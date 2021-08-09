#!/usr/bin/env cwl-runner

cwlVersion: v1.0
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
