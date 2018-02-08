#! /bin/bash
help_text <<EOF
Create a temp swap file
 - arg: size in MiB [default: 1024]
EOF

swapoff /swap 2>/dev/null || true
count=$(( ${2:-1024} * 1024 ))
dd if=/dev/zero of=/swap bs=1024 count=$count
chown root:root /swap
chmod 0600 /swap
mkswap /swap
swapon /swap
