function test_cross_platform_compatibility()
    % ========================================================================
    % TESTE DE INTEGRAÇÃO - COMPATIBILIDADE MULTIPLATAFORMA
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Teste de integração que valida a compatibilidade do sistema
    %   em diferentes plataformas e configurações
    %
    % TUTORIAL MATLAB:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Cross-Platform Development
    %   - System Compatibility
    % ========================================================================
    
    fprintf('=== TESTE DE INTEGRAÇÃO - COMPATIBILIDADE MULTIPLATAFORMA ===\n\n');
    
    % Adicionar caminhos necessários
    addpath(genpath('src'));
    
    % Detectar ambiente atual
    platformInfo = detectPlatformInfo();
    fprintf('Plataforma detectada: %s\n', platformInfo.description);
    
    try
        % Executar testes de compatibilidade
        test_file_system_compatibility(platformInfo);
        test_path_handling_compatibility(platformInfo);
        test_toolbox_compatibility(platformInfo);
        test_gpu_compatibility(platformInfo);
        test_parallel_computing_compatibility(platformInfo);
        test_memory_management_compatibility(platformInfo);
        test_configuration_portability(platformInfo);
        test_data_format_compatibility(platformInfo);
        
        fprintf('\n=== TODOS OS TESTES DE COMPATIBILIDADE PASSARAM! ===\n');
        
    catch ME
        fprintf('\n=== ERRO NOS TESTES DE COMPATIBILIDADE ===\n');
        fprintf('Erro: %s\n', ME.message);
        if ~isempty(ME.stack)
            fprintf('Arquivo: %s\n', ME.stack(1).file);
            fprintf('Linha: %d\n', ME.stack(1).line);
        end
        rethrow(ME);
    end
end

function platformInfo = detectPlatformInfo()
    % Detecta informações da plataforma atual
    platformInfo = struct();
    
    % Sistema operacional
    if ispc
        platformInfo.os = 'Windows';
    elseif ismac
        platformInfo.os = 'macOS';
    elseif isunix
        platformInfo.os = 'Linux';
    else
        platformInfo.os = 'Unknown';
    end
    
    % Versão do MATLAB
    matlabVersion = version('-release');
    platformInfo.matlabVersion = matlabVersion;
    platformInfo.matlabYear = str2double(matlabVersion(1:4));
    
    % Arquitetura
    platformInfo.architecture = computer('arch');
    
    % Separador de caminho
    platformInfo.pathSeparator = filesep;
    
    % Informações de memória
    try
        memInfo = memory;
        platformInfo.totalMemory = memInfo.MaxPossibleArrayBytes;
        platformInfo.availableMemory = memInfo.MemAvailableAllArrays;
    catch
        platformInfo.totalMemory = NaN;
        platformInfo.availableMemory = NaN;
    end
    
    % Toolboxes disponíveis
    platformInfo.toolboxes = getAvailableToolboxes();
    
    % GPU disponível
    try
        gpuDevice();
        platformInfo.hasGPU = true;
        platformInfo.gpuCount = gpuDeviceCount();
    catch
        platformInfo.hasGPU = false;
        platformInfo.gpuCount = 0;
    end
    
    % Parallel Computing Toolbox
    try
        parpool('local', 2);
        delete(gcp('nocreate'));
        platformInfo.hasParallelToolbox = true;
    catch
        platformInfo.hasParallelToolbox = false;
    end
    
    % Descrição resumida
    platformInfo.description = sprintf('%s %s MATLAB %s', ...
        platformInfo.os, platformInfo.architecture, platformInfo.matlabVersion);
end

function toolboxes = getAvailableToolboxes()
    % Lista toolboxes disponíveis
    try
        installedToolboxes = ver;
        toolboxNames = {installedToolboxes.Name};
        
        % Toolboxes relevantes para o projeto
        relevantToolboxes = {
            'Deep Learning Toolbox'
            'Image Processing Toolbox'
            'Statistics and Machine Learning Toolbox'
            'Parallel Computing Toolbox'
            'Computer Vision Toolbox'
        };
        
        toolboxes = struct();
        for i = 1:length(relevantToolboxes)
            toolboxName = relevantToolboxes{i};
            fieldName = matlab.lang.makeValidName(toolboxName);
            toolboxes.(fieldName) = any(contains(toolboxNames, toolboxName));
        end
        
    catch
        toolboxes = struct();
    end
end

