# Apache Airflow + CWL-Airflow in Docker with Optional Conda and R

## Before building the containers

### Configure Git submodules

This step is especially important if you are working inside environment 
with limited Internet capabilities. It works around the problem that docker
containers running CWL and Airflow might have no access to the Internet.

Most probably, you need to install your projects inside the CWL-Airflow 
environment. These projects can be installed using Git submodules functionality.

1. Clone this repo and go to repo directory
                     
2. If you need to install additional projects with custom code 
   [add them as submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) 
   to the project as subprojects inside `project` subdirectory. You can also
   just copy the content into a subdirectory of `project`.
   Please note, that one submodule (CWL-Airflow) is already included. 

2. Execute command:

`git submodule update --init --recursive`

#### Setup Environment Variables

###### This dockercompose supports four modes:

1. Airflow with Conda and with Postges (by default)
2. Airflow without Conda and with Postges
3. Airflow with Conda and without Postges
4. Airflow without Conda and without Postges

> **_NOTE:_** For choosing start mode uses the next options:
>```
>COMPOSE_PROFILES [postgres,null] 
>conda [true,false]
>```


In the root folder of project four files with the example .env file for the docker-compose:
```
.env_exapmple_nopostgres_conda
.env_exapmple_nopostgres_noconda
.env_exapmple_postgres_conda
.env_exapmple_postgres_noconda
```
Choose the right for you and rename it to ".env".
As example for second mode "without Conda and with Postges")
```
cp -r .env_exapmple_postgres_noconda .env
```

> **_NOTE:_ !! If you change mode you must completely rebuild containers:**
> `docker-compose down && docker-compose build --no-cache`

### Build Containers
```
docker-compose build
```

### Configuring and starting containers
#### Configuring
If you want to override some params, edit .env file in the root folder.
###### Full list of variables with default values available for editing::
```

### Available options and default values
## Postgres
# POSTGRE_USER: airflow
# POSTGRE_PASS: airflow
# POSTGRE_DB: airflow
# POSTGRES_PORT: 5432
#
## Airflow parameters
# POSTGRE_SERVER: postgres
# WEB_SERVER_PORT: 8080
# AIRFLOW__CORE__SQL_ALCHEMY_CONN: postgresql+psycopg2://${POSTGRE_USER:-airflow}:${POSTGRE_PASS:-airflow}@${POSTGRE_SERVER:-postgres}/${POSTGRE_DB:-airflow}
# AIRFLOW_CONN_METADATA_DB: postgresql+psycopg2://${POSTGRE_USER:-airflow}:${POSTGRE_PASS:-airflow}@${POSTGRE_SERVER:-postgres}/${POSTGRE_DB:-airflow}
# AIRFLOW_VAR__METADATA_DB_SCHEMA: ${POSTGRE_DB:-airflow}
# AIRFLOW__CORE__LOAD_EXAMPLES: False
# DAGS_FOLDER: /opt/airflow/dags
# _AIRFLOW_WWW_USER_USERNAME: airflow
# _AIRFLOW_WWW_USER_PASSWORD: airflow
# BASE_URL: http://localhost:8080 - AIRFLOW__WEBSERVER__BASE_URL
#
### Mapped volumes
# PROJECT_DIR: ./project
# DAGS_DIR: ./dags
# LOGS_DIR: ./airflow-logs
# CWL_TMP_FOLDER:-./cwl_tmp_folder
# CWL_INPUTS_FOLDER:-./cwl_inputs_folder
# CWL_OUTPUTS_FOLDER:-./cwl_outputs_folder
# CWL_PICKLE_FOLDER:-./cwl_pickle_folder
```

> **As example**
> _Changing base url and www username and password_
> Add next lines to the .env file:
>```
>BASE_URL=http://yourdomain.com
>POSTGRE_USER: airflow
>POSTGRE_PASS: airflow
>```
>And restart conteiners
>`docker-compose down && docker-compose up`

#### Starting
Daemon mode
`docker-compose -d up`
Console mode
`docker-compose up`
> **_Note_** Some useful commands:
> 1. To see logs of started containers
> usage
> `docker-compose logs {container_name}`
> example
> `docker-compose logs webserver`
> 2. To attach to the started container (bash)
> usage
> `docker-compose exec {container_name} bash`
> example
> `docker-compose exec webserver bash`
> 3. Command to stop all your containers:
> `docker-compose down`
> 4. To delete all images and containers:
> `docker system prune -a`