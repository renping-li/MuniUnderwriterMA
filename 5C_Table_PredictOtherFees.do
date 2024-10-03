
/* Table: Statistical model of other fees */

local outfile =  "../Draft/tabs/PredictOtherFees.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) tdec(2) nonotes adec(3)"

/* Column 1 */

import delimited "../CleanData/California/0H_CostSample_RegData_CRRatio.csv", clear

label var inc_to_avg "Income"
label var pop_to_avg "Population"

gen maturity_bracket_1 = gpf_maturity_bracket=="2y to 5y"
gen maturity_bracket_2 = gpf_maturity_bracket=="5y to 10y"
gen maturity_bracket_3 = gpf_maturity_bracket=="10y to 20y"
gen maturity_bracket_4 = gpf_maturity_bracket=="20y to 30y"
gen maturity_bracket_5 = gpf_maturity_bracket=="30y to 40y"
gen maturity_bracket_6 = gpf_maturity_bracket=="Greater than 40y"

label var maturity_bracket_1 "Maturity in [2y, 5y)"
label var maturity_bracket_2 "Maturity in [5y, 10y)"
label var maturity_bracket_3 "Maturity in [10y, 20y)"
label var maturity_bracket_4 "Maturity in [20y, 30y)"
label var maturity_bracket_5 "Maturity in [30y, 40y)"
label var maturity_bracket_6 "Maturity $\ge$ 40y"

gen amount_bracket_1 = gpf_amount_bracket=="1M to 5M"
gen amount_bracket_2 = gpf_amount_bracket=="5M to 10M"
gen amount_bracket_3 = gpf_amount_bracket=="10M to 50M"
gen amount_bracket_4 = gpf_amount_bracket=="50M to 100M"
gen amount_bracket_5 = gpf_amount_bracket=="Greater than 100M"

label var amount_bracket_1 "Amount in [1M, 5M)"
label var amount_bracket_2 "Amount in [5M, 10M)"
label var amount_bracket_3 "Amount in [10M, 50M)"
label var amount_bracket_4 "Amount in [50M, 100M)"
label var amount_bracket_5 "Amount $\ge$ 100M"

gen bidN = gpf_bid=="N"

label var bidN "Is Negotiated Sales"

gen taxT = gpf_taxable_code=="T"
gen taxA = gpf_taxable_code=="A"

label var taxT "Is Taxable"
label var taxA "Is Alternative Minimum Tax"

gen security_type_RV = gpf_security_type=="RV"

label var security_type_RV "Is REV"

reg crfeeratio inc_to_avg pop_to_avg ///
maturity_bracket_1 maturity_bracket_2 maturity_bracket_3 maturity_bracket_4 maturity_bracket_5 maturity_bracket_6 ///
amount_bracket_1 amount_bracket_2 amount_bracket_3 amount_bracket_4 amount_bracket_5 ///
bidN taxT taxA security_type_RV

