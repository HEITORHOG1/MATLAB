"""
Complete Article Update Script
Automatically updates the article with all real experimental data
"""

import os
import json
import re

def load_results():
    """Load all experimental results"""
    with open('results/all_models_results.json', 'r') as f:
        results = json.load(f)
    
    with open('results/dataset_statistics.json', 'r') as f:
        dataset_stats = json.load(f)
    
    return results, dataset_stats

def update_dataset_section(tex_content, dataset_stats):
    """Update dataset description with real statistics"""
    
    # Update total images
    tex_content = re.sub(
        r'dataset comprises \d+ images',
        f'dataset comprises {dataset_stats["dataset"]["total_images"]} images',
        tex_content
    )
    
    # Update class distribution
    class_0 = dataset_stats['class_distribution']['class_0']
    class_1 = dataset_stats['class_distribution']['class_1']
    class_2 = dataset_stats['class_distribution']['class_2']
    
    # Find and replace class distribution section
    old_pattern = r'Class 0.*?:\s*\d+\s*images\s*\(\d+\.\d+%\)'
    new_text_0 = f'Class 0 (Light, <{dataset_stats["thresholds"]["threshold_low"]:.0f}\\%): {class_0["count"]} images ({class_0["percentage"]:.1f}\\%)'
    tex_content = re.sub(old_pattern, new_text_0, tex_content)
    
    old_pattern = r'Class 1.*?:\s*\d+\s*images\s*\(\d+\.\d+%\)'
    new_text_1 = f'Class 1 (Moderate, {dataset_stats["thresholds"]["threshold_low"]:.0f}\\%-{dataset_stats["thresholds"]["threshold_high"]:.0f}\\%): {class_1["count"]} images ({class_1["percentage"]:.1f}\\%)'
    tex_content = re.sub(old_pattern, new_text_1, tex_content)
    
    old_pattern = r'Class 2.*?:\s*\d+\s*images\s*\(\d+\.\d+%\)'
    new_text_2 = f'Class 2 (Severe, ≥{dataset_stats["thresholds"]["threshold_high"]:.0f}\\%): {class_2["count"]} images ({class_2["percentage"]:.1f}\\%)'
    tex_content = re.sub(old_pattern, new_text_2, tex_content)
    
    # Update splits
    train_size = dataset_stats['splits']['train']['size']
    val_size = dataset_stats['splits']['validation']['size']
    test_size = dataset_stats['splits']['test']['size']
    
    tex_content = re.sub(
        r'training set.*?\d+\s*images',
        f'training set contains {train_size} images',
        tex_content,
        flags=re.IGNORECASE
    )
    
    tex_content = re.sub(
        r'validation set.*?\d+\s*images',
        f'validation set contains {val_size} images',
        tex_content,
        flags=re.IGNORECASE
    )
    
    tex_content = re.sub(
        r'test set.*?\d+\s*images',
        f'test set contains {test_size} images',
        tex_content,
        flags=re.IGNORECASE
    )
    
    return tex_content

def create_results_tables(results):
    """Create LaTeX tables with real results"""
    
    # Table 2: Overall Performance
    table2 = """\\begin{table}[htbp]
\\centering
\\caption{Overall Model Performance on Test Set}
\\label{tab:overall_performance}
\\begin{tabular}{lcccc}
\\toprule
Model & Accuracy & Precision & Recall & F1-Score \\\\
\\midrule
"""
    
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
        table2 += f"{model_name} & {acc:.3f} & {prec:.3f} & {rec:.3f} & {f1:.3f} \\\\\n"
    
    table2 += """\\bottomrule
\\end{tabular}
\\end{table}
"""
    
    # Table 4: Inference Time
    table4 = """\\begin{table}[htbp]
\\centering
\\caption{Inference Time Comparison}
\\label{tab:inference_time}
\\begin{tabular}{lcc}
\\toprule
Model & Mean Time (ms) & Std Dev (ms) \\\\
\\midrule
"""
    
    for model_key, model_name in models:
        mean_time = results[model_key]['inference_time_mean_ms']
        std_time = results[model_key]['inference_time_std_ms']
        table4 += f"{model_name} & {mean_time:.2f} & {std_time:.2f} \\\\\n"
    
    table4 += """\\bottomrule
\\end{tabular}
\\end{table}
"""
    
    return table2, table4

