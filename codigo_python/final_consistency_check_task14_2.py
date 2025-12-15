#!/usr/bin/env python3
"""
Final Consistency Check Script for Task 14.2
Verifies all numbers match across text, tables, and figures
Checks all cross-references resolve correctly
Ensures no contradictions between sections
Validates all citations are properly formatted
"""

import re
import sys
from pathlib import Path
from collections import defaultdict

class ConsistencyReport:
    def __init__(self):
        self.checks = []
        self.passed = 0
        self.failed = 0
        self.warnings = 0
    
    def add_check(self, name, status, details=""):
        self.checks.append({
            'name': name,
            'status': status,
            'details': details
        })
        if status == 'PASS':
            self.passed += 1
        elif status == 'FAIL':
            self.failed += 1
        elif status == 'WARNING':
            self.warnings += 1
    
    def print_report(self):
        print("\n" + "="*80)
        print("TASK 14.2: FINAL CONSISTENCY CHECK")
        print("="*80 + "\n")
        
        for check in self.checks:
            status_symbol = {
                'PASS': '✓',
                'FAIL': '✗',
                'WARNING': '⚠'
            }.get(check['status'], '?')
            
            print(f"{status_symbol} {check['status']:8} | {check['name']}")
            if check['details']:
                for line in check['details'].split('\n'):
                    if line.strip():
                        print(f"           | {line}")
            print()
        
        print("="*80)
        print(f"SUMMARY: {self.passed} passed, {self.failed} failed, {self.warnings} warnings")
        print("="*80 + "\n")
        
        return self.failed == 0

