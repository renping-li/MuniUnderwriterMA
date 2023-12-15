
// Notes:
// (1) Yield figure patterns are more clear if use two control areas.

set scheme s1color





/* Figure: Using implied HHI, split sample one way by HHI */

set scheme s1color

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear 

gen avg_yield_inbbps = avg_yield*10000

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

drop if if_yield_from_nic=="True"

gen treatedXpostm2 = treated==1&year_to_merger==-2
gen treatedXpostm3 = treated==1&year_to_merger==-3
gen treatedXpostm4 = treated==1&year_to_merger==-4
gen treatedXpost0 = treated==1&year_to_merger==0
gen treatedXpost1 = treated==1&year_to_merger==1
gen treatedXpost2 = treated==1&year_to_merger==2
gen treatedXpost3 = treated==1&year_to_merger==3
gen treatedXpost4 = treated==1&year_to_merger==4

bysort county: egen avghhi_by_n = mean(hhi_by_n)
sum avghhi_by_n, d
gen top_hhi_by_n = avghhi_by_n>0.1

gen treatedXpostm2Xtop_hhi_by_n = treatedXpostm2*top_hhi_by_n
gen treatedXpostm3Xtop_hhi_by_n = treatedXpostm3*top_hhi_by_n
gen treatedXpostm4Xtop_hhi_by_n = treatedXpostm4*top_hhi_by_n
gen treatedXpost0Xtop_hhi_by_n = treatedXpost0*top_hhi_by_n
gen treatedXpost1Xtop_hhi_by_n = treatedXpost1*top_hhi_by_n
gen treatedXpost2Xtop_hhi_by_n = treatedXpost2*top_hhi_by_n
gen treatedXpost3Xtop_hhi_by_n = treatedXpost3*top_hhi_by_n
gen treatedXpost4Xtop_hhi_by_n = treatedXpost4*top_hhi_by_n

gen bottom_hhi_by_n = (1-top_hhi_by_n)
gen treatedXpostm2Xbottom_hhi_by_n = treatedXpostm2*bottom_hhi_by_n
gen treatedXpostm3Xbottom_hhi_by_n = treatedXpostm3*bottom_hhi_by_n
gen treatedXpostm4Xbottom_hhi_by_n = treatedXpostm4*bottom_hhi_by_n
gen treatedXpost0Xbottom_hhi_by_n = treatedXpost0*bottom_hhi_by_n
gen treatedXpost1Xbottom_hhi_by_n = treatedXpost1*bottom_hhi_by_n
gen treatedXpost2Xbottom_hhi_by_n = treatedXpost2*bottom_hhi_by_n
gen treatedXpost3Xbottom_hhi_by_n = treatedXpost3*bottom_hhi_by_n
gen treatedXpost4Xbottom_hhi_by_n = treatedXpost4*bottom_hhi_by_n

preserve

reghdfe avg_yield_inbbps ///
(i.treated i.post)##(i.top_hhi_by_n) ///
treatedXpostm2Xtop_hhi_by_n treatedXpostm3Xtop_hhi_by_n treatedXpostm4Xtop_hhi_by_n ///
treatedXpost0Xtop_hhi_by_n treatedXpost1Xtop_hhi_by_n treatedXpost2Xtop_hhi_by_n treatedXpost3Xtop_hhi_by_n treatedXpost4Xtop_hhi_by_n ///
treatedXpostm2Xbottom_hhi_by_n treatedXpostm3Xbottom_hhi_by_n treatedXpostm4Xbottom_hhi_by_n ///
treatedXpost0Xbottom_hhi_by_n treatedXpost1Xbottom_hhi_by_n treatedXpost2Xbottom_hhi_by_n treatedXpost3Xbottom_hhi_by_n treatedXpost4Xbottom_hhi_by_n ///
, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(issuer_code)

forvalues x = 2/4 {
local bm`x'_tophhi = _b[treatedXpostm`x'Xtop_hhi_by_n]
local lbm`x'_tophhi = _b[treatedXpostm`x'Xtop_hhi_by_n] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'Xtop_hhi_by_n] 
local ubm`x'_tophhi = _b[treatedXpostm`x'Xtop_hhi_by_n] + invttail(e(df_r),0.025)*_se[treatedXpostm`x'Xtop_hhi_by_n]
}

forvalues x = 0/4 {
local b`x'_tophhi = _b[treatedXpost`x'Xtop_hhi_by_n]
local lb`x'_tophhi = _b[treatedXpost`x'Xtop_hhi_by_n] - invttail(e(df_r),0.025)*_se[treatedXpost`x'Xtop_hhi_by_n] 
local ub`x'_tophhi = _b[treatedXpost`x'Xtop_hhi_by_n] + invttail(e(df_r),0.025)*_se[treatedXpost`x'Xtop_hhi_by_n]
}

forvalues x = 2/4 {
local bm`x'_bottomhhi = _b[treatedXpostm`x'Xbottom_hhi_by_n]
local lbm`x'_bottomhhi = _b[treatedXpostm`x'Xbottom_hhi_by_n] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'Xbottom_hhi_by_n] 
local ubm`x'_bottomhhi = _b[treatedXpostm`x'Xbottom_hhi_by_n] + invttail(e(df_r),0.025)*_se[treatedXpostm`x'Xbottom_hhi_by_n]
}

forvalues x = 0/4 {
local b`x'_bottomhhi = _b[treatedXpost`x'Xbottom_hhi_by_n]
local lb`x'_bottomhhi = _b[treatedXpost`x'Xbottom_hhi_by_n] - invttail(e(df_r),0.025)*_se[treatedXpost`x'Xbottom_hhi_by_n] 
local ub`x'_bottomhhi = _b[treatedXpost`x'Xbottom_hhi_by_n] + invttail(e(df_r),0.025)*_se[treatedXpost`x'Xbottom_hhi_by_n]
}

clear
set obs 31
gen yeartochange = .

replace yeartochange = -1 if _n == 1

gen coef_tophhi = .
gen upper_tophhi = .
gen lower_tophhi = .

replace coef_tophhi = 0 if _n == 1
replace coef_tophhi = 0 if _n == 1

gen coef_bottomhhi = .
gen upper_bottomhhi = .
gen lower_bottomhhi = .

replace coef_bottomhhi = 0 if _n == 1
replace coef_bottomhhi = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef_tophhi = `bm`x'_tophhi' if _n == `x'
replace lower_tophhi = `lbm`x'_tophhi' if _n == `x'
replace upper_tophhi = `ubm`x'_tophhi' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef_tophhi = `b`x'_tophhi' if _n == `x' + 5
replace lower_tophhi = `lb`x'_tophhi' if _n == `x' + 5
replace upper_tophhi = `ub`x'_tophhi' if _n == `x' + 5
}

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef_bottomhhi = `bm`x'_bottomhhi' if _n == `x'
replace lower_bottomhhi = `lbm`x'_bottomhhi' if _n == `x'
replace upper_bottomhhi = `ubm`x'_bottomhhi' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef_bottomhhi = `b`x'_bottomhhi' if _n == `x' + 5
replace lower_bottomhhi = `lb`x'_bottomhhi' if _n == `x' + 5
replace upper_bottomhhi = `ub`x'_bottomhhi' if _n == `x' + 5
}

