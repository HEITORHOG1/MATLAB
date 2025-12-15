# ASCE Template Migration Plan

## 1. Requisitos obrigatórios e recomendações do guia ASCE

- **Template e estilo**
  - Utilizar a classe `ascelike` (disponível no CTAN e no template oficial da ASCE/Overleaf).
  - Garantir formatação em coluna única e texto em espaço duplo.
  - Fonte principal Times New Roman em 10–12 pt (o template `ascelike` já configura automaticamente).
- **Numeração de linhas**
  - Habilitar numeração contínua de linhas usando o pacote `lineno`.
  - Envolver ambientes matemáticos com `\begin{linenomath*}`/`\end{linenomath*}` para evitar conflitos com `ascelike`.
- **Pacotes**
  - `amsmath` é permitido; evitar `subcaption` e outros pacotes não suportados pelo template.
  - Verificar compatibilidade de pacotes atuais e remover redundâncias.
- **Figuras e tabelas**
  - Imagens devem ser enviadas separadamente (EPS, PDF, PS, BMP, TIF/TIFF); no .tex, usar referências simples (`\includegraphics{figura.pdf}` sem subpastas).
  - No manuscrito, posicionar legendas em páginas separadas ao final.
  - Evitar inserir figuras diretamente no corpo final; manter referências coerentes para o PDF gerado.
- **Bibliografia**
  - Preferência por BibTeX com estilo `ascelike.bst`.
  - Submeter o `.bbl` junto como arquivo de manuscrito.
  - Garantir que citações apareçam corretamente (sem interrogações). Todos os arquivos relacionados devem estar no mesmo diretório.
- **Seções obrigatórias adicionais**
  - "Practical Applications" (150–200 palavras, linguagem simples) após o Abstract.
  - "Data Availability Statement" antes dos Acknowledgments, usando uma das declarações oficiais.
  - A data do PDF deve refletir o autor responsável (incluir nome no carimbo `<Author Name> \today`).
- **Outras diretrizes importantes**
  - `hyperref` pode ser mantido, mas validar compatibilidade com o template.
  - Garantir que todas as figuras e tabelas sejam numeradas e referenciadas no texto.
  - Manuscrito completo em um único diretório (sem subpastas para imagens/tabelas/bibliografia).
  - Garantir ausência de erros de compilação e revisar PDF final.

## 2. Mapeamento inicial do artigo atual

- Arquivo principal: `artigo_cientifico_corrosao.tex`, baseado em `article` com margens e cabeçalhos personalizados (`geometry`, `fancyhdr`, `titlesec`) e espaçamento simples (`\singlespacing`).
- Pacotes carregados:
  - Manter (submeter a validação): `amsmath`, `amssymb`, `mathtools`, `siunitx`, `graphicx`, `booktabs`, `array`, `float`, `hyperref`, `natbib`, `doi`, `url`.
  - Remover/substituir: `subcaption` (não permitido), `geometry`/`setspace`/`fancyhdr`/`titlesec` (layout será do `ascelike`), `microtype` (confirmar suporte), `rotating`, `longtable`, `multirow` (avaliar necessidade real), `epstopdf`/`\DeclareGraphicsExtensions` (template já trata), `graphicspath` apontando para subpasta `figuras/` (ASCE exige todos os arquivos no mesmo diretório).
- Estrutura textual já contempla resumo estruturado, palavras-chave, seções principais (`Introdução`, `Methodology`, `Discussion`, `Conclusions`) e referências via `\bibliography{referencias}`; ainda faltam as seções "Practical Applications" e "Data Availability Statement" exigidas.
- Figuras e tabelas estão inseridas ao longo do texto com `figure`/`table` e `H`; arquivos referenciados com e sem extensão, várias figuras em subdiretório `figuras/`.
- Não há numeração contínua de linhas nem uso de `linenomath*`; equações exibidas precisarão ser encapsuladas.
- Estilo bibliográfico atual `unsrt`; será necessário trocar para `ascelike` e gerar o `.bbl` correspondente.
- Metadados (`\hypersetup`, `\date{\today}`) precisam ser ajustados para o carimbo de data que inclui o nome do autor responsável.

## 3. Próximos passos planejados

1. Preparar dependências externas: copiar `ASCE/ascelike-new.cls` e `ASCE/ascelike-new.bst` para o diretório do manuscrito (ou ajustar caminhos relativos) e mantê-las versionadas.
2. Validar cada pacote utilizado hoje e definir substituições/remover incompatíveis (`subcaption`, `multirow`, etc.).
3. Reorganizar o preâmbulo conforme o template ASCE (manter apenas pacotes permitidos).
4. Ajustar capa (título, autores, afiliações) para os comandos específicos do template (`\title`, `\author`, `\correspondingauthor`, etc., conforme a classe).
5. Inserir seções obrigatórias (Practical Applications, Data Availability Statement) com conteúdo apropriado.
6. Adaptar figuras/tabelas para o posicionamento final exigido (capítulos/tabelas separados no final, sem subpastas).
7. Configurar `lineno` e revisar ambientes matemáticos com `linenomath*`.
8. Gerar e validar `.bbl` usando `ascelike.bst`; garantir citações no formato correto.
9. Testar compilação local com o novo template (`latexmk`/`pdflatex`) e revisar o PDF resultante.
10. Preparar checklist final para submissão (arquivos necessários, conferência de caminhos, ausência de erros).

## 4. Pendências e insumos necessários

- ✅ Arquivos do template localizados em `ASCE/` (`ascelike-new.cls`, `ascelike-new.bst`, `ascexmpl-new.bib`, `ascexmpl-new.tex`). Próximo passo: copiar `ascelike-new.cls`/`ascelike-new.bst` para o mesmo diretório do manuscrito ou ajustar o caminho de classe/estilo na compilação.
- Definir texto do novo bloco "Practical Applications" (pode ser derivado do resumo em tom acessível).
- Selecionar a declaração adequada para "Data Availability Statement" com base nos dados do estudo.

A partir desta base, seguiremos com a adequação passo a passo, atualizando este plano conforme as tarefas forem concluídas.
