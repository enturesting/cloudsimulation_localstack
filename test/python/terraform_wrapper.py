import subprocess
import os
import json
import tempfile
import shutil
import uuid
from typing import Dict, Any, Optional

class Terraform:
    def __init__(self, terraform_dir: str, vars: Dict[str, Any] = None, env_vars: Dict[str, str] = None):
        self.terraform_dir = terraform_dir
        self.vars = vars or {}
        self.env_vars = env_vars or {}
        self.env = os.environ.copy()
        self.env.update(self.env_vars)
        
        # Create isolated workspace
        self.workspace_id = str(uuid.uuid4())[:8]
        self.temp_dir = tempfile.mkdtemp(prefix=f"tf-test-{self.workspace_id}-")
        self.working_dir = os.path.join(self.temp_dir, "terraform")
        
        # Copy terraform files to isolated workspace
        shutil.copytree(self.terraform_dir, self.working_dir)
        
        # Add isolation variables
        self.vars.update({
            'test_workspace_id': self.workspace_id,
            'test_prefix': f"test-{self.workspace_id}"
        })

    def _run_command(self, command: str, *args) -> str:
        cmd = ['terraform', command] + list(args)
        result = subprocess.run(
            cmd,
            cwd=self.working_dir,
            env=self.env,
            capture_output=True,
            text=True
        )
        if result.returncode != 0:
            raise Exception(f"Terraform command failed: {result.stderr}")
        return result.stdout

    def init(self):
        self._run_command('init')

    def apply(self):
        var_args = []
        for key, value in self.vars.items():
            var_args.extend(['-var', f'{key}={value}'])
        self._run_command('apply', '-auto-approve', *var_args)

    def destroy(self):
        var_args = []
        for key, value in self.vars.items():
            var_args.extend(['-var', f'{key}={value}'])
        self._run_command('destroy', '-auto-approve', *var_args)

    def output(self, name: str) -> Optional[str]:
        try:
            output = self._run_command('output', '-json')
            outputs = json.loads(output)
            return outputs.get(name, {}).get('value')
        except Exception:
            return None 
    
    def cleanup(self):
        """Clean up temporary workspace"""
        if hasattr(self, 'temp_dir') and os.path.exists(self.temp_dir):
            try:
                shutil.rmtree(self.temp_dir)
            except Exception as e:
                print(f"Warning: Failed to cleanup temp directory {self.temp_dir}: {e}")
    
    def __enter__(self):
        return self
        
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.cleanup()