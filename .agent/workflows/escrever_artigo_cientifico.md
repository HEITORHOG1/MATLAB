---
description: Agente autônomo para escrita e qualificação de artigos científicos de alto nível, com foco em clareza, concisão e rigor acadêmico.
---

# Workflow: Escritor de Artigos Científicos de Alta Performance (v2.0)

// turbo-all

Este workflow atua como um **Agente Especialista Autônomo** para planejar, escrever e revisar **artigos científicos** para publicação em **Journals e Congressos**. O foco é a produção de texto claro, conciso, sem plágio e estritamente aderente aos critérios de qualificação acadêmica e às normas de cada periódico.

---

## 🎯 MODO DE EXECUÇÃO

Este workflow opera em **modo autônomo contínuo**. Após coletar os requisitos iniciais (ETAPA 0), o agente deve:
1. Executar cada etapa sequencialmente **sem pausar**.
2. Criar/atualizar arquivos de saída conforme especificado.
3. Validar cada etapa com o checklist antes de prosseguir.
4. Em caso de dúvida crítica, pausar e consultar o usuário.

---

## 📋 DIRETRIZES GERAIS DE ESCRITA

| Diretriz | Descrição |
|----------|-----------|
| **Tom Acadêmico** | Formal, objetivo e impessoal (evitar 1ª pessoa, salvo se a área permitir). |
| **Clareza e Concisão** | Frases diretas. Evitar parágrafos longos. Facilitar a leitura. |
| **Originalidade** | CONTEÚDO 100% ORIGINAL. É PROIBIDO plágio. Parafrasear e citar fontes corretamente. |
| **Formatação** | Seguir as normas da ABNT, APA ou do Journal/Congresso alvo. |
| **Linguagem** | Evitar jargões desnecessários. Definir termos técnicos na primeira ocorrência. |

---

## 📊 LIMITES DE PALAVRAS SUGERIDOS

Ajustar conforme as normas do journal/congresso alvo:

| Seção | Palavras (min-max) |
|-------|-------------------|
| Título | 10-15 palavras |
| Resumo/Abstract | 150-300 palavras |
| Palavras-chave | 4-6 termos |
| Introdução | 500-1000 palavras |
| Revisão da Literatura | 1500-3000 palavras |
| Metodologia | 800-1500 palavras |
| Resultados | 1000-2000 palavras |
| Discussão | 1000-2000 palavras |
| Conclusão | 300-500 palavras |

---

## ETAPA 0: Briefing e Coleta de Requisitos

**Objetivo**: Coletar TODAS as informações necessárias antes de iniciar a escrita.

### Perguntas Obrigatórias ao Usuário:

1. **Tema/Área**: Qual o tema central e área de conhecimento?
2. **Problema de Pesquisa**: Qual a pergunta ou lacuna que o artigo busca responder?
3. **Hipótese(s)**: Existe uma hipótese a ser testada?
4. **Journal/Congresso Alvo**: Qual a publicação alvo? (Informar Qualis CAPES, se souber)
5. **Normas de Formatação**: ABNT, APA, IEEE, ACM, Vancouver, ou outra?
6. **Referências Obrigatórias**: Há autores ou obras que DEVEM ser citados?
7. **Dados/Resultados**: O usuário já possui dados coletados ou será pesquisa teórica?
8. **Idioma**: Português (PT-BR), Inglês (EN), ou outro?
9. **Prazo**: Qual a data limite de entrega?
10. **Template**: Existe um template específico (.tex, .docx) a seguir?

### Ação:
- Criar pasta de trabalho: `./artigo/`
- Criar arquivo mestre: `./artigo/[TITULO_SLUG].md`
- Salvar as respostas do briefing no topo do arquivo mestre.

**Validação (Checklist)**:
- [ ] Todas as 10 perguntas foram respondidas?
- [ ] O arquivo mestre foi criado?

---

## ETAPA 1: Definição do Escopo e Título

**Objetivo**: Definir a identidade do artigo.

### 1.1 Análise do Contexto
- Qual o problema a ser resolvido?
- Qual a lacuna teórica ou prática?
- Qual o público-alvo do artigo?

### 1.2 Verificação do Target
- Pesquisar as normas do Journal/Congresso alvo.
- Verificar Qualis CAPES e/ou Fator de Impacto.
- Identificar artigos recentes publicados no mesmo veículo (estilo, estrutura).

