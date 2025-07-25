# Documento de Requisitos - Sistema de Comparação U-Net vs Attention U-Net

## Introdução

Este projeto implementa um sistema completo para comparação entre arquiteturas U-Net clássica e Attention U-Net para segmentação semântica de imagens, com foco em detecção de corrosão. O sistema atual está funcional mas precisa de melhorias na organização, documentação e funcionalidades de análise.

## Requisitos

### Requisito 1: Sistema de Comparação Automatizada

**User Story:** Como pesquisador, eu quero executar comparações automatizadas entre U-Net e Attention U-Net, para que eu possa avaliar objetivamente qual modelo tem melhor performance.

#### Critérios de Aceitação

1. QUANDO o usuário executar o sistema ENTÃO o sistema DEVE carregar automaticamente os dados de imagens e máscaras
2. QUANDO os dados forem carregados ENTÃO o sistema DEVE treinar ambos os modelos (U-Net e Attention U-Net) com os mesmos dados
3. QUANDO o treinamento for concluído ENTÃO o sistema DEVE calcular métricas de avaliação (IoU, Dice, Accuracy) para ambos os modelos
4. QUANDO as métricas forem calculadas ENTÃO o sistema DEVE gerar um relatório comparativo mostrando qual modelo teve melhor performance
5. QUANDO a comparação for finalizada ENTÃO o sistema DEVE salvar os modelos treinados e os resultados

### Requisito 2: Interface de Usuário Simplificada

**User Story:** Como usuário, eu quero uma interface simples e intuitiva, para que eu possa usar o sistema sem conhecimento técnico profundo.

#### Critérios de Aceitação

1. QUANDO o usuário iniciar o sistema ENTÃO o sistema DEVE apresentar um menu claro com opções numeradas
2. QUANDO o usuário selecionar uma opção ENTÃO o sistema DEVE executar a funcionalidade correspondente com feedback visual
3. QUANDO ocorrer um erro ENTÃO o sistema DEVE mostrar mensagens de erro claras e sugestões de solução
4. QUANDO o processo estiver em execução ENTÃO o sistema DEVE mostrar progresso e tempo estimado
5. QUANDO o usuário quiser sair ENTÃO o sistema DEVE permitir saída segura a qualquer momento

### Requisito 3: Análise Estatística Avançada

**User Story:** Como pesquisador, eu quero análises estatísticas detalhadas dos resultados, para que eu possa validar cientificamente as diferenças entre os modelos.

#### Critérios de Aceitação

1. QUANDO a comparação for executada ENTÃO o sistema DEVE calcular médias, desvios padrão e intervalos de confiança para todas as métricas
2. QUANDO houver dados suficientes ENTÃO o sistema DEVE executar testes estatísticos (t-test) para verificar significância das diferenças
3. QUANDO os testes forem executados ENTÃO o sistema DEVE reportar p-values e interpretação dos resultados
4. QUANDO solicitado ENTÃO o sistema DEVE executar validação cruzada k-fold para resultados mais robustos
5. QUANDO a análise for concluída ENTÃO o sistema DEVE gerar gráficos comparativos e visualizações

### Requisito 4: Visualização e Relatórios

**User Story:** Como usuário, eu quero visualizações claras dos resultados, para que eu possa entender facilmente as diferenças entre os modelos.

#### Critérios de Aceitação

1. QUANDO a comparação for executada ENTÃO o sistema DEVE gerar comparações visuais lado a lado das predições
2. QUANDO as métricas forem calculadas ENTÃO o sistema DEVE criar gráficos de barras e boxplots comparativos
3. QUANDO solicitado ENTÃO o sistema DEVE gerar relatório em PDF com todos os resultados
4. QUANDO houver diferenças significativas ENTÃO o sistema DEVE destacar visualmente as áreas onde um modelo supera o outro
5. QUANDO o relatório for gerado ENTÃO o sistema DEVE incluir interpretação automática dos resultados

### Requisito 5: Gerenciamento de Dados e Configuração

**User Story:** Como usuário, eu quero que o sistema gerencie automaticamente dados e configurações, para que eu possa focar na análise sem me preocupar com aspectos técnicos.

#### Critérios de Aceitação

1. QUANDO o sistema for executado pela primeira vez ENTÃO o sistema DEVE detectar automaticamente os diretórios de dados
2. QUANDO os dados forem carregados ENTÃO o sistema DEVE validar formato, tamanho e compatibilidade das imagens e máscaras
3. QUANDO houver problemas nos dados ENTÃO o sistema DEVE oferecer correção automática ou sugestões
4. QUANDO a configuração for alterada ENTÃO o sistema DEVE salvar automaticamente para uso futuro
5. QUANDO o sistema for usado em outro computador ENTÃO o sistema DEVE ser facilmente portável

### Requisito 6: Limpeza e Organização do Código

**User Story:** Como desenvolvedor, eu quero um código limpo e bem organizado, para que eu possa manter e expandir o sistema facilmente.

#### Critérios de Aceitação

1. QUANDO o código for revisado ENTÃO todos os arquivos duplicados ou obsoletos DEVEM ser removidos
2. QUANDO as funções forem analisadas ENTÃO cada função DEVE ter uma responsabilidade única e clara
3. QUANDO a documentação for verificada ENTÃO todos os arquivos DEVEM ter cabeçalhos padronizados e comentários claros
4. QUANDO os testes forem executados ENTÃO o sistema DEVE ter cobertura de testes de pelo menos 80%
5. QUANDO o projeto for estruturado ENTÃO os arquivos DEVEM estar organizados em diretórios lógicos

### Requisito 7: Performance e Otimização

**User Story:** Como usuário, eu quero que o sistema execute rapidamente, para que eu possa obter resultados em tempo razoável.

#### Critérios de Aceitação

1. QUANDO o treinamento for iniciado ENTÃO o sistema DEVE usar GPU automaticamente se disponível
2. QUANDO houver muitos dados ENTÃO o sistema DEVE implementar carregamento em lotes para otimizar memória
3. QUANDO o processamento estiver lento ENTÃO o sistema DEVE oferecer modo de teste rápido com amostra reduzida
4. QUANDO o sistema estiver em uso ENTÃO o tempo total de execução NÃO DEVE exceder 30 minutos para datasets típicos
5. QUANDO recursos forem limitados ENTÃO o sistema DEVE ajustar automaticamente parâmetros para funcionar

### Requisito 8: Validação e Testes

**User Story:** Como desenvolvedor, eu quero um sistema robusto de testes, para que eu possa garantir que todas as funcionalidades funcionem corretamente.

#### Critérios de Aceitação

1. QUANDO o sistema for iniciado ENTÃO todos os componentes críticos DEVEM ser testados automaticamente
2. QUANDO uma função for modificada ENTÃO os testes correspondentes DEVEM ser executados
3. QUANDO houver falha em teste ENTÃO o sistema DEVE reportar claramente o problema e localização
4. QUANDO novos dados forem adicionados ENTÃO o sistema DEVE validar compatibilidade automaticamente
5. QUANDO o sistema for implantado ENTÃO todos os testes DEVEM passar com 100% de sucesso