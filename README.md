# Dotfiles

My personal (and very easy) dotfiles :)

## Contents 

- **.bashrc** - Bash config
- **.bash_profile** - Bash profile
- **.bash_logout** - Bash logout
- **.vimrc** - Vim config
- **.vim/startscreen.vim** - Vim startup screen plugin
- **.tmux.conf** - Tmux config
- **.tmux/status.sh** - Tmux status bar script
- **.fzf/env.sh** - fzf/fd/ripgrep config and helper functions
- **.gitconfig** - Git config

## Dipendences 

| Tool | Usage |
|------|-----|
| `stow` | Dotfiles manager |
| `jq` | Parsing JSON in .tmux/status.sh |
| `thefuck` | Shell commands correction |
| `pwgen` | Generation password (alias `passgen`) |
| `msmtp` | Email notifications on login/logout |
| `tmux` | Terminal multiplexer |
| `vim-plug` | Plugin manager for vim |
| `coc.nvim` | vim autocompletion (needs Node.js) |
| `telegram_send_msg.sh` | Telegram notifications on login/logout (personal script) |
| `fzf` | Fuzzy finder |
| `fd` / `fdfind` | Fast file finder (used by fzf helpers) |
| `bat` / `batcat` | File previewer for fzf |
| `ripgrep` (`rg`) | Fast search tool (used by frg/frgf helpers) |

## Installation

```bash
git clone https://github.com/dennisfrati/dotfiles.git ~/dotfiles
cd ~
stow dotfiles
```

### Uninstall:

```bash
cd ~
stow -D dotfiles
```

### Install vim-plug:

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Then open Vim and run `:PlugInstall`.

### Vim plugins included:

| Plugin | Description |
|--------|-------------|
| `coc.nvim` | Intellisense engine with LSP support (requires Node.js) |

### Vim startup screen:

The `.vim/startscreen.vim` plugin shows a custom start page when Vim is launched without a file:

- Displays system info (OS, date)
- Lists the 20 most recent files
- Press `j`/`k` to navigate, `Enter` to open, `q` to quit

### fzf functions

`.fzf/env.sh` provides shell functions for fuzzy searching. Requires `fzf`.

| Function | Description |
|----------|-------------|
| `ff` | Fuzzy-find a file and open it in `$EDITOR` |
| `ffm` | Fuzzy-find multiple files and open them all in `$EDITOR` |
| `fcd` | Fuzzy cd into a directory |
| `ftree` | Fuzzy file selection with tree preview (requires `tree`) |
| `fh` | Fuzzy search shell history and print the selected command |
| `frg` | Fuzzy-select a ripgrep result and jump to that line in `$EDITOR` |
| `frgf` | Fuzzy-select a file from ripgrep file list and open in `$EDITOR` |
| `fkill` | Fuzzy-select a process and kill it |
| `fgb` | Fuzzy-select a git branch and checkout |
| `fgt` | Fuzzy-select a git tag and show it |
| `fgc` | Fuzzy-select a git commit and show it |
| `fsys` | Fuzzy-select a systemd service and show its status |
| `fjournal` | Fuzzy-select a systemd service and follow its journal |
| `fdc_logs` | Fuzzy-select a running Docker container and follow its logs |
| `fdc_shell` | Fuzzy-select a running Docker container and open a shell inside |
| `fssh` | Fuzzy-select a host from `~/.ssh/config` and connect via ssh |
| `fkc` | Fuzzy-select a kubectl context and switch to it |
| `fkp_logs` | Fuzzy-select a Kubernetes pod and follow its logs |
