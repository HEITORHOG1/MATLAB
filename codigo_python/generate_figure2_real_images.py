"""
Generate Figure 2 with Real Corrosion Images
Uses actual images from img/original and img/masks directories
"""

import os
import numpy as np
from PIL import Image
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

# Configuration
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman', 'DejaVu Serif']
plt.rcParams['font.size'] = 10
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.dpi'] = 300

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
        return 0.0

def classify_image(percentage):
    """Classify image based on corroded percentage"""
    if percentage < 8:
        return 0  # Light
    elif percentage < 11:
        return 1  # Moderate
    else:
        return 2  # Severe (relative to this dataset)

def process_all_images(original_dir, mask_dir):
    """Process all images and classify them"""
    results = []
    
    mask_files = [f for f in os.listdir(mask_dir) if f.endswith('.jpg')]
    
    print(f"Found {len(mask_files)} mask files")
    
    for mask_file in mask_files:
        # Get corresponding original image
        original_file = mask_file.replace('_CORROSAO_', '_PRINCIPAL_')
        original_path = os.path.join(original_dir, original_file)
        mask_path = os.path.join(mask_dir, mask_file)
        
        if not os.path.exists(original_path):
            continue
        
        # Calculate percentage and classify
        percentage = calculate_corroded_percentage(mask_path)
        class_label = classify_image(percentage)
        
        results.append({
            'original_path': original_path,
            'mask_path': mask_path,
            'percentage': percentage,
            'class': class_label,
            'filename': original_file
        })
    
    return results

def select_representative_images(results, num_per_class=4):
    """Select representative images from each class"""
    # Group by class
    class_images = {0: [], 1: [], 2: []}
    
    for result in results:
        class_images[result['class']].append(result)
    
    # Sort each class by percentage
    for class_label in class_images:
        class_images[class_label].sort(key=lambda x: x['percentage'])
    
    # Select evenly distributed examples
    final_selection = []
    
    for class_label in [0, 1, 2]:
        images = class_images[class_label]
        n = len(images)
        
        if n == 0:
            print(f"Warning: No images found for Class {class_label}")
            continue
        
        # Select evenly spaced indices
        if n <= num_per_class:
            indices = range(n)
        else:
            step = n / num_per_class
            indices = [int(i * step) for i in range(num_per_class)]
        
        for idx in indices:
            final_selection.append(images[idx])
            print(f"  Selected: Class {class_label}, {images[idx]['percentage']:.1f}% - {images[idx]['filename']}")
    
    return final_selection

def generate_figure2(selected_images, output_path):
    """Generate Figure 2 with real images"""
    # Group by class
    class_images = {0: [], 1: [], 2: []}
    for img in selected_images:
        class_images[img['class']].append(img)
    
    # Determine grid size
    max_cols = max(len(class_images[c]) for c in [0, 1, 2])
    
    fig, axes = plt.subplots(3, max_cols, figsize=(max_cols * 2.5, 7.5))
    
    class_names = ['Class 0: Light (<8%)', 
                   'Class 1: Moderate (8-11%)', 
                   'Class 2: Severe (≥11%)']
    
    for row, class_label in enumerate([0, 1, 2]):
        images = class_images[class_label]
        
        for col in range(max_cols):
            if max_cols == 1:
                ax = axes[row]
            else:
                ax = axes[row, col]
            
            if col < len(images):
                # Load and display image
                img_data = images[col]
                img = Image.open(img_data['original_path'])
                ax.imshow(img, cmap='gray')
                
                # Add label
                percentage = img_data['percentage']
                ax.set_title(f'{percentage:.1f}%', fontsize=9, weight='bold')
                
                # Add class label on first column
                if col == 0:
                    ax.text(-0.15, 0.5, class_names[class_label], 
                           transform=ax.transAxes,
                           fontsize=9, weight='bold', 
                           rotation=90, ha='right', va='center')
            else:
                # Empty cell
                ax.imshow(np.ones((256, 256)) * 255, cmap='gray')
            
            ax.set_xticks([])
            ax.set_yticks([])
            
            # Add border
            for spine in ax.spines.values():
                spine.set_edgecolor('black')
                spine.set_linewidth(1.5)
    
    plt.suptitle('Sample Images by Severity Class', fontsize=12, weight='bold')
    plt.tight_layout()
    plt.savefig(output_path, bbox_inches='tight')
    plt.close()
    
    print(f"✓ Figure 2 saved to: {output_path}")

def main():
    # Paths
    original_dir = 'img/original'
    mask_dir = 'img/masks'
    output_path = 'figuras_pure_classification/figura_exemplos_classes.pdf'
    
    print("="*60)
    print("Generating Figure 2 with Real Images")
    print("="*60)
    print()
    
    # Check directories exist
    if not os.path.exists(original_dir):
        print(f"ERROR: Directory not found: {original_dir}")
        return
    
    if not os.path.exists(mask_dir):
        print(f"ERROR: Directory not found: {mask_dir}")
        return
    
    # Process all images
    print("Processing images...")
    results = process_all_images(original_dir, mask_dir)
    print(f"✓ Processed {len(results)} images")
    print()
    
    # Count by class
    class_counts = {0: 0, 1: 0, 2: 0}
    for r in results:
        class_counts[r['class']] += 1
    
    print("Class Distribution:")
    print(f"  Class 0 (Light, <8%): {class_counts[0]} images ({class_counts[0]/len(results)*100:.1f}%)")
    print(f"  Class 1 (Moderate, 8-11%): {class_counts[1]} images ({class_counts[1]/len(results)*100:.1f}%)")
    print(f"  Class 2 (Severe, ≥11%): {class_counts[2]} images ({class_counts[2]/len(results)*100:.1f}%)")
    print()
    
    # Select representative images
    print("Selecting representative images (4 per class)...")
    selected = select_representative_images(results, num_per_class=4)
    print(f"✓ Selected {len(selected)} images total")
    print()
    
    # Generate figure
    print("Generating figure...")
    generate_figure2(selected, output_path)
    print()
    
    print("="*60)
    print("✓ Figure 2 generated successfully with REAL images!")
    print("="*60)
    print()
    print("Next step: Recompile article with compile_pure_classification.bat")

if __name__ == '__main__':
    main()
