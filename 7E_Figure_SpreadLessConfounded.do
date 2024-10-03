
set scheme s1color

/*--------------------------------------*/
/* Figure: Using the narrative approach */
/*--------------------------------------*/

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

/* Column 1 */

// Column 1: Whole sample
reghdfe gross_spread_inbp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=7), ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

local b_whole = _b[treatedXpost]
local se_whole = _se[treatedXpost]

/* Column 2 */

// Column 2: Require M&A is for reasons unlikely to be related to local economic conditions
reghdfe gross_spread_inbp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=7) & reasonma_endo_possible=="False", ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

local b_exclude2 = _b[treatedXpost]
local se_exclude2 = _se[treatedXpost]

/* Column 3 */

// Column 3: Require M&A is for reasons unlikely to be related to local economic conditions, and also not due to financial distress
reghdfe gross_spread_inbp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=7) & reasonma_endo_possible=="False"&reasonma_fin_stress=="False", ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

local b_exclude3 = _b[treatedXpost]
local se_exclude3 = _se[treatedXpost]

clear
set obs 4
gen idx = _n
gen label = ""
gen coef = .
gen se = .

replace label = "Whole Sample" if idx==1
replace coef = `b_whole' if idx==1
replace se = `se_whole' if idx==1
replace label = "Exclude M&As Due to Top Two Reasons" if idx==2
replace coef = `b_exclude2' if idx==2
replace se = `se_exclude2' if idx==2
replace label = "Further Exclude M&As Due to Financial Stress" if idx==3
replace coef = `b_exclude3' if idx==3
replace se = `se_exclude3' if idx==3

gen low95 = coef-1.95*se
gen high95 = coef+1.95*se

gen group = .
replace group = 1 if idx==1|idx==2|idx==3

twoway ///
(rcap low95 high95 idx if group==1, vertical lcolor(blue*0.3)) ///
(scatter coef idx if group ==1, mcolor(blue)) ///
, xlabel( ///
1 "Whole Sample" 1.85 "Exclude M&As" 2.15 "Due to Top Two Reasons" 2.85 "Further Exclude M&As" 3.15 "Due to Financial Stress" ///
, angle(45) noticks) ///
xscale(range(-0.5,4.5)) ///
yscale(range(-0.5,12.5)) ///
ytitle("Effects on Underwriting Spread (in bps.)") xtitle("") /// 
legend(off) ///
yline(0.1, lpattern(dash) lcolor(red))
graph export "../Draft/figs/GrossSpread_ByReportedReason.eps", replace



/*---------------------------------------------------------------------------------------------------*/
/* Figure: Affected markets account for a small fraction of total businesses of merging underwriters */
/*---------------------------------------------------------------------------------------------------*/

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear 

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

/* Column 1 */

// Column 1: Less than 10%
reghdfe gross_spread_inbp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=7) ///
& max_acquiror_weight<0.1&max_target_weight<0.1, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

local b_less10 = _b[treatedXpost]
local se_less10 = _se[treatedXpost]

/* Column 2 */

// Column 2: Less than 5%
reghdfe gross_spread_inbp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=7) ///
& max_acquiror_weight<0.05&max_target_weight<0.05, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

local b_less5 = _b[treatedXpost]
local se_less5 = _se[treatedXpost]

/* Column 3 */

// Column 3: Less than 3%
reghdfe gross_spread_inbp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=7) ///
& max_acquiror_weight<0.03&max_target_weight<0.03, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

local b_less3 = _b[treatedXpost]
local se_less3 = _se[treatedXpost]

/* Column 4 */

// Column 4: Both the affected CSA and all of its neighbours make up less than 5%
reghdfe gross_spread_inbp treated post treatedXpost ///
if (year_to_merger>=-4&year_to_merger<=7) ///
& max_acquiror_weight<0.05&max_target_weight<0.05 ///
&max_acquiror_weight_in_neighbour<0.05 &max_target_weight_in_neighbour<0.05, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) cluster(csacode calendar_year)

local b_less5neighbour = _b[treatedXpost]
local se_less5neighbour = _se[treatedXpost]

clear
set obs 5
gen idx = _n
gen label = ""
gen coef = .
gen se = .

replace label = "Less than 10% of Total Businesses" if idx==1
replace coef = `b_less10' if idx==1
replace se = `se_less10' if idx==1
replace label = "Less than 5% of Total Businesses" if idx==2
replace coef = `b_less5' if idx==2
replace se = `se_less5' if idx==2
replace label = "Less than 3% of Total Businesses" if idx==3
replace coef = `b_less3' if idx==3
replace se = `se_less3' if idx==3
replace label = "Both Treated and Neighbour Less than 5% of Total Businesses" if idx==5
replace coef = `b_less5neighbour' if idx==5
replace se = `se_less5neighbour' if idx==5

gen low95 = coef-1.95*se
gen high95 = coef+1.95*se

gen group = .
replace group = 1 if idx==1|idx==2|idx==3|idx==5
replace idx = 4.5 if idx==5

twoway ///
(rcap low95 high95 idx if group==1, vertical lcolor(orange*0.3)) ///
(scatter coef idx if group ==1, mcolor(orange)) ///
, xlabel( ///
0.85 "Less than 10%" 1.15 "of Total Businesses" ///
1.85 "Less than 5%" 2.15 "of Total Businesses" ///
2.85 "Less than 3%" 3.15 "of Total Businesses" ///
4.2 "Both Affected & Neighbours" 4.5"Make up for Less than 3%" 4.8 "of Total Businesses" ///
, angle(45) noticks) ///
xscale(range(-0.5,4.5)) ///
yscale(range(-0.5,20)) ///
ytitle("Effects on Underwriting Spread (in bps.)") xtitle("") /// 
legend(off) ///
yline(0.1, lpattern(dash) lcolor(red))
graph export "../Draft/figs/GrossSpread_MarketSmallFraction.eps", replace

