FROM ubuntu:jammy

RUN apt-get update && apt-get install -y curl git gnupg make pkg-config
COPY neovim-ppa-ubuntu-stable-jammy.list /etc/apt/sources.list.d/
RUN curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x9dbb0be9366964f134855e2255f96fcf8231b6dd" \
    | gpg --dearmor > /etc/apt/trusted.gpg.d/neovim-ppa-ubuntu-stable-jammy.gpg
RUN curl -fsSL https://deb.nodesource.com/setup_19.x | bash -
RUN apt-get install -y neovim nodejs
RUN rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash joplin
COPY --chown=joplin:joplin nvim /home/joplin/.config/nvim/
COPY --chown=joplin:joplin dein.vim /home/joplin/.local/share/dein/repos/github.com/Shougo/dein.vim/
RUN chown -R joplin:joplin /home/joplin/.config /home/joplin/.local

USER joplin
WORKDIR /home/joplin

RUN nvim -u $HOME/.config/nvim/dein.vim --headless '+call dein#install() | qall'

ENV NPM_CONFIG_PREFIX=/home/joplin/.npm
RUN npm install -g joplin@2.9.1

ENV EDITOR=nvim
CMD .npm/bin/joplin
