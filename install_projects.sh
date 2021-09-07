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

echo "Installing local projects"
cd /dependencies || exit
# if projects list is not specified, create it by
# listing all folders with setup.py file
PROJECT_LIST="projects.lst"
if [ ! -f ${PROJECT_LIST} ] ; then
  touch ${PROJECT_LIST}
  for dir in */setup.py ; do echo ${dir%/*} >> ${PROJECT_LIST} ; done
fi
# Install all projects
while read -r project; do
  echo "Installing " "$project"
  pushd "$project" || exit
  if [ ! -f setup.py ] ; then
    echo "Not a valid project (no setup.py): " "$project"
  fi
  echo "Building wheel"
  pip3 install . || cd dist && pip3 install *.whl
  popd || exit
done < ${PROJECT_LIST}
cd ~ || exit
echo 'Installed: local projects'