# Implementation Plan

## Task Overview

This implementation plan provides a step-by-step guide for adapting the corrosion classification article from ASCE format to MDPI format. Each task builds incrementally on previous tasks, ensuring a systematic and validated approach.

- [x] 1. Setup MDPI document structure and template configuration




  - Create new LaTeX file `artigo_mdpi_classification.tex` with MDPI document class
  - Configure document class for Applied Sciences journal with appropriate options
  - Set up preamble with MDPI-compatible packages (remove ASCE-specific packages)
  - Configure graphics path to `figuras_pure_classification/` directory
  - Add MDPI internal commands (firstpage, pubvolume, issuenum, etc.)
  - _Requirements: 1.1, 1.2, 7.1, 7.2_

- [x] 2. Implement front matter and metadata sections




  - [x] 2.1 Convert title and author information to MDPI format

    - Use `\Title{}` command for article title
    - Format authors with `\Author{}` command including affiliations
    - Add author affiliations with `\address{}` command
    - Include correspondence information with `\corres{}` command
    - _Requirements: 1.3, 5.1_
  
  - [x] 2.2 Adapt abstract to MDPI structured format


    - Condense abstract from ~300 words to ~200 words
    - Structure abstract with Background, Methods, Results, Conclusions (without headings)
    - Use `\abstract{}` command
    - Ensure single paragraph format without line breaks
    - _Requirements: 1.4, 6.2_
  
  - [x] 2.3 Format keywords for MDPI

    - Convert keywords to semicolon-separated format
    - Use `\keyword{}` command
    - Ensure 3-10 keywords included
    - _Requirements: 1.5_
  
  - [x] 2.4 Add required MDPI metadata sections


    - Add `\authorcontributions{}` section with CRediT taxonomy
    - Add `\funding{}` section (no external funding statement)
    - Add `\institutionalreview{}` section (not applicable statement)
    - Add `\informedconsent{}` section (not applicable statement)
    - Add `\dataavailability{}` section with GitHub link and data access info
    - Add `\conflictsofinterest{}` section (no conflicts declaration)
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 3. Migrate main content sections with MDPI formatting





  - [x] 3.1 Adapt Introduction section


    - Copy Introduction content from ASCE version
    - Condense from ~1200 words to ~900 words (remove redundancy in literature review)
    - Ensure proper section formatting with `\section{Introduction}`
    - Maintain all key citations and scientific context
    - Verify all `\cite{}` commands are present
    - _Requirements: 2.1, 2.2, 6.2_
  
  - [x] 3.2 Convert Methodology to Materials and Methods


    - Rename section to "Materials and Methods" per MDPI guidelines
    - Copy all subsections: Dataset Description, Model Architectures, Training Configuration, Evaluation Metrics
    - Maintain all technical details and parameters
    - Ensure proper subsection formatting with `\subsection{}` and `\subsubsection{}`
    - Keep all mathematical equations with proper MDPI formatting
    - _Requirements: 2.1, 2.3_
  
  - [x] 3.3 Transfer Results section


    - Copy all Results subsections with complete data
    - Maintain subsection structure: Overall Performance, Confusion Matrix Analysis, Training Dynamics, Inference Time Analysis, Complexity Analysis
    - Ensure all quantitative results are preserved
    - Condense descriptive text where possible without losing clarity
    - _Requirements: 2.1, 6.3_
  
  - [x] 3.4 Adapt Discussion section


    - Copy Discussion content with all subsections
    - Condense from ~2000 words to ~1500 words (merge related points, remove redundancy)
    - Maintain key arguments: Transfer Learning Effectiveness, Architecture Comparison, Practical Applications, Deployment Considerations, Limitations, Future Work
    - Preserve all scientific interpretations and implications
    - _Requirements: 2.1, 6.2_
  
  - [x] 3.5 Transfer Conclusions section


    - Copy Conclusions content
    - Maintain all key findings and recommendations
    - Ensure proper formatting
    - _Requirements: 2.1_

