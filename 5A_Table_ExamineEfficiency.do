
/*---------------------------------------------------------------------*/
/* Table: Investigate whether M&A has any efficiency enhancing effects */
/*---------------------------------------------------------------------*/

clear *

/* Panel 1: Linear probability model */

local outfile =  "../Draft/tabs/DID_MAEfficiency.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

gen bank_is_involved = (bank_is_acquiror=="True")|(bank_is_target=="True")
gen treatedXpostXbank_not_involved = treatedXpost*(1-bank_is_involved)
gen treatedXpostXbank_is_involved = treatedXpost*bank_is_involved

label var treatedXpostXbank_not_involved "Treated $\times$ Post $\times$ Bank not in M\&A"
label var treatedXpostXbank_is_involved "Treated $\times$ Post $\times$ Bank is in M\&A"

/* Column 1 */

gen has_rating = (has_fitch=="True")|(has_moodys=="True")

// Column 1: Having rating
reghdfe has_rating treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Has","Rating") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Effects on probability of having credit rating */

local effects_has_rating = _b[treatedXpost]*100
local effects_has_rating : display %-9.1f `effects_has_rating'
file open myfile using "../Draft/nums/effects_has_rating.tex", write replace
file write myfile "`effects_has_rating'"
file close myfile

local abs_effects_has_rating = -_b[treatedXpost]*100
local abs_effects_has_rating : display %-9.1f `abs_effects_has_rating'
file open myfile using "../Draft/nums/abs_effects_has_rating.tex", write replace
file write myfile "`abs_effects_has_rating'"
file close myfile

local t_effects_has_rating = _b[treatedXpost]/_se[treatedXpost]
local t_effects_has_rating : display %-9.1f `t_effects_has_rating'
file open myfile using "../Draft/nums/t_effects_has_rating.tex", write replace
file write myfile "`t_effects_has_rating'"
file close myfile

/* T-stat under alternative clustering */

reghdfe has_rating treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(issuer_code)

local t_effects_has_rating = _b[treatedXpost]/_se[treatedXpost]
local t_effects_has_rating : display %-9.1f `t_effects_has_rating'
file open myfile using "../Draft/nums/t_effects_has_rating_clusterissuer.tex", write replace
file write myfile "`t_effects_has_rating'"
file close myfile


/* Effect by whether bond issue is insured */

gen if_insured = insured_amount!=.

gen treatedXif_insured = treated*if_insured
gen postXif_insured = post*if_insured
gen treatedXpostXif_insured = treatedXpost*if_insured

gen treatedXif_not_insured = treated*(1-if_insured)
gen postXif_not_insured = post*(1-if_insured)
gen treatedXpostXif_not_insured = treatedXpost*(1-if_insured)

reghdfe has_rating if_insured treatedXif_insured postXif_insured treatedXpostXif_insured treatedXif_not_insured postXif_not_insured treatedXpostXif_not_insured ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)
drop if_insured

local effects_has_rat_if_ins = _b[treatedXpostXif_insured]*100
local effects_has_rat_if_ins : display %-9.1f `effects_has_rat_if_ins'
file open myfile using "../Draft/nums/effects_has_rat_if_ins.tex", write replace
file write myfile "`effects_has_rat_if_ins'"
file close myfile

local effects_has_rat_if_not_ins = _b[treatedXpostXif_not_insured]*100
local effects_has_rat_if_not_ins : display %-9.1f `effects_has_rat_if_not_ins'
file open myfile using "../Draft/nums/effects_has_rat_if_not_ins.tex", write replace
file write myfile "`effects_has_rat_if_not_ins'"
file close myfile

local abs_effects_has_rat_if_ins = -_b[treatedXpostXif_insured]*100
local abs_effects_has_rat_if_ins : display %-9.1f `abs_effects_has_rat_if_ins'
file open myfile using "../Draft/nums/abs_effects_has_rat_if_ins.tex", write replace
file write myfile "`abs_effects_has_rat_if_ins'"
file close myfile

local abs_effects_has_rat_if_not_ins = -_b[treatedXpostXif_not_insured]*100
local abs_effects_has_rat_if_not_ins : display %-9.1f `abs_effects_has_rat_if_not_ins'
file open myfile using "../Draft/nums/abs_effects_has_rat_if_not_ins.tex", write replace
file write myfile "`abs_effects_has_rat_if_not_ins'"
file close myfile

local t_effects_has_rat_if_ins = _b[treatedXpostXif_insured]/_se[treatedXpostXif_insured]
local t_effects_has_rat_if_ins : display %-9.2f `t_effects_has_rat_if_ins'
file open myfile using "../Draft/nums/t_effects_has_rat_if_ins.tex", write replace
file write myfile "`t_effects_has_rat_if_ins'"
file close myfile

local t_effects_has_rat_if_not_ins = _b[treatedXpostXif_not_insured]/_se[treatedXpostXif_not_insured]
local t_effects_has_rat_if_not_ins : display %-9.2f `t_effects_has_rat_if_not_ins'
file open myfile using "../Draft/nums/t_effects_has_rat_if_not_ins.tex", write replace
file write myfile "`t_effects_has_rat_if_not_ins'"
file close myfile

/* Column 2 */

// Column 2: Having rating
reghdfe has_rating (i.treated i.post)##(i.bank_is_involved) treatedXpostXbank_not_involved treatedXpostXbank_is_involved ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXbank_not_involved treatedXpostXbank_is_involved) `outputoptions' ctitle("Has","Rating") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* T-stat under alternative clustering */

reghdfe has_rating (i.treated i.post)##(i.bank_is_involved) treatedXpostXbank_not_involved treatedXpostXbank_is_involved ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(issuer_code calendar_year)

