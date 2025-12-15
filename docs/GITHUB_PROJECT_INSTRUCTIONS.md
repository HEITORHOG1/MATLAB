# Instruções para Publicar o Projeto no GitHub

## Estrutura Criada

Foi criada uma pasta `github-project/` com toda a estrutura necessária para publicar seu projeto no GitHub. A estrutura inclui:

```
github-project/
├── README.md                          # Documentação principal (completa)
├── LICENSE                            # Licença MIT
├── requirements.txt                   # Dependências Python
├── .gitignore                        # Arquivos a ignorar no git
│
├── data/                             # Diretório para dataset
│   └── .gitkeep
│
├── matlab/                           # Códigos MATLAB
│   ├── prepare_dataset.m             # Preparação do dataset
│   ├── train_resnet50.m              # Treinar ResNet50
│   ├── train_efficientnet.m          # Treinar EfficientNet-B0
│   ├── train_custom_cnn.m            # Treinar Custom CNN
│   └── evaluate_model.m              # Avaliar modelos
│
├── python/                           # Scripts Python
│   └── analyze_results.py            # Análise de resultados
│
├── models/                           # Modelos treinados (não incluídos no git)
│   └── .gitkeep
│
├── results/                          # Resultados e figuras
│   └── .gitkeep
│
└── docs/                             # Documentação
    └── TRAINING.md                   # Guia de treinamento
```

## Passos para Publicar no GitHub

### 1. Criar Repositório no GitHub

1. Acesse https://github.com/new
2. Nome do repositório: `corrosion-classification-astm-a572`
3. Descrição: "Deep Learning-Based Corrosion Severity Classification for ASTM A572 Grade 50 Steel Structures"
4. Público ou Privado (sua escolha)
5. **NÃO** inicialize com README, .gitignore ou license (já temos esses arquivos)
6. Clique em "Create repository"

### 2. Preparar o Projeto Localmente

Abra o terminal/PowerShell na pasta do projeto:

```powershell
# Navegue até a pasta github-project
cd C:\projetos\MATLAB2\github-project

# Inicialize o repositório git
git init

# Adicione todos os arquivos
git add .

# Faça o primeiro commit
git commit -m "Initial commit: Deep learning corrosion classification"

# Adicione o repositório remoto (substitua SEU_USUARIO pelo seu username)
git remote add origin https://github.com/heitorhog/corrosion-classification-astm-a572.git

# Envie para o GitHub
git push -u origin main
```

**Nota:** Se o git pedir para configurar nome e email:
```powershell
git config --global user.name "Heitor Oliveira Gonçalves"
git config --global user.email "heitorhog@gmail.com"
```

### 3. Verificar no GitHub

1. Acesse seu repositório: https://github.com/heitorhog/corrosion-classification-astm-a572
2. Verifique se todos os arquivos foram enviados
3. O README.md será exibido automaticamente na página principal

### 4. Adicionar Badges (Opcional mas Recomendado)

O README já inclui badges para:
- Licença MIT
- MATLAB R2023b
- Python 3.12

### 5. Configurar GitHub Pages (Opcional)

Para criar uma página web do projeto:

1. Vá em Settings → Pages
2. Source: Deploy from a branch
3. Branch: main, folder: /docs
4. Save

## O Que NÃO Incluir no GitHub

O `.gitignore` já está configurado para excluir:

- ✗ Dataset (imagens proprietárias)
- ✗ Modelos treinados (.mat, .h5, .pth - muito grandes)
- ✗ Resultados temporários
- ✗ Arquivos de cache do MATLAB/Python

## Atualizando o Link no Artigo

Depois de publicar no GitHub, atualize o artigo:

### No arquivo `artigo_elsevier_classification_optimized.tex`:

Procure por:
```latex
[GitHub repository URL to be added upon acceptance]
```

Substitua por:
```latex
https://github.com/heitorhog/corrosion-classification-astm-a572
```

### Recompilar o artigo:

