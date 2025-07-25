classdef MetricsCalculator < handle
    % ========================================================================
    % METRICS CALCULATOR - PROJETO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Classe unificada para cálculo de métricas de segmentação
    %   Consolida funcionalidades de IoU, Dice e Accuracy
    %
    % TUTORIAL MATLAB:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Object-Oriented Programming in MATLAB
    %   - Image Processing and Computer Vision
    % ========================================================================
    
    properties (Access = private)
        verbose = false;
        epsilon = 1e-7; % Para evitar divisão por zero
    end
    
    methods
        function obj = MetricsCalculator(varargin)
            % Construtor da classe MetricsCalculator
            %
            % Uso:
            %   calc = MetricsCalculator()
            %   calc = MetricsCalculator('verbose', true)
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'verbose', false, @islogical);
            parse(p, varargin{:});
            
            obj.verbose = p.Results.verbose;
            
            if obj.verbose
                fprintf('MetricsCalculator inicializado.\n');
            end
        end
        
        function iou = calculateIoU(obj, pred, gt)
            % Calcular IoU (Intersection over Union)
            %
            % Entrada:
            %   pred - Predição do modelo (matriz ou categorical)
            %   gt   - Ground truth (matriz ou categorical)
            %
            % Saída:
            %   iou  - Valor IoU (0-1)
            
            try
                % Converter para binário
                predBinary = obj.convertToBinary(pred);
                gtBinary = obj.convertToBinary(gt);
                
                % Validar dimensões
                if ~isequal(size(predBinary), size(gtBinary))
                    error('MetricsCalculator:DimensionMismatch', ...
                          'Predição e ground truth devem ter as mesmas dimensões');
                end
                
                % Calcular IoU
                intersection = sum(predBinary(:) & gtBinary(:));
                union = sum(predBinary(:) | gtBinary(:));
                
                if union == 0
                    iou = 1; % Ambos são vazios - perfeita concordância
                else
                    iou = intersection / union;
                end
                
                if obj.verbose
                    fprintf('IoU calculado: %.4f\n', iou);
                end
                
            catch ME
                if obj.verbose
                    fprintf('Erro no cálculo de IoU: %s\n', ME.message);
                end
                iou = 0;
            end
        end
        
        function dice = calculateDice(obj, pred, gt)
            % Calcular coeficiente Dice (F1-score para segmentação)
            %
            % Entrada:
            %   pred - Predição do modelo (matriz ou categorical)
            %   gt   - Ground truth (matriz ou categorical)
            %
            % Saída:
            %   dice - Valor Dice (0-1)
            
            try
                % Converter para binário
                predBinary = obj.convertToBinary(pred);
                gtBinary = obj.convertToBinary(gt);
                
                % Validar dimensões
                if ~isequal(size(predBinary), size(gtBinary))
                    error('MetricsCalculator:DimensionMismatch', ...
                          'Predição e ground truth devem ter as mesmas dimensões');
                end
                
                % Calcular Dice
                intersection = sum(predBinary(:) & gtBinary(:));
                total = sum(predBinary(:)) + sum(gtBinary(:));
                
                if total == 0
                    dice = 1; % Ambos são vazios - perfeita concordância
                else
                    dice = 2 * intersection / total;
                end
                
                if obj.verbose
                    fprintf('Dice calculado: %.4f\n', dice);
                end
                
            catch ME
                if obj.verbose
                    fprintf('Erro no cálculo de Dice: %s\n', ME.message);
                end
                dice = 0;
            end
        end
        
        function accuracy = calculateAccuracy(obj, pred, gt)
            % Calcular acurácia pixel-wise
            %
            % Entrada:
            %   pred - Predição do modelo (matriz ou categorical)
            %   gt   - Ground truth (matriz ou categorical)
            %
            % Saída:
            %   accuracy - Valor de acurácia (0-1)
            
            try
                % Converter para binário
                predBinary = obj.convertToBinary(pred);
                gtBinary = obj.convertToBinary(gt);
                
                % Validar dimensões
                if ~isequal(size(predBinary), size(gtBinary))
                    error('MetricsCalculator:DimensionMismatch', ...
                          'Predição e ground truth devem ter as mesmas dimensões');
                end
                
                % Calcular acurácia
                correct = sum(predBinary(:) == gtBinary(:));
                total = numel(predBinary);
                
                accuracy = correct / total;
                
                if obj.verbose
                    fprintf('Accuracy calculada: %.4f\n', accuracy);
                end
                
            catch ME
                if obj.verbose
                    fprintf('Erro no cálculo de Accuracy: %s\n', ME.message);
                end
                accuracy = 0;
            end
        end     
   
        function metrics = calculateAllMetrics(obj, pred, gt)
            % Calcular todas as métricas simultaneamente
            %
            % Entrada:
            %   pred - Predição do modelo (matriz ou categorical)
            %   gt   - Ground truth (matriz ou categorical)
            %
            % Saída:
            %   metrics - Struct com todas as métricas
            %             .iou, .dice, .accuracy
            
            if obj.verbose
                fprintf('Calculando todas as métricas...\n');
            end
            
            % Inicializar estrutura de resultados
            metrics = struct();
            
            % Calcular todas as métricas
            metrics.iou = obj.calculateIoU(pred, gt);
            metrics.dice = obj.calculateDice(pred, gt);
            metrics.accuracy = obj.calculateAccuracy(pred, gt);
            
            % Adicionar informações extras
            try
                metrics.timestamp = datetime('now');
            catch
                % Fallback para sistemas sem datetime (Octave)
                metrics.timestamp = datestr(now);
            end
            metrics.valid = all([metrics.iou >= 0, metrics.dice >= 0, metrics.accuracy >= 0]);
            
            if obj.verbose
                fprintf('Métricas calculadas - IoU: %.4f, Dice: %.4f, Accuracy: %.4f\n', ...
                        metrics.iou, metrics.dice, metrics.accuracy);
            end
        end
        
        function classMetrics = calculateClassMetrics(obj, pred, gt, numClasses)
            % Calcular métricas por classe (para segmentação multi-classe)
            %
            % Entrada:
            %   pred       - Predição do modelo (matriz ou categorical)
            %   gt         - Ground truth (matriz ou categorical)
            %   numClasses - Número de classes (opcional, detectado automaticamente)
            %
            % Saída:
            %   classMetrics - Struct com métricas por classe
            
            try
                % Detectar número de classes se não fornecido
                if nargin < 4
                    try
                        if iscategorical(pred)
                            numClasses = length(categories(pred));
                        elseif iscategorical(gt)
                            numClasses = length(categories(gt));
                        else
                            numClasses = max([max(pred(:)), max(gt(:))]);
                        end
                    catch
                        % Fallback para sistemas sem iscategorical (Octave)
                        numClasses = max([max(pred(:)), max(gt(:))]);
                    end
                end
                
                % Converter para formato numérico se necessário
                try
                    if iscategorical(pred)
                        predNum = double(pred);
                    else
                        predNum = pred;
                    end
                    
                    if iscategorical(gt)
                        gtNum = double(gt);
                    else
                        gtNum = gt;
                    end
                catch
                    % Fallback para sistemas sem iscategorical (Octave)
                    predNum = pred;
                    gtNum = gt;
                end
                
                % Inicializar estrutura de resultados
                classMetrics = struct();
                classMetrics.numClasses = numClasses;
                classMetrics.perClass = struct();
                
                % Calcular métricas para cada classe
                for classIdx = 1:numClasses
                    % Criar máscaras binárias para a classe atual
                    predClass = (predNum == classIdx);
                    gtClass = (gtNum == classIdx);
                    
                    % Calcular métricas para esta classe
                    classMetrics.perClass(classIdx).iou = obj.calculateIoU(predClass, gtClass);
                    classMetrics.perClass(classIdx).dice = obj.calculateDice(predClass, gtClass);
                    classMetrics.perClass(classIdx).accuracy = obj.calculateAccuracy(predClass, gtClass);
                    classMetrics.perClass(classIdx).classId = classIdx;
                end
                
                % Calcular métricas globais (média das classes)
                allIoUs = [classMetrics.perClass.iou];
                allDices = [classMetrics.perClass.dice];
                allAccuracies = [classMetrics.perClass.accuracy];
                
                classMetrics.global.meanIoU = mean(allIoUs);
                classMetrics.global.meanDice = mean(allDices);
                classMetrics.global.meanAccuracy = mean(allAccuracies);
                classMetrics.global.stdIoU = std(allIoUs);
                classMetrics.global.stdDice = std(allDices);
                classMetrics.global.stdAccuracy = std(allAccuracies);
                
                if obj.verbose
                    fprintf('Métricas por classe calculadas para %d classes\n', numClasses);
                    fprintf('IoU médio: %.4f (±%.4f)\n', classMetrics.global.meanIoU, classMetrics.global.stdIoU);
                    fprintf('Dice médio: %.4f (±%.4f)\n', classMetrics.global.meanDice, classMetrics.global.stdDice);
                    fprintf('Accuracy média: %.4f (±%.4f)\n', classMetrics.global.meanAccuracy, classMetrics.global.stdAccuracy);
                end
                
            catch ME
                if obj.verbose
                    fprintf('Erro no cálculo de métricas por classe: %s\n', ME.message);
                end
                classMetrics = struct('error', ME.message);
            end
        end
        
        function batchMetrics = calculateBatchMetrics(obj, predBatch, gtBatch)
            % Calcular métricas para um lote de imagens
            %
            % Entrada:
            %   predBatch - Cell array de predições
            %   gtBatch   - Cell array de ground truths
            %
            % Saída:
            %   batchMetrics - Struct com estatísticas do lote
            
            try
                if length(predBatch) ~= length(gtBatch)
                    error('MetricsCalculator:BatchSizeMismatch', ...
                          'Número de predições deve ser igual ao número de ground truths');
                end
                
                numSamples = length(predBatch);
                
                % Inicializar arrays para armazenar métricas
                ious = zeros(numSamples, 1);
                dices = zeros(numSamples, 1);
                accuracies = zeros(numSamples, 1);
                
                % Calcular métricas para cada amostra
                for i = 1:numSamples
                    metrics = obj.calculateAllMetrics(predBatch{i}, gtBatch{i});
                    ious(i) = metrics.iou;
                    dices(i) = metrics.dice;
                    accuracies(i) = metrics.accuracy;
                end
                
                % Calcular estatísticas do lote
                batchMetrics = struct();
                batchMetrics.numSamples = numSamples;
                
                % Métricas individuais
                batchMetrics.individual.iou = ious;
                batchMetrics.individual.dice = dices;
                batchMetrics.individual.accuracy = accuracies;
                
                % Estatísticas agregadas
                batchMetrics.stats.iou.mean = mean(ious);
                batchMetrics.stats.iou.std = std(ious);
                batchMetrics.stats.iou.min = min(ious);
                batchMetrics.stats.iou.max = max(ious);
                batchMetrics.stats.iou.median = median(ious);
                
                batchMetrics.stats.dice.mean = mean(dices);
                batchMetrics.stats.dice.std = std(dices);
                batchMetrics.stats.dice.min = min(dices);
                batchMetrics.stats.dice.max = max(dices);
                batchMetrics.stats.dice.median = median(dices);
                
                batchMetrics.stats.accuracy.mean = mean(accuracies);
                batchMetrics.stats.accuracy.std = std(accuracies);
                batchMetrics.stats.accuracy.min = min(accuracies);
                batchMetrics.stats.accuracy.max = max(accuracies);
                batchMetrics.stats.accuracy.median = median(accuracies);
                
                if obj.verbose
                    fprintf('Métricas de lote calculadas para %d amostras\n', numSamples);
                    fprintf('IoU: %.4f ± %.4f\n', batchMetrics.stats.iou.mean, batchMetrics.stats.iou.std);
                    fprintf('Dice: %.4f ± %.4f\n', batchMetrics.stats.dice.mean, batchMetrics.stats.dice.std);
                    fprintf('Accuracy: %.4f ± %.4f\n', batchMetrics.stats.accuracy.mean, batchMetrics.stats.accuracy.std);
                end
                
            catch ME
                if obj.verbose
                    fprintf('Erro no cálculo de métricas de lote: %s\n', ME.message);
                end
                batchMetrics = struct('error', ME.message);
            end
        end
    end
    
    methods (Access = private)
        function binary = convertToBinary(obj, input)
            % Converter entrada para formato binário
            %
            % Entrada:
            %   input - Matriz ou categorical
            %
            % Saída:
            %   binary - Matriz binária lógica
            
            try
                try
                    if iscategorical(input)
                        % Para dados categóricos, assumir que classe > 1 é positiva
                        binary = double(input) > 1;
                    elseif islogical(input)
                        % Já é binário
                        binary = input;
                    else
                        % Para dados numéricos, assumir que > 0 é positiva
                        binary = input > 0;
                    end
                catch
                    % Fallback para sistemas sem iscategorical (Octave)
                    if islogical(input)
                        % Já é binário
                        binary = input;
                    else
                        % Para dados numéricos, assumir que > 0 é positiva
                        binary = input > 0;
                    end
                end
                
                % Garantir que é lógico
                binary = logical(binary);
                
            catch ME
                if obj.verbose
                    fprintf('Erro na conversão para binário: %s\n', ME.message);
                end
                binary = false(size(input));
            end
        end
    end
end