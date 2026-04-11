#!/usr/bin/env bash
# diff-review.sh - Claude Code PreToolUse hook for reviewing edits in a diff tool.
# Intercepts Edit and Write tool calls, constructs original/proposed temp files,
# and opens a configurable diff tool for review before allowing or denying.
set -euo pipefail

# Known tools that support non-zero exit for rejection (:cq in vim, etc.)
EXIT_CODE_TOOLS="gvimdiff|helix|hx|kak|kakoune|nvim|vi|vimdiff|vim"

# --- Configuration ---

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/claude-diff-review"
config_path="${CLAUDE_DIFF_CONFIG:-$config_dir/config.json}"

# --init: seed a default config file
if [[ "${1:-}" == "--init" ]]; then
	if [[ -f "$config_path" ]]; then
		echo "Config already exists: $config_path"
	else
		mkdir -p "$(dirname "$config_path")"
		cat >"$config_path" <<'EOF'
{
  "enabled": true,
  "command": "nvim -d",
  "decision": "auto",
  "display": "auto",
  "context": true
}
EOF
		echo "Created: $config_path"
	fi
	exit 0
fi

# Read config file defaults (all optional)
cfg_enabled="true"
cfg_cmd="nvim -d"
cfg_decision="auto"
cfg_display="auto"
cfg_context="true"

if [[ -f "$config_path" ]]; then
	cfg_enabled=$(jq -r '.enabled // true' "$config_path")
	cfg_cmd=$(jq -r '.command // "nvim -d"' "$config_path")
	cfg_decision=$(jq -r '.decision // "auto"' "$config_path")
	cfg_display=$(jq -r '.display // "auto"' "$config_path")
	cfg_context=$(jq -r '.context // true' "$config_path")
fi

# Env vars override config
diff_cmd="${CLAUDE_DIFF_CMD:-$cfg_cmd}"
diff_decision="${CLAUDE_DIFF_DECISION:-$cfg_decision}"
diff_display="${CLAUDE_DIFF_DISPLAY:-$cfg_display}"
diff_enabled="${CLAUDE_DIFF_ENABLED:-}"
diff_context="${CLAUDE_DIFF_CONTEXT:-$cfg_context}"

# Check enabled state: env var -> config -> toggle file
if [[ "$diff_enabled" == "0" ]]; then
	exit 0
fi
if [[ "$cfg_enabled" == "false" ]] && [[ -z "$diff_enabled" ]]; then
	exit 0
fi
if [[ -f "$config_dir/disabled" ]]; then
	exit 0
fi

# --- Read hook input ---

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')

# Only handle Edit and Write
case "$tool_name" in
Edit | Write) ;;
*) exit 0 ;;
esac

# --- Temp file management ---

diff_tmpdir=$(mktemp -d "/tmp/claude-diff-XXXXXX")
chmod 0700 "$diff_tmpdir"
trap 'rm -rf "$diff_tmpdir"' EXIT

make_temp() {
	local ext="$1"
	local label="$2"
	local tmp="$diff_tmpdir/${label}${ext}"
	touch "$tmp"
	chmod 0600 "$tmp"
	echo "$tmp"
}

# --- Context helpers ---

comment_prefix() {
	case "$1" in
	.go | .c | .cpp | .h | .hpp | .java | .js | .jsx | .ts | .tsx | .rs | .swift | .kt | .kts | .cs | .scala | .groovy | .m) echo "//" ;;
	.lua | .hs | .sql) echo "--" ;;
	.vim | .el | .clj | .cljs | .lisp | .scm) echo ";" ;;
	*) echo "#" ;;
	esac
}

