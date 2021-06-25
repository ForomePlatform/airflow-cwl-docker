FROM ubuntu:20.04
USER root

COPY install_cwl_airflow /usr/bin/install_cwl_airflow
COPY install_conda /usr/bin/install_conda
COPY install_local /usr/bin/install_local

COPY cwl-airflow /cwl-airflow
COPY project /dependencies
COPY entrypoint.sh /usr/bin/entrypoint.sh

SHELL [ "/bin/bash", "--login" ,"-c" ]
RUN apt-get update && apt-get install -y curl unzip zip wget ca-certificates \
 && update-ca-certificates --fresh && chmod a+rx /usr/bin/install_cwl_airflow \
 && chmod -R a+rx /cwl-airflow && \
 curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-20.10.7.tgz \
 && tar xzvf docker-20.10.7.tgz --strip 1 -C /usr/bin docker/docker \
 && rm docker-20.10.7.tgz && mkdir /nsaphutils && chmod -R 777 /nsaphutils \
 && chmod a+rx /usr/bin/entrypoint.sh  \
 && chmod a+rx /usr/bin/install_cwl_airflow  /usr/bin/install_conda  /usr/bin/install_local

ARG CONDA_ENV
ENV CONDA_ENV=${CONDA_ENV}
ENTRYPOINT [ "entrypoint.sh" ]

RUN install_conda
ENV PATH=/root/anaconda/condabin/:$PATH:/root/anaconda/envs/${CONDA_ENV}/bin:/root/anaconda/bin
RUN install_cwl_airflow
#RUN install_local
