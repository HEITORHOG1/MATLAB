function config = configurar_caminhos()
    % ========================================================================
    % CONFIGURACAO DE CAMINHOS - PROJETO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 1.2 Final
    %
    % DESCRIÇÃO:
    %   Função para configurar os caminhos das imagens e máscaras de forma
    %   portável e reutilizável em diferentes computadores.
    %
    % RETORNA:
    %   config - estrutura com todas as configurações do projeto
    %
    % USO:
    %   >> config = configurar_caminhos();
    %   >> save('config_caminhos.mat', 'config');
    %
    % VERSÃO: 1.0
    % DATA: Julho 2025
    % ========================================================================
    
    fprintf('=====================================\n');
    fprintf('   CONFIGURACAO DE CAMINHOS          \n');
    fprintf('   Projeto U-Net vs Attention U-Net  \n');
    fprintf('=====================================\n\n');
    
    config = struct();
    
    % === CONFIGURAÇÕES PADRÃO PARA ESTE COMPUTADOR ===
    % Defina aqui os caminhos padrão para o seu computador atual
    caminhos_padrao = struct();
    caminhos_padrao.imageDir = 'C:\Users\heito\Pictures\imagens matlab\original';
    caminhos_padrao.maskDir = 'C:\Users\heito\Pictures\imagens matlab\masks';
    
    % === DETECÇÃO AUTOMÁTICA DE AMBIENTE ===
    usuario_atual = getenv('USERNAME');
    computador_atual = getenv('COMPUTERNAME');
    
    fprintf('Usuário atual: %s\n', usuario_atual);
    fprintf('Computador atual: %s\n\n', computador_atual);
    
    % === VERIFICAÇÃO DE CAMINHOS EXISTENTES ===
    caminhos_encontrados = verificar_caminhos_existentes(caminhos_padrao);
    
    if caminhos_encontrados
        fprintf('✓ Caminhos padrão encontrados!\n');
        fprintf('  Imagens: %s\n', caminhos_padrao.imageDir);
        fprintf('  Máscaras: %s\n\n', caminhos_padrao.maskDir);
        
        usar_padrao = input('Usar estes caminhos? (s/n) [s]: ', 's');
        if isempty(usar_padrao) || lower(usar_padrao) == 's'
            config.imageDir = caminhos_padrao.imageDir;
            config.maskDir = caminhos_padrao.maskDir;
        else
            config = configurar_caminhos_manual();
        end
    else
        fprintf('⚠️  Caminhos padrão não encontrados.\n');
        fprintf('   Isso é normal se você estiver em um computador diferente.\n\n');
        config = configurar_caminhos_manual();
    end
    
    % === CONFIGURAÇÕES TÉCNICAS ===
    config.inputSize = [256, 256, 3];
    config.numClasses = 2;
    config.validationSplit = 0.2;
    config.miniBatchSize = 8;
    config.maxEpochs = 20;
    config.quickTest = struct('numSamples', 50, 'maxEpochs', 5);
    
    % === INFORMAÇÕES DO AMBIENTE ===
    config.ambiente = struct();
    config.ambiente.usuario = usuario_atual;
    config.ambiente.computador = computador_atual;
    config.ambiente.data_config = datestr(now);
    config.ambiente.matlab_version = version;
    
    % === VALIDAÇÃO FINAL ===
    if validar_configuracao(config)
        fprintf('\n✓ Configuração válida!\n');
        
        % Salvar automaticamente
        salvar_config = input('Salvar configuração? (s/n) [s]: ', 's');
        if isempty(salvar_config) || lower(salvar_config) == 's'
            save('config_caminhos.mat', 'config');
            fprintf('✓ Configuração salva em: config_caminhos.mat\n');
            
            % Criar backup com timestamp
            timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
            backup_name = sprintf('config_backup_%s.mat', timestamp);
            save(backup_name, 'config');
            fprintf('✓ Backup criado: %s\n', backup_name);
        end
        
        exibir_resumo_configuracao(config);
    else
        error('❌ Configuração inválida. Verifique os caminhos.');
    end