def add_data_availability_section():
    """Create Data Availability section"""
    
    section = """
\\section{Data Availability Statement}

The code for model training, evaluation, and figure generation is publicly available at: \\url{https://github.com/[USERNAME]/corrosion-classification}

The trained model weights are available upon reasonable request to the corresponding author. The dataset cannot be publicly shared due to proprietary restrictions.

\\textbf{Reproducibility:} All experiments used random seed 42 for reproducibility. Software versions: Python 3.12, TensorFlow 2.20.0, NumPy 2.2.6, scikit-learn 1.7.2.

"""
    return section

def update_article():
    """Main function to update article"""
    
    print("="*70)
    print("UPDATING ARTICLE WITH REAL DATA")
    print("="*70)
    print()
    
    # Check if results exist
    if not os.path.exists('results/all_models_results.json'):
        print("ERROR: Results not found. Please complete training first.")
        return False
    
    # Load results
    print("Loading experimental results...")
    results, dataset_stats = load_results()
    print("✓ Results loaded")
    print()
    
    # Read article
    print("Reading article...")
    with open('artigo_pure_classification.tex', 'r', encoding='utf-8') as f:
        tex_content = f.read()
    print("✓ Article loaded")
    print()
    
    # Backup original
    print("Creating backup...")
    with open('artigo_pure_classification_backup.tex', 'w', encoding='utf-8') as f:
        f.write(tex_content)
    print("✓ Backup created: artigo_pure_classification_backup.tex")
    print()
    
    # Update dataset section
    print("Updating dataset section...")
    tex_content = update_dataset_section(tex_content, dataset_stats)
    print("✓ Dataset section updated")
    print()
    
    # Create tables
    print("Creating results tables...")
    table2, table4 = create_results_tables(results)
    
    # Save tables to separate files for manual insertion
    with open('results/table2_overall_performance.tex', 'w') as f:
        f.write(table2)
    with open('results/table4_inference_time.tex', 'w') as f:
        f.write(table4)
    
    print("✓ Tables saved to results/")
    print()
    
    # Add Data Availability section
    print("Adding Data Availability section...")
    data_avail = add_data_availability_section()
    
    # Insert before \end{document}
    tex_content = tex_content.replace('\\end{document}', data_avail + '\\end{document}')
    print("✓ Data Availability section added")
    print()
    
    # Save updated article
    print("Saving updated article...")
    with open('artigo_pure_classification_updated.tex', 'w', encoding='utf-8') as f:
        f.write(tex_content)
    print("✓ Updated article saved: artigo_pure_classification_updated.tex")
    print()
    
    # Print summary
    print("="*70)
    print("ARTICLE UPDATE SUMMARY")
    print("="*70)
    print()
    print("Updated:")
    print(f"  - Total images: {dataset_stats['dataset']['total_images']}")
    print(f"  - Class 0: {dataset_stats['class_distribution']['class_0']['count']} images")
    print(f"  - Class 1: {dataset_stats['class_distribution']['class_1']['count']} images")
    print(f"  - Class 2: {dataset_stats['class_distribution']['class_2']['count']} images")
    print(f"  - Thresholds: {dataset_stats['thresholds']['threshold_low']:.0f}%, {dataset_stats['thresholds']['threshold_high']:.0f}%")
    print()
    print("Results:")
    print(f"  - ResNet50: {results['resnet50']['test_accuracy']:.3f} accuracy")
    print(f"  - EfficientNet-B0: {results['efficientnet']['test_accuracy']:.3f} accuracy")
    print(f"  - Custom CNN: {results['custom_cnn']['test_accuracy']:.3f} accuracy")
    print()
    print("Files created:")
    print("  - artigo_pure_classification_updated.tex (updated article)")
    print("  - artigo_pure_classification_backup.tex (original backup)")
    print("  - results/table2_overall_performance.tex")
    print("  - results/table4_inference_time.tex")
    print()
    print("Next steps:")
    print("  1. Review artigo_pure_classification_updated.tex")
    print("  2. Manually insert tables where needed")
    print("  3. Update figure references")
    print("  4. Compile with compile_pure_classification.bat")
    print()
    
    return True

if __name__ == '__main__':
    success = update_article()
    if success:
        print("✅ Article update completed successfully!")
    else:
        print("❌ Article update failed. Check error messages above.")
