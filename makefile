# 2015-01-23 juha.lento@csc.fi
#
# USAGE: make [ GNU make options ] -f this-makefile
#
# Builds the html and pdf documents from markdown (.md) sources
# using pandoc.
#
# The source files have a name of the form
#
#     <document-name>.<doc-type>.md
#
# where the supported <doc-type>s are
#
#     exercise -  plain A4 Latex document
#     slide    -  revealjs html slideshow
# 
# Source files are searched from the directory containing this
# makefile, and it's subdirectories. Well, you can do
#
#     make -f makefile ROOT=/some/other/root
# too...
#

#################
# SET VARIABLES #
#################

ROOT  := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Auxiliary files used by pandoc 
REVEALJS                := $(HOME)/.pandoc/reveal.js
EXERCISE_HEADER_TEX     := $(ROOT)/utils/exercise_header.tex
REVEALJS_HEADER_CSS     := $(ROOT)/utils/reveal-simple-override.css
REVEALJS_HEADER_PDF_CSS := $(ROOT)/utils/reveal-pdf.css

# Supported document types
types           := slide exercise
slide_suffix    := html
exercise_suffix := pdf

# Pandoc options for each supported type
exercise_OPTS := -V papersize=a4paper -V fontsize=12pt \
                 -V geometry='top=2cm,bottom=2cm,left=2cm,right=2cm' \
                 -H $(EXERCISE_HEADER_TEX)

slide_OPTS := --self-contained \
              --slide-level=2 --smart -s --mathml \
              -V revealjs-url=$(REVEALJS) \
              -t revealjs

# This stuff would be better fixed with a pandoc filter...
INCLUDE_SUFFIXES = $(subst $(eval) ,|,svg SVG png PNG jpg JPG jpeg JPEG gif GIF)


##########################
# Helper functions, etc. #
##########################

# Given document source file name, returns it's type
source-type = $(patsubst .%,%,$(suffix $(basename $(notdir $(1)))))

fix-relative-paths = sed -r 's:\(([^(]*\.($(INCLUDE_SUFFIXES)))\):\($$(dir $$<)\1\):'

#######################
# GENERATED VARIABLES #
#######################

# Sources
sources   := $(filter-out %README.md,$(shell find $(ROOT) -name '*.md'))

# Targets for each document type in variable $(<type>s)
$(foreach type,$(types),$(eval $(type)s := $(patsubst %.md,%.$($(type)_suffix),$(notdir $(filter %.$(type).md,$(sources))))))


#########
# RULES #
#########

# Source search path
vpath %.md $(subst $(eval) ,:,$(dir $(sources)))

.PHONY : all clean

all : $(slides) $(exercises)

# Generate build rules for each type using a template
define gen-build
%.$(1).$$($(1)_suffix) : %.$(1).md %.$(1).d
	$(fix-relative-paths) $$< | pandoc $$($(1)_OPTS) -o $$@
endef
$(foreach type,$(types),$(eval $(call gen-build,$(type))))

# Generate and include dependencies
%.d: %.md extracturls
	./extracturls < $< | \
          sed -r -e '/^https:\/\/|http:\/\//d' \
              -e 's|(/*)(.*)|$(dir $<)\2|' | \
          tr '\n' ' ' | sed 's|.*|$(patsubst %.md,%.$($(call source-type,$<)_suffix),$(notdir $<)) : &\n|' > $(notdir $@)
include $(notdir $(sources:.md=.d))

extracturls : $(ROOT)/utils/extracturls.hs 
	ghc -outputdir . $< -o $@

clean :
	rm -f *.pdf *.html *.d extractulrs

