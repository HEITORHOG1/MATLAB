# Design Document

## Overview

This design document outlines the comprehensive approach for converting the scientific article from ASCE format (artigo_pure_classification.tex) to Elsevier format. The conversion will create a new file (artigo_elsevier_classification.tex) that maintains all scientific content while adapting to Elsevier's elsarticle document class structure, formatting requirements, and submission guidelines.

The design follows a systematic approach: (1) analyze the source document structure and content, (2) map ASCE elements to Elsevier equivalents, (3) create the new document with proper frontmatter, (4) transfer and adapt all content sections, (5) configure bibliography and citations, (6) optimize for page limits, and (7) validate compilation and formatting.

## Architecture

### Document Structure Mapping

The conversion follows a clear mapping from ASCE to Elsevier structure:

**ASCE Structure:**
```
\documentclass[Journal,letterpaper,InsideFigs]{ascelike-new}
\title{...}
\author[1]{...}
\maketitle
\begin{abstract}...\end{abstract}
[Main content sections]
\bibliographystyle{ascelike-new}
```

**Elsevier Structure:**
```
\documentclass[preprint,12pt]{elsarticle}
\begin{frontmatter}
  \title{...}
  \author{...}
  \affiliation{...}
  \begin{abstract}...\end{abstract}
  \begin{highlights}...\end{highlights}
  \begin{keyword}...\end{keyword}
\end{frontmatter}
[Main content sections]
\bibliographystyle{elsarticle-num}
```

## Components and Interfaces

### Component 1: Document Class Configuration

Set up the Elsevier document class with appropriate options for journal submission.

**Implementation:**
```latex
\documentclass[preprint,12pt]{elsarticle}
```

**Package Imports:**
- inputenc, fontenc, babel for text encoding
- graphicx for figures
- amsmath, amssymb for mathematics
- siunitx for units
- booktabs, array, multirow for tables
- hyperref for links

### Component 2: Frontmatter Section

Configure article metadata including title, authors, affiliations, abstract, highlights, and keywords.

**Author Configuration:**
```latex
\author[ucp]{Heitor Oliveira Gon\c{c}alves\corref{cor1}}
\ead{heitorhog@gmail.com}
\author[ucp]{Darlan Porto}
[... other authors ...]

\affiliation[ucp]{organization={Catholic University of Petr\'opolis},
                  city={Petr\'opolis},
                  state={Rio de Janeiro},
                  country={Brazil}}
```

**Research Highlights (3-5 items):**
1. Transfer learning achieves 94.2% accuracy with limited data
2. EfficientNet-B0 provides optimal accuracy-efficiency balance
3. Conservative adjacent-class errors avoid critical misclassifications
4. Rapid inference enables real-time field deployment
5. System reduces inspection costs by 40-50%

### Component 3: Main Content Sections

Transfer all scientific content maintaining section hierarchy:
1. Introduction
2. Methodology (with subsections)
3. Results (with subsections)
4. Discussion (with subsections)
5. Conclusions

### Component 4: Figures and Tables

Configure graphics path and adapt all visual elements:
```latex
\graphicspath{{figuras_pure_classification/}}
```

Figures to transfer:
- figura_sample_images.pdf
- figura_confusion_matrices.pdf
- figura_training_curves.pdf

Tables to transfer (6 tables total)

### Component 5: Bibliography System

Configure numerical citation system:
```latex
\bibliographystyle{elsarticle-num}
\bibliography{referencias_pure_classification}
```

## Data Models

### Document Metadata
- Title, authors, affiliations
- Abstract (350-400 words)
- Highlights (3-5 items)
- Keywords (8-10 items)

### Content Structure
- Sections with hierarchy
- Figures and tables with references
- Equations with numbering
- Citations with numerical format

## Error Handling

### Compilation Errors
- Progressive compilation testing
- Incremental content addition
- Package conflict resolution

### Reference Resolution
- Citation validation
- Cross-reference checking
- Hyperlink verification

## Testing Strategy

### Unit Tests
1. Document class configuration
2. Package compatibility
3. Frontmatter formatting
4. Bibliography system

### Integration Tests
5. Complete document compilation
6. Cross-reference integrity
7. Figure and table rendering

### Validation Tests
8. Content completeness
9. Technical accuracy
10. Formatting compliance
11. Page count analysis

## Content Optimization Strategy

If page reduction needed:
- Preserve core scientific content
- Condense supporting content
- Move details to supplementary materials

Optimization techniques:
- Reduce introduction length
- Streamline methodology descriptions
- Condense discussion sections
- Focus on key findings

## Compilation Workflow

Standard sequence:
1. pdflatex (initial)
2. bibtex (bibliography)
3. pdflatex (resolve citations)
4. pdflatex (resolve cross-references)

## Success Criteria

1. Document compiles without errors
2. All content transferred completely
3. Technical accuracy maintained
4. Elsevier formatting followed
5. All references resolve correctly
6. Visual elements display properly
7. Page count within limits
8. Metadata complete
9. Submission requirements met
10. Professional quality achieved
