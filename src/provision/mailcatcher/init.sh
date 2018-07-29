#! /bin/bash
help_text <<EOF
Mailcatcher service, reachable on 1080
EOF

include ruby

install libsqlite3-dev

which mailcatcher >/dev/null 2>&1 || gem install --no-rdoc --no-ri mailcatcher

service "$1/mailcatcher.service" \
    bin="/usr/local/bin/mailcatcher --foreground --ip 0.0.0.0"

firewall='firewall'
if [ "$2" == "private" ]; then
    firewall='firewall_private'
fi
$firewall allow 1080