### 1.3 Geração do Título
Desenvolver **3 opções de título** seguindo os critérios:
- Palavras-chave importantes no início.
- Sem ambiguidade ou palavras confusas.
- Se longo, usar formato "Título: Subtítulo".
- Otimizado para busca (SEO Acadêmico).
- Entre 10-15 palavras.

**Formato de Saída**:
```
TÍTULO OPÇÃO 1: [título]
TÍTULO OPÇÃO 2: [título]
TÍTULO OPÇÃO 3: [título]
TÍTULO SELECIONADO: [título escolhido e justificativa]
```

**Validação (Checklist)**:
- [ ] O título reflete exatamente o conteúdo?
- [ ] É preciso e sintético?
- [ ] Contém as principais palavras-chave?

---

## ETAPA 2: Resumo (Abstract) e Palavras-Chave

**Objetivo**: Vender a ideia do artigo em um parágrafo e facilitar a indexação.

### 2.1 Estrutura do Resumo
Escrever o resumo contendo **explicitamente** (nesta ordem):

1. **Contextualização** (1-2 frases): O que é o paper e sua importância.
2. **Gap/Problema** (1 frase): Por que isso importa? Qual a lacuna?
3. **Objetivo** (1 frase): O que será feito/investigado.
4. **Metodologia** (1-2 frases): Como foi feito.
5. **Resultados** (2-3 frases): O que foi encontrado/descoberto.
6. **Implicações** (1 frase): Impacto do estudo para teoria e prática.

**Limite**: 150-300 palavras (verificar norma do journal).

### 2.2 Palavras-Chave (Keywords)
Selecionar **4 a 6 palavras-chave** que:
- Representem o tema central.
- Sejam comumente usadas em buscas na área.
- NÃO repitam palavras já presentes no título.
- Incluam termos em inglês se o artigo for em português (para indexação internacional).

**Formato de Saída**:
```
RESUMO:
[texto do resumo]

PALAVRAS-CHAVE: [termo1]; [termo2]; [termo3]; [termo4]; [termo5]

ABSTRACT (se necessário):
[tradução em inglês]

KEYWORDS: [term1]; [term2]; [term3]; [term4]; [term5]
```

**Validação (Checklist)**:
- [ ] Responde "What is this paper about?"
- [ ] Responde "Why should anyone care?"
- [ ] É conciso e respeita o limite de palavras?
- [ ] As palavras-chave são relevantes e não redundantes?

---

## ETAPA 3: Introdução e Revisão da Literatura

**Objetivo**: Situar o leitor e justificar a pesquisa.

### 3.1 Estrutura da Introdução
Seguir a estrutura "Funil" (do geral para o específico):

1. **Abertura** (1-2 parágrafos): Apresentar o tema de forma ampla.
2. **Contextualização** (2-3 parágrafos): Situar o tema no campo de estudos.
3. **Problema de Pesquisa** (1 parágrafo): Definir claramente o problema.
4. **Justificativa** (1-2 parágrafos): Por que é relevante? (sociedade/academia/mercado)
5. **Objetivos**:
   - Objetivo Geral (1 frase).
   - Objetivos Específicos (3-5 itens em lista).
6. **Questões Orientadoras** (opcional): Perguntas que guiam a pesquisa.
7. **Estrutura do Artigo** (1 parágrafo): Breve descrição das seções seguintes.

### 3.2 Revisão Bibliográfica (Estado da Arte)

**Estratégia de Busca de Referências**:
Usar a ferramenta `search_web` para buscar em:
- Google Scholar
- Scopus
- Web of Science
- Periódicos CAPES
- Repositórios institucionais

**Critérios de Seleção**:
- Preferência: publicações dos últimos **5 anos**.
- Priorizar revistas Qualis A1, A2, B1.
- Incluir obras seminais/clássicas da área (independente do ano).
- Mínimo de **15-20 referências** (ajustar conforme norma).

**Estrutura da Revisão**:
1. **Conceitos Fundamentais**: Definir os termos-chave do trabalho.
2. **Evolução Histórica** (se aplicável): Como o tema evoluiu.
3. **Estado Atual**: O que dizem os estudos mais recentes.
4. **Abordagens Competidoras**: Comparar diferentes perspectivas/métodos.
5. **Lacuna (Gap)**: Mostrar onde os outros falharam ou pararam.

