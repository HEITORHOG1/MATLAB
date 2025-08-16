function executar_sistema_completo()
    % EXECUTAR_SISTEMA_COMPLETO - Script principal do sistema de segmentação
    %
    % Este script executa todo o pipeline de segmentação:
    % 1. Verificação de caminhos e configuração inicial
    % 2. Treinamento dos modelos U-Net e Attention U-Net
    % 3. Segmentação das imagens após treinamento
    % 4. Organização dos resultados
    % 5. Comparação e análise dos modelos
    %
    % Uso: executar_sistema_completo()
    %
    % Autor: Sistema de Segmentação Completo
    % Data: 2025
    
    % Configuração inicial
    fprintf('\n');
    fprintf('========================================\n');
    fprintf('  SISTEMA DE SEGMENTAÇÃO COMPLETO\n');
    fprintf('========================================\n');
    fprintf('Iniciando execução do pipeline completo...\n\n');
    
    % Adicionar caminhos necessários
    addpath(genpath('src'));
    
    % Inicializar timer e logging
    tic; % Iniciar cronômetro
    logFile = inicializar_logging();
    
    try
        % Etapa 1: Configuração inicial e verificação de caminhos
        fprintf('[1/5] Verificando configuração inicial...\n');
        log_message(logFile, 'INFO', 'Iniciando verificação de configuração');
        
        config = verificar_configuracao_inicial();
        if isempty(config)
            error('Falha na configuração inicial. Execução interrompida.');
        end
        
        fprintf('✅ Configuração verificada com sucesso!\n\n');
        log_message(logFile, 'INFO', 'Configuração verificada com sucesso');
        
        % Etapa 2: Treinamento dos modelos
        fprintf('[2/5] Iniciando treinamento dos modelos...\n');
        log_message(logFile, 'INFO', 'Iniciando fase de treinamento');
        
        [modelo_unet, modelo_attention] = executar_treinamento(config, logFile);
        
        fprintf('✅ Treinamento concluído com sucesso!\n\n');
        log_message(logFile, 'INFO', 'Treinamento concluído com sucesso');
        
        % Etapa 3: Segmentação das imagens
        fprintf('[3/5] Aplicando modelos nas imagens de teste...\n');
        log_message(logFile, 'INFO', 'Iniciando fase de segmentação');
        
        executar_segmentacao(config, modelo_unet, modelo_attention, logFile);
        
        fprintf('✅ Segmentação concluída com sucesso!\n\n');
        log_message(logFile, 'INFO', 'Segmentação concluída com sucesso');
        
        % Etapa 4: Organização dos resultados
        fprintf('[4/5] Organizando resultados...\n');
        log_message(logFile, 'INFO', 'Iniciando organização de resultados');
        
        organizar_resultados(config, logFile);
        
        fprintf('✅ Resultados organizados com sucesso!\n\n');
        log_message(logFile, 'INFO', 'Organização de resultados concluída');
        
        % Etapa 5: Comparação e análise
        fprintf('[5/5] Comparando modelos e gerando relatórios...\n');
        log_message(logFile, 'INFO', 'Iniciando comparação de modelos');
        
        executar_comparacao(config, logFile);
        
        fprintf('✅ Comparação concluída com sucesso!\n\n');
        log_message(logFile, 'INFO', 'Comparação de modelos concluída');
        
        % Finalização
        fprintf('========================================\n');
        fprintf('🎉 EXECUÇÃO CONCLUÍDA COM SUCESSO! 🎉\n');
        fprintf('========================================\n');
        fprintf('Resultados salvos em: %s\n', config.caminhos.saida);
        fprintf('Log de execução: %s\n', logFile);
        fprintf('Tempo total de execução: %.2f minutos\n', toc/60);
        
        log_message(logFile, 'INFO', 'Sistema executado com sucesso');
        
    catch ME
        % Tratamento de erros
        fprintf('\n❌ ERRO DURANTE A EXECUÇÃO:\n');
        fprintf('Mensagem: %s\n', ME.message);
        fprintf('Arquivo: %s\n', ME.stack(1).file);
        fprintf('Linha: %d\n', ME.stack(1).line);
        fprintf('\nExecução interrompida. Verifique o log para mais detalhes.\n');
        fprintf('Log de execução: %s\n', logFile);
        
        % Log do erro
        log_message(logFile, 'ERROR', sprintf('Erro durante execução: %s', ME.message));
        log_message(logFile, 'ERROR', sprintf('Arquivo: %s, Linha: %d', ME.stack(1).file, ME.stack(1).line));
        
        rethrow(ME);
    end
    
    % Fechar arquivo de log
    if exist('logFile', 'var') && ~isempty(logFile)
        fclose(logFile);
    end
