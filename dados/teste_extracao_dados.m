% ========================================================================
% TESTE DO SISTEMA DE EXTRAÇÃO DE DADOS EXPERIMENTAIS
% ========================================================================
% 
% AUTOR: Heitor Oliveira Gonçalves
% LinkedIn: https://www.linkedin.com/in/heitorhog/
% Data: Agosto 2025
% Versão: 1.0
%
% DESCRIÇÃO:
%   Script para testar e demonstrar o sistema de extração de dados
%   experimentais para o artigo científico sobre detecção de corrosão
% ========================================================================

clear; clc; close all;

fprintf('========================================================================\n');
fprintf('TESTE DO SISTEMA DE EXTRAÇÃO DE DADOS EXPERIMENTAIS\n');
fprintf('========================================================================\n\n');

try
    % Adicionar caminhos necessários
    addpath(genpath('src'));
    addpath(genpath('utils'));
    
    % Criar instância do extrator
    fprintf('🔧 Inicializando extrator de dados experimentais...\n');
    extrator = ExtratorDadosExperimentais('verbose', true);
    
    % Executar extração completa
    fprintf('\n🚀 Iniciando extração completa de dados...\n');
    sucesso = extrator.extrairDadosCompletos();
    
    if sucesso
        fprintf('\n✅ Extração concluída com sucesso!\n');
        
        % Salvar dados extraídos
        fprintf('\n💾 Salvando dados extraídos...\n');
        extrator.salvarDadosExtraidos('dados/dados_experimentais_extraidos.mat');
        
        % Gerar relatório completo
        fprintf('\n📄 Gerando relatório completo...\n');
        extrator.gerarRelatorioCompleto('dados/relatorio_dados_experimentais.txt');
        
        % Exibir resumo dos resultados
        fprintf('\n📊 RESUMO DOS RESULTADOS EXTRAÍDOS:\n');
        fprintf('=====================================\n');
        
        % Verificar se temos dados de análise estatística
        if ~isempty(extrator.analiseEstatistica) && isfield(extrator.analiseEstatistica, 'resumo')
            resumo = extrator.analiseEstatistica.resumo;
            
            fprintf('Modelo superior: %s\n', resumo.modelo_superior);
            fprintf('Métricas analisadas: %d\n', resumo.total_metricas);
            fprintf('Diferenças significativas: %d (%.1f%%)\n', ...
                    resumo.metricas_significativas, resumo.percentual_significativo);
            
            if isfield(resumo, 'metrica_maior_diferenca')
                fprintf('Métrica com maior diferença: %s (%.2f%%)\n', ...
                        resumo.metrica_maior_diferenca, resumo.maior_diferenca_percentual);
            end
        end
        
        % Mostrar características do dataset
        if ~isempty(extrator.caracteristicasDataset)
            ds = extrator.caracteristicasDataset;
            fprintf('\nDataset: %d imagens (%dx%d pixels)\n', ...
                    ds.total_imagens, ds.resolucao_processamento(1), ds.resolucao_processamento(2));
            fprintf('Material: %s\n', ds.material.tipo);
        end
        
        % Mostrar configurações de treinamento
        if ~isempty(extrator.configuracaoTreinamento)
            cfg = extrator.configuracaoTreinamento;
            fprintf('\nTreinamento: %d épocas, batch size %d, LR %.4f\n', ...
                    cfg.epochs, cfg.batch_size, cfg.learning_rate);
        end
        
        fprintf('\n🎯 ARQUIVOS GERADOS:\n');
        fprintf('===================\n');
        fprintf('1. dados/dados_experimentais_extraidos.mat - Dados completos em formato MATLAB\n');
        fprintf('2. dados/relatorio_dados_experimentais.txt - Relatório detalhado em texto\n');
        
        fprintf('\n✨ Sistema de extração testado com sucesso!\n');
        fprintf('Os dados estão prontos para uso no artigo científico.\n');
        
    else
        fprintf('\n❌ Erro na extração de dados!\n');
    end
    
catch ME
    fprintf('\n❌ ERRO NO TESTE: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

fprintf('\n========================================================================\n');
fprintf('Fim do teste\n');
fprintf('========================================================================\n');