# Design Document: ASCE Page Reduction System

## Overview

This design document outlines a systematic approach to reducing the classification paper (artigo_classificacao_corrosao.tex) to meet ASCE's 30-page manuscript limit. The system will analyze the current document, identify reduction opportunities, and implement targeted content condensation while preserving scientific integrity and key findings.

The design follows a multi-pass iterative approach where each pass focuses on specific reduction strategies, compiles the document to check page count, and allows user review before proceeding. This ensures controlled, quality-preserving reduction rather than aggressive cutting that might compromise the paper's scientific value.

## Architecture

### System Components

The page reduction system consists of four main components:

1. **Page Count Analyzer**: Compiles the LaTeX document and extracts page count information
2. **Content Analyzer**: Identifies reduction opportunities by analyzing text patterns, section lengths, and redundancy
3. **Content Reducer**: Implements specific reduction strategies on targeted sections
4. **Quality Validator**: Verifies that reduced content maintains scientific integrity and coherence

### Workflow

```
┌─────────────────────┐
│  Compile & Count    │
│  Current Pages      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Analyze Content    │
│  Identify Targets   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Apply Reduction    │
│  Strategy (Pass N)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Compile & Verify   │
│  New Page Count     │
└──────────┬──────────┘
           │
           ▼
    ┌──────────────┐
    │ Under 30     │
    │ pages?       │
    └──┬───────┬───┘
       │ No    │ Yes
       │       │
       │       ▼
       │   ┌─────────────┐
       │   │  Complete   │
       │   └─────────────┘
       │
       └──► Next Pass
```

## Components and Interfaces

### 1. Page Count Analyzer

**Purpose**: Compile the LaTeX document and extract page count information.

**Interface**:
```
Input: LaTeX file path (artigo_classificacao_corrosao.tex)
Output: {
  total_pages: integer,
  pages_over_limit: integer,
  section_page_counts: {
    abstract: float,
    introduction: float,
    methodology: float,
    results: float,
    discussion: float,
    conclusions: float,
    references: float
  }
}
```

**Implementation Strategy**:
- Use pdflatex to compile the document
- Parse the .log file to extract page count
- Use LaTeX \label commands to identify section boundaries
- Calculate approximate page contribution per section

### 2. Content Analyzer

**Purpose**: Analyze document content to identify reduction opportunities.

**Interface**:
```
Input: LaTeX file content
Output: {
  verbose_sections: [section_names],
  redundant_phrases: [{phrase, count, locations}],
  combinable_figures: [[fig1, fig2, ...]],
  optional_content: [{location, type, estimated_space}],
  wordiness_score: float
}
```

**Analysis Strategies**:

1. **Verbosity Detection**:
   - Count words per section
   - Identify sections exceeding typical length for their type
   - Flag paragraphs with high word count but low information density

2. **Redundancy Detection**:
   - Identify repeated phrases or concepts across sections
   - Find similar sentences that convey the same information
   - Detect redundant explanations of the same concept

3. **Figure/Table Analysis**:
   - Identify figures that could be combined into multi-panel layouts
   - Find tables with similar structure that could be merged
   - Detect figures/tables that are not essential to the narrative

4. **Content Classification**:
   - Essential: Core methodology, key results, main conclusions
   - Important: Supporting details, secondary results, context
   - Optional: Extensive background, redundant explanations, minor details

### 3. Content Reducer

**Purpose**: Apply specific reduction strategies to targeted content.

**Reduction Strategies** (applied in order):

#### Pass 1: Low-Hanging Fruit (Target: 2-3 pages)
- Remove redundant phrases and wordy expressions
- Simplify passive voice to active voice
- Condense verbose explanations
- Remove unnecessary adjectives and adverbs
- Combine short paragraphs where appropriate

**Example Transformations**:
- "It is important to note that" → "Note that" or remove entirely
- "In order to" → "To"
- "Due to the fact that" → "Because"
- "A large number of" → "Many"
- "It can be seen that" → "The results show" or remove

