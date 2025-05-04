import pytest
from python_terratest import Terraform
import os

def test_dynamodb_module():
    # Configure Terraform options
    terraform_options = {
        'terraform_dir': '../modules/dynamodb',
        'vars': {},
        'env_vars': {
            'AWS_ACCESS_KEY_ID': 'test',
            'AWS_SECRET_ACCESS_KEY': 'test',
            'AWS_REGION': 'us-east-1'
        }
    }

    # Initialize Terraform
    tf = Terraform(**terraform_options)
    
    try:
        # Initialize and apply
        tf.init()
        tf.apply()
        
        # Get output
        output = tf.output('example_output')
        assert output is not None
        assert output != ''
        
    finally:
        # Cleanup
        tf.destroy() 