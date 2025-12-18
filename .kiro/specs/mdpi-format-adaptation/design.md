# Design Document

## Overview

This design document outlines the technical approach for adapting the corrosion classification article from ASCE format to MDPI format. The adaptation will create a new LaTeX file (`artigo_mdpi_classification.tex`) that uses the MDPI template while preserving all scientific content from the original ASCE article (`artigo_pure_classification.tex`).

The design follows a systematic approach: (1) analyze MDPI template structure and requirements, (2) map ASCE content to MDPI sections, (3) adapt LaTeX commands and environments, (4) optimize content for page limits, and (5) validate the final document.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Input Documents                           │
├─────────────────────────────────────────────────────────────┤
│  • artigo_pure_classification.tex (ASCE format)             │
│  • MDPI_template_ACS/template.tex (MDPI template)           │
│  • referencias_pure_classification.bib (bibliography)        │
│  • figuras_pure_classification/ (figures directory)         │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              Adaptation Process                              │
├─────────────────────────────────────────────────────────────┤
│  1. Document Class & Preamble Conversion                    │
│  2. Metadata & Front Matter Adaptation                      │
│  3. Content Section Mapping                                 │
│  4. Figure & Table Reformatting                             │
│  5. Bibliography Conversion                                 │
│  6. Page Length Optimization                                │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Output Document                           │
├─────────────────────────────────────────────────────────────┤
│  • artigo_mdpi_classification.tex (MDPI format)             │
│  • artigo_mdpi_classification.pdf (compiled output)         │
└─────────────────────────────────────────────────────────────┘
```

### Component Architecture

The adaptation system consists of six major components:

1. **Document Class Converter**: Transforms ASCE document class to MDPI
2. **Content Mapper**: Maps ASCE sections to MDPI structure
3. **Figure/Table Adapter**: Reformats visual elements for MDPI
4. **Bibliography Converter**: Adapts citation style to MDPI format
5. **Metadata Generator**: Creates required MDPI metadata sections
6. **Length Optimizer**: Ensures document fits within page limits

## Components and Interfaces

### 1. Document Class Converter

**Purpose**: Convert ASCE document class and preamble to MDPI format

**Input**:
- ASCE document class: `\documentclass[Journal,letterpaper,InsideFigs]{ascelike-new}`
- ASCE packages and configurations

**Output**:
- MDPI document class: `\documentclass[journal,article,submit,pdftex,moreauthors]{Definitions/mdpi}`
- MDPI-compatible packages

**Transformation Rules**:

| ASCE Element | MDPI Equivalent | Notes |
|--------------|-----------------|-------|
| `\documentclass{ascelike-new}` | `\documentclass{Definitions/mdpi}` | Change class file |
| `\NameTag{...}` | Remove | Not used in MDPI |
| `\graphicspath{{figuras_pure_classification/}}` | Keep | Same path |
| `\usepackage[style=base,figurename=Fig.]{caption}` | Remove | MDPI handles captions |
| `\usepackage{newtxtext,newtxmath}` | Remove | MDPI uses different fonts |

**Package Compatibility**:
- Keep: `graphicx`, `amsmath`, `siunitx`, `booktabs`, `array`, `multirow`, `hyperref`
- Remove: `caption`, `subcaption` (MDPI provides these)
- Add: None (MDPI class loads required packages)

### 2. Content Mapper

**Purpose**: Map ASCE content sections to MDPI structure

**Section Mapping**:

| ASCE Section | MDPI Section | Modifications |
|--------------|--------------|---------------|
| Abstract | Abstract | Restructure to 200 words, add structure |
| Keywords | Keywords | Change format to semicolon-separated |
| Introduction | Introduction | Keep content, adjust formatting |
| Methodology | Materials and Methods | Rename section |
| Results | Results | Keep structure |
| Discussion | Discussion | Keep structure |
| Conclusions | Conclusions | Keep structure |
| Acknowledgments | Acknowledgments | Move to end matter |
| References | References | Adapt citation style |
| Data Availability | Data Availability Statement | Add as new section |

**Content Preservation Strategy**:
- All scientific content must be preserved
- Technical details remain intact
- Results and findings unchanged
- Discussion points maintained

### 3. Figure/Table Adapter

**Purpose**: Reformat figures and tables for MDPI compliance

**Figure Adaptation**:

ASCE Format:
```latex
\begin{figure}[htbp]
\centering
\includegraphics[width=0.95\textwidth]{figura_sample_images.pdf}
\caption{Caption text}
\label{fig:sample_images}
\end{figure}
```

MDPI Format:
```latex
\begin{figure}[H]
\centering
\includegraphics[width=0.95\textwidth]{figura_sample_images.pdf}
\caption{Caption text}
\label{fig:sample_images}
\end{figure}
```

**Table Adaptation**:

ASCE Format:
```latex
\begin{table}[htbp]
\caption{Caption}
\label{tab:label}
\centering
\begin{tabular}{lccc}
...
\end{tabular}
\end{table}
```

MDPI Format:
```latex
\begin{table}[H]
\caption{Caption}
\label{tab:label}
\centering
\begin{tabularx}{\textwidth}{CCC}
...
\end{tabularx}
\end{table}
```

**Multi-Panel Figures**:
- Use MDPI's `\subfloat` command
- Wrap in `adjustwidth` environment for full-width figures
- Label panels as (a), (b), (c), etc.

### 4. Bibliography Converter

**Purpose**: Adapt bibliography to MDPI citation style

**Citation Style**:
- MDPI uses numeric citations: `\cite{ref-key}`
- References numbered in order of appearance
- Bibliography formatted per MDPI guidelines

**Bibliography Format**:

MDPI uses either:
1. Internal bibliography with `\begin{thebibliography}` environment
2. External BibTeX file with appropriate style

**Conversion Strategy**:
- Keep existing BibTeX file: `referencias_pure_classification.bib`
- Use MDPI-compatible bibliography style
- Ensure all references follow MDPI format:
  - Journal articles: Author(s). Title. *Journal* **Year**, *Volume*, Pages.
  - Books: Author(s). *Title*; Publisher: Location, Year; Pages.
  - Conference: Author(s). Title. In *Proceedings*; Location, Date; Pages.

### 5. Metadata Generator

**Purpose**: Create required MDPI metadata sections

**Required Metadata Sections**:

1. **Title and Authors**:
```latex
\Title{DEEP LEARNING-BASED CORROSION SEVERITY CLASSIFICATION FOR ASTM A572 GRADE 50 STEEL STRUCTURES: A TRANSFER LEARNING APPROACH}

