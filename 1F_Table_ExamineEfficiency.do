
/*---------------------------------------------------------------------*/
/* Table: Investigate whether M&A has any efficiency enhancing effects */
/*---------------------------------------------------------------------*/

/* Panel 1: Linear probability model */

local outfile =  "../Slides/tabs/DID_MAEfficiency.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

if "$MainThreshold" == "HHI" {
	import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear
}
else if "$MainThreshold" == "MarketShare" {
	import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear
}

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

winsor2 amount, replace cuts(1 99)
winsor2 avg_maturity, replace cuts(1 99)

gen amount_2 = amount*amount
gen avg_maturity_2 = avg_maturity*avg_maturity

gen bank_is_involved = (bank_is_acquiror=="True")|(bank_is_target=="True")
gen treatedXpostXbank_not_involved = treatedXpost*(1-bank_is_involved)
gen treatedXpostXbank_is_involved = treatedXpost*bank_is_involved

label var treatedXpostXbank_not_involved "Treated $\times$ Post $\times$ Bank not in M\&A"
label var treatedXpostXbank_is_involved "Treated $\times$ Post $\times$ Bank is in M\&A"

/* Column 1 */

gen has_rating = (has_fitch=="True")|(has_moodys=="True")

// Column 1: Having rating
reghdfe has_rating treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Has","Rating") ///
addstat("Within R-squared", e(r2_within)) addtext("Controls","No","Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Effects on probability of having credit rating */

local effects_has_rating = _b[treatedXpost]*100
local effects_has_rating : display %-9.1f `effects_has_rating'
file open myfile using "../Slides/nums/effects_has_rating.tex", write replace
file write myfile "`effects_has_rating'"
file close myfile

local abs_effects_has_rating = -_b[treatedXpost]*100
local abs_effects_has_rating : display %-9.1f `abs_effects_has_rating'
file open myfile using "../Slides/nums/abs_effects_has_rating.tex", write replace
file write myfile "`abs_effects_has_rating'"
file close myfile

/* Column 2 */

// Column 2: Having rating
reghdfe has_rating treated post treatedXpost amount amount_2 avg_maturity avg_maturity_2, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Has","Rating") ///
addstat("Within R-squared", e(r2_within)) addtext("Controls","Yes","Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 3 */

// Column 3: Having rating
reghdfe has_rating (i.treated i.post)##(i.bank_is_involved) treatedXpostXbank_not_involved treatedXpostXbank_is_involved, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXbank_not_involved treatedXpostXbank_is_involved) `outputoptions' ctitle("Has","Rating") ///
addstat("Within R-squared", e(r2_within)) addtext("Controls","No","Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 4 */

replace insured_amount = 0 if insured_amount==.
gen insured_ratio = insured_amount/amount

// Column 4: Having an advisor
reghdfe insured_ratio treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Insured","Ratio") ///
addstat("Within R-squared", e(r2_within)) addtext("Controls","No","Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Effects on probability of having credit rating */

local effects_insured_ratio = _b[treatedXpost]*100
local effects_insured_ratio : display %-9.1f `effects_insured_ratio'
file open myfile using "../Slides/nums/effects_insured_ratio.tex", write replace
file write myfile "`effects_insured_ratio'"
file close myfile

local abs_effects_insured_ratio = -_b[treatedXpost]*100
local abs_effects_insured_ratio : display %-9.1f `abs_effects_insured_ratio'
file open myfile using "../Slides/nums/abs_effects_insured_ratio.tex", write replace
file write myfile "`abs_effects_insured_ratio'"
file close myfile

/* Column 5 */

// Column 5: Having an advisor, with control variables
reghdfe insured_ratio treated post treatedXpost amount amount_2 avg_maturity avg_maturity_2, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Insured","Ratio") ///
addstat("Within R-squared", e(r2_within)) addtext("Controls","Yes","Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 6 */

// Column 6: Having an advisor, by either bank is involved in M&A
reghdfe insured_ratio (i.treated i.post)##(i.bank_is_involved) treatedXpostXbank_not_involved treatedXpostXbank_is_involved, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXbank_not_involved treatedXpostXbank_is_involved) `outputoptions' ctitle("Insured","Ratio") ///
addstat("Within R-squared", e(r2_within)) addtext("Controls","No","Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 7 */

gen if_advisor_coded = if_advisor=="Yes"

// Column 7: Having an advisor
reghdfe if_advisor_coded treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Has","Advisor") ///
addstat("Within R-squared", e(r2_within)) addtext("Controls","No","Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Effects on probability of having credit rating */

local effects_if_advisor = _b[treatedXpost]*100
local effects_if_advisor : display %-9.1f `effects_if_advisor'
file open myfile using "../Slides/nums/effects_if_advisor.tex", write replace
file write myfile "`effects_if_advisor'"
file close myfile

local abs_effects_if_advisor = -_b[treatedXpost]*100
local abs_effects_if_advisor : display %-9.1f `abs_effects_if_advisor'
file open myfile using "../Slides/nums/abs_effects_if_advisor.tex", write replace
file write myfile "`abs_effects_if_advisor'"
file close myfile

/* Column 8 */

// Column 8: Having an advisor, with control variables
reghdfe if_advisor_coded treated post treatedXpost amount amount_2 avg_maturity avg_maturity_2, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Has","Advisor") ///
addstat("Within R-squared", e(r2_within)) addtext("Controls","Yes","Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 9 */

// Column 9: Having an advisor, by either bank is involved in M&A
reghdfe if_advisor_coded (i.treated i.post)##(i.bank_is_involved) treatedXpostXbank_not_involved treatedXpostXbank_is_involved, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXbank_not_involved treatedXpostXbank_is_involved) `outputoptions' ctitle("Has","Advisor") ///
addstat("Within R-squared", e(r2_within)) addtext("Controls","No","Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer") ///
sortvar(treatedXpost treatedXpostXbank_not_involved treatedXpostXbank_is_involved)






/* Panel 2: Probit model */

local outfile =  "../Slides/tabs/DID_MAEfficiency_Probit.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes"

if "$MainThreshold" == "HHI" {
	import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear
}
else if "$MainThreshold" == "MarketShare" {
	import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear
}

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

egen issuer_codeXissuer_type = group(issuer_code issuer_type)

/* Column 1 */

gen has_rating = (has_fitch=="True")|(has_moodys=="True")

// First, obtain the estimated margin at the mean. Note that it only works if "i" is put in front of "treatedXpost", even if it is the same regression
probit has_rating treated post i.treatedXpost i.calendar_year, vce(cluster issuer_codeXissuer_type)
margins treatedXpost, atmean
local predicted_effect = string(r(b)[1,2]-r(b)[1,1], "%6.3f")

// Column 1: Having an advisor, probit model
probit has_rating treated post treatedXpost i.calendar_year, vce(cluster issuer_codeXissuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Has","Rating") ///
addtext("Year FE", "Yes","Issuer FE", "No","Clustering","Issuer","Predicted effect","`predicted_effect'")

/* Column 2 */

replace insured_amount = 0 if insured_amount==.
gen insured_ratio = insured_amount/amount
gen if_insured = insured_ratio>0

// First, obtain the estimated margin at the mean. Note that it only works if "i" is put in front of "treatedXpost", even if it is the same regression
probit if_insured treated post i.treatedXpost i.calendar_year, vce(cluster issuer_codeXissuer_type)
margins treatedXpost, atmean
local predicted_effect = string(r(b)[1,2]-r(b)[1,1], "%6.3f")

// Column 2: Having an advisor, probit model
probit if_insured treated post treatedXpost i.calendar_year, vce(cluster issuer_codeXissuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Is","Insured") ///
addtext("Year FE", "Yes","Issuer FE", "No","Clustering","Issuer","Predicted effect","`predicted_effect'")

/* Column 3 */

gen if_advisor_coded = if_advisor=="Yes"

// First, obtain the estimated margin at the mean. Note that it only works if "i" is put in front of "treatedXpost", even if it is the same regression
probit if_advisor_coded treated post i.treatedXpost i.calendar_year, vce(cluster issuer_codeXissuer_type)
margins treatedXpost, atmean
local predicted_effect = string(r(b)[1,2]-r(b)[1,1], "%6.3f")

// Column 3: Having an advisor, probit model
probit if_advisor_coded treated post treatedXpost i.calendar_year, vce(cluster issuer_codeXissuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Has","Advisor") ///
addtext("Year FE", "Yes","Issuer FE", "No","Clustering","Issuer","Predicted effect","`predicted_effect'")







/* Table: Linear probability model for slides */

local outfile =  "../Slides/tabs/Slides_DID_MAEfficiency.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

if "$MainThreshold" == "HHI" {
	import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear
}
else if "$MainThreshold" == "MarketShare" {
	import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear
}

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
reghdfe has_rating treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Has","Rating") ///
addstat("Within R-squared", e(r2_within)) addtext("Controls","No","Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 2 */

replace insured_amount = 0 if insured_amount==.
gen insured_ratio = insured_amount/amount

// Column 2: Having an advisor
reghdfe insured_ratio treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Insured","Ratio") ///
addstat("Within R-squared", e(r2_within)) addtext("Controls","No","Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 3 */

gen if_advisor_coded = if_advisor=="Yes"

// Column 3: Having an advisor
reghdfe if_advisor_coded treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Has","Advisor") ///
addstat("Within R-squared", e(r2_within)) addtext("Controls","No","Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")






