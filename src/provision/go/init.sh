#! /bin/bash

help_text <<EOF
Basic golang install.
EOF

include web

if [ ! -d /usr/local/go ]; then
    curl 'https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz' | \
        tar -C /usr/local -xzf -
fi

ensure_dir /home/${webuser}/web/go

ln -sf /usr/local/go/bin/go /usr/local/bin/go

set_line "/home/${webuser}/.bashrc" 'export GOPATH=~/web/go; export GOBIN="$GOPATH/bin"; export GOROOT="/usr/local/go";'
set_line "/home/${webuser}/.bashrc" 'export PATH="$PATH:$GOBIN";'

fix_user_perms "${webuser}"

