
import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIByN_GovFin.csv", clear

do 1I_Proc_GovFin.do

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"




/* Panel: Scaled by revenue */

{

// Pooling all governments

local outfile =  "../Slides/tabs/DID_GovFin_toexp.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

reghdfe totalinterestondebt_toexp treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Interest Paid/","Exp. (in %)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

local coef_totalinterestondebt_toexp = _b[treatedXpost]
local coef_totalinterestondebt_toexp : display %-9.1f `coef_totalinterestondebt_toexp'
file open myfile using "../Slides/nums/coef_totalinterestondebt_toexp.tex", write replace
file write myfile "`coef_totalinterestondebt_toexp'"
file close myfile

reghdfe totalltdissued_toexp treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("New Issuance/","Exp. (in %)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

local coef_totalltdissued_toexp = _b[treatedXpost]
local coef_totalltdissued_toexp : display %-9.1f `coef_totalltdissued_toexp'
file open myfile using "../Slides/nums/coef_totalltdissued_toexp.tex", write replace
file write myfile "`coef_totalltdissued_toexp'"
file close myfile

local abs_coef_totalltdissued_toexp = -_b[treatedXpost]
local abs_coef_totalltdissued_toexp : display %-9.1f `abs_coef_totalltdissued_toexp'
file open myfile using "../Slides/nums/abs_coef_totalltdissued_toexp.tex", write replace
file write myfile "`abs_coef_totalltdissued_toexp'"
file close myfile

reghdfe totaltaxes_toexp treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Total Taxes/","Exp. (in %)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

local coef_totaltaxes_toexp = _b[treatedXpost]
local coef_totaltaxes_toexp : display %-9.1f `coef_totaltaxes_toexp'
file open myfile using "../Slides/nums/coef_totaltaxes_toexp.tex", write replace
file write myfile "`coef_totaltaxes_toexp'"
file close myfile

reghdfe propertytax_toexp treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Property Tax/","Exp. (in %)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

local coef_propertytax_toexp = _b[treatedXpost]
local coef_propertytax_toexp : display %-9.1f `coef_propertytax_toexp'
file open myfile using "../Slides/nums/coef_propertytax_toexp.tex", write replace
file write myfile "`coef_propertytax_toexp'"
file close myfile

reghdfe totaligrevenue_toexp treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Inter-Gov. Rev./","Exp. (in %)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

local coef_totaligrevenue_toexp = _b[treatedXpost]
local coef_totaligrevenue_toexp : display %-9.1f `coef_totaligrevenue_toexp'
file open myfile using "../Slides/nums/coef_totaligrevenue_toexp.tex", write replace
file write myfile "`coef_totaligrevenue_toexp'"
file close myfile

local abs_coef_totaligrevenue_toexp = -_b[treatedXpost]
local abs_coef_totaligrevenue_toexp : display %-9.1f `abs_coef_totaligrevenue_toexp'
file open myfile using "../Slides/nums/abs_coef_totaligrevenue_toexp.tex", write replace
file write myfile "`abs_coef_totaligrevenue_toexp'"
file close myfile

reghdfe deficit_ratio treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Deficit Ratio","(in %)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

local coef_deficit_ratio = _b[treatedXpost]
local coef_deficit_ratio : display %-9.1f `coef_deficit_ratio'
file open myfile using "../Slides/nums/coef_deficit_ratio.tex", write replace
file write myfile "`coef_deficit_ratio'"
file close myfile

local abs_coef_deficit_ratio = -_b[treatedXpost]
local abs_coef_deficit_ratio : display %-9.1f `abs_coef_deficit_ratio'
file open myfile using "../Slides/nums/abs_coef_deficit_ratio.tex", write replace
file write myfile "`abs_coef_deficit_ratio'"
file close myfile

// Separating two kinds of governments

local outfile =  "../Slides/tabs/DID_GovFin_toexp_SDorNonSD.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

gen is_schooldistrict = typecode==5
gen is_not_schooldistrict = typecode!=5

gen TXPXis_schooldistrict = treatedXpost*is_schooldistrict
gen TXPXis_not_schooldistrict = treatedXpost*is_not_schooldistrict

label var TXPXis_schooldistrict "Treated $\times$ Post $\times$ Is School Dist."
label var TXPXis_not_schooldistrict "Treated $\times$ Post $\times$ Is Other Gov."

reghdfe totalinterestondebt_toexp (is_schooldistrict is_not_schooldistrict)##(treated post) TXPXis_schooldistrict TXPXis_not_schooldistrict, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) replace label keep(TXPXis_schooldistrict TXPXis_not_schooldistrict) `outputoptions' ctitle("Interest Paid/","Exp. (in %)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe totalltdissued_toexp (is_schooldistrict is_not_schooldistrict)##(treated post) TXPXis_schooldistrict TXPXis_not_schooldistrict, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(TXPXis_schooldistrict TXPXis_not_schooldistrict) `outputoptions' ctitle("New Issuance/","Exp. (in %)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe totaltaxes_toexp (is_schooldistrict is_not_schooldistrict)##(treated post) TXPXis_schooldistrict TXPXis_not_schooldistrict, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(TXPXis_schooldistrict TXPXis_not_schooldistrict) `outputoptions' ctitle("Total Taxes/","Exp. (in %)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe propertytax_toexp (is_schooldistrict is_not_schooldistrict)##(treated post) TXPXis_schooldistrict TXPXis_not_schooldistrict, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(TXPXis_schooldistrict TXPXis_not_schooldistrict) `outputoptions' ctitle("Property Tax/","Exp. (in %)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe totaligrevenue_toexp (is_schooldistrict is_not_schooldistrict)##(treated post) TXPXis_schooldistrict TXPXis_not_schooldistrict, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(TXPXis_schooldistrict TXPXis_not_schooldistrict) `outputoptions' ctitle("Inter-Gov. Rev./","Exp. (in %)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe deficit_ratio (is_schooldistrict is_not_schooldistrict)##(treated post) TXPXis_schooldistrict TXPXis_not_schooldistrict, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(TXPXis_schooldistrict TXPXis_not_schooldistrict) `outputoptions' ctitle("Deficit Ratio","(in %)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

}




/* Panel: Per capita dollar amount */

{

// For school district

local outfile =  "../Slides/tabs/DID_GovFin_PC_SD.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

reghdfe totalinterestondebt_pe treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Interest Paid","Per Student") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe totalltdissued_pe treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("New Issuance","Per Student") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe totaltaxes_pe treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Total Taxes","Per Student") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe propertytax_pe treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Property Taxes","Per Student") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe totaligrevenue_pe treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Inter-Gov. Rev.","Per Student") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe deficit_pe treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Deficit","Per Student") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe totalrevenue_pe treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Rev.","Per Student") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe totalexpenditure_pe treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Exp.","Per Student") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

