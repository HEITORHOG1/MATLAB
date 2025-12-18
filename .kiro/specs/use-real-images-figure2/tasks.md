# Implementation Plan - Use Real Images in Figure 2

## Overview

This implementation plan outlines the tasks for replacing the placeholder Figure 2 with real corrosion images from the dataset, processing masks to calculate corroded percentages, and generating a professional figure with actual examples.

## Tasks

- [x] 1. Create Python script to process images


  - Create script `generate_figure2_real_images.py`
  - Implement function to calculate corroded percentage from masks
  - Implement function to classify images into severity classes
  - Implement function to select representative images
  - Implement function to generate Figure 2 with real images
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4, 2.5, 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 2. Process all images and calculate percentages


  - Run script to process all 207 image pairs
  - Calculate corroded percentage for each mask
  - Classify each image into Class 0, 1, or 2
  - Save results with filename, percentage, and class
  - Report class distribution statistics
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 3. Select representative images for each class

  - Select 4-6 images per class
  - Ensure diverse corroded percentages within each class
  - Prioritize clear, representative examples
  - Verify selection covers range of corrosion manifestations
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 4. Generate Figure 2 with real images

  - Create 3×4 or 3×6 grid layout
  - Load and display original images (not masks)
  - Add labels with class name and corroded percentage
  - Format with professional styling
  - Export as PDF at 300 DPI to `figuras_pure_classification/figura_exemplos_classes.pdf`
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 5. Verify figure quality

  - Open generated PDF and inspect visually
  - Check that images are clear and high-quality
  - Verify labels are accurate and readable
  - Confirm layout is balanced and professional
  - Validate file size is reasonable (~500-800 KB)
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 6. Recompile article with new figure



  - Run `compile_pure_classification.bat` to recompile article
  - Verify Figure 2 appears correctly in PDF
  - Check that image quality is acceptable in compiled article
  - Confirm figure caption matches content
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 7. Create MATLAB alternative script (if needed)
  - Create MATLAB script `generate_figure2_matlab.m`
  - Implement image processing in MATLAB
  - Implement classification logic
  - Implement figure generation
  - Test MATLAB script if Python version has issues
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

## Notes

- The dataset contains 207 image pairs (original + mask)
- Images are 256×256 grayscale
- Masks are binary (white = corroded, black = non-corroded)
- Expected class distribution based on article: ~59% Class 0, ~27% Class 1, ~14% Class 2
- Python script uses PIL and matplotlib (already installed)
- MATLAB alternative available if Python has issues
- Figure 2 will be much more professional with real images

## Data Paths

- Original images: `img/original/`
- Mask images: `img/masks/`
- Output figure: `figuras_pure_classification/figura_exemplos_classes.pdf`

## Expected Results

After processing:
- Class 0 (None/Light): ~122 images (Pc < 10%)
- Class 1 (Moderate): ~56 images (10% ≤ Pc < 30%)
- Class 2 (Severe): ~29 images (Pc ≥ 30%)

Selected for figure:
- 4 images from Class 0
- 4 images from Class 1
- 4 images from Class 2
- Total: 12 images in 3×4 grid
