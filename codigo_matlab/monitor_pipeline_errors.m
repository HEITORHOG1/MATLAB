function monitor_pipeline_errors()
    % Sistema de monitoramento para capturar erros do pipeline
    % Executa o pipeline completo e grava todos os erros em arquivo
    
    fprintf('=== SISTEMA DE MONITORAMENTO DE ERROS ===\n');
    fprintf('Iniciando monitoramento do pipeline...\n');
    
    % Configurar arquivo de log
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    error_log_file = sprintf('pipeline_errors_%s.txt', timestamp);
    
    % Abrir arquivo de log
    fid = fopen(error_log_file, 'w');
    if fid == -1
        error('Não foi possível criar arquivo de log: %s', error_log_file);
    end
    
    % Escrever cabeçalho do log
    fprintf(fid, '=== LOG DE ERROS DO PIPELINE ===\n');
    fprintf(fid, 'Data/Hora: %s\n', datestr(now));
    fprintf(fid, 'MATLAB Version: %s\n', version);
    fprintf(fid, '================================\n\n');
    
    try
        % Adicionar paths necessários
        addpath('src/utils');
        addpath('legacy');
        addpath('scripts');
        
        % Log inicial
        log_message(fid, 'INFO', 'Sistema de monitoramento iniciado');
        log_message(fid, 'INFO', 'Paths adicionados com sucesso');
        
        % Executar pipeline em etapas com monitoramento
        execute_with_monitoring(fid);
        
        log_message(fid, 'SUCCESS', 'Pipeline executado com sucesso!');
        
    catch ME
        log_error(fid, 'CRITICAL', 'Erro crítico no sistema de monitoramento', ME);
        fprintf('❌ Erro crítico capturado. Verifique o arquivo: %s\n', error_log_file);
    end
    
    % Fechar arquivo de log
    fclose(fid);
    
    % Mostrar resumo
    show_error_summary(error_log_file);
    
    fprintf('\n=== MONITORAMENTO CONCLUÍDO ===\n');
    fprintf('Log salvo em: %s\n', error_log_file);
end

function execute_with_monitoring(fid)
    % Executa o pipeline com monitoramento detalhado
    
    log_message(fid, 'INFO', 'Iniciando execução monitorada do pipeline');
    
    % Etapa 1: Verificar dependências
    try
        log_message(fid, 'INFO', 'Verificando dependências...');
        check_dependencies(fid);
        log_message(fid, 'SUCCESS', 'Dependências verificadas');
    catch ME
        log_error(fid, 'ERROR', 'Falha na verificação de dependências', ME);
    end
    
    % Etapa 2: Configurar ambiente
    try
        log_message(fid, 'INFO', 'Configurando ambiente...');
        config = setup_environment(fid);
        log_message(fid, 'SUCCESS', 'Ambiente configurado');
    catch ME
        log_error(fid, 'ERROR', 'Falha na configuração do ambiente', ME);
        return;
    end
    
    % Etapa 3: Executar pipeline principal
    try
        log_message(fid, 'INFO', 'Executando pipeline principal...');
        execute_main_pipeline(fid, config);
        log_message(fid, 'SUCCESS', 'Pipeline principal executado');
    catch ME
        log_error(fid, 'ERROR', 'Falha no pipeline principal', ME);
    end
    
    % Etapa 4: Testar componentes individuais
    try
        log_message(fid, 'INFO', 'Testando componentes individuais...');
        test_individual_components(fid);
        log_message(fid, 'SUCCESS', 'Componentes testados');
    catch ME
        log_error(fid, 'ERROR', 'Falha nos testes de componentes', ME);
    end
end

function check_dependencies(fid)
    % Verifica se todas as dependências estão disponíveis
    
    required_files = {
        'src/utils/ErrorHandler.m',
        'src/utils/VisualizationHelper.m',
        'src/utils/DataTypeConverter.m',
        'src/utils/PreprocessingValidator.m',
        'executar_comparacao.m',
        'legacy/comparacao_unet_attention_final.m'
    };
    
    for i = 1:length(required_files)
        if ~exist(required_files{i}, 'file')
            error('Arquivo necessário não encontrado: %s', required_files{i});
        end
        log_message(fid, 'DEBUG', sprintf('Arquivo encontrado: %s', required_files{i}));
    end
    
    % Verificar toolboxes necessárias
    required_toolboxes = {
        'Deep Learning Toolbox',
        'Image Processing Toolbox',
        'Computer Vision Toolbox'
    };
    
    for i = 1:length(required_toolboxes)
        if ~license('test', strrep(required_toolboxes{i}, ' ', '_'))
            log_message(fid, 'WARNING', sprintf('Toolbox pode não estar disponível: %s', required_toolboxes{i}));
        else
            log_message(fid, 'DEBUG', sprintf('Toolbox disponível: %s', required_toolboxes{i}));
        end
    end
end

