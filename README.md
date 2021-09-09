# Apache Airflow + CWL-Airflow in Docker with Optional Conda and R

* [Prerequisites](#prerequisites)
* [Quick Start](#quick-start)
  + [Without Conda](#without-conda)
  + [With Conda](#with-conda)
* [Custom project configurations](#custom-project-configurations)
  + [Possible Configurations](#possible-configurations)
  + [Controlling Conda environments](#controlling-conda-environments)
  + [Setting up user projects](#setting-up-user-projects)
    - [Python Projects](#python-projects)
    - [R Projects](#r-projects)
* [Before building the containers](#before-building-the-containers)
  + [Configure Git submodules](#configure-git-submodules)
  + [Configuring PostgreSQL](#configuring-postgresql)
    - [Create database and user for Airflow](#create-database-and-user-for-airflow)
    - [Configure PostgreSQL to authenticate Airflow user](#configure-postgresql-to-authenticate-airflow-user)
  + [Setup Environment Variables](#setup-environment-variables)
    - [Selecting configuration mode](#selecting-configuration-mode)
    - [Environment variables that commonly require changing](#environment-variables-that-commonly-require-changing)
  + [Managing Conda environments](#managing-conda-environments)
  + [Controlling installation of R packages](#controlling-installation-of-r-packages)
    - [Using Conda environment](#using-conda-environment)
    - [Installing from GitHub](#installing-from-github)
* [Building Containers](#building-containers)
  + [Docker build command](#docker-build-command)
  + [Rebuilding the Containers](#rebuilding-the-containers)
  + [Copying DAGs to Airflow folder](#copying-dags-to-airflow-folder)
* [Starting up the containers](#starting-up-the-containers)
  + [Checking environment variables](#checking-environment-variables)
    - [Overriding BASE_URL](#overriding-base_url)
    - [Database authentication](#database-authentication)
  + [Starting Up](#starting-up)
    - [Daemon mode](#daemon-mode)
    - [Console mode](#console-mode)
    - [Test containers](#test-containers)
    - [After starting containers](#after-starting-containers)
* [Some useful commands:](#some-useful-commands)
  + [To view logs of the running containers:](#to-view-logs-of-the-running-containers)
  + [To attach to the started container (bash)](#to-attach-to-the-started-container-bash)
  + [Attach to a container when it does not start](#attach-to-a-container-when-it-does-not-start)
  + [To stop all your containers:](#to-stop-all-your-containers)
  + [To delete all images and containers:](#to-delete-all-images-and-containers)
  + [Upgrade Airflow Database](#upgrade-airflow-database)
  + [Create Airflow user](#create-airflow-user)
* [Overriding default parameters](#overriding-default-parameters)
  + [Full list of available environment variables](#full-list-of-available-environment-variables)
  + [Example of .env file. Ready to run containers](#example-of-env-file-ready-to-run-containers)
* [Testing the installation](#testing-the-installation)
  + [Included examples](#included-examples)
  + [Testing command line mode](#testing-command-line-mode)
    - [Entering container command line environment](#entering-container-command-line-environment)
    - [Test 1: basic CWL (Hello World)](#test-1-basic-cwl-hello-world)
    - [Test 2: CWL, using python project](#test-2-cwl-using-python-project)
    - [Test 3: CWL, using R script](#test-3-cwl-using-r-script)
  + [Testing Airflow User Interface](#testing-airflow-user-interface)
    - [Preparation](#preparation)
    - [UI Test 1: basic CWL (Hello World)](#ui-test-1-basic-cwl-hello-world)
    - [UI Test 2: CWL, using python project](#ui-test-2-cwl-using-python-project)
    - [UI Test 3: CWL, using R script](#ui-test-3-cwl-using-r-script)
## Prerequisites 

>**NB**: The docker-compose.yaml in this project uses profiles and therefore
> requires **docker-compose utility version 1.29+**
 
Installation of CWL-Airflow on a dedicated host should be trivial and 
by and large should be covered by the [Quick Start](#quick-start) section 
with possible customizations described in 
[Common Environment variables](#environment-variables-that-commonly-require-changing)
and [more advanced](#full-list-of-available-environment-variables) 
options sections.

However, if the host where you are installing CWL-Airflow is shared with other 
applications, especially those, using PostgreSQL, you should read this manual
carefully.

## Quick Start

If you have a clean VM, where you want to install CWL-Airflow 
without any customizations, just issue the following commands:

### Without Conda
The simplest configuration without Conda:

    git clone https://github.com/ForomePlatform/airflow-cwl-docker.git
    cd airflow-cwl-docker
    git submodule update --init --recursive
    cp .env_example_postgres_noconda .env
    DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker-compose --env-file ./.env build
    mkdir -p ./dags && cp -rf ./project/examples/* ./dags
    docker-compose --env-file ./.env up -d
    
                                                  
The whole process, when using a stable Internet
connection should take from 5 to 20 minutes depending on your 
Internet speed.
                 
You can test the installation as described in 
[Testing the installation](#testing-the-installation) section. The first two 
examples should run in both command-line mode and in Airflow UI. 
The third example requires Conda.

### With Conda
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
    DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker-compose --env-file ./.env build
    mkdir -p ./dags && cp -rf ./project/examples/* ./dags
    docker-compose --env-file ./.env up -d

You can test the installation as described in 
[Testing the installation](#testing-the-installation) section. All three 
examples should run in both command-line mode and in Airflow UI.

##  Custom project configurations

###  Possible Configurations

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

### Controlling Conda environments

Put your env file (yaml) to folder `project` or use 
existing default (`conda_default.yml`) and then edit your `.env` file (example vim):
    
    vim .env
And then set variable AIRFLOW_CONDA_ENV (for example conda_default):

    AIRFLOW_CONDA_ENV="conda_default"
                                           
### Setting up user projects

#### Python Projects
               
Python projects can be installed inside CWL-Airflow and hence can 
be used by workflows. The automatic configuration assumes that all
Python projects must be placed in project folder under the source tree.
It can be done either by using [Git submodules](#configure-git-submodules)
utility, or, simply by copying the project content under projects folder.
Each Python project must contain `setup.py` file.
An included example, `project/python_sample_project` shows how it can be done.

If the projects depend on each other, then it is important to 
install the projects in the specific order. To enforce the order,
create a file called `projects.lst` and place it in `project` folder.
List a single subfolder of a python project on each line of this file.
If there is no file `projects.lst`, then teh projects will be installed
in an arbitrary order. See [install_projects.sh](install_projects.sh) 
for details.


#### R Projects

R scripts can be placed under project folder in the source tree. 
See included example, `project/r_sample_project`. 

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

        git submodule update --init --recursive

### Configuring PostgreSQL

**_The steps, described in this section, are only applicable if 
you would like to reuse a PostgreSQL RDBMS already 
installed on your system for Airflow_**. If you are using default 
configuration, when a new container with PostgreSQL is installed, then skip
to the [Environment Variables](#setup-environment-variables) section.

The following subsections explain how 
to configure existing PostgreSQL service to be used by Airflow.
There is a difference if PostgreSQL is running directly on 
host machine or in a separate docker container that is used by other
application.
                                                                   
#### Create database and user for Airflow
Execute the following commands, replacing appropriate values, or execute 
corresponding commands within PostgreSQL console, or SQL console.

    sudo -u postgres createuser --superuser --createrole --createdb --login --inherit airflow
    sudo -u postgres createdb --owner=airflow airflow
    sudo -u postgres psql -c "alter user airflow with password 'airflow';"

####  Configure PostgreSQL to authenticate Airflow user

If your PostgreSQL configured to authenticate user(s) 
from built-in bridge Docker network, you are all set, nothing needs
to be done.

Only if you need to adjust authentication settings, follow steps 1-4 below
or execute a similar procedure. You might need to edit two configuration 
files: `pg_hba.conf` and `postgresql.conf`. If you do not know where they 
are located, execute the following command:

    sudo -u postgres psql -c "show data_directory;"    

1. Ensure, that network, created by docker for Airflow containers
can be authenticated by PostgreSQL.

By default, docker-compose creates network with subnet 172.16.238.0/24 
and gateway 172.16.238.1/32 (it works in both modes: PostgreSQL 
on the host and PostgreSQL in a container).

If you need to change these network parameters, edit `networks` section in
`docker-compose.yaml`, at the bottom of the file.

2. Configure authentication in `pg_hba.conf`

       host    all             all             172.16.238.0/24         password

3. Configure listening address in `postgresql.conf` 

        listen_address = '*'

4. Restart PostgreSQL service. This is an OS dependent command, but on 
many Linux systems it will be (for the latest PostgreSQL at the time of
writing - [PostgreSQL 13](https://www.postgresql.org/docs/13/index.html)): 

       sudo systemctl restart postgresql-13 

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
      AIRFLOW_CONDA_ENV=[/conda_default]
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

> On [Mac systems](https://docs.docker.com/desktop/mac/networking/#there-is-no-docker0-bridge-on-macos),
> because of the way networking is implemented 
> in Docker Desktop for Mac, you cannot see a docker0 interface 
> on the host. This interface is actually within the virtual machine.
> Therefore, one has to use a 
> [workaround](https://docs.docker.com/desktop/mac/networking/#use-cases-and-workarounds).
> and set PostgreSQL server address to `host.docker.internal`
> 
>    `export POSTGRE_SERVER=host.docker.internal` 



Most probably, for security reasons, you would want to change 
username and password for the Airflow and for the 
database authentication, used by Airflow.

    export POSTGRE_DB=airflow
    export POSTGRE_USER=airflow
    export POSTGRE_PASS=airflow
    export _AIRFLOW_WWW_USER_USERNAME=airflow
    export _AIRFLOW_WWW_USER_PASSWORD=airflow

More advanced options are listed in the 
[appendix](#full-list-of-available-environment-variables)
                                                             
### Managing Conda environments

It is possible

### Controlling installation of R packages

#### Using Conda environment

Normally, R packages are installed through 
[Conda environments](#managing-conda-environments). Just make sure 
the default environment contains all necessary dependencies.

#### Installing from GitHub

R Packages listed in [r-github-packages.txt](r-github-packages.txt) are
installed directly from GitHub (see [install_conda script](install_conda.sh)).
Add any packages you need to this file. Make sure, that there is an 
end-of-line at the end of the file.

## Building Containers

### Docker build command                                 

Use the following command for docker build:

```
DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker-compose build
```

Variable DOCKER_BUILDKIT=1 instructs Docker to use 
[BuildKit](https://docs.docker.com/develop/develop-images/build_enhancements/) 
(only during build)

Variable BUILDKIT_PROGRESS=plain instructs Docker  
to use plain text progress output (only during build)

### Rebuilding the Containers
> _**NB:**_
> If you have changed the configuration mode, 
> you must completely rebuild containers, clearing the cache. Use 
> the following command:

    docker-compose down && docker-compose build --no-cache

### Copying DAGs to Airflow folder

After the build, copy the DAGs you will be using into dags fle.
Examples can be copied by the following command:

    mkdir -p ./dags && cp -rf ./project/examples/* ./dags
                                                           
If you have changed `DAGS_DIR` environment variable 
(e.g. in .env file), then the command will be:

    mkdir -p ./dags && cp -rf ./project/examples/* ${DAGS_DIR}/


## Starting up the containers

### Checking environment variables 

Some environment variables can be changed even after the 
containers are built. Examples are:

#### Overriding BASE_URL                       

    export BASE_URL=http://your_domain:8080
      
#### Database authentication

The following environment variables are responsible for
Airflow authentication for PostgreSQL:

    export POSTGRE_DB=airflow
    export POSTGRE_USER=airflow
    export POSTGRE_PASS=airflow

> _**NB:**_
> If you have changed PostgreSQL configuration or authentication 
> (`POSTGRE_DB`/`POSTGRE_USER`/`POSTGRE_PASS`),  
> and you are using PostgreSQL in a container (not on the host),
> it is necessary
> to delete postgres volume to recreate the Airflow database
 
    # stop all
    docker-compose --env-file ./.env down
    # find volume name
    docker volume ls | grep postgre
    # delete
    docker volume rm airflow-cwl-docker_postgres-db-volume
                               

### Starting Up

Export any of the environment variables that are not included 
in the `.env` file. 

Restart the containers

`docker-compose down && docker-compose --env-file ./.env up`

#### Daemon mode

`docker-compose --env-file ./.env -d up`

#### Console mode

`docker-compose --env-file ./.env up`
                                 
#### Test containers

Testing is described in 
[Testing the installation](#testing-the-installation) section. The first two 
examples should run in both command-line mode and in Airflow UI. 
The third example requires Conda.

#### After starting containers

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
                                           
### Attach to a container when it does not start
If a container does not start because of teh startup errors,
use the following command:

    docker-compose run --entrypoint bash webserver

### To stop all your containers:
      docker-compose down

### To delete all images and containers:
      docker system prune -a
                                      
### Upgrade Airflow Database
If you have a problem with login and logs in containers complaining that
"relation does not exist" execute this:

```
docker exec -it scheduler entrypoint.sh airflow db upgrade
docker exec -it webserver entrypoint.sh airflow db upgrade
```     

### Create Airflow user

If you have a problem with login and logs in containers 
complaining that "No user yet created" execute this:

```
docker exec -it scheduler entrypoint.sh airflow users create --username $_AIRFLOW_WWW_USER_USERNAME --password $_AIRFLOW_WWW_USER_PASSWORD -r Admin -e 1@example.com -f Airflow -l Airflow
```


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
## DAGS_FOLDER -- Environment variable inside container. Do not override if you set DAGS_DIR variable
# DAGS_FOLDER="/opt/airflow/dags"
# _AIRFLOW_WWW_USER_USERNAME="airflow"
# _AIRFLOW_WWW_USER_PASSWORD="airflow"
# BASE_URL="http://localhost:8080"
#
### Mapped volumes
# PROJECT_DIR="./project"
## DAGS_DIR -- Environment variable on host! Do not override if you set DAGS_FOLDER variable
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
AIRFLOW_CONDA_ENV="conda_default"
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

#### Test 3: CWL, using R script 
              
In the container execute:

    cwl-runner /dependencies/examples/rpi.cwl --script /dependencies/r_sample_project/rpi.R --iterations 1000

Look for the words a message:

    INFO [job calculate] /tmp/s7tumyy5$ Rscript \
      /tmp/tmpmkit67pd/stg19d1507c-992d-4722-82a7-fb24a87ff427/rpi.R \
      1000
    1000  ->  3.059059 
    ...
    INFO Final process status is success


### Testing Airflow User Interface
                                           
#### Preparation

1. Point your browser to http://localhost:8080
                                          
2. Log in with the username and passowrd you have defined by 

        _AIRFLOW_WWW_USER_USERNAME
        _AIRFLOW_WWW_USER_PASSWORD
                             
    environment variables (default `airflow/airflow`).

3. Go to the DAGs Tab and **enable** all dags (at least `1st-tool` and `pi`)
                                        
#### UI Test 1: basic CWL (Hello World)

4. Click Play button to the right of the DAG name `1st-tool`

5. Enter the following code into  box:

        {
          "job": {
             "message": "Hello World"
          }
        }
6. Click `Trigger` button
7. Examine the Graph and the Log for the "Hello World" result.

#### UI Test 2: CWL, using python project 

8. Click Play button to the right of the DAG name `pi`

9. Enter the following code into  box:

        {
           "job": {
              "iterations": "1000"
           }
        }
    Note, that the number of iterations must be a quoted string.

10. Click `Trigger` button
11. Examine the Graph and the Log.

#### UI Test 3: CWL, using R script 

8. Click Play button to the right of the DAG name `rpi`

9. Enter the following code into  box:

        {
           "job": {
               "script": {
                  "class": "File",
                  "location": "/dependencies/r_sample_project/rpi.R"
               },
               "iterations": "1000"
           }
        }
     Note, that the number of iterations must be a quoted string.

10. Click `Trigger` button
11. Examine the Graph and the Log.

