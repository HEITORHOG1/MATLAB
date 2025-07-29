function test_visualization_fix()
    % Test script to verify the visualization function fixes
    % Tests the categorical to uint8 conversions and error handling
    
    fprintf('=== TESTE DA FUNÇÃO DE VISUALIZAÇÃO CORRIGIDA ===\n');
    
    try
        % Add necessary paths
        addpath('src/utils');
        addpath('legacy');
        
        % Test 1: Verify VisualizationHelper is available
        fprintf('Teste 1: Verificando disponibilidade do VisualizationHelper...\n');
        if exist('VisualizationHelper', 'class')
            fprintf('✓ VisualizationHelper encontrado\n');
        else
            error('VisualizationHelper não encontrado');
        end
        
        % Test 2: Test categorical data preparation
        fprintf('Teste 2: Testando preparação de dados categorical...\n');
        
        % Create test categorical data
        test_mask = categorical([0, 1; 1, 0], [0, 1], ["background", "foreground"]);
        test_img = rand(2, 2, 3);
        test_pred = categorical([1, 0; 0, 1], [0, 1], ["background", "foreground"]);
        
        % Test data preparation
        [img_visual, mask_visual, pred_visual] = VisualizationHelper.prepareComparisonData(test_img, test_mask, test_pred);
        
        fprintf('✓ Preparação de dados categorical bem-sucedida\n');
        fprintf('  - Imagem: %s, tamanho: %s\n', class(img_visual), mat2str(size(img_visual)));
        fprintf('  - Máscara: %s, tamanho: %s\n', class(mask_visual), mat2str(size(mask_visual)));
        fprintf('  - Predição: %s, tamanho: %s\n', class(pred_visual), mat2str(size(pred_visual)));
        
        % Test 3: Test safe imshow functionality
        fprintf('Teste 3: Testando safeImshow...\n');
        
        figure('Visible', 'off'); % Create invisible figure for testing
        
        % Test with different data types
        subplot(2, 2, 1);
        success1 = VisualizationHelper.safeImshow(test_img);
        if success1
            fprintf('  - Imagem RGB: Sucesso\n');
        else
            fprintf('  - Imagem RGB: Falha\n');
        end
        
        subplot(2, 2, 2);
        success2 = VisualizationHelper.safeImshow(test_mask);
        if success2
            fprintf('  - Máscara categorical: Sucesso\n');
        else
            fprintf('  - Máscara categorical: Falha\n');
        end
        
        subplot(2, 2, 3);
        success3 = VisualizationHelper.safeImshow(mask_visual);
        if success3
            fprintf('  - Máscara preparada: Sucesso\n');
        else
            fprintf('  - Máscara preparada: Falha\n');
        end
        
        subplot(2, 2, 4);
        % Test difference calculation
        try
            diff = abs(double(mask_visual) - double(pred_visual));
            success4 = VisualizationHelper.safeImshow(diff);
            if success4
                fprintf('  - Diferença: Sucesso\n');
            else
                fprintf('  - Diferença: Falha\n');
            end
        catch ME
            fprintf('  - Diferença: Falha (%s)\n', ME.message);
            success4 = false;
        end
        
        close(gcf); % Close test figure
        
        % Test 4: Test error handling
        fprintf('Teste 4: Testando tratamento de erros...\n');
        
        % Test with empty data
        figure('Visible', 'off');
        success_empty = VisualizationHelper.safeImshow([]);
        if success_empty
            fprintf('  - Dados vazios: Inesperado sucesso\n');
        else
            fprintf('  - Dados vazios: Falha esperada\n');
        end
        close(gcf);
        
        % Test with invalid data
        figure('Visible', 'off');
        try
            success_invalid = VisualizationHelper.safeImshow('invalid_data');
            if success_invalid
                fprintf('  - Dados inválidos: Inesperado sucesso\n');
            else
                fprintf('  - Dados inválidos: Falha esperada\n');
            end
        catch
            fprintf('  - Dados inválidos: Erro capturado corretamente\n');
        end
        close(gcf);
        
        % Summary
        fprintf('\n=== RESUMO DOS TESTES ===\n');
        total_tests = 4;
        passed_tests = 0;
        
        if exist('VisualizationHelper', 'class')
            passed_tests = passed_tests + 1;
        end
        
        if exist('img_visual', 'var') && exist('mask_visual', 'var') && exist('pred_visual', 'var')
            passed_tests = passed_tests + 1;
        end
        
        if success1 && success2 && success3
            passed_tests = passed_tests + 1;
        end
        
        if ~success_empty % Empty data should fail
            passed_tests = passed_tests + 1;
        end
        
        fprintf('Testes aprovados: %d/%d\n', passed_tests, total_tests);
        
        if passed_tests == total_tests
            fprintf('✓ TODOS OS TESTES PASSARAM - Visualização corrigida com sucesso!\n');
        else
            fprintf('⚠ Alguns testes falharam - Verificar implementação\n');
        end
        
    catch ME
        fprintf('❌ ERRO no teste: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for k = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(k).name, ME.stack(k).line);
        end
    end
    
    fprintf('\n=== TESTE CONCLUÍDO ===\n');
end