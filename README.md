# Apache Airflow + CWL-Airflow in Docker with Optional Conda and R

## Possible Configurations

>**NB**: The docker-compose.yaml in this project uses profiles and therefore
> requires **docker-compose utility version 1.28+**

Airflow requires a relational database management system (RDBMS) to 
store and manage states of the running pipelines. This configuration
assumes that the RDBMS in use is [PostgreSQL](https://www.postgresql.org/).

By default, most Airflow docker configurations, including this one, build 
and install a new container running an appropriate version of PostgreSQL.
However, in many cases Airflow will be installed on a system that already
runs PostgreSQL. Installing another container with PostgreSQL will cause
conflicts with TCP ports, beside creating a general mess and requiring 
additional resources. To address these cases we provide an option to use
an existing PostgreSQL installation instead of creating a new container.

Many data science and bioinformatics applications use 
[Conda](https://docs.conda.io/en/latest/) to manage their
environments. This is especially helpful if some of workflow
steps use [R](https://www.r-project.org/about.html) programming language. 
Regardless of whether Conda is already set up on the host system, in order
to be used inside workflows, it has to be installed within the CWL-Airflow
container. Therefore we provide an option to install 
[Anaconda®](https://repo.anaconda.com/) as part of the setup procedure.

This brings us to four possible configurations:

| Configurations  | Existing PostgreSQL | New Container with PostgreSQL |
|---|---------------------|-------------------------------|
|**With Conda** | Only Conda | Conda + PostgreSQL (default) |
|**Without Conda** | Vanilla | PostgreSQL |
          
Selection of one of these four possible configuration is controlled through 
environment variables.

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

### Configuring PostgreSQL

The steps, described in this section, are only applicable if 
you would like to reuse a PostgreSQL RDBMS already 
installed on your system for Airflow. If you are using default 
configuration, when a new container with PostgreSQL is installed, then skip
to [Environment Variables](#Setup Environment Variables) section.

The following subsections explain how 
to configure existing PostgreSQL service to be used by Airflow.
There is a difference if PostgreSQL is running directly on 
host machine or in a separate docker container that is used by other
application.
                                                                   
#### Create database and user for Airflow
Execute the following commands, replacing appropriate values, or execute 
corresponding commands within PostgreSQL console, or SQL console.

`sudo -u postgres createuser --superuser --createrole --createdb --login --inherit airflow`

`sudo -u postgres createdb --owner=airflow airflow`

`sudo -u postgres psql -c "alter user airflow with password 'airflow';"`

####  Configure PostgreSQL to authenticate Airflow user

If your PostgreSQL configured to authenticate user(s) 
from built-in bridge Docker network, you are all set, nothing needs
to be done.

Only if you need to adjust authentication settings, follow these steps
or execute a similar procedure:

1. Create docker network

`docker network create --gateway 172.18.0.1 --subnet 172.18.0.0/24 airflownetwork`

2. Configure authentication in `pg_hba.conf`

        host    all             all             172.18.0.77/32          password
        host    all             all             172.18.0.99/32          password

3. Configure listening address in `postgresql.conf` and restart PostgreSQL

        listen_address = '*'

If you have an existing ***user-defined*** network with custom parameters 
(***NOT a built-in network***), you will probably need to override these
additional parameters by exporting them as environment variables 
and adjusting pg_hba.conf and postgresql.conf as needed.
 
    NETWORK_NAME
    WEB_SERVER_CONTAINER_IP
    SCHEDULER_CONTAINER_IP

### Setup Environment Variables

Environment variables can be defined in `.env` file or as host environment
variables in teh shell that executes docker commands.

#### Selecting configuration mode
                                 
As discussed, the included `docker-compose.yaml` supports four configuration
modes:

1. Airflow with Conda and with PostgreSQL in a new container (default)
2. Airflow without Conda and PostgreSQL in a new container
3. Airflow with Conda, reusing existing PostgreSQL installation
4. Airflow without Conda, reusing existing PostgreSQL installation
                                                     
Included in the root folder of the project are four sample 
`.env_example_*` files, each corresponding to one of these 
configurations: 

```
.env_example_nopostgres_conda
.env_example_nopostgres_noconda
.env_example_postgres_conda
.env_example_postgres_noconda
```

The configuration is controlled by the two lines at the top
of each file:

      ###
      COMPOSE_PROFILES=[/postgres]
      conda=[true/false]
      ###
   

Select the file, corresponding to your desired configuration
and copy it to the file with the name ".env". Adjust all other 
environment variables to match your configuration
As example for second mode "without Conda and with Postgres")
```
cp -r .env_example_postgres_noconda .env
```

#### Environment variables that commonly require changing
                                          
You can edit these values in the `.env` file or set them up in
the shell used to run docker commands

If you created custom docker network, your PostgreSQL server address 
is defined by `gateway` option in `docker network create` command (see above,
where it is set to `172.18.0.1`). Alternatively, it is normally, `172.17.0.1`

    export POSTGRE_SERVER=172.17.0.1  
    ## or export POSTGRE_SERVER=172.18.0.1

Most probably, for security reasons, you would want to change 
username and password for the database authentication, used by Airflow.

    export POSTGRE_DB=airflow
    export POSTGRE_USER=airflow
    export POSTGRE_PASS=airflow

More advanced options are listed in the 
[appendix](#Full list of variables avalable for overriding via export)

## Building Containers

Simply run the build command:

```
docker-compose build
```
> **_NB:_ If you have changed the configuration mode, 
> you must completely rebuild containers, clearing the cahce. Use 
> the following command:**

      docker-compose down && docker-compose build --no-cache

## Starting up the containers

### Post-build configuration 

Some environment variables can be changed even after the 
containers are built. Examples are:

#### Overriding BASE_URL                       

`export BASE_URL=http://your_domain:8080`
      
#### Database authentication

> **As example**
```
export BASE_URL=http://yourdomain.com
export POSTGRE_USER=airflow
export POSTGRE_PASS=airflow
```

### Starting Up

Source the `.env` file:
```
source .env
```

Then, restart containers

`docker-compose down && docker-compose up`

#### Daemon mode

`docker-compose -d up`

Console mode

`docker-compose up`


#### After starting containers
If you have a problem with login and logs in contaners say about "relation does not exist" execute this:

>```
>docker exec -it scheduler entrypoint.sh >airflow db upgrade
>docker exec -it webserver entrypoint.sh >airflow db upgrade
>```       

## Some useful commands:

### To view logs of the running containers:
      usage:
          docker-compose logs {container_name}
      example:
        docker-compose logs webserver

### To attach to the started container (bash)
      usage:
         docker-compose exec {container_name} bash
      example:
         docker-compose exec webserver bash

### To stop all your containers:
      docker-compose down

### To delete all images and containers:
      docker system prune -a


## Overriding default parameters

If you want to override some params, see the section environment 
in docker-compose.yaml.

###Full list of variables avalable for overriding via export

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



