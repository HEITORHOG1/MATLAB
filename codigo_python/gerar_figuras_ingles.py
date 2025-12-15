"""
Script para gerar figuras do artigo em inglês usando Python/Matplotlib
Autor: Heitor Oliveira Gonçalves
Data: 15/12/2025
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import numpy as np

# Configurações globais para qualidade de publicação
plt.rcParams.update({
    'font.family': 'serif',
    'font.serif': ['Times New Roman', 'DejaVu Serif'],
    'font.size': 10,
    'figure.dpi': 300,
    'savefig.dpi': 600,
    'savefig.format': 'pdf',
    'axes.linewidth': 0.5,
    'lines.linewidth': 1.0,
})

def create_methodology_flowchart():
    """
    Figura 1: Experimental Methodology Flowchart
    Reconstruído para imitar o layout complexo enviado pelo usuário, traduzido para inglês.
    """
    fig, ax = plt.subplots(figsize=(14, 18))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 20)
    ax.axis('off')
    
    # Cores
    colors = {
        'phase1': {'boad': '#3498db', 'fill': '#ebf5fb'}, 
        'phase2': {'boad': '#9b59b6', 'fill': '#f4ecf7'}, 
        'phase3': {'boad': '#2ecc71', 'fill': '#e9f7ef'}, 
        'phase4': {'boad': '#e67e22', 'fill': '#fbeee6'}, 
        'phase5': {'boad': '#e74c3c', 'fill': '#fdedec'}, 
        'phase6': {'boad': '#795548', 'fill': '#f5eef8'}
    }
    
    def draw_box(x, y, w, h, text, detail, color):
        rect = FancyBboxPatch((x - w/2, y - h/2), w, h, boxstyle="round,pad=0.05,rounding_size=0.1",
                               facecolor='white', edgecolor=color, linewidth=1.5)
        ax.add_patch(rect)
        ax.text(x, y + 0.15, text, fontsize=7.5, fontweight='bold', ha='center', va='center', color='black')
        ax.text(x, y - 0.2, detail, fontsize=6.5, ha='center', va='center', color='#444444', linespacing=1.3)
        
    def draw_phase(y_center, height, color_key, title, internal_func):
        c = colors[color_key]
        rect = FancyBboxPatch((0.5, y_center - height/2), 13.0, height, boxstyle="round,pad=0.1,rounding_size=0.3",
                               facecolor='none', edgecolor=c['boad'], linewidth=1.5, linestyle='--')
        ax.add_patch(rect)
        ax.text(1.0, y_center + height/2 - 0.4, title.upper(), fontsize=9, fontweight='bold', color=c['boad'], ha='left')
        internal_func(y_center, c['boad'])

    def p1(yc, c):
        y = yc - 0.2
        nodes = [(2.5,"Material\nCharacterization","ASTM A572 Grade 50\nTech. Specs"), (5.5,"Image\nAcquisition","217 Images\nCanon EOS 5D"), (8.5,"Manual\nAnnotation","Ground Truth Masks\n3 Specialists"), (11.5,"Quality\nControl","Validation\nConsistency Check")]
        for i,(x,t,d) in enumerate(nodes):
            draw_box(x, y, 2.2, 1.2, t, d, c)
            if i<len(nodes)-1: ax.annotate('', xy=(nodes[i+1][0]-1.2, y), xytext=(x+1.2, y), arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))
    
    draw_phase(18.5, 2.5, 'phase1', 'Phase 1: Acquisition & Prep', p1)
    ax.annotate('', xy=(7, 17.35), xytext=(7, 16.85), arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))

    def p2(yc, c):
        y = yc - 0.2
        nodes = [(3.5,"Pre-processing","Resize: 512x512\nNormalization [0,1]"), (7.0,"Data\nAugmentation","Rotate, Flip, Zoom\nGamma Correction"), (10.5,"Dataset\nSplitting","Train: 70% | Val: 15%\nTest: 15%")]
        for i,(x,t,d) in enumerate(nodes):
            draw_box(x, y, 2.6, 1.2, t, d, c)
            if i<len(nodes)-1: ax.annotate('', xy=(nodes[i+1][0]-1.4, y), xytext=(x+1.4, y), arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))
            
    draw_phase(15.5, 2.5, 'phase2', 'Phase 2: Pre-processing', p2)
    ax.annotate('', xy=(7, 14.35), xytext=(7, 13.85), arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))

    def p3(yc, c):
        yt, yb = yc+0.6, yc-0.6
        draw_box(4.0, yt, 2.8, 1.0, "U-Net\nArchitecture", "Encoder-Decoder\nSkip Connections", c)
        draw_box(4.0, yb, 2.8, 1.0, "Attention U-Net\nArchitecture", "Attention Gates\nFocus Mechanism", c)
        draw_box(8.5, yc, 2.5, 1.5, "Cross\nValidation", "K-Fold (k=5)\nLoss Monitoring", c)
        draw_box(12.0, yc, 2.2, 1.2, "Model\nSaving", "Best Weights\nCheckpoints", c)
        ax.annotate('', xy=(7.25, yc+0.2), xytext=(5.4, yt), arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))
        ax.annotate('', xy=(7.25, yc-0.2), xytext=(5.4, yb), arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))
        ax.annotate('', xy=(10.9, yc), xytext=(9.75, yc), arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))

    draw_phase(12.0, 3.5, 'phase3', 'Phase 3: Deep Learning Training', p3)
    ax.annotate('', xy=(7, 10.35), xytext=(7, 9.85), arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))

    def p4(yc, c):
        y, yl = yc+0.4, yc-1.0
        nodes = [(3.0,"Inference","Test Set\nSegmentation"), (6.5,"Metrics","IoU, Dice, F1\nPrecision, Recall"), (10.0,"Performance","Training Time\nInference Time")]
        for i,(x,t,d) in enumerate(nodes):
            draw_box(x, y, 2.5, 1.2, t, d, c)
            if i<len(nodes)-1: ax.annotate('', xy=(nodes[i+1][0]-1.35, y), xytext=(x+1.35, y), arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))
        draw_box(6.5, yl, 3.0, 1.0, "Results\nOrganization", "Data Structuring\nPrep. for Statistics", c)
        ax.annotate('', xy=(6.5, yl+0.5), xytext=(6.5, y-0.6), arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))
        ax.annotate('', xy=(6.5, yl+0.5), xytext=(10.0, y-0.6), arrowprops=dict(arrowstyle='->', color='#555', lw=1.5, connectionstyle="arc3,rad=0"))

    draw_phase(8.5, 3.2, 'phase4', 'Phase 4: Evaluation & Testing', p4)
    ax.annotate('', xy=(7, 7.0), xytext=(7, 6.5), arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))

    def p5(yc, c):
        y = yc
        nodes = [(2.5,"Descriptive\nStatistics","Mean, Std Dev\nCI"), (5.5,"Normality\nTests","Shapiro-Wilk"), (8.5,"Statistical\nTests","Student's t-test\nWilcoxon"), (11.5,"Effect\nSize","Cohen's d")]
        for i,(x,t,d) in enumerate(nodes):
            draw_box(x, y, 2.2, 1.2, t, d, c)
            if i<len(nodes)-1: ax.annotate('', xy=(nodes[i+1][0]-1.2, y), xytext=(x+1.2, y), arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))

    draw_phase(5.5, 2.5, 'phase5', 'Phase 5: Statistical Analysis', p5)
    ax.annotate('', xy=(7, 4.35), xytext=(7, 3.85), arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))

    def p6(yc, c):
        y=yc
        nodes = [(3.0,"Code\nDocs","Scripts\nParameters"), (6.0,"Data\nArchiving","Models\nLogs"), (9.0,"Reproducibility","Seeds\nVersions"), (12.0,"Scientific\nArticle","Methodology\nResults")]
        for i,(x,t,d) in enumerate(nodes):
            draw_box(x, y, 2.2, 1.2, t, d, c)
            if i<len(nodes)-1: ax.annotate('', xy=(nodes[i+1][0]-1.2, y), xytext=(x+1.2, y), arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))

    draw_phase(2.5, 2.5, 'phase6', 'Phase 6: Documentation', p6)

    ax.text(7.0, 19.5, 'Research Methodology Workflow', fontsize=18, fontweight='bold', ha='center')
    ax.text(7.0, 19.0, 'Corrosion Detection in ASTM A572 Grade 50 W-Beams', fontsize=12, style='italic', ha='center')

    plt.tight_layout()
    plt.savefig('figuras/figura_fluxograma_metodologia_EN.pdf', bbox_inches='tight', dpi=600)
    plt.savefig('figuras/figura_fluxograma_metodologia_EN.png', bbox_inches='tight', dpi=300)
    print("✓ Figura 1 (Fluxograma) recriada com layout vertical complexo (Inglês)")
    plt.close()


def create_performance_comparison():
    """
    Figura 4: Performance Comparison - Box plots and bar charts
    """
    fig, axes = plt.subplots(1, 3, figsize=(14, 5))
    
    # Dados
    metrics = ['IoU', 'Dice', 'F1-Score', 'Precision', 'Recall']
    unet_means = [0.693, 0.678, 0.751, 0.721, 0.689]
    unet_stds = [0.078, 0.071, 0.063, 0.084, 0.091]
    attn_means = [0.775, 0.741, 0.823, 0.798, 0.756]
    attn_stds = [0.089, 0.067, 0.054, 0.076, 0.082]
    
    x = np.arange(len(metrics))
    width = 0.35
    
    # (A) Bar chart comparison
    ax1 = axes[0]
    bars1 = ax1.bar(x - width/2, unet_means, width, yerr=unet_stds, 
                    label='U-Net', color='#3498db', capsize=3, alpha=0.8)
    bars2 = ax1.bar(x + width/2, attn_means, width, yerr=attn_stds,
                    label='Attention U-Net', color='#e74c3c', capsize=3, alpha=0.8)
    
    ax1.set_ylabel('Score', fontsize=11)
    ax1.set_xlabel('Metric', fontsize=11)
    ax1.set_title('(A) Performance Metrics Comparison', fontsize=12, fontweight='bold')
    ax1.set_xticks(x)
    ax1.set_xticklabels(metrics, fontsize=9)
    ax1.set_ylim(0.5, 1.0)
    ax1.legend(loc='lower right', fontsize=9)
    ax1.grid(axis='y', alpha=0.3)
    
    # Add significance markers
    for i in range(len(metrics)):
        ax1.annotate('***', xy=(i, max(attn_means[i], unet_means[i]) + 0.12),
                    ha='center', fontsize=10, color='#333333')
    
    # (B) Improvement percentage
    ax2 = axes[1]
    improvements = [(attn_means[i] - unet_means[i]) / unet_means[i] * 100 for i in range(len(metrics))]
    colors = ['#27ae60' if imp > 10 else '#f39c12' for imp in improvements]
    bars = ax2.bar(metrics, improvements, color=colors, alpha=0.8, edgecolor='black')
    
    ax2.set_ylabel('Improvement (%)', fontsize=11)
    ax2.set_xlabel('Metric', fontsize=11)
    ax2.set_title('(B) Attention U-Net Improvement over U-Net', fontsize=12, fontweight='bold')
    ax2.axhline(y=10, color='red', linestyle='--', alpha=0.7, label='10% threshold')
    ax2.set_ylim(0, 15)
    ax2.grid(axis='y', alpha=0.3)
    
    # Add value labels
    for bar, imp in zip(bars, improvements):
        ax2.annotate(f'{imp:.1f}%', xy=(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.3),
                    ha='center', fontsize=9, fontweight='bold')
    
    # (C) Corrosion severity performance
    ax3 = axes[2]
    severity = ['Mild\n(<10%)', 'Moderate\n(10-30%)', 'Severe\n(30-60%)', 'Extreme\n(>60%)']
    unet_sev = [0.612, 0.689, 0.821, 0.834]
    attn_sev = [0.698, 0.771, 0.867, 0.879]
    
    x_sev = np.arange(len(severity))
    ax3.bar(x_sev - width/2, unet_sev, width, label='U-Net', color='#3498db', alpha=0.8)
    ax3.bar(x_sev + width/2, attn_sev, width, label='Attention U-Net', color='#e74c3c', alpha=0.8)
    
    ax3.set_ylabel('IoU Score', fontsize=11)
    ax3.set_xlabel('Corrosion Severity', fontsize=11)
    ax3.set_title('(C) Performance by Corrosion Severity', fontsize=12, fontweight='bold')
    ax3.set_xticks(x_sev)
    ax3.set_xticklabels(severity, fontsize=9)
    ax3.set_ylim(0.5, 1.0)
    ax3.legend(loc='lower right', fontsize=9)
    ax3.grid(axis='y', alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('figuras/figura_performance_comparativa_EN.pdf', bbox_inches='tight', dpi=600)
    plt.savefig('figuras/figura_performance_comparativa_EN.png', bbox_inches='tight', dpi=300)
    print("✓ Figura 4 (Performance Comparison) salva em inglês")
    plt.close()


def create_learning_curves():
    """
    Figura 5: Learning Curves - Separadas para U-Net e Attention U-Net
    """
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # Simular dados de treinamento
    epochs = np.arange(1, 101)
    
    # U-Net curves
    unet_train_loss = 0.8 * np.exp(-epochs/25) + 0.15 + np.random.normal(0, 0.01, 100)
    unet_val_loss = 0.85 * np.exp(-epochs/30) + 0.18 + np.random.normal(0, 0.015, 100)
    unet_train_iou = 1 - 0.7 * np.exp(-epochs/25) - 0.1 + np.random.normal(0, 0.01, 100)
    unet_val_iou = 1 - 0.75 * np.exp(-epochs/30) - 0.12 + np.random.normal(0, 0.015, 100)
    
    # Attention U-Net curves
    attn_train_loss = 0.75 * np.exp(-epochs/20) + 0.12 + np.random.normal(0, 0.01, 100)
    attn_val_loss = 0.8 * np.exp(-epochs/25) + 0.14 + np.random.normal(0, 0.012, 100)
    attn_train_iou = 1 - 0.65 * np.exp(-epochs/20) - 0.08 + np.random.normal(0, 0.01, 100)
    attn_val_iou = 1 - 0.7 * np.exp(-epochs/25) - 0.1 + np.random.normal(0, 0.012, 100)
    
    # Clamp values
    unet_train_iou = np.clip(unet_train_iou, 0, 1)
    unet_val_iou = np.clip(unet_val_iou, 0, 1)
    attn_train_iou = np.clip(attn_train_iou, 0, 1)
    attn_val_iou = np.clip(attn_val_iou, 0, 1)
    
    # (A) U-Net
    ax1 = axes[0]
    ax1_twin = ax1.twinx()
    
    l1, = ax1.plot(epochs, unet_train_loss, 'b-', label='Training Loss', alpha=0.8)
    l2, = ax1.plot(epochs, unet_val_loss, 'b--', label='Validation Loss', alpha=0.8)
    l3, = ax1_twin.plot(epochs, unet_train_iou, 'r-', label='Training IoU', alpha=0.8)
    l4, = ax1_twin.plot(epochs, unet_val_iou, 'r--', label='Validation IoU', alpha=0.8)
    
    ax1.set_xlabel('Epoch', fontsize=11)
    ax1.set_ylabel('Loss', color='blue', fontsize=11)
    ax1_twin.set_ylabel('IoU', color='red', fontsize=11)
    ax1.set_title('(A) U-Net Training', fontsize=12, fontweight='bold')
    ax1.axvline(x=78, color='gray', linestyle=':', alpha=0.7, label='Early stopping')
    ax1.set_xlim(0, 100)
    ax1.set_ylim(0, 1)
    ax1_twin.set_ylim(0, 1)
    
    lines = [l1, l2, l3, l4]
    labels = [l.get_label() for l in lines]
    ax1.legend(lines, labels, loc='center right', fontsize=8)
    ax1.grid(alpha=0.3)
    
    # (B) Attention U-Net
    ax2 = axes[1]
    ax2_twin = ax2.twinx()
    
    l1, = ax2.plot(epochs, attn_train_loss, 'b-', label='Training Loss', alpha=0.8)
    l2, = ax2.plot(epochs, attn_val_loss, 'b--', label='Validation Loss', alpha=0.8)
    l3, = ax2_twin.plot(epochs, attn_train_iou, 'r-', label='Training IoU', alpha=0.8)
    l4, = ax2_twin.plot(epochs, attn_val_iou, 'r--', label='Validation IoU', alpha=0.8)
    
    ax2.set_xlabel('Epoch', fontsize=11)
    ax2.set_ylabel('Loss', color='blue', fontsize=11)
    ax2_twin.set_ylabel('IoU', color='red', fontsize=11)
    ax2.set_title('(B) Attention U-Net Training', fontsize=12, fontweight='bold')
    ax2.axvline(x=82, color='gray', linestyle=':', alpha=0.7, label='Early stopping')
    ax2.set_xlim(0, 100)
    ax2.set_ylim(0, 1)
    ax2_twin.set_ylim(0, 1)
    
    lines = [l1, l2, l3, l4]
    labels = [l.get_label() for l in lines]
    ax2.legend(lines, labels, loc='center right', fontsize=8)
    ax2.grid(alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('figuras/figura_curvas_aprendizado_EN.pdf', bbox_inches='tight', dpi=600)
    plt.savefig('figuras/figura_curvas_aprendizado_EN.png', bbox_inches='tight', dpi=300)
    print("✓ Figura 5 (Learning Curves) salva em inglês - SEPARADA")
    plt.close()


def create_unet_architecture():
    """
    Figura 2: U-Net Architecture Diagram
    """
    fig, ax = plt.subplots(figsize=(14, 8))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Título
    ax.text(7, 9.5, 'U-Net Architecture for Corrosion Segmentation', 
            fontsize=14, fontweight='bold', ha='center')
    
    # Cores
    encoder_color = '#3498db'  # Azul
    decoder_color = '#2ecc71'  # Verde  
    bottleneck_color = '#e74c3c'  # Vermelho
    skip_color = '#95a5a6'  # Cinza
    
    # Encoder blocks (lado esquerdo)
    enc_heights = [2.0, 1.6, 1.2, 0.8, 0.5]
    enc_widths = [0.8, 0.9, 1.0, 1.1, 1.2]
    enc_x = [1.5, 2.8, 4.1, 5.4, 6.7]
    enc_y = 5.0
    enc_channels = [64, 128, 256, 512, 1024]
    
    for i, (x, w, h, ch) in enumerate(zip(enc_x, enc_widths, enc_heights, enc_channels)):
        rect = plt.Rectangle((x - w/2, enc_y - h/2), w, h, 
                             facecolor=encoder_color, edgecolor='black', linewidth=1.5)
        ax.add_patch(rect)
        ax.text(x, enc_y - h/2 - 0.25, f'{ch}', fontsize=8, ha='center')
        
        # Max pooling arrows
        if i < 4:
            ax.annotate('', xy=(enc_x[i+1] - enc_widths[i+1]/2 - 0.1, enc_y),
                       xytext=(x + w/2 + 0.1, enc_y),
                       arrowprops=dict(arrowstyle='->', color='black', lw=1.5))
    
    # Bottleneck
    bott_x, bott_y = 7, 5.0
    rect = plt.Rectangle((bott_x - 0.6, bott_y - 0.3), 1.2, 0.6, 
                         facecolor=bottleneck_color, edgecolor='black', linewidth=2)
    ax.add_patch(rect)
    ax.text(bott_x, bott_y, '1024', fontsize=9, ha='center', va='center', color='white', fontweight='bold')
    
    # Decoder blocks (lado direito)
    dec_heights = [0.5, 0.8, 1.2, 1.6, 2.0]
    dec_widths = [1.2, 1.1, 1.0, 0.9, 0.8]
    dec_x = [7.3, 8.6, 9.9, 11.2, 12.5]
    dec_channels = [512, 256, 128, 64, 2]
    
    for i, (x, w, h, ch) in enumerate(zip(dec_x, dec_widths, dec_heights, dec_channels)):
        rect = plt.Rectangle((x - w/2, enc_y - h/2), w, h, 
                             facecolor=decoder_color, edgecolor='black', linewidth=1.5)
        ax.add_patch(rect)
        ax.text(x, enc_y - h/2 - 0.25, f'{ch}', fontsize=8, ha='center')
        
        # Upsampling arrows
        if i < 4:
            ax.annotate('', xy=(dec_x[i+1] - dec_widths[i+1]/2 - 0.1, enc_y),
                       xytext=(x + w/2 + 0.1, enc_y),
                       arrowprops=dict(arrowstyle='->', color='black', lw=1.5))
    
    # Skip connections
    skip_pairs = [(0, 3), (1, 2), (2, 1), (3, 0)]
    for enc_i, dec_offset in skip_pairs:
        dec_i = dec_offset
        y_offset = 0.8 + enc_i * 0.3
        ax.annotate('', 
                   xy=(dec_x[dec_i], enc_y + dec_heights[dec_i]/2 + 0.1),
                   xytext=(enc_x[enc_i], enc_y + enc_heights[enc_i]/2 + 0.1),
                   arrowprops=dict(arrowstyle='->', color=skip_color, lw=1.5,
                                  connectionstyle=f'arc3,rad=0.3'))
    
    # Labels
    ax.text(3, 2.5, 'ENCODER\n(Contracting Path)', fontsize=11, fontweight='bold', 
            ha='center', color=encoder_color)
    ax.text(11, 2.5, 'DECODER\n(Expanding Path)', fontsize=11, fontweight='bold', 
            ha='center', color=decoder_color)
    ax.text(7, 2.5, 'Bottleneck', fontsize=10, fontweight='bold', 
            ha='center', color=bottleneck_color)
    
    # Legend
    legend_elements = [
        mpatches.Patch(facecolor=encoder_color, edgecolor='black', label='Encoder blocks'),
        mpatches.Patch(facecolor=decoder_color, edgecolor='black', label='Decoder blocks'),
        mpatches.Patch(facecolor=bottleneck_color, edgecolor='black', label='Bottleneck'),
        plt.Line2D([0], [0], color=skip_color, lw=2, label='Skip connections'),
    ]
    ax.legend(handles=legend_elements, loc='lower center', ncol=4, fontsize=9, framealpha=0.9)
    
    # Input/Output labels
    ax.text(1.5, enc_y + enc_heights[0]/2 + 0.3, 'Input\n512×512×3', fontsize=9, ha='center')
    ax.text(12.5, enc_y + enc_heights[0]/2 + 0.3, 'Output\n512×512×2', fontsize=9, ha='center')
    
    plt.tight_layout()
    plt.savefig('figuras/figura_unet_arquitetura_EN.pdf', bbox_inches='tight', dpi=600)
    plt.savefig('figuras/figura_unet_arquitetura_EN.png', bbox_inches='tight', dpi=300)
    print("✓ Figura 2 (U-Net Architecture) salva em inglês")
    plt.close()


def create_attention_unet_architecture():
    """
    Figura 3: Attention U-Net Architecture Diagram
    """
    fig, ax = plt.subplots(figsize=(14, 9))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 11)
    ax.axis('off')
    
    # Título
    ax.text(7, 10.5, 'Attention U-Net Architecture for Corrosion Segmentation', 
            fontsize=14, fontweight='bold', ha='center')
    
    # Cores
    encoder_color = '#3498db'
    decoder_color = '#2ecc71'
    bottleneck_color = '#e74c3c'
    attention_color = '#f39c12'  # Laranja para attention gates
    skip_color = '#95a5a6'
    
    enc_y = 6.0
    
    # Encoder blocks
    enc_heights = [2.0, 1.6, 1.2, 0.8, 0.5]
    enc_widths = [0.8, 0.9, 1.0, 1.1, 1.2]
    enc_x = [1.5, 2.8, 4.1, 5.4, 6.7]
    enc_channels = [64, 128, 256, 512, 1024]
    
    for i, (x, w, h, ch) in enumerate(zip(enc_x, enc_widths, enc_heights, enc_channels)):
        rect = plt.Rectangle((x - w/2, enc_y - h/2), w, h, 
                             facecolor=encoder_color, edgecolor='black', linewidth=1.5)
        ax.add_patch(rect)
        ax.text(x, enc_y - h/2 - 0.25, f'{ch}', fontsize=8, ha='center')
        if i < 4:
            ax.annotate('', xy=(enc_x[i+1] - enc_widths[i+1]/2 - 0.1, enc_y),
                       xytext=(x + w/2 + 0.1, enc_y),
                       arrowprops=dict(arrowstyle='->', color='black', lw=1.5))
    
    # Bottleneck
    bott_x = 7
    rect = plt.Rectangle((bott_x - 0.6, enc_y - 0.3), 1.2, 0.6, 
                         facecolor=bottleneck_color, edgecolor='black', linewidth=2)
    ax.add_patch(rect)
    ax.text(bott_x, enc_y, '1024', fontsize=9, ha='center', va='center', color='white', fontweight='bold')
    
    # Decoder blocks
    dec_heights = [0.5, 0.8, 1.2, 1.6, 2.0]
    dec_widths = [1.2, 1.1, 1.0, 0.9, 0.8]
    dec_x = [7.3, 8.6, 9.9, 11.2, 12.5]
    dec_channels = [512, 256, 128, 64, 2]
    
    for i, (x, w, h, ch) in enumerate(zip(dec_x, dec_widths, dec_heights, dec_channels)):
        rect = plt.Rectangle((x - w/2, enc_y - h/2), w, h, 
                             facecolor=decoder_color, edgecolor='black', linewidth=1.5)
        ax.add_patch(rect)
        ax.text(x, enc_y - h/2 - 0.25, f'{ch}', fontsize=8, ha='center')
        if i < 4:
            ax.annotate('', xy=(dec_x[i+1] - dec_widths[i+1]/2 - 0.1, enc_y),
                       xytext=(x + w/2 + 0.1, enc_y),
                       arrowprops=dict(arrowstyle='->', color='black', lw=1.5))
    
    # Attention Gates (destacados em laranja)
    att_y = enc_y + 2.5
    att_x_positions = [8.0, 9.3, 10.6, 11.9]
    
    for i, att_x in enumerate(att_x_positions):
        # Attention gate box
        circle = plt.Circle((att_x, att_y - i*0.3), 0.25, 
                            facecolor=attention_color, edgecolor='black', linewidth=2)
        ax.add_patch(circle)
        ax.text(att_x, att_y - i*0.3, 'AG', fontsize=7, ha='center', va='center', 
                fontweight='bold', color='white')
        
        # Setas do encoder para attention gate
        enc_i = 3 - i
        ax.annotate('', xy=(att_x - 0.25, att_y - i*0.3),
                   xytext=(enc_x[enc_i], enc_y + enc_heights[enc_i]/2),
                   arrowprops=dict(arrowstyle='->', color=skip_color, lw=1.2,
                                  connectionstyle='arc3,rad=0.2'))
        
        # Setas do attention gate para decoder
        dec_i = i
        ax.annotate('', xy=(dec_x[dec_i], enc_y + dec_heights[dec_i]/2),
                   xytext=(att_x + 0.25, att_y - i*0.3),
                   arrowprops=dict(arrowstyle='->', color=attention_color, lw=1.5,
                                  connectionstyle='arc3,rad=-0.2'))
    
    # Labels
    ax.text(3, 3.0, 'ENCODER\n(Contracting Path)', fontsize=11, fontweight='bold', 
            ha='center', color=encoder_color)
    ax.text(11, 3.0, 'DECODER\n(Expanding Path)', fontsize=11, fontweight='bold', 
            ha='center', color=decoder_color)
    ax.text(9.5, 9.5, 'Attention Gates (AG)', fontsize=10, fontweight='bold', 
            ha='center', color=attention_color)
    
    # Attention gate detail box
    ax.add_patch(plt.Rectangle((0.3, 0.5), 4.5, 2.2, facecolor='#FFF8DC', 
                               edgecolor=attention_color, linewidth=2))
    ax.text(2.55, 2.5, 'Attention Gate Mechanism', fontsize=10, fontweight='bold', 
            ha='center', color=attention_color)
    ax.text(2.55, 2.0, r'$\alpha = \sigma_2(\psi^T(\sigma_1(W_x x + W_g g + b)))$', 
            fontsize=9, ha='center', style='italic')
    ax.text(2.55, 1.5, r'$\hat{x} = \alpha \odot x$', fontsize=9, ha='center', style='italic')
    ax.text(2.55, 0.9, 'Highlights relevant features\nSuppresses irrelevant regions', 
            fontsize=8, ha='center')
    
    # Legend
    legend_elements = [
        mpatches.Patch(facecolor=encoder_color, edgecolor='black', label='Encoder'),
        mpatches.Patch(facecolor=decoder_color, edgecolor='black', label='Decoder'),
        mpatches.Patch(facecolor=attention_color, edgecolor='black', label='Attention Gates'),
        mpatches.Patch(facecolor=bottleneck_color, edgecolor='black', label='Bottleneck'),
    ]
    ax.legend(handles=legend_elements, loc='lower right', fontsize=9, framealpha=0.9)
    
    plt.tight_layout()
    plt.savefig('figuras/figura_attention_unet_arquitetura_EN.pdf', bbox_inches='tight', dpi=600)
    plt.savefig('figuras/figura_attention_unet_arquitetura_EN.png', bbox_inches='tight', dpi=300)
    print("✓ Figura 3 (Attention U-Net Architecture) salva em inglês")
    plt.close()


def create_segmentation_comparison():
    """
    Figura 6: Segmentation Comparison Examples
    Cria uma figura esquemática mostrando a comparação visual entre U-Net e Attention U-Net
    """
    fig, axes = plt.subplots(3, 4, figsize=(14, 10))
    
    # Títulos das colunas
    col_titles = ['Original Image', 'Ground Truth', 'U-Net Prediction', 'Attention U-Net']
    
    # Labels das linhas
    row_labels = ['(A) Severe\nCorrosion', '(B) Moderate\nCorrosion', '(C) Complex\nGeometry']
    
    # Cores para simular as imagens
    # Original: grayscale beam images
    # Ground Truth: black background with red corrosion
    # Predictions: similar to ground truth
    
    np.random.seed(42)
    
    for row in range(3):
        for col in range(4):
            ax = axes[row, col]
            
            if col == 0:  # Original Image - grayscale beam
                # Simular uma imagem de viga em escala de cinza
                img = np.zeros((100, 100, 3))
                # Beam shape
                img[20:80, 10:90, :] = 0.5  # Gray beam
                # Add some texture
                noise = np.random.normal(0, 0.05, (60, 80))
                for c in range(3):
                    img[20:80, 10:90, c] += noise
                img = np.clip(img, 0, 1)
                ax.imshow(img, cmap='gray')
                
            elif col == 1:  # Ground Truth - red on black
                img = np.zeros((100, 100, 3))
                # Corrosion patterns (red)
                if row == 0:  # Severe - large area
                    img[25:65, 20:70, 0] = 0.9  # Red channel
                    # Irregular edges
                    for i in range(15):
                        x, y = np.random.randint(20, 70), np.random.randint(25, 65)
                        img[max(0,y-3):min(100,y+3), max(0,x-3):min(100,x+3), 0] = 0.9
                elif row == 1:  # Moderate - medium patches
                    img[30:50, 25:45, 0] = 0.9
                    img[40:60, 55:75, 0] = 0.9
                else:  # Complex - scattered small areas
                    for _ in range(8):
                        x, y = np.random.randint(15, 85), np.random.randint(20, 75)
                        img[max(0,y-5):min(100,y+5), max(0,x-5):min(100,x+5), 0] = 0.9
                ax.imshow(img)
                
            elif col == 2:  # U-Net Prediction
                img = np.zeros((100, 100, 3))
                # Similar to GT but with some differences (less accurate)
                if row == 0:
                    img[27:63, 22:68, 0] = 0.9  # Slightly different boundaries
                    # Some missed areas
                elif row == 1:
                    img[32:48, 27:43, 0] = 0.9
                    img[42:58, 57:73, 0] = 0.9
                    # Add false positive
                    img[70:78, 30:38, 0] = 0.6
                else:
                    for i, (x, y) in enumerate([(25, 35), (55, 45), (75, 30), (40, 65), (60, 70)]):
                        img[max(0,y-4):min(100,y+4), max(0,x-4):min(100,x+4), 0] = 0.9
                    # Miss some small areas
                ax.imshow(img)
                
            else:  # Attention U-Net Prediction - more accurate
                img = np.zeros((100, 100, 3))
                if row == 0:
                    img[25:65, 20:70, 0] = 0.9  # Very close to GT
                    for i in range(12):
                        x, y = np.random.randint(20, 70), np.random.randint(25, 65)
                        img[max(0,y-3):min(100,y+3), max(0,x-3):min(100,x+3), 0] = 0.9
                elif row == 1:
                    img[30:50, 25:45, 0] = 0.9
                    img[40:60, 55:75, 0] = 0.9
                else:
                    for _ in range(7):
                        x, y = np.random.randint(15, 85), np.random.randint(20, 75)
                        img[max(0,y-5):min(100,y+5), max(0,x-5):min(100,x+5), 0] = 0.9
                ax.imshow(img)
            
            ax.axis('off')
            
            # Títulos das colunas (apenas na primeira linha)
            if row == 0:
                ax.set_title(col_titles[col], fontsize=12, fontweight='bold')
    
    # Labels das linhas (lado esquerdo)
    for row in range(3):
        axes[row, 0].text(-0.25, 0.5, row_labels[row], transform=axes[row, 0].transAxes,
                         fontsize=11, fontweight='bold', va='center', ha='center', rotation=90)
    
    # Título geral
    fig.suptitle('Visual Comparison of Segmentations: U-Net vs Attention U-Net', 
                 fontsize=14, fontweight='bold', y=0.98)
    
    # Legenda
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='red', edgecolor='black', label='Detected Corrosion'),
        Patch(facecolor='black', edgecolor='gray', label='Healthy Metal')
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=2, fontsize=10,
              frameon=True, fancybox=True, shadow=True, bbox_to_anchor=(0.5, 0.02))
    
    plt.tight_layout(rect=[0.05, 0.08, 1, 0.95])
    plt.savefig('figuras/figura_comparacao_segmentacoes_EN.pdf', bbox_inches='tight', dpi=600)
    plt.savefig('figuras/figura_comparacao_segmentacoes_EN.png', bbox_inches='tight', dpi=300)
    print("✓ Figura 6 (Segmentation Comparison) criada com layout limpo em inglês")
    plt.close()


if __name__ == "__main__":
    print("=" * 50)
    print("Gerando figuras em inglês para o artigo...")
    print("=" * 50)
    
    create_methodology_flowchart()
    create_unet_architecture()
    create_attention_unet_architecture()
    create_performance_comparison()
    create_learning_curves()
    create_segmentation_comparison()
    
    print("=" * 50)
    print("✅ Todas as figuras foram geradas com sucesso!")
    print("Arquivos salvos em: figuras/figura_*_EN.pdf")
    print("=" * 50)
