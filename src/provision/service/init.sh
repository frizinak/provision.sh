#! /bin/bash

help_text <<EOF
Generic service based app runner, first arg should be the binary.
EOF

if [ "$2" == "" ]; then
    echo "$1: No binary specified"
    exit 1
fi

name=$(basename $2 | tr -cd '[[:alnum:]]_-')
cp "$1/service.service" "$1/$name.service"

service "$1/$name.service" \
    bin="/home/${user}/$2" \
    user="${user}"
