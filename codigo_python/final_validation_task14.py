#!/usr/bin/env python3
"""
Final Pre-Submission Validation Script for Task 14.1
Verifies all critical fixes are applied to the MDPI article
"""

import re
import sys
from pathlib import Path

class ValidationReport:
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
        print("TASK 14.1: VERIFY ALL CRITICAL FIXES ARE APPLIED")
        print("="*80 + "\n")
        
        for check in self.checks:
            status_symbol = {
                'PASS': '✓',
                'FAIL': '✗',
                'WARNING': '⚠'
            }.get(check['status'], '?')
            
            print(f"{status_symbol} {check['status']:8} | {check['name']}")
            if check['details']:
                print(f"           | {check['details']}")
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

def check_figure2_accuracy_values(content, report):
    """Verify Figure 2 has correct accuracy values in caption/text"""
    check_name = "Figure 2: Correct Accuracy Values"
    
    # Look for confusion matrix figure reference
    fig2_pattern = r'\\label\{fig:confusion_matrices\}'
    if not re.search(fig2_pattern, content):
        report.add_check(check_name, 'FAIL', 
                        "Figure 2 (confusion_matrices) label not found")
        return
    
    # Check for correct accuracy values in entire Results section
    results_section = re.search(
        r'\\section\{Results\}.*?\\section\{Discussion\}',
        content, re.DOTALL
    )
    
    if not results_section:
        report.add_check(check_name, 'FAIL', 
                        "Results section not found")
        return
    
    section_text = results_section.group(0)
    
    # Check for ResNet50: 94.2%
    resnet_ok = '94.2' in section_text
    
    # Check for EfficientNet-B0: 91.9%
    efficient_ok = '91.9' in section_text
    
    # Check for Custom CNN: 85.5%
    custom_ok = '85.5' in section_text
    
    # Check for incorrect old values (should NOT be present)
    has_old_values = ('39.4' in section_text or '48.5' in section_text or 
                      '54.5' in section_text)
    
    if resnet_ok and efficient_ok and custom_ok and not has_old_values:
        report.add_check(check_name, 'PASS', 
                        "Correct accuracy values found (94.2%, 91.9%, 85.5%)")
    elif has_old_values:
        report.add_check(check_name, 'FAIL', 
                        "Old incorrect values still present (39.4%, 48.5%, 54.5%)")
    else:
        missing = []
        if not resnet_ok: missing.append("ResNet50 94.2%")
        if not efficient_ok: missing.append("EfficientNet 91.9%")
        if not custom_ok: missing.append("Custom CNN 85.5%")
        report.add_check(check_name, 'FAIL', 
                        f"Missing accuracy values: {', '.join(missing)}")

def check_methodology_detail(content, report):
    """Verify methodology section has sufficient detail"""
    check_name = "Methodology: Sufficient Detail"
    
    # Check for data augmentation justification
    aug_pattern = r'(data augmentation|augmentation techniques)'
    aug_matches = re.findall(aug_pattern, content, re.IGNORECASE)
    
    # Check for class weighting formula
    class_weight_formula = r'w_c\s*=\s*\\frac\{N\}\{C\s*\\cdot\s*n_c\}'
    has_formula = re.search(class_weight_formula, content)
    
    # Check for early stopping criteria
    early_stopping = re.search(r'early stopping.*?patience.*?10 epochs', content, re.IGNORECASE | re.DOTALL)
    
    # Check for specific augmentation parameters
    has_flip = 'horizontal flip' in content.lower()
    has_rotation = 'rotation' in content.lower()
    has_brightness = 'brightness' in content.lower()
    
    issues = []
    if len(aug_matches) < 2:
        issues.append("Limited data augmentation discussion")
    if not has_formula:
        issues.append("Missing class weighting formula")
    if not early_stopping:
        issues.append("Missing early stopping criteria details")
    if not (has_flip and has_rotation and has_brightness):
        issues.append("Missing augmentation technique details")
    
    if not issues:
        report.add_check(check_name, 'PASS', 
                        "Methodology has comprehensive detail")
    else:
        report.add_check(check_name, 'WARNING', 
                        f"Potential gaps: {'; '.join(issues)}")

def check_limitations_comprehensive(content, report):
    """Verify limitations section is comprehensive"""
    check_name = "Limitations: Comprehensive Coverage"
    
    # Find limitations section
    limitations_section = re.search(
        r'\\subsection\{Limitations\}.*?(?=\\subsection|\\section)',
        content, re.DOTALL
    )
    
    if not limitations_section:
        report.add_check(check_name, 'FAIL', 
                        "Limitations section not found")
        return
    
    section_text = limitations_section.group(0)
    
    # Check for key limitations
    has_steel_type = 'ASTM A572' in section_text and 'steel type' in section_text.lower()
    has_dataset_size = 'dataset' in section_text.lower() and ('414' in section_text or 'limited' in section_text.lower())
    has_localization = 'localization' in section_text.lower() or 'spatial' in section_text.lower()
    
    # Count limitation subsections/paragraphs
    limitation_count = section_text.count('\\textbf{')
    
    issues = []
    if not has_steel_type:
        issues.append("Missing steel type specificity limitation")
    if not has_dataset_size:
        issues.append("Missing dataset size limitation")
    if not has_localization:
        issues.append("Missing spatial localization limitation")
    if limitation_count < 3:
        issues.append(f"Only {limitation_count} limitations discussed (expected 3+)")
    
    if not issues:
        report.add_check(check_name, 'PASS', 
                        f"Comprehensive limitations section ({limitation_count} limitations)")
    else:
        report.add_check(check_name, 'FAIL', 
                        f"Incomplete: {'; '.join(issues)}")

