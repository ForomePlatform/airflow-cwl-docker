# Howto

## Table of Contents

<!-- toc -->

- [Deployment Steps](#deployment-steps)
- [Building Containers](#building-containers)
  * [Docker build command](#docker-build-command)
  * [Rebuilding the Containers](#rebuilding-the-containers)
  * [When building goes wrong](#when-building-goes-wrong)
- [Copying DAGs to Airflow folder](#copying-dags-to-airflow-folder)

<!-- tocstop -->

For a simple quick start with the most common options for test 
environment see the [Quick Start](../README.md#quick-start) section
of README. It will allow you to quickly crete an environment
where you can try whether it works for you.

To keep in mind: a few [useful commands](UsefulCommands.md).

## Deployment Steps

In order to build and deploy CWL-Airflow in your custom environment
with your custom options, you will need to follow these steps:

1. Clone the repository. Sample commands:

        git clone https://github.com/ForomePlatform/airflow-cwl-docker.git
        cd airflow-cwl-docker

2. Init git submodules (_simple command below is required to fetch CWL-airflow, 
    see [Configuration](Configuration.md#configure-git-submodules)
    for advanced options_):

        git submodule update --init --recursive
                                               
3. **[Optional]** [Configure PostgreSQL](Configuration.md#configurations-related-to-postgresql) 
    and how Airflow connects to it.
4. **[Optional]** [Configure prerequisites](Configuration.md#configuring-installation-of-third-party-requirements)
5. **[Optional]** Configure [your own projects](Configuration.md#configuring-user-projects) 
    that have to be installed
    in the workflow execution environment.
6. Copy [environment template](Configuration.md#selecting-base-configuration) 
    to `.env` file. Sample command:
   
        cp .env_example_postgres_noconda .env
7. **[Optional]** Adjust environment settings:
   * [Base URL](Configuration.md#overriding-base_url)
   * How Airflow connects to PostgreSQL
   * [Airflow admin username and password](Configuration.md#airflow-admin-username-and-password)
   * [Anything else](Configuration.md#full-list-of-available-environment-variables)
8. Build the containers. Sample command (see [advanced options](#building-containers)):

        DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker-compose --env-file ./.env build
9. [Copy DAGs](#copying-dags-to-airflow-folder) from examples 
    to a directory in Airflow path (and your own DAGs)
     Sample command:

        mkdir -p ./dags && cp -rf ./project/examples/* ./dags
10. **[Optional]** Delete postgres volume to recreate the Airflow database. 
    > This step is required if you have changed PostgreSQL 
    configuration or authentication 
    (`POSTGRE_DB`/`POSTGRE_USER`/`POSTGRE_PASS`),  
    and you are using PostgreSQL in a container (not on the host).
     
    See [commands](UsefulCommands.md#to-delete-postgresql-volumes)
    to be executed.
11. Start the containers:
    * Daemon mode
    
            docker-compose down && docker-compose --env-file ./.env up -d
    * Or, console mode:
    
            docker-compose down && docker-compose --env-file ./.env up 

12. Wait for the Airflow to initialize and start up. The first time
    you run the containers, Airflow will need to perform some 
    initialization tasks, e.g., upgrading its database and
    creating an admin user
    * If you use daemon mode then use the following command to examine how 
        the Airflow starts up

            docker-compose logs -f webserver

13. [Test your deployment](Testing.md)

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

    docker-compose down && docker-compose --env-file ./.env build --no-cache
                             
### When building goes wrong
Build the containers with a detailed log. One possible command is:

    export log=build-`date +%Y-%m-%d-%H-%M`.log && date > $log && cat .env >> $log && DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker-compose --env-file ./.env  build --no-cache 2>&1 | tee -a $log && date >> $log
    

## Copying DAGs to Airflow folder

After the build, copy the DAGs you will be using into dags fle.
Examples can be copied by the following command:

    mkdir -p ./dags && cp -rf ./project/examples/* ./dags
                                                           
If you have changed `DAGS_DIR` environment variable 
(e.g. in .env file), then the command will be:

    mkdir -p ./dags && cp -rf ./project/examples/* ${DAGS_DIR}/

