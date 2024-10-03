
/*---------------------------*/
/* Table: Summary statistics */
/*---------------------------*/

/* Table: Part 1: bond level sample */

/* Issue level sample */

import delimited "../CleanData/SDC/1A_GPF_OLS.csv", clear 
tempfile GPF

winsor2 amount, replace cuts(1 99)
winsor2 avg_maturity, replace cuts(1 99)

gen amount_adjusted = amount*scaler
replace avg_maturity = avg_maturity/365
gen gross_spread_inbp = gross_spread*10
gen avg_yield_inbp = avg_yield*10000
gen treasury_avg_spread_inbp = treasury_avg_spread*10000
gen mma_avg_spread_inbp = mma_avg_spread*10000
gen mod_tic_spread_inbp = mod_tic_spread_treasury*10000
gen mod_tic_spread_inbp_timefe = mod_tic_spread_treasury_timefe*10000
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
gen net_cost_inbp = gross_spread_inbp+if_advisor*advisorfeeratio_hat+has_rating*crfeeratio_hat+insured_ratio*insurefeeratio_hat
gen net_cost_inbp_timefe = gross_spread_inbp+if_advisor*advisorfeeratio_hat_model_timefe+has_rating*crfeeratio_hat_model_timefe+insured_ratio*insurefeeratio_hat_model_timefe

save `GPF', replace

/*--- Number: Average gross spread ---*/

quietly sum gross_spread_inbp
local gross_spread_inbp = r(mean)
local gross_spread_inbp : display %-9.1f `gross_spread_inbp'
file open myfile using "../Draft/nums/avg_gross_spread_inbp.tex", write replace
file write myfile "`gross_spread_inbp'"
file close myfile

/*--- Number: Average yield and yield spread ---*/

quietly sum avg_yield_inbp
local avg_yield_inbp = r(mean)
local avg_yield_inbp : display %-9.1f `avg_yield_inbp'
file open myfile using "../Draft/nums/avg_yield_inbp.tex", write replace
file write myfile "`avg_yield_inbp'"
file close myfile

quietly sum treasury_avg_spread_inbp
local treasury_avg_spread_inbp = r(mean)
local treasury_avg_spread_inbp : display %-9.1f `treasury_avg_spread_inbp'
file open myfile using "../Draft/nums/treasury_avg_spread_inbp.tex", write replace
file write myfile "`treasury_avg_spread_inbp'"
file close myfile

/*--- Number: Underpricing ---*/

quietly sum underpricing_15to30
local underpricing_15to30 = r(mean)
local underpricing_15to30 : display %-9.1f `underpricing_15to30'
file open myfile using "../Draft/nums/underpricing_15to30.tex", write replace
file write myfile "`underpricing_15to30'"
file close myfile

/*--- Number: Number of bids ---*/

quietly sum tbb_n_bidders
local tbb_n_bidders = r(mean)
local tbb_n_bidders : display %-9.1f `tbb_n_bidders'
file open myfile using "../Draft/nums/avg_tbb_n_bidders.tex", write replace
file write myfile "`tbb_n_bidders'"
file close myfile

quietly sum tbb_n_bidders, d
local tbb_n_bidders = r(p50)
local tbb_n_bidders : display %-9.1f `tbb_n_bidders'
file open myfile using "../Draft/nums/median_tbb_n_bidders.tex", write replace
file write myfile "`tbb_n_bidders'"
file close myfile

/*--- Number: Fraction of negotiated sales and competitive bidding ---*/

quietly sum bidC
local frac_C = r(mean)*100
local frac_C : display %-9.1f `frac_C'
file open myfile using "../Draft/nums/frac_C.tex", write replace
file write myfile "`frac_C'"
file close myfile

quietly sum bidN
local frac_N = r(mean)*100
local frac_N : display %-9.1f `frac_N'
file open myfile using "../Draft/nums/frac_N.tex", write replace
file write myfile "`frac_N'"
file close myfile

/*--- Number: Fraction of issues with insurance ---*/

