FROM debian:buster-slim

# Referenced Dockerfile here: https://github.com/roshii/docker-joinmarket/blob/master/Dockerfile

LABEL maintainer="David Parrish <daveparrish@tutanota.com>"

# Install known dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates=* wget=* gpg=* \
     dirmngr=* gpg-agent=* gosu=* curl=* python3-dev=* python3-pip=* \
     build-essential=* automake=* pkg-config=* libtool=* libgmp-dev=* \
     libltdl-dev=* libssl-dev=* python3-pip=* python3-setuptools=* \
     python3-nacl=* libsecp256k1-dev=* git=* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /jm \
  && echo "Install dependencies for ob-watcher" \
  && pip3 install 'wheel>=0.35.1' \
  && pip3 install 'matplotlib>=3.3.1' \
  && ecno "Install scipy for history command. Predict accumulation rate." \
  && pip3 install 'scipy>=1.5.2' \
  && echo "Install source code from git" \
  && git clone https://github.com/JoinMarket-Org/joinmarket-clientserver.git /jm/clientserver

# Install source code and base requirements
# Add user and group
WORKDIR /jm/clientserver
RUN git checkout master && pip3 install -r requirements/base.txt \
 && echo "add user and group with default ids" \
 && groupadd joinmarket \
 && useradd -g joinmarket -s /bin/bash -m joinmarket

WORKDIR /home/joinmarket
COPY entrypoint.sh /usr/local/bin/

# Patch yield generator scripts
COPY yg-env.patch /tmp/yg-env.patch
RUN git -C /jm/clientserver apply /tmp/yg-env.patch

ENTRYPOINT ["entrypoint.sh"]
