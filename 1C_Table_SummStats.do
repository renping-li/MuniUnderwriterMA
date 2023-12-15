
/*---------------------------*/
/* Table: Summary statistics */
/*---------------------------*/

/* Table: Part 1: bond level sample */

/* Issue level sample */

import delimited "../CleanData/MAEvent/GPF.csv", clear 
tempfile GPF

// keep if gross_spread!=.|avg_yield!=.

winsor2 amount, replace cuts(1 99)
winsor2 avg_maturity, replace cuts(1 99)

gen amount_adjusted = amount*scaler
replace avg_maturity = avg_maturity/365
gen gross_spread_inbp = gross_spread*10
gen avg_yield_inbp = avg_yield*10000
gen avg_spread_inbp = avg_spread*10000
replace hhi_by_n = hhi_by_n*10000
gen bidC = bid=="C"
gen bidN = bid=="N"
gen bidP = bid=="P"
gen taxE = taxable_code=="E"
gen taxT = taxable_code=="T"
gen taxA = taxable_code=="A"
gen securityGO = security_type=="GO"
gen securityRV = security_type=="RV"
gen if_advisor2 = if_advisor=="Yes"
drop if_advisor
rename if_advisor2 if_advisor
gen if_dual_advisor2 = if_dual_advisor=="True"
drop if_dual_advisor
rename if_dual_advisor2 if_dual_advisor
gen has_rating = (has_fitch=="True")|(has_moodys=="True")
replace insured_amount = 0 if insured_amount==.
gen insured_ratio = insured_amount/amount
gen if_insured = insured_ratio>0
gen is_callable = if_callable=="Yes"
gen is_cb_eligible = cb_eligible=="Yes"

save `GPF', replace

/*--- Number: Average gross spread ---*/

sum gross_spread_inbp
local gross_spread_inbp = r(mean)
local gross_spread_inbp : display %-9.1f `gross_spread_inbp'
file open myfile using "../Slides/nums/avg_gross_spread_inbp.tex", write replace
file write myfile "`gross_spread_inbp'"
file close myfile

/*--- Number: Fraction of issues with insurance ---*/

sum if_insured if calendar_year>=1997&calendar_year<=2007
local if_insured_beforeGFC = r(mean)*100
local if_insured_beforeGFC : display %-9.1f `if_insured_beforeGFC'
file open myfile using "../Slides/nums/if_insured_beforeGFC.tex", write replace
file write myfile "`if_insured_beforeGFC'"
file close myfile

sum if_insured if calendar_year>=2008&calendar_year<=2018
local if_insured_afterGFC = r(mean)*100
local if_insured_afterGFC : display %-9.1f `if_insured_afterGFC'
file open myfile using "../Slides/nums/if_insured_afterGFC.tex", write replace
file write myfile "`if_insured_afterGFC'"
file close myfile

/*--- Number: Fraction of callable issues ---*/

sum is_callable
local frac_callable = r(mean)*100
local frac_callable : display %-9.1f `frac_callable'
file open myfile using "../Slides/nums/frac_callable.tex", write replace
file write myfile "`frac_callable'"
file close myfile

/*--- Number: Fraction of taxable issues ---*/

sum taxT
local taxT = r(mean)*100
local taxT : display %-9.1f `taxT'
file open myfile using "../Slides/nums/taxT.tex", write replace
file write myfile "`taxT'"
file close myfile

/*--- Number: Fraction of issues with credit ratings ---*/

sum has_rating
local has_rating = r(mean)*100
local has_rating : display %-9.1f `has_rating'
file open myfile using "../Slides/nums/has_rating.tex", write replace
file write myfile "`has_rating'"
file close myfile

/* M&A episode sample */

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHI_SumStats.csv", clear 
tempfile CSA_episodes

replace hhi_dif = hhi_dif*10000

/* Number: Number of M&A episodes */

sum hhi_dif
local n_episodes_impliedhhi = r(N)
local n_episodes_impliedhhi : display %-9.0f `n_episodes_impliedhhi'
file open myfile using "../Slides/nums/n_episodes_impliedhhi.tex", write replace
file write myfile "`n_episodes_impliedhhi'"
file close myfile

