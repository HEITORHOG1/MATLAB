#!/usr/bin/env python3
"""
Validate all cross-references in MDPI document
"""

import re
from pathlib import Path

def extract_labels(tex_file):
    """Extract all labels from a LaTeX file"""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    labels = {
        'sec': [],
        'subsec': [],
        'subsubsec': [],
        'fig': [],
        'tab': [],
        'eq': []
    }
    
    # Find all labels
    label_pattern = r'\\label\{([^:}]+):([^}]+)\}'
    matches = re.finditer(label_pattern, content)
    
    for match in matches:
        label_type = match.group(1)
        label_name = match.group(2)
        
        if label_type in labels:
            labels[label_type].append(label_name)
    
    return labels

def extract_references(tex_file):
    """Extract all references from a LaTeX file"""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    references = {
        'sec': [],
        'subsec': [],
        'subsubsec': [],
        'fig': [],
        'tab': [],
        'eq': []
    }
    
    # Find all references
    ref_pattern = r'\\ref\{([^:}]+):([^}]+)\}'
    matches = re.finditer(ref_pattern, content)
    
    for match in matches:
        ref_type = match.group(1)
        ref_name = match.group(2)
        
        if ref_type in references:
            references[ref_type].append(ref_name)
    
    return references

def check_undefined_references(log_file):
    """Check LaTeX log for undefined references"""
    undefined = []
    
    try:
        with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # Find undefined reference warnings
        undefined_pattern = r'Reference `([^\']+)\' on page \d+ undefined'
        matches = re.finditer(undefined_pattern, content)
        
        for match in matches:
            undefined.append(match.group(1))
    except FileNotFoundError:
        pass
    
    return undefined

def main():
    mdpi_file = 'artigo_mdpi_classification.tex'
    log_file = 'artigo_mdpi_classification.log'
    
    print("=" * 80)
    print("CROSS-REFERENCE VALIDATION REPORT")
    print("=" * 80)
    print()
    
    # Extract labels and references
    labels = extract_labels(mdpi_file)
    references = extract_references(mdpi_file)
    
    # Validate each type
    print("1. SECTION REFERENCES")
    print("-" * 80)
    
    sec_labels = set(labels['sec'])
    sec_refs = set(references['sec'])
    
    print(f"Defined section labels: {len(sec_labels)}")
    print(f"Section references: {len(sec_refs)}")
    
    undefined_sec = sec_refs - sec_labels
    if undefined_sec:
        print(f"⚠️  Undefined section references: {undefined_sec}")
    else:
        print("✓ All section references are defined")
    print()
    
    print("2. SUBSECTION REFERENCES")
    print("-" * 80)
    
    subsec_labels = set(labels['subsec'])
    subsec_refs = set(references['subsec'])
    
    print(f"Defined subsection labels: {len(subsec_labels)}")
    print(f"Subsection references: {len(subsec_refs)}")
    
    undefined_subsec = subsec_refs - subsec_labels
    if undefined_subsec:
        print(f"⚠️  Undefined subsection references: {undefined_subsec}")
    else:
        print("✓ All subsection references are defined")
    print()
    
    print("3. FIGURE REFERENCES")
    print("-" * 80)
    
    fig_labels = set(labels['fig'])
    fig_refs = set(references['fig'])
    
    print(f"Defined figure labels: {len(fig_labels)}")
    print(f"Figure references: {len(fig_refs)}")
    print(f"Figures: {sorted(fig_labels)}")
    
    undefined_fig = fig_refs - fig_labels
    if undefined_fig:
        print(f"⚠️  Undefined figure references: {undefined_fig}")
    else:
        print("✓ All figure references are defined")
    print()
    
    print("4. TABLE REFERENCES")
    print("-" * 80)
    
    tab_labels = set(labels['tab'])
    tab_refs = set(references['tab'])
    
    print(f"Defined table labels: {len(tab_labels)}")
    print(f"Table references: {len(tab_refs)}")
    print(f"Tables: {sorted(tab_labels)}")
    
    undefined_tab = tab_refs - tab_labels
    if undefined_tab:
        print(f"⚠️  Undefined table references: {undefined_tab}")
    else:
        print("✓ All table references are defined")
    print()
    
    print("5. EQUATION REFERENCES")
    print("-" * 80)
    
    eq_labels = set(labels['eq'])
    eq_refs = set(references['eq'])
    
    print(f"Defined equation labels: {len(eq_labels)}")
    print(f"Equation references: {len(eq_refs)}")
    
    if eq_labels:
        print(f"Equations: {sorted(eq_labels)}")
    
    undefined_eq = eq_refs - eq_labels
    if undefined_eq:
        print(f"⚠️  Undefined equation references: {undefined_eq}")
    else:
        if eq_refs:
            print("✓ All equation references are defined")
        else:
            print("✓ No equation references (none expected)")
    print()
    
    print("6. LATEX LOG CHECK")
    print("-" * 80)
    
    log_undefined = check_undefined_references(log_file)
    
    if log_undefined:
        print(f"⚠️  LaTeX reported {len(log_undefined)} undefined references:")
        for ref in log_undefined:
            print(f"   - {ref}")
    else:
        print("✓ No undefined references in LaTeX log")
    print()
    
    # Summary
    print("7. SUMMARY")
    print("-" * 80)
    
    issues = []
    
    if undefined_sec:
        issues.append(f"Undefined section references: {len(undefined_sec)}")
    
    if undefined_subsec:
        issues.append(f"Undefined subsection references: {len(undefined_subsec)}")
    
    if undefined_fig:
        issues.append(f"Undefined figure references: {len(undefined_fig)}")
    
    if undefined_tab:
        issues.append(f"Undefined table references: {len(undefined_tab)}")
    
    if undefined_eq:
        issues.append(f"Undefined equation references: {len(undefined_eq)}")
    
    if log_undefined:
        issues.append(f"LaTeX log reports {len(log_undefined)} undefined references")
    
    if issues:
        print("⚠️  Issues found:")
        for issue in issues:
            print(f"   - {issue}")
    else:
        print("✓ Cross-reference validation PASSED")
        print("✓ All references resolve correctly")
    
    print()
    print("=" * 80)

if __name__ == "__main__":
    main()