// For non-school district

local outfile =  "../Slides/tabs/DID_GovFin_PC_NonSD.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

reghdfe totalinterestondebt_pc treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Interest Paid","Per Capita") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe totalltdissued_pc treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("New Issuance","Per Capita") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe totaltaxes_pc treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Total Taxes","Per Capita") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe propertytax_pc treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Property Taxes","Per Capita") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe totaligrevenue_pc treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Inter-Gov. Rev.","Per Capita") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe deficit_pc treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Deficit","Per Capita") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe totalrevenue_pc treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Rev.","Per Capita") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe totalexpenditure_pc treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Exp.","Per Capita") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

}




/* Panel: Per capita dollar amount, logged */

{

local outfile =  "../Slides/tabs/DID_GovFin_Logged.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

reghdfe log_totalinterestondebt_pc treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("log Interest Paid","Per Capita+1") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe log_totalltdissued_pc treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("log New Issuance","Per Capita+1") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe log_totaltaxes_pc treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("log Total Taxes","Per Capita+1") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe log_propertytax_pc treated post treatedXpost, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("log Property Taxes","Per Capita+1") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

}




/* Panel: Which type of inter-government transfer is reduced? */

local outfile =  "../Slides/tabs/DID_GovFin_IG.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

reghdfe totalfedigrevenue_toexp (is_schooldistrict is_not_schooldistrict)##(treated post) TXPXis_schooldistrict TXPXis_not_schooldistrict, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) replace label keep(TXPXis_schooldistrict TXPXis_not_schooldistrict) `outputoptions' ctitle("Inter-Gov. Rev. from Federal/","Exp. (in %)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe totalstateigrevenue_toexp (is_schooldistrict is_not_schooldistrict)##(treated post) TXPXis_schooldistrict TXPXis_not_schooldistrict, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(TXPXis_schooldistrict TXPXis_not_schooldistrict) `outputoptions' ctitle("Inter-Gov. Rev. from State/","Exp. (in %)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")

reghdfe totlocaligrev_toexp (is_schooldistrict is_not_schooldistrict)##(treated post) TXPXis_schooldistrict TXPXis_not_schooldistrict, absorb(i.id i.calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(TXPXis_schooldistrict TXPXis_not_schooldistrict) `outputoptions' ctitle("Inter-Gov. Rev. from Local/","Exp. (in %)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Government FE", "Yes","Clustering","County")




/* Figures: Dynamics */

{

gen treatedXpostm2 = treated==1&year_to_merger==-2
gen treatedXpostm3 = treated==1&year_to_merger==-3
gen treatedXpostm4 = treated==1&year_to_merger==-4
gen treatedXpost0 = treated==1&year_to_merger==0
gen treatedXpost1 = treated==1&year_to_merger==1
gen treatedXpost2 = treated==1&year_to_merger==2
gen treatedXpost3 = treated==1&year_to_merger==3
gen treatedXpost4 = treated==1&year_to_merger==4

gen TXPm2Xis_schooldistrict = treatedXpostm2*is_schooldistrict
gen TXPm3Xis_schooldistrict = treatedXpostm3*is_schooldistrict
gen TXPm4Xis_schooldistrict = treatedXpostm4*is_schooldistrict
gen TXP0Xis_schooldistrict = treatedXpost0*is_schooldistrict
gen TXP1Xis_schooldistrict = treatedXpost1*is_schooldistrict
gen TXP2Xis_schooldistrict = treatedXpost2*is_schooldistrict
gen TXP3Xis_schooldistrict = treatedXpost3*is_schooldistrict
gen TXP4Xis_schooldistrict = treatedXpost4*is_schooldistrict

gen TXPm2Xis_not_schooldistrict = treatedXpostm2*is_not_schooldistrict
gen TXPm3Xis_not_schooldistrict = treatedXpostm3*is_not_schooldistrict
gen TXPm4Xis_not_schooldistrict = treatedXpostm4*is_not_schooldistrict
gen TXP0Xis_not_schooldistrict = treatedXpost0*is_not_schooldistrict
gen TXP1Xis_not_schooldistrict = treatedXpost1*is_not_schooldistrict
gen TXP2Xis_not_schooldistrict = treatedXpost2*is_not_schooldistrict
gen TXP3Xis_not_schooldistrict = treatedXpost3*is_not_schooldistrict
gen TXP4Xis_not_schooldistrict = treatedXpost4*is_not_schooldistrict

// Interest paid

preserve

reghdfe totalinterestondebt_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
, absorb(i.id calendar_year) cluster(i.county_code)

forvalues x = 2/4 {
local bm`x'= _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'] 
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x'= _b[treatedXpost`x']
local lb`x' = _b[treatedXpost`x'] - invttail(e(df_r),0.025)*_se[treatedXpost`x'] 
local ub`x' = _b[treatedXpost`x'] + invttail(e(df_r),0.025)*_se[treatedXpost`x']
}

clear
set obs 31
gen yeartochange = .
gen coef = .
gen upper = .
gen lower = .