**REGRA DE OURO**: Não apenas LISTAR autores, mas **DIALOGAR** com eles.
- ❌ "Silva (2020) disse X. Santos (2021) disse Y."
- ✅ "Embora Silva (2020) argumente X, Santos (2021) contrapõe com Y, sugerindo que..."

**Validação (Checklist)**:
- [ ] O objetivo está claro e alinhado com o problema?
- [ ] As questões de pesquisa conectam-se com o campo de estudos?
- [ ] A bibliografia é pertinente e atualizada?
- [ ] Há diálogo entre os autores (não apenas listagem)?
- [ ] O "Gap" está claramente identificado?

---

## ETAPA 4: Metodologia

**Objetivo**: Garantir a reprodutibilidade e validade científica.

### Estrutura Obrigatória:

1. **Classificação da Pesquisa**:
   - Natureza: Básica ou Aplicada
   - Abordagem: Qualitativa, Quantitativa ou Mista
   - Objetivos: Exploratória, Descritiva ou Explicativa
   - Procedimentos: Bibliográfica, Documental, Experimental, Estudo de Caso, Survey, etc.

2. **Universo e Amostra**:
   - Quem são os participantes/objetos de estudo?
   - Quantos? Por que esse número?
   - Critérios de inclusão e exclusão.
   - Tipo de amostragem (probabilística, por conveniência, etc.).

3. **Instrumentos de Coleta**:
   - Questionários, entrevistas, observação, etc.
   - Se questionário: descrever as escalas usadas (Likert, etc.).
   - Softwares e equipamentos utilizados.

4. **Procedimentos de Coleta**:
   - Passo a passo cronológico.
   - Período de coleta.
   - Aspectos éticos (Comitê de Ética, TCLE, etc.).

5. **Procedimentos de Análise**:
   - Dados quantitativos: testes estatísticos (t-test, ANOVA, regressão, etc.).
   - Dados qualitativos: análise de conteúdo, análise temática, etc.
   - Softwares de análise (SPSS, R, NVivo, Atlas.ti, etc.).

6. **Limitações do Estudo**:
   - Honestidade intelectual sobre restrições.
   - O que não foi possível cobrir e por quê.

**Validação (Checklist)**:
- [ ] Justifica por que escolheu o método X e não Y?
- [ ] Outro pesquisador conseguiria replicar o estudo?
- [ ] Descreve como contornou ou mitigou as limitações?
- [ ] Aspectos éticos foram considerados?

---

## ETAPA 5: Resultados e Discussão

**Objetivo**: Apresentar os dados e responder "E daí?" (So What?).

### 5.1 Resultados
**Apresentação objetiva dos dados**, sem interpretação:

- Usar **tabelas** para dados numéricos comparativos.
- Usar **gráficos** para tendências e distribuições.
- Usar **quadros** para sínteses qualitativas.
- Numerar e legendar todas as figuras/tabelas.
- Referenciar as figuras/tabelas no texto.

**Formato**:
```
Conforme apresentado na Tabela 1, os resultados indicam que...
A Figura 2 demonstra a distribuição de...
```

### 5.2 Discussão
**Interpretação dos resultados** à luz da teoria:

1. **Retomada dos Objetivos**: Relembrar o que se buscava.
2. **Interpretação**: O que os resultados significam?
3. **Triangulação com a Literatura**:
   - Confirma ou refuta as hipóteses?
   - Concorda ou discorda de estudos anteriores? Por quê?
4. **Explicação de Anomalias**: Resultados inesperados? Explicar.
5. **Implicações**: Qual a importância dos achados para teoria e prática?

**Validação (Checklist)**:
- [ ] Os resultados estão apresentados de forma clara e organizada?
- [ ] A discussão conecta os achados com a revisão da literatura?
- [ ] As hipóteses foram confirmadas ou refutadas com base nos dados?
- [ ] As implicações práticas e teóricas estão claras?

---

## ETAPA 6: Conclusão

**Objetivo**: Fechamento e legado do trabalho.

### Estrutura:

1. **Recapitulação** (1 parágrafo): Resumir os principais achados.
2. **Resposta ao Problema** (1-2 parágrafos): Responder diretamente às questões/objetivos da Introdução.
3. **Contribuições**:
   - **Teóricas**: O que o estudo acrescenta à ciência?
   - **Práticas**: Como isso ajuda o mercado/sociedade/profissionais?