- [x] 4. Adapt all figures to MDPI format




  - [x] 4.1 Convert Figure 1 (Sample Images)


    - Change figure environment to MDPI format with `[H]` placement
    - Update `\includegraphics` command with appropriate width
    - Ensure caption and label are properly formatted
    - Verify figure path resolves correctly
    - _Requirements: 2.4, 3.1, 3.2_
  
  - [x] 4.2 Convert Figure 2 (Confusion Matrices)


    - Adapt multi-panel figure to MDPI format
    - Use `\subfloat` for panel labeling if needed
    - Ensure proper width for readability
    - Verify caption describes all panels
    - _Requirements: 2.4, 3.1, 3.4_
  
  - [x] 4.3 Convert Figure 3 (Training Curves)


    - Adapt figure to MDPI format
    - Optimize figure width for space efficiency
    - Ensure caption is descriptive
    - Verify label and cross-references
    - _Requirements: 2.4, 3.1_
  
  - [x] 4.4 Verify all figure cross-references


    - Check all `\ref{fig:...}` commands resolve correctly
    - Ensure figures are cited in text near first reference
    - Verify figure numbering is sequential
    - _Requirements: 2.4, 3.1_

- [x] 5. Adapt all tables to MDPI format





  - [x] 5.1 Convert Table 1 (Dataset Statistics)


    - Change table environment to MDPI format with `[H]` placement
    - Use `tabularx` environment with MDPI column specifications
    - Ensure caption is above table per MDPI guidelines
    - Verify label and formatting
    - _Requirements: 2.4, 3.3_
  
  - [x] 5.2 Convert Table 2 (Model Architectures)

    - Adapt table to MDPI `tabularx` format
    - Ensure proper column alignment
    - Verify all data is preserved
    - Check caption and label
    - _Requirements: 2.4, 3.3_
  
  - [x] 5.3 Convert Table 3 (Training Configuration)

    - Adapt table to MDPI format
    - Use compact formatting if needed for space
    - Ensure readability is maintained
    - Verify all parameters are included
    - _Requirements: 2.4, 3.3_
  
  - [x] 5.4 Convert Table 4 (Performance Metrics)

    - Adapt table to MDPI format
    - Ensure confidence intervals are properly formatted
    - Verify all model results are included
    - Check caption and label
    - _Requirements: 2.4, 3.3_
  
  - [x] 5.5 Convert Table 5 (Inference Time)

    - Adapt table to MDPI format
    - Ensure all timing data is preserved
    - Verify column alignment
    - Check caption and label
    - _Requirements: 2.4, 3.3_
  
  - [x] 5.6 Convert Table 6 (Complexity Analysis)

    - Adapt table to MDPI format
    - Ensure all metrics are included
    - Verify calculations are correct
    - Check caption and label
    - _Requirements: 2.4, 3.3_
  
  - [x] 5.7 Verify all table cross-references

    - Check all `\ref{tab:...}` commands resolve correctly
    - Ensure tables are cited in text near first reference
    - Verify table numbering is sequential
    - _Requirements: 2.4, 3.3_

- [x] 6. Convert bibliography to MDPI format






  - [x] 6.1 Adapt bibliography style

    - Configure bibliography to use MDPI citation style
    - Use `\bibliographystyle{...}` with MDPI-compatible style or internal bibliography
    - Ensure numeric citation format
    - _Requirements: 4.1, 4.2_
  
  - [x] 6.2 Verify bibliography file compatibility


    - Check `referencias_pure_classification.bib` works with MDPI format
    - Verify all reference entries follow MDPI format guidelines
    - Ensure journal abbreviations are correct
    - _Requirements: 4.3, 4.4_
  

  - [x] 6.3 Validate all citations

    - Compile document and check all citations resolve
    - Verify no undefined references
    - Ensure all cited works appear in bibliography
    - Check no orphaned references in bibliography
    - _Requirements: 4.5_

- [x] 7. Optimize document length for MDPI page limits




  - [x] 7.1 Compile and measure initial page count


    - Compile complete document with pdfLaTeX
    - Count total pages in output PDF
    - Identify sections that need condensation if over 25 pages
    - _Requirements: 6.1_
  
  - [x] 7.2 Apply length optimization strategies if needed


    - Condense verbose sections while preserving scientific content
    - Optimize figure sizes (reduce width from 0.95 to 0.85 textwidth if needed)
    - Use more compact table formatting where appropriate
    - Remove any redundant text or repetitive statements
    - _Requirements: 6.2, 6.3, 6.4, 6.5_
  
  - [x] 7.3 Verify page count is within limits


    - Recompile after optimizations
    - Confirm final page count is 20-25 pages
    - Ensure all content remains clear and readable
    - _Requirements: 6.1_

