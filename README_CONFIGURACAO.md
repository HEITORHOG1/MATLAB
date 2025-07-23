# 🚀 Sistema de Configuração Portável - U-Net vs Attention U-Net

## ✅ Configuração Atual

**STATUS**: ✅ Configurado e pronto para uso!

**Caminhos configurados:**
- **Imagens**: `C:\Users\heito\Pictures\imagens matlab\original`
- **Máscaras**: `C:\Users\heito\Pictures\imagens matlab\masks`

## 🎯 Como Usar

### 1. Execução Simples
```matlab
>> executar_comparacao()
```

### 2. Teste Rápido da Configuração
```matlab
>> testar_configuracao()
```

### 3. Para Reconfigurar (se necessário)
```matlab
>> configuracao_inicial_automatica()
```

## 📱 Para Usar em Outro Computador

### Método Rápido
1. **Copie todos os arquivos** para o novo computador
2. **Execute no MATLAB:**
   ```matlab
   >> exportar_configuracao_portatil()
   ```
3. **Edite o arquivo** `config_portatil.m` criado
4. **Aplique a nova configuração:**
   ```matlab
   >> config = config_portatil();
   >> save('config_caminhos.mat', 'config');
   ```

### Método Manual
1. **Delete a configuração atual:**
   ```matlab
   >> delete('config_caminhos.mat')
   ```
2. **Execute novamente:**
   ```matlab
   >> executar_comparacao()
   ```
3. **Configure os novos caminhos** quando solicitado

## 📁 Estrutura de Arquivos Criados

```
Projeto/
├── executar_comparacao.m          # ← Script principal
├── configurar_caminhos.m          # ← Configuração interativa
├── configuracao_inicial_automatica.m  # ← Configuração automática
├── testar_configuracao.m          # ← Teste de configuração
├── exportar_configuracao_portatil.m   # ← Exportador portátil
├── config_caminhos.mat            # ← Configuração salva
├── config_backup_*.mat            # ← Backups automáticos
└── GUIA_CONFIGURACAO.md          # ← Guia completo
```

## 🔧 Opções do Menu Principal

Quando executar `executar_comparacao()`, você verá:

1. **Testar formato dos dados** - Verifica se suas imagens/máscaras estão OK
2. **Converter máscaras** - Converte máscaras para formato binário
3. **Teste rápido com U-Net** - Validação rápida (5 épocas)
4. **Comparação completa** - Análise completa U-Net vs Attention U-Net
5. **Executar todos os passos** - Automático (recomendado para iniciantes)
6. **Validação cruzada** - Análise estatística robusta (2-4 horas)
7. **Teste Attention U-Net** - Teste específico do modelo

## ⚠️ Notas Importantes

- **0 imagens/máscaras encontradas**: Verifique se os arquivos estão nas pastas corretas
- **Formatos suportados**: jpg, jpeg, png, bmp, tif, tiff
- **Estrutura de pastas**: Imagens e máscaras devem estar em pastas separadas

## 🆘 Resolução de Problemas

### "Diretório não encontrado"
```matlab
>> testar_configuracao()  % Verificar o problema
>> configuracao_inicial_automatica()  % Reconfigurar
```

### "Nenhuma imagem encontrada"
- Verifique se os arquivos estão nas pastas corretas
- Verifique os formatos dos arquivos (jpg, png, etc.)

### "Erro na configuração"
```matlab
>> delete('config_caminhos.mat')
>> executar_comparacao()
```

## 📞 Comandos Úteis

```matlab
% Verificar configuração atual
>> load('config_caminhos.mat'); disp(config)

% Listar arquivos encontrados
>> dir('C:\Users\heito\Pictures\imagens matlab\original\*.*')
>> dir('C:\Users\heito\Pictures\imagens matlab\masks\*.*')

% Recriar configuração
>> configuracao_inicial_automatica()

% Testar tudo
>> testar_configuracao()
```

---

**🎉 Pronto para usar!** Execute `executar_comparacao()` e escolha a opção 5 para execução automática completa.