#### Pass 2: Introduction Condensation (Target: 1-2 pages)
- Reduce background literature review
- Condense motivation section
- Streamline problem statement
- Shorten research gap discussion
- Tighten objectives and contributions

**Strategy**:
- Keep: Core motivation, specific objectives, key contributions
- Reduce: Extensive background, detailed literature review, redundant context
- Combine: Multiple paragraphs on similar topics

#### Pass 3: Methodology Streamlining (Target: 1-2 pages)
- Condense dataset description
- Streamline architecture descriptions
- Reduce training configuration details
- Simplify evaluation metrics explanations
- Remove redundant mathematical formulations

**Strategy**:
- Keep: Essential methodology for reproducibility, key equations, novel approaches
- Reduce: Standard procedures, well-known techniques, verbose explanations
- Reference: Cite prior work for standard methods instead of explaining

#### Pass 4: Results Condensation (Target: 1-2 pages)
- Condense performance metric discussions
- Streamline confusion matrix analysis
- Reduce training dynamics descriptions
- Tighten inference time analysis
- Condense comparison discussions

**Strategy**:
- Keep: All quantitative results, key findings, statistical significance
- Reduce: Verbose interpretations, redundant observations, obvious conclusions
- Tables/Figures: Let data speak for itself with minimal text

#### Pass 5: Discussion Reduction (Target: 2-3 pages)
- Condense performance interpretation
- Streamline practical applications section
- Reduce method selection guidelines
- Tighten limitations discussion
- Condense future work section

**Strategy**:
- Keep: Key insights, practical implications, important limitations
- Reduce: Redundant interpretations, extensive examples, verbose guidelines
- Focus: Most impactful points, avoid repetition of results

#### Pass 6: Figure/Table Optimization (Target: 1-2 pages)
- Combine related figures into multi-panel layouts
- Merge similar tables
- Reduce figure sizes where appropriate
- Condense captions
- Consider moving secondary figures to supplementary materials

**Candidates for Combination**:
- Training curves (loss + accuracy) → already combined
- Confusion matrices for 3 models → already combined
- Architecture diagrams → could be condensed
- Performance comparison tables → could be merged

#### Pass 7: Reference Optimization (Target: 0.5-1 page)
- Remove non-essential citations
- Combine multiple citations where appropriate
- Ensure all citations are necessary
- Remove redundant references

**Strategy**:
- Keep: Seminal works, direct comparisons, methodology sources
- Reduce: Multiple citations for the same point, tangential references
- Combine: Use "et al." citations where multiple papers support same point

### 4. Quality Validator

**Purpose**: Verify that reduced content maintains scientific quality.

**Validation Checks**:

1. **Completeness Check**:
   - All key findings present
   - All methodology steps described
   - All results reported
   - All major conclusions stated

2. **Coherence Check**:
   - Logical flow maintained
   - Transitions between sections smooth
   - No orphaned references to removed content
   - Consistent terminology

3. **Technical Accuracy Check**:
   - Equations correct
   - Numbers and statistics accurate
   - Citations properly formatted
   - Figures/tables referenced correctly

4. **Compilation Check**:
   - LaTeX compiles without errors
   - All references resolve
   - All figures load correctly
   - Page count under 30

## Data Models

### Document Structure Model
```
Document {
  sections: [
    {
      name: string,
      content: string,
      word_count: integer,
      page_estimate: float,
      subsections: [Subsection]
    }
  ],
  figures: [
    {
      label: string,
      caption: string,
      file: string,
      page_estimate: float
    }
  ],
  tables: [
    {
      label: string,
      caption: string,
      content: string,
      page_estimate: float
    }
  ],
  references: [
    {
      key: string,
      citation_count: integer,
      essential: boolean
    }
  ]
}
```

### Reduction Plan Model
```
ReductionPlan {
  current_pages: integer,
  target_pages: integer,
  passes: [
    {
      pass_number: integer,
      strategy: string,
      target_reduction: float,
      sections_affected: [string],
      estimated_new_page_count: integer
    }
  ]
}
```

## Error Handling

### Compilation Errors
- If LaTeX compilation fails, report error and halt
- Provide clear error message with line number
- Suggest fixes for common errors
- Maintain backup of last working version