save `CSA_episodes', replace

/* California sample */

import delimited "../RawData/California/SumStats.csv", clear 
tempfile California
replace insureratio = insureratio*10000
replace advisorratio = advisorratio*10000
replace crratio = crratio*10000

save `California', replace

/*--- Number: Average credit rating/insurance/advisor cost ---*/

sum crratio
local avg_crratio = r(mean)
local avg_crratio : display %-9.1f `avg_crratio'
file open myfile using "../Slides/nums/avg_crratio.tex", write replace
file write myfile "`avg_crratio'"
file close myfile

sum insureratio
local avg_insureratio = r(mean)
local avg_insureratio : display %-9.1f `avg_insureratio'
file open myfile using "../Slides/nums/avg_insureratio.tex", write replace
file write myfile "`avg_insureratio'"
file close myfile

sum advisorratio
local avg_advisorratio = r(mean)
local avg_advisorratio : display %-9.1f `avg_advisorratio'
file open myfile using "../Slides/nums/avg_advisorratio.tex", write replace
file write myfile "`avg_advisorratio'"
file close myfile

/* Make table */

clear
tempfile table
tempname memhold
postfile `memhold' str60 varname str80 (mean sd p25 median p75 N) using `table', replace

post `memhold' (" ") ("Mean") ("SD") ("25%") ("Median") ("75%") ("N")

/* Panel: Issue level */

post `memhold' ("Panel A: SDC Sample") (" ") (" ") (" ") (" ") (" ") (" ")

local varlist = "amount_adjusted avg_maturity gross_spread_inbp avg_yield_inbp hhi_by_n bidC bidN bidP taxE taxT taxA securityGO securityRV if_advisor if_dual_advisor has_rating insured_ratio if_insured is_callable is_cb_eligible"
local lb_amount_adjusted = "Amount (\$ Millions)"
local lb_avg_maturity = "Maturity (Years)"
local lb_gross_spread_inbp = "Underwriting Spread (bps.)"
local lb_avg_yield_inbp = "Offering Yield (bps.)"
local lb_avg_spread_inbp = "Offering Yield Spread (bps.)"
local lb_hhi_by_n = "HHI"
local lb_bidC = "Method of Sale: Competitive Bidding"
local lb_bidN = "Method of Sale: Negotiated Sales"
local lb_bidP = "Method of Sale: Private Placement"
local lb_taxE = "Tax Status: Tax Exempt"
local lb_taxT = "Tax Status: Taxable"
local lb_taxA = "Tax Status: Alternative Minimum Tax"
local lb_securityGO = "Soource of Repayment: General Obligation"
local lb_securityRV = "Soource of Repayment: Revenue"
local lb_if_advisor = "Has Advisor"
local lb_if_dual_advisor "Has Dual Advisor"
local lb_has_rating = "Has Credit Rating"
local lb_insured_ratio = "Insured Ratio"
local lb_if_insured = "If Insured"
local lb_is_callable "If Callable"
local lb_is_cb_eligible "If Commercial Banks Eligible"

foreach var in `varlist' {

preserve 
use `GPF', clear
sum `var', d
local mean = string(r(mean), "%6.2f")
local sd = string(r(sd), "%6.2f")
local p25 = string(r(p25), "%6.2f")
local median = string(r(p50), "%6.2f")
local p75 = string(r(p75), "%6.2f")
local N = string(r(N), "%6.0f")
restore

post `memhold' ("`lb_`var''") ("`mean'") ("`sd'") ("`p25'") ("`median'") ("`p75'") ("`N'")


}

/* Panel: Episodes */

post `memhold' (" ") (" ") (" ") (" ") (" ") (" ") (" ")

post `memhold' ("Panel B: Local M&A Episodes") (" ") (" ") (" ") (" ") (" ") (" ")

local varlist = "acquiror_market_share_n_max target_market_share_n_max hhi_dif"
local lb_acquiror_market_share_n_max = "Acquiror Market Share"
local lb_target_market_share_n_max = "Target Market Share"
local lb_hhi_dif = "Delta HHI"

