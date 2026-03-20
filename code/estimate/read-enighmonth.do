*************************************************
*************** Read ENIGH Month ****************
*************************************************

*** REPLICATION FILE: read-enighmonth
*** STATA VERSION: StataNow 19.5
*** AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
*** DATE: 2026-03-20

*  Loads the monthly panel produced by
*  code/build/enigh-month.do, harmonizes variable
*  names to match read-enighyear.do interface.

*  Called inside foreach loops in analysis do-files:
*     do read-enighmonth.do

*************************************************
****************** Load Data ********************
*************************************************

use "../../data/clean/enigh/enigh-month.dta", clear

*************************************************
********** Harmonize Variable Names *************
*************************************************

rename zona_a zlfn
rename edad edad_pob
rename indigenous etnia

gen female = 1 - gender

gen post = (year > 2018)
label variable post "Post-Treatment (year > 2018)"
label variable female "Female"

*************************************************
***************** Controls **********************
*************************************************

global controls i.female edad_pob edadsq years_of_study hoursworked i.employed
