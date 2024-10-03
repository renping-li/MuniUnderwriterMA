
set scheme s1color

/*---------------------------------------------------------------*/
/* Figure: Effects of M&A on gross spread by the use of proceeds */
/*---------------------------------------------------------------*/

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated X Post"

encode issuer, gen(issuer_code)

/* Using self-defined purpose */

drop if_*

gen use_of_proceeds = ""
replace use_of_proceeds = "Genl Purpose/ Public Imp" if ///
	use_of_proceeds_general=="Genl Purpose/ Public Imp"
replace use_of_proceeds = "Education" if ///
	use_of_proceeds_general=="Education"| ///
	use_of_proceeds_general=="Student Loans"
replace use_of_proceeds = "Housing" if ///
	use_of_proceeds_general=="Multi Family Housing"| ///
	use_of_proceeds_general=="Single Family Housing"
replace use_of_proceeds = "Utilities" if ///
	use_of_proceeds_general=="Water, Sewer & Gas Facs"| ///
	use_of_proceeds_general=="Electric & Public Power"| ///
	use_of_proceeds_general=="Combined Utilities"
replace use_of_proceeds = "Transportation" if ///
	use_of_proceeds_general=="Transportation"| ///
	use_of_proceeds_general=="Airports"| ///
	use_of_proceeds_general=="Seaports/Marine Terminals"
replace use_of_proceeds = "Health Care" if ///
	use_of_proceeds_general=="Health Care"| ///
	use_of_proceeds_general=="Nursing Homes/ Life Care"
replace use_of_proceeds = "Economic Development" if ///
	use_of_proceeds_general=="Economic Development"| ///
	use_of_proceeds_general=="Industrial Development"
replace use_of_proceeds = "Pollution Control" if ///
	use_of_proceeds_general=="Solid Waste/ Resource Rec"| ///
	use_of_proceeds_general=="Pollution Control"

gen if_gp = use_of_proceeds=="Genl Purpose/ Public Imp"
gen if_gpXtreated = if_gp*treated
gen if_gpXpost = if_gp*post
gen if_gpXtreatedXpost = if_gp*treatedXpost

count if if_gp==1
local N_gp = r(N)

gen if_edu = use_of_proceeds=="Education"
gen if_eduXtreated = if_edu*treated
gen if_eduXpost = if_edu*post
gen if_eduXtreatedXpost = if_edu*treatedXpost

count if if_edu==1
local N_edu = r(N)

gen if_house = use_of_proceeds=="Housing"
gen if_houseXtreated = if_house*treated
gen if_houseXpost = if_house*post
gen if_houseXtreatedXpost = if_house*treatedXpost

count if if_house==1
local N_house = r(N)

gen if_util = use_of_proceeds=="Utilities"
gen if_utilXtreated = if_util*treated
gen if_utilXpost = if_util*post
gen if_utilXtreatedXpost = if_util*treatedXpost

count if if_util==1
local N_util = r(N)

gen if_tsp = use_of_proceeds=="Transportation"
gen if_tspXtreated = if_tsp*treated
gen if_tspXpost = if_tsp*post
gen if_tspXtreatedXpost = if_tsp*treatedXpost

count if if_tsp==1
local N_tsp = r(N)

gen if_health = use_of_proceeds=="Health Care"
gen if_healthXtreated = if_health*treated
gen if_healthXpost = if_health*post
gen if_healthXtreatedXpost = if_health*treatedXpost

count if if_health==1
local N_health = r(N)

gen if_ed = use_of_proceeds=="Economic Development"
gen if_edXtreated = if_ed*treated
gen if_edXpost = if_ed*post
gen if_edXtreatedXpost = if_ed*treatedXpost

count if if_ed==1
local N_ed = r(N)

gen if_pollute = use_of_proceeds=="Pollution Control"
gen if_polluteXtreated = if_pollute*treated
gen if_polluteXpost = if_pollute*post
gen if_polluteXtreatedXpost = if_pollute*treatedXpost

count if if_pollute==1
local N_pollute = r(N)

reghdfe gross_spread_inbp ///
i.(treated post)##( ///
if_gp ///
if_edu ///
if_util ///
if_house ///
if_ed ///
if_health ///
if_tsp ///
if_pollute) ///
if_gpXtreatedXpost ///
if_eduXtreatedXpost ///
if_utilXtreatedXpost ///
if_houseXtreatedXpost ///
if_edXtreatedXpost ///
if_healthXtreatedXpost ///
if_tspXtreatedXpost ///
if_polluteXtreatedXpost ///
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

/* Create a plot */

clear
set obs 8
gen idx = _n
gen desc = ""
gen coef = .
gen se = .
gen N = .

