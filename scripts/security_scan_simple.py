#!/usr/bin/env python3
"""
Simple Terraform Security Scanner for Testing
"""

import os
import json
import re
import argparse
from pathlib import Path
from typing import Dict, List, Optional
from dataclasses import dataclass
from datetime import datetime

@dataclass
class SecurityFinding:
    """Represents a security finding"""
    severity: str
    rule_id: str
    rule_name: str
    description: str
    file_path: str
    resource_type: str
    resource_name: str
    recommendation: str

def scan_file_for_secrets(file_path: Path) -> List[SecurityFinding]:
    """Scan a file for potential security issues"""
    findings = []
    
    # Simple patterns for demonstration
    patterns = {
        'HARDCODED_PASSWORD': r'password\s*=\s*["\'][^"\']+["\']',
        'PUBLIC_BUCKET': r'public-read',
        'WILDCARD_POLICY': r'\*.*\*',
        'SSH_ANYWHERE': r'0\.0\.0\.0/0.*22'
    }
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        lines = content.split('\n')
        for line_num, line in enumerate(lines, 1):
            for pattern_name, pattern in patterns.items():
                if re.search(pattern, line, re.IGNORECASE):
                    findings.append(SecurityFinding(
                        severity='HIGH',
                        rule_id=f'SEC_{pattern_name}',
                        rule_name=f'{pattern_name.replace("_", " ").title()}',
                        description=f'Potential {pattern_name.lower()} detected in line {line_num}',
                        file_path=str(file_path),
                        resource_type='unknown',
                        resource_name='unknown',
                        recommendation=f'Review and fix {pattern_name.lower()} issue'
                    ))
    
    except Exception as e:
        print(f"Error scanning {file_path}: {e}")
    
    return findings

def scan_modules(modules_dir: str) -> List[SecurityFinding]:
    """Scan all modules for security issues"""
    print("Starting security scan...")
    findings = []
    
    modules_path = Path(modules_dir)
    for tf_file in modules_path.rglob('*.tf'):
        file_findings = scan_file_for_secrets(tf_file)
        findings.extend(file_findings)
    
    return findings

def generate_report(findings: List[SecurityFinding], output_file: str):
    """Generate JSON security report"""
    severity_counts = {}
    for finding in findings:
        severity_counts[finding.severity] = severity_counts.get(finding.severity, 0) + 1
    
    report = {
        'scan_metadata': {
            'scan_time': datetime.now().isoformat(),
            'total_findings': len(findings)
        },
        'summary': {
            'high_issues': severity_counts.get('HIGH', 0),
            'medium_issues': severity_counts.get('MEDIUM', 0),
            'low_issues': severity_counts.get('LOW', 0)
        },
        'findings': [
            {
                'severity': f.severity,
                'rule_id': f.rule_id,
                'rule_name': f.rule_name,
                'description': f.description,
                'file_path': f.file_path,
                'resource_type': f.resource_type,
                'resource_name': f.resource_name,
                'recommendation': f.recommendation
            }
            for f in findings
        ]
    }
    
    with open(output_file, 'w') as f:
        json.dump(report, f, indent=2)
    
    return output_file

def main():
    parser = argparse.ArgumentParser(description='Simple Terraform security scanner')
    parser.add_argument('--modules-dir', default='../modules', help='Modules directory')
    parser.add_argument('--output-dir', default='security_reports', help='Output directory')
    parser.add_argument('--format', default='json', help='Output format')
    
    args = parser.parse_args()
    
    # Create output directory
    output_dir = Path(args.output_dir)
    output_dir.mkdir(exist_ok=True)
    
    # Scan modules
    findings = scan_modules(args.modules_dir)
    
    print(f"Found {len(findings)} security issues")
    
    # Generate report
    if findings:
        report_file = output_dir / 'security_report.json'
        generate_report(findings, str(report_file))
        print(f"Report saved to: {report_file}")
        
        # Show summary
        severity_counts = {}
        for finding in findings:
            severity_counts[finding.severity] = severity_counts.get(finding.severity, 0) + 1
        
        print("\nSecurity Summary:")
        for severity, count in severity_counts.items():
            print(f"  {severity}: {count}")
    else:
        print("No security issues found!")

if __name__ == '__main__':
    main()