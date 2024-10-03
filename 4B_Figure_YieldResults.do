
set scheme s1color



/* Figure: Plot with yield */

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen avg_yield_inbbps = avg_yield*10000

gen treasury_avg_spread_inbp = treasury_avg_spread*10000
gen mma_avg_spread_inbp = mma_avg_spread*10000

gen is_callable = if_callable=="Yes"
gen is_callable_m100 = is_callable*100

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

encode bid, gen(bid_code)

gen treatedXpostm2XN = treated==1&year_to_merger==-2&bid=="N"
gen treatedXpostm3XN = treated==1&year_to_merger==-3&bid=="N"
gen treatedXpostm4XN = treated==1&year_to_merger==-4&bid=="N"
gen treatedXpost0XN = treated==1&year_to_merger==0&bid=="N"
gen treatedXpost1XN = treated==1&year_to_merger==1&bid=="N"
gen treatedXpost2XN = treated==1&year_to_merger==2&bid=="N"
gen treatedXpost3XN = treated==1&year_to_merger==3&bid=="N"
gen treatedXpost4XN = treated==1&year_to_merger==4&bid=="N"

gen treatedXpostm2XP = treated==1&year_to_merger==-2&bid=="P"
gen treatedXpostm3XP = treated==1&year_to_merger==-3&bid=="P"
gen treatedXpostm4XP = treated==1&year_to_merger==-4&bid=="P"
gen treatedXpost0XP = treated==1&year_to_merger==0&bid=="P"
gen treatedXpost1XP = treated==1&year_to_merger==1&bid=="P"
gen treatedXpost2XP = treated==1&year_to_merger==2&bid=="P"
gen treatedXpost3XP = treated==1&year_to_merger==3&bid=="P"
gen treatedXpost4XP = treated==1&year_to_merger==4&bid=="P"

gen treatedXpostm2XC = treated==1&year_to_merger==-2&bid=="C"
gen treatedXpostm3XC = treated==1&year_to_merger==-3&bid=="C"
gen treatedXpostm4XC = treated==1&year_to_merger==-4&bid=="C"
gen treatedXpost0XC = treated==1&year_to_merger==0&bid=="C"
gen treatedXpost1XC = treated==1&year_to_merger==1&bid=="C"
gen treatedXpost2XC = treated==1&year_to_merger==2&bid=="C"
gen treatedXpost3XC = treated==1&year_to_merger==3&bid=="C"
gen treatedXpost4XC = treated==1&year_to_merger==4&bid=="C"

preserve

reghdfe avg_yield_inbbps treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

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

replace coef = coef
replace upper = upper
replace lower = lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on Reoffering Yield", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in bps.)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/Yield_Around_MA_impliedHHI.eps", replace

restore



/* Figure: Plot with yield spread over Treasury */

preserve

reghdfe treasury_avg_spread_inbp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

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

replace coef = coef
replace upper = upper
replace lower = lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on Reoffering Yield Spread", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in bps.)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/YieldSpreadTreasury_Around_MA_impliedHHI.eps", replace

restore



/* Figure: Plot with yield spread over MMA */

preserve

reghdfe mma_avg_spread_inbp treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

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

replace coef = coef
replace upper = upper
replace lower = lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on Reoffering Yield Spread", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in bps.)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/YieldSpreadMMA_Around_MA_impliedHHI.eps", replace

restore



/* Figure: Plot with initial underpricing */

preserve

reghdfe underpricing_15to30 treated post ///
treatedXpostm2 treatedXpostm3 treatedXpostm4 treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4 ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

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

replace coef = coef
replace upper = upper
replace lower = lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on Initial Underpricing", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in $)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/Underpricing_Around_MA_impliedHHI.eps", replace

restore




/* Figure: Plot with initial underpricing, separately for competitive bidding and negotiated sales */

// Under competitive bidding

preserve

reghdfe underpricing_15to30 bid_code##(treated post) ///
treatedXpostm2XC treatedXpostm3XC treatedXpostm4XC treatedXpost0XC treatedXpost1XC treatedXpost2XC treatedXpost3XC treatedXpost4XC ///
treatedXpostm2XP treatedXpostm3XP treatedXpostm4XP treatedXpost0XP treatedXpost1XP treatedXpost2XP treatedXpost3XP treatedXpost4XP ///
treatedXpostm2XN treatedXpostm3XN treatedXpostm4XN treatedXpost0XN treatedXpost1XN treatedXpost2XN treatedXpost3XN treatedXpost4XN ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

forvalues x = 2/4 {
local bm`x'= _b[treatedXpostm`x'XC]
local lbm`x' = _b[treatedXpostm`x'XC] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'XC] 
local ubm`x' = _b[treatedXpostm`x'XC] + invttail(e(df_r),0.025)*_se[treatedXpostm`x'XC]
}

forvalues x = 0/4 {
local b`x'= _b[treatedXpost`x'XC]
local lb`x' = _b[treatedXpost`x'XC] - invttail(e(df_r),0.025)*_se[treatedXpost`x'XC] 
local ub`x' = _b[treatedXpost`x'XC] + invttail(e(df_r),0.025)*_se[treatedXpost`x'XC]
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

replace coef = coef
replace upper = upper
replace lower = lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on Initial Underpricing", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in $)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/Underpricing_Around_MA_impliedHHI_C.eps", replace

restore

// Under negotiated sales

preserve

reghdfe underpricing_15to30 bid_code##(treated post) ///
treatedXpostm2XC treatedXpostm3XC treatedXpostm4XC treatedXpost0XC treatedXpost1XC treatedXpost2XC treatedXpost3XC treatedXpost4XC ///
treatedXpostm2XP treatedXpostm3XP treatedXpostm4XP treatedXpost0XP treatedXpost1XP treatedXpost2XP treatedXpost3XP treatedXpost4XP ///
treatedXpostm2XN treatedXpostm3XN treatedXpostm4XN treatedXpost0XN treatedXpost1XN treatedXpost2XN treatedXpost3XN treatedXpost4XN ///
if year_to_merger>=-4&year_to_merger<=4, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

forvalues x = 2/4 {
local bm`x'= _b[treatedXpostm`x'XN]
local lbm`x' = _b[treatedXpostm`x'XN] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'XN] 
local ubm`x' = _b[treatedXpostm`x'XN] + invttail(e(df_r),0.025)*_se[treatedXpostm`x'XN]
}

forvalues x = 0/4 {
local b`x'= _b[treatedXpost`x'XN]
local lb`x' = _b[treatedXpost`x'XN] - invttail(e(df_r),0.025)*_se[treatedXpost`x'XN] 
local ub`x' = _b[treatedXpost`x'XN] + invttail(e(df_r),0.025)*_se[treatedXpost`x'XN]
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

replace coef = coef
replace upper = upper
replace lower = lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on Initial Underpricing", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
ylabel(, labsize(large)) ///
legend(label(1 "Coef (in $)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Draft/figs/Underpricing_Around_MA_impliedHHI_N.eps", replace

restore

