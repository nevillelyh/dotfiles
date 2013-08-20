# Python
if [ -d /usr/local/share/python ]; then
    local PATH=$(echo ${PATH} | sed -e 's/\/usr\/local\/bin://')
    export PATH="/usr/local/bin:/usr/local/share/python:${PATH}"
fi

pidof() {
    ps axc 2>/dev/null | awk "{if (\$5==\"$1\") print \$1}"
}

export JAVA_HOME=$(/usr/libexec/java_home -v 1.7)

# vim: ft=zsh:
