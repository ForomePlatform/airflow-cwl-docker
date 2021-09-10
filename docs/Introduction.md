# Introduction

Data processing workflows consist of multiple steps with each 
step using different tools. These tools and their prerequisites must  
be available in the runtime environment that runs a workflow. Therefore, 
deployment configuration is far from trivial. This package provides 
a way to manage runtime environments for CWL workflows deployed 
on Apache Airflow using CWL-Airflow.

Many data science and bioinformatics applications use 
[Conda](https://docs.conda.io/en/latest/) to manage their
environments. This is especially helpful if some workflow
steps use [R](https://www.r-project.org/about.html) programming language. 
Regardless of whether Conda is already set up on the host system, in order
to be used inside workflows, it has to be installed within the CWL-Airflow
container. Therefore, we provide an option to install 
[Anaconda®](https://repo.anaconda.com/) as part of the setup procedure.

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

