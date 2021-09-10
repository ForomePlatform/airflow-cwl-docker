# Glossary

<!-- toc -->

- [What is CWL?](#what-is-cwl)
- [What is Airflow](#what-is-airflow)
- [What is CWL-Airflow](#what-is-cwl-airflow)
- [What is Docker](#what-is-docker)
- [What is Docker-compose](#what-is-docker-compose)
- [What is Conda](#what-is-conda)
- [What is PostgreSQL](#what-is-postgresql)

<!-- tocstop -->

### What is CWL?

CWL stands for the [Common Workflow Language](https://www.commonwl.org/) 
Citing the CWL website: 
    
    CWL is an open standard for describing analysis workflows 
    and tools in a way that makes them portable and scalable 
    across a variety of software and hardware environments, 
    from workstations to cluster, cloud, and high performance 
    computing (HPC) environments. CWL is designed to meet the 
    needs of data-intensive science, such as Bioinformatics, 
    Medical Imaging, Astronomy, High Energy Physics, and Machine Learning.
                   

### What is Airflow

[Apache Airflow](https://airflow.apache.org/)
is a platform to programmatically author, schedule and monitor workflows.
It represents workflows as graphs, visualizes them and provides a nice 
Graphical User
Interface (GUI) to manage, control and monitor workflows.

### What is CWL-Airflow

**_CWL-Airflow_** implements CWL by translating CWL workflows into 
[Airflow DAGs](https://airflow.apache.org/docs/apache-airflow/1.10.12/concepts.html#dags), 
hence providing a nice GUI to manage, control and 
monitor **_CWL_** workflows. 

### What is Docker 

[Docker](https://www.docker.com/), is a software framework for managing 
[containers](https://www.docker.com/resources/what-container) on 
servers and the cloud. 

### What is Docker-compose

[Docker-compose](https://docs.docker.com/compose/) is a tool for defining 
and running multi-container Docker applications.  

Airflow uses multiple containers (at least webserver and scheduler) and
also interacts with other applications, such as a RDBMSs where it stores
it state. These applications can also be deployed as containers. We use
docker-compose to orchestrate all required containers. 

### What is Conda

[Conda](https://docs.conda.io/en/latest/)

### What is PostgreSQL

[PostgreSQL](https://www.postgresql.org/)