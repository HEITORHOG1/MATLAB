classdef ConfigManager < handle
    % ========================================================================
    % CONFIGMANAGER - GERENCIADOR DE CONFIGURAÇÕES
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Classe handle para gerenciar todas as configurações do sistema de
    %   comparação entre U-Net e Attention U-Net. Implementa detecção
    %   automática de caminhos, validação robusta e portabilidade.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Object-Oriented Programming
    %   - Handle Classes
    %   - File I/O
    %
    % USO:
    %   >> configMgr = ConfigManager();
    %   >> config = configMgr.loadConfig();
    %   >> configMgr.saveConfig(config);
    %
    % REQUISITOS: 5.1, 5.4
    % ========================================================================
    
    properties (Access = private)
        configFile = 'config_caminhos.mat'
        backupDir = 'config_backups'
        defaultPaths = struct()
        logger
    end
    
    properties (Constant)
        SUPPORTED_IMAGE_FORMATS = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff'}
        CONFIG_VERSION = '2.0'
    end
    
    methods
        function obj = ConfigManager()
            % Construtor da classe ConfigManager
            % Inicializa o gerenciador e configura caminhos padrão
            
            obj.initializeLogger();
            obj.setupDefaultPaths();
            obj.ensureBackupDirectory();
            
            obj.logger('info', 'ConfigManager inicializado');
        end
        
        function config = loadConfig(obj, configPath)
            % Carrega configuração de arquivo ou cria nova se não existir
            %
            % ENTRADA:
            %   configPath (opcional) - caminho para arquivo de configuração
            %
            % SAÍDA:
            %   config - estrutura com configurações carregadas
            %
            % REFERÊNCIA MATLAB:
            %   https://www.mathworks.com/help/matlab/ref/load.html
            
            if nargin < 2
                configPath = obj.configFile;
            end
            
            obj.logger('info', sprintf('Carregando configuração de: %s', configPath));
            
            if exist(configPath, 'file')
                try
                    loadedData = load(configPath);
                    if isfield(loadedData, 'config')
                        config = loadedData.config;
                        obj.logger('success', 'Configuração carregada com sucesso');
                        
                        % Validar configuração carregada
                        if obj.validateConfig(config)
                            obj.logger('success', 'Configuração validada');
                        else
                            obj.logger('warning', 'Configuração carregada é inválida, criando nova');
                            config = obj.createDefaultConfig();
                        end
                    else
                        obj.logger('warning', 'Arquivo não contém configuração válida');
                        config = obj.createDefaultConfig();
                    end
                catch ME
                    obj.logger('error', sprintf('Erro ao carregar configuração: %s', ME.message));
                    config = obj.createDefaultConfig();
                end
            else
                obj.logger('info', 'Arquivo de configuração não encontrado, criando novo');
                config = obj.createDefaultConfig();
            end
            
            % Atualizar informações do ambiente
            config = obj.updateEnvironmentInfo(config);
        end
        
        function success = saveConfig(obj, config, configPath)
            % Salva configuração em arquivo
            %
            % ENTRADA:
            %   config - estrutura de configuração para salvar
            %   configPath (opcional) - caminho para salvar
            %
            % SAÍDA:
            %   success - true se salvou com sucesso
            %
            % REFERÊNCIA MATLAB:
            %   https://www.mathworks.com/help/matlab/ref/save.html
            
            if nargin < 3
                configPath = obj.configFile;
            end
            
            success = false;
            
            try
                % Validar antes de salvar
                if ~obj.validateConfig(config)
                    obj.logger('error', 'Configuração inválida, não será salva');
                    return;
                end
                
                % Criar backup se arquivo já existe
                if exist(configPath, 'file')
                    obj.createBackup(configPath);
                end
                
                % Salvar configuração
                save(configPath, 'config');
                obj.logger('success', sprintf('Configuração salva em: %s', configPath));
                
                success = true;
                
            catch ME
                obj.logger('error', sprintf('Erro ao salvar configuração: %s', ME.message));
            end
        end
        
        function isValid = validateConfig(obj, config)
            % Valida estrutura de configuração
            %
            % ENTRADA:
            %   config - estrutura de configuração
            %
            % SAÍDA:
            %   isValid - true se configuração é válida
            %
            % REQUISITOS: 5.2
            
            isValid = false;
            
            try
                % Verificar campos obrigatórios
                requiredFields = {'imageDir', 'maskDir', 'inputSize', 'numClasses', ...
                                'validationSplit', 'miniBatchSize', 'maxEpochs'};
                
                for i = 1:length(requiredFields)
                    if ~isfield(config, requiredFields{i})
                        obj.logger('error', sprintf('Campo obrigatório ausente: %s', requiredFields{i}));
                        return;
                    end
                end
                
                % Validar tipos de dados
                if ~ischar(config.imageDir) && ~isstring(config.imageDir)
                    obj.logger('error', 'imageDir deve ser string');
                    return;
                end
                
                if ~ischar(config.maskDir) && ~isstring(config.maskDir)
                    obj.logger('error', 'maskDir deve ser string');
                    return;
                end
                
                if ~isnumeric(config.inputSize) || length(config.inputSize) ~= 3
                    obj.logger('error', 'inputSize deve ser vetor numérico [H, W, C]');
                    return;
                end
                
                if ~isnumeric(config.numClasses) || config.numClasses < 2
                    obj.logger('error', 'numClasses deve ser número >= 2');
                    return;
                end
                
                if ~isnumeric(config.validationSplit) || config.validationSplit <= 0 || config.validationSplit >= 1
                    obj.logger('error', 'validationSplit deve estar entre 0 e 1');
                    return;
                end
                
                obj.logger('success', 'Estrutura de configuração válida');
                isValid = true;
                
            catch ME
                obj.logger('error', sprintf('Erro na validação: %s', ME.message));
            end
        end
        
        function detectedPaths = detectCommonDataPaths(obj)
            % Detecta automaticamente diretórios de dados comuns
            %
            % SAÍDA:
            %   detectedPaths - estrutura com caminhos detectados
            %
            % REQUISITOS: 5.4
            
            obj.logger('info', 'Detectando caminhos de dados automaticamente...');
            
            detectedPaths = struct();
            
            % Caminhos comuns para procurar
            commonPaths = {
                fullfile(pwd, 'img', 'original'),
                fullfile(pwd, 'img', 'masks'),
                fullfile(pwd, 'data', 'images'),
                fullfile(pwd, 'data', 'masks'),
                fullfile(pwd, 'dataset', 'images'),
                fullfile(pwd, 'dataset', 'masks'),
                obj.defaultPaths.imageDir,
                obj.defaultPaths.maskDir
            };
            
            % Detectar diretório de imagens
            for i = 1:length(commonPaths)
                if exist(commonPaths{i}, 'dir')
                    if obj.hasImageFiles(commonPaths{i})
                        detectedPaths.imageDir = commonPaths{i};
                        obj.logger('success', sprintf('Diretório de imagens detectado: %s', commonPaths{i}));
                        break;
                    end
                end
            end
            
            % Detectar diretório de máscaras
            for i = 1:length(commonPaths)
                if exist(commonPaths{i}, 'dir')
                    if obj.hasImageFiles(commonPaths{i}) && contains(lower(commonPaths{i}), 'mask')
                        detectedPaths.maskDir = commonPaths{i};
                        obj.logger('success', sprintf('Diretório de máscaras detectado: %s', commonPaths{i}));
                        break;
                    end
                end
            end
            
            % Se não encontrou, usar caminhos do projeto atual
            if ~isfield(detectedPaths, 'imageDir')
                if exist(fullfile(pwd, 'img', 'original'), 'dir')
                    detectedPaths.imageDir = fullfile(pwd, 'img', 'original');
                end
            end
            
            if ~isfield(detectedPaths, 'maskDir')
                if exist(fullfile(pwd, 'img', 'masks'), 'dir')
                    detectedPaths.maskDir = fullfile(pwd, 'img', 'masks');
                end
            end
            
            obj.logger('info', sprintf('Detecção concluída. Encontrados %d caminhos', length(fieldnames(detectedPaths))));
        end
        
        function portableConfig = exportPortableConfig(obj, config, exportPath)
            % Exporta configuração portátil para uso em outra máquina
            %
            % ENTRADA:
            %   config - estrutura de configuração atual
            %   exportPath (opcional) - caminho para salvar configuração portátil
            %
            % SAÍDA:
            %   portableConfig - estrutura de configuração portátil
            %
            % REQUISITOS: 5.5
            
            if nargin < 3
                exportPath = 'portable_config.mat';
            end
            
            obj.logger('info', 'Criando configuração portátil...');
            
            try
                % Criar cópia da configuração
                portableConfig = config;
                
                % Remover informações específicas da máquina
                if isfield(portableConfig, 'environment')
                    portableConfig.environment = rmfield(portableConfig.environment, ...
                        intersect(fieldnames(portableConfig.environment), ...
                        {'username', 'computername', 'lastUpdate'}));
                end
                
                % Converter caminhos absolutos para relativos quando possível
                portableConfig = obj.convertToRelativePaths(portableConfig);
                
                % Adicionar metadados de portabilidade
                portableConfig.portability = struct();
                portableConfig.portability.isPortable = true;
                portableConfig.portability.exportDate = datestr(now);
                portableConfig.portability.exportedFrom = struct();
                portableConfig.portability.exportedFrom.username = obj.getUsername();
                portableConfig.portability.exportedFrom.computername = obj.getComputerName();
                portableConfig.portability.exportedFrom.platform = computer;
                
                % Adicionar instruções de uso
                portableConfig.portability.instructions = {
                    'Esta é uma configuração portátil.',
                    'Use importPortableConfig() para aplicar em nova máquina.',
                    'Caminhos podem precisar ser ajustados manualmente.'
                };
                
                % Salvar configuração portátil
                save(exportPath, 'portableConfig');
                obj.logger('success', sprintf('Configuração portátil salva em: %s', exportPath));
                
            catch ME
                obj.logger('error', sprintf('Erro ao exportar configuração portátil: %s', ME.message));
                portableConfig = [];
            end
        end
        
        function config = importPortableConfig(obj, portableConfigPath, targetPaths)
            % Importa e adapta configuração portátil para máquina atual
            %
            % ENTRADA:
            %   portableConfigPath - caminho para configuração portátil
            %   targetPaths (opcional) - estrutura com novos caminhos
            %
            % SAÍDA:
            %   config - configuração adaptada para máquina atual
            %
            % REQUISITOS: 5.5
            
            if nargin < 3
                targetPaths = struct();
            end
            
            obj.logger('info', sprintf('Importando configuração portátil de: %s', portableConfigPath));
            
            try
                % Carregar configuração portátil
                if ~exist(portableConfigPath, 'file')
                    obj.logger('error', 'Arquivo de configuração portátil não encontrado');
                    config = [];
                    return;
                end
                
                loadedData = load(portableConfigPath);
                if isfield(loadedData, 'portableConfig')
                    config = loadedData.portableConfig;
                elseif isfield(loadedData, 'config')
                    config = loadedData.config;
                else
                    obj.logger('error', 'Arquivo não contém configuração válida');
                    config = [];
                    return;
                end
                
                % Verificar se é realmente uma configuração portátil
                if isfield(config, 'portability') && isfield(config.portability, 'isPortable') && config.portability.isPortable
                    obj.logger('success', 'Configuração portátil válida detectada');
                    
                    % Mostrar informações de origem
                    if isfield(config.portability, 'exportedFrom')
                        exportInfo = config.portability.exportedFrom;
                        obj.logger('info', sprintf('Exportada de: %s@%s (%s)', ...
                            exportInfo.username, exportInfo.computername, exportInfo.platform));
                    end
                else
                    obj.logger('warning', 'Configuração não é marcada como portátil, tentando importar mesmo assim');
                end
                
                % Adaptar caminhos para máquina atual
                config = obj.adaptPathsForCurrentMachine(config, targetPaths);
                
                % Atualizar informações do ambiente
                config = obj.updateEnvironmentInfo(config);
                
                % Remover metadados de portabilidade (não são mais necessários)
                if isfield(config, 'portability')
                    config = rmfield(config, 'portability');
                end
                
                % Validar configuração importada
                if obj.validateConfig(config)
                    obj.logger('success', 'Configuração importada e validada com sucesso');
                    
                    % Salvar configuração adaptada
                    obj.saveConfig(config);
                else
                    obj.logger('warning', 'Configuração importada requer ajustes manuais');
                end
                
            catch ME
                obj.logger('error', sprintf('Erro ao importar configuração portátil: %s', ME.message));
                config = [];
            end
        end
        
        function success = createAutomaticBackup(obj, config)
            % Cria backup automático da configuração atual
            %
            % ENTRADA:
            %   config - configuração para fazer backup
            %
            % SAÍDA:
            %   success - true se backup foi criado com sucesso
            %
            % REQUISITOS: 5.5
            
            success = false;
            
            try
                obj.logger('info', 'Criando backup automático...');
                
                % Criar nome do backup com timestamp
                timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
                backupName = sprintf('config_auto_backup_%s.mat', timestamp);
                backupPath = fullfile(obj.backupDir, backupName);
                
                % Salvar backup
                save(backupPath, 'config');
                obj.logger('success', sprintf('Backup automático criado: %s', backupPath));
                
                % Limpar backups antigos (manter apenas os 10 mais recentes)
                obj.cleanupOldBackups();
                
                success = true;
                
            catch ME
                obj.logger('error', sprintf('Erro ao criar backup automático: %s', ME.message));
            end
        end
        
        function isValid = validatePaths(obj, config)
            % Valida existência e acessibilidade de diretórios
            %
            % ENTRADA:
            %   config - estrutura de configuração
            %
            % SAÍDA:
            %   isValid - true se todos os caminhos são válidos
            %
            % REQUISITOS: 5.2
            
            isValid = false;
            
            try
                obj.logger('info', 'Validando caminhos de diretórios...');
                
                % Verificar diretório de imagens
                if ~isfield(config, 'imageDir') || isempty(config.imageDir)
                    obj.logger('error', 'Caminho de imagens não especificado');
                    return;
                end
                
                if ~exist(config.imageDir, 'dir')
                    obj.logger('error', sprintf('Diretório de imagens não existe: %s', config.imageDir));
                    return;
                end
                
                % Verificar permissões de leitura
                try
                    dir(config.imageDir);
                    obj.logger('success', 'Diretório de imagens acessível');
                catch
                    obj.logger('error', sprintf('Sem permissão de leitura: %s', config.imageDir));
                    return;
                end
                
                % Verificar diretório de máscaras
                if ~isfield(config, 'maskDir') || isempty(config.maskDir)
                    obj.logger('error', 'Caminho de máscaras não especificado');
                    return;
                end
                
                if ~exist(config.maskDir, 'dir')
                    obj.logger('error', sprintf('Diretório de máscaras não existe: %s', config.maskDir));
                    return;
                end
                
                % Verificar permissões de leitura
                try
                    dir(config.maskDir);
                    obj.logger('success', 'Diretório de máscaras acessível');
                catch
                    obj.logger('error', sprintf('Sem permissão de leitura: %s', config.maskDir));
                    return;
                end
                
                % Verificar diretório de saída
                if isfield(config, 'outputDir') && ~isempty(config.outputDir)
                    if ~exist(config.outputDir, 'dir')
                        try
                            mkdir(config.outputDir);
                            obj.logger('success', sprintf('Diretório de saída criado: %s', config.outputDir));
                        catch
                            obj.logger('error', sprintf('Não foi possível criar diretório de saída: %s', config.outputDir));
                            return;
                        end
                    end
                    
                    % Verificar permissões de escrita
                    testFile = fullfile(config.outputDir, 'test_write.tmp');
                    try
                        fid = fopen(testFile, 'w');
                        if fid ~= -1
                            fclose(fid);
                            delete(testFile);
                            obj.logger('success', 'Diretório de saída tem permissão de escrita');
                        else
                            obj.logger('error', sprintf('Sem permissão de escrita: %s', config.outputDir));
                            return;
                        end
                    catch
                        obj.logger('error', sprintf('Erro ao testar escrita: %s', config.outputDir));
                        return;
                    end
                end
                
                obj.logger('success', 'Todos os caminhos são válidos');
                isValid = true;
                
            catch ME
                obj.logger('error', sprintf('Erro na validação de caminhos: %s', ME.message));
            end
        end
        
        function isValid = validateDataCompatibility(obj, config)
            % Valida compatibilidade e formato dos dados
            %
            % ENTRADA:
            %   config - estrutura de configuração
            %
            % SAÍDA:
            %   isValid - true se dados são compatíveis
            %
            % REQUISITOS: 5.2
            
            isValid = false;
            
            try
                obj.logger('info', 'Validando compatibilidade de dados...');
                
                % Obter listas de arquivos
                imageFiles = obj.getImageFiles(config.imageDir);
                maskFiles = obj.getImageFiles(config.maskDir);
                
                if isempty(imageFiles)
                    obj.logger('error', sprintf('Nenhuma imagem encontrada em: %s', config.imageDir));
                    return;
                end
                
                if isempty(maskFiles)
                    obj.logger('error', sprintf('Nenhuma máscara encontrada em: %s', config.maskDir));
                    return;
                end
                
                obj.logger('info', sprintf('Encontradas %d imagens e %d máscaras', length(imageFiles), length(maskFiles)));
                
                % Verificar correspondência de nomes (opcional, mas recomendado)
                [imageNames, ~, ~] = cellfun(@fileparts, {imageFiles.name}, 'UniformOutput', false);
                [maskNames, ~, ~] = cellfun(@fileparts, {maskFiles.name}, 'UniformOutput', false);
                
                commonNames = intersect(imageNames, maskNames);
                if length(commonNames) < min(length(imageNames), length(maskNames)) * 0.5
                    obj.logger('warning', sprintf('Apenas %d/%d arquivos têm correspondência entre imagens e máscaras', ...
                        length(commonNames), min(length(imageNames), length(maskNames))));
                else
                    obj.logger('success', sprintf('%d arquivos com correspondência encontrados', length(commonNames)));
                end
                
                % Validar algumas amostras de imagens
                numSamplesToCheck = min(5, length(imageFiles));
                obj.logger('info', sprintf('Validando %d amostras de imagens...', numSamplesToCheck));
                
                for i = 1:numSamplesToCheck
                    try
                        % Tentar carregar imagem
                        imgPath = fullfile(config.imageDir, imageFiles(i).name);
                        img = imread(imgPath);
                        
                        % Verificar dimensões
                        [h, w, c] = size(img);
                        if c ~= 1 && c ~= 3
                            obj.logger('warning', sprintf('Imagem %s tem %d canais (esperado 1 ou 3)', imageFiles(i).name, c));
                        end
                        
                        % Verificar se não está corrompida
                        if h < 10 || w < 10
                            obj.logger('warning', sprintf('Imagem %s muito pequena: %dx%d', imageFiles(i).name, h, w));
                        end
                        
                    catch ME
                        obj.logger('error', sprintf('Erro ao carregar imagem %s: %s', imageFiles(i).name, ME.message));
                        return;
                    end
                end
                
                % Validar algumas amostras de máscaras
                numSamplesToCheck = min(5, length(maskFiles));
                obj.logger('info', sprintf('Validando %d amostras de máscaras...', numSamplesToCheck));
                
                for i = 1:numSamplesToCheck
                    try
                        % Tentar carregar máscara
                        maskPath = fullfile(config.maskDir, maskFiles(i).name);
                        mask = imread(maskPath);
                        
                        % Verificar se é binária ou tem classes válidas
                        uniqueVals = unique(mask(:));
                        if length(uniqueVals) > config.numClasses
                            obj.logger('warning', sprintf('Máscara %s tem %d valores únicos (esperado <= %d)', ...
                                maskFiles(i).name, length(uniqueVals), config.numClasses));
                        end
                        
                        % Verificar se valores estão no range esperado
                        if any(uniqueVals < 0) || any(uniqueVals > config.numClasses - 1)
                            obj.logger('warning', sprintf('Máscara %s tem valores fora do range [0, %d]', ...
                                maskFiles(i).name, config.numClasses - 1));
                        end
                        
                    catch ME
                        obj.logger('error', sprintf('Erro ao carregar máscara %s: %s', maskFiles(i).name, ME.message));
                        return;
                    end
                end
                
                obj.logger('success', 'Dados são compatíveis');
                isValid = true;
                
            catch ME
                obj.logger('error', sprintf('Erro na validação de compatibilidade: %s', ME.message));
            end
        end
        
        function isValid = validateHardware(obj, config)
            % Valida recursos de hardware disponíveis
            %
            % ENTRADA:
            %   config - estrutura de configuração
            %
            % SAÍDA:
            %   isValid - true se hardware é adequado
            %
            % REQUISITOS: 5.2, 7.1
            
            isValid = false;
            
            try
                obj.logger('info', 'Validando recursos de hardware...');
                
                % Verificar memória disponível
                if ispc
                    [~, memInfo] = memory;
                    availableMemoryGB = memInfo.PhysicalMemory.Available / (1024^3);
                else
                    % Para Linux/Mac, usar uma estimativa conservadora
                    availableMemoryGB = 4; % Assumir 4GB disponível
                end
                
                obj.logger('info', sprintf('Memória disponível estimada: %.1f GB', availableMemoryGB));
                
                if availableMemoryGB < 2
                    obj.logger('warning', 'Pouca memória disponível (< 2GB). Considere reduzir batch size');
                    % Ajustar configurações automaticamente
                    if isfield(config, 'miniBatchSize') && config.miniBatchSize > 4
                        config.miniBatchSize = 4;
                        obj.logger('info', 'Batch size reduzido para 4 devido à memória limitada');
                    end
                end
                
                % Verificar GPU
                gpuAvailable = false;
                gpuMemoryGB = 0;
                
                try
                    if license('test', 'Distrib_Computing_Toolbox') || license('test', 'Parallel_Computing_Toolbox')
                        gpuDevice = gpuDevice();
                        gpuAvailable = true;
                        gpuMemoryGB = gpuDevice.AvailableMemory / (1024^3);
                        
                        obj.logger('success', sprintf('GPU detectada: %s (%.1f GB disponível)', ...
                            gpuDevice.Name, gpuMemoryGB));
                        
                        if gpuMemoryGB < 2
                            obj.logger('warning', 'GPU com pouca memória (< 2GB). Treinamento pode ser lento');
                        end
                    else
                        obj.logger('info', 'Parallel Computing Toolbox não disponível - GPU não será usada');
                    end
                catch
                    obj.logger('info', 'GPU não detectada ou não disponível');
                end
                
                % Atualizar configuração com informações de hardware
                if ~isfield(config, 'hardware')
                    config.hardware = struct();
                end
                
                config.hardware.availableMemoryGB = availableMemoryGB;
                config.hardware.gpuAvailable = gpuAvailable;
                config.hardware.gpuMemoryGB = gpuMemoryGB;
                config.hardware.recommendedBatchSize = obj.calculateRecommendedBatchSize(availableMemoryGB, gpuMemoryGB);
                
                % Verificar toolboxes necessários
                requiredToolboxes = {
                    'Deep Learning Toolbox',
                    'Image Processing Toolbox'
                };
                
                missingToolboxes = {};
                for i = 1:length(requiredToolboxes)
                    if ~obj.isToolboxAvailable(requiredToolboxes{i})
                        missingToolboxes{end+1} = requiredToolboxes{i};
                    end
                end
                
                if ~isempty(missingToolboxes)
                    obj.logger('error', sprintf('Toolboxes obrigatórios ausentes: %s', strjoin(missingToolboxes, ', ')));
                    return;
                end
                
                obj.logger('success', 'Hardware validado com sucesso');
                isValid = true;
                
            catch ME
                obj.logger('error', sprintf('Erro na validação de hardware: %s', ME.message));
            end
        end
    end
    
    methods (Access = private)
        function initializeLogger(obj)
            % Inicializa sistema de logging simples
            obj.logger = @(level, msg) obj.logMessage(level, msg);
        end
        
        function logMessage(obj, level, message)
            % Sistema de logging interno
            timestamp = datestr(now, 'HH:MM:SS');
            
            switch lower(level)
                case 'info'
                    prefix = 'ℹ️';
                case 'success'
                    prefix = '✅';
                case 'warning'
                    prefix = '⚠️';
                case 'error'
                    prefix = '❌';
                otherwise
                    prefix = '📝';
            end
            
            fprintf('[%s] %s %s\n', timestamp, prefix, message);
        end
        
        function setupDefaultPaths(obj)
            % Configura caminhos padrão baseados no ambiente atual
            
            % Detectar sistema operacional
            if ispc
                % Windows
                userProfile = getenv('USERPROFILE');
                obj.defaultPaths.imageDir = fullfile(userProfile, 'Pictures', 'imagens matlab', 'original');
                obj.defaultPaths.maskDir = fullfile(userProfile, 'Pictures', 'imagens matlab', 'masks');
            else
                % Linux/Mac
                homeDir = getenv('HOME');
                obj.defaultPaths.imageDir = fullfile(homeDir, 'Pictures', 'imagens_matlab', 'original');
                obj.defaultPaths.maskDir = fullfile(homeDir, 'Pictures', 'imagens_matlab', 'masks');
            end
        end
        
        function ensureBackupDirectory(obj)
            % Garante que diretório de backup existe
            if ~exist(obj.backupDir, 'dir')
                mkdir(obj.backupDir);
                obj.logger('info', sprintf('Diretório de backup criado: %s', obj.backupDir));
            end
        end
        
        function config = createDefaultConfig(obj)
            % Cria configuração padrão
            
            obj.logger('info', 'Criando configuração padrão...');
            
            % Detectar caminhos automaticamente
            detectedPaths = obj.detectCommonDataPaths();
            
            config = struct();
            
            % Caminhos de dados
            if isfield(detectedPaths, 'imageDir')
                config.imageDir = detectedPaths.imageDir;
            else
                config.imageDir = obj.defaultPaths.imageDir;
            end
            
            if isfield(detectedPaths, 'maskDir')
                config.maskDir = detectedPaths.maskDir;
            else
                config.maskDir = obj.defaultPaths.maskDir;
            end
            
            % Configurações de modelo
            config.inputSize = [256, 256, 3];
            config.numClasses = 2;
            config.encoderDepth = 4;
            
            % Configurações de treinamento
            config.maxEpochs = 20;
            config.miniBatchSize = 8;
            config.learningRate = 1e-3;
            config.validationSplit = 0.2;
            
            % Configurações de avaliação
            config.metrics = {'iou', 'dice', 'accuracy'};
            config.crossValidationFolds = 5;
            config.statisticalTests = true;
            
            % Configurações de saída
            config.saveModels = true;
            config.generateReports = true;
            config.createVisualizations = true;
            config.outputDir = fullfile(pwd, 'output');
            
            % Teste rápido
            config.quickTest = struct('numSamples', 50, 'maxEpochs', 5);
            
            % Informações de versão
            config.version = obj.CONFIG_VERSION;
            config.createdDate = datestr(now);
            
            obj.logger('success', 'Configuração padrão criada');
        end
        
        function config = updateEnvironmentInfo(obj, config)
            % Atualiza informações do ambiente na configuração
            
            if ~isfield(config, 'environment')
                config.environment = struct();
            end
            
            config.environment.username = obj.getUsername();
            config.environment.computername = obj.getComputerName();
            config.environment.matlabVersion = version;
            config.environment.platform = computer;
            config.environment.lastUpdate = datestr(now);
            
            % Detectar toolboxes disponíveis
            config.environment.availableToolboxes = obj.detectAvailableToolboxes();
        end
        
        function username = getUsername(obj)
            % Obtém nome do usuário atual de forma multiplataforma
            if ispc
                username = getenv('USERNAME');
            else
                username = getenv('USER');
            end
            
            if isempty(username)
                username = 'unknown';
            end
        end
        
        function computername = getComputerName(obj)
            % Obtém nome do computador de forma multiplataforma
            if ispc
                computername = getenv('COMPUTERNAME');
            else
                computername = getenv('HOSTNAME');
            end
            
            if isempty(computername)
                computername = 'unknown';
            end
        end
        
        function toolboxes = detectAvailableToolboxes(obj)
            % Detecta toolboxes disponíveis relevantes para o projeto
            
            requiredToolboxes = {
                'Deep Learning Toolbox',
                'Image Processing Toolbox',
                'Statistics and Machine Learning Toolbox',
                'Parallel Computing Toolbox'
            };
            
            toolboxes = struct();
            
            try
                installedToolboxes = ver;
                installedNames = {installedToolboxes.Name};
                
                for i = 1:length(requiredToolboxes)
                    toolboxName = requiredToolboxes{i};
                    fieldName = matlab.lang.makeValidName(toolboxName);
                    toolboxes.(fieldName) = any(contains(installedNames, toolboxName));
                end
            catch
                % Se falhar, assumir que não tem nenhum
                for i = 1:length(requiredToolboxes)
                    toolboxName = requiredToolboxes{i};
                    fieldName = matlab.lang.makeValidName(toolboxName);
                    toolboxes.(fieldName) = false;
                end
            end
        end
        
        function hasFiles = hasImageFiles(obj, dirPath)
            % Verifica se diretório contém arquivos de imagem
            
            hasFiles = false;
            
            if ~exist(dirPath, 'dir')
                return;
            end
            
            for i = 1:length(obj.SUPPORTED_IMAGE_FORMATS)
                files = dir(fullfile(dirPath, obj.SUPPORTED_IMAGE_FORMATS{i}));
                if ~isempty(files)
                    hasFiles = true;
                    return;
                end
            end
        end
        
        function imageFiles = getImageFiles(obj, dirPath)
            % Obtém lista de arquivos de imagem em um diretório
            
            imageFiles = [];
            
            if ~exist(dirPath, 'dir')
                return;
            end
            
            for i = 1:length(obj.SUPPORTED_IMAGE_FORMATS)
                files = dir(fullfile(dirPath, obj.SUPPORTED_IMAGE_FORMATS{i}));
                imageFiles = [imageFiles; files];
            end
        end
        
        function batchSize = calculateRecommendedBatchSize(obj, memoryGB, gpuMemoryGB)
            % Calcula batch size recomendado baseado na memória disponível
            
            if gpuMemoryGB > 0
                % Usar memória da GPU como referência
                if gpuMemoryGB >= 8
                    batchSize = 16;
                elseif gpuMemoryGB >= 4
                    batchSize = 8;
                elseif gpuMemoryGB >= 2
                    batchSize = 4;
                else
                    batchSize = 2;
                end
            else
                % Usar memória RAM como referência
                if memoryGB >= 16
                    batchSize = 8;
                elseif memoryGB >= 8
                    batchSize = 4;
                elseif memoryGB >= 4
                    batchSize = 2;
                else
                    batchSize = 1;
                end
            end
        end
        
        function available = isToolboxAvailable(obj, toolboxName)
            % Verifica se um toolbox específico está disponível
            
            available = false;
            
            try
                installedToolboxes = ver;
                installedNames = {installedToolboxes.Name};
                available = any(contains(installedNames, toolboxName));
            catch
                available = false;
            end
        end
        
        function createBackup(obj, configPath)
            % Cria backup da configuração atual
            
            try
                timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
                [~, name, ext] = fileparts(configPath);
                backupName = sprintf('%s_backup_%s%s', name, timestamp, ext);
                backupPath = fullfile(obj.backupDir, backupName);
                
                copyfile(configPath, backupPath);
                obj.logger('info', sprintf('Backup criado: %s', backupPath));
                
            catch ME
                obj.logger('warning', sprintf('Falha ao criar backup: %s', ME.message));
            end
        end
    end
