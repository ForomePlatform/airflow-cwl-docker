#!/usr/bin/env python3
from cwl_airflow.extensions.cwldag import CWLDAG

args = {
    "cwl": {
        "debug": True,
        "parallel": True
    }
}

dag = CWLDAG(
    workflow="/opt/airflow/project/examples/1st-tool.cwl",
    dag_id="1st-tool",
    default_args=args
)