function integration_example()
    % INTEGRATION_EXAMPLE - Exemplo de integração com sistema existente
    %
    % Este script demonstra como integrar o sistema de visualização
    % avançada com o sistema existente de comparação U-Net vs Attention U-Net.
    
    fprintf('=== EXEMPLO DE INTEGRAÇÃO: Sistema de Visualização ===\n\n');
    
    try
        % Configurar ambiente
        addpath(genpath('src/'));
        
        % Simular dados do sistema existente
        fprintf('1. Simulando dados do sistema existente...\n');
        [dados_sistema] = simular_dados_sistema_existente();
        
        % Integração com ComparisonVisualizer
        fprintf('2. Integrando ComparisonVisualizer...\n');
        integrar_comparison_visualizer(dados_sistema);
        
        % Integração com análise estatística
        fprintf('3. Integrando análise estatística...\n');
        integrar_analise_estatistica(dados_sistema);
        
        % Integração com galeria HTML
        fprintf('4. Integrando galeria HTML...\n');
        integrar_galeria_html(dados_sistema);
        
        % Exemplo de modificação do executar_comparacao.m
        fprintf('5. Exemplo de modificação do menu principal...\n');
        exemplo_modificacao_menu();
        
        fprintf('\n=== INTEGRAÇÃO CONCLUÍDA COM SUCESSO ===\n');
        fprintf('O sistema de visualização está pronto para ser integrado!\n\n');
        
    catch ME
        fprintf('ERRO durante integração: %s\n', ME.message);
    end
end

function dados_sistema = simular_dados_sistema_existente()
    % Simular estrutura de dados do sistema existente
    
    dados_sistema = struct();
    
    % Simular resultados de comparação
    dados_sistema.num_imagens = 10;
    dados_sistema.imagens_originais = {};
    dados_sistema.ground_truth = {};
    dados_sistema.predicoes_unet = {};
    dados_sistema.predicoes_attention = {};
    dados_sistema.metricas = struct();
    
    % Inicializar arrays de métricas
    dados_sistema.metricas.unet.iou = [];
    dados_sistema.metricas.unet.dice = [];
    dados_sistema.metricas.unet.accuracy = [];
    
    dados_sistema.metricas.attention.iou = [];
    dados_sistema.metricas.attention.dice = [];
    dados_sistema.metricas.attention.accuracy = [];
    
    % Simular dados para cada imagem
    for i = 1:dados_sistema.num_imagens
        % Imagem original simulada
        img_original = uint8(rand(256, 256, 3) * 255);
        dados_sistema.imagens_originais{i} = img_original;
        
        % Ground truth simulado
        [X, Y] = meshgrid(1:256, 1:256);
        center = [128 + randn()*30, 128 + randn()*30];
        radius = 40 + randn()*10;
        gt = sqrt((X - center(1)).^2 + (Y - center(2)).^2) < radius;
        dados_sistema.ground_truth{i} = gt;
        
        % Predições simuladas
        unet_pred = gt;
        % Adicionar ruído específico do U-Net
        noise_unet = rand(256, 256) > 0.95;
        unet_pred = unet_pred | noise_unet;
        unet_pred = unet_pred & ~(rand(256, 256) > 0.98);
        dados_sistema.predicoes_unet{i} = unet_pred;
        
        attention_pred = gt;
        % Adicionar ruído específico do Attention U-Net (menor)
        noise_attention = rand(256, 256) > 0.97;
        attention_pred = attention_pred | noise_attention;
        attention_pred = attention_pred & ~(rand(256, 256) > 0.99);
        dados_sistema.predicoes_attention{i} = attention_pred;
        
        % Calcular métricas
        % U-Net
        unet_intersection = sum(sum(unet_pred & gt));
        unet_union = sum(sum(unet_pred | gt));
        dados_sistema.metricas.unet.iou(i) = unet_intersection / unet_union;
        dados_sistema.metricas.unet.dice(i) = 2 * unet_intersection / (sum(sum(unet_pred)) + sum(sum(gt)));
        dados_sistema.metricas.unet.accuracy(i) = sum(sum(unet_pred == gt)) / numel(gt);
        
        % Attention U-Net
        att_intersection = sum(sum(attention_pred & gt));
        att_union = sum(sum(attention_pred | gt));
        dados_sistema.metricas.attention.iou(i) = att_intersection / att_union;
        dados_sistema.metricas.attention.dice(i) = 2 * att_intersection / (sum(sum(attention_pred)) + sum(sum(gt)));
        dados_sistema.metricas.attention.accuracy(i) = sum(sum(attention_pred == gt)) / numel(gt);
    end
    
    fprintf('   - Simulados %d imagens com métricas\n', dados_sistema.num_imagens);
end

