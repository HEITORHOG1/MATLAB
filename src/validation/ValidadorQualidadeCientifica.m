classdef ValidadorQualidadeCientifica < handle
    % ValidadorQualidadeCientifica - Sistema de validação de qualidade científica I-R-B-MB-E
    % 
    % Este sistema implementa validação automatizada para artigos científicos
    % seguindo critérios de qualidade I-R-B-MB-E (Insuficiente, Regular, Bom, Muito Bom, Excelente)
    % e estrutura IMRAD (Introdução, Metodologia, Resultados, Análise, Discussão)
    
    properties (Access = private)
        criterios_imrad
        criterios_qualidade
        relatorio_validacao
        arquivo_artigo
        arquivo_referencias
    end
    
    methods
        function obj = ValidadorQualidadeCientifica()
            % Construtor - inicializa critérios de validação
            obj.inicializar_criterios();
            obj.relatorio_validacao = struct();
        end
        
        function resultado = validar_artigo_completo(obj, arquivo_tex, arquivo_bib)
            % Valida artigo científico completo
            % 
            % Inputs:
            %   arquivo_tex - Caminho para arquivo LaTeX do artigo
            %   arquivo_bib - Caminho para arquivo de referências bibliográficas
            %
            % Output:
            %   resultado - Estrutura com resultados da validação
            
            try
                fprintf('=== INICIANDO VALIDAÇÃO DE QUALIDADE CIENTÍFICA ===\n');
                
                obj.arquivo_artigo = arquivo_tex;
                obj.arquivo_referencias = arquivo_bib;
                
                % 1. Validar estrutura IMRAD
                fprintf('1. Validando estrutura IMRAD...\n');
                resultado_imrad = obj.validar_estrutura_imrad();
                
                % 2. Validar qualidade por seção (I-R-B-MB-E)
                fprintf('2. Validando qualidade por seção...\n');
                resultado_qualidade = obj.validar_qualidade_secoes();
                
                % 3. Verificar integridade de referências
                fprintf('3. Verificando integridade de referências...\n');
                resultado_referencias = obj.verificar_referencias_bibliograficas();
                
                % 4. Gerar relatório consolidado
                fprintf('4. Gerando relatório de qualidade...\n');
                resultado = obj.gerar_relatorio_qualidade(resultado_imrad, ...
                    resultado_qualidade, resultado_referencias);
                
                fprintf('=== VALIDAÇÃO CONCLUÍDA ===\n');
                
            catch ME
                fprintf('ERRO na validação: %s\n', ME.message);
                resultado = obj.criar_resultado_erro(ME);
            end
        end
        
        function resultado = validar_estrutura_imrad(obj)
            % Valida se o artigo segue a estrutura IMRAD
            
            resultado = struct();
            resultado.secoes_encontradas = {};
            resultado.secoes_ausentes = {};
            resultado.estrutura_valida = false;
            resultado.pontuacao = 0;
            
            try
                % Ler conteúdo do artigo
                conteudo = obj.ler_arquivo_artigo();
                
                % Verificar seções obrigatórias IMRAD
                secoes_obrigatorias = obj.criterios_imrad.secoes_obrigatorias;
                
                for i = 1:length(secoes_obrigatorias)
                    secao = secoes_obrigatorias{i};
                    if obj.verificar_secao_presente(conteudo, secao)
                        resultado.secoes_encontradas{end+1} = secao;
                        resultado.pontuacao = resultado.pontuacao + 1;
                    else
                        resultado.secoes_ausentes{end+1} = secao;
                    end
                end
                
                % Determinar se estrutura é válida
                resultado.estrutura_valida = isempty(resultado.secoes_ausentes);
                resultado.percentual_completude = (resultado.pontuacao / length(secoes_obrigatorias)) * 100;
                
                fprintf('  - Seções encontradas: %d/%d\n', resultado.pontuacao, length(secoes_obrigatorias));
                fprintf('  - Completude: %.1f%%\n', resultado.percentual_completude);
                
            catch ME
                fprintf('  ERRO na validação IMRAD: %s\n', ME.message);
                resultado.erro = ME.message;
            end
        end
        
        function resultado = validar_qualidade_secoes(obj)
            % Valida qualidade de cada seção usando critérios I-R-B-MB-E
            
            resultado = struct();
            resultado.avaliacoes_secoes = struct();
            resultado.qualidade_geral = 'I';
            resultado.pontuacao_total = 0;
            
            try
                conteudo = obj.ler_arquivo_artigo();
                secoes = fieldnames(obj.criterios_qualidade);
                
                for i = 1:length(secoes)
                    secao = secoes{i};
                    fprintf('  - Avaliando seção: %s\n', secao);
                    
                    avaliacao = obj.avaliar_qualidade_secao(conteudo, secao);
                    resultado.avaliacoes_secoes.(secao) = avaliacao;
                    resultado.pontuacao_total = resultado.pontuacao_total + avaliacao.pontuacao_numerica;
                end
                
                % Calcular qualidade geral
                pontuacao_media = resultado.pontuacao_total / length(secoes);
                resultado.qualidade_geral = obj.converter_pontuacao_para_nivel(pontuacao_media);
                resultado.pontuacao_media = pontuacao_media;
                
                fprintf('  - Qualidade geral: %s (%.1f pontos)\n', resultado.qualidade_geral, pontuacao_media);
                
            catch ME
                fprintf('  ERRO na validação de qualidade: %s\n', ME.message);
                resultado.erro = ME.message;
            end
        end
        
        function resultado = verificar_referencias_bibliograficas(obj)
            % Verifica integridade das referências bibliográficas
            
            resultado = struct();
            resultado.citacoes_encontradas = {};
            resultado.citacoes_quebradas = {};
            resultado.referencias_nao_citadas = {};
            resultado.integridade_ok = false;
            
            try
                % Extrair citações do artigo
                conteudo_artigo = obj.ler_arquivo_artigo();
                resultado.citacoes_encontradas = obj.extrair_citacoes(conteudo_artigo);
                
                % Carregar referências do arquivo .bib
                referencias_disponiveis = obj.carregar_referencias_bib();
                
                % Verificar citações quebradas
                for i = 1:length(resultado.citacoes_encontradas)
                    citacao = resultado.citacoes_encontradas{i};
                    if ~ismember(citacao, referencias_disponiveis)
                        resultado.citacoes_quebradas{end+1} = citacao;
                    end
                end
                
                % Verificar referências não citadas
                for i = 1:length(referencias_disponiveis)
                    ref = referencias_disponiveis{i};
                    if ~ismember(ref, resultado.citacoes_encontradas)
                        resultado.referencias_nao_citadas{end+1} = ref;
                    end
                end
                
                % Determinar integridade
                resultado.integridade_ok = isempty(resultado.citacoes_quebradas);
                resultado.total_citacoes = length(resultado.citacoes_encontradas);
                resultado.total_referencias = length(referencias_disponiveis);
                
                fprintf('  - Citações encontradas: %d\n', resultado.total_citacoes);
                fprintf('  - Referências disponíveis: %d\n', resultado.total_referencias);
                fprintf('  - Citações quebradas: %d\n', length(resultado.citacoes_quebradas));
                fprintf('  - Integridade: %s\n', obj.bool_para_texto(resultado.integridade_ok));
                
            catch ME
                fprintf('  ERRO na verificação de referências: %s\n', ME.message);
                resultado.erro = ME.message;
            end
        end
        
        function resultado_final = gerar_relatorio_qualidade(obj, resultado_imrad, resultado_qualidade, resultado_referencias)
            % Gera relatório consolidado de qualidade científica
            
            resultado_final = struct();
            resultado_final.timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
            resultado_final.arquivo_artigo = obj.arquivo_artigo;
            resultado_final.arquivo_referencias = obj.arquivo_referencias;
            
            % Consolidar resultados
            resultado_final.imrad = resultado_imrad;
            resultado_final.qualidade = resultado_qualidade;
            resultado_final.referencias = resultado_referencias;
            
            % Calcular pontuação geral
            pontuacao_imrad = resultado_imrad.percentual_completude / 100 * 5;
            pontuacao_qualidade = resultado_qualidade.pontuacao_media;
            pontuacao_referencias = resultado_referencias.integridade_ok * 5;
            
            resultado_final.pontuacao_geral = (pontuacao_imrad + pontuacao_qualidade + pontuacao_referencias) / 3;
            resultado_final.nivel_geral = obj.converter_pontuacao_para_nivel(resultado_final.pontuacao_geral);
            
            % Gerar recomendações
            resultado_final.recomendacoes = obj.gerar_recomendacoes(resultado_imrad, resultado_qualidade, resultado_referencias);
            
            % Salvar relatório
            obj.salvar_relatorio(resultado_final);
            
            % Exibir resumo
            obj.exibir_resumo_validacao(resultado_final);
        end
        
        function nivel = converter_pontuacao_para_nivel(obj, pontuacao)
            % Converte pontuação numérica para nível I-R-B-MB-E
            % Método público para permitir testes
            
            if pontuacao >= 4.5
                nivel = 'E';  % Excelente
            elseif pontuacao >= 3.5
                nivel = 'MB'; % Muito Bom
            elseif pontuacao >= 2.5
                nivel = 'B';  % Bom
            elseif pontuacao >= 1.5
                nivel = 'R';  % Regular
            else
                nivel = 'I';  % Insuficiente
            end
        end
    end
    
    methods (Access = private)
        function inicializar_criterios(obj)
            % Inicializa critérios de validação IMRAD e I-R-B-MB-E
            
            % Critérios IMRAD
            obj.criterios_imrad = struct();
            obj.criterios_imrad.secoes_obrigatorias = {
                'introducao', 'metodologia', 'resultados', 'discussao', 'conclusoes', 'referencias'
            };
            
            % Critérios de qualidade I-R-B-MB-E por seção
            obj.criterios_qualidade = struct();
            
            % Critérios para Introdução
            obj.criterios_qualidade.introducao = {
                'contextualizacao', 'problema', 'objetivo', 'justificativa', 'relevancia'
            };
            
            % Critérios para Metodologia
            obj.criterios_qualidade.metodologia = {
                'reproducibilidade', 'detalhamento', 'materiais', 'procedimentos', 'metricas'
            };
            
            % Critérios para Resultados
            obj.criterios_qualidade.resultados = {
                'dados_concretos', 'evidencias', 'analise_estatistica', 'visualizacoes', 'objetividade'
            };
            
            % Critérios para Discussão
            obj.criterios_qualidade.discussao = {
                'interpretacao', 'limitacoes', 'implicacoes', 'trabalhos_futuros', 'conexao_objetivos'
            };
            
            % Critérios para Conclusões
            obj.criterios_qualidade.conclusoes = {
                'resposta_objetivos', 'sintese', 'contribuicoes', 'limitacoes_resumo', 'recomendacoes'
            };
        end
        
        function conteudo = ler_arquivo_artigo(obj)
            % Lê conteúdo do arquivo LaTeX do artigo
            
            if ~exist(obj.arquivo_artigo, 'file')
                error('Arquivo do artigo não encontrado: %s', obj.arquivo_artigo);
            end
            
            fid = fopen(obj.arquivo_artigo, 'r', 'n', 'UTF-8');
            if fid == -1
                error('Não foi possível abrir o arquivo: %s', obj.arquivo_artigo);
            end
            
            conteudo = fread(fid, '*char')';
            fclose(fid);
        end
        
        function presente = verificar_secao_presente(obj, conteudo, secao)
            % Verifica se uma seção está presente no conteúdo
            
            % Mapeamento de seções para padrões em português e inglês
            mapeamento_secoes = containers.Map();
            mapeamento_secoes('introducao') = {'Introdução', 'Introduction', 'introducao'};
            mapeamento_secoes('metodologia') = {'Metodologia', 'Methodology', 'Methods', 'metodologia'};
            mapeamento_secoes('resultados') = {'Resultados', 'Results', 'resultados'};
            mapeamento_secoes('discussao') = {'Discussão', 'Discussion', 'discussao'};
            mapeamento_secoes('conclusoes') = {'Conclusões', 'Conclusions', 'Conclusão', 'conclusoes'};
            mapeamento_secoes('referencias') = {'Referências', 'References', 'Bibliografia', 'referencias'};
            
            % Obter variações da seção
            if mapeamento_secoes.isKey(secao)
                variacoes = mapeamento_secoes(secao);
            else
                variacoes = {secao};
            end
            
            presente = false;
            
            % Verificar cada variação
            for i = 1:length(variacoes)
                variacao = variacoes{i};
                
                % Padrões LaTeX para seções (escapar caracteres especiais)
                variacao_escaped = regexprep(variacao, '([.*+?^${}()|[\]\\])', '\\$1');
                
                padroes = {
                    sprintf('\\\\section\\{[^}]*%s[^}]*\\}', variacao_escaped),
                    sprintf('\\\\subsection\\{[^}]*%s[^}]*\\}', variacao_escaped),
                    sprintf('\\\\chapter\\{[^}]*%s[^}]*\\}', variacao_escaped),
                    sprintf('\\\\section\\{%s\\}', variacao_escaped),
                    sprintf('\\\\subsection\\{%s\\}', variacao_escaped)
                };
                
                for j = 1:length(padroes)
                    if ~isempty(regexp(conteudo, padroes{j}, 'ignorecase'))
                        presente = true;
                        return;
                    end
                end
            end
        end
        
        function avaliacao = avaliar_qualidade_secao(obj, conteudo, secao)
            % Avalia qualidade de uma seção específica
            
            avaliacao = struct();
            avaliacao.secao = secao;
            avaliacao.criterios_atendidos = {};
            avaliacao.criterios_nao_atendidos = {};
            avaliacao.pontuacao = 0;
            avaliacao.feedback = {};
            
            if isfield(obj.criterios_qualidade, secao)
                criterios = obj.criterios_qualidade.(secao);
                
                for i = 1:length(criterios)
                    criterio = criterios{i};
                    if obj.verificar_criterio_atendido(conteudo, secao, criterio)
                        avaliacao.criterios_atendidos{end+1} = criterio;
                        avaliacao.pontuacao = avaliacao.pontuacao + 1;
                    else
                        avaliacao.criterios_nao_atendidos{end+1} = criterio;
                        avaliacao.feedback{end+1} = sprintf('Critério não atendido: %s', criterio);
                    end
                end
                
                % Converter para pontuação 0-5
                avaliacao.pontuacao_numerica = (avaliacao.pontuacao / length(criterios)) * 5;
                avaliacao.nivel_qualidade = obj.converter_pontuacao_para_nivel(avaliacao.pontuacao_numerica);
            else
                avaliacao.erro = sprintf('Critérios não definidos para seção: %s', secao);
                avaliacao.pontuacao_numerica = 0;
                avaliacao.nivel_qualidade = 'I';
            end
        end
        
        function atendido = verificar_criterio_atendido(obj, conteudo, secao, criterio)
            % Verifica se um critério específico é atendido na seção
            
            % Palavras-chave por critério
            palavras_chave = obj.obter_palavras_chave_criterio(criterio);
            
            % Extrair conteúdo da seção
            conteudo_secao = obj.extrair_conteudo_secao(conteudo, secao);
            
            % Verificar presença das palavras-chave
            atendido = false;
            for i = 1:length(palavras_chave)
                if contains(lower(conteudo_secao), lower(palavras_chave{i}))
                    atendido = true;
                    break;
                end
            end
        end
        
        function palavras = obter_palavras_chave_criterio(obj, criterio)
            % Retorna palavras-chave para verificação de critérios (expandidas para maior robustez)
            
            switch lower(criterio)
                case 'contextualizacao'
                    palavras = {'contexto', 'background', 'situação', 'cenário', 'corrosão', 'estruturas', 'aço', 'inspeção', 'engenharia', 'civil'};
                case 'problema'
                    palavras = {'problema', 'questão', 'desafio', 'lacuna', 'limitações', 'dificuldades', 'subjetividade', 'custos', 'detecção'};
                case 'objetivo'
                    palavras = {'objetivo', 'meta', 'propósito', 'finalidade', 'desenvolver', 'avaliar', 'comparar', 'estabelecer', 'analisar'};
                case 'justificativa'
                    palavras = {'justificativa', 'importância', 'relevância', 'necessidade', 'significativo', 'crítico', 'essencial', 'fundamental'};
                case 'relevancia'
                    palavras = {'relevância', 'importância', 'significância', 'impacto', 'contribuição', 'avanço', 'inovação', 'aplicação'};
                case 'reproducibilidade'
                    palavras = {'reprodução', 'replicação', 'procedimento', 'protocolo', 'metodologia', 'dataset', 'configuração', 'parâmetros'};
                case 'detalhamento'
                    palavras = {'detalhamento', 'detalhes', 'especificação', 'descrição', 'procedimentos', 'passos', 'etapas'};
                case 'materiais'
                    palavras = {'materiais', 'equipamentos', 'hardware', 'software', 'ferramentas', 'recursos'};
                case 'procedimentos'
                    palavras = {'procedimentos', 'métodos', 'técnicas', 'processos', 'algoritmos', 'implementação'};
                case 'metricas'
                    palavras = {'métricas', 'medidas', 'indicadores', 'critérios', 'avaliação', 'IoU', 'Dice', 'F1-Score'};
                case 'dados_concretos'
                    palavras = {'dados', 'resultados', 'valores', 'medições', 'números', 'estatísticas', 'performance'};
                case 'evidencias'
                    palavras = {'evidência', 'prova', 'demonstração', 'comprovação', 'validação', 'confirmação'};
                case 'analise_estatistica'
                    palavras = {'análise', 'estatística', 'teste', 'significância', 'p-valor', 'confiança', 'Cohen'};
                case 'visualizacoes'
                    palavras = {'visualizações', 'figuras', 'gráficos', 'tabelas', 'imagens', 'plots'};
                case 'objetividade'
                    palavras = {'objetividade', 'objetivos', 'quantitativo', 'mensurável', 'preciso', 'específico'};
                case 'interpretacao'
                    palavras = {'interpretação', 'análise', 'discussão', 'explicação', 'significado', 'implicações'};
                case 'limitacoes'
                    palavras = {'limitação', 'restrição', 'constraint', 'limitado', 'desafios', 'dificuldades'};
                case 'implicacoes'
                    palavras = {'implicações', 'consequências', 'impactos', 'aplicações', 'práticas', 'uso'};
                case 'trabalhos_futuros'
                    palavras = {'futuros', 'futuras', 'próximos', 'continuidade', 'extensão', 'melhorias'};
                case 'conexao_objetivos'
                    palavras = {'objetivos', 'metas', 'propósitos', 'alcançados', 'atingidos', 'cumpridos'};
                case 'resposta_objetivos'
                    palavras = {'objetivos', 'respondidos', 'alcançados', 'atingidos', 'cumpridos', 'satisfeitos'};
                case 'sintese'
                    palavras = {'síntese', 'resumo', 'sumário', 'consolidação', 'principais', 'conclusões'};
                case 'contribuicoes'
                    palavras = {'contribuições', 'avanços', 'inovações', 'melhorias', 'benefícios', 'vantagens'};
                case 'limitacoes_resumo'
                    palavras = {'limitações', 'restrições', 'constraints', 'desafios', 'dificuldades', 'problemas'};
                case 'recomendacoes'
                    palavras = {'recomendações', 'sugestões', 'diretrizes', 'orientações', 'propostas', 'indicações'};
                otherwise
                    palavras = {criterio};
            end
        end
        
        function conteudo_secao = extrair_conteudo_secao(obj, conteudo, secao)
            % Extrai conteúdo de uma seção específica
            
            % Padrão para início da seção
            padrao_inicio = sprintf('\\\\section\\{[^}]*%s[^}]*\\}', secao);
            
            % Encontrar início da seção
            inicio = regexp(conteudo, padrao_inicio, 'ignorecase');
            
            if isempty(inicio)
                conteudo_secao = '';
                return;
            end
            
            % Encontrar próxima seção
            padrao_proxima = '\\section\{';
            proximas = regexp(conteudo(inicio(1)+1:end), padrao_proxima);
            
            if isempty(proximas)
                conteudo_secao = conteudo(inicio(1):end);
            else
                fim = inicio(1) + proximas(1);
                conteudo_secao = conteudo(inicio(1):fim-1);
            end
        end
        
        function citacoes = extrair_citacoes(obj, conteudo)
            % Extrai citações do conteúdo LaTeX
            
            % Padrões para citações LaTeX
            padroes = {
                '\\cite\{([^}]+)\}',
                '\\citep\{([^}]+)\}',
                '\\citet\{([^}]+)\}',
                '\\ref\{([^}]+)\}'
            };
            
            citacoes = {};
            for i = 1:length(padroes)
                matches = regexp(conteudo, padroes{i}, 'tokens');
                for j = 1:length(matches)
                    % Separar múltiplas citações
                    cits = strsplit(matches{j}{1}, ',');
                    for k = 1:length(cits)
                        citacao = strtrim(cits{k});
                        if ~ismember(citacao, citacoes)
                            citacoes{end+1} = citacao;
                        end
                    end
                end
            end
        end
        
        function referencias = carregar_referencias_bib(obj)
            % Carrega referências do arquivo .bib
            
            referencias = {};
            
            if ~exist(obj.arquivo_referencias, 'file')
                warning('Arquivo de referências não encontrado: %s', obj.arquivo_referencias);
                return;
            end
            
            fid = fopen(obj.arquivo_referencias, 'r', 'n', 'UTF-8');
            if fid == -1
                warning('Não foi possível abrir arquivo de referências: %s', obj.arquivo_referencias);
                return;
            end
            
            conteudo = fread(fid, '*char')';
            fclose(fid);
            
            % Extrair chaves das entradas bibliográficas
            padrao = '@\w+\{([^,\s]+)';
            matches = regexp(conteudo, padrao, 'tokens');
            
            for i = 1:length(matches)
                referencias{end+1} = matches{i}{1};
            end
        end
        
        function recomendacoes = gerar_recomendacoes(obj, resultado_imrad, resultado_qualidade, resultado_referencias)
            % Gera recomendações para melhoria da qualidade
            
            recomendacoes = {};
            
            % Recomendações IMRAD
            if ~resultado_imrad.estrutura_valida
                recomendacoes{end+1} = 'Completar seções IMRAD ausentes';
                for i = 1:length(resultado_imrad.secoes_ausentes)
                    recomendacoes{end+1} = sprintf('  - Adicionar seção: %s', resultado_imrad.secoes_ausentes{i});
                end
            end
            
            % Recomendações de qualidade
            if resultado_qualidade.pontuacao_media < 3.5
                recomendacoes{end+1} = 'Melhorar qualidade das seções:';
                secoes = fieldnames(resultado_qualidade.avaliacoes_secoes);
                for i = 1:length(secoes)
                    secao = secoes{i};
                    avaliacao = resultado_qualidade.avaliacoes_secoes.(secao);
                    if avaliacao.pontuacao_numerica < 3.5
                        recomendacoes{end+1} = sprintf('  - %s (nível %s)', secao, avaliacao.nivel_qualidade);
                    end
                end
            end
            
            % Recomendações de referências
            if ~resultado_referencias.integridade_ok
                recomendacoes{end+1} = 'Corrigir problemas de referências:';
                for i = 1:length(resultado_referencias.citacoes_quebradas)
                    recomendacoes{end+1} = sprintf('  - Adicionar referência: %s', resultado_referencias.citacoes_quebradas{i});
                end
            end
            
            if isempty(recomendacoes)
                recomendacoes{1} = 'Artigo atende aos critérios de qualidade científica!';
            end
        end
        
        function salvar_relatorio(obj, resultado)
            % Salva relatório de validação em arquivo
            
            nome_arquivo = sprintf('relatorio_validacao_qualidade_%s.txt', datestr(now, 'yyyymmdd_HHMMSS'));
            
            fid = fopen(nome_arquivo, 'w', 'n', 'UTF-8');
            if fid == -1
                warning('Não foi possível salvar relatório: %s', nome_arquivo);
                return;
            end
            
            fprintf(fid, '=== RELATÓRIO DE VALIDAÇÃO DE QUALIDADE CIENTÍFICA ===\n\n');
            fprintf(fid, 'Data/Hora: %s\n', resultado.timestamp);
            fprintf(fid, 'Arquivo do artigo: %s\n', resultado.arquivo_artigo);
            fprintf(fid, 'Arquivo de referências: %s\n\n', resultado.arquivo_referencias);
            
            fprintf(fid, '--- AVALIAÇÃO GERAL ---\n');
            fprintf(fid, 'Nível de qualidade: %s\n', resultado.nivel_geral);
            fprintf(fid, 'Pontuação geral: %.2f/5.0\n\n', resultado.pontuacao_geral);
            
            fprintf(fid, '--- ESTRUTURA IMRAD ---\n');
            fprintf(fid, 'Estrutura válida: %s\n', obj.bool_para_texto(resultado.imrad.estrutura_valida));
            fprintf(fid, 'Completude: %.1f%%\n', resultado.imrad.percentual_completude);
            fprintf(fid, 'Seções encontradas: %s\n', strjoin(resultado.imrad.secoes_encontradas, ', '));
            if ~isempty(resultado.imrad.secoes_ausentes)
                fprintf(fid, 'Seções ausentes: %s\n', strjoin(resultado.imrad.secoes_ausentes, ', '));
            end
            fprintf(fid, '\n');
            
            fprintf(fid, '--- QUALIDADE POR SEÇÃO ---\n');
            fprintf(fid, 'Qualidade geral: %s (%.2f pontos)\n', resultado.qualidade.qualidade_geral, resultado.qualidade.pontuacao_media);
            secoes = fieldnames(resultado.qualidade.avaliacoes_secoes);
            for i = 1:length(secoes)
                secao = secoes{i};
                avaliacao = resultado.qualidade.avaliacoes_secoes.(secao);
                fprintf(fid, '  %s: %s (%.2f pontos)\n', secao, avaliacao.nivel_qualidade, avaliacao.pontuacao_numerica);
            end
            fprintf(fid, '\n');
            
            fprintf(fid, '--- REFERÊNCIAS BIBLIOGRÁFICAS ---\n');
            fprintf(fid, 'Integridade: %s\n', obj.bool_para_texto(resultado.referencias.integridade_ok));
            fprintf(fid, 'Total de citações: %d\n', resultado.referencias.total_citacoes);
            fprintf(fid, 'Total de referências: %d\n', resultado.referencias.total_referencias);
            fprintf(fid, 'Citações quebradas: %d\n', length(resultado.referencias.citacoes_quebradas));
            if ~isempty(resultado.referencias.citacoes_quebradas)
                fprintf(fid, 'Lista de citações quebradas: %s\n', strjoin(resultado.referencias.citacoes_quebradas, ', '));
            end
            fprintf(fid, '\n');
            
            fprintf(fid, '--- RECOMENDAÇÕES ---\n');
            for i = 1:length(resultado.recomendacoes)
                fprintf(fid, '%s\n', resultado.recomendacoes{i});
            end
            
            fclose(fid);
            fprintf('Relatório salvo em: %s\n', nome_arquivo);
        end
        
        function exibir_resumo_validacao(obj, resultado)
            % Exibe resumo da validação no console
            
            fprintf('\n=== RESUMO DA VALIDAÇÃO ===\n');
            fprintf('Nível geral de qualidade: %s (%.2f/5.0)\n', resultado.nivel_geral, resultado.pontuacao_geral);
            fprintf('Estrutura IMRAD: %s (%.1f%% completa)\n', obj.bool_para_texto(resultado.imrad.estrutura_valida), resultado.imrad.percentual_completude);
            fprintf('Qualidade das seções: %s (%.2f pontos)\n', resultado.qualidade.qualidade_geral, resultado.qualidade.pontuacao_media);
            fprintf('Integridade das referências: %s\n', obj.bool_para_texto(resultado.referencias.integridade_ok));
            
            if length(resultado.recomendacoes) > 1 || ~contains(resultado.recomendacoes{1}, 'atende aos critérios')
                fprintf('\nRecomendações principais:\n');
                for i = 1:min(3, length(resultado.recomendacoes))
                    fprintf('  - %s\n', resultado.recomendacoes{i});
                end
            else
                fprintf('\n✓ Artigo atende aos critérios de qualidade científica!\n');
            end
            fprintf('========================\n\n');
        end
        
        function texto = bool_para_texto(obj, valor)
            % Converte valor booleano para texto
            if valor
                texto = 'SIM';
            else
                texto = 'NÃO';
            end
        end
        
        function resultado = criar_resultado_erro(obj, ME)
            % Cria resultado de erro para casos de falha
            resultado = struct();
            resultado.erro_geral = true;
            resultado.mensagem_erro = ME.message;
            resultado.nivel_geral = 'I';
            resultado.pontuacao_geral = 0;
            resultado.timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
        end
    end
end