extract_context() {
	local transcript="$1"
	local prefix="$2"

	if [[ -z "$transcript" ]] || [[ ! -f "$transcript" ]]; then
		return
	fi

	local raw_text
	raw_text=$(tac "$transcript" | jq -rc '
    select(.type == "assistant") |
    select(.message.content | any(.type == "text")) |
    [.message.content[] | select(.type == "text") | .text][0] // empty
  ' 2>/dev/null | head -1)

	if [[ -z "$raw_text" ]]; then
		return
	fi

	# Strip markdown formatting and take first meaningful line
	local summary
	summary=$(echo "$raw_text" |
		sed 's/\*\*//g; s/`//g; s/^```.*//; s/^★.*//; s/^─.*//; s/^[[:space:]]*//' |
		grep -v '^$' | head -1)

	if [[ -z "$summary" ]]; then
		return
	fi

	# Word-wrap into multiple comment lines (~50 chars each)
	local first=true
	while IFS= read -r wrap_line; do
		if [[ "$first" == "true" ]]; then
			printf '%s [context] %s\n' "$prefix" "$wrap_line"
			first=false
		else
			printf '%s %s\n' "$prefix" "$wrap_line"
		fi
	done < <(echo "$summary" | fold -s -w 50)
}

prepend_lines() {
	local text="$1"
	local file="$2"
	local tmp="${file}.prepend"
	printf '%s\n\n' "$text" | cat - "$file" >"$tmp"
	mv "$tmp" "$file"
}

# --- Build original and proposed temp files (real file is never modified) ---

file_path=$(echo "$input" | jq -r '.tool_input.file_path')
ext="${file_path##*.}"
[[ "$ext" == "$file_path" ]] && ext="" || ext=".$ext"
file_dir="$(dirname "$file_path")"
file_basename=$(basename "$file_path")

mkdir -p "$diff_tmpdir/original" "$diff_tmpdir/proposed"
original_path="$diff_tmpdir/original/$file_basename"
proposed_path="$diff_tmpdir/proposed/$file_basename"
touch "$original_path" "$proposed_path"
chmod 0600 "$original_path" "$proposed_path"

if [[ "$tool_name" == "Edit" ]]; then
	# Use old_string/new_string directly — avoids reading the real file entirely
	echo "$input" | jq -r '.tool_input.old_string' >"$original_path"
	echo "$input" | jq -r '.tool_input.new_string' >"$proposed_path"

elif [[ "$tool_name" == "Write" ]]; then
	if [[ -f "$file_path" ]]; then
		cp "$file_path" "$original_path"
	fi
	chmod 0600 "$original_path"
	echo "$input" | jq -r '.tool_input.content' >"$proposed_path"
fi

# Save a byte-exact backup of proposed before the diff tool runs, for change detection
proposed_backup=$(make_temp "$ext" "proposed_backup")
cp "$proposed_path" "$proposed_backup"

# --- Build display copy for left pane (original + context) ---

mkdir -p "$diff_tmpdir/display"
display_path="$diff_tmpdir/display/$file_basename"
touch "$display_path"
chmod 0600 "$display_path"
cp "$original_path" "$display_path"

ctx_lines=""
if [[ "$diff_context" != "false" ]] && [[ "$diff_context" != "0" ]]; then
	ctx_prefix=$(comment_prefix "$ext")
	ctx_lines=$(extract_context "$transcript_path" "$ctx_prefix")
	if [[ -n "$ctx_lines" ]]; then
		prepend_lines "$ctx_lines" "$display_path"
	fi
fi

# --- Resolve display strategy ---

diff_bin="${diff_cmd%% *}"
diff_bin="${diff_bin##*/}"

is_terminal_tool() {
	[[ "$diff_bin" =~ ^($EXIT_CODE_TOOLS)$ ]]
}

effective_display="$diff_display"
if [[ "$effective_display" == "auto" ]]; then
	if [[ -n "${TMUX:-}" ]] && is_terminal_tool; then
		effective_display="tmux-popup"
	else
		effective_display="direct"
	fi
fi

# --- Resolve decision mode ---

effective_decision="$diff_decision"
if [[ "$effective_decision" == "auto" ]]; then
	if is_terminal_tool; then
		effective_decision="exit-code"
	else
		effective_decision="ask"
	fi
fi

# --- Launch diff tool ---

read -ra cmd_parts <<<"$diff_cmd"

# Vim-family: lock left pane read-only, focus right pane
case "$diff_bin" in
gvimdiff | nvim | vi | vim | vimdiff)
	cmd_parts+=(-c "1windo setlocal nomodifiable readonly" -c "wincmd l")
	;;
esac

diff_exit=0

tmux_title_args=()
if [[ -n "$ctx_lines" ]]; then
	tmux_summary=$(echo "$ctx_lines" | head -1 | sed "s/^[^]]*] //")
	ctx_line_count=$(echo "$ctx_lines" | wc -l)
	if [[ "$ctx_line_count" -gt 1 ]]; then
		tmux_summary="${tmux_summary}..."
	fi
	tmux_title_args=(-T "$tmux_summary")
fi

case "$effective_display" in
tmux-popup)
	tmux display-popup -E -w 90% -h 90% -d "$file_dir" "${tmux_title_args[@]}" -- "${cmd_parts[@]}" "$display_path" "$proposed_path" || diff_exit=$?
	;;
tmux-split)
	tmux split-window -h -c "$file_dir" -- "${cmd_parts[@]}" "$display_path" "$proposed_path" || diff_exit=$?
	;;
direct | *)
	(cd "$file_dir" && "${cmd_parts[@]}" "$display_path" "$proposed_path") || diff_exit=$?
	;;
esac

# --- Output decision ---

emit_allow() {
	jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      permissionDecisionReason: "Reviewed in diff tool"
    }
  }'
}

emit_updated_input() {
	local current_path="$1"
	if [[ "$tool_name" == "Write" ]]; then
		# file_path required — Claude Code replaces tool_input entirely with updatedInput
		jq --rawfile content "$current_path" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "allow",
        permissionDecisionReason: "Reviewed in diff tool",
        updatedInput: { file_path: .tool_input.file_path, content: $content }
      }
    }' <<<"$input"
	else
		# file_path required for same reason.
		# old_string from original input (no roundtrip — preserves exact bytes incl. trailing newlines)
		# new_string via --rawfile (preserves trailing newlines)
		jq --rawfile new "$current_path" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "allow",
        permissionDecisionReason: "Reviewed in diff tool",
        updatedInput: {
          file_path: .tool_input.file_path,
          old_string: .tool_input.old_string,
          new_string: $new,
          replace_all: (.tool_input.replace_all // false)
        }
      }
    }' <<<"$input"
	fi
}

# Compare proposed file now vs byte-exact backup saved before diff tool ran
content_changed() {
	! cmp -s "$proposed_path" "$proposed_backup"
}

if [[ "$effective_decision" == "ask" ]]; then
	if content_changed; then
		emit_updated_input "$proposed_path"
	else
		emit_allow
	fi
elif [[ "$diff_exit" -eq 0 ]]; then
	if content_changed; then
		emit_updated_input "$proposed_path"
	else
		emit_allow
	fi
else
	jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Rejected during diff review"
    }
  }'
fi
