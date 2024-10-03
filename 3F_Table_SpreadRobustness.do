
// To do: Remove "Add underwriter FE". Add "state X calendar year FE" column

/*----------------------------------------------------------------*/
/* Table: Robustness checks for main results of spread around M&A */
/*----------------------------------------------------------------*/

{

local outfile =  "../Draft/tabs/DID_MA_GrossSpread_robust.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1*/

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

encode taxable_code, gen(taxable_code_coded)
encode bid, gen(bid_coded)
encode security_type, gen(security_type_coded)

encode state, gen(state_coded)

encode name_gpf_0, gen(underwriter_code)

winsor2 amount, replace cuts(1 99)
winsor2 avg_maturity, replace cuts(1 99)

replace avg_maturity = avg_maturity/365

gen amount_2 = amount*amount
gen avg_maturity_2 = avg_maturity*avg_maturity

label var amount "Amount (Million)"
label var avg_maturity "Maturity (Years)"
label var amount_2 "Amount (Million)$^2$"
label var avg_maturity_2 "Maturity (Years)$^2$"

gen is_cb_eligible = cb_eligible=="Yes"

label var is_cb_eligible "If Commercial Banks Eligible"

// Generate corrective weights as in Wing et al.

preserve
duplicates drop episode_start_year treated_csa treated issuer_code issuer_type, force
egen issuer_codeXissuer_type = group(issuer_code issuer_type)
bysort episode_start_year treated_csa treated: egen n_count = count(issuer_codeXissuer_type)
duplicates drop episode_start_year treated_csa treated, force
keep episode_start_year treated_csa treated n_count
sum n_count if treated==0
local sum_n_count_control = r(sum)
sum n_count if treated==1
local sum_n_count_treated = r(sum)
replace n_count = n_count/`sum_n_count_control' if treated==0
replace n_count = n_count/`sum_n_count_treated' if treated==1
rename n_count weight
tempfile weight
save `weight', replace
restore

merge m:1 episode_start_year treated_csa treated using `weight'



/* Column 1 */

// Column 1: Add state X year FE
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
i.state_coded##i.calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext( ///
"Controls","No", ///
"Year FE", "No","Issuer $\times$ Cohort FE","Yes", ///
"State $\times$ Year FE","Yes","Underwriter $\times$ Year FE","No","Issuer $\times$ Underwriter $\times$ Cohort FE","No", ///
"Taxable $\times$ Year FE","No","Method of Sale $\times$ Year FE","No","Source of Repayment $\times$ Year FE","No", ///
"Clustering","CSA \& Year","Weighting","No")

/* Column 2 */

// Column 2: Add underwriter X time FE
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
i.calendar_year##i.underwriter_code) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext( ///
"Controls","No", ///
"Year FE", "No","Issuer $\times$ Cohort FE","Yes", ///
"State $\times$ Year FE","No","Underwriter $\times$ Year FE","Yes","Issuer $\times$ Underwriter $\times$ Cohort FE","No", ///
"Taxable $\times$ Year FE","No","Method of Sale $\times$ Year FE","No","Source of Repayment $\times$ Year FE","No", ///
"Clustering","CSA \& Year","Weighting","No")

/* Column 3 */

// Column 3: Add underwriter X issuer X cohort FE
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.underwriter_code##i.episode_start_year##i.treated_csa ///
i.calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext( ///
"Controls","No", ///
"Year FE", "Yes","Issuer $\times$ Cohort FE","No", ///
"State $\times$ Year FE","No","Underwriter $\times$ Year FE","No","Issuer $\times$ Underwriter $\times$ Cohort FE","Yes", ///
"Taxable $\times$ Year FE","No","Method of Sale $\times$ Year FE","No","Source of Repayment $\times$ Year FE","No", ///
"Clustering","CSA \& Year","Weighting","No")

/* Column 4 */

// Column 4: Add more FEs interacted with time
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
i.taxable_code_coded##i.calendar_year ///
i.bid_coded##i.calendar_year ///
i.security_type_coded##i.calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext( ///
"Controls","No", ///
"Year FE", "No","Issuer $\times$ Cohort FE","Yes", ///
"State $\times$ Year FE","No","Underwriter $\times$ Year FE","No","Issuer $\times$ Underwriter $\times$ Cohort FE","No", ///
"Taxable $\times$ Year FE","Yes","Method of Sale $\times$ Year FE","Yes","Source of Repayment $\times$ Year FE","Yes", ///
"Clustering","CSA \& Year","Weighting","No")

