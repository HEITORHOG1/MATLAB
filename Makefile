# Makefile para compilação do artigo científico LaTeX

# Variáveis
MAIN = artigo_cientifico_corrosao
TEXFILE = $(MAIN).tex
PDFFILE = $(MAIN).pdf
BIBFILE = referencias.bib

# Compilador LaTeX
LATEX = pdflatex
BIBTEX = bibtex

# Flags
LATEXFLAGS = -interaction=nonstopmode -halt-on-error

# Regra principal
all: $(PDFFILE)

# Compilação completa com bibliografia
$(PDFFILE): $(TEXFILE) $(BIBFILE)
	$(LATEX) $(LATEXFLAGS) $(TEXFILE)
	$(BIBTEX) $(MAIN)
	$(LATEX) $(LATEXFLAGS) $(TEXFILE)
	$(LATEX) $(LATEXFLAGS) $(TEXFILE)

# Compilação rápida (sem bibliografia)
quick: $(TEXFILE)
	$(LATEX) $(LATEXFLAGS) $(TEXFILE)

# Limpeza de arquivos temporários
clean:
	rm -f *.aux *.bbl *.blg *.log *.out *.toc *.lof *.lot *.fls *.fdb_latexmk *.synctex.gz

# Limpeza completa (incluindo PDF)
distclean: clean
	rm -f $(PDFFILE)

# Visualizar PDF (Linux/Mac)
view: $(PDFFILE)
	@if command -v xdg-open > /dev/null; then \
		xdg-open $(PDFFILE); \
	elif command -v open > /dev/null; then \
		open $(PDFFILE); \
	else \
		echo "Não foi possível abrir o PDF automaticamente"; \
	fi

# Contar palavras
wordcount: $(TEXFILE)
	@echo "Contagem de palavras (aproximada):"
	@detex $(TEXFILE) | wc -w

# Verificar sintaxe LaTeX
check: $(TEXFILE)
	$(LATEX) $(LATEXFLAGS) -draftmode $(TEXFILE)

# Ajuda
help:
	@echo "Comandos disponíveis:"
	@echo "  make all       - Compilação completa com bibliografia"
	@echo "  make quick     - Compilação rápida sem bibliografia"
	@echo "  make clean     - Remove arquivos temporários"
	@echo "  make distclean - Remove todos os arquivos gerados"
	@echo "  make view      - Abre o PDF gerado"
	@echo "  make wordcount - Conta palavras no documento"
	@echo "  make check     - Verifica sintaxe LaTeX"
	@echo "  make help      - Mostra esta ajuda"

.PHONY: all quick clean distclean view wordcount check help