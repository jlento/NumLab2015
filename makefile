# 2015-01-05 juha.lento@csc.fi
#
# USAGE: make [ GNU make options ] -f this-makefile [ SUBDIR ]
#
# Builds the html and pdf documents from markdown (.md) sources
# using pandoc.
#
# ROOT
#    of the source directories is the directory containing this makefile.
# SUBDIR
#    source directory is any directory under ROOT which name
#    begins with a digit.
# files.mk
#    contains the list of documents and their type within a SUBDIR.
#    Currently supported types are EXERCISES, plain A4 Latex document,
#    and SLIDES, revealjs html slideshow (+ printable version).
#
#    Also, files.mk contains the list of sources for the documents. For
#    example (ROOT/ex1/files.mk):
#
#        EXERCISES = ex1 ex2
#        SRC_ex1 = ex1.md ex1.svg
#        SRC_ex2 = ex2.md ex2.svg
#
# The resulting documents are written to the current directory, i.e.
#    the directory where make was called (out-of-source build),
#    under respective SUBDIRs.

ROOT = $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
SUBDIRS = $(notdir $(wildcard $(ROOT)/[0-9]*))

.PHONY : all clean $(SUBDIRS)

all : $(SUBDIRS)

$(SUBDIRS) :
	@mkdir -p $@
	@$(MAKE) --no-print-directory -f $(ROOT)/$@/files.mk -f $(ROOT)/utils/makefile ROOT=$(ROOT) SUBDIR=$@

clean :
	rm -f $(foreach dir,$(SUBDIRS),$(dir)/*.pdf $(dir)/*.html)
