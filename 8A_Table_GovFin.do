
import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIByN_GovFin.csv", clear

do 8B_Proc_GovFin.do

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

gen is_schooldistrict = typecode==5
gen is_not_schooldistrict = typecode!=5

gen TXPXis_schooldistrict = treatedXpost*is_schooldistrict
gen TXPXis_not_schooldistrict = treatedXpost*is_not_schooldistrict

label var TXPXis_schooldistrict "Treated $\times$ Post $\times$ Is School Dist."
label var TXPXis_not_schooldistrict "Treated $\times$ Post $\times$ Is Other Gov."

/* Weight as in Wing, Freedman, Hollingsworth */

preserve
duplicates drop episode_start_year treated_csa treated id, force
bysort episode_start_year treated_csa treated: egen n_count = count(id)
duplicates drop episode_start_year treated_csa treated, force
keep episode_start_year treated_csa treated n_count
sum n_count if treated==0
local sum_n_count_control = r(sum)
sum n_count if treated==1
local sum_n_count_treated = r(sum)
replace n_count = n_count/`sum_n_count_control' if treated==0
replace n_count = n_count/`sum_n_count_treated' if treated==1
rename n_count weight
tempfile weight
save `weight', replace
restore

merge m:1 episode_start_year treated_csa treated using `weight'



/* A non-stacked GovFin sample, which is used to pull sample statistics */

preserve

tempfile GovFinData

import delimited "../CleanData/GovFinSurvey/0G_GovFinData.csv", clear

rename year4 calendar_year

do 8B_Proc_GovFin.do

save `GovFinData', replace

restore



/*-------------------------------------*/
/* Table for slides: Scaled by revenue */
/*-------------------------------------*/

{

// Pooling all governments

local outfile =  "../Draft/tabs/Slides_DID_GovFin_toexp.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes"

reghdfe totalinterestondebt_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

preserve
use `GovFinData', clear
sum totalinterestondebt_toexp
local sample_mean = string(r(mean), "%10.2f")
restore

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Interest Paid/","Exp. (in %)") ///
addtext("Year FE", "Yes","Gov. $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","Sample Mean","`sample_mean'")

reghdfe totalltdissued_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

preserve
use `GovFinData', clear
sum totalltdissued_toexp
local sample_mean = string(r(mean), "%10.2f")
restore

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("New Issuance/","Exp. (in %)") ///
addtext("Year FE", "Yes","Gov. $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","Sample Mean","`sample_mean'")

reghdfe surplus_ratio treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

preserve
use `GovFinData', clear
sum surplus_ratio
local sample_mean = string(r(mean), "%10.2f")
restore

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Budget Surplus","Ratio (in %)") ///
addtext("Year FE", "Yes","Gov. $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","Sample Mean","`sample_mean'")

// Separating two kinds of governments

local outfile =  "../Draft/tabs/Slides_DID_GovFin_toexp_SDorNonSD.tex"

tempfile table
tempname memhold
postfile `memhold' str100 varname str30 (coef1 coef2 coef3) using `table', replace
post `memhold' (" ") ("(1)") ("(2)") ("(3)")
post `memhold' (" ") ("Interest Paid/") ("New Issuance/") ("Budget Surplus/")
post `memhold' (" ") ("Exp. (in \%)") ("Exp. (in \%)") ("Exp. (in \%)")

// Panel A: By type of government: School district

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel A: School district") (" ") (" ") (" ") 

reghdfe totalinterestondebt_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef1 = _b[treatedXpost]
local t_coef1 = _b[treatedXpost]/_se[treatedXpost]
local p_coef1 = 2 * ttail(e(df_r), abs(`t_coef1'))
if `p_coef1' >= 0.10 {
	local b_coef1 = string(`b_coef1', "%6.2f")
} 
else if `p_coef1' < 0.10 & `p_coef1' >= 0.05 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "*"
} 
else if `p_coef1' < 0.05 & `p_coef1' >= 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "**"
} 
else if `p_coef1' < 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "***"
}
local t_coef1 = "(" + string(`t_coef1', "%6.2f") + ")"
local r2_coef1 = string(e(r2_a), "%6.3f")
local obs_coef1 = string(e(N), "%10.0fc")

