function executar_comparacao_automatico(varargin)
% EXECUTAR_COMPARACAO_AUTOMATICO - Wrapper de execução não interativa
%
% Uso:
%   >> executar_comparacao_automatico
%   >> executar_comparacao_automatico(5)   % parâmetro opcional ignorado
%
% Este wrapper apenas delega para o pipeline completo automatizado,
% mantendo compatibilidade com scripts e testes legados que chamam
% este nome com um argumento numérico.

    if exist('src', 'dir')
        addpath(genpath('src'));
    end

    try
        executar_sistema_completo();
    catch ME
        fprintf('\n⚠️ Falha na execução automática: %s\n', ME.message);
        if exist('monitor_pipeline_errors.m', 'file')
            try
                monitor_pipeline_errors();
            catch
                % silencia erro secundário e relança original
            end
        end
        rethrow(ME);
    end
end
