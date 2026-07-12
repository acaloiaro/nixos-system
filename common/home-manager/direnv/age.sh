: "${AGE_DOTENV_IDENTITY:=}"

# load_age_dotenv decrypts `file` and exports its variables into the direnv environment.
# `identity` must be an age plugin identity string (AGE-PLUGIN-NAME-1...); age invokes the
# corresponding plugin binary to perform decryption, so key material never passes through this shell.
load_age_dotenv() {
  local file="${1:-.env.age}"
  local identity="${2:-$AGE_DOTENV_IDENTITY}"

  watch_file "$file"
  [[ -f "$file" ]] || return 0
  [[ -n "$identity" ]] || { echo "load_age_dotenv: no identity — set AGE_DOTENV_IDENTITY or pass as second argument" >&2; return 1; }

  eval "$(age --decrypt --identity <(echo "$identity") "$file" | direnv dotenv bash /dev/stdin)"
}
