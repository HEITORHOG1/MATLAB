function exportar_configuracao_portatil()
    % ========================================================================
    % EXPORTADOR DE CONFIGURAÇÃO PORTÁTIL
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Cria um arquivo de configuração portátil que pode ser facilmente
    %   editado e usado em diferentes computadores.
    %
    % USO:
    %   >> exportar_configuracao_portatil()
    %
    % VERSÃO: 1.0
    % DATA: Julho 2025
    % ========================================================================
    
    fprintf('=====================================\n');
    fprintf('   EXPORTADOR DE CONFIGURAÇÃO        \n');
    fprintf('   Para Diferentes Computadores      \n');
    fprintf('=====================================\n\n');
    
    % Carregar configuração atual se existir
    if exist('config_caminhos.mat', 'file')
        load('config_caminhos.mat', 'config');
        fprintf('✓ Configuração atual carregada\n');
    else
        fprintf('⚠️  Nenhuma configuração encontrada. Criando template...\n');
        config = criar_template_configuracao();
    end
    
    % Criar arquivo de configuração portátil
    nome_arquivo = 'config_portatil.m';
    
    fprintf('Criando arquivo: %s\n', nome_arquivo);
    
    % Escrever arquivo
    fid = fopen(nome_arquivo, 'w', 'n', 'UTF-8');
    
    if fid == -1
        error('Não foi possível criar o arquivo %s', nome_arquivo);
    end
    
    try
        % Cabeçalho
        fprintf(fid, 'function config = config_portatil()\n');
        fprintf(fid, '%% ========================================================================\n');
        fprintf(fid, '%% CONFIGURAÇÃO PORTÁTIL - Projeto U-Net vs Attention U-Net\n');
        fprintf(fid, '%% ========================================================================\n');
        fprintf(fid, '%% \n');
        fprintf(fid, '%% DESCRIÇÃO:\n');
        fprintf(fid, '%%   Arquivo de configuração que pode ser facilmente editado para\n');
        fprintf(fid, '%%   diferentes computadores. Edite os caminhos abaixo conforme necessário.\n');
        fprintf(fid, '%%\n');
        fprintf(fid, '%% USO:\n');
        fprintf(fid, '%%   1. Edite os caminhos abaixo\n');
        fprintf(fid, '%%   2. Execute: config = config_portatil();\n');
        fprintf(fid, '%%   3. Execute: save(''config_caminhos.mat'', ''config'');\n');
        fprintf(fid, '%%\n');
        fprintf(fid, '%% GERADO AUTOMATICAMENTE EM: %s\n', datestr(now));
        fprintf(fid, '%% ========================================================================\n\n');
        
        % Seção de configuração de caminhos
        fprintf(fid, '    %% ==============================\n');
        fprintf(fid, '    %% EDITE ESTES CAMINHOS AQUI!\n');
        fprintf(fid, '    %% ==============================\n\n');
        
        % Detectar sistema operacional e ajustar exemplos
        if ispc
            fprintf(fid, '    %% Para Windows - use barras invertidas duplas (\\\\) ou simples (/)\n');
            fprintf(fid, '    imageDir = ''%s'';\n', strrep(config.imageDir, '\', '\\'));
            fprintf(fid, '    maskDir = ''%s'';\n\n', strrep(config.maskDir, '\', '\\'));
            
            fprintf(fid, '    %% Exemplos para outros computadores Windows:\n');
            fprintf(fid, '    %% imageDir = ''C:\\\\Users\\\\SeuUsuario\\\\Pictures\\\\dataset\\\\original'';\n');
            fprintf(fid, '    %% maskDir = ''C:\\\\Users\\\\SeuUsuario\\\\Pictures\\\\dataset\\\\masks'';\n');
            fprintf(fid, '    %% \n');
            fprintf(fid, '    %% Ou usando barras normais:\n');
            fprintf(fid, '    %% imageDir = ''C:/Users/SeuUsuario/Pictures/dataset/original'';\n');
            fprintf(fid, '    %% maskDir = ''C:/Users/SeuUsuario/Pictures/dataset/masks'';\n\n');
        else
            fprintf(fid, '    %% Para Linux/Mac - use barras normais (/)\n');
            fprintf(fid, '    imageDir = ''%s'';\n', config.imageDir);
            fprintf(fid, '    maskDir = ''%s'';\n\n', config.maskDir);
            
            fprintf(fid, '    %% Exemplos para outros computadores Linux/Mac:\n');
            fprintf(fid, '    %% imageDir = ''/home/usuario/dataset/original'';\n');
            fprintf(fid, '    %% maskDir = ''/home/usuario/dataset/masks'';\n\n');
        end
        
        % Configurações técnicas
        fprintf(fid, '    %% ==============================\n');
        fprintf(fid, '    %% CONFIGURAÇÕES TÉCNICAS\n');
        fprintf(fid, '    %% (Normalmente não precisam ser alteradas)\n');
        fprintf(fid, '    %% ==============================\n\n');
        
        fprintf(fid, '    config = struct();\n');
        fprintf(fid, '    config.imageDir = imageDir;\n');
        fprintf(fid, '    config.maskDir = maskDir;\n');
        fprintf(fid, '    config.inputSize = [%d, %d, %d];\n', config.inputSize);
        fprintf(fid, '    config.numClasses = %d;\n', config.numClasses);
        fprintf(fid, '    config.validationSplit = %.2f;\n', config.validationSplit);
        fprintf(fid, '    config.miniBatchSize = %d;\n', config.miniBatchSize);
        fprintf(fid, '    config.maxEpochs = %d;\n', config.maxEpochs);
        
        % Configurações de teste rápido
        fprintf(fid, '    config.quickTest = struct(''numSamples'', %d, ''maxEpochs'', %d);\n', ...
               config.quickTest.numSamples, config.quickTest.maxEpochs);
        
        % Informações do ambiente
        fprintf(fid, '\n    %% Informações do ambiente (automáticas)\n');
        fprintf(fid, '    config.ambiente = struct();\n');
        fprintf(fid, '    config.ambiente.usuario = getenv(''USERNAME'');\n');
        fprintf(fid, '    config.ambiente.computador = getenv(''COMPUTERNAME'');\n');
        fprintf(fid, '    config.ambiente.data_config = datestr(now);\n');
        fprintf(fid, '    config.ambiente.matlab_version = version;\n\n');
        
        % Validação
        fprintf(fid, '    %% Validação básica\n');
        fprintf(fid, '    if ~exist(config.imageDir, ''dir'')\n');
        fprintf(fid, '        error(''Diretório de imagens não encontrado: %%s'', config.imageDir);\n');
        fprintf(fid, '    end\n\n');
        fprintf(fid, '    if ~exist(config.maskDir, ''dir'')\n');
        fprintf(fid, '        error(''Diretório de máscaras não encontrado: %%s'', config.maskDir);\n');
        fprintf(fid, '    end\n\n');
        
        % Mensagem de sucesso
        fprintf(fid, '    fprintf(''✓ Configuração portátil carregada com sucesso!\\n'');\n');
        fprintf(fid, '    fprintf(''  Imagens: %%s\\n'', config.imageDir);\n');
        fprintf(fid, '    fprintf(''  Máscaras: %%s\\n'', config.maskDir);\n\n');
        
        fprintf(fid, 'end\n');
        
        fclose(fid);
        
        fprintf('✓ Arquivo criado: %s\n\n', nome_arquivo);
        
        % Instruções
        fprintf('INSTRUÇÕES PARA USO EM OUTRO COMPUTADOR:\n');
        fprintf('=========================================\n');
        fprintf('1. Copie este arquivo (%s) para o novo computador\n', nome_arquivo);
        fprintf('2. Abra o arquivo em um editor de texto\n');
        fprintf('3. Edite os caminhos imageDir e maskDir\n');
        fprintf('4. No MATLAB, execute:\n');
        fprintf('   >> config = config_portatil();\n');
        fprintf('   >> save(''config_caminhos.mat'', ''config'');\n');
        fprintf('5. Execute: executar_comparacao()\n\n');
        
        % Criar também um arquivo de instruções
        criar_arquivo_instrucoes(nome_arquivo);
        
    catch ME
        fclose(fid);
        error('Erro ao escrever arquivo: %s', ME.message);
    end
end

function config = criar_template_configuracao()
    % Cria um template de configuração padrão
    
    config = struct();
    config.imageDir = 'C:\Users\heito\Pictures\imagens matlab\original';
    config.maskDir = 'C:\Users\heito\Pictures\imagens matlab\masks';
    config.inputSize = [256, 256, 3];
    config.numClasses = 2;
    config.validationSplit = 0.2;
    config.miniBatchSize = 8;
    config.maxEpochs = 20;
    config.quickTest = struct('numSamples', 50, 'maxEpochs', 5);
end

function criar_arquivo_instrucoes(nome_config)
    % Cria arquivo de instruções detalhadas
    
    nome_instrucoes = 'INSTRUCOES_CONFIGURACAO.txt';
    
    fid = fopen(nome_instrucoes, 'w', 'n', 'UTF-8');
    
    if fid == -1
        return;
    end
    
    fprintf(fid, '=====================================\n');
    fprintf(fid, 'INSTRUÇÕES DE CONFIGURAÇÃO PORTÁTIL\n');
    fprintf(fid, 'Projeto U-Net vs Attention U-Net\n');
    fprintf(fid, 'Gerado em: %s\n', datestr(now));
    fprintf(fid, '=====================================\n\n');
    
    fprintf(fid, 'COMO USAR EM UM NOVO COMPUTADOR:\n\n');
    
    fprintf(fid, '1. COPIAR ARQUIVOS\n');
    fprintf(fid, '   - Copie toda a pasta do projeto\n');
    fprintf(fid, '   - Certifique-se de que %s está incluído\n\n', nome_config);
    
    fprintf(fid, '2. EDITAR CONFIGURAÇÃO\n');
    fprintf(fid, '   - Abra o arquivo %s\n', nome_config);
    fprintf(fid, '   - Encontre as linhas:\n');
    fprintf(fid, '     imageDir = ''...'';\n');
    fprintf(fid, '     maskDir = ''...'';\n');
    fprintf(fid, '   - Substitua pelos caminhos corretos no novo computador\n\n');
    
    fprintf(fid, '3. APLICAR CONFIGURAÇÃO\n');
    fprintf(fid, '   - No MATLAB, execute:\n');
    fprintf(fid, '     >> config = %s();\n', strrep(nome_config, '.m', ''));
    fprintf(fid, '     >> save(''config_caminhos.mat'', ''config'');\n\n');
    
    fprintf(fid, '4. TESTAR\n');
    fprintf(fid, '   - Execute: testar_configuracao()\n');
    fprintf(fid, '   - Se tudo estiver OK, execute: executar_comparacao()\n\n');
    
    fprintf(fid, 'EXEMPLOS DE CAMINHOS:\n\n');
    fprintf(fid, 'Windows:\n');
    fprintf(fid, '  imageDir = ''C:\\\\Users\\\\SeuNome\\\\Documents\\\\dataset\\\\original'';\n');
    fprintf(fid, '  maskDir = ''C:\\\\Users\\\\SeuNome\\\\Documents\\\\dataset\\\\masks'';\n\n');
    
    fprintf(fid, 'Linux/Mac:\n');
    fprintf(fid, '  imageDir = ''/home/seunome/dataset/original'';\n');
    fprintf(fid, '  maskDir = ''/home/seunome/dataset/masks'';\n\n');
    
    fprintf(fid, 'RESOLUÇÃO DE PROBLEMAS:\n\n');
    fprintf(fid, '- Se aparecer "Diretório não encontrado":\n');
    fprintf(fid, '  Verifique se o caminho está correto e se a pasta existe\n\n');
    fprintf(fid, '- Se aparecer erro de sintaxe:\n');
    fprintf(fid, '  Verifique se as aspas estão corretas\n');
    fprintf(fid, '  Use barras duplas \\\\ no Windows\n\n');
    
    fprintf(fid, '- Para reconfigurar completamente:\n');
    fprintf(fid, '  Delete config_caminhos.mat e execute executar_comparacao()\n\n');
    
    fclose(fid);
    
    fprintf('✓ Instruções criadas: %s\n', nome_instrucoes);
end
