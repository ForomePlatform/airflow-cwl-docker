#!/bin/bash --login

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
if [ "$conda" = "true" ] ;
then
    set -e
    export PATH=${HOME}/anaconda/condabin/:$PATH:${HOME}/anaconda/envs/${CONDA_ENV}/bin:${HOME}/anaconda/bin
# activate conda environment and let the following process take over
    #exec conda run --no-capture-output -n ${CONDA_ENV} airflow users create --username $_AIRFLOW_WWW_USER_USERNAME --password $_AIRFLOW_WWW_USER_PASSWORD -r Admin -e 1@example.com -f Airflow -l Airflow
    #exec conda run --no-capture-output -n ${CONDA_ENV} airflow db upgrade
    exec conda run --no-capture-output -n ${CONDA_ENV} "$@"

else
    airflow users create --username $_AIRFLOW_WWW_USER_USERNAME --password $_AIRFLOW_WWW_USER_PASSWORD -r Admin
    airflow db upgrade
    exec "$@"
fi