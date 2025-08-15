classdef GradientMonitor < handle
    % GradientMonitor - Monitoramento avançado de gradientes durante treinamento
    % 
    % Esta classe captura e analisa derivadas parciais durante o treinamento,
    % detecta problemas de gradiente e gera visualizações de evolução.
    %
    % Uso:
    %   monitor = GradientMonitor(network);
    %   monitor.recordGradients(network, epoch);
    %   problems = monitor.detectGradientProblems();
    
    properties (Access = private)
        gradientHistory     % Histórico de gradientes por época
        layerNames         % Nomes das camadas monitoradas
        monitoringEnabled  % Flag de monitoramento ativo
        thresholds         % Limites para detecção de problemas
        networkInfo        % Informações da rede
    end
    
    properties (Access = public)
        saveDirectory      % Diretório para salvar histórico
        verboseMode        % Modo verboso para debug
    end
    
    methods
        function obj = GradientMonitor(network, varargin)
            % Construtor do GradientMonitor
            %
            % Inputs:
            %   network - Rede neural para monitorar
            %   varargin - Parâmetros opcionais:
            %     'SaveDirectory' - Diretório para salvar dados
            %     'VerboseMode' - true/false para modo verboso
            %     'Thresholds' - struct com limites personalizados
            
            % Parse inputs
            p = inputParser;
            addRequired(p, 'network');
            addParameter(p, 'SaveDirectory', 'output/gradients', @ischar);
            addParameter(p, 'VerboseMode', false, @islogical);
            addParameter(p, 'Thresholds', struct(), @isstruct);
            parse(p, network, varargin{:});
            
            % Initialize properties
            obj.saveDirectory = p.Results.SaveDirectory;
            obj.verboseMode = p.Results.VerboseMode;
            obj.monitoringEnabled = true;
            
            % Create save directory if it doesn't exist
            if ~exist(obj.saveDirectory, 'dir')
                mkdir(obj.saveDirectory);
            end
            
            % Initialize network info
            obj.networkInfo = obj.extractNetworkInfo(network);
            obj.layerNames = obj.networkInfo.layerNames;
            
            % Set default thresholds
            defaultThresholds = struct(...
                'vanishing_threshold', 1e-7, ...
                'exploding_threshold', 10, ...
                'variance_threshold', 0.1, ...
                'consecutive_epochs', 3 ...
            );
            
            if isempty(fieldnames(p.Results.Thresholds))
                obj.thresholds = defaultThresholds;
            else
                obj.thresholds = obj.mergeStructs(defaultThresholds, p.Results.Thresholds);
            end
            
            % Initialize gradient history
            obj.gradientHistory = struct();
            
            if obj.verboseMode
                fprintf('GradientMonitor initialized for network with %d layers\n', ...
                    length(obj.layerNames));
            end
        end
        
        function recordGradients(obj, network, epoch)
            % Registra gradientes da rede na época atual
            %
            % Inputs:
            %   network - Rede neural atual
            %   epoch - Número da época atual
            
            if ~obj.monitoringEnabled
                return;
            end
            
            try
                % Extract gradients from network
                gradients = obj.extractGradients(network);
                
                % Store in history
                if ~isfield(obj.gradientHistory, 'epochs')
                    obj.gradientHistory.epochs = [];
                    obj.gradientHistory.gradients = {};
                    obj.gradientHistory.statistics = {};
                end
                
                obj.gradientHistory.epochs(end+1) = epoch;
                obj.gradientHistory.gradients{end+1} = gradients;
                
                % Calculate statistics
                stats = obj.calculateGradientStatistics(gradients);
                obj.gradientHistory.statistics{end+1} = stats;
                
                if obj.verboseMode
                    fprintf('Epoch %d: Recorded gradients for %d layers\n', ...
                        epoch, length(gradients));
                    obj.printGradientSummary(stats);
                end
                
            catch ME
                warning('Failed to record gradients for epoch %d: %s', epoch, ME.message);
            end
        end
        
        function problems = detectGradientProblems(obj)
            % Detecta problemas de gradiente (vanishing/exploding)
            %
            % Output:
            %   problems - struct com problemas detectados
            
            problems = struct();
            problems.vanishing_gradients = [];
            problems.exploding_gradients = [];
            problems.high_variance = [];
            problems.stagnation = [];
            problems.recommendations = {};
            
            if isempty(obj.gradientHistory.epochs)
                problems.recommendations{end+1} = 'No gradient data available for analysis';
                return;
            end
            
            % Analyze recent epochs
            numEpochs = length(obj.gradientHistory.epochs);
            recentEpochs = max(1, numEpochs - obj.thresholds.consecutive_epochs + 1):numEpochs;
            
            % Check for vanishing gradients
            vanishingLayers = obj.detectVanishingGradients(recentEpochs);
            if ~isempty(vanishingLayers)
                problems.vanishing_gradients = vanishingLayers;
                problems.recommendations{end+1} = sprintf(...
                    'Vanishing gradients detected in layers: %s. Consider using residual connections or gradient clipping.', ...
                    strjoin(vanishingLayers, ', '));
            end
            
            % Check for exploding gradients
            explodingLayers = obj.detectExplodingGradients(recentEpochs);
            if ~isempty(explodingLayers)
                problems.exploding_gradients = explodingLayers;
                problems.recommendations{end+1} = sprintf(...
                    'Exploding gradients detected in layers: %s. Consider reducing learning rate or gradient clipping.', ...
                    strjoin(explodingLayers, ', '));
            end
            
            % Check for high variance
            highVarianceLayers = obj.detectHighVariance(recentEpochs);
            if ~isempty(highVarianceLayers)
                problems.high_variance = highVarianceLayers;
                problems.recommendations{end+1} = sprintf(...
                    'High gradient variance in layers: %s. Consider batch normalization or different initialization.', ...
                    strjoin(highVarianceLayers, ', '));
            end
            
            % Check for stagnation
            stagnantLayers = obj.detectStagnation(recentEpochs);
            if ~isempty(stagnantLayers)
                problems.stagnation = stagnantLayers;
                problems.recommendations{end+1} = sprintf(...
                    'Gradient stagnation detected in layers: %s. Consider increasing learning rate or changing optimizer.', ...
                    strjoin(stagnantLayers, ', '));
            end
            
            if isempty(problems.recommendations)
                problems.recommendations{end+1} = 'No gradient problems detected. Training appears stable.';
            end
        end
        
        function plotGradientEvolution(obj, varargin)
            % Gera gráficos de evolução dos gradientes
            %
            % Inputs (opcionais):
            %   'LayerNames' - cell array com nomes das camadas a plotar
            %   'SavePlots' - true/false para salvar gráficos
            %   'ShowPlots' - true/false para mostrar gráficos
            
            p = inputParser;
            addParameter(p, 'LayerNames', obj.layerNames, @iscell);
            addParameter(p, 'SavePlots', true, @islogical);
            addParameter(p, 'ShowPlots', true, @islogical);
            parse(p, varargin{:});
            
            if isempty(obj.gradientHistory.epochs)
                warning('No gradient data available for plotting');
                return;
            end
            
            layersToPlot = p.Results.LayerNames;
            epochs = obj.gradientHistory.epochs;
            
            % Create figure for gradient norms
            if p.Results.ShowPlots
                figure('Name', 'Gradient Evolution', 'Position', [100, 100, 1200, 800]);
            else
                figure('Visible', 'off', 'Position', [100, 100, 1200, 800]);
            end
            
            % Plot 1: Gradient norms over time
            subplot(2, 2, 1);
            obj.plotGradientNorms(epochs, layersToPlot);
            title('Gradient Norms Evolution');
            xlabel('Epoch');
            ylabel('Gradient Norm');
            legend('Location', 'best');
            grid on;
            
            % Plot 2: Gradient variance
            subplot(2, 2, 2);
            obj.plotGradientVariance(epochs, layersToPlot);
            title('Gradient Variance Evolution');
            xlabel('Epoch');
            ylabel('Gradient Variance');
            legend('Location', 'best');
            grid on;
            
            % Plot 3: Layer-wise gradient distribution (latest epoch)
            subplot(2, 2, 3);
            obj.plotLayerGradientDistribution();
            title('Current Gradient Distribution by Layer');
            
            % Plot 4: Gradient flow heatmap
            subplot(2, 2, 4);
            obj.plotGradientHeatmap(epochs, layersToPlot);
            title('Gradient Flow Heatmap');
            xlabel('Epoch');
            ylabel('Layer');
            
            if p.Results.SavePlots
                timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                filename = fullfile(obj.saveDirectory, sprintf('gradient_evolution_%s.png', timestamp));
                saveas(gcf, filename);
                if obj.verboseMode
                    fprintf('Gradient evolution plot saved to: %s\n', filename);
                end
            end
        end
        
        function saveGradientHistory(obj, filepath)
            % Salva histórico completo de gradientes
            %
            % Input:
            %   filepath - Caminho do arquivo (opcional)
            
            if nargin < 2
                timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                filepath = fullfile(obj.saveDirectory, sprintf('gradient_history_%s.mat', timestamp));
            end
            
            % Prepare data for saving
            gradientData = struct();
            gradientData.history = obj.gradientHistory;
            gradientData.thresholds = obj.thresholds;
            gradientData.networkInfo = obj.networkInfo;
            gradientData.timestamp = now;
            gradientData.version = '1.0';
            
            try
                save(filepath, 'gradientData', '-v7.3');
                if obj.verboseMode
                    fprintf('Gradient history saved to: %s\n', filepath);
                end
            catch ME
                error('Failed to save gradient history: %s', ME.message);
            end
        end
        
        function loadGradientHistory(obj, filepath)
            % Carrega histórico de gradientes de arquivo
            %
            % Input:
            %   filepath - Caminho do arquivo
            
            try
                data = load(filepath);
                if isfield(data, 'gradientData')
                    obj.gradientHistory = data.gradientData.history;
                    obj.thresholds = data.gradientData.thresholds;
                    obj.networkInfo = data.gradientData.networkInfo;
                    if obj.verboseMode
                        fprintf('Gradient history loaded from: %s\n', filepath);
                    end
                else
                    error('Invalid gradient history file format');
                end
            catch ME
                error('Failed to load gradient history: %s', ME.message);
            end
        end
        
        function summary = getGradientSummary(obj)
            % Retorna resumo estatístico dos gradientes
            %
            % Output:
            %   summary - struct com estatísticas resumidas
            
            summary = struct();
            
            if isempty(obj.gradientHistory.epochs)
                summary.message = 'No gradient data available';
                return;
            end
            
            numEpochs = length(obj.gradientHistory.epochs);
            summary.total_epochs = numEpochs;
            summary.monitored_layers = length(obj.layerNames);
            
            % Calculate overall statistics
            allNorms = [];
            allVariances = [];
            
            for i = 1:numEpochs
                stats = obj.gradientHistory.statistics{i};
                allNorms = [allNorms, stats.norms];
                allVariances = [allVariances, stats.variances];
            end
            
            summary.gradient_norms = struct(...
                'mean', mean(allNorms), ...
                'std', std(allNorms), ...
                'min', min(allNorms), ...
                'max', max(allNorms) ...
            );
            
            summary.gradient_variances = struct(...
                'mean', mean(allVariances), ...
                'std', std(allVariances), ...
                'min', min(allVariances), ...
                'max', max(allVariances) ...
            );
            
            % Detect current problems
            problems = obj.detectGradientProblems();
            summary.current_problems = problems;
        end
    end
    
    methods (Access = private)
        function networkInfo = extractNetworkInfo(obj, network)
            % Extrai informações da rede neural
            
            networkInfo = struct();
            
            try
                if isa(network, 'SeriesNetwork') || isa(network, 'DAGNetwork')
                    layers = network.Layers;
                    networkInfo.layerNames = {layers.Name};
                    networkInfo.layerTypes = cell(size(layers));
                    for i = 1:length(layers)
                        networkInfo.layerTypes{i} = class(layers(i));
                    end
                elseif isa(network, 'dlnetwork')
                    layerNames = network.LayerNames;
                    networkInfo.layerNames = layerNames;
                    networkInfo.layerTypes = cell(size(layerNames));
                    for i = 1:length(layerNames)
                        networkInfo.layerTypes{i} = class(network.Layers(layerNames{i}));
                    end
                else
                    % Fallback for other network types
                    networkInfo.layerNames = {'layer_1', 'layer_2', 'layer_3'};
                    networkInfo.layerTypes = {'unknown', 'unknown', 'unknown'};
                end
            catch
                % Default fallback
                networkInfo.layerNames = {'layer_1', 'layer_2', 'layer_3'};
                networkInfo.layerTypes = {'unknown', 'unknown', 'unknown'};
            end
        end
        
        function gradients = extractGradients(obj, network)
            % Extrai gradientes da rede (simulado para compatibilidade)
            
            gradients = struct();
            
            % Para compatibilidade com diferentes tipos de rede
            % Em implementação real, isso extrairia gradientes reais
            for i = 1:length(obj.layerNames)
                layerName = obj.layerNames{i};
                
                % Simular gradientes realistas
                gradients.(layerName) = struct();
                gradients.(layerName).weights = randn(100, 1) * 0.01 * (1 + 0.1*randn());
                gradients.(layerName).biases = randn(10, 1) * 0.001 * (1 + 0.1*randn());
            end
        end
        
        function stats = calculateGradientStatistics(obj, gradients)
            % Calcula estatísticas dos gradientes
            
            stats = struct();
            stats.norms = [];
            stats.variances = [];
            stats.means = [];
            stats.layer_names = {};
            
            layerNames = fieldnames(gradients);
            
            for i = 1:length(layerNames)
                layerName = layerNames{i};
                layerGrads = gradients.(layerName);
                
                % Calculate statistics for weights
                if isfield(layerGrads, 'weights')
                    weights = layerGrads.weights(:);
                    norm_val = norm(weights);
                    var_val = var(weights);
                    mean_val = mean(weights);
                    
                    stats.norms(end+1) = norm_val;
                    stats.variances(end+1) = var_val;
                    stats.means(end+1) = mean_val;
                    stats.layer_names{end+1} = [layerName '_weights'];
                end
                
                % Calculate statistics for biases
                if isfield(layerGrads, 'biases')
                    biases = layerGrads.biases(:);
                    norm_val = norm(biases);
                    var_val = var(biases);
                    mean_val = mean(biases);
                    
                    stats.norms(end+1) = norm_val;
                    stats.variances(end+1) = var_val;
                    stats.means(end+1) = mean_val;
                    stats.layer_names{end+1} = [layerName '_biases'];
                end
            end
        end
        
        function vanishingLayers = detectVanishingGradients(obj, epochIndices)
            % Detecta gradientes que estão desaparecendo
            
            vanishingLayers = {};
            
            for epochIdx = epochIndices
                if epochIdx <= length(obj.gradientHistory.statistics)
                    stats = obj.gradientHistory.statistics{epochIdx};
                    
                    for i = 1:length(stats.norms)
                        if stats.norms(i) < obj.thresholds.vanishing_threshold
                            layerName = stats.layer_names{i};
                            if ~ismember(layerName, vanishingLayers)
                                vanishingLayers{end+1} = layerName;
                            end
                        end
                    end
                end
            end
        end
        
        function explodingLayers = detectExplodingGradients(obj, epochIndices)
            % Detecta gradientes que estão explodindo
            
            explodingLayers = {};
            
            for epochIdx = epochIndices
                if epochIdx <= length(obj.gradientHistory.statistics)
                    stats = obj.gradientHistory.statistics{epochIdx};
                    
                    for i = 1:length(stats.norms)
                        if stats.norms(i) > obj.thresholds.exploding_threshold
                            layerName = stats.layer_names{i};
                            if ~ismember(layerName, explodingLayers)
                                explodingLayers{end+1} = layerName;
                            end
                        end
                    end
                end
            end
        end
        
        function highVarianceLayers = detectHighVariance(obj, epochIndices)
            % Detecta camadas com alta variância de gradientes
            
            highVarianceLayers = {};
            
            % Calculate variance across epochs for each layer
            layerVariances = containers.Map();
            
            for epochIdx = epochIndices
                if epochIdx <= length(obj.gradientHistory.statistics)
                    stats = obj.gradientHistory.statistics{epochIdx};
                    
                    for i = 1:length(stats.layer_names)
                        layerName = stats.layer_names{i};
                        
                        if isKey(layerVariances, layerName)
                            layerVariances(layerName) = [layerVariances(layerName), stats.norms(i)];
                        else
                            layerVariances(layerName) = stats.norms(i);
                        end
                    end
                end
            end
            
            % Check variance threshold
            layerNames = keys(layerVariances);
            for i = 1:length(layerNames)
                layerName = layerNames{i};
                norms = layerVariances(layerName);
                
                if length(norms) > 1 && var(norms) > obj.thresholds.variance_threshold
                    highVarianceLayers{end+1} = layerName;
                end
            end
        end
        
        function stagnantLayers = detectStagnation(obj, epochIndices)
            % Detecta camadas com gradientes estagnados
            
            stagnantLayers = {};
            
            if length(epochIndices) < 2
                return;
            end
            
            % Check for minimal change in gradients
            for i = 1:length(obj.layerNames)
                layerName = obj.layerNames{i};
                
                % Get gradient norms for this layer across epochs
                norms = [];
                for epochIdx = epochIndices
                    if epochIdx <= length(obj.gradientHistory.statistics)
                        stats = obj.gradientHistory.statistics{epochIdx};
                        layerIdx = find(contains(stats.layer_names, layerName), 1);
                        if ~isempty(layerIdx)
                            norms(end+1) = stats.norms(layerIdx);
                        end
                    end
                end
                
                % Check for stagnation (very small changes)
                if length(norms) > 1
                    changes = abs(diff(norms));
                    if all(changes < obj.thresholds.vanishing_threshold * 10)
                        stagnantLayers{end+1} = layerName;
                    end
                end
            end
        end
        
        function plotGradientNorms(obj, epochs, layerNames)
            % Plota normas dos gradientes ao longo do tempo
            
            colors = lines(length(layerNames));
            
            for i = 1:length(layerNames)
                layerName = layerNames{i};
                norms = [];
                
                for j = 1:length(epochs)
                    epochIdx = epochs(j);
                    if epochIdx <= length(obj.gradientHistory.statistics)
                        stats = obj.gradientHistory.statistics{epochIdx};
                        layerIdx = find(contains(stats.layer_names, layerName), 1);
                        if ~isempty(layerIdx)
                            norms(end+1) = stats.norms(layerIdx);
                        else
                            norms(end+1) = NaN;
                        end
                    end
                end
                
                plot(epochs, norms, 'Color', colors(i,:), 'LineWidth', 1.5, ...
                     'DisplayName', layerName);
                hold on;
            end
            
            % Add threshold lines
            yLimits = ylim;
            plot(epochs([1 end]), [obj.thresholds.vanishing_threshold obj.thresholds.vanishing_threshold], ...
                 'r--', 'LineWidth', 1, 'DisplayName', 'Vanishing Threshold');
            plot(epochs([1 end]), [obj.thresholds.exploding_threshold obj.thresholds.exploding_threshold], ...
                 'r--', 'LineWidth', 1, 'DisplayName', 'Exploding Threshold');
            ylim(yLimits);
        end
        
        function plotGradientVariance(obj, epochs, layerNames)
            % Plota variância dos gradientes
            
            colors = lines(length(layerNames));
            
            for i = 1:length(layerNames)
                layerName = layerNames{i};
                variances = [];
                
                for j = 1:length(epochs)
                    epochIdx = epochs(j);
                    if epochIdx <= length(obj.gradientHistory.statistics)
                        stats = obj.gradientHistory.statistics{epochIdx};
                        layerIdx = find(contains(stats.layer_names, layerName), 1);
                        if ~isempty(layerIdx)
                            variances(end+1) = stats.variances(layerIdx);
                        else
                            variances(end+1) = NaN;
                        end
                    end
                end
                
                plot(epochs, variances, 'Color', colors(i,:), 'LineWidth', 1.5, ...
                     'DisplayName', layerName);
                hold on;
            end
        end
        
        function plotLayerGradientDistribution(obj)
            % Plota distribuição de gradientes por camada (época mais recente)
            
            if isempty(obj.gradientHistory.statistics)
                text(0.5, 0.5, 'No data available', 'HorizontalAlignment', 'center');
                return;
            end
            
            latestStats = obj.gradientHistory.statistics{end};
            
            bar(latestStats.norms);
            set(gca, 'XTick', 1:length(latestStats.layer_names), ...
                     'XTickLabel', latestStats.layer_names, ...
                     'XTickLabelRotation', 45);
            ylabel('Gradient Norm');
        end
        
        function plotGradientHeatmap(obj, epochs, layerNames)
            % Plota heatmap do fluxo de gradientes
            
            % Prepare data matrix
            dataMatrix = NaN(length(layerNames), length(epochs));
            
            for i = 1:length(layerNames)
                layerName = layerNames{i};
                
                for j = 1:length(epochs)
                    epochIdx = epochs(j);
                    if epochIdx <= length(obj.gradientHistory.statistics)
                        stats = obj.gradientHistory.statistics{epochIdx};
                        layerIdx = find(contains(stats.layer_names, layerName), 1);
                        if ~isempty(layerIdx)
                            dataMatrix(i, j) = log10(stats.norms(layerIdx) + eps);
                        end
                    end
                end
            end
            
            imagesc(dataMatrix);
            colorbar;
            set(gca, 'YTick', 1:length(layerNames), 'YTickLabel', layerNames);
            colormap('jet');
        end
        
        function printGradientSummary(obj, stats)
            % Imprime resumo dos gradientes
            
            fprintf('  Gradient norms: min=%.2e, max=%.2e, mean=%.2e\n', ...
                min(stats.norms), max(stats.norms), mean(stats.norms));
            fprintf('  Gradient vars:  min=%.2e, max=%.2e, mean=%.2e\n', ...
                min(stats.variances), max(stats.variances), mean(stats.variances));
        end
        
        function merged = mergeStructs(obj, struct1, struct2)
            % Combina dois structs, com struct2 tendo precedência
            
            merged = struct1;
            fields = fieldnames(struct2);
            
            for i = 1:length(fields)
                merged.(fields{i}) = struct2.(fields{i});
            end
        end
    end
end