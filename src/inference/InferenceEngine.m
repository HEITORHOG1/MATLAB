classdef InferenceEngine < handle
    % InferenceEngine - Sistema de inferência para aplicação de modelos treinados
    % 
    % Esta classe implementa um sistema completo de inferência que permite
    % aplicar modelos U-Net e Attention U-Net treinados em novas imagens,
    % calculando métricas e estatísticas de performance.
    %
    % Requisitos atendidos: 3.1, 3.2, 3.3, 3.4
    
    properties
        loadedModels        % Modelos carregados em memória
        batchSize          % Tamanho do lote para processamento
        confidenceThreshold % Limiar de confiança para predições
        outputDir          % Diretório para salvar resultados
        verbose            % Flag para output detalhado
    end
    
    methods
        function obj = InferenceEngine(config)
            % Construtor do InferenceEngine
            %
            % Inputs:
            %   config - struct com configurações:
            %     .batchSize (default: 8)
            %     .confidenceThreshold (default: 0.5)
            %     .outputDir (default: 'output/inference')
            %     .verbose (default: true)
            
            if nargin < 1
                config = struct();
            end
            
            % Configurações padrão
            obj.batchSize = getfield_default(config, 'batchSize', 8);
            obj.confidenceThreshold = getfield_default(config, 'confidenceThreshold', 0.5);
            obj.outputDir = getfield_default(config, 'outputDir', 'output/inference');
            obj.verbose = getfield_default(config, 'verbose', true);
            
            % Inicializar estruturas
            obj.loadedModels = containers.Map();
            
            % Criar diretório de saída se não existir
            if ~exist(obj.outputDir, 'dir')
                mkdir(obj.outputDir);
            end
            
            if obj.verbose
                fprintf('InferenceEngine inicializado com sucesso.\n');
                fprintf('Diretório de saída: %s\n', obj.outputDir);
            end
        end
        
        function loadModel(obj, modelPath, modelName)
            % Carrega um modelo para uso em inferência
            %
            % Inputs:
            %   modelPath - caminho para o arquivo do modelo
            %   modelName - nome identificador do modelo
            
            try
                if obj.verbose
                    fprintf('Carregando modelo: %s\n', modelName);
                end
                
                % Carregar modelo usando ModelLoader
                if exist('ModelLoader', 'class')
                    [model, metadata] = ModelLoader.loadModel(modelPath);
                else
                    % Fallback para carregamento direto
                    modelData = load(modelPath);
                    if isfield(modelData, 'net')
                        model = modelData.net;
                    elseif isfield(modelData, 'model')
                        model = modelData.model;
                    else
                        error('Formato de modelo não reconhecido');
                    end
                    metadata = struct();
                end
                
                % Armazenar modelo
                obj.loadedModels(modelName) = struct('model', model, 'metadata', metadata);
                
                if obj.verbose
                    fprintf('Modelo %s carregado com sucesso.\n', modelName);
                end
                
            catch ME
                error('Erro ao carregar modelo %s: %s', modelName, ME.message);
            end
        end
        
        function results = segmentImages(obj, modelName, imagePaths)
            % Segmenta um conjunto de imagens usando modelo especificado
            %
            % Inputs:
            %   modelName - nome do modelo a ser usado
            %   imagePaths - cell array com caminhos das imagens
            %
            % Outputs:
            %   results - struct array com resultados da segmentação
            
            if ~obj.loadedModels.isKey(modelName)
                error('Modelo %s não foi carregado', modelName);
            end
            
            model = obj.loadedModels(modelName).model;
            numImages = length(imagePaths);
            
            if obj.verbose
                fprintf('Iniciando segmentação de %d imagens com modelo %s\n', numImages, modelName);
            end
            
            % Inicializar array de resultados
            results = struct('imagePath', {}, 'segmentationPath', {}, ...
                           'modelUsed', {}, 'metrics', {}, ...
                           'processingTime', {}, 'timestamp', {});
            
            % Processar imagens em lotes
            for i = 1:obj.batchSize:numImages
                endIdx = min(i + obj.batchSize - 1, numImages);
                batchPaths = imagePaths(i:endIdx);
                
                if obj.verbose
                    fprintf('Processando lote %d-%d de %d\n', i, endIdx, numImages);
                end
                
                % Processar lote
                batchResults = obj.processBatch(model, modelName, batchPaths);
                results = [results, batchResults];
            end
            
            if obj.verbose
                fprintf('Segmentação concluída. %d imagens processadas.\n', length(results));
            end
        end
        
        function [results, confidence] = segmentWithConfidence(obj, modelName, imagePaths)
            % Segmenta imagens calculando medidas de confiança
            %
            % Inputs:
            %   modelName - nome do modelo a ser usado
            %   imagePaths - cell array com caminhos das imagens
            %
            % Outputs:
            %   results - struct array com resultados da segmentação
            %   confidence - array com medidas de confiança
            
            results = obj.segmentImages(modelName, imagePaths);
            confidence = zeros(length(results), 1);
            
            if obj.verbose
                fprintf('Calculando medidas de confiança...\n');
            end
            
            for i = 1:length(results)
                % Calcular confiança baseada na distribuição de probabilidades
                segPath = results(i).segmentationPath;
                if exist(segPath, 'file')
                    seg = imread(segPath);
                    confidence(i) = obj.calculateConfidence(seg);
                end
            end
            
            % Adicionar confiança aos resultados
            for i = 1:length(results)
                results(i).confidence = confidence(i);
            end
        end
        
        function metrics = calculateBatchMetrics(obj, results, groundTruthPaths)
            % Calcula métricas para um lote de resultados
            %
            % Inputs:
            %   results - array de resultados de segmentação
            %   groundTruthPaths - cell array com caminhos do ground truth
            %
            % Outputs:
            %   metrics - struct com métricas calculadas
            
            if length(results) ~= length(groundTruthPaths)
                error('Número de resultados deve ser igual ao número de ground truths');
            end
            
            numImages = length(results);
            iouValues = zeros(numImages, 1);
            diceValues = zeros(numImages, 1);
            accuracyValues = zeros(numImages, 1);
            
            if obj.verbose
                fprintf('Calculando métricas para %d imagens...\n', numImages);
            end
            
            for i = 1:numImages
                try
                    % Carregar segmentação e ground truth
                    segPath = results(i).segmentationPath;
                    gtPath = groundTruthPaths{i};
                    
                    if exist(segPath, 'file') && exist(gtPath, 'file')
                        seg = imread(segPath);
                        gt = imread(gtPath);
                        
                        % Converter para binário se necessário
                        if size(seg, 3) > 1
                            seg = rgb2gray(seg);
                        end
                        if size(gt, 3) > 1
                            gt = rgb2gray(gt);
                        end
                        
                        seg = seg > obj.confidenceThreshold * 255;
                        gt = gt > 0.5 * 255;
                        
                        % Calcular métricas
                        iouValues(i) = obj.calculateIoU(seg, gt);
                        diceValues(i) = obj.calculateDice(seg, gt);
                        accuracyValues(i) = obj.calculateAccuracy(seg, gt);
                    else
                        warning('Arquivo não encontrado para imagem %d', i);
                        iouValues(i) = NaN;
                        diceValues(i) = NaN;
                        accuracyValues(i) = NaN;
                    end
                catch ME
                    warning('Erro ao calcular métricas para imagem %d: %s', i, ME.message);
                    iouValues(i) = NaN;
                    diceValues(i) = NaN;
                    accuracyValues(i) = NaN;
                end
            end
            
            % Compilar métricas
            metrics = struct();
            metrics.iou = struct('values', iouValues, 'mean', nanmean(iouValues), ...
                               'std', nanstd(iouValues), 'median', nanmedian(iouValues));
            metrics.dice = struct('values', diceValues, 'mean', nanmean(diceValues), ...
                                'std', nanstd(diceValues), 'median', nanmedian(diceValues));
            metrics.accuracy = struct('values', accuracyValues, 'mean', nanmean(accuracyValues), ...
                                    'std', nanstd(accuracyValues), 'median', nanmedian(accuracyValues));
            
            if obj.verbose
                fprintf('Métricas calculadas:\n');
                fprintf('  IoU: %.4f ± %.4f\n', metrics.iou.mean, metrics.iou.std);
                fprintf('  Dice: %.4f ± %.4f\n', metrics.dice.mean, metrics.dice.std);
                fprintf('  Accuracy: %.4f ± %.4f\n', metrics.accuracy.mean, metrics.accuracy.std);
            end
        end
        
        function statistics = generateStatistics(obj, allResults)
            % Gera estatísticas descritivas completas dos resultados
            %
            % Inputs:
            %   allResults - cell array com resultados de múltiplas execuções
            %
            % Outputs:
            %   statistics - struct com estatísticas descritivas
            
            if obj.verbose
                fprintf('Gerando estatísticas descritivas...\n');
            end
            
            % Compilar todas as métricas
            allIoU = [];
            allDice = [];
            allAccuracy = [];
            
            for i = 1:length(allResults)
                if isfield(allResults{i}, 'metrics')
                    metrics = allResults{i}.metrics;
                    if isfield(metrics, 'iou') && isfield(metrics.iou, 'values')
                        allIoU = [allIoU; metrics.iou.values(:)];
                    end
                    if isfield(metrics, 'dice') && isfield(metrics.dice, 'values')
                        allDice = [allDice; metrics.dice.values(:)];
                    end
                    if isfield(metrics, 'accuracy') && isfield(metrics.accuracy, 'values')
                        allAccuracy = [allAccuracy; metrics.accuracy.values(:)];
                    end
                end
            end
            
            % Calcular estatísticas descritivas
            statistics = struct();
            statistics.iou = obj.calculateDescriptiveStats(allIoU);
            statistics.dice = obj.calculateDescriptiveStats(allDice);
            statistics.accuracy = obj.calculateDescriptiveStats(allAccuracy);
            
            % Adicionar informações gerais
            statistics.totalSamples = length(allIoU);
            statistics.timestamp = datetime('now');
            
            if obj.verbose
                fprintf('Estatísticas geradas para %d amostras\n', statistics.totalSamples);
            end
        end
        
        function outliers = detectOutliers(obj, metrics)
            % Detecta casos atípicos usando múltiplos métodos
            %
            % Inputs:
            %   metrics - struct com métricas calculadas
            %
            % Outputs:
            %   outliers - struct com índices de outliers detectados
            
            if obj.verbose
                fprintf('Detectando casos atípicos...\n');
            end
            
            outliers = struct();
            
            % Detectar outliers para cada métrica
            if isfield(metrics, 'iou') && isfield(metrics.iou, 'values')
                outliers.iou = obj.detectOutliersInMetric(metrics.iou.values);
            end
            
            if isfield(metrics, 'dice') && isfield(metrics.dice, 'values')
                outliers.dice = obj.detectOutliersInMetric(metrics.dice.values);
            end
            
            if isfield(metrics, 'accuracy') && isfield(metrics.accuracy, 'values')
                outliers.accuracy = obj.detectOutliersInMetric(metrics.accuracy.values);
            end
            
            % Combinar outliers de todas as métricas
            allOutliers = [];
            if isfield(outliers, 'iou')
                allOutliers = [allOutliers; outliers.iou.iqr(:); outliers.iou.zscore(:)];
            end
            if isfield(outliers, 'dice')
                allOutliers = [allOutliers; outliers.dice.iqr(:); outliers.dice.zscore(:)];
            end
            if isfield(outliers, 'accuracy')
                allOutliers = [allOutliers; outliers.accuracy.iqr(:); outliers.accuracy.zscore(:)];
            end
            
            outliers.combined = unique(allOutliers);
            
            if obj.verbose
                fprintf('Detectados %d casos atípicos\n', length(outliers.combined));
            end
        end
    end
    
    methods (Access = private)
        function batchResults = processBatch(obj, model, modelName, imagePaths)
            % Processa um lote de imagens
            
            batchSize = length(imagePaths);
            batchResults = struct('imagePath', {}, 'segmentationPath', {}, ...
                                'modelUsed', {}, 'metrics', {}, ...
                                'processingTime', {}, 'timestamp', {});
            
            for i = 1:batchSize
                tic;
                imagePath = imagePaths{i};
                
                try
                    % Carregar e preprocessar imagem
                    img = imread(imagePath);
                    if size(img, 3) == 3
                        img = rgb2gray(img);
                    end
                    
                    % Redimensionar se necessário (assumindo 256x256)
                    img = imresize(img, [256, 256]);
                    img = double(img) / 255.0;
                    
                    % Aplicar modelo
                    if isa(model, 'SeriesNetwork') || isa(model, 'DAGNetwork')
                        % Rede neural do Deep Learning Toolbox
                        prediction = predict(model, img);
                    else
                        % Modelo customizado - assumir que tem método predict
                        prediction = model.predict(img);
                    end
                    
                    % Pós-processar predição
                    if size(prediction, 3) > 1
                        prediction = prediction(:,:,1);
                    end
                    prediction = prediction > obj.confidenceThreshold;
                    
                    % Salvar resultado
                    [~, name, ~] = fileparts(imagePath);
                    outputPath = fullfile(obj.outputDir, sprintf('%s_%s_seg.png', name, modelName));
                    imwrite(uint8(prediction * 255), outputPath);
                    
                    processingTime = toc;
                    
                    % Criar resultado
                    result = struct();
                    result.imagePath = imagePath;
                    result.segmentationPath = outputPath;
                    result.modelUsed = modelName;
                    result.metrics = struct();
                    result.processingTime = processingTime;
                    result.timestamp = datetime('now');
                    
                    batchResults(end+1) = result;
                    
                catch ME
                    warning('Erro ao processar imagem %s: %s', imagePath, ME.message);
                end
            end
        end
        
        function confidence = calculateConfidence(obj, segmentation)
            % Calcula medida de confiança baseada na distribuição de valores
            
            if islogical(segmentation)
                segmentation = double(segmentation);
            end
            
            % Normalizar para [0,1]
            segmentation = double(segmentation) / 255.0;
            
            % Calcular entropia como medida de incerteza
            % Confiança = 1 - entropia normalizada
            p = segmentation(:);
            p = p(p > 0 & p < 1); % Remover valores extremos
            
            if isempty(p)
                confidence = 1.0; % Segmentação binária perfeita
            else
                entropy = -sum(p .* log2(p + eps) + (1-p) .* log2(1-p + eps)) / length(p);
                confidence = 1 - entropy; % Normalizar entropia
            end
            
            confidence = max(0, min(1, confidence)); % Garantir [0,1]
        end
        
        function iou = calculateIoU(obj, pred, gt)
            % Calcula Intersection over Union
            intersection = sum(pred(:) & gt(:));
            union = sum(pred(:) | gt(:));
            
            if union == 0
                iou = 1.0; % Ambos vazios
            else
                iou = intersection / union;
            end
        end
        
        function dice = calculateDice(obj, pred, gt)
            % Calcula coeficiente Dice
            intersection = sum(pred(:) & gt(:));
            total = sum(pred(:)) + sum(gt(:));
            
            if total == 0
                dice = 1.0; % Ambos vazios
            else
                dice = 2 * intersection / total;
            end
        end
        
        function accuracy = calculateAccuracy(obj, pred, gt)
            % Calcula acurácia pixel-wise
            correct = sum(pred(:) == gt(:));
            total = numel(pred);
            accuracy = correct / total;
        end
        
        function stats = calculateDescriptiveStats(obj, data)
            % Calcula estatísticas descritivas completas
            
            % Remover NaN
            data = data(~isnan(data));
            
            if isempty(data)
                stats = struct('mean', NaN, 'std', NaN, 'median', NaN, ...
                             'min', NaN, 'max', NaN, 'q25', NaN, 'q75', NaN, ...
                             'skewness', NaN, 'kurtosis', NaN, 'count', 0);
                return;
            end
            
            stats = struct();
            stats.mean = mean(data);
            stats.std = std(data);
            stats.median = median(data);
            stats.min = min(data);
            stats.max = max(data);
            stats.q25 = prctile(data, 25);
            stats.q75 = prctile(data, 75);
            stats.skewness = skewness(data);
            stats.kurtosis = kurtosis(data);
            stats.count = length(data);
        end
        
        function outlierIndices = detectOutliersInMetric(obj, values)
            % Detecta outliers usando múltiplos métodos
            
            % Remover NaN
            validIdx = ~isnan(values);
            validValues = values(validIdx);
            
            if length(validValues) < 4
                outlierIndices = struct('iqr', [], 'zscore', []);
                return;
            end
            
            % Método IQR
            Q1 = prctile(validValues, 25);
            Q3 = prctile(validValues, 75);
            IQR = Q3 - Q1;
            lowerBound = Q1 - 1.5 * IQR;
            upperBound = Q3 + 1.5 * IQR;
            
            iqrOutliers = find(validValues < lowerBound | validValues > upperBound);
            
            % Método Z-score
            zScores = abs(zscore(validValues));
            zOutliers = find(zScores > 3);
            
            % Mapear de volta para índices originais
            originalIdx = find(validIdx);
            
            outlierIndices = struct();
            outlierIndices.iqr = originalIdx(iqrOutliers);
            outlierIndices.zscore = originalIdx(zOutliers);
        end
    end
end

function value = getfield_default(s, field, default)
    % Função auxiliar para obter campo com valor padrão
    if isfield(s, field)
        value = s.(field);
    else
        value = default;
    end
end