#! /bin/bash
help_text <<EOF
Disable ipv6
EOF

replace_line '/etc/sysctl.conf' \
    'net.ipv6.conf.all.disable_ipv6.*' 'net.ipv6.conf.all.disable_ipv6 = 1'

replace_line '/etc/sysctl.conf' \
    'net.ipv6.conf.default.disable_ipv6.*' 'net.ipv6.conf.default.disable_ipv6 = 1'

replace_line '/etc/sysctl.conf' \
    'net.ipv6.conf.lo.disable_ipv6.*' 'net.ipv6.conf.lo.disable_ipv6 = 1'

sysctl -p