function integrar_comparison_visualizer(dados_sistema)
    % Demonstrar integração com ComparisonVisualizer
    
    try
        % Criar visualizador
        visualizer = ComparisonVisualizer('outputDir', 'output/integration_demo/comparisons/');
        
        % Processar algumas imagens como exemplo
        num_exemplos = min(3, dados_sistema.num_imagens);
        
        for i = 1:num_exemplos
            % Preparar métricas no formato esperado
            metricas_img = struct();
            metricas_img.unet.iou = dados_sistema.metricas.unet.iou(i);
            metricas_img.unet.dice = dados_sistema.metricas.unet.dice(i);
            metricas_img.unet.accuracy = dados_sistema.metricas.unet.accuracy(i);
            
            metricas_img.attention.iou = dados_sistema.metricas.attention.iou(i);
            metricas_img.attention.dice = dados_sistema.metricas.attention.dice(i);
            metricas_img.attention.accuracy = dados_sistema.metricas.attention.accuracy(i);
            
            % Criar comparação lado a lado
            comparison_path = visualizer.createSideBySideComparison(...
                dados_sistema.imagens_originais{i}, ...
                dados_sistema.ground_truth{i}, ...
                dados_sistema.predicoes_unet{i}, ...
                dados_sistema.predicoes_attention{i}, ...
                metricas_img, ...
                'title', sprintf('Comparação - Imagem %03d', i), ...
                'filename', sprintf('comparison_img_%03d.png', i));
            
            % Criar mapa de diferenças
            diff_path = visualizer.createDifferenceMap(...
                dados_sistema.predicoes_unet{i}, ...
                dados_sistema.predicoes_attention{i}, ...
                'title', sprintf('Diferenças - Imagem %03d', i), ...
                'filename', sprintf('differences_img_%03d.png', i));
            
            fprintf('   - Imagem %d: comparação e diferenças criadas\n', i);
        end
        
        fprintf('   ✓ ComparisonVisualizer integrado com sucesso\n');
        
    catch ME
        fprintf('   ✗ Erro na integração do ComparisonVisualizer: %s\n', ME.message);
    end
end

function integrar_analise_estatistica(dados_sistema)
    % Demonstrar integração com análise estatística
    
    try
        % Criar plotter estatístico
        plotter = StatisticalPlotter('outputDir', 'output/integration_demo/statistics/');
        
        % Análise comparativa completa
        stats_path = plotter.plotStatisticalComparison(...
            dados_sistema.metricas.unet, ...
            dados_sistema.metricas.attention, ...
            'title', 'Análise Estatística - U-Net vs Attention U-Net', ...
            'includeTests', true, ...
            'filename', 'statistical_analysis.png');
        
        % Simular histórico de treinamento
        historico_treinamento = struct();
        epochs = 50;
        
        % U-Net
        historico_treinamento.unet.loss = 1 - linspace(0.3, 0.9, epochs) + randn(1, epochs) * 0.05;
        historico_treinamento.unet.iou = linspace(0.3, mean(dados_sistema.metricas.unet.iou), epochs) + randn(1, epochs) * 0.02;
        historico_treinamento.unet.dice = linspace(0.4, mean(dados_sistema.metricas.unet.dice), epochs) + randn(1, epochs) * 0.02;
        historico_treinamento.unet.accuracy = linspace(0.7, mean(dados_sistema.metricas.unet.accuracy), epochs) + randn(1, epochs) * 0.01;
        
        % Attention U-Net
        historico_treinamento.attention.loss = 1 - linspace(0.35, 0.92, epochs) + randn(1, epochs) * 0.04;
        historico_treinamento.attention.iou = linspace(0.35, mean(dados_sistema.metricas.attention.iou), epochs) + randn(1, epochs) * 0.02;
        historico_treinamento.attention.dice = linspace(0.45, mean(dados_sistema.metricas.attention.dice), epochs) + randn(1, epochs) * 0.02;
        historico_treinamento.attention.accuracy = linspace(0.72, mean(dados_sistema.metricas.attention.accuracy), epochs) + randn(1, epochs) * 0.01;
        
        % Gráfico de evolução
        evolution_path = plotter.createPerformanceEvolution(historico_treinamento, ...
            'title', 'Evolução da Performance Durante Treinamento', ...
            'filename', 'training_evolution.png');
        
        fprintf('   ✓ Análise estatística integrada com sucesso\n');
        
    catch ME
        fprintf('   ✗ Erro na integração da análise estatística: %s\n', ME.message);
    end
end

