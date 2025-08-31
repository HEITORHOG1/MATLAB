#!/usr/bin/env python3
"""
Script to fix LaTeX image references and uncomment figures
"""

def fix_latex_images():
    # Read the LaTeX file
    with open('artigo_cientifico_corrosao.tex', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # List of corrections to make
    corrections = [
        # Fix .eps to .svg extensions
        ('figuras/figura_performance_comparativa.eps', 'figuras/figura_performance_comparativa.svg'),
        ('figuras/figura_mapas_atencao.eps', 'figuras/figura_mapas_atencao.svg'),
        
        # Remove comment markers from figures
        ('% FIGURA TEMPORARIAMENTE COMENTADA - SVG NÃO SUPORTADO\n%', ''),
        ('% \\begin{figure}[H]', '\\begin{figure}[H]'),
        ('%     \\centering', '    \\centering'),
        ('%     \\includegraphics', '    \\includegraphics'),
        ('%     \\caption{', '    \\caption{'),
        ('%     \\label{', '    \\label{'),
        ('% \\end{figure}', '\\end{figure}'),
    ]
    
    # Apply corrections
    for old, new in corrections:
        content = content.replace(old, new)
    
    # Additional specific fixes for multi-line comments
    lines = content.split('\n')
    fixed_lines = []
    
    for line in lines:
        # Remove comment from figure-related lines
        if line.strip().startswith('% ') and any(keyword in line for keyword in ['\\begin{figure}', '\\end{figure}', '\\centering', '\\includegraphics', '\\caption{', '\\label{']):
            # Remove the '% ' prefix
            fixed_line = line.replace('% ', '', 1)
            fixed_lines.append(fixed_line)
        else:
            fixed_lines.append(line)
    
    content = '\n'.join(fixed_lines)
    
    # Write back the corrected content
    with open('artigo_cientifico_corrosao.tex', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("LaTeX image references fixed successfully!")
    print("Fixed:")
    print("- Changed .eps to .svg extensions where available")
    print("- Uncommented all figure blocks")
    print("- Removed temporary comment markers")

if __name__ == "__main__":
    fix_latex_images()