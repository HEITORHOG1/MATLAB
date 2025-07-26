function test_visualizer()
    % ========================================================================
    % TEST_VISUALIZER - Testes unitários para a classe Visualizer
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Testa as funcionalidades principais da classe Visualizer
    %
    % USO:
    %   >> test_visualizer()
    %
    % ========================================================================
    
    fprintf('🧪 Iniciando testes da classe Visualizer...\n');
    
    try
        % Teste 1: Construtor
        fprintf('📋 Teste 1: Construtor da classe...\n');
        visualizer = Visualizer('OutputDir', 'output/test_visualizations', 'AutoSave', false);
        assert(isa(visualizer, 'Visualizer'), 'Falha na criação do objeto Visualizer');
        fprintf('✅ Construtor funcionando corretamente\n');
        
        % Teste 2: Dados de teste
        fprintf('📋 Teste 2: Preparando dados de teste...\n');
        results = createTestResults();
        assert(isstruct(results), 'Falha na criação dos dados de teste');
        fprintf('✅ Dados de teste criados\n');
        
        % Teste 3: Gráfico de comparação
        fprintf('📋 Teste 3: Criando gráfico de comparação...\n');
        figHandle = visualizer.createComparisonPlot(results, 'Title', 'Teste de Comparação');
        if ~isempty(figHandle)
            close(figHandle);
            fprintf('✅ Gráfico de comparação criado com sucesso\n');
        else
            fprintf('⚠️ Gráfico de comparação retornou vazio\n');
        end
        
        % Teste 4: Boxplot de métricas
        fprintf('📋 Teste 4: Criando boxplot de métricas...\n');
        figHandle = visualizer.createMetricsBoxplot(results, 'Title', 'Teste de Boxplot');
        if ~isempty(figHandle)
            close(figHandle);
            fprintf('✅ Boxplot criado com sucesso\n');
        else
            fprintf('⚠️ Boxplot retornou vazio\n');
        end
        
        % Teste 5: Comparação de predições (dados simulados)
        fprintf('📋 Teste 5: Testando comparação de predições...\n');
        [images, pred1, pred2, gt] = createTestPredictions();
        figHandle = visualizer.createPredictionComparison(images, pred1, pred2, gt, ...
            'NumSamples', 2, 'Title', 'Teste de Predições');
        if ~isempty(figHandle)
            close(figHandle);
            fprintf('✅ Comparação de predições criada com sucesso\n');
        else
            fprintf('⚠️ Comparação de predições retornou vazio\n');
        end
        
        % Teste 6: Heatmap de diferenças
        fprintf('📋 Teste 6: Testando heatmap de diferenças...\n');
        figHandle = visualizer.createDifferenceHeatmap(pred1, pred2, gt, ...
            'NumSamples', 2, 'Title', 'Teste de Heatmap');
        if ~isempty(figHandle)
            close(figHandle);
            fprintf('✅ Heatmap de diferenças criado com sucesso\n');
        else
            fprintf('⚠️ Heatmap retornou vazio\n');
        end
        
        % Teste 7: Gráfico radar
        fprintf('📋 Teste 7: Testando gráfico radar...\n');
        figHandle = visualizer.createPerformanceRadarChart(results, 'Title', 'Teste Radar');
        if ~isempty(figHandle)
            close(figHandle);
            fprintf('✅ Gráfico radar criado com sucesso\n');
        else
            fprintf('⚠️ Gráfico radar retornou vazio\n');
        end
        
        fprintf('🎉 Todos os testes da classe Visualizer concluídos com sucesso!\n');
        
    catch ME
        fprintf('❌ Erro durante os testes: %s\n', ME.message);
        fprintf('📍 Arquivo: %s, Linha: %d\n', ME.stack(1).file, ME.stack(1).line);
    end
end

function results = createTestResults()
    % Cria dados de teste para os resultados
    
    % Métricas U-Net
    results.models.unet.metrics.iou.mean = 0.75;
    results.models.unet.metrics.iou.std = 0.08;
    results.models.unet.metrics.iou.min = 0.60;
    results.models.unet.metrics.iou.max = 0.90;
    results.models.unet.metrics.iou.values = 0.75 + 0.08 * randn(50, 1);
    
    results.models.unet.metrics.dice.mean = 0.80;
    results.models.unet.metrics.dice.std = 0.07;
    results.models.unet.metrics.dice.min = 0.65;
    results.models.unet.metrics.dice.max = 0.92;
    results.models.unet.metrics.dice.values = 0.80 + 0.07 * randn(50, 1);
    
    results.models.unet.metrics.accuracy.mean = 0.85;
    results.models.unet.metrics.accuracy.std = 0.05;
    results.models.unet.metrics.accuracy.min = 0.75;
    results.models.unet.metrics.accuracy.max = 0.95;
    results.models.unet.metrics.accuracy.values = 0.85 + 0.05 * randn(50, 1);
    
    results.models.unet.metrics.numSamples = 50;
    
    % Métricas Attention U-Net
    results.models.attentionUnet.metrics.iou.mean = 0.78;
    results.models.attentionUnet.metrics.iou.std = 0.07;
    results.models.attentionUnet.metrics.iou.min = 0.65;
    results.models.attentionUnet.metrics.iou.max = 0.92;
    results.models.attentionUnet.metrics.iou.values = 0.78 + 0.07 * randn(50, 1);
    
    results.models.attentionUnet.metrics.dice.mean = 0.82;
    results.models.attentionUnet.metrics.dice.std = 0.06;
    results.models.attentionUnet.metrics.dice.min = 0.70;
    results.models.attentionUnet.metrics.dice.max = 0.94;
    results.models.attentionUnet.metrics.dice.values = 0.82 + 0.06 * randn(50, 1);
    
    results.models.attentionUnet.metrics.accuracy.mean = 0.87;
    results.models.attentionUnet.metrics.accuracy.std = 0.04;
    results.models.attentionUnet.metrics.accuracy.min = 0.78;
    results.models.attentionUnet.metrics.accuracy.max = 0.96;
    results.models.attentionUnet.metrics.accuracy.values = 0.87 + 0.04 * randn(50, 1);
    
    results.models.attentionUnet.metrics.numSamples = 50;
    
    % Dados estatísticos
    results.statistical.iou.pValue = 0.03;
    results.statistical.iou.significant = true;
    results.statistical.iou.effectSize = 0.4;
    
    results.statistical.dice.pValue = 0.02;
    results.statistical.dice.significant = true;
    results.statistical.dice.effectSize = 0.3;
    
    results.statistical.accuracy.pValue = 0.08;
    results.statistical.accuracy.significant = false;
    results.statistical.accuracy.effectSize = 0.2;
end

function [images, pred1, pred2, gt] = createTestPredictions()
    % Cria dados de teste para predições
    
    % Dimensões das imagens
    height = 64;
    width = 64;
    channels = 3;
    numSamples = 4;
    
    % Imagens originais (simuladas)
    images = rand(height, width, channels, numSamples);
    
    % Ground truth (máscaras binárias simuladas)
    gt = zeros(height, width, numSamples);
    for i = 1:numSamples
        % Criar formas geométricas simples
        center_x = randi([20, width-20]);
        center_y = randi([20, height-20]);
        radius = randi([10, 20]);
        
        [X, Y] = meshgrid(1:width, 1:height);
        mask = (X - center_x).^2 + (Y - center_y).^2 <= radius^2;
        gt(:, :, i) = double(mask);
    end
    
    % Predições U-Net (com algum ruído)
    pred1 = gt + 0.1 * randn(size(gt));
    pred1 = max(0, min(1, pred1)); % Clamp entre 0 e 1
    
    % Predições Attention U-Net (ligeiramente melhores)
    pred2 = gt + 0.08 * randn(size(gt));
    pred2 = max(0, min(1, pred2)); % Clamp entre 0 e 1
end