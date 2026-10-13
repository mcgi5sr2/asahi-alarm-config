# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
unsetopt BEEP
unsetopt CORRECT
unsetopt CORRECT_ALL
unset -f command_not_found_handler 2>/dev/null
fastfetch --config $HOME/.config/fastfetch/config.jsonc

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Shell basics (replaces the CachyOS zsh config package) ─────
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
setopt AUTO_CD INTERACTIVE_COMMENTS
bindkey -e
bindkey '^[[H' beginning-of-line '^[[F' end-of-line '^[[3~' delete-char
bindkey '^[[1;5C' forward-word '^[[1;5D' backward-word
bindkey '^[[A' history-beginning-search-backward '^[[B' history-beginning-search-forward

autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
eval "$(dircolors -b)"
export LESS='-R'
export MANPAGER="sh -c 'col -bx | batcat -l man -p'"

# ── Prompt + plugins ──────────────────────────────────────────
[[ -r ~/.local/share/powerlevel10k/powerlevel10k.zsh-theme ]] && source ~/.local/share/powerlevel10k/powerlevel10k.zsh-theme
[[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# ── Aliases ───────────────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza --icons --group-directories-first -l --git'
alias la='eza --icons --group-directories-first -la --git'
alias lt='eza --icons --tree --level=2'
alias cat='bat --style=plain'
alias grep='grep --color=auto'

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export KUBECONFIG=~/.kube/configs/img-amrc.kubeconfig.yaml

# Created by `pipx` on 2026-05-18 12:37:39
export PATH="$PATH:/home/me1sgr/.local/bin"


# Added by Antigravity CLI installer
export PATH="/home/me1sgr/.local/bin:$PATH"

# Must stay last
[[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
