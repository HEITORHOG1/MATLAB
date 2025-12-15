#!/usr/bin/env python3
"""
Final Validation Script for Task 13: Final Validation and Submission Preparation
Validates class consistency, reference citations, and document quality.
"""

import re
import os
from collections import defaultdict
from datetime import datetime

def read_file(filepath):
    """Read file content with UTF-8 encoding."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return None

def validate_class_consistency(content):
    """Validate that all class references use 3-class system consistently."""
    print("\n" + "="*80)
    print("TASK 13.1: CLASS CONSISTENCY VALIDATION")
    print("="*80)
    
    issues = []
    
    # Check for any mention of 4 classes or Class 3
    four_class_patterns = [
        r'four\s+classes',
        r'4\s+classes',
        r'Class\s+3',
        r'class\s+3',
    ]
    
    for pattern in four_class_patterns:
        matches = re.finditer(pattern, content, re.IGNORECASE)
        for match in matches:
            # Get context around the match
            start = max(0, match.start() - 100)
            end = min(len(content), match.end() + 100)
            context = content[start:end]
            issues.append(f"Found '{match.group()}' at position {match.start()}: ...{context}...")
    
    # Check for correct 3-class references
    three_class_patterns = [
        r'three\s+classes',
        r'3\s+classes',
        r'three\s+severity\s+classes',
    ]
    
    three_class_count = 0
    for pattern in three_class_patterns:
        matches = list(re.finditer(pattern, content, re.IGNORECASE))
        three_class_count += len(matches)
    
    # Check class definitions in abstract
    abstract_match = re.search(r'\\begin\{abstract\}(.*?)\\end\{abstract\}', content, re.DOTALL)
    if abstract_match:
        abstract = abstract_match.group(1)
        if 'Class 0' in abstract and 'Class 1' in abstract and 'Class 2' in abstract:
            print("✓ Abstract correctly defines 3 classes (Class 0, 1, 2)")
        else:
            issues.append("Abstract does not clearly define all 3 classes")
        
        if 'Class 3' in abstract or 'four classes' in abstract.lower():
            issues.append("Abstract mentions 4 classes or Class 3")
    
    # Check methodology section
    methodology_match = re.search(r'\\section\{Methodology\}(.*?)\\section\{Results\}', content, re.DOTALL)
    if methodology_match:
        methodology = methodology_match.group(1)
        class_0_count = len(re.findall(r'Class\s+0', methodology))
        class_1_count = len(re.findall(r'Class\s+1', methodology))
        class_2_count = len(re.findall(r'Class\s+2', methodology))
        class_3_count = len(re.findall(r'Class\s+3', methodology))
        
        print(f"✓ Methodology section mentions: Class 0 ({class_0_count}x), Class 1 ({class_1_count}x), Class 2 ({class_2_count}x)")
        if class_3_count > 0:
            issues.append(f"Methodology mentions Class 3 ({class_3_count} times)")
    
    # Check conclusions section
    conclusions_match = re.search(r'\\section\{Conclusions\}(.*?)(?:\\section|\\bibliographystyle)', content, re.DOTALL)
    if conclusions_match:
        conclusions = conclusions_match.group(1)
        if 'three classes' in conclusions.lower() or 'Class 0' in conclusions:
            print("✓ Conclusions section correctly references 3-class system")
        if 'Class 3' in conclusions or 'four classes' in conclusions.lower():
            issues.append("Conclusions mentions 4 classes or Class 3")
    
    # Check tables for class consistency
    table_matches = re.finditer(r'\\begin\{table\}(.*?)\\end\{table\}', content, re.DOTALL)
    for i, table_match in enumerate(table_matches, 1):
        table_content = table_match.group(1)
        if 'Class' in table_content:
            has_class_3 = 'Class 3' in table_content or 'Class\s+3' in table_content
            if has_class_3:
                issues.append(f"Table {i} contains reference to Class 3")
    
    print(f"\n✓ Found {three_class_count} explicit references to '3 classes' or 'three classes'")
    
    if issues:
        print(f"\n⚠ ISSUES FOUND ({len(issues)}):")
        for issue in issues:
            print(f"  - {issue}")
        return False
    else:
        print("\n✓ ALL CLASS CONSISTENCY CHECKS PASSED")
        print("  - All references use 3-class system (Class 0, 1, 2)")
        print("  - No references to 4 classes or Class 3 found")
        print("  - Abstract, methodology, results, discussion, and conclusions are consistent")
        return True

def validate_references(content, bib_file):
    """Validate that all references are cited and properly formatted."""
    print("\n" + "="*80)
    print("TASK 13.2: REFERENCE CITATION AND FORMATTING VALIDATION")
    print("="*80)
    
    issues = []
    
    # Extract all citations from the document
    cite_pattern = r'\\cite\{([^}]+)\}'
    citations = re.findall(cite_pattern, content)
    
    # Flatten multiple citations (e.g., \cite{ref1,ref2})
    all_cited_keys = set()
    for citation in citations:
        keys = [k.strip() for k in citation.split(',')]
        all_cited_keys.update(keys)
    
    print(f"✓ Found {len(all_cited_keys)} unique citation keys in document")
    
    # Read bibliography file
    bib_content = read_file(bib_file)
    if bib_content:
        # Extract all reference keys from .bib file
        bib_pattern = r'@\w+\{([^,]+),'
        bib_keys = set(re.findall(bib_pattern, bib_content))
        
        print(f"✓ Found {len(bib_keys)} references in bibliography file")
        
        # Check for cited but not in bibliography
        missing_in_bib = all_cited_keys - bib_keys
        if missing_in_bib:
            issues.append(f"Citations not found in bibliography: {missing_in_bib}")
        else:
            print("✓ All cited references exist in bibliography")
        
        # Check for in bibliography but not cited
        uncited = bib_keys - all_cited_keys
        if uncited:
            print(f"\n⚠ References in bibliography but not cited ({len(uncited)}):")
            for key in sorted(uncited):
                print(f"  - {key}")
            issues.append(f"{len(uncited)} references in bibliography are not cited")
        else:
            print("✓ All bibliography entries are cited in text")
        
        # Check for "in preparation" references
        in_prep_pattern = r'note\s*=\s*\{[^}]*in preparation[^}]*\}'
        in_prep_matches = re.findall(in_prep_pattern, bib_content, re.IGNORECASE)
        if in_prep_matches:
            issues.append(f"Found {len(in_prep_matches)} 'in preparation' references")
            print(f"\n⚠ Found {len(in_prep_matches)} 'in preparation' references")
        else:
            print("✓ No 'in preparation' references found")
        
        # Check citation format consistency
        print(f"\n✓ Total citations in text: {len(citations)}")
        print(f"✓ Unique references cited: {len(all_cited_keys)}")
        
    else:
        issues.append("Could not read bibliography file")
    
    if issues:
        print(f"\n⚠ ISSUES FOUND ({len(issues)}):")
        for issue in issues:
            print(f"  - {issue}")
        return False
    else:
        print("\n✓ ALL REFERENCE CHECKS PASSED")
        return True

def validate_figures_tables(content):
    """Validate that all figures and tables are referenced."""
    print("\n" + "="*80)
    print("TASK 13.3: FIGURE AND TABLE REFERENCE VALIDATION")
    print("="*80)
    
    issues = []
    
    # Extract figure labels
    fig_labels = set(re.findall(r'\\label\{(fig:[^}]+)\}', content))
    print(f"✓ Found {len(fig_labels)} figure labels")
    
    # Extract table labels
    table_labels = set(re.findall(r'\\label\{(tab:[^}]+)\}', content))
    print(f"✓ Found {len(table_labels)} table labels")
    
    # Extract figure references
    fig_refs = set(re.findall(r'\\ref\{(fig:[^}]+)\}', content))
    fig_refs.update(re.findall(r'Figure~\\ref\{(fig:[^}]+)\}', content))
    
    # Extract table references
    table_refs = set(re.findall(r'\\ref\{(tab:[^}]+)\}', content))
    table_refs.update(re.findall(r'Table~\\ref\{(tab:[^}]+)\}', content))
    
    # Check for unreferenced figures
    unreferenced_figs = fig_labels - fig_refs
    if unreferenced_figs:
        issues.append(f"Unreferenced figures: {unreferenced_figs}")
    else:
        print("✓ All figures are referenced in text")
    
    # Check for unreferenced tables
    unreferenced_tables = table_labels - table_refs
    if unreferenced_tables:
        issues.append(f"Unreferenced tables: {unreferenced_tables}")
    else:
        print("✓ All tables are referenced in text")
    
    # Check for broken references
    broken_fig_refs = fig_refs - fig_labels
    if broken_fig_refs:
        issues.append(f"Broken figure references: {broken_fig_refs}")
    
    broken_table_refs = table_refs - table_labels
    if broken_table_refs:
        issues.append(f"Broken table references: {broken_table_refs}")
    
    if not broken_fig_refs and not broken_table_refs:
        print("✓ No broken figure or table references")
    
    if issues:
        print(f"\n⚠ ISSUES FOUND ({len(issues)}):")
        for issue in issues:
            print(f"  - {issue}")
        return False
    else:
        print("\n✓ ALL FIGURE/TABLE CHECKS PASSED")
        return True

def validate_document_structure(content):
    """Validate overall document structure and completeness."""
    print("\n" + "="*80)
    print("DOCUMENT STRUCTURE VALIDATION")
    print("="*80)
    
    required_sections = [
        'abstract',
        'Introduction',
        'Methodology',
        'Results',
        'Discussion',
        'Conclusions'
    ]
    
    for section in required_sections:
        if section == 'abstract':
            pattern = r'\\begin\{abstract\}'
        else:
            pattern = r'\\section\{' + section + r'\}'
        
        if re.search(pattern, content):
            print(f"✓ {section} section found")
        else:
            print(f"✗ {section} section NOT found")
    
    return True

def generate_validation_report(results, output_file):
    """Generate comprehensive validation report."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    report = []
    report.append("="*80)
    report.append("FINAL VALIDATION REPORT - TASK 13")
    report.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    report.append("="*80)
    report.append("")
    
    report.append("VALIDATION SUMMARY")
    report.append("-"*80)
    
    all_passed = all(results.values())
    
    for task, passed in results.items():
        status = "✓ PASSED" if passed else "✗ FAILED"
        report.append(f"{task}: {status}")
    
    report.append("")
    report.append("-"*80)
    
    if all_passed:
        report.append("OVERALL STATUS: ✓ ALL VALIDATIONS PASSED")
        report.append("")
        report.append("The document is ready for final compilation and submission.")
    else:
        report.append("OVERALL STATUS: ✗ SOME VALIDATIONS FAILED")
        report.append("")
        report.append("Please review the issues above and make necessary corrections.")
    
    report.append("")
    report.append("="*80)
    
    report_text = "\n".join(report)
    
    # Print to console
    print("\n" + report_text)
    
    # Write to file
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(report_text)
    
    print(f"\n✓ Validation report saved to: {output_file}")
    
    return all_passed