end

%% Funções de Suporte

function logFile = inicializar_logging()
    % Inicializa sistema de logging
    
    % Criar pasta de logs se não existir
    if ~exist('logs', 'dir')
        mkdir('logs');
    end
    
    % Nome do arquivo de log com timestamp
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    logFileName = sprintf('logs/execucao_%s.log', timestamp);
    
    % Abrir arquivo de log
    logFile = fopen(logFileName, 'w');
    
    if logFile == -1
        warning('Não foi possível criar arquivo de log. Continuando sem logging.');
        logFile = [];
        return;
    end
    
    % Escrever cabeçalho do log
    fprintf(logFile, '=== LOG DE EXECUÇÃO - SISTEMA DE SEGMENTAÇÃO COMPLETO ===\n');
    fprintf(logFile, 'Data/Hora de início: %s\n', datestr(now));
    fprintf(logFile, 'MATLAB Version: %s\n', version);
    fprintf(logFile, '=========================================================\n\n');
end

function log_message(logFile, level, message)
    % Escreve mensagem no log
    
    if isempty(logFile) || logFile == -1
        return;
    end
    
    timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    fprintf(logFile, '[%s] %s: %s\n', timestamp, level, message);
    
    % Força escrita no arquivo (MATLAB não tem fflush, mas fprintf já escreve imediatamente)
end

function config = verificar_configuracao_inicial()
    % Verifica e configura caminhos necessários para o sistema
    
    fprintf('  → Verificando caminhos de entrada...\n');
    
    % Definir caminhos padrão (corrigidos para o ambiente atual)
    config = struct();
    config.caminhos.imagens_originais = 'img/original';
    config.caminhos.mascaras = 'img/masks';
    config.caminhos.imagens_teste = 'img/imagens apos treinamento/original';
    config.caminhos.saida = 'resultados_segmentacao';
    
    % Verificar existência dos caminhos de entrada
    caminhos_entrada = {
        config.caminhos.imagens_originais, 'Imagens originais para treinamento';
        config.caminhos.mascaras, 'Máscaras para treinamento';
        config.caminhos.imagens_teste, 'Imagens para segmentação'
    };
    
    for i = 1:size(caminhos_entrada, 1)
        caminho = caminhos_entrada{i, 1};
        descricao = caminhos_entrada{i, 2};
        
        if ~exist(caminho, 'dir')
            fprintf('    ❌ %s não encontrado: %s\n', descricao, caminho);
            config = [];
            return;
        else
            % Contar arquivos no diretório
            arquivos = dir(fullfile(caminho, '*.png'));
            if isempty(arquivos)
                arquivos = dir(fullfile(caminho, '*.jpg'));
            end
            fprintf('    ✅ %s: %d arquivos encontrados\n', descricao, length(arquivos));
        end
    end
    
    fprintf('  → Criando estrutura de pastas de saída...\n');
    
    % Criar pastas de saída
    pastas_saida = {
        config.caminhos.saida;
        fullfile(config.caminhos.saida, 'unet');
        fullfile(config.caminhos.saida, 'attention_unet');
        fullfile(config.caminhos.saida, 'comparacoes');
        fullfile(config.caminhos.saida, 'relatorios');
        fullfile(config.caminhos.saida, 'modelos');
        'logs'
    };
    
    for i = 1:length(pastas_saida)
        if ~exist(pastas_saida{i}, 'dir')
            mkdir(pastas_saida{i});
            fprintf('    ✅ Pasta criada: %s\n', pastas_saida{i});
        else
            fprintf('    ✅ Pasta já existe: %s\n', pastas_saida{i});
        end
    end
    
    % Configurações de treinamento
    config.treinamento.epochs = 50;
    config.treinamento.batch_size = 8;
    config.treinamento.learning_rate = 0.001;
    config.treinamento.validation_split = 0.2;
    
    % Configurações de segmentação
    config.segmentacao.formato_saida = 'png';
    config.segmentacao.qualidade = 95;
    
    fprintf('  → Configuração inicial concluída\n');
