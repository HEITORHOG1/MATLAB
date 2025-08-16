# Documento de Requisitos - Sistema de Segmentação Completo

## Introdução

Este documento define os requisitos para criar um sistema completo de segmentação que treine modelos U-Net e Attention U-Net, faça segmentação das imagens após treinamento, compare os resultados e organize tudo de forma clara e funcional.

## Requisitos

### Requisito 1: Treinamento de Modelos U-Net e Attention U-Net

**User Story:** Como usuário, eu quero treinar dois modelos (U-Net e Attention U-Net) usando as máscaras e imagens originais, para que eu possa comparar a performance de ambos.

#### Critérios de Aceitação

1. QUANDO o sistema for executado ENTÃO deve treinar automaticamente o modelo U-Net usando as imagens em `C:\Users\heito\Documents\MATLAB\img\original` e máscaras em `C:\Users\heito\Documents\MATLAB\img\masks`
2. QUANDO o treinamento U-Net for concluído ENTÃO deve treinar automaticamente o modelo Attention U-Net com os mesmos dados
3. QUANDO cada modelo for treinado ENTÃO deve salvar automaticamente o modelo treinado com nome identificável
4. QUANDO o treinamento for concluído ENTÃO deve exibir métricas de treinamento (loss, accuracy) para cada modelo
5. QUANDO houver erro no treinamento ENTÃO deve exibir mensagem clara e parar a execução

### Requisito 2: Segmentação das Imagens Após Treinamento

**User Story:** Como usuário, eu quero que os modelos treinados sejam aplicados nas imagens de `C:\Users\heito\Documents\MATLAB\img\imagens apos treinamento\original`, para que eu possa ver os resultados da segmentação.

#### Critérios de Aceitação

1. QUANDO os modelos estiverem treinados ENTÃO deve carregar automaticamente as imagens de `C:\Users\heito\Documents\MATLAB\img\imagens apos treinamento\original`
2. QUANDO as imagens forem carregadas ENTÃO deve aplicar o modelo U-Net em todas as imagens
3. QUANDO a segmentação U-Net for concluída ENTÃO deve aplicar o modelo Attention U-Net nas mesmas imagens
4. QUANDO cada segmentação for gerada ENTÃO deve salvar a imagem segmentada com nome identificável
5. QUANDO todas as segmentações forem concluídas ENTÃO deve exibir mensagem de sucesso

### Requisito 3: Organização dos Resultados de Segmentação

**User Story:** Como usuário, eu quero que as imagens segmentadas sejam organizadas em pastas separadas por modelo, para que eu possa comparar facilmente os resultados.

#### Critérios de Aceitação

1. QUANDO as segmentações forem geradas ENTÃO deve criar pasta `resultados_segmentacao/unet/` para resultados do U-Net
2. QUANDO as segmentações forem geradas ENTÃO deve criar pasta `resultados_segmentacao/attention_unet/` para resultados do Attention U-Net
3. QUANDO as imagens forem salvas ENTÃO deve usar nomenclatura consistente (ex: `img001_unet.png`, `img001_attention.png`)
4. QUANDO a organização for concluída ENTÃO deve criar arquivo de índice listando todas as imagens processadas
5. QUANDO houver erro na organização ENTÃO deve criar as pastas automaticamente e continuar

### Requisito 4: Comparação e Análise dos Resultados

**User Story:** Como usuário, eu quero comparar visualmente e numericamente os resultados dos dois modelos, para que eu possa determinar qual modelo tem melhor performance.

#### Critérios de Aceitação

1. QUANDO as segmentações estiverem prontas ENTÃO deve calcular métricas de comparação (IoU, Dice, Accuracy) para cada modelo
2. QUANDO as métricas forem calculadas ENTÃO deve gerar relatório comparativo em formato texto
3. QUANDO o relatório for gerado ENTÃO deve criar visualizações lado a lado das segmentações
4. QUANDO as visualizações forem criadas ENTÃO deve destacar diferenças entre os modelos
5. QUANDO a análise for concluída ENTÃO deve salvar relatório final com conclusões

### Requisito 5: Limpeza e Organização do Código

**User Story:** Como desenvolvedor, eu quero que o código seja limpo e organizado, removendo arquivos desnecessários e mantendo apenas o essencial para o funcionamento.

#### Critérios de Aceitação

1. QUANDO o sistema for analisado ENTÃO deve identificar arquivos de código duplicados ou obsoletos
2. QUANDO arquivos obsoletos forem identificados ENTÃO deve criar lista de arquivos para remoção
3. QUANDO a limpeza for aprovada ENTÃO deve remover arquivos desnecessários mantendo backup
4. QUANDO o código for limpo ENTÃO deve reorganizar arquivos em estrutura lógica
5. QUANDO a reorganização for concluída ENTÃO deve criar documentação atualizada do sistema

### Requisito 6: Interface de Execução Simples

**User Story:** Como usuário, eu quero executar todo o processo com um comando simples, para que eu não precise executar múltiplos scripts manualmente.

#### Critérios de Aceitação

1. QUANDO o usuário executar o script principal ENTÃO deve executar automaticamente: treinamento → segmentação → comparação
2. QUANDO cada etapa for iniciada ENTÃO deve exibir mensagem clara do que está sendo executado
3. QUANDO houver progresso ENTÃO deve mostrar barra de progresso ou percentual concluído
4. QUANDO houver erro ENTÃO deve parar e exibir mensagem clara do problema
5. QUANDO tudo for concluído ENTÃO deve exibir resumo final com localização dos resultados