quietly sum if_insured if calendar_year>=1997&calendar_year<=2007
local if_insured_beforeGFC = r(mean)*100
local if_insured_beforeGFC : display %-9.1f `if_insured_beforeGFC'
file open myfile using "../Draft/nums/if_insured_beforeGFC.tex", write replace
file write myfile "`if_insured_beforeGFC'"
file close myfile

quietly sum if_insured if calendar_year>=2008&calendar_year<=2018
local if_insured_afterGFC = r(mean)*100
local if_insured_afterGFC : display %-9.1f `if_insured_afterGFC'
file open myfile using "../Draft/nums/if_insured_afterGFC.tex", write replace
file write myfile "`if_insured_afterGFC'"
file close myfile

quietly sum if_insured
local if_insured = r(mean)*100
local if_insured : display %-9.1f `if_insured'
file open myfile using "../Draft/nums/if_insured.tex", write replace
file write myfile "`if_insured'"
file close myfile

/*--- Number: Fraction of callable issues ---*/

quietly sum is_callable
local frac_callable = r(mean)*100
local frac_callable : display %-9.1f `frac_callable'
file open myfile using "../Draft/nums/frac_callable.tex", write replace
file write myfile "`frac_callable'"
file close myfile

/*--- Number: Fraction of taxable issues ---*/

quietly sum taxT
local taxT = r(mean)*100
local taxT : display %-9.1f `taxT'
file open myfile using "../Draft/nums/taxT.tex", write replace
file write myfile "`taxT'"
file close myfile

/*--- Number: Fraction of issues with credit ratings ---*/

quietly sum has_rating
local has_rating = r(mean)*100
local has_rating : display %-9.1f `has_rating'
file open myfile using "../Draft/nums/has_rating.tex", write replace
file write myfile "`has_rating'"
file close myfile

/*--- Number: Fraction of issues with financial advisor ---*/

quietly sum if_advisor
local if_advisor = r(mean)*100
local if_advisor : display %-9.1f `if_advisor'
file open myfile using "../Draft/nums/if_advisor.tex", write replace
file write myfile "`if_advisor'"
file close myfile

/*--- Number: Issues each year by issuer and by county ---*/

preserve
bysort issuer calendar_year: egen n_issue = count(issuer)
duplicates drop issuer calendar_year, force
quietly sum n_issue, d
local n_issues_oneissuer = r(mean)
local n_issues_oneissuer : display %-9.1f `n_issues_oneissuer'
file open myfile using "../Draft/nums/n_issues_oneissuer.tex", write replace
file write myfile "`n_issues_oneissuer'"
file close myfile
restore

preserve
bysort county calendar_year: egen n_issue = count(county)
duplicates drop county calendar_year, force
quietly sum n_issue, d
local n_issues_onecounty = r(mean)
local n_issues_onecounty : display %-9.1f `n_issues_onecounty'
file open myfile using "../Draft/nums/n_issues_onecounty.tex", write replace
file write myfile "`n_issues_onecounty'"
file close myfile
restore

/* M&A episode sample */

import delimited "../CleanData/MAEvent/1B_CSA_episodes_impliedHHI_SumStats.csv", clear 
tempfile CSA_episodes

replace hhi_dif = hhi_dif*10000

/* Number: Number of M&A episodes */

quietly sum hhi_dif
local n_episodes_impliedhhi = r(N)
local n_episodes_impliedhhi : display %-9.0f `n_episodes_impliedhhi'
file open myfile using "../Draft/nums/n_episodes_impliedhhi.tex", write replace
file write myfile "`n_episodes_impliedhhi'"
file close myfile

save `CSA_episodes', replace

/* California sample */

import delimited "../CleanData/California/0H_SumStats.csv", clear 
tempfile CaliforniaTexas
replace insurefeeratio = insurefeeratio*10000
replace advisorfeeratio = advisorfeeratio*10000
replace crfeeratio = crfeeratio*10000

save `CaliforniaTexas', replace

/*--- Number: Average credit rating/insurance/advisor cost ---*/

