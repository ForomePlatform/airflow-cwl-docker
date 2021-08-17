#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
inputs:
  script:
    type: File
  iterations:
    type: string
outputs: []

steps:
  calculate:
    run:
      class: CommandLineTool
      baseCommand: Rscript
      inputs:
        script:
          type: File
          inputBinding:
            position: 1
        iterations:
          type: string
          inputBinding:
            position: 2

      outputs: []
    in:
      iterations: iterations
      script: script
    out: []



