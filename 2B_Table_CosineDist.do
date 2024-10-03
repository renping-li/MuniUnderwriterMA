
import delimited "../CleanData/SampleDesc/1F_SimScore.csv", clear

egen state_pair = group(statea stateb)

reshape long cosine_ ndealsa_ ndealsb_, i(state_pair year) j(type) string

gen distmiles_in1000 = distmiles/1000

local outfile =  "../Draft/tabs/SimScore.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Number: Average cosine similarity by security type */

sum cosine_ if type=="muni"
local cosine_muni : display %-9.3f r(mean)
file open myfile using "../Draft/nums/cosine_muni.tex", write replace
file write myfile "`cosine_muni'"
file close myfile

sum cosine_ if type=="bond"
local cosine_bond : display %-9.3f r(mean)
file open myfile using "../Draft/nums/cosine_bond.tex", write replace
file write myfile "`cosine_bond'"
file close myfile

sum cosine_ if type=="equity"
local cosine_equity : display %-9.3f r(mean)
file open myfile using "../Draft/nums/cosine_equity.tex", write replace
file write myfile "`cosine_equity'"
file close myfile

gen is_muni = type=="muni"
gen is_bond = type=="bond"
gen is_equity = type=="equity"

label var is_muni "For Municipal Bond Underwriters"
label var is_bond "Corporate Bond Over Municipal Bond"
label var is_equity "Corporate Equity Over Municipal Bond"

label var distmiles_in1000 "Geographic Distance, in 1,000 Miles"

// Column 1: Compare security types
reghdfe cosine_ is_bond is_equity, absorb(state_pair year) cluster(state_pair)
outreg2 using  "`outfile'", tex(fragment) replace label keep(is_bond is_equity) `outputoptions' ctitle("Cosine Similarity") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("State-Pair FE", "Yes","Year FE", "Yes","Clustering","State-Pair")

// Column 2: Geographic distance and cosine similarity
reghdfe cosine_ distmiles_in1000 if type=="muni", absorb(year) cluster(state_pair)
outreg2 using  "`outfile'", tex(fragment) append label keep(distmiles_in1000) `outputoptions' ctitle("Cosine Similarity") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("State-Pair FE", "No","Year FE", "Yes","Clustering","State-Pair")

