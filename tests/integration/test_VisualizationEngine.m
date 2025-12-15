% test_VisualizationEngine.m
% Integration tests for VisualizationEngine class
%
% This script tests all visualization and export functionality including:
%   - Confusion matrix visualization
%   - Training curves visualization
%   - ROC curves visualization
%   - Inference time comparison
%   - LaTeX table generation
%   - Figure export functionality
%
% Requirements tested: 6.1, 6.2, 6.3, 6.4, 6.5, 9.1, 9.2, 9.3

function test_VisualizationEngine()
    fprintf('\n=== Testing VisualizationEngine ===\n\n');
    
    % Initialize error handler
    errorHandler = ErrorHandler.getInstance();
    errorHandler.setLogFile('test_visualization_engine.log');
    
    % Create test output directory
    testOutputDir = 'output/classification/test_visualization';
    if ~exist(testOutputDir, 'dir')
        mkdir(testOutputDir);
    end
    
    % Test counters
    totalTests = 0;
    passedTests = 0;
    
    % Test 1: Confusion Matrix Visualization
    fprintf('Test 1: Confusion Matrix Visualization...\n');
    totalTests = totalTests + 1;
    try
        % Create synthetic confusion matrix
        confMat = [45, 3, 2; 4, 38, 3; 2, 1, 42];
        classNames = {'Class 0 - None/Light', 'Class 1 - Moderate', 'Class 2 - Severe'};
        outputPath = fullfile(testOutputDir, 'test_confusion_matrix');
        
        % Plot confusion matrix
        figHandle = VisualizationEngine.plotConfusionMatrix(confMat, classNames, outputPath, 'TestModel');
        
        % Verify figure was created
        assert(isvalid(figHandle), 'Figure handle is invalid');
        
        % Verify files were created
        assert(exist([outputPath, '.png'], 'file') == 2, 'PNG file not created');
        assert(exist([outputPath, '.pdf'], 'file') == 2, 'PDF file not created');
        
        % Clean up
        close(figHandle);
        
        fprintf('  ✓ Confusion matrix visualization passed\n');
        passedTests = passedTests + 1;
    catch ME
        fprintf('  ✗ Confusion matrix visualization failed: %s\n', ME.message);
    end
    
    % Test 2: Training Curves Visualization
    fprintf('Test 2: Training Curves Visualization...\n');
    totalTests = totalTests + 1;
    try
        % Create synthetic training histories
        epochs = 1:20;
        history1 = struct(...
            'epoch', epochs, ...
            'trainLoss', 0.8 * exp(-epochs/10) + 0.1, ...
            'valLoss', 0.9 * exp(-epochs/10) + 0.15, ...
            'trainAccuracy', 1 - 0.7 * exp(-epochs/8), ...
            'valAccuracy', 1 - 0.75 * exp(-epochs/8));
        
        history2 = struct(...
            'epoch', epochs, ...
            'trainLoss', 0.7 * exp(-epochs/12) + 0.12, ...
            'valLoss', 0.85 * exp(-epochs/12) + 0.18, ...
            'trainAccuracy', 1 - 0.65 * exp(-epochs/9), ...
            'valAccuracy', 1 - 0.7 * exp(-epochs/9));
        
        histories = {history1, history2};
        modelNames = {'Model A', 'Model B'};
        outputPath = fullfile(testOutputDir, 'test_training_curves');
        
        % Plot training curves
        figHandle = VisualizationEngine.plotTrainingCurves(histories, modelNames, outputPath);
        
        % Verify figure was created
        assert(isvalid(figHandle), 'Figure handle is invalid');
        
        % Verify files were created
        assert(exist([outputPath, '.png'], 'file') == 2, 'PNG file not created');
        assert(exist([outputPath, '.pdf'], 'file') == 2, 'PDF file not created');
        
        % Clean up
        close(figHandle);
        
        fprintf('  ✓ Training curves visualization passed\n');
        passedTests = passedTests + 1;
    catch ME
        fprintf('  ✗ Training curves visualization failed: %s\n', ME.message);
    end
    
    % Test 3: ROC Curves Visualization
    fprintf('Test 3: ROC Curves Visualization...\n');
    totalTests = totalTests + 1;
    try
        % Create synthetic ROC data
        numPoints = 100;
        fpr1 = linspace(0, 1, numPoints)';
        tpr1 = sqrt(fpr1) + 0.1 * randn(numPoints, 1);
        tpr1 = max(0, min(1, tpr1));
        
        fpr2 = linspace(0, 1, numPoints)';
        tpr2 = fpr2.^0.7 + 0.1 * randn(numPoints, 1);
        tpr2 = max(0, min(1, tpr2));
        
        fpr3 = linspace(0, 1, numPoints)';
        tpr3 = fpr3.^0.6 + 0.1 * randn(numPoints, 1);
        tpr3 = max(0, min(1, tpr3));
        
        rocData = struct(...
            'fpr', {{fpr1, fpr2, fpr3}}, ...
            'tpr', {{tpr1, tpr2, tpr3}}, ...
            'auc', [0.92, 0.88, 0.90]);
        
        classNames = {'Class 0', 'Class 1', 'Class 2'};
        outputPath = fullfile(testOutputDir, 'test_roc_curves');
        
        % Plot ROC curves
        figHandle = VisualizationEngine.plotROCCurves(rocData, classNames, outputPath, 'TestModel');
        
        % Verify figure was created
        assert(isvalid(figHandle), 'Figure handle is invalid');
        
        % Verify files were created
        assert(exist([outputPath, '.png'], 'file') == 2, 'PNG file not created');
        assert(exist([outputPath, '.pdf'], 'file') == 2, 'PDF file not created');
        
        % Clean up
        close(figHandle);
        
        fprintf('  ✓ ROC curves visualization passed\n');
        passedTests = passedTests + 1;
    catch ME
        fprintf('  ✗ ROC curves visualization failed: %s\n', ME.message);
    end
    
    % Test 4: Inference Time Comparison
    fprintf('Test 4: Inference Time Comparison...\n');
    totalTests = totalTests + 1;
    try
        % Create synthetic inference times
        times = [25.3, 18.7, 42.1]; % milliseconds
        modelNames = {'Model A', 'Model B', 'Model C'};
        outputPath = fullfile(testOutputDir, 'test_inference_comparison');
        
        % Plot inference comparison
        figHandle = VisualizationEngine.plotInferenceComparison(times, modelNames, outputPath);
        
        % Verify figure was created
        assert(isvalid(figHandle), 'Figure handle is invalid');
        
        % Verify files were created
        assert(exist([outputPath, '.png'], 'file') == 2, 'PNG file not created');
        assert(exist([outputPath, '.pdf'], 'file') == 2, 'PDF file not created');
        
        % Clean up
        close(figHandle);
        
        fprintf('  ✓ Inference time comparison passed\n');
        passedTests = passedTests + 1;
    catch ME
        fprintf('  ✗ Inference time comparison failed: %s\n', ME.message);
    end
    
    % Test 5: LaTeX Metrics Table Generation
    fprintf('Test 5: LaTeX Metrics Table Generation...\n');
    totalTests = totalTests + 1;
    try
        % Create synthetic evaluation reports
        report1 = struct(...
            'metrics', struct('accuracy', 0.92, 'macroF1', 0.91, 'weightedF1', 0.92), ...
            'roc', struct('auc', [0.95, 0.90, 0.93]), ...
            'inferenceTime', 25.3, ...
            'throughput', 39.5);
        
        report2 = struct(...
            'metrics', struct('accuracy', 0.89, 'macroF1', 0.88, 'weightedF1', 0.89), ...
            'roc', struct('auc', [0.92, 0.87, 0.90]), ...
            'inferenceTime', 18.7, ...
            'throughput', 53.5);
        
        reports = {report1, report2};
        modelNames = {'Model A', 'Model B'};
        outputPath = fullfile(testOutputDir, 'test_metrics_table.tex');
        
        % Generate LaTeX table
        VisualizationEngine.generateLatexTable(reports, 'metrics', outputPath, modelNames);
        
        % Verify file was created
        assert(exist(outputPath, 'file') == 2, 'LaTeX file not created');
        
        % Verify file contains expected content
        content = fileread(outputPath);
        assert(contains(content, '\\begin{table}'), 'Missing table environment');
        assert(contains(content, '\\toprule'), 'Missing booktabs formatting');
        assert(contains(content, 'Model A'), 'Missing model name');
        
        fprintf('  ✓ LaTeX metrics table generation passed\n');
        passedTests = passedTests + 1;
    catch ME
        fprintf('  ✗ LaTeX metrics table generation failed: %s\n', ME.message);
    end
    
    % Test 6: LaTeX Confusion Matrix Table Generation
    fprintf('Test 6: LaTeX Confusion Matrix Table Generation...\n');
    totalTests = totalTests + 1;
    try
        % Create synthetic confusion matrix
        confMat = [45, 3, 2; 4, 38, 3; 2, 1, 42];
        classNames = {'Class 0', 'Class 1', 'Class 2'};
        outputPath = fullfile(testOutputDir, 'test_confusion_table.tex');
        
        % Generate LaTeX table
        VisualizationEngine.generateLatexTable(confMat, 'confusion', outputPath, classNames, 'TestModel');
        
        % Verify file was created
        assert(exist(outputPath, 'file') == 2, 'LaTeX file not created');
        
        % Verify file contains expected content
        content = fileread(outputPath);
        assert(contains(content, '\\begin{table}'), 'Missing table environment');
        assert(contains(content, 'Confusion Matrix'), 'Missing title');
        assert(contains(content, 'Class 0'), 'Missing class name');
        
        fprintf('  ✓ LaTeX confusion matrix table generation passed\n');
        passedTests = passedTests + 1;
    catch ME
        fprintf('  ✗ LaTeX confusion matrix table generation failed: %s\n', ME.message);
    end
    
    % Test 7: LaTeX Summary Document Generation
    fprintf('Test 7: LaTeX Summary Document Generation...\n');
    totalTests = totalTests + 1;
    try
        % Create synthetic evaluation reports
        report1 = struct(...
            'metrics', struct('accuracy', 0.92, 'macroF1', 0.91, 'weightedF1', 0.92), ...
            'roc', struct('auc', [0.95, 0.90, 0.93]), ...
            'inferenceTime', 25.3, ...
            'throughput', 39.5);
        
        report2 = struct(...
            'metrics', struct('accuracy', 0.89, 'macroF1', 0.88, 'weightedF1', 0.89), ...
            'roc', struct('auc', [0.92, 0.87, 0.90]), ...
            'inferenceTime', 18.7, ...
            'throughput', 53.5);
        
        reports = {report1, report2};
        modelNames = {'Model A', 'Model B'};
        classNames = {'Class 0', 'Class 1', 'Class 2'};
        outputPath = fullfile(testOutputDir, 'test_summary.tex');
        
        % Generate LaTeX summary
        VisualizationEngine.generateLatexTable(reports, 'summary', outputPath, modelNames, classNames);
        
        % Verify file was created
        assert(exist(outputPath, 'file') == 2, 'LaTeX file not created');
        
        % Verify file contains expected content
        content = fileread(outputPath);
        assert(contains(content, '\\section{Classification Results}'), 'Missing section header');
        assert(contains(content, '\\subsection{Overview}'), 'Missing subsection');
        assert(contains(content, 'Model A'), 'Missing model name');
        assert(contains(content, '\\begin{figure}'), 'Missing figure environment');
        
        fprintf('  ✓ LaTeX summary document generation passed\n');
        passedTests = passedTests + 1;
    catch ME
        fprintf('  ✗ LaTeX summary document generation failed: %s\n', ME.message);
    end
    
    % Test 8: Export All Figures
    fprintf('Test 8: Export All Figures...\n');
    totalTests = totalTests + 1;
    try
        % Create multiple test figures
        fig1 = figure('Visible', 'off');
        plot(1:10, rand(1, 10));
        title('Test Figure 1');
        
        fig2 = figure('Visible', 'off');
        bar(rand(1, 5));
        title('Test Figure 2');
        
        figHandles = {fig1, fig2};
        outputDir = fullfile(testOutputDir, 'batch_export');
        baseName = 'test_figure';
        
        % Export all figures
        VisualizationEngine.exportAllFigures(figHandles, outputDir, baseName);
        
        % Verify files were created
        assert(exist(fullfile(outputDir, 'test_figure_1.png'), 'file') == 2, 'Figure 1 PNG not created');
        assert(exist(fullfile(outputDir, 'test_figure_1.pdf'), 'file') == 2, 'Figure 1 PDF not created');
        assert(exist(fullfile(outputDir, 'test_figure_2.png'), 'file') == 2, 'Figure 2 PNG not created');
        assert(exist(fullfile(outputDir, 'test_figure_2.pdf'), 'file') == 2, 'Figure 2 PDF not created');
        
        % Clean up
        close(fig1);
        close(fig2);
        
        fprintf('  ✓ Export all figures passed\n');
        passedTests = passedTests + 1;
    catch ME
        fprintf('  ✗ Export all figures failed: %s\n', ME.message);
    end
    
    % Test 9: Figure Format Validation
    fprintf('Test 9: Figure Format Validation...\n');
    totalTests = totalTests + 1;
    try
        % Create a test figure
        confMat = [10, 2; 1, 15];
        classNames = {'Class A', 'Class B'};
        outputPath = fullfile(testOutputDir, 'test_format_validation');
        
        figHandle = VisualizationEngine.plotConfusionMatrix(confMat, classNames, outputPath, 'FormatTest');
        
        % Verify PNG properties
        pngPath = [outputPath, '.png'];
        pngInfo = imfinfo(pngPath);
        
        % Check resolution (should be 300 DPI)
        % Note: MATLAB may store DPI differently, so we check if it's reasonable
        assert(pngInfo.Width > 1000, 'PNG width too small for 300 DPI');
        assert(pngInfo.Height > 600, 'PNG height too small for 300 DPI');
        
        % Verify PDF exists and is not empty
        pdfPath = [outputPath, '.pdf'];
        pdfInfo = dir(pdfPath);
        assert(pdfInfo.bytes > 1000, 'PDF file too small');
        
        % Clean up
        close(figHandle);
        
        fprintf('  ✓ Figure format validation passed\n');
        passedTests = passedTests + 1;
    catch ME
        fprintf('  ✗ Figure format validation failed: %s\n', ME.message);
    end
    
    % Test 10: Error Handling
    fprintf('Test 10: Error Handling...\n');
    totalTests = totalTests + 1;
    try
        % Test with invalid input
        errorCaught = false;
        try
            % Empty confusion matrix should cause error
            VisualizationEngine.plotConfusionMatrix([], {}, '', 'ErrorTest');
        catch
            errorCaught = true;
        end
        
        assert(errorCaught, 'Error not caught for invalid input');
        
        fprintf('  ✓ Error handling passed\n');
        passedTests = passedTests + 1;
    catch ME
        fprintf('  ✗ Error handling failed: %s\n', ME.message);
    end
    
    % Print summary
    fprintf('\n=== Test Summary ===\n');
    fprintf('Total tests: %d\n', totalTests);
    fprintf('Passed: %d\n', passedTests);
    fprintf('Failed: %d\n', totalTests - passedTests);
    fprintf('Success rate: %.1f%%\n', (passedTests / totalTests) * 100);
    
    if passedTests == totalTests
        fprintf('\n✓ All VisualizationEngine tests passed!\n');
    else
        fprintf('\n✗ Some tests failed. Check log file for details.\n');
    end
    
    fprintf('\nTest output saved to: %s\n', testOutputDir);
end
