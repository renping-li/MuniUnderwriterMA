
/*-----------------------------------------*/
/* Table: Main results of yield around M&A */
/*-----------------------------------------*/



/* Panel 1: Using yield */

local outfile =  "../Draft/tabs/DID_MA_Yield_main.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen avg_yield_inbp = avg_yield*10000
gen treasury_avg_spread_inbp = treasury_avg_spread*10000
gen mma_avg_spread_inbp = mma_avg_spread*10000

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode bid, gen(bid_code)
gen treatedXpost_bidC = treatedXpost*(bid=="C")
gen treatedXpost_bidN = treatedXpost*(bid=="N")
gen treatedXpost_bidP = treatedXpost*(bid=="P")

label var treatedXpost_bidC "Treated $\times$ Post $\times$ Competitive Bidding"
label var treatedXpost_bidN "Treated $\times$ Post $\times$ Negotiated Sales"

encode issuer, gen(issuer_code)

/* Column 1 */

// Column 1: Yield spread over treasury
reghdfe treasury_avg_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label ///
keep(treatedXpost) `outputoptions' ctitle("Yield Spread","over Treasury","(bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

local coef_treasury_avg_spread_inbp = _b[treatedXpost]
local coef_treasury_avg_spread_inbp : display %-9.2f `coef_treasury_avg_spread_inbp'
file open myfile using "../Draft/nums/coef_treasury_avg_spread_inbp.tex", write replace
file write myfile "`coef_treasury_avg_spread_inbp'"
file close myfile

local t_treasury_avg_spread_inbp = _b[treatedXpost]/_se[treatedXpost]
local t_treasury_avg_spread_inbp : display %-9.2f `t_treasury_avg_spread_inbp'
file open myfile using "../Draft/nums/t_treasury_avg_spread_inbp.tex", write replace
file write myfile "`t_treasury_avg_spread_inbp'"
file close myfile

/* Column 2 */

// Column 2: Yield spread over treasury, by the method of sales
reghdfe treasury_avg_spread_inbp bid_code##(treated post) treatedXpost_bidC treatedXpost_bidN treatedXpost_bidP ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost_bidC treatedXpost_bidN) `outputoptions' ctitle("Yield Spread","over Treasury","(bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 3 */

// Column 3: Yield spread over MMA
reghdfe mma_avg_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost) `outputoptions' ctitle("Yield Spread","over MMA","(bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 4 */

// Column 4: Reoffering yield
reghdfe avg_yield_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost) `outputoptions' ctitle("Reoffering","Yield","(bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 5 */

// Column 5: Initial underpricing
reghdfe underpricing_15to30 treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost) `outputoptions' ctitle("Initial","Under-","pricing") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

local underpricing_15to30_effects = _b[treatedXpost]
local underpricing_15to30_effects : display %-9.2f `underpricing_15to30_effects'
file open myfile using "../Draft/nums/underpricing_15to30_effects.tex", write replace
file write myfile "`underpricing_15to30_effects'"
file close myfile

local t_underpricing_15to30_effects = _b[treatedXpost]/_se[treatedXpost]
local t_underpricing_15to30_effects : display %-9.2f `t_underpricing_15to30_effects'
file open myfile using "../Draft/nums/t_underpricing_15to30_effects.tex", write replace
file write myfile "`t_underpricing_15to30_effects'"
file close myfile

/* Column 6 */

// Column 6: Initial underpricing, by the method of sales
reghdfe underpricing_15to30 bid_code##(treated post) treatedXpost_bidC treatedXpost_bidN treatedXpost_bidP ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost_bidC treatedXpost_bidN) `outputoptions' ctitle("Initial","Under-","pricing") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

local underpricing_15to30_effects_C = _b[treatedXpost_bidC]
local underpricing_15to30_effects_C : display %-9.2f `underpricing_15to30_effects_C'
file open myfile using "../Draft/nums/underpricing_15to30_effects_C.tex", write replace
file write myfile "`underpricing_15to30_effects_C'"
file close myfile

local t_underpricing_effects_C = _b[treatedXpost_bidC]/_se[treatedXpost_bidC]
local t_underpricing_effects_C : display %-9.2f `t_underpricing_effects_C'
file open myfile using "../Draft/nums/t_underpricing_15to30_effects_C.tex", write replace
file write myfile "`t_underpricing_effects_C'"
file close myfile

local underpricing_15to30_effects_N = _b[treatedXpost_bidN]
local underpricing_15to30_effects_N : display %-9.2f `underpricing_15to30_effects_N'
file open myfile using "../Draft/nums/underpricing_15to30_effects_N.tex", write replace
file write myfile "`underpricing_15to30_effects_N'"
file close myfile

local t_underpricing_effects_N = _b[treatedXpost_bidN]/_se[treatedXpost_bidN]
local t_underpricing_effects_N : display %-9.2f `t_underpricing_effects_N'
file open myfile using "../Draft/nums/t_underpricing_15to30_effects_N.tex", write replace
file write myfile "`t_underpricing_effects_N'"
file close myfile

/* Column 7 */

// Column 7: Number of bids
reghdfe tbb_n_bidders treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost) `outputoptions' ctitle("N of","Bids") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year") ///
sortvar(treatedXpost treatedXpost_bidC treatedXpost_bidN)

local coef_tbb_n_bidders_effects = _b[treatedXpost]
local coef_tbb_n_bidders_effects : display %-9.2f `coef_tbb_n_bidders_effects'
file open myfile using "../Draft/nums/coef_tbb_n_bidders_effects.tex", write replace
file write myfile "`coef_tbb_n_bidders_effects'"
file close myfile

local t_tbb_n_bidders_effects = _b[treatedXpost]/_se[treatedXpost]
local t_tbb_n_bidders_effects : display %-9.2f `t_tbb_n_bidders_effects'
file open myfile using "../Draft/nums/t_tbb_n_bidders_effects.tex", write replace
file write myfile "`t_tbb_n_bidders_effects'"
file close myfile



/* Slides version of table with less columns */

local outfile =  "../Draft/tabs/Slides_DID_MA_Yield_main.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen avg_yield_inbp = avg_yield*10000
gen treasury_avg_spread_inbp = treasury_avg_spread*10000
gen mma_avg_spread_inbp = mma_avg_spread*10000

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode bid, gen(bid_code)
gen treatedXpost_bidC = treatedXpost*(bid=="C")
gen treatedXpost_bidN = treatedXpost*(bid=="N")
gen treatedXpost_bidP = treatedXpost*(bid=="P")

label var treatedXpost_bidC "Treated $\times$ Post $\times$ Competitive Bidding"
label var treatedXpost_bidN "Treated $\times$ Post $\times$ Negotiated Sales"

encode issuer, gen(issuer_code)

/* Column 1 */

// Column 1: Reoffering yield
reghdfe avg_yield_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label ///
keep(treatedXpost) `outputoptions' ctitle("Yield at","Initial Offering","(bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 2 */

// Column 2: Yield spread over treasury
reghdfe treasury_avg_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost) `outputoptions' ctitle("Yield Spread","over Treasury","(bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 3 */

// Column 3: Yield spread over treasury, by the method of sales
reghdfe treasury_avg_spread_inbp bid_code##(treated post) treatedXpost_bidC treatedXpost_bidN treatedXpost_bidP ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost_bidC treatedXpost_bidN) `outputoptions' ctitle("Yield Spread","over Treasury","(bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 4 */

// Column 4: Initial underpricing
reghdfe underpricing_15to30 treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Initial","Underpricing") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 5 */

// Column 5: Initial underpricing, by the method of sales
reghdfe underpricing_15to30 bid_code##(treated post) treatedXpost_bidC treatedXpost_bidN treatedXpost_bidP ///
if year_to_merger>=-4&year_to_merger<=4, /// 
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost_bidC treatedXpost_bidN) `outputoptions' ctitle("Initial","Underpricing") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year") ///
sortvar(treatedXpost treatedXpost_bidC treatedXpost_bidN)