\Author{Heitor Oliveira Gonçalves $^{1}$, Darlan Porto $^{1}$, Renato Amaral $^{1}$, Celso Santana Santos Pereira $^{1}$, Cleber Mange Esteves $^{1}$ and Giovane Quadrelli $^{1,}$*}

\address{$^{1}$ Catholic University of Petrópolis (UCP), Petrópolis, Rio de Janeiro, Brazil}

\corres{Correspondence: heitorhog@gmail.com}
```

2. **Abstract** (200 words, structured):
- Background: Context and problem statement
- Methods: Brief methodology description
- Results: Key findings
- Conclusions: Main implications

3. **Keywords** (3-10 keywords, semicolon-separated):
```latex
\keyword{Deep Learning; Corrosion Classification; Transfer Learning; ASTM A572 Grade 50; ResNet; EfficientNet; Structural Inspection; Computer Vision; Infrastructure Monitoring}
```

4. **Author Contributions**:
```latex
\authorcontributions{Conceptualization, H.O.G., D.P., and G.Q.; methodology, H.O.G. and D.P.; software, H.O.G.; validation, H.O.G., R.A., and C.S.S.P.; formal analysis, H.O.G.; investigation, H.O.G. and D.P.; resources, G.Q.; data curation, H.O.G.; writing---original draft preparation, H.O.G.; writing---review and editing, H.O.G., D.P., R.A., C.S.S.P., C.M.E., and G.Q.; visualization, H.O.G.; supervision, D.P., C.M.E., and G.Q.; project administration, G.Q. All authors have read and agreed to the published version of the manuscript.}
```

5. **Funding**:
```latex
\funding{This research received no external funding.}
```

6. **Institutional Review Board Statement**:
```latex
\institutionalreview{Not applicable for studies not involving humans or animals.}
```

7. **Informed Consent Statement**:
```latex
\informedconsent{Not applicable for studies not involving humans.}
```

8. **Data Availability Statement**:
```latex
\dataavailability{The code for model training, evaluation, and figure generation is publicly available at: \url{https://github.com/[USERNAME]/corrosion-classification}. The trained model weights are available upon reasonable request to the corresponding author. The dataset cannot be publicly shared due to proprietary restrictions.}
```

9. **Conflicts of Interest**:
```latex
\conflictsofinterest{The authors declare no conflicts of interest.}
```

### 6. Length Optimizer

**Purpose**: Ensure document fits within MDPI page limits (20-25 pages)

**Optimization Strategies**:

1. **Abstract Condensation**:
   - Current: ~300 words
   - Target: ~200 words
   - Strategy: Remove redundant phrases, condense methodology description

2. **Introduction Streamlining**:
   - Current: ~1200 words
   - Target: ~900 words
   - Strategy: Condense literature review, focus on key gaps

3. **Methodology Optimization**:
   - Keep all technical details
   - Use more compact table formatting
   - Optimize figure sizes

4. **Results Section**:
   - Keep all quantitative results
   - Condense descriptive text
   - Optimize table layouts

5. **Discussion Condensation**:
   - Current: ~2000 words
   - Target: ~1500 words
   - Strategy: Merge related subsections, remove redundancy

6. **Figure Optimization**:
   - Reduce figure widths where appropriate (0.85\textwidth instead of 0.95\textwidth)
   - Use multi-panel figures to save space
   - Ensure figures remain readable

## Data Models

### Document Structure Model

```
Document
├── Front Matter
│   ├── Title
│   ├── Authors
│   ├── Affiliations
│   ├── Correspondence
│   ├── Abstract
│   └── Keywords
├── Main Content
│   ├── Introduction
│   ├── Materials and Methods
│   │   ├── Dataset Description
│   │   ├── Model Architectures
│   │   ├── Training Configuration
│   │   └── Evaluation Metrics
│   ├── Results
│   │   ├── Overall Performance
│   │   ├── Confusion Matrix Analysis
│   │   ├── Training Dynamics
│   │   ├── Inference Time Analysis
│   │   └── Complexity vs Performance
│   ├── Discussion
│   │   ├── Transfer Learning Effectiveness
│   │   ├── Architecture Comparison
│   │   ├── Practical Applications
│   │   ├── Deployment Considerations
│   │   ├── Limitations
│   │   └── Future Work
│   └── Conclusions
├── Back Matter
│   ├── Acknowledgments
│   ├── Author Contributions
│   ├── Funding
│   ├── Institutional Review
│   ├── Informed Consent
│   ├── Data Availability
│   ├── Conflicts of Interest
│   └── References
└── Supplementary Materials (optional)
```

### Figure/Table Registry

| Element | Type | Label | Caption | Location |
|---------|------|-------|---------|----------|
| Sample Images | Figure | fig:sample_images | Representative examples | Section 2.1 |
| Dataset Statistics | Table | tab:dataset_statistics | Class distribution | Section 2.1 |
| Model Architectures | Table | tab:model_architectures | Architecture characteristics | Section 2.2 |
| Training Config | Table | tab:training_config | Training parameters | Section 2.3 |
| Performance Metrics | Table | tab:performance_metrics | Validation metrics | Section 3.1 |
| Confusion Matrices | Figure | fig:confusion_matrices | Classification errors | Section 3.2 |
| Training Curves | Figure | fig:training_curves | Training dynamics | Section 3.3 |
| Inference Time | Table | tab:inference_time | Computational efficiency | Section 3.4 |
| Complexity Analysis | Table | tab:complexity_performance | Model trade-offs | Section 3.5 |

## Error Handling

### Compilation Errors

**Strategy**: Incremental validation during adaptation

1. **Phase 1**: Validate document class and preamble
   - Compile minimal document with MDPI class
   - Verify all packages load correctly
   - Check for package conflicts

2. **Phase 2**: Validate front matter
   - Add title, authors, abstract, keywords
   - Compile and check formatting
   - Verify metadata sections

3. **Phase 3**: Validate main content
   - Add sections incrementally
   - Compile after each major section
   - Check cross-references

4. **Phase 4**: Validate figures and tables
   - Add visual elements one at a time
   - Verify paths and labels
   - Check formatting

5. **Phase 5**: Validate bibliography
   - Add references
   - Check citation resolution
   - Verify bibliography formatting

### Content Validation

**Missing Content Check**:
- Compare section headings between ASCE and MDPI versions
- Verify all figures are referenced
- Confirm all tables are included
- Check all citations resolve

**Formatting Validation**:
- Verify page count is within limits
- Check figure/table placement
- Validate equation formatting
- Confirm reference style compliance

### Recovery Strategies

**If compilation fails**:
1. Identify error location from log file
2. Comment out problematic section
3. Compile remaining document
4. Fix error incrementally
5. Uncomment and recompile

**If page limit exceeded**:
1. Identify longest sections
2. Apply condensation strategies
3. Optimize figure sizes
4. Recompile and measure
5. Iterate until within limits

## Testing Strategy

### Unit Testing

**Test 1: Document Class**
- Input: MDPI document class declaration
- Expected: Successful compilation with MDPI class
- Validation: Check PDF header shows MDPI format

**Test 2: Front Matter**
- Input: Title, authors, abstract, keywords
- Expected: Proper formatting per MDPI guidelines
- Validation: Visual inspection of first page

**Test 3: Sections**
- Input: Each main section
- Expected: Proper numbering and formatting
- Validation: Check section hierarchy

**Test 4: Figures**
- Input: Each figure
- Expected: Correct display and referencing
- Validation: Check figure numbers and captions

**Test 5: Tables**
- Input: Each table
- Expected: Proper formatting and alignment
- Validation: Check table layout and readability

**Test 6: Bibliography**
- Input: All citations
- Expected: Correct numbering and formatting
- Validation: Check reference list completeness

### Integration Testing

**Test 1: Complete Document Compilation**
- Compile full document from start to finish
- Verify no errors or warnings
- Check PDF output quality

**Test 2: Cross-Reference Validation**
- Verify all `\ref` commands resolve correctly
- Check figure/table numbering consistency
- Validate citation numbers

**Test 3: Page Count Validation**
- Measure total page count
- Verify within MDPI limits (20-25 pages)
- Check page layout and margins

### Acceptance Testing

**Test 1: Content Completeness**
- Compare ASCE and MDPI versions section by section
- Verify all scientific content preserved
- Check no data or results lost

**Test 2: Format Compliance**
- Review against MDPI author guidelines
- Check all required sections present
- Verify formatting matches MDPI standards

**Test 3: Visual Quality**
- Inspect all figures for clarity
- Check table readability
- Verify equation formatting

**Test 4: Reference Accuracy**
- Verify all citations in text appear in bibliography
- Check no orphaned references
- Validate reference formatting

## Journal Selection Rationale

### Candidate MDPI Journals

1. **Applied Sciences** (`applsci`)
   - Scope: Broad coverage of applied sciences and engineering
   - Relevance: Covers computer vision, deep learning, civil engineering
   - Impact Factor: 2.7 (2023)
   - **Recommendation**: Primary choice - best fit for interdisciplinary work

2. **Sensors** (`sensors`)
   - Scope: Sensor technology and applications
   - Relevance: Covers image sensors, computer vision, structural monitoring
   - Impact Factor: 3.9 (2023)
   - **Recommendation**: Alternative if focusing on sensing aspects

3. **Buildings** (`buildings`)
   - Scope: Building science and construction
   - Relevance: Covers structural health monitoring, building maintenance
   - Impact Factor: 3.8 (2023)
   - **Recommendation**: Good fit if emphasizing building applications

4. **Infrastructures** (`infrastructures`)
   - Scope: Infrastructure engineering and management
   - Relevance: Covers bridge inspection, infrastructure monitoring
   - Impact Factor: 2.7 (2023)
   - **Recommendation**: Excellent fit for infrastructure focus

### Selected Journal: Applied Sciences

**Rationale**:
- Broadest scope accommodates interdisciplinary nature (AI + civil engineering)
- Accepts papers on deep learning applications
- Covers structural engineering and inspection
- Reasonable impact factor and publication timeline
- Large readership across multiple disciplines

**Configuration**:
```latex
\documentclass[applsci,article,submit,pdftex,moreauthors]{Definitions/mdpi}
```

## Implementation Phases

### Phase 1: Setup and Template Preparation (Requirements 1, 7)
- Create new file: `artigo_mdpi_classification.tex`
- Set up MDPI document class with Applied Sciences journal
- Configure preamble with compatible packages
- Set up file paths and basic structure

### Phase 2: Front Matter Adaptation (Requirements 1, 5)
- Convert title and author information
- Adapt abstract to 200-word structured format
- Format keywords with semicolons
- Add all required metadata sections

### Phase 3: Main Content Migration (Requirements 2, 6)
- Copy Introduction section with minor condensation
- Migrate Materials and Methods section
- Transfer Results section with all data
- Copy Discussion section with optimization
- Transfer Conclusions section

### Phase 4: Visual Elements Adaptation (Requirement 3)
- Adapt all figures to MDPI format
- Convert all tables to MDPI style
- Update all cross-references
- Verify figure/table placement

### Phase 5: Bibliography Conversion (Requirement 4)
- Adapt bibliography style to MDPI format
- Verify all citations resolve
- Check reference formatting
- Validate bibliography completeness

### Phase 6: Optimization and Validation (Requirements 6, 8)
- Compile complete document
- Measure page count
- Apply length optimization if needed
- Perform final validation checks
- Generate final PDF

## Success Criteria

1. **Compilation Success**: Document compiles without errors using pdfLaTeX
2. **Format Compliance**: All MDPI formatting requirements met
3. **Content Preservation**: All scientific content from ASCE version preserved
4. **Page Limit**: Final document within 20-25 pages
5. **Visual Quality**: All figures and tables display correctly and are readable
6. **Reference Completeness**: All citations resolve and bibliography is complete
7. **Metadata Completeness**: All required MDPI sections present and properly formatted
8. **Cross-Reference Integrity**: All internal references (figures, tables, sections, equations) resolve correctly
