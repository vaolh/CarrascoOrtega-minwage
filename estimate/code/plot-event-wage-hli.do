*************************************************
***************** Clean Memory ******************
*************************************************

clear
cap clear
cap log close
set more off

*** REPLICATION FILE: plot-event-wage-hli
*** STATA VERSION: StataNow 19.5
*** AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
*** DATE: 2026-03-03

*************************************************
**************** Load + Globals *****************
*************************************************

do read-enighyear.do
cap mkdir "../output/figs"

*************************************************
**** Event Study: Wages by HLI Status **********
*************************************************

* Non-indigenous speakers
reghdfe lnw i.zlfn#ib2018.year $controls if indspeaker == 0, ///
    absorb(ubica_geo year) vce(cluster ubica_geo)
eststo graph1

* Indigenous speakers
reghdfe lnw i.zlfn#ib2018.year $controls if indspeaker == 1, ///
    absorb(ubica_geo year) vce(cluster ubica_geo)
eststo graph2

*************************************************
*************** Coefficient Plot ****************
*************************************************

coefplot ///
    (graph1, label("Non-Indigenous Speaker") ///
        connect(direct) lcolor(blue) lw(medthin) ///
        msize(small) mfcolor(blue) mlcolor(blue) mlw(thin) ///
        ciopts(recast(rcap) lcolor(blue) lw(thin))) ///
    (graph2, label("Indigenous Speaker") ///
        connect(direct) lcolor(red) lw(medthin) ///
        msize(small) mfcolor(red) mlcolor(red) mlw(thin) ///
        ciopts(recast(rcap) lcolor(red) lw(thin))) ///
    , keep(1.zlfn#*.year) vertical ///
    xline(1.5, lcolor(red) lpattern(dash)) ///
    yline(0, lw(thin) lpattern(solid)) ///
    ytitle("Coefficient Estimate on Log Wages") ///
    xtitle("Year") ///
    legend(order(2 "Non-Indigenous Speaker" 4 "Indigenous Speaker") ///
        position(11) ring(0) col(1)) ///
    xlabel(, valuelabel angle(0))

graph export "../output/figs/plot-event-wage-hli.png", replace width(4000) height(3000)
