Simple bash digital ocean droplet creation and provisioning

# how
- use doctl to create droplets and dns records
- upload a tar.gz of src to the droplet and execute the provisioner
- yeh...

# why

Clean dev environment, please do not use this for a production app...

To prove a point, ansible and puppet are for vast infrastructures, bash
is for everything else and is not a problem that needs solving.

Vagrant issue after vagrant issue, also ansible.

DO cpu time is pretty cheap, need my cpu for reddit.com/r/gifs.

No migration between different machines (home, work, ...)

# cray cray

Crazy enough to try this?

create ~/.doctlcfg
```
access-token: <your-digitalocean-api-token>
output: text
```

edit src/provision/authorized_keys and replace with one of your ssh pubkeys

# cwd

every single script should be executed from the repo root... (:/ ikr)

i.e.: `./droplet.sh` `./servers/domain/dns-record/provision-ip.sh` `...`

# droplet.sh

`./droplet.sh domain region size imageRE`

e.g.: `./droplet.sh redis.website.com ams2 512mb 'ubuntu-16.*64'`

will prompt for any missing args

server info stored in servers/domain/dns-record/info-ip.{yml,json}

e.g.: `./droplet.sh redis.website.com ams2`

# destroy

`./servers/domain/dns-record/destroy-ip.sh`

# provision

`./servers/domain/dns-record/provision-ip.sh provisionerA,provisionerB:argB1:argB2`

`./servers/domain/dns-record/provision-ip.sh provisioner --no-upgrade|-n`

will prompt for the provisioner if arg was omitted


# Full example

```
# create domain website.com so all dns entries are grouped under this domain
./droplet.sh redis.website.com ams2 512mb 'ubuntu-16.*64'
./droplet.sh fs1.website.com ams2 512mb 'ubuntu-16.*64'
./droplet.sh fs2.website.com ams2 512mb 'ubuntu-16.*64'

export PROVISION_REDIS_SERVER=<public/internal/floating ip>

./servers/website.com/redis/provision-<IP>.sh redis-server
./servers/website.com/fs1/provision-*.sh fileserver
./servers/website.com/fs2/provision-*.sh fileserver

ssh asdf@fs1.website.com
redis-cli -s /var/redis.sock get fs2.website.com:internal_ipv4
```



# TODO
local envs are inheritted during provisioning if prefixed with 'PROVISION_'

e.g.: export PROVISION_REDIS_HOST=10.129.16.244

# Known bugs:

- destroying a server with a floating ip will require executing destroy.sh
multiple times. Which is because destroying a droplet and a floating ip are
both 'droplet actions' and no actions can be undertaken while another is still
processing.

- doctl doesnt provide appropriate exit codes => we'll continue adding
dns records etc even if the droplet was never created. (not anymore [v1.4.0])
