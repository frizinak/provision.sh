#! /bin/bash
help_text <<EOF
Elasticsearch 5.1.1

if arg 1 is 'public' elastic will be reachable on 9200
arg 2 is the java heapsize in mb (default: 128)
EOF

include java

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
