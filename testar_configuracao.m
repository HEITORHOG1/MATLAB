function testar_configuracao()
    % ========================================================================
    % TESTE DE CONFIGURAÇÃO - Projeto U-Net vs Attention U-Net
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Script para testar rapidamente se a configuração de caminhos
    %   está funcionando corretamente.
    %
    % USO:
    %   >> testar_configuracao()
    %
    % VERSÃO: 1.0
    % DATA: Julho 2025
    % ========================================================================
    
    clc;
    fprintf('=====================================\n');
    fprintf('   TESTE DE CONFIGURAÇÃO             \n');
    fprintf('   Projeto U-Net vs Attention U-Net  \n');
    fprintf('=====================================\n\n');
    
    try
        % Verificar se o arquivo de configuração existe
        if exist('config_caminhos.mat', 'file')
            fprintf('✓ Arquivo de configuração encontrado\n');
            
            % Carregar configuração
            load('config_caminhos.mat', 'config');
            fprintf('✓ Configuração carregada com sucesso\n');
            
            % Testar caminhos
            fprintf('\n=== TESTANDO CAMINHOS ===\n');
            
            % Testar diretório de imagens
            if exist(config.imageDir, 'dir')
                fprintf('✓ Diretório de imagens existe: %s\n', config.imageDir);
                
                % Contar arquivos de imagem usando busca individual por formato
                formatos = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff'};
                imgs = [];
                for i = 1:length(formatos)
                    temp = dir(fullfile(config.imageDir, formatos{i}));
                    imgs = [imgs; temp];
                end
                fprintf('✓ Encontradas %d imagens\n', length(imgs));
                
                if length(imgs) > 0
                    fprintf('  Exemplos: %s, %s...\n', imgs(1).name, ...
                           imgs(min(2, length(imgs))).name);
                end
            else
                fprintf('❌ Diretório de imagens não existe: %s\n', config.imageDir);
            end
            
            % Testar diretório de máscaras
            if exist(config.maskDir, 'dir')
                fprintf('✓ Diretório de máscaras existe: %s\n', config.maskDir);
                
                % Contar arquivos de máscara usando busca individual por formato
                masks = [];
                for i = 1:length(formatos)
                    temp = dir(fullfile(config.maskDir, formatos{i}));
                    masks = [masks; temp];
                end
                fprintf('✓ Encontradas %d máscaras\n', length(masks));
                
                if length(masks) > 0
                    fprintf('  Exemplos: %s, %s...\n', masks(1).name, ...
                           masks(min(2, length(masks))).name);
                end
            else
                fprintf('❌ Diretório de máscaras não existe: %s\n', config.maskDir);
            end
            
            % Exibir configurações técnicas
            fprintf('\n=== CONFIGURAÇÕES TÉCNICAS ===\n');
            fprintf('Tamanho de entrada: [%d, %d, %d]\n', config.inputSize);
            fprintf('Número de classes: %d\n', config.numClasses);
            fprintf('Split de validação: %.1f%%\n', config.validationSplit * 100);
            fprintf('Batch size: %d\n', config.miniBatchSize);
            fprintf('Épocas máximas: %d\n', config.maxEpochs);
            
            % Informações do ambiente
            if isfield(config, 'ambiente')
                fprintf('\n=== INFORMAÇÕES DO AMBIENTE ===\n');
                fprintf('Usuário: %s\n', config.ambiente.usuario);
                fprintf('Computador: %s\n', config.ambiente.computador);
                fprintf('Data da configuração: %s\n', config.ambiente.data_config);
            end
            
            % Teste de carregamento de uma imagem
            fprintf('\n=== TESTE DE CARREGAMENTO ===\n');
            testar_carregamento_arquivos(config);
            
            fprintf('\n✅ TESTE CONCLUÍDO COM SUCESSO!\n');
            fprintf('A configuração está funcionando corretamente.\n');
            
        else
            fprintf('❌ Arquivo de configuração não encontrado\n');
            fprintf('Execute primeiro: executar_comparacao()\n');
            fprintf('Ou configure manualmente: config = configurar_caminhos();\n');
        end
        
    catch ME
        fprintf('❌ Erro durante o teste: %s\n', ME.message);
        fprintf('\nPara resolver:\n');
        fprintf('1. Delete o arquivo config_caminhos.mat\n');
        fprintf('2. Execute: executar_comparacao()\n');
        fprintf('3. Reconfigure os caminhos\n');
    end
end

function testar_carregamento_arquivos(config)
    % Testa o carregamento de uma imagem e máscara
    
    try
        % Listar arquivos usando busca individual por formato
        formatos = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff'};
        
        imgs = [];
        for i = 1:length(formatos)
            temp = dir(fullfile(config.imageDir, formatos{i}));
            imgs = [imgs; temp];
        end
        
        masks = [];
        for i = 1:length(formatos)
            temp = dir(fullfile(config.maskDir, formatos{i}));
            masks = [masks; temp];
        end
        
        if ~isempty(imgs) && ~isempty(masks)
            % Tentar carregar primeira imagem
            img_path = fullfile(config.imageDir, imgs(1).name);
            img = imread(img_path);
            fprintf('✓ Imagem carregada: %s [%dx%dx%d]\n', imgs(1).name, size(img));
            
            % Tentar carregar primeira máscara
            mask_path = fullfile(config.maskDir, masks(1).name);
            mask = imread(mask_path);
            fprintf('✓ Máscara carregada: %s [%dx%dx%d]\n', masks(1).name, size(mask));
            
            % Verificar compatibilidade de tamanhos
            if size(img, 1) == size(mask, 1) && size(img, 2) == size(mask, 2)
                fprintf('✓ Tamanhos compatíveis: %dx%d\n', size(img, 1), size(img, 2));
            else
                fprintf('⚠️  Tamanhos diferentes - Imagem: %dx%d, Máscara: %dx%d\n', ...
                       size(img, 1), size(img, 2), size(mask, 1), size(mask, 2));
                fprintf('   (Isso será corrigido automaticamente no pré-processamento)\n');
            end
            
        else
            fprintf('⚠️  Não foi possível testar carregamento (arquivos insuficientes)\n');
        end
        
    catch ME
        fprintf('⚠️  Erro no teste de carregamento: %s\n', ME.message);
    end
end
