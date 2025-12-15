# Code Style Guide

**Corrosion Analysis System - Coding Standards**

## Overview

This document defines the coding standards and style guidelines for the corrosion analysis system. Following these guidelines ensures code consistency, readability, and maintainability.

## General Principles

1. **Clarity over Cleverness:** Write code that is easy to understand
2. **Consistency:** Follow established patterns
3. **Documentation:** Comment complex logic
4. **Testing:** Write tests for new code
5. **Modularity:** Keep functions focused and small

## MATLAB Conventions

### File Organization

**File Structure:**
```matlab
% filename.m - Brief description
%
% Detailed description of what this file does.
%
% Author: [Name]
% Date: [Date]
% Version: [Version]

function output = filename(input1, input2)
% FILENAME Brief one-line description
%
% Detailed description of the function's purpose and behavior.
%
% Syntax:
%   output = filename(input1, input2)
%
% Inputs:
%   input1 - Description of input1 (type, units, constraints)
%   input2 - Description of input2 (type, units, constraints)
%
% Outputs:
%   output - Description of output (type, units, meaning)
%
% Example:
%   result = filename(data, config);
%   % result contains processed data
%
% See also: RELATEDFUNCTION1, RELATEDFUNCTION2
%
% Requirements: [Requirement IDs if applicable]

    % Input validation
    validateattributes(input1, {'numeric'}, {'nonempty'});
    
    % Main logic
    output = processData(input1, input2);
    
    % Helper functions below
end

function result = processData(data, config)
    % Process data according to configuration
    result = data * config.factor;
end
```

### Naming Conventions

**Functions:**
- Use `camelCase`
- Start with verb
- Be descriptive

```matlab
% Good
computeMetrics()
generateLabels()
trainModel()

% Bad
metrics()
labels()
train()
```

**Classes:**
- Use `PascalCase`
- Noun or noun phrase
- Descriptive name

```matlab
% Good
LabelGenerator
ModelFactory
EvaluationEngine

% Bad
labelgen
factory
eval
```

**Variables:**
- Use `camelCase`
- Descriptive names
- Avoid abbreviations unless common

```matlab
% Good
trainDataset
validationAccuracy
confusionMatrix

% Bad
tds
valAcc
cm
```

**Constants:**
- Use `UPPER_CASE`
- Underscore separators

```matlab
% Good
MAX_EPOCHS = 50;
DEFAULT_BATCH_SIZE = 32;
LEARNING_RATE = 1e-4;

% Bad
maxEpochs = 50;
defaultBatchSize = 32;
```

### Code Formatting

**Indentation:**
- 4 spaces per level
- No tabs

**Line Length:**
- Maximum 100 characters
- Break long lines logically

```matlab
% Good
result = computeMetrics(predictions, groundTruth, ...
    classNames, options);

% Bad
result = computeMetrics(predictions, groundTruth, classNames, options);
```

**Spacing:**
- Space after commas
- Space around operators
- No space before semicolons

```matlab
% Good
x = a + b;
result = func(arg1, arg2, arg3);

% Bad
x=a+b;
result=func(arg1,arg2,arg3);
```

**Blank Lines:**
- One blank line between functions
- One blank line between logical sections
- Two blank lines between major sections

### Comments

**File Header:**
- Required for all files
- Brief and detailed description
- Author and date
- Version if applicable

**Function Documentation:**
- Required for all public functions
- Follow format shown above
- Include examples for complex functions

**Inline Comments:**
- Explain why, not what
- Above or beside code
- Complete sentences with punctuation

```matlab
% Good
% Calculate mean only for non-zero values to avoid bias
meanValue = mean(data(data > 0));

% Bad
% Calculate mean
meanValue = mean(data(data > 0));
```

**TODO Comments:**
```matlab
% TODO: Implement error handling for edge case
% FIXME: This breaks when input is empty
% NOTE: This assumes data is normalized
```

### Error Handling

**Input Validation:**
```matlab
function result = myFunction(data, config)
    % Validate inputs
    validateattributes(data, {'numeric'}, {'nonempty', 'finite'});
    validateattributes(config, {'struct'}, {'nonempty'});
    
    % Check required fields
    requiredFields = {'threshold', 'method'};
    for i = 1:length(requiredFields)
        if ~isfield(config, requiredFields{i})
            error('myFunction:MissingField', ...
                'Config must contain field: %s', requiredFields{i});
        end
    end
    
    % Process data
    result = processData(data, config);
end
```

**Try-Catch Blocks:**
```matlab
try
    % Risky operation
    result = riskyOperation(data);
    
    % Log success
    errorHandler.logInfo('Module', 'Operation successful');
    
catch ME
    % Log error
    errorHandler.logError('Module', ME.message);
    
    % Provide context
    error('myFunction:OperationFailed', ...
        'Failed to process data: %s', ME.message);
end
```

**Error Messages:**
- Use error identifiers: `'Module:ErrorType'`
- Provide helpful messages
- Include context

```matlab
% Good
error('LabelGenerator:InvalidMask', ...
    'Mask must be binary (0 or 255), got values in range [%d, %d]', ...
    min(mask(:)), max(mask(:)));

% Bad
error('Invalid mask');
```

### Classes

