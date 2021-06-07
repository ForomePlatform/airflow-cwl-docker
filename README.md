# Apache Airflow + CWL-Airflow in Docker

## Instruction:

### Attention #0!

If you have some limits of internet in containers:

1. Clone this repo.

2. Execute command:

`git submodule update --init --recursive`

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
