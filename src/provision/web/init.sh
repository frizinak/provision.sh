#! /bin/bash

help_text <<EOF
Base webserver setup:
- create webuser
- allow ssh as this webuser
- open up ports 80, 443, 8080 and 8081
- forward 8080 to 80 and 8081 to 443.
EOF

################################################################################
##################################### USER #####################################
################################################################################
create_user "${webuser}" "${pw}"

ensure_dir "/home/${webuser}/.ssh"
cp $1/authorized_keys "/home/${webuser}/.ssh/"
cp ./bashrc "/home/${webuser}/.bashrc"

fix_user_perms "${webuser}"

################################################################################
################################### FIREWALL ###################################
################################################################################
firewall='firewall'
if [ "$2" == "private" ]; then
    firewall='firewall_private'
fi

$firewall allow 80
$firewall allow 443
$firewall allow 8080
$firewall allow 8081

rules=(\
    "PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080" \
    "PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8081" \
    )

for rule in "${rules[@]}"; do
    if ! iptables -t nat -C ${rule} 2>/dev/null; then
        iptables -t nat -A ${rule}
    fi
done
