@echo off
echo ========================================
echo Compiling Elsevier Classification Article
echo ========================================
echo.

echo [1/4] First LaTeX compilation...
pdflatex -interaction=nonstopmode artigo_elsevier_classification.tex
if %errorlevel% neq 0 (
    echo ERROR: First LaTeX compilation failed!
    pause
    exit /b 1
)

echo.
echo [2/4] BibTeX compilation...
bibtex artigo_elsevier_classification
if %errorlevel% neq 0 (
    echo WARNING: BibTeX compilation had issues, continuing...
)

echo.
echo [3/4] Second LaTeX compilation...
pdflatex -interaction=nonstopmode artigo_elsevier_classification.tex
if %errorlevel% neq 0 (
    echo ERROR: Second LaTeX compilation failed!
    pause
    exit /b 1
)

echo.
echo [4/4] Final LaTeX compilation...
pdflatex -interaction=nonstopmode artigo_elsevier_classification.tex
if %errorlevel% neq 0 (
    echo ERROR: Final LaTeX compilation failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Compilation completed successfully!
echo Output: artigo_elsevier_classification.pdf
echo ========================================
echo.

pause
