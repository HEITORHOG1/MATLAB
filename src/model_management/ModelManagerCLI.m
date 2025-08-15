classdef ModelManagerCLI < handle
    % ========================================================================
    % MODELMANAGERCLI - Interface de Linha de Comando para Gerenciamento de Modelos
    % ========================================================================
    % 
    % AUTOR: Sistema de Melhorias de Segmentação
    % Data: Agosto 2025
    % Versão: 1.0
    %
    % DESCRIÇÃO:
    %   Interface de linha de comando para listar, carregar e gerenciar
    %   modelos salvos do sistema de segmentação
    % ========================================================================
    
    properties (Access = private)
        modelLoader
        modelSaver
        versioningSystem
        baseDirectory
    end
    
    methods
        function obj = ModelManagerCLI(config)
            % Construtor da CLI
            %
            % Parâmetros:
            %   config - configuração do sistema (opcional)
            
            if nargin < 1
                config = struct();
            end
            
            % Inicializar componentes
            obj.modelLoader = [];  % Será inicializado quando necessário (classe estática)
            obj.modelSaver = ModelSaver(config);
            obj.versioningSystem = ModelVersioning(config);
            
            % Configurar diretório base
            obj.baseDirectory = obj.getConfigValue(config, 'saveDirectory', 'saved_models');
            
            fprintf('✓ Interface CLI do gerenciador de modelos inicializada\n');
        end
        
        function runInteractiveMode(obj)
            % Executar modo interativo da CLI
            
            fprintf('\n=== GERENCIADOR DE MODELOS - MODO INTERATIVO ===\n');
            
            while true
                obj.displayMainMenu();
                
                choice = input('Escolha uma opção: ', 's');
                
                switch lower(choice)
                    case '1'
                        obj.listModelsCommand();
                    case '2'
                        obj.loadModelCommand();
                    case '3'
                        obj.listVersionsCommand();
                    case '4'
                        obj.restoreVersionCommand();
                    case '5'
                        obj.deleteModelCommand();
                    case '6'
                        obj.generateReportCommand();
                    case '7'
                        obj.cleanupCommand();
                    case '8'
                        obj.searchModelsCommand();
                    case '9'
                        obj.compareModelsCommand();
                    case '0'
                        fprintf('Saindo do gerenciador de modelos...\n');
                        break;
                    case 'h'
                        obj.displayHelp();
                    otherwise
                        fprintf('⚠ Opção inválida. Digite "h" para ajuda.\n');
                end
                
                fprintf('\n');
            end
        end
        
        function executeCommand(obj, command, varargin)
            % Executar comando específico
            %
            % Parâmetros:
            %   command - comando a executar
            %   varargin - argumentos do comando
            
            try
                switch lower(command)
                    case 'list'
                        obj.listModelsCommand(varargin{:});
                    case 'load'
                        obj.loadModelCommand(varargin{:});
                    case 'versions'
                        obj.listVersionsCommand(varargin{:});
                    case 'restore'
                        obj.restoreVersionCommand(varargin{:});
                    case 'delete'
                        obj.deleteModelCommand(varargin{:});
                    case 'report'
                        obj.generateReportCommand(varargin{:});
                    case 'cleanup'
                        obj.cleanupCommand(varargin{:});
                    case 'search'
                        obj.searchModelsCommand(varargin{:});
                    case 'compare'
                        obj.compareModelsCommand(varargin{:});
                    case 'help'
                        obj.displayHelp();
                    otherwise
                        fprintf('❌ Comando desconhecido: %s\n', command);
                        obj.displayHelp();
                end
                
            catch ME
                fprintf('❌ Erro ao executar comando: %s\n', ME.message);
            end
        end
        
        function listModelsCommand(obj, varargin)
            % Comando para listar modelos
            
            fprintf('\n=== MODELOS DISPONÍVEIS ===\n');
            
            % Determinar diretório
            if nargin > 1 && ~isempty(varargin{1})
                directory = varargin{1};
            else
                directory = obj.baseDirectory;
            end
            
            % Listar modelos
            models = ModelLoader.listAvailableModels(directory);
            
            if ~isempty(models)
                % Exibir estatísticas
                fprintf('\n--- Estatísticas ---\n');
                fprintf('Total de modelos: %d\n', length(models));
                
                % Contar por tipo
                types = {models.type};
                uniqueTypes = unique(types);
                for i = 1:length(uniqueTypes)
                    count = sum(strcmp(types, uniqueTypes{i}));
                    fprintf('%s: %d modelos\n', uniqueTypes{i}, count);
                end
                
                % Calcular espaço total
                totalSize = sum([models.size]);
                fprintf('Espaço total: %s\n', obj.formatFileSize(totalSize));
            end
        end
        
        function loadModelCommand(obj, varargin)
            % Comando para carregar modelo
            
            if nargin > 1 && ~isempty(varargin{1})
                % Carregar modelo específico
                modelPath = varargin{1};
                
                try
                    [model, metadata] = ModelLoader.loadModel(modelPath);
                    
                    if ~isempty(model)
                        % Salvar no workspace
                        assignin('base', 'loadedModel', model);
                        assignin('base', 'loadedMetadata', metadata);
                        
                        fprintf('✓ Modelo carregado no workspace como "loadedModel"\n');
                        fprintf('✓ Metadados disponíveis como "loadedMetadata"\n');
                    end
                    
                catch ME
                    fprintf('❌ Erro ao carregar modelo: %s\n', ME.message);
                end
            else
                % Modo interativo para seleção
                obj.interactiveModelSelection();
            end
        end
        
        function listVersionsCommand(obj, varargin)
            % Comando para listar versões
            
            if nargin > 1 && ~isempty(varargin{1})
                modelType = varargin{1};
            else
                modelType = input('Digite o tipo do modelo (ou Enter para todos): ', 's');
                if isempty(modelType)
                    modelType = [];
                end
            end
            
            fprintf('\n=== VERSÕES DE MODELOS ===\n');
            versions = obj.versioningSystem.listVersions(modelType);
            
            if ~isempty(versions)
                fprintf('\nUse "restore <tipo> <versão>" para restaurar uma versão específica\n');
            end
        end
        
        function restoreVersionCommand(obj, varargin)
            % Comando para restaurar versão
            
            if nargin > 2
                modelType = varargin{1};
                versionNumber = str2double(varargin{2});
            else
                modelType = input('Digite o tipo do modelo: ', 's');
                versionNumber = input('Digite o número da versão: ');
            end
            
            if ~isempty(modelType) && ~isnan(versionNumber)
                try
                    [model, metadata] = obj.versioningSystem.restoreVersion(modelType, versionNumber);
                    
                    if ~isempty(model)
                        % Salvar no workspace
                        assignin('base', 'restoredModel', model);
                        assignin('base', 'restoredMetadata', metadata);
                        
                        fprintf('✓ Versão restaurada no workspace como "restoredModel"\n');
                    end
                    
                catch ME
                    fprintf('❌ Erro ao restaurar versão: %s\n', ME.message);
                end
            else
                fprintf('❌ Parâmetros inválidos\n');
            end
        end
        
        function deleteModelCommand(obj, varargin)
            % Comando para deletar modelo
            
            if nargin > 1 && ~isempty(varargin{1})
                modelPath = varargin{1};
            else
                modelPath = input('Digite o caminho do modelo para deletar: ', 's');
            end
            
            if ~isempty(modelPath) && exist(modelPath, 'file')
                % Confirmar deleção
                response = input(sprintf('Tem certeza que deseja deletar "%s"? (y/N): ', modelPath), 's');
                
                if strcmpi(response, 'y')
                    try
                        delete(modelPath);
                        
                        % Deletar metadados associados
                        metadataPath = strrep(modelPath, '.mat', '_metadata.json');
                        if exist(metadataPath, 'file')
                            delete(metadataPath);
                        end
                        
                        fprintf('✓ Modelo deletado: %s\n', modelPath);
                        
                    catch ME
                        fprintf('❌ Erro ao deletar modelo: %s\n', ME.message);
                    end
                else
                    fprintf('Operação cancelada\n');
                end
            else
                fprintf('❌ Arquivo não encontrado: %s\n', modelPath);
            end
        end
        
        function generateReportCommand(obj, varargin)
            % Comando para gerar relatório
            
            fprintf('\n=== RELATÓRIO DO SISTEMA ===\n');
            
            % Relatório de modelos
            fprintf('\n--- MODELOS SALVOS ---\n');
            models = ModelLoader.listAvailableModels(obj.baseDirectory);
            
            if ~isempty(models)
                totalSize = sum([models.size]);
                fprintf('Total de modelos: %d\n', length(models));
                fprintf('Espaço usado: %s\n', obj.formatFileSize(totalSize));
                
                % Análise por tipo
                types = {models.type};
                uniqueTypes = unique(types);
                for i = 1:length(uniqueTypes)
                    typeModels = models(strcmp(types, uniqueTypes{i}));
                    typeSize = sum([typeModels.size]);
                    fprintf('  %s: %d modelos (%s)\n', uniqueTypes{i}, length(typeModels), obj.formatFileSize(typeSize));
                end
            end
            
            % Relatório de versionamento
            fprintf('\n--- SISTEMA DE VERSIONAMENTO ---\n');
            obj.versioningSystem.generateVersionReport();
            
            % Sugestões de otimização
            fprintf('\n--- SUGESTÕES DE OTIMIZAÇÃO ---\n');
            obj.generateOptimizationSuggestions(models);
        end
        
        function cleanupCommand(obj, varargin)
            % Comando para limpeza
            
            fprintf('\n=== LIMPEZA DO SISTEMA ===\n');
            
            % Opções de limpeza
            fprintf('Opções de limpeza disponíveis:\n');
            fprintf('1. Limpeza automática de versões antigas\n');
            fprintf('2. Compressão de modelos antigos\n');
            fprintf('3. Remoção de arquivos temporários\n');
            fprintf('4. Limpeza completa (cuidado!)\n');
            
            choice = input('Escolha uma opção (1-4): ', 's');
            
            switch choice
                case '1'
                    obj.cleanupOldVersions();
                case '2'
                    obj.compressOldModels();
                case '3'
                    obj.cleanupTempFiles();
                case '4'
                    obj.fullCleanup();
                otherwise
                    fprintf('❌ Opção inválida\n');
            end
        end
        
        function searchModelsCommand(obj, varargin)
            % Comando para buscar modelos
            
            if nargin > 1 && ~isempty(varargin{1})
                searchTerm = varargin{1};
            else
                searchTerm = input('Digite o termo de busca: ', 's');
            end
            
            if ~isempty(searchTerm)
                fprintf('\n=== RESULTADOS DA BUSCA: "%s" ===\n', searchTerm);
                
                models = ModelLoader.listAvailableModels(obj.baseDirectory);
                
                if ~isempty(models)
                    % Buscar em nomes de arquivo
                    matches = [];
                    for i = 1:length(models)
                        if contains(lower(models(i).filename), lower(searchTerm)) || ...
                           contains(lower(models(i).type), lower(searchTerm))
                            matches = [matches, models(i)];
                        end
                    end
                    
                    if ~isempty(matches)
                        fprintf('Encontrados %d modelos:\n\n', length(matches));
                        
                        for i = 1:length(matches)
                            model = matches(i);
                            fprintf('%d. %s\n', i, model.filename);
                            fprintf('   Tipo: %s\n', model.type);
                            fprintf('   Data: %s\n', datestr(model.date));
                            fprintf('   Tamanho: %s\n', obj.formatFileSize(model.size));
                            fprintf('   Caminho: %s\n\n', model.filepath);
                        end
                    else
                        fprintf('Nenhum modelo encontrado com o termo "%s"\n', searchTerm);
                    end
                end
            end
        end
        
        function compareModelsCommand(obj, varargin)
            % Comando para comparar modelos
            
            fprintf('\n=== COMPARAÇÃO DE MODELOS ===\n');
            
            models = ModelLoader.listAvailableModels(obj.baseDirectory);
            
            if length(models) < 2
                fprintf('❌ Pelo menos 2 modelos são necessários para comparação\n');
                return;
            end
            
            % Selecionar modelos para comparação
            fprintf('Modelos disponíveis:\n');
            for i = 1:length(models)
                fprintf('%d. %s (%s)\n', i, models(i).filename, models(i).type);
            end
            
            idx1 = input('Selecione o primeiro modelo (número): ');
            idx2 = input('Selecione o segundo modelo (número): ');
            
            if idx1 >= 1 && idx1 <= length(models) && idx2 >= 1 && idx2 <= length(models) && idx1 ~= idx2
                obj.performModelComparison(models(idx1), models(idx2));
            else
                fprintf('❌ Seleção inválida\n');
            end
        end
    end
    
    methods (Access = private)
        function displayMainMenu(obj)
            % Exibir menu principal
            
            fprintf('\n--- MENU PRINCIPAL ---\n');
            fprintf('1. Listar modelos\n');
            fprintf('2. Carregar modelo\n');
            fprintf('3. Listar versões\n');
            fprintf('4. Restaurar versão\n');
            fprintf('5. Deletar modelo\n');
            fprintf('6. Gerar relatório\n');
            fprintf('7. Limpeza do sistema\n');
            fprintf('8. Buscar modelos\n');
            fprintf('9. Comparar modelos\n');
            fprintf('0. Sair\n');
            fprintf('h. Ajuda\n');
            fprintf('---------------------\n');
        end
        
        function displayHelp(obj)
            % Exibir ajuda
            
            fprintf('\n=== AJUDA DO GERENCIADOR DE MODELOS ===\n');
            fprintf('\nComandos disponíveis:\n');
            fprintf('  list [diretório]     - Listar modelos disponíveis\n');
            fprintf('  load <caminho>       - Carregar modelo específico\n');
            fprintf('  versions [tipo]      - Listar versões de modelos\n');
            fprintf('  restore <tipo> <ver> - Restaurar versão específica\n');
            fprintf('  delete <caminho>     - Deletar modelo\n');
            fprintf('  report               - Gerar relatório do sistema\n');
            fprintf('  cleanup              - Executar limpeza do sistema\n');
            fprintf('  search <termo>       - Buscar modelos\n');
            fprintf('  compare              - Comparar dois modelos\n');
            fprintf('  help                 - Exibir esta ajuda\n');
            fprintf('\nExemplos:\n');
            fprintf('  modelCLI.executeCommand(''list'');\n');
            fprintf('  modelCLI.executeCommand(''load'', ''saved_models/unet_20250815_143022.mat'');\n');
            fprintf('  modelCLI.executeCommand(''versions'', ''unet'');\n');
            fprintf('=====================================\n');
        end
        
        function interactiveModelSelection(obj)
            % Seleção interativa de modelo
            
            models = ModelLoader.listAvailableModels(obj.baseDirectory);
            
            if isempty(models)
                fprintf('❌ Nenhum modelo encontrado\n');
                return;
            end
            
            fprintf('\nModelos disponíveis:\n');
            for i = 1:length(models)
                fprintf('%d. %s (%s, %s)\n', i, models(i).filename, ...
                       models(i).type, obj.formatFileSize(models(i).size));
            end
            
            choice = input('Selecione um modelo (número): ');
            
            if choice >= 1 && choice <= length(models)
                selectedModel = models(choice);
                obj.loadModelCommand(selectedModel.filepath);
            else
                fprintf('❌ Seleção inválida\n');
            end
        end
        
        function cleanupOldVersions(obj)
            % Limpeza de versões antigas
            
            fprintf('Executando limpeza de versões antigas...\n');
            
            % Listar tipos de modelo
            versionDir = fullfile(obj.baseDirectory, 'versions');
            if exist(versionDir, 'dir')
                modelTypes = dir(versionDir);
                modelTypes = modelTypes([modelTypes.isdir] & ~startsWith({modelTypes.name}, '.'));
                
                for i = 1:length(modelTypes)
                    fprintf('Limpando versões de %s...\n', modelTypes(i).name);
                    obj.versioningSystem.cleanupOldVersions(modelTypes(i).name);
                end
            end
            
            fprintf('✓ Limpeza de versões concluída\n');
        end
        
        function compressOldModels(obj)
            % Compressão de modelos antigos
            
            daysOld = input('Comprimir modelos com mais de quantos dias? (padrão: 7): ');
            if isempty(daysOld)
                daysOld = 7;
            end
            
            fprintf('Comprimindo modelos com mais de %d dias...\n', daysOld);
            
            % Implementar compressão
            versionDir = fullfile(obj.baseDirectory, 'versions');
            if exist(versionDir, 'dir')
                modelTypes = dir(versionDir);
                modelTypes = modelTypes([modelTypes.isdir] & ~startsWith({modelTypes.name}, '.'));
                
                for i = 1:length(modelTypes)
                    obj.versioningSystem.compressOldVersions(modelTypes(i).name, daysOld);
                end
            end
            
            fprintf('✓ Compressão concluída\n');
        end
        
        function cleanupTempFiles(obj)
            % Limpeza de arquivos temporários
            
            fprintf('Removendo arquivos temporários...\n');
            
            % Padrões de arquivos temporários
            tempPatterns = {'*.tmp', '*~', '*.bak', '*.temp'};
            
            for i = 1:length(tempPatterns)
                tempFiles = dir(fullfile(obj.baseDirectory, tempPatterns{i}));
                for j = 1:length(tempFiles)
                    tempPath = fullfile(obj.baseDirectory, tempFiles(j).name);
                    delete(tempPath);
                    fprintf('Removido: %s\n', tempFiles(j).name);
                end
            end
            
            fprintf('✓ Limpeza de arquivos temporários concluída\n');
        end
        
        function fullCleanup(obj)
            % Limpeza completa (cuidado!)
            
            fprintf('⚠ ATENÇÃO: Esta operação irá remover TODOS os modelos e versões!\n');
            response = input('Digite "CONFIRMAR" para continuar: ', 's');
            
            if strcmp(response, 'CONFIRMAR')
                fprintf('Executando limpeza completa...\n');
                
                % Remover todos os arquivos
                if exist(obj.baseDirectory, 'dir')
                    rmdir(obj.baseDirectory, 's');
                    mkdir(obj.baseDirectory);
                end
                
                fprintf('✓ Limpeza completa executada\n');
            else
                fprintf('Operação cancelada\n');
            end
        end
        
        function performModelComparison(obj, model1, model2)
            % Realizar comparação entre dois modelos
            
            fprintf('\n=== COMPARAÇÃO DE MODELOS ===\n');
            fprintf('Modelo 1: %s\n', model1.filename);
            fprintf('Modelo 2: %s\n', model2.filename);
            fprintf('-----------------------------\n');
            
            % Comparar tamanhos
            fprintf('Tamanho:\n');
            fprintf('  Modelo 1: %s\n', obj.formatFileSize(model1.size));
            fprintf('  Modelo 2: %s\n', obj.formatFileSize(model2.size));
            
            sizeDiff = model2.size - model1.size;
            if sizeDiff > 0
                fprintf('  Diferença: +%s (Modelo 2 é maior)\n', obj.formatFileSize(abs(sizeDiff)));
            elseif sizeDiff < 0
                fprintf('  Diferença: -%s (Modelo 1 é maior)\n', obj.formatFileSize(abs(sizeDiff)));
            else
                fprintf('  Diferença: Mesmo tamanho\n');
            end
            
            % Comparar datas
            fprintf('\nData de criação:\n');
            fprintf('  Modelo 1: %s\n', datestr(model1.date));
            fprintf('  Modelo 2: %s\n', datestr(model2.date));
            
            timeDiff = model2.date - model1.date;
            if timeDiff > 0
                fprintf('  Diferença: %.1f dias (Modelo 2 é mais recente)\n', days(timeDiff));
            elseif timeDiff < 0
                fprintf('  Diferença: %.1f dias (Modelo 1 é mais recente)\n', abs(days(timeDiff)));
            else
                fprintf('  Diferença: Mesma data\n');
            end
            
            % Comparar tipos
            fprintf('\nTipo:\n');
            fprintf('  Modelo 1: %s\n', model1.type);
            fprintf('  Modelo 2: %s\n', model2.type);
            
            if strcmp(model1.type, model2.type)
                fprintf('  Status: Mesmo tipo de modelo\n');
            else
                fprintf('  Status: Tipos diferentes\n');
            end
            
            % Tentar carregar metadados para comparação mais detalhada
            try
                [~, metadata1] = ModelLoader.loadModel(model1.filepath);
                [~, metadata2] = ModelLoader.loadModel(model2.filepath);
                
                obj.compareMetadata(metadata1, metadata2);
                
            catch
                fprintf('\n⚠ Não foi possível carregar metadados para comparação detalhada\n');
            end
        end
        
        function compareMetadata(obj, metadata1, metadata2)
            % Comparar metadados de dois modelos
            
            fprintf('\n--- COMPARAÇÃO DE METADADOS ---\n');
            
            % Comparar performance se disponível
            if ~isempty(metadata1) && isfield(metadata1, 'performance') && ...
               ~isempty(metadata2) && isfield(metadata2, 'performance')
                
                perf1 = metadata1.performance;
                perf2 = metadata2.performance;
                
                fprintf('Performance:\n');
                
                metrics = {'iou_mean', 'dice_mean', 'acc_mean'};
                metricNames = {'IoU', 'Dice', 'Acurácia'};
                
                for i = 1:length(metrics)
                    metric = metrics{i};
                    name = metricNames{i};
                    
                    if isfield(perf1, metric) && isfield(perf2, metric)
                        val1 = perf1.(metric);
                        val2 = perf2.(metric);
                        diff = val2 - val1;
                        
                        fprintf('  %s:\n', name);
                        fprintf('    Modelo 1: %.4f\n', val1);
                        fprintf('    Modelo 2: %.4f\n', val2);
                        
                        if diff > 0
                            fprintf('    Diferença: +%.4f (Modelo 2 melhor)\n', diff);
                        elseif diff < 0
                            fprintf('    Diferença: %.4f (Modelo 1 melhor)\n', diff);
                        else
                            fprintf('    Diferença: Mesma performance\n');
                        end
                    end
                end
            end
        end
        
        function generateOptimizationSuggestions(obj, models)
            % Gerar sugestões de otimização
            
            if isempty(models)
                return;
            end
            
            totalSize = sum([models.size]);
            
            % Sugestão de compressão
            if totalSize > 1024^3  % > 1GB
                fprintf('• Considere comprimir modelos antigos para economizar espaço\n');
            end
            
            % Sugestão de limpeza
            if length(models) > 20
                fprintf('• Muitos modelos encontrados. Considere fazer limpeza de modelos obsoletos\n');
            end
            
            % Verificar modelos duplicados por tamanho
            sizes = [models.size];
            uniqueSizes = unique(sizes);
            
            if length(uniqueSizes) < length(sizes)
                fprintf('• Possíveis modelos duplicados detectados (mesmo tamanho)\n');
            end
            
            % Sugestão de versionamento
            versionDir = fullfile(obj.baseDirectory, 'versions');
            if ~exist(versionDir, 'dir')
                fprintf('• Sistema de versionamento não está sendo usado. Considere ativar\n');
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