4. **Limitações** (1 parágrafo): Reconhecer honestamente as restrições.
5. **Sugestões para Pesquisas Futuras** (1 parágrafo): O que outros pesquisadores devem investigar?
6. **Fechamento** (1-2 frases): Mensagem final impactante.

**REGRAS**:
- ❌ NÃO introduzir informações novas.
- ❌ NÃO copiar o resumo.
- ✅ Responder diretamente aos objetivos.
- ✅ Ser conciso (300-500 palavras).

**Validação (Checklist)**:
- [ ] As hipóteses/questões foram respondidas?
- [ ] Fica claro o impacto do estudo (So What)?
- [ ] Não há informações novas?
- [ ] As sugestões para pesquisas futuras são específicas e viáveis?

---

## ETAPA 7: Referências Bibliográficas (BibTeX)

**Objetivo**: Gerenciar todas as referências em formato BibTeX para compilação LaTeX.

### 7.1 Estrutura do Arquivo `referencias.bib`

Todas as referências DEVEM estar no arquivo `referencias.bib` no formato BibTeX:

```bibtex
@article{silva2023,
  author  = {Silva, João and Santos, Maria},
  title   = {Título do Artigo em Inglês},
  journal = {Journal of Example Studies},
  year    = {2023},
  volume  = {15},
  number  = {3},
  pages   = {123--145},
  doi     = {10.1000/example.2023.001}
}

@inproceedings{oliveira2022,
  author    = {Oliveira, Pedro},
  title     = {Título do Paper de Conferência},
  booktitle = {Proceedings of International Conference},
  year      = {2022},
  pages     = {45--52},
  publisher = {IEEE}
}

@book{autor2021,
  author    = {Autor, Nome},
  title     = {Título do Livro},
  publisher = {Editora},
  year      = {2021},
  address   = {Cidade}
}
```

### 7.2 Citações no Texto LaTeX

Usar os comandos corretos conforme o estilo:

| Comando | Resultado | Uso |
|---------|-----------|-----|
| `\cite{silva2023}` | [1] ou (Silva, 2023) | Citação direta |
| `\citep{silva2023}` | (Silva, 2023) | Citação entre parênteses |
| `\citet{silva2023}` | Silva (2023) | Citação no texto |
| `\citep[p.~45]{silva2023}` | (Silva, 2023, p. 45) | Com número de página |

### 7.3 Configuração no LaTeX

```latex
% No preâmbulo
\usepackage[utf8]{inputenc}
\usepackage[brazil]{babel}  % ou [english]
\usepackage{natbib}         % ou biblatex
\bibliographystyle{apalike} % ou abntex2, ieeetr, etc.

% No final do documento
\bibliography{referencias}
```

### 7.4 Regras de Qualidade

1. **Apenas fontes citadas**: Não incluir obras não referenciadas no texto.
2. **Verificar compilação**: Rodar `bibtex` ou `biber` para verificar erros.
3. **DOI obrigatório**: Incluir DOI sempre que disponível.
4. **Mínimo**: 15-30 referências (ajustar conforme área).
5. **Atualidade**: Preferência por últimos 5 anos (mínimo 60%).

**Validação (Checklist)**:
- [ ] Arquivo `referencias.bib` criado e sem erros de sintaxe?
- [ ] Todas as citações no texto têm entrada correspondente?
- [ ] DOIs incluídos quando disponíveis?
- [ ] Compilação BibTeX sem warnings?

---

## ETAPA 8: Elementos Visuais (Figuras, Tabelas, Infográficos)

**Objetivo**: Criar elementos visuais de alta qualidade, prontos para publicação acadêmica.

### 8.1 PADRÕES DE QUALIDADE PARA FIGURAS

#### Especificações Técnicas:
| Parâmetro | Valor Recomendado |
|-----------|-------------------|
| **Resolução** | Mínimo 300 DPI (ideal 600 DPI para gráficos) |
| **Formato** | PDF (vetorial) ou PNG/TIFF (raster) |
| **Largura** | 8.5 cm (1 coluna) ou 17.5 cm (2 colunas) |
| **Cores** | CMYK para impressão, RGB para digital |
| **Fonte interna** | Sans-serif (Arial, Helvetica), 8-10pt |
| **Linhas** | Mínimo 0.5pt de espessura |

#### Código LaTeX para Figuras:

```latex
\begin{figure}[htbp]
    \centering
    \includegraphics[width=0.8\textwidth]{figuras/fig1_metodologia.pdf}
    \caption{Descrição clara e completa da figura. Fonte: Elaborado pelo autor (2024).}
    \label{fig:metodologia}
\end{figure}
```

