@echo off
REM Compilation script for classification article
REM This script compiles the LaTeX document with bibliography

echo ========================================
echo Compiling Classification Article
echo ========================================
echo.

echo [1/4] First LaTeX compilation...
pdflatex -interaction=nonstopmode artigo_classificacao_corrosao.tex
if %errorlevel% neq 0 (
    echo ERROR: First LaTeX compilation failed!
    pause
    exit /b 1
)

echo.
echo [2/4] Generating bibliography...
bibtex artigo_classificacao_corrosao
if %errorlevel% neq 0 (
    echo WARNING: BibTeX compilation had issues (this is normal if no citations yet)
)

echo.
echo [3/4] Second LaTeX compilation...
pdflatex -interaction=nonstopmode artigo_classificacao_corrosao.tex
if %errorlevel% neq 0 (
    echo ERROR: Second LaTeX compilation failed!
    pause
    exit /b 1
)

echo.
echo [4/4] Final LaTeX compilation...
pdflatex -interaction=nonstopmode artigo_classificacao_corrosao.tex
if %errorlevel% neq 0 (
    echo ERROR: Final LaTeX compilation failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Compilation completed successfully!
echo Output: artigo_classificacao_corrosao.pdf
echo ========================================
echo.

REM Clean up auxiliary files (optional)
echo Cleaning up auxiliary files...
del artigo_classificacao_corrosao.aux 2>nul
del artigo_classificacao_corrosao.log 2>nul
del artigo_classificacao_corrosao.out 2>nul
del artigo_classificacao_corrosao.bbl 2>nul
del artigo_classificacao_corrosao.blg 2>nul

echo Done!
pause