replace desc = "Genl Purpose/ Public Imp" if idx==1
replace coef = _b[if_gpXtreatedXpost] if idx==1
replace se = _se[if_gpXtreatedXpost] if idx==1
replace N = `N_gp' if idx==1

replace desc = "Education" if idx==2
replace coef = _b[if_eduXtreatedXpost] if idx==2
replace se = _se[if_eduXtreatedXpost] if idx==2
replace N = `N_edu' if idx==2

replace desc = "Utilities" if idx==3
replace coef = _b[if_utilXtreatedXpost] if idx==3
replace se = _se[if_utilXtreatedXpost] if idx==3
replace N = `N_util' if idx==3

replace desc = "Housing" if idx==4
replace coef = _b[if_houseXtreatedXpost] if idx==4
replace se = _se[if_houseXtreatedXpost] if idx==4
replace N = `N_house' if idx==4

replace desc = "Economic Development" if idx==5
replace coef = _b[if_edXtreatedXpost] if idx==5
replace se = _se[if_edXtreatedXpost] if idx==5
replace N = `N_ed' if idx==5

replace desc = "Health Care" if idx==6
replace coef = _b[if_healthXtreatedXpost] if idx==6
replace se = _se[if_healthXtreatedXpost] if idx==6
replace N = `N_health' if idx==6

replace desc = "Transportation" if idx==7
replace coef = _b[if_tspXtreatedXpost] if idx==7
replace se = _se[if_tspXtreatedXpost] if idx==7
replace N = `N_tsp' if idx==7

replace desc = "Pollution Control" if idx==8
replace coef = _b[if_polluteXtreatedXpost] if idx==8
replace se = _se[if_polluteXtreatedXpost] if idx==8
replace N = `N_pollute' if idx==8

gen upper = coef+1.96*se
gen lower = coef-1.96*se

twoway ///
(scatter coef idx) ///
(rcap upper lower idx), ///
xtitle("") ytitle("Effects on Underwriting Spread (in bps.)") yline(0, lpattern(dash)) legend(label(1 "Coef") label(2 "95% CI") position(11) col(1) ring(0)) ///
xlabel(1 "General Purpose" 2 "Education" 3 "Utilities" 4 "Housing" 5 "Economic Development" 6 "Health Care" 7 "Transportation" 8 "Pollution Control",angle(45)) ///
xscale(range(0,8.5))
graph export "../Draft/figs/EffectByUse.eps", replace



/* Figure: Plot frequency of each use of proceeds */

import delimited "../CleanData/SDC/1A_GPF_OLS.csv", clear 

gen use_of_proceeds = ""
replace use_of_proceeds = "Genl Purpose/ Public Imp" if ///
	use_of_proceeds_general=="Genl Purpose/ Public Imp"
replace use_of_proceeds = "Education" if ///
	use_of_proceeds_general=="Education"| ///
	use_of_proceeds_general=="Student Loans"
replace use_of_proceeds = "Housing" if ///
	use_of_proceeds_general=="Multi Family Housing"| ///
	use_of_proceeds_general=="Single Family Housing"
replace use_of_proceeds = "Utilities" if ///
	use_of_proceeds_general=="Water, Sewer & Gas Facs"| ///
	use_of_proceeds_general=="Electric & Public Power"| ///
	use_of_proceeds_general=="Combined Utilities"
replace use_of_proceeds = "Transportation" if ///
	use_of_proceeds_general=="Transportation"| ///
	use_of_proceeds_general=="Airports"| ///
	use_of_proceeds_general=="Seaports/Marine Terminals"
replace use_of_proceeds = "Health Care" if ///
	use_of_proceeds_general=="Health Care"| ///
	use_of_proceeds_general=="Nursing Homes/ Life Care"
replace use_of_proceeds = "Economic Development" if ///
	use_of_proceeds_general=="Economic Development"| ///
	use_of_proceeds_general=="Industrial Development"
replace use_of_proceeds = "Pollution Control" if ///
	use_of_proceeds_general=="Solid Waste/ Resource Rec"| ///
	use_of_proceeds_general=="Pollution Control"

keep use_of_proceeds amount

collapse (count) amount, by(use_of_proceeds)

rename amount N

gsort - N

gen idx = _n

replace N = N/1000
twoway ///
(bar N idx, barwidth(0.5)), ///
xtitle("") ytitle("N of Issues (in Thousands)") ///
xlabel(1 "General Purpose" 2 "Education" 3 "Utilities" 4 "Housing" 5 "Economic Development" 6 "Health Care" 7 "Transportation" 8 "Pollution Control",angle(45)) ///
xscale(range(0,8.5)) 
graph export "../Draft/figs/FrequencyByUse.eps", replace



/*-----------------------------------------------------------------*/
/* Figure: Effects of M&A on gross spread by driving reason of M&A */
/*-----------------------------------------------------------------*/

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated X Post"

encode issuer, gen(issuer_code)

