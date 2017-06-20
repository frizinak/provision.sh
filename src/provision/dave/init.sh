#! /bin/bash
help_text <<EOF
dave, the wieni deployment dj.
EOF

include web
include node

install openssl libgcrypt11-dev

ufw allow 1337

ensure_dir "${docroot}"
if [ ! -d "${docroot}/dave/.git" ]; then
    git clone https://klipkens@wieni.githost.io/wieni/deploy "${docroot}/dave"
fi

# make -C "${docroot}/dave" reset
sudo -u "${webuser}" -i make -C "${docroot}/dave"

rm -rf "${docroot}/dave/resources"
mv "$1/resources" "${docroot}/dave/resources"

fix_user_perms "${webuser}"

service "$1/dave.service" \
    bin="/usr/bin/node ${docroot}/dave/lib/server.js" \
    user="${webuser}"