replace yeartochange = -1 if _n == 1
replace coef = 0 if _n == 1
replace coef = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef = `bm`x'' if _n == `x'
replace lower = `lbm`x'' if _n == `x'
replace upper = `ubm`x'' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef = `b`x'' if _n == `x' + 5
replace lower = `lb`x'' if _n == `x' + 5
replace upper = `ub`x'' if _n == `x' + 5
}

sort yeartochange

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(green)) (rcap upper lower yeartochange, color(green)), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on Interest Paid/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in %)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_InterestToExp.eps", replace

restore

// Interest paid, by type of government

preserve

reghdfe totalinterestondebt_toexp (is_schooldistrict is_not_schooldistrict)##(treated post) ///
TXPm2Xis_schooldistrict TXPm3Xis_schooldistrict TXPm4Xis_schooldistrict ///
TXP0Xis_schooldistrict TXP1Xis_schooldistrict TXP2Xis_schooldistrict TXP3Xis_schooldistrict TXP4Xis_schooldistrict ///
TXPm2Xis_not_schooldistrict TXPm3Xis_not_schooldistrict TXPm4Xis_not_schooldistrict ///
TXP0Xis_not_schooldistrict TXP1Xis_not_schooldistrict TXP2Xis_not_schooldistrict TXP3Xis_not_schooldistrict TXP4Xis_not_schooldistrict ///
, absorb(i.id calendar_year) cluster(i.county_code)

forvalues x = 2/4 {
local bm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict]
local lbm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict] - invttail(e(df_r),0.025)*_se[TXPm`x'Xis_schooldistrict]
local ubm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict] + invttail(e(df_r),0.025)*_se[TXPm`x'Xis_schooldistrict]
}

forvalues x = 0/4 {
local b`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict]
local lb`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict] - invttail(e(df_r),0.025)*_se[TXP`x'Xis_schooldistrict] 
local ub`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict] + invttail(e(df_r),0.025)*_se[TXP`x'Xis_schooldistrict]
}

forvalues x = 2/4 {
local bm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict]
local lbm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict] - invttail(e(df_r),0.025)*_se[TXPm`x'Xis_not_schooldistrict]
local ubm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict] + invttail(e(df_r),0.025)*_se[TXPm`x'Xis_not_schooldistrict]
}

forvalues x = 0/4 {
local b`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict]
local lb`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict] - invttail(e(df_r),0.025)*_se[TXP`x'Xis_not_schooldistrict] 
local ub`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict] + invttail(e(df_r),0.025)*_se[TXP`x'Xis_not_schooldistrict]
}

clear
set obs 31
gen yeartochange = .
gen coefXis_schooldistrict = .
gen upperXis_schooldistrict = .
gen lowerXis_schooldistrict = .
gen coefXis_not_schooldistrict = .
gen upperXis_not_schooldistrict = .
gen lowerXis_not_schooldistrict = .

replace yeartochange = -1 if _n == 1
replace coefXis_schooldistrict = 0 if _n == 1
replace coefXis_not_schooldistrict = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coefXis_schooldistrict = `bm`x'Xis_schooldistrict' if _n == `x'
replace lowerXis_schooldistrict = `lbm`x'Xis_schooldistrict' if _n == `x'
replace upperXis_schooldistrict = `ubm`x'Xis_schooldistrict' if _n == `x'
replace coefXis_not_schooldistrict = `bm`x'Xis_not_schooldistrict' if _n == `x'
replace lowerXis_not_schooldistrict = `lbm`x'Xis_not_schooldistrict' if _n == `x'
replace upperXis_not_schooldistrict = `ubm`x'Xis_not_schooldistrict' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coefXis_schooldistrict = `b`x'Xis_schooldistrict' if _n == `x' + 5
replace lowerXis_schooldistrict = `lb`x'Xis_schooldistrict' if _n == `x' + 5
replace upperXis_schooldistrict = `ub`x'Xis_schooldistrict' if _n == `x' + 5
replace coefXis_not_schooldistrict = `b`x'Xis_not_schooldistrict' if _n == `x' + 5
replace lowerXis_not_schooldistrict = `lb`x'Xis_not_schooldistrict' if _n == `x' + 5
replace upperXis_not_schooldistrict = `ub`x'Xis_not_schooldistrict' if _n == `x' + 5
}

sort yeartochange

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coefXis_schooldistrict yeartochange, msize(small) mcolor(magenta)) ///
(rcap upperXis_schooldistrict lowerXis_schooldistrict yeartochange, color(magenta)) ///
(scatter coefXis_not_schooldistrict yeartochange2, msize(small) mcolor(blue)) ///
(rcap upperXis_not_schooldistrict lowerXis_not_schooldistrict yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("Effects on Interest Paid/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") label(3 "Municipality/township/county") label(4 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_InterestToExp_SDorNonSD.eps", replace

graph twoway ///
(scatter coefXis_schooldistrict yeartochange, msize(small) mcolor(magenta)) ///
(rcap upperXis_schooldistrict lowerXis_schooldistrict yeartochange, color(magenta)) ///
,xtitle("Year to M&A", size(large)) ytitle("Effects on Interest Paid/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_InterestToExp_SD.eps", replace

graph twoway ///
(scatter coefXis_not_schooldistrict yeartochange2, msize(small) mcolor(blue)) ///
(rcap upperXis_not_schooldistrict lowerXis_not_schooldistrict yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("Effects on Interest Paid/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Municipality/township/county") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_InterestToExp_NonSD.eps", replace

restore

// New issuance

preserve

reghdfe totalltdissued_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
, absorb(i.id calendar_year) cluster(i.county_code)

forvalues x = 2/4 {
local bm`x'= _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'] 
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x'= _b[treatedXpost`x']
local lb`x' = _b[treatedXpost`x'] - invttail(e(df_r),0.025)*_se[treatedXpost`x'] 
local ub`x' = _b[treatedXpost`x'] + invttail(e(df_r),0.025)*_se[treatedXpost`x']
}

clear
set obs 31
gen yeartochange = .
gen coef = .
gen upper = .
gen lower = .

replace yeartochange = -1 if _n == 1
replace coef = 0 if _n == 1
replace coef = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef = `bm`x'' if _n == `x'
replace lower = `lbm`x'' if _n == `x'
replace upper = `ubm`x'' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef = `b`x'' if _n == `x' + 5
replace lower = `lb`x'' if _n == `x' + 5
replace upper = `ub`x'' if _n == `x' + 5
}

sort yeartochange

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(green)) (rcap upper lower yeartochange, color(green)), ///
xtitle("Year to M&A", size(large)) ytitle("New Issuance/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in %)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_IssuanceToExp.eps", replace

restore

// New issuance, by type of government

preserve

reghdfe totalltdissued_toexp (is_schooldistrict is_not_schooldistrict)##(treated post) ///
TXPm2Xis_schooldistrict TXPm3Xis_schooldistrict TXPm4Xis_schooldistrict ///
TXP0Xis_schooldistrict TXP1Xis_schooldistrict TXP2Xis_schooldistrict TXP3Xis_schooldistrict TXP4Xis_schooldistrict ///
TXPm2Xis_not_schooldistrict TXPm3Xis_not_schooldistrict TXPm4Xis_not_schooldistrict ///
TXP0Xis_not_schooldistrict TXP1Xis_not_schooldistrict TXP2Xis_not_schooldistrict TXP3Xis_not_schooldistrict TXP4Xis_not_schooldistrict ///
, absorb(i.id calendar_year) cluster(i.county_code)

forvalues x = 2/4 {
local bm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict]
local lbm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict] - invttail(e(df_r),0.025)*_se[TXPm`x'Xis_schooldistrict]
local ubm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict] + invttail(e(df_r),0.025)*_se[TXPm`x'Xis_schooldistrict]
}

forvalues x = 0/4 {
local b`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict]
local lb`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict] - invttail(e(df_r),0.025)*_se[TXP`x'Xis_schooldistrict] 
local ub`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict] + invttail(e(df_r),0.025)*_se[TXP`x'Xis_schooldistrict]
}

