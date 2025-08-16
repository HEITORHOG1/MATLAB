function teste_comparador_modelos()
    % ========================================================================
    % TESTE DO COMPARADOR DE MODELOS
    % ========================================================================
    % 
    % Testa a funcionalidade da classe ComparadorModelos
    % 
    % AUTOR: Sistema de Segmentação Completo
    % Data: Agosto 2025
    % ========================================================================
    
    fprintf('=== TESTE DO COMPARADOR DE MODELOS ===\n\n');
    
    try
        % 1. Configurar ambiente de teste
        fprintf('[1/5] Configurando ambiente de teste...\n');
        configurarAmbienteTeste();
        
        % 2. Criar dados de teste
        fprintf('[2/5] Criando dados de teste...\n');
        criarDadosTeste();
        
        % 3. Testar inicialização
        fprintf('[3/5] Testando inicialização...\n');
        testarInicializacao();
        
        % 4. Testar carregamento de resultados
        fprintf('[4/5] Testando carregamento de resultados...\n');
        testarCarregamentoResultados();
        
        % 5. Testar comparação completa
        fprintf('[5/5] Testando comparação completa...\n');
        testarComparacaoCompleta();
        
        fprintf('\n✅ TODOS OS TESTES PASSARAM!\n');
        
    catch ME
        fprintf('\n❌ ERRO no teste: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
    
    % Limpeza
    fprintf('\nLimpando arquivos de teste...\n');
    limparAmbienteTeste();
end

function configurarAmbienteTeste()
    % Configura ambiente para testes
    
    % Adicionar caminhos necessários
    addpath('src/comparacao');
    addpath('src/evaluation');
    addpath('src/visualization');
    
    % Criar diretório de teste
    if ~exist('test_output', 'dir')
        mkdir('test_output');
    end
    
    fprintf('✅ Ambiente configurado\n');
end

function criarDadosTeste()
    % Cria dados sintéticos para teste
    
    % Criar estrutura de pastas
    pastas = {
        'test_output/unet',
        'test_output/attention_unet'
    };
    
    for i = 1:length(pastas)
        if ~exist(pastas{i}, 'dir')
            mkdir(pastas{i});
        end
    end
    
    % Criar imagens de teste
    for i = 1:5
        % Criar segmentação U-Net (círculo)
        img_unet = criarImagemCirculo(128, 128, 30 + i*2);
        nomeArquivo = sprintf('seg_%03d.png', i);
        imwrite(img_unet, fullfile('test_output/unet', nomeArquivo));
        
        % Criar segmentação Attention U-Net (círculo ligeiramente diferente)
        img_attention = criarImagemCirculo(128, 128, 32 + i*2);
        imwrite(img_attention, fullfile('test_output/attention_unet', nomeArquivo));
    end
    
    fprintf('✅ Dados de teste criados (5 imagens por modelo)\n');
end

function img = criarImagemCirculo(altura, largura, raio)
    % Cria imagem binária com círculo
    
    img = false(altura, largura);
    
    % Centro da imagem
    cx = largura / 2;
    cy = altura / 2;
    
    % Criar círculo
    [X, Y] = meshgrid(1:largura, 1:altura);
    distancia = sqrt((X - cx).^2 + (Y - cy).^2);
    img = distancia <= raio;
    
    % Converter para uint8
    img = uint8(img * 255);
end

function testarInicializacao()
    % Testa inicialização da classe
    
    try
        % Teste 1: Inicialização básica
        comparador = ComparadorModelos('caminhoSaida', 'test_output', 'verbose', false);
        assert(isa(comparador, 'ComparadorModelos'), 'Falha na criação da instância');
        
        % Teste 2: Inicialização com verbose
        comparador_verbose = ComparadorModelos('caminhoSaida', 'test_output', 'verbose', true);
        assert(isa(comparador_verbose, 'ComparadorModelos'), 'Falha na criação com verbose');
        
        fprintf('✅ Inicialização testada com sucesso\n');
        
    catch ME
        error('Falha no teste de inicialização: %s', ME.message);
    end
end

function testarCarregamentoResultados()
    % Testa carregamento de resultados
    
    try
        comparador = ComparadorModelos('caminhoSaida', 'test_output', 'verbose', false);
        
        % Testar carregamento
        resultados = comparador.carregarResultados();
        
        % Verificar estrutura
        assert(isstruct(resultados), 'Resultados devem ser struct');
        assert(isfield(resultados, 'unet'), 'Deve conter campo unet');
        assert(isfield(resultados, 'attention'), 'Deve conter campo attention');
        
        % Verificar dados U-Net
        assert(length(resultados.unet.arquivos) == 5, 'Deve carregar 5 arquivos U-Net');
        assert(strcmp(resultados.unet.modelo, 'U-Net'), 'Nome do modelo incorreto');
        
        % Verificar dados Attention U-Net
        assert(length(resultados.attention.arquivos) == 5, 'Deve carregar 5 arquivos Attention');
        assert(strcmp(resultados.attention.modelo, 'Attention U-Net'), 'Nome do modelo incorreto');
        
        fprintf('✅ Carregamento de resultados testado com sucesso\n');
        
    catch ME
        error('Falha no teste de carregamento: %s', ME.message);
    end
end

function testarComparacaoCompleta()
    % Testa comparação completa
    
    try
        comparador = ComparadorModelos('caminhoSaida', 'test_output', 'verbose', false);
        
        % Executar comparação completa
        comparador.comparar();
        
        % Verificar se arquivos foram criados
        arquivosEsperados = {
            'test_output/comparacoes',
            'test_output/relatorios',
            'test_output/relatorios/relatorio_comparativo.txt'
        };
        
        for i = 1:length(arquivosEsperados)
            assert(exist(arquivosEsperados{i}, 'dir') || exist(arquivosEsperados{i}, 'file'), ...
                sprintf('Arquivo/pasta não criado: %s', arquivosEsperados{i}));
        end
        
        % Verificar conteúdo do relatório
        relatorio = fileread('test_output/relatorios/relatorio_comparativo.txt');
        assert(contains(relatorio, 'RELATÓRIO COMPARATIVO'), 'Relatório deve conter título');
        assert(contains(relatorio, 'RESUMO EXECUTIVO'), 'Relatório deve conter resumo');
        assert(contains(relatorio, 'MÉTRICAS DETALHADAS'), 'Relatório deve conter métricas');
        assert(contains(relatorio, 'CONCLUSÕES'), 'Relatório deve conter conclusões');
        
        fprintf('✅ Comparação completa testada com sucesso\n');
        
    catch ME
        error('Falha no teste de comparação completa: %s', ME.message);
    end
end

function limparAmbienteTeste()
    % Remove arquivos de teste
    
    try
        if exist('test_output', 'dir')
            rmdir('test_output', 's');
        end
        fprintf('✅ Limpeza concluída\n');
    catch
        fprintf('⚠️ Aviso: Não foi possível remover todos os arquivos de teste\n');
    end
end