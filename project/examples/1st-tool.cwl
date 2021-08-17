#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
inputs:
  message:
    type: string
outputs: []

steps:
  echo:
    run:
      class: CommandLineTool
      baseCommand: echo
      inputs:
        message:
          type: string
          inputBinding:
            position: 1
      outputs: []
    in:
      message: message
    out: []