quietly sum crfeeratio if crfeeratio>0
local avg_crfeeratio = r(mean)
local avg_crfeeratio : display %-9.1f `avg_crfeeratio'
file open myfile using "../Draft/nums/avg_crfeeratio.tex", write replace
file write myfile "`avg_crfeeratio'"
file close myfile

quietly sum insurefeeratio if insurefeeratio>0
local avg_insurefeeratio = r(mean)
local avg_insurefeeratio : display %-9.1f `avg_insurefeeratio'
file open myfile using "../Draft/nums/avg_insurefeeratio.tex", write replace
file write myfile "`avg_insurefeeratio'"
file close myfile

quietly sum advisorfeeratio if advisorfeeratio>0
local avg_advisorfeeratio = r(mean)
local avg_advisorfeeratio : display %-9.1f `avg_advisorfeeratio'
file open myfile using "../Draft/nums/avg_advisorfeeratio.tex", write replace
file write myfile "`avg_advisorfeeratio'"
file close myfile

/* Make table */

clear
tempfile table
tempname memhold
postfile `memhold' str60 varname str80 (mean sd p25 median p75 N) using `table', replace

post `memhold' (" ") ("Mean") ("SD") ("25%") ("Median") ("75%") ("N")

/* Panel: Issue level */

post `memhold' ("Panel A: SDC Sample") (" ") (" ") (" ") (" ") (" ") (" ")

// Part 1: One digit

local varlist = "amount_adjusted avg_maturity gross_spread_inbp avg_yield_inbp treasury_avg_spread_inbp mma_avg_spread_inbp mod_tic_spread_inbp mod_tic_spread_inbp_timefe underpricing_15to30 net_cost_inbp net_cost_inbp_timefe hhi_by_n"
local lb_amount_adjusted = "Amount (\$ Million)"
local lb_avg_maturity = "Maturity (Years)"
local lb_gross_spread_inbp = "Underwriting Spread (bps.)"
local lb_avg_yield_inbp = "Reoffering Yield (bps.)"
local lb_treasury_avg_spread_inbp = "Reoffering Yield Spread over Treasury (bps.)"
local lb_mma_avg_spread_inbp = "Reoffering Yield Spread over MMA (bps.)"
local lb_mod_tic_spread_inbp = "Modified TIC Spread (bps.)"
local lb_mod_tic_spread_inbp_timefe = "Modified TIC Spread, Year FE (bps.)"
local lb_underpricing_15to30 = "Initial Underpricing ($)"
local lb_net_cost_inbp = "Total Issuing Cost (bps.)"
local lb_net_cost_inbp_timefe = "Total Issuing Cost, Year FE (bps.)"
local lb_hhi_by_n = "HHI"

foreach var in `varlist' {

preserve 
use `GPF', clear
quietly sum `var', d
local mean = string(r(mean), "%6.1f")
local sd = string(r(sd), "%6.1f")
local p25 = string(r(p25), "%6.1f")
local median = string(r(p50), "%6.1f")
local p75 = string(r(p75), "%6.1f")
local N = string(r(N), "%6.0f")
restore

post `memhold' ("`lb_`var''") ("`mean'") ("`sd'") ("`p25'") ("`median'") ("`p75'") ("`N'")

}

// Part 2: Two digits

local varlist = "tbb_n_bidders bidC bidN bidP taxE taxT taxA securityGO securityRV if_advisor if_dual_advisor has_rating insured_ratio if_insured is_callable is_cb_eligible"
local lb_tbb_n_bidders = "Number of Bidders (Competitive Bidding only)"
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
quietly sum `var', d
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

local varlist = "acquiror_market_share_n_max target_market_share_n_max"
local lb_acquiror_market_share_n_max = "Acquiror Market Share"
local lb_target_market_share_n_max = "Target Market Share"

foreach var in `varlist' {

preserve 
use `CSA_episodes', clear
quietly sum `var', d
local mean = string(r(mean), "%6.2f")
local sd = string(r(sd), "%6.2f")
local p25 = string(r(p25), "%6.2f")
local median = string(r(p50), "%6.2f")
local p75 = string(r(p75), "%6.2f")
local N = string(r(N), "%6.0f")
restore

