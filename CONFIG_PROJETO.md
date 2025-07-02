# 🔧 CONFIGURAÇÃO DO PROJETO - MANUAL DE INSTRUÇÕES

## 📋 INFORMAÇÕES GERAIS

### **NOME DO PROJETO**
Comparação U-Net vs Attention U-Net para Segmentação de Imagens

### **VERSÃO ATUAL**
1.1 (Enxugada e Otimizada)

### **DATA DA ÚLTIMA ATUALIZAÇÃO**
02 de Julho de 2025

### **STATUS**
✅ Funcional e Testado - Projeto limpo e organizado

---

## 🎯 OBJETIVO PRINCIPAL

Comparar performance entre U-Net clássica e Attention U-Net em segmentação semântica de imagens, avaliando métricas como IoU, Dice Score e acurácia pixel-wise.

---

## 📁 ESTRUTURA DE ARQUIVOS ESSENCIAIS (15 arquivos)

### 🚀 **ARQUIVO PRINCIPAL (SEMPRE EXECUTAR ESTE)**
- `executar_comparacao.m` - Script principal com menu interativo

### 📜 **SCRIPTS PRINCIPAIS (8 arquivos)**
- `comparacao_unet_attention_final.m` - Comparação completa
- `converter_mascaras.m` - Conversão de máscaras
- `teste_dados_segmentacao.m` - Teste de formato dos dados  
- `treinar_unet_simples.m` - Teste rápido com U-Net
- `create_working_attention_unet.m` - **ÚNICA** implementação da Attention U-Net
- `teste_attention_unet_real.m` - Teste robusto da Attention U-Net
- `funcoes_auxiliares.m` - Funções auxiliares
- `analise_metricas_detalhada.m` - Análise detalhada de métricas

### 📋 **ARQUIVOS DE CONFIGURAÇÃO/DADOS (6 arquivos)**
- `README.md` - Documentação completa
- `CONFIG_PROJETO.md` - **ESTE ARQUIVO** (manual de instruções)
- `.gitignore` - Configuração Git
- `config_caminhos.mat` - Configurações salvas automaticamente
- `modelo_unet.mat` - Modelo treinado (gerado automaticamente)
- `resultados_comparacao.mat` - Resultados (gerado automaticamente)

---

## ⚠️ REGRAS CRÍTICAS - NUNCA QUEBRAR

### 🚫 **NUNCA FAZER:**
1. **Criar novos arquivos** de implementação da Attention U-Net
2. **Duplicar funções** que já existem
3. **Modificar** `create_working_attention_unet.m` sem necessidade extrema
4. **Deletar** arquivos sem verificar dependências
5. **Criar** versões alternativas dos scripts principais

### ✅ **SEMPRE FAZER:**
1. **Ler este arquivo** antes de qualquer modificação
2. **Usar** os arquivos existentes como base
3. **Verificar** dependências antes de deletar
4. **Testar** funcionalidade após modificações
5. **Documentar** mudanças significativas

---

## 🔗 FLUXO DE DEPENDÊNCIAS

### **SCRIPT PRINCIPAL**
```
executar_comparacao.m
├── teste_dados_segmentacao.m
├── converter_mascaras.m  
├── treinar_unet_simples.m
├── comparacao_unet_attention_final.m
├── teste_attention_unet_real.m
└── funcoes_auxiliares.m
```

### **IMPLEMENTAÇÃO DA ATTENTION U-NET**
```
create_working_attention_unet.m (ÚNICA VERSÃO FUNCIONAL)
└── Usada por: comparacao_unet_attention_final.m
└── Usada por: executar_comparacao.m (validação cruzada)
```

### **FUNÇÕES AUXILIARES CRÍTICAS**
- `carregar_dados_robustos()` - Carregamento de dados
- `analisar_mascaras_automatico()` - Análise de máscaras
- `configurar_projeto_inicial()` - Configuração inicial

---

## 🛠️ PROBLEMAS CONHECIDOS E SOLUÇÕES

### **PROBLEMA 1: Attention U-Net não funciona**
- **CAUSA**: Erro na implementação dos attention gates
- **SOLUÇÃO**: Usar `create_working_attention_unet.m` (já corrigida)
- **NÃO FAZER**: Criar nova implementação

### **PROBLEMA 2: Erro "function not found"**
- **CAUSA**: Referência a arquivo deletado
- **SOLUÇÃO**: Verificar se arquivo existe antes de chamar
- **VERIFICAR**: `funcoes_auxiliares.m` tem todas as funções necessárias

### **PROBLEMA 3: Máscaras incompatíveis**
- **CAUSA**: Formato incorreto das máscaras
- **SOLUÇÃO**: Usar opção 2 do menu (converter_mascaras)
- **VERIFICAR**: Máscaras devem ter valores 0 e 255

### **PROBLEMA 4: Erro de memória**
- **CAUSA**: Batch size muito grande
- **SOLUÇÃO**: Reduzir `config.miniBatchSize` para 4 ou 2
- **NÃO FAZER**: Aumentar número de amostras sem verificar RAM

---

## 📊 MÉTRICAS E RESULTADOS ESPERADOS

### **MÉTRICAS PRINCIPAIS**
- **IoU** (Intersection over Union): 0.85-0.92
- **Dice Score**: 0.92-0.96  
- **Acurácia**: 85%-95%

