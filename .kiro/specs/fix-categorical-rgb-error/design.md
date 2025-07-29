# Design Document

## Overview

O sistema apresenta múltiplos problemas interconectados:

### Problema 1: Incompatibilidade de Tipos
O sistema está tentando aplicar operações RGB em dados categorical, causando erros recorrentes.

### Problema 2: Lógica de Conversão Categorical Incorreta
A lógica atual `double(categorical) > 1` para converter categorical para binário está causando:
- Métricas artificialmente perfeitas (1.0000 ± 0.0000)
- Inconsistência entre diferentes funções
- Resultados não confiáveis

### Problema 3: Inconsistência na Criação de Categorical
Diferentes funções criam dados categorical de formas inconsistentes:
- Alguns usam `[0, 1]` como labelIDs
- Outros podem usar diferentes mapeamentos
- Isso causa problemas na conversão `double(categorical)`

### Problema 4: Visualização Incorreta
A conversão para visualização não está funcionando corretamente, gerando imagens de comparação inválidas.

A solução envolve:
1. **Padronizar criação de categorical** em todo o sistema
2. **Corrigir lógica de conversão** para métricas
3. **Implementar validação de resultados** para detectar problemas
4. **Criar sistema robusto de conversão** para visualização

## Architecture

### Componentes Principais

1. **DataTypeConverter**: Classe utilitária para conversões seguras entre tipos
2. **PreprocessingValidator**: Validador que verifica tipos antes do processamento
3. **VisualizationHelper**: Utilitário específico para preparar dados para visualização
4. **ErrorHandler**: Sistema de tratamento de erros com recuperação graceful

### Fluxo de Dados

```
Dados de Entrada → Validação de Tipos → Conversão Necessária → Processamento → Saída
                                    ↓
                              Tratamento de Erros
```

## Components and Interfaces

### 1. DataTypeConverter

```matlab
classdef DataTypeConverter < handle
    methods (Static)
        function output = categoricalToNumeric(data, targetType)
        function output = numericToCategorical(data, classNames, labelIDs)
        function isValid = validateDataType(data, expectedTypes)
        function output = safeConversion(data, targetType, context)
    end
end
```

**Responsabilidades:**
- Converter dados categorical para tipos numéricos (uint8, double, single)
- Converter dados numéricos para categorical quando necessário
- Validar tipos de dados antes de conversões
- Fornecer conversões seguras com tratamento de erros

### 2. PreprocessingValidator

```matlab
classdef PreprocessingValidator < handle
    methods (Static)
        function validateImageData(img)
        function validateMaskData(mask)
        function data = prepareForRGBOperation(data)
        function data = prepareForCategoricalOperation(data)
    end
end
```

**Responsabilidades:**
- Validar dados de imagem antes do processamento
- Validar dados de máscara antes do processamento
- Preparar dados para operações RGB específicas
- Preparar dados para operações categorical específicas

### 3. VisualizationHelper

```matlab
classdef VisualizationHelper < handle
    methods (Static)
        function imgData = prepareImageForDisplay(img)
        function maskData = prepareMaskForDisplay(mask)
        function [img, mask, pred] = prepareComparisonData(img, mask, pred)
        function success = safeImshow(data, varargin)
    end
end
```

**Responsabilidades:**
- Preparar imagens para visualização com imshow
- Preparar máscaras para visualização
- Preparar dados para comparação visual
- Implementar imshow seguro com tratamento de erros

### 4. MetricsValidator

```matlab
classdef MetricsValidator < handle
    methods (Static)
        function isValid = validateMetrics(metrics)
        function warnings = checkPerfectMetrics(iou, dice, accuracy)
        function corrected = correctCategoricalConversion(categorical_data)
        function validated = validateCategoricalStructure(data)
    end
end
```

**Responsabilidades:**
- Detectar métricas artificialmente perfeitas
- Validar estrutura de dados categorical
- Corrigir conversões categorical para binário
- Alertar sobre problemas nos resultados

### 5. Funções de Pré-processamento Corrigidas

Modificar as funções existentes:
- `preprocessDataCorrigido.m` - Padronizar criação de categorical
- `preprocessDataMelhorado.m` - Corrigir inconsistências
- `calcular_iou_simples.m` - Corrigir lógica de conversão
- `calcular_dice_simples.m` - Corrigir lógica de conversão
- `calcular_accuracy_simples.m` - Corrigir lógica de conversão
- Função de visualização em `comparacao_unet_attention_final.m`