- [x] 8. Perform comprehensive validation and quality assurance





  - [x] 8.1 Validate document compilation


    - Compile document with pdfLaTeX without errors
    - Check log file for warnings
    - Verify PDF output is generated correctly
    - _Requirements: 8.1_
  
  - [x] 8.2 Verify content completeness


    - Compare MDPI version against ASCE version section by section
    - Ensure all scientific content is preserved
    - Check no data, results, or findings are missing
    - Verify all methodology details are included
    - _Requirements: 8.2_
  
  - [x] 8.3 Validate all visual elements


    - Check all figures display correctly in PDF
    - Verify all figures are referenced in text
    - Ensure all tables are properly formatted
    - Confirm all tables are referenced in text
    - _Requirements: 8.3, 8.4_
  
  - [x] 8.4 Validate all cross-references


    - Check all section references resolve correctly
    - Verify all figure references resolve correctly
    - Confirm all table references resolve correctly
    - Ensure all equation references resolve correctly
    - _Requirements: 8.5_
  
  - [x] 8.5 Perform final format compliance check


    - Review document against MDPI author guidelines
    - Verify all required metadata sections are present
    - Check title, authors, affiliations formatting
    - Confirm abstract is structured and within word limit
    - Verify keywords are properly formatted
    - Check bibliography follows MDPI style
    - _Requirements: 7.3, 7.4, 7.5_
  
  - [x] 8.6 Generate final submission-ready PDF


    - Compile final version with all corrections
    - Generate high-quality PDF output
    - Verify PDF metadata (title, authors, keywords)
    - Create backup copy of final LaTeX source
    - _Requirements: 8.1_

## Notes

- Each task should be completed and validated before proceeding to the next
- Compile the document frequently during implementation to catch errors early
- Keep the original ASCE version (`artigo_pure_classification.tex`) as reference
- Test figure and table rendering after each adaptation
- Maintain a compilation log to track any warnings or issues
- Use version control or backups to preserve working versions

## Estimated Effort

- Task 1 (Setup): 30 minutes
- Task 2 (Front Matter): 1 hour
- Task 3 (Main Content): 2-3 hours
- Task 4 (Figures): 1 hour
- Task 5 (Tables): 1.5 hours
- Task 6 (Bibliography): 30 minutes
- Task 7 (Optimization): 1-2 hours
- Task 8 (Validation): 1 hour

**Total Estimated Time**: 8-11 hours

## Success Criteria

✓ Document compiles without errors
✓ All MDPI formatting requirements met
✓ All scientific content preserved
✓ Page count within 20-25 pages
✓ All figures and tables display correctly
✓ All cross-references resolve
✓ Bibliography complete and properly formatted
✓ All required metadata sections present

---

## Phase 2: Critical Issues and Quality Improvements

Based on detailed review, the following critical issues and improvements need to be addressed before submission:

- [x] 9. Fix critical data accuracy issues






  - [x] 9.1 Regenerate confusion matrix figures with correct accuracy values

    - Current Figure 2 shows incorrect accuracy values (39.4%, 48.5%, 54.5%)
    - Must display correct values: ResNet50 (94.2%), EfficientNet-B0 (91.9%), Custom CNN (85.5%)
    - Verify confusion matrix patterns match the text descriptions
    - Ensure normalized values are displayed correctly
    - _Requirements: 8.3, CRITICAL_

  - [x] 9.2 Verify all numerical data consistency


    - Cross-check all accuracy values in text, tables, and figures
    - Verify confusion matrix percentages match class-specific accuracies
    - Ensure training/validation splits are consistent throughout
    - _Requirements: 8.2, CRITICAL_

- [x] 10. Expand methodology section for reproducibility





  - [x] 10.1 Add detailed data augmentation justification


    - Explain why each of the 6 augmentation techniques was chosen
    - Add brief rationale for augmentation parameters
    - Maintain conciseness while improving clarity
    - _Requirements: 2.3, IMPORTANT_

  - [x] 10.2 Restore class weighting formula and explanation


    - Add formula: w_c = N/(C·n_c) where N=414, C=3, n_c=samples in class c
    - Explain purpose: ensures equal attention to minority classes
    - Add one sentence about impact on training
    - _Requirements: 2.3, IMPORTANT_

  - [x] 10.3 Clarify early stopping criteria


    - Specify patience parameter (10 epochs)
    - Explain monitoring metric (validation loss)
    - Describe restoration of best weights
    - _Requirements: 2.3, IMPORTANT_

