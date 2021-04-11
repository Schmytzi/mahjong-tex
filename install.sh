#!/bin/sh
# Installs package into local TeX search path
prefix=$(kpsewhich -var-value TEXMFHOME)
unzip build/ctan/mahjong.tds.zip -d $prefix