function executar_segmentacao_standalone()
    % EXECUTAR_SEGMENTACAO_STANDALONE - Executa apenas a segmentação de imagens
    %
    % Esta função executa apenas a etapa de segmentação do sistema completo,
    % carregando modelos já treinados e aplicando-os nas imagens de teste.
    %
    % Pré-requisitos:
    %   - modelo_unet.mat deve existir no diretório raiz
    %   - modelo_attention_unet.mat deve existir no diretório raiz
    %   - Imagens de teste devem estar em: C:\Users\heito\Documents\MATLAB\img\imagens apos treinamento\original
    %
    % Uso: executar_segmentacao_standalone()
    %
    % Autor: Sistema de Segmentação Completo
    % Data: 2025
    
    fprintf('\n');
    fprintf('========================================\n');
    fprintf('    SEGMENTAÇÃO DE IMAGENS - STANDALONE\n');
    fprintf('========================================\n');
    fprintf('Executando apenas a etapa de segmentação...\n\n');
    
    % Adicionar caminhos necessários
    addpath(genpath('src'));
    
    try
        % Configuração de caminhos
        caminhoImagens = 'C:\Users\heito\Documents\MATLAB\img\imagens apos treinamento\original';
        caminhoSaida = 'resultados_segmentacao';
        
        fprintf('[1/4] Verificando arquivos necessários...\n');
        
        % Verificar se as imagens existem
        if ~exist(caminhoImagens, 'dir')
            error('Pasta de imagens não encontrada: %s', caminhoImagens);
        end
        
        % Contar imagens
        arquivos = dir(fullfile(caminhoImagens, '*.png'));
        if isempty(arquivos)
            arquivos = dir(fullfile(caminhoImagens, '*.jpg'));
        end
        
        if isempty(arquivos)
            error('Nenhuma imagem encontrada em: %s', caminhoImagens);
        end
        
        fprintf('   ✅ %d imagens encontradas\n', length(arquivos));
        
        % Verificar modelos
        if ~exist('modelo_unet.mat', 'file')
            error('Modelo U-Net não encontrado: modelo_unet.mat');
        end
        
        if ~exist('modelo_attention_unet.mat', 'file')
            error('Modelo Attention U-Net não encontrado: modelo_attention_unet.mat');
        end
        
        fprintf('   ✅ Ambos os modelos encontrados\n');
        
        fprintf('[2/4] Carregando modelos treinados...\n');
        
        % Carregar modelo U-Net
        dadosUNet = load('modelo_unet.mat');
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
        
        % Carregar modelo Attention U-Net
        dadosAttention = load('modelo_attention_unet.mat');
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
        
        fprintf('[3/4] Criando estrutura de saída...\n');
        
        % Criar pastas de saída
        pastas = {
            caminhoSaida,
            fullfile(caminhoSaida, 'unet'),
            fullfile(caminhoSaida, 'attention_unet')
        };
        
        for i = 1:length(pastas)
            if ~exist(pastas{i}, 'dir')
                mkdir(pastas{i});
                fprintf('   ✅ Pasta criada: %s\n', pastas{i});
            else
                fprintf('   ✅ Pasta já existe: %s\n', pastas{i});
            end
        end
        
        fprintf('[4/4] Executando segmentação...\n');
        
        % Criar segmentador e executar
        segmentador = SegmentadorImagens(caminhoImagens, modeloUNet, modeloAttention, caminhoSaida);
        
        % Mostrar informações do segmentador
        info = segmentador.obterInformacoes();
        fprintf('   → Número de imagens: %d\n', info.numeroImagens);
        fprintf('   → Caminho de saída: %s\n', caminhoSaida);
        
        % Executar segmentação
        segmentador.segmentar();
        
        fprintf('\n========================================\n');
        fprintf('🎉 SEGMENTAÇÃO CONCLUÍDA COM SUCESSO! 🎉\n');
        fprintf('========================================\n');
        fprintf('Resultados salvos em:\n');
        fprintf('  - U-Net: %s\n', fullfile(caminhoSaida, 'unet'));
        fprintf('  - Attention U-Net: %s\n', fullfile(caminhoSaida, 'attention_unet'));
        fprintf('\nTotal de imagens processadas: %d\n', info.numeroImagens);
        
    catch ME
        fprintf('\n❌ ERRO DURANTE A SEGMENTAÇÃO:\n');
        fprintf('Mensagem: %s\n', ME.message);
        if ~isempty(ME.stack)
            fprintf('Arquivo: %s\n', ME.stack(1).file);
            fprintf('Linha: %d\n', ME.stack(1).line);
        end
        fprintf('\nExecução interrompida.\n');
        rethrow(ME);
    end
end