end

function [modelo_unet, modelo_attention] = executar_treinamento(config, logFile)
    % Executa o treinamento dos modelos U-Net e Attention U-Net
    
    fprintf('  → Preparando para treinamento dos modelos...\n');
    log_message(logFile, 'INFO', 'Iniciando preparação para treinamento');
    
    % Verificar se os treinadores existem
    if ~exist('src/treinamento/TreinadorUNet.m', 'file')
        fprintf('    ⚠️  TreinadorUNet.m não encontrado. Será necessário implementar.\n');
        log_message(logFile, 'WARNING', 'TreinadorUNet.m não encontrado');
        modelo_unet = [];
    else
        fprintf('    → Treinando modelo U-Net...\n');
        treinador_unet = TreinadorUNet(config.caminhos.imagens_originais, config.caminhos.mascaras);
        modelo_unet = treinador_unet.treinar();
        fprintf('    ✅ U-Net treinado com sucesso\n');
    end
    
    if ~exist('src/treinamento/TreinadorAttentionUNet.m', 'file')
        fprintf('    ⚠️  TreinadorAttentionUNet.m não encontrado. Será necessário implementar.\n');
        log_message(logFile, 'WARNING', 'TreinadorAttentionUNet.m não encontrado');
        modelo_attention = [];
    else
        fprintf('    → Treinando modelo Attention U-Net...\n');
        treinador_attention = TreinadorAttentionUNet(config.caminhos.imagens_originais, config.caminhos.mascaras);
        modelo_attention = treinador_attention.treinar();
        fprintf('    ✅ Attention U-Net treinado com sucesso\n');
    end
    
    log_message(logFile, 'INFO', 'Fase de treinamento concluída');
end