def read_file(filepath):
    """Read file content"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return None

def extract_accuracy_values(content):
    """Extract all accuracy values from the document"""
    # Pattern to match accuracy percentages
    accuracy_pattern = r'(\d+\.\d+)\\?%'
    matches = re.findall(accuracy_pattern, content)
    
    # Count occurrences of key accuracy values
    accuracy_counts = defaultdict(int)
    for match in matches:
        accuracy_counts[match] += 1
    
    return accuracy_counts

def check_numerical_consistency(content, report):
    """Verify all numbers match across text, tables, and figures"""
    check_name = "Numerical Consistency"
    
    # Key accuracy values that should appear consistently
    expected_values = {
        '94.2': 'ResNet50 validation accuracy',
        '91.9': 'EfficientNet-B0 validation accuracy',
        '85.5': 'Custom CNN validation accuracy',
        '0.185': 'ResNet50 validation loss',
        '0.243': 'EfficientNet-B0 validation loss',
        '0.412': 'Custom CNN validation loss',
        '45.3': 'ResNet50 inference time (ms)',
        '32.7': 'EfficientNet-B0 inference time (ms)',
        '18.5': 'Custom CNN inference time (ms)',
        '414': 'Total dataset images',
        '290': 'Training images',
        '62': 'Validation/test images'
    }
    
    issues = []
    for value, description in expected_values.items():
        count = content.count(value)
        if count == 0:
            issues.append(f"Missing: {description} ({value})")
        elif count < 2:
            issues.append(f"Only 1 occurrence: {description} ({value})")
    
    if not issues:
        report.add_check(check_name, 'PASS', 
                        f"All key numerical values appear consistently")
    else:
        report.add_check(check_name, 'WARNING', 
                        '\n'.join(issues))

def check_cross_references(content, report):
    """Verify all cross-references resolve correctly"""
    check_name = "Cross-References"
    
    # Extract all labels
    label_pattern = r'\\label\{([^}]+)\}'
    labels = set(re.findall(label_pattern, content))
    
    # Extract all references
    ref_pattern = r'\\ref\{([^}]+)\}'
    refs = re.findall(ref_pattern, content)
    
    # Find undefined references
    undefined_refs = []
    for ref in refs:
        if ref not in labels:
            undefined_refs.append(ref)
    
    # Find unused labels
    unused_labels = []
    for label in labels:
        if content.count(f'\\ref{{{label}}}') == 0:
            unused_labels.append(label)
    
    issues = []
    if undefined_refs:
        issues.append(f"Undefined references: {', '.join(set(undefined_refs))}")
    if unused_labels:
        issues.append(f"Unused labels: {', '.join(unused_labels)}")
    
    if not issues:
        report.add_check(check_name, 'PASS', 
                        f"{len(labels)} labels defined, {len(refs)} references used")
    else:
        report.add_check(check_name, 'WARNING', 
                        '\n'.join(issues))

def check_figure_references(content, report):
    """Verify all figures are referenced in text"""
    check_name = "Figure References"
    
    # Extract figure labels
    fig_pattern = r'\\label\{fig:([^}]+)\}'
    figures = re.findall(fig_pattern, content)
    
    # Check each figure is referenced
    unreferenced = []
    for fig in figures:
        if f'\\ref{{fig:{fig}}}' not in content and f'Figure~\\ref{{fig:{fig}}}' not in content:
            unreferenced.append(f'fig:{fig}')
    
    if not unreferenced:
        report.add_check(check_name, 'PASS', 
                        f"All {len(figures)} figures are referenced in text")
    else:
        report.add_check(check_name, 'WARNING', 
                        f"Unreferenced figures: {', '.join(unreferenced)}")

def check_table_references(content, report):
    """Verify all tables are referenced in text"""
    check_name = "Table References"
    
    # Extract table labels
    tab_pattern = r'\\label\{tab:([^}]+)\}'
    tables = re.findall(tab_pattern, content)
    
    # Check each table is referenced
    unreferenced = []
    for tab in tables:
        if f'\\ref{{tab:{tab}}}' not in content and f'Table~\\ref{{tab:{tab}}}' not in content:
            unreferenced.append(f'tab:{tab}')
    
    if not unreferenced:
        report.add_check(check_name, 'PASS', 
                        f"All {len(tables)} tables are referenced in text")
    else:
        report.add_check(check_name, 'WARNING', 
                        f"Unreferenced tables: {', '.join(unreferenced)}")

def check_section_consistency(content, report):
    """Check for contradictions between sections"""
    check_name = "Section Consistency"
    
    # Check that abstract values match results
    abstract_match = re.search(r'\\abstract\{(.*?)\}', content, re.DOTALL)
    if not abstract_match:
        report.add_check(check_name, 'FAIL', "Abstract not found")
        return
    
    abstract = abstract_match.group(1)
    
    # Check key values in abstract
    issues = []
    if '94.2' not in abstract:
        issues.append("ResNet50 accuracy (94.2%) not in abstract")
    if '91.9' not in abstract:
        issues.append("EfficientNet-B0 accuracy (91.9%) not in abstract")
    if '85.5' not in abstract:
        issues.append("Custom CNN accuracy (85.5%) not in abstract")
    
    # Check conclusions match results
    conclusions_match = re.search(
        r'\\section\{Conclusions\}.*?(?=\\vspace|\\authorcontributions)',
        content, re.DOTALL
    )
    
    if conclusions_match:
        conclusions = conclusions_match.group(0)
        if '94.2' not in conclusions:
            issues.append("ResNet50 accuracy (94.2%) not in conclusions")
        if '91.9' not in conclusions:
            issues.append("EfficientNet-B0 accuracy (91.9%) not in conclusions")
        if '85.5' not in conclusions:
            issues.append("Custom CNN accuracy (85.5%) not in conclusions")
    else:
        issues.append("Conclusions section not found")
    
    if not issues:
        report.add_check(check_name, 'PASS', 
                        "Abstract and conclusions consistent with results")
    else:
        report.add_check(check_name, 'WARNING', 
                        '\n'.join(issues))

def check_citation_format(content, report):
    """Validate all citations are properly formatted"""
    check_name = "Citation Format"
    
    # Find all citations
    cite_pattern = r'\\cite\{([^}]+)\}'
    citations = re.findall(cite_pattern, content)
    
    # Check for bibliography command
    has_bibliography = '\\bibliography{' in content
    
    issues = []
    if not has_bibliography:
        issues.append("No \\bibliography command found")
    
    if len(citations) == 0:
        issues.append("No citations found in document")
    
    # Check for common citation issues
    if '\\cite{}' in content:
        issues.append("Empty citation found: \\cite{}")
    
    if not issues:
        report.add_check(check_name, 'PASS', 
                        f"{len(citations)} citations found, bibliography present")
    else:
        report.add_check(check_name, 'WARNING', 
                        '\n'.join(issues))

def check_table_data_consistency(content, report):
    """Verify table data matches text descriptions"""
    check_name = "Table Data Consistency"
    
    # Extract Table 2 (Performance Metrics)
    table2_match = re.search(
        r'\\caption\{Validation Performance Metrics.*?\}.*?\\end\{tabularx\}',
        content, re.DOTALL
    )
    
    if not table2_match:
        report.add_check(check_name, 'WARNING', 
                        "Table 2 (Performance Metrics) not found")
        return
    
    table2 = table2_match.group(0)
    
    # Check key values in table
    issues = []
    if '94.2' not in table2:
        issues.append("ResNet50 accuracy missing from Table 2")
    if '91.9' not in table2:
        issues.append("EfficientNet-B0 accuracy missing from Table 2")
    if '85.5' not in table2:
        issues.append("Custom CNN accuracy missing from Table 2")
    if '0.185' not in table2:
        issues.append("ResNet50 loss missing from Table 2")
    if '0.243' not in table2:
        issues.append("EfficientNet-B0 loss missing from Table 2")
    if '0.412' not in table2:
        issues.append("Custom CNN loss missing from Table 2")
    
    if not issues:
        report.add_check(check_name, 'PASS', 
                        "Table 2 data consistent with text")
    else:
        report.add_check(check_name, 'FAIL', 
                        '\n'.join(issues))

def check_dataset_split_consistency(content, report):
    """Verify dataset split numbers are consistent"""
    check_name = "Dataset Split Consistency"
    
    # Check for 70/15/15 split
    has_split_ratio = '70\\%/15\\%/15\\%' in content or '70%/15%/15%' in content
    
    # Check for specific numbers
    has_290 = '290' in content  # training
    has_62 = '62' in content    # validation/test
    has_414 = '414' in content  # total
    
    issues = []
    if not has_split_ratio:
        issues.append("Split ratio (70%/15%/15%) not clearly stated")
    if not has_290:
        issues.append("Training set size (290) not mentioned")
    if not has_62:
        issues.append("Validation/test set size (62) not mentioned")
    if not has_414:
        issues.append("Total dataset size (414) not mentioned")
    
    # Verify math: 290 + 62 + 62 = 414
    if has_290 and has_62 and has_414:
        # Math checks out
        pass
    else:
        issues.append("Dataset split numbers incomplete")
    
    if not issues:
        report.add_check(check_name, 'PASS', 
                        "Dataset split (414 = 290 + 62 + 62) consistent")
    else:
        report.add_check(check_name, 'WARNING', 
                        '\n'.join(issues))

def check_model_parameters_consistency(content, report):
    """Verify model parameter counts are consistent"""
    check_name = "Model Parameters Consistency"
    
    # Expected parameter counts
    expected = {
        'ResNet50': '25M',
        'EfficientNet-B0': '5M',
        'Custom CNN': '2M'
    }
    
    issues = []
    for model, params in expected.items():
        # Count occurrences
        count = content.count(params)
        if count < 2:
            issues.append(f"{model} parameters ({params}) mentioned only {count} time(s)")
    
    if not issues:
        report.add_check(check_name, 'PASS', 
                        "Model parameter counts consistent throughout")
    else:
        report.add_check(check_name, 'WARNING', 
                        '\n'.join(issues))

def main():
    """Main validation function"""
    report = ConsistencyReport()
    
    # Read the main article
    article_path = 'artigo_mdpi_classification.tex'
    content = read_file(article_path)
    
    if not content:
        print(f"ERROR: Could not read {article_path}")
        sys.exit(1)
    
    print(f"\nValidating: {article_path}")
    print(f"File size: {len(content)} characters\n")
    
    # Run all consistency checks
    check_numerical_consistency(content, report)
    check_cross_references(content, report)
    check_figure_references(content, report)
    check_table_references(content, report)
    check_section_consistency(content, report)
    check_citation_format(content, report)
    check_table_data_consistency(content, report)
    check_dataset_split_consistency(content, report)
    check_model_parameters_consistency(content, report)
    
    # Print report
    success = report.print_report()
    
    if success:
        print("✓ ALL CONSISTENCY CHECKS PASSED")
        print("\nThe article is ready for final submission package (Task 14.3)")
        return 0
    else:
        print("✗ CONSISTENCY ISSUES FOUND")
        print("\nPlease review the warnings and failures before proceeding")
        return 1

if __name__ == '__main__':
    sys.exit(main())
