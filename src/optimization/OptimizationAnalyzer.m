classdef OptimizationAnalyzer < handle
    % OptimizationAnalyzer - Análise de otimização e sugestões de hiperparâmetros
    %
    % Esta classe analisa dados de monitoramento de gradientes e fornece
    % sugestões automáticas para ajustes de hiperparâmetros e otimização.
    %
    % Uso:
    %   analyzer = OptimizationAnalyzer(gradientMonitor);
    %   suggestions = analyzer.suggestOptimizations();
    %   analyzer.generateOptimizationReport();
    
    properties (Access = private)
        gradientMonitor    % Instância do GradientMonitor
        analysisHistory    % Histórico de análises
        currentConfig      % Configuração atual de treinamento
        recommendations    % Recomendações geradas
    end
    
    properties (Access = public)
        alertThresholds    % Limites para alertas em tempo real
        verboseMode        % Modo verboso
        saveDirectory      % Diretório para salvar relatórios
    end
    
    methods
        function obj = OptimizationAnalyzer(gradientMonitor, varargin)
            % Construtor do OptimizationAnalyzer
            %
            % Inputs:
            %   gradientMonitor - Instância do GradientMonitor
            %   varargin - Parâmetros opcionais:
            %     'SaveDirectory' - Diretório para salvar relatórios
            %     'VerboseMode' - true/false para modo verboso
            %     'AlertThresholds' - struct com limites para alertas
            
            % Parse inputs
            p = inputParser;
            addRequired(p, 'gradientMonitor');
            addParameter(p, 'SaveDirectory', 'output/optimization', @ischar);
            addParameter(p, 'VerboseMode', false, @islogical);
            addParameter(p, 'AlertThresholds', struct(), @isstruct);
            parse(p, gradientMonitor, varargin{:});
            
            % Initialize properties
            obj.gradientMonitor = gradientMonitor;
            obj.saveDirectory = p.Results.SaveDirectory;
            obj.verboseMode = p.Results.VerboseMode;
            
            % Create save directory if it doesn't exist
            if ~exist(obj.saveDirectory, 'dir')
                mkdir(obj.saveDirectory);
            end
            
            % Set default alert thresholds
            defaultThresholds = struct(...
                'gradient_norm_change', 0.5, ...      % 50% change triggers alert
                'loss_stagnation_epochs', 5, ...      % 5 epochs without improvement
                'learning_rate_adjustment', 0.1, ...  % 10% LR adjustment threshold
                'convergence_patience', 10 ...        % Epochs to wait for convergence
            );
            
            if isempty(fieldnames(p.Results.AlertThresholds))
                obj.alertThresholds = defaultThresholds;
            else
                obj.alertThresholds = obj.mergeStructs(defaultThresholds, p.Results.AlertThresholds);
            end
            
            % Initialize other properties
            obj.analysisHistory = struct();
            obj.currentConfig = struct();
            obj.recommendations = {};
            
            if obj.verboseMode
                fprintf('OptimizationAnalyzer initialized\n');
            end
        end
        
        function suggestions = suggestOptimizations(obj, varargin)
            % Gera sugestões automáticas de otimização
            %
            % Inputs (opcionais):
            %   'CurrentConfig' - struct com configuração atual
            %   'TrainingMetrics' - struct com métricas de treinamento
            %
            % Output:
            %   suggestions - struct com sugestões de otimização
            
            % Parse inputs
            p = inputParser;
            addParameter(p, 'CurrentConfig', struct(), @isstruct);
            addParameter(p, 'TrainingMetrics', struct(), @isstruct);
            parse(p, varargin{:});
            
            obj.currentConfig = p.Results.CurrentConfig;
            trainingMetrics = p.Results.TrainingMetrics;
            
            % Initialize suggestions structure
            suggestions = struct();
            suggestions.learning_rate = struct();
            suggestions.optimizer = struct();
            suggestions.architecture = struct();
            suggestions.regularization = struct();
            suggestions.training_schedule = struct();
            suggestions.priority_level = 'medium';
            suggestions.confidence = 0.5;
            suggestions.reasoning = {};
            
            % Analyze gradient problems
            gradientProblems = obj.gradientMonitor.detectGradientProblems();
            
            % Learning rate suggestions
            lrSuggestions = obj.analyzeLearningRate(gradientProblems, trainingMetrics);
            suggestions.learning_rate = lrSuggestions;
            
            % Optimizer suggestions
            optimizerSuggestions = obj.analyzeOptimizer(gradientProblems, trainingMetrics);
            suggestions.optimizer = optimizerSuggestions;
            
            % Architecture suggestions
            archSuggestions = obj.analyzeArchitecture(gradientProblems);
            suggestions.architecture = archSuggestions;
            
            % Regularization suggestions
            regSuggestions = obj.analyzeRegularization(gradientProblems, trainingMetrics);
            suggestions.regularization = regSuggestions;
            
            % Training schedule suggestions
            scheduleSuggestions = obj.analyzeTrainingSchedule(gradientProblems, trainingMetrics);
            suggestions.training_schedule = scheduleSuggestions;
            
            % Determine overall priority and confidence
            [priority, confidence, reasoning] = obj.determinePriorityAndConfidence(suggestions, gradientProblems);
            suggestions.priority_level = priority;
            suggestions.confidence = confidence;
            suggestions.reasoning = reasoning;
            
            % Store in history
            obj.storeAnalysis(suggestions, gradientProblems);
            
            if obj.verboseMode
                obj.printSuggestions(suggestions);
            end
        end
        
        function alerts = checkRealTimeAlerts(obj, currentEpoch, currentMetrics)
            % Verifica alertas em tempo real durante o treinamento
            %
            % Inputs:
            %   currentEpoch - Época atual
            %   currentMetrics - Métricas atuais (loss, accuracy, etc.)
            %
            % Output:
            %   alerts - struct com alertas detectados
            
            alerts = struct();
            alerts.critical = {};
            alerts.warning = {};
            alerts.info = {};
            alerts.actions_required = {};
            
            % Check gradient-based alerts
            gradientProblems = obj.gradientMonitor.detectGradientProblems();
            
            % Critical alerts
            if ~isempty(gradientProblems.exploding_gradients)
                alerts.critical{end+1} = sprintf(...
                    'CRITICAL: Exploding gradients detected in epoch %d. Training may become unstable.', ...
                    currentEpoch);
                alerts.actions_required{end+1} = 'Reduce learning rate immediately or apply gradient clipping';
            end
            
            if ~isempty(gradientProblems.vanishing_gradients)
                alerts.critical{end+1} = sprintf(...
                    'CRITICAL: Vanishing gradients detected in epoch %d. Learning may stop.', ...
                    currentEpoch);
                alerts.actions_required{end+1} = 'Consider residual connections or increase learning rate';
            end
            
            % Warning alerts
            if ~isempty(gradientProblems.high_variance)
                alerts.warning{end+1} = sprintf(...
                    'WARNING: High gradient variance detected in epoch %d.', currentEpoch);
                alerts.actions_required{end+1} = 'Consider batch normalization or different initialization';
            end
            
            if ~isempty(gradientProblems.stagnation)
                alerts.warning{end+1} = sprintf(...
                    'WARNING: Gradient stagnation detected in epoch %d.', currentEpoch);
                alerts.actions_required{end+1} = 'Consider increasing learning rate or changing optimizer';
            end
            
            % Loss-based alerts
            if isfield(currentMetrics, 'loss') && obj.checkLossStagnation(currentMetrics.loss, currentEpoch)
                alerts.warning{end+1} = sprintf(...
                    'WARNING: Loss stagnation detected for %d epochs.', ...
                    obj.alertThresholds.loss_stagnation_epochs);
                alerts.actions_required{end+1} = 'Consider learning rate scheduling or early stopping';
            end
            
            % Info alerts
            if currentEpoch > 1
                gradientSummary = obj.gradientMonitor.getGradientSummary();
                if isfield(gradientSummary, 'gradient_norms')
                    meanNorm = gradientSummary.gradient_norms.mean;
                    if meanNorm > 0.1 && meanNorm < 10
                        alerts.info{end+1} = sprintf(...
                            'INFO: Gradient norms appear healthy (mean: %.3f) in epoch %d.', ...
                            meanNorm, currentEpoch);
                    end
                end
            end
            
            if obj.verboseMode && (~isempty(alerts.critical) || ~isempty(alerts.warning))
                obj.printAlerts(alerts);
            end
        end
        
        function report = generateOptimizationReport(obj, varargin)
            % Gera relatório completo de otimização
            %
            % Inputs (opcionais):
            %   'SaveReport' - true/false para salvar relatório
            %   'IncludePlots' - true/false para incluir gráficos
            %
            % Output:
            %   report - struct com relatório completo
            
            % Parse inputs
            p = inputParser;
            addParameter(p, 'SaveReport', true, @islogical);
            addParameter(p, 'IncludePlots', true, @islogical);
            parse(p, varargin{:});
            
            % Generate comprehensive report
            report = struct();
            report.timestamp = now;
            report.summary = obj.generateExecutiveSummary();
            report.gradient_analysis = obj.analyzeGradientTrends();
            report.optimization_history = obj.analysisHistory;
            report.current_recommendations = obj.recommendations;
            report.performance_metrics = obj.calculatePerformanceMetrics();
            
            if p.Results.IncludePlots
                report.visualizations = obj.generateOptimizationPlots();
            end
            
            % Generate text report
            textReport = obj.formatTextReport(report);
            report.text_summary = textReport;
            
            if p.Results.SaveReport
                obj.saveOptimizationReport(report);
            end
            
            if obj.verboseMode
                fprintf('Optimization report generated\n');
                fprintf('Summary: %s\n', report.summary);
            end
        end
        
        function convergenceAnalysis = analyzeConvergence(obj, trainingMetrics)
            % Analisa convergência do treinamento
            %
            % Input:
            %   trainingMetrics - struct com métricas de treinamento
            %
            % Output:
            %   convergenceAnalysis - struct com análise de convergência
            
            convergenceAnalysis = struct();
            convergenceAnalysis.is_converging = false;
            convergenceAnalysis.convergence_rate = 0;
            convergenceAnalysis.estimated_epochs_to_convergence = inf;
            convergenceAnalysis.convergence_quality = 'poor';
            convergenceAnalysis.recommendations = {};
            
            if ~isfield(trainingMetrics, 'loss') || length(trainingMetrics.loss) < 5
                convergenceAnalysis.recommendations{end+1} = 'Insufficient data for convergence analysis';
                return;
            end
            
            losses = trainingMetrics.loss;
            epochs = 1:length(losses);
            
            % Analyze loss trend
            [convergenceRate, isConverging] = obj.calculateConvergenceRate(losses);
            convergenceAnalysis.convergence_rate = convergenceRate;
            convergenceAnalysis.is_converging = isConverging;
            
            % Estimate epochs to convergence
            if isConverging && convergenceRate > 0
                currentLoss = losses(end);
                targetLoss = min(losses) * 0.95; % Target 5% improvement from best
                epochsNeeded = abs(log(targetLoss / currentLoss) / convergenceRate);
                convergenceAnalysis.estimated_epochs_to_convergence = min(epochsNeeded, 1000);
            end
            
            % Assess convergence quality
            recentLosses = losses(max(1, end-9):end); % Last 10 epochs
            lossVariability = std(recentLosses) / mean(recentLosses);
            
            if lossVariability < 0.01
                convergenceAnalysis.convergence_quality = 'excellent';
            elseif lossVariability < 0.05
                convergenceAnalysis.convergence_quality = 'good';
            elseif lossVariability < 0.1
                convergenceAnalysis.convergence_quality = 'fair';
            else
                convergenceAnalysis.convergence_quality = 'poor';
            end
            
            % Generate recommendations
            if ~isConverging
                convergenceAnalysis.recommendations{end+1} = 'Training is not converging. Consider adjusting learning rate or architecture.';
            elseif convergenceAnalysis.estimated_epochs_to_convergence > 100
                convergenceAnalysis.recommendations{end+1} = 'Slow convergence detected. Consider increasing learning rate.';
            elseif strcmp(convergenceAnalysis.convergence_quality, 'poor')
                convergenceAnalysis.recommendations{end+1} = 'High loss variability. Consider learning rate scheduling or regularization.';
            else
                convergenceAnalysis.recommendations{end+1} = 'Training appears to be converging well.';
            end
        end
        
        function hyperparamSuggestions = suggestHyperparameters(obj, currentConfig, performanceMetrics)
            % Sugere ajustes específicos de hiperparâmetros
            %
            % Inputs:
            %   currentConfig - Configuração atual
            %   performanceMetrics - Métricas de performance
            %
            % Output:
            %   hyperparamSuggestions - Sugestões específicas
            
            hyperparamSuggestions = struct();
            
            % Learning rate suggestions
            if isfield(currentConfig, 'learning_rate')
                currentLR = currentConfig.learning_rate;
                gradientProblems = obj.gradientMonitor.detectGradientProblems();
                
                if ~isempty(gradientProblems.exploding_gradients)
                    newLR = currentLR * 0.5;
                    hyperparamSuggestions.learning_rate = struct(...
                        'current', currentLR, ...
                        'suggested', newLR, ...
                        'reason', 'Reduce due to exploding gradients', ...
                        'confidence', 0.9 ...
                    );
                elseif ~isempty(gradientProblems.vanishing_gradients)
                    newLR = currentLR * 2.0;
                    hyperparamSuggestions.learning_rate = struct(...
                        'current', currentLR, ...
                        'suggested', newLR, ...
                        'reason', 'Increase due to vanishing gradients', ...
                        'confidence', 0.8 ...
                    );
                elseif ~isempty(gradientProblems.stagnation)
                    newLR = currentLR * 1.5;
                    hyperparamSuggestions.learning_rate = struct(...
                        'current', currentLR, ...
                        'suggested', newLR, ...
                        'reason', 'Increase due to gradient stagnation', ...
                        'confidence', 0.7 ...
                    );
                end
            end
            
            % Batch size suggestions
            if isfield(currentConfig, 'batch_size')
                currentBS = currentConfig.batch_size;
                gradientProblems = obj.gradientMonitor.detectGradientProblems();
                
                if ~isempty(gradientProblems.high_variance)
                    newBS = min(currentBS * 2, 128);
                    hyperparamSuggestions.batch_size = struct(...
                        'current', currentBS, ...
                        'suggested', newBS, ...
                        'reason', 'Increase to reduce gradient variance', ...
                        'confidence', 0.6 ...
                    );
                end
            end
            
            % Regularization suggestions
            if isfield(performanceMetrics, 'validation_loss') && isfield(performanceMetrics, 'training_loss')
                valLoss = performanceMetrics.validation_loss;
                trainLoss = performanceMetrics.training_loss;
                
                if length(valLoss) > 5 && length(trainLoss) > 5
                    recentValLoss = mean(valLoss(end-4:end));
                    recentTrainLoss = mean(trainLoss(end-4:end));
                    
                    if recentValLoss > recentTrainLoss * 1.2 % Overfitting
                        hyperparamSuggestions.regularization = struct(...
                            'dropout_rate', struct('suggested', 0.3, 'reason', 'Increase to reduce overfitting'), ...
                            'weight_decay', struct('suggested', 1e-4, 'reason', 'Add L2 regularization'), ...
                            'confidence', 0.7 ...
                        );
                    end
                end
            end
        end
    end
    
    methods (Access = private)
        function lrSuggestions = analyzeLearningRate(obj, gradientProblems, trainingMetrics)
            % Analisa e sugere ajustes na taxa de aprendizado
            
            lrSuggestions = struct();
            lrSuggestions.action = 'maintain';
            lrSuggestions.factor = 1.0;
            lrSuggestions.reasoning = {};
            lrSuggestions.confidence = 0.5;
            
            % Check gradient problems
            if ~isempty(gradientProblems.exploding_gradients)
                lrSuggestions.action = 'decrease';
                lrSuggestions.factor = 0.5;
                lrSuggestions.reasoning{end+1} = 'Exploding gradients detected - reduce learning rate';
                lrSuggestions.confidence = 0.9;
            elseif ~isempty(gradientProblems.vanishing_gradients)
                lrSuggestions.action = 'increase';
                lrSuggestions.factor = 2.0;
                lrSuggestions.reasoning{end+1} = 'Vanishing gradients detected - increase learning rate';
                lrSuggestions.confidence = 0.8;
            elseif ~isempty(gradientProblems.stagnation)
                lrSuggestions.action = 'increase';
                lrSuggestions.factor = 1.5;
                lrSuggestions.reasoning{end+1} = 'Gradient stagnation detected - moderate increase';
                lrSuggestions.confidence = 0.7;
            end
            
            % Check training metrics if available
            if isfield(trainingMetrics, 'loss') && length(trainingMetrics.loss) > 5
                recentLosses = trainingMetrics.loss(end-4:end);
                lossChange = (recentLosses(end) - recentLosses(1)) / recentLosses(1);
                
                if abs(lossChange) < 0.01 % Very small change
                    if strcmp(lrSuggestions.action, 'maintain')
                        lrSuggestions.action = 'increase';
                        lrSuggestions.factor = 1.2;
                        lrSuggestions.reasoning{end+1} = 'Loss plateau detected - small increase';
                        lrSuggestions.confidence = 0.6;
                    end
                end
            end
        end
        
        function optimizerSuggestions = analyzeOptimizer(obj, gradientProblems, trainingMetrics)
            % Analisa e sugere mudanças no otimizador
            
            optimizerSuggestions = struct();
            optimizerSuggestions.recommended = 'adam';
            optimizerSuggestions.parameters = struct();
            optimizerSuggestions.reasoning = {};
            optimizerSuggestions.confidence = 0.6;
            
            % Default Adam parameters
            optimizerSuggestions.parameters.beta1 = 0.9;
            optimizerSuggestions.parameters.beta2 = 0.999;
            optimizerSuggestions.parameters.epsilon = 1e-8;
            
            % Analyze gradient characteristics
            if ~isempty(gradientProblems.high_variance)
                optimizerSuggestions.recommended = 'rmsprop';
                optimizerSuggestions.reasoning{end+1} = 'High gradient variance - RMSprop may help';
                optimizerSuggestions.confidence = 0.7;
            elseif ~isempty(gradientProblems.vanishing_gradients)
                optimizerSuggestions.recommended = 'adam';
                optimizerSuggestions.parameters.beta1 = 0.95; % Higher momentum
                optimizerSuggestions.reasoning{end+1} = 'Vanishing gradients - Adam with higher momentum';
                optimizerSuggestions.confidence = 0.8;
            elseif ~isempty(gradientProblems.exploding_gradients)
                optimizerSuggestions.recommended = 'sgd';
                optimizerSuggestions.parameters.momentum = 0.9;
                optimizerSuggestions.reasoning{end+1} = 'Exploding gradients - SGD with momentum for stability';
                optimizerSuggestions.confidence = 0.7;
            end
        end
        
        function archSuggestions = analyzeArchitecture(obj, gradientProblems)
            % Analisa e sugere mudanças na arquitetura
            
            archSuggestions = struct();
            archSuggestions.modifications = {};
            archSuggestions.reasoning = {};
            archSuggestions.confidence = 0.5;
            
            if ~isempty(gradientProblems.vanishing_gradients)
                archSuggestions.modifications{end+1} = 'Add residual connections';
                archSuggestions.modifications{end+1} = 'Consider batch normalization';
                archSuggestions.reasoning{end+1} = 'Vanishing gradients suggest need for better gradient flow';
                archSuggestions.confidence = 0.8;
            end
            
            if ~isempty(gradientProblems.exploding_gradients)
                archSuggestions.modifications{end+1} = 'Add gradient clipping';
                archSuggestions.modifications{end+1} = 'Consider layer normalization';
                archSuggestions.reasoning{end+1} = 'Exploding gradients need stabilization techniques';
                archSuggestions.confidence = 0.9;
            end
            
            if ~isempty(gradientProblems.high_variance)
                archSuggestions.modifications{end+1} = 'Add batch normalization';
                archSuggestions.modifications{end+1} = 'Consider different weight initialization';
                archSuggestions.reasoning{end+1} = 'High variance suggests normalization issues';
                archSuggestions.confidence = 0.7;
            end
        end
        
        function regSuggestions = analyzeRegularization(obj, gradientProblems, trainingMetrics)
            % Analisa e sugere técnicas de regularização
            
            regSuggestions = struct();
            regSuggestions.techniques = {};
            regSuggestions.parameters = struct();
            regSuggestions.reasoning = {};
            regSuggestions.confidence = 0.6;
            
            % Check for overfitting signs
            if isfield(trainingMetrics, 'validation_loss') && isfield(trainingMetrics, 'training_loss')
                if length(trainingMetrics.validation_loss) > 5
                    valLoss = trainingMetrics.validation_loss(end-4:end);
                    trainLoss = trainingMetrics.training_loss(end-4:end);
                    
                    if mean(valLoss) > mean(trainLoss) * 1.2
                        regSuggestions.techniques{end+1} = 'dropout';
                        regSuggestions.parameters.dropout_rate = 0.3;
                        regSuggestions.techniques{end+1} = 'weight_decay';
                        regSuggestions.parameters.weight_decay = 1e-4;
                        regSuggestions.reasoning{end+1} = 'Overfitting detected - add regularization';
                        regSuggestions.confidence = 0.8;
                    end
                end
            end
            
            % Gradient-based suggestions
            if ~isempty(gradientProblems.high_variance)
                regSuggestions.techniques{end+1} = 'batch_normalization';
                regSuggestions.reasoning{end+1} = 'High gradient variance - normalize activations';
                regSuggestions.confidence = 0.7;
            end
        end
        
        function scheduleSuggestions = analyzeTrainingSchedule(obj, gradientProblems, trainingMetrics)
            % Analisa e sugere cronograma de treinamento
            
            scheduleSuggestions = struct();
            scheduleSuggestions.schedule_type = 'constant';
            scheduleSuggestions.parameters = struct();
            scheduleSuggestions.reasoning = {};
            scheduleSuggestions.confidence = 0.5;
            
            % Check for plateau
            if isfield(trainingMetrics, 'loss') && length(trainingMetrics.loss) > 10
                recentLosses = trainingMetrics.loss(end-9:end);
                lossVariation = std(recentLosses) / mean(recentLosses);
                
                if lossVariation < 0.02 % Very stable, possibly plateaued
                    scheduleSuggestions.schedule_type = 'step_decay';
                    scheduleSuggestions.parameters.decay_factor = 0.5;
                    scheduleSuggestions.parameters.decay_epochs = 10;
                    scheduleSuggestions.reasoning{end+1} = 'Loss plateau - use learning rate decay';
                    scheduleSuggestions.confidence = 0.7;
                end
            end
            
            % Gradient-based scheduling
            if ~isempty(gradientProblems.stagnation)
                scheduleSuggestions.schedule_type = 'cosine_annealing';
                scheduleSuggestions.reasoning{end+1} = 'Gradient stagnation - try cosine annealing';
                scheduleSuggestions.confidence = 0.6;
            end
        end
        
        function [priority, confidence, reasoning] = determinePriorityAndConfidence(obj, suggestions, gradientProblems)
            % Determina prioridade geral e confiança das sugestões
            
            reasoning = {};
            
            % Determine priority based on severity of problems
            if ~isempty(gradientProblems.exploding_gradients) || ~isempty(gradientProblems.vanishing_gradients)
                priority = 'high';
                confidence = 0.9;
                reasoning{end+1} = 'Critical gradient problems detected requiring immediate attention';
            elseif ~isempty(gradientProblems.high_variance) || ~isempty(gradientProblems.stagnation)
                priority = 'medium';
                confidence = 0.7;
                reasoning{end+1} = 'Moderate optimization issues detected';
            else
                priority = 'low';
                confidence = 0.5;
                reasoning{end+1} = 'No major issues detected, suggestions are preventive';
            end
            
            % Adjust confidence based on data availability
            gradientSummary = obj.gradientMonitor.getGradientSummary();
            if isfield(gradientSummary, 'total_epochs') && gradientSummary.total_epochs < 5
                confidence = confidence * 0.7;
                reasoning{end+1} = 'Limited data available, confidence reduced';
            end
        end
        
        function storeAnalysis(obj, suggestions, gradientProblems)
            % Armazena análise no histórico
            
            analysis = struct();
            analysis.timestamp = now;
            analysis.suggestions = suggestions;
            analysis.gradient_problems = gradientProblems;
            analysis.gradient_summary = obj.gradientMonitor.getGradientSummary();
            
            if ~isfield(obj.analysisHistory, 'analyses')
                obj.analysisHistory.analyses = {};
            end
            
            obj.analysisHistory.analyses{end+1} = analysis;
            obj.recommendations = suggestions;
        end
        
        function printSuggestions(obj, suggestions)
            % Imprime sugestões de forma formatada
            
            fprintf('\n=== OPTIMIZATION SUGGESTIONS ===\n');
            fprintf('Priority: %s (Confidence: %.1f%%)\n', ...
                upper(suggestions.priority_level), suggestions.confidence * 100);
            
            if ~isempty(suggestions.reasoning)
                fprintf('\nReasoning:\n');
                for i = 1:length(suggestions.reasoning)
                    fprintf('  - %s\n', suggestions.reasoning{i});
                end
            end
            
            % Learning rate
            if isfield(suggestions.learning_rate, 'action') && ~strcmp(suggestions.learning_rate.action, 'maintain')
                fprintf('\nLearning Rate: %s by factor %.2f\n', ...
                    suggestions.learning_rate.action, suggestions.learning_rate.factor);
            end
            
            % Optimizer
            if isfield(suggestions.optimizer, 'recommended')
                fprintf('Optimizer: %s\n', suggestions.optimizer.recommended);
            end
            
            % Architecture
            if isfield(suggestions.architecture, 'modifications') && ~isempty(suggestions.architecture.modifications)
                fprintf('Architecture: %s\n', strjoin(suggestions.architecture.modifications, ', '));
            end
            
            fprintf('================================\n\n');
        end
        
        function printAlerts(obj, alerts)
            % Imprime alertas em tempo real
            
            fprintf('\n=== REAL-TIME ALERTS ===\n');
            
            if ~isempty(alerts.critical)
                fprintf('CRITICAL:\n');
                for i = 1:length(alerts.critical)
                    fprintf('  %s\n', alerts.critical{i});
                end
            end
            
            if ~isempty(alerts.warning)
                fprintf('WARNING:\n');
                for i = 1:length(alerts.warning)
                    fprintf('  %s\n', alerts.warning{i});
                end
            end
            
            if ~isempty(alerts.actions_required)
                fprintf('ACTIONS REQUIRED:\n');
                for i = 1:length(alerts.actions_required)
                    fprintf('  - %s\n', alerts.actions_required{i});
                end
            end
            
            fprintf('========================\n\n');
        end
        
        function isStagnant = checkLossStagnation(obj, lossHistory, currentEpoch)
            % Verifica se a loss está estagnada
            
            isStagnant = false;
            
            if length(lossHistory) < obj.alertThresholds.loss_stagnation_epochs
                return;
            end
            
            recentLosses = lossHistory(end-obj.alertThresholds.loss_stagnation_epochs+1:end);
            lossChange = abs(recentLosses(end) - recentLosses(1)) / recentLosses(1);
            
            if lossChange < 0.01 % Less than 1% change
                isStagnant = true;
            end
        end
        
        function [convergenceRate, isConverging] = calculateConvergenceRate(obj, losses)
            % Calcula taxa de convergência
            
            if length(losses) < 3
                convergenceRate = 0;
                isConverging = false;
                return;
            end
            
            % Fit exponential decay to recent losses
            recentLosses = losses(max(1, end-19):end); % Last 20 epochs
            epochs = 1:length(recentLosses);
            
            try
                % Simple linear fit in log space
                logLosses = log(recentLosses + eps);
                p = polyfit(epochs, logLosses, 1);
                convergenceRate = -p(1); % Negative slope means convergence
                isConverging = convergenceRate > 0;
            catch
                convergenceRate = 0;
                isConverging = false;
            end
        end
        
        function summary = generateExecutiveSummary(obj)
            % Gera resumo executivo
            
            gradientSummary = obj.gradientMonitor.getGradientSummary();
            
            if isfield(gradientSummary, 'message')
                summary = gradientSummary.message;
                return;
            end
            
            problems = obj.gradientMonitor.detectGradientProblems();
            
            if isempty(problems.recommendations)
                summary = 'Training appears stable with no major optimization issues detected.';
            else
                numProblems = length(problems.vanishing_gradients) + length(problems.exploding_gradients) + ...
                             length(problems.high_variance) + length(problems.stagnation);
                
                if numProblems > 3
                    summary = 'Multiple optimization issues detected requiring immediate attention.';
                elseif numProblems > 1
                    summary = 'Some optimization issues detected that should be addressed.';
                else
                    summary = 'Minor optimization issues detected with suggested improvements.';
                end
            end
        end
        
        function trends = analyzeGradientTrends(obj)
            % Analisa tendências dos gradientes
            
            trends = struct();
            gradientSummary = obj.gradientMonitor.getGradientSummary();
            
            if ~isfield(gradientSummary, 'gradient_norms')
                trends.message = 'Insufficient data for trend analysis';
                return;
            end
            
            trends.norm_trend = 'stable';
            trends.variance_trend = 'stable';
            trends.overall_health = 'good';
            
            % Simple trend analysis based on current statistics
            meanNorm = gradientSummary.gradient_norms.mean;
            
            if meanNorm < 1e-6
                trends.norm_trend = 'decreasing';
                trends.overall_health = 'poor';
            elseif meanNorm > 10
                trends.norm_trend = 'increasing';
                trends.overall_health = 'poor';
            end
        end
        
        function metrics = calculatePerformanceMetrics(obj)
            % Calcula métricas de performance da otimização
            
            metrics = struct();
            metrics.gradient_stability = 0.5;
            metrics.convergence_quality = 0.5;
            metrics.optimization_efficiency = 0.5;
            
            gradientSummary = obj.gradientMonitor.getGradientSummary();
            
            if isfield(gradientSummary, 'gradient_norms')
                % Gradient stability (inverse of coefficient of variation)
                cv = gradientSummary.gradient_norms.std / gradientSummary.gradient_norms.mean;
                metrics.gradient_stability = max(0, min(1, 1 - cv));
                
                % Overall score
                metrics.optimization_efficiency = (metrics.gradient_stability + metrics.convergence_quality) / 2;
            end
        end
        
        function plots = generateOptimizationPlots(obj)
            % Gera gráficos de otimização
            
            plots = struct();
            plots.gradient_evolution = 'gradient_evolution.png';
            plots.optimization_summary = 'optimization_summary.png';
            
            % Generate plots using gradient monitor
            obj.gradientMonitor.plotGradientEvolution('SavePlots', true, 'ShowPlots', false);
            
            % Additional optimization-specific plots would go here
        end
        
        function textReport = formatTextReport(obj, report)
            % Formata relatório em texto
            
            textReport = sprintf('OPTIMIZATION REPORT - %s\n', datestr(report.timestamp));
            textReport = [textReport sprintf('Summary: %s\n\n', report.summary)];
            
            if isfield(report, 'current_recommendations') && ~isempty(report.current_recommendations)
                textReport = [textReport 'Current Recommendations:\n'];
                if isfield(report.current_recommendations, 'reasoning')
                    for i = 1:length(report.current_recommendations.reasoning)
                        textReport = [textReport sprintf('- %s\n', report.current_recommendations.reasoning{i})];
                    end
                end
            end
            
            textReport = [textReport sprintf('\nGradient Analysis: %s\n', report.gradient_analysis.overall_health)];
        end
        
        function saveOptimizationReport(obj, report)
            % Salva relatório de otimização
            
            timestamp = datestr(now, 'yyyymmdd_HHMMSS');
            
            % Save MATLAB data
            filename = fullfile(obj.saveDirectory, sprintf('optimization_report_%s.mat', timestamp));
            save(filename, 'report', '-v7.3');
            
            % Save text summary
            textFilename = fullfile(obj.saveDirectory, sprintf('optimization_summary_%s.txt', timestamp));
            fid = fopen(textFilename, 'w');
            if fid > 0
                fprintf(fid, '%s', report.text_summary);
                fclose(fid);
            end
            
            if obj.verboseMode
                fprintf('Optimization report saved to: %s\n', filename);
            end
        end
        
        function merged = mergeStructs(obj, struct1, struct2)
            % Combina dois structs
            
            merged = struct1;
            fields = fieldnames(struct2);
            
            for i = 1:length(fields)
                merged.(fields{i}) = struct2.(fields{i});
            end
        end
    end
end