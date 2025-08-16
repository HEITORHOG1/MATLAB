function teste_organizador_resultados()
    % Teste completo da classe OrganizadorResultados
    % 
    % Este teste valida todas as funcionalidades do organizador:
    % - Criação de estrutura de pastas
    % - Organização de arquivos de segmentação
    % - Organização de modelos
    % - Criação de índices
    % - Recuperação de erros
    
    fprintf('=== TESTE DO ORGANIZADOR DE RESULTADOS ===\n\n');
    
    try
        % Limpa resultados de testes anteriores
        limparResultadosTeste();
        
        % Teste 1: Criação da estrutura básica
        fprintf('Teste 1: Criação de estrutura de pastas...\n');
        testeEstruturaPastas();
        
        % Teste 2: Nomenclatura consistente
        fprintf('\nTeste 2: Nomenclatura consistente...\n');
        testeNomenclaturaConsistente();
        
        % Teste 3: Organização de arquivos de segmentação
        fprintf('\nTeste 3: Organização de arquivos de segmentação...\n');
        testeOrganizacaoSegmentacao();
        
        % Teste 4: Organização de modelos
        fprintf('\nTeste 4: Organização de modelos...\n');
        testeOrganizacaoModelos();
        
        % Teste 5: Criação de índice
        fprintf('\nTeste 5: Criação de índice de arquivos...\n');
        testeCriacaoIndice();
        
        % Teste 6: Recuperação de erros
        fprintf('\nTeste 6: Recuperação de erros...\n');
        testeRecuperacaoErros();
        
        % Teste 7: Método estático de organização rápida
        fprintf('\nTeste 7: Organização rápida...\n');
        testeOrganizacaoRapida();
        
        fprintf('\n✅ TODOS OS TESTES PASSARAM COM SUCESSO!\n');
        
    catch ME
        fprintf('\n❌ ERRO NO TESTE: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
    
    % Limpa arquivos de teste
    limparResultadosTeste();
end

function testeEstruturaPastas()
    % Testa criação da estrutura de pastas
    
    organizador = OrganizadorResultados('teste_resultados');
    
    % Verifica estado inicial
    assert(~organizador.estruturaCriada, 'Estrutura não deveria estar criada inicialmente');
    
    % Cria estrutura
    sucesso = organizador.criarEstruturaPastas();
    assert(sucesso, 'Falha ao criar estrutura de pastas');
    assert(organizador.estruturaCriada, 'Flag de estrutura criada não foi definida');
    
    % Verifica se todas as pastas foram criadas
    pastas = {
        'teste_resultados',
        'teste_resultados/unet',
        'teste_resultados/attention_unet',
        'teste_resultados/comparacoes',
        'teste_resultados/relatorios',
        'teste_resultados/modelos'
    };
    
    for i = 1:length(pastas)
        assert(exist(pastas{i}, 'dir') == 7, 'Pasta não foi criada: %s', pastas{i});
    end
    
    fprintf('  ✓ Estrutura de pastas criada corretamente\n');
end

function testeNomenclaturaConsistente()
    % Testa geração de nomes consistentes
    
    organizador = OrganizadorResultados();
    
    % Testa diferentes tipos de entrada
    casos = {
        {'imagem001.jpg', 'unet', 'png', 'imagem001_unet.png'},
        {'teste.png', 'attention_unet', 'png', 'teste_attention.png'},
        {'foto.tif', 'attention', 'png', 'foto_attention.png'},
        {'sem_extensao', 'unet', 'jpg', 'sem_extensao_unet.jpg'}
    };
    
    for i = 1:length(casos)
        caso = casos{i};
        resultado = organizador.gerarNomeConsistente(caso{1}, caso{2}, caso{3});
        esperado = caso{4};
        assert(strcmp(resultado, esperado), ...
            'Nomenclatura incorreta. Esperado: %s, Obtido: %s', esperado, resultado);
    end
    
    fprintf('  ✓ Nomenclatura consistente funcionando\n');
end

function testeOrganizacaoSegmentacao()
    % Testa organização de arquivos de segmentação
    
    organizador = OrganizadorResultados('teste_resultados');
    organizador.criarEstruturaPastas();
    
    % Cria arquivos de teste
    criarArquivoTeste('temp_seg_unet.png');
    criarArquivoTeste('temp_seg_attention.png');
    
    % Organiza arquivos
    sucesso1 = organizador.organizarArquivoSegmentacao('temp_seg_unet.png', 'imagem001.png', 'unet');
    sucesso2 = organizador.organizarArquivoSegmentacao('temp_seg_attention.png', 'imagem001.png', 'attention_unet');
    
    assert(sucesso1, 'Falha ao organizar arquivo U-Net');
    assert(sucesso2, 'Falha ao organizar arquivo Attention U-Net');
    
    % Verifica se arquivos foram criados nos locais corretos
    assert(exist('teste_resultados/unet/imagem001_unet.png', 'file') == 2, ...
        'Arquivo U-Net não foi organizado corretamente');
    assert(exist('teste_resultados/attention_unet/imagem001_attention.png', 'file') == 2, ...
        'Arquivo Attention U-Net não foi organizado corretamente');
    
    % Verifica índices
    assert(length(organizador.indiceArquivos.unet) == 1, 'Índice U-Net incorreto');
    assert(length(organizador.indiceArquivos.attention_unet) == 1, 'Índice Attention U-Net incorreto');
    
    fprintf('  ✓ Organização de segmentações funcionando\n');
end

function testeOrganizacaoModelos()
    % Testa organização de modelos treinados
    
    organizador = OrganizadorResultados('teste_resultados');
    organizador.criarEstruturaPastas();
    
    % Cria arquivos de modelo de teste
    criarArquivoTeste('temp_modelo_unet.mat');
    criarArquivoTeste('temp_modelo_attention.mat');
    
    % Organiza modelos
    sucesso1 = organizador.organizarModelo('temp_modelo_unet.mat', 'modelo_unet');
    sucesso2 = organizador.organizarModelo('temp_modelo_attention.mat', 'modelo_attention_unet');
    
    assert(sucesso1, 'Falha ao organizar modelo U-Net');
    assert(sucesso2, 'Falha ao organizar modelo Attention U-Net');
    
    % Verifica se modelos foram organizados
    assert(exist('teste_resultados/modelos/modelo_unet.mat', 'file') == 2, ...
        'Modelo U-Net não foi organizado corretamente');
    assert(exist('teste_resultados/modelos/modelo_attention_unet.mat', 'file') == 2, ...
        'Modelo Attention U-Net não foi organizado corretamente');
    
    % Verifica índice de modelos
    assert(length(organizador.indiceArquivos.modelos) == 2, 'Índice de modelos incorreto');
    
    fprintf('  ✓ Organização de modelos funcionando\n');
end

function testeCriacaoIndice()
    % Testa criação do arquivo de índice
    
    organizador = OrganizadorResultados('teste_resultados');
    organizador.criarEstruturaPastas();
    
    % Adiciona alguns itens aos índices para teste
    organizador.indiceArquivos.unet{1} = struct(...
        'original', 'teste1.png', ...
        'organizado', 'teste1_unet.png', ...
        'caminho', 'teste_resultados/unet/teste1_unet.png', ...
        'timestamp', datetime('now'));
    
    organizador.indiceArquivos.attention_unet{1} = struct(...
        'original', 'teste1.png', ...
        'organizado', 'teste1_attention.png', ...
        'caminho', 'teste_resultados/attention_unet/teste1_attention.png', ...
        'timestamp', datetime('now'));
    
    % Cria índice
    sucesso = organizador.criarIndiceArquivos();
    assert(sucesso, 'Falha ao criar índice de arquivos');
    
    % Verifica se arquivo foi criado
    assert(exist('teste_resultados/indice_arquivos.txt', 'file') == 2, ...
        'Arquivo de índice não foi criado');
    
    % Verifica conteúdo básico do índice
    conteudo = fileread('teste_resultados/indice_arquivos.txt');
    assert(contains(conteudo, 'ÍNDICE DE ARQUIVOS PROCESSADOS'), ...
        'Conteúdo do índice incorreto');
    assert(contains(conteudo, 'teste1_unet.png'), ...
        'Arquivo U-Net não listado no índice');
    assert(contains(conteudo, 'teste1_attention.png'), ...
        'Arquivo Attention U-Net não listado no índice');
    
    fprintf('  ✓ Criação de índice funcionando\n');
end

function testeRecuperacaoErros()
    % Testa recuperação de erros
    
    organizador = OrganizadorResultados('teste_resultados');
    
    % Remove uma pasta para simular erro
    if exist('teste_resultados/unet', 'dir')
        rmdir('teste_resultados/unet', 's');
    end
    
    % Tenta recuperar
    sucesso = organizador.recuperarDeErro();
    assert(sucesso, 'Falha na recuperação de erro');
    
    % Verifica se pasta foi recriada
    assert(exist('teste_resultados/unet', 'dir') == 7, ...
        'Pasta não foi recriada durante recuperação');
    
    fprintf('  ✓ Recuperação de erros funcionando\n');
end

function testeOrganizacaoRapida()
    % Testa método estático de organização rápida
    
    % Cria arquivos de teste
    arquivosUNet = {'temp_rapid_unet1.png', 'temp_rapid_unet2.png'};
    arquivosAttention = {'temp_rapid_att1.png', 'temp_rapid_att2.png'};
    modelos = {'temp_rapid_modelo1.mat', 'temp_rapid_modelo2.mat'};
    
    for i = 1:length(arquivosUNet)
        criarArquivoTeste(arquivosUNet{i});
    end
    for i = 1:length(arquivosAttention)
        criarArquivoTeste(arquivosAttention{i});
    end
    for i = 1:length(modelos)
        criarArquivoTeste(modelos{i});
    end
    
    % Executa organização rápida
    sucesso = OrganizadorResultados.organizarResultadosRapido(arquivosUNet, arquivosAttention, modelos);
    assert(sucesso, 'Falha na organização rápida');
    
    % Verifica se arquivos foram organizados
    assert(exist('resultados_segmentacao/unet/temp_rapid_unet1_unet.png', 'file') == 2, ...
        'Arquivo U-Net 1 não foi organizado');
    assert(exist('resultados_segmentacao/attention_unet/temp_rapid_att1_attention.png', 'file') == 2, ...
        'Arquivo Attention 1 não foi organizado');
    assert(exist('resultados_segmentacao/modelos/temp_rapid_modelo1.mat', 'file') == 2, ...
        'Modelo 1 não foi organizado');
    
    % Verifica se índice foi criado
    assert(exist('resultados_segmentacao/indice_arquivos.txt', 'file') == 2, ...
        'Índice não foi criado na organização rápida');
    
    fprintf('  ✓ Organização rápida funcionando\n');
end

function criarArquivoTeste(nomeArquivo)
    % Cria um arquivo de teste simples
    
    [caminho, nome, ext] = fileparts(nomeArquivo);
    
    if strcmp(ext, '.png') || strcmp(ext, '.jpg')
        % Cria imagem de teste simples
        img = uint8(rand(100, 100, 3) * 255);
        imwrite(img, nomeArquivo);
    elseif strcmp(ext, '.mat')
        % Cria arquivo MAT de teste
        dados_teste = struct('modelo', 'teste', 'timestamp', datetime('now'));
        save(nomeArquivo, 'dados_teste');
    else
        % Cria arquivo de texto simples
        fid = fopen(nomeArquivo, 'w');
        fprintf(fid, 'Arquivo de teste criado em %s\n', char(datetime('now')));
        fclose(fid);
    end
end

function limparResultadosTeste()
    % Remove arquivos e pastas de teste
    
    % Remove pastas de teste
    if exist('teste_resultados', 'dir')
        rmdir('teste_resultados', 's');
    end
    if exist('resultados_segmentacao', 'dir')
        rmdir('resultados_segmentacao', 's');
    end
    
    % Remove arquivos temporários
    arquivosTemp = {
        'temp_seg_unet.png', 'temp_seg_attention.png',
        'temp_modelo_unet.mat', 'temp_modelo_attention.mat',
        'temp_rapid_unet1.png', 'temp_rapid_unet2.png',
        'temp_rapid_att1.png', 'temp_rapid_att2.png',
        'temp_rapid_modelo1.mat', 'temp_rapid_modelo2.mat'
    };
    
    for i = 1:length(arquivosTemp)
        if exist(arquivosTemp{i}, 'file')
            delete(arquivosTemp{i});
        end
    end
end