## Makefile for mahjong package
# Directories
BUILD=build
TEXBUILD=$(BUILD)/tex
OUT=out
TEXMF_HOME:= $(shell kpsewhich -var-value TEXMFHOME)
# TDS directories
TDS=$(BUILD)/tds
TDSDOC=$(TDS)/doc/latex/mahjong
TDSSRC=$(TDS)/source/latex/mahjong
TDSTEX=$(TDS)/tex/latex/mahjong
# CTAN directories
CTAN=$(BUILD)/ctan
CTAN_MAHJONG=$(CTAN)/mahjong
# Compilers
LATEX=latex -output-directory $(TEXBUILD)
LATEXMK=latexmk -lualatex -outdir=$(TEXBUILD) -auxdir=$(TEXBUILD) -interaction=nonstopmode -use-make
ZIP=zip -r
dir_guard=@mkdir -p $(@D)

.PHONY: all clean install

all: $(OUT)/mahjong-ctan.zip

clean:
	rm -rf $(BUILD)
	rm -rf $(OUT)
	rm -f mahjong.sty

install: all
	unzip $(CTAN)/mahjong.tds.zip -d $(TEXMF_HOME)


# Extract package from DTX source
$(TEXBUILD)/mahjong.sty: mahjong.ins mahjong.dtx
	$(dir_guard)
	$(LATEX) $<

# Compile documentation
$(TEXBUILD)/%.pdf: %.tex $(TEXBUILD)/mahjong.sty tiles
	$(LATEXMK) $<
	$(LATEXMK) $<

%.gls: %.glo
	makeindex -s gglo.ist -o $@ $<

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

$(TDSDOC)/LICENSE: LICENSE
	$(dir_guard)
	cp $< $@

$(TDSSRC)/mahjong.dtx: mahjong.dtx
	$(dir_guard)
	cp $< $@

$(TDSSRC)/mahjong.ins: mahjong.ins
	$(dir_guard)
	cp $< $@

$(TDSSRC)/Makefile: Makefile
	$(dir_guard)
	cp $< $@

$(TDSTEX)/%.sty: $(TEXBUILD)/%.sty
	$(dir_guard)
	cp $< $@

$(TDSTEX)/tiles: tiles
	cp -r $< $@

# Create TDS zip and moved it to CTAN staging area
$(CTAN)/mahjong.tds.zip: $(TDSDOC)/mahjong.pdf $(TDSDOC)/mahjong-code.pdf
$(CTAN)/mahjong.tds.zip: $(TDSDOC)/mahjong.tex $(TDSDOC)/mahjong-code.tex
$(CTAN)/mahjong.tds.zip: $(TDSDOC)/README.md $(TDSDOC)/LICENSE
$(CTAN)/mahjong.tds.zip: $(TDSSRC)/mahjong.ins $(TDSSRC)/mahjong.dtx $(TDSSRC)/Makefile
$(CTAN)/mahjong.tds.zip: $(TDSTEX)/mahjong.sty $(TDSTEX)/tiles
	$(dir_guard)
	cd $(TDS) && $(ZIP) $(@F) *
	mv $(TDS)/$(@F) $@

# Move everything to CTAN staging area
$(CTAN_MAHJONG)/%.pdf: $(TDSDOC)/%.pdf
	$(dir_guard)
	cp $< $@

$(CTAN_MAHJONG)/%.tex: $(TDSDOC)/%.tex
	$(dir_guard)
	cp $< $@

$(CTAN_MAHJONG)/%: %
	$(dir_guard)
	cp -r $< $@

# Create final zip archive for upload to CTAN
$(OUT)/mahjong-ctan.zip: $(CTAN_MAHJONG)/mahjong.tex $(CTAN_MAHJONG)/mahjong.pdf
$(OUT)/mahjong-ctan.zip: $(CTAN_MAHJONG)/mahjong-code.tex $(CTAN_MAHJONG)/mahjong-code.pdf
$(OUT)/mahjong-ctan.zip: $(CTAN_MAHJONG)/README.md $(CTAN_MAHJONG)/LICENSE
$(OUT)/mahjong-ctan.zip: $(CTAN_MAHJONG)/mahjong.dtx $(CTAN_MAHJONG)/mahjong.ins
$(OUT)/mahjong-ctan.zip: $(CTAN_MAHJONG)/Makefile
$(OUT)/mahjong-ctan.zip: $(CTAN_MAHJONG)/tiles $(CTAN)/mahjong.tds.zip
	$(dir_guard)
	cd $(CTAN) && $(ZIP) $(@F) ./*
	mv $(CTAN)/$(@F) $@