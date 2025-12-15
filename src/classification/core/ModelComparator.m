% ModelComparator.m - Aggregate and compare results from multiple models
%
% Copyright (c) 2025 Corrosion Analysis System Contributors
% Licensed under the MIT License (see LICENSE file in project root)
%
% This class provides utilities for comparing multiple classification models:
%   - Aggregate results from all trained models
%   - Create comparative metrics tables
%   - Identify best model per metric
%   - Generate ranking tables
%
% Requirements addressed: 5.5, 10.3

classdef ModelComparator < handle
    % ModelComparator - Aggregate and compare results from multiple models
    %
    % This class provides utilities for comparing multiple classification models:
    %   - Aggregate results from all trained models
    %   - Create comparative metrics tables
    %   - Identify best model per metric
    %   - Generate ranking tables
    %
    % Requirements addressed: 5.5, 10.3
    
    properties (Access = private)
        results         % Cell array of evaluation results
        modelNames      % Cell array of model names
        errorHandler    % ErrorHandler instance for logging
    end
    
    methods
        function obj = ModelComparator(errorHandler)
            % Constructor
            % Inputs:
            %   errorHandler - ErrorHandler instance (optional)
            %
            % Requirements: 5.5
            
            obj.results = {};
            obj.modelNames = {};
            
            % Initialize error handler
            if nargin >= 1 && ~isempty(errorHandler)
                obj.errorHandler = errorHandler;
            else
                obj.errorHandler = ErrorHandler.getInstance();
            end
            
            obj.errorHandler.logInfo('ModelComparator', 'ModelComparator initialized');
        end
        
        function addResult(obj, modelName, result)
            % Add evaluation result for a model
            % Inputs:
            %   modelName - Name of the model
            %   result - Evaluation result struct from EvaluationEngine
            %
            % Requirements: 5.5
            
            if isempty(modelName)
                error('ModelComparator:InvalidInput', 'Model name cannot be empty');
            end
            
            if ~isstruct(result)
                error('ModelComparator:InvalidInput', 'Result must be a struct');
            end
            
            % Check if model already exists
            idx = find(strcmp(obj.modelNames, modelName), 1);
            if ~isempty(idx)
                obj.errorHandler.logWarning('ModelComparator', ...
                    sprintf('Overwriting existing result for model: %s', modelName));
                obj.results{idx} = result;
            else
                obj.modelNames{end+1} = modelName;
                obj.results{end+1} = result;
                obj.errorHandler.logInfo('ModelComparator', ...
                    sprintf('Added result for model: %s', modelName));
            end
        end
        
        function loadResults(obj, resultsDir)
            % Load all evaluation results from a directory
            % Inputs:
            %   resultsDir - Directory containing *_evaluation_report.mat files
            %
            % Requirements: 5.5
            
            obj.errorHandler.logInfo('ModelComparator', ...
                sprintf('Loading results from: %s', resultsDir));
            
            if ~isfolder(resultsDir)
                error('ModelComparator:InvalidPath', ...
                    'Results directory does not exist: %s', resultsDir);
            end
            
            % Find all evaluation report files
            files = dir(fullfile(resultsDir, '*_evaluation_report.mat'));
            
            if isempty(files)
                obj.errorHandler.logWarning('ModelComparator', ...
                    'No evaluation report files found');
                return;
            end
            
            % Load each result
            for i = 1:length(files)
                filepath = fullfile(files(i).folder, files(i).name);
                
                try
                    data = load(filepath);
                    if isfield(data, 'report')
                        result = data.report;
                        modelName = result.modelName;
                        obj.addResult(modelName, result);
                    else
                        obj.errorHandler.logWarning('ModelComparator', ...
                            sprintf('File does not contain report field: %s', files(i).name));
                    end
                catch ME
                    obj.errorHandler.logError('ModelComparator', ...
                        sprintf('Failed to load file %s: %s', files(i).name, ME.message));
                end
            end
            
            obj.errorHandler.logInfo('ModelComparator', ...
                sprintf('Loaded %d model results', length(obj.modelNames)));
        end
        
        function compTable = createComparisonTable(obj)
            % Create comparative metrics table for all models
            % Output:
            %   compTable - Table with columns: Model, Accuracy, MacroF1, WeightedF1, 
            %               MeanAUC, InferenceTime, Throughput
            %
            % Requirements: 5.5, 10.3
            
            obj.errorHandler.logInfo('ModelComparator', 'Creating comparison table...');
            
            if isempty(obj.results)
                error('ModelComparator:NoResults', 'No results available for comparison');
            end
            
            numModels = length(obj.modelNames);
            
            % Initialize arrays
            accuracy = zeros(numModels, 1);
            macroF1 = zeros(numModels, 1);
            weightedF1 = zeros(numModels, 1);
            meanAUC = zeros(numModels, 1);
            inferenceTime = zeros(numModels, 1);
            throughput = zeros(numModels, 1);
            
            % Extract metrics from each result
            for i = 1:numModels
                result = obj.results{i};
                
                accuracy(i) = result.metrics.accuracy;
                macroF1(i) = result.metrics.macroF1;
                weightedF1(i) = result.metrics.weightedF1;
                meanAUC(i) = mean(result.roc.auc);
                inferenceTime(i) = result.inferenceTime;
                throughput(i) = result.throughput;
            end
            
            % Create table
            compTable = table(obj.modelNames', accuracy, macroF1, weightedF1, ...
                meanAUC, inferenceTime, throughput, ...
                'VariableNames', {'Model', 'Accuracy', 'MacroF1', 'WeightedF1', ...
                'MeanAUC', 'InferenceTime_ms', 'Throughput_imgs_per_sec'});
            
            obj.errorHandler.logInfo('ModelComparator', 'Comparison table created');
            obj.errorHandler.logInfo('ModelComparator', '=== Model Comparison ===');
            disp(compTable);
        end
        
        function bestModels = identifyBestModels(obj)
            % Identify best model for each metric
            % Output:
            %   bestModels - Struct with fields for each metric containing
            %                model name and value
            %
            % Requirements: 5.5, 10.3
            
            obj.errorHandler.logInfo('ModelComparator', 'Identifying best models per metric...');
            
            if isempty(obj.results)
                error('ModelComparator:NoResults', 'No results available for comparison');
            end
            
            numModels = length(obj.modelNames);
            
            % Extract metrics
            accuracy = zeros(numModels, 1);
            macroF1 = zeros(numModels, 1);
            weightedF1 = zeros(numModels, 1);
            meanAUC = zeros(numModels, 1);
            inferenceTime = zeros(numModels, 1);
            
            for i = 1:numModels
                result = obj.results{i};
                accuracy(i) = result.metrics.accuracy;
                macroF1(i) = result.metrics.macroF1;
                weightedF1(i) = result.metrics.weightedF1;
                meanAUC(i) = mean(result.roc.auc);
                inferenceTime(i) = result.inferenceTime;
            end
            
            % Find best models (highest is better except for inference time)
            [maxAccuracy, idxAccuracy] = max(accuracy);
            [maxMacroF1, idxMacroF1] = max(macroF1);
            [maxWeightedF1, idxWeightedF1] = max(weightedF1);
            [maxMeanAUC, idxMeanAUC] = max(meanAUC);
            [minInferenceTime, idxInferenceTime] = min(inferenceTime);
            
            % Create best models struct
            bestModels = struct();
            bestModels.accuracy = struct('model', obj.modelNames{idxAccuracy}, 'value', maxAccuracy);
            bestModels.macroF1 = struct('model', obj.modelNames{idxMacroF1}, 'value', maxMacroF1);
            bestModels.weightedF1 = struct('model', obj.modelNames{idxWeightedF1}, 'value', maxWeightedF1);
            bestModels.meanAUC = struct('model', obj.modelNames{idxMeanAUC}, 'value', maxMeanAUC);
            bestModels.inferenceTime = struct('model', obj.modelNames{idxInferenceTime}, 'value', minInferenceTime);
            
            obj.errorHandler.logInfo('ModelComparator', '=== Best Models per Metric ===');
            obj.errorHandler.logInfo('ModelComparator', ...
                sprintf('Best Accuracy: %s (%.4f)', bestModels.accuracy.model, bestModels.accuracy.value));
            obj.errorHandler.logInfo('ModelComparator', ...
                sprintf('Best Macro F1: %s (%.4f)', bestModels.macroF1.model, bestModels.macroF1.value));
            obj.errorHandler.logInfo('ModelComparator', ...
                sprintf('Best Weighted F1: %s (%.4f)', bestModels.weightedF1.model, bestModels.weightedF1.value));
            obj.errorHandler.logInfo('ModelComparator', ...
                sprintf('Best Mean AUC: %s (%.4f)', bestModels.meanAUC.model, bestModels.meanAUC.value));
            obj.errorHandler.logInfo('ModelComparator', ...
                sprintf('Fastest Inference: %s (%.2f ms)', bestModels.inferenceTime.model, bestModels.inferenceTime.value));
        end
        
        function rankingTable = generateRankingTable(obj)
            % Generate ranking table showing model ranks for each metric
            % Output:
            %   rankingTable - Table with model names and ranks (1=best)
            %
            % Requirements: 5.5, 10.3
            
            obj.errorHandler.logInfo('ModelComparator', 'Generating ranking table...');
            
            if isempty(obj.results)
                error('ModelComparator:NoResults', 'No results available for ranking');
            end
            
            numModels = length(obj.modelNames);
            
            % Extract metrics
            accuracy = zeros(numModels, 1);
            macroF1 = zeros(numModels, 1);
            weightedF1 = zeros(numModels, 1);
            meanAUC = zeros(numModels, 1);
            inferenceTime = zeros(numModels, 1);
            
            for i = 1:numModels
                result = obj.results{i};
                accuracy(i) = result.metrics.accuracy;
                macroF1(i) = result.metrics.macroF1;
                weightedF1(i) = result.metrics.weightedF1;
                meanAUC(i) = mean(result.roc.auc);
                inferenceTime(i) = result.inferenceTime;
            end
            
            % Compute ranks (1 = best)
            % For accuracy, F1, AUC: higher is better
            % For inference time: lower is better
            [~, rankAccuracy] = sort(accuracy, 'descend');
            [~, rankMacroF1] = sort(macroF1, 'descend');
            [~, rankWeightedF1] = sort(weightedF1, 'descend');
            [~, rankMeanAUC] = sort(meanAUC, 'descend');
            [~, rankInferenceTime] = sort(inferenceTime, 'ascend');
            
            % Create rank arrays (convert indices to ranks)
            accuracyRank = zeros(numModels, 1);
            macroF1Rank = zeros(numModels, 1);
            weightedF1Rank = zeros(numModels, 1);
            meanAUCRank = zeros(numModels, 1);
            inferenceTimeRank = zeros(numModels, 1);
            
            for i = 1:numModels
                accuracyRank(rankAccuracy(i)) = i;
                macroF1Rank(rankMacroF1(i)) = i;
                weightedF1Rank(rankWeightedF1(i)) = i;
                meanAUCRank(rankMeanAUC(i)) = i;
                inferenceTimeRank(rankInferenceTime(i)) = i;
            end
            
            % Compute average rank
            avgRank = (accuracyRank + macroF1Rank + weightedF1Rank + meanAUCRank + inferenceTimeRank) / 5;
            
            % Create ranking table
            rankingTable = table(obj.modelNames', accuracyRank, macroF1Rank, ...
                weightedF1Rank, meanAUCRank, inferenceTimeRank, avgRank, ...
                'VariableNames', {'Model', 'AccuracyRank', 'MacroF1Rank', ...
                'WeightedF1Rank', 'MeanAUCRank', 'InferenceTimeRank', 'AverageRank'});
            
            % Sort by average rank
            rankingTable = sortrows(rankingTable, 'AverageRank');
            
            obj.errorHandler.logInfo('ModelComparator', 'Ranking table generated');
            obj.errorHandler.logInfo('ModelComparator', '=== Model Rankings ===');
            disp(rankingTable);
        end
        
        function saveComparison(obj, outputDir, filename)
            % Save comparison results to file
            % Inputs:
            %   outputDir - Directory to save results
            %   filename - Base filename (without extension)
            %
            % Requirements: 5.5
            
            if nargin < 3
                filename = 'model_comparison';
            end
            
            obj.errorHandler.logInfo('ModelComparator', ...
                sprintf('Saving comparison results to: %s', outputDir));
            
            if ~isfolder(outputDir)
                mkdir(outputDir);
            end
            
            try
                % Create comparison table
                compTable = obj.createComparisonTable();
                
                % Identify best models
                bestModels = obj.identifyBestModels();
                
                % Generate ranking table
                rankingTable = obj.generateRankingTable();
                
                % Save to MAT file
                matPath = fullfile(outputDir, [filename '.mat']);
                save(matPath, 'compTable', 'bestModels', 'rankingTable', '-v7.3');
                obj.errorHandler.logInfo('ModelComparator', ...
                    sprintf('Comparison saved to MAT file: %s', matPath));
                
                % Save to text file
                txtPath = fullfile(outputDir, [filename '.txt']);
                obj.saveComparisonAsText(compTable, bestModels, rankingTable, txtPath);
                
                % Save to CSV files
                csvPath1 = fullfile(outputDir, [filename '_metrics.csv']);
                writetable(compTable, csvPath1);
                obj.errorHandler.logInfo('ModelComparator', ...
                    sprintf('Metrics table saved to CSV: %s', csvPath1));
                
                csvPath2 = fullfile(outputDir, [filename '_rankings.csv']);
                writetable(rankingTable, csvPath2);
                obj.errorHandler.logInfo('ModelComparator', ...
                    sprintf('Rankings table saved to CSV: %s', csvPath2));
                
            catch ME
                obj.errorHandler.logError('ModelComparator', ...
                    sprintf('Failed to save comparison: %s', ME.message));
                rethrow(ME);
            end
        end
    end
    
    methods (Access = private)
        function saveComparisonAsText(obj, compTable, bestModels, rankingTable, filepath)
            % Save comparison results as text file
            % Inputs:
            %   compTable - Comparison table
            %   bestModels - Best models struct
            %   rankingTable - Ranking table
            %   filepath - Path to save text file
            
            try
                fid = fopen(filepath, 'w');
                if fid == -1
                    error('Cannot open file: %s', filepath);
                end
                
                % Write header
                fprintf(fid, '=================================================\n');
                fprintf(fid, 'MODEL COMPARISON REPORT\n');
                fprintf(fid, '=================================================\n\n');
                fprintf(fid, 'Generated: %s\n', char(datetime('now')));
                fprintf(fid, 'Number of models: %d\n\n', length(obj.modelNames));
                
                % Write comparison table
                fprintf(fid, '=== Comparative Metrics ===\n\n');
                fprintf(fid, '%-20s %10s %10s %10s %10s %15s %20s\n', ...
                    'Model', 'Accuracy', 'MacroF1', 'WeightF1', 'MeanAUC', 'Time(ms)', 'Throughput(img/s)');
                fprintf(fid, '%s\n', repmat('-', 1, 110));
                
                for i = 1:height(compTable)
                    fprintf(fid, '%-20s %10.4f %10.4f %10.4f %10.4f %15.2f %20.2f\n', ...
                        compTable.Model{i}, compTable.Accuracy(i), compTable.MacroF1(i), ...
                        compTable.WeightedF1(i), compTable.MeanAUC(i), ...
                        compTable.InferenceTime_ms(i), compTable.Throughput_imgs_per_sec(i));
                end
                fprintf(fid, '\n');
                
                % Write best models
                fprintf(fid, '=== Best Models per Metric ===\n\n');
                fprintf(fid, 'Best Accuracy:       %s (%.4f)\n', bestModels.accuracy.model, bestModels.accuracy.value);
                fprintf(fid, 'Best Macro F1:       %s (%.4f)\n', bestModels.macroF1.model, bestModels.macroF1.value);
                fprintf(fid, 'Best Weighted F1:    %s (%.4f)\n', bestModels.weightedF1.model, bestModels.weightedF1.value);
                fprintf(fid, 'Best Mean AUC:       %s (%.4f)\n', bestModels.meanAUC.model, bestModels.meanAUC.value);
                fprintf(fid, 'Fastest Inference:   %s (%.2f ms)\n', bestModels.inferenceTime.model, bestModels.inferenceTime.value);
                fprintf(fid, '\n');
                
                % Write ranking table
                fprintf(fid, '=== Model Rankings (1=Best) ===\n\n');
                fprintf(fid, '%-20s %12s %12s %12s %12s %15s %12s\n', ...
                    'Model', 'AccuracyRnk', 'MacroF1Rnk', 'WeightF1Rnk', 'MeanAUCRnk', 'InferTimeRnk', 'AvgRank');
                fprintf(fid, '%s\n', repmat('-', 1, 110));
                
                for i = 1:height(rankingTable)
                    fprintf(fid, '%-20s %12d %12d %12d %12d %15d %12.2f\n', ...
                        rankingTable.Model{i}, rankingTable.AccuracyRank(i), ...
                        rankingTable.MacroF1Rank(i), rankingTable.WeightedF1Rank(i), ...
                        rankingTable.MeanAUCRank(i), rankingTable.InferenceTimeRank(i), ...
                        rankingTable.AverageRank(i));
                end
                fprintf(fid, '\n');
                
                % Write summary
                fprintf(fid, '=== Summary ===\n\n');
                [~, bestOverallIdx] = min(rankingTable.AverageRank);
                fprintf(fid, 'Best Overall Model (by average rank): %s\n', rankingTable.Model{bestOverallIdx});
                fprintf(fid, 'Average Rank: %.2f\n', rankingTable.AverageRank(bestOverallIdx));
                
                fclose(fid);
                
                obj.errorHandler.logInfo('ModelComparator', ...
                    sprintf('Text report saved: %s', filepath));
                
            catch ME
                if fid ~= -1
                    fclose(fid);
                end
                obj.errorHandler.logError('ModelComparator', ...
                    sprintf('Failed to save text report: %s', ME.message));
            end
        end
    end
end
