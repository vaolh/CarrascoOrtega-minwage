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

.PHONY: all tables figures stata_figs r_figs python_figs clean

TABLES := \
	$(PAPERDIR)/tables/sum-descriptive.tex \
	$(PAPERDIR)/tables/did-wage-ethnic-year.tex \
	$(PAPERDIR)/tables/did-income-ethnic-year.tex \
	$(PAPERDIR)/tables/did-wage-deciles-year.tex \
	$(PAPERDIR)/tables/did-wage-informality-year.tex \
	$(PAPERDIR)/tables/did-wage-sector-year.tex

tables: $(TABLES)

$(PAPERDIR)/tables/sum-descriptive.tex: sum-descriptive.do read-enighyear.do $(DATA_YEAR) | $(PAPERDIR)/tables log
	stata-mp -e $<
	@rm -f $(<:.do=.log)

$(PAPERDIR)/tables/did-wage-ethnic-year.tex: did-wage-ethnic.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/tables log
	stata-mp -e $<
	@rm -f $(<:.do=.log)

$(PAPERDIR)/tables/did-income-ethnic-year.tex: did-income-ethnic.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/tables log
	stata-mp -e $<
	@rm -f $(<:.do=.log)

$(PAPERDIR)/tables/did-wage-deciles-year.tex: did-wage-deciles.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/tables log
	stata-mp -e $<
	@rm -f $(<:.do=.log)

$(PAPERDIR)/tables/did-wage-informality-year.tex: did-wage-informality.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/tables log
	stata-mp -e $<
	@rm -f $(<:.do=.log)

$(PAPERDIR)/tables/did-wage-sector-year.tex: did-wage-sector.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/tables log
	stata-mp -e $<
	@rm -f $(<:.do=.log)

#################################################
############## Figures — Stata ##################
#################################################

figures: stata_figs r_figs python_figs

stata_figs: \
	$(PAPERDIR)/figures/plot-event-wage-hli-nonind-year.png \
	$(PAPERDIR)/figures/plot-event-income-hli-nonind-year.png \
	$(PAPERDIR)/figures/plot-event-wage-centiles-year.png \
	$(PAPERDIR)/figures/plot-kernel-all.png \
	$(PAPERDIR)/figures/plot-density-wages-ethnic-pretreat.png

$(PAPERDIR)/figures/plot-event-wage-hli-nonind-year.png: plot-event-wage-ethnic.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/figures log
	stata-mp -e $<
	@rm -f $(<:.do=.log)

$(PAPERDIR)/figures/plot-event-wage-centiles-year.png: plot-event-wage-centiles.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/figures log
	stata-mp -e $<
	@rm -f $(<:.do=.log)

$(PAPERDIR)/figures/plot-event-income-hli-nonind-year.png: plot-event-income-ethnic.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/figures log
	stata-mp -e $<
	@rm -f $(<:.do=.log)

$(PAPERDIR)/figures/plot-kernel-all.png: plot-densities.do read-enighyear.do $(DATA_YEAR) | $(PAPERDIR)/figures log
	stata-mp -e $<
	@rm -f $(<:.do=.log)

$(PAPERDIR)/figures/plot-density-wages-ethnic-pretreat.png: $(PAPERDIR)/figures/plot-kernel-all.png
	@rm -f $(<:.do=.log)

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

#################################################
##################### Clean #####################
#################################################

clean:
	@rm -f *.log Rplots.pdf
