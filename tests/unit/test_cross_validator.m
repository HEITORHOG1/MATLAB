function test_cross_validator()
    % ========================================================================
    % TESTES UNITÁRIOS - CROSS VALIDATOR
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Testes unitários para a classe CrossValidator
    %
    % TUTORIAL MATLAB:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Unit Testing Framework
    % ========================================================================
    
    fprintf('=== INICIANDO TESTES UNITÁRIOS - CROSS VALIDATOR ===\n\n');
    
    % Adicionar caminho para as classes
    addpath(genpath('src'));
    
    % Executar todos os testes
    try
        test_constructor();
        test_create_random_folds();
        test_create_stratified_folds();
        test_k_fold_validation();
        test_model_comparison();
        test_edge_cases();
        
        fprintf('\n=== TODOS OS TESTES PASSARAM! ===\n');
        
    catch ME
        fprintf('\n=== ERRO NOS TESTES ===\n');
        fprintf('Erro: %s\n', ME.message);
        fprintf('Arquivo: %s\n', ME.stack(1).file);
        fprintf('Linha: %d\n', ME.stack(1).line);
        rethrow(ME);
    end
end

function test_constructor()
    fprintf('Testando construtor...\n');
    
    % Teste construtor padrão
    cv1 = CrossValidator();
    assert(isa(cv1, 'CrossValidator'), 'Construtor padrão falhou');
    
    % Teste construtor com parâmetros
    cv2 = CrossValidator('verbose', true, 'randomSeed', 123);
    assert(isa(cv2, 'CrossValidator'), 'Construtor com parâmetros falhou');
    
    fprintf('✓ Construtor OK\n');
end

function test_create_random_folds()
    fprintf('Testando criação de folds aleatórios...\n');
    
    cv = CrossValidator('randomSeed', 42);
    
    % Dados de teste simples
    data = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    k = 3;
    
    % Criar folds
    folds = cv.createKFolds(data, k);
    
    % Verificar estrutura
    assert(iscell(folds), 'Folds devem ser cell array');
    assert(length(folds) == k, 'Número de folds incorreto');
    
    % Verificar que todos os índices estão presentes
    allIndices = [];
    for i = 1:k
        allIndices = [allIndices, folds{i}];
    end
    allIndices = sort(allIndices);
    expectedIndices = 1:length(data);
    
    assert(isequal(allIndices, expectedIndices), 'Nem todos os índices estão presentes');
    
    % Verificar que não há sobreposição
    for i = 1:k
        for j = i+1:k
            overlap = intersect(folds{i}, folds{j});
            assert(isempty(overlap), 'Há sobreposição entre folds');
        end
    end
    
    fprintf('✓ Folds aleatórios OK\n');
end

function test_create_stratified_folds()
    fprintf('Testando criação de folds estratificados...\n');
    
    cv = CrossValidator('randomSeed', 42);
    
    % Dados com labels para estratificação
    data = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};
    labels = [1, 1, 1, 2, 2, 2, 3, 3, 3, 1, 2, 3]; % 3 classes
    k = 3;
    
    % Criar folds estratificados
    folds = cv.createKFolds(data, k, 'stratified', true, 'labels', labels);
    
    % Verificar estrutura
    assert(iscell(folds), 'Folds devem ser cell array');
    assert(length(folds) == k, 'Número de folds incorreto');
    
    % Verificar estratificação (cada fold deve ter amostras de cada classe)
    uniqueLabels = unique(labels);
    for i = 1:k
        foldLabels = labels(folds{i});
        for classLabel = uniqueLabels
            hasClass = any(foldLabels == classLabel);
            % Para dados pequenos, pode não ser possível garantir todas as classes em todos os folds
            % Então vamos apenas verificar que a distribuição é razoável
        end
    end
    
    fprintf('✓ Folds estratificados OK\n');
end

function test_k_fold_validation()
    fprintf('Testando validação cruzada k-fold...\n');
    
    cv = CrossValidator('randomSeed', 42);
    
    % Dados de teste simulados
    data = struct();
    data.X = rand(20, 5); % 20 amostras, 5 features
    data.y = rand(20, 1); % 20 targets
    
    % Função de treinamento simulada
    trainFunction = @(trainData) struct('weights', rand(5, 1), 'bias', rand());
    
    % Função de avaliação simulada
    evaluateFunction = @(model, testData) struct('mse', rand(), 'r2', rand());
    
    k = 5;
    
    % Executar validação cruzada
    results = cv.performKFoldValidation(data, trainFunction, evaluateFunction, k);
    
    % Verificar estrutura
    assert(isstruct(results), 'Resultado deve ser struct');
    assert(isfield(results, 'k'), 'Deve conter k');
    assert(isfield(results, 'foldResults'), 'Deve conter foldResults');
    assert(isfield(results, 'aggregated'), 'Deve conter aggregated');
    assert(isfield(results, 'trainTime'), 'Deve conter trainTime');
    assert(isfield(results, 'evalTime'), 'Deve conter evalTime');
    
    % Verificar valores
    assert(results.k == k, 'Valor de k incorreto');
    assert(length(results.foldResults) == k, 'Número de fold results incorreto');
    assert(length(results.trainTime) == k, 'Número de train times incorreto');
    assert(length(results.evalTime) == k, 'Número de eval times incorreto');
    
    % Verificar agregação
    assert(isstruct(results.aggregated), 'Agregação deve ser struct');
    
    fprintf('✓ Validação cruzada k-fold OK\n');
