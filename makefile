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
REVEALJS                := $(HOME)/.pandoc/reveal.js
EXERCISE_HEADER_TEX     := $(ROOT)/utils/exercise_header.tex
REVEALJS_HEADER_CSS     := $(ROOT)/utils/reveal-simple-override.css
REVEALJS_HEADER_PDF_CSS := $(ROOT)/utils/reveal-pdf.css

# Supported document types
types            := SLIDE EXERCISE
SLIDE_suffix    := .html
EXERCISE_suffix := .pdf

# Pandoc options for each supported type
EXERCISE_OPTS := -V papersize=a4paper -V fontsize=12pt \
                 -V geometry='top=2cm,bottom=2cm,left=2cm,right=2cm' \
                 -H $(EXERCISE_HEADER_TEX)

SLIDE_OPTS := --self-contained \
              --slide-level=2 --smart -s --mathml \
              -V revealjs-url=$(REVEALJS) \
              -t revealjs


##############################
# Templates/functions/macros #
##############################

# patsubst with multiple patterns
rpatsubst = $(if $1,$(call rpatsubst,$(filter-out $(firstword $1),$1),$2,$(patsubst $(firstword $1),$2,$3)),$3)

# Set variables
#     SRCDIR_<document-name>"
#     INCLUDES_<document-name>
# Append the document to the corresponding make target
#     <TYPE>S
#
# $(1) is the name of a variable, i.e.
# <document-type>_<document-name> from FILES definition file.
#
define set-vars
 srcdir  := $$(dir $$(lastword $$(MAKEFILE_LIST)))
 docname := $$(call rpatsubst,$(types:%=%_%),%,$(1))
 doctype := $$(patsubst %_$$(docname),%,$1)
 $$(eval SRCDIR_$$(docname) = $(srcdir))
 $$(eval INCLUDES_$$(docname) = $$(patsubst %,$(CURDIR)/%,$$(filter-out $$(firstword $$($1)),$$($(1)))))
 $$(eval $$(doctype)S += $$(docname)$$($$(doctype)_suffix))
endef

# Include the specified makefile, extract the list of variables
# defined in it and call routine that defines relevant variables for
# each document.
#
# $(1) is the makefile to be loaded
#
define load-defs
 all_vars := $$(.VARIABLES)
 include $(1)
 new_doc_var_names := $$(filter-out all_vars new_docs $$(all_vars),$$(.VARIABLES))
 $$(foreach varname,$$(new_doc_var_names),$$(eval $$(call set-vars,$$(varname))))
endef


######################
# GENERATE VARIABLES #
######################

# Find all the sub-directories that have a definition file
defs  := $(shell find $(ROOT) -name $(FILES))

# Load definition files and set variables
#    SRCDIR_<document>
#    INCLUDES_<document>
#    <TYPE>S
# for all documents.
#
$(foreach def,$(defs),$(eval $(call load-defs,$(def))))

# Source directories
VPATH := $(patsubst $(eval) ,:,$(dir $(defs)))

# All documents' include files
INCLUDES := $(foreach var,$(filter INCLUDES_%,$(.VARIABLES)),$($(var)))

# Subdirs containing the includes under current (build) directory
INCLUDE_SUBDIRS := $(sort $(dir $(INCLUDES)))


#########
# RULES #
#########

.PHONY : all subdirs clean

all : $(SLIDES) $(EXERCISES)

.SECONDEXPANSION :

# Generic rule
#
# document.<type suffix> : <document-source.md> <document-include-subdirs>
#                          <document-includes>
#	rules ...
#
define gen-build
$$($(1)S) : $$$$(firstword $$$$($(1)_$$$$(basename $$$$@))) \
            $$$$(INCLUDES_$$$$(basename $$$$@))
	pandoc $$($(1)_OPTS) $$< -o $(CURDIR)/$$@
endef

# Generate a rule for each supported document type
$(foreach type,$(types),$(eval $(call gen-build,$(type))))

# Rules for the include files (files included in .md sources)
$(CURDIR)/%.svg : %.svg
	cp $< $@

# Subdirs for the included files
$(INCLUDES) : | $$(dir $$@)

$(INCLUDE_SUBDIRS) :
	mkdir -p $@

clean :
	rm -f *.pdf *.html */*.svg

