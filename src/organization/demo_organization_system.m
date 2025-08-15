function demo_organization_system()
    % DEMO_ORGANIZATION_SYSTEM Demonstrate the results organization system
    %
    % This script shows how to use the ResultsOrganizer and FileManager
    % classes to automatically organize segmentation results.
    
    fprintf('=== Results Organization System Demo ===\n\n');
    
    try
        % 1. Create sample results data
        fprintf('1. Creating sample results data...\n');
        [unetResults, attentionResults, config] = createSampleResults();
        
        % 2. Initialize organizer
        fprintf('2. Initializing ResultsOrganizer...\n');
        organizerConfig = struct(...
            'baseOutputDir', 'demo_output', ...
            'namingConvention', 'timestamp_metrics', ...
            'compressionEnabled', true ...
        );
        organizer = ResultsOrganizer(organizerConfig);
        
        % 3. Organize results
        fprintf('3. Organizing results...\n');
        sessionId = organizer.organizeResults(unetResults, attentionResults, config);
        
        % 4. Generate HTML index
        fprintf('4. Generating HTML index...\n');
        organizer.generateHTMLIndex(sessionId);
        
        % 5. Export metadata
        fprintf('5. Exporting metadata...\n');
        organizer.exportMetadata(sessionId, 'json');
        organizer.exportMetadata(sessionId, 'csv');
        
        % 6. Demonstrate file management
        fprintf('6. Demonstrating file management...\n');
        fileManager = FileManager(organizerConfig);
        
        % Generate space report
        report = fileManager.generateSpaceReport();
        displaySpaceReport(report);
        
        % 7. Show directory structure
        fprintf('7. Directory structure created:\n');
        showDirectoryStructure(fullfile('demo_output', 'sessions', sessionId));
        
        fprintf('\n=== Demo completed successfully! ===\n');
        fprintf('Check the demo_output directory for organized results.\n');
        
    catch ME
        fprintf('Demo failed: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

function [unetResults, attentionResults, config] = createSampleResults()
    % Create sample segmentation results for demonstration
    
    % Configuration
    config = struct(...
        'epochs', 50, ...
        'batchSize', 8, ...
        'learningRate', 0.001, ...
        'dataset', 'sample_corrosion' ...
    );
    
    % Sample U-Net results
    unetResults = struct([]);
    for i = 1:5
        unetResults(i).imagePath = sprintf('sample_image_%03d.jpg', i);
        unetResults(i).segmentationPath = sprintf('unet_seg_%03d.png', i);
        unetResults(i).metrics = struct(...
            'iou', 0.75 + 0.1 * randn(), ...
            'dice', 0.80 + 0.1 * randn(), ...
            'accuracy', 0.85 + 0.05 * randn() ...
        );
        unetResults(i).processingTime = 0.5 + 0.2 * randn();
        unetResults(i).timestamp = now - randi(60)/1440; % Convert minutes to days
    end
    
    % Sample Attention U-Net results  
    attentionResults = struct([]);
    for i = 1:5
        attentionResults(i).imagePath = sprintf('sample_image_%03d.jpg', i);
        attentionResults(i).segmentationPath = sprintf('attention_seg_%03d.png', i);
        attentionResults(i).metrics = struct(...
            'iou', 0.78 + 0.1 * randn(), ...
            'dice', 0.83 + 0.1 * randn(), ...
            'accuracy', 0.87 + 0.05 * randn() ...
        );
        attentionResults(i).processingTime = 0.7 + 0.2 * randn();
        attentionResults(i).timestamp = now - randi(60)/1440; % Convert minutes to days
    end
end

function displaySpaceReport(report)
    % Display space usage report
    
    fprintf('\n--- Disk Space Report ---\n');
    fprintf('Base Directory: %s\n', report.baseDirectory);
    fprintf('Free Space: %.2f GB\n', report.totalFreeSpace);
    fprintf('Session Count: %d\n', report.sessionCount);
    fprintf('Total Size: %.2f MB\n', report.totalSizeMB);
    fprintf('Compressed Files: %d\n', report.compressedCount);
    
    if isfield(report, 'recommendations') && ~isempty(report.recommendations)
        fprintf('\nRecommendations:\n');
        for i = 1:length(report.recommendations)
            fprintf('  - %s\n', report.recommendations{i});
        end
    end
    fprintf('------------------------\n\n');
end

function showDirectoryStructure(sessionDir)
    % Display the created directory structure
    
    if ~exist(sessionDir, 'dir')
        fprintf('Session directory not found: %s\n', sessionDir);
        return;
    end
    
    fprintf('\nDirectory structure:\n');
    fprintf('%s/\n', sessionDir);
    
    % List main directories
    mainDirs = {'models', 'segmentations', 'comparisons', 'statistics', 'metadata'};
    
    for i = 1:length(mainDirs)
        dirPath = fullfile(sessionDir, mainDirs{i});
        if exist(dirPath, 'dir')
            fprintf('├── %s/\n', mainDirs{i});
            
            % Show subdirectories for segmentations
            if strcmp(mainDirs{i}, 'segmentations')
                subDirs = {'unet', 'attention_unet'};
                for j = 1:length(subDirs)
                    subDirPath = fullfile(dirPath, subDirs{j});
                    if exist(subDirPath, 'dir')
                        fprintf('│   ├── %s/\n', subDirs{j});
                        
                        % Show files in subdirectory
                        files = dir(fullfile(subDirPath, '*'));
                        files = files(~[files.isdir]);
                        for k = 1:min(3, length(files)) % Show first 3 files
                            fprintf('│   │   ├── %s\n', files(k).name);
                        end
                        if length(files) > 3
                            fprintf('│   │   └── ... (%d more files)\n', length(files) - 3);
                        end
                    end
                end
            else
                % Show files in other directories
                files = dir(fullfile(dirPath, '*'));
                files = files(~[files.isdir]);
                for j = 1:min(2, length(files)) % Show first 2 files
                    fprintf('│   ├── %s\n', files(j).name);
                end
                if length(files) > 2
                    fprintf('│   └── ... (%d more files)\n', length(files) - 2);
                end
            end
        end
    end
    
    % Check for HTML index
    htmlPath = fullfile(sessionDir, 'index.html');
    if exist(htmlPath, 'file')
        fprintf('└── index.html\n');
    end
    
    fprintf('\n');
end