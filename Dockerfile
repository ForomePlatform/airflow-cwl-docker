FROM apache/airflow:2.0.2
USER root
COPY --chown=airflow:airflow install_cwl_airflow /usr/bin/install_cwl_airflow
#COPY --chown=airflow:airflow cwl-airflow.zip /cwl-airflow.zip
RUN apt-get update && apt-get install -y git ca-certificates && update-ca-certificates --fresh && chmod a+rx /usr/bin/install_cwl_airflow
ENV PYTHONPATH=$PYTHONPATH:/home/airflow/.local/lib/python3.6/site-packages
USER airflow
RUN install_cwl_airflow
