
/*------------------------------------*/
/* Table: Dividing the market further */
/*------------------------------------*/

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

local outfile =  "../Draft/tabs/DID_MA_GrossSpread_divide.tex"

tempfile table
tempname memhold
postfile `memhold' str100 varname str30 (coef1 coef2 coef3 coef4 coef5 coef6) using `table', replace
post `memhold' (" ") ("(1)") ("(2)") ("(3)") ("(4)") ("(5)") ("(6)")
post `memhold' (" ") ("Underwriting") ("Underwriting") ("Underwriting") ("Underwriting") ("Underwriting") ("Underwriting")
post `memhold' (" ") ("Spread (bps.)") ("Spread (bps.)") ("Spread (bps.)") ("Spread (bps.)") ("Spread (bps.)") ("Spread (bps.)")
post `memhold' (" ") ("[-4, +4]") ("[-4, +7]") ("[-4, +10]") ("[-4, +4]") ("[-4, +7]") ("[-4, +10]")

cap prog drop regression_us
prog regression_us

	args begin_year end_year
	
	reghdfe gross_spread_inbp ///
	(treated)##(if_us_expertise) post ///
	TXPXif_us_expertise TXPXif_not_us_expertise ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', /// 
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.bracket_code calendar_year) cluster(csacode calendar_year)

end

cap prog drop regression_csa
prog regression_csa

	args begin_year end_year
	
	reghdfe gross_spread_inbp ///
	(treated)##(if_csa_expertise) post ///
	TXPXif_csa_expertise TXPXif_not_csa_expertise ///
	if year_to_merger>=`begin_year'&year_to_merger<=`end_year', /// 
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.bracket_code calendar_year) cluster(csacode calendar_year)

end

/*-----------------------------*/
/* Panel A: By amount brackets */
/*-----------------------------*/

post `memhold' (" ") (" ") (" ") (" ") (" ") (" ") (" ")
post `memhold' ("Panel A: By amount brackets") (" ") (" ") (" ") (" ") (" ") (" ")

gen if_us_expertise = if_us_expert_amount_bracket_5=="True"
gen TXPXif_us_expertise = treatedXpost*if_us_expertise
gen TXPXif_not_us_expertise = treatedXpost*(1-if_us_expertise)

gen if_csa_expertise = if_csa_expert_amount_bracket_5=="True"
gen TXPXif_csa_expertise = treatedXpost*if_csa_expertise
gen TXPXif_not_csa_expertise = treatedXpost*(1-if_csa_expertise)

encode amount_bracket, gen(bracket_code)

// Row 1: Merging underwriters are experts

local varname = "TXPXif_us_expertise"

regression_us -4 4

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

regression_us -4 7

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

regression_us -4 10

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

local varname = "TXPXif_csa_expertise"

regression_csa -4 4

local b_coef4 = _b[`varname']
local t_coef4 = _b[`varname']/_se[`varname']
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

regression_csa -4 7

local b_coef5 = _b[`varname']
local t_coef5 = _b[`varname']/_se[`varname']
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

regression_csa -4 10

local b_coef6 = _b[`varname']
local t_coef6 = _b[`varname']/_se[`varname']
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

