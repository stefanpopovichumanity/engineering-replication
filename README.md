## Steps:

1. Go into sp-vagrant/vagrant and clone this repo - ```git clone https://github.com/stefanpopovichumanity/engineering-replication```
2. ssh into vagrant and ```cd /vagrant/engineering-replication``` (run all commands below inside vagrant)
3. Create dump.db by using ```bash create_dump.sh```
4. Run the databases ```bash init.sh```
5. Change .env to use the new databases ```bash switch_db_to_replication.sh```

## Connecting to the databases:

You can use Workbench or any other tool with the following parameters:
1. user: root
2. password: L0c@lhost
3. host: 10.11.12.13
4. port: see env.txt (defaults are 33167 for master and 33166 for slave)

## Adding replication delay:
```bash set_replication_delay.sh 5``` (or any other number)

Replication delay should be removed automatically when the slave database is restarted _(TODO: check)_

## Stopping the databases:

```bash stop.sh```

## Notes:

- init.sh needs to be started manually every time vagrant is started
