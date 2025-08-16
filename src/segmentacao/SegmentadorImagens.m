classdef SegmentadorImagens < handle
    % SegmentadorImagens - Classe para aplicar modelos treinados em imagens
    % Esta classe carrega imagens de teste e aplica modelos U-Net e Attention U-Net
    % para gerar segmentações, salvando os resultados com nomenclatura clara.
    
    properties
        caminhoImagens          % Caminho para imagens de teste
        modeloUNet             % Modelo U-Net treinado
        modeloAttentionUNet    % Modelo Attention U-Net treinado
        caminhoSaida           % Caminho base para salvar resultados
        tamanhoImagem          % Tamanho padrão para redimensionamento
    end
    
    methods
        function obj = SegmentadorImagens(caminhoImagens, modeloUNet, modeloAttentionUNet, caminhoSaida)
            % Construtor da classe SegmentadorImagens
            %
            % Parâmetros:
            %   caminhoImagens - Caminho para pasta com imagens de teste
            %   modeloUNet - Modelo U-Net treinado
            %   modeloAttentionUNet - Modelo Attention U-Net treinado
            %   caminhoSaida - Caminho base para salvar resultados (opcional)
            
            obj.caminhoImagens = caminhoImagens;
            obj.modeloUNet = modeloUNet;
            obj.modeloAttentionUNet = modeloAttentionUNet;
            
            if nargin < 4
                obj.caminhoSaida = 'resultados_segmentacao';
            else
                obj.caminhoSaida = caminhoSaida;
            end
            
            % Tamanho padrão para imagens (pode ser ajustado conforme necessário)
            obj.tamanhoImagem = [256, 256];
            
            % Verifica se o caminho de imagens existe
            if ~exist(obj.caminhoImagens, 'dir')
                error('SegmentadorImagens:CaminhoInvalido', ...
                    'Caminho de imagens não encontrado: %s', obj.caminhoImagens);
            end
            
            % Cria estrutura de pastas de saída
            obj.criarEstruturaSaida();
        end
        
        function segmentar(obj)
            % Método principal para segmentar todas as imagens
            % Aplica ambos os modelos (U-Net e Attention U-Net) em todas as imagens
            
            fprintf('\n=== INICIANDO SEGMENTAÇÃO DE IMAGENS ===\n');
            
            try
                % Lista imagens para segmentar
                arquivosImagens = obj.listarImagens();
                
                if isempty(arquivosImagens)
                    warning('SegmentadorImagens:SemImagens', ...
                        'Nenhuma imagem encontrada em: %s', obj.caminhoImagens);
                    return;
                end
                
                fprintf('Encontradas %d imagens para segmentar\n', length(arquivosImagens));
                fprintf('Caminho: %s\n', obj.caminhoImagens);
                
                % Processa cada imagem
                for i = 1:length(arquivosImagens)
                    fprintf('\n[%d/%d] Processando: %s\n', i, length(arquivosImagens), arquivosImagens{i});
                    
                    try
                        % Carrega e pré-processa imagem
                        imagem = obj.carregarEPreprocessarImagem(arquivosImagens{i});
                        
                        % Aplica modelo U-Net
                        fprintf('  → Aplicando U-Net...\n');
                        segmentacaoUNet = obj.aplicarModelo(imagem, obj.modeloUNet);
                        obj.salvarSegmentacao(segmentacaoUNet, arquivosImagens{i}, 'unet');
                        
                        % Aplica modelo Attention U-Net
                        fprintf('  → Aplicando Attention U-Net...\n');
                        segmentacaoAttention = obj.aplicarModelo(imagem, obj.modeloAttentionUNet);
                        obj.salvarSegmentacao(segmentacaoAttention, arquivosImagens{i}, 'attention_unet');

                        % Salva imagem lado a lado: original + segmentação (Attention por padrão)
                        try
                            obj.salvarComparacaoLadoALado(imagem, segmentacaoAttention, arquivosImagens{i});
                        catch MEcmp
                            fprintf('  ⚠️  Falha ao salvar comparação lado a lado: %s\n', MEcmp.message);
                        end
                        
                        fprintf('  ✅ Concluído!\n');
                        
                    catch ME
                        fprintf('  ❌ Erro ao processar %s: %s\n', arquivosImagens{i}, ME.message);
                        continue;
                    end
                end
                
                fprintf('\n✅ SEGMENTAÇÃO CONCLUÍDA COM SUCESSO!\n');
                fprintf('Resultados salvos em:\n');
                fprintf('  - U-Net: %s\n', fullfile(obj.caminhoSaida, 'unet'));
                fprintf('  - Attention U-Net: %s\n', fullfile(obj.caminhoSaida, 'attention_unet'));
                
            catch ME
                fprintf('\n❌ ERRO DURANTE SEGMENTAÇÃO: %s\n', ME.message);
                rethrow(ME);
            end
        end
        
        function arquivos = listarImagens(obj)
            % Lista todas as imagens válidas na pasta de entrada
            % Retorna cell array com nomes dos arquivos
            
            extensoesValidas = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tiff', '*.tif'};
            arquivos = {};
            
            for i = 1:length(extensoesValidas)
                arquivosExt = dir(fullfile(obj.caminhoImagens, extensoesValidas{i}));
                for j = 1:length(arquivosExt)
                    if ~arquivosExt(j).isdir
                        arquivos{end+1} = arquivosExt(j).name; %#ok<AGROW>
                    end
                end
            end
            
            % Remove duplicatas e ordena
            arquivos = unique(arquivos);
            arquivos = sort(arquivos);
        end
        
        function imagem = carregarEPreprocessarImagem(obj, nomeArquivo)
            % Carrega e pré-processa uma imagem para segmentação
            % Aplica redimensionamento e normalização consistentes
            
            caminhoCompleto = fullfile(obj.caminhoImagens, nomeArquivo);
            
            try
                % Carrega imagem
                imagem = imread(caminhoCompleto);
                
                % Converte para RGB se necessário
                if size(imagem, 3) == 1
                    imagem = repmat(imagem, [1, 1, 3]);
                elseif size(imagem, 3) == 4
                    imagem = imagem(:, :, 1:3);
                end
                
                % Redimensiona para tamanho padrão
                imagem = imresize(imagem, obj.tamanhoImagem);
                
                % Normaliza para [0, 1]
                imagem = im2double(imagem);
                
            catch ME
                error('SegmentadorImagens:ErroCarregamento', ...
                    'Erro ao carregar imagem %s: %s', nomeArquivo, ME.message);
            end
        end
        
        function segmentacao = aplicarModelo(obj, imagem, modelo)
            % Aplica um modelo treinado na imagem
            % Retorna a segmentação resultante
            
            try
                % Verifica se o modelo é válido
                if isempty(modelo)
                    error('Modelo não fornecido ou vazio');
                end
                
                % Aplica o modelo
                if isa(modelo, 'SeriesNetwork') || isa(modelo, 'DAGNetwork')
                    % Modelo de deep learning
                    segmentacao = predict(modelo, imagem);
                elseif isa(modelo, 'dlnetwork')
                    % Modelo dlnetwork
                    imagemDL = dlarray(imagem, 'SSCB');
                    segmentacao = predict(modelo, imagemDL);
                    segmentacao = extractdata(segmentacao);
                else
                    error('Tipo de modelo não suportado: %s', class(modelo));
                end
                
                % Pós-processamento da segmentação
                segmentacao = obj.posProcessarSegmentacao(segmentacao);
                
            catch ME
                error('SegmentadorImagens:ErroModelo', ...
                    'Erro ao aplicar modelo: %s', ME.message);
            end
        end
        
        function segmentacao = posProcessarSegmentacao(obj, segmentacaoRaw)
            % Pós-processa a segmentação para formato final
            % Converte probabilidades em máscara binária
            
            % Se a segmentação tem múltiplas classes, pega a classe com maior probabilidade
            if size(segmentacaoRaw, 3) > 1
                [~, segmentacao] = max(segmentacaoRaw, [], 3);
                segmentacao = segmentacao - 1; % Converte para 0-1
            else
                % Segmentação binária - aplica threshold
                segmentacao = segmentacaoRaw > 0.5;
            end
            
            % Converte para uint8 para salvar
            segmentacao = uint8(segmentacao * 255);
        end
        
        function salvarSegmentacao(obj, segmentacao, nomeImagemOriginal, tipoModelo)
            % Salva a segmentação com nomenclatura clara
            % 
            % Parâmetros:
            %   segmentacao - Imagem segmentada
            %   nomeImagemOriginal - Nome da imagem original
            %   tipoModelo - 'unet' ou 'attention_unet'
            
            try
                % Cria nome do arquivo de saída
                [~, nomeBase, ~] = fileparts(nomeImagemOriginal);
                nomeArquivoSaida = sprintf('%s_%s.png', nomeBase, tipoModelo);
                
                % Define caminho completo
                pastaDestino = fullfile(obj.caminhoSaida, tipoModelo);
                caminhoCompleto = fullfile(pastaDestino, nomeArquivoSaida);
                
                % Salva a imagem
                imwrite(segmentacao, caminhoCompleto);
                
            catch ME
                error('SegmentadorImagens:ErroSalvamento', ...
                    'Erro ao salvar segmentação: %s', ME.message);
            end
        end
        
        function criarEstruturaSaida(obj)
            % Cria a estrutura de pastas para salvar os resultados
            
            pastasNecessarias = {
                obj.caminhoSaida,
                fullfile(obj.caminhoSaida, 'unet'),
                fullfile(obj.caminhoSaida, 'attention_unet'),
                fullfile(obj.caminhoSaida, 'comparacoes')
            };
            
            for i = 1:length(pastasNecessarias)
                if ~exist(pastasNecessarias{i}, 'dir')
                    mkdir(pastasNecessarias{i});
                end
            end
        end

        function salvarComparacaoLadoALado(obj, imagemOriginal, segmentacao, nomeImagemOriginal)
            % Cria e salva uma imagem com original e máscara lado a lado
            try
                if size(segmentacao,3) == 1
                    segRgb = cat(3, segmentacao, segmentacao, segmentacao);
                else
                    segRgb = segmentacao;
                end
                % Garantir uint8 para salvar
                if isa(imagemOriginal, 'double')
                    img = im2uint8(imagemOriginal);
                else
                    img = imagemOriginal;
                end
                if isa(segRgb, 'logical')
                    segRgb = uint8(segRgb) * 255;
                elseif isa(segRgb, 'double')
                    segRgb = im2uint8(segRgb);
                end

                combinado = [img, segRgb];
                [~, nomeBase, ~] = fileparts(nomeImagemOriginal);
                destino = fullfile(obj.caminhoSaida, 'comparacoes', sprintf('%s_original_vs_pred.png', nomeBase));
                imwrite(combinado, destino);
            catch ME
                error('SegmentadorImagens:ErroComparacao', 'Erro ao gerar lado a lado: %s', ME.message);
            end
        end
        
        function info = obterInformacoes(obj)
            % Retorna informações sobre o segmentador
            
            info = struct();
            info.caminhoImagens = obj.caminhoImagens;
            info.caminhoSaida = obj.caminhoSaida;
            info.tamanhoImagem = obj.tamanhoImagem;
            info.temModeloUNet = ~isempty(obj.modeloUNet);
            info.temModeloAttention = ~isempty(obj.modeloAttentionUNet);
            
            % Conta imagens disponíveis
            arquivos = obj.listarImagens();
            info.numeroImagens = length(arquivos);
            info.arquivosImagens = arquivos;
        end
    end
    
    methods (Static)
        function testar()
            % Método estático para testar a classe (para desenvolvimento)
            fprintf('Testando SegmentadorImagens...\n');
            
            % Caminhos de exemplo (ajustar conforme necessário)
            caminhoImagens = 'C:\Users\heito\Documents\MATLAB\img\imagens apos treinamento\original';
            
            try
                % Cria instância sem modelos (apenas para testar estrutura)
                segmentador = SegmentadorImagens(caminhoImagens, [], []);
                
                % Obtém informações
                info = segmentador.obterInformacoes();
                
                fprintf('Caminho de imagens: %s\n', info.caminhoImagens);
                fprintf('Número de imagens encontradas: %d\n', info.numeroImagens);
                
                if info.numeroImagens > 0
                    fprintf('Primeiras imagens:\n');
                    for i = 1:min(5, info.numeroImagens)
                        fprintf('  %d. %s\n', i, info.arquivosImagens{i});
                    end
                end
                
                fprintf('✅ Teste básico concluído!\n');
                
            catch ME
                fprintf('❌ Erro no teste: %s\n', ME.message);
            end
        end
    end
end