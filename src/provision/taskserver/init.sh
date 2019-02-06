#! /bin/bash

help_text <<EOF
TaskWarrior Server
EOF

install taskd

if ! taskd -v | grep 1\.2\..; then
    install cmake gcc uuid-dev build-essential libgnutls28-dev
    if [ ! -d ~/taskserver.git ]; then
        git clone https://github.com/GothenburgBitFactory/taskserver.git ~/taskserver.git
    fi

    if [ ! -f ~/taskserver.git/src/taskd ]; then
        cd ~/taskserver.git
        git checkout 1.2.0
        #8e3d6d5
        git submodule init
        git submodule update
        cmake -DCMAKE_BUILD_TYPE=release .
        make
        cd -
    fi

    systemctl stop taskd
    cp ~/taskserver.git/src/taskd /usr/bin/taskd
fi

datadir=/var/lib/taskd
port=53000

mkdir -p "${datadir}/orgs" 2>/dev/null || true
if [ ! -d "${datadir}/pki" ]; then
    cp -r /usr/share/taskd/pki "${datadir}/"
fi

if [ ! -f "${datadir}/pki/ca.cert.pem" ]; then
    template "$1/vars" host=${DOMAIN} > "${datadir}/pki/vars"
    cd "${datadir}/pki"
    ./generate
    cd -
fi

chown -R Debian-taskd:Debian-taskd "${datadir}"
find "${datadir}/pki" -type d -exec chmod 700 {} \;
find "${datadir}/pki" -type f -exec chmod 600 {} \;
chmod 700 "${datadir}/pki"

template "$1/config" \
    address="*:${port}" \
    dir="${datadir}" \
    log="${datadir}/log" \
    > "${datadir}/config"


template "$1/taskd.service" dir=${datadir} > "/lib/systemd/system/taskd.service"

firewall allow "${port}"
native_service taskd
