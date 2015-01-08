# 2015-01-05 juha.lento@csc.fi
#
# This (sub)makefile is run for each document source directory SUBDIR.
#
# The list of the target documents are in the variables EXERCISES and
#     SLIDES and their corresponding sources are in variables SRC_*.
# The caller (root makefile) sets the variables ROOT and
#     SUBDIR.
# See the root makefile ../makefile for more documentation about
#     defining the targets and sources for each SUBDIR, and how this
#     makefile is called.

ifndef ROOT
  $(error Internal error: Variable ROOT needs to be set.)
endif
ifndef SUBDIR
  $(error Internal error: Variable SUBDIR needs to be set.)
endif

VPATH = $(ROOT)/$(SUBDIR):$(SUBDIR)

REVEALJS = $(HOME)/.pandoc/reveal.js

EXERCISE_HEADER_TEX     = $(ROOT)/utils/exercise_header.tex
REVEALJS_HEADER_CSS     = $(ROOT)/utils/reveal-simple-override.css
REVEALJS_HEADER_PDF_CSS = $(ROOT)/utils/reveal-pdf.css

EXERCISE_OPTS = -V papersize=a4paper -V fontsize=12pt \
                -V geometry='top=2cm,bottom=2cm,left=2cm,right=2cm' \
                -H $(EXERCISE_HEADER_TEX)

SLIDES_OPTS = --self-contained \
              --slide-level=2 --smart -s --mathml \
              -V revealjs-url=$(REVEALJS) \
              -t revealjs \
              -H $(REVEALJS_HEADER_CSS)

PRINTABLE_SLIDES_OPTS = $(SLIDES_OPTS) -H $(REVEALJS_HEADER_PDF_CSS)

.PHONY : all $(SLIDES) $(EXERCISES)

all : $(SLIDES) $(EXERCISES)

.SECONDEXPANSION:

$(EXERCISES) : $$@.pdf

$(SLIDES) : $$@.html $$@_printable.html

%.pdf : $$(SRC_$$(basename $$@))
	cd $(ROOT)/$(SUBDIR) ; \
            pandoc $(EXERCISE_OPTS) $< -o $(CURDIR)/$(SUBDIR)/$@

%_printable.html : $$(SRC_$$(subst _printable.html,,$$@))
	cd $(ROOT)/$(SUBDIR) ; \
            pandoc $(PRINTABLE_SLIDES_OPTS) $< -o $(CURDIR)/$(SUBDIR)/$@

%.html : $$(SRC_$$(basename $$@))
	cd $(ROOT)/$(SUBDIR) ;	\
            pandoc $(SLIDES_OPTS) $< -o $(CURDIR)/$(SUBDIR)/$@
