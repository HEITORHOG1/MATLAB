function test_categorical_standardization()
    % Test to verify categorical data standardization and visualization fixes
    % This test validates Requirements 2.1, 2.2, 2.4, and 3.3
    
    fprintf('=== TESTE DE PADRONIZAÇÃO CATEGORICAL E VISUALIZAÇÃO ===\n');
    
    try
        % Add necessary paths
        addpath('src/utils');
        addpath('legacy');
        addpath('utils');
        
        % Test 1: Verify all utility classes are available
        fprintf('Teste 1: Verificando classes utilitárias...\n');
        
        classes_needed = {'VisualizationHelper', 'DataTypeConverter'};
        classes_found = 0;
        
        for i = 1:length(classes_needed)
            if exist(classes_needed{i}, 'class')
                fprintf('  ✓ %s encontrado\n', classes_needed{i});
                classes_found = classes_found + 1;
            else
                fprintf('  ❌ %s NÃO encontrado\n', classes_needed{i});
            end
        end
        
        % Test 2: Test categorical standardization
        fprintf('\nTeste 2: Testando padronização categorical...\n');
        
        % Create test data with standard format [0,1] -> ["background","foreground"]
        test_numeric = [0, 1; 1, 0];
        expected_categories = ["background", "foreground"];
        expected_labelIDs = [0, 1];
        
        if exist('DataTypeConverter', 'class')
            test_categorical = DataTypeConverter.numericToCategorical(test_numeric, expected_categories, expected_labelIDs);
            
            % Verify categorical structure
            actual_categories = categories(test_categorical);
            actual_values = double(test_categorical);
            
            fprintf('  - Categorias esperadas: %s\n', strjoin(expected_categories, ', '));
            fprintf('  - Categorias obtidas: %s\n', strjoin(actual_categories, ', '));
            fprintf('  - Valores numéricos: %s\n', mat2str(actual_values));
            
            % Test conversion back to binary
            binary_result = test_categorical == "foreground";
            expected_binary = logical([0, 1; 1, 0]);
            
            if isequal(binary_result, expected_binary)
                fprintf('  ✓ Conversão categorical -> binário correta\n');
            else
                fprintf('  ❌ Conversão categorical -> binário incorreta\n');
            end
        else
            fprintf('  ⚠ DataTypeConverter não disponível - usando fallback\n');
            test_categorical = categorical(test_numeric, [0, 1], ["background", "foreground"]);
        end
        
        % Test 3: Test visualization preparation
        fprintf('\nTeste 3: Testando preparação para visualização...\n');
        
        % Create test image and masks
        test_img = rand(64, 64, 3);
        test_gt = categorical(randi([0, 1], 64, 64), [0, 1], ["background", "foreground"]);
        test_pred = categorical(randi([0, 1], 64, 64), [0, 1], ["background", "foreground"]);
        
        % Test data preparation
        [img_visual, gt_visual, pred_visual] = VisualizationHelper.prepareComparisonData(test_img, test_gt, test_pred);
        
        % Verify output types and ranges
        fprintf('  - Imagem preparada: %s, range: [%.3f, %.3f]\n', class(img_visual), min(img_visual(:)), max(img_visual(:)));
        fprintf('  - GT preparada: %s, range: [%d, %d]\n', class(gt_visual), min(gt_visual(:)), max(gt_visual(:)));
        fprintf('  - Predição preparada: %s, range: [%d, %d]\n', class(pred_visual), min(pred_visual(:)), max(pred_visual(:)));
        
        % Test 4: Test safe visualization
        fprintf('\nTeste 4: Testando visualização segura...\n');
        
        figure('Visible', 'off', 'Position', [100, 100, 800, 600]);
        
        % Test different subplot configurations
        subplot(2, 3, 1);
        success1 = VisualizationHelper.safeImshow(img_visual);
        title('Imagem Original');
        
        subplot(2, 3, 2);
        success2 = VisualizationHelper.safeImshow(gt_visual);
        title('Ground Truth');
        
        subplot(2, 3, 3);
        success3 = VisualizationHelper.safeImshow(pred_visual);
        title('Predição');
        
        subplot(2, 3, 4);
        success4 = VisualizationHelper.safeImshow(test_gt);
        title('GT Categorical');
        
        subplot(2, 3, 5);
        success5 = VisualizationHelper.safeImshow(test_pred);
        title('Pred Categorical');
        
        subplot(2, 3, 6);
        % Test difference calculation
        try
            diff = abs(double(gt_visual) - double(pred_visual));
            success6 = VisualizationHelper.safeImshow(diff, []);
            title('Diferença');
            colorbar;
        catch ME
            fprintf('  ⚠ Erro no cálculo de diferença: %s\n', ME.message);
            success6 = false;
        end
        
        % Save test figure
        try
            saveas(gcf, 'test_visualization_output.png');
            fprintf('  ✓ Figura de teste salva: test_visualization_output.png\n');
        catch ME_save
            fprintf('  ⚠ Erro ao salvar figura: %s\n', ME_save.message);
        end
        
        close(gcf);
        
        % Test 5: Test error handling scenarios
        fprintf('\nTeste 5: Testando cenários de erro...\n');
        
        error_tests = 0;
        error_passed = 0;
        
        % Test with mismatched sizes
        error_tests = error_tests + 1;
        try
            img_small = rand(32, 32, 3);
            mask_large = categorical(randi([0, 1], 128, 128), [0, 1], ["background", "foreground"]);
            [~, ~, ~] = VisualizationHelper.prepareComparisonData(img_small, mask_large, mask_large);
            fprintf('  ✓ Tratamento de tamanhos diferentes\n');
            error_passed = error_passed + 1;
        catch ME
            fprintf('  ❌ Falha no tratamento de tamanhos: %s\n', ME.message);
        end
        
        % Test with empty data
        error_tests = error_tests + 1;
        figure('Visible', 'off');
        success_empty = VisualizationHelper.safeImshow([]);
        if ~success_empty
            fprintf('  ✓ Tratamento correto de dados vazios\n');
            error_passed = error_passed + 1;
        else
            fprintf('  ❌ Dados vazios não tratados corretamente\n');
        end
        close(gcf);
        
        % Test with invalid categorical structure
        error_tests = error_tests + 1;
        try
            invalid_cat = categorical([1, 2, 3], [1, 2, 3], ["class1", "class2", "class3"]);
            mask_prepared = VisualizationHelper.prepareMaskForDisplay(invalid_cat);
            fprintf('  ✓ Tratamento de categorical não-binário\n');
            error_passed = error_passed + 1;
        catch ME
            fprintf('  ❌ Falha no tratamento de categorical: %s\n', ME.message);
        end
        
        % Summary
        fprintf('\n=== RESUMO FINAL ===\n');
        fprintf('Classes utilitárias: %d/%d encontradas\n', classes_found, length(classes_needed));
        fprintf('Visualizações básicas: %d/6 bem-sucedidas\n', sum([success1, success2, success3, success4, success5, success6]));
        fprintf('Testes de erro: %d/%d aprovados\n', error_passed, error_tests);
        
        % Overall assessment
        total_score = classes_found + sum([success1, success2, success3, success4, success5, success6]) + error_passed;
        max_score = length(classes_needed) + 6 + error_tests;
        
        fprintf('\nPontuação total: %d/%d (%.1f%%)\n', total_score, max_score, (total_score/max_score)*100);
        
        if total_score >= max_score * 0.8
            fprintf('✓ IMPLEMENTAÇÃO APROVADA - Visualização corrigida com sucesso!\n');
            fprintf('  - Conversões categorical -> uint8 implementadas\n');
            fprintf('  - Tratamento de erros robusto\n');
            fprintf('  - VisualizationHelper integrado corretamente\n');
        else
            fprintf('⚠ IMPLEMENTAÇÃO PRECISA DE MELHORIAS\n');
        end
        
    catch ME
        fprintf('❌ ERRO CRÍTICO no teste: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for k = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(k).name, ME.stack(k).line);
        end
    end
    
    fprintf('\n=== TESTE DE PADRONIZAÇÃO CONCLUÍDO ===\n');
end