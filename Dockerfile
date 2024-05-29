# Use an official Python runtime as a parent image
FROM nvcr.io/nvidia/pytorch:24.05-py3

# Copy the current directory contents into the container at /fetachallenge
COPY . /fetachallenge

# Install any needed packages specified in requirements.txt
RUN pip install -r /fetachallenge/requirements.txt &&\
    chmod +x /fetachallenge/src/inference.sh &&\
    chmod +x /fetachallenge/scripts/run_test.sh

# Set the working directory in the container
WORKDIR /fetachallenge

# COMPLETE YOUR INSTALLATION BELOW IF NEEDED