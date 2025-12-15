# Dataset Documentation - Corrosion Classification

## Overview

This document provides comprehensive documentation for the corrosion severity classification dataset used in the article "Automated Corrosion Severity Classification in ASTM A572 Grade 50 Steel Using Deep Learning".

## Dataset Description

### Source

The classification dataset is derived from the segmentation dataset presented in our previous work:

> Gonçalves, H. O., Porto, D., Amaral, R., & Quadrelli, G. (2024). "Automated Corrosion Detection in ASTM A572 Grade 50 Steel Structures Using Deep Learning Segmentation." Journal of Computing in Civil Engineering, ASCE.

### Dataset Composition

- **Total Images:** 414
- **Image Format:** JPEG/PNG
- **Image Resolution:** Variable (resized to 224×224 for training)
- **Color Space:** RGB
- **Classes:** 4 (hierarchical severity levels)

### Class Definition

The dataset uses a hierarchical 4-class classification system based on the percentage of corroded area:

| Class | Label | Severity | Corroded Area | Description |
|-------|-------|----------|---------------|-------------|
| 0 | None | No corrosion | 0% | No visible corrosion |
| 1 | Light | Light corrosion | < 10% | Minor surface corrosion |
| 2 | Moderate | Moderate corrosion | 10-30% | Significant corrosion requiring attention |
| 3 | Severe | Severe corrosion | > 30% | Critical corrosion requiring immediate action |

### Dataset Statistics

#### Overall Distribution

| Split | Total | Class 0 | Class 1 | Class 2 | Class 3 |
|-------|-------|---------|---------|---------|---------|
| Train | 290 (70%) | 87 (30.0%) | 72 (24.8%) | 78 (26.9%) | 53 (18.3%) |
| Validation | 62 (15%) | 19 (30.6%) | 15 (24.2%) | 17 (27.4%) | 11 (17.7%) |
| Test | 62 (15%) | 18 (29.0%) | 16 (25.8%) | 16 (25.8%) | 12 (19.4%) |
| **Total** | **414** | **124 (30.0%)** | **103 (24.9%)** | **111 (26.8%)** | **76 (18.4%)** |

#### Class Balance Analysis

- **Most Common Class:** Class 0 (No corrosion) - 30.0%
- **Least Common Class:** Class 3 (Severe) - 18.4%
- **Imbalance Ratio:** 1.63:1 (acceptable for deep learning)
- **Stratification:** All splits maintain similar class distributions

## Label Generation Process

### Methodology

Labels are automatically generated from pixel-level segmentation masks using a threshold-based approach:

```matlab
function class = generateLabel(maskPath)
    % Load segmentation mask
    mask = imread(maskPath);
    
    % Convert to binary if needed
    if size(mask, 3) == 3
        mask = rgb2gray(mask);
    end
    mask = mask > 0;
    
    % Calculate corroded percentage
    corroded_pixels = sum(mask(:));
    total_pixels = numel(mask);
    corroded_percentage = (corroded_pixels / total_pixels) * 100;
    
    % Assign class based on thresholds
    if corroded_percentage == 0
        class = 0;  % No corrosion
    elseif corroded_percentage < 10
        class = 1;  % Light
    elseif corroded_percentage < 30
        class = 2;  % Moderate
    else
        class = 3;  % Severe
    end
end
```

### Threshold Rationale

The thresholds (0%, 10%, 30%) were selected based on:

1. **Engineering Standards:** ASTM and NACE guidelines for corrosion severity assessment
2. **Structural Impact:** Correlation with structural integrity degradation
3. **Maintenance Priorities:** Alignment with inspection and maintenance protocols
4. **Statistical Distribution:** Natural clustering in the dataset

### Validation

Label generation was validated by:
- Manual inspection of 50 random samples (100% agreement)
- Cross-validation with domain experts (structural engineers)
- Consistency check with segmentation results

## Accessing the Dataset

### Option 1: Generate from Segmentation Dataset

If you have the segmentation dataset, generate classification labels:

```matlab
% Run label generation script
>> gerar_labels_classificacao

% Output: output/classification/labels.csv
```

The generated `labels.csv` file contains:
```csv
filename,class,corroded_percentage,split
img001.jpg,0,0.00,train
img002.jpg,1,5.23,train
img003.jpg,2,15.67,validation
img004.jpg,3,42.89,test
...
```

### Option 2: Download Pre-generated Labels

Pre-generated labels are available in the repository:

