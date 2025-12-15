% validate_visualization_engine.m
% Validation script for VisualizationEngine
%
% This script validates the VisualizationEngine implementation by:
%   1. Running integration tests
%   2. Generating sample visualizations
%   3. Validating output files
%   4. Checking LaTeX table generation
%
% Requirements validated: 6.1, 6.2, 6.3, 6.4, 6.5, 9.1, 9.2, 9.3

function validate_visualization_engine()
    fprintf('\n========================================\n');
    fprintf('VisualizationEngine Validation\n');
    fprintf('========================================\n\n');
    
    % Initialize error handler
    errorHandler = ErrorHandler.getInstance();
    errorHandler.setLogFile('validation_visualization_engine.log');
    
    try
        % Step 1: Run integration tests
        fprintf('Step 1: Running integration tests...\n');
        test_VisualizationEngine();
        fprintf('✓ Integration tests completed\n\n');
        
        % Step 2: Validate class structure
        fprintf('Step 2: Validating class structure...\n');
        validateClassStructure();
        fprintf('✓ Class structure validated\n\n');
        
        % Step 3: Test with realistic data
        fprintf('Step 3: Testing with realistic data...\n');
        testRealisticScenario();
        fprintf('✓ Realistic scenario tested\n\n');
        
        % Step 4: Validate output quality
        fprintf('Step 4: Validating output quality...\n');
        validateOutputQuality();
        fprintf('✓ Output quality validated\n\n');
        
        fprintf('========================================\n');
        fprintf('✓ VisualizationEngine validation PASSED\n');
        fprintf('========================================\n\n');
        
        fprintf('All visualization and export functionality is working correctly.\n');
        fprintf('The system can generate publication-quality figures and LaTeX tables.\n\n');
        
    catch ME
        fprintf('\n✗ Validation FAILED: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

function validateClassStructure()
    % Validate that VisualizationEngine has all required methods
    
    methods = {'plotConfusionMatrix', 'plotTrainingCurves', 'plotROCCurves', ...
               'plotInferenceComparison', 'generateLatexTable', 'exportAllFigures'};
    
    for i = 1:length(methods)
        methodName = methods{i};
        assert(ismethod('VisualizationEngine', methodName), ...
            sprintf('Missing method: %s', methodName));
        fprintf('  ✓ Method exists: %s\n', methodName);
    end
    
    % Check constants
    assert(isprop('VisualizationEngine', 'FIGURE_DPI'), 'Missing constant: FIGURE_DPI');
    assert(isprop('VisualizationEngine', 'REALTIME_THRESHOLD'), 'Missing constant: REALTIME_THRESHOLD');
    fprintf('  ✓ Constants defined\n');
end

function testRealisticScenario()
    % Test with realistic evaluation data
    
    outputDir = 'output/classification/validation_visualization';
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    % Create realistic confusion matrix (3 classes)
    confMat = [
        85, 10, 5;
        8, 82, 10;
        3, 7, 90
    ];
    classNames = {'Class 0 - None/Light', 'Class 1 - Moderate', 'Class 2 - Severe'};
    
    % Test confusion matrix
    fprintf('  Testing confusion matrix visualization...\n');
    figHandle = VisualizationEngine.plotConfusionMatrix(...
        confMat, classNames, fullfile(outputDir, 'realistic_confusion'), 'ResNet50');
    assert(isvalid(figHandle), 'Invalid figure handle');
    close(figHandle);
    fprintf('    ✓ Confusion matrix generated\n');
    
    % Create realistic training history
    epochs = 1:30;
    history = struct(...
        'epoch', epochs, ...
        'trainLoss', 1.2 * exp(-epochs/8) + 0.05 + 0.02 * randn(size(epochs)), ...
        'valLoss', 1.3 * exp(-epochs/8) + 0.08 + 0.03 * randn(size(epochs)), ...
        'trainAccuracy', 1 - 0.8 * exp(-epochs/7) + 0.01 * randn(size(epochs)), ...
        'valAccuracy', 1 - 0.85 * exp(-epochs/7) + 0.02 * randn(size(epochs)));
    
    % Test training curves
    fprintf('  Testing training curves visualization...\n');
    figHandle = VisualizationEngine.plotTrainingCurves(...
        {history}, {'ResNet50'}, fullfile(outputDir, 'realistic_training'));
    assert(isvalid(figHandle), 'Invalid figure handle');
    close(figHandle);
    fprintf('    ✓ Training curves generated\n');
    
    % Create realistic ROC data
    numPoints = 100;
    rocData = struct();
    rocData.fpr = cell(3, 1);
    rocData.tpr = cell(3, 1);
    rocData.auc = zeros(3, 1);
    
    for i = 1:3
        fpr = linspace(0, 1, numPoints)';
        tpr = fpr.^(0.5 + 0.1 * i) + 0.05 * randn(numPoints, 1);
        tpr = max(0, min(1, tpr));
        tpr = sort(tpr); % Ensure monotonic
        
        rocData.fpr{i} = fpr;
        rocData.tpr{i} = tpr;
        rocData.auc(i) = trapz(fpr, tpr);
    end
    
    % Test ROC curves
    fprintf('  Testing ROC curves visualization...\n');
    figHandle = VisualizationEngine.plotROCCurves(...
        rocData, classNames, fullfile(outputDir, 'realistic_roc'), 'ResNet50');
    assert(isvalid(figHandle), 'Invalid figure handle');
    close(figHandle);
    fprintf('    ✓ ROC curves generated\n');
    
    % Test inference comparison
    fprintf('  Testing inference comparison visualization...\n');
    times = [28.5, 19.2, 45.7];
    modelNames = {'ResNet50', 'EfficientNet-B0', 'Custom CNN'};
    figHandle = VisualizationEngine.plotInferenceComparison(...
        times, modelNames, fullfile(outputDir, 'realistic_inference'));
    assert(isvalid(figHandle), 'Invalid figure handle');
    close(figHandle);
    fprintf('    ✓ Inference comparison generated\n');
    
    % Test LaTeX table generation
    fprintf('  Testing LaTeX table generation...\n');
    
    % Create realistic reports
    report1 = struct(...
        'metrics', struct('accuracy', 0.92, 'macroF1', 0.91, 'weightedF1', 0.92), ...
        'roc', struct('auc', rocData.auc), ...
        'inferenceTime', 28.5, ...
        'throughput', 35.1);
    
    reports = {report1};
    
    % Generate metrics table
    VisualizationEngine.generateLatexTable(...
        reports, 'metrics', fullfile(outputDir, 'realistic_metrics.tex'), {'ResNet50'});
    assert(exist(fullfile(outputDir, 'realistic_metrics.tex'), 'file') == 2, ...
        'Metrics table not created');
    fprintf('    ✓ Metrics table generated\n');
    
    % Generate confusion table
    VisualizationEngine.generateLatexTable(...
        confMat, 'confusion', fullfile(outputDir, 'realistic_confusion.tex'), ...
        classNames, 'ResNet50');
    assert(exist(fullfile(outputDir, 'realistic_confusion.tex'), 'file') == 2, ...
        'Confusion table not created');
    fprintf('    ✓ Confusion table generated\n');
    
    % Generate summary document
    VisualizationEngine.generateLatexTable(...
        reports, 'summary', fullfile(outputDir, 'realistic_summary.tex'), ...
        {'ResNet50'}, classNames);
    assert(exist(fullfile(outputDir, 'realistic_summary.tex'), 'file') == 2, ...
        'Summary document not created');
    fprintf('    ✓ Summary document generated\n');
end

function validateOutputQuality()
    % Validate the quality of generated outputs
    
    outputDir = 'output/classification/validation_visualization';
    
    % Check that all expected files exist
    expectedFiles = {
        'realistic_confusion.png', 'realistic_confusion.pdf', ...
        'realistic_training.png', 'realistic_training.pdf', ...
        'realistic_roc.png', 'realistic_roc.pdf', ...
        'realistic_inference.png', 'realistic_inference.pdf', ...
        'realistic_metrics.tex', 'realistic_confusion.tex', 'realistic_summary.tex'
    };
    
    fprintf('  Checking output files...\n');
    for i = 1:length(expectedFiles)
        filepath = fullfile(outputDir, expectedFiles{i});
        assert(exist(filepath, 'file') == 2, ...
            sprintf('Missing file: %s', expectedFiles{i}));
    end
    fprintf('    ✓ All expected files exist\n');
    
    % Validate PNG resolution
    fprintf('  Validating PNG resolution...\n');
    pngPath = fullfile(outputDir, 'realistic_confusion.png');
    info = imfinfo(pngPath);
    assert(info.Width >= 1000, 'PNG width too small');
    assert(info.Height >= 600, 'PNG height too small');
    fprintf('    ✓ PNG resolution adequate (W=%d, H=%d)\n', info.Width, info.Height);
    
    % Validate PDF size
    fprintf('  Validating PDF files...\n');
    pdfPath = fullfile(outputDir, 'realistic_confusion.pdf');
    pdfInfo = dir(pdfPath);
    assert(pdfInfo.bytes > 1000, 'PDF file too small');
    fprintf('    ✓ PDF files have reasonable size\n');
    
    % Validate LaTeX content
    fprintf('  Validating LaTeX content...\n');
    
    % Check metrics table
    metricsContent = fileread(fullfile(outputDir, 'realistic_metrics.tex'));
    assert(contains(metricsContent, '\\begin{table}'), 'Missing table environment');
    assert(contains(metricsContent, '\\toprule'), 'Missing booktabs formatting');
    assert(contains(metricsContent, 'Accuracy'), 'Missing accuracy column');
    fprintf('    ✓ Metrics table has valid LaTeX\n');
    
    % Check confusion table
    confusionContent = fileread(fullfile(outputDir, 'realistic_confusion.tex'));
    assert(contains(confusionContent, 'Confusion Matrix'), 'Missing title');
    assert(contains(confusionContent, 'Class 0'), 'Missing class names');
    fprintf('    ✓ Confusion table has valid LaTeX\n');
    
    % Check summary document
    summaryContent = fileread(fullfile(outputDir, 'realistic_summary.tex'));
    assert(contains(summaryContent, '\\section'), 'Missing section headers');
    assert(contains(summaryContent, '\\begin{figure}'), 'Missing figure environments');
    assert(contains(summaryContent, '\\caption'), 'Missing captions');
    fprintf('    ✓ Summary document has valid LaTeX\n');
end
