FROM debian:buster-slim

# Referenced Dockerfile here: https://github.com/roshii/docker-joinmarket/blob/master/Dockerfile

LABEL maintainer="David Parrish <daveparrish@tutanota.com>"

# Ubuntu dependencies
# hadolint ignore=DL3008,DL3013
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates wget gpg dirmngr gpg-agent gosu \
     curl python3-dev python3-pip build-essential automake pkg-config libtool libgmp-dev \
     libltdl-dev libssl-dev python3-pip python3-setuptools python3-nacl \
  && pip3 install wheel \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /jm

# Source code from git
# hadolint ignore=DL3008,DL3003
RUN apt-get update \
  && apt-get install -y --no-install-recommends git \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && git clone https://github.com/JoinMarket-Org/joinmarket-clientserver.git /jm/clientserver \
  && cd /jm/clientserver \
  && git checkout master

# Python dependencies
WORKDIR /jm/clientserver
RUN pip3 install -r requirements/base.txt

# add user and group with default ids
RUN groupadd joinmarket \
  && useradd -g joinmarket -s /bin/bash -m joinmarket
WORKDIR /home/joinmarket
COPY entrypoint.sh /usr/local/bin/

ENTRYPOINT ["entrypoint.sh"]
