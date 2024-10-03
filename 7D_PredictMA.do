
/*-----------------------------------------------------------------------*/
/* Table: What predicts consolidation, and effects controlling for those */
/*-----------------------------------------------------------------------*/

/* Part 1: What predicts consolidation */

local outfile =  "../Draft/tabs/PredictMA.tex"

import delimited "../CleanData/MAEvent/ImpliedDeltaHHI.csv", clear 

// HHI in [0,10000]
replace hhi_dif = hhi_dif*10000
replace hhi_piror = hhi_piror*10000
// Population in thousand
replace pop = pop/1000
// Income in thousand dollars
replace inc = inc/1000
// Amount of past issuance, dollar per person
gen amount_percap = (amount*1000000)/(pop*1000)

xtset csacode year

gen pop_growth = (pop-l.pop)/pop
gen inc_growth = (inc-l.inc)/inc

// For regressions, use prior year's value. Add "csa" prefix and include them in main regressions in the last two columns
gen csa_hhi_piror = l.hhi_piror
gen csa_pop = l.pop
gen csa_pop_growth = l.pop_growth
gen csa_inc = l.inc
gen csa_inc_growth = l.inc_growth
gen csa_age = l.age
gen csa_is_minority = l.is_minority
gen csa_amount_percap = l.amount_percap
 
label var csa_hhi_piror "Prior HHI"
label var csa_pop "Population"
label var csa_pop_growth "Population Growth Rate"
label var csa_inc "Income"
label var csa_inc_growth "Income Growth Rate"
label var csa_age "Age"
label var csa_is_minority "Minority Ratio"
label var csa_amount_percap "Past Issuance Per Capita"

local outputoptions = "nor2 dec(4) stats(coef tstat) tdec(2) nonotes adec(3)"

// Column 1: Predict Delta HHI
reghdfe hhi_dif csa_hhi_piror csa_pop csa_pop_growth csa_inc csa_inc_growth csa_age csa_is_minority csa_amount_percap, ///
absorb(year) cluster(csacode year)

outreg2 using  "`outfile'", tex(fragment) replace label ///
keep(csa_hhi_piror csa_pop csa_pop_growth csa_inc csa_inc_growth csa_age csa_is_minority csa_amount_percap) ///
`outputoptions' ctitle("$\;Predicted\;$","$\Delta_{\text{HHI}}$") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","CSA $\times$ Cohort FE","\;","Clustering","CSA \& Year")

/*--- Number: Effects of population growth rate ---*/

local csa_pop_growth_effects = _b[csa_pop_growth]*0.01
local csa_pop_growth_effects : display %-9.1f `csa_pop_growth_effects'
file open myfile using "../Draft/nums/PredictMA_csa_pop_growth_effects.tex", write replace
file write myfile "`csa_pop_growth_effects'"
file close myfile

/*--- Number: Effects of minority ratio ---*/

local csa_is_minority_effects = _b[csa_is_minority]*0.01
local csa_is_minority_effects : display %-9.1f `csa_is_minority_effects'
file open myfile using "../Draft/nums/PredictMA_csa_is_minority_effects.tex", write replace
file write myfile "`csa_is_minority_effects'"
file close myfile

/*--- Number: Effects of minority ratio ---*/

local csa_amount_percap_effects = -_b[csa_amount_percap]*1000
local csa_amount_percap_effects : display %-9.1f `csa_amount_percap_effects'
file open myfile using "../Draft/nums/PredictMA_csa_amount_percap_effects.tex", write replace
file write myfile "`csa_amount_percap_effects'"
file close myfile

gen hhi_dif_above100 = 100*(hhi_dif>100)

// Column 2: Predict if Delta HHI > 100
reghdfe hhi_dif_above100 csa_hhi_piror csa_pop csa_pop_growth csa_inc csa_inc_growth csa_age csa_is_minority csa_amount_percap, ///
absorb(year) cluster(csacode year)

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(csa_hhi_piror csa_pop csa_pop_growth csa_inc csa_inc_growth csa_age csa_is_minority csa_amount_percap) ///
`outputoptions' ctitle("$1_{Predicted\;\Delta_{\text{HHI}}\ge100}$","$\times100$") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","CSA $\times$ Cohort FE","\;","Clustering","CSA \& Year")



/* Part 2: Do effects hold controlling for those? */

local outputoptions = "nor2 dec(2) stats(coef tstat) tdec(2) nonotes adec(3)"

// Combine with issue level data
rename year calendar_year
keep csacode calendar_year csa_hhi_piror csa_pop csa_pop_growth csa_inc csa_inc_growth csa_age csa_is_minority csa_amount_percap
tempfile ImpliedDeltaHHI
save `ImpliedDeltaHHI', replace

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear 
merge m:1 csacode calendar_year using `ImpliedDeltaHHI'

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 3: Control for variables that significantly affects Delta HHI
reghdfe gross_spread_inbp treated post treatedXpost ///
csa_hhi_piror csa_pop_growth ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost csa_hhi_piror csa_pop_growth) ///
 `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","CSA $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

// Column 4: Control for all variables
reghdfe gross_spread_inbp treated post treatedXpost ///
csa_hhi_piror csa_pop csa_pop_growth csa_inc csa_inc_growth csa_age csa_is_minority csa_amount_percap ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost csa_hhi_piror csa_pop csa_pop_growth csa_inc csa_inc_growth csa_age csa_is_minority csa_amount_percap) ///
`outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","CSA $\times$ Cohort FE", "Yes","Clustering","CSA \& Year") ///
sortvar(treatedXpost csa_hhi_piror csa_pop csa_pop_growth csa_inc csa_inc_growth csa_age csa_is_minority csa_amount_percap)


