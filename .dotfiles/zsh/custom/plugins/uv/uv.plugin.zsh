# Ported from python.plugin.zsh

[[ -n ${VIRTUAL_ENV:-} ]] && return

UV_VENV_NAME=.venv
PIP_PKGS=(ipython flake8 mypy)

function auto_venv() {
    # deactivate function exists and not inside $VIRTUAL_ENV/..
    if (( $+functions[deactivate] )) && [[ $PWD != ${VIRTUAL_ENV:h}* ]]; then
        deactivate > /dev/null 2>&1
    fi

    # $PWD is not $VIRTUAL_ENV/..
    if [[ $PWD != ${VIRTUAL_ENV:h} ]]; then
        for _file in "$UV_VENV_NAME"/bin/activate(N.); do
            # deactivate first if function exists
            (( $+functions[deactivate] )) && deactivate > /dev/null 2>&1
            source $_file > /dev/null 2>&1
            break
        done
    fi
}

function mkvenv() {
    out=$(uv venv --color always --seed "$@" 2>&1)
    echo "$out" >&2
    activate="$(echo "$out" | grep -o 'source .*/bin/activate' | sed 's/^source //')"
    source "$activate"
    uv pip install "${PIP_PKGS[@]}"
    if [[ -f requirements.txt ]]; then
        read -q "REPLY?Install packages in requirements.txt? (y/N) "
        echo
        [[ $REPLY == "y" ]] && uv pip install --requirement requirements.txt
    fi
}

add-zsh-hook chpwd auto_venv
auto_venv

alias pip='uv pip'
alias pip3='uv pip'

function python() {
    if ! which -p python &> /dev/null; then
        /usr/bin/env python3 "$@"
    else
        $(which -p python) "$@"
    fi
}
