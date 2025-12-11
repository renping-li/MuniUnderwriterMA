
local outfile =  "../Draft/tabs/DID_MAEntry.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIByN_Quant.csv", clear

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

// Collapse the county level data, as entry and quantity share the same datafile

duplicates drop episode_start_year treated_csa csacode year_to_merger, force

winsor2 n_newbanks, replace cuts(1 99)
winsor2 market_share_n_newbanks, replace cuts(1 99)

/* Column 1 */

// Column 1: N underwriter entry
reghdfe n_newbanks treated post treatedXpost, absorb(i.csacode##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) cluster(i.csacode i.calendar_year) nocons

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("N New","Underwriters") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Cohort $\times$ Year FE", "Yes","CSA $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","Minimum N Deals","0")

/* Column 2 */

// Column 2: New underwriter market share
reghdfe market_share_n_newbanks treated post treatedXpost, absorb(i.csacode##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) cluster(i.csacode i.calendar_year) nocons

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Market Share New","Underwriters") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Cohort $\times$ Year FE", "Yes","CSA $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","Minimum N Deals","0")

/* Column 3 */

// Column 3: N underwriter entry, minimum 10 deals
reghdfe n_newbanks treated post treatedXpost if n_deals>10, absorb(i.csacode##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) cluster(i.csacode i.calendar_year) nocons

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("N New","Underwriters") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Cohort $\times$ Year FE", "Yes","CSA $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","Minimum N Deals","10")

/* Column 4 */

// Column 4: New underwriter market share, minimum 10 deals
reghdfe market_share_n_newbanks treated post treatedXpost if n_deals>10, absorb(i.csacode##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) cluster(i.csacode i.calendar_year) nocons

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Market Share New","Underwriters") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Cohort $\times$ Year FE", "Yes","CSA $\times$ Cohort FE", "Yes","Clustering","CSA \& Year","Minimum N Deals","10")
