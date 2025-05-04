import pytest
from python_terratest import Terraform
import os

def test_kms_module_versions():
    # Get all version directories
    versions_dir = '../modules/kms'
    version_dirs = [d for d in os.listdir(versions_dir) if os.path.isdir(os.path.join(versions_dir, d))]
    
    for version in version_dirs:
        with pytest.subTest(version=version):
            # Configure Terraform options for this version
            terraform_options = {
                'terraform_dir': f'../modules/kms/{version}',
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