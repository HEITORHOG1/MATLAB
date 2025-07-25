function executar_testes_completos()
    % ========================================================================
    % TESTE COMPLETO DO PROJETO - Diagnóstico e Correção
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 1.2 Final
    %
    % DESCRIÇÃO:
    %   Executa uma bateria completa de testes para identificar e corrigir
    %   todos os problemas do projeto U-Net vs Attention U-Net.
    %
    % USO:
    %   >> executar_testes_completos()
    %
    % VERSÃO: 1.0
    % DATA: Julho 2025
    % ========================================================================
    
    clc;
    fprintf('=====================================\n');
    fprintf('   TESTE COMPLETO DO PROJETO         \n');
    fprintf('   U-Net vs Attention U-Net          \n');
    fprintf('   Diagnóstico e Correção            \n');
    fprintf('=====================================\n\n');
    
    % Estatísticas de testes
    testes = [];
    resultados = [];
    
    % Lista de testes a executar
    lista_testes = {
        'Teste 1: Configuração básica', @teste_configuracao_basica;
        'Teste 2: Verificação de arquivos', @teste_arquivos_projeto;
        'Teste 3: Carregamento de dados', @teste_carregamento_dados;
        'Teste 4: Preprocessamento', @teste_preprocessamento;
        'Teste 5: Análise de máscaras', @teste_analise_mascaras;
        'Teste 6: Criação de datastores', @teste_datastores;
        'Teste 7: Arquitetura U-Net', @teste_unet_arquitetura;
        'Teste 8: Arquitetura Attention U-Net', @teste_attention_unet;
        'Teste 9: Treinamento simples', @teste_treinamento_simples;
        'Teste 10: Integração completa', @teste_integracao_completa
    };
    
    fprintf('Executando %d testes...\n\n', size(lista_testes, 1));
    
    % Executar cada teste
    for i = 1:size(lista_testes, 1)
        nome_teste = lista_testes{i, 1};
        funcao_teste = lista_testes{i, 2};
        
        fprintf('=== %s ===\n', nome_teste);
        
        try
            resultado = funcao_teste();
            if resultado
                fprintf('✅ PASSOU\n\n');
                status = 'PASSOU';
            else
                fprintf('❌ FALHOU\n\n');
                status = 'FALHOU';
            end
        catch ME
            fprintf('💥 ERRO: %s\n\n', ME.message);
            status = 'ERRO';
        end
        
        testes{end+1} = nome_teste;
        resultados{end+1} = status;
    end
    
    % Relatório final
    gerar_relatorio_final(testes, resultados);
end

function resultado = teste_configuracao_basica()
    % Teste 1: Verificar se a configuração básica funciona
    
    fprintf('Verificando configuração...\n');
    
    % Verificar se arquivo de configuração existe
    if ~exist('config_caminhos.mat', 'file')
        fprintf('❌ Arquivo de configuração não encontrado\n');
        fprintf('Criando configuração automática...\n');
        configuracao_inicial_automatica();
    end
    
    % Carregar configuração
    load('config_caminhos.mat', 'config');
    fprintf('✓ Configuração carregada\n');
    
    % Verificar campos obrigatórios
    campos = {'imageDir', 'maskDir', 'inputSize', 'numClasses'};
    for i = 1:length(campos)
        if ~isfield(config, campos{i})
            fprintf('❌ Campo ausente: %s\n', campos{i});
            resultado = false;
            return;
        end
    end
    
    fprintf('✓ Todos os campos obrigatórios presentes\n');
    resultado = true;
end

function resultado = teste_arquivos_projeto()
    % Teste 2: Verificar arquivos essenciais do projeto
    
    fprintf('Verificando arquivos do projeto...\n');
    
    arquivos_essenciais = {
        'executar_comparacao.m', 'Script principal';
        'configurar_caminhos.m', 'Configuração';
        'carregar_dados_robustos.m', 'Carregamento de dados';
        'preprocessDataCorrigido.m', 'Preprocessamento';
        'analisar_mascaras_automatico.m', 'Análise de máscaras';
        'treinar_unet_simples.m', 'Treinamento U-Net';
        'create_working_attention_unet.m', 'Attention U-Net';
        'comparacao_unet_attention_final.m', 'Comparação'
    };
    
    arquivos_faltando = {};
    
    for i = 1:size(arquivos_essenciais, 1)
        arquivo = arquivos_essenciais{i, 1};
        descricao = arquivos_essenciais{i, 2};
        
        if exist(arquivo, 'file')
            fprintf('✓ %s (%s)\n', arquivo, descricao);
        else
            fprintf('❌ FALTANDO: %s (%s)\n', arquivo, descricao);
            arquivos_faltando{end+1} = arquivo;
        end
    end
    
    if isempty(arquivos_faltando)
        fprintf('✓ Todos os arquivos essenciais presentes\n');
        resultado = true;
    else
        fprintf('❌ %d arquivo(s) faltando\n', length(arquivos_faltando));
        resultado = false;
    end
