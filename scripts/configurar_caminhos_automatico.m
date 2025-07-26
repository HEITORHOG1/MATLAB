function config = configurar_caminhos_automatico()
    % ========================================================================
    % CONFIGURACAO DE CAMINHOS AUTOMATICA - PROJETO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % VERSÃO AUTOMÁTICA que não requer entrada do usuário para uso em scripts
    % automatizados ou modo batch do MATLAB.
    %
    % RETORNA:
    %   config - estrutura com todas as configurações do projeto
    %
    % USO:
    %   >> config = configurar_caminhos_automatico();
    %
    % ========================================================================
    
    fprintf('=====================================\n');
    fprintf('   CONFIGURACAO AUTOMATICA           \n');
    fprintf('   Projeto U-Net vs Attention U-Net  \n');
    fprintf('=====================================\n\n');
    
    % === INFORMAÇÕES DO SISTEMA ===
    usuario_atual = getenv('USERNAME');
    computador_atual = getenv('COMPUTERNAME');
    
    fprintf('Usuário atual: %s\n', usuario_atual);
    fprintf('Computador atual: %s\n\n', computador_atual);
    
    % === DEFINIÇÃO DE CAMINHOS PADRÃO ===
    caminhos_padrao = definir_caminhos_padrao();
    
    % === VERIFICAÇÃO DE CAMINHOS EXISTENTES ===
    caminhos_encontrados = verificar_caminhos_existentes(caminhos_padrao);
    
    if caminhos_encontrados
        fprintf('✓ Caminhos padrão encontrados e serão usados automaticamente!\n');
        fprintf('  Imagens: %s\n', caminhos_padrao.imageDir);
        fprintf('  Máscaras: %s\n\n', caminhos_padrao.maskDir);
        
        config.imageDir = caminhos_padrao.imageDir;
        config.maskDir = caminhos_padrao.maskDir;
    else
        fprintf('⚠️  Caminhos padrão não encontrados.\n');
        fprintf('   Usando caminhos relativos como fallback...\n\n');
        
        % Fallback para caminhos relativos
        config.imageDir = fullfile(pwd, 'img', 'original');
        config.maskDir = fullfile(pwd, 'img', 'masks');
        
        fprintf('  Imagens: %s\n', config.imageDir);
        fprintf('  Máscaras: %s\n\n', config.maskDir);
        
        % Verificar se os caminhos relativos existem
        if ~exist(config.imageDir, 'dir')
            fprintf('⚠️  Diretório de imagens não existe: %s\n', config.imageDir);
        end
        if ~exist(config.maskDir, 'dir')
            fprintf('⚠️  Diretório de máscaras não existe: %s\n', config.maskDir);
        end
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
    config.ambiente.modo_automatico = true;
    
    % === VALIDAÇÃO FINAL ===
    if validar_configuracao(config)
        fprintf('\n✓ Configuração automática válida!\n');
        
        % Salvar automaticamente
        save('config_caminhos.mat', 'config');
        fprintf('✓ Configuração salva em: config_caminhos.mat\n');
        
        % Criar backup com timestamp
        timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
        backup_name = sprintf('config_backup_%s.mat', timestamp);
        save(backup_name, 'config');
        fprintf('✓ Backup criado: %s\n', backup_name);
        
        exibir_resumo_configuracao(config);
    else
        fprintf('❌ Erro na configuração automática!\n');
        error('Falha na validação da configuração automática');
    end
    
    fprintf('\n✅ Configuração automática concluída com sucesso!\n\n');
end

% ========================================================================
% FUNÇÕES AUXILIARES (copiadas da função original)
% ========================================================================

