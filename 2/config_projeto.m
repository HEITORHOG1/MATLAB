function config = config_projeto()
    % CONFIGURAÇÃO PORTÁVEL PARA PROJETO U-NET vs ATTENTION U-NET
    % 
    % Esta função centraliza todas as configurações do projeto,
    % tornando-o portável e fácil de modificar.
    
    fprintf('\n=== CONFIGURAÇÃO DO PROJETO ===\n');
    
    % Inicializar estrutura de configuração
    config = struct();
    
    %% CONFIGURAÇÃO DE CAMINHOS
    fprintf('Configurando caminhos dos dados...\n');
    
    % Verificar se existe arquivo de configuração salvo
    configFile = 'config_caminhos.mat';
    if exist(configFile, 'file')
        resp = input('Usar configuração salva? (s/n): ', 's');
        if lower(resp) == 's'
            load(configFile, 'savedConfig');
            config.imageDir = savedConfig.imageDir;
            config.maskDir = savedConfig.maskDir;
            fprintf('Configuração carregada:\n');
            fprintf('  Imagens: %s\n', config.imageDir);
            fprintf('  Máscaras: %s\n', config.maskDir);
        else
            [config.imageDir, config.maskDir] = configurar_caminhos_interativo();
            savedConfig.imageDir = config.imageDir;
            savedConfig.maskDir = config.maskDir;
            save(configFile, 'savedConfig');
        end
    else
        [config.imageDir, config.maskDir] = configurar_caminhos_interativo();
        savedConfig.imageDir = config.imageDir;
        savedConfig.maskDir = config.maskDir;
        save(configFile, 'savedConfig');
    end
    
    %% PARÂMETROS DE TREINAMENTO
    fprintf('\nConfigurando parâmetros de treinamento...\n');
    
    % Parâmetros básicos
    config.inputSize = [256, 256, 3];
    config.numClasses = 2;
    
    % Parâmetros de treinamento
    config.numEpochs = 20;
    config.miniBatchSize = 8;
    config.initialLearningRate = 1e-3;
    config.initialLearningRateAttention = 5e-4;  % Menor para Attention U-Net
    
    % Parâmetros de validação
    config.validationSplit = 0.2;  % 20% para validação
    config.validationFrequency = 10;
    config.validationPatience = 10;  % Early stopping
    
    % Parâmetros de data augmentation
    config.useDataAugmentation = true;
    config.augmentationProbability = 0.5;
    config.rotationRange = 15;  % ±15 graus
    config.brightnessRange = 0.2;  % ±20%
    
    % Parâmetros para teste rápido
    config.quickTest = struct();
    config.quickTest.numEpochs = 3;
    config.quickTest.miniBatchSize = 4;
    config.quickTest.numSamples = 50;
    config.quickTest.inputSize = [128, 128, 3];
    
    %% CONFIGURAÇÕES DE SAÍDA
    config.outputDir = './resultados';
    config.modelDir = './modelos';
    config.plotDir = './graficos';
    
    % Criar diretórios se não existirem
    if ~exist(config.outputDir, 'dir'), mkdir(config.outputDir); end
    if ~exist(config.modelDir, 'dir'), mkdir(config.modelDir); end
    if ~exist(config.plotDir, 'dir'), mkdir(config.plotDir); end
    
    %% CONFIGURAÇÕES AVANÇADAS
    config.useGPU = true;  % Tentar usar GPU se disponível
    config.verbose = true;
    config.saveCheckpoints = true;
    config.generateReport = true;
    
    % Métricas a calcular
    config.metrics = {'accuracy', 'iou', 'dice', 'precision', 'recall', 'f1'};
    
    fprintf('Configuração concluída!\n');
    fprintf('Resumo:\n');
    fprintf('  Tamanho de entrada: %dx%dx%d\n', config.inputSize);
    fprintf('  Épocas: %d\n', config.numEpochs);
    fprintf('  Batch size: %d\n', config.miniBatchSize);
    fprintf('  Learning rate U-Net: %.1e\n', config.initialLearningRate);
    fprintf('  Learning rate Attention: %.1e\n', config.initialLearningRateAttention);
    fprintf('  Data augmentation: %s\n', config.useDataAugmentation ? 'Sim' : 'Não');
    fprintf('\n');
end

function [imageDir, maskDir] = configurar_caminhos_interativo()
    % Configuração interativa dos caminhos
    
    fprintf('\nConfiguração de caminhos dos dados:\n');
    fprintf('Você pode:\n');
    fprintf('1. Digitar os caminhos manualmente\n');
    fprintf('2. Usar seletor de pasta (se disponível)\n');
    
    opcao = input('Escolha (1 ou 2): ');
    
    if opcao == 2
        try
            fprintf('Selecione o diretório das imagens...\n');
            imageDir = uigetdir('', 'Selecione o diretório das imagens');
            if imageDir == 0
                error('Seleção cancelada');
            end
            
            fprintf('Selecione o diretório das máscaras...\n');
            maskDir = uigetdir('', 'Selecione o diretório das máscaras');
            if maskDir == 0
                error('Seleção cancelada');
            end
        catch
            fprintf('Seletor não disponível. Usando entrada manual.\n');
            opcao = 1;
        end
    end
    
    if opcao == 1
        % Entrada manual
        while true
            imageDir = input('Caminho do diretório das imagens: ', 's');
            if exist(imageDir, 'dir')
                break;
            else
                fprintf('ERRO: Diretório não encontrado. Tente novamente.\n');
            end
        end
        
        while true
            maskDir = input('Caminho do diretório das máscaras: ', 's');
            if exist(maskDir, 'dir')
                break;
            else
                fprintf('ERRO: Diretório não encontrado. Tente novamente.\n');
            end
        end
    end
    
    % Verificar arquivos
    imgFiles = [dir(fullfile(imageDir, '*.png')); dir(fullfile(imageDir, '*.jpg')); dir(fullfile(imageDir, '*.jpeg'))];
    maskFiles = [dir(fullfile(maskDir, '*.png')); dir(fullfile(maskDir, '*.jpg')); dir(fullfile(maskDir, '*.jpeg'))];
    
    fprintf('\nVerificação dos dados:\n');
    fprintf('  Imagens encontradas: %d\n', length(imgFiles));
    fprintf('  Máscaras encontradas: %d\n', length(maskFiles));
    
    if isempty(imgFiles)
        error('Nenhuma imagem encontrada no diretório especificado!');
    end
    if isempty(maskFiles)
        error('Nenhuma máscara encontrada no diretório especificado!');
    end
    
    if length(imgFiles) ~= length(maskFiles)
        warning('Número de imagens (%d) diferente do número de máscaras (%d)', ...
                length(imgFiles), length(maskFiles));
    end
    
    fprintf('Caminhos configurados com sucesso!\n');
end

