% ========================================================================
% TESTE DO CONFIGMANAGER
% ========================================================================
% 
% Script para testar a funcionalidade da classe ConfigManager
% 
% AUTOR: Sistema de Comparação U-Net vs Attention U-Net
% Data: Julho 2025
% ========================================================================

fprintf('=====================================\n');
fprintf('   TESTE DO CONFIGMANAGER            \n');
fprintf('=====================================\n\n');

try
    % Adicionar caminho do src/core
    addpath('src/core');
    
    % Criar instância do ConfigManager
    fprintf('1. Criando instância do ConfigManager...\n');
    configMgr = ConfigManager();
    fprintf('   ✅ ConfigManager criado com sucesso\n\n');
    
    % Testar carregamento de configuração
    fprintf('2. Testando carregamento de configuração...\n');
    config = configMgr.loadConfig();
    fprintf('   ✅ Configuração carregada\n\n');
    
    % Exibir configuração carregada
    fprintf('3. Configuração atual:\n');
    fprintf('   - Diretório de imagens: %s\n', config.imageDir);
    fprintf('   - Diretório de máscaras: %s\n', config.maskDir);
    fprintf('   - Tamanho de entrada: [%d, %d, %d]\n', config.inputSize);
    fprintf('   - Número de classes: %d\n', config.numClasses);
    fprintf('   - Batch size: %d\n', config.miniBatchSize);
    fprintf('   - Épocas máximas: %d\n\n', config.maxEpochs);
    
    % Testar validação de configuração
    fprintf('4. Testando validação de configuração...\n');
    isValid = configMgr.validateConfig(config);
    if isValid
        fprintf('   ✅ Configuração é válida\n\n');
    else
        fprintf('   ⚠️  Configuração tem problemas\n\n');
    end
    
    % Testar validação de caminhos
    fprintf('5. Testando validação de caminhos...\n');
    pathsValid = configMgr.validatePaths(config);
    if pathsValid
        fprintf('   ✅ Caminhos são válidos\n\n');
    else
        fprintf('   ⚠️  Problemas com caminhos detectados\n\n');
    end
    
    % Testar validação de hardware
    fprintf('6. Testando validação de hardware...\n');
    hardwareValid = configMgr.validateHardware(config);
    if hardwareValid
        fprintf('   ✅ Hardware é adequado\n\n');
    else
        fprintf('   ⚠️  Limitações de hardware detectadas\n\n');
    end
    
    % Testar detecção de caminhos
    fprintf('7. Testando detecção automática de caminhos...\n');
    detectedPaths = configMgr.detectCommonDataPaths();
    if ~isempty(fieldnames(detectedPaths))
        fprintf('   ✅ Caminhos detectados automaticamente\n');
        if isfield(detectedPaths, 'imageDir')
            fprintf('     - Imagens: %s\n', detectedPaths.imageDir);
        end
        if isfield(detectedPaths, 'maskDir')
            fprintf('     - Máscaras: %s\n', detectedPaths.maskDir);
        end
    else
        fprintf('   ⚠️  Nenhum caminho detectado automaticamente\n');
    end
    fprintf('\n');
    
    % Testar salvamento de configuração
    fprintf('8. Testando salvamento de configuração...\n');
    success = configMgr.saveConfig(config, 'test_config.mat');
    if success
        fprintf('   ✅ Configuração salva com sucesso\n\n');
    else
        fprintf('   ❌ Erro ao salvar configuração\n\n');
    end
    
    % Testar exportação portátil
    fprintf('9. Testando exportação de configuração portátil...\n');
    portableConfig = configMgr.exportPortableConfig(config, 'test_portable_config.mat');
    if ~isempty(portableConfig)
        fprintf('   ✅ Configuração portátil exportada\n\n');
    else
        fprintf('   ❌ Erro ao exportar configuração portátil\n\n');
    end
    
    % Testar backup automático
    fprintf('10. Testando backup automático...\n');
    backupSuccess = configMgr.createAutomaticBackup(config);
    if backupSuccess
        fprintf('    ✅ Backup automático criado\n\n');
    else
        fprintf('    ❌ Erro ao criar backup automático\n\n');
    end
    
    fprintf('=====================================\n');
    fprintf('   TESTE CONCLUÍDO COM SUCESSO       \n');
    fprintf('=====================================\n\n');
    
    % Limpeza
    if exist('test_config.mat', 'file')
        delete('test_config.mat');
    end
    if exist('test_portable_config.mat', 'file')
        delete('test_portable_config.mat');
    end
    
catch ME
    fprintf('❌ ERRO NO TESTE: %s\n', ME.message);
    fprintf('   Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('     %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end