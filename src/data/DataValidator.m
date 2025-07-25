classdef DataValidator < handle
    % ========================================================================
    % DATAVALIDATOR - SISTEMA DE COMPARAÇÃO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 3.0 - Refatoração Modular
    %
    % DESCRIÇÃO:
    %   Classe para validação automática de dados e correção de problemas
    %   comuns em datasets de segmentação semântica
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Image Processing Toolbox: Image Analysis and Enhancement
    %   - Deep Learning Toolbox: Data Validation and Quality Control
    % ========================================================================
    
    properties (Access = private)
        config
        supportedFormats = {'.png', '.jpg', '.jpeg', '.bmp', '.tiff', '.tif'}
        validationResults
        correctionLog
    end
    
    properties (Access = public)
        % Estatísticas de validação
        totalValidated = 0
        validFiles = 0
        invalidFiles = 0
        correctedFiles = 0
        autoCorrectEnabled = true
    end
    
    methods
        function obj = DataValidator(config, varargin)
            % Construtor da classe DataValidator
            % 
            % ENTRADA:
            %   config - Estrutura com configurações
            %   varargin - Parâmetros opcionais:
            %     'AutoCorrect' - true/false (padrão: true)
            
            if nargin < 1
                error('DataValidator:InvalidInput', 'Configuração é obrigatória');
            end
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'AutoCorrect', true, @islogical);
            parse(p, varargin{:});
            
            obj.config = config;
            obj.autoCorrectEnabled = p.Results.AutoCorrect;
            obj.validationResults = {};
            obj.correctionLog = {};
            
            % Validar configuração
            obj.validateConfig();
        end
        
        function isValid = validateDataFormat(obj, imagePath, maskPath)
            % Valida formato de uma imagem e máscara específicas
            %
            % ENTRADA:
            %   imagePath - Caminho para a imagem
            %   maskPath  - Caminho para a máscara
            %
            % SAÍDA:
            %   isValid - true se os formatos são válidos
            
            obj.totalValidated = obj.totalValidated + 1;
            isValid = false;
            issues = {};
            
            try
                % Verificar existência dos arquivos
                if ~exist(imagePath, 'file')
                    issues{end+1} = sprintf('Imagem não encontrada: %s', imagePath);
                    obj.logValidationResult(imagePath, maskPath, false, issues);
                    return;
                end
                
                if ~exist(maskPath, 'file')
                    issues{end+1} = sprintf('Máscara não encontrada: %s', maskPath);
                    obj.logValidationResult(imagePath, maskPath, false, issues);
                    return;
                end
                
                % Verificar extensões de arquivo
                [~, ~, imgExt] = fileparts(imagePath);
                [~, ~, maskExt] = fileparts(maskPath);
                
                if ~ismember(lower(imgExt), obj.supportedFormats)
                    issues{end+1} = sprintf('Formato de imagem não suportado: %s', imgExt);
                end
                
                if ~ismember(lower(maskExt), obj.supportedFormats)
                    issues{end+1} = sprintf('Formato de máscara não suportado: %s', maskExt);
                end
                
                % Tentar ler as imagens
                try
                    imgInfo = imfinfo(imagePath);
                    maskInfo = imfinfo(maskPath);
                catch ME
                    issues{end+1} = sprintf('Erro ao ler informações: %s', ME.message);
                    obj.logValidationResult(imagePath, maskPath, false, issues);
                    return;
                end
                
                % Validar dimensões básicas
                if imgInfo.Width ~= maskInfo.Width || imgInfo.Height ~= maskInfo.Height
                    issues{end+1} = sprintf('Dimensões não coincidem: img(%dx%d) vs mask(%dx%d)', ...
                        imgInfo.Width, imgInfo.Height, maskInfo.Width, maskInfo.Height);
                end
                
                % Verificar se as imagens são muito pequenas
                minSize = 32; % Tamanho mínimo razoável
                if imgInfo.Width < minSize || imgInfo.Height < minSize
                    issues{end+1} = sprintf('Imagem muito pequena: %dx%d (mínimo: %dx%d)', ...
                        imgInfo.Width, imgInfo.Height, minSize, minSize);
                end
                
                % Verificar profundidade de bits
                if imgInfo.BitDepth < 8
                    issues{end+1} = sprintf('Profundidade de bits muito baixa: %d', imgInfo.BitDepth);
                end
                
                % Tentar carregar e validar conteúdo
                try
                    img = imread(imagePath);
                    mask = imread(maskPath);
                    
                    % Validar dimensões carregadas
                    if ndims(img) < 2 || ndims(img) > 3
                        issues{end+1} = sprintf('Dimensões de imagem inválidas: %dD', ndims(img));
                    end
                    
                    if ndims(mask) < 2 || ndims(mask) > 3
                        issues{end+1} = sprintf('Dimensões de máscara inválidas: %dD', ndims(mask));
                    end
                    
                    % Verificar valores da máscara
                    if size(mask, 3) > 1
                        mask = rgb2gray(mask);
                    end
                    
                    uniqueVals = unique(mask(:));
                    if length(uniqueVals) > 10  % Muitos valores únicos para segmentação binária
                        issues{end+1} = sprintf('Máscara com muitos valores únicos: %d', length(uniqueVals));
                    end
                    
                catch ME
                    issues{end+1} = sprintf('Erro ao carregar dados: %s', ME.message);
                end
                
                % Determinar se é válido
                isValid = isempty(issues);
                
                if isValid
                    obj.validFiles = obj.validFiles + 1;
                else
                    obj.invalidFiles = obj.invalidFiles + 1;
                end
                
                obj.logValidationResult(imagePath, maskPath, isValid, issues);
                
            catch ME
                issues{end+1} = sprintf('Erro geral na validação: %s', ME.message);
                obj.logValidationResult(imagePath, maskPath, false, issues);
                obj.invalidFiles = obj.invalidFiles + 1;
            end
        end
        
        function isConsistent = checkDataConsistency(obj, images, masks)
            % Valida correspondência entre listas de imagens e máscaras
            %
            % ENTRADA:
            %   images - Cell array com caminhos das imagens
            %   masks  - Cell array com caminhos das máscaras
            %
            % SAÍDA:
            %   isConsistent - true se os dados são consistentes
            
            isConsistent = true;
            issues = {};
            
            try
                % Verificar se as listas têm o mesmo tamanho
                if length(images) ~= length(masks)
                    issues{end+1} = sprintf('Número de imagens (%d) ≠ número de máscaras (%d)', ...
                        length(images), length(masks));
                    isConsistent = false;
                end
                
                % Verificar correspondência de nomes
                if ~isempty(images) && ~isempty(masks)
                    [~, imgNames, ~] = cellfun(@fileparts, images, 'UniformOutput', false);
                    [~, maskNames, ~] = cellfun(@fileparts, masks, 'UniformOutput', false);
                    
                    % Ordenar para comparação
                    imgNames = sort(imgNames);
                    maskNames = sort(maskNames);
                    
                    % Encontrar nomes não correspondentes
                    missingInMasks = setdiff(imgNames, maskNames);
                    missingInImages = setdiff(maskNames, imgNames);
                    
                    if ~isempty(missingInMasks)
                        issues{end+1} = sprintf('Máscaras ausentes para: %s', ...
                            strjoin(missingInMasks, ', '));
                        isConsistent = false;
                    end
                    
                    if ~isempty(missingInImages)
                        issues{end+1} = sprintf('Imagens ausentes para: %s', ...
                            strjoin(missingInImages, ', '));
                        isConsistent = false;
                    end
                end
                
                % Verificar consistência de formatos
                if ~isempty(images)
                    [~, ~, imgExts] = cellfun(@fileparts, images, 'UniformOutput', false);
                    uniqueImgExts = unique(lower(imgExts));
                    
                    if length(uniqueImgExts) > 3  % Muitos formatos diferentes
                        issues{end+1} = sprintf('Muitos formatos de imagem diferentes: %s', ...
                            strjoin(uniqueImgExts, ', '));
                    end
                end
                
                if ~isempty(masks)
                    [~, ~, maskExts] = cellfun(@fileparts, masks, 'UniformOutput', false);
                    uniqueMaskExts = unique(lower(maskExts));
                    
                    if length(uniqueMaskExts) > 3  % Muitos formatos diferentes
                        issues{end+1} = sprintf('Muitos formatos de máscara diferentes: %s', ...
                            strjoin(uniqueMaskExts, ', '));
                    end
                end
                
                % Log dos resultados
                obj.logConsistencyResult(isConsistent, issues);
                
            catch ME
                issues{end+1} = sprintf('Erro na verificação de consistência: %s', ME.message);
                obj.logConsistencyResult(false, issues);
                isConsistent = false;
            end
        end
        
        function [correctedImages, correctedMasks] = autoCorrectData(obj, images, masks)
            % Aplica correções automáticas aos dados quando possível
            %
            % ENTRADA:
            %   images - Cell array com caminhos das imagens
            %   masks  - Cell array com caminhos das máscaras
            %
            % SAÍDA:
            %   correctedImages - Cell array com imagens corrigidas
            %   correctedMasks  - Cell array com máscaras corrigidas
            
            if ~obj.autoCorrectEnabled
                correctedImages = images;
                correctedMasks = masks;
                return;
            end
            
            correctedImages = images;
            correctedMasks = masks;
            corrections = {};
            
            try
                % Correção 1: Remover pares sem correspondência
                if length(images) ~= length(masks)
                    [correctedImages, correctedMasks] = obj.matchImageMaskPairs(images, masks);
                    corrections{end+1} = sprintf('Removidos %d pares sem correspondência', ...
                        length(images) + length(masks) - length(correctedImages) - length(correctedMasks));
                end
                
                % Correção 2: Filtrar arquivos inválidos
                validPairs = true(length(correctedImages), 1);
                
                for i = 1:length(correctedImages)
                    if ~obj.validateDataFormat(correctedImages{i}, correctedMasks{i})
                        validPairs(i) = false;
                    end
                end
                
                if sum(~validPairs) > 0
                    correctedImages = correctedImages(validPairs);
                    correctedMasks = correctedMasks(validPairs);
                    corrections{end+1} = sprintf('Removidos %d pares inválidos', sum(~validPairs));
                end
                
                % Correção 3: Verificar duplicatas
                [correctedImages, correctedMasks, numDuplicates] = obj.removeDuplicates(correctedImages, correctedMasks);
                if numDuplicates > 0
                    corrections{end+1} = sprintf('Removidas %d duplicatas', numDuplicates);
                end
                
                % Log das correções
                if ~isempty(corrections)
                    obj.correctedFiles = obj.correctedFiles + length(corrections);
                    obj.logCorrections(corrections);
                end
                
            catch ME
                warning('DataValidator:CorrectionError', ...
                    'Erro na correção automática: %s', ME.message);
                % Retornar dados originais em caso de erro
                correctedImages = images;
                correctedMasks = masks;
            end
        end
        
        function report = generateValidationReport(obj)
            % Gera relatório detalhado da validação
            %
            % SAÍDA:
            %   report - Struct com relatório completo
            
            report = struct();
            report.summary = struct(...
                'totalValidated', obj.totalValidated, ...
                'validFiles', obj.validFiles, ...
                'invalidFiles', obj.invalidFiles, ...
                'correctedFiles', obj.correctedFiles, ...
                'successRate', obj.validFiles / max(1, obj.totalValidated));
            
            report.validationResults = obj.validationResults;
            report.correctionLog = obj.correctionLog;
            
            % Análise de problemas comuns
            allIssues = {};
            for i = 1:length(obj.validationResults)
                if ~obj.validationResults{i}.isValid
                    allIssues = [allIssues, obj.validationResults{i}.issues];
                end
            end
            
            if ~isempty(allIssues)
                [uniqueIssues, ~, idx] = unique(allIssues);
                issueCounts = accumarray(idx, 1);
                [sortedCounts, sortIdx] = sort(issueCounts, 'descend');
                
                report.commonIssues = struct();
                for i = 1:min(10, length(uniqueIssues))  % Top 10 problemas
                    issue = uniqueIssues{sortIdx(i)};
                    count = sortedCounts(i);
                    fieldName = sprintf('issue_%d', i);
                    report.commonIssues.(fieldName) = struct('description', issue, 'count', count);
                end
            end
            
            % Compatibility fix for Octave
            try
                report.timestamp = datetime('now');
            catch
                report.timestamp = datestr(now);
            end
        end
        
        function printReport(obj)
            % Imprime relatório de validação no console
            
            report = obj.generateValidationReport();
            
            fprintf('\n=== RELATÓRIO DE VALIDAÇÃO DE DADOS ===\n');
            fprintf('Total validado: %d arquivos\n', report.summary.totalValidated);
            fprintf('Arquivos válidos: %d (%.1f%%)\n', ...
                report.summary.validFiles, report.summary.successRate * 100);
            fprintf('Arquivos inválidos: %d\n', report.summary.invalidFiles);
            fprintf('Correções aplicadas: %d\n', report.summary.correctedFiles);
            
            if isfield(report, 'commonIssues')
                fprintf('\n--- PROBLEMAS MAIS COMUNS ---\n');
                fields = fieldnames(report.commonIssues);
                for i = 1:length(fields)
                    issue = report.commonIssues.(fields{i});
                    fprintf('%d. %s (%d ocorrências)\n', i, issue.description, issue.count);
                end
            end
            
            fprintf('\nValidação concluída em: %s\n', char(report.timestamp));
        end
    end
    
    methods (Access = private)
        function validateConfig(obj)
            % Valida a configuração fornecida
            
            if ~isstruct(obj.config)
                error('DataValidator:InvalidConfig', 'Configuração deve ser struct');
            end
        end
        
        function logValidationResult(obj, imagePath, maskPath, isValid, issues)
            % Registra resultado de validação
            
            % Compatibility fix for Octave
            try
                timestamp = datetime('now');
            catch
                timestamp = datestr(now);
            end
            
            result = struct(...
                'imagePath', imagePath, ...
                'maskPath', maskPath, ...
                'isValid', isValid, ...
                'issues', {issues}, ...
                'timestamp', timestamp);
            
            obj.validationResults{end+1} = result;
        end
        
        function logConsistencyResult(obj, isConsistent, issues)
            % Registra resultado de verificação de consistência
            
            % Compatibility fix for Octave
            try
                timestamp = datetime('now');
            catch
                timestamp = datestr(now);
            end
            
            result = struct(...
                'type', 'consistency_check', ...
                'isConsistent', isConsistent, ...
                'issues', {issues}, ...
                'timestamp', timestamp);
            
            obj.validationResults{end+1} = result;
        end
        
        function logCorrections(obj, corrections)
            % Registra correções aplicadas
            
            % Compatibility fix for Octave
            try
                timestamp = datetime('now');
            catch
                timestamp = datestr(now);
            end
            
            correction = struct(...
                'corrections', {corrections}, ...
                'timestamp', timestamp);
            
            obj.correctionLog{end+1} = correction;
        end
        
        function [matchedImages, matchedMasks] = matchImageMaskPairs(obj, images, masks)
            % Encontra pares correspondentes entre imagens e máscaras
            
            % Extrair nomes base
            [~, imgNames, ~] = cellfun(@fileparts, images, 'UniformOutput', false);
            [~, maskNames, ~] = cellfun(@fileparts, masks, 'UniformOutput', false);
            
            % Encontrar interseção
            [~, imgIdx, maskIdx] = intersect(imgNames, maskNames);
            
            matchedImages = images(imgIdx);
            matchedMasks = masks(maskIdx);
        end
        
        function [uniqueImages, uniqueMasks, numDuplicates] = removeDuplicates(obj, images, masks)
            % Remove duplicatas baseadas nos nomes dos arquivos
            
            % Extrair nomes base
            [~, imgNames, ~] = cellfun(@fileparts, images, 'UniformOutput', false);
            
            % Encontrar índices únicos
            [~, uniqueIdx] = unique(imgNames, 'stable');
            
            uniqueImages = images(uniqueIdx);
            uniqueMasks = masks(uniqueIdx);
            numDuplicates = length(images) - length(uniqueImages);
        end
    end
end