list

sort yeartochange

replace coef_tophhi = coef_tophhi
replace upper_tophhi = upper_tophhi
replace lower_tophhi = lower_tophhi

replace coef_bottomhhi = coef_bottomhhi
replace upper_bottomhhi = upper_bottomhhi
replace lower_bottomhhi = lower_bottomhhi

gen yeartochange_right = yeartochange+0.1

// Plot only for HHI > 1000
graph twoway ///
(scatter coef_tophhi yeartochange, msize(small) mcolor(red)) (rcap upper_tophhi lower_tophhi yeartochange, lcolor(red)), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on offering yield", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in bps.), HHI > 1000") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/Yield_Around_MA_impliedHHI_SlicedHHI.eps", replace

/// (scatter coef_bottomhhi yeartochange_right, msize(small) mcolor(blue)) (rcap upper_bottomhhi lower_bottomhhi yeartochange_right, lcolor(blue)), ///
/// label(3 "Coef (in bps.), HHI < 1000") label(4 "95% CI")

restore





/* Figure: Using market share, split sample one way by HHI */

import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear 

gen avg_yield_inbbps = avg_yield*10000

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

drop if if_yield_from_nic=="True"

gen treatedXpostm2 = treated==1&year_to_merger==-2
gen treatedXpostm3 = treated==1&year_to_merger==-3
gen treatedXpostm4 = treated==1&year_to_merger==-4
gen treatedXpost0 = treated==1&year_to_merger==0
gen treatedXpost1 = treated==1&year_to_merger==1
gen treatedXpost2 = treated==1&year_to_merger==2
gen treatedXpost3 = treated==1&year_to_merger==3
gen treatedXpost4 = treated==1&year_to_merger==4

bysort county: egen avghhi_by_n = mean(hhi_by_n)
sum avghhi_by_n, d
gen top_hhi_by_n = avghhi_by_n>0.1

gen treatedXpostm2Xtop_hhi_by_n = treatedXpostm2*top_hhi_by_n
gen treatedXpostm3Xtop_hhi_by_n = treatedXpostm3*top_hhi_by_n
gen treatedXpostm4Xtop_hhi_by_n = treatedXpostm4*top_hhi_by_n
gen treatedXpost0Xtop_hhi_by_n = treatedXpost0*top_hhi_by_n
gen treatedXpost1Xtop_hhi_by_n = treatedXpost1*top_hhi_by_n
gen treatedXpost2Xtop_hhi_by_n = treatedXpost2*top_hhi_by_n
gen treatedXpost3Xtop_hhi_by_n = treatedXpost3*top_hhi_by_n
gen treatedXpost4Xtop_hhi_by_n = treatedXpost4*top_hhi_by_n

gen bottom_hhi_by_n = (1-top_hhi_by_n)
gen treatedXpostm2Xbottom_hhi_by_n = treatedXpostm2*bottom_hhi_by_n
gen treatedXpostm3Xbottom_hhi_by_n = treatedXpostm3*bottom_hhi_by_n
gen treatedXpostm4Xbottom_hhi_by_n = treatedXpostm4*bottom_hhi_by_n
gen treatedXpost0Xbottom_hhi_by_n = treatedXpost0*bottom_hhi_by_n
gen treatedXpost1Xbottom_hhi_by_n = treatedXpost1*bottom_hhi_by_n
gen treatedXpost2Xbottom_hhi_by_n = treatedXpost2*bottom_hhi_by_n
gen treatedXpost3Xbottom_hhi_by_n = treatedXpost3*bottom_hhi_by_n
gen treatedXpost4Xbottom_hhi_by_n = treatedXpost4*bottom_hhi_by_n

preserve

reghdfe avg_yield_inbbps ///
(i.treated i.post)##(i.top_hhi_by_n) ///
treatedXpostm2Xtop_hhi_by_n treatedXpostm3Xtop_hhi_by_n treatedXpostm4Xtop_hhi_by_n ///
treatedXpost0Xtop_hhi_by_n treatedXpost1Xtop_hhi_by_n treatedXpost2Xtop_hhi_by_n treatedXpost3Xtop_hhi_by_n treatedXpost4Xtop_hhi_by_n ///
treatedXpostm2Xbottom_hhi_by_n treatedXpostm3Xbottom_hhi_by_n treatedXpostm4Xbottom_hhi_by_n ///
treatedXpost0Xbottom_hhi_by_n treatedXpost1Xbottom_hhi_by_n treatedXpost2Xbottom_hhi_by_n treatedXpost3Xbottom_hhi_by_n treatedXpost4Xbottom_hhi_by_n ///
, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(issuer_code)

forvalues x = 2/4 {
local bm`x'_tophhi = _b[treatedXpostm`x'Xtop_hhi_by_n]
local lbm`x'_tophhi = _b[treatedXpostm`x'Xtop_hhi_by_n] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'Xtop_hhi_by_n] 
local ubm`x'_tophhi = _b[treatedXpostm`x'Xtop_hhi_by_n] + invttail(e(df_r),0.025)*_se[treatedXpostm`x'Xtop_hhi_by_n]
}

forvalues x = 0/4 {
local b`x'_tophhi = _b[treatedXpost`x'Xtop_hhi_by_n]
local lb`x'_tophhi = _b[treatedXpost`x'Xtop_hhi_by_n] - invttail(e(df_r),0.025)*_se[treatedXpost`x'Xtop_hhi_by_n] 
local ub`x'_tophhi = _b[treatedXpost`x'Xtop_hhi_by_n] + invttail(e(df_r),0.025)*_se[treatedXpost`x'Xtop_hhi_by_n]
}

forvalues x = 2/4 {
local bm`x'_bottomhhi = _b[treatedXpostm`x'Xbottom_hhi_by_n]
local lbm`x'_bottomhhi = _b[treatedXpostm`x'Xbottom_hhi_by_n] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'Xbottom_hhi_by_n] 
local ubm`x'_bottomhhi = _b[treatedXpostm`x'Xbottom_hhi_by_n] + invttail(e(df_r),0.025)*_se[treatedXpostm`x'Xbottom_hhi_by_n]
}

forvalues x = 0/4 {
local b`x'_bottomhhi = _b[treatedXpost`x'Xbottom_hhi_by_n]
local lb`x'_bottomhhi = _b[treatedXpost`x'Xbottom_hhi_by_n] - invttail(e(df_r),0.025)*_se[treatedXpost`x'Xbottom_hhi_by_n] 
local ub`x'_bottomhhi = _b[treatedXpost`x'Xbottom_hhi_by_n] + invttail(e(df_r),0.025)*_se[treatedXpost`x'Xbottom_hhi_by_n]
}

clear
set obs 31
gen yeartochange = .

replace yeartochange = -1 if _n == 1

gen coef_tophhi = .
gen upper_tophhi = .
gen lower_tophhi = .

replace coef_tophhi = 0 if _n == 1
replace coef_tophhi = 0 if _n == 1