end

function config = configurar_caminhos_manual()
    % Configuração manual de caminhos
    
    fprintf('=== CONFIGURAÇÃO MANUAL ===\n');
    
    config = struct();
    
    while true
        % Solicitar caminho das imagens
        fprintf('\n1. Caminho das IMAGENS ORIGINAIS:\n');
        fprintf('   Exemplo: C:\\Users\\seu_usuario\\Pictures\\imagens matlab\\original\n');
        imageDir = input('   Caminho: ', 's');
        
        if exist(imageDir, 'dir')
            config.imageDir = imageDir;
            fprintf('   ✓ Diretório de imagens encontrado!\n');
            break;
        else
            fprintf('   ❌ Diretório não encontrado. Tente novamente.\n');
            
            % Oferecer opção de navegar
            navegar = input('   Deseja navegar para selecionar? (s/n): ', 's');
            if lower(navegar) == 's'
                try
                    imageDir = uigetdir('', 'Selecione o diretório das imagens');
                    if imageDir ~= 0
                        config.imageDir = imageDir;
                        fprintf('   ✓ Diretório selecionado: %s\n', imageDir);
                        break;
                    end
                catch
                    fprintf('   Erro ao abrir navegador de arquivos.\n');
                end
            end
        end
    end
    
    while true
        % Solicitar caminho das máscaras
        fprintf('\n2. Caminho das MÁSCARAS:\n');
        fprintf('   Exemplo: C:\\Users\\seu_usuario\\Pictures\\imagens matlab\\masks\n');
        maskDir = input('   Caminho: ', 's');
        
        if exist(maskDir, 'dir')
            config.maskDir = maskDir;
            fprintf('   ✓ Diretório de máscaras encontrado!\n');
            break;
        else
            fprintf('   ❌ Diretório não encontrado. Tente novamente.\n');
            
            % Oferecer opção de navegar
            navegar = input('   Deseja navegar para selecionar? (s/n): ', 's');
            if lower(navegar) == 's'
                try
                    maskDir = uigetdir('', 'Selecione o diretório das máscaras');
                    if maskDir ~= 0
                        config.maskDir = maskDir;
                        fprintf('   ✓ Diretório selecionado: %s\n', maskDir);
                        break;
                    end
                catch
                    fprintf('   Erro ao abrir navegador de arquivos.\n');
                end
            end
        end
    end
end

function encontrados = verificar_caminhos_existentes(caminhos)
    % Verifica se os caminhos padrão existem
    
    encontrados = false;
    
    if exist(caminhos.imageDir, 'dir') && exist(caminhos.maskDir, 'dir')
        % Verificar se há arquivos nos diretórios usando busca individual por formato
        formatos = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff'};
        
        % Verificar imagens
        imgs = [];
        for i = 1:length(formatos)
            temp = dir(fullfile(caminhos.imageDir, formatos{i}));
            imgs = [imgs; temp];
        end
        
        % Verificar máscaras
        masks = [];
        for i = 1:length(formatos)
            temp = dir(fullfile(caminhos.maskDir, formatos{i}));
            masks = [masks; temp];
        end
        
        if ~isempty(imgs) && ~isempty(masks)
            encontrados = true;
        end
    end
end

