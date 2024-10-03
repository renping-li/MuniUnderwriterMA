
set scheme s1color

/* Using implied HHI */

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

gen treatedXpostm2 = treated==1&year_to_merger==-2
gen treatedXpostm3 = treated==1&year_to_merger==-3
gen treatedXpostm4 = treated==1&year_to_merger==-4
gen treatedXpost0 = treated==1&year_to_merger==0
gen treatedXpost1 = treated==1&year_to_merger==1
gen treatedXpost2 = treated==1&year_to_merger==2
gen treatedXpost3 = treated==1&year_to_merger==3
gen treatedXpost4 = treated==1&year_to_merger==4

gen if_advisor_coded = if_advisor=="Yes"

gen has_rating = (has_fitch=="True")|(has_moodys=="True")

replace insured_amount = 0 if insured_amount==.
gen insured_ratio = insured_amount/amount
gen if_insured = insured_ratio>0

egen issuer_codeXissuer_type = group(issuer_code issuer_type)



/* Using if advisor */

preserve

reghdfe if_advisor_coded treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(issuer_code)

forvalues x = 2/4 {
local bm`x'= _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'] 
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x'= _b[treatedXpost`x']
local lb`x' = _b[treatedXpost`x'] - invttail(e(df_r),0.025)*_se[treatedXpost`x'] 
local ub`x' = _b[treatedXpost`x'] + invttail(e(df_r),0.025)*_se[treatedXpost`x']
}

clear
set obs 31
gen yeartochange = .
gen coef = .
gen upper = .
gen lower = .

replace yeartochange = -1 if _n == 1
replace coef = 0 if _n == 1
replace coef = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef = `bm`x'' if _n == `x'
replace lower = `lbm`x'' if _n == `x'
replace upper = `ubm`x'' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef = `b`x'' if _n == `x' + 5
replace lower = `lb`x'' if _n == `x' + 5
replace upper = `ub`x'' if _n == `x' + 5
}

sort yeartochange

replace coef = 10 * coef
replace upper = 10 * upper
replace lower = 10 * lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on If Using an Advisor", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in bps.)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/Efficiency_Advisor_Around_MA_impliedHHI.eps", replace

restore



/* Using if advisor, probit model */

preserve

probit if_advisor_coded treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
i.calendar_year, vce(cluster issuer_codeXissuer_type)

forvalues x = 2/4 {
local bm`x'= _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_m),0.025)*_se[treatedXpostm`x'] 
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_m),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x'= _b[treatedXpost`x']
local lb`x' = _b[treatedXpost`x'] - invttail(e(df_m),0.025)*_se[treatedXpost`x'] 
local ub`x' = _b[treatedXpost`x'] + invttail(e(df_m),0.025)*_se[treatedXpost`x']
}

clear
set obs 31
gen yeartochange = .
gen coef = .
gen upper = .
gen lower = .

replace yeartochange = -1 if _n == 1
replace coef = 0 if _n == 1
replace coef = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef = `bm`x'' if _n == `x'
replace lower = `lbm`x'' if _n == `x'
replace upper = `ubm`x'' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef = `b`x'' if _n == `x' + 5
replace lower = `lb`x'' if _n == `x' + 5
replace upper = `ub`x'' if _n == `x' + 5
}

sort yeartochange

replace coef = 10 * coef
replace upper = 10 * upper
replace lower = 10 * lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on If Using an Advisor", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Probit Coef") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/Efficiency_Advisor_Around_MA_impliedHHI_Probit.eps", replace

restore



/* Using if having rating */

preserve

reghdfe has_rating treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(issuer_code)

forvalues x = 2/4 {
local bm`x'= _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'] 
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x'= _b[treatedXpost`x']
local lb`x' = _b[treatedXpost`x'] - invttail(e(df_r),0.025)*_se[treatedXpost`x'] 
local ub`x' = _b[treatedXpost`x'] + invttail(e(df_r),0.025)*_se[treatedXpost`x']
}

clear
set obs 31
gen yeartochange = .
gen coef = .
gen upper = .
gen lower = .

