#!/usr/bin/env python3
"""
Test the enhanced terraform_wrapper functionality
"""

import tempfile
import os
from terraform_wrapper import Terraform

def test_terraform_wrapper_isolation():
    """Test that the terraform wrapper creates isolated workspaces"""
    
    # Create a minimal terraform file for testing
    with tempfile.TemporaryDirectory() as temp_dir:
        # Write a simple terraform file
        tf_content = '''
resource "null_resource" "test" {
  provisioner "local-exec" {
    command = "echo Hello from test"
  }
}

output "test_output" {
  value = "test_success"
}
'''
        
        tf_file = os.path.join(temp_dir, 'main.tf')
        with open(tf_file, 'w') as f:
            f.write(tf_content)
        
        # Test the wrapper
        terraform_options = {
            'terraform_dir': temp_dir,
            'vars': {'test_var': 'test_value'},
            'env_vars': {
                'TF_LOG': 'ERROR'  # Suppress terraform logs
            }
        }
        
        # Test context manager functionality
        with Terraform(**terraform_options) as tf:
            print(f"Terraform workspace ID: {tf.workspace_id}")
            print(f"Terraform working directory: {tf.working_dir}")
            print(f"Test variables: {tf.vars}")
            
            # Check that workspace directory was created
            assert os.path.exists(tf.working_dir), "Working directory should exist"
            assert os.path.exists(os.path.join(tf.working_dir, 'main.tf')), "Terraform files should be copied"
            
            print("✅ Terraform wrapper isolation test passed!")

if __name__ == '__main__':
    test_terraform_wrapper_isolation()