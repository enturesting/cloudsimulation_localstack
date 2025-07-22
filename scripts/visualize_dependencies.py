#!/usr/bin/env python3
"""
Module Dependency Graph Visualization

This script analyzes Terraform modules and creates a dependency graph showing:
- Module relationships and dependencies
- Resource types and counts
- Version information
- Example usage patterns

Generates both interactive HTML and static PNG visualizations.
"""

import os
import json
import re
import argparse
from pathlib import Path
from typing import Dict, List, Set, Tuple
import networkx as nx
import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots
import hcl2

class TerraformModuleAnalyzer:
    def __init__(self, modules_dir: str):
        self.modules_dir = Path(modules_dir)
        self.modules = {}
        self.dependencies = {}
        
    def analyze_modules(self):
        """Analyze all modules and their dependencies"""
        print("🔍 Analyzing Terraform modules...")
        
        for module_path in self.modules_dir.iterdir():
            if module_path.is_dir() and not module_path.name.startswith('.'):
                self._analyze_module_type(module_path)
                
        self._analyze_dependencies()
        return self.modules, self.dependencies
    
    def _analyze_module_type(self, module_path: Path):
        """Analyze all versions of a module type"""
        module_name = module_path.name
        self.modules[module_name] = {}
        
        for version_path in module_path.iterdir():
            if version_path.is_dir() and version_path.name.startswith('v'):
                version = version_path.name
                self.modules[module_name][version] = self._analyze_module_version(
                    module_name, version, version_path
                )
    
    def _analyze_module_version(self, module_name: str, version: str, version_path: Path) -> Dict:
        """Analyze a specific module version"""
        analysis = {
            'name': module_name,
            'version': version,
            'path': str(version_path),
            'resources': {},
            'variables': {},
            'outputs': {},
            'dependencies': set(),
            'examples': []
        }
        
        # Analyze main.tf
        main_tf = version_path / 'main.tf'
        if main_tf.exists():
            analysis.update(self._analyze_terraform_file(main_tf))
        
        # Analyze variables.tf
        variables_tf = version_path / 'variables.tf'
        if variables_tf.exists():
            analysis['variables'] = self._extract_variables(variables_tf)
        
        # Analyze outputs.tf
        outputs_tf = version_path / 'outputs.tf'
        if outputs_tf.exists():
            analysis['outputs'] = self._extract_outputs(outputs_tf)
        
        # Analyze examples
        examples_dir = version_path / 'examples'
        if examples_dir.exists():
            analysis['examples'] = self._analyze_examples(examples_dir)
        
        return analysis
    
    def _analyze_terraform_file(self, tf_file: Path) -> Dict:
        """Analyze a Terraform file for resources and module calls"""
        try:
            with open(tf_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Parse HCL content
            parsed = hcl2.loads(content)
            
            resources = {}
            dependencies = set()
            
            # Extract resources
            if 'resource' in parsed:
                for resource_type, resource_instances in parsed['resource'].items():
                    if resource_type not in resources:
                        resources[resource_type] = 0
                    resources[resource_type] += len(resource_instances)
            
            # Extract module calls
            if 'module' in parsed:
                for module_name, module_config in parsed['module'].items():
                    if isinstance(module_config, dict) and 'source' in module_config:
                        source = module_config['source']
                        if isinstance(source, str) and '../modules/' in source:
                            # Extract module dependency
                            match = re.search(r'\.\.\/modules\/([^\/]+)', source)
                            if match:
                                dependencies.add(match.group(1))
            
            return {'resources': resources, 'dependencies': dependencies}
            
        except Exception as e:
            print(f"⚠️  Error analyzing {tf_file}: {e}")
            return {'resources': {}, 'dependencies': set()}
    
    def _extract_variables(self, variables_tf: Path) -> Dict:
        """Extract variable definitions"""
        try:
            with open(variables_tf, 'r', encoding='utf-8') as f:
                content = f.read()
            
            parsed = hcl2.loads(content)
            variables = {}
            
            if 'variable' in parsed:
                for var_name, var_config in parsed['variable'].items():
                    variables[var_name] = {
                        'type': var_config.get('type', 'unknown'),
                        'description': var_config.get('description', ''),
                        'default': var_config.get('default')
                    }
            
            return variables
            
        except Exception as e:
            print(f"⚠️  Error extracting variables from {variables_tf}: {e}")
            return {}
    
    def _extract_outputs(self, outputs_tf: Path) -> Dict:
        """Extract output definitions"""
        try:
            with open(outputs_tf, 'r', encoding='utf-8') as f:
                content = f.read()
            
            parsed = hcl2.loads(content)
            outputs = {}
            
            if 'output' in parsed:
                for output_name, output_config in parsed['output'].items():
                    outputs[output_name] = {
                        'description': output_config.get('description', ''),
                        'value': str(output_config.get('value', ''))
                    }
            
            return outputs
            
        except Exception as e:
            print(f"⚠️  Error extracting outputs from {outputs_tf}: {e}")
            return {}
    
    def _analyze_examples(self, examples_dir: Path) -> List[Dict]:
        """Analyze example files"""
        examples = []
        
        for example_file in examples_dir.glob('*.tf'):
            example = {
                'name': example_file.stem,
                'path': str(example_file),
                'description': self._extract_example_description(example_file)
            }
            examples.append(example)
        
        return examples
    
    def _extract_example_description(self, example_file: Path) -> str:
        """Extract description from example file comments"""
        try:
            with open(example_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Look for description in comments at the top
            lines = content.split('\n')
            description_lines = []
            
            for line in lines:
                line = line.strip()
                if line.startswith('#'):
                    description_lines.append(line[1:].strip())
                elif line and not line.startswith('#'):
                    break
            
            return ' '.join(description_lines)[:200]  # Limit length
            
        except Exception:
            return "No description available"
    
    def _analyze_dependencies(self):
        """Build dependency graph"""
        for module_name, versions in self.modules.items():
            for version, analysis in versions.items():
                key = f"{module_name}:{version}"
                self.dependencies[key] = list(analysis['dependencies'])

class DependencyGraphVisualizer:
    def __init__(self, modules: Dict, dependencies: Dict):
        self.modules = modules
        self.dependencies = dependencies
        self.graph = nx.DiGraph()
        
    def create_graph(self):
        """Create NetworkX graph from modules and dependencies"""
        print("📊 Creating dependency graph...")
        
        # Add nodes
        for module_name, versions in self.modules.items():
            for version, analysis in versions.items():
                node_id = f"{module_name}:{version}"
                
                # Calculate node attributes
                resource_count = sum(analysis['resources'].values())
                variable_count = len(analysis['variables'])
                output_count = len(analysis['outputs'])
                example_count = len(analysis['examples'])
                
                self.graph.add_node(node_id, 
                                  module_name=module_name,
                                  version=version,
                                  resource_count=resource_count,
                                  variable_count=variable_count,
                                  output_count=output_count,
                                  example_count=example_count,
                                  resources=list(analysis['resources'].keys()),
                                  examples=[ex['name'] for ex in analysis['examples']])
        
        # Add edges
        for node_id, deps in self.dependencies.items():
            for dep in deps:
                # Find the latest version of the dependency
                if dep in self.modules:
                    dep_versions = list(self.modules[dep].keys())
                    if dep_versions:
                        latest_version = sorted(dep_versions)[-1]  # Simple version sorting
                        dep_node_id = f"{dep}:{latest_version}"
                        if dep_node_id in self.graph:
                            self.graph.add_edge(node_id, dep_node_id)
        
        return self.graph
    
    def create_interactive_visualization(self, output_file: str = "module_dependencies.html"):
        """Create interactive Plotly visualization"""
        print(f"🎨 Creating interactive visualization: {output_file}")
        
        # Calculate layout
        pos = nx.spring_layout(self.graph, k=3, iterations=50)
        
        # Prepare node data
        node_x = []
        node_y = []
        node_text = []
        node_color = []
        node_size = []
        
        for node in self.graph.nodes():
            x, y = pos[node]
            node_x.append(x)
            node_y.append(y)
            
            data = self.graph.nodes[node]
            hover_text = f"""
            <b>{data['module_name']}</b> {data['version']}<br>
            Resources: {data['resource_count']}<br>
            Variables: {data['variable_count']}<br>
            Outputs: {data['output_count']}<br>
            Examples: {data['example_count']}<br>
            Resource Types: {', '.join(data['resources'][:3])}{'...' if len(data['resources']) > 3 else ''}<br>
            Examples: {', '.join(data['examples'][:2])}{'...' if len(data['examples']) > 2 else ''}
            """
            node_text.append(hover_text)
            node_color.append(data['resource_count'])
            node_size.append(max(10, min(50, data['resource_count'] * 5)))
        
        # Prepare edge data
        edge_x = []
        edge_y = []
        
        for edge in self.graph.edges():
            x0, y0 = pos[edge[0]]
            x1, y1 = pos[edge[1]]
            edge_x.extend([x0, x1, None])
            edge_y.extend([y0, y1, None])
        
        # Create figure
        fig = go.Figure()
        
        # Add edges
        fig.add_trace(go.Scatter(x=edge_x, y=edge_y,
                               mode='lines',
                               line=dict(width=1, color='#888'),
                               hoverinfo='none',
                               showlegend=False,
                               name='Dependencies'))
        
        # Add nodes
        fig.add_trace(go.Scatter(x=node_x, y=node_y,
                               mode='markers+text',
                               marker=dict(size=node_size,
                                         color=node_color,
                                         colorscale='Viridis',
                                         colorbar=dict(title="Resource Count"),
                                         line=dict(width=2, color='white')),
                               text=[node.split(':')[0] for node in self.graph.nodes()],
                               textposition="middle center",
                               textfont=dict(size=8, color='white'),
                               hovertemplate='%{hovertext}<extra></extra>',
                               hovertext=node_text,
                               showlegend=False,
                               name='Modules'))
        
        # Update layout
        fig.update_layout(
            title=dict(
                text="🏗️ Terraform Module Dependency Graph",
                x=0.5,
                font=dict(size=20)
            ),
            showlegend=False,
            hovermode='closest',
            margin=dict(b=20,l=5,r=5,t=40),
            annotations=[ dict(
                text="Node size represents resource count. Hover for details.",
                showarrow=False,
                xref="paper", yref="paper",
                x=0.005, y=-0.002 ,
                xanchor='left', yanchor='bottom',
                font=dict(color='gray', size=12)
            )],
            xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
            yaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
            plot_bgcolor='rgba(0,0,0,0)',
            paper_bgcolor='rgba(0,0,0,0)'
        )
        
        fig.write_html(output_file)
        return output_file
    
    def create_module_matrix(self, output_file: str = "module_matrix.html"):
        """Create module compatibility matrix"""
        print(f"📊 Creating module compatibility matrix: {output_file}")
        
        module_names = list(self.modules.keys())
        matrix_data = []
        
        # Create compatibility matrix
        for i, mod1 in enumerate(module_names):
            row = []
            for j, mod2 in enumerate(module_names):
                if i == j:
                    # Same module - show version count
                    row.append(len(self.modules[mod1]))
                else:
                    # Different modules - check if mod1 depends on mod2
                    dependency_count = 0
                    for version in self.modules[mod1].values():
                        if mod2 in version['dependencies']:
                            dependency_count += 1
                    row.append(dependency_count)
            matrix_data.append(row)
        
        # Create heatmap
        fig = go.Figure(data=go.Heatmap(
            z=matrix_data,
            x=module_names,
            y=module_names,
            colorscale='Blues',
            text=matrix_data,
            texttemplate="%{text}",
            textfont={"size":12},
            colorbar=dict(title="Dependencies")
        ))
        
        fig.update_layout(
            title="🔗 Module Dependency Matrix",
            xaxis_title="Depends On",
            yaxis_title="Module",
            width=800,
            height=800
        )
        
        fig.write_html(output_file)
        return output_file
    
    def generate_report(self, output_file: str = "dependency_report.json"):
        """Generate dependency analysis report"""
        print(f"📋 Generating dependency report: {output_file}")
        
        report = {
            'summary': {
                'total_modules': len(self.modules),
                'total_versions': sum(len(versions) for versions in self.modules.values()),
                'total_dependencies': len([dep for deps in self.dependencies.values() for dep in deps]),
            },
            'modules': {},
            'dependency_chains': [],
            'circular_dependencies': []
        }
        
        # Module details
        for module_name, versions in self.modules.items():
            latest_version = sorted(versions.keys())[-1]
            latest_analysis = versions[latest_version]
            
            report['modules'][module_name] = {
                'versions': list(versions.keys()),
                'latest_version': latest_version,
                'resource_count': sum(latest_analysis['resources'].values()),
                'resource_types': list(latest_analysis['resources'].keys()),
                'dependencies': list(latest_analysis['dependencies']),
                'examples': [ex['name'] for ex in latest_analysis['examples']]
            }
        
        # Check for circular dependencies
        try:
            cycles = list(nx.simple_cycles(self.graph))
            report['circular_dependencies'] = cycles
        except:
            report['circular_dependencies'] = []
        
        # Dependency chains
        for node in self.graph.nodes():
            try:
                # Find longest path from this node
                paths = nx.single_source_shortest_path(self.graph, node, cutoff=5)
                longest_path = max(paths.values(), key=len) if paths else [node]
                if len(longest_path) > 1:
                    report['dependency_chains'].append(longest_path)
            except:
                continue
        
        with open(output_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        return report

def main():
    parser = argparse.ArgumentParser(description='Visualize Terraform module dependencies')
    parser.add_argument('--modules-dir', '-m', default='../modules', 
                       help='Directory containing Terraform modules')
    parser.add_argument('--output-dir', '-o', default='visualizations',
                       help='Output directory for visualizations')
    parser.add_argument('--format', '-f', choices=['html', 'json', 'all'], default='all',
                       help='Output format')
    
    args = parser.parse_args()
    
    # Create output directory
    output_dir = Path(args.output_dir)
    output_dir.mkdir(exist_ok=True)
    
    print("🔍 Starting Terraform module dependency analysis...")
    
    # Analyze modules
    analyzer = TerraformModuleAnalyzer(args.modules_dir)
    modules, dependencies = analyzer.analyze_modules()
    
    if not modules:
        print("❌ No modules found to analyze")
        return
    
    # Create visualizations
    visualizer = DependencyGraphVisualizer(modules, dependencies)
    graph = visualizer.create_graph()
    
    print(f"📊 Found {len(modules)} module types with {len(graph.nodes())} total versions")
    print(f"🔗 Identified {len(graph.edges())} dependencies")
    
    if args.format in ['html', 'all']:
        # Generate visualizations
        graph_file = output_dir / 'module_dependencies.html'
        matrix_file = output_dir / 'module_matrix.html'
        
        visualizer.create_interactive_visualization(str(graph_file))
        visualizer.create_module_matrix(str(matrix_file))
        
        print(f"✅ Generated HTML visualizations:")
        print(f"   📊 Dependency graph: {graph_file}")
        print(f"   📊 Compatibility matrix: {matrix_file}")
    
    if args.format in ['json', 'all']:
        # Generate report
        report_file = output_dir / 'dependency_report.json'
        report = visualizer.generate_report(str(report_file))
        
        print(f"✅ Generated JSON report: {report_file}")
        print(f"📋 Summary:")
        print(f"   Modules: {report['summary']['total_modules']}")
        print(f"   Versions: {report['summary']['total_versions']}")
        print(f"   Dependencies: {report['summary']['total_dependencies']}")
        
        if report['circular_dependencies']:
            print(f"⚠️  Circular dependencies found: {len(report['circular_dependencies'])}")
    
    print("🎉 Module dependency analysis complete!")

if __name__ == '__main__':
    main()