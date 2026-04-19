{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellApplication {
      name = "run-in-zellij";
      runtimeInputs = with pkgs; [zellij];
      text = ''
        # Usage: run-in-zellij [--width W] [--height H] [--x X] [--y Y] [--] <command> [args...]

        width="80%"
        height="80%"
        x="10%"
        y="10%"

        while [[ $# -gt 0 ]]; do
          case "$1" in
            --width)  width="$2";  shift 2 ;;
            --height) height="$2"; shift 2 ;;
            --x)      x="$2";      shift 2 ;;
            --y)      y="$2";      shift 2 ;;
            --)       shift; break ;;
            *)        break ;;
          esac
        done

        if [[ $# -lt 1 ]]; then
          echo "Usage: run-in-zellij [--width W] [--height H] [--x X] [--y Y] [--] <command> [args...]" >&2
          exit 1
        fi

        fifo=$(mktemp -u /tmp/run-in-zellij-XXXXXX)
        mkfifo "$fifo"

        exitfile=$(mktemp /tmp/run-in-zellij-result-XXXXXX)
        outfile=$(mktemp /tmp/run-in-zellij-output-XXXXXX)
        stdinfile=$(mktemp /tmp/run-in-zellij-stdin-XXXXXX)
        inner=$(mktemp /tmp/run-in-zellij-inner-XXXXXX.sh)
        chmod +x "$inner"
        trap 'rm -f "$fifo" "$inner" "$exitfile" "$outfile" "$stdinfile"' EXIT

        # Capture stdin before zellij takes over the terminal.
        # Skip when stdin is a TTY — cat would block waiting for EOF
        # that never arrives from an interactive keyboard.
        if [[ ! -t 0 ]]; then
          cat > "$stdinfile"
        fi

        # Inner script: run the command, capturing output, then signal exit code via the fifo.
        # The fifo write blocks until the parent's background reader consumes it,
        # which is what prevents --close-on-exit from racing ahead.
        {
          printf '#!/usr/bin/env bash\n'
          printf '%q ' "$@"
          printf '< %q > %q 2>&1\n' "$stdinfile" "$outfile"
          printf 'echo $? > %q\n' "$fifo"
        } > "$inner"

        # Start the fifo reader before launching zellij so it is ready
        # when the inner script writes. Uses a temp file (not a variable)
        # to avoid subshell scoping issues with the backgrounded cat.
        cat "$fifo" > "$exitfile" &
        reader_pid=$!

        zellij run --floating --close-on-exit --name "run-in-zellij" \
          --width "$width" --height "$height" --x "$x" --y "$y" \
          -- bash "$inner" > /dev/null

        # Block until the inner script has written the exit code via the fifo.
        # This is the key: zellij run may return before the pane finishes,
        # so wait here keeps us parked until the user has actually responded.
        wait "$reader_pid" || true
        exit_code=$(cat "$exitfile" 2>/dev/null)

        cat "$outfile" 2>/dev/null
        exit "''${exit_code:-1}"
      '';
    })
  ];
}
