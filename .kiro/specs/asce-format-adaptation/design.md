# Design Document

## Overview

Este documento apresenta o design detalhado para adaptar o artigo científico existente sobre detecção automatizada de corrosão para o formato oficial da revista ASCE (American Society of Civil Engineers). A adaptação manterá 100% do conteúdo científico original enquanto reformata completamente o documento para atender às especificações editoriais da ASCE, utilizando a classe `ascelike-new.cls` e o sistema bibliográfico `ascelike-new.bst`.

## Architecture

### Estrutura do Documento ASCE

```
artigo_cientifico_corrosao_asce.tex
├── 1. Preâmbulo ASCE
│   ├── \documentclass[Journal,letterpaper]{ascelike-new}
│   ├── Pacotes obrigatórios ASCE
│   ├── Configurações de hyperref
│   └── \NameTag{} para identificação
├── 2. Metadados do Artigo
│   ├── \title{} (formato ASCE)
│   ├── \author[]{} e \affil[]{} (authblk)
│   └── \maketitle
├── 3. Abstract (ambiente ASCE)
├── 4. Practical Applications (obrigatório ASCE)
├── 5. Seções Principais
│   ├── Introduction
│   ├── Methodology
│   ├── Results
│   ├── Discussion
│   └── Conclusions
├── 6. Data Availability Statement (obrigatório ASCE)
├── 7. Acknowledgments
├── 8. Notation (se aplicável)
├── 9. Appendixes (numeração romana)
└── 10. References (bibliografia automática)
```

### Sistema de Referências ASCE

```
referencias_asce.bib
├── Entradas convertidas para formato ASCE
├── Campos obrigatórios: author, title, journal/booktitle, year
├── Campos opcionais: volume, number, pages, publisher, address
├── URLs formatadas corretamente
├── DOIs incluídos quando disponíveis
└── Compatibilidade com ascelike-new.bst
```

## Components and Interfaces

### Componente 1: Conversor de Formato LaTeX

**Interface:** `ConversorFormatoASCE`

**Responsabilidades:**
- Converter preâmbulo para formato ASCE
- Adaptar comandos de seção e formatação
- Migrar conteúdo preservando estrutura científica
- Configurar pacotes compatíveis com ascelike-new.cls

**Transformações principais:**
```latex
# De formato genérico para ASCE
\documentclass{article} → \documentclass[Journal,letterpaper]{ascelike-new}
\section*{Abstract} → \begin{abstract}...\end{abstract}
\section{Introduction} → \section{Introduction} (sem numeração)
\bibliographystyle{plain} → \bibliographystyle{ascelike-new}
```

### Componente 2: Adaptador de Bibliografia

**Interface:** `AdaptadorBibliografiaASCE`

**Responsabilidades:**
- Converter arquivo .bib para formato ASCE
- Mapear tipos de entrada para equivalentes ASCE
- Ajustar campos obrigatórios e opcionais
- Validar compatibilidade com ascelike-new.bst

**Mapeamentos de entrada:**
```bibtex
@article → @ARTICLE (campos: author, title, journal, year, volume, number, pages)
@inproceedings → @INPROCEEDINGS (campos: author, title, booktitle, year, pages, organization, address)
@book → @BOOK (campos: author, title, publisher, address, year, edition)
@techreport → @TECHREPORT (campos: author, title, institution, year, type, number)
@misc → @MISC (para websites, com campos url e month)
```

### Componente 3: Formatador de Elementos Visuais

**Interface:** `FormatadorElementosVisuaisASCE`

**Responsabilidades:**
- Adaptar figuras para padrão ASCE
- Reformatar tabelas conforme especificações
- Ajustar legendas e referências cruzadas
- Configurar posicionamento de floats

**Padrões ASCE para figuras:**
```latex
\begin{figure}[htbp]
    \centering
    \includegraphics[width=0.9\textwidth]{figura_nome.pdf}
    \caption{Legenda da figura seguindo padrão ASCE. Descrição detalhada...}
    \label{fig:nome_figura}
\end{figure}
```

**Padrões ASCE para tabelas:**
```latex
\begin{table}[htbp]
    \centering
    \caption{Título da tabela}
    \label{tab:nome_tabela}
    \begin{tabular}{|l|c|c|}
        \hline
        \textbf{Coluna 1} & \textbf{Coluna 2} & \textbf{Coluna 3} \\
        \hline
        Dados... & Dados... & Dados... \\
        \hline
    \end{tabular}
\end{table}
```

### Componente 4: Gerador de Seções Obrigatórias ASCE

**Interface:** `GeradorSecoesObrigatoriasASCE`

