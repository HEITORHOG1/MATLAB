# Documentação do Sistema de Segmentação Completo

## Visão Geral

O Sistema de Segmentação Completo é uma solução integrada para treinamento, segmentação e comparação de modelos U-Net e Attention U-Net. O sistema automatiza todo o pipeline desde o treinamento até a geração de relatórios comparativos.

## Estrutura do Sistema

```
projeto/
├── executar_sistema_completo.m     # Script principal - executa tudo
├── teste_integracao_sistema_completo.m  # Testes de integração
├── DOCUMENTACAO_SISTEMA_COMPLETO.md     # Esta documentação
├── src/
│   ├── treinamento/
│   │   ├── TreinadorUNet.m         # Treina modelo U-Net
│   │   └── TreinadorAttentionUNet.m # Treina modelo Attention U-Net
│   ├── segmentacao/
│   │   ├── SegmentadorImagens.m    # Aplica modelos nas imagens
│   │   └── executar_segmentacao_standalone.m # Segmentação independente
│   ├── organization/
│   │   └── OrganizadorResultados.m # Organiza resultados em pastas
│   ├── comparacao/
│   │   └── ComparadorModelos.m     # Compara performance dos modelos
│   └── limpeza/
│       └── LimpadorCodigo.m        # Remove arquivos desnecessários
├── logs/                           # Logs de execução
├── examples/                       # Exemplos de uso dos componentes
├── tests/                          # Testes unitários e de integração
└── resultados_segmentacao/         # Pasta de saída (criada automaticamente)
    ├── unet/                       # Resultados U-Net
    ├── attention_unet/             # Resultados Attention U-Net
    ├── comparacoes/                # Comparações lado a lado
    ├── relatorios/                 # Relatórios e métricas
    └── modelos/                    # Modelos treinados
```

## Como Usar o Sistema

### 1. Execução Completa (Recomendado)

Para executar todo o pipeline automaticamente:

```matlab
% No MATLAB, execute:
executar_sistema_completo()
```

Este comando irá:
1. Verificar configuração inicial e caminhos
2. Treinar modelos U-Net e Attention U-Net
3. Segmentar imagens de teste com ambos os modelos
4. Organizar resultados em estrutura de pastas
5. Comparar modelos e gerar relatórios

### 2. Teste de Integração (Antes da Primeira Execução)

Antes de executar com o dataset completo, recomenda-se testar a integração:

```matlab
% Teste todos os componentes:
teste_integracao_sistema_completo()
```

### 3. Execução de Componentes Individuais

Se necessário, você pode executar componentes individualmente:

#### Treinamento apenas do U-Net:
```matlab
addpath(genpath('src'));
treinador = TreinadorUNet('caminho/imagens', 'caminho/mascaras');
modelo = treinador.treinar();
```

#### Treinamento apenas do Attention U-Net:
```matlab
addpath(genpath('src'));
treinador = TreinadorAttentionUNet('caminho/imagens', 'caminho/mascaras');
modelo = treinador.treinar();
```

#### Segmentação com modelos existentes:
```matlab
addpath(genpath('src'));
segmentador = SegmentadorImagens('caminho/imagens', modelo_unet, modelo_attention, 'pasta_saida');
segmentador.segmentar();
```

#### Organização de resultados:
```matlab
addpath(genpath('src'));
OrganizadorResultados.organizar();
```

#### Comparação de modelos:
```matlab
addpath(genpath('src'));
ComparadorModelos.comparar();
```

## Configuração do Sistema

### Caminhos Padrão

O sistema está configurado para usar os seguintes caminhos:

- **Imagens para treinamento:** `C:\Users\heito\Documents\MATLAB\img\original`
- **Máscaras para treinamento:** `C:\Users\heito\Documents\MATLAB\img\masks`
- **Imagens para segmentação:** `C:\Users\heito\Documents\MATLAB\img\imagens apos treinamento\original`
- **Pasta de saída:** `resultados_segmentacao/`

### Modificando Caminhos

Para usar caminhos diferentes, modifique a função `verificar_configuracao_inicial()` no arquivo `executar_sistema_completo.m`:

```matlab
% Exemplo de modificação:
config.caminhos.imagens_originais = 'seu/caminho/imagens';
config.caminhos.mascaras = 'seu/caminho/mascaras';
config.caminhos.imagens_teste = 'seu/caminho/teste';
config.caminhos.saida = 'sua_pasta_saida';
```

### Parâmetros de Treinamento

Os parâmetros padrão de treinamento são:

```matlab
config.treinamento.epochs = 50;
config.treinamento.batch_size = 8;
config.treinamento.learning_rate = 0.001;
config.treinamento.validation_split = 0.2;
```

Para modificar, edite a função `verificar_configuracao_inicial()`.

## Resultados Gerados

### Estrutura de Saída

Após a execução, os resultados são organizados em:

```
resultados_segmentacao/
├── unet/
│   ├── img001_unet.png
│   ├── img002_unet.png
│   └── ...
├── attention_unet/
│   ├── img001_attention.png
│   ├── img002_attention.png
│   └── ...
├── comparacoes/
│   ├── comparacao_img001.png
│   ├── comparacao_img002.png
│   └── ...
├── relatorios/
│   ├── relatorio_comparativo.txt
│   ├── metricas_unet.mat
│   ├── metricas_attention.mat
│   ├── resumo_final.html
│   └── indice_arquivos.txt
└── modelos/
    ├── modelo_unet.mat
    └── modelo_attention_unet.mat
```

### Tipos de Arquivos

