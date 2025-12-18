# Requirements Document

## Introduction

O professor solicitou simplificação do artigo para focar nas métricas essenciais e adicionar imagens de exemplo para melhor compreensão do problema de classificação de corrosão. O artigo deve apresentar apenas acurácia de validação, loss de validação e matriz de confusão, além de incluir exemplos visuais das três classes de corrosão.

## Glossary

- **Article**: O documento LaTeX `artigo_pure_classification.tex`
- **Validation Metrics**: Métricas calculadas no conjunto de validação (dados não vistos durante treino)
- **Confusion Matrix**: Matriz que mostra predições corretas e incorretas por classe
- **Sample Images**: Imagens reais do dataset mostrando exemplos de cada classe de corrosão
- **Loss**: Função de perda que mede o erro do modelo durante treinamento

## Requirements

### Requirement 1

**User Story:** Como leitor do artigo, quero ver apenas as métricas essenciais de validação, para entender o desempenho real dos modelos sem informações redundantes

#### Acceptance Criteria

1. WHEN o artigo apresenta resultados, THE Article SHALL display only validation accuracy, validation loss, and confusion matrix
2. THE Article SHALL remove all precision, recall, F1-score, and statistical test results from tables and text
3. THE Article SHALL remove training accuracy and training loss from all figures and tables
4. THE Article SHALL emphasize that all reported metrics are from validation set
5. THE Article SHALL maintain comparison between Custom CNN, ResNet50, and EfficientNet-B0 using only the simplified metrics

### Requirement 2

**User Story:** Como leitor do artigo, quero ver exemplos visuais das três classes de corrosão, para entender claramente o problema que está sendo resolvido

#### Acceptance Criteria

1. THE Article SHALL include a new figure showing sample images from the dataset
2. THE Article SHALL display at least 2 examples per class (Class 0: No Corrosion, Class 1: Moderate, Class 2: Severe)
3. THE Article SHALL place sample images in the Introduction or Methodology section
4. THE Article SHALL add clear captions explaining each corrosion class
5. WHERE sample images are shown, THE Article SHALL use real images from the actual dataset

### Requirement 3

**User Story:** Como autor do artigo, quero que as figuras de resultados mostrem apenas curvas de validação, para manter consistência com as métricas reportadas

#### Acceptance Criteria

1. THE Article SHALL modify training history plots to show only validation curves
2. THE Article SHALL remove training accuracy curves from all plots
3. THE Article SHALL remove training loss curves from all plots
4. THE Article SHALL keep validation accuracy and validation loss in separate or combined plots
5. THE Article SHALL update figure captions to reflect validation-only metrics

### Requirement 4

**User Story:** Como autor do artigo, quero que as tabelas de resultados sejam simplificadas, para apresentar apenas acurácia e loss de validação

#### Acceptance Criteria

1. THE Article SHALL create simplified results table with columns: Model, Validation Accuracy, Validation Loss
2. THE Article SHALL remove all columns for precision, recall, F1-score from results tables
3. THE Article SHALL keep confusion matrices for each model
4. THE Article SHALL remove statistical significance tests (Wilcoxon, McNemar) from tables
5. THE Article SHALL update table captions to reflect simplified metrics

### Requirement 5

**User Story:** Como autor do artigo, quero que o texto seja atualizado para refletir as mudanças nas métricas, para manter coerência entre texto e resultados

#### Acceptance Criteria

1. THE Article SHALL update Results section to discuss only validation accuracy, loss, and confusion matrix
2. THE Article SHALL remove all text discussing precision, recall, F1-score, and statistical tests
3. THE Article SHALL update Discussion section to focus on validation performance
4. THE Article SHALL remove references to training metrics in all text
5. THE Article SHALL maintain clear explanation of why validation metrics are the focus
