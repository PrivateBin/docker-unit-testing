FROM alpine:3.18

LABEL maintainer="support@privatebin.org"

RUN \
# Install dependencies
    apk add --no-cache composer php81 php81-json php81-gd php81-opcache \
        php81-pdo_sqlite php81-mbstring php81-dom php81-xml php81-xmlwriter \
        php81-tokenizer php81-fileinfo nodejs npm mailcap \
# Install npm modules
    && npm install -g mocha jsverify jsdom@9 jsdom-global@2 mime-types @peculiar/webcrypto jsdom-url fake-indexeddb \
    && wget -qO- https://gobinaries.com/tj/node-prune | sh \
    && cd /usr/local \
    && node-prune lib/node_modules \
# Install composer modules
    && composer require phpunit/phpunit:^9 google/cloud-storage:1.32.0 \
# cleanup to reduce the already large image size
    && apk del --no-cache composer npm \
    && rm -rf /bin/.cache \
        /etc/mailcap \
        /root/.??* \
        /tmp/* \
        /usr/lib/node_modules/npm \
        /usr/local/bin/node-prune \
        /usr/local/composer.* \
        /var/log/*

# mark dirs as volumes that need to be writable, allows running the container --read-only
VOLUME /srv /tmp

COPY unit-test.sh /usr/local/bin/

WORKDIR /usr/local/bin

USER nobody

ENTRYPOINT ["unit-test.sh"]
