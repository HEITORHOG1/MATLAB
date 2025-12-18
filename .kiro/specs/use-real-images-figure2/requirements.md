# Requirements Document - Use Real Images in Figure 2

## Introduction

This document specifies the requirements for replacing the placeholder Figure 2 (Sample Images Grid) with real corrosion images from the dataset located in `C:\projetos\MATLAB2\img`. The figure will show actual examples from each severity class to provide readers with visual understanding of the classification task.

## Glossary

- **Original Images**: Real steel structure images in `img/original/` directory
- **Mask Images**: Binary segmentation masks in `img/masks/` directory
- **Severity Classes**: Three classes based on corroded area percentage (Class 0: <10%, Class 1: 10-30%, Class 2: ≥30%)
- **Figure 2**: Sample Images Grid showing examples from each severity class

## Requirements

### Requirement 1: Calculate Corroded Percentage from Masks

**User Story:** As a developer, I want to calculate the corroded percentage from mask images, so that I can classify images into severity classes.

#### Acceptance Criteria

1. WHEN THE mask image is loaded, THE System SHALL read the binary mask as grayscale
2. WHEN THE corroded percentage is calculated, THE System SHALL compute the ratio of white pixels to total pixels
3. WHEN THE percentage is computed, THE System SHALL use the formula: Pc = (white_pixels / total_pixels) × 100%
4. WHEN THE calculation is complete, THE System SHALL return the corroded percentage as a float value
5. WHERE THE mask has intermediate values, THE System SHALL threshold at 127 to binarize

### Requirement 2: Classify Images into Severity Classes

**User Story:** As a developer, I want to classify images based on corroded percentage, so that I can select representative examples for each class.

#### Acceptance Criteria

1. WHEN THE corroded percentage is less than 10%, THE System SHALL assign the image to Class 0 (None/Light)
2. WHEN THE corroded percentage is between 10% and 30%, THE System SHALL assign the image to Class 1 (Moderate)
3. WHEN THE corroded percentage is 30% or greater, THE System SHALL assign the image to Class 2 (Severe)
4. WHEN THE classification is complete, THE System SHALL store the class label with the image filename
5. WHERE THE percentage is exactly at a threshold, THE System SHALL use inclusive lower bound (e.g., 10.0% is Class 1)

### Requirement 3: Select Representative Images for Each Class

**User Story:** As a researcher, I want to select diverse representative images from each class, so that the figure shows the range of corrosion manifestations.

#### Acceptance Criteria

1. WHEN THE images are selected, THE System SHALL choose 4-6 images per class
2. WHEN THE selection is made, THE System SHALL prioritize images with different corroded percentages within each class
3. WHEN THE images are chosen, THE System SHALL avoid selecting very similar images
4. WHEN THE selection is complete, THE System SHALL have a total of 12-18 images (4-6 per class × 3 classes)
5. WHERE THE class has fewer than 6 images, THE System SHALL use all available images for that class

### Requirement 4: Generate Figure 2 with Real Images

**User Story:** As a reader, I want to see real corrosion examples, so that I can understand what each severity class looks like.

#### Acceptance Criteria

1. WHEN THE figure is created, THE Figure SHALL display images in a 3×4 or 3×6 grid layout
2. WHEN THE images are arranged, THE Figure SHALL group images by class (one row per class)
3. WHEN THE images are displayed, THE Figure SHALL show the original steel images (not masks)
4. WHEN THE labels are added, THE Figure SHALL annotate each image with its class and corroded percentage
5. WHERE THE figure is saved, THE Figure SHALL be exported as PDF at 300 DPI to `figuras_pure_classification/figura_exemplos_classes.pdf`

### Requirement 5: Maintain Publication Quality

**User Story:** As an author, I want publication-quality figure, so that the article meets journal standards.

#### Acceptance Criteria

1. WHEN THE figure is created, THE Figure SHALL use 300 DPI resolution
2. WHEN THE images are displayed, THE Images SHALL be clearly visible and not pixelated
3. WHEN THE text is added, THE Text SHALL use readable fonts (10-12pt minimum)
4. WHEN THE layout is designed, THE Layout SHALL be clean and professional
5. WHERE THE figure includes borders, THE Borders SHALL clearly separate images

### Requirement 6: Update Python Script

**User Story:** As a developer, I want to update the figure generation script, so that it uses real images instead of placeholders.

#### Acceptance Criteria

1. WHEN THE script is updated, THE Script SHALL load images from `img/original/` and `img/masks/` directories
2. WHEN THE script processes images, THE Script SHALL calculate corroded percentage for all images
3. WHEN THE script selects images, THE Script SHALL choose representative examples from each class
4. WHEN THE script generates the figure, THE Script SHALL create a professional grid layout with real images
5. WHERE THE script encounters errors, THE Script SHALL provide clear error messages

### Requirement 7: Verify Figure Quality

**User Story:** As an author, I want to verify the figure quality, so that I can ensure it meets publication standards.

#### Acceptance Criteria

1. WHEN THE figure is generated, THE System SHALL verify that the PDF file was created successfully
2. WHEN THE figure is inspected, THE Figure SHALL show clear, high-quality images
3. WHEN THE labels are checked, THE Labels SHALL be accurate and match the calculated percentages
4. WHEN THE layout is reviewed, THE Layout SHALL be balanced and professional
5. WHERE THE figure has issues, THE System SHALL report specific problems

### Requirement 8: Recompile Article with New Figure

**User Story:** As an author, I want to recompile the article with the new figure, so that the PDF includes real corrosion examples.

#### Acceptance Criteria

1. WHEN THE new figure is generated, THE System SHALL replace the old placeholder figure
2. WHEN THE article is recompiled, THE Compilation SHALL include the new Figure 2
3. WHEN THE PDF is generated, THE PDF SHALL display the real images clearly
4. WHEN THE figure is referenced, THE Reference SHALL point to the correct figure
5. WHERE THE compilation succeeds, THE System SHALL confirm successful PDF generation