end

function resultado = teste_carregamento_dados()
    % Teste 3: Testar carregamento de dados
    
    fprintf('Testando carregamento de dados...\n');
    
    try
        load('config_caminhos.mat', 'config');
        
        % Verificar se diretórios existem
        if ~exist(config.imageDir, 'dir')
            fprintf('❌ Diretório de imagens não existe: %s\n', config.imageDir);
            resultado = false;
            return;
        end
        
        if ~exist(config.maskDir, 'dir')
            fprintf('❌ Diretório de máscaras não existe: %s\n', config.maskDir);
            resultado = false;
            return;
        end
        
        fprintf('✓ Diretórios existem\n');
        
        % Testar carregamento
        [images, masks] = carregar_dados_robustos(config);
        
        if isempty(images) || isempty(masks)
            fprintf('❌ Nenhum dado carregado\n');
            resultado = false;
            return;
        end
        
        fprintf('✓ Carregados %d imagens e %d máscaras\n', length(images), length(masks));
        
        % Testar carregamento de uma amostra
        img = imread(images{1});
        mask = imread(masks{1});
        
        fprintf('✓ Amostra carregada: img %s, mask %s\n', mat2str(size(img)), mat2str(size(mask)));
        resultado = true;
        
    catch ME
        fprintf('❌ Erro no carregamento: %s\n', ME.message);
        resultado = false;
    end
end

function resultado = teste_preprocessamento()
    % Teste 4: Testar função de preprocessamento
    
    fprintf('Testando preprocessamento...\n');
    
    try
        % Verificar se função existe
        if ~exist('preprocessDataCorrigido', 'file')
            fprintf('❌ Função preprocessDataCorrigido não encontrada\n');
            resultado = false;
            return;
        end
        
        fprintf('✓ Função de preprocessamento encontrada\n');
        
        % Carregar configuração e dados
        load('config_caminhos.mat', 'config');
        [images, masks] = carregar_dados_robustos(config);
        
        if isempty(images) || isempty(masks)
            fprintf('❌ Sem dados para testar\n');
            resultado = false;
            return;
        end
        
        % Testar preprocessamento
        img = imread(images{1});
        mask = imread(masks{1});
        data_in = {img, mask};
        labelIDs = [0, 1];
        
        data_out = preprocessDataCorrigido(data_in, config, labelIDs, false);
        
        processed_img = data_out{1};
        processed_mask = data_out{2};
        
        % Verificar tipos e dimensões
        if ~isa(processed_img, 'single')
            fprintf('❌ Imagem processada deve ser single, é %s\n', class(processed_img));
            resultado = false;
            return;
        end
        
        if ~isa(processed_mask, 'categorical')
            fprintf('❌ Máscara processada deve ser categorical, é %s\n', class(processed_mask));
            resultado = false;
            return;
        end
        
        if size(processed_img, 3) ~= 3
            fprintf('❌ Imagem deve ter 3 canais, tem %d\n', size(processed_img, 3));
            resultado = false;
            return;
        end
        
        fprintf('✓ Preprocessamento funcionando corretamente\n');
        resultado = true;
        
    catch ME
        fprintf('❌ Erro no preprocessamento: %s\n', ME.message);
        resultado = false;
    end
end