endany(contains(installedNames, toolboxName));
                end
            catch
                % Se falhar, assumir que não tem nenhum
                for i = 1:length(requiredToolboxes)
                    toolboxName = requiredToolboxes{i};
                    fieldName = matlab.lang.makeValidName(toolboxName);
                    toolboxes.(fieldName) = false;
                end
            end
        end
        
        function hasFiles = hasImageFiles(obj, dirPath)
            % Verifica se diretório contém arquivos de imagem
            
            hasFiles = false;
            
            if ~exist(dirPath, 'dir')
                return;
            end
            
            for i = 1:length(obj.SUPPORTED_IMAGE_FORMATS)
                files = dir(fullfile(dirPath, obj.SUPPORTED_IMAGE_FORMATS{i}));
                if ~isempty(files)
                    hasFiles = true;
                    return;
                end
            end
        end
        
        function createBackup(obj, configPath)
            % Cria backup da configuração atual
            
            try
                timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
                [~, name, ext] = fileparts(configPath);
                backupName = sprintf('%s_backup_%s%s', name, timestamp, ext);
                backupPath = fullfile(obj.backupDir, backupName);
                
                copyfile(configPath, backupPath);
                obj.logger('info', sprintf('Backup criado: %s', backupPath));
                
            catch ME
                obj.logger('warning', sprintf('Falha ao criar backup: %s', ME.message));
            end
        end
    end
