# Design Document - Use Real Images in Figure 2

## Overview

This document outlines the design for replacing the placeholder Figure 2 with real corrosion images from the dataset. We will process the mask images to calculate corroded percentages, classify images into severity classes, select representative examples, and generate a professional figure with real images.

## Data Structure

### Image Directories
- **Original Images:** `img/original/` - 207 grayscale steel structure images
- **Mask Images:** `img/masks/` - 207 binary segmentation masks
- **Naming Convention:** `Whisk_[hash]_[num]_[type]_256_gray.jpg`

### Image Pairs
Each original image has a corresponding mask:
- Original: `Whisk_00d5ba3dc4_1_PRINCIPAL_256_gray.jpg`
- Mask: `Whisk_00d5ba3dc4_1_CORROSAO_256_gray.jpg`

## Processing Pipeline

### Step 1: Calculate Corroded Percentage

For each mask image:
1. Load mask as grayscale
2. Threshold at 127 to binarize (white = corroded, black = non-corroded)
3. Count white pixels
4. Calculate percentage: `Pc = (white_pixels / total_pixels) × 100%`

### Step 2: Classify Images

Based on corroded percentage:
- **Class 0 (None/Light):** Pc < 10%
- **Class 1 (Moderate):** 10% ≤ Pc < 30%
- **Class 2 (Severe):** Pc ≥ 30%

### Step 3: Select Representative Images

Selection criteria:
- 4-6 images per class
- Diverse corroded percentages within each class
- Clear visual examples
- Avoid very similar images

Target distribution:
- Class 0: Select images with Pc ≈ 0%, 2%, 5%, 8%
- Class 1: Select images with Pc ≈ 12%, 16%, 20%, 25%
- Class 2: Select images with Pc ≈ 32%, 40%, 50%, 60%+

### Step 4: Generate Figure

Layout:
- 3 rows (one per class)
- 4-6 columns (examples per class)
- Each cell: original image + label
- Labels: "Class X: Y.Z%"

## Python Implementation

### Script: `generate_figure2_real_images.py`

```python
import os
import numpy as np
from PIL import Image
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def calculate_corroded_percentage(mask_path):
    """Calculate corroded percentage from mask image"""
    mask = Image.open(mask_path).convert('L')
    mask_array = np.array(mask)
    
    # Threshold at 127 to binarize
    binary_mask = (mask_array > 127).astype(np.uint8)
    
    # Calculate percentage
    total_pixels = binary_mask.size
    corroded_pixels = np.sum(binary_mask)
    percentage = (corroded_pixels / total_pixels) * 100
    
    return percentage

def classify_image(percentage):
    """Classify image based on corroded percentage"""
    if percentage < 10:
        return 0  # None/Light
    elif percentage < 30:
        return 1  # Moderate
    else:
        return 2  # Severe

def process_all_images(original_dir, mask_dir):
    """Process all images and classify them"""
    results = []
    
    for mask_file in os.listdir(mask_dir):
        if not mask_file.endswith('.jpg'):
            continue
        
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
    selected = {0: [], 1: [], 2: []}
    
    # Group by class
    for result in results:
        selected[result['class']].append(result)
    
    # Sort each class by percentage
    for class_label in selected:
        selected[class_label].sort(key=lambda x: x['percentage'])
    
    # Select evenly distributed examples
    final_selection = []
    for class_label in [0, 1, 2]:
        class_images = selected[class_label]
        n = len(class_images)
        
        if n == 0:
            continue
        
        # Select evenly spaced indices
        if n <= num_per_class:
            indices = range(n)
        else:
            step = n / num_per_class
            indices = [int(i * step) for i in range(num_per_class)]
        
        for idx in indices:
            final_selection.append(class_images[idx])
    
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
    
    class_names = ['Class 0: None/Light (<10%)', 
                   'Class 1: Moderate (10-30%)', 
                   'Class 2: Severe (≥30%)']
    
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
                    ax.set_ylabel(class_names[class_label], fontsize=9, 
                                 weight='bold', rotation=0, ha='right', va='center')
            else:
                # Empty cell
                ax.axis('off')
            
            ax.set_xticks([])
            ax.set_yticks([])
            
            # Add border
            for spine in ax.spines.values():
                spine.set_edgecolor('black')
                spine.set_linewidth(1.5)
    
    plt.suptitle('Sample Images by Severity Class', fontsize=12, weight='bold')
    plt.tight_layout()
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
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
    
    # Process all images
    print("Processing images...")
    results = process_all_images(original_dir, mask_dir)
    print(f"✓ Processed {len(results)} images")
    
    # Count by class
    class_counts = {0: 0, 1: 0, 2: 0}
    for r in results:
        class_counts[r['class']] += 1
    
    print(f"  Class 0 (None/Light): {class_counts[0]} images")
    print(f"  Class 1 (Moderate): {class_counts[1]} images")
    print(f"  Class 2 (Severe): {class_counts[2]} images")
    print()
    
    # Select representative images
    print("Selecting representative images...")
    selected = select_representative_images(results, num_per_class=4)
    print(f"✓ Selected {len(selected)} images")
    print()
    
    # Generate figure
    print("Generating figure...")
    generate_figure2(selected, output_path)
    print()
    
    print("="*60)
    print("✓ Figure 2 generated successfully!")
    print("="*60)

if __name__ == '__main__':
    main()
```

