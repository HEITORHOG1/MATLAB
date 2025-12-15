function executar_curvas_aprendizado()
    % executar_curvas_aprendizado - Executa a geração da Figura 6: Curvas de Aprendizado
    % 
    % Este script gera as curvas de loss e accuracy durante o treinamento
    % para U-Net e Attention U-Net, conforme especificado no artigo científico
    
    fprintf('=== GERAÇÃO DE CURVAS DE APRENDIZADO ===\n');
    fprintf('Tarefa 16: Criar figura 6: Curvas de aprendizado\n\n');
    
    try
        % Adicionar caminhos necessários
        addpath('src/visualization');
        
        % Gerar figura completa
        gerar_curvas_aprendizado();
        
        % Validar resultado
        validarCurvasAprendizado();
        
        fprintf('\n✅ EXECUÇÃO CONCLUÍDA COM SUCESSO!\n');
        fprintf('📊 Figura gerada: figuras/figura_curvas_aprendizado.svg\n');
        fprintf('📋 Localização no artigo: Seção Resultados (7.2)\n');
        
    catch ME
        fprintf('\n❌ ERRO NA EXECUÇÃO:\n');
        fprintf('Erro: %s\n', ME.message);
        fprintf('Arquivo: %s (linha %d)\n', ME.stack(1).file, ME.stack(1).line);
        
        % Tentar diagnóstico
        diagnosticarProblema();
    end
end

function validarCurvasAprendizado()
    % Valida se a figura foi gerada corretamente
    
    fprintf('\n🔍 Validando curvas de aprendizado...\n');
    
    % Verificar se arquivo foi criado
    arquivo_svg = fullfile('figuras', 'figura_curvas_aprendizado.svg');
    arquivo_png = fullfile('figuras', 'figura_curvas_aprendizado.png');
    
    if exist(arquivo_svg, 'file')
        fprintf('✅ Arquivo SVG criado: %s\n', arquivo_svg);
    else
        error('❌ Arquivo SVG não foi criado');
    end
    
    if exist(arquivo_png, 'file')
        fprintf('✅ Arquivo PNG criado: %s\n', arquivo_png);
    else
        warning('⚠️ Arquivo PNG não foi criado');
    end
    
    % Verificar tamanho dos arquivos
    info_svg = dir(arquivo_svg);
    if info_svg.bytes > 1000 % Pelo menos 1KB
        fprintf('✅ Arquivo SVG tem tamanho adequado: %.1f KB\n', info_svg.bytes/1024);
    else
        warning('⚠️ Arquivo SVG muito pequeno: %.1f KB', info_svg.bytes/1024);
    end
    
    fprintf('✅ Validação concluída\n');
end

function diagnosticarProblema()
    % Diagnóstica problemas comuns
    
    fprintf('\n🔧 Executando diagnóstico...\n');
    
    % Verificar se diretório figuras existe
    if ~exist('figuras', 'dir')
        fprintf('⚠️ Diretório figuras não existe - será criado\n');
        mkdir('figuras');
    else
        fprintf('✅ Diretório figuras existe\n');
    end
    
    % Verificar se arquivos de dados existem
    if exist('resultados_comparacao.mat', 'file')
        fprintf('✅ Arquivo resultados_comparacao.mat encontrado\n');
    else
        fprintf('⚠️ Arquivo resultados_comparacao.mat não encontrado - usando dados padrão\n');
    end
    
    % Verificar se classe existe
    if exist('src/visualization/GeradorCurvasAprendizado.m', 'file')
        fprintf('✅ Classe GeradorCurvasAprendizado encontrada\n');
    else
        fprintf('❌ Classe GeradorCurvasAprendizado não encontrada\n');
    end
    
    % Verificar MATLAB Graphics
    try
        figure('Visible', 'off');
        close;
        fprintf('✅ Sistema gráfico MATLAB funcionando\n');
    catch
        fprintf('❌ Problema com sistema gráfico MATLAB\n');
    end
end