forvalues x = 2/4 {
local bm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict]
local lbm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict] - invttail(e(df_r),0.025)*_se[TXPm`x'Xis_not_schooldistrict]
local ubm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict] + invttail(e(df_r),0.025)*_se[TXPm`x'Xis_not_schooldistrict]
}

forvalues x = 0/4 {
local b`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict]
local lb`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict] - invttail(e(df_r),0.025)*_se[TXP`x'Xis_not_schooldistrict] 
local ub`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict] + invttail(e(df_r),0.025)*_se[TXP`x'Xis_not_schooldistrict]
}

clear
set obs 31
gen yeartochange = .
gen coefXis_schooldistrict = .
gen upperXis_schooldistrict = .
gen lowerXis_schooldistrict = .
gen coefXis_not_schooldistrict = .
gen upperXis_not_schooldistrict = .
gen lowerXis_not_schooldistrict = .

replace yeartochange = -1 if _n == 1
replace coefXis_schooldistrict = 0 if _n == 1
replace coefXis_not_schooldistrict = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coefXis_schooldistrict = `bm`x'Xis_schooldistrict' if _n == `x'
replace lowerXis_schooldistrict = `lbm`x'Xis_schooldistrict' if _n == `x'
replace upperXis_schooldistrict = `ubm`x'Xis_schooldistrict' if _n == `x'
replace coefXis_not_schooldistrict = `bm`x'Xis_not_schooldistrict' if _n == `x'
replace lowerXis_not_schooldistrict = `lbm`x'Xis_not_schooldistrict' if _n == `x'
replace upperXis_not_schooldistrict = `ubm`x'Xis_not_schooldistrict' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coefXis_schooldistrict = `b`x'Xis_schooldistrict' if _n == `x' + 5
replace lowerXis_schooldistrict = `lb`x'Xis_schooldistrict' if _n == `x' + 5
replace upperXis_schooldistrict = `ub`x'Xis_schooldistrict' if _n == `x' + 5
replace coefXis_not_schooldistrict = `b`x'Xis_not_schooldistrict' if _n == `x' + 5
replace lowerXis_not_schooldistrict = `lb`x'Xis_not_schooldistrict' if _n == `x' + 5
replace upperXis_not_schooldistrict = `ub`x'Xis_not_schooldistrict' if _n == `x' + 5
}

