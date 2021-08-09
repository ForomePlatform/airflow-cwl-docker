# Examples
                    
These examples will be installed in CWL-Airflow

## Basic CWL
Taken from [Tutorial](https://www.commonwl.org/user_guide/02-1st-example/index.html)

To run independently:

    cwl-runner ${pathToProject}/project/examples/1st-tool.cwl --message Hello    
                                                                             
Or:

    cwl-runner ${pathToProject}/project/examples/1st-tool.cwl  ${pathToProject}/project/examples/echo-job.yaml   

## Using Python project
A sample python project to calculate the number 
Pi is included in these examples. It is installed as a wheel in CWL-Airflow
environment.

To run it as CWL airflow independently, use the following command:

    cwl-runner ${pathToProject}/project/examples/pi.cwl --iterations 1000 

## Using R project
A sample R script to calculate the number Pi using Monte-Carlo simulations
is included in these examples.

To run it as CWL airflow independently, use the following command:

    cwl-runner ${pathToProject}/project/examples/rpi.cwl  --script ${pathToProject}/project/r_sample_project/rpi.R --iterations 1000  
