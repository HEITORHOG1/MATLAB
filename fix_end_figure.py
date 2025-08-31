#!/usr/bin/env python3
"""
Simple script to fix the commented end figure
"""

# Read the file
with open('artigo_cientifico_corrosao.tex', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Fix line 447 (index 446)
if len(lines) > 446:
    if lines[446].strip() == '% \\end{figure}':
        lines[446] = '\\end{figure}\n'
        print("Fixed line 447: % \\end{figure} -> \\end{figure}")
    else:
        print(f"Line 447 content: '{lines[446].strip()}'")

# Write back
with open('artigo_cientifico_corrosao.tex', 'w', encoding='utf-8') as f:
    f.writelines(lines)

print("File updated successfully!")