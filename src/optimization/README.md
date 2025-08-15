# Sistema de Monitoramento de Otimização e Gradientes

Este módulo implementa monitoramento avançado de gradientes e análise de otimização durante o treinamento de redes neurais.

## Componentes

### GradientMonitor.m
- Captura e análise de derivadas parciais durante o treinamento
- Detecção automática de problemas de gradiente (vanishing/exploding)
- Visualizações de evolução de gradientes
- Salvamento de histórico completo

### OptimizationAnalyzer.m
- Sugestões automáticas de ajustes de hiperparâmetros
- Análise de convergência
- Alertas em tempo real
- Recomendações baseadas em padrões de gradiente

## Uso

```matlab
% Criar monitor de gradientes
monitor = GradientMonitor(network);

% Durante o treinamento
monitor.recordGradients(network, epoch);

% Análise e sugestões
analyzer = OptimizationAnalyzer(monitor);
suggestions = analyzer.suggestOptimizations();
```

## Integração

O sistema se integra automaticamente com:
- treinar_unet_simples_enhanced.m
- comparacao_unet_attention_final.m
- Sistema de salvamento de modelos