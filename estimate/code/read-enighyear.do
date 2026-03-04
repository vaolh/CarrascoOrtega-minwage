*************************************************
*************** Read ENIGH Year *****************
*************************************************

*** REPLICATION FILE: read-enighyear
*** STATA VERSION: StataNow 19.5
*** AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
*** DATE: 2026-03-03

*  Loads the yearly cross-section produced by
*  data/clean/code/enigh-year.R, generates derived
*  variables and sets the $controls global.

*  Called by every analysis do-file:
*     do read-enighyear.do

*************************************************
****************** Load Data ********************
*************************************************

use "../input/enigh-year.dta", clear

ssc install require, replace
ssc install estout, replace

* Install ftools (remove program if it existed previously)
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")

* Install reghdfe 6.x
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")

*************************************************
*************** Decode Factors ******************
*************************************************

* haven::write_dta stores R factors as labeled integers.
* Decode year and ent to recover original numeric values.

foreach v in year ent {
    capture decode `v', gen(_`v'_str)
    if _rc == 0 {
        destring _`v'_str, replace force
        drop `v'
        rename _`v'_str `v'
    }
}

*************************************************
*********** Generate Log Incomes ****************
*************************************************

gen lnw   = ln(ing_wages)            if ing_wages > 0
gen lni   = ln(ing_lab)              if ing_lab > 0
gen lnmon = ln(ing_mon)              if ing_mon > 0
gen lnr   = ln(ing_rentas)          if ing_rentas > 0
gen lnv   = ln(ing_ventas)          if ing_ventas > 0
gen lno   = ln(ing_other)           if ing_other > 0
gen lnn   = ln(ing_negocio)         if ing_negocio > 0
gen lnnwi = ln(ing_non_wage_income) if ing_non_wage_income > 0
gen lngt  = ln(ing_gov_transfers)   if ing_gov_transfers > 0
gen lnfc  = ln(ing_fin_capital)     if ing_fin_capital > 0

*************************************************
************ Derived Variables ******************
*************************************************

gen female = 1 - sexo
gen edadsq = edad_pob * edad_pob

label variable lnw   "Log Wages"
label variable lni   "Log Labor Income"
label variable lnmon "Log Monetary Income"
label variable lnr   "Log Rent Income"
label variable lnv   "Log Sales Income"
label variable lno   "Log Other Income"
label variable lnn   "Log Business Income"
label variable lnnwi "Log Non-Wage Income"
label variable lngt  "Log Government Transfers"
label variable lnfc  "Log Financial Capital Income"
label variable post  "Post-Treatment (year > 2018)"
label variable female "Female"
label variable edadsq "Age Squared"

*************************************************
***************** Controls **********************
*************************************************

global controls i.female edad_pob edadsq years_of_study hoursworked i.employed
