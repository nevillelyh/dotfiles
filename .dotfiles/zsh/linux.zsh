for pkg in $(find /opt -maxdepth 2 -name latest -type l); do
    [[ -d "${pkg}/bin" ]] && export PATH="${pkg}/bin:$PATH"
done
