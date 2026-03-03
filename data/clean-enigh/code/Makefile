all: ../output/enigh_year.RData ../output/enigh_year.dta

include ../../../generic.make

YEARS := 2016 2018 2020 2022 2024

# All ENIGH tables needed by enigh_year.R
INPUT_DTA := $(foreach year, $(YEARS), \
  ../input/ingresos$(year).dta \
  ../input/poblacion$(year).dta \
  ../input/concentradohogar$(year).dta \
  ../input/viviendas$(year).dta \
  ../input/trabajos$(year).dta \
  ../input/pobreza$(year).dta)

# ---------------------------------------------------------------------------
# 1. INPC deflator: json → csv
# ---------------------------------------------------------------------------

../output/inpc.csv: inpc_year.R ../input/inpc.json | ../output
	Rscript inpc_year.R

# ---------------------------------------------------------------------------
# 2. Yearly cross-section from ENIGH + poverty + INPC
# ---------------------------------------------------------------------------

../output/enigh_year.RData ../output/enigh_year.dta: enigh_year.R $(INPUT_DTA) ../output/inpc.csv | ../output
	Rscript enigh_year.R

# ---------------------------------------------------------------------------
# Symlinks: raw outputs → clean inputs
# ---------------------------------------------------------------------------

../input/%.dta: ../../raw/output/%.dta | ../input
	@if [ ! -e ../input ]; then mkdir -p ../input; fi
	@if [ ! -e $@ ]; then ln -sf $< $@; fi

../input/%.json: ../../raw/output/%.json | ../input
	@if [ ! -e ../input ]; then mkdir -p ../input; fi
	@if [ ! -e $@ ]; then ln -sf $< $@; fi
