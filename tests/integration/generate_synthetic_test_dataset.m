function generate_synthetic_test_dataset()
% GENERATE_SYNTHETIC_TEST_DATASET Creates synthetic images and masks for testing
%
% This function generates 30 synthetic images (10 per class) with corresponding
% binary masks that have controlled corroded percentages for testing the
% classification pipeline.
%
% Output Structure:
%   tests/integration/synthetic_data/
%       images/
%           class0_001.jpg ... class0_010.jpg (0-9% corroded)
%           class1_001.jpg ... class1_010.jpg (10-29% corroded)
%           class2_001.jpg ... class2_010.jpg (30%+ corroded)
%       masks/
%           class0_001.jpg ... class0_010.jpg
%           class1_001.jpg ... class1_010.jpg
%           class2_001.jpg ... class2_010.jpg

    fprintf('=== Synthetic Test Dataset Generator ===\n\n');
    
    % Configuration
    imageSize = [224, 224, 3];
    numImagesPerClass = 10;
    outputDir = fullfile('tests', 'integration', 'synthetic_data');
    imageDir = fullfile(outputDir, 'images');
    maskDir = fullfile(outputDir, 'masks');
    
    % Create directories
    if ~exist(imageDir, 'dir')
        mkdir(imageDir);
    end
    if ~exist(maskDir, 'dir')
        mkdir(maskDir);
    end
    
    % Define corroded percentage ranges for each class
    % Class 0: None/Light (0-9%)
    % Class 1: Moderate (10-29%)
    % Class 2: Severe (30%+)
    classRanges = struct(...
        'class0', [0.5, 9.5], ...    % 0.5% to 9.5%
        'class1', [10.5, 29.5], ...  % 10.5% to 29.5%
        'class2', [30.5, 70.0] ...   % 30.5% to 70%
    );
    
    % Generate images for each class
    classes = {'class0', 'class1', 'class2'};
    totalImages = 0;
    
    for c = 1:length(classes)
        className = classes{c};
        range = classRanges.(className);
        
        fprintf('Generating %d images for %s (%.1f%% - %.1f%% corroded)...\n', ...
            numImagesPerClass, className, range(1), range(2));
        
        for i = 1:numImagesPerClass
            % Generate unique filename
            filename = sprintf('%s_%03d.jpg', className, i);
            imagePath = fullfile(imageDir, filename);
            maskPath = fullfile(maskDir, filename);
            
            % Calculate target corroded percentage for this image
            targetPercentage = range(1) + (range(2) - range(1)) * (i-1) / (numImagesPerClass-1);
            
            % Generate synthetic image and mask
            [img, mask] = generateSyntheticImagePair(imageSize, targetPercentage);
            
            % Verify actual percentage
            actualPercentage = (sum(mask(:) > 0) / numel(mask)) * 100;
            
            % Save image and mask
            imwrite(img, imagePath, 'Quality', 95);
            imwrite(mask, maskPath, 'Quality', 95);
            
            totalImages = totalImages + 1;
            
            if mod(i, 5) == 0
                fprintf('  Generated %d/%d images (last: %.2f%% corroded)\n', ...
                    i, numImagesPerClass, actualPercentage);
            end
        end
        fprintf('  Completed %s\n\n', className);
    end
    
    % Validate dataset integrity
    fprintf('Validating dataset integrity...\n');
    [isValid, stats] = validateSyntheticDataset(imageDir, maskDir);
    
    if isValid
        fprintf('\n✓ Dataset validation PASSED\n');
        fprintf('  Total images: %d\n', stats.totalImages);
        fprintf('  Total masks: %d\n', stats.totalMasks);
        fprintf('  Class 0 (None/Light): %d images\n', stats.class0Count);
        fprintf('  Class 1 (Moderate): %d images\n', stats.class1Count);
        fprintf('  Class 2 (Severe): %d images\n', stats.class2Count);
        fprintf('  Average corroded %% by class:\n');
        fprintf('    Class 0: %.2f%%\n', stats.avgCorrodedClass0);
        fprintf('    Class 1: %.2f%%\n', stats.avgCorrodedClass1);
        fprintf('    Class 2: %.2f%%\n', stats.avgCorrodedClass2);
        fprintf('\nSynthetic dataset created successfully at:\n  %s\n', outputDir);
    else
        error('Dataset validation FAILED. Check the output directory.');
    end