post `memhold' ("Treated $\times$ Post $\times$ Merging Underwriters are Experts") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'") ("`b_coef4'") ("`b_coef5'") ("`b_coef6'")
post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'") ("`t_coef4'") ("`t_coef5'") ("`t_coef6'")

// Row 2: Merging underwriters are not experts

local varname = "TXPXif_not_us_expertise"

regression_us -4 4

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

regression_us -4 7

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

regression_us -4 10

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

local varname = "TXPXif_not_csa_expertise"

regression_csa -4 4

local b_coef4 = _b[`varname']
local t_coef4 = _b[`varname']/_se[`varname']
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

regression_csa -4 7

local b_coef5 = _b[`varname']
local t_coef5 = _b[`varname']/_se[`varname']
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

regression_csa -4 10

local b_coef6 = _b[`varname']
local t_coef6 = _b[`varname']/_se[`varname']
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

post `memhold' ("Treated $\times$ Post $\times$ Merging Underwriters not Experts") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'") ("`b_coef4'") ("`b_coef5'") ("`b_coef6'")
post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'") ("`t_coef4'") ("`t_coef5'") ("`t_coef6'")

cap drop if_us_expertise TXPXif_us_expertise TXPXif_not_us_expertise
cap drop if_csa_expertise TXPXif_csa_expertise TXPXif_not_csa_expertise
cap drop bracket_code

/*-------------------------------*/
/* Panel B: By maturity brackets */
/*-------------------------------*/

post `memhold' (" ") (" ") (" ") (" ") (" ") (" ") (" ")
post `memhold' ("Panel B: By maturity brackets") (" ") (" ") (" ") (" ") (" ") (" ")

gen if_us_expertise = if_us_expert_mat_bracket_5=="True"
gen TXPXif_us_expertise = treatedXpost*if_us_expertise
gen TXPXif_not_us_expertise = treatedXpost*(1-if_us_expertise)

gen if_csa_expertise = if_csa_expert_mat_bracket_5=="True"
gen TXPXif_csa_expertise = treatedXpost*if_csa_expertise
gen TXPXif_not_csa_expertise = treatedXpost*(1-if_csa_expertise)

encode mat_bracket, gen(bracket_code)

// Row 1: Merging underwriters are experts

local varname = "TXPXif_us_expertise"

regression_us -4 4

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

regression_us -4 7

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

regression_us -4 10

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

local varname = "TXPXif_csa_expertise"

regression_csa -4 4

local b_coef4 = _b[`varname']
local t_coef4 = _b[`varname']/_se[`varname']
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

regression_csa -4 7

local b_coef5 = _b[`varname']
local t_coef5 = _b[`varname']/_se[`varname']
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

regression_csa -4 10

local b_coef6 = _b[`varname']
local t_coef6 = _b[`varname']/_se[`varname']
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

post `memhold' ("Treated $\times$ Post $\times$ Merging Underwriters are Experts") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'") ("`b_coef4'") ("`b_coef5'") ("`b_coef6'")
post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'") ("`t_coef4'") ("`t_coef5'") ("`t_coef6'")

// Row 2: Merging underwriters are not experts

local varname = "TXPXif_not_us_expertise"

regression_us -4 4

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

regression_us -4 7

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

regression_us -4 10

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

local varname = "TXPXif_not_csa_expertise"

regression_csa -4 4

local b_coef4 = _b[`varname']
local t_coef4 = _b[`varname']/_se[`varname']
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

regression_csa -4 7

local b_coef5 = _b[`varname']
local t_coef5 = _b[`varname']/_se[`varname']
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

regression_csa -4 10

local b_coef6 = _b[`varname']
local t_coef6 = _b[`varname']/_se[`varname']
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

post `memhold' ("Treated $\times$ Post $\times$ Merging Underwriters not Experts") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'") ("`b_coef4'") ("`b_coef5'") ("`b_coef6'")
post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'") ("`t_coef4'") ("`t_coef5'") ("`t_coef6'")

cap drop if_us_expertise TXPXif_us_expertise TXPXif_not_us_expertise
cap drop if_csa_expertise TXPXif_csa_expertise TXPXif_not_csa_expertise
cap drop bracket_code

/*--------------------------------------*/
/* Panel C: By the main use of proceeds */
/*--------------------------------------*/

post `memhold' (" ") (" ") (" ") (" ") (" ") (" ") (" ") 
post `memhold' ("Panel C: By the main use of proceeds") (" ") (" ") (" ") (" ") (" ") (" ") 

gen if_us_expertise = if_us_expert_use_short_5=="True"
gen TXPXif_us_expertise = treatedXpost*if_us_expertise
gen TXPXif_not_us_expertise = treatedXpost*(1-if_us_expertise)

gen if_csa_expertise = if_csa_expert_use_short_5=="True"
gen TXPXif_csa_expertise = treatedXpost*if_csa_expertise
gen TXPXif_not_csa_expertise = treatedXpost*(1-if_csa_expertise)

encode use_short, gen(bracket_code)

// Row 1: Merging underwriters are experts

local varname = "TXPXif_us_expertise"

regression_us -4 4

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

regression_us -4 7

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

regression_us -4 10

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

local varname = "TXPXif_csa_expertise"

regression_csa -4 4

local b_coef4 = _b[`varname']
local t_coef4 = _b[`varname']/_se[`varname']
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

regression_csa -4 7

local b_coef5 = _b[`varname']
local t_coef5 = _b[`varname']/_se[`varname']
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

regression_csa -4 10

local b_coef6 = _b[`varname']
local t_coef6 = _b[`varname']/_se[`varname']
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

post `memhold' ("Treated $\times$ Post $\times$ Merging Underwriters are Experts") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'") ("`b_coef4'") ("`b_coef5'") ("`b_coef6'")
post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'") ("`t_coef4'") ("`t_coef5'") ("`t_coef6'")

// Row 2: Merging underwriters are not experts

local varname = "TXPXif_not_us_expertise"

regression_us -4 4

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

regression_us -4 7

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

regression_us -4 10

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

local varname = "TXPXif_not_csa_expertise"

regression_csa -4 4

local b_coef4 = _b[`varname']
local t_coef4 = _b[`varname']/_se[`varname']
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

regression_csa -4 7

local b_coef5 = _b[`varname']
local t_coef5 = _b[`varname']/_se[`varname']
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

regression_csa -4 10

local b_coef6 = _b[`varname']
local t_coef6 = _b[`varname']/_se[`varname']
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

post `memhold' ("Treated $\times$ Post $\times$ Merging Underwriters not Experts") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'") ("`b_coef4'") ("`b_coef5'") ("`b_coef6'")
post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'") ("`t_coef4'") ("`t_coef5'") ("`t_coef6'")

cap drop if_us_expertise TXPXif_us_expertise TXPXif_not_us_expertise
cap drop if_csa_expertise TXPXif_csa_expertise TXPXif_not_csa_expertise
cap drop bracket_code

/*---------------------------------*/
/* Panel D: By the method of sales */
/*---------------------------------*/

post `memhold' (" ") (" ") (" ") (" ") (" ") (" ") (" ") 
post `memhold' ("Panel D: By the method of sales") (" ") (" ") (" ") (" ") (" ") (" ") 

gen if_us_expertise = if_us_expert_bid_5=="True"
gen TXPXif_us_expertise = treatedXpost*if_us_expertise
gen TXPXif_not_us_expertise = treatedXpost*(1-if_us_expertise)

gen if_csa_expertise = if_csa_expert_bid_5=="True"
gen TXPXif_csa_expertise = treatedXpost*if_csa_expertise
gen TXPXif_not_csa_expertise = treatedXpost*(1-if_csa_expertise)

encode bid, gen(bracket_code)

// Row 1: Merging underwriters are experts

local varname = "TXPXif_us_expertise"

regression_us -4 4

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

regression_us -4 7

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

regression_us -4 10

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

local varname = "TXPXif_csa_expertise"

regression_csa -4 4

local b_coef4 = _b[`varname']
local t_coef4 = _b[`varname']/_se[`varname']
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

regression_csa -4 7

local b_coef5 = _b[`varname']
local t_coef5 = _b[`varname']/_se[`varname']
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

regression_csa -4 10

local b_coef6 = _b[`varname']
local t_coef6 = _b[`varname']/_se[`varname']
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

post `memhold' ("Treated $\times$ Post $\times$ Merging Underwriters are Experts") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'") ("`b_coef4'") ("`b_coef5'") ("`b_coef6'")
post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'") ("`t_coef4'") ("`t_coef5'") ("`t_coef6'")

// Row 2: Merging underwriters are not experts

local varname = "TXPXif_not_us_expertise"

regression_us -4 4

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

regression_us -4 7

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

regression_us -4 10

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

local varname = "TXPXif_not_csa_expertise"

regression_csa -4 4

local b_coef4 = _b[`varname']
local t_coef4 = _b[`varname']/_se[`varname']
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

regression_csa -4 7

local b_coef5 = _b[`varname']
local t_coef5 = _b[`varname']/_se[`varname']
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

regression_csa -4 10

local b_coef6 = _b[`varname']
local t_coef6 = _b[`varname']/_se[`varname']
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

post `memhold' ("Treated $\times$ Post $\times$ Merging Underwriters not Experts") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'") ("`b_coef4'") ("`b_coef5'") ("`b_coef6'")
post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'") ("`t_coef4'") ("`t_coef5'") ("`t_coef6'")

cap drop if_us_expertise TXPXif_us_expertise TXPXif_not_us_expertise
cap drop if_csa_expertise TXPXif_csa_expertise TXPXif_not_csa_expertise
cap drop bracket_code

/*-------------------------------------------------------*/
/* Panel E: By whether the bond issue has credit ratings */
/*-------------------------------------------------------*/

post `memhold' (" ") (" ") (" ") (" ") (" ") (" ") (" ") 
post `memhold' ("Panel E: By whether the bond issue has credit ratings") (" ") (" ") (" ") (" ") (" ") (" ") 

gen if_us_expertise = if_us_expert_has_ratings_5=="True"
gen TXPXif_us_expertise = treatedXpost*if_us_expertise
gen TXPXif_not_us_expertise = treatedXpost*(1-if_us_expertise)

gen if_csa_expertise = if_csa_expert_has_ratings_5=="True"
gen TXPXif_csa_expertise = treatedXpost*if_csa_expertise
gen TXPXif_not_csa_expertise = treatedXpost*(1-if_csa_expertise)

encode has_ratings, gen(bracket_code)

// Row 1: Merging underwriters are experts

local varname = "TXPXif_us_expertise"

regression_us -4 4

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

regression_us -4 7

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

regression_us -4 10

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

local varname = "TXPXif_csa_expertise"

regression_csa -4 4

local b_coef4 = _b[`varname']
local t_coef4 = _b[`varname']/_se[`varname']
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

regression_csa -4 7

local b_coef5 = _b[`varname']
local t_coef5 = _b[`varname']/_se[`varname']
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

regression_csa -4 10

local b_coef6 = _b[`varname']
local t_coef6 = _b[`varname']/_se[`varname']
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

post `memhold' ("Treated $\times$ Post $\times$ Merging Underwriters are Experts") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'") ("`b_coef4'") ("`b_coef5'") ("`b_coef6'")
post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'") ("`t_coef4'") ("`t_coef5'") ("`t_coef6'")

// Row 2: Merging underwriters are not experts

local varname = "TXPXif_not_us_expertise"

regression_us -4 4

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

regression_us -4 7

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

regression_us -4 10

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

local varname = "TXPXif_not_csa_expertise"

regression_csa -4 4

local b_coef4 = _b[`varname']
local t_coef4 = _b[`varname']/_se[`varname']
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

regression_csa -4 7

local b_coef5 = _b[`varname']
local t_coef5 = _b[`varname']/_se[`varname']
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

regression_csa -4 10

local b_coef6 = _b[`varname']
local t_coef6 = _b[`varname']/_se[`varname']
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

post `memhold' ("Treated $\times$ Post $\times$ Merging Underwriters not Experts") ("`b_coef1'") ("`b_coef2'") ("`b_coef3'") ("`b_coef4'") ("`b_coef5'") ("`b_coef6'")
post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'") ("`t_coef4'") ("`t_coef5'") ("`t_coef6'")

cap drop if_us_expertise TXPXif_us_expertise TXPXif_not_us_expertise
cap drop if_csa_expertise TXPXif_csa_expertise TXPXif_not_csa_expertise
cap drop bracket_code

/*--------------*/
/* Export table */
/*--------------*/

post `memhold' (" ") (" ") (" ") (" ") (" ") (" ") (" ") 
post `memhold' ("Issuer \(\times\) Cohort FE") ("Yes") ("Yes") ("Yes")  ("Yes") ("Yes") ("Yes")
post `memhold' ("Year FE") ("Yes") ("Yes") ("Yes")  ("Yes") ("Yes") ("Yes")
post `memhold' ("Clustering") ("CSA \& Year") ("CSA \& Year") ("CSA \& Year")  ("CSA \& Year") ("CSA \& Year") ("CSA \& Year")
post `memhold' ("Ranking of Underwriters") ("US") ("US") ("US")  ("CSA") ("CSA") ("CSA")

postclose `memhold'
use `table', clear
texsave using "`outfile'", replace dataonly nonames italics("Panel") nofix hlines(4)
