% Simple validation script for performance optimizations
fprintf('🔍 Validação Simples das Otimizações de Performance\n');
fprintf('=================================================\n\n');

passed = 0;
total = 0;

% Test 1: Check if performance classes exist
total = total + 1;
fprintf('📋 Teste 1: Verificar se classes de performance existem\n');
try
    if exist('src/utils/ResourceMonitor.m', 'file') && ...
       exist('src/utils/PerformanceProfiler.m', 'file') && ...
       exist('src/utils/SystemMonitor.m', 'file')
        fprintf('✅ PASSOU - Todas as classes de performance existem\n\n');
        passed = passed + 1;
    else
        fprintf('❌ FALHOU - Classes de performance não encontradas\n\n');
    end
catch
    fprintf('❌ FALHOU - Erro ao verificar classes\n\n');
end

% Test 2: Check if DataLoader has lazy loading properties
total = total + 1;
fprintf('📋 Teste 2: Verificar propriedades de lazy loading no DataLoader\n');
try
    dataloader_content = fileread('src/data/DataLoader.m');
    if contains(dataloader_content, 'lazyLoadingEnabled') && ...
       contains(dataloader_content, 'maxMemoryUsage') && ...
       contains(dataloader_content, 'lazyLoadSample')
        fprintf('✅ PASSOU - DataLoader tem propriedades de lazy loading\n\n');
        passed = passed + 1;
    else
        fprintf('❌ FALHOU - Propriedades de lazy loading não encontradas\n\n');
    end
catch
    fprintf('❌ FALHOU - Erro ao verificar DataLoader\n\n');
end

% Test 3: Check if DataPreprocessor has cache optimization
total = total + 1;
fprintf('📋 Teste 3: Verificar otimizações de cache no DataPreprocessor\n');
try
    preprocessor_content = fileread('src/data/DataPreprocessor.m');
    if contains(preprocessor_content, 'intelligentCacheCleanup') && ...
       contains(preprocessor_content, 'optimizeMemoryUsage') && ...
       contains(preprocessor_content, 'getCacheStats')
        fprintf('✅ PASSOU - DataPreprocessor tem otimizações de cache\n\n');
        passed = passed + 1;
    else
        fprintf('❌ FALHOU - Otimizações de cache não encontradas\n\n');
    end
catch
    fprintf('❌ FALHOU - Erro ao verificar DataPreprocessor\n\n');
end

% Test 4: Check if MainInterface has monitoring integration
total = total + 1;
fprintf('📋 Teste 4: Verificar integração de monitoramento na MainInterface\n');
try
    interface_content = fileread('src/core/MainInterface.m');
    if contains(interface_content, 'systemMonitor') && ...
       contains(interface_content, 'startSystemMonitoring') && ...
       contains(interface_content, 'displaySystemStatus')
        fprintf('✅ PASSOU - MainInterface tem integração de monitoramento\n\n');
        passed = passed + 1;
    else
        fprintf('❌ FALHOU - Integração de monitoramento não encontrada\n\n');
    end
catch
    fprintf('❌ FALHOU - Erro ao verificar MainInterface\n\n');
end

% Test 5: Check if documentation is updated
total = total + 1;
fprintf('📋 Teste 5: Verificar se documentação foi atualizada\n');
try
    if exist('docs/api_reference.md', 'file') && exist('docs/user_guide.md', 'file')
        api_content = fileread('docs/api_reference.md');
        guide_content = fileread('docs/user_guide.md');
        
        if contains(api_content, 'ResourceMonitor') && ...
           contains(api_content, 'PerformanceProfiler') && ...
           contains(guide_content, 'Monitoramento') && ...
           contains(guide_content, 'Performance')
            fprintf('✅ PASSOU - Documentação atualizada com novas funcionalidades\n\n');
            passed = passed + 1;
        else
            fprintf('❌ FALHOU - Documentação não contém novas funcionalidades\n\n');
        end
    else
        fprintf('❌ FALHOU - Arquivos de documentação não encontrados\n\n');
    end
catch
    fprintf('❌ FALHOU - Erro ao verificar documentação\n\n');
end

% Summary
fprintf('📊 RESUMO DA VALIDAÇÃO\n');
fprintf('=====================\n');
fprintf('Total de testes: %d\n', total);
fprintf('Testes aprovados: %d\n', passed);
fprintf('Testes falharam: %d\n', total - passed);
fprintf('Taxa de sucesso: %.1f%%\n', (passed / total) * 100);

if passed == total
    fprintf('\n🎉 TODOS OS TESTES PASSARAM!\n');
    fprintf('✅ Otimizações de performance implementadas com sucesso\n');
    fprintf('✅ Sistema de monitoramento integrado\n');
    fprintf('✅ Documentação atualizada\n');
else
    fprintf('\n⚠️  ALGUNS TESTES FALHARAM\n');
    fprintf('Verifique os erros acima para mais detalhes\n');
end

fprintf('\n📝 Validação concluída em: %s\n', datestr(now));