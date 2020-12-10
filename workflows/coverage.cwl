#!/usr/bin/env cwl-runner

cwlVersion: v1.1

class: CommandLineTool
baseCommand: odgi

inputs:
  paths:
    type: string
    inputBinding:
      position: 1

  input_flag:
    type: boolean
    inputBinding:
      position: 2
      prefix: -i

  graph:
    type: File
    inputBinding:
        position: 3

  input_x_flag:
    type: boolean
    inputBinding:
      position: 4
      prefix: -H

outputs:
  coverage_matrix:
    type: stdout

stdout: coverage.tsv