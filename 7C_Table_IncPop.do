
/*-------------------------------------------------------------------------------------*/
/* Table: How population and income evolve around M&As for treated relative to control */
/*-------------------------------------------------------------------------------------*/

local outfile =  "../Draft/tabs/DID_MA_IncPop.tex"
local outputoptions = "nor2 dec(1) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIByN_IncPop.csv", clear 

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

/* Column 1 */

winsor2 inc, replace cuts(1 99)

// Column 1: Using income and using CSA level observations
reghdfe inc treated post treatedXpost, absorb(csacode##treated_csa calendar_year) cluster(csacode calendar_year)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Income") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","CSA FE", "Yes","Clustering","CSA")

/*--- Number: Effects on gross spread ---*/

local inc_effects = _b[treatedXpost]
local inc_effects : display %-9.1f `inc_effects'
file open myfile using "../Draft/nums/inc_effects.tex", write replace
file write myfile "`inc_effects'"
file close myfile

local abs_inc_effects = -_b[treatedXpost]
local abs_inc_effects : display %-9.1f `abs_inc_effects'
file open myfile using "../Draft/nums/abs_inc_effects.tex", write replace
file write myfile "`abs_inc_effects'"
file close myfile

/* Column 2 */

winsor2 pop, replace cuts(1 99)

// Column 2: Using population and using CSA level observations
reghdfe pop treated post treatedXpost, absorb(csacode##treated_csa calendar_year) cluster(csacode calendar_year)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Population") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","CSA FE", "Yes","Clustering","CSA")

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIByN.csv", clear 

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

