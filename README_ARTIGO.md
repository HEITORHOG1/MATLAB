# Artigo Científico: Detecção Automatizada de Corrosão

Este repositório contém o artigo científico completo sobre "Detecção Automatizada de Corrosão em Vigas W ASTM A572 Grau 50 Utilizando Redes Neurais Convolucionais: Análise Comparativa entre U-Net e Attention U-Net para Segmentação Semântica".

## Estrutura do Projeto

```
.
├── artigo_cientifico_corrosao.tex    # Arquivo principal LaTeX
├── referencias.bib                    # Bibliografia em formato BibTeX
├── Makefile                          # Automação de compilação
├── README_ARTIGO.md                  # Este arquivo
├── figuras/                          # Diretório para figuras
│   ├── figura_unet_arquitetura.svg
│   ├── figura_attention_unet_arquitetura.svg
│   ├── figura_fluxograma_metodologia.svg
│   ├── figura_comparacao_segmentacoes.png
│   ├── figura_performance_comparativa.svg
│   ├── figura_curvas_aprendizado.svg
│   └── figura_mapas_atencao.png
├── tabelas/                          # Diretório para tabelas LaTeX
│   ├── tabela_caracteristicas_dataset.tex
│   ├── tabela_configuracoes_treinamento.tex
│   ├── tabela_resultados_quantitativos.tex
│   └── tabela_tempo_computacional.tex
└── dados/                            # Diretório para dados experimentais
    ├── metricas_experimentais.mat
    ├── configuracoes_treinamento.json
    ├── resultados_estatisticos.csv
    ├── dados_dataset.json
    └── tempos_computacionais.csv
```

## Compilação

### Pré-requisitos
- LaTeX (TeX Live, MiKTeX ou similar)
- BibTeX para processamento de referências
- Make (opcional, para usar o Makefile)

### Comandos de Compilação

#### Usando Makefile (recomendado)
```bash
# Compilação completa com bibliografia
make all

# Compilação rápida (sem bibliografia)
make quick

# Visualizar PDF
make view

# Limpar arquivos temporários
make clean

# Ver todos os comandos disponíveis
make help
```

#### Compilação manual
```bash
# Primeira compilação
pdflatex artigo_cientifico_corrosao.tex

# Processar bibliografia
bibtex artigo_cientifico_corrosao

# Segunda compilação (resolve referências)
pdflatex artigo_cientifico_corrosao.tex

# Terceira compilação (finaliza referências cruzadas)
pdflatex artigo_cientifico_corrosao.tex
```

## Estrutura do Artigo (IMRAD)

1. **Título e Metadados**
   - Título completo e descritivo
   - Autores e afiliações
   - Resumo estruturado
   - Palavras-chave

2. **Introdução**
   - Contextualização da corrosão em estruturas metálicas
   - Formulação do problema
   - Objetivos da pesquisa
   - Justificativa e relevância

3. **Revisão da Literatura**
   - Deep Learning para Inspeção Estrutural
   - Arquiteturas U-Net
   - Mecanismos de Atenção
   - Estado da Arte em Detecção de Corrosão

4. **Metodologia**
   - Caracterização do material ASTM A572 Grau 50
   - Descrição do dataset
   - Arquiteturas de redes neurais
   - Protocolo experimental
   - Métricas de avaliação

5. **Resultados**
   - Análise descritiva do dataset
   - Performance das arquiteturas
   - Análise comparativa quantitativa
   - Análise qualitativa das segmentações

6. **Discussão**
   - Interpretação dos resultados
   - Implicações práticas
   - Limitações do estudo
   - Direções futuras

7. **Conclusões**

8. **Referências Bibliográficas**

9. **Apêndices**

## Figuras Necessárias

- **Figura 1:** Diagrama da arquitetura U-Net clássica
- **Figura 2:** Diagrama da arquitetura Attention U-Net
- **Figura 3:** Fluxograma da metodologia experimental
- **Figura 4:** Comparação visual de segmentações
- **Figura 5:** Gráficos de performance comparativa
- **Figura 6:** Curvas de aprendizado
- **Figura 7:** Mapas de atenção (Attention U-Net)

## Tabelas Necessárias

- **Tabela 1:** Características do dataset
- **Tabela 2:** Configurações de treinamento
- **Tabela 3:** Resultados quantitativos comparativos
- **Tabela 4:** Análise de tempo computacional

## Critérios de Qualidade

O artigo segue os critérios I-R-B-MB-E (Insuficiente, Regular, Bom, Muito Bom, Excelente), visando atingir o nível **Excelente** em todas as seções:

- ✅ Estrutura IMRAD rigorosa
- ✅ Metodologia reproduzível
- ✅ Análise estatística robusta
- ✅ Referências bibliográficas completas
- ✅ Figuras e tabelas de alta qualidade
- ✅ Redação científica precisa

## Contribuições

Este artigo apresenta:

1. **Contribuição Metodológica:** Comparação sistemática entre U-Net e Attention U-Net para detecção de corrosão
2. **Contribuição Técnica:** Dataset especializado em corrosão de vigas ASTM A572 Grau 50
3. **Contribuição Prática:** Ferramenta automatizada para inspeção estrutural
4. **Contribuição Científica:** Análise estatística rigorosa das diferenças entre arquiteturas

## Contato

Para dúvidas sobre o artigo ou colaborações, entre em contato através de [autor@instituicao.edu.br].

## Licença

Este trabalho está licenciado sob [especificar licença apropriada].