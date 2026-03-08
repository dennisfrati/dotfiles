# fzf / fd / ripgrep shared environment

if ! command -v fzf >/dev/null 2>&1; then
  return 0 2>/dev/null || :
fi

export VISUAL="$EDITOR"

if command -v fd >/dev/null 2>&1; then
  FD_BIN="fd"
elif command -v fdfind >/dev/null 2>&1; then
  FD_BIN="fdfind"
else
  FD_BIN=""
fi

export FD_BIN
# --hidden: include hidden files
# --follow: follow symlinks
# --exclude .git: ignore .git directories

if [ -n "$FD_BIN" ]; then
	export FD_OPTIONS="--hidden --follow --exclude .git"
fi

if command -v rg >/dev/null 2>&1; then
	if [ -f "$HOME/.ripgreprc" ]; then
		export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
	fi
fi

# FZF core environment (sources for file/dir lists)
if [ -n "$FD_BIN" ]; then
  export FZF_DEFAULT_COMMAND="$FD_BIN ${FD_OPTIONS:-} --type f"
else
  export FZF_DEFAULT_COMMAND="find . -type f 2>/dev/null"
fi

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

if [ -n "$FD_BIN" ]; then
  export FZF_ALT_C_COMMAND="$FD_BIN ${FD_OPTIONS:-} --type d"
else
  export FZF_ALT_C_COMMAND="find . -type d 2>/dev/null"
fi

if command -v bat >/dev/null 2>&1; then
  FZF_DEFAULT_OPTS='
    --height 40%
    --border
    --info=inline
    --reverse
    --bind=ctrl-a:select-all,ctrl-d:deselect-all
    --preview "bat --style=numbers --color=always --line-range=:200 {}"
    --preview-window=right:60%
  '
elif command -v batcat >/dev/null 2>&1; then
  FZF_DEFAULT_OPTS='
    --height 40%
    --border
    --info=inline
    --reverse
    --bind=ctrl-a:select-all,ctrl-d:deselect-all
    --preview "batcat --style=numbers --color=always --line-range=:200 {}"
    --preview-window=right:60%
  '
else
  FZF_DEFAULT_OPTS='
    --height 40%
    --border
    --info=inline
    --reverse
    --bind=ctrl-a:select-all,ctrl-d:deselect-all
  '
fi

# FZF vi-style keybindings
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --style=full --bind j:down,k:up,g:top,ctrl-u:half-page-up,ctrl-d:half-page-down,ctrl-f:page-down,ctrl-b:page-up"

export FZF_DEFAULT_OPTS

_fzf_fd_files() {
  if [ -n "$FD_BIN" ]; then
    "$FD_BIN" ${FD_OPTIONS:-} --type f
  else
    find . -type f 2>/dev/null
  fi
}

_fzf_fd_dirs() {
  if [ -n "$FD_BIN" ]; then
    "$FD_BIN" ${FD_OPTIONS:-} --type d
  else
    find . -type d 2>/dev/null
  fi
}

# General-purpose FZF helpers
ff() {
  local file
  file="$(_fzf_fd_files | fzf)" || return
  [ -n "$file" ] && "$EDITOR" "$file"
}

# ffm: fuzzy-find multiple files and open all in EDITOR
ffm() {
  local -a files
  mapfile -t files < <(_fzf_fd_files | fzf -m) || return
  [ ${#files[@]} -gt 0 ] && "$EDITOR" "${files[@]}"
}

# fcd: fuzzy cd into a directory
fcd() {
  local dir
  dir="$(_fzf_fd_dirs | fzf)" || return
  [ -n "$dir" ] && cd "$dir" || return
}

# ftree: fuzzy file selection with "tree" preview (optional)
ftree() {
  local file
  if ! command -v tree >/dev/null 2>&1; then
    echo "ftree: 'tree' is not installed." >&2
    return 1
  fi
  file="$(_fzf_fd_files | fzf --preview 'tree -C $(dirname {}) | head -200')" || return
  [ -n "$file" ] && "$EDITOR" "$file"
}

# fh: fuzzy search shell history (prints, does not execute)
fh() {
  local selected cmd
  # history output with HISTTIMEFORMAT: " 123  dd/mm/yyyy hh:mm:ss  command..."
  selected="$(history | fzf)" || return
  cmd="$(echo "$selected" | awk '{$1=$2=$3=""; sub(/^[[:space:]]+/,""); print}')"
  printf '%s\n' "$cmd"
}

# frg: fuzzy-select search result (rg) and go to line in EDITOR
frg() {
  if ! command -v rg >/dev/null 2>&1; then
    echo "frg: ripgrep (rg) is not installed." >&2
    return 1
  fi

  if [ $# -lt 1 ]; then
    echo "Usage: frg <pattern>" >&2
    return 1
  fi

  local result file line
  result="$(rg --line-number --no-heading "$@" | fzf)" || return
  file="${result%%:*}"
  line="${result#*:}"
  line="${line%%:*}"

  [ -n "$file" ] && "$EDITOR" "+${line}" "$file"
}

# frgf: fuzzy-select file from ripgrep file list (rg --files)
frgf() {
  if ! command -v rg >/dev/null 2>&1; then
    echo "frgf: ripgrep (rg) is not installed." >&2
    return 1
  fi

  local file
  file="$(rg --files | fzf)" || return
  [ -n "$file" ] && "$EDITOR" "$file"
}

# fkill: fuzzy-select a process and kill it (SIGKILL by default)
fkill() {
  local line pid
  if command -v ps >/dev/null 2>&1; then
    line="$(
      ps -eo pid,comm,user,pcpu,pmem --sort=-pcpu \
      | sed 1d \
      | fzf --header='Select process to kill'
    )" || return
    pid="$(echo "$line" | awk '{print $1}')"
    [ -n "$pid" ] && kill -9 "$pid"
  else
    echo "fkill: ps not available." >&2
    return 1
  fi
}

# fgb: fuzzy-select a git branch and checkout
fgb() {
  if ! command -v git >/dev/null 2>&1; then
    echo "fgb: git is not installed." >&2
    return 1
  fi

  local branch
  branch="$(
    git branch --all --color=always 2>/dev/null \
    | sed 's/^[* ]*//' \
    | sed 's#^remotes/##' \
    | sort -u \
    | fzf --ansi --header='Select git branch'
  )" || return

  [ -n "$branch" ] && git checkout "$branch"
}

# fgt: fuzzy-select a git tag and show it
fgt() {
  if ! command -v git >/dev/null 2>&1; then
    echo "fgt: git is not installed." >&2
    return 1
  fi

  local tag
  tag="$(git tag --sort=-creatordate | fzf --header='Select git tag')" || return
  [ -n "$tag" ] && git show "$tag"
}

# fgc: fuzzy-select a git commit and show it
fgc() {
  if ! command -v git >/dev/null 2>&1; then
    echo "fgc: git is not installed." >&2
    return 1
  fi

  local commit
  commit="$(
    git log --oneline --decorate --graph --all \
    | fzf --ansi --no-sort --reverse --tiebreak=index --header='Select commit'
  )" || return

  commit="${commit%% *}"
  [ -n "$commit" ] && git show "$commit"
}

