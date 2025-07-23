# Configuração de Caminhos - Projeto U-Net vs Attention U-Net

## 📁 Sistema de Configuração Portável

Este projeto agora possui um sistema robusto de configuração que permite usar o código em diferentes computadores sem precisar modificar os caminhos manualmente.

## 🚀 Como Usar

### Primeira Execução (Configuração Inicial)

1. **Execute o script principal:**
   ```matlab
   >> executar_comparacao()
   ```

2. **Na primeira execução, você será guiado pela configuração:**
   - O sistema detectará automaticamente se você está no computador original
   - Se os caminhos padrão forem encontrados, você poderá usá-los diretamente
   - Caso contrário, será solicitado a configurar manualmente

3. **Configuração manual (se necessário):**
   - Digite os caminhos completos das suas pastas
   - Ou use o navegador gráfico (opção mais fácil)
   - O sistema validará se os diretórios existem e contêm arquivos

### Execuções Subsequentes

O sistema carregará automaticamente a configuração salva e verificará se os caminhos ainda são válidos.

## 📂 Estrutura de Pastas Esperada

```
Suas Imagens/
├── original/          # Imagens originais
│   ├── img001.jpg
│   ├── img002.jpg
│   └── ...
└── masks/             # Máscaras correspondentes
    ├── img001.png
    ├── img002.png
    └── ...
```

## 🔧 Configuração Atual

**Caminhos configurados:**
- **Imagens:** `C:\Users\heito\Pictures\imagens matlab\original`
- **Máscaras:** `C:\Users\heito\Pictures\imagens matlab\masks`

## 🖥️ Portabilidade para Outros Computadores

### Método 1: Cópia Direta
1. Copie toda a pasta do projeto para o novo computador
2. Execute `executar_comparacao()`
3. Configure os novos caminhos quando solicitado

### Método 2: Reconfiguração Manual
1. No novo computador, execute:
   ```matlab
   >> config = configurar_caminhos();
   ```
2. Siga as instruções para configurar os novos caminhos

### Método 3: Edição do Arquivo de Configuração
1. Edite o arquivo `configurar_caminhos.m`
2. Modifique as linhas dos caminhos padrão:
   ```matlab
   caminhos_padrao.imageDir = 'C:\Novo\Caminho\original';
   caminhos_padrao.maskDir = 'C:\Novo\Caminho\masks';
   ```

## 📝 Arquivos de Configuração

O sistema cria automaticamente:

- **`config_caminhos.mat`** - Configuração principal
- **`config_backup_YYYY-MM-DD_HH-MM-SS.mat`** - Backup com timestamp
- **`configurar_caminhos.m`** - Script de configuração

## ✅ Funcionalidades do Sistema

- ✅ **Detecção automática de ambiente** (usuário e computador)
- ✅ **Validação de caminhos** (verifica se existem e contêm arquivos)
- ✅ **Navegador gráfico** para seleção de pastas
- ✅ **Backup automático** das configurações
- ✅ **Reconfiguração fácil** sem perder dados
- ✅ **Informações de ambiente** salvas para debug

## 🛠️ Resolução de Problemas

### Problema: "Diretório não encontrado"
- Verifique se o caminho está correto
- Use barras invertidas duplas `\\` no Windows
- Ou use o navegador gráfico para selecionar

### Problema: "Nenhuma imagem encontrada"
- Verifique se há arquivos nas pastas
- Formatos suportados: jpg, jpeg, png, bmp, tif, tiff

### Problema: "Configuração inválida"
- Delete o arquivo `config_caminhos.mat`
- Execute novamente `executar_comparacao()`
- Reconfigure os caminhos

### Reconfigurar Completamente
```matlab
>> delete('config_caminhos.mat')
>> executar_comparacao()
```

## 📊 Exemplo de Uso Completo

```matlab
% 1. Primeira execução (configuração automática)
>> executar_comparacao()

% 2. Escolher opção 1 para testar dados
>> 1

% 3. Se tudo estiver OK, escolher opção 5 para execução completa
>> 5

% 4. Para reconfigurar em outro computador:
>> config = configurar_caminhos();
```

## 🔄 Histórico de Versões

- **v1.2** - Sistema de configuração portável implementado
- **v1.1** - Configuração básica
- **v1.0** - Versão inicial

---

**💡 Dica:** Mantenha sempre um backup das suas imagens e máscaras em um local seguro!
