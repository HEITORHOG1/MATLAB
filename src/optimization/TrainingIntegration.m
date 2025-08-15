classdef TrainingIntegration < handle
    % TrainingIntegration - Integração do monitoramento com processo de treinamento
    %
    % Esta classe facilita a integração do sistema de monitoramento de gradientes
    % com os scripts de treinamento existentes.
    %
    % Uso:
    %   integration = TrainingIntegration();
    %   integration.setupMonitoring(network, config);
    %   % Durante o treinamento:
    %   integration.recordEpoch(network, epoch, metrics);
    
    properties (Access = private)
        gradientMonitor     % Instância do GradientMonitor
        optimizationAnalyzer % Instância do OptimizationAnalyzer
        trainingConfig      % Configuração de treinamento
        trainingMetrics     % Métricas acumuladas
        alertsEnabled       % Flag para alertas em tempo real
    end
    
    properties (Access = public)
        verboseMode         % Modo verboso
        saveDirectory       % Diretório base para salvar dados
        autoSaveEnabled     % Salvamento automático habilitado
    end
    
    methods
        function obj = TrainingIntegration(varargin)
            % Construtor da TrainingIntegration
            %
            % Inputs (opcionais):
            %   'SaveDirectory' - Diretório base para salvar dados
            %   'VerboseMode' - true/false para modo verboso
            %   'AlertsEnabled' - true/false para alertas em tempo real
            %   'AutoSaveEnabled' - true/false para salvamento automático
            
            % Parse inputs
            p = inputParser;
            addParameter(p, 'SaveDirectory', 'output', @ischar);
            addParameter(p, 'VerboseMode', true, @islogical);
            addParameter(p, 'AlertsEnabled', true, @islogical);
            addParameter(p, 'AutoSaveEnabled', true, @islogical);
            parse(p, varargin{:});
            
            % Initialize properties
            obj.saveDirectory = p.Results.SaveDirectory;
            obj.verboseMode = p.Results.VerboseMode;
            obj.alertsEnabled = p.Results.AlertsEnabled;
            obj.autoSaveEnabled = p.Results.AutoSaveEnabled;
            
            % Initialize empty properties
            obj.gradientMonitor = [];
            obj.optimizationAnalyzer = [];
            obj.trainingConfig = struct();
            obj.trainingMetrics = struct();
            
            if obj.verboseMode
                fprintf('TrainingIntegration initialized\n');
            end
        end
        
        function setupMonitoring(obj, network, config)
            % Configura monitoramento para uma rede e configuração específicas
            %
            % Inputs:
            %   network - Rede neural a ser monitorada
            %   config - struct com configuração de treinamento
            
            % Store configuration
            obj.trainingConfig = config;
            
            % Initialize gradient monitor
            gradientDir = fullfile(obj.saveDirectory, 'gradients');
            obj.gradientMonitor = GradientMonitor(network, ...
                'SaveDirectory', gradientDir, ...
                'VerboseMode', obj.verboseMode);
            
            % Initialize optimization analyzer
            optimizationDir = fullfile(obj.saveDirectory, 'optimization');
            obj.optimizationAnalyzer = OptimizationAnalyzer(obj.gradientMonitor, ...
                'SaveDirectory', optimizationDir, ...
                'VerboseMode', obj.verboseMode);
            
            % Initialize metrics storage
            obj.trainingMetrics = struct();
            obj.trainingMetrics.loss = [];
            obj.trainingMetrics.validation_loss = [];
            obj.trainingMetrics.accuracy = [];
            obj.trainingMetrics.validation_accuracy = [];
            obj.trainingMetrics.epochs = [];
            
            if obj.verboseMode
                fprintf('Monitoring setup complete for network with %d layers\n', ...
                    length(obj.gradientMonitor.layerNames));
            end
        end
        
        function recordEpoch(obj, network, epoch, metrics)
            % Registra dados de uma época de treinamento
            %
            % Inputs:
            %   network - Rede neural atual
            %   epoch - Número da época
            %   metrics - struct com métricas da época (loss, accuracy, etc.)
            
            if isempty(obj.gradientMonitor)
                warning('Monitoring not setup. Call setupMonitoring first.');
                return;
            end
            
            % Record gradients
            obj.gradientMonitor.recordGradients(network, epoch);
            
            % Store training metrics
            obj.trainingMetrics.epochs(end+1) = epoch;
            
            if isfield(metrics, 'loss')
                obj.trainingMetrics.loss(end+1) = metrics.loss;
            end
            
            if isfield(metrics, 'validation_loss')
                obj.trainingMetrics.validation_loss(end+1) = metrics.validation_loss;
            end
            
            if isfield(metrics, 'accuracy')
                obj.trainingMetrics.accuracy(end+1) = metrics.accuracy;
            end
            
            if isfield(metrics, 'validation_accuracy')
                obj.trainingMetrics.validation_accuracy(end+1) = metrics.validation_accuracy;
            end
            
            % Check for real-time alerts
            if obj.alertsEnabled
                alerts = obj.optimizationAnalyzer.checkRealTimeAlerts(epoch, metrics);
                obj.handleAlerts(alerts, epoch);
            end
            
            % Auto-save periodically
            if obj.autoSaveEnabled && mod(epoch, 10) == 0
                obj.saveProgress();
            end
            
            if obj.verboseMode
                fprintf('Epoch %d recorded. Loss: %.4f\n', epoch, ...
                    metrics.loss);
            end
        end
        
        function suggestions = getSuggestions(obj)
            % Obtém sugestões de otimização atuais
            %
            % Output:
            %   suggestions - struct com sugestões de otimização
            
            if isempty(obj.optimizationAnalyzer)
                warning('Optimization analyzer not initialized');
                suggestions = struct();
                return;
            end
            
            suggestions = obj.optimizationAnalyzer.suggestOptimizations(...
                'CurrentConfig', obj.trainingConfig, ...
                'TrainingMetrics', obj.trainingMetrics);
        end
        
        function report = generateReport(obj)
            % Gera relatório completo de monitoramento
            %
            % Output:
            %   report - struct com relatório completo
            
            if isempty(obj.optimizationAnalyzer)
                warning('Optimization analyzer not initialized');
                report = struct();
                return;
            end
            
            report = obj.optimizationAnalyzer.generateOptimizationReport();
            
            % Add training-specific information
            report.training_config = obj.trainingConfig;
            report.training_metrics = obj.trainingMetrics;
            report.integration_info = struct(...
                'total_epochs_monitored', length(obj.trainingMetrics.epochs), ...
                'monitoring_start_time', obj.gradientMonitor.networkInfo, ...
                'alerts_enabled', obj.alertsEnabled, ...
                'auto_save_enabled', obj.autoSaveEnabled ...
            );
        end
        
        function plotTrainingProgress(obj, varargin)
            % Gera gráficos de progresso do treinamento
            %
            % Inputs (opcionais):
            %   'SavePlots' - true/false para salvar gráficos
            %   'ShowPlots' - true/false para mostrar gráficos
            
            % Parse inputs
            p = inputParser;
            addParameter(p, 'SavePlots', true, @islogical);
            addParameter(p, 'ShowPlots', true, @islogical);
            parse(p, varargin{:});
            
            if isempty(obj.trainingMetrics.epochs)
                warning('No training data available for plotting');
                return;
            end
            
            % Create comprehensive training plot
            if p.Results.ShowPlots
                figure('Name', 'Training Progress', 'Position', [100, 100, 1400, 1000]);
            else
                figure('Visible', 'off', 'Position', [100, 100, 1400, 1000]);
            end
            
            epochs = obj.trainingMetrics.epochs;
            
            % Plot 1: Loss curves
            subplot(2, 3, 1);
            if ~isempty(obj.trainingMetrics.loss)
                plot(epochs, obj.trainingMetrics.loss, 'b-', 'LineWidth', 2, 'DisplayName', 'Training Loss');
                hold on;
            end
            if ~isempty(obj.trainingMetrics.validation_loss)
                plot(epochs, obj.trainingMetrics.validation_loss, 'r-', 'LineWidth', 2, 'DisplayName', 'Validation Loss');
            end
            title('Loss Evolution');
            xlabel('Epoch');
            ylabel('Loss');
            legend('Location', 'best');
            grid on;
            
            % Plot 2: Accuracy curves
            subplot(2, 3, 2);
            if ~isempty(obj.trainingMetrics.accuracy)
                plot(epochs, obj.trainingMetrics.accuracy, 'b-', 'LineWidth', 2, 'DisplayName', 'Training Accuracy');
                hold on;
            end
            if ~isempty(obj.trainingMetrics.validation_accuracy)
                plot(epochs, obj.trainingMetrics.validation_accuracy, 'r-', 'LineWidth', 2, 'DisplayName', 'Validation Accuracy');
            end
            title('Accuracy Evolution');
            xlabel('Epoch');
            ylabel('Accuracy');
            legend('Location', 'best');
            grid on;
            
            % Plot 3: Gradient evolution (from gradient monitor)
            subplot(2, 3, 3);
            if ~isempty(obj.gradientMonitor)
                obj.gradientMonitor.plotGradientEvolution('SavePlots', false, 'ShowPlots', false);
                title('Gradient Norms');
            else
                text(0.5, 0.5, 'Gradient data not available', 'HorizontalAlignment', 'center');
            end
            
            % Plot 4: Learning curve analysis
            subplot(2, 3, 4);
            obj.plotLearningCurveAnalysis();
            
            % Plot 5: Optimization health
            subplot(2, 3, 5);
            obj.plotOptimizationHealth();
            
            % Plot 6: Convergence analysis
            subplot(2, 3, 6);
            obj.plotConvergenceAnalysis();
            
            if p.Results.SavePlots
                timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                filename = fullfile(obj.saveDirectory, sprintf('training_progress_%s.png', timestamp));
                saveas(gcf, filename);
                if obj.verboseMode
                    fprintf('Training progress plot saved to: %s\n', filename);
                end
            end
        end
        
        function saveProgress(obj, filename)
            % Salva progresso atual do monitoramento
            %
            % Input:
            %   filename - Nome do arquivo (opcional)
            
            if nargin < 2
                timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                filename = fullfile(obj.saveDirectory, sprintf('training_progress_%s.mat', timestamp));
            end
            
            % Prepare data for saving
            progressData = struct();
            progressData.training_config = obj.trainingConfig;
            progressData.training_metrics = obj.trainingMetrics;
            progressData.timestamp = now;
            progressData.version = '1.0';
            
            % Save gradient history if available
            if ~isempty(obj.gradientMonitor)
                gradientFile = strrep(filename, '.mat', '_gradients.mat');
                obj.gradientMonitor.saveGradientHistory(gradientFile);
                progressData.gradient_file = gradientFile;
            end
            
            % Save optimization analysis if available
            if ~isempty(obj.optimizationAnalyzer)
                optimizationReport = obj.optimizationAnalyzer.generateOptimizationReport('SaveReport', false);
                progressData.optimization_report = optimizationReport;
            end
            
            try
                save(filename, 'progressData', '-v7.3');
                if obj.verboseMode
                    fprintf('Training progress saved to: %s\n', filename);
                end
            catch ME
                warning('Failed to save training progress: %s', ME.message);
            end
        end
        
        function loadProgress(obj, filename)
            % Carrega progresso salvo
            %
            % Input:
            %   filename - Nome do arquivo
            
            try
                data = load(filename);
                if isfield(data, 'progressData')
                    obj.trainingConfig = data.progressData.training_config;
                    obj.trainingMetrics = data.progressData.training_metrics;
                    
                    % Load gradient history if available
                    if isfield(data.progressData, 'gradient_file') && exist(data.progressData.gradient_file, 'file')
                        if ~isempty(obj.gradientMonitor)
                            obj.gradientMonitor.loadGradientHistory(data.progressData.gradient_file);
                        end
                    end
                    
                    if obj.verboseMode
                        fprintf('Training progress loaded from: %s\n', filename);
                        fprintf('Loaded %d epochs of data\n', length(obj.trainingMetrics.epochs));
                    end
                else
                    error('Invalid progress file format');
                end
            catch ME
                error('Failed to load training progress: %s', ME.message);
            end
        end
        
        function summary = getTrainingSummary(obj)
            % Retorna resumo do treinamento
            %
            % Output:
            %   summary - struct com resumo do treinamento
            
            summary = struct();
            
            if isempty(obj.trainingMetrics.epochs)
                summary.message = 'No training data available';
                return;
            end
            
            summary.total_epochs = length(obj.trainingMetrics.epochs);
            summary.current_epoch = max(obj.trainingMetrics.epochs);
            
            % Loss summary
            if ~isempty(obj.trainingMetrics.loss)
                summary.final_loss = obj.trainingMetrics.loss(end);
                summary.best_loss = min(obj.trainingMetrics.loss);
                summary.loss_improvement = (obj.trainingMetrics.loss(1) - obj.trainingMetrics.loss(end)) / obj.trainingMetrics.loss(1);
            end
            
            % Accuracy summary
            if ~isempty(obj.trainingMetrics.accuracy)
                summary.final_accuracy = obj.trainingMetrics.accuracy(end);
                summary.best_accuracy = max(obj.trainingMetrics.accuracy);
            end
            
            % Gradient summary
            if ~isempty(obj.gradientMonitor)
                gradientSummary = obj.gradientMonitor.getGradientSummary();
                summary.gradient_health = gradientSummary;
            end
            
            % Optimization summary
            if ~isempty(obj.optimizationAnalyzer)
                problems = obj.gradientMonitor.detectGradientProblems();
                summary.optimization_issues = length(problems.vanishing_gradients) + ...
                                            length(problems.exploding_gradients) + ...
                                            length(problems.high_variance) + ...
                                            length(problems.stagnation);
            end
        end
    end
    
    methods (Access = private)
        function handleAlerts(obj, alerts, epoch)
            % Processa alertas em tempo real
            
            if ~isempty(alerts.critical)
                fprintf('\n*** CRITICAL ALERT - EPOCH %d ***\n', epoch);
                for i = 1:length(alerts.critical)
                    fprintf('%s\n', alerts.critical{i});
                end
                
                if ~isempty(alerts.actions_required)
                    fprintf('IMMEDIATE ACTIONS REQUIRED:\n');
                    for i = 1:length(alerts.actions_required)
                        fprintf('- %s\n', alerts.actions_required{i});
                    end
                end
                fprintf('*********************************\n\n');
            end
            
            if ~isempty(alerts.warning) && obj.verboseMode
                fprintf('\nWarning (Epoch %d): %s\n', epoch, alerts.warning{1});
            end
        end
        
        function plotLearningCurveAnalysis(obj)
            % Plota análise da curva de aprendizado
            
            if isempty(obj.trainingMetrics.loss) || length(obj.trainingMetrics.loss) < 3
                text(0.5, 0.5, 'Insufficient data', 'HorizontalAlignment', 'center');
                title('Learning Curve Analysis');
                return;
            end
            
            epochs = obj.trainingMetrics.epochs;
            loss = obj.trainingMetrics.loss;
            
            % Calculate moving average
            windowSize = min(5, length(loss));
            movingAvg = movmean(loss, windowSize);
            
            plot(epochs, loss, 'b-', 'Alpha', 0.3, 'DisplayName', 'Raw Loss');
            hold on;
            plot(epochs, movingAvg, 'r-', 'LineWidth', 2, 'DisplayName', 'Moving Average');
            
            title('Learning Curve Analysis');
            xlabel('Epoch');
            ylabel('Loss');
            legend('Location', 'best');
            grid on;
        end
        
        function plotOptimizationHealth(obj)
            % Plota saúde da otimização
            
            if isempty(obj.gradientMonitor)
                text(0.5, 0.5, 'Gradient data not available', 'HorizontalAlignment', 'center');
                title('Optimization Health');
                return;
            end
            
            gradientSummary = obj.gradientMonitor.getGradientSummary();
            
            if ~isfield(gradientSummary, 'gradient_norms')
                text(0.5, 0.5, 'No gradient statistics', 'HorizontalAlignment', 'center');
                title('Optimization Health');
                return;
            end
            
            % Create health indicators
            healthMetrics = {'Gradient Stability', 'Convergence Quality', 'Overall Health'};
            healthValues = [0.7, 0.6, 0.65]; % Placeholder values
            
            bar(healthValues);
            set(gca, 'XTickLabel', healthMetrics, 'XTickLabelRotation', 45);
            ylim([0, 1]);
            ylabel('Health Score');
            title('Optimization Health');
            grid on;
        end
        
        function plotConvergenceAnalysis(obj)
            % Plota análise de convergência
            
            if isempty(obj.trainingMetrics.loss) || length(obj.trainingMetrics.loss) < 5
                text(0.5, 0.5, 'Insufficient data', 'HorizontalAlignment', 'center');
                title('Convergence Analysis');
                return;
            end
            
            if ~isempty(obj.optimizationAnalyzer)
                convergenceAnalysis = obj.optimizationAnalyzer.analyzeConvergence(obj.trainingMetrics);
                
                % Plot convergence indicators
                epochs = obj.trainingMetrics.epochs;
                loss = obj.trainingMetrics.loss;
                
                % Calculate convergence trend
                if length(loss) > 10
                    recentLoss = loss(end-9:end);
                    recentEpochs = epochs(end-9:end);
                    p = polyfit(recentEpochs, log(recentLoss + eps), 1);
                    trendLine = exp(polyval(p, epochs));
                    
                    plot(epochs, loss, 'b-', 'DisplayName', 'Actual Loss');
                    hold on;
                    plot(epochs, trendLine, 'r--', 'LineWidth', 2, 'DisplayName', 'Convergence Trend');
                    
                    if convergenceAnalysis.is_converging
                        title(sprintf('Converging (Rate: %.4f)', convergenceAnalysis.convergence_rate));
                    else
                        title('Not Converging');
                    end
                else
                    plot(epochs, loss, 'b-');
                    title('Convergence Analysis (Insufficient Data)');
                end
            else
                epochs = obj.trainingMetrics.epochs;
                loss = obj.trainingMetrics.loss;
                plot(epochs, loss, 'b-');
                title('Loss Trend');
            end
            
            xlabel('Epoch');
            ylabel('Loss');
            legend('Location', 'best');
            grid on;
        end
    end
end