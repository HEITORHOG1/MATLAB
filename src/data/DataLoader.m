classdef DataLoader < handle
    % ========================================================================
    % DATALOADER - SISTEMA DE COMPARAÇÃO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 3.0 - Refatoração Modular
    %
    % DESCRIÇÃO:
    %   Classe unificada para carregamento de dados com suporte a múltiplos
    %   formatos e divisão automática de dados para treino/validação/teste
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Deep Learning Toolbox: Data Loading and Preprocessing
    %   - Image Processing Toolbox: Working with Images
    % ========================================================================
    
    properties (Access = private)
        config
        supportedExtensions = {'*.png', '*.jpg', '*.jpeg', '*.bmp', '*.tiff', '*.tif'}
        imageCache
        maskCache
        cacheEnabled = true
        
        % Lazy loading properties
        lazyLoadingEnabled = true
        dataIndex = []  % Index of available data without loading
        loadedData = containers.Map()  % Actually loaded data
        maxMemoryUsage = 4  % GB
        currentMemoryUsage = 0
        
        % Performance monitoring
        loadTimes = []
        cacheHitRate = 0
        totalRequests = 0
        cacheHits = 0
    end
    
    methods
        function obj = DataLoader(config)
            % Construtor da classe DataLoader
            % 
            % ENTRADA:
            %   config - Estrutura com configurações (imageDir, maskDir, etc.)
            
            if nargin < 1
                error('DataLoader:InvalidInput', 'Configuração é obrigatória');
            end
            
            obj.config = config;
            obj.imageCache = containers.Map();
            obj.maskCache = containers.Map();
            
            % Validar configuração básica
            obj.validateConfig();
        end
        
        function [images, masks] = loadData(obj, varargin)
            % Carrega dados de imagens e máscaras com validação robusta
            %
            % ENTRADA:
            %   varargin - Parâmetros opcionais:
            %     'UseCache' - true/false (padrão: true)
            %     'Verbose' - true/false (padrão: true)
            %
            % SAÍDA:
            %   images - Cell array com caminhos das imagens
            %   masks  - Cell array com caminhos das máscaras
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'UseCache', true, @islogical);
            addParameter(p, 'Verbose', true, @islogical);
            parse(p, varargin{:});
            
            useCache = p.Results.UseCache;
            verbose = p.Results.Verbose;
            
            try
                % Verificar se os diretórios existem
                obj.validateDirectories();
                
                % Carregar listas de arquivos
                [images, masks] = obj.loadFileLists();
                
                % Validar correspondência entre imagens e máscaras
                [images, masks] = obj.validateCorrespondence(images, masks);
                
                if verbose
                    fprintf('✓ DataLoader: %d pares imagem-máscara carregados com sucesso\n', ...
                        length(images));
                end
                
            catch ME
                error('DataLoader:LoadError', ...
                    'Erro ao carregar dados: %s', ME.message);
            end
        end
        
        function [trainData, valData, testData] = splitData(obj, images, masks, varargin)
            % Divide dados em conjuntos de treino, validação e teste
            %
            % ENTRADA:
            %   images - Cell array com caminhos das imagens
            %   masks  - Cell array com caminhos das máscaras
            %   varargin - Parâmetros opcionais:
            %     'TrainRatio' - Proporção para treino (padrão: 0.7)
            %     'ValRatio' - Proporção para validação (padrão: 0.2)
            %     'TestRatio' - Proporção para teste (padrão: 0.1)
            %     'Shuffle' - Embaralhar dados (padrão: true)
            %     'Seed' - Semente para reprodutibilidade (padrão: 42)
            %
            % SAÍDA:
            %   trainData - Struct com dados de treino
            %   valData   - Struct com dados de validação
            %   testData  - Struct com dados de teste
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'TrainRatio', 0.7, @(x) x > 0 && x < 1);
            addParameter(p, 'ValRatio', 0.2, @(x) x > 0 && x < 1);
            addParameter(p, 'TestRatio', 0.1, @(x) x > 0 && x < 1);
            addParameter(p, 'Shuffle', true, @islogical);
            addParameter(p, 'Seed', 42, @isnumeric);
            parse(p, varargin{:});
            
            trainRatio = p.Results.TrainRatio;
            valRatio = p.Results.ValRatio;
            testRatio = p.Results.TestRatio;
            shuffleData = p.Results.Shuffle;
            seed = p.Results.Seed;
            
            % Validar proporções
            if abs(trainRatio + valRatio + testRatio - 1.0) > 1e-6
                error('DataLoader:InvalidRatios', ...
                    'Soma das proporções deve ser 1.0 (atual: %.3f)', ...
                    trainRatio + valRatio + testRatio);
            end
            
            % Validar entrada
            if length(images) ~= length(masks)
                error('DataLoader:MismatchedData', ...
                    'Número de imagens (%d) deve ser igual ao número de máscaras (%d)', ...
                    length(images), length(masks));
            end
            
            numSamples = length(images);
            
            % Configurar semente para reprodutibilidade
            rng(seed);
            
            % Embaralhar índices se solicitado
            if shuffleData
                indices = randperm(numSamples);
            else
                indices = 1:numSamples;
            end
            
            % Calcular tamanhos dos conjuntos
            numTrain = round(numSamples * trainRatio);
            numVal = round(numSamples * valRatio);
            numTest = numSamples - numTrain - numVal;
            
            % Dividir índices
            trainIdx = indices(1:numTrain);
            valIdx = indices(numTrain+1:numTrain+numVal);
            testIdx = indices(numTrain+numVal+1:end);
            
            % Criar estruturas de dados
            trainData = struct(...
                'images', {images(trainIdx)}, ...
                'masks', {masks(trainIdx)}, ...
                'indices', trainIdx, ...
                'size', numTrain);
            
            valData = struct(...
                'images', {images(valIdx)}, ...
                'masks', {masks(valIdx)}, ...
                'indices', valIdx, ...
                'size', numVal);
            
            testData = struct(...
                'images', {images(testIdx)}, ...
                'masks', {masks(testIdx)}, ...
                'indices', testIdx, ...
                'size', numTest);
            
            fprintf('✓ Dados divididos: Treino=%d, Validação=%d, Teste=%d\n', ...
                numTrain, numVal, numTest);
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
            
            isValid = false;
            
            try
                % Verificar se arquivos existem
                if ~exist(imagePath, 'file')
                    warning('DataLoader:FileNotFound', 'Imagem não encontrada: %s', imagePath);
                    return;
                end
                
                if ~exist(maskPath, 'file')
                    warning('DataLoader:FileNotFound', 'Máscara não encontrada: %s', maskPath);
                    return;
                end
                
                % Tentar ler as imagens
                img = imread(imagePath);
                mask = imread(maskPath);
                
                % Validar dimensões básicas
                if ndims(img) < 2 || ndims(img) > 3
                    warning('DataLoader:InvalidDimensions', ...
                        'Imagem deve ter 2 ou 3 dimensões: %s', imagePath);
                    return;
                end
                
                if ndims(mask) < 2 || ndims(mask) > 3
                    warning('DataLoader:InvalidDimensions', ...
                        'Máscara deve ter 2 ou 3 dimensões: %s', maskPath);
                    return;
                end
                
                % Verificar se as dimensões espaciais são compatíveis
                if size(img, 1) ~= size(mask, 1) || size(img, 2) ~= size(mask, 2)
                    warning('DataLoader:DimensionMismatch', ...
                        'Dimensões espaciais não coincidem: %s vs %s', ...
                        imagePath, maskPath);
                    return;
                end
                
                isValid = true;
                
            catch ME
                warning('DataLoader:ValidationError', ...
                    'Erro ao validar %s: %s', imagePath, ME.message);
            end
        end
        
        function [img, mask] = lazyLoadSample(obj, index)
            % Carrega uma amostra específica usando lazy loading
            %
            % ENTRADA:
            %   index - Índice da amostra a carregar
            %
            % SAÍDA:
            %   img  - Imagem carregada
            %   mask - Máscara carregada
            %
            % REQUISITOS: 7.2 (lazy loading para datasets grandes)
            
            obj.totalRequests = obj.totalRequests + 1;
            
            % Gerar chave para cache
            cacheKey = sprintf('sample_%d', index);
            
            % Verificar se já está carregado
            if obj.loadedData.isKey(cacheKey)
                data = obj.loadedData(cacheKey);
                img = data.img;
                mask = data.mask;
                obj.cacheHits = obj.cacheHits + 1;
                obj.updateCacheHitRate();
                return;
            end
            
            % Verificar se há espaço na memória
            if obj.currentMemoryUsage >= obj.maxMemoryUsage
                obj.cleanupMemory();
            end
            
            try
                startTime = tic;
                
                % Carregar dados do disco
                if isempty(obj.dataIndex)
                    error('DataLoader:NoIndex', 'Índice de dados não inicializado');
                end
                
                if index > length(obj.dataIndex.images)
                    error('DataLoader:InvalidIndex', 'Índice %d fora do range', index);
                end
                
                imgPath = obj.dataIndex.images{index};
                maskPath = obj.dataIndex.masks{index};
                
                img = imread(imgPath);
                mask = imread(maskPath);
                
                % Estimar uso de memória
                memoryUsage = obj.estimateMemoryUsage(img, mask);
                
                % Armazenar no cache se habilitado
                if obj.cacheEnabled
                    data = struct('img', img, 'mask', mask, 'memoryUsage', memoryUsage, ...
                                 'lastAccess', now);
                    obj.loadedData(cacheKey) = data;
                    obj.currentMemoryUsage = obj.currentMemoryUsage + memoryUsage;
                end
                
                % Registrar tempo de carregamento
                loadTime = toc(startTime);
                obj.loadTimes(end+1) = loadTime;
                
            catch ME
                error('DataLoader:LazyLoadError', ...
                    'Erro no lazy loading do índice %d: %s', index, ME.message);
            end
        end
        
        function initializeLazyLoading(obj, images, masks)
            % Inicializa sistema de lazy loading
            %
            % ENTRADA:
            %   images - Cell array com caminhos das imagens
            %   masks  - Cell array com caminhos das máscaras
            %
            % REQUISITOS: 7.2 (lazy loading para datasets grandes)
            
            if ~obj.lazyLoadingEnabled
                return;
            end
            
            try
                % Criar índice de dados sem carregar
                obj.dataIndex = struct();
                obj.dataIndex.images = images;
                obj.dataIndex.masks = masks;
                obj.dataIndex.size = length(images);
                obj.dataIndex.initialized = true;
                
                % Inicializar cache de dados carregados
                obj.loadedData = containers.Map();
                obj.currentMemoryUsage = 0;
                
                % Configurar limite de memória baseado no sistema
                obj.configureMemoryLimits();
                
                fprintf('✓ Lazy loading inicializado para %d amostras (limite: %.1f GB)\n', ...
                    obj.dataIndex.size, obj.maxMemoryUsage);
                
            catch ME
                warning('DataLoader:LazyLoadInit', ...
                    'Erro ao inicializar lazy loading: %s', ME.message);
                obj.lazyLoadingEnabled = false;
            end
        end
        
        function cleanupMemory(obj)
            % Limpa memória removendo dados menos usados
            %
            % REQUISITOS: 7.3 (limpeza automática de variáveis)
            
            if obj.loadedData.Count == 0
                return;
            end
            
            try
                keys = obj.loadedData.keys;
                accessTimes = [];
                memoryUsages = [];
                
                % Coletar informações de acesso e uso de memória
                for i = 1:length(keys)
                    data = obj.loadedData(keys{i});
                    accessTimes(i) = data.lastAccess;
                    memoryUsages(i) = data.memoryUsage;
                end
                
                % Ordenar por tempo de acesso (mais antigos primeiro)
                [~, sortIdx] = sort(accessTimes);
                
                % Remover itens até liberar 50% da memória
                targetMemory = obj.maxMemoryUsage * 0.5;
                removedCount = 0;
                
                for i = 1:length(sortIdx)
                    if obj.currentMemoryUsage <= targetMemory
                        break;
                    end
                    
                    idx = sortIdx(i);
                    key = keys{idx};
                    data = obj.loadedData(key);
                    
                    obj.currentMemoryUsage = obj.currentMemoryUsage - data.memoryUsage;
                    obj.loadedData.remove(key);
                    removedCount = removedCount + 1;
                end
                
                % Forçar garbage collection
                clear data;
                
                fprintf('🧹 Memória limpa: %d itens removidos (%.1f GB liberados)\n', ...
                    removedCount, obj.maxMemoryUsage * 0.5);
                
            catch ME
                warning('DataLoader:CleanupError', ...
                    'Erro na limpeza de memória: %s', ME.message);
            end
        end
        
        function stats = getPerformanceStats(obj)
            % Retorna estatísticas de performance
            %
            % SAÍDA:
            %   stats - Estrutura com estatísticas detalhadas
            
            stats = struct();
            
            % Estatísticas de cache
            stats.cache.enabled = obj.cacheEnabled;
            stats.cache.hitRate = obj.cacheHitRate;
            stats.cache.totalRequests = obj.totalRequests;
            stats.cache.hits = obj.cacheHits;
            stats.cache.misses = obj.totalRequests - obj.cacheHits;
            
            % Estatísticas de memória
            stats.memory.currentUsage = obj.currentMemoryUsage;
            stats.memory.maxUsage = obj.maxMemoryUsage;
            stats.memory.utilizationPercent = (obj.currentMemoryUsage / obj.maxMemoryUsage) * 100;
            stats.memory.itemsLoaded = obj.loadedData.Count;
            
            % Estatísticas de tempo de carregamento
            if ~isempty(obj.loadTimes)
                stats.loadTime.average = mean(obj.loadTimes);
                stats.loadTime.median = median(obj.loadTimes);
                stats.loadTime.min = min(obj.loadTimes);
                stats.loadTime.max = max(obj.loadTimes);
                stats.loadTime.total = sum(obj.loadTimes);
            else
                stats.loadTime = struct('average', 0, 'median', 0, 'min', 0, 'max', 0, 'total', 0);
            end
            
            % Estatísticas de lazy loading
            stats.lazyLoading.enabled = obj.lazyLoadingEnabled;
            if ~isempty(obj.dataIndex)
                stats.lazyLoading.totalSamples = obj.dataIndex.size;
                stats.lazyLoading.loadedSamples = obj.loadedData.Count;
                stats.lazyLoading.loadedPercent = (obj.loadedData.Count / obj.dataIndex.size) * 100;
            else
                stats.lazyLoading.totalSamples = 0;
                stats.lazyLoading.loadedSamples = 0;
                stats.lazyLoading.loadedPercent = 0;
            end
        end
    end
    
    methods (Access = private)
        function validateConfig(obj)
            % Valida a configuração fornecida
            
            requiredFields = {'imageDir', 'maskDir'};
            
            for i = 1:length(requiredFields)
                field = requiredFields{i};
                if ~isfield(obj.config, field)
                    error('DataLoader:MissingConfig', ...
                        'Campo obrigatório ausente na configuração: %s', field);
                end
                
                if ~ischar(obj.config.(field)) && ~isstring(obj.config.(field))
                    error('DataLoader:InvalidConfig', ...
                        'Campo %s deve ser string ou char', field);
                end
            end
        end
        
        function validateDirectories(obj)
            % Valida se os diretórios existem
            
            if ~exist(obj.config.imageDir, 'dir')
                error('DataLoader:DirectoryNotFound', ...
                    'Diretório de imagens não encontrado: %s', obj.config.imageDir);
            end
            
            if ~exist(obj.config.maskDir, 'dir')
                error('DataLoader:DirectoryNotFound', ...
                    'Diretório de máscaras não encontrado: %s', obj.config.maskDir);
            end
        end
        
        function [images, masks] = loadFileLists(obj)
            % Carrega listas de arquivos de imagens e máscaras
            
            images = {};
            masks = {};
            
            % Listar arquivos de imagens
            for ext = obj.supportedExtensions
                imgFiles = dir(fullfile(obj.config.imageDir, ext{1}));
                if ~isempty(imgFiles)
                    imgPaths = arrayfun(@(x) fullfile(obj.config.imageDir, x.name), ...
                        imgFiles, 'UniformOutput', false);
                    images = [images; imgPaths];
                end
            end
            
            % Listar arquivos de máscaras
            for ext = obj.supportedExtensions
                maskFiles = dir(fullfile(obj.config.maskDir, ext{1}));
                if ~isempty(maskFiles)
                    maskPaths = arrayfun(@(x) fullfile(obj.config.maskDir, x.name), ...
                        maskFiles, 'UniformOutput', false);
                    masks = [masks; maskPaths];
                end
            end
            
            % Verificar se encontrou arquivos
            if isempty(images)
                error('DataLoader:NoImagesFound', ...
                    'Nenhuma imagem encontrada em: %s', obj.config.imageDir);
            end
            
            if isempty(masks)
                error('DataLoader:NoMasksFound', ...
                    'Nenhuma máscara encontrada em: %s', obj.config.maskDir);
            end
        end
        
        function [images, masks] = validateCorrespondence(obj, images, masks)
            % Valida e ajusta correspondência entre imagens e máscaras
            
            % Ordenar para garantir correspondência
            images = sort(images);
            masks = sort(masks);
            
            % Extrair nomes base para comparação
            [~, imgNames, ~] = cellfun(@fileparts, images, 'UniformOutput', false);
            [~, maskNames, ~] = cellfun(@fileparts, masks, 'UniformOutput', false);
            
            % Encontrar interseção
            [commonNames, imgIdx, maskIdx] = intersect(imgNames, maskNames);
            
            if length(commonNames) < length(images) || length(commonNames) < length(masks)
                warning('DataLoader:MismatchedFiles', ...
                    'Nem todas as imagens têm máscaras correspondentes. Usando apenas pares válidos.');
                
                fprintf('  - Imagens originais: %d\n', length(images));
                fprintf('  - Máscaras originais: %d\n', length(masks));
                fprintf('  - Pares válidos: %d\n', length(commonNames));
            end
            
            % Manter apenas arquivos com correspondência
            images = images(imgIdx);
            masks = masks(maskIdx);
            
            if isempty(images)
                error('DataLoader:NoValidPairs', ...
                    'Nenhum par imagem-máscara válido encontrado');
            end
        end
        
        function updateCacheHitRate(obj)
            % Atualiza taxa de acerto do cache
            if obj.totalRequests > 0
                obj.cacheHitRate = obj.cacheHits / obj.totalRequests;
            end
        end
        
        function memoryUsage = estimateMemoryUsage(obj, img, mask)
            % Estima uso de memória de uma imagem e máscara
            %
            % ENTRADA:
            %   img  - Imagem
            %   mask - Máscara
            %
            % SAÍDA:
            %   memoryUsage - Uso estimado de memória em GB
            
            try
                % Calcular bytes para imagem
                imgBytes = numel(img) * 8; % Assumir double precision
                
                % Calcular bytes para máscara
                maskBytes = numel(mask) * 8;
                
                % Converter para GB e adicionar overhead
                memoryUsage = (imgBytes + maskBytes) / (1024^3) * 1.2; % 20% overhead
                
            catch
                % Fallback: estimativa conservadora
                memoryUsage = 0.1; % 100MB por amostra
            end
        end
        
        function configureMemoryLimits(obj)
            % Configura limites de memória baseado no sistema
            
            try
                % Tentar obter informação de memória do sistema
                if ispc
                    [~, memInfo] = system('wmic computersystem get TotalPhysicalMemory /value');
                    tokens = regexp(memInfo, 'TotalPhysicalMemory=(\d+)', 'tokens');
                    if ~isempty(tokens)
                        totalMemoryBytes = str2double(tokens{1}{1});
                        totalMemoryGB = totalMemoryBytes / (1024^3);
                        % Usar 25% da memória total para cache
                        obj.maxMemoryUsage = totalMemoryGB * 0.25;
                    end
                elseif isunix
                    [~, memInfo] = system('free -b | grep Mem');
                    tokens = regexp(memInfo, '\s+(\d+)', 'tokens');
                    if length(tokens) >= 2
                        totalMemoryBytes = str2double(tokens{1}{1});
                        totalMemoryGB = totalMemoryBytes / (1024^3);
                        % Usar 25% da memória total para cache
                        obj.maxMemoryUsage = totalMemoryGB * 0.25;
                    end
                end
                
                % Garantir limites mínimos e máximos
                obj.maxMemoryUsage = max(1, min(8, obj.maxMemoryUsage)); % Entre 1GB e 8GB
                
            catch
                % Fallback: usar valor padrão conservador
                obj.maxMemoryUsage = 2; % 2GB
            end
        end
    end
end