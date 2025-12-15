# Resposta aos Revisores - Artigo Corrosão ASTM A572

**Data:** 15 de Dezembro de 2025
**Artigo:** Automated Corrosion Detection in ASTM A572 Grade 50 W-Beams Using U-Net and Attention U-Net

---

## Resumo das Modificações Realizadas

Agradecemos aos revisores pelos comentários construtivos que permitiram melhorar significativamente a qualidade do manuscrito. Abaixo apresentamos as respostas ponto a ponto.

---

## 🔴 PROBLEMAS CRÍTICOS - RESOLVIDOS

### 1. Inconsistência 414 vs 217 Imagens ✅ CORRIGIDO

**Problema identificado:** O resumo mencionava 414 imagens enquanto a Tabela 1 indicava 217 imagens.

**Solução:** Esclarecemos que o dataset ORIGINAL contém 217 imagens de alta resolução. Após aplicação de data augmentation, o dataset expandido contém 414 imagens utilizadas para treinamento/validação/teste.

**Alterações realizadas:**
- Abstract: Linhas 55-72 - Reescrito para explicitar "217 original high-resolution images... After data augmentation, the final dataset contained 414 images"
- Tabela 1: Linhas 102-145 - Reestruturada com seções "Original Dataset" e "After Data Augmentation"
- Texto após Tabela 1: Explicação clara da relação 217 → 414

### 2. Tabelas e Figuras Referenciadas no Texto ✅ CORRIGIDO

**Problema:** Tabela 2 não era referenciada explicitamente no texto.

**Solução:** Adicionada referência explícita à Tabela 2 na linha do texto:
- Linha 283: "Table~\ref{tab:training_configurations} summarizes all training configurations..."

---

## 🟡 ALTA PRIORIDADE - RESOLVIDOS

### 3. Resumo (Abstract) - Reestruturado ✅ CORRIGIDO

**Estrutura implementada:**
- Parágrafo 1 (1-4 frases): Problema + necessidade da pesquisa
- Parágrafo 2 (1-3 frases): Metodologia resumida + origem das imagens
- Parágrafo 3: Resultados ESPECÍFICOS com valores estatísticos
- Última frase: Conclusão principal clara

