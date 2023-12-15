
/*------------------------------------------*/
/* Table: Main results of spread around M&A */
/*------------------------------------------*/

local outfile =  "../Slides/tabs/DID_MA_GrossSpread_IV.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

if "$MainThreshold" == "HHI" {
	import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear
}
else if "$MainThreshold" == "MarketShare" {
	import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear
}

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

replace hhi_by_n = hhi_by_n*10000

/* Column 1: OLS */

label var hhi_by_n "HHI"

// Column 1: Using implied HHI increase > 0.01
reghdfe gross_spread_inbp hhi_by_n, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label keep(hhi_by_n) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 2 */

import delimited "../CleanData/MAEvent/GPF.csv", clear 

gen gross_spread_inbp = gross_spread*10

encode issuer, gen(issuer_code)

label var hhi_by_n "HHI"

replace hhi_by_n = hhi_by_n*10000

// Column 2: OLS using whole sample
reghdfe gross_spread_inbp hhi_by_n, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(hhi_by_n) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 3 */

if "$MainThreshold" == "HHI" {
	import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear
}
else if "$MainThreshold" == "MarketShare" {
	import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear
}

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

egen issuer_codeXissuer_type = group(issuer_code issuer_type)

replace hhi_by_n = hhi_by_n*10000

// Column 3: First stage of IV
reghdfe hhi_by_n treated post treatedXpost ///
if gross_spread_inbp!=. ///
, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(csacode)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("HHI") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","CSA")

/* Column 4 */

local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes"

label var hhi_by_n "HHI"

// Column 4: IV regression using M&A
ivreghdfe gross_spread_inbp treated post (hhi_by_n=treatedXpost), ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(issuer_codeXissuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(hhi_by_n) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Elasticity of spread to HHI */

local elast_spread_hhi = _b[hhi_by_n]
local elast_spread_hhi : display %-9.2f `elast_spread_hhi'
file open myfile using "../Slides/nums/elast_spread_hhi.tex", write replace
file write myfile "`elast_spread_hhi'"
file close myfile

/* Predicted change in spread if going from 5 to 4 equal size underwriters */

local delta_spread_5_to_4 = _b[hhi_by_n]*500
local delta_spread_5_to_4 : display %-9.1f `delta_spread_5_to_4'
file open myfile using "../Slides/nums/delta_spread_5_to_4.tex", write replace
file write myfile "`delta_spread_5_to_4'"
file close myfile

