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
                 
### Configuring PostgreSQL

The next steps depend on whether you would like to reuse a DBMS already 
installed on your system for Airflow or would like to install an additional 
container with PostgreSQL (default option). The following sections explain how 
to configure existing PostgreSQL service to be used by Airflow.
                                                                   
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

#### Setup Environment Variables

If you created custom docker network, your PostgreSQL server address 
is defined by `gateway` option in `docker network create` command (see above,
where it is set to `172.18.0.1`). Alternatively, it is normally, `172.17.0.1`

    export POSTGRE_SERVER=172.17.0.1  
    ## or export POSTGRE_SERVER=172.18.0.1 
    export POSTGRE_DB=airflow
    export POSTGRE_USER=airflow
    export POSTGRE_PASS=airflow

## Build Containers           
                 
By default, we will build an environment for Conda by installing 
Anaconda. 

If you do not need conda, you can disable it by follwing two steps:

1. In `Dockerfile`Comment out the line

       ENTRYPOINT [ "entrypoint.sh" ]

2. Provide the following build argument: `--build-arg conda=false`

       docker-compose  build
       ## or docker-compose  build --build-arg conda=false
       docker-compose  up -d

## Overriding default parameters

If you want to override some params, see the section environment 
in docker-compose.yaml.

###Full list of variables avalable for overriding via export:

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

###Example overriding BASE_URL                       

`export BASE_URL=http://your_domain:8080`


### If PosgtreSQL installed on host!!! (Hard way. Example. Gateway, subnet, network name and IPs may be different) 





### Attention!

