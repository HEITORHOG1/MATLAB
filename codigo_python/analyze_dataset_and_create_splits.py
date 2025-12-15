"""
Comprehensive Dataset Analysis and Split Creation
Analyzes all 217 images, determines optimal thresholds, creates stratified splits
"""

import os
import json
import numpy as np
from PIL import Image
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from collections import Counter

# Configuration
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman', 'DejaVu Serif']
plt.rcParams['font.size'] = 10
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.dpi'] = 300

# Random seed for reproducibility
RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)

def calculate_corroded_percentage(mask_path):
    """Calculate corroded percentage from mask image"""
    try:
        mask = Image.open(mask_path).convert('L')
        mask_array = np.array(mask)
        
        # Threshold at 127 to binarize (white = corroded)
        binary_mask = (mask_array > 127).astype(np.uint8)
        
        # Calculate percentage
        total_pixels = binary_mask.size
        corroded_pixels = np.sum(binary_mask)
        percentage = (corroded_pixels / total_pixels) * 100
        
        return percentage
    except Exception as e:
        print(f"Error processing {mask_path}: {e}")
        return None

def analyze_all_images(original_dir, mask_dir):
    """Analyze all images and calculate corrosion percentages"""
    results = []
    
    mask_files = sorted([f for f in os.listdir(mask_dir) if f.endswith('.jpg')])
    
    print(f"Found {len(mask_files)} mask files")
    print("Analyzing images...")
    
    for i, mask_file in enumerate(mask_files):
        if (i + 1) % 50 == 0:
            print(f"  Processed {i + 1}/{len(mask_files)} images...")
        
        # Get corresponding original image
        original_file = mask_file.replace('_CORROSAO_', '_PRINCIPAL_')
        original_path = os.path.join(original_dir, original_file)
        mask_path = os.path.join(mask_dir, mask_file)
        
        if not os.path.exists(original_path):
            print(f"  Warning: Original image not found for {mask_file}")
            continue
        
        # Calculate percentage
        percentage = calculate_corroded_percentage(mask_path)
        
        if percentage is not None:
            results.append({
                'original_path': original_path,
                'mask_path': mask_path,
                'percentage': percentage,
                'filename': original_file
            })
    
    print(f"✓ Successfully analyzed {len(results)} images")
    return results

def determine_optimal_thresholds(percentages, method='quantile'):
    """
    Determine optimal thresholds for classification
    
    Methods:
    - 'quantile': Use 33rd and 67th percentiles
    - 'domain': Use domain knowledge (8%, 11% based on initial analysis)
    - 'kmeans': Use k-means clustering
    """
    percentages_array = np.array(percentages)
    
    if method == 'quantile':
        threshold_low = np.percentile(percentages_array, 33)
        threshold_high = np.percentile(percentages_array, 67)
        print(f"  Quantile-based thresholds: {threshold_low:.2f}%, {threshold_high:.2f}%")
    
    elif method == 'domain':
        # Based on initial analysis showing max ~13%
        threshold_low = 8.0
        threshold_high = 11.0
        print(f"  Domain-knowledge thresholds: {threshold_low:.2f}%, {threshold_high:.2f}%")
    
    elif method == 'kmeans':
        from sklearn.cluster import KMeans
        X = percentages_array.reshape(-1, 1)
        kmeans = KMeans(n_clusters=3, random_state=RANDOM_SEED, n_init=10)
        kmeans.fit(X)
        centers = sorted(kmeans.cluster_centers_.flatten())
        threshold_low = (centers[0] + centers[1]) / 2
        threshold_high = (centers[1] + centers[2]) / 2
        print(f"  K-means thresholds: {threshold_low:.2f}%, {threshold_high:.2f}%")
    
    return threshold_low, threshold_high

def classify_images(results, threshold_low, threshold_high):
    """Classify images based on thresholds"""
    for result in results:
        percentage = result['percentage']
        if percentage < threshold_low:
            result['class'] = 0  # Light
        elif percentage < threshold_high:
            result['class'] = 1  # Moderate
        else:
            result['class'] = 2  # Severe
    
    return results