foreach var in `varlist' {

preserve 
use `CSA_episodes', clear
sum `var', d
local mean = string(r(mean), "%6.2f")
local sd = string(r(sd), "%6.2f")
local p25 = string(r(p25), "%6.2f")
local median = string(r(p50), "%6.2f")
local p75 = string(r(p75), "%6.2f")
local N = string(r(N), "%6.0f")
restore

post `memhold' ("`lb_`var''") ("`mean'") ("`sd'") ("`p25'") ("`median'") ("`p75'") ("`N'")


}

/* Panel: California */

post `memhold' (" ") (" ") (" ") (" ") (" ") (" ") (" ")

post `memhold' ("Panel C: California Sample") (" ") (" ") (" ") (" ") (" ") (" ")

local varlist = "advisorratio crratio insureratio"
local lb_advisorratio = "Financial Advisor Fee (bps.)"
local lb_crratio = "Credit Rating Fee (bps.)"
local lb_insureratio = "Insurance Fee (bps.)"

foreach var in `varlist' {

preserve 
use `California', clear
sum `var', d
local mean = string(r(mean), "%6.2f")
local sd = string(r(sd), "%6.2f")
local p25 = string(r(p25), "%6.2f")
local median = string(r(p50), "%6.2f")
local p75 = string(r(p75), "%6.2f")
local N = string(r(N), "%6.0f")
restore

post `memhold' ("`lb_`var''") ("`mean'") ("`sd'") ("`p25'") ("`median'") ("`p75'") ("`N'")


}

postclose `memhold'
clear
use `table'

texsave using "../Slides/tabs/Sum_Stats.tex", replace frag nonames title("Summary Statistics") size(small) label("sum_stats") location("H")




/* Table: Part 2: Government level sample */

/* Government sample */

import delimited "../RawData/GovFinSurvey/GovFinData.csv", clear

preserve

duplicates drop id, force

/* Number: Number of each type of local government */

count if typecode==1
local n_county = r(N)
local n_county : display %-9.0fc `n_county'
file open myfile using "../Slides/nums/n_county.tex", write replace
file write myfile "`n_county'"
file close myfile

count if typecode==2
local n_municipality = r(N)
local n_municipality : display %-9.0fc `n_municipality'
file open myfile using "../Slides/nums/n_municipality.tex", write replace
file write myfile "`n_municipality'"
file close myfile

count if typecode==3
local n_township = r(N)
local n_township : display %-9.0fc `n_township'
file open myfile using "../Slides/nums/n_township.tex", write replace
file write myfile "`n_township'"
file close myfile

count if typecode==5
local n_SD = r(N)
local n_SD : display %-9.0fc `n_SD'
file open myfile using "../Slides/nums/n_SD.tex", write replace
file write myfile "`n_SD'"
file close myfile

restore

rename year4 calendar_year

do 1I_Proc_GovFin.do

/*--- Number: Revenue/Expenditure per student/per capita ---*/

sum totalrevenue_pe
local totalrevenue_pe = r(mean)
local totalrevenue_pe : display %-9.0fc `totalrevenue_pe'
file open myfile using "../Slides/nums/totalrevenue_pe.tex", write replace
file write myfile "`totalrevenue_pe'"
file close myfile

sum totalrevenue_pc
local totalrevenue_pc = r(mean)
local totalrevenue_pc : display %-9.0fc `totalrevenue_pc'
file open myfile using "../Slides/nums/totalrevenue_pc.tex", write replace
file write myfile "`totalrevenue_pc'"
file close myfile

sum totalexpenditure_pe
local totalexpenditure_pe = r(mean)
local totalexpenditure_pe : display %-9.0fc `totalexpenditure_pe'
file open myfile using "../Slides/nums/totalexpenditure_pe.tex", write replace
file write myfile "`totalexpenditure_pe'"
file close myfile

