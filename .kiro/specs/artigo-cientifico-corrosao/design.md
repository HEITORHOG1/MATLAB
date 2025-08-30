# Design Document

## Overview

Este documento apresenta o design detalhado para a criação de um artigo científico rigoroso sobre "Detecção Automatizada de Corrosão em Vigas W ASTM A572 Grau 50 Utilizando Redes Neurais Convolucionais: Análise Comparativa entre U-Net e Attention U-Net para Segmentação Semântica". O artigo seguirá os mais altos padrões acadêmicos, estrutura IMRAD, e critérios de qualidade I-R-B-MB-E visando nível Excelente.

## Architecture

### Estrutura do Artigo (IMRAD)

```
artigo_cientifico_corrosao.tex
├── 1. Título e Metadados
├── 2. Resumo (Abstract)
├── 3. Palavras-chave (Keywords)
├── 4. Introdução
│   ├── 4.1 Contextualização da corrosão em estruturas metálicas
│   ├── 4.2 Formulação do problema de detecção automatizada
│   ├── 4.3 Objetivos da pesquisa (geral e específicos)
│   └── 4.4 Justificativa e relevância científica
├── 5. Revisão da Literatura
│   ├── 5.1 Deep Learning para Inspeção Estrutural
│   ├── 5.2 Arquiteturas U-Net em Segmentação Médica e Industrial
│   ├── 5.3 Mecanismos de Atenção em Redes Convolucionais
│   └── 5.4 Detecção de Corrosão: Estado da Arte
├── 6. Metodologia
│   ├── 6.1 Caracterização do Material (ASTM A572 Grau 50)
│   ├── 6.2 Aquisição e Preparação do Dataset
│   ├── 6.3 Arquiteturas de Redes Neurais
│   ├── 6.4 Protocolo Experimental
│   └── 6.5 Métricas de Avaliação
├── 7. Resultados
│   ├── 7.1 Análise Descritiva do Dataset
│   ├── 7.2 Performance das Arquiteturas
│   ├── 7.3 Análise Comparativa Quantitativa
│   └── 7.4 Análise Qualitativa das Segmentações
├── 8. Discussão
│   ├── 8.1 Interpretação dos Resultados
│   ├── 8.2 Implicações Práticas para Inspeção Estrutural
│   ├── 8.3 Limitações do Estudo
│   └── 8.4 Direções para Pesquisas Futuras
├── 9. Conclusões
├── 10. Agradecimentos
├── 11. Referências Bibliográficas
└── 12. Apêndices
    ├── A. Especificações Técnicas Detalhadas
    ├── B. Código-fonte e Reprodutibilidade
    └── C. Dados Suplementares
```

### Sistema de Referências Bibliográficas

```
referencias.bib
├── Seção 1: Deep Learning e Computer Vision
├── Seção 2: Arquiteturas U-Net e Variantes
├── Seção 3: Mecanismos de Atenção
├── Seção 4: Detecção de Corrosão e Inspeção Estrutural
├── Seção 5: Materiais ASTM A572
├── Seção 6: Métricas de Segmentação Semântica
└── Seção 7: Normas e Padrões Técnicos
```

## Components and Interfaces

### Componente 1: Sistema de Geração de Conteúdo Científico

**Interface:** `GeradorConteudoCientifico`

**Responsabilidades:**
- Gerar seções do artigo seguindo padrões IMRAD
- Aplicar critérios de qualidade I-R-B-MB-E
- Integrar resultados experimentais do projeto existente
- Manter consistência terminológica e técnica

**Métodos principais:**
- `gerarIntroducao()`: Contextualização integrada sem subtítulos
- `gerarRevisaoLiteratura()`: Seções baseadas em palavras-chave das perguntas de pesquisa
- `gerarMetodologia()`: Descrição detalhada para reprodutibilidade
- `gerarResultados()`: Apresentação de dados concretos com evidências
- `gerarDiscussao()`: Interpretação conectada às perguntas de pesquisa

### Componente 2: Sistema de Integração de Dados Experimentais

**Interface:** `IntegradorDadosExperimentais`

**Responsabilidades:**
- Extrair métricas dos resultados do projeto MATLAB
- Processar dados de treinamento e validação
- Gerar tabelas e figuras científicas
- Calcular estatísticas comparativas

**Dados a serem integrados:**
- Métricas de performance (IoU, Dice, Accuracy, F1-Score)
- Tempos de treinamento e inferência
- Curvas de aprendizado
- Análises de convergência
- Comparações estatísticas entre arquiteturas