post `memhold' ("`lb_`var''") ("`mean'") ("`sd'") ("`p25'") ("`median'") ("`p75'") ("`N'")

}

local varlist = "hhi_dif"
local lb_hhi_dif = "Delta HHI"

foreach var in `varlist' {

preserve 
use `CSA_episodes', clear
quietly sum `var', d
local mean = string(r(mean), "%6.1f")
local sd = string(r(sd), "%6.1f")
local p25 = string(r(p25), "%6.1f")
local median = string(r(p50), "%6.1f")
local p75 = string(r(p75), "%6.1f")
local N = string(r(N), "%6.0f")
restore

post `memhold' ("`lb_`var''") ("`mean'") ("`sd'") ("`p25'") ("`median'") ("`p75'") ("`N'")


}

/* Panel: California */

post `memhold' (" ") (" ") (" ") (" ") (" ") (" ") (" ")

post `memhold' ("Panel C: California & Texas Sample") (" ") (" ") (" ") (" ") (" ") (" ")

local varlist = "advisorfeeratio crfeeratio insurefeeratio"
local lb_advisorfeeratio = "Financial Advisor Fee (bps.)"
local lb_crfeeratio = "Credit Rating Fee (bps.)"
local lb_insurefeeratio = "Insurance Fee (bps.)"

foreach var in `varlist' {

preserve 
use `CaliforniaTexas', clear
// Using only observations where a cost is above 0
quietly sum `var' if `var'>0.0001, d
local mean = string(r(mean), "%6.1f")
local sd = string(r(sd), "%6.1f")
local p25 = string(r(p25), "%6.1f")
local median = string(r(p50), "%6.1f")
local p75 = string(r(p75), "%6.1f")
local N = string(r(N), "%6.0f")
restore

post `memhold' ("`lb_`var''") ("`mean'") ("`sd'") ("`p25'") ("`median'") ("`p75'") ("`N'")

}

postclose `memhold'
clear
use `table'

texsave using "../Draft/tabs/Sum_Stats.tex", replace frag nonames title("Summary Statistics") size(small) label("sum_stats") location("H")




/* Table: Part 2: Government level sample */

/* Government sample */

import delimited "../CleanData/GovFinSurvey/0G_GovFinData.csv", clear

preserve

tostring id, gen(id_str) force
duplicates drop id_str, force

/* Number: Number of each type of local government */

count if typecode==1
local n_county = r(N)
local n_county : display %-9.0fc `n_county'
file open myfile using "../Draft/nums/n_county.tex", write replace
file write myfile "`n_county'"
file close myfile

count if typecode==2
local n_municipality = r(N)
local n_municipality : display %-9.0fc `n_municipality'
file open myfile using "../Draft/nums/n_municipality.tex", write replace
file write myfile "`n_municipality'"
file close myfile

count if typecode==3
local n_township = r(N)
local n_township : display %-9.0fc `n_township'
file open myfile using "../Draft/nums/n_township.tex", write replace
file write myfile "`n_township'"
file close myfile

count if typecode==5
local n_SD = r(N)
local n_SD : display %-9.0fc `n_SD'
file open myfile using "../Draft/nums/n_SD.tex", write replace
file write myfile "`n_SD'"
file close myfile

restore

rename year4 calendar_year

do 8B_Proc_GovFin.do

/*--- Number: Revenue/Expenditure per student/per capita ---*/

quietly sum totalrevenue_pe
local totalrevenue_pe = r(mean)
local totalrevenue_pe : display %-9.0fc `totalrevenue_pe'
file open myfile using "../Draft/nums/totalrevenue_pe.tex", write replace
file write myfile "`totalrevenue_pe'"
file close myfile

quietly sum totalrevenue_pc
local totalrevenue_pc = r(mean)
local totalrevenue_pc : display %-9.0fc `totalrevenue_pc'
file open myfile using "../Draft/nums/totalrevenue_pc.tex", write replace
file write myfile "`totalrevenue_pc'"
file close myfile

