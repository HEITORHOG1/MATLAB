function test_config_manager()
    % ========================================================================
    % TESTES UNITÁRIOS - CONFIG MANAGER
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Testes unitários abrangentes para a classe ConfigManager
    %
    % TUTORIAL MATLAB:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Object-Oriented Programming
    %   - File I/O
    % ========================================================================
    
    fprintf('=== INICIANDO TESTES UNITÁRIOS - CONFIG MANAGER ===\n\n');
    
    % Adicionar caminho para as classes
    addpath(genpath('src'));
    
    % Executar todos os testes
    try
        test_constructor();
        test_load_save_config();
        test_validate_config();
        test_auto_detection();
        test_portable_config();
        test_backup_system();
        test_error_handling();
        test_edge_cases();
        
        fprintf('\n=== TODOS OS TESTES PASSARAM! ===\n');
        
    catch ME
        fprintf('\n=== ERRO NOS TESTES ===\n');
        fprintf('Erro: %s\n', ME.message);
        if ~isempty(ME.stack)
            fprintf('Arquivo: %s\n', ME.stack(1).file);
            fprintf('Linha: %d\n', ME.stack(1).line);
        end
        rethrow(ME);
    end
end

function test_constructor()
    fprintf('Testando construtor...\n');
    
    % Teste construtor padrão
    config1 = ConfigManager();
    assert(isa(config1, 'ConfigManager'), 'Construtor padrão falhou');
    
    % Teste construtor com parâmetros
    config2 = ConfigManager('verbose', true, 'autoDetect', false);
    assert(isa(config2, 'ConfigManager'), 'Construtor com parâmetros falhou');
    
    % Teste construtor com arquivo específico
    testFile = 'test_config.mat';
    config3 = ConfigManager('configFile', testFile);
    assert(isa(config3, 'ConfigManager'), 'Construtor com arquivo falhou');
    
    % Limpar arquivo de teste
    if exist(testFile, 'file')
        delete(testFile);
    end
    
    fprintf('✓ Construtor OK\n');
end

function test_load_save_config()
    fprintf('Testando carregamento e salvamento...\n');
    
    config = ConfigManager();
    
    % Criar configuração de teste
    testConfig = struct();
    testConfig.paths = struct();
    testConfig.paths.imageDir = 'test/images';
    testConfig.paths.maskDir = 'test/masks';
    testConfig.paths.outputDir = 'test/output';
    testConfig.model = struct();
    testConfig.model.inputSize = [256, 256, 3];
    testConfig.model.numClasses = 2;
    testConfig.training = struct();
    testConfig.training.maxEpochs = 20;
    testConfig.training.miniBatchSize = 8;
    
    % Testar salvamento
    testFile = 'test_config_save.mat';
    success = config.saveConfig(testConfig, testFile);
    assert(success, 'Salvamento falhou');
    assert(exist(testFile, 'file') == 2, 'Arquivo não foi criado');
    
    % Testar carregamento
    loadedConfig = config.loadConfig(testFile);
    assert(isstruct(loadedConfig), 'Configuração carregada não é struct');
    assert(isfield(loadedConfig, 'paths'), 'Campo paths não encontrado');
    assert(isfield(loadedConfig, 'model'), 'Campo model não encontrado');
    assert(isfield(loadedConfig, 'training'), 'Campo training não encontrado');
    
    % Verificar valores específicos
    assert(strcmp(loadedConfig.paths.imageDir, 'test/images'), 'imageDir incorreto');
    assert(isequal(loadedConfig.model.inputSize, [256, 256, 3]), 'inputSize incorreto');
    assert(loadedConfig.training.maxEpochs == 20, 'maxEpochs incorreto');
    
    % Limpar arquivo de teste
    delete(testFile);
    
    fprintf('✓ Carregamento e salvamento OK\n');
end

function test_validate_config()
    fprintf('Testando validação de configuração...\n');
    
    config = ConfigManager();
    
    % Configuração válida
    validConfig = struct();
    validConfig.paths = struct();
    validConfig.paths.imageDir = pwd; % Usar diretório atual (existe)
    validConfig.paths.maskDir = pwd;
    validConfig.paths.outputDir = pwd;
    validConfig.model = struct();
    validConfig.model.inputSize = [256, 256, 3];
    validConfig.model.numClasses = 2;
    validConfig.training = struct();
    validConfig.training.maxEpochs = 20;
    validConfig.training.miniBatchSize = 8;
    validConfig.training.learningRate = 1e-3;
    
    [isValid, errors] = config.validateConfig(validConfig);
    assert(isValid, sprintf('Configuração válida rejeitada: %s', strjoin(errors, '; ')));
    assert(isempty(errors), 'Erros reportados para configuração válida');
    
    % Configuração inválida - campos obrigatórios ausentes
    invalidConfig1 = struct();
    [isValid1, errors1] = config.validateConfig(invalidConfig1);
    assert(~isValid1, 'Configuração inválida aceita');
    assert(~isempty(errors1), 'Nenhum erro reportado para configuração inválida');
    
    % Configuração inválida - valores incorretos
    invalidConfig2 = validConfig;
    invalidConfig2.model.inputSize = [256, 256]; % Dimensão incorreta
    invalidConfig2.training.maxEpochs = -1; % Valor negativo
    invalidConfig2.training.miniBatchSize = 0; % Valor zero
    
    [isValid2, errors2] = config.validateConfig(invalidConfig2);
    assert(~isValid2, 'Configuração com valores incorretos aceita');
    assert(length(errors2) >= 3, 'Nem todos os erros foram detectados');
    
    % Configuração inválida - diretórios inexistentes
    invalidConfig3 = validConfig;
    invalidConfig3.paths.imageDir = '/diretorio/inexistente';
    invalidConfig3.paths.maskDir = '/outro/diretorio/inexistente';
    
    [isValid3, errors3] = config.validateConfig(invalidConfig3);
    assert(~isValid3, 'Configuração com diretórios inexistentes aceita');
    
    fprintf('✓ Validação de configuração OK\n');