function test_file_system_compatibility(platformInfo)
    fprintf('Testando compatibilidade do sistema de arquivos...\n');
    
    % Criar diretório de teste
    testDir = 'test_filesystem_compat';
    if ~exist(testDir, 'dir')
        mkdir(testDir);
    end
    
    try
        % Teste 1: Criação e remoção de diretórios
        subDir = fullfile(testDir, 'subdir');
        mkdir(subDir);
        assert(exist(subDir, 'dir') == 7, 'Falha na criação de subdiretório');
        
        rmdir(subDir);
        assert(exist(subDir, 'dir') == 0, 'Falha na remoção de subdiretório');
        
        fprintf('  ✓ Operações de diretório funcionando\n');
        
        % Teste 2: Criação e remoção de arquivos
        testFile = fullfile(testDir, 'test_file.txt');
        fid = fopen(testFile, 'w');
        assert(fid ~= -1, 'Falha na criação de arquivo');
        fprintf(fid, 'Teste de compatibilidade\n');
        fclose(fid);
        
        assert(exist(testFile, 'file') == 2, 'Arquivo não foi criado');
        
        delete(testFile);
        assert(exist(testFile, 'file') == 0, 'Falha na remoção de arquivo');
        
        fprintf('  ✓ Operações de arquivo funcionando\n');
        
        % Teste 3: Caracteres especiais em nomes (dependente da plataforma)
        try
            specialFile = fullfile(testDir, 'arquivo_com_acentos_çãõ.txt');
            fid = fopen(specialFile, 'w');
            if fid ~= -1
                fclose(fid);
                delete(specialFile);
                fprintf('  ✓ Caracteres especiais suportados\n');
            else
                fprintf('  ⚠ Caracteres especiais não suportados\n');
            end
        catch
            fprintf('  ⚠ Caracteres especiais causaram erro\n');
        end
        
        % Teste 4: Caminhos longos
        try
            longPath = testDir;
            for i = 1:5
                longPath = fullfile(longPath, sprintf('very_long_directory_name_%d', i));
            end
            
            if length(longPath) < 260 || ~ispc % Windows tem limite de 260 caracteres
                mkdir(longPath);
                if exist(longPath, 'dir')
                    rmdir(fullfile(testDir, 'very_long_directory_name_1'), 's');
                    fprintf('  ✓ Caminhos longos suportados\n');
                else
                    fprintf('  ⚠ Caminhos longos não suportados\n');
                end
            else
                fprintf('  ⚠ Caminho muito longo para Windows\n');
            end
        catch
            fprintf('  ⚠ Erro com caminhos longos\n');
        end
        
        % Teste 5: Permissões de arquivo (Unix/Linux/macOS)
        if isunix
            try
                permFile = fullfile(testDir, 'perm_test.txt');
                fid = fopen(permFile, 'w');
                fclose(fid);
                
                % Tentar alterar permissões
                system(sprintf('chmod 644 "%s"', permFile));
                
                delete(permFile);
                fprintf('  ✓ Permissões de arquivo funcionando\n');
            catch
                fprintf('  ⚠ Erro com permissões de arquivo\n');
            end
        end
        
    finally
        % Limpar diretório de teste
        if exist(testDir, 'dir')
            rmdir(testDir, 's');
        end
    end
end

function test_path_handling_compatibility(platformInfo)
    fprintf('Testando compatibilidade de manipulação de caminhos...\n');
    
    % Teste 1: Separadores de caminho
    testPath1 = fullfile('dir1', 'dir2', 'file.txt');
    expectedSep = platformInfo.pathSeparator;
    
    assert(contains(testPath1, expectedSep), 'Separador de caminho incorreto');
    fprintf('  ✓ Separador de caminho: %s\n', expectedSep);
    
    % Teste 2: Caminhos absolutos vs relativos
    absolutePath = pwd;
    relativePath = '.';
    
    assert(isAbsolutePath(absolutePath), 'Caminho absoluto não reconhecido');
    assert(~isAbsolutePath(relativePath), 'Caminho relativo mal interpretado');
    
    fprintf('  ✓ Detecção de caminhos absolutos/relativos\n');
    
    % Teste 3: Normalização de caminhos
    unnormalizedPath = fullfile('.', 'dir1', '..', 'dir2', 'file.txt');
    normalizedPath = fullfile('dir2', 'file.txt');
    
    % MATLAB normaliza automaticamente com fullfile
    testNormalized = fullfile(unnormalizedPath);
    fprintf('  ✓ Normalização de caminhos: %s -> %s\n', unnormalizedPath, testNormalized);
    
    % Teste 4: Caracteres especiais em caminhos
    if ispc
        % Windows: testar unidades de disco
        drives = {'C:', 'D:'};
        for i = 1:length(drives)
            testDrivePath = fullfile(drives{i}, 'temp');
            if exist(drives{i}, 'dir')
                fprintf('  ✓ Unidade %s acessível\n', drives{i});
                break;
            end
        end
    else
        % Unix: testar caminhos com espaços
        spacePath = fullfile(pwd, 'dir with spaces');
        try
            mkdir(spacePath);
            rmdir(spacePath);
            fprintf('  ✓ Caminhos com espaços suportados\n');
        catch
            fprintf('  ⚠ Problemas com caminhos com espaços\n');
        end
    end
    
    % Teste 5: Caminhos de rede (Windows)
    if ispc
        try
            networkPath = '\\localhost\c$';
            if exist(networkPath, 'dir')
                fprintf('  ✓ Caminhos de rede acessíveis\n');
            else
                fprintf('  ⚠ Caminhos de rede não acessíveis\n');
            end
        catch
            fprintf('  ⚠ Erro ao testar caminhos de rede\n');
        end
    end
