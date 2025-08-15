function simple_test()
    % SIMPLE_TEST Basic test of organization system
    
    fprintf('=== Simple Organization Test ===\n\n');
    
    try
        % Create organizer
        config = struct('baseOutputDir', 'simple_test_output');
        organizer = ResultsOrganizer(config);
        
        % Create simple test data
        unetResult = struct();
        unetResult.imagePath = 'test_image.jpg';
        unetResult.segmentationPath = 'test_seg.png';
        unetResult.metrics = struct('iou', 0.75, 'dice', 0.80, 'accuracy', 0.85);
        unetResult.processingTime = 0.5;
        unetResult.timestamp = now;
        
        attentionResult = unetResult;
        attentionResult.segmentationPath = 'test_attention_seg.png';
        attentionResult.metrics.iou = 0.78;
        
        config = struct('epochs', 10);
        
        % Test organization
        sessionId = organizer.organizeResults(unetResult, attentionResult, config);
        fprintf('Session created: %s\n', sessionId);
        
        % Test HTML generation with same organizer instance
        organizer.generateHTMLIndex(sessionId);
        fprintf('HTML generated successfully\n');
        
        % Test metadata export
        organizer.exportMetadata(sessionId, 'json');
        fprintf('JSON exported successfully\n');
        
        fprintf('\n=== Simple test completed successfully! ===\n');
        
    catch ME
        fprintf('Simple test failed: %s\n', ME.message);
    end
    
    % Cleanup
    try
        if exist('simple_test_output', 'dir')
            rmdir('simple_test_output', 's');
        end
    catch
        % Ignore cleanup errors
    end
end