replace yeartochange = -1 if _n == 1
replace coef = 0 if _n == 1
replace coef = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef = `bm`x'' if _n == `x'
replace lower = `lbm`x'' if _n == `x'
replace upper = `ubm`x'' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef = `b`x'' if _n == `x' + 5
replace lower = `lb`x'' if _n == `x' + 5
replace upper = `ub`x'' if _n == `x' + 5
}

sort yeartochange

replace coef = 10 * coef
replace upper = 10 * upper
replace lower = 10 * lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on If Having Credit Ratings", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in bps.)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/Efficiency_Rating_Around_MA_impliedHHI.eps", replace

restore



/* Using if having rating, probit model */

preserve

probit has_rating treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
i.calendar_year, vce(cluster issuer_codeXissuer_type)

forvalues x = 2/4 {
local bm`x'= _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_m),0.025)*_se[treatedXpostm`x'] 
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_m),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x'= _b[treatedXpost`x']
local lb`x' = _b[treatedXpost`x'] - invttail(e(df_m),0.025)*_se[treatedXpost`x'] 
local ub`x' = _b[treatedXpost`x'] + invttail(e(df_m),0.025)*_se[treatedXpost`x']
}

clear
set obs 31
gen yeartochange = .
gen coef = .
gen upper = .
gen lower = .

replace yeartochange = -1 if _n == 1
replace coef = 0 if _n == 1
replace coef = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef = `bm`x'' if _n == `x'
replace lower = `lbm`x'' if _n == `x'
replace upper = `ubm`x'' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef = `b`x'' if _n == `x' + 5
replace lower = `lb`x'' if _n == `x' + 5
replace upper = `ub`x'' if _n == `x' + 5
}

sort yeartochange

replace coef = 10 * coef
replace upper = 10 * upper
replace lower = 10 * lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on If Having Credit Ratings", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Probit Coef") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/Efficiency_Rating_Around_MA_impliedHHI_Probit.eps", replace

restore



/* Using insured ratio */

preserve

reghdfe insured_ratio treated post treatedXpostm2 treatedXpostm3 treatedXpostm4 treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(issuer_code)

forvalues x = 2/4 {
local bm`x'= _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'] 
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_r),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x'= _b[treatedXpost`x']
local lb`x' = _b[treatedXpost`x'] - invttail(e(df_r),0.025)*_se[treatedXpost`x'] 
local ub`x' = _b[treatedXpost`x'] + invttail(e(df_r),0.025)*_se[treatedXpost`x']
}

clear
set obs 31
gen yeartochange = .
gen coef = .
gen upper = .
gen lower = .

replace yeartochange = -1 if _n == 1
replace coef = 0 if _n == 1
replace coef = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef = `bm`x'' if _n == `x'
replace lower = `lbm`x'' if _n == `x'
replace upper = `ubm`x'' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef = `b`x'' if _n == `x' + 5
replace lower = `lb`x'' if _n == `x' + 5
replace upper = `ub`x'' if _n == `x' + 5
}

sort yeartochange

replace coef = 10 * coef
replace upper = 10 * upper
replace lower = 10 * lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on Insured Ratio", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in bps.)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/Efficiency_Insured_Around_MA_impliedHHI.eps", replace

restore




/* Using if insured, probit model */

preserve

probit if_insured treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
i.calendar_year, vce(cluster issuer_codeXissuer_type)

forvalues x = 2/4 {
local bm`x'= _b[treatedXpostm`x']
local lbm`x' = _b[treatedXpostm`x'] - invttail(e(df_m),0.025)*_se[treatedXpostm`x'] 
local ubm`x' = _b[treatedXpostm`x'] + invttail(e(df_m),0.025)*_se[treatedXpostm`x']
}

forvalues x = 0/4 {
local b`x'= _b[treatedXpost`x']
local lb`x' = _b[treatedXpost`x'] - invttail(e(df_m),0.025)*_se[treatedXpost`x'] 
local ub`x' = _b[treatedXpost`x'] + invttail(e(df_m),0.025)*_se[treatedXpost`x']
}

clear
set obs 31
gen yeartochange = .
gen coef = .
gen upper = .
gen lower = .

replace yeartochange = -1 if _n == 1
replace coef = 0 if _n == 1
replace coef = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef = `bm`x'' if _n == `x'
replace lower = `lbm`x'' if _n == `x'
replace upper = `ubm`x'' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef = `b`x'' if _n == `x' + 5
replace lower = `lb`x'' if _n == `x' + 5
replace upper = `ub`x'' if _n == `x' + 5
}

sort yeartochange

replace coef = 10 * coef
replace upper = 10 * upper
replace lower = 10 * lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on If Insured", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Probit Coef") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/Efficiency_Insured_Around_MA_impliedHHI_Probit.eps", replace

restore
