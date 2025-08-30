# Sistema de Validação de Qualidade Científica I-R-B-MB-E

## Visão Geral

O Sistema de Validação de Qualidade Científica implementa critérios automatizados para avaliar artigos científicos seguindo:

- **Estrutura IMRAD**: Introdução, Metodologia, Resultados, Análise e Discussão
- **Critérios I-R-B-MB-E**: Insuficiente, Regular, Bom, Muito Bom, Excelente
- **Integridade Bibliográfica**: Verificação de citações e referências

## Arquivos Implementados

### Classe Principal
- `src/validation/ValidadorQualidadeCientifica.m` - Classe principal do sistema de validação

### Scripts de Execução
- `executar_validacao_qualidade.m` - Script para executar validação completa
- `validar_sistema_qualidade.m` - Script para validar o próprio sistema

### Scripts de Teste
- `tests/teste_validacao_qualidade.m` - Testes unitários do sistema

## Funcionalidades Implementadas

### 1. Validação de Estrutura IMRAD

**Método**: `validar_estrutura_imrad()`

**Verifica**:
- Presença de seções obrigatórias: Introdução, Metodologia, Resultados, Discussão, Conclusões, Referências
- Completude da estrutura (percentual)
- Identificação de seções ausentes

**Saída**:
```matlab
resultado_imrad = struct(
    'secoes_encontradas', {...},
    'secoes_ausentes', {...},
    'estrutura_valida', true/false,
    'pontuacao', numero,
    'percentual_completude', percentual
);
```

### 2. Validação de Qualidade por Seção (I-R-B-MB-E)

**Método**: `validar_qualidade_secoes()`

**Critérios por Seção**:

#### Introdução
- Contextualização
- Formulação do problema
- Objetivos claros
- Justificativa
- Relevância científica

#### Metodologia
- Reprodutibilidade
- Detalhamento adequado
- Descrição de materiais
- Procedimentos claros
- Métricas definidas

#### Resultados
- Dados concretos
- Evidências apresentadas
- Análise estatística
- Visualizações adequadas
- Objetividade

#### Discussão
- Interpretação dos resultados
- Limitações identificadas
- Implicações práticas
- Trabalhos futuros
- Conexão com objetivos

#### Conclusões
- Resposta aos objetivos
- Síntese adequada
- Contribuições claras
- Resumo de limitações
- Recomendações

**Níveis de Qualidade**:
- **E (Excelente)**: 4.5-5.0 pontos
- **MB (Muito Bom)**: 3.5-4.4 pontos
- **B (Bom)**: 2.5-3.4 pontos
- **R (Regular)**: 1.5-2.4 pontos
- **I (Insuficiente)**: 0.0-1.4 pontos

### 3. Verificação de Integridade Bibliográfica

**Método**: `verificar_referencias_bibliograficas()`

**Verifica**:
- Citações presentes no texto LaTeX
- Referências disponíveis no arquivo .bib
- Citações quebradas (sem entrada no .bib)
- Referências não citadas

**Padrões de Citação Suportados**:
- `\cite{chave}`
- `\citep{chave}`
- `\citet{chave}`
- `\ref{chave}`

### 4. Geração de Relatório Consolidado

**Método**: `gerar_relatorio_qualidade()`

**Inclui**:
- Pontuação geral consolidada
- Nível de qualidade geral
- Recomendações específicas
- Relatório detalhado salvo em arquivo
- Resumo no console

## Como Usar

### Validação Completa

```matlab
% Executar validação completa
resultado = executar_validacao_qualidade();

% Ou usar diretamente a classe
validador = ValidadorQualidadeCientifica();
resultado = validador.validar_artigo_completo('artigo_cientifico_corrosao.tex', 'referencias.bib');
```

### Validações Específicas

```matlab
validador = ValidadorQualidadeCientifica();

% Apenas estrutura IMRAD
resultado_imrad = validador.validar_estrutura_imrad();

% Apenas qualidade das seções
resultado_qualidade = validador.validar_qualidade_secoes();

% Apenas referências
resultado_referencias = validador.verificar_referencias_bibliograficas();
```

### Executar Testes

```matlab
% Testar o sistema
teste_validacao_qualidade();

% Validar o próprio sistema
validar_sistema_qualidade();
```

## Estrutura do Relatório Gerado

O sistema gera automaticamente um relatório detalhado com:

