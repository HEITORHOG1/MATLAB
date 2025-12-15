"""
Generate sample images figure showing examples from each corrosion class.
Creates a 3x2 grid with 2 examples per class.
"""

import json
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from pathlib import Path
import numpy as np

# Read dataset splits to get class information
with open('results/dataset_splits_files.json', 'r') as f:
    splits = json.load(f)

# Collect images by class
class_images = {0: [], 1: [], 2: []}

# Get all images from train, val, and test sets
all_images = []
if 'train' in splits:
    all_images.extend(splits['train'])
if 'val' in splits:
    all_images.extend(splits['val'])
if 'validation' in splits:
    all_images.extend(splits['validation'])
if 'test' in splits:
    all_images.extend(splits['test'])

for img_info in all_images:
    class_label = img_info['class']
    img_path = img_info['original_path'].replace('\\', '/')
    percentage = img_info['percentage']
    class_images[class_label].append({
        'path': img_path,
        'percentage': percentage
    })

# Select 2 representative images per class
# For Class 0: low percentage (< 5%)
# For Class 1: mid-range percentage (15-20%)
# For Class 2: high percentage (> 25%)

selected_images = {}

# Class 0: Select images with very low corrosion
class_0_sorted = sorted(class_images[0], key=lambda x: x['percentage'])
selected_images[0] = [class_0_sorted[5], class_0_sorted[10]]  # Pick diverse examples

# Class 1: Select images with moderate corrosion
class_1_sorted = sorted(class_images[1], key=lambda x: abs(x['percentage'] - 15))
selected_images[1] = [class_1_sorted[0], class_1_sorted[5]]

# Class 2: Select images with high corrosion
class_2_sorted = sorted(class_images[2], key=lambda x: x['percentage'], reverse=True)
selected_images[2] = [class_2_sorted[2], class_2_sorted[8]]  # Pick diverse examples

# Create figure with much more space for text labels
fig = plt.figure(figsize=(14, 15))
gs = fig.add_gridspec(3, 2, left=0.25, right=0.98, top=0.96, bottom=0.02, 
                      hspace=0.15, wspace=0.08)

fig.suptitle('Representative Examples from Corrosion Dataset', 
             fontsize=16, fontweight='bold', y=0.985)

class_names = {
    0: r'Class 0: None/Light ($P_c < 10\%$)',
    1: r'Class 1: Moderate ($10\% \leq P_c < 30\%$)',
    2: r'Class 2: Severe ($P_c \geq 30\%$)'
}

class_descriptions = {
    0: 'Minimal surface rust,\nno structural concern',
    1: 'Visible corrosion,\nmaintenance planning required',
    2: 'Extensive metal loss,\nimmediate intervention required'
}

# Plot images
for class_idx in range(3):
    for col_idx in range(2):
        ax = fig.add_subplot(gs[class_idx, col_idx])
        
        img_info = selected_images[class_idx][col_idx]
        img_path = img_info['path']
        percentage = img_info['percentage']
        
        # Load and display image
        try:
            img = mpimg.imread(img_path)
            ax.imshow(img, cmap='gray')
            ax.set_title(f'$P_c = {percentage:.1f}\\%$', fontsize=13, pad=8)
            ax.axis('off')
        except Exception as e:
            print(f"Error loading {img_path}: {e}")
            ax.text(0.5, 0.5, 'Image not found', ha='center', va='center')
            ax.axis('off')
        
        # Add class label on the left side - only for first column
        if col_idx == 0:
            # Get the position of the subplot
            bbox = ax.get_position()
            y_center = bbox.y0 + bbox.height / 2
            
            # Add class name to the left of the images
            fig.text(0.02, y_center + 0.03, class_names[class_idx], 
                    fontsize=12, fontweight='bold', va='center',
                    ha='left')
            
            # Add description below class name
            fig.text(0.02, y_center - 0.02, class_descriptions[class_idx], 
                    fontsize=10, va='center', ha='left',
                    style='italic', color='#555555',
                    linespacing=1.5)

# Save figure
output_path = 'figuras_pure_classification/figura_sample_images.pdf'
plt.savefig(output_path, dpi=300, bbox_inches='tight', format='pdf')
print(f"✓ Sample images figure saved to: {output_path}")

# Also save as PNG for preview
output_path_png = 'figuras_pure_classification/figura_sample_images.png'
plt.savefig(output_path_png, dpi=300, bbox_inches='tight', format='png')
print(f"✓ PNG preview saved to: {output_path_png}")

plt.close()

# Print selected images info
print("\nSelected images:")
for class_idx in range(3):
    print(f"\n{class_names[class_idx]}:")
    for i, img_info in enumerate(selected_images[class_idx], 1):
        print(f"  Example {i}: {img_info['path']} (Pc = {img_info['percentage']:.2f}%)")
