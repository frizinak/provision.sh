#! /bin/bash
help_text <<EOF
JRE
EOF

#if ! dpkg --status "oracle-java8-installer" >/dev/null 2>&1; then
#    add-apt-repository ppa:webupd8team/java
#    apt-get update
#    install oracle-java8-installer
#fi

dir=/usr/java
if [ ! -f $dir/bin/java ] || [ ! -f /usr/bin/java ]; then
    arch="x86"
    if lscpu | grep Architecture | grep 64 > /dev/null; then
        arch="x64"
    fi
    u=$(\
        curl -SsL http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html \
        | grep -o "Linux $arch.*\.tar\.gz" \
        | grep -o "http:.*\.tar\.gz" \
        | head -n1 \
    )
    rm -rf $dir
    mkdir $dir
    curl -L "$u" --cookie 'oraclelicense=accept-securebackup-cookie' | tar -C "$dir" --strip-components=1 -xzf -
    ln -sf "$dir/bin"/* /usr/bin/
fi