**Valores específicos incluídos:**
- IoU: 0.775 ± 0.089 vs 0.693 ± 0.078 (11.8% improvement, p < 0.001, Cohen's d = 0.98)
- Dice: 0.741 ± 0.067 vs 0.678 ± 0.071 (9.3% improvement)
- F1-Score: 0.823 ± 0.054 vs 0.751 ± 0.063 (9.6% improvement)
- False positive reduction: 46% (12.8% vs 23.4%)
- Pitting detection: 87.3% vs 71.2%

### 4. Introdução - Fortalecida ✅ CORRIGIDO

**Alterações realizadas:**
- **Tabela Comparativa:** Nova Table 2 (tab:related_works) com 7 estudos relacionados incluindo: Autor/ano, Tipo de dataset, Arquitetura, Métricas, Principais achados/limitações
- **Parágrafo final:** Adicionada descrição da estrutura do artigo
- **Contribuição original explícita:** "To the best of the authors' knowledge, this is the first rigorous comparative evaluation between U-Net and Attention U-Net architectures specifically for corrosion detection in ASTM A572 Grade 50 structural steel W-beams..."
- **Análise crítica:** Novo parágrafo dialogando com literatura existente e identificando lacunas
- **Referências 2023-2025:** 12 novas referências adicionadas ao referencias.bib

### 5. Metodologia - Detalhes Adicionados ✅ CORRIGIDO

**Justificativa BCE + Dice Loss:**
- Linhas 289-291: Explicação teórica detalhada da escolha
- Citações adicionadas: \cite{sudre2017generalised}, \cite{milletari2016v}
- Resultado da grid search: α ∈ {0.3, 0.5, 0.7, 0.9}
- Ganhos quantificados: 4.2% vs BCE alone, 2.8% vs Dice alone

### 6. Discussão - EXPANDIDA SIGNIFICATIVAMENTE ✅ CORRIGIDO

**5 novas subseções adicionadas (linhas 596-660):**

1. **Comparative Analysis with Alternative Approaches** (§4.4)
   - Comparação com Atha & Jahanshahi (2018), Forkan et al. (2022)
   - Vision Transformers, CNN-LSTM approaches

2. **Representativeness for Real-World Scenarios** (§4.5)
   - Limitações de iluminação controlada vs campo
   - Variações angulares
   - Contaminação ambiental
   - Condições de pintura/revestimento

3. **Overfitting Risk Assessment and Mitigation** (§4.6)
   - Técnicas de regularização
   - Data augmentation
   - Resultados cross-validation
   - Comparação validação vs teste

4. **Generalization Limitations and Scope Boundaries** (§4.7)
   - Especificidade do material (ASTM A572 Grade 50)
   - Restrições geométricas
   - Condições de exposição ambiental
   - Limitações de severidade

5. **Implications of False Positives and False Negatives in Practice** (§4.8)
   - Implicações econômicas de FP
   - Implicações de segurança de FN
   - Protocolos de inspeção baseados em risco

### 7. Conclusões - Reescritas com Valores Específicos ✅ CORRIGIDO

**Alterações realizadas:**
- Todos os valores estatísticos incluídos em cada conclusão
- **Novas seções práticas:**
  - Recomendações para Inspetores de Campo (4 itens)
  - Recomendações para Implementação de Sistema (3 itens)
  - Direções Prioritárias para Pesquisas Futuras (4 itens com horizonte temporal)

---

## 🟢 PRIORIDADE MÉDIA

### 8. Afiliações dos Autores ✅ CORRIGIDO

Cada autor agora possui:
- Posição/título (Ph.D. Candidate, M.Sc., Ph.D., Full Professor)
- Instituição completa
- Endereço completo (Rua Benjamin Constant 213, Centro, Petrópolis, RJ, 25610-130, Brazil)
- Email institucional
- ORCID (placeholder para ser preenchido)

### 9. Referências Bibliográficas ✅ CORRIGIDO

**12 novas referências de 2023-2025 adicionadas:**
- chen2023deep (Automation in Construction)
- zhang2024transformer (Engineering Applications of AI)
- liu2024hybrid (Structural Health Monitoring)
- wang2023attention (IEEE Trans. Instrumentation and Measurement)
- kumar2024deep (Structural Control and Health Monitoring)
- park2023automated (Construction and Building Materials)
- santos2024semantic (NDT & E International)
- li2023realtime (Journal of Computing in Civil Engineering - ASCE)
- johnson2024transfer (Computers in Industry)
- garcia2023uav (Ocean Engineering)
- zhao2024efficientnet (IEEE CASE 2024)
- thompson2023explainable (Engineering Structures)

---

## 🔵 PENDENTES (Requerem ação manual)

### Figuras em Inglês
- [ ] Figura 1 (fluxograma): Requer edição manual do PDF/SVG
- [ ] Figura 3: Requer edição manual
- [ ] Figura 4: Requer edição manual
- [ ] Figura 6: Requer edição manual

**Nota:** Os arquivos fonte (SVG/PDF) estão na pasta `figuras/`. A tradução requer software de edição vetorial (Inkscape, Adobe Illustrator).

### Documento de Legendas Separado
- [ ] Criar arquivo Word com legendas das figuras

---

## Checklist Final

- [x] Inconsistência 414 vs 217 imagens resolvida
- [x] Tabela comparativa de estudos relacionados criada
- [x] Discussão expandida com 5+ novas subseções
- [x] Conclusões reescritas com valores específicos
- [x] Todas tabelas/figuras referenciadas no texto
- [x] 12 referências pós-2023 adicionadas
- [x] Afiliações completas para todos autores
- [x] Justificativa BCE + Dice Loss adicionada
- [ ] Figuras traduzidas para inglês (pendente - requer edição manual)
- [ ] Arquivo de legendas separado (pendente)

---

**Arquivos modificados:**
1. `artigo_cientifico_corrosao.tex` - Documento principal
2. `referencias.bib` - Referências bibliográficas

**Próximos passos recomendados:**
1. Traduzir figuras para inglês usando software de edição vetorial
2. Revisar ORCID dos autores
3. Compilar documento LaTeX para verificar referências
4. Submeter para verificação de plágio
