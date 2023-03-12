FROM debian:bullseye-slim

LABEL maintainer="David Parrish <daveparrish@tutanota.com>"

# Install known dependencies from apt and pip
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates=2021* wget=1.21* \
     gosu=1.12* curl=7.* python3-dev=3.9* python3-pip=20.* build-essential=12.* automake=1:1.16* \
     pkg-config=0.29* python3-setuptools=52.0.* git=1:2.30.* libtool=2.4.* \
     libgmp-dev=2:6.2.* libltdl-dev=2.4.* zlib1g-dev=1:1.2.* libjpeg-dev=1:2.0.* \
     libblas-dev=3.9.* liblapack-dev=3.9.* gfortran=4:10.2.* gpg=2.2.* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /jm \
  && echo "Install dependencies for ob-watcher" \
  && pip3 install --no-cache-dir 'wheel>=0.37.1' \
  && echo "Add dependency for ob-watcher" \
  && pip3 install --no-cache-dir 'matplotlib>=3.5.1' \
  && echo "Install scipy for history command. Predict accumulation rate." \
  && pip3 install --no-cache-dir 'scipy>=1.8.0' \
  && echo "Install source code from git" \
  && git clone https://github.com/JoinMarket-Org/joinmarket-clientserver.git /jm/clientserver

# Install JoinMarket and base requirements
# Add user and group
WORKDIR /jm/clientserver
RUN apt update \
 && ./install.sh --docker-install \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && echo "add user and group with default ids" \
 && groupadd joinmarket \
 && useradd -g joinmarket -s /bin/bash -m joinmarket

WORKDIR /home/joinmarket
COPY entrypoint.sh /usr/local/bin/

ENTRYPOINT ["entrypoint.sh"]