gen coef_bottomhhi = .
gen upper_bottomhhi = .
gen lower_bottomhhi = .

replace coef_bottomhhi = 0 if _n == 1
replace coef_bottomhhi = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef_tophhi = `bm`x'_tophhi' if _n == `x'
replace lower_tophhi = `lbm`x'_tophhi' if _n == `x'
replace upper_tophhi = `ubm`x'_tophhi' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef_tophhi = `b`x'_tophhi' if _n == `x' + 5
replace lower_tophhi = `lb`x'_tophhi' if _n == `x' + 5
replace upper_tophhi = `ub`x'_tophhi' if _n == `x' + 5
}

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef_bottomhhi = `bm`x'_bottomhhi' if _n == `x'
replace lower_bottomhhi = `lbm`x'_bottomhhi' if _n == `x'
replace upper_bottomhhi = `ubm`x'_bottomhhi' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef_bottomhhi = `b`x'_bottomhhi' if _n == `x' + 5
replace lower_bottomhhi = `lb`x'_bottomhhi' if _n == `x' + 5
replace upper_bottomhhi = `ub`x'_bottomhhi' if _n == `x' + 5
}

list

sort yeartochange

replace coef_tophhi = coef_tophhi
replace upper_tophhi = upper_tophhi
replace lower_tophhi = lower_tophhi

replace coef_bottomhhi = coef_bottomhhi
replace upper_bottomhhi = upper_bottomhhi
replace lower_bottomhhi = lower_bottomhhi

gen yeartochange_right = yeartochange+0.1

// Plot only for HHI > 1000
graph twoway ///
(scatter coef_tophhi yeartochange, msize(small) mcolor(red)) (rcap upper_tophhi lower_tophhi yeartochange, lcolor(red)), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on offering yield", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in bps.), HHI > 1000") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/Yield_Around_MA_matketshare_SlicedHHI.eps", replace

/// (scatter coef_bottomhhi yeartochange_right, msize(small) mcolor(blue)) (rcap upper_bottomhhi lower_bottomhhi yeartochange_right, lcolor(blue)), ///
/// label(3 "Coef (in bps.), HHI < 1000") label(4 "95% CI")

restore






/* Figure: Using implied HHI, split sample one way by HHI, using two matches */

set scheme s1color

import delimited "../CleanData/MAEvent/CSA_TwoMatch_episodes_impliedHHIByN.csv", clear 

gen avg_yield_inbbps = avg_yield*10000

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

bysort county: egen avghhi_by_n = mean(hhi_by_n)
sum avghhi_by_n, d
gen top_hhi_by_n = avghhi_by_n>0.1

gen treatedXpostm2Xtop_hhi_by_n = treatedXpostm2*top_hhi_by_n
gen treatedXpostm3Xtop_hhi_by_n = treatedXpostm3*top_hhi_by_n
gen treatedXpostm4Xtop_hhi_by_n = treatedXpostm4*top_hhi_by_n
gen treatedXpost0Xtop_hhi_by_n = treatedXpost0*top_hhi_by_n
gen treatedXpost1Xtop_hhi_by_n = treatedXpost1*top_hhi_by_n
gen treatedXpost2Xtop_hhi_by_n = treatedXpost2*top_hhi_by_n
gen treatedXpost3Xtop_hhi_by_n = treatedXpost3*top_hhi_by_n
gen treatedXpost4Xtop_hhi_by_n = treatedXpost4*top_hhi_by_n

gen bottom_hhi_by_n = (1-top_hhi_by_n)
gen treatedXpostm2Xbottom_hhi_by_n = treatedXpostm2*bottom_hhi_by_n
gen treatedXpostm3Xbottom_hhi_by_n = treatedXpostm3*bottom_hhi_by_n
gen treatedXpostm4Xbottom_hhi_by_n = treatedXpostm4*bottom_hhi_by_n
gen treatedXpost0Xbottom_hhi_by_n = treatedXpost0*bottom_hhi_by_n
gen treatedXpost1Xbottom_hhi_by_n = treatedXpost1*bottom_hhi_by_n
gen treatedXpost2Xbottom_hhi_by_n = treatedXpost2*bottom_hhi_by_n
gen treatedXpost3Xbottom_hhi_by_n = treatedXpost3*bottom_hhi_by_n
gen treatedXpost4Xbottom_hhi_by_n = treatedXpost4*bottom_hhi_by_n

drop if if_yield_from_nic=="True"

preserve

reghdfe avg_yield_inbbps ///
(i.treated i.post)##(i.top_hhi_by_n) ///
treatedXpostm2Xtop_hhi_by_n treatedXpostm3Xtop_hhi_by_n treatedXpostm4Xtop_hhi_by_n ///
treatedXpost0Xtop_hhi_by_n treatedXpost1Xtop_hhi_by_n treatedXpost2Xtop_hhi_by_n treatedXpost3Xtop_hhi_by_n treatedXpost4Xtop_hhi_by_n ///
treatedXpostm2Xbottom_hhi_by_n treatedXpostm3Xbottom_hhi_by_n treatedXpostm4Xbottom_hhi_by_n ///
treatedXpost0Xbottom_hhi_by_n treatedXpost1Xbottom_hhi_by_n treatedXpost2Xbottom_hhi_by_n treatedXpost3Xbottom_hhi_by_n treatedXpost4Xbottom_hhi_by_n ///
, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(issuer_code)

forvalues x = 2/4 {
local bm`x'_tophhi = _b[treatedXpostm`x'Xtop_hhi_by_n]
local lbm`x'_tophhi = _b[treatedXpostm`x'Xtop_hhi_by_n] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'Xtop_hhi_by_n] 
local ubm`x'_tophhi = _b[treatedXpostm`x'Xtop_hhi_by_n] + invttail(e(df_r),0.025)*_se[treatedXpostm`x'Xtop_hhi_by_n]
}

forvalues x = 0/4 {
local b`x'_tophhi = _b[treatedXpost`x'Xtop_hhi_by_n]
local lb`x'_tophhi = _b[treatedXpost`x'Xtop_hhi_by_n] - invttail(e(df_r),0.025)*_se[treatedXpost`x'Xtop_hhi_by_n] 
local ub`x'_tophhi = _b[treatedXpost`x'Xtop_hhi_by_n] + invttail(e(df_r),0.025)*_se[treatedXpost`x'Xtop_hhi_by_n]
}

forvalues x = 2/4 {
local bm`x'_bottomhhi = _b[treatedXpostm`x'Xbottom_hhi_by_n]
local lbm`x'_bottomhhi = _b[treatedXpostm`x'Xbottom_hhi_by_n] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'Xbottom_hhi_by_n] 
local ubm`x'_bottomhhi = _b[treatedXpostm`x'Xbottom_hhi_by_n] + invttail(e(df_r),0.025)*_se[treatedXpostm`x'Xbottom_hhi_by_n]
}