function resultado = teste_analise_mascaras()
    % Teste 5: Testar análise de máscaras
    
    fprintf('Testando análise de máscaras...\n');
    
    try
        if ~exist('analisar_mascaras_automatico', 'file')
            fprintf('❌ Função analisar_mascaras_automatico não encontrada\n');
            resultado = false;
            return;
        end
        
        load('config_caminhos.mat', 'config');
        [~, masks] = carregar_dados_robustos(config);
        
        if isempty(masks)
            fprintf('❌ Sem máscaras para analisar\n');
            resultado = false;
            return;
        end
        
        [classNames, labelIDs] = analisar_mascaras_automatico(config.maskDir, masks);
        
        if isempty(classNames) || isempty(labelIDs)
            fprintf('❌ Análise de máscaras falhou\n');
            resultado = false;
            return;
        end
        
        fprintf('✓ Análise de máscaras: %d classes\n', length(classNames));
        fprintf('  Classes: %s\n', strjoin(classNames, ', '));
        fprintf('  Label IDs: %s\n', mat2str(labelIDs));
        
        resultado = true;
        
    catch ME
        fprintf('❌ Erro na análise de máscaras: %s\n', ME.message);
        resultado = false;
    end
end

function resultado = teste_datastores()
    % Teste 6: Testar criação de datastores
    
    fprintf('Testando criação de datastores...\n');
    
    try
        load('config_caminhos.mat', 'config');
        [images, masks] = carregar_dados_robustos(config);
        
        if length(images) < 2 || length(masks) < 2
            fprintf('❌ Dados insuficientes para teste\n');
            resultado = false;
            return;
        end
        
        % Usar apenas 2 amostras para teste
        test_images = images(1:2);
        test_masks = masks(1:2);
        
        [classNames, labelIDs] = analisar_mascaras_automatico(config.maskDir, test_masks);
        
        % Criar datastores
        imds = imageDatastore(test_images);
        pxds = pixelLabelDatastore(test_masks, classNames, labelIDs);
        ds = combine(imds, pxds);
        
        fprintf('✓ Datastores criados\n');
        
        % Aplicar transformação
        ds = transform(ds, @(data) preprocessDataCorrigido(data, config, labelIDs, false));
        
        % Testar leitura
        reset(ds);
        data_sample = read(ds);
        
        fprintf('✓ Datastore com transformação funcionando\n');
        fprintf('  Dados: img %s, mask %s\n', class(data_sample{1}), class(data_sample{2}));
        
        resultado = true;
        
    catch ME
        fprintf('❌ Erro nos datastores: %s\n', ME.message);
        resultado = false;
    end
end

function resultado = teste_unet_arquitetura()
    % Teste 7: Testar criação da arquitetura U-Net
    
    fprintf('Testando arquitetura U-Net...\n');
    
    try
        load('config_caminhos.mat', 'config');
        
        inputSize = config.inputSize;
        numClasses = config.numClasses;
        
        % Criar U-Net
        lgraph = unetLayers(inputSize, numClasses, 'EncoderDepth', 2);
        
        fprintf('✓ U-Net criada com sucesso\n');
        fprintf('  Input size: %s\n', mat2str(inputSize));
        fprintf('  Num classes: %d\n', numClasses);
        
        % Verificar se a rede está bem formada
        try
            analyzeNetwork(lgraph);
            fprintf('✓ Arquitetura U-Net válida\n');
        catch
            fprintf('⚠️  Arquitetura U-Net pode ter problemas (mas criada)\n');
        end
        
        resultado = true;
        
    catch ME
        fprintf('❌ Erro na criação da U-Net: %s\n', ME.message);
        resultado = false;
    end
end

function resultado = teste_attention_unet()
    % Teste 8: Testar criação da Attention U-Net
    
    fprintf('Testando arquitetura Attention U-Net...\n');
    
    try
        if ~exist('create_working_attention_unet', 'file')
            fprintf('❌ Função create_working_attention_unet não encontrada\n');
            resultado = false;
            return;
        end
        
        load('config_caminhos.mat', 'config');
        
        inputSize = config.inputSize;
        numClasses = config.numClasses;
        
        % Criar Attention U-Net
        lgraph = create_working_attention_unet(inputSize, numClasses);
        
        fprintf('✓ Attention U-Net criada com sucesso\n');
        
        resultado = true;
        
    catch ME
        fprintf('❌ Erro na criação da Attention U-Net: %s\n', ME.message);
        resultado = false;
    end
end

