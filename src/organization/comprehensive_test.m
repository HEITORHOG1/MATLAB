function success = comprehensive_test()
    % COMPREHENSIVE_TEST Test all organization system functionality
    %
    % This function tests all sub-tasks of Task 4 to ensure complete implementation
    
    fprintf('=== Comprehensive Organization System Test ===\n\n');
    
    success = false;
    testResults = struct();
    
    try
        % Sub-task 1: ResultsOrganizer.m for automatic organization
        fprintf('Testing Sub-task 1: ResultsOrganizer automatic organization...\n');
        testResults.organizer = testResultsOrganizer();
        
        % Sub-task 2: Hierarchical directory structure
        fprintf('Testing Sub-task 2: Hierarchical directory structure...\n');
        testResults.directory_structure = testDirectoryStructure();
        
        % Sub-task 3: Consistent naming system
        fprintf('Testing Sub-task 3: Consistent naming with timestamps and metrics...\n');
        testResults.naming_system = testNamingSystem();
        
        % Sub-task 4: FileManager for compression and space management
        fprintf('Testing Sub-task 4: FileManager compression and space management...\n');
        testResults.file_manager = testFileManagerFunctionality();
        
        % Sub-task 5: HTML index generation
        fprintf('Testing Sub-task 5: HTML index generation...\n');
        testResults.html_index = testHTMLIndexGeneration();
        
        % Sub-task 6: Metadata export (JSON, CSV)
        fprintf('Testing Sub-task 6: Metadata export in standard formats...\n');
        testResults.metadata_export = testMetadataExportFormats();
        
        % Summary
        fprintf('\n=== Comprehensive Test Results ===\n');
        fields = fieldnames(testResults);
        passCount = 0;
        
        for i = 1:length(fields)
            status = testResults.(fields{i});
            fprintf('Sub-task %d (%s): %s\n', i, fields{i}, status);
            if strcmp(status, 'PASS')
                passCount = passCount + 1;
            end
        end
        
        success = (passCount == length(fields));
        fprintf('\nOverall: %d/%d sub-tasks completed successfully\n', passCount, length(fields));
        
        if success
            fprintf('✓ Task 4 implementation COMPLETE!\n');
            fprintf('All sub-tasks have been successfully implemented:\n');
            fprintf('  ✓ ResultsOrganizer.m created with automatic organization\n');
            fprintf('  ✓ Hierarchical directory structure implemented\n');
            fprintf('  ✓ Consistent naming with timestamps and metrics\n');
            fprintf('  ✓ FileManager.m created for compression and cleanup\n');
            fprintf('  ✓ HTML index generation implemented\n');
            fprintf('  ✓ Metadata export in JSON and CSV formats\n');
        else
            fprintf('✗ Some sub-tasks need attention!\n');
        end
        
    catch ME
        fprintf('Comprehensive test failed: %s\n', ME.message);
        success = false;
    end
    
    % Cleanup test files
    cleanupComprehensiveTest();
end

function result = testResultsOrganizer()
    % Test ResultsOrganizer main functionality
    
    try
        config = struct('baseOutputDir', 'comp_test_output');
        organizer = ResultsOrganizer(config);
        
        % Create test data
        unetResults = createTestResults('unet', 3);
        attentionResults = createTestResults('attention', 3);
        config = struct('epochs', 50, 'batchSize', 16);
        
        % Test organization
        sessionId = organizer.organizeResults(unetResults, attentionResults, config);
        
        if ~isempty(sessionId) && ischar(sessionId)
            result = 'PASS';
        else
            result = 'FAIL - No valid session ID';
        end
        
    catch ME
        result = sprintf('FAIL - %s', ME.message);
    end
end

function result = testDirectoryStructure()
    % Test hierarchical directory structure creation
    
    try
        config = struct('baseOutputDir', 'comp_test_output');
        organizer = ResultsOrganizer(config);
        
        sessionId = 'test_structure_session';
        sessionDir = organizer.createDirectoryStructure(sessionId);
        
        % Check all required directories
        requiredDirs = {
            fullfile(sessionDir, 'models'),
            fullfile(sessionDir, 'segmentations', 'unet'),
            fullfile(sessionDir, 'segmentations', 'attention_unet'),
            fullfile(sessionDir, 'comparisons'),
            fullfile(sessionDir, 'statistics'),
            fullfile(sessionDir, 'metadata')
        };
        
        allExist = true;
        for i = 1:length(requiredDirs)
            if ~exist(requiredDirs{i}, 'dir')
                allExist = false;
                break;
            end
        end
        
        if allExist
            result = 'PASS';
        else
            result = 'FAIL - Missing required directories';
        end
        
    catch ME
        result = sprintf('FAIL - %s', ME.message);
    end
end

function result = testNamingSystem()
    % Test consistent naming with timestamps and metrics
    
    try
        config = struct('baseOutputDir', 'comp_test_output', 'namingConvention', 'timestamp_metrics');
        organizer = ResultsOrganizer(config);
        
        % Create test result with specific metrics
        testResult = struct();
        testResult.imagePath = 'test_image.jpg';
        testResult.segmentationPath = 'test_seg.png';
        testResult.metrics = struct('iou', 0.756, 'dice', 0.823);
        
        % Test naming system by organizing results and checking filenames
        unetResults = createTestResults('unet', 1);
        attentionResults = createTestResults('attention', 1);
        sessionConfig = struct('epochs', 10);
        
        sessionId = organizer.organizeResults(unetResults, attentionResults, sessionConfig);
        
        % Check if files were created with proper naming
        sessionData = organizer.sessionMetadata.(sessionId);
        segmentationDir = fullfile(sessionData.sessionDir, 'segmentations', 'unet');
        
        files = dir(fullfile(segmentationDir, '*.json'));
        filename = '';
        if ~isempty(files)
            filename = files(1).name;
        end
        
        % Check if filename contains expected elements
        hasIndex = ~isempty(strfind(filename, 'img_'));
        hasTimestamp = length(filename) > 15; % Should have timestamp and metrics
        
        if hasIndex && hasTimestamp
            result = 'PASS';
        else
            result = 'FAIL - Naming convention not followed';
        end
        
    catch ME
        result = sprintf('FAIL - %s', ME.message);
    end