forvalues x = 0/4 {
local b`x'_bottomhhi = _b[treatedXpost`x'Xbottom_hhi_by_n]
local lb`x'_bottomhhi = _b[treatedXpost`x'Xbottom_hhi_by_n] - invttail(e(df_r),0.025)*_se[treatedXpost`x'Xbottom_hhi_by_n] 
local ub`x'_bottomhhi = _b[treatedXpost`x'Xbottom_hhi_by_n] + invttail(e(df_r),0.025)*_se[treatedXpost`x'Xbottom_hhi_by_n]
}

clear
set obs 31
gen yeartochange = .

replace yeartochange = -1 if _n == 1

gen coef_tophhi = .
gen upper_tophhi = .
gen lower_tophhi = .

replace coef_tophhi = 0 if _n == 1
replace coef_tophhi = 0 if _n == 1

gen coef_bottomhhi = .
gen upper_bottomhhi = .
gen lower_bottomhhi = .

replace coef_bottomhhi = 0 if _n == 1
replace coef_bottomhhi = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef_tophhi = `bm`x'_tophhi' if _n == `x'
replace lower_tophhi = `lbm`x'_tophhi' if _n == `x'
replace upper_tophhi = `ubm`x'_tophhi' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef_tophhi = `b`x'_tophhi' if _n == `x' + 5
replace lower_tophhi = `lb`x'_tophhi' if _n == `x' + 5
replace upper_tophhi = `ub`x'_tophhi' if _n == `x' + 5
}

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef_bottomhhi = `bm`x'_bottomhhi' if _n == `x'
replace lower_bottomhhi = `lbm`x'_bottomhhi' if _n == `x'
replace upper_bottomhhi = `ubm`x'_bottomhhi' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef_bottomhhi = `b`x'_bottomhhi' if _n == `x' + 5
replace lower_bottomhhi = `lb`x'_bottomhhi' if _n == `x' + 5
replace upper_bottomhhi = `ub`x'_bottomhhi' if _n == `x' + 5
}

list

sort yeartochange

replace coef_tophhi = coef_tophhi
replace upper_tophhi = upper_tophhi
replace lower_tophhi = lower_tophhi

replace coef_bottomhhi = coef_bottomhhi
replace upper_bottomhhi = upper_bottomhhi
replace lower_bottomhhi = lower_bottomhhi

gen yeartochange_right = yeartochange+0.1

// Plot only for HHI > 1000
graph twoway ///
(scatter coef_tophhi yeartochange, msize(small) mcolor(red)) (rcap upper_tophhi lower_tophhi yeartochange, lcolor(red)), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on offering yield", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in bps.), HHI > 1000") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/Yield_Around_MA_impliedHHI_SlicedHHI_TwoMatch.eps", replace

/// (scatter coef_bottomhhi yeartochange_right, msize(small) mcolor(blue)) (rcap upper_bottomhhi lower_bottomhhi yeartochange_right, lcolor(blue)), ///
/// label(3 "Coef (in bps.), HHI < 1000") label(4 "95% CI")

restore





/* Figure: Using market share, split sample one way by HHI */

set scheme s1color

import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear 

gen avg_yield_inbbps = avg_yield*10000

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

bysort county: egen avghhi_by_n = mean(hhi_by_n)
sum avghhi_by_n, d
gen top_hhi_by_n = avghhi_by_n>0.1

gen treatedXpostm2Xtop_hhi_by_n = treatedXpostm2*top_hhi_by_n
gen treatedXpostm3Xtop_hhi_by_n = treatedXpostm3*top_hhi_by_n
gen treatedXpostm4Xtop_hhi_by_n = treatedXpostm4*top_hhi_by_n
gen treatedXpost0Xtop_hhi_by_n = treatedXpost0*top_hhi_by_n
gen treatedXpost1Xtop_hhi_by_n = treatedXpost1*top_hhi_by_n
gen treatedXpost2Xtop_hhi_by_n = treatedXpost2*top_hhi_by_n
gen treatedXpost3Xtop_hhi_by_n = treatedXpost3*top_hhi_by_n
gen treatedXpost4Xtop_hhi_by_n = treatedXpost4*top_hhi_by_n

gen bottom_hhi_by_n = (1-top_hhi_by_n)
gen treatedXpostm2Xbottom_hhi_by_n = treatedXpostm2*bottom_hhi_by_n
gen treatedXpostm3Xbottom_hhi_by_n = treatedXpostm3*bottom_hhi_by_n
gen treatedXpostm4Xbottom_hhi_by_n = treatedXpostm4*bottom_hhi_by_n
gen treatedXpost0Xbottom_hhi_by_n = treatedXpost0*bottom_hhi_by_n
gen treatedXpost1Xbottom_hhi_by_n = treatedXpost1*bottom_hhi_by_n
gen treatedXpost2Xbottom_hhi_by_n = treatedXpost2*bottom_hhi_by_n
gen treatedXpost3Xbottom_hhi_by_n = treatedXpost3*bottom_hhi_by_n
gen treatedXpost4Xbottom_hhi_by_n = treatedXpost4*bottom_hhi_by_n

drop if if_yield_from_nic=="True"

preserve

reghdfe avg_yield_inbbps ///
(i.treated i.post)##(i.top_hhi_by_n) ///
treatedXpostm2Xtop_hhi_by_n treatedXpostm3Xtop_hhi_by_n treatedXpostm4Xtop_hhi_by_n ///
treatedXpost0Xtop_hhi_by_n treatedXpost1Xtop_hhi_by_n treatedXpost2Xtop_hhi_by_n treatedXpost3Xtop_hhi_by_n treatedXpost4Xtop_hhi_by_n ///
treatedXpostm2Xbottom_hhi_by_n treatedXpostm3Xbottom_hhi_by_n treatedXpostm4Xbottom_hhi_by_n ///
treatedXpost0Xbottom_hhi_by_n treatedXpost1Xbottom_hhi_by_n treatedXpost2Xbottom_hhi_by_n treatedXpost3Xbottom_hhi_by_n treatedXpost4Xbottom_hhi_by_n ///
, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(issuer_code)

forvalues x = 2/4 {
local bm`x'_tophhi = _b[treatedXpostm`x'Xtop_hhi_by_n]
local lbm`x'_tophhi = _b[treatedXpostm`x'Xtop_hhi_by_n] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'Xtop_hhi_by_n] 
local ubm`x'_tophhi = _b[treatedXpostm`x'Xtop_hhi_by_n] + invttail(e(df_r),0.025)*_se[treatedXpostm`x'Xtop_hhi_by_n]
}

forvalues x = 0/4 {
local b`x'_tophhi = _b[treatedXpost`x'Xtop_hhi_by_n]
local lb`x'_tophhi = _b[treatedXpost`x'Xtop_hhi_by_n] - invttail(e(df_r),0.025)*_se[treatedXpost`x'Xtop_hhi_by_n] 
local ub`x'_tophhi = _b[treatedXpost`x'Xtop_hhi_by_n] + invttail(e(df_r),0.025)*_se[treatedXpost`x'Xtop_hhi_by_n]
}

