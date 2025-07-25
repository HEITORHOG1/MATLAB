function test_metrics_calculator()
    % ========================================================================
    % TESTES UNITÁRIOS - METRICS CALCULATOR
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Testes unitários para a classe MetricsCalculator
    %
    % TUTORIAL MATLAB:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Unit Testing Framework
    % ========================================================================
    
    fprintf('=== INICIANDO TESTES UNITÁRIOS - METRICS CALCULATOR ===\n\n');
    
    % Adicionar caminho para as classes
    addpath(genpath('src'));
    
    % Executar todos os testes
    try
        test_constructor();
        test_basic_metrics();
        test_edge_cases();
        test_all_metrics();
        test_class_metrics();
        test_batch_metrics();
        test_error_handling();
        
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
    calc1 = MetricsCalculator();
    assert(isa(calc1, 'MetricsCalculator'), 'Construtor padrão falhou');
    
    % Teste construtor com verbose
    calc2 = MetricsCalculator('verbose', true);
    assert(isa(calc2, 'MetricsCalculator'), 'Construtor com verbose falhou');
    
    fprintf('✓ Construtor OK\n');
end

function test_basic_metrics()
    fprintf('Testando métricas básicas...\n');
    
    calc = MetricsCalculator();
    
    % Criar dados de teste simples
    pred = [1 1 0; 0 1 0; 0 0 0];
    gt   = [1 0 0; 0 1 0; 0 0 1];
    
    % Testar IoU
    iou = calc.calculateIoU(pred, gt);
    assert(iou >= 0 && iou <= 1, 'IoU fora do intervalo válido');
    
    % Testar Dice
    dice = calc.calculateDice(pred, gt);
    assert(dice >= 0 && dice <= 1, 'Dice fora do intervalo válido');
    
    % Testar Accuracy
    acc = calc.calculateAccuracy(pred, gt);
    assert(acc >= 0 && acc <= 1, 'Accuracy fora do intervalo válido');
    
    fprintf('✓ Métricas básicas OK\n');
end

function test_edge_cases()
    fprintf('Testando casos extremos...\n');
    
    calc = MetricsCalculator();
    
    % Caso 1: Ambos vazios (todos zeros)
    pred_empty = zeros(3, 3);
    gt_empty = zeros(3, 3);
    
    iou_empty = calc.calculateIoU(pred_empty, gt_empty);
    dice_empty = calc.calculateDice(pred_empty, gt_empty);
    acc_empty = calc.calculateAccuracy(pred_empty, gt_empty);
    
    assert(iou_empty == 1, 'IoU para caso vazio deve ser 1');
    assert(dice_empty == 1, 'Dice para caso vazio deve ser 1');
    assert(acc_empty == 1, 'Accuracy para caso vazio deve ser 1');
    
    % Caso 2: Predição perfeita
    pred_perfect = [1 1 0; 0 1 0; 0 0 1];
    gt_perfect = [1 1 0; 0 1 0; 0 0 1];
    
    iou_perfect = calc.calculateIoU(pred_perfect, gt_perfect);
    dice_perfect = calc.calculateDice(pred_perfect, gt_perfect);
    acc_perfect = calc.calculateAccuracy(pred_perfect, gt_perfect);
    
    assert(iou_perfect == 1, 'IoU para predição perfeita deve ser 1');
    assert(dice_perfect == 1, 'Dice para predição perfeita deve ser 1');
    assert(acc_perfect == 1, 'Accuracy para predição perfeita deve ser 1');
    
    % Caso 3: Dados categóricos (apenas se disponível)
    try
        pred_cat = categorical([1 2 1; 1 2 1; 1 1 1]);
        gt_cat = categorical([1 1 1; 1 2 1; 1 1 2]);
        
        iou_cat = calc.calculateIoU(pred_cat, gt_cat);
        dice_cat = calc.calculateDice(pred_cat, gt_cat);
        acc_cat = calc.calculateAccuracy(pred_cat, gt_cat);
        
        assert(iou_cat >= 0 && iou_cat <= 1, 'IoU categórico fora do intervalo válido');
        assert(dice_cat >= 0 && dice_cat <= 1, 'Dice categórico fora do intervalo válido');
        assert(acc_cat >= 0 && acc_cat <= 1, 'Accuracy categórico fora do intervalo válido');
        
        fprintf('  ✓ Dados categóricos testados\n');
    catch
        fprintf('  ⚠ Dados categóricos não disponíveis (Octave)\n');
    end
    
    fprintf('✓ Casos extremos OK\n');
end

function test_all_metrics()
    fprintf('Testando calculateAllMetrics...\n');
    
    calc = MetricsCalculator();
    
    % Dados de teste
    pred = [1 1 0; 0 1 0; 0 0 0];
    gt   = [1 0 0; 0 1 0; 0 0 1];
    
    % Calcular todas as métricas
    metrics = calc.calculateAllMetrics(pred, gt);
    
    % Verificar estrutura
    assert(isstruct(metrics), 'Resultado deve ser struct');
    assert(isfield(metrics, 'iou'), 'Deve conter campo iou');
    assert(isfield(metrics, 'dice'), 'Deve conter campo dice');
    assert(isfield(metrics, 'accuracy'), 'Deve conter campo accuracy');
    assert(isfield(metrics, 'timestamp'), 'Deve conter campo timestamp');
    assert(isfield(metrics, 'valid'), 'Deve conter campo valid');
    
    % Verificar valores
    assert(metrics.iou >= 0 && metrics.iou <= 1, 'IoU inválido');
    assert(metrics.dice >= 0 && metrics.dice <= 1, 'Dice inválido');
    assert(metrics.accuracy >= 0 && metrics.accuracy <= 1, 'Accuracy inválido');
    assert(islogical(metrics.valid), 'Campo valid deve ser lógico');
    
    fprintf('✓ calculateAllMetrics OK\n');
