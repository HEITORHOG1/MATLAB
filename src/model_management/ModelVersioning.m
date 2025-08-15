classdef ModelVersioning < handle
    % ========================================================================
    % MODELVERSIONING - Sistema de Versionamento Automático de Modelos
    % ========================================================================
    % 
    % AUTOR: Sistema de Melhorias de Segmentação
    % Data: Agosto 2025
    % Versão: 1.0
    %
    % DESCRIÇÃO:
    %   Classe responsável pelo versionamento automático e limpeza
    %   inteligente de modelos antigos
    % ========================================================================
    
    properties (Access = private)
        baseDirectory
        maxVersionsPerModel
        compressionEnabled
        backupEnabled
        retentionDays
    end
    
    methods
        function obj = ModelVersioning(config)
            % Construtor do ModelVersioning
            %
            % Parâmetros:
            %   config - struct com configurações:
            %     .baseDirectory - diretório base (padrão: 'saved_models')
            %     .maxVersionsPerModel - máximo de versões por modelo (padrão: 5)
            %     .compressionEnabled - habilitar compressão (padrão: true)
            %     .backupEnabled - habilitar backup (padrão: true)
            %     .retentionDays - dias de retenção (padrão: 30)
            
            if nargin < 1
                config = struct();
            end
            
            % Configurações padrão
            obj.baseDirectory = obj.getConfigValue(config, 'baseDirectory', 'saved_models');
            obj.maxVersionsPerModel = obj.getConfigValue(config, 'maxVersionsPerModel', 5);
            obj.compressionEnabled = obj.getConfigValue(config, 'compressionEnabled', true);
            obj.backupEnabled = obj.getConfigValue(config, 'backupEnabled', true);
            obj.retentionDays = obj.getConfigValue(config, 'retentionDays', 30);
            
            % Criar estrutura de diretórios
            obj.createDirectoryStructure();
        end
        
        function versionPath = createNewVersion(obj, modelPath, modelType)
            % Criar nova versão de um modelo
            %
            % Parâmetros:
            %   modelPath - caminho do modelo atual
            %   modelType - tipo do modelo
            %
            % Retorna:
            %   versionPath - caminho da nova versão criada
            
            try
                % Criar diretório de versões para o tipo de modelo
                versionDir = fullfile(obj.baseDirectory, 'versions', modelType);
                if ~exist(versionDir, 'dir')
                    mkdir(versionDir);
                end
                
                % Gerar nome da versão
                timestamp = datetime('now', 'Format', 'yyyyMMdd_HHmmss');
                versionNumber = obj.getNextVersionNumber(modelType);
                
                versionFilename = sprintf('%s_v%03d_%s.mat', modelType, versionNumber, timestamp);
                versionPath = fullfile(versionDir, versionFilename);
                
                % Copiar modelo para versão
                if exist(modelPath, 'file')
                    copyfile(modelPath, versionPath);
                    
                    % Comprimir se habilitado
                    if obj.compressionEnabled
                        obj.compressVersion(versionPath);
                    end
                    
                    fprintf('✓ Nova versão criada: %s\n', versionFilename);
                    
                    % Limpeza automática
                    obj.cleanupOldVersions(modelType);
                else
                    error('Arquivo de modelo não encontrado: %s', modelPath);
                end
                
            catch ME
                fprintf('❌ Erro ao criar versão: %s\n', ME.message);
                versionPath = '';
                rethrow(ME);
            end
        end
        
        function versions = listVersions(obj, modelType)
            % Listar versões disponíveis de um tipo de modelo
            %
            % Parâmetros:
            %   modelType - tipo do modelo (opcional, lista todos se vazio)
            %
            % Retorna:
            %   versions - array de structs com informações das versões
            
            versions = [];
            
            try
                if nargin < 2 || isempty(modelType)
                    % Listar todas as versões
                    versionBaseDir = fullfile(obj.baseDirectory, 'versions');
                    if ~exist(versionBaseDir, 'dir')
                        fprintf('Nenhuma versão encontrada\n');
                        return;
                    end
                    
                    modelTypes = dir(versionBaseDir);
                    modelTypes = modelTypes([modelTypes.isdir] & ~startsWith({modelTypes.name}, '.'));
                    
                    for i = 1:length(modelTypes)
                        typeVersions = obj.listVersions(modelTypes(i).name);
                        versions = [versions, typeVersions];
                    end
                else
                    % Listar versões de um tipo específico
                    versionDir = fullfile(obj.baseDirectory, 'versions', modelType);
                    if ~exist(versionDir, 'dir')
                        fprintf('Nenhuma versão encontrada para %s\n', modelType);
                        return;
                    end
                    
                    versionFiles = dir(fullfile(versionDir, '*.mat'));
                    
                    fprintf('Versões disponíveis para %s:\n', modelType);
                    fprintf('%-30s %-10s %-20s %-10s\n', 'Arquivo', 'Versão', 'Data', 'Tamanho');
                    fprintf('%s\n', repmat('-', 1, 70));
                    
                    for i = 1:length(versionFiles)
                        file = versionFiles(i);
                        filepath = fullfile(versionDir, file.name);
                        
                        % Extrair número da versão
                        versionNum = obj.extractVersionNumber(file.name);
                        
                        % Criar struct da versão
                        version = struct( ...
                            'filename', file.name, ...
                            'filepath', filepath, ...
                            'modelType', modelType, ...
                            'version', versionNum, ...
                            'date', datetime(file.datenum, 'ConvertFrom', 'datenum'), ...
                            'size', file.bytes ...
                        );
                        
                        versions = [versions, version];
                        
                        % Exibir informações
                        sizeStr = obj.formatFileSize(file.bytes);
                        dateStr = datestr(file.datenum, 'yyyy-mm-dd HH:MM');
                        
                        fprintf('%-30s v%-8d %-20s %-10s\n', ...
                            file.name, versionNum, dateStr, sizeStr);
                    end
                    
                    if ~isempty(versions)
                        fprintf('\nTotal: %d versões encontradas\n', length(versions));
                    end
                end
                
            catch ME
                fprintf('❌ Erro ao listar versões: %s\n', ME.message);
            end
        end
        
        function [model, metadata] = restoreVersion(obj, modelType, versionNumber)
            % Restaurar uma versão específica de um modelo
            %
            % Parâmetros:
            %   modelType - tipo do modelo
            %   versionNumber - número da versão a restaurar
            %
            % Retorna:
            %   model - modelo restaurado
            %   metadata - metadados da versão
            
            model = [];
            metadata = [];
            
            try
                % Encontrar arquivo da versão
                versionDir = fullfile(obj.baseDirectory, 'versions', modelType);
                versionFiles = dir(fullfile(versionDir, sprintf('%s_v%03d_*.mat', modelType, versionNumber)));
                
                if isempty(versionFiles)
                    error('Versão %d não encontrada para %s', versionNumber, modelType);
                end
                
                % Usar o arquivo mais recente se houver múltiplos
                [~, idx] = max([versionFiles.datenum]);
                versionFile = versionFiles(idx);
                versionPath = fullfile(versionDir, versionFile.name);
                
                fprintf('Restaurando versão %d de %s...\n', versionNumber, modelType);
                
                % Carregar modelo da versão
                [model, metadata] = ModelLoader.loadModel(versionPath);
                
                % Criar backup da versão atual se habilitado
                if obj.backupEnabled
                    currentModelPath = fullfile(obj.baseDirectory, sprintf('%s_current.mat', modelType));
                    if exist(currentModelPath, 'file')
                        backupPath = obj.createBackup(currentModelPath, modelType);
                        fprintf('✓ Backup da versão atual criado: %s\n', backupPath);
                    end
                end
                
                % Salvar como versão atual
                currentPath = fullfile(obj.baseDirectory, sprintf('%s_current.mat', modelType));
                copyfile(versionPath, currentPath);
                
                fprintf('✓ Versão %d restaurada com sucesso!\n', versionNumber);
                
            catch ME
                fprintf('❌ Erro ao restaurar versão: %s\n', ME.message);
                rethrow(ME);
            end
        end
        
        function cleanupOldVersions(obj, modelType)
            % Limpeza automática de versões antigas
            %
            % Parâmetros:
            %   modelType - tipo do modelo para limpeza
            
            try
                versionDir = fullfile(obj.baseDirectory, 'versions', modelType);
                if ~exist(versionDir, 'dir')
                    return;
                end
                
                % Listar versões
                versionFiles = dir(fullfile(versionDir, '*.mat'));
                
                if length(versionFiles) > obj.maxVersionsPerModel
                    % Ordenar por data de modificação (mais antigos primeiro)
                    [~, idx] = sort([versionFiles.datenum]);
                    versionFiles = versionFiles(idx);
                    
                    % Remover versões mais antigas
                    numToRemove = length(versionFiles) - obj.maxVersionsPerModel;
                    
                    for i = 1:numToRemove
                        filePath = fullfile(versionDir, versionFiles(i).name);
                        
                        % Verificar se não é uma versão importante (marcos)
                        if ~obj.isImportantVersion(versionFiles(i))
                            delete(filePath);
                            fprintf('🗑 Versão antiga removida: %s\n', versionFiles(i).name);
                        end
                    end
                end
                
                % Limpeza baseada em tempo de retenção
                obj.cleanupByRetentionPolicy(modelType);
                
            catch ME
                fprintf('⚠ Erro na limpeza de versões: %s\n', ME.message);
            end
        end
        
        function compressOldVersions(obj, modelType, daysOld)
            % Comprimir versões antigas para economizar espaço
            %
            % Parâmetros:
            %   modelType - tipo do modelo
            %   daysOld - idade em dias para compressão (padrão: 7)
            
            if nargin < 3
                daysOld = 7;
            end
            
            try
                versionDir = fullfile(obj.baseDirectory, 'versions', modelType);
                if ~exist(versionDir, 'dir')
                    return;
                end
                
                versionFiles = dir(fullfile(versionDir, '*.mat'));
                cutoffDate = datetime('now') - days(daysOld);
                
                for i = 1:length(versionFiles)
                    file = versionFiles(i);
                    fileDate = datetime(file.datenum, 'ConvertFrom', 'datenum');
                    
                    if fileDate < cutoffDate && ~contains(file.name, '_compressed')
                        filePath = fullfile(versionDir, file.name);
                        obj.compressVersion(filePath);
                    end
                end
                
            catch ME
                fprintf('⚠ Erro na compressão de versões: %s\n', ME.message);
            end
        end
        
        function generateVersionReport(obj)
            % Gerar relatório de versões e uso de espaço
            
            try
                fprintf('\n=== RELATÓRIO DE VERSIONAMENTO ===\n');
                
                versionBaseDir = fullfile(obj.baseDirectory, 'versions');
                if ~exist(versionBaseDir, 'dir')
                    fprintf('Nenhuma versão encontrada\n');
                    return;
                end
                
                % Listar tipos de modelo
                modelTypes = dir(versionBaseDir);
                modelTypes = modelTypes([modelTypes.isdir] & ~startsWith({modelTypes.name}, '.'));
                
                totalSize = 0;
                totalVersions = 0;
                
                for i = 1:length(modelTypes)
                    modelType = modelTypes(i).name;
                    versionDir = fullfile(versionBaseDir, modelType);
                    
                    versionFiles = dir(fullfile(versionDir, '*.mat'));
                    typeSize = sum([versionFiles.bytes]);
                    
                    fprintf('\n%s:\n', upper(modelType));
                    fprintf('  Versões: %d\n', length(versionFiles));
                    fprintf('  Tamanho total: %s\n', obj.formatFileSize(typeSize));
                    
                    if ~isempty(versionFiles)
                        % Versão mais antiga e mais recente
                        [~, oldestIdx] = min([versionFiles.datenum]);
                        [~, newestIdx] = max([versionFiles.datenum]);
                        
                        fprintf('  Mais antiga: %s\n', datestr(versionFiles(oldestIdx).datenum));
                        fprintf('  Mais recente: %s\n', datestr(versionFiles(newestIdx).datenum));
                    end
                    
                    totalSize = totalSize + typeSize;
                    totalVersions = totalVersions + length(versionFiles);
                end
                
                fprintf('\n--- RESUMO GERAL ---\n');
                fprintf('Total de versões: %d\n', totalVersions);
                fprintf('Espaço total usado: %s\n', obj.formatFileSize(totalSize));
                fprintf('Política de retenção: %d dias\n', obj.retentionDays);
                fprintf('Máximo de versões por modelo: %d\n', obj.maxVersionsPerModel);
                
                % Sugestões de limpeza
                if totalVersions > obj.maxVersionsPerModel * length(modelTypes)
                    fprintf('\n💡 Sugestão: Execute limpeza automática para liberar espaço\n');
                end
                
                fprintf('================================\n\n');
                
            catch ME
                fprintf('❌ Erro ao gerar relatório: %s\n', ME.message);
            end
        end
    end
    
    methods (Access = private)
        function createDirectoryStructure(obj)
            % Criar estrutura de diretórios necessária
            
            dirs = {
                obj.baseDirectory,
                fullfile(obj.baseDirectory, 'versions'),
                fullfile(obj.baseDirectory, 'backups')
            };
            
            for i = 1:length(dirs)
                if ~exist(dirs{i}, 'dir')
                    mkdir(dirs{i});
                end
            end
        end
        
        function value = getConfigValue(obj, config, fieldName, defaultValue)
            % Obter valor de configuração com fallback
            if isfield(config, fieldName)
                value = config.(fieldName);
            else
                value = defaultValue;
            end
        end
        
        function versionNumber = getNextVersionNumber(obj, modelType)
            % Obter próximo número de versão
            
            versionDir = fullfile(obj.baseDirectory, 'versions', modelType);
            if ~exist(versionDir, 'dir')
                versionNumber = 1;
                return;
            end
            
            versionFiles = dir(fullfile(versionDir, '*.mat'));
            
            if isempty(versionFiles)
                versionNumber = 1;
            else
                % Extrair números de versão existentes
                versions = [];
                for i = 1:length(versionFiles)
                    vNum = obj.extractVersionNumber(versionFiles(i).name);
                    if ~isempty(vNum)
                        versions = [versions, vNum];
                    end
                end
                
                if isempty(versions)
                    versionNumber = 1;
                else
                    versionNumber = max(versions) + 1;
                end
            end
        end
        
        function versionNum = extractVersionNumber(obj, filename)
            % Extrair número da versão do nome do arquivo
            
            % Padrão: modeltype_v001_timestamp.mat
            pattern = '_v(\d+)_';
            tokens = regexp(filename, pattern, 'tokens');
            
            if ~isempty(tokens)
                versionNum = str2double(tokens{1}{1});
            else
                versionNum = [];
            end
        end
        
        function compressVersion(obj, versionPath)
            % Comprimir uma versão específica
            
            try
                % Carregar dados
                data = load(versionPath);
                
                % Salvar com compressão
                compressedPath = strrep(versionPath, '.mat', '_compressed.mat');
                save(compressedPath, '-struct', 'data', '-v7.3');
                
                % Remover versão não comprimida se compressão foi bem-sucedida
                if exist(compressedPath, 'file')
                    delete(versionPath);
                    movefile(compressedPath, versionPath);
                    fprintf('✓ Versão comprimida: %s\n', versionPath);
                end
                
            catch ME
                fprintf('⚠ Erro na compressão: %s\n', ME.message);
            end
        end
        
        function backupPath = createBackup(obj, modelPath, modelType)
            % Criar backup de um modelo
            
            backupDir = fullfile(obj.baseDirectory, 'backups');
            timestamp = datetime('now', 'Format', 'yyyyMMdd_HHmmss');
            
            [~, name, ext] = fileparts(modelPath);
            backupFilename = sprintf('%s_backup_%s%s', name, timestamp, ext);
            backupPath = fullfile(backupDir, backupFilename);
            
            copyfile(modelPath, backupPath);
        end
        
        function isImportant = isImportantVersion(obj, fileInfo)
            % Verificar se uma versão é importante (marco)
            
            % Considerar importante se:
            % 1. É uma das 3 versões mais recentes
            % 2. É do primeiro dia de cada mês
            % 3. Tem performance excepcional (se metadados disponíveis)
            
            isImportant = false;
            
            try
                fileDate = datetime(fileInfo.datenum, 'ConvertFrom', 'datenum');
                
                % Verificar se é do primeiro dia do mês
                if day(fileDate) == 1
                    isImportant = true;
                end
                
                % Adicionar outras regras conforme necessário
                
            catch
                % Em caso de erro, considerar importante para segurança
                isImportant = true;
            end
        end
        
        function cleanupByRetentionPolicy(obj, modelType)
            % Limpeza baseada na política de retenção
            
            try
                versionDir = fullfile(obj.baseDirectory, 'versions', modelType);
                versionFiles = dir(fullfile(versionDir, '*.mat'));
                
                cutoffDate = datetime('now') - days(obj.retentionDays);
                
                for i = 1:length(versionFiles)
                    file = versionFiles(i);
                    fileDate = datetime(file.datenum, 'ConvertFrom', 'datenum');
                    
                    if fileDate < cutoffDate && ~obj.isImportantVersion(file)
                        filePath = fullfile(versionDir, file.name);
                        delete(filePath);
                        fprintf('🗑 Versão expirada removida: %s\n', file.name);
                    end
                end
                
            catch ME
                fprintf('⚠ Erro na limpeza por retenção: %s\n', ME.message);
            end
        end
        
        function sizeStr = formatFileSize(obj, bytes)
            % Formatar tamanho do arquivo
            
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
    end
end