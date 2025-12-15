# Classification System - Test Suite

## Overview

This directory contains the complete test suite for the corrosion classification system, including unit tests, integration tests, end-to-end pipeline tests, infrastructure validation, and performance benchmarking.

## Directory Structure

```
tests/
├── unit/                           # Unit tests for individual components
│   ├── test_LabelGenerator.m      # Tests for label generation
│   ├── test_DatasetManager.m      # Tests for dataset management
│   ├── test_ModelFactory.m        # Tests for model creation
│   └── test_EvaluationEngine.m    # Tests for evaluation metrics
│
├── integration/                    # Integration and system tests
│   ├── generate_synthetic_test_dataset.m    # Synthetic data generator
│   ├── run_synthetic_dataset_generation.m   # Wrapper script
│   ├── test_complete_pipeline.m             # End-to-end pipeline test
│   ├── test_infrastructure_integration.m    # Infrastructure validation
│   ├── test_performance_benchmarking.m      # Performance benchmarks
│   ├── test_TrainingEngine.m                # Training integration test
│   ├── test_VisualizationEngine.m           # Visualization integration test
│   ├── run_full_test_suite.m                # Master test suite runner
│   ├── TESTING_GUIDE.md                     # Comprehensive testing guide
│   ├── synthetic_data/                      # Generated test data
│   │   ├── images/                          # Synthetic images
│   │   └── masks/                           # Synthetic masks
│   └── test_output/                         # Test results and reports
│       ├── task_11_results.mat
│       ├── task_11_report.txt
│       ├── full_test_suite_results.mat
│       ├── full_test_suite_report.txt
│       ├── full_test_suite_report.html
│       └── ... (other test outputs)
│
└── README.md                       # This file
```

## Quick Start

### Run All Tests

From the project root:

```matlab
>> run_task_11_tests
```

This executes the complete test suite including all subtasks.

### Run Individual Test Categories

```matlab
% Unit tests
>> cd tests/unit
>> test_LabelGenerator()
>> test_DatasetManager()
>> test_ModelFactory()
>> test_EvaluationEngine()

% Integration tests
>> cd tests/integration
>> test_TrainingEngine()
>> test_VisualizationEngine()

% System tests
>> test_complete_pipeline()
>> test_infrastructure_integration()
>> test_performance_benchmarking()

% Full suite
>> run_full_test_suite()
```

## Test Categories

### 1. Unit Tests

**Location**: `tests/unit/`

**Purpose**: Test individual components in isolation

**Components Tested**:
- LabelGenerator: Label generation from masks
- DatasetManager: Dataset loading and splitting
- ModelFactory: Model architecture creation
- EvaluationEngine: Metrics computation

**Run Time**: ~2-5 minutes total

### 2. Integration Tests

**Location**: `tests/integration/`

**Purpose**: Test component interactions and workflows

**Components Tested**:
- TrainingEngine: Training loop and checkpointing
- VisualizationEngine: Figure generation and export

**Run Time**: ~3-5 minutes total

### 3. End-to-End Pipeline Test

**Location**: `tests/integration/test_complete_pipeline.m`

**Purpose**: Validate complete workflow from data to results

**Phases Tested**:
1. Label generation from masks
2. Dataset preparation and splitting
3. Model training (quick 2-epoch test)
4. Evaluation metrics computation
5. Visualization generation

**Run Time**: ~2-5 minutes

### 4. Infrastructure Integration Test

**Location**: `tests/integration/test_infrastructure_integration.m`

**Purpose**: Validate integration with existing project infrastructure

**Tests**:
- ErrorHandler integration
- VisualizationHelper compatibility
- DataTypeConverter compatibility
- Segmentation code compatibility
- Configuration system validation

**Run Time**: ~30 seconds

### 5. Performance Benchmarking

**Location**: `tests/integration/test_performance_benchmarking.m`

**Purpose**: Measure and validate performance metrics

**Benchmarks**:
- Training time per epoch
- Inference speed (ms per image)
- Memory usage (training and inference)
- Model comparison (size, layers, speed)

**Run Time**: ~3-5 minutes

## Test Data

### Synthetic Test Dataset

**Location**: `tests/integration/synthetic_data/`

**Generation**:
```matlab
>> cd tests/integration
>> generate_synthetic_test_dataset()
```

