function demo_ComparadorModelos()
    % ========================================================================
    % DEMONSTRAÇÃO DO COMPARADOR DE MODELOS
    % ========================================================================
    % 
    % Este script demonstra como usar a classe ComparadorModelos para
    % realizar análise comparativa entre modelos U-Net e Attention U-Net.
    % 
    % AUTOR: Sistema de Segmentação Completo
    % Data: Agosto 2025
    % ========================================================================
    
    fprintf('=== DEMONSTRAÇÃO DO COMPARADOR DE MODELOS ===\n\n');
    
    try
        % 1. Configurar ambiente
        fprintf('[1/4] Configurando ambiente...\n');
        configurarAmbiente();
        
        % 2. Criar dados de demonstração
        fprintf('[2/4] Criando dados de demonstração...\n');
        criarDadosDemo();
        
        % 3. Executar comparação
        fprintf('[3/4] Executando comparação...\n');
        executarComparacao();
        
        % 4. Mostrar resultados
        fprintf('[4/4] Mostrando resultados...\n');
        mostrarResultados();
        
        fprintf('\n✅ DEMONSTRAÇÃO CONCLUÍDA COM SUCESSO!\n');
        fprintf('Verifique os resultados em: demo_output/\n');
        
    catch ME
        fprintf('\n❌ ERRO na demonstração: %s\n', ME.message);
        rethrow(ME);
    end
end

function configurarAmbiente()
    % Configura ambiente para demonstração
    
    % Adicionar caminhos necessários
    addpath('src/comparacao');
    addpath('src/evaluation');
    addpath('src/visualization');
    
    % Criar diretório de demonstração
    if ~exist('demo_output', 'dir')
        mkdir('demo_output');
    end
    
    fprintf('✅ Ambiente configurado\n');
end

function criarDadosDemo()
    % Cria dados sintéticos para demonstração
    
    % Criar estrutura de pastas
    pastas = {
        'demo_output/unet',
        'demo_output/attention_unet'
    };
    
    for i = 1:length(pastas)
        if ~exist(pastas{i}, 'dir')
            mkdir(pastas{i});
        end
    end
    
    % Criar imagens de demonstração mais realistas
    numImagens = 8;
    
    for i = 1:numImagens
        % Criar segmentação U-Net (formas geométricas)
        img_unet = criarSegmentacaoRealista('unet', i);
        nomeArquivo = sprintf('segmentacao_%03d.png', i);
        imwrite(img_unet, fullfile('demo_output/unet', nomeArquivo));
        
        % Criar segmentação Attention U-Net (ligeiramente diferente)
        img_attention = criarSegmentacaoRealista('attention', i);
        imwrite(img_attention, fullfile('demo_output/attention_unet', nomeArquivo));
    end
    
    fprintf('✅ Dados de demonstração criados (%d imagens por modelo)\n', numImagens);
end

function img = criarSegmentacaoRealista(tipoModelo, indice)
    % Cria segmentação realista baseada no tipo de modelo
    
    altura = 256;
    largura = 256;
    img = false(altura, largura);
    
    % Centro da imagem
    cx = largura / 2;
    cy = altura / 2;
    
    switch tipoModelo
        case 'unet'
            % U-Net: formas mais simples e regulares
            raio = 40 + indice * 5;
            [X, Y] = meshgrid(1:largura, 1:altura);
            distancia = sqrt((X - cx).^2 + (Y - cy).^2);
            img = distancia <= raio;
            
            % Adicionar algumas imperfeições
            if mod(indice, 2) == 0
                img(cy-10:cy+10, cx-5:cx+5) = false;
            end
            
        case 'attention'
            % Attention U-Net: formas mais complexas e detalhadas
            raio = 42 + indice * 5;
            [X, Y] = meshgrid(1:largura, 1:altura);
            distancia = sqrt((X - cx).^2 + (Y - cy).^2);
            img = distancia <= raio;
            
            % Adicionar detalhes extras (simulando melhor captura de detalhes)
            if mod(indice, 3) == 0
                % Adicionar pequenas extensões
                img(cy-raio-5:cy-raio, cx-2:cx+2) = true;
                img(cy+raio:cy+raio+5, cx-2:cx+2) = true;
            end
            
            % Adicionar ruído controlado
            noise = rand(altura, largura) > 0.98;
            img = img | noise;
    end
    
    % Converter para uint8
    img = uint8(img * 255);
end

function executarComparacao()
    % Executa comparação usando ComparadorModelos
    
    % Criar instância do comparador
    comparador = ComparadorModelos('caminhoSaida', 'demo_output', 'verbose', true);
    
    % Executar comparação completa
    comparador.comparar();
    
    fprintf('✅ Comparação executada\n');
end

function mostrarResultados()
    % Mostra resumo dos resultados gerados
    
    fprintf('\n=== RESULTADOS GERADOS ===\n');
    
    % Verificar arquivos criados
    arquivos = {
        'demo_output/comparacoes',
        'demo_output/relatorios',
        'demo_output/relatorios/relatorio_comparativo.txt'
    };
    
    for i = 1:length(arquivos)
        if exist(arquivos{i}, 'dir') || exist(arquivos{i}, 'file')
            fprintf('✅ %s\n', arquivos{i});
        else
            fprintf('❌ %s (não encontrado)\n', arquivos{i});
        end
    end
    
    % Mostrar resumo do relatório se existir
    relatorioPath = 'demo_output/relatorios/relatorio_comparativo.txt';
    if exist(relatorioPath, 'file')
        fprintf('\n=== RESUMO DO RELATÓRIO ===\n');
        try
            conteudo = fileread(relatorioPath);
            linhas = strsplit(conteudo, '\n');
            
            % Mostrar apenas as primeiras 20 linhas
            numLinhas = min(20, length(linhas));
            for i = 1:numLinhas
                fprintf('%s\n', linhas{i});
            end
            
            if length(linhas) > 20
                fprintf('... (relatório completo em %s)\n', relatorioPath);
            end
            
        catch
            fprintf('Erro ao ler relatório\n');
        end
    end
    
    % Listar visualizações criadas
    comparacoesDir = 'demo_output/comparacoes';
    if exist(comparacoesDir, 'dir')
        arquivosViz = dir(fullfile(comparacoesDir, '*.png'));
        if ~isempty(arquivosViz)
            fprintf('\n=== VISUALIZAÇÕES CRIADAS ===\n');
            for i = 1:length(arquivosViz)
                fprintf('📊 %s\n', arquivosViz(i).name);
            end
        end
    end
end