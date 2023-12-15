
/*----------------------------------------------------------------*/
/* Table: Robustness checks for main results of spread around M&A */
/*----------------------------------------------------------------*/

local outfile =  "../Slides/tabs/DID_MA_GrossSpread_robust.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1*/

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

encode taxable_code, gen(taxable_code_coded)
encode bid, gen(bid_coded)
encode security_type, gen(security_type_coded)
local outfile =  "../Slides/tabs/DID_MA_GrossSpread_robust.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1 */

encode name_gpf_0, gen(underwriter_code)

// Column 1: Add underwriter FE
reghdfe gross_spread_inbp treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type i.calendar_year i.underwriter_code) ///
cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) ///
addtext("Controls","No", ///
"Year FE", "Yes","Issuer FE", "Yes","Underwriter FE","Yes","Issuer X Underwriter FE","No", ///
"Taxable FE","No","Method of Sale FE","No","Source of Repayment FE","No", ///
"Taxable X Year FE","No","Method of Sale X Year FE","No","Source of Repayment X Year FE","No", ///
"Clustering","Issuer")

/* Column 2 */

// Column 2: Add underwriter X issuer FE
reghdfe gross_spread_inbp treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type##i.underwriter_code i.calendar_year) ///
cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) ///
addtext("Controls","No", ///
"Year FE", "Yes","Issuer FE", "Yes","Underwriter FE","No","Issuer X Underwriter FE","Yes", ///
"Taxable FE","No","Method of Sale FE","No","Source of Repayment FE","No", ///
"Taxable X Year FE","No","Method of Sale X Year FE","No","Source of Repayment X Year FE","No", ///
"Clustering","Issuer")

/* Column 3 */

// Column 3: Add more FEs
reghdfe gross_spread_inbp treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type i.taxable_code_coded i.bid_coded i.security_type_coded calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) ///
addtext( ///
"Controls","No", ///
"Year FE", "Yes","Issuer FE", "Yes","Underwriter FE","No","Issuer X Underwriter FE","No", ///
"Taxable FE","Yes","Method of Sale FE","Yes","Source of Repayment FE","Yes", ///
"Taxable X Year FE","No","Method of Sale X Year FE","No","Source of Repayment X Year FE","No", ///
"Clustering","Issuer")

/* Column 4 */

// Column 4: Add more FEs interacted with time
reghdfe gross_spread_inbp treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type i.taxable_code_coded##i.calendar_year i.bid_coded##i.calendar_year i.security_type_coded##i.calendar_year) ///
cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) ///
addtext( ///
"Controls","No", ///
"Year FE", "Yes","Issuer FE", "Yes","Underwriter FE","No","Issuer X Underwriter FE","No", ///
"Taxable FE","No","Method of Sale FE","No","Source of Repayment FE","No", ///
"Taxable X Year FE","Yes","Method of Sale X Year FE","Yes","Source of Repayment X Year FE","Yes", ///
"Clustering","Issuer")

/* Column 5 */

winsor2 amount, replace cuts(1 99)
winsor2 avg_maturity, replace cuts(1 99)

replace avg_maturity = avg_maturity/365

gen amount_2 = amount*amount
gen avg_maturity_2 = avg_maturity*avg_maturity

label var amount "Amount (Millions)"
label var avg_maturity "Maturity (Years)"
label var amount_2 "Amount (Millions)$^2$"
label var avg_maturity_2 "Maturity (Years)$^2$"

// Column 5: Controls
reghdfe gross_spread_inbp treated post treatedXpost amount avg_maturity amount_2 avg_maturity_2, ///
absorb(i.issuer_code##i.issuer_type i.calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost amount avg_maturity amount_2 avg_maturity_2) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) ///
addtext("Controls","Yes", ///
"Year FE", "Yes","Issuer FE", "Yes","Underwriter FE","No","Issuer X Underwriter FE","No", ///
"Taxable FE","No","Method of Sale FE","No","Source of Repayment FE","No", ///
"Taxable X Year FE","No","Method of Sale X Year FE","No","Source of Repayment X Year FE","No", ///
"Clustering","Issuer")

/* Column 6 */

gen is_cb_eligible = cb_eligible=="Yes"

label var is_cb_eligible "If Commercial Banks Eligible"

// Column 6: Control for whether commercial banks are eligible to underwrite
reghdfe gross_spread_inbp treated post treatedXpost is_cb_eligible, ///
absorb(i.issuer_code##i.issuer_type i.calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost is_cb_eligible) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) ///
addtext("Controls","No", ///
"Year FE", "Yes","Issuer FE", "Yes","Underwriter FE","No","Issuer X Underwriter FE","No", ///
"Taxable FE","No","Method of Sale FE","No","Source of Repayment FE","No", ///
"Taxable X Year FE","No","Method of Sale X Year FE","No","Source of Repayment X Year FE","No", ///
"Clustering","Issuer") ///
sortvar(treatedXpost amount avg_maturity amount_2 avg_maturity_2 is_cb_eligible)

/*--- Number: Effects on gross spread ---*/

local is_cb_eligible_effects = _b[is_cb_eligible]
local is_cb_eligible_effects : display %-9.1f `is_cb_eligible_effects'
file open myfile using "../Slides/nums/is_cb_eligible_effects.tex", write replace
file write myfile "`is_cb_eligible_effects'"
file close myfile

local abs_is_cb_eligible_effects = -_b[is_cb_eligible]
local abs_is_cb_eligible_effects : display %-9.1f `abs_is_cb_eligible_effects'
file open myfile using "../Slides/nums/abs_is_cb_eligible_effects.tex", write replace
file write myfile "`abs_is_cb_eligible_effects'"
file close myfile

/*

/* Column 7 */

gen gross_spread_inDollar = gross_spread_inbp*amount/10000
gen log_gross_spread_inDollar = log(gross_spread_inDollar)
winsor2 log_gross_spread_inDollar, replace cuts(1 99)

reghdfe log_gross_spread_inDollar treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type i.calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) ///
addtext("Controls","No","Year FE", "Yes","Issuer FE", "Yes","Taxable FE","No","Method of Sale FE","No","Source of Repayment FE","No","Taxable X Year FE","No","Method of Sale X Year FE","No","Source of Repayment X Year FE","No","Clustering","Issuer")

*/


