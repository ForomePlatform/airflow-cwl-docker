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

echo "Installing Anaconda"
echo https_proxy=${https_proxy}   HTTPS_PROXY="${HTTPS_PROXY}"
wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh -O anaconda.sh
chmod a+x ./anaconda.sh
bash ./anaconda.sh -b -p ${HOME}/anaconda
export PATH=${HOME}/anaconda/condabin:$PATH
echo "Activating conda"
eval "$(conda shell.bash hook)"
conda init
conda config --set auto_activate_base False
source ~/.bashrc
pip3 uninstall -y typing
echo 'Installing cwl-airflow in the base environment'
conda activate base
pushd /cwl-airflow || exit
pip3 install pathlib
pip3 install .
pip3 install -r requirements.txt
popd || exit
conda deactivate
echo 'Installing conda environments'
cd /dependencies/ || exit
for cenv_file in $(ls . | grep "yml\|yaml")
do
  cenv=${cenv_file%.*}
  echo "Creating $cenv Conda environment"
  #conda create -y --name $cenv  python=3.8
  conda env create -f ${cenv_file}
  source /root/anaconda/etc/profile.d/conda.sh
  echo 'from /root/anaconda/etc/profile.d/conda.sh'
  conda activate ${cenv}
  echo "Installing conda packages"
  conda install -y --name ${cenv} -c conda-forge r-remotes r-optparse numpy scipy dataclasses r rpy2
  if command -v R &> /dev/null
  then
    while read -r package; do
      echo "Installing R package from GitHub: $package"
      export R_SCRIPT_INSTALL1="remotes::install_github(\"$package\", repos='http://cran.us.r-project.org')"
      echo "command to install: ${R_SCRIPT_INSTALL1}"
      R -e "${R_SCRIPT_INSTALL1}"
    done < r-github-packages.txt
  fi
  echo "In $cenv Conda environment: "
  install_cwl_airflow.sh
  echo "In $cenv Conda environment: "
  install_projects.sh
  echo '#!/bin/bash' > /usr/bin/RScript
  echo 'exec conda run --no-capture-output -n $CONDA_ENV Rscript "$@"' >> /usr/bin/Rscript
  chmod a+x /usr/bin/Rscript
  conda deactivate
  echo "Installed: $cenv Conda environment"
  conda env list
  #exit
done
