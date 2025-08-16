# TreinadorUNet - Classe para Treinamento de Modelo U-Net

## Descrição

A classe `TreinadorUNet` encapsula todo o processo de treinamento do modelo U-Net para segmentação de imagens. Ela fornece uma interface simples e robusta para treinar modelos U-Net com dados personalizados.

## Características

- **Carregamento automático de dados**: Carrega imagens e máscaras das pastas especificadas
- **Arquitetura U-Net otimizada**: Implementa arquitetura U-Net completa com skip connections
- **Configuração flexível**: Permite personalizar parâmetros de treinamento
- **Validação robusta**: Inclui validação de dados e tratamento de erros
- **Salvamento automático**: Salva o modelo treinado automaticamente

## Uso Básico

```matlab
% Criar instância do treinador
caminhoImagens = 'C:\Users\heito\Documents\MATLAB\img\original';
caminhoMascaras = 'C:\Users\heito\Documents\MATLAB\img\masks';
treinador = TreinadorUNet(caminhoImagens, caminhoMascaras);

% Executar treinamento
modelo = treinador.treinar();
```

## Parâmetros de Configuração

A classe usa os seguintes parâmetros padrão:

- **Epochs**: 50
- **Learning Rate**: 0.001
- **Batch Size**: 4
- **Validation Split**: 0.2

## Estrutura de Arquivos

### Entrada Esperada
```
caminhoImagens/
├── imagem1.jpg
├── imagem2.png
└── ...

caminhoMascaras/
├── imagem1.png
├── imagem2.png
└── ...
```

### Saída Gerada
```
resultados_segmentacao/
└── modelos/
    └── modelo_unet.mat
```

## Arquitetura U-Net

A arquitetura implementada inclui:

- **Encoder**: 4 blocos de convolução com max pooling
- **Bottleneck**: Bloco central com 1024 filtros
- **Decoder**: 4 blocos de deconvolução com skip connections
- **Saída**: Classificação pixel-wise com softmax

### Detalhes da Arquitetura

- Tamanho de entrada: 256x256x3
- Número de classes: 2 (background, foreground)
- Normalização: Batch normalization em todas as camadas
- Ativação: ReLU
- Skip connections: Concatenação de features do encoder

## Métodos Principais

### `TreinadorUNet(caminhoImagens, caminhoMascaras)`
Construtor da classe.

### `modelo = treinar()`
Executa o treinamento completo e retorna o modelo treinado.

### `[imagens, mascaras] = carregarDados()`
Carrega e pré-processa os dados de treinamento.

### `rede = criarArquiteturaUNet()`
Cria a arquitetura U-Net.

### `opcoes = configurarTreinamento()`
Configura as opções de treinamento.

## Tratamento de Erros

A classe inclui tratamento robusto de erros para:

- Caminhos inexistentes
- Máscaras não encontradas
- Formatos de imagem incompatíveis
- Problemas de memória durante treinamento

## Requisitos

- MATLAB R2019b ou superior
- Deep Learning Toolbox
- Image Processing Toolbox
- Pelo menos 8GB de RAM recomendado
- GPU compatível (opcional, mas recomendado)

## Exemplo Completo

Veja `examples/exemplo_treinamento_unet.m` para um exemplo completo de uso.

## Teste

Execute `tests/teste_treinador_unet.m` para validar a instalação e funcionamento.