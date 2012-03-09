autoload -U colors && colors
autoload -Uz vcs_info

zstyle ':vcs_info:*' stagedstr "%{$fg_bold[green]%}⚫"
zstyle ':vcs_info:*' unstagedstr "%{$fg_bold[yellow]%}⚫"
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat "%b%{$fg_bold[1]%}:%{$fg_bold[11]%}%r"
zstyle ':vcs_info:*' enable git svn

rprompt_pwd() {
    RPROMPT="%{$fg_bold[cyan]%}%~%{$reset_color%}"
}

rprompt_vcs() {
    local prefix="%{$fg_bold[cyan]%}%r:%S %{$fg_bold[green]%}["
    local postfix="%{$fg_bold[green]%}]%{$reset_color%}"
    local action="%{$fg_bold[magenta]%}%a"
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
        local branch="%b%c%u"
    } else {
        local branch="%b%c%u%{$fg_bold[red]%}⚫"
    }
    zstyle ':vcs_info:*' formats "${prefix}${branch}${postfix}"
    zstyle ':vcs_info:*' actionformats "${prefix}${branch} ${action}${postfix}"
    vcs_info

    RPROMPT="${vcs_info_msg_0_}"
}

precmd() {
    local url=$(git config --get remote.origin.url 2> /dev/null)
    if [[ -z ${url} ]] || [[ ${url} =~ '.*[:/]dotfiles\.git$' ]] || [[ ${url} =~ '.*[:/]homebrew\.git$' ]] {
        rprompt_pwd
    } else {
        rprompt_vcs
    }
}

local mcolor="%{$fg_bold[cyan]%}"
[[ "$(hostname)" =~ '.*\.local$' ]] && mcolor="%{$fg_bold[green]%}"
[[ "$(hostname)" =~ '.*\.spotify\.net$' ]] && mcolor="%{$fg_bold[red]%}"
[[ "$(hostname)" =~ '.*\.d\.spotify\.net$' ]] && mcolor="%{$fg_bold[magenta]%}"
[[ "$(hostname)" =~ '.*\.office\.spotify\.net$' ]] && mcolor="%{$fg_bold[green]%}"

setopt prompt_subst
PROMPT="%{$fg_bold[green]%}%n${mcolor}@%m %{$fg_bold[blue]%}%. $%{$reset_color%} "

# vim: ft=zsh:
