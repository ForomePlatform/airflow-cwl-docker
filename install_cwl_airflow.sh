#!/bin/bash

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

echo "Installing cwl-airflow"
cd /cwl-airflow || exit
pip3 install .
pip3 install --upgrade apache-airflow-providers-google
pip3 install --upgrade cwltool cwlref-runner wheel
pip3 install -r requirements.txt
pip3 install psycopg2-binary
pip3 install SQLAlchemy==1.3.23 --force-reinstall
cd ~ || exit