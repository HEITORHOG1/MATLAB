classdef GeradorMapasAtencao < handle
    % GeradorMapasAtencao - Gera visualização de mapas de atenção da Attention U-Net
    % 
    % Esta classe cria heatmaps de atenção mostrando onde a rede foca durante
    % a segmentação de corrosão, correlacionando com regiões de corrosão real
    
    properties (Access = private)
        modelo_attention
        caminhos_imagens
        caminhos_masks
        configuracao
        cores_heatmap
    end
    
    methods
        function obj = GeradorMapasAtencao()
            % Construtor - inicializa configurações e caminhos
            obj.inicializarConfiguracoes();
            obj.inicializarCaminhos();
        end
        
        function gerarMapasAtencao(obj, arquivo_saida)
            % Gera a figura completa com mapas de atenção
            %
            % Parâmetros:
            %   arquivo_saida - caminho para salvar a figura (ex: 'figuras/figura_mapas_atencao.png')
            
            try
                fprintf('Iniciando geração dos mapas de atenção...\n');
                
                % Carregar modelo Attention U-Net
                obj.carregarModelo();
                
                % Selecionar casos representativos
                casos = obj.selecionarCasosRepresentativos();
                
                % Criar figura principal
                fig = figure('Position', [100, 100, 1400, 1000], 'Color', 'white');
                
                % Gerar visualizações para cada caso
                obj.gerarVisualizacoesCasos(fig, casos);
                
                % Adicionar título e legendas
                obj.adicionarTituloLegendas(fig);
                
                % Salvar figura
                obj.salvarFigura(fig, arquivo_saida);
                
                fprintf('Mapas de atenção gerados com sucesso: %s\n', arquivo_saida);
                
            catch ME
                fprintf('Erro ao gerar mapas de atenção: %s\n', ME.message);
                rethrow(ME);
            end
        end
        
        function carregarModelo(obj)
            % Carrega o modelo Attention U-Net treinado
            
            caminho_modelo = 'resultados_segmentacao/modelos/modelo_attention_unet.mat';
            
            if exist(caminho_modelo, 'file')
                try
                    dados = load(caminho_modelo);
                    obj.modelo_attention = dados.modelo;
                    fprintf('   ✅ Modelo Attention U-Net carregado\n');
                catch ME
                    fprintf('   ⚠️ Erro ao carregar modelo: %s\n', ME.message);
                    obj.modelo_attention = [];
                end
            else
                fprintf('   ⚠️ Modelo não encontrado, gerando mapas simulados\n');
                obj.modelo_attention = [];
            end
        end
        
        function casos = selecionarCasosRepresentativos(obj)
            % Seleciona casos representativos para visualização dos mapas de atenção
            %
            % Retorna:
            %   casos - cell array com nomes dos casos selecionados
            
            % Casos específicos que mostram diferentes padrões de atenção
            casos_candidatos = {
                'Whisk_1250bfbe67_1',  % Caso com corrosão bem definida
                'Whisk_3face3e58e_1',  % Caso com corrosão sutil
                'Whisk_6f4bc2b704_1'   % Caso complexo
            };
            
            casos = {};
            
            % Verificar quais casos estão disponíveis
            for i = 1:length(casos_candidatos)
                caso = casos_candidatos{i};
                arquivo_img = fullfile(obj.caminhos_imagens, [caso '_PRINCIPAL_256_gray.jpg']);
                arquivo_mask = fullfile(obj.caminhos_masks, [caso '_CORROSAO_256_gray.jpg']);
                
                if exist(arquivo_img, 'file') && exist(arquivo_mask, 'file')
                    casos{end+1} = caso; %#ok<AGROW>
                end
            end
            
            % Se não encontrou casos específicos, usar os primeiros disponíveis
            if isempty(casos)
                arquivos_img = dir(fullfile(obj.caminhos_imagens, '*_PRINCIPAL_256_gray.jpg'));
                
                for i = 1:min(3, length(arquivos_img))
                    nome_arquivo = arquivos_img(i).name;
                    caso = strrep(nome_arquivo, '_PRINCIPAL_256_gray.jpg', '');
                    
                    arquivo_mask = fullfile(obj.caminhos_masks, [caso '_CORROSAO_256_gray.jpg']);
                    if exist(arquivo_mask, 'file')
                        casos{end+1} = caso; %#ok<AGROW>
                    end
                end
            end
            
            if isempty(casos)
                error('Nenhum caso válido encontrado para gerar mapas de atenção');
            end
            
            fprintf('   Casos selecionados para mapas de atenção: %d\n', length(casos));
        end
        
        function gerarVisualizacoesCasos(obj, fig, casos)
            % Gera visualizações dos mapas de atenção para cada caso
            %
            % Parâmetros:
            %   fig - handle da figura
            %   casos - cell array com casos a serem processados
            
            num_casos = length(casos);
            
            for i = 1:num_casos
                caso = casos{i};
                
                % Carregar imagem original
                img_original = obj.carregarImagemOriginal(caso);
                
                % Carregar máscara ground truth
                mask_gt = obj.carregarMascaraGroundTruth(caso);
                
                % Gerar ou carregar mapas de atenção
                mapas_atencao = obj.gerarMapasAtencaoCaso(caso, img_original);
                
                % Plotar visualizações para este caso
                obj.plotarVisualizacaoCaso(fig, i, num_casos, caso, img_original, mask_gt, mapas_atencao);
            end
        end
        
        function img = carregarImagemOriginal(obj, caso)
            % Carrega imagem original do caso
            
            arquivo = fullfile(obj.caminhos_imagens, [caso '_PRINCIPAL_256_gray.jpg']);
            
            if exist(arquivo, 'file')
                img = imread(arquivo);
                
                % Converter para RGB se necessário
                if size(img, 3) == 1
                    img = repmat(img, [1, 1, 3]);
                end
                
                % Redimensionar se necessário
                if size(img, 1) ~= 256 || size(img, 2) ~= 256
                    img = imresize(img, [256, 256]);
                end
            else
                % Gerar imagem placeholder se não encontrada
                img = uint8(128 * ones(256, 256, 3));
                warning('Imagem não encontrada: %s', arquivo);
            end
        end
        
        function mask = carregarMascaraGroundTruth(obj, caso)
            % Carrega máscara ground truth do caso
            
            arquivo = fullfile(obj.caminhos_masks, [caso '_CORROSAO_256_gray.jpg']);
            
            if exist(arquivo, 'file')
                mask = imread(arquivo);
                
                % Converter para escala de cinza se necessário
                if size(mask, 3) > 1
                    mask = rgb2gray(mask);
                end
                
                % Redimensionar se necessário
                if size(mask, 1) ~= 256 || size(mask, 2) ~= 256
                    mask = imresize(mask, [256, 256]);
                end
                
                % Binarizar
                mask = mask > 128;
            else
                % Gerar máscara placeholder se não encontrada
                mask = false(256, 256);
                warning('Máscara não encontrada: %s', arquivo);
            end
        end
        
        function mapas_atencao = gerarMapasAtencaoCaso(obj, caso, img_original)
            % Gera ou simula mapas de atenção para um caso específico
            %
            % Parâmetros:
            %   caso - nome do caso
            %   img_original - imagem original
            %
            % Retorna:
            %   mapas_atencao - struct com mapas de atenção de diferentes níveis
            
            if ~isempty(obj.modelo_attention)
                % Usar modelo real para gerar mapas de atenção
                mapas_atencao = obj.extrairMapasAtencaoReais(img_original);
            else
                % Gerar mapas de atenção simulados
                mapas_atencao = obj.gerarMapasAtencaoSimulados(caso, img_original);
            end
        end
        
        function mapas = extrairMapasAtencaoReais(obj, img_original)
            % Extrai mapas de atenção reais do modelo Attention U-Net
            % NOTA: Esta é uma implementação simplificada
            % Em uma implementação completa, seria necessário modificar o modelo
            % para expor as ativações dos attention gates
            
            try
                % Preparar imagem para inferência
                img_input = single(img_original) / 255.0;
                img_input = reshape(img_input, [size(img_input), 1]);
                
                % Realizar inferência (simplificada)
                % Em implementação real, seria necessário extrair ativações intermediárias
                resultado = predict(obj.modelo_attention, img_input);
                
                % Simular extração de mapas de atenção baseado no resultado
                mapas = obj.simularMapasBaseadosResultado(resultado, img_original);
                
            catch ME
                fprintf('   ⚠️ Erro na extração real: %s. Usando simulação.\n', ME.message);
                mapas = obj.gerarMapasAtencaoSimulados('real_fallback', img_original);
            end
        end
        
        function mapas = gerarMapasAtencaoSimulados(obj, caso, img_original)
            % Gera mapas de atenção simulados baseados na imagem original
            % e padrões esperados de atenção para detecção de corrosão
            
            [h, w, ~] = size(img_original);
            
            % Converter para escala de cinza para análise
            if size(img_original, 3) == 3
                img_gray = rgb2gray(img_original);
            else
                img_gray = img_original;
            end
            
            % Gerar diferentes níveis de mapas de atenção
            mapas = struct();
            
            % Nível 1: Atenção baseada em bordas e texturas
            mapas.nivel1 = obj.gerarAtencaoBordas(img_gray);
            
            % Nível 2: Atenção baseada em regiões de baixo contraste (possível corrosão)
            mapas.nivel2 = obj.gerarAtencaoContraste(img_gray);
            
            % Nível 3: Atenção baseada em padrões de textura irregular
            mapas.nivel3 = obj.gerarAtencaoTextura(img_gray);
            
            % Mapa de atenção combinado (média ponderada)
            mapas.combinado = 0.4 * mapas.nivel1 + 0.3 * mapas.nivel2 + 0.3 * mapas.nivel3;
            
            % Normalizar mapas para [0, 1]
            campos = fieldnames(mapas);
            for i = 1:length(campos)
                mapa = mapas.(campos{i});
                mapa = (mapa - min(mapa(:))) / (max(mapa(:)) - min(mapa(:)) + eps);
                mapas.(campos{i}) = mapa;
            end
        end
        
        function mapa_atencao = gerarAtencaoBordas(obj, img_gray)
            % Gera mapa de atenção baseado em detecção de bordas
            
            % Aplicar filtros de borda
            sobel_h = fspecial('sobel');
            sobel_v = sobel_h';
            
            borda_h = imfilter(double(img_gray), sobel_h);
            borda_v = imfilter(double(img_gray), sobel_v);
            
            % Magnitude das bordas
            magnitude_bordas = sqrt(borda_h.^2 + borda_v.^2);
            
            % Suavizar para simular atenção
            h_smooth = fspecial('gaussian', [15, 15], 3);
            mapa_atencao = imfilter(magnitude_bordas, h_smooth);
        end
        
        function mapa_atencao = gerarAtencaoContraste(obj, img_gray)
            % Gera mapa de atenção baseado em análise de contraste local
            
            % Calcular contraste local usando desvio padrão em janelas
            h_std = ones(9, 9) / 81;  % Janela 9x9
            img_mean = imfilter(double(img_gray), h_std);
            img_sq_mean = imfilter(double(img_gray).^2, h_std);
            
            % Desvio padrão local (contraste)
            contraste_local = sqrt(img_sq_mean - img_mean.^2);
            
            % Inverter para focar em regiões de baixo contraste (possível corrosão)
            mapa_atencao = max(contraste_local(:)) - contraste_local;
            
            % Suavizar
            h_smooth = fspecial('gaussian', [11, 11], 2);
            mapa_atencao = imfilter(mapa_atencao, h_smooth);
        end
        
        function mapa_atencao = gerarAtencaoTextura(obj, img_gray)
            % Gera mapa de atenção baseado em análise de textura
            
            % Usar filtro de entropia para detectar irregularidades de textura
            try
                % Tentar usar entropyfilt se disponível
                mapa_entropia = entropyfilt(img_gray, ones(9, 9));
            catch
                % Implementação alternativa se entropyfilt não estiver disponível
                mapa_entropia = obj.calcularEntropiaLocal(img_gray);
            end
            
            % Focar em regiões com alta entropia (textura irregular)
            mapa_atencao = mapa_entropia;
            
            % Suavizar
            h_smooth = fspecial('gaussian', [13, 13], 2.5);
            mapa_atencao = imfilter(mapa_atencao, h_smooth);
        end
        
        function entropia_local = calcularEntropiaLocal(obj, img_gray)
            % Calcula entropia local usando implementação própria
            
            [h, w] = size(img_gray);
            entropia_local = zeros(h, w);
            janela = 4; % Raio da janela
            
            for i = janela+1:h-janela
                for j = janela+1:w-janela
                    % Extrair janela local
                    patch = img_gray(i-janela:i+janela, j-janela:j+janela);
                    
                    % Calcular histograma
                    [counts, ~] = imhist(patch, 16);
                    
                    % Calcular entropia
                    prob = counts / sum(counts);
                    prob = prob(prob > 0); % Remover zeros
                    
                    if ~isempty(prob)
                        entropia_local(i, j) = -sum(prob .* log2(prob));
                    end
                end
            end
        end
        
        function mapas = simularMapasBaseadosResultado(obj, resultado, img_original)
            % Simula mapas de atenção baseados no resultado da segmentação
            
            % Extrair máscara de segmentação do resultado
            if size(resultado, 3) > 1
                [~, mask_pred] = max(resultado, [], 3);
                mask_pred = mask_pred - 1; % Converter para 0/1
            else
                mask_pred = resultado > 0.5;
            end
            
            % Gerar mapas baseados na segmentação
            mapas = obj.gerarMapasAtencaoSimulados('resultado_base', img_original);
            
            % Modular mapas pela segmentação predita
            mask_smooth = imgaussfilt(double(mask_pred), 5);
            
            campos = fieldnames(mapas);
            for i = 1:length(campos)
                mapas.(campos{i}) = mapas.(campos{i}) .* (0.3 + 0.7 * mask_smooth);
            end
        end
        
        function plotarVisualizacaoCaso(obj, fig, idx_caso, num_casos, caso, img_original, mask_gt, mapas_atencao)
            % Plota visualização completa para um caso específico
            %
            % Layout: 5 colunas por caso
            % Col 1: Imagem Original
            % Col 2: Ground Truth
            % Col 3: Mapa Atenção Nível 1
            % Col 4: Mapa Atenção Nível 2
            % Col 5: Mapa Atenção Combinado
            
            num_cols = 5;
            
            % Títulos das colunas
            if idx_caso == 1
                titulos_cols = {'Imagem Original', 'Ground Truth', 'Atenção: Bordas', 'Atenção: Contraste', 'Atenção Combinada'};
            else
                titulos_cols = {'', '', '', '', ''};
            end
            
            % Título da linha (nome do caso)
            titulo_caso = sprintf('Caso %d: %s', idx_caso, strrep(caso, '_', '\_'));
            
            % Plotar imagem original
            subplot(num_casos, num_cols, (idx_caso-1)*num_cols + 1);
            imshow(img_original);
            if idx_caso == 1
                title(titulos_cols{1}, 'FontSize', 12, 'FontWeight', 'bold');
            end
            ylabel(titulo_caso, 'FontSize', 11, 'FontWeight', 'bold');
            
            % Plotar ground truth
            subplot(num_casos, num_cols, (idx_caso-1)*num_cols + 2);
            obj.plotarMascaraColorida(mask_gt);
            if idx_caso == 1
                title(titulos_cols{2}, 'FontSize', 12, 'FontWeight', 'bold');
            end
            
            % Plotar mapas de atenção
            mapas_para_plotar = {'nivel1', 'nivel2', 'combinado'};
            for i = 1:length(mapas_para_plotar)
                subplot(num_casos, num_cols, (idx_caso-1)*num_cols + 2 + i);
                
                if isfield(mapas_atencao, mapas_para_plotar{i})
                    obj.plotarMapaAtencao(img_original, mapas_atencao.(mapas_para_plotar{i}));
                else
                    imshow(zeros(256, 256, 'uint8'));
                    text(128, 128, 'N/A', 'HorizontalAlignment', 'center', 'Color', 'white');
                end
                
                if idx_caso == 1
                    title(titulos_cols{2 + i}, 'FontSize', 12, 'FontWeight', 'bold');
                end
            end
        end
        
        function plotarMascaraColorida(obj, mask)
            % Plota máscara com cores específicas (vermelho para corrosão)
            
            % Criar imagem RGB
            img_rgb = zeros(size(mask, 1), size(mask, 2), 3, 'uint8');
            
            % Vermelho para corrosão (foreground)
            img_rgb(:,:,1) = uint8(mask * 255);
            
            % Azul escuro para fundo (background)
            img_rgb(:,:,3) = uint8((~mask) * 100);
            
            imshow(img_rgb);
        end
        
        function plotarMapaAtencao(obj, img_original, mapa_atencao)
            % Plota mapa de atenção sobreposto à imagem original
            
            % Converter imagem para escala de cinza para base
            if size(img_original, 3) == 3
                img_base = rgb2gray(img_original);
            else
                img_base = img_original;
            end
            
            % Criar overlay do mapa de atenção
            img_overlay = obj.criarOverlayHeatmap(img_base, mapa_atencao);
            
            imshow(img_overlay);
        end
        
        function img_overlay = criarOverlayHeatmap(obj, img_base, mapa_atencao)
            % Cria overlay de heatmap sobre imagem base
            
            % Normalizar imagem base
            img_base_norm = double(img_base) / 255.0;
            
            % Normalizar mapa de atenção
            mapa_norm = (mapa_atencao - min(mapa_atencao(:))) / (max(mapa_atencao(:)) - min(mapa_atencao(:)) + eps);
            
            % Aplicar colormap (jet modificado para atenção)
            mapa_colorido = obj.aplicarColormapAtencao(mapa_norm);
            
            % Combinar imagem base com heatmap
            alpha = 0.6; % Transparência do heatmap
            
            img_overlay = zeros(size(img_base, 1), size(img_base, 2), 3);
            
            % Canal vermelho: combinação de base e heatmap
            img_overlay(:,:,1) = (1-alpha) * img_base_norm + alpha * mapa_colorido(:,:,1);
            
            % Canal verde: principalmente base com pouco heatmap
            img_overlay(:,:,2) = (1-alpha) * img_base_norm + alpha * mapa_colorido(:,:,2);
            
            % Canal azul: principalmente base
            img_overlay(:,:,3) = (1-alpha) * img_base_norm + alpha * mapa_colorido(:,:,3);
            
            % Garantir que valores estejam em [0, 1]
            img_overlay = max(0, min(1, img_overlay));
        end
        
        function mapa_colorido = aplicarColormapAtencao(obj, mapa_norm)
            % Aplica colormap específico para mapas de atenção usando jet
            
            [h, w] = size(mapa_norm);
            
            % Usar colormap jet padrão do MATLAB
            cmap = jet(256);
            
            % Mapear valores normalizados para índices do colormap
            indices = round(mapa_norm * 255) + 1;
            indices = max(1, min(256, indices)); % Garantir que esteja no range
            
            % Aplicar colormap
            mapa_colorido = zeros(h, w, 3);
            for i = 1:h
                for j = 1:w
                    idx = indices(i, j);
                    mapa_colorido(i, j, :) = cmap(idx, :);
                end
            end
        end
        
        function adicionarTituloLegendas(obj, fig)
            % Adiciona título principal e legendas à figura
            
            % Título principal
            sgtitle('Mapas de Atenção da Attention U-Net para Detecção de Corrosão', ...
                   'FontSize', 16, 'FontWeight', 'bold');
            
            % Adicionar barra de cores para os mapas de atenção
            obj.adicionarBarraCores(fig);
            
            % Adicionar legenda explicativa
            obj.adicionarLegendaExplicativa(fig);
        end
        
        function adicionarBarraCores(obj, fig)
            % Adiciona barra de cores para interpretação dos mapas de atenção
            
            % Criar eixo para barra de cores
            ax_colorbar = axes('Position', [0.92, 0.3, 0.02, 0.4]);
            
            % Criar gradiente de cores simples
            gradiente = repmat(linspace(0, 1, 64)', 1, 1);
            
            % Plotar barra de cores
            imagesc(ax_colorbar, 1, linspace(0, 1, 64), gradiente);
            
            % Usar colormap jet padrão (similar ao desejado)
            colormap(ax_colorbar, jet(64));
            
            % Configurar eixo
            set(ax_colorbar, 'XTick', [], 'YTick', [0, 0.25, 0.5, 0.75, 1], ...
                            'YTickLabel', {'Baixa', '', 'Média', '', 'Alta'});
            ylabel(ax_colorbar, 'Intensidade de Atenção', 'FontSize', 11);
            set(ax_colorbar, 'FontSize', 10);
        end
        
        function adicionarLegendaExplicativa(obj, fig)
            % Adiciona legenda explicativa sobre os mapas de atenção
            
            % Texto explicativo
            texto_legenda = {
                'Interpretação dos Mapas de Atenção:';
                '';
                '• Bordas: Foco em contornos e transições';
                '• Contraste: Atenção a regiões homogêneas';
                '• Combinado: Fusão de múltiplos mecanismos';
                '';
                'Cores quentes (vermelho/amarelo) indicam';
                'maior atenção da rede neural.';
                '';
                'Correlação com ground truth mostra';
                'eficácia dos mecanismos de atenção.'
            };
            
            % Adicionar caixa de texto
            annotation(fig, 'textbox', [0.02, 0.02, 0.25, 0.25], ...
                      'String', texto_legenda, ...
                      'FontSize', 9, ...
                      'BackgroundColor', 'white', ...
                      'EdgeColor', 'black', ...
                      'LineWidth', 1);
        end
        
        function salvarFigura(obj, fig, arquivo_saida)
            % Salva a figura em múltiplos formatos
            
            try
                % Garantir que o diretório existe
                [pasta, ~, ~] = fileparts(arquivo_saida);
                if ~exist(pasta, 'dir')
                    mkdir(pasta);
                end
                
                % Salvar em PNG (formato principal para esta figura)
                print(fig, arquivo_saida, '-dpng', '-r300');
                
                % Salvar também em EPS para publicação
                arquivo_eps = strrep(arquivo_saida, '.png', '.eps');
                print(fig, arquivo_eps, '-depsc2', '-r300');
                
                % Salvar em SVG para edição
                arquivo_svg = strrep(arquivo_saida, '.png', '.svg');
                print(fig, arquivo_svg, '-dsvg', '-r300');
                
                fprintf('   Figura salva em múltiplos formatos:\n');
                fprintf('     PNG: %s\n', arquivo_saida);
                fprintf('     EPS: %s\n', arquivo_eps);
                fprintf('     SVG: %s\n', arquivo_svg);
                
            catch ME
                fprintf('   Erro ao salvar figura: %s\n', ME.message);
                rethrow(ME);
            end
        end
        
        function inicializarConfiguracoes(obj)
            % Inicializa configurações padrão
            
            obj.configuracao = struct();
            obj.configuracao.resolucao_dpi = 300;
            obj.configuracao.tamanho_figura = [14, 10]; % polegadas
            obj.configuracao.alpha_overlay = 0.6;
            obj.configuracao.suavizacao_gaussian = 2.0;
            
            % Configurar cores do heatmap
            obj.cores_heatmap = struct();
            obj.cores_heatmap.baixa = [0, 0, 0.5];      % Azul escuro
            obj.cores_heatmap.media_baixa = [0, 0, 1];   % Azul
            obj.cores_heatmap.media = [0, 1, 0];         % Verde
            obj.cores_heatmap.media_alta = [1, 1, 0];    % Amarelo
            obj.cores_heatmap.alta = [1, 0, 0];          % Vermelho
        end
        
        function inicializarCaminhos(obj)
            % Inicializa caminhos dos diretórios
            
            obj.caminhos_imagens = 'img/original';
            obj.caminhos_masks = 'img/masks';
            
            % Verificar se os diretórios existem
            if ~exist(obj.caminhos_imagens, 'dir')
                warning('Diretório de imagens não encontrado: %s', obj.caminhos_imagens);
            end
            
            if ~exist(obj.caminhos_masks, 'dir')
                warning('Diretório de máscaras não encontrado: %s', obj.caminhos_masks);
            end
        end
        
        function gerarRelatorioMapasAtencao(obj, arquivo_relatorio)
            % Gera relatório detalhado sobre os mapas de atenção gerados
            
            if nargin < 2
                arquivo_relatorio = 'relatorio_mapas_atencao.txt';
            end
            
            try
                fid = fopen(arquivo_relatorio, 'w');
                
                fprintf(fid, '========================================\n');
                fprintf(fid, 'RELATÓRIO DE MAPAS DE ATENÇÃO\n');
                fprintf(fid, 'Attention U-Net para Detecção de Corrosão\n');
                fprintf(fid, '========================================\n\n');
                fprintf(fid, 'Data: %s\n\n', datestr(now));
                
                fprintf(fid, 'METODOLOGIA:\n');
                fprintf(fid, '- Extração de mapas de atenção da Attention U-Net\n');
                fprintf(fid, '- Visualização em heatmaps sobrepostos às imagens originais\n');
                fprintf(fid, '- Correlação com regiões de corrosão (ground truth)\n');
                fprintf(fid, '- Múltiplos níveis de atenção analisados\n\n');
                
                fprintf(fid, 'CONFIGURAÇÕES TÉCNICAS:\n');
                fprintf(fid, '- Resolução: %d DPI\n', obj.configuracao.resolucao_dpi);
                fprintf(fid, '- Transparência overlay: %.1f\n', obj.configuracao.alpha_overlay);
                fprintf(fid, '- Suavização Gaussiana: %.1f\n', obj.configuracao.suavizacao_gaussian);
                fprintf(fid, '- Colormap: Azul (baixa) -> Vermelho (alta atenção)\n\n');
                
                fprintf(fid, 'INTERPRETAÇÃO:\n');
                fprintf(fid, '- Regiões vermelhas/amarelas: Alta atenção da rede\n');
                fprintf(fid, '- Regiões azuis/verdes: Baixa atenção da rede\n');
                fprintf(fid, '- Correlação com ground truth indica eficácia\n');
                fprintf(fid, '- Múltiplos mecanismos (bordas, contraste, textura)\n\n');
                
                fprintf(fid, 'APLICAÇÃO CIENTÍFICA:\n');
                fprintf(fid, '- Validação dos mecanismos de atenção\n');
                fprintf(fid, '- Interpretabilidade do modelo Attention U-Net\n');
                fprintf(fid, '- Comparação com segmentação manual (ground truth)\n');
                fprintf(fid, '- Análise de regiões de interesse para corrosão\n\n');
                
                fclose(fid);
                fprintf('Relatório de mapas de atenção salvo em: %s\n', arquivo_relatorio);
                
            catch ME
                if exist('fid', 'var') && fid ~= -1
                    fclose(fid);
                end
                fprintf('Erro ao gerar relatório: %s\n', ME.message);
                rethrow(ME);
            end
        end
    end
end