**Contents**:
- 30 synthetic images (10 per class)
- 30 corresponding binary masks
- Controlled corroded percentages:
  - Class 0: 0.5% - 9.5% corroded
  - Class 1: 10.5% - 29.5% corroded
  - Class 2: 30.5% - 70% corroded

**Purpose**: Provides consistent test data for reproducible testing

## Test Results

### Output Location

All test results are saved to: `tests/integration/test_output/`

### Result Files

- `*.mat`: MATLAB result structures
- `*.txt`: Text reports
- `*.html`: HTML reports (viewable in browser)
- `test_labels.csv`: Generated labels
- `checkpoints/`: Training checkpoints
- `figures/`: Generated visualizations

### Viewing Results

```matlab
% Load results
>> load('tests/integration/test_output/task_11_results.mat');

% Check status
>> if results.allPassed
       disp('All tests passed!');
   else
       disp('Some tests failed.');
   end

% View details
>> disp(results.subtasks);

% View HTML report
>> web('tests/integration/test_output/full_test_suite_report.html');
```

## Performance Targets

Tests validate against these targets:

| Metric | Target | Model |
|--------|--------|-------|
| Inference Time | ≤ 50 ms/image | ResNet50 |
| Inference Time | ≤ 30 ms/image | EfficientNet-B0 |
| Inference Time | ≤ 20 ms/image | Custom CNN |
| Training Time | ≤ 60 s/epoch | All models (100 images) |
| Training Memory | ≤ 8 GB | GPU memory |
| Inference Memory | ≤ 2 GB | GPU memory |

## Requirements Coverage

The test suite validates all classification system requirements:

- **Requirements 1.1-1.5**: Label generation
- **Requirements 2.1-2.5**: Dataset preparation
- **Requirements 3.1-3.5**: Model architectures
- **Requirements 4.1-4.4**: Training pipeline
- **Requirements 5.1-5.5**: Evaluation metrics
- **Requirements 6.1-6.5**: Visualization
- **Requirements 7.1-7.5**: Infrastructure integration
- **Requirements 8.1-8.5**: Execution pipeline
- **Requirements 9.1-9.5**: Research article support
- **Requirements 10.1-10.5**: Performance benchmarking

## Troubleshooting

### Common Issues

#### 1. Synthetic Data Not Found

```matlab
>> cd tests/integration
>> generate_synthetic_test_dataset()
```

#### 2. Out of Memory

- Close other MATLAB processes
- Reduce batch size in test configuration
- Use CustomCNN instead of ResNet50

#### 3. Missing Dependencies

```matlab
>> addpath(genpath('src/classification'));
>> addpath(genpath('tests'));
```

#### 4. GPU Not Available

Tests will automatically use CPU if GPU is unavailable. Performance benchmarks may not meet targets on CPU.

### Debug Mode

For detailed output:

```matlab
% Run with verbose output
>> results = run_full_test_suite();

% Check specific test details
>> disp(results.suites.pipelineTest.phases);
```

## Best Practices

### Before Running Tests

1. Clean workspace: `clear; clc; close all;`
2. Add paths: `addpath(genpath('src/classification'));`
3. Check dependencies: Deep Learning Toolbox installed
4. Free memory: Close unnecessary applications

### During Testing

1. Monitor console output for errors
2. Check memory usage
3. Results are automatically saved
4. Review logs if tests fail

### After Testing

1. Review generated reports
2. Analyze any failures
3. Clean up temporary files if needed
4. Document any issues

## Documentation

- **TESTING_GUIDE.md**: Comprehensive testing guide
- **TASK_11_IMPLEMENTATION_SUMMARY.md**: Implementation details
- **TASK_11_VERIFICATION.md**: Verification instructions

## Continuous Integration

### Automated Testing Script

```matlab
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

## Support

For issues or questions:

1. Check the TESTING_GUIDE.md
2. Review test output and error messages
3. Check test_output/ for detailed reports
4. Consult main README.md for system documentation

## Version History

- **v1.0** (2025-01-23): Initial test suite
  - Complete unit test coverage
  - Integration tests for all components
  - End-to-end pipeline testing
  - Performance benchmarking
  - Infrastructure integration validation

---

**Last Updated**: January 23, 2025
**Test Suite Version**: 1.0
**Classification System Version**: 1.0
