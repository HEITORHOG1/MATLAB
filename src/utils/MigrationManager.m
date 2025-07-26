classdef MigrationManager < handle
    % ========================================================================
    % MIGRATIONMANAGER - GERENCIADOR DE MIGRAÇÃO DO SISTEMA
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Classe para gerenciar migração controlada do sistema legado para
    %   nova arquitetura, preservando configurações existentes e fornecendo
    %   sistema de rollback em caso de problemas.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - File I/O Operations
    %   - Error Handling
    %   - Object-Oriented Programming
    %
    % USO:
    %   >> migrator = MigrationManager();
    %   >> success = migrator.performMigration();
    %   >> migrator.rollback(); % se necessário
    %
    % REQUISITOS: 5.5
    % ========================================================================
    
    properties (Access = private)
        backupDir = 'migration_backups'
        migrationLog = 'migration_log.txt'
        rollbackInfo = 'rollback_info.mat'
        logger
        startTime
    end
    
    properties (Constant)
        MIGRATION_VERSION = '2.0'
        LEGACY_CONFIG_FILE = 'config_caminhos.mat'
        NEW_CONFIG_DIR = 'config'
    end
    
    methods
        function obj = MigrationManager()
            % Construtor da classe MigrationManager
            
            obj.initializeLogger();
            obj.startTime = now;
            obj.ensureBackupDirectory();
            
            obj.logger('info', 'MigrationManager inicializado');
            obj.logger('info', sprintf('Versão de migração: %s', obj.MIGRATION_VERSION));
        end
        
        function success = performMigration(obj)
            % Executa migração completa do sistema legado para nova arquitetura
            %
            % SAÍDA:
            %   success - true se migração foi bem-sucedida
            %
            % REQUISITOS: 5.5
            
            success = false;
            
            try
                obj.logger('info', '=== INICIANDO MIGRAÇÃO DO SISTEMA ===');
                obj.logger('info', sprintf('Data/Hora: %s', datestr(now)));
                
                % Etapa 1: Verificar pré-requisitos
                if ~obj.checkPrerequisites()
                    obj.logger('error', 'Pré-requisitos não atendidos. Migração cancelada.');
                    return;
                end
                
                % Etapa 2: Criar backup completo do sistema atual
                if ~obj.createSystemBackup()
                    obj.logger('error', 'Falha ao criar backup. Migração cancelada.');
                    return;
                end
                
                % Etapa 3: Migrar configurações
                if ~obj.migrateConfigurations()
                    obj.logger('error', 'Falha na migração de configurações.');
                    obj.rollback();
                    return;
                end
                
                % Etapa 4: Migrar dados e estruturas
                if ~obj.migrateDataStructures()
                    obj.logger('error', 'Falha na migração de estruturas de dados.');
                    obj.rollback();
                    return;
                end
                
                % Etapa 5: Validar sistema migrado
                if ~obj.validateMigratedSystem()
                    obj.logger('error', 'Validação do sistema migrado falhou.');
                    obj.rollback();
                    return;
                end
                
                % Etapa 6: Finalizar migração
                obj.finalizeMigration();
                
                obj.logger('success', '=== MIGRAÇÃO CONCLUÍDA COM SUCESSO ===');
                success = true;
                
            catch ME
                obj.logger('error', sprintf('Erro durante migração: %s', ME.message));
                obj.logger('error', 'Executando rollback automático...');
                obj.rollback();
            end
        end
        
        function success = rollback(obj)
            % Executa rollback para estado anterior à migração
            %
            % SAÍDA:
            %   success - true se rollback foi bem-sucedido
            
            success = false;
            
            try
                obj.logger('warning', '=== INICIANDO ROLLBACK ===');
                
                % Verificar se existe informação de rollback
                if ~exist(obj.rollbackInfo, 'file')
                    obj.logger('error', 'Informações de rollback não encontradas');
                    return;
                end
                
                % Carregar informações de rollback
                rollbackData = load(obj.rollbackInfo);
                
                % Restaurar arquivos de backup
                if isfield(rollbackData, 'backupFiles')
                    for i = 1:length(rollbackData.backupFiles)
                        backupFile = rollbackData.backupFiles{i};
                        originalFile = rollbackData.originalFiles{i};
                        
                        if exist(backupFile, 'file')
                            copyfile(backupFile, originalFile);
                            obj.logger('info', sprintf('Restaurado: %s', originalFile));
                        end
                    end
                end
                
                % Remover arquivos criados durante migração
                if isfield(rollbackData, 'createdFiles')
                    for i = 1:length(rollbackData.createdFiles)
                        createdFile = rollbackData.createdFiles{i};
                        if exist(createdFile, 'file')
                            delete(createdFile);
                            obj.logger('info', sprintf('Removido: %s', createdFile));
                        end
                    end
                end
                
                % Remover diretórios criados
                if isfield(rollbackData, 'createdDirs')
                    for i = 1:length(rollbackData.createdDirs)
                        createdDir = rollbackData.createdDirs{i};
                        if exist(createdDir, 'dir')
                            rmdir(createdDir, 's');
                            obj.logger('info', sprintf('Diretório removido: %s', createdDir));
                        end
                    end
                end
                
                obj.logger('success', 'Rollback concluído com sucesso');
                success = true;
                
            catch ME
                obj.logger('error', sprintf('Erro durante rollback: %s', ME.message));
            end
        end
        
        function isCompatible = validateCompatibility(obj)
            % Valida compatibilidade com dados existentes
            %
            % SAÍDA:
            %   isCompatible - true se dados são compatíveis
            
            isCompatible = false;
            
            try
                obj.logger('info', 'Validando compatibilidade com dados existentes...');
                
                % Verificar se existe configuração legada
                if ~exist(obj.LEGACY_CONFIG_FILE, 'file')
                    obj.logger('warning', 'Configuração legada não encontrada');
                    isCompatible = true; % Não há nada para migrar
                    return;
                end
                
                % Carregar configuração legada
                legacyData = load(obj.LEGACY_CONFIG_FILE);
                if ~isfield(legacyData, 'config')
                    obj.logger('error', 'Configuração legada inválida');
                    return;
                end
                
                legacyConfig = legacyData.config;
                
                % Verificar campos essenciais
                requiredFields = {'imageDir', 'maskDir'};
                for i = 1:length(requiredFields)
                    if ~isfield(legacyConfig, requiredFields{i})
                        obj.logger('error', sprintf('Campo obrigatório ausente: %s', requiredFields{i}));
                        return;
                    end
                end
                
                % Verificar se diretórios ainda existem
                if ~exist(legacyConfig.imageDir, 'dir')
                    obj.logger('warning', sprintf('Diretório de imagens não existe: %s', legacyConfig.imageDir));
                end
                
                if ~exist(legacyConfig.maskDir, 'dir')
                    obj.logger('warning', sprintf('Diretório de máscaras não existe: %s', legacyConfig.maskDir));
                end
                
                obj.logger('success', 'Dados são compatíveis para migração');
                isCompatible = true;
                
            catch ME
                obj.logger('error', sprintf('Erro na validação de compatibilidade: %s', ME.message));
            end
        end
    end
    
    methods (Access = private)
        function initializeLogger(obj)
            % Inicializa sistema de logging
            
            obj.logger = @(level, message) obj.logMessage(level, message);
        end
        
        function logMessage(obj, level, message)
            % Registra mensagem no log
            
            timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
            logEntry = sprintf('[%s] %s: %s', timestamp, upper(level), message);
            
            % Exibir no console com cores
            switch lower(level)
                case 'success'
                    fprintf('✓ %s\n', message);
                case 'error'
                    fprintf('❌ %s\n', message);
                case 'warning'
                    fprintf('⚠️  %s\n', message);
                case 'info'
                    fprintf('ℹ️  %s\n', message);
                otherwise
                    fprintf('%s\n', message);
            end
            
            % Salvar no arquivo de log
            try
                fid = fopen(obj.migrationLog, 'a');
                if fid ~= -1
                    fprintf(fid, '%s\n', logEntry);
                    fclose(fid);
                end
            catch
                % Ignorar erros de log
            end
        end
        
        function ensureBackupDirectory(obj)
            % Garante que diretório de backup existe
            
            if ~exist(obj.backupDir, 'dir')
                mkdir(obj.backupDir);
            end
        end
        
        function success = checkPrerequisites(obj)
            % Verifica pré-requisitos para migração
            
            success = false;
            
            try
                obj.logger('info', 'Verificando pré-requisitos...');
                
                % Verificar se nova estrutura existe
                if ~exist('src', 'dir')
                    obj.logger('error', 'Diretório src/ não encontrado. Execute a criação da estrutura primeiro.');
                    return;
                end
                
                % Verificar componentes essenciais
                essentialFiles = {
                    'src/core/ConfigManager.m',
                    'src/core/MainInterface.m',
                    'src/data/DataLoader.m'
                };
                
                for i = 1:length(essentialFiles)
                    if ~exist(essentialFiles{i}, 'file')
                        obj.logger('error', sprintf('Arquivo essencial não encontrado: %s', essentialFiles{i}));
                        return;
                    end
                end
                
                % Verificar permissões de escrita
                testFile = 'migration_test.tmp';
                try
                    fid = fopen(testFile, 'w');
                    if fid ~= -1
                        fclose(fid);
                        delete(testFile);
                    else
                        obj.logger('error', 'Sem permissão de escrita no diretório atual');
                        return;
                    end
                catch
                    obj.logger('error', 'Erro ao testar permissões de escrita');
                    return;
                end
                
                obj.logger('success', 'Pré-requisitos atendidos');
                success = true;
                
            catch ME
                obj.logger('error', sprintf('Erro na verificação de pré-requisitos: %s', ME.message));
            end
        end
        
        function success = createSystemBackup(obj)
            % Cria backup completo do sistema atual
            
            success = false;
            
            try
                obj.logger('info', 'Criando backup do sistema atual...');
                
                timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
                backupSubdir = fullfile(obj.backupDir, sprintf('backup_%s', timestamp));
                mkdir(backupSubdir);
                
                % Lista de arquivos para backup
                filesToBackup = {
                    'config_caminhos.mat',
                    'executar_comparacao.m',
                    'configurar_caminhos.m',
                    'carregar_dados_robustos.m',
                    'preprocessDataCorrigido.m',
                    'treinar_unet_simples.m',
                    'create_working_attention_unet.m',
                    'comparacao_unet_attention_final.m'
                };
                
                backupFiles = {};
                originalFiles = {};
                
                for i = 1:length(filesToBackup)
                    originalFile = filesToBackup{i};
                    if exist(originalFile, 'file')
                        backupFile = fullfile(backupSubdir, originalFile);
                        
                        % Criar diretório se necessário
                        [backupDir, ~, ~] = fileparts(backupFile);
                        if ~exist(backupDir, 'dir')
                            mkdir(backupDir);
                        end
                        
                        copyfile(originalFile, backupFile);
                        backupFiles{end+1} = backupFile;
                        originalFiles{end+1} = originalFile;
                        
                        obj.logger('info', sprintf('Backup criado: %s', originalFile));
                    end
                end
                
                % Salvar informações de rollback
                rollbackData = struct();
                rollbackData.backupFiles = backupFiles;
                rollbackData.originalFiles = originalFiles;
                rollbackData.createdFiles = {};
                rollbackData.createdDirs = {};
                rollbackData.timestamp = timestamp;
                
                save(obj.rollbackInfo, 'rollbackData');
                
                obj.logger('success', sprintf('Backup completo criado em: %s', backupSubdir));
                success = true;
                
            catch ME
                obj.logger('error', sprintf('Erro ao criar backup: %s', ME.message));
            end
        end
        
        function success = migrateConfigurations(obj)
            % Migra configurações do sistema legado
            
            success = false;
            
            try
                obj.logger('info', 'Migrando configurações...');
                
                % Verificar se existe configuração legada
                if ~exist(obj.LEGACY_CONFIG_FILE, 'file')
                    obj.logger('info', 'Nenhuma configuração legada encontrada, criando padrão');
                    success = true;
                    return;
                end
                
                % Carregar configuração legada
                legacyData = load(obj.LEGACY_CONFIG_FILE);
                legacyConfig = legacyData.config;
                
                % Criar nova configuração baseada na legada
                newConfig = obj.convertLegacyConfig(legacyConfig);
                
                % Criar diretório de configuração se não existir
                if ~exist(obj.NEW_CONFIG_DIR, 'dir')
                    mkdir(obj.NEW_CONFIG_DIR);
                end
                
                % Salvar nova configuração
                newConfigFile = fullfile(obj.NEW_CONFIG_DIR, 'system_config.mat');
                save(newConfigFile, 'newConfig');
                
                % Também salvar no formato legado para compatibilidade
                config = newConfig;
                save('config_caminhos.mat', 'config');
                
                obj.logger('success', 'Configurações migradas com sucesso');
                success = true;
                
            catch ME
                obj.logger('error', sprintf('Erro na migração de configurações: %s', ME.message));
            end
        end
        
        function newConfig = convertLegacyConfig(obj, legacyConfig)
            % Converte configuração legada para novo formato
            
            newConfig = struct();
            
            % Campos básicos
            newConfig.imageDir = legacyConfig.imageDir;
            newConfig.maskDir = legacyConfig.maskDir;
            
            % Configurações de modelo
            if isfield(legacyConfig, 'inputSize')
                newConfig.inputSize = legacyConfig.inputSize;
            else
                newConfig.inputSize = [256, 256, 3];
            end
            
            if isfield(legacyConfig, 'numClasses')
                newConfig.numClasses = legacyConfig.numClasses;
            else
                newConfig.numClasses = 2;
            end
            
            % Configurações de treinamento
            if isfield(legacyConfig, 'validationSplit')
                newConfig.validationSplit = legacyConfig.validationSplit;
            else
                newConfig.validationSplit = 0.2;
            end
            
            if isfield(legacyConfig, 'miniBatchSize')
                newConfig.miniBatchSize = legacyConfig.miniBatchSize;
            else
                newConfig.miniBatchSize = 8;
            end
            
            if isfield(legacyConfig, 'maxEpochs')
                newConfig.maxEpochs = legacyConfig.maxEpochs;
            else
                newConfig.maxEpochs = 20;
            end
            
            % Configurações de saída
            newConfig.outputDir = fullfile(pwd, 'output');
            
            % Configurações de teste rápido
            if isfield(legacyConfig, 'quickTest')
                newConfig.quickTest = legacyConfig.quickTest;
            else
                newConfig.quickTest = struct('numSamples', 50, 'maxEpochs', 5);
            end
            
            % Informações do ambiente
            if isfield(legacyConfig, 'ambiente')
                newConfig.environment = legacyConfig.ambiente;
            else
                newConfig.environment = struct();
                newConfig.environment.username = getenv('USERNAME');
                newConfig.environment.computername = getenv('COMPUTERNAME');
                newConfig.environment.lastUpdate = datestr(now);
            end
            
            % Metadados de migração
            newConfig.migration = struct();
            newConfig.migration.migratedFrom = 'legacy_v1.2';
            newConfig.migration.migrationDate = datestr(now);
            newConfig.migration.migrationVersion = obj.MIGRATION_VERSION;
            
            obj.logger('info', 'Configuração convertida para novo formato');
        end
        
        function success = migrateDataStructures(obj)
            % Migra estruturas de dados e cria diretórios necessários
            
            success = false;
            
            try
                obj.logger('info', 'Migrando estruturas de dados...');
                
                % Criar diretórios de saída se não existirem
                outputDirs = {
                    'output',
                    'output/models',
                    'output/reports',
                    'output/visualizations',
                    'output/logs'
                };
                
                for i = 1:length(outputDirs)
                    if ~exist(outputDirs{i}, 'dir')
                        mkdir(outputDirs{i});
                        obj.logger('info', sprintf('Diretório criado: %s', outputDirs{i}));
                    end
                end
                
                % Migrar logs existentes se houver
                logFiles = dir('*.log');
                if ~isempty(logFiles)
                    for i = 1:length(logFiles)
                        source = logFiles(i).name;
                        target = fullfile('output', 'logs', source);
                        copyfile(source, target);
                        obj.logger('info', sprintf('Log migrado: %s', source));
                    end
                end
                
                % Migrar modelos salvos se houver
                modelFiles = dir('*.mat');
                modelFiles = modelFiles(contains({modelFiles.name}, {'net', 'model', 'trained'}));
                if ~isempty(modelFiles)
                    for i = 1:length(modelFiles)
                        source = modelFiles(i).name;
                        target = fullfile('output', 'models', source);
                        copyfile(source, target);
                        obj.logger('info', sprintf('Modelo migrado: %s', source));
                    end
                end
                
                obj.logger('success', 'Estruturas de dados migradas');
                success = true;
                
            catch ME
                obj.logger('error', sprintf('Erro na migração de estruturas: %s', ME.message));
            end
        end
        
        function success = validateMigratedSystem(obj)
            % Valida sistema após migração
            
            success = false;
            
            try
                obj.logger('info', 'Validando sistema migrado...');
                
                % Verificar se nova configuração existe e é válida
                if exist(fullfile(obj.NEW_CONFIG_DIR, 'system_config.mat'), 'file')
                    obj.logger('success', 'Nova configuração encontrada');
                else
                    obj.logger('error', 'Nova configuração não encontrada');
                    return;
                end
                
                % Verificar se ConfigManager funciona
                try
                    addpath('src/core');
                    configMgr = ConfigManager();
                    config = configMgr.loadConfig();
                    
                    if configMgr.validateConfig(config)
                        obj.logger('success', 'ConfigManager funcionando corretamente');
                    else
                        obj.logger('error', 'ConfigManager não validou configuração');
                        return;
                    end
                catch ME
                    obj.logger('error', sprintf('Erro ao testar ConfigManager: %s', ME.message));
                    return;
                end
                
                % Verificar se diretórios de saída existem
                requiredDirs = {'output', 'output/models', 'output/reports'};
                for i = 1:length(requiredDirs)
                    if ~exist(requiredDirs{i}, 'dir')
                        obj.logger('error', sprintf('Diretório obrigatório ausente: %s', requiredDirs{i}));
                        return;
                    end
                end
                
                obj.logger('success', 'Sistema migrado validado com sucesso');
                success = true;
                
            catch ME
                obj.logger('error', sprintf('Erro na validação: %s', ME.message));
            end
        end
        
        function finalizeMigration(obj)
            % Finaliza processo de migração
            
            try
                obj.logger('info', 'Finalizando migração...');
                
                % Criar arquivo de status da migração
                migrationStatus = struct();
                migrationStatus.completed = true;
                migrationStatus.version = obj.MIGRATION_VERSION;
                migrationStatus.date = datestr(now);
                migrationStatus.duration = (now - obj.startTime) * 24 * 60; % em minutos
                
                save('migration_status.mat', 'migrationStatus');
                
                % Criar README de migração
                readmeContent = {
                    '# Sistema Migrado com Sucesso';
                    '';
                    sprintf('Data da migração: %s', datestr(now));
                    sprintf('Versão: %s', obj.MIGRATION_VERSION);
                    sprintf('Duração: %.1f minutos', migrationStatus.duration);
                    '';
                    '## Mudanças Principais:';
                    '- Configurações migradas para nova arquitetura';
                    '- Estrutura de diretórios reorganizada';
                    '- Sistema de backup implementado';
                    '';
                    '## Como usar o novo sistema:';
                    '1. Execute: addpath(''src/core'')';
                    '2. Execute: mainInterface = MainInterface()';
                    '3. Execute: mainInterface.run()';
                    '';
                    '## Rollback (se necessário):';
                    '1. Execute: migrator = MigrationManager()';
                    '2. Execute: migrator.rollback()';
                };
                
                fid = fopen('MIGRATION_README.md', 'w');
                if fid ~= -1
                    for i = 1:length(readmeContent)
                        fprintf(fid, '%s\n', readmeContent{i});
                    end
                    fclose(fid);
                end
                
                obj.logger('success', 'Migração finalizada. Consulte MIGRATION_README.md para instruções.');
                
            catch ME
                obj.logger('error', sprintf('Erro ao finalizar migração: %s', ME.message));
            end
        end
    end
end