def create_stratified_splits(results, train_ratio=0.70, val_ratio=0.15, test_ratio=0.15):
    """Create stratified train/val/test splits"""
    assert abs(train_ratio + val_ratio + test_ratio - 1.0) < 0.001, "Ratios must sum to 1.0"
    
    # Extract labels
    labels = [r['class'] for r in results]
    indices = list(range(len(results)))
    
    # First split: train vs (val + test)
    train_idx, temp_idx = train_test_split(
        indices, 
        test_size=(val_ratio + test_ratio),
        stratify=labels,
        random_state=RANDOM_SEED
    )
    
    # Second split: val vs test
    temp_labels = [labels[i] for i in temp_idx]
    val_ratio_adjusted = val_ratio / (val_ratio + test_ratio)
    
    val_idx, test_idx = train_test_split(
        temp_idx,
        test_size=(1 - val_ratio_adjusted),
        stratify=temp_labels,
        random_state=RANDOM_SEED
    )
    
    return train_idx, val_idx, test_idx

def generate_statistics_report(results, train_idx, val_idx, test_idx, threshold_low, threshold_high):
    """Generate comprehensive statistics report"""
    
    # Overall statistics
    percentages = [r['percentage'] for r in results]
    labels = [r['class'] for r in results]
    
    stats = {
        'dataset': {
            'total_images': len(results),
            'min_percentage': float(np.min(percentages)),
            'max_percentage': float(np.max(percentages)),
            'mean_percentage': float(np.mean(percentages)),
            'median_percentage': float(np.median(percentages)),
            'std_percentage': float(np.std(percentages)),
        },
        'thresholds': {
            'threshold_low': float(threshold_low),
            'threshold_high': float(threshold_high),
            'class_0_range': f'<{threshold_low:.1f}%',
            'class_1_range': f'{threshold_low:.1f}%-{threshold_high:.1f}%',
            'class_2_range': f'≥{threshold_high:.1f}%',
        },
        'class_distribution': {
            'class_0': {
                'count': int(labels.count(0)),
                'percentage': float(labels.count(0) / len(labels) * 100),
                'min_corrosion': float(min([r['percentage'] for r in results if r['class'] == 0], default=0)),
                'max_corrosion': float(max([r['percentage'] for r in results if r['class'] == 0], default=0)),
            },
            'class_1': {
                'count': int(labels.count(1)),
                'percentage': float(labels.count(1) / len(labels) * 100),
                'min_corrosion': float(min([r['percentage'] for r in results if r['class'] == 1], default=0)),
                'max_corrosion': float(max([r['percentage'] for r in results if r['class'] == 1], default=0)),
            },
            'class_2': {
                'count': int(labels.count(2)),
                'percentage': float(labels.count(2) / len(labels) * 100),
                'min_corrosion': float(min([r['percentage'] for r in results if r['class'] == 2], default=0)),
                'max_corrosion': float(max([r['percentage'] for r in results if r['class'] == 2], default=0)),
            },
        },
        'splits': {
            'train': {
                'size': len(train_idx),
                'percentage': float(len(train_idx) / len(results) * 100),
                'class_distribution': dict(Counter([results[i]['class'] for i in train_idx])),
            },
            'validation': {
                'size': len(val_idx),
                'percentage': float(len(val_idx) / len(results) * 100),
                'class_distribution': dict(Counter([results[i]['class'] for i in val_idx])),
            },
            'test': {
                'size': len(test_idx),
                'percentage': float(len(test_idx) / len(results) * 100),
                'class_distribution': dict(Counter([results[i]['class'] for i in test_idx])),
            },
        },
        'reproducibility': {
            'random_seed': RANDOM_SEED,
            'split_ratios': [0.70, 0.15, 0.15],
        }
    }
    
    return stats

