
/* Table: Cross-sectional heterogeneity of effects of spread around M&A */




/*-----------------------------------------------------------------------*/
/* Panel 1: By economics of where market power could have bigger effects */
/*-----------------------------------------------------------------------*/

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

local outfile =  "../Draft/tabs/DID_MA_GrossSpread_hetero_1.tex"

tempfile table
tempname memhold
postfile `memhold' str100 varname str30 (coef1 coef2 coef3) using `table', replace
post `memhold' (" ") ("(1)") ("(2)") ("(3)")
post `memhold' (" ") ("Underwriting") ("Underwriting") ("Underwriting")
post `memhold' (" ") ("Spread (bps.)") ("Spread (bps.)") ("Spread (bps.)")
post `memhold' (" ") ("[-4, +4]") ("[-4, +7]") ("[-4, +10]")

/*------------------------------*/
/* Panel A: By the size of M\&A */
/*------------------------------*/

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel A: By the significance of M\&A") (" ") (" ") (" ")

gen if_hhi_dif_lt200 = hhi_dif<=0.02
gen TXPXhhi_dif_lt200 = treatedXpost*(hhi_dif<=0.02)
local label_TXPXhhi_dif_lt200 = "\emph{Predicted} $\Delta_{HHI}$ in [100,200)"

gen if_hhi_dif_gt200 = hhi_dif>0.02
gen TXPXhhi_dif_gt200 = treatedXpost*(hhi_dif>0.02)
local label_TXPXhhi_dif_gt200 = "\emph{Predicted} $\Delta_{HHI}$ $\ge$ 200"

cap prog drop regression
prog regression

	args begin_year end_year
	
	reghdfe gross_spread_inbp ///
	TXPXhhi_dif_lt200 TXPXhhi_dif_gt200 ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', /// 
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
	i.episode_start_year##i.treated_csa##i.calendar_year) ///
	cluster(csacode calendar_year) noconstant

end

/* Effects when Delta HHI above 200 */

regression -4 10

local spread_effects_if_hhi_dif_gt200 = _b[TXPXhhi_dif_gt200]
local spread_effects_if_hhi_dif_gt200 : display %-9.1f `spread_effects_if_hhi_dif_gt200'
file open myfile using "../Draft/nums/spread_effects_if_hhi_dif_gt200.tex", write replace
file write myfile "`spread_effects_if_hhi_dif_gt200'"
file close myfile

local t_spread_if_hhi_dif_gt200 = _b[TXPXhhi_dif_gt200]/_se[TXPXhhi_dif_gt200]
local t_spread_if_hhi_dif_gt200 : display %-9.1f `t_spread_if_hhi_dif_gt200'
file open myfile using "../Draft/nums/t_spread_effects_if_hhi_dif_gt200.tex", write replace
file write myfile "`t_spread_if_hhi_dif_gt200'"
file close myfile

local spread_effects_if_hhi_dif_lt200 = _b[TXPXhhi_dif_lt200]
local spread_effects_if_hhi_dif_lt200 : display %-9.1f `spread_effects_if_hhi_dif_lt200'
file open myfile using "../Draft/nums/spread_effects_if_hhi_dif_lt200.tex", write replace
file write myfile "`spread_effects_if_hhi_dif_lt200'"
file close myfile

local t_spread_if_hhi_dif_lt200 = _b[TXPXhhi_dif_lt200]/_se[TXPXhhi_dif_lt200]
local t_spread_if_hhi_dif_lt200 : display %-9.1f `t_spread_if_hhi_dif_lt200'
file open myfile using "../Draft/nums/t_spread_effects_if_hhi_dif_lt200.tex", write replace
file write myfile "`t_spread_if_hhi_dif_lt200'"
file close myfile

