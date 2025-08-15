classdef BackupManager < handle
    % BackupManager - Sistema de backup e versionamento
    % 
    % Esta classe implementa sistema de backup automático e versionamento
    % com integração Git LFS para modelos grandes
    %
    % Uso:
    %   manager = BackupManager();
    %   manager.createBackup(modelPath, 'backup_v1');
    %   manager.initializeGitLFS();
    
    properties (Access = private)
        backupDirectory
        maxBackups
        compressionEnabled
        gitLFSEnabled
        versioningEnabled
    end
    
    methods
        function obj = BackupManager(varargin)
            % Constructor - Inicializa o gerenciador de backup
            %
            % Parâmetros:
            %   'BackupDirectory' - Diretório de backup (padrão: 'backups')
            %   'MaxBackups' - Número máximo de backups (padrão: 10)
            %   'CompressionEnabled' - Habilitar compressão (padrão: true)
            %   'GitLFSEnabled' - Habilitar Git LFS (padrão: false)
            %   'VersioningEnabled' - Habilitar versionamento (padrão: true)
            
            p = inputParser;
            addParameter(p, 'BackupDirectory', 'backups', @ischar);
            addParameter(p, 'MaxBackups', 10, @isnumeric);
            addParameter(p, 'CompressionEnabled', true, @islogical);
            addParameter(p, 'GitLFSEnabled', false, @islogical);
            addParameter(p, 'VersioningEnabled', true, @islogical);
            parse(p, varargin{:});
            
            obj.backupDirectory = p.Results.BackupDirectory;
            obj.maxBackups = p.Results.MaxBackups;
            obj.compressionEnabled = p.Results.CompressionEnabled;
            obj.gitLFSEnabled = p.Results.GitLFSEnabled;
            obj.versioningEnabled = p.Results.VersioningEnabled;
            
            % Criar diretório de backup se não existir
            if ~exist(obj.backupDirectory, 'dir')
                mkdir(obj.backupDirectory);
            end
            
            % Inicializar Git LFS se habilitado
            if obj.gitLFSEnabled
                obj.initializeGitLFS();
            end
        end
        
        function backupPath = createBackup(obj, sourcePath, backupName, varargin)
            % Cria backup de arquivo ou diretório
            %
            % Parâmetros:
            %   sourcePath - Caminho do arquivo/diretório a ser copiado
            %   backupName - Nome do backup (opcional, auto-gerado se vazio)
            %   'IncludeMetadata' - Incluir metadados (padrão: true)
            %   'Compress' - Comprimir backup (padrão: obj.compressionEnabled)
            
            p = inputParser;
            addParameter(p, 'IncludeMetadata', true, @islogical);
            addParameter(p, 'Compress', obj.compressionEnabled, @islogical);
            parse(p, varargin{:});
            
            if ~exist(sourcePath, 'file') && ~exist(sourcePath, 'dir')
                error('BackupManager:SourceNotFound', 'Arquivo/diretório não encontrado: %s', sourcePath);
            end
            
            % Gerar nome do backup se não fornecido
            if isempty(backupName)
                timestamp = datestr(now, 'yyyyMMdd_HHmmss');
                [~, name, ext] = fileparts(sourcePath);
                backupName = sprintf('%s_backup_%s%s', name, timestamp, ext);
            end
            
            % Determinar caminho do backup
            if obj.versioningEnabled
                version = obj.getNextVersion(backupName);
                backupName = sprintf('%s_v%d', backupName, version);
            end
            
            backupPath = fullfile(obj.backupDirectory, backupName);
            
            try
                % Criar backup
                if exist(sourcePath, 'dir')
                    obj.backupDirectory_internal(sourcePath, backupPath);
                else
                    obj.backupFile(sourcePath, backupPath);
                end
                
                % Comprimir se solicitado
                if p.Results.Compress
                    backupPath = obj.compressBackup(backupPath);
                end
                
                % Criar metadados
                if p.Results.IncludeMetadata
                    obj.createBackupMetadata(sourcePath, backupPath);
                end
                
                % Adicionar ao Git LFS se habilitado
                if obj.gitLFSEnabled
                    obj.addToGitLFS(backupPath);
                end
                
                % Limpar backups antigos
                obj.cleanupOldBackups();
                
                fprintf('Backup criado: %s\n', backupPath);
                
            catch ME
                error('BackupManager:BackupError', 'Erro ao criar backup: %s', ME.message);
            end
        end
        
        function success = restoreBackup(obj, backupPath, restorePath)
            % Restaura backup para localização especificada
            %
            % Parâmetros:
            %   backupPath - Caminho do backup
            %   restorePath - Caminho de destino para restauração
            
            success = false;
            
            try
                if ~exist(backupPath, 'file') && ~exist(backupPath, 'dir')
                    error('BackupManager:BackupNotFound', 'Backup não encontrado: %s', backupPath);
                end
                
                % Verificar se é arquivo comprimido
                [~, ~, ext] = fileparts(backupPath);
                if strcmp(ext, '.zip')
                    % Descomprimir primeiro
                    tempDir = tempname;
                    unzip(backupPath, tempDir);
                    
                    % Encontrar arquivo/diretório descomprimido
                    contents = dir(tempDir);
                    contents = contents(~ismember({contents.name}, {'.', '..'}));
                    
                    if length(contents) == 1
                        sourcePath = fullfile(tempDir, contents(1).name);
                    else
                        sourcePath = tempDir;
                    end
                else
                    sourcePath = backupPath;
                end
                
                % Restaurar
                if exist(sourcePath, 'dir')
                    if exist(restorePath, 'dir')
                        rmdir(restorePath, 's');
                    end
                    copyfile(sourcePath, restorePath);
                else
                    copyfile(sourcePath, restorePath);
                end
                
                % Limpar arquivos temporários
                if exist('tempDir', 'var') && exist(tempDir, 'dir')
                    rmdir(tempDir, 's');
                end
                
                success = true;
                fprintf('Backup restaurado: %s -> %s\n', backupPath, restorePath);
                
            catch ME
                error('BackupManager:RestoreError', 'Erro ao restaurar backup: %s', ME.message);
            end
        end
        
        function backups = listBackups(obj, pattern)
            % Lista backups disponíveis
            %
            % Parâmetros:
            %   pattern - Padrão de busca (opcional)
            
            if nargin < 2
                pattern = '*';
            end
            
            try
                files = dir(fullfile(obj.backupDirectory, pattern));
                files = files(~[files.isdir]);
                
                backups = struct('name', {}, 'path', {}, 'size', {}, 'date', {}, 'version', {});
                
                for i = 1:length(files)
                    backup = struct();
                    backup.name = files(i).name;
                    backup.path = fullfile(obj.backupDirectory, files(i).name);
                    backup.size = files(i).bytes;
                    backup.date = files(i).datenum;
                    backup.version = obj.extractVersion(files(i).name);
                    
                    backups(end+1) = backup;
                end
                
                % Ordenar por data (mais recente primeiro)
                if ~isempty(backups)
                    [~, idx] = sort([backups.date], 'descend');
                    backups = backups(idx);
                end
                
            catch ME
                error('BackupManager:ListError', 'Erro ao listar backups: %s', ME.message);
            end
        end
        
        function success = initializeGitLFS(obj)
            % Inicializa Git LFS no diretório de backup
            
            success = false;
            
            try
                % Verificar se Git está disponível
                [status, ~] = system('git --version');
                if status ~= 0
                    warning('BackupManager:GitNotFound', 'Git não encontrado no sistema');
                    return;
                end
                
                % Verificar se Git LFS está disponível
                [status, ~] = system('git lfs version');
                if status ~= 0
                    warning('BackupManager:GitLFSNotFound', 'Git LFS não encontrado no sistema');
                    return;
                end
                
                % Inicializar repositório Git se necessário
                gitDir = fullfile(obj.backupDirectory, '.git');
                if ~exist(gitDir, 'dir')
                    oldDir = pwd;
                    cd(obj.backupDirectory);
                    
                    system('git init');
                    system('git lfs install');
                    
                    % Configurar Git LFS para arquivos grandes
                    system('git lfs track "*.mat"');
                    system('git lfs track "*.zip"');
                    system('git lfs track "*.h5"');
                    system('git lfs track "*.onnx"');
                    
                    % Adicionar .gitattributes
                    system('git add .gitattributes');
                    system('git commit -m "Initialize Git LFS"');
                    
                    cd(oldDir);
                end
                
                success = true;
                fprintf('Git LFS inicializado no diretório de backup\n');
                
            catch ME
                warning('BackupManager:GitLFSError', 'Erro ao inicializar Git LFS: %s', ME.message);
            end
        end
        
        function success = addToGitLFS(obj, filePath)
            % Adiciona arquivo ao Git LFS
            
            success = false;
            
            try
                if ~obj.gitLFSEnabled
                    return;
                end
                
                % Verificar se arquivo está no diretório de backup
                [pathStr, ~, ~] = fileparts(filePath);
                if ~contains(pathStr, obj.backupDirectory)
                    return;
                end
                
                oldDir = pwd;
                cd(obj.backupDirectory);
                
                % Adicionar arquivo ao Git
                [~, name, ext] = fileparts(filePath);
                relativePath = [name, ext];
                
                system(sprintf('git add "%s"', relativePath));
                system(sprintf('git commit -m "Add backup: %s"', relativePath));
                
                cd(oldDir);
                
                success = true;
                
            catch ME
                warning('BackupManager:GitLFSAddError', 'Erro ao adicionar ao Git LFS: %s', ME.message);
            end
        end
        
        function cleanupOldBackups(obj)
            % Remove backups antigos mantendo apenas os mais recentes
            
            try
                backups = obj.listBackups();
                
                if length(backups) > obj.maxBackups
                    % Remover backups mais antigos
                    toRemove = backups((obj.maxBackups+1):end);
                    
                    for i = 1:length(toRemove)
                        backup = toRemove(i);
                        
                        % Remover do Git se necessário
                        if obj.gitLFSEnabled
                            obj.removeFromGit(backup.path);
                        end
                        
                        % Remover arquivo
                        if exist(backup.path, 'file')
                            delete(backup.path);
                        elseif exist(backup.path, 'dir')
                            rmdir(backup.path, 's');
                        end
                        
                        fprintf('Backup antigo removido: %s\n', backup.name);
                    end
                end
                
            catch ME
                warning('BackupManager:CleanupError', 'Erro na limpeza de backups: %s', ME.message);
            end
        end
        
        function metadata = getBackupMetadata(obj, backupPath)
            % Obtém metadados de um backup
            
            [pathStr, name, ~] = fileparts(backupPath);
            metadataFile = fullfile(pathStr, [name '_metadata.json']);
            
            metadata = struct();
            
            try
                if exist(metadataFile, 'file')
                    fid = fopen(metadataFile, 'r', 'n', 'UTF-8');
                    jsonStr = fread(fid, '*char')';
                    fclose(fid);
                    
                    metadata = jsondecode(jsonStr);
                end
                
            catch ME
                warning('BackupManager:MetadataError', 'Erro ao ler metadados: %s', ME.message);
            end
        end
        
        function success = validateBackup(obj, backupPath, originalPath)
            % Valida integridade de um backup
            
            success = false;
            
            try
                if ~exist(backupPath, 'file') && ~exist(backupPath, 'dir')
                    return;
                end
                
                % Para arquivos, comparar checksums
                if exist(backupPath, 'file') && exist(originalPath, 'file')
                    backupChecksum = obj.calculateChecksum(backupPath);
                    originalChecksum = obj.calculateChecksum(originalPath);
                    success = strcmp(backupChecksum, originalChecksum);
                    
                % Para diretórios, comparar estrutura
                elseif exist(backupPath, 'dir') && exist(originalPath, 'dir')
                    success = obj.compareDirectories(backupPath, originalPath);
                end
                
                if success
                    fprintf('Backup validado com sucesso: %s\n', backupPath);
                else
                    fprintf('Falha na validação do backup: %s\n', backupPath);
                end
                
            catch ME
                warning('BackupManager:ValidationError', 'Erro na validação: %s', ME.message);
            end
        end
    end
    
    methods (Access = private)
        function backupDirectory_internal(obj, sourceDir, backupDir)
            % Cria backup de diretório
            
            if exist(backupDir, 'dir')
                rmdir(backupDir, 's');
            end
            
            copyfile(sourceDir, backupDir);
        end
        
        function backupFile(obj, sourceFile, backupFile)
            % Cria backup de arquivo
            
            copyfile(sourceFile, backupFile);
        end
        
        function compressedPath = compressBackup(obj, backupPath)
            % Comprime backup usando ZIP
            
            [pathStr, name, ~] = fileparts(backupPath);
            compressedPath = fullfile(pathStr, [name '.zip']);
            
            if exist(backupPath, 'dir')
                zip(compressedPath, backupPath);
                rmdir(backupPath, 's');
            else
                zip(compressedPath, backupPath);
                delete(backupPath);
            end
        end
        
        function createBackupMetadata(obj, sourcePath, backupPath)
            % Cria arquivo de metadados para o backup
            
            metadata = struct();
            metadata.source_path = sourcePath;
            metadata.backup_path = backupPath;
            metadata.creation_date = datestr(now);
            metadata.matlab_version = version;
            metadata.backup_type = 'automatic';
            
            % Informações do arquivo/diretório original
            if exist(sourcePath, 'file')
                info = dir(sourcePath);
                metadata.source_size = info.bytes;
                metadata.source_date = datestr(info.datenum);
            elseif exist(sourcePath, 'dir')
                metadata.source_type = 'directory';
                metadata.source_date = datestr(now);
            end
            
            % Calcular checksum se for arquivo
            if exist(sourcePath, 'file')
                metadata.checksum = obj.calculateChecksum(sourcePath);
            end
            
            % Salvar metadados
            [pathStr, name, ~] = fileparts(backupPath);
            metadataFile = fullfile(pathStr, [name '_metadata.json']);
            
            jsonStr = jsonencode(metadata);
            fid = fopen(metadataFile, 'w', 'n', 'UTF-8');
            fprintf(fid, '%s', jsonStr);
            fclose(fid);
        end
        
        function version = getNextVersion(obj, baseName)
            % Obtém próximo número de versão
            
            version = 1;
            
            try
                pattern = sprintf('%s_v*', baseName);
                files = dir(fullfile(obj.backupDirectory, pattern));
                
                versions = [];
                for i = 1:length(files)
                    v = obj.extractVersion(files(i).name);
                    if ~isnan(v)
                        versions(end+1) = v;
                    end
                end
                
                if ~isempty(versions)
                    version = max(versions) + 1;
                end
                
            catch
                % Em caso de erro, usar versão 1
            end
        end
        
        function version = extractVersion(obj, filename)
            % Extrai número de versão do nome do arquivo
            
            version = NaN;
            
            try
                tokens = regexp(filename, '_v(\d+)', 'tokens');
                if ~isempty(tokens)
                    version = str2double(tokens{1}{1});
                end
            catch
                % Retornar NaN se não conseguir extrair
            end
        end
        
        function removeFromGit(obj, filePath)
            % Remove arquivo do Git
            
            try
                [~, name, ext] = fileparts(filePath);
                relativePath = [name, ext];
                
                oldDir = pwd;
                cd(obj.backupDirectory);
                
                system(sprintf('git rm "%s"', relativePath));
                system(sprintf('git commit -m "Remove old backup: %s"', relativePath));
                
                cd(oldDir);
                
            catch ME
                warning('BackupManager:GitRemoveError', 'Erro ao remover do Git: %s', ME.message);
            end
        end
        
        function checksum = calculateChecksum(obj, filePath)
            % Calcula checksum MD5 de um arquivo
            
            checksum = '';
            
            try
                % Usar função MATLAB se disponível
                if exist('GetMD5', 'file')
                    checksum = GetMD5(filePath, 'File');
                else
                    % Fallback: usar sistema operacional
                    if ispc
                        [status, result] = system(sprintf('certutil -hashfile "%s" MD5', filePath));
                        if status == 0
                            lines = strsplit(result, '\n');
                            if length(lines) >= 2
                                checksum = strtrim(lines{2});
                            end
                        end
                    else
                        [status, result] = system(sprintf('md5sum "%s"', filePath));
                        if status == 0
                            tokens = strsplit(result, ' ');
                            if ~isempty(tokens)
                                checksum = tokens{1};
                            end
                        end
                    end
                end
                
            catch ME
                warning('BackupManager:ChecksumError', 'Erro ao calcular checksum: %s', ME.message);
            end
        end
        
        function isEqual = compareDirectories(obj, dir1, dir2)
            % Compara estrutura de dois diretórios
            
            isEqual = false;
            
            try
                % Listar arquivos em ambos os diretórios
                files1 = obj.listDirectoryFiles(dir1);
                files2 = obj.listDirectoryFiles(dir2);
                
                % Comparar número de arquivos
                if length(files1) ~= length(files2)
                    return;
                end
                
                % Comparar nomes de arquivos
                names1 = sort({files1.name});
                names2 = sort({files2.name});
                
                if ~isequal(names1, names2)
                    return;
                end
                
                % Comparar tamanhos de arquivos
                sizes1 = [files1.bytes];
                sizes2 = [files2.bytes];
                
                if ~isequal(sizes1, sizes2)
                    return;
                end
                
                isEqual = true;
                
            catch ME
                warning('BackupManager:CompareError', 'Erro na comparação: %s', ME.message);
            end
        end
        
        function files = listDirectoryFiles(obj, dirPath)
            % Lista todos os arquivos em um diretório recursivamente
            
            files = [];
            
            try
                items = dir(dirPath);
                items = items(~ismember({items.name}, {'.', '..'}));
                
                for i = 1:length(items)
                    item = items(i);
                    itemPath = fullfile(dirPath, item.name);
                    
                    if item.isdir
                        subFiles = obj.listDirectoryFiles(itemPath);
                        files = [files, subFiles];
                    else
                        files = [files, item];
                    end
                end
                
            catch ME
                warning('BackupManager:ListFilesError', 'Erro ao listar arquivos: %s', ME.message);
            end
        end
    end
end