**File:** `output/classification/labels.csv`  
**Size:** ~25 KB  
**Format:** CSV with headers  
**Columns:**
- `filename`: Image filename
- `class`: Severity class (0-3)
- `corroded_percentage`: Exact percentage of corroded area
- `split`: Dataset split (train/validation/test)

### Option 3: Request Full Dataset

For access to the complete image dataset:

1. **Contact:** heitor.goncalves@ucp.br
2. **Purpose:** Specify research or educational use
3. **Agreement:** Sign data usage agreement
4. **Delivery:** Dataset provided via secure transfer

**Note:** The dataset is available for academic and research purposes only.

## Dataset Structure

### Directory Organization

```
dataset/
├── images/                      # Original images
│   ├── img001.jpg
│   ├── img002.jpg
│   └── ...
├── masks/                       # Segmentation masks (for label generation)
│   ├── mask001.jpg
│   ├── mask002.jpg
│   └── ...
└── labels.csv                   # Classification labels
```

### File Naming Convention

- **Images:** `img{ID}.jpg` where ID is a 3-digit number (001-414)
- **Masks:** `mask{ID}.jpg` matching the corresponding image ID
- **Consistency:** All IDs are consistent across images and masks

## Sample Images

### Class 0: No Corrosion

**Example:** `img001.jpg`
- **Corroded Area:** 0%
- **Description:** Clean steel surface with no visible corrosion
- **Visual Characteristics:** Uniform metallic appearance, no discoloration

### Class 1: Light Corrosion

**Example:** `img045.jpg`
- **Corroded Area:** 5.23%
- **Description:** Minor surface rust, localized spots
- **Visual Characteristics:** Small rust patches, mostly intact surface

### Class 2: Moderate Corrosion

**Example:** `img123.jpg`
- **Corroded Area:** 18.45%
- **Description:** Significant rust coverage, surface degradation
- **Visual Characteristics:** Multiple rust areas, visible pitting

### Class 3: Severe Corrosion

**Example:** `img287.jpg`
- **Corroded Area:** 45.67%
- **Description:** Extensive corrosion, structural concern
- **Visual Characteristics:** Heavy rust, significant material loss

**Note:** Sample images are included in `figuras_classificacao/figura_exemplos_classes.pdf`

## Data Preprocessing

### Image Preprocessing Pipeline

```matlab
function preprocessedImg = preprocessImage(img)
    % 1. Resize to model input size
    preprocessedImg = imresize(img, [224 224]);
    
    % 2. Normalize to [0, 1]
    preprocessedImg = im2double(preprocessedImg);
    
    % 3. Ensure RGB format
    if size(preprocessedImg, 3) == 1
        preprocessedImg = repmat(preprocessedImg, [1 1 3]);
    end
end
```

### Data Augmentation (Training Only)

```matlab
augmenter = imageDataAugmenter( ...
    'RandXReflection', true, ...           % Horizontal flip
    'RandYReflection', true, ...           % Vertical flip
    'RandRotation', [-15 15], ...          % Rotation ±15°
    'RandXScale', [0.8 1.2], ...           % Scale variation
    'RandYScale', [0.8 1.2], ...
    'RandXTranslation', [-10 10], ...      % Translation
    'RandYTranslation', [-10 10]);
```

## Dataset Quality Assurance

### Quality Checks Performed

1. **Image Integrity:**
   - All images successfully loaded
   - No corrupted files
   - Consistent format (RGB, JPEG/PNG)

2. **Label Consistency:**
   - All images have corresponding labels
   - No missing or duplicate entries
   - Class distribution validated

3. **Split Integrity:**
   - No overlap between train/val/test
   - Stratified distribution maintained
   - Reproducible random seed (42)

4. **Mask-Label Correspondence:**
   - Labels match mask-derived percentages
   - Threshold application verified
   - Manual validation performed

### Validation Script

```matlab
% validate_dataset.m
function report = validate_dataset()
    % Load labels
    labels = readtable('output/classification/labels.csv');
    
    % Check completeness
    assert(height(labels) == 414, 'Incorrect number of labels');
    
    % Check class distribution
    classCounts = histcounts(labels.class, 0:4);
    fprintf('Class Distribution:\n');
    for i = 0:3
        fprintf('  Class %d: %d (%.2f%%)\n', i, classCounts(i+1), ...
            classCounts(i+1)/414*100);
    end
    
    % Check split distribution
    splitCounts = groupcounts(labels, 'split');
    fprintf('\nSplit Distribution:\n');
    disp(splitCounts);
    
    % Validate files exist
    for i = 1:height(labels)
        imgPath = fullfile('img/original', labels.filename{i});
        assert(isfile(imgPath), 'Missing image: %s', labels.filename{i});
    end
    
    fprintf('\n✓ Dataset validation passed!\n');
end
```