**Class Structure:**
```matlab
classdef MyClass < handle
    % MYCLASS Brief description
    %
    % Detailed description of the class purpose and usage.
    %
    % Properties:
    %   property1 - Description
    %   property2 - Description
    %
    % Methods:
    %   method1 - Description
    %   method2 - Description
    %
    % Example:
    %   obj = MyClass(config);
    %   result = obj.method1(data);
    
    properties (Access = private)
        property1  % Description
        property2  % Description
    end
    
    properties (Access = public)
        publicProperty  % Description
    end
    
    methods (Access = public)
        function obj = MyClass(config)
            % Constructor
            obj.property1 = config.value1;
            obj.property2 = config.value2;
        end
        
        function result = method1(obj, data)
            % METHOD1 Brief description
            result = obj.processData(data);
        end
    end
    
    methods (Access = private)
        function result = processData(obj, data)
            % Private helper method
            result = data * obj.property1;
        end
    end
    
    methods (Static)
        function result = staticMethod(input)
            % STATICMETHOD Brief description
            result = input * 2;
        end
    end
end
```

### Testing

**Test File Structure:**
```matlab
classdef test_MyComponent < matlab.unittest.TestCase
    % TEST_MYCOMPONENT Unit tests for MyComponent
    
    properties
        testData
        testConfig
    end
    
    methods (TestMethodSetup)
        function setup(testCase)
            % Setup before each test
            testCase.testData = generateTestData();
            testCase.testConfig = getDefaultConfig();
        end
    end
    
    methods (TestMethodTeardown)
        function teardown(testCase)
            % Cleanup after each test
            % (if needed)
        end
    end
    
    methods (Test)
        function testBasicFunctionality(testCase)
            % Test basic functionality
            result = myFunction(testCase.testData, testCase.testConfig);
            testCase.verifyEqual(result.status, 'success');
        end
        
        function testEdgeCase(testCase)
            % Test edge case: empty input
            result = myFunction([], testCase.testConfig);
            testCase.verifyTrue(isempty(result));
        end
        
        function testErrorHandling(testCase)
            % Test error handling
            testCase.verifyError(...
                @() myFunction('invalid', testCase.testConfig), ...
                'myFunction:InvalidInput');
        end
    end
end
```

## Best Practices

### Performance

**Preallocate Arrays:**
```matlab
% Good
results = zeros(n, 1);
for i = 1:n
    results(i) = compute(data(i));
end

% Bad
results = [];
for i = 1:n
    results(end+1) = compute(data(i));
end
```

**Vectorize When Possible:**
```matlab
% Good
results = data .* factor + offset;

% Bad
results = zeros(size(data));
for i = 1:length(data)
    results(i) = data(i) * factor + offset;
end
```

**Use Built-in Functions:**
```matlab
% Good
meanValue = mean(data);

% Bad
meanValue = sum(data) / length(data);
```

### Code Organization

**Keep Functions Small:**
- One function, one purpose
- Maximum ~50 lines
- Extract complex logic to helpers

**Avoid Deep Nesting:**
```matlab
% Good
if ~isValid(data)
    return;
end

result = processData(data);

% Bad
if isValid(data)
    result = processData(data);
end
```

**Use Early Returns:**
```matlab
% Good
function result = myFunction(data)
    if isempty(data)
        result = [];
        return;
    end
    
    result = processData(data);
end

% Bad
function result = myFunction(data)
    if ~isempty(data)
        result = processData(data);
    else
        result = [];
    end
end
```

### Documentation

**Document Public APIs:**
- All public functions
- All public class methods
- Include examples

**Keep Comments Updated:**
- Update comments when code changes
- Remove obsolete comments
- Don't comment obvious code

**Use Meaningful Names:**
```matlab
% Good
function accuracy = computeAccuracy(predictions, groundTruth)
    correctPredictions = sum(predictions == groundTruth);
    totalSamples = length(groundTruth);
    accuracy = correctPredictions / totalSamples;
end

% Bad (needs comments to understand)
function a = compute(p, g)
    c = sum(p == g);
    t = length(g);
    a = c / t;
end
```

## Code Review Checklist

Before submitting code for review:

- [ ] Code follows style guidelines
- [ ] All functions have documentation
- [ ] Complex logic has comments
- [ ] No debug code or commented-out code
- [ ] Variable names are descriptive
- [ ] No magic numbers (use named constants)
- [ ] Error handling is appropriate
- [ ] Tests are included
- [ ] Tests pass
- [ ] No warnings from MATLAB Code Analyzer

## Tools

**MATLAB Code Analyzer:**
```matlab
% Check code quality
checkcode('myfile.m')
```

**Profiler:**
```matlab
% Profile performance
profile on
myFunction(data);
profile viewer
```

**Code Coverage:**
```matlab
% Measure test coverage
import matlab.unittest.plugins.CodeCoveragePlugin
runner = TestRunner.withTextOutput;
runner.addPlugin(CodeCoveragePlugin.forFolder('src'));
results = runner.run(testsuite('tests'));
```

## References

- [MATLAB Style Guidelines](https://www.mathworks.com/matlabcentral/fileexchange/46056-matlab-style-guidelines-2-0)
- [MATLAB Best Practices](https://www.mathworks.com/help/matlab/matlab_prog/matlab-programming-best-practices.html)
- [Clean Code by Robert C. Martin](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)

---

*This guide was created as part of Task 12.5: Prepare code for release*
*Date: 2025-10-23*
*Version: 1.0*