quietly sum totalexpenditure_pe
local totalexpenditure_pe = r(mean)
local totalexpenditure_pe : display %-9.0fc `totalexpenditure_pe'
file open myfile using "../Draft/nums/totalexpenditure_pe.tex", write replace
file write myfile "`totalexpenditure_pe'"
file close myfile

quietly sum totalexpenditure_pc
local totalexpenditure_pc = r(mean)
local totalexpenditure_pc : display %-9.0fc `totalexpenditure_pc'
file open myfile using "../Draft/nums/totalexpenditure_pc.tex", write replace
file write myfile "`totalexpenditure_pc'"
file close myfile

/* Number: Interest expense as a fraction of total expenditure */

quietly sum totalinterestondebt_toexp if type==5
local totalinterestondebt_toexp_SD = r(mean)
local totalinterestondebt_toexp_SD : display %-9.1f `totalinterestondebt_toexp_SD'
file open myfile using "../Draft/nums/totalinterestondebt_toexp_SD.tex", write replace
file write myfile "`totalinterestondebt_toexp_SD'"
file close myfile

quietly sum totalinterestondebt_toexp if type==1|type==2|type==3
local totalinterestondebt_toexp_nonSD = r(mean)
local totalinterestondebt_toexp_nonSD : display %-9.1f `totalinterestondebt_toexp_nonSD'
file open myfile using "../Draft/nums/totalinterestondebt_toexp_nonSD.tex", write replace
file write myfile "`totalinterestondebt_toexp_nonSD'"
file close myfile

/* Number: New debt issuance as a fraction of total expenditure */

quietly sum totalltdissued_toexp if type==5
local totalltdissued_toexp_SD = r(mean)
local totalltdissued_toexp_SD : display %-9.1f `totalltdissued_toexp_SD'
file open myfile using "../Draft/nums/totalltdissued_toexp_SD.tex", write replace
file write myfile "`totalltdissued_toexp_SD'"
file close myfile

quietly sum totalltdissued_toexp if type==1|type==2|type==3
local totalltdissued_toexp_nonSD = r(mean)
local totalltdissued_toexp_nonSD : display %-9.1f `totalltdissued_toexp_nonSD'
file open myfile using "../Draft/nums/totalltdissued_toexp_nonSD.tex", write replace
file write myfile "`totalltdissued_toexp_nonSD'"
file close myfile

/* Number: Total taxes as a fraction of total expenditure */

quietly sum totaltaxes_toexp if type==5
local totaltaxes_toexp_SD = r(mean)
local totaltaxes_toexp_SD : display %-9.1f `totaltaxes_toexp_SD'
file open myfile using "../Draft/nums/totaltaxes_toexp_SD.tex", write replace
file write myfile "`totaltaxes_toexp_SD'"
file close myfile

quietly sum totaltaxes_toexp if type==1|type==2|type==3
local totaltaxes_toexp_nonSD = r(mean)
local totaltaxes_toexp_nonSD : display %-9.1f `totaltaxes_toexp_nonSD'
file open myfile using "../Draft/nums/totaltaxes_toexp_nonSD.tex", write replace
file write myfile "`totaltaxes_toexp_nonSD'"
file close myfile

/* Number: Inter-gov transfer as a fraction of total expenditure */

quietly sum totaligrevenue_toexp if type==5
local totaligrevenue_toexp_SD = r(mean)
local totaligrevenue_toexp_SD : display %-9.1f `totaligrevenue_toexp_SD'
file open myfile using "../Draft/nums/totaligrevenue_toexp_SD.tex", write replace
file write myfile "`totaligrevenue_toexp_SD'"
file close myfile