// Acquiror's desire to gain local/regional dominance
cap drop if_reason TXPXif_reason TXPXnot_reason
gen if_reason = reasonma_local_dom=="True"
gen TXPXif_reason = treatedXpost*if_reason
gen TXPXnot_reason = treatedXpost*(1-if_reason)

reghdfe gross_spread_inbp i.(treated post)##(if_reason) TXPXif_reason TXPXnot_reason ///
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

local b_TXPtXlocal_dom = _b[TXPXif_reason]
local b_TXPtXnot_local_dom = _b[TXPXnot_reason]
local se_TXPtXlocal_dom = _se[TXPXif_reason]
local se_TXPtXnot_local_dom = _se[TXPXnot_reason]

// Acquiror's desire to expand geographically
cap drop if_reason TXPXif_reason TXPXnot_reason
gen if_reason = reasonma_expand_geo=="True"
gen TXPXif_reason = treatedXpost*if_reason
gen TXPXnot_reason = treatedXpost*(1-if_reason)

reghdfe gross_spread_inbp i.(treated post)##(if_reason) TXPXif_reason TXPXnot_reason ///
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

local b_TXPtXexpand_geo = _b[TXPXif_reason]
local b_TXPtXnot_expand_geo = _b[TXPXnot_reason]
local se_TXPtXexpand_geo = _se[TXPXif_reason]
local se_TXPtXnot_expand_geo = _se[TXPXnot_reason]

// Acquiror's desire to gain industry-wide dominance
cap drop if_reason TXPXif_reason TXPXnot_reason
gen if_reason = reasonma_ind_dom=="True"
gen TXPXif_reason = treatedXpost*if_reason
gen TXPXnot_reason = treatedXpost*(1-if_reason)

reghdfe gross_spread_inbp i.(treated post)##(if_reason) TXPXif_reason TXPXnot_reason ///
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

local b_TXPtXind_dom = _b[TXPXif_reason]
local b_TXPtXnot_ind_dom = _b[TXPXnot_reason]
local se_TXPtXind_dom = _se[TXPXif_reason]
local se_TXPtXnot_ind_dom = _se[TXPXnot_reason]

// Synergy from combining different lines of business
cap drop if_reason TXPXif_reason TXPXnot_reason
gen if_reason = reasonma_syn_comb_lines=="True"
gen TXPXif_reason = treatedXpost*if_reason
gen TXPXnot_reason = treatedXpost*(1-if_reason)

reghdfe gross_spread_inbp i.(treated post)##(if_reason) TXPXif_reason TXPXnot_reason ///
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

local b_TXPtXsyn_comb_lines = _b[TXPXif_reason]
local b_TXPtXnot_syn_comb_lines = _b[TXPXnot_reason]
local se_TXPtXsyn_comb_lines = _se[TXPXif_reason]
local se_TXPtXnot_syn_comb_lines = _se[TXPXnot_reason]

// Synergy from cost management
cap drop if_reason TXPXif_reason TXPXnot_reason
gen if_reason = reasonma_syn_cost=="True"
gen TXPXif_reason = treatedXpost*if_reason
gen TXPXnot_reason = treatedXpost*(1-if_reason)

reghdfe gross_spread_inbp i.(treated post)##(if_reason) TXPXif_reason TXPXnot_reason ///
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

local b_TXPtXsyn_cost = _b[TXPXif_reason]
local b_TXPtXnot_syn_cost = _b[TXPXnot_reason]
local se_TXPtXsyn_cost = _se[TXPXif_reason]
local se_TXPtXnot_syn_cost = _se[TXPXnot_reason]

// Acquiror's desire to diversify its revenue sources
cap drop if_reason TXPXif_reason TXPXnot_reason
gen if_reason = reasonma_diversify=="True"
gen TXPXif_reason = treatedXpost*if_reason
gen TXPXnot_reason = treatedXpost*(1-if_reason)

reghdfe gross_spread_inbp i.(treated post)##(if_reason) TXPXif_reason TXPXnot_reason ///
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

local b_TXPtXdiversify = _b[TXPXif_reason]
local b_TXPtXnot_diversify = _b[TXPXnot_reason]
local se_TXPtXdiversify = _se[TXPXif_reason]
local se_TXPtXnot_diversify = _se[TXPXnot_reason]

// Financial stress of the target
cap drop if_reason TXPXif_reason TXPXnot_reason
gen if_reason = reasonma_fin_stress=="True"
gen TXPXif_reason = treatedXpost*if_reason
gen TXPXnot_reason = treatedXpost*(1-if_reason)

reghdfe gross_spread_inbp i.(treated post)##(if_reason) TXPXif_reason TXPXnot_reason ///
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

