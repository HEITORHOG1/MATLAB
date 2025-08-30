% Teste simples do sistema de extração de dados
clear; clc;

fprintf('=== TESTE SIMPLES DO EXTRATOR DE DADOS ===\n\n');

try
    % Adicionar caminhos
    addpath(genpath('src'));
    addpath(genpath('utils'));
    
    % Verificar se a classe existe
    if exist('src/data/ExtratorDadosExperimentais.m', 'file')
        fprintf('✅ Arquivo da classe encontrado\n');
    else
        fprintf('❌ Arquivo da classe não encontrado\n');
        return;
    end
    
    % Tentar criar instância
    fprintf('🔧 Criando instância do extrator...\n');
    extrator = ExtratorDadosExperimentais();
    fprintf('✅ Instância criada com sucesso!\n');
    
    % Testar extração
    fprintf('🚀 Testando extração de dados...\n');
    sucesso = extrator.extrairDadosCompletos();
    
    if sucesso
        fprintf('✅ Extração concluída!\n');
        
        % Salvar dados
        if ~exist('dados', 'dir')
            mkdir('dados');
        end
        
        extrator.salvarDadosExtraidos();
        extrator.gerarRelatorioCompleto();
        
        fprintf('📄 Arquivos gerados com sucesso!\n');
    else
        fprintf('❌ Erro na extração\n');
    end
    
catch ME
    fprintf('❌ ERRO: %s\n', ME.message);
    if ~isempty(ME.stack)
        fprintf('   Arquivo: %s (linha %d)\n', ME.stack(1).name, ME.stack(1).line);
    end
end

fprintf('\n=== FIM DO TESTE ===\n');