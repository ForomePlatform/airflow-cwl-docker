FROM apache/airflow:2.0.2
USER root
COPY --chown=airflow:airflow install_cwl_airflow /usr/bin/install_cwl_airflow
COPY --chown=airflow:airflow cwl-airflow /cwl-airflow
RUN apt-get update && apt-get install -y git wget ca-certificates && update-ca-certificates --fresh && chmod a+rx /usr/bin/install_cwl_airflow && chmod -R a+rx /cwl-airflow && curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-20.10.7.tgz && tar xzvf docker-20.10.7.tgz --strip 1 -C /usr/bin docker/docker && rm docker-20.10.7.tgz
ENV PYTHONPATH=$PYTHONPATH:/home/airflow/.local/lib/python3.6/site-packages
USER airflow
RUN install_cwl_airflow