function integrar_galeria_html(dados_sistema)
    % Demonstrar integração com galeria HTML
    
    try
        % Criar gerador de galeria
        generator = HTMLGalleryGenerator('outputDir', 'output/integration_demo/gallery/');
        
        % Preparar dados para galeria
        all_results = {};
        
        for i = 1:dados_sistema.num_imagens
            result = struct();
            
            % Salvar imagem original temporariamente
            temp_img_path = sprintf('temp/integration_img_%03d.png', i);
            if ~exist('temp', 'dir')
                mkdir('temp');
            end
            imwrite(dados_sistema.imagens_originais{i}, temp_img_path);
            result.imagePath = temp_img_path;
            
            % Métricas
            result.metrics.iou = dados_sistema.metricas.unet.iou(i);
            result.metrics.dice = dados_sistema.metricas.unet.dice(i);
            
            % Caminho da comparação (se existir)
            comparison_path = sprintf('output/integration_demo/comparisons/comparison_img_%03d.png', i);
            if exist(comparison_path, 'file')
                result.comparisonPath = comparison_path;
            end
            
            all_results{i} = result;
        end
        
        % Gerar galeria
        session_id = sprintf('integration_demo_%s', datestr(now, 'yyyymmdd_HHMMSS'));
        gallery_path = generator.generateComparisonGallery(all_results, ...
            'sessionId', session_id);
        
        fprintf('   ✓ Galeria HTML integrada com sucesso\n');
        fprintf('     Galeria disponível em: %s\n', gallery_path);
        
    catch ME
        fprintf('   ✗ Erro na integração da galeria HTML: %s\n', ME.message);
    end
end

function exemplo_modificacao_menu()
    % Mostrar como modificar o menu principal para incluir visualizações
    
    fprintf('   Exemplo de modificação do executar_comparacao.m:\n\n');
    
    codigo_exemplo = [
        '% Adicionar no menu principal (executar_comparacao.m):\n'
        '\n'
        'fprintf(''\\n=== SISTEMA DE COMPARAÇÃO U-NET vs ATTENTION U-NET ===\\n'');\n'
        'fprintf(''1. Treinar e comparar modelos\\n'');\n'
        'fprintf(''2. Carregar modelos pré-treinados\\n'');\n'
        'fprintf(''3. Executar inferência em novas imagens\\n'');\n'
        'fprintf(''4. Organizar resultados\\n'');\n'
        'fprintf(''5. NOVO: Gerar visualizações avançadas\\n'');  % NOVA OPÇÃO\n'
        'fprintf(''6. NOVO: Criar galeria HTML interativa\\n'');  % NOVA OPÇÃO\n'
        'fprintf(''7. NOVO: Análise estatística completa\\n'');   % NOVA OPÇÃO\n'
        'fprintf(''0. Sair\\n'');\n'
        '\n'
        'opcao = input(''Escolha uma opção: '', ''s'');\n'
        '\n'
        'switch opcao\n'
        '    case ''5''  % Visualizações avançadas\n'
        '        fprintf(''Gerando visualizações avançadas...\\n'');\n'
        '        \n'
        '        % Criar visualizador\n'
        '        visualizer = ComparisonVisualizer();\n'
        '        \n'
        '        % Processar todas as imagens\n'
        '        for i = 1:length(resultados.imagens)\n'
        '            comparison_path = visualizer.createSideBySideComparison(...\n'
        '                resultados.imagens{i}, ...\n'
        '                resultados.ground_truth{i}, ...\n'
        '                resultados.unet_pred{i}, ...\n'
        '                resultados.attention_pred{i}, ...\n'
        '                resultados.metricas{i});\n'
        '        end\n'
        '        \n'
        '        fprintf(''Visualizações salvas em: output/visualizations/\\n'');\n'
        '        \n'
        '    case ''6''  % Galeria HTML\n'
        '        fprintf(''Criando galeria HTML interativa...\\n'');\n'
        '        \n'
        '        generator = HTMLGalleryGenerator();\n'
        '        gallery_path = generator.generateComparisonGallery(resultados.all_results);\n'
        '        \n'
        '        fprintf(''Galeria disponível em: %s\\n'', gallery_path);\n'
        '        \n'
        '    case ''7''  % Análise estatística\n'
        '        fprintf(''Executando análise estatística completa...\\n'');\n'
        '        \n'
        '        plotter = StatisticalPlotter();\n'
        '        stats_path = plotter.plotStatisticalComparison(...\n'
        '            resultados.metricas_unet, resultados.metricas_attention);\n'
        '        \n'
        '        fprintf(''Análise estatística salva em: %s\\n'', stats_path);\n'
        'end\n'
    ];
    
    fprintf('%s\n', codigo_exemplo);
    
    % Salvar exemplo em arquivo
    exemplo_file = 'src/visualization/menu_integration_example.m';
    fid = fopen(exemplo_file, 'w');
    fprintf(fid, '%% Exemplo de integração com menu principal\n');
    fprintf(fid, '%% Este código pode ser adicionado ao executar_comparacao.m\n\n');
    fprintf(fid, '%s', codigo_exemplo);
    fclose(fid);
    
    fprintf('   ✓ Exemplo salvo em: %s\n', exemplo_file);
end