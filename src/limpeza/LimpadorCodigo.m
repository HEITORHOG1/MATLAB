classdef LimpadorCodigo < handle
    % ========================================================================
    % LIMPADOR DE CÓDIGO - Sistema de Limpeza e Organização
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Classe responsável por identificar e remover arquivos duplicados,
    %   obsoletos e desnecessários do projeto, mantendo apenas o essencial
    %   para o funcionamento do sistema de segmentação.
    %
    % FUNCIONALIDADES:
    %   - Identificar arquivos duplicados
    %   - Identificar arquivos obsoletos
    %   - Criar backup antes da remoção
    %   - Remover arquivos desnecessários
    %   - Reorganizar estrutura de pastas
    %
    % USO:
    %   limpador = LimpadorCodigo();
    %   limpador.executarLimpeza();
    %
    % AUTOR: Sistema de Segmentação Completo
    % DATA: Agosto 2025
    % ========================================================================
    
    properties (Access = private)
        arquivosDuplicados
        arquivosObsoletos
        arquivosEssenciais
        pastaBackup
        relatorioLimpeza
    end
    
    methods
        function obj = LimpadorCodigo()
            % Construtor da classe
            obj.pastaBackup = fullfile(pwd, 'backup_limpeza');
            obj.relatorioLimpeza = {};
            obj.inicializarArquivosEssenciais();
        end
        
        function executarLimpeza(obj)
            % Executa o processo completo de limpeza
            
            fprintf('=== INICIANDO LIMPEZA DO CÓDIGO BASE ===\n\n');
            
            try
                % Etapa 1: Identificar arquivos duplicados e obsoletos
                fprintf('[1/5] Identificando arquivos duplicados e obsoletos...\n');
                obj.identificarArquivosDuplicados();
                obj.identificarArquivosObsoletos();
                
                % Etapa 2: Criar lista de arquivos para remoção
                fprintf('[2/5] Criando lista de arquivos para remoção...\n');
                obj.criarListaRemocao();
                
                % Etapa 3: Fazer backup dos arquivos importantes
                fprintf('[3/5] Criando backup dos arquivos importantes...\n');
                obj.criarBackup();
                
                % Etapa 4: Remover arquivos desnecessários
                fprintf('[4/5] Removendo arquivos desnecessários...\n');
                obj.removerArquivos();
                
                % Etapa 5: Reorganizar estrutura de pastas
                fprintf('[5/5] Reorganizando estrutura de pastas...\n');
                obj.reorganizarEstrutura();
                
                % Gerar relatório final
                obj.gerarRelatorioFinal();
                
                fprintf('\n✅ LIMPEZA CONCLUÍDA COM SUCESSO!\n');
                fprintf('📁 Backup criado em: %s\n', obj.pastaBackup);
                fprintf('📄 Relatório salvo em: relatorio_limpeza.txt\n');
                
            catch ME
                fprintf('\n❌ ERRO durante limpeza: %s\n', ME.message);
                fprintf('📍 Local: %s\n', ME.stack(1).name);
                rethrow(ME);
            end
        end
        
        function identificarArquivosDuplicados(obj)
            % Identifica arquivos duplicados no projeto
            
            obj.arquivosDuplicados = {};
            
            % Padrões de arquivos duplicados conhecidos
            padroesDuplicados = {
                '*.backup',           'Arquivos de backup';
                'config_backup_*.mat', 'Backups de configuração';
                '*_old.*',            'Arquivos marcados como antigos';
                '*_backup.*',         'Arquivos de backup';
                '*_v*.mat',           'Versões antigas de arquivos';
                'temp_*.mat',         'Arquivos temporários';
                'workspace_backup.mat', 'Backup de workspace'
            };
            
            fprintf('   Procurando por padrões de duplicação...\n');
            
            for i = 1:size(padroesDuplicados, 1)
                padrao = padroesDuplicados{i, 1};
                descricao = padroesDuplicados{i, 2};
                
                arquivos = dir(padrao);
                
                for j = 1:length(arquivos)
                    if ~arquivos(j).isdir
                        obj.arquivosDuplicados{end+1} = struct(...
                            'nome', arquivos(j).name, ...
                            'caminho', fullfile(arquivos(j).folder, arquivos(j).name), ...
                            'tipo', 'duplicado', ...
                            'motivo', descricao ...
                        );
                    end
                end
            end
            
            % Identificar executáveis similares
            obj.identificarExecutaveisSimilares();
            
            fprintf('   ✓ Encontrados %d arquivos duplicados\n', length(obj.arquivosDuplicados));
        end
        
        function identificarExecutaveisSimilares(obj)
            % Identifica scripts executáveis similares que podem ser duplicados
            
            executaveis = {
                'executar_comparacao.m',
                'executar_comparacao_automatico.m', 
                'executar_pipeline_real.m',
                'executar_sistema_completo.m'
            };
            
            % Manter apenas o executar_sistema_completo.m como principal
            for i = 1:length(executaveis)
                arquivo = executaveis{i};
                if exist(arquivo, 'file') && ~strcmp(arquivo, 'executar_sistema_completo.m')
                    obj.arquivosDuplicados{end+1} = struct(...
                        'nome', arquivo, ...
                        'caminho', fullfile(pwd, arquivo), ...
                        'tipo', 'executavel_duplicado', ...
                        'motivo', 'Script executável duplicado - manter apenas executar_sistema_completo.m' ...
                    );
                end
            end
        end
        
        function identificarArquivosObsoletos(obj)
            % Identifica arquivos obsoletos no projeto
            
            obj.arquivosObsoletos = {};
            
            % Arquivos de teste temporários
            arquivosTest = dir('test_*.m');
            for i = 1:length(arquivosTest)
                if ~arquivosTest(i).isdir
                    obj.arquivosObsoletos{end+1} = struct(...
                        'nome', arquivosTest(i).name, ...
                        'caminho', fullfile(arquivosTest(i).folder, arquivosTest(i).name), ...
                        'tipo', 'teste_temporario', ...
                        'motivo', 'Arquivo de teste temporário' ...
                    );
                end
            end
            
            % Arquivos de erro e log temporários
            arquivosLog = [dir('pipeline_errors_*.txt'); dir('*_errors_*.txt')];
            for i = 1:length(arquivosLog)
                if ~arquivosLog(i).isdir
                    obj.arquivosObsoletos{end+1} = struct(...
                        'nome', arquivosLog(i).name, ...
                        'caminho', fullfile(arquivosLog(i).folder, arquivosLog(i).name), ...
                        'tipo', 'log_temporario', ...
                        'motivo', 'Arquivo de log temporário' ...
                    );
                end
            end
            
            % Arquivos de modelo de teste
            modelosTest = dir('*_teste.mat');
            for i = 1:length(modelosTest)
                if ~modelosTest(i).isdir
                    obj.arquivosObsoletos{end+1} = struct(...
                        'nome', modelosTest(i).name, ...
                        'caminho', fullfile(modelosTest(i).folder, modelosTest(i).name), ...
                        'tipo', 'modelo_teste', ...
                        'motivo', 'Modelo de teste temporário' ...
                    );
                end
            end
            
            % Arquivos de imagem temporários na pasta temp
            if exist('temp', 'dir')
                arquivosTemp = dir('temp/*.png');
                for i = 1:length(arquivosTemp)
                    obj.arquivosObsoletos{end+1} = struct(...
                        'nome', arquivosTemp(i).name, ...
                        'caminho', fullfile(arquivosTemp(i).folder, arquivosTemp(i).name), ...
                        'tipo', 'imagem_temporaria', ...
                        'motivo', 'Imagem temporária de teste' ...
                    );
                end
            end
            
            fprintf('   ✓ Encontrados %d arquivos obsoletos\n', length(obj.arquivosObsoletos));
        end
        
        function inicializarArquivosEssenciais(obj)
            % Define lista de arquivos essenciais que nunca devem ser removidos
            
            obj.arquivosEssenciais = {
                % Scripts principais
                'executar_sistema_completo.m',
                
                % Configurações importantes
                'config_caminhos.mat',
                'config_comparacao.mat',
                
                % Modelos treinados finais
                'modelo_unet.mat',
                'modelo_attention_unet.mat',
                
                % Documentação
                'README.md',
                'CHANGELOG.md',
                'INSTALLATION.md',
                
                % Estrutura do projeto
                'src/',
                'data/',
                'docs/',
                'examples/',
                'tests/',
                'scripts/',
                'utils/',
                
                % Arquivos de sistema
                '.gitignore',
                '.kiro/',
                
                % Resultados finais
                'RESULTADOS_FINAIS/',
                'resultados_segmentacao/',
                'organized_results/'
            };
        end
        
        function criarListaRemocao(obj)
            % Cria lista consolidada de arquivos para remoção
            
            fprintf('   Consolidando lista de remoção...\n');
            
            % Combinar duplicados e obsoletos
            todosArquivos = [obj.arquivosDuplicados, obj.arquivosObsoletos];
            
            % Filtrar arquivos essenciais
            arquivosParaRemover = {};
            
            for i = 1:length(todosArquivos)
                arquivo = todosArquivos{i};
                
                % Verificar se não é essencial
                if ~obj.isArquivoEssencial(arquivo.nome)
                    arquivosParaRemover{end+1} = arquivo;
                    obj.relatorioLimpeza{end+1} = sprintf('REMOVER: %s - %s', arquivo.nome, arquivo.motivo);
                else
                    obj.relatorioLimpeza{end+1} = sprintf('MANTER: %s - Arquivo essencial', arquivo.nome);
                end
            end
            
            % Atualizar listas
            obj.arquivosDuplicados = {};
            obj.arquivosObsoletos = {};
            
            for i = 1:length(arquivosParaRemover)
                arquivo = arquivosParaRemover{i};
                if strcmp(arquivo.tipo, 'duplicado') || contains(arquivo.tipo, 'duplicado')
                    obj.arquivosDuplicados{end+1} = arquivo;
                else
                    obj.arquivosObsoletos{end+1} = arquivo;
                end
            end
            
            fprintf('   ✓ Lista criada: %d duplicados, %d obsoletos\n', ...
                length(obj.arquivosDuplicados), length(obj.arquivosObsoletos));
        end
        
        function isEssencial = isArquivoEssencial(obj, nomeArquivo)
            % Verifica se um arquivo é essencial e não deve ser removido
            
            isEssencial = false;
            
            for i = 1:length(obj.arquivosEssenciais)
                essencial = obj.arquivosEssenciais{i};
                
                % Verificação exata
                if strcmp(nomeArquivo, essencial)
                    isEssencial = true;
                    return;
                end
                
                % Verificação de pasta
                if endsWith(essencial, '/') && startsWith(nomeArquivo, essencial(1:end-1))
                    isEssencial = true;
                    return;
                end
            end
        end
        
        function criarBackup(obj)
            % Cria backup dos arquivos importantes antes da remoção
            
            if ~exist(obj.pastaBackup, 'dir')
                mkdir(obj.pastaBackup);
            end
            
            % Backup de arquivos duplicados importantes
            for i = 1:length(obj.arquivosDuplicados)
                arquivo = obj.arquivosDuplicados{i};
                obj.backupArquivo(arquivo);
            end
            
            % Backup de arquivos obsoletos importantes
            for i = 1:length(obj.arquivosObsoletos)
                arquivo = obj.arquivosObsoletos{i};
                obj.backupArquivo(arquivo);
            end
            
            fprintf('   ✓ Backup criado em: %s\n', obj.pastaBackup);
        end
        
        function backupArquivo(obj, arquivo)
            % Faz backup de um arquivo específico
            
            try
                if exist(arquivo.caminho, 'file')
                    [~, nome, ext] = fileparts(arquivo.nome);
                    nomeBackup = sprintf('%s_backup_%s%s', nome, datestr(now, 'yyyymmdd_HHMMSS'), ext);
                    caminhoBackup = fullfile(obj.pastaBackup, nomeBackup);
                    
                    copyfile(arquivo.caminho, caminhoBackup);
                    obj.relatorioLimpeza{end+1} = sprintf('BACKUP: %s -> %s', arquivo.nome, nomeBackup);
                end
            catch ME
                obj.relatorioLimpeza{end+1} = sprintf('ERRO BACKUP: %s - %s', arquivo.nome, ME.message);
            end
        end
        
        function removerArquivos(obj)
            % Remove os arquivos identificados como desnecessários
            
            totalRemovidos = 0;
            
            % Remover duplicados
            for i = 1:length(obj.arquivosDuplicados)
                arquivo = obj.arquivosDuplicados{i};
                if obj.removerArquivo(arquivo)
                    totalRemovidos = totalRemovidos + 1;
                end
            end
            
            % Remover obsoletos
            for i = 1:length(obj.arquivosObsoletos)
                arquivo = obj.arquivosObsoletos{i};
                if obj.removerArquivo(arquivo)
                    totalRemovidos = totalRemovidos + 1;
                end
            end
            
            fprintf('   ✓ %d arquivos removidos\n', totalRemovidos);
        end
        
        function sucesso = removerArquivo(obj, arquivo)
            % Remove um arquivo específico
            
            sucesso = false;
            
            try
                if exist(arquivo.caminho, 'file')
                    delete(arquivo.caminho);
                    obj.relatorioLimpeza{end+1} = sprintf('REMOVIDO: %s', arquivo.nome);
                    sucesso = true;
                else
                    obj.relatorioLimpeza{end+1} = sprintf('JÁ REMOVIDO: %s', arquivo.nome);
                end
            catch ME
                obj.relatorioLimpeza{end+1} = sprintf('ERRO REMOÇÃO: %s - %s', arquivo.nome, ME.message);
            end
        end
        
        function reorganizarEstrutura(obj)
            % Reorganiza a estrutura de pastas mantendo apenas o necessário
            
            fprintf('   Reorganizando estrutura de pastas...\n');
            
            % Criar estrutura padrão se não existir
            pastasEssenciais = {
                'src',
                'src/core',
                'src/treinamento', 
                'src/segmentacao',
                'src/comparacao',
                'src/limpeza',
                'data',
                'data/images',
                'data/masks',
                'results',
                'docs'
            };
            
            for i = 1:length(pastasEssenciais)
                pasta = pastasEssenciais{i};
                if ~exist(pasta, 'dir')
                    mkdir(pasta);
                    obj.relatorioLimpeza{end+1} = sprintf('PASTA CRIADA: %s', pasta);
                end
            end
            
            % Remover pastas vazias desnecessárias
            obj.removerPastasVazias();
            
            fprintf('   ✓ Estrutura reorganizada\n');
        end
        
        function removerPastasVazias(obj)
            % Remove pastas vazias que não são essenciais
            
            pastasParaVerificar = {'temp', 'output', 'backup_*'};
            
            for i = 1:length(pastasParaVerificar)
                padrao = pastasParaVerificar{i};
                pastas = dir(padrao);
                
                for j = 1:length(pastas)
                    if pastas(j).isdir && ~strcmp(pastas(j).name, '.') && ~strcmp(pastas(j).name, '..')
                        caminhoCompleto = fullfile(pastas(j).folder, pastas(j).name);
                        
                        % Verificar se está vazia
                        conteudo = dir(caminhoCompleto);
                        conteudo = conteudo(~ismember({conteudo.name}, {'.', '..'}));
                        
                        if isempty(conteudo)
                            try
                                rmdir(caminhoCompleto);
                                obj.relatorioLimpeza{end+1} = sprintf('PASTA VAZIA REMOVIDA: %s', pastas(j).name);
                            catch ME
                                obj.relatorioLimpeza{end+1} = sprintf('ERRO REMOVER PASTA: %s - %s', pastas(j).name, ME.message);
                            end
                        end
                    end
                end
            end
        end
        
        function gerarRelatorioFinal(obj)
            % Gera relatório final da limpeza
            
            nomeRelatorio = 'relatorio_limpeza.txt';
            fid = fopen(nomeRelatorio, 'w');
            
            fprintf(fid, '================================================================\n');
            fprintf(fid, '                    RELATÓRIO DE LIMPEZA\n');
            fprintf(fid, '                 Sistema de Segmentação Completo\n');
            fprintf(fid, '================================================================\n\n');
            fprintf(fid, 'Data: %s\n\n', datestr(now));
            
            fprintf(fid, '📊 RESUMO:\n');
            fprintf(fid, '- Arquivos duplicados identificados: %d\n', length(obj.arquivosDuplicados));
            fprintf(fid, '- Arquivos obsoletos identificados: %d\n', length(obj.arquivosObsoletos));
            fprintf(fid, '- Total de arquivos processados: %d\n\n', length(obj.relatorioLimpeza));
            
            fprintf(fid, '📝 DETALHES DAS OPERAÇÕES:\n');
            for i = 1:length(obj.relatorioLimpeza)
                fprintf(fid, '%s\n', obj.relatorioLimpeza{i});
            end
            
            fprintf(fid, '\n================================================================\n');
            fprintf(fid, '✅ LIMPEZA CONCLUÍDA COM SUCESSO!\n');
            fprintf(fid, '📁 Backup disponível em: %s\n', obj.pastaBackup);
            fprintf(fid, '================================================================\n');
            
            fclose(fid);
        end
    end
end