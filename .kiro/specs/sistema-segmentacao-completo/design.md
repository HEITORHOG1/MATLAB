# Documento de Design - Sistema de Segmentação Completo

## Overview

Este design implementa um sistema completo e direto para treinamento de modelos U-Net e Attention U-Net, segmentação de imagens, comparação de resultados e limpeza de código. O foco é na simplicidade e funcionalidade, criando um pipeline automatizado que execute todo o processo com um comando.

## Architecture

### Arquitetura do Sistema

```
Sistema de Segmentação Completo
├── executar_sistema_completo.m     # Script principal - executa tudo
├── src/
│   ├── treinamento/
│   │   ├── TreinadorUNet.m         # Treina modelo U-Net
│   │   └── TreinadorAttentionUNet.m # Treina modelo Attention U-Net
│   ├── segmentacao/
│   │   ├── SegmentadorImagens.m    # Aplica modelos nas imagens
│   │   └── OrganizadorResultados.m # Organiza resultados em pastas
│   ├── comparacao/
│   │   ├── ComparadorModelos.m     # Compara performance dos modelos
│   │   └── GeradorRelatorio.m      # Gera relatórios e visualizações
│   └── limpeza/
│       └── LimpadorCodigo.m        # Remove arquivos desnecessários
└── resultados_segmentacao/         # Pasta de saída organizada
    ├── unet/                       # Resultados U-Net
    ├── attention_unet/             # Resultados Attention U-Net
    ├── comparacoes/                # Comparações lado a lado
    └── relatorios/                 # Relatórios e métricas
```

## Components and Interfaces

### 1. Script Principal - executar_sistema_completo.m

```matlab
function executar_sistema_completo()
    % Script principal que executa todo o pipeline
    
    fprintf('=== SISTEMA DE SEGMENTAÇÃO COMPLETO ===\n');
    
    try
        % 1. Configuração inicial
        configurar_caminhos();
        
        % 2. Treinamento dos modelos
        fprintf('\n[1/5] Iniciando treinamento dos modelos...\n');
        [modelo_unet, modelo_attention] = treinar_modelos();
        
        % 3. Segmentação das imagens
        fprintf('\n[2/5] Aplicando modelos nas imagens...\n');
        segmentar_imagens(modelo_unet, modelo_attention);
        
        % 4. Organização dos resultados
        fprintf('\n[3/5] Organizando resultados...\n');
        organizar_resultados();
        
        % 5. Comparação e análise
        fprintf('\n[4/5] Comparando modelos...\n');
        comparar_modelos();
        
        % 6. Limpeza de código (opcional)
        fprintf('\n[5/5] Limpeza de código...\n');
        limpar_codigo();
        
        fprintf('\n✅ SISTEMA EXECUTADO COM SUCESSO!\n');
        fprintf('Resultados salvos em: resultados_segmentacao/\n');
        
    catch ME
        fprintf('\n❌ ERRO: %s\n', ME.message);
        fprintf('Execução interrompida.\n');
    end
end
```

### 2. TreinadorUNet.m - Treinamento do Modelo U-Net

```matlab
classdef TreinadorUNet < handle
    properties
        caminhoImagens
        caminhoMascaras
        configuracao
    end
    
    methods
        function obj = TreinadorUNet(caminhoImagens, caminhoMascaras)
            obj.caminhoImagens = caminhoImagens;
            obj.caminhoMascaras = caminhoMascaras;
            obj.configuracao = obj.obterConfiguracaoDefault();
        end
        
        function modelo = treinar(obj)
            % Carrega dados
            [imagens, mascaras] = obj.carregarDados();
            
            % Cria arquitetura U-Net
            rede = obj.criarArquiteturaUNet();
            
            % Configura treinamento
            opcoes = obj.configurarTreinamento();
            
            % Executa treinamento
            fprintf('Treinando U-Net...\n');
            modelo = trainNetwork(imagens, mascaras, rede, opcoes);
            
            % Salva modelo
            obj.salvarModelo(modelo, 'modelo_unet.mat');
            
            fprintf('✅ U-Net treinado com sucesso!\n');
        end
        
        function [imagens, mascaras] = carregarDados(obj)
            % Implementação de carregamento de dados
        end
        
        function rede = criarArquiteturaUNet(obj)
            % Implementação da arquitetura U-Net
        end
        
        function opcoes = configurarTreinamento(obj)
            % Configurações de treinamento
        end
        
        function salvarModelo(obj, modelo, nomeArquivo)
            % Salva modelo treinado
        end
    end
end
```

### 3. TreinadorAttentionUNet.m - Treinamento do Modelo Attention U-Net

