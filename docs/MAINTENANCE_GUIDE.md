# Maintenance Guide

**Corrosion Analysis System - Maintenance and Support**

## Overview

This guide provides instructions for maintaining, updating, and troubleshooting the corrosion analysis system.

## Regular Maintenance Tasks

### Daily/Weekly

- [ ] Check execution logs for errors
- [ ] Monitor disk space in output directories
- [ ] Verify GPU availability and memory
- [ ] Review recent results for anomalies

### Monthly

- [ ] Clean up old output files
- [ ] Update documentation for changes
- [ ] Review and update test cases
- [ ] Check for MATLAB toolbox updates

### Quarterly

- [ ] Performance benchmarking
- [ ] Code review and refactoring
- [ ] Update dependencies
- [ ] Backup trained models and results

## Code Maintenance

### Adding New Features

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/new-feature-name
   ```

2. **Implement Feature**
   - Follow existing code style
   - Add appropriate comments
   - Update relevant documentation

3. **Write Tests**
   - Unit tests for new functions
   - Integration tests for workflows
   - Validation tests for outputs

4. **Update Documentation**
   - README if user-facing
   - Code comments
   - User guide if needed

5. **Submit for Review**
   - Create pull request
   - Run all tests
   - Update changelog

### Modifying Existing Code

1. **Understand Current Behavior**
   - Read existing code and comments
   - Check related tests
   - Review documentation

2. **Make Changes**
   - Preserve backward compatibility when possible
   - Update tests to match changes
   - Document breaking changes

3. **Test Thoroughly**
   - Run affected unit tests
   - Run integration tests
   - Manual testing if needed

4. **Update Documentation**
   - Code comments
   - User guide
   - Changelog

### Code Style Guidelines

**MATLAB Conventions:**

```matlab
% Function header with description
function output = myFunction(input1, input2)
% MYFUNCTION Brief description
%
% Detailed description of what the function does.
%
% Inputs:
%   input1 - Description of input1
%   input2 - Description of input2
%
% Output:
%   output - Description of output
%
% Example:
%   result = myFunction(data, config);

    % Implementation
    output = processData(input1, input2);
end
```

**Naming Conventions:**
- Functions: `camelCase` (e.g., `computeMetrics`)
- Classes: `PascalCase` (e.g., `ModelFactory`)
- Variables: `camelCase` (e.g., `trainDataset`)
- Constants: `UPPER_CASE` (e.g., `MAX_EPOCHS`)

## Testing

### Running Tests

**All Tests:**
```matlab
>> run_full_test_suite
```

**Unit Tests Only:**
```matlab
>> runtests('tests/unit')
```

**Integration Tests Only:**
```matlab
>> runtests('tests/integration')
```

**Specific Test:**
```matlab
>> runtests('tests/unit/test_LabelGenerator.m')
```

### Writing New Tests

**Unit Test Template:**

```matlab
classdef test_MyComponent < matlab.unittest.TestCase
    
    properties
        testData
    end
    
    methods (TestMethodSetup)
        function setup(testCase)
            % Setup before each test
            testCase.testData = generateTestData();
        end
    end
    
    methods (Test)
        function testBasicFunctionality(testCase)
            % Test basic functionality
            result = myFunction(testCase.testData);
            testCase.verifyEqual(result.status, 'success');
        end
        
        function testEdgeCase(testCase)
            % Test edge case
            result = myFunction([]);
            testCase.verifyTrue(isempty(result));
        end
    end
end
```

### Test Coverage

Aim for >80% code coverage:

```matlab
>> import matlab.unittest.TestRunner
>> import matlab.unittest.plugins.CodeCoveragePlugin

