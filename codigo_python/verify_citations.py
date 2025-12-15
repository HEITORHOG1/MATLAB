#!/usr/bin/env python3
"""
Verify that all citations in text have corresponding bibliography entries.
"""

import re

def extract_citations_from_tex(tex_file):
    """Extract all citations from the LaTeX file."""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    citation_pattern = r'\\cite\{([^}]+)\}'
    matches = re.findall(citation_pattern, content)
    
    citations = []
    for match in matches:
        keys = [key.strip() for key in match.split(',')]
        citations.extend(keys)
    
    return set(citations)

def extract_references_from_bib(bib_file):
    """Extract all reference keys from the bibliography file."""
    with open(bib_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    ref_pattern = r'@\w+\{([^,]+),'
    references = re.findall(ref_pattern, content)
    
    return set(references)

def main():
    tex_file = 'artigo_classificacao_corrosao.tex'
    bib_file = 'referencias_classificacao.bib'
    
    citations = extract_citations_from_tex(tex_file)
    references = extract_references_from_bib(bib_file)
    
    print("Citations in text:", len(citations))
    print("References in bibliography:", len(references))
    print()
    
    # Find citations without bibliography entries
    missing_refs = citations - references
    if missing_refs:
        print("CITATIONS WITHOUT BIBLIOGRAPHY ENTRIES:")
        for ref in sorted(missing_refs):
            print(f"  - {ref}")
        print()
    
    # Find bibliography entries without citations
    unused_refs = references - citations
    if unused_refs:
        print("BIBLIOGRAPHY ENTRIES WITHOUT CITATIONS:")
        for ref in sorted(unused_refs):
            print(f"  - {ref}")
        print()
    
    if not missing_refs and not unused_refs:
        print("✓ All citations have bibliography entries")
        print("✓ All bibliography entries are cited")
    
    return len(missing_refs) == 0 and len(unused_refs) == 0

if __name__ == '__main__':
    success = main()
    exit(0 if success else 1)
