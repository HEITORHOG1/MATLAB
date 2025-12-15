# Apresentação do Projeto - Detecção Automatizada de Corrosão

## Estrutura da Apresentação

### Equipe de Apresentação
- **Heitor Oliveira Gonçalves** - Tecnologia e Ferramentas
- **Darlan Porto** (Engenheiro Mecânico) - Aços das Vigas
- **Renato Amaral** (Engenheiro Civil) - Impacto e Aplicações

### Conteúdo

1. **Introdução e Contexto**
   - Resumo do projeto
   - Resumo executivo em português
   - Problema e solução

2. **Caracterização dos Materiais** (Darlan)
   - Aço ASTM A572 Grau 50
   - Perfis W utilizados
   - Tipos de corrosão

3. **Impacto e Aplicações Práticas** (Renato)
   - Impacto econômico
   - Aplicações práticas
   - Implicações para manutenção

4. **Tecnologia e Ferramentas** (Heitor)
   - Arquiteturas de Deep Learning
   - Stack tecnológico
   - Dataset e processamento
   - Métricas de avaliação

5. **Resultados**
   - Comparação de desempenho
   - Análise estatística

6. **Conclusões**
   - Principais contribuições
   - Limitações e trabalhos futuros

## Como Compilar

### Opção 1: Linha de Comando
```bash
cd apresentacao
pdflatex apresentacao_projeto.tex
pdflatex apresentacao_projeto.tex  # Segunda compilação para referências
```

### Opção 2: Editor LaTeX
Abra o arquivo `apresentacao_projeto.tex` em seu editor LaTeX favorito (TeXstudio, Overleaf, etc.) e compile.

## Personalização

### Adicionar Logo da Universidade
1. Coloque o arquivo de logo (PNG ou PDF) na pasta `apresentacao/`
2. Descomente a linha no preâmbulo:
```latex
\logo{\includegraphics[height=1cm]{logo_ucp.png}}
```

### Adicionar Figuras
Coloque as figuras na pasta `apresentacao/figuras/` e use:
```latex
\includegraphics[width=0.8\textwidth]{figuras/nome_da_figura.pdf}
```

### Mudar Tema
Para mudar o tema da apresentação, altere:
```latex
\usetheme{Madrid}  % Outros: Berlin, Copenhagen, Warsaw, etc.
\usecolortheme{default}  % Outros: beaver, crane, dolphin, etc.
```

## Observações

- A apresentação está em formato 16:9 (widescreen)
- Resumo executivo em português conforme solicitado
- Sem o Giovane Quadrelli na lista de autores
- Estrutura modular para fácil edição
- Pronta para adicionar figuras e gráficos do artigo

## Próximos Passos

1. Revisar o conteúdo de cada seção
2. Adicionar figuras do artigo original
3. Ajustar detalhes conforme necessário
4. Praticar a apresentação com divisão de tempo