#! /bin/bash
help_text <<EOF
Elasticsearch 5.1.1

if arg 1 is 'public' elastic will be reachable on 9200
arg 2 is the java heapsize in mb (default: 128)
EOF

#if ! dpkg --status "oracle-java8-installer" >/dev/null 2>&1; then
#    add-apt-repository ppa:webupd8team/java
#    apt-get update
#    install oracle-java8-installer
#fi

dir=/usr/java
if [ ! -f $dir/bin/java ] || [ ! -f /usr/bin/java ]; then
    # http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html
    base='http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jre-8u171-linux'
    u="$base-i586.tar.gz"
    if lscpu | grep Architecture | grep 64 > /dev/null; then
        u="$base-x64.tar.gz"
    fi
    rm -rf $dir
    mkdir $dir
    curl -L "$u" --cookie 'oraclelicense=accept-securebackup-cookie' | tar -C $dir --strip-components=1 -xzf -
    ln -sf $dir/bin/* /usr/bin/
fi

if ! dpkg --status "elasticsearch" >/dev/null 2>&1; then
    wget -O /tmp/elastic.deb 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.10.deb'
    dpkg -i /tmp/elastic.deb
fi

cp "$1/elasticsearch.yml" /etc/elasticsearch/
template "$1/jvm.options" \
    size=${3:-128} \
    > /etc/elasticsearch/jvm.options

if [ "$2" == "public" ]; then
    ufw allow 9200
    replace_line \
        /etc/elasticsearch/elasticsearch.yml \
        '^network.host.*$' \
        'network.host: 0.0.0.0'
fi

systemctl restart elasticsearch.service
