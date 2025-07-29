# 🚀 COMO EXECUTAR O SISTEMA

## Arquivo Principal Único

**Use APENAS este arquivo para executar o sistema:**

```matlab
>> executar_comparacao
```

## ⚠️ IMPORTANTE

- **NÃO use** `main_sistema_comparacao.m` (foi renomeado para .backup)
- **NÃO use** `executar_comparacao_automatico.m` (foi renomeado para .backup)
- **USE APENAS** `executar_comparacao.m`

## Menu Principal

O sistema oferece as seguintes opções:

1. **Testar formato dos dados** - Verificar se os dados estão no formato correto
2. **Converter máscaras** - Converter máscaras para formato binário (se necessário)
3. **Teste rápido com U-Net simples** - Validação inicial rápida
4. **Comparação completa U-Net vs Attention U-Net** - Análise principal
5. **Executar todos os passos em sequência** - Execução automática completa
6. **Comparação com validação cruzada** - Análise estatística robusta
7. **Verificar Attention U-Net** - Teste específico do modelo

## Primeira Execução

Na primeira execução, o sistema irá:
1. Configurar automaticamente os caminhos das imagens e máscaras
2. Salvar a configuração em `config_caminhos.mat`
3. Nas próximas execuções, usar a configuração salva

## Problemas Conhecidos (A SEREM CORRIGIDOS)

⚠️ **ATENÇÃO**: O sistema atualmente apresenta os seguintes problemas que serão corrigidos:

1. **Erro categorical RGB**: "Expected RGB to be one of these types... Instead its type was categorical"
2. **Métricas artificialmente perfeitas**: IoU, Dice e Acurácia sempre 1.0000 ± 0.0000
3. **Visualização incorreta**: Imagem de comparação não mostra diferenças reais

## Próximos Passos

Execute as tarefas do spec em `.kiro/specs/fix-categorical-rgb-error/tasks.md` para corrigir estes problemas.

## Suporte

Para problemas ou dúvidas, consulte:
- `README.md` - Documentação completa
- `.kiro/specs/fix-categorical-rgb-error/` - Especificação das correções necessárias