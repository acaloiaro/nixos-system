{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellApplication {
      name = "run-in-mux";
      runtimeInputs = with pkgs; [zellij tmux jq];
      excludeShellChecks = ["SC2016"];
      text = ''
        # Usage: run-in-mux [--name N] [--width W] [--height H] [--x X] [--y Y] [--] <command> [args...]
        #
        # Runs <command> in a floating overlay of whichever terminal multiplexer
        # the caller is inside: a zellij floating pane or a tmux popup. When the
        # caller is in neither, the command runs inline in the current terminal.

        name="run-in-mux"
        width="80%"
        height="80%"
        x="10%"
        y="10%"

        while [[ $# -gt 0 ]]; do
          case "$1" in
            --name)   name="$2";   shift 2 ;;
            --width)  width="$2";  shift 2 ;;
            --height) height="$2"; shift 2 ;;
            --x)      x="$2";      shift 2 ;;
            --y)      y="$2";      shift 2 ;;
            --)       shift; break ;;
            *)        break ;;
          esac
        done

        if [[ $# -lt 1 ]]; then
          echo "Usage: run-in-mux [--name N] [--width W] [--height H] [--x X] [--y Y] [--] <command> [args...]" >&2
          exit 1
        fi

        # Detect the host multiplexer. zellij takes precedence when both are
        # set (e.g. zellij running inside tmux) so the floating pane lands in
        # the multiplexer the user is actually looking at.
        if [[ -n "''${ZELLIJ:-}" ]]; then
          mux="zellij"
        elif [[ -n "''${TMUX:-}" ]]; then
          mux="tmux"
        else
          mux="none"
        fi

        # No multiplexer: nothing to float into, so just run the command
        # directly in the current terminal and pass its exit code through.
        if [[ "$mux" == "none" ]]; then
          exec "$@"
        fi

        # All per-invocation artifacts live in one tempdir so concurrent
        # callers can't collide on filenames. BSD mktemp (macOS) only
        # substitutes trailing X's, which made the previous per-file
        # template `...-inner-XXXXXX.sh` resolve to a literal name and
        # fail under concurrency.
        tmpdir=$(mktemp -d /tmp/run-in-mux-XXXXXX)
        trap 'rm -rf "$tmpdir"' EXIT

        fifo="$tmpdir/fifo"
        exitfile="$tmpdir/exit"
        outfile="$tmpdir/out"
        stdinfile="$tmpdir/stdin"
        inner="$tmpdir/inner.sh"
        mkfifo "$fifo"

        # Capture stdin before the multiplexer takes over the terminal.
        # Skip when stdin is a TTY — cat would block waiting for EOF
        # that never arrives from an interactive keyboard.
        if [[ ! -t 0 ]]; then
          cat > "$stdinfile"
        fi

        # Inner script: run the command, capturing output, then signal exit code via the fifo.
        # The fifo write blocks until the parent's background reader consumes it,
        # which is what prevents close-on-exit from racing ahead.
        {
          printf '#!/usr/bin/env bash\n'
          # Only shadow the pane's keyboard stdin when there is real piped data;
          # redirecting an empty file blocks y/n and other interactive prompts.
          printf '[[ -s %q ]] && exec 0< %q\n' "$stdinfile" "$stdinfile"
          printf '%q ' "$@"
          # tee: show output in the pane so the user can see prompts, and also
          # capture it to outfile for the caller.
          printf '2>&1 | tee %q\n' "$outfile"
          printf 'echo "''${PIPESTATUS[0]}" > %q\n' "$fifo"
        } > "$inner"

        # Start the fifo reader before launching the multiplexer so it is
        # ready when the inner script writes. Uses a temp file (not a variable)
        # to avoid subshell scoping issues with the backgrounded cat.
        cat "$fifo" > "$exitfile" &
        reader_pid=$!

        case "$mux" in
          zellij)
            # Pin the floating pane to the caller's tab. Without --tab-id,
            # zellij attaches it to whichever tab the user is currently viewing,
            # which hijacks their focus when background agents trigger us.
            tab_id_args=()
            if [[ -n "''${ZELLIJ_PANE_ID:-}" ]]; then
              caller_tab_id=$(
                zellij action list-panes --json --tab 2>/dev/null \
                  | jq -r --argjson pid "$ZELLIJ_PANE_ID" \
                      'map(select(.id == $pid and (.is_plugin | not))) | .[0].tab_id // empty'
              )
              if [[ -n "$caller_tab_id" ]]; then
                tab_id_args=(--tab-id "$caller_tab_id")
              else
                echo "run-in-mux: could not resolve tab for pane $ZELLIJ_PANE_ID; floating pane may open on the active tab" >&2
              fi
            fi

            zellij run --floating --close-on-exit --name "$name" \
              --width "$width" --height "$height" --x "$x" --y "$y" \
              "''${tab_id_args[@]}" \
              -- bash "$inner" > /dev/null
            ;;
          tmux)
            # tmux popups are client overlays, not tab-attached, so there is
            # no tab to pin. -E closes the popup when the inner script exits;
            # display-popup blocks the calling client until the popup closes.
            tmux display-popup -E -T "$name" \
              -w "$width" -h "$height" -x "$x" -y "$y" \
              "bash $inner"
            ;;
        esac

        # Block until the inner script has written the exit code via the fifo.
        # This is the key: the launch command may return before the pane
        # finishes, so wait here keeps us parked until the user has responded.
        wait "$reader_pid" || true
        exit_code=$(cat "$exitfile" 2>/dev/null)

        cat "$outfile" 2>/dev/null
        exit "''${exit_code:-1}"
      '';
    })
  ];
}
