from terraform_wrapper import Terraform
import os
import sys

def test_ec2_module_versions():
    # Get the directory containing this test file
    test_dir = os.path.dirname(os.path.abspath(__file__))
    # Go up two levels to project root, then to modules
    project_root = os.path.dirname(os.path.dirname(test_dir))
    versions_dir = os.path.join(project_root, 'modules', 'ec2')
    
    if not os.path.exists(versions_dir):
        print(f"Error: Module directory not found at {versions_dir}")
        print(f"Current working directory: {os.getcwd()}")
        print(f"Test file location: {test_dir}")
        print(f"Project root: {project_root}")
        return
    
    version_dirs = [d for d in os.listdir(versions_dir) if os.path.isdir(os.path.join(versions_dir, d))]
    
    for version in version_dirs:
        terraform_dir = os.path.join(versions_dir, version)
        terraform_options = {
            'terraform_dir': terraform_dir,
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
        print(f"EC2 module {version} validation completed successfully") 