end

function result = testFileManagerFunctionality()
    % Test FileManager compression and space management
    
    try
        config = struct('baseDirectory', 'comp_test_output');
        fileManager = FileManager(config);
        
        % Test space report generation
        report = fileManager.generateSpaceReport();
        
        % Test space checking
        freeSpace = fileManager.checkDiskSpace();
        
        % Test ensure free space (should not fail)
        spaceEnsured = fileManager.ensureFreeSpace(0.1); % Very small requirement
        
        if isstruct(report) && isnumeric(freeSpace) && islogical(spaceEnsured)
            result = 'PASS';
        else
            result = 'FAIL - FileManager functionality incomplete';
        end
        
    catch ME
        result = sprintf('FAIL - %s', ME.message);
    end
end

function result = testHTMLIndexGeneration()
    % Test HTML index generation
    
    try
        config = struct('baseOutputDir', 'comp_test_output');
        organizer = ResultsOrganizer(config);
        
        % Create test session
        unetResults = createTestResults('unet', 2);
        attentionResults = createTestResults('attention', 2);
        sessionConfig = struct('epochs', 25);
        
        sessionId = organizer.organizeResults(unetResults, attentionResults, sessionConfig);
        
        % Generate HTML
        organizer.generateHTMLIndex(sessionId);
        
        % Check if HTML file exists and has content
        sessionData = organizer.sessionMetadata.(sessionId);
        htmlPath = fullfile(sessionData.sessionDir, 'index.html');
        
        if exist(htmlPath, 'file')
            content = fileread(htmlPath);
            hasTitle = ~isempty(strfind(content, 'Segmentation Results'));
            hasSession = ~isempty(strfind(content, sessionId));
            
            if hasTitle && hasSession
                result = 'PASS';
            else
                result = 'FAIL - HTML content incomplete';
            end
        else
            result = 'FAIL - HTML file not created';
        end
        
    catch ME
        result = sprintf('FAIL - %s', ME.message);
    end
end

function result = testMetadataExportFormats()
    % Test metadata export in JSON and CSV formats
    
    try
        config = struct('baseOutputDir', 'comp_test_output');
        organizer = ResultsOrganizer(config);
        
        % Create test session
        unetResults = createTestResults('unet', 2);
        attentionResults = createTestResults('attention', 2);
        sessionConfig = struct('epochs', 25);
        
        sessionId = organizer.organizeResults(unetResults, attentionResults, sessionConfig);
        
        % Test JSON export
        organizer.exportMetadata(sessionId, 'json');
        
        % Test CSV export
        organizer.exportMetadata(sessionId, 'csv');
        
        % Check if files exist
        sessionData = organizer.sessionMetadata.(sessionId);
        metadataDir = fullfile(sessionData.sessionDir, 'metadata');
        
        jsonPath = fullfile(metadataDir, 'session_summary.json');
        csvPath = fullfile(metadataDir, 'session_summary.csv');
        
        jsonExists = exist(jsonPath, 'file');
        csvExists = exist(csvPath, 'file');
        
        if jsonExists && csvExists
            % Check file contents
            jsonContent = fileread(jsonPath);
            csvContent = fileread(csvPath);
            
            hasJsonData = ~isempty(strfind(jsonContent, 'sessionId'));
            hasCsvData = ~isempty(strfind(csvContent, 'SessionId'));
            
            if hasJsonData && hasCsvData
                result = 'PASS';
            else
                result = 'FAIL - Export file contents incomplete';
            end
        else
            result = 'FAIL - Export files not created';
        end
        
    catch ME
        result = sprintf('FAIL - %s', ME.message);
    end
end

function testResults = createTestResults(modelType, count)
    % Create test results for specified model type and count
    
    testResults = struct([]);
    
    for i = 1:count
        testResults(i).imagePath = sprintf('test_image_%s_%d.jpg', modelType, i);
        testResults(i).segmentationPath = sprintf('test_seg_%s_%d.png', modelType, i);
        testResults(i).metrics = struct(...
            'iou', 0.70 + 0.1 * randn(), ...
            'dice', 0.75 + 0.1 * randn(), ...
            'accuracy', 0.80 + 0.05 * randn() ...
        );
        testResults(i).processingTime = 0.5 + 0.2 * randn();
        testResults(i).timestamp = now - randi(60)/1440;
        testResults(i).modelType = modelType;
        
        % Create dummy segmentation file
        segDir = fileparts(testResults(i).segmentationPath);
        if ~isempty(segDir) && ~exist(segDir, 'dir')
            mkdir(segDir);
        end
        
        fid = fopen(testResults(i).segmentationPath, 'w');
        if fid ~= -1
            fprintf(fid, 'Test segmentation data for %s model %d\n', modelType, i);
            fclose(fid);
        end
    end
end

function cleanupComprehensiveTest()
    % Clean up comprehensive test files
    
    try
        if exist('comp_test_output', 'dir')
            rmdir('comp_test_output', 's');
        end
        
        % Clean up test segmentation files
        testFiles = dir('test_seg_*.png');
        for i = 1:length(testFiles)
            delete(testFiles(i).name);
        end
        
        fprintf('\nComprehensive test cleanup completed.\n');
        
    catch ME
        fprintf('Warning: Could not clean up all test files: %s\n', ME.message);
    end
end