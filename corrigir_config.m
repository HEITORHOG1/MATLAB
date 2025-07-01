function corrigir_config()
    % Corrigir arquivo de configuração com todos os campos necessários
    
    fprintf('=== CORRIGINDO CONFIGURAÇÃO ===\n');
    
    % Carregar configuração existente ou criar nova
    if exist('config_caminhos.mat', 'file')
        load('config_caminhos.mat', 'config');
        fprintf('Configuração existente carregada.\n');
    else
        config = struct();
        fprintf('Criando nova configuração.\n');
    end
    
    % Garantir que todos os campos necessários existem
    if ~isfield(config, 'imageDir')
        config.imageDir = 'C:\Users\heito\Pictures\imagens_divididas_processadas_2025-06-22-20250626T224937Z-1-001\imagens_divididas_processadas_2025-06-22\original';
    end
    
    if ~isfield(config, 'maskDir')
        config.maskDir = 'C:\Users\heito\Pictures\imagens_divididas_processadas_2025-06-22-20250626T224937Z-1-001\imagens_divididas_processadas_2025-06-22\masks_converted';
    end
    
    if ~isfield(config, 'inputSize')
        config.inputSize = [256, 256, 3];
    end
    
    if ~isfield(config, 'numClasses')
        config.numClasses = 2;
    end
    
    if ~isfield(config, 'validationSplit')
        config.validationSplit = 0.2;
    end
    
    if ~isfield(config, 'miniBatchSize')
        config.miniBatchSize = 8;
    end
    
    if ~isfield(config, 'maxEpochs')
        config.maxEpochs = 20;
    end
    
    if ~isfield(config, 'quickTest')
        config.quickTest = struct('numSamples', 50, 'maxEpochs', 5);
    end
    
    % Salvar configuração corrigida
    save('config_caminhos.mat', 'config');
    
    fprintf('✓ Configuração corrigida e salva!\n');
    fprintf('Campos adicionados:\n');
    fprintf('  - imageDir: %s\n', config.imageDir);
    fprintf('  - maskDir: %s\n', config.maskDir);
    fprintf('  - inputSize: [%d, %d, %d]\n', config.inputSize);
    fprintf('  - numClasses: %d\n', config.numClasses);
    fprintf('  - miniBatchSize: %d\n', config.miniBatchSize);
    fprintf('  - maxEpochs: %d\n', config.maxEpochs);
    fprintf('  - quickTest.numSamples: %d\n', config.quickTest.numSamples);
    fprintf('  - quickTest.maxEpochs: %d\n', config.quickTest.maxEpochs);
    
    fprintf('\n=== CONFIGURAÇÃO CORRIGIDA ===\n');
    fprintf('Execute novamente: executar_comparacao\n');
end
