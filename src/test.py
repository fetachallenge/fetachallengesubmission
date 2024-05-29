import argparse
from pathlib import Path

import pandas as pd
import SimpleITK as sitk


# parse the arguments
parser = argparse.ArgumentParser(
                    prog='Inference Script for the FeTA Challenge Submission',
                    description='Runs inference on an input image and\
                        saves the output to the a folder',
                    epilog='FeTA 2024 MICCAI Challenge.\
                        More info here: https://fetachallenge.github.io/pages/Submission_instruction')

parser.add_argument('-ii', '--input_image', required=True)
parser.add_argument('-part', '--participants', required=False)
parser.add_argument('-os', '--output_seg', required=True)
parser.add_argument('-ob', '--output_biom', required=True)
parser.add_argument('-ol', '--output_landm', required=False)

args = parser.parse_args()

# DEFINE YOU OWN LOGIC FOR THE INFERENCE
# BELOW IS A DUMMY EXAMPLE
def main():
    # load inputs
    input_image = sitk.ReadImage(args.input_image)
    input_meta = pd.read_csv(args.participants)

    subj = Path(args.input_image).parent.parent.name

    # define dummy outputs
    out_segm = sitk.BinaryThreshold(input_image,
                                    lowerThreshold=100,
                                    upperThreshold=400,
                                    insideValue=1,
                                    outsideValue=0)
    
    out_biom = pd.DataFrame({'LCC': 28.3, 'HV': 12,
                                  'bBIP':61.9,'sBIP':80.02,
                                  'TCD':33.6}, index=[subj])
    if args.output_landm: 
        out_landm = input_image*0
        out_landm[100,100,100] = 1
        sitk.WriteImage(out_landm, args.output_landm)

    # save outputs
    pd.DataFrame.to_csv(out_biom, args.output_biom, sep='\t')
    sitk.WriteImage(out_segm, args.output_seg)

if __name__ == '__main__':
    main()