# fsys: fuzzy-select a systemd service and show its status
fsys() {
  if ! command -v systemctl >/dev/null 2>&1; then
    echo "fsys: systemctl is not available." >&2
    return 1
  fi

  local unit
  unit="$(
    systemctl list-units --type=service --no-pager --no-legend \
    | awk '{print $1}' \
    | fzf --header='Select systemd service'
  )" || return

  [ -n "$unit" ] && systemctl status "$unit"
}

# fjournal: fuzzy-select a service and show its journal
fjournal() {
  if ! command -v systemctl >/dev/null 2>&1; then
    echo "fjournal: systemctl is not available." >&2
    return 1
  fi
  if ! command -v journalctl >/dev/null 2>&1; then
    echo "fjournal: journalctl is not available." >&2
    return 1
  fi

  local unit
  unit="$(
    systemctl list-units --type=service --no-pager --no-legend \
    | awk '{print $1}' \
    | fzf --header='Select systemd service'
  )" || return

  [ -n "$unit" ] && journalctl -u "$unit" -e
}

# fdc_logs: fuzzy-select a running container and follow its logs
fdc_logs() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "fdc_logs: docker is not installed." >&2
    return 1
  fi

  local line cid
  line="$(
    docker ps --format '{{.ID}} {{.Names}} {{.Status}}' \
    | fzf --header='Select container for logs'
  )" || return

  cid="${line%% *}"
  [ -n "$cid" ] && docker logs -f "$cid"
}

# fdc_shell: fuzzy-select a running container and open a shell inside
fdc_shell() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "fdc_shell: docker is not installed." >&2
    return 1
  fi

  local line cid
  line="$(
    docker ps --format '{{.ID}} {{.Names}} {{.Image}}' \
    | fzf --header='Select container for shell'
  )" || return

  cid="${line%% *}"

  if [ -n "$cid" ]; then
    # Try bash first, then sh
    docker exec -it "$cid" bash 2>/dev/null || docker exec -it "$cid" sh
  fi
}

# fssh: fuzzy-select a host from ~/.ssh/config and connect via ssh
fssh() {
  local host
  if [ ! -f "$HOME/.ssh/config" ]; then
    echo "fssh: $HOME/.ssh/config not found." >&2
    return 1
  fi

  host="$(
    grep -iE '^\s*Host\s+' "$HOME/.ssh/config" \
    | sed 's/^\s*Host\s\+//' \
    | grep -v '*' \
    | fzf --header='Select SSH host'
  )" || return

  [ -n "$host" ] && ssh "$host"
}

# fkc: fuzzy-select a kubectl context and switch to it
fkc() {
  if ! command -v kubectl >/dev/null 2>&1; then
    echo "fkc: kubectl is not installed." >&2
    return 1
  fi

  local ctx
  ctx="$(kubectl config get-contexts -o name | fzf --header='Select kubectl context')" || return
  [ -n "$ctx" ] && kubectl config use-context "$ctx"
}

# fkp_logs: fuzzy-select a pod in the current namespace and follow its logs
fkp_logs() {
  if ! command -v kubectl >/dev/null 2>&1; then
    echo "fkp_logs: kubectl is not installed." >&2
    return 1
  fi

  local pod
  pod="$(
    kubectl get pods --no-headers \
    | awk '{print $1}' \
    | fzf --header='Select pod'
  )" || return

  [ -n "$pod" ] && kubectl logs -f "$pod"
}
