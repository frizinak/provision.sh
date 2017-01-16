#! /bin/bash
help_text <<EOF
PHP dependencies, should not be used directly.
EOF

install composer \
    php-pear \
    php${2}-dev \
    php${2}-fpm \
    php${2}-mysql \
    php${2}-common \
    php${2}-gd \
    php${2}-json \
    php${2}-cli \
    php${2}-mbstring \
    php${2}-xml \
    php${2}-soap \
    php${2}-curl


################################################################################
#################################### XHPROF ####################################
################################################################################
if [ ! -f /etc/php/${2}/mods-available/tideways.ini ]; then
    rm -rf tideways
    git clone https://github.com/tideways/php-profiler-extension.git tideways
    cd tideways
    phpize${2}
    ./configure --with-php-config=/usr/bin/php-config${2}
    make
    make install

    ln -sf /etc/php/${2}/mods-available/tideways.ini /etc/php/${2}/cli/conf.d/20-tideways.ini
    ln -sf /etc/php/${2}/mods-available/tideways.ini /etc/php/${2}/fpm/conf.d/20-tideways.ini
    set_line /etc/php/${2}/mods-available/tideways.ini 'extension=tideways.so'

    cd ..
fi

################################################################################
################################### PHPREDIS ###################################
################################################################################
if [ ! -f /etc/php/${2}/mods-available/redis.ini ]; then
    rm -rf phpredis
    git clone https://github.com/phpredis/phpredis.git
    cd phpredis
    if echo "${2}" | grep '^7' >/dev/null; then
        git checkout php7
    fi
    phpize${2}
    ./configure
    make
    make install

    ln -sf /etc/php/${2}/mods-available/redis.ini /etc/php/${2}/cli/conf.d/20-redis.ini
    ln -sf /etc/php/${2}/mods-available/redis.ini /etc/php/${2}/fpm/conf.d/20-redis.ini
    set_line /etc/php/${2}/mods-available/redis.ini 'extension=redis.so'

    cd ..
fi


su $webuser -c 'composer global require drush/drush:^8.0'
set_line "/home/${webuser}/.bashrc" \
    'PATH=$PATH:$HOME/.config/composer/vendor/bin'

ensure_dir "/home/${webuser}/.drush"

cat > "/home/${webuser}/.drush/drushrc.php" <<EOF
<?php
\$_SERVER['APP_ENV'] = 'local';
EOF
