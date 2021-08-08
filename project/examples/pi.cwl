#!/usr/bin/env cwl-runner

cwlVersion: v1.0
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