sort yeartochange

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coefXis_schooldistrict yeartochange, msize(small) mcolor(magenta)) ///
(rcap upperXis_schooldistrict lowerXis_schooldistrict yeartochange, color(magenta)) ///
(scatter coefXis_not_schooldistrict yeartochange2, msize(small) mcolor(blue)) ///
(rcap upperXis_not_schooldistrict lowerXis_not_schooldistrict yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("New Issuance/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") label(3 "Municipality/township/county") label(4 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_IssuanceToExp_SDorNonSD.eps", replace

graph twoway ///
(scatter coefXis_schooldistrict yeartochange, msize(small) mcolor(magenta)) ///
(rcap upperXis_schooldistrict lowerXis_schooldistrict yeartochange, color(magenta)) ///
,xtitle("Year to M&A", size(large)) ytitle("New Issuance/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_IssuanceToExp_SD.eps", replace

graph twoway ///
(scatter coefXis_not_schooldistrict yeartochange2, msize(small) mcolor(blue)) ///
(rcap upperXis_not_schooldistrict lowerXis_not_schooldistrict yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("New Issuance/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Municipality/township/county") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_IssuanceToExp_NonSD.eps", replace

restore

// Deficit ratio

preserve

reghdfe deficit_ratio treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
, absorb(i.id calendar_year) cluster(i.county_code)

forvalues x = 2/4 {
local bm`x'= _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'] 
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x'= _b[treatedXpost`x']
local lb`x' = _b[treatedXpost`x'] - invttail(e(df_r),0.025)*_se[treatedXpost`x'] 
local ub`x' = _b[treatedXpost`x'] + invttail(e(df_r),0.025)*_se[treatedXpost`x']
}

clear
set obs 31
gen yeartochange = .
gen coef = .
gen upper = .
gen lower = .

replace yeartochange = -1 if _n == 1
replace coef = 0 if _n == 1
replace coef = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef = `bm`x'' if _n == `x'
replace lower = `lbm`x'' if _n == `x'
replace upper = `ubm`x'' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef = `b`x'' if _n == `x' + 5
replace lower = `lb`x'' if _n == `x' + 5
replace upper = `ub`x'' if _n == `x' + 5
}

sort yeartochange

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(green)) (rcap upper lower yeartochange, color(green)), ///
xtitle("Year to M&A", size(large)) ytitle("Deficit Ratio", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in %)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_DeficitRatio.eps", replace

restore

// Deficit ratio, by type of government

preserve

reghdfe deficit_ratio (is_schooldistrict is_not_schooldistrict)##(treated post) ///
TXPm2Xis_schooldistrict TXPm3Xis_schooldistrict TXPm4Xis_schooldistrict ///
TXP0Xis_schooldistrict TXP1Xis_schooldistrict TXP2Xis_schooldistrict TXP3Xis_schooldistrict TXP4Xis_schooldistrict ///
TXPm2Xis_not_schooldistrict TXPm3Xis_not_schooldistrict TXPm4Xis_not_schooldistrict ///
TXP0Xis_not_schooldistrict TXP1Xis_not_schooldistrict TXP2Xis_not_schooldistrict TXP3Xis_not_schooldistrict TXP4Xis_not_schooldistrict ///
, absorb(i.id calendar_year) cluster(i.county_code)

forvalues x = 2/4 {
local bm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict]
local lbm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict] - invttail(e(df_r),0.025)*_se[TXPm`x'Xis_schooldistrict]
local ubm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict] + invttail(e(df_r),0.025)*_se[TXPm`x'Xis_schooldistrict]
}

forvalues x = 0/4 {
local b`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict]
local lb`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict] - invttail(e(df_r),0.025)*_se[TXP`x'Xis_schooldistrict] 
local ub`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict] + invttail(e(df_r),0.025)*_se[TXP`x'Xis_schooldistrict]
}

forvalues x = 2/4 {
local bm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict]
local lbm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict] - invttail(e(df_r),0.025)*_se[TXPm`x'Xis_not_schooldistrict]
local ubm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict] + invttail(e(df_r),0.025)*_se[TXPm`x'Xis_not_schooldistrict]
}

forvalues x = 0/4 {
local b`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict]
local lb`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict] - invttail(e(df_r),0.025)*_se[TXP`x'Xis_not_schooldistrict] 
local ub`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict] + invttail(e(df_r),0.025)*_se[TXP`x'Xis_not_schooldistrict]
}

clear
set obs 31
gen yeartochange = .
gen coefXis_schooldistrict = .
gen upperXis_schooldistrict = .
gen lowerXis_schooldistrict = .
gen coefXis_not_schooldistrict = .
gen upperXis_not_schooldistrict = .
gen lowerXis_not_schooldistrict = .

replace yeartochange = -1 if _n == 1
replace coefXis_schooldistrict = 0 if _n == 1
replace coefXis_not_schooldistrict = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coefXis_schooldistrict = `bm`x'Xis_schooldistrict' if _n == `x'
replace lowerXis_schooldistrict = `lbm`x'Xis_schooldistrict' if _n == `x'
replace upperXis_schooldistrict = `ubm`x'Xis_schooldistrict' if _n == `x'
replace coefXis_not_schooldistrict = `bm`x'Xis_not_schooldistrict' if _n == `x'
replace lowerXis_not_schooldistrict = `lbm`x'Xis_not_schooldistrict' if _n == `x'
replace upperXis_not_schooldistrict = `ubm`x'Xis_not_schooldistrict' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coefXis_schooldistrict = `b`x'Xis_schooldistrict' if _n == `x' + 5
replace lowerXis_schooldistrict = `lb`x'Xis_schooldistrict' if _n == `x' + 5
replace upperXis_schooldistrict = `ub`x'Xis_schooldistrict' if _n == `x' + 5
replace coefXis_not_schooldistrict = `b`x'Xis_not_schooldistrict' if _n == `x' + 5
replace lowerXis_not_schooldistrict = `lb`x'Xis_not_schooldistrict' if _n == `x' + 5
replace upperXis_not_schooldistrict = `ub`x'Xis_not_schooldistrict' if _n == `x' + 5
}

