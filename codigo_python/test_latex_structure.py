#!/usr/bin/env python3
"""
Simple LaTeX Structure Test

Tests basic LaTeX structure without requiring full compilation.
"""

import re
import os
from pathlib import Path

def test_latex_structure():
    """Test basic LaTeX document structure."""
    tex_file = "artigo_cientifico_corrosao.tex"
    
    if not os.path.exists(tex_file):
        print(f"❌ LaTeX file not found: {tex_file}")
        return False
    
    try:
        with open(tex_file, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"❌ Error reading LaTeX file: {e}")
        return False
    
    print("Testing LaTeX document structure...")
    
    # Test 1: Basic document structure
    tests = [
        (r'\\documentclass', "Document class declaration"),
        (r'\\begin\{document\}', "Document begin"),
        (r'\\end\{document\}', "Document end"),
        (r'\\usepackage\[english\]\{babel\}', "English babel package"),
        (r'\\usepackage\{amsmath', "Math package"),
        (r'\\usepackage\{graphicx\}', "Graphics package"),
    ]
    
    passed = 0
    total = len(tests)
    
    for pattern, description in tests:
        if re.search(pattern, content):
            print(f"✓ {description}")
            passed += 1
        else:
            print(f"❌ {description}")
    
    # Test 2: Mathematical equations
    equations = re.findall(r'\\begin\{equation\}.*?\\end\{equation\}', content, re.DOTALL)
    print(f"✓ Found {len(equations)} mathematical equations")
    
    # Test 3: Figure references
    fig_labels = re.findall(r'\\label\{fig:([^}]+)\}', content)
    fig_refs = re.findall(r'\\ref\{fig:([^}]+)\}', content)
    print(f"✓ Found {len(fig_labels)} figure labels and {len(fig_refs)} figure references")
    
    # Test 4: Table references  
    tab_labels = re.findall(r'\\label\{tab:([^}]+)\}', content)
    tab_refs = re.findall(r'\\ref\{tab:([^}]+)\}', content)
    print(f"✓ Found {len(tab_labels)} table labels and {len(tab_refs)} table references")
    
    success_rate = (passed / total) * 100
    print(f"\nStructure test results: {passed}/{total} passed ({success_rate:.1f}%)")
    
    return success_rate >= 80

if __name__ == "__main__":
    success = test_latex_structure()
    print(f"\n{'✓ LaTeX structure test PASSED' if success else '❌ LaTeX structure test FAILED'}")