reghdfe totalltdissued_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef2 = _b[treatedXpost]
local t_coef2 = _b[treatedXpost]/_se[treatedXpost]
local p_coef2 = 2 * ttail(e(df_r), abs(`t_coef2'))
if `p_coef2' >= 0.10 {
	local b_coef2 = string(`b_coef2', "%6.2f")
} 
else if `p_coef2' < 0.10 & `p_coef2' >= 0.05 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "*"
} 
else if `p_coef2' < 0.05 & `p_coef2' >= 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "**"
} 
else if `p_coef2' < 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "***"
}
local t_coef2 = "(" + string(`t_coef2', "%6.2f") + ")"
local r2_coef2 = string(e(r2_a), "%6.3f")
local obs_coef2 = string(e(N), "%10.0fc")

reghdfe surplus_ratio treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef3 = _b[treatedXpost]
local t_coef3 = _b[treatedXpost]/_se[treatedXpost]
local p_coef3 = 2 * ttail(e(df_r), abs(`t_coef3'))
if `p_coef3' >= 0.10 {
	local b_coef3 = string(`b_coef3', "%6.2f")
} 
else if `p_coef3' < 0.10 & `p_coef3' >= 0.05 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "*"
} 
else if `p_coef3' < 0.05 & `p_coef3' >= 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "**"
} 
else if `p_coef3' < 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "***"
}
local t_coef3 = "(" + string(`t_coef3', "%6.2f") + ")"
local r2_coef3 = string(e(r2_a), "%6.3f")
local obs_coef3 = string(e(N), "%10.0fc")

reghdfe totaltaxes_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef4 = _b[treatedXpost]
local t_coef4 = _b[treatedXpost]/_se[treatedXpost]
local p_coef4 = 2 * ttail(e(df_r), abs(`t_coef4'))
if `p_coef4' >= 0.10 {
	local b_coef4 = string(`b_coef4', "%6.2f")
} 
else if `p_coef4' < 0.10 & `p_coef4' >= 0.05 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "*"
} 
else if `p_coef4' < 0.05 & `p_coef4' >= 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "**"
} 
else if `p_coef4' < 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "***"
}
local t_coef4 = "(" + string(`t_coef4', "%6.2f") + ")"
local r2_coef4 = string(e(r2_a), "%6.3f")
local obs_coef4 = string(e(N), "%10.0fc")

reghdfe propertytax_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef5 = _b[treatedXpost]
local t_coef5 = _b[treatedXpost]/_se[treatedXpost]
local p_coef5 = 2 * ttail(e(df_r), abs(`t_coef5'))
if `p_coef5' >= 0.10 {
	local b_coef5 = string(`b_coef5', "%6.2f")
} 
else if `p_coef5' < 0.10 & `p_coef5' >= 0.05 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "*"
} 
else if `p_coef5' < 0.05 & `p_coef5' >= 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "**"
} 
else if `p_coef5' < 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "***"
}
local t_coef5 = "(" + string(`t_coef5', "%6.2f") + ")"
local r2_coef5 = string(e(r2_a), "%6.3f")
local obs_coef5 = string(e(N), "%10.0fc")

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef6 = _b[treatedXpost]
local t_coef6 = _b[treatedXpost]/_se[treatedXpost]
local p_coef6 = 2 * ttail(e(df_r), abs(`t_coef6'))
if `p_coef6' >= 0.10 {
	local b_coef6 = string(`b_coef6', "%6.2f")
} 
else if `p_coef6' < 0.10 & `p_coef6' >= 0.05 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "*"
} 
else if `p_coef6' < 0.05 & `p_coef6' >= 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "**"
} 
else if `p_coef6' < 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "***"
}
local t_coef6 = "(" + string(`t_coef6', "%6.2f") + ")"
local r2_coef6 = string(e(r2_a), "%6.3f")
local obs_coef6 = string(e(N), "%10.0fc")

post `memhold' ("Treated $\times$ Post") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
post `memhold' (" ") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

// Panel B: By type of government: Municipality/township/county

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel B: Municipality/township/county") (" ") (" ") (" ")

reghdfe totalinterestondebt_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef1 = _b[treatedXpost]
local t_coef1 = _b[treatedXpost]/_se[treatedXpost]
local p_coef1 = 2 * ttail(e(df_r), abs(`t_coef1'))
if `p_coef1' >= 0.10 {
	local b_coef1 = string(`b_coef1', "%6.2f")
} 
else if `p_coef1' < 0.10 & `p_coef1' >= 0.05 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "*"
} 
else if `p_coef1' < 0.05 & `p_coef1' >= 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "**"
} 
else if `p_coef1' < 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "***"
}
local t_coef1 = "(" + string(`t_coef1', "%6.2f") + ")"
local r2_coef1 = string(e(r2_a), "%6.3f")
local obs_coef1 = string(e(N), "%10.0fc")

reghdfe totalltdissued_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef2 = _b[treatedXpost]
local t_coef2 = _b[treatedXpost]/_se[treatedXpost]
local p_coef2 = 2 * ttail(e(df_r), abs(`t_coef2'))
if `p_coef2' >= 0.10 {
	local b_coef2 = string(`b_coef2', "%6.2f")
} 
else if `p_coef2' < 0.10 & `p_coef2' >= 0.05 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "*"
} 
else if `p_coef2' < 0.05 & `p_coef2' >= 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "**"
} 
else if `p_coef2' < 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "***"
}
local t_coef2 = "(" + string(`t_coef2', "%6.2f") + ")"
local r2_coef2 = string(e(r2_a), "%6.3f")
local obs_coef2 = string(e(N), "%10.0fc")

reghdfe surplus_ratio treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef3 = _b[treatedXpost]
local t_coef3 = _b[treatedXpost]/_se[treatedXpost]
local p_coef3 = 2 * ttail(e(df_r), abs(`t_coef3'))
if `p_coef3' >= 0.10 {
	local b_coef3 = string(`b_coef3', "%6.2f")
} 
else if `p_coef3' < 0.10 & `p_coef3' >= 0.05 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "*"
} 
else if `p_coef3' < 0.05 & `p_coef3' >= 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "**"
} 
else if `p_coef3' < 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "***"
}
local t_coef3 = "(" + string(`t_coef3', "%6.2f") + ")"
local r2_coef3 = string(e(r2_a), "%6.3f")
local obs_coef3 = string(e(N), "%10.0fc")

reghdfe totaltaxes_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef4 = _b[treatedXpost]
local t_coef4 = _b[treatedXpost]/_se[treatedXpost]
local p_coef4 = 2 * ttail(e(df_r), abs(`t_coef4'))
if `p_coef4' >= 0.10 {
	local b_coef4 = string(`b_coef4', "%6.2f")
} 
else if `p_coef4' < 0.10 & `p_coef4' >= 0.05 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "*"
} 
else if `p_coef4' < 0.05 & `p_coef4' >= 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "**"
} 
else if `p_coef4' < 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "***"
}
local t_coef4 = "(" + string(`t_coef4', "%6.2f") + ")"
local r2_coef4 = string(e(r2_a), "%6.3f")
local obs_coef4 = string(e(N), "%10.0fc")

reghdfe propertytax_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef5 = _b[treatedXpost]
local t_coef5 = _b[treatedXpost]/_se[treatedXpost]
local p_coef5 = 2 * ttail(e(df_r), abs(`t_coef5'))
if `p_coef5' >= 0.10 {
	local b_coef5 = string(`b_coef5', "%6.2f")
} 
else if `p_coef5' < 0.10 & `p_coef5' >= 0.05 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "*"
} 
else if `p_coef5' < 0.05 & `p_coef5' >= 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "**"
} 
else if `p_coef5' < 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "***"
}
local t_coef5 = "(" + string(`t_coef5', "%6.2f") + ")"
local r2_coef5 = string(e(r2_a), "%6.3f")
local obs_coef5 = string(e(N), "%10.0fc")

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef6 = _b[treatedXpost]
local t_coef6 = _b[treatedXpost]/_se[treatedXpost]
local p_coef6 = 2 * ttail(e(df_r), abs(`t_coef6'))
if `p_coef6' >= 0.10 {
	local b_coef6 = string(`b_coef6', "%6.2f")
} 
else if `p_coef6' < 0.10 & `p_coef6' >= 0.05 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "*"
} 
else if `p_coef6' < 0.05 & `p_coef6' >= 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "**"
} 
else if `p_coef6' < 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "***"
}
local t_coef6 = "(" + string(`t_coef6', "%6.2f") + ")"
local r2_coef6 = string(e(r2_a), "%6.3f")
local obs_coef6 = string(e(N), "%10.0fc")

post `memhold' ("Treated $\times$ Post") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
post `memhold' (" ") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Government \(\times\) Cohort FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Year FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Clustering") ("CSA \& Year") ("CSA \& Year") ("CSA \& Year")

postclose `memhold'

preserve
use `table', clear
texsave using "`outfile'", replace dataonly nonames italics("Panel") nofix hlines(3)
restore

}



/*--------------------------*/
/* Panel: Scaled by revenue */
/*--------------------------*/

// Part 1: Interest paid, new issuance, and budget surplus

{

local outfile =  "../Draft/tabs/DID_GovFin_toexp.tex"

tempfile table
tempname memhold
postfile `memhold' str100 varname str30 (coef1 coef2 coef3) using `table', replace
post `memhold' (" ") ("(1)") ("(2)") ("(3)")
post `memhold' (" ") ("Interest Paid/") ("New Issuance/") ("Budget Surplus/")
post `memhold' (" ") ("Exp. (in \%)") ("Exp. (in \%)") ("Exp. (in \%)")

// Panel A: Overall

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel A: Overall") (" ") (" ") (" ")

reghdfe totalinterestondebt_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef1 = _b[treatedXpost]
local t_coef1 = _b[treatedXpost]/_se[treatedXpost]
local p_coef1 = 2 * ttail(e(df_r), abs(`t_coef1'))
if `p_coef1' >= 0.10 {
	local b_coef1 = string(`b_coef1', "%6.2f")
} 
else if `p_coef1' < 0.10 & `p_coef1' >= 0.05 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "*"
} 
else if `p_coef1' < 0.05 & `p_coef1' >= 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "**"
} 
else if `p_coef1' < 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "***"
}
local t_coef1 = "(" + string(`t_coef1', "%6.2f") + ")"
local r2_coef1 = string(e(r2_a), "%6.3f")
local obs_coef1 = string(e(N), "%10.0fc")

reghdfe totalltdissued_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef2 = _b[treatedXpost]
local t_coef2 = _b[treatedXpost]/_se[treatedXpost]
local p_coef2 = 2 * ttail(e(df_r), abs(`t_coef2'))
if `p_coef2' >= 0.10 {
	local b_coef2 = string(`b_coef2', "%6.2f")
} 
else if `p_coef2' < 0.10 & `p_coef2' >= 0.05 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "*"
} 
else if `p_coef2' < 0.05 & `p_coef2' >= 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "**"
} 
else if `p_coef2' < 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "***"
}
local t_coef2 = "(" + string(`t_coef2', "%6.2f") + ")"
local r2_coef2 = string(e(r2_a), "%6.3f")
local obs_coef2 = string(e(N), "%10.0fc")

reghdfe surplus_ratio treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef3 = _b[treatedXpost]
local t_coef3 = _b[treatedXpost]/_se[treatedXpost]
local p_coef3 = 2 * ttail(e(df_r), abs(`t_coef3'))
if `p_coef3' >= 0.10 {
	local b_coef3 = string(`b_coef3', "%6.2f")
} 
else if `p_coef3' < 0.10 & `p_coef3' >= 0.05 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "*"
} 
else if `p_coef3' < 0.05 & `p_coef3' >= 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "**"
} 
else if `p_coef3' < 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "***"
}
local t_coef3 = "(" + string(`t_coef3', "%6.2f") + ")"
local r2_coef3 = string(e(r2_a), "%6.3f")
local obs_coef3 = string(e(N), "%10.0fc")

reghdfe totaltaxes_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef4 = _b[treatedXpost]
local t_coef4 = _b[treatedXpost]/_se[treatedXpost]
local p_coef4 = 2 * ttail(e(df_r), abs(`t_coef4'))
if `p_coef4' >= 0.10 {
	local b_coef4 = string(`b_coef4', "%6.2f")
} 
else if `p_coef4' < 0.10 & `p_coef4' >= 0.05 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "*"
} 
else if `p_coef4' < 0.05 & `p_coef4' >= 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "**"
} 
else if `p_coef4' < 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "***"
}
local t_coef4 = "(" + string(`t_coef4', "%6.2f") + ")"
local r2_coef4 = string(e(r2_a), "%6.3f")
local obs_coef4 = string(e(N), "%10.0fc")

reghdfe propertytax_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef5 = _b[treatedXpost]
local t_coef5 = _b[treatedXpost]/_se[treatedXpost]
local p_coef5 = 2 * ttail(e(df_r), abs(`t_coef5'))
if `p_coef5' >= 0.10 {
	local b_coef5 = string(`b_coef5', "%6.2f")
} 
else if `p_coef5' < 0.10 & `p_coef5' >= 0.05 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "*"
} 
else if `p_coef5' < 0.05 & `p_coef5' >= 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "**"
} 
else if `p_coef5' < 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "***"
}
local t_coef5 = "(" + string(`t_coef5', "%6.2f") + ")"
local r2_coef5 = string(e(r2_a), "%6.3f")
local obs_coef5 = string(e(N), "%10.0fc")

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef6 = _b[treatedXpost]
local t_coef6 = _b[treatedXpost]/_se[treatedXpost]
local p_coef6 = 2 * ttail(e(df_r), abs(`t_coef6'))
if `p_coef6' >= 0.10 {
	local b_coef6 = string(`b_coef6', "%6.2f")
} 
else if `p_coef6' < 0.10 & `p_coef6' >= 0.05 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "*"
} 
else if `p_coef6' < 0.05 & `p_coef6' >= 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "**"
} 
else if `p_coef6' < 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "***"
}
local t_coef6 = "(" + string(`t_coef6', "%6.2f") + ")"
local r2_coef6 = string(e(r2_a), "%6.3f")
local obs_coef6 = string(e(N), "%10.0fc")

post `memhold' ("Treated $\times$ Post") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
post `memhold' (" ") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'")
post `memhold' ("Adjusted R-squared") ("`r2_coef1'") ("`r2_coef2'") ("`r2_coef3'")

// Panel B: By type of government: School district

post `memhold' (" ") (" ") (" ") (" ") (" ") (" ") (" ")
post `memhold' ("Panel B: School district") (" ") (" ") (" ") (" ") (" ") (" ")

reghdfe totalinterestondebt_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef1 = _b[treatedXpost]
local t_coef1 = _b[treatedXpost]/_se[treatedXpost]
local p_coef1 = 2 * ttail(e(df_r), abs(`t_coef1'))
if `p_coef1' >= 0.10 {
	local b_coef1 = string(`b_coef1', "%6.2f")
} 
else if `p_coef1' < 0.10 & `p_coef1' >= 0.05 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "*"
} 
else if `p_coef1' < 0.05 & `p_coef1' >= 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "**"
} 
else if `p_coef1' < 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "***"
}
local t_coef1 = "(" + string(`t_coef1', "%6.2f") + ")"
local r2_coef1 = string(e(r2_a), "%6.3f")
local obs_coef1 = string(e(N), "%10.0fc")

reghdfe totalltdissued_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef2 = _b[treatedXpost]
local t_coef2 = _b[treatedXpost]/_se[treatedXpost]
local p_coef2 = 2 * ttail(e(df_r), abs(`t_coef2'))
if `p_coef2' >= 0.10 {
	local b_coef2 = string(`b_coef2', "%6.2f")
} 
else if `p_coef2' < 0.10 & `p_coef2' >= 0.05 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "*"
} 
else if `p_coef2' < 0.05 & `p_coef2' >= 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "**"
} 
else if `p_coef2' < 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "***"
}
local t_coef2 = "(" + string(`t_coef2', "%6.2f") + ")"
local r2_coef2 = string(e(r2_a), "%6.3f")
local obs_coef2 = string(e(N), "%10.0fc")

reghdfe surplus_ratio treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef3 = _b[treatedXpost]
local t_coef3 = _b[treatedXpost]/_se[treatedXpost]
local p_coef3 = 2 * ttail(e(df_r), abs(`t_coef3'))
if `p_coef3' >= 0.10 {
	local b_coef3 = string(`b_coef3', "%6.2f")
} 
else if `p_coef3' < 0.10 & `p_coef3' >= 0.05 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "*"
} 
else if `p_coef3' < 0.05 & `p_coef3' >= 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "**"
} 
else if `p_coef3' < 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "***"
}
local t_coef3 = "(" + string(`t_coef3', "%6.2f") + ")"
local r2_coef3 = string(e(r2_a), "%6.3f")
local obs_coef3 = string(e(N), "%10.0fc")

reghdfe totaltaxes_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef4 = _b[treatedXpost]
local t_coef4 = _b[treatedXpost]/_se[treatedXpost]
local p_coef4 = 2 * ttail(e(df_r), abs(`t_coef4'))
if `p_coef4' >= 0.10 {
	local b_coef4 = string(`b_coef4', "%6.2f")
} 
else if `p_coef4' < 0.10 & `p_coef4' >= 0.05 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "*"
} 
else if `p_coef4' < 0.05 & `p_coef4' >= 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "**"
} 
else if `p_coef4' < 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "***"
}
local t_coef4 = "(" + string(`t_coef4', "%6.2f") + ")"
local r2_coef4 = string(e(r2_a), "%6.3f")
local obs_coef4 = string(e(N), "%10.0fc")

reghdfe propertytax_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef5 = _b[treatedXpost]
local t_coef5 = _b[treatedXpost]/_se[treatedXpost]
local p_coef5 = 2 * ttail(e(df_r), abs(`t_coef5'))
if `p_coef5' >= 0.10 {
	local b_coef5 = string(`b_coef5', "%6.2f")
} 
else if `p_coef5' < 0.10 & `p_coef5' >= 0.05 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "*"
} 
else if `p_coef5' < 0.05 & `p_coef5' >= 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "**"
} 
else if `p_coef5' < 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "***"
}
local t_coef5 = "(" + string(`t_coef5', "%6.2f") + ")"
local r2_coef5 = string(e(r2_a), "%6.3f")
local obs_coef5 = string(e(N), "%10.0fc")

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef6 = _b[treatedXpost]
local t_coef6 = _b[treatedXpost]/_se[treatedXpost]
local p_coef6 = 2 * ttail(e(df_r), abs(`t_coef6'))
if `p_coef6' >= 0.10 {
	local b_coef6 = string(`b_coef6', "%6.2f")
} 
else if `p_coef6' < 0.10 & `p_coef6' >= 0.05 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "*"
} 
else if `p_coef6' < 0.05 & `p_coef6' >= 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "**"
} 
else if `p_coef6' < 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "***"
}
local t_coef6 = "(" + string(`t_coef6', "%6.2f") + ")"
local r2_coef6 = string(e(r2_a), "%6.3f")
local obs_coef6 = string(e(N), "%10.0fc")

post `memhold' ("Treated $\times$ Post") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
post `memhold' (" ") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'")
post `memhold' ("Adjusted R-squared") ("`r2_coef1'") ("`r2_coef2'") ("`r2_coef3'")

// Panel C: By type of government: Municipality/township/county

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel C: Municipality/township/county") (" ") (" ") (" ")

reghdfe totalinterestondebt_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef1 = _b[treatedXpost]
local t_coef1 = _b[treatedXpost]/_se[treatedXpost]
local p_coef1 = 2 * ttail(e(df_r), abs(`t_coef1'))
if `p_coef1' >= 0.10 {
	local b_coef1 = string(`b_coef1', "%6.2f")
} 
else if `p_coef1' < 0.10 & `p_coef1' >= 0.05 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "*"
} 
else if `p_coef1' < 0.05 & `p_coef1' >= 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "**"
} 
else if `p_coef1' < 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "***"
}
local t_coef1 = "(" + string(`t_coef1', "%6.2f") + ")"
local r2_coef1 = string(e(r2_a), "%6.3f")
local obs_coef1 = string(e(N), "%10.0fc")

reghdfe totalltdissued_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef2 = _b[treatedXpost]
local t_coef2 = _b[treatedXpost]/_se[treatedXpost]
local p_coef2 = 2 * ttail(e(df_r), abs(`t_coef2'))
if `p_coef2' >= 0.10 {
	local b_coef2 = string(`b_coef2', "%6.2f")
} 
else if `p_coef2' < 0.10 & `p_coef2' >= 0.05 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "*"
} 
else if `p_coef2' < 0.05 & `p_coef2' >= 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "**"
} 
else if `p_coef2' < 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "***"
}
local t_coef2 = "(" + string(`t_coef2', "%6.2f") + ")"
local r2_coef2 = string(e(r2_a), "%6.3f")
local obs_coef2 = string(e(N), "%10.0fc")

reghdfe surplus_ratio treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef3 = _b[treatedXpost]
local t_coef3 = _b[treatedXpost]/_se[treatedXpost]
local p_coef3 = 2 * ttail(e(df_r), abs(`t_coef3'))
if `p_coef3' >= 0.10 {
	local b_coef3 = string(`b_coef3', "%6.2f")
} 
else if `p_coef3' < 0.10 & `p_coef3' >= 0.05 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "*"
} 
else if `p_coef3' < 0.05 & `p_coef3' >= 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "**"
} 
else if `p_coef3' < 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "***"
}
local t_coef3 = "(" + string(`t_coef3', "%6.2f") + ")"
local r2_coef3 = string(e(r2_a), "%6.3f")
local obs_coef3 = string(e(N), "%10.0fc")

reghdfe totaltaxes_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef4 = _b[treatedXpost]
local t_coef4 = _b[treatedXpost]/_se[treatedXpost]
local p_coef4 = 2 * ttail(e(df_r), abs(`t_coef4'))
if `p_coef4' >= 0.10 {
	local b_coef4 = string(`b_coef4', "%6.2f")
} 
else if `p_coef4' < 0.10 & `p_coef4' >= 0.05 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "*"
} 
else if `p_coef4' < 0.05 & `p_coef4' >= 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "**"
} 
else if `p_coef4' < 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "***"
}
local t_coef4 = "(" + string(`t_coef4', "%6.2f") + ")"
local r2_coef4 = string(e(r2_a), "%6.3f")
local obs_coef4 = string(e(N), "%10.0fc")

reghdfe propertytax_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef5 = _b[treatedXpost]
local t_coef5 = _b[treatedXpost]/_se[treatedXpost]
local p_coef5 = 2 * ttail(e(df_r), abs(`t_coef5'))
if `p_coef5' >= 0.10 {
	local b_coef5 = string(`b_coef5', "%6.2f")
} 
else if `p_coef5' < 0.10 & `p_coef5' >= 0.05 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "*"
} 
else if `p_coef5' < 0.05 & `p_coef5' >= 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "**"
} 
else if `p_coef5' < 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "***"
}
local t_coef5 = "(" + string(`t_coef5', "%6.2f") + ")"
local r2_coef5 = string(e(r2_a), "%6.3f")
local obs_coef5 = string(e(N), "%10.0fc")

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef6 = _b[treatedXpost]
local t_coef6 = _b[treatedXpost]/_se[treatedXpost]
local p_coef6 = 2 * ttail(e(df_r), abs(`t_coef6'))
if `p_coef6' >= 0.10 {
	local b_coef6 = string(`b_coef6', "%6.2f")
} 
else if `p_coef6' < 0.10 & `p_coef6' >= 0.05 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "*"
} 
else if `p_coef6' < 0.05 & `p_coef6' >= 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "**"
} 
else if `p_coef6' < 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "***"
}
local t_coef6 = "(" + string(`t_coef6', "%6.2f") + ")"
local r2_coef6 = string(e(r2_a), "%6.3f")
local obs_coef6 = string(e(N), "%10.0fc")

post `memhold' ("Treated $\times$ Post") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
post `memhold' (" ") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'")
post `memhold' ("Adjusted R-squared") ("`r2_coef1'") ("`r2_coef2'") ("`r2_coef3'")

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Government \(\times\) Cohort FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Year FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Clustering") ("CSA \& Year") ("CSA \& Year") ("CSA \& Year")

postclose `memhold'

preserve
use `table', clear
texsave using "`outfile'", replace dataonly nonames italics("Panel") nofix hlines(3)
restore

}

// Part 2: Taxes and inter-governmental transfer

{

local outfile =  "../Draft/tabs/DID_GovFin_toexp_tax_transfer.tex"

tempfile table
tempname memhold
postfile `memhold' str100 varname str30 (coef1 coef2 coef3) using `table', replace
post `memhold' (" ") ("(1)") ("(2)") ("(3)")
post `memhold' (" ") ("Total Taxes/") ("Property Tax/") ("Inter-Gov. Trans./")
post `memhold' (" ") ("Exp. (in \%)") ("Exp. (in \%)") ("Exp. (in \%)")

// Panel A: Overall

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel A: Overall") (" ") (" ") (" ")

reghdfe totaltaxes_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef4 = _b[treatedXpost]
local t_coef4 = _b[treatedXpost]/_se[treatedXpost]
local p_coef4 = 2 * ttail(e(df_r), abs(`t_coef4'))
if `p_coef4' >= 0.10 {
	local b_coef4 = string(`b_coef4', "%6.2f")
} 
else if `p_coef4' < 0.10 & `p_coef4' >= 0.05 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "*"
} 
else if `p_coef4' < 0.05 & `p_coef4' >= 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "**"
} 
else if `p_coef4' < 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "***"
}
local t_coef4 = "(" + string(`t_coef4', "%6.2f") + ")"
local r2_coef4 = string(e(r2_a), "%6.3f")
local obs_coef4 = string(e(N), "%10.0fc")

reghdfe propertytax_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef5 = _b[treatedXpost]
local t_coef5 = _b[treatedXpost]/_se[treatedXpost]
local p_coef5 = 2 * ttail(e(df_r), abs(`t_coef5'))
if `p_coef5' >= 0.10 {
	local b_coef5 = string(`b_coef5', "%6.2f")
} 
else if `p_coef5' < 0.10 & `p_coef5' >= 0.05 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "*"
} 
else if `p_coef5' < 0.05 & `p_coef5' >= 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "**"
} 
else if `p_coef5' < 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "***"
}
local t_coef5 = "(" + string(`t_coef5', "%6.2f") + ")"
local r2_coef5 = string(e(r2_a), "%6.3f")
local obs_coef5 = string(e(N), "%10.0fc")

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef6 = _b[treatedXpost]
local t_coef6 = _b[treatedXpost]/_se[treatedXpost]
local p_coef6 = 2 * ttail(e(df_r), abs(`t_coef6'))
if `p_coef6' >= 0.10 {
	local b_coef6 = string(`b_coef6', "%6.2f")
} 
else if `p_coef6' < 0.10 & `p_coef6' >= 0.05 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "*"
} 
else if `p_coef6' < 0.05 & `p_coef6' >= 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "**"
} 
else if `p_coef6' < 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "***"
}
local t_coef6 = "(" + string(`t_coef6', "%6.2f") + ")"
local r2_coef6 = string(e(r2_a), "%6.3f")
local obs_coef6 = string(e(N), "%10.0fc")

post `memhold' ("Treated $\times$ Post") ("`b_coef4'") ("`b_coef5'") ("`b_coef6'")
post `memhold' (" ") ("`t_coef4'") ("`t_coef5'") ("`t_coef6'")

post `memhold' ("Observations") ("`obs_coef4'") ("`obs_coef5'") ("`obs_coef6'")
post `memhold' ("Adjusted R-squared") ("`r2_coef4'") ("`r2_coef5'") ("`r2_coef6'")

// Panel B: By type of government: School district

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel B: School district") (" ") (" ") (" ")

reghdfe totaltaxes_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef4 = _b[treatedXpost]
local t_coef4 = _b[treatedXpost]/_se[treatedXpost]
local p_coef4 = 2 * ttail(e(df_r), abs(`t_coef4'))
if `p_coef4' >= 0.10 {
	local b_coef4 = string(`b_coef4', "%6.2f")
} 
else if `p_coef4' < 0.10 & `p_coef4' >= 0.05 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "*"
} 
else if `p_coef4' < 0.05 & `p_coef4' >= 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "**"
} 
else if `p_coef4' < 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "***"
}
local t_coef4 = "(" + string(`t_coef4', "%6.2f") + ")"
local r2_coef4 = string(e(r2_a), "%6.3f")
local obs_coef4 = string(e(N), "%10.0fc")

reghdfe propertytax_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef5 = _b[treatedXpost]
local t_coef5 = _b[treatedXpost]/_se[treatedXpost]
local p_coef5 = 2 * ttail(e(df_r), abs(`t_coef5'))
if `p_coef5' >= 0.10 {
	local b_coef5 = string(`b_coef5', "%6.2f")
} 
else if `p_coef5' < 0.10 & `p_coef5' >= 0.05 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "*"
} 
else if `p_coef5' < 0.05 & `p_coef5' >= 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "**"
} 
else if `p_coef5' < 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "***"
}
local t_coef5 = "(" + string(`t_coef5', "%6.2f") + ")"
local r2_coef5 = string(e(r2_a), "%6.3f")
local obs_coef5 = string(e(N), "%10.0fc")

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef6 = _b[treatedXpost]
local t_coef6 = _b[treatedXpost]/_se[treatedXpost]
local p_coef6 = 2 * ttail(e(df_r), abs(`t_coef6'))
if `p_coef6' >= 0.10 {
	local b_coef6 = string(`b_coef6', "%6.2f")
} 
else if `p_coef6' < 0.10 & `p_coef6' >= 0.05 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "*"
} 
else if `p_coef6' < 0.05 & `p_coef6' >= 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "**"
} 
else if `p_coef6' < 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "***"
}
local t_coef6 = "(" + string(`t_coef6', "%6.2f") + ")"
local r2_coef6 = string(e(r2_a), "%6.3f")
local obs_coef6 = string(e(N), "%10.0fc")

post `memhold' ("Treated $\times$ Post") ("`b_coef4'") ("`b_coef5'") ("`b_coef6'")
post `memhold' (" ") ("`t_coef4'") ("`t_coef5'") ("`t_coef6'")

post `memhold' ("Observations") ("`obs_coef4'") ("`obs_coef5'") ("`obs_coef6'")
post `memhold' ("Adjusted R-squared") ("`r2_coef4'") ("`r2_coef5'") ("`r2_coef6'")

// Panel C: By type of government: Municipality/township/county

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel C: Municipality/township/county") (" ") (" ") (" ")

reghdfe totaltaxes_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef4 = _b[treatedXpost]
local t_coef4 = _b[treatedXpost]/_se[treatedXpost]
local p_coef4 = 2 * ttail(e(df_r), abs(`t_coef4'))
if `p_coef4' >= 0.10 {
	local b_coef4 = string(`b_coef4', "%6.2f")
} 
else if `p_coef4' < 0.10 & `p_coef4' >= 0.05 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "*"
} 
else if `p_coef4' < 0.05 & `p_coef4' >= 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "**"
} 
else if `p_coef4' < 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "***"
}
local t_coef4 = "(" + string(`t_coef4', "%6.2f") + ")"
local r2_coef4 = string(e(r2_a), "%6.3f")
local obs_coef4 = string(e(N), "%10.0fc")

reghdfe propertytax_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef5 = _b[treatedXpost]
local t_coef5 = _b[treatedXpost]/_se[treatedXpost]
local p_coef5 = 2 * ttail(e(df_r), abs(`t_coef5'))
if `p_coef5' >= 0.10 {
	local b_coef5 = string(`b_coef5', "%6.2f")
} 
else if `p_coef5' < 0.10 & `p_coef5' >= 0.05 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "*"
} 
else if `p_coef5' < 0.05 & `p_coef5' >= 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "**"
} 
else if `p_coef5' < 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "***"
}
local t_coef5 = "(" + string(`t_coef5', "%6.2f") + ")"
local r2_coef5 = string(e(r2_a), "%6.3f")
local obs_coef5 = string(e(N), "%10.0fc")

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef6 = _b[treatedXpost]
local t_coef6 = _b[treatedXpost]/_se[treatedXpost]
local p_coef6 = 2 * ttail(e(df_r), abs(`t_coef6'))
if `p_coef6' >= 0.10 {
	local b_coef6 = string(`b_coef6', "%6.2f")
} 
else if `p_coef6' < 0.10 & `p_coef6' >= 0.05 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "*"
} 
else if `p_coef6' < 0.05 & `p_coef6' >= 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "**"
} 
else if `p_coef6' < 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "***"
}
local t_coef6 = "(" + string(`t_coef6', "%6.2f") + ")"
local r2_coef6 = string(e(r2_a), "%6.3f")
local obs_coef6 = string(e(N), "%10.0fc")

post `memhold' ("Treated $\times$ Post") ("`b_coef4'") ("`b_coef5'") ("`b_coef6'")
post `memhold' (" ") ("`t_coef4'") ("`t_coef5'") ("`t_coef6'")

post `memhold' ("Observations") ("`obs_coef4'") ("`obs_coef5'") ("`obs_coef6'")
post `memhold' ("Adjusted R-squared") ("`r2_coef4'") ("`r2_coef5'") ("`r2_coef6'")

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Government \(\times\) Cohort FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Year FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Clustering") ("CSA \& Year") ("CSA \& Year") ("CSA \& Year")

postclose `memhold'

preserve
use `table', clear
texsave using "`outfile'", replace dataonly nonames italics("Panel") nofix hlines(3)
restore

}



/*-----------------------------------*/
/* Run regressions to export numbers */
/*-----------------------------------*/

// Pooling two kinds of local governments

{

// (1)

reghdfe totalinterestondebt_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_totalinterestondebt_toexp = _b[treatedXpost]
local coef_totalinterestondebt_toexp : display %-9.2f `coef_totalinterestondebt_toexp'
file open myfile using "../Draft/nums/coef_totalinterestondebt_toexp.tex", write replace
file write myfile "`coef_totalinterestondebt_toexp'"
file close myfile

local t_totalinterestondebt_toexp = _b[treatedXpost]/_se[treatedXpost]
local t_totalinterestondebt_toexp : display %-9.2f `t_totalinterestondebt_toexp'
file open myfile using "../Draft/nums/t_totalinterestondebt_toexp.tex", write replace
file write myfile "`t_totalinterestondebt_toexp'"
file close myfile

preserve
duplicates drop county calendar_year, force
sum county_totalexpenditure, d
local totalinterestondebt_county = _b[treatedXpost]/100*r(p50)*1000/1000000
di `totalinterestondebt_county'
local totalinterestondebt_county : display %-9.2f `totalinterestondebt_county'
file open myfile using "../Draft/nums/totalinterestondebt_county.tex", write replace
file write myfile "`totalinterestondebt_county'"
file close myfile
restore

// (2)

reghdfe totalltdissued_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_totalltdissued_toexp = _b[treatedXpost]
local coef_totalltdissued_toexp : display %-9.2f `coef_totalltdissued_toexp'
file open myfile using "../Draft/nums/coef_totalltdissued_toexp.tex", write replace
file write myfile "`coef_totalltdissued_toexp'"
file close myfile

local t_totalltdissued_toexp = _b[treatedXpost]/_se[treatedXpost]
local t_totalltdissued_toexp : display %-9.2f `t_totalltdissued_toexp'
file open myfile using "../Draft/nums/t_totalltdissued_toexp.tex", write replace
file write myfile "`t_totalltdissued_toexp'"
file close myfile

local abs_coef_totalltdissued_toexp = abs(_b[treatedXpost])
local abs_coef_totalltdissued_toexp : display %-9.2f `abs_coef_totalltdissued_toexp'
file open myfile using "../Draft/nums/abs_coef_totalltdissued_toexp.tex", write replace
file write myfile "`abs_coef_totalltdissued_toexp'"
file close myfile

preserve
duplicates drop county calendar_year, force
sum county_totalexpenditure, d
local abs_totalltdissued_county = abs(_b[treatedXpost]/100*r(p50)*1000/1000000)
di `abs_totalltdissued_county'
local abs_totalltdissued_county : display %-9.2f `abs_totalltdissued_county'
file open myfile using "../Draft/nums/abs_totalltdissued_county.tex", write replace
file write myfile "`abs_totalltdissued_county'"
file close myfile
restore

// (3)

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_totaligrevenue_toexp = _b[treatedXpost]
local coef_totaligrevenue_toexp : display %-9.2f `coef_totaligrevenue_toexp'
file open myfile using "../Draft/nums/coef_totaligrevenue_toexp.tex", write replace
file write myfile "`coef_totaligrevenue_toexp'"
file close myfile

local t_totaligrevenue_toexp = _b[treatedXpost]/_se[treatedXpost]
local t_totaligrevenue_toexp : display %-9.2f `t_totaligrevenue_toexp'
file open myfile using "../Draft/nums/t_totaligrevenue_toexp.tex", write replace
file write myfile "`t_totaligrevenue_toexp'"
file close myfile

local abs_coef_totaligrevenue_toexp = abs(_b[treatedXpost])
local abs_coef_totaligrevenue_toexp : display %-9.2f `abs_coef_totaligrevenue_toexp'
file open myfile using "../Draft/nums/abs_coef_totaligrevenue_toexp.tex", write replace
file write myfile "`abs_coef_totaligrevenue_toexp'"
file close myfile

// (4)

reghdfe totaltaxes_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_totaltaxes_toexp = _b[treatedXpost]
local coef_totaltaxes_toexp : display %-9.2f `coef_totaltaxes_toexp'
file open myfile using "../Draft/nums/coef_totaltaxes_toexp.tex", write replace
file write myfile "`coef_totaltaxes_toexp'"
file close myfile

local t_totaltaxes_toexp = _b[treatedXpost]/_se[treatedXpost]
local t_totaltaxes_toexp : display %-9.2f `t_totaltaxes_toexp'
file open myfile using "../Draft/nums/t_totaltaxes_toexp.tex", write replace
file write myfile "`t_totaltaxes_toexp'"
file close myfile

// (5)

reghdfe propertytax_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_propertytax_toexp = _b[treatedXpost]
local coef_propertytax_toexp : display %-9.2f `coef_propertytax_toexp'
file open myfile using "../Draft/nums/coef_propertytax_toexp.tex", write replace
file write myfile "`coef_propertytax_toexp'"
file close myfile

local t_propertytax_toexp = _b[treatedXpost]/_se[treatedXpost]
local t_propertytax_toexp : display %-9.2f `t_propertytax_toexp'
file open myfile using "../Draft/nums/t_propertytax_toexp.tex", write replace
file write myfile "`t_propertytax_toexp'"
file close myfile

// (6)

reghdfe surplus_ratio treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_surplus_ratio = _b[treatedXpost]
local coef_surplus_ratio : display %-9.2f `coef_surplus_ratio'
file open myfile using "../Draft/nums/coef_surplus_ratio.tex", write replace
file write myfile "`coef_surplus_ratio'"
file close myfile

local t_surplus_ratio = _b[treatedXpost]/_se[treatedXpost]
local t_surplus_ratio : display %-9.2f `t_surplus_ratio'
file open myfile using "../Draft/nums/t_surplus_ratio.tex", write replace
file write myfile "`t_surplus_ratio'"
file close myfile

local abs_coef_surplus_ratio = abs(_b[treatedXpost])
local abs_coef_surplus_ratio : display %-9.2f `abs_coef_surplus_ratio'
file open myfile using "../Draft/nums/abs_coef_surplus_ratio.tex", write replace
file write myfile "`abs_coef_surplus_ratio'"
file close myfile

// Extra number: Change in short-term debt

reghdfe stdebt_change_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_stdebt_change_toexp = _b[treatedXpost]
local coef_stdebt_change_toexp : display %-9.2f `coef_stdebt_change_toexp'
file open myfile using "../Draft/nums/coef_stdebt_change_toexp.tex", write replace
file write myfile "`coef_stdebt_change_toexp'"
file close myfile

local t_stdebt_change_toexp = _b[treatedXpost]/_se[treatedXpost]
local t_stdebt_change_toexp : display %-9.2f `t_stdebt_change_toexp'
file open myfile using "../Draft/nums/t_stdebt_change_toexp.tex", write replace
file write myfile "`t_stdebt_change_toexp'"
file close myfile

local abs_coef_stdebt_change_toexp = abs(_b[treatedXpost])
local abs_coef_stdebt_change_toexp : display %-9.2f `abs_coef_stdebt_change_toexp'
file open myfile using "../Draft/nums/abs_coef_stdebt_change_toexp.tex", write replace
file write myfile "`abs_coef_stdebt_change_toexp'"
file close myfile

// Extra number: Level of short-term debt

reghdfe stdebtendofyear_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_stdebtendofyear_toexp = _b[treatedXpost]
local coef_stdebtendofyear_toexp : display %-9.2f `coef_stdebtendofyear_toexp'
file open myfile using "../Draft/nums/coef_stdebtendofyear_toexp.tex", write replace
file write myfile "`coef_stdebtendofyear_toexp'"
file close myfile

local t_stdebtendofyear_toexp = _b[treatedXpost]/_se[treatedXpost]
local t_stdebtendofyear_toexp : display %-9.2f `t_stdebtendofyear_toexp'
file open myfile using "../Draft/nums/t_stdebtendofyear_toexp.tex", write replace
file write myfile "`t_stdebtendofyear_toexp'"
file close myfile

local abs_coef_stdebtendofyear_toexp = abs(_b[treatedXpost])
local abs_coef_stdebtendofyear_toexp : display %-9.2f `abs_coef_stdebtendofyear_toexp'
file open myfile using "../Draft/nums/abs_coef_stdebtendofyear_toexp.tex", write replace
file write myfile "`abs_coef_stdebtendofyear_toexp'"
file close myfile

}

// Separating two kinds of local governments

{

// (1)

reghdfe totalinterestondebt_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_totalinterestondebt_SD = _b[treatedXpost]
local coef_totalinterestondebt_SD : display %-9.2f `coef_totalinterestondebt_SD'
file open myfile using "../Draft/nums/coef_totalinterestondebt_SD.tex", write replace
file write myfile "`coef_totalinterestondebt_SD'"
file close myfile

local t_totalinterestondebt_SD = _b[treatedXpost]/_se[treatedXpost]
local t_totalinterestondebt_SD : display %-9.2f `t_totalinterestondebt_SD'
file open myfile using "../Draft/nums/t_totalinterestondebt_SD.tex", write replace
file write myfile "`t_totalinterestondebt_SD'"
file close myfile

reghdfe totalinterestondebt_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_totalinterestondebt_nonSD = _b[treatedXpost]
local coef_totalinterestondebt_nonSD : display %-9.2f `coef_totalinterestondebt_nonSD'
file open myfile using "../Draft/nums/coef_totalinterestondebt_nonSD.tex", write replace
file write myfile "`coef_totalinterestondebt_nonSD'"
file close myfile

local t_totalinterestondebt_nonSD = _b[treatedXpost]/_se[treatedXpost]
local t_totalinterestondebt_nonSD : display %-9.2f `t_totalinterestondebt_nonSD'
file open myfile using "../Draft/nums/t_totalinterestondebt_nonSD.tex", write replace
file write myfile "`t_totalinterestondebt_nonSD'"
file close myfile

// Number relative to sample mean

local coef_interest_nonSD_relative = _b[treatedXpost]
preserve
use `GovFinData', clear
sum totalinterestondebt_toexp if typecode!=5, d
restore
local coef_interest_nonSD_relative = `coef_interest_nonSD_relative'/r(mean)*100
local coef_interest_nonSD_relative : display %-9.1f `coef_interest_nonSD_relative'
file open myfile using "../Draft/nums/coef_totalinterestondebt_nonSD_relative.tex", write replace
file write myfile "`coef_interest_nonSD_relative'"
file close myfile

// (2)

reghdfe totalltdissued_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_totalltdissued_SD = _b[treatedXpost]
local coef_totalltdissued_SD : display %-9.2f `coef_totalltdissued_SD'
file open myfile using "../Draft/nums/coef_totalltdissued_SD.tex", write replace
file write myfile "`coef_totalltdissued_SD'"
file close myfile

local t_totalltdissued_SD = _b[treatedXpost]/_se[treatedXpost]
local t_totalltdissued_SD : display %-9.2f `t_totalltdissued_SD'
file open myfile using "../Draft/nums/t_totalltdissued_SD.tex", write replace
file write myfile "`t_totalltdissued_SD'"
file close myfile

// Number relative to sample mean

local coef_issued_SD_relative = _b[treatedXpost]
preserve
use `GovFinData', clear
sum totalltdissued_toexp if typecode==5, d
restore
local coef_issued_SD_relative = `coef_issued_SD_relative'/r(mean)*100
local coef_issued_SD_relative : display %-9.1f `coef_issued_SD_relative'
file open myfile using "../Draft/nums/coef_totalltdissued_SD_relative.tex", write replace
file write myfile "`coef_issued_SD_relative'"
file close myfile

reghdfe totalltdissued_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_totalltdissued_nonSD = _b[treatedXpost]
local coef_totalltdissued_nonSD : display %-9.2f `coef_totalltdissued_nonSD'
file open myfile using "../Draft/nums/coef_totalltdissued_nonSD.tex", write replace
file write myfile "`coef_totalltdissued_nonSD'"
file close myfile

local t_totalltdissued_nonSD = _b[treatedXpost]/_se[treatedXpost]
local t_totalltdissued_nonSD : display %-9.2f `t_totalltdissued_nonSD'
file open myfile using "../Draft/nums/t_totalltdissued_nonSD.tex", write replace
file write myfile "`t_totalltdissued_nonSD'"
file close myfile

// (3)

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_totaligrevenue_SD = _b[treatedXpost]
local coef_totaligrevenue_SD : display %-9.2f `coef_totaligrevenue_SD'
file open myfile using "../Draft/nums/coef_totaligrevenue_SD.tex", write replace
file write myfile "`coef_totaligrevenue_SD'"
file close myfile

local t_totaligrevenue_SD = _b[treatedXpost]/_se[treatedXpost]
local t_totaligrevenue_SD : display %-9.2f `t_totaligrevenue_SD'
file open myfile using "../Draft/nums/t_totaligrevenue_SD.tex", write replace
file write myfile "`t_totaligrevenue_SD'"
file close myfile

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_totaligrevenue_nonSD = _b[treatedXpost]
local coef_totaligrevenue_nonSD : display %-9.2f `coef_totaligrevenue_nonSD'
file open myfile using "../Draft/nums/coef_totaligrevenue_nonSD.tex", write replace
file write myfile "`coef_totaligrevenue_nonSD'"
file close myfile

local t_totaligrevenue_nonSD = _b[treatedXpost]/_se[treatedXpost]
local t_totaligrevenue_nonSD : display %-9.2f `t_totaligrevenue_nonSD'
file open myfile using "../Draft/nums/t_totaligrevenue_nonSD.tex", write replace
file write myfile "`t_totaligrevenue_nonSD'"
file close myfile

// (4)

reghdfe totaltaxes_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_totaltaxes_SD = _b[treatedXpost]
local coef_totaltaxes_SD : display %-9.2f `coef_totaltaxes_SD'
file open myfile using "../Draft/nums/coef_totaltaxes_SD.tex", write replace
file write myfile "`coef_totaltaxes_SD'"
file close myfile

local t_totaltaxes_SD = _b[treatedXpost]/_se[treatedXpost]
local t_totaltaxes_SD : display %-9.2f `t_totaltaxes_SD'
file open myfile using "../Draft/nums/t_totaltaxes_SD.tex", write replace
file write myfile "`t_totaltaxes_SD'"
file close myfile

reghdfe totaltaxes_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_totaltaxes_nonSD = _b[treatedXpost]
local coef_totaltaxes_nonSD : display %-9.2f `coef_totaltaxes_nonSD'
file open myfile using "../Draft/nums/coef_totaltaxes_nonSD.tex", write replace
file write myfile "`coef_totaltaxes_nonSD'"
file close myfile

local t_totaltaxes_nonSD = _b[treatedXpost]/_se[treatedXpost]
local t_totaltaxes_nonSD : display %-9.2f `t_totaltaxes_nonSD'
file open myfile using "../Draft/nums/t_totaltaxes_nonSD.tex", write replace
file write myfile "`t_totaltaxes_nonSD'"
file close myfile

// (5)

reghdfe propertytax_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_propertytax_SD = _b[treatedXpost]
local coef_propertytax_SD : display %-9.2f `coef_propertytax_SD'
file open myfile using "../Draft/nums/coef_propertytax_SD.tex", write replace
file write myfile "`coef_propertytax_SD'"
file close myfile

local t_propertytax_SD = _b[treatedXpost]/_se[treatedXpost]
local t_propertytax_SD : display %-9.2f `t_propertytax_SD'
file open myfile using "../Draft/nums/t_propertytax_SD.tex", write replace
file write myfile "`t_propertytax_SD'"
file close myfile

reghdfe propertytax_toexp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_propertytax_nonSD = _b[treatedXpost]
local coef_propertytax_nonSD : display %-9.2f `coef_propertytax_nonSD'
file open myfile using "../Draft/nums/coef_propertytax_nonSD.tex", write replace
file write myfile "`coef_propertytax_nonSD'"
file close myfile

local t_propertytax_nonSD = _b[treatedXpost]/_se[treatedXpost]
local t_propertytax_nonSD : display %-9.2f `t_propertytax_nonSD'
file open myfile using "../Draft/nums/t_propertytax_nonSD.tex", write replace
file write myfile "`t_propertytax_nonSD'"
file close myfile

// (6)

reghdfe surplus_ratio treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_surplus_ratio_SD = _b[treatedXpost]
local coef_surplus_ratio_SD : display %-9.2f `coef_surplus_ratio_SD'
file open myfile using "../Draft/nums/coef_surplus_ratio_SD.tex", write replace
file write myfile "`coef_surplus_ratio_SD'"
file close myfile

local t_surplus_ratio_SD = _b[treatedXpost]/_se[treatedXpost]
local t_surplus_ratio_SD : display %-9.2f `t_surplus_ratio_SD'
file open myfile using "../Draft/nums/t_surplus_ratio_SD.tex", write replace
file write myfile "`t_surplus_ratio_SD'"
file close myfile

reghdfe surplus_ratio treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_surplus_ratio_nonSD = _b[treatedXpost]
local coef_surplus_ratio_nonSD : display %-9.2f `coef_surplus_ratio_nonSD'
file open myfile using "../Draft/nums/coef_surplus_ratio_nonSD.tex", write replace
file write myfile "`coef_surplus_ratio_nonSD'"
file close myfile

local t_surplus_ratio_nonSD = _b[treatedXpost]/_se[treatedXpost]
local t_surplus_ratio_nonSD : display %-9.2f `t_surplus_ratio_nonSD'
file open myfile using "../Draft/nums/t_surplus_ratio_nonSD.tex", write replace
file write myfile "`t_surplus_ratio_nonSD'"
file close myfile

}




/*--------------------------------------------------------------------*/
/* Table: Per enrollment/capita dollar amount or logged specification */
/*--------------------------------------------------------------------*/

{
	
/* Per capita */

local outfile =  "../Draft/tabs/DID_GovFin_PC.tex"

tempfile table
tempname memhold
postfile `memhold' str100 varname str30 (coef1 coef2 coef3 coef4 coef5) using `table', replace
post `memhold' (" ") ("(1)") ("(2)") ("(3)") ("(4)") ("(5)")

// Panel A: School districts, using per student variable

post `memhold' (" ") (" ") (" ") (" ") (" ") (" ")
post `memhold' ("Panel A: School districts, using per student variable") (" ") (" ") (" ") (" ") (" ")
post `memhold' (" ") ("Interest Paid/") ("New Issuance/") ("Budget Surplus/") ("Rev.") ("Exp.")
post `memhold' (" ") ("Per Student") ("Per Student") ("Per Student") ("Per Student") ("Per Student")

reghdfe totalinterestondebt_pe treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef1 = _b[treatedXpost]
local t_coef1 = _b[treatedXpost]/_se[treatedXpost]
local p_coef1 = 2 * ttail(e(df_r), abs(`t_coef1'))
if `p_coef1' >= 0.10 {
	local b_coef1 = string(`b_coef1', "%6.2f")
} 
else if `p_coef1' < 0.10 & `p_coef1' >= 0.05 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "*"
} 
else if `p_coef1' < 0.05 & `p_coef1' >= 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "**"
} 
else if `p_coef1' < 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "***"
}
local t_coef1 = "(" + string(`t_coef1', "%6.2f") + ")"
local r2_coef1 = string(e(r2_a), "%6.3f")
local obs_coef1 = string(e(N), "%10.0fc")

reghdfe totalltdissued_pe treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef2 = _b[treatedXpost]
local t_coef2 = _b[treatedXpost]/_se[treatedXpost]
local p_coef2 = 2 * ttail(e(df_r), abs(`t_coef2'))
if `p_coef2' >= 0.10 {
	local b_coef2 = string(`b_coef2', "%6.2f")
} 
else if `p_coef2' < 0.10 & `p_coef2' >= 0.05 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "*"
} 
else if `p_coef2' < 0.05 & `p_coef2' >= 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "**"
} 
else if `p_coef2' < 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "***"
}
local t_coef2 = "(" + string(`t_coef2', "%6.2f") + ")"
local r2_coef2 = string(e(r2_a), "%6.3f")
local obs_coef2 = string(e(N), "%10.0fc")

reghdfe surplus_pe treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef3 = _b[treatedXpost]
local t_coef3 = _b[treatedXpost]/_se[treatedXpost]
local p_coef3 = 2 * ttail(e(df_r), abs(`t_coef3'))
if `p_coef3' >= 0.10 {
	local b_coef3 = string(`b_coef3', "%6.2f")
} 
else if `p_coef3' < 0.10 & `p_coef3' >= 0.05 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "*"
} 
else if `p_coef3' < 0.05 & `p_coef3' >= 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "**"
} 
else if `p_coef3' < 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "***"
}
local t_coef3 = "(" + string(`t_coef3', "%6.2f") + ")"
local r2_coef3 = string(e(r2_a), "%6.3f")
local obs_coef3 = string(e(N), "%10.0fc")

reghdfe totalrevenue_pe treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef7 = _b[treatedXpost]
local t_coef7 = _b[treatedXpost]/_se[treatedXpost]
local p_coef7 = 2 * ttail(e(df_r), abs(`t_coef7'))
if `p_coef7' >= 0.10 {
	local b_coef7 = string(`b_coef7', "%6.2f")
} 
else if `p_coef7' < 0.10 & `p_coef7' >= 0.05 {
	local b_coef7 = string(`b_coef7', "%6.2f") + "*"
} 
else if `p_coef7' < 0.05 & `p_coef7' >= 0.01 {
	local b_coef7 = string(`b_coef7', "%6.2f") + "**"
} 
else if `p_coef7' < 0.01 {
	local b_coef7 = string(`b_coef7', "%6.2f") + "***"
}
local t_coef7 = "(" + string(`t_coef7', "%6.2f") + ")"
local r2_coef7 = string(e(r2_a), "%6.3f")
local obs_coef7 = string(e(N), "%10.0fc")

reghdfe totalexpenditure_pe treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef8 = _b[treatedXpost]
local t_coef8 = _b[treatedXpost]/_se[treatedXpost]
local p_coef8 = 2 * ttail(e(df_r), abs(`t_coef8'))
if `p_coef8' >= 0.10 {
	local b_coef8 = string(`b_coef8', "%6.2f")
} 
else if `p_coef8' < 0.10 & `p_coef8' >= 0.05 {
	local b_coef8 = string(`b_coef8', "%6.2f") + "*"
} 
else if `p_coef8' < 0.05 & `p_coef8' >= 0.01 {
	local b_coef8 = string(`b_coef8', "%6.2f") + "**"
} 
else if `p_coef8' < 0.01 {
	local b_coef8 = string(`b_coef8', "%6.2f") + "***"
}
local t_coef8 = "(" + string(`t_coef8', "%6.2f") + ")"
local r2_coef8 = string(e(r2_a), "%6.3f")
local obs_coef8 = string(e(N), "%10.0fc")

post `memhold' ("Treated $\times$ Post") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'") ("`b_coef7'") ("`b_coef8'")
post `memhold' (" ") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'") ("`t_coef7'") ("`t_coef8'")

post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'") ("`obs_coef7'") ("`obs_coef8'")
post `memhold' ("Adjusted R-squared") ("`r2_coef1'") ("`r2_coef2'") ("`r2_coef3'") ("`r2_coef7'") ("`r2_coef8'")

// Panel B: Municipality/township/county, using per capita variable

post `memhold' (" ") (" ") (" ") (" ") (" ") (" ")
post `memhold' ("Panel B: Municipality/township/county, using per capita variable") (" ") (" ") (" ") (" ") (" ")
post `memhold' (" ") ("Interest Paid/") ("New Issuance/") ("Budget Surplus/") ("Rev.") ("Exp.")
post `memhold' (" ") ("Per Capita") ("Per Capita") ("Per Capita") ("Per Capita") ("Per Capita")

reghdfe totalinterestondebt_pc treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef1 = _b[treatedXpost]
local t_coef1 = _b[treatedXpost]/_se[treatedXpost]
local p_coef1 = 2 * ttail(e(df_r), abs(`t_coef1'))
if `p_coef1' >= 0.10 {
	local b_coef1 = string(`b_coef1', "%6.2f")
} 
else if `p_coef1' < 0.10 & `p_coef1' >= 0.05 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "*"
} 
else if `p_coef1' < 0.05 & `p_coef1' >= 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "**"
} 
else if `p_coef1' < 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "***"
}
local t_coef1 = "(" + string(`t_coef1', "%6.2f") + ")"
local r2_coef1 = string(e(r2_a), "%6.3f")
local obs_coef1 = string(e(N), "%10.0fc")

reghdfe totalltdissued_pc treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef2 = _b[treatedXpost]
local t_coef2 = _b[treatedXpost]/_se[treatedXpost]
local p_coef2 = 2 * ttail(e(df_r), abs(`t_coef2'))
if `p_coef2' >= 0.10 {
	local b_coef2 = string(`b_coef2', "%6.2f")
} 
else if `p_coef2' < 0.10 & `p_coef2' >= 0.05 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "*"
} 
else if `p_coef2' < 0.05 & `p_coef2' >= 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "**"
} 
else if `p_coef2' < 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "***"
}
local t_coef2 = "(" + string(`t_coef2', "%6.2f") + ")"
local r2_coef2 = string(e(r2_a), "%6.3f")
local obs_coef2 = string(e(N), "%10.0fc")

reghdfe surplus_pc treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef3 = _b[treatedXpost]
local t_coef3 = _b[treatedXpost]/_se[treatedXpost]
local p_coef3 = 2 * ttail(e(df_r), abs(`t_coef3'))
if `p_coef3' >= 0.10 {
	local b_coef3 = string(`b_coef3', "%6.2f")
} 
else if `p_coef3' < 0.10 & `p_coef3' >= 0.05 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "*"
} 
else if `p_coef3' < 0.05 & `p_coef3' >= 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "**"
} 
else if `p_coef3' < 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "***"
}
local t_coef3 = "(" + string(`t_coef3', "%6.2f") + ")"
local r2_coef3 = string(e(r2_a), "%6.3f")
local obs_coef3 = string(e(N), "%10.0fc")

reghdfe totalrevenue_pc treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef7 = _b[treatedXpost]
local t_coef7 = _b[treatedXpost]/_se[treatedXpost]
local p_coef7 = 2 * ttail(e(df_r), abs(`t_coef7'))
if `p_coef7' >= 0.10 {
	local b_coef7 = string(`b_coef7', "%6.2f")
} 
else if `p_coef7' < 0.10 & `p_coef7' >= 0.05 {
	local b_coef7 = string(`b_coef7', "%6.2f") + "*"
} 
else if `p_coef7' < 0.05 & `p_coef7' >= 0.01 {
	local b_coef7 = string(`b_coef7', "%6.2f") + "**"
} 
else if `p_coef7' < 0.01 {
	local b_coef7 = string(`b_coef7', "%6.2f") + "***"
}
local t_coef7 = "(" + string(`t_coef7', "%6.2f") + ")"
local r2_coef7 = string(e(r2_a), "%6.3f")
local obs_coef7 = string(e(N), "%10.0fc")

reghdfe totalexpenditure_pc treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef8 = _b[treatedXpost]
local t_coef8 = _b[treatedXpost]/_se[treatedXpost]
local p_coef8 = 2 * ttail(e(df_r), abs(`t_coef8'))
if `p_coef8' >= 0.10 {
	local b_coef8 = string(`b_coef8', "%6.2f")
} 
else if `p_coef8' < 0.10 & `p_coef8' >= 0.05 {
	local b_coef8 = string(`b_coef8', "%6.2f") + "*"
} 
else if `p_coef8' < 0.05 & `p_coef8' >= 0.01 {
	local b_coef8 = string(`b_coef8', "%6.2f") + "**"
} 
else if `p_coef8' < 0.01 {
	local b_coef8 = string(`b_coef8', "%6.2f") + "***"
}
local t_coef8 = "(" + string(`t_coef8', "%6.2f") + ")"
local r2_coef8 = string(e(r2_a), "%6.3f")
local obs_coef8 = string(e(N), "%10.0fc")

post `memhold' ("Treated $\times$ Post") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'") ("`b_coef7'") ("`b_coef8'")
post `memhold' (" ") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'") ("`t_coef7'") ("`t_coef8'")

post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'") ("`obs_coef7'") ("`obs_coef8'")
post `memhold' ("Adjusted R-squared") ("`r2_coef1'") ("`r2_coef2'") ("`r2_coef3'") ("`r2_coef7'") ("`r2_coef8'")


postclose `memhold'

preserve
use `table', clear
texsave using "`outfile'", replace dataonly nonames italics("Panel") nofix hlines(1)
restore

}




/*------------------------------------------------------------------*/
/* Export numbers using the dollar per student/capita specification */
/*------------------------------------------------------------------*/

{

// (2)

reghdfe totalltdissued_pe treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_totalltdissued_SD_pe = _b[treatedXpost]
local coef_totalltdissued_SD_pe : display %-9.1f `coef_totalltdissued_SD_pe'
file open myfile using "../Draft/nums/coef_totalltdissued_SD_pe.tex", write replace
file write myfile "`coef_totalltdissued_SD_pe'"
file close myfile

local t_totalltdissued_SD_pe = _b[treatedXpost]/_se[treatedXpost]
local t_totalltdissued_SD_pe : display %-9.2f `t_totalltdissued_SD_pe'
file open myfile using "../Draft/nums/t_totalltdissued_SD_pe.tex", write replace
file write myfile "`t_totalltdissued_SD_pe'"
file close myfile

local abs_coef_totalltdissued_SD_pe = abs(_b[treatedXpost])
local abs_coef_totalltdissued_SD_pe : display %-9.1f `abs_coef_totalltdissued_SD_pe'
file open myfile using "../Draft/nums/abs_coef_totalltdissued_SD_pe.tex", write replace
file write myfile "`abs_coef_totalltdissued_SD_pe'"
file close myfile

reghdfe totalltdissued_pc treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_ltdissued_nonSD_pc = _b[treatedXpost]
local coef_ltdissued_nonSD_pc : display %-9.1f `coef_ltdissued_nonSD_pc'
file open myfile using "../Draft/nums/coef_totalltdissued_nonSD_pc.tex", write replace
file write myfile "`coef_ltdissued_nonSD_pc'"
file close myfile

local t_totalltdissued_nonSD_pc = _b[treatedXpost]/_se[treatedXpost]
local t_totalltdissued_nonSD_pc : display %-9.2f `t_totalltdissued_nonSD_pc'
file open myfile using "../Draft/nums/t_totalltdissued_nonSD_pc.tex", write replace
file write myfile "`t_totalltdissued_nonSD_pc'"
file close myfile

local abs_coef_ltdissued_nonSD_pc = abs(_b[treatedXpost])
local abs_coef_ltdissued_nonSD_pc : display %-9.1f `abs_coef_ltdissued_nonSD_pc'
file open myfile using "../Draft/nums/abs_coef_totalltdissued_nonSD_pc.tex", write replace
file write myfile "`abs_coef_ltdissued_nonSD_pc'"
file close myfile

// (7)

reghdfe totalrevenue_pe treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_totalrevenue_SD_pe = _b[treatedXpost]
local coef_totalrevenue_SD_pe : display %-9.1f `coef_totalrevenue_SD_pe'
file open myfile using "../Draft/nums/coef_totalrevenue_SD_pe.tex", write replace
file write myfile "`coef_totalrevenue_SD_pe'"
file close myfile

local t_totalrevenue_SD_pe = _b[treatedXpost]/_se[treatedXpost]
local t_totalrevenue_SD_pe : display %-9.2f `t_totalrevenue_SD_pe'
file open myfile using "../Draft/nums/t_totalrevenue_SD_pe.tex", write replace
file write myfile "`t_totalrevenue_SD_pe'"
file close myfile

local abs_coef_totalrevenue_SD_pe = abs(_b[treatedXpost])
local abs_coef_totalrevenue_SD_pe : display %-9.1f `abs_coef_totalrevenue_SD_pe'
file open myfile using "../Draft/nums/abs_coef_totalrevenue_SD_pe.tex", write replace
file write myfile "`abs_coef_totalrevenue_SD_pe'"
file close myfile

reghdfe totalrevenue_pc treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_ltdissued_nonSD_pc = _b[treatedXpost]
local coef_ltdissued_nonSD_pc : display %-9.1f `coef_ltdissued_nonSD_pc'
file open myfile using "../Draft/nums/coef_totalrevenue_nonSD_pc.tex", write replace
file write myfile "`coef_ltdissued_nonSD_pc'"
file close myfile

local t_totalrevenue_nonSD_pc = _b[treatedXpost]/_se[treatedXpost]
local t_totalrevenue_nonSD_pc : display %-9.2f `t_totalrevenue_nonSD_pc'
file open myfile using "../Draft/nums/t_totalrevenue_nonSD_pc.tex", write replace
file write myfile "`t_totalrevenue_nonSD_pc'"
file close myfile

local abs_coef_ltdissued_nonSD_pc = abs(_b[treatedXpost])
local abs_coef_ltdissued_nonSD_pc : display %-9.1f `abs_coef_ltdissued_nonSD_pc'
file open myfile using "../Draft/nums/abs_coef_totalrevenue_nonSD_pc.tex", write replace
file write myfile "`abs_coef_ltdissued_nonSD_pc'"
file close myfile

// (8)

reghdfe totalexpenditure_pe treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_totalexpenditure_SD_pe = _b[treatedXpost]
local coef_totalexpenditure_SD_pe : display %-9.1f `coef_totalexpenditure_SD_pe'
file open myfile using "../Draft/nums/coef_totalexpenditure_SD_pe.tex", write replace
file write myfile "`coef_totalexpenditure_SD_pe'"
file close myfile

local t_totalexpenditure_SD_pe = _b[treatedXpost]/_se[treatedXpost]
local t_totalexpenditure_SD_pe : display %-9.2f `t_totalexpenditure_SD_pe'
file open myfile using "../Draft/nums/t_totalexpenditure_SD_pe.tex", write replace
file write myfile "`t_totalexpenditure_SD_pe'"
file close myfile

local abs_coef_totalexpenditure_SD_pe = abs(_b[treatedXpost])
local abs_coef_totalexpenditure_SD_pe : display %-9.1f `abs_coef_totalexpenditure_SD_pe'
file open myfile using "../Draft/nums/abs_coef_totalexpenditure_SD_pe.tex", write replace
file write myfile "`abs_coef_totalexpenditure_SD_pe'"
file close myfile

reghdfe totalexpenditure_pc treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local coef_ltdissued_nonSD_pc = _b[treatedXpost]
local coef_ltdissued_nonSD_pc : display %-9.1f `coef_ltdissued_nonSD_pc'
file open myfile using "../Draft/nums/coef_totalexpenditure_nonSD_pc.tex", write replace
file write myfile "`coef_ltdissued_nonSD_pc'"
file close myfile

local t_totalexpenditure_nonSD_pc = _b[treatedXpost]/_se[treatedXpost]
local t_totalexpenditure_nonSD_pc : display %-9.2f `t_totalexpenditure_nonSD_pc'
file open myfile using "../Draft/nums/t_totalexpenditure_nonSD_pc.tex", write replace
file write myfile "`t_totalexpenditure_nonSD_pc'"
file close myfile

local abs_coef_ltdissued_nonSD_pc = abs(_b[treatedXpost])
local abs_coef_ltdissued_nonSD_pc : display %-9.1f `abs_coef_ltdissued_nonSD_pc'
file open myfile using "../Draft/nums/abs_coef_totalexpenditure_nonSD_pc.tex", write replace
file write myfile "`abs_coef_ltdissued_nonSD_pc'"
file close myfile

}



/*------------------------------------------------------------*/
/* Panel: Which type of inter-government transfer is reduced? */
/*------------------------------------------------------------*/

{

local outfile =  "../Draft/tabs/DID_GovFin_IG.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

reghdfe totalfedigrevenue_toexp (is_schooldistrict is_not_schooldistrict)##(treated post) TXPXis_schooldistrict TXPXis_not_schooldistrict ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(TXPXis_schooldistrict TXPXis_not_schooldistrict) `outputoptions' ctitle("Inter-Gov. Trans. from Federal/","Exp. (in %)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Government $\times$ FE", "Yes","Clustering","CSA \& Year")

reghdfe totalstateigrevenue_toexp (is_schooldistrict is_not_schooldistrict)##(treated post) TXPXis_schooldistrict TXPXis_not_schooldistrict ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(TXPXis_schooldistrict TXPXis_not_schooldistrict) `outputoptions' ctitle("Inter-Gov. Trans. from State/","Exp. (in %)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Government $\times$ FE", "Yes","Clustering","CSA \& Year")

reghdfe totlocaligrev_toexp (is_schooldistrict is_not_schooldistrict)##(treated post) TXPXis_schooldistrict TXPXis_not_schooldistrict ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(TXPXis_schooldistrict TXPXis_not_schooldistrict) `outputoptions' ctitle("Inter-Gov. Trans. from Local/","Exp. (in %)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Government $\times$ FE", "Yes","Clustering","CSA \& Year")

}



/*-------------------------------------------------------------------------------------*/
/* Panel: Using M&As more likely to be exogeneous or influenced by commercial bank M&A */
/*-------------------------------------------------------------------------------------*/

{

local outfile =  "../Draft/tabs/DID_GovFin_toexp_CleanSample.tex"

tempfile table
tempname memhold
postfile `memhold' str120 varname str30 (coef1 coef2 coef3) using `table', replace
post `memhold' (" ") ("(1)") ("(2)") ("(3)")
post `memhold' (" ") ("Interest Paid/") ("New Issuance/") ("Budget Surplus/")
post `memhold' (" ") ("Exp. (in \%)") ("Exp. (in \%)") ("Exp. (in \%)")

// Panel A: Require M&A is for reasons unlikely to be related to local economic conditions

// Row 1: School districts

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel A: M\&As are driven by reasons likely unrelated to local economic dynamics according to news articles, School Districts") (" ") (" ") (" ")

reghdfe totalinterestondebt_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & reasonma_endo_possible=="False" & is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef1 = _b[treatedXpost]
local t_coef1 = _b[treatedXpost]/_se[treatedXpost]
local p_coef1 = 2 * ttail(e(df_r), abs(`t_coef1'))
if `p_coef1' >= 0.10 {
	local b_coef1 = string(`b_coef1', "%6.2f")
} 
else if `p_coef1' < 0.10 & `p_coef1' >= 0.05 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "*"
} 
else if `p_coef1' < 0.05 & `p_coef1' >= 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "**"
} 
else if `p_coef1' < 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "***"
}
local t_coef1 = "(" + string(`t_coef1', "%6.2f") + ")"
local r2_coef1 = string(e(r2_a), "%6.3f")
local obs_coef1 = string(e(N), "%10.0fc")

reghdfe totalltdissued_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & reasonma_endo_possible=="False" & is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef2 = _b[treatedXpost]
local t_coef2 = _b[treatedXpost]/_se[treatedXpost]
local p_coef2 = 2 * ttail(e(df_r), abs(`t_coef2'))
if `p_coef2' >= 0.10 {
	local b_coef2 = string(`b_coef2', "%6.2f")
} 
else if `p_coef2' < 0.10 & `p_coef2' >= 0.05 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "*"
} 
else if `p_coef2' < 0.05 & `p_coef2' >= 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "**"
} 
else if `p_coef2' < 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "***"
}
local t_coef2 = "(" + string(`t_coef2', "%6.2f") + ")"
local r2_coef2 = string(e(r2_a), "%6.3f")
local obs_coef2 = string(e(N), "%10.0fc")

reghdfe surplus_ratio treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & reasonma_endo_possible=="False" & is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef3 = _b[treatedXpost]
local t_coef3 = _b[treatedXpost]/_se[treatedXpost]
local p_coef3 = 2 * ttail(e(df_r), abs(`t_coef3'))
if `p_coef3' >= 0.10 {
	local b_coef3 = string(`b_coef3', "%6.2f")
} 
else if `p_coef3' < 0.10 & `p_coef3' >= 0.05 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "*"
} 
else if `p_coef3' < 0.05 & `p_coef3' >= 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "**"
} 
else if `p_coef3' < 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "***"
}
local t_coef3 = "(" + string(`t_coef3', "%6.2f") + ")"
local r2_coef3 = string(e(r2_a), "%6.3f")
local obs_coef3 = string(e(N), "%10.0fc")

reghdfe totaltaxes_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & reasonma_endo_possible=="False" & is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef4 = _b[treatedXpost]
local t_coef4 = _b[treatedXpost]/_se[treatedXpost]
local p_coef4 = 2 * ttail(e(df_r), abs(`t_coef4'))
if `p_coef4' >= 0.10 {
	local b_coef4 = string(`b_coef4', "%6.2f")
} 
else if `p_coef4' < 0.10 & `p_coef4' >= 0.05 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "*"
} 
else if `p_coef4' < 0.05 & `p_coef4' >= 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "**"
} 
else if `p_coef4' < 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "***"
}
local t_coef4 = "(" + string(`t_coef4', "%6.2f") + ")"
local r2_coef4 = string(e(r2_a), "%6.3f")
local obs_coef4 = string(e(N), "%10.0fc")

reghdfe propertytax_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & reasonma_endo_possible=="False" & is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef5 = _b[treatedXpost]
local t_coef5 = _b[treatedXpost]/_se[treatedXpost]
local p_coef5 = 2 * ttail(e(df_r), abs(`t_coef5'))
if `p_coef5' >= 0.10 {
	local b_coef5 = string(`b_coef5', "%6.2f")
} 
else if `p_coef5' < 0.10 & `p_coef5' >= 0.05 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "*"
} 
else if `p_coef5' < 0.05 & `p_coef5' >= 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "**"
} 
else if `p_coef5' < 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "***"
}
local t_coef5 = "(" + string(`t_coef5', "%6.2f") + ")"
local r2_coef5 = string(e(r2_a), "%6.3f")
local obs_coef5 = string(e(N), "%10.0fc")

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & reasonma_endo_possible=="False" & is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef6 = _b[treatedXpost]
local t_coef6 = _b[treatedXpost]/_se[treatedXpost]
local p_coef6 = 2 * ttail(e(df_r), abs(`t_coef6'))
if `p_coef6' >= 0.10 {
	local b_coef6 = string(`b_coef6', "%6.2f")
} 
else if `p_coef6' < 0.10 & `p_coef6' >= 0.05 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "*"
} 
else if `p_coef6' < 0.05 & `p_coef6' >= 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "**"
} 
else if `p_coef6' < 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "***"
}
local t_coef6 = "(" + string(`t_coef6', "%6.2f") + ")"
local r2_coef6 = string(e(r2_a), "%6.3f")
local obs_coef6 = string(e(N), "%10.0fc")

post `memhold' ("Treated $\times$ Post") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
post `memhold' (" ") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'")

// Row 2: Non-School districts

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel B: M\&As are driven by reasons likely unrelated to local economic dynamics according to news articles, Municipalities/Townships/Counties") (" ") (" ") (" ")

reghdfe totalinterestondebt_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & reasonma_endo_possible=="False" & is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef1 = _b[treatedXpost]
local t_coef1 = _b[treatedXpost]/_se[treatedXpost]
local p_coef1 = 2 * ttail(e(df_r), abs(`t_coef1'))
if `p_coef1' >= 0.10 {
	local b_coef1 = string(`b_coef1', "%6.2f")
} 
else if `p_coef1' < 0.10 & `p_coef1' >= 0.05 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "*"
} 
else if `p_coef1' < 0.05 & `p_coef1' >= 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "**"
} 
else if `p_coef1' < 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "***"
}
local t_coef1 = "(" + string(`t_coef1', "%6.2f") + ")"
local r2_coef1 = string(e(r2_a), "%6.3f")
local obs_coef1 = string(e(N), "%10.0fc")

reghdfe totalltdissued_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & reasonma_endo_possible=="False" & is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef2 = _b[treatedXpost]
local t_coef2 = _b[treatedXpost]/_se[treatedXpost]
local p_coef2 = 2 * ttail(e(df_r), abs(`t_coef2'))
if `p_coef2' >= 0.10 {
	local b_coef2 = string(`b_coef2', "%6.2f")
} 
else if `p_coef2' < 0.10 & `p_coef2' >= 0.05 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "*"
} 
else if `p_coef2' < 0.05 & `p_coef2' >= 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "**"
} 
else if `p_coef2' < 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "***"
}
local t_coef2 = "(" + string(`t_coef2', "%6.2f") + ")"
local r2_coef2 = string(e(r2_a), "%6.3f")
local obs_coef2 = string(e(N), "%10.0fc")

reghdfe surplus_ratio treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & reasonma_endo_possible=="False" & is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef3 = _b[treatedXpost]
local t_coef3 = _b[treatedXpost]/_se[treatedXpost]
local p_coef3 = 2 * ttail(e(df_r), abs(`t_coef3'))
if `p_coef3' >= 0.10 {
	local b_coef3 = string(`b_coef3', "%6.2f")
} 
else if `p_coef3' < 0.10 & `p_coef3' >= 0.05 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "*"
} 
else if `p_coef3' < 0.05 & `p_coef3' >= 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "**"
} 
else if `p_coef3' < 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "***"
}
local t_coef3 = "(" + string(`t_coef3', "%6.2f") + ")"
local r2_coef3 = string(e(r2_a), "%6.3f")
local obs_coef3 = string(e(N), "%10.0fc")

reghdfe totaltaxes_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & reasonma_endo_possible=="False" & is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef4 = _b[treatedXpost]
local t_coef4 = _b[treatedXpost]/_se[treatedXpost]
local p_coef4 = 2 * ttail(e(df_r), abs(`t_coef4'))
if `p_coef4' >= 0.10 {
	local b_coef4 = string(`b_coef4', "%6.2f")
} 
else if `p_coef4' < 0.10 & `p_coef4' >= 0.05 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "*"
} 
else if `p_coef4' < 0.05 & `p_coef4' >= 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "**"
} 
else if `p_coef4' < 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "***"
}
local t_coef4 = "(" + string(`t_coef4', "%6.2f") + ")"
local r2_coef4 = string(e(r2_a), "%6.3f")
local obs_coef4 = string(e(N), "%10.0fc")

reghdfe propertytax_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & reasonma_endo_possible=="False" & is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef5 = _b[treatedXpost]
local t_coef5 = _b[treatedXpost]/_se[treatedXpost]
local p_coef5 = 2 * ttail(e(df_r), abs(`t_coef5'))
if `p_coef5' >= 0.10 {
	local b_coef5 = string(`b_coef5', "%6.2f")
} 
else if `p_coef5' < 0.10 & `p_coef5' >= 0.05 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "*"
} 
else if `p_coef5' < 0.05 & `p_coef5' >= 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "**"
} 
else if `p_coef5' < 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "***"
}
local t_coef5 = "(" + string(`t_coef5', "%6.2f") + ")"
local r2_coef5 = string(e(r2_a), "%6.3f")
local obs_coef5 = string(e(N), "%10.0fc")

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & reasonma_endo_possible=="False" & is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef6 = _b[treatedXpost]
local t_coef6 = _b[treatedXpost]/_se[treatedXpost]
local p_coef6 = 2 * ttail(e(df_r), abs(`t_coef6'))
if `p_coef6' >= 0.10 {
	local b_coef6 = string(`b_coef6', "%6.2f")
} 
else if `p_coef6' < 0.10 & `p_coef6' >= 0.05 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "*"
} 
else if `p_coef6' < 0.05 & `p_coef6' >= 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "**"
} 
else if `p_coef6' < 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "***"
}
local t_coef6 = "(" + string(`t_coef6', "%6.2f") + ")"
local r2_coef6 = string(e(r2_a), "%6.3f")
local obs_coef6 = string(e(N), "%10.0fc")

post `memhold' ("Treated $\times$ Post") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
post `memhold' (" ") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'")

// Panel B: Require weight less than 10% for both acquiror and target firms

// Row 1: School districts

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel C: CSA makes up a small fraction of the total businesses of the merging underwriters, School Districts") (" ") (" ") (" ")

reghdfe totalinterestondebt_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & (max_acquiror_weight<0.1&max_target_weight<0.1) & is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef1 = _b[treatedXpost]
local t_coef1 = _b[treatedXpost]/_se[treatedXpost]
local p_coef1 = 2 * ttail(e(df_r), abs(`t_coef1'))
if `p_coef1' >= 0.10 {
	local b_coef1 = string(`b_coef1', "%6.2f")
} 
else if `p_coef1' < 0.10 & `p_coef1' >= 0.05 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "*"
} 
else if `p_coef1' < 0.05 & `p_coef1' >= 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "**"
} 
else if `p_coef1' < 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "***"
}
local t_coef1 = "(" + string(`t_coef1', "%6.2f") + ")"
local r2_coef1 = string(e(r2_a), "%6.3f")
local obs_coef1 = string(e(N), "%10.0fc")

reghdfe totalltdissued_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & (max_acquiror_weight<0.1&max_target_weight<0.1) & is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef2 = _b[treatedXpost]
local t_coef2 = _b[treatedXpost]/_se[treatedXpost]
local p_coef2 = 2 * ttail(e(df_r), abs(`t_coef2'))
if `p_coef2' >= 0.10 {
	local b_coef2 = string(`b_coef2', "%6.2f")
} 
else if `p_coef2' < 0.10 & `p_coef2' >= 0.05 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "*"
} 
else if `p_coef2' < 0.05 & `p_coef2' >= 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "**"
} 
else if `p_coef2' < 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "***"
}
local t_coef2 = "(" + string(`t_coef2', "%6.2f") + ")"
local r2_coef2 = string(e(r2_a), "%6.3f")
local obs_coef2 = string(e(N), "%10.0fc")

reghdfe surplus_ratio treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & (max_acquiror_weight<0.1&max_target_weight<0.1) & is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef3 = _b[treatedXpost]
local t_coef3 = _b[treatedXpost]/_se[treatedXpost]
local p_coef3 = 2 * ttail(e(df_r), abs(`t_coef3'))
if `p_coef3' >= 0.10 {
	local b_coef3 = string(`b_coef3', "%6.2f")
} 
else if `p_coef3' < 0.10 & `p_coef3' >= 0.05 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "*"
} 
else if `p_coef3' < 0.05 & `p_coef3' >= 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "**"
} 
else if `p_coef3' < 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "***"
}
local t_coef3 = "(" + string(`t_coef3', "%6.2f") + ")"
local r2_coef3 = string(e(r2_a), "%6.3f")
local obs_coef3 = string(e(N), "%10.0fc")

reghdfe totaltaxes_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & (max_acquiror_weight<0.1&max_target_weight<0.1) & is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef4 = _b[treatedXpost]
local t_coef4 = _b[treatedXpost]/_se[treatedXpost]
local p_coef4 = 2 * ttail(e(df_r), abs(`t_coef4'))
if `p_coef4' >= 0.10 {
	local b_coef4 = string(`b_coef4', "%6.2f")
} 
else if `p_coef4' < 0.10 & `p_coef4' >= 0.05 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "*"
} 
else if `p_coef4' < 0.05 & `p_coef4' >= 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "**"
} 
else if `p_coef4' < 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "***"
}
local t_coef4 = "(" + string(`t_coef4', "%6.2f") + ")"
local r2_coef4 = string(e(r2_a), "%6.3f")
local obs_coef4 = string(e(N), "%10.0fc")

reghdfe propertytax_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & (max_acquiror_weight<0.1&max_target_weight<0.1) & is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef5 = _b[treatedXpost]
local t_coef5 = _b[treatedXpost]/_se[treatedXpost]
local p_coef5 = 2 * ttail(e(df_r), abs(`t_coef5'))
if `p_coef5' >= 0.10 {
	local b_coef5 = string(`b_coef5', "%6.2f")
} 
else if `p_coef5' < 0.10 & `p_coef5' >= 0.05 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "*"
} 
else if `p_coef5' < 0.05 & `p_coef5' >= 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "**"
} 
else if `p_coef5' < 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "***"
}
local t_coef5 = "(" + string(`t_coef5', "%6.2f") + ")"
local r2_coef5 = string(e(r2_a), "%6.3f")
local obs_coef5 = string(e(N), "%10.0fc")

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & (max_acquiror_weight<0.1&max_target_weight<0.1) & is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef6 = _b[treatedXpost]
local t_coef6 = _b[treatedXpost]/_se[treatedXpost]
local p_coef6 = 2 * ttail(e(df_r), abs(`t_coef6'))
if `p_coef6' >= 0.10 {
	local b_coef6 = string(`b_coef6', "%6.2f")
} 
else if `p_coef6' < 0.10 & `p_coef6' >= 0.05 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "*"
} 
else if `p_coef6' < 0.05 & `p_coef6' >= 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "**"
} 
else if `p_coef6' < 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "***"
}
local t_coef6 = "(" + string(`t_coef6', "%6.2f") + ")"
local r2_coef6 = string(e(r2_a), "%6.3f")
local obs_coef6 = string(e(N), "%10.0fc")

post `memhold' ("Treated $\times$ Post") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
post `memhold' (" ") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'")

// Row 2: Non-School districts

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel D: CSA makes up a small fraction of the total businesses of the merging underwriters, Municipalities/Townships/Counties") (" ") (" ") (" ")

reghdfe totalinterestondebt_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & (max_acquiror_weight<0.1&max_target_weight<0.1) & is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef1 = _b[treatedXpost]
local t_coef1 = _b[treatedXpost]/_se[treatedXpost]
local p_coef1 = 2 * ttail(e(df_r), abs(`t_coef1'))
if `p_coef1' >= 0.10 {
	local b_coef1 = string(`b_coef1', "%6.2f")
} 
else if `p_coef1' < 0.10 & `p_coef1' >= 0.05 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "*"
} 
else if `p_coef1' < 0.05 & `p_coef1' >= 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "**"
} 
else if `p_coef1' < 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "***"
}
local t_coef1 = "(" + string(`t_coef1', "%6.2f") + ")"
local r2_coef1 = string(e(r2_a), "%6.3f")
local obs_coef1 = string(e(N), "%10.0fc")

reghdfe totalltdissued_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & (max_acquiror_weight<0.1&max_target_weight<0.1) & is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef2 = _b[treatedXpost]
local t_coef2 = _b[treatedXpost]/_se[treatedXpost]
local p_coef2 = 2 * ttail(e(df_r), abs(`t_coef2'))
if `p_coef2' >= 0.10 {
	local b_coef2 = string(`b_coef2', "%6.2f")
} 
else if `p_coef2' < 0.10 & `p_coef2' >= 0.05 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "*"
} 
else if `p_coef2' < 0.05 & `p_coef2' >= 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "**"
} 
else if `p_coef2' < 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "***"
}
local t_coef2 = "(" + string(`t_coef2', "%6.2f") + ")"
local r2_coef2 = string(e(r2_a), "%6.3f")
local obs_coef2 = string(e(N), "%10.0fc")

reghdfe surplus_ratio treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & (max_acquiror_weight<0.1&max_target_weight<0.1) & is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef3 = _b[treatedXpost]
local t_coef3 = _b[treatedXpost]/_se[treatedXpost]
local p_coef3 = 2 * ttail(e(df_r), abs(`t_coef3'))
if `p_coef3' >= 0.10 {
	local b_coef3 = string(`b_coef3', "%6.2f")
} 
else if `p_coef3' < 0.10 & `p_coef3' >= 0.05 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "*"
} 
else if `p_coef3' < 0.05 & `p_coef3' >= 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "**"
} 
else if `p_coef3' < 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "***"
}
local t_coef3 = "(" + string(`t_coef3', "%6.2f") + ")"
local r2_coef3 = string(e(r2_a), "%6.3f")
local obs_coef3 = string(e(N), "%10.0fc")

reghdfe totaltaxes_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & (max_acquiror_weight<0.1&max_target_weight<0.1) & is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef4 = _b[treatedXpost]
local t_coef4 = _b[treatedXpost]/_se[treatedXpost]
local p_coef4 = 2 * ttail(e(df_r), abs(`t_coef4'))
if `p_coef4' >= 0.10 {
	local b_coef4 = string(`b_coef4', "%6.2f")
} 
else if `p_coef4' < 0.10 & `p_coef4' >= 0.05 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "*"
} 
else if `p_coef4' < 0.05 & `p_coef4' >= 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "**"
} 
else if `p_coef4' < 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "***"
}
local t_coef4 = "(" + string(`t_coef4', "%6.2f") + ")"
local r2_coef4 = string(e(r2_a), "%6.3f")
local obs_coef4 = string(e(N), "%10.0fc")

reghdfe propertytax_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & (max_acquiror_weight<0.1&max_target_weight<0.1) & is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef5 = _b[treatedXpost]
local t_coef5 = _b[treatedXpost]/_se[treatedXpost]
local p_coef5 = 2 * ttail(e(df_r), abs(`t_coef5'))
if `p_coef5' >= 0.10 {
	local b_coef5 = string(`b_coef5', "%6.2f")
} 
else if `p_coef5' < 0.10 & `p_coef5' >= 0.05 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "*"
} 
else if `p_coef5' < 0.05 & `p_coef5' >= 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "**"
} 
else if `p_coef5' < 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "***"
}
local t_coef5 = "(" + string(`t_coef5', "%6.2f") + ")"
local r2_coef5 = string(e(r2_a), "%6.3f")
local obs_coef5 = string(e(N), "%10.0fc")

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4) & (max_acquiror_weight<0.1&max_target_weight<0.1) & is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef6 = _b[treatedXpost]
local t_coef6 = _b[treatedXpost]/_se[treatedXpost]
local p_coef6 = 2 * ttail(e(df_r), abs(`t_coef6'))
if `p_coef6' >= 0.10 {
	local b_coef6 = string(`b_coef6', "%6.2f")
} 
else if `p_coef6' < 0.10 & `p_coef6' >= 0.05 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "*"
} 
else if `p_coef6' < 0.05 & `p_coef6' >= 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "**"
} 
else if `p_coef6' < 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "***"
}
local t_coef6 = "(" + string(`t_coef6', "%6.2f") + ")"
local r2_coef6 = string(e(r2_a), "%6.3f")
local obs_coef6 = string(e(N), "%10.0fc")

post `memhold' ("Treated $\times$ Post") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
post `memhold' (" ") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'")

// Panel C: Using M&As episodes that are not confounded by concurrent commercial bank M&A

preserve

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIByN_excludeCBConfound_GovFin.csv", clear

do 8B_Proc_GovFin.do

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

gen is_schooldistrict = typecode==5
gen is_not_schooldistrict = typecode!=5

gen TXPXis_schooldistrict = treatedXpost*is_schooldistrict
gen TXPXis_not_schooldistrict = treatedXpost*is_not_schooldistrict

// Row 1: School districts

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel E: M\&As are not confouned by concurrent commercial bank M\&A, School Districts") (" ") (" ") (" ")

reghdfe totalinterestondebt_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4)&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef1 = _b[treatedXpost]
local t_coef1 = _b[treatedXpost]/_se[treatedXpost]
local p_coef1 = 2 * ttail(e(df_r), abs(`t_coef1'))
if `p_coef1' >= 0.10 {
	local b_coef1 = string(`b_coef1', "%6.2f")
} 
else if `p_coef1' < 0.10 & `p_coef1' >= 0.05 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "*"
} 
else if `p_coef1' < 0.05 & `p_coef1' >= 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "**"
} 
else if `p_coef1' < 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "***"
}
local t_coef1 = "(" + string(`t_coef1', "%6.2f") + ")"
local r2_coef1 = string(e(r2_a), "%6.3f")
local obs_coef1 = string(e(N), "%10.0fc")

reghdfe totalltdissued_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4)&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef2 = _b[treatedXpost]
local t_coef2 = _b[treatedXpost]/_se[treatedXpost]
local p_coef2 = 2 * ttail(e(df_r), abs(`t_coef2'))
if `p_coef2' >= 0.10 {
	local b_coef2 = string(`b_coef2', "%6.2f")
} 
else if `p_coef2' < 0.10 & `p_coef2' >= 0.05 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "*"
} 
else if `p_coef2' < 0.05 & `p_coef2' >= 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "**"
} 
else if `p_coef2' < 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "***"
}
local t_coef2 = "(" + string(`t_coef2', "%6.2f") + ")"
local r2_coef2 = string(e(r2_a), "%6.3f")
local obs_coef2 = string(e(N), "%10.0fc")

reghdfe surplus_ratio treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4)&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef3 = _b[treatedXpost]
local t_coef3 = _b[treatedXpost]/_se[treatedXpost]
local p_coef3 = 2 * ttail(e(df_r), abs(`t_coef3'))
if `p_coef3' >= 0.10 {
	local b_coef3 = string(`b_coef3', "%6.2f")
} 
else if `p_coef3' < 0.10 & `p_coef3' >= 0.05 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "*"
} 
else if `p_coef3' < 0.05 & `p_coef3' >= 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "**"
} 
else if `p_coef3' < 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "***"
}
local t_coef3 = "(" + string(`t_coef3', "%6.2f") + ")"
local r2_coef3 = string(e(r2_a), "%6.3f")
local obs_coef3 = string(e(N), "%10.0fc")

reghdfe totaltaxes_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4)&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef4 = _b[treatedXpost]
local t_coef4 = _b[treatedXpost]/_se[treatedXpost]
local p_coef4 = 2 * ttail(e(df_r), abs(`t_coef4'))
if `p_coef4' >= 0.10 {
	local b_coef4 = string(`b_coef4', "%6.2f")
} 
else if `p_coef4' < 0.10 & `p_coef4' >= 0.05 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "*"
} 
else if `p_coef4' < 0.05 & `p_coef4' >= 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "**"
} 
else if `p_coef4' < 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "***"
}
local t_coef4 = "(" + string(`t_coef4', "%6.2f") + ")"
local r2_coef4 = string(e(r2_a), "%6.3f")
local obs_coef4 = string(e(N), "%10.0fc")

reghdfe propertytax_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4)&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef5 = _b[treatedXpost]
local t_coef5 = _b[treatedXpost]/_se[treatedXpost]
local p_coef5 = 2 * ttail(e(df_r), abs(`t_coef5'))
if `p_coef5' >= 0.10 {
	local b_coef5 = string(`b_coef5', "%6.2f")
} 
else if `p_coef5' < 0.10 & `p_coef5' >= 0.05 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "*"
} 
else if `p_coef5' < 0.05 & `p_coef5' >= 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "**"
} 
else if `p_coef5' < 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "***"
}
local t_coef5 = "(" + string(`t_coef5', "%6.2f") + ")"
local r2_coef5 = string(e(r2_a), "%6.3f")
local obs_coef5 = string(e(N), "%10.0fc")

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4)&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef6 = _b[treatedXpost]
local t_coef6 = _b[treatedXpost]/_se[treatedXpost]
local p_coef6 = 2 * ttail(e(df_r), abs(`t_coef6'))
if `p_coef6' >= 0.10 {
	local b_coef6 = string(`b_coef6', "%6.2f")
} 
else if `p_coef6' < 0.10 & `p_coef6' >= 0.05 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "*"
} 
else if `p_coef6' < 0.05 & `p_coef6' >= 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "**"
} 
else if `p_coef6' < 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "***"
}
local t_coef6 = "(" + string(`t_coef6', "%6.2f") + ")"
local r2_coef6 = string(e(r2_a), "%6.3f")
local obs_coef6 = string(e(N), "%10.0fc")

post `memhold' ("Treated $\times$ Post") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
post `memhold' (" ") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'")

// Row 2: Non-School districts

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel F: M\&As are not confouned by concurrent commercial bank M\&A, Municipalities/Townships/Counties") (" ") (" ") (" ")

reghdfe totalinterestondebt_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4)&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef1 = _b[treatedXpost]
local t_coef1 = _b[treatedXpost]/_se[treatedXpost]
local p_coef1 = 2 * ttail(e(df_r), abs(`t_coef1'))
if `p_coef1' >= 0.10 {
	local b_coef1 = string(`b_coef1', "%6.2f")
} 
else if `p_coef1' < 0.10 & `p_coef1' >= 0.05 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "*"
} 
else if `p_coef1' < 0.05 & `p_coef1' >= 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "**"
} 
else if `p_coef1' < 0.01 {
	local b_coef1 = string(`b_coef1', "%6.2f") + "***"
}
local t_coef1 = "(" + string(`t_coef1', "%6.2f") + ")"
local r2_coef1 = string(e(r2_a), "%6.3f")
local obs_coef1 = string(e(N), "%10.0fc")

reghdfe totalltdissued_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4)&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef2 = _b[treatedXpost]
local t_coef2 = _b[treatedXpost]/_se[treatedXpost]
local p_coef2 = 2 * ttail(e(df_r), abs(`t_coef2'))
if `p_coef2' >= 0.10 {
	local b_coef2 = string(`b_coef2', "%6.2f")
} 
else if `p_coef2' < 0.10 & `p_coef2' >= 0.05 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "*"
} 
else if `p_coef2' < 0.05 & `p_coef2' >= 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "**"
} 
else if `p_coef2' < 0.01 {
	local b_coef2 = string(`b_coef2', "%6.2f") + "***"
}
local t_coef2 = "(" + string(`t_coef2', "%6.2f") + ")"
local r2_coef2 = string(e(r2_a), "%6.3f")
local obs_coef2 = string(e(N), "%10.0fc")

reghdfe surplus_ratio treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4)&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef3 = _b[treatedXpost]
local t_coef3 = _b[treatedXpost]/_se[treatedXpost]
local p_coef3 = 2 * ttail(e(df_r), abs(`t_coef3'))
if `p_coef3' >= 0.10 {
	local b_coef3 = string(`b_coef3', "%6.2f")
} 
else if `p_coef3' < 0.10 & `p_coef3' >= 0.05 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "*"
} 
else if `p_coef3' < 0.05 & `p_coef3' >= 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "**"
} 
else if `p_coef3' < 0.01 {
	local b_coef3 = string(`b_coef3', "%6.2f") + "***"
}
local t_coef3 = "(" + string(`t_coef3', "%6.2f") + ")"
local r2_coef3 = string(e(r2_a), "%6.3f")
local obs_coef3 = string(e(N), "%10.0fc")

reghdfe totaltaxes_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4)&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef4 = _b[treatedXpost]
local t_coef4 = _b[treatedXpost]/_se[treatedXpost]
local p_coef4 = 2 * ttail(e(df_r), abs(`t_coef4'))
if `p_coef4' >= 0.10 {
	local b_coef4 = string(`b_coef4', "%6.2f")
} 
else if `p_coef4' < 0.10 & `p_coef4' >= 0.05 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "*"
} 
else if `p_coef4' < 0.05 & `p_coef4' >= 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "**"
} 
else if `p_coef4' < 0.01 {
	local b_coef4 = string(`b_coef4', "%6.2f") + "***"
}
local t_coef4 = "(" + string(`t_coef4', "%6.2f") + ")"
local r2_coef4 = string(e(r2_a), "%6.3f")
local obs_coef4 = string(e(N), "%10.0fc")

reghdfe propertytax_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4)&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef5 = _b[treatedXpost]
local t_coef5 = _b[treatedXpost]/_se[treatedXpost]
local p_coef5 = 2 * ttail(e(df_r), abs(`t_coef5'))
if `p_coef5' >= 0.10 {
	local b_coef5 = string(`b_coef5', "%6.2f")
} 
else if `p_coef5' < 0.10 & `p_coef5' >= 0.05 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "*"
} 
else if `p_coef5' < 0.05 & `p_coef5' >= 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "**"
} 
else if `p_coef5' < 0.01 {
	local b_coef5 = string(`b_coef5', "%6.2f") + "***"
}
local t_coef5 = "(" + string(`t_coef5', "%6.2f") + ")"
local r2_coef5 = string(e(r2_a), "%6.3f")
local obs_coef5 = string(e(N), "%10.0fc")

reghdfe totaligrevenue_toexp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=4)&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa i.calendar_year) cluster(i.csacode i.calendar_year)

local b_coef6 = _b[treatedXpost]
local t_coef6 = _b[treatedXpost]/_se[treatedXpost]
local p_coef6 = 2 * ttail(e(df_r), abs(`t_coef6'))
if `p_coef6' >= 0.10 {
	local b_coef6 = string(`b_coef6', "%6.2f")
} 
else if `p_coef6' < 0.10 & `p_coef6' >= 0.05 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "*"
} 
else if `p_coef6' < 0.05 & `p_coef6' >= 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "**"
} 
else if `p_coef6' < 0.01 {
	local b_coef6 = string(`b_coef6', "%6.2f") + "***"
}
local t_coef6 = "(" + string(`t_coef6', "%6.2f") + ")"
local r2_coef6 = string(e(r2_a), "%6.3f")
local obs_coef6 = string(e(N), "%10.0fc")

restore

post `memhold' ("Treated $\times$ Post") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
post `memhold' (" ") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'")

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Government \(\times\) Cohort FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Year FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Clustering") ("CSA \& Year") ("CSA \& Year") ("CSA \& Year")

postclose `memhold'

preserve
use `table', clear
texsave using "`outfile'", replace dataonly nonames italics("Panel") nofix hlines(3)
restore

}





/*-------------------*/
/* Figures: Dynamics */
/*-------------------*/

{

gen treatedXpostm2 = treated==1&year_to_merger==-2
gen treatedXpostm3 = treated==1&year_to_merger==-3
gen treatedXpostm4 = treated==1&year_to_merger==-4
gen treatedXpost0 = treated==1&year_to_merger==0
gen treatedXpost1 = treated==1&year_to_merger==1
gen treatedXpost2 = treated==1&year_to_merger==2
gen treatedXpost3 = treated==1&year_to_merger==3
gen treatedXpost4 = treated==1&year_to_merger==4

// Interest paid

preserve

reghdfe totalinterestondebt_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

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
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in %)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_InterestToExp.eps", replace

restore

// Interest paid, by type of government: School district

preserve

reghdfe totalinterestondebt_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

forvalues x = 2/4 {
local bm`x' = _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x']
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x' = _b[treatedXpost`x']
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

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(magenta)) ///
(rcap upper lower yeartochange, color(magenta)) ///
,xtitle("Year to M&A", size(large)) ytitle("Effects on Interest Paid/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_InterestToExp_SD.eps", replace

restore

// Interest paid, by type of government: Non-school district

preserve

reghdfe totalinterestondebt_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

forvalues x = 2/4 {
local bm`x' = _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x']
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x' = _b[treatedXpost`x']
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

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coef yeartochange2, msize(small) mcolor(blue)) ///
(rcap upper lower yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("Effects on Interest Paid/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Municipality/township/county") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_InterestToExp_NonSD.eps", replace

restore

// New issuance

preserve

reghdfe totalltdissued_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

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
xtitle("Year to M&A", size(large)) ytitle("Effects on New Issuance/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in %)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_IssuanceToExp.eps", replace

restore

// New issuance, by type of government: School district

preserve

reghdfe totalltdissued_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

forvalues x = 2/4 {
local bm`x' = _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x']
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x' = _b[treatedXpost`x']
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

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(magenta)) ///
(rcap upper lower yeartochange, color(magenta)) ///
,xtitle("Year to M&A", size(large)) ytitle("Effects on New Issuance/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_IssuanceToExp_SD.eps", replace

restore

// New issuance, by type of government: Not school district

preserve

reghdfe totalltdissued_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

forvalues x = 2/4 {
local bm`x' = _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x']
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x' = _b[treatedXpost`x']
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

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coef yeartochange2, msize(small) mcolor(blue)) ///
(rcap upper lower yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("Effects on New Issuance/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Municipality/township/county") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_IssuanceToExp_NonSD.eps", replace

restore

// Surplus Ratio

preserve

reghdfe surplus_ratio treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

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
xtitle("Year to M&A", size(large)) ytitle("Effects on Budget Surplus Ratio", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in %)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_SurplusRatio.eps", replace

restore

// Surplus Ratio, by type of government: School district

preserve

reghdfe surplus_ratio treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

forvalues x = 2/4 {
local bm`x' = _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x']
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x' = _b[treatedXpost`x']
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

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(magenta)) ///
(rcap upper lower yeartochange, color(magenta)) ///
,xtitle("Year to M&A", size(large)) ytitle("Effects on Budget Surplus Ratio", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_SurplusRatio_SD.eps", replace

restore

// Surplus Ratio, by type of government: Not school district

preserve

reghdfe surplus_ratio treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

forvalues x = 2/4 {
local bm`x' = _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x']
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x' = _b[treatedXpost`x']
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

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coef yeartochange2, msize(small) mcolor(blue)) ///
(rcap upper lower yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("Effects on Budget Surplus Ratio", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Municipality/township/county") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_SurplusRatio_NonSD.eps", replace

restore

// Total taxes

preserve

reghdfe totaltaxes_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

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
xtitle("Year to M&A", size(large)) ytitle("Effects on Total Taxes/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in %)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_TotalTaxes.eps", replace

restore

// Total taxes, by type of government: School district

preserve

reghdfe totaltaxes_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

forvalues x = 2/4 {
local bm`x' = _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x']
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x' = _b[treatedXpost`x']
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

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(magenta)) ///
(rcap upper lower yeartochange, color(magenta)) ///
,xtitle("Year to M&A", size(large)) ytitle("Effects on Total Taxes/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_TotalTaxes_SD.eps", replace

restore

// Total taxes, by type of government: Not school district

preserve

reghdfe totaltaxes_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

forvalues x = 2/4 {
local bm`x' = _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x']
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x' = _b[treatedXpost`x']
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

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coef yeartochange2, msize(small) mcolor(blue)) ///
(rcap upper lower yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("Effects on Total Taxes/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Municipality/township/county") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_TotalTaxes_NonSD.eps", replace

restore

// Property tax

preserve

reghdfe propertytax_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

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
xtitle("Year to M&A", size(large)) ytitle("Effects on Property Tax/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in %)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_PropertyTax.eps", replace

restore

// Property tax, by type of government: School district

preserve

reghdfe propertytax_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

forvalues x = 2/4 {
local bm`x' = _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x']
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x' = _b[treatedXpost`x']
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

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coef yeartochange2, msize(small) mcolor(magenta)) ///
(rcap upper lower yeartochange2, color(magenta)) ///
,xtitle("Year to M&A", size(large)) ytitle("Effects on Property Tax/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Municipality/township/county") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_PropertyTax_SD.eps", replace

restore

// Property tax, by type of government: Not school district

preserve

reghdfe propertytax_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

forvalues x = 2/4 {
local bm`x' = _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x']
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x' = _b[treatedXpost`x']
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

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(blue)) ///
(rcap upper lower yeartochange, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("Effects on Property Tax/Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_PropertyTax_NonSD.eps", replace

restore

// IG Revenue

preserve

reghdfe totaligrevenue_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

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
xtitle("Year to M&A", size(large)) ytitle("Effects on Inter-Gov. Trans./Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in %)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_IGRev.eps", replace

restore

// IG Revenue, by type of governmens: School district

preserve

reghdfe totaligrevenue_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4&is_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

forvalues x = 2/4 {
local bm`x' = _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x']
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x' = _b[treatedXpost`x']
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

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(magenta)) ///
(rcap upper lower yeartochange, color(magenta)) ///
,xtitle("Year to M&A", size(large)) ytitle("Effects on Inter-Gov. Trans./Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "School district") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_IGRev_SD.eps", replace

restore

// IG Revenue, by type of governmens: Not school district

preserve

reghdfe totaligrevenue_toexp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4&is_not_schooldistrict, ///
absorb(i.id##i.episode_start_year##i.treated_csa##i.episode_start_year i.calendar_year) cluster(i.csacode i.calendar_year)

forvalues x = 2/4 {
local bm`x' = _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x']
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x' = _b[treatedXpost`x']
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

gen yeartochange2 = yeartochange
replace yeartochange2 = yeartochange-0.1 if yeartochange!=-1

graph twoway ///
(scatter coef yeartochange2, msize(small) mcolor(blue)) ///
(rcap upper lower yeartochange2, color(blue)) ///
,xtitle("Year to M&A", size(large)) ytitle("Effects on Inter-Gov. Trans./Exp.", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Municipality/township/county") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GovFin_IGRev_NonSD.eps", replace

restore

}


