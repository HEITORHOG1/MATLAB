# Guia de Instalação - Sistema de Comparação U-Net vs Attention U-Net

## 📋 Índice

- [Requisitos do Sistema](#-requisitos-do-sistema)
- [Instalação Rápida](#-instalação-rápida)
- [Instalação Detalhada](#-instalação-detalhada)
- [Configuração Inicial](#-configuração-inicial)
- [Verificação da Instalação](#-verificação-da-instalação)
- [Solução de Problemas](#-solução-de-problemas)
- [Migração de Versão Anterior](#-migração-de-versão-anterior)

---

## 🖥️ Requisitos do Sistema

### Requisitos Mínimos

| Componente | Requisito Mínimo | Recomendado |
|------------|------------------|-------------|
| **MATLAB** | R2020a | R2022a ou superior |
| **RAM** | 4 GB | 8 GB ou mais |
| **Armazenamento** | 2 GB livres | 5 GB ou mais |
| **GPU** | Não obrigatória | NVIDIA com CUDA |

### Toolboxes Obrigatórias

✅ **Essenciais** (obrigatórias):
- **Deep Learning Toolbox** - Para redes neurais
- **Image Processing Toolbox** - Para manipulação de imagens

⚡ **Recomendadas** (para melhor performance):
- **Statistics and Machine Learning Toolbox** - Para análises estatísticas
- **Parallel Computing Toolbox** - Para aceleração GPU

### Verificar Toolboxes Instaladas

```matlab
% Verificar toolboxes instaladas
ver

% Verificar toolboxes específicas
license('test', 'Deep_Learning_Toolbox')
license('test', 'Image_Toolbox')
license('test', 'Statistics_Toolbox')
license('test', 'Distrib_Computing_Toolbox')
```

---

## 🚀 Instalação Rápida

### Para Usuários Experientes

```matlab
% 1. Baixar e extrair o projeto
% 2. Navegar para o diretório do projeto
cd('caminho/para/projeto')

% 3. Executar instalação automática
install_system()

% 4. Configurar dados
configurar_caminhos()

% 5. Testar instalação
executar_testes_completos()

% 6. Usar o sistema
addpath('src/core')
mainInterface = MainInterface()
mainInterface.run()
```

---

## 📦 Instalação Detalhada

### Passo 1: Obter o Código

#### Opção A: Download Direto
1. Baixe o arquivo ZIP do projeto
2. Extraia para um diretório de sua escolha
3. Anote o caminho completo

#### Opção B: Clone (se disponível)
```bash
git clone [URL_DO_REPOSITORIO]
cd comparacao-unet-attention
```

### Passo 2: Verificar Estrutura

Após extração, você deve ter esta estrutura:

```
projeto/
├── src/                    # Código fonte
│   ├── core/              # Componentes principais
│   ├── data/              # Carregamento de dados
│   ├── models/            # Modelos de rede
│   ├── evaluation/        # Avaliação e métricas
│   ├── visualization/     # Visualização
│   └── utils/             # Utilitários
├── tests/                 # Testes automatizados
├── docs/                  # Documentação
├── config/                # Configurações
├── output/                # Resultados (criado automaticamente)
├── img/                   # Dados de exemplo
├── README.md              # Documentação principal
├── INSTALLATION.md        # Este arquivo
└── install_system.m       # Script de instalação
```

### Passo 3: Executar Instalação

```matlab
% Navegar para o diretório do projeto
cd('C:\caminho\para\seu\projeto')  % Windows
% cd('/caminho/para/seu/projeto')   % Linux/Mac

% Executar script de instalação
install_system()
```

O script de instalação irá:
- ✅ Verificar requisitos do sistema
- ✅ Validar toolboxes necessárias
- ✅ Criar estrutura de diretórios
- ✅ Configurar caminhos do MATLAB
- ✅ Executar testes básicos

---

## ⚙️ Configuração Inicial

### Configuração Automática (Recomendada)

```matlab
% Executar configuração automática
configurar_caminhos()
```

O sistema tentará detectar automaticamente:
- Diretórios de imagens e máscaras
- Configurações de hardware (GPU)
- Parâmetros otimizados para seu sistema

### Configuração Manual

Se a configuração automática falhar:

```matlab
% Configuração manual passo a passo
config = struct();

% Definir caminhos dos dados
config.imageDir = 'C:\seus_dados\imagens';
config.maskDir = 'C:\seus_dados\mascaras';

% Configurações de modelo
config.inputSize = [256, 256, 3];
config.numClasses = 2;

% Configurações de treinamento
config.validationSplit = 0.2;
config.miniBatchSize = 8;
config.maxEpochs = 20;

% Salvar configuração
save('config_caminhos.mat', 'config');
```

### Estrutura de Dados Esperada

Organize seus dados assim:

```
seus_dados/
├── imagens/               # Imagens RGB
│   ├── img001.jpg
│   ├── img002.jpg
│   └── ...
└── mascaras/              # Máscaras binárias
    ├── mask001.jpg        # 0 = background, 255 = foreground
    ├── mask002.jpg
    └── ...
```

**Formatos Suportados**: JPG, JPEG, PNG, BMP, TIF, TIFF

---

## ✅ Verificação da Instalação

### Teste Rápido

```matlab
% Teste básico de funcionamento
teste_instalacao_rapido()
```

### Teste Completo

```matlab
% Teste abrangente (recomendado na primeira instalação)
executar_testes_completos()
```

### Teste Manual

```matlab
% 1. Verificar se classes principais carregam
addpath('src/core')
configMgr = ConfigManager();
mainInterface = MainInterface();

% 2. Verificar carregamento de dados
addpath('src/data')
dataLoader = DataLoader();

% 3. Verificar modelos
addpath('src/models')
trainer = ModelTrainer();

% 4. Teste de configuração
config = configurar_caminhos();
disp('✅ Instalação verificada com sucesso!')
```

---

## 🔧 Solução de Problemas

### Problema: Toolbox Não Encontrada

**Erro**: `License checkout failed for Deep_Learning_Toolbox`

**Solução**:
```matlab
% Verificar toolboxes instaladas
ver

% Se não estiver instalada, instalar via Add-On Explorer
% MATLAB → Home → Add-Ons → Get Add-Ons
% Procurar por "Deep Learning Toolbox"
```

### Problema: Erro de Caminho

**Erro**: `Undefined function or variable 'ConfigManager'`

**Solução**:
```matlab
% Adicionar caminhos necessários
addpath('src/core')
addpath('src/data')
addpath('src/models')
addpath('src/evaluation')
addpath('src/visualization')
addpath('src/utils')

% Ou usar função de configuração
setup_paths()
```

### Problema: Dados Não Encontrados

**Erro**: `Diretório de imagens não existe`

**Solução**:
```matlab
% Verificar se caminhos estão corretos
load('config_caminhos.mat')
disp(config.imageDir)
disp(config.maskDir)

% Reconfigurar se necessário
configurar_caminhos()
```

### Problema: Erro de Memória

**Erro**: `Out of memory`

**Solução**:
```matlab
% Reduzir batch size
config.miniBatchSize = 4;  % ou menor

% Usar modo de teste rápido
config.quickTest.numSamples = 20;
config.quickTest.maxEpochs = 3;

% Salvar configuração
save('config_caminhos.mat', 'config');
```

### Problema: GPU Não Detectada

**Erro**: GPU disponível mas não sendo usada

**Solução**:
```matlab
% Verificar GPU
gpuDevice()

% Resetar GPU se necessário
reset(gpuDevice())

% Verificar Parallel Computing Toolbox
license('test', 'Distrib_Computing_Toolbox')
```

---

## 🔄 Migração de Versão Anterior

### Se Você Tem Versão 1.x

```matlab
% 1. Fazer backup da versão atual
backup_sistema_atual()

% 2. Executar migração automática
migrate_system()

% 3. Validar migração
validate_system_consistency()

% 4. Se algo der errado, fazer rollback
% migrator = MigrationManager()
% migrator.rollback()
```

### Preservação de Dados

A migração preserva automaticamente:
- ✅ Suas configurações de caminhos
- ✅ Dados de treinamento existentes
- ✅ Modelos salvos anteriormente
- ✅ Relatórios e resultados

---

## 🎯 Primeiros Passos Após Instalação

### 1. Teste Rápido

```matlab
% Executar teste com dados de exemplo
addpath('src/core')
mainInterface = MainInterface()
mainInterface.run()
% Escolher opção 1 (Teste Rápido)
```

### 2. Configurar Seus Dados

```matlab
% Configurar com seus próprios dados
configurar_caminhos()
% Apontar para suas pastas de imagens e máscaras
```

### 3. Executar Comparação Completa

```matlab
% Executar comparação completa
mainInterface.run()
% Escolher opção 4 (Comparação Completa)
```

---

## 📚 Recursos Adicionais

### Documentação

- **README.md**: Visão geral e início rápido
- **docs/user_guide.md**: Guia detalhado do usuário
- **docs/api_reference.md**: Referência da API
- **CHANGELOG.md**: Histórico de mudanças

### Exemplos

```matlab
% Explorar exemplos
cd('docs/examples')
ls  % Ver exemplos disponíveis
```

### Suporte

- **Logs**: Consulte arquivos `.log` para diagnóstico
- **Testes**: Execute `executar_testes_completos()` para verificar problemas
- **Validação**: Use `validate_system_consistency()` após mudanças

---

## 🔧 Configurações Avançadas

### Otimização de Performance

```matlab
% Para datasets grandes
config.dataLoader.useCache = true;
config.dataLoader.cacheDir = 'cache/';

% Para GPUs potentes
config.training.mixedPrecision = true;
config.training.miniBatchSize = 16;

% Para sistemas com pouca memória
config.training.miniBatchSize = 4;
config.dataLoader.lazyLoading = true;
```

### Configuração Multi-GPU (Avançado)

```matlab
% Verificar GPUs disponíveis
gpuDeviceCount()

% Configurar para múltiplas GPUs
config.hardware.useMultiGPU = true;
config.hardware.gpuIndices = [1, 2];
```

---

## ✅ Checklist de Instalação

- [ ] MATLAB R2020a+ instalado
- [ ] Deep Learning Toolbox instalada
- [ ] Image Processing Toolbox instalada
- [ ] Projeto baixado e extraído
- [ ] `install_system()` executado com sucesso
- [ ] `configurar_caminhos()` executado
- [ ] `executar_testes_completos()` passou todos os testes
- [ ] Teste rápido executado com sucesso
- [ ] Dados próprios configurados (opcional)

---

## 🆘 Suporte

Se você encontrar problemas não cobertos neste guia:

1. **Verifique os logs**: Consulte arquivos `.log` no diretório do projeto
2. **Execute diagnóstico**: `diagnosticar_sistema()`
3. **Consulte documentação**: `docs/user_guide.md`
4. **Teste com dados de exemplo**: Use dados em `img/`

### Informações para Suporte

Ao reportar problemas, inclua:

```matlab
% Executar diagnóstico completo
diagnosticar_sistema()

% Informações do sistema
version
computer
memory
```

---

**Instalação concluída com sucesso? Parabéns! 🎉**

**Próximo passo**: Consulte o [README.md](README.md) para começar a usar o sistema.

---

**Autor**: Heitor Oliveira Gonçalves  
**LinkedIn**: [linkedin.com/in/heitorhog](https://www.linkedin.com/in/heitorhog/)  
**Versão**: 2.0.0  
**Data**: Julho 2025