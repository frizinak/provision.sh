#! /bin/bash

help_text <<EOF
Base for any server that requires tls.
Simply saves the common acme account key.
EOF

include web

if [ ! -f "${acme}" ]; then
    cp $1/acme_account_key "${acme}"
    chmod 400 "${acme}"
    fix_user_perms "${webuser}"
fi
