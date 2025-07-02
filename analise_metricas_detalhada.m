%% ANÁLISE DETALHADA DAS MÉTRICAS DE SEGMENTAÇÃO
%% Por que U-Net e Attention U-Net tiveram resultados idênticos?

fprintf('=== ANÁLISE DAS MÉTRICAS ===\n\n');

%% 1. ACURÁCIA PIXEL-WISE
fprintf('1. ACURÁCIA PIXEL-WISE = 88.84%%\n');
fprintf('   - Definição: Percentual de pixels classificados corretamente\n');
fprintf('   - Fórmula: Pixels Corretos / Total de Pixels\n');
fprintf('   - Problema: Não considera o balanceamento de classes\n\n');

%% Exemplo prático
fprintf('   Exemplo com imagem 256x256:\n');
total_pixels = 256 * 256;
pixels_corretos = round(0.8884 * total_pixels);
pixels_incorretos = total_pixels - pixels_corretos;

fprintf('   - Total de pixels: %d\n', total_pixels);
fprintf('   - Pixels corretos: %d\n', pixels_corretos);
fprintf('   - Pixels incorretos: %d\n', pixels_incorretos);
fprintf('   - Acurácia: %.2f%%\n\n', 100 * pixels_corretos / total_pixels);

%% 2. IoU (Intersection over Union)
fprintf('2. IoU = 88.84%% (idêntico à acurácia - SUSPEITO!)\n');
fprintf('   - Definição: Área de interseção / Área de união\n');
fprintf('   - Fórmula: TP / (TP + FP + FN)\n');
fprintf('   - Normalmente: IoU < Acurácia\n\n');

%% 3. DICE COEFFICIENT
fprintf('3. DICE = 94.06%%\n');
fprintf('   - Definição: 2 × Interseção / (Predição + Ground Truth)\n');
fprintf('   - Fórmula: 2×TP / (2×TP + FP + FN)\n');
fprintf('   - Normalmente: Dice > IoU\n\n');

%% 4. POR QUE OS RESULTADOS SÃO IDÊNTICOS?
fprintf('4. RAZÕES PARA RESULTADOS IDÊNTICOS:\n\n');

fprintf('   a) IMPLEMENTAÇÃO INCORRETA:\n');
fprintf('      - A "Attention U-Net" é na verdade apenas U-Net + regularização\n');
fprintf('      - Não possui verdadeiros attention gates\n');
fprintf('      - Mesma arquitetura = mesmos resultados\n\n');

fprintf('   b) DATASET CARACTERÍSTICAS:\n');
fprintf('      - 414 imagens podem ser insuficientes para mostrar diferenças\n');
fprintf('      - Classes muito desbalanceadas (muito background)\n');
fprintf('      - Objetos podem ser muito simples de segmentar\n\n');

fprintf('   c) HIPERPARÂMETROS IDÊNTICOS:\n');
fprintf('      - Mesmo learning rate (0.001)\n');
fprintf('      - Mesmo número de épocas (20)\n');
fprintf('      - Mesmo mini-batch size (8)\n\n');

%% 5. COMO INTERPRETAR OS RESULTADOS
fprintf('5. INTERPRETAÇÃO DOS RESULTADOS:\n\n');

fprintf('   CENÁRIO ATUAL (PROBLEMÁTICO):\n');
fprintf('   - Acurácia = IoU = 88.84%% (matematicamente impossível em casos normais)\n');
fprintf('   - Desvio padrão muito baixo (0.0303) = baixa variabilidade\n');
fprintf('   - Dice muito alto (94.06%%) comparado ao IoU\n\n');

fprintf('   CENÁRIO ESPERADO (NORMAL):\n');
fprintf('   - Acurácia: 85-95%%\n');
fprintf('   - IoU: 70-85%% (menor que acurácia)\n');
fprintf('   - Dice: 80-90%% (entre IoU e acurácia)\n\n');

%% 6. POSSÍVEIS PROBLEMAS
fprintf('6. POSSÍVEIS PROBLEMAS IDENTIFICADOS:\n\n');

fprintf('   a) FUNÇÃO DE AVALIAÇÃO:\n');
fprintf('      - Pode estar calculando IoU incorretamente\n');
fprintf('      - Conversão categorical -> numeric com erro\n\n');

fprintf('   b) ATTENTION U-NET FALSA:\n');
fprintf('      - Não implementa attention gates reais\n');
fprintf('      - Apenas regularização L2 + dropout\n\n');

fprintf('   c) DATASET MUITO FÁCIL:\n');
fprintf('      - Segmentação muito simples\n');
fprintf('      - Ambos os modelos conseguem 100%% facilmente\n\n');

%% 7. SOLUÇÕES RECOMENDADAS
fprintf('7. SOLUÇÕES PARA VER DIFERENÇAS REAIS:\n\n');

fprintf('   a) IMPLEMENTAR ATTENTION U-NET VERDADEIRA:\n');
fprintf('      - Attention gates nos skip connections\n');
fprintf('      - Squeeze-and-Excitation blocks\n');
fprintf('      - Self-attention mechanisms\n\n');

fprintf('   b) USAR MÉTRICAS MAIS SENSÍVEIS:\n');
fprintf('      - Boundary IoU (para bordas)\n');
fprintf('      - Hausdorff Distance\n');
fprintf('      - Surface Distance\n\n');

fprintf('   c) DATASET MAIS DESAFIADOR:\n');
fprintf('      - Objetos menores\n');
fprintf('      - Mais variabilidade\n');
fprintf('      - Casos edge mais difíceis\n\n');

fprintf('=== CONCLUSÃO ===\n');
fprintf('Os resultados idênticos indicam que:\n');
fprintf('1. A Attention U-Net implementada NÃO é diferente da U-Net\n');
fprintf('2. O dataset pode ser muito simples\n');
fprintf('3. As métricas podem ter problemas de implementação\n\n');

fprintf('RECOMENDAÇÃO: Implementar attention mechanisms reais\n');
fprintf('para ver diferenças significativas entre os modelos.\n');