### Componente 3: Sistema de Geração de Visualizações Científicas

**Interface:** `GeradorVisualizacoesCientificas`

**Responsabilidades:**
- Criar diagramas arquiteturais das redes neurais
- Gerar gráficos de resultados (boxplots, heatmaps, curvas ROC)
- Produzir comparações visuais de segmentações
- Criar tabelas formatadas para publicação

**Visualizações necessárias:**
1. Diagrama da arquitetura U-Net clássica
2. Diagrama da arquitetura Attention U-Net
3. Fluxograma da metodologia experimental
4. Gráficos comparativos de métricas
5. Exemplos de segmentações bem-sucedidas e falhas
6. Heatmaps de mapas de atenção
7. Curvas de aprendizado durante treinamento

### Componente 4: Sistema de Validação de Qualidade Científica

**Interface:** `ValidadorQualidadeCientifica`

**Responsabilidades:**
- Aplicar checklist I-R-B-MB-E para cada seção
- Verificar consistência de referências bibliográficas
- Validar estrutura IMRAD
- Garantir rigor metodológico

**Critérios de validação:**
- Título: Completo, objetivo, preciso, sintético
- Resumo: Propósito claro, metodologia, resultados principais
- Introdução: Contextualização integrada, objetivos claros
- Metodologia: Reprodutibilidade completa
- Resultados: Evidências concretas, resposta às perguntas de pesquisa
- Discussão: Interpretação baseada em evidências
- Conclusões: Apropriadas aos objetivos estabelecidos

## Data Models

### Modelo de Dados Experimentais

```python
class DadosExperimentais:
    # Configurações de treinamento
    configuracao_treinamento: {
        'epochs': int,
        'batch_size': int,
        'learning_rate': float,
        'validation_split': float,
        'optimizer': str
    }
    
    # Métricas de performance
    metricas_unet: {
        'iou': float,
        'dice': float,
        'accuracy': float,
        'precision': float,
        'recall': float,
        'f1_score': float,
        'tempo_treinamento': float,
        'tempo_inferencia': float
    }
    
    metricas_attention_unet: {
        'iou': float,
        'dice': float,
        'accuracy': float,
        'precision': float,
        'recall': float,
        'f1_score': float,
        'tempo_treinamento': float,
        'tempo_inferencia': float
    }
    
    # Análise estatística
    analise_estatistica: {
        'teste_t_student': dict,
        'intervalos_confianca': dict,
        'significancia_estatistica': bool,
        'effect_size': float
    }
    
    # Dataset
    caracteristicas_dataset: {
        'total_imagens': int,
        'resolucao_imagens': tuple,
        'distribuicao_classes': dict,
        'divisao_treino_validacao_teste': dict
    }
```

### Modelo de Estrutura do Artigo

```python
class EstruturaArtigo:
    titulo: str
    autores: list
    afiliacao: str
    resumo: str
    palavras_chave: list
    
    secoes: {
        'introducao': {
            'contextualizacao': str,
            'problema': str,
            'objetivos': str,
            'justificativa': str
        },
        'revisao_literatura': {
            'deep_learning_inspecao': str,
            'arquiteturas_unet': str,
            'mecanismos_atencao': str,
            'deteccao_corrosao': str
        },
        'metodologia': {
            'caracterizacao_material': str,
            'dataset': str,
            'arquiteturas': str,
            'protocolo_experimental': str,
            'metricas': str
        },
        'resultados': {
            'analise_dataset': str,
            'performance_arquiteturas': str,
            'comparacao_quantitativa': str,
            'analise_qualitativa': str
        },
        'discussao': {
            'interpretacao': str,
            'implicacoes_praticas': str,
            'limitacoes': str,
            'trabalhos_futuros': str
        },
        'conclusoes': str
    }
    
    referencias: list
    figuras: list
    tabelas: list
```

## Error Handling

### Estratégias de Tratamento de Erros

#### 1. Validação de Dados Experimentais
```python
def validar_dados_experimentais(dados):
    try:
        # Verificar completude das métricas
        if not all(key in dados.metricas_unet for key in ['iou', 'dice', 'accuracy']):
            raise ValueError("Métricas incompletas para U-Net")
        
        # Verificar valores válidos (0-1 para métricas)
        for metrica, valor in dados.metricas_unet.items():
            if metrica in ['iou', 'dice', 'accuracy'] and not 0 <= valor <= 1:
                raise ValueError(f"Valor inválido para {metrica}: {valor}")
        
        return True
    except Exception as e:
        log_error(f"Erro na validação de dados: {e}")
        return False
```

