function test_categorical_conversion_fix()
    % ========================================================================
    % TESTE DA CORREÇÃO DE CONVERSÃO CATEGORICAL - TASK 7
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Testa se a correção da lógica de conversão categorical para binário
    %   está funcionando corretamente nas funções de métricas
    % ========================================================================
    
    fprintf('=== TESTE DA CORREÇÃO DE CONVERSÃO CATEGORICAL ===\n');
    
    try
        % Criar dados de teste categorical
        % Usando labelIDs [0,1] e classNames ["background","foreground"]
        test_pred = categorical([0 0 1 1; 0 1 1 1], [0,1], ["background","foreground"]);
        test_gt = categorical([0 1 1 1; 0 0 1 1], [0,1], ["background","foreground"]);
        
        fprintf('Dados de teste criados:\n');
        fprintf('Predição categorical:\n');
        disp(test_pred);
        fprintf('Ground truth categorical:\n');
        disp(test_gt);
        
        % Verificar conversão manual
        pred_binary = (test_pred == "foreground");
        gt_binary = (test_gt == "foreground");
        
        fprintf('\nConversão para binário:\n');
        fprintf('Predição binária:\n');
        disp(double(pred_binary));
        fprintf('Ground truth binária:\n');
        disp(double(gt_binary));
        
        % Testar funções de métricas
        fprintf('\n=== TESTANDO FUNÇÕES DE MÉTRICAS ===\n');
        
        % Testar IoU
        iou_result = calcular_iou_simples(test_pred, test_gt);
        fprintf('IoU calculado: %.4f\n', iou_result);
        
        % Testar Dice
        dice_result = calcular_dice_simples(test_pred, test_gt);
        fprintf('Dice calculado: %.4f\n', dice_result);
        
        % Testar Accuracy
        acc_result = calcular_accuracy_simples(test_pred, test_gt);
        fprintf('Accuracy calculada: %.4f\n', acc_result);
        
        % Verificar se os resultados são realistas (não perfeitos)
        fprintf('\n=== VALIDAÇÃO DOS RESULTADOS ===\n');
        
        if iou_result == 1.0
            fprintf('AVISO: IoU = 1.0 (pode indicar problema)\n');
        else
            fprintf('✓ IoU tem valor realístico: %.4f\n', iou_result);
        end
        
        if dice_result == 1.0
            fprintf('AVISO: Dice = 1.0 (pode indicar problema)\n');
        else
            fprintf('✓ Dice tem valor realístico: %.4f\n', dice_result);
        end
        
        if acc_result == 1.0
            fprintf('AVISO: Accuracy = 1.0 (pode indicar problema)\n');
        else
            fprintf('✓ Accuracy tem valor realístico: %.4f\n', acc_result);
        end
        
        % Calcular métricas manualmente para verificação
        fprintf('\n=== VERIFICAÇÃO MANUAL ===\n');
        
        intersection = sum(pred_binary(:) & gt_binary(:));
        union = sum(pred_binary(:) | gt_binary(:));
        manual_iou = intersection / union;
        fprintf('IoU manual: %.4f\n', manual_iou);
        
        total_pixels = sum(pred_binary(:)) + sum(gt_binary(:));
        manual_dice = 2 * intersection / total_pixels;
        fprintf('Dice manual: %.4f\n', manual_dice);
        
        correct_pixels = sum(pred_binary(:) == gt_binary(:));
        total_pixels_acc = numel(pred_binary);
        manual_acc = correct_pixels / total_pixels_acc;
        fprintf('Accuracy manual: %.4f\n', manual_acc);
        
        % Verificar consistência
        if abs(iou_result - manual_iou) < 1e-6
            fprintf('✓ IoU consistente com cálculo manual\n');
        else
            fprintf('✗ IoU inconsistente: função=%.6f, manual=%.6f\n', iou_result, manual_iou);
        end
        
        if abs(dice_result - manual_dice) < 1e-6
            fprintf('✓ Dice consistente com cálculo manual\n');
        else
            fprintf('✗ Dice inconsistente: função=%.6f, manual=%.6f\n', dice_result, manual_dice);
        end
        
        if abs(acc_result - manual_acc) < 1e-6
            fprintf('✓ Accuracy consistente com cálculo manual\n');
        else
            fprintf('✗ Accuracy inconsistente: função=%.6f, manual=%.6f\n', acc_result, manual_acc);
        end
        
        fprintf('\n=== TESTE CONCLUÍDO COM SUCESSO ===\n');
        
    catch ME
        fprintf('ERRO durante o teste: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end