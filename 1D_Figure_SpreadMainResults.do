
set scheme s1color


/* Figure: Using market share */

import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear 

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

preserve

reghdfe gross_spread treated post treatedXpostm2 treatedXpostm3 treatedXpostm4 treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(issuer_code)

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
xtitle("Year to M&A", size(large)) ytitle("Effects on underwriting spread", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in bps.)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GrossSpread_Around_MA_marketshare.eps", replace

restore




/* Figure: Using implied HHI */

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

preserve

reghdfe gross_spread treated post treatedXpostm2 treatedXpostm3 treatedXpostm4 treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(issuer_code)

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
xtitle("Year to M&A", size(large)) ytitle("Effects on underwriting spread", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in bps.)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GrossSpread_Around_MA_impliedHHI.eps", replace

restore




/* Figure: Using top 5 market share */

import delimited "../CleanData/MAEvent/CSA_episodes_top5shareByN.csv", clear 

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

preserve

reghdfe gross_spread treated post treatedXpostm2 treatedXpostm3 treatedXpostm4 treatedXpost0 treatedXpost1 treatedXpost2 treatedXpost3 treatedXpost4, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(issuer_code)

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
xtitle("Year to M&A", size(large)) ytitle("Effects on underwriting spread", size(large)) ///
xlabel(-4(1)4, labsize(large)) ///
legend(label(1 "Coef (in bps.)") label(2 "95% CI") size(large)) yline(0, lpattern(dot))
graph export "../Slides/figs/GrossSpread_Around_MA_top5share.eps", replace

restore



/* Figure: Heterogeneity in effects, part I */

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

/* Column 1 */

gen if_hhi_dif_100_200 = hhi_dif>=0.01&hhi_dif<0.02
gen treatedXpostXhhi_dif_100_200 = treatedXpost*(hhi_dif>=0.01&hhi_dif<0.02)
label var treatedXpostXhhi_dif_100_200 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ in [100,200)"

gen if_hhi_dif_200_300 = hhi_dif>=0.02&hhi_dif<0.03
gen treatedXpostXhhi_dif_200_300 = treatedXpost*(hhi_dif>=0.02&hhi_dif<0.03)
label var treatedXpostXhhi_dif_200_300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ in [200,300)"

gen if_hhi_dif_gt300 = hhi_dif>0.03&hhi_dif!=.
gen treatedXpostXhhi_dif_gt300 = treatedXpost*(hhi_dif>0.03&hhi_dif!=.)
label var treatedXpostXhhi_dif_gt300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ $\ge$ 300"

// Column 1: By increased in HHI induced by merger
reghdfe gross_spread_inbp treated post if_hhi_dif_200_300 if_hhi_dif_gt300 ///
treatedXpostXhhi_dif_100_200 treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)

local b_TXPXhhi_dif_100_200 = _b[treatedXpostXhhi_dif_100_200]
local b_TXPXhhi_dif_200_300 = _b[treatedXpostXhhi_dif_200_300]
local b_TXPXhhi_dif_gt300 = _b[treatedXpostXhhi_dif_gt300]
local se_TXPXhhi_dif_100_200 = _se[treatedXpostXhhi_dif_100_200]
local se_TXPXhhi_dif_200_300 = _se[treatedXpostXhhi_dif_200_300]
local se_TXPXhhi_dif_gt300 = _se[treatedXpostXhhi_dif_gt300]

/* Column 2 */

bysort county: egen avghhi_by_n = mean(hhi_by_n)

gen if_avghhi_lt1000 = (avghhi_by_n<0.1)
gen treatedXpostXavghhi_lt1000 = treatedXpost*(avghhi_by_n<0.1)
label var treatedXpostXavghhi_lt1000 "Treated $\times$ Post $\times$ HHI $\le$ 1000"

gen if_avghhi_1000_2500 = (avghhi_by_n>=0.1&avghhi_by_n<0.25)
gen treatedXpostXavghhi_1000_2500 = treatedXpost*(avghhi_by_n>=0.1&avghhi_by_n<0.25)
label var treatedXpostXavghhi_1000_2500 "Treated $\times$ Post $\times$ HHI in [1000,2500)"

gen if_avghhi_gt2500 = (avghhi_by_n>=0.25)&(avghhi_by_n!=.)
gen treatedXpostXavghhi_gt2500 = treatedXpost*(avghhi_by_n>=0.25)&(avghhi_by_n!=.)
label var treatedXpostXavghhi_gt2500 "Treated $\times$ Post $\times$ HHI $\ge$ 2500"

// Column 2: By initial HHI
reghdfe gross_spread_inbp (i.treated i.post)##(i.if_avghhi_1000_2500 i.if_avghhi_gt2500) ///
treatedXpostXavghhi_lt1000 treatedXpostXavghhi_1000_2500 treatedXpostXavghhi_gt2500, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)