sum totalexpenditure_pc
local totalexpenditure_pc = r(mean)
local totalexpenditure_pc : display %-9.0fc `totalexpenditure_pc'
file open myfile using "../Slides/nums/totalexpenditure_pc.tex", write replace
file write myfile "`totalexpenditure_pc'"
file close myfile

/* Number: Interest expense as a fraction of total expenditure */

sum totalinterestondebt_toexp if type==5
local totalinterestondebt_toexp_SD = r(mean)
local totalinterestondebt_toexp_SD : display %-9.1f `totalinterestondebt_toexp_SD'
file open myfile using "../Slides/nums/totalinterestondebt_toexp_SD.tex", write replace
file write myfile "`totalinterestondebt_toexp_SD'"
file close myfile

sum totalinterestondebt_toexp if type==1|type==2|type==3
local totalinterestondebt_toexp_nonSD = r(mean)
local totalinterestondebt_toexp_nonSD : display %-9.1f `totalinterestondebt_toexp_nonSD'
file open myfile using "../Slides/nums/totalinterestondebt_toexp_nonSD.tex", write replace
file write myfile "`totalinterestondebt_toexp_nonSD'"
file close myfile

/* Number: New debt issuance as a fraction of total expenditure */

sum totalltdissued_toexp if type==5
local totalltdissued_toexp_SD = r(mean)
local totalltdissued_toexp_SD : display %-9.1f `totalltdissued_toexp_SD'
file open myfile using "../Slides/nums/totalltdissued_toexp_SD.tex", write replace
file write myfile "`totalltdissued_toexp_SD'"
file close myfile

sum totalltdissued_toexp if type==1|type==2|type==3
local totalltdissued_toexp_nonSD = r(mean)
local totalltdissued_toexp_nonSD : display %-9.1f `totalltdissued_toexp_nonSD'
file open myfile using "../Slides/nums/totalltdissued_toexp_nonSD.tex", write replace
file write myfile "`totalltdissued_toexp_nonSD'"
file close myfile

/* Number: Total taxes as a fraction of total expenditure */

sum totaltaxes_toexp if type==5
local totaltaxes_toexp_SD = r(mean)
local totaltaxes_toexp_SD : display %-9.1f `totaltaxes_toexp_SD'
file open myfile using "../Slides/nums/totaltaxes_toexp_SD.tex", write replace
file write myfile "`totaltaxes_toexp_SD'"
file close myfile

sum totaltaxes_toexp if type==1|type==2|type==3
local totaltaxes_toexp_nonSD = r(mean)
local totaltaxes_toexp_nonSD : display %-9.1f `totaltaxes_toexp_nonSD'
file open myfile using "../Slides/nums/totaltaxes_toexp_nonSD.tex", write replace
file write myfile "`totaltaxes_toexp_nonSD'"
file close myfile

/* Number: Inter-gov transfer as a fraction of total expenditure */

sum totaligrevenue_toexp if type==5
local totaligrevenue_toexp_SD = r(mean)
local totaligrevenue_toexp_SD : display %-9.1f `totaligrevenue_toexp_SD'
file open myfile using "../Slides/nums/totaligrevenue_toexp_SD.tex", write replace
file write myfile "`totaligrevenue_toexp_SD'"
file close myfile

sum totaligrevenue_toexp if type==1|type==2|type==3
local totaligrevenue_toexp_nonSD = r(mean)
local totaligrevenue_toexp_nonSD : display %-9.1f `totaligrevenue_toexp_nonSD'
file open myfile using "../Slides/nums/totaligrevenue_toexp_nonSD.tex", write replace
file write myfile "`totaligrevenue_toexp_nonSD'"
file close myfile

tempfile GovFin
save `GovFin', replace

/* Make table */

tempfile table
tempname memhold
postfile `memhold' str60 varname str80 (mean sd p25 median p75 N) using `table', replace

post `memhold' (" ") ("Mean") ("SD") ("25%") ("Median") ("75%") ("N")

/* Panel: Local government */

post `memhold' (" ") (" ") (" ") (" ") (" ") (" ") (" ")