local b_TXPtXfin_stress = _b[TXPXif_reason]
local b_TXPtXnot_fin_stress = _b[TXPXnot_reason]
local se_TXPtXfin_stress = _se[TXPXif_reason]
local se_TXPtXnot_fin_stress = _se[TXPXnot_reason]

/* Create a plot */

clear
set obs 7
gen idx = _n
gen desc = ""
gen coef_if_reason = .
gen se_if_reason = .

replace desc = "Acquiror's desire to gain local/regional dominance" if idx==1
replace coef_if_reason = `b_TXPtXlocal_dom' if idx==1
replace se_if_reason = `se_TXPtXlocal_dom' if idx==1

replace desc = "Acquiror's desire to expand geographically" if idx==2
replace coef_if_reason = `b_TXPtXexpand_geo' if idx==2
replace se_if_reason = `se_TXPtXexpand_geo' if idx==2

replace desc = "Acquiror's desire to gain industry-wide dominance" if idx==3
replace coef_if_reason = `b_TXPtXind_dom' if idx==3
replace se_if_reason = `se_TXPtXind_dom' if idx==3

replace desc = "Synergy from combining different lines of business" if idx==4
replace coef_if_reason = `b_TXPtXsyn_comb_lines' if idx==4
replace se_if_reason = `se_TXPtXsyn_comb_lines' if idx==4

replace desc = "Synergy from cost management" if idx==5
replace coef_if_reason = `b_TXPtXsyn_cost' if idx==5
replace se_if_reason = `se_TXPtXsyn_cost' if idx==5

replace desc = "Acquiror's desire to diversify its revenue sources" if idx==6
replace coef_if_reason = `b_TXPtXdiversify' if idx==6
replace se_if_reason = `se_TXPtXdiversify' if idx==6

replace desc = "Financial stress of the target" if idx==7
replace coef_if_reason = `b_TXPtXfin_stress' if idx==7
replace se_if_reason = `se_TXPtXfin_stress' if idx==7

gen upper_if_reason = coef_if_reason+1.96*se_if_reason
gen lower_if_reason = coef_if_reason-1.96*se_if_reason

twoway ///
(scatter idx coef_if_reason) ///
(rcap upper_if_reason lower_if_reason idx, horizontal), ///
ytitle("") xtitle("Effects on Underwriting Spread (in bps.)") xline(0, lpattern(dash)) legend(label(1 "Coef") label(2 "95% CI") position(2) col(1) ring(0)) ///
ylabel( ///
1 "Acquiror's desire to gain local/regional dominance" ///
2 "Acquiror's desire to expand geographically" ///
3 "Acquiror's desire to gain industry-wide dominance" ///
4 "Synergy from combining different lines of business" ///
5 "Synergy from cost management" ///
6 "Acquiror's desire to diversify its revenue sources" ///
7 "Financial stress of the target", ///
angle(0)) ///
yscale(range(0,7.5)) ysc(reverse) xsize(10) ysize(5)
graph export "../Draft/figs/EffectByMAReason.eps", replace



/* Figure: Plot frequency of each use of proceeds */

import delimited "../CleanData/SDC/1A_GPF_OLS.csv", clear 

gen use_of_proceeds = ""
replace use_of_proceeds = "Genl Purpose/ Public Imp" if ///
	use_of_proceeds_general=="Genl Purpose/ Public Imp"
replace use_of_proceeds = "Education" if ///
	use_of_proceeds_general=="Education"| ///
	use_of_proceeds_general=="Student Loans"
replace use_of_proceeds = "Housing" if ///
	use_of_proceeds_general=="Multi Family Housing"| ///
	use_of_proceeds_general=="Single Family Housing"
replace use_of_proceeds = "Utilities" if ///
	use_of_proceeds_general=="Water, Sewer & Gas Facs"| ///
	use_of_proceeds_general=="Electric & Public Power"| ///
	use_of_proceeds_general=="Combined Utilities"
replace use_of_proceeds = "Transportation" if ///
	use_of_proceeds_general=="Transportation"| ///
	use_of_proceeds_general=="Airports"| ///
	use_of_proceeds_general=="Seaports/Marine Terminals"
replace use_of_proceeds = "Health Care" if ///
	use_of_proceeds_general=="Health Care"| ///
	use_of_proceeds_general=="Nursing Homes/ Life Care"
replace use_of_proceeds = "Economic Development" if ///
	use_of_proceeds_general=="Economic Development"| ///
	use_of_proceeds_general=="Industrial Development"
replace use_of_proceeds = "Pollution Control" if ///
	use_of_proceeds_general=="Solid Waste/ Resource Rec"| ///
	use_of_proceeds_general=="Pollution Control"

keep use_of_proceeds amount

collapse (count) amount, by(use_of_proceeds)

rename amount N

gsort - N

gen idx = _n

