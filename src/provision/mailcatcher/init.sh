#! /bin/bash
help_text <<EOF
Mailcatcher service, reachable on 1080
EOF

include ruby

install libsqlite3-dev

which mailcatcher >/dev/null 2>&1 || gem install --no-rdoc --no-ri mailcatcher

service "$1/mailcatcher.service" \
    bin="/usr/local/bin/mailcatcher --foreground --ip 0.0.0.0"

prefix=''
if [ "$2" == "private" ]; then
    prefix="from ${client} to any port "
fi

ufw allow ${prefix}1080
