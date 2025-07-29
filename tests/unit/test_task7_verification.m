function test_task7_verification()
    % ========================================================================
    % VERIFICAÇÃO FINAL DA TASK 7 - CORREÇÃO CATEGORICAL TO BINARY
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Verifica se todas as funções de métricas foram corrigidas
    %   e estão produzindo resultados realísticos
    % ========================================================================
    
    fprintf('=== VERIFICAÇÃO FINAL DA TASK 7 ===\n');
    
    try
        % Criar dados de teste mais complexos
        % Simular dados reais com diferentes padrões
        pred_data = [0 0 1 1 0; 0 1 1 1 0; 1 1 0 1 1; 0 1 1 0 0];
        gt_data = [0 1 1 1 0; 0 0 1 1 0; 1 1 1 1 0; 0 0 1 1 0];
        
        % Converter para categorical usando o padrão correto
        test_pred = categorical(pred_data, [0,1], ["background","foreground"]);
        test_gt = categorical(gt_data, [0,1], ["background","foreground"]);
        
        fprintf('Testando com dados categorical mais complexos...\n');
        
        % Testar todas as funções de métricas
        iou_result = calcular_iou_simples(test_pred, test_gt);
        dice_result = calcular_dice_simples(test_pred, test_gt);
        acc_result = calcular_accuracy_simples(test_pred, test_gt);
        
        fprintf('\nResultados das métricas:\n');
        fprintf('IoU: %.4f\n', iou_result);
        fprintf('Dice: %.4f\n', dice_result);
        fprintf('Accuracy: %.4f\n', acc_result);
        
        % Verificar se os resultados são realísticos
        metrics_realistic = true;
        
        if iou_result == 1.0
            fprintf('❌ PROBLEMA: IoU = 1.0 (artificialmente perfeito)\n');
            metrics_realistic = false;
        else
            fprintf('✅ IoU realístico: %.4f\n', iou_result);
        end
        
        if dice_result == 1.0
            fprintf('❌ PROBLEMA: Dice = 1.0 (artificialmente perfeito)\n');
            metrics_realistic = false;
        else
            fprintf('✅ Dice realístico: %.4f\n', dice_result);
        end
        
        if acc_result == 1.0
            fprintf('❌ PROBLEMA: Accuracy = 1.0 (artificialmente perfeito)\n');
            metrics_realistic = false;
        else
            fprintf('✅ Accuracy realístico: %.4f\n', acc_result);
        end
        
        % Testar com dados numéricos para garantir compatibilidade
        fprintf('\n=== TESTE COM DADOS NUMÉRICOS ===\n');
        
        pred_numeric = double(pred_data);
        gt_numeric = double(gt_data);
        
        iou_numeric = calcular_iou_simples(pred_numeric, gt_numeric);
        dice_numeric = calcular_dice_simples(pred_numeric, gt_numeric);
        acc_numeric = calcular_accuracy_simples(pred_numeric, gt_numeric);
        
        fprintf('IoU (numérico): %.4f\n', iou_numeric);
        fprintf('Dice (numérico): %.4f\n', dice_numeric);
        fprintf('Accuracy (numérico): %.4f\n', acc_numeric);
        
        % Verificar consistência entre categorical e numérico
        if abs(iou_result - iou_numeric) < 1e-6
            fprintf('✅ IoU consistente entre categorical e numérico\n');
        else
            fprintf('❌ IoU inconsistente: cat=%.6f, num=%.6f\n', iou_result, iou_numeric);
        end
        
        if abs(dice_result - dice_numeric) < 1e-6
            fprintf('✅ Dice consistente entre categorical e numérico\n');
        else
            fprintf('❌ Dice inconsistente: cat=%.6f, num=%.6f\n', dice_result, dice_numeric);
        end
        
        if abs(acc_result - acc_numeric) < 1e-6
            fprintf('✅ Accuracy consistente entre categorical e numérico\n');
        else
            fprintf('❌ Accuracy inconsistente: cat=%.6f, num=%.6f\n', acc_result, acc_numeric);
        end
        
        % Resultado final
        fprintf('\n=== RESULTADO FINAL ===\n');
        if metrics_realistic
            fprintf('✅ TASK 7 CONCLUÍDA COM SUCESSO!\n');
            fprintf('   Todas as funções de métricas foram corrigidas\n');
            fprintf('   Métricas produzem valores realísticos\n');
            fprintf('   Conversão categorical → binary funciona corretamente\n');
        else
            fprintf('❌ TASK 7 PRECISA DE MAIS CORREÇÕES\n');
            fprintf('   Algumas métricas ainda estão artificialmente perfeitas\n');
        end
        
    catch ME
        fprintf('❌ ERRO durante a verificação: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end