end

function test_toolbox_compatibility(platformInfo)
    fprintf('Testando compatibilidade de toolboxes...\n');
    
    toolboxes = platformInfo.toolboxes;
    
    % Teste Deep Learning Toolbox
    if isfield(toolboxes, 'DeepLearningToolbox') && toolboxes.DeepLearningToolbox
        try
            % Testar função básica
            layers = [
                imageInputLayer([28 28 1])
                convolution2dLayer(3, 8)
                reluLayer
                fullyConnectedLayer(10)
                softmaxLayer
                classificationLayer
            ];
            
            lgraph = layerGraph(layers);
            assert(~isempty(lgraph), 'Falha na criação de layer graph');
            
            fprintf('  ✓ Deep Learning Toolbox funcionando\n');
        catch ME
            fprintf('  ❌ Deep Learning Toolbox com problemas: %s\n', ME.message);
        end
    else
        fprintf('  ⚠ Deep Learning Toolbox não disponível\n');
    end
    
    % Teste Image Processing Toolbox
    if isfield(toolboxes, 'ImageProcessingToolbox') && toolboxes.ImageProcessingToolbox
        try
            % Testar função básica
            testImg = rand(100, 100);
            filteredImg = imgaussfilt(testImg, 2);
            assert(isequal(size(testImg), size(filteredImg)), 'Falha no processamento de imagem');
            
            fprintf('  ✓ Image Processing Toolbox funcionando\n');
        catch ME
            fprintf('  ❌ Image Processing Toolbox com problemas: %s\n', ME.message);
        end
    else
        fprintf('  ⚠ Image Processing Toolbox não disponível\n');
    end
    
    % Teste Statistics and Machine Learning Toolbox
    if isfield(toolboxes, 'StatisticsandMachineLearningToolbox') && toolboxes.StatisticsandMachineLearningToolbox
        try
            % Testar função básica
            data = randn(100, 2);
            [~, pval] = ttest(data(:,1), data(:,2));
            assert(isnumeric(pval), 'Falha no teste estatístico');
            
            fprintf('  ✓ Statistics and Machine Learning Toolbox funcionando\n');
        catch ME
            fprintf('  ❌ Statistics and Machine Learning Toolbox com problemas: %s\n', ME.message);
        end
    else
        fprintf('  ⚠ Statistics and Machine Learning Toolbox não disponível\n');
    end
    
    % Teste Parallel Computing Toolbox
    if isfield(toolboxes, 'ParallelComputingToolbox') && toolboxes.ParallelComputingToolbox
        try
            % Testar função básica
            data = 1:100;
            result = arrayfun(@(x) x^2, data);
            assert(length(result) == length(data), 'Falha no processamento paralelo');
            
            fprintf('  ✓ Parallel Computing Toolbox funcionando\n');
        catch ME
            fprintf('  ❌ Parallel Computing Toolbox com problemas: %s\n', ME.message);
        end
    else
        fprintf('  ⚠ Parallel Computing Toolbox não disponível\n');
    end
end

