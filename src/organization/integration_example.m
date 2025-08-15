function integration_example()
    % INTEGRATION_EXAMPLE Show how to integrate organization system with existing pipeline
    %
    % This script demonstrates how to integrate the ResultsOrganizer and FileManager
    % with the existing U-Net vs Attention U-Net comparison system.
    
    fprintf('=== Organization System Integration Example ===\n\n');
    
    try
        % 1. Setup organization system
        fprintf('1. Setting up organization system...\n');
        organizationConfig = setupOrganizationSystem();
        
        % 2. Simulate existing segmentation pipeline
        fprintf('2. Running segmentation comparison (simulated)...\n');
        [unetResults, attentionResults, trainingConfig] = simulateSegmentationPipeline();
        
        % 3. Organize results automatically
        fprintf('3. Organizing results automatically...\n');
        [sessionId, organizer] = organizeSegmentationResults(unetResults, attentionResults, ...
            trainingConfig, organizationConfig);
        
        % 4. Generate comprehensive outputs
        fprintf('4. Generating comprehensive outputs...\n');
        generateComprehensiveOutputs(sessionId, organizationConfig, organizer);
        
        % 5. Demonstrate file management
        fprintf('5. Demonstrating file management...\n');
        demonstrateFileManagement(organizationConfig);
        
        % 6. Show integration points
        fprintf('6. Integration points with existing system:\n');
        showIntegrationPoints();
        
        fprintf('\n=== Integration example completed! ===\n');
        
    catch ME
        fprintf('Integration example failed: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

function config = setupOrganizationSystem()
    % Setup the organization system with appropriate configuration
    
    config = struct();
    config.baseOutputDir = 'organized_results';
    config.namingConvention = 'timestamp_metrics';
    config.compressionEnabled = true;
    config.cleanupEnabled = true;
    
    % Ensure output directory exists
    if ~exist(config.baseOutputDir, 'dir')
        mkdir(config.baseOutputDir);
    end
    
    fprintf('  - Base output directory: %s\n', config.baseOutputDir);
    fprintf('  - Naming convention: %s\n', config.namingConvention);
    fprintf('  - Compression enabled: %s\n', mat2str(config.compressionEnabled));
end

function [unetResults, attentionResults, trainingConfig] = simulateSegmentationPipeline()
    % Simulate the existing segmentation pipeline
    
    % Training configuration (would come from actual training)
    trainingConfig = struct();
    trainingConfig.epochs = 100;
    trainingConfig.batchSize = 16;
    trainingConfig.learningRate = 0.001;
    trainingConfig.optimizer = 'adam';
    trainingConfig.dataset = 'corrosion_segmentation';
    trainingConfig.imageSize = [256, 256];
    trainingConfig.augmentation = true;
    
    % Simulate U-Net results
    numImages = 10;
    unetResults = struct([]);
    
    for i = 1:numImages
        unetResults(i).imagePath = sprintf('img/original/image_%03d.jpg', i);
        unetResults(i).segmentationPath = sprintf('temp/unet_seg_%03d.png', i);
        unetResults(i).groundTruthPath = sprintf('img/masks/mask_%03d.png', i);
        
        % Simulate metrics (U-Net typically slightly lower performance)
        unetResults(i).metrics = struct();
        unetResults(i).metrics.iou = 0.72 + 0.08 * randn();
        unetResults(i).metrics.dice = 0.78 + 0.08 * randn();
        unetResults(i).metrics.accuracy = 0.85 + 0.05 * randn();
        unetResults(i).metrics.precision = 0.80 + 0.06 * randn();
        unetResults(i).metrics.recall = 0.76 + 0.07 * randn();
        
        unetResults(i).processingTime = 0.45 + 0.15 * randn();
        unetResults(i).timestamp = now - randi(120)/1440;
        unetResults(i).modelType = 'unet';
        
        % Create dummy segmentation file
        createDummySegmentation(unetResults(i).segmentationPath);
    end
    
    % Simulate Attention U-Net results  
    attentionResults = struct([]);
    
    for i = 1:numImages
        attentionResults(i).imagePath = sprintf('img/original/image_%03d.jpg', i);
        attentionResults(i).segmentationPath = sprintf('temp/attention_seg_%03d.png', i);
        attentionResults(i).groundTruthPath = sprintf('img/masks/mask_%03d.png', i);
        
        % Simulate metrics (Attention U-Net typically better performance)
        attentionResults(i).metrics = struct();
        attentionResults(i).metrics.iou = 0.76 + 0.08 * randn();
        attentionResults(i).metrics.dice = 0.82 + 0.08 * randn();
        attentionResults(i).metrics.accuracy = 0.88 + 0.05 * randn();
        attentionResults(i).metrics.precision = 0.84 + 0.06 * randn();
        attentionResults(i).metrics.recall = 0.80 + 0.07 * randn();
        
        attentionResults(i).processingTime = 0.65 + 0.20 * randn();
        attentionResults(i).timestamp = now - randi(120)/1440;
        attentionResults(i).modelType = 'attention_unet';
        
        % Create dummy segmentation file
        createDummySegmentation(attentionResults(i).segmentationPath);
    end
    
    fprintf('  - Generated %d U-Net results\n', length(unetResults));
    fprintf('  - Generated %d Attention U-Net results\n', length(attentionResults));
end

function [sessionId, organizer] = organizeSegmentationResults(unetResults, attentionResults, ...
    trainingConfig, organizationConfig)
    % Organize segmentation results using the organization system
    
    % Create ResultsOrganizer
    organizer = ResultsOrganizer(organizationConfig);
    
    % Organize results
    sessionId = organizer.organizeResults(unetResults, attentionResults, trainingConfig);
    
    fprintf('  - Session created: %s\n', sessionId);
    fprintf('  - Results organized in structured directories\n');
end

function generateComprehensiveOutputs(sessionId, organizationConfig, organizer)
    % Generate all comprehensive outputs for the session
    
    % Use existing organizer instance (passed as parameter)
    
    % Generate HTML index
    organizer.generateHTMLIndex(sessionId);
    fprintf('  - HTML index generated\n');
    
    % Export metadata in multiple formats
    organizer.exportMetadata(sessionId, 'json');
    fprintf('  - JSON metadata exported\n');
    
    organizer.exportMetadata(sessionId, 'csv');
    fprintf('  - CSV metadata exported\n');
    
    % Generate statistical summary (placeholder)
    generateStatisticalSummary(sessionId, organizationConfig);
    fprintf('  - Statistical summary generated\n');
end

function demonstrateFileManagement(organizationConfig)
    % Demonstrate file management capabilities
    
    % Create FileManager
    fileManager = FileManager(organizationConfig);
    
    % Generate space report
    report = fileManager.generateSpaceReport();
    
    fprintf('  - Space report generated:\n');
    fprintf('    * Free space: %.2f GB\n', report.totalFreeSpace);
    fprintf('    * Sessions: %d\n', report.sessionCount);
    fprintf('    * Total size: %.2f MB\n', report.totalSizeMB);
    
    % Check if cleanup is needed
    if report.totalSizeMB > 100 % If more than 100MB
        fprintf('  - Large data detected, compression recommended\n');
    end
end

function showIntegrationPoints()
    % Show key integration points with existing system
    
    fprintf('  Key integration points:\n');
    fprintf('  - Add to executar_comparacao.m: automatic result organization\n');
    fprintf('  - Modify treinar_unet_simples.m: save results for organization\n');
    fprintf('  - Update main menu: add result browsing option\n');
    fprintf('  - Integrate with ModelSaver: coordinate model and result storage\n');
    fprintf('  - Add to comparison pipeline: automatic HTML generation\n');
    
    fprintf('\n  Example integration code:\n');
    fprintf('  %% In executar_comparacao.m, after comparison:\n');
    fprintf('  organizer = ResultsOrganizer();\n');
    fprintf('  sessionId = organizer.organizeResults(unetResults, attentionResults, config);\n');
    fprintf('  organizer.generateHTMLIndex(sessionId);\n');
end

function createDummySegmentation(filepath)
    % Create a dummy segmentation file for testing
    
    % Ensure directory exists
    [dir, ~, ~] = fileparts(filepath);
    if ~isempty(dir) && ~exist(dir, 'dir')
        mkdir(dir);
    end
    
    % Create dummy file
    fid = fopen(filepath, 'w');
    if fid ~= -1
        fprintf(fid, 'Dummy segmentation data\n');
        fclose(fid);
    end
end

function generateStatisticalSummary(sessionId, organizationConfig)
    % Generate statistical summary for the session (placeholder)
    
    try
        % Get session directory
        sessionsDir = fullfile(organizationConfig.baseOutputDir, 'sessions');
        sessionDir = fullfile(sessionsDir, sessionId);
        statisticsDir = fullfile(sessionDir, 'statistics');
        
        % Create statistics directory if it doesn't exist
        if ~exist(statisticsDir, 'dir')
            mkdir(statisticsDir);
        end
        
        % Generate summary report
        summaryPath = fullfile(statisticsDir, 'statistical_summary.txt');
        
        fid = fopen(summaryPath, 'w');
        if fid ~= -1
            fprintf(fid, 'Statistical Summary for Session: %s\n', sessionId);
            fprintf(fid, 'Generated: %s\n\n', datestr(now));
            fprintf(fid, 'This is a placeholder for comprehensive statistical analysis.\n');
            fprintf(fid, 'In the full implementation, this would include:\n');
            fprintf(fid, '- Comparative metrics analysis\n');
            fprintf(fid, '- Statistical significance tests\n');
            fprintf(fid, '- Performance distribution analysis\n');
            fprintf(fid, '- Model comparison summary\n');
            fclose(fid);
        end
        
    catch ME
        warning('Failed to generate statistical summary: %s', ME.message);
    end
end