replace N = N/1000
twoway ///
(bar N idx, barwidth(0.5)), ///
xtitle("") ytitle("N of Issues (in Thousands)") ///
xlabel(1 "General Purpose" 2 "Education" 3 "Utilities" 4 "Housing" 5 "Economic Development" 6 "Health Care" 7 "Transportation" 8 "Pollution Control",angle(45)) ///
xscale(range(0,8.5)) 
graph export "../Draft/figs/FrequencyByUse.eps", replace




/*------------------------------------------*/
/* Figure: Heterogeneity in effects, part I */
/*------------------------------------------*/

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

/* Column 1 */

gen if_hhi_dif_100_200 = hhi_dif>=0.01&hhi_dif<0.02
gen TXPXhhi_dif_100_200 = treatedXpost*(hhi_dif>=0.01&hhi_dif<0.02)
label var TXPXhhi_dif_100_200 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ in [100,200)"

gen if_hhi_dif_200_300 = hhi_dif>=0.02&hhi_dif<0.03
gen TXPXhhi_dif_200_300 = treatedXpost*(hhi_dif>=0.02&hhi_dif<0.03)
label var TXPXhhi_dif_200_300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ in [200,300)"

gen if_hhi_dif_gt300 = hhi_dif>0.03&hhi_dif!=.
gen TXPXhhi_dif_gt300 = treatedXpost*(hhi_dif>0.03&hhi_dif!=.)
label var TXPXhhi_dif_gt300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ $\ge$ 300"

// Column 1: By increased in HHI induced by merger
reghdfe gross_spread_inbp treated post if_hhi_dif_200_300 if_hhi_dif_gt300 ///
TXPXhhi_dif_100_200 TXPXhhi_dif_200_300 TXPXhhi_dif_gt300 /// 
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

local b_TXPXhhi_dif_100_200 = _b[TXPXhhi_dif_100_200]
local b_TXPXhhi_dif_200_300 = _b[TXPXhhi_dif_200_300]
local b_TXPXhhi_dif_gt300 = _b[TXPXhhi_dif_gt300]
local se_TXPXhhi_dif_100_200 = _se[TXPXhhi_dif_100_200]
local se_TXPXhhi_dif_200_300 = _se[TXPXhhi_dif_200_300]
local se_TXPXhhi_dif_gt300 = _se[TXPXhhi_dif_gt300]

/* Column 2 */

// Calculate an average HHI during sample period to avoid picking up heterogeneity in effects over time
preserve
keep hhi_by_n county calendar_year
duplicates drop county calendar_year, force
bysort county: egen avghhi_by_n = mean(hhi_by_n)
drop calendar_year hhi_by_n
duplicates drop county, force
tempfile avghhi_by_n
save `avghhi_by_n', replace
restore

merge m:1 county using `avghhi_by_n'

gen if_avghhi_lt1000 = (avghhi_by_n<0.1)
gen TXPXavghhi_lt1000 = treatedXpost*(avghhi_by_n<0.1)
label var TXPXavghhi_lt1000 "Treated $\times$ Post $\times$ HHI $\le$ 1000"

gen if_avghhi_1000_2500 = (avghhi_by_n>=0.1&avghhi_by_n<0.25)
gen TXPXavghhi_1000_2500 = treatedXpost*(avghhi_by_n>=0.1&avghhi_by_n<0.25)
label var TXPXavghhi_1000_2500 "Treated $\times$ Post $\times$ HHI in [1000,2500)"

gen if_avghhi_gt2500 = (avghhi_by_n>=0.25)&(avghhi_by_n!=.)
gen TXPXavghhi_gt2500 = treatedXpost*(avghhi_by_n>=0.25)&(avghhi_by_n!=.)
label var TXPXavghhi_gt2500 "Treated $\times$ Post $\times$ HHI $\ge$ 2500"

// Column 2: By initial HHI
reghdfe gross_spread_inbp (i.treated i.post)##(i.if_avghhi_1000_2500 i.if_avghhi_gt2500) ///
TXPXavghhi_lt1000 TXPXavghhi_1000_2500 TXPXavghhi_gt2500 /// 
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

local b_TXPXavghhi_lt1000 = _b[TXPXavghhi_lt1000]
local b_TXPXavghhi_1000_2500 = _b[TXPXavghhi_1000_2500]
local b_TXPXavghhi_gt2500 = _b[TXPXavghhi_gt2500]

local se_TXPXavghhi_lt1000 = _se[TXPXavghhi_lt1000]
local se_TXPXavghhi_1000_2500 = _se[TXPXavghhi_1000_2500]
local se_TXPXavghhi_gt2500 = _se[TXPXavghhi_gt2500]

/* Column 3 */

gen if_advisor_coded = if_advisor=="Yes"
label var if_advisor_coded "Has Advisor"

