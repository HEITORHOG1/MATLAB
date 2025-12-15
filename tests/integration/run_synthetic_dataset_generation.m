% RUN_SYNTHETIC_DATASET_GENERATION
% Wrapper script to generate synthetic test dataset for classification testing
%
% This script can be executed directly from MATLAB command window:
%   >> run_synthetic_dataset_generation
%
% Or from the tests/integration directory:
%   >> cd tests/integration
%   >> run_synthetic_dataset_generation

% Add necessary paths
if ~exist('generate_synthetic_test_dataset', 'file')
    addpath(fullfile(pwd, 'tests', 'integration'));
end

% Run the generator
try
    generate_synthetic_test_dataset();
    fprintf('\n✓ Synthetic dataset generation completed successfully!\n');
catch ME
    fprintf('\n✗ Error generating synthetic dataset:\n');
    fprintf('  %s\n', ME.message);
    fprintf('  File: %s\n', ME.stack(1).file);
    fprintf('  Line: %d\n', ME.stack(1).line);
    rethrow(ME);
end
