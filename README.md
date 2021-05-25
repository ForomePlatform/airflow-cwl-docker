# Apache Airflow + CWL-Airflow in Docker

## Instruction:

### Budnle (with PostgreSQL and Redis)

`docker-compose -f docker-compose.yaml.bundle up -d --build`

### Without PostgreSQL and Redis

If PostgreSQL and Redis already exists, edit docker-compose.yaml file. Change AIRFLOW__CORE__SQL_ALCHEMY_CONN, AIRFLOW__CELERY__RESULT_BACKEND and AIRFLOW__CELERY__BROKER_URL values.

`docker-compose -f docker-compose.yaml up -d --build`
