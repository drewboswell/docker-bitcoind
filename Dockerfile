FROM ubuntu:bionic
MAINTAINER Andrew Boswell <@drewboswell>

ARG USER_ID
ARG GROUP_ID

ENV HOME /bitcoin
ENV BITCOIN_VERSION=0.16.0

# Add user/group or default
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

# add group, user, default shell, user home
RUN groupadd -g ${GROUP_ID} bitcoin \
    && useradd -u ${USER_ID} -g bitcoin -s /bin/bash -m -d /bitcoin bitcoin

# install general dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    gnupg \
    ca-certificates \
    wget \
    gosu

# add bitcoin official apt repository
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C70EF1F0305A1ADB9986DBD8D46F45428842CE5E \
    && echo "deb http://ppa.launchpad.net/bitcoin/bitcoin/ubuntu bionic main" > /etc/apt/sources.list.d/bitcoin.list

RUN apt-get update \
    && apt-get install -y --no-install-recommends bitcoind \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# clean up unneeded cache, install apt packages etc
RUN apt-get purge -y gnupg ca-certificates wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./bin /usr/local/bin

VOLUME /bitcoin

EXPOSE 8332 8333 18332 18333

WORKDIR /bitcoin

COPY docker_entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker_entrypoint.sh"]

CMD ["btc_oneshot"]