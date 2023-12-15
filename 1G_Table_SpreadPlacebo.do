
/*----------------------*/
/* Table: Placebo tests */
/*----------------------*/

/* Table 1: Cross-market M&A */

local outfile =  "../Slides/tabs/DID_MA_GrossSpread_Placebo.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1*/

import delimited "../CleanData/MAEvent/CSA_AcrossMarket_episodes_impliedHHIByN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 1: Using areas affected by across-market M&A
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 2*/

import delimited "../CleanData/MAEvent/CSA_AcrossMarket_SamePop_episodes_impliedHHIByN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 2: Using areas affected by across-market M&A, looking for areas with similar population size
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 3*/

import delimited "../CleanData/MAEvent/CSA_AcrossMarket_AnyShare_episodes_impliedHHIByN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 3: Using areas affected by across-market M&A, with no restriction on market share of M&A bank
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 4*/

import delimited "../CleanData/MAEvent/CSA_AcrossMarket_SamePop_AnyShare_episodes_impliedHHIByN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 4: Using areas affected by across-market M&A, looking for areas with similar population size, with no restriction on market share of M&A bank
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")






/* Table 2: CB M&A */

local outfile =  "../Slides/tabs/DID_MA_CB_Placebo.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1 */

import delimited "../CleanData/MAEvent/CB_CSA_episodes_DeltaHHI100.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 1: Using CB M&A with HHI > 100 and market being CSA
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 2 */

import delimited "../CleanData/MAEvent/CB_CBSA_episodes_DeltaHHI100.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 2: Using CB M&A with HHI > 100 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 3 */

import delimited "../CleanData/MAEvent/CB_CSA_episodes_DeltaHHI50.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 3: Using CB M&A with HHI > 50 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")


/* Column 4 */

import delimited "../CleanData/MAEvent/CB_CBSA_episodes_DeltaHHI50.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 4: Using CB M&A with HHI > 50 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 5 */

import delimited "../CleanData/MAEvent/CB_CSA_episodes_DeltaHHI20.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 5: Using CB M&A with HHI > 20 and market being CSA
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 6 */

import delimited "../CleanData/MAEvent/CB_CBSA_episodes_DeltaHHI20.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 6: Using CB M&A with HHI > 20 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")





/* Table 3: Withdrawn M&A */

local outfile =  "../Slides/tabs/DID_MA_Withdrawn_Placebo.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1 */

import delimited "../CleanData/MAEvent/CSA_Withdrawn_DeltaHHI100.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 1: Using withdrawn M&A with HHI > 100 and market being CSA
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 2 */

import delimited "../CleanData/MAEvent/CBSA_Withdrawn_DeltaHHI100.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 2: Using withdrawn M&A with HHI > 100 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 3 */

import delimited "../CleanData/MAEvent/CSA_Withdrawn_DeltaHHI50.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 3: Using withdrawn M&A with HHI > 50 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")


/* Column 4 */

import delimited "../CleanData/MAEvent/CBSA_Withdrawn_DeltaHHI50.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 4: Using withdrawn M&A with HHI > 50 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 5 */

import delimited "../CleanData/MAEvent/CSA_Withdrawn_DeltaHHI20.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 5: Using withdrawn M&A with HHI > 20 and market being CSA
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 6 */

import delimited "../CleanData/MAEvent/CBSA_Withdrawn_DeltaHHI20.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 6: Using withdrawn M&A with HHI > 20 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")


