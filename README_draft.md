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