gen TXPXhas_advisor = treatedXpost*(if_advisor=="Yes")
label var TXPXhas_advisor "Treated $\times$ Post $\times$ Has Advisor"

gen TXPXno_advisor = treatedXpost*(if_advisor=="No")
label var TXPXno_advisor "Treated $\times$ Post $\times$ No Advisor"

// Column 3: By whether employing an advisor
reghdfe gross_spread_inbp (i.treated i.post)##(i.if_advisor_coded) TXPXhas_advisor TXPXno_advisor /// 
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

local b_TXPXhas_advisor = _b[TXPXhas_advisor]
local b_TXPXno_advisor = _b[TXPXno_advisor]
local se_TXPXhas_advisor = _se[TXPXhas_advisor]
local se_TXPXno_advisor = _se[TXPXno_advisor]

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
1 "{it:Predicted} {&Delta}{sub:HHI} in [100,200)" 2 "{it:Predicted} {&Delta}{sub:HHI} in [200,300)" 3 "{it:Predicted} {&Delta}{sub:HHI} > 300" ///
4.5 "HHI < 1000" 5.5 "HHI in [1000,2500)" 6.5 "HHI > 2500" ///
8 "Has Advisor" 9 "No Advisor", angle(45) noticks) ///
xscale(range(-0.5,10)) ///
ytitle("Effects on Underwriting Spread (in bps.)") xtitle("") /// 
legend(off) ///
yline(0.1, lpattern(dash) lcolor(red))
graph export "../Draft/figs/GrossSpread_Around_MA_Het1.eps", replace




/*-------------------------------------------*/
/* Figure: Heterogeneity in effects, part II */
/*-------------------------------------------*/

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

/* Column 1 */

encode bid, gen(bid_coded)

gen TXPXbidC = treatedXpost*(bid=="C")
label var TXPXbidC "Treated $\times$ Post $\times$ Competitive Bidding"

gen TXPXbidN = treatedXpost*(bid=="N")
label var TXPXbidN "Treated $\times$ Post $\times$ Negotiated Sales"

// Column 1: Either competitive bidding or negotiated sales
reghdfe gross_spread_inbp (i.treated i.post)##(i.bid_coded) TXPXbidC TXPXbidN /// 
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

local b_TXPXbidC = _b[TXPXbidC]
local b_TXPXbidN = _b[TXPXbidN]

local se_b_TXPXbidC = _se[TXPXbidC]
local se_b_TXPXbidN = _se[TXPXbidN]

/* Column 2 */

encode taxable_code, gen(taxable_code_coded)

gen TXPXtaxableE = treatedXpost*(taxable_code=="E")
label var TXPXtaxableE "Treated $\times$ Post $\times$ Tax-Exempt"

gen TXPXtaxableT = treatedXpost*(taxable_code=="T")
label var TXPXtaxableT "Treated $\times$ Post $\times$ Taxable"

gen TXPXtaxableA = treatedXpost*(taxable_code=="A")
label var TXPXtaxableA "Treated $\times$ Post $\times$ Alternative Minimum Tax"

// Column 2: By taxable or exempt
reghdfe gross_spread_inbp (i.treated i.post)##(i.taxable_code_coded) TXPXtaxableE TXPXtaxableT TXPXtaxableA /// 
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

local b_TXPXtaxableE = _b[TXPXtaxableE]
local b_TXPXtaxableT = _b[TXPXtaxableT]
local b_TXPXtaxableA = _b[TXPXtaxableA]

local se_TXPXtaxableE = _se[TXPXtaxableE]
local se_TXPXtaxableT = _se[TXPXtaxableT]
local se_TXPXtaxableA = _se[TXPXtaxableA]

/* Column 3 */

encode security_type, gen(security_type_coded)

gen TXPXsectypeREV = treatedXpost*(security_type=="RV")
label var TXPXsectypeREV "Treated $\times$ Post $\times$ REV"

gen TXPXsectypeGO = treatedXpost*(security_type=="GO")
label var TXPXsectypeGO "Treated $\times$ Post $\times$ GO"

// Column 3: By Revenue or Go
reghdfe gross_spread_inbp (i.treated i.post)##(i.security_type_coded) TXPXsectypeREV TXPXsectypeGO /// 
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

local b_TXPXsectypeREV = _b[TXPXsectypeREV]
local b_TXPXsectypeGO = _b[TXPXsectypeGO]

local se_TXPXsectypeREV = _se[TXPXsectypeREV]
local se_TXPXsectypeGO = _se[TXPXsectypeGO]

/* Column 4 */

gen if_before2000 = (calendar_year-year_to_merger<=2000)

gen TXPXbefore2000 = treatedXpost*(calendar_year-year_to_merger<=2000)
label var TXPXbefore2000 "Treated $\times$ Post $\times$ Pre-2000"

