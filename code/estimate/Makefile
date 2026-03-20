### REPLICATION FILE: code/estimate/Makefile
### VERSION: GNU Make 3.81+
### AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
### DATE: 2026-03-20

DATADIR  := ../../data
PAPERDIR := ../../paper
PYTHON   := ../../.venv/bin/python

DATA_YEAR  := $(DATADIR)/clean/enigh/enigh-year.dta
DATA_MONTH := $(DATADIR)/clean/enigh/enigh-month.dta
READERS    := read-enighyear.do read-enighmonth.do

all: tables figures

#################################################
############# Directory Creation ################
#################################################

$(PAPERDIR)/figures:
	mkdir -p $@

$(PAPERDIR)/tables:
	mkdir -p $@

log:
	mkdir -p $@

#################################################
############### Tables (Stata) ##################
#################################################

.PHONY: all tables figures stata_figs r_figs python_figs

TABLES := \
	$(PAPERDIR)/tables/sum-descriptive.tex \
	$(PAPERDIR)/tables/did-wage-hli-year.tex \
	$(PAPERDIR)/tables/did-wage-indig-year.tex \
	$(PAPERDIR)/tables/did-income-zlfn-year.tex \
	$(PAPERDIR)/tables/did-income-negoc-year.tex \
	$(PAPERDIR)/tables/did-wage-deciles-year.tex

tables: $(TABLES)

$(PAPERDIR)/tables/sum-descriptive.tex: sum-descriptive.do read-enighyear.do $(DATA_YEAR) | $(PAPERDIR)/tables log
	stata-mp -e $<
	@rm -f sum-descriptive.log

$(PAPERDIR)/tables/did-wage-hli-year.tex: did-wage-hli.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/tables log
	stata-mp -e $<
	@rm -f did-wage-hli.log

$(PAPERDIR)/tables/did-wage-indig-year.tex: did-wage-indig.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/tables log
	stata-mp -e $<
	@rm -f did-wage-indig.log

$(PAPERDIR)/tables/did-income-zlfn-year.tex: did-income-zlfn.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/tables log
	stata-mp -e $<
	@rm -f did-income-zlfn.log

$(PAPERDIR)/tables/did-income-negoc-year.tex: did-income-negoc.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/tables log
	stata-mp -e $<
	@rm -f did-income-negoc.log

$(PAPERDIR)/tables/did-wage-deciles-year.tex: did-wage-deciles.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/tables $(PAPERDIR)/figures log
	stata-mp -e $<
	@rm -f did-wage-deciles.log

#################################################
############## Figures — Stata ##################
#################################################

figures: stata_figs r_figs python_figs

stata_figs: \
	$(PAPERDIR)/figures/plot-event-wage-hli-year.png \
	$(PAPERDIR)/figures/plot-event-wage-indig-year.png \
	$(PAPERDIR)/figures/plot-event-income-hli-nonind-year.png \
	$(PAPERDIR)/figures/plot-kernel-all.png

$(PAPERDIR)/figures/plot-event-wage-hli-year.png: plot-event-wage-hli.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/figures log
	stata-mp -e $<
	@rm -f plot-event-wage-hli.log

$(PAPERDIR)/figures/plot-event-wage-indig-year.png: plot-event-wage-indig.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/figures log
	stata-mp -e $<
	@rm -f plot-event-wage-indig.log

$(PAPERDIR)/figures/plot-event-income-hli-nonind-year.png: plot-event-income.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/figures log
	stata-mp -e $<
	@rm -f plot-event-income.log

$(PAPERDIR)/figures/plot-kernel-all.png: plot-densities.do read-enighyear.do $(DATA_YEAR) | $(PAPERDIR)/figures log
	stata-mp -e $<
	@rm -f plot-densities.log

#################################################
################ Figures — R ####################
#################################################

r_figs: $(PAPERDIR)/figures/sum-centile-ictpc.png

$(PAPERDIR)/figures/sum-centile-ictpc.png: sum-inequality.R $(DATADIR)/clean/enigh/enigh-year.RData | $(PAPERDIR)/figures
	Rscript $<
	@rm -f Rplots.pdf

#################################################
############## Figures — Python #################
#################################################

python_figs: $(PAPERDIR)/figures/sum-gini-state-change.png

$(PAPERDIR)/figures/sum-gini-state-change.png: sum-mapgini.py $(DATA_YEAR) | $(PAPERDIR)/figures
	$(PYTHON) $<
