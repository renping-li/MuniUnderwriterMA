
local outfile =  "../Draft/tabs/DID_MA_Liquidity.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIByN_Liquidity.csv", clear

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

egen cusip_code = group(cusip)

replace percent_markup_withinmonth = percent_markup_withinmonth*100
replace percent_markup_withinweek = percent_markup_withinweek*100

// Column 1: N trades

reghdfe n_trades treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.cusip_code##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) ///
cluster(csacode calendar_year) noconstant

outreg2 using  "`outfile'", tex(fragment) replace label ///
keep(treatedXpost) `outputoptions' ctitle("N Trades","\;") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("CUSIP $\times$ Cohort FE", "Yes","Cohort $\times$ Year FE", "Yes","Clustering","CSA \& Year")

// Column 2: Trading amount, scaled

reghdfe dollar_trades_scaled treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.cusip_code##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) ///
cluster(csacode calendar_year) noconstant

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost) `outputoptions' ctitle("Trading Volume","\;") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("CUSIP $\times$ Cohort FE", "Yes","Cohort $\times$ Year FE", "Yes","Clustering","CSA \& Year")

// Column 3: Markup, comparing price within a month

reghdfe percent_markup_withinmonth treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.cusip_code##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) ///
cluster(csacode calendar_year) noconstant

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost) `outputoptions' ctitle("Markup","(within Month)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("CUSIP $\times$ Cohort FE", "Yes","Cohort $\times$ Year FE", "Yes","Clustering","CSA \& Year")

// Column 4: Markup, comparing price within a week

reghdfe percent_markup_withinweek treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.cusip_code##i.episode_start_year##i.treated_csa i.episode_start_year##i.treated_csa##i.calendar_year) ///
cluster(csacode calendar_year) noconstant

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost) `outputoptions' ctitle("Markup","(within Week)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("CUSIP $\times$ Cohort FE", "Yes","Cohort $\times$ Year FE", "Yes","Clustering","CSA \& Year")
