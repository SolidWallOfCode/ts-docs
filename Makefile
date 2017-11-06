# Makefile for Sphinx documentation

.PHONY: help dirhtml singlehtml

srcdir=.
SPHINXBUILD=sphinx-build
PAPER         = letter
BUILDDIR      = docbuild
JAVA          = java

SBUILD = $(SPHINXBUILD) ${PAPEROPT_letter}
PLANTUML = $(JAVA) -jar ~/bin/plantuml.jar
IMAGEDIR = $(srcdir)/pix
BUILD_IMAGEDIR = $(BUILDDIR)/html/_images
UMLDIR = $(srcdir)/uml

$(IMAGEDIR)/%.png : $(UMLDIR)/%.uml
	$(PLANTUML) $< -o $(shell realpath $(IMAGEDIR))

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  html       to make standalone HTML files"
	@echo "  dirhtml    to make HTML files named index.html in directories"
	@echo "  singlehtml to make a single large HTML file"

html: uml $(BUILD_IMAGEDIR)/ts-projects.png
	$(SBUILD) -d $(BUILDDIR)/doctrees -b html $(srcdir) $(BUILDDIR)/html
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/html."

uml: $(IMAGEDIR)/ts-projects.png\
	 $(IMAGEDIR)/ts-api-action.png\
	 $(IMAGEDIR)/cache-dir-sync.png

$(BUILD_IMAGEDIR)/ts-projects.png: $(IMAGEDIR)/ts-projects.png
	cp $(IMAGEDIR)/ts-projects.png $(BUILD_IMAGEDIR)

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

publish:
	$(SHELL) ./publish.sh