## Usage Examples

### Example 1: Load Dataset for Training

```matlab
% Load labels
labels = readtable('output/classification/labels.csv');

% Filter training data
trainData = labels(strcmp(labels.split, 'train'), :);

% Create image datastore
imds = imageDatastore(fullfile('img/original', trainData.filename));
imds.Labels = categorical(trainData.class);

% Create augmented datastore
augimds = augmentedImageDatastore([224 224], imds, ...
    'DataAugmentation', augmenter);
```

### Example 2: Analyze Class Distribution

```matlab
% Load labels
labels = readtable('output/classification/labels.csv');

% Calculate statistics
classCounts = histcounts(labels.class, 0:4);
classPercentages = classCounts / sum(classCounts) * 100;

% Visualize
figure;
bar(0:3, classCounts);
xlabel('Severity Class');
ylabel('Number of Images');
title('Class Distribution');
xticklabels({'None', 'Light', 'Moderate', 'Severe'});
grid on;
```

### Example 3: Stratified Split Verification

```matlab
% Load labels
labels = readtable('output/classification/labels.csv');

% Calculate per-split class distribution
splits = {'train', 'validation', 'test'};
for i = 1:length(splits)
    splitData = labels(strcmp(labels.split, splits{i}), :);
    classCounts = histcounts(splitData.class, 0:4);
    classPercentages = classCounts / sum(classCounts) * 100;
    
    fprintf('%s Split:\n', splits{i});
    for j = 0:3
        fprintf('  Class %d: %.2f%%\n', j, classPercentages(j+1));
    end
    fprintf('\n');
end
```

## Dataset Limitations

### Known Limitations

1. **Dataset Size:** 414 images is relatively small for deep learning
   - **Mitigation:** Transfer learning from ImageNet
   - **Mitigation:** Data augmentation during training

2. **Class Imbalance:** Severe class (18.4%) underrepresented
   - **Mitigation:** Stratified sampling
   - **Mitigation:** Class weighting in loss function

3. **Single Steel Type:** Limited to ASTM A572 Grade 50
   - **Impact:** Generalization to other steel types not validated
   - **Future Work:** Expand to multiple steel grades

4. **Controlled Conditions:** Images from similar lighting/angles
   - **Impact:** Real-world variability may be higher
   - **Future Work:** Include diverse capture conditions

5. **Binary Masks:** Segmentation masks are binary (corroded/not)
   - **Impact:** No distinction between rust types
   - **Future Work:** Multi-class segmentation

## Citation

If you use this dataset, please cite:

```bibtex
@article{goncalves2025classification,
  title={Automated Corrosion Severity Classification in ASTM A572 Grade 50 Steel Using Deep Learning: A Hierarchical Approach for Structural Health Monitoring},
  author={Gonçalves, Heitor Oliveira and Porto, Darlan and Amaral, Renato and Quadrelli, Giovane},
  journal={Journal of Computing in Civil Engineering, ASCE},
  year={2025},
  note={Submitted}
}

@article{goncalves2024segmentation,
  title={Automated Corrosion Detection in ASTM A572 Grade 50 Steel Structures Using Deep Learning Segmentation},
  author={Gonçalves, Heitor Oliveira and Porto, Darlan and Amaral, Renato and Quadrelli, Giovane},
  journal={Journal of Computing in Civil Engineering, ASCE},
  year={2024}
}
```

## Contact

For dataset access, questions, or collaboration:

**Author:** Heitor Oliveira Gonçalves  
**Email:** heitor.goncalves@ucp.br  
**Institution:** Catholic University of Petrópolis (UCP)  
**LinkedIn:** [linkedin.com/in/heitorhog](https://www.linkedin.com/in/heitorhog/)

## License

This dataset is provided for academic and research purposes only. Commercial use requires explicit permission.

**Terms of Use:**
- ✓ Academic research
- ✓ Educational purposes
- ✓ Non-commercial applications
- ✗ Commercial use without permission
- ✗ Redistribution without attribution

---

**Last Updated:** January 2025  
**Version:** 1.0  
**Dataset Version:** 1.0
