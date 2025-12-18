# Implementation Plan

- [x] 1. Create ASCE document base structure


  - Create new LaTeX file with ascelike-new.cls document class
  - Configure Journal option and letterpaper format
  - Set up proper encoding (UTF-8) and language (English)
  - Add NameTag command for author identification
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_


- [x] 2. Configure ASCE-compatible package imports





  - Import required packages: inputenc, fontenc, babel, lmodern
  - Add graphicx with figuras path configuration
  - Include caption and subcaption packages with ASCE settings
  - Import mathematical packages: amsmath, siunitx
  - Add table packages: booktabs, array, multirow
  - Configure newtxtext and newtxmath fonts as per ASCE requirements
  - Set up hyperref with ASCE-appropriate colors

  - _Requirements: 1.2, 6.1, 6.3, 6.4, 6.5_

- [x] 3. Set up document metadata and title structure





  - Convert title to ASCE format using \title{} command
  - Configure authors using \author[]{} and \affil[]{} from authblk package
  - Set up proper author affiliations and corresponding author email
  - Add hypersetup with PDF metadata (title, authors, subject, keywords)

  - Configure \maketitle command
  - _Requirements: 1.4, 1.5, 5.3_

- [x] 4. Create ASCE abstract environment





  - Convert existing abstract to \begin{abstract}...\end{abstract} format
  - Remove any internal subtitles or formatting
  - Ensure abstract follows ASCE length guidelines (250-300 words)

  - Maintain structured format: Background, Objective, Methods, Results, Conclusions
  - Preserve all scientific content from original abstract
  - _Requirements: 2.1, 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 5. Create Practical Applications section





  - Write 150-200 word plain-language summary for non-academic audiences
  - Focus on practical implications of attention-based deep learning for inspectors
  - Explain how the technology converts photographs to objective corrosion maps
  - Describe real-world applications: drone systems, maintenance optimization
  - Highlight quantitative benefits: 11.8% IoU improvement, 46% false positive reduction
  - _Requirements: 5.1, 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 6. Convert main sections to ASCE format

  - Transform Introduction section maintaining all scientific content
  - Convert Methodology section preserving technical details
  - Adapt Results section with all experimental data
  - Transform Discussion section keeping analysis intact
  - Convert Conclusions section maintaining scientific rigor
  - Use \section{} commands without manual numbering (ASCE standard)
  - Use \subsection{} and \subsubsection{} for hierarchical structure
  - _Requirements: 2.2, 2.3, 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 7. Adapt figures to ASCE format standards

  - Convert all figure environments to ASCE format with [htbp] positioning
  - Update \includegraphics commands with proper width specifications
  - Reformat all captions following ASCE style (Fig. X format)
  - Update all \label{} commands to use fig: prefix
  - Ensure all \ref{} commands work correctly
  - Verify figure paths point to correct files
  - _Requirements: 3.1, 3.3, 3.4, 7.4_


- [x] 8. Adapt tables to ASCE format standards





  - Convert all table environments to ASCE format with [htbp] positioning
  - Reformat table structure using proper ASCE tabular formatting
  - Update captions to follow ASCE style (Table X format)
  - Update all \label{} commands to use tab: prefix
  - Ensure proper column alignment and borders
  - Verify all table data is preserved accurately
  - _Requirements: 3.2, 3.3, 3.4, 7.4_


- [x] 9. Convert equations to ASCE format








  - Ensure all equations use \begin{equation}...\end{equation} environment
  - Implement sequential numbering throughout document including appendixes
  - Update all equation references using \ref{} commands
  - Verify mathematical notation is preserved correctly
  - Check that complex equations display properly
  - _Requirements: 2.4, 7.3, 7.4, 7.5_

- [x] 10. Create bibliography file in ASCE format

  - Convert existing referencias.bib to ASCE-compatible format
  - Map entry types to ASCE equivalents (@article → @ARTICLE, etc.)
  - Ensure all required fields are present for each entry type
  - Add optional fields like URL and DOI where available
  - Validate all author names and publication details
  - Remove any incompatible fields or formatting
  - _Requirements: 4.1, 4.4, 4.5_

- [x] 11. Configure ASCE citation system

  - Replace bibliography style with ascelike-new.bst
  - Convert all citation commands to ASCE format (\cite{}, \citeA{}, \citeN{})
  - Update \bibliography{} command to reference ASCE .bib file
  - Ensure author-year citation format is working correctly
  - Verify all citations resolve to bibliography entries
  - _Requirements: 2.5, 4.2, 4.3_

- [x] 12. Add mandatory ASCE sections

  - Create Data Availability Statement using appropriate ASCE template
  - Add Acknowledgments section after Conclusions
  - Format Keywords using \KeyWords{} command specific to ASCE class
  - Position all sections according to ASCE requirements order
  - Ensure proper spacing and formatting for each section
  - _Requirements: 5.1, 5.2, 5.4, 5.5_

- [x] 13. Set up appendixes with Roman numerals

  - Add \appendix command before appendix sections
  - Convert existing appendixes to ASCE format
  - Ensure Roman numeral numbering (I, II, III, etc.)
  - Update appendix references throughout document
  - Verify appendix content is properly formatted
  - _Requirements: 5.5, 7.4, 7.5_

- [x] 14. Perform comprehensive compilation testing







  - Run pdflatex on the ASCE document
  - Execute bibtex to process bibliography
  - Run pdflatex twice more to resolve all references
  - Verify PDF generates without errors or warnings
  - Check that all cross-references are resolved correctly
  - Validate that bibliography appears correctly formatted
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 15. Validate content preservation and ASCE compliance





  - Compare original and ASCE versions to ensure 100% content preservation
  - Verify all scientific data, metrics, and analysis are intact
  - Check that all figures and tables maintain original information
  - Validate that mathematical equations are correctly formatted
  - Confirm all references are properly cited and listed
  - Run final quality assurance checklist for ASCE compliance
  - Generate final PDF ready for ASCE submission
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 8.1, 8.2, 8.3, 8.4, 8.5_