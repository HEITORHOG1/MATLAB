classdef ModelLoader < handle
    % ========================================================================
    % MODELLOADER - Sistema de Carregamento de Modelos Pré-treinados
    % ========================================================================
    % 
    % AUTOR: Sistema de Melhorias de Segmentação
    % Data: Agosto 2025
    % Versão: 1.0
    %
    % DESCRIÇÃO:
    %   Classe responsável pelo carregamento seguro de modelos pré-treinados
    %   com validação de compatibilidade e listagem de modelos disponíveis
    % ========================================================================
    
    methods (Static)
        function [model, metadata] = loadModel(modelPath)
            % Carregar modelo de arquivo com validação
            %
            % Parâmetros:
            %   modelPath - caminho para o arquivo do modelo
            %
            % Retorna:
            %   model - rede neural carregada
            %   metadata - metadados do modelo
            
            model = [];
            metadata = [];
            
            try
                % Verificar se arquivo existe
                if ~exist(modelPath, 'file')
                    error('Arquivo de modelo não encontrado: %s', modelPath);
                end
                
                fprintf('Carregando modelo: %s\n', modelPath);
                
                % Carregar arquivo
                loadedData = load(modelPath);
                
                % Verificar se contém modelo
                if isfield(loadedData, 'model')
                    model = loadedData.model;
                elseif isfield(loadedData, 'net')
                    model = loadedData.net;
                elseif isfield(loadedData, 'netUNet')
                    model = loadedData.netUNet;
                elseif isfield(loadedData, 'netAttUNet')
                    model = loadedData.netAttUNet;
                else
                    error('Nenhum modelo encontrado no arquivo');
                end
                
                % Carregar metadados se disponíveis
                if isfield(loadedData, 'metadata')
                    metadata = loadedData.metadata;
                else
                    % Gerar metadados básicos se não existirem
                    metadata = ModelLoader.generateBasicMetadata(model, modelPath);
                end
                
                % Validar modelo carregado
                if ModelLoader.validateModel(model)
                    fprintf('✓ Modelo carregado com sucesso!\n');
                    ModelLoader.displayModelInfo(model, metadata);
                else
                    error('Modelo carregado é inválido');
                end
                
            catch ME
                fprintf('❌ Erro ao carregar modelo: %s\n', ME.message);
                rethrow(ME);
            end
        end
        
        function models = listAvailableModels(directory)
            % Listar modelos disponíveis em um diretório
            %
            % Parâmetros:
            %   directory - diretório para buscar modelos (padrão: 'saved_models')
            %
            % Retorna:
            %   models - array de structs com informações dos modelos
            
            if nargin < 1
                directory = 'saved_models';
            end
            
            models = [];
            
            try
                if ~exist(directory, 'dir')
                    fprintf('⚠ Diretório não encontrado: %s\n', directory);
                    return;
                end
                
                % Buscar arquivos .mat
                modelFiles = dir(fullfile(directory, '*.mat'));
                
                if isempty(modelFiles)
                    fprintf('Nenhum modelo encontrado em: %s\n', directory);
                    return;
                end
                
                fprintf('Modelos disponíveis em %s:\n', directory);
                fprintf('%-40s %-15s %-20s %-10s\n', 'Arquivo', 'Tipo', 'Data', 'Tamanho');
                fprintf('%s\n', repmat('-', 1, 85));
                
                models = struct('filename', {}, 'filepath', {}, 'type', {}, ...
                              'date', {}, 'size', {}, 'metadata', {});
                
                for i = 1:length(modelFiles)
                    file = modelFiles(i);
                    filepath = fullfile(directory, file.name);
                    
                    % Extrair tipo do modelo do nome do arquivo
                    modelType = ModelLoader.extractModelType(file.name);
                    
                    % Tentar carregar metadados
                    try
                        loadedData = load(filepath, 'metadata');
                        if isfield(loadedData, 'metadata')
                            metadata = loadedData.metadata;
                        else
                            metadata = struct();
                        end
                    catch
                        metadata = struct();
                    end
                    
                    % Adicionar à lista
                    models(end+1) = struct( ...
                        'filename', file.name, ...
                        'filepath', filepath, ...
                        'type', modelType, ...
                        'date', datetime(file.datenum, 'ConvertFrom', 'datenum'), ...
                        'size', file.bytes, ...
                        'metadata', metadata ...
                    );
                    
                    % Exibir informações
                    sizeStr = ModelLoader.formatFileSize(file.bytes);
                    dateStr = datestr(file.datenum, 'yyyy-mm-dd HH:MM');
                    
                    fprintf('%-40s %-15s %-20s %-10s\n', ...
                        file.name, modelType, dateStr, sizeStr);
                end
                
                fprintf('\nTotal: %d modelos encontrados\n', length(models));
                
            catch ME
                fprintf('❌ Erro ao listar modelos: %s\n', ME.message);
            end
        end
        
        function isValid = validateModelCompatibility(modelPath, currentConfig)
            % Validar compatibilidade do modelo com configuração atual
            %
            % Parâmetros:
            %   modelPath - caminho do modelo
            %   currentConfig - configuração atual do sistema
            %
            % Retorna:
            %   isValid - true se modelo é compatível
            
            isValid = false;
            
            try
                % Carregar metadados do modelo
                loadedData = load(modelPath, 'metadata');
                
                if ~isfield(loadedData, 'metadata')
                    fprintf('⚠ Metadados não encontrados, assumindo compatibilidade\n');
                    isValid = true;
                    return;
                end
                
                metadata = loadedData.metadata;
                
                % Verificar compatibilidade de tamanho de entrada
                if isfield(metadata, 'architecture') && isfield(metadata.architecture, 'inputSize')
                    modelInputSize = metadata.architecture.inputSize;
                    if isfield(currentConfig, 'inputSize')
                        currentInputSize = currentConfig.inputSize;
                        
                        if ~isequal(modelInputSize, currentInputSize)
                            fprintf('⚠ Incompatibilidade de tamanho de entrada:\n');
                            fprintf('  Modelo: %s\n', mat2str(modelInputSize));
                            fprintf('  Atual: %s\n', mat2str(currentInputSize));
                            
                            % Perguntar ao usuário se deseja continuar
                            response = input('Continuar mesmo assim? (y/n): ', 's');
                            if ~strcmpi(response, 'y')
                                return;
                            end
                        end
                    end
                end
                
                % Verificar compatibilidade de número de classes
                if isfield(metadata, 'trainingConfig') && isfield(metadata.trainingConfig, 'numClasses')
                    modelNumClasses = metadata.trainingConfig.numClasses;
                    if isfield(currentConfig, 'numClasses')
                        currentNumClasses = currentConfig.numClasses;
                        
                        if modelNumClasses ~= currentNumClasses
                            fprintf('⚠ Incompatibilidade de número de classes:\n');
                            fprintf('  Modelo: %d\n', modelNumClasses);
                            fprintf('  Atual: %d\n', currentNumClasses);
                            
                            response = input('Continuar mesmo assim? (y/n): ', 's');
                            if ~strcmpi(response, 'y')
                                return;
                            end
                        end
                    end
                end
                
                fprintf('✓ Modelo compatível com configuração atual\n');
                isValid = true;
                
            catch ME
                fprintf('❌ Erro na validação de compatibilidade: %s\n', ME.message);
            end
        end
        
        function [model, metadata] = loadBestModel(directory, metric)
            % Carregar o melhor modelo baseado em uma métrica
            %
            % Parâmetros:
            %   directory - diretório dos modelos (padrão: 'saved_models')
            %   metric - métrica para seleção ('iou_mean', 'dice_mean', 'acc_mean')
            %
            % Retorna:
            %   model - melhor modelo encontrado
            %   metadata - metadados do melhor modelo
            
            if nargin < 1
                directory = 'saved_models';
            end
            if nargin < 2
                metric = 'iou_mean';
            end
            
            model = [];
            metadata = [];
            
            try
                % Listar modelos disponíveis
                models = ModelLoader.listAvailableModels(directory);
                
                if isempty(models)
                    fprintf('Nenhum modelo encontrado para seleção\n');
                    return;
                end
                
                % Encontrar melhor modelo baseado na métrica
                bestValue = -inf;
                bestModelIdx = 0;
                
                for i = 1:length(models)
                    modelMetadata = models(i).metadata;
                    
                    if isfield(modelMetadata, 'performance') && ...
                       isfield(modelMetadata.performance, metric)
                        
                        value = modelMetadata.performance.(metric);
                        if value > bestValue
                            bestValue = value;
                            bestModelIdx = i;
                        end
                    end
                end
                
                if bestModelIdx > 0
                    bestModel = models(bestModelIdx);
                    fprintf('Melhor modelo encontrado: %s\n', bestModel.filename);
                    fprintf('Métrica %s: %.4f\n', metric, bestValue);
                    
                    % Carregar o melhor modelo
                    [model, metadata] = ModelLoader.loadModel(bestModel.filepath);
                else
                    fprintf('⚠ Nenhum modelo com métrica %s encontrado\n', metric);
                end
                
            catch ME
                fprintf('❌ Erro ao carregar melhor modelo: %s\n', ME.message);
            end
        end
        
        function [model, gradients, metadata] = loadModelWithGradients(modelPath)
            % Carregar modelo incluindo histórico de gradientes
            %
            % Parâmetros:
            %   modelPath - caminho do modelo
            %
            % Retorna:
            %   model - rede neural
            %   gradients - histórico de gradientes
            %   metadata - metadados do modelo
            
            model = [];
            gradients = [];
            metadata = [];
            
            try
                % Carregar arquivo
                loadedData = load(modelPath);
                
                % Extrair modelo
                if isfield(loadedData, 'model')
                    model = loadedData.model;
                else
                    error('Modelo não encontrado no arquivo');
                end
                
                % Extrair gradientes
                if isfield(loadedData, 'gradientHistory')
                    gradients = loadedData.gradientHistory;
                    fprintf('✓ Histórico de gradientes carregado\n');
                else
                    fprintf('⚠ Nenhum histórico de gradientes encontrado\n');
                end
                
                % Extrair metadados
                if isfield(loadedData, 'metadata')
                    metadata = loadedData.metadata;
                end
                
                fprintf('✓ Modelo com gradientes carregado: %s\n', modelPath);
                
            catch ME
                fprintf('❌ Erro ao carregar modelo com gradientes: %s\n', ME.message);
                rethrow(ME);
            end
        end
    end
    
    methods (Static, Access = private)
        function isValid = validateModel(model)
            % Validar se o modelo carregado é válido
            isValid = false;
            
            try
                if isa(model, 'SeriesNetwork') || isa(model, 'DAGNetwork')
                    % Verificar se tem camadas
                    if ~isempty(model.Layers)
                        isValid = true;
                    end
                elseif isa(model, 'dlnetwork')
                    isValid = true;
                end
            catch
                % Modelo inválido
            end
        end
        
        function displayModelInfo(model, metadata)
            % Exibir informações do modelo carregado
            
            fprintf('\n--- Informações do Modelo ---\n');
            
            try
                % Informações básicas
                if ~isempty(metadata)
                    if isfield(metadata, 'modelType')
                        fprintf('Tipo: %s\n', metadata.modelType);
                    end
                    if isfield(metadata, 'timestamp')
                        fprintf('Data de criação: %s\n', metadata.timestamp);
                    end
                end
                
                % Informações da arquitetura
                if isa(model, 'SeriesNetwork') || isa(model, 'DAGNetwork')
                    fprintf('Arquitetura: %s\n', class(model));
                    fprintf('Número de camadas: %d\n', numel(model.Layers));
                    
                    if ~isempty(model.Layers)
                        inputLayer = model.Layers(1);
                        if isprop(inputLayer, 'InputSize')
                            fprintf('Tamanho de entrada: %s\n', mat2str(inputLayer.InputSize));
                        end
                    end
                end
                
                % Métricas de performance
                if ~isempty(metadata) && isfield(metadata, 'performance')
                    perf = metadata.performance;
                    fprintf('\n--- Métricas de Performance ---\n');
                    
                    if isfield(perf, 'iou_mean')
                        fprintf('IoU: %.4f ± %.4f\n', perf.iou_mean, ...
                               getfield(perf, 'iou_std', 0));
                    end
                    if isfield(perf, 'dice_mean')
                        fprintf('Dice: %.4f ± %.4f\n', perf.dice_mean, ...
                               getfield(perf, 'dice_std', 0));
                    end
                    if isfield(perf, 'acc_mean')
                        fprintf('Acurácia: %.4f ± %.4f\n', perf.acc_mean, ...
                               getfield(perf, 'acc_std', 0));
                    end
                end
                
            catch ME
                fprintf('⚠ Erro ao exibir informações: %s\n', ME.message);
            end
            
            fprintf('-----------------------------\n\n');
        end
        
        function modelType = extractModelType(filename)
            % Extrair tipo do modelo do nome do arquivo
            
            filename = lower(filename);
            
            if contains(filename, 'attention')
                modelType = 'attention_unet';
            elseif contains(filename, 'unet')
                modelType = 'unet';
            else
                modelType = 'unknown';
            end
        end
        
        function sizeStr = formatFileSize(bytes)
            % Formatar tamanho do arquivo em formato legível
            
            if bytes < 1024
                sizeStr = sprintf('%d B', bytes);
            elseif bytes < 1024^2
                sizeStr = sprintf('%.1f KB', bytes/1024);
            elseif bytes < 1024^3
                sizeStr = sprintf('%.1f MB', bytes/1024^2);
            else
                sizeStr = sprintf('%.1f GB', bytes/1024^3);
            end
        end
        
        function metadata = generateBasicMetadata(model, modelPath)
            % Gerar metadados básicos para modelo sem metadados
            
            metadata = struct();
            metadata.modelType = ModelLoader.extractModelType(modelPath);
            metadata.timestamp = datetime('now');
            metadata.version = 'unknown';
            metadata.source = 'loaded_without_metadata';
            
            % Informações da arquitetura
            try
                if isa(model, 'SeriesNetwork') || isa(model, 'DAGNetwork')
                    metadata.architecture.type = class(model);
                    metadata.architecture.numLayers = numel(model.Layers);
                    if ~isempty(model.Layers)
                        inputLayer = model.Layers(1);
                        if isprop(inputLayer, 'InputSize')
                            metadata.architecture.inputSize = inputLayer.InputSize;
                        end
                    end
                end
            catch
                metadata.architecture = struct('type', 'unknown');
            end
        end
    end
end

function value = getfield(s, field, defaultValue)
    % Função auxiliar para obter campo com valor padrão
    if isfield(s, field)
        value = s.(field);
    else
        value = defaultValue;
    end
end