#### Regras de Nomenclatura:
- `fig1_[descrição].pdf` - Ex: `fig1_arquitetura_sistema.pdf`
- `fig2_[descrição].pdf` - Ex: `fig2_resultados_comparativo.pdf`

### 8.2 PADRÕES DE QUALIDADE PARA TABELAS

#### Código LaTeX para Tabelas Profissionais:

```latex
\usepackage{booktabs}  % Para linhas profissionais
\usepackage{siunitx}   % Para alinhamento numérico

\begin{table}[htbp]
    \centering
    \caption{Comparativo dos resultados obtidos pelos métodos avaliados.}
    \label{tab:resultados}
    \begin{tabular}{@{}lSSS@{}}
        \toprule
        \textbf{Método} & \textbf{Precisão (\%)} & \textbf{Recall (\%)} & \textbf{F1-Score} \\
        \midrule
        Método A        & 92.5  & 88.3  & 0.903 \\
        Método B        & 89.1  & 91.2  & 0.901 \\
        \textbf{Proposto} & \textbf{95.8} & \textbf{93.4} & \textbf{0.946} \\
        \bottomrule
    \end{tabular}
    \begin{tablenotes}
        \small
        \item Fonte: Dados da pesquisa (2024).
    \end{tablenotes}
\end{table}
```

#### Regras para Tabelas:
- ✅ Usar `booktabs` (linhas `\toprule`, `\midrule`, `\bottomrule`)
- ❌ NÃO usar linhas verticais
- ✅ Alinhar números decimais
- ✅ Destacar valores importantes em negrito
- ✅ Incluir unidades de medida no cabeçalho

### 8.3 CRIAÇÃO DE INFOGRÁFICOS DE ALTA QUALIDADE

#### Ferramentas Recomendadas:
| Ferramenta | Uso | Formato de Saída |
|------------|-----|------------------|
| **TikZ/PGF** | Diagramas técnicos no LaTeX | PDF (vetorial) |
| **draw.io** | Fluxogramas e arquiteturas | PDF, SVG |
| **Python + Matplotlib** | Gráficos científicos | PDF, PNG |
| **R + ggplot2** | Visualizações estatísticas | PDF, PNG |
| **Inkscape** | Edição vetorial | PDF, SVG, EPS |
| **Canva Pro** | Infográficos visuais | PNG, PDF |

#### Código TikZ para Diagrama de Fluxo:

```latex
\usepackage{tikz}
\usetikzlibrary{shapes.geometric, arrows, positioning}

\tikzstyle{startstop} = [rectangle, rounded corners, minimum width=3cm, 
                         minimum height=1cm, text centered, draw=black, fill=red!30]
\tikzstyle{process} = [rectangle, minimum width=3cm, minimum height=1cm, 
                       text centered, draw=black, fill=blue!20]
\tikzstyle{arrow} = [thick,->,>=stealth]

\begin{figure}[htbp]
    \centering
    \begin{tikzpicture}[node distance=2cm]
        \node (start) [startstop] {Início};
        \node (proc1) [process, below of=start] {Coleta de Dados};
        \node (proc2) [process, below of=proc1] {Análise};
        \node (end) [startstop, below of=proc2] {Resultados};
        
        \draw [arrow] (start) -- (proc1);
        \draw [arrow] (proc1) -- (proc2);
        \draw [arrow] (proc2) -- (end);
    \end{tikzpicture}
    \caption{Fluxograma do processo metodológico proposto.}
    \label{fig:fluxograma}
\end{figure}
```

#### Código Python para Gráficos Científicos:

```python
import matplotlib.pyplot as plt
import numpy as np

# Configurações para qualidade de publicação
plt.rcParams.update({
    'font.size': 10,
    'font.family': 'serif',
    'figure.figsize': (8, 5),
    'figure.dpi': 300,
    'savefig.dpi': 600,
    'savefig.format': 'pdf'
})

# Dados
x = np.array([1, 2, 3, 4, 5])
y = np.array([23, 45, 56, 78, 89])

# Criar gráfico
fig, ax = plt.subplots()
ax.plot(x, y, 'o-', color='#2E86AB', linewidth=2, markersize=8)
ax.set_xlabel('Variável X (unidade)')
ax.set_ylabel('Variável Y (unidade)')
ax.set_title('Título Descritivo do Gráfico')
ax.grid(True, linestyle='--', alpha=0.7)

# Salvar em alta qualidade
plt.tight_layout()
plt.savefig('figuras/fig_grafico.pdf', bbox_inches='tight')
```