```powershell
cd C:\projetos\MATLAB2
compile_elsevier_optimized.bat
```

## Estrutura de Commits Recomendada

Para manter um histórico organizado:

```powershell
# Commit inicial
git commit -m "Initial commit: Project structure and documentation"

# Adicionar códigos MATLAB
git commit -m "Add MATLAB training scripts"

# Adicionar análise Python
git commit -m "Add Python analysis scripts"

# Adicionar documentação
git commit -m "Add training and deployment documentation"

# Atualizações futuras
git commit -m "Update: [descrição da mudança]"
```

## Adicionando Releases (Versões)

Quando o artigo for aceito, crie uma release:

1. Vá em "Releases" → "Create a new release"
2. Tag version: `v1.0.0`
3. Release title: "v1.0.0 - Initial Release"
4. Description:
```
First official release accompanying the paper:
"Deep Learning-Based Corrosion Severity Classification for ASTM A572 Grade 50 Steel Structures"

Published in: [Nome da Revista]
DOI: [DOI do artigo]

This release includes:
- Complete training code for ResNet50, EfficientNet-B0, and Custom CNN
- Evaluation and analysis scripts
- Comprehensive documentation
```

## Adicionando DOI via Zenodo (Opcional)

Para tornar o código citável:

1. Acesse https://zenodo.org/
2. Faça login com GitHub
3. Ative o repositório
4. Crie uma release no GitHub
5. Zenodo gerará automaticamente um DOI

## Mantendo o Repositório Atualizado

```powershell
# Adicionar novos arquivos
git add .

# Commit com mensagem descritiva
git commit -m "Add: [descrição]"

# Enviar para GitHub
git push
```

## Colaboração

Se quiser permitir colaborações:

1. Settings → Manage access
2. Invite collaborators
3. Ou aceite Pull Requests de outros usuários

## Issues e Discussões

Ative Issues para que usuários possam:
- Reportar bugs
- Sugerir melhorias
- Fazer perguntas

Settings → Features → Issues (marcar checkbox)

## Estatísticas e Insights

Após publicar, você pode ver:
- Número de clones
- Número de visitantes
- Tráfego do repositório

Em: Insights → Traffic

## Checklist Final

Antes de publicar, verifique:

- [ ] README.md completo e claro
- [ ] LICENSE incluída
- [ ] .gitignore configurado
- [ ] Códigos comentados e documentados
- [ ] requirements.txt atualizado
- [ ] Documentação em docs/
- [ ] Exemplos de uso no README
- [ ] Informações de contato corretas
- [ ] Link do artigo (quando disponível)

## Promovendo o Repositório

Após publicar:

1. **Adicione ao artigo:**
   - Na seção "Data Availability Statement"
   - No abstract (se permitido)

2. **Compartilhe:**
   - LinkedIn
   - ResearchGate
   - Twitter/X
   - Comunidades de ML/Deep Learning

3. **Adicione tópicos no GitHub:**
   - deep-learning
   - computer-vision
   - corrosion-detection
   - transfer-learning
   - civil-engineering
   - infrastructure-monitoring
   - matlab
   - resnet
   - efficientnet

## Suporte

Se tiver dúvidas sobre Git/GitHub:
- Documentação oficial: https://docs.github.com/
- Git tutorial: https://git-scm.com/docs/gittutorial
- GitHub Learning Lab: https://lab.github.com/

## Próximos Passos

1. ✅ Criar repositório no GitHub
2. ✅ Fazer push do código
3. ✅ Atualizar link no artigo
4. ✅ Recompilar PDF
5. ⏳ Aguardar aceitação do artigo
6. ⏳ Criar release v1.0.0
7. ⏳ Adicionar DOI via Zenodo
8. ⏳ Promover o repositório

---

**Importante:** O dataset não deve ser incluído no GitHub por ser proprietário. Usuários interessados devem entrar em contato para colaboração acadêmica.

**Contato:** heitorhog@gmail.com
