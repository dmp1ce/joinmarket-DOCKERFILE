FROM debian:buster-slim

LABEL maintainer="David Parrish <daveparrish@tutanota.com>"

# Install known dependencies from apt and pip
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates=20190110 wget=1.20* \
     gosu=1.10* curl=* python3-dev=3.7* python3-pip=18* build-essential=12* automake=1:1.16* \
     pkg-config=0.29* python3-setuptools=40.8* git=1:2.20* libtool=2.4* \
     libgmp-dev=2:6.1* libltdl-dev=2.4* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /jm \
  && echo "Install dependencies for ob-watcher" \
  && pip3 install 'wheel>=0.35.1' \
  && echo "Add dependency for ob-watcher" \
  && pip3 install 'matplotlib>=3.3.1' \
  && echo "Install scipy for history command. Predict accumulation rate." \
  && pip3 install 'scipy>=1.5.2' \
  && echo "Install source code from git" \
  && git clone https://github.com/JoinMarket-Org/joinmarket-clientserver.git /jm/clientserver

# Install JoinMarket and base requirements
# Add user and group
WORKDIR /jm/clientserver
RUN echo "Get Docker install PR" \
 && git fetch origin pull/669/head:docker-install \
 && git checkout docker-install && ./install.sh --docker-install \
 && echo "add user and group with default ids" \
 && groupadd joinmarket \
 && useradd -g joinmarket -s /bin/bash -m joinmarket

WORKDIR /home/joinmarket
COPY entrypoint.sh /usr/local/bin/

# Patch yield generator scripts
COPY yg-env.patch /tmp/yg-env.patch
RUN git -C /jm/clientserver apply /tmp/yg-env.patch

ENTRYPOINT ["entrypoint.sh"]
