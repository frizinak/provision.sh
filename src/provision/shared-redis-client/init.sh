#! /bin/bash
help_text <<EOF
Use an ssh socket to connect to a remote redis domain socket.

envs:
- REDIS_HOST    IP of the remote redis-server
EOF

cp redis-server/id_rsa /root/redis.id_rsa

read_args=
if echo 'ping' | redis-cli -s "${redissock}" | grep -i pong >/dev/null 2>&1; then
    read_args='-ei skip'
fi

host="${REDIS_HOST}"
if [ "${REDIS_HOST}" == "" ]; then
    while [ "$host" == "" ]; do
        echo -n 'Redis host? [skip|host|ip] '
        read $read_args host
    done
    export REDIS_HOST="$host"
fi

if [ "$host" != "skip" ]; then
    ssh -i redis-server/id_rsa "${redisuser}@${host}" "true"

    install redis-server # because we want redis-cli
    systemctl disable redis-server.service
    systemctl stop redis-server.service

    ensure_dir "$(dirname "${redissock}")"

    service "$1/redis-client.service" \
        sock="${redissock}" \
        user="${redisuser}" \
        host="${host}"

    redis-cli -s "${redissock}" set "${DOMAIN}:internal_ipv4" "${IIPV4}"
    redis-cli -s "${redissock}" set "${DOMAIN}:public_ipv4" "${IPV4}"
    redis-cli -s "${redissock}" set "${DOMAIN}:public_ipv6" "${IPV6}"
    if [ "${PROXY}" != "" ]; then
        redis-cli -s "${redissock}" hset "${PROXY}:proxy" "${DOMAIN}" "${IIPV4}"
    fi
fi
