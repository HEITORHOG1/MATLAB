#!/usr/bin/env python3
"""
Script to check LaTeX syntax and identify potential issues
"""
import re
import os

def check_latex_syntax():
    if not os.path.exists('artigo_cientifico_corrosao.tex'):
        print("ERROR: artigo_cientifico_corrosao.tex not found!")
        return
    
    with open('artigo_cientifico_corrosao.tex', 'r', encoding='utf-8') as f:
        content = f.read()
    
    issues = []
    lines = content.split('\n')
    
    # Check for common LaTeX issues
    for i, line in enumerate(lines, 1):
        # Check for unmatched braces
        open_braces = line.count('{')
        close_braces = line.count('}')
        if open_braces != close_braces and '\\' in line:
            issues.append(f"Line {i}: Potential unmatched braces: {line.strip()}")
        
        # Check for missing image files
        if '\\includegraphics' in line:
            match = re.search(r'\\includegraphics.*\{([^}]+)\}', line)
            if match:
                img_path = match.group(1)
                if not os.path.exists(img_path):
                    issues.append(f"Line {i}: Image file not found: {img_path}")
                else:
                    print(f"✓ Image found: {img_path}")
        
        # Check for undefined references
        if '\\cite{' in line:
            citations = re.findall(r'\\cite\{([^}]+)\}', line)
            for citation in citations:
                print(f"Citation found: {citation}")
        
        # Check for figure labels
        if '\\label{' in line:
            labels = re.findall(r'\\label\{([^}]+)\}', line)
            for label in labels:
                print(f"Label found: {label}")
    
    # Check document structure
    begin_document = content.count('\\begin{document}')
    end_document = content.count('\\end{document}')
    
    if begin_document != 1:
        issues.append(f"Document should have exactly one \\begin{{document}}, found {begin_document}")
    
    if end_document != 1:
        issues.append(f"Document should have exactly one \\end{{document}}, found {end_document}")
    
    # Check for figure environments
    begin_figures = content.count('\\begin{figure}')
    end_figures = content.count('\\end{figure}')
    
    if begin_figures != end_figures:
        issues.append(f"Unmatched figure environments: {begin_figures} begin vs {end_figures} end")
    
    print(f"\n=== LaTeX Syntax Check Results ===")
    print(f"Total lines: {len(lines)}")
    print(f"Figure environments: {begin_figures}")
    print(f"Issues found: {len(issues)}")
    
    if issues:
        print("\n=== ISSUES FOUND ===")
        for issue in issues:
            print(f"⚠️  {issue}")
    else:
        print("\n✅ No syntax issues detected!")
    
    # Check available image files
    print(f"\n=== Available Images ===")
    if os.path.exists('figuras'):
        for file in os.listdir('figuras'):
            if file.endswith(('.svg', '.eps', '.png', '.jpg', '.pdf')):
                print(f"📁 figuras/{file}")
    
    return len(issues) == 0

if __name__ == "__main__":
    check_latex_syntax()