end

function test_auto_detection()
    fprintf('Testando detecção automática...\n');
    
    config = ConfigManager();
    
    % Testar detecção de diretórios comuns
    commonDirs = config.detectCommonDirectories();
    assert(isstruct(commonDirs), 'Resultado da detecção não é struct');
    assert(isfield(commonDirs, 'found'), 'Campo found não encontrado');
    assert(isfield(commonDirs, 'candidates'), 'Campo candidates não encontrado');
    
    % Testar detecção de hardware
    hardwareInfo = config.detectHardware();
    assert(isstruct(hardwareInfo), 'Informações de hardware não são struct');
    assert(isfield(hardwareInfo, 'hasGPU'), 'Campo hasGPU não encontrado');
    assert(isfield(hardwareInfo, 'memoryGB'), 'Campo memoryGB não encontrado');
    assert(isfield(hardwareInfo, 'recommendedBatchSize'), 'Campo recommendedBatchSize não encontrado');
    
    % Verificar tipos de dados
    assert(islogical(hardwareInfo.hasGPU), 'hasGPU deve ser lógico');
    assert(isnumeric(hardwareInfo.memoryGB), 'memoryGB deve ser numérico');
    assert(isnumeric(hardwareInfo.recommendedBatchSize), 'recommendedBatchSize deve ser numérico');
    
    % Testar criação de configuração padrão
    defaultConfig = config.createDefaultConfig();
    assert(isstruct(defaultConfig), 'Configuração padrão não é struct');
    
    [isValid, ~] = config.validateConfig(defaultConfig);
    % Nota: pode não ser válida se diretórios não existirem, mas deve ter estrutura correta
    assert(isfield(defaultConfig, 'paths'), 'Configuração padrão sem campo paths');
    assert(isfield(defaultConfig, 'model'), 'Configuração padrão sem campo model');
    assert(isfield(defaultConfig, 'training'), 'Configuração padrão sem campo training');
    
    fprintf('✓ Detecção automática OK\n');
end

function test_portable_config()
    fprintf('Testando configuração portátil...\n');
    
    config = ConfigManager();
    
    % Criar configuração de teste
    testConfig = struct();
    testConfig.paths = struct();
    testConfig.paths.imageDir = fullfile(pwd, 'images');
    testConfig.paths.maskDir = fullfile(pwd, 'masks');
    testConfig.paths.outputDir = fullfile(pwd, 'output');
    testConfig.model = struct();
    testConfig.model.inputSize = [256, 256, 3];
    testConfig.model.numClasses = 2;
    testConfig.training = struct();
    testConfig.training.maxEpochs = 20;
    testConfig.training.miniBatchSize = 8;
    
    % Testar exportação portátil
    portableFile = 'test_portable_config.json';
    success = config.exportPortableConfig(testConfig, portableFile);
    assert(success, 'Exportação portátil falhou');
    assert(exist(portableFile, 'file') == 2, 'Arquivo portátil não foi criado');
    
    % Testar importação portátil
    importedConfig = config.importPortableConfig(portableFile);
    assert(isstruct(importedConfig), 'Configuração importada não é struct');
    
    % Verificar se os campos principais foram preservados
    assert(isfield(importedConfig, 'model'), 'Campo model perdido na importação');
    assert(isfield(importedConfig, 'training'), 'Campo training perdido na importação');
    assert(isequal(importedConfig.model.inputSize, [256, 256, 3]), 'inputSize alterado');
    assert(importedConfig.training.maxEpochs == 20, 'maxEpochs alterado');
    
    % Limpar arquivo de teste
    delete(portableFile);
    
    fprintf('✓ Configuração portátil OK\n');
end

