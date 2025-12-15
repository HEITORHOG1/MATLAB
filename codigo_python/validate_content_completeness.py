#!/usr/bin/env python3
"""
Validate content completeness between ASCE and MDPI versions
"""

import re
from pathlib import Path

def extract_sections(tex_file):
    """Extract all section, subsection, and subsubsection titles from a LaTeX file"""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    sections = []
    
    # Find all section commands
    section_pattern = r'\\(section|subsection|subsubsection)\{([^}]+)\}'
    matches = re.finditer(section_pattern, content)
    
    for match in matches:
        level = match.group(1)
        title = match.group(2)
        sections.append((level, title))
    
    return sections

def extract_figures(tex_file):
    """Extract all figure labels from a LaTeX file"""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    figures = []
    
    # Find all figure labels
    fig_pattern = r'\\label\{fig:([^}]+)\}'
    matches = re.finditer(fig_pattern, content)
    
    for match in matches:
        figures.append(match.group(1))
    
    return figures

def extract_tables(tex_file):
    """Extract all table labels from a LaTeX file"""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    tables = []
    
    # Find all table labels
    tab_pattern = r'\\label\{tab:([^}]+)\}'
    matches = re.finditer(tab_pattern, content)
    
    for match in matches:
        tables.append(match.group(1))
    
    return tables

def count_citations(tex_file):
    """Count number of citations in a LaTeX file"""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all citations
    cite_pattern = r'\\cite\{[^}]+\}'
    citations = re.findall(cite_pattern, content)
    
    return len(citations)

def main():
    asce_file = 'artigo_pure_classification.tex'
    mdpi_file = 'artigo_mdpi_classification.tex'
    
    print("=" * 80)
    print("CONTENT COMPLETENESS VALIDATION REPORT")
    print("=" * 80)
    print()
    
    # Compare sections
    print("1. SECTION STRUCTURE COMPARISON")
    print("-" * 80)
    
    asce_sections = extract_sections(asce_file)
    mdpi_sections = extract_sections(mdpi_file)
    
    print(f"ASCE version: {len(asce_sections)} sections")
    print(f"MDPI version: {len(mdpi_sections)} sections")
    print()
    
    print("ASCE Sections:")
    for level, title in asce_sections:
        indent = "  " * (0 if level == "section" else 1 if level == "subsection" else 2)
        print(f"{indent}- {title}")
    
    print()
    print("MDPI Sections:")
    for level, title in mdpi_sections:
        indent = "  " * (0 if level == "section" else 1 if level == "subsection" else 2)
        print(f"{indent}- {title}")
    
    print()
    
    # Compare figures
    print("2. FIGURE COMPARISON")
    print("-" * 80)
    
    asce_figures = extract_figures(asce_file)
    mdpi_figures = extract_figures(mdpi_file)
    
    print(f"ASCE version: {len(asce_figures)} figures")
    print(f"MDPI version: {len(mdpi_figures)} figures")
    print()
    
    print("ASCE Figures:", asce_figures)
    print("MDPI Figures:", mdpi_figures)
    print()
    
    missing_figures = set(asce_figures) - set(mdpi_figures)
    if missing_figures:
        print(f"⚠️  Missing figures in MDPI: {missing_figures}")
    else:
        print("✓ All figures present in MDPI version")
    print()
    
    # Compare tables
    print("3. TABLE COMPARISON")
    print("-" * 80)
    
    asce_tables = extract_tables(asce_file)
    mdpi_tables = extract_tables(mdpi_file)
    
    print(f"ASCE version: {len(asce_tables)} tables")
    print(f"MDPI version: {len(mdpi_tables)} tables")
    print()
    
    print("ASCE Tables:", asce_tables)
    print("MDPI Tables:", mdpi_tables)
    print()
    
    missing_tables = set(asce_tables) - set(mdpi_tables)
    if missing_tables:
        print(f"⚠️  Missing tables in MDPI: {missing_tables}")
    else:
        print("✓ All tables present in MDPI version")
    print()
    
    # Compare citations
    print("4. CITATION COMPARISON")
    print("-" * 80)
    
    asce_citations = count_citations(asce_file)
    mdpi_citations = count_citations(mdpi_file)
    
    print(f"ASCE version: {asce_citations} citations")
    print(f"MDPI version: {mdpi_citations} citations")
    
    if asce_citations == mdpi_citations:
        print("✓ Citation count matches")
    else:
        diff = mdpi_citations - asce_citations
        print(f"⚠️  Citation count difference: {diff:+d}")
    print()
    
    # Summary
    print("5. SUMMARY")
    print("-" * 80)
    
    issues = []
    
    if len(mdpi_sections) < len(asce_sections):
        issues.append(f"Missing {len(asce_sections) - len(mdpi_sections)} sections")
    
    if missing_figures:
        issues.append(f"Missing {len(missing_figures)} figures")
    
    if missing_tables:
        issues.append(f"Missing {len(missing_tables)} tables")
    
    if abs(asce_citations - mdpi_citations) > 5:
        issues.append(f"Significant citation count difference ({abs(asce_citations - mdpi_citations)})")
    
    if issues:
        print("⚠️  Issues found:")
        for issue in issues:
            print(f"   - {issue}")
    else:
        print("✓ Content completeness validation PASSED")
        print("✓ All scientific content appears to be preserved")
    
    print()
    print("=" * 80)

if __name__ == "__main__":
    main()
