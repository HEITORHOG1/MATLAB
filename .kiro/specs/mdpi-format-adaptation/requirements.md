# Requirements Document

## Introduction

This specification defines the requirements for adapting the existing corrosion classification article from ASCE format to MDPI journal format. The article "Deep Learning-Based Corrosion Severity Classification for ASTM A572 Grade 50 Steel Structures: A Transfer Learning Approach" needs to be reformatted to comply with MDPI submission guidelines while maintaining scientific rigor and staying within page limits.

## Glossary

- **ASCE**: American Society of Civil Engineers - the current format of the article
- **MDPI**: Multidisciplinary Digital Publishing Institute - the target journal format
- **LaTeX**: Document preparation system used for scientific publishing
- **Transfer Learning**: Machine learning technique using pre-trained models
- **Article System**: The complete LaTeX document including text, figures, tables, and references
- **Page Limit**: Maximum number of pages allowed by the journal (typically 20-25 pages for MDPI)
- **Template Compliance**: Adherence to MDPI's specific formatting requirements

## Requirements

### Requirement 1: Document Structure Adaptation

**User Story:** As a researcher, I want to adapt my ASCE-formatted article to MDPI format, so that I can submit it to an MDPI journal while maintaining all scientific content.

#### Acceptance Criteria

1. WHEN the Article System processes the ASCE document, THE Article System SHALL convert the document class from `ascelike-new` to MDPI's `mdpi` class
2. WHEN the Article System adapts the preamble, THE Article System SHALL replace ASCE-specific packages with MDPI-compatible packages while preserving functionality
3. WHEN the Article System formats the title and authors, THE Article System SHALL use MDPI's `\Title`, `\Author`, and `\address` commands instead of ASCE's format
4. WHEN the Article System processes the abstract, THE Article System SHALL format it as a single paragraph of approximately 200 words following MDPI's structured abstract guidelines (Background, Methods, Results, Conclusions)
5. WHEN the Article System handles keywords, THE Article System SHALL use MDPI's `\keyword` command with semicolon-separated keywords (3-10 keywords)

### Requirement 2: Content Organization and Section Structure

**User Story:** As a researcher, I want the article sections to follow MDPI's structure, so that reviewers can easily navigate the content according to journal standards.

#### Acceptance Criteria

1. WHEN the Article System organizes sections, THE Article System SHALL maintain the sequence: Introduction, Materials and Methods, Results, Discussion, Conclusions
2. WHEN the Article System processes subsections, THE Article System SHALL use MDPI's subsection and subsubsection formatting with appropriate numbering
3. WHEN the Article System handles the methodology section, THE Article System SHALL title it "Materials and Methods" per MDPI guidelines
4. WHEN the Article System processes figures and tables, THE Article System SHALL place them in the main text near their first citation using MDPI's figure and table environments
5. WHEN the Article System formats equations, THE Article System SHALL use MDPI's `linenomath` environment for proper line numbering in submit mode

### Requirement 3: Figures and Tables Formatting

**User Story:** As a researcher, I want all figures and tables properly formatted for MDPI, so that they meet journal specifications and display correctly.

#### Acceptance Criteria

1. WHEN the Article System processes figures, THE Article System SHALL use MDPI's figure environment with `\caption` and `\label` commands
2. WHEN the Article System handles figure paths, THE Article System SHALL update `\graphicspath` to point to `figuras_pure_classification/` directory
3. WHEN the Article System formats tables, THE Article System SHALL use `tabularx` environment with MDPI's column specifications
4. WHEN the Article System processes multi-panel figures, THE Article System SHALL use `\subfloat` command with proper panel labeling (a), (b), (c), etc.
5. WHEN the Article System handles wide figures or tables, THE Article System SHALL use `adjustwidth` environment for content spanning full page width

### Requirement 4: Bibliography and Citations

**User Story:** As a researcher, I want citations and references formatted according to MDPI standards, so that the bibliography complies with journal requirements.

#### Acceptance Criteria

1. WHEN the Article System processes citations, THE Article System SHALL use numeric citation style with `\cite` command
2. WHEN the Article System formats the bibliography, THE Article System SHALL use `\begin{thebibliography}` environment or external BibTeX file
3. WHEN the Article System handles reference entries, THE Article System SHALL format them according to MDPI's reference style guidelines
4. WHEN the Article System processes the bibliography file, THE Article System SHALL ensure `referencias_pure_classification.bib` is compatible with MDPI's citation style
5. WHEN the Article System validates references, THE Article System SHALL ensure all cited works appear in the reference list and vice versa

### Requirement 5: Metadata and Supplementary Sections

**User Story:** As a researcher, I want all required MDPI metadata sections included, so that the submission is complete and meets journal requirements.

#### Acceptance Criteria

1. WHEN the Article System adds metadata, THE Article System SHALL include `\authorcontributions` section with CRediT taxonomy statements
2. WHEN the Article System processes funding information, THE Article System SHALL include `\funding` section with appropriate funding statement
3. WHEN the Article System handles ethical compliance, THE Article System SHALL include `\institutionalreview` section with appropriate statement
4. WHEN the Article System adds data availability, THE Article System SHALL include `\dataavailability` section describing data access
5. WHEN the Article System processes conflicts of interest, THE Article System SHALL include `\conflictsofinterest` section with appropriate declaration

### Requirement 6: Page Length Optimization

**User Story:** As a researcher, I want the article to fit within MDPI's page limits, so that it meets submission requirements without losing essential content.

#### Acceptance Criteria

1. WHEN the Article System compiles the document, THE Article System SHALL produce a PDF with page count within MDPI's limits (typically 20-25 pages)
2. WHEN the Article System optimizes content, THE Article System SHALL preserve all key scientific findings and methodology details
3. WHEN the Article System reduces length, THE Article System SHALL condense verbose sections while maintaining clarity
4. WHEN the Article System handles figures, THE Article System SHALL optimize figure sizes to balance readability and space efficiency
5. WHEN the Article System processes tables, THE Article System SHALL use compact formatting where appropriate without sacrificing readability

### Requirement 7: Journal Selection and Configuration

**User Story:** As a researcher, I want to select an appropriate MDPI journal for submission, so that the article is formatted for the correct publication venue.

#### Acceptance Criteria

1. WHEN the Article System configures the document class, THE Article System SHALL specify an appropriate MDPI journal from the available options (e.g., `applsci`, `sensors`, `buildings`, `infrastructures`)
2. WHEN the Article System sets document options, THE Article System SHALL use `[journal,article,submit,pdftex,moreauthors]` class options
3. WHEN the Article System processes journal-specific requirements, THE Article System SHALL include any special sections required by the selected journal
4. WHEN the Article System validates configuration, THE Article System SHALL ensure all journal-specific formatting is correctly applied
5. WHEN the Article System generates the final document, THE Article System SHALL produce output compatible with the selected MDPI journal's submission system

### Requirement 8: Quality Assurance and Validation

**User Story:** As a researcher, I want the adapted article validated for completeness and correctness, so that I can confidently submit it to the journal.

#### Acceptance Criteria

1. WHEN the Article System validates the document, THE Article System SHALL compile without errors using pdfLaTeX
2. WHEN the Article System checks content, THE Article System SHALL verify all sections from the original article are present
3. WHEN the Article System validates figures, THE Article System SHALL confirm all figures are referenced and display correctly
4. WHEN the Article System checks tables, THE Article System SHALL verify all tables are properly formatted and referenced
5. WHEN the Article System validates references, THE Article System SHALL ensure all citations resolve correctly and bibliography is complete
