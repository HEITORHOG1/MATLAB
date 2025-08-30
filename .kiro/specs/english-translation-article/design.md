# Design Document

## Overview

This document presents the design for translating the complete scientific article "Detecção Automatizada de Corrosão em Vigas W ASTM A572 Grau 50 Utilizando Redes Neurais Convolucionais: Análise Comparativa entre U-Net e Attention U-Net para Segmentação Semântica" from Portuguese to English. The translation will maintain scientific rigor, technical accuracy, and academic quality while following English scientific writing conventions.

## Architecture

### Translation Strategy

The translation will follow a systematic approach that preserves the document structure while ensuring high-quality English academic writing:

```
Translation Process Flow:
├── 1. Document Analysis
│   ├── Identify technical terminology
│   ├── Map Portuguese-English equivalents
│   └── Preserve LaTeX structure
├── 2. Section-by-Section Translation
│   ├── Title and metadata
│   ├── Abstract (structured format)
│   ├── Keywords
│   ├── Introduction
│   ├── Literature Review
│   ├���─ Methodology
│   ├── Results
│   ├── Discussion
│   ├── Conclusions
│   └── References
├── 3. Technical Content Validation
│   ├── Engineering terminology verification
│   ├── AI/ML terminology accuracy
│   ├── Mathematical notation preservation
│   └── Figure/table caption translation
└── 4. Quality Assurance
    ├── Consistency checking
    ├── Academic tone verification
    ├── LaTeX compilation testing
    └── Final proofreading
```

### Technical Terminology Mapping

#### Structural Engineering Terms
- "Vigas W" → "W-beams"
- "Aço ASTM A572 Grau 50" → "ASTM A572 Grade 50 steel"
- "Corrosão" → "Corrosion"
- "Inspeção estrutural" → "Structural inspection"
- "Integridade estrutural" → "Structural integrity"
- "Deterioração" → "Deterioration"
- "Patologia estrutural" → "Structural pathology"

#### Deep Learning Terms
- "Redes neurais convolucionais" → "Convolutional neural networks"
- "Segmentação semântica" → "Semantic segmentation"
- "Aprendizado profundo" → "Deep learning"
- "Mecanismos de atenção" → "Attention mechanisms"
- "Treinamento" → "Training"
- "Validação cruzada" → "Cross-validation"
- "Hiperparâmetros" → "Hyperparameters"

#### Evaluation Metrics
- "Intersection over Union (IoU)" → Preserved (standard term)
- "Coeficiente Dice" → "Dice coefficient"
- "Precisão" → "Precision"
- "Revocação/Recall" → "Recall"
- "F1-Score" → Preserved (standard term)
- "Acurácia" → "Accuracy"

## Components and Interfaces

### Component 1: Document Structure Analyzer

**Interface:** `DocumentStructureAnalyzer`

**Responsibilities:**
- Parse LaTeX document structure
- Identify sections, subsections, and content blocks
- Map figure and table references
- Preserve mathematical formulations

**Methods:**
- `parseLatexStructure()`: Extract document hierarchy
- `identifyTechnicalTerms()`: Create terminology dictionary
- `mapReferences()`: Track citations and cross-references
- `preserveFormatting()`: Maintain LaTeX commands

### Component 2: Technical Translator

**Interface:** `TechnicalTranslator`

**Responsibilities:**
- Translate technical content with domain expertise
- Maintain terminology consistency
- Preserve scientific accuracy
- Apply English academic writing conventions

**Specialized Translation Modules:**
- `StructuralEngineeringTranslator`: Materials, corrosion, inspection
- `DeepLearningTranslator`: Neural networks, training, evaluation
- `StatisticalAnalysisTranslator`: Metrics, significance tests
- `AcademicWritingTranslator`: Scientific tone and structure

### Component 3: Content Validator

**Interface:** `ContentValidator`

**Responsibilities:**
- Verify technical accuracy
- Check terminology consistency
- Validate academic writing quality
- Ensure completeness

**Validation Checks:**
- Technical term consistency across document
- Proper English scientific writing conventions
- Mathematical notation preservation
- Citation format compliance

### Component 4: Quality Assurance System

**Interface:** `QualityAssuranceSystem`

**Responsibilities:**
- Perform final document review
- Check LaTeX compilation
- Verify no Portuguese text remains
- Generate quality report

## Data Models

### Translation Memory Model