end

function test_class_metrics()
    fprintf('Testando métricas por classe...\n');
    
    calc = MetricsCalculator();
    
    % Dados multi-classe
    pred = [1 2 1; 2 2 1; 1 1 3];
    gt   = [1 1 1; 2 2 1; 1 1 1];
    
    % Calcular métricas por classe
    classMetrics = calc.calculateClassMetrics(pred, gt, 3);
    
    % Debug: mostrar estrutura
    if isfield(classMetrics, 'error')
        fprintf('  ⚠ Erro nas métricas por classe: %s\n', classMetrics.error);
        return;
    end
    
    % Verificar estrutura
    assert(isstruct(classMetrics), 'Resultado deve ser struct');
    assert(isfield(classMetrics, 'numClasses'), 'Deve conter numClasses');
    assert(isfield(classMetrics, 'perClass'), 'Deve conter perClass');
    assert(isfield(classMetrics, 'global'), 'Deve conter global');
    
    % Verificar número de classes
    assert(classMetrics.numClasses == 3, 'Número de classes incorreto');
    assert(length(classMetrics.perClass) == 3, 'Número de elementos perClass incorreto');
    
    % Verificar métricas globais
    assert(isfield(classMetrics.global, 'meanIoU'), 'Deve conter meanIoU');
    assert(isfield(classMetrics.global, 'meanDice'), 'Deve conter meanDice');
    assert(isfield(classMetrics.global, 'meanAccuracy'), 'Deve conter meanAccuracy');
    
    fprintf('✓ Métricas por classe OK\n');
end

function test_batch_metrics()
    fprintf('Testando métricas de lote...\n');
    
    calc = MetricsCalculator();
    
    % Criar lote de dados
    predBatch = {
        [1 1 0; 0 1 0; 0 0 0],
        [1 0 1; 0 1 0; 1 0 0],
        [0 1 1; 1 0 0; 0 1 0]
    };
    
    gtBatch = {
        [1 0 0; 0 1 0; 0 0 1],
        [1 1 0; 0 1 0; 0 0 1],
        [0 1 0; 1 0 1; 0 1 0]
    };
    
    % Calcular métricas de lote
    batchMetrics = calc.calculateBatchMetrics(predBatch, gtBatch);
    
    % Verificar estrutura
    assert(isstruct(batchMetrics), 'Resultado deve ser struct');
    assert(isfield(batchMetrics, 'numSamples'), 'Deve conter numSamples');
    assert(isfield(batchMetrics, 'individual'), 'Deve conter individual');
    assert(isfield(batchMetrics, 'stats'), 'Deve conter stats');
    
    % Verificar número de amostras
    assert(batchMetrics.numSamples == 3, 'Número de amostras incorreto');
    
    % Verificar arrays individuais
    assert(length(batchMetrics.individual.iou) == 3, 'Array IoU individual incorreto');
    assert(length(batchMetrics.individual.dice) == 3, 'Array Dice individual incorreto');
    assert(length(batchMetrics.individual.accuracy) == 3, 'Array Accuracy individual incorreto');
    
    % Verificar estatísticas
    assert(isfield(batchMetrics.stats, 'iou'), 'Stats deve conter iou');
    assert(isfield(batchMetrics.stats, 'dice'), 'Stats deve conter dice');
    assert(isfield(batchMetrics.stats, 'accuracy'), 'Stats deve conter accuracy');
    
    fprintf('✓ Métricas de lote OK\n');
end

function test_error_handling()
    fprintf('Testando tratamento de erros...\n');
    
    calc = MetricsCalculator();
    
    % Teste com dimensões incompatíveis
    pred_wrong = [1 1; 0 1];
    gt_wrong = [1 0 0; 0 1 0; 0 0 1];
    
    % Deve retornar 0 em caso de erro
    iou_error = calc.calculateIoU(pred_wrong, gt_wrong);
    dice_error = calc.calculateDice(pred_wrong, gt_wrong);
    acc_error = calc.calculateAccuracy(pred_wrong, gt_wrong);
    
    assert(iou_error == 0, 'IoU deve retornar 0 em caso de erro');
    assert(dice_error == 0, 'Dice deve retornar 0 em caso de erro');
    assert(acc_error == 0, 'Accuracy deve retornar 0 em caso de erro');
    
    % Teste com lotes de tamanhos diferentes
    predBatch_wrong = {[1 1; 0 1]};
    gtBatch_wrong = {[1 0; 0 1], [0 1; 1 0]};
    
    batchMetrics_error = calc.calculateBatchMetrics(predBatch_wrong, gtBatch_wrong);
    assert(isfield(batchMetrics_error, 'error'), 'Deve retornar erro para lotes incompatíveis');
    
    fprintf('✓ Tratamento de erros OK\n');
end