runner = TestRunner.withTextOutput;
runner.addPlugin(CodeCoveragePlugin.forFolder('src'));
results = runner.run(testsuite('tests'));
```

## Troubleshooting

### Common Issues

#### Issue: Out of Memory During Training

**Symptoms:**
- MATLAB crashes
- "Out of memory" error
- System becomes unresponsive

**Solutions:**
1. Reduce mini-batch size:
   ```matlab
   config.training.miniBatchSize = 16; % Instead of 32
   ```

2. Reduce input size:
   ```matlab
   config.dataset.inputSize = [224, 224]; % Instead of 299
   ```

3. Clear workspace before training:
   ```matlab
   clear all; close all; clc;
   ```

4. Use gradient checkpointing (if available)

#### Issue: Training Not Converging

**Symptoms:**
- Loss not decreasing
- Validation accuracy stuck
- NaN or Inf values

**Solutions:**
1. Check learning rate:
   ```matlab
   config.training.initialLearnRate = 1e-5; % Lower rate
   ```

2. Verify data normalization:
   ```matlab
   % Images should be in [0, 1] or [-1, 1]
   ```

3. Check for data issues:
   ```matlab
   % Verify labels are correct
   % Check for corrupted images
   ```

4. Try different optimizer:
   ```matlab
   config.training.optimizer = 'adam'; % Or 'sgdm'
   ```

#### Issue: Poor Model Performance

**Symptoms:**
- Low accuracy on test set
- High confusion between classes
- Poor generalization

**Solutions:**
1. Check class balance:
   ```matlab
   stats = datasetManager.getDatasetStatistics();
   % Ensure no severe imbalance
   ```

2. Increase data augmentation:
   ```matlab
   config.dataset.augmentation = true;
   config.dataset.augmentationStrength = 'strong';
   ```

3. Try different model:
   ```matlab
   config.models.architectures = {'EfficientNetB0'};
   ```

4. Collect more training data

#### Issue: Slow Inference

**Symptoms:**
- Inference takes >100ms per image
- Real-time processing not possible

**Solutions:**
1. Use smaller model:
   ```matlab
   % Use CustomCNN instead of ResNet50
   ```

2. Reduce input size:
   ```matlab
   config.dataset.inputSize = [224, 224];
   ```

3. Enable GPU acceleration:
   ```matlab
   gpuDevice(1); % Use first GPU
   ```

4. Batch inference:
   ```matlab
   % Process multiple images at once
   ```

### Debugging Tips

**Enable Verbose Logging:**
```matlab
errorHandler.setVerbose(true);
```

**Check GPU Status:**
```matlab
gpuDevice
```

**Monitor Memory Usage:**
```matlab
memory
```

**Profile Code:**
```matlab
profile on
executar_classificacao
profile viewer
```

## Backup and Recovery

### What to Backup

**Critical Files:**
- Trained model checkpoints (`output/classification/checkpoints/`)
- Configuration files
- Custom code modifications
- Test datasets

**Important Files:**
- Execution logs
- Results files
- Generated figures
- Documentation

### Backup Schedule

**Daily:**
- Trained models from current session
- Execution logs

**Weekly:**
- All output files
- Code repository

**Monthly:**
- Complete system backup
- Archive old results

### Backup Commands

**Create Backup:**
```matlab
% Backup checkpoints
copyfile('output/classification/checkpoints', 'backup/checkpoints_YYYYMMDD');

