import unittest
from terraform_wrapper import Terraform
import os

class TestIAMModule(unittest.TestCase):
    def test_iam_module_versions(self):
        # Get all version directories
        versions_dir = '../modules/iam'
        version_dirs = [d for d in os.listdir(versions_dir) if os.path.isdir(os.path.join(versions_dir, d))]
        
        for version in version_dirs:
            with self.subTest(version=version):
                # Configure Terraform options for this version
                terraform_options = {
                    'terraform_dir': f'../modules/iam/{version}',
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