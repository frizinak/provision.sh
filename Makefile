src:=$(shell find src)
provision:=dist/provision.sh

rediskey:=src/provision/redis-server/id_rsa
acmekey:=src/provision/tls/acme_account_key

.PHONY: clean

$(provision): src $(src) $(rediskey) $(acmekey) | dist
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

dist:
	mkdir dist

clean:
	rm -rf dist
