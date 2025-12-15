% ========================================================================
% GERAR TABELA DE CONFIGURAÇÕES DE TREINAMENTO
% ========================================================================
% 
% AUTOR: Heitor Oliveira Gonçalves
% LinkedIn: https://www.linkedin.com/in/heitorhog/
% Data: Agosto 2025
% Versão: 1.0
%
% DESCRIÇÃO:
%   Script principal para gerar a Tabela 2 do artigo científico com
%   configurações de treinamento, hiperparâmetros e especificações de hardware
%
% TASK: 19. Criar tabela 2: Configurações de treinamento
% REQUIREMENTS: 6.5
% ========================================================================

clear; clc; close all;

fprintf('========================================================================\n');
fprintf('GERAÇÃO DA TABELA DE CONFIGURAÇÕES DE TREINAMENTO\n');
fprintf('========================================================================\n\n');

try
    % Adicionar caminhos necessários
    addpath(genpath('src'));
    addpath(genpath('utils'));
    
    % Criar instância do gerador
    fprintf('🔧 Inicializando gerador de tabela de configurações...\n');
    gerador = GeradorTabelaConfiguracoes('verbose', true);
    
    % Gerar tabela completa
    fprintf('\n🚀 Gerando tabela de configurações de treinamento...\n');
    sucesso = gerador.gerarTabelaCompleta();
    
    if sucesso
        fprintf('\n✅ Tabela de configurações gerada com sucesso!\n');
        
        % Gerar relatório
        fprintf('\n📄 Gerando relatório...\n');
        gerador.gerarRelatorio();
        
        % Exibir resumo
        fprintf('\n📊 RESUMO DA TABELA GERADA:\n');
        fprintf('===========================\n');
        
        fprintf('Arquivos gerados:\n');
        fprintf('1. tabelas/tabela_configuracoes_treinamento.tex - Tabela LaTeX para artigo\n');
        fprintf('2. tabelas/configuracoes_treinamento.txt - Versão em texto\n');
        fprintf('3. tabelas/relatorio_tabela_configuracoes.txt - Relatório detalhado\n\n');
        
        fprintf('Configurações documentadas:\n');
        fprintf('- Arquiteturas: U-Net Clássica e Attention U-Net\n');
        fprintf('- Hiperparâmetros: Otimizador, learning rate, épocas, batch size\n');
        fprintf('- Dataset: 414 imagens (70%% treino, 15%% validação, 15%% teste)\n');
        fprintf('- Hardware: CPU, RAM, GPU e especificações\n');
        fprintf('- Software: MATLAB R2023b, Deep Learning Toolbox\n\n');
        
        % Verificar se arquivos foram criados
        arquivos_esperados = {
            'tabelas/tabela_configuracoes_treinamento.tex';
            'tabelas/configuracoes_treinamento.txt';
            'tabelas/relatorio_tabela_configuracoes.txt'
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
        
        if arquivos_criados == length(arquivos_esperados)
            fprintf('\n🎯 TASK 19 COMPLETADA COM SUCESSO! 🎯\n');
            fprintf('A Tabela 2 de configurações de treinamento foi gerada e está pronta\n');
            fprintf('para integração no artigo científico.\n\n');
            
            fprintf('PRÓXIMOS PASSOS:\n');
            fprintf('1. Revisar o arquivo LaTeX gerado\n');
            fprintf('2. Integrar no documento principal (artigo_cientifico_corrosao.tex)\n');
            fprintf('3. Verificar formatação e alinhamento na compilação\n');
            fprintf('4. Validar informações técnicas com dados reais do projeto\n');
        else
            fprintf('\n⚠️ Alguns arquivos não foram criados corretamente.\n');
        end
        
    else
        fprintf('\n❌ Erro na geração da tabela de configurações!\n');
    end
    
catch ME
    fprintf('\n❌ ERRO NO SCRIPT: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

fprintf('\n========================================================================\n');
fprintf('Fim da geração da tabela de configurações\n');
fprintf('========================================================================\n');