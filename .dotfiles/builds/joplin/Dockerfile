FROM node:current-alpine

ARG VERSION=2.13.2
RUN if [[ "$(uname -m)" == aarch64 ]]; then \
        apk add --no-cache --virtual .deps build-base python3 && \
        apk add vips-dev; \
    fi && \
    npm install -g joplin@$VERSION && \
    if [[ "$(uname -m)" == aarch64 ]]; then apk del .deps; fi

RUN apk add --no-cache git neovim
COPY nvim /home/node/.config/nvim/
COPY dein.vim /home/node/.local/share/dein/repos/github.com/Shougo/dein.vim/
RUN chown -R node:node /home/node/.config /home/node/.local

USER node
WORKDIR /home/node

RUN nvim -u $HOME/.config/nvim/dein.vim --headless '+call dein#install() | qall'

ENV EDITOR=nvim
ENTRYPOINT ["joplin"]
