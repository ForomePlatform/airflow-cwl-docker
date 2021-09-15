# Apache Airflow + CWL-Airflow in Docker with Optional Conda and R

## Prerequisites 

>**NB**: The docker-compose.yaml in this project uses profiles and therefore
> requires **docker-compose utility version 1.29+**
                    
## Installation

[Deployment Guide](docs/Guide.md) provides detailed information about
deployment options and custom configurations.

[Howto](docs/Howto.md) provides a list of required and optional steps
that should be performed during the deployment.  

Installation of CWL-Airflow on a dedicated host is relatively simple and 
is by and large covered by the [Quick Start](#quick-start) section below.

Advanced options are described in the 
[Configuration Guide](docs/Configuration.md)

> If the host where you are installing CWL-Airflow is shared with other 
> applications, especially those, using PostgreSQL, you should carefully read 
> [Howto](docs/Howto.md) and [Configuration Guide](docs/Configuration.md)
 
After you have deployed CWL-Airflow, 
[test it](docs/Testing.md) 
with the included examples.
                         
You should be aware of some [useful commands](docs/UsefulCommands.md).


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
[Testing the installation](docs/Testing.md) section. The first two 
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
[Testing the installation](docs/Testing.md) section. All three 
examples should run in both command-line mode and in Airflow UI.

## Testing 

Testing is described in the [Test Guide](docs/Testing.md).