#### 2. Verificação de Referências Bibliográficas
```python
def verificar_referencias(arquivo_bib, citacoes_texto):
    try:
        # Carregar arquivo .bib
        referencias_disponiveis = carregar_referencias_bib(arquivo_bib)
        
        # Extrair citações do texto
        citacoes_encontradas = extrair_citacoes(citacoes_texto)
        
        # Verificar se todas as citações têm entrada no .bib
        citacoes_quebradas = []
        for citacao in citacoes_encontradas:
            if citacao not in referencias_disponiveis:
                citacoes_quebradas.append(citacao)
        
        if citacoes_quebradas:
            raise ValueError(f"Referências quebradas: {citacoes_quebradas}")
        
        return True
    except Exception as e:
        log_error(f"Erro na verificação de referências: {e}")
        return False
```

#### 3. Validação de Qualidade por Seção
```python
def validar_qualidade_secao(secao, conteudo, criterios_imrad):
    try:
        pontuacao = 0
        feedback = []
        
        # Aplicar critérios específicos por seção
        if secao == 'introducao':
            if 'contextualização' in conteudo.lower():
                pontuacao += 1
            else:
                feedback.append("Falta contextualização clara")
            
            if 'objetivo' in conteudo.lower():
                pontuacao += 1
            else:
                feedback.append("Objetivos não claramente definidos")
        
        # Classificar qualidade (I-R-B-MB-E)
        if pontuacao >= 4:
            qualidade = 'E'  # Excelente
        elif pontuacao >= 3:
            qualidade = 'MB'  # Muito Bom
        elif pontuacao >= 2:
            qualidade = 'B'   # Bom
        elif pontuacao >= 1:
            qualidade = 'R'   # Regular
        else:
            qualidade = 'I'   # Insuficiente
        
        return qualidade, feedback
    except Exception as e:
        log_error(f"Erro na validação de qualidade: {e}")
        return 'I', [f"Erro na validação: {e}"]
```

## Testing Strategy

### Estratégia de Testes para Qualidade Científica

#### 1. Testes de Estrutura IMRAD
```python
def test_estrutura_imrad():
    """Testa se o artigo segue corretamente a estrutura IMRAD"""
    secoes_obrigatorias = [
        'introducao', 'metodologia', 'resultados', 
        'discussao', 'conclusoes', 'referencias'
    ]
    
    for secao in secoes_obrigatorias:
        assert secao in artigo.secoes, f"Seção {secao} ausente"
        assert len(artigo.secoes[secao]) > 0, f"Seção {secao} vazia"
```

#### 2. Testes de Qualidade I-R-B-MB-E
```python
def test_qualidade_minima():
    """Testa se cada seção atinge qualidade mínima 'B' (Bom)"""
    for secao, conteudo in artigo.secoes.items():
        qualidade, feedback = validar_qualidade_secao(secao, conteudo)
        assert qualidade in ['B', 'MB', 'E'], f"Seção {secao} com qualidade {qualidade}: {feedback}"
```

#### 3. Testes de Integridade de Referências
```python
def test_referencias_completas():
    """Testa se todas as citações têm entrada correspondente no .bib"""
    citacoes = extrair_citacoes_do_artigo()
    referencias_bib = carregar_referencias_bib()
    
    for citacao in citacoes:
        assert citacao in referencias_bib, f"Referência quebrada: {citacao}"
```

#### 4. Testes de Dados Experimentais
```python
def test_dados_experimentais_validos():
    """Testa se os dados experimentais são válidos e completos"""
    # Verificar métricas U-Net
    assert 0 <= dados.metricas_unet['iou'] <= 1
    assert 0 <= dados.metricas_unet['dice'] <= 1
    assert 0 <= dados.metricas_unet['accuracy'] <= 1
    
    # Verificar métricas Attention U-Net
    assert 0 <= dados.metricas_attention_unet['iou'] <= 1
    assert 0 <= dados.metricas_attention_unet['dice'] <= 1
    assert 0 <= dados.metricas_attention_unet['accuracy'] <= 1
    
    # Verificar análise estatística
    assert 'teste_t_student' in dados.analise_estatistica
    assert 'intervalos_confianca' in dados.analise_estatistica
```

