classdef VersionManager < handle
    % ========================================================================
    % VERSIONMANAGER - GERENCIADOR DE VERSÃO E BACKUP
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Classe para gerenciar versionamento do sistema, criar backups
    %   automáticos e manter histórico de releases.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - File I/O Operations
    %   - Version Control Concepts
    %   - System Administration
    %
    % USO:
    %   >> versionMgr = VersionManager();
    %   >> versionMgr.createBackup();
    %   >> versionMgr.showVersionInfo();
    %
    % REQUISITOS: 2.1, 2.2
    % ========================================================================
    
    properties (Access = private)
        versionFile = 'VERSION.mat'
        backupDir = 'version_backups'
        releaseNotesFile = 'RELEASE_NOTES.md'
        logger
    end
    
    properties (Constant)
        CURRENT_VERSION = '2.0.0'
        VERSION_FORMAT = 'MAJOR.MINOR.PATCH'
        BACKUP_RETENTION_DAYS = 30
    end
    
    methods
        function obj = VersionManager()
            % Construtor da classe VersionManager
            
            obj.initializeLogger();
            obj.ensureBackupDirectory();
            obj.initializeVersionFile();
            
            obj.logger('info', 'VersionManager inicializado');
        end
        
        function versionInfo = getCurrentVersion(obj)
            % Obtém informações da versão atual
            %
            % SAÍDA:
            %   versionInfo - estrutura com informações da versão
            
            try
                if exist(obj.versionFile, 'file')
                    versionData = load(obj.versionFile);
                    versionInfo = versionData.versionInfo;
                else
                    versionInfo = obj.createDefaultVersionInfo();
                    obj.saveVersionInfo(versionInfo);
                end
                
                obj.logger('info', sprintf('Versão atual: %s', versionInfo.version));
                
            catch ME
                obj.logger('error', sprintf('Erro ao obter versão: %s', ME.message));
                versionInfo = obj.createDefaultVersionInfo();
            end
        end
        
        function success = createBackup(obj, backupName)
            % Cria backup completo do sistema atual
            %
            % ENTRADA:
            %   backupName (opcional) - nome personalizado para o backup
            %
            % SAÍDA:
            %   success - true se backup foi criado com sucesso
            %
            % REQUISITOS: 2.2
            
            if nargin < 2
                timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
                backupName = sprintf('backup_%s_v%s', timestamp, obj.CURRENT_VERSION);
            end
            
            success = false;
            
            try
                obj.logger('info', sprintf('Criando backup: %s', backupName));
                
                % Criar diretório de backup
                backupPath = fullfile(obj.backupDir, backupName);
                if ~exist(backupPath, 'dir')
                    mkdir(backupPath);
                end
                
                % Lista de arquivos e diretórios para backup
                itemsToBackup = {
                    'src/',
                    'tests/',
                    'docs/',
                    'config/',
                    'README.md',
                    'CHANGELOG.md',
                    'INSTALLATION.md',
                    'config_caminhos.mat',
                    'VERSION.mat'
                };
                
                backupManifest = {};
                
                for i = 1:length(itemsToBackup)
                    item = itemsToBackup{i};
                    
                    if exist(item, 'file') || exist(item, 'dir')
                        targetPath = fullfile(backupPath, item);
                        
                        % Criar diretório pai se necessário
                        [parentDir, ~, ~] = fileparts(targetPath);
                        if ~exist(parentDir, 'dir')
                            mkdir(parentDir);
                        end
                        
                        if exist(item, 'dir')
                            copyfile(item, targetPath);
                            obj.logger('info', sprintf('Diretório copiado: %s', item));
                        else
                            copyfile(item, targetPath);
                            obj.logger('info', sprintf('Arquivo copiado: %s', item));
                        end
                        
                        backupManifest{end+1} = item;
                    end
                end
                
                % Criar manifesto do backup
                manifestInfo = struct();
                manifestInfo.backupName = backupName;
                manifestInfo.creationDate = datestr(now);
                manifestInfo.version = obj.CURRENT_VERSION;
                manifestInfo.items = backupManifest;
                manifestInfo.creator = obj.getUsername();
                manifestInfo.computer = obj.getComputerName();
                
                manifestFile = fullfile(backupPath, 'BACKUP_MANIFEST.mat');
                save(manifestFile, 'manifestInfo');
                
                % Criar README do backup
                obj.createBackupReadme(backupPath, manifestInfo);
                
                obj.logger('success', sprintf('Backup criado: %s', backupPath));
                success = true;
                
                % Limpar backups antigos
                obj.cleanupOldBackups();
                
            catch ME
                obj.logger('error', sprintf('Erro ao criar backup: %s', ME.message));
            end
        end
        
        function success = restoreBackup(obj, backupName)
            % Restaura sistema a partir de backup
            %
            % ENTRADA:
            %   backupName - nome do backup para restaurar
            %
            % SAÍDA:
            %   success - true se restauração foi bem-sucedida
            
            success = false;
            
            try
                backupPath = fullfile(obj.backupDir, backupName);
                
                if ~exist(backupPath, 'dir')
                    obj.logger('error', sprintf('Backup não encontrado: %s', backupName));
                    return;
                end
                
                obj.logger('info', sprintf('Restaurando backup: %s', backupName));
                
                % Carregar manifesto do backup
                manifestFile = fullfile(backupPath, 'BACKUP_MANIFEST.mat');
                if exist(manifestFile, 'file')
                    manifestData = load(manifestFile);
                    manifestInfo = manifestData.manifestInfo;
                    
                    obj.logger('info', sprintf('Backup criado em: %s', manifestInfo.creationDate));
                    obj.logger('info', sprintf('Versão do backup: %s', manifestInfo.version));
                else
                    obj.logger('warning', 'Manifesto do backup não encontrado, tentando restauração básica');
                    manifestInfo = struct('items', {{}});
                end
                
                % Criar backup do estado atual antes de restaurar
                currentBackupName = sprintf('pre_restore_%s', datestr(now, 'yyyy-mm-dd_HH-MM-SS'));
                obj.createBackup(currentBackupName);
                
                % Restaurar itens do backup
                if ~isempty(manifestInfo.items)
                    for i = 1:length(manifestInfo.items)
                        item = manifestInfo.items{i};
                        sourcePath = fullfile(backupPath, item);
                        targetPath = item;
                        
                        if exist(sourcePath, 'file') || exist(sourcePath, 'dir')
                            % Remover item atual se existir
                            if exist(targetPath, 'file')
                                delete(targetPath);
                            elseif exist(targetPath, 'dir')
                                rmdir(targetPath, 's');
                            end
                            
                            % Copiar do backup
                            copyfile(sourcePath, targetPath);
                            obj.logger('info', sprintf('Restaurado: %s', item));
                        end
                    end
                else
                    % Restauração básica se não há manifesto
                    obj.logger('info', 'Executando restauração básica...');
                    copyfile(fullfile(backupPath, '*'), '.');
                end
                
                obj.logger('success', 'Backup restaurado com sucesso');
                success = true;
                
            catch ME
                obj.logger('error', sprintf('Erro ao restaurar backup: %s', ME.message));
            end
        end
        
        function backupList = listBackups(obj)
            % Lista todos os backups disponíveis
            %
            % SAÍDA:
            %   backupList - cell array com informações dos backups
            
            backupList = {};
            
            try
                if ~exist(obj.backupDir, 'dir')
                    obj.logger('info', 'Nenhum backup encontrado');
                    return;
                end
                
                backupDirs = dir(obj.backupDir);
                backupDirs = backupDirs([backupDirs.isdir] & ~ismember({backupDirs.name}, {'.', '..'}));
                
                obj.logger('info', sprintf('Encontrados %d backups', length(backupDirs)));
                
                for i = 1:length(backupDirs)
                    backupName = backupDirs(i).name;
                    backupPath = fullfile(obj.backupDir, backupName);
                    
                    backupInfo = struct();
                    backupInfo.name = backupName;
                    backupInfo.path = backupPath;
                    backupInfo.date = backupDirs(i).date;
                    
                    % Tentar carregar manifesto
                    manifestFile = fullfile(backupPath, 'BACKUP_MANIFEST.mat');
                    if exist(manifestFile, 'file')
                        try
                            manifestData = load(manifestFile);
                            backupInfo.version = manifestData.manifestInfo.version;
                            backupInfo.creator = manifestData.manifestInfo.creator;
                            backupInfo.items = length(manifestData.manifestInfo.items);
                        catch
                            backupInfo.version = 'unknown';
                            backupInfo.creator = 'unknown';
                            backupInfo.items = 0;
                        end
                    else
                        backupInfo.version = 'unknown';
                        backupInfo.creator = 'unknown';
                        backupInfo.items = 0;
                    end
                    
                    backupList{end+1} = backupInfo;
                end
                
                % Ordenar por data (mais recente primeiro)
                if ~isempty(backupList)
                    dates = cellfun(@(x) datenum(x.date), backupList);
                    [~, sortIdx] = sort(dates, 'descend');
                    backupList = backupList(sortIdx);
                end
                
            catch ME
                obj.logger('error', sprintf('Erro ao listar backups: %s', ME.message));
            end
        end
        
        function showVersionInfo(obj)
            % Exibe informações detalhadas da versão
            
            try
                versionInfo = obj.getCurrentVersion();
                
                fprintf('\n');
                fprintf('========================================\n');
                fprintf('    INFORMAÇÕES DA VERSÃO DO SISTEMA    \n');
                fprintf('========================================\n');
                fprintf('Versão: %s\n', versionInfo.version);
                fprintf('Data de Release: %s\n', versionInfo.releaseDate);
                fprintf('Tipo de Release: %s\n', versionInfo.releaseType);
                fprintf('Build: %s\n', versionInfo.buildNumber);
                fprintf('========================================\n');
                fprintf('Ambiente:\n');
                fprintf('  MATLAB: %s\n', versionInfo.environment.matlabVersion);
                fprintf('  Sistema: %s\n', versionInfo.environment.platform);
                fprintf('  Usuário: %s\n', versionInfo.environment.username);
                fprintf('  Computador: %s\n', versionInfo.environment.computername);
                fprintf('========================================\n');
                fprintf('Componentes:\n');
                
                if isfield(versionInfo, 'components')
                    components = fieldnames(versionInfo.components);
                    for i = 1:length(components)
                        comp = components{i};
                        compVersion = versionInfo.components.(comp);
                        fprintf('  %s: %s\n', comp, compVersion);
                    end
                end
                
                fprintf('========================================\n\n');
                
            catch ME
                obj.logger('error', sprintf('Erro ao exibir informações: %s', ME.message));
            end
        end
        
        function success = createRelease(obj, releaseType, releaseNotes)
            % Cria nova release do sistema
            %
            % ENTRADA:
            %   releaseType - 'major', 'minor', ou 'patch'
            %   releaseNotes - notas da release
            %
            % SAÍDA:
            %   success - true se release foi criada
            
            if nargin < 3
                releaseNotes = 'Release automática';
            end
            
            success = false;
            
            try
                obj.logger('info', sprintf('Criando release %s', releaseType));
                
                % Obter versão atual
                currentVersion = obj.getCurrentVersion();
                
                % Calcular nova versão
                newVersion = obj.calculateNewVersion(currentVersion.version, releaseType);
                
                % Criar backup da versão atual
                backupName = sprintf('release_%s_v%s', datestr(now, 'yyyy-mm-dd'), currentVersion.version);
                if ~obj.createBackup(backupName)
                    obj.logger('error', 'Falha ao criar backup para release');
                    return;
                end
                
                % Criar nova informação de versão
                newVersionInfo = obj.createVersionInfo(newVersion, releaseType, releaseNotes);
                
                % Salvar nova versão
                if obj.saveVersionInfo(newVersionInfo)
                    obj.logger('success', sprintf('Release %s criada: %s', releaseType, newVersion));
                    success = true;
                    
                    % Atualizar changelog
                    obj.updateChangelog(newVersionInfo, releaseNotes);
                    
                    % Criar tag de release
                    obj.createReleaseTag(newVersionInfo);
                else
                    obj.logger('error', 'Falha ao salvar informações da nova versão');
                end
                
            catch ME
                obj.logger('error', sprintf('Erro ao criar release: %s', ME.message));
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
        end
        
        function ensureBackupDirectory(obj)
            % Garante que diretório de backup existe
            
            if ~exist(obj.backupDir, 'dir')
                mkdir(obj.backupDir);
            end
        end
        
        function initializeVersionFile(obj)
            % Inicializa arquivo de versão se não existir
            
            if ~exist(obj.versionFile, 'file')
                versionInfo = obj.createDefaultVersionInfo();
                obj.saveVersionInfo(versionInfo);
            end
        end
        
        function versionInfo = createDefaultVersionInfo(obj)
            % Cria informação de versão padrão
            
            versionInfo = struct();
            versionInfo.version = obj.CURRENT_VERSION;
            versionInfo.releaseDate = datestr(now, 'yyyy-mm-dd');
            versionInfo.releaseType = 'major';
            versionInfo.buildNumber = obj.generateBuildNumber();
            
            % Informações do ambiente
            versionInfo.environment = struct();
            versionInfo.environment.matlabVersion = version;
            versionInfo.environment.platform = computer;
            versionInfo.environment.username = obj.getUsername();
            versionInfo.environment.computername = obj.getComputerName();
            
            % Componentes do sistema
            versionInfo.components = struct();
            versionInfo.components.ConfigManager = '2.0.0';
            versionInfo.components.MainInterface = '2.0.0';
            versionInfo.components.DataLoader = '2.0.0';
            versionInfo.components.ModelTrainer = '2.0.0';
            versionInfo.components.MetricsCalculator = '2.0.0';
            versionInfo.components.Visualizer = '2.0.0';
        end
        
        function success = saveVersionInfo(obj, versionInfo)
            % Salva informações de versão
            
            success = false;
            
            try
                save(obj.versionFile, 'versionInfo');
                success = true;
            catch ME
                obj.logger('error', sprintf('Erro ao salvar versão: %s', ME.message));
            end
        end
        
        function buildNumber = generateBuildNumber(obj)
            % Gera número de build único
            
            buildNumber = sprintf('%s.%d', datestr(now, 'yyyymmdd'), round(now * 86400));
        end
        
        function username = getUsername(obj)
            % Obtém nome do usuário
            
            try
                username = getenv('USERNAME');
                if isempty(username)
                    username = getenv('USER');
                end
                if isempty(username)
                    username = 'unknown';
                end
            catch
                username = 'unknown';
            end
        end
        
        function computername = getComputerName(obj)
            % Obtém nome do computador
            
            try
                computername = getenv('COMPUTERNAME');
                if isempty(computername)
                    computername = getenv('HOSTNAME');
                end
                if isempty(computername)
                    computername = 'unknown';
                end
            catch
                computername = 'unknown';
            end
        end
        
        function cleanupOldBackups(obj)
            % Remove backups antigos baseado na política de retenção
            
            try
                if ~exist(obj.backupDir, 'dir')
                    return;
                end
                
                backupDirs = dir(obj.backupDir);
                backupDirs = backupDirs([backupDirs.isdir] & ~ismember({backupDirs.name}, {'.', '..'}));
                
                cutoffDate = now - obj.BACKUP_RETENTION_DAYS;
                
                for i = 1:length(backupDirs)
                    backupDate = datenum(backupDirs(i).date);
                    
                    if backupDate < cutoffDate
                        backupPath = fullfile(obj.backupDir, backupDirs(i).name);
                        rmdir(backupPath, 's');
                        obj.logger('info', sprintf('Backup antigo removido: %s', backupDirs(i).name));
                    end
                end
                
            catch ME
                obj.logger('warning', sprintf('Erro na limpeza de backups: %s', ME.message));
            end
        end
        
        function createBackupReadme(obj, backupPath, manifestInfo)
            % Cria README para o backup
            
            try
                readmeFile = fullfile(backupPath, 'README.md');
                
                fid = fopen(readmeFile, 'w');
                if fid == -1
                    return;
                end
                
                fprintf(fid, '# Backup do Sistema - %s\n\n', manifestInfo.backupName);
                fprintf(fid, '## Informações do Backup\n\n');
                fprintf(fid, '- **Data de Criação**: %s\n', manifestInfo.creationDate);
                fprintf(fid, '- **Versão**: %s\n', manifestInfo.version);
                fprintf(fid, '- **Criado por**: %s@%s\n', manifestInfo.creator, manifestInfo.computer);
                fprintf(fid, '- **Itens incluídos**: %d\n\n', length(manifestInfo.items));
                
                fprintf(fid, '## Conteúdo do Backup\n\n');
                for i = 1:length(manifestInfo.items)
                    fprintf(fid, '- %s\n', manifestInfo.items{i});
                end
                
                fprintf(fid, '\n## Como Restaurar\n\n');
                fprintf(fid, '```matlab\n');
                fprintf(fid, '%% Carregar VersionManager\n');
                fprintf(fid, 'addpath(''src/utils'')\n');
                fprintf(fid, 'versionMgr = VersionManager()\n\n');
                fprintf(fid, '%% Restaurar este backup\n');
                fprintf(fid, 'versionMgr.restoreBackup(''%s'')\n', manifestInfo.backupName);
                fprintf(fid, '```\n\n');
                
                fprintf(fid, '## Aviso\n\n');
                fprintf(fid, 'Este backup foi criado automaticamente. ');
                fprintf(fid, 'Certifique-se de fazer backup do estado atual antes de restaurar.\n');
                
                fclose(fid);
                
            catch ME
                obj.logger('warning', sprintf('Erro ao criar README do backup: %s', ME.message));
                if exist('fid', 'var') && fid ~= -1
                    fclose(fid);
                end
            end
        end
        
        function newVersion = calculateNewVersion(obj, currentVersion, releaseType)
            % Calcula nova versão baseada no tipo de release
            
            % Parse da versão atual
            versionParts = strsplit(currentVersion, '.');
            major = str2double(versionParts{1});
            minor = str2double(versionParts{2});
            patch = str2double(versionParts{3});
            
            % Incrementar baseado no tipo
            switch lower(releaseType)
                case 'major'
                    major = major + 1;
                    minor = 0;
                    patch = 0;
                case 'minor'
                    minor = minor + 1;
                    patch = 0;
                case 'patch'
                    patch = patch + 1;
                otherwise
                    error('Tipo de release inválido: %s', releaseType);
            end
            
            newVersion = sprintf('%d.%d.%d', major, minor, patch);
        end
        
        function versionInfo = createVersionInfo(obj, version, releaseType, releaseNotes)
            % Cria estrutura de informação de versão
            
            versionInfo = obj.createDefaultVersionInfo();
            versionInfo.version = version;
            versionInfo.releaseType = releaseType;
            versionInfo.releaseNotes = releaseNotes;
            versionInfo.buildNumber = obj.generateBuildNumber();
        end
        
        function updateChangelog(obj, versionInfo, releaseNotes)
            % Atualiza changelog com nova versão
            
            try
                if ~exist('CHANGELOG.md', 'file')
                    return;
                end
                
                % Ler changelog atual
                fid = fopen('CHANGELOG.md', 'r');
                if fid == -1
                    return;
                end
                
                currentContent = fread(fid, '*char')';
                fclose(fid);
                
                % Criar entrada para nova versão
                newEntry = sprintf('\n## [%s] - %s\n\n### %s\n\n%s\n\n---\n', ...
                    versionInfo.version, versionInfo.releaseDate, ...
                    upper(versionInfo.releaseType), releaseNotes);
                
                % Encontrar onde inserir (após o cabeçalho)
                insertPos = strfind(currentContent, '## [');
                if ~isempty(insertPos)
                    insertPos = insertPos(1);
                    newContent = [currentContent(1:insertPos-1), newEntry, currentContent(insertPos:end)];
                else
                    newContent = [currentContent, newEntry];
                end
                
                % Salvar changelog atualizado
                fid = fopen('CHANGELOG.md', 'w');
                if fid ~= -1
                    fprintf(fid, '%s', newContent);
                    fclose(fid);
                    obj.logger('success', 'Changelog atualizado');
                end
                
            catch ME
                obj.logger('warning', sprintf('Erro ao atualizar changelog: %s', ME.message));
            end
        end
        
        function createReleaseTag(obj, versionInfo)
            % Cria tag de release
            
            try
                tagFile = sprintf('RELEASE_v%s.md', versionInfo.version);
                
                fid = fopen(tagFile, 'w');
                if fid == -1
                    return;
                end
                
                fprintf(fid, '# Release %s\n\n', versionInfo.version);
                fprintf(fid, '**Data**: %s\n', versionInfo.releaseDate);
                fprintf(fid, '**Tipo**: %s\n', versionInfo.releaseType);
                fprintf(fid, '**Build**: %s\n\n', versionInfo.buildNumber);
                
                fprintf(fid, '## Notas da Release\n\n');
                fprintf(fid, '%s\n\n', versionInfo.releaseNotes);
                
                fprintf(fid, '## Informações Técnicas\n\n');
                fprintf(fid, '- **MATLAB**: %s\n', versionInfo.environment.matlabVersion);
                fprintf(fid, '- **Plataforma**: %s\n', versionInfo.environment.platform);
                fprintf(fid, '- **Criado por**: %s@%s\n', versionInfo.environment.username, versionInfo.environment.computername);
                
                fclose(fid);
                
                obj.logger('success', sprintf('Tag de release criada: %s', tagFile));
                
            catch ME
                obj.logger('warning', sprintf('Erro ao criar tag de release: %s', ME.message));
                if exist('fid', 'var') && fid ~= -1
                    fclose(fid);
                end
            end
        end
    end
end