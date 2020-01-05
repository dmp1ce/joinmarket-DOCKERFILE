FROM debian:buster-slim

# Referenced Dockerfile here: https://github.com/roshii/docker-joinmarket/blob/master/Dockerfile

LABEL maintainer="David Parrish <daveparrish@tutanota.com>"

ENV JM_VERSION 0.6.1
ENV JM_URL https://github.com/JoinMarket-Org/joinmarket-clientserver/archive/v$JM_VERSION.tar.gz
ENV JM_ASC_URL https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/download/v$JM_VERSION/joinmarket-clientserver-$JM_VERSION.tar.gz.asc
ENV JM_PGP_KEY 2B6FC204D9BF332D062B461A141001A1AF77F20B

#RUN pwd && apt-get update && \
#  apt-get install -y --no-install-recommends git=1:2.20.1-2+deb10u1 && \
#  apt-get clean && \
#  rm -rf /var/lib/apt/lists/* && \
#  git clone https://github.com/JoinMarket-Org/joinmarket-clientserver.git && \
#  git checkout v"$JM_VERSION"

# JM dependencies
# hadolint ignore=DL3008
RUN pwd && apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates wget gpg dirmngr gpg-agent gosu virtualenv \
     python-virtualenv curl python3-dev python3-pip build-essential automake pkg-config libtool libgmp-dev \
     libltdl-dev libssl-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# add user and group with default ids
RUN groupadd joinmarket \
  && useradd -g joinmarket -s /bin/bash -m -d /jm joinmarket

WORKDIR /tmp
RUN set -ex \
  && wget -qO jm.tar.gz "$JM_URL" \
  && gpg --keyserver keyserver.ubuntu.com --recv-keys "$JM_PGP_KEY" \
  && wget -qO jm.asc "$JM_ASC_URL" \
  && gpg --verify jm.asc jm.tar.gz \
  && mkdir -p /jm/clientserver \
  && tar -xzvf jm.tar.gz -C /jm/clientserver --strip-components=1 \
  && rm -rf /tmp/*

WORKDIR /jm/clientserver
RUN ./install.sh && chown -R joinmarket /jm/clientserver
COPY entrypoint.sh /usr/local/bin/

ENTRYPOINT ["entrypoint.sh"]