#### 5. Testes de Reprodutibilidade
```python
def test_reprodutibilidade():
    """Testa se a metodologia permite reprodução completa"""
    elementos_reprodutibilidade = [
        'configuracao_hardware',
        'versoes_software',
        'parametros_treinamento',
        'divisao_dataset',
        'metricas_avaliacao',
        'codigo_fonte_disponivel'
    ]
    
    for elemento in elementos_reprodutibilidade:
        assert elemento in artigo.metodologia, f"Elemento de reprodutibilidade ausente: {elemento}"
```

### Critérios de Aceitação para Testes

#### Nível Excelente (E)
- Todos os testes passam sem exceções
- Qualidade I-R-B-MB-E ≥ 'MB' em todas as seções
- Zero referências quebradas
- Dados experimentais completos e válidos
- Reprodutibilidade 100% garantida

#### Nível Muito Bom (MB)
- 95% dos testes passam
- Qualidade I-R-B-MB-E ≥ 'B' em 90% das seções
- Máximo 1 referência quebrada (corrigível)
- Dados experimentais 95% completos

#### Nível Bom (B)
- 90% dos testes passam
- Qualidade I-R-B-MB-E ≥ 'B' em 80% das seções
- Máximo 3 referências quebradas
- Dados experimentais 90% completos

### Automação de Testes

```python
def executar_suite_testes_completa():
    """Executa todos os testes de qualidade científica"""
    resultados = {
        'estrutura_imrad': test_estrutura_imrad(),
        'qualidade_minima': test_qualidade_minima(),
        'referencias_completas': test_referencias_completas(),
        'dados_experimentais': test_dados_experimentais_validos(),
        'reprodutibilidade': test_reprodutibilidade()
    }
    
    # Gerar relatório de qualidade
    gerar_relatorio_qualidade(resultados)
    
    # Determinar nível geral de qualidade
    nivel_qualidade = determinar_nivel_qualidade(resultados)
    
    return nivel_qualidade, resultados
```

## Especificações de Figuras e Tabelas

### Figuras Necessárias

#### Figura 1: Arquitetura U-Net Clássica
- **Localização:** Seção Metodologia (6.3)
- **Descrição:** Diagrama detalhado da arquitetura U-Net mostrando encoder, decoder, skip connections
- **Especificações técnicas:** Resolução 300 DPI, formato vetorial (SVG/EPS)
- **Prompt para geração:** "Criar diagrama técnico da arquitetura U-Net para segmentação semântica, mostrando: (1) Encoder com blocos convolucionais e max pooling, (2) Bottleneck central, (3) Decoder com upsampling e concatenações, (4) Skip connections conectando encoder-decoder, (5) Dimensões das feature maps em cada nível, (6) Funções de ativação (ReLU, Sigmoid), (7) Cores diferenciadas para cada tipo de operação"

#### Figura 2: Arquitetura Attention U-Net
- **Localização:** Seção Metodologia (6.3)
- **Descrição:** Diagrama da Attention U-Net destacando mecanismos de atenção
- **Especificações técnicas:** Resolução 300 DPI, formato vetorial
- **Prompt para geração:** "Criar diagrama técnico da arquitetura Attention U-Net, baseado na U-Net clássica mas incluindo: (1) Attention Gates entre encoder e decoder, (2) Mecanismo de atenção com queries, keys e values, (3) Mapas de atenção coloridos mostrando regiões de foco, (4) Multiplicação elemento-wise dos attention weights, (5) Comparação lado-a-lado com U-Net clássica destacando diferenças, (6) Fluxo de informação através dos attention gates"

#### Figura 3: Fluxograma da Metodologia Experimental
- **Localização:** Seção Metodologia (6.4)
- **Descrição:** Fluxograma completo do protocolo experimental
- **Prompt para geração:** "Criar fluxograma científico da metodologia experimental mostrando: (1) Aquisição de imagens de vigas W ASTM A572 Grau 50, (2) Anotação manual de regiões de corrosão, (3) Pré-processamento (normalização, augmentação), (4) Divisão train/validation/test (70/15/15), (5) Treinamento paralelo U-Net e Attention U-Net, (6) Validação cruzada k-fold, (7) Avaliação com métricas IoU/Dice/F1, (8) Análise estatística comparativa, (9) Geração de relatórios"

