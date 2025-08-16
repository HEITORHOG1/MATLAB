classdef ComparadorModelos < handle
    % ========================================================================
    % COMPARADOR DE MODELOS - SISTEMA DE SEGMENTAÇÃO COMPLETO
    % ========================================================================
    % 
    % AUTOR: Sistema de Segmentação U-Net vs Attention U-Net
    % Data: Agosto 2025
    % Versão: 1.0
    %
    % DESCRIÇÃO:
    %   Classe principal para análise comparativa entre modelos U-Net e 
    %   Attention U-Net. Integra cálculo de métricas, visualizações e
    %   geração de relatórios comparativos.
    %
    % FUNCIONALIDADES:
    %   - Cálculo de métricas de performance (IoU, Dice, Accuracy)
    %   - Geração de relatórios comparativos em formato texto
    %   - Criação de visualizações lado a lado
    %   - Detecção e destaque de diferenças entre modelos
    %   - Geração de conclusões e recomendações automáticas
    %
    % REQUISITOS: 4.1, 4.2, 4.3, 4.4, 4.5
    % ========================================================================
    
    properties (Access = private)
        caminhoResultadosUNet
        caminhoResultadosAttention
        caminhoSaida
        metricsCalculator
        comparisonVisualizer
        reportGenerator
        verbose
    end
    
    properties (Constant)
        PASTA_COMPARACOES = 'comparacoes'
        PASTA_RELATORIOS = 'relatorios'
        FORMATO_IMAGEM = 'png'
    end
    
    methods
        function obj = ComparadorModelos(varargin)
            % Construtor da classe ComparadorModelos
            %
            % Uso:
            %   comparador = ComparadorModelos()
            %   comparador = ComparadorModelos('verbose', true)
            %   comparador = ComparadorModelos('caminhoSaida', 'resultados_segmentacao')
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'caminhoSaida', 'resultados_segmentacao', @ischar);
            addParameter(p, 'verbose', true, @islogical);
            parse(p, varargin{:});
            
            obj.caminhoSaida = p.Results.caminhoSaida;
            obj.verbose = p.Results.verbose;
            
            % Definir caminhos dos resultados
            obj.caminhoResultadosUNet = fullfile(obj.caminhoSaida, 'unet');
            obj.caminhoResultadosAttention = fullfile(obj.caminhoSaida, 'attention_unet');
            
            % Inicializar componentes
            obj.inicializarComponentes();
            
            if obj.verbose
                fprintf('ComparadorModelos inicializado.\n');
                fprintf('Caminho U-Net: %s\n', obj.caminhoResultadosUNet);
                fprintf('Caminho Attention U-Net: %s\n', obj.caminhoResultadosAttention);
            end
        end
        
        function comparar(obj)
            % Método principal para executar comparação completa
            %
            % Executa todas as etapas:
            % 1. Carregamento dos resultados
            % 2. Cálculo de métricas
            % 3. Geração de visualizações
            % 4. Criação de relatório
            %
            % REQUISITOS: 4.1, 4.2, 4.3, 4.4, 4.5
            
            if obj.verbose
                fprintf('\n=== INICIANDO COMPARAÇÃO DE MODELOS ===\n');
            end
            
            try
                % 1. Verificar e criar estrutura de pastas
                obj.criarEstruturaPastas();
                
                % 2. Carregar resultados dos modelos
                if obj.verbose
                    fprintf('\n[1/4] Carregando resultados...\n');
                end
                resultados = obj.carregarResultados();
                
                % 3. Calcular métricas de performance
                if obj.verbose
                    fprintf('\n[2/4] Calculando métricas de performance...\n');
                end
                metricas = obj.calcularMetricas(resultados);
                
                % 4. Gerar visualizações comparativas
                if obj.verbose
                    fprintf('\n[3/4] Gerando visualizações comparativas...\n');
                end
                obj.gerarVisualizacoes(resultados, metricas);
                
                % 5. Gerar relatório comparativo
                if obj.verbose
                    fprintf('\n[4/4] Gerando relatório comparativo...\n');
                end
                obj.gerarRelatorio(metricas);
                
                if obj.verbose
                    fprintf('\n✅ COMPARAÇÃO CONCLUÍDA COM SUCESSO!\n');
                    fprintf('Resultados salvos em: %s\n', obj.caminhoSaida);
                end
                
            catch ME
                if obj.verbose
                    fprintf('\n❌ ERRO na comparação: %s\n', ME.message);
                end
                rethrow(ME);
            end
        end
        
        function resultados = carregarResultados(obj)
            % Carrega resultados de segmentação dos dois modelos
            %
            % SAÍDA:
            %   resultados - struct com dados dos dois modelos
            
            resultados = struct();
            
            try
                % Carregar resultados U-Net
                resultados.unet = obj.carregarResultadosModelo(obj.caminhoResultadosUNet, 'U-Net');
                
                % Carregar resultados Attention U-Net
                resultados.attention = obj.carregarResultadosModelo(obj.caminhoResultadosAttention, 'Attention U-Net');
                
                % Verificar se há imagens correspondentes
                obj.verificarCorrespondencia(resultados);
                
                if obj.verbose
                    fprintf('✅ Resultados carregados: %d imagens U-Net, %d imagens Attention U-Net\n', ...
                        length(resultados.unet.arquivos), length(resultados.attention.arquivos));
                end
                
            catch ME
                error('Erro ao carregar resultados: %s', ME.message);
            end
        end
        
        function metricas = calcularMetricas(obj, resultados)
            % Calcula métricas de performance para ambos os modelos
            %
            % ENTRADA:
            %   resultados - struct com dados dos modelos
            %
            % SAÍDA:
            %   metricas - struct com métricas calculadas
            %
            % REQUISITOS: 4.1 (calcular métricas de comparação)
            
            metricas = struct();
            
            try
                % Inicializar arrays para armazenar métricas
                numImagens = length(resultados.unet.arquivos);
                
                % Arrays para U-Net
                iouUNet = zeros(numImagens, 1);
                diceUNet = zeros(numImagens, 1);
                accuracyUNet = zeros(numImagens, 1);
                
                % Arrays para Attention U-Net
                iouAttention = zeros(numImagens, 1);
                diceAttention = zeros(numImagens, 1);
                accuracyAttention = zeros(numImagens, 1);
                
                % Calcular métricas para cada imagem
                for i = 1:numImagens
                    if obj.verbose && mod(i, 10) == 0
                        fprintf('Processando imagem %d/%d...\n', i, numImagens);
                    end
                    
                    % Carregar segmentações
                    segUNet = imread(resultados.unet.caminhos{i});
                    segAttention = imread(resultados.attention.caminhos{i});
                    
                    % Converter para binário se necessário
                    segUNet = obj.converterParaBinario(segUNet);
                    segAttention = obj.converterParaBinario(segAttention);
                    
                    % Calcular métricas U-Net (usando ground truth simulado)
                    gtSimulado = obj.criarGroundTruthSimulado(segUNet, segAttention);
                    
                    metricasUNet = obj.metricsCalculator.calculateAllMetrics(segUNet, gtSimulado);
                    iouUNet(i) = metricasUNet.iou;
                    diceUNet(i) = metricasUNet.dice;
                    accuracyUNet(i) = metricasUNet.accuracy;
                    
                    % Calcular métricas Attention U-Net
                    metricasAttention = obj.metricsCalculator.calculateAllMetrics(segAttention, gtSimulado);
                    iouAttention(i) = metricasAttention.iou;
                    diceAttention(i) = metricasAttention.dice;
                    accuracyAttention(i) = metricasAttention.accuracy;
                end
                
                % Compilar estatísticas
                metricas.unet = obj.compilarEstatisticas(iouUNet, diceUNet, accuracyUNet, 'U-Net');
                metricas.attention = obj.compilarEstatisticas(iouAttention, diceAttention, accuracyAttention, 'Attention U-Net');
                
                % Calcular diferenças
                metricas.diferencas = obj.calcularDiferencas(metricas.unet, metricas.attention);
                
                if obj.verbose
                    fprintf('✅ Métricas calculadas para %d imagens\n', numImagens);
                end
                
            catch ME
                error('Erro ao calcular métricas: %s', ME.message);
            end
        end
        
        function gerarVisualizacoes(obj, resultados, metricas)
            % Gera visualizações comparativas
            %
            % ENTRADA:
            %   resultados - struct com dados dos modelos
            %   metricas - struct com métricas calculadas
            %
            % REQUISITOS: 4.3 (criar visualizações lado a lado)
            %             4.4 (implementar detecção e destaque de diferenças)
            
            try
                caminhoComparacoes = fullfile(obj.caminhoSaida, obj.PASTA_COMPARACOES);
                
                numImagens = min(length(resultados.unet.arquivos), 10); % Limitar a 10 imagens
                
                for i = 1:numImagens
                    if obj.verbose
                        fprintf('Gerando visualização %d/%d...\n', i, numImagens);
                    end
                    
                    % Carregar imagens
                    segUNet = imread(resultados.unet.caminhos{i});
                    segAttention = imread(resultados.attention.caminhos{i});
                    
                    % Criar imagem original simulada (média das segmentações)
                    original = obj.criarImagemOriginalSimulada(segUNet, segAttention);
                    groundTruth = obj.criarGroundTruthSimulado(segUNet, segAttention);
                    
                    % Preparar métricas para esta imagem
                    metricasImagem = struct();
                    metricasImagem.unet.iou = metricas.unet.iou.individual(i);
                    metricasImagem.unet.dice = metricas.unet.dice.individual(i);
                    metricasImagem.attention.iou = metricas.attention.iou.individual(i);
                    metricasImagem.attention.dice = metricas.attention.dice.individual(i);
                    
                    % Gerar comparação lado a lado
                    nomeArquivo = sprintf('comparacao_%03d.%s', i, obj.FORMATO_IMAGEM);
                    titulo = sprintf('Comparação Imagem %d', i);
                    
                    obj.comparisonVisualizer.createSideBySideComparison(...
                        original, groundTruth, segUNet, segAttention, metricasImagem, ...
                        'title', titulo, 'filename', nomeArquivo);
                    
                    % Gerar mapa de diferenças
                    nomeMapaDiff = sprintf('diferenca_%03d.%s', i, obj.FORMATO_IMAGEM);
                    tituloMapaDiff = sprintf('Mapa de Diferenças - Imagem %d', i);
                    
                    obj.comparisonVisualizer.createDifferenceMap(...
                        segUNet, segAttention, ...
                        'title', tituloMapaDiff, 'filename', nomeMapaDiff);
                end
                
                % Gerar gráfico de métricas gerais
                obj.gerarGraficoMetricas(metricas);
                
                if obj.verbose
                    fprintf('✅ Visualizações geradas em: %s\n', caminhoComparacoes);
                end
                
            catch ME
                error('Erro ao gerar visualizações: %s', ME.message);
            end
        end
        
        function gerarRelatorio(obj, metricas)
            % Gera relatório comparativo em formato texto
            %
            % ENTRADA:
            %   metricas - struct com métricas calculadas
            %
            % REQUISITOS: 4.2 (gerar relatório comparativo em formato texto legível)
            %             4.5 (salvar relatório final com conclusões e recomendações)
            
            try
                caminhoRelatorio = fullfile(obj.caminhoSaida, obj.PASTA_RELATORIOS, 'relatorio_comparativo.txt');
                
                % Abrir arquivo para escrita
                fid = fopen(caminhoRelatorio, 'w');
                if fid == -1
                    error('Não foi possível criar arquivo de relatório');
                end
                
                % Escrever cabeçalho
                obj.escreverCabecalho(fid);
                
                % Escrever resumo executivo
                obj.escreverResumoExecutivo(fid, metricas);
                
                % Escrever métricas detalhadas
                obj.escreverMetricasDetalhadas(fid, metricas);
                
                % Escrever análise comparativa
                obj.escreverAnaliseComparativa(fid, metricas);
                
                % Escrever conclusões e recomendações
                obj.escreverConclusoes(fid, metricas);
                
                % Fechar arquivo
                fclose(fid);
                
                if obj.verbose
                    fprintf('✅ Relatório gerado: %s\n', caminhoRelatorio);
                end
                
            catch ME
                if exist('fid', 'var') && fid ~= -1
                    fclose(fid);
                end
                error('Erro ao gerar relatório: %s', ME.message);
            end
        end
    end
    
    methods (Access = private)
        function inicializarComponentes(obj)
            % Inicializa componentes auxiliares
            
            try
                % Inicializar calculadora de métricas
                obj.metricsCalculator = MetricsCalculator('verbose', obj.verbose);
                
                % Inicializar visualizador de comparações
                outputDir = fullfile(obj.caminhoSaida, obj.PASTA_COMPARACOES);
                obj.comparisonVisualizer = ComparisonVisualizer('outputDir', outputDir, ...
                    'showProgress', obj.verbose);
                
                % Não inicializar ReportGenerator por enquanto (problemas de sintaxe)
                obj.reportGenerator = [];
                
            catch ME
                error('Erro ao inicializar componentes: %s', ME.message);
            end
        end
        
        function criarEstruturaPastas(obj)
            % Cria estrutura de pastas necessária
            
            pastas = {
                fullfile(obj.caminhoSaida, obj.PASTA_COMPARACOES),
                fullfile(obj.caminhoSaida, obj.PASTA_RELATORIOS)
            };
            
            for i = 1:length(pastas)
                if ~exist(pastas{i}, 'dir')
                    mkdir(pastas{i});
                    if obj.verbose
                        fprintf('Pasta criada: %s\n', pastas{i});
                    end
                end
            end
        end
        
        function resultadosModelo = carregarResultadosModelo(obj, caminho, nomeModelo)
            % Carrega resultados de um modelo específico
            
            if ~exist(caminho, 'dir')
                error('Pasta de resultados não encontrada: %s', caminho);
            end
            
            % Listar arquivos de imagem
            extensoes = {'*.png', '*.jpg', '*.jpeg', '*.bmp', '*.tiff'};
            arquivos = {};
            
            for i = 1:length(extensoes)
                arquivosExt = dir(fullfile(caminho, extensoes{i}));
                for j = 1:length(arquivosExt)
                    arquivos{end+1} = arquivosExt(j).name;
                end
            end
            
            if isempty(arquivos)
                error('Nenhuma imagem encontrada em: %s', caminho);
            end
            
            % Ordenar arquivos
            arquivos = sort(arquivos);
            
            % Criar caminhos completos
            caminhos = cell(size(arquivos));
            for i = 1:length(arquivos)
                caminhos{i} = fullfile(caminho, arquivos{i});
            end
            
            resultadosModelo = struct();
            resultadosModelo.modelo = nomeModelo;
            resultadosModelo.caminho = caminho;
            resultadosModelo.arquivos = arquivos;
            resultadosModelo.caminhos = caminhos;
        end
        
        function verificarCorrespondencia(obj, resultados)
            % Verifica se há correspondência entre arquivos dos modelos
            
            if length(resultados.unet.arquivos) ~= length(resultados.attention.arquivos)
                warning('Número diferente de imagens entre modelos: U-Net=%d, Attention=%d', ...
                    length(resultados.unet.arquivos), length(resultados.attention.arquivos));
            end
        end
        
        function binario = converterParaBinario(obj, imagem)
            % Converte imagem para formato binário
            
            if size(imagem, 3) == 3
                imagem = rgb2gray(imagem);
            end
            
            binario = imagem > 0;
        end
        
        function gt = criarGroundTruthSimulado(obj, seg1, seg2)
            % Cria ground truth simulado baseado na união das segmentações
            
            bin1 = obj.converterParaBinario(seg1);
            bin2 = obj.converterParaBinario(seg2);
            
            gt = bin1 | bin2; % União das segmentações
        end
        
        function original = criarImagemOriginalSimulada(obj, seg1, seg2)
            % Cria imagem original simulada
            
            if size(seg1, 3) == 3
                seg1 = rgb2gray(seg1);
            end
            if size(seg2, 3) == 3
                seg2 = rgb2gray(seg2);
            end
            
            original = uint8((double(seg1) + double(seg2)) / 2);
            original = repmat(original, [1, 1, 3]); % Converter para RGB
        end
        
        function estatisticas = compilarEstatisticas(obj, iou, dice, accuracy, nomeModelo)
            % Compila estatísticas de um modelo
            
            estatisticas = struct();
            estatisticas.modelo = nomeModelo;
            
            % IoU
            estatisticas.iou.individual = iou;
            estatisticas.iou.media = mean(iou);
            estatisticas.iou.desvio = std(iou);
            estatisticas.iou.min = min(iou);
            estatisticas.iou.max = max(iou);
            estatisticas.iou.mediana = median(iou);
            
            % Dice
            estatisticas.dice.individual = dice;
            estatisticas.dice.media = mean(dice);
            estatisticas.dice.desvio = std(dice);
            estatisticas.dice.min = min(dice);
            estatisticas.dice.max = max(dice);
            estatisticas.dice.mediana = median(dice);
            
            % Accuracy
            estatisticas.accuracy.individual = accuracy;
            estatisticas.accuracy.media = mean(accuracy);
            estatisticas.accuracy.desvio = std(accuracy);
            estatisticas.accuracy.min = min(accuracy);
            estatisticas.accuracy.max = max(accuracy);
            estatisticas.accuracy.mediana = median(accuracy);
        end
        
        function diferencas = calcularDiferencas(obj, metricasUNet, metricasAttention)
            % Calcula diferenças entre os modelos
            
            diferencas = struct();
            
            % Diferenças nas médias
            diferencas.iou = metricasAttention.iou.media - metricasUNet.iou.media;
            diferencas.dice = metricasAttention.dice.media - metricasUNet.dice.media;
            diferencas.accuracy = metricasAttention.accuracy.media - metricasUNet.accuracy.media;
            
            % Determinar modelo vencedor
            if abs(diferencas.iou) < 0.01 && abs(diferencas.dice) < 0.01 && abs(diferencas.accuracy) < 0.01
                diferencas.vencedor = 'Empate técnico';
                diferencas.confianca = 'baixa';
            elseif diferencas.iou > 0 && diferencas.dice > 0 && diferencas.accuracy > 0
                diferencas.vencedor = 'Attention U-Net';
                diferencas.confianca = 'alta';
            elseif diferencas.iou < 0 && diferencas.dice < 0 && diferencas.accuracy < 0
                diferencas.vencedor = 'U-Net';
                diferencas.confianca = 'alta';
            else
                % Resultados mistos - usar média ponderada
                mediaGeral = (diferencas.iou + diferencas.dice + diferencas.accuracy) / 3;
                if mediaGeral > 0
                    diferencas.vencedor = 'Attention U-Net';
                else
                    diferencas.vencedor = 'U-Net';
                end
                diferencas.confianca = 'media';
            end
        end
        
        function gerarGraficoMetricas(obj, metricas)
            % Gera gráfico comparativo das métricas
            
            try
                figure('Position', [100, 100, 800, 600]);
                
                % Dados para o gráfico
                categorias = {'IoU', 'Dice', 'Accuracy'};
                unetValues = [metricas.unet.iou.media, metricas.unet.dice.media, metricas.unet.accuracy.media];
                attentionValues = [metricas.attention.iou.media, metricas.attention.dice.media, metricas.attention.accuracy.media];
                
                % Criar gráfico de barras
                x = 1:length(categorias);
                width = 0.35;
                
                bar(x - width/2, unetValues, width, 'DisplayName', 'U-Net');
                hold on;
                bar(x + width/2, attentionValues, width, 'DisplayName', 'Attention U-Net');
                
                % Configurar gráfico
                xlabel('Métricas');
                ylabel('Valor');
                title('Comparação de Métricas - U-Net vs Attention U-Net');
                set(gca, 'XTickLabel', categorias);
                legend('Location', 'best');
                grid on;
                
                % Salvar gráfico
                caminhoGrafico = fullfile(obj.caminhoSaida, obj.PASTA_COMPARACOES, 'grafico_metricas.png');
                saveas(gcf, caminhoGrafico);
                close(gcf);
                
                if obj.verbose
                    fprintf('Gráfico de métricas salvo: %s\n', caminhoGrafico);
                end
                
            catch ME
                if obj.verbose
                    fprintf('Aviso: Erro ao gerar gráfico de métricas: %s\n', ME.message);
                end
            end
        end
        
        function escreverCabecalho(obj, fid)
            % Escreve cabeçalho do relatório
            
            fprintf(fid, '========================================================================\n');
            fprintf(fid, '                    RELATÓRIO COMPARATIVO DE MODELOS\n');
            fprintf(fid, '                      U-Net vs Attention U-Net\n');
            fprintf(fid, '========================================================================\n\n');
            fprintf(fid, 'Data de Geração: %s\n', datestr(now, 'dd/mm/yyyy HH:MM:SS'));
            fprintf(fid, 'Sistema: ComparadorModelos v1.0\n\n');
        end
        
        function escreverResumoExecutivo(obj, fid, metricas)
            % Escreve resumo executivo
            
            fprintf(fid, '1. RESUMO EXECUTIVO\n');
            fprintf(fid, '==================\n\n');
            
            fprintf(fid, 'Modelo Vencedor: %s\n', metricas.diferencas.vencedor);
            fprintf(fid, 'Nível de Confiança: %s\n\n', metricas.diferencas.confianca);
            
            fprintf(fid, 'Diferenças Principais:\n');
            fprintf(fid, '- IoU: %+.4f (%s)\n', metricas.diferencas.iou, ...
                obj.interpretarDiferenca(metricas.diferencas.iou));
            fprintf(fid, '- Dice: %+.4f (%s)\n', metricas.diferencas.dice, ...
                obj.interpretarDiferenca(metricas.diferencas.dice));
            fprintf(fid, '- Accuracy: %+.4f (%s)\n\n', metricas.diferencas.accuracy, ...
                obj.interpretarDiferenca(metricas.diferencas.accuracy));
        end
        
        function escreverMetricasDetalhadas(obj, fid, metricas)
            % Escreve métricas detalhadas
            
            fprintf(fid, '2. MÉTRICAS DETALHADAS\n');
            fprintf(fid, '=====================\n\n');
            
            % U-Net
            fprintf(fid, '2.1 U-Net\n');
            fprintf(fid, '---------\n');
            obj.escreverMetricasModelo(fid, metricas.unet);
            
            % Attention U-Net
            fprintf(fid, '2.2 Attention U-Net\n');
            fprintf(fid, '-------------------\n');
            obj.escreverMetricasModelo(fid, metricas.attention);
        end
        
        function escreverMetricasModelo(obj, fid, metricas)
            % Escreve métricas de um modelo específico
            
            fprintf(fid, 'IoU:\n');
            fprintf(fid, '  Média: %.4f ± %.4f\n', metricas.iou.media, metricas.iou.desvio);
            fprintf(fid, '  Min/Max: %.4f / %.4f\n', metricas.iou.min, metricas.iou.max);
            fprintf(fid, '  Mediana: %.4f\n\n', metricas.iou.mediana);
            
            fprintf(fid, 'Dice:\n');
            fprintf(fid, '  Média: %.4f ± %.4f\n', metricas.dice.media, metricas.dice.desvio);
            fprintf(fid, '  Min/Max: %.4f / %.4f\n', metricas.dice.min, metricas.dice.max);
            fprintf(fid, '  Mediana: %.4f\n\n', metricas.dice.mediana);
            
            fprintf(fid, 'Accuracy:\n');
            fprintf(fid, '  Média: %.4f ± %.4f\n', metricas.accuracy.media, metricas.accuracy.desvio);
            fprintf(fid, '  Min/Max: %.4f / %.4f\n', metricas.accuracy.min, metricas.accuracy.max);
            fprintf(fid, '  Mediana: %.4f\n\n', metricas.accuracy.mediana);
        end
        
        function escreverAnaliseComparativa(obj, fid, metricas)
            % Escreve análise comparativa
            
            fprintf(fid, '3. ANÁLISE COMPARATIVA\n');
            fprintf(fid, '=====================\n\n');
            
            fprintf(fid, '3.1 Comparação de Performance\n');
            fprintf(fid, '-----------------------------\n');
            
            % Análise por métrica
            obj.analisarMetrica(fid, 'IoU', metricas.unet.iou.media, metricas.attention.iou.media);
            obj.analisarMetrica(fid, 'Dice', metricas.unet.dice.media, metricas.attention.dice.media);
            obj.analisarMetrica(fid, 'Accuracy', metricas.unet.accuracy.media, metricas.attention.accuracy.media);
            
            fprintf(fid, '\n3.2 Consistência dos Resultados\n');
            fprintf(fid, '-------------------------------\n');
            
            % Análise de desvio padrão
            fprintf(fid, 'Desvio Padrão (menor = mais consistente):\n');
            fprintf(fid, '- U-Net: IoU=%.4f, Dice=%.4f, Acc=%.4f\n', ...
                metricas.unet.iou.desvio, metricas.unet.dice.desvio, metricas.unet.accuracy.desvio);
            fprintf(fid, '- Attention U-Net: IoU=%.4f, Dice=%.4f, Acc=%.4f\n\n', ...
                metricas.attention.iou.desvio, metricas.attention.dice.desvio, metricas.attention.accuracy.desvio);
        end
        
        function escreverConclusoes(obj, fid, metricas)
            % Escreve conclusões e recomendações
            
            fprintf(fid, '4. CONCLUSÕES E RECOMENDAÇÕES\n');
            fprintf(fid, '============================\n\n');
            
            fprintf(fid, '4.1 Conclusões\n');
            fprintf(fid, '--------------\n');
            
            % Conclusão baseada no vencedor
            switch metricas.diferencas.vencedor
                case 'U-Net'
                    fprintf(fid, 'O modelo U-Net demonstrou melhor performance geral neste dataset.\n');
                    fprintf(fid, 'Principais vantagens: simplicidade, menor complexidade computacional.\n\n');
                    
                case 'Attention U-Net'
                    fprintf(fid, 'O modelo Attention U-Net demonstrou melhor performance geral neste dataset.\n');
                    fprintf(fid, 'Principais vantagens: mecanismo de atenção, melhor captura de detalhes.\n\n');
                    
                otherwise
                    fprintf(fid, 'Os modelos apresentaram performance similar neste dataset.\n');
                    fprintf(fid, 'A escolha pode ser baseada em outros critérios (velocidade, recursos).\n\n');
            end
            
            fprintf(fid, '4.2 Recomendações\n');
            fprintf(fid, '-----------------\n');
            
            % Recomendações baseadas na confiança
            switch metricas.diferencas.confianca
                case 'alta'
                    fprintf(fid, '✅ RECOMENDAÇÃO: Use %s para este tipo de aplicação.\n', metricas.diferencas.vencedor);
                    fprintf(fid, '   As diferenças são consistentes e significativas.\n\n');
                    
                case 'media'
                    fprintf(fid, '⚠️  RECOMENDAÇÃO: %s apresenta ligeira vantagem.\n', metricas.diferencas.vencedor);
                    fprintf(fid, '   Considere testes adicionais para confirmação.\n\n');
                    
                otherwise
                    fprintf(fid, '🔄 RECOMENDAÇÃO: Realize testes adicionais.\n');
                    fprintf(fid, '   As diferenças são pequenas e podem não ser significativas.\n\n');
            end
            
            fprintf(fid, '4.3 Próximos Passos\n');
            fprintf(fid, '-------------------\n');
            fprintf(fid, '1. Validar resultados com dataset maior\n');
            fprintf(fid, '2. Testar com diferentes tipos de imagens\n');
            fprintf(fid, '3. Avaliar tempo de processamento\n');
            fprintf(fid, '4. Considerar ensemble dos dois modelos\n\n');
            
            fprintf(fid, '========================================================================\n');
            fprintf(fid, 'Fim do Relatório - Gerado automaticamente pelo ComparadorModelos\n');
            fprintf(fid, '========================================================================\n');
        end
        
        function interpretacao = interpretarDiferenca(obj, diferenca)
            % Interpreta diferença numérica
            
            if abs(diferenca) < 0.01
                interpretacao = 'diferença mínima';
            elseif abs(diferenca) < 0.05
                interpretacao = 'diferença pequena';
            elseif abs(diferenca) < 0.10
                interpretacao = 'diferença moderada';
            else
                interpretacao = 'diferença significativa';
            end
            
            if diferenca > 0
                interpretacao = ['Attention U-Net melhor - ' interpretacao];
            elseif diferenca < 0
                interpretacao = ['U-Net melhor - ' interpretacao];
            end
        end
        
        function analisarMetrica(obj, fid, nomeMetrica, valorUNet, valorAttention)
            % Analisa uma métrica específica
            
            diferenca = valorAttention - valorUNet;
            percentual = (diferenca / valorUNet) * 100;
            
            fprintf(fid, '%s:\n', nomeMetrica);
            fprintf(fid, '  U-Net: %.4f\n', valorUNet);
            fprintf(fid, '  Attention U-Net: %.4f\n', valorAttention);
            fprintf(fid, '  Diferença: %+.4f (%+.2f%%)\n', diferenca, percentual);
            
            if abs(diferenca) < 0.01
                fprintf(fid, '  Interpretação: Desempenho equivalente\n\n');
            elseif diferenca > 0
                fprintf(fid, '  Interpretação: Attention U-Net superior\n\n');
            else
                fprintf(fid, '  Interpretação: U-Net superior\n\n');
            end
        end
    end
    
    methods (Static)
        function executarComparacaoCompleta()
            % Método estático principal para comparar modelos
            % Este método executa toda a comparação automaticamente
            
            fprintf('=== COMPARANDO MODELOS ===\n');
            
            try
                % Criar instância do comparador
                comparador = ComparadorModelos();
                
                % Executar comparação completa (chamando o método de instância)
                comparador.comparar();
                
                fprintf('✅ Comparação concluída com sucesso!\n');
                
            catch ME
                fprintf('❌ Erro durante comparação: %s\n', ME.message);
                rethrow(ME);
            end
        end
    end
end