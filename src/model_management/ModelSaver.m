classdef ModelSaver < handle
    % ========================================================================
    % MODELSAVER - Sistema de Salvamento Automático de Modelos
    % ========================================================================
    % 
    % AUTOR: Sistema de Melhorias de Segmentação
    % Data: Agosto 2025
    % Versão: 1.0
    %
    % DESCRIÇÃO:
    %   Classe responsável pelo salvamento automático de redes treinadas
    %   incluindo timestamp, métricas e metadados completos
    % ========================================================================
    
    properties (Access = private)
        saveDirectory
        compressionLevel
        metadataEnabled
        maxModels
        versioningEnabled
    end
    
    methods
        function obj = ModelSaver(config)
            % Construtor do ModelSaver
            %
            % Parâmetros:
            %   config - struct com configurações:
            %     .saveDirectory - diretório para salvar modelos (padrão: 'saved_models')
            %     .compressionLevel - nível de compressão (padrão: 6)
            %     .metadataEnabled - habilitar metadados (padrão: true)
            %     .maxModels - máximo de modelos por tipo (padrão: 10)
            %     .versioningEnabled - habilitar versionamento (padrão: true)
            
            if nargin < 1
                config = struct();
            end
            
            % Configurações padrão
            obj.saveDirectory = obj.getConfigValue(config, 'saveDirectory', 'saved_models');
            obj.compressionLevel = obj.getConfigValue(config, 'compressionLevel', 6);
            obj.metadataEnabled = obj.getConfigValue(config, 'metadataEnabled', true);
            obj.maxModels = obj.getConfigValue(config, 'maxModels', 10);
            obj.versioningEnabled = obj.getConfigValue(config, 'versioningEnabled', true);
            
            % Criar diretório se não existir
            if ~exist(obj.saveDirectory, 'dir')
                mkdir(obj.saveDirectory);
                fprintf('✓ Diretório de modelos criado: %s\n', obj.saveDirectory);
            end
        end
        
        function savedPath = saveModel(obj, model, modelType, metrics, trainingConfig)
            % Salvar modelo com metadados completos
            %
            % Parâmetros:
            %   model - rede neural treinada
            %   modelType - tipo do modelo ('unet', 'attention_unet')
            %   metrics - struct com métricas de performance
            %   trainingConfig - configuração usada no treinamento
            %
            % Retorna:
            %   savedPath - caminho do arquivo salvo
            
            try
                % Gerar timestamp
                timestamp = datetime('now', 'Format', 'yyyyMMdd_HHmmss');
                
                % Gerar nome do arquivo
                filename = sprintf('%s_%s.mat', modelType, timestamp);
                savedPath = fullfile(obj.saveDirectory, filename);
                
                % Gerar metadados
                metadata = obj.generateMetadata(model, modelType, metrics, trainingConfig);
                
                % Salvar modelo
                if obj.compressionLevel > 0
                    save(savedPath, 'model', 'metadata', '-v7.3', '-nocompression');
                else
                    save(savedPath, 'model', 'metadata', '-v7.3');
                end
                
                fprintf('✓ Modelo salvo: %s\n', savedPath);
                
                % Salvar metadados separadamente se habilitado
                if obj.metadataEnabled
                    metadataPath = strrep(savedPath, '.mat', '_metadata.json');
                    obj.saveMetadataJSON(metadata, metadataPath);
                end
                
                % Limpeza automática se habilitada
                if obj.versioningEnabled
                    obj.cleanupOldModels(modelType);
                end
                
            catch ME
                fprintf('❌ Erro ao salvar modelo: %s\n', ME.message);
                savedPath = '';
                rethrow(ME);
            end
        end
        
        function success = saveModelWithGradients(obj, model, modelType, metrics, trainingConfig, gradientHistory)
            % Salvar modelo incluindo histórico de gradientes
            %
            % Parâmetros:
            %   model - rede neural treinada
            %   modelType - tipo do modelo
            %   metrics - métricas de performance
            %   trainingConfig - configuração de treinamento
            %   gradientHistory - histórico de gradientes
            %
            % Retorna:
            %   success - true se salvamento foi bem-sucedido
            
            try
                % Gerar timestamp
                timestamp = datetime('now', 'Format', 'yyyyMMdd_HHmmss');
                
                % Gerar nome do arquivo
                filename = sprintf('%s_%s_with_gradients.mat', modelType, timestamp);
                savedPath = fullfile(obj.saveDirectory, filename);
                
                % Gerar metadados
                metadata = obj.generateMetadata(model, modelType, metrics, trainingConfig);
                metadata.hasGradients = true;
                metadata.gradientStats = obj.analyzeGradients(gradientHistory);
                
                % Salvar modelo com gradientes
                save(savedPath, 'model', 'metadata', 'gradientHistory', '-v7.3');
                
                fprintf('✓ Modelo com gradientes salvo: %s\n', savedPath);
                
                % Salvar metadados JSON
                if obj.metadataEnabled
                    metadataPath = strrep(savedPath, '.mat', '_metadata.json');
                    obj.saveMetadataJSON(metadata, metadataPath);
                end
                
                success = true;
                
            catch ME
                fprintf('❌ Erro ao salvar modelo com gradientes: %s\n', ME.message);
                success = false;
            end
        end
        
        function cleanupOldModels(obj, modelType)
            % Limpeza automática de modelos antigos
            %
            % Parâmetros:
            %   modelType - tipo do modelo para limpeza
            
            try
                % Listar modelos do tipo especificado
                pattern = sprintf('%s_*.mat', modelType);
                files = dir(fullfile(obj.saveDirectory, pattern));
                
                if length(files) > obj.maxModels
                    % Ordenar por data de modificação
                    [~, idx] = sort([files.datenum]);
                    files = files(idx);
                    
                    % Remover modelos mais antigos
                    numToRemove = length(files) - obj.maxModels;
                    for i = 1:numToRemove
                        filePath = fullfile(obj.saveDirectory, files(i).name);
                        delete(filePath);
                        
                        % Remover metadados associados
                        metadataPath = strrep(filePath, '.mat', '_metadata.json');
                        if exist(metadataPath, 'file')
                            delete(metadataPath);
                        end
                        
                        fprintf('🗑 Modelo antigo removido: %s\n', files(i).name);
                    end
                end
                
            catch ME
                fprintf('⚠ Erro na limpeza de modelos: %s\n', ME.message);
            end
        end
        
        function metadata = generateMetadata(obj, model, modelType, metrics, trainingConfig)
            % Gerar metadados completos do modelo
            %
            % Parâmetros:
            %   model - rede neural
            %   modelType - tipo do modelo
            %   metrics - métricas de performance
            %   trainingConfig - configuração de treinamento
            %
            % Retorna:
            %   metadata - struct com metadados completos
            
            metadata = struct();
            
            % Informações básicas
            metadata.modelType = modelType;
            metadata.timestamp = datetime('now');
            metadata.version = '1.0';
            metadata.hasGradients = false;
            
            % Configuração de treinamento
            if exist('trainingConfig', 'var') && ~isempty(trainingConfig)
                metadata.trainingConfig = trainingConfig;
            else
                metadata.trainingConfig = struct();
            end
            
            % Arquitetura da rede
            try
                if isa(model, 'SeriesNetwork') || isa(model, 'DAGNetwork')
                    metadata.architecture.type = class(model);
                    metadata.architecture.numLayers = numel(model.Layers);
                    metadata.architecture.inputSize = model.Layers(1).InputSize;
                    
                    % Contar parâmetros treináveis
                    totalParams = 0;
                    for i = 1:numel(model.Layers)
                        layer = model.Layers(i);
                        if isprop(layer, 'Weights') && ~isempty(layer.Weights)
                            totalParams = totalParams + numel(layer.Weights);
                        end
                        if isprop(layer, 'Bias') && ~isempty(layer.Bias)
                            totalParams = totalParams + numel(layer.Bias);
                        end
                    end
                    metadata.architecture.totalParameters = totalParams;
                end
            catch
                metadata.architecture = struct('type', 'unknown');
            end
            
            % Métricas de performance
            if exist('metrics', 'var') && ~isempty(metrics)
                metadata.performance = metrics;
            else
                metadata.performance = struct();
            end
            
            % Informações do sistema
            metadata.systemInfo = obj.getSystemInfo();
            
            % Informações do dataset (se disponível)
            if isfield(trainingConfig, 'imageDir')
                metadata.datasetInfo.imageDir = trainingConfig.imageDir;
                metadata.datasetInfo.maskDir = trainingConfig.maskDir;
                
                % Contar arquivos no dataset
                try
                    imgFiles = dir(fullfile(trainingConfig.imageDir, '*.{png,jpg,jpeg}'));
                    metadata.datasetInfo.numImages = length(imgFiles);
                catch
                    metadata.datasetInfo.numImages = 0;
                end
            end
        end
        
        function saveMetadataJSON(obj, metadata, filepath)
            % Salvar metadados em formato JSON
            %
            % Parâmetros:
            %   metadata - struct com metadados
            %   filepath - caminho do arquivo JSON
            
            try
                % Converter datetime para string para JSON
                metadataForJSON = obj.convertDatetimeForJSON(metadata);
                
                % Escrever JSON
                jsonStr = jsonencode(metadataForJSON, 'PrettyPrint', true);
                fid = fopen(filepath, 'w');
                if fid ~= -1
                    fprintf(fid, '%s', jsonStr);
                    fclose(fid);
                    fprintf('✓ Metadados JSON salvos: %s\n', filepath);
                end
                
            catch ME
                fprintf('⚠ Erro ao salvar metadados JSON: %s\n', ME.message);
            end
        end
    end
    
    methods (Access = private)
        function value = getConfigValue(obj, config, fieldName, defaultValue)
            % Obter valor de configuração com fallback para padrão
            if isfield(config, fieldName)
                value = config.(fieldName);
            else
                value = defaultValue;
            end
        end
        
        function systemInfo = getSystemInfo(obj)
            % Obter informações do sistema
            systemInfo = struct();
            
            try
                systemInfo.matlab_version = version;
                systemInfo.computer_type = computer;
                systemInfo.hostname = getenv('COMPUTERNAME');
                if isempty(systemInfo.hostname)
                    systemInfo.hostname = getenv('HOSTNAME');
                end
                systemInfo.timestamp = datetime('now');
                
                % Informações de memória (se disponível)
                try
                    [~, memInfo] = memory;
                    systemInfo.memory_available = memInfo.MemAvailableAllArrays;
                catch
                    systemInfo.memory_available = 'unknown';
                end
                
            catch
                systemInfo.error = 'Could not retrieve system info';
            end
        end
        
        function gradientStats = analyzeGradients(obj, gradientHistory)
            % Analisar estatísticas dos gradientes
            gradientStats = struct();
            
            try
                if ~isempty(gradientHistory)
                    % Calcular estatísticas básicas
                    allGrads = [];
                    for i = 1:length(gradientHistory)
                        if isstruct(gradientHistory{i})
                            fields = fieldnames(gradientHistory{i});
                            for j = 1:length(fields)
                                grad = gradientHistory{i}.(fields{j});
                                if isnumeric(grad)
                                    allGrads = [allGrads; grad(:)];
                                end
                            end
                        end
                    end
                    
                    if ~isempty(allGrads)
                        gradientStats.mean = mean(allGrads);
                        gradientStats.std = std(allGrads);
                        gradientStats.min = min(allGrads);
                        gradientStats.max = max(allGrads);
                        gradientStats.num_epochs = length(gradientHistory);
                    end
                end
            catch
                gradientStats.error = 'Could not analyze gradients';
            end
        end
        
        function metadataOut = convertDatetimeForJSON(obj, metadata)
            % Converter campos datetime para string para compatibilidade JSON
            metadataOut = metadata;
            
            fields = fieldnames(metadata);
            for i = 1:length(fields)
                field = fields{i};
                value = metadata.(field);
                
                if isa(value, 'datetime')
                    metadataOut.(field) = char(value);
                elseif isstruct(value)
                    metadataOut.(field) = obj.convertDatetimeForJSON(value);
                end
            end
        end
    end
end