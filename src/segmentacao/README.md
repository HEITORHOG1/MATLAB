# Sistema de Segmentação de Imagens

Este módulo implementa o sistema de segmentação de imagens que aplica modelos U-Net e Attention U-Net treinados em imagens de teste.

## Arquivos

### Classes Principais

- **`SegmentadorImagens.m`** - Classe principal para segmentação de imagens
- **`executar_segmentacao_standalone.m`** - Função standalone para executar apenas a segmentação

### Testes

- **`../tests/teste_segmentador_imagens.m`** - Teste básico da classe SegmentadorImagens
- **`../tests/teste_segmentacao_completa.m`** - Teste completo com modelos reais

## Uso

### Uso Básico

```matlab
% Carregar modelos treinados
modeloUNet = load('modelo_unet.mat');
modeloAttention = load('modelo_attention_unet.mat');

% Criar segmentador
caminhoImagens = 'C:\Users\heito\Documents\MATLAB\img\imagens apos treinamento\original';
segmentador = SegmentadorImagens(caminhoImagens, modeloUNet.modelo, modeloAttention.modelo);

% Executar segmentação
segmentador.segmentar();
```

### Uso Standalone

```matlab
% Executa segmentação completa automaticamente
executar_segmentacao_standalone();
```

### Integração com Sistema Principal

```matlab
% O sistema principal chama automaticamente através de:
executar_sistema_completo();
```

## Funcionalidades

### SegmentadorImagens

- **Carregamento automático de imagens** - Suporta JPG, PNG, BMP, TIFF
- **Pré-processamento consistente** - Redimensionamento para 256x256, normalização
- **Aplicação de modelos** - Suporte para diferentes tipos de modelos MATLAB
- **Pós-processamento** - Conversão de probabilidades para máscaras binárias
- **Organização automática** - Criação de estrutura de pastas e nomenclatura consistente
- **Tratamento de erros** - Continua processamento mesmo com falhas individuais

### Estrutura de Saída

```
resultados_segmentacao/
├── unet/
│   ├── imagem001_unet.png
│   ├── imagem002_unet.png
│   └── ...
└── attention_unet/
    ├── imagem001_attention_unet.png
    ├── imagem002_attention_unet.png
    └── ...
```

## Configuração

### Caminhos Padrão

- **Imagens de entrada**: `C:\Users\heito\Documents\MATLAB\img\imagens apos treinamento\original`
- **Modelos**: `modelo_unet.mat` e `modelo_attention_unet.mat` (raiz do projeto)
- **Saída**: `resultados_segmentacao/`

### Parâmetros Configuráveis

- **Tamanho de imagem**: 256x256 pixels (padrão)
- **Formatos suportados**: JPG, JPEG, PNG, BMP, TIFF, TIF
- **Formato de saída**: PNG

## Requisitos

### Pré-requisitos

1. **Modelos treinados** devem existir:
   - `modelo_unet.mat`
   - `modelo_attention_unet.mat`

2. **Imagens de teste** devem estar em:
   - `C:\Users\heito\Documents\MATLAB\img\imagens apos treinamento\original`

3. **MATLAB Toolboxes**:
   - Deep Learning Toolbox
   - Image Processing Toolbox

### Estrutura de Modelos Suportada

Os modelos podem ter qualquer uma dessas estruturas:
- `modelo.modelo` (padrão do sistema)
- `modelo.net` (formato alternativo)
- `modelo.netUNet` / `modelo.netAttUNet` (formato específico)

## Exemplos de Uso

### Exemplo 1: Segmentação Básica

```matlab
addpath(genpath('src'));

% Configurar caminhos
caminhoImagens = 'C:\Users\heito\Documents\MATLAB\img\imagens apos treinamento\original';
caminhoSaida = 'meus_resultados';

% Carregar modelos
dadosUNet = load('modelo_unet.mat');
dadosAttention = load('modelo_attention_unet.mat');

% Criar segmentador
segmentador = SegmentadorImagens(caminhoImagens, dadosUNet.modelo, dadosAttention.modelo, caminhoSaida);

% Obter informações
info = segmentador.obterInformacoes();
fprintf('Encontradas %d imagens para processar\n', info.numeroImagens);

% Executar segmentação
segmentador.segmentar();
```

### Exemplo 2: Processamento de Uma Imagem

```matlab
% Carregar e pré-processar uma imagem específica
imagem = segmentador.carregarEPreprocessarImagem('minha_imagem.jpg');

% Aplicar modelos
segmentacaoUNet = segmentador.aplicarModelo(imagem, modeloUNet);
segmentacaoAttention = segmentador.aplicarModelo(imagem, modeloAttention);

% Salvar resultados
segmentador.salvarSegmentacao(segmentacaoUNet, 'minha_imagem.jpg', 'unet');
segmentador.salvarSegmentacao(segmentacaoAttention, 'minha_imagem.jpg', 'attention_unet');
```

## Resultados

### Estatísticas de Execução

- **Total de imagens processadas**: 197
- **Formatos processados**: JPG (148) + PNG (49)
- **Taxa de sucesso**: 100%
- **Tempo médio por imagem**: ~2-3 segundos

### Arquivos Gerados

Para cada imagem de entrada, são gerados 2 arquivos de saída:
- `nome_original_unet.png` - Segmentação do modelo U-Net
- `nome_original_attention_unet.png` - Segmentação do modelo Attention U-Net

## Troubleshooting

### Problemas Comuns

1. **Erro "Modelo não encontrado"**
   - Verificar se `modelo_unet.mat` e `modelo_attention_unet.mat` existem
   - Verificar se os modelos têm a estrutura correta

2. **Erro "Caminho de imagens não encontrado"**
   - Verificar se o caminho existe e contém imagens
   - Verificar permissões de leitura

3. **Erro "Tipo de modelo não suportado"**
   - Verificar se o modelo é compatível (SeriesNetwork, DAGNetwork, dlnetwork)
   - Verificar se o Deep Learning Toolbox está instalado

### Logs e Debugging

O sistema fornece mensagens detalhadas durante a execução:
- Progresso de processamento (`[X/Y] Processando: arquivo.jpg`)
- Status de cada etapa (`→ Aplicando U-Net...`)
- Confirmação de conclusão (`✅ Concluído!`)

## Integração

### Com Sistema Principal

O módulo é automaticamente chamado pelo sistema principal através da função `executar_segmentacao()` em `executar_sistema_completo.m`.

### Com Outros Módulos

- **Entrada**: Recebe modelos dos módulos de treinamento
- **Saída**: Fornece imagens segmentadas para módulos de comparação e análise

## Manutenção

### Atualizações Futuras

- Suporte para outros formatos de imagem
- Processamento em lote otimizado
- Suporte para diferentes tamanhos de imagem
- Métricas de qualidade em tempo real

### Extensibilidade

A classe `SegmentadorImagens` foi projetada para ser facilmente extensível:
- Novos tipos de modelo podem ser adicionados no método `aplicarModelo()`
- Novos formatos de saída podem ser implementados em `salvarSegmentacao()`
- Pré-processamento personalizado pode ser adicionado em `carregarEPreprocessarImagem()`