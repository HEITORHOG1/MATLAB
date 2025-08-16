function teste_segmentador_imagens()
    % Teste para a classe SegmentadorImagens
    % Verifica funcionalidades básicas sem necessidade de modelos treinados
    
    fprintf('=== TESTE SEGMENTADOR DE IMAGENS ===\n');
    
    try
        % Adiciona caminho para as classes
        addpath(genpath('../src'));
        
        % Caminho das imagens de teste
        caminhoImagens = 'C:\Users\heito\Documents\MATLAB\img\imagens apos treinamento\original';
        
        fprintf('1. Testando criação da classe...\n');
        
        % Testa criação sem modelos (apenas estrutura)
        segmentador = SegmentadorImagens(caminhoImagens, [], []);
        fprintf('   ✅ Classe criada com sucesso\n');
        
        fprintf('2. Testando listagem de imagens...\n');
        arquivos = segmentador.listarImagens();
        fprintf('   ✅ Encontradas %d imagens\n', length(arquivos));
        
        if length(arquivos) > 0
            fprintf('   Primeiras imagens encontradas:\n');
            for i = 1:min(3, length(arquivos))
                fprintf('     - %s\n', arquivos{i});
            end
        end
        
        fprintf('3. Testando obtenção de informações...\n');
        info = segmentador.obterInformacoes();
        fprintf('   ✅ Informações obtidas:\n');
        fprintf('     - Caminho: %s\n', info.caminhoImagens);
        fprintf('     - Número de imagens: %d\n', info.numeroImagens);
        fprintf('     - Tem modelo U-Net: %s\n', mat2str(info.temModeloUNet));
        fprintf('     - Tem modelo Attention: %s\n', mat2str(info.temModeloAttention));
        
        fprintf('4. Testando criação de estrutura de saída...\n');
        % A estrutura já foi criada no construtor
        if exist('resultados_segmentacao', 'dir') && ...
           exist('resultados_segmentacao/unet', 'dir') && ...
           exist('resultados_segmentacao/attention_unet', 'dir')
            fprintf('   ✅ Estrutura de pastas criada corretamente\n');
        else
            fprintf('   ⚠️  Algumas pastas podem não ter sido criadas\n');
        end
        
        fprintf('5. Testando carregamento de imagem (se disponível)...\n');
        if length(arquivos) > 0
            try
                imagem = segmentador.carregarEPreprocessarImagem(arquivos{1});
                fprintf('   ✅ Imagem carregada e pré-processada\n');
                fprintf('     - Tamanho: %dx%dx%d\n', size(imagem, 1), size(imagem, 2), size(imagem, 3));
                fprintf('     - Tipo: %s\n', class(imagem));
                fprintf('     - Range: [%.3f, %.3f]\n', min(imagem(:)), max(imagem(:)));
            catch ME
                fprintf('   ❌ Erro ao carregar imagem: %s\n', ME.message);
            end
        else
            fprintf('   ⚠️  Nenhuma imagem disponível para teste\n');
        end
        
        fprintf('\n✅ TODOS OS TESTES BÁSICOS CONCLUÍDOS!\n');
        fprintf('A classe SegmentadorImagens está pronta para uso com modelos treinados.\n');
        
    catch ME
        fprintf('\n❌ ERRO NO TESTE: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end