/* Column 5 */

// Column 5: Controls
reghdfe gross_spread_inbp treated post treatedXpost amount avg_maturity amount_2 avg_maturity_2 ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
i.calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext( ///
"Controls","Yes", ///
"Year FE", "Yes","Issuer $\times$ Cohort FE","Yes", ///
"State $\times$ Year FE","No","Underwriter $\times$ Year FE","No","Issuer $\times$ Underwriter $\times$ Cohort FE","No", ///
"Taxable $\times$ Year FE","No","Method of Sale $\times$ Year FE","No","Source of Repayment $\times$ Year FE","No", ///
"Clustering","CSA \& Year","Weighting","No") ///

/* Column 6 */

// Column 6: Control for whether commercial banks are eligible to underwrite
reghdfe gross_spread_inbp treated post treatedXpost is_cb_eligible ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost is_cb_eligible) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext( ///
"Controls","No", ///
"Year FE", "Yes","Issuer $\times$ Cohort FE","Yes", ///
"State $\times$ Year FE","No","Underwriter $\times$ Year FE","No","Issuer $\times$ Underwriter $\times$ Cohort FE","No", ///
"Taxable $\times$ Year FE","No","Method of Sale $\times$ Year FE","No","Source of Repayment $\times$ Year FE","No", ///
"Clustering","CSA \& Year","Weighting","No") ///

/*--- Number: Effects on gross spread ---*/

local is_cb_eligible_effects = _b[is_cb_eligible]
local is_cb_eligible_effects : display %-9.1f `is_cb_eligible_effects'
file open myfile using "../Draft/nums/is_cb_eligible_effects.tex", write replace
file write myfile "`is_cb_eligible_effects'"
file close myfile

local abs_is_cb_eligible_effects = -_b[is_cb_eligible]
local abs_is_cb_eligible_effects : display %-9.1f `abs_is_cb_eligible_effects'
file open myfile using "../Draft/nums/abs_is_cb_eligible_effects.tex", write replace
file write myfile "`abs_is_cb_eligible_effects'"
file close myfile

local t_is_cb_eligible_effects = _b[is_cb_eligible]/_se[is_cb_eligible]
local t_is_cb_eligible_effects : display %-9.1f `t_is_cb_eligible_effects'
file open myfile using "../Draft/nums/t_is_cb_eligible_effects.tex", write replace
file write myfile "`t_is_cb_eligible_effects'"
file close myfile

/* Column 7 */

// Column 7: Using corrective weight developed for stacked dif-in-dif
reghdfe gross_spread_inbp treated post treatedXpost ///
[aweight=weight] if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost is_cb_eligible) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext( ///
"Controls","No", ///
"Year FE", "Yes","Issuer $\times$ Cohort FE","Yes", ///
"State $\times$ Year FE","No","Underwriter $\times$ Year FE","No","Issuer $\times$ Underwriter $\times$ Cohort FE","No", ///
"Taxable $\times$ Year FE","No","Method of Sale $\times$ Year FE","No","Source of Repayment $\times$ Year FE","No", ///
"Clustering","CSA \& Year","Weighting","Yes") ///
sortvar(treatedXpost is_cb_eligible)

}






/*--------------------------------------------------------------------------------*/
/* Table: Robustness to the matching and addressing critics in Baker et al (2022) */
/*--------------------------------------------------------------------------------*/