% Backup results
copyfile('output/classification/results', 'backup/results_YYYYMMDD');
```

**Restore from Backup:**
```matlab
% Restore checkpoints
copyfile('backup/checkpoints_YYYYMMDD', 'output/classification/checkpoints');
```

### Recovery Procedures

**If Training Crashes:**
1. Check last checkpoint:
   ```matlab
   load('output/classification/checkpoints/resnet50_last.mat');
   ```

2. Resume training:
   ```matlab
   trainer.resumeTraining(net, trainDS, valDS);
   ```

**If Results Lost:**
1. Check backup directory
2. Rerun evaluation if needed:
   ```matlab
   evaluator = EvaluationEngine(net, testDS, classNames, errorHandler);
   report = evaluator.generateEvaluationReport(modelName, resultsDir);
   ```

## Performance Optimization

### Training Optimization

**Use Mixed Precision:**
```matlab
config.training.executionEnvironment = 'gpu';
config.training.precision = 'mixed'; % If supported
```

**Parallel Data Loading:**
```matlab
config.dataset.numWorkers = 4; % Parallel workers
```

**Optimize Augmentation:**
```matlab
% Use efficient augmentation pipeline
config.dataset.augmentationPipeline = 'optimized';
```

### Inference Optimization

**Batch Processing:**
```matlab
% Process multiple images at once
predictions = classify(net, testDS, 'MiniBatchSize', 32);
```

**Model Quantization:**
```matlab
% Reduce model size (if supported)
quantizedNet = quantize(net);
```

**GPU Optimization:**
```matlab
% Ensure GPU is used
net = resetState(net);
gpuDevice(1);
```

## Updating Dependencies

### MATLAB Toolboxes

**Check Current Versions:**
```matlab
ver
```

**Update Toolboxes:**
1. Open MATLAB Add-On Manager
2. Check for updates
3. Install updates
4. Test system after updates

### Pre-trained Models

**Update Model Weights:**
```matlab
% Download latest pre-trained weights
net = resnet50('Weights', 'imagenet');
```

## Documentation Updates

### When to Update

- After adding new features
- After fixing bugs
- After changing APIs
- After performance improvements

### What to Update

**README.md:**
- New features
- Changed usage
- New requirements

**User Guide:**
- New functionality
- Changed workflows
- New examples

**API Documentation:**
- Function signatures
- Parameter descriptions
- Return values

**Changelog:**
- Version number
- Date
- Changes made

### Documentation Format

**Changelog Entry:**
```markdown
## [1.1.0] - 2025-10-23

### Added
- New feature X
- Support for Y

### Changed
- Improved performance of Z
- Updated API for W

### Fixed
- Bug in component A
- Issue with B
```

## Support and Contact

### Getting Help

1. **Check Documentation:**
   - README.md
   - User Guide
   - This maintenance guide

2. **Search Issues:**
   - Check existing GitHub issues
   - Search error messages

3. **Ask for Help:**
   - Create GitHub issue
   - Email maintainers
   - Contact support

### Reporting Bugs

**Include:**
- MATLAB version
- Operating system
- Error message
- Steps to reproduce
- Expected vs actual behavior
- Relevant code snippets

**Template:**
```markdown
**Environment:**
- MATLAB: R2023b
- OS: Windows 11
- GPU: NVIDIA RTX 3060

**Description:**
[Clear description of the bug]

**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happens]

**Error Message:**
```
[Error message]
```

**Additional Context:**
[Any other relevant information]
```

### Contributing

See `CODE_STYLE_GUIDE.md` for guidelines on:
- Code style and conventions
- Pull request process
- Testing requirements
- Documentation standards

## Classification System Specific Maintenance

### Model Management

**Checkpoint Organization:**
```
output/classification/checkpoints/
├── resnet50_best.mat          # Best validation accuracy
├── resnet50_last.mat           # Last epoch
├── efficientnet_best.mat
├── efficientnet_last.mat
├── customcnn_best.mat
└── customcnn_last.mat
```

**Checkpoint Cleanup:**
```matlab
% Remove old checkpoints (keep only best)
delete('output/classification/checkpoints/*_last.mat');
```

**Model Versioning:**
```matlab
% Save with version tag
save('output/classification/checkpoints/resnet50_v1.2.mat', 'net');
```

### Label Management

**Regenerate Labels:**
```matlab
% If thresholds change
config = ClassificationConfig();
config.labelGeneration.thresholds = [15, 35]; % New thresholds
LabelGenerator.generateLabelsFromMasks(...
    config.paths.maskDir, ...
    config.labelGeneration.outputCSV, ...
    config.labelGeneration.thresholds);
```

**Validate Labels:**
```matlab
% Check label distribution
labels = readtable('output/classification/labels.csv');
histogram(labels.severity_class);
title('Class Distribution');
```

### Dataset Updates

**Add New Images:**
1. Place images in `img/original/`
2. Place masks in `img/masks/`
3. Regenerate labels
4. Retrain models

**Update Split Ratios:**
```matlab
config.dataset.splitRatios = [0.8, 0.1, 0.1]; % More training data
```

### Performance Monitoring

**Track Model Performance:**
```matlab
% Load results
results = load('output/classification/results/resnet50_results.mat');

