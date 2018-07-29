#! /bin/bash

help_text <<EOF
A redis-server whose domain socket can be accessed by all users on the server.
EOF

################################################################################
##################################### USER #####################################
################################################################################
create_user "${redisuser}" "${pw}"
ensure_dir "/home/${redisuser}/.ssh"
ensure_dir "/home/${redisuser}/store"
cp "$1/id_rsa.pub" "/home/${redisuser}/.ssh/authorized_keys"

template "$1/redis.conf" \
    sock="${redissock}" \
    log="/home/${redisuser}/redis-server.log" \
    store="/home/${redisuser}/store" \
    > "/home/${redisuser}/redis.conf"

chmod 666 "/home/${redisuser}/redis.conf"

fix_user_perms "${redisuser}"

################################################################################
#################################### REDIS #####################################
################################################################################
install redis-server
systemctl disable redis-server.service
systemctl stop redis-server.service

ensure_dir "$(dirname "${redissock}")"
chown "${redisuser}:${redisuser}" "$(dirname "${redissock}")"

service async "$1/redis-main.service" \
    conf="/home/${redisuser}/redis.conf" \
    sock="${redissock}" \
    user="${redisuser}"

