#!/usr/bin/env python3
"""
Validate all visual elements (figures and tables) in MDPI document
"""

import re
from pathlib import Path

def extract_figure_info(tex_file):
    """Extract figure labels, captions, and references"""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    figures = {}
    
    # Find all figure environments
    fig_pattern = r'\\begin\{figure\}.*?\\end\{figure\}'
    fig_matches = re.finditer(fig_pattern, content, re.DOTALL)
    
    for match in fig_matches:
        fig_content = match.group(0)
        
        # Extract label
        label_match = re.search(r'\\label\{fig:([^}]+)\}', fig_content)
        if label_match:
            label = label_match.group(1)
            
            # Extract caption
            caption_match = re.search(r'\\caption\{([^}]+(?:\{[^}]*\}[^}]*)*)\}', fig_content)
            caption = caption_match.group(1) if caption_match else "No caption"
            
            # Extract includegraphics
            graphics_match = re.search(r'\\includegraphics.*?\{([^}]+)\}', fig_content)
            graphics_file = graphics_match.group(1) if graphics_match else "No file"
            
            figures[label] = {
                'caption': caption,
                'file': graphics_file
            }
    
    # Find all figure references
    ref_pattern = r'\\ref\{fig:([^}]+)\}'
    references = re.findall(ref_pattern, content)
    
    return figures, references

def extract_table_info(tex_file):
    """Extract table labels, captions, and references"""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    tables = {}
    
    # Find all table environments
    tab_pattern = r'\\begin\{table\}.*?\\end\{table\}'
    tab_matches = re.finditer(tab_pattern, content, re.DOTALL)
    
    for match in tab_matches:
        tab_content = match.group(0)
        
        # Extract label
        label_match = re.search(r'\\label\{tab:([^}]+)\}', tab_content)
        if label_match:
            label = label_match.group(1)
            
            # Extract caption
            caption_match = re.search(r'\\caption\{([^}]+(?:\{[^}]*\}[^}]*)*)\}', tab_content)
            caption = caption_match.group(1) if caption_match else "No caption"
            
            tables[label] = {
                'caption': caption
            }
    
    # Find all table references
    ref_pattern = r'\\ref\{tab:([^}]+)\}'
    references = re.findall(ref_pattern, content)
    
    return tables, references

def check_file_exists(filepath):
    """Check if a figure file exists"""
    # Try with and without extension
    base_path = Path(filepath)
    
    if base_path.exists():
        return True
    
    # Try with .pdf extension
    pdf_path = base_path.with_suffix('.pdf')
    if pdf_path.exists():
        return True
    
    # Try with .png extension
    png_path = base_path.with_suffix('.png')
    if png_path.exists():
        return True
    
    return False

def main():
    mdpi_file = 'artigo_mdpi_classification.tex'
    
    print("=" * 80)
    print("VISUAL ELEMENTS VALIDATION REPORT")
    print("=" * 80)
    print()
    
    # Validate figures
    print("1. FIGURE VALIDATION")
    print("-" * 80)
    
    figures, fig_refs = extract_figure_info(mdpi_file)
    
    print(f"Total figures defined: {len(figures)}")
    print(f"Total figure references: {len(fig_refs)}")
    print()
    
    for label, info in figures.items():
        print(f"Figure: fig:{label}")
        print(f"  Caption: {info['caption'][:80]}...")
        print(f"  File: {info['file']}")
        
        # Check if file exists
        file_exists = check_file_exists(info['file'])
        if file_exists:
            print(f"  ✓ File exists")
        else:
            print(f"  ⚠️  File not found")
        
        # Check if referenced
        ref_count = fig_refs.count(label)
        if ref_count > 0:
            print(f"  ✓ Referenced {ref_count} time(s) in text")
        else:
            print(f"  ⚠️  Not referenced in text")
        
        print()
    
    # Check for unreferenced figure references
    unique_refs = set(fig_refs)
    defined_labels = set(figures.keys())
    undefined_refs = unique_refs - defined_labels
    
    if undefined_refs:
        print(f"⚠️  Undefined figure references: {undefined_refs}")
    else:
        print("✓ All figure references are defined")
    print()
    
    # Validate tables
    print("2. TABLE VALIDATION")
    print("-" * 80)
    
    tables, tab_refs = extract_table_info(mdpi_file)
    
    print(f"Total tables defined: {len(tables)}")
    print(f"Total table references: {len(tab_refs)}")
    print()
    
    for label, info in tables.items():
        print(f"Table: tab:{label}")
        print(f"  Caption: {info['caption'][:80]}...")
        
        # Check if referenced
        ref_count = tab_refs.count(label)
        if ref_count > 0:
            print(f"  ✓ Referenced {ref_count} time(s) in text")
        else:
            print(f"  ⚠️  Not referenced in text")
        
        print()
    
    # Check for unreferenced table references
    unique_tab_refs = set(tab_refs)
    defined_tab_labels = set(tables.keys())
    undefined_tab_refs = unique_tab_refs - defined_tab_labels
    
    if undefined_tab_refs:
        print(f"⚠️  Undefined table references: {undefined_tab_refs}")
    else:
        print("✓ All table references are defined")
    print()
    
    # Summary
    print("3. SUMMARY")
    print("-" * 80)
    
    issues = []
    
    # Check for missing figure files
    missing_files = [label for label, info in figures.items() if not check_file_exists(info['file'])]
    if missing_files:
        issues.append(f"Missing figure files: {missing_files}")
    
    # Check for unreferenced figures
    unreferenced_figs = [label for label in figures.keys() if fig_refs.count(label) == 0]
    if unreferenced_figs:
        issues.append(f"Unreferenced figures: {unreferenced_figs}")
    
    # Check for unreferenced tables
    unreferenced_tabs = [label for label in tables.keys() if tab_refs.count(label) == 0]
    if unreferenced_tabs:
        issues.append(f"Unreferenced tables: {unreferenced_tabs}")
    
    # Check for undefined references
    if undefined_refs:
        issues.append(f"Undefined figure references: {undefined_refs}")
    
    if undefined_tab_refs:
        issues.append(f"Undefined table references: {undefined_tab_refs}")
    
    if issues:
        print("⚠️  Issues found:")
        for issue in issues:
            print(f"   - {issue}")
    else:
        print("✓ Visual elements validation PASSED")
        print("✓ All figures and tables are properly defined and referenced")
    
    print()
    print("=" * 80)

if __name__ == "__main__":
    main()
