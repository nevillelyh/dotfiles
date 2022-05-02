FROM ubuntu:jammy
ENV NPM_CONFIG_PREFIX=/joplin

COPY dein.vim /root/.local/share/dein/repos/github.com/Shougo/dein.vim/
COPY nvim /root/.config/nvim/

RUN apt-get update && apt-get install -y neovim nodejs npm && rm -rf /var/lib/apt/lists/*
RUN nvim -u $HOME/.config/nvim/dein.vim --headless '+call dein#install() | qall'
RUN cd /root && npm install -g joplin@2.6.2

CMD ["/joplin/bin/joplin"]
