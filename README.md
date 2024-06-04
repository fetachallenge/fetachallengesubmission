# [FeTA: Fetal Tissue Annotation and Segmentation Challenge in MICCAI 2024](https://fetachallenge.github.io/)
## Docker Submission Guidelines and Template

Use this repository to build your Docker container for the FeTA challenge. Your Docker container will be used to evaluate your algorithm on the test data.

**Please read the following instructions carefully to learn how to integrate your solution with this template. Using this template for submission is mandatory.**

> **Note:**
> Docker containers are chosen for evaluation to ensure reproducibility and simplify execution across different platforms and environments. This repository provides a simple Docker container definition example for solutions based on Python and Pytorch. Refer to the [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/) and [Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) for more information.

Below is a step-by-step guide on building your Docker container.

## Step 1: Develop Your Algorithm

### 1.1 Choose Your Framework and Track Dependencies
You can use any framework or programming language to develop your solution for the FeTA challenge, as long as your final model can be containerized and follows our guidelines for running and input/output formatting.

Submit the inference code that will be used to evaluate your algorithm on the test data. The inference code should:
- Read the input image and metadata file
- Process the image
- Save the result in the output directory

Store your final code in the `src` directory and the final weights in the `weights` directory.

Keep track of your environment and dependencies during development. This information will be necessary for building the Docker container and determining the base image.

For Python solutions, we recommend using a virtual environment to manage dependencies. Use the following commands to create one and save its configuration:

```bash
# Create and activate a virtual environment
conda create -n fetachallenge
conda activate fetachallenge

# Install required packages for training and inference
# ...

# Save the environment configuration to a file
pip freeze > requirements.txt
```

The base image for the Docker container should be compatible with your development environment. For example, see the [Dockerfile](Dockerfile) in the repository that uses the `nvcr.io/nvidia/pytorch` base image. Modify if needed the Dockerfile to match your solution's requirements.

### 1.2 Prepare for Inference
**After developing your algorithm, prepare the inference code as a command-line tool for evaluation on test data.**

Edit [`src/inference.sh`](src/inference.sh) to contain the code needed to process a single given subject with your algorithm. **Your command-line tool should accept the following named arguments**:
- `t2w_image`: Path to the input image. The image is a 3D T2-weighted MRI of the fetal brain in NIfTI format, same as in the training dataset.
- `participants`: [OPTIONAL] Path to a `participants.tsv` file containing meta-information of gestational age and pathology for each subject. It will follow exactly the same format as the `participants.tsv` file in the training dataset and contain information for all test subjects with columns `participant_id`, `Gestational age` (in weeks), and `Pathology` label.
- `output_seg`: [OPTIONAL] Path to save the output segmentation (.nii.gz file). The segmentation should contain integer labels corresponding to target tissues, in the same space and dimensions as the input image.
- `output_biom`: [OPTIONAL] Path to save the output biometry values (in a TSV file). The file should contain predicted biometry measurements in millimetres (mm) for the given subject in columns `LCC`, `HV`, `bBIP`, `sBIP`, and `TCD`. The file should follow exactly the same formatting as the `biometry.tsv` file in the training dataset, but with predicted values for a single subject.
- `output_landm`: [OPTIONAL] Path to save the output biometry landmarks (in a NIfTI file) in a format similar to the `sub-0XX_rec-xxx_meas.nii.gz` files. The landmarks should be in the same space and have the same dimensions as the input SR image (e.g. they should **not** be in the transformed space unlike `sub-0XX_rec-xxx_meas.nii.gz`). This is an optional output for the biometry task that will not be used for ranking.

Ensure the correct environment and dependencies are loaded in the inference script.

**If you are participating in only one of the challenges, modify the [`inference.sh`](src/inference.sh) script to accept only the relevant arguments for you. During inference, all arguments mentioned above will be available through corresponding variables, meaning that you could access their values in your `inference.sh` script through $<variable_name>**

For example, if you are using Python, we recommend first defining a Python script for inference. See [`src/test.py`](src/test.py) where we have defined a dummy example of such a script, that handles input and output arguments, runs dummy inference and saves outputs in the correct format. Running the script from `inference.sh` should be as simple as:

```bash
python src/test.py --input $t2w_image --participants $participants --output_seg $output_seg --output_biom $output_biom $output_landm --output_biom $output_landm
```
**Notice how we are passing the named arguments values as variables. Your `inference.sh` should use the same approach and format.**

We recommend you test your inference code on an example from the training data to ensure it works as expected. After all the development and testing is done, you can proceed to the final step of containerizing your application.


## Step 2: Build the Docker Container

### 2.1 Docker Dependencies
Ensure Docker is installed on your machine. You can download and install Docker from the official [website](https://docs.docker.com/engine/install/).

Define the Dockerfile to build the Docker container. The Dockerfile is a text document containing commands to assemble and build a Docker image.

We provide an example [Dockerfile](Dockerfile) for Python-PyTorch solutions. It is based on the [nvcr.io/nvidia/pytorch](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/pytorch) base image, optimized for GPU-accelerated training and inference with CUDA. Modify the Dockerfile to match your solution's requirements if needed.

You can build the Docker container using:

```bash
docker build -t <teamname> .
```

Replace `<teamname>` with your team name. After successful building, ensure your [`src/inference.sh`](src/inference.sh) script is executable from the Docker image:

```bash
sudo docker run --gpus all --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 --privileged -v /path/to/data/locally:/path/to/data/in/docker -e t2w_image=/path/to/data/in/docker/image.nii.gz -e participants=/path/to/data/in/docker/participants.tsv -e output_seg=/path/to/data/in/docker/output_segm.nii.gz -e output_biom=/path/to/data/in/docker/output_biom.csv <teamname> bash src/inference.sh
```

In it, the `-v` parameter maps a local path to a specific location in the Docker container space. The `--gpus all --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 --privileged` arguments enable GPU-accelerated execution. Assignments like `t2w_image=/path/to/data/in/docker/image.nii.gz` pass named arguments to [`src/inference.sh`](src/inference.sh) with paths to input/output files inside the container. Don't forget to adjust the paths to test execution on some training images in the command above.

### 2.2 Evaluation Script
You can also test your Docker container by running the evaluation script on all training data:

```bash
sudo docker run --gpus all --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 --privileged -v /path/to/data/locally:/path/to/data/in/docker -e bids_input="/path/to/feta_2.3" -e participants="/path/to/feta_2.3/participants.tsv" -e teamname=<teamname> <teamname> /bin/bash scripts/run_test.sh
```

This command runs the inference script sequentially on all training data located in a given BIDS formatted `bids_input` directory. This same command will be used on the test data during the evaluation phase. Note that for running scripts inside the container you need to pass all variables values with an  `-e` flag.

### 2.3 Save and Submit
Once you successfully build your Docker container, save it to a zipped file and upload it to a cloud platform (e.g., Mega, Google Drive, WeTransfer). Use the following command:

```bash
docker save -o <zip_file_path> <teamname>
```

Submit your algorithm by sending the download link to feta-challenge@googlegroups.com with the subject "FeTA 2024 Submission [TEAMNAME] Docker Container Submission". The deadline for Docker submission is **31st July 2024**.

Please complete and send the submission description form by **12th August 2024**. More information is available here: [FeTA Challenge Algorithm Description](https://fetachallenge.github.io/pages/Submission_instruction).

___

For any questions, please contact the organizing team at feta-challenge@googlegroups.com.
