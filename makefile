# 2015-01-14 juha.lento@csc.fi
#
# USAGE: make [ GNU make options ] -f this-makefile
#
# Builds the html and pdf documents from markdown (.md) sources
# using pandoc.
#
# ROOT
#    of the source directories is the directory containing this makefile.
# FILES
#    name of the definition file containing the list of documents to
#    be build, document types and document sources, within each subdir.
#
#    Currently supported types are
#      EXERCISE -  plain A4 Latex document
#      SLIDE    -  revealjs html slideshow
#      PSLIDE   -  a printable version of SLIDE
#
#    For example, see $(ROOT)/1_Session/files.mk
#
# The built documents and other dependencies than the markdown
# source are written to the current directory.


#################
# SET VARIABLES #
#################

ROOT  := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
FILES := files.mk

# Auxiliary files used by pandoc 
REVEALJS = $(HOME)/.pandoc/reveal.js
EXERCISE_HEADER_TEX     = $(ROOT)/utils/exercise_header.tex
REVEALJS_HEADER_CSS     = $(ROOT)/utils/reveal-simple-override.css
REVEALJS_HEADER_PDF_CSS = $(ROOT)/utils/reveal-pdf.css

# Supported document types
types := SLIDE PSLIDE EXERCISE
SLIDE_postfix    := .html
PSLIDE_postfix   := .html
EXERCISE_postfix := .pdf

# Pandoc options for each supported type
EXERCISE_OPTS = -V papersize=a4paper -V fontsize=12pt \
                -V geometry='top=2cm,bottom=2cm,left=2cm,right=2cm' \
                -H $(EXERCISE_HEADER_TEX)

SLIDE_OPTS = --self-contained \
              --slide-level=2 --smart -s --mathml \
              -V revealjs-url=$(REVEALJS) \
              -t revealjs

PSLIDE_OPTS = $(SLIDE_OPTS) -H $(REVEALJS_HEADER_PDF_CSS)


##############################
# Templates/functions/macros #
##############################

# Set variable "SRCDIR_<document name>" and
# add each document of the specified type to
# the corresponding make target "<TYPE>S".
#
# $(1) specifies the type of the documents.
# $(2) is the source root for the documents.
# $(3) is the list of variable names specified
#      in the definition file
define set-vars
 new_$(1)S = $$(patsubst $(1)_%,%$$($(1)_postfix),$$(filter $(1)_%,$(3)))
 $(1)S += $$(new_$(1)S)
 $$(foreach doc,$$(basename $$(new_$(1)S)),$$(eval SRCDIR_$$(doc) = $(2)))
endef

# Include the specified makefile, extract the list of variables
# defined in it and set/append to the appropriate variables.
#
# $(1) is the makefile to be loaded
define load-defs
 all_vars := $$(.VARIABLES)
 include $(1)
 srcdir := $$(dir $$(lastword $$(MAKEFILE_LIST)))
 files_vars = $$(filter-out all_vars $$(all_vars),$$(.VARIABLES))
 $$(foreach type,$(types),$$(eval $$(call set-vars,$$(type),$$(srcdir),$$(files_vars))))
endef


######################
# GENERATE VARIABLES #
######################

# Find all the sub-directories that have a definition file
defs  := $(shell find $(ROOT) -name $(FILES))

# Loop over all found definition files and
# 1) include the definition file here (i.e. the source
#    dependencies for each document),
# 2) add the documents listed in the file to the
#    make target list for each document type, and
# 2) set a pointer to the source directory for each document
$(foreach def,$(defs),$(eval $(call load-defs,$(def))))

VPATH := $(patsubst $(eval) ,:,$(dir $(defs)))

#########
# RULES #
#########

.PHONY : all clean

all : $(SLIDES) $(PSLIDES) $(EXERCISES)

.SECONDEXPANSION :

# Generic rule
#
# document.<type suffix> : <document dependencies>
#	rules ...
#
## Change the first line to this if you need to copy includes ..
#
#$$($(1)S) : $$$$(firstword $$$$($(1)_$$$$(basename $$$$@))) \
#            $$$$(addprefix $(CURDIR)/,$$$$(patsubst $$$$(SRCDIR_$$$$(basename $$$$@))%,%,$$$$(wordlist 2,$$$$(words $$$$($(1)_$$$$(basename $$$$@))),$$$$($(1)_$$$$(basename $$$$@)))))
#
define gen-build
$$($(1)S) : $$$$($(1)_$$$$(basename $$$$@))
	cd $$(SRCDIR_$$(basename $$@)) ; \
            pandoc $$($(1)_OPTS) $$(notdir $$<) -o $(CURDIR)/$$@
endef

# Generate a rule for each supported document type
$(foreach type,$(types),$(eval $(call gen-build,$(type))))

## Rules for the include files they need to be copied to the current dir.
#$(CURDIR)/%.svg : %.svg
#	test -d $(dir $@) || mkdir -p $(dir $@)
#	cp $^ $@

clean :
	rm -f *.pdf *.html
# include/*.svg

