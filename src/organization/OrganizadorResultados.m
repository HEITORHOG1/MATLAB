classdef OrganizadorResultados < handle
    % OrganizadorResultados - Classe para organizar automaticamente os resultados de segmentação
    % 
    % Esta classe é responsável por:
    % - Criar estrutura de pastas para organizar resultados
    % - Implementar nomenclatura consistente para arquivos
    % - Gerar índices de arquivos processados
    % - Organizar modelos treinados
    % - Recuperar de erros criando pastas automaticamente
    
    properties (Constant)
        PASTA_BASE = 'resultados_segmentacao'
        PASTA_UNET = 'unet'
        PASTA_ATTENTION = 'attention_unet'
        PASTA_COMPARACOES = 'comparacoes'
        PASTA_RELATORIOS = 'relatorios'
        PASTA_MODELOS = 'modelos'
    end
    
    properties
        caminhoBase
        estruturaCriada
        indiceArquivos
    end
    
    methods
        function obj = OrganizadorResultados(caminhoBase)
            % Construtor da classe OrganizadorResultados
            %
            % Parâmetros:
            %   caminhoBase - Caminho base onde criar a estrutura (opcional)
            
            if nargin < 1 || isempty(caminhoBase)
                obj.caminhoBase = obj.PASTA_BASE;
            else
                obj.caminhoBase = caminhoBase;
            end
            
            obj.estruturaCriada = false;
            obj.indiceArquivos = struct();
            obj.indiceArquivos.unet = {};
            obj.indiceArquivos.attention_unet = {};
            obj.indiceArquivos.modelos = {};
            obj.indiceArquivos.comparacoes = {};
        end
        
        function sucesso = criarEstruturaPastas(obj)
            % Cria toda a estrutura de pastas necessária
            %
            % Retorna:
            %   sucesso - true se todas as pastas foram criadas com sucesso
            
            fprintf('Criando estrutura de pastas...\n');
            
            try
                % Lista de todas as pastas necessárias
                pastas = {
                    obj.caminhoBase,
                    fullfile(obj.caminhoBase, obj.PASTA_UNET),
                    fullfile(obj.caminhoBase, obj.PASTA_ATTENTION),
                    fullfile(obj.caminhoBase, obj.PASTA_COMPARACOES),
                    fullfile(obj.caminhoBase, obj.PASTA_RELATORIOS),
                    fullfile(obj.caminhoBase, obj.PASTA_MODELOS)
                };
                
                % Cria cada pasta se não existir
                for i = 1:length(pastas)
                    if ~exist(pastas{i}, 'dir')
                        [sucesso_pasta, msg] = mkdir(pastas{i});
                        if ~sucesso_pasta
                            error('Erro ao criar pasta %s: %s', pastas{i}, msg);
                        end
                        fprintf('  ✓ Pasta criada: %s\n', pastas{i});
                    else
                        fprintf('  ✓ Pasta já existe: %s\n', pastas{i});
                    end
                end
                
                obj.estruturaCriada = true;
                sucesso = true;
                fprintf('✅ Estrutura de pastas criada com sucesso!\n');
                
            catch ME
                fprintf('❌ Erro ao criar estrutura de pastas: %s\n', ME.message);
                sucesso = false;
            end
        end
        
        function nomeArquivo = gerarNomeConsistente(obj, nomeOriginal, tipoModelo, extensao)
            % Gera nome de arquivo consistente baseado no padrão estabelecido
            %
            % Parâmetros:
            %   nomeOriginal - Nome original do arquivo
            %   tipoModelo - 'unet' ou 'attention_unet'
            %   extensao - Extensão do arquivo (ex: 'png', 'mat')
            %
            % Retorna:
            %   nomeArquivo - Nome formatado consistentemente
            
            if nargin < 4 || isempty(extensao)
                extensao = 'png';
            end
            
            % Remove extensão do nome original se presente
            [~, nomeBase, ~] = fileparts(nomeOriginal);
            
            % Gera nome consistente: nomebase_modelo.extensao
            switch lower(tipoModelo)
                case 'unet'
                    sufixo = 'unet';
                case 'attention_unet'
                    sufixo = 'attention';
                case 'attention'
                    sufixo = 'attention';
                otherwise
                    sufixo = tipoModelo;
            end
            
            nomeArquivo = sprintf('%s_%s.%s', nomeBase, sufixo, extensao);
        end
        
        function sucesso = organizarArquivoSegmentacao(obj, arquivoOrigem, nomeOriginal, tipoModelo)
            % Organiza um arquivo de segmentação na pasta apropriada
            %
            % Parâmetros:
            %   arquivoOrigem - Caminho completo do arquivo original
            %   nomeOriginal - Nome original do arquivo
            %   tipoModelo - 'unet' ou 'attention_unet'
            %
            % Retorna:
            %   sucesso - true se o arquivo foi organizado com sucesso
            
            try
                % Garante que a estrutura existe
                if ~obj.estruturaCriada
                    obj.criarEstruturaPastas();
                end
                
                % Determina pasta de destino
                switch lower(tipoModelo)
                    case 'unet'
                        pastaDestino = fullfile(obj.caminhoBase, obj.PASTA_UNET);
                        indiceKey = 'unet';
                    case {'attention_unet', 'attention'}
                        pastaDestino = fullfile(obj.caminhoBase, obj.PASTA_ATTENTION);
                        indiceKey = 'attention_unet';
                    otherwise
                        error('Tipo de modelo não reconhecido: %s', tipoModelo);
                end
                
                % Gera nome consistente
                nomeDestino = obj.gerarNomeConsistente(nomeOriginal, tipoModelo, 'png');
                caminhoDestino = fullfile(pastaDestino, nomeDestino);
                
                % Move ou copia arquivo
                if exist(arquivoOrigem, 'file')
                    [sucesso_copia, msg] = copyfile(arquivoOrigem, caminhoDestino);
                    if ~sucesso_copia
                        error('Erro ao copiar arquivo: %s', msg);
                    end
                    
                    % Adiciona ao índice
                    obj.indiceArquivos.(indiceKey){end+1} = struct(...
                        'original', nomeOriginal, ...
                        'organizado', nomeDestino, ...
                        'caminho', caminhoDestino, ...
                        'timestamp', datetime('now'));
                    
                    fprintf('  ✓ Arquivo organizado: %s -> %s\n', nomeOriginal, nomeDestino);
                    sucesso = true;
                else
                    error('Arquivo origem não encontrado: %s', arquivoOrigem);
                end
                
            catch ME
                fprintf('❌ Erro ao organizar arquivo %s: %s\n', nomeOriginal, ME.message);
                sucesso = false;
            end
        end
        
        function sucesso = organizarModelo(obj, arquivoModelo, nomeModelo)
            % Organiza um modelo treinado na pasta de modelos
            %
            % Parâmetros:
            %   arquivoModelo - Caminho completo do arquivo do modelo
            %   nomeModelo - Nome identificador do modelo
            %
            % Retorna:
            %   sucesso - true se o modelo foi organizado com sucesso
            
            try
                % Garante que a estrutura existe
                if ~obj.estruturaCriada
                    obj.criarEstruturaPastas();
                end
                
                pastaDestino = fullfile(obj.caminhoBase, obj.PASTA_MODELOS);
                
                % Gera nome consistente para modelo
                [~, ~, ext] = fileparts(arquivoModelo);
                nomeDestino = sprintf('%s%s', nomeModelo, ext);
                caminhoDestino = fullfile(pastaDestino, nomeDestino);
                
                % Move ou copia modelo
                if exist(arquivoModelo, 'file')
                    [sucesso_copia, msg] = copyfile(arquivoModelo, caminhoDestino);
                    if ~sucesso_copia
                        error('Erro ao copiar modelo: %s', msg);
                    end
                    
                    % Adiciona ao índice
                    obj.indiceArquivos.modelos{end+1} = struct(...
                        'original', arquivoModelo, ...
                        'organizado', nomeDestino, ...
                        'caminho', caminhoDestino, ...
                        'timestamp', datetime('now'));
                    
                    fprintf('  ✓ Modelo organizado: %s\n', nomeDestino);
                    sucesso = true;
                else
                    error('Arquivo de modelo não encontrado: %s', arquivoModelo);
                end
                
            catch ME
                fprintf('❌ Erro ao organizar modelo %s: %s\n', nomeModelo, ME.message);
                sucesso = false;
            end
        end
        
        function sucesso = criarIndiceArquivos(obj, nomeArquivo)
            % Cria arquivo de índice listando todos os arquivos processados
            %
            % Parâmetros:
            %   nomeArquivo - Nome do arquivo de índice (opcional)
            %
            % Retorna:
            %   sucesso - true se o índice foi criado com sucesso
            
            if nargin < 2 || isempty(nomeArquivo)
                nomeArquivo = 'indice_arquivos.txt';
            end
            
            try
                % Garante que a estrutura existe
                if ~obj.estruturaCriada
                    obj.criarEstruturaPastas();
                end
                
                caminhoIndice = fullfile(obj.caminhoBase, nomeArquivo);
                
                % Abre arquivo para escrita
                fid = fopen(caminhoIndice, 'w');
                if fid == -1
                    error('Não foi possível criar arquivo de índice: %s', caminhoIndice);
                end
                
                % Escreve cabeçalho
                fprintf(fid, '=== ÍNDICE DE ARQUIVOS PROCESSADOS ===\n');
                fprintf(fid, 'Gerado em: %s\n\n', char(datetime('now')));
                
                % Escreve seção U-Net
                fprintf(fid, '--- SEGMENTAÇÕES U-NET ---\n');
                fprintf(fid, 'Total de arquivos: %d\n\n', length(obj.indiceArquivos.unet));
                for i = 1:length(obj.indiceArquivos.unet)
                    item = obj.indiceArquivos.unet{i};
                    fprintf(fid, '%d. %s -> %s\n', i, item.original, item.organizado);
                    fprintf(fid, '   Caminho: %s\n', item.caminho);
                    fprintf(fid, '   Processado: %s\n\n', char(item.timestamp));
                end
                
                % Escreve seção Attention U-Net
                fprintf(fid, '--- SEGMENTAÇÕES ATTENTION U-NET ---\n');
                fprintf(fid, 'Total de arquivos: %d\n\n', length(obj.indiceArquivos.attention_unet));
                for i = 1:length(obj.indiceArquivos.attention_unet)
                    item = obj.indiceArquivos.attention_unet{i};
                    fprintf(fid, '%d. %s -> %s\n', i, item.original, item.organizado);
                    fprintf(fid, '   Caminho: %s\n', item.caminho);
                    fprintf(fid, '   Processado: %s\n\n', char(item.timestamp));
                end
                
                % Escreve seção Modelos
                fprintf(fid, '--- MODELOS TREINADOS ---\n');
                fprintf(fid, 'Total de modelos: %d\n\n', length(obj.indiceArquivos.modelos));
                for i = 1:length(obj.indiceArquivos.modelos)
                    item = obj.indiceArquivos.modelos{i};
                    fprintf(fid, '%d. %s\n', i, item.organizado);
                    fprintf(fid, '   Caminho: %s\n', item.caminho);
                    fprintf(fid, '   Salvo: %s\n\n', char(item.timestamp));
                end
                
                % Escreve resumo
                totalArquivos = length(obj.indiceArquivos.unet) + ...
                               length(obj.indiceArquivos.attention_unet) + ...
                               length(obj.indiceArquivos.modelos);
                fprintf(fid, '--- RESUMO ---\n');
                fprintf(fid, 'Total de arquivos organizados: %d\n', totalArquivos);
                fprintf(fid, '- Segmentações U-Net: %d\n', length(obj.indiceArquivos.unet));
                fprintf(fid, '- Segmentações Attention U-Net: %d\n', length(obj.indiceArquivos.attention_unet));
                fprintf(fid, '- Modelos treinados: %d\n', length(obj.indiceArquivos.modelos));
                
                fclose(fid);
                
                fprintf('✅ Índice de arquivos criado: %s\n', caminhoIndice);
                sucesso = true;
                
            catch ME
                if exist('fid', 'var') && fid ~= -1
                    fclose(fid);
                end
                fprintf('❌ Erro ao criar índice de arquivos: %s\n', ME.message);
                sucesso = false;
            end
        end
        
        function info = obterEstatisticas(obj)
            % Obtém estatísticas sobre os arquivos organizados
            %
            % Retorna:
            %   info - Estrutura com estatísticas dos arquivos
            
            info = struct();
            info.total_unet = length(obj.indiceArquivos.unet);
            info.total_attention = length(obj.indiceArquivos.attention_unet);
            info.total_modelos = length(obj.indiceArquivos.modelos);
            info.total_geral = info.total_unet + info.total_attention + info.total_modelos;
            info.estrutura_criada = obj.estruturaCriada;
            info.caminho_base = obj.caminhoBase;
        end
        
        function sucesso = recuperarDeErro(obj)
            % Tenta recuperar de erros recriando a estrutura de pastas
            %
            % Retorna:
            %   sucesso - true se a recuperação foi bem-sucedida
            
            fprintf('Tentando recuperar de erro...\n');
            
            try
                % Força recriação da estrutura
                obj.estruturaCriada = false;
                sucesso = obj.criarEstruturaPastas();
                
                if sucesso
                    fprintf('✅ Recuperação bem-sucedida!\n');
                else
                    fprintf('❌ Falha na recuperação.\n');
                end
                
            catch ME
                fprintf('❌ Erro durante recuperação: %s\n', ME.message);
                sucesso = false;
            end
        end
        
        function exibirEstrutura(obj)
            % Exibe a estrutura de pastas criada
            
            fprintf('\n=== ESTRUTURA DE RESULTADOS ===\n');
            fprintf('%s/\n', obj.caminhoBase);
            fprintf('├── %s/          (Segmentações U-Net)\n', obj.PASTA_UNET);
            fprintf('├── %s/   (Segmentações Attention U-Net)\n', obj.PASTA_ATTENTION);
            fprintf('├── %s/      (Comparações visuais)\n', obj.PASTA_COMPARACOES);
            fprintf('├── %s/       (Relatórios e métricas)\n', obj.PASTA_RELATORIOS);
            fprintf('└── %s/         (Modelos treinados)\n', obj.PASTA_MODELOS);
            
            % Mostra estatísticas se disponíveis
            if obj.estruturaCriada
                stats = obj.obterEstatisticas();
                fprintf('\n=== ESTATÍSTICAS ===\n');
                fprintf('Arquivos U-Net: %d\n', stats.total_unet);
                fprintf('Arquivos Attention U-Net: %d\n', stats.total_attention);
                fprintf('Modelos salvos: %d\n', stats.total_modelos);
                fprintf('Total de arquivos: %d\n', stats.total_geral);
            end
            fprintf('\n');
        end
    end
    
    methods (Static)
        function organizar()
            % Método estático principal para organizar todos os resultados
            % Este método cria a estrutura de pastas e organiza todos os arquivos encontrados
            
            fprintf('=== ORGANIZANDO RESULTADOS ===\n');
            
            try
                % Criar organizador padrão
                organizador = OrganizadorResultados.criarOrganizadorPadrao();
                
                % Buscar arquivos para organizar
                fprintf('Buscando arquivos para organizar...\n');
                
                % Buscar segmentações U-Net
                arquivos_unet = dir('*unet*.png');
                if ~isempty(arquivos_unet)
                    fprintf('Encontrados %d arquivos U-Net\n', length(arquivos_unet));
                    for i = 1:length(arquivos_unet)
                        organizador.organizarArquivoSegmentacao(arquivos_unet(i).name, arquivos_unet(i).name, 'unet');
                    end
                end
                
                % Buscar segmentações Attention U-Net
                arquivos_attention = dir('*attention*.png');
                if ~isempty(arquivos_attention)
                    fprintf('Encontrados %d arquivos Attention U-Net\n', length(arquivos_attention));
                    for i = 1:length(arquivos_attention)
                        organizador.organizarArquivoSegmentacao(arquivos_attention(i).name, arquivos_attention(i).name, 'attention_unet');
                    end
                end
                
                % Buscar modelos
                modelos = dir('modelo_*.mat');
                if ~isempty(modelos)
                    fprintf('Encontrados %d modelos\n', length(modelos));
                    for i = 1:length(modelos)
                        [~, nome, ~] = fileparts(modelos(i).name);
                        organizador.organizarModelo(modelos(i).name, nome);
                    end
                end
                
                % Criar índice final
                organizador.criarIndiceArquivos();
                
                fprintf('✅ Organização concluída com sucesso!\n');
                
            catch ME
                fprintf('❌ Erro durante organização: %s\n', ME.message);
                rethrow(ME);
            end
        end
        
        function organizador = criarOrganizadorPadrao()
            % Método estático para criar organizador com configuração padrão
            %
            % Retorna:
            %   organizador - Instância configurada do OrganizadorResultados
            
            organizador = OrganizadorResultados();
            organizador.criarEstruturaPastas();
        end
        
        function sucesso = organizarResultadosRapido(arquivosUNet, arquivosAttention, modelos)
            % Método estático para organização rápida de resultados
            %
            % Parâmetros:
            %   arquivosUNet - Cell array com arquivos U-Net
            %   arquivosAttention - Cell array com arquivos Attention U-Net
            %   modelos - Cell array com modelos treinados
            %
            % Retorna:
            %   sucesso - true se todos os arquivos foram organizados
            
            try
                organizador = OrganizadorResultados.criarOrganizadorPadrao();
                
                % Organiza arquivos U-Net
                if exist('arquivosUNet', 'var') && ~isempty(arquivosUNet)
                    for i = 1:length(arquivosUNet)
                        [caminho, nome, ext] = fileparts(arquivosUNet{i});
                        organizador.organizarArquivoSegmentacao(arquivosUNet{i}, [nome ext], 'unet');
                    end
                end
                
                % Organiza arquivos Attention U-Net
                if exist('arquivosAttention', 'var') && ~isempty(arquivosAttention)
                    for i = 1:length(arquivosAttention)
                        [caminho, nome, ext] = fileparts(arquivosAttention{i});
                        organizador.organizarArquivoSegmentacao(arquivosAttention{i}, [nome ext], 'attention_unet');
                    end
                end
                
                % Organiza modelos
                if exist('modelos', 'var') && ~isempty(modelos)
                    for i = 1:length(modelos)
                        [caminho, nome, ext] = fileparts(modelos{i});
                        organizador.organizarModelo(modelos{i}, nome);
                    end
                end
                
                % Cria índice
                organizador.criarIndiceArquivos();
                
                sucesso = true;
                
            catch ME
                fprintf('❌ Erro na organização rápida: %s\n', ME.message);
                sucesso = false;
            end
        end
    end
end