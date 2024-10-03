
/*------------------------------------------------------------------------------------------------------------*/
/* Table: Total issuing cost and modified true interest cost, in one table, with two versions, time FE or not */
/*------------------------------------------------------------------------------------------------------------*/

local outfile =  "../Draft/tabs/DID_MA_NetCostModTIC_main.tex"

// Sample based on Delta HHI

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)
gen if_advisor_coded = if_advisor=="Yes"
gen has_rating = (has_fitch=="True")|(has_moodys=="True")
replace insured_amount = 0 if insured_amount==.
gen insured_ratio = insured_amount/amount

gen net_cost_inbp = gross_spread_inbp+if_advisor_coded*advisorfeeratio_hat+has_rating*crfeeratio_hat+insured_ratio*insurefeeratio_hat
gen net_cost_inbp_timefe = gross_spread_inbp+if_advisor_coded*advisorfeeratio_hat_model_timefe+has_rating*crfeeratio_hat_model_timefe+insured_ratio*insurefeeratio_hat_model_timefe

gen mod_tic_spread_inbp = mod_tic_spread_treasury*10000
gen mod_tic_spread_inbp_timefe = mod_tic_spread_treasury_timefe*10000

tempfile CSA_episodes_impliedHHIbyN
save `CSA_episodes_impliedHHIbyN', replace

// Sample based on Market Share

import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)
gen if_advisor_coded = if_advisor=="Yes"
gen has_rating = (has_fitch=="True")|(has_moodys=="True")
replace insured_amount = 0 if insured_amount==.
gen insured_ratio = insured_amount/amount

gen net_cost_inbp = gross_spread_inbp+if_advisor_coded*advisorfeeratio_hat+has_rating*crfeeratio_hat+insured_ratio*insurefeeratio_hat
gen net_cost_inbp_timefe = gross_spread_inbp+if_advisor_coded*advisorfeeratio_hat_model_timefe+has_rating*crfeeratio_hat_model_timefe+insured_ratio*insurefeeratio_hat_model_timefe

gen mod_tic_spread_inbp = mod_tic_spread_treasury*10000
gen mod_tic_spread_inbp_timefe = mod_tic_spread_treasury_timefe*10000

tempfile CSA_episodes_marketsharebyN
save `CSA_episodes_marketsharebyN', replace

// Sample based on Top 5 Share

import delimited "../CleanData/MAEvent/CSA_episodes_top5shareByN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)
gen if_advisor_coded = if_advisor=="Yes"
gen has_rating = (has_fitch=="True")|(has_moodys=="True")
replace insured_amount = 0 if insured_amount==.
gen insured_ratio = insured_amount/amount

gen net_cost_inbp = gross_spread_inbp+if_advisor_coded*advisorfeeratio_hat+has_rating*crfeeratio_hat+insured_ratio*insurefeeratio_hat
gen net_cost_inbp_timefe = gross_spread_inbp+if_advisor_coded*advisorfeeratio_hat_model_timefe+has_rating*crfeeratio_hat_model_timefe+insured_ratio*insurefeeratio_hat_model_timefe

gen mod_tic_spread_inbp = mod_tic_spread_treasury*10000
gen mod_tic_spread_inbp_timefe = mod_tic_spread_treasury_timefe*10000

tempfile CSA_episodes_top5shareByN
save `CSA_episodes_top5shareByN', replace

// Produce table

tempfile table
tempname memhold
postfile `memhold' str100 varname str30 (coef1 coef2 coef3) using `table', replace
post `memhold' (" ") ("(1)") ("(2)") ("(3)")
	
foreach varname in "net_cost_inbp" "net_cost_inbp_timefe" "mod_tic_spread_inbp" "mod_tic_spread_inbp_timefe" {
	
	if "`varname'"=="net_cost_inbp" {
		post `memhold' (" ") (" ") (" ") (" ")
		post `memhold' ("Panel A: Using total issuing cost") (" ") (" ") (" ")
		post `memhold' (" ") ("Total Issuing") ("Total Issuing") ("Total Issuing")
		post `memhold' (" ") ("Cost (bps.)") ("Cost (bps.)") ("Cost (bps.)")
	}

	if "`varname'"=="net_cost_inbp_timefe" {
		post `memhold' (" ") (" ") (" ") (" ")
		post `memhold' ("Panel B: Using total issuing cost based on a model with year FE") (" ") (" ") (" ")
		post `memhold' (" ") ("Total Issuing") ("Total Issuing") ("Total Issuing")
		post `memhold' (" ") ("Cost, Year FE") ("Cost, Year FE") ("Cost, Year FE")
		post `memhold' (" ") ("Model (bps.)") ("Model (bps.)") ("Model (bps.)")
	}

	if "`varname'"=="mod_tic_spread_inbp" {
		post `memhold' (" ") (" ") (" ") (" ")
		post `memhold' ("Panel C: Using Modified TIC spread") (" ") (" ") (" ")
		post `memhold' (" ") ("Modified TIC") ("Modified TIC") ("Modified TIC")
		post `memhold' (" ") ("Spread (bps.)") ("Spread (bps.)") ("Spread (bps.)")
	}

	if "`varname'"=="mod_tic_spread_inbp_timefe" {
		post `memhold' (" ") (" ") (" ") (" ")
		post `memhold' ("Panel D: Using Modified TIC spread based on a model with year FE") (" ") (" ") (" ")
		post `memhold' (" ") ("Modified TIC") ("Modified TIC") ("Modified TIC")
		post `memhold' (" ") ("Spread, Year FE") ("Spread, Year FE") ("Spread, Year FE")
		post `memhold' (" ") ("Model (bps.)") ("Model (bps.)") ("Model (bps.)")
	}

	/* Column 1*/

	use `CSA_episodes_impliedHHIbyN', clear

	// Column 1: Sample based on Delta HHI
	reghdfe `varname' treated post treatedXpost ///
	if year_to_merger>=-4&year_to_merger<=4, ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

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

	/* Column 2 */

	use `CSA_episodes_marketsharebyN', clear

	// Column 2: Sample based on Market Share
	reghdfe `varname' treated post treatedXpost ///
	if year_to_merger>=-4&year_to_merger<=4, ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

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

	/* Column 3 */

	use `CSA_episodes_top5shareByN', clear

	// Column 3: Sample based on Top 5 Share
	reghdfe `varname' treated post treatedXpost ///
	if year_to_merger>=-4&year_to_merger<=4, ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

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

	post `memhold' ("Treated $\times$ Post") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
	post `memhold' (" ") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")
	post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'")
	post `memhold' ("Adjusted R-squared") ("`r2_coef1'") ("`r2_coef2'") ("`r2_coef3'")

}

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Issuer \(\times\) Cohort FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Year FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Clustering") ("CSA \& Year") ("CSA \& Year") ("CSA \& Year")