sort yeartochange

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coefXis_schooldistrict yeartochange, msize(small) mcolor(magenta)) ///
(rcap upperXis_schooldistrict lowerXis_schooldistrict yeartochange, color(magenta)) ///
(scatter coefXis_not_schooldistrict yeartochange2, msize(small) mcolor(blue)) ///
(rcap upperXis_not_schooldistrict lowerXis_not_schooldistrict yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("Deficit Ratio", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") label(3 "Municipality/township/county") label(4 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_DeficitRatio_SDorNonSD.eps", replace

graph twoway ///
(scatter coefXis_schooldistrict yeartochange, msize(small) mcolor(magenta)) ///
(rcap upperXis_schooldistrict lowerXis_schooldistrict yeartochange, color(magenta)) ///
,xtitle("Year to M&A", size(large)) ytitle("Deficit Ratio", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_DeficitRatio_SD.eps", replace

graph twoway ///
(scatter coefXis_not_schooldistrict yeartochange2, msize(small) mcolor(blue)) ///
(rcap upperXis_not_schooldistrict lowerXis_not_schooldistrict yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("Deficit Ratio", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Municipality/township/county") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_DeficitRatio_NonSD.eps", replace

restore

// Total taxes

preserve

reghdfe totaltaxes_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
, absorb(i.id calendar_year) cluster(i.county_code)

forvalues x = 2/4 {
local bm`x'= _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'] 
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x'= _b[treatedXpost`x']
local lb`x' = _b[treatedXpost`x'] - invttail(e(df_r),0.025)*_se[treatedXpost`x'] 
local ub`x' = _b[treatedXpost`x'] + invttail(e(df_r),0.025)*_se[treatedXpost`x']
}

clear
set obs 31
gen yeartochange = .
gen coef = .
gen upper = .
gen lower = .

replace yeartochange = -1 if _n == 1
replace coef = 0 if _n == 1
replace coef = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef = `bm`x'' if _n == `x'
replace lower = `lbm`x'' if _n == `x'
replace upper = `ubm`x'' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef = `b`x'' if _n == `x' + 5
replace lower = `lb`x'' if _n == `x' + 5
replace upper = `ub`x'' if _n == `x' + 5
}

sort yeartochange

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(green)) (rcap upper lower yeartochange, color(green)), ///
xtitle("Year to M&A", size(large)) ytitle("Total Taxes/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in %)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_TotalTaxes.eps", replace

restore

// Total taxes, by type of government

preserve

reghdfe totaltaxes_toexp (is_schooldistrict is_not_schooldistrict)##(treated post) ///
TXPm2Xis_schooldistrict TXPm3Xis_schooldistrict TXPm4Xis_schooldistrict ///
TXP0Xis_schooldistrict TXP1Xis_schooldistrict TXP2Xis_schooldistrict TXP3Xis_schooldistrict TXP4Xis_schooldistrict ///
TXPm2Xis_not_schooldistrict TXPm3Xis_not_schooldistrict TXPm4Xis_not_schooldistrict ///
TXP0Xis_not_schooldistrict TXP1Xis_not_schooldistrict TXP2Xis_not_schooldistrict TXP3Xis_not_schooldistrict TXP4Xis_not_schooldistrict ///
, absorb(i.id calendar_year) cluster(i.county_code)

forvalues x = 2/4 {
local bm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict]
local lbm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict] - invttail(e(df_r),0.025)*_se[TXPm`x'Xis_schooldistrict]
local ubm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict] + invttail(e(df_r),0.025)*_se[TXPm`x'Xis_schooldistrict]
}

forvalues x = 0/4 {
local b`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict]
local lb`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict] - invttail(e(df_r),0.025)*_se[TXP`x'Xis_schooldistrict] 
local ub`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict] + invttail(e(df_r),0.025)*_se[TXP`x'Xis_schooldistrict]
}

forvalues x = 2/4 {
local bm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict]
local lbm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict] - invttail(e(df_r),0.025)*_se[TXPm`x'Xis_not_schooldistrict]
local ubm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict] + invttail(e(df_r),0.025)*_se[TXPm`x'Xis_not_schooldistrict]
}

forvalues x = 0/4 {
local b`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict]
local lb`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict] - invttail(e(df_r),0.025)*_se[TXP`x'Xis_not_schooldistrict] 
local ub`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict] + invttail(e(df_r),0.025)*_se[TXP`x'Xis_not_schooldistrict]
}

clear
set obs 31
gen yeartochange = .
gen coefXis_schooldistrict = .
gen upperXis_schooldistrict = .
gen lowerXis_schooldistrict = .
gen coefXis_not_schooldistrict = .
gen upperXis_not_schooldistrict = .
gen lowerXis_not_schooldistrict = .

replace yeartochange = -1 if _n == 1
replace coefXis_schooldistrict = 0 if _n == 1
replace coefXis_not_schooldistrict = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coefXis_schooldistrict = `bm`x'Xis_schooldistrict' if _n == `x'
replace lowerXis_schooldistrict = `lbm`x'Xis_schooldistrict' if _n == `x'
replace upperXis_schooldistrict = `ubm`x'Xis_schooldistrict' if _n == `x'
replace coefXis_not_schooldistrict = `bm`x'Xis_not_schooldistrict' if _n == `x'
replace lowerXis_not_schooldistrict = `lbm`x'Xis_not_schooldistrict' if _n == `x'
replace upperXis_not_schooldistrict = `ubm`x'Xis_not_schooldistrict' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coefXis_schooldistrict = `b`x'Xis_schooldistrict' if _n == `x' + 5
replace lowerXis_schooldistrict = `lb`x'Xis_schooldistrict' if _n == `x' + 5
replace upperXis_schooldistrict = `ub`x'Xis_schooldistrict' if _n == `x' + 5
replace coefXis_not_schooldistrict = `b`x'Xis_not_schooldistrict' if _n == `x' + 5
replace lowerXis_not_schooldistrict = `lb`x'Xis_not_schooldistrict' if _n == `x' + 5
replace upperXis_not_schooldistrict = `ub`x'Xis_not_schooldistrict' if _n == `x' + 5
}