forvalues x = 2/4 {
local bm`x'_bottomhhi = _b[treatedXpostm`x'Xbottom_hhi_by_n]
local lbm`x'_bottomhhi = _b[treatedXpostm`x'Xbottom_hhi_by_n] - invttail(e(df_r),0.025)*_se[treatedXpostm`x'Xbottom_hhi_by_n] 
local ubm`x'_bottomhhi = _b[treatedXpostm`x'Xbottom_hhi_by_n] + invttail(e(df_r),0.025)*_se[treatedXpostm`x'Xbottom_hhi_by_n]
}

forvalues x = 0/4 {
local b`x'_bottomhhi = _b[treatedXpost`x'Xbottom_hhi_by_n]
local lb`x'_bottomhhi = _b[treatedXpost`x'Xbottom_hhi_by_n] - invttail(e(df_r),0.025)*_se[treatedXpost`x'Xbottom_hhi_by_n] 
local ub`x'_bottomhhi = _b[treatedXpost`x'Xbottom_hhi_by_n] + invttail(e(df_r),0.025)*_se[treatedXpost`x'Xbottom_hhi_by_n]
}

clear
set obs 31
gen yeartochange = .

replace yeartochange = -1 if _n == 1

gen coef_tophhi = .
gen upper_tophhi = .
gen lower_tophhi = .

replace coef_tophhi = 0 if _n == 1
replace coef_tophhi = 0 if _n == 1

gen coef_bottomhhi = .
gen upper_bottomhhi = .
gen lower_bottomhhi = .

replace coef_bottomhhi = 0 if _n == 1
replace coef_bottomhhi = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef_tophhi = `bm`x'_tophhi' if _n == `x'
replace lower_tophhi = `lbm`x'_tophhi' if _n == `x'
replace upper_tophhi = `ubm`x'_tophhi' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef_tophhi = `b`x'_tophhi' if _n == `x' + 5
replace lower_tophhi = `lb`x'_tophhi' if _n == `x' + 5
replace upper_tophhi = `ub`x'_tophhi' if _n == `x' + 5
}

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef_bottomhhi = `bm`x'_bottomhhi' if _n == `x'
replace lower_bottomhhi = `lbm`x'_bottomhhi' if _n == `x'
replace upper_bottomhhi = `ubm`x'_bottomhhi' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef_bottomhhi = `b`x'_bottomhhi' if _n == `x' + 5
replace lower_bottomhhi = `lb`x'_bottomhhi' if _n == `x' + 5
replace upper_bottomhhi = `ub`x'_bottomhhi' if _n == `x' + 5
}

list

sort yeartochange

replace coef_tophhi = coef_tophhi
replace upper_tophhi = upper_tophhi
replace lower_tophhi = lower_tophhi

replace coef_bottomhhi = coef_bottomhhi
replace upper_bottomhhi = upper_bottomhhi
replace lower_bottomhhi = lower_bottomhhi

gen yeartochange_right = yeartochange+0.1

// Plot only for HHI > 1000
graph twoway ///
(scatter coef_tophhi yeartochange, msize(small) mcolor(red)) (rcap upper_tophhi lower_tophhi yeartochange, lcolor(red)), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on offering yield", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in bps.), HHI > 1000") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/Yield_Around_MA_marketshare_SlicedHHI.eps", replace

/// (scatter coef_bottomhhi yeartochange_right, msize(small) mcolor(blue)) (rcap upper_bottomhhi lower_bottomhhi yeartochange_right, lcolor(blue)), ///
/// label(3 "Coef (in bps.), HHI < 1000") label(4 "95% CI")

restore





/* Figure: Using implied HHI, no sample split */

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen avg_yield_inbbps = avg_yield*10000

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

bysort county: egen avghhi_by_n = mean(hhi_by_n)
sum avghhi_by_n, d

drop if if_yield_from_nic=="True"

preserve

reghdfe avg_yield_inbbps treated post ///
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

replace coef = coef
replace upper = upper
replace lower = lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on offering yield", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in bps.)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/Yield_Around_MA_marketshare.eps", replace

restore




/* Figure: Using market share, no sample split */

import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear

gen avg_yield_inbbps = avg_yield*10000

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

bysort county: egen avghhi_by_n = mean(hhi_by_n)
sum avghhi_by_n, d

drop if if_yield_from_nic=="True"

preserve

reghdfe avg_yield_inbbps treated post ///
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

replace coef = coef
replace upper = upper
replace lower = lower

graph twoway ///
(scatter coef yeartochange, msize(small) mcolor(red)) (rcap upper lower yeartochange), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on offering yield", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in bps.)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/Yield_Around_MA_marketshare.eps", replace

restore




/* Figure: Using market share, split sample two ways by both HHI and size of merger */

import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear 

gen avg_yield_inbbps = avg_yield*10000

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

bysort county: egen avghhi_by_n = mean(hhi_by_n)
gen top_hhi_by_n = avghhi_by_n>0.1
gen bottom_hhi_by_n = (1-top_hhi_by_n)

gen top_max_share = max_sum_share>0.15&max_sum_share!=.
gen bottom_max_share = (1-top_max_share)

gen TXPm2Xtop_hhi_by_n_top_MS = treatedXpostm2*top_hhi_by_n*top_max_share
gen TXPm3Xtop_hhi_by_n_top_MS = treatedXpostm3*top_hhi_by_n*top_max_share
gen TXPm4Xtop_hhi_by_n_top_MS = treatedXpostm4*top_hhi_by_n*top_max_share
gen TXP0Xtop_hhi_by_n_top_MS = treatedXpost0*top_hhi_by_n*top_max_share
gen TXP1Xtop_hhi_by_n_top_MS = treatedXpost1*top_hhi_by_n*top_max_share
gen TXP2Xtop_hhi_by_n_top_MS = treatedXpost2*top_hhi_by_n*top_max_share
gen TXP3Xtop_hhi_by_n_top_MS = treatedXpost3*top_hhi_by_n*top_max_share
gen TXP4Xtop_hhi_by_n_top_MS = treatedXpost4*top_hhi_by_n*top_max_share

gen TXPm2Xbottom_hhi_by_n_top_MS = treatedXpostm2*bottom_hhi_by_n*top_max_share
gen TXPm3Xbottom_hhi_by_n_top_MS = treatedXpostm3*bottom_hhi_by_n*top_max_share
gen TXPm4Xbottom_hhi_by_n_top_MS = treatedXpostm4*bottom_hhi_by_n*top_max_share
gen TXP0Xbottom_hhi_by_n_top_MS = treatedXpost0*bottom_hhi_by_n*top_max_share
gen TXP1Xbottom_hhi_by_n_top_MS = treatedXpost1*bottom_hhi_by_n*top_max_share
gen TXP2Xbottom_hhi_by_n_top_MS = treatedXpost2*bottom_hhi_by_n*top_max_share
gen TXP3Xbottom_hhi_by_n_top_MS = treatedXpost3*bottom_hhi_by_n*top_max_share
gen TXP4Xbottom_hhi_by_n_top_MS = treatedXpost4*bottom_hhi_by_n*top_max_share

