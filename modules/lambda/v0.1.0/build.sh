#!/bin/bash

# Create a virtual environment
python -m venv venv
source venv/Scripts/activate

# Install dependencies
pip install boto3

# Create deployment package
mkdir -p package
cp lambda_function.py package/

# Create zip file using Python
python -c "import shutil; shutil.make_archive('lambda_function', 'zip', 'package')"

# Clean up
rm -rf package venv 