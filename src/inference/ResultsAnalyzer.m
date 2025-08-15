classdef ResultsAnalyzer < handle
    % ResultsAnalyzer - Análise de confiança e incerteza das predições
    % 
    % Esta classe implementa análises avançadas de confiança e incerteza
    % para resultados de segmentação, incluindo detecção de casos atípicos
    % e análise de qualidade das predições.
    %
    % Requisitos atendidos: 3.3, 3.4
    
    properties
        confidenceMethod    % Método para cálculo de confiança
        uncertaintyMethod   % Método para cálculo de incerteza
        outlierThreshold    % Limiar para detecção de outliers
        verbose            % Flag para output detalhado
    end
    
    methods
        function obj = ResultsAnalyzer(config)
            % Construtor do ResultsAnalyzer
            %
            % Inputs:
            %   config - struct com configurações:
            %     .confidenceMethod (default: 'entropy')
            %     .uncertaintyMethod (default: 'variance')
            %     .outlierThreshold (default: 2.0)
            %     .verbose (default: true)
            
            if nargin < 1
                config = struct();
            end
            
            % Configurações padrão
            obj.confidenceMethod = getfield_default(config, 'confidenceMethod', 'entropy');
            obj.uncertaintyMethod = getfield_default(config, 'uncertaintyMethod', 'variance');
            obj.outlierThreshold = getfield_default(config, 'outlierThreshold', 2.0);
            obj.verbose = getfield_default(config, 'verbose', true);
            
            if obj.verbose
                fprintf('ResultsAnalyzer inicializado.\n');
                fprintf('Método de confiança: %s\n', obj.confidenceMethod);
                fprintf('Método de incerteza: %s\n', obj.uncertaintyMethod);
            end
        end
        
        function analysis = analyzeResults(obj, results, groundTruthPaths)
            % Análise completa de resultados de segmentação
            %
            % Inputs:
            %   results - array de resultados de segmentação
            %   groundTruthPaths - cell array com caminhos do ground truth
            %
            % Outputs:
            %   analysis - struct com análise completa
            
            if obj.verbose
                fprintf('Iniciando análise de %d resultados...\n', length(results));
            end
            
            analysis = struct();
            analysis.timestamp = datetime('now');
            analysis.numResults = length(results);
            
            % Calcular confiança e incerteza
            [confidence, uncertainty] = obj.calculateConfidenceUncertainty(results);
            analysis.confidence = confidence;
            analysis.uncertainty = uncertainty;
            
            % Calcular métricas de qualidade
            if nargin > 2 && ~isempty(groundTruthPaths)
                analysis.quality = obj.calculateQualityMetrics(results, groundTruthPaths);
            end
            
            % Detectar casos atípicos
            analysis.outliers = obj.detectAnomalousResults(results, confidence, uncertainty);
            
            % Análise de distribuições
            analysis.distributions = obj.analyzeDistributions(confidence, uncertainty);
            
            % Correlações entre métricas
            if isfield(analysis, 'quality')
                analysis.correlations = obj.calculateCorrelations(analysis);
            end
            
            if obj.verbose
                fprintf('Análise concluída.\n');
                obj.printSummary(analysis);
            end
        end    
    
        function [confidence, uncertainty] = calculateConfidenceUncertainty(obj, results)
            % Calcula medidas de confiança e incerteza
            
            numResults = length(results);
            confidence = zeros(numResults, 1);
            uncertainty = zeros(numResults, 1);
            
            if obj.verbose
                fprintf('Calculando confiança e incerteza...\n');
            end
            
            for i = 1:numResults
                try
                    segPath = results(i).segmentationPath;
                    if exist(segPath, 'file')
                        seg = imread(segPath);
                        
                        % Calcular confiança
                        confidence(i) = obj.calculateConfidence(seg);
                        
                        % Calcular incerteza
                        uncertainty(i) = obj.calculateUncertainty(seg);
                    else
                        confidence(i) = NaN;
                        uncertainty(i) = NaN;
                    end
                catch ME
                    warning('Erro ao analisar resultado %d: %s', i, ME.message);
                    confidence(i) = NaN;
                    uncertainty(i) = NaN;
                end
            end
        end
        
        function quality = calculateQualityMetrics(obj, results, groundTruthPaths)
            % Calcula métricas de qualidade comparando com ground truth
            
            numResults = length(results);
            iou = zeros(numResults, 1);
            dice = zeros(numResults, 1);
            accuracy = zeros(numResults, 1);
            precision = zeros(numResults, 1);
            recall = zeros(numResults, 1);
            
            for i = 1:numResults
                try
                    segPath = results(i).segmentationPath;
                    gtPath = groundTruthPaths{i};
                    
                    if exist(segPath, 'file') && exist(gtPath, 'file')
                        seg = imread(segPath);
                        gt = imread(gtPath);
                        
                        % Preprocessar
                        seg = obj.preprocessMask(seg);
                        gt = obj.preprocessMask(gt);
                        
                        % Calcular métricas
                        [iou(i), dice(i), accuracy(i), precision(i), recall(i)] = ...
                            obj.calculateAllMetrics(seg, gt);
                    else
                        iou(i) = NaN;
                        dice(i) = NaN;
                        accuracy(i) = NaN;
                        precision(i) = NaN;
                        recall(i) = NaN;
                    end
                catch ME
                    warning('Erro ao calcular qualidade %d: %s', i, ME.message);
                    iou(i) = NaN;
                    dice(i) = NaN;
                    accuracy(i) = NaN;
                    precision(i) = NaN;
                    recall(i) = NaN;
                end
            end
            
            quality = struct();
            quality.iou = iou;
            quality.dice = dice;
            quality.accuracy = accuracy;
            quality.precision = precision;
            quality.recall = recall;
        end
        
        function outliers = detectAnomalousResults(obj, results, confidence, uncertainty)
            % Detecta resultados anômalos baseado em múltiplos critérios
            
            outliers = struct();
            
            % Outliers por baixa confiança
            validConfidence = confidence(~isnan(confidence));
            if length(validConfidence) > 1
                confidenceThreshold = prctile(validConfidence, 10);
                outliers.lowConfidence = find(confidence < confidenceThreshold);
            else
                outliers.lowConfidence = [];
            end
            
            % Outliers por alta incerteza
            validUncertainty = uncertainty(~isnan(uncertainty));
            if length(validUncertainty) > 1
                uncertaintyThreshold = prctile(validUncertainty, 90);
                outliers.highUncertainty = find(uncertainty > uncertaintyThreshold);
            else
                outliers.highUncertainty = [];
            end
            
            % Outliers por tempo de processamento
            if ~isempty(results) && isfield(results, 'processingTime')
                processingTimes = [results.processingTime];
                if length(processingTimes) > 1 && std(processingTimes) > 0
                    timeOutliers = abs(zscore(processingTimes)) > obj.outlierThreshold;
                    outliers.slowProcessing = find(timeOutliers);
                else
                    outliers.slowProcessing = [];
                end
            else
                outliers.slowProcessing = [];
            end
            
            % Combinar todos os outliers
            allOutliers = unique([outliers.lowConfidence; outliers.highUncertainty; ...
                                outliers.slowProcessing]);
            outliers.combined = allOutliers;
            
            if obj.verbose
                fprintf('Detectados %d casos anômalos:\n', length(allOutliers));
                fprintf('  Baixa confiança: %d\n', length(outliers.lowConfidence));
                fprintf('  Alta incerteza: %d\n', length(outliers.highUncertainty));
                fprintf('  Processamento lento: %d\n', length(outliers.slowProcessing));
            end
        end
        
        function distributions = analyzeDistributions(obj, confidence, uncertainty)
            % Analisa distribuições de confiança e incerteza
            
            distributions = struct();
            
            % Análise de confiança
            validConf = confidence(~isnan(confidence));
            if ~isempty(validConf)
                distributions.confidence = obj.analyzeDistribution(validConf, 'Confiança');
            end
            
            % Análise de incerteza
            validUnc = uncertainty(~isnan(uncertainty));
            if ~isempty(validUnc)
                distributions.uncertainty = obj.analyzeDistribution(validUnc, 'Incerteza');
            end
        end
        
        function correlations = calculateCorrelations(obj, analysis)
            % Calcula correlações entre diferentes métricas
            
            correlations = struct();
            
            % Extrair dados válidos
            conf = analysis.confidence(~isnan(analysis.confidence));
            unc = analysis.uncertainty(~isnan(analysis.uncertainty));
            
            if isfield(analysis, 'quality')
                iou = analysis.quality.iou(~isnan(analysis.quality.iou));
                dice = analysis.quality.dice(~isnan(analysis.quality.dice));
                
                % Garantir mesmo tamanho
                minLen = min([length(conf), length(unc), length(iou), length(dice)]);
                if minLen > 1
                    conf = conf(1:minLen);
                    unc = unc(1:minLen);
                    iou = iou(1:minLen);
                    dice = dice(1:minLen);
                    
                    % Calcular correlações
                    correlations.conf_iou = corr(conf, iou);
                    correlations.conf_dice = corr(conf, dice);
                    correlations.unc_iou = corr(unc, iou);
                    correlations.unc_dice = corr(unc, dice);
                    correlations.conf_unc = corr(conf, unc);
                end
            end
        end
    end
    
    methods (Access = private)
        function confidence = calculateConfidence(obj, segmentation)
            % Calcula confiança baseada no método especificado
            
            switch obj.confidenceMethod
                case 'entropy'
                    confidence = obj.calculateEntropyConfidence(segmentation);
                case 'variance'
                    confidence = obj.calculateVarianceConfidence(segmentation);
                case 'edge_coherence'
                    confidence = obj.calculateEdgeCoherence(segmentation);
                otherwise
                    confidence = obj.calculateEntropyConfidence(segmentation);
            end
        end
        
        function uncertainty = calculateUncertainty(obj, segmentation)
            % Calcula incerteza baseada no método especificado
            
            switch obj.uncertaintyMethod
                case 'variance'
                    uncertainty = obj.calculateVarianceUncertainty(segmentation);
                case 'entropy'
                    uncertainty = obj.calculateEntropyUncertainty(segmentation);
                case 'gradient'
                    uncertainty = obj.calculateGradientUncertainty(segmentation);
                otherwise
                    uncertainty = obj.calculateVarianceUncertainty(segmentation);
            end
        end
        
        function confidence = calculateEntropyConfidence(obj, seg)
            % Confiança baseada em entropia (menor entropia = maior confiança)
            
            seg = double(seg) / 255.0;
            
            % Calcular entropia local
            entropy = entropyfilt(seg);
            
            % Confiança = 1 - entropia normalizada
            maxEntropy = log2(256); % Entropia máxima para 8 bits
            confidence = 1 - mean(entropy(:)) / maxEntropy;
            confidence = max(0, min(1, confidence));
        end
        
        function confidence = calculateVarianceConfidence(obj, seg)
            % Confiança baseada em variância (menor variância = maior confiança)
            
            seg = double(seg);
            localVar = stdfilt(seg).^2;
            
            % Normalizar variância
            maxVar = var(seg(:));
            if maxVar > 0
                confidence = 1 - mean(localVar(:)) / maxVar;
            else
                confidence = 1.0;
            end
            confidence = max(0, min(1, confidence));
        end
        
        function confidence = calculateEdgeCoherence(obj, seg)
            % Confiança baseada na coerência das bordas
            
            % Detectar bordas
            edges = edge(seg, 'canny');
            
            % Calcular coerência das bordas
            edgeRatio = sum(edges(:)) / numel(edges);
            
            % Confiança baseada na proporção de bordas bem definidas
            confidence = min(1, edgeRatio * 10); % Fator de escala ajustável
        end
        
        function uncertainty = calculateVarianceUncertainty(obj, seg)
            % Incerteza baseada em variância local
            
            seg = double(seg);
            localVar = stdfilt(seg).^2;
            uncertainty = mean(localVar(:)) / var(seg(:));
            uncertainty = max(0, min(1, uncertainty));
        end
        
        function uncertainty = calculateEntropyUncertainty(obj, seg)
            % Incerteza baseada em entropia
            
            seg = double(seg) / 255.0;
            entropy = entropyfilt(seg);
            
            maxEntropy = log2(256);
            uncertainty = mean(entropy(:)) / maxEntropy;
            uncertainty = max(0, min(1, uncertainty));
        end
        
        function uncertainty = calculateGradientUncertainty(obj, seg)
            % Incerteza baseada na magnitude do gradiente
            
            [Gx, Gy] = gradient(double(seg));
            gradMag = sqrt(Gx.^2 + Gy.^2);
            
            % Normalizar pela magnitude máxima
            maxGrad = max(gradMag(:));
            if maxGrad > 0
                uncertainty = mean(gradMag(:)) / maxGrad;
            else
                uncertainty = 0;
            end
        end
        
        function mask = preprocessMask(obj, mask)
            % Preprocessa máscara para análise
            
            if size(mask, 3) > 1
                mask = rgb2gray(mask);
            end
            
            mask = mask > 127; % Binarizar
        end
        
        function [iou, dice, accuracy, precision, recall] = calculateAllMetrics(obj, pred, gt)
            % Calcula todas as métricas de segmentação
            
            % Intersection over Union
            intersection = sum(pred(:) & gt(:));
            union = sum(pred(:) | gt(:));
            iou = intersection / (union + eps);
            
            % Dice coefficient
            dice = 2 * intersection / (sum(pred(:)) + sum(gt(:)) + eps);
            
            % Accuracy
            accuracy = sum(pred(:) == gt(:)) / numel(pred);
            
            % Precision e Recall
            tp = sum(pred(:) & gt(:));
            fp = sum(pred(:) & ~gt(:));
            fn = sum(~pred(:) & gt(:));
            
            precision = tp / (tp + fp + eps);
            recall = tp / (tp + fn + eps);
        end
        
        function distAnalysis = analyzeDistribution(obj, data, name)
            % Analisa distribuição de dados
            
            distAnalysis = struct();
            distAnalysis.name = name;
            distAnalysis.mean = mean(data);
            distAnalysis.std = std(data);
            distAnalysis.median = median(data);
            distAnalysis.min = min(data);
            distAnalysis.max = max(data);
            distAnalysis.skewness = skewness(data);
            distAnalysis.kurtosis = kurtosis(data);
            
            % Teste de normalidade (Shapiro-Wilk aproximado)
            if length(data) > 3 && length(data) < 5000
                [~, distAnalysis.normalityTest] = swtest(data);
            else
                distAnalysis.normalityTest = NaN;
            end
        end
        
        function printSummary(obj, analysis)
            % Imprime resumo da análise
            
            fprintf('\n=== Resumo da Análise ===\n');
            fprintf('Número de resultados: %d\n', analysis.numResults);
            
            if ~isempty(analysis.confidence)
                validConf = analysis.confidence(~isnan(analysis.confidence));
                fprintf('Confiança média: %.3f ± %.3f\n', mean(validConf), std(validConf));
            end
            
            if ~isempty(analysis.uncertainty)
                validUnc = analysis.uncertainty(~isnan(analysis.uncertainty));
                fprintf('Incerteza média: %.3f ± %.3f\n', mean(validUnc), std(validUnc));
            end
            
            if isfield(analysis, 'outliers')
                fprintf('Casos anômalos detectados: %d\n', length(analysis.outliers.combined));
            end
            
            fprintf('========================\n\n');
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