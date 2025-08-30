classdef GeradorReferencias < handle
    % GeradorReferencias - Sistema para gerar e gerenciar referências bibliográficas
    % 
    % Esta classe implementa funcionalidades para:
    % - Adicionar novas referências ao arquivo .bib
    % - Organizar referências por categorias
    % - Validar formato das referências
    % - Gerar referências automaticamente a partir de DOI
    % - Manter consistência e qualidade das referências
    
    properties (Access = private)
        arquivo_bib
        referencias_carregadas
        categorias_disponiveis
        template_referencias
    end
    
    methods
        function obj = GeradorReferencias(caminho_arquivo_bib)
            % Construtor da classe GeradorReferencias
            %
            % Parâmetros:
            %   caminho_arquivo_bib - Caminho para o arquivo .bib
            
            if nargin < 1
                obj.arquivo_bib = 'referencias.bib';
            else
                obj.arquivo_bib = caminho_arquivo_bib;
            end
            
            obj.referencias_carregadas = containers.Map();
            obj.inicializarCategorias();
            obj.inicializarTemplates();
            obj.carregarReferenciasExistentes();
        end
        
        function inicializarCategorias(obj)
            % Inicializa as categorias de referências disponíveis
            
            obj.categorias_disponiveis = {
                'deep_learning_cv',      % Deep Learning e Computer Vision
                'unet_arquiteturas',     % Arquiteturas U-Net e variantes
                'mecanismos_atencao',    % Mecanismos de atenção
                'deteccao_corrosao',     % Detecção de corrosão
                'materiais_astm',        % Materiais ASTM A572
                'metricas_segmentacao',  % Métricas de segmentação
                'normas_tecnicas',       % Normas e padrões técnicos
                'referencias_adicionais' % Referências adicionais
            };
        end
        
        function inicializarTemplates(obj)
            % Inicializa templates para diferentes tipos de referência
            
            obj.template_referencias = containers.Map();
            
            % Template para artigo de journal
            obj.template_referencias('article') = struct(...
                'campos_obrigatorios', {{'title', 'author', 'journal', 'year'}}, ...
                'campos_opcionais', {{'volume', 'number', 'pages', 'publisher', 'doi'}}, ...
                'formato', '@article{%s,\n  title={%s},\n  author={%s},\n  journal={%s},\n  year={%s}%s\n}');
            
            % Template para conference paper
            obj.template_referencias('inproceedings') = struct(...
                'campos_obrigatorios', {{'title', 'author', 'booktitle', 'year'}}, ...
                'campos_opcionais', {{'pages', 'organization', 'publisher', 'doi'}}, ...
                'formato', '@inproceedings{%s,\n  title={%s},\n  author={%s},\n  booktitle={%s},\n  year={%s}%s\n}');
            
            % Template para livro
            obj.template_referencias('book') = struct(...
                'campos_obrigatorios', {{'title', 'author', 'publisher', 'year'}}, ...
                'campos_opcionais', {{'volume', 'edition', 'isbn'}}, ...
                'formato', '@book{%s,\n  title={%s},\n  author={%s},\n  publisher={%s},\n  year={%s}%s\n}');
            
            % Template para padrão/norma técnica
            obj.template_referencias('misc') = struct(...
                'campos_obrigatorios', {{'title', 'author', 'year'}}, ...
                'campos_opcionais', {{'publisher', 'note', 'url'}}, ...
                'formato', '@misc{%s,\n  title={%s},\n  author={%s},\n  year={%s}%s\n}');
        end
        
        function carregarReferenciasExistentes(obj)
            % Carrega referências existentes do arquivo .bib
            
            try
                if exist(obj.arquivo_bib, 'file')
                    fid = fopen(obj.arquivo_bib, 'r');
                    conteudo = fread(fid, '*char')';
                    fclose(fid);
                    
                    % Extrair entradas existentes
                    padrao = '@(\w+)\s*\{\s*([^,\s]+)';
                    matches = regexp(conteudo, padrao, 'tokens');
                    
                    for i = 1:length(matches)
                        tipo = matches{i}{1};
                        chave = matches{i}{2};
                        obj.referencias_carregadas(chave) = tipo;
                    end
                    
                    fprintf('✓ Carregadas %d referências existentes\n', obj.referencias_carregadas.Count);
                else
                    fprintf('⚠️  Arquivo .bib não encontrado, será criado novo\n');
                end
            catch ME
                fprintf('❌ Erro ao carregar referências: %s\n', ME.message);
            end
        end
        
        function chave = adicionarReferencia(obj, tipo, dados, categoria)
            % Adiciona nova referência ao arquivo .bib
            %
            % Parâmetros:
            %   tipo - Tipo da referência (article, inproceedings, book, misc)
            %   dados - Struct com dados da referência
            %   categoria - Categoria para organização (opcional)
            %
            % Retorna:
            %   chave - Chave gerada para a referência
            
            try
                % Validar tipo
                if ~obj.template_referencias.isKey(tipo)
                    error('Tipo de referência não suportado: %s', tipo);
                end
                
                template = obj.template_referencias(tipo);
                
                % Validar campos obrigatórios
                for i = 1:length(template.campos_obrigatorios)
                    campo = template.campos_obrigatorios{i};
                    if ~isfield(dados, campo) || isempty(dados.(campo))
                        error('Campo obrigatório ausente: %s', campo);
                    end
                end
                
                % Gerar chave única
                chave = obj.gerarChaveUnica(dados);
                
                % Verificar se já existe
                if obj.referencias_carregadas.isKey(chave)
                    fprintf('⚠️  Referência já existe: %s\n', chave);
                    return;
                end
                
                % Gerar entrada BibTeX
                entrada_bibtex = obj.gerarEntradaBibtex(tipo, chave, dados, template);
                
                % Adicionar ao arquivo
                obj.adicionarAoArquivo(entrada_bibtex, categoria);
                
                % Atualizar cache
                obj.referencias_carregadas(chave) = tipo;
                
                fprintf('✅ Referência adicionada: %s\n', chave);
                
            catch ME
                fprintf('❌ Erro ao adicionar referência: %s\n', ME.message);
                chave = '';
                rethrow(ME);
            end
        end
        
        function chave = gerarChaveUnica(obj, dados)
            % Gera chave única para a referência
            %
            % Parâmetros:
            %   dados - Struct com dados da referência
            %
            % Retorna:
            %   chave - Chave única gerada
            
            % Extrair primeiro autor
            autor = dados.author;
            if contains(autor, ' and ')
                partes = strsplit(autor, ' and ');
                autor = strtrim(partes{1});
            end
            
            % Extrair sobrenome
            partes_autor = strsplit(autor, ' ');
            sobrenome = partes_autor{end};
            sobrenome = lower(regexprep(sobrenome, '[^a-zA-Z]', ''));
            
            % Extrair ano
            ano = num2str(dados.year);
            
            % Extrair primeira palavra significativa do título
            titulo = lower(dados.title);
            titulo = regexprep(titulo, '[^a-zA-Z\s]', '');
            palavras = strsplit(titulo, ' ');
            
            % Filtrar palavras comuns
            palavras_comuns = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by'};
            primeira_palavra = '';
            for i = 1:length(palavras)
                palavra = strtrim(palavras{i});
                if length(palavra) > 2 && ~ismember(palavra, palavras_comuns)
                    primeira_palavra = palavra;
                    break;
                end
            end
            
            % Gerar chave base
            chave_base = sprintf('%s%s%s', sobrenome, ano, primeira_palavra);
            chave = chave_base;
            
            % Garantir unicidade
            contador = 1;
            while obj.referencias_carregadas.isKey(chave)
                chave = sprintf('%s_%d', chave_base, contador);
                contador = contador + 1;
            end
        end
        
        function entrada = gerarEntradaBibtex(obj, tipo, chave, dados, template)
            % Gera entrada BibTeX formatada
            %
            % Parâmetros:
            %   tipo - Tipo da referência
            %   chave - Chave da referência
            %   dados - Dados da referência
            %   template - Template para o tipo
            %
            % Retorna:
            %   entrada - String com entrada BibTeX formatada
            
            % Campos obrigatórios
            campos_obrig = {};
            for i = 1:length(template.campos_obrigatorios)
                campo = template.campos_obrigatorios{i};
                campos_obrig{end+1} = dados.(campo);
            end
            
            % Campos opcionais
            campos_opcionais_str = '';
            for i = 1:length(template.campos_opcionais)
                campo = template.campos_opcionais{i};
                if isfield(dados, campo) && ~isempty(dados.(campo))
                    if strcmp(campo, 'pages')
                        campos_opcionais_str = [campos_opcionais_str, sprintf(',\n  %s={%s}', campo, dados.(campo))];
                    elseif strcmp(campo, 'volume') || strcmp(campo, 'number')
                        campos_opcionais_str = [campos_opcionais_str, sprintf(',\n  %s={%s}', campo, num2str(dados.(campo)))];
                    else
                        campos_opcionais_str = [campos_opcionais_str, sprintf(',\n  %s={%s}', campo, dados.(campo))];
                    end
                end
            end
            
            % Gerar entrada completa
            entrada = sprintf(template.formato, chave, campos_obrig{:}, campos_opcionais_str);
        end
        
        function adicionarAoArquivo(obj, entrada_bibtex, categoria)
            % Adiciona entrada ao arquivo .bib na categoria apropriada
            %
            % Parâmetros:
            %   entrada_bibtex - Entrada BibTeX formatada
            %   categoria - Categoria para organização
            
            try
                % Ler arquivo existente
                conteudo_existente = '';
                if exist(obj.arquivo_bib, 'file')
                    fid = fopen(obj.arquivo_bib, 'r');
                    conteudo_existente = fread(fid, '*char')';
                    fclose(fid);
                end
                
                % Determinar onde inserir
                if nargin > 2 && ~isempty(categoria)
                    % Inserir na categoria específica
                    conteudo_novo = obj.inserirNaCategoria(conteudo_existente, entrada_bibtex, categoria);
                else
                    % Adicionar no final
                    conteudo_novo = [conteudo_existente, sprintf('\n%s\n', entrada_bibtex)];
                end
                
                % Escrever arquivo atualizado
                fid = fopen(obj.arquivo_bib, 'w');
                fprintf(fid, '%s', conteudo_novo);
                fclose(fid);
                
            catch ME
                fprintf('❌ Erro ao escrever no arquivo: %s\n', ME.message);
                rethrow(ME);
            end
        end
        
        function conteudo_novo = inserirNaCategoria(obj, conteudo, entrada, categoria)
            % Insere entrada na categoria apropriada do arquivo .bib
            %
            % Parâmetros:
            %   conteudo - Conteúdo atual do arquivo
            %   entrada - Nova entrada a ser inserida
            %   categoria - Categoria de destino
            %
            % Retorna:
            %   conteudo_novo - Conteúdo atualizado
            
            % Mapear categoria para seção
            mapa_secoes = containers.Map();
            mapa_secoes('deep_learning_cv') = 'SEÇÃO 1: DEEP LEARNING E COMPUTER VISION';
            mapa_secoes('unet_arquiteturas') = 'SEÇÃO 2: ARQUITETURAS U-NET E VARIANTES';
            mapa_secoes('mecanismos_atencao') = 'SEÇÃO 3: MECANISMOS DE ATENÇÃO';
            mapa_secoes('deteccao_corrosao') = 'SEÇÃO 4: DETECÇÃO DE CORROSÃO E INSPEÇÃO ESTRUTURAL';
            mapa_secoes('materiais_astm') = 'SEÇÃO 5: MATERIAIS ASTM A572';
            mapa_secoes('metricas_segmentacao') = 'SEÇÃO 6: MÉTRICAS DE SEGMENTAÇÃO SEMÂNTICA';
            mapa_secoes('normas_tecnicas') = 'SEÇÃO 7: NORMAS E PADRÕES TÉCNICOS';
            mapa_secoes('referencias_adicionais') = 'REFERÊNCIAS ADICIONAIS ESPECÍFICAS';
            
            if mapa_secoes.isKey(categoria)
                nome_secao = mapa_secoes(categoria);
                
                % Procurar pela seção
                padrao_secao = sprintf('%% %s', nome_secao);
                pos_secao = strfind(conteudo, padrao_secao);
                
                if ~isempty(pos_secao)
                    % Encontrar próxima seção ou final do arquivo
                    pos_proxima_secao = strfind(conteudo(pos_secao(1):end), '% ========================================');
                    
                    if length(pos_proxima_secao) > 1
                        % Inserir antes da próxima seção
                        pos_insercao = pos_secao(1) + pos_proxima_secao(2) - 2;
                        conteudo_novo = [conteudo(1:pos_insercao), sprintf('\n%s\n', entrada), conteudo(pos_insercao+1:end)];
                    else
                        % Inserir no final da seção (final do arquivo)
                        conteudo_novo = [conteudo, sprintf('\n%s\n', entrada)];
                    end
                else
                    % Seção não encontrada, adicionar no final
                    conteudo_novo = [conteudo, sprintf('\n%s\n', entrada)];
                end
            else
                % Categoria não reconhecida, adicionar no final
                conteudo_novo = [conteudo, sprintf('\n%s\n', entrada)];
            end
        end
        
        function adicionarReferenciaCorrosao(obj, titulo, autores, journal, ano, varargin)
            % Método específico para adicionar referências sobre corrosão
            %
            % Parâmetros:
            %   titulo - Título do artigo
            %   autores - Autores (formato BibTeX)
            %   journal - Nome do journal
            %   ano - Ano de publicação
            %   varargin - Campos opcionais (volume, number, pages, doi)
            
            dados = struct();
            dados.title = titulo;
            dados.author = autores;
            dados.journal = journal;
            dados.year = ano;
            
            % Processar campos opcionais
            for i = 1:2:length(varargin)
                if i+1 <= length(varargin)
                    dados.(varargin{i}) = varargin{i+1};
                end
            end
            
            chave = obj.adicionarReferencia('article', dados, 'deteccao_corrosao');
        end
        
        function adicionarReferenciaUNet(obj, titulo, autores, venue, ano, tipo_venue, varargin)
            % Método específico para adicionar referências sobre U-Net
            %
            % Parâmetros:
            %   titulo - Título do trabalho
            %   autores - Autores (formato BibTeX)
            %   venue - Journal ou conference
            %   ano - Ano de publicação
            %   tipo_venue - 'journal' ou 'conference'
            %   varargin - Campos opcionais
            
            dados = struct();
            dados.title = titulo;
            dados.author = autores;
            dados.year = ano;
            
            if strcmp(tipo_venue, 'journal')
                dados.journal = venue;
                tipo_ref = 'article';
            else
                dados.booktitle = venue;
                tipo_ref = 'inproceedings';
            end
            
            % Processar campos opcionais
            for i = 1:2:length(varargin)
                if i+1 <= length(varargin)
                    dados.(varargin{i}) = varargin{i+1};
                end
            end
            
            chave = obj.adicionarReferencia(tipo_ref, dados, 'unet_arquiteturas');
        end
        
        function adicionarReferenciaASTM(obj, codigo_norma, titulo, organizacao, ano, varargin)
            % Método específico para adicionar normas ASTM
            %
            % Parâmetros:
            %   codigo_norma - Código da norma (ex: A572/A572M-18)
            %   titulo - Título completo da norma
            %   organizacao - Organização (ex: ASTM International)
            %   ano - Ano de publicação
            %   varargin - Campos opcionais
            
            dados = struct();
            dados.title = sprintf('%s: %s', codigo_norma, titulo);
            dados.author = organizacao;
            dados.year = ano;
            dados.publisher = organizacao;
            
            % Processar campos opcionais
            for i = 1:2:length(varargin)
                if i+1 <= length(varargin)
                    dados.(varargin{i}) = varargin{i+1};
                end
            end
            
            chave = obj.adicionarReferencia('misc', dados, 'materiais_astm');
        end
        
        function validarArquivoBib(obj)
            % Valida a estrutura e qualidade do arquivo .bib
            
            fprintf('🔍 VALIDANDO ARQUIVO .BIB\n');
            fprintf(repmat('=', 1, 40));
            fprintf('\n\n');
            
            try
                % Verificar se arquivo existe
                if ~exist(obj.arquivo_bib, 'file')
                    fprintf('❌ Arquivo .bib não encontrado: %s\n', obj.arquivo_bib);
                    return;
                end
                
                % Ler e analisar conteúdo
                fid = fopen(obj.arquivo_bib, 'r');
                conteudo = fread(fid, '*char')';
                fclose(fid);
                
                % Contar entradas por tipo
                tipos_entrada = {'@article', '@inproceedings', '@book', '@misc'};
                contadores = containers.Map();
                
                for i = 1:length(tipos_entrada)
                    tipo = tipos_entrada{i};
                    matches = regexp(conteudo, [tipo, '\s*\{'], 'match');
                    contadores(tipo) = length(matches);
                end
                
                % Verificar estrutura das seções
                secoes_esperadas = {
                    'SEÇÃO 1: DEEP LEARNING E COMPUTER VISION',
                    'SEÇÃO 2: ARQUITETURAS U-NET E VARIANTES',
                    'SEÇÃO 3: MECANISMOS DE ATENÇÃO',
                    'SEÇÃO 4: DETECÇÃO DE CORROSÃO E INSPEÇÃO ESTRUTURAL',
                    'SEÇÃO 5: MATERIAIS ASTM A572',
                    'SEÇÃO 6: MÉTRICAS DE SEGMENTAÇÃO SEMÂNTICA',
                    'SEÇÃO 7: NORMAS E PADRÕES TÉCNICOS'
                };
                
                secoes_encontradas = 0;
                for i = 1:length(secoes_esperadas)
                    if contains(conteudo, secoes_esperadas{i})
                        secoes_encontradas = secoes_encontradas + 1;
                    end
                end
                
                % Verificar campos obrigatórios
                entradas_problematicas = obj.verificarCamposObrigatorios(conteudo);
                
                % Gerar relatório
                fprintf('📊 ESTATÍSTICAS DO ARQUIVO:\n');
                fprintf('   Arquivo: %s\n', obj.arquivo_bib);
                fprintf('   Tamanho: %.1f KB\n', length(conteudo)/1024);
                fprintf('   Seções organizacionais: %d/%d encontradas\n', secoes_encontradas, length(secoes_esperadas));
                fprintf('\n📈 DISTRIBUIÇÃO POR TIPO:\n');
                
                total_entradas = 0;
                tipos_keys = keys(contadores);
                for i = 1:length(tipos_keys)
                    tipo = tipos_keys{i};
                    count = contadores(tipo);
                    total_entradas = total_entradas + count;
                    fprintf('   %s: %d entradas\n', tipo, count);
                end
                
                fprintf('\n📋 RESUMO DE QUALIDADE:\n');
                fprintf('   Total de entradas: %d\n', total_entradas);
                fprintf('   Entradas com problemas: %d\n', length(entradas_problematicas));
                
                if length(entradas_problematicas) == 0
                    fprintf('   ✅ Status: EXCELENTE - Nenhum problema encontrado\n');
                elseif length(entradas_problematicas) < total_entradas * 0.05
                    fprintf('   ✅ Status: MUITO BOM - Poucos problemas menores\n');
                elseif length(entradas_problematicas) < total_entradas * 0.1
                    fprintf('   ⚠️  Status: BOM - Alguns problemas encontrados\n');
                else
                    fprintf('   ❌ Status: NECESSITA CORREÇÃO - Muitos problemas\n');
                end
                
                % Listar problemas se houver
                if ~isempty(entradas_problematicas)
                    fprintf('\n🔧 PROBLEMAS ENCONTRADOS:\n');
                    for i = 1:length(entradas_problematicas)
                        fprintf('   - %s\n', entradas_problematicas{i});
                    end
                end
                
                fprintf('\n');
                
            catch ME
                fprintf('❌ Erro na validação: %s\n', ME.message);
            end
        end
        
        function problemas = verificarCamposObrigatorios(obj, conteudo)
            % Verifica se todas as entradas têm campos obrigatórios
            %
            % Parâmetros:
            %   conteudo - Conteúdo do arquivo .bib
            %
            % Retorna:
            %   problemas - Lista de problemas encontrados
            
            problemas = {};
            
            % Extrair todas as entradas
            padrao_entrada = '@(\w+)\s*\{\s*([^,\s]+)([^}]+)\}';
            matches = regexp(conteudo, padrao_entrada, 'tokens');
            
            for i = 1:length(matches)
                tipo = lower(matches{i}{1});
                chave = matches{i}{2};
                corpo = matches{i}{3};
                
                % Verificar campos obrigatórios por tipo
                if strcmp(tipo, 'article')
                    campos_obrig = {'title', 'author', 'journal', 'year'};
                elseif strcmp(tipo, 'inproceedings')
                    campos_obrig = {'title', 'author', 'booktitle', 'year'};
                elseif strcmp(tipo, 'book')
                    campos_obrig = {'title', 'author', 'publisher', 'year'};
                elseif strcmp(tipo, 'misc')
                    campos_obrig = {'title', 'author', 'year'};
                else
                    continue; % Tipo não reconhecido
                end
                
                % Verificar cada campo obrigatório
                for j = 1:length(campos_obrig)
                    campo = campos_obrig{j};
                    padrao_campo = sprintf('%s\\s*=\\s*\\{[^}]*\\}', campo);
                    
                    if isempty(regexp(corpo, padrao_campo, 'once'))
                        % Verificar se o campo existe de alguma forma
                        padrao_alternativo = sprintf('%s\\s*=', campo);
                        if isempty(regexp(corpo, padrao_alternativo, 'once'))
                            problemas{end+1} = sprintf('Entrada "%s": campo obrigatório "%s" ausente', chave, campo);
                        end
                    end
                end
            end
        end
        
        function gerarEstatisticas(obj)
            % Gera estatísticas detalhadas das referências
            
            fprintf('📊 ESTATÍSTICAS DETALHADAS DAS REFERÊNCIAS\n');
            fprintf('=' * ones(1, 50));
            fprintf('\n\n');
            
            % Recarregar referências
            obj.carregarReferenciasExistentes();
            
            if obj.referencias_carregadas.Count == 0
                fprintf('⚠️  Nenhuma referência carregada\n');
                return;
            end
            
            % Análise por tipo
            tipos = values(obj.referencias_carregadas);
            tipos_unicos = unique(tipos);
            
            fprintf('📈 DISTRIBUIÇÃO POR TIPO DE PUBLICAÇÃO:\n');
            for i = 1:length(tipos_unicos)
                tipo = tipos_unicos{i};
                count = sum(strcmp(tipos, tipo));
                percentual = (count / length(tipos)) * 100;
                fprintf('   %s: %d (%.1f%%)\n', tipo, count, percentual);
            end
            
            % Análise temporal (se possível extrair anos)
            fprintf('\n📅 ANÁLISE TEMPORAL:\n');
            obj.analisarDistribuicaoTemporal();
            
            % Análise de completude
            fprintf('\n🔍 ANÁLISE DE QUALIDADE:\n');
            obj.validarArquivoBib();
        end
        
        function analisarDistribuicaoTemporal(obj)
            % Analisa distribuição temporal das referências
            
            try
                % Ler arquivo para extrair anos
                fid = fopen(obj.arquivo_bib, 'r');
                conteudo = fread(fid, '*char')';
                fclose(fid);
                
                % Extrair anos
                padrao_ano = 'year\s*=\s*\{?(\d{4})\}?';
                matches = regexp(conteudo, padrao_ano, 'tokens');
                
                if isempty(matches)
                    fprintf('   ⚠️  Não foi possível extrair informações de ano\n');
                    return;
                end
                
                anos = [];
                for i = 1:length(matches)
                    anos(end+1) = str2double(matches{i}{1});
                end
                
                % Estatísticas temporais
                ano_min = min(anos);
                ano_max = max(anos);
                ano_mediano = median(anos);
                
                fprintf('   Período coberto: %d - %d\n', ano_min, ano_max);
                fprintf('   Ano mediano: %.0f\n', ano_mediano);
                
                % Distribuição por década
                decadas = floor(anos / 10) * 10;
                decadas_unicas = unique(decadas);
                
                fprintf('   Distribuição por década:\n');
                for i = 1:length(decadas_unicas)
                    decada = decadas_unicas(i);
                    count = sum(decadas == decada);
                    fprintf('     %ds: %d referências\n', decada, count);
                end
                
            catch ME
                fprintf('   ❌ Erro na análise temporal: %s\n', ME.message);
            end
        end
    end
end