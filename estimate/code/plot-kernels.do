*************************************************
***************** Clean Memory ******************
*************************************************

clear
cap clear
cap log close
set more off

*** REPLICATION FILE: plot-kernels
*** STATA VERSION: StataNow 19.5
*** AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
*** DATE: 2026-03-03

*************************************************
**************** Load + Globals *****************
*************************************************

do read-enighyear.do
cap mkdir "../output/figs"

*************************************************
*********** Graph: All Years Combined ***********
*************************************************

twoway (kdensity lni if year == 2016, bw(0.4) lcolor(blue) lwidth(vthin) ///
             legend(label(1 "ENIGH 2016"))) ///
       (kdensity lni if year == 2018, bw(0.4) lcolor(red) lwidth(vthin) ///
             legend(label(2 "ENIGH 2018"))) ///
       (kdensity lni if year == 2020, bw(0.4) lcolor(green) lwidth(vthin) ///
             legend(label(3 "ENIGH 2020"))) ///
       (kdensity lni if year == 2022, bw(0.4) lcolor(magenta) lwidth(vthin) ///
             legend(label(4 "ENIGH 2022"))) ///
       (kdensity lni if year == 2024, bw(0.4) lcolor(orange) lwidth(vthin) ///
             legend(label(5 "ENIGH 2024"))), ///
       xlabel(-2(2.5)16.5, grid) ///
       ylabel(, grid) ///
       xtitle("") ///
       ytitle("Log Average Labor Income") ///
       legend(order(1 "2016" 2 "2018" 3 "2020" 4 "2022" 5 "2024") ///
              position(1) ring(0) colfirst)
graph export "../output/figs/plot-kernel-all.png", replace width(4000) height(3000)

*************************************************
***** Graphs: By Indigenous Speaker by Year *****
*************************************************

* 2016
twoway (kdensity lni if year == 2016 & indspeaker == 1, bw(0.4) lcolor(blue) lpattern(dash) lwidth(vthin)) ///
       (kdensity lni if year == 2016 & indspeaker == 0, bw(0.4) lcolor(blue) lpattern(solid) lwidth(vthin)), ///
       xlabel(-2(2.5)16.5, grid) ylabel(, grid) xtitle("") ///
       ytitle("Log Average Labor Income") ///
       legend(order(1 "Indigenous (2016)" 2 "Non-Indigenous (2016)") position(1) ring(0) colfirst)
graph export "../output/figs/plot-kernel-2016.png", replace width(4000) height(3000)

* 2018
twoway (kdensity lni if year == 2018 & indspeaker == 1, bw(0.4) lcolor(blue) lpattern(dash) lwidth(vthin)) ///
       (kdensity lni if year == 2018 & indspeaker == 0, bw(0.4) lcolor(blue) lpattern(solid) lwidth(vthin)), ///
       xlabel(-2(2.5)16.5, grid) ylabel(, grid) xtitle("") ///
       ytitle("Log Average Labor Income") ///
       legend(order(1 "Indigenous (2018)" 2 "Non-Indigenous (2018)") position(1) ring(0) colfirst)
graph export "../output/figs/plot-kernel-2018.png", replace width(4000) height(3000)

* 2020
twoway (kdensity lni if year == 2020 & indspeaker == 1, bw(0.4) lcolor(blue) lpattern(dash) lwidth(vthin)) ///
       (kdensity lni if year == 2020 & indspeaker == 0, bw(0.4) lcolor(blue) lpattern(solid) lwidth(vthin)), ///
       xlabel(-2(2.5)16.5, grid) ylabel(, grid) xtitle("") ///
       ytitle("Log Average Labor Income") ///
       legend(order(1 "Indigenous (2020)" 2 "Non-Indigenous (2020)") position(1) ring(0) colfirst)
graph export "../output/figs/plot-kernel-2020.png", replace width(4000) height(3000)

* 2022
twoway (kdensity lni if year == 2022 & indspeaker == 1, bw(0.4) lcolor(blue) lpattern(dash) lwidth(vthin)) ///
       (kdensity lni if year == 2022 & indspeaker == 0, bw(0.4) lcolor(blue) lpattern(solid) lwidth(vthin)), ///
       xlabel(-2(2.5)16.5, grid) ylabel(, grid) xtitle("") ///
       ytitle("Log Average Labor Income") ///
       legend(order(1 "Indigenous (2022)" 2 "Non-Indigenous (2022)") position(11) ring(0) colfirst)
graph export "../output/figs/plot-kernel-2022.png", replace width(4000) height(3000)

* 2024
twoway (kdensity lni if year == 2024 & indspeaker == 1, bw(0.4) lcolor(blue) lpattern(dash) lwidth(vthin)) ///
       (kdensity lni if year == 2024 & indspeaker == 0, bw(0.4) lcolor(blue) lpattern(solid) lwidth(vthin)), ///
       xlabel(-2(2.5)16.5, grid) ylabel(, grid) xtitle("") ///
       ytitle("Log Average Labor Income") ///
       legend(order(1 "Indigenous (2024)" 2 "Non-Indigenous (2024)") position(11) ring(0) colfirst)
graph export "../output/figs/plot-kernel-2024.png", replace width(4000) height(3000)