```python
class TranslationMemory:
    terminology_map: {
        'structural_engineering': dict,
        'deep_learning': dict,
        'materials_science': dict,
        'statistics': dict,
        'general_academic': dict
    }
    
    consistency_rules: {
        'technical_terms': list,
        'abbreviations': dict,
        'units_of_measurement': dict,
        'mathematical_notation': dict
    }
    
    quality_metrics: {
        'terminology_consistency': float,
        'academic_tone_score': float,
        'technical_accuracy': float,
        'completeness': float
    }
```

### Document Structure Model

```python
class DocumentStructure:
    metadata: {
        'title': str,
        'authors': list,
        'abstract': str,
        'keywords': list
    }
    
    sections: {
        'introduction': str,
        'literature_review': dict,
        'methodology': dict,
        'results': dict,
        'discussion': dict,
        'conclusions': str
    }
    
    figures: {
        'figure_1_unet_architecture': str,
        'figure_2_attention_unet': str,
        'figure_3_methodology_flowchart': str,
        'figure_4_segmentation_comparison': str,
        'figure_5_performance_graphs': str,
        'figure_6_learning_curves': str,
        'figure_7_attention_maps': str
    }
    
    tables: {
        'table_1_dataset_characteristics': str,
        'table_2_training_configurations': str,
        'table_3_quantitative_results': str,
        'table_4_computational_analysis': str
    }
    
    references: list
```

## Error Handling

### Translation Quality Control

#### 1. Technical Accuracy Validation
```python
def validate_technical_accuracy(translated_text, domain):
    try:
        # Check domain-specific terminology
        if domain == 'structural_engineering':
            required_terms = ['ASTM A572 Grade 50', 'W-beams', 'corrosion']
            for term in required_terms:
                if term not in translated_text:
                    raise ValueError(f"Missing technical term: {term}")
        
        # Verify no Portuguese technical terms remain
        portuguese_terms = ['aço', 'corrosão', 'viga', 'treinamento']
        for term in portuguese_terms:
            if term.lower() in translated_text.lower():
                raise ValueError(f"Portuguese term found: {term}")
        
        return True
    except Exception as e:
        log_error(f"Technical accuracy validation failed: {e}")
        return False
```

#### 2. Consistency Checking
```python
def check_terminology_consistency(document_sections):
    try:
        term_usage = {}
        
        # Track usage of technical terms across sections
        for section_name, content in document_sections.items():
            terms_found = extract_technical_terms(content)
            for term in terms_found:
                if term not in term_usage:
                    term_usage[term] = []
                term_usage[term].append(section_name)
        
        # Check for inconsistent usage
        inconsistencies = []
        for term, sections in term_usage.items():
            if len(set(sections)) > 1:  # Term used differently in different sections
                inconsistencies.append(term)
        
        if inconsistencies:
            raise ValueError(f"Inconsistent terminology: {inconsistencies}")
        
        return True
    except Exception as e:
        log_error(f"Consistency check failed: {e}")
        return False
```

#### 3. LaTeX Compilation Validation
```python
def validate_latex_compilation(tex_file_path):
    try:
        # Attempt to compile LaTeX document
        result = subprocess.run(
            ['pdflatex', '-interaction=nonstopmode', tex_file_path],
            capture_output=True,
            text=True,
            timeout=60
        )
        
        if result.returncode != 0:
            raise ValueError(f"LaTeX compilation failed: {result.stderr}")
        
        # Check for warnings about missing references
        if 'undefined references' in result.stdout.lower():
            raise ValueError("Undefined references found in compiled document")
        
        return True
    except Exception as e:
        log_error(f"LaTeX compilation validation failed: {e}")
        return False
```

## Testing Strategy

### Translation Quality Tests

#### 1. Technical Terminology Accuracy
```python
def test_technical_terminology():
    """Test that all technical terms are correctly translated"""
    expected_translations = {
        'U-Net': 'U-Net',  # Preserved
        'Attention U-Net': 'Attention U-Net',  # Preserved
        'IoU': 'Intersection over Union (IoU)',
        'Dice coefficient': 'Dice coefficient',
        'ASTM A572 Grade 50': 'ASTM A572 Grade 50'
    }
    
    for portuguese_term, english_term in expected_translations.items():
        assert english_term in translated_document
        assert portuguese_term not in translated_document or portuguese_term == english_term
```

