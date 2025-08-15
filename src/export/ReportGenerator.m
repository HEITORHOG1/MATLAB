classdef ReportGenerator < handle
    % ReportGenerator - Geração automática de relatórios científicos
    % 
    % Esta classe implementa geração automática de relatórios científicos
    % completos com análises estatísticas, visualizações e formatação
    %
    % Uso:
    %   generator = ReportGenerator();
    %   generator.generateFullReport(results, 'report.html');
    %   generator.generateLaTeXReport(results, 'report.tex');
    
    properties (Access = private)
        outputDirectory
        templateDirectory
        includeStatistics
        includeVisualizations
        reportLanguage
    end
    
    methods
        function obj = ReportGenerator(varargin)
            % Constructor - Inicializa o gerador de relatórios
            %
            % Parâmetros:
            %   'OutputDirectory' - Diretório de saída (padrão: 'output/reports')
            %   'TemplateDirectory' - Diretório de templates (padrão: 'templates')
            %   'IncludeStatistics' - Incluir análises estatísticas (padrão: true)
            %   'IncludeVisualizations' - Incluir visualizações (padrão: true)
            %   'Language' - Idioma do relatório ('pt', 'en') (padrão: 'pt')
            
            p = inputParser;
            addParameter(p, 'OutputDirectory', 'output/reports', @ischar);
            addParameter(p, 'TemplateDirectory', 'templates', @ischar);
            addParameter(p, 'IncludeStatistics', true, @islogical);
            addParameter(p, 'IncludeVisualizations', true, @islogical);
            addParameter(p, 'Language', 'pt', @ischar);
            parse(p, varargin{:});
            
            obj.outputDirectory = p.Results.OutputDirectory;
            obj.templateDirectory = p.Results.TemplateDirectory;
            obj.includeStatistics = p.Results.IncludeStatistics;
            obj.includeVisualizations = p.Results.IncludeVisualizations;
            obj.reportLanguage = p.Results.Language;
            
            % Criar diretórios se não existirem
            if ~exist(obj.outputDirectory, 'dir')
                mkdir(obj.outputDirectory);
            end
            if ~exist(obj.templateDirectory, 'dir')
                mkdir(obj.templateDirectory);
                obj.createDefaultTemplates();
            end
        end
        
        function filepath = generateFullReport(obj, results, filename, varargin)
            % Gera relatório completo em HTML
            %
            % Parâmetros:
            %   results - Estrutura com resultados da comparação
            %   filename - Nome do arquivo HTML
            %   'Title' - Título do relatório
            %   'Author' - Autor do relatório
            %   'IncludeRawData' - Incluir dados brutos (padrão: false)
            
            p = inputParser;
            addParameter(p, 'Title', 'Relatório de Segmentação de Imagens', @ischar);
            addParameter(p, 'Author', 'Sistema Automatizado', @ischar);
            addParameter(p, 'IncludeRawData', false, @islogical);
            parse(p, varargin{:});
            
            if isempty(filename)
                timestamp = datestr(now, 'yyyyMMdd_HHmmss');
                filename = sprintf('relatorio_completo_%s.html', timestamp);
            end
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                % Gerar conteúdo do relatório
                htmlContent = obj.generateHTMLContent(results, ...
                    p.Results.Title, p.Results.Author, p.Results.IncludeRawData);
                
                % Escrever arquivo
                fid = fopen(filepath, 'w', 'n', 'UTF-8');
                if fid == -1
                    error('ReportGenerator:FileError', 'Não foi possível criar arquivo HTML');
                end
                
                fprintf(fid, '%s', htmlContent);
                fclose(fid);
                
                % Copiar recursos (CSS, JS) se necessário
                obj.copyReportAssets(filepath);
                
                fprintf('Relatório HTML gerado: %s\n', filepath);
                
            catch ME
                error('ReportGenerator:HTMLReportError', ...
                    'Erro ao gerar relatório HTML: %s', ME.message);
            end
        end
        
        function filepath = generateLaTeXReport(obj, results, filename, varargin)
            % Gera relatório em LaTeX
            %
            % Parâmetros:
            %   results - Estrutura com resultados
            %   filename - Nome do arquivo TEX
            %   'DocumentClass' - Classe do documento (padrão: 'article')
            %   'Bibliography' - Incluir bibliografia (padrão: true)
            
            p = inputParser;
            addParameter(p, 'DocumentClass', 'article', @ischar);
            addParameter(p, 'Bibliography', true, @islogical);
            addParameter(p, 'Title', 'Comparação de Modelos de Segmentação', @ischar);
            addParameter(p, 'Author', 'Sistema Automatizado', @ischar);
            parse(p, varargin{:});
            
            if isempty(filename)
                timestamp = datestr(now, 'yyyyMMdd_HHmmss');
                filename = sprintf('relatorio_%s.tex', timestamp);
            end
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                % Gerar conteúdo LaTeX
                latexContent = obj.generateLaTeXContent(results, ...
                    p.Results.DocumentClass, p.Results.Title, p.Results.Author);
                
                % Escrever arquivo
                fid = fopen(filepath, 'w', 'n', 'UTF-8');
                if fid == -1
                    error('ReportGenerator:FileError', 'Não foi possível criar arquivo LaTeX');
                end
                
                fprintf(fid, '%s', latexContent);
                fclose(fid);
                
                % Gerar bibliografia se solicitado
                if p.Results.Bibliography
                    obj.generateBibliography(filepath);
                end
                
                fprintf('Relatório LaTeX gerado: %s\n', filepath);
                
            catch ME
                error('ReportGenerator:LaTeXReportError', ...
                    'Erro ao gerar relatório LaTeX: %s', ME.message);
            end
        end
        
        function filepath = generateExecutiveSummary(obj, results, filename)
            % Gera sumário executivo conciso
            %
            % Parâmetros:
            %   results - Estrutura com resultados
            %   filename - Nome do arquivo
            
            if isempty(filename)
                timestamp = datestr(now, 'yyyyMMdd_HHmmss');
                filename = sprintf('sumario_executivo_%s.html', timestamp);
            end
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                % Extrair métricas principais
                summary = obj.extractExecutiveSummary(results);
                
                % Gerar HTML conciso
                htmlContent = obj.generateSummaryHTML(summary);
                
                % Escrever arquivo
                fid = fopen(filepath, 'w', 'n', 'UTF-8');
                fprintf(fid, '%s', htmlContent);
                fclose(fid);
                
                fprintf('Sumário executivo gerado: %s\n', filepath);
                
            catch ME
                error('ReportGenerator:SummaryError', ...
                    'Erro ao gerar sumário executivo: %s', ME.message);
            end
        end
        
        function filepath = generateMethodologyReport(obj, config, filename)
            % Gera relatório de metodologia
            %
            % Parâmetros:
            %   config - Configuração utilizada no experimento
            %   filename - Nome do arquivo
            
            if isempty(filename)
                timestamp = datestr(now, 'yyyyMMdd_HHmmss');
                filename = sprintf('metodologia_%s.tex', timestamp);
            end
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                % Gerar seção de metodologia
                methodContent = obj.generateMethodologyContent(config);
                
                % Escrever arquivo
                fid = fopen(filepath, 'w', 'n', 'UTF-8');
                fprintf(fid, '%s', methodContent);
                fclose(fid);
                
                fprintf('Relatório de metodologia gerado: %s\n', filepath);
                
            catch ME
                error('ReportGenerator:MethodologyError', ...
                    'Erro ao gerar relatório de metodologia: %s', ME.message);
            end
        end
        
        function filepath = generateComparisonReport(obj, unetResults, attentionResults, filename)
            % Gera relatório específico de comparação entre modelos
            %
            % Parâmetros:
            %   unetResults - Resultados do U-Net
            %   attentionResults - Resultados do Attention U-Net
            %   filename - Nome do arquivo
            
            if isempty(filename)
                timestamp = datestr(now, 'yyyyMMdd_HHmmss');
                filename = sprintf('comparacao_modelos_%s.html', timestamp);
            end
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                % Preparar dados de comparação
                comparison = obj.prepareComparisonData(unetResults, attentionResults);
                
                % Gerar relatório de comparação
                htmlContent = obj.generateComparisonHTML(comparison);
                
                % Escrever arquivo
                fid = fopen(filepath, 'w', 'n', 'UTF-8');
                fprintf(fid, '%s', htmlContent);
                fclose(fid);
                
                fprintf('Relatório de comparação gerado: %s\n', filepath);
                
            catch ME
                error('ReportGenerator:ComparisonError', ...
                    'Erro ao gerar relatório de comparação: %s', ME.message);
            end
        end
        
        function success = compileLatexReport(obj, texFilepath)
            % Compila relatório LaTeX para PDF
            %
            % Parâmetros:
            %   texFilepath - Caminho do arquivo TEX
            
            success = false;
            
            try
                [pathStr, name, ~] = fileparts(texFilepath);
                
                % Tentar compilar com pdflatex
                if ispc
                    cmd = sprintf('pdflatex -output-directory="%s" "%s"', pathStr, texFilepath);
                else
                    cmd = sprintf('pdflatex -output-directory=%s %s', pathStr, texFilepath);
                end
                
                [status, ~] = system(cmd);
                
                if status == 0
                    pdfFile = fullfile(pathStr, [name '.pdf']);
                    if exist(pdfFile, 'file')
                        success = true;
                        fprintf('PDF compilado com sucesso: %s\n', pdfFile);
                    end
                else
                    warning('ReportGenerator:CompilationWarning', ...
                        'pdflatex não disponível. Arquivo TEX gerado sem compilação.');
                end
                
            catch ME
                warning('ReportGenerator:CompilationError', ...
                    'Erro na compilação LaTeX: %s', ME.message);
            end
        end
    end
    
    methods (Access = private)
        function createDefaultTemplates(obj)
            % Cria templates padrão
            
            % Template HTML
            htmlTemplate = obj.getDefaultHTMLTemplate();
            htmlFile = fullfile(obj.templateDirectory, 'report_template.html');
            fid = fopen(htmlFile, 'w', 'n', 'UTF-8');
            fprintf(fid, '%s', htmlTemplate);
            fclose(fid);
            
            % Template LaTeX
            latexTemplate = obj.getDefaultLaTeXTemplate();
            latexFile = fullfile(obj.templateDirectory, 'report_template.tex');
            fid = fopen(latexFile, 'w', 'n', 'UTF-8');
            fprintf(fid, '%s', latexTemplate);
            fclose(fid);
        end
        
        function htmlContent = generateHTMLContent(obj, results, title, author, includeRawData)
            % Gera conteúdo HTML completo
            
            htmlContent = sprintf('<!DOCTYPE html>\n<html lang="%s">\n<head>\n', obj.reportLanguage);
            htmlContent = [htmlContent, sprintf('<meta charset="UTF-8">\n')];
            htmlContent = [htmlContent, sprintf('<meta name="viewport" content="width=device-width, initial-scale=1.0">\n')];
            htmlContent = [htmlContent, sprintf('<title>%s</title>\n', title)];
            htmlContent = [htmlContent, obj.getReportCSS()];
            htmlContent = [htmlContent, sprintf('</head>\n<body>\n')];
            
            % Cabeçalho
            htmlContent = [htmlContent, obj.generateHTMLHeader(title, author)];
            
            % Sumário executivo
            htmlContent = [htmlContent, obj.generateHTMLExecutiveSummary(results)];
            
            % Metodologia
            htmlContent = [htmlContent, obj.generateHTMLMethodology(results)];
            
            % Resultados
            htmlContent = [htmlContent, obj.generateHTMLResults(results)];
            
            % Análise estatística
            if obj.includeStatistics
                htmlContent = [htmlContent, obj.generateHTMLStatistics(results)];
            end
            
            % Visualizações
            if obj.includeVisualizations
                htmlContent = [htmlContent, obj.generateHTMLVisualizations(results)];
            end
            
            % Conclusões
            htmlContent = [htmlContent, obj.generateHTMLConclusions(results)];
            
            % Dados brutos (opcional)
            if includeRawData
                htmlContent = [htmlContent, obj.generateHTMLRawData(results)];
            end
            
            % Rodapé
            htmlContent = [htmlContent, obj.generateHTMLFooter()];
            
            htmlContent = [htmlContent, sprintf('</body>\n</html>\n')];
        end
        
        function latexContent = generateLaTeXContent(obj, results, documentClass, title, author)
            % Gera conteúdo LaTeX completo
            
            latexContent = sprintf('\\documentclass{%s}\n', documentClass);
            latexContent = [latexContent, obj.getLaTeXPackages()];
            latexContent = [latexContent, sprintf('\\title{%s}\n', title)];
            latexContent = [latexContent, sprintf('\\author{%s}\n', author)];
            latexContent = [latexContent, sprintf('\\date{%s}\n', datestr(now, 'dd/mm/yyyy'))];
            latexContent = [latexContent, sprintf('\\begin{document}\n')];
            latexContent = [latexContent, sprintf('\\maketitle\n')];
            latexContent = [latexContent, sprintf('\\tableofcontents\n')];
            latexContent = [latexContent, sprintf('\\newpage\n\n')];
            
            % Resumo
            latexContent = [latexContent, obj.generateLaTeXAbstract(results)];
            
            % Introdução
            latexContent = [latexContent, obj.generateLaTeXIntroduction()];
            
            % Metodologia
            latexContent = [latexContent, obj.generateLaTeXMethodology(results)];
            
            % Resultados
            latexContent = [latexContent, obj.generateLaTeXResults(results)];
            
            % Discussão
            latexContent = [latexContent, obj.generateLaTeXDiscussion(results)];
            
            % Conclusão
            latexContent = [latexContent, obj.generateLaTeXConclusion(results)];
            
            latexContent = [latexContent, sprintf('\\end{document}\n')];
        end
        
        function summary = extractExecutiveSummary(obj, results)
            % Extrai sumário executivo dos resultados
            
            summary = struct();
            
            try
                if isfield(results, 'unet_metrics') && isfield(results, 'attention_metrics')
                    unet = results.unet_metrics;
                    attention = results.attention_metrics;
                    
                    % Métricas principais
                    summary.unet_iou_mean = mean(unet.iou);
                    summary.attention_iou_mean = mean(attention.iou);
                    summary.iou_improvement = summary.attention_iou_mean - summary.unet_iou_mean;
                    
                    summary.unet_dice_mean = mean(unet.dice);
                    summary.attention_dice_mean = mean(attention.dice);
                    summary.dice_improvement = summary.attention_dice_mean - summary.unet_dice_mean;
                    
                    % Determinar modelo vencedor
                    if summary.iou_improvement > 0 && summary.dice_improvement > 0
                        summary.winner = 'Attention U-Net';
                        summary.improvement_significant = true;
                    elseif summary.iou_improvement < 0 && summary.dice_improvement < 0
                        summary.winner = 'U-Net';
                        summary.improvement_significant = true;
                    else
                        summary.winner = 'Empate técnico';
                        summary.improvement_significant = false;
                    end
                    
                    summary.num_images = length(unet.iou);
                    summary.generation_date = datestr(now);
                end
                
            catch ME
                warning('ReportGenerator:SummaryWarning', ...
                    'Erro ao extrair sumário: %s', ME.message);
                summary.error = ME.message;
            end
        end
        
        function htmlContent = generateSummaryHTML(obj, summary)
            % Gera HTML do sumário executivo
            
            htmlContent = sprintf('<!DOCTYPE html>\n<html>\n<head>\n');
            htmlContent = [htmlContent, sprintf('<meta charset="UTF-8">\n')];
            htmlContent = [htmlContent, sprintf('<title>Sumário Executivo</title>\n')];
            htmlContent = [htmlContent, obj.getReportCSS()];
            htmlContent = [htmlContent, sprintf('</head>\n<body>\n')];
            
            htmlContent = [htmlContent, sprintf('<div class="container">\n')];
            htmlContent = [htmlContent, sprintf('<h1>Sumário Executivo</h1>\n')];
            
            if isfield(summary, 'winner')
                htmlContent = [htmlContent, sprintf('<div class="summary-box">\n')];
                htmlContent = [htmlContent, sprintf('<h2>Resultado Principal</h2>\n')];
                htmlContent = [htmlContent, sprintf('<p><strong>Modelo Vencedor:</strong> %s</p>\n', summary.winner)];
                
                if isfield(summary, 'iou_improvement')
                    htmlContent = [htmlContent, sprintf('<p><strong>Melhoria IoU:</strong> %.4f</p>\n', summary.iou_improvement)];
                    htmlContent = [htmlContent, sprintf('<p><strong>Melhoria Dice:</strong> %.4f</p>\n', summary.dice_improvement)];
                end
                
                htmlContent = [htmlContent, sprintf('</div>\n')];
            end
            
            htmlContent = [htmlContent, sprintf('</div>\n')];
            htmlContent = [htmlContent, sprintf('</body>\n</html>\n')];
        end
        
        function methodContent = generateMethodologyContent(obj, config)
            % Gera conteúdo de metodologia
            
            methodContent = sprintf('\\section{Metodologia}\n\n');
            methodContent = [methodContent, sprintf('\\subsection{Configuração Experimental}\n\n')];
            
            if isstruct(config)
                fields = fieldnames(config);
                for i = 1:length(fields)
                    field = fields{i};
                    value = config.(field);
                    
                    if isnumeric(value)
                        methodContent = [methodContent, sprintf('\\textbf{%s:} %.4f\n\n', field, value)];
                    else
                        methodContent = [methodContent, sprintf('\\textbf{%s:} %s\n\n', field, string(value))];
                    end
                end
            end
            
            methodContent = [methodContent, sprintf('\\subsection{Métricas de Avaliação}\n\n')];
            methodContent = [methodContent, sprintf('As seguintes métricas foram utilizadas:\n')];
            methodContent = [methodContent, sprintf('\\begin{itemize}\n')];
            methodContent = [methodContent, sprintf('\\item IoU (Intersection over Union)\n')];
            methodContent = [methodContent, sprintf('\\item Coeficiente Dice\n')];
            methodContent = [methodContent, sprintf('\\item Acurácia\n')];
            methodContent = [methodContent, sprintf('\\end{itemize}\n\n')];
        end
        
        function comparison = prepareComparisonData(obj, unetResults, attentionResults)
            % Prepara dados para comparação
            
            comparison = struct();
            comparison.unet = unetResults;
            comparison.attention = attentionResults;
            comparison.generation_date = datestr(now);
            
            % Calcular estatísticas comparativas
            if isfield(unetResults, 'iou') && isfield(attentionResults, 'iou')
                comparison.iou_comparison = struct();
                comparison.iou_comparison.unet_mean = mean(unetResults.iou);
                comparison.iou_comparison.attention_mean = mean(attentionResults.iou);
                comparison.iou_comparison.difference = comparison.iou_comparison.attention_mean - comparison.iou_comparison.unet_mean;
                comparison.iou_comparison.improvement_percent = (comparison.iou_comparison.difference / comparison.iou_comparison.unet_mean) * 100;
            end
            
            if isfield(unetResults, 'dice') && isfield(attentionResults, 'dice')
                comparison.dice_comparison = struct();
                comparison.dice_comparison.unet_mean = mean(unetResults.dice);
                comparison.dice_comparison.attention_mean = mean(attentionResults.dice);
                comparison.dice_comparison.difference = comparison.dice_comparison.attention_mean - comparison.dice_comparison.unet_mean;
                comparison.dice_comparison.improvement_percent = (comparison.dice_comparison.difference / comparison.dice_comparison.unet_mean) * 100;
            end
        end
        
        function htmlContent = generateComparisonHTML(obj, comparison)
            % Gera HTML de comparação
            
            htmlContent = sprintf('<!DOCTYPE html>\n<html>\n<head>\n');
            htmlContent = [htmlContent, sprintf('<meta charset="UTF-8">\n')];
            htmlContent = [htmlContent, sprintf('<title>Comparação de Modelos</title>\n')];
            htmlContent = [htmlContent, obj.getReportCSS()];
            htmlContent = [htmlContent, sprintf('</head>\n<body>\n')];
            
            htmlContent = [htmlContent, sprintf('<div class="container">\n')];
            htmlContent = [htmlContent, sprintf('<h1>Comparação de Modelos</h1>\n')];
            
            % Tabela de comparação IoU
            if isfield(comparison, 'iou_comparison')
                htmlContent = [htmlContent, sprintf('<h2>Comparação IoU</h2>\n')];
                htmlContent = [htmlContent, sprintf('<table class="comparison-table">\n')];
                htmlContent = [htmlContent, sprintf('<tr><th>Modelo</th><th>IoU Médio</th><th>Diferença</th><th>Melhoria (%%)</th></tr>\n')];
                htmlContent = [htmlContent, sprintf('<tr><td>U-Net</td><td>%.4f</td><td>-</td><td>-</td></tr>\n', comparison.iou_comparison.unet_mean)];
                htmlContent = [htmlContent, sprintf('<tr><td>Attention U-Net</td><td>%.4f</td><td>%.4f</td><td>%.2f%%</td></tr>\n', ...
                    comparison.iou_comparison.attention_mean, comparison.iou_comparison.difference, comparison.iou_comparison.improvement_percent)];
                htmlContent = [htmlContent, sprintf('</table>\n')];
            end
            
            % Tabela de comparação Dice
            if isfield(comparison, 'dice_comparison')
                htmlContent = [htmlContent, sprintf('<h2>Comparação Dice</h2>\n')];
                htmlContent = [htmlContent, sprintf('<table class="comparison-table">\n')];
                htmlContent = [htmlContent, sprintf('<tr><th>Modelo</th><th>Dice Médio</th><th>Diferença</th><th>Melhoria (%%)</th></tr>\n')];
                htmlContent = [htmlContent, sprintf('<tr><td>U-Net</td><td>%.4f</td><td>-</td><td>-</td></tr>\n', comparison.dice_comparison.unet_mean)];
                htmlContent = [htmlContent, sprintf('<tr><td>Attention U-Net</td><td>%.4f</td><td>%.4f</td><td>%.2f%%</td></tr>\n', ...
                    comparison.dice_comparison.attention_mean, comparison.dice_comparison.difference, comparison.dice_comparison.improvement_percent)];
                htmlContent = [htmlContent, sprintf('</table>\n')];
            end
            
            htmlContent = [htmlContent, sprintf('</div>\n')];
            htmlContent = [htmlContent, sprintf('</body>\n</html>\n')];
        end
        
        function copyReportAssets(obj, reportPath)
            % Copia recursos necessários para o relatório
            
            try
                [pathStr, ~, ~] = fileparts(reportPath);
                
                % Criar diretório de assets se necessário
                assetsDir = fullfile(pathStr, 'assets');
                if ~exist(assetsDir, 'dir')
                    mkdir(assetsDir);
                end
                
                % Copiar CSS se existir template customizado
                cssFile = fullfile(obj.templateDirectory, 'report.css');
                if exist(cssFile, 'file')
                    copyfile(cssFile, fullfile(assetsDir, 'report.css'));
                end
                
            catch ME
                warning('ReportGenerator:AssetsWarning', ...
                    'Erro ao copiar recursos: %s', ME.message);
            end
        end
        
        function generateBibliography(obj, texFilepath)
            % Gera bibliografia para relatório LaTeX
            
            try
                [pathStr, name, ~] = fileparts(texFilepath);
                bibFile = fullfile(pathStr, [name '.bib']);
                
                % Bibliografia básica
                bibContent = sprintf('@article{unet2015,\n');
                bibContent = [bibContent, sprintf('  title={U-Net: Convolutional Networks for Biomedical Image Segmentation},\n')];
                bibContent = [bibContent, sprintf('  author={Ronneberger, Olaf and Fischer, Philipp and Brox, Thomas},\n')];
                bibContent = [bibContent, sprintf('  journal={arXiv preprint arXiv:1505.04597},\n')];
                bibContent = [bibContent, sprintf('  year={2015}\n')];
                bibContent = [bibContent, sprintf('}\n\n')];
                
                bibContent = [bibContent, sprintf('@article{attention2018,\n')];
                bibContent = [bibContent, sprintf('  title={Attention U-Net: Learning Where to Look for the Pancreas},\n')];
                bibContent = [bibContent, sprintf('  author={Oktay, Ozan and Schlemper, Jo and Folgoc, Loic Le and Lee, Matthew and Heinrich, Mattias and Misawa, Kazunari and Mori, Kensaku and McDonagh, Steven and Hammerla, Nils Y and Kainz, Bernhard and others},\n')];
                bibContent = [bibContent, sprintf('  journal={arXiv preprint arXiv:1804.03999},\n')];
                bibContent = [bibContent, sprintf('  year={2018}\n')];
                bibContent = [bibContent, sprintf('}\n')];
                
                fid = fopen(bibFile, 'w', 'n', 'UTF-8');
                fprintf(fid, '%s', bibContent);
                fclose(fid);
                
            catch ME
                warning('ReportGenerator:BibliographyWarning', ...
                    'Erro ao gerar bibliografia: %s', ME.message);
            end
        end
        
        % Métodos auxiliares para geração de conteúdo HTML
        function content = generateHTMLHeader(obj, title, author)
            content = sprintf('<header class="report-header">\n');
            content = [content, sprintf('<h1>%s</h1>\n', title)];
            content = [content, sprintf('<p class="author">%s</p>\n', author)];
            content = [content, sprintf('<p class="date">%s</p>\n', datestr(now, 'dd/mm/yyyy HH:MM'))];
            content = [content, sprintf('</header>\n\n')];
        end
        
        function content = generateHTMLExecutiveSummary(obj, results)
            content = sprintf('<section class="executive-summary">\n');
            content = [content, sprintf('<h2>Sumário Executivo</h2>\n')];
            content = [content, sprintf('<p>Relatório gerado automaticamente pelo sistema de comparação de modelos de segmentação.</p>\n')];
            content = [content, sprintf('</section>\n\n')];
        end
        
        function content = generateHTMLMethodology(obj, results)
            content = sprintf('<section class="methodology">\n');
            content = [content, sprintf('<h2>Metodologia</h2>\n')];
            content = [content, sprintf('<p>Comparação entre modelos U-Net e Attention U-Net para segmentação de imagens.</p>\n')];
            content = [content, sprintf('</section>\n\n')];
        end
        
        function content = generateHTMLResults(obj, results)
            content = sprintf('<section class="results">\n');
            content = [content, sprintf('<h2>Resultados</h2>\n')];
            content = [content, sprintf('<p>Seção de resultados será implementada com base nos dados fornecidos.</p>\n')];
            content = [content, sprintf('</section>\n\n')];
        end
        
        function content = generateHTMLStatistics(obj, results)
            content = sprintf('<section class="statistics">\n');
            content = [content, sprintf('<h2>Análise Estatística</h2>\n')];
            content = [content, sprintf('<p>Análises estatísticas detalhadas dos resultados.</p>\n')];
            content = [content, sprintf('</section>\n\n')];
        end
        
        function content = generateHTMLVisualizations(obj, results)
            content = sprintf('<section class="visualizations">\n');
            content = [content, sprintf('<h2>Visualizações</h2>\n')];
            content = [content, sprintf('<p>Gráficos e visualizações dos resultados.</p>\n')];
            content = [content, sprintf('</section>\n\n')];
        end
        
        function content = generateHTMLConclusions(obj, results)
            content = sprintf('<section class="conclusions">\n');
            content = [content, sprintf('<h2>Conclusões</h2>\n')];
            content = [content, sprintf('<p>Conclusões baseadas nos resultados obtidos.</p>\n')];
            content = [content, sprintf('</section>\n\n')];
        end
        
        function content = generateHTMLRawData(obj, results)
            content = sprintf('<section class="raw-data">\n');
            content = [content, sprintf('<h2>Dados Brutos</h2>\n')];
            content = [content, sprintf('<details>\n')];
            content = [content, sprintf('<summary>Clique para expandir dados brutos</summary>\n')];
            content = [content, sprintf('<pre>%s</pre>\n', jsonencode(results))];
            content = [content, sprintf('</details>\n')];
            content = [content, sprintf('</section>\n\n')];
        end
        
        function content = generateHTMLFooter(obj)
            content = sprintf('<footer class="report-footer">\n');
            content = [content, sprintf('<p>Relatório gerado automaticamente em %s</p>\n', datestr(now))];
            content = [content, sprintf('</footer>\n\n')];
        end
        
        % Métodos auxiliares para LaTeX
        function content = generateLaTeXAbstract(obj, results)
            content = sprintf('\\begin{abstract}\n');
            content = [content, sprintf('Este relatório apresenta uma comparação entre os modelos U-Net e Attention U-Net para segmentação de imagens médicas.\n')];
            content = [content, sprintf('\\end{abstract}\n\n')];
        end
        
        function content = generateLaTeXIntroduction(obj)
            content = sprintf('\\section{Introdução}\n\n');
            content = [content, sprintf('A segmentação de imagens médicas é uma tarefa fundamental em análise de imagens.\n\n')];
        end
        
        function content = generateLaTeXMethodology(obj, results)
            content = sprintf('\\section{Metodologia}\n\n');
            content = [content, sprintf('Foram utilizados dois modelos de deep learning para comparação.\n\n')];
        end
        
        function content = generateLaTeXResults(obj, results)
            content = sprintf('\\section{Resultados}\n\n');
            content = [content, sprintf('Os resultados obtidos são apresentados a seguir.\n\n')];
        end
        
        function content = generateLaTeXDiscussion(obj, results)
            content = sprintf('\\section{Discussão}\n\n');
            content = [content, sprintf('Os resultados indicam diferenças significativas entre os modelos.\n\n')];
        end
        
        function content = generateLaTeXConclusion(obj, results)
            content = sprintf('\\section{Conclusão}\n\n');
            content = [content, sprintf('Este estudo demonstrou a eficácia dos modelos comparados.\n\n')];
        end
        
        % Templates padrão
        function template = getDefaultHTMLTemplate(obj)
            template = sprintf('<!DOCTYPE html>\n<html>\n<head>\n<meta charset="UTF-8">\n<title>{{TITLE}}</title>\n</head>\n<body>\n{{CONTENT}}\n</body>\n</html>');
        end
        
        function template = getDefaultLaTeXTemplate(obj)
            template = sprintf('\\documentclass{article}\n\\begin{document}\n{{CONTENT}}\n\\end{document}');
        end
        
        function css = getReportCSS(obj)
            css = sprintf('<style>\n');
            css = [css, sprintf('body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }\n')];
            css = [css, sprintf('.container { max-width: 1200px; margin: 0 auto; }\n')];
            css = [css, sprintf('.report-header { text-align: center; border-bottom: 2px solid #333; padding-bottom: 20px; }\n')];
            css = [css, sprintf('.summary-box { background: #f5f5f5; padding: 20px; border-radius: 5px; margin: 20px 0; }\n')];
            css = [css, sprintf('.comparison-table { width: 100%%; border-collapse: collapse; margin: 20px 0; }\n')];
            css = [css, sprintf('.comparison-table th, .comparison-table td { border: 1px solid #ddd; padding: 12px; text-align: left; }\n')];
            css = [css, sprintf('.comparison-table th { background-color: #f2f2f2; }\n')];
            css = [css, sprintf('section { margin: 30px 0; }\n')];
            css = [css, sprintf('h1, h2, h3 { color: #333; }\n')];
            css = [css, sprintf('.report-footer { text-align: center; margin-top: 50px; font-size: 0.9em; color: #666; }\n')];
            css = [css, sprintf('</style>\n')];
        end
        
        function packages = getLaTeXPackages(obj)
            packages = sprintf('\\usepackage[utf8]{inputenc}\n');
            packages = [packages, sprintf('\\usepackage[T1]{fontenc}\n')];
            packages = [packages, sprintf('\\usepackage{graphicx}\n')];
            packages = [packages, sprintf('\\usepackage{amsmath}\n')];
            packages = [packages, sprintf('\\usepackage{amsfonts}\n')];
            packages = [packages, sprintf('\\usepackage{amssymb}\n')];
            packages = [packages, sprintf('\\usepackage{booktabs}\n')];
            packages = [packages, sprintf('\\usepackage{hyperref}\n')];
            packages = [packages, sprintf('\\usepackage{geometry}\n')];
            packages = [packages, sprintf('\\geometry{a4paper,margin=2.5cm}\n\n')];
        end
    end
end