- **`.png`**: Imagens segmentadas e comparações visuais
- **`.txt`**: Relatórios em formato texto
- **`.mat`**: Modelos treinados e dados de métricas
- **`.html`**: Relatórios formatados (quando disponível)

## Logs e Monitoramento

### Sistema de Logging

O sistema gera logs automáticos em `logs/execucao_YYYY-MM-DD_HH-MM-SS.log` contendo:

- Timestamps de cada etapa
- Mensagens de progresso
- Erros e warnings
- Informações de debug

### Monitoramento de Progresso

Durante a execução, o sistema exibe:

```
========================================
  SISTEMA DE SEGMENTAÇÃO COMPLETO
========================================

[1/5] Verificando configuração inicial...
✅ Configuração verificada com sucesso!

[2/5] Iniciando treinamento dos modelos...
  → Treinando modelo U-Net...
  ✅ U-Net treinado com sucesso
  → Treinando modelo Attention U-Net...
  ✅ Attention U-Net treinado com sucesso
✅ Treinamento concluído com sucesso!

[3/5] Aplicando modelos nas imagens de teste...
  → 10 imagens encontradas para segmentação
  ✅ Segmentação concluída para todas as imagens
✅ Segmentação concluída com sucesso!

[4/5] Organizando resultados...
  ✅ Resultados organizados em estrutura de pastas
✅ Resultados organizados com sucesso!

[5/5] Comparando modelos e gerando relatórios...
  ✅ Comparação concluída e relatórios gerados
✅ Comparação concluída com sucesso!

========================================
🎉 EXECUÇÃO CONCLUÍDA COM SUCESSO! 🎉
========================================
Resultados salvos em: resultados_segmentacao
Log de execução: logs/execucao_2025-08-15_14-30-25.log
Tempo total de execução: 45.30 minutos
```

## Tratamento de Erros

### Tipos de Erros Comuns

1. **Caminhos não encontrados**
   - Erro: `Imagens originais para treinamento não encontrado`
   - Solução: Verificar se os caminhos estão corretos

2. **Falta de memória**
   - Erro: `Out of memory`
   - Solução: Reduzir batch_size ou usar imagens menores

3. **Modelos não encontrados**
   - Erro: `Modelos não disponíveis para segmentação`
   - Solução: Executar treinamento primeiro

4. **Permissões de arquivo**
   - Erro: `Permission denied`
   - Solução: Verificar permissões de escrita nas pastas

### Recuperação de Erros

O sistema implementa recuperação automática:

- Cria pastas automaticamente se não existirem
- Carrega modelos de arquivos se não estiverem na memória
- Continua execução mesmo com componentes faltando (com warnings)

## Requisitos do Sistema

### Software Necessário

- MATLAB R2019b ou superior
- Deep Learning Toolbox
- Image Processing Toolbox
- Computer Vision Toolbox (recomendado)

### Hardware Recomendado

- **RAM:** Mínimo 8GB, recomendado 16GB+
- **GPU:** NVIDIA com suporte CUDA (opcional, mas recomendado)
- **Armazenamento:** 5GB+ livres para resultados

### Formatos de Imagem Suportados

- PNG (recomendado)
- JPG/JPEG
- TIFF
- BMP

## Solução de Problemas

### Problema: "Componentes não encontrados"
**Solução:** Execute `addpath(genpath('src'))` antes de usar o sistema.

### Problema: "Treinamento muito lento"
**Solução:** 
- Reduza o número de epochs
- Diminua o batch_size
- Use GPU se disponível

### Problema: "Imagens não segmentadas"
**Solução:**
- Verifique se os modelos foram treinados
- Confirme formato das imagens de entrada
- Verifique permissões da pasta de saída

### Problema: "Relatórios não gerados"
**Solução:**
- Confirme que a segmentação foi concluída
- Verifique se há resultados nas pastas unet/ e attention_unet/
- Execute apenas a comparação: `ComparadorModelos.comparar()`

## Exemplos de Uso

### Exemplo 1: Execução Completa Padrão

```matlab
% Execução simples com configurações padrão
executar_sistema_completo()
```

### Exemplo 2: Teste Antes da Execução

```matlab
% Testar integração primeiro
teste_integracao_sistema_completo()

% Se todos os testes passaram, executar sistema completo
executar_sistema_completo()
```

### Exemplo 3: Execução com Monitoramento

```matlab
% Executar com monitoramento detalhado
tic;
executar_sistema_completo()
tempo_total = toc;
fprintf('Tempo total: %.2f minutos\n', tempo_total/60);
```

## Manutenção e Atualizações

### Limpeza de Código

Para limpar arquivos desnecessários:

```matlab
addpath(genpath('src'));
LimpadorCodigo.limpar();
```

### Backup de Resultados

Recomenda-se fazer backup dos resultados importantes:

```matlab
% Criar backup com timestamp
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
pasta_backup = sprintf('backup_resultados_%s', timestamp);
copyfile('resultados_segmentacao', pasta_backup);
```

### Atualização de Componentes

Para atualizar componentes individuais, substitua os arquivos em `src/` e execute:

```matlab
clear classes; % Limpar classes carregadas
addpath(genpath('src')); % Recarregar caminhos
```

## Suporte e Contato

Para problemas ou dúvidas:

1. Verifique os logs em `logs/`
2. Execute os testes de integração
3. Consulte esta documentação
4. Verifique os exemplos em `examples/`

## Histórico de Versões

### Versão 1.0 (Agosto 2025)
- Implementação inicial do sistema completo
- Integração de todos os componentes
- Sistema de logging e tratamento de erros
- Documentação completa
- Testes de integração

---

**Última atualização:** Agosto 2025  
**Versão da documentação:** 1.0