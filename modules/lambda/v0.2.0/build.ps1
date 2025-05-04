# Create a virtual environment
python -m venv venv
.\venv\Scripts\Activate.ps1

# Install dependencies
pip install boto3

# Create deployment package
New-Item -ItemType Directory -Force -Path package
Copy-Item lambda_function.py package/

# Create zip file using Python
python -c "import shutil; shutil.make_archive('lambda_function', 'zip', 'package')"

# Clean up
Remove-Item -Recurse -Force package
Remove-Item -Recurse -Force venv 