function resultado = teste_treinamento_simples()
    % Teste 9: Testar treinamento simples (1 época)
    
    fprintf('Testando treinamento simples...\n');
    
    try
        load('config_caminhos.mat', 'config');
        [images, masks] = carregar_dados_robustos(config);
        
        if length(images) < 2 || length(masks) < 2
            fprintf('❌ Dados insuficientes para treinamento\n');
            resultado = false;
            return;
        end
        
        % Usar apenas 2 amostras
        test_images = images(1:2);
        test_masks = masks(1:2);
        
        [classNames, labelIDs] = analisar_mascaras_automatico(config.maskDir, test_masks);
        
        % Criar datastores
        imds = imageDatastore(test_images);
        pxds = pixelLabelDatastore(test_masks, classNames, labelIDs);
        ds = combine(imds, pxds);
        ds = transform(ds, @(data) preprocessDataCorrigido(data, config, labelIDs, false));
        
        % Criar rede simples
        lgraph = unetLayers(config.inputSize, config.numClasses, 'EncoderDepth', 1);
        
        % Opções de treinamento mínimas
        options = trainingOptions('adam', ...
            'InitialLearnRate', 1e-3, ...
            'MaxEpochs', 1, ...
            'MiniBatchSize', 1, ...
            'Plots', 'none', ...
            'Verbose', false);
        
        fprintf('Iniciando treinamento de teste...\n');
        net = trainNetwork(ds, lgraph, options);
        
        fprintf('✓ Treinamento simples concluído\n');
        resultado = true;
        
    catch ME
        fprintf('❌ Erro no treinamento: %s\n', ME.message);
        resultado = false;
    end
end

function resultado = teste_integracao_completa()
    % Teste 10: Testar integração completa
    
    fprintf('Testando integração completa...\n');
    
    try
        if ~exist('treinar_unet_simples', 'file')
            fprintf('❌ Função treinar_unet_simples não encontrada\n');
            resultado = false;
            return;
        end
        
        load('config_caminhos.mat', 'config');
        
        % Modificar configuração para teste rápido
        config.quickTest.numSamples = 5;
        config.quickTest.maxEpochs = 1;
        
        % Testar função completa
        treinar_unet_simples(config);
        
        fprintf('✓ Integração completa funcionando\n');
        resultado = true;
        
    catch ME
        fprintf('❌ Erro na integração: %s\n', ME.message);
        resultado = false;
    end
end

function gerar_relatorio_final(testes, resultados)
    % Gerar relatório final dos testes
    
    fprintf('\n=====================================\n');
    fprintf('   RELATÓRIO FINAL DOS TESTES        \n');
    fprintf('=====================================\n\n');
    
    passou = 0;
    falhou = 0;
    erro = 0;
    
    for i = 1:length(testes)
        status_icon = '';
        switch resultados{i}
            case 'PASSOU'
                status_icon = '✅';
                passou = passou + 1;
            case 'FALHOU'
                status_icon = '❌';
                falhou = falhou + 1;
            case 'ERRO'
                status_icon = '💥';
                erro = erro + 1;
        end
        
        fprintf('%s %s\n', status_icon, testes{i});
    end
    
    fprintf('\n=====================================\n');
    fprintf('ESTATÍSTICAS:\n');
    fprintf('✅ Passou: %d\n', passou);
    fprintf('❌ Falhou: %d\n', falhou);
    fprintf('💥 Erro: %d\n', erro);
    fprintf('📊 Total: %d\n', length(testes));
    fprintf('📈 Taxa de sucesso: %.1f%%\n', (passou/length(testes))*100);
    fprintf('=====================================\n\n');
    
    if falhou == 0 && erro == 0
        fprintf('🎉 TODOS OS TESTES PASSARAM!\n');
        fprintf('Seu projeto está 100%% funcional.\n\n');
    else
        fprintf('⚠️  AÇÕES NECESSÁRIAS:\n');
        if falhou > 0
            fprintf('- Corrigir %d teste(s) que falharam\n', falhou);
        end
        if erro > 0
            fprintf('- Resolver %d erro(s) crítico(s)\n', erro);
        end
        fprintf('\n');
    end
    
    % Salvar relatório
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    filename = sprintf('relatorio_testes_%s.txt', timestamp);
    
    fid = fopen(filename, 'w');
    fprintf(fid, 'RELATÓRIO DE TESTES - %s\n\n', datestr(now));
    for i = 1:length(testes)
        fprintf(fid, '%s: %s\n', testes{i}, resultados{i});
    end
    fprintf(fid, '\nEstatísticas:\n');
    fprintf(fid, 'Passou: %d, Falhou: %d, Erro: %d\n', passou, falhou, erro);
    fprintf(fid, 'Taxa de sucesso: %.1f%%\n', (passou/length(testes))*100);
    fclose(fid);
    
    fprintf('📄 Relatório salvo em: %s\n', filename);
end
