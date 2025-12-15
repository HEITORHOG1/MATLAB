% test_gerar_labels.m
% Quick test script for gerar_labels_classificacao.m

fprintf('Testing gerar_labels_classificacao.m...\n\n');

% Add paths
addpath('src/classification/core');
addpath('src/classification/utils');
addpath('src/utils');

try
    % Run the label generation script
    gerar_labels_classificacao();
    
    fprintf('\n=== Test Passed ===\n');
    fprintf('Label generation completed successfully!\n');
    
    % Verify outputs exist
    if exist('output/classification/labels.csv', 'file')
        fprintf('✓ CSV file created\n');
        
        % Read and display first few rows
        labels = readtable('output/classification/labels.csv');
        fprintf('\nFirst 5 labels:\n');
        disp(labels(1:min(5, height(labels)), :));
    else
        fprintf('✗ CSV file not found\n');
    end
    
    if exist('output/classification/results/label_generation_stats.mat', 'file')
        fprintf('✓ Statistics file created\n');
    else
        fprintf('✗ Statistics file not found\n');
    end
    
    if exist('output/classification/results/label_generation_report.txt', 'file')
        fprintf('✓ Report file created\n');
    else
        fprintf('✗ Report file not found\n');
    end
    
catch ME
    fprintf('\n=== Test Failed ===\n');
    fprintf('Error: %s\n', ME.message);
    fprintf('Stack:\n');
    disp(ME.stack);
    rethrow(ME);
end
