FROM debian

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y sudo git wget curl gcc g++ autoconf automake libtool \
                       gperf bison flex texinfo bzip2 xz-utils help2man gawk \
                       make libncurses5-dev python python-dev python3 \
                       python3-dev htop

RUN useradd imrc -m -b /home
RUN echo 'imrc:imrc' | chpasswd
RUN echo 'imrc ALL = NOPASSWD : ALL' >>/etc/sudoers.d/imrc

USER imrc
ENV HOME /home/imrc
RUN mkdir -p "$HOME/.local/src"
RUN sudo chown imrc:imrc -R $HOME

WORKDIR $HOME/.local/src
RUN git clone --depth=1 https://github.com/crosstool-ng/crosstool-ng
WORKDIR crosstool-ng
RUN autoreconf -i -m
RUN ./configure --prefix="$HOME/.local"
RUN maintainer/gen-kconfig.sh
RUN make
RUN make install

RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.bashrc"
ENV PATH "$HOME/.local/bin:$PATH"

WORKDIR $HOME/ct-ng/armv6-rpi-linux-gnueabi
RUN sudo chown imrc:imrc .
RUN ct-ng armv6-rpi-linux-gnueabi
RUN ct-ng build

WORKDIR $HOME/ct-ng/armv7-rpi2-linux-gnueabihf
RUN sudo chown imrc:imrc .
RUN ct-ng armv7-rpi2-linux-gnueabihf
RUN ct-ng build

WORKDIR $HOME/ct-ng/armv8-rpi3-linux-gnueabihf
RUN sudo chown imrc:imrc .
RUN ct-ng armv8-rpi3-linux-gnueabihf
RUN ct-ng build

RUN echo 'export PATH="$HOME/x-tools/armv6-rpi-linux-gnueabi/bin:$PATH"' >>"$HOME/.bashrc"
RUN echo 'export PATH="$HOME/x-tools/armv7-rpi2-linux-gnueabihf/bin:$PATH"' >>"$HOME/.bashrc"
RUN echo 'export PATH="$HOME/x-tools/armv8-rpi3-linux-gnueabihf/bin:$PATH"' >>"$HOME/.bashrc"

WORKDIR $HOME
RUN sudo rm -rf ct-ng/

CMD /bin/bash
