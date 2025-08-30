classdef ValidadorCitacoes < handle
    % ValidadorCitacoes - Sistema de validação de citações bibliográficas
    % 
    % Esta classe implementa um sistema completo para validar citações
    % em documentos LaTeX contra um arquivo .bib de referências.
    %
    % Funcionalidades:
    % - Extração de citações de documentos LaTeX
    % - Validação contra arquivo .bib
    % - Detecção de referências quebradas
    % - Relatório de qualidade das citações
    % - Sugestões de correção
    
    properties (Access = private)
        arquivo_bib
        referencias_disponiveis
        citacoes_encontradas
        citacoes_quebradas
        relatorio_validacao
    end
    
    methods
        function obj = ValidadorCitacoes(caminho_arquivo_bib)
            % Construtor da classe ValidadorCitacoes
            %
            % Parâmetros:
            %   caminho_arquivo_bib - Caminho para o arquivo .bib
            
            if nargin < 1
                obj.arquivo_bib = 'referencias.bib';
            else
                obj.arquivo_bib = caminho_arquivo_bib;
            end
            
            obj.referencias_disponiveis = containers.Map();
            obj.citacoes_encontradas = {};
            obj.citacoes_quebradas = {};
            obj.relatorio_validacao = struct();
            
            % Carregar referências do arquivo .bib
            obj.carregarReferencias();
        end
        
        function carregarReferencias(obj)
            % Carrega todas as referências do arquivo .bib
            
            try
                if ~exist(obj.arquivo_bib, 'file')
                    error('ValidadorCitacoes:ArquivoNaoEncontrado', ...
                        'Arquivo .bib não encontrado: %s', obj.arquivo_bib);
                end
                
                % Ler arquivo .bib
                fid = fopen(obj.arquivo_bib, 'r');
                if fid == -1
                    error('ValidadorCitacoes:ErroLeitura', ...
                        'Não foi possível abrir o arquivo: %s', obj.arquivo_bib);
                end
                
                conteudo = fread(fid, '*char')';
                fclose(fid);
                
                % Extrair chaves das referências usando regex
                padrao_entrada = '@\w+\s*\{\s*([^,\s]+)';
                matches = regexp(conteudo, padrao_entrada, 'tokens');
                
                % Armazenar referências disponíveis
                obj.referencias_disponiveis = containers.Map();
                for i = 1:length(matches)
                    chave = matches{i}{1};
                    obj.referencias_disponiveis(chave) = true;
                end
                
                fprintf('✓ Carregadas %d referências do arquivo %s\n', ...
                    obj.referencias_disponiveis.Count, obj.arquivo_bib);
                
            catch ME
                fprintf('❌ Erro ao carregar referências: %s\n', ME.message);
                rethrow(ME);
            end
        end
        
        function citacoes = extrairCitacoes(obj, arquivo_latex)
            % Extrai todas as citações de um arquivo LaTeX
            %
            % Parâmetros:
            %   arquivo_latex - Caminho para o arquivo .tex
            %
            % Retorna:
            %   citacoes - Cell array com todas as citações encontradas
            
            try
                if ~exist(arquivo_latex, 'file')
                    error('ValidadorCitacoes:ArquivoTexNaoEncontrado', ...
                        'Arquivo LaTeX não encontrado: %s', arquivo_latex);
                end
                
                % Ler arquivo LaTeX
                fid = fopen(arquivo_latex, 'r');
                conteudo = fread(fid, '*char')';
                fclose(fid);
                
                % Padrões para diferentes tipos de citação
                padroes = {
                    '\\cite\{([^}]+)\}',           % \cite{key}
                    '\\citep\{([^}]+)\}',          % \citep{key}
                    '\\citet\{([^}]+)\}',          % \citet{key}
                    '\\citeauthor\{([^}]+)\}',     % \citeauthor{key}
                    '\\citeyear\{([^}]+)\}',       % \citeyear{key}
                    '\\nocite\{([^}]+)\}'          % \nocite{key}
                };
                
                citacoes_unicas = containers.Map();
                
                % Extrair citações para cada padrão
                for i = 1:length(padroes)
                    matches = regexp(conteudo, padroes{i}, 'tokens');
                    
                    for j = 1:length(matches)
                        % Separar múltiplas citações (ex: \cite{ref1,ref2,ref3})
                        chaves = strsplit(matches{j}{1}, ',');
                        
                        for k = 1:length(chaves)
                            chave = strtrim(chaves{k});
                            if ~isempty(chave)
                                citacoes_unicas(chave) = true;
                            end
                        end
                    end
                end
                
                % Converter para cell array
                citacoes = keys(citacoes_unicas);
                obj.citacoes_encontradas = citacoes;
                
                fprintf('✓ Encontradas %d citações únicas em %s\n', ...
                    length(citacoes), arquivo_latex);
                
            catch ME
                fprintf('❌ Erro ao extrair citações: %s\n', ME.message);
                citacoes = {};
                rethrow(ME);
            end
        end
        
        function [valido, relatorio] = validarCitacoes(obj, arquivo_latex)
            % Valida todas as citações de um arquivo LaTeX
            %
            % Parâmetros:
            %   arquivo_latex - Caminho para o arquivo .tex
            %
            % Retorna:
            %   valido - true se todas as citações são válidas
            %   relatorio - Estrutura com detalhes da validação
            
            try
                % Extrair citações do arquivo
                citacoes = obj.extrairCitacoes(arquivo_latex);
                
                % Verificar cada citação
                obj.citacoes_quebradas = {};
                citacoes_validas = {};
                
                for i = 1:length(citacoes)
                    citacao = citacoes{i};
                    
                    if obj.referencias_disponiveis.isKey(citacao)
                        citacoes_validas{end+1} = citacao;
                    else
                        obj.citacoes_quebradas{end+1} = citacao;
                    end
                end
                
                % Gerar relatório
                total_citacoes = length(citacoes);
                total_validas = length(citacoes_validas);
                total_quebradas = length(obj.citacoes_quebradas);
                
                relatorio = struct();
                relatorio.arquivo_latex = arquivo_latex;
                relatorio.arquivo_bib = obj.arquivo_bib;
                relatorio.total_citacoes = total_citacoes;
                relatorio.citacoes_validas = total_validas;
                relatorio.citacoes_quebradas = total_quebradas;
                relatorio.lista_citacoes_validas = citacoes_validas;
                relatorio.lista_citacoes_quebradas = obj.citacoes_quebradas;
                relatorio.percentual_validas = (total_validas / max(total_citacoes, 1)) * 100;
                relatorio.timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
                
                % Determinar se é válido (100% das citações devem ser válidas)
                valido = (total_quebradas == 0);
                
                obj.relatorio_validacao = relatorio;
                
                % Exibir resultado
                if valido
                    fprintf('✅ VALIDAÇÃO APROVADA: Todas as %d citações são válidas\n', total_citacoes);
                else
                    fprintf('❌ VALIDAÇÃO REPROVADA: %d de %d citações são inválidas (%.1f%%)\n', ...
                        total_quebradas, total_citacoes, (total_quebradas/total_citacoes)*100);
                end
                
            catch ME
                fprintf('❌ Erro na validação: %s\n', ME.message);
                valido = false;
                relatorio = struct();
                rethrow(ME);
            end
        end
        
        function gerarRelatorioDetalhado(obj, arquivo_saida)
            % Gera relatório detalhado da validação
            %
            % Parâmetros:
            %   arquivo_saida - Caminho para salvar o relatório (opcional)
            
            if isempty(obj.relatorio_validacao)
                fprintf('⚠️  Nenhuma validação foi executada ainda.\n');
                return;
            end
            
            rel = obj.relatorio_validacao;
            
            % Criar conteúdo do relatório
            relatorio_texto = sprintf([...
                '# RELATÓRIO DE VALIDAÇÃO DE CITAÇÕES BIBLIOGRÁFICAS\n\n', ...
                '**Data/Hora:** %s\n', ...
                '**Arquivo LaTeX:** %s\n', ...
                '**Arquivo .bib:** %s\n\n', ...
                '## RESUMO EXECUTIVO\n\n', ...
                '- **Total de citações encontradas:** %d\n', ...
                '- **Citações válidas:** %d (%.1f%%)\n', ...
                '- **Citações quebradas:** %d (%.1f%%)\n', ...
                '- **Status:** %s\n\n'], ...
                rel.timestamp, rel.arquivo_latex, rel.arquivo_bib, ...
                rel.total_citacoes, rel.citacoes_validas, rel.percentual_validas, ...
                rel.citacoes_quebradas, 100-rel.percentual_validas, ...
                iif(rel.citacoes_quebradas == 0, '✅ APROVADO', '❌ REPROVADO'));
            
            % Adicionar lista de citações válidas
            if ~isempty(rel.lista_citacoes_validas)
                relatorio_texto = [relatorio_texto, sprintf('## CITAÇÕES VÁLIDAS (%d)\n\n', length(rel.lista_citacoes_validas))];
                for i = 1:length(rel.lista_citacoes_validas)
                    relatorio_texto = [relatorio_texto, sprintf('- ✅ `%s`\n', rel.lista_citacoes_validas{i})];
                end
                relatorio_texto = [relatorio_texto, sprintf('\n')];
            end
            
            % Adicionar lista de citações quebradas
            if ~isempty(rel.lista_citacoes_quebradas)
                relatorio_texto = [relatorio_texto, sprintf('## CITAÇÕES QUEBRADAS (%d)\n\n', length(rel.lista_citacoes_quebradas))];
                relatorio_texto = [relatorio_texto, sprintf('⚠️  **As seguintes citações não possuem entrada correspondente no arquivo .bib:**\n\n')];
                for i = 1:length(rel.lista_citacoes_quebradas)
                    relatorio_texto = [relatorio_texto, sprintf('- ❌ `%s`\n', rel.lista_citacoes_quebradas{i})];
                end
                relatorio_texto = [relatorio_texto, sprintf('\n')];
            end
            
            % Adicionar recomendações
            relatorio_texto = [relatorio_texto, sprintf([...
                '## RECOMENDAÇÕES\n\n', ...
                '### Para Citações Quebradas:\n', ...
                '1. Verificar se a chave da citação está correta no arquivo LaTeX\n', ...
                '2. Adicionar a referência correspondente no arquivo .bib\n', ...
                '3. Verificar se não há erros de digitação nas chaves\n\n', ...
                '### Para Manutenção:\n', ...
                '1. Executar validação regularmente durante a escrita\n', ...
                '2. Usar chaves consistentes e descritivas\n', ...
                '3. Manter o arquivo .bib organizado por seções\n\n', ...
                '---\n', ...
                '*Relatório gerado automaticamente pelo ValidadorCitacoes v1.0*\n'])];
            
            % Exibir no console
            fprintf('\n%s\n', relatorio_texto);
            
            % Salvar em arquivo se especificado
            if nargin > 1 && ~isempty(arquivo_saida)
                try
                    fid = fopen(arquivo_saida, 'w');
                    fprintf(fid, '%s', relatorio_texto);
                    fclose(fid);
                    fprintf('📄 Relatório salvo em: %s\n', arquivo_saida);
                catch ME
                    fprintf('❌ Erro ao salvar relatório: %s\n', ME.message);
                end
            end
        end
        
        function sugerirCorrecoes(obj)
            % Sugere correções para citações quebradas
            
            if isempty(obj.citacoes_quebradas)
                fprintf('✅ Nenhuma correção necessária - todas as citações são válidas!\n');
                return;
            end
            
            fprintf('\n🔧 SUGESTÕES DE CORREÇÃO:\n\n');
            
            refs_disponiveis = keys(obj.referencias_disponiveis);
            
            for i = 1:length(obj.citacoes_quebradas)
                citacao_quebrada = obj.citacoes_quebradas{i};
                fprintf('❌ Citação quebrada: `%s`\n', citacao_quebrada);
                
                % Buscar referências similares
                sugestoes = obj.buscarReferenciaSimilar(citacao_quebrada, refs_disponiveis);
                
                if ~isempty(sugestoes)
                    fprintf('   💡 Sugestões:\n');
                    for j = 1:min(3, length(sugestoes))  % Máximo 3 sugestões
                        fprintf('      - %s\n', sugestoes{j});
                    end
                else
                    fprintf('   ⚠️  Nenhuma referência similar encontrada\n');
                    fprintf('   📝 Considere adicionar esta referência ao arquivo .bib\n');
                end
                fprintf('\n');
            end
        end
        
        function sugestoes = buscarReferenciaSimilar(obj, citacao, referencias)
            % Busca referências similares usando distância de edição
            %
            % Parâmetros:
            %   citacao - Citação quebrada
            %   referencias - Lista de referências disponíveis
            %
            % Retorna:
            %   sugestoes - Cell array com referências similares
            
            sugestoes = {};
            distancias = [];
            
            for i = 1:length(referencias)
                ref = referencias{i};
                dist = obj.calcularDistanciaEdicao(lower(citacao), lower(ref));
                
                % Considerar similar se a distância for pequena
                if dist <= max(2, length(citacao) * 0.3)
                    sugestoes{end+1} = ref;
                    distancias(end+1) = dist;
                end
            end
            
            % Ordenar por distância (mais similar primeiro)
            if ~isempty(distancias)
                [~, idx] = sort(distancias);
                sugestoes = sugestoes(idx);
            end
        end
        
        function dist = calcularDistanciaEdicao(obj, str1, str2)
            % Calcula distância de edição (Levenshtein) entre duas strings
            %
            % Parâmetros:
            %   str1, str2 - Strings para comparar
            %
            % Retorna:
            %   dist - Distância de edição
            
            m = length(str1);
            n = length(str2);
            
            % Matriz de programação dinâmica
            dp = zeros(m+1, n+1);
            
            % Inicializar primeira linha e coluna
            for i = 1:m+1
                dp(i, 1) = i-1;
            end
            for j = 1:n+1
                dp(1, j) = j-1;
            end
            
            % Preencher matriz
            for i = 2:m+1
                for j = 2:n+1
                    if str1(i-1) == str2(j-1)
                        dp(i, j) = dp(i-1, j-1);
                    else
                        dp(i, j) = 1 + min([dp(i-1, j), dp(i, j-1), dp(i-1, j-1)]);
                    end
                end
            end
            
            dist = dp(m+1, n+1);
        end
        
        function estatisticas = obterEstatisticas(obj)
            % Obtém estatísticas das referências carregadas
            %
            % Retorna:
            %   estatisticas - Estrutura com estatísticas do arquivo .bib
            
            estatisticas = struct();
            estatisticas.total_referencias = obj.referencias_disponiveis.Count;
            estatisticas.arquivo_bib = obj.arquivo_bib;
            
            if obj.referencias_disponiveis.Count > 0
                refs = keys(obj.referencias_disponiveis);
                
                % Analisar tipos de referência por prefixo
                tipos = containers.Map();
                for i = 1:length(refs)
                    ref = refs{i};
                    % Extrair possível prefixo (até primeiro número ou underscore)
                    prefixo = regexp(ref, '^[a-zA-Z]+', 'match', 'once');
                    if ~isempty(prefixo)
                        if tipos.isKey(prefixo)
                            tipos(prefixo) = tipos(prefixo) + 1;
                        else
                            tipos(prefixo) = 1;
                        end
                    end
                end
                
                estatisticas.tipos_referencia = tipos;
            end
            
            fprintf('📊 ESTATÍSTICAS DO ARQUIVO .BIB:\n');
            fprintf('   Total de referências: %d\n', estatisticas.total_referencias);
            fprintf('   Arquivo: %s\n', estatisticas.arquivo_bib);
            
            if isfield(estatisticas, 'tipos_referencia') && ~isempty(estatisticas.tipos_referencia)
                fprintf('   Distribuição por tipo:\n');
                tipos_keys = keys(estatisticas.tipos_referencia);
                for i = 1:length(tipos_keys)
                    tipo = tipos_keys{i};
                    count = estatisticas.tipos_referencia(tipo);
                    fprintf('     - %s: %d referências\n', tipo, count);
                end
            end
        end
        
        function resultado = validar_citacoes_completas(obj, arquivo_tex, arquivo_bib)
            % Método para validação completa de citações (compatibilidade com validador final)
            %
            % Parâmetros:
            %   arquivo_tex - Caminho para arquivo LaTeX
            %   arquivo_bib - Caminho para arquivo .bib (opcional, usa o configurado)
            %
            % Retorna:
            %   resultado - Estrutura com resultados da validação completa
            
            if nargin >= 3 && ~isempty(arquivo_bib)
                obj.arquivo_bib = arquivo_bib;
                obj.carregarReferencias();
            end
            
            % Executar validação completa
            resultado_validacao = obj.validarCitacoes(arquivo_tex);
            
            % Converter para formato esperado pelo validador final
            resultado = struct();
            resultado.total_citacoes = length(obj.citacoes_encontradas);
            resultado.total_referencias = obj.referencias_disponiveis.Count;
            resultado.citacoes_quebradas = obj.citacoes_quebradas;
            
            % Encontrar referências não citadas
            refs_disponiveis = keys(obj.referencias_disponiveis);
            resultado.referencias_nao_citadas = {};
            
            for i = 1:length(refs_disponiveis)
                ref = refs_disponiveis{i};
                if ~ismember(ref, obj.citacoes_encontradas)
                    resultado.referencias_nao_citadas{end+1} = ref;
                end
            end
            
            % Status de integridade
            resultado.integridade_ok = isempty(obj.citacoes_quebradas);
            resultado.percentual_integridade = ((resultado.total_citacoes - length(obj.citacoes_quebradas)) / max(1, resultado.total_citacoes)) * 100;
            
            % Adicionar detalhes do resultado original
            resultado.detalhes_validacao = resultado_validacao;
            resultado.timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
            
            fprintf('✅ Validação completa de citações concluída\n');
            fprintf('   Citações: %d | Referências: %d | Quebradas: %d\n', ...
                resultado.total_citacoes, resultado.total_referencias, length(resultado.citacoes_quebradas));
        end
    end
end

% Função auxiliar para operador ternário
function result = iif(condition, true_value, false_value)
    if condition
        result = true_value;
    else
        result = false_value;
    end
end