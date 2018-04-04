FROM c0mpiler/alpine-base:latest

MAINTAINER Harsha Krishnareddy <c0mpiler@outlook.com>

ENV LANG=C.UTF-8
USER root

ARG REQUIRE="sudo build-base"
RUN apk update && apk upgrade \
      && apk add --no-cache ${REQUIRE}

RUN apk update && apk upgrade
RUN apk add --no-cache \
			autoconf \
			automake \
			libtool \
      gsl \
      zlib \
      dpkg \
      gsl \
      gsl-dev \
      boost-dev \
      gcc \
      g++ \
      git \
      zlib \
      zlib-dev

#############################################################################
# Installing CapNProto
  RUN mkdir -p /tmp/build \
    && git clone https://github.com/sandstorm-io/capnproto.git \
    && cd capnproto/c++ \
    && autoreconf -i \
    && ./configure \
    && make -j6 check \
    && sudo make install

#############################################################################
# Install CA certificates
RUN apk add --update ca-certificates && rm -rf /var/cache/apk/*

#############################################################################
# Add boost dependencies
RUN apk add --update build-base boost linux-headers bzip2-dev python python-dev &&\
    rm -rf /var/cache/apk/*
#############################################################################

RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.27-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    wget \
        "https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub" \
        -O "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"
#############################################################################

RUN cd /tmp/build &&\
    wget "https://github.com/marbl/Mash/releases/download/v2.0/mash-Linux64-v2.0.tar" && \
    tar xf mash-Linux64-v2.0.tar && \
    cd mash-Linux64-v2.0 && \
    mv ./mash /usr/bin && \
    rm -rf /tmp/build/mash-Linux64-v2.0

RUN mash
#############################################################################

CMD ["/bin/ash"]
