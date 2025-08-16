function demo_OrganizadorResultados()
    % Demonstração do uso da classe OrganizadorResultados
    % 
    % Este exemplo mostra como usar o organizador para estruturar
    % automaticamente os resultados de segmentação
    
    fprintf('=== DEMO: ORGANIZADOR DE RESULTADOS ===\n\n');
    
    try
        % Limpa resultados anteriores
        if exist('demo_resultados', 'dir')
            rmdir('demo_resultados', 's');
        end
        
        % 1. Criar organizador
        fprintf('1. Criando organizador...\n');
        organizador = OrganizadorResultados('demo_resultados');
        
        % 2. Criar estrutura de pastas
        fprintf('\n2. Criando estrutura de pastas...\n');
        sucesso = organizador.criarEstruturaPastas();
        if sucesso
            fprintf('✅ Estrutura criada com sucesso!\n');
        end
        
        % 3. Exibir estrutura
        fprintf('\n3. Estrutura criada:\n');
        organizador.exibirEstrutura();
        
        % 4. Simular organização de arquivos de segmentação
        fprintf('4. Simulando organização de segmentações...\n');
        
        % Cria arquivos de exemplo
        criarArquivosExemplo();
        
        % Organiza segmentações U-Net
        organizador.organizarArquivoSegmentacao('exemplo_seg_unet.png', 'imagem001.png', 'unet');
        organizador.organizarArquivoSegmentacao('exemplo_seg_unet2.png', 'imagem002.png', 'unet');
        
        % Organiza segmentações Attention U-Net
        organizador.organizarArquivoSegmentacao('exemplo_seg_attention.png', 'imagem001.png', 'attention_unet');
        organizador.organizarArquivoSegmentacao('exemplo_seg_attention2.png', 'imagem002.png', 'attention_unet');
        
        % 5. Organizar modelos
        fprintf('\n5. Organizando modelos treinados...\n');
        organizador.organizarModelo('exemplo_modelo_unet.mat', 'modelo_unet');
        organizador.organizarModelo('exemplo_modelo_attention.mat', 'modelo_attention_unet');
        
        % 6. Criar índice de arquivos
        fprintf('\n6. Criando índice de arquivos...\n');
        organizador.criarIndiceArquivos();
        
        % 7. Mostrar estatísticas
        fprintf('\n7. Estatísticas finais:\n');
        stats = organizador.obterEstatisticas();
        fprintf('   - Segmentações U-Net: %d\n', stats.total_unet);
        fprintf('   - Segmentações Attention U-Net: %d\n', stats.total_attention);
        fprintf('   - Modelos salvos: %d\n', stats.total_modelos);
        fprintf('   - Total de arquivos: %d\n', stats.total_geral);
        
        % 8. Mostrar conteúdo do índice
        fprintf('\n8. Conteúdo do índice:\n');
        if exist('demo_resultados/indice_arquivos.txt', 'file')
            conteudo = fileread('demo_resultados/indice_arquivos.txt');
            fprintf('--- INÍCIO DO ÍNDICE ---\n');
            fprintf('%s', conteudo);
            fprintf('--- FIM DO ÍNDICE ---\n');
        end
        
        % 9. Demonstrar organização rápida
        fprintf('\n9. Demonstrando organização rápida...\n');
        
        % Cria mais arquivos de exemplo
        criarArquivosRapidos();
        
        arquivosUNet = {'rapido_unet1.png', 'rapido_unet2.png'};
        arquivosAttention = {'rapido_att1.png', 'rapido_att2.png'};
        modelos = {'rapido_modelo1.mat'};
        
        sucesso = OrganizadorResultados.organizarResultadosRapido(arquivosUNet, arquivosAttention, modelos);
        if sucesso
            fprintf('✅ Organização rápida concluída!\n');
        end
        
        % 10. Verificar estrutura final
        fprintf('\n10. Estrutura final:\n');
        listarEstrutura('demo_resultados');
        listarEstrutura('resultados_segmentacao');
        
        fprintf('\n✅ DEMO CONCLUÍDA COM SUCESSO!\n');
        fprintf('\nArquivos organizados em:\n');
        fprintf('  - demo_resultados/\n');
        fprintf('  - resultados_segmentacao/\n');
        
    catch ME
        fprintf('\n❌ ERRO NA DEMO: %s\n', ME.message);
    end
    
    % Limpa arquivos temporários
    limparArquivosExemplo();
end

function criarArquivosExemplo()
    % Cria arquivos de exemplo para demonstração
    
    % Cria imagens de segmentação de exemplo
    img = uint8(rand(100, 100, 3) * 255);
    imwrite(img, 'exemplo_seg_unet.png');
    imwrite(img, 'exemplo_seg_unet2.png');
    imwrite(img, 'exemplo_seg_attention.png');
    imwrite(img, 'exemplo_seg_attention2.png');
    
    % Cria modelos de exemplo
    modelo_dados = struct('arquitetura', 'U-Net', 'treinado', datetime('now'));
    save('exemplo_modelo_unet.mat', 'modelo_dados');
    
    modelo_dados.arquitetura = 'Attention U-Net';
    save('exemplo_modelo_attention.mat', 'modelo_dados');
end

function criarArquivosRapidos()
    % Cria arquivos para demonstração da organização rápida
    
    img = uint8(rand(50, 50, 3) * 255);
    imwrite(img, 'rapido_unet1.png');
    imwrite(img, 'rapido_unet2.png');
    imwrite(img, 'rapido_att1.png');
    imwrite(img, 'rapido_att2.png');
    
    modelo_dados = struct('tipo', 'rapido', 'criado', datetime('now'));
    save('rapido_modelo1.mat', 'modelo_dados');
end

function listarEstrutura(pasta)
    % Lista a estrutura de uma pasta
    
    if ~exist(pasta, 'dir')
        return;
    end
    
    fprintf('\n%s/\n', pasta);
    
    % Lista subpastas
    subpastas = dir(pasta);
    subpastas = subpastas([subpastas.isdir]);
    subpastas = subpastas(~ismember({subpastas.name}, {'.', '..'}));
    
    for i = 1:length(subpastas)
        subpasta = subpastas(i).name;
        fprintf('├── %s/\n', subpasta);
        
        % Lista arquivos na subpasta
        arquivos = dir(fullfile(pasta, subpasta, '*.*'));
        arquivos = arquivos(~[arquivos.isdir]);
        
        for j = 1:length(arquivos)
            if j == length(arquivos)
                fprintf('│   └── %s\n', arquivos(j).name);
            else
                fprintf('│   ├── %s\n', arquivos(j).name);
            end
        end
    end
    
    % Lista arquivos na pasta raiz
    arquivos = dir(fullfile(pasta, '*.*'));
    arquivos = arquivos(~[arquivos.isdir]);
    
    for i = 1:length(arquivos)
        fprintf('└── %s\n', arquivos(i).name);
    end
end

function limparArquivosExemplo()
    % Remove arquivos de exemplo criados
    
    arquivos = {
        'exemplo_seg_unet.png', 'exemplo_seg_unet2.png', ...
        'exemplo_seg_attention.png', 'exemplo_seg_attention2.png', ...
        'exemplo_modelo_unet.mat', 'exemplo_modelo_attention.mat', ...
        'rapido_unet1.png', 'rapido_unet2.png', ...
        'rapido_att1.png', 'rapido_att2.png', ...
        'rapido_modelo1.mat'
    };
    
    for i = 1:length(arquivos)
        if exist(arquivos{i}, 'file')
            delete(arquivos{i});
        end
    end
end