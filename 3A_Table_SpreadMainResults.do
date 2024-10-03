
/*------------------------------------------*/
/* Table: Main results of spread around M&A */
/*------------------------------------------*/

local outfile =  "../Draft/tabs/DID_MA_GrossSpread_main.tex"

tempfile table
tempname memhold
postfile `memhold' str100 varname str30 (coef1 coef2 coef3 coef4 coef5 coef6) using `table', replace
post `memhold' (" ") ("(1)") ("(2)") ("(3)") ("(4)") ("(5)") ("(6)")
post `memhold' (" ") ("Underwriting") ("Underwriting") ("Underwriting") ("Underwriting") ("Underwriting") ("Underwriting")
post `memhold' (" ") ("Spread (bps.)") ("Spread (bps.)") ("Spread (bps.)") ("Spread (bps.)") ("Spread (bps.)") ("Spread (bps.)")

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

	/* Column 1*/

	import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear 

	gen gross_spread_inbp = gross_spread*10

	gen post = year_to_merger>=0
	gen treatedXpost = treated*post
	label var treatedXpost "Treated $\times$ Post"

	encode issuer, gen(issuer_code)

	// Column 1: Using implied HHI increase > 0.01
	reghdfe gross_spread_inbp treated post treatedXpost ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', ///
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

	import delimited "../CleanData/MAEvent/CBSA_episodes_impliedHHIbyN.csv", clear 

	gen gross_spread_inbp = gross_spread*10

	gen post = year_to_merger>=0
	gen treatedXpost = treated*post
	label var treatedXpost "Treated $\times$ Post"

	encode issuer, gen(issuer_code)

	// Column 2: Using implied HHI increase > 0.01
	reghdfe gross_spread_inbp treated post treatedXpost ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_cbsa calendar_year) cluster(cbsacode calendar_year)

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

	import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear 

	gen gross_spread_inbp = gross_spread*10

	gen post = year_to_merger>=0
	gen treatedXpost = treated*post
	label var treatedXpost "Treated $\times$ Post"

	encode issuer, gen(issuer_code)

	// Column 3: Using market share of target and acquiror > 0.05
	reghdfe gross_spread_inbp treated post treatedXpost ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', ///
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

	/* Column 4 */

	import delimited "../CleanData/MAEvent/CBSA_episodes_marketsharebyN.csv", clear 

	gen gross_spread_inbp = gross_spread*10

	gen post = year_to_merger>=0
	gen treatedXpost = treated*post
	label var treatedXpost "Treated $\times$ Post"

	encode issuer, gen(issuer_code)

	// Column 4: Using market share of target and acquiror > 0.05
	reghdfe gross_spread_inbp treated post treatedXpost ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_cbsa calendar_year) cluster(cbsacode calendar_year)

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

	/* Column 5 */

	import delimited "../CleanData/MAEvent/CSA_episodes_top5shareByN.csv", clear 

	gen gross_spread_inbp = gross_spread*10

	gen post = year_to_merger>=0
	gen treatedXpost = treated*post
	label var treatedXpost "Treated $\times$ Post"

	encode issuer, gen(issuer_code)

	// Column 5: Using rise in top 5 share > 0.05
	reghdfe gross_spread_inbp treated post treatedXpost ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

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

	/* Column 6 */

	import delimited "../CleanData/MAEvent/CBSA_episodes_top5shareByN.csv", clear 

	gen gross_spread_inbp = gross_spread*10

	gen post = year_to_merger>=0
	gen treatedXpost = treated*post
	label var treatedXpost "Treated $\times$ Post"

	encode issuer, gen(issuer_code)

	// Column 6: Using rise in top 5 share > 0.05
	reghdfe gross_spread_inbp treated post treatedXpost ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_cbsa calendar_year) cluster(cbsacode calendar_year)

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

	post `memhold' (" ") (" ") (" ") (" ") (" ") (" ") (" ")
	post `memhold' ("`paneltitle'") (" ") (" ") (" ") (" ") (" ") (" ")
	post `memhold' ("Treated $\times$ Post") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'") ("`b_coef4'") ("`b_coef5'") ("`b_coef6'")
	post `memhold' (" ") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'") ("`t_coef4'") ("`t_coef5'") ("`t_coef6'")
	post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'") ("`obs_coef4'") ("`obs_coef5'") ("`obs_coef6'")
	post `memhold' ("Adjusted R-squared") ("`r2_coef1'") ("`r2_coef2'") ("`r2_coef3'") ("`r2_coef4'") ("`r2_coef5'") ("`r2_coef6'")

}

post `memhold' (" ") (" ") (" ") (" ") (" ") (" ") (" ")
post `memhold' ("Issuer \(\times\) Cohort FE") ("Yes") ("Yes") ("Yes") ("Yes") ("Yes") ("Yes")
post `memhold' ("Year FE") ("Yes") ("Yes") ("Yes") ("Yes") ("Yes") ("Yes")
post `memhold' ("Clustering") ("CSA \& Year") ("CBSA \& Year") ("CSA \& Year") ("CBSA \& Year") ("CSA \& Year") ("CBSA \& Year")

postclose `memhold'
use `table', clear
texsave using "`outfile'", replace dataonly nonames italics("Panel") nofix hlines(3)



/*----------------------*/
/* Table for the Slides */
/*----------------------*/

{

local outfile =  "../Draft/tabs/Slides_DID_MA_GrossSpread.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1*/

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 1: Using implied HHI increase > 0.01
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer \(\times\) Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 2 */

import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 2: Using market share of target and acquiror > 0.05
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer \(\times\) Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 3 */

import delimited "../CleanData/MAEvent/CSA_episodes_top5shareByN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 3: Using rise in top 5 share > 0.05
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer \(\times\) Cohort FE", "Yes","Clustering","CSA \& Year")

}




