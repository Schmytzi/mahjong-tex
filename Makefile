## Makefile for mahjong package
# Directories
BUILD=build
TEXBUILD=$(BUILD)/tex
OUT=out
# TDS directories
TDS=$(BUILD)/tds
TDSDOC=$(TDS)/doc/latex/mahjong
TDSSRC=$(TDS)/source/latex/mahjong
TDSTEX=$(TDS)/tex/latex/mahjong
# CTAN directories
CTAN=$(BUILD)/ctan
# Compilers
LATEX=latex -output-directory $(TEXBUILD)
LATEXMK=latexmk -lualatex -outdir=$(TEXBUILD) -auxdir=$(TEXBUILD)
ZIP=zip -r
dir_guard=@mkdir -p $(@D)

.PHONY: all clean install

all: $(OUT)/mahjong-ctan.zip

clean:
	rm -rf $(BUILD)
	rm -rf $(OUT)
	rm -f mahjong.sty

install: all
	./install.sh


# Extract package from DTX source
$(TEXBUILD)/mahjong.sty: mahjong.ins mahjong.dtx
	$(dir_guard)
	$(LATEX) $<

# Compile documentation
$(TEXBUILD)/%.pdf: %.tex $(TEXBUILD)/mahjong.sty
	$(LATEXMK) $<

# Move everything to TDS staging area where it belongs
$(TDSDOC)/%.pdf: $(TEXBUILD)/%.pdf
	$(dir_guard)
	cp $< $@

$(TDSDOC)/%.tex: %.tex
	$(dir_guard)
	cp $< $@

$(TDSDOC)/README.md: README.md
	$(dir_guard)
	cp $< $@

$(TDSSRC)/mahjong.dtx: mahjong.dtx
	$(dir_guard)
	cp $< $@

$(TDSSRC)/mahjong.ins: mahjong.ins
	$(dir_guard)
	cp $< $@

$(TDSTEX)/%.sty: $(TEXBUILD)/%.sty
	$(dir_guard)
	cp $< $@

$(TDSTEX)/tiles: tiles
	cp -r $< $@

# Create TDS zip and moved it to CTAN staging area
$(CTAN)/mahjong.tds.zip: $(TDSDOC)/mahjong.pdf $(TDSDOC)/mahjong-code.pdf
$(CTAN)/mahjong.tds.zip: $(TDSDOC)/mahjong.tex $(TDSDOC)/mahjong-code.tex $(TDSDOC)/README.md
$(CTAN)/mahjong.tds.zip: $(TDSSRC)/mahjong.ins $(TDSSRC)/mahjong.dtx
$(CTAN)/mahjong.tds.zip: $(TDSTEX)/mahjong.sty $(TDSTEX)/tiles
	$(dir_guard)
	cd $(TDS) && $(ZIP) $(@F) *
	mv $(TDS)/$(@F) $@

# Move everything to CTAN staging area
$(CTAN)/%.pdf: $(TDSDOC)/%.pdf
	$(dir_guard)
	cp $< $@

$(CTAN)/%.tex: $(TDSDOC)/%.tex
	$(dir_guard)
	cp $< $@

$(CTAN)/%: %
	$(dir_guard)
	cp -r $< $@

# Create final zip archive for upload to CTAN
$(OUT)/mahjong-ctan.zip: $(CTAN)/mahjong.tex $(CTAN)/mahjong.pdf
$(OUT)/mahjong-ctan.zip: $(CTAN)/mahjong-code.tex $(CTAN)/mahjong-code.pdf
$(OUT)/mahjong-ctan.zip: $(CTAN)/README.md $(CTAN)/LICENSE
$(OUT)/mahjong-ctan.zip: $(CTAN)/mahjong.dtx $(CTAN)/mahjong.ins
$(OUT)/mahjong-ctan.zip: $(CTAN)/tiles $(CTAN)/mahjong.tds.zip
	$(dir_guard)
	cd $(CTAN) && $(ZIP) $(@F) ./*
	mv $(CTAN)/$(@F) $@