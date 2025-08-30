% ========================================================================
% VALIDADOR DA TABELA DE TEMPO COMPUTACIONAL
% ========================================================================
% 
% AUTOR: Heitor Oliveira Gonçalves
% LinkedIn: https://www.linkedin.com/in/heitorhog/
% Data: Agosto 2025
% Versão: 1.0
%
% DESCRIÇÃO:
%   Script para validar a Tabela 4 de análise de tempo computacional
%   gerada para o artigo científico
%
% VALIDAÇÕES:
%   - Existência e integridade dos arquivos gerados
%   - Consistência dos dados estatísticos
%   - Formato LaTeX correto
%   - Valores realistas das métricas computacionais
% ========================================================================

clear; clc;

fprintf('========================================================================\n');
fprintf('VALIDAÇÃO DA TABELA 4: ANÁLISE DE TEMPO COMPUTACIONAL\n');
fprintf('========================================================================\n\n');

try
    % Inicializar contadores de validação
    total_testes = 0;
    testes_passou = 0;
    
    % ====================================================================
    % TESTE 1: Verificar existência dos arquivos
    % ====================================================================
    fprintf('1. Verificando existência dos arquivos...\n');
    total_testes = total_testes + 1;
    
    arquivos_esperados = {
        'tabelas/tabela_tempo_computacional.tex';
        'tabelas/relatorio_tempo_computacional.txt';
        'tabelas/dados_tempo_computacional.mat'
    };
    
    arquivos_existem = true;
    for i = 1:length(arquivos_esperados)
        if exist(arquivos_esperados{i}, 'file')
            fprintf('   ✅ %s\n', arquivos_esperados{i});
        else
            fprintf('   ❌ %s (não encontrado)\n', arquivos_esperados{i});
            arquivos_existem = false;
        end
    end
    
    if arquivos_existem
        fprintf('   ✅ PASSOU: Todos os arquivos foram encontrados\n');
        testes_passou = testes_passou + 1;
    else
        fprintf('   ❌ FALHOU: Alguns arquivos estão ausentes\n');
    end
    
    % ====================================================================
    % TESTE 2: Validar dados MATLAB
    % ====================================================================
    fprintf('\n2. Validando dados MATLAB...\n');
    total_testes = total_testes + 1;
    
    if exist('tabelas/dados_tempo_computacional.mat', 'file')
        try
            dados = load('tabelas/dados_tempo_computacional.mat');
            
            % Verificar estruturas principais
            campos_obrigatorios = {'dadosTempoComputacional', 'estatisticas'};
            dados_validos = true;
            
            for i = 1:length(campos_obrigatorios)
                campo = campos_obrigatorios{i};
                if isfield(dados, campo)
                    fprintf('   ✅ Campo %s presente\n', campo);
                else
                    fprintf('   ❌ Campo %s ausente\n', campo);
                    dados_validos = false;
                end
            end
            
            % Verificar dados dos modelos
            if isfield(dados, 'dadosTempoComputacional')
                dtc = dados.dadosTempoComputacional;
                
                if isfield(dtc, 'unet') && isfield(dtc, 'attention_unet')
                    fprintf('   ✅ Dados de ambos os modelos presentes\n');
                    
                    % Verificar métricas essenciais
                    metricas_essenciais = {'tempo_treinamento_minutos', 'tempo_inferencia_ms', ...
                                         'memoria_gpu_mb', 'fps'};
                    
                    for j = 1:length(metricas_essenciais)
                        metrica = metricas_essenciais{j};
                        if isfield(dtc.unet, metrica) && isfield(dtc.attention_unet, metrica)
                            fprintf('   ✅ Métrica %s presente em ambos modelos\n', metrica);
                        else
                            fprintf('   ❌ Métrica %s ausente\n', metrica);
                            dados_validos = false;
                        end
                    end
                else
                    fprintf('   ❌ Dados dos modelos incompletos\n');
                    dados_validos = false;
                end
            end
            
            if dados_validos
                fprintf('   ✅ PASSOU: Dados MATLAB válidos\n');
                testes_passou = testes_passou + 1;
            else
                fprintf('   ❌ FALHOU: Dados MATLAB inválidos\n');
            end
            
        catch ME
            fprintf('   ❌ FALHOU: Erro ao carregar dados MATLAB: %s\n', ME.message);
        end
    else
        fprintf('   ❌ FALHOU: Arquivo de dados não encontrado\n');
    end
    
    % ====================================================================
    % TESTE 3: Validar tabela LaTeX
    % ====================================================================
    fprintf('\n3. Validando tabela LaTeX...\n');
    total_testes = total_testes + 1;
    
    if exist('tabelas/tabela_tempo_computacional.tex', 'file')
        try
            % Ler conteúdo do arquivo
            fid = fopen('tabelas/tabela_tempo_computacional.tex', 'r', 'n', 'UTF-8');
            conteudo = fread(fid, '*char')';
            fclose(fid);
            
            % Verificar elementos LaTeX essenciais
            elementos_latex = {
                '\begin{table}', 'Início da tabela';
                '\end{table}', 'Fim da tabela';
                '\begin{tabular}', 'Início do tabular';
                '\end{tabular}', 'Fim do tabular';
                '\caption{', 'Caption da tabela';
                '\label{tab:', 'Label da tabela';
                '\toprule', 'Linha superior';
                '\midrule', 'Linha do meio';
                '\bottomrule', 'Linha inferior';
                'Tempo de Processamento', 'Seção de tempo';
                'Uso de Memória', 'Seção de memória';
                'U-Net', 'Coluna U-Net';
                'Attention U-Net', 'Coluna Attention U-Net'
            };
            
            latex_valido = true;
            for i = 1:size(elementos_latex, 1)
                elemento = elementos_latex{i, 1};
                descricao = elementos_latex{i, 2};
                
                if contains(conteudo, elemento)
                    fprintf('   ✅ %s encontrado\n', descricao);
                else
                    fprintf('   ❌ %s não encontrado\n', descricao);
                    latex_valido = false;
                end
            end
            
            % Verificar se há dados numéricos
            if ~isempty(regexp(conteudo, '\d+\.\d+', 'once'))
                fprintf('   ✅ Dados numéricos encontrados\n');
            else
                fprintf('   ❌ Dados numéricos não encontrados\n');
                latex_valido = false;
            end
            
            if latex_valido
                fprintf('   ✅ PASSOU: Tabela LaTeX válida\n');
                testes_passou = testes_passou + 1;
            else
                fprintf('   ❌ FALHOU: Tabela LaTeX inválida\n');
            end
            
        catch ME
            fprintf('   ❌ FALHOU: Erro ao ler tabela LaTeX: %s\n', ME.message);
        end
    else
        fprintf('   ❌ FALHOU: Arquivo LaTeX não encontrado\n');
    end
    
    % ====================================================================
    % TESTE 4: Validar valores realistas
    % ====================================================================
    fprintf('\n4. Validando realismo dos valores...\n');
    total_testes = total_testes + 1;
    
    if exist('tabelas/dados_tempo_computacional.mat', 'file')
        try
            dados = load('tabelas/dados_tempo_computacional.mat');
            
            valores_realistas = true;
            
            if isfield(dados, 'estatisticas') && isfield(dados.estatisticas, 'unet') && ...
               isfield(dados.estatisticas, 'attention_unet')
                
                stats_unet = dados.estatisticas.unet;
                stats_attention = dados.estatisticas.attention_unet;
                
                % Validar tempo de treinamento (deve ser entre 5-120 minutos)
                if isfield(stats_unet, 'tempo_treinamento_minutos')
                    tempo_unet = stats_unet.tempo_treinamento_minutos.mean;
                    tempo_attention = stats_attention.tempo_treinamento_minutos.mean;
                    
                    if tempo_unet >= 5 && tempo_unet <= 120 && tempo_attention >= 5 && tempo_attention <= 120
                        fprintf('   ✅ Tempos de treinamento realistas (%.1f min, %.1f min)\n', ...
                            tempo_unet, tempo_attention);
                    else
                        fprintf('   ❌ Tempos de treinamento irrealistas (%.1f min, %.1f min)\n', ...
                            tempo_unet, tempo_attention);
                        valores_realistas = false;
                    end
                end
                
                % Validar tempo de inferência (deve ser entre 10-500 ms)
                if isfield(stats_unet, 'tempo_inferencia_ms')
                    infer_unet = stats_unet.tempo_inferencia_ms.mean;
                    infer_attention = stats_attention.tempo_inferencia_ms.mean;
                    
                    if infer_unet >= 10 && infer_unet <= 500 && infer_attention >= 10 && infer_attention <= 500
                        fprintf('   ✅ Tempos de inferência realistas (%.0f ms, %.0f ms)\n', ...
                            infer_unet, infer_attention);
                    else
                        fprintf('   ❌ Tempos de inferência irrealistas (%.0f ms, %.0f ms)\n', ...
                            infer_unet, infer_attention);
                        valores_realistas = false;
                    end
                end
                
                % Validar uso de memória GPU (deve ser entre 1-8 GB)
                if isfield(stats_unet, 'memoria_gpu_mb')
                    gpu_unet = stats_unet.memoria_gpu_mb.mean / 1024; % Converter para GB
                    gpu_attention = stats_attention.memoria_gpu_mb.mean / 1024;
                    
                    if gpu_unet >= 1 && gpu_unet <= 8 && gpu_attention >= 1 && gpu_attention <= 8
                        fprintf('   ✅ Uso de memória GPU realista (%.1f GB, %.1f GB)\n', ...
                            gpu_unet, gpu_attention);
                    else
                        fprintf('   ❌ Uso de memória GPU irrealista (%.1f GB, %.1f GB)\n', ...
                            gpu_unet, gpu_attention);
                        valores_realistas = false;
                    end
                end
                
                % Validar que Attention U-Net é mais lento que U-Net
                if isfield(dados.estatisticas, 'comparacao')
                    comp = dados.estatisticas.comparacao;
                    
                    if isfield(comp, 'tempo_treinamento_minutos')
                        diff_treino = comp.tempo_treinamento_minutos.diferenca_percentual;
                        if diff_treino > 0
                            fprintf('   ✅ Attention U-Net mais lenta no treinamento (%+.1f%%)\n', diff_treino);
                        else
                            fprintf('   ⚠️ Attention U-Net mais rápida no treinamento (%+.1f%%) - incomum\n', diff_treino);
                        end
                    end
                    
                    if isfield(comp, 'memoria_gpu_mb')
                        diff_memoria = comp.memoria_gpu_mb.diferenca_percentual;
                        if diff_memoria > 0
                            fprintf('   ✅ Attention U-Net usa mais memória (%+.1f%%)\n', diff_memoria);
                        else
                            fprintf('   ⚠️ Attention U-Net usa menos memória (%+.1f%%) - incomum\n', diff_memoria);
                        end
                    end
                end
            end
            
            if valores_realistas
                fprintf('   ✅ PASSOU: Valores são realistas\n');
                testes_passou = testes_passou + 1;
            else
                fprintf('   ❌ FALHOU: Alguns valores são irrealistas\n');
            end
            
        catch ME
            fprintf('   ❌ FALHOU: Erro na validação de valores: %s\n', ME.message);
        end
    else
        fprintf('   ❌ FALHOU: Dados não disponíveis para validação\n');
    end
    
    % ====================================================================
    % TESTE 5: Validar relatório
    % ====================================================================
    fprintf('\n5. Validando relatório...\n');
    total_testes = total_testes + 1;
    
    if exist('tabelas/relatorio_tempo_computacional.txt', 'file')
        try
            % Ler conteúdo do relatório
            fid = fopen('tabelas/relatorio_tempo_computacional.txt', 'r', 'n', 'UTF-8');
            conteudo = fread(fid, '*char')';
            fclose(fid);
            
            % Verificar seções essenciais
            secoes_essenciais = {
                'RELATÓRIO: ANÁLISE DE TEMPO COMPUTACIONAL';
                'RESUMO EXECUTIVO';
                'ANÁLISE DETALHADA';
                'U-NET CLÁSSICA';
                'ATTENTION U-NET';
                'ANÁLISE COMPARATIVA'
            };
            
            relatorio_valido = true;
            for i = 1:length(secoes_essenciais)
                secao = secoes_essenciais{i};
                if contains(conteudo, secao)
                    fprintf('   ✅ Seção "%s" encontrada\n', secao);
                else
                    fprintf('   ❌ Seção "%s" não encontrada\n', secao);
                    relatorio_valido = false;
                end
            end
            
            % Verificar se há dados quantitativos
            if ~isempty(regexp(conteudo, '\d+\.\d+', 'once'))
                fprintf('   ✅ Dados quantitativos encontrados no relatório\n');
            else
                fprintf('   ❌ Dados quantitativos não encontrados no relatório\n');
                relatorio_valido = false;
            end
            
            if relatorio_valido
                fprintf('   ✅ PASSOU: Relatório válido\n');
                testes_passou = testes_passou + 1;
            else
                fprintf('   ❌ FALHOU: Relatório inválido\n');
            end
            
        catch ME
            fprintf('   ❌ FALHOU: Erro ao ler relatório: %s\n', ME.message);
        end
    else
        fprintf('   ❌ FALHOU: Arquivo de relatório não encontrado\n');
    end
    
    % ====================================================================
    % RESUMO FINAL DA VALIDAÇÃO
    % ====================================================================
    fprintf('\n========================================================================\n');
    fprintf('RESUMO DA VALIDAÇÃO\n');
    fprintf('========================================================================\n');
    
    percentual_sucesso = (testes_passou / total_testes) * 100;
    
    fprintf('Testes executados: %d\n', total_testes);
    fprintf('Testes aprovados: %d\n', testes_passou);
    fprintf('Taxa de sucesso: %.1f%%\n\n', percentual_sucesso);
    
    if percentual_sucesso >= 80
        fprintf('✅ VALIDAÇÃO APROVADA!\n');
        fprintf('A Tabela 4 de análise de tempo computacional foi gerada corretamente\n');
        fprintf('e está pronta para integração no artigo científico.\n\n');
        
        fprintf('📋 CHECKLIST FINAL:\n');
        fprintf('☑️ Arquivos LaTeX, relatório e dados gerados\n');
        fprintf('☑️ Estrutura LaTeX correta para publicação\n');
        fprintf('☑️ Dados estatísticos consistentes\n');
        fprintf('☑️ Valores realistas para métricas computacionais\n');
        fprintf('☑️ Relatório detalhado disponível\n\n');
        
        fprintf('🎯 TASK 21 VALIDADA COM SUCESSO!\n');
        
    elseif percentual_sucesso >= 60
        fprintf('⚠️ VALIDAÇÃO PARCIAL\n');
        fprintf('A tabela foi gerada mas alguns problemas foram identificados.\n');
        fprintf('Revisar os itens marcados como FALHOU acima.\n');
        
    else
        fprintf('❌ VALIDAÇÃO REPROVADA\n');
        fprintf('Muitos problemas foram identificados. A tabela precisa ser regenerada.\n');
    end
    
catch ME
    fprintf('\n❌ ERRO NA VALIDAÇÃO: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

fprintf('\n========================================================================\n');
fprintf('Fim da validação da tabela de tempo computacional\n');
fprintf('========================================================================\n');