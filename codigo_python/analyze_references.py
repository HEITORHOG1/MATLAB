#!/usr/bin/env python3
"""
Analyze reference usage in the classification paper.
Counts citations per reference, identifies non-essential citations, and finds redundant references.
"""

import re
from collections import defaultdict
from pathlib import Path

def extract_citations_from_tex(tex_file):
    """Extract all citations from the LaTeX file."""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all \cite{...} commands
    # Matches \cite{key1,key2,key3} and extracts individual keys
    citation_pattern = r'\\cite\{([^}]+)\}'
    matches = re.findall(citation_pattern, content)
    
    citations = []
    for match in matches:
        # Split by comma to handle multiple citations
        keys = [key.strip() for key in match.split(',')]
        citations.extend(keys)
    
    return citations

def extract_references_from_bib(bib_file):
    """Extract all reference keys from the bibliography file."""
    with open(bib_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all @article, @book, @inproceedings, etc.
    ref_pattern = r'@\w+\{([^,]+),'
    references = re.findall(ref_pattern, content)
    
    return references

def categorize_references(bib_file):
    """Categorize references by type based on comments in bib file."""
    with open(bib_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    categories = {}
    current_category = "Uncategorized"
    
    lines = content.split('\n')
    for line in lines:
        # Check for category comments
        if line.strip().startswith('%') and '=' in line:
            current_category = line.strip('% =').strip()
        elif line.strip().startswith('@'):
            # Extract reference key
            match = re.match(r'@\w+\{([^,]+),', line)
            if match:
                ref_key = match.group(1)
                categories[ref_key] = current_category
    
    return categories

def analyze_citation_context(tex_file, citation_key):
    """Analyze the context where a citation appears."""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find sentences containing this citation
    contexts = []
    pattern = rf'[^.]*\\cite\{{[^}}]*{re.escape(citation_key)}[^}}]*\}}[^.]*\.'
    matches = re.findall(pattern, content)
    
    return matches

def main():
    tex_file = 'artigo_classificacao_corrosao.tex'
    bib_file = 'referencias_classificacao.bib'
    
    print("=" * 80)
    print("REFERENCE USAGE ANALYSIS - PASS 7")
    print("=" * 80)
    print()
    
    # Extract citations and references
    citations = extract_citations_from_tex(tex_file)
    references = extract_references_from_bib(bib_file)
    categories = categorize_references(bib_file)
    
    # Count citations per reference
    citation_counts = defaultdict(int)
    for citation in citations:
        citation_counts[citation] += 1
    
    print(f"Total citations in text: {len(citations)}")
    print(f"Unique references cited: {len(citation_counts)}")
    print(f"Total references in bibliography: {len(references)}")
    print(f"Uncited references: {len(references) - len(citation_counts)}")
    print()
    
    # Identify uncited references
    uncited = set(references) - set(citation_counts.keys())
    if uncited:
        print("UNCITED REFERENCES (to be removed):")
        print("-" * 80)
        for ref in sorted(uncited):
            category = categories.get(ref, "Unknown")
            print(f"  - {ref} ({category})")
        print()
    
    # Sort references by citation count
    sorted_refs = sorted(citation_counts.items(), key=lambda x: x[1], reverse=True)
    
    print("CITATION FREQUENCY ANALYSIS:")
    print("-" * 80)
    print(f"{'Reference':<40} {'Count':<8} {'Category'}")
    print("-" * 80)
    
    for ref, count in sorted_refs:
        category = categories.get(ref, "Unknown")
        print(f"{ref:<40} {count:<8} {category}")
    
    print()
    
    # Identify single-citation references (potential candidates for removal)
    single_citations = [ref for ref, count in citation_counts.items() if count == 1]
    print(f"SINGLE-CITATION REFERENCES ({len(single_citations)} total):")
    print("-" * 80)
    print("These may be candidates for removal if not essential:")
    print()
    
    # Group by category
    single_by_category = defaultdict(list)
    for ref in single_citations:
        category = categories.get(ref, "Unknown")
        single_by_category[category].append(ref)
    
    for category in sorted(single_by_category.keys()):
        refs = single_by_category[category]
        print(f"{category} ({len(refs)}):")
        for ref in sorted(refs):
            print(f"  - {ref}")
        print()
    
    # Identify heavily cited references (essential)
    essential_threshold = 3
    essential_refs = [ref for ref, count in citation_counts.items() if count >= essential_threshold]
    print(f"ESSENTIAL REFERENCES (cited {essential_threshold}+ times, {len(essential_refs)} total):")
    print("-" * 80)
    for ref in sorted(essential_refs, key=lambda x: citation_counts[x], reverse=True):
        count = citation_counts[ref]
        category = categories.get(ref, "Unknown")
        print(f"  - {ref} ({count} citations) - {category}")
    print()
    
    # Analyze by category
    print("REFERENCES BY CATEGORY:")
    print("-" * 80)
    category_stats = defaultdict(lambda: {'total': 0, 'cited': 0, 'citations': 0})
    
    for ref in references:
        category = categories.get(ref, "Unknown")
        category_stats[category]['total'] += 1
        if ref in citation_counts:
            category_stats[category]['cited'] += 1
            category_stats[category]['citations'] += citation_counts[ref]
    
    for category in sorted(category_stats.keys()):
        stats = category_stats[category]
        print(f"{category}:")
        print(f"  Total references: {stats['total']}")
        print(f"  Cited references: {stats['cited']}")
        print(f"  Total citations: {stats['citations']}")
        print(f"  Avg citations per ref: {stats['citations']/stats['cited']:.2f}" if stats['cited'] > 0 else "  Avg citations per ref: 0.00")
        print()
    
    # Recommendations
    print("=" * 80)
    print("RECOMMENDATIONS:")
    print("=" * 80)
    print()
    
    print("1. REMOVE UNCITED REFERENCES:")
    print(f"   Remove {len(uncited)} uncited references from bibliography")
    print()
    
    print("2. REVIEW SINGLE-CITATION REFERENCES:")
    print(f"   Review {len(single_citations)} references cited only once")
    print("   Consider removing if:")
    print("   - Not seminal work in the field")
    print("   - Not directly related to methodology or results")
    print("   - Tangential or background information only")
    print()
    
    print("3. POTENTIAL CANDIDATES FOR REMOVAL (single citations):")
    # Identify specific candidates based on category
    removal_candidates = []
    
    # Future work references (less essential)
    future_work_cats = ['EXPLAINABILITY AND VISUALIZATION', 'OPTIMIZATION AND TRAINING']
    for cat in future_work_cats:
        if cat in single_by_category:
            removal_candidates.extend(single_by_category[cat])
    
    if removal_candidates:
        print("   High priority for removal (future work, optimization):")
        for ref in sorted(removal_candidates)[:10]:  # Top 10
            category = categories.get(ref, "Unknown")
            print(f"   - {ref} ({category})")
    print()
    
    print("4. KEEP ESSENTIAL REFERENCES:")
    print(f"   Keep all {len(essential_refs)} references cited {essential_threshold}+ times")
    print("   These are core to the paper's narrative")
    print()
    
    # Estimate page savings
    avg_ref_lines = 4  # Average lines per reference
    lines_per_page = 50  # Approximate
    potential_removals = len(uncited) + len(removal_candidates)
    estimated_lines_saved = potential_removals * avg_ref_lines
    estimated_pages_saved = estimated_lines_saved / lines_per_page
    
    print(f"5. ESTIMATED SPACE SAVINGS:")
    print(f"   Potential removals: {potential_removals} references")
    print(f"   Estimated lines saved: {estimated_lines_saved}")
    print(f"   Estimated pages saved: {estimated_pages_saved:.2f}")
    print()
    
    # Save detailed report
    report_file = 'pass7_reference_analysis.md'
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write("# Pass 7: Reference Usage Analysis\n\n")
        f.write("## Summary Statistics\n\n")
        f.write(f"- Total citations in text: {len(citations)}\n")
        f.write(f"- Unique references cited: {len(citation_counts)}\n")
        f.write(f"- Total references in bibliography: {len(references)}\n")
        f.write(f"- Uncited references: {len(uncited)}\n")
        f.write(f"- Single-citation references: {len(single_citations)}\n")
        f.write(f"- Essential references (3+ citations): {len(essential_refs)}\n\n")
        
        f.write("## Uncited References (Remove)\n\n")
        for ref in sorted(uncited):
            category = categories.get(ref, "Unknown")
            f.write(f"- `{ref}` - {category}\n")
        f.write("\n")
        
        f.write("## Single-Citation References (Review)\n\n")
        for category in sorted(single_by_category.keys()):
            refs = single_by_category[category]
            f.write(f"### {category} ({len(refs)})\n\n")
            for ref in sorted(refs):
                f.write(f"- `{ref}`\n")
            f.write("\n")
        
        f.write("## Citation Frequency\n\n")
        f.write("| Reference | Citations | Category |\n")
        f.write("|-----------|-----------|----------|\n")
        for ref, count in sorted_refs:
            category = categories.get(ref, "Unknown")
            f.write(f"| `{ref}` | {count} | {category} |\n")
        f.write("\n")
        
        f.write("## Recommendations\n\n")
        f.write(f"1. Remove {len(uncited)} uncited references\n")
        f.write(f"2. Review {len(single_citations)} single-citation references\n")
        f.write(f"3. Estimated space savings: {estimated_pages_saved:.2f} pages\n")
    
    print(f"Detailed report saved to: {report_file}")
    print()

if __name__ == '__main__':
    main()
