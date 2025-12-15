% test_DatasetManager.m - Unit tests for DatasetManager class
%
% This script tests the DatasetManager class functionality including:
% - Constructor and data loading
% - Stratified dataset splitting
% - Dataset statistics computation
% - Data augmentation configuration
%
% Requirements tested: 2.1, 2.2, 2.3, 2.4, 7.3

function test_DatasetManager()
    fprintf('=== Testing DatasetManager Class ===\n\n');
    
    % Initialize error handler
    errorHandler = ErrorHandler.getInstance();
    errorHandler.setLogLevel(ErrorHandler.LOG_LEVEL_INFO);
    
    % Track test results
    testsPassed = 0;
    testsFailed = 0;
    
    % Test 1: Constructor with valid inputs
    fprintf('Test 1: Constructor with valid inputs...\n');
    try
        % Use existing labels from previous task
        imageDir = 'img/original';
        labelCSV = 'output/classification/labels.csv';
        
        % Check if files exist
        if ~exist(imageDir, 'dir')
            fprintf('  SKIP: Image directory not found: %s\n', imageDir);
        elseif ~exist(labelCSV, 'file')
            fprintf('  SKIP: Label CSV not found: %s\n', labelCSV);
        else
            config = struct();
            config.splitRatios = [0.7, 0.15, 0.15];
            config.errorHandler = errorHandler;
            
            manager = DatasetManager(imageDir, labelCSV, config);
            
            if ~isempty(manager)
                fprintf('  PASS: DatasetManager created successfully\n');
                testsPassed = testsPassed + 1;
            else
                fprintf('  FAIL: DatasetManager is empty\n');
                testsFailed = testsFailed + 1;
            end
        end
    catch ME
        fprintf('  FAIL: %s\n', ME.message);
        testsFailed = testsFailed + 1;
    end
    fprintf('\n');
    
    % Test 2: Constructor with invalid directory
    fprintf('Test 2: Constructor with invalid directory...\n');
    try
        invalidDir = 'nonexistent/directory';
        labelCSV = 'output/classification/labels.csv';
        
        manager = DatasetManager(invalidDir, labelCSV); %#ok<NASGU>
        fprintf('  FAIL: Should have thrown error for invalid directory\n');
        testsFailed = testsFailed + 1;
    catch ME
        if contains(ME.identifier, 'DirectoryNotFound')
            fprintf('  PASS: Correctly threw error for invalid directory\n');
            testsPassed = testsPassed + 1;
        else
            fprintf('  FAIL: Wrong error type: %s\n', ME.identifier);
            testsFailed = testsFailed + 1;
        end
    end
    fprintf('\n');
    
    % Test 3: Constructor with invalid CSV
    fprintf('Test 3: Constructor with invalid CSV file...\n');
    try
        imageDir = 'img/original';
        invalidCSV = 'nonexistent.csv';
        
        if ~exist(imageDir, 'dir')
            fprintf('  SKIP: Image directory not found\n');
        else
            manager = DatasetManager(imageDir, invalidCSV); %#ok<NASGU>
            fprintf('  FAIL: Should have thrown error for invalid CSV\n');
            testsFailed = testsFailed + 1;
        end
    catch ME
        if contains(ME.identifier, 'FileNotFound')
            fprintf('  PASS: Correctly threw error for invalid CSV\n');
            testsPassed = testsPassed + 1;
        else
            fprintf('  FAIL: Wrong error type: %s\n', ME.identifier);
            testsFailed = testsFailed + 1;
        end
    end
    fprintf('\n');
    
    % Test 4: Stratified dataset splitting
    fprintf('Test 4: Stratified dataset splitting...\n');
    try
        imageDir = 'img/original';
        labelCSV = 'output/classification/labels.csv';
        
        if ~exist(imageDir, 'dir') || ~exist(labelCSV, 'file')
            fprintf('  SKIP: Required files not found\n');
        else
            config = struct();
            config.splitRatios = [0.7, 0.15, 0.15];
            config.errorHandler = errorHandler;
            
            manager = DatasetManager(imageDir, labelCSV, config);
            
            % Prepare datasets
            inputSize = [224, 224];
            [trainDS, valDS, testDS] = manager.prepareDatasets(inputSize);
            
            % Verify datastores are created
            if ~isempty(trainDS) && ~isempty(valDS) && ~isempty(testDS)
                fprintf('  PASS: All three datastores created\n');
                
                % Check that they have labels
                if isprop(trainDS, 'Labels') && isprop(valDS, 'Labels') && isprop(testDS, 'Labels')
                    fprintf('  PASS: All datastores have labels\n');
                    testsPassed = testsPassed + 1;
                else
                    fprintf('  FAIL: Some datastores missing labels\n');
                    testsFailed = testsFailed + 1;
                end
            else
                fprintf('  FAIL: Some datastores are empty\n');
                testsFailed = testsFailed + 1;
            end
        end
    catch ME
        fprintf('  FAIL: %s\n', ME.message);
        testsFailed = testsFailed + 1;
    end
    fprintf('\n');
    
    % Test 5: Dataset statistics computation
    fprintf('Test 5: Dataset statistics computation...\n');
    try
        imageDir = 'img/original';
        labelCSV = 'output/classification/labels.csv';
        
        if ~exist(imageDir, 'dir') || ~exist(labelCSV, 'file')
            fprintf('  SKIP: Required files not found\n');
        else
            config = struct();
            config.errorHandler = errorHandler;
            
            manager = DatasetManager(imageDir, labelCSV, config);
            
            % Get statistics
            stats = manager.getDatasetStatistics();
            
            % Verify statistics structure
            requiredFields = {'totalSamples', 'uniqueClasses', 'numClasses', ...
                'classDistribution', 'classPercentages', 'percentageRange', ...
                'percentageMean', 'percentageStd', 'imbalanceRatio'};
            
            hasAllFields = true;
            for i = 1:length(requiredFields)
                if ~isfield(stats, requiredFields{i})
                    fprintf('  FAIL: Missing field: %s\n', requiredFields{i});
                    hasAllFields = false;
                end
            end
            
            if hasAllFields
                fprintf('  PASS: Statistics structure has all required fields\n');
                fprintf('  INFO: Total samples: %d\n', stats.totalSamples);
                fprintf('  INFO: Number of classes: %d\n', stats.numClasses);
                fprintf('  INFO: Imbalance ratio: %.2f:1\n', stats.imbalanceRatio);
                testsPassed = testsPassed + 1;
            else
                testsFailed = testsFailed + 1;
            end
        end
    catch ME
        fprintf('  FAIL: %s\n', ME.message);
        testsFailed = testsFailed + 1;
    end
    fprintf('\n');
    
    % Test 6: Data augmentation configuration
    fprintf('Test 6: Data augmentation configuration...\n');
    try
        imageDir = 'img/original';
        labelCSV = 'output/classification/labels.csv';
        
        if ~exist(imageDir, 'dir') || ~exist(labelCSV, 'file')
            fprintf('  SKIP: Required files not found\n');
        else
            % Create manager with augmentation enabled
            config = struct();
            config.augmentation = struct(...
                'enabled', true, ...
                'horizontalFlip', true, ...
                'verticalFlip', true, ...
                'rotationRange', [-15, 15], ...
                'brightnessRange', [0.8, 1.2], ...
                'contrastRange', [0.8, 1.2]);
            config.errorHandler = errorHandler;
            
            manager = DatasetManager(imageDir, labelCSV, config);
            
            % Create a simple datastore
            [trainDS, ~, ~] = manager.prepareDatasets([224, 224]);
            
            % Apply augmentation
            augDS = manager.applyAugmentation(trainDS);
            
            if ~isempty(augDS)
                fprintf('  PASS: Augmented datastore created\n');
                testsPassed = testsPassed + 1;
            else
                fprintf('  FAIL: Augmented datastore is empty\n');
                testsFailed = testsFailed + 1;
            end
        end
    catch ME
        fprintf('  FAIL: %s\n', ME.message);
        testsFailed = testsFailed + 1;
    end
    fprintf('\n');
    
    % Test 7: Augmentation disabled
    fprintf('Test 7: Augmentation disabled...\n');
    try
        imageDir = 'img/original';
        labelCSV = 'output/classification/labels.csv';
        
        if ~exist(imageDir, 'dir') || ~exist(labelCSV, 'file')
            fprintf('  SKIP: Required files not found\n');
        else
            % Create manager with augmentation disabled
            config = struct();
            config.augmentation = struct('enabled', false);
            config.errorHandler = errorHandler;
            
            manager = DatasetManager(imageDir, labelCSV, config);
            
            % Create a simple datastore
            [trainDS, ~, ~] = manager.prepareDatasets([224, 224]);
            
            % Apply augmentation (should return original)
            augDS = manager.applyAugmentation(trainDS);
            
            % Check if it's the same object (no augmentation applied)
            if isequal(augDS, trainDS)
                fprintf('  PASS: Returned original datastore when augmentation disabled\n');
                testsPassed = testsPassed + 1;
            else
                fprintf('  FAIL: Should return original datastore when disabled\n');
                testsFailed = testsFailed + 1;
            end
        end
    catch ME
        fprintf('  FAIL: %s\n', ME.message);
        testsFailed = testsFailed + 1;
    end
    fprintf('\n');
    
    % Test 8: Invalid split ratios
    fprintf('Test 8: Invalid split ratios...\n');
    try
        imageDir = 'img/original';
        labelCSV = 'output/classification/labels.csv';
        
        if ~exist(imageDir, 'dir') || ~exist(labelCSV, 'file')
            fprintf('  SKIP: Required files not found\n');
        else
            config = struct();
            config.splitRatios = [0.5, 0.3, 0.1]; % Sum is 0.9, not 1.0
            
            manager = DatasetManager(imageDir, labelCSV, config); %#ok<NASGU>
            fprintf('  FAIL: Should have thrown error for invalid split ratios\n');
            testsFailed = testsFailed + 1;
        end
    catch ME
        if contains(ME.identifier, 'InvalidSplitRatios')
            fprintf('  PASS: Correctly threw error for invalid split ratios\n');
            testsPassed = testsPassed + 1;
        else
            fprintf('  FAIL: Wrong error type: %s\n', ME.identifier);
            testsFailed = testsFailed + 1;
        end
    end
    fprintf('\n');
    
    % Test 9: Brightness and contrast augmentation
    fprintf('Test 9: Brightness and contrast augmentation...\n');
    try
        imageDir = 'img/original';
        labelCSV = 'output/classification/labels.csv';
        
        if ~exist(imageDir, 'dir') || ~exist(labelCSV, 'file')
            fprintf('  SKIP: Required files not found\n');
        else
            % Create manager with full augmentation
            config = struct();
            config.augmentation = struct(...
                'enabled', true, ...
                'horizontalFlip', true, ...
                'verticalFlip', true, ...
                'rotationRange', [-15, 15], ...
                'brightnessRange', [0.8, 1.2], ...
                'contrastRange', [0.8, 1.2]);
            config.errorHandler = errorHandler;
            
            manager = DatasetManager(imageDir, labelCSV, config);
            
            % Create datastore
            [trainDS, ~, ~] = manager.prepareDatasets([224, 224]);
            
            % Apply augmentation
            augDS = manager.applyAugmentation(trainDS, [224, 224]);
            
            % Try to read one sample to verify augmentation works
            if hasdata(augDS)
                data = read(augDS);
                img = data{1};
                label = data{2};
                
                % Verify image is valid
                if ~isempty(img) && ~isempty(label)
                    fprintf('  PASS: Successfully read augmented image\n');
                    fprintf('  INFO: Image size: %dx%dx%d\n', size(img, 1), size(img, 2), size(img, 3));
                    fprintf('  INFO: Image class: %s\n', class(img));
                    fprintf('  INFO: Label: %s\n', char(label));
                    testsPassed = testsPassed + 1;
                else
                    fprintf('  FAIL: Augmented image or label is empty\n');
                    testsFailed = testsFailed + 1;
                end
            else
                fprintf('  FAIL: Augmented datastore has no data\n');
                testsFailed = testsFailed + 1;
            end
        end
    catch ME
        fprintf('  FAIL: %s\n', ME.message);
        fprintf('  Stack: %s\n', ME.getReport());
        testsFailed = testsFailed + 1;
    end
    fprintf('\n');
    
    % Test 10: DatasetValidator - validate dataset
    fprintf('Test 10: DatasetValidator - validate dataset...\n');
    try
        imageDir = 'img/original';
        labelCSV = 'output/classification/labels.csv';
        
        if ~exist(imageDir, 'dir') || ~exist(labelCSV, 'file')
            fprintf('  SKIP: Required files not found\n');
        else
            validator = DatasetValidator(errorHandler);
            [isValid, report] = validator.validateDataset(imageDir, labelCSV);
            
            % Verify report structure
            requiredFields = {'totalLabels', 'validImages', 'missingFiles', ...
                'unreadableFiles', 'invalidDimensions', 'invalidChannels', ...
                'classDistribution', 'imbalanceRatio'};
            
            hasAllFields = true;
            for i = 1:length(requiredFields)
                if ~isfield(report, requiredFields{i})
                    fprintf('  FAIL: Missing field: %s\n', requiredFields{i});
                    hasAllFields = false;
                end
            end
            
            if hasAllFields && ~isempty(report)
                fprintf('  PASS: Dataset validation completed with valid report\n');
                fprintf('  INFO: Valid images: %d/%d\n', report.validImages, report.totalLabels);
                fprintf('  INFO: Imbalance ratio: %.2f:1\n', report.imbalanceRatio);
                testsPassed = testsPassed + 1;
            else
                fprintf('  FAIL: Report structure incomplete\n');
                testsFailed = testsFailed + 1;
            end
        end
    catch ME
        fprintf('  FAIL: %s\n', ME.message);
        testsFailed = testsFailed + 1;
    end
    fprintf('\n');
    
    % Test 11: DatasetValidator - invalid directory
    fprintf('Test 11: DatasetValidator - invalid directory...\n');
    try
        validator = DatasetValidator(errorHandler);
        [isValid, report] = validator.validateDataset('nonexistent/dir', 'dummy.csv');
        
        if ~isValid && ~isempty(report.errors)
            fprintf('  PASS: Correctly detected invalid directory\n');
            testsPassed = testsPassed + 1;
        else
            fprintf('  FAIL: Should have detected invalid directory\n');
            testsFailed = testsFailed + 1;
        end
    catch ME
        fprintf('  FAIL: %s\n', ME.message);
        testsFailed = testsFailed + 1;
    end
    fprintf('\n');
    
    % Test 12: DatasetValidator - generate report
    fprintf('Test 12: DatasetValidator - generate report...\n');
    try
        imageDir = 'img/original';
        labelCSV = 'output/classification/labels.csv';
        
        if ~exist(imageDir, 'dir') || ~exist(labelCSV, 'file')
            fprintf('  SKIP: Required files not found\n');
        else
            validator = DatasetValidator(errorHandler);
            [isValid, report] = validator.validateDataset(imageDir, labelCSV);
            
            % Generate report to file
            outputDir = 'output/classification/test';
            if ~exist(outputDir, 'dir')
                mkdir(outputDir);
            end
            
            reportFile = fullfile(outputDir, 'test_validation_report.txt');
            validator.generateReport(report, reportFile);
            
            if exist(reportFile, 'file')
                fprintf('  PASS: Report file generated successfully\n');
                testsPassed = testsPassed + 1;
                
                % Clean up
                delete(reportFile);
            else
                fprintf('  FAIL: Report file not created\n');
                testsFailed = testsFailed + 1;
            end
        end
    catch ME
        fprintf('  FAIL: %s\n', ME.message);
        testsFailed = testsFailed + 1;
    end
    fprintf('\n');
    
    % Print summary
    fprintf('=== Test Summary ===\n');
    fprintf('Tests passed: %d\n', testsPassed);
    fprintf('Tests failed: %d\n', testsFailed);
    fprintf('Total tests: %d\n', testsPassed + testsFailed);
    
    if testsFailed == 0
        fprintf('\nAll tests PASSED!\n');
    else
        fprintf('\nSome tests FAILED. Please review the output above.\n');
    end
end
