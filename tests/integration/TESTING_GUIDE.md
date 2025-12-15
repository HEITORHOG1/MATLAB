# Classification System - Testing Guide

## Overview

This guide provides instructions for running the complete test suite for the corrosion classification system. The test suite includes unit tests, integration tests, end-to-end pipeline tests, infrastructure integration tests, and performance benchmarking.

## Test Structure

```
tests/
├── unit/                           # Unit tests for individual components
│   ├── test_LabelGenerator.m
│   ├── test_DatasetManager.m
│   ├── test_ModelFactory.m
│   └── test_EvaluationEngine.m
│
├── integration/                    # Integration and system tests
│   ├── generate_synthetic_test_dataset.m
│   ├── test_complete_pipeline.m
│   ├── test_infrastructure_integration.m
│   ├── test_performance_benchmarking.m
│   ├── test_TrainingEngine.m
│   ├── test_VisualizationEngine.m
│   └── run_full_test_suite.m
│
└── integration/synthetic_data/     # Generated test data
    ├── images/
    └── masks/
```

## Quick Start

### Run Complete Test Suite

To run all tests at once:

```matlab
>> cd tests/integration
>> results = run_full_test_suite()
```

This will execute:
1. All unit tests
2. All integration tests
3. End-to-end pipeline test
4. Infrastructure integration test
5. Performance benchmarking

Results are saved to `tests/integration/test_output/`.

## Individual Test Suites

### 1. Generate Synthetic Test Data

Before running tests, generate synthetic test data:

```matlab
>> cd tests/integration
>> generate_synthetic_test_dataset()
```

This creates 30 synthetic images (10 per class) with controlled corrosion percentages:
- **Class 0 (None/Light)**: 0.5% - 9.5% corroded
- **Class 1 (Moderate)**: 10.5% - 29.5% corroded
- **Class 2 (Severe)**: 30.5% - 70% corroded

Output: `tests/integration/synthetic_data/`

### 2. Unit Tests

Run individual unit tests:

```matlab
% Test LabelGenerator
>> cd tests/unit
>> results = test_LabelGenerator()

% Test DatasetManager
>> results = test_DatasetManager()

% Test ModelFactory
>> results = test_ModelFactory()

% Test EvaluationEngine
>> results = test_EvaluationEngine()
```

### 3. Integration Tests

Run integration tests:

```matlab
% Test TrainingEngine
>> cd tests/integration
>> results = test_TrainingEngine()

% Test VisualizationEngine
>> results = test_VisualizationEngine()
```

### 4. End-to-End Pipeline Test

Test the complete classification pipeline:

```matlab
>> cd tests/integration
>> results = test_complete_pipeline()
```

This tests:
- Label generation from masks
- Dataset preparation and splitting
- Model training (quick 2-epoch test)
- Evaluation metrics computation
- Visualization generation

### 5. Infrastructure Integration Test

Validate integration with existing infrastructure:

```matlab
>> cd tests/integration
>> results = test_infrastructure_integration()
```

This tests:
- ErrorHandler integration
- VisualizationHelper integration
- DataTypeConverter compatibility
- No conflicts with segmentation code
- Configuration system compatibility

### 6. Performance Benchmarking

Run performance benchmarks:

```matlab
>> cd tests/integration
>> results = test_performance_benchmarking()
```

This measures:
- Training time per epoch for each model
- Inference speed (ms per image)
- Memory usage during training and inference
- Model comparison (size, layers, speed)

## Test Output

All test results are saved to `tests/integration/test_output/`:

```
test_output/
├── full_test_suite_results.mat          # Complete test results
├── full_test_suite_report.txt           # Text report
├── full_test_suite_report.html          # HTML report
├── pipeline_test_results.mat            # Pipeline test results
├── pipeline_test_report.txt
├── infrastructure_integration_results.mat
├── infrastructure_integration_report.txt
├── performance_benchmark_results.mat
├── performance_benchmark_report.txt
├── test_labels.csv                      # Generated labels
├── checkpoints/                         # Training checkpoints
└── figures/                             # Generated visualizations
```

## Performance Targets

The test suite validates against these performance targets:

| Metric | Target | Notes |
|--------|--------|-------|
| ResNet50 Inference | ≤ 50 ms/image | Industry standard |
| EfficientNet Inference | ≤ 30 ms/image | Efficient architecture |
| Custom CNN Inference | ≤ 20 ms/image | Lightweight model |
| Training Time | ≤ 60 s/epoch | For 100 images |
| Training Memory | ≤ 8 GB | GPU memory |
| Inference Memory | ≤ 2 GB | GPU memory |

## Interpreting Results

### Success Criteria

A test passes if:
- ✓ All assertions pass
- ✓ No exceptions are thrown
- ✓ Output files are created correctly
- ✓ Performance targets are met (where applicable)

