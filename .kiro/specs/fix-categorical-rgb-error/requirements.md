# Requirements Document

## Introduction

O sistema de comparação de modelos U-Net está apresentando múltiplos problemas críticos:

1. **Erros de Tipo Categorical**: Erro recorrente "Expected RGB to be one of these types... Instead its type was categorical" durante pré-processamento, treinamento, avaliação e visualização.

2. **Métricas Artificialmente Perfeitas**: Todas as métricas (IoU, Dice, Acurácia) estão retornando 1.0000 ± 0.0000, indicando erro grave na lógica de cálculo ou processamento de dados.

3. **Visualizações Incorretas**: A imagem de comparação visual está sendo gerada incorretamente devido a problemas na conversão de dados categorical para visualização.

4. **Inconsistência no Pipeline**: Diferentes funções estão criando e processando dados categorical de formas inconsistentes, causando erros em cascata.

Estes problemas impedem a avaliação correta dos modelos e geram resultados não confiáveis.

## Requirements

### Requirement 1: Correção do Pré-processamento de Dados

**User Story:** Como desenvolvedor do sistema, eu quero que o pré-processamento de dados funcione corretamente, para que os modelos possam ser treinados e avaliados sem erros de tipo de dados.

#### Acceptance Criteria

1. WHEN dados categorical são processados THEN o sistema SHALL converter corretamente para tipos numéricos antes de operações RGB
2. WHEN máscaras são processadas THEN o sistema SHALL manter consistência entre tipos categorical e numéricos
3. WHEN funções como rgb2gray são chamadas THEN o sistema SHALL garantir que os dados de entrada sejam do tipo correto
4. WHEN dados são transformados THEN o sistema SHALL validar tipos antes de aplicar transformações

### Requirement 2: Correção da Função de Visualização

**User Story:** Como usuário do sistema, eu quero que as visualizações sejam geradas sem erros, para que eu possa ver os resultados da comparação entre modelos.

#### Acceptance Criteria

1. WHEN a função de visualização é chamada THEN o sistema SHALL converter dados categorical para tipos apropriados para imshow
2. WHEN máscaras categorical são processadas THEN o sistema SHALL converter para uint8 ou double antes da visualização
3. WHEN predições são visualizadas THEN o sistema SHALL garantir compatibilidade de tipos entre ground truth e predições
4. WHEN comparações visuais são geradas THEN o sistema SHALL salvar as imagens sem erros de tipo

### Requirement 3: Validação e Tratamento de Tipos de Dados

**User Story:** Como desenvolvedor, eu quero que o sistema valide e trate corretamente os tipos de dados, para que não ocorram erros de incompatibilidade durante o processamento.

#### Acceptance Criteria

1. WHEN dados são carregados THEN o sistema SHALL validar os tipos de dados antes do processamento
2. WHEN conversões de tipo são necessárias THEN o sistema SHALL aplicar conversões seguras e consistentes
3. WHEN erros de tipo ocorrem THEN o sistema SHALL fornecer mensagens de erro claras e recuperação graceful
4. WHEN dados categorical são detectados THEN o sistema SHALL aplicar conversões apropriadas automaticamente

### Requirement 4: Correção da Lógica de Cálculo de Métricas

**User Story:** Como pesquisador, eu quero que as métricas de avaliação sejam calculadas corretamente, para que eu possa confiar nos resultados da comparação entre modelos.

#### Acceptance Criteria

1. WHEN métricas são calculadas THEN o sistema SHALL usar lógica correta para conversão categorical para binário
2. WHEN dados categorical são processados THEN o sistema SHALL garantir que a conversão `double(categorical)` seja interpretada corretamente
3. WHEN comparações são feitas THEN o sistema SHALL produzir métricas realistas (não artificialmente perfeitas)
4. WHEN diferentes amostras são avaliadas THEN o sistema SHALL mostrar variação natural nas métricas

### Requirement 5: Consistência no Pipeline de Dados

**User Story:** Como usuário do sistema, eu quero que todo o pipeline de dados funcione de forma consistente, para que eu possa executar comparações completas sem interrupções.

#### Acceptance Criteria

1. WHEN o pipeline de treinamento é executado THEN o sistema SHALL manter consistência de tipos em todas as etapas
2. WHEN a avaliação é executada THEN o sistema SHALL processar dados sem erros de tipo categorical
3. WHEN múltiplas amostras são processadas THEN o sistema SHALL manter consistência de tipos entre todas as amostras
4. WHEN o sistema completa uma execução THEN o sistema SHALL gerar todos os outputs esperados sem erros de tipo

### Requirement 6: Validação de Resultados

**User Story:** Como pesquisador, eu quero que o sistema valide a qualidade dos resultados gerados, para que eu possa identificar quando algo está errado.

#### Acceptance Criteria

1. WHEN métricas são calculadas THEN o sistema SHALL validar se os resultados são realistas
2. WHEN métricas perfeitas são detectadas THEN o sistema SHALL alertar sobre possíveis problemas
3. WHEN visualizações são geradas THEN o sistema SHALL validar se as imagens foram criadas corretamente
4. WHEN comparações são feitas THEN o sistema SHALL verificar se há diferenças significativas entre modelos