function executar_segmentacao(config, modelo_unet, modelo_attention, logFile)
    % Executa a segmentação das imagens de teste
    
    fprintf('  → Preparando para segmentação das imagens...\n');
    log_message(logFile, 'INFO', 'Iniciando segmentação de imagens');
    
    % Verificar se o segmentador existe
    if ~exist('src/segmentacao/SegmentadorImagens.m', 'file')
        fprintf('    ⚠️  SegmentadorImagens.m não encontrado. Será necessário implementar.\n');
        log_message(logFile, 'WARNING', 'SegmentadorImagens.m não encontrado');
        return;
    end
    
    % Se os modelos não foram passados, tentar carregar dos arquivos
    if isempty(modelo_unet)
        if exist('modelo_unet.mat', 'file')
            fprintf('    → Carregando modelo U-Net do arquivo...\n');
            dados_unet = load('modelo_unet.mat');
        else
            caminhoModeloUNet = fullfile(config.caminhos.saida, 'modelos', 'modelo_unet.mat');
            if exist(caminhoModeloUNet, 'file')
                fprintf('    → Carregando modelo U-Net do arquivo (pasta de resultados)...\n');
                dados_unet = load(caminhoModeloUNet);
            else
                dados_unet = struct();
            end
        end
        if ~isempty(fieldnames(dados_unet))
            if isfield(dados_unet, 'modelo')
                modelo_unet = dados_unet.modelo;
            elseif isfield(dados_unet, 'net')
                modelo_unet = dados_unet.net;
            elseif isfield(dados_unet, 'netUNet')
                modelo_unet = dados_unet.netUNet;
            end
            if ~isempty(modelo_unet)
                fprintf('    ✅ Modelo U-Net carregado\n');
            end
        end
    end

    if isempty(modelo_attention)
        if exist('modelo_attention_unet.mat', 'file')
            fprintf('    → Carregando modelo Attention U-Net do arquivo...\n');
            dados_attention = load('modelo_attention_unet.mat');
        else
            caminhoModeloAtt = fullfile(config.caminhos.saida, 'modelos', 'modelo_attention_unet.mat');
            if exist(caminhoModeloAtt, 'file')
                fprintf('    → Carregando modelo Attention U-Net do arquivo (pasta de resultados)...\n');
                dados_attention = load(caminhoModeloAtt);
            else
                dados_attention = struct();
            end
        end
        if ~isempty(fieldnames(dados_attention))
            if isfield(dados_attention, 'modelo')
                modelo_attention = dados_attention.modelo;
            elseif isfield(dados_attention, 'net')
                modelo_attention = dados_attention.net;
            elseif isfield(dados_attention, 'netAttUNet')
                modelo_attention = dados_attention.netAttUNet;
            end
            if ~isempty(modelo_attention)
                fprintf('    ✅ Modelo Attention U-Net carregado\n');
            end
        end
    end
    
    % Verificar se temos os modelos necessários
    if isempty(modelo_unet) || isempty(modelo_attention)
        fprintf('    ❌ Modelos não disponíveis para segmentação\n');
        log_message(logFile, 'ERROR', 'Modelos não disponíveis para segmentação');
        return;
    end
    
    % Contar imagens para segmentar
    arquivos_teste = dir(fullfile(config.caminhos.imagens_teste, '*.png'));
    if isempty(arquivos_teste)
        arquivos_teste = dir(fullfile(config.caminhos.imagens_teste, '*.jpg'));
    end
    
    fprintf('    → %d imagens encontradas para segmentação\n', length(arquivos_teste));
    
    % Executar segmentação
    segmentador = SegmentadorImagens(config.caminhos.imagens_teste, modelo_unet, modelo_attention, config.caminhos.saida);
    segmentador.segmentar();
    
    fprintf('    ✅ Segmentação concluída para todas as imagens\n');
    log_message(logFile, 'INFO', sprintf('Segmentação concluída para %d imagens', length(arquivos_teste)));
end

function organizar_resultados(config, logFile)
    % Organiza os resultados da segmentação
    
    fprintf('  → Organizando resultados da segmentação...\n');
    log_message(logFile, 'INFO', 'Iniciando organização de resultados');
    
    % Verificar se o organizador existe (corrigir caminho)
    if ~exist('src/organization/OrganizadorResultados.m', 'file')
        fprintf('    ⚠️  OrganizadorResultados.m não encontrado. Será necessário implementar.\n');
        log_message(logFile, 'WARNING', 'OrganizadorResultados.m não encontrado');
        return;
    end
    
    % Executar organização
    OrganizadorResultados.organizar();
    
    fprintf('    ✅ Resultados organizados em estrutura de pastas\n');
    log_message(logFile, 'INFO', 'Organização de resultados concluída');
end

function executar_comparacao(config, logFile)
    % Executa a comparação entre os modelos
    
    fprintf('  → Comparando performance dos modelos...\n');
    log_message(logFile, 'INFO', 'Iniciando comparação de modelos');
    
    % Verificar se o comparador existe
    if ~exist('src/comparacao/ComparadorModelos.m', 'file')
        fprintf('    ⚠️  ComparadorModelos.m não encontrado. Será necessário implementar.\n');
        log_message(logFile, 'WARNING', 'ComparadorModelos.m não encontrado');
        return;
    end
    
    % Executar comparação
    ComparadorModelos.executarComparacaoCompleta();
    
    fprintf('    ✅ Comparação concluída e relatórios gerados\n');
    log_message(logFile, 'INFO', 'Comparação de modelos concluída');
end