post `memhold' ("Panel D: School Districts Sample") (" ") (" ") (" ") (" ") (" ") (" ")

local varlist = "totalrevenue_pe totalexpenditure_pe totalinterestondebt_toexp totalltdissued_toexp deficit_ratio totaltaxes_toexp propertytax_toexp totaligrevenue_toexp totalfedigrevenue_toexp totalstateigrevenue_toexp totlocaligrev_toexp"
local lb_totalrevenue_pe = "Revenue Per Student"
local lb_totalexpenditure_pe = "Expenditure Per Student"
local lb_totalinterestondebt_toexp = "Interest Paid/Exp. (%)"
local lb_totalltdissued_toexp "New Issuance/Exp. (%)"
local lb_deficit_ratio "Deficit Ratio (%)"
local lb_totaltaxes_toexp "Total Taxes/Exp. (%)"
local lb_propertytax_toexp "Property Tax/Exp. (%)"
local lb_totaligrevenue_toexp "Inter-Gov. Rev./Exp. (%)"
local lb_totalfedigrevenue_toexp "Inter-Gov. Rev. from Federal/Exp. (%)"
local lb_totalstateigrevenue_toexp "Inter-Gov. Rev. from State/Exp. (%)"
local lb_totlocaligrev_toexp "Inter-Gov. Rev. from Local/Exp. (%)"

foreach var in `varlist' {

preserve 
use `GovFin', clear
sum `var' if typecode==5, d
local mean = string(r(mean), "%6.2f")
local sd = string(r(sd), "%6.2f")
local p25 = string(r(p25), "%6.2f")
local median = string(r(p50), "%6.2f")
local p75 = string(r(p75), "%6.2f")
local N = string(r(N), "%6.0f")
restore

post `memhold' ("`lb_`var''") ("`mean'") ("`sd'") ("`p25'") ("`median'") ("`p75'") ("`N'")


}

post `memhold' (" ") (" ") (" ") (" ") (" ") (" ") (" ")

post `memhold' ("Panel E: Municipalities/Townships/Counties Sample") (" ") (" ") (" ") (" ") (" ") (" ")

local varlist = "totalrevenue_pc totalexpenditure_pc totalinterestondebt_toexp totalltdissued_toexp deficit_ratio totaltaxes_toexp propertytax_toexp totaligrevenue_toexp totalfedigrevenue_toexp totalstateigrevenue_toexp totlocaligrev_toexp"
local lb_totalrevenue_pc = "Revenue Per Capita"
local lb_totalexpenditure_pc = "Expenditure Per Capita"
local lb_totalinterestondebt_toexp = "Interest Paid/Exp. (%)"
local lb_totalltdissued_toexp "New Issuance/Exp. (%)"
local lb_deficit_ratio "Deficit Ratio (%)"
local lb_totaltaxes_toexp "Total Taxes/Exp. (%)"
local lb_propertytax_toexp "Property Tax/Exp. (%)"
local lb_totaligrevenue_toexp "Inter-Gov. Rev./Exp. (%)"
local lb_totalfedigrevenue_toexp "Inter-Gov. Rev. from Federal/Exp. (%)"
local lb_totalstateigrevenue_toexp "Inter-Gov. Rev. from State/Exp. (%)"
local lb_totlocaligrev_toexp "Inter-Gov. Rev. from Local/Exp. (%)"

foreach var in `varlist' {

preserve 
use `GovFin', clear
sum `var' if typecode!=5, d
local mean = string(r(mean), "%6.2f")
local sd = string(r(sd), "%6.2f")
local p25 = string(r(p25), "%6.2f")
local median = string(r(p50), "%6.2f")
local p75 = string(r(p75), "%6.2f")
local N = string(r(N), "%6.0f")
restore

post `memhold' ("`lb_`var''") ("`mean'") ("`sd'") ("`p25'") ("`median'") ("`p75'") ("`N'")


}

postclose `memhold'
clear
use `table'

texsave using "../Slides/tabs/Sum_Stats_GovFin.tex", replace frag nonames title("Summary Statistics") size(small) label("sum_stats_govfin") location("H")




