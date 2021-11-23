# Testing the installation

## Table of Contents

<!-- toc -->

- [Included examples](#included-examples)
- [Testing command line mode](#testing-command-line-mode)
  * [Test 1: basic CWL (Hello World)](#test-1-basic-cwl-hello-world)
  * [Test 2: CWL, using python project](#test-2-cwl-using-python-project)
  * [Test 3: CWL, using R script](#test-3-cwl-using-r-script)
  * [Alternative way to test command line](#alternative-way-to-test-command-line)
- [Testing Airflow User Interface](#testing-airflow-user-interface)
  * [Preparation](#preparation)
  * [UI Test 1: basic CWL (Hello World)](#ui-test-1-basic-cwl-hello-world)
  * [UI Test 2: CWL, using python project](#ui-test-2-cwl-using-python-project)
  * [UI Test 3: CWL, using R script](#ui-test-3-cwl-using-r-script)

<!-- tocstop -->

To keep in mind: a few [useful commands](UsefulCommands.md).

## Included examples
                       
This distribution include 3 tests:

- Basic CWL, aka "Hello World" example
- CWL, using a python project
- CWL, using an R program

The first two examples should run in all modes, the third requires
conda environment.

The examples should run in both command-line mode (from a terminal) 
and in Airflow UI.

## Testing command line mode

### Test 1: basic CWL (Hello World)
              
Execute:

    docker exec webserver bash -ic 'cwl-runner /dependencies/examples/1st-tool.cwl /dependencies/examples/echo-job.yaml'

Look for the words "Hello World" and a message:

    INFO Final process status is success

> You might need to use sudo to run docker commands:
>
>>    sudo docker exec webserver bash -ic 'cwl-runner /dependencies/examples/1st-tool.cwl /dependencies/examples/echo-job.yaml' 

### Test 2: CWL, using python project 
              
Execute:

    docker exec webserver bash -ic 'cwl-runner /dependencies/examples/pi.cwl --iterations 1000'

Look for the words a message:

    INFO [job calculate] /tmp/l416_dsl$ python \
        -m \
        pi \
        1000
    3.140592653839794
    ...
    INFO Final process status is success

> You might need to use sudo to run docker commands:
>
>>    sudo docker exec webserver bash -ic 'cwl-runner /dependencies/examples/pi.cwl --iterations 1000'

### Test 3: CWL, using R script 
                            
> This test only works if Conda has been installed. It will fail in "noconda"
> mode

Execute:

    docker exec webserver bash -ic 'cwl-runner /dependencies/examples/rpi.cwl --script /dependencies/r_sample_project/rpi.R --iterations 1000'

Look for the words a message:

    INFO [job calculate] /tmp/s7tumyy5$ Rscript \
      /tmp/tmpmkit67pd/stg19d1507c-992d-4722-82a7-fb24a87ff427/rpi.R \
      1000
    1000  ->  3.059059 
    ...
    INFO Final process status is success

> You might need to use sudo to run docker commands:
>
>>    sudo docker exec webserver bash -ic 'cwl-runner /dependencies/examples/rpi.cwl --script /dependencies/r_sample_project/rpi.R --iterations 1000'
                                  
### Alternative way to test command line
Instead of executing `docker exec webserver` command for each test,
you can enter the container once and then run all the tests inside 
the container environment

Execute the following command to enter the container:

    docker exec -it webserver bash

> You might need to use sudo to run docker commands:
>
>>    sudo docker exec -it webserver bash

Inside the container, execute the following commands:

    cwl-runner /dependencies/examples/1st-tool.cwl /dependencies/examples/echo-job.yaml
    cwl-runner /dependencies/examples/pi.cwl --iterations 1000
    cwl-runner /dependencies/examples/rpi.cwl --script /dependencies/r_sample_project/rpi.R --iterations 1000


## Testing Airflow User Interface
                                           
### Preparation

1. Point your browser to http://localhost:8080
                                          
2. Log in with the username and passowrd you have defined by 

        _AIRFLOW_WWW_USER_USERNAME
        _AIRFLOW_WWW_USER_PASSWORD
                             
    environment variables (default `airflow/airflow`).

3. Go to the DAGs Tab and **enable** all dags (at least `1st-tool` and `pi`)
                                        
### UI Test 1: basic CWL (Hello World)

4. Click Play button to the right of the DAG name `1st-tool`

5. Enter the following code into  box:

        {
          "job": {
             "message": "Hello World"
          }
        }
6. Click `Trigger` button
7. Examine the Graph and the Log for the "Hello World" result.

### UI Test 2: CWL, using python project 

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

### UI Test 3: CWL, using R script 

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