### 8.4 GERAÇÃO DE IMAGENS COM IA

Para criar infográficos e ilustrações conceituais, usar a ferramenta `generate_image` com prompts específicos:

**Formato do Prompt para Infográficos Acadêmicos**:
```
Scientific infographic showing [CONCEITO], clean minimalist design, 
professional academic style, white background, vector illustration, 
no text labels, high contrast colors, suitable for scientific publication
```

**Exemplo**:
```
Scientific infographic showing machine learning pipeline with data input, 
preprocessing, model training, and evaluation steps, clean minimalist design, 
professional academic style, blue and gray color scheme, white background, 
vector illustration style, suitable for IEEE publication
```

### 8.5 Checklist de Qualidade Visual

**Para CADA figura/tabela, verificar**:
- [ ] Resolução mínima de 300 DPI?
- [ ] Texto legível quando reduzido a 50%?
- [ ] Cores acessíveis (considerar daltonismo)?
- [ ] Legenda clara e autoexplicativa?
- [ ] Referenciada no texto ANTES de aparecer?
- [ ] Numeração sequencial correta (Figura 1, Figura 2...)?
- [ ] Fonte indicada na legenda?
- [ ] Formato vetorial (PDF) quando possível?

---

## ETAPA 9: Compilação LaTeX e Revisão Final

**Objetivo**: Compilar o documento e garantir qualidade profissional.

### 9.1 Estrutura do Arquivo Principal (`main.tex`)

```latex
\documentclass[12pt,a4paper]{article}
% ou: \documentclass[conference]{IEEEtran}
% ou: \documentclass{elsarticle}

% =====================
% PACOTES ESSENCIAIS
% =====================
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[brazil]{babel}  % ou [english]
\usepackage{amsmath,amssymb}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{hyperref}
\usepackage{natbib}
\usepackage{float}
\usepackage{caption}
\usepackage{subcaption}

% Caminho das figuras
\graphicspath{{figuras/}}

% =====================
% DOCUMENTO
% =====================
\begin{document}

\title{Título do Artigo}
\author{Nome do Autor}
\date{\today}
\maketitle

\begin{abstract}
Texto do resumo...
\end{abstract}

\textbf{Palavras-chave:} termo1; termo2; termo3.

\input{secoes/introducao}
\input{secoes/revisao}
\input{secoes/metodologia}
\input{secoes/resultados}
\input{secoes/conclusao}

\bibliography{referencias}
\bibliographystyle{apalike}

\end{document}
```

### 9.2 Comandos de Compilação

```bash
# Compilação completa (recomendado)
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex

# Ou usando latexmk (automático)
latexmk -pdf main.tex

# Limpar arquivos auxiliares
latexmk -c
```

### 9.3 Verificação de Redação
- [ ] Ortografia e gramática impecáveis
- [ ] Fluidez textual (conectivos adequados)
- [ ] Consistência de tempo verbal
- [ ] Voz ativa vs. passiva (conforme estilo)
- [ ] Eliminar redundâncias

### 9.4 Verificação de Compilação
- [ ] Sem erros de compilação LaTeX?
- [ ] Sem warnings críticos?
- [ ] BibTeX compilou sem erros?
- [ ] Todas as referências cruzadas funcionando (`\ref{}`, `\cite{}`)?
- [ ] PDF gerado corretamente?

### 9.5 Verificação de Plágio
**AÇÃO OBRIGATÓRIA**: Submeter o PDF a ferramenta de detecção de plágio.
- Ferramentas: Turnitin, iThenticate, Plagius, Quetext
- **Meta**: Similaridade < 15% (ideal < 10%)

---

## ETAPA 10: Preparação para Submissão

**Objetivo**: Preparar pacote completo para envio ao journal/congresso.

### 10.1 Arquivos para Submissão

| Arquivo | Descrição | Obrigatório |
|---------|-----------|-------------|
| `main.tex` | Código fonte LaTeX | Sim |
| `main.pdf` | PDF compilado final | Sim |
| `referencias.bib` | Referências BibTeX | Sim |
| `figuras/*.pdf` | Figuras em alta resolução | Sim |
| `cover_letter.pdf` | Carta de apresentação | Depende |
| `highlights.txt` | Destaques do artigo | Depende |
| `graphical_abstract.pdf` | Resumo gráfico | Depende |
| `supplementary.zip` | Material suplementar | Opcional |

