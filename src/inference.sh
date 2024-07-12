#!/usr/bin/bash 
# Script to run inference on a single subject

# PLEASE TEST IF IT WORKS BY SETTING THE PATHS
# TO A TRAINING DATA SAMPLE AND RUNNING THIS SCRIPT
# BY UNCOMMENTING THE LINES BELOW
# t2w_image=/path/to/t2w_image.nii.gz
# participants=/path/to/participants.tsv
# output_seg=/path/to/output_seg.nii.gz
# output_biom=/path/to/output_biom.tsv

# COMMENT BACK THE LINES ABOVE AFTER TESTING
# AS THE SCRIPT SHOULD ONLY ACCEPT THE NAMED ARGUMENTS FROM THE 
# VARIABLE DEFINITIONS BELOW ($<variable_name>)
# SO THAT IT CAN BE USED TO RUN A BATCH INFERENCE

python src/test.py --input $t2w_image --participants $participants --output_seg $output_seg --output_biom $output_biom
