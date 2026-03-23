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
	$(PAPERDIR)/tables/did-income-ethnic-year.tex \
	$(PAPERDIR)/tables/did-wage-deciles-year.tex

tables: $(TABLES)

$(PAPERDIR)/tables/sum-descriptive.tex: sum-descriptive.do read-enighyear.do $(DATA_YEAR) | $(PAPERDIR)/tables log
	ln -sf /dev/null $(<:.do=.log) && stata-mp -e $<

$(PAPERDIR)/tables/did-wage-hli-year.tex: did-wage-ethnic.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/tables log
	ln -sf /dev/null $(<:.do=.log) && stata-mp -e $<

$(PAPERDIR)/tables/did-income-ethnic-year.tex: did-income-ethnic.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/tables log
	ln -sf /dev/null $(<:.do=.log) && stata-mp -e $<

$(PAPERDIR)/tables/did-wage-deciles-year.tex: did-wage-deciles.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/tables log
	ln -sf /dev/null $(<:.do=.log) && stata-mp -e $<

#################################################
############## Figures — Stata ##################
#################################################

figures: stata_figs r_figs python_figs

stata_figs: \
	$(PAPERDIR)/figures/plot-event-wage-hli-nonind-year.png \
	$(PAPERDIR)/figures/plot-event-income-hli-nonind-year.png \
	$(PAPERDIR)/figures/plot-event-wage-centiles-year.png \
	$(PAPERDIR)/figures/plot-kernel-all.png

$(PAPERDIR)/figures/plot-event-wage-hli-nonind-year.png: plot-event-wage-ethnic.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/figures log
	ln -sf /dev/null $(<:.do=.log) && stata-mp -e $<

$(PAPERDIR)/figures/plot-event-wage-centiles-year.png: plot-event-wage-centiles.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/figures log
	ln -sf /dev/null $(<:.do=.log) && stata-mp -e $<

$(PAPERDIR)/figures/plot-event-income-hli-nonind-year.png: plot-event-income-ethnic.do $(READERS) $(DATA_YEAR) $(DATA_MONTH) | $(PAPERDIR)/figures log
	ln -sf /dev/null $(<:.do=.log) && stata-mp -e $<

$(PAPERDIR)/figures/plot-kernel-all.png: plot-densities.do read-enighyear.do $(DATA_YEAR) | $(PAPERDIR)/figures log
	ln -sf /dev/null $(<:.do=.log) && stata-mp -e $<

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