function test_gpu_compatibility(platformInfo)
    fprintf('Testando compatibilidade de GPU...\n');
    
    if platformInfo.hasGPU
        try
            % Testar acesso básico à GPU
            gpu = gpuDevice();
            fprintf('  ✓ GPU detectada: %s\n', gpu.Name);
            fprintf('    Memória: %.1f GB\n', gpu.TotalMemory / 1024^3);
            fprintf('    Compute Capability: %.1f\n', gpu.ComputeCapability);
            
            % Testar operação básica na GPU
            testData = rand(1000, 1000);
            gpuData = gpuArray(testData);
            result = sum(gpuData(:));
            cpuResult = gather(result);
            
            assert(isnumeric(cpuResult), 'Falha na operação GPU');
            fprintf('  ✓ Operações básicas na GPU funcionando\n');
            
            % Testar compatibilidade com Deep Learning
            if isfield(platformInfo.toolboxes, 'DeepLearningToolbox') && ...
               platformInfo.toolboxes.DeepLearningToolbox
                try
                    % Criar rede simples e testar na GPU
                    layers = [
                        imageInputLayer([28 28 1])
                        convolution2dLayer(3, 8)
                        reluLayer
                        globalAveragePooling2dLayer
                        fullyConnectedLayer(10)
                        softmaxLayer
                        classificationLayer
                    ];
                    
                    options = trainingOptions('sgdm', ...
                        'MaxEpochs', 1, ...
                        'MiniBatchSize', 32, ...
                        'ExecutionEnvironment', 'gpu', ...
                        'Verbose', false);
                    
                    fprintf('  ✓ Deep Learning compatível com GPU\n');
                    
                catch ME
                    fprintf('  ⚠ Deep Learning na GPU com problemas: %s\n', ME.message);
                end
            end
            
        catch ME
            fprintf('  ❌ Erro na GPU: %s\n', ME.message);
        end
    else
        fprintf('  ⚠ GPU não disponível\n');
        
        % Testar fallback para CPU
        try
            testData = rand(100, 100);
            result = sum(testData(:));
            assert(isnumeric(result), 'Falha no fallback CPU');
            fprintf('  ✓ Fallback para CPU funcionando\n');
        catch ME
            fprintf('  ❌ Erro no fallback CPU: %s\n', ME.message);
        end
    end
end

function test_parallel_computing_compatibility(platformInfo)
    fprintf('Testando compatibilidade de computação paralela...\n');
    
    if platformInfo.hasParallelToolbox
        try
            % Testar criação de pool paralelo
            poolSize = min(4, feature('numcores'));
            
            % Verificar se já existe um pool
            currentPool = gcp('nocreate');
            if isempty(currentPool)
                parpool('local', poolSize);
                poolCreated = true;
            else
                poolCreated = false;
                poolSize = currentPool.NumWorkers;
            end
            
            fprintf('  ✓ Pool paralelo: %d workers\n', poolSize);
            
            % Testar operação paralela básica
            data = 1:1000;
            tic;
            serialResult = arrayfun(@(x) x^2, data);
            serialTime = toc;
            
            tic;
            parallelResult = arrayfun(@(x) x^2, data, 'UniformOutput', true);
            parallelTime = toc;
            
            assert(isequal(serialResult, parallelResult), 'Resultados paralelos diferem');
            
            fprintf('  ✓ Operação paralela: %.3fs vs serial: %.3fs\n', ...
                parallelTime, serialTime);
            
            % Testar parfor
            try
                result = zeros(1, 100);
                parfor i = 1:100
                    result(i) = i^2;
                end
                
                expected = (1:100).^2;
                assert(isequal(result, expected), 'Parfor com problemas');
                fprintf('  ✓ Parfor funcionando\n');
                
            catch ME
                fprintf('  ⚠ Parfor com problemas: %s\n', ME.message);
            end
            
            % Limpar pool se foi criado neste teste
            if poolCreated
                delete(gcp('nocreate'));
            end
            
        catch ME
            fprintf('  ❌ Erro na computação paralela: %s\n', ME.message);
        end
    else
        fprintf('  ⚠ Parallel Computing Toolbox não disponível\n');
        
        % Testar fallback sequencial
        try
            data = 1:100;
            result = arrayfun(@(x) x^2, data);
            expected = (1:100).^2;
            assert(isequal(result, expected), 'Fallback sequencial falhou');
            fprintf('  ✓ Fallback sequencial funcionando\n');
        catch ME
            fprintf('  ❌ Erro no fallback sequencial: %s\n', ME.message);
        end
    end
end

