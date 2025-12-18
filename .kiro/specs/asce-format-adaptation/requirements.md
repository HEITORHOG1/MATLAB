# Requirements Document

## Introduction

Este documento define os requisitos para adaptar o artigo científico existente "Automated Corrosion Detection in ASTM A572 Grade 50 W-Beams Using U-Net and Attention U-Net: A Comparative Analysis for Semantic Segmentation" para o formato oficial da revista ASCE (American Society of Civil Engineers). O artigo deve ser completamente reformatado seguindo as diretrizes específicas da ASCE, utilizando a classe `ascelike-new.cls` e o estilo bibliográfico `ascelike-new.bst`, mantendo todo o conteúdo científico original mas adaptando-o às normas editoriais da revista.

## Requirements

### Requirement 1

**User Story:** Como autor submetendo para revista ASCE, eu quero que meu artigo científico seja formatado corretamente segundo as diretrizes oficiais da ASCE, para que possa ser aceito para revisão por pares sem problemas de formatação.

#### Acceptance Criteria

1. WHEN o documento for criado THEN o sistema SHALL usar a classe `ascelike-new.cls` com opção `Journal` para manuscritos de revista
2. WHEN o cabeçalho for configurado THEN o sistema SHALL incluir todos os pacotes necessários conforme template ASCE
3. WHEN a estrutura for definida THEN o sistema SHALL seguir a ordem específica: Title, Authors, Abstract, Practical Applications, Introduction, Main sections, Conclusions, Data Availability, Acknowledgments, References
4. WHEN o título for formatado THEN o sistema SHALL usar comando `\title{}` sem formatação manual adicional
5. WHEN os autores forem definidos THEN o sistema SHALL usar comandos `\author[]{}` e `\affil[]{}` do pacote authblk

### Requirement 2

**User Story:** Como editor da revista ASCE, eu quero que o manuscrito siga exatamente as especificações de formatação da revista, para que possa ser processado automaticamente pelo sistema editorial.

#### Acceptance Criteria

1. WHEN o abstract for criado THEN o sistema SHALL usar ambiente `\begin{abstract}...\end{abstract}` sem subtítulos internos
2. WHEN as seções forem estruturadas THEN o sistema SHALL usar `\section{}` sem numeração (padrão ASCE)
3. WHEN as subseções forem criadas THEN o sistema SHALL usar `\subsection{}` e `\subsubsection{}` conforme hierarquia ASCE
4. WHEN as equações forem incluídas THEN o sistema SHALL numerá-las sequencialmente usando `\begin{equation}...\end{equation}`
5. WHEN as referências forem formatadas THEN o sistema SHALL usar `ascelike-new.bst` com citações no formato autor-ano

### Requirement 3

**User Story:** Como revisor científico da ASCE, eu quero que todas as figuras e tabelas estejam formatadas segundo os padrões da revista, para que possa avaliar adequadamente o conteúdo visual.

#### Acceptance Criteria

1. WHEN figuras forem inseridas THEN o sistema SHALL usar ambiente `figure` com `\caption{}` e `\label{}`
2. WHEN tabelas forem criadas THEN o sistema SHALL usar ambiente `table` com formatação ASCE padrão
3. WHEN legendas forem escritas THEN o sistema SHALL seguir o padrão "Fig. X" para figuras e "Table X" para tabelas
4. WHEN referências cruzadas forem feitas THEN o sistema SHALL usar `\ref{}` para figuras e tabelas
5. WHEN o posicionamento for definido THEN o sistema SHALL usar parâmetros apropriados `[htbp]` para floats

### Requirement 4

**User Story:** Como bibliotecário da ASCE, eu quero que todas as referências bibliográficas estejam no formato correto da revista, para que possam ser indexadas adequadamente nas bases de dados.

#### Acceptance Criteria

1. WHEN o arquivo .bib for criado THEN o sistema SHALL converter todas as referências para formato compatível com `ascelike-new.bst`
2. WHEN citações forem feitas THEN o sistema SHALL usar comandos `\cite{}`, `\citeA{}`, `\citeN{}` conforme apropriado
3. WHEN a bibliografia for gerada THEN o sistema SHALL usar `\bibliography{referencias}` com estilo automático
4. WHEN URLs forem incluídas THEN o sistema SHALL usar campo `url` nas entradas .bib
5. WHEN DOIs estiverem disponíveis THEN o sistema SHALL incluí-los nas referências apropriadas

### Requirement 5

**User Story:** Como autor correspondente, eu quero que o manuscrito inclua todas as seções obrigatórias da ASCE, para que atenda completamente aos requisitos editoriais da revista.

#### Acceptance Criteria

1. WHEN a seção Practical Applications for criada THEN o sistema SHALL incluir resumo de 150-200 palavras para audiência não-acadêmica
2. WHEN o Data Availability Statement for incluído THEN o sistema SHALL usar uma das declarações padrão da ASCE
3. WHEN palavras-chave forem definidas THEN o sistema SHALL usar comando `\KeyWords{}` específico da classe ASCE
4. WHEN agradecimentos forem incluídos THEN o sistema SHALL posicioná-los após conclusões e antes das referências
5. WHEN apêndices forem necessários THEN o sistema SHALL usar comando `\appendix` e numeração romana

### Requirement 6

**User Story:** Como especialista em LaTeX, eu quero que o código seja limpo e bem estruturado, para que possa ser facilmente mantido e modificado conforme necessário.

#### Acceptance Criteria

1. WHEN o preâmbulo for configurado THEN o sistema SHALL incluir apenas pacotes necessários e compatíveis com ascelike-new.cls
2. WHEN comentários forem adicionados THEN o sistema SHALL documentar seções importantes e configurações específicas
3. WHEN a codificação for definida THEN o sistema SHALL usar UTF-8 com `\usepackage[utf8]{inputenc}`
4. WHEN fontes forem configuradas THEN o sistema SHALL usar `newtxtext,newtxmath` conforme recomendação ASCE
5. WHEN hyperlinks forem configurados THEN o sistema SHALL usar `hyperref` com cores apropriadas para ASCE

### Requirement 7

**User Story:** Como autor internacional, eu quero que o manuscrito mantenha toda a qualidade científica do artigo original, para que o conteúdo técnico não seja comprometido durante a adaptação de formato.

#### Acceptance Criteria

1. WHEN o conteúdo for migrado THEN o sistema SHALL preservar 100% do texto científico original
2. WHEN equações forem transferidas THEN o sistema SHALL manter numeração e formatação matemática correta
3. WHEN dados experimentais forem incluídos THEN o sistema SHALL preservar todas as métricas e análises estatísticas
4. WHEN figuras forem adaptadas THEN o sistema SHALL manter qualidade e informação visual original
5. WHEN a estrutura for reorganizada THEN o sistema SHALL garantir fluxo lógico e coerência científica

### Requirement 8

**User Story:** Como sistema de submissão da ASCE, eu quero que o manuscrito compile sem erros e warnings, para que possa ser processado automaticamente pelo sistema editorial.

#### Acceptance Criteria

1. WHEN o documento for compilado THEN o sistema SHALL produzir PDF sem erros de LaTeX
2. WHEN referências forem processadas THEN o sistema SHALL resolver todas as citações sem warnings
3. WHEN figuras forem incluídas THEN o sistema SHALL encontrar todos os arquivos de imagem
4. WHEN a bibliografia for gerada THEN o sistema SHALL processar o arquivo .bib sem erros
5. WHEN o documento final for criado THEN o sistema SHALL produzir PDF com formatação consistente e profissional