gen TXPXafter2000 = treatedXpost*(calendar_year-year_to_merger>2000)
label var TXPXafter2000 "Treated $\times$ Post $\times$ Post-2000"

// Column 4: By whether before or after 2000
reghdfe gross_spread_inbp (i.treated i.post)##(i.if_before2000) TXPXbefore2000 TXPXafter2000 /// 
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

local b_TXPXbefore2000 = _b[TXPXbefore2000]
local b_TXPXafter2000 = _b[TXPXafter2000]

local se_TXPXbefore2000 = _se[TXPXbefore2000]
local se_TXPXafter2000 = _se[TXPXafter2000]

/* Column 5 */

gen if_bank_is_either = (bank_is_acquiror=="True")|(bank_is_target=="True")
gen TXPXbank_is_either = treatedXpost*(bank_is_acquiror=="True")|(bank_is_target=="True")
replace if_bank_is_either = 0 if treated==0
replace TXPXbank_is_either = 0 if treated==0
label var TXPXbank_is_either "Treated $\times$ Post $\times$ Bank is in M\&A"

gen if_bank_is_neither = (bank_is_acquiror!="True")&(bank_is_target!="True")
gen TXPXbank_is_neither = treatedXpost*(bank_is_acquiror!="True")&(bank_is_target!="True")
replace if_bank_is_neither = 0 if treated==0
replace TXPXbank_is_neither = 0 if treated==0
label var TXPXbank_is_neither "Treated $\times$ Post $\times$ Bank is not in M\&A"

// Column 5: By whether bank is a target bank
reghdfe gross_spread_inbp ///
(i.treated)##(if_bank_is_either if_bank_is_neither) i.post TXPXbank_is_either TXPXbank_is_neither ///
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

local b_TXPXbank_is_either = _b[TXPXbank_is_either]
local b_TXPXbank_is_neither = _b[TXPXbank_is_neither]
local se_TXPXbank_is_either = _se[TXPXbank_is_either]
local se_TXPXbank_is_neither = _se[TXPXbank_is_neither]

clear
set obs 16
gen idx = _n
gen label = ""
gen coef = .
gen se = .

replace label = "Competitive Bidding" if idx==1
replace coef = `b_TXPXbidC' if idx==1
replace se = `se_b_TXPXbidC' if idx==1
replace label = "Negotiated Sales" if idx==2
replace coef = `b_TXPXbidN' if idx==2
replace se = `se_b_TXPXbidN' if idx==2

replace label = "Taxable" if idx==4
replace coef = `b_TXPXtaxableT' if idx==4
replace se = `se_TXPXtaxableT' if idx==4
replace label = "Tax-Exempt" if idx==5
replace coef = `b_TXPXtaxableE' if idx==5
replace se = `se_TXPXtaxableE' if idx==5
replace label = "Alternative Minimum Tax" if idx==6
replace coef = `b_TXPXtaxableA' if idx==6
replace se = `se_TXPXtaxableA' if idx==6

replace label = "Revenue Bond" if idx==8
replace coef = `b_TXPXsectypeREV' if idx==8
replace se = `se_TXPXsectypeREV' if idx==8
replace label = "Go Bond" if idx==9
replace coef = `b_TXPXsectypeGO' if idx==9
replace se = `se_TXPXsectypeGO' if idx==9

replace label = "Pre-2000" if idx==11
replace coef = `b_TXPXbefore2000' if idx==11
replace se = `se_TXPXbefore2000' if idx==11
replace label = "Post-2000" if idx==12
replace coef = `b_TXPXafter2000' if idx==12
replace se = `se_TXPXafter2000' if idx==12

replace label = "Bank is in M&A" if idx==14
replace coef = `b_TXPXbank_is_either' if idx==14
replace se = `se_TXPXbank_is_either' if idx==14
replace label = "Bank is not in M&A" if idx==15
replace coef = `b_TXPXbank_is_neither' if idx==15
replace se = `se_TXPXbank_is_neither' if idx==15

gen low95 = coef-1.95*se
gen high95 = coef+1.95*se

gen group = .
replace group = 1 if idx==1|idx==2
replace group = 2 if idx==4|idx==5|idx==6
replace group = 3 if idx==8|idx==9
replace group = 4 if idx==11|idx==12
replace group = 5 if idx==14|idx==15

