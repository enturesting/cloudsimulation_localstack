#!/usr/bin/env python3
"""
Terraform Security Scanner

This script performs automated security analysis on Terraform modules:
- Detects common security misconfigurations
- Checks for exposed sensitive data
- Validates IAM policies and permissions
- Scans for compliance violations
- Generates security reports with recommendations

Integrates with tools like tfsec, checkov, and terrascan when available.
"""

import os
import json
import re
import subprocess
import argparse
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass, asdict
from datetime import datetime
import hcl2

@dataclass
class SecurityFinding:
    """Represents a security finding"""
    severity: str  # CRITICAL, HIGH, MEDIUM, LOW, INFO
    rule_id: str
    rule_name: str
    description: str
    file_path: str
    line_number: int
    resource_type: str
    resource_name: str
    recommendation: str
    cwe_id: Optional[str] = None
    
class TerraformSecurityScanner:
    def __init__(self, modules_dir: str):
        self.modules_dir = Path(modules_dir)
        self.findings = []
        self.rules = self._load_security_rules()
        
    def _load_security_rules(self) -> Dict:
        """Load security rules for scanning"""
        return {
            'aws_s3_bucket': [
                {
                    'id': 'S3_001',
                    'name': 'S3 Bucket Public Read',
                    'severity': 'HIGH',
                    'description': 'S3 bucket allows public read access',
                    'pattern': r'public-read|public-read-write',
                    'recommendation': 'Restrict bucket ACL to private or use bucket policies for controlled access'
                },
                {
                    'id': 'S3_002',
                    'name': 'S3 Bucket Encryption',
                    'severity': 'MEDIUM',
                    'description': 'S3 bucket encryption is not enabled',
                    'check': 'missing_encryption',
                    'recommendation': 'Enable server-side encryption using AES256 or KMS'
                },
                {
                    'id': 'S3_003',
                    'name': 'S3 Bucket Versioning',
                    'severity': 'LOW',
                    'description': 'S3 bucket versioning is not enabled',
                    'check': 'missing_versioning',
                    'recommendation': 'Enable versioning for data protection and compliance'
                }
            ],
            'aws_iam_role': [
                {
                    'id': 'IAM_001',
                    'name': 'IAM Overly Permissive Policy',
                    'severity': 'CRITICAL',
                    'description': 'IAM policy grants excessive permissions',
                    'pattern': r'\*.*\*',
                    'recommendation': 'Apply principle of least privilege with specific actions and resources'
                },
                {
                    'id': 'IAM_002',
                    'name': 'IAM Admin Access',
                    'severity': 'HIGH',
                    'description': 'IAM policy grants administrative access',
                    'pattern': r'AdministratorAccess|arn:aws:iam::aws:policy/.*Admin.*',
                    'recommendation': 'Use more restrictive policies based on actual requirements'
                }
            ],
            'aws_security_group': [
                {
                    'id': 'SG_001',
                    'name': 'Security Group Open to World',
                    'severity': 'CRITICAL',
                    'description': 'Security group allows unrestricted inbound access',
                    'pattern': r'0\.0\.0\.0/0',
                    'recommendation': 'Restrict access to specific IP ranges or security groups'
                },
                {
                    'id': 'SG_002',
                    'name': 'Security Group SSH Access',
                    'severity': 'HIGH',
                    'description': 'Security group allows SSH access from anywhere',
                    'check': 'ssh_anywhere',
                    'recommendation': 'Restrict SSH access to bastion hosts or VPN ranges'
                }
            ],
            'aws_db_instance': [
                {
                    'id': 'RDS_001',
                    'name': 'RDS Public Access',
                    'severity': 'CRITICAL',
                    'description': 'RDS instance is publicly accessible',
                    'pattern': r'publicly_accessible\s*=\s*true',
                    'recommendation': 'Set publicly_accessible to false and use VPC for access'
                },
                {
                    'id': 'RDS_002',
                    'name': 'RDS Encryption',
                    'severity': 'HIGH',
                    'description': 'RDS instance encryption is not enabled',
                    'check': 'missing_encryption',
                    'recommendation': 'Enable encryption at rest using KMS'
                }
            ]
        }
    
    def scan_modules(self) -> List[SecurityFinding]:
        """Scan all modules for security issues"""
        print("🔒 Starting security scan of Terraform modules...")
        
        for module_path in self.modules_dir.iterdir():
            if module_path.is_dir() and not module_path.name.startswith('.'):
                self._scan_module_type(module_path)
        
        return self.findings
    
    def _scan_module_type(self, module_path: Path):
        """Scan all versions of a module type"""
        module_name = module_path.name
        print(f"🔍 Scanning module: {module_name}")
        
        for version_path in module_path.iterdir():
            if version_path.is_dir() and version_path.name.startswith('v'):
                self._scan_module_version(module_name, version_path)
    
    def _scan_module_version(self, module_name: str, version_path: Path):
        """Scan a specific module version"""
        version = version_path.name
        
        # Scan Terraform files
        for tf_file in version_path.glob('*.tf'):
            self._scan_terraform_file(module_name, version, tf_file)
        
        # Scan example files
        examples_dir = version_path / 'examples'
        if examples_dir.exists():
            for example_file in examples_dir.glob('*.tf'):
                self._scan_terraform_file(f"{module_name}/examples", version, example_file)
    
    def _scan_terraform_file(self, module_name: str, version: str, tf_file: Path):
        """Scan a Terraform file for security issues"""
        try:
            with open(tf_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Parse HCL content
            try:
                parsed = hcl2.loads(content)
            except Exception as e:
                print(f"⚠️  Failed to parse {tf_file}: {e}")
                return
            
            # Scan resources
            if 'resource' in parsed:
                for resource_type, resource_instances in parsed['resource'].items():
                    if resource_type in self.rules:
                        for resource_name, resource_config in resource_instances.items():
                            self._scan_resource(
                                module_name, version, tf_file, 
                                resource_type, resource_name, resource_config
                            )
            
            # Scan for hardcoded secrets
            self._scan_for_secrets(module_name, version, tf_file, content)
            
        except Exception as e:
            print(f"⚠️  Error scanning {tf_file}: {e}")
    
    def _scan_resource(self, module_name: str, version: str, tf_file: Path,
                      resource_type: str, resource_name: str, resource_config: Dict):
        """Scan a specific resource for security issues"""
        rules = self.rules.get(resource_type, [])
        
        for rule in rules:
            finding = self._check_rule(
                rule, module_name, version, tf_file,
                resource_type, resource_name, resource_config
            )
            if finding:
                self.findings.append(finding)
    
    def _check_rule(self, rule: Dict, module_name: str, version: str, tf_file: Path,
                   resource_type: str, resource_name: str, resource_config: Dict) -> Optional[SecurityFinding]:
        """Check a specific security rule against a resource"""
        
        # Pattern-based checks
        if 'pattern' in rule:
            config_str = json.dumps(resource_config, indent=2)
            if re.search(rule['pattern'], config_str, re.IGNORECASE):
                return SecurityFinding(
                    severity=rule['severity'],
                    rule_id=rule['id'],
                    rule_name=rule['name'],
                    description=rule['description'],
                    file_path=str(tf_file),
                    line_number=0,  # TODO: Extract actual line number
                    resource_type=resource_type,
                    resource_name=resource_name,
                    recommendation=rule['recommendation']
                )
        
        # Custom checks
        if 'check' in rule:
            check_result = self._perform_custom_check(rule['check'], resource_config)
            if check_result:
                return SecurityFinding(
                    severity=rule['severity'],
                    rule_id=rule['id'],
                    rule_name=rule['name'],
                    description=rule['description'],
                    file_path=str(tf_file),
                    line_number=0,
                    resource_type=resource_type,
                    resource_name=resource_name,
                    recommendation=rule['recommendation']
                )
        
        return None
    
    def _perform_custom_check(self, check_type: str, resource_config: Dict) -> bool:
        """Perform custom security checks"""
        if check_type == 'missing_encryption':
            # Check for encryption settings
            encryption_keys = ['encrypted', 'encryption', 'server_side_encryption_configuration']
            return not any(key in str(resource_config).lower() for key in encryption_keys)
        
        elif check_type == 'missing_versioning':
            # Check for versioning settings
            return 'versioning' not in str(resource_config).lower()
        
        elif check_type == 'ssh_anywhere':
            # Check for SSH access from anywhere
            config_str = json.dumps(resource_config, indent=2)
            return ('22' in config_str and '0.0.0.0/0' in config_str)
        
        return False
    
    def _scan_for_secrets(self, module_name: str, version: str, tf_file: Path, content: str):
        """Scan for hardcoded secrets and sensitive data"""
        secret_patterns = {
            'AWS_ACCESS_KEY': r'AKIA[0-9A-Z]{16}',
            'AWS_SECRET_KEY': r'[A-Za-z0-9/+=]{40}',
            'PASSWORD': r'password\s*=\s*["\'][^"\']+["\']',
            'API_KEY': r'api[_-]?key\s*[=:]\s*["\'][^"\']+["\']',
            'SECRET': r'secret\s*[=:]\s*["\'][^"\']+["\']',
            'TOKEN': r'token\s*[=:]\s*["\'][^"\']+["\']',
            'PRIVATE_KEY': r'-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----'
        }
        
        lines = content.split('\n')
        for line_num, line in enumerate(lines, 1):
            # Skip comments and variable references
            if line.strip().startswith('#') or '${var.' in line or '${local.' in line:
                continue
            
            for secret_type, pattern in secret_patterns.items():
                if re.search(pattern, line, re.IGNORECASE):
                    self.findings.append(SecurityFinding(
                        severity='CRITICAL',
                        rule_id='SEC_001',
                        rule_name=f'Hardcoded {secret_type}',
                        description=f'Potential hardcoded {secret_type.lower()} detected',
                        file_path=str(tf_file),
                        line_number=line_num,
                        resource_type='variable',
                        resource_name='hardcoded_secret',
                        recommendation='Use Terraform variables, AWS Secrets Manager, or environment variables'
                    ))

class SecurityReportGenerator:
    def __init__(self, findings: List[SecurityFinding]):
        self.findings = findings
    
    def generate_report(self, output_format: str = 'json', output_file: str = 'security_report.json') -> str:
        """Generate security report in specified format"""
        
        if output_format == 'json':
            return self._generate_json_report(output_file)
        elif output_format == 'html':
            return self._generate_html_report(output_file)
        elif output_format == 'sarif':
            return self._generate_sarif_report(output_file)
        else:
            raise ValueError(f"Unsupported output format: {output_format}")
    
    def _generate_json_report(self, output_file: str) -> str:
        """Generate JSON security report"""
        
        # Categorize findings by severity
        severity_counts = {}
        for finding in self.findings:
            severity_counts[finding.severity] = severity_counts.get(finding.severity, 0) + 1
        
        report = {
            'scan_metadata': {
                'scan_time': datetime.now().isoformat(),
                'total_findings': len(self.findings),
                'severity_counts': severity_counts
            },
            'summary': {
                'critical_issues': severity_counts.get('CRITICAL', 0),
                'high_issues': severity_counts.get('HIGH', 0),
                'medium_issues': severity_counts.get('MEDIUM', 0),
                'low_issues': severity_counts.get('LOW', 0),
                'info_issues': severity_counts.get('INFO', 0)
            },
            'findings': [asdict(finding) for finding in self.findings],
            'recommendations': self._generate_recommendations()
        }
        
        with open(output_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        return output_file
    
    def _generate_html_report(self, output_file: str) -> str:
        """Generate HTML security report"""
        
        # Group findings by severity
        findings_by_severity = {}
        for finding in self.findings:
            if finding.severity not in findings_by_severity:
                findings_by_severity[finding.severity] = []
            findings_by_severity[finding.severity].append(finding)
        
        html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Terraform Security Scan Report</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 40px; }}
        .header {{ background: #f4f4f4; padding: 20px; border-radius: 8px; }}
        .severity-critical {{ border-left: 5px solid #d73a49; }}
        .severity-high {{ border-left: 5px solid #f66a0a; }}
        .severity-medium {{ border-left: 5px solid #ffd33d; }}
        .severity-low {{ border-left: 5px solid #28a745; }}
        .finding {{ margin: 15px 0; padding: 15px; background: #f8f9fa; border-radius: 5px; }}
        .rule-id {{ font-weight: bold; color: #0366d6; }}
        .file-path {{ font-family: monospace; font-size: 0.9em; color: #586069; }}
        .recommendation {{ margin-top: 10px; padding: 10px; background: #e1f5fe; border-radius: 3px; }}
        .summary {{ display: flex; justify-content: space-around; margin: 20px 0; }}
        .summary-item {{ text-align: center; padding: 15px; background: #f4f4f4; border-radius: 8px; }}
        .count {{ font-size: 2em; font-weight: bold; }}
    </style>
</head>
<body>
    <div class="header">
        <h1>🔒 Terraform Security Scan Report</h1>
        <p>Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
        <p>Total findings: {len(self.findings)}</p>
    </div>
    
    <div class="summary">
        <div class="summary-item">
            <div class="count" style="color: #d73a49;">{len([f for f in self.findings if f.severity == 'CRITICAL'])}</div>
            <div>Critical</div>
        </div>
        <div class="summary-item">
            <div class="count" style="color: #f66a0a;">{len([f for f in self.findings if f.severity == 'HIGH'])}</div>
            <div>High</div>
        </div>
        <div class="summary-item">
            <div class="count" style="color: #ffd33d;">{len([f for f in self.findings if f.severity == 'MEDIUM'])}</div>
            <div>Medium</div>
        </div>
        <div class="summary-item">
            <div class="count" style="color: #28a745;">{len([f for f in self.findings if f.severity == 'LOW'])}</div>
            <div>Low</div>
        </div>
    </div>
"""
        
        for severity in ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'INFO']:
            if severity in findings_by_severity:
                html_content += f"<h2>{severity} Issues ({len(findings_by_severity[severity])})</h2>\n"
                
                for finding in findings_by_severity[severity]:
                    html_content += f"""
    <div class="finding severity-{severity.lower()}">
        <div class="rule-id">{finding.rule_id}: {finding.rule_name}</div>
        <div><strong>Resource:</strong> {finding.resource_type}.{finding.resource_name}</div>
        <div class="file-path"><strong>File:</strong> {finding.file_path}:{finding.line_number}</div>
        <div><strong>Description:</strong> {finding.description}</div>
        <div class="recommendation"><strong>Recommendation:</strong> {finding.recommendation}</div>
    </div>
"""
        
        html_content += """
</body>
</html>
"""
        
        with open(output_file, 'w') as f:
            f.write(html_content)
        
        return output_file
    
    def _generate_sarif_report(self, output_file: str) -> str:
        """Generate SARIF format report for integration with security tools"""
        
        sarif_report = {
            "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
            "version": "2.1.0",
            "runs": [
                {
                    "tool": {
                        "driver": {
                            "name": "Terraform Security Scanner",
                            "version": "1.0.0",
                            "informationUri": "https://github.com/your-org/terraform-security-scanner"
                        }
                    },
                    "results": []
                }
            ]
        }
        
        for finding in self.findings:
            severity_level = {
                'CRITICAL': 'error',
                'HIGH': 'error', 
                'MEDIUM': 'warning',
                'LOW': 'note',
                'INFO': 'none'
            }.get(finding.severity, 'warning')
            
            result = {
                "ruleId": finding.rule_id,
                "message": {"text": finding.description},
                "level": severity_level,
                "locations": [
                    {
                        "physicalLocation": {
                            "artifactLocation": {"uri": finding.file_path},
                            "region": {"startLine": finding.line_number}
                        }
                    }
                ]
            }
            
            sarif_report["runs"][0]["results"].append(result)
        
        with open(output_file, 'w') as f:
            json.dump(sarif_report, f, indent=2)
        
        return output_file
    
    def _generate_recommendations(self) -> List[str]:
        """Generate prioritized security recommendations"""
        recommendations = []
        
        critical_count = len([f for f in self.findings if f.severity == 'CRITICAL'])
        high_count = len([f for f in self.findings if f.severity == 'HIGH'])
        
        if critical_count > 0:
            recommendations.append(f"🚨 Address {critical_count} critical security issues immediately")
        
        if high_count > 0:
            recommendations.append(f"⚠️ Review and fix {high_count} high-severity issues")
        
        # Common recommendations based on findings
        rule_counts = {}
        for finding in self.findings:
            rule_counts[finding.rule_id] = rule_counts.get(finding.rule_id, 0) + 1
        
        top_issues = sorted(rule_counts.items(), key=lambda x: x[1], reverse=True)[:3]
        for rule_id, count in top_issues:
            recommendations.append(f"📋 Most common issue: {rule_id} ({count} occurrences)")
        
        recommendations.extend([
            "🔒 Implement infrastructure scanning in CI/CD pipeline",
            "📚 Provide security training for infrastructure team",
            "🔍 Regular security audits and penetration testing",
            "📋 Establish security policies and compliance checks"
        ])
        
        return recommendations

def run_external_scanners(modules_dir: str, output_dir: str) -> Dict:
    """Run external security scanners if available"""
    external_results = {}
    
    # Check for tfsec
    if subprocess.run(['which', 'tfsec'], capture_output=True).returncode == 0:
        print("🔍 Running tfsec...")
        try:
            result = subprocess.run([
                'tfsec', modules_dir, 
                '--format', 'json',
                '--out', f"{output_dir}/tfsec_results.json"
            ], capture_output=True, text=True)
            external_results['tfsec'] = f"{output_dir}/tfsec_results.json"
        except Exception as e:
            print(f"⚠️  tfsec failed: {e}")
    
    # Check for checkov
    if subprocess.run(['which', 'checkov'], capture_output=True).returncode == 0:
        print("🔍 Running checkov...")
        try:
            result = subprocess.run([
                'checkov', '-d', modules_dir,
                '--output', 'json',
                '--output-file', f"{output_dir}/checkov_results.json"
            ], capture_output=True, text=True)
            external_results['checkov'] = f"{output_dir}/checkov_results.json"
        except Exception as e:
            print(f"⚠️  checkov failed: {e}")
    
    return external_results

def main():
    parser = argparse.ArgumentParser(description='Scan Terraform modules for security issues')
    parser.add_argument('--modules-dir', '-m', default='../modules',
                       help='Directory containing Terraform modules')
    parser.add_argument('--output-dir', '-o', default='security_reports',
                       help='Output directory for reports')
    parser.add_argument('--format', '-f', choices=['json', 'html', 'sarif', 'all'], 
                       default='all', help='Output format')
    parser.add_argument('--external', action='store_true',
                       help='Run external scanners (tfsec, checkov) if available')
    
    args = parser.parse_args()
    
    # Create output directory
    output_dir = Path(args.output_dir)
    output_dir.mkdir(exist_ok=True)
    
    print("🔒 Starting Terraform security scan...")
    
    # Run internal scanner
    scanner = TerraformSecurityScanner(args.modules_dir)
    findings = scanner.scan_modules()
    
    if not findings:
        print("✅ No security issues found!")
        return
    
    print(f"⚠️  Found {len(findings)} security issues")
    
    # Generate reports
    report_generator = SecurityReportGenerator(findings)
    
    if args.format in ['json', 'all']:
        json_report = output_dir / 'security_report.json'
        report_generator.generate_report('json', str(json_report))
        print(f"📄 JSON report: {json_report}")
    
    if args.format in ['html', 'all']:
        html_report = output_dir / 'security_report.html'
        report_generator.generate_report('html', str(html_report))
        print(f"🌐 HTML report: {html_report}")
    
    if args.format in ['sarif', 'all']:
        sarif_report = output_dir / 'security_report.sarif'
        report_generator.generate_report('sarif', str(sarif_report))
        print(f"📋 SARIF report: {sarif_report}")
    
    # Run external scanners
    if args.external:
        external_results = run_external_scanners(args.modules_dir, str(output_dir))
        if external_results:
            print("🔍 External scanner results:")
            for tool, result_file in external_results.items():
                print(f"   {tool}: {result_file}")
    
    # Summary
    severity_counts = {}
    for finding in findings:
        severity_counts[finding.severity] = severity_counts.get(finding.severity, 0) + 1
    
    print("\n📊 Security Scan Summary:")
    for severity in ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'INFO']:
        count = severity_counts.get(severity, 0)
        if count > 0:
            emoji = {'CRITICAL': '🚨', 'HIGH': '⚠️', 'MEDIUM': '⚡', 'LOW': '💡', 'INFO': 'ℹ️'}[severity]
            print(f"   {emoji} {severity}: {count}")
    
    print(f"\n📁 Reports saved to: {output_dir}")

if __name__ == '__main__':
    main()