foreach varname of varlist TXPXhhi_dif_lt200 TXPXhhi_dif_gt200 {

	regression -4 4

	local b_coef1 = _b[`varname']
	local t_coef1 = _b[`varname']/_se[`varname']
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

	regression -4 7

	local b_coef2 = _b[`varname']
	local t_coef2 = _b[`varname']/_se[`varname']
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

	regression -4 10

	local b_coef3 = _b[`varname']
	local t_coef3 = _b[`varname']/_se[`varname']
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

	post `memhold' ("`label_`varname''") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
	post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

}

/*-----------------*/
/* Panel B: By HHI */
/*-----------------*/

// Calculate an average HHI during sample period to avoid picking up heterogeneity in effects over time
preserve
keep hhi_by_n county calendar_year
duplicates drop county calendar_year, force
bysort county: egen avghhi_by_n = mean(hhi_by_n)
drop calendar_year hhi_by_n
duplicates drop county, force
tempfile avghhi_by_n
save `avghhi_by_n', replace
restore

merge m:1 county using `avghhi_by_n'

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel B: By pre-consolidation HHI") (" ") (" ") (" ")

gen if_avghhi_lt1000 = (avghhi_by_n<0.1)
gen TXPXavghhi_lt1000 = treatedXpost*(avghhi_by_n<0.1)
local label_TXPXavghhi_lt1000 = "HHI in [0,1000)"

gen if_avghhi_1000_2500 = (avghhi_by_n>=0.1&avghhi_by_n<0.25)
gen TXPXavghhi_1000_2500 = treatedXpost*(avghhi_by_n>=0.1&avghhi_by_n<0.25)
local label_TXPXavghhi_1000_2500 = "HHI in [1000,2500)"

gen if_avghhi_gt2500 = (avghhi_by_n>=0.25)
gen TXPXavghhi_gt2500 = treatedXpost*(avghhi_by_n>=0.25)
local label_TXPXavghhi_gt2500 = "HHI $\ge$ 2500"

cap prog drop regression
prog regression

	args begin_year end_year
	
	reghdfe gross_spread_inbp ///
	(post)##(if_avghhi_lt1000 if_avghhi_1000_2500 if_avghhi_gt2500) ///
	TXPXavghhi_lt1000 TXPXavghhi_1000_2500 TXPXavghhi_gt2500 ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', /// 
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
	i.episode_start_year##i.treated_csa##i.calendar_year) ///
	cluster(csacode calendar_year) noconstant

end

/* Effects when HHI above 2500 */
regression -4 10

local spread_effects_if_avghhi_gt2500 = _b[TXPXavghhi_gt2500]
local spread_effects_if_avghhi_gt2500 : display %-9.1f `spread_effects_if_avghhi_gt2500'
file open myfile using "../Draft/nums/spread_effects_if_avghhi_gt2500.tex", write replace
file write myfile "`spread_effects_if_avghhi_gt2500'"
file close myfile

local t_spread_if_avghhi_gt2500 = _b[TXPXavghhi_gt2500]/_se[TXPXavghhi_gt2500]
local t_spread_if_avghhi_gt2500 : display %-9.1f `t_spread_if_avghhi_gt2500'
file open myfile using "../Draft/nums/t_spread_effects_if_avghhi_gt2500.tex", write replace
file write myfile "`t_spread_if_avghhi_gt2500'"
file close myfile

foreach varname of varlist TXPXavghhi_lt1000 TXPXavghhi_1000_2500 TXPXavghhi_gt2500 {

	regression -4 4

	local b_coef1 = _b[`varname']
	local t_coef1 = _b[`varname']/_se[`varname']
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

	regression -4 7

	local b_coef2 = _b[`varname']
	local t_coef2 = _b[`varname']/_se[`varname']
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

	regression -4 10

	local b_coef3 = _b[`varname']
	local t_coef3 = _b[`varname']/_se[`varname']
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

	post `memhold' ("`label_`varname''") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
	post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

}

/*---------------------------------------------*/
/* Panel C: By whether using financial advisor */
/*---------------------------------------------*/

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel C: By if having financial advisor") (" ") (" ") (" ")

gen if_advisor_coded = if_advisor=="Yes"

gen TXPXif_has_advisor = treatedXpost*if_advisor_coded
local label_TXPXif_has_advisor = "If has advisor"

gen TXPXif_no_advisor = treatedXpost*(1-if_advisor_coded)
local label_TXPXif_no_advisor = "If no advisor"

cap prog drop regression
prog regression

	args begin_year end_year
	
	reghdfe gross_spread_inbp ///
	(treated post)##(if_advisor_coded) ///
	TXPXif_has_advisor TXPXif_no_advisor ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', /// 
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
	i.episode_start_year##i.treated_csa##i.calendar_year) ///
	cluster(csacode calendar_year) noconstant

end

foreach varname of varlist TXPXif_has_advisor TXPXif_no_advisor {

	regression -4 4

	local b_coef1 = _b[`varname']
	local t_coef1 = _b[`varname']/_se[`varname']
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

	regression -4 7

	local b_coef2 = _b[`varname']
	local t_coef2 = _b[`varname']/_se[`varname']
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

	regression -4 10

	local b_coef3 = _b[`varname']
	local t_coef3 = _b[`varname']/_se[`varname']
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

	post `memhold' ("`label_`varname''") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
	post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

}

/*--------------*/
/* Export table */
/*--------------*/

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Issuer \(\times\) Cohort FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Cohort \(\times\) Year FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Clustering") ("CSA \& Year") ("CSA \& Year") ("CSA \& Year")

postclose `memhold'
use `table', clear
texsave using "`outfile'", replace dataonly nonames italics("Panel") nofix hlines(4)




/*---------------------------------------------------------------------*/
/* Panel 2: By other features of interest in the municipal bond market */
/*---------------------------------------------------------------------*/


import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

local outfile =  "../Draft/tabs/DID_MA_GrossSpread_hetero_2.tex"

tempfile table
tempname memhold
postfile `memhold' str100 varname str30 (coef1 coef2 coef3) using `table', replace
post `memhold' (" ") ("(1)") ("(2)") ("(3)")
post `memhold' (" ") ("Underwriting") ("Underwriting") ("Underwriting")
post `memhold' (" ") ("Spread (bps.)") ("Spread (bps.)") ("Spread (bps.)")
post `memhold' (" ") ("[-4, +4]") ("[-4, +7]") ("[-4, +10]")

/*----------------------------------------------------------------------*/
/* Panel A: By whether issue is underwritten by a bank involved in M\&A */
/*----------------------------------------------------------------------*/

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel A: By whether bank is in M\&A") (" ") (" ") (" ")

// "if_bank_is_either" and "if_bank_is_neither" can take non-zero values based on M&As in the control areas. I set it to all
// 0 instead.
gen if_bank_is_either = (bank_is_acquiror=="True")|(bank_is_target=="True")
gen TXPXbank_is_either = treatedXpost*(bank_is_acquiror=="True")|(bank_is_target=="True")
replace if_bank_is_either = 0 if treated==0
replace TXPXbank_is_either = 0 if treated==0
local label_TXPXbank_is_either = "Underwriter is in M\&A"

gen if_bank_is_neither = (bank_is_acquiror!="True")&(bank_is_target!="True")
gen TXPXbank_is_neither = treatedXpost*(bank_is_acquiror!="True")&(bank_is_target!="True")
replace if_bank_is_neither = 0 if treated==0
replace TXPXbank_is_neither = 0 if treated==0
local label_TXPXbank_is_neither "Underwriter is not in M\&A"

cap prog drop regression
prog regression

	args begin_year end_year

	reghdfe gross_spread_inbp ///
	if_bank_is_either if_bank_is_neither TXPXbank_is_either TXPXbank_is_neither ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', /// 
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
	i.episode_start_year##i.treated_csa##i.calendar_year) ///
	cluster(csacode calendar_year) noconstant

end

foreach varname of varlist TXPXbank_is_either TXPXbank_is_neither {

	regression -4 4

	local b_coef1 = _b[`varname']
	local t_coef1 = _b[`varname']/_se[`varname']
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

	regression -4 7

	local b_coef2 = _b[`varname']
	local t_coef2 = _b[`varname']/_se[`varname']
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

	regression -4 10

	local b_coef3 = _b[`varname']
	local t_coef3 = _b[`varname']/_se[`varname']
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

	post `memhold' ("`label_`varname''") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
	post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

}

/*-----------------------------*/
/* Panel B: By method of sales */
/*-----------------------------*/

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel B: By method of sales") (" ") (" ") (" ")

encode bid, gen(bid_coded)

gen TXPXbidC = treatedXpost*(bid=="C")
local label_TXPXbidC "Competitive Bidding"

gen TXPXbidN = treatedXpost*(bid=="N")
local label_TXPXbidN = "Negotiated Sales"

gen TXPXbidP = treatedXpost*(bid=="P")
local label_TXPXbidP = "Private Placement"

cap prog drop regression
prog regression

	args begin_year end_year

	reghdfe gross_spread_inbp ///
	(i.treated i.post)##(i.bid_coded) TXPXbidC TXPXbidN TXPXbidP ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', /// 
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
	i.episode_start_year##i.treated_csa##i.calendar_year) ///
	cluster(csacode calendar_year) noconstant

end

foreach varname of varlist TXPXbidC TXPXbidN {

	regression -4 4

	local b_coef1 = _b[`varname']
	local t_coef1 = _b[`varname']/_se[`varname']
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

	regression -4 7

	local b_coef2 = _b[`varname']
	local t_coef2 = _b[`varname']/_se[`varname']
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

	regression -4 10

	local b_coef3 = _b[`varname']
	local t_coef3 = _b[`varname']/_se[`varname']
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

	post `memhold' ("`label_`varname''") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
	post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

}

/*----------------------------*/
/* Panel C: By taxable status */
/*----------------------------*/

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel C: By taxable status") (" ") (" ") (" ")

encode taxable_code, gen(taxable_code_coded)

gen TXPXtaxableE = treatedXpost*(taxable_code=="E")
local label_TXPXtaxableE = "Tax-Exempt"

gen TXPXtaxableT = treatedXpost*(taxable_code=="T")
local label_TXPXtaxableT = "Taxable"

gen TXPXtaxableA = treatedXpost*(taxable_code=="A")
local label_TXPXtaxableA = "Alternative Minimum Tax"

cap prog drop regression
prog regression

	args begin_year end_year

	reghdfe gross_spread_inbp ///
	(i.treated i.post)##(i.taxable_code_coded) TXPXtaxableE TXPXtaxableT TXPXtaxableA ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', /// 
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
	i.episode_start_year##i.treated_csa##i.calendar_year) ///
	cluster(csacode calendar_year) noconstant

end

foreach varname of varlist TXPXtaxableE TXPXtaxableT TXPXtaxableA {

	regression -4 4

	local b_coef1 = _b[`varname']
	local t_coef1 = _b[`varname']/_se[`varname']
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

	regression -4 7

	local b_coef2 = _b[`varname']
	local t_coef2 = _b[`varname']/_se[`varname']
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

	regression -4 10

	local b_coef3 = _b[`varname']
	local t_coef3 = _b[`varname']/_se[`varname']
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

	post `memhold' ("`label_`varname''") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
	post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

}

/*---------------------------------*/
/* Panel D: By source of repayment */
/*---------------------------------*/

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel D: By source of repayment") (" ") (" ") (" ")

encode security_type, gen(security_type_coded)

gen TXPXsectypeREV = treatedXpost*(security_type=="RV")
local label_TXPXsectypeREV "REV"

gen TXPXsectypeGO = treatedXpost*(security_type=="GO")
local label_TXPXsectypeGO "GO"

cap prog drop regression
prog regression

	args begin_year end_year

	reghdfe gross_spread_inbp ///
	(i.treated i.post)##(i.security_type_coded) TXPXsectypeREV TXPXsectypeGO ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', /// 
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
	i.episode_start_year##i.treated_csa##i.calendar_year) ///
	cluster(csacode calendar_year) noconstant

end

foreach varname of varlist TXPXsectypeREV TXPXsectypeGO {

	regression -4 4

	local b_coef1 = _b[`varname']
	local t_coef1 = _b[`varname']/_se[`varname']
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

	regression -4 7

	local b_coef2 = _b[`varname']
	local t_coef2 = _b[`varname']/_se[`varname']
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

	regression -4 10

	local b_coef3 = _b[`varname']
	local t_coef3 = _b[`varname']/_se[`varname']
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

	post `memhold' ("`label_`varname''") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
	post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

}

/*----------------------------------------------*/
/* Panel E: By whether issue is a refunding one */
/*----------------------------------------------*/

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel E: By if refunding issue") (" ") (" ") (" ")

gen TXPXrefunding = treatedXpost*if_refunding
local label_TXPXrefunding = "If refunding issue"

gen TXPXnot_refunding = treatedXpost*(1-if_refunding)
local label_TXPXnot_refunding = "If not refunding issue"

cap prog drop regression
prog regression

	args begin_year end_year

	reghdfe gross_spread_inbp ///
	(i.treated i.post)##(if_refunding) TXPXrefunding TXPXnot_refunding ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', /// 
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
	i.episode_start_year##i.treated_csa##i.calendar_year) ///
	cluster(csacode calendar_year) noconstant

end

foreach varname of varlist TXPXrefunding TXPXnot_refunding {

	regression -4 4

	local b_coef1 = _b[`varname']
	local t_coef1 = _b[`varname']/_se[`varname']
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

	regression -4 7

	local b_coef2 = _b[`varname']
	local t_coef2 = _b[`varname']/_se[`varname']
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

	regression -4 10

	local b_coef3 = _b[`varname']
	local t_coef3 = _b[`varname']/_se[`varname']
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

	post `memhold' ("`label_`varname''") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
	post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

}

/*-------------------------------------*/
/* Panel H: Dividing the sample period */
/*-------------------------------------*/

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel F: Dividing the sample period") (" ") (" ") (" ")

gen if_before2000 = (calendar_year-year_to_merger<=2000)

gen TXPXbefore2000 = treatedXpost*(calendar_year-year_to_merger<=2000)
local label_TXPXbefore2000 = "Pre-2000"

gen TXPXafter2000 = treatedXpost*(calendar_year-year_to_merger>2000)
local label_TXPXafter2000 = "Post-2000"

cap prog drop regression
prog regression

	args begin_year end_year
	
	reghdfe gross_spread_inbp ///
	TXPXbefore2000 TXPXafter2000 ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', /// 
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
	i.episode_start_year##i.treated_csa##i.calendar_year) ///
	cluster(csacode calendar_year) noconstant

end

foreach varname of varlist TXPXbefore2000 TXPXafter2000 {

	regression -4 4

	local b_coef1 = _b[`varname']
	local t_coef1 = _b[`varname']/_se[`varname']
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

	regression -4 7

	local b_coef2 = _b[`varname']
	local t_coef2 = _b[`varname']/_se[`varname']
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

	regression -4 10

	local b_coef3 = _b[`varname']
	local t_coef3 = _b[`varname']/_se[`varname']
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

	post `memhold' ("`label_`varname''") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
	post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

}

/*--------------*/
/* Export table */
/*--------------*/

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Issuer \(\times\) Cohort FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Cohort \(\times\) Year FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Clustering") ("CSA \& Year") ("CSA \& Year") ("CSA \& Year")

postclose `memhold'
use `table', clear
texsave using "`outfile'", replace dataonly nonames italics("Panel") nofix hlines(4)




/*----------------------------------------------------------*/
/* Panel 3: By other feature of interest of the muni market */
/*----------------------------------------------------------*/

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

local outfile =  "../Draft/tabs/DID_MA_GrossSpread_hetero_3.tex"

tempfile table
tempname memhold
postfile `memhold' str100 varname str30 (coef1 coef2 coef3) using `table', replace
post `memhold' (" ") ("(1)") ("(2)") ("(3)")
post `memhold' (" ") ("Underwriting") ("Underwriting") ("Underwriting")
post `memhold' (" ") ("Spread (bps.)") ("Spread (bps.)") ("Spread (bps.)")
post `memhold' (" ") ("[-4, +4]") ("[-4, +7]") ("[-4, +10]")

/*---------------------------*/
/* Panel I: By size of issue */
/*---------------------------*/

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel G: By size of issue") (" ") (" ") (" ")

gen decade = floor(calendar_year/10)*10
bysort decade csacode: egen median_amount = median(amount)

gen if_small = (amount<=median_amount)

gen TXPXsmall= treatedXpost*(amount<=median_amount)
local label_TXPXsmall = "Amount below median"

gen TXPXlarge= treatedXpost*(amount>median_amount)
local label_TXPXlarge = "Amount above median"

cap prog drop regression
prog regression

	args begin_year end_year
	
	reghdfe gross_spread_inbp ///
	(treated post)##(if_small) ///
	TXPXsmall TXPXlarge ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', /// 
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
	i.episode_start_year##i.treated_csa##i.calendar_year) ///
	cluster(csacode calendar_year) noconstant

end

foreach varname of varlist TXPXsmall TXPXlarge {

	regression -4 4

	local b_coef1 = _b[`varname']
	local t_coef1 = _b[`varname']/_se[`varname']
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

	regression -4 7

	local b_coef2 = _b[`varname']
	local t_coef2 = _b[`varname']/_se[`varname']
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

	regression -4 10

	local b_coef3 = _b[`varname']
	local t_coef3 = _b[`varname']/_se[`varname']
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

	post `memhold' ("`label_`varname''") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
	post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

}

/*--------------------------------*/
/* Panel J: By length of maturity */
/*--------------------------------*/

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel H: By maturity length of issue") (" ") (" ") (" ")

bysort decade csacode: egen median_avg_maturity = median(avg_maturity)

gen if_long = (avg_maturity>=median_avg_maturity)

gen TXPXlong= treatedXpost*(avg_maturity>=median_avg_maturity)
local label_TXPXlong = "Maturity length above median"

gen TXPXshort= treatedXpost*(avg_maturity<median_avg_maturity)
local label_TXPXshort = "Maturity length below median"

cap prog drop regression
prog regression

	args begin_year end_year
	
	reghdfe gross_spread_inbp ///
	(treated post)##(if_long) ///
	TXPXlong TXPXshort ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', /// 
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
	i.episode_start_year##i.treated_csa##i.calendar_year) ///
	cluster(csacode calendar_year) noconstant

end

foreach varname of varlist TXPXlong TXPXshort {

	regression -4 4

	local b_coef1 = _b[`varname']
	local t_coef1 = _b[`varname']/_se[`varname']
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

	regression -4 7

	local b_coef2 = _b[`varname']
	local t_coef2 = _b[`varname']/_se[`varname']
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

	regression -4 10

	local b_coef3 = _b[`varname']
	local t_coef3 = _b[`varname']/_se[`varname']
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

	post `memhold' ("`label_`varname''") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
	post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

}

/*------------------------------------*/
/* Panel K: By area ratio composition */
/*------------------------------------*/

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel I: By area racial composition") (" ") (" ") (" ")

bysort decade: egen black_ratio_p75 = pctile(black_ratio), p(75)

gen if_black = (black_ratio>black_ratio_p75)&(black_ratio!=.)

gen TXPXblack = treatedXpost*((black_ratio>black_ratio_p75)&(black_ratio!=.))
local label_TXPXblack = "Black population ratio in top quartile"

gen TXPXnotblack = treatedXpost*((black_ratio<=black_ratio_p75)&(black_ratio!=.))
local label_TXPXnotblack = "Black population ratio not in top quartile"

cap prog drop regression
prog regression

	args begin_year end_year
	
	reghdfe gross_spread_inbp ///
	(treated post)##(if_black) ///
	TXPXblack TXPXnotblack ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', /// 
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
	i.episode_start_year##i.treated_csa##i.calendar_year) ///
	cluster(csacode calendar_year) noconstant

end

foreach varname of varlist TXPXblack TXPXnotblack {

	regression -4 4

	local b_coef1 = _b[`varname']
	local t_coef1 = _b[`varname']/_se[`varname']
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

	regression -4 7

	local b_coef2 = _b[`varname']
	local t_coef2 = _b[`varname']/_se[`varname']
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

	regression -4 10

	local b_coef3 = _b[`varname']
	local t_coef3 = _b[`varname']/_se[`varname']
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

	post `memhold' ("`label_`varname''") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'")
	post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")

}

/*--------------*/
/* Export table */
/*--------------*/

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Issuer \(\times\) Cohort FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Cohort \(\times\) Year FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Clustering") ("CSA \& Year") ("CSA \& Year") ("CSA \& Year")

postclose `memhold'
use `table', clear
texsave using "`outfile'", replace dataonly nonames italics("Panel") nofix hlines(4)




/*--------------------------------------------------------------------*/
/* Table in the Appendix: Can employing an advisor undo market power? */
/*--------------------------------------------------------------------*/

// Note that variable label is too long and has to be updated by hand in the latex table

local outfile =  "../Draft/tabs/DID_MA_GrossSpread_advisor_undo.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

/* Column 1 */

gen if_advisor_coded = if_advisor=="Yes"

gen TXPXhas_advisor = treatedXpost*if_advisor_coded
label var TXPXhas_advisor "Treated $\times$ Post $\times$ Has Advisor"

gen TXPXno_advisor = treatedXpost*(1-if_advisor_coded)
label var TXPXno_advisor "Treated $\times$ Post $\times$ No Advisor"

// Column 1: By whether employing an advisor
reghdfe gross_spread_inbp ///
(i.post i.treated)##(if_advisor_coded) ///
TXPXhas_advisor TXPXno_advisor ///
if year_to_merger>=-4 & year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
i.episode_start_year##i.treated_csa##i.calendar_year) ///
cluster(csacode calendar_year) noconstant

outreg2 using  "`outfile'", tex(fragment) replace label ///
keep(TXPXhas_advisor TXPXno_advisor) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer \(\times\) Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 2 */

gen if_has_advisor_hhi_dif_100_200 = (if_advisor=="Yes")*(hhi_dif>=0.01&hhi_dif<0.02)
gen TXPXhas_advisor_hhi_dif_100_200 = treatedXpost*(if_advisor=="Yes")*(hhi_dif>=0.01&hhi_dif<0.02)
label var TXPXhas_advisor_hhi_dif_100_200 "T X P $\times$ HA $\times$ \emph{Predicted} $\Delta_{HHI}$ in [0.01,0.02)"

gen if_has_advisor_hhi_dif_gt_200 = (if_advisor=="Yes")*(hhi_dif>0.02)
gen TXPXhas_advisor_hhi_dif_gt_200 = treatedXpost*(if_advisor=="Yes")*(hhi_dif>0.02)
label var TXPXhas_advisor_hhi_dif_gt_200 "T X P $\times$ HA $\times$ \emph{Predicted} $\Delta_{HHI}$ $\ge$ 0.02"

// Column 2: By whether employing an advisor, for levels of increased in HHI induced by merger 
reghdfe gross_spread_inbp ///
(i.post i.treated)##(i.if_has_advisor_hhi_dif_100_200 i.if_has_advisor_hhi_dif_gt_200 if_advisor_coded) ///
TXPXhas_advisor_hhi_dif_100_200 TXPXhas_advisor_hhi_dif_gt_200 TXPXno_advisor ///
if year_to_merger>=-4 & year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
i.episode_start_year##i.treated_csa##i.calendar_year) ///
cluster(csacode calendar_year) noconstant

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(TXPXhas_advisor_hhi_dif_100_200 TXPXhas_advisor_hhi_dif_gt_200 TXPXno_advisor) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer \(\times\) Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 3 */

// Calculate an average HHI during sample period to avoid picking up heterogeneity in effects over time
preserve
keep hhi_by_n county calendar_year
duplicates drop county calendar_year, force
bysort county: egen avghhi_by_n = mean(hhi_by_n)
drop calendar_year hhi_by_n
duplicates drop county, force
tempfile avghhi_by_n
save `avghhi_by_n', replace
restore

merge m:1 county using `avghhi_by_n'

gen if_avghhi_lt1000 = (avghhi_by_n<0.1)
gen if_avghhi_1000_2500 = (avghhi_by_n>=0.1&avghhi_by_n<0.25)
gen if_avghhi_gt2500 = (avghhi_by_n>=0.25)

gen TXPXhas_advisor_avghhi_lt1000 = treatedXpost*(if_advisor=="Yes")*(avghhi_by_n<0.1)
label var TXPXhas_advisor_avghhi_lt1000 "Treated $\times$ Post $\times$ Has Advisor $\times$ HHI $\le$ 1000"

gen TXPXhas_advisor_avghhi_1000_2500 = treatedXpost*(if_advisor=="Yes")*(avghhi_by_n>=0.1&avghhi_by_n<0.25)
label var TXPXhas_advisor_avghhi_1000_2500 "Treated $\times$ Post $\times$ Has Advisor $\times$ HHI in [1000,2500)"

gen TXPXhas_advisor_avghhi_gt2500 = treatedXpost*(if_advisor=="Yes")*(avghhi_by_n>=0.25)
label var TXPXhas_advisor_avghhi_gt2500 "Treated $\times$ Post $\times$ Has Advisor $\times$ HHI $\ge$ 2500"

// Column 3: By whether employing an advisor, for levels of initial HHI
reghdfe gross_spread_inbp (i.post i.treated)##(i.if_avghhi_lt1000 i.if_avghhi_1000_2500 i.if_avghhi_gt2500) ///
TXPXhas_advisor_avghhi_lt1000 TXPXhas_advisor_avghhi_1000_2500 TXPXhas_advisor_avghhi_gt2500 TXPXno_advisor /// 
if year_to_merger>=-4 & year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
i.episode_start_year##i.treated_csa##i.calendar_year) ///
cluster(csacode calendar_year) noconstant

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(TXPXhas_advisor_avghhi_lt1000 TXPXhas_advisor_avghhi_1000_2500 TXPXhas_advisor_avghhi_gt2500 TXPXno_advisor) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer \(\times\) Cohort FE", "Yes","Clustering","CSA \& Year") ///
sortvar(TXPXhas_advisor ///
TXPXhas_advisor_hhi_dif_100_200 TXPXhas_advisor_hhi_dif_gt_200 ///
TXPXhas_advisor_avghhi_lt1000 TXPXhas_advisor_avghhi_1000_2500 TXPXhas_advisor_avghhi_gt2500 ///
TXPXno_advisor)