local b_TXPXavghhi_lt1000 = _b[treatedXpostXavghhi_lt1000]
local b_TXPXavghhi_1000_2500 = _b[treatedXpostXavghhi_1000_2500]
local b_TXPXavghhi_gt2500 = _b[treatedXpostXavghhi_gt2500]

local se_TXPXavghhi_lt1000 = _se[treatedXpostXavghhi_lt1000]
local se_TXPXavghhi_1000_2500 = _se[treatedXpostXavghhi_1000_2500]
local se_TXPXavghhi_gt2500 = _se[treatedXpostXavghhi_gt2500]

/* Column 3 */

gen if_advisor_coded = if_advisor=="Yes"
label var if_advisor_coded "Has Advisor"

gen treatedXpostXhas_advisor = treatedXpost*(if_advisor=="Yes")
label var treatedXpostXhas_advisor "Treated $\times$ Post $\times$ Has Advisor"

gen treatedXpostXno_advisor = treatedXpost*(if_advisor=="No")
label var treatedXpostXno_advisor "Treated $\times$ Post $\times$ No Advisor"

// Column 3: By whether employing an advisor
reghdfe gross_spread_inbp (i.treated i.post)##(i.if_advisor_coded) treatedXpostXhas_advisor treatedXpostXno_advisor, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)

local b_TXPXhas_advisor = _b[treatedXpostXhas_advisor]
local b_TXPXno_advisor = _b[treatedXpostXno_advisor]
local se_TXPXhas_advisor = _se[treatedXpostXhas_advisor]
local se_TXPXno_advisor = _se[treatedXpostXno_advisor]

clear
set obs 10
gen idx = _n
gen label = ""
gen coef = .
gen se = .

replace label = "predicted DeltaHHI in [100,200)" if idx==1
replace coef = `b_TXPXhhi_dif_100_200' if idx==1
replace se = `se_TXPXhhi_dif_100_200' if idx==1
replace label = "predicted DeltaHHI in [200,300)" if idx==2
replace coef = `b_TXPXhhi_dif_200_300' if idx==2
replace se = `se_TXPXhhi_dif_200_300' if idx==2
replace label = "predicted DeltaHHI > 300" if idx==3
replace coef = `b_TXPXhhi_dif_gt300' if idx==3
replace se = `se_TXPXhhi_dif_gt300' if idx==3

replace label = "HHI < 1000" if idx==5
replace coef = `b_TXPXavghhi_lt1000' if idx==5
replace se = `se_TXPXavghhi_lt1000' if idx==5
replace label = "HHI in [1000,2500)" if idx==6
replace coef = `b_TXPXavghhi_1000_2500' if idx==6
replace se = `se_TXPXavghhi_1000_2500' if idx==6
replace label = "HHI > 2500" if idx==7
replace coef = `b_TXPXavghhi_gt2500' if idx==7
replace se = `se_TXPXavghhi_gt2500' if idx==7

replace label = "Has advisor" if idx==9
replace coef = `b_TXPXhas_advisor' if idx==9
replace se = `se_TXPXhas_advisor' if idx==9
replace label = "No advisor" if idx==10
replace coef = `b_TXPXno_advisor' if idx==10
replace se = `se_TXPXno_advisor' if idx==10

gen low95 = coef-1.95*se
gen high95 = coef+1.95*se

gen group = .
replace group = 1 if idx==1|idx==2|idx==3
replace group = 2 if idx==5|idx==6|idx==7
replace group = 3 if idx==9|idx==10

replace idx = idx-0.5 if idx==5|idx==6|idx==7
replace idx = idx-1 if idx==9|idx==10

twoway ///
(rcap low95 high95 idx if group==1, vertical lcolor(orange*0.3)) ///
(rcap low95 high95 idx if group==2, vertical lcolor(green*0.3)) ///
(rcap low95 high95 idx if group==3, vertical lcolor(blue*0.3)) ///
(scatter coef idx if group ==1, mcolor(orange)) ///
(scatter coef idx if group ==2, mcolor(green)) ///
(scatter coef idx if group ==3, mcolor(blue)) ///
, xlabel( ///
1 "{it:predicted} {&Delta}{sub:HHI} in [100,200)" 2 "{it:predicted} {&Delta}{sub:HHI} in [200,300)" 3 "{it:predicted} {&Delta}{sub:HHI} > 300" ///
4.5 "HHI < 1000" 5.5 "HHI in [1000,2500)" 6.5 "HHI > 2500" ///
8 "Has advisor" 9 "No advisor", angle(45) noticks) ///
xscale(range(-0.5,10)) ///
ytitle("Effects on underwriting spread (in bps.)") xtitle("") /// 
legend(off) ///
yline(0.1, lpattern(dash) lcolor(red))
graph export "../Slides/figs/GrossSpread_Around_MA_Het1.eps", replace

