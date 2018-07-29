#! /bin/bash
help_text <<EOF
Tools for modern developers
GitLab unifies issues, code review, CI and CD into a single UI
EOF

install postfix

if ! dpkg --status gitlab-ce >/dev/null 2>&1; then
    chmod +x "$1/gitlab.sh"
    "./$1/gitlab.sh"
    install gitlab-ce
    passwd -d git
fi

template "$1/gitlab.rb" \
    domain="${DOMAIN}" \
    tz="Europe/Brussels" \
    init_passwd="${pw}" \
    unicorn_workers=3 \
    > /etc/gitlab/gitlab.rb
gitlab-ctl reconfigure

firewall allow 80
firewall allow 8080
