#!/usr/bin/env python3
"""
Final script to fix LaTeX file
"""

# Read the entire file
with open('artigo_cientifico_corrosao.tex', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the problematic line
content = content.replace('% \\end{figure}', '\\end{figure}')

# Write back
with open('artigo_cientifico_corrosao.tex', 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed all commented \\end{figure} lines")

# Verify the fix
with open('artigo_cientifico_corrosao.tex', 'r', encoding='utf-8') as f:
    lines = f.readlines()

begin_count = sum(1 for line in lines if '\\begin{figure}' in line)
end_count = sum(1 for line in lines if '\\end{figure}' in line)

print(f"Begin figure count: {begin_count}")
print(f"End figure count: {end_count}")

if begin_count == end_count:
    print("✅ Figure environments are balanced!")
else:
    print("❌ Figure environments are NOT balanced!")