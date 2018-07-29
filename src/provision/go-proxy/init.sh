#! /bin/bash

help_text <<EOF
Reverse proxy that collects its config from the included redis server.
This config is stored by 'proxied' droplets in the proxy-domain:proxy
hash as backend-domain=internal-ip.

These proxied droplets thus require the redis-client provisioner to
access this redis-server.
EOF

include go
include tls
include redis-server

go get -u "github.com/wieni/go-tls/impl/go-reverse-proxy"

_backends=$(redis-cli -s "${redissock}" --raw hgetall "${DOMAIN}:proxy")
backends="${DOMAIN}: { backends: {"
skip=1
for i in $_backends; do
    if [ $skip -eq 1 ]; then
        skip=0
        continue
    fi
    skip=1
    if [ "$i" == "" ]; then
        continue
    fi
    backends="${backends} 'http://${i}': 10,"
done
backends="$(echo "${backends}" | sed 's/,$//') }}"

template "$1/proxy.yml" \
    account="${acme}" > "/home/${webuser}/proxy.yml" \
    servers="${backends}"

fix_user_perms "${webuser}"

service async "$1/proxy.service" \
    bin="/home/${webuser}/go/bin/go-reverse-proxy" \
    dir="/home/${webuser}" \
    user="${webuser}"

