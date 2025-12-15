"""
Generate All Figures with Real Experimental Data
Creates Figures 4-7 using actual training and evaluation results
"""

import os
import json
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpec

# Configuration
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman', 'DejaVu Serif']
plt.rcParams['font.size'] = 10
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.dpi'] = 300

def load_results():
    """Load all experimental results"""
    with open('results/all_models_results.json', 'r') as f:
        results = json.load(f)
    
    histories = {}
    for model_name in ['resnet50', 'efficientnet', 'custom_cnn']:
        with open(f'results/{model_name}_training_history.json', 'r') as f:
            histories[model_name] = json.load(f)
    
    return results, histories

def generate_figure4_confusion_matrices(results, output_path):
    """Generate Figure 4: Confusion Matrices for all 3 models"""
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    
    models = [
        ('resnet50', 'ResNet50'),
        ('efficientnet', 'EfficientNet-B0'),
        ('custom_cnn', 'Custom CNN')
    ]
    
    for idx, (model_key, model_name) in enumerate(models):
        ax = axes[idx]
        
        # Get confusion matrix
        cm = np.array(results[model_key]['confusion_matrix'])
        
        # Normalize to percentages
        cm_normalized = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]
        
        # Plot
        im = ax.imshow(cm_normalized, cmap='Blues', aspect='auto', vmin=0, vmax=1)
        
        # Add text annotations
        for i in range(3):
            for j in range(3):
                text_color = 'white' if cm_normalized[i, j] > 0.5 else 'black'
                ax.text(j, i, f'{cm_normalized[i, j]:.3f}\n({cm[i, j]})',
                       ha='center', va='center', color=text_color, fontsize=9)
        
        # Labels
        ax.set_xlabel('Predicted Class', fontsize=10)
        ax.set_ylabel('True Class', fontsize=10)
        ax.set_title(f'{model_name}\nAccuracy: {results[model_key]["test_accuracy"]:.3f}',
                    fontsize=11, weight='bold')
        
        # Ticks
        ax.set_xticks([0, 1, 2])
        ax.set_yticks([0, 1, 2])
        ax.set_xticklabels(['Class 0', 'Class 1', 'Class 2'])
        ax.set_yticklabels(['Class 0', 'Class 1', 'Class 2'])
        
        # Colorbar
        if idx == 2:
            cbar = plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
            cbar.set_label('Normalized Frequency', rotation=270, labelpad=15)
    
    plt.suptitle('Confusion Matrices - Test Set Performance', fontsize=13, weight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(output_path, bbox_inches='tight')
    plt.close()
    
    print(f"OK - Figure 4 saved: {output_path}")

def generate_figure5_training_curves(histories, output_path):
    """Generate Figure 5: Training and Validation Curves"""
    
    fig = plt.figure(figsize=(14, 8))
    gs = GridSpec(2, 3, figure=fig, hspace=0.3, wspace=0.3)
    
    models = [
        ('resnet50', 'ResNet50'),
        ('efficientnet', 'EfficientNet-B0'),
        ('custom_cnn', 'Custom CNN')
    ]
    
    colors = {'train': '#2E86AB', 'val': '#A23B72'}
    
    for col, (model_key, model_name) in enumerate(models):
        history = histories[model_key]['history']
        epochs = range(1, len(history['loss']) + 1)
        
        # Loss subplot
        ax_loss = fig.add_subplot(gs[0, col])
        ax_loss.plot(epochs, history['loss'], color=colors['train'], 
                    linewidth=2, label='Training')
        ax_loss.plot(epochs, history['val_loss'], color=colors['val'], 
                    linewidth=2, label='Validation')
        ax_loss.set_xlabel('Epoch')
        ax_loss.set_ylabel('Loss')
        ax_loss.set_title(f'{model_name} - Loss', fontsize=10, weight='bold')
        ax_loss.legend(loc='upper right')
        ax_loss.grid(True, alpha=0.3)
        
        # Accuracy subplot
        ax_acc = fig.add_subplot(gs[1, col])
        ax_acc.plot(epochs, history['accuracy'], color=colors['train'], 
                   linewidth=2, label='Training')
        ax_acc.plot(epochs, history['val_accuracy'], color=colors['val'], 
                   linewidth=2, label='Validation')
        ax_acc.set_xlabel('Epoch')
        ax_acc.set_ylabel('Accuracy')
        ax_acc.set_title(f'{model_name} - Accuracy', fontsize=10, weight='bold')
        ax_acc.legend(loc='lower right')
        ax_acc.grid(True, alpha=0.3)
        ax_acc.set_ylim([0, 1])
    
    plt.suptitle('Training and Validation Curves', fontsize=13, weight='bold')
    plt.savefig(output_path, bbox_inches='tight')
    plt.close()
    
    print(f"OK - Figure 5 saved: {output_path}")

def generate_figure6_performance_comparison(results, output_path):
    """Generate Figure 6: Performance Metrics Comparison"""
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    models = ['ResNet50', 'EfficientNet-B0', 'Custom CNN']
    model_keys = ['resnet50', 'efficientnet', 'custom_cnn']
    
    metrics = ['test_accuracy', 'precision_weighted', 'recall_weighted', 'f1_weighted']
    metric_labels = ['Accuracy', 'Precision', 'Recall', 'F1-Score']
    
    x = np.arange(len(models))
    width = 0.2
    
    colors = ['#2E86AB', '#A23B72', '#F18F01', '#06A77D']
    
    for i, (metric, label) in enumerate(zip(metrics, metric_labels)):
        values = [results[key][metric] for key in model_keys]
        offset = width * (i - 1.5)
        bars = ax.bar(x + offset, values, width, label=label, color=colors[i], 
                     edgecolor='black', linewidth=1.2)
        
        # Add value labels on bars
        for bar in bars:
            height = bar.get_height()
            ax.text(bar.get_x() + bar.get_width()/2., height,
                   f'{height:.3f}',
                   ha='center', va='bottom', fontsize=8)
    
    ax.set_xlabel('Model', fontsize=11, weight='bold')
    ax.set_ylabel('Score', fontsize=11, weight='bold')
    ax.set_title('Performance Metrics Comparison - Test Set', fontsize=12, weight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(models)
    ax.legend(loc='lower right', ncol=2)
    ax.set_ylim([0, 1.05])
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig(output_path, bbox_inches='tight')
    plt.close()
    
    print(f"OK - Figure 6 saved: {output_path}")

def generate_figure7_inference_time(results, output_path):
    """Generate Figure 7: Inference Time Comparison"""
    
    fig, ax = plt.subplots(figsize=(8, 6))
    
    models = ['ResNet50', 'EfficientNet-B0', 'Custom CNN']
    model_keys = ['resnet50', 'efficientnet', 'custom_cnn']
    
    times = [results[key]['inference_time_mean_ms'] for key in model_keys]
    stds = [results[key]['inference_time_std_ms'] for key in model_keys]
    
    colors = ['#2E86AB', '#A23B72', '#F18F01']
    
    bars = ax.bar(models, times, yerr=stds, capsize=10, color=colors, 
                 edgecolor='black', linewidth=1.5, alpha=0.8)
    
    # Add value labels on bars
    for bar, time, std in zip(bars, times, stds):
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height + std,
               f'{time:.1f} ms\n± {std:.1f}',
               ha='center', va='bottom', fontsize=10, weight='bold')
    
    ax.set_ylabel('Inference Time (ms)', fontsize=11, weight='bold')
    ax.set_title('Average Inference Time per Image', fontsize=12, weight='bold')
    ax.grid(True, alpha=0.3, axis='y')
    ax.set_ylim([0, max(times) * 1.3])
    
    # Add efficiency note
    ax.text(0.5, 0.95, 'Lower is better (faster inference)', 
           transform=ax.transAxes, ha='center', va='top',
           fontsize=9, style='italic', bbox=dict(boxstyle='round', 
           facecolor='wheat', alpha=0.5))
    
    plt.tight_layout()
    plt.savefig(output_path, bbox_inches='tight')
    plt.close()
    
    print(f"OK - Figure 7 saved: {output_path}")

def generate_per_class_performance_table(results):
    """Generate LaTeX table for per-class performance"""
    
    latex = "\\begin{table}[htbp]\n"
    latex += "\\centering\n"
    latex += "\\caption{Per-Class Performance Metrics}\n"
    latex += "\\label{tab:per_class_performance}\n"
    latex += "\\begin{tabular}{llccc}\n"
    latex += "\\toprule\n"
    latex += "Model & Class & Precision & Recall & F1-Score \\\\\n"
    latex += "\\midrule\n"
    
    models = [
        ('resnet50', 'ResNet50'),
        ('efficientnet', 'EfficientNet-B0'),
        ('custom_cnn', 'Custom CNN')
    ]
    
    class_names = ['Light (<8\\%)', 'Moderate (8-11\\%)', 'Severe (>=11\\%)']
    
    for model_key, model_name in models:
        for class_idx, class_name in enumerate(class_names):
            precision = results[model_key]['precision_per_class'][class_idx]
            recall = results[model_key]['recall_per_class'][class_idx]
            f1 = results[model_key]['f1_per_class'][class_idx]
            
            if class_idx == 0:
                latex += f"{model_name} & {class_name} & {precision:.3f} & {recall:.3f} & {f1:.3f} \\\\\n"
            else:
                latex += f" & {class_name} & {precision:.3f} & {recall:.3f} & {f1:.3f} \\\\\n"
        
        if model_key != 'custom_cnn':
            latex += "\\midrule\n"
    
    latex += "\\bottomrule\n"
    latex += "\\end{tabular}\n"
    latex += "\\end{table}\n"
    
    with open('results/per_class_performance_table.tex', 'w') as f:
        f.write(latex)
    
    print("OK - Per-class performance LaTeX table saved")

def generate_overall_performance_table(results):
    """Generate LaTeX table for overall performance"""
    
    latex = "\\begin{table}[htbp]\n"
    latex += "\\centering\n"
    latex += "\\caption{Overall Model Performance on Test Set}\n"
    latex += "\\label{tab:overall_performance}\n"
    latex += "\\begin{tabular}{lcccc}\n"
    latex += "\\toprule\n"
    latex += "Model & Accuracy & Precision & Recall & F1-Score \\\\\n"
    latex += "\\midrule\n"
    
    models = [
        ('resnet50', 'ResNet50'),
        ('efficientnet', 'EfficientNet-B0'),
        ('custom_cnn', 'Custom CNN')
    ]
    
    for model_key, model_name in models:
        acc = results[model_key]['test_accuracy']
        prec = results[model_key]['precision_weighted']
        rec = results[model_key]['recall_weighted']
        f1 = results[model_key]['f1_weighted']
        
        latex += f"{model_name} & {acc:.3f} & {prec:.3f} & {rec:.3f} & {f1:.3f} \\\\\n"
    
    latex += "\\bottomrule\n"
    latex += "\\end{tabular}\n"
    latex += "\\end{table}\n"
    
    with open('results/overall_performance_table.tex', 'w') as f:
        f.write(latex)
    
    print("OK - Overall performance LaTeX table saved")

def generate_inference_time_table(results):
    """Generate LaTeX table for inference time"""
    
    latex = "\\begin{table}[htbp]\n"
    latex += "\\centering\n"
    latex += "\\caption{Inference Time Comparison}\n"
    latex += "\\label{tab:inference_time}\n"
    latex += "\\begin{tabular}{lcc}\n"
    latex += "\\toprule\n"
    latex += "Model & Mean Time (ms) & Std Dev (ms) \\\\\n"
    latex += "\\midrule\n"
    
    models = [
        ('resnet50', 'ResNet50'),
        ('efficientnet', 'EfficientNet-B0'),
        ('custom_cnn', 'Custom CNN')
    ]
    
    for model_key, model_name in models:
        mean_time = results[model_key]['inference_time_mean_ms']
        std_time = results[model_key]['inference_time_std_ms']
        
        latex += f"{model_name} & {mean_time:.2f} & {std_time:.2f} \\\\\n"
    
    latex += "\\bottomrule\n"
    latex += "\\end{tabular}\n"
    latex += "\\end{table}\n"
    
    with open('results/inference_time_table.tex', 'w') as f:
        f.write(latex)
    
    print("OK - Inference time LaTeX table saved")

def main():
    print("="*70)
    print("GENERATING ALL FIGURES WITH REAL DATA")
    print("="*70)
    print()
    
    # Check if results exist
    if not os.path.exists('results/all_models_results.json'):
        print("ERROR: Results not found. Please train models first.")
        return
    
    # Load results
    print("Loading experimental results...")
    results, histories = load_results()
    print("OK - Results loaded")
    print()
    
    # Create output directory
    output_dir = 'figuras_pure_classification'
    os.makedirs(output_dir, exist_ok=True)
    
    # Generate figures
    print("Generating figures...")
    print()
    
    generate_figure4_confusion_matrices(
        results, 
        os.path.join(output_dir, 'figura_confusion_matrices.pdf')
    )
    
    generate_figure5_training_curves(
        histories,
        os.path.join(output_dir, 'figura_training_curves.pdf')
    )
    
    generate_figure6_performance_comparison(
        results,
        os.path.join(output_dir, 'figura_performance_comparison.pdf')
    )
    
    generate_figure7_inference_time(
        results,
        os.path.join(output_dir, 'figura_inference_time.pdf')
    )
    
    print()
    print("Generating LaTeX tables...")
    print()
    
    generate_overall_performance_table(results)
    generate_per_class_performance_table(results)
    generate_inference_time_table(results)
    
    print()
    print("="*70)
    print("SUCCESS - ALL FIGURES AND TABLES GENERATED!")
    print("="*70)
    print()
    print("Output files:")
    print(f"  Figures: {output_dir}/")
    print("  Tables: results/")
    print()
    print("Next step: Update article with real data")

if __name__ == '__main__':
    main()