sort yeartochange

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coefXis_schooldistrict yeartochange, msize(small) mcolor(magenta)) ///
(rcap upperXis_schooldistrict lowerXis_schooldistrict yeartochange, color(magenta)) ///
(scatter coefXis_not_schooldistrict yeartochange2, msize(small) mcolor(blue)) ///
(rcap upperXis_not_schooldistrict lowerXis_not_schooldistrict yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("Total Taxes/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") label(3 "Municipality/township/county") label(4 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_TotalTaxes_SDorNonSD.eps", replace

graph twoway ///
(scatter coefXis_schooldistrict yeartochange, msize(small) mcolor(magenta)) ///
(rcap upperXis_schooldistrict lowerXis_schooldistrict yeartochange, color(magenta)) ///
,xtitle("Year to M&A", size(large)) ytitle("Total Taxes/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_TotalTaxes_SD.eps", replace

graph twoway ///
(scatter coefXis_not_schooldistrict yeartochange2, msize(small) mcolor(blue)) ///
(rcap upperXis_not_schooldistrict lowerXis_not_schooldistrict yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("Total Taxes/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Municipality/township/county") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_TotalTaxes_NonSD.eps", replace

restore

// Property tax

preserve

reghdfe propertytax_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
, absorb(i.id calendar_year) cluster(i.county_code)

forvalues x = 2/4 {
local bm`x'= _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'] 
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x'= _b[treatedXpost`x']
local lb`x' = _b[treatedXpost`x'] - invttail(e(df_r),0.025)*_se[treatedXpost`x'] 
local ub`x' = _b[treatedXpost`x'] + invttail(e(df_r),0.025)*_se[treatedXpost`x']
}

clear
set obs 31
gen yeartochange = .
gen coef = .
gen upper = .
gen lower = .

replace yeartochange = -1 if _n == 1
replace coef = 0 if _n == 1
replace coef = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef = `bm`x'' if _n == `x'
replace lower = `lbm`x'' if _n == `x'
replace upper = `ubm`x'' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef = `b`x'' if _n == `x' + 5
replace lower = `lb`x'' if _n == `x' + 5
replace upper = `ub`x'' if _n == `x' + 5
}

sort yeartochange

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(green)) (rcap upper lower yeartochange, color(green)), ///
xtitle("Year to M&A", size(large)) ytitle("Property Tax/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in %)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_PropertyTax.eps", replace

restore

// Property tax, by type of government

preserve

reghdfe propertytax_toexp (is_schooldistrict is_not_schooldistrict)##(treated post) ///
TXPm2Xis_schooldistrict TXPm3Xis_schooldistrict TXPm4Xis_schooldistrict ///
TXP0Xis_schooldistrict TXP1Xis_schooldistrict TXP2Xis_schooldistrict TXP3Xis_schooldistrict TXP4Xis_schooldistrict ///
TXPm2Xis_not_schooldistrict TXPm3Xis_not_schooldistrict TXPm4Xis_not_schooldistrict ///
TXP0Xis_not_schooldistrict TXP1Xis_not_schooldistrict TXP2Xis_not_schooldistrict TXP3Xis_not_schooldistrict TXP4Xis_not_schooldistrict ///
, absorb(i.id calendar_year) cluster(i.county_code)

forvalues x = 2/4 {
local bm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict]
local lbm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict] - invttail(e(df_r),0.025)*_se[TXPm`x'Xis_schooldistrict]
local ubm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict] + invttail(e(df_r),0.025)*_se[TXPm`x'Xis_schooldistrict]
}

forvalues x = 0/4 {
local b`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict]
local lb`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict] - invttail(e(df_r),0.025)*_se[TXP`x'Xis_schooldistrict] 
local ub`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict] + invttail(e(df_r),0.025)*_se[TXP`x'Xis_schooldistrict]
}

forvalues x = 2/4 {
local bm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict]
local lbm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict] - invttail(e(df_r),0.025)*_se[TXPm`x'Xis_not_schooldistrict]
local ubm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict] + invttail(e(df_r),0.025)*_se[TXPm`x'Xis_not_schooldistrict]
}

forvalues x = 0/4 {
local b`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict]
local lb`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict] - invttail(e(df_r),0.025)*_se[TXP`x'Xis_not_schooldistrict] 
local ub`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict] + invttail(e(df_r),0.025)*_se[TXP`x'Xis_not_schooldistrict]
}

clear
set obs 31
gen yeartochange = .
gen coefXis_schooldistrict = .
gen upperXis_schooldistrict = .
gen lowerXis_schooldistrict = .
gen coefXis_not_schooldistrict = .
gen upperXis_not_schooldistrict = .
gen lowerXis_not_schooldistrict = .

replace yeartochange = -1 if _n == 1
replace coefXis_schooldistrict = 0 if _n == 1
replace coefXis_not_schooldistrict = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coefXis_schooldistrict = `bm`x'Xis_schooldistrict' if _n == `x'
replace lowerXis_schooldistrict = `lbm`x'Xis_schooldistrict' if _n == `x'
replace upperXis_schooldistrict = `ubm`x'Xis_schooldistrict' if _n == `x'
replace coefXis_not_schooldistrict = `bm`x'Xis_not_schooldistrict' if _n == `x'
replace lowerXis_not_schooldistrict = `lbm`x'Xis_not_schooldistrict' if _n == `x'
replace upperXis_not_schooldistrict = `ubm`x'Xis_not_schooldistrict' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coefXis_schooldistrict = `b`x'Xis_schooldistrict' if _n == `x' + 5
replace lowerXis_schooldistrict = `lb`x'Xis_schooldistrict' if _n == `x' + 5
replace upperXis_schooldistrict = `ub`x'Xis_schooldistrict' if _n == `x' + 5
replace coefXis_not_schooldistrict = `b`x'Xis_not_schooldistrict' if _n == `x' + 5
replace lowerXis_not_schooldistrict = `lb`x'Xis_not_schooldistrict' if _n == `x' + 5
replace upperXis_not_schooldistrict = `ub`x'Xis_not_schooldistrict' if _n == `x' + 5
}