### **TEMPOS ESPERADOS (CPU)**
- U-Net: ~15-20 minutos (20 épocas)
- Attention U-Net: ~18-25 minutos (20 épocas)
- Comparação completa: ~40-50 minutos

### **DIFERENÇAS ESPERADAS**
- Attention U-Net deve ter IoU 2-5% maior que U-Net
- Se resultados forem idênticos = PROBLEMA na implementação

---

## 🎮 OPÇÕES DO MENU PRINCIPAL

1. **Testar formato dos dados** - SEMPRE fazer primeiro
2. **Converter máscaras** - Se teste anterior falhar
3. **Teste rápido** - Para validação rápida (5 épocas)
4. **Comparação completa** - OBJETIVO PRINCIPAL (20 épocas)
5. **Executar todos os passos** - Automático (recomendado)
6. **Validação cruzada** - Para resultados robustos (2-4 horas)
7. **Teste Attention U-Net** - Para debug específico

---

## 🔧 CONFIGURAÇÕES PADRÃO

### **CONFIGURAÇÃO PADRÃO**
```matlab
config.inputSize = [256, 256, 3];     % Tamanho das imagens
config.numClasses = 2;                % Background + Foreground  
config.validationSplit = 0.2;         % 20% para validação
config.miniBatchSize = 8;              % Batch size padrão
config.maxEpochs = 20;                 % Épocas de treinamento
```

### **CONFIGURAÇÃO PARA TESTE RÁPIDO**
```matlab
config.quickTest.numSamples = 50;     % Apenas 50 amostras
config.quickTest.maxEpochs = 5;       % Apenas 5 épocas
```

---

## 🚨 CHECKLIST ANTES DE MODIFICAR

### **ANTES DE QUALQUER MUDANÇA:**
- [ ] Li este arquivo CONFIG_PROJETO.md
- [ ] Entendi o objetivo da modificação
- [ ] Verifiquei se não estou duplicando código existente
- [ ] Confirmo que é necessário criar novo arquivo
- [ ] Testei a funcionalidade atual

### **ANTES DE DELETAR ARQUIVOS:**
- [ ] Verifiquei dependências com `grep_search`
- [ ] Confirmo que arquivo não é usado
- [ ] Fiz backup se necessário
- [ ] Testei funcionalidade após remoção

### **ANTES DE CRIAR NOVOS ARQUIVOS:**
- [ ] Verifico se funcionalidade já existe
- [ ] Confirmo que é realmente necessário
- [ ] Planejo onde colocar o código
- [ ] Documento o novo arquivo

---

## 💡 DIRETRIZES DE DESENVOLVIMENTO

### **PRIORIDADES (EM ORDEM)**
1. **Usar código existente** sempre que possível
2. **Modificar** arquivos existentes se necessário
3. **Criar novos** apenas em último caso
4. **Documentar** todas as mudanças

### **PADRÃO DE COMENTÁRIOS**
```matlab
% ========================================================================
% NOME DA FUNÇÃO/SCRIPT - DESCRIÇÃO BREVE
% ========================================================================
% 
% DESCRIÇÃO: Explicação detalhada
% ENTRADA: Parâmetros de entrada
% SAÍDA: O que retorna
% USO: Como usar
% ========================================================================
```

### **PADRÃO DE NOMES**
- Scripts principais: `verbo_substantivo.m` (ex: `executar_comparacao.m`)
- Funções: `verbo_substantivo()` (ex: `carregar_dados_robustos()`)
- Arquivos de config: `NOME_CONFIG.ext` (ex: `CONFIG_PROJETO.md`)

---

## 📝 LOG DE MUDANÇAS

### **v1.1 (02/Jul/2025) - Enxugamento**
- ✅ Removidas 4 pastas de versões antigas
- ✅ Removidas implementações duplicadas da Attention U-Net
- ✅ Removidos scripts de correção temporários
- ✅ Projeto reduzido de ~50 para 15 arquivos
- ✅ Documentação atualizada

### **v1.0 (01/Jul/2025) - Versão funcional**
- ✅ Implementação funcional da Attention U-Net
- ✅ Menu interativo completo
- ✅ Todas as funcionalidades testadas

---

## 🆘 EM CASO DE PROBLEMAS

### **SE O PROJETO PARAR DE FUNCIONAR:**
1. Verificar se todos os 15 arquivos estão presentes
2. Executar `executar_comparacao()` → Opção 1 (teste de dados)
3. Verificar se `config_caminhos.mat` existe
4. Verificar se os caminhos das imagens estão corretos

### **SE APARECER ERRO "function not found":**
1. Verificar se o arquivo da função existe
2. Verificar se está no diretório correto
3. Verificar se a função está definida no arquivo correto

### **SE A ATTENTION U-NET FALHAR:**
1. Usar apenas U-Net clássica (ainda é útil)
2. Verificar se `create_working_attention_unet.m` existe
3. NÃO tentar criar nova implementação

---

## 🎯 META FINAL

**OBJETIVO**: Manter o projeto funcionando, limpo e bem documentado, permitindo comparações válidas entre U-Net e Attention U-Net para segmentação de imagens.

**SUCESSO**: Quando o usuário consegue executar `executar_comparacao()` → Opção 4 ou 5 e obter resultados diferentes entre os dois modelos.

---

*🤖 Este arquivo deve ser lido ANTES de qualquer modificação no projeto!*
*📅 Última atualização: 02 de Julho de 2025*
*✅ Status: Projeto funcional e organizado*
