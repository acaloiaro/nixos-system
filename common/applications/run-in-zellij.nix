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

        zellij run --floating --close-on-exit --name "run-in-zellij" \
          --width "$width" --height "$height" --x "$x" --y "$y" \
          -- "$@"
      '';
    })
  ];
}
