# vim: ft=zsh:

autoload -U colors && colors
autoload -Uz vcs_info

dot="•"
zstyle ':vcs_info:*' stagedstr "%{$fg_bold[green]%}${dot}"
zstyle ':vcs_info:*' unstagedstr "%{$fg_bold[yellow]%}${dot}"
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat "%b%{$fg_bold[1]%}:%{$fg_bold[11]%}%r"
zstyle ':vcs_info:*' enable git

rprompt_pwd() {
    RPROMPT="%{$fg_bold[cyan]%}%~%{$reset_color%}"
}

rprompt_vcs() {
    local prefix="%{$fg_bold[cyan]%}%r:%S %{$fg_bold[blue]%}["
    local postfix="%{$fg_bold[blue]%}]%{$reset_color%}"
    local action="%{$fg_bold[magenta]%}%a"
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
        local branch="%b%c%u"
    else
        local branch="%b%c%u%{$fg_bold[red]%}${dot}"
    fi
    numstash=$(git stash list | wc -l)
    if [[ ${numstash} -gt 0 ]]; then
        local stash="%{$fg_bold[magenta]%}@{${numstash}}"
    else
        local stash=""
    fi
    zstyle ':vcs_info:*' formats "${prefix}${branch}${stash}${postfix}"
    zstyle ':vcs_info:*' actionformats "${prefix}${branch} ${action}${stash}${postfix}"
    vcs_info

    RPROMPT="${vcs_info_msg_0_}"
}

precmd() {
    local url=$(git config --get remote.origin.url 2> /dev/null)
    if [[ -z ${url} ]] || [[ ${url} =~ '.*[:/]dotfiles\.git$' ]]; then
        rprompt_pwd
    else
        rprompt_vcs
    fi
}

local mcolor="%{$fg_bold[cyan]%}"

setopt prompt_subst
PROMPT="%{$fg_bold[green]%}%n${mcolor}@%m %{$fg_bold[blue]%}%. $%{$reset_color%} "
