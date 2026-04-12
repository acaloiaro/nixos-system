{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellApplication {
      name = "run-in-zellij";
      runtimeInputs = with pkgs; [zellij];
      text = ''
        # Usage: run-in-zellij [--width W] [--height H] [--x X] [--y Y] [--emit-hook-json] [--] <command> [args...]

        width="80%"
        height="80%"
        x="10%"
        y="10%"
        emit_hook_json="false"

        while [[ $# -gt 0 ]]; do
          case "$1" in
            --width)          width="$2";           shift 2 ;;
            --height)         height="$2";          shift 2 ;;
            --x)              x="$2";               shift 2 ;;
            --y)              y="$2";               shift 2 ;;
            --emit-hook-json) emit_hook_json="true"; shift ;;
            --)               shift; break ;;
            *)                break ;;
          esac
        done

        if [[ $# -lt 1 ]]; then
          echo "Usage: run-in-zellij [--width W] [--height H] [--x X] [--y Y] [--emit-hook-json] [--] <command> [args...]" >&2
          exit 1
        fi

        fifo=$(mktemp -u /tmp/run-in-zellij-XXXXXX)
        mkfifo "$fifo"

        exitfile=$(mktemp /tmp/run-in-zellij-result-XXXXXX)
        inner=$(mktemp /tmp/run-in-zellij-inner-XXXXXX.sh)
        chmod +x "$inner"
        trap 'rm -f "$fifo" "$inner" "$exitfile"' EXIT

        # Inner script: run the command, then signal its exit code via the fifo.
        # The fifo write blocks until the parent's background reader consumes it,
        # which is what prevents --close-on-exit from racing ahead.
        {
          printf '#!/usr/bin/env bash\n'
          printf '%q ' "$@"
          printf '\n'
          printf 'echo $? > %q\n' "$fifo"
        } > "$inner"

        # Start the fifo reader before launching zellij so it is ready
        # when the inner script writes. Uses a temp file (not a variable)
        # to avoid subshell scoping issues with the backgrounded cat.
        cat "$fifo" > "$exitfile" &
        reader_pid=$!

        zellij run --floating --close-on-exit --name "run-in-zellij" \
          --width "$width" --height "$height" --x "$x" --y "$y" \
          -- bash "$inner"

        # Block until the inner script has written the exit code via the fifo.
        # This is the key: zellij run may return before the pane finishes,
        # so wait here keeps us parked until the user has actually responded.
        wait "$reader_pid" || true
        exit_code=$(cat "$exitfile" 2>/dev/null)

        if [[ "$emit_hook_json" == "true" ]]; then
          if [[ "''${exit_code:-1}" -eq 0 ]]; then
            printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"Approved in diff viewer"}}\n'
          else
            printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Rejected in diff viewer"}}\n'
          fi
        fi

        exit "''${exit_code:-1}"
      '';
    })
  ];
}
