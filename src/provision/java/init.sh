#! /bin/bash
help_text <<EOF
JRE
EOF

dir=/usr/java
if [ ! -f $dir/bin/java ] || [ ! -f /usr/bin/java ]; then
    arch="x86"
    if lscpu | grep Architecture | grep 64 > /dev/null; then
        arch="x64"
    fi

    rm -rf $dir
    mkdir $dir

    mirror="$(ls -1 ./mirror/java/jre*${arch}.tar.gz | tail -n1)"
    if [ "$mirror" != "" ] && [ -f "$mirror" ]; then
        echo 'From local mirror'
        tar -C "$dir" --strip-components=1 -xzf "$mirror"
    else
        echo 'Downloading fresh'
        u=$(\
            curl -SsL  \
                http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html \
                | grep -o "Linux ${arch}.*\.tar\.gz" \
                | grep -o "https:.*\.tar\.gz" \
                | head -n1 \
        )
        curl -L "$u" --cookie 'oraclelicense=accept-securebackup-cookie' | tar -C "$dir" --strip-components=1 -xzf -
    fi
    ln -sf "$dir/bin"/* /usr/bin/
fi