**Responsabilidades:**
- Criar seção Practical Applications
- Gerar Data Availability Statement
- Formatar Keywords usando comando ASCE
- Estruturar Acknowledgments conforme padrão

**Template Practical Applications:**
```latex
\section{Practical Applications}
Attention-based deep learning allows inspectors to convert routine photographs 
into objective corrosion maps without erecting scaffolds or relying solely on 
subjective visual judgments. In this work, U-Net and Attention U-Net models 
were trained on hundreds of annotated ASTM A572 Grade 50 W-beam images and 
learned to outline corroded regions automatically...
```

**Template Data Availability Statement:**
```latex
\section{Data Availability Statement}
Some or all data, models, or code generated or used during the study are 
proprietary or confidential in nature and may only be provided with 
restrictions. Aggregated metrics and processing scripts documented in this 
article are available from the corresponding author upon reasonable request 
to support result verification.
```

## Data Models

### Modelo de Configuração ASCE

```python
class ConfiguracaoASCE:
    # Classe do documento
    document_class: str = "ascelike-new"
    class_options: list = ["Journal", "letterpaper"]
    
    # Pacotes obrigatórios
    pacotes_obrigatorios: list = [
        "inputenc[utf8]",
        "fontenc[T1]", 
        "babel[english]",
        "lmodern",
        "graphicx",
        "caption",
        "subcaption",
        "amsmath",
        "siunitx",
        "booktabs",
        "array",
        "multirow",
        "newtxtext,newtxmath",
        "hyperref"
    ]
    
    # Configurações específicas
    name_tag: str = "Gonçalves, \\today"
    bibliography_style: str = "ascelike-new"
    
    # Metadados do artigo
    titulo: str
    autores: list
    afiliacoes: list
    keywords: list
```

### Modelo de Mapeamento de Conteúdo

```python
class MapeamentoConteudoASCE:
    # Seções originais → Seções ASCE
    mapeamento_secoes: dict = {
        "abstract": "abstract_environment",
        "introduction": "section_introduction", 
        "methodology": "section_methodology",
        "results": "section_results",
        "discussion": "section_discussion",
        "conclusions": "section_conclusions"
    }
    
    # Seções adicionais obrigatórias ASCE
    secoes_adicionais: dict = {
        "practical_applications": "section_practical_applications",
        "data_availability": "section_data_availability",
        "acknowledgments": "section_acknowledgments"
    }
    
    # Elementos visuais
    figuras: list
    tabelas: list
    equacoes: list
```

### Modelo de Bibliografia ASCE

```python
class BibliografiaASCE:
    # Tipos de entrada suportados
    tipos_entrada: list = [
        "ARTICLE", "BOOK", "INPROCEEDINGS", "INCOLLECTION",
        "TECHREPORT", "MASTERSTHESIS", "PHDTHESIS", "MANUAL", "MISC"
    ]
    
    # Campos obrigatórios por tipo
    campos_obrigatorios: dict = {
        "ARTICLE": ["author", "title", "journal", "year"],
        "BOOK": ["author", "title", "publisher", "year"],
        "INPROCEEDINGS": ["author", "title", "booktitle", "year"],
        "TECHREPORT": ["author", "title", "institution", "year"]
    }
    
    # Campos opcionais
    campos_opcionais: list = [
        "volume", "number", "pages", "address", "edition", 
        "organization", "url", "note", "month"
    ]
```

## Error Handling

### Estratégias de Tratamento de Erros ASCE

#### 1. Validação de Compatibilidade de Pacotes
```python
def validar_compatibilidade_pacotes():
    try:
        pacotes_incompativeis = [
            "natbib",  # Conflita com sistema de citação ASCE
            "cite",    # Incompatível com ascelike-new.bst
            "geometry" # Conflita com layout ASCE
        ]
        
        for pacote in pacotes_documento:
            if pacote in pacotes_incompativeis:
                raise ValueError(f"Pacote incompatível com ASCE: {pacote}")
        
        return True
    except Exception as e:
        log_error(f"Erro de compatibilidade: {e}")
        return False
```

#### 2. Verificação de Estrutura ASCE
```python
def verificar_estrutura_asce(documento):
    try:
        secoes_obrigatorias = [
            "abstract", "practical_applications", "introduction",
            "data_availability", "references"
        ]
        
        secoes_encontradas = extrair_secoes(documento)
        
        for secao in secoes_obrigatorias:
            if secao not in secoes_encontradas:
                raise ValueError(f"Seção obrigatória ASCE ausente: {secao}")
        
        return True
    except Exception as e:
        log_error(f"Erro de estrutura ASCE: {e}")
        return False
```

