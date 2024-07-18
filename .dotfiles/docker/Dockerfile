FROM ubuntu:noble

RUN apt-get update
RUN apt-get install -y curl git lsb-release openssh-client sudo wget
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
RUN useradd -m -s /bin/bash neville
RUN usermod -aG sudo neville
RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN sed -i "s/^\(auth \+\)required\( \+pam_shells.so\)/\1sufficient\2/" /etc/pam.d/chsh

USER neville
RUN mkdir /home/neville/.ssh
RUN echo "Host *" >> /home/neville/.ssh/config
RUN echo "    StrictHostKeyChecking no" >> /home/neville/.ssh/config

WORKDIR /home/neville
