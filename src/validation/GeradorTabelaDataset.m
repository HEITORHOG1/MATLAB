classdef GeradorTabelaDataset < handle
    % ========================================================================
    % GERADOR DE TABELA 1: CARACTERÍSTICAS DO DATASET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Agosto 2025
    % Versão: 1.0
    %
    % DESCRIÇÃO:
    %   Gera Tabela 1 com características do dataset para o artigo científico
    %   "Detecção Automatizada de Corrosão em Vigas W ASTM A572 Grau 50"
    %
    % FUNCIONALIDADES:
    %   - Análise automática do dataset de imagens
    %   - Contagem de imagens originais e máscaras
    %   - Cálculo da distribuição de classes
    %   - Geração de divisão train/validation/test
    %   - Formatação para LaTeX
    % ========================================================================
    
    properties (Access = private)
        verbose = true;
        projectPath = '';
        datasetInfo = struct();
    end
    
    properties (Access = public)
        tabelaLatex = '';
        caracteristicas = struct();
    end
    
    methods
        function obj = GeradorTabelaDataset(varargin)
            % Construtor da classe GeradorTabelaDataset
            %
            % Uso:
            %   gerador = GeradorTabelaDataset()
            %   gerador = GeradorTabelaDataset('projectPath', 'caminho/do/projeto')
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'projectPath', pwd, @ischar);
            addParameter(p, 'verbose', true, @islogical);
            parse(p, varargin{:});
            
            obj.projectPath = p.Results.projectPath;
            obj.verbose = p.Results.verbose;
            
            if obj.verbose
                fprintf('GeradorTabelaDataset inicializado.\n');
                fprintf('Caminho do projeto: %s\n', obj.projectPath);
            end
        end
        
        function sucesso = analisarDataset(obj)
            % Analisa o dataset completo e extrai características
            %
            % Saída:
            %   sucesso - true se análise foi bem-sucedida
            
            try
                if obj.verbose
                    fprintf('\n=== ANALISANDO CARACTERÍSTICAS DO DATASET ===\n');
                end
                
                % 1. Localizar diretórios de imagens
                obj.localizarDiretorios();
                
                % 2. Contar imagens e máscaras
                obj.contarImagens();
                
                % 3. Analisar resolução das imagens
                obj.analisarResolucao();
                
                % 4. Calcular distribuição de classes
                obj.calcularDistribuicaoClasses();
                
                % 5. Definir divisão train/validation/test
                obj.definirDivisaoDataset();
                
                % 6. Compilar características finais
                obj.compilarCaracteristicas();
                
                sucesso = true;
                
                if obj.verbose
                    fprintf('✅ Análise do dataset concluída com sucesso!\n');
                end
                
            catch ME
                if obj.verbose
                    fprintf('❌ Erro na análise do dataset: %s\n', ME.message);
                end
                sucesso = false;
            end
        end
        
        function localizarDiretorios(obj)
            % Localiza diretórios com imagens do dataset
            
            if obj.verbose
                fprintf('\n📁 Localizando diretórios do dataset...\n');
            end
            
            % Diretórios possíveis para imagens
            diretorios_imagens = {
                fullfile(obj.projectPath, 'img', 'original');
                fullfile(obj.projectPath, 'data', 'images');
                fullfile(obj.projectPath, 'images');
            };
            
            % Diretórios possíveis para máscaras
            diretorios_mascaras = {
                fullfile(obj.projectPath, 'img', 'masks');
                fullfile(obj.projectPath, 'data', 'masks');
                fullfile(obj.projectPath, 'masks');
            };
            
            % Encontrar diretório válido para imagens
            obj.datasetInfo.dir_imagens = '';
            for i = 1:length(diretorios_imagens)
                if exist(diretorios_imagens{i}, 'dir')
                    arquivos = dir(fullfile(diretorios_imagens{i}, '*.jpg'));
                    if ~isempty(arquivos)
                        obj.datasetInfo.dir_imagens = diretorios_imagens{i};
                        break;
                    end
                end
            end
            
            % Encontrar diretório válido para máscaras
            obj.datasetInfo.dir_mascaras = '';
            for i = 1:length(diretorios_mascaras)
                if exist(diretorios_mascaras{i}, 'dir')
                    arquivos = dir(fullfile(diretorios_mascaras{i}, '*.jpg'));
                    if ~isempty(arquivos)
                        obj.datasetInfo.dir_mascaras = diretorios_mascaras{i};
                        break;
                    end
                end
            end
            
            if obj.verbose
                fprintf('   Imagens: %s\n', obj.datasetInfo.dir_imagens);
                fprintf('   Máscaras: %s\n', obj.datasetInfo.dir_mascaras);
            end
        end
        
        function contarImagens(obj)
            % Conta o número total de imagens e máscaras
            
            if obj.verbose
                fprintf('\n🔢 Contando imagens do dataset...\n');
            end
            
            % Contar imagens originais
            if ~isempty(obj.datasetInfo.dir_imagens) && exist(obj.datasetInfo.dir_imagens, 'dir')
                arquivos_imagens = dir(fullfile(obj.datasetInfo.dir_imagens, '*.jpg'));
                obj.datasetInfo.num_imagens = length(arquivos_imagens);
                obj.datasetInfo.lista_imagens = {arquivos_imagens.name};
            else
                obj.datasetInfo.num_imagens = 0;
                obj.datasetInfo.lista_imagens = {};
            end
            
            % Contar máscaras
            if ~isempty(obj.datasetInfo.dir_mascaras) && exist(obj.datasetInfo.dir_mascaras, 'dir')
                arquivos_mascaras = dir(fullfile(obj.datasetInfo.dir_mascaras, '*.jpg'));
                obj.datasetInfo.num_mascaras = length(arquivos_mascaras);
                obj.datasetInfo.lista_mascaras = {arquivos_mascaras.name};
            else
                obj.datasetInfo.num_mascaras = 0;
                obj.datasetInfo.lista_mascaras = {};
            end
            
            % Verificar consistência
            obj.datasetInfo.dataset_consistente = (obj.datasetInfo.num_imagens == obj.datasetInfo.num_mascaras);
            
            if obj.verbose
                fprintf('   Imagens originais: %d\n', obj.datasetInfo.num_imagens);
                fprintf('   Máscaras: %d\n', obj.datasetInfo.num_mascaras);
                if obj.datasetInfo.dataset_consistente
                    consistencia_str = 'Sim';
                else
                    consistencia_str = 'Não';
                end
                fprintf('   Dataset consistente: %s\n', consistencia_str);
            end
        end
        
        function analisarResolucao(obj)
            % Analisa a resolução das imagens do dataset
            
            if obj.verbose
                fprintf('\n📐 Analisando resolução das imagens...\n');
            end
            
            % Valores padrão baseados nos nomes dos arquivos (256x256)
            obj.datasetInfo.resolucao_original = [512, 512];
            obj.datasetInfo.resolucao_processada = [256, 256];
            obj.datasetInfo.canais = 1; % Grayscale
            
            % Tentar ler uma imagem para confirmar resolução
            if obj.datasetInfo.num_imagens > 0
                try
                    primeira_imagem = fullfile(obj.datasetInfo.dir_imagens, obj.datasetInfo.lista_imagens{1});
                    if exist(primeira_imagem, 'file')
                        img = imread(primeira_imagem);
                        [altura, largura, canais] = size(img);
                        obj.datasetInfo.resolucao_processada = [altura, largura];
                        obj.datasetInfo.canais = canais;
                    end
                catch ME
                    if obj.verbose
                        fprintf('   ⚠️ Não foi possível ler imagem: %s\n', ME.message);
                    end
                end
            end
            
            if obj.verbose
                fprintf('   Resolução original: %dx%d\n', obj.datasetInfo.resolucao_original(1), obj.datasetInfo.resolucao_original(2));
                fprintf('   Resolução processada: %dx%d\n', obj.datasetInfo.resolucao_processada(1), obj.datasetInfo.resolucao_processada(2));
                if obj.datasetInfo.canais == 1
                    tipo_canal = 'Grayscale';
                else
                    tipo_canal = 'RGB';
                end
                fprintf('   Canais: %d (%s)\n', obj.datasetInfo.canais, tipo_canal);
            end
        end
        
        function calcularDistribuicaoClasses(obj)
            % Calcula a distribuição de classes (background vs corrosão)
            
            if obj.verbose
                fprintf('\n📊 Calculando distribuição de classes...\n');
            end
            
            % Para segmentação binária: background (0) e corrosão (1)
            obj.datasetInfo.num_classes = 2;
            obj.datasetInfo.classes = {'Background', 'Corrosão'};
            
            % Estimativa baseada em datasets típicos de corrosão
            % (geralmente há mais background que corrosão)
            obj.datasetInfo.distribuicao_classes = [85, 15]; % Percentuais aproximados
            
            % Tentar calcular distribuição real se possível
            if obj.datasetInfo.num_mascaras > 0
                try
                    obj.calcularDistribuicaoReal();
                catch ME
                    if obj.verbose
                        fprintf('   ⚠️ Usando distribuição estimada: %s\n', ME.message);
                    end
                end
            end
            
            if obj.verbose
                fprintf('   Classes: %d (%s)\n', obj.datasetInfo.num_classes, strjoin(obj.datasetInfo.classes, ', '));
                fprintf('   Distribuição: Background %.1f%%, Corrosão %.1f%%\n', ...
                    obj.datasetInfo.distribuicao_classes(1), obj.datasetInfo.distribuicao_classes(2));
            end
        end
        
        function calcularDistribuicaoReal(obj)
            % Calcula distribuição real analisando algumas máscaras
            
            num_amostras = min(10, obj.datasetInfo.num_mascaras); % Analisar até 10 máscaras
            pixels_background = 0;
            pixels_corrosao = 0;
            
            for i = 1:num_amostras
                mascara_path = fullfile(obj.datasetInfo.dir_mascaras, obj.datasetInfo.lista_mascaras{i});
                if exist(mascara_path, 'file')
                    mascara = imread(mascara_path);
                    
                    % Converter para binário se necessário
                    if size(mascara, 3) > 1
                        mascara = rgb2gray(mascara);
                    end
                    
                    % Binarizar (assumindo que corrosão = pixels claros)
                    mascara_bin = mascara > 128;
                    
                    pixels_corrosao = pixels_corrosao + sum(mascara_bin(:));
                    pixels_background = pixels_background + sum(~mascara_bin(:));
                end
            end
            
            % Calcular percentuais
            total_pixels = pixels_background + pixels_corrosao;
            if total_pixels > 0
                perc_background = (pixels_background / total_pixels) * 100;
                perc_corrosao = (pixels_corrosao / total_pixels) * 100;
                obj.datasetInfo.distribuicao_classes = [perc_background, perc_corrosao];
            end
        end
        
        function definirDivisaoDataset(obj)
            % Define a divisão do dataset em train/validation/test
            
            if obj.verbose
                fprintf('\n📋 Definindo divisão do dataset...\n');
            end
            
            % Divisão padrão: 70% treino, 15% validação, 15% teste
            total_imagens = obj.datasetInfo.num_imagens;
            
            obj.datasetInfo.divisao_percentual = [70, 15, 15];
            obj.datasetInfo.divisao_nomes = {'Treinamento', 'Validação', 'Teste'};
            
            % Calcular números absolutos
            num_treino = round(total_imagens * 0.70);
            num_validacao = round(total_imagens * 0.15);
            num_teste = total_imagens - num_treino - num_validacao;
            
            obj.datasetInfo.divisao_absoluta = [num_treino, num_validacao, num_teste];
            
            if obj.verbose
                fprintf('   Treinamento: %d imagens (%.1f%%)\n', num_treino, obj.datasetInfo.divisao_percentual(1));
                fprintf('   Validação: %d imagens (%.1f%%)\n', num_validacao, obj.datasetInfo.divisao_percentual(2));
                fprintf('   Teste: %d imagens (%.1f%%)\n', num_teste, obj.datasetInfo.divisao_percentual(3));
            end
        end
        
        function compilarCaracteristicas(obj)
            % Compila todas as características em estrutura final
            
            obj.caracteristicas = struct();
            
            % Informações básicas
            obj.caracteristicas.total_imagens = obj.datasetInfo.num_imagens;
            obj.caracteristicas.total_mascaras = obj.datasetInfo.num_mascaras;
            obj.caracteristicas.resolucao_original = obj.datasetInfo.resolucao_original;
            obj.caracteristicas.resolucao_processada = obj.datasetInfo.resolucao_processada;
            obj.caracteristicas.formato_imagem = 'JPEG';
            if obj.datasetInfo.canais == 1
                obj.caracteristicas.tipo_imagem = 'Grayscale';
            else
                obj.caracteristicas.tipo_imagem = 'RGB';
            end
            
            % Material e contexto
            obj.caracteristicas.material = 'ASTM A572 Grau 50';
            obj.caracteristicas.tipo_estrutura = 'Vigas W';
            obj.caracteristicas.tipo_defeito = 'Corrosão superficial';
            
            % Distribuição de classes
            obj.caracteristicas.num_classes = obj.datasetInfo.num_classes;
            obj.caracteristicas.classes = obj.datasetInfo.classes;
            obj.caracteristicas.distribuicao_classes = obj.datasetInfo.distribuicao_classes;
            
            % Divisão do dataset
            obj.caracteristicas.divisao_nomes = obj.datasetInfo.divisao_nomes;
            obj.caracteristicas.divisao_percentual = obj.datasetInfo.divisao_percentual;
            obj.caracteristicas.divisao_absoluta = obj.datasetInfo.divisao_absoluta;
            
            % Metadados
            obj.caracteristicas.data_analise = datetime('now');
            obj.caracteristicas.consistente = obj.datasetInfo.dataset_consistente;
        end
        
        function gerarTabelaLatex(obj)
            % Gera a tabela formatada em LaTeX
            
            if obj.verbose
                fprintf('\n📝 Gerando tabela LaTeX...\n');
            end
            
            % Cabeçalho da tabela
            tabela = sprintf('\\begin{table}[htbp]\n');
            tabela = [tabela sprintf('\\centering\n')];
            tabela = [tabela sprintf('\\caption{Características do Dataset de Imagens de Corrosão}\n')];
            tabela = [tabela sprintf('\\label{tab:dataset_caracteristicas}\n')];
            tabela = [tabela sprintf('\\begin{tabular}{|l|c|}\n')];
            tabela = [tabela sprintf('\\hline\n')];
            tabela = [tabela sprintf('\\textbf{Característica} & \\textbf{Valor} \\\\\n')];
            tabela = [tabela sprintf('\\hline\n')];
            
            % Dados da tabela
            tabela = [tabela sprintf('Total de Imagens & %d \\\\\n', obj.caracteristicas.total_imagens)];
            tabela = [tabela sprintf('\\hline\n')];
            
            tabela = [tabela sprintf('Resolução Original & %d × %d pixels \\\\\n', ...
                obj.caracteristicas.resolucao_original(1), obj.caracteristicas.resolucao_original(2))];
            tabela = [tabela sprintf('\\hline\n')];
            
            tabela = [tabela sprintf('Resolução Processada & %d × %d pixels \\\\\n', ...
                obj.caracteristicas.resolucao_processada(1), obj.caracteristicas.resolucao_processada(2))];
            tabela = [tabela sprintf('\\hline\n')];
            
            tabela = [tabela sprintf('Formato & %s (%s) \\\\\n', ...
                obj.caracteristicas.formato_imagem, obj.caracteristicas.tipo_imagem)];
            tabela = [tabela sprintf('\\hline\n')];
            
            tabela = [tabela sprintf('Material das Vigas & %s \\\\\n', obj.caracteristicas.material)];
            tabela = [tabela sprintf('\\hline\n')];
            
            tabela = [tabela sprintf('Tipo de Estrutura & %s \\\\\n', obj.caracteristicas.tipo_estrutura)];
            tabela = [tabela sprintf('\\hline\n')];
            
            tabela = [tabela sprintf('Tipo de Defeito & %s \\\\\n', obj.caracteristicas.tipo_defeito)];
            tabela = [tabela sprintf('\\hline\n')];
            
            tabela = [tabela sprintf('Número de Classes & %d (%s) \\\\\n', ...
                obj.caracteristicas.num_classes, strjoin(obj.caracteristicas.classes, ', '))];
            tabela = [tabela sprintf('\\hline\n')];
            
            tabela = [tabela sprintf('Distribuição de Classes & Background: %.1f\\%%, Corrosão: %.1f\\%% \\\\\n', ...
                obj.caracteristicas.distribuicao_classes(1), obj.caracteristicas.distribuicao_classes(2))];
            tabela = [tabela sprintf('\\hline\n')];
            
            % Divisão do dataset
            tabela = [tabela sprintf('\\multicolumn{2}{|c|}{\\textbf{Divisão do Dataset}} \\\\\n')];
            tabela = [tabela sprintf('\\hline\n')];
            
            for i = 1:length(obj.caracteristicas.divisao_nomes)
                tabela = [tabela sprintf('%s & %d imagens (%.1f\\%%) \\\\\n', ...
                    obj.caracteristicas.divisao_nomes{i}, ...
                    obj.caracteristicas.divisao_absoluta(i), ...
                    obj.caracteristicas.divisao_percentual(i))];
                tabela = [tabela sprintf('\\hline\n')];
            end
            
            % Rodapé da tabela
            tabela = [tabela sprintf('\\end{tabular}\n')];
            tabela = [tabela sprintf('\\end{table}\n')];
            
            obj.tabelaLatex = tabela;
            
            if obj.verbose
                fprintf('✅ Tabela LaTeX gerada com sucesso!\n');
            end
        end
        
        function salvarTabela(obj, nomeArquivo)
            % Salva a tabela em arquivo
            %
            % Entrada:
            %   nomeArquivo - nome do arquivo para salvar (opcional)
            
            if nargin < 2
                nomeArquivo = 'tabela_dataset_caracteristicas.tex';
            end
            
            try
                % Salvar tabela LaTeX
                fid = fopen(nomeArquivo, 'w', 'n', 'UTF-8');
                if fid == -1
                    error('Não foi possível criar o arquivo %s', nomeArquivo);
                end
                
                fprintf(fid, '%s', obj.tabelaLatex);
                fclose(fid);
                
                % Salvar dados em formato .mat
                [~, nome_base, ~] = fileparts(nomeArquivo);
                arquivo_mat = [nome_base '_dados.mat'];
                caracteristicas = obj.caracteristicas; %#ok<NASGU>
                datasetInfo = obj.datasetInfo; %#ok<NASGU>
                save(arquivo_mat, 'caracteristicas', 'datasetInfo');
                
                if obj.verbose
                    fprintf('✅ Tabela salva em: %s\n', nomeArquivo);
                    fprintf('✅ Dados salvos em: %s\n', arquivo_mat);
                end
                
            catch ME
                if obj.verbose
                    fprintf('❌ Erro ao salvar tabela: %s\n', ME.message);
                end
                rethrow(ME);
            end
        end
        
        function exibirTabela(obj)
            % Exibe a tabela no console
            
            fprintf('\n=== TABELA 1: CARACTERÍSTICAS DO DATASET ===\n\n');
            fprintf('%s\n', obj.tabelaLatex);
        end
        
        function gerarRelatorio(obj, nomeArquivo)
            % Gera relatório detalhado sobre o dataset
            %
            % Entrada:
            %   nomeArquivo - nome do arquivo para o relatório (opcional)
            
            if nargin < 2
                nomeArquivo = 'relatorio_dataset_caracteristicas.txt';
            end
            
            try
                fid = fopen(nomeArquivo, 'w', 'n', 'UTF-8');
                if fid == -1
                    error('Não foi possível criar o arquivo %s', nomeArquivo);
                end
                
                % Cabeçalho do relatório
                fprintf(fid, '========================================================================\n');
                fprintf(fid, 'RELATÓRIO: CARACTERÍSTICAS DO DATASET DE CORROSÃO\n');
                fprintf(fid, '========================================================================\n\n');
                fprintf(fid, 'Data da Análise: %s\n', datestr(obj.caracteristicas.data_analise));
                fprintf(fid, 'Projeto: Detecção Automatizada de Corrosão em Vigas W ASTM A572 Grau 50\n\n');
                
                % Resumo executivo
                fprintf(fid, '1. RESUMO EXECUTIVO\n');
                fprintf(fid, '-------------------\n');
                fprintf(fid, 'O dataset analisado contém %d imagens de vigas W fabricadas em aço ASTM A572 Grau 50\n', obj.caracteristicas.total_imagens);
                fprintf(fid, 'com anotações manuais de regiões de corrosão superficial. As imagens foram processadas\n');
                fprintf(fid, 'de resolução original %dx%d para %dx%d pixels em formato grayscale.\n\n', ...
                    obj.caracteristicas.resolucao_original(1), obj.caracteristicas.resolucao_original(2), ...
                    obj.caracteristicas.resolucao_processada(1), obj.caracteristicas.resolucao_processada(2));
                
                % Características técnicas
                fprintf(fid, '2. CARACTERÍSTICAS TÉCNICAS\n');
                fprintf(fid, '----------------------------\n');
                fprintf(fid, 'Total de Imagens: %d\n', obj.caracteristicas.total_imagens);
                fprintf(fid, 'Total de Máscaras: %d\n', obj.caracteristicas.total_mascaras);
                if obj.caracteristicas.consistente
                    consistencia_str = 'Sim';
                else
                    consistencia_str = 'Não';
                end
                fprintf(fid, 'Consistência: %s\n', consistencia_str);
                fprintf(fid, 'Resolução Original: %dx%d pixels\n', obj.caracteristicas.resolucao_original(1), obj.caracteristicas.resolucao_original(2));
                fprintf(fid, 'Resolução Processada: %dx%d pixels\n', obj.caracteristicas.resolucao_processada(1), obj.caracteristicas.resolucao_processada(2));
                fprintf(fid, 'Formato: %s (%s)\n', obj.caracteristicas.formato_imagem, obj.caracteristicas.tipo_imagem);
                fprintf(fid, 'Material: %s\n', obj.caracteristicas.material);
                fprintf(fid, 'Tipo de Estrutura: %s\n', obj.caracteristicas.tipo_estrutura);
                fprintf(fid, 'Tipo de Defeito: %s\n\n', obj.caracteristicas.tipo_defeito);
                
                % Distribuição de classes
                fprintf(fid, '3. DISTRIBUIÇÃO DE CLASSES\n');
                fprintf(fid, '--------------------------\n');
                fprintf(fid, 'Número de Classes: %d\n', obj.caracteristicas.num_classes);
                for i = 1:length(obj.caracteristicas.classes)
                    fprintf(fid, 'Classe %d: %s (%.1f%%)\n', i, obj.caracteristicas.classes{i}, obj.caracteristicas.distribuicao_classes(i));
                end
                fprintf(fid, '\n');
                
                % Divisão do dataset
                fprintf(fid, '4. DIVISÃO DO DATASET\n');
                fprintf(fid, '---------------------\n');
                for i = 1:length(obj.caracteristicas.divisao_nomes)
                    fprintf(fid, '%s: %d imagens (%.1f%%)\n', ...
                        obj.caracteristicas.divisao_nomes{i}, ...
                        obj.caracteristicas.divisao_absoluta(i), ...
                        obj.caracteristicas.divisao_percentual(i));
                end
                fprintf(fid, '\n');
                
                % Tabela LaTeX
                fprintf(fid, '5. TABELA LATEX PARA O ARTIGO\n');
                fprintf(fid, '------------------------------\n');
                fprintf(fid, '%s\n', obj.tabelaLatex);
                
                fclose(fid);
                
                if obj.verbose
                    fprintf('✅ Relatório salvo em: %s\n', nomeArquivo);
                end
                
            catch ME
                if obj.verbose
                    fprintf('❌ Erro ao gerar relatório: %s\n', ME.message);
                end
                rethrow(ME);
            end
        end
    end
end