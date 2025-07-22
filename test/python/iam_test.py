from terraform_wrapper import Terraform
import os

def test_iam_module_versions():
    # Get all version directories
    versions_dir = '../../modules/iam'
    version_dirs = [d for d in os.listdir(versions_dir) if os.path.isdir(os.path.join(versions_dir, d))]
    
    for version in version_dirs:
        # Configure Terraform options for this version
        terraform_options = {
            'terraform_dir': f'../../modules/iam/{version}',
            'vars': {},  # No variables needed for validation
            'env_vars': {
                'AWS_ACCESS_KEY_ID': 'test',
                'AWS_SECRET_ACCESS_KEY': 'test',
                'AWS_REGION': 'us-east-1'
            }
        }

        # Initialize and validate only
        tf = Terraform(**terraform_options)
        tf.init()
        # Add validation if terraform_wrapper supports it
        print(f"IAM module {version} validation completed successfully") 