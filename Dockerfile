FROM alpine:latest AS builder

ARG PDNS_RECURSOR_VERSION=4.4.0

RUN apk add --no-cache \
        build-base \
        boost-dev \
        lua-dev \
        openssl-dev \
    && \
    wget -O - https://downloads.powerdns.com/releases/pdns-recursor-$PDNS_RECURSOR_VERSION.tar.bz2 | tar xj && \
    cd pdns-recursor-$PDNS_RECURSOR_VERSION && \
    ./configure --enable-dns-over-tls --enable-dns-over-https && \
    make && \
    make install DESTDIR=/build


FROM alpine:latest

COPY --from=builder /build /

RUN apk add --no-cache \
        libstdc++ \
        boost-context \
        boost-filesystem \
        lua \
        openssl \
    && \
    addgroup -g 500 -S pdns-recursor && \
    adduser -u 500 -D -H -S -g pdns-recursor -s /sbin/nologin -G pdns-recursor pdns-recursor && \
    mkdir /var/run/pdns-recursor && \
    chown -R pdns-recursor:pdns-recursor /var/run/pdns-recursor

USER pdns-recursor

CMD ["/usr/local/sbin/pdns_recursor"]