twoway ///
(rcap low95 high95 idx if group==1, vertical lcolor(orange*0.3)) ///
(rcap low95 high95 idx if group==2, vertical lcolor(green*0.3)) ///
(rcap low95 high95 idx if group==3, vertical lcolor(blue*0.3)) ///
(rcap low95 high95 idx if group==4, vertical lcolor(purple*0.3)) ///
(rcap low95 high95 idx if group==5, vertical lcolor(red*0.3)) ///
(scatter coef idx if group ==1, mcolor(orange)) ///
(scatter coef idx if group ==2, mcolor(green)) ///
(scatter coef idx if group ==3, mcolor(blue)) ///
(scatter coef idx if group ==4, mcolor(purple)) ///
(scatter coef idx if group ==5, mcolor(red)) ///
, xlabel( ///
1 "Competitive Bidding" 2 "Negotiated Sales" ///
4 "Taxable" 5 "Tax-Exempt" 6 "Alternative Minimum Tax" ///
8 "Revenue Bond" 9 "GO Bond" ///
11 "Pre-2000" 12 "Post-2000" ///
14 "Bank is in M&A" 15 "Bank is not in M&A" ///
, angle(45) noticks) ///
xscale(range(-0.5,16.5)) ///
ytitle("Effects on Underwriting Spread (in bps.)") xtitle("") /// 
legend(off) ///
yline(0.1, lpattern(dash) lcolor(red))
graph export "../Draft/figs/GrossSpread_Around_MA_Het2.eps", replace



/*--------------------------------------------*/
/* Figure: Heterogeneity in effects, part III */
/*--------------------------------------------*/

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

/* Column 1 */

gen if0to1relation = num_relationship<=1
gen TXPX0to1relation = treatedXpost*if0to1relation
label var TXPX0to1relation "Treated $\times$ Post $\times$ 0-1 Relationship"

gen if2to3relation = (num_relationship>=2)&(num_relationship<=3)
gen TXPX2to3relation = treatedXpost*if2to3relation
label var TXPX2to3relation "Treated $\times$ Post $\times$ 2-3 Relationship"

gen if4to5relation = (num_relationship>=4)&(num_relationship<=5)
gen TXPX4to5relation = treatedXpost*if4to5relation
label var TXPX4to5relation "Treated $\times$ Post $\times$ 4-5 Relationship"

gen ifover5relation = num_relationship>5
gen TXPXover5relation = treatedXpost*ifover5relation
label var TXPXover5relation "Treated $\times$ Post $\times$ More than 5 Relationships"

// Column 1: By prior relationship of the issuer with the bank
reghdfe gross_spread_inbp (i.treated i.post)##(if0to1relation if2to3relation if4to5relation ifover5relation) ///
TXPX0to1relation TXPX2to3relation TXPX4to5relation TXPXover5relation /// 
if year_to_merger>=-4&year_to_merger<=7, ///
absorb(i.issuer_code##i.issuer_type##i.episode_start_year##i.treated_csa calendar_year) ///
cluster(csacode calendar_year)

local b_if0to1relation = _b[TXPX0to1relation]
local b_if2to3relation = _b[TXPX2to3relation]
local b_if4to5relation = _b[TXPX4to5relation]
local b_ifover5relation = _b[TXPXover5relation]

local se_if0to1relation = _se[TXPX0to1relation]
local se_if2to3relation = _se[TXPX2to3relation]
local se_if4to5relation = _se[TXPX4to5relation]
local se_ifover5relation = _se[TXPXover5relation]

clear
set obs 10
gen idx = _n
gen label = ""
gen coef = .
gen se = .

replace label = "0-1 Relationships" if idx==1
replace coef = `b_if0to1relation' if idx==1
replace se = `se_if0to1relation' if idx==1
replace label = "2-3 Relationships" if idx==2
replace coef = `b_if2to3relation' if idx==2
replace se = `se_if2to3relation' if idx==2
replace label = "4-5 Relationships" if idx==3
replace coef = `b_if4to5relation' if idx==3
replace se = `se_if4to5relation' if idx==3
replace label = "More than 5 Relationships" if idx==4
replace coef = `b_ifover5relation' if idx==4
replace se = `se_ifover5relation' if idx==4

gen low95 = coef-1.95*se
gen high95 = coef+1.95*se

gen group = .
replace group = 1 if idx==1|idx==2|idx==3|idx==4

twoway ///
(rcap low95 high95 idx if group==1 , horizontal lcolor(orange*0.3)) ///
(scatter idx coef if group ==1, mcolor(orange)) ///
, ylabel( ///
1 "0-1 Relationships" 2 "2-3 Relationships" 3 "4-5 Relationships" 4 "More than 5 Relationships" ///
, angle(0) noticks labsize(vlarge)) ///
xlabel( ///
0 "0" 5 "5" 10 "10" 15 "15" ///
, angle(0) noticks labsize(vlarge)) ///
yscale(range(0.5,4.5)) ///
xscale(range(-0.5,12.5)) ///
xtitle("Effects on Underwriting Spread (in bps.)", size(vlarge)) ytitle("", size(vlarge)) /// 
legend(off) ///
xline(0.1, lpattern(dash) lcolor(red)) ///
xsize(5) ysize(2)
graph export "../Draft/figs/GrossSpread_Around_MA_Het3.eps", replace