/*----------------------------------*/
/* Table for the Slides, Using CBSA */
/*----------------------------------*/

{

local outfile =  "../Draft/tabs/Slides_DID_MA_GrossSpread_CBSA.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1*/

import delimited "../CleanData/MAEvent/CBSA_episodes_impliedHHIbyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 1: Using implied HHI increase > 0.01
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_cbsa calendar_year) cluster(cbsacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer \(\times\) Cohort FE", "Yes","Clustering","CBSA \& Year")

/* Column 2 */

import delimited "../CleanData/MAEvent/CBSA_episodes_marketsharebyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 2: Using market share of target and acquiror > 0.05
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_cbsa calendar_year) cluster(cbsacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer \(\times\) Cohort FE", "Yes","Clustering","CBSA \& Year")

/* Column 3 */

import delimited "../CleanData/MAEvent/CBSA_episodes_top5shareByN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 3: Using rise in top 5 share > 0.05
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_cbsa calendar_year) cluster(cbsacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer \(\times\) Cohort FE", "Yes","Clustering","CBSA \& Year")

}




/******************/
/* Export numbers */
/******************/

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

// 

import excel "../RawData/MSA/CBSA.xlsx", sheet("List 1") cellrange(A3:L1921) firstrow clear

/*--- Number: Effects on gross spread ---*/

local spread_effects_main = _b[treatedXpost]
local spread_effects_main : display %-9.1f `spread_effects_main'
file open myfile using "../Draft/nums/spread_effects_main.tex", write replace
file write myfile "`spread_effects_main'"
file close myfile

local t_spread_effects_main = _b[treatedXpost]/_se[treatedXpost]
local t_spread_effects_main : display %-9.2f `t_spread_effects_main'
file open myfile using "../Draft/nums/t_spread_effects_main.tex", write replace
file write myfile "`t_spread_effects_main'"
file close myfile

preserve
import delimited "../CleanData/SDC/1A_GPF_OLS.csv", clear 
winsor2 amount, replace cuts(1 99)
gen amount_adjusted = amount*scaler
sum amount_adjusted, d

/*--- Number: Effects on gross spread as a fraction of sample average ---*/

sum gross_spread, d
local spread_effects_frac = _b[treatedXpost]/(r(mean)*10)*100
local spread_effects_frac : display %-9.1f `spread_effects_frac'
file open myfile using "../Draft/nums/spread_effects_frac.tex", write replace
file write myfile "`spread_effects_frac'"
file close myfile

/*--- Number: Median issue size ---*/

local median_size = r(p50)
local median_size : display %-9.1fc `median_size'
file open myfile using "../Draft/nums/median_size.tex", write replace
file write myfile "`median_size'"
file close myfile

/*--- Number: Effects on gross spread in dollars ---*/

local spread_effects_dollar = r(p50)*_b[treatedXpost]/10000*1000*1000
local spread_effects_dollar : display %-9.0fc `spread_effects_dollar'
file open myfile using "../Draft/nums/spread_effects_dollar.tex", write replace
file write myfile "`spread_effects_dollar'"
file close myfile

/*--- Number: Median issue size for a county ---*/

collapse (sum) amount_adjusted, by(csacode county calendar_year)
sum amount_adjusted, d
local median_size_county = r(p50)
local median_size_county : display %-9.1fc `median_size_county'
file open myfile using "../Draft/nums/median_size_county.tex", write replace
file write myfile "`median_size_county'"
file close myfile

/*--- Number: Effects on gross spread in dollars for a county ---*/

local spread_effects_dollar_county = r(p50)*_b[treatedXpost]/10000*1000*1000
local spread_effects_dollar_county : display %-9.0fc `spread_effects_dollar_county'
file open myfile using "../Draft/nums/median_spread_effects_dollar_county.tex", write replace
file write myfile "`spread_effects_dollar_county'"
file close myfile

/*--- Number: Median issue size for a CSA ---*/

collapse (sum) amount_adjusted, by(csacode calendar_year)
sum amount_adjusted, d
local median_size_csa = r(p50)
local median_size_csa : display %-9.0fc `median_size_csa'
file open myfile using "../Draft/nums/median_size_csa.tex", write replace
file write myfile "`median_size_csa'"
file close myfile

/*--- Number: Median effects on gross spread in dollars for a CSA ---*/

local spread_effects_dollar_csa = r(p50)*_b[treatedXpost]/10000*1000*1000
local spread_effects_dollar_csa : display %-9.0fc `spread_effects_dollar_csa'
file open myfile using "../Draft/nums/median_spread_effects_dollar_csa.tex", write replace
file write myfile "`spread_effects_dollar_csa'"
file close myfile

/*--- Number: Mean issue size for a CSA ---*/

collapse (sum) amount_adjusted, by(csacode calendar_year)
sum amount_adjusted, d
local mean_size_csa = r(mean)
local mean_size_csa : display %-9.0fc `mean_size_csa'
file open myfile using "../Draft/nums/mean_size_csa.tex", write replace
file write myfile "`mean_size_csa'"
file close myfile

/*--- Number: Median effects on gross spread in dollars for a CSA ---*/

local spread_effects_dollar_csa = r(mean)*_b[treatedXpost]/10000*1000*1000
local spread_effects_dollar_csa : display %-9.0fc `spread_effects_dollar_csa'
file open myfile using "../Draft/nums/mean_spread_effects_dollar_csa.tex", write replace
file write myfile "`spread_effects_dollar_csa'"
file close myfile

restore

