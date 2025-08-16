# Módulo de Organização de Resultados

Este módulo contém a classe `OrganizadorResultados` responsável por organizar automaticamente todos os resultados do sistema de segmentação.

## Funcionalidades

### 1. Criação Automática de Estrutura de Pastas
- `resultados_segmentacao/unet/` - Segmentações do modelo U-Net
- `resultados_segmentacao/attention_unet/` - Segmentações do modelo Attention U-Net
- `resultados_segmentacao/comparacoes/` - Comparações visuais entre modelos
- `resultados_segmentacao/relatorios/` - Relatórios e métricas
- `resultados_segmentacao/modelos/` - Modelos treinados

### 2. Nomenclatura Consistente
- Segmentações U-Net: `nomeoriginal_unet.png`
- Segmentações Attention U-Net: `nomeoriginal_attention.png`
- Modelos: `modelo_unet.mat`, `modelo_attention_unet.mat`

### 3. Índice de Arquivos
- Arquivo `indice_arquivos.txt` com lista completa de todos os arquivos processados
- Timestamps de processamento
- Estatísticas de organização

### 4. Recuperação de Erros
- Criação automática de pastas em caso de erro
- Método de recuperação para recriar estrutura

## Uso Básico

```matlab
% Criar organizador
organizador = OrganizadorResultados();

% Criar estrutura de pastas
organizador.criarEstruturaPastas();

% Organizar arquivo de segmentação
organizador.organizarArquivoSegmentacao('temp/img001_seg.png', 'img001.png', 'unet');

% Organizar modelo treinado
organizador.organizarModelo('modelo_temp.mat', 'modelo_unet');

% Criar índice de arquivos
organizador.criarIndiceArquivos();

% Exibir estrutura
organizador.exibirEstrutura();
```

## Uso Avançado

```matlab
% Organização rápida de múltiplos arquivos
arquivosUNet = {'temp/seg1_unet.png', 'temp/seg2_unet.png'};
arquivosAttention = {'temp/seg1_att.png', 'temp/seg2_att.png'};
modelos = {'modelo_unet.mat', 'modelo_attention.mat'};

sucesso = OrganizadorResultados.organizarResultadosRapido(arquivosUNet, arquivosAttention, modelos);
```

## Integração com Sistema Principal

O `OrganizadorResultados` é chamado automaticamente pelo sistema principal após a segmentação das imagens, organizando todos os resultados de forma consistente e criando a documentação necessária.

## Tratamento de Erros

A classe implementa recuperação automática de erros:
- Recria pastas se não existirem
- Continua processamento mesmo com falhas individuais
- Log detalhado de erros para debugging

## Estrutura Final

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
│   └── (comparações visuais)
├── relatorios/
│   └── (relatórios e métricas)
├── modelos/
│   ├── modelo_unet.mat
│   └── modelo_attention_unet.mat
└── indice_arquivos.txt
```