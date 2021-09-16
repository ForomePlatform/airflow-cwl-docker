# Configuration Guide
                                   
## Table of Contents

<!-- toc -->

- [What can be configured](#what-can-be-configured)
- [Selecting base configuration.](#selecting-base-configuration)
- [Controlling Conda environments](#controlling-conda-environments)
  * [Setting Conda environment used during workflow executions](#setting-conda-environment-used-during-workflow-executions)
  * [Managing multiple Conda environments](#managing-multiple-conda-environments)
- [Configuring installation of third-party requirements](#configuring-installation-of-third-party-requirements)
  * [Python requirements](#python-requirements)
  * [R libraries](#r-libraries)
- [Configuring user projects](#configuring-user-projects)
  * [Python Projects](#python-projects)
  * [Enforcing order for installation of user Python Projects](#enforcing-order-for-installation-of-user-python-projects)
  * [R Projects](#r-projects)
- [Configure Git submodules](#configure-git-submodules)
- [Overriding BASE_URL](#overriding-base_url)
- [Airflow admin username and password](#airflow-admin-username-and-password)
- [Configurations related to PostgreSQL](#configurations-related-to-postgresql)
  * [When you need to change defaults](#when-you-need-to-change-defaults)
  * [Configuring PostgreSQL Server](#configuring-postgresql-server)
    + [Create database and user for Airflow](#create-database-and-user-for-airflow)
    + [Configure PostgreSQL to authenticate Airflow user](#configure-postgresql-to-authenticate-airflow-user)
  * [Tell Airflow how to authenticate with PostgreSQL](#tell-airflow-how-to-authenticate-with-postgresql)
    + [Authentication](#authentication)
    + [Networking](#networking)
    + [Note for Mac](#note-for-mac)
- [Overriding default parameters](#overriding-default-parameters)
  * [Full list of available environment variables](#full-list-of-available-environment-variables)
  * [Example of .env file. Ready to run containers](#example-of-env-file-ready-to-run-containers)

<!-- tocstop -->

## What can be configured

The following options can be configured:

* Quick Options (see [Quick Start](../README.md#quick-start) 
    and [Selecting base configuration](#selecting-base-configuration)):
    * To install Conda or not
    * Use Existing PostgreSQL or install a new container 
      (existing PostgreSQL requires custom configuration)
      
* Custom configuration
    * How Airflow connects to PostgreSQL
    * What [prerequisites and requirements](#configuring-installation-of-third-party-requirements) 
      are installed into the runtime workflow execution environment
    * What [user projects](#configuring-user-projects) 
      are installed into the runtime workflow execution environment
    * Username and password used by Airflow administrator
    * [Public Airflow URL](#overriding-base_url) 
                          
## Selecting base configuration.

You may or may not need Conda for your workflows. Your host system
might also run other applications that use PostgreSQL and thus 
already have PostgreSQL running directly on your host or in an
existing Docker container. Combination of these options bring us to four 
possible base configurations.

| Configurations  | Existing PostgreSQL | New Container with PostgreSQL |
|---|---------------------|-------------------------------|
|**With Conda** | Need to install Conda and configure PostgreSQL connections | Need to install Conda and PostgreSQL (**default**). Connections are automatically configured |
|**Without Conda** | Need to configure PostgreSQL connections | Need to install PostgreSQL. Connections are automatically configured |

Configuration is mostly defined by setting environment variables
that can be set manually in the shell or, for simplicity and 
repeatability, listed in a special file named `.env`. This package
includes four template environment files, corresponding to the 
configurations above:

| Configurations  | Existing PostgreSQL | New Container with PostgreSQL |
|---|---------------------|-------------------------------|
|**With Conda** | [.env_example_nopostgres_conda](../.env_example_nopostgres_conda) | [.env_example_postgres_conda](../.env_example_postgres_conda) |
|**Without Conda** | [.env_example_nopostgres_noconda](../.env_example_nopostgres_noconda) | [.env_example_postgres_noconda](../.env_example_postgres_noconda) |

The first step will always be to select the appropriate configuration
and copying corresponding environment file into `.env`, e.g.,

    cp .env_example_postgres_conda .env

The configuration is controlled by the two lines at the top
of each file:

      ###
      COMPOSE_PROFILES=[/postgres]
      AIRFLOW_CONDA_ENV=[/conda_default]
      ###

Then users can edit the setting in the `.env`, which they most probably 
would want to do in a production environment.



## Controlling Conda environments

### Setting Conda environment used during workflow executions
            
For more details about managing Conda environments, please look
[here](https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html).

First, 
[export the environment](https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#exporting-the-environment-yml-file) 
you need into a YAML file. Put your Conda environment file 
into `project` folder under the source tree. Then edit 
variable `AIRFLOW_CONDA_ENV` in the `.env` file:

    # AIRFLOW_CONDA_ENV="conda_default"
    AIRFLOW_CONDA_ENV="mycondaenv"

Alternatively, but less preferably, you can replace 
[conda_default.yml](../project/conda_default.yml).
   
### Managing multiple Conda environments

If you have more than one YAML file in the `project` folder,
your containers will be built with all of these environments. 
This will give you an option to switch between Conda environments 
without rebuilding the containers. The default environment will
be the one, specified by `AIRFLOW_CONDA_ENV` environment variable.

You will be also able to select
Conda environment inside a container when running command line
tools (e.g., using cwl-runner) or batch executions. 
However, only one Conda Environment, specified by 
`AIRFLOW_CONDA_ENV` environment variable will be active inside 
Airflow. To change the environment you will need to shut down
the webserver container, set the new value of `AIRFLOW_CONDA_ENV`
and restart webserver **_without_** rebuilding it. 
                         
## Configuring installation of third-party requirements

### Python requirements

Python requirements should be placed in the 
[requirements.txt](../requirements.txt) file.

### R libraries

We are using Conda as an execution environment for R scripts,
therefore R requirements should be part of your 
[Conda environment](#setting-conda-environment-used-during-workflow-executions).
                                                                              
If any R packages have to be installed from GitHub, they should be
listed in
[r-github-packages.txt](../r-github-packages.txt)
These packages are installed directly from GitHub 
by [install_conda script](../install_conda.sh) script.
Make sure, that there is an 
end-of-line at the end of the file.

## Configuring user projects

Beside installing third-party requirements, in many cases,
you will want to install your own code inside the workflow 
execution environment. This deployment supports user code
written in Python and R.

### Python Projects
               
Python projects can be installed inside CWL-Airflow and hence can 
be used by workflows. The automatic configuration assumes that all
Python projects must be placed in project folder under the source tree.
It can be done either by using [Git submodules](#configure-git-submodules)
utility, or, simply by copying the project content under projects folder.
Each Python project must contain `setup.py` file.
An included example, `project/python_sample_project` shows how it can be done.

Please make sure that the argument 

    install_requires = [
        ...
    ]

of your `setup.py` file includes all required dependencies.

### Enforcing order for installation of user Python Projects

If the projects depend on each other, then it is important to 
install the projects in the specific order. To enforce the order,
create a file called `projects.lst` and place it in `project` folder.
List a single subfolder of a python project on each line of this file.
If there is no file `projects.lst`, then teh projects will be installed
in an arbitrary order. See [install_projects.sh](../install_projects.sh) 
for details.


### R Projects

R scripts can be placed under project folder in the source tree. 
See included example, `project/r_sample_project`. 

## Configure Git submodules

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


## Overriding BASE_URL

In most of teh cases, you will use a 
[proxy server to connect to Airflow](https://airflow.apache.org/docs/apache-airflow/stable/howto/run-behind-proxy.html) 
in production environment. The connection can go through 
[nginx](https://www.nginx.com/) or
[apache](https://httpd.apache.org/) HTTP server.
Airflow itself uses redirection, therefore you will need to
tell Airflow that it is behind a proxy. This is done
by enabling a proxy fix (`enable_proxy_fix = True`) and setting the value
of `BASE_URL` in your `.env` file.

    export BASE_URL=http://my_host/myorg/airflow

## Airflow admin username and password
Most probably, for security reasons, you would want to change 
username and password for the Airflow and for the 
database authentication, used by Airflow.

    export _AIRFLOW_WWW_USER_USERNAME=airflow
    export _AIRFLOW_WWW_USER_PASSWORD=airflow

## Configurations related to PostgreSQL

### When you need to change defaults

**_The steps, described in this section, are only applicable if 
you would like to reuse a PostgreSQL RDBMS already 
installed on your system for Airflow_**. If you are using default 
configuration, when a new container with PostgreSQL is installed, 
these parameters are automatically configured.

The following subsections explain how 
to configure existing PostgreSQL service to be used by Airflow.
There is a difference if PostgreSQL is running directly on 
host machine or in a separate docker container that is used by other
application.

### Configuring PostgreSQL Server

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

### Tell Airflow how to authenticate with PostgreSQL

Airflow should know how it should connect to PostgreSQL 
and authenticate itself. It knows it by examining environment variables,
normally set in the `.env` file.

#### Authentication

In a test environment you might prefer to
keep default values and will not need to change anything. 
Most probably, for security reasons, in production environment,
you would want to change 
username and password that Airflow uses to connect. Uncomment
and edit the following lines in your `.env` file:

    # POSTGRE_USER=airflow
    # POSTGRE_PASS=airflow
    # POSTGRE_DB=airflow

#### Networking

If you created custom docker network, your PostgreSQL server address 
is defined by `gateway` option in `docker network create` command.
By default, it is set to `172.16.238.1` in the
[docker-compose](../docker-compose.yaml). Alternatively, sometimes, it 
will be `172.17.0.1` or `172.18.0.1`.

    export POSTGRE_SERVER=172.16.238.1  
    ## or export POSTGRE_SERVER=172.18.0.1

      
#### Note for Mac

> On [Mac systems](https://docs.docker.com/desktop/mac/networking/#there-is-no-docker0-bridge-on-macos),
> because of the way networking is implemented 
> in Docker Desktop for Mac, you cannot see a docker0 interface 
> on the host. This interface is actually within the virtual machine.
> Therefore, one has to use a 
> [workaround](https://docs.docker.com/desktop/mac/networking/#use-cases-and-workarounds).
> and set PostgreSQL server address to `host.docker.internal`
> 
>    `export POSTGRE_SERVER=host.docker.internal` 




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
# AIRFLOW__WEBSERVER__EXPOSE_CONFIG: "True"
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
