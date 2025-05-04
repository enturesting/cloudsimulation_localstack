import unittest
from terraform_wrapper import Terraform
import os

class TestIAMModule(unittest.TestCase):
    def test_iam_module(self):
        # Configure Terraform options
        terraform_options = {
            'terraform_dir': '../modules/iam',
            'vars': {
                'environment_name': 'test'
            },
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
            self.assertIsNotNone(output)
            self.assertNotEqual(output, '')
            
        finally:
            # Cleanup
            tf.destroy()

if __name__ == '__main__':
    unittest.main() 