end    
    function config = convertToRelativePaths(obj, config)
            % Converte caminhos absolutos para relativos quando possível
            
            try
                currentDir = pwd;
                
                % Converter imageDir
                if isfield(config, 'imageDir') && ~isempty(config.imageDir)
                    config.imageDir = obj.makePathRelative(config.imageDir, currentDir);
                end
                
                % Converter maskDir
                if isfield(config, 'maskDir') && ~isempty(config.maskDir)
                    config.maskDir = obj.makePathRelative(config.maskDir, currentDir);
                end
                
                % Converter outputDir
                if isfield(config, 'outputDir') && ~isempty(config.outputDir)
                    config.outputDir = obj.makePathRelative(config.outputDir, currentDir);
                end
                
            catch ME
                obj.logger('warning', sprintf('Erro ao converter caminhos: %s', ME.message));
            end
        end
        
        function relativePath = makePathRelative(obj, absolutePath, basePath)
            % Converte caminho absoluto para relativo se possível
            
            try
                if contains(absolutePath, basePath)
                    relativePath = strrep(absolutePath, [basePath filesep], '');
                    if isempty(relativePath)
                        relativePath = '.';
                    end
                else
                    relativePath = absolutePath; % Manter absoluto se não for subdiretório
                end
            catch
                relativePath = absolutePath;
            end
        end
        
        function config = adaptPathsForCurrentMachine(obj, config, targetPaths)
            % Adapta caminhos para máquina atual
            
            try
                % Se caminhos específicos foram fornecidos, usar eles
                if isfield(targetPaths, 'imageDir') && ~isempty(targetPaths.imageDir)
                    config.imageDir = targetPaths.imageDir;
                else
                    % Tentar detectar automaticamente
                    detectedPaths = obj.detectCommonDataPaths();
                    if isfield(detectedPaths, 'imageDir')
                        config.imageDir = detectedPaths.imageDir;
                    else
                        % Converter caminho relativo para absoluto
                        if ~isempty(config.imageDir) && ~obj.isAbsolutePath(config.imageDir)
                            config.imageDir = fullfile(pwd, config.imageDir);
                        end
                    end
                end
                
                if isfield(targetPaths, 'maskDir') && ~isempty(targetPaths.maskDir)
                    config.maskDir = targetPaths.maskDir;
                else
                    % Tentar detectar automaticamente
                    detectedPaths = obj.detectCommonDataPaths();
                    if isfield(detectedPaths, 'maskDir')
                        config.maskDir = detectedPaths.maskDir;
                    else
                        % Converter caminho relativo para absoluto
                        if ~isempty(config.maskDir) && ~obj.isAbsolutePath(config.maskDir)
                            config.maskDir = fullfile(pwd, config.maskDir);
                        end
                    end
                end
                
                % Atualizar outputDir
                if isfield(config, 'outputDir') && ~isempty(config.outputDir)
                    if ~obj.isAbsolutePath(config.outputDir)
                        config.outputDir = fullfile(pwd, config.outputDir);
                    end
                end
                
            catch ME
                obj.logger('error', sprintf('Erro ao adaptar caminhos: %s', ME.message));
            end
        end
        
        function cleanupOldBackups(obj)
            % Remove backups antigos, mantendo apenas os 10 mais recentes
            
            try
                backupFiles = dir(fullfile(obj.backupDir, 'config_*_backup_*.mat'));
                
                if length(backupFiles) > 10
                    % Ordenar por data de modificação
                    [~, sortIdx] = sort([backupFiles.datenum], 'descend');
                    backupFiles = backupFiles(sortIdx);
                    
                    % Remover arquivos mais antigos
                    for i = 11:length(backupFiles)
                        try
                            delete(fullfile(obj.backupDir, backupFiles(i).name));
                            obj.logger('info', sprintf('Backup antigo removido: %s', backupFiles(i).name));
                        catch
                            obj.logger('warning', sprintf('Falha ao remover backup: %s', backupFiles(i).name));
                        end
                    end
                end
                
            catch ME
                obj.logger('warning', sprintf('Erro na limpeza de backups: %s', ME.message));
            end
        end
        
        function isAbsolute = isAbsolutePath(obj, path)
            % Verifica se caminho é absoluto (multiplataforma)
            
            if ispc
                % Windows: C:\ ou \\server\
                isAbsolute = length(path) >= 3 && (path(2) == ':' || (path(1) == '\' && path(2) == '\'));
            else
                % Unix/Linux/Mac: /path
                isAbsolute = ~isempty(path) && path(1) == '/';
            end
        end
    end
end