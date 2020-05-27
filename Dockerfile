FROM alpine:3.11

LABEL description "Multipurpose rss reader, live stream, mashup, aggregation web application" \
      maintainer="Wonderfall <wonderfall@protonmail.com>"

ARG VERSION=2.18
ARG SHA256_HASH="0b3d46b0b25170f99e3e29c9fc6a2e5235b0449fecbdad902583c919724aa6ed"

ENV GID=991 UID=991 CRON_PERIOD=15m UPLOAD_MAX_SIZE=25M LOG_TO_STDOUT=false MEMORY_LIMIT=128M

RUN apk -U upgrade \
 && apk add -t build-dependencies \
    wget \
    git \
 && apk add \
    musl \
    nginx \
    s6 \
    su-exec \
    libwebp \
    ca-certificates \
    php7 \
    php7-fpm \
    php7-gd \
    php7-json \
    php7-zlib \
    php7-xml \
    php7-dom \
    php7-curl \
    php7-iconv \
    php7-mcrypt \
    php7-pdo_sqlite \
    php7-ctype \
    php7-session \
    php7-mbstring \
    php7-simplexml \
    php7-xml \
    php7-xmlwriter \
 && wget -q https://github.com/SSilence/selfoss/releases/download/$VERSION/selfoss-$VERSION.zip -P /tmp \
 && CHECKSUM=$(sha256sum /tmp/selfoss-$VERSION.zip | awk '{print $1}') \
 && if [ "${CHECKSUM}" != "${SHA256_HASH}" ]; then echo "Warning! Checksum does not match!" && exit 1; fi \
 && mkdir /selfoss && unzip -q /tmp/selfoss-$VERSION.zip -d /selfoss \
 && sed -i -e 's/base_url=/base_url=\//g' /selfoss/defaults.ini \
 && apk del build-dependencies \
 && rm -rf /var/cache/apk/* /tmp/*

COPY rootfs /
RUN chmod +x /usr/local/bin/run.sh /services/*/run /services/.s6-svscan/*
VOLUME /selfoss/data
EXPOSE 8888
CMD ["run.sh"]
