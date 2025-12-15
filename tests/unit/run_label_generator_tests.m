% run_label_generator_tests.m
% Script to run LabelGenerator unit tests
%
% This script runs all unit tests for the LabelGenerator class.
% Run this from MATLAB command window or as a batch script.

clear;
clc;

fprintf('=== Running LabelGenerator Unit Tests ===\n\n');

% Add paths
addpath(genpath('../../src/classification'));
addpath('../../src/utils');

% Run tests
try
    test_LabelGenerator();
    fprintf('\n✓ All tests completed successfully!\n');
catch ME
    fprintf(2, '\n✗ Tests failed: %s\n', ME.message);
    fprintf(2, 'Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf(2, '  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end