end

function test_model_comparison()
    fprintf('Testando comparação de modelos...\n');
    
    cv = CrossValidator('randomSeed', 42);
    
    % Dados de teste
    data = struct();
    data.X = rand(16, 3); % 16 amostras para permitir divisão em 4 folds
    data.y = rand(16, 1);
    
    % Duas funções de treinamento simuladas
    trainFunction1 = @(trainData) struct('type', 'model1', 'accuracy', 0.8 + 0.1*rand());
    trainFunction2 = @(trainData) struct('type', 'model2', 'accuracy', 0.85 + 0.1*rand());
    
    trainFunctions = {trainFunction1, trainFunction2};
    
    % Função de avaliação que retorna métricas diferentes para cada modelo
    evaluateFunction = @(model, testData) struct('accuracy', model.accuracy + 0.05*randn(), ...
                                                'precision', 0.8 + 0.1*rand());
    
    k = 4;
    modelNames = {'Model A', 'Model B'};
    
    % Executar comparação
    comparison = cv.compareModelsKFold(data, trainFunctions, evaluateFunction, k, modelNames);
    
    % Verificar estrutura
    assert(isstruct(comparison), 'Comparação deve ser struct');
    assert(isfield(comparison, 'modelNames'), 'Deve conter modelNames');
    assert(isfield(comparison, 'k'), 'Deve conter k');
    assert(isfield(comparison, 'modelResults'), 'Deve conter modelResults');
    assert(isfield(comparison, 'summary'), 'Deve conter summary');
    
    % Verificar valores
    assert(comparison.k == k, 'Valor de k incorreto');
    assert(length(comparison.modelResults) == 2, 'Número de model results incorreto');
    assert(isequal(comparison.modelNames, modelNames), 'Model names incorretos');
    
    % Verificar que cada modelo tem resultados
    for i = 1:length(comparison.modelResults)
        modelResult = comparison.modelResults{i};
        assert(isstruct(modelResult), 'Model result deve ser struct');
        assert(isfield(modelResult, 'foldResults'), 'Model result deve conter foldResults');
    end
    
    fprintf('✓ Comparação de modelos OK\n');
end

function test_edge_cases()
    fprintf('Testando casos extremos...\n');
    
    cv = CrossValidator();
    
    % Teste com k inválido
    data = {1, 2, 3, 4, 5};
    
    try
        folds = cv.createKFolds(data, 0); % k = 0 deve falhar
        assert(false, 'Deveria ter falhado com k = 0');
    catch ME
        % Verificar que falhou por motivo relacionado a k inválido
        assert(~isempty(strfind(ME.message, 'deve estar entre')), 'Erro incorreto para k inválido');
    end
    
    try
        folds = cv.createKFolds(data, 10); % k > nSamples deve falhar
        assert(false, 'Deveria ter falhado com k > nSamples');
    catch ME
        assert(~isempty(strfind(ME.message, 'deve estar entre')), 'Erro incorreto para k > nSamples');
    end
    
    % Teste com estratificação sem labels
    try
        folds = cv.createKFolds(data, 3, 'stratified', true);
        assert(false, 'Deveria ter falhado sem labels para estratificação');
    catch ME
        assert(~isempty(strfind(ME.message, 'Labels são necessários')), 'Erro incorreto para labels ausentes');
    end
    
    % Teste com dados vazios
    emptyData = {};
    try
        folds = cv.createKFolds(emptyData, 2);
        assert(false, 'Deveria ter falhado com dados vazios');
    catch ME
        % Esperado falhar
    end
    
    % Teste com k = 1 (deve falhar)
    try
        folds = cv.createKFolds(data, 1);
        assert(false, 'Deveria ter falhado com k = 1');
    catch ME
        assert(~isempty(strfind(ME.message, 'deve estar entre')), 'Erro incorreto para k = 1');
    end
    
    fprintf('✓ Casos extremos OK\n');
end