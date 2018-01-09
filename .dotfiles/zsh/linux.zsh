[[ -d /usr/lib/jvm/java-8-oracle ]] && export JAVA_HOME=/usr/lib/jvm/java-8-oracle

for pkg in $(find /opt -maxdepth 2 -name latest -type l); do
    [[ -d "${pkg}/bin" ]] && export PATH="${pkg}/bin:$PATH"
done

[[ -f /usr/bin/xdg-open ]] && alias open='xdg-open'
[[ -f /usr/bin/ack-grep ]] && alias ack='ack-grep'
