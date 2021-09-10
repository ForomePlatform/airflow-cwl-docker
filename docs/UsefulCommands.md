# Some useful commands:

## To view logs of the running containers:
      usage:
        docker-compose logs {container_name}
      example:
        docker-compose logs webserver

## To attach to the started container (bash)
      usage:
         docker-compose exec {container_name} bash
      example:
         docker-compose exec webserver bash
                                           
## Attach to a container when it does not start
If a container does not start because of teh startup errors,
use the following command:

    docker-compose run --entrypoint bash webserver

## To stop all your containers:
      docker-compose down

## To delete all images and containers:
      docker system prune -a

## To delete PostgreSQL volumes

    # find volume name
    docker volume ls | grep postgre
    # delete
    docker volume rm airflow-cwl-docker_postgres-db-volume

                                      
## Upgrade Airflow Database
If you have a problem with login and logs in containers complaining that
"relation does not exist" execute this:

```
docker exec -it scheduler entrypoint.sh airflow db upgrade
docker exec -it webserver entrypoint.sh airflow db upgrade
```     

## Create Airflow user

If you have a problem with login and logs in containers 
complaining that "No user yet created" execute this:

```
docker exec -it scheduler entrypoint.sh airflow users create --username $_AIRFLOW_WWW_USER_USERNAME --password $_AIRFLOW_WWW_USER_PASSWORD -r Admin -e 1@example.com -f Airflow -l Airflow
```