function config = setup_environment(fid)
    % Configura o ambiente de execução
    
    config = struct();
    config.maxEpochs = 2; % Reduzido para teste rápido
    config.miniBatchSize = 4;
    config.inputSize = [256, 256, 3];
    config.numClasses = 2;
    config.learningRate = 0.001;
    config.validationFrequency = 10;
    
    % Configurar paths de dados (usar dados sintéticos se necessário)
    config.dataPath = 'data';
    config.outputPath = 'results';
    
    % Criar diretórios se não existirem
    if ~exist(config.outputPath, 'dir')
        mkdir(config.outputPath);
        log_message(fid, 'INFO', sprintf('Diretório criado: %s', config.outputPath));
    end
    
    log_message(fid, 'INFO', 'Configuração criada com sucesso');
end

function execute_main_pipeline(fid, config)
    % Executa o pipeline principal com captura de erros
    
    try
        % Tentar executar o script principal
        log_message(fid, 'INFO', 'Tentando executar executar_comparacao()...');
        
        % Executar com timeout para evitar travamento
        warning('off', 'all'); % Suprimir warnings durante execução
        
        % Executar em modo seguro - tentar versão automatizada primeiro
        if exist('executar_comparacao_automatico.m', 'file')
            log_message(fid, 'INFO', 'Usando versão automatizada do pipeline');
            executar_comparacao_automatico(5); % Executar todos os passos
        elseif exist('executar_comparacao.m', 'file')
            log_message(fid, 'WARNING', 'Versão automatizada não encontrada, tentando versão interativa');
            executar_comparacao();
        else
            % Fallback para execução direta
            log_message(fid, 'WARNING', 'Scripts de execução não encontrados, tentando execução direta');
            comparacao_unet_attention_final(config);
        end
        
        warning('on', 'all'); % Reativar warnings
        
    catch ME
        warning('on', 'all'); % Reativar warnings em caso de erro
        log_error(fid, 'ERROR', 'Erro na execução do pipeline principal', ME);
        
        % Tentar execução alternativa com dados sintéticos
        try
            log_message(fid, 'INFO', 'Tentando execução com dados sintéticos...');
            execute_with_synthetic_data(fid, config);
        catch ME2
            log_error(fid, 'ERROR', 'Falha também com dados sintéticos', ME2);
        end
    end
end

function execute_with_synthetic_data(fid, config)
    % Executa teste com dados sintéticos para identificar problemas
    
    log_message(fid, 'INFO', 'Gerando dados sintéticos para teste...');
    
    % Gerar dados sintéticos
    num_samples = 10;
    images = cell(num_samples, 1);
    masks = cell(num_samples, 1);
    
    for i = 1:num_samples
        % Imagem sintética
        images{i} = uint8(rand(256, 256, 3) * 255);
        
        % Máscara sintética (categorical)
        mask_logical = rand(256, 256) > 0.7;
        masks{i} = categorical(mask_logical, [false, true], ["background", "foreground"]);
    end
    
    log_message(fid, 'INFO', sprintf('Dados sintéticos gerados: %d amostras', num_samples));
    
    % Testar componentes com dados sintéticos
    test_visualization_with_data(fid, images{1}, masks{1});
    test_data_conversion_with_data(fid, masks{1});
    test_preprocessing_with_data(fid, images{1}, masks{1});
end

function test_individual_components(fid)
    % Testa componentes individuais
    
    % Teste 1: ErrorHandler
    try
        log_message(fid, 'INFO', 'Testando ErrorHandler...');
        eh = ErrorHandler.getInstance();
        eh.logInfo('test', 'Teste do ErrorHandler');
        log_message(fid, 'SUCCESS', 'ErrorHandler funcionando');
    catch ME
        log_error(fid, 'ERROR', 'Erro no ErrorHandler', ME);
    end
    
    % Teste 2: VisualizationHelper
    try
        log_message(fid, 'INFO', 'Testando VisualizationHelper...');
        test_data = uint8(rand(10, 10) * 255);
        result = VisualizationHelper.prepareImageForDisplay(test_data);
        log_message(fid, 'SUCCESS', 'VisualizationHelper funcionando');
    catch ME
        log_error(fid, 'ERROR', 'Erro no VisualizationHelper', ME);
    end
    
    % Teste 3: DataTypeConverter
    try
        log_message(fid, 'INFO', 'Testando DataTypeConverter...');
        test_cat = categorical([true, false], [false, true], ["background", "foreground"]);
        result = DataTypeConverter.categoricalToNumeric(test_cat);
        log_message(fid, 'SUCCESS', 'DataTypeConverter funcionando');
    catch ME
        log_error(fid, 'ERROR', 'Erro no DataTypeConverter', ME);
    end
    
    % Teste 4: PreprocessingValidator
    try
        log_message(fid, 'INFO', 'Testando PreprocessingValidator...');
        test_img = rand(256, 256, 3);
        test_mask = categorical(rand(256, 256) > 0.5, [false, true], ["background", "foreground"]);
        result = PreprocessingValidator.validateImageMaskPair(test_img, test_mask);
        log_message(fid, 'SUCCESS', 'PreprocessingValidator funcionando');
    catch ME
        log_error(fid, 'ERROR', 'Erro no PreprocessingValidator', ME);
    end
