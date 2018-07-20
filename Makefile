src:=$(shell find src)
provision:=dist/provision.sh

rediskey:=src/provision/redis-server/id_rsa
acmekey:=src/provision/tls/acme_account_key
host_ca:=./host_ca

.PHONY: clean

$(provision): src $(src) $(rediskey) $(acmekey) $(host_ca).pub $(host_ca) | dist
	find src -type f -name '*.sh' -exec chmod +x {} \;
	cp src/_init.sh $(provision)
	cd src && tar -zchf ../dist/provision.tar.gz provision
	cat dist/provision.tar.gz >> dist/provision.sh
	rm dist/provision.tar.gz

$(rediskey):
	ssh-keygen -t rsa -b 4096 -f $(rediskey) -N ''

$(acmekey):
	ssh-keygen -t rsa -b 4096 -f $(acmekey) -N ''
	rm $(acmekey).pub

$(host_ca):
	ssh-keygen -t rsa -b 4096 -f $(host_ca) -N ''

$(host_ca).pub: $(host_ca)
	ssh-keygen -y -f $(host_ca) > $(host_ca).pub.tmp
	if ! grep -F "$$(cat $(host_ca).pub.tmp | cut -d' ' -f2)" ~/.ssh/known_hosts; then \
		{ echo -n '@cert-authority * '; cat "$(host_ca).pub.tmp"; } >> ~/.ssh/known_hosts; \
	fi
	mv $(host_ca).pub{.tmp,}

dist:
	mkdir dist

clean:
	rm -rf dist
