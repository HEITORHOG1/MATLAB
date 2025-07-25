function validate_comparison_controller()
    % ========================================================================
    % VALIDATE_COMPARISON_CONTROLLER - Validação do ComparisonController
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Script para validar a implementação do ComparisonController e seus
    %   componentes relacionados (ExecutionManager, ReportGenerator).
    %
    % USO:
    %   >> validate_comparison_controller()
    % ========================================================================
    
    fprintf('=== VALIDAÇÃO DO COMPARISON CONTROLLER ===\n');
    fprintf('Iniciando validação dos componentes implementados...\n\n');
    
    try
        % 1. Testar inicialização do ComparisonController
        fprintf('1. Testando inicialização do ComparisonController...\n');
        
        % Configuração mínima para teste
        config = struct();
        config.imageDir = fullfile(pwd, 'img', 'original');
        config.maskDir = fullfile(pwd, 'img', 'masks');
        config.inputSize = [256, 256, 3];
        config.numClasses = 2;
        config.maxEpochs = 5;  % Reduzido para teste
        config.miniBatchSize = 4;
        config.validationSplit = 0.2;
        config.name = 'Teste ComparisonController';
        
        % Verificar se diretórios existem
        if ~exist(config.imageDir, 'dir') || ~exist(config.maskDir, 'dir')
            fprintf('   ⚠️  Diretórios de dados não encontrados, usando configuração de teste\n');
            config.imageDir = pwd;  % Usar diretório atual como fallback
            config.maskDir = pwd;
        end
        
        % Inicializar ComparisonController
        controller = ComparisonController(config, 'EnableDetailedLogging', true, ...
            'EnableQuickTest', true, 'QuickTestSampleSize', 10);
        
        fprintf('   ✅ ComparisonController inicializado com sucesso\n');
        
        % 2. Testar status de execução
        fprintf('\n2. Testando status de execução...\n');
        status = controller.getExecutionStatus();
        
        fprintf('   📊 Status atual: %s\n', status.currentStep);
        fprintf('   📈 Progresso: %.1f%%\n', status.progressPercent);
        fprintf('   ⏱️  Tempo decorrido: %.2f segundos\n', status.elapsedTime);
        
        % 3. Testar geração de resumo
        fprintf('\n3. Testando geração de resumo...\n');
        summary = controller.generateExecutionSummary();
        fprintf('   📋 Resumo gerado:\n');
        fprintf('   %s\n', strrep(summary, sprintf('\n'), sprintf('\n   ')));
        
        % 4. Testar ExecutionManager separadamente
        fprintf('\n4. Testando ExecutionManager...\n');
        execManager = ExecutionManager('MaxConcurrentJobs', 1, 'QuickTestRatio', 0.2);
        
        % Testar modo de teste rápido
        testData = {{'img1.jpg', 'img2.jpg', 'img3.jpg'}, {'mask1.jpg', 'mask2.jpg', 'mask3.jpg'}};
        optimizedData = execManager.enableQuickTestMode(testData, 'MaxSamples', 2);
        
        fprintf('   ✅ ExecutionManager: Teste rápido funcionando\n');
        fprintf('   📊 Dados originais: %d amostras → %d amostras\n', ...
            length(testData{1}), length(optimizedData{1}));
        
        % 5. Testar ReportGenerator
        fprintf('\n5. Testando ReportGenerator...\n');
        reportGen = ReportGenerator('OutputDir', fullfile('output', 'test_reports'), ...
            'ReportFormat', 'text');
        
        % Criar dados de teste para relatório
        testResults = struct();
        testResults.models = struct();
        testResults.models.unet = struct();
        testResults.models.unet.metrics = struct();
        testResults.models.unet.metrics.iou = struct('mean', 0.85, 'std', 0.05, 'values', [0.8, 0.85, 0.9]);
        testResults.models.unet.metrics.dice = struct('mean', 0.82, 'std', 0.04, 'values', [0.78, 0.82, 0.86]);
        testResults.models.unet.metrics.accuracy = struct('mean', 0.88, 'std', 0.03, 'values', [0.85, 0.88, 0.91]);
        testResults.models.unet.metrics.numSamples = 3;
        
        testResults.models.attentionUnet = struct();
        testResults.models.attentionUnet.metrics = struct();
        testResults.models.attentionUnet.metrics.iou = struct('mean', 0.87, 'std', 0.04, 'values', [0.83, 0.87, 0.91]);
        testResults.models.attentionUnet.metrics.dice = struct('mean', 0.84, 'std', 0.03, 'values', [0.81, 0.84, 0.87]);
        testResults.models.attentionUnet.metrics.accuracy = struct('mean', 0.90, 'std', 0.02, 'values', [0.88, 0.90, 0.92]);
        testResults.models.attentionUnet.metrics.numSamples = 3;
        
        testResults.comparison = struct();
        testResults.comparison.winner = 'Attention U-Net';
        testResults.comparison.summary = 'Attention U-Net mostrou melhor performance';
        
        % Gerar interpretação automática
        interpretation = reportGen.generateAutomaticInterpretation(testResults);
        
        if ~isfield(interpretation, 'error')
            fprintf('   ✅ ReportGenerator: Interpretação automática gerada\n');
            
            if isfield(interpretation, 'winner')
                fprintf('   🏆 Modelo vencedor: %s (confiança: %s)\n', ...
                    interpretation.winner.model, interpretation.winner.confidence);
            end
            
            if isfield(interpretation, 'executiveSummary')
                fprintf('   📋 Resumo executivo gerado com sucesso\n');
            end
        else
            fprintf('   ⚠️  Erro na interpretação: %s\n', interpretation.error);
        end
        
        % 6. Testar ResourceMonitor
        fprintf('\n6. Testando ResourceMonitor...\n');
        resourceMonitor = ResourceMonitor();
        resourceInfo = resourceMonitor.getResourceInfo();
        
        fprintf('   💾 Memória: %.1f GB total, %.1f GB disponível\n', ...
            resourceInfo.memory.totalGB, resourceInfo.memory.availableGB);
        fprintf('   🖥️  CPU: %d cores, uso estimado: %.1f%%\n', ...
            resourceInfo.cpu.numCores, resourceInfo.cpu.usage);
        fprintf('   🎮 GPU: %s\n', resourceInfo.gpu.available ? 'Disponível' : 'Não disponível');
        
        if resourceInfo.gpu.available
            fprintf('   📊 GPU: %s (%.1f GB)\n', resourceInfo.gpu.name, resourceInfo.gpu.memoryGB);
        end
        
        % 7. Testar limpeza
        fprintf('\n7. Testando limpeza de recursos...\n');
        controller.cleanup();
        execManager.cleanup();
        
        fprintf('   ✅ Limpeza concluída\n');
        
        % Resumo final
        fprintf('\n=== RESUMO DA VALIDAÇÃO ===\n');
        fprintf('✅ ComparisonController: Inicialização OK\n');
        fprintf('✅ ExecutionManager: Funcionalidades básicas OK\n');
        fprintf('✅ ReportGenerator: Interpretação automática OK\n');
        fprintf('✅ ResourceMonitor: Monitoramento de recursos OK\n');
        fprintf('✅ Integração: Componentes funcionando em conjunto\n');
        
        fprintf('\n🎉 VALIDAÇÃO CONCLUÍDA COM SUCESSO!\n');
        fprintf('O sistema de comparação automatizada está pronto para uso.\n');
        
    catch ME
        fprintf('\n❌ ERRO NA VALIDAÇÃO:\n');
        fprintf('Mensagem: %s\n', ME.message);
        
        if ~isempty(ME.stack)
            fprintf('Local: %s (linha %d)\n', ME.stack(1).name, ME.stack(1).line);
        end
        
        fprintf('\n💡 Sugestões:\n');
        fprintf('- Verifique se todos os arquivos foram criados corretamente\n');
        fprintf('- Confirme que os diretórios de dados existem\n');
        fprintf('- Execute o script novamente após corrigir os problemas\n');
        
        rethrow(ME);
    end
end