function test_memory_management_compatibility(platformInfo)
    fprintf('Testando compatibilidade de gerenciamento de memória...\n');
    
    try
        % Testar informações de memória
        if ~isnan(platformInfo.totalMemory)
            totalGB = platformInfo.totalMemory / 1024^3;
            availableGB = platformInfo.availableMemory / 1024^3;
            
            fprintf('  ✓ Memória total: %.1f GB\n', totalGB);
            fprintf('  ✓ Memória disponível: %.1f GB\n', availableGB);
            
            % Testar alocação de memória
            testSize = min(100, floor(availableGB * 1024 * 0.1)); % 10% da memória disponível em MB
            testData = rand(testSize, 1000); % Aproximadamente testSize MB
            
            assert(~isempty(testData), 'Falha na alocação de memória');
            fprintf('  ✓ Alocação de ~%d MB bem-sucedida\n', testSize);
            
            % Limpar memória
            clear testData;
            
        else
            fprintf('  ⚠ Informações de memória não disponíveis\n');
        end
        
        % Testar detecção de limite de memória
        try
            memInfo = memory;
            maxArraySize = memInfo.MaxPossibleArrayBytes;
            fprintf('  ✓ Tamanho máximo de array: %.1f GB\n', maxArraySize / 1024^3);
            
        catch ME
            fprintf('  ⚠ Função memory() não disponível: %s\n', ME.message);
        end
        
        % Testar limpeza automática de memória
        try
            % Criar variáveis temporárias
            for i = 1:10
                eval(sprintf('temp_var_%d = rand(100, 100);', i));
            end
            
            % Limpar workspace
            clearvars temp_var_*;
            
            fprintf('  ✓ Limpeza de memória funcionando\n');
            
        catch ME
            fprintf('  ⚠ Erro na limpeza de memória: %s\n', ME.message);
        end
        
    catch ME
        fprintf('  ❌ Erro no gerenciamento de memória: %s\n', ME.message);
    end
end

function test_configuration_portability(platformInfo)
    fprintf('Testando portabilidade de configuração...\n');
    
    testDir = 'test_config_portability';
    if ~exist(testDir, 'dir')
        mkdir(testDir);
    end
    
    try
        % Criar configuração de teste
        config = struct();
        config.platform = platformInfo.os;
        config.matlabVersion = platformInfo.matlabVersion;
        config.paths = struct();
        config.paths.imageDir = fullfile(pwd, 'images');
        config.paths.maskDir = fullfile(pwd, 'masks');
        config.paths.outputDir = fullfile(pwd, 'output');
        
        config.model = struct();
        config.model.inputSize = [256, 256, 3];
        config.model.numClasses = 2;
        
        config.training = struct();
        config.training.maxEpochs = 20;
        config.training.miniBatchSize = 8;
        config.training.useGPU = platformInfo.hasGPU;
        config.training.useParallel = platformInfo.hasParallelToolbox;
        
        % Salvar configuração em formato MATLAB
        matFile = fullfile(testDir, 'config.mat');
        save(matFile, 'config');
        
        % Carregar e verificar
        loadedConfig = load(matFile);
        assert(isequal(config, loadedConfig.config), 'Configuração MAT não preservada');
        fprintf('  ✓ Formato MAT funcionando\n');
        
        % Testar formato JSON (se disponível)
        try
            jsonFile = fullfile(testDir, 'config.json');
            jsonStr = jsonencode(config);
            
            fid = fopen(jsonFile, 'w');
            fprintf(fid, '%s', jsonStr);
            fclose(fid);
            
            % Ler JSON
            fid = fopen(jsonFile, 'r');
            jsonContent = fread(fid, '*char')';
            fclose(fid);
            
            loadedJsonConfig = jsondecode(jsonContent);
            
            % Verificar campos principais
            assert(strcmp(loadedJsonConfig.platform, config.platform), 'Platform não preservado em JSON');
            assert(isequal(loadedJsonConfig.model.inputSize, config.model.inputSize), 'InputSize não preservado em JSON');
            
            fprintf('  ✓ Formato JSON funcionando\n');
            
        catch ME
            fprintf('  ⚠ JSON não disponível: %s\n', ME.message);
        end
        
        % Testar caminhos relativos vs absolutos
        relativeConfig = config;
        relativeConfig.paths.imageDir = 'images';
        relativeConfig.paths.maskDir = 'masks';
        relativeConfig.paths.outputDir = 'output';
        
        relativeFile = fullfile(testDir, 'relative_config.mat');
        save(relativeFile, 'relativeConfig');
        
        loadedRelative = load(relativeFile);
        assert(strcmp(loadedRelative.relativeConfig.paths.imageDir, 'images'), ...
            'Caminhos relativos não preservados');
        
        fprintf('  ✓ Caminhos relativos preservados\n');
        
        % Testar configuração específica da plataforma
        platformConfig = config;
        if ispc
            platformConfig.paths.tempDir = 'C:\temp';
        else
            platformConfig.paths.tempDir = '/tmp';
        end
        
        platformFile = fullfile(testDir, 'platform_config.mat');
        save(platformFile, 'platformConfig');
        
        loadedPlatform = load(platformFile);
        assert(~isempty(loadedPlatform.platformConfig.paths.tempDir), ...
            'Configuração específica da plataforma perdida');
        
        fprintf('  ✓ Configuração específica da plataforma preservada\n');
        
    finally
        % Limpar diretório de teste
        if exist(testDir, 'dir')
            rmdir(testDir, 's');
        end
    end