#### Figura 4: Comparação Visual de Segmentações
- **Localização:** Seção Resultados (7.4)
- **Descrição:** Grid comparativo mostrando imagens originais, ground truth, U-Net e Attention U-Net
- **Prompt para geração:** "Criar grid de comparação visual 4x3 mostrando: Coluna 1 - Imagens originais de vigas com corrosão, Coluna 2 - Ground truth (máscaras manuais), Coluna 3 - Segmentação U-Net, Coluna 4 - Segmentação Attention U-Net. Incluir 3 casos: (1) Segmentação bem-sucedida, (2) Caso desafiador com corrosão sutil, (3) Caso de falha/limitação. Usar cores consistentes: vermelho para corrosão, azul para metal saudável"

#### Figura 5: Gráficos de Performance Comparativa
- **Localização:** Seção Resultados (7.2)
- **Descrição:** Boxplots das métricas IoU, Dice, F1-Score para ambas arquiteturas
- **Prompt para geração:** "Criar conjunto de boxplots científicos comparando U-Net vs Attention U-Net: (1) Três subplots lado-a-lado para IoU, Dice e F1-Score, (2) Boxplots com mediana, quartis, outliers, (3) Cores diferenciadas (azul U-Net, laranja Attention U-Net), (4) Valores de significância estatística (p-values), (5) Intervalos de confiança 95%, (6) Eixos padronizados 0-1, (7) Grid de fundo sutil, (8) Legendas claras"

#### Figura 6: Curvas de Aprendizado
- **Localização:** Seção Resultados (7.2)
- **Descrição:** Curvas de loss e accuracy durante treinamento
- **Prompt para geração:** "Criar gráficos de curvas de aprendizado: (1) Subplot superior: Training/Validation Loss vs Epochs para U-Net e Attention U-Net, (2) Subplot inferior: Training/Validation Accuracy vs Epochs, (3) Linhas suaves com cores diferenciadas, (4) Legendas claras, (5) Marcadores de convergência, (6) Área sombreada para intervalos de confiança, (7) Eixos bem rotulados"

#### Figura 7: Mapas de Atenção (Attention U-Net)
- **Localização:** Seção Resultados (7.4)
- **Descrição:** Visualização dos mapas de atenção gerados pela Attention U-Net
- **Prompt para geração:** "Criar visualização de mapas de atenção: (1) Imagem original de viga com corrosão, (2) Heatmap de atenção sobreposto (cores quentes = alta atenção), (3) Múltiplos níveis de atenção (encoder layers), (4) Comparação com regiões de corrosão real, (5) Escala de cores (azul-verde-amarelo-vermelho), (6) Barra de escala de intensidade"

### Tabelas Necessárias

#### Tabela 1: Características do Dataset
- **Localização:** Seção Metodologia (6.2)
- **Conteúdo:** Total de imagens, resolução, distribuição de classes, divisão train/val/test
- **Formato:** Tabela científica com bordas, cabeçalhos em negrito

#### Tabela 2: Configurações de Treinamento
- **Localização:** Seção Metodologia (6.4)
- **Conteúdo:** Hiperparâmetros, otimizadores, funções de loss, hardware utilizado
- **Formato:** Duas colunas (Parâmetro, Valor)

#### Tabela 3: Resultados Quantitativos Comparativos
- **Localização:** Seção Resultados (7.3)
- **Conteúdo:** Métricas médias ± desvio padrão, intervalos de confiança, p-values
- **Formato:** Tabela comparativa com significância estatística destacada

#### Tabela 4: Análise de Tempo Computacional
- **Localização:** Seção Resultados (7.2)
- **Conteúdo:** Tempo de treinamento, tempo de inferência, uso de memória
- **Formato:** Comparação direta entre arquiteturas

## Cronograma de Implementação

### Fase 1: Preparação e Estruturação (Tarefas 1-3)
- Criação da estrutura base do artigo
- Configuração do sistema de referências
- Preparação dos templates de seções

### Fase 2: Desenvolvimento do Conteúdo Principal (Tarefas 4-8)
- Redação da introdução integrada
- Desenvolvimento da revisão da literatura
- Elaboração da metodologia detalhada
- Integração dos resultados experimentais

### Fase 3: Análise e Discussão (Tarefas 9-11)
- Apresentação e análise dos resultados
- Discussão científica aprofundada
- Formulação das conclusões

### Fase 4: Elementos Visuais e Finalizações (Tarefas 12-15)
- Criação de todas as figuras e tabelas
- Formatação final do documento
- Revisão completa de qualidade
- Validação final I-R-B-MB-E