gen TXPm2Xtop_hhi_by_n_bottom_MS = treatedXpostm2*top_hhi_by_n*bottom_max_share
gen TXPm3Xtop_hhi_by_n_bottom_MS = treatedXpostm3*top_hhi_by_n*bottom_max_share
gen TXPm4Xtop_hhi_by_n_bottom_MS = treatedXpostm4*top_hhi_by_n*bottom_max_share
gen TXP0Xtop_hhi_by_n_bottom_MS = treatedXpost0*top_hhi_by_n*bottom_max_share
gen TXP1Xtop_hhi_by_n_bottom_MS = treatedXpost1*top_hhi_by_n*bottom_max_share
gen TXP2Xtop_hhi_by_n_bottom_MS = treatedXpost2*top_hhi_by_n*bottom_max_share
gen TXP3Xtop_hhi_by_n_bottom_MS = treatedXpost3*top_hhi_by_n*bottom_max_share
gen TXP4Xtop_hhi_by_n_bottom_MS = treatedXpost4*top_hhi_by_n*bottom_max_share

gen TXPm2Xbottom_hhi_by_n_bottom_MS = treatedXpostm2*bottom_hhi_by_n*bottom_max_share
gen TXPm3Xbottom_hhi_by_n_bottom_MS = treatedXpostm3*bottom_hhi_by_n*bottom_max_share
gen TXPm4Xbottom_hhi_by_n_bottom_MS = treatedXpostm4*bottom_hhi_by_n*bottom_max_share
gen TXP0Xbottom_hhi_by_n_bottom_MS = treatedXpost0*bottom_hhi_by_n*bottom_max_share
gen TXP1Xbottom_hhi_by_n_bottom_MS = treatedXpost1*bottom_hhi_by_n*bottom_max_share
gen TXP2Xbottom_hhi_by_n_bottom_MS = treatedXpost2*bottom_hhi_by_n*bottom_max_share
gen TXP3Xbottom_hhi_by_n_bottom_MS = treatedXpost3*bottom_hhi_by_n*bottom_max_share
gen TXP4Xbottom_hhi_by_n_bottom_MS = treatedXpost4*bottom_hhi_by_n*bottom_max_share

drop if if_yield_from_nic=="True"

preserve

reghdfe avg_yield_inbbps ///
i.treated##(i.top_hhi_by_n##i.top_max_share) (i.post)##(i.top_hhi_by_n) ///
TXPm2Xtop_hhi_by_n_top_MS TXPm3Xtop_hhi_by_n_top_MS TXPm4Xtop_hhi_by_n_top_MS TXP0Xtop_hhi_by_n_top_MS TXP1Xtop_hhi_by_n_top_MS TXP2Xtop_hhi_by_n_top_MS TXP3Xtop_hhi_by_n_top_MS TXP4Xtop_hhi_by_n_top_MS ///
TXPm2Xbottom_hhi_by_n_top_MS TXPm3Xbottom_hhi_by_n_top_MS TXPm4Xbottom_hhi_by_n_top_MS TXP0Xbottom_hhi_by_n_top_MS TXP1Xbottom_hhi_by_n_top_MS TXP2Xbottom_hhi_by_n_top_MS TXP3Xbottom_hhi_by_n_top_MS TXP4Xbottom_hhi_by_n_top_MS ///
TXPm2Xtop_hhi_by_n_bottom_MS TXPm3Xtop_hhi_by_n_bottom_MS TXPm4Xtop_hhi_by_n_bottom_MS TXP0Xtop_hhi_by_n_bottom_MS TXP1Xtop_hhi_by_n_bottom_MS TXP2Xtop_hhi_by_n_bottom_MS TXP3Xtop_hhi_by_n_bottom_MS TXP4Xtop_hhi_by_n_bottom_MS ///
TXPm2Xbottom_hhi_by_n_bottom_MS TXPm3Xbottom_hhi_by_n_bottom_MS TXPm4Xbottom_hhi_by_n_bottom_MS TXP0Xbottom_hhi_by_n_bottom_MS TXP1Xbottom_hhi_by_n_bottom_MS TXP2Xbottom_hhi_by_n_bottom_MS TXP3Xbottom_hhi_by_n_bottom_MS TXP4Xbottom_hhi_by_n_bottom_MS ///
, absorb(i.issuer_code##i.issuer_type i.calendar_year) cluster(issuer_code)

forvalues x = 2/4 {
local bm`x'_topMS = _b[TXPm`x'Xtop_hhi_by_n_top_MS]
local lbm`x'_topMS = _b[TXPm`x'Xtop_hhi_by_n_top_MS] - invttail(e(df_r),0.025)*_se[TXPm`x'Xtop_hhi_by_n_top_MS] 
local ubm`x'_topMS = _b[TXPm`x'Xtop_hhi_by_n_top_MS] + invttail(e(df_r),0.025)*_se[TXPm`x'Xtop_hhi_by_n_top_MS]
}

forvalues x = 0/4 {
local b`x'_topMS = _b[TXP`x'Xtop_hhi_by_n_top_MS]
local lb`x'_topMS = _b[TXP`x'Xtop_hhi_by_n_top_MS] - invttail(e(df_r),0.025)*_se[TXP`x'Xtop_hhi_by_n_top_MS] 
local ub`x'_topMS = _b[TXP`x'Xtop_hhi_by_n_top_MS] + invttail(e(df_r),0.025)*_se[TXP`x'Xtop_hhi_by_n_top_MS]
}

forvalues x = 2/4 {
local bm`x'_bottomMS = _b[TXPm`x'Xtop_hhi_by_n_bottom_MS]
local lbm`x'_bottomMS = _b[TXPm`x'Xtop_hhi_by_n_bottom_MS] - invttail(e(df_r),0.025)*_se[TXPm`x'Xtop_hhi_by_n_bottom_MS] 
local ubm`x'_bottomMS = _b[TXPm`x'Xtop_hhi_by_n_bottom_MS] + invttail(e(df_r),0.025)*_se[TXPm`x'Xtop_hhi_by_n_bottom_MS]
}

forvalues x = 0/4 {
local b`x'_bottomMS = _b[TXP`x'Xtop_hhi_by_n_bottom_MS]
local lb`x'_bottomMS = _b[TXP`x'Xtop_hhi_by_n_bottom_MS] - invttail(e(df_r),0.025)*_se[TXP`x'Xtop_hhi_by_n_bottom_MS] 
local ub`x'_bottomMS = _b[TXP`x'Xtop_hhi_by_n_bottom_MS] + invttail(e(df_r),0.025)*_se[TXP`x'Xtop_hhi_by_n_bottom_MS]
}

clear
set obs 31
gen yeartochange = .

replace yeartochange = -1 if _n == 1

gen coef_topMS = .
gen upper_topMS = .
gen lower_topMS = .

replace coef_topMS = 0 if _n == 1
replace coef_topMS = 0 if _n == 1

gen coef_bottomMS = .
gen upper_bottomMS = .
gen lower_bottomMS = .

