function success = install_system()
    % ========================================================================
    % INSTALL_SYSTEM - INSTALAÇÃO AUTOMÁTICA DO SISTEMA
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Script de instalação automática que verifica requisitos, configura
    %   o ambiente e prepara o sistema para uso.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - System Administration
    %   - Path Management
    %   - Installation Procedures
    %
    % USO:
    %   >> success = install_system();
    %
    % REQUISITOS: 2.1, 2.2
    % ========================================================================
    
    success = false;
    
    try
        fprintf('\n');
        fprintf('========================================================================\n');
        fprintf('                    INSTALAÇÃO DO SISTEMA                              \n');
        fprintf('                   U-Net vs Attention U-Net v2.0                      \n');
        fprintf('========================================================================\n');
        fprintf('\n');
        
        % Verificar se já está instalado
        if exist('VERSION.mat', 'file')
            versionData = load('VERSION.mat');
            if isfield(versionData, 'versionInfo')
                fprintf('⚠️  Sistema já instalado (versão %s)\n', versionData.versionInfo.version);
                
                choice = input('Deseja reinstalar? (s/n) [n]: ', 's');
                if isempty(choice) || lower(choice) ~= 's'
                    fprintf('Instalação cancelada.\n');
                    return;
                end
                
                fprintf('\n🔄 Reinstalando sistema...\n\n');
            end
        end
        
        % Etapa 1: Verificar requisitos do sistema
        fprintf('🔍 Verificando requisitos do sistema...\n');
        if ~checkSystemRequirements()
            fprintf('❌ Requisitos do sistema não atendidos.\n');
            return;
        end
        fprintf('✅ Requisitos do sistema verificados\n\n');
        
        % Etapa 2: Verificar toolboxes
        fprintf('📦 Verificando toolboxes do MATLAB...\n');
        if ~checkMatlabToolboxes()
            fprintf('❌ Toolboxes necessárias não encontradas.\n');
            return;
        end
        fprintf('✅ Toolboxes verificadas\n\n');
        
        % Etapa 3: Criar estrutura de diretórios
        fprintf('📁 Criando estrutura de diretórios...\n');
        if ~createDirectoryStructure()
            fprintf('❌ Erro ao criar estrutura de diretórios.\n');
            return;
        end
        fprintf('✅ Estrutura de diretórios criada\n\n');
        
        % Etapa 4: Configurar caminhos do MATLAB
        fprintf('🛤️  Configurando caminhos do MATLAB...\n');
        if ~setupMatlabPaths()
            fprintf('❌ Erro ao configurar caminhos.\n');
            return;
        end
        fprintf('✅ Caminhos configurados\n\n');
        
        % Etapa 5: Inicializar sistema de versão
        fprintf('🏷️  Inicializando sistema de versão...\n');
        if ~initializeVersionSystem()
            fprintf('❌ Erro ao inicializar sistema de versão.\n');
            return;
        end
        fprintf('✅ Sistema de versão inicializado\n\n');
        
        % Etapa 6: Executar testes básicos
        fprintf('🧪 Executando testes básicos...\n');
        if ~runBasicTests()
            fprintf('❌ Testes básicos falharam.\n');
            return;
        end
        fprintf('✅ Testes básicos aprovados\n\n');
        
        % Etapa 7: Criar configuração inicial
        fprintf('⚙️  Criando configuração inicial...\n');
        if ~createInitialConfiguration()
            fprintf('❌ Erro ao criar configuração inicial.\n');
            return;
        end
        fprintf('✅ Configuração inicial criada\n\n');
        
        % Etapa 8: Finalizar instalação
        fprintf('🎯 Finalizando instalação...\n');
        finalizeInstallation();
        
        fprintf('✅ INSTALAÇÃO CONCLUÍDA COM SUCESSO!\n\n');
        
        % Mostrar instruções pós-instalação
        showPostInstallationInstructions();
        
        success = true;
        
    catch ME
        fprintf('\n❌ ERRO CRÍTICO NA INSTALAÇÃO: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        % Tentar limpeza em caso de erro
        try
            fprintf('\n🧹 Executando limpeza...\n');
            cleanupFailedInstallation();
        catch
            fprintf('⚠️  Não foi possível executar limpeza automática.\n');
        end
    end
    
    fprintf('\n========================================================================\n');
    if success
        fprintf('                        INSTALAÇÃO CONCLUÍDA                           \n');
    else
        fprintf('                         INSTALAÇÃO FALHOU                             \n');
    end
    fprintf('========================================================================\n\n');
end

function success = checkSystemRequirements()
    % Verifica requisitos básicos do sistema
    
    success = false;
    
    try
        % Verificar versão do MATLAB
        matlabVersion = version('-release');
        matlabYear = str2double(matlabVersion(1:4));
        
        if matlabYear < 2020
            fprintf('❌ MATLAB R2020a ou superior necessário (atual: %s)\n', matlabVersion);
            return;
        end
        
        fprintf('✓ MATLAB %s (compatível)\n', matlabVersion);
        
        % Verificar memória disponível
        if ispc
            try
                [~, memInfo] = memory;
                availableMemoryGB = memInfo.PhysicalMemory.Available / (1024^3);
                fprintf('✓ Memória disponível: %.1f GB\n', availableMemoryGB);
                
                if availableMemoryGB < 2
                    fprintf('⚠️  Pouca memória disponível (< 2GB). Performance pode ser limitada.\n');
                end
            catch
                fprintf('⚠️  Não foi possível verificar memória disponível\n');
            end
        else
            fprintf('✓ Sistema não-Windows detectado\n');
        end
        
        % Verificar espaço em disco
        try
            dirInfo = dir('.');
            fprintf('✓ Diretório de instalação acessível\n');
        catch
            fprintf('❌ Erro ao acessar diretório de instalação\n');
            return;
        end
        
        % Verificar permissões de escrita
        testFile = 'install_test.tmp';
        try
            fid = fopen(testFile, 'w');
            if fid ~= -1
                fclose(fid);
                delete(testFile);
                fprintf('✓ Permissões de escrita verificadas\n');
            else
                fprintf('❌ Sem permissão de escrita no diretório atual\n');
                return;
            end
        catch
            fprintf('❌ Erro ao testar permissões de escrita\n');
            return;
        end
        
        success = true;
        
    catch ME
        fprintf('❌ Erro na verificação de requisitos: %s\n', ME.message);
    end
end

function success = checkMatlabToolboxes()
    % Verifica toolboxes necessárias
    
    success = false;
    
    try
        % Toolboxes obrigatórias
        requiredToolboxes = {
            'Deep_Learning_Toolbox', 'Deep Learning Toolbox';
            'Image_Toolbox', 'Image Processing Toolbox'
        };
        
        % Toolboxes recomendadas
        recommendedToolboxes = {
            'Statistics_Toolbox', 'Statistics and Machine Learning Toolbox';
            'Distrib_Computing_Toolbox', 'Parallel Computing Toolbox'
        };
        
        allRequired = true;
        
        % Verificar toolboxes obrigatórias
        fprintf('Toolboxes obrigatórias:\n');
        for i = 1:size(requiredToolboxes, 1)
            toolboxId = requiredToolboxes{i, 1};
            toolboxName = requiredToolboxes{i, 2};
            
            if license('test', toolboxId)
                fprintf('  ✓ %s\n', toolboxName);
            else
                fprintf('  ❌ %s (OBRIGATÓRIA)\n', toolboxName);
                allRequired = false;
            end
        end
        
        if ~allRequired
            fprintf('\n❌ Toolboxes obrigatórias ausentes.\n');
            fprintf('   Instale via: Home → Add-Ons → Get Add-Ons\n');
            return;
        end
        
        % Verificar toolboxes recomendadas
        fprintf('\nToolboxes recomendadas:\n');
        for i = 1:size(recommendedToolboxes, 1)
            toolboxId = recommendedToolboxes{i, 1};
            toolboxName = recommendedToolboxes{i, 2};
            
            if license('test', toolboxId)
                fprintf('  ✓ %s\n', toolboxName);
            else
                fprintf('  ⚠️  %s (recomendada para melhor performance)\n', toolboxName);
            end
        end
        
        success = true;
        
    catch ME
        fprintf('❌ Erro na verificação de toolboxes: %s\n', ME.message);
    end
end

function success = createDirectoryStructure()
    % Cria estrutura de diretórios necessária
    
    success = false;
    
    try
        % Diretórios principais
        mainDirs = {
            'src',
            'src/core',
            'src/data',
            'src/models',
            'src/evaluation',
            'src/visualization',
            'src/utils',
            'tests',
            'tests/unit',
            'tests/integration',
            'tests/performance',
            'docs',
            'docs/examples',
            'config',
            'output',
            'output/models',
            'output/reports',
            'output/visualizations',
            'output/logs',
            'version_backups'
        };
        
        for i = 1:length(mainDirs)
            dirPath = mainDirs{i};
            
            if ~exist(dirPath, 'dir')
                mkdir(dirPath);
                fprintf('  📁 Criado: %s\n', dirPath);
            else
                fprintf('  ✓ Existe: %s\n', dirPath);
            end
        end
        
        % Criar arquivos README em diretórios principais
        createReadmeFiles();
        
        success = true;
        
    catch ME
        fprintf('❌ Erro ao criar diretórios: %s\n', ME.message);
    end
end

function createReadmeFiles()
    % Cria arquivos README em diretórios principais
    
    readmeContents = containers.Map();
    
    readmeContents('src') = {
        '# Código Fonte';
        '';
        'Este diretório contém todo o código fonte do sistema.';
        '';
        '## Estrutura:';
        '- `core/` - Componentes principais do sistema';
        '- `data/` - Carregamento e preprocessamento de dados';
        '- `models/` - Arquiteturas de modelos e treinamento';
        '- `evaluation/` - Métricas e avaliação';
        '- `visualization/` - Visualização e relatórios';
        '- `utils/` - Utilitários e ferramentas auxiliares';
    };
    
    readmeContents('tests') = {
        '# Testes Automatizados';
        '';
        'Este diretório contém todos os testes do sistema.';
        '';
        '## Estrutura:';
        '- `unit/` - Testes unitários de componentes individuais';
        '- `integration/` - Testes de integração entre componentes';
        '- `performance/` - Testes de performance e benchmarking';
    };
    
    readmeContents('docs') = {
        '# Documentação';
        '';
        'Este diretório contém a documentação do sistema.';
        '';
        '## Arquivos:';
        '- `user_guide.md` - Guia detalhado do usuário';
        '- `api_reference.md` - Referência da API';
        '- `examples/` - Exemplos práticos de uso';
    };
    
    readmeContents('output') = {
        '# Resultados e Saídas';
        '';
        'Este diretório contém todos os resultados gerados pelo sistema.';
        '';
        '## Estrutura:';
        '- `models/` - Modelos treinados salvos';
        '- `reports/` - Relatórios de comparação';
        '- `visualizations/` - Gráficos e visualizações';
        '- `logs/` - Arquivos de log do sistema';
    };
    
    % Criar arquivos README
    dirs = keys(readmeContents);
    for i = 1:length(dirs)
        dirName = dirs{i};
        content = readmeContents(dirName);
        
        readmeFile = fullfile(dirName, 'README.md');
        
        try
            fid = fopen(readmeFile, 'w');
            if fid ~= -1
                for j = 1:length(content)
                    fprintf(fid, '%s\n', content{j});
                end
                fclose(fid);
            end
        catch
            % Ignorar erros na criação de README
        end
    end
end

function success = setupMatlabPaths()
    % Configura caminhos do MATLAB
    
    success = false;
    
    try
        % Adicionar caminhos principais
        pathsToAdd = {
            'src/core',
            'src/data',
            'src/models',
            'src/evaluation',
            'src/visualization',
            'src/utils',
            'tests',
            'tests/unit',
            'tests/integration',
            'tests/performance'
        };
        
        for i = 1:length(pathsToAdd)
            pathToAdd = pathsToAdd{i};
            
            if exist(pathToAdd, 'dir')
                addpath(pathToAdd);
                fprintf('  ✓ Adicionado ao path: %s\n', pathToAdd);
            end
        end
        
        % Salvar caminhos (opcional)
        try
            savepath;
            fprintf('  ✓ Caminhos salvos permanentemente\n');
        catch
            fprintf('  ⚠️  Não foi possível salvar caminhos permanentemente\n');
            fprintf('     Execute setup_paths() no início de cada sessão\n');
        end
        
        success = true;
        
    catch ME
        fprintf('❌ Erro ao configurar caminhos: %s\n', ME.message);
    end
end

function success = initializeVersionSystem()
    % Inicializa sistema de versão
    
    success = false;
    
    try
        % Verificar se VersionManager existe
        if exist('src/utils/VersionManager.m', 'file')
            % Criar instância do VersionManager
            versionMgr = VersionManager();
            
            % Obter informações da versão
            versionInfo = versionMgr.getCurrentVersion();
            
            fprintf('  ✓ Sistema de versão inicializado (v%s)\n', versionInfo.version);
            success = true;
        else
            fprintf('  ⚠️  VersionManager não encontrado, criando versão básica\n');
            
            % Criar informação básica de versão
            versionInfo = struct();
            versionInfo.version = '2.0.0';
            versionInfo.releaseDate = datestr(now, 'yyyy-mm-dd');
            versionInfo.releaseType = 'major';
            versionInfo.buildNumber = sprintf('%s.%d', datestr(now, 'yyyymmdd'), round(now * 86400));
            
            save('VERSION.mat', 'versionInfo');
            fprintf('  ✓ Versão básica criada\n');
            success = true;
        end
        
    catch ME
        fprintf('❌ Erro ao inicializar sistema de versão: %s\n', ME.message);
    end
end

function success = runBasicTests()
    % Executa testes básicos de funcionamento
    
    success = false;
    
    try
        fprintf('  🧪 Testando carregamento de classes principais...\n');
        
        % Testar ConfigManager
        try
            if exist('src/core/ConfigManager.m', 'file')
                configMgr = ConfigManager();
                fprintf('    ✓ ConfigManager\n');
            else
                fprintf('    ⚠️  ConfigManager não encontrado\n');
            end
        catch
            fprintf('    ❌ ConfigManager falhou\n');
        end
        
        % Testar MainInterface
        try
            if exist('src/core/MainInterface.m', 'file')
                mainInterface = MainInterface();
                fprintf('    ✓ MainInterface\n');
            else
                fprintf('    ⚠️  MainInterface não encontrado\n');
            end
        catch
            fprintf('    ❌ MainInterface falhou\n');
        end
        
        % Testar DataLoader
        try
            if exist('src/data/DataLoader.m', 'file')
                dataLoader = DataLoader();
                fprintf('    ✓ DataLoader\n');
            else
                fprintf('    ⚠️  DataLoader não encontrado\n');
            end
        catch
            fprintf('    ❌ DataLoader falhou\n');
        end
        
        fprintf('  ✓ Testes básicos concluídos\n');
        success = true;
        
    catch ME
        fprintf('❌ Erro nos testes básicos: %s\n', ME.message);
    end
end

function success = createInitialConfiguration()
    % Cria configuração inicial do sistema
    
    success = false;
    
    try
        % Verificar se já existe configuração
        if exist('config_caminhos.mat', 'file')
            fprintf('  ✓ Configuração existente encontrada\n');
            success = true;
            return;
        end
        
        % Criar configuração padrão
        config = struct();
        
        % Tentar detectar dados de exemplo
        if exist('img/original', 'dir') && exist('img/masks', 'dir')
            config.imageDir = fullfile(pwd, 'img', 'original');
            config.maskDir = fullfile(pwd, 'img', 'masks');
            fprintf('  ✓ Dados de exemplo detectados\n');
        else
            config.imageDir = '';
            config.maskDir = '';
            fprintf('  ⚠️  Dados de exemplo não encontrados\n');
        end
        
        % Configurações padrão
        config.inputSize = [256, 256, 3];
        config.numClasses = 2;
        config.validationSplit = 0.2;
        config.miniBatchSize = 8;
        config.maxEpochs = 20;
        
        % Configurações de teste rápido
        config.quickTest = struct();
        config.quickTest.numSamples = 50;
        config.quickTest.maxEpochs = 5;
        
        % Configurações de saída
        config.outputDir = fullfile(pwd, 'output');
        
        % Informações do ambiente
        config.environment = struct();
        config.environment.username = getenv('USERNAME');
        config.environment.computername = getenv('COMPUTERNAME');
        config.environment.matlabVersion = version;
        config.environment.installDate = datestr(now);
        
        % Salvar configuração
        save('config_caminhos.mat', 'config');
        fprintf('  ✓ Configuração inicial criada\n');
        
        success = true;
        
    catch ME
        fprintf('❌ Erro ao criar configuração: %s\n', ME.message);
    end
end

function finalizeInstallation()
    % Finaliza processo de instalação
    
    try
        % Criar arquivo de status da instalação
        installStatus = struct();
        installStatus.completed = true;
        installStatus.version = '2.0.0';
        installStatus.installDate = datestr(now);
        installStatus.installer = getenv('USERNAME');
        installStatus.computer = getenv('COMPUTERNAME');
        
        save('INSTALL_STATUS.mat', 'installStatus');
        
        % Criar script de configuração de caminhos
        createSetupPathsScript();
        
        fprintf('  ✓ Instalação finalizada\n');
        
    catch ME
        fprintf('⚠️  Erro ao finalizar instalação: %s\n', ME.message);
    end
end

function createSetupPathsScript()
    % Cria script para configurar caminhos
    
    try
        fid = fopen('setup_paths.m', 'w');
        if fid == -1
            return;
        end
        
        fprintf(fid, 'function setup_paths()\n');
        fprintf(fid, '%% SETUP_PATHS - Configura caminhos do sistema\n');
        fprintf(fid, '%% Execute este script no início de cada sessão se os caminhos não foram salvos permanentemente\n\n');
        
        fprintf(fid, 'try\n');
        fprintf(fid, '    %% Adicionar caminhos principais\n');
        fprintf(fid, '    addpath(''src/core'');\n');
        fprintf(fid, '    addpath(''src/data'');\n');
        fprintf(fid, '    addpath(''src/models'');\n');
        fprintf(fid, '    addpath(''src/evaluation'');\n');
        fprintf(fid, '    addpath(''src/visualization'');\n');
        fprintf(fid, '    addpath(''src/utils'');\n');
        fprintf(fid, '    addpath(''tests'');\n');
        fprintf(fid, '    addpath(''tests/unit'');\n');
        fprintf(fid, '    addpath(''tests/integration'');\n');
        fprintf(fid, '    addpath(''tests/performance'');\n\n');
        
        fprintf(fid, '    fprintf(''✅ Caminhos configurados com sucesso\\n'');\n');
        fprintf(fid, 'catch ME\n');
        fprintf(fid, '    fprintf(''❌ Erro ao configurar caminhos: %%s\\n'', ME.message);\n');
        fprintf(fid, 'end\n');
        fprintf(fid, 'end\n');
        
        fclose(fid);
        
    catch
        % Ignorar erros na criação do script
    end
end

function cleanupFailedInstallation()
    % Limpa arquivos de instalação falhada
    
    try
        % Remover arquivos temporários
        tempFiles = {
            'install_test.tmp',
            'INSTALL_STATUS.mat',
            'VERSION.mat'
        };
        
        for i = 1:length(tempFiles)
            if exist(tempFiles{i}, 'file')
                delete(tempFiles{i});
            end
        end
        
        fprintf('✓ Limpeza concluída\n');
        
    catch
        % Ignorar erros de limpeza
    end
end

function showPostInstallationInstructions()
    % Mostra instruções pós-instalação
    
    fprintf('📋 INSTRUÇÕES PÓS-INSTALAÇÃO:\n\n');
    
    fprintf('1. 🎯 COMO USAR O SISTEMA:\n');
    fprintf('   >> mainInterface = MainInterface()\n');
    fprintf('   >> mainInterface.run()\n\n');
    
    fprintf('2. ⚙️  CONFIGURAR SEUS DADOS:\n');
    fprintf('   >> configurar_caminhos()\n');
    fprintf('   (Aponte para suas pastas de imagens e máscaras)\n\n');
    
    fprintf('3. 🧪 EXECUTAR TESTES COMPLETOS:\n');
    fprintf('   >> executar_testes_completos()\n\n');
    
    fprintf('4. 📚 DOCUMENTAÇÃO:\n');
    fprintf('   - README.md - Visão geral e início rápido\n');
    fprintf('   - INSTALLATION.md - Guia de instalação detalhado\n');
    fprintf('   - docs/user_guide.md - Guia do usuário\n\n');
    
    fprintf('5. 🔧 SE ALGO DER ERRADO:\n');
    fprintf('   - Execute: setup_paths() (se caminhos não foram salvos)\n');
    fprintf('   - Consulte logs em output/logs/\n');
    fprintf('   - Execute testes para diagnóstico\n\n');
    
    fprintf('6. 📁 ESTRUTURA DE ARQUIVOS:\n');
    fprintf('   - src/ - Código fonte\n');
    fprintf('   - tests/ - Testes automatizados\n');
    fprintf('   - docs/ - Documentação\n');
    fprintf('   - output/ - Resultados gerados\n\n');
    
    fprintf('✨ Sistema pronto para uso! Comece com mainInterface.run()\n\n');
end