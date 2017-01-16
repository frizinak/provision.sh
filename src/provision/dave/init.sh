#! /bin/bash
help_text <<EOF
dave, the wieni deployment dj.
EOF

include web
include node

ufw allow 1337

ensure_dir "${docroot}"
if [ ! -d "${docroot}/dave/.git" ]; then
    git clone https://klipkens@bitbucket.org/wieni/deploy.git "${docroot}/dave"
    make -C "${docroot}/dave"
fi

fix_user_perms "${webuser}"

service "$1/dave.service" \
    bin="/usr/bin/node ${docroot}/dave/lib/server.js" \
    user="${webuser}"
