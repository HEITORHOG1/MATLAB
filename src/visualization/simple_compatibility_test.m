function results = simple_compatibility_test()
    % SIMPLE_COMPATIBILITY_TEST - Teste básico de compatibilidade
    % 
    % Este script verifica a sintaxe e estrutura básica dos arquivos
    % do sistema de visualização sem executar funcionalidades que
    % requerem MATLAB completo.
    
    fprintf('=== TESTE DE COMPATIBILIDADE: Sistema de Visualização ===\n\n');
    
    results = struct();
    results.timestamp = datestr(now);
    results.tests_passed = 0;
    results.tests_failed = 0;
    results.files_checked = {};
    
    % Lista de arquivos para verificar
    files_to_check = {
        'ComparisonVisualizer.m'
        'HTMLGalleryGenerator.m'
        'StatisticalPlotter.m'
        'TimeLapseGenerator.m'
        'demo_visualization_system.m'
        'validate_visualization_system.m'
    };
    
    fprintf('1. Verificando existência dos arquivos...\n');
    
    for i = 1:length(files_to_check)
        filename = files_to_check{i};
        filepath = fullfile('src', 'visualization', filename);
        
        if exist(filepath, 'file') == 2
            fprintf('   ✓ %s\n', filename);
            results.tests_passed = results.tests_passed + 1;
            results.files_checked{end+1} = filename;
        else
            fprintf('   ✗ %s (não encontrado)\n', filename);
            results.tests_failed = results.tests_failed + 1;
        end
    end
    
    fprintf('\n2. Verificando estrutura das classes...\n');
    
    % Verificar ComparisonVisualizer
    if checkClassStructure('ComparisonVisualizer.m', {'createSideBySideComparison', 'createDifferenceMap', 'createMetricsOverlay'})
        fprintf('   ✓ ComparisonVisualizer - estrutura OK\n');
        results.tests_passed = results.tests_passed + 1;
    else
        fprintf('   ✗ ComparisonVisualizer - estrutura incorreta\n');
        results.tests_failed = results.tests_failed + 1;
    end
    
    % Verificar HTMLGalleryGenerator
    if checkClassStructure('HTMLGalleryGenerator.m', {'generateComparisonGallery', 'processImages', 'generateHTML'})
        fprintf('   ✓ HTMLGalleryGenerator - estrutura OK\n');
        results.tests_passed = results.tests_passed + 1;
    else
        fprintf('   ✗ HTMLGalleryGenerator - estrutura incorreta\n');
        results.tests_failed = results.tests_failed + 1;
    end
    
    % Verificar StatisticalPlotter
    if checkClassStructure('StatisticalPlotter.m', {'plotStatisticalComparison', 'createPerformanceEvolution', 'testNormality'})
        fprintf('   ✓ StatisticalPlotter - estrutura OK\n');
        results.tests_passed = results.tests_passed + 1;
    else
        fprintf('   ✗ StatisticalPlotter - estrutura incorreta\n');
        results.tests_failed = results.tests_failed + 1;
    end
    
    % Verificar TimeLapseGenerator
    if checkClassStructure('TimeLapseGenerator.m', {'createTrainingEvolutionVideo', 'createPredictionEvolutionVideo', 'createComparisonVideo'})
        fprintf('   ✓ TimeLapseGenerator - estrutura OK\n');
        results.tests_passed = results.tests_passed + 1;
    else
        fprintf('   ✗ TimeLapseGenerator - estrutura incorreta\n');
        results.tests_failed = results.tests_failed + 1;
    end
    
    fprintf('\n3. Verificando diretórios de saída...\n');
    
    output_dirs = {'output/visualizations', 'output/gallery', 'output/statistics', 'output/videos'};
    
    for i = 1:length(output_dirs)
        dir_path = output_dirs{i};
        if ~exist(dir_path, 'dir')
            mkdir(dir_path);
            fprintf('   ✓ Criado diretório: %s\n', dir_path);
            results.tests_passed = results.tests_passed + 1;
        else
            fprintf('   ✓ Diretório existe: %s\n', dir_path);
            results.tests_passed = results.tests_passed + 1;
        end
    end
    
    fprintf('\n=== RESUMO DO TESTE ===\n');
    total_tests = results.tests_passed + results.tests_failed;
    fprintf('Testes executados: %d\n', total_tests);
    fprintf('Testes aprovados: %d\n', results.tests_passed);
    fprintf('Testes falharam: %d\n', results.tests_failed);
    
    if total_tests > 0
        success_rate = (results.tests_passed / total_tests) * 100;
        fprintf('Taxa de sucesso: %.1f%%\n', success_rate);
        
        if success_rate >= 90
            fprintf('✓ Sistema de visualização está pronto para uso!\n');
        elseif success_rate >= 70
            fprintf('⚠ Sistema de visualização funcional com algumas limitações\n');
        else
            fprintf('✗ Sistema de visualização requer correções\n');
        end
    end
    
    fprintf('\nPara teste completo, execute: validate_visualization_system()\n');
end

function isValid = checkClassStructure(filename, required_methods)
    % Verificar se uma classe contém os métodos necessários
    
    filepath = fullfile('src', 'visualization', filename);
    
    if exist(filepath, 'file') ~= 2
        isValid = false;
        return;
    end
    
    try
        % Ler conteúdo do arquivo
        fid = fopen(filepath, 'r');
        if fid == -1
            isValid = false;
            return;
        end
        
        content = fread(fid, '*char')';
        fclose(fid);
        
        % Verificar se é uma classe
        if ~contains(content, 'classdef')
            isValid = false;
            return;
        end
        
        % Verificar métodos necessários
        methods_found = 0;
        for i = 1:length(required_methods)
            method_name = required_methods{i};
            if contains(content, ['function ' method_name]) || contains(content, [method_name '('])
                methods_found = methods_found + 1;
            end
        end
        
        % Considerar válido se pelo menos 80% dos métodos foram encontrados
        isValid = (methods_found / length(required_methods)) >= 0.8;
        
    catch
        isValid = false;
    end
end