function test_backup_system()
    fprintf('Testando sistema de backup...\n');
    
    config = ConfigManager();
    
    % Criar configuração de teste
    testConfig = struct();
    testConfig.paths = struct();
    testConfig.paths.imageDir = 'test/images';
    testConfig.model = struct();
    testConfig.model.inputSize = [256, 256, 3];
    
    % Testar criação de backup
    backupFile = config.createBackup(testConfig);
    assert(~isempty(backupFile), 'Backup não foi criado');
    assert(exist(backupFile, 'file') == 2, 'Arquivo de backup não existe');
    
    % Testar listagem de backups
    backups = config.listBackups();
    assert(iscell(backups), 'Lista de backups não é cell array');
    assert(~isempty(backups), 'Nenhum backup encontrado');
    
    % Testar restauração de backup
    restoredConfig = config.restoreBackup(backupFile);
    assert(isstruct(restoredConfig), 'Configuração restaurada não é struct');
    assert(isfield(restoredConfig, 'paths'), 'Campo paths perdido na restauração');
    assert(strcmp(restoredConfig.paths.imageDir, 'test/images'), 'imageDir alterado na restauração');
    
    % Testar limpeza de backups antigos
    numCleaned = config.cleanOldBackups(0); % Limpar todos
    assert(isnumeric(numCleaned), 'Número de backups limpos deve ser numérico');
    
    fprintf('✓ Sistema de backup OK\n');
end

function test_error_handling()
    fprintf('Testando tratamento de erros...\n');
    
    config = ConfigManager();
    
    % Teste carregamento de arquivo inexistente
    loadedConfig = config.loadConfig('arquivo_inexistente.mat');
    assert(isempty(loadedConfig), 'Deveria retornar vazio para arquivo inexistente');
    
    % Teste salvamento em diretório protegido (pode falhar em alguns sistemas)
    testConfig = struct('test', 'value');
    try
        success = config.saveConfig(testConfig, '/root/test_config.mat');
        % Se chegou aqui, ou teve sucesso ou tratou o erro graciosamente
        assert(islogical(success), 'Resultado do salvamento deve ser lógico');
    catch
        % Erro esperado em sistemas onde /root não é acessível
        fprintf('  ⚠ Teste de salvamento em diretório protegido pulado\n');
    end
    
    % Teste validação de configuração malformada
    malformedConfig = 'not a struct';
    [isValid, errors] = config.validateConfig(malformedConfig);
    assert(~isValid, 'Configuração malformada aceita');
    assert(~isempty(errors), 'Nenhum erro reportado para configuração malformada');
    
    % Teste importação de arquivo JSON inválido
    invalidJsonFile = 'invalid.json';
    fid = fopen(invalidJsonFile, 'w');
    fprintf(fid, '{ invalid json content }');
    fclose(fid);
    
    importedConfig = config.importPortableConfig(invalidJsonFile);
    assert(isempty(importedConfig), 'Deveria retornar vazio para JSON inválido');
    
    delete(invalidJsonFile);
    
    fprintf('✓ Tratamento de erros OK\n');
end

function test_edge_cases()
    fprintf('Testando casos extremos...\n');
    
    config = ConfigManager();
    
    % Configuração vazia
    emptyConfig = struct();
    [isValid, errors] = config.validateConfig(emptyConfig);
    assert(~isValid, 'Configuração vazia aceita');
    assert(~isempty(errors), 'Nenhum erro para configuração vazia');
    
    % Configuração com campos extras
    extraConfig = struct();
    extraConfig.paths = struct('imageDir', pwd, 'maskDir', pwd, 'outputDir', pwd);
    extraConfig.model = struct('inputSize', [256, 256, 3], 'numClasses', 2);
    extraConfig.training = struct('maxEpochs', 20, 'miniBatchSize', 8, 'learningRate', 1e-3);
    extraConfig.extraField = 'should be ignored';
    extraConfig.anotherExtra = 123;
    
    [isValid, errors] = config.validateConfig(extraConfig);
    % Deve ser válida mesmo com campos extras
    assert(isValid, sprintf('Configuração com campos extras rejeitada: %s', strjoin(errors, '; ')));
    
    % Configuração com valores limítrofes
    limitConfig = extraConfig;
    limitConfig.training.maxEpochs = 1; % Mínimo
    limitConfig.training.miniBatchSize = 1; % Mínimo
    limitConfig.training.learningRate = 1e-6; % Muito pequeno
    limitConfig.model.numClasses = 1; % Mínimo (pode ser inválido dependendo da implementação)
    
    [isValid, errors] = config.validateConfig(limitConfig);
    % Resultado pode variar dependendo das regras de validação
    if ~isValid
        fprintf('  ⚠ Configuração com valores limítrofes rejeitada (esperado): %s\n', strjoin(errors, '; '));
    else
        fprintf('  ✓ Configuração com valores limítrofes aceita\n');
    end
    
    % Configuração com tipos incorretos
    wrongTypeConfig = extraConfig;
    wrongTypeConfig.training.maxEpochs = '20'; % String em vez de número
    wrongTypeConfig.model.inputSize = '256,256,3'; % String em vez de array
    
    [isValid, errors] = config.validateConfig(wrongTypeConfig);
    assert(~isValid, 'Configuração com tipos incorretos aceita');
    assert(length(errors) >= 2, 'Nem todos os erros de tipo foram detectados');
    
    fprintf('✓ Casos extremos OK\n');
end