# Apache Airflow + CWL-Airflow in Docker

## Instruction:

### Attention #0!

If you have some limits of internet in containers:

1. Clone this repo. Go to repo directory

2. Execute command:

`git submodule update --init --recursive`

### If PosgtreSQL installed on host!!! (Hard way. Example. Gateway, subnet, network name and IPs may be different) 

1. Create docker network

`docker network create --gateway 172.18.0.1 --subnet 172.18.0.0/24 airflownetwork`

2. Configure authentification in pg_hba.conf

`host    all             all             172.18.0.77/32          password
host    all             all             172.18.0.99/32          password`

3. Configure listening address in postgresql.conf and restart PostgreSQL

`listen_address = '*'`

4. Create role, DB and change password in PostgreSQL

`sudo -u postgres createuser --superuser --createrole --createdb --login --inherit airflow`

`sudo -u postgres createdb --owner=airflow airflow`

`sudo -u postgres psql -c "alter user airflow with password 'airflow';"`

5. Execute commands to start:

`export POSTGRE_SERVER=172.18.0.1`  (PosqtgreSQL server IP is gateway address)

`export POSTGRE_DB=airflow`

`export POSTGRE_USER=airflow`

`export POSTGRE_PASS=airflow`

`docker-compose -f docker-compose.yaml.localexec.definenet build`

`docker-compose -f docker-compose.yaml.localexec.definenet up -d`

ATTENTION!

If you have other params of existing network (NOT built-in network! Only user-defined networks with user-defined subnets!), override this variables via export and change pg_hba.conf and postgresql.conf how need:

NETWORK_NAME

WEB_SERVER_CONTAINER_IP

SCHEDULER_CONTAINER_IP

### If PosgtreSQL installed on host!!! (Easy way: if your PostgreSQL configured to authentificate user(s) from built-in brodge Docker network)

1. Only if user and DB for Airflow do not exist

See step #4 in Hard way and execute commands.

2. Execute commands to start:

`export POSTGRE_SERVER=172.17.0.1`

`export POSTGRE_DB=airflow`

`export POSTGRE_USER=airflow`

`export POSTGRE_PASS=airflow`

`docker-compose -f docker-compose.yaml.localexec.bridgenet build`

`docker-compose -f docker-compose.yaml.localexec.bridgenet up -d`

### Local Executor. Bundle (with PostgreSQL only)

`docker-compose -f docker-compose.yaml.localexec.bundle up -d --build`

If you want to override some params, see too the section environment in docker-compose.yaml.localexec.bundle and run:

`export BASE_URL=http://your_domain:8080`

`docker-compose -f docker-compose.yaml.localexec.bundle up -d --build`

### Attention!

Full list of variables avalable for overriding via export:

POSTGRE_USER

POSTGRE_PASS

POSTGRE_DB

POSTGRE_SERVER (use only not bundle)

_AIRFLOW_WWW_USER_USERNAME

_AIRFLOW_WWW_USER_PASSWORD

WEB_SERVER_PORT

ENDPOINT_URL

BASE_URL

DAGS_DIR

SCRIPTS_DIR

LOGS_DIR

HTTP_PROXY

HTTPS_PROXY
