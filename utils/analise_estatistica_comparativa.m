function resultado = analise_estatistica_comparativa(dados1, dados2, nomeMetrica, alpha)
    % ========================================================================
    % ANÁLISE ESTATÍSTICA COMPARATIVA - PROJETO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Agosto 2025
    % Versão: 1.0
    %
    % DESCRIÇÃO:
    %   Realiza análise estatística comparativa completa entre dois grupos
    %   incluindo teste t-student, intervalos de confiança e effect size
    %
    % ENTRADA:
    %   dados1 - Array de dados do primeiro grupo (U-Net)
    %   dados2 - Array de dados do segundo grupo (Attention U-Net)
    %   nomeMetrica - Nome da métrica sendo analisada
    %   alpha - Nível de significância (padrão: 0.05)
    %
    % SAÍDA:
    %   resultado - Struct com análise estatística completa
    % ========================================================================
    
    if nargin < 4
        alpha = 0.05; % 95% de confiança
    end
    
    resultado = struct();
    resultado.metrica = nomeMetrica;
    resultado.alpha = alpha;
    resultado.confianca = (1 - alpha) * 100;
    
    try
        % Validar dados de entrada
        if isempty(dados1) || isempty(dados2)
            error('Dados vazios fornecidos');
        end
        
        % Remover NaN e Inf
        dados1 = dados1(~isnan(dados1) & ~isinf(dados1));
        dados2 = dados2(~isnan(dados2) & ~isinf(dados2));
        
        if isempty(dados1) || isempty(dados2)
            error('Dados insuficientes após limpeza');
        end
        
        % Estatísticas descritivas
        resultado.grupo1 = calcularEstatisticasDescritivas(dados1, 'U-Net', alpha);
        resultado.grupo2 = calcularEstatisticasDescritivas(dados2, 'Attention U-Net', alpha);
        
        % Diferença entre grupos
        resultado.diferenca_medias = resultado.grupo2.mean - resultado.grupo1.mean;
        resultado.diferenca_percentual = (resultado.diferenca_medias / resultado.grupo1.mean) * 100;
        
        % Teste de normalidade (Shapiro-Wilk se disponível)
        resultado.normalidade = testarNormalidade(dados1, dados2);
        
        % Teste de homogeneidade de variâncias (Levene)
        resultado.homogeneidade_variancias = testarHomogeneidadeVariancias(dados1, dados2);
        
        % Teste t de Student
        resultado.teste_t = realizarTesteT(dados1, dados2, alpha);
        
        % Teste não paramétrico (Wilcoxon-Mann-Whitney)
        resultado.teste_wilcoxon = realizarTesteWilcoxon(dados1, dados2, alpha);
        
        % Effect size (Cohen's d)
        resultado.effect_size = calcularEffectSize(dados1, dados2);
        
        % Intervalo de confiança para a diferença das médias
        resultado.ic_diferenca = calcularICDiferenca(dados1, dados2, alpha);
        
        % Recomendação de teste
        resultado.recomendacao = determinarTesteRecomendado(resultado);
        
        % Interpretação dos resultados
        resultado.interpretacao = interpretarResultados(resultado);
        
    catch ME
        resultado.erro = ME.message;
        resultado.sucesso = false;
        return;
    end
    
    resultado.sucesso = true;
end

function stats = calcularEstatisticasDescritivas(dados, nomeGrupo, alpha)
    % Calcula estatísticas descritivas para um grupo
    
    stats = struct();
    stats.nome = nomeGrupo;
    stats.n = length(dados);
    stats.mean = mean(dados);
    stats.std = std(dados);
    stats.var = var(dados);
    stats.min = min(dados);
    stats.max = max(dados);
    stats.median = median(dados);
    stats.q1 = prctile(dados, 25);
    stats.q3 = prctile(dados, 75);
    stats.iqr = stats.q3 - stats.q1;
    stats.range = stats.max - stats.min;
    
    % Coeficiente de variação
    stats.cv = stats.std / stats.mean;
    
    % Erro padrão da média
    stats.sem = stats.std / sqrt(stats.n);
    
    % Intervalo de confiança para a média
    t_critical = tinv(1 - alpha/2, stats.n - 1);
    margin_error = t_critical * stats.sem;
    stats.ic_mean_lower = stats.mean - margin_error;
    stats.ic_mean_upper = stats.mean + margin_error;
    stats.ic_margin = margin_error;
    
    % Assimetria e curtose
    try
        stats.skewness = skewness(dados);
        stats.kurtosis = kurtosis(dados);
    catch
        stats.skewness = NaN;
        stats.kurtosis = NaN;
    end
end

function normalidade = testarNormalidade(dados1, dados2)
    % Testa normalidade dos dados usando Shapiro-Wilk se disponível
    
    normalidade = struct();
    
    % Testar grupo 1
    try
        if exist('swtest', 'file') == 2
            [~, normalidade.p_grupo1] = swtest(dados1);
            normalidade.normal_grupo1 = normalidade.p_grupo1 > 0.05;
        else
            % Usar teste de Jarque-Bera como alternativa
            [~, normalidade.p_grupo1] = jbtest(dados1);
            normalidade.normal_grupo1 = normalidade.p_grupo1 > 0.05;
        end
    catch
        normalidade.p_grupo1 = NaN;
        normalidade.normal_grupo1 = true; % Assumir normal se teste falhar
    end
    
    % Testar grupo 2
    try
        if exist('swtest', 'file') == 2
            [~, normalidade.p_grupo2] = swtest(dados2);
            normalidade.normal_grupo2 = normalidade.p_grupo2 > 0.05;
        else
            [~, normalidade.p_grupo2] = jbtest(dados2);
            normalidade.normal_grupo2 = normalidade.p_grupo2 > 0.05;
        end
    catch
        normalidade.p_grupo2 = NaN;
        normalidade.normal_grupo2 = true;
    end
    
    normalidade.ambos_normais = normalidade.normal_grupo1 && normalidade.normal_grupo2;
end

function homogeneidade = testarHomogeneidadeVariancias(dados1, dados2)
    % Testa homogeneidade de variâncias usando teste F
    
    homogeneidade = struct();
    
    try
        % Teste F para igualdade de variâncias
        [~, homogeneidade.p_value] = vartest2(dados1, dados2);
        homogeneidade.variancias_iguais = homogeneidade.p_value > 0.05;
        
        % Razão das variâncias
        homogeneidade.razao_variancias = var(dados2) / var(dados1);
        
    catch
        homogeneidade.p_value = NaN;
        homogeneidade.variancias_iguais = true; % Assumir iguais se teste falhar
        homogeneidade.razao_variancias = NaN;
    end
end

function teste_t = realizarTesteT(dados1, dados2, alpha)
    % Realiza teste t de Student
    
    teste_t = struct();
    
    try
        % Teste t assumindo variâncias iguais (pooled)
        [h, p, ci, stats] = ttest2(dados1, dados2, 'Alpha', alpha);
        
        teste_t.h = h; % 1 se rejeitou H0, 0 caso contrário
        teste_t.p_value = p;
        teste_t.ci_lower = ci(1);
        teste_t.ci_upper = ci(2);
        teste_t.t_stat = stats.tstat;
        teste_t.df = stats.df;
        teste_t.sd = stats.sd; % Desvio padrão pooled
        
        % Interpretação do p-value
        if p < 0.001
            teste_t.significancia = 'Altamente significativo (p < 0.001)';
            teste_t.nivel = '***';
        elseif p < 0.01
            teste_t.significancia = 'Muito significativo (p < 0.01)';
            teste_t.nivel = '**';
        elseif p < 0.05
            teste_t.significancia = 'Significativo (p < 0.05)';
            teste_t.nivel = '*';
        elseif p < 0.1
            teste_t.significancia = 'Marginalmente significativo (p < 0.1)';
            teste_t.nivel = '.';
        else
            teste_t.significancia = 'Não significativo (p ≥ 0.05)';
            teste_t.nivel = 'ns';
        end
        
        % Teste t com correção de Welch (variâncias desiguais)
        [h_welch, p_welch, ci_welch, stats_welch] = ttest2(dados1, dados2, 'Vartype', 'unequal', 'Alpha', alpha);
        
        teste_t.welch.h = h_welch;
        teste_t.welch.p_value = p_welch;
        teste_t.welch.ci_lower = ci_welch(1);
        teste_t.welch.ci_upper = ci_welch(2);
        teste_t.welch.t_stat = stats_welch.tstat;
        teste_t.welch.df = stats_welch.df;
        
    catch ME
        teste_t.erro = ME.message;
        teste_t.p_value = NaN;
        teste_t.significancia = 'Erro no cálculo';
    end
end

function teste_wilcoxon = realizarTesteWilcoxon(dados1, dados2, alpha)
    % Realiza teste de Wilcoxon-Mann-Whitney (não paramétrico)
    
    teste_wilcoxon = struct();
    
    try
        % Teste de Wilcoxon rank sum (Mann-Whitney U)
        [p, h, stats] = ranksum(dados1, dados2, 'alpha', alpha);
        
        teste_wilcoxon.p_value = p;
        teste_wilcoxon.h = h;
        teste_wilcoxon.ranksum = stats.ranksum;
        teste_wilcoxon.significativo = p < alpha;
        
        % Interpretação
        if p < 0.001
            teste_wilcoxon.significancia = 'Altamente significativo (p < 0.001)';
        elseif p < 0.01
            teste_wilcoxon.significancia = 'Muito significativo (p < 0.01)';
        elseif p < 0.05
            teste_wilcoxon.significancia = 'Significativo (p < 0.05)';
        else
            teste_wilcoxon.significancia = 'Não significativo (p ≥ 0.05)';
        end
        
    catch ME
        teste_wilcoxon.erro = ME.message;
        teste_wilcoxon.p_value = NaN;
        teste_wilcoxon.significativo = false;
    end
end

function effect_size = calcularEffectSize(dados1, dados2)
    % Calcula effect size (Cohen's d e outras medidas)
    
    effect_size = struct();
    
    try
        n1 = length(dados1);
        n2 = length(dados2);
        mean1 = mean(dados1);
        mean2 = mean(dados2);
        std1 = std(dados1);
        std2 = std(dados2);
        
        % Cohen's d (pooled standard deviation)
        pooled_std = sqrt(((n1-1)*std1^2 + (n2-1)*std2^2) / (n1+n2-2));
        effect_size.cohens_d = (mean2 - mean1) / pooled_std;
        
        % Glass's delta (usando desvio padrão do grupo controle)
        effect_size.glass_delta = (mean2 - mean1) / std1;
        
        % Hedges' g (correção para amostras pequenas)
        correction_factor = 1 - (3 / (4*(n1+n2-2) - 1));
        effect_size.hedges_g = effect_size.cohens_d * correction_factor;
        
        % Interpretação do Cohen's d
        abs_d = abs(effect_size.cohens_d);
        if abs_d < 0.2
            effect_size.interpretacao = 'Efeito pequeno (d < 0.2)';
            effect_size.magnitude = 'Pequeno';
        elseif abs_d < 0.5
            effect_size.interpretacao = 'Efeito médio (0.2 ≤ d < 0.5)';
            effect_size.magnitude = 'Médio';
        elseif abs_d < 0.8
            effect_size.interpretacao = 'Efeito grande (0.5 ≤ d < 0.8)';
            effect_size.magnitude = 'Grande';
        else
            effect_size.interpretacao = 'Efeito muito grande (d ≥ 0.8)';
            effect_size.magnitude = 'Muito Grande';
        end
        
        % Direção do efeito
        if effect_size.cohens_d > 0
            effect_size.direcao = 'Grupo 2 > Grupo 1';
        elseif effect_size.cohens_d < 0
            effect_size.direcao = 'Grupo 1 > Grupo 2';
        else
            effect_size.direcao = 'Sem diferença';
        end
        
    catch ME
        effect_size.erro = ME.message;
        effect_size.cohens_d = NaN;
        effect_size.interpretacao = 'Erro no cálculo';
    end
end

function ic_diferenca = calcularICDiferenca(dados1, dados2, alpha)
    % Calcula intervalo de confiança para a diferença das médias
    
    ic_diferenca = struct();
    
    try
        n1 = length(dados1);
        n2 = length(dados2);
        mean1 = mean(dados1);
        mean2 = mean(dados2);
        std1 = std(dados1);
        std2 = std(dados2);
        
        % Diferença das médias
        diff_means = mean2 - mean1;
        
        % Erro padrão da diferença (pooled)
        pooled_var = ((n1-1)*std1^2 + (n2-1)*std2^2) / (n1+n2-2);
        se_diff = sqrt(pooled_var * (1/n1 + 1/n2));
        
        % Graus de liberdade
        df = n1 + n2 - 2;
        
        % Valor crítico t
        t_critical = tinv(1 - alpha/2, df);
        
        % Margem de erro
        margin_error = t_critical * se_diff;
        
        % Intervalo de confiança
        ic_diferenca.diferenca = diff_means;
        ic_diferenca.lower = diff_means - margin_error;
        ic_diferenca.upper = diff_means + margin_error;
        ic_diferenca.margin = margin_error;
        ic_diferenca.se = se_diff;
        ic_diferenca.df = df;
        ic_diferenca.confianca = (1 - alpha) * 100;
        
        % Interpretação
        if ic_diferenca.lower > 0
            ic_diferenca.interpretacao = 'Grupo 2 significativamente maior';
        elseif ic_diferenca.upper < 0
            ic_diferenca.interpretacao = 'Grupo 1 significativamente maior';
        else
            ic_diferenca.interpretacao = 'Diferença não significativa (IC inclui zero)';
        end
        
    catch ME
        ic_diferenca.erro = ME.message;
        ic_diferenca.diferenca = NaN;
    end
end

function recomendacao = determinarTesteRecomendado(resultado)
    % Determina qual teste estatístico é mais apropriado
    
    recomendacao = struct();
    
    try
        % Verificar pressupostos
        normalidade_ok = resultado.normalidade.ambos_normais;
        variancias_ok = resultado.homogeneidade_variancias.variancias_iguais;
        
        if normalidade_ok && variancias_ok
            recomendacao.teste = 'Teste t de Student (pooled)';
            recomendacao.justificativa = 'Dados normais e variâncias homogêneas';
            recomendacao.p_value = resultado.teste_t.p_value;
        elseif normalidade_ok && ~variancias_ok
            recomendacao.teste = 'Teste t de Welch';
            recomendacao.justificativa = 'Dados normais mas variâncias heterogêneas';
            recomendacao.p_value = resultado.teste_t.welch.p_value;
        else
            recomendacao.teste = 'Teste de Wilcoxon-Mann-Whitney';
            recomendacao.justificativa = 'Dados não normais - usar teste não paramétrico';
            recomendacao.p_value = resultado.teste_wilcoxon.p_value;
        end
        
        recomendacao.significativo = recomendacao.p_value < 0.05;
        
    catch
        recomendacao.teste = 'Indeterminado';
        recomendacao.justificativa = 'Erro na determinação';
    end
end

function interpretacao = interpretarResultados(resultado)
    % Gera interpretação textual dos resultados
    
    interpretacao = struct();
    
    try
        % Resumo da comparação
        if resultado.diferenca_medias > 0
            melhor = 'Attention U-Net';
            pior = 'U-Net';
        else
            melhor = 'U-Net';
            pior = 'Attention U-Net';
        end
        
        interpretacao.melhor_modelo = melhor;
        interpretacao.diferenca_percentual = abs(resultado.diferenca_percentual);
        
        % Significância estatística
        p_recomendado = resultado.recomendacao.p_value;
        interpretacao.estatisticamente_significativo = p_recomendado < 0.05;
        
        % Effect size
        if isfield(resultado.effect_size, 'magnitude')
            interpretacao.magnitude_efeito = resultado.effect_size.magnitude;
        else
            interpretacao.magnitude_efeito = 'Indeterminado';
        end
        
        % Conclusão textual
        if interpretacao.estatisticamente_significativo
            interpretacao.conclusao = sprintf(...
                'O modelo %s apresentou desempenho significativamente superior (p = %.4f), ' + ...
                'com diferença de %.2f%% e effect size %s.', ...
                melhor, p_recomendado, interpretacao.diferenca_percentual, ...
                lower(interpretacao.magnitude_efeito));
        else
            interpretacao.conclusao = sprintf(...
                'Não há diferença estatisticamente significativa entre os modelos (p = %.4f). ' + ...
                'Diferença observada: %.2f%%.', ...
                p_recomendado, interpretacao.diferenca_percentual);
        end
        
    catch
        interpretacao.conclusao = 'Erro na interpretação dos resultados';
    end
end