#### 2. Academic Writing Quality
```python
def test_academic_writing_quality():
    """Test that the translation follows English academic writing conventions"""
    # Check abstract structure
    abstract_sections = ['background', 'objective', 'methods', 'results', 'conclusions']
    for section in abstract_sections:
        assert section.lower() in translated_abstract.lower()
    
    # Check proper use of passive voice in methodology
    methodology_text = translated_document['methodology']
    passive_indicators = ['was performed', 'were conducted', 'was implemented']
    assert any(indicator in methodology_text for indicator in passive_indicators)
    
    # Check proper statistical reporting
    results_text = translated_document['results']
    statistical_terms = ['p <', 'confidence interval', 'standard deviation']
    assert any(term in results_text for term in statistical_terms)
```

#### 3. Completeness Verification
```python
def test_translation_completeness():
    """Test that no content was lost during translation"""
    # Check all sections are present
    required_sections = [
        'introduction', 'methodology', 'results', 
        'discussion', 'conclusions', 'references'
    ]
    for section in required_sections:
        assert section in translated_document
        assert len(translated_document[section]) > 0
    
    # Check all figures and tables are referenced
    figure_references = ['Figure 1', 'Figure 2', 'Figure 3', 'Figure 4', 
                        'Figure 5', 'Figure 6', 'Figure 7']
    table_references = ['Table 1', 'Table 2', 'Table 3', 'Table 4']
    
    full_text = ' '.join(translated_document.values())
    for ref in figure_references + table_references:
        assert ref in full_text
```

#### 4. LaTeX Integrity Test
```python
def test_latex_integrity():
    """Test that LaTeX structure is preserved"""
    # Check essential LaTeX commands are present
    latex_commands = [
        '\\documentclass', '\\begin{document}', '\\end{document}',
        '\\section', '\\subsection', '\\cite', '\\ref'
    ]
    
    with open('artigo_cientifico_corrosao.tex', 'r', encoding='utf-8') as f:
        tex_content = f.read()
    
    for command in latex_commands:
        assert command in tex_content
    
    # Check mathematical equations are preserved
    math_environments = ['\\begin{equation}', '\\end{equation}']
    for env in math_environments:
        assert env in tex_content
```

### Quality Metrics

#### Translation Quality Score
```python
def calculate_translation_quality_score():
    """Calculate overall translation quality score"""
    scores = {
        'technical_accuracy': test_technical_terminology(),
        'academic_writing': test_academic_writing_quality(),
        'completeness': test_translation_completeness(),
        'latex_integrity': test_latex_integrity()
    }
    
    # Weight the scores
    weights = {
        'technical_accuracy': 0.3,
        'academic_writing': 0.3,
        'completeness': 0.2,
        'latex_integrity': 0.2
    }
    
    total_score = sum(scores[metric] * weights[metric] for metric in scores)
    
    if total_score >= 0.95:
        quality_level = 'Excellent'
    elif total_score >= 0.85:
        quality_level = 'Very Good'
    elif total_score >= 0.75:
        quality_level = 'Good'
    else:
        quality_level = 'Needs Improvement'
    
    return total_score, quality_level
```

## Implementation Approach

### Phase 1: Preparation and Analysis
- Analyze current Portuguese document structure
- Create comprehensive terminology dictionary
- Set up translation memory system
- Prepare English academic writing templates

### Phase 2: Core Content Translation
- Translate title, abstract, and keywords
- Translate introduction with proper academic flow
- Translate methodology maintaining technical precision
- Translate results preserving statistical accuracy

### Phase 3: Technical Content Refinement
- Translate discussion with proper academic argumentation
- Translate conclusions maintaining logical flow
- Update all figure and table captions
- Verify mathematical formulations

### Phase 4: Quality Assurance and Finalization
- Perform comprehensive consistency checking
- Validate technical terminology accuracy
- Test LaTeX compilation and formatting
- Generate final quality assessment report

## Success Criteria

The translation will be considered successful when:

1. **Technical Accuracy**: 100% of technical terms correctly translated
2. **Academic Quality**: Follows English scientific writing conventions
3. **Completeness**: No content lost during translation
4. **Consistency**: Uniform terminology usage throughout
5. **Compilation**: LaTeX document compiles without errors
6. **Readability**: Natural English flow suitable for international publication

The final deliverable will be a publication-ready English version of the scientific article that maintains the original's scientific rigor while meeting international academic standards.