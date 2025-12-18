# ASCE Submission Package

This folder contains all files formatted according to ASCE Journal submission requirements.

## Contents

### Main Files
- **manuscript.tex** - Main manuscript in LaTeX format
  - Tables moved to the end (after References)
  - Figure placeholders: `[Figure X about here]`
  - Double-spaced text
  
- **referencias.bib** - Bibliography file

- **Figure_Captions_List.docx.txt** - Double-spaced list of figure captions

### Style Files
- **ascelike-new.cls** - ASCE document class
- **ascelike-new.bst** - ASCE bibliography style

### Figures (in `figures/` folder)
Each figure is provided as a separate PDF file:
- **Figure_1.pdf** - Experimental methodology flowchart
- **Figure_2.pdf** - Comparative performance analysis (box plots, PR curves)
- **Figure_3.pdf** - Learning curves (training/validation loss, IoU, Dice)
- **Figure_4.pdf** - Visual comparison of segmentations

## ASCE Requirements Checklist

- [x] Manuscript in LaTeX format (.tex file provided)
- [x] Tables at end of manuscript (after References)
- [x] Figures removed from text and uploaded separately
- [x] Figures in PDF format (also available: EPS, TIFF)
- [x] Figure filenames include figure number
- [x] Double-spaced figure captions list provided
- [x] Bibliography file included

## Compilation Instructions

```bash
pdflatex manuscript.tex
bibtex manuscript
pdflatex manuscript.tex
pdflatex manuscript.tex
```

## Notes

1. The original TikZ flowchart (Figure 1) has been replaced with a pre-rendered PDF
2. All figures are in English (EN versions)
3. The manuscript uses `[Figure X about here]` placeholders as required by ASCE