### Result Structure

Each test returns a results struct:

```matlab
results = struct(
    'timestamp', datetime('now'),
    'allPassed', true/false,
    'tests', struct(...),  % Individual test results
    'summary', struct(...) % Summary statistics
);
```

### Viewing Results

```matlab
% Load saved results
load('tests/integration/test_output/full_test_suite_results.mat');

% Check overall status
if results.allPassed
    disp('All tests passed!');
else
    disp('Some tests failed. Check results for details.');
end

% View summary
disp(results.summary);

% View specific test results
disp(results.suites.unitTests);
```

## Troubleshooting

### Common Issues

#### 1. Synthetic Data Not Found

**Error**: "Synthetic data not found"

**Solution**:
```matlab
>> cd tests/integration
>> generate_synthetic_test_dataset()
```

#### 2. Out of Memory

**Error**: "Out of memory" during training

**Solution**:
- Reduce batch size in test configuration
- Close other MATLAB processes
- Use smaller model (CustomCNN instead of ResNet50)

#### 3. Missing Dependencies

**Error**: "Undefined function or variable"

**Solution**:
```matlab
% Add classification system to path
>> addpath(genpath('src/classification'));
>> addpath(genpath('tests'));
```

#### 4. GPU Not Available

**Warning**: Tests run slower without GPU

**Solution**:
- Tests will automatically use CPU if GPU unavailable
- Performance benchmarks may not meet targets on CPU

### Debug Mode

Run tests with detailed output:

```matlab
% Enable verbose output
>> results = run_full_test_suite();

% Check specific test details
>> disp(results.suites.pipelineTest.phases);
```

## Continuous Integration

### Automated Testing

To run tests automatically:

```matlab
% Create test script: run_ci_tests.m
function success = run_ci_tests()
    try
        results = run_full_test_suite();
        success = results.allPassed;
        
        if ~success
            error('Test suite failed');
        end
    catch ME
        fprintf('CI Test Error: %s\n', ME.message);
        success = false;
    end
end
```

### Test Coverage

The test suite covers:

- ✓ Label generation (Requirements 1.1-1.5)
- ✓ Dataset preparation (Requirements 2.1-2.5)
- ✓ Model architectures (Requirements 3.1-3.5)
- ✓ Training pipeline (Requirements 4.1-4.4)
- ✓ Evaluation metrics (Requirements 5.1-5.5)
- ✓ Visualization (Requirements 6.1-6.5)
- ✓ Infrastructure integration (Requirements 7.1-7.5)
- ✓ Execution pipeline (Requirements 8.1-8.5)
- ✓ Performance benchmarking (Requirements 10.1-10.2)

## Best Practices

### Before Running Tests

1. **Clean workspace**: `clear; clc; close all;`
2. **Add paths**: `addpath(genpath('src/classification'));`
3. **Check dependencies**: Ensure Deep Learning Toolbox is installed
4. **Free memory**: Close unnecessary applications

### During Testing

1. **Monitor progress**: Watch console output for errors
2. **Check memory**: Use Task Manager/Activity Monitor
3. **Save results**: Results are automatically saved
4. **Review logs**: Check error logs if tests fail

### After Testing

1. **Review reports**: Check text and HTML reports
2. **Analyze failures**: Investigate any failed tests
3. **Clean up**: Remove temporary files if needed
4. **Document issues**: Note any problems for future reference

## Advanced Usage

### Custom Test Configuration

Modify test parameters:

```matlab
% Edit test configuration
config = struct();
config.maxEpochs = 5;  % Increase for more thorough testing
config.miniBatchSize = 8;
config.numTestImages = 20;

% Run with custom config
results = test_complete_pipeline_custom(config);
```

### Selective Testing

Run specific test categories:

```matlab
% Run only unit tests
results = runUnitTests();

% Run only performance benchmarks
results = test_performance_benchmarking();

% Run only infrastructure tests
results = test_infrastructure_integration();
```

### Parallel Testing

For faster execution (requires Parallel Computing Toolbox):

```matlab
% Enable parallel pool
parpool('local', 4);

% Run tests in parallel
% (Implementation depends on specific test structure)
```

## Support

For issues or questions:

1. Check this guide first
2. Review test output and error messages
3. Check `tests/integration/test_output/` for detailed reports
4. Consult the main README.md for system documentation

## Version History

- **v1.0** (2025-01-23): Initial test suite implementation
  - Complete unit test coverage
  - Integration tests for all components
  - End-to-end pipeline testing
  - Performance benchmarking
  - Infrastructure integration validation

---

**Last Updated**: January 23, 2025
**Test Suite Version**: 1.0
**Classification System Version**: 1.0
