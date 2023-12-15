
/*------------------------------------------*/
/* Table: Main results of spread around M&A */
/*------------------------------------------*/

local outfile =  "../Slides/tabs/DID_MA_GrossSpread_main.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1*/

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 1: Using implied HHI increase > 0.01
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/*--- Number: Effects on gross spread ---*/

local spread_effects_main = _b[treatedXpost]
local spread_effects_main : display %-9.1f `spread_effects_main'
file open myfile using "../Slides/nums/spread_effects_main.tex", write replace
file write myfile "`spread_effects_main'"
file close myfile

preserve
import delimited "../CleanData/MAEvent/GPF.csv", clear 
winsor2 amount, replace cuts(1 99)
gen amount_adjusted = amount*scaler
sum amount_adjusted, d

/*--- Number: Effects on gross spread as a fraction of sample average ---*/

sum gross_spread, d
local spread_effects_frac = _b[treatedXpost]/(r(mean)*10)*100
local spread_effects_frac : display %-9.1f `spread_effects_frac'
file open myfile using "../Slides/nums/spread_effects_frac.tex", write replace
file write myfile "`spread_effects_frac'"
file close myfile

/*--- Number: Median issue size ---*/

local median_size = r(p50)
local median_size : display %-9.1fc `median_size'
file open myfile using "../Slides/nums/median_size.tex", write replace
file write myfile "`median_size'"
file close myfile

/*--- Number: Effects on gross spread in dollars ---*/

local spread_effects_dollar = r(p50)*_b[treatedXpost]/10000*1000*1000
local spread_effects_dollar : display %-9.0fc `spread_effects_dollar'
file open myfile using "../Slides/nums/spread_effects_dollar.tex", write replace
file write myfile "`spread_effects_dollar'"
file close myfile

/*--- Number: Median issue size for a county ---*/

collapse (sum) amount_adjusted, by(csacode county calendar_year)
sum amount_adjusted, d
local median_size_county = r(p50)
local median_size_county : display %-9.1fc `median_size_county'
file open myfile using "../Slides/nums/median_size_county.tex", write replace
file write myfile "`median_size_county'"
file close myfile

/*--- Number: Effects on gross spread in dollars for a county ---*/

local spread_effects_dollar_county = r(p50)*_b[treatedXpost]/10000*1000*1000
local spread_effects_dollar_county : display %-9.0fc `spread_effects_dollar_county'
file open myfile using "../Slides/nums/spread_effects_dollar_county.tex", write replace
file write myfile "`spread_effects_dollar_county'"
file close myfile

restore

/* Column 2 */

import delimited "../CleanData/MAEvent/CBSA_episodes_impliedHHIbyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 2: Using implied HHI increase > 0.01
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 3 */

import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 3: Using market share of target and acquiror > 0.05
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 4 */

import delimited "../CleanData/MAEvent/CBSA_episodes_marketsharebyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 4: Using market share of target and acquiror > 0.05
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 5 */

import delimited "../CleanData/MAEvent/CSA_episodes_top5shareByN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 5: Using rise in top 5 share > 0.05
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 6 */

import delimited "../CleanData/MAEvent/CBSA_episodes_top5shareByN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 5: Using rise in top 5 share > 0.05
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")


