#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
inputs:
  iterations:
    type: string
outputs: []

steps:
  calculate:
    run:
      class: CommandLineTool
      baseCommand: python
      inputs:
        iterations:
          type: string
          inputBinding:
            position: 1

      arguments:
        - valueFrom: pi
          prefix: -m

      outputs: []
    in:
      iterations: iterations
    out: []
