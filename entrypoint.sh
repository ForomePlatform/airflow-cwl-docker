#!/bin/bash --login
set -e
export CONDA_ENV=NSAPHclimate
export PATH=${HOME}/anaconda/condabin/:$PATH:${HOME}/anaconda/envs/${CONDA_ENV}/bin:${HOME}/anaconda/bin
# activate conda environment and let the following process take over
source /root/anaconda/etc/profile.d/conda.sh
conda activate ${HOME}/anaconda/envs/${CONDA_ENV}
exec "$@"