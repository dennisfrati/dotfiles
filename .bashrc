# ~/.bashrc by Dennis Frati

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#========== functions =========

# easy function mkdir and enter
mkcd() {
	mkdir -p "${1}" && cd "${1}"
}

# lazy load thefuck
fuck() {
    eval "$(thefuck --alias)" && fuck "$@"
}

# System update function
upgrade() {
	if command -v pacman &>/dev/null; then
        	# Arch/Manjaro
		sudo pacman -Syu
    	elif command -v apt &>/dev/null; then
        	# Debian/Ubuntu
        	sudo apt update && sudo apt upgrade -y
    	elif command -v dnf &>/dev/null; then
        	# Fedora
        	sudo dnf upgrade -y
    	elif command -v yum &>/dev/null; then
        	# CentOS/RHEL (old)
        	sudo yum update -y
    	elif command -v zypper &>/dev/null; then
        	# openSUSE
        	sudo zypper update -y
    	elif command -v apk &>/dev/null; then
        	# Alpine
        	sudo apk update && sudo apk upgrade
    	else
        	echo "Package manager not recognized"
        	return 1
    	fi
}

# functions for git
parse_git_dirty() {
	[[ $(git status --porcelain 2>/dev/null) ]] && echo "*"
}

parse_git_branch() {
	git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/ (\1$(parse_git_dirty))/"
}

# function for current command
current_command() {
	line="$(history 1 | awk '{print $4}')"
	printf "%s" "${line}"
}

# exit code function
exit_code(){
	[[ ! $1 -eq 0 ]] && echo " $1 " || echo ""
}

# empty lines fuction clearing
rmemptylines() {
	sed -i '/^$/d' "${@}"
}

# info about hardware
hw_info() {
	sudo dmidecode | grep -i -A9 "^System information"
}

#========== colors ============

# colors with \[\033
YELLOW='\[\033[1;33m\]'
RED='\[\033[0;31m\]'
NO_COLOR='\[\033[0m\]'

# ========= variables =========

DATE=$(date '+%T %F' | tr -d '\n')
TTY=$(tty)

#========== export ============

# PS1 prompt
if [[ -n "${TERMUX_VERSION}" ]]; then
	export PS1="[${YELLOW}\$(exit_code \${?})${NO_COLOR} \w${RED} \$(parse_git_branch)${NO_COLOR}]\$ "
elif [[ "${OSTYPE}" == "linux-gnu"* ]]; then
	export PS1="[${YELLOW}\$(exit_code \${?})${NO_COLOR}${RED}\u${NO_COLOR}@${RED}\h${NO_COLOR} \w${RED}\$(parse_git_branch)${NO_COLOR}]\$ "
elif [[ "${OSTYPE}" == "darwin"* ]]; then
	export PS1="[\u@\w]\$ "
else
	export PS1=""
fi

# editor (i prefer using vim, i really like it)
if command -v vim &>/dev/null; then
	export EDITOR='vim'
elif command -v nvim &>/dev/null; then
	export EDITOR='nvim'
else
	export EDITOR='nano'
fi

# executables path
export PATH="$PATH:/sbin:$HOME/.local/bin"

# variable for commands to ignore
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"

#========= alias =============

alias lss='\ls -sh'
alias ls='ls --color=auto -alFh'
alias edbash='$EDITOR ~/.bashrc'
alias reloadbash='source ~/.bashrc'
alias catall='for i in *; do if [[ ! -d $i ]]; then echo -e "\033[31m$i: \033[37m"; cat $i 2>/dev/null; fi; done'
alias edtmux='$EDITOR ~/.tmux.conf'
alias colors='for i in {0..255}; do printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"; done | xargs'
alias grep='grep --color=auto'
alias last_mod='\ls -t1F | head -n 1'
alias who='who --all'
alias free='free -h'
alias stophist='set +o history'
alias restarthist='set -o history'
alias xargs='xargs -t'
alias passgen='pwgen -s -y 20 | head -n 1 | cut -d " " -f 1'
alias ls_proc='\ls /proc | grep "[^0-9]"'
alias edlogout='$EDITOR ~/.bash_logout'
alias torcheck='torsocks wget -qO- https://check.torproject.org/ | grep -i congratulations'
alias edgrub='$EDITOR /etc/default/grub'
alias edvim='$EDITOR ~/.vimrc'
alias cvecheck='arch-audit --upgradable'
alias grepr='grep -Ril'
alias uncomment_clean="sed -e '/^$/d' -e '/^[[:space:]]*#/d'"

#========= options ===========

# Readline/completion settings
bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'
bind -m vi-insert 'TAB:menu-complete'
bind -m vi-insert 'Space:magic-space'
bind "set completion-map-case on"
bind "set mark-symlinked-directories on"

# Arrow keys for history search (vi-insert keymap)
bind -m vi-insert '"\e[A": history-search-backward'
bind -m vi-insert '"\e[B": history-search-forward'
bind -m vi-insert '"\e[C": forward-char'
bind -m vi-insert '"\e[D": backward-char'

# i prefer use vi, if you want to use emacs delete this line
set -o vi

# shell behavior and history
shopt -s checkwinsize
shopt -s globstar
shopt -s nocaseglob
shopt -s histappend
shopt -s cmdhist
shopt -s dirspell
shopt -s autocd
shopt -s cdable_vars

# Prompt settings
PROMPT_DIRTRIM=2
PROMPT_COMMAND='history -a'

# History configuration
HISTSIZE=500000
HISTFILESIZE=500000
HISTCONTROL="erasedups:ignoreboth"
HISTTIMEFORMAT='%d/%m/%Y %T '

#========== run-programs ===========

# bash-completion
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
	. /usr/share/bash-completion/bash_completion
fi

# bash functions
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local

# bash secrets
[[ -f ~/.bash_secrets ]] && source ~/.bash_secrets

# Config fzf/fd/rg
[[ -f ~/.fzf/env.sh ]] && source ~/.fzf/env.sh

# Bindings/completion specifici di Bash
if [[ -r /usr/share/fzf/key-bindings.bash ]]; then
  source /usr/share/fzf/key-bindings.bash
fi

if [[ -r /usr/share/fzf/completion.bash ]]; then
  source /usr/share/fzf/completion.bash
fi

# tmux launcher
# Send login notification via Telegram and email via msmtp
# Note: telegram_send_msg.sh is a personal script - see my telegram-scripts repo

if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
		if [ -n "$SSH_TTY" ]; then
			if command -v telegram_send_msg.sh &>/dev/null; then
				SSH_MSG="[$DATE] [ALARM] user: $USER access to ssh connection on $TTY."
				EMAIL_SUBJECT="Subject: SSH ACCESS\n\n"
				telegram_send_msg.sh "$SSH_MSG"
				echo -e "${EMAIL_SUBJECT}${SSH_MSG}" | msmtp "${ALLERT_EMAIL}"
			fi
			tmux new-session -A -s ssh_session
			exit
		else
			if command -v telegram_send_msg.sh &>/dev/null; then
				LOCAL_MSG="[$DATE] [ALARM] user: $USER access to local machine on $TTY."
				EMAIL_SUBJECT="Subject: LOCAL ACCESS\n\n"
				telegram_send_msg.sh "$LOCAL_MSG"
				echo -e "${EMAIL_SUBJECT}${LOCAL_MSG}" | msmtp "${ALLERT_EMAIL}"
			fi
			tmux new-session -A -s local_session
			exit
		fi
fi

