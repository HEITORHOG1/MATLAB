classdef QualityReportGenerator < handle
    % QualityReportGenerator - Geração de relatório final de qualidade
    % 
    % Gera relatório abrangente da validação do sistema incluindo
    % métricas de qualidade, análises e recomendações.
    
    properties (Access = private)
        logger
        config
    end
    
    methods
        function obj = QualityReportGenerator(config)
            % Construtor
            if nargin < 1
                obj.config = obj.getDefaultConfig();
            else
                obj.config = config;
            end
            
            obj.logger = ValidationLogger('QualityReportGenerator');
        end
        
        function results = generateFinalReport(obj, validationResults, outputDir)
            % Gera relatório final de qualidade
            obj.logger.info('Gerando relatório final de qualidade...');
            
            try
                % Analisar resultados de validação
                analysis = obj.analyzeValidationResults(validationResults);
                
                % Gerar diferentes formatos de relatório
                results = struct();
                results.htmlReport = obj.generateHTMLReport(analysis, outputDir);
                results.textReport = obj.generateTextReport(analysis, outputDir);
                results.summaryReport = obj.generateSummaryReport(analysis, outputDir);
                results.metricsReport = obj.generateMetricsReport(analysis, outputDir);
                
                % Gerar recomendações
                results.recommendations = obj.generateRecommendations(analysis);
                
                results.success = true;
                obj.logger.info('✓ Relatório final de qualidade gerado');
                
            catch ME
                obj.logger.error(['Erro ao gerar relatório: ' ME.message]);
                results = struct();
                results.error = ME.message;
                results.success = false;
            end
        end
        
        function analysis = analyzeValidationResults(obj, validationResults)
            % Analisa resultados de validação
            analysis = struct();
            
            % Análise geral
            analysis.overallSuccess = validationResults.success;
            analysis.totalTime = validationResults.totalTime;
            analysis.timestamp = datetime();
            
            % Análise por categoria
            categories = {'integration', 'regression', 'performance', 'components', 'compatibility'};
            analysis.categoryResults = struct();
            
            for i = 1:length(categories)
                category = categories{i};
                if isfield(validationResults, category)
                    categoryResult = validationResults.(category);
                    analysis.categoryResults.(category) = obj.analyzeCategoryResult(categoryResult);
                end
            end
            
            % Calcular métricas de qualidade
            analysis.qualityMetrics = obj.calculateQualityMetrics(validationResults);
            
            % Identificar problemas críticos
            analysis.criticalIssues = obj.identifyCriticalIssues(validationResults);
            
            % Calcular score geral
            analysis.overallScore = obj.calculateOverallScore(analysis);
            
            obj.logger.info(['Score geral de qualidade: ' num2str(analysis.overallScore, '%.1f') '/100']);
        end
        
        function categoryAnalysis = analyzeCategoryResult(obj, categoryResult)
            % Analisa resultado de uma categoria específica
            categoryAnalysis = struct();
            
            if isfield(categoryResult, 'summary')
                summary = categoryResult.summary;
                categoryAnalysis.totalTests = summary.totalTests;
                categoryAnalysis.passedTests = summary.passedTests;
                categoryAnalysis.failedTests = summary.failedTests;
                categoryAnalysis.successRate = summary.successRate;
            else
                categoryAnalysis.totalTests = 0;
                categoryAnalysis.passedTests = 0;
                categoryAnalysis.failedTests = 0;
                categoryAnalysis.successRate = 0;
            end
            
            categoryAnalysis.overallSuccess = categoryResult.overallSuccess;
            
            if isfield(categoryResult, 'totalDuration')
                categoryAnalysis.duration = categoryResult.totalDuration;
            else
                categoryAnalysis.duration = 0;
            end
        end
        
        function metrics = calculateQualityMetrics(obj, validationResults)
            % Calcula métricas de qualidade
            metrics = struct();
            
            % Métricas de cobertura
            totalComponents = obj.countTotalComponents();
            testedComponents = obj.countTestedComponents(validationResults);
            metrics.coveragePercentage = (testedComponents / totalComponents) * 100;
            
            % Métricas de confiabilidade
            totalTests = 0;
            passedTests = 0;
            
            categories = {'integration', 'regression', 'performance'};
            for i = 1:length(categories)
                if isfield(validationResults, categories{i}) && ...
                   isfield(validationResults.(categories{i}), 'summary')
                    summary = validationResults.(categories{i}).summary;
                    totalTests = totalTests + summary.totalTests;
                    passedTests = passedTests + summary.passedTests;
                end
            end
            
            if totalTests > 0
                metrics.reliabilityScore = (passedTests / totalTests) * 100;
            else
                metrics.reliabilityScore = 0;
            end
            
            % Métricas de performance
            if isfield(validationResults, 'performance')
                metrics.performanceScore = obj.calculatePerformanceScore(validationResults.performance);
            else
                metrics.performanceScore = 0;
            end
            
            % Métricas de compatibilidade
            if isfield(validationResults, 'regression')
                metrics.compatibilityScore = obj.calculateCompatibilityScore(validationResults.regression);
            else
                metrics.compatibilityScore = 0;
            end
        end
        
        function issues = identifyCriticalIssues(obj, validationResults)
            % Identifica problemas críticos
            issues = {};
            
            % Verificar falhas críticas
            if ~validationResults.success
                issues{end+1} = 'Validação geral falhou - sistema não aprovado';
            end
            
            % Verificar problemas de integração
            if isfield(validationResults, 'integration') && ...
               ~validationResults.integration.overallSuccess
                issues{end+1} = 'Problemas críticos de integração detectados';
            end
            
            % Verificar regressões
            if isfield(validationResults, 'regression') && ...
               isfield(validationResults.regression, 'summary') && ...
               validationResults.regression.summary.regressionIssues > 0
                issues{end+1} = sprintf('%d problemas de regressão detectados', ...
                    validationResults.regression.summary.regressionIssues);
            end
            
            % Verificar problemas de performance
            if isfield(validationResults, 'performance') && ...
               isfield(validationResults.performance, 'summary') && ...
               validationResults.performance.summary.performanceIssues > 0
                issues{end+1} = sprintf('%d problemas de performance detectados', ...
                    validationResults.performance.summary.performanceIssues);
            end
        end
        
        function score = calculateOverallScore(obj, analysis)
            % Calcula score geral de qualidade (0-100)
            weights = struct();
            weights.reliability = 0.3;
            weights.coverage = 0.2;
            weights.performance = 0.2;
            weights.compatibility = 0.2;
            weights.criticalIssues = 0.1;
            
            score = 0;
            
            % Score de confiabilidade
            score = score + analysis.qualityMetrics.reliabilityScore * weights.reliability;
            
            % Score de cobertura
            score = score + analysis.qualityMetrics.coverageScore * weights.coverage;
            
            % Score de performance
            score = score + analysis.qualityMetrics.performanceScore * weights.performance;
            
            % Score de compatibilidade
            score = score + analysis.qualityMetrics.compatibilityScore * weights.compatibility;
            
            % Penalidade por problemas críticos
            criticalPenalty = length(analysis.criticalIssues) * 10;
            score = score - criticalPenalty * weights.criticalIssues;
            
            % Garantir que score está entre 0 e 100
            score = max(0, min(100, score));
        end 
       
        function htmlFile = generateHTMLReport(obj, analysis, outputDir)
            % Gera relatório HTML
            htmlFile = fullfile(outputDir, 'quality_report.html');
            
            html = {
                '<!DOCTYPE html>'
                '<html lang="pt-BR">'
                '<head>'
                '    <meta charset="UTF-8">'
                '    <title>Relatório de Qualidade - Sistema de Segmentação</title>'
                '    <style>'
                '        body { font-family: Arial, sans-serif; margin: 20px; }'
                '        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }'
                '        .success { color: green; font-weight: bold; }'
                '        .warning { color: orange; font-weight: bold; }'
                '        .error { color: red; font-weight: bold; }'
                '        .metric { margin: 10px 0; padding: 10px; border-left: 4px solid #007acc; }'
                '        .score { font-size: 24px; font-weight: bold; }'
                '        table { border-collapse: collapse; width: 100%; margin: 20px 0; }'
                '        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }'
                '        th { background-color: #f2f2f2; }'
                '    </style>'
                '</head>'
                '<body>'
                ''
                '<div class="header">'
                '<h1>Relatório de Qualidade do Sistema</h1>'
                ['<p>Gerado em: ' char(analysis.timestamp) '</p>']
                ['<p>Tempo total de validação: ' num2str(analysis.totalTime, '%.2f') ' segundos</p>']
                '</div>'
                ''
                '<h2>Resumo Executivo</h2>'
            };
            
            % Status geral
            if analysis.overallSuccess
                html{end+1} = '<p class="success">✓ SISTEMA APROVADO</p>';
            else
                html{end+1} = '<p class="error">✗ SISTEMA REPROVADO</p>';
            end
            
            % Score geral
            html{end+1} = ['<div class="score">Score Geral: ' ...
                num2str(analysis.overallScore, '%.1f') '/100</div>'];
            
            % Métricas principais
            html = [html; {
                '<h2>Métricas de Qualidade</h2>'
                '<table>'
                '<tr><th>Métrica</th><th>Valor</th><th>Status</th></tr>'
            }];
            
            metrics = analysis.qualityMetrics;
            html{end+1} = obj.createMetricRow('Cobertura de Testes', ...
                sprintf('%.1f%%', metrics.coveragePercentage), metrics.coveragePercentage >= 80);
            html{end+1} = obj.createMetricRow('Confiabilidade', ...
                sprintf('%.1f%%', metrics.reliabilityScore), metrics.reliabilityScore >= 90);
            html{end+1} = obj.createMetricRow('Performance', ...
                sprintf('%.1f%%', metrics.performanceScore), metrics.performanceScore >= 75);
            html{end+1} = obj.createMetricRow('Compatibilidade', ...
                sprintf('%.1f%%', metrics.compatibilityScore), metrics.compatibilityScore >= 85);
            
            html{end+1} = '</table>';
            
            % Problemas críticos
            if ~isempty(analysis.criticalIssues)
                html = [html; {
                    '<h2>Problemas Críticos</h2>'
                    '<ul>'
                }];
                
                for i = 1:length(analysis.criticalIssues)
                    html{end+1} = ['<li class="error">' analysis.criticalIssues{i} '</li>'];
                end
                
                html{end+1} = '</ul>';
            end
            
            % Resultados por categoria
            html = [html; {
                '<h2>Resultados por Categoria</h2>'
                '<table>'
                '<tr><th>Categoria</th><th>Testes</th><th>Sucessos</th><th>Falhas</th><th>Taxa de Sucesso</th></tr>'
            }];
            
            categories = fieldnames(analysis.categoryResults);
            for i = 1:length(categories)
                category = categories{i};
                result = analysis.categoryResults.(category);
                
                html{end+1} = sprintf('<tr><td>%s</td><td>%d</td><td>%d</td><td>%d</td><td>%.1f%%</td></tr>', ...
                    category, result.totalTests, result.passedTests, result.failedTests, ...
                    result.successRate * 100);
            end
            
            html{end+1} = '</table>';
            
            html = [html; {
                '</body>'
                '</html>'
            }];
            
            obj.writeTextFile(htmlFile, html);
        end
        
        function textFile = generateTextReport(obj, analysis, outputDir)
            % Gera relatório em texto
            textFile = fullfile(outputDir, 'quality_report.txt');
            
            report = {
                '========================================='
                '    RELATÓRIO DE QUALIDADE DO SISTEMA'
                '========================================='
                ''
                ['Gerado em: ' char(analysis.timestamp)]
                ['Tempo de validação: ' num2str(analysis.totalTime, '%.2f') ' segundos']
                ''
                'RESUMO EXECUTIVO'
                '----------------'
            };
            
            if analysis.overallSuccess
                report{end+1} = 'Status: ✓ SISTEMA APROVADO';
            else
                report{end+1} = 'Status: ✗ SISTEMA REPROVADO';
            end
            
            report{end+1} = ['Score Geral: ' num2str(analysis.overallScore, '%.1f') '/100'];
            report{end+1} = '';
            
            % Métricas
            report = [report; {
                'MÉTRICAS DE QUALIDADE'
                '---------------------'
                ['Cobertura de Testes: ' sprintf('%.1f%%', analysis.qualityMetrics.coveragePercentage)]
                ['Confiabilidade: ' sprintf('%.1f%%', analysis.qualityMetrics.reliabilityScore)]
                ['Performance: ' sprintf('%.1f%%', analysis.qualityMetrics.performanceScore)]
                ['Compatibilidade: ' sprintf('%.1f%%', analysis.qualityMetrics.compatibilityScore)]
                ''
            }];
            
            % Problemas críticos
            if ~isempty(analysis.criticalIssues)
                report = [report; {
                    'PROBLEMAS CRÍTICOS'
                    '------------------'
                }];
                
                for i = 1:length(analysis.criticalIssues)
                    report{end+1} = ['- ' analysis.criticalIssues{i}];
                end
                
                report{end+1} = '';
            end
            
            obj.writeTextFile(textFile, report);
        end
        
        function summaryFile = generateSummaryReport(obj, analysis, outputDir)
            % Gera resumo executivo
            summaryFile = fullfile(outputDir, 'executive_summary.txt');
            
            summary = {
                'RESUMO EXECUTIVO - VALIDAÇÃO DO SISTEMA'
                '======================================='
                ''
                ['Data: ' char(analysis.timestamp)]
                ['Score: ' num2str(analysis.overallScore, '%.1f') '/100']
            };
            
            if analysis.overallSuccess
                summary{end+1} = 'Resultado: APROVADO ✓';
                summary{end+1} = '';
                summary{end+1} = 'O sistema passou em todos os testes críticos e está';
                summary{end+1} = 'pronto para uso em produção.';
            else
                summary{end+1} = 'Resultado: REPROVADO ✗';
                summary{end+1} = '';
                summary{end+1} = 'O sistema apresenta problemas que devem ser';
                summary{end+1} = 'corrigidos antes do uso em produção.';
            end
            
            summary{end+1} = '';
            summary{end+1} = 'PRINCIPAIS MÉTRICAS:';
            summary{end+1} = ['- Confiabilidade: ' sprintf('%.1f%%', analysis.qualityMetrics.reliabilityScore)];
            summary{end+1} = ['- Cobertura: ' sprintf('%.1f%%', analysis.qualityMetrics.coveragePercentage)];
            summary{end+1} = ['- Performance: ' sprintf('%.1f%%', analysis.qualityMetrics.performanceScore)];
            
            if ~isempty(analysis.criticalIssues)
                summary{end+1} = '';
                summary{end+1} = 'AÇÕES NECESSÁRIAS:';
                for i = 1:length(analysis.criticalIssues)
                    summary{end+1} = ['- ' analysis.criticalIssues{i}];
                end
            end
            
            obj.writeTextFile(summaryFile, summary);
        end
        
        function metricsFile = generateMetricsReport(obj, analysis, outputDir)
            % Gera relatório detalhado de métricas
            metricsFile = fullfile(outputDir, 'detailed_metrics.mat');
            
            % Salvar métricas em formato MATLAB
            qualityMetrics = analysis.qualityMetrics;
            categoryResults = analysis.categoryResults;
            overallScore = analysis.overallScore;
            criticalIssues = analysis.criticalIssues;
            
            save(metricsFile, 'qualityMetrics', 'categoryResults', ...
                'overallScore', 'criticalIssues');
        end
        
        function recommendations = generateRecommendations(obj, analysis)
            % Gera recomendações baseadas na análise
            recommendations = {};
            
            % Recomendações baseadas no score
            if analysis.overallScore < 70
                recommendations{end+1} = 'Score baixo - revisão completa necessária';
            elseif analysis.overallScore < 85
                recommendations{end+1} = 'Score moderado - melhorias recomendadas';
            end
            
            % Recomendações baseadas em métricas específicas
            if analysis.qualityMetrics.coveragePercentage < 80
                recommendations{end+1} = 'Aumentar cobertura de testes';
            end
            
            if analysis.qualityMetrics.reliabilityScore < 90
                recommendations{end+1} = 'Melhorar confiabilidade dos testes';
            end
            
            if analysis.qualityMetrics.performanceScore < 75
                recommendations{end+1} = 'Otimizar performance do sistema';
            end
            
            % Recomendações baseadas em problemas críticos
            if ~isempty(analysis.criticalIssues)
                recommendations{end+1} = 'Corrigir problemas críticos antes do deploy';
            end
        end
        
        function row = createMetricRow(obj, name, value, isGood)
            % Cria linha da tabela de métricas
            if isGood
                status = '<span class="success">✓</span>';
            else
                status = '<span class="error">✗</span>';
            end
            
            row = sprintf('<tr><td>%s</td><td>%s</td><td>%s</td></tr>', ...
                name, value, status);
        end
        
        function writeTextFile(obj, filename, content)
            % Escreve arquivo de texto
            fid = fopen(filename, 'w', 'n', 'UTF-8');
            if fid ~= -1
                for i = 1:length(content)
                    fprintf(fid, '%s\n', content{i});
                end
                fclose(fid);
            end
        end
        
        function count = countTotalComponents(obj)
            % Conta total de componentes do sistema
            count = 0;
            
            % Contar arquivos .m em src/
            srcDirs = {'model_management', 'optimization', 'inference', ...
                'organization', 'visualization', 'export', 'core', 'utils'};
            
            for i = 1:length(srcDirs)
                dirPath = fullfile('src', srcDirs{i});
                if exist(dirPath, 'dir')
                    files = dir(fullfile(dirPath, '*.m'));
                    count = count + length(files);
                end
            end
        end
        
        function count = countTestedComponents(obj, validationResults)
            % Conta componentes testados
            count = 0;
            
            % Estimar baseado nos testes executados
            if isfield(validationResults, 'integration') && ...
               isfield(validationResults.integration, 'summary')
                count = count + validationResults.integration.summary.totalTests;
            end
            
            if isfield(validationResults, 'regression') && ...
               isfield(validationResults.regression, 'summary')
                count = count + validationResults.regression.summary.totalTests;
            end
        end
        
        function score = calculatePerformanceScore(obj, performanceResults)
            % Calcula score de performance
            if isfield(performanceResults, 'summary')
                summary = performanceResults.summary;
                if summary.performanceIssues == 0
                    score = 100;
                else
                    score = max(0, 100 - (summary.performanceIssues * 20));
                end
            else
                score = 50; % Score neutro se não há dados
            end
        end
        
        function score = calculateCompatibilityScore(obj, regressionResults)
            % Calcula score de compatibilidade
            if isfield(regressionResults, 'summary')
                summary = regressionResults.summary;
                if summary.regressionIssues == 0
                    score = 100;
                else
                    score = max(0, 100 - (summary.regressionIssues * 15));
                end
            else
                score = 50; % Score neutro se não há dados
            end
        end
        
        function config = getDefaultConfig(obj)
            % Configuração padrão
            config = struct();
            config.generateHTML = true;
            config.generateText = true;
            config.generateSummary = true;
            config.includeRecommendations = true;
        end
    end
end