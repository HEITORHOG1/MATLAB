# Sistema de Comparação de Modelos

## Visão Geral

O módulo de comparação implementa análise comparativa completa entre modelos U-Net e Attention U-Net, incluindo cálculo de métricas, visualizações e geração de relatórios.

## Classe Principal: ComparadorModelos

### Funcionalidades

- **Cálculo de Métricas**: IoU, Dice Coefficient, Accuracy
- **Visualizações Comparativas**: Comparações lado a lado, mapas de diferença
- **Relatórios Detalhados**: Análise textual com conclusões e recomendações
- **Detecção de Diferenças**: Identificação automática de divergências entre modelos

### Uso Básico

```matlab
% Criar instância do comparador
comparador = ComparadorModelos('caminhoSaida', 'resultados_segmentacao');

% Executar comparação completa
comparador.comparar();
```

### Uso Avançado

```matlab
% Com configurações personalizadas
comparador = ComparadorModelos(...
    'caminhoSaida', 'meus_resultados', ...
    'verbose', true);

% Executar etapas individuais
resultados = comparador.carregarResultados();
metricas = comparador.calcularMetricas(resultados);
comparador.gerarVisualizacoes(resultados, metricas);
comparador.gerarRelatorio(metricas);
```

## Estrutura de Saída

```
resultados_segmentacao/
├── comparacoes/
│   ├── comparacao_001.png      # Comparações lado a lado
│   ├── diferenca_001.png       # Mapas de diferença
│   └── grafico_metricas.png    # Gráfico comparativo
└── relatorios/
    └── relatorio_comparativo.txt # Relatório detalhado
```

## Requisitos

- Resultados de segmentação em `resultados_segmentacao/unet/`
- Resultados de segmentação em `resultados_segmentacao/attention_unet/`
- Classes auxiliares: `MetricsCalculator`, `ComparisonVisualizer`, `ReportGenerator`

## Métricas Calculadas

### IoU (Intersection over Union)
- Mede sobreposição entre predição e ground truth
- Valores: 0-1 (maior = melhor)

### Dice Coefficient
- Mede similaridade entre segmentações
- Valores: 0-1 (maior = melhor)

### Accuracy
- Mede acurácia pixel-wise
- Valores: 0-1 (maior = melhor)

## Interpretação de Resultados

### Níveis de Confiança
- **Alta**: Diferenças consistentes em todas as métricas
- **Média**: Resultados mistos, algumas métricas favorecem cada modelo
- **Baixa**: Diferenças mínimas, empate técnico

### Categorias de Diferença
- **Mínima**: < 1% de diferença
- **Pequena**: 1-5% de diferença
- **Moderada**: 5-10% de diferença
- **Significativa**: > 10% de diferença

## Visualizações Geradas

### Comparação Lado a Lado
- Imagem original (simulada)
- Ground truth (simulado)
- Segmentação U-Net com métricas
- Segmentação Attention U-Net com métricas

### Mapa de Diferenças
- Visualização das divergências entre modelos
- Heatmap destacando áreas de maior diferença
- Comparação visual direta

### Gráfico de Métricas
- Comparação em barras das métricas médias
- Visualização clara da performance relativa

## Relatório Comparativo

### Seções do Relatório

1. **Resumo Executivo**
   - Modelo vencedor
   - Nível de confiança
   - Principais diferenças

2. **Métricas Detalhadas**
   - Estatísticas completas para cada modelo
   - Média, desvio padrão, min/max, mediana

3. **Análise Comparativa**
   - Comparação métrica por métrica
   - Análise de consistência

4. **Conclusões e Recomendações**
   - Interpretação dos resultados
   - Recomendações de uso
   - Próximos passos sugeridos

## Tratamento de Erros

- Verificação de existência de pastas
- Validação de correspondência entre arquivos
- Criação automática de estrutura de saída
- Mensagens de erro informativas

## Limitações

- Requer imagens correspondentes entre modelos
- Ground truth simulado baseado na união das segmentações
- Limitado a 10 visualizações para evitar sobrecarga

## Integração

Esta classe é integrada automaticamente no sistema principal através do script `executar_sistema_completo.m`.