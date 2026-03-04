### REPLICATION FILE: data/clean/code/Makefile
### VERSION: GNU Make 3.81+
### AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
### DATE: 2026-03-03

all: ../output/enigh-year.RData ../output/enigh-year.dta

include ../../../generic.make

YEARS := 2016 2018 2020 2022 2024

# All ENIGH tables needed by enigh-year.R
INPUT_DTA := $(foreach year, $(YEARS), \
  ../input/ingresos$(year).dta \
  ../input/poblacion$(year).dta \
  ../input/concentradohogar$(year).dta \
  ../input/viviendas$(year).dta \
  ../input/trabajos$(year).dta \
  ../input/pobreza$(year).dta)

#################################################
############### INPC Deflator ###################
#################################################

../output/inpc.csv: inpc-year.R ../input/inpc.json | ../output
	Rscript inpc-year.R

#################################################
############# Yearly Cross-Section ##############
#################################################

../output/enigh-year.RData ../output/enigh-year.dta: enigh-year.R $(INPUT_DTA) ../output/inpc.csv | ../output
	Rscript enigh-year.R

#################################################
############## Input Symlinks ###################
#################################################

../input/%.dta: ../../download/output/%.dta | ../input
	@if [ ! -e ../input ]; then mkdir -p ../input; fi
	@if [ ! -e $@ ]; then ln -sf $< $@; fi

../input/%.json: ../../download/output/%.json | ../input
	@if [ ! -e ../input ]; then mkdir -p ../input; fi
	@if [ ! -e $@ ]; then ln -sf $< $@; fi
