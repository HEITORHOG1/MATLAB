classdef TrainingIntegration < handle
    % ========================================================================
    % TRAININGINTEGRATION - Integração com Pipeline de Treinamento Existente
    % ========================================================================
    % 
    % AUTOR: Sistema de Melhorias de Segmentação
    % Data: Agosto 2025
    % Versão: 1.0
    %
    % DESCRIÇÃO:
    %   Classe responsável pela integração do sistema de gerenciamento
    %   de modelos com o pipeline de treinamento existente
    % ========================================================================
    
    properties (Access = private)
        modelSaver
        modelLoader
        versioningSystem
        autoSaveEnabled
        autoVersionEnabled
    end
    
    methods
        function obj = TrainingIntegration(config)
            % Construtor da integração
            %
            % Parâmetros:
            %   config - configuração do sistema
            
            if nargin < 1
                config = struct();
            end
            
            % Inicializar componentes
            obj.modelSaver = ModelSaver(config);
            obj.versioningSystem = ModelVersioning(config);
            
            % Configurações
            obj.autoSaveEnabled = obj.getConfigValue(config, 'autoSaveEnabled', true);
            obj.autoVersionEnabled = obj.getConfigValue(config, 'autoVersionEnabled', true);
            
            fprintf('✓ Sistema de gerenciamento de modelos inicializado\n');
        end
        
        function enhancedConfig = enhanceTrainingConfig(obj, originalConfig)
            % Aprimorar configuração de treinamento com funcionalidades de salvamento
            %
            % Parâmetros:
            %   originalConfig - configuração original
            %
            % Retorna:
            %   enhancedConfig - configuração aprimorada
            
            enhancedConfig = originalConfig;
            
            % Adicionar configurações de salvamento
            enhancedConfig.modelManagement = struct();
            enhancedConfig.modelManagement.autoSave = obj.autoSaveEnabled;
            enhancedConfig.modelManagement.autoVersion = obj.autoVersionEnabled;
            enhancedConfig.modelManagement.saveDirectory = 'saved_models';
            
            % Adicionar callbacks de salvamento
            enhancedConfig.modelManagement.saveCallback = @obj.saveModelCallback;
            enhancedConfig.modelManagement.versionCallback = @obj.versionCallback;
            
            fprintf('✓ Configuração de treinamento aprimorada\n');
        end
        
        function modifiedScript = modifyTrainingScript(obj, scriptPath, outputPath)
            % Modificar script de treinamento existente para incluir salvamento automático
            %
            % Parâmetros:
            %   scriptPath - caminho do script original
            %   outputPath - caminho do script modificado
            %
            % Retorna:
            %   modifiedScript - conteúdo do script modificado
            
            try
                % Ler script original
                fid = fopen(scriptPath, 'r');
                if fid == -1
                    error('Não foi possível abrir o script: %s', scriptPath);
                end
                
                originalContent = fread(fid, '*char')';
                fclose(fid);
                
                % Modificar conteúdo
                modifiedScript = obj.insertModelManagementCode(originalContent);
                
                % Salvar script modificado
                if nargin > 2 && ~isempty(outputPath)
                    fid = fopen(outputPath, 'w');
                    if fid ~= -1
                        fprintf(fid, '%s', modifiedScript);
                        fclose(fid);
                        fprintf('✓ Script modificado salvo: %s\n', outputPath);
                    end
                end
                
            catch ME
                fprintf('❌ Erro ao modificar script: %s\n', ME.message);
                modifiedScript = '';
                rethrow(ME);
            end
        end
        
        function success = integrateWithExistingTraining(obj, trainingFunction, config)
            % Integrar com função de treinamento existente
            %
            % Parâmetros:
            %   trainingFunction - handle da função de treinamento
            %   config - configuração de treinamento
            %
            % Retorna:
            %   success - true se integração foi bem-sucedida
            
            success = false;
            
            try
                fprintf('Integrando sistema de gerenciamento com treinamento...\n');
                
                % Aprimorar configuração
                enhancedConfig = obj.enhanceTrainingConfig(config);
                
                % Executar treinamento com configuração aprimorada
                result = trainingFunction(enhancedConfig);
                
                % Processar resultado se disponível
                if ~isempty(result)
                    obj.processTrainingResult(result, enhancedConfig);
                end
                
                success = true;
                fprintf('✓ Integração concluída com sucesso\n');
                
            catch ME
                fprintf('❌ Erro na integração: %s\n', ME.message);
            end
        end
        
        function savedPath = saveTrainedModel(obj, model, modelType, metrics, config)
            % Salvar modelo treinado com metadados
            %
            % Parâmetros:
            %   model - modelo treinado
            %   modelType - tipo do modelo
            %   metrics - métricas de performance
            %   config - configuração de treinamento
            %
            % Retorna:
            %   savedPath - caminho do modelo salvo
            
            try
                % Salvar modelo
                savedPath = obj.modelSaver.saveModel(model, modelType, metrics, config);
                
                % Criar versão se habilitado
                if obj.autoVersionEnabled
                    obj.versioningSystem.createNewVersion(savedPath, modelType);
                end
                
                fprintf('✓ Modelo %s salvo e versionado\n', modelType);
                
            catch ME
                fprintf('❌ Erro ao salvar modelo: %s\n', ME.message);
                savedPath = '';
            end
        end
        
        function [model, metadata] = loadPretrainedModel(obj, modelType, versionNumber)
            % Carregar modelo pré-treinado
            %
            % Parâmetros:
            %   modelType - tipo do modelo
            %   versionNumber - número da versão (opcional, usa mais recente se vazio)
            %
            % Retorna:
            %   model - modelo carregado
            %   metadata - metadados do modelo
            
            model = [];
            metadata = [];
            
            try
                if nargin > 2 && ~isempty(versionNumber)
                    % Carregar versão específica
                    [model, metadata] = obj.versioningSystem.restoreVersion(modelType, versionNumber);
                else
                    % Carregar melhor modelo disponível
                    [model, metadata] = ModelLoader.loadBestModel('saved_models', 'iou_mean');
                end
                
                if ~isempty(model)
                    fprintf('✓ Modelo pré-treinado carregado: %s\n', modelType);
                end
                
            catch ME
                fprintf('❌ Erro ao carregar modelo pré-treinado: %s\n', ME.message);
            end
        end
        
        function createEnhancedTrainingScript(obj, originalScriptPath, enhancedScriptPath)
            % Criar versão aprimorada do script de treinamento
            %
            % Parâmetros:
            %   originalScriptPath - caminho do script original
            %   enhancedScriptPath - caminho do script aprimorado
            
            try
                % Template do script aprimorado
                template = obj.generateEnhancedScriptTemplate();
                
                % Ler script original para extrair lógica específica
                originalContent = fileread(originalScriptPath);
                
                % Combinar template com lógica original
                enhancedContent = obj.combineScriptContent(template, originalContent);
                
                % Salvar script aprimorado
                fid = fopen(enhancedScriptPath, 'w');
                if fid ~= -1
                    fprintf(fid, '%s', enhancedContent);
                    fclose(fid);
                    fprintf('✓ Script aprimorado criado: %s\n', enhancedScriptPath);
                end
                
            catch ME
                fprintf('❌ Erro ao criar script aprimorado: %s\n', ME.message);
            end
        end
    end
    
    methods (Access = private)
        function value = getConfigValue(obj, config, fieldName, defaultValue)
            % Obter valor de configuração com fallback
            if isfield(config, fieldName)
                value = config.(fieldName);
            else
                value = defaultValue;
            end
        end
        
        function saveModelCallback(obj, model, modelType, metrics, config)
            % Callback para salvamento automático durante treinamento
            
            try
                obj.saveTrainedModel(model, modelType, metrics, config);
            catch ME
                fprintf('⚠ Erro no callback de salvamento: %s\n', ME.message);
            end
        end
        
        function versionCallback(obj, modelPath, modelType)
            % Callback para versionamento automático
            
            try
                obj.versioningSystem.createNewVersion(modelPath, modelType);
            catch ME
                fprintf('⚠ Erro no callback de versionamento: %s\n', ME.message);
            end
        end
        
        function modifiedContent = insertModelManagementCode(obj, originalContent)
            % Inserir código de gerenciamento de modelos no script original
            
            modifiedContent = originalContent;
            
            % Adicionar imports no início
            importCode = sprintf([...
                '%% Adicionar sistema de gerenciamento de modelos\n' ...
                'addpath(''src/model_management'');\n' ...
                'modelSaver = ModelSaver();\n' ...
                'modelVersioning = ModelVersioning();\n\n'
            ]);
            
            % Inserir após a primeira linha de função
            functionPattern = 'function\s+.*?\n';
            modifiedContent = regexprep(modifiedContent, functionPattern, '$0\n    ' + importCode);
            
            % Adicionar código de salvamento antes do final da função
            saveCode = sprintf([...
                '\n    %% Salvamento automático do modelo\n' ...
                '    try\n' ...
                '        if exist(''net'', ''var'')\n' ...
                '            modelType = ''unet'';\n' ...
                '            if contains(func2str(@treinar_modelo), ''attention'')\n' ...
                '                modelType = ''attention_unet'';\n' ...
                '            end\n' ...
                '            \n' ...
                '            %% Calcular métricas se disponíveis\n' ...
                '            if exist(''metricas'', ''var'')\n' ...
                '                savedPath = modelSaver.saveModel(net, modelType, metricas, config);\n' ...
                '            else\n' ...
                '                savedPath = modelSaver.saveModel(net, modelType, struct(), config);\n' ...
                '            end\n' ...
                '            \n' ...
                '            %% Criar versão\n' ...
                '            modelVersioning.createNewVersion(savedPath, modelType);\n' ...
                '            \n' ...
                '            fprintf(''✓ Modelo salvo e versionado automaticamente\\n'');\n' ...
                '        end\n' ...
                '    catch ME\n' ...
                '        fprintf(''⚠ Erro no salvamento automático: %%s\\n'', ME.message);\n' ...
                '    end\n'
            ]);
            
            % Inserir antes do 'end' final
            modifiedContent = regexprep(modifiedContent, '\nend\s*$', saveCode + '\nend');
        end
        
        function processTrainingResult(obj, result, config)
            % Processar resultado do treinamento
            
            try
                if isstruct(result)
                    % Extrair modelo e métricas do resultado
                    if isfield(result, 'model')
                        model = result.model;
                        modelType = obj.getConfigValue(result, 'modelType', 'unet');
                        metrics = obj.getConfigValue(result, 'metrics', struct());
                        
                        obj.saveTrainedModel(model, modelType, metrics, config);
                    end
                end
            catch ME
                fprintf('⚠ Erro ao processar resultado: %s\n', ME.message);
            end
        end
        
        function template = generateEnhancedScriptTemplate(obj)
            % Gerar template para script aprimorado
            
            template = sprintf([...
                'function result = enhanced_training_script(config)\n' ...
                '%% Script de treinamento aprimorado com gerenciamento de modelos\n' ...
                '%% Gerado automaticamente pelo sistema de melhorias\n\n' ...
                '    %% Inicializar sistema de gerenciamento\n' ...
                '    addpath(''src/model_management'');\n' ...
                '    trainingIntegration = TrainingIntegration(config);\n\n' ...
                '    %% Aprimorar configuração\n' ...
                '    config = trainingIntegration.enhanceTrainingConfig(config);\n\n' ...
                '    %% Verificar se deve carregar modelo pré-treinado\n' ...
                '    if isfield(config, ''loadPretrainedModel'') && config.loadPretrainedModel\n' ...
                '        fprintf(''Carregando modelo pré-treinado...\\n'');\n' ...
                '        [pretrainedModel, metadata] = trainingIntegration.loadPretrainedModel(config.modelType);\n' ...
                '        if ~isempty(pretrainedModel)\n' ...
                '            config.pretrainedModel = pretrainedModel;\n' ...
                '            config.pretrainedMetadata = metadata;\n' ...
                '        end\n' ...
                '    end\n\n' ...
                '    %% === INSERIR LÓGICA DE TREINAMENTO ORIGINAL AQUI ===\n' ...
                '    %% [Código do script original será inserido]\n\n' ...
                '    %% Salvamento automático\n' ...
                '    if exist(''net'', ''var'')\n' ...
                '        modelType = config.modelType;\n' ...
                '        metrics = struct(); %% Calcular métricas reais\n' ...
                '        \n' ...
                '        savedPath = trainingIntegration.saveTrainedModel(net, modelType, metrics, config);\n' ...
                '        \n' ...
                '        result = struct();\n' ...
                '        result.model = net;\n' ...
                '        result.modelType = modelType;\n' ...
                '        result.metrics = metrics;\n' ...
                '        result.savedPath = savedPath;\n' ...
                '    else\n' ...
                '        result = struct();\n' ...
                '    end\n\n' ...
                'end\n'
            ]);
        end
        
        function combinedContent = combineScriptContent(obj, template, originalContent)
            % Combinar template com conteúdo original
            
            % Extrair lógica principal do script original
            % (implementação simplificada - pode ser expandida)
            
            % Encontrar seção de treinamento no script original
            trainingSection = obj.extractTrainingLogic(originalContent);
            
            % Substituir placeholder no template
            combinedContent = strrep(template, ...
                '    %% === INSERIR LÓGICA DE TREINAMENTO ORIGINAL AQUI ===', ...
                trainingSection);
        end
        
        function trainingLogic = extractTrainingLogic(obj, content)
            % Extrair lógica de treinamento do script original
            % (implementação simplificada)
            
            % Procurar por seções importantes
            patterns = {
                'trainNetwork\(.*?\);',
                'net\s*=\s*trainNetwork.*?;',
                'lgraph\s*=.*?;',
                'options\s*=\s*trainingOptions.*?\);'
            };
            
            trainingLogic = '    %% Lógica de treinamento extraída\n';
            
            for i = 1:length(patterns)
                matches = regexp(content, patterns{i}, 'match');
                for j = 1:length(matches)
                    trainingLogic = [trainingLogic, '    ', matches{j}, '\n'];
                end
            end
        end
    end
end