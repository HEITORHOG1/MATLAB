function results = run_complete_validation(config)
% RUN_COMPLETE_VALIDATION - Executa validação completa do sistema
%
% Esta função executa todos os testes de validação do sistema melhorado
% de segmentação, incluindo testes de integração, regressão, performance
% e geração de documentação completa.
%
% Uso:
%   results = run_complete_validation()
%   results = run_complete_validation(config)
%
% Parâmetros:
%   config - (opcional) Estrutura de configuração personalizada
%
% Retorna:
%   results - Estrutura com resultados completos da validação
%
% Exemplo:
%   % Executar validação completa com configuração padrão
%   results = run_complete_validation();
%   
%   % Executar com configuração personalizada
%   config = struct();
%   config.outputPath = 'minha_validacao';
%   config.runQuickTests = true;
%   results = run_complete_validation(config);

% Configuração padrão se não fornecida
if nargin < 1
    config = struct();
    config.outputPath = fullfile('validation_results', ['validation_' datestr(now, 'yyyymmdd_HHMMSS')]);
    config.runQuickTests = false;
    config.generateDocumentation = true;
    config.verboseOutput = true;
end

% Adicionar caminhos necessários
fprintf('Configurando ambiente de validação...\n');
addpath(genpath('src'));

% Criar diretório de saída
if ~exist(config.outputPath, 'dir')
    mkdir(config.outputPath);
end

% Inicializar logger principal
fprintf('Iniciando validação completa do sistema...\n');
fprintf('Diretório de saída: %s\n', config.outputPath);
fprintf('Configuração: %s\n', jsonencode(config));

startTime = tic;

try
    %% 1. Executar ValidationMaster
    fprintf('\n=== EXECUTANDO VALIDAÇÃO PRINCIPAL ===\n');
    
    validator = ValidationMaster(config);
    validationResults = validator.runCompleteValidation();
    
    % Salvar resultados principais
    resultsFile = fullfile(config.outputPath, 'validation_results.mat');
    save(resultsFile, 'validationResults');
    
    %% 2. Gerar relatórios de qualidade
    fprintf('\n=== GERANDO RELATÓRIOS DE QUALIDADE ===\n');
    
    reportGenerator = QualityReportGenerator(config);
    qualityReport = reportGenerator.generateFinalReport(validationResults, config.outputPath);
    
    %% 3. Gerar documentação (se habilitado)
    if config.generateDocumentation
        fprintf('\n=== GERANDO DOCUMENTAÇÃO COMPLETA ===\n');
        
        docGenerator = DocumentationGenerator(config);
        documentationResults = docGenerator.generateCompleteDocumentation(config.outputPath);
    else
        documentationResults = struct();
        documentationResults.skipped = true;
        documentationResults.reason = 'Geração de documentação desabilitada';
    end
    
    %% 4. Compilar resultados finais
    results = struct();
    results.validation = validationResults;
    results.qualityReport = qualityReport;
    results.documentation = documentationResults;
    results.config = config;
    results.totalTime = toc(startTime);
    results.timestamp = datetime();
    results.success = validationResults.success && qualityReport.success;
    
    % Salvar resultados completos
    finalResultsFile = fullfile(config.outputPath, 'complete_results.mat');
    save(finalResultsFile, 'results');
    
    %% 5. Gerar resumo final
    fprintf('\n=== RESUMO FINAL DA VALIDAÇÃO ===\n');
    printValidationSummary(results);
    
    % Salvar resumo em arquivo texto
    summaryFile = fullfile(config.outputPath, 'validation_summary.txt');
    generateTextSummary(results, summaryFile);
    
    fprintf('\nValidação completa finalizada com sucesso!\n');
    fprintf('Resultados salvos em: %s\n', config.outputPath);
    
