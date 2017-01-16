#! /bin/bash

help_text <<EOF
Basic golang install.
EOF

include web
install golang

ensure_dir /home/${webuser}/go
export GOPATH=/home/${webuser}/go; export GOBIN=$GOPATH/bin;
export PATH="$PATH:$GOBIN"

set_line "/home/${webuser}/.bashrc" 'export GOPATH=~/go; export GOBIN="$GOPATH/bin";'
set_line "/home/${webuser}/.bashrc" 'export PATH="$PATH:$GOBIN";'

fix_user_perms "${webuser}"

