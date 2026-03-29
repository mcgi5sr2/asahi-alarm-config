#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ── Colours ───────────────────────────────────────────────────
# Rich LS_COLORS: dirs=blue, symlinks=cyan, exec=green,
#   archives=red, images=magenta, audio=cyan, docs=green
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.zip=01;31:*.gz=01;31:*.bz2=01;31:*.xz=01;31:*.zst=01;31:*.7z=01;31:*.rar=01;31:*.deb=01;31:*.rpm=01;31:*.jpg=01;35:*.jpeg=01;35:*.png=01;35:*.gif=01;35:*.bmp=01;35:*.tif=01;35:*.tiff=01;35:*.svg=01;35:*.webp=01;35:*.avif=01;35:*.ico=01;35:*.mp4=01;35:*.mkv=01;35:*.avi=01;35:*.mov=01;35:*.webm=01;35:*.mp3=00;36:*.flac=00;36:*.ogg=00;36:*.wav=00;36:*.aac=00;36:*.opus=00;36:*.m4a=00;36:*.pdf=00;32:*.txt=00;32:*.md=00;32:*.log=00;33:*.conf=00;33:*.cfg=00;33:*.json=00;33:*.yaml=00;33:*.yml=00;33:*.toml=00;33:*.sh=01;32:*.py=01;33:*.js=01;33:*.ts=01;33:*.rs=01;33:*.go=01;33:'

# Core aliases
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -lh --color=auto --group-directories-first'
alias la='ls -lAh --color=auto --group-directories-first'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

# Use eza if installed (better ls)
if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first --color=always'
    alias ll='eza -lh --icons --group-directories-first --color=always --git'
    alias la='eza -lAh --icons --group-directories-first --color=always --git'
    alias tree='eza --tree --icons --color=always'
fi

# Use bat if installed (syntax-highlighted cat)
if command -v bat &>/dev/null; then
    alias cat='bat --style=plain'
    alias less='bat --style=full --paging=always'
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# ── Prompt ────────────────────────────────────────────────────
# green user@host, yellow dir, magenta git branch
__git_branch() {
    git branch 2>/dev/null | grep '^\*' | sed 's/\* //'
}
__prompt_git() {
    local branch
    branch=$(__git_branch)
    [[ -n "$branch" ]] && printf " \001\e[01;35m\002(\001\e[00;35m\002%s\001\e[01;35m\002)" "$branch"
}
PS1='\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;33m\]\W\[\e[00m\]$(__prompt_git)\[\e[00m\] \$ '

export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"

fastfetch