#### 3. Validação de Bibliografia ASCE
```python
def validar_bibliografia_asce(arquivo_bib):
    try:
        entradas = carregar_entradas_bib(arquivo_bib)
        
        for entrada in entradas:
            # Verificar tipo de entrada válido
            if entrada.tipo not in tipos_asce_validos:
                raise ValueError(f"Tipo de entrada inválido: {entrada.tipo}")
            
            # Verificar campos obrigatórios
            campos_necessarios = campos_obrigatorios[entrada.tipo]
            for campo in campos_necessarios:
                if campo not in entrada.campos:
                    raise ValueError(f"Campo obrigatório ausente: {campo} em {entrada.key}")
        
        return True
    except Exception as e:
        log_error(f"Erro na bibliografia ASCE: {e}")
        return False
```

#### 4. Verificação de Compilação
```python
def verificar_compilacao_asce(arquivo_tex):
    try:
        # Executar pdflatex
        resultado_latex = executar_pdflatex(arquivo_tex)
        if resultado_latex.returncode != 0:
            raise CompilationError("Erro na compilação LaTeX")
        
        # Executar bibtex
        resultado_bibtex = executar_bibtex(arquivo_tex)
        if resultado_bibtex.returncode != 0:
            raise CompilationError("Erro na compilação bibliografia")
        
        # Executar pdflatex novamente (2x para referências)
        for i in range(2):
            resultado_final = executar_pdflatex(arquivo_tex)
            if resultado_final.returncode != 0:
                raise CompilationError(f"Erro na compilação final (passo {i+1})")
        
        return True
    except Exception as e:
        log_error(f"Erro de compilação: {e}")
        return False
```

## Testing Strategy

### Estratégia de Testes para Formato ASCE

#### 1. Testes de Conformidade com Template
```python
def test_conformidade_template_asce():
    """Testa se o documento segue exatamente o template ASCE"""
    # Verificar classe do documento
    assert "ascelike-new" in preambulo
    assert "Journal" in opcoes_classe
    
    # Verificar pacotes obrigatórios
    pacotes_necessarios = ["authblk", "graphicx", "amsmath", "hyperref"]
    for pacote in pacotes_necessarios:
        assert pacote in pacotes_carregados
    
    # Verificar estrutura de seções
    assert "\\begin{abstract}" in documento
    assert "\\section{Practical Applications}" in documento
    assert "\\section{Data Availability Statement}" in documento
```

#### 2. Testes de Bibliografia ASCE
```python
def test_bibliografia_asce():
    """Testa se a bibliografia está no formato ASCE correto"""
    # Verificar estilo bibliográfico
    assert "\\bibliographystyle{ascelike-new}" in documento
    
    # Verificar formato das citações
    citacoes = extrair_citacoes(documento)
    for citacao in citacoes:
        assert re.match(r"\\cite\{[\w:]+\}", citacao)
    
    # Verificar entradas .bib válidas
    entradas_bib = carregar_bibliografia()
    for entrada in entradas_bib:
        assert entrada.tipo in tipos_asce_validos
        assert all(campo in entrada.campos for campo in campos_obrigatorios[entrada.tipo])
```

#### 3. Testes de Elementos Visuais
```python
def test_elementos_visuais_asce():
    """Testa se figuras e tabelas seguem padrão ASCE"""
    # Verificar ambiente de figuras
    figuras = extrair_figuras(documento)
    for figura in figuras:
        assert "\\begin{figure}[htbp]" in figura
        assert "\\centering" in figura
        assert "\\caption{" in figura
        assert "\\label{fig:" in figura
    
    # Verificar ambiente de tabelas
    tabelas = extrair_tabelas(documento)
    for tabela in tabelas:
        assert "\\begin{table}[htbp]" in tabela
        assert "\\caption{" in tabela
        assert "\\label{tab:" in tabela
```

#### 4. Testes de Compilação Completa
```python
def test_compilacao_completa():
    """Testa se o documento compila sem erros"""
    # Compilação LaTeX
    resultado = executar_pdflatex("artigo_asce.tex")
    assert resultado.returncode == 0
    assert "Error" not in resultado.stdout
    
    # Compilação Bibliografia
    resultado_bib = executar_bibtex("artigo_asce")
    assert resultado_bib.returncode == 0
    
    # Compilação final
    for i in range(2):
        resultado_final = executar_pdflatex("artigo_asce.tex")
        assert resultado_final.returncode == 0
    
    # Verificar PDF gerado
    assert os.path.exists("artigo_asce.pdf")
    assert os.path.getsize("artigo_asce.pdf") > 0
```

