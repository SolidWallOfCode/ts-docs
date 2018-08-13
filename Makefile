# Makefile for Sphinx documentation

.PHONY: help dirhtml singlehtml

srcdir        ?= .
SPHINXBUILD    = sphinx-build
PAPER         ?= letter
BUILDDIR      ?= docbuild
JAVA          ?= java
PLANTUML_JAR  ?= ~/bin/plantuml.jar
PLANTUML_ARGS ?=
REALPATH       = $(if $(WINDIR), cygpath --absolute --windows, realpath)

SBUILD = $(SPHINXBUILD) ${PAPEROPT_letter}
PLANTUML = $(JAVA) -jar $(PLANTUML_JAR) $(PLANTUML_ARGS)
IMAGEDIR = $(srcdir)/pix
UMLDIR = $(srcdir)/uml

$(IMAGEDIR)/%.png : $(UMLDIR)/%.uml
	$(PLANTUML) $< -o $(shell $(REALPATH) $(IMAGEDIR))

$(IMAGEDIR)/%.svg : $(UMLDIR)/%.uml
	$(PLANTUML) $< -tsvg -o $(shell $(REALPATH) $(IMAGEDIR))

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  html       to make standalone HTML files"
	@echo "  dirhtml    to make HTML files named index.html in directories"
	@echo "  singlehtml to make a single large HTML file"

html: uml 
	$(SBUILD) -d $(BUILDDIR)/doctrees -b html $(srcdir) $(BUILDDIR)/html
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/html."

uml: $(IMAGEDIR)/ts-projects.png\
     $(IMAGEDIR)/ts-api-action.png\
     $(IMAGEDIR)/cache-dir-sync.png \
     $(IMAGEDIR)/layer-4-proxy.png 

dirhtml:
	$(SBUILD) -d $(BUILDDIR)/doctrees -b dirhtml $(srcdir) $(BUILDDIR)/html
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/dirhtml."

singlehtml:
	$(SBUILD) -d $(BUILDDIR)/doctrees -b singlehtml $(srcdir) $(BUILDDIR)/singlehtml
	@echo
	@echo "Build finished. The HTML page is in $(BUILDDIR)/singlehtml."

clean:
	-rm -rf html warn.log
	-rm -rf $(BUILDDIR)/doctrees $(BUILDDIR)/html $(BUILDDIR)/dirhtml $(BUILDDIR)/singlehtml

publish: clean html
	$(SHELL) ./publish.sh
