all: inequality preliminaryplots preliminarydid

include ../../generic.make

# ---------------------------------------------------------------------------
# Input symlinks — RData files from the data/clean pipeline
# ---------------------------------------------------------------------------

../input/enigh_year.RData: | ../input
	ln -sf ../../data/clean/output/enigh_year.RData $@

# ---------------------------------------------------------------------------
# Inequality measures (deciles, centiles, Gini, Lorenz)
# ---------------------------------------------------------------------------

.PHONY: inequality

inequality: ../output/figs/centile_ictpc.jpeg

../output/figs/centile_ictpc.jpeg: inequality.R ../input/enigh_year.RData | ../output
	Rscript inequality.R

# ---------------------------------------------------------------------------
# Stata targets (legacy — uncomment if needed)
# ---------------------------------------------------------------------------

# ../input/enighdata.dta: | ../input
# 	ln -sf ../../data/clean/output/enighdata.dta ../input/enighdata.dta
#
# ../output/graph5.png ../output/graph6.png: ZLFNincomedidplot.do ../input/enighdata.dta | ../output
# 	stata-mp -e ZLFNincomedidplot.do

# ---------------------------------------------------------------------------
# R preliminary scripts
# ---------------------------------------------------------------------------

.PHONY: preliminaryplots preliminarydid

preliminaryplots: ../output/figs/min_wageZone_comp.jpeg

../output/figs/min_wageZone_comp.jpeg: preliminaryplots.R ../input/enigh_year.RData | ../output
	Rscript preliminaryplots.R

preliminarydid: ../output/preliminarydid.log

../output/preliminarydid.log: preliminarydid.R ../input/enigh_year.RData | ../output
	Rscript preliminarydid.R 2>&1 | tee $@