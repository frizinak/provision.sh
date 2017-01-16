#! /bin/bash
help_text <<EOF
nodejs
EOF

if ! node -v  | grep 'v6\..\..'; then
    chmod +x "$1/setup6.x.sh"
    "$1/setup6.x.sh"
fi
install nodejs node-gyp
