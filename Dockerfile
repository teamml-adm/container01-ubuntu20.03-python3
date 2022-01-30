# コンテナイメージ名 : ubuntu20.04-python3
# update date: 2022/01/09
#
# OS : Ubuntu20.04
# dev langugage: Python3.8
# インストール済みライブラリ
# pip / awscli
#
FROM ubuntu:20.04
LABEL maintainer="mshinoda <shinoda@data-artist.com>"

# install basic pakces
ENV DEBIAN_FRONTEND=noninteractive
ENV DIR_PIP /home/operator/.local/bin
RUN apt-get update && apt-get upgrade -y
RUN apt-get -y install apt-utils
RUN apt-get -y install locales && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8

# coreutils for cat /meld for diff
RUN apt-get install -y coreutils vim less nkf jq zip unzip wget meld sudo git curl telnet
RUN apt-get install -y python3-ldb-dev gcc libffi-dev libcurl4-openssl-dev
RUN apt-get install -y tmux
# for pip install
RUN apt-get install -y python3-distutils python3-testresources

# setting global config
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8
ENV TZ JST-9
ENV TERM xterm

# add sudo user
RUN groupadd -g 1100 developer && \
    useradd  -g      developer -G sudo -m -s /bin/bash operator && \
    echo 'operator:operatorpass' | chpasswd
RUN echo 'Defaults visiblepw'              >> /etc/sudoers
RUN echo 'operator ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir -p /var/batch && chown operator:operator /var/batch
USER operator
WORKDIR /var/batch

# pip install
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3 get-pip.py --no-warn-script-location
# installed on /home/operator/.local/bin/pip
RUN echo 'export PATH=$PATH:/home/operator/.local/bin' >> /home/operator/.bashrc
RUN echo "alias pip='/home/operator/.local/bin/pip'"    >> /home/operator/.bashrc
RUN ${DIR_PIP}/pip install --upgrade pip
RUN ${DIR_PIP}/pip install --upgrade setuptools

# aws cli v2 のインストール
RUN cd ~/ && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && sudo ./aws/install
