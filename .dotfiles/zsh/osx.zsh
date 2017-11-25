export PATH="/usr/local/bin:$PATH"
[[ -d /usr/local/opt/python/libexec/bin ]] && export PATH="/usr/local/opt/python/libexec/bin:$PATH"

pidof() {
    ps axc 2>/dev/null | awk "{if (\$5==\"$1\") print \$1}"
}

/usr/libexec/java_home -v 1.8 > /dev/null 2>&1 && export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
