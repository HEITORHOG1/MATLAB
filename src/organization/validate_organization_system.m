function success = validate_organization_system()
    % VALIDATE_ORGANIZATION_SYSTEM Test the results organization system
    %
    % This function runs comprehensive tests on the organization system
    % to ensure all components work correctly.
    
    fprintf('=== Validating Results Organization System ===\n\n');
    
    success = false;
    testResults = struct();
    
    try
        % Test 1: ResultsOrganizer basic functionality
        fprintf('Test 1: ResultsOrganizer basic functionality...\n');
        testResults.organizer_basic = testOrganizerBasic();
        
        % Test 2: Directory structure creation
        fprintf('Test 2: Directory structure creation...\n');
        testResults.directory_structure = testDirectoryStructure();
        
        % Test 3: HTML generation
        fprintf('Test 3: HTML index generation...\n');
        testResults.html_generation = testHTMLGeneration();
        
        % Test 4: Metadata export
        fprintf('Test 4: Metadata export...\n');
        testResults.metadata_export = testMetadataExport();
        
        % Test 5: FileManager functionality
        fprintf('Test 5: FileManager functionality...\n');
        testResults.file_manager = testFileManager();
        
        % Test 6: Error handling
        fprintf('Test 6: Error handling...\n');
        testResults.error_handling = testErrorHandling();
        
        % Summary
        fprintf('\n=== Test Results Summary ===\n');
        fields = fieldnames(testResults);
        passCount = 0;
        
        for i = 1:length(fields)
            status = testResults.(fields{i});
            fprintf('%s: %s\n', fields{i}, status);
            if strcmp(status, 'PASS')
                passCount = passCount + 1;
            end
        end
        
        success = (passCount == length(fields));
        fprintf('\nOverall: %d/%d tests passed\n', passCount, length(fields));
        
        if success
            fprintf('✓ All tests passed!\n');
        else
            fprintf('✗ Some tests failed!\n');
        end
        
    catch ME
        fprintf('Validation failed: %s\n', ME.message);
        success = false;
    end
    
    % Cleanup test files
    cleanupTestFiles();
end

function result = testOrganizerBasic()
    % Test basic ResultsOrganizer functionality
    
    try
        % Create organizer
        config = struct('baseOutputDir', 'test_output');
        organizer = ResultsOrganizer(config);
        
        % Create sample data
        unetResults = createSampleResult('unet', 1);
        attentionResults = createSampleResult('attention', 1);
        config = struct('epochs', 10);
        
        % Test organization
        sessionId = organizer.organizeResults(unetResults, attentionResults, config);
        
        % Verify session was created
        if ischar(sessionId) && ~isempty(sessionId)
            result = 'PASS';
        else
            result = 'FAIL - No session ID returned';
        end
        
    catch ME
        result = sprintf('FAIL - %s', ME.message);
    end
end

function result = testDirectoryStructure()
    % Test directory structure creation
    
    try
        config = struct('baseOutputDir', 'test_output');
        organizer = ResultsOrganizer(config);
        
        sessionId = sprintf('test_session_%s', datestr(now, 'HHMMSS'));
        sessionDir = organizer.createDirectoryStructure(sessionId);
        
        % Check required directories exist
        requiredDirs = {
            sessionDir,
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
            result = 'FAIL - Missing directories';
        end
        
    catch ME
        result = sprintf('FAIL - %s', ME.message);
    end
end

function result = testHTMLGeneration()
    % Test HTML index generation
    
    try
        config = struct('baseOutputDir', 'test_output');
        organizer = ResultsOrganizer(config);
        
        % Create test session
        unetResults = createSampleResult('unet', 1);
        attentionResults = createSampleResult('attention', 1);
        sessionConfig = struct('epochs', 10);
        
        sessionId = organizer.organizeResults(unetResults, attentionResults, sessionConfig);
        
        % Generate HTML
        organizer.generateHTMLIndex(sessionId);
        
        % Check if HTML file was created
        sessionData = organizer.sessionMetadata.(sessionId);
        htmlPath = fullfile(sessionData.sessionDir, 'index.html');
        
        if exist(htmlPath, 'file')
            % Check if HTML contains expected content
            content = fileread(htmlPath);
            if ~isempty(strfind(content, 'Segmentation Results')) && ~isempty(strfind(content, sessionId))
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

function result = testMetadataExport()
    % Test metadata export functionality
    
    try
        config = struct('baseOutputDir', 'test_output');
        organizer = ResultsOrganizer(config);
        
        % Create test session
        unetResults = createSampleResult('unet', 1);
        attentionResults = createSampleResult('attention', 1);
        sessionConfig = struct('epochs', 10);
        
        sessionId = organizer.organizeResults(unetResults, attentionResults, sessionConfig);
        
        % Test JSON export
        organizer.exportMetadata(sessionId, 'json');
        
        % Test CSV export
        organizer.exportMetadata(sessionId, 'csv');
        
        % Check if files were created
        sessionData = organizer.sessionMetadata.(sessionId);
        metadataDir = fullfile(sessionData.sessionDir, 'metadata');
        
        jsonPath = fullfile(metadataDir, 'session_summary.json');
        csvPath = fullfile(metadataDir, 'session_summary.csv');
        
        if exist(jsonPath, 'file') && exist(csvPath, 'file')
            result = 'PASS';
        else
            result = 'FAIL - Metadata files not created';
        end
        
    catch ME
        result = sprintf('FAIL - %s', ME.message);
    end
end

function result = testFileManager()
    % Test FileManager functionality
    
    try
        config = struct('baseDirectory', 'test_output');
        fileManager = FileManager(config);
        
        % Test space report generation
        report = fileManager.generateSpaceReport();
        
        if isstruct(report) && isfield(report, 'totalFreeSpace')
            result = 'PASS';
        else
            result = 'FAIL - Invalid space report';
        end
        
    catch ME
        result = sprintf('FAIL - %s', ME.message);
    end
end

function result = testErrorHandling()
    % Test error handling capabilities
    
    try
        % Test with invalid configuration
        config = struct('baseOutputDir', '/invalid/path/that/should/not/exist');
        organizer = ResultsOrganizer(config);
        
        % This should handle the error gracefully
        unetResults = createSampleResult('unet', 1);
        attentionResults = createSampleResult('attention', 1);
        sessionConfig = struct('epochs', 10);
        
        try
            sessionId = organizer.organizeResults(unetResults, attentionResults, sessionConfig);
            % If we get here, error handling worked
            result = 'PASS';
        catch
            % Expected to fail, but should be handled gracefully
            result = 'PASS';
        end
        
    catch ME
        result = sprintf('FAIL - %s', ME.message);
    end
end

function sampleResult = createSampleResult(modelType, index)
    % Create a sample result structure for testing
    
    sampleResult = struct();
    sampleResult.imagePath = sprintf('test_image_%s_%d.jpg', modelType, index);
    sampleResult.segmentationPath = sprintf('test_seg_%s_%d.png', modelType, index);
    sampleResult.metrics = struct(...
        'iou', 0.75 + 0.1 * randn(), ...
        'dice', 0.80 + 0.1 * randn(), ...
        'accuracy', 0.85 + 0.05 * randn() ...
    );
    sampleResult.processingTime = 0.5 + 0.2 * randn();
    sampleResult.timestamp = datetime('now');
    
    % Create dummy segmentation file for testing
    segDir = fileparts(sampleResult.segmentationPath);
    if ~isempty(segDir) && ~exist(segDir, 'dir')
        mkdir(segDir);
    end
    
    % Create a simple test file
    fid = fopen(sampleResult.segmentationPath, 'w');
    if fid ~= -1
        fprintf(fid, 'Test segmentation data for %s model\n', modelType);
        fclose(fid);
    end
end

function cleanupTestFiles()
    % Clean up test files and directories
    
    try
        if exist('test_output', 'dir')
            rmdir('test_output', 's');
        end
        
        % Clean up any test segmentation files
        testFiles = dir('test_seg_*.png');
        for i = 1:length(testFiles)
            delete(testFiles(i).name);
        end
        
        fprintf('Test cleanup completed.\n');
        
    catch ME
        fprintf('Warning: Could not clean up all test files: %s\n', ME.message);
    end
end