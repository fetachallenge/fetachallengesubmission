# $bids_input and $participants should be defined
# in the script that calls this one or as environment
# variables specified before running the script

# Define output directory
output="$bids_input"/derivatives/predictions/"$teamname"

# Iterate through all evaluation data
# and run src/inference.sh script on each
# subject's image

total_subjects=$(ls -d "$bids_input"/sub-* | wc -l)
echo "Total subjects: $total_subjects"

for subject_dir in "$bids_input"/sub-*; do
    # Find T2w image path
    t2w_image=$(find "$subject_dir" -name "*_T2w.nii.gz")
    # Create output directory and set file paths
    output_dir="$output/$(basename $subject_dir)/anat"
    mkdir -p "$output_dir"
    output_biom="$output_dir/$(basename $t2w_image .nii.gz)_biom.csv"
    output_landm="$output_dir/$(basename $t2w_image .nii.gz)_meas.nii.gz"
    output_seg="$output_dir/$(basename $t2w_image .nii.gz)_dseg.nii.gz"

    echo "Processing $t2w_image"
    # Run inference script
    . src/inference.sh
done | tqdm --total $total_subjects --unit "subject" --unit_scale --dynamic_ncols >> /dev/null