{

local outfile =  "../Draft/tabs/DID_MA_GrossSpread_robust_match.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1 */

import delimited "../CleanData/MAEvent/CSA_TwoMatch_episodes_impliedHHIByN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 1: Using two matches
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext("Year FE", "Yes", ///
"Issuer \$\times\$ Cohort FE", "Yes", ///
"Clustering","CSA \& Year", ///
"Number of Matches","2", ///
"Matching Co-variates","Local Income", ///
"\;","and", ///
"\;\;","Population", ///
"\;\;\;","\;", ///
"\;\;\;\;","\;", ///
"Restrictions","\;", ///
"\;\;\;\;\;","\;")

/* Column 2 */

import delimited "../CleanData/MAEvent/CSA_ThreeMatch_episodes_impliedHHIByN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 2: Using three matches
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext("Year FE", "Yes", ///
"Issuer \$\times\$ Cohort FE", "Yes", ///
"Clustering","CSA \& Year", ///
"Number of Matches","3", ///
"Matching Co-variates","Local Income", ///
"\;","and", ///
"\;\;","Population", ///
"\;\;\;","\;", ///
"\;\;\;\;","\;", ///
"Restrictions","\;", ///
"\;\;\;\;\;","\;")


/* Column 3 */

import delimited "../CleanData/MAEvent/CSA_Dynamics_episodes_impliedHHIByN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 3: Match on dynamics of demographics
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext("Year FE", "Yes", ///
"Issuer \$\times\$ Cohort FE", "Yes", ///
"Clustering","CSA \& Year", ///
"Number of Matches","1", ///
"Matching Co-variates","Local Income", ///
"\;","and", ///
"\;\;","Population", ///
"\;\;\;","plus", ///
"\;\;\;\;","Demographics Dynamics", ///
"Restrictions","\;", ///
"\;\;\;\;\;","\;")

/* Column 4 */

import delimited "../CleanData/MAEvent/CSA_Outcome_episodes_impliedHHIByN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 4: Match on outcome variable
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext("Year FE", "Yes", ///
"Issuer \$\times\$ Cohort FE", "Yes", ///
"Clustering","CSA \& Year", ///
"Number of Matches","1", ///
"Matching Co-variates","Local Income", ///
"\;","and", ///
"\;\;","Population", ///
"\;\;\;","plus", ///
"\;\;\;\;","Issuance Outcomes", ///
"Restrictions","\;", ///
"\;\;\;\;\;","\;")

/* Column 5 */

import delimited "../CleanData/MAEvent/CSA_AllAsControl_episodes_impliedHHIByN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 5: Use all non-treated as control
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext("Year FE", "Yes", ///
"Issuer \$\times\$ Cohort FE", "Yes", ///
"Clustering","CSA \& Year", ///
"Number of Matches","Unlimited", ///
"Matching Co-variates","None", ///
"\;","\;", ///
"\;\;","\;", ///
"\;\;\;","\;", ///
"\;\;\;\;","\;", ///
"Restrictions","\;", ///
"\;\;\;\;\;","\;")

/* Column 6 */

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIByN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 6: Using three matches
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&frequency==1, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext("Year FE", "Yes", ///
"Issuer \$\times\$ Cohort FE", "Yes", ///
"Clustering","CSA \& Year", ///
"Number of Matches","1", ///
"Matching Co-variates","Local Income", ///
"\;","and", ///
"\;\;","Population", ///
"\;\;\;","\;", ///
"\;\;\;\;","\;", ///
"Restrictions","\;", ///
"\;\;\;\;\;","\;")

/* Column 7 */

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIByN_ControlNeverTreated.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 7: Using three matches
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext("Year FE", "Yes", ///
"Issuer \$\times\$ Cohort FE", "Yes", ///
"Clustering","CSA \& Year", ///
"Number of Matches","1", ///
"Matching Co-variates","Local Income", ///
"\;","and", ///
"\;\;","Population", ///
"\;\;\;","\;", ///
"\;\;\;\;","\;", ///
"Restrictions","Requiring No", ///
"\;\;\;\;\;","Prior Treatment")

}





/*---------------------------------------------------------------------------*/
/* Table for slides: Robustness checks for main results of spread around M&A */
/*---------------------------------------------------------------------------*/

/* Part I */

{

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

encode taxable_code, gen(taxable_code_coded)
encode bid, gen(bid_coded)
encode security_type, gen(security_type_coded)

encode state, gen(state_coded)

encode name_gpf_0, gen(underwriter_code)

preserve
duplicates drop episode_start_year treated_csa treated issuer_code issuer_type, force
egen issuer_codeXissuer_type = group(issuer_code issuer_type)
bysort episode_start_year treated_csa treated: egen n_count = count(issuer_codeXissuer_type)
duplicates drop episode_start_year treated_csa treated, force
keep episode_start_year treated_csa treated n_count
sum n_count if treated==0
local sum_n_count_control = r(sum)
sum n_count if treated==1
local sum_n_count_treated = r(sum)
replace n_count = n_count/`sum_n_count_control' if treated==0
replace n_count = n_count/`sum_n_count_treated' if treated==1
rename n_count weight
tempfile weight
save `weight', replace
restore

merge m:1 episode_start_year treated_csa treated using `weight'



/* Part I */

local outfile =  "../Draft/tabs/Slides_DID_MA_GrossSpread_robust_part1.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1 */

// Column 1: Add state X time FE
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
i.state_coded##i.calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext( ///
"Year FE", "\;", ///
"Issuer $\times$ Cohort FE","Yes", ///
"State $\times$ Year FE","Yes", ///
"Underwriter $\times$ Year FE","\;", ///
"Issuer $\times$ Underwriter $\times$ Cohort FE","\;", ///
"Clustering","CSA \& Year", ///
"Weights","None")

