function main_sistema_comparacao()
    % ========================================================================
    % MAIN_SISTEMA_COMPARACAO - Arquivo Principal do Sistema
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Arquivo principal para executar o Sistema de Comparação U-Net vs
    %   Attention U-Net. Este é o ponto de entrada único do sistema.
    %
    % COMO USAR:
    %   >> main_sistema_comparacao
    %
    % REQUISITOS:
    %   - MATLAB R2019b ou superior
    %   - Deep Learning Toolbox
    %   - Image Processing Toolbox
    %
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 3.0 - Performance Optimization
    % ========================================================================
    
    try
        % Verificar se estamos no diretório correto
        if ~exist('src', 'dir')
            error('Execute este script a partir do diretório raiz do projeto!');
        end
        
        % Adicionar caminhos necessários
        addpath(genpath('src'));
        addpath(genpath('scripts'));
        addpath(genpath('utils'));
        
        % Exibir informações do sistema
        fprintf('\n🚀 SISTEMA DE COMPARAÇÃO U-NET vs ATTENTION U-NET\n');
        fprintf('=====================================================\n');
        fprintf('Versão: 3.0 - Performance Optimization\n');
        fprintf('Data: %s\n', datestr(now, 'dd/mm/yyyy HH:MM'));
        fprintf('MATLAB: %s\n', version);
        fprintf('=====================================================\n\n');
        
        % Verificar dependências básicas
        verificarDependencias();
        
        % Criar e executar interface principal
        interface = MainInterface();
        interface.run();
        
    catch ME
        fprintf('❌ Erro ao executar sistema: %s\n', ME.message);
        fprintf('\n💡 Dicas:\n');
        fprintf('1. Verifique se está no diretório correto\n');
        fprintf('2. Verifique se as toolboxes estão instaladas\n');
        fprintf('3. Consulte docs/COMO_USAR.md para mais ajuda\n\n');
        rethrow(ME);
    end
end

function verificarDependencias()
    % Verificar dependências básicas
    
    toolboxes_necessarias = {
        'Deep Learning Toolbox', 'Neural_Network_Toolbox';
        'Image Processing Toolbox', 'Image_Toolbox';
    };
    
    fprintf('🔍 Verificando dependências...\n');
    
    for i = 1:size(toolboxes_necessarias, 1)
        nome = toolboxes_necessarias{i, 1};
        licenca = toolboxes_necessarias{i, 2};
        
        if license('test', licenca)
            fprintf('  ✅ %s: OK\n', nome);
        else
            fprintf('  ❌ %s: NÃO ENCONTRADA\n', nome);
            warning('Toolbox não encontrada: %s', nome);
        end
    end
    
    fprintf('\n');
end