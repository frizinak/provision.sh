#! /bin/bash
help_text <<EOF
Private PHP5.0 fpm nginx mariadb setup.
 - args: colon separated docroots
EOF

apt_repo ppa:ondrej/php

include web private
include mailcatcher private
include php 5.6
include mariadb

install nginx

if [ -e /etc/php/5.6/fpm/conf.d/10-opcache.ini ]; then
    rm /etc/php/5.6/fpm/conf.d/10-opcache.ini;
fi

rm /etc/nginx/sites-enabled/default 2>/dev/null || true

for i in ${@:2}; do
    template "$1/nginx.conf" docroot="${docroot}/${i}/web" \
        host="${i}.${DOMAIN} ${DOMAIN}" \
        > /etc/nginx/sites-available/php5-${i}.conf

    ln -sf /etc/nginx/sites-available/php5-${i}.conf \
        /etc/nginx/sites-enabled/php5-${i}.conf

    ensure_dir "${docroot}/${i}/web"
done

fix_user_perms "${webuser}"

template "$1/pool.ini" user="www-main" mail_from="info@$DOMAIN" \
    > /etc/php/5.6/fpm/pool.d/www.conf

replace_line \
    '/etc/php/5.6/fpm/php.ini' \
    ';pcre.backtrack_limit=100000' \
    'pcre.backtrack_limit=10000'

replace_line \
    '/etc/php/5.6/cli/php.ini' \
    ';pcre.backtrack_limit=100000' \
    'pcre.backtrack_limit=10000'

restart_php_services