outreg2 using  "`outfile'", tex(fragment) replace label ///
`outputoptions' ctitle("Credit Rating", "Fee (bps.)") ///
addstat("R-squared", e(r2)) drop(crratio)

/* Column 2 */

import delimited "../CleanData/California/0H_CostSample_RegData_InsureRatio.csv", clear

label var inc_to_avg "Income"
label var pop_to_avg "Population"

gen maturity_bracket_1 = gpf_maturity_bracket=="2y to 5y"
gen maturity_bracket_2 = gpf_maturity_bracket=="5y to 10y"
gen maturity_bracket_3 = gpf_maturity_bracket=="10y to 20y"
gen maturity_bracket_4 = gpf_maturity_bracket=="20y to 30y"
gen maturity_bracket_5 = gpf_maturity_bracket=="30y to 40y"
gen maturity_bracket_6 = gpf_maturity_bracket=="Greater than 40y"

label var maturity_bracket_1 "Maturity in [2y, 5y)"
label var maturity_bracket_2 "Maturity in [5y, 10y)"
label var maturity_bracket_3 "Maturity in [10y, 20y)"
label var maturity_bracket_4 "Maturity in [20y, 30y)"
label var maturity_bracket_5 "Maturity in [30y, 40y)"
label var maturity_bracket_6 "Maturity $\ge$ 40y"

gen amount_bracket_1 = gpf_amount_bracket=="1M to 5M"
gen amount_bracket_2 = gpf_amount_bracket=="5M to 10M"
gen amount_bracket_3 = gpf_amount_bracket=="10M to 50M"
gen amount_bracket_4 = gpf_amount_bracket=="50M to 100M"
gen amount_bracket_5 = gpf_amount_bracket=="Greater than 100M"

label var amount_bracket_1 "Amount in [1M, 5M)"
label var amount_bracket_2 "Amount in [5M, 10M)"
label var amount_bracket_3 "Amount in [10M, 50M)"
label var amount_bracket_4 "Amount in [50M, 100M)"
label var amount_bracket_5 "Amount $\ge$ 100M"

gen bidN = gpf_bid=="N"

label var bidN "Is Negotiated Sales"

gen taxT = gpf_taxable_code=="T"
gen taxA = gpf_taxable_code=="A"

label var taxT "Is Taxable"
label var taxA "Is Alternative Minimum Tax"

gen security_type_RV = gpf_security_type=="RV"

label var security_type_RV "Is REV"

reg insurefeeratio inc_to_avg pop_to_avg ///
maturity_bracket_1 maturity_bracket_2 maturity_bracket_3 maturity_bracket_4 maturity_bracket_5 maturity_bracket_6 ///
amount_bracket_1 amount_bracket_2 amount_bracket_3 amount_bracket_4 amount_bracket_5 ///
bidN taxT taxA security_type_RV

outreg2 using  "`outfile'", tex(fragment) append label ///
`outputoptions' ctitle("Insurance", "Fee (bps.)") ///
addstat("R-squared", e(r2)) drop(insureratio)

/* Column 3 */

import delimited "../CleanData/California/0H_CostSample_RegData_AdvisorRatio.csv", clear

label var inc_to_avg "Income"
label var pop_to_avg "Population"

gen maturity_bracket_1 = gpf_maturity_bracket=="2y to 5y"
gen maturity_bracket_2 = gpf_maturity_bracket=="5y to 10y"
gen maturity_bracket_3 = gpf_maturity_bracket=="10y to 20y"
gen maturity_bracket_4 = gpf_maturity_bracket=="20y to 30y"
gen maturity_bracket_5 = gpf_maturity_bracket=="30y to 40y"
gen maturity_bracket_6 = gpf_maturity_bracket=="Greater than 40y"

label var maturity_bracket_1 "Maturity in [2y, 5y)"
label var maturity_bracket_2 "Maturity in [5y, 10y)"
label var maturity_bracket_3 "Maturity in [10y, 20y)"
label var maturity_bracket_4 "Maturity in [20y, 30y)"
label var maturity_bracket_5 "Maturity in [30y, 40y)"
label var maturity_bracket_6 "Maturity $\ge$ 40y"

gen amount_bracket_1 = gpf_amount_bracket=="1M to 5M"
gen amount_bracket_2 = gpf_amount_bracket=="5M to 10M"
gen amount_bracket_3 = gpf_amount_bracket=="10M to 50M"
gen amount_bracket_4 = gpf_amount_bracket=="50M to 100M"
gen amount_bracket_5 = gpf_amount_bracket=="Greater than 100M"

label var amount_bracket_1 "Amount in [1M, 5M)"
label var amount_bracket_2 "Amount in [5M, 10M)"
label var amount_bracket_3 "Amount in [10M, 50M)"
label var amount_bracket_4 "Amount in [50M, 100M)"
label var amount_bracket_5 "Amount $\ge$ 100M"

gen bidN = gpf_bid=="N"

label var bidN "Is Negotiated Sales"

gen taxT = gpf_taxable_code=="T"
gen taxA = gpf_taxable_code=="A"

label var taxT "Is Taxable"
label var taxA "Is Alternative Minimum Tax"

gen security_type_RV = gpf_security_type=="RV"

label var security_type_RV "Is REV"

reg advisorfeeratio inc_to_avg pop_to_avg ///
maturity_bracket_1 maturity_bracket_2 maturity_bracket_3 maturity_bracket_4 maturity_bracket_5 maturity_bracket_6 ///
amount_bracket_1 amount_bracket_2 amount_bracket_3 amount_bracket_4 amount_bracket_5 ///
bidN taxT taxA security_type_RV

outreg2 using  "`outfile'", tex(fragment) append label ///
`outputoptions' ctitle("Financial Advisor", "Fee (bps.)") ///
addstat("R-squared", e(r2)) drop(advisorratio)

