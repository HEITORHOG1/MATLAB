classdef DataPreprocessor < handle
    % ========================================================================
    % DATAPREPROCESSOR - SISTEMA DE COMPARAÇÃO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 3.0 - Refatoração Modular
    %
    % DESCRIÇÃO:
    %   Classe otimizada para pré-processamento de dados com cache inteligente
    %   e conversões otimizadas categorical/single para evitar erros de tipo
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Deep Learning Toolbox: Data Preprocessing
    %   - Image Processing Toolbox: Image Enhancement and Filtering
    % ========================================================================
    
    properties (Access = private)
        config
        cache
        cacheEnabled = true
        cacheMaxSize = 1000  % Máximo de itens no cache
        augmentationEnabled = true
        classNames = ["background", "foreground"]
        labelIDs = [0, 1]
    end
    
    properties (Access = public)
        % Estatísticas de uso
        cacheHits = 0
        cacheMisses = 0
        totalProcessed = 0
    end
    
    methods
        function obj = DataPreprocessor(config, varargin)
            % Construtor da classe DataPreprocessor
            % 
            % ENTRADA:
            %   config - Estrutura com configurações
            %   varargin - Parâmetros opcionais:
            %     'EnableCache' - true/false (padrão: true)
            %     'CacheMaxSize' - Tamanho máximo do cache (padrão: 1000)
            %     'ClassNames' - Nomes das classes (padrão: ["background", "foreground"])
            %     'LabelIDs' - IDs dos labels (padrão: [0, 1])
            
            if nargin < 1
                error('DataPreprocessor:InvalidInput', 'Configuração é obrigatória');
            end
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'EnableCache', true, @islogical);
            addParameter(p, 'CacheMaxSize', 1000, @isnumeric);
            addParameter(p, 'ClassNames', ["background", "foreground"], @isstring);
            addParameter(p, 'LabelIDs', [0, 1], @isnumeric);
            parse(p, varargin{:});
            
            obj.config = config;
            obj.cacheEnabled = p.Results.EnableCache;
            obj.cacheMaxSize = p.Results.CacheMaxSize;
            obj.classNames = p.Results.ClassNames;
            obj.labelIDs = p.Results.LabelIDs;
            
            % Inicializar cache
            if obj.cacheEnabled
                obj.cache = containers.Map();
            end
            
            % Validar configuração
            obj.validateConfig();
        end
        
        function data = preprocess(obj, data, varargin)
            % Pré-processa dados de imagem e máscara
            %
            % ENTRADA:
            %   data - Cell array {imagem, máscara} ou caminhos para arquivos
            %   varargin - Parâmetros opcionais:
            %     'IsTraining' - true/false (padrão: false)
            %     'UseAugmentation' - true/false (padrão: false)
            %     'UseCache' - true/false (padrão: true)
            %
            % SAÍDA:
            %   data - Cell array {imagem_processada, máscara_processada}
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'IsTraining', false, @islogical);
            addParameter(p, 'UseAugmentation', false, @islogical);
            addParameter(p, 'UseCache', true, @islogical);
            parse(p, varargin{:});
            
            isTraining = p.Results.IsTraining;
            useAugmentation = p.Results.UseAugmentation && isTraining;
            useCache = p.Results.UseCache && obj.cacheEnabled;
            
            obj.totalProcessed = obj.totalProcessed + 1;
            
            try
                % Gerar chave de cache se aplicável
                cacheKey = '';
                if useCache && ~useAugmentation
                    cacheKey = obj.generateCacheKey(data, isTraining);
                    if obj.cache.isKey(cacheKey)
                        data = obj.cache(cacheKey);
                        obj.cacheHits = obj.cacheHits + 1;
                        return;
                    end
                    obj.cacheMisses = obj.cacheMisses + 1;
                end
                
                % Carregar dados se necessário
                if iscell(data) && length(data) == 2 && ischar(data{1})
                    % Dados são caminhos de arquivo
                    img = imread(data{1});
                    mask = imread(data{2});
                    data = {img, mask};
                elseif iscell(data) && length(data) == 2
                    % Dados já são matrizes
                    img = data{1};
                    mask = data{2};
                else
                    error('DataPreprocessor:InvalidInput', ...
                        'Dados devem ser cell array {imagem, máscara}');
                end
                
                % Pré-processar imagem
                img = obj.preprocessImage(img);
                
                % Pré-processar máscara
                mask = obj.preprocessMask(mask);
                
                % Aplicar data augmentation se solicitado
                if useAugmentation
                    [img, mask] = obj.augment(img, mask);
                end
                
                % Validação final e conversão de tipos
                [img, mask] = obj.finalizeProcessing(img, mask);
                
                data = {img, mask};
                
                % Salvar no cache se aplicável
                if useCache && ~useAugmentation && ~isempty(cacheKey)
                    obj.addToCache(cacheKey, data);
                end
                
            catch ME
                error('DataPreprocessor:ProcessingError', ...
                    'Erro no pré-processamento: %s', ME.message);
            end
        end
        
        function [img, mask] = augment(obj, img, mask)
            % Aplica data augmentation às imagens e máscaras
            %
            % ENTRADA:
            %   img  - Imagem a ser aumentada
            %   mask - Máscara correspondente
            %
            % SAÍDA:
            %   img  - Imagem aumentada
            %   mask - Máscara aumentada
            
            if ~obj.augmentationEnabled
                return;
            end
            
            % Flip horizontal (50% chance)
            if rand > 0.5
                img = fliplr(img);
                mask = fliplr(mask);
            end
            
            % Flip vertical (30% chance)
            if rand > 0.7
                img = flipud(img);
                mask = flipud(mask);
            end
            
            % Rotação pequena (30% chance)
            if rand > 0.7
                angle = (rand - 0.5) * 20; % ±10 graus
                img = imrotate(img, angle, 'bilinear', 'crop');
                mask = imrotate(mask, angle, 'nearest', 'crop');
            end
            
            % Ajuste de brilho (40% chance)
            if rand > 0.6
                brightness_factor = 0.8 + 0.4 * rand; % 0.8 a 1.2
                img = img * brightness_factor;
                img = min(max(img, 0), 1);
            end
            
            % Ajuste de contraste (30% chance)
            if rand > 0.7
                contrast_factor = 0.8 + 0.4 * rand; % 0.8 a 1.2
                img = (img - 0.5) * contrast_factor + 0.5;
                img = min(max(img, 0), 1);
            end
            
            % Ruído gaussiano (20% chance)
            if rand > 0.8
                noise_std = 0.01 * rand; % 0 a 0.01
                noise = noise_std * randn(size(img));
                img = img + noise;
                img = min(max(img, 0), 1);
            end
        end
        
        function clearCache(obj)
            % Limpa o cache de dados preprocessados
            
            if obj.cacheEnabled && ~isempty(obj.cache)
                obj.cache.remove(obj.cache.keys);
                fprintf('✓ Cache limpo (%d hits, %d misses)\n', ...
                    obj.cacheHits, obj.cacheMisses);
            end
        end
        
        function optimizeMemoryUsage(obj)
            % Otimiza uso de memória com limpeza automática
            %
            % REQUISITOS: 7.3 (otimizar uso de memória com limpeza automática de variáveis)
            
            try
                % Limpar variáveis temporárias
                evalin('base', 'clear temp* tmp*');
                
                % Forçar garbage collection
                java.lang.System.gc();
                
                % Limpar cache se muito grande
                if obj.cacheEnabled && obj.cache.Count > obj.cacheMaxSize * 0.8
                    obj.intelligentCacheCleanup();
                end
                
                % Limpar histórico de tempos de processamento se muito grande
                if length(obj.loadTimes) > 1000
                    obj.loadTimes = obj.loadTimes(end-100:end); % Manter apenas últimos 100
                end
                
                fprintf('🧹 Memória otimizada (cache: %d itens, processados: %d)\n', ...
                    obj.cache.Count, obj.totalProcessed);
                
            catch ME
                warning('DataPreprocessor:MemoryOptimization', ...
                    'Erro na otimização de memória: %s', ME.message);
            end
        end
        
        function intelligentCacheCleanup(obj)
            % Limpeza inteligente do cache baseada em uso e idade
            %
            % REQUISITOS: 7.2 (cache inteligente de dados preprocessados)
            
            if ~obj.cacheEnabled || obj.cache.Count == 0
                return;
            end
            
            try
                keys = obj.cache.keys;
                scores = zeros(length(keys), 1);
                
                % Calcular score para cada item do cache
                for i = 1:length(keys)
                    data = obj.cache(keys{i});
                    
                    % Score baseado em frequência de uso e idade
                    if isfield(data, 'accessCount') && isfield(data, 'lastAccess')
                        age = now - data.lastAccess;
                        frequency = data.accessCount;
                        
                        % Score maior = mais importante (manter)
                        scores(i) = frequency / (1 + age);
                    else
                        scores(i) = 0.1; % Score baixo para itens sem metadados
                    end
                end
                
                % Ordenar por score (menores primeiro = remover primeiro)
                [~, sortIdx] = sort(scores);
                
                % Remover 30% dos itens com menor score
                itemsToRemove = round(length(keys) * 0.3);
                removedCount = 0;
                
                for i = 1:min(itemsToRemove, length(sortIdx))
                    key = keys{sortIdx(i)};
                    obj.cache.remove(key);
                    removedCount = removedCount + 1;
                end
                
                fprintf('🧠 Cache inteligente: %d itens removidos (score-based)\n', removedCount);
                
            catch ME
                warning('DataPreprocessor:CacheCleanup', ...
                    'Erro na limpeza inteligente do cache: %s', ME.message);
            end
        end
        
        function data = preprocessBatch(obj, dataBatch, varargin)
            % Pré-processa um lote de dados para otimização de performance
            %
            % ENTRADA:
            %   dataBatch - Cell array de dados {imagem1, máscara1; imagem2, máscara2; ...}
            %   varargin - Parâmetros opcionais (mesmos do preprocess)
            %
            % SAÍDA:
            %   data - Cell array com dados preprocessados
            %
            % REQUISITOS: 7.2 (otimizações de processamento)
            
            if isempty(dataBatch)
                data = {};
                return;
            end
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'IsTraining', false, @islogical);
            addParameter(p, 'UseAugmentation', false, @islogical);
            addParameter(p, 'UseCache', true, @islogical);
            addParameter(p, 'UseParallel', false, @islogical);
            parse(p, varargin{:});
            
            useParallel = p.Results.UseParallel;
            
            try
                batchSize = size(dataBatch, 1);
                data = cell(batchSize, 1);
                
                if useParallel && batchSize > 4
                    % Processamento paralelo para lotes grandes
                    fprintf('⚡ Processando lote de %d amostras em paralelo...\n', batchSize);
                    
                    parfor i = 1:batchSize
                        try
                            data{i} = obj.preprocess(dataBatch(i, :), varargin{:});
                        catch ME
                            warning('DataPreprocessor:BatchError', ...
                                'Erro no processamento paralelo do item %d: %s', i, ME.message);
                            data{i} = [];
                        end
                    end
                else
                    % Processamento sequencial
                    for i = 1:batchSize
                        data{i} = obj.preprocess(dataBatch(i, :), varargin{:});
                        
                        % Otimizar memória a cada 10 itens
                        if mod(i, 10) == 0
                            obj.optimizeMemoryUsage();
                        end
                    end
                end
                
                % Remover itens vazios (falhas no processamento)
                data = data(~cellfun(@isempty, data));
                
                fprintf('✓ Lote processado: %d/%d amostras válidas\n', length(data), batchSize);
                
            catch ME
                error('DataPreprocessor:BatchProcessingError', ...
                    'Erro no processamento em lote: %s', ME.message);
            end
        end
        
        function stats = getCacheStats(obj)
            % Retorna estatísticas do cache
            
            if obj.cacheEnabled
                stats = struct(...
                    'enabled', true, ...
                    'size', obj.cache.Count, ...
                    'maxSize', obj.cacheMaxSize, ...
                    'hits', obj.cacheHits, ...
                    'misses', obj.cacheMisses, ...
                    'hitRate', obj.cacheHits / max(1, obj.cacheHits + obj.cacheMisses), ...
                    'totalProcessed', obj.totalProcessed);
            else
                stats = struct('enabled', false);
            end
        end
    end
    
    methods (Access = private)
        function validateConfig(obj)
            % Valida a configuração fornecida
            
            requiredFields = {'inputSize'};
            
            for i = 1:length(requiredFields)
                field = requiredFields{i};
                if ~isfield(obj.config, field)
                    error('DataPreprocessor:MissingConfig', ...
                        'Campo obrigatório ausente na configuração: %s', field);
                end
            end
            
            % Validar inputSize
            if ~isnumeric(obj.config.inputSize) || length(obj.config.inputSize) < 2
                error('DataPreprocessor:InvalidConfig', ...
                    'inputSize deve ser vetor numérico com pelo menos 2 elementos');
            end
        end
        
        function img = preprocessImage(obj, img)
            % Pré-processa uma imagem
            
            % Redimensionar
            img = imresize(img, obj.config.inputSize(1:2));
            
            % Garantir que a imagem tenha 3 canais
            if size(img, 3) == 1
                img = repmat(img, [1, 1, 3]);
            elseif size(img, 3) > 3
                img = img(:,:,1:3);
            end
            
            % Normalizar para [0,1]
            if ~isa(img, 'double')
                img = im2double(img);
            end
            
            % Verificar valores válidos
            if any(img(:) < 0) || any(img(:) > 1)
                img = max(0, min(1, img));
            end
        end
        
        function mask = preprocessMask(obj, mask)
            % Pré-processa uma máscara
            
            % Redimensionar com interpolação nearest
            mask = imresize(mask, obj.config.inputSize(1:2), 'nearest');
            
            % Converter para escala de cinza se necessário
            if size(mask, 3) > 1
                mask = rgb2gray(mask);
            end
            
            % Converter para double
            mask = double(mask);
            
            % Normalizar se os valores estão em [0,255]
            if max(mask(:)) > 1
                mask = mask / 255;
            end
            
            % Binarizar máscara
            threshold = 0.5;
            mask = double(mask > threshold);
            
            % Garantir que seja 2D
            if size(mask, 3) > 1
                mask = mask(:,:,1);
            end
        end
        
        function [img, mask] = finalizeProcessing(obj, img, mask)
            % Finaliza o processamento com conversões de tipo otimizadas
            
            % CRÍTICO: Conversão otimizada para evitar erros de tipo
            
            % Converter imagem para single (requerido pelo trainNetwork)
            img = single(img);
            
            % Validar dimensões da imagem
            if size(img, 3) ~= 3
                error('DataPreprocessor:InvalidImageDimensions', ...
                    'Imagem deve ter 3 canais após processamento');
            end
            
            % Converter máscara para categorical (requerido para segmentação semântica)
            % CORREÇÃO CRÍTICA: Garantir valores corretos antes da conversão
            uniqueVals = unique(mask(:));
            
            if length(uniqueVals) > length(obj.labelIDs)
                % Forçar binarização se há valores extras
                mask = double(mask > 0.5);
            end
            
            % Garantir que mask só tenha valores válidos dos labelIDs
            mask = uint8(mask);
            for i = 1:length(obj.labelIDs)
                mask(mask == i-1) = obj.labelIDs(i);
            end
            
            % Converter para categorical com classes corretas
            try
                mask = categorical(mask, obj.labelIDs, obj.classNames);
            catch ME
                % Fallback: forçar valores válidos
                warning('DataPreprocessor:CategoricalConversion', ...
                    'Erro na conversão categorical, aplicando correção: %s', ME.message);
                
                mask = double(mask > 0);
                mask = categorical(mask, [0, 1], obj.classNames);
            end
            
            % Validar dimensões finais
            if ndims(mask) ~= 2
                error('DataPreprocessor:InvalidMaskDimensions', ...
                    'Máscara deve ser 2D após processamento');
            end
            
            % Verificar compatibilidade de dimensões
            if size(img, 1) ~= size(mask, 1) || size(img, 2) ~= size(mask, 2)
                error('DataPreprocessor:DimensionMismatch', ...
                    'Dimensões espaciais de imagem e máscara não coincidem');
            end
        end
        
        function cacheKey = generateCacheKey(obj, data, isTraining)
            % Gera chave única para cache baseada nos dados
            
            if iscell(data) && length(data) == 2 && ischar(data{1})
                % Usar caminhos de arquivo como base
                keyStr = sprintf('%s_%s_%d_%dx%d', ...
                    data{1}, data{2}, isTraining, ...
                    obj.config.inputSize(1), obj.config.inputSize(2));
            else
                % Usar hash dos dados
                keyStr = sprintf('data_%d_%dx%d', ...
                    isTraining, obj.config.inputSize(1), obj.config.inputSize(2));
            end
            
            % Gerar hash simples da string (compatível com Octave)
            try
                % Tentar usar Java MD5 se disponível
                cacheKey = char(java.security.MessageDigest.getInstance('MD5').digest(uint8(keyStr)));
                cacheKey = sprintf('%02x', cacheKey);
            catch
                % Fallback: usar hash simples baseado na string
                cacheKey = sprintf('cache_%d', mod(sum(uint8(keyStr)), 999999));
            end
        end
        
        function addToCache(obj, key, data)
            % Adiciona item ao cache com controle de tamanho
            
            if obj.cache.Count >= obj.cacheMaxSize
                % Remover item mais antigo (FIFO simples)
                keys = obj.cache.keys;
                obj.cache.remove(keys{1});
            end
            
            obj.cache(key) = data;
        end
    end
end