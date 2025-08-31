@echo off
setlocal
set MIKTEX_PATH=C:\Users\%USERNAME%\AppData\Local\Programs\MiKTeX\miktex\bin\x64
set PATH=%MIKTEX_PATH%;%PATH%

echo Compilando artigo cientifico...
echo.

echo [1/4] Primeira compilacao...
pdflatex -interaction=nonstopmode -halt-on-error artigo_cientifico_corrosao.tex
if errorlevel 1 goto erro

echo [2/4] Processando bibliografia...
bibtex artigo_cientifico_corrosao
if errorlevel 1 echo Aviso: Erro na bibliografia (pode ser normal se nao houver citacoes)

echo [3/4] Segunda compilacao...
pdflatex -interaction=nonstopmode -halt-on-error artigo_cientifico_corrosao.tex
if errorlevel 1 goto erro

echo [4/4] Compilacao final...
pdflatex -interaction=nonstopmode -halt-on-error artigo_cientifico_corrosao.tex
if errorlevel 1 goto erro

echo.
echo ✓ Compilacao concluida com sucesso!
echo ✓ PDF gerado: artigo_cientifico_corrosao.pdf

if exist artigo_cientifico_corrosao.pdf (
    echo.
    echo Abrindo PDF...
    start artigo_cientifico_corrosao.pdf
)

goto fim

:erro
echo.
echo ✗ Erro durante a compilacao!
echo Verifique o arquivo de log para detalhes: artigo_cientifico_corrosao.log
pause
exit /b 1

:fim
pause