/* Column 3 */

replace insured_amount = 0 if insured_amount==.
gen insured_ratio = insured_amount/amount

// Column 3: Having insurance
reghdfe insured_ratio treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Insured","Ratio") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Effects on probability of having insurance */

local effects_insured_ratio = _b[treatedXpost]*100
local effects_insured_ratio : display %-9.1f `effects_insured_ratio'
file open myfile using "../Draft/nums/effects_insured_ratio.tex", write replace
file write myfile "`effects_insured_ratio'"
file close myfile

local t_effects_insured_ratio = _b[treatedXpost]/_se[treatedXpost]
local t_effects_insured_ratio : display %-9.1f `t_effects_insured_ratio'
file open myfile using "../Draft/nums/t_effects_insured_ratio.tex", write replace
file write myfile "`t_effects_insured_ratio'"
file close myfile

local abs_effects_insured_ratio = -_b[treatedXpost]*100
local abs_effects_insured_ratio : display %-9.1f `abs_effects_insured_ratio'
file open myfile using "../Draft/nums/abs_effects_insured_ratio.tex", write replace
file write myfile "`abs_effects_insured_ratio'"
file close myfile

/* T-stat under alternative clustering */

reghdfe insured_ratio treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(issuer_code)

local t_effects_insured_ratio = _b[treatedXpost]/_se[treatedXpost]
local t_effects_insured_ratio : display %-9.1f `t_effects_insured_ratio'
file open myfile using "../Draft/nums/t_effects_insured_ratio_clusterissuer.tex", write replace
file write myfile "`t_effects_insured_ratio'"
file close myfile

/* Column 4 */

// Column 4: Having insurance, with control variables
reghdfe insured_ratio (i.treated i.post)##(i.bank_is_involved) treatedXpostXbank_not_involved treatedXpostXbank_is_involved ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXbank_not_involved treatedXpostXbank_is_involved) `outputoptions' ctitle("Insured","Ratio") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* T-stat under alternative clustering */

reghdfe insured_ratio (i.treated i.post)##(i.bank_is_involved) treatedXpostXbank_not_involved treatedXpostXbank_is_involved ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(issuer_code calendar_year)

/* Column 5 */

gen if_advisor_coded = if_advisor=="Yes"

// Column 5: Having an advisor
reghdfe if_advisor_coded treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Has","Advisor") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Effects on probability of having credit rating */

local effects_if_advisor = _b[treatedXpost]*100
local effects_if_advisor : display %-9.1f `effects_if_advisor'
file open myfile using "../Draft/nums/effects_if_advisor.tex", write replace
file write myfile "`effects_if_advisor'"
file close myfile

local t_effects_if_advisor = _b[treatedXpost]/_se[treatedXpost]
local t_effects_if_advisor : display %-9.1f `t_effects_if_advisor'
file open myfile using "../Draft/nums/t_effects_if_advisor.tex", write replace
file write myfile "`t_effects_if_advisor'"
file close myfile

local abs_effects_if_advisor = -_b[treatedXpost]*100
local abs_effects_if_advisor : display %-9.1f `abs_effects_if_advisor'
file open myfile using "../Draft/nums/abs_effects_if_advisor.tex", write replace
file write myfile "`abs_effects_if_advisor'"
file close myfile

/* T-stat under alternative clustering */

reghdfe if_advisor_coded treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(issuer_code)

local t_effects_if_advisor = _b[treatedXpost]/_se[treatedXpost]
local t_effects_if_advisor : display %-9.1f `t_effects_if_advisor'
file open myfile using "../Draft/nums/t_effects_if_advisor_clusterissuer.tex", write replace
file write myfile "`t_effects_if_advisor'"
file close myfile

/* Column 6 */

// Column 6: Having an advisor, with control variables
reghdfe if_advisor_coded (i.treated i.post)##(i.bank_is_involved) treatedXpostXbank_not_involved treatedXpostXbank_is_involved ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXbank_not_involved treatedXpostXbank_is_involved) `outputoptions' ctitle("Has","Advisor") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year") ///
sortvar(treatedXpost treatedXpostXbank_not_involved treatedXpostXbank_is_involved)

/* T-stat under alternative clustering */

reghdfe if_advisor_coded (i.treated i.post)##(i.bank_is_involved) treatedXpostXbank_not_involved treatedXpostXbank_is_involved ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(issuer_code)

local t_effects_if_advisor = _b[treatedXpostXbank_is_involved]/_se[treatedXpostXbank_is_involved]
local t_effects_if_advisor : display %-9.1f `t_effects_if_advisor'
file open myfile using "../Draft/nums/t_effects_if_advisor_clusterissuer_involved.tex", write replace
file write myfile "`t_effects_if_advisor'"
file close myfile



/* Table: Linear probability model for slides */

local outfile =  "../Draft/tabs/Slides_DID_MAEfficiency.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

winsor2 amount, replace cuts(1 99)
winsor2 avg_maturity, replace cuts(1 99)

/* Column 1 */

gen has_rating = (has_fitch=="True")|(has_moodys=="True")

// Column 1: Having rating
reghdfe has_rating treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Has","Rating") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 2 */

replace insured_amount = 0 if insured_amount==.
gen insured_ratio = insured_amount/amount

// Column 2: Having an advisor
reghdfe insured_ratio treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Insured","Ratio") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")

/* Column 3 */

gen if_advisor_coded = if_advisor=="Yes"

// Column 3: Having an advisor
reghdfe if_advisor_coded treated post treatedXpost ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Has","Advisor") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","Issuer $\times$ Cohort FE", "Yes","Clustering","CSA \& Year")