def main():
    """Main validation function."""
    print("="*80)
    print("FINAL VALIDATION - TASK 13: Final Validation and Submission Preparation")
    print("="*80)
    
    # File paths
    tex_file = 'artigo_classificacao_corrosao.tex'
    bib_file = 'referencias_classificacao.bib'
    output_file = f'final_validation_report_task13_{datetime.now().strftime("%Y%m%d_%H%M%S")}.txt'
    
    # Check if files exist
    if not os.path.exists(tex_file):
        print(f"✗ Error: {tex_file} not found")
        return False
    
    if not os.path.exists(bib_file):
        print(f"✗ Error: {bib_file} not found")
        return False
    
    # Read main document
    content = read_file(tex_file)
    if not content:
        print("✗ Error: Could not read main document")
        return False
    
    # Run validations
    results = {}
    
    # Task 13.1: Class consistency
    results['13.1 Class Consistency'] = validate_class_consistency(content)
    
    # Task 13.2: Reference validation
    results['13.2 Reference Citations'] = validate_references(content, bib_file)
    
    # Task 13.3: Figure/Table validation
    results['13.3 Figures and Tables'] = validate_figures_tables(content)
    
    # Additional: Document structure
    validate_document_structure(content)
    
    # Generate report
    all_passed = generate_validation_report(results, output_file)
    
    return all_passed

if __name__ == '__main__':
    success = main()
    exit(0 if success else 1)
