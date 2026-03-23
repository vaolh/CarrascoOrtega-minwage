*************************************************
***************** Clean Memory ******************
*************************************************

clear
cap clear
cap log close
set more off

*** REPLICATION FILE: did-wage-ethnic
*** STATA VERSION: StataNow 19.5
*** AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
*** DATE: 2026-03-23

log using "log/did-wage-ethnic.log", replace text

*************************************************
******* DiD: Wages by Ethnicity / HLI ***********
*************************************************

foreach ds in year month {

do read-enigh`ds'.do
estimates clear

* All units — no controls
reghdfe lnw i.zlfn##i.post, absorb(ubica_geo year) vce(cluster ubica_geo)
     eststo t1m1
     estadd local controls       "N"
     estadd local hastimefe      "Y"
     estadd local hasmunicfe     "Y"

* All units — with controls
reghdfe lnw i.zlfn##i.post $controls, absorb(ubica_geo year) vce(cluster ubica_geo)
     eststo t1m2
     estadd local controls       "Y"
     estadd local hastimefe      "Y"
     estadd local hasmunicfe     "Y"

* Non-indigenous speakers — no controls
reghdfe lnw i.zlfn##i.post if indspeaker == 0, absorb(ubica_geo year) vce(cluster ubica_geo)
     eststo t1m3
     estadd local controls       "N"
     estadd local hastimefe      "Y"
     estadd local hasmunicfe     "Y"

* Non-indigenous speakers — with controls
reghdfe lnw i.zlfn##i.post $controls if indspeaker == 0, absorb(ubica_geo year) vce(cluster ubica_geo)
     eststo t1m4
     estadd local controls       "Y"
     estadd local hastimefe      "Y"
     estadd local hasmunicfe     "Y"

* Indigenous speakers — no controls
reghdfe lnw i.zlfn##i.post if indspeaker == 1, absorb(ubica_geo year) vce(cluster ubica_geo)
     eststo t1m5
     estadd local controls       "N"
     estadd local hastimefe      "Y"
     estadd local hasmunicfe     "Y"

* Indigenous speakers — with controls
reghdfe lnw i.zlfn##i.post $controls if indspeaker == 1, absorb(ubica_geo year) vce(cluster ubica_geo)
     eststo t1m6
     estadd local controls       "Y"
     estadd local hastimefe      "Y"
     estadd local hasmunicfe     "Y"

*************************************************
******* Export TeX Table: HLI Status ************
*************************************************

esttab t1m1 t1m2 t1m3 t1m4 t1m5 t1m6 ///
    using "../../paper/tables/did-wage-hli-`ds'.tex", replace label fragment ///
    nolines posthead(\cmidrule{2-7}) prefoot(\midrule) ///
    postfoot(\bottomrule \bottomrule) booktabs ///
    nonumbers mtitle("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") collabels(none) ///
    cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01) ///
    refcat(1.zlfn#1.post "ZLFN $\times$", nolabel) ///
    keep(1.zlfn#1.post) ///
    coeflabel(1.zlfn#1.post "{2016-2024}") ///
    stats(N controls hastimefe hasmunicfe, ///
        fmt(%11.0gc) label("Observations" "Controls" "Time FE" "Municipal FE")) onecell

*************************************************
***** Regressions by Indigenous Identity ********
*************************************************

estimates clear

* All units — no controls
reghdfe lnw i.zlfn##i.post, absorb(ubica_geo year) vce(cluster ubica_geo)
     eststo t2m1
     estadd local controls       "N"
     estadd local hastimefe      "Y"
     estadd local hasmunicfe     "Y"

* All units — with controls
reghdfe lnw i.zlfn##i.post $controls, absorb(ubica_geo year) vce(cluster ubica_geo)
     eststo t2m2
     estadd local controls       "Y"
     estadd local hastimefe      "Y"
     estadd local hasmunicfe     "Y"

* Non-indigenous (self-identified) — no controls
reghdfe lnw i.zlfn##i.post if etnia == 0, absorb(ubica_geo year) vce(cluster ubica_geo)
     eststo t2m3
     estadd local controls       "N"
     estadd local hastimefe      "Y"
     estadd local hasmunicfe     "Y"

* Non-indigenous (self-identified) — with controls
reghdfe lnw i.zlfn##i.post $controls if etnia == 0, absorb(ubica_geo year) vce(cluster ubica_geo)
     eststo t2m4
     estadd local controls       "Y"
     estadd local hastimefe      "Y"
     estadd local hasmunicfe     "Y"

* Indigenous (self-identified) — no controls
reghdfe lnw i.zlfn##i.post if etnia == 1, absorb(ubica_geo year) vce(cluster ubica_geo)
     eststo t2m5
     estadd local controls       "N"
     estadd local hastimefe      "Y"
     estadd local hasmunicfe     "Y"

* Indigenous (self-identified) — with controls
reghdfe lnw i.zlfn##i.post $controls if etnia == 1, absorb(ubica_geo year) vce(cluster ubica_geo)
     eststo t2m6
     estadd local controls       "Y"
     estadd local hastimefe      "Y"
     estadd local hasmunicfe     "Y"

*************************************************
***** Export TeX Table: Indigenous Identity ******
*************************************************

esttab t2m1 t2m2 t2m3 t2m4 t2m5 t2m6 ///
    using "../../paper/tables/did-wage-indig-`ds'.tex", replace label fragment ///
    nolines posthead(\cmidrule{2-7}) prefoot(\midrule) ///
    postfoot(\bottomrule \bottomrule) booktabs ///
    nonumbers mtitle("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") collabels(none) ///
    cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01) ///
    refcat(1.zlfn#1.post "ZLFN $\times$", nolabel) ///
    keep(1.zlfn#1.post) ///
    coeflabel(1.zlfn#1.post "{2016-2024}") ///
    stats(N controls hastimefe hasmunicfe, ///
        fmt(%11.0gc) label("Observations" "Controls" "Time FE" "Municipal FE")) onecell

}

cap log close
