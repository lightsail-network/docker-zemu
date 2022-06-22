#*******************************************************************************
#    (c) 2020-2022 Zondax GmbH
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#*******************************************************************************
#Download base ubuntu image
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN apt-get update && \
    apt-get -y install build-essential git wget sudo udev zip \
                       curl cmake software-properties-common \
                       python3 python3-pip python-is-python3 \
                       libudev-dev libusb-1.0-0-dev

# Speculos dependencies
RUN apt-get update && \
    apt-get -y install qemu-user-static python3-construct \
                       python3-mnemonic python3-pyelftools gcc-arm-linux-gnueabihf \
                       libc6-dev-armhf-cross gdb-multiarch

RUN pip3 install -U setuptools ledgerblue jsonschema pyelftools mnemonic construct flask flask-restful pillow requests

# Create zondax user
RUN adduser --disabled-password --gecos "" -u 1000 zondax
RUN echo "zondax ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /home/zondax

####################################
####################################
USER zondax

# Speculos
RUN git clone https://github.com/LedgerHQ/speculos --depth 1

RUN cd /home/zondax/speculos && cmake -Bbuild -H. -DWITH_VNC=0
RUN make -C /home/zondax/speculos/build/

# Patch proxy to connect to all interfaces
RUN sed -i "s/HOST = '127.0.0.1'/HOST = '0.0.0.0'/g" speculos/tools/ledger-live-http-proxy.py

# Open TCP ports
# gdb
EXPOSE 1234/tcp
EXPOSE 1234/udp
# device keyboard
EXPOSE 1235/tcp
EXPOSE 1235/udp
# APDU RAW
EXPOSE 9999/tcp
EXPOSE 9999/udp
# HTTP APDU PROXY
EXPOSE 9998/tcp
EXPOSE 9998/udp
# RFB
EXPOSE 8001/tcp
EXPOSE 8001/udp
# API Speculos
EXPOSE 5000/tcp
EXPOSE 5000/udp

# ENV
ADD entrypoint.sh /home/zondax/entrypoint.sh

# START SCRIPT
ENTRYPOINT ["/home/zondax/entrypoint.sh"]
