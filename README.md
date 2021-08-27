# Apache Airflow + CWL-Airflow in Docker with Optional Conda and R

* [Prerequisites](#Prerequisites)
* [Quick Start](#quick-start)
  + [Without Conda](#without-conda)
  + [With Conda:](#with-conda)
* [Possible Configurations](#possible-configurations)
* [Before building the containers](#before-building-the-containers)
  + [Configure Git submodules](#configure-git-submodules)
  + [Configuring PostgreSQL](#configuring-postgresql)
    - [Create database and user for Airflow](#create-database-and-user-for-airflow)
    - [Configure PostgreSQL to authenticate Airflow user](#configure-postgresql-to-authenticate-airflow-user)
  + [Setup Environment Variables](#setup-environment-variables)
    - [Selecting configuration mode](#selecting-configuration-mode)
    - [Environment variables that commonly require changing](#environment-variables-that-commonly-require-changing)
* [Building Containers](#building-containers)
* [Starting up the containers](#starting-up-the-containers)
  + [Post-build configuration](#post-build-configuration)
    - [Overriding BASE_URL](#overriding-base_url)
    - [Database authentication](#database-authentication)
  + [Starting Up](#starting-up)
    - [Daemon mode](#daemon-mode)
    - [Console mode](#console-mode)
    - [After starting containers](#after-starting-containers)
* [Some useful commands:](#some-useful-commands)
  + [To view logs of the running containers:](#to-view-logs-of-the-running-containers)
  + [To attach to the started container (bash)](#to-attach-to-the-started-container-bash)
  + [To stop all your containers:](#to-stop-all-your-containers)
  + [To delete all images and containers:](#to-delete-all-images-and-containers)
* [Overriding default parameters](#overriding-default-parameters)
  + [Full list of available environment variables](#full-list-of-available-environment-variables)
  + [Example of .env file. Ready to run containers](#example-of-env-file-ready-to-run-containers)

## Prerequisites 

>**NB**: The docker-compose.yaml in this project uses profiles and therefore
> requires **docker-compose utility version 1.28+**
 
Installation of CWL-Airflow on a dedicated host should be trivial and 
by and large should be covered by the [Quick Start](#Quick Start) section 
with possible customizations described in 
[Common Environment variables](#Environment variables that commonly require changing)
and [more advanced](#Full list of available environment variables ) 
options sections.

However, if the host where you are installing CWL-Airflow is shared with other 
applications, especially those, using PostgreSQL, you should read this manual
carefully.

## Quick Start

If you have a clean VM, where you want to install CWL-Airflow 
without any 
customizations, just issue the following commands:

### Without Conda
The simplest configuration without Conda:

    git clone https://github.com/ForomePlatform/airflow-cwl-docker.git
    cd airflow-cwl-docker
    git submodule update --init --recursive
    cp .env_example_postgres_noconda .env
    source .env
    DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker-compose build
    docker-compose --env-file ./.env up -d
    sudo cp -rf ./project/examples/* ./dags
                                                  
The whole process should take about 15 minutes on a stable Internet
connection.
                 
You can test the installation as described in 
[Testing Installation](#Testing the installation) section. The first two 
examples should run in both command-line mode and in Airflow UI. 
The third example requires Conda.

### With Conda:
If you need to use CWL-Airflow in Conda environment, then instead of 

    cp .env_example_postgres_noconda .env
use

    cp .env_example_postgres_conda .env
                                         
Please note, that Conda installation might take about an hour.

Full sequence of commands to copy and paste:

    git clone https://github.com/ForomePlatform/airflow-cwl-docker.git
    cd airflow-cwl-docker
    git submodule update --init --recursive
    cp .env_example_postgres_conda .env
    source .env
    DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker-compose build
    docker-compose --env-file ./.env up -d
    sudo cp -rf ./project/examples/* ./dags

You can test the installation as described in 
[Testing Installation](#Testing the installation) section. All three 
examples should run in both command-line mode and in Airflow UI.

## Possible Configurations

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

1. Ensure, that network, created by docker for Airflow containers
can be authenticated by PostgreSQL.

By default, docker-compose creates network with subnet 172.16.238.0/24 
and gateway 172.16.238.1/32 (it works in both modes: PostgreSQL 
on the host and PostgreSQL in a container).

If you need to change these network parameters, edit `networks` section in
`docker-compose.yaml`, at the bottom of the file.

2. Configure authentication in `pg_hba.conf`

        host    all             all             172.16.238.0/24         password

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
      CONDA_CHECK=[true/false]
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
where it is set to `172.16.238.1`). Alternatively, it is normally, `172.17.0.1`

    export POSTGRE_SERVER=172.16.238.1  
    ## or export POSTGRE_SERVER=172.18.0.1

Most probably, for security reasons, you would want to change 
username and password for the database authentication, used by Airflow.

    export POSTGRE_DB=airflow
    export POSTGRE_USER=airflow
    export POSTGRE_PASS=airflow

More advanced options are listed in the 
[appendix](#Full list of variables available for overriding via export)

## Building Containers

Export CONDA_CHECK variable either by sourcing your `.env` file
or by giving one of the export commands below:

```
EXPORT CONDA_CHECK="false"
EXPORT CONDA_CHECK="true"
```

Then, run the build command:

```
DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker-compose build
```
Variable DOCKER_BUILDKIT=1 set Docker configuration to use 
buildkit (only during build)

Variable BUILDKIT_PROGRESS=plain set Docker configuration 
to use plain text progress output (only during build)


> _**NB:**_
> If you have changed the configuration mode, 
> you must completely rebuild containers, clearing the cache. Use 
> the following command:

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

Export any of the environment variables that are not included 
in `.env` file. 

Restart the containers

`docker-compose down && docker-compose --env-file ./.env up`

#### Daemon mode

`docker-compose --env-file ./.env -d up`

#### Console mode

`docker-compose --env-file ./.env up`


#### After starting containers
If you have a problem with login and logs in contaners say about "relation does not exist" execute this:

>```
>docker exec -it scheduler entrypoint.sh airflow db upgrade
>docker exec -it webserver entrypoint.sh airflow db upgrade
>```     

If you have a problem with login and logs in contaners say about "No user yet created" execute this:

>```
>docker exec -it scheduler entrypoint.sh airflow users create --username $_AIRFLOW_WWW_USER_USERNAME --password $_AIRFLOW_WWW_USER_PASSWORD -r Admin -e 1@example.com -f Airflow -l Airflow
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

### Full list of available environment variables 

The following variables can be exported in the shell or updated in .env file
to override their default values

```
### Available options and default values
## Postgres
# POSTGRE_USER=airflow
# POSTGRE_PASS=airflow
# POSTGRE_DB=airflow
# POSTGRES_PORT=5432
#
## Airflow parameters
# POSTGRE_SERVER=postgres
# WEB_SERVER_PORT=8080
# AIRFLOW__CORE__LOAD_EXAMPLES="False"
## DAGS_FOLDER -- Environment varibale inside container. Do not override if you set DAGS_DIR variable
# DAGS_FOLDER="/opt/airflow/dags"
# _AIRFLOW_WWW_USER_USERNAME="airflow"
# _AIRFLOW_WWW_USER_PASSWORD="airflow"
# BASE_URL="http://localhost:8080"
#
### Mapped volumes
# PROJECT_DIR="./project"
## DAGS_DIR -- Environment varibale on host! Do not override if you set DAGS_FOLDER variable
# DAGS_DIR="./dags"
# LOGS_DIR="./airflow-logs"
# CWL_TMP_FOLDER="./cwl_tmp_folder"
# CWL_INPUTS_FOLDER="./cwl_inputs_folder"
# CWL_OUTPUTS_FOLDER="./cwl_outputs_folder"
# CWL_PICKLE_FOLDER="./cwl_pickle_folder"
```
### Example of .env file. Ready to run containers
> NB: Values might be different for your environment
```
COMPOSE_PROFILES=
CONDA_CHECK="true"
POSTGRE_SERVER="172.16.238.1"
POSTGRE_DB=airflow
POSTGRE_USER=airflow
POSTGRE_PASS=airflow
PROJECT_DIR=./project
DAGS_DIR=./dags
LOGS_DIR=./airflow-logs
CWL_TMP_FOLDER=./cwl_tmp_folder
CWL_INPUTS_FOLDER=./cwl_inputs_folder
CWL_OUTPUTS_FOLDER=./cwl_outputs_folder
CWL_PICKLE_FOLDER=./cwl_pickle_folder
```

## Testing the installation
### Included examples
                       
This distribution include 3 tests:

- Basic CWL, aka "Hello World" example
- CWL, using a python project
- CWL, using an R program

The first two examples should run in all modes, the third requires
conda environment.

The examples should run in both command-line mode (from a terminal) 
and in Airflow UI.

### Testing command line mode
#### Entering container command line environment

Execute the following command to enter the container:

    docker exec -it webserver bash

> You might need to use sudo to run docker commands:
>
>>    sudo docker exec -it webserver bash

#### Test 1: basic CWL (Hello World)
              
In the container execute:

    cwl-runner /dependencies/examples/1st-tool.cwl /dependencies/examples/echo-job.yaml

Look for the words "Hello World" and a message:

    INFO Final process status is success

#### Test 2: CWL, using python project 
              
In the container execute:

    cwl-runner /dependencies/examples/pi.cwl --iterations 1000

Look for the words a message:

    INFO [job calculate] /tmp/l416_dsl$ python \
        -m \
        pi \
        1000
    3.140592653839794
    ...
    INFO Final process status is success