```matlab
classdef TreinadorAttentionUNet < handle
    properties
        caminhoImagens
        caminhoMascaras
        configuracao
    end
    
    methods
        function obj = TreinadorAttentionUNet(caminhoImagens, caminhoMascaras)
            obj.caminhoImagens = caminhoImagens;
            obj.caminhoMascaras = caminhoMascaras;
            obj.configuracao = obj.obterConfiguracaoDefault();
        end
        
        function modelo = treinar(obj)
            % Carrega dados
            [imagens, mascaras] = obj.carregarDados();
            
            % Cria arquitetura Attention U-Net
            rede = obj.criarArquiteturaAttentionUNet();
            
            % Configura treinamento
            opcoes = obj.configurarTreinamento();
            
            % Executa treinamento
            fprintf('Treinando Attention U-Net...\n');
            modelo = trainNetwork(imagens, mascaras, rede, opcoes);
            
            % Salva modelo
            obj.salvarModelo(modelo, 'modelo_attention_unet.mat');
            
            fprintf('✅ Attention U-Net treinado com sucesso!\n');
        end
        
        function rede = criarArquiteturaAttentionUNet(obj)
            % Implementação da arquitetura Attention U-Net com mecanismo de atenção
        end
    end
end
```

### 4. SegmentadorImagens.m - Aplicação dos Modelos

```matlab
classdef SegmentadorImagens < handle
    properties
        caminhoImagens
        modeloUNet
        modeloAttentionUNet
    end
    
    methods
        function obj = SegmentadorImagens(caminhoImagens, modeloUNet, modeloAttentionUNet)
            obj.caminhoImagens = caminhoImagens;
            obj.modeloUNet = modeloUNet;
            obj.modeloAttentionUNet = modeloAttentionUNet;
        end
        
        function segmentar(obj)
            % Lista imagens para segmentar
            arquivosImagens = obj.listarImagens();
            
            fprintf('Segmentando %d imagens...\n', length(arquivosImagens));
            
            for i = 1:length(arquivosImagens)
                fprintf('Processando imagem %d/%d: %s\n', i, length(arquivosImagens), arquivosImagens{i});
                
                % Carrega imagem
                imagem = imread(fullfile(obj.caminhoImagens, arquivosImagens{i}));
                
                % Segmenta com U-Net
                segmentacaoUNet = obj.aplicarModelo(imagem, obj.modeloUNet);
                obj.salvarSegmentacao(segmentacaoUNet, arquivosImagens{i}, 'unet');
                
                % Segmenta com Attention U-Net
                segmentacaoAttention = obj.aplicarModelo(imagem, obj.modeloAttentionUNet);
                obj.salvarSegmentacao(segmentacaoAttention, arquivosImagens{i}, 'attention_unet');
            end
            
            fprintf('✅ Segmentação concluída!\n');
        end
        
        function segmentacao = aplicarModelo(obj, imagem, modelo)
            % Aplica modelo na imagem
        end
        
        function salvarSegmentacao(obj, segmentacao, nomeImagem, tipoModelo)
            % Salva resultado da segmentação
        end
    end
end
```

### 5. OrganizadorResultados.m - Organização dos Resultados

```matlab
classdef OrganizadorResultados < handle
    methods (Static)
        function organizar()
            fprintf('Organizando resultados...\n');
            
            % Cria estrutura de pastas
            OrganizadorResultados.criarEstruturaPastas();
            
            % Move arquivos para pastas corretas
            OrganizadorResultados.organizarArquivos();
            
            % Cria índice de arquivos
            OrganizadorResultados.criarIndice();
            
            fprintf('✅ Resultados organizados!\n');
        end
        
        function criarEstruturaPastas()
            pastas = {
                'resultados_segmentacao',
                'resultados_segmentacao/unet',
                'resultados_segmentacao/attention_unet',
                'resultados_segmentacao/comparacoes',
                'resultados_segmentacao/relatorios'
            };
            
            for i = 1:length(pastas)
                if ~exist(pastas{i}, 'dir')
                    mkdir(pastas{i});
                end
            end
        end
        
        function organizarArquivos()
            % Move arquivos para pastas apropriadas
        end
        
        function criarIndice()
            % Cria arquivo de índice listando todas as imagens
        end
    end
end
```

### 6. ComparadorModelos.m - Comparação de Performance