def plot_distribution_analysis(results, threshold_low, threshold_high, output_dir):
    """Create comprehensive distribution analysis plots"""
    
    percentages = [r['percentage'] for r in results]
    labels = [r['class'] for r in results]
    
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    # Plot 1: Histogram of corrosion percentages
    ax1 = axes[0, 0]
    ax1.hist(percentages, bins=30, edgecolor='black', alpha=0.7)
    ax1.axvline(threshold_low, color='red', linestyle='--', linewidth=2, label=f'Threshold 1: {threshold_low:.1f}%')
    ax1.axvline(threshold_high, color='orange', linestyle='--', linewidth=2, label=f'Threshold 2: {threshold_high:.1f}%')
    ax1.set_xlabel('Corrosion Percentage (%)')
    ax1.set_ylabel('Frequency')
    ax1.set_title('Distribution of Corrosion Percentages')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Box plot by class
    ax2 = axes[0, 1]
    class_data = [
        [r['percentage'] for r in results if r['class'] == 0],
        [r['percentage'] for r in results if r['class'] == 1],
        [r['percentage'] for r in results if r['class'] == 2],
    ]
    bp = ax2.boxplot(class_data, labels=['Class 0\n(Light)', 'Class 1\n(Moderate)', 'Class 2\n(Severe)'])
    ax2.set_ylabel('Corrosion Percentage (%)')
    ax2.set_title('Corrosion Distribution by Class')
    ax2.grid(True, alpha=0.3, axis='y')
    
    # Plot 3: Class distribution bar chart
    ax3 = axes[1, 0]
    class_counts = [labels.count(0), labels.count(1), labels.count(2)]
    class_percentages = [c / len(labels) * 100 for c in class_counts]
    bars = ax3.bar(['Class 0\n(Light)', 'Class 1\n(Moderate)', 'Class 2\n(Severe)'], 
                   class_counts, edgecolor='black', alpha=0.7)
    ax3.set_ylabel('Number of Images')
    ax3.set_title('Class Distribution')
    ax3.grid(True, alpha=0.3, axis='y')
    
    # Add percentage labels on bars
    for bar, pct in zip(bars, class_percentages):
        height = bar.get_height()
        ax3.text(bar.get_x() + bar.get_width()/2., height,
                f'{int(height)}\n({pct:.1f}%)',
                ha='center', va='bottom')
    
    # Plot 4: Cumulative distribution
    ax4 = axes[1, 1]
    sorted_percentages = sorted(percentages)
    cumulative = np.arange(1, len(sorted_percentages) + 1) / len(sorted_percentages) * 100
    ax4.plot(sorted_percentages, cumulative, linewidth=2)
    ax4.axvline(threshold_low, color='red', linestyle='--', linewidth=2, label=f'Threshold 1: {threshold_low:.1f}%')
    ax4.axvline(threshold_high, color='orange', linestyle='--', linewidth=2, label=f'Threshold 2: {threshold_high:.1f}%')
    ax4.set_xlabel('Corrosion Percentage (%)')
    ax4.set_ylabel('Cumulative Percentage (%)')
    ax4.set_title('Cumulative Distribution')
    ax4.legend()
    ax4.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'dataset_distribution_analysis.pdf'))
    plt.close()
    
    print(f"✓ Distribution analysis plot saved")

def save_splits_to_files(results, train_idx, val_idx, test_idx, output_dir):
    """Save split indices and file lists"""
    
    # Save indices
    splits_data = {
        'train_indices': train_idx,
        'val_indices': val_idx,
        'test_indices': test_idx,
    }
    
    with open(os.path.join(output_dir, 'dataset_splits_indices.json'), 'w') as f:
        json.dump(splits_data, f, indent=2)
    
    # Save file lists
    splits_files = {
        'train': [results[i] for i in train_idx],
        'validation': [results[i] for i in val_idx],
        'test': [results[i] for i in test_idx],
    }
    
    with open(os.path.join(output_dir, 'dataset_splits_files.json'), 'w') as f:
        json.dump(splits_files, f, indent=2)
    
    print(f"✓ Split files saved")

