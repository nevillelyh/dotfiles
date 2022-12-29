FROM node:current-alpine

RUN apk add --no-cache build-base git neovim python3 vips-dev

COPY --chown=node:node nvim /home/node/.config/nvim/
COPY --chown=node:node dein.vim /home/node/.local/share/dein/repos/github.com/Shougo/dein.vim/
RUN chown -R node:node /home/node/.config /home/node/.local

USER node
WORKDIR /home/node

RUN nvim -u $HOME/.config/nvim/dein.vim --headless '+call dein#install() | qall'

ENV NPM_CONFIG_PREFIX=/home/node/.npm
RUN npm install -g joplin@2.9.1

ENV EDITOR=nvim
CMD .npm/bin/joplin