% Compare with baseline
baseline_accuracy = 0.90;
current_accuracy = results.accuracy;

if current_accuracy < baseline_accuracy - 0.05
    warning('Model performance degraded!');
end
```

**Monitor Inference Time:**
```matlab
% Benchmark regularly
evaluator = EvaluationEngine(net, testDS, classNames, errorHandler);
inferenceTime = evaluator.measureInferenceSpeed(100);

if inferenceTime > 50 % ms
    warning('Inference time exceeds target!');
end
```

### Troubleshooting Classification Issues

#### Issue: Class Imbalance

**Symptoms:**
- Poor performance on minority class
- High overall accuracy but low per-class recall

**Solutions:**
```matlab
% 1. Adjust class weights
config.training.classWeights = [1.0, 2.0, 1.5]; % Weight minority classes

% 2. Oversample minority class
config.dataset.oversampleMinority = true;

% 3. Use stratified sampling (already default)
config.dataset.stratifiedSplit = true;
```

#### Issue: Overfitting

**Symptoms:**
- High training accuracy, low validation accuracy
- Large gap between train and validation loss

**Solutions:**
```matlab
% 1. Increase dropout
config.training.dropoutRate = 0.6; % From 0.5

% 2. Stronger augmentation
config.dataset.augmentationStrength = 'strong';

% 3. Early stopping (already implemented)
config.training.validationPatience = 10;

% 4. Reduce model complexity
config.models.architectures = {'CustomCNN'}; % Simpler model
```

#### Issue: Label Quality

**Symptoms:**
- Inconsistent predictions
- High confusion between adjacent classes

**Solutions:**
```matlab
% 1. Review threshold values
config.labelGeneration.thresholds = [10, 30]; % Adjust if needed

% 2. Validate labels manually
labels = readtable('output/classification/labels.csv');
% Check boundary cases (9-11%, 29-31%)

% 3. Visualize label distribution
histogram(labels.corroded_percentage);
xline([10, 30], 'r--', 'LineWidth', 2);
```

### Regular Maintenance Checklist

**Weekly:**
- [ ] Check execution logs for errors
- [ ] Monitor disk space in output directories
- [ ] Review recent classification results
- [ ] Verify GPU availability

**Monthly:**
- [ ] Clean up old checkpoints
- [ ] Benchmark model performance
- [ ] Review and update test cases
- [ ] Check for MATLAB updates

**Quarterly:**
- [ ] Retrain models with accumulated data
- [ ] Performance comparison with baseline
- [ ] Update documentation
- [ ] Code review and refactoring

### Backup Strategy

**Critical Files:**
```matlab
% Backup script
backupDir = sprintf('backup_%s', datestr(now, 'yyyymmdd'));
mkdir(backupDir);

% Backup checkpoints
copyfile('output/classification/checkpoints', ...
         fullfile(backupDir, 'checkpoints'));

% Backup labels
copyfile('output/classification/labels.csv', ...
         fullfile(backupDir, 'labels.csv'));

% Backup configuration
copyfile('src/classification/utils/ClassificationConfig.m', ...
         fullfile(backupDir, 'ClassificationConfig.m'));
```

### Version Control Best Practices

**What to Commit:**
- Source code
- Configuration files
- Documentation
- Test scripts

**What NOT to Commit:**
- Trained models (too large)
- Output files
- Temporary files
- Log files

**Use .gitignore:**
```
output/
*.mat
*.log
*.asv
```

### Contact and Support

**For Classification System Issues:**
- Check `src/classification/USER_GUIDE.md`
- Review `src/classification/README.md`
- See `.kiro/specs/corrosion-classification-system/`

**For General Issues:**
- Check main `README.md`
- Review `docs/user_guide.md`
- Contact maintainer

**Author:**
Heitor Oliveira Gonçalves
- LinkedIn: [linkedin.com/in/heitorhog](https://www.linkedin.com/in/heitorhog/)

---

*This guide was created as part of Task 12.4: Write final project documentation*
*Date: 2025-10-23*
*Version: 1.1*
*Last Updated: 2025-10-23*