function caminhos = definir_caminhos_padrao()
    % Definir caminhos padrão baseados no usuário e estrutura conhecida
    usuario = getenv('USERNAME');
    
    % Caminhos padrão conhecidos
    caminhos_possiveis = {
        fullfile('C:', 'Users', usuario, 'Pictures', 'imagens matlab', 'original');
        fullfile('C:', 'Users', usuario, 'Documents', 'MATLAB', 'img', 'original');
        fullfile('C:', 'Users', usuario, 'Desktop', 'img', 'original');
        fullfile(pwd, 'img', 'original');
    };
    
    caminhos_mascaras_possiveis = {
        fullfile('C:', 'Users', usuario, 'Pictures', 'imagens matlab', 'masks');
        fullfile('C:', 'Users', usuario, 'Documents', 'MATLAB', 'img', 'masks');
        fullfile('C:', 'Users', usuario, 'Desktop', 'img', 'masks');
        fullfile(pwd, 'img', 'masks');
    };
    
    % Buscar o primeiro caminho que existe
    caminhos.imageDir = '';
    caminhos.maskDir = '';
    
    for i = 1:length(caminhos_possiveis)
        if exist(caminhos_possiveis{i}, 'dir')
            caminhos.imageDir = caminhos_possiveis{i};
            break;
        end
    end
    
    for i = 1:length(caminhos_mascaras_possiveis)
        if exist(caminhos_mascaras_possiveis{i}, 'dir')
            caminhos.maskDir = caminhos_mascaras_possiveis{i};
            break;
        end
    end
end

function existe = verificar_caminhos_existentes(caminhos)
    % Verificar se os caminhos existem e contêm arquivos
    existe = false;
    
    if isempty(caminhos.imageDir) || isempty(caminhos.maskDir)
        return;
    end
    
    if exist(caminhos.imageDir, 'dir') && exist(caminhos.maskDir, 'dir')
        % Verificar se há arquivos nos diretórios
        img_files = dir(fullfile(caminhos.imageDir, '*.jpg'));
        mask_files = dir(fullfile(caminhos.maskDir, '*.jpg'));
        
        if ~isempty(img_files) && ~isempty(mask_files)
            existe = true;
        end
    end
end

function valido = validar_configuracao(config)
    % Validar se a configuração está completa e válida
    valido = true;
    
    % Verificar campos obrigatórios
    campos_obrigatorios = {'imageDir', 'maskDir', 'inputSize', 'numClasses'};
    for i = 1:length(campos_obrigatorios)
        if ~isfield(config, campos_obrigatorios{i})
            fprintf('❌ Campo obrigatório faltando: %s\n', campos_obrigatorios{i});
            valido = false;
        end
    end
    
    % Validar tipos e valores
    if valido
        if ~ischar(config.imageDir) || ~ischar(config.maskDir)
            fprintf('❌ Caminhos devem ser strings\n');
            valido = false;
        end
        
        if ~isnumeric(config.inputSize) || length(config.inputSize) ~= 3
            fprintf('❌ inputSize deve ser um vetor de 3 elementos\n');
            valido = false;
        end
        
        if ~isnumeric(config.numClasses) || config.numClasses < 2
            fprintf('❌ numClasses deve ser um número >= 2\n');
            valido = false;
        end
    end
end

function exibir_resumo_configuracao(config)
    % Exibir resumo da configuração
    fprintf('\n=== RESUMO DA CONFIGURACAO ===\n');
    fprintf('📁 Diretório de Imagens: %s\n', config.imageDir);
    fprintf('🎭 Diretório de Máscaras: %s\n', config.maskDir);
    fprintf('📐 Tamanho de Entrada: [%d, %d, %d]\n', config.inputSize);
    fprintf('🔢 Número de Classes: %d\n', config.numClasses);
    fprintf('⚡ Divisão de Validação: %.1f%%\n', config.validationSplit * 100);
    fprintf('📦 Tamanho do Lote: %d\n', config.miniBatchSize);
    fprintf('🔄 Épocas Máximas: %d\n', config.maxEpochs);
    fprintf('💻 Usuário: %s\n', config.ambiente.usuario);
    fprintf('🖥️  Computador: %s\n', config.ambiente.computador);
    fprintf('📅 Data: %s\n', config.ambiente.data_config);
    fprintf('🔧 MATLAB: %s\n', config.ambiente.matlab_version);
    
    if isfield(config.ambiente, 'modo_automatico') && config.ambiente.modo_automatico
        fprintf('🤖 Modo: Automático\n');
    end
    
    fprintf('==============================\n\n');
end
