#! /bin/bash
help_text <<EOF
nodejs
EOF

if ! node -v  | grep 'v6\.9\.1'; then
    curl -o- "https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh" \
        | sudo -u "${user}" -i bash
    sudo -u "${user}" -i bash -c ". ~/.nvm/nvm.sh && nvm install 6.9.1"
fi

node-gyp &>/dev/null || npm -g install node-gyp
which yarn &>/dev/null || npm -g install yarn

for i in "$home/.nvm/versions/node/v6.9.1/bin/"*; do
    ln -sf "$i" "/usr/bin/$(basename "$i")"
done
