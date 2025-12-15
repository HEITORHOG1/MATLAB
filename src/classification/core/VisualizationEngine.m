% VisualizationEngine.m - Publication-quality figure generation and LaTeX export
%
% Copyright (c) 2025 Corrosion Analysis System Contributors
% Licensed under the MIT License (see LICENSE file in project root)
%
% This class provides static methods for generating publication-quality
% visualizations and LaTeX tables for classification results.
%
% Features:
%   - Confusion matrix heatmaps with percentage annotations
%   - Training curves comparison (loss and accuracy)
%   - ROC curves with AUC scores
%   - Inference time comparison bar charts
%   - LaTeX table generation for metrics and confusion matrices
%   - Batch figure export in multiple formats (PNG, PDF)
%
% Requirements addressed: 6.1, 6.2, 6.3, 6.4, 6.5, 7.2, 9.1, 9.2, 9.3

classdef VisualizationEngine < handle
    % VisualizationEngine - Publication-quality figure generation and LaTeX export
    %
    % This class provides static methods for generating publication-quality
    % visualizations and LaTeX tables for classification results.
    %
    % Features:
    %   - Confusion matrix heatmaps with percentage annotations
    %   - Training curves comparison (loss and accuracy)
    %   - ROC curves with AUC scores
    %   - Inference time comparison bar charts
    %   - LaTeX table generation for metrics and confusion matrices
    %   - Batch figure export in multiple formats (PNG, PDF)
    %
    % Requirements addressed: 6.1, 6.2, 6.3, 6.4, 6.5, 7.2, 9.1, 9.2, 9.3
    
    properties (Constant)
        % Figure specifications for publication quality
        FIGURE_DPI = 300;
        CONFUSION_MATRIX_SIZE = [8, 6]; % inches
        TRAINING_CURVES_SIZE = [10, 6]; % inches
        ROC_CURVES_SIZE = [8, 6]; % inches
        INFERENCE_COMPARISON_SIZE = [8, 6]; % inches
        
        % Color schemes
        COLORMAP_CONFUSION = 'Blues';
        REALTIME_THRESHOLD = 33.33; % ms for 30 fps
    end
    
    methods (Static)
        
        function figHandle = plotConfusionMatrix(confMat, classNames, outputPath, modelName)
            % Plot confusion matrix as heatmap with percentage annotations
            % Inputs:
            %   confMat - Confusion matrix (rows=true, cols=predicted)
            %   classNames - Cell array of class names
            %   outputPath - Path to save figure (without extension)
            %   modelName - Name of model for title (optional)
            % Output:
            %   figHandle - Figure handle
            %
            % Requirements: 6.1
            
            if nargin < 4
                modelName = 'Model';
            end
            
            errorHandler = ErrorHandler.getInstance();
            errorHandler.logInfo('VisualizationEngine', ...
                sprintf('Plotting confusion matrix for %s...', modelName));
            
            try
                % Normalize confusion matrix to percentages
                rowSums = sum(confMat, 2);
                normalizedConfMat = confMat ./ rowSums * 100;
                normalizedConfMat(isnan(normalizedConfMat)) = 0;
                
                % Create figure with specified size
                figHandle = figure('Units', 'inches', ...
                    'Position', [1, 1, VisualizationEngine.CONFUSION_MATRIX_SIZE], ...
                    'Color', 'white', ...
                    'Visible', 'off');
                
                % Create heatmap
                imagesc(normalizedConfMat);
                colormap(VisualizationEngine.COLORMAP_CONFUSION);
                colorbar;
                
                % Set axis properties
                axis square;
                set(gca, 'XTick', 1:length(classNames), ...
                    'XTickLabel', classNames, ...
                    'YTick', 1:length(classNames), ...
                    'YTickLabel', classNames, ...
                    'FontSize', 11, ...
                    'FontName', 'Arial');
                
                % Add labels
                xlabel('Predicted Class', 'FontSize', 12, 'FontWeight', 'bold');
                ylabel('True Class', 'FontSize', 12, 'FontWeight', 'bold');
                title(sprintf('Confusion Matrix - %s', modelName), ...
                    'FontSize', 14, 'FontWeight', 'bold');
                
                % Add percentage annotations to each cell
                for i = 1:length(classNames)
                    for j = 1:length(classNames)
                        % Determine text color based on background intensity
                        if normalizedConfMat(i, j) > 50
                            textColor = 'white';
                        else
                            textColor = 'black';
                        end
                        
                        % Add text annotation
                        text(j, i, sprintf('%.1f%%\n(%d)', ...
                            normalizedConfMat(i, j), confMat(i, j)), ...
                            'HorizontalAlignment', 'center', ...
                            'VerticalAlignment', 'middle', ...
                            'Color', textColor, ...
                            'FontSize', 10, ...
                            'FontWeight', 'bold');
                    end
                end
                
                % Adjust layout
                set(gca, 'TickLength', [0 0]);
                
                % Export figure
                if nargin >= 3 && ~isempty(outputPath)
                    VisualizationEngine.exportFigure(figHandle, outputPath);
                    errorHandler.logInfo('VisualizationEngine', ...
                        sprintf('Confusion matrix saved: %s', outputPath));
                end
                
            catch ME
                errorHandler.logError('VisualizationEngine', ...
                    sprintf('Failed to plot confusion matrix: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function figHandle = plotTrainingCurves(histories, modelNames, outputPath)
            % Plot training curves comparison (loss and accuracy)
            % Inputs:
            %   histories - Cell array of training history structs
            %   modelNames - Cell array of model names
            %   outputPath - Path to save figure (without extension)
            % Output:
            %   figHandle - Figure handle
            %
            % Requirements: 6.2
            
            errorHandler = ErrorHandler.getInstance();
            errorHandler.logInfo('VisualizationEngine', ...
                'Plotting training curves comparison...');
            
            try
                % Create figure with specified size
                figHandle = figure('Units', 'inches', ...
                    'Position', [1, 1, VisualizationEngine.TRAINING_CURVES_SIZE], ...
                    'Color', 'white', ...
                    'Visible', 'off');
                
                % Define colors for different models
                colors = lines(length(modelNames));
                
                % Subplot 1: Loss curves
                subplot(1, 2, 1);
                hold on;
                grid on;
                
                for i = 1:length(histories)
                    history = histories{i};
                    
                    % Plot training loss (solid line)
                    plot(history.epoch, history.trainLoss, ...
                        '-', 'LineWidth', 2, 'Color', colors(i, :), ...
                        'DisplayName', sprintf('%s (Train)', modelNames{i}));
                    
                    % Plot validation loss (dashed line)
                    plot(history.epoch, history.valLoss, ...
                        '--', 'LineWidth', 2, 'Color', colors(i, :), ...
                        'DisplayName', sprintf('%s (Val)', modelNames{i}));
                end
                
                xlabel('Epoch', 'FontSize', 11, 'FontWeight', 'bold');
                ylabel('Loss', 'FontSize', 11, 'FontWeight', 'bold');
                title('Training and Validation Loss', 'FontSize', 12, 'FontWeight', 'bold');
                legend('Location', 'best', 'FontSize', 9);
                set(gca, 'FontSize', 10, 'FontName', 'Arial');
                hold off;
                
                % Subplot 2: Accuracy curves
                subplot(1, 2, 2);
                hold on;
                grid on;
                
                for i = 1:length(histories)
                    history = histories{i};
                    
                    % Plot training accuracy (solid line)
                    plot(history.epoch, history.trainAccuracy * 100, ...
                        '-', 'LineWidth', 2, 'Color', colors(i, :), ...
                        'DisplayName', sprintf('%s (Train)', modelNames{i}));
                    
                    % Plot validation accuracy (dashed line)
                    plot(history.epoch, history.valAccuracy * 100, ...
                        '--', 'LineWidth', 2, 'Color', colors(i, :), ...
                        'DisplayName', sprintf('%s (Val)', modelNames{i}));
                end
                
                xlabel('Epoch', 'FontSize', 11, 'FontWeight', 'bold');
                ylabel('Accuracy (%)', 'FontSize', 11, 'FontWeight', 'bold');
                title('Training and Validation Accuracy', 'FontSize', 12, 'FontWeight', 'bold');
                legend('Location', 'best', 'FontSize', 9);
                set(gca, 'FontSize', 10, 'FontName', 'Arial');
                hold off;
                
                % Adjust layout
                sgtitle('Model Training Comparison', 'FontSize', 14, 'FontWeight', 'bold');
                
                % Export figure
                if nargin >= 3 && ~isempty(outputPath)
                    VisualizationEngine.exportFigure(figHandle, outputPath);
                    errorHandler.logInfo('VisualizationEngine', ...
                        sprintf('Training curves saved: %s', outputPath));
                end
                
            catch ME
                errorHandler.logError('VisualizationEngine', ...
                    sprintf('Failed to plot training curves: %s', ME.message));
                rethrow(ME);
            end
        end
        
        
        function figHandle = plotROCCurves(rocData, classNames, outputPath, modelName)
            % Plot ROC curves with AUC scores
            % Inputs:
            %   rocData - Struct with fields: fpr (cell), tpr (cell), auc (array)
            %   classNames - Cell array of class names
            %   outputPath - Path to save figure (without extension)
            %   modelName - Name of model for title (optional)
            % Output:
            %   figHandle - Figure handle
            %
            % Requirements: 6.3
            
            if nargin < 4
                modelName = 'Model';
            end
            
            errorHandler = ErrorHandler.getInstance();
            errorHandler.logInfo('VisualizationEngine', ...
                sprintf('Plotting ROC curves for %s...', modelName));
            
            try
                % Create figure with specified size
                figHandle = figure('Units', 'inches', ...
                    'Position', [1, 1, VisualizationEngine.ROC_CURVES_SIZE], ...
                    'Color', 'white', ...
                    'Visible', 'off');
                
                hold on;
                grid on;
                
                % Define colors for different classes
                colors = lines(length(classNames));
                
                % Plot ROC curve for each class
                for i = 1:length(classNames)
                    plot(rocData.fpr{i}, rocData.tpr{i}, ...
                        '-', 'LineWidth', 2, 'Color', colors(i, :), ...
                        'DisplayName', sprintf('%s (AUC = %.3f)', ...
                        classNames{i}, rocData.auc(i)));
                end
                
                % Plot diagonal reference line (random classifier)
                plot([0, 1], [0, 1], 'k--', 'LineWidth', 1.5, ...
                    'DisplayName', 'Random Classifier');
                
                % Set axis properties
                xlabel('False Positive Rate', 'FontSize', 12, 'FontWeight', 'bold');
                ylabel('True Positive Rate', 'FontSize', 12, 'FontWeight', 'bold');
                title(sprintf('ROC Curves - %s (Mean AUC = %.3f)', ...
                    modelName, mean(rocData.auc)), ...
                    'FontSize', 14, 'FontWeight', 'bold');
                
                legend('Location', 'southeast', 'FontSize', 10);
                set(gca, 'FontSize', 11, 'FontName', 'Arial');
                axis square;
                xlim([0, 1]);
                ylim([0, 1]);
                
                hold off;
                
                % Export figure
                if nargin >= 3 && ~isempty(outputPath)
                    VisualizationEngine.exportFigure(figHandle, outputPath);
                    errorHandler.logInfo('VisualizationEngine', ...
                        sprintf('ROC curves saved: %s', outputPath));
                end
                
            catch ME
                errorHandler.logError('VisualizationEngine', ...
                    sprintf('Failed to plot ROC curves: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function figHandle = plotInferenceComparison(times, modelNames, outputPath)
            % Plot inference time comparison bar chart
            % Inputs:
            %   times - Array of inference times in milliseconds
            %   modelNames - Cell array of model names
            %   outputPath - Path to save figure (without extension)
            % Output:
            %   figHandle - Figure handle
            %
            % Requirements: 6.4
            
            errorHandler = ErrorHandler.getInstance();
            errorHandler.logInfo('VisualizationEngine', ...
                'Plotting inference time comparison...');
            
            try
                % Create figure with specified size
                figHandle = figure('Units', 'inches', ...
                    'Position', [1, 1, VisualizationEngine.INFERENCE_COMPARISON_SIZE], ...
                    'Color', 'white', ...
                    'Visible', 'off');
                
                % Create bar chart
                bar(times, 'FaceColor', [0.2, 0.4, 0.8], 'EdgeColor', 'black', 'LineWidth', 1.5);
                
                % Add horizontal line for real-time threshold (30 fps = 33.33 ms)
                hold on;
                yline(VisualizationEngine.REALTIME_THRESHOLD, 'r--', ...
                    sprintf('Real-time threshold (%.1f ms)', VisualizationEngine.REALTIME_THRESHOLD), ...
                    'LineWidth', 2, 'FontSize', 10, 'LabelHorizontalAlignment', 'left');
                
                % Add value labels on top of bars
                for i = 1:length(times)
                    text(i, times(i) + max(times) * 0.02, sprintf('%.2f ms', times(i)), ...
                        'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'bottom', ...
                        'FontSize', 10, ...
                        'FontWeight', 'bold');
                end
                
                % Set axis properties
                set(gca, 'XTick', 1:length(modelNames), ...
                    'XTickLabel', modelNames, ...
                    'FontSize', 11, ...
                    'FontName', 'Arial');
                
                xlabel('Model', 'FontSize', 12, 'FontWeight', 'bold');
                ylabel('Inference Time (ms)', 'FontSize', 12, 'FontWeight', 'bold');
                title('Inference Time Comparison', 'FontSize', 14, 'FontWeight', 'bold');
                
                grid on;
                ylim([0, max(times) * 1.15]);
                
                hold off;
                
                % Export figure
                if nargin >= 3 && ~isempty(outputPath)
                    VisualizationEngine.exportFigure(figHandle, outputPath);
                    errorHandler.logInfo('VisualizationEngine', ...
                        sprintf('Inference comparison saved: %s', outputPath));
                end
                
            catch ME
                errorHandler.logError('VisualizationEngine', ...
                    sprintf('Failed to plot inference comparison: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function generateLatexTable(data, tableType, outputPath, varargin)
            % Generate LaTeX table from data
            % Inputs:
            %   data - Data struct or matrix
            %   tableType - Type of table: 'metrics', 'confusion', 'summary'
            %   outputPath - Path to save LaTeX file
            %   varargin - Additional parameters (modelNames, classNames, etc.)
            %
            % Requirements: 9.1, 9.2, 9.3
            
            errorHandler = ErrorHandler.getInstance();
            errorHandler.logInfo('VisualizationEngine', ...
                sprintf('Generating LaTeX table: %s', tableType));
            
            try
                switch lower(tableType)
                    case 'metrics'
                        VisualizationEngine.generateMetricsTable(data, outputPath, varargin{:});
                    case 'confusion'
                        VisualizationEngine.generateConfusionTable(data, outputPath, varargin{:});
                    case 'summary'
                        VisualizationEngine.generateSummaryDocument(data, outputPath, varargin{:});
                    otherwise
                        error('VisualizationEngine:InvalidTableType', ...
                            'Unknown table type: %s', tableType);
                end
                
                errorHandler.logInfo('VisualizationEngine', ...
                    sprintf('LaTeX table saved: %s', outputPath));
                
            catch ME
                errorHandler.logError('VisualizationEngine', ...
                    sprintf('Failed to generate LaTeX table: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function exportAllFigures(figHandles, outputDir, baseName)
            % Export all figures in multiple formats
            % Inputs:
            %   figHandles - Array of figure handles or cell array
            %   outputDir - Directory to save figures
            %   baseName - Base name for files (optional)
            %
            % Requirements: 6.5
            
            if nargin < 3
                baseName = 'figure';
            end
            
            errorHandler = ErrorHandler.getInstance();
            errorHandler.logInfo('VisualizationEngine', ...
                sprintf('Exporting %d figures to %s...', length(figHandles), outputDir));
            
            try
                % Create output directory if it doesn't exist
                if ~exist(outputDir, 'dir')
                    mkdir(outputDir);
                end
                
                % Convert to cell array if needed
                if ~iscell(figHandles)
                    figHandles = num2cell(figHandles);
                end
                
                % Export each figure
                for i = 1:length(figHandles)
                    figHandle = figHandles{i};
                    
                    if isempty(figHandle) || ~isvalid(figHandle)
                        errorHandler.logWarning('VisualizationEngine', ...
                            sprintf('Skipping invalid figure handle at index %d', i));
                        continue;
                    end
                    
                    % Generate filename
                    if length(figHandles) == 1
                        filename = baseName;
                    else
                        filename = sprintf('%s_%d', baseName, i);
                    end
                    
                    outputPath = fullfile(outputDir, filename);
                    VisualizationEngine.exportFigure(figHandle, outputPath);
                end
                
                errorHandler.logInfo('VisualizationEngine', ...
                    sprintf('Successfully exported %d figures', length(figHandles)));
                
            catch ME
                errorHandler.logError('VisualizationEngine', ...
                    sprintf('Failed to export figures: %s', ME.message));
                rethrow(ME);
            end
        end
        
    end
    
    methods (Static, Access = private)
        
        function exportFigure(figHandle, outputPath)
            % Export figure in PNG (300 DPI) and PDF (vector) formats
            % Inputs:
            %   figHandle - Figure handle
            %   outputPath - Path without extension
            
            errorHandler = ErrorHandler.getInstance();
            
            try
                % Export as PNG (300 DPI)
                pngPath = [outputPath, '.png'];
                print(figHandle, pngPath, '-dpng', ...
                    sprintf('-r%d', VisualizationEngine.FIGURE_DPI));
                errorHandler.logDebug('VisualizationEngine', ...
                    sprintf('PNG exported: %s', pngPath));
                
                % Export as PDF (vector)
                pdfPath = [outputPath, '.pdf'];
                print(figHandle, pdfPath, '-dpdf', '-bestfit');
                errorHandler.logDebug('VisualizationEngine', ...
                    sprintf('PDF exported: %s', pdfPath));
                
            catch ME
                errorHandler.logError('VisualizationEngine', ...
                    sprintf('Failed to export figure: %s', ME.message));
                rethrow(ME);
            end
        end
        
        
        function generateMetricsTable(reports, outputPath, modelNames)
            % Generate LaTeX table for metrics comparison
            % Inputs:
            %   reports - Cell array of evaluation report structs
            %   outputPath - Path to save LaTeX file
            %   modelNames - Cell array of model names
            
            errorHandler = ErrorHandler.getInstance();
            
            try
                fid = fopen(outputPath, 'w');
                if fid == -1
                    error('Cannot open file: %s', outputPath);
                end
                
                % Write LaTeX table header
                fprintf(fid, '\\begin{table}[htbp]\n');
                fprintf(fid, '\\centering\n');
                fprintf(fid, '\\caption{Classification Model Performance Comparison}\n');
                fprintf(fid, '\\label{tab:classification_metrics}\n');
                fprintf(fid, '\\begin{tabular}{lcccccc}\n');
                fprintf(fid, '\\toprule\n');
                fprintf(fid, 'Model & Accuracy & Macro F1 & Weighted F1 & Mean AUC & Inference Time (ms) & Throughput (img/s) \\\\\n');
                fprintf(fid, '\\midrule\n');
                
                % Write data rows
                for i = 1:length(reports)
                    report = reports{i};
                    fprintf(fid, '%s & %.4f & %.4f & %.4f & %.4f & %.2f & %.2f \\\\\n', ...
                        modelNames{i}, ...
                        report.metrics.accuracy, ...
                        report.metrics.macroF1, ...
                        report.metrics.weightedF1, ...
                        mean(report.roc.auc), ...
                        report.inferenceTime, ...
                        report.throughput);
                end
                
                fprintf(fid, '\\bottomrule\n');
                fprintf(fid, '\\end{tabular}\n');
                fprintf(fid, '\\end{table}\n');
                
                fclose(fid);
                
                errorHandler.logInfo('VisualizationEngine', ...
                    sprintf('Metrics table generated: %s', outputPath));
                
            catch ME
                if exist('fid', 'var') && fid ~= -1
                    fclose(fid);
                end
                rethrow(ME);
            end
        end
        
        function generateConfusionTable(confMat, outputPath, classNames, modelName)
            % Generate LaTeX table for confusion matrix
            % Inputs:
            %   confMat - Confusion matrix
            %   outputPath - Path to save LaTeX file
            %   classNames - Cell array of class names
            %   modelName - Name of model
            
            errorHandler = ErrorHandler.getInstance();
            
            try
                fid = fopen(outputPath, 'w');
                if fid == -1
                    error('Cannot open file: %s', outputPath);
                end
                
                % Normalize confusion matrix to percentages
                rowSums = sum(confMat, 2);
                normalizedConfMat = confMat ./ rowSums * 100;
                normalizedConfMat(isnan(normalizedConfMat)) = 0;
                
                % Write LaTeX table header
                fprintf(fid, '\\begin{table}[htbp]\n');
                fprintf(fid, '\\centering\n');
                fprintf(fid, '\\caption{Confusion Matrix - %s}\n', modelName);
                fprintf(fid, '\\label{tab:confusion_%s}\n', matlab.lang.makeValidName(modelName));
                
                % Create column specification
                colSpec = 'l';
                for i = 1:length(classNames)
                    colSpec = [colSpec, 'c'];
                end
                
                fprintf(fid, '\\begin{tabular}{%s}\n', colSpec);
                fprintf(fid, '\\toprule\n');
                
                % Write header row
                fprintf(fid, 'True / Predicted');
                for i = 1:length(classNames)
                    fprintf(fid, ' & %s', classNames{i});
                end
                fprintf(fid, ' \\\\\n');
                fprintf(fid, '\\midrule\n');
                
                % Write data rows
                for i = 1:length(classNames)
                    fprintf(fid, '%s', classNames{i});
                    for j = 1:length(classNames)
                        fprintf(fid, ' & %.1f\\%% (%d)', ...
                            normalizedConfMat(i, j), confMat(i, j));
                    end
                    fprintf(fid, ' \\\\\n');
                end
                
                fprintf(fid, '\\bottomrule\n');
                fprintf(fid, '\\end{tabular}\n');
                fprintf(fid, '\\end{table}\n');
                
                fclose(fid);
                
                errorHandler.logInfo('VisualizationEngine', ...
                    sprintf('Confusion matrix table generated: %s', outputPath));
                
            catch ME
                if exist('fid', 'var') && fid ~= -1
                    fclose(fid);
                end
                rethrow(ME);
            end
        end
        
        function generateSummaryDocument(reports, outputPath, modelNames, classNames)
            % Generate LaTeX summary document with figure captions
            % Inputs:
            %   reports - Cell array of evaluation report structs
            %   outputPath - Path to save LaTeX file
            %   modelNames - Cell array of model names
            %   classNames - Cell array of class names
            
            errorHandler = ErrorHandler.getInstance();
            
            try
                fid = fopen(outputPath, 'w');
                if fid == -1
                    error('Cannot open file: %s', outputPath);
                end
                
                % Write document header
                fprintf(fid, '%% Classification Results Summary\n');
                fprintf(fid, '%% Generated: %s\n\n', char(datetime('now')));
                
                fprintf(fid, '\\section{Classification Results}\n\n');
                
                % Overall summary
                fprintf(fid, '\\subsection{Overview}\n\n');
                fprintf(fid, 'This section presents the results of the corrosion severity classification system.\n');
                fprintf(fid, 'We evaluated %d different model architectures: %s.\n', ...
                    length(modelNames), strjoin(modelNames, ', '));
                fprintf(fid, 'The classification task involves categorizing corrosion into %d severity classes: %s.\n\n', ...
                    length(classNames), strjoin(classNames, ', '));
                
                % Model comparison
                fprintf(fid, '\\subsection{Model Performance Comparison}\n\n');
                fprintf(fid, 'Table~\\ref{tab:classification_metrics} presents a comprehensive comparison of all evaluated models.\n');
                fprintf(fid, 'The metrics include overall accuracy, macro-averaged F1 score, weighted F1 score, mean AUC, and inference time.\n\n');
                
                % Find best model for each metric
                accuracies = cellfun(@(r) r.metrics.accuracy, reports);
                [~, bestAccIdx] = max(accuracies);
                
                f1Scores = cellfun(@(r) r.metrics.macroF1, reports);
                [~, bestF1Idx] = max(f1Scores);
                
                inferenceTimes = cellfun(@(r) r.inferenceTime, reports);
                [~, fastestIdx] = min(inferenceTimes);
                
                fprintf(fid, 'Key findings:\n');
                fprintf(fid, '\\begin{itemize}\n');
                fprintf(fid, '  \\item Best accuracy: %s (%.2f\\%%)\n', ...
                    modelNames{bestAccIdx}, accuracies(bestAccIdx) * 100);
                fprintf(fid, '  \\item Best F1 score: %s (%.4f)\n', ...
                    modelNames{bestF1Idx}, f1Scores(bestF1Idx));
                fprintf(fid, '  \\item Fastest inference: %s (%.2f ms)\n', ...
                    modelNames{fastestIdx}, inferenceTimes(fastestIdx));
                fprintf(fid, '\\end{itemize}\n\n');
                
                % Figure captions
                fprintf(fid, '\\subsection{Visualizations}\n\n');
                
                fprintf(fid, '\\begin{figure}[htbp]\n');
                fprintf(fid, '  \\centering\n');
                fprintf(fid, '  \\includegraphics[width=0.8\\textwidth]{figures/training_curves_comparison.pdf}\n');
                fprintf(fid, '  \\caption{Training and validation curves for all models. ');
                fprintf(fid, 'Solid lines represent training metrics, while dashed lines represent validation metrics. ');
                fprintf(fid, 'The curves show the convergence behavior and potential overfitting of each model.}\n');
                fprintf(fid, '  \\label{fig:training_curves}\n');
                fprintf(fid, '\\end{figure}\n\n');
                
                for i = 1:length(modelNames)
                    fprintf(fid, '\\begin{figure}[htbp]\n');
                    fprintf(fid, '  \\centering\n');
                    fprintf(fid, '  \\includegraphics[width=0.7\\textwidth]{figures/confusion_matrix_%s.pdf}\n', ...
                        matlab.lang.makeValidName(modelNames{i}));
                    fprintf(fid, '  \\caption{Confusion matrix for %s. ', modelNames{i});
                    fprintf(fid, 'Each cell shows the percentage and count of predictions. ');
                    fprintf(fid, 'Rows represent true classes, columns represent predicted classes.}\n');
                    fprintf(fid, '  \\label{fig:confusion_%s}\n', matlab.lang.makeValidName(modelNames{i}));
                    fprintf(fid, '\\end{figure}\n\n');
                end
                
                fprintf(fid, '\\begin{figure}[htbp]\n');
                fprintf(fid, '  \\centering\n');
                fprintf(fid, '  \\includegraphics[width=0.8\\textwidth]{figures/roc_curves_comparison.pdf}\n');
                fprintf(fid, '  \\caption{ROC curves for all models showing the trade-off between true positive rate and false positive rate. ');
                fprintf(fid, 'The area under the curve (AUC) quantifies the overall classification performance.}\n');
                fprintf(fid, '  \\label{fig:roc_curves}\n');
                fprintf(fid, '\\end{figure}\n\n');
                
                fprintf(fid, '\\begin{figure}[htbp]\n');
                fprintf(fid, '  \\centering\n');
                fprintf(fid, '  \\includegraphics[width=0.7\\textwidth]{figures/inference_time_comparison.pdf}\n');
                fprintf(fid, '  \\caption{Inference time comparison across models. ');
                fprintf(fid, 'The red dashed line indicates the real-time threshold (%.1f ms for 30 fps). ', ...
                    VisualizationEngine.REALTIME_THRESHOLD);
                fprintf(fid, 'Models below this threshold can process video in real-time.}\n');
                fprintf(fid, '  \\label{fig:inference_time}\n');
                fprintf(fid, '\\end{figure}\n\n');
                
                % Per-class analysis
                fprintf(fid, '\\subsection{Per-Class Performance}\n\n');
                fprintf(fid, 'Table~\\ref{tab:per_class_metrics} shows the precision, recall, and F1 score for each severity class.\n\n');
                
                % Bibliography entry
                fprintf(fid, '\\subsection{Citation}\n\n');
                fprintf(fid, 'To cite this classification system:\n\n');
                fprintf(fid, '\\begin{verbatim}\n');
                fprintf(fid, '@article{corrosion_classification,\n');
                fprintf(fid, '  title={Automated Corrosion Severity Classification for ASTM A572 Grade 50 Steel},\n');
                fprintf(fid, '  author={Author Names},\n');
                fprintf(fid, '  journal={Journal Name},\n');
                fprintf(fid, '  year={%d},\n', year(datetime('now')));
                fprintf(fid, '  note={Deep learning-based classification system}\n');
                fprintf(fid, '}\n');
                fprintf(fid, '\\end{verbatim}\n');
                
                fclose(fid);
                
                errorHandler.logInfo('VisualizationEngine', ...
                    sprintf('Summary document generated: %s', outputPath));
                
            catch ME
                if exist('fid', 'var') && fid ~= -1
                    fclose(fid);
                end
                rethrow(ME);
            end
        end
        
    end
end