end

function [img, mask] = generateSyntheticImagePair(imageSize, targetPercentage)
% Generate a synthetic steel texture image and corresponding corrosion mask
    
    % Create base steel texture (grayscale with noise)
    baseTexture = 0.4 + 0.2 * rand(imageSize(1), imageSize(2));
    
    % Add some structure (simulated grain patterns)
    [X, Y] = meshgrid(1:imageSize(2), 1:imageSize(1));
    grainPattern = 0.05 * sin(X/10) .* cos(Y/15);
    baseTexture = baseTexture + grainPattern;
    
    % Add noise
    baseTexture = baseTexture + 0.05 * randn(imageSize(1), imageSize(2));
    baseTexture = max(0, min(1, baseTexture));
    
    % Convert to RGB (steel gray color)
    img = cat(3, baseTexture * 0.6, baseTexture * 0.6, baseTexture * 0.65);
    
    % Generate corrosion mask with target percentage
    mask = generateCorrosionMask(imageSize(1:2), targetPercentage);
    
    % Apply corrosion effect to image (rust color)
    rustColor = [0.7, 0.3, 0.1]; % Rust orange-brown
    for c = 1:3
        imgChannel = img(:,:,c);
        imgChannel(mask > 0) = rustColor(c) * 0.8 + 0.2 * imgChannel(mask > 0);
        img(:,:,c) = imgChannel;
    end
    
    % Add some texture variation to corroded areas
    corrodedRegion = mask > 0;
    if any(corrodedRegion(:))
        textureNoise = 0.1 * randn(imageSize(1), imageSize(2));
        for c = 1:3
            imgChannel = img(:,:,c);
            imgChannel(corrodedRegion) = imgChannel(corrodedRegion) + textureNoise(corrodedRegion);
            imgChannel = max(0, min(1, imgChannel));
            img(:,:,c) = imgChannel;
        end
    end
    
    % Convert to uint8
    img = uint8(img * 255);
    mask = uint8(mask);
end

function mask = generateCorrosionMask(maskSize, targetPercentage)
% Generate a binary mask with approximately targetPercentage of pixels set to 255
    
    % Calculate number of pixels to set
    totalPixels = maskSize(1) * maskSize(2);
    targetPixels = round(totalPixels * targetPercentage / 100);
    
    % Initialize mask
    mask = zeros(maskSize);
    
    if targetPixels == 0
        return;
    end
    
    % Generate random corrosion blobs
    numBlobs = max(1, round(targetPixels / 500)); % Roughly 500 pixels per blob
    
    for b = 1:numBlobs
        % Random blob center
        centerX = randi([1, maskSize(2)]);
        centerY = randi([1, maskSize(1)]);
        
        % Random blob size
        blobRadius = 10 + randi([5, 30]);
        
        % Create blob
        [X, Y] = meshgrid(1:maskSize(2), 1:maskSize(1));
        distances = sqrt((X - centerX).^2 + (Y - centerY).^2);
        blob = distances < blobRadius;
        
        % Add irregular edges
        blob = blob & (rand(maskSize) > 0.3);
        
        % Add to mask
        mask = mask | blob;
    end
    
    % Adjust to match target percentage
    currentPixels = sum(mask(:));
    
    if currentPixels < targetPixels
        % Add more pixels randomly
        availablePixels = find(mask == 0);
        numToAdd = min(targetPixels - currentPixels, length(availablePixels));
        if numToAdd > 0
            addIndices = availablePixels(randperm(length(availablePixels), numToAdd));
            mask(addIndices) = 1;
        end
    elseif currentPixels > targetPixels
        % Remove pixels randomly
        corrodedPixels = find(mask > 0);
        numToRemove = min(currentPixels - targetPixels, length(corrodedPixels));
        if numToRemove > 0
            removeIndices = corrodedPixels(randperm(length(corrodedPixels), numToRemove));
            mask(removeIndices) = 0;
        end
    end
    
    % Convert to uint8 (0 or 255)
    mask = uint8(mask * 255);