quietly sum totaligrevenue_toexp if type==1|type==2|type==3
local totaligrevenue_toexp_nonSD = r(mean)
local totaligrevenue_toexp_nonSD : display %-9.1f `totaligrevenue_toexp_nonSD'
file open myfile using "../Draft/nums/totaligrevenue_toexp_nonSD.tex", write replace
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

local varlist = "totalrevenue_pe totalexpenditure_pe totalinterestondebt_toexp totalltdissued_toexp surplus_ratio totaltaxes_toexp propertytax_toexp totaligrevenue_toexp totalfedigrevenue_toexp totalstateigrevenue_toexp totlocaligrev_toexp"
local lb_totalrevenue_pe = "Revenue Per Student"
local lb_totalexpenditure_pe = "Expenditure Per Student"
local lb_totalinterestondebt_toexp = "Interest Paid/Exp. (%)"
local lb_totalltdissued_toexp "New Issuance/Exp. (%)"
local lb_surplus_ratio "Surplus Ratio (%)"
local lb_totaltaxes_toexp "Total Taxes/Exp. (%)"
local lb_propertytax_toexp "Property Tax/Exp. (%)"
local lb_totaligrevenue_toexp "Inter-Gov. Trans./Exp. (%)"
local lb_totalfedigrevenue_toexp "Inter-Gov. Trans. from Federal/Exp. (%)"
local lb_totalstateigrevenue_toexp "Inter-Gov. Trans. from State/Exp. (%)"
local lb_totlocaligrev_toexp "Inter-Gov. Trans. from Local/Exp. (%)"

foreach var in `varlist' {

preserve 
use `GovFin', clear
quietly sum `var' if typecode==5, d
local mean = string(r(mean), "%6.1f")
local sd = string(r(sd), "%6.1f")
local p25 = string(r(p25), "%6.1f")
local median = string(r(p50), "%6.1f")
local p75 = string(r(p75), "%6.1f")
local N = string(r(N), "%6.0f")
restore

post `memhold' ("`lb_`var''") ("`mean'") ("`sd'") ("`p25'") ("`median'") ("`p75'") ("`N'")


}

post `memhold' (" ") (" ") (" ") (" ") (" ") (" ") (" ")

post `memhold' ("Panel E: Municipalities/Townships/Counties Sample") (" ") (" ") (" ") (" ") (" ") (" ")

local varlist = "totalrevenue_pc totalexpenditure_pc totalinterestondebt_toexp totalltdissued_toexp surplus_ratio totaltaxes_toexp propertytax_toexp totaligrevenue_toexp totalfedigrevenue_toexp totalstateigrevenue_toexp totlocaligrev_toexp"
local lb_totalrevenue_pc = "Revenue Per Capita"
local lb_totalexpenditure_pc = "Expenditure Per Capita"
local lb_totalinterestondebt_toexp = "Interest Paid/Exp. (%)"
local lb_totalltdissued_toexp "New Issuance/Exp. (%)"
local lb_surplus_ratio "Surplus Ratio (%)"
local lb_totaltaxes_toexp "Total Taxes/Exp. (%)"
local lb_propertytax_toexp "Property Tax/Exp. (%)"
local lb_totaligrevenue_toexp "Inter-Gov. Trans./Exp. (%)"
local lb_totalfedigrevenue_toexp "Inter-Gov. Trans. from Federal/Exp. (%)"
local lb_totalstateigrevenue_toexp "Inter-Gov. Trans. from State/Exp. (%)"
local lb_totlocaligrev_toexp "Inter-Gov. Trans. from Local/Exp. (%)"

foreach var in `varlist' {

preserve 
use `GovFin', clear
quietly sum `var' if typecode!=5, d
local mean = string(r(mean), "%6.1f")
local sd = string(r(sd), "%6.1f")
local p25 = string(r(p25), "%6.1f")
local median = string(r(p50), "%6.1f")
local p75 = string(r(p75), "%6.1f")
local N = string(r(N), "%6.0f")
restore

post `memhold' ("`lb_`var''") ("`mean'") ("`sd'") ("`p25'") ("`median'") ("`p75'") ("`N'")


}

postclose `memhold'
clear
use `table'

texsave using "../Draft/tabs/Sum_Stats_GovFin.tex", replace frag nonames title("Summary Statistics") size(small) label("sum_stats_govfin") location("H")




