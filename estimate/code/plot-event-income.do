*************************************************
***************** Clean Memory ******************
*************************************************

clear
cap clear
cap log close
set more off

*** REPLICATION FILE: plot-event-income
*** STATA VERSION: StataNow 19.5
*** AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
*** DATE: 2026-03-03

*************************************************
**************** Load + Globals *****************
*************************************************

do read-enighyear.do
cap mkdir "../output/figs"

*************************************************
**** Event Study: Income by HLI Status *********
*************************************************

reghdfe lni ib2016.year##i.zlfn $controls if indspeaker == 0, ///
    absorb(ubica_geo) vce(cluster ubica_geo)
eststo graph1

reghdfe lni ib2016.year##i.zlfn $controls if indspeaker == 1, ///
    absorb(ubica_geo) vce(cluster ubica_geo)
eststo graph2

coefplot graph1 ///
    , keep(*.year#1.zlfn) vertical offset(0) ///
    rename(2018.year#1.zlfn = "2018" 2020.year#1.zlfn = "2020" ///
           2022.year#1.zlfn = "2022" 2024.year#1.zlfn = "2024") ///
    recast(connected) lcolor("31 119 180") mcolor("31 119 180") msymbol(circle) lw(medthin) msize(small) ///
    ciopts(recast(rarea) fcolor("31 119 180%30") lwidth(none)) ///
    xline(2.5, lcolor(gs10) lpattern(dash)) ///
    yline(0, lw(thin) lpattern(solid) lcolor(black)) ///
    ytitle("Coefficient Estimate on Log Income") ///
    xtitle("Year") ///
    title("Non-Indigenous Speaker", size(medium)) ///
    xlabel(, angle(0)) ///
    graphregion(color(white)) bgcolor(white) ///
    grid(glcolor(gs14) glwidth(thin))

graph export "../output/figs/plot-event-income-hli-nonind.png", replace width(4000) height(3000)

coefplot graph2 ///
    , keep(*.year#1.zlfn) vertical offset(0) ///
    rename(2018.year#1.zlfn = "2018" 2020.year#1.zlfn = "2020" ///
           2022.year#1.zlfn = "2022" 2024.year#1.zlfn = "2024") ///
    recast(connected) lcolor("214 39 40") mcolor("214 39 40") msymbol(circle) lw(medthin) msize(small) ///
    ciopts(recast(rarea) fcolor("214 39 40%30") lwidth(none)) ///
    xline(2.5, lcolor(gs10) lpattern(dash)) ///
    yline(0, lw(thin) lpattern(solid) lcolor(black)) ///
    ytitle("Coefficient Estimate on Log Income") ///
    xtitle("Year") ///
    title("Indigenous Speaker", size(medium)) ///
    xlabel(, angle(0)) ///
    graphregion(color(white)) bgcolor(white) ///
    grid(glcolor(gs14) glwidth(thin))

graph export "../output/figs/plot-event-income-hli-ind.png", replace width(4000) height(3000)

*************************************************
** Event Study: Income by Indigenous Identity ***
*************************************************

estimates clear

reghdfe lni ib2016.year##i.zlfn $controls if etnia == 0, ///
    absorb(ubica_geo) vce(cluster ubica_geo)
eststo graph3

reghdfe lni ib2016.year##i.zlfn $controls if etnia == 1, ///
    absorb(ubica_geo) vce(cluster ubica_geo)
eststo graph4

coefplot graph3 ///
    , keep(*.year#1.zlfn) vertical offset(0) ///
    rename(2018.year#1.zlfn = "2018" 2020.year#1.zlfn = "2020" ///
           2022.year#1.zlfn = "2022" 2024.year#1.zlfn = "2024") ///
    recast(connected) lcolor("31 119 180") mcolor("31 119 180") msymbol(circle) lw(medthin) msize(small) ///
    ciopts(recast(rarea) fcolor("31 119 180%30") lwidth(none)) ///
    xline(2.5, lcolor(gs10) lpattern(dash)) ///
    yline(0, lw(thin) lpattern(solid) lcolor(black)) ///
    ytitle("Coefficient Estimate on Log Income") ///
    xtitle("Year") ///
    title("Non-Indigenous", size(medium)) ///
    xlabel(, angle(0)) ///
    graphregion(color(white)) bgcolor(white) ///
    grid(glcolor(gs14) glwidth(thin))

graph export "../output/figs/plot-event-income-indig-nonind.png", replace width(4000) height(3000)

coefplot graph4 ///
    , keep(*.year#1.zlfn) vertical offset(0) ///
    rename(2018.year#1.zlfn = "2018" 2020.year#1.zlfn = "2020" ///
           2022.year#1.zlfn = "2022" 2024.year#1.zlfn = "2024") ///
    recast(connected) lcolor("214 39 40") mcolor("214 39 40") msymbol(circle) lw(medthin) msize(small) ///
    ciopts(recast(rarea) fcolor("214 39 40%30") lwidth(none)) ///
    xline(2.5, lcolor(gs10) lpattern(dash)) ///
    yline(0, lw(thin) lpattern(solid) lcolor(black)) ///
    ytitle("Coefficient Estimate on Log Income") ///
    xtitle("Year") ///
    title("Indigenous", size(medium)) ///
    xlabel(, angle(0)) ///
    graphregion(color(white)) bgcolor(white) ///
    grid(glcolor(gs14) glwidth(thin))

graph export "../output/figs/plot-event-income-indig-ind.png", replace width(4000) height(3000)