def print_summary(stats):
    """Print comprehensive summary"""
    print("\n" + "="*70)
    print("DATASET ANALYSIS SUMMARY")
    print("="*70)
    
    print(f"\n📊 OVERALL STATISTICS:")
    print(f"  Total Images: {stats['dataset']['total_images']}")
    print(f"  Corrosion Range: {stats['dataset']['min_percentage']:.2f}% - {stats['dataset']['max_percentage']:.2f}%")
    print(f"  Mean: {stats['dataset']['mean_percentage']:.2f}% ± {stats['dataset']['std_percentage']:.2f}%")
    print(f"  Median: {stats['dataset']['median_percentage']:.2f}%")
    
    print(f"\n🎯 THRESHOLDS:")
    print(f"  Threshold 1 (Light/Moderate): {stats['thresholds']['threshold_low']:.2f}%")
    print(f"  Threshold 2 (Moderate/Severe): {stats['thresholds']['threshold_high']:.2f}%")
    
    print(f"\n📈 CLASS DISTRIBUTION:")
    for class_id in [0, 1, 2]:
        class_name = ['Light', 'Moderate', 'Severe'][class_id]
        class_range = stats['thresholds'][f'class_{class_id}_range']
        class_data = stats['class_distribution'][f'class_{class_id}']
        print(f"  Class {class_id} ({class_name}, {class_range}):")
        print(f"    Count: {class_data['count']} ({class_data['percentage']:.1f}%)")
        print(f"    Corrosion Range: {class_data['min_corrosion']:.2f}% - {class_data['max_corrosion']:.2f}%")
    
    print(f"\n✂️ DATA SPLITS:")
    for split_name in ['train', 'validation', 'test']:
        split_data = stats['splits'][split_name]
        print(f"  {split_name.capitalize()}:")
        print(f"    Size: {split_data['size']} ({split_data['percentage']:.1f}%)")
        print(f"    Class Distribution: {split_data['class_distribution']}")
    
    print(f"\n🔄 REPRODUCIBILITY:")
    print(f"  Random Seed: {stats['reproducibility']['random_seed']}")
    print(f"  Split Ratios: {stats['reproducibility']['split_ratios']}")
    
    print("\n" + "="*70)

def main():
    # Paths
    original_dir = 'img/original'
    mask_dir = 'img/masks'
    output_dir = 'results'
    
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    print("="*70)
    print("COMPREHENSIVE DATASET ANALYSIS")
    print("="*70)
    print()
    
    # Check directories exist
    if not os.path.exists(original_dir):
        print(f"ERROR: Directory not found: {original_dir}")
        return
    
    if not os.path.exists(mask_dir):
        print(f"ERROR: Directory not found: {mask_dir}")
        return
    
    # Step 1: Analyze all images
    print("STEP 1: Analyzing all images...")
    results = analyze_all_images(original_dir, mask_dir)
    print()
    
    if len(results) == 0:
        print("ERROR: No images found!")
        return
    
    # Step 2: Determine optimal thresholds
    print("STEP 2: Determining optimal thresholds...")
    percentages = [r['percentage'] for r in results]
    
    print("\n  Trying different methods:")
    determine_optimal_thresholds(percentages, method='quantile')
    determine_optimal_thresholds(percentages, method='domain')
    
    # Use domain knowledge thresholds (based on initial analysis)
    threshold_low, threshold_high = 8.0, 11.0
    print(f"\n  ✓ Selected thresholds: {threshold_low:.1f}%, {threshold_high:.1f}%")
    print()
    
    # Step 3: Classify images
    print("STEP 3: Classifying images...")
    results = classify_images(results, threshold_low, threshold_high)
    print(f"✓ Classified {len(results)} images")
    print()
    
    # Step 4: Create stratified splits
    print("STEP 4: Creating stratified splits (70/15/15)...")
    train_idx, val_idx, test_idx = create_stratified_splits(results)
    print(f"✓ Train: {len(train_idx)}, Val: {len(val_idx)}, Test: {len(test_idx)}")
    print()
    
    # Step 5: Generate statistics report
    print("STEP 5: Generating statistics report...")
    stats = generate_statistics_report(results, train_idx, val_idx, test_idx, threshold_low, threshold_high)
    
    # Save statistics to JSON
    with open(os.path.join(output_dir, 'dataset_statistics.json'), 'w') as f:
        json.dump(stats, f, indent=2)
    print(f"✓ Statistics saved to: {os.path.join(output_dir, 'dataset_statistics.json')}")
    print()
    
    # Step 6: Save splits
    print("STEP 6: Saving split files...")
    save_splits_to_files(results, train_idx, val_idx, test_idx, output_dir)
    print()
    
    # Step 7: Generate distribution plots
    print("STEP 7: Generating distribution analysis plots...")
    plot_distribution_analysis(results, threshold_low, threshold_high, output_dir)
    print()
    
    # Print summary
    print_summary(stats)
    
    print("\n✅ DATASET ANALYSIS COMPLETE!")
    print(f"\nOutput files saved to: {output_dir}/")
    print("  - dataset_statistics.json")
    print("  - dataset_splits_indices.json")
    print("  - dataset_splits_files.json")
    print("  - dataset_distribution_analysis.pdf")
    print()
    print("Next step: Train models using the generated splits")

if __name__ == '__main__':
    main()