replace coef_bottomMS = 0 if _n == 1
replace coef_bottomMS = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef_topMS = `bm`x'_topMS' if _n == `x'
replace lower_topMS = `lbm`x'_topMS' if _n == `x'
replace upper_topMS = `ubm`x'_topMS' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef_topMS = `b`x'_topMS' if _n == `x' + 5
replace lower_topMS = `lb`x'_topMS' if _n == `x' + 5
replace upper_topMS = `ub`x'_topMS' if _n == `x' + 5
}

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef_bottomMS = `bm`x'_bottomMS' if _n == `x'
replace lower_bottomMS = `lbm`x'_bottomMS' if _n == `x'
replace upper_bottomMS = `ubm`x'_bottomMS' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef_bottomMS = `b`x'_bottomMS' if _n == `x' + 5
replace lower_bottomMS = `lb`x'_bottomMS' if _n == `x' + 5
replace upper_bottomMS = `ub`x'_bottomMS' if _n == `x' + 5
}

list

sort yeartochange

replace coef_topMS = coef_topMS
replace upper_topMS = upper_topMS
replace lower_topMS = lower_topMS

replace coef_bottomMS = coef_bottomMS
replace upper_bottomMS = upper_bottomMS
replace lower_bottomMS = lower_bottomMS

gen yeartochange_right = yeartochange+0.1

graph twoway ///
(scatter coef_topMS yeartochange, msize(small) mcolor(red)) (rcap upper_topMS lower_topMS yeartochange, lcolor(red)) ///
(scatter coef_bottomMS yeartochange_right, msize(small) mcolor(blue)) (rcap upper_bottomMS lower_bottomMS yeartochange_right, lcolor(blue)), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on offering yield", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in bps.), Market share > 0.15") label(2 "95% CI") label(3 "Coef (in bps.), Market share <= 0.15") label(4 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/Yield_Around_MA_marketshare_Sliced.eps", replace

restore






/* Figure: Using implied HHI, split sample two ways by both HHI and size of merger */

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear 

gen avg_yield_inbbps = avg_yield*10000

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

bysort county: egen avghhi_by_n = mean(hhi_by_n)
gen top_hhi_by_n = avghhi_by_n>0.1
gen bottom_hhi_by_n = (1-top_hhi_by_n)

gen top_hhi_dif = hhi_dif>0.02&hhi_dif!=.
gen bottom_hhi_dif = (1-top_hhi_dif)

gen TXPm2Xtop_hhi_by_n_top_MS = treatedXpostm2*top_hhi_by_n*top_hhi_dif
gen TXPm3Xtop_hhi_by_n_top_MS = treatedXpostm3*top_hhi_by_n*top_hhi_dif
gen TXPm4Xtop_hhi_by_n_top_MS = treatedXpostm4*top_hhi_by_n*top_hhi_dif
gen TXP0Xtop_hhi_by_n_top_MS = treatedXpost0*top_hhi_by_n*top_hhi_dif
gen TXP1Xtop_hhi_by_n_top_MS = treatedXpost1*top_hhi_by_n*top_hhi_dif
gen TXP2Xtop_hhi_by_n_top_MS = treatedXpost2*top_hhi_by_n*top_hhi_dif
gen TXP3Xtop_hhi_by_n_top_MS = treatedXpost3*top_hhi_by_n*top_hhi_dif
gen TXP4Xtop_hhi_by_n_top_MS = treatedXpost4*top_hhi_by_n*top_hhi_dif

gen TXPm2Xbottom_hhi_by_n_top_MS = treatedXpostm2*bottom_hhi_by_n*top_hhi_dif
gen TXPm3Xbottom_hhi_by_n_top_MS = treatedXpostm3*bottom_hhi_by_n*top_hhi_dif
gen TXPm4Xbottom_hhi_by_n_top_MS = treatedXpostm4*bottom_hhi_by_n*top_hhi_dif
gen TXP0Xbottom_hhi_by_n_top_MS = treatedXpost0*bottom_hhi_by_n*top_hhi_dif
gen TXP1Xbottom_hhi_by_n_top_MS = treatedXpost1*bottom_hhi_by_n*top_hhi_dif
gen TXP2Xbottom_hhi_by_n_top_MS = treatedXpost2*bottom_hhi_by_n*top_hhi_dif
gen TXP3Xbottom_hhi_by_n_top_MS = treatedXpost3*bottom_hhi_by_n*top_hhi_dif
gen TXP4Xbottom_hhi_by_n_top_MS = treatedXpost4*bottom_hhi_by_n*top_hhi_dif

gen TXPm2Xtop_hhi_by_n_bottom_MS = treatedXpostm2*top_hhi_by_n*bottom_hhi_dif
gen TXPm3Xtop_hhi_by_n_bottom_MS = treatedXpostm3*top_hhi_by_n*bottom_hhi_dif
gen TXPm4Xtop_hhi_by_n_bottom_MS = treatedXpostm4*top_hhi_by_n*bottom_hhi_dif
gen TXP0Xtop_hhi_by_n_bottom_MS = treatedXpost0*top_hhi_by_n*bottom_hhi_dif
gen TXP1Xtop_hhi_by_n_bottom_MS = treatedXpost1*top_hhi_by_n*bottom_hhi_dif
gen TXP2Xtop_hhi_by_n_bottom_MS = treatedXpost2*top_hhi_by_n*bottom_hhi_dif
gen TXP3Xtop_hhi_by_n_bottom_MS = treatedXpost3*top_hhi_by_n*bottom_hhi_dif
gen TXP4Xtop_hhi_by_n_bottom_MS = treatedXpost4*top_hhi_by_n*bottom_hhi_dif

gen TXPm2Xbottom_hhi_by_n_bottom_MS = treatedXpostm2*bottom_hhi_by_n*bottom_hhi_dif
gen TXPm3Xbottom_hhi_by_n_bottom_MS = treatedXpostm3*bottom_hhi_by_n*bottom_hhi_dif
gen TXPm4Xbottom_hhi_by_n_bottom_MS = treatedXpostm4*bottom_hhi_by_n*bottom_hhi_dif
gen TXP0Xbottom_hhi_by_n_bottom_MS = treatedXpost0*bottom_hhi_by_n*bottom_hhi_dif
gen TXP1Xbottom_hhi_by_n_bottom_MS = treatedXpost1*bottom_hhi_by_n*bottom_hhi_dif
gen TXP2Xbottom_hhi_by_n_bottom_MS = treatedXpost2*bottom_hhi_by_n*bottom_hhi_dif
gen TXP3Xbottom_hhi_by_n_bottom_MS = treatedXpost3*bottom_hhi_by_n*bottom_hhi_dif
gen TXP4Xbottom_hhi_by_n_bottom_MS = treatedXpost4*bottom_hhi_by_n*bottom_hhi_dif

drop if if_yield_from_nic=="True"

preserve

reghdfe avg_yield_inbbps ///
i.treated##(i.top_hhi_by_n##i.top_hhi_dif) (i.post)##(i.top_hhi_by_n) ///
TXPm2Xtop_hhi_by_n_top_MS TXPm3Xtop_hhi_by_n_top_MS TXPm4Xtop_hhi_by_n_top_MS TXP0Xtop_hhi_by_n_top_MS TXP1Xtop_hhi_by_n_top_MS TXP2Xtop_hhi_by_n_top_MS TXP3Xtop_hhi_by_n_top_MS TXP4Xtop_hhi_by_n_top_MS ///
TXPm2Xbottom_hhi_by_n_top_MS TXPm3Xbottom_hhi_by_n_top_MS TXPm4Xbottom_hhi_by_n_top_MS TXP0Xbottom_hhi_by_n_top_MS TXP1Xbottom_hhi_by_n_top_MS TXP2Xbottom_hhi_by_n_top_MS TXP3Xbottom_hhi_by_n_top_MS TXP4Xbottom_hhi_by_n_top_MS ///
TXPm2Xtop_hhi_by_n_bottom_MS TXPm3Xtop_hhi_by_n_bottom_MS TXPm4Xtop_hhi_by_n_bottom_MS TXP0Xtop_hhi_by_n_bottom_MS TXP1Xtop_hhi_by_n_bottom_MS TXP2Xtop_hhi_by_n_bottom_MS TXP3Xtop_hhi_by_n_bottom_MS TXP4Xtop_hhi_by_n_bottom_MS ///
TXPm2Xbottom_hhi_by_n_bottom_MS TXPm3Xbottom_hhi_by_n_bottom_MS TXPm4Xbottom_hhi_by_n_bottom_MS TXP0Xbottom_hhi_by_n_bottom_MS TXP1Xbottom_hhi_by_n_bottom_MS TXP2Xbottom_hhi_by_n_bottom_MS TXP3Xbottom_hhi_by_n_bottom_MS TXP4Xbottom_hhi_by_n_bottom_MS ///
, absorb(i.issuer_code##i.issuer_type i.calendar_year) cluster(issuer_code)

forvalues x = 2/4 {
local bm`x'_tophhi_dif = _b[TXPm`x'Xtop_hhi_by_n_top_MS]
local lbm`x'_tophhi_dif = _b[TXPm`x'Xtop_hhi_by_n_top_MS] - invttail(e(df_r),0.025)*_se[TXPm`x'Xtop_hhi_by_n_top_MS] 
local ubm`x'_tophhi_dif = _b[TXPm`x'Xtop_hhi_by_n_top_MS] + invttail(e(df_r),0.025)*_se[TXPm`x'Xtop_hhi_by_n_top_MS]
}