end

function [isValid, stats] = validateSyntheticDataset(imageDir, maskDir)
% Validate the generated synthetic dataset
    
    isValid = true;
    stats = struct();
    
    % Get all image files
    imageFiles = dir(fullfile(imageDir, '*.jpg'));
    maskFiles = dir(fullfile(maskDir, '*.jpg'));
    
    stats.totalImages = length(imageFiles);
    stats.totalMasks = length(maskFiles);
    
    % Check counts match
    if stats.totalImages ~= stats.totalMasks
        fprintf('ERROR: Image count (%d) does not match mask count (%d)\n', ...
            stats.totalImages, stats.totalMasks);
        isValid = false;
        return;
    end
    
    % Count by class and compute average corroded percentages
    class0Percentages = [];
    class1Percentages = [];
    class2Percentages = [];
    
    for i = 1:length(imageFiles)
        imageName = imageFiles(i).name;
        maskName = maskFiles(i).name;
        
        % Check names match
        if ~strcmp(imageName, maskName)
            fprintf('ERROR: Image/mask name mismatch: %s vs %s\n', imageName, maskName);
            isValid = false;
            continue;
        end
        
        % Load and validate image
        imgPath = fullfile(imageDir, imageName);
        img = imread(imgPath);
        if size(img, 3) ~= 3
            fprintf('ERROR: Image %s is not RGB\n', imageName);
            isValid = false;
        end
        
        % Load and validate mask
        maskPath = fullfile(maskDir, maskName);
        mask = imread(maskPath);
        if size(mask, 3) ~= 1
            mask = rgb2gray(mask);
        end
        
        % Check mask is binary
        uniqueVals = unique(mask(:));
        if ~all(ismember(uniqueVals, [0, 255]))
            fprintf('WARNING: Mask %s has non-binary values\n', maskName);
        end
        
        % Calculate corroded percentage
        corrodedPercentage = (sum(mask(:) > 0) / numel(mask)) * 100;
        
        % Categorize by class
        if startsWith(imageName, 'class0')
            class0Percentages(end+1) = corrodedPercentage;
        elseif startsWith(imageName, 'class1')
            class1Percentages(end+1) = corrodedPercentage;
        elseif startsWith(imageName, 'class2')
            class2Percentages(end+1) = corrodedPercentage;
        end
    end
    
    stats.class0Count = length(class0Percentages);
    stats.class1Count = length(class1Percentages);
    stats.class2Count = length(class2Percentages);
    
    stats.avgCorrodedClass0 = mean(class0Percentages);
    stats.avgCorrodedClass1 = mean(class1Percentages);
    stats.avgCorrodedClass2 = mean(class2Percentages);
    
    % Validate class distributions
    if stats.avgCorrodedClass0 >= 10
        fprintf('WARNING: Class 0 average (%.2f%%) should be < 10%%\n', stats.avgCorrodedClass0);
    end
    if stats.avgCorrodedClass1 < 10 || stats.avgCorrodedClass1 >= 30
        fprintf('WARNING: Class 1 average (%.2f%%) should be 10-30%%\n', stats.avgCorrodedClass1);
    end
    if stats.avgCorrodedClass2 < 30
        fprintf('WARNING: Class 2 average (%.2f%%) should be >= 30%%\n', stats.avgCorrodedClass2);
    end
end
