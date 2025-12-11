
/*------------------------------------------------------------------------------------------------------------*/
/* Table: Total issuing cost and modified true interest cost, in one table, with two versions, time FE or not */
/*------------------------------------------------------------------------------------------------------------*/

local outfile =  "../Draft/tabs/DID_MA_NetCost_main.tex"

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
postfile `memhold' str100 varname str30 (coef1 coef2 coef3 coef4) using `table', replace
post `memhold' (" ") ("(1)") ("(2)") ("(3)") ("(4)")
post `memhold' (" ") ("Total Issuance") ("Total Issuance") ("Total Issuance") ("Total Issuance")
post `memhold' (" ") ("Expenses (bps.)") ("Expenses, Year FE") ("Expenses (bps.)") ("Expenses, Year FE")
post `memhold' (" ") ("\;") ("Model (bps.)") ("\;") ("Model (bps.)")

foreach panelname in "m4to4" "m4to7" "m4to10" {
	
	if "`panelname'"=="m4to4" {
		local begin_year = -4
		local end_year = 4
		local paneltitle = "Panel A: [-4, +4]"
	}

	if "`panelname'"=="m4to7" {
		local begin_year = -4
		local end_year = 7
		local paneltitle = "Panel B: [-4, +7]"
	}

	if "`panelname'"=="m4to10" {
		local begin_year = -4
		local end_year = 10
		local paneltitle = "Panel C: [-4, +10]"
	}

	use `CSA_episodes_impliedHHIbyN', clear

	/* Column 1*/

	// Column 1: Sample based on Delta HHI
	reghdfe net_cost_inbp treatedXpost ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) ///
	cluster(csacode calendar_year) noconstant

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

	// Column 2: Sample based on Delta HHI
	reghdfe net_cost_inbp_timefe treatedXpost ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) ///
	cluster(csacode calendar_year) noconstant

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

	use `CSA_episodes_top5shareByN', clear

	/* Column 3*/

	// Column 3: Sample based on Delta HHI
	reghdfe net_cost_inbp treatedXpost ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) ///
	cluster(csacode calendar_year) noconstant

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

	/* Column 4 */

	// Column 4: Sample based on Delta HHI
	reghdfe net_cost_inbp_timefe treatedXpost ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) ///
	cluster(csacode calendar_year) noconstant

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

	post `memhold' (" ") (" ") (" ") (" ") (" ")
	post `memhold' ("`paneltitle'") (" ") (" ") (" ") (" ")
	post `memhold' ("Treated $\times$ Post") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'") ("`b_coef4'")
	post `memhold' (" ") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'") ("`t_coef4'")
	post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'") ("`obs_coef4'")
	post `memhold' ("Adjusted R-squared") ("`r2_coef1'") ("`r2_coef2'") ("`r2_coef3'") ("`r2_coef4'")

}

post `memhold' (" ") (" ") (" ") (" ") (" ")
post `memhold' ("Issuer \(\times\) Cohort FE") ("Yes") ("Yes") ("Yes") ("Yes")
post `memhold' ("Cohort \(\times\) Year FE") ("Yes") ("Yes") ("Yes") ("Yes")
post `memhold' ("Clustering") ("CSA \& Year") ("CBSA \& Year") ("CSA \& Year") ("CBSA \& Year")

postclose `memhold'
use `table', clear
texsave using "`outfile'", replace dataonly nonames italics("Panel") nofix hlines(4)




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

reghdfe net_cost_inbp treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) ///
cluster(csacode calendar_year) noconstant

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

reghdfe mod_tic_spread_inbp treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) ///
cluster(csacode calendar_year) noconstant

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
reghdfe net_cost_inbp treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) ///
cluster(csacode calendar_year) noconstant

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Total Issuance","Expenses (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Cohort $\times$ Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 2 */

// Column 2: Using modified TIC
reghdfe mod_tic_spread_inbp treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) ///
cluster(csacode calendar_year) noconstant

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Modified TIC","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Cohort $\times$ Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")





/*------------------------------------------*/
/* Table for the Slides, total issuing cost */
/*------------------------------------------*/

{

local outfile =  "../Draft/tabs/Slides_DID_MA_TotalIssuingCost.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

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

// Column 1: Using implied HHI increase > 0.01
reghdfe net_cost_inbp treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) ///
cluster(csacode calendar_year) noconstant

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Total Issuance","Expenses (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Cohort $\times$ Year FE", "Yes","Issuer \(\times\) Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 2 */

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

// Column 3: Using rise in top 5 share > 0.05
reghdfe net_cost_inbp treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) ///
cluster(csacode calendar_year) noconstant

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Total Issuance","Expenses (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Cohort $\times$ Year FE", "Yes","Issuer \(\times\) Cohort FE", "Yes","Clustering","CSA \& Year")

}



/*-------------------------------------------*/
/* Table for the Slides, modified TIC spread */
/*-------------------------------------------*/

{

local outfile =  "../Draft/tabs/Slides_DID_MA_ModifiedTIC.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

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

// Column 1: Using implied HHI increase > 0.01
reghdfe mod_tic_spread_inbp treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) ///
cluster(csacode calendar_year) noconstant

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Modified TIC","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Cohort $\times$ Year FE", "Yes","Issuer \(\times\) Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 2 */

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

// Column 2: Using rise in top 5 share > 0.05
reghdfe mod_tic_spread_inbp treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) ///
cluster(csacode calendar_year) noconstant

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Modified TIC","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Cohort $\times$ Year FE", "Yes","Issuer \(\times\) Cohort FE", "Yes","Clustering","CSA \& Year")

}

