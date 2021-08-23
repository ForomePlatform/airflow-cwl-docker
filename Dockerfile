# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#


FROM ubuntu:20.04
USER root
ARG CONDA_CHECK=true
ENV CONDA_CHECK=${CONDA_CHECK}

COPY install_*.sh /usr/bin/
COPY entrypoint.sh /usr/bin/

COPY cwl-airflow /cwl-airflow
COPY requirements.txt /
COPY project /dependencies
COPY r-* /dependencies/

SHELL [ "/bin/bash", "--login" ,"-c" ]
RUN apt-get update && apt-get install -y curl unzip zip wget ca-certificates python3-pip \
 && update-ca-certificates --fresh && chmod a+rx /usr/bin/install_cwl_airflow.sh \
 && chmod -R a+rx /cwl-airflow && \
 curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-20.10.7.tgz \
 && tar xzvf docker-20.10.7.tgz --strip 1 -C /usr/bin docker/docker \
 && rm docker-20.10.7.tgz \
 && chmod a+rx /usr/bin/entrypoint.sh  \
 && chmod a+rx /usr/bin/install_cwl_airflow.sh  /usr/bin/install_conda.sh  /usr/bin/install_projects.sh \
 && ln -s /usr/bin/python3 /usr/bin/python


ENTRYPOINT [ "entrypoint.sh" ]

RUN if [ "$CONDA_CHECK" == "true" ] ; then install_conda.sh ; \
        else python3 -m pip install --upgrade pip && install_cwl_airflow.sh && install_projects.sh ; \
    fi
ENV PATH=$PATH:/root/anaconda/condabin/:$PATH:/root/anaconda/envs/${CONDA_ENV}/bin:/root/anaconda/bin