```
=== RELATÓRIO DE VALIDAÇÃO DE QUALIDADE CIENTÍFICA ===

Data/Hora: 2025-08-30 10:20:21
Arquivo do artigo: artigo_cientifico_corrosao.tex
Arquivo de referências: referencias.bib

--- AVALIAÇÃO GERAL ---
Nível de qualidade: MB
Pontuação geral: 3.67/5.0

--- ESTRUTURA IMRAD ---
Estrutura válida: SIM
Completude: 100.0%
Seções encontradas: introducao, metodologia, resultados, discussao, conclusoes, referencias

--- QUALIDADE POR SEÇÃO ---
Qualidade geral: B (3.20 pontos)
  introducao: B (3.00 pontos)
  metodologia: MB (4.00 pontos)
  resultados: B (3.20 pontos)
  discussao: B (2.80 pontos)
  conclusoes: B (3.00 pontos)

--- REFERÊNCIAS BIBLIOGRÁFICAS ---
Integridade: SIM
Total de citações: 34
Total de referências: 47
Citações quebradas: 0

--- RECOMENDAÇÕES ---
Artigo atende aos critérios de qualidade científica!
```

## Critérios de Aprovação

### Para Submissão Científica

- **Aprovado**: Nível E (Excelente) ou MB (Muito Bom)
- **Necessita Melhorias**: Nível B (Bom)
- **Requer Revisão**: Nível R (Regular) ou I (Insuficiente)

### Requisitos Mínimos

1. **Estrutura IMRAD**: 100% completa
2. **Qualidade Geral**: Mínimo nível B (Bom)
3. **Integridade Bibliográfica**: Zero citações quebradas
4. **Reprodutibilidade**: Metodologia detalhada

## Personalização

### Adicionar Novos Critérios

Edite o método `inicializar_criterios()` na classe `ValidadorQualidadeCientifica`:

```matlab
% Adicionar critério para nova seção
obj.criterios_qualidade.nova_secao = {
    'criterio1', 'criterio2', 'criterio3'
};
```

### Modificar Palavras-chave

Edite o método `obter_palavras_chave_criterio()`:

```matlab
case 'novo_criterio'
    palavras = {'palavra1', 'palavra2', 'palavra3'};
```

### Ajustar Níveis de Qualidade

Modifique o método `converter_pontuacao_para_nivel()`:

```matlab
if pontuacao >= 4.8  % Mais rigoroso para Excelente
    nivel = 'E';
% ... outros níveis
```

## Integração com Workflow

O sistema se integra perfeitamente com o workflow de criação do artigo científico:

1. **Desenvolvimento**: Usar durante a escrita para monitorar qualidade
2. **Revisão**: Executar antes de cada revisão importante
3. **Finalização**: Validação final antes da submissão
4. **Automação**: Integrar em pipelines de CI/CD acadêmico

## Requisitos Atendidos

- ✅ **Requisito 1.2**: Critérios de qualidade I-R-B-MB-E implementados
- ✅ **Requisito 2.1**: Estrutura IMRAD validada automaticamente
- ✅ **Requisito 5.3**: Integridade de referências bibliográficas verificada

## Limitações e Considerações

### Limitações Atuais

1. **Análise Semântica**: Sistema baseado em palavras-chave, não compreensão semântica
2. **Idioma**: Otimizado para português, pode precisar ajustes para outros idiomas
3. **Formato**: Específico para LaTeX, necessita adaptação para outros formatos

### Melhorias Futuras

1. **IA Semântica**: Integração com modelos de linguagem para análise mais profunda
2. **Múltiplos Formatos**: Suporte para Word, Markdown, etc.
3. **Métricas Avançadas**: Análise de legibilidade, coesão textual
4. **Interface Gráfica**: Dashboard web para visualização de resultados

## Suporte e Manutenção

### Logs e Debugging

O sistema gera logs detalhados para debugging:
- Erros são capturados e reportados
- Stack traces completos em caso de falha
- Relatórios salvos automaticamente com timestamp

### Atualizações

Para atualizar critérios ou adicionar funcionalidades:
1. Modifique a classe `ValidadorQualidadeCientifica`
2. Execute `validar_sistema_qualidade()` para verificar integridade
3. Execute `teste_validacao_qualidade()` para testes unitários
4. Atualize esta documentação conforme necessário

---

**Desenvolvido para**: Projeto de Detecção de Corrosão com Deep Learning  
**Versão**: 1.0  
**Data**: Agosto 2025  
**Status**: ✅ Implementado e Testado