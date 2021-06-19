#!/bin/sh
[ ! -d /srv/tst ] && \
    echo "'tst' folder not found, are you sure you have attached your PrivateBin git repository as a volume to /srv?" 1>&2 && \
    exit 1

cp -r /srv /tmp/repo
[ -d /tmp/repo/js/node_modules ] && rm -rf /tmp/repo/js/node_modules
ln -s /usr/local/lib/node_modules /tmp/repo/js/node_modules
COMMAND="$1"
[ -n "$COMMAND" ] && shift

# run mocha…
cd /tmp/repo/js
# …(in foreground)
[ "$COMMAND" = mocha ] && mocha -c "$@"
# …(in background)
[ -z "$COMMAND" ] && mocha -c > /tmp/mocha.out 2>&1 &

# run phpunit (in foreground)
cd /tmp/repo/tst
[ "$COMMAND" = phpunit -o -z "$COMMAND" ] && /usr/local/vendor/bin/phpunit --no-coverage --colors=always "$@"

# present mocha results, when done
[ -z "$COMMAND" ] && wait && cat /tmp/mocha.out

