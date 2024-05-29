#!/usr/bin/bash 
# Script to run inference on a single subject

# PLEASE TEST IF IT WORKS BY SETTING THE PATHS
# TO A TRAINING DATA SAMPLE AND RUNNING THIS SCRIPT

# IT SHOULD ACCEPT THE NAMED ARGUMENTS FROM THE 
# VARIABLE DEFINITIONS BELOW ($<variable_name>)
# SO THAT IT CAN BE USED TO RUN A BATCH INFERENCE

python src/test.py --input $t2w_image --participants $participants --output_seg $output_seg --output_biom $output_biom