function valido = validar_configuracao(config)
    % Valida a configuração completa
    
    valido = false;
    
    try
        % Verificar campos obrigatórios
        campos_obrigatorios = {'imageDir', 'maskDir', 'inputSize', 'numClasses'};
        for i = 1:length(campos_obrigatorios)
            if ~isfield(config, campos_obrigatorios{i})
                fprintf('❌ Campo obrigatório ausente: %s\n', campos_obrigatorios{i});
                return;
            end
        end
        
        % Verificar diretórios
        if ~exist(config.imageDir, 'dir')
            fprintf('❌ Diretório de imagens não existe: %s\n', config.imageDir);
            return;
        end
        
        if ~exist(config.maskDir, 'dir')
            fprintf('❌ Diretório de máscaras não existe: %s\n', config.maskDir);
            return;
        end
        
        % Verificar se há arquivos usando busca individual por formato
        formatos = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff'};
        
        % Verificar imagens
        imgs = [];
        for i = 1:length(formatos)
            temp = dir(fullfile(config.imageDir, formatos{i}));
            imgs = [imgs; temp];
        end
        
        % Verificar máscaras
        masks = [];
        for i = 1:length(formatos)
            temp = dir(fullfile(config.maskDir, formatos{i}));
            masks = [masks; temp];
        end
        
        if isempty(imgs)
            fprintf('❌ Nenhuma imagem encontrada em: %s\n', config.imageDir);
            fprintf('   📁 Diretório existe, mas está vazio ou não contém arquivos de imagem.\n');
            fprintf('   🔍 Formatos suportados: jpg, jpeg, png, bmp, tif, tiff\n');
            
            % Listar arquivos existentes para debug
            todos_arquivos = dir(config.imageDir);
            arquivos_reais = todos_arquivos(~[todos_arquivos.isdir]);
            if ~isempty(arquivos_reais)
                fprintf('   📄 Arquivos encontrados no diretório:\n');
                for i = 1:min(5, length(arquivos_reais))
                    fprintf('      - %s\n', arquivos_reais(i).name);
                end
                if length(arquivos_reais) > 5
                    fprintf('      ... e mais %d arquivos\n', length(arquivos_reais) - 5);
                end
            end
            
            % Perguntar se deseja continuar mesmo assim
            continuar = input('   Continuar mesmo sem imagens? (s/n) [n]: ', 's');
            if lower(continuar) ~= 's'
                return;
            else
                fprintf('   ⚠️  Continuando sem validação de imagens...\n');
            end
        end
        
        if isempty(masks)
            fprintf('❌ Nenhuma máscara encontrada em: %s\n', config.maskDir);
            fprintf('   📁 Diretório existe, mas está vazio ou não contém arquivos de máscara.\n');
            fprintf('   🔍 Formatos suportados: jpg, jpeg, png, bmp, tif, tiff\n');
            
            % Listar arquivos existentes para debug
            todos_arquivos = dir(config.maskDir);
            arquivos_reais = todos_arquivos(~[todos_arquivos.isdir]);
            if ~isempty(arquivos_reais)
                fprintf('   📄 Arquivos encontrados no diretório:\n');
                for i = 1:min(5, length(arquivos_reais))
                    fprintf('      - %s\n', arquivos_reais(i).name);
                end
                if length(arquivos_reais) > 5
                    fprintf('      ... e mais %d arquivos\n', length(arquivos_reais) - 5);
                end
            end
            
            % Perguntar se deseja continuar mesmo assim
            continuar = input('   Continuar mesmo sem máscaras? (s/n) [n]: ', 's');
            if lower(continuar) ~= 's'
                return;
            else
                fprintf('   ⚠️  Continuando sem validação de máscaras...\n');
            end
        end
        
        if ~isempty(imgs) && ~isempty(masks)
            fprintf('✓ Encontradas %d imagens e %d máscaras\n', length(imgs), length(masks));
        elseif ~isempty(imgs)
            fprintf('⚠️  Encontradas %d imagens (sem máscaras)\n', length(imgs));
        elseif ~isempty(masks)
            fprintf('⚠️  Encontradas %d máscaras (sem imagens)\n', length(masks));
        else
            fprintf('⚠️  Configuração criada sem arquivos (pode adicionar depois)\n');
        end
        
        valido = true;
        
    catch ME
        fprintf('❌ Erro na validação: %s\n', ME.message);
    end
end

function exibir_resumo_configuracao(config)
    % Exibe resumo da configuração
    
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
    fprintf('Ambiente: %s@%s\n', config.ambiente.usuario, config.ambiente.computador);
    fprintf('Data: %s\n', config.ambiente.data_config);
    fprintf('=====================================\n\n');
end
