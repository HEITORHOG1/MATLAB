# Módulo de Dados - Sistema de Comparação U-Net vs Attention U-Net

## Visão Geral

Este módulo fornece classes unificadas para carregamento, pré-processamento e validação de dados para o sistema de comparação entre U-Net e Attention U-Net.

## Classes Implementadas

### 1. DataLoader
Classe responsável pelo carregamento unificado de dados com suporte a múltiplos formatos.

**Funcionalidades:**
- Carregamento robusto de imagens e máscaras
- Suporte a múltiplos formatos (PNG, JPG, JPEG, BMP, TIFF)
- Divisão automática em conjuntos de treino/validação/teste
- Validação de correspondência entre imagens e máscaras

**Exemplo de uso:**
```matlab
config = struct('imageDir', 'img/original', 'maskDir', 'img/masks', 'inputSize', [256, 256, 3]);
loader = DataLoader(config);
[images, masks] = loader.loadData();
[trainData, valData, testData] = loader.splitData(images, masks);
```

### 2. DataPreprocessor
Classe otimizada para pré-processamento com cache inteligente e conversões de tipo otimizadas.

**Funcionalidades:**
- Redimensionamento e normalização de imagens
- Conversão otimizada categorical/single para evitar erros
- Data augmentation configurável
- Cache de dados preprocessados para melhor performance
- Suporte a processamento em lote

**Exemplo de uso:**
```matlab
preprocessor = DataPreprocessor(config, 'EnableCache', true);
processedData = preprocessor.preprocess({imagePath, maskPath}, 'IsTraining', true, 'UseAugmentation', true);
```

### 3. DataValidator
Classe para validação automática e correção de problemas comuns em datasets.

**Funcionalidades:**
- Validação de formato de arquivos
- Verificação de consistência entre imagens e máscaras
- Correção automática de problemas comuns
- Relatórios detalhados de validação
- Detecção e remoção de duplicatas

**Exemplo de uso:**
```matlab
validator = DataValidator(config);
isValid = validator.validateDataFormat(imagePath, maskPath);
isConsistent = validator.checkDataConsistency(images, masks);
[correctedImages, correctedMasks] = validator.autoCorrectData(images, masks);
```

## Melhorias Implementadas

### Em relação ao código anterior:

1. **Modularidade**: Separação clara de responsabilidades em classes especializadas
2. **Robustez**: Tratamento abrangente de erros e casos extremos
3. **Performance**: Cache inteligente e otimizações de memória
4. **Usabilidade**: Interface consistente e documentação clara
5. **Manutenibilidade**: Código bem estruturado e testável

### Correções Críticas:

1. **Conversões de Tipo**: Otimização das conversões categorical/single para evitar erros no trainNetwork
2. **Validação de Dados**: Verificação automática de formatos e dimensões
3. **Correspondência**: Algoritmo robusto para matching de imagens e máscaras
4. **Cache**: Sistema de cache para melhorar performance em datasets grandes

## Requisitos Atendidos

- **Requisito 5.1**: Sistema unificado de carregamento de dados ✅
- **Requisito 5.2**: Validação automática de dados e correção de problemas ✅
- **Requisito 5.3**: Pré-processamento otimizado com cache ✅
- **Requisito 7.2**: Otimizações de performance e memória ✅

## Testes

Execute o teste unitário para validar o funcionamento:

```matlab
test_data_module()
```

## Tutorial MATLAB

Para referência completa sobre as funcionalidades utilizadas, consulte:
- [MATLAB Deep Learning Toolbox](https://www.mathworks.com/support/learn-with-matlab-tutorials.html)
- [Image Processing Toolbox](https://www.mathworks.com/help/images/)

## Compatibilidade

- MATLAB R2019b ou superior
- Deep Learning Toolbox
- Image Processing Toolbox
- Statistics and Machine Learning Toolbox (opcional, para análises avançadas)