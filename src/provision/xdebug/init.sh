help_text <<EOF
PHP XDebug
 - arg: php version
EOF

if ! dpkg --status "php${2}-xdebug" &>/dev/null && ! dpkg --status "php-xdebug" &>/dev/null; then
    install php${2}-xdebug 2>/dev/null || install php-xdebug
fi
cp "${1}/xdebug.ini"  "/etc/php/${2}/mods-available/xdebug.ini"

phpenmod -v ${2} xdebug

restart_php_services