#### 5. Testes de Preservação de Conteúdo
```python
def test_preservacao_conteudo():
    """Testa se todo o conteúdo científico foi preservado"""
    # Verificar seções principais
    secoes_originais = ["Introduction", "Methodology", "Results", "Discussion", "Conclusions"]
    for secao in secoes_originais:
        assert f"\\section{{{secao}}}" in documento_asce
    
    # Verificar equações numeradas
    equacoes_originais = extrair_equacoes(documento_original)
    equacoes_asce = extrair_equacoes(documento_asce)
    assert len(equacoes_originais) == len(equacoes_asce)
    
    # Verificar figuras e tabelas
    assert numero_figuras_original == numero_figuras_asce
    assert numero_tabelas_original == numero_tabelas_asce
    
    # Verificar referências
    referencias_originais = extrair_referencias(documento_original)
    referencias_asce = extrair_referencias(documento_asce)
    assert len(referencias_originais) == len(referencias_asce)
```

### Critérios de Aceitação para Testes

#### Nível Excelente (E)
- 100% dos testes passam
- Compilação sem warnings ou erros
- Conformidade total com template ASCE
- Preservação completa do conteúdo científico
- Bibliografia 100% compatível com ascelike-new.bst

#### Nível Muito Bom (MB)
- 95% dos testes passam
- Máximo 2 warnings menores na compilação
- Conformidade 98% com template ASCE
- 99% do conteúdo preservado

#### Nível Bom (B)
- 90% dos testes passam
- Máximo 5 warnings na compilação
- Conformidade 95% com template ASCE
- 95% do conteúdo preservado

## Implementation Plan

### Fase 1: Configuração Base ASCE
1. Criar novo arquivo .tex com classe ascelike-new
2. Configurar preâmbulo com pacotes compatíveis
3. Definir metadados (título, autores, afiliações)
4. Configurar sistema de citações ASCE

### Fase 2: Migração de Conteúdo
1. Converter abstract para ambiente ASCE
2. Migrar seções principais preservando conteúdo
3. Adaptar figuras e tabelas para padrão ASCE
4. Converter equações mantendo numeração

### Fase 3: Seções Obrigatórias ASCE
1. Criar seção Practical Applications
2. Adicionar Data Availability Statement
3. Formatar Keywords usando comando ASCE
4. Estruturar Acknowledgments

### Fase 4: Bibliografia e Referências
1. Converter arquivo .bib para formato ASCE
2. Ajustar tipos de entrada e campos
3. Configurar ascelike-new.bst
4. Validar todas as citações

### Fase 5: Validação e Testes
1. Executar suite completa de testes
2. Verificar compilação sem erros
3. Validar conformidade com template
4. Revisar preservação de conteúdo

### Cronograma Estimado
- Fase 1: 2 horas
- Fase 2: 4 horas  
- Fase 3: 2 horas
- Fase 4: 3 horas
- Fase 5: 2 horas
- **Total: 13 horas**

## Quality Assurance

### Checklist de Qualidade ASCE

#### Formatação Geral
- [ ] Classe ascelike-new.cls configurada corretamente
- [ ] Opção Journal selecionada
- [ ] Pacotes compatíveis carregados
- [ ] Encoding UTF-8 configurado

#### Estrutura do Documento
- [ ] Título formatado corretamente
- [ ] Autores e afiliações usando authblk
- [ ] Abstract em ambiente próprio
- [ ] Practical Applications incluída
- [ ] Data Availability Statement presente
- [ ] Seções sem numeração (padrão ASCE)

#### Elementos Visuais
- [ ] Figuras com ambiente figure[htbp]
- [ ] Tabelas com ambiente table[htbp]
- [ ] Legendas seguindo padrão ASCE
- [ ] Referências cruzadas funcionando

#### Bibliografia
- [ ] Arquivo .bib no formato ASCE
- [ ] Estilo ascelike-new.bst aplicado
- [ ] Citações no formato autor-ano
- [ ] Todas as referências resolvidas

#### Compilação
- [ ] pdflatex executa sem erros
- [ ] bibtex processa bibliografia
- [ ] PDF final gerado corretamente
- [ ] Todas as referências cruzadas resolvidas

### Validação Final

O documento será considerado pronto para submissão ASCE quando:
1. Todos os itens do checklist estiverem marcados
2. Compilação produzir PDF sem erros ou warnings
3. Conteúdo científico 100% preservado
4. Formatação 100% conforme template ASCE
5. Bibliografia completamente funcional