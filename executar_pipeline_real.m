function executar_pipeline_real()
    % Executa o pipeline real com configuração correta
    
    fprintf('=== EXECUTANDO PIPELINE REAL ===\n');
    
    % Adicionar paths necessários
    addpath('legacy');
    addpath('src/utils');
    
    % Criar configuração correta
    config = struct();
    
    % Configurações básicas
    config.maxEpochs = 5;
    config.miniBatchSize = 4;
    config.inputSize = [256, 256, 3];
    config.numClasses = 2;
    config.learningRate = 0.001;
    config.validationFrequency = 10;
    
    % Paths que o script espera
    config.imageDir = 'C:\Users\heito\Pictures\imagens matlab\original';
    config.maskDir = 'C:\Users\heito\Pictures\imagens matlab\masks';
    
    % Verificar se os diretórios existem
    if ~exist(config.imageDir, 'dir')
        fprintf('⚠ Diretório de imagens não encontrado: %s\n', config.imageDir);
        fprintf('Criando dados sintéticos...\n');
        criar_dados_sinteticos();
        config.imageDir = fullfile(pwd, 'data', 'images');
        config.maskDir = fullfile(pwd, 'data', 'masks');
    end
    
    if ~exist(config.maskDir, 'dir')
        fprintf('⚠ Diretório de máscaras não encontrado: %s\n', config.maskDir);
        fprintf('Criando dados sintéticos...\n');
        criar_dados_sinteticos();
        config.imageDir = fullfile(pwd, 'data', 'images');
        config.maskDir = fullfile(pwd, 'data', 'masks');
    end
    
    fprintf('Configuração:\n');
    fprintf('  Imagens: %s\n', config.imageDir);
    fprintf('  Máscaras: %s\n', config.maskDir);
    fprintf('  Épocas: %d\n', config.maxEpochs);
    fprintf('  Batch Size: %d\n', config.miniBatchSize);
    
    try
        fprintf('\n🚀 Iniciando comparação U-Net vs Attention U-Net...\n');
        comparacao_unet_attention_final(config);
        fprintf('\n✅ Pipeline executado com sucesso!\n');
        
    catch ME
        fprintf('\n❌ Erro durante execução:\n');
        fprintf('  Erro: %s\n', ME.message);
        fprintf('  Identificador: %s\n', ME.identifier);
        
        if ~isempty(ME.stack)
            fprintf('  Stack trace:\n');
            for i = 1:min(3, length(ME.stack))
                fprintf('    %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
            end
        end
        
        % Tentar execução com dados sintéticos
        fprintf('\n🔄 Tentando com dados sintéticos...\n');
        try
            criar_dados_sinteticos();
            config.imageDir = fullfile(pwd, 'data', 'images');
            config.maskDir = fullfile(pwd, 'data', 'masks');
            comparacao_unet_attention_final(config);
            fprintf('\n✅ Pipeline com dados sintéticos executado!\n');
        catch ME2
            fprintf('\n❌ Falha também com dados sintéticos: %s\n', ME2.message);
        end
    end
end

function criar_dados_sinteticos()
    % Cria dados sintéticos para teste
    
    fprintf('📁 Criando dados sintéticos...\n');
    
    % Criar diretórios
    img_dir = fullfile(pwd, 'data', 'images');
    mask_dir = fullfile(pwd, 'data', 'masks');
    
    if ~exist(img_dir, 'dir')
        mkdir(img_dir);
    end
    
    if ~exist(mask_dir, 'dir')
        mkdir(mask_dir);
    end
    
    % Gerar algumas imagens e máscaras sintéticas
    num_samples = 10;
    
    for i = 1:num_samples
        % Imagem sintética RGB
        img = uint8(rand(256, 256, 3) * 255);
        
        % Máscara sintética (criar padrão circular)
        [X, Y] = meshgrid(1:256, 1:256);
        center_x = 128 + randn() * 30;
        center_y = 128 + randn() * 30;
        radius = 40 + randn() * 10;
        
        mask_logical = ((X - center_x).^2 + (Y - center_y).^2) < radius^2;
        
        % Salvar arquivos
        img_file = fullfile(img_dir, sprintf('image_%03d.png', i));
        mask_file = fullfile(mask_dir, sprintf('mask_%03d.png', i));
        
        imwrite(img, img_file);
        imwrite(uint8(mask_logical) * 255, mask_file);
    end
    
    fprintf('✅ %d amostras sintéticas criadas\n', num_samples);
    fprintf('  Imagens: %s\n', img_dir);
    fprintf('  Máscaras: %s\n', mask_dir);
end