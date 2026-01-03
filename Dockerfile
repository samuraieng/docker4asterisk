# Copyright (c) 2026 Samuraieng
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ubuntu:24.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive TZ=Asia/Tokyo apt-get install -y tzdata && \
    apt-get upgrade -y

RUN apt-get install -y \
    autoconf \
    ca-certificates \
    curl \
    build-essential \
    git \
    gpg \
    iproute2 \
    iputils-ping \
    libedit-dev \
    libjansson-dev \
    libncurses5-dev \
    libnewt-dev \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libxml2-dev \
    net-tools \
    sudo \
    vim \
    wget

RUN set +e; \
    groupadd -g 1000 ubuntu; \
    useradd -m -u 1000 -g ubuntu -s /bin/bash ubuntu; \
    mkdir /home/ubuntu; \
    set -e

RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo "ubuntu:ubuntu|chpasswd"
RUN mkdir /home/ubuntu/sandbox

WORKDIR /home/ubuntu/sandbox

RUN git clone -b 16.3 https://github.com/asterisk/asterisk.git && \
    cd asterisk && \
    ./configure --with-jansson-bundled && \
    make && \
    make install && \
    cd ..

RUN wget http://download-mirror.savannah.gnu.org/releases/linphone/plugins/sources/bcg729-1.0.2.tar.gz && \
    tar zxvf bcg729-1.0.2.tar.gz && \
    cd bcg729-1.0.2 && \
    ./configure && \
    make && \
    make install && \
    ldconfig && \
    cd ..

RUN wget http://asterisk.hosting.lv/src/asterisk-g72x-1.4.3.tar.bz2 && \
    bunzip2 -c asterisk-g72x-1.4.3.tar.bz2 | tar xvf - && \
    cd asterisk-g72x-1.4.3 && \
    ./autogen.sh  && \
    ./configure --with-bcg729 --with-asterisk-includes=../asterisk/include && \
    make && \
    make install && \
    cd ..

COPY etc-asterisk.tar.gz /tmp/etc-asterisk.tar.gz
RUN tar xzf /tmp/etc-asterisk.tar.gz -C /

RUN cd asterisk && \
    make config

CMD ["asterisk","-f"]