## Data Models

### Tipos de Dados Suportados

1. **Imagens**: 
   - Entrada: uint8, double, single
   - Processamento: single (normalizado [0,1])
   - Visualização: uint8 ou double

2. **Máscaras**:
   - Entrada: uint8, double, categorical
   - Processamento: categorical para treinamento
   - Visualização: uint8 (0-255) ou double (0-1)

3. **Predições**:
   - Saída do modelo: categorical
   - Visualização: uint8 convertido
   - Métricas: double binário

### Mapeamentos de Conversão

**PROBLEMA IDENTIFICADO**: A lógica atual `double(categorical) > 1` está incorreta!

**Lógica Correta**:
```matlab
% CORRETO: Categorical para binário
categorical → binary: (data == "foreground")  % Retorna logical
categorical → double: double(data == "foreground")  % Retorna 0/1

% INCORRETO (atual): 
% double(categorical) > 1  % Depende de como categorical foi criado!

% Categorical para visualização
categorical → uint8: uint8(data == "foreground") * 255
categorical → double: double(data == "foreground")

% Numérico para categorical (PADRONIZADO)
uint8 → categorical: categorical(data > threshold, [0,1], ["background","foreground"])
double → categorical: categorical(data > 0.5, [0,1], ["background","foreground"])
logical → categorical: categorical(data, [false,true], ["background","foreground"])
```

**Validação de Categorical**:
```matlab
% Verificar se categorical foi criado corretamente
categories(data)  % Deve retornar ["background", "foreground"]
double(data)      % Deve retornar 1 para background, 2 para foreground
```

## Error Handling

### Estratégias de Recuperação

1. **Detecção Precoce**: Validar tipos antes de operações críticas
2. **Conversão Automática**: Aplicar conversões quando tipos incompatíveis são detectados
3. **Fallback Seguro**: Usar implementações alternativas quando conversões falham
4. **Logging Detalhado**: Registrar todos os erros e conversões para debugging

### Pontos Críticos de Tratamento

1. **Pré-processamento**: Antes de aplicar rgb2gray, imresize
2. **Visualização**: Antes de imshow, saveas
3. **Avaliação**: Antes de calcular métricas
4. **Transformações**: Durante transform() de datastores

## Testing Strategy

### Testes Unitários

1. **DataTypeConverter**:
   - Testar conversões categorical ↔ numérico
   - Testar validação de tipos
   - Testar casos extremos (dados vazios, tipos inválidos)

2. **PreprocessingValidator**:
   - Testar validação de imagens e máscaras
   - Testar preparação para operações RGB
   - Testar preparação para operações categorical

3. **VisualizationHelper**:
   - Testar preparação de dados para visualização
   - Testar imshow seguro
   - Testar casos de erro

### Testes de Integração

1. **Pipeline Completo**: Testar fluxo completo de dados
2. **Compatibilidade**: Testar com dados existentes
3. **Performance**: Verificar impacto das conversões
4. **Robustez**: Testar com dados corrompidos ou inválidos

### Testes de Regressão

1. **Funcionalidade Existente**: Garantir que correções não quebrem funcionalidades
2. **Métricas**: Verificar que resultados numéricos permanecem consistentes
3. **Visualizações**: Confirmar que visualizações são geradas corretamente

## Implementation Plan

### Fase 1: Utilitários Base
- Implementar DataTypeConverter
- Implementar PreprocessingValidator
- Criar testes unitários básicos

### Fase 2: Correção de Pré-processamento
- Modificar preprocessDataCorrigido.m
- Modificar preprocessDataMelhorado.m
- Integrar validação de tipos

### Fase 3: Correção de Visualização
- Implementar VisualizationHelper
- Corrigir função de visualização
- Testar geração de imagens

### Fase 4: Integração e Testes
- Integrar todas as correções
- Executar testes completos
- Validar com dados reais

## Performance Considerations

- Conversões de tipo devem ser minimizadas para evitar overhead
- Cache de conversões quando apropriado
- Validação eficiente de tipos usando funções MATLAB otimizadas
- Evitar cópias desnecessárias de dados grandes