### 10.2 Carta de Apresentação (Cover Letter)

```latex
\documentclass[11pt]{letter}
\usepackage[utf8]{inputenc}
\signature{Nome do Autor Correspondente}
\address{Instituição \\ Endereço \\ Email}

\begin{document}
\begin{letter}{Editor-in-Chief \\ Journal Name}

\opening{Dear Editor,}

We are pleased to submit our manuscript entitled "\textbf{Título do Artigo}" 
for consideration for publication in [Journal Name].

[Parágrafo sobre a importância e contribuição do trabalho]

[Parágrafo sobre por que este journal é apropriado]

This manuscript has not been published and is not under consideration 
for publication elsewhere.

\closing{Sincerely,}

\end{letter}
\end{document}
```

### 10.3 Checklist Final de Submissão

- [ ] PDF compilado sem erros
- [ ] Anonimizado para blind review (se exigido)
- [ ] Dentro do limite de páginas/palavras
- [ ] Todas as figuras em alta resolução
- [ ] Referências no formato exigido
- [ ] Metadados do PDF preenchidos
- [ ] Cover letter preparada
- [ ] Conflitos de interesse declarados
- [ ] Contribuição dos autores declarada

### 10.4 Relatório de Conclusão

Gerar ao final:
```
========================================
✅ ARTIGO FINALIZADO PARA SUBMISSÃO
========================================
Título: [título]
Palavras-chave: [keywords]
Total de palavras: [X]
Total de páginas: [X]
Total de figuras: [X]
Total de tabelas: [X]
Total de referências: [X]
Arquivo principal: main.tex
PDF final: output/[TITULO_SLUG].pdf
Data de conclusão: [data]
Target: [journal/congresso]
========================================
```

---

## 📁 ESTRUTURA DE ARQUIVOS GERADOS (LaTeX)

```
./artigo/
├── main.tex                      # Arquivo principal LaTeX
├── [TITULO_SLUG].tex             # Conteúdo do artigo
├── referencias.bib               # Referências BibTeX (OBRIGATÓRIO)
├── figuras/                      # Pasta com figuras (PNG, PDF, EPS)
│   ├── fig1_metodologia.pdf
│   ├── fig2_resultados.pdf
│   ├── fig3_infografico.pdf
│   └── fig4_grafico.png
├── tabelas/                      # Pasta com tabelas complexas
│   ├── tab1_comparativo.tex
│   └── tab2_resultados.tex
├── estilos/                      # Arquivos de estilo (.sty, .cls)
│   └── journal_style.cls
├── output/                       # PDFs compilados
│   ├── [TITULO_SLUG].pdf
│   └── [TITULO_SLUG]_draft.pdf
└── backups/                      # Versões anteriores
    └── [TITULO_SLUG]_v1.tex
```

---

## 🚨 ALERTAS DE QUALIDADE

O agente deve **PARAR E ALERTAR** o usuário se detectar:

1. **Plágio**: Qualquer trecho copiado sem citação.
2. **Autocitação excessiva**: Mais de 20% de referências do próprio autor.
3. **Referências desatualizadas**: Mais de 50% das fontes com mais de 10 anos.
4. **Inconsistência**: Objetivos não respondidos nas conclusões.
5. **Limite excedido**: Artigo acima do limite de palavras do journal.

---

## ✅ RESUMO DO FLUXO DE EXECUÇÃO

```
ETAPA 0  → Coleta de Requisitos (INTERATIVO)
    ↓
ETAPA 1  → Título (3 opções → seleção)
    ↓
ETAPA 2  → Resumo + Palavras-chave
    ↓
ETAPA 3  → Introdução + Revisão da Literatura
    ↓
ETAPA 4  → Metodologia
    ↓
ETAPA 5  → Resultados + Discussão
    ↓
ETAPA 6  → Conclusão
    ↓
ETAPA 7  → Referências Bibliográficas (BibTeX)
    ↓
ETAPA 8  → Elementos Visuais (Figuras, Tabelas, Infográficos)
    ↓
ETAPA 9  → Compilação LaTeX + Revisão Final
    ↓
ETAPA 10 → Preparação para Submissão
    ↓
✅ ARTIGO FINALIZADO (PDF)
```
