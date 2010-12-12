.SUFFIXES: .fig .dvi .ps

VERSION = NoVersionGiven

#----------------------------------------------------------------------
# Edit these variables for each new paper.
#----------------------------------------------------------------------

name = phonelab
fig_dirs = .
pdf_dirs = .
tex_dirs = .
bib_dirs = .
latex = pdflatex

#----------------------------------------------------------------------
# Shouldn't have to touch anything below here...
#----------------------------------------------------------------------

#----------------------------------------------------------------------
# Setup variable
#----------------------------------------------------------------------

# look for files
find = $(foreach dir,$(1),$(wildcard $(dir)/*.$(2)))

tex_files = $(call find,$(tex_dirs),tex)

fig_files = $(call find,$(fig_dirs),fig)
eps_fig_files = $(patsubst %.fig, %.eps, $(fig_files))
pdf_fig_files = $(patsubst %.fig, %.pdf, $(fig_files))

pdf_files = $(pdf_fig_files) $(call find,$(pdf_dirs),pdf)
eps_files = $(eps_fig_files)

bib_files = $(call find,$(bib_dirs),bib)

latex_library_files =

#see if we have a bib
have_bib = $(if $(strip $(bib_files)),true,false)


# running variables
junk = $(eps_fig_files) $(pdf_fig_files)
docs =

#----------------------------------------------------------------------
# LaTeX commands.
#----------------------------------------------------------------------

ifeq ($(latex),pdflatex)
all: $(name).pdf
else
all: $(name).dvi
endif

%.eps: %.fig
	fig2dev -L eps $< $@

$(pdf_fig_files): %.pdf: %.eps
	epstopdf --outfile=$@ $<

once:
	$(latex) $(name)

ifeq ($(latex),pdflatex)
$(name).pdf: $(tex_files) $(bib_files) $(pdf_files)
else
$(name).dvi: $(tex_files) $(bib_files) $(eps_files)
endif
ifeq ($(have_bib), true)
	@echo "**************************************************************"
	@echo "Run latex once ***********************************************"
	@echo "**************************************************************"
	$(latex) $(name)
	@echo "**************************************************************"
	@echo "Run bibtex  **************************************************"
	@echo "**************************************************************"
	bibtex $(name)
	@echo "**************************************************************"
	@echo "Run latex twice **********************************************"
	@echo "**************************************************************"
	$(latex) $(name)
	@echo "**************************************************************"
	@echo "Run latex thrice *********************************************"
	@echo "**************************************************************"
	$(latex) $(name)
	@echo "**************************************************************"
	@echo "Run latex one more time **************************************"
	@echo "**************************************************************"
	$(latex) $(name)
	@echo "**************************************************************"
	@echo "**************************************************************"
	rm -f $(junk)
else
	@echo "**************************************************************"
	@echo "Run latex once ***********************************************"
	@echo "**************************************************************"
	$(latex) $(name)
	@echo "**************************************************************"
	@echo "Run latex twice **********************************************"
	@echo "**************************************************************"
	$(latex) $(name)
	@echo "**************************************************************"
	@echo "**************************************************************"
	rm -f $(junk)
endif

bib:
	bibtex $(name)

ifeq ($(latex),pdflatex)
docs += $(name).pdf
else
docs += $(name).dvi $(eps_files)
endif
junk +=	*.aux \
		$(name).log \
		$(name).lof \
		$(name).lot \
		$(name).toc \
		$(name).blg \
		$(name).bbl \
		psfig.aux 

#----------------------------------------------------------------------
# Postscript/PDF generation.
#----------------------------------------------------------------------

ifeq ($(latex),latex)
ps: $(name).ps

DVIPS = dvips

$(name).ps: $(name).dvi
	$(DVIPS) -t letter -o $(name).ps $(name).dvi

$(name).ps2: $(name).dvi
	$(DVIPS) -o ps2.tmp -p 2 $(name).dvi
	mpage -2 -P ps2.tmp > $(name).ps2
	rm ps2.tmp

pdf: $(name).pdf

$(name).pdf: $(name).dvi
	dvipdfm $(distill_args) $(name)

docs += $(name).ps $(name).ps2 $(name).pdf
endif

#----------------------------------------------------------------------
# Document previewers.
#----------------------------------------------------------------------

ifeq ($(latex),pdflatex)
x: $(name).pdf
	xpdf $(name).pdf
endif

ifeq ($(latex),latex)
x: $(name).dvi
	xdvi $(name).dvi &

gv: $(name).ps
	ghostview $(name).ps &
endif

#----------------------------------------------------------------------
# Miscellaneous.
#----------------------------------------------------------------------

debug:
	@echo fig_files: $(fig_files)
	@echo tex_files: $(tex_files)
	@echo bib_files: $(bib_files)
	@echo have_bib: $(have_bib)

tags:
	etags $(tex_files)

clean:
	rm -f $(junk)
	rm *.pdf

allclean: clean
	rm -f $(docs)

