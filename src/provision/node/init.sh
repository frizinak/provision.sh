#! /bin/bash
help_text <<EOF
nodejs
EOF

if ! node -v  | grep 'v6\.9\.1'; then
    curl -o- "https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh" \
        | bash
    . ~/.nvm/nvm.sh
    nvm install 6.9.1
    cp -r ~/.nvm/versions/node/v6.9.1/bin/* /usr/bin/
fi

node-gyp &>/dev/null || npm -g install node-gyp
which yarn &>/dev/null || npm -g install yarn
