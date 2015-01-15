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
#    name of the definition file containing
#      1) the list of documents to be build,
#      2) document types,
#      3) and the files included in each document source (.md file),
#    within each subdir.
#
#    Currently supported types are
#      EXERCISE -  plain A4 Latex document
#      SLIDE    -  revealjs html slideshow
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
REVEALJS                = $(HOME)/.pandoc/reveal.js
EXERCISE_HEADER_TEX     = $(ROOT)/utils/exercise_header.tex
REVEALJS_HEADER_CSS     = $(ROOT)/utils/reveal-simple-override.css
REVEALJS_HEADER_PDF_CSS = $(ROOT)/utils/reveal-pdf.css

# Supported document types
types            := SLIDE EXERCISE
SLIDE_postfix    := .html
EXERCISE_postfix := .pdf

# Pandoc options for each supported type
EXERCISE_OPTS = -V papersize=a4paper -V fontsize=12pt \
                -V geometry='top=2cm,bottom=2cm,left=2cm,right=2cm' \
                -H $(EXERCISE_HEADER_TEX)

SLIDE_OPTS = --self-contained \
              --slide-level=2 --smart -s --mathml \
              -V revealjs-url=$(REVEALJS) \
              -t revealjs


##############################
# Templates/functions/macros #
##############################

# Set variables "SRCDIR_<document-name>" and
# INCLUDES_<document-name>, and
# each document of the specified type to
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
 $$(foreach doc,$$(basename $$(new_$(1)S)),$$(eval INCLUDES_$$(doc) = $$(patsubst %,$(CURDIR)/%,$$(wordlist 2,$$(words $$($(1)_$$(doc))),$$($(1)_$$(doc))))))
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

# Load definition files
$(foreach def,$(defs),$(eval $(call load-defs,$(def))))

VPATH := $(patsubst $(eval) ,:,$(dir $(defs)))

#########
# RULES #
#########

.PHONY : all subdirs clean

all : subdirs $(SLIDES) $(EXERCISES)

.SECONDEXPANSION :

# Generic rule
#
# document.<type suffix> : <document-source.md> <document includes>
#	rules ...
#
define gen-build
$$($(1)S) : $$$$(firstword $$$$($(1)_$$$$(basename $$$$@))) \
            $$$$(INCLUDES_$$$$(basename $$$$@))
	@echo $$^
	pandoc $$($(1)_OPTS) $$< -o $(CURDIR)/$$@
endef

# Generate a rule for each supported document type
$(foreach type,$(types),$(eval $(call gen-build,$(type))))

# Rules for the include files (files included in .md sources)
$(CURDIR)/%.svg : %.svg
	cp $< $@

# Subdirs for files included in document sources
INCLUDE_SUBDIRS = $(sort $(dir $(foreach var, $(filter INCLUDES_%,$(.VARIABLES)),$(eval) $($(var)))))

subdirs : $(INCLUDE_SUBDIRS)

$(INCLUDE_SUBDIRS) :
	mkdir -p $@

clean :
	rm -f *.pdf *.html */*.svg

