#! /bin/bash
help_text <<EOF
PHP-FPM
 - args:
    1:   version (tested with 5.6, 7.1 and 7.2)
    ...: colon separated docroots
EOF

php_version=${2}

if [ "${php_version}" == "5.6" ]; then
    apt_repo ppa ondrej/php
fi

install nginx \
    composer \
    php-pear \
    php${php_version}-dev \
    php${php_version}-fpm \
    php${php_version}-mysql \
    php${php_version}-common \
    php${php_version}-gd \
    php${php_version}-json \
    php${php_version}-cli \
    php${php_version}-mbstring \
    php${php_version}-xml \
    php${php_version}-soap \
    php${php_version}-curl

if [ "${php_version}" != "5.6" ]; then
    install php${php_version}-zip
fi

################################################################################
#################################### XHPROF ####################################
################################################################################
if [ ! -f /etc/php/${php_version}/mods-available/tideways.ini ]; then
    rm -rf tideways
    git clone https://github.com/tideways/php-profiler-extension.git tideways
    cd tideways
    if [ "${php_version}" == "5.6" ]; then
        git reset --hard v4.1.4
    fi
    phpize${php_version}
    ./configure --with-php-config=/usr/bin/php-config${php_version}
    make
    make install

    ln -sf /etc/php/${php_version}/mods-available/tideways.ini /etc/php/${php_version}/cli/conf.d/20-tideways.ini
    ln -sf /etc/php/${php_version}/mods-available/tideways.ini /etc/php/${php_version}/fpm/conf.d/20-tideways.ini

    cd ..
fi
echo 'extension=tideways_xhprof.so' > /etc/php/${php_version}/mods-available/tideways.ini
if [ "${php_version}" == "5.6" ]; then
    echo 'extension=tideways.so' > /etc/php/${php_version}/mods-available/tideways.ini
fi

################################################################################
################################### PHPREDIS ###################################
################################################################################
if [ ! -f /etc/php/${php_version}/mods-available/redis.ini ]; then
    rm -rf phpredis
    git clone https://github.com/phpredis/phpredis.git
    cd phpredis
    phpize${php_version}
    ./configure
    make
    make install

    ln -sf /etc/php/${php_version}/mods-available/redis.ini /etc/php/${php_version}/cli/conf.d/20-redis.ini
    ln -sf /etc/php/${php_version}/mods-available/redis.ini /etc/php/${php_version}/fpm/conf.d/20-redis.ini

    cd ..
fi
echo 'extension=redis.so' > /etc/php/${php_version}/mods-available/redis.ini


if [ -e /etc/php/${php_version}/fpm/conf.d/10-opcache.ini ]; then
    rm /etc/php/${php_version}/fpm/conf.d/10-opcache.ini;
fi

rm /etc/nginx/sites-enabled/default 2>/dev/null || true

for i in ${@:3}; do
    template "$1/nginx.conf" \
        docroot="${docroot}/${i}/web" \
        php_version="${php_version}" \
        host="${i}.${DOMAIN} ${DOMAIN}" \
        > /etc/nginx/sites-available/php${php_version}-${i}.conf

    ln -sf /etc/nginx/sites-available/php${php_version}-${i}.conf \
        /etc/nginx/sites-enabled/php${php_version}-${i}.conf

    ensure_dir "${docroot}/${i}/web"
    chown -R "${webuser}:${webuser}" "${docroot}/${i}"
done

template "$1/pool.ini" \
    user="www-main" \
    mail_from="info@$DOMAIN" \
    php_version="${php_version}" \
    > /etc/php/${php_version}/fpm/pool.d/www.conf

replace_line \
    "/etc/php/${php_version}/fpm/php.ini" \
    ';pcre.backtrack_limit=' \
    'pcre.backtrack_limit=100000'

replace_line \
    "/etc/php/${php_version}/cli/php.ini" \
    ';pcre.backtrack_limit=' \
    'pcre.backtrack_limit=100000'

restart_php_services () {
    native_service async nginx.service
    native_service async php${php_version}-fpm.service
}

restart_php_services