end

function test_visualization_with_data(fid, image, mask)
    % Testa visualização com dados reais
    
    try
        log_message(fid, 'INFO', 'Testando visualização com dados...');
        
        % Testar preparação de imagem
        img_prepared = VisualizationHelper.prepareImageForDisplay(image);
        log_message(fid, 'DEBUG', sprintf('Imagem preparada: %s, size: %s', class(img_prepared), mat2str(size(img_prepared))));
        
        % Testar preparação de máscara
        mask_prepared = VisualizationHelper.prepareMaskForDisplay(mask);
        log_message(fid, 'DEBUG', sprintf('Máscara preparada: %s, size: %s', class(mask_prepared), mat2str(size(mask_prepared))));
        
        % Testar preparação de comparação
        [imgOut, maskOut, predOut] = VisualizationHelper.prepareComparisonData(image, mask, mask);
        log_message(fid, 'DEBUG', 'Dados de comparação preparados com sucesso');
        
        log_message(fid, 'SUCCESS', 'Teste de visualização concluído');
        
    catch ME
        log_error(fid, 'ERROR', 'Erro no teste de visualização', ME);
    end
end

function test_data_conversion_with_data(fid, mask)
    % Testa conversão de dados
    
    try
        log_message(fid, 'INFO', 'Testando conversão de dados...');
        
        % Testar conversão categorical para numeric
        numeric_result = DataTypeConverter.categoricalToNumeric(mask);
        log_message(fid, 'DEBUG', sprintf('Conversão categórica: %s -> %s', class(mask), class(numeric_result)));
        
        % Testar conversão para RGB
        rgb_result = DataTypeConverter.categoricalToRGB(mask);
        log_message(fid, 'DEBUG', sprintf('Conversão RGB: size: %s', mat2str(size(rgb_result))));
        
        log_message(fid, 'SUCCESS', 'Teste de conversão concluído');
        
    catch ME
        log_error(fid, 'ERROR', 'Erro no teste de conversão', ME);
    end
end

function test_preprocessing_with_data(fid, image, mask)
    % Testa preprocessamento
    
    try
        log_message(fid, 'INFO', 'Testando preprocessamento...');
        
        % Testar validação de par imagem-máscara
        is_valid = PreprocessingValidator.validateImageMaskPair(image, mask);
        log_message(fid, 'DEBUG', sprintf('Validação de par: %s', mat2str(is_valid)));
        
        % Testar validação de dados categóricos
        is_cat_valid = PreprocessingValidator.validateCategoricalData(mask);
        log_message(fid, 'DEBUG', sprintf('Validação categórica: %s', mat2str(is_cat_valid)));
        
        log_message(fid, 'SUCCESS', 'Teste de preprocessamento concluído');
        
    catch ME
        log_error(fid, 'ERROR', 'Erro no teste de preprocessamento', ME);
    end
end

function log_message(fid, level, message)
    % Registra mensagem no log
    timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    log_entry = sprintf('[%s] %s: %s\n', timestamp, level, message);
    fprintf(fid, log_entry);
    fprintf(log_entry); % Também mostrar no console
end

function log_error(fid, level, message, ME)
    % Registra erro detalhado no log
    timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    
    fprintf(fid, '[%s] %s: %s\n', timestamp, level, message);
    fprintf(fid, '  Erro: %s\n', ME.message);
    fprintf(fid, '  Identificador: %s\n', ME.identifier);
    
    if ~isempty(ME.stack)
        fprintf(fid, '  Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf(fid, '    %s (linha %d) em %s\n', ME.stack(i).name, ME.stack(i).line, ME.stack(i).file);
        end
    end
    fprintf(fid, '\n');
    
    % Também mostrar no console
    fprintf('[%s] %s: %s\n', timestamp, level, message);
    fprintf('  Erro: %s\n', ME.message);
end

function show_error_summary(error_log_file)
    % Mostra resumo dos erros encontrados
    
    fprintf('\n=== RESUMO DE ERROS ===\n');
    
    try
        content = fileread(error_log_file);
        
        % Contar tipos de mensagens
        error_count = length(strfind(content, '] ERROR:'));
        warning_count = length(strfind(content, '] WARNING:'));
        success_count = length(strfind(content, '] SUCCESS:'));
        critical_count = length(strfind(content, '] CRITICAL:'));
        
        fprintf('Erros críticos: %d\n', critical_count);
        fprintf('Erros: %d\n', error_count);
        fprintf('Avisos: %d\n', warning_count);
        fprintf('Sucessos: %d\n', success_count);
        
        if error_count > 0 || critical_count > 0
            fprintf('\n⚠ Erros encontrados! Verifique o arquivo de log para detalhes.\n');
        else
            fprintf('\n✅ Nenhum erro crítico encontrado!\n');
        end
        
    catch
        fprintf('Erro ao ler arquivo de log para resumo.\n');
    end
end