- [x] 11. Enhance results analysis and discussion





  - [x] 11.1 Add class-specific error pattern analysis


    - Discuss why Class 2 (severe) has more errors
    - Explain importance of adjacent-class errors only
    - Highlight that no Class 0→Class 2 misclassifications occur
    - Contextualize 30% threshold ambiguity
    - _Requirements: 2.1, 6.3, RECOMMENDED_

  - [x] 11.2 Add context to Table 6 (Model Complexity)


    - Explain "Acc/M params" metric meaning
    - Highlight EfficientNet-B0's 5x better parameter efficiency
    - Connect to compound scaling and mobile inverted bottleneck design
    - Provide deployment recommendation based on metrics
    - _Requirements: 3.3, RECOMMENDED_

- [x] 12. Expand limitations section for scientific rigor






  - [x] 12.1 Add steel type specificity limitation


    - Note training exclusively on ASTM A572 Grade 50
    - Discuss generalization concerns for other steel types
    - Mention different corrosion morphologies
    - _Requirements: 2.1, IMPORTANT_

  - [x] 12.2 Add dataset size limitation discussion

    - Acknowledge 414 images is sufficient for transfer learning demo
    - Note Class 2 (severe) has only 57 images
    - Discuss potential impact on model exposure to diverse severe corrosion
    - _Requirements: 2.1, IMPORTANT_

  - [x] 12.3 Add spatial localization limitation

    - Explain system provides image-level classification only
    - Note lack of pixel-level or region-level localization
    - Discuss impact on detailed maintenance planning
    - _Requirements: 2.1, IMPORTANT_

- [x] 13. Add code and data availability section




  - [x] 13.1 Create comprehensive data availability statement


    - Add GitHub repository link for code and model weights
    - Specify software versions (Python 3.12, TensorFlow 2.20.0, etc.)
    - Note random seed (42) for reproducibility
    - Explain dataset access restrictions and request process
    - _Requirements: 5.5, IMPORTANT_

  - [x] 13.2 Verify reproducibility information completeness


    - Ensure all hyperparameters are documented
    - Verify hardware specifications are mentioned
    - Check that all dependencies are listed
    - _Requirements: 5.5, IMPORTANT_

- [x] 14. Final pre-submission validation







  - [x] 14.1 Verify all critical fixes are applied

    - Confirm Figure 2 has correct accuracy values
    - Verify methodology section has sufficient detail
    - Check limitations section is comprehensive
    - Ensure data availability section is complete
    - _Requirements: 8.1, 8.2, CRITICAL_


  - [x] 14.2 Perform final consistency check

    - Verify all numbers match across text, tables, and figures
    - Check all cross-references resolve correctly
    - Ensure no contradictions between sections
    - Validate all citations are properly formatted
    - _Requirements: 8.5, CRITICAL_

  - [x] 14.3 Generate final submission package


    - Compile final PDF with all corrections
    - Create submission checklist document
    - Prepare cover letter highlighting key contributions
    - Package all supplementary materials
    - _Requirements: 8.6, IMPORTANT_

## Priority Levels

- **CRITICAL**: Must be fixed before submission (blocks acceptance)
- **IMPORTANT**: Should be fixed before submission (improves quality significantly)
- **RECOMMENDED**: Nice to have (enhances paper but not blocking)

## Phase 2 Estimated Effort

- Task 9 (Critical Data Fixes): 2-3 hours (requires regenerating figures)
- Task 10 (Methodology Expansion): 1-2 hours
- Task 11 (Results Enhancement): 1 hour
- Task 12 (Limitations Expansion): 1 hour
- Task 13 (Data Availability): 30 minutes
- Task 14 (Final Validation): 1 hour

**Total Phase 2 Estimated Time**: 6.5-9.5 hours

## Updated Success Criteria

✓ All critical data accuracy issues resolved
✓ Methodology section provides sufficient reproducibility details
✓ Limitations section demonstrates scientific rigor
✓ Data and code availability clearly documented
✓ All numerical values consistent across document
✓ Results analysis provides adequate depth
✓ Document ready for journal submission
