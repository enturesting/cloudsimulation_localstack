#!/usr/bin/env python3
"""
Simple Dependency Analyzer for Testing (No External Dependencies)
"""

import os
import json
import re
from pathlib import Path
from typing import Dict, List, Set

def analyze_terraform_file(file_path: Path) -> Dict:
    """Analyze a terraform file for module dependencies"""
    dependencies = set()
    resources = {}
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Look for module calls
        module_pattern = r'module\s+"([^"]+)"\s*\{[^}]*source\s*=\s*"([^"]+)"'
        for match in re.finditer(module_pattern, content, re.MULTILINE | re.DOTALL):
            module_name = match.group(1)
            source = match.group(2)
            
            # Extract module type from source path
            if '../modules/' in source:
                module_match = re.search(r'\.\.\/modules\/([^\/]+)', source)
                if module_match:
                    dependencies.add(module_match.group(1))
            elif '../../' in source and '/' in source:
                # Handle relative paths like "../../dynamodb/v0.2.0"
                parts = source.split('/')
                if len(parts) >= 2:
                    dependencies.add(parts[-2])
        
        # Look for resources
        resource_pattern = r'resource\s+"([^"]+)"\s+"([^"]+)"'
        for match in re.finditer(resource_pattern, content):
            resource_type = match.group(1)
            resource_name = match.group(2)
            if resource_type not in resources:
                resources[resource_type] = 0
            resources[resource_type] += 1
        
        return {
            'dependencies': list(dependencies),
            'resources': resources
        }
        
    except Exception as e:
        print(f"Error analyzing {file_path}: {e}")
        return {'dependencies': [], 'resources': {}}

def analyze_modules(modules_dir: str) -> Dict:
    """Analyze all modules and their dependencies"""
    print("Analyzing module dependencies...")
    
    modules_path = Path(modules_dir)
    analysis = {}
    
    for module_path in modules_path.iterdir():
        if module_path.is_dir() and not module_path.name.startswith('.'):
            module_name = module_path.name
            analysis[module_name] = {}
            
            # Analyze each version
            for version_path in module_path.iterdir():
                if version_path.is_dir() and version_path.name.startswith('v'):
                    version = version_path.name
                    
                    # Analyze main terraform files
                    version_analysis = {
                        'dependencies': set(),
                        'resources': {},
                        'examples': []
                    }
                    
                    # Analyze main module files
                    for tf_file in version_path.glob('*.tf'):
                        file_analysis = analyze_terraform_file(tf_file)
                        version_analysis['dependencies'].update(file_analysis['dependencies'])
                        for resource_type, count in file_analysis['resources'].items():
                            version_analysis['resources'][resource_type] = version_analysis['resources'].get(resource_type, 0) + count
                    
                    # Analyze examples
                    examples_dir = version_path / 'examples'
                    if examples_dir.exists():
                        for example_file in examples_dir.glob('*.tf'):
                            example_analysis = analyze_terraform_file(example_file)
                            version_analysis['examples'].append({
                                'name': example_file.stem,
                                'dependencies': example_analysis['dependencies'],
                                'resources': example_analysis['resources']
                            })
                    
                    # Convert set to list for JSON serialization
                    version_analysis['dependencies'] = list(version_analysis['dependencies'])
                    analysis[module_name][version] = version_analysis
    
    return analysis

def generate_dependency_report(analysis: Dict, output_file: str):
    """Generate dependency analysis report"""
    
    # Calculate summary statistics
    total_modules = len(analysis)
    total_versions = sum(len(versions) for versions in analysis.values())
    
    # Find dependency relationships
    dependency_count = {}
    for module_name, versions in analysis.items():
        for version, version_data in versions.items():
            deps = version_data['dependencies']
            dependency_count[f"{module_name}:{version}"] = len(deps)
    
    # Most common dependencies
    all_deps = []
    for module_name, versions in analysis.items():
        for version, version_data in versions.items():
            all_deps.extend(version_data['dependencies'])
    
    dep_frequency = {}
    for dep in all_deps:
        dep_frequency[dep] = dep_frequency.get(dep, 0) + 1
    
    most_common_deps = sorted(dep_frequency.items(), key=lambda x: x[1], reverse=True)[:5]
    
    # Generate report
    report = {
        'summary': {
            'total_modules': total_modules,
            'total_versions': total_versions,
            'total_dependencies': len(all_deps)
        },
        'modules': analysis,
        'most_common_dependencies': most_common_deps,
        'dependency_counts': dependency_count
    }
    
    with open(output_file, 'w') as f:
        json.dump(report, f, indent=2)
    
    return report

def main():
    modules_dir = '../modules'
    output_dir = 'visualizations'
    
    # Create output directory
    Path(output_dir).mkdir(exist_ok=True)
    
    print("Starting dependency analysis...")
    
    # Analyze modules
    analysis = analyze_modules(modules_dir)
    
    if not analysis:
        print("No modules found to analyze")
        return
    
    print(f"Found {len(analysis)} module types")
    
    # Generate report
    report_file = Path(output_dir) / 'dependency_analysis.json'
    report = generate_dependency_report(analysis, str(report_file))
    
    print(f"Analysis complete! Report saved to: {report_file}")
    print(f"Total modules: {report['summary']['total_modules']}")
    print(f"Total versions: {report['summary']['total_versions']}")
    print(f"Total dependencies: {report['summary']['total_dependencies']}")
    
    if report['most_common_dependencies']:
        print("\nMost common dependencies:")
        for dep, count in report['most_common_dependencies']:
            print(f"  {dep}: {count} references")

if __name__ == '__main__':
    main()