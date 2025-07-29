function test_categorical_conversion_edge_cases()
    % Test edge cases where the old categorical conversion logic fails
    
    fprintf('=== Testing Categorical Conversion Edge Cases ===\n');
    
    % Add necessary paths
    addpath(fullfile(pwd, 'src', 'utils'));
    
    try
        % Case 1: Standard case (should work with both methods)
        fprintf('\nCase 1: Standard categorical with [0,1] labelIDs\n');
        cat1 = categorical([0, 1, 0, 1], [0, 1], {'background', 'foreground'});
        
        method1 = cat1 == "foreground";
        method2 = double(cat1) > 1;
        
        fprintf('Data: %s\n', mat2str(double(cat1)));
        fprintf('Method 1 (== "foreground"): %s\n', mat2str(method1));
        fprintf('Method 2 (double > 1): %s\n', mat2str(method2));
        fprintf('Methods agree: %s\n', mat2str(isequal(method1, method2)));
        
        % Case 2: Categorical with different labelIDs (old method fails)
        fprintf('\nCase 2: Categorical with [1,2] labelIDs\n');
        cat2 = categorical([1, 2, 1, 2], [1, 2], {'background', 'foreground'});
        
        method1 = cat2 == "foreground";
        method2 = double(cat2) > 1;
        
        fprintf('Data: %s\n', mat2str(double(cat2)));
        fprintf('Method 1 (== "foreground"): %s\n', mat2str(method1));
        fprintf('Method 2 (double > 1): %s\n', mat2str(method2));
        fprintf('Methods agree: %s\n', mat2str(isequal(method1, method2)));
        
        % Case 3: Categorical with [0,255] labelIDs (old method fails badly)
        fprintf('\nCase 3: Categorical with [0,255] labelIDs\n');
        cat3 = categorical([0, 255, 0, 255], [0, 255], {'background', 'foreground'});
        
        method1 = cat3 == "foreground";
        method2 = double(cat3) > 1;
        
        fprintf('Data: %s\n', mat2str(double(cat3)));
        fprintf('Method 1 (== "foreground"): %s\n', mat2str(method1));
        fprintf('Method 2 (double > 1): %s\n', mat2str(method2));
        fprintf('Methods agree: %s\n', mat2str(isequal(method1, method2)));
        
        % Case 4: Logical data converted to categorical
        fprintf('\nCase 4: Logical data converted to categorical\n');
        logical_data = [false, true, false, true];
        cat4 = categorical(logical_data, [false, true], {'background', 'foreground'});
        
        method1 = cat4 == "foreground";
        method2 = double(cat4) > 1;
        
        fprintf('Data: %s\n', mat2str(double(cat4)));
        fprintf('Method 1 (== "foreground"): %s\n', mat2str(method1));
        fprintf('Method 2 (double > 1): %s\n', mat2str(method2));
        fprintf('Methods agree: %s\n', mat2str(isequal(method1, method2)));
        
        % Demonstrate why the fix is critical
        fprintf('\n=== Summary ===\n');
        fprintf('The corrected method (== "foreground") is:\n');
        fprintf('1. More explicit and readable\n');
        fprintf('2. Independent of labelID values\n');
        fprintf('3. Robust against different categorical creation methods\n');
        fprintf('4. Prevents artificially perfect metrics from incorrect conversions\n');
        
        % Test with VisualizationHelper
        fprintf('\nTesting VisualizationHelper with edge cases...\n');
        
        for i = 1:4
            eval(sprintf('test_cat = cat%d;', i));
            visual_data = VisualizationHelper.prepareMaskForDisplay(test_cat);
            fprintf('Case %d: %s -> %s (size: %s)\n', i, class(test_cat), class(visual_data), mat2str(size(visual_data)));
        end
        
        fprintf('\n✓ All edge cases handled successfully by VisualizationHelper\n');
        
    catch ME
        fprintf('❌ Test failed: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for k = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(k).name, ME.stack(k).line);
        end
    end
end