forvalues x = 0/4 {
local b`x'_tophhi_dif = _b[TXP`x'Xtop_hhi_by_n_top_MS]
local lb`x'_tophhi_dif = _b[TXP`x'Xtop_hhi_by_n_top_MS] - invttail(e(df_r),0.025)*_se[TXP`x'Xtop_hhi_by_n_top_MS] 
local ub`x'_tophhi_dif = _b[TXP`x'Xtop_hhi_by_n_top_MS] + invttail(e(df_r),0.025)*_se[TXP`x'Xtop_hhi_by_n_top_MS]
}

forvalues x = 2/4 {
local bm`x'_bottomhhi_dif = _b[TXPm`x'Xtop_hhi_by_n_bottom_MS]
local lbm`x'_bottomhhi_dif = _b[TXPm`x'Xtop_hhi_by_n_bottom_MS] - invttail(e(df_r),0.025)*_se[TXPm`x'Xtop_hhi_by_n_bottom_MS] 
local ubm`x'_bottomhhi_dif = _b[TXPm`x'Xtop_hhi_by_n_bottom_MS] + invttail(e(df_r),0.025)*_se[TXPm`x'Xtop_hhi_by_n_bottom_MS]
}

forvalues x = 0/4 {
local b`x'_bottomhhi_dif = _b[TXP`x'Xtop_hhi_by_n_bottom_MS]
local lb`x'_bottomhhi_dif = _b[TXP`x'Xtop_hhi_by_n_bottom_MS] - invttail(e(df_r),0.025)*_se[TXP`x'Xtop_hhi_by_n_bottom_MS] 
local ub`x'_bottomhhi_dif = _b[TXP`x'Xtop_hhi_by_n_bottom_MS] + invttail(e(df_r),0.025)*_se[TXP`x'Xtop_hhi_by_n_bottom_MS]
}

clear
set obs 31
gen yeartochange = .

replace yeartochange = -1 if _n == 1

gen coef_tophhi_dif = .
gen upper_tophhi_dif = .
gen lower_tophhi_dif = .

replace coef_tophhi_dif = 0 if _n == 1
replace coef_tophhi_dif = 0 if _n == 1

gen coef_bottomhhi_dif = .
gen upper_bottomhhi_dif = .
gen lower_bottomhhi_dif = .

replace coef_bottomhhi_dif = 0 if _n == 1
replace coef_bottomhhi_dif = 0 if _n == 1

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef_tophhi_dif = `bm`x'_tophhi_dif' if _n == `x'
replace lower_tophhi_dif = `lbm`x'_tophhi_dif' if _n == `x'
replace upper_tophhi_dif = `ubm`x'_tophhi_dif' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef_tophhi_dif = `b`x'_tophhi_dif' if _n == `x' + 5
replace lower_tophhi_dif = `lb`x'_tophhi_dif' if _n == `x' + 5
replace upper_tophhi_dif = `ub`x'_tophhi_dif' if _n == `x' + 5
}

forvalues x = 2/4 {
replace yeartochange = -1 * `x' if _n == `x'
replace coef_bottomhhi_dif = `bm`x'_bottomhhi_dif' if _n == `x'
replace lower_bottomhhi_dif = `lbm`x'_bottomhhi_dif' if _n == `x'
replace upper_bottomhhi_dif = `ubm`x'_bottomhhi_dif' if _n == `x'
}

forvalues x = 0/4 {
replace yeartochange = `x' if _n == `x' + 5
replace coef_bottomhhi_dif = `b`x'_bottomhhi_dif' if _n == `x' + 5
replace lower_bottomhhi_dif = `lb`x'_bottomhhi_dif' if _n == `x' + 5
replace upper_bottomhhi_dif = `ub`x'_bottomhhi_dif' if _n == `x' + 5
}

list

sort yeartochange

replace coef_tophhi_dif = coef_tophhi_dif
replace upper_tophhi_dif = upper_tophhi_dif
replace lower_tophhi_dif = lower_tophhi_dif

replace coef_bottomhhi_dif = coef_bottomhhi_dif
replace upper_bottomhhi_dif = upper_bottomhhi_dif
replace lower_bottomhhi_dif = lower_bottomhhi_dif

gen yeartochange_right = yeartochange+0.1

graph twoway ///
(scatter coef_tophhi_dif yeartochange, msize(small) mcolor(red)) (rcap upper_tophhi_dif lower_tophhi_dif yeartochange, lcolor(red)) ///
(scatter coef_bottomhhi_dif yeartochange_right, msize(small) mcolor(blue)) (rcap upper_bottomhhi_dif lower_bottomhhi_dif yeartochange_right, lcolor(blue)), ///
xtitle("Year to M&A", size(large)) ytitle("Effects on offering yield", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in bps.), Market share > 0.15") label(2 "95% CI") label(3 "Coef (in bps.), Market share <= 0.15") label(4 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/Yield_Around_MA_impliedHHI_Sliced.eps", replace

restore

