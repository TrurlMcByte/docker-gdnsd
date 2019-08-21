FROM alpine:latest

ENV VERSION=3.2.1

RUN \
    addgroup -S gdnsd \
    && adduser -D -S -h /var/run/gdnsd -s /sbin/nologin -G gdnsd gdnsd \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        bison \
        curl \
        file \
        flex \
        gawk \
        gcc \
        geoip-dev \
        git \
        gnupg \
        libc-dev \
        libev-dev \
        libmaxminddb-dev \
        libsodium-dev \
        libtool \
        make \
        openssl-dev \
        patch \
        pcre-dev \
        perl \
        perl-test-pod-doc \
        ragel \
        userspace-rcu-dev \
        zlib-dev \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && curl -sSL https://github.com/gdnsd/gdnsd/releases/download/v${VERSION}/gdnsd-${VERSION}.tar.xz | tar -xJ \
    && cd gdnsd-$VERSION \
#    && sed -i 's/1546300799LLU/1830775403LLU/' libgdmaps/gdgeoip2.c \
    && autoreconf -vif \
    && ./configure \
    && make all install \
    && strip /usr/local/sbin/gdnsd \
    && runDeps="$( \
        scanelf --needed --nobanner --recursive /usr/local \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache --virtual .rundeps $runDeps \
    && apk del .build-deps \
    && rm -rf /usr/src/*

ADD entrypoint.sh /entrypoint.sh
ADD maxminddb.conf /etc/conf.d/libmaxminddb
EXPOSE 53 53/udp 3506
ENTRYPOINT ["/entrypoint.sh"]
#CMD ["/usr/local/sbin/gdnsd", "-fx", "start"]
