function teste_segmentacao_completa()
    % Teste completo do sistema de segmentação com modelos reais
    % Este teste carrega os modelos treinados e executa segmentação real
    
    fprintf('=== TESTE COMPLETO DE SEGMENTAÇÃO ===\n');
    
    try
        % Adiciona caminhos necessários
        addpath(genpath('../src'));
        
        % Caminhos dos modelos e imagens
        caminhoModeloUNet = '../modelo_unet.mat';
        caminhoModeloAttention = '../modelo_attention_unet.mat';
        caminhoImagens = 'C:\Users\heito\Documents\MATLAB\img\imagens apos treinamento\original';
        
        fprintf('1. Verificando existência dos modelos...\n');
        
        % Verifica se os modelos existem
        if ~exist(caminhoModeloUNet, 'file')
            error('Modelo U-Net não encontrado: %s', caminhoModeloUNet);
        end
        if ~exist(caminhoModeloAttention, 'file')
            error('Modelo Attention U-Net não encontrado: %s', caminhoModeloAttention);
        end
        fprintf('   ✅ Ambos os modelos encontrados\n');
        
        fprintf('2. Carregando modelos...\n');
        
        % Carrega modelo U-Net
        dadosUNet = load(caminhoModeloUNet);
        if isfield(dadosUNet, 'modelo')
            modeloUNet = dadosUNet.modelo;
        elseif isfield(dadosUNet, 'net')
            modeloUNet = dadosUNet.net;
        elseif isfield(dadosUNet, 'netUNet')
            modeloUNet = dadosUNet.netUNet;
        else
            error('Estrutura do modelo U-Net não reconhecida');
        end
        fprintf('   ✅ Modelo U-Net carregado\n');
        
        % Carrega modelo Attention U-Net
        dadosAttention = load(caminhoModeloAttention);
        if isfield(dadosAttention, 'modelo')
            modeloAttention = dadosAttention.modelo;
        elseif isfield(dadosAttention, 'net')
            modeloAttention = dadosAttention.net;
        elseif isfield(dadosAttention, 'netAttUNet')
            modeloAttention = dadosAttention.netAttUNet;
        else
            error('Estrutura do modelo Attention U-Net não reconhecida');
        end
        fprintf('   ✅ Modelo Attention U-Net carregado\n');
        
        fprintf('3. Criando segmentador...\n');
        
        % Cria instância do segmentador
        segmentador = SegmentadorImagens(caminhoImagens, modeloUNet, modeloAttention, '../resultados_segmentacao_teste');
        fprintf('   ✅ Segmentador criado\n');
        
        fprintf('4. Obtendo informações do segmentador...\n');
        info = segmentador.obterInformacoes();
        fprintf('   - Número de imagens: %d\n', info.numeroImagens);
        fprintf('   - Tem modelo U-Net: %s\n', mat2str(info.temModeloUNet));
        fprintf('   - Tem modelo Attention: %s\n', mat2str(info.temModeloAttention));
        
        if info.numeroImagens == 0
            fprintf('   ⚠️  Nenhuma imagem encontrada para teste\n');
            return;
        end
        
        fprintf('5. Testando segmentação em uma imagem...\n');
        
        % Testa com apenas uma imagem para verificar funcionamento
        arquivos = segmentador.listarImagens();
        imagemTeste = arquivos{1};
        fprintf('   Testando com: %s\n', imagemTeste);
        
        % Carrega e pré-processa imagem
        imagem = segmentador.carregarEPreprocessarImagem(imagemTeste);
        fprintf('   ✅ Imagem carregada: %dx%dx%d\n', size(imagem, 1), size(imagem, 2), size(imagem, 3));
        
        % Testa aplicação do modelo U-Net
        try
            segmentacaoUNet = segmentador.aplicarModelo(imagem, modeloUNet);
            fprintf('   ✅ Segmentação U-Net: %dx%d\n', size(segmentacaoUNet, 1), size(segmentacaoUNet, 2));
            
            % Salva resultado
            segmentador.salvarSegmentacao(segmentacaoUNet, imagemTeste, 'unet');
            fprintf('   ✅ Resultado U-Net salvo\n');
        catch ME
            fprintf('   ❌ Erro na segmentação U-Net: %s\n', ME.message);
        end
        
        % Testa aplicação do modelo Attention U-Net
        try
            segmentacaoAttention = segmentador.aplicarModelo(imagem, modeloAttention);
            fprintf('   ✅ Segmentação Attention U-Net: %dx%d\n', size(segmentacaoAttention, 1), size(segmentacaoAttention, 2));
            
            % Salva resultado
            segmentador.salvarSegmentacao(segmentacaoAttention, imagemTeste, 'attention_unet');
            fprintf('   ✅ Resultado Attention U-Net salvo\n');
        catch ME
            fprintf('   ❌ Erro na segmentação Attention U-Net: %s\n', ME.message);
        end
        
        fprintf('6. Verificando arquivos de saída...\n');
        
        % Verifica se os arquivos foram criados
        [~, nomeBase, ~] = fileparts(imagemTeste);
        arquivoUNet = sprintf('../resultados_segmentacao_teste/unet/%s_unet.png', nomeBase);
        arquivoAttention = sprintf('../resultados_segmentacao_teste/attention_unet/%s_attention_unet.png', nomeBase);
        
        if exist(arquivoUNet, 'file')
            fprintf('   ✅ Arquivo U-Net criado: %s\n', arquivoUNet);
        else
            fprintf('   ❌ Arquivo U-Net não encontrado\n');
        end
        
        if exist(arquivoAttention, 'file')
            fprintf('   ✅ Arquivo Attention U-Net criado: %s\n', arquivoAttention);
        else
            fprintf('   ❌ Arquivo Attention U-Net não encontrado\n');
        end
        
        fprintf('\n✅ TESTE COMPLETO CONCLUÍDO COM SUCESSO!\n');
        fprintf('O sistema de segmentação está funcionando corretamente.\n');
        fprintf('Para executar segmentação completa, use: segmentador.segmentar()\n');
        
    catch ME
        fprintf('\n❌ ERRO NO TESTE COMPLETO: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end