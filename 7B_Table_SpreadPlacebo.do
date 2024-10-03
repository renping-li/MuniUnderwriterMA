
/*----------------------*/
/* Table: Placebo tests */
/*----------------------*/

/* Table 1: Cross-market M&A */

local outfile =  "../Draft/tabs/DID_MA_GrossSpread_Cross.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1*/

import delimited "../CleanData/MAEvent/CSA_AcrossMarket_episodes_impliedHHIByN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 1: Using areas affected by across-market M&A
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","If Similar Population","No")

/* Column 2*/

import delimited "../CleanData/MAEvent/CSA_AcrossMarket_SamePop_episodes_impliedHHIByN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 2: Using areas affected by across-market M&A, looking for areas with similar population size
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","If Similar Population","Yes")

/* Column 3*/

import delimited "../CleanData/MAEvent/CSA_AcrossMarket_AnyShare_episodes_impliedHHIByN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 3: Using areas affected by across-market M&A, with no restriction on market share of M&A bank
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","If Similar Population","No")

/* Column 4*/

import delimited "../CleanData/MAEvent/CSA_AcrossMarket_SamePop_AnyShare_episodes_impliedHHIByN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 4: Using areas affected by across-market M&A, looking for areas with similar population size, with no restriction on market share of M&A bank
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","If Similar Population","Yes")






/* Table 2: CB M&A */

local outfile =  "../Draft/tabs/DID_MA_CB_Placebo.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1 */

import delimited "../CleanData/MAEvent/CB_CSA_episodes_DeltaHHI100.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 1: Using CB M&A with HHI > 100 and market being CSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","Market Definition","CSA")

/* Column 2 */

import delimited "../CleanData/MAEvent/CB_CBSA_episodes_DeltaHHI100.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 2: Using CB M&A with HHI > 100 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_cbsa calendar_year) cluster(cbsacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CBSA \& Year","Market Definition","CBSA")

/* Column 3 */

import delimited "../CleanData/MAEvent/CB_CSA_episodes_DeltaHHI50.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 3: Using CB M&A with HHI > 50 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","Market Definition","CSA")


/* Column 4 */

import delimited "../CleanData/MAEvent/CB_CBSA_episodes_DeltaHHI50.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 4: Using CB M&A with HHI > 50 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_cbsa calendar_year) cluster(cbsacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CBSA \& Year","Market Definition","CBSA")

/* Column 5 */

import delimited "../CleanData/MAEvent/CB_CSA_episodes_DeltaHHI30.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 5: Using CB M&A with HHI > 30 and market being CSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","Market Definition","CSA")

/* Column 6 */

import delimited "../CleanData/MAEvent/CB_CBSA_episodes_DeltaHHI30.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 6: Using CB M&A with HHI > 30 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_cbsa calendar_year) cluster(cbsacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CBSA \& Year","Market Definition","CBSA")




/* Draft version of Table 2: CB M&A */

local outfile =  "../Draft/tabs/Slides_DID_MA_CB_Placebo.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1 */

import delimited "../CleanData/MAEvent/CB_CSA_episodes_DeltaHHI100.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 1: Using CB M&A with HHI > 100 and market being CSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 2 */

import delimited "../CleanData/MAEvent/CB_CSA_episodes_DeltaHHI50.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 2: Using CB M&A with HHI > 50 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 3 */

import delimited "../CleanData/MAEvent/CB_CSA_episodes_DeltaHHI30.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 2: Using CB M&A with HHI > 30 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")





/* Table 3: Withdrawn M&A */

local outfile =  "../Draft/tabs/DID_MA_Withdrawn_Placebo.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1 */

import delimited "../CleanData/MAEvent/CSA_Withdrawn_DeltaHHI50.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 1: Using withdrawn M&A with HHI > 50 and market being CSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","Market Definition","CSA")

/* Column 2 */

import delimited "../CleanData/MAEvent/CBSA_Withdrawn_DeltaHHI50.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 2: Using withdrawn M&A with HHI > 50 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_cbsa calendar_year) cluster(cbsacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CBSA \& Year","Market Definition","CBSA")

/* Column 3 */

import delimited "../CleanData/MAEvent/CSA_Withdrawn_DeltaHHI30.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 3: Using withdrawn M&A with HHI > 30 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","Market Definition","CSA")


/* Column 4 */

import delimited "../CleanData/MAEvent/CBSA_Withdrawn_DeltaHHI30.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 4: Using withdrawn M&A with HHI > 30 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_cbsa calendar_year) cluster(cbsacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CBSA \& Year","Market Definition","CBSA")

/* Column 5 */

import delimited "../CleanData/MAEvent/CSA_Withdrawn_DeltaHHI10.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 5: Using withdrawn M&A with HHI > 10 and market being CSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","Market Definition","CSA")

/* Column 6 */

import delimited "../CleanData/MAEvent/CBSA_Withdrawn_DeltaHHI10.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 6: Using withdrawn M&A with HHI > 10 and market being CBSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_cbsa calendar_year) cluster(cbsacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CBSA \& Year","Market Definition","CBSA")




/* Draft version for Table 3: Withdrawn M&A */

local outfile =  "../Draft/tabs/Slides_DID_MA_Withdrawn_Placebo.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1 */

import delimited "../CleanData/MAEvent/CSA_Withdrawn_DeltaHHI50.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 1: Using withdrawn M&A with HHI > 50 and market being CSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 2 */

import delimited "../CleanData/MAEvent/CSA_Withdrawn_DeltaHHI30.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 2: Using withdrawn M&A with HHI > 30 and market being CSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 3 */

import delimited "../CleanData/MAEvent/CSA_Withdrawn_DeltaHHI10.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 3: Using withdrawn M&A with HHI > 10 and market being CSA
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")