/* Column 2 */

// Column 2: Add underwriter X time FE
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
i.calendar_year##i.underwriter_code) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext( ///
"Year FE", "\;", ///
"Issuer $\times$ Cohort FE","Yes", ///
"State $\times$ Year FE","\;", ///
"Underwriter $\times$ Year FE","Yes", ///
"Issuer $\times$ Underwriter $\times$ Cohort FE","\;", ///
"Clustering","CSA \& Year", ///
"Weights","None")

/* Column 3 */

// Column 3: Add underwriter X issuer X cohort FE
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.underwriter_code##i.episode_start_year##i.treated_csa ///
i.calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext( ///
"Year FE", "Yes", ///
"Issuer $\times$ Cohort FE","\;", ///
"State $\times$ Year FE","\;", ///
"Underwriter $\times$ Year FE","\;", ///
"Issuer $\times$ Underwriter $\times$ Cohort FE","Yes", ///
"Clustering","CSA \& Year", ///
"Weights","None")

/* Column 4 */

// Column 4: Using corrective weight developed for stacked dif-in-dif
reghdfe gross_spread_inbp treated post treatedXpost ///
[aweight=weight] if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext( ///
"Year FE", "Yes", ///
"Issuer $\times$ Cohort FE","Yes", ///
"State $\times$ Year FE","\;", ///
"Underwriter $\times$ Year FE","\;", ///
"Issuer $\times$ Underwriter $\times$ Cohort FE","\;", ///
"Clustering","CSA \& Year", ///
"Weights","\citet{Wing_2024}")

}




/* Part II */

{

local outfile =  "../Draft/tabs/Slides_DID_MA_GrossSpread_robust_part2.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1 */

// Column 1: Add more FEs interacted with time
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
i.taxable_code_coded##i.calendar_year ///
i.bid_coded##i.calendar_year ///
i.security_type_coded##i.calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext( ///
"Controls","\;", ///
"Year FE", "\;","Issuer $\times$ Cohort FE","Yes", ///
"Taxable $\times$ Year FE","Yes","Method of Sale $\times$ Year FE","Yes","Source of Repayment $\times$ Year FE","Yes", ///
"Clustering","CSA \& Year")

/* Column 2 */

winsor2 amount, replace cuts(1 99)
winsor2 avg_maturity, replace cuts(1 99)

replace avg_maturity = avg_maturity/365

gen amount_2 = amount*amount
gen avg_maturity_2 = avg_maturity*avg_maturity

label var amount "Amount (Million)"
label var avg_maturity "Maturity (Years)"
label var amount_2 "Amount (Million)$^2$"
label var avg_maturity_2 "Maturity (Years)$^2$"

// Column 2: Controls
reghdfe gross_spread_inbp treated post treatedXpost amount avg_maturity amount_2 avg_maturity_2 ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa ///
i.calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext( ///
"Controls","Yes", ///
"Year FE", "Yes","Issuer $\times$ Cohort FE","Yes", ///
"Taxable $\times$ Year FE","\;","Method of Sale $\times$ Year FE","\;","Source of Repayment $\times$ Year FE","\;", ///
"Clustering","CSA \& Year")

/* Column 3 */

gen is_cb_eligible = cb_eligible=="Yes"

label var is_cb_eligible "If Commercial Banks Eligible"

// Column 3: Control for whether commercial banks are eligible to underwrite
reghdfe gross_spread_inbp treated post treatedXpost is_cb_eligible ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa i.calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost is_cb_eligible) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext( ///
"Controls","\;", ///
"Year FE", "Yes","Issuer $\times$ Cohort FE","Yes", ///
"Taxable $\times$ Year FE","\;","Method of Sale $\times$ Year FE","\;","Source of Repayment $\times$ Year FE","\;", ///
"Clustering","CSA \& Year") ///
sortvar(treatedXpost is_cb_eligible)

}





