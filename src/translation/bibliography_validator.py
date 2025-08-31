#!/usr/bin/env python3
"""
Bibliography Validation Script for English Translation
Validates bibliography consistency and citation format for the translated article.
"""

import re
import sys
from pathlib import Path

def extract_bib_keys(bib_file_path):
    """Extract all bibliography keys from the .bib file."""
    bib_keys = set()
    
    with open(bib_file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all @article, @inproceedings, @book, @misc entries
    pattern = r'@(?:article|inproceedings|book|misc|manual)\s*\{\s*([^,\s]+)'
    matches = re.findall(pattern, content, re.IGNORECASE)
    
    for match in matches:
        bib_keys.add(match.strip())
    
    return bib_keys

def extract_citations(tex_file_path):
    """Extract all citations from the .tex file."""
    citations = set()
    
    with open(tex_file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all \cite{...} commands
    pattern = r'\\cite\s*\{\s*([^}]+)\s*\}'
    matches = re.findall(pattern, content)
    
    for match in matches:
        # Split multiple citations separated by commas
        cite_keys = [key.strip() for key in match.split(',')]
        citations.update(cite_keys)
    
    return citations

def validate_bibliography_format(bib_file_path):
    """Validate bibliography format and consistency."""
    issues = []
    
    with open(bib_file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check for Portuguese section headers
    portuguese_patterns = [
        r'SEÇÃO',
        r'REFERÊNCIAS',
        r'NORMAS E PADRÕES',
        r'DETECÇÃO DE CORROSÃO',
        r'MECANISMOS DE ATENÇÃO'
    ]
    
    for pattern in portuguese_patterns:
        if re.search(pattern, content):
            issues.append(f"Portuguese text found: {pattern}")
    
    # Check for inconsistent entry types
    lines = content.split('\n')
    for i, line in enumerate(lines):
        # Check for @article entries with booktitle
        if re.match(r'@article', line, re.IGNORECASE):
            # Look ahead for booktitle in the next few lines
            for j in range(i+1, min(i+10, len(lines))):
                if 'booktitle' in lines[j]:
                    issues.append(f"Line {i+1}: @article entry has booktitle (should be @inproceedings)")
                    break
        
        # Check for journal entries that should be publishers
        if 'journal' in line and any(pub in line for pub in ['MIT Press', 'Springer', 'Wiley', 'McGraw-Hill']):
            issues.append(f"Line {i+1}: Publisher in journal field")
    
    return issues

def validate_citation_consistency(tex_file_path, bib_file_path):
    """Validate that all citations have corresponding bibliography entries."""
    bib_keys = extract_bib_keys(bib_file_path)
    citations = extract_citations(tex_file_path)
    
    missing_refs = citations - bib_keys
    unused_refs = bib_keys - citations
    
    return missing_refs, unused_refs

def main():
    """Main validation function."""
    tex_file = "artigo_cientifico_corrosao.tex"
    bib_file = "referencias.bib"
    
    print("Bibliography Validation Report")
    print("=" * 50)
    
    # Check if files exist
    if not Path(tex_file).exists():
        print(f"ERROR: {tex_file} not found")
        return 1
    
    if not Path(bib_file).exists():
        print(f"ERROR: {bib_file} not found")
        return 1
    
    # Validate bibliography format
    print("\n1. Bibliography Format Validation:")
    format_issues = validate_bibliography_format(bib_file)
    
    if format_issues:
        print("   Issues found:")
        for issue in format_issues:
            print(f"   - {issue}")
    else:
        print("   ✓ No format issues found")
    
    # Validate citation consistency
    print("\n2. Citation Consistency Validation:")
    missing_refs, unused_refs = validate_citation_consistency(tex_file, bib_file)
    
    if missing_refs:
        print("   Missing bibliography entries:")
        for ref in sorted(missing_refs):
            print(f"   - {ref}")
    else:
        print("   ✓ All citations have corresponding bibliography entries")
    
    if unused_refs:
        print("   Unused bibliography entries:")
        for ref in sorted(unused_refs):
            print(f"   - {ref}")
    else:
        print("   ✓ All bibliography entries are cited")
    
    # Summary
    print("\n3. Summary:")
    total_issues = len(format_issues) + len(missing_refs)
    
    if total_issues == 0:
        print("   ✓ Bibliography validation passed successfully")
        return 0
    else:
        print(f"   ⚠ Found {total_issues} issues that need attention")
        return 1

if __name__ == "__main__":
    sys.exit(main())