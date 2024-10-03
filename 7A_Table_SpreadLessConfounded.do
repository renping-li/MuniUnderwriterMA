
/*---------------------------------------------------------------------------------------------------------------------------*/
/* Table: Sample based on news, sample based on CSA as a fraction of total business, and sample not confounded by CB mergers */
/*---------------------------------------------------------------------------------------------------------------------------*/

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

local outfile =  "../Draft/tabs/DID_MA_GrossSpread_lessconfounded.tex"

tempfile table
tempname memhold
postfile `memhold' str120 varname str30 (coef1 coef2 coef3) using `table', replace
post `memhold' (" ") ("(1)") ("(2)") ("(3)")
post `memhold' (" ") ("Underwriting") ("Underwriting") ("Underwriting")
post `memhold' (" ") ("Spread (bps.)") ("Spread (bps.)") ("Spread (bps.)")
post `memhold' (" ") ("[-4, +4]") ("[-4, +7]") ("[-4, +10]")

// Panel A: Exclude those driven by endogenous factors

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel A: M\&As are driven by factors likely unrelated to local economic dynamics according to news articles") (" ") (" ") (" ")

cap prog drop regression
prog regression

	args begin_year end_year

	reghdfe gross_spread_inbp treated post treatedXpost ///
	if (year_to_merger>=`begin_year'&year_to_merger<=`end_year') & ///
	reasonma_endo_possible=="False", ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

end

regression -4 4

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

regression -4 7

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

regression -4 10

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
post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")
post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'")
post `memhold' ("Adjusted R-squared") ("`r2_coef1'") ("`r2_coef2'") ("`r2_coef3'")

// Panel B: Further exclude M&As driven by financial distress

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel B: Further exclude M\&As driven by financial distress") (" ") (" ") (" ")

cap prog drop regression
prog regression

	args begin_year end_year

	reghdfe gross_spread_inbp treated post treatedXpost ///
	if (year_to_merger>=`begin_year'&year_to_merger<=`end_year') & ///
	reasonma_endo_possible=="False"&reasonma_fin_stress=="False", ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

end

regression -4 4

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

regression -4 7

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

regression -4 10

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
post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")
post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'")
post `memhold' ("Adjusted R-squared") ("`r2_coef1'") ("`r2_coef2'") ("`r2_coef3'")

// Panel C: CSA makes up less than 5%

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel C: CSA makes up $\le$ 5\% of the total businesses of the merging underwriters") (" ") (" ") (" ")

cap prog drop regression
prog regression

	args begin_year end_year

	reghdfe gross_spread_inbp treated post treatedXpost ///
	if (year_to_merger>=`begin_year'&year_to_merger<=`end_year') & ///
	max_acquiror_weight<0.05&max_target_weight<0.05, ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

end

regression -4 4

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

regression -4 7

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

regression -4 10

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
post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")
post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'")
post `memhold' ("Adjusted R-squared") ("`r2_coef1'") ("`r2_coef2'") ("`r2_coef3'")

// Panel D: CSA and neighbour make up less than 5%

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel D: Affected and neighbouring CSAs make up $\le$ 5\% of the total businesses of the merging underwriters") (" ") (" ") (" ")

cap prog drop regression
prog regression

	args begin_year end_year

	reghdfe gross_spread_inbp treated post treatedXpost ///
	if (year_to_merger>=`begin_year'&year_to_merger<=`end_year') & ///
	max_acquiror_weight<0.05&max_target_weight<0.05 ///
	&max_acquiror_weight_in_neighbour<0.05 &max_target_weight_in_neighbour<0.05, ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

end

regression -4 4

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

regression -4 7

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

regression -4 10

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
post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")
post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'")
post `memhold' ("Adjusted R-squared") ("`r2_coef1'") ("`r2_coef2'") ("`r2_coef3'")

// Panel E: Exclude episodes confounded by CB M&As, based on CB HHI of 100

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIByN_excludeCBConfound100.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel E: Exclude cases with concurrent CB bank M\&As $\ge$ 100") (" ") (" ") (" ")

cap prog drop regression
prog regression

	args begin_year end_year

	reghdfe gross_spread_inbp treated post treatedXpost ///
	if (year_to_merger>=`begin_year'&year_to_merger<=`end_year'), ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

end

regression -4 4

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

regression -4 7

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

regression -4 10

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
post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")
post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'")
post `memhold' ("Adjusted R-squared") ("`r2_coef1'") ("`r2_coef2'") ("`r2_coef3'")

// Panel F: Exclude episodes confounded by CB M&As, based on CB HHI of 50

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIByN_excludeCBConfound50.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Panel F: Exclude cases with concurrent CB bank M\&As $\ge$ 50") (" ") (" ") (" ")

cap prog drop regression
prog regression

	args begin_year end_year

	reghdfe gross_spread_inbp treated post treatedXpost ///
	if (year_to_merger>=`begin_year'&year_to_merger<=`end_year'), ///
	absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

end

regression -4 4

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

regression -4 7

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

regression -4 10

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
post `memhold' ("\;") ("`t_coef1'") ("`t_coef2'") ("`t_coef3'")
post `memhold' ("Observations") ("`obs_coef1'") ("`obs_coef2'") ("`obs_coef3'")
post `memhold' ("Adjusted R-squared") ("`r2_coef1'") ("`r2_coef2'") ("`r2_coef3'")

post `memhold' (" ") (" ") (" ") (" ")
post `memhold' ("Issuer \(\times\) Cohort FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Year FE") ("Yes") ("Yes") ("Yes")
post `memhold' ("Clustering") ("CSA \& Year") ("CSA \& Year") ("CSA \& Year")