/*----------------------------------------------*/
/* Table for slides: Robustness to the matching */
/*----------------------------------------------*/

{

local outfile =  "../Draft/tabs/Slides_DID_MA_GrossSpread_robust_match.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1 */

import delimited "../CleanData/MAEvent/CSA_TwoMatch_episodes_impliedHHIByN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 1: Using two matches
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext("Year FE", "Yes", ///
"Issuer \$\times\$ Cohort FE", "Yes", ///
"Clustering","CSA \& Year", ///
"Number of Matches","2", ///
"Matching Co-variates","Local Income", ///
"\;","and", ///
"\;\;","Population", ///
"\;\;\;","\;", ///
"\;\;\;\;","\;")

/* Column 2 */

import delimited "../CleanData/MAEvent/CSA_ThreeMatch_episodes_impliedHHIByN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 2: Using three matches
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext("Year FE", "Yes", ///
"Issuer \$\times\$ Cohort FE", "Yes", ///
"Clustering","CSA \& Year", ///
"Number of Matches","3", ///
"Matching Co-variates","Local Income", ///
"\;","and", ///
"\;\;","Population", ///
"\;\;\;","\;", ///
"\;\;\;\;","\;")

/* Column 3 */

import delimited "../CleanData/MAEvent/CSA_Dynamics_episodes_impliedHHIByN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 3: Match on dynamics of demographics
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext("Year FE", "Yes", ///
"Issuer \$\times\$ Cohort FE", "Yes", ///
"Clustering","CSA \& Year", ///
"Number of Matches","1", ///
"Matching Co-variates","Local Income", ///
"\;","and", ///
"\;\;","Population", ///
"\;\;\;","plus", ///
"\;\;\;\;","Demographics Dynamics")

/* Column 4 */

import delimited "../CleanData/MAEvent/CSA_Outcome_episodes_impliedHHIByN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 4: Match on outcome variable
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext("Year FE", "Yes", ///
"Issuer \$\times\$ Cohort FE", "Yes", ///
"Clustering","CSA \& Year", ///
"Number of Matches","1", ///
"Matching Co-variates","Local Income", ///
"\;","and", ///
"\;\;","Population", ///
"\;\;\;","plus", ///
"\;\;\;\;","Issuance Outcomes")

/* Column 5 */

import delimited "../CleanData/MAEvent/CSA_AllAsControl_episodes_impliedHHIByN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 5: Use all non-treated as control
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext("Year FE", "Yes", ///
"Issuer \$\times\$ Cohort FE", "Yes", ///
"Clustering","CSA \& Year", ///
"Number of Matches","Unlimited", ///
"Matching Co-variates","None", ///
"\;","\;", ///
"\;\;","\;", ///
"\;\;\;","\;", ///
"\;\;\;\;","\;")

}



/*--------------------------------------------------------------------------*/
/* Table for slides: Robustness to addressing critics in Baker et al (2022) */
/*--------------------------------------------------------------------------*/

{

local outfile =  "../Draft/tabs/Slides_DID_MA_GrossSpread_robust_match_Baker.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1 */

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIByN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 1: Using three matches
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4&frequency==1, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext("Year FE", "Yes", ///
"Issuer \$\times\$ Cohort FE", "Yes", ///
"Clustering","CSA \& Year", ///
"Number of Matches","1", ///
"Matching Co-variates","Local Income", ///
"\;","and", ///
"\;\;","Population", ///
"Restrictions","Treated Once", ///
"\;\;\;\;\;","\;")

/* Column 2 */

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIByN_ControlNeverTreated.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Column 2: Using three matches
reghdfe gross_spread_inbp treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Adjusted R-squared", e(r2_a)) ///
addtext("Year FE", "Yes", ///
"Issuer \$\times\$ Cohort FE", "Yes", ///
"Clustering","CSA \& Year", ///
"Number of Matches","1", ///
"Matching Co-variates","Local Income", ///
"\;","and", ///
"\;\;","Population", ///
"Restrictions","Requiring No", ///
"\;\;\;\;\;","Prior Treatment")

}