catch ME
    fprintf('\nERRO durante validação: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
    
    % Salvar erro
    results = struct();
    results.success = false;
    results.error = ME;
    results.totalTime = toc(startTime);
    results.timestamp = datetime();
    
    errorFile = fullfile(config.outputPath, 'validation_error.mat');
    save(errorFile, 'results');
    
    rethrow(ME);
end

end

function printValidationSummary(results)
% Imprime resumo da validação no console

fprintf('Tempo total: %.2f segundos\n', results.totalTime);
fprintf('Data/Hora: %s\n', char(results.timestamp));

if results.success
    fprintf('Status: ✓ VALIDAÇÃO BEM-SUCEDIDA\n');
else
    fprintf('Status: ✗ VALIDAÇÃO COM PROBLEMAS\n');
end

% Resumo por categoria
if isfield(results.validation, 'integration')
    integration = results.validation.integration;
    if isfield(integration, 'summary')
        fprintf('Testes de integração: %d/%d passaram (%.1f%%)\n', ...
            integration.summary.passedTests, integration.summary.totalTests, ...
            integration.summary.successRate * 100);
    end
end

if isfield(results.validation, 'regression')
    regression = results.validation.regression;
    if isfield(regression, 'summary')
        fprintf('Testes de regressão: %d/%d passaram (%.1f%%)\n', ...
            regression.summary.passedTests, regression.summary.totalTests, ...
            regression.summary.successRate * 100);
    end
end

if isfield(results.validation, 'performance')
    performance = results.validation.performance;
    if isfield(performance, 'summary')
        fprintf('Testes de performance: %d/%d passaram (%.1f%%)\n', ...
            performance.summary.passedTests, performance.summary.totalTests, ...
            performance.summary.successRate * 100);
    end
end

% Score de qualidade
if isfield(results, 'qualityReport') && isfield(results.qualityReport, 'overallScore')
    fprintf('Score de qualidade: %.1f/100\n', results.qualityReport.overallScore);
end

fprintf('Diretório de resultados: %s\n', results.config.outputPath);
end

function generateTextSummary(results, summaryFile)
% Gera resumo em arquivo texto

try
    fid = fopen(summaryFile, 'w');
    if fid == -1
        warning('Não foi possível criar arquivo de resumo: %s', summaryFile);
        return;
    end
    
    fprintf(fid, '=== RESUMO DA VALIDAÇÃO DO SISTEMA ===\n');
    fprintf(fid, 'Data/Hora: %s\n', char(results.timestamp));
    fprintf(fid, 'Tempo total: %.2f segundos\n', results.totalTime);
    fprintf(fid, '\n');
    
    if results.success
        fprintf(fid, 'RESULTADO: VALIDAÇÃO BEM-SUCEDIDA ✓\n');
    else
        fprintf(fid, 'RESULTADO: VALIDAÇÃO COM PROBLEMAS ✗\n');
    end
    
    fprintf(fid, '\n=== DETALHES POR CATEGORIA ===\n');
    
    % Integração
    if isfield(results.validation, 'integration') && ...
       isfield(results.validation.integration, 'summary')
        summary = results.validation.integration.summary;
        fprintf(fid, 'Testes de Integração:\n');
        fprintf(fid, '  Total: %d\n', summary.totalTests);
        fprintf(fid, '  Passou: %d\n', summary.passedTests);
        fprintf(fid, '  Falhou: %d\n', summary.failedTests);
        fprintf(fid, '  Taxa de sucesso: %.1f%%\n', summary.successRate * 100);
        fprintf(fid, '\n');
    end
    
    % Regressão
    if isfield(results.validation, 'regression') && ...
       isfield(results.validation.regression, 'summary')
        summary = results.validation.regression.summary;
        fprintf(fid, 'Testes de Regressão:\n');
        fprintf(fid, '  Total: %d\n', summary.totalTests);
        fprintf(fid, '  Passou: %d\n', summary.passedTests);
        fprintf(fid, '  Falhou: %d\n', summary.failedTests);
        fprintf(fid, '  Problemas de regressão: %d\n', summary.regressionIssues);
        fprintf(fid, '  Taxa de sucesso: %.1f%%\n', summary.successRate * 100);
        fprintf(fid, '\n');
    end
    
    % Performance
    if isfield(results.validation, 'performance') && ...
       isfield(results.validation.performance, 'summary')
        summary = results.validation.performance.summary;
        fprintf(fid, 'Testes de Performance:\n');
        fprintf(fid, '  Total: %d\n', summary.totalTests);
        fprintf(fid, '  Passou: %d\n', summary.passedTests);
        fprintf(fid, '  Falhou: %d\n', summary.failedTests);
        fprintf(fid, '  Problemas de performance: %d\n', summary.performanceIssues);
        fprintf(fid, '  Taxa de sucesso: %.1f%%\n', summary.successRate * 100);
        fprintf(fid, '\n');
    end
    
    % Score de qualidade
    if isfield(results, 'qualityReport')
        fprintf(fid, '=== MÉTRICAS DE QUALIDADE ===\n');
        if isfield(results.qualityReport, 'overallScore')
            fprintf(fid, 'Score Geral: %.1f/100\n', results.qualityReport.overallScore);
        end
        fprintf(fid, '\n');
    end
    
    % Documentação
    if isfield(results, 'documentation')
        fprintf(fid, '=== DOCUMENTAÇÃO ===\n');
        if isfield(results.documentation, 'success') && results.documentation.success
            fprintf(fid, 'Documentação gerada com sucesso\n');
        elseif isfield(results.documentation, 'skipped') && results.documentation.skipped
            fprintf(fid, 'Geração de documentação foi pulada\n');
        else
            fprintf(fid, 'Problemas na geração de documentação\n');
        end
        fprintf(fid, '\n');
    end
    
    fprintf(fid, '=== ARQUIVOS GERADOS ===\n');
    fprintf(fid, 'Diretório principal: %s\n', results.config.outputPath);
    fprintf(fid, '- validation_results.mat (resultados principais)\n');
    fprintf(fid, '- complete_results.mat (resultados completos)\n');
    fprintf(fid, '- quality_report.html (relatório de qualidade)\n');
    fprintf(fid, '- validation_summary.txt (este arquivo)\n');
    
    if isfield(results, 'documentation') && ...
       isfield(results.documentation, 'success') && results.documentation.success
        fprintf(fid, '- documentation/ (documentação completa)\n');
    end
    
    fprintf(fid, '\n=== FIM DO RESUMO ===\n');
    
    fclose(fid);
    
catch ME
    if exist('fid', 'var') && fid ~= -1
        fclose(fid);
    end
    warning('Erro ao gerar resumo: %s', ME.message);
end

end