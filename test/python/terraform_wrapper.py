import subprocess
import os
import json
from typing import Dict, Any, Optional

class Terraform:
    def __init__(self, terraform_dir: str, vars: Dict[str, Any] = None, env_vars: Dict[str, str] = None):
        self.terraform_dir = terraform_dir
        self.vars = vars or {}
        self.env_vars = env_vars or {}
        self.env = os.environ.copy()
        self.env.update(self.env_vars)

    def _run_command(self, command: str, *args) -> str:
        cmd = ['terraform', command] + list(args)
        result = subprocess.run(
            cmd,
            cwd=self.terraform_dir,
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