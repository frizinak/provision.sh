#! /bin/bash

help_text <<EOF
A VPN
EOF

install openvpn easy-rsa

cp $1/server.conf /etc/openvpn/server.conf

set_line /etc/sysctl.conf 'net.ipv4.ip_forward=1'

echo 1 > /proc/sys/net/ipv4/ip_forward
cp $1/ufw /etc/default/ufw
cp $1/before.rules /etc/ufw/before.rules
ufw allow 1194/udp

if [ ! -f /etc/openvpn/server.crt ]; then
    cp -r /usr/share/easy-rsa/ /etc/openvpn
    mkdir /etc/openvpn/easy-rsa/keys || true
    touch /etc/openvpn/easy-rsa/keys/index.txt
    cd /etc/openvpn/easy-rsa
    . /etc/openvpn/easy-rsa/vars
    export KEY_COUNTRY="US"
    export KEY_PROVINCE="TX"
    export KEY_CITY="Dallas"
    export KEY_ORG="Hideeho"
    export KEY_EMAIL="welcome@vpn.com"
    export KEY_OU="iunno"
    export KEY_NAME="server"

    ./clean-all
    if [ ! -f /etc/openvpn/dh2048.pem ]; then
        openssl dhparam -out /etc/openvpn/dh2048.pem 2048
    fi

    ./build-ca
    ./build-key-server server
    cp /etc/openvpn/easy-rsa/keys/{server.crt,server.key,ca.crt} /etc/openvpn
    cd -
fi

# gen keys:
# cd /etc/openvpn/easy-rsa
# . ./vars
# ./build-key <name>

native_service openvpn