postclose `memhold'
use `table', clear
texsave using "`outfile'", replace dataonly nonames italics("Panel") nofix hlines(4)




/*--------------------------------------------------------------*/
/* Table for slides: Exclude those driven by endogenous factors */
/*--------------------------------------------------------------*/

local outfile =  "../Draft/tabs/DID_MA_GrossSpread_MAReason.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

/* Column 1 */

// Column 1: Require M&A is for reasons unlikely to be related to local economic conditions
reghdfe gross_spread_inbp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=7) & reasonma_endo_possible=="False", ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA $\times$ Year")

/* Column 2 */

// Column 2: Require M&A is for reasons unlikely to be related to local economic conditions, and also not due to financial distress
reghdfe gross_spread_inbp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=7) & reasonma_endo_possible=="False"&reasonma_fin_stress=="False", ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA $\times$ Year")

/* Figure: Using cases where affected CSA makes up less than 10% of underwriter's business */

set scheme s1color

gen treatedXpostm2 = treated==1&year_to_merger==-2
gen treatedXpostm3 = treated==1&year_to_merger==-3
gen treatedXpostm4 = treated==1&year_to_merger==-4
gen treatedXpost0 = treated==1&year_to_merger==0
gen treatedXpost1 = treated==1&year_to_merger==1
gen treatedXpost2 = treated==1&year_to_merger==2
gen treatedXpost3 = treated==1&year_to_merger==3
gen treatedXpost4 = treated==1&year_to_merger==4

preserve

reghdfe gross_spread treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if reasonma_endo_possible=="False" & (year_to_merger>=-4&year_to_merger<=4), ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

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

replace coef = 10 * coef
replace upper = 10 * upper
replace lower = 10 * lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on Underwriting Spread", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in bps.)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GrossSpread_Around_MA_MAReason.eps", replace

restore




/*-----------------------------------------------------------------------------------------------*/
/* Table: Exclude cases where merging underwriters account for a small share of total businesses */
/*-----------------------------------------------------------------------------------------------*/

local outfile =  "../Draft/tabs/DID_MA_GrossSpread_LowWeight.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

/* Column 1 */

// Column 1: Require weight less than 10% for both acquiror and target firms
reghdfe gross_spread_inbp treated post treatedXpost ///
if max_acquiror_weight<0.1&max_target_weight<0.1 & (year_to_merger>=-4&year_to_merger<=7), ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA $\times$ Year")

/* Column 2 */

// Column 2: Require weight less than 5% for both acquiror and target firms
reghdfe gross_spread_inbp treated post treatedXpost ///
if max_acquiror_weight<0.05&max_target_weight<0.05 & (year_to_merger>=-4&year_to_merger<=7), ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA $\times$ Year")

/*--- Number: Effects on gross spread ---*/

reghdfe gross_spread_inbp treated post treatedXpost ///
if max_acquiror_weight<0.05&max_target_weight<0.05 & (year_to_merger>=-4&year_to_merger<=4), ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

local spread_effects_bothweight_lt5 = _b[treatedXpost]
local spread_effects_bothweight_lt5 : display %-9.1f `spread_effects_bothweight_lt5'
file open myfile using "../Draft/nums/spread_effects_bothweight_lt5.tex", write replace
file write myfile "`spread_effects_bothweight_lt5'"
file close myfile

local t_spread_bothweight_lt5 = _b[treatedXpost]/_se[treatedXpost]
local t_spread_bothweight_lt5 : display %-9.1f `t_spread_bothweight_lt5'
file open myfile using "../Draft/nums/t_spread_effects_bothweight_lt5.tex", write replace
file write myfile "`t_spread_bothweight_lt5'"
file close myfile



/* Figure: Using cases where affected CSA makes up less than 10% of underwriter's business */

gen treatedXpostm2 = treated==1&year_to_merger==-2
gen treatedXpostm3 = treated==1&year_to_merger==-3
gen treatedXpostm4 = treated==1&year_to_merger==-4
gen treatedXpost0 = treated==1&year_to_merger==0
gen treatedXpost1 = treated==1&year_to_merger==1
gen treatedXpost2 = treated==1&year_to_merger==2
gen treatedXpost3 = treated==1&year_to_merger==3
gen treatedXpost4 = treated==1&year_to_merger==4

preserve

reghdfe gross_spread treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if max_acquiror_weight<0.1&max_target_weight<0.1 & (year_to_merger>=-4&year_to_merger<=4), ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

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

replace coef = 10 * coef
replace upper = 10 * upper
replace lower = 10 * lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on Underwriting Spread", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in bps.)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GrossSpread_Around_MA_LowWeight10.eps", replace

restore





/* Figure: Using cases where affected CSA makes up less than 5% of underwriter's business */

preserve

reghdfe gross_spread treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if max_acquiror_weight<0.05&max_target_weight<0.05 & (year_to_merger>=-4&year_to_merger<=4), ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

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

replace coef = 10 * coef
replace upper = 10 * upper
replace lower = 10 * lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on Underwriting Spread", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in bps.)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GrossSpread_Around_MA_LowWeight5.eps", replace

restore







/* Figure: Using cases where affected CSA makes up less than 3% of underwriter's business */

preserve

reghdfe gross_spread treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 ///
treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if max_acquiror_weight<0.03&max_target_weight<0.03 & (year_to_merger>=-4&year_to_merger<=4), ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

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

replace coef = 10 * coef
replace upper = 10 * upper
replace lower = 10 * lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on Underwriting Spread", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in bps.)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/GrossSpread_Around_MA_LowWeight3.eps", replace

restore
