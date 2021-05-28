FROM apache/airflow:2.0.2
USER root
RUN apt-get update && apt-get install -y git
ENV PYTHONPATH=$PYTHONPATH:/home/airflow/.local/lib/python3.6/site-packages
USER airflow
RUN pip3 install git+https://github.com/Barski-lab/cwl-airflow.git@master
