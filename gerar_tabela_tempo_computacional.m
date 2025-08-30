% ========================================================================
% GERAR TABELA 4: ANÁLISE DE TEMPO COMPUTACIONAL
% ========================================================================
% 
% AUTOR: Heitor Oliveira Gonçalves
% LinkedIn: https://www.linkedin.com/in/heitorhog/
% Data: Agosto 2025
% Versão: 1.0
%
% DESCRIÇÃO:
%   Script principal para gerar a Tabela 4 do artigo científico com
%   análise comparativa de tempo computacional entre U-Net e Attention U-Net
%
% TASK: 21. Criar tabela 4: Análise de tempo computacional
% REQUIREMENTS: 6.5
% ========================================================================

clear; clc; close all;

fprintf('========================================================================\n');
fprintf('GERAÇÃO DA TABELA 4: ANÁLISE DE TEMPO COMPUTACIONAL\n');
fprintf('========================================================================\n\n');

try
    % Adicionar caminhos necessários
    addpath(genpath('src'));
    addpath(genpath('utils'));
    
    % Criar instância do gerador
    fprintf('🔧 Inicializando gerador de tabela de tempo computacional...\n');
    gerador = GeradorTabelaTempoComputacional('verbose', true);
    
    % Gerar tabela completa
    fprintf('\n🚀 Gerando análise de tempo computacional...\n');
    sucesso = gerador.gerarTabelaCompleta();
    
    if sucesso
        fprintf('\n✅ Tabela de tempo computacional gerada com sucesso!\n');
        
        % Exibir resumo
        gerador.exibirResumo();
        
        % Verificar arquivos gerados
        fprintf('\n📊 ARQUIVOS GERADOS:\n');
        fprintf('===================\n');
        
        arquivos_esperados = {
            'tabelas/tabela_tempo_computacional.tex';
            'tabelas/relatorio_tempo_computacional.txt';
            'tabelas/dados_tempo_computacional.mat'
        };
        
        arquivos_criados = 0;
        for i = 1:length(arquivos_esperados)
            if exist(arquivos_esperados{i}, 'file')
                arquivos_criados = arquivos_criados + 1;
                fprintf('✅ %s\n', arquivos_esperados{i});
            else
                fprintf('❌ %s (não encontrado)\n', arquivos_esperados{i});
            end
        end
        
        fprintf('\nArquivos criados: %d/%d\n', arquivos_criados, length(arquivos_esperados));
        
        % Exibir conteúdo da tabela LaTeX
        fprintf('\n📄 PRÉVIA DA TABELA LATEX:\n');
        fprintf('==========================\n');
        if ~isempty(gerador.tabelaLatex)
            linhas = strsplit(gerador.tabelaLatex, '\n');
            for i = 1:min(20, length(linhas))  % Mostrar primeiras 20 linhas
                fprintf('%s\n', linhas{i});
            end
            if length(linhas) > 20
                fprintf('... (mais %d linhas)\n', length(linhas) - 20);
            end
        end
        
        % Resumo das métricas principais
        if isfield(gerador.estatisticas, 'comparacao')
            fprintf('\n📈 RESUMO DAS DIFERENÇAS COMPUTACIONAIS:\n');
            fprintf('=======================================\n');
            
            comp = gerador.estatisticas.comparacao;
            
            if isfield(comp, 'tempo_treinamento_minutos')
                diff = comp.tempo_treinamento_minutos.diferenca_percentual;
                if isfield(comp.tempo_treinamento_minutos, 'teste_t') && isfield(comp.tempo_treinamento_minutos.teste_t, 'p_value')
                    p_val = comp.tempo_treinamento_minutos.teste_t.p_value;
                    fprintf('• Tempo de treinamento: %+.1f%% (p = %.4f)\n', diff, p_val);
                else
                    fprintf('• Tempo de treinamento: %+.1f%%\n', diff);
                end
            end
            
            if isfield(comp, 'tempo_inferencia_ms')
                diff = comp.tempo_inferencia_ms.diferenca_percentual;
                if isfield(comp.tempo_inferencia_ms, 'teste_t') && isfield(comp.tempo_inferencia_ms.teste_t, 'p_value')
                    p_val = comp.tempo_inferencia_ms.teste_t.p_value;
                    fprintf('• Tempo de inferência: %+.1f%% (p = %.4f)\n', diff, p_val);
                else
                    fprintf('• Tempo de inferência: %+.1f%%\n', diff);
                end
            end
            
            if isfield(comp, 'memoria_gpu_mb')
                diff = comp.memoria_gpu_mb.diferenca_percentual;
                if isfield(comp.memoria_gpu_mb, 'teste_t') && isfield(comp.memoria_gpu_mb.teste_t, 'p_value')
                    p_val = comp.memoria_gpu_mb.teste_t.p_value;
                    fprintf('• Uso de memória GPU: %+.1f%% (p = %.4f)\n', diff, p_val);
                else
                    fprintf('• Uso de memória GPU: %+.1f%%\n', diff);
                end
            end
            
            if isfield(comp, 'fps')
                diff = comp.fps.diferenca_percentual;
                if isfield(comp.fps, 'teste_t') && isfield(comp.fps.teste_t, 'p_value')
                    p_val = comp.fps.teste_t.p_value;
                    fprintf('• Taxa de processamento: %+.1f%% (p = %.4f)\n', diff, p_val);
                else
                    fprintf('• Taxa de processamento: %+.1f%%\n', diff);
                end
            end
            
            if isfield(comp, 'parametros')
                diff = comp.parametros.diferenca_percentual;
                fprintf('• Número de parâmetros: %+.1f%%\n', diff);
            end
        end
        
        % Instruções para integração
        fprintf('\n🎯 PRÓXIMOS PASSOS:\n');
        fprintf('==================\n');
        fprintf('1. Revisar tabela LaTeX gerada em: tabelas/tabela_tempo_computacional.tex\n');
        fprintf('2. Integrar no documento principal (artigo_cientifico_corrosao.tex)\n');
        fprintf('3. Verificar formatação na compilação LaTeX\n');
        fprintf('4. Validar dados com experimentos reais se disponíveis\n');
        fprintf('5. Ajustar interpretações no texto do artigo\n\n');
        
        % Sugestões para o texto do artigo
        fprintf('💡 SUGESTÕES PARA O TEXTO DO ARTIGO:\n');
        fprintf('===================================\n');
        fprintf('• A Attention U-Net apresenta maior custo computacional devido aos attention gates\n');
        fprintf('• O trade-off entre precisão e eficiência deve ser considerado na aplicação prática\n');
        fprintf('• Tempos de inferência ainda permitem aplicação em tempo real (< 200ms)\n');
        fprintf('• Uso de memória adicional é compensado pela melhoria na qualidade de segmentação\n\n');
        
        if arquivos_criados == length(arquivos_esperados)
            fprintf('🎯 TASK 21 COMPLETADA COM SUCESSO! 🎯\n');
            fprintf('A Tabela 4 de análise de tempo computacional foi gerada e está pronta\n');
            fprintf('para integração no artigo científico.\n\n');
        else
            fprintf('⚠️ Alguns arquivos não foram criados corretamente.\n');
        end
        
    else
        fprintf('\n❌ Erro na geração da tabela de tempo computacional!\n');
    end
    
catch ME
    fprintf('\n❌ ERRO NO SCRIPT: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
    
    % Diagnóstico
    fprintf('\n🔍 DIAGNÓSTICO:\n');
    if exist('src/validation/GeradorTabelaTempoComputacional.m', 'file')
        fprintf('✅ Classe GeradorTabelaTempoComputacional encontrada\n');
    else
        fprintf('❌ Classe GeradorTabelaTempoComputacional não encontrada\n');
    end
    
    if exist('src/data/ExtratorDadosExperimentais.m', 'file')
        fprintf('✅ Extrator de dados encontrado\n');
    else
        fprintf('❌ Extrator de dados não encontrado\n');
    end
    
    if exist('tabelas', 'dir')
        fprintf('✅ Diretório tabelas existe\n');
    else
        fprintf('⚠️ Diretório tabelas será criado\n');
    end
end

fprintf('\n========================================================================\n');
fprintf('Fim da geração da tabela de tempo computacional\n');
fprintf('========================================================================\n');