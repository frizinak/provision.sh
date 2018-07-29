#! /bin/bash
help_text <<EOF
PHP-FPM development machine (mariadb, mailcatcher)
 - args:
    1:   version (tested with 5.6, 7.1 and 7.2)
    ...: colon separated docroots
EOF

include web private
include mailcatcher private
include mariadb
include php "${@:2}"