def check_data_availability_complete(content, report):
    """Verify data availability section is complete"""
    check_name = "Data Availability: Complete Information"
    
    # Find data availability section - need to handle multi-line
    data_avail_match = re.search(
        r'\\dataavailability\{',
        content
    )
    
    if not data_avail_match:
        report.add_check(check_name, 'FAIL', 
                        "Data availability section not found")
        return
    
    # Extract a large chunk after \dataavailability{ to capture the full content
    start_pos = data_avail_match.end()
    # Find the closing brace by counting braces
    brace_count = 1
    end_pos = start_pos
    while brace_count > 0 and end_pos < len(content):
        if content[end_pos] == '{':
            brace_count += 1
        elif content[end_pos] == '}':
            brace_count -= 1
        end_pos += 1
    
    section_text = content[start_pos:end_pos-1]
    
    # Check for required elements
    has_github = 'github' in section_text.lower()
    has_python_version = 'Python 3.12' in section_text
    has_tensorflow = 'TensorFlow 2.20' in section_text or 'TensorFlow 2.2' in section_text
    has_random_seed = 'seed 42' in section_text.lower()
    has_hardware = 'RTX 3060' in section_text or 'GPU' in section_text
    has_cuda = 'CUDA' in section_text
    has_dataset_access = 'dataset' in section_text.lower() and 'proprietary' in section_text.lower()
    
    issues = []
    if not has_github:
        issues.append("Missing GitHub repository link")
    if not has_python_version:
        issues.append("Missing Python version")
    if not has_tensorflow:
        issues.append("Missing TensorFlow version")
    if not has_random_seed:
        issues.append("Missing random seed")
    if not has_hardware:
        issues.append("Missing hardware specifications")
    if not has_cuda:
        issues.append("Missing CUDA version")
    if not has_dataset_access:
        issues.append("Missing dataset access information")
    
    if not issues:
        report.add_check(check_name, 'PASS', 
                        "Complete data availability statement")
    else:
        report.add_check(check_name, 'FAIL', 
                        f"Missing: {'; '.join(issues)}")

def check_confusion_matrix_figure_exists(report):
    """Verify confusion matrix figure file exists"""
    check_name = "Figure 2: File Exists"
    
    fig_path = Path('figuras_pure_classification/figura_confusion_matrices.pdf')
    
    if fig_path.exists():
        report.add_check(check_name, 'PASS', 
                        f"File exists: {fig_path}")
    else:
        report.add_check(check_name, 'FAIL', 
                        f"File not found: {fig_path}")

def check_task9_completion(report):
    """Verify Task 9 completion report exists"""
    check_name = "Task 9: Completion Report"
    
    task9_path = Path('TASK_9_DATA_CONSISTENCY_REPORT.md')
    
    if task9_path.exists():
        content = read_file(task9_path)
        if content and 'COMPLETED' in content:
            report.add_check(check_name, 'PASS', 
                            "Task 9 completion report found")
        else:
            report.add_check(check_name, 'WARNING', 
                            "Task 9 report exists but status unclear")
    else:
        report.add_check(check_name, 'WARNING', 
                        "Task 9 completion report not found")

def check_task13_completion(report):
    """Verify Task 13 completion report exists"""
    check_name = "Task 13: Completion Report"
    
    task13_path = Path('TASK_13_DATA_AVAILABILITY_COMPLETION.md')
    
    if task13_path.exists():
        content = read_file(task13_path)
        if content and 'COMPLETED' in content:
            report.add_check(check_name, 'PASS', 
                            "Task 13 completion report found")
        else:
            report.add_check(check_name, 'WARNING', 
                            "Task 13 report exists but status unclear")
    else:
        report.add_check(check_name, 'WARNING', 
                        "Task 13 completion report not found")

def main():
    """Main validation function"""
    report = ValidationReport()
    
    # Read the main article
    article_path = 'artigo_mdpi_classification.tex'
    content = read_file(article_path)
    
    if not content:
        print(f"ERROR: Could not read {article_path}")
        sys.exit(1)
    
    print(f"\nValidating: {article_path}")
    print(f"File size: {len(content)} characters\n")
    
    # Run all checks
    check_figure2_accuracy_values(content, report)
    check_methodology_detail(content, report)
    check_limitations_comprehensive(content, report)
    check_data_availability_complete(content, report)
    check_confusion_matrix_figure_exists(report)
    check_task9_completion(report)
    check_task13_completion(report)
    
    # Print report
    success = report.print_report()
    
    if success:
        print("✓ ALL CRITICAL FIXES VERIFIED")
        print("\nThe article is ready for final consistency check (Task 14.2)")
        return 0
    else:
        print("✗ CRITICAL ISSUES FOUND")
        print("\nPlease address the failed checks before proceeding")
        return 1

if __name__ == '__main__':
    sys.exit(main())
