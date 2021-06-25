#!/bin/bash --login
set -e
export PATH=${HOME}/anaconda/condabin/:$PATH:${HOME}/anaconda/envs/${CONDA_ENV}/bin:${HOME}/anaconda/bin
# activate conda environment and let the following process take over

exec conda run --no-capture-output -n ${CONDA_ENV} "$@"