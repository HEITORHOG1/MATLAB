function config = configuracao_inicial_automatica()
    % ========================================================================
    % CONFIGURAÇÃO INICIAL AUTOMÁTICA
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Cria configuração inicial com os caminhos especificados pelo usuário.
    %   Esta função é executada automaticamente sem interação.
    %
    % CAMINHOS CONFIGURADOS:
    %   - Imagens: C:\Users\heito\Pictures\imagens matlab\original
    %   - Máscaras: C:\Users\heito\Pictures\imagens matlab\masks
    %
    % VERSÃO: 1.0
    % DATA: Julho 2025
    % ========================================================================
    
    fprintf('=====================================\n');
    fprintf('   CONFIGURACAO AUTOMATICA           \n');
    fprintf('   Projeto U-Net vs Attention U-Net  \n');
    fprintf('=====================================\n\n');
    
    % Configurar caminhos especificados pelo usuário
    config = struct();
    config.imageDir = 'C:\Users\heito\Pictures\imagens matlab\original';
    config.maskDir = 'C:\Users\heito\Pictures\imagens matlab\masks';
    
    fprintf('Configurando caminhos:\n');
    fprintf('  Imagens: %s\n', config.imageDir);
    fprintf('  Máscaras: %s\n', config.maskDir);
    
    % Verificar se os diretórios existem e contêm arquivos
    if ~exist(config.imageDir, 'dir')
        fprintf('⚠️  AVISO: Diretório de imagens não encontrado: %s\n', config.imageDir);
        fprintf('   Por favor, verifique se o caminho está correto.\n');
    else
        fprintf('✓ Diretório de imagens encontrado!\n');
        
        % Verificar arquivos usando busca individual por formato
        formatos = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff'};
        imgs = [];
        for i = 1:length(formatos)
            temp = dir(fullfile(config.imageDir, formatos{i}));
            imgs = [imgs; temp];
        end
        fprintf('✓ Encontradas %d imagens\n', length(imgs));
    end
    
    if ~exist(config.maskDir, 'dir')
        fprintf('⚠️  AVISO: Diretório de máscaras não encontrado: %s\n', config.maskDir);
        fprintf('   Por favor, verifique se o caminho está correto.\n');
    else
        fprintf('✓ Diretório de máscaras encontrado!\n');
        
        % Verificar arquivos usando busca individual por formato
        masks = [];
        for i = 1:length(formatos)
            temp = dir(fullfile(config.maskDir, formatos{i}));
            masks = [masks; temp];
        end
        fprintf('✓ Encontradas %d máscaras\n', length(masks));
    end
    
    % Configurações técnicas
    config.inputSize = [256, 256, 3];
    config.numClasses = 2;
    config.validationSplit = 0.2;
    config.miniBatchSize = 8;
    config.maxEpochs = 20;
    config.quickTest = struct('numSamples', 50, 'maxEpochs', 5);
    
    % Informações do ambiente
    config.ambiente = struct();
    config.ambiente.usuario = getenv('USERNAME');
    config.ambiente.computador = getenv('COMPUTERNAME');
    config.ambiente.data_config = datestr(now);
    config.ambiente.matlab_version = version;
    
    % Salvar configuração
    save('config_caminhos.mat', 'config');
    fprintf('\n✓ Configuração salva em: config_caminhos.mat\n');
    
    % Criar backup
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    backup_name = sprintf('config_backup_%s.mat', timestamp);
    save(backup_name, 'config');
    fprintf('✓ Backup criado: %s\n', backup_name);
    
    % Exibir resumo
    fprintf('\n=====================================\n');
    fprintf('   RESUMO DA CONFIGURAÇÃO            \n');
    fprintf('=====================================\n');
    fprintf('Imagens: %s\n', config.imageDir);
    fprintf('Máscaras: %s\n', config.maskDir);
    fprintf('Tamanho de entrada: [%d, %d, %d]\n', config.inputSize);
    fprintf('Número de classes: %d\n', config.numClasses);
    fprintf('Split de validação: %.1f%%\n', config.validationSplit * 100);
    fprintf('Batch size: %d\n', config.miniBatchSize);
    fprintf('Épocas máximas: %d\n', config.maxEpochs);
    fprintf('=====================================\n');
    fprintf('Usuário: %s\n', config.ambiente.usuario);
    fprintf('Computador: %s\n', config.ambiente.computador);
    fprintf('Data: %s\n', config.ambiente.data_config);
    fprintf('=====================================\n\n');
    
    fprintf('✅ CONFIGURAÇÃO CONCLUÍDA!\n');
    fprintf('Agora você pode executar: executar_comparacao()\n\n');
end
