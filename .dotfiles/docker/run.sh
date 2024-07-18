#!/bin/bash

docker build --tag dotfiles .

dir="$(git rev-parse --show-toplevel)"
docker run -it --rm \
    --volume "$dir":/home/neville/dotfiles \
    --volume "$HOME/.ssh/private":/home/neville/.ssh/private \
    --cap-add SYS_ADMIN \
    dotfiles \
    bash -x dotfiles/.dotfiles/files/bootstrap.sh
