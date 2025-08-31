#!/usr/bin/env python3
"""
Script para corrigir as referências de figuras no LaTeX
"""

import os
import re

def fix_latex_figures():
    """Corrige as referências de figuras no arquivo LaTeX"""
    latex_file = "artigo_cientifico_corrosao.tex"
    
    # Lê o arquivo LaTeX
    with open(latex_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Lista de substituições necessárias
    replacements = [
        # Para figuras que existem apenas em SVG, usar PNG genérico
        (r'\\includegraphics\[width=0\.9\\textwidth\]\{figuras/figura_fluxograma_metodologia\.eps\}',
         r'\\includegraphics[width=0.9\\textwidth]{figuras/figura_fluxograma_metodologia.svg}'),
        
        (r'\\includegraphics\[width=0\.9\\textwidth\]\{figuras/figura_unet_arquitetura\.eps\}',
         r'\\includegraphics[width=0.9\\textwidth]{figuras/figura_unet_arquitetura.svg}'),
        
        (r'\\includegraphics\[width=0\.9\\textwidth\]\{figuras/figura_attention_unet_arquitetura\.eps\}',
         r'\\includegraphics[width=0.9\\textwidth]{figuras/figura_attention_unet_arquitetura.svg}'),
        
        (r'\\includegraphics\[width=\\textwidth\]\{figuras/figura_curvas_aprendizado\.eps\}',
         r'\\includegraphics[width=\\textwidth]{figuras/figura_curvas_aprendizado.svg}'),
         
        # Adicionar novamente o suporte SVG
        (r'\\DeclareGraphicsExtensions\{\.pdf,\.eps,\.png,\.jpg,\.jpeg\}',
         r'\\DeclareGraphicsExtensions{.pdf,.eps,.png,.jpg,.jpeg,.svg}')
    ]
    
    # Aplica as substituições
    for old, new in replacements:
        content = re.sub(old, new, content)
    
    # Reintroduz o pacote SVG na seção de pacotes
    if '\\usepackage{svg}' not in content:
        content = content.replace(
            '\\usepackage{graphicx}',
            '\\usepackage{graphicx}\n\\usepackage{svg}'
        )
    
    # Escreve o arquivo corrigido
    with open(latex_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✓ Arquivo LaTeX corrigido!")
    print("✓ Referências de figuras atualizadas")

if __name__ == "__main__":
    fix_latex_figures()
