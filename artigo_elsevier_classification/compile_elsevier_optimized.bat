@echo off
echo ========================================
echo Compiling Optimized Elsevier Article
echo ========================================

echo.
echo [1/4] Running pdflatex (first pass)...
pdflatex -interaction=nonstopmode artigo_elsevier_classification_optimized.tex

echo.
echo [2/4] Running bibtex...
bibtex artigo_elsevier_classification_optimized

echo.
echo [3/4] Running pdflatex (second pass)...
pdflatex -interaction=nonstopmode artigo_elsevier_classification_optimized.tex

echo.
echo [4/4] Running pdflatex (third pass)...
pdflatex -interaction=nonstopmode artigo_elsevier_classification_optimized.tex

echo.
echo ========================================
echo Compilation Complete!
echo ========================================
echo Output: artigo_elsevier_classification_optimized.pdf
echo.

pause
