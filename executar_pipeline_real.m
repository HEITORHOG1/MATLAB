function executar_pipeline_real()
% EXECUTAR_PIPELINE_REAL - Wrapper simples para iniciar o pipeline completo
%
% Uso:
%   >> executar_pipeline_real
%
% Este wrapper garante que os paths de 'src' estejam no caminho e delega
% a execução para 'executar_sistema_completo'. Em caso de falha, tenta
% executar o monitoramento de erros para registrar detalhes úteis.

    % Garantir paths necessários
    if exist('src', 'dir')
        addpath(genpath('src'));
    end

    fprintf('=== EXECUTANDO PIPELINE REAL ===\n');
    try
        executar_sistema_completo();
    catch ME
        fprintf('\n⚠️ Falha ao executar o pipeline direto: %s\n', ME.message);
        if exist('monitor_pipeline_errors.m', 'file')
            fprintf('→ Iniciando execução com monitoramento para coletar logs...\n');
            try
                monitor_pipeline_errors();
            catch ME2
                fprintf('✖ Também falhou ao monitorar: %s\n', ME2.message);
                rethrow(ME);
            end
        else
            rethrow(ME);
        end
    end
end
