#! /bin/bash
help_text <<EOF
dave, the wieni deployment dj.
EOF

include web
include node
include php 7.1

install openssl libgcrypt11-dev python

ufw allow 1337

ensure_dir "${docroot}"
rm -rf "${docroot}/tmp-dave"
mv "$1/dave" "${docroot}/tmp-dave"
make -C "${docroot}/tmp-dave"
fix_user_perms "${webuser}"
rm -rf "${docroot}/dave"
mv "${docroot}/tmp-dave" "${docroot}/dave"

which npm-cache &>/dev/null || npm -g install npm-cache
node_link

service "$1/dave.service" \
    bin="/usr/bin/node ${docroot}/dave/lib/server.js" \
    user="${webuser}"