sort yeartochange

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coefXis_schooldistrict yeartochange, msize(small) mcolor(magenta)) ///
(rcap upperXis_schooldistrict lowerXis_schooldistrict yeartochange, color(magenta)) ///
(scatter coefXis_not_schooldistrict yeartochange2, msize(small) mcolor(blue)) ///
(rcap upperXis_not_schooldistrict lowerXis_not_schooldistrict yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("Property Tax/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") label(3 "Municipality/township/county") label(4 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_PropertyTax_SDorNonSD.eps", replace

graph twoway ///
(scatter coefXis_schooldistrict yeartochange, msize(small) mcolor(magenta)) ///
(rcap upperXis_schooldistrict lowerXis_schooldistrict yeartochange, color(magenta)) ///
,xtitle("Year to M&A", size(large)) ytitle("Property Tax/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_PropertyTax_SD.eps", replace

graph twoway ///
(scatter coefXis_not_schooldistrict yeartochange2, msize(small) mcolor(blue)) ///
(rcap upperXis_not_schooldistrict lowerXis_not_schooldistrict yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("Property Tax/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Municipality/township/county") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_PropertyTax_NonSD.eps", replace

restore

// IG Revenue

preserve

reghdfe totaligrevenue_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
, absorb(i.id calendar_year) cluster(i.county_code)

forvalues x = 2/4 {
local bm`x'= _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'] 
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x'= _b[treatedXpost`x']
local lb`x' = _b[treatedXpost`x'] - invttail(e(df_r),0.025)*_se[treatedXpost`x'] 
local ub`x' = _b[treatedXpost`x'] + invttail(e(df_r),0.025)*_se[treatedXpost`x']
}

clear
set obs 31
gen yeartochange = .
gen coef = .
gen upper = .
gen lower = .

replace yeartochange = -1 if _n == 1
replace coef = 0 if _n == 1
replace coef = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef = `bm`x'' if _n == `x'
replace lower = `lbm`x'' if _n == `x'
replace upper = `ubm`x'' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef = `b`x'' if _n == `x' + 5
replace lower = `lb`x'' if _n == `x' + 5
replace upper = `ub`x'' if _n == `x' + 5
}

sort yeartochange

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(green)) (rcap upper lower yeartochange, color(green)), ///
xtitle("Year to M&A", size(large)) ytitle("Inter-Gov. Rev./Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in %)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_IGRev.eps", replace

restore

// IG Revenue, by type of government

preserve

reghdfe totaligrevenue_toexp (is_schooldistrict is_not_schooldistrict)##(treated post) ///
TXPm2Xis_schooldistrict TXPm3Xis_schooldistrict TXPm4Xis_schooldistrict ///
TXP0Xis_schooldistrict TXP1Xis_schooldistrict TXP2Xis_schooldistrict TXP3Xis_schooldistrict TXP4Xis_schooldistrict ///
TXPm2Xis_not_schooldistrict TXPm3Xis_not_schooldistrict TXPm4Xis_not_schooldistrict ///
TXP0Xis_not_schooldistrict TXP1Xis_not_schooldistrict TXP2Xis_not_schooldistrict TXP3Xis_not_schooldistrict TXP4Xis_not_schooldistrict ///
, absorb(i.id calendar_year) cluster(i.county_code)

forvalues x = 2/4 {
local bm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict]
local lbm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict] - invttail(e(df_r),0.025)*_se[TXPm`x'Xis_schooldistrict]
local ubm`x'Xis_schooldistrict = _b[TXPm`x'Xis_schooldistrict] + invttail(e(df_r),0.025)*_se[TXPm`x'Xis_schooldistrict]
}

forvalues x = 0/4 {
local b`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict]
local lb`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict] - invttail(e(df_r),0.025)*_se[TXP`x'Xis_schooldistrict] 
local ub`x'Xis_schooldistrict = _b[TXP`x'Xis_schooldistrict] + invttail(e(df_r),0.025)*_se[TXP`x'Xis_schooldistrict]
}

forvalues x = 2/4 {
local bm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict]
local lbm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict] - invttail(e(df_r),0.025)*_se[TXPm`x'Xis_not_schooldistrict]
local ubm`x'Xis_not_schooldistrict = _b[TXPm`x'Xis_not_schooldistrict] + invttail(e(df_r),0.025)*_se[TXPm`x'Xis_not_schooldistrict]
}

forvalues x = 0/4 {
local b`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict]
local lb`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict] - invttail(e(df_r),0.025)*_se[TXP`x'Xis_not_schooldistrict] 
local ub`x'Xis_not_schooldistrict = _b[TXP`x'Xis_not_schooldistrict] + invttail(e(df_r),0.025)*_se[TXP`x'Xis_not_schooldistrict]
}

clear
set obs 31
gen yeartochange = .
gen coefXis_schooldistrict = .
gen upperXis_schooldistrict = .
gen lowerXis_schooldistrict = .
gen coefXis_not_schooldistrict = .
gen upperXis_not_schooldistrict = .
gen lowerXis_not_schooldistrict = .

replace yeartochange = -1 if _n == 1
replace coefXis_schooldistrict = 0 if _n == 1
replace coefXis_not_schooldistrict = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coefXis_schooldistrict = `bm`x'Xis_schooldistrict' if _n == `x'
replace lowerXis_schooldistrict = `lbm`x'Xis_schooldistrict' if _n == `x'
replace upperXis_schooldistrict = `ubm`x'Xis_schooldistrict' if _n == `x'
replace coefXis_not_schooldistrict = `bm`x'Xis_not_schooldistrict' if _n == `x'
replace lowerXis_not_schooldistrict = `lbm`x'Xis_not_schooldistrict' if _n == `x'
replace upperXis_not_schooldistrict = `ubm`x'Xis_not_schooldistrict' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coefXis_schooldistrict = `b`x'Xis_schooldistrict' if _n == `x' + 5
replace lowerXis_schooldistrict = `lb`x'Xis_schooldistrict' if _n == `x' + 5
replace upperXis_schooldistrict = `ub`x'Xis_schooldistrict' if _n == `x' + 5
replace coefXis_not_schooldistrict = `b`x'Xis_not_schooldistrict' if _n == `x' + 5
replace lowerXis_not_schooldistrict = `lb`x'Xis_not_schooldistrict' if _n == `x' + 5
replace upperXis_not_schooldistrict = `ub`x'Xis_not_schooldistrict' if _n == `x' + 5
}

sort yeartochange

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coefXis_schooldistrict yeartochange, msize(small) mcolor(magenta)) ///
(rcap upperXis_schooldistrict lowerXis_schooldistrict yeartochange, color(magenta)) ///
(scatter coefXis_not_schooldistrict yeartochange2, msize(small) mcolor(blue)) ///
(rcap upperXis_not_schooldistrict lowerXis_not_schooldistrict yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("Inter-Gov. Rev./Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") label(3 "Municipality/township/county") label(4 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_IGRev_SDorNonSD.eps", replace

graph twoway ///
(scatter coefXis_schooldistrict yeartochange, msize(small) mcolor(magenta)) ///
(rcap upperXis_schooldistrict lowerXis_schooldistrict yeartochange, color(magenta)) ///
,xtitle("Year to M&A", size(large)) ytitle("Inter-Gov. Rev./Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_IGRev_SD.eps", replace

graph twoway ///
(scatter coefXis_not_schooldistrict yeartochange2, msize(small) mcolor(blue)) ///
(rcap upperXis_not_schooldistrict lowerXis_not_schooldistrict yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("Inter-Gov. Rev./Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Municipality/township/county") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GovFin_IGRev_NonSD.eps", replace

restore

}


