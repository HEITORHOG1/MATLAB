#!/usr/bin/env python3
"""
Validate MDPI format compliance
"""

import re
from pathlib import Path

def check_document_class(tex_file):
    """Check if document class is MDPI"""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check for MDPI document class
    doc_class_pattern = r'\\documentclass\[([^\]]*)\]\{([^}]+)\}'
    match = re.search(doc_class_pattern, content)
    
    if match:
        options = match.group(1)
        doc_class = match.group(2)
        return doc_class, options
    
    return None, None

def check_metadata_sections(tex_file):
    """Check for required MDPI metadata sections"""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    required_sections = {
        'Title': r'\\Title\{',
        'Author': r'\\Author\{',
        'Address': r'\\address\{',
        'Correspondence': r'\\corres\{',
        'Abstract': r'\\abstract\{',
        'Keywords': r'\\keyword\{',
        'Author Contributions': r'\\authorcontributions\{',
        'Funding': r'\\funding\{',
        'Institutional Review': r'\\institutionalreview\{',
        'Informed Consent': r'\\informedconsent\{',
        'Data Availability': r'\\dataavailability\{',
        'Conflicts of Interest': r'\\conflictsofinterest\{'
    }
    
    found = {}
    
    for section, pattern in required_sections.items():
        match = re.search(pattern, content)
        found[section] = match is not None
    
    return found

def check_abstract_length(tex_file):
    """Check abstract word count"""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract abstract content
    abstract_pattern = r'\\abstract\{([^}]+(?:\{[^}]*\}[^}]*)*)\}'
    match = re.search(abstract_pattern, content)
    
    if match:
        abstract_text = match.group(1)
        # Remove LaTeX commands
        clean_text = re.sub(r'\\[a-zA-Z]+\{[^}]*\}', '', abstract_text)
        clean_text = re.sub(r'\\[a-zA-Z]+', '', clean_text)
        # Count words
        words = clean_text.split()
        return len(words)
    
    return 0

def check_keywords(tex_file):
    """Check keywords format and count"""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract keywords
    keyword_pattern = r'\\keyword\{([^}]+)\}'
    match = re.search(keyword_pattern, content)
    
    if match:
        keywords_text = match.group(1)
        # Split by semicolon
        keywords = [k.strip() for k in keywords_text.split(';')]
        return keywords
    
    return []

def check_bibliography_style(tex_file):
    """Check bibliography configuration"""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check for bibliography style
    bib_style_pattern = r'\\bibliographystyle\{([^}]+)\}'
    style_match = re.search(bib_style_pattern, content)
    
    # Check for bibliography file
    bib_file_pattern = r'\\bibliography\{([^}]+)\}'
    file_match = re.search(bib_file_pattern, content)
    
    return style_match, file_match

def get_page_count(log_file):
    """Extract page count from LaTeX log"""
    try:
        with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # Find output written line
        output_pattern = r'Output written on [^\(]+\((\d+) pages'
        match = re.search(output_pattern, content)
        
        if match:
            return int(match.group(1))
    except FileNotFoundError:
        pass
    
    return None

def main():
    mdpi_file = 'artigo_mdpi_classification.tex'
    log_file = 'artigo_mdpi_classification.log'
    
    print("=" * 80)
    print("MDPI FORMAT COMPLIANCE VALIDATION REPORT")
    print("=" * 80)
    print()
    
    # Check document class
    print("1. DOCUMENT CLASS")
    print("-" * 80)
    
    doc_class, options = check_document_class(mdpi_file)
    
    if doc_class:
        print(f"Document class: {doc_class}")
        print(f"Options: {options}")
        
        if 'mdpi' in doc_class.lower():
            print("✓ Using MDPI document class")
        else:
            print("⚠️  Not using MDPI document class")
    else:
        print("⚠️  Could not detect document class")
    print()
    
    # Check metadata sections
    print("2. REQUIRED METADATA SECTIONS")
    print("-" * 80)
    
    metadata = check_metadata_sections(mdpi_file)
    
    for section, found in metadata.items():
        status = "✓" if found else "⚠️ "
        print(f"{status} {section}: {'Present' if found else 'Missing'}")
    
    missing_count = sum(1 for found in metadata.values() if not found)
    
    if missing_count == 0:
        print("\n✓ All required metadata sections present")
    else:
        print(f"\n⚠️  {missing_count} required metadata sections missing")
    print()
    
    # Check abstract
    print("3. ABSTRACT")
    print("-" * 80)
    
    abstract_words = check_abstract_length(mdpi_file)
    
    print(f"Abstract word count: {abstract_words}")
    
    if 150 <= abstract_words <= 250:
        print("✓ Abstract length within recommended range (150-250 words)")
    elif abstract_words < 150:
        print("⚠️  Abstract is shorter than recommended (< 150 words)")
    else:
        print("⚠️  Abstract is longer than recommended (> 250 words)")
    print()
    
    # Check keywords
    print("4. KEYWORDS")
    print("-" * 80)
    
    keywords = check_keywords(mdpi_file)
    
    print(f"Number of keywords: {len(keywords)}")
    print(f"Keywords: {'; '.join(keywords)}")
    
    if 3 <= len(keywords) <= 10:
        print("✓ Keyword count within required range (3-10)")
    else:
        print("⚠️  Keyword count outside required range (3-10)")
    
    # Check for semicolon separation
    if len(keywords) > 1:
        print("✓ Keywords properly formatted with semicolons")
    print()
    
    # Check bibliography
    print("5. BIBLIOGRAPHY")
    print("-" * 80)
    
    style_match, file_match = check_bibliography_style(mdpi_file)
    
    if style_match:
        print(f"Bibliography style: {style_match.group(1)}")
    else:
        print("⚠️  No bibliography style specified")
    
    if file_match:
        print(f"Bibliography file: {file_match.group(1)}")
        print("✓ Bibliography configured")
    else:
        print("⚠️  No bibliography file specified")
    print()
    
    # Check page count
    print("6. PAGE COUNT")
    print("-" * 80)
    
    page_count = get_page_count(log_file)
    
    if page_count:
        print(f"Total pages: {page_count}")
        
        if 20 <= page_count <= 25:
            print("✓ Page count within MDPI recommended range (20-25 pages)")
        elif page_count < 20:
            print("✓ Page count below maximum (< 25 pages)")
        else:
            print("⚠️  Page count exceeds recommended maximum (> 25 pages)")
    else:
        print("⚠️  Could not determine page count from log")
    print()
    
    # Summary
    print("7. SUMMARY")
    print("-" * 80)
    
    issues = []
    
    if doc_class and 'mdpi' not in doc_class.lower():
        issues.append("Not using MDPI document class")
    
    if missing_count > 0:
        issues.append(f"{missing_count} required metadata sections missing")
    
    if not (150 <= abstract_words <= 250):
        issues.append(f"Abstract length outside recommended range ({abstract_words} words)")
    
    if not (3 <= len(keywords) <= 10):
        issues.append(f"Keyword count outside required range ({len(keywords)} keywords)")
    
    if not file_match:
        issues.append("Bibliography not configured")
    
    if page_count and page_count > 25:
        issues.append(f"Page count exceeds recommended maximum ({page_count} pages)")
    
    if issues:
        print("⚠️  Issues found:")
        for issue in issues:
            print(f"   - {issue}")
    else:
        print("✓ MDPI format compliance validation PASSED")
        print("✓ Document meets all MDPI formatting requirements")
    
    print()
    print("=" * 80)

if __name__ == "__main__":
    main()