## Alternative: MATLAB Implementation

If Python processing has issues, we can use MATLAB:

### Script: `generate_figure2_matlab.m`

```matlab
% Generate Figure 2 with Real Images

% Paths
original_dir = 'img/original';
mask_dir = 'img/masks';
output_path = 'figuras_pure_classification/figura_exemplos_classes.pdf';

% Get all mask files
mask_files = dir(fullfile(mask_dir, '*.jpg'));

% Process all images
results = struct('original_path', {}, 'percentage', {}, 'class', {});

for i = 1:length(mask_files)
    mask_file = mask_files(i).name;
    
    % Get corresponding original image
    original_file = strrep(mask_file, '_CORROSAO_', '_PRINCIPAL_');
    original_path = fullfile(original_dir, original_file);
    mask_path = fullfile(mask_dir, mask_file);
    
    if ~exist(original_path, 'file')
        continue;
    end
    
    % Load mask and calculate percentage
    mask = imread(mask_path);
    binary_mask = mask > 127;
    percentage = sum(binary_mask(:)) / numel(binary_mask) * 100;
    
    % Classify
    if percentage < 10
        class_label = 0;
    elseif percentage < 30
        class_label = 1;
    else
        class_label = 2;
    end
    
    % Store result
    results(end+1).original_path = original_path;
    results(end).percentage = percentage;
    results(end).class = class_label;
end

fprintf('Processed %d images\n', length(results));

% Select representative images (4 per class)
selected = struct('original_path', {}, 'percentage', {}, 'class', {});

for class_label = 0:2
    class_images = results([results.class] == class_label);
    [~, idx] = sort([class_images.percentage]);
    class_images = class_images(idx);
    
    n = length(class_images);
    if n > 0
        step = max(1, floor(n / 4));
        indices = 1:step:n;
        indices = indices(1:min(4, length(indices)));
        
        for j = indices
            selected(end+1) = class_images(j);
        end
    end
end

% Generate figure
fig = figure('Position', [100, 100, 1000, 750]);

class_names = {'Class 0: None/Light (<10%)', ...
               'Class 1: Moderate (10-30%)', ...
               'Class 2: Severe (≥30%)'};

for row = 1:3
    class_label = row - 1;
    class_images = selected([selected.class] == class_label);
    
    for col = 1:4
        subplot(3, 4, (row-1)*4 + col);
        
        if col <= length(class_images)
            img = imread(class_images(col).original_path);
            imshow(img);
            title(sprintf('%.1f%%', class_images(col).percentage), ...
                  'FontSize', 9, 'FontWeight', 'bold');
            
            if col == 1
                ylabel(class_names{row}, 'FontSize', 9, ...
                       'FontWeight', 'bold', 'Rotation', 0, ...
                       'HorizontalAlignment', 'right');
            end
        else
            axis off;
        end
    end
end

sgtitle('Sample Images by Severity Class', 'FontSize', 12, 'FontWeight', 'bold');

% Save as PDF
print(fig, output_path, '-dpdf', '-r300');
close(fig);

fprintf('✓ Figure 2 saved to: %s\n', output_path);
```

## Quality Assurance

### Verification Steps
1. Check that all selected images load correctly
2. Verify corroded percentages are accurate
3. Ensure class distribution is balanced
4. Confirm figure quality (300 DPI, clear images)
5. Validate labels match calculated percentages

### Expected Output
- Figure 2: 3×4 grid (12 images total)
- Class 0: 4 images with Pc < 10%
- Class 1: 4 images with Pc 10-30%
- Class 2: 4 images with Pc ≥ 30%
- File size: ~500-800 KB (PDF with embedded images)

## Integration

After generating the new Figure 2:
1. Replace old `figura_exemplos_classes.pdf`
2. Recompile article: `compile_pure_classification.bat`
3. Verify figure appears correctly in PDF
4. Check that image quality is acceptable

## Fallback Plan

If automatic selection doesn't produce good results:
1. Manually review selected images
2. Adjust selection criteria
3. Manually specify image filenames
4. Regenerate figure with manual selection