```matlab
classdef ComparadorModelos < handle
    methods (Static)
        function comparar()
            fprintf('Comparando modelos...\n');
            
            % Carrega resultados
            resultadosUNet = ComparadorModelos.carregarResultados('unet');
            resultadosAttention = ComparadorModelos.carregarResultados('attention_unet');
            
            % Calcula métricas
            metricasUNet = ComparadorModelos.calcularMetricas(resultadosUNet);
            metricasAttention = ComparadorModelos.calcularMetricas(resultadosAttention);
            
            % Gera comparações visuais
            ComparadorModelos.gerarComparacoesVisuais(resultadosUNet, resultadosAttention);
            
            % Gera relatório
            ComparadorModelos.gerarRelatorio(metricasUNet, metricasAttention);
            
            fprintf('✅ Comparação concluída!\n');
        end
        
        function metricas = calcularMetricas(resultados)
            % Calcula IoU, Dice, Accuracy
        end
        
        function gerarComparacoesVisuais(resultadosUNet, resultadosAttention)
            % Cria imagens lado a lado
        end
        
        function gerarRelatorio(metricasUNet, metricasAttention)
            % Gera relatório comparativo
        end
    end
end
```

### 7. LimpadorCodigo.m - Limpeza de Arquivos Desnecessários

```matlab
classdef LimpadorCodigo < handle
    methods (Static)
        function limpar()
            fprintf('Analisando código para limpeza...\n');
            
            % Identifica arquivos duplicados
            arquivosDuplicados = LimpadorCodigo.identificarDuplicados();
            
            % Identifica arquivos obsoletos
            arquivosObsoletos = LimpadorCodigo.identificarObsoletos();
            
            % Lista arquivos para remoção
            LimpadorCodigo.listarParaRemocao(arquivosDuplicados, arquivosObsoletos);
            
            % Remove arquivos (com confirmação)
            LimpadorCodigo.removerArquivos(arquivosDuplicados, arquivosObsoletos);
            
            fprintf('✅ Limpeza concluída!\n');
        end
        
        function duplicados = identificarDuplicados()
            % Identifica arquivos com conteúdo similar
        end
        
        function obsoletos = identificarObsoletos()
            % Identifica arquivos não utilizados
        end
    end
end
```

## Data Models

### Estrutura de Configuração
```matlab
struct Configuracao
    caminhos
        .imagens_originais      % 'C:\Users\heito\Documents\MATLAB\img\original'
        .mascaras              % 'C:\Users\heito\Documents\MATLAB\img\masks'
        .imagens_teste         % 'C:\Users\heito\Documents\MATLAB\img\imagens apos treinamento\original'
        .saida                 % 'resultados_segmentacao'
    
    treinamento
        .epochs                % 50
        .batch_size           % 8
        .learning_rate        % 0.001
        .validation_split     % 0.2
    
    segmentacao
        .formato_saida        % 'png'
        .qualidade           % 95
end
```

### Estrutura de Métricas
```matlab
struct Metricas
    modelo                    % 'unet' | 'attention_unet'
    iou_medio                % Intersection over Union médio
    dice_medio               % Coeficiente Dice médio
    accuracy_media           % Acurácia média
    tempo_processamento      % Tempo total de processamento
    numero_imagens          % Número de imagens processadas
end
```

## Error Handling

### Estratégias de Tratamento de Erros

1. **Verificação de Caminhos:**
   - Validar existência de pastas de entrada antes de iniciar
   - Criar pastas de saída automaticamente se não existirem
   - Mensagens claras sobre caminhos incorretos

2. **Tratamento de Falhas de Treinamento:**
   - Verificar disponibilidade de GPU/CPU
   - Validar formato e tamanho das imagens
   - Salvar progresso parcial em caso de interrupção

3. **Recuperação de Erros:**
   - Permitir retomar execução a partir de etapa específica
   - Backup automático de modelos durante treinamento
   - Log detalhado de erros para debugging

## Testing Strategy

### Testes de Funcionalidade
- Teste com dataset pequeno para validar pipeline completo
- Verificação de criação correta de pastas e arquivos
- Validação de formatos de saída

### Testes de Performance
- Benchmark de tempo de treinamento
- Validação de uso de memória
- Teste com diferentes tamanhos de imagem

### Testes de Robustez
- Teste com imagens corrompidas
- Validação com diferentes formatos de entrada
- Teste de recuperação após falhas

## Implementation Notes

### Prioridades de Implementação
1. Script principal com estrutura básica
2. Treinamento dos modelos (U-Net primeiro, depois Attention U-Net)
3. Segmentação e organização de resultados
4. Comparação e relatórios
5. Limpeza de código

### Considerações Técnicas
- Usar arquiteturas existentes como base
- Implementar progressão visual clara para o usuário
- Otimizar para uso de memória com imagens grandes
- Documentar cada função claramente

### Estrutura de Saída Final
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
│   └── resumo_final.html
└── modelos/
    ├── modelo_unet.mat
    └── modelo_attention_unet.mat
```