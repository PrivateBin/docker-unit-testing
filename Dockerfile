FROM alpine:3.14

LABEL maintainer="support@privatebin.org"

RUN \
# Install dependencies
    apk add --no-cache composer php7 php7-json php7-gd php7-opcache \
        php7-pdo_sqlite php7-mbstring php7-dom php7-xml php7-xmlwriter \
        php7-tokenizer php7-fileinfo nodejs npm mailcap \
# Install npm modules
    && npm config set unsafe-perm=true \
    && npm install -g mocha jsverify jsdom@9 jsdom-global@2 mime-types @peculiar/webcrypto jsdom-url fake-indexeddb \
    && wget -qO- https://install.goreleaser.com/github.com/tj/node-prune.sh | sh \
    && node-prune /usr/local/lib/node_modules \
# Install composer modules
    && cd /usr/local \
    && composer require phpunit/phpunit:^5.0 google/cloud-storage:1.23.1 \
# cleanup to reduce the already large image size
    && apk del --no-cache composer npm \
    && rm -rf /bin/.cache \
        /bin/node-prune \
        /etc/mailcap \
        /root/.??* \
        /tmp/* \
        /usr/lib/node_modules/npm \
        /usr/local/composer.* \
        /var/log/*

# mark dirs as volumes that need to be writable, allows running the container --read-only
VOLUME /srv /tmp

COPY unit-test.sh /usr/local/bin/

WORKDIR /usr/local/bin

USER nobody

ENTRYPOINT ["unit-test.sh"]
