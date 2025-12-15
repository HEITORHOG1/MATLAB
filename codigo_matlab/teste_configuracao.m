% Teste rápido para verificar se configurar_caminhos funciona
clc;
fprintf('=== TESTE DE CONFIGURACAO ===\n');

% Adicionar paths necessários
pasta_atual = pwd;
addpath(pasta_atual);
addpath(fullfile(pasta_atual, 'scripts'));
addpath(fullfile(pasta_atual, 'utils'));
addpath(fullfile(pasta_atual, 'legacy'));

% Verificar se a função existe
if exist('configurar_caminhos', 'file')
    fprintf('✓ Função configurar_caminhos encontrada!\n');
    
    try
        % Tentar executar a função
        fprintf('Tentando executar configurar_caminhos...\n');
        config = configurar_caminhos();
        fprintf('✓ Função executada com sucesso!\n');
        
        % Mostrar resultado
        if isstruct(config)
            fprintf('✓ Configuração retornada é uma estrutura válida\n');
            fields = fieldnames(config);
            fprintf('Campos da configuração:\n');
            for i = 1:length(fields)
                fprintf('  - %s\n', fields{i});
            end
        else
            fprintf('❌ Configuração não é uma estrutura válida\n');
        end
        
    catch ME
        fprintf('❌ Erro ao executar configurar_caminhos:\n');
        fprintf('   %s\n', ME.message);
    end
else
    fprintf('❌ Função configurar_caminhos NÃO encontrada!\n');
    fprintf('Verificando paths:\n');
    paths = strsplit(path, ';');
    for i = 1:min(5, length(paths))
        fprintf('  %s\n', paths{i});
    end
end

fprintf('\n=== FIM DO TESTE ===\n');
