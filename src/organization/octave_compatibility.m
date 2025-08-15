function octave_compatibility()
    % OCTAVE_COMPATIBILITY Ensure organization system works with Octave
    %
    % This script provides compatibility fixes for Octave
    
    fprintf('=== Octave Compatibility Check ===\n\n');
    
    try
        % Test basic functionality with Octave-compatible code
        fprintf('Testing basic organization functionality...\n');
        
        % Create simple test
        config = struct('baseOutputDir', 'octave_test_output');
        organizer = ResultsOrganizer(config);
        
        % Create minimal test data
        unetResult = struct();
        unetResult.imagePath = 'test_image.jpg';
        unetResult.segmentationPath = 'test_seg.png';
        unetResult.metrics = struct('iou', 0.75, 'dice', 0.80, 'accuracy', 0.85);
        unetResult.processingTime = 0.5;
        unetResult.timestamp = now; % Use datenum instead of datetime for Octave
        
        attentionResult = unetResult;
        attentionResult.segmentationPath = 'test_attention_seg.png';
        attentionResult.metrics.iou = 0.78;
        
        config = struct('epochs', 10);
        
        % Test organization
        sessionId = organizer.organizeResults(unetResult, attentionResult, config);
        
        if ~isempty(sessionId)
            fprintf('✓ Basic organization works\n');
        else
            fprintf('✗ Basic organization failed\n');
        end
        
        % Test HTML generation (simplified)
        try
            organizer.generateHTMLIndex(sessionId);
            fprintf('✓ HTML generation works\n');
        catch ME
            fprintf('✗ HTML generation failed: %s\n', ME.message);
        end
        
        % Test metadata export (simplified)
        try
            organizer.exportMetadata(sessionId, 'json');
            fprintf('✓ JSON export works\n');
        catch ME
            fprintf('✗ JSON export failed: %s\n', ME.message);
        end
        
        % Test FileManager
        try
            fileManager = FileManager(struct('baseDirectory', 'octave_test_output'));
            report = fileManager.generateSpaceReport();
            fprintf('✓ FileManager works\n');
        catch ME
            fprintf('✗ FileManager failed: %s\n', ME.message);
        end
        
        fprintf('\n=== Octave compatibility test completed ===\n');
        
    catch ME
        fprintf('Octave compatibility test failed: %s\n', ME.message);
    end
    
    % Cleanup
    try
        if exist('octave_test_output', 'dir')
            rmdir('octave_test_output', 's');
        end
    catch
        % Ignore cleanup errors
    end
end