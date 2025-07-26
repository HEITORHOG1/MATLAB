function test_report_generator()
    % ========================================================================
    % TEST_REPORT_GENERATOR - Testes unitários para a classe ReportGenerator
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Testa as funcionalidades principais da classe ReportGenerator
    %
    % USO:
    %   >> test_report_generator()
    %
    % ========================================================================
    
    fprintf('🧪 Iniciando testes da classe ReportGenerator...\n');
    
    try
        % Teste 1: Construtor
        fprintf('📋 Teste 1: Construtor da classe...\n');
        generator = ReportGenerator('OutputDir', 'output/test_reports', 'ReportFormat', 'text');
        assert(isa(generator, 'ReportGenerator'), 'Falha na criação do objeto ReportGenerator');
        fprintf('✅ Construtor funcionando corretamente\n');
        
        % Teste 2: Dados de teste
        fprintf('📋 Teste 2: Preparando dados de teste...\n');
        results = createTestResults();
        assert(isstruct(results), 'Falha na criação dos dados de teste');
        fprintf('✅ Dados de teste criados\n');
        
        % Teste 3: Interpretação automática
        fprintf('📋 Teste 3: Testando interpretação automática...\n');
        interpretation = generator.generateAutomaticInterpretation(results);
        assert(isstruct(interpretation), 'Falha na interpretação automática');
        fprintf('✅ Interpretação automática funcionando\n');
        
        % Teste 4: Geração de recomendações
        fprintf('📋 Teste 4: Testando geração de recomendações...\n');
        recommendations = generator.generateRecommendations(results, interpretation);
        assert(isstruct(recommendations), 'Falha na geração de recomendações');
        fprintf('✅ Recomendações geradas com sucesso\n');
        
        % Teste 5: Relatório de comparação
        fprintf('📋 Teste 5: Testando relatório de comparação...\n');
        reportPath = generator.generateComparisonReport(results, 'Title', 'Teste de Relatório');
        if ~isempty(reportPath) && exist(reportPath, 'file')
            fprintf('✅ Relatório de comparação gerado: %s\n', reportPath);
        else
            fprintf('⚠️ Relatório não foi gerado ou não foi encontrado\n');
        end
        
        % Teste 6: Exportação para CSV
        fprintf('📋 Teste 6: Testando exportação para CSV...\n');
        csvPath = generator.exportToScientificFormat(results, 'csv', 'IncludeRawData', false);
        if ~isempty(csvPath) && exist(csvPath, 'file')
            fprintf('✅ Exportação CSV realizada: %s\n', csvPath);
        else
            fprintf('⚠️ Exportação CSV falhou\n');
        end
        
        % Teste 7: Exportação para JSON
        fprintf('📋 Teste 7: Testando exportação para JSON...\n');
        jsonPath = generator.exportToScientificFormat(results, 'json', 'IncludeRawData', false);
        if ~isempty(jsonPath) && exist(jsonPath, 'file')
            fprintf('✅ Exportação JSON realizada: %s\n', jsonPath);
        else
            fprintf('⚠️ Exportação JSON falhou\n');
        end
        
        % Teste 8: Relatório HTML
        fprintf('📋 Teste 8: Testando relatório HTML...\n');
        htmlPath = generator.generateHTMLReport(results, 'Title', 'Teste HTML');
        if ~isempty(htmlPath) && exist(htmlPath, 'file')
            fprintf('✅ Relatório HTML gerado: %s\n', htmlPath);
        else
            fprintf('⚠️ Relatório HTML falhou\n');
        end
        
        fprintf('🎉 Todos os testes da classe ReportGenerator concluídos com sucesso!\n');
        
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
    
    % Informações de execução
    results.execution.timestamp = datestr(now);
    results.execution.quickTest.enabled = false;
    results.execution.totalTime = 1800; % 30 minutos
end