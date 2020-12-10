#!/usr/bin/env cwl-runner

cwlVersion: v1.1

class: CommandLineTool
baseCommand: python

inputs:
    main_py_script:
        type: File
        inputBinding:
            position: 1

    clado-rsvd:
        type: string
        inputBinding:
            position: 2

    cladogram_matrix:
        type: File
        inputBinding:
            position: 3

    reduced_matrix:
        type: string
        inputBinding:
            position: 4

    svg_figure:
        type: string
        inputBinding:
            position: 5

outputs:
    reduced_matrix_out:
        type: File
        outputBinding:
            glob: '*.reduced.tsv'

    svg_figure_out:
        type: File
        outputBinding:
            glob: '*.svg'
    html_figure:
        type: File
        outputBinding:
            glob: '*.html'