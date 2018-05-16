help_text <<EOF
PHP XDebug
 - arg: php version
EOF

install php${2}-xdebug
cp "${1}/xdebug.ini"  "/etc/php/${2}/mods-available/xdebug.ini"

phpenmod -v ${2} xdebug

restart_php_services
