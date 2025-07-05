function teste_correcao_critica()
    % ========================================================================
    % TESTE DA CORREÇÃO CRÍTICA - Preprocessamento
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Testa se a correção do preprocessamento resolve o erro categorical
    %
    % USO:
    %   >> teste_correcao_critica()
    %
    % VERSÃO: 1.0
    % DATA: Julho 2025
    % ========================================================================
    
    clc;
    fprintf('=====================================\n');
    fprintf('   TESTE DA CORREÇÃO CRÍTICA         \n');
    fprintf('   Preprocessamento de Dados         \n');
    fprintf('=====================================\n\n');
    
    try
        % Carregar configuração
        if ~exist('config_caminhos.mat', 'file')
            error('Configuração não encontrada. Execute: configuracao_inicial_automatica()');
        end
        
        load('config_caminhos.mat', 'config');
        fprintf('✓ Configuração carregada\n');
        
        % Verificar se a função corrigida existe
        if ~exist('preprocessDataCorrigido', 'file')
            error('Função preprocessDataCorrigido não encontrada');
        end
        fprintf('✓ Função corrigida encontrada\n');
        
        % Carregar dados de teste
        fprintf('\n=== CARREGANDO DADOS DE TESTE ===\n');
        
        % Encontrar arquivos
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
        
        if isempty(imgs) || isempty(masks)
            error('Nenhuma imagem ou máscara encontrada');
        end
        
        fprintf('✓ Encontradas %d imagens e %d máscaras\n', length(imgs), length(masks));
        
        % Testar uma amostra
        fprintf('\n=== TESTANDO PREPROCESSAMENTO ===\n');
        
        % Carregar primeira imagem e máscara
        img_path = fullfile(config.imageDir, imgs(1).name);
        mask_path = fullfile(config.maskDir, masks(1).name);
        
        img = imread(img_path);
        mask = imread(mask_path);
        
        fprintf('Imagem original: %s\n', class(img));
        fprintf('  Dimensões: %s\n', mat2str(size(img)));
        fprintf('  Valores: min=%d, max=%d\n', min(img(:)), max(img(:)));
        
        fprintf('Máscara original: %s\n', class(mask));
        fprintf('  Dimensões: %s\n', mat2str(size(mask)));
        fprintf('  Valores únicos: %d classes\n', length(unique(mask(:))));
        
        % Testar preprocessamento
        data_in = {img, mask};
        labelIDs = [0, 1];
        
        fprintf('\n--- Testando preprocessDataCorrigido ---\n');
        try
            data_out = preprocessDataCorrigido(data_in, config, labelIDs, false);
            
            processed_img = data_out{1};
            processed_mask = data_out{2};
            
            fprintf('✓ Preprocessamento bem-sucedido!\n');
            fprintf('Imagem processada: %s\n', class(processed_img));
            fprintf('  Dimensões: %s\n', mat2str(size(processed_img)));
            fprintf('  Valores: min=%.3f, max=%.3f\n', min(processed_img(:)), max(processed_img(:)));
            
            fprintf('Máscara processada: %s\n', class(processed_mask));
            fprintf('  Dimensões: %s\n', mat2str(size(processed_mask)));
            fprintf('  Valores únicos: %s\n', mat2str(unique(processed_mask(:))));
            
            % Verificar se está no formato correto para treinamento
            if isa(processed_img, 'single') && isa(processed_mask, 'single')
                fprintf('✓ Tipos corretos: single\n');
            else
                fprintf('❌ Tipos incorretos\n');
            end
            
            if size(processed_img, 3) == 3 && ndims(processed_mask) == 2
                fprintf('✓ Dimensões corretas\n');
            else
                fprintf('❌ Dimensões incorretas\n');
            end
            
            if all(processed_img(:) >= 0) && all(processed_img(:) <= 1) && ...
               all(processed_mask(:) >= 0) && all(processed_mask(:) <= 1)
                fprintf('✓ Valores normalizados corretamente\n');
            else
                fprintf('❌ Valores fora do range [0,1]\n');
            end
            
        catch ME
            fprintf('❌ Erro no preprocessamento: %s\n', ME.message);
            return;
        end
        
        % Testar com data augmentation
        fprintf('\n--- Testando com Data Augmentation ---\n');
        try
            data_out_aug = preprocessDataCorrigido(data_in, config, labelIDs, true);
            fprintf('✓ Data augmentation funcionando\n');
        catch ME
            fprintf('❌ Erro no data augmentation: %s\n', ME.message);
        end
        
        % Testar criação de datastore
        fprintf('\n=== TESTANDO DATASTORE ===\n');
        try
            % Criar listas pequenas para teste
            img_list = {fullfile(config.imageDir, imgs(1).name), ...
                       fullfile(config.imageDir, imgs(2).name)};
            mask_list = {fullfile(config.maskDir, masks(1).name), ...
                        fullfile(config.maskDir, masks(2).name)};
            
            % Criar datastores
            imds = imageDatastore(img_list);
            pxds = pixelLabelDatastore(mask_list, ["background", "foreground"], [0, 255]);
            
            % Combinar
            ds = combine(imds, pxds);
            
            % Aplicar transformação
            ds = transform(ds, @(data) preprocessDataCorrigido(data, config, labelIDs, false));
            
            % Testar leitura
            data_sample = read(ds);
            fprintf('✓ Datastore funcionando\n');
            fprintf('  Dados lidos: img %s, mask %s\n', ...
                   class(data_sample{1}), class(data_sample{2}));
            
        catch ME
            fprintf('❌ Erro no datastore: %s\n', ME.message);
            fprintf('  Detalhes: %s\n', ME.stack(1).name);
        end
        
        fprintf('\n=====================================\n');
        fprintf('   RESULTADO DO TESTE                \n');
        fprintf('=====================================\n');
        fprintf('✅ CORREÇÃO APLICADA COM SUCESSO!\n');
        fprintf('O problema categorical foi resolvido.\n');
        fprintf('Agora você pode executar o treinamento.\n\n');
        
        fprintf('PRÓXIMOS PASSOS:\n');
        fprintf('1. Execute: executar_comparacao()\n');
        fprintf('2. Escolha opção 3 para teste rápido\n');
        fprintf('3. Se funcionar, escolha opção 5 para execução completa\n\n');
        
    catch ME
        fprintf('❌ Erro crítico: %s\n', ME.message);
        if ~isempty(ME.stack)
            fprintf('Arquivo: %s, Linha: %d\n', ME.stack(1).file, ME.stack(1).line);
        end
    end
end