postclose `memhold'
use `table', clear
texsave using "`outfile'", replace dataonly nonames italics("Panel") nofix hlines(1)




/*----------------*/
/* Export numbers */
/*----------------*/

/* Column 1*/

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

gen if_advisor_coded = if_advisor=="Yes"
gen has_rating = (has_fitch=="True")|(has_moodys=="True")
replace insured_amount = 0 if insured_amount==.
gen insured_ratio = insured_amount/amount

gen net_cost_inbp = gross_spread_inbp+if_advisor_coded*advisorfeeratio_hat+has_rating*crfeeratio_hat+insured_ratio*insurefeeratio_hat
gen net_cost_inbp_timefe = gross_spread_inbp+if_advisor_coded*advisorfeeratio_hat_model_timefe+has_rating*crfeeratio_hat_model_timefe+insured_ratio*insurefeeratio_hat_model_timefe

gen mod_tic_spread_inbp = mod_tic_spread_treasury*10000
gen mod_tic_spread_inbp_timefe = mod_tic_spread_treasury_timefe*10000

/*--- Number: Effects on total costs ---*/

reghdfe net_cost_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

local totalcost_effects_main = _b[treatedXpost]
local totalcost_effects_main : display %-9.1f `totalcost_effects_main'
file open myfile using "../Draft/nums/totalcost_effects_main.tex", write replace
file write myfile "`totalcost_effects_main'"
file close myfile

local t_totalcost_effects_main = _b[treatedXpost]/_se[treatedXpost]
local t_totalcost_effects_main : display %-9.1f `t_totalcost_effects_main'
file open myfile using "../Draft/nums/t_totalcost_effects_main.tex", write replace
file write myfile "`t_totalcost_effects_main'"
file close myfile

/*--- Number: Effects on total costs ---*/

reghdfe mod_tic_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

local modticspread_effects_main = _b[treatedXpost]
local modticspread_effects_main : display %-9.1f `modticspread_effects_main'
file open myfile using "../Draft/nums/modticspread_effects_main.tex", write replace
file write myfile "`modticspread_effects_main'"
file close myfile

local t_modticspread_effects_main = _b[treatedXpost]/_se[treatedXpost]
local t_modticspread_effects_main : display %-9.1f `t_modticspread_effects_main'
file open myfile using "../Draft/nums/t_modticspread_effects_main.tex", write replace
file write myfile "`t_modticspread_effects_main'"
file close myfile




/*---------------------------------*/
/* Table: A version for the slides */
/*---------------------------------*/

local outfile =  "../Draft/tabs/Slides_DID_MA_NetCost_main.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

gen if_advisor_coded = if_advisor=="Yes"
gen has_rating = (has_fitch=="True")|(has_moodys=="True")
replace insured_amount = 0 if insured_amount==.
gen insured_ratio = insured_amount/amount

gen net_cost_inbp = gross_spread_inbp+if_advisor_coded*advisorfeeratio_hat+has_rating*crfeeratio_hat+insured_ratio*insurefeeratio_hat
gen net_cost_inbp_timefe = gross_spread_inbp+if_advisor_coded*advisorfeeratio_hat_model_timefe+has_rating*crfeeratio_hat_model_timefe+insured_ratio*insurefeeratio_hat_model_timefe

gen mod_tic_spread_inbp = mod_tic_spread_treasury*10000
gen mod_tic_spread_inbp_timefe = mod_tic_spread_treasury_timefe*10000

/* Column 1 */

// Column 1: Using total issuing cost
reghdfe net_cost_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Total Issuing","Cost (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 2 */

// Column 2: Using modified TIC
reghdfe mod_tic_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Modified TIC","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