### Over-Reduction
- If reduction removes essential content, warn user
- Provide option to restore previous version
- Suggest alternative reduction strategies
- Allow manual review before finalizing

### Under-Reduction
- If page count still exceeds 30 after all passes, report status
- Suggest additional manual reduction areas
- Provide list of remaining verbose sections
- Offer to create supplementary materials document

## Testing Strategy

### Unit Testing
- Test page count extraction from PDF
- Test content analysis functions
- Test individual reduction transformations
- Test validation checks

### Integration Testing
- Test complete reduction workflow
- Test iterative pass execution
- Test backup and restore functionality
- Test compilation after each pass

### Validation Testing
- Verify scientific content preserved
- Verify logical flow maintained
- Verify all figures/tables referenced
- Verify page count under 30

## Implementation Priorities

### Phase 1: Analysis (High Priority)
1. Implement page count analyzer
2. Implement content analyzer
3. Generate reduction plan

### Phase 2: Reduction (High Priority)
1. Implement Pass 1 (low-hanging fruit)
2. Implement Pass 2 (introduction)
3. Implement Pass 3 (methodology)
4. Implement Pass 4 (results)

### Phase 3: Optimization (Medium Priority)
1. Implement Pass 5 (discussion)
2. Implement Pass 6 (figures/tables)
3. Implement Pass 7 (references)

### Phase 4: Validation (High Priority)
1. Implement quality validator
2. Implement compilation checker
3. Generate change report

## Success Criteria

The page reduction system is successful when:

1. **Page Count**: Final document is ≤30 pages
2. **Content Preservation**: All key findings, methodology, and conclusions preserved
3. **Quality**: Paper maintains scientific rigor and logical coherence
4. **Compilation**: Document compiles without errors
5. **Readability**: Paper remains clear and well-structured

## Specific Reduction Targets for Classification Paper

Based on analysis of the current paper structure:

### Current Estimated Page Distribution
- Abstract: ~1 page
- Introduction: ~4 pages → **Target: 3 pages** (reduce by 1)
- Methodology: ~4 pages → **Target: 3 pages** (reduce by 1)
- Results: ~5 pages → **Target: 4 pages** (reduce by 1)
- Discussion: ~6 pages → **Target: 4 pages** (reduce by 2)
- Conclusions: ~2 pages → **Target: 1.5 pages** (reduce by 0.5)
- References: ~2 pages → **Target: 1.5 pages** (reduce by 0.5)
- Figures/Tables: ~8 pages → **Target: 6 pages** (reduce by 2)

**Total Estimated Reduction: 9 pages**

This provides buffer to ensure we stay well under the 30-page limit.

### Priority Reduction Areas

1. **Discussion Section** (highest priority): Currently most verbose, can be condensed significantly
   - Reduce practical applications subsection
   - Condense method selection guidelines
   - Streamline limitations discussion
   - Tighten future work section

2. **Introduction** (high priority): Extensive background can be condensed
   - Reduce literature review
   - Condense motivation
   - Streamline problem statement

3. **Results** (medium priority): Some descriptive text can be reduced
   - Let tables/figures speak more
   - Reduce redundant observations
   - Condense interpretations

4. **Methodology** (medium priority): Some details can be streamlined
   - Reference standard procedures
   - Condense architecture descriptions
   - Reduce training configuration details

5. **Figures/Tables** (medium priority): Optimize layout
   - Reduce figure sizes slightly
   - Condense captions
   - Consider combining related content

## Backup Strategy

Before any reduction:
1. Create backup: `artigo_classificacao_corrosao_original_backup.tex`
2. Create version control: `artigo_classificacao_corrosao_v1.tex`, `v2.tex`, etc.
3. Document all changes in a change log
4. Allow easy restoration of previous versions

## User Interaction Points

The system will pause for user review at:
1. After initial analysis and reduction plan generation
2. After each reduction pass (show page count and changes)
3. Before finalizing (show final page count and summary)
4. If any quality concerns detected

This ensures the user maintains control over the reduction process and can verify quality at each step.
