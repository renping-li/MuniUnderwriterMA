
/*------------------------------------*/
/* Table: Total Issuing cost around M&A */
/*------------------------------------*/

local outfile =  "../Slides/tabs/DID_MA_NetCost_main.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

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
gen net_cost_inbp = gross_spread_inbp+if_advisor_coded*advisorratio_hat+has_rating*crratio_hat+insured_ratio*insureratio_hat

// Column 1: Using implied HHI increase > 0.01
reghdfe net_cost_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Total Issuing","Cost (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/*--- Number: Effects on total costs ---*/

local totalcost_effects_main = _b[treatedXpost]
local totalcost_effects_main : display %-9.1f `totalcost_effects_main'
file open myfile using "../Slides/nums/totalcost_effects_main.tex", write replace
file write myfile "`totalcost_effects_main'"
file close myfile


/* Column 2 */

import delimited "../CleanData/MAEvent/CBSA_episodes_impliedHHIbyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

gen if_advisor_coded = if_advisor=="Yes"
gen has_rating = (has_fitch=="True")|(has_moodys=="True")
replace insured_amount = 0 if insured_amount==.
gen insured_ratio = insured_amount/amount
gen net_cost_inbp = gross_spread_inbp+if_advisor_coded*advisorratio_hat+has_rating*crratio_hat+insured_ratio*insureratio_hat

// Column 2: Using implied HHI increase > 0.01
reghdfe net_cost_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Total Issuing","Cost (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 3 */

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
gen net_cost_inbp = gross_spread_inbp+if_advisor_coded*advisorratio_hat+has_rating*crratio_hat+insured_ratio*insureratio_hat

// Column 3: Using market share of target and acquiror > 0.05
reghdfe net_cost_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Total Issuing","Cost (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 4 */

import delimited "../CleanData/MAEvent/CBSA_episodes_marketsharebyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

gen if_advisor_coded = if_advisor=="Yes"
gen has_rating = (has_fitch=="True")|(has_moodys=="True")
replace insured_amount = 0 if insured_amount==.
gen insured_ratio = insured_amount/amount
gen net_cost_inbp = gross_spread_inbp+if_advisor_coded*advisorratio_hat+has_rating*crratio_hat+insured_ratio*insureratio_hat

// Column 4: Using market share of target and acquiror > 0.05
reghdfe net_cost_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Total Issuing","Cost (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

