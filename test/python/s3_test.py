import pytest
from terraform_wrapper import Terraform
import os

def test_s3_module_versions():
    # Get all version directories
    versions_dir = '../modules/s3'
    version_dirs = [d for d in os.listdir(versions_dir) if os.path.isdir(os.path.join(versions_dir, d))]
    
    for version in version_dirs:
        with pytest.subTest(version=version):
            # Configure Terraform options for this version
            terraform_options = {
                'terraform_dir': f'../modules/s3/{version}',
                'vars': {
                    'environment_name': f'test-s3-{version.replace(".", "-")}'
                },
                'env_vars': {
                    'AWS_ACCESS_KEY_ID': 'test',
                    'AWS_SECRET_ACCESS_KEY': 'test',
                    'AWS_REGION': 'us-east-1',
                    'AWS_ENDPOINT_URL_S3': 'http://localhost:4566'
                }
            }

            # Use context manager for proper cleanup
            with Terraform(**terraform_options) as tf:
                try:
                    # Initialize and apply
                    tf.init()
                    tf.apply()
                    
                    # Get outputs and validate
                    bucket_name = tf.output('bucket_name')
                    bucket_arn = tf.output('bucket_arn')
                    example_output = tf.output('example_output')
                    
                    assert bucket_name is not None, "bucket_name output should exist"
                    assert bucket_arn is not None, "bucket_arn output should exist"
                    assert example_output == 'ok', "example_output should be 'ok'"
                    
                finally:
                    # Ensure cleanup
                    try:
                        tf.destroy()
                    except Exception as e:
                        print(f"Warning: Terraform destroy failed: {e}") 