#! /bin/bash
help_text <<EOF
Basic nginx file server.
EOF

include web

ensure_dir "${docroot}"
fix_user_perms "${webuser}"

install nginx

rm /etc/nginx/sites-enabled/default 2>/dev/null || true

template "$1/nginx.conf" docroot="${docroot}/" \
    > /etc/nginx/sites-available/fileserver.conf

ln -sf /etc/nginx/sites-available/fileserver.conf \
    /etc/nginx/sites-enabled/fileserver.conf

native_service async nginx.service