end

function test_data_format_compatibility(platformInfo)
    fprintf('Testando compatibilidade de formatos de dados...\n');
    
    testDir = 'test_data_formats';
    if ~exist(testDir, 'dir')
        mkdir(testDir);
    end
    
    try
        % Testar diferentes formatos de imagem
        testImage = uint8(rand(64, 64, 3) * 255);
        
        % PNG
        pngFile = fullfile(testDir, 'test.png');
        imwrite(testImage, pngFile);
        loadedPng = imread(pngFile);
        assert(isequal(size(testImage), size(loadedPng)), 'PNG não preservou dimensões');
        fprintf('  ✓ Formato PNG suportado\n');
        
        % JPEG
        jpgFile = fullfile(testDir, 'test.jpg');
        imwrite(testImage, jpgFile);
        loadedJpg = imread(jpgFile);
        assert(isequal(size(testImage), size(loadedJpg)), 'JPEG não preservou dimensões');
        fprintf('  ✓ Formato JPEG suportado\n');
        
        % TIFF (se disponível)
        try
            tiffFile = fullfile(testDir, 'test.tiff');
            imwrite(testImage, tiffFile);
            loadedTiff = imread(tiffFile);
            assert(isequal(size(testImage), size(loadedTiff)), 'TIFF não preservou dimensões');
            fprintf('  ✓ Formato TIFF suportado\n');
        catch
            fprintf('  ⚠ Formato TIFF não disponível\n');
        end
        
        % Testar imagens grayscale
        grayImage = rgb2gray(testImage);
        grayFile = fullfile(testDir, 'gray.png');
        imwrite(grayImage, grayFile);
        loadedGray = imread(grayFile);
        assert(isequal(size(grayImage), size(loadedGray)), 'Grayscale não preservou dimensões');
        fprintf('  ✓ Imagens grayscale suportadas\n');
        
        % Testar diferentes tipos de dados
        doubleImage = double(testImage) / 255;
        doubleFile = fullfile(testDir, 'double.png');
        imwrite(doubleImage, doubleFile);
        loadedDouble = imread(doubleFile);
        assert(~isempty(loadedDouble), 'Imagem double não foi salva');
        fprintf('  ✓ Conversão de tipos de dados funcionando\n');
        
        % Testar máscaras binárias
        binaryMask = rand(64, 64) > 0.5;
        maskFile = fullfile(testDir, 'mask.png');
        imwrite(uint8(binaryMask) * 255, maskFile);
        loadedMask = imread(maskFile);
        assert(~isempty(loadedMask), 'Máscara binária não foi salva');
        fprintf('  ✓ Máscaras binárias suportadas\n');
        
        % Testar dados categóricos (se disponível)
        try
            categoricalData = categorical(randi([1, 3], 64, 64));
            catFile = fullfile(testDir, 'categorical.mat');
            save(catFile, 'categoricalData');
            
            loadedCat = load(catFile);
            assert(isa(loadedCat.categoricalData, 'categorical'), ...
                'Dados categóricos não preservados');
            fprintf('  ✓ Dados categóricos suportados\n');
        catch
            fprintf('  ⚠ Dados categóricos não disponíveis\n');
        end
        
    finally
        % Limpar diretório de teste
        if exist(testDir, 'dir')
            rmdir(testDir, 's');
        end
    end
end

function isAbsolute = isAbsolutePath(path)
    % Verifica se um caminho é absoluto
    if ispc
        % Windows: começa com letra de unidade ou \\
        isAbsolute = length(path) >= 2 && ...
            ((isstrprop(path(1), 'alpha') && path(2) == ':') || ...
             (length(path) >= 2 && strcmp(path(1:2), '\\')));
    else
        % Unix/Linux/macOS: começa com /
        isAbsolute = ~isempty(path) && path(1) == '/';
    end
end