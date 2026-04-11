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

        inner=$(mktemp /tmp/run-in-zellij-inner-XXXXXX.sh)
        chmod +x "$inner"

        exitfile=$(mktemp /tmp/run-in-zellij-result-XXXXXX)
        trap 'rm -f "$fifo" "$inner" "$exitfile"' EXIT

        {
          printf '#!/usr/bin/env bash\n'
          printf '%q ' "$@"
          printf '\n'
          printf 'echo $? > %q\n' "$fifo"
        } > "$inner"

        # Read from fifo in background before launching zellij so the reader
        # is ready whether zellij run blocks or not; write result to exitfile
        # so it's accessible in the parent shell (subshell vars are not)
        cat "$fifo" > "$exitfile" &
        reader_pid=$!

        zellij run --floating --close-on-exit --name "run-in-zellij" \
          --width "$width" --height "$height" --x "$x" --y "$y" \
          -- bash "$inner"

        wait "$reader_pid"
        exit_code=$(cat "$exitfile")
        exit "''${exit_code:-1}"
      '';
    })
  ];
}
