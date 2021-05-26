FROM apache/airflow:2.0.2
USER root
RUN apt-get update && apt-get install -y git
USER airflow
RUN pip3 install git+https://github.com/Barski-lab/cwl-airflow.git@dependabot/pip/apache-airflow-2.0.2
