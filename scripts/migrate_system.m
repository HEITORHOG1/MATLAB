function success = migrate_system()
    % ========================================================================
    % MIGRATE_SYSTEM - SCRIPT DE MIGRAÇÃO AUTOMÁTICA
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Script principal para migração automática do sistema legado para
    %   nova arquitetura. Preserva configurações existentes e fornece
    %   sistema de rollback em caso de problemas.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Script Files
    %   - Error Handling
    %   - File I/O
    %
    % USO:
    %   >> success = migrate_system();
    %
    % REQUISITOS: 5.5
    % ========================================================================
    
    success = false;
    
    try
        fprintf('\n');
        fprintf('========================================================================\n');
        fprintf('                    MIGRAÇÃO AUTOMÁTICA DO SISTEMA                     \n');
        fprintf('                   U-Net vs Attention U-Net v2.0                      \n');
        fprintf('========================================================================\n');
        fprintf('\n');
        
        % Verificar se migração já foi executada
        if exist('migration_status.mat', 'file')
            migrationData = load('migration_status.mat');
            if isfield(migrationData, 'migrationStatus') && migrationData.migrationStatus.completed
                fprintf('⚠️  Sistema já foi migrado em: %s\n', migrationData.migrationStatus.date);
                
                choice = input('Deseja executar migração novamente? (s/n) [n]: ', 's');
                if isempty(choice) || lower(choice) ~= 's'
                    fprintf('Migração cancelada pelo usuário.\n');
                    return;
                end
                
                fprintf('\n🔄 Executando nova migração...\n\n');
            end
        end
        
        % Verificar se usuário quer continuar
        fprintf('Esta migração irá:\n');
        fprintf('✓ Fazer backup completo do sistema atual\n');
        fprintf('✓ Migrar configurações para nova arquitetura\n');
        fprintf('✓ Reorganizar estrutura de arquivos\n');
        fprintf('✓ Validar sistema migrado\n');
        fprintf('✓ Fornecer opção de rollback se necessário\n\n');
        
        choice = input('Deseja continuar com a migração? (s/n) [s]: ', 's');
        if ~isempty(choice) && lower(choice) == 'n'
            fprintf('Migração cancelada pelo usuário.\n');
            return;
        end
        
        fprintf('\n🚀 Iniciando migração...\n\n');
        
        % Adicionar caminho para utilitários
        if exist('src/utils', 'dir')
            addpath('src/utils');
        else
            fprintf('❌ Diretório src/utils não encontrado.\n');
            fprintf('   Execute primeiro a criação da estrutura do projeto.\n');
            return;
        end
        
        % Criar instância do MigrationManager
        try
            migrator = MigrationManager();
        catch ME
            fprintf('❌ Erro ao inicializar MigrationManager: %s\n', ME.message);
            fprintf('   Verifique se todos os arquivos estão presentes.\n');
            return;
        end
        
        % Verificar compatibilidade antes de migrar
        fprintf('🔍 Verificando compatibilidade...\n');
        if ~migrator.validateCompatibility()
            fprintf('❌ Dados não são compatíveis para migração.\n');
            fprintf('   Verifique configurações e dados existentes.\n');
            return;
        end
        
        % Executar migração
        fprintf('⚙️  Executando migração...\n');
        if migrator.performMigration()
            fprintf('\n✅ MIGRAÇÃO CONCLUÍDA COM SUCESSO!\n\n');
            
            % Mostrar instruções pós-migração
            showPostMigrationInstructions();
            
            success = true;
        else
            fprintf('\n❌ MIGRAÇÃO FALHOU!\n');
            fprintf('   Consulte migration_log.txt para detalhes.\n');
            
            % Oferecer rollback
            choice = input('Deseja executar rollback? (s/n) [s]: ', 's');
            if isempty(choice) || lower(choice) == 's'
                fprintf('\n🔄 Executando rollback...\n');
                if migrator.rollback()
                    fprintf('✅ Rollback concluído. Sistema restaurado.\n');
                else
                    fprintf('❌ Erro no rollback. Verifique manualmente.\n');
                end
            end
        end
        
    catch ME
        fprintf('\n❌ ERRO CRÍTICO NA MIGRAÇÃO: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        % Tentar rollback automático
        try
            fprintf('\n🔄 Tentando rollback automático...\n');
            if exist('src/utils/MigrationManager.m', 'file')
                addpath('src/utils');
                migrator = MigrationManager();
                if migrator.rollback()
                    fprintf('✅ Rollback automático concluído.\n');
                else
                    fprintf('❌ Rollback automático falhou.\n');
                end
            end
        catch
            fprintf('❌ Não foi possível executar rollback automático.\n');
        end
    end
    
    fprintf('\n========================================================================\n');
    if success
        fprintf('                        MIGRAÇÃO CONCLUÍDA                             \n');
    else
        fprintf('                         MIGRAÇÃO FALHOU                               \n');
    end
    fprintf('========================================================================\n\n');
end

function showPostMigrationInstructions()
    % Mostra instruções após migração bem-sucedida
    
    fprintf('📋 INSTRUÇÕES PÓS-MIGRAÇÃO:\n\n');
    
    fprintf('1. 🎯 COMO USAR O NOVO SISTEMA:\n');
    fprintf('   >> addpath(''src/core'')\n');
    fprintf('   >> mainInterface = MainInterface()\n');
    fprintf('   >> mainInterface.run()\n\n');
    
    fprintf('2. 📁 NOVA ESTRUTURA DE ARQUIVOS:\n');
    fprintf('   - src/          : Código fonte organizado\n');
    fprintf('   - config/       : Configurações do sistema\n');
    fprintf('   - output/       : Resultados e relatórios\n');
    fprintf('   - tests/        : Testes automatizados\n\n');
    
    fprintf('3. 🔧 CONFIGURAÇÕES:\n');
    fprintf('   - Suas configurações foram preservadas\n');
    fprintf('   - Nova configuração em: config/system_config.mat\n');
    fprintf('   - Backup da configuração antiga mantido\n\n');
    
    fprintf('4. 📊 FUNCIONALIDADES NOVAS:\n');
    fprintf('   - Interface melhorada com feedback visual\n');
    fprintf('   - Sistema de testes automatizados\n');
    fprintf('   - Relatórios mais detalhados\n');
    fprintf('   - Melhor organização de código\n\n');
    
    fprintf('5. 🆘 SE ALGO DER ERRADO:\n');
    fprintf('   >> migrator = MigrationManager()\n');
    fprintf('   >> migrator.rollback()\n\n');
    
    fprintf('6. 📖 DOCUMENTAÇÃO:\n');
    fprintf('   - Consulte: MIGRATION_README.md\n');
    fprintf('   - Logs em: migration_log.txt\n');
    fprintf('   - Guia do usuário: docs/user_guide.md\n\n');
    
    fprintf('✨ Aproveite o sistema melhorado!\n\n');
end