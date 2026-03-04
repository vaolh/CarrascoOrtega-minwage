### REPLICATION FILE: estimate/code/Makefile
### VERSION: GNU Make 3.81+
### AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
### DATE: 2026-03-03

all: tables figures

include ../../generic.make

#################################################
############### Input Symlinks ##################
#################################################

../input/enigh-year.dta: ../../data/clean/output/enigh-year.dta | ../input
	ln -sf $< $@

../input/enigh-year.RData: ../../data/clean/output/enigh-year.RData | ../input
	ln -sf $< $@

#################################################
############# Directory Creation ################
#################################################

../output/figs: | ../output
	mkdir -p $@

log:
	mkdir -p $@

#################################################
############### Tables (Stata) ##################
#################################################

.PHONY: tables

../output/tables:
	mkdir -p $@

TABLES := \
	../output/tables/sum-descriptive.tex \
	../output/tables/did-wage-hli.tex \
	../output/tables/did-wage-indig.tex \
	../output/tables/did-income-zlfn.tex \
	../output/tables/did-income-negoc.tex

tables: $(TABLES)

# Generic pattern rule: any .do → matching .tex in output/tables/
../output/tables/%.tex: %.do read-enighyear.do ../input/enigh-year.dta | ../output/tables log
	stata-mp -e $<
	@mv -f $(basename $<).log log/ 2>/dev/null || true

#################################################
############## Figures — Stata ##################
#################################################

.PHONY: figures stata_figs r_figs python_figs

figures: stata_figs r_figs python_figs

stata_figs: \
	../output/figs/plot-kernel-all.png \
	../output/figs/plot-event-wage-hli.png \
	../output/figs/plot-event-wage-indig.png \
	../output/figs/plot-event-income-hli.png

# Kernel density plots (one do-file, many outputs)
../output/figs/plot-kernel-all.png: plot-kernels.do read-enighyear.do ../input/enigh-year.dta | ../output/figs log
	stata-mp -e $<
	@mv -f plot-kernels.log log/ 2>/dev/null || true

../output/figs/plot-event-wage-hli.png: plot-event-wage-hli.do read-enighyear.do ../input/enigh-year.dta | ../output/figs log
	stata-mp -e $<
	@mv -f plot-event-wage-hli.log log/ 2>/dev/null || true

../output/figs/plot-event-wage-indig.png: plot-event-wage-indig.do read-enighyear.do ../input/enigh-year.dta | ../output/figs log
	stata-mp -e $<
	@mv -f plot-event-wage-indig.log log/ 2>/dev/null || true

# Two outputs from one do-file
../output/figs/plot-event-income-hli.png ../output/figs/plot-event-income-indig.png: plot-event-income.do read-enighyear.do ../input/enigh-year.dta | ../output/figs log
	stata-mp -e $<
	@mv -f plot-event-income.log log/ 2>/dev/null || true

#################################################
################ Figures — R ####################
#################################################

.PHONY: r_figs

r_figs: \
	../output/figs/sum-centile-ictpc.png \
	../output/figs/plot-density-zone.png

../output/figs/sum-centile-ictpc.png: sum-inequality.R ../input/enigh-year.RData | ../output/figs
	Rscript $<

../output/figs/plot-density-zone.png: plot-densities.R ../input/enigh-year.RData | ../output/figs
	Rscript $<

#################################################
############## Figures — Python #################
#################################################

.PHONY: python_figs

python_figs: ../output/figs/sum-gini-state-change.png

../output/figs/sum-gini-state-change.png: sum-mapgini.py ../input/enigh-year.dta | ../output/figs
	uv run python $<