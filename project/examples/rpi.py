#!/usr/bin/env python3
from cwl_airflow.extensions.cwldag import CWLDAG

args = {
    "cwl": {
        "debug": True,
        "parallel": True
    }
}

dag = CWLDAG(
    workflow="/opt/airflow/project/examples/rpi.cwl",
    dag_id="rpi",
    default_args=args
)