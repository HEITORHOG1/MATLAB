function executar_comparacao()
% EXECUTAR_COMPARACAO - Wrapper compatível com versão interativa clássica
%
% Uso:
%   >> executar_comparacao
%
% Para simplificar, delega ao pipeline completo automatizado. Se desejar
% um fluxo interativo no futuro, este arquivo pode ser expandido com um menu.

    if exist('src', 'dir')
        addpath(genpath('src'));
    end

    fprintf('Executando comparação (modo automático)...\n');
    executar_sistema_completo();
end
