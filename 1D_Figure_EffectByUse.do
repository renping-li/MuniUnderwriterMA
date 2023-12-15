
// To be done: The "N" should be pulled from GPF, not the matched T-C sample

set scheme s1color

/*---------------------------------------------------------------*/
/* Figure: Effects of M&A on gross spread by the use of proceeds */
/*---------------------------------------------------------------*/

if "$MainThreshold" == "HHI" {
	import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear
}
else if "$MainThreshold" == "MarketShare" {
	import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear
}

gen gross_spread_inbp = gross_spread*10

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated X Post"

encode issuer, gen(issuer_code)

/* Using BB purpose */

gen if_gp = use_of_proceeds_bb=="General Purpose"
gen if_gpXtreated = if_gp*treated
gen if_gpXpost = if_gp*post
gen if_gpXtreatedXpost = if_gp*treatedXpost

gen if_edu = use_of_proceeds_bb=="Education"
gen if_eduXtreated = if_edu*treated
gen if_eduXpost = if_edu*post
gen if_eduXtreatedXpost = if_edu*treatedXpost

gen if_util = use_of_proceeds_bb=="Utilities"
gen if_utilXtreated = if_util*treated
gen if_utilXpost = if_util*post
gen if_utilXtreatedXpost = if_util*treatedXpost

gen if_house = use_of_proceeds_bb=="Housing"
gen if_houseXtreated = if_house*treated
gen if_houseXpost = if_house*post
gen if_houseXtreatedXpost = if_house*treatedXpost

gen if_pf = use_of_proceeds_bb=="Public Facilities"
gen if_pfXtreated = if_pf*treated
gen if_pfXpost = if_pf*post
gen if_pfXtreatedXpost = if_pf*treatedXpost

gen if_dvp = use_of_proceeds_bb=="Development"
gen if_dvpXtreated = if_dvp*treated
gen if_dvpXpost = if_dvp*post
gen if_dvpXtreatedXpost = if_dvp*treatedXpost

gen if_tsp = use_of_proceeds_bb=="Transportation"
gen if_tspXtreated = if_tsp*treated
gen if_tspXpost = if_tsp*post
gen if_tspXtreatedXpost = if_tsp*treatedXpost

gen if_health = use_of_proceeds_bb=="Healthcare"
gen if_healthXtreated = if_health*treated
gen if_healthXpost = if_health*post
gen if_healthXtreatedXpost = if_health*treatedXpost

gen if_power = use_of_proceeds_bb=="Electric Power"
gen if_powerXtreated = if_power*treated
gen if_powerXpost = if_power*post
gen if_powerXtreatedXpost = if_power*treatedXpost

gen if_env = use_of_proceeds_bb=="Environmental Facilities"
gen if_envXtreated = if_env*treated
gen if_envXpost = if_env*post
gen if_envXtreatedXpost = if_env*treatedXpost

reghdfe gross_spread_inbp ///
i.(treated post)##( ///
if_gp ///
if_edu ///
if_util ///
if_house ///
if_pf ///
if_dvp ///
if_tsp ///
if_health ///
if_power ///
if_env) ///
if_gpXtreatedXpost ///
if_eduXtreatedXpost ///
if_utilXtreatedXpost ///
if_houseXtreatedXpost ///
if_pfXtreatedXpost ///
if_dvpXtreatedXpost ///
if_tspXtreatedXpost ///
if_healthXtreatedXpost ///
if_powerXtreatedXpost ///
if_envXtreatedXpost ///
, ///
absorb(i.issuer_code##i.issuer_type i.calendar_year) cluster(i.issuer_code##i.issuer_type)

/* Using general purpose */

drop if_*

gen if_gp = use_of_proceeds_general=="Genl Purpose/ Public Imp"
gen if_gpXtreated = if_gp*treated
gen if_gpXpost = if_gp*post
gen if_gpXtreatedXpost = if_gp*treatedXpost

gen if_edu = use_of_proceeds_general=="Education"
gen if_eduXtreated = if_edu*treated
gen if_eduXpost = if_edu*post
gen if_eduXtreatedXpost = if_edu*treatedXpost

gen if_util = use_of_proceeds_general=="Water, Sewer & Gas Facs"
gen if_utilXtreated = if_util*treated
gen if_utilXpost = if_util*post
gen if_utilXtreatedXpost = if_util*treatedXpost

gen if_mfh = use_of_proceeds_general=="Multi Family Housing"
gen if_mfhXtreated = if_mfh*treated
gen if_mfhXpost = if_mfh*post
gen if_mfhXtreatedXpost = if_mfh*treatedXpost

gen if_tsp = use_of_proceeds_general=="Transportation"
gen if_tspXtreated = if_tsp*treated
gen if_tspXpost = if_tsp*post
gen if_tspXtreatedXpost = if_tsp*treatedXpost

gen if_health = use_of_proceeds_general=="Health Care"
gen if_healthXtreated = if_health*treated
gen if_healthXpost = if_health*post
gen if_healthXtreatedXpost = if_health*treatedXpost

gen if_ed = use_of_proceeds_general=="Economic Development"
gen if_edXtreated = if_ed*treated
gen if_edXpost = if_ed*post
gen if_edXtreatedXpost = if_ed*treatedXpost

gen if_id = use_of_proceeds_general=="Industrial Development"
gen if_idXtreated = if_id*treated
gen if_idXpost = if_id*post
gen if_idXtreatedXpost = if_id*treatedXpost

gen if_sfh = use_of_proceeds_general=="Single Family Housing"
gen if_sfhXtreated = if_sfh*treated
gen if_sfhXpost = if_sfh*post
gen if_sfhXtreatedXpost = if_sfh*treatedXpost

gen if_nh = use_of_proceeds_general=="Nursing Homes/ Life Care"
gen if_nhXtreated = if_nh*treated
gen if_nhXpost = if_nh*post
gen if_nhXtreatedXpost = if_nh*treatedXpost

gen if_elec = use_of_proceeds_general=="Electric & Public Power"
gen if_elecXtreated = if_elec*treated
gen if_elecXpost = if_elec*post
gen if_elecXtreatedXpost = if_elec*treatedXpost

gen if_air = use_of_proceeds_general=="Airports"
gen if_airXtreated = if_air*treated
gen if_airXpost = if_air*post
gen if_airXtreatedXpost = if_air*treatedXpost

gen if_waste = use_of_proceeds_general=="Solid Waste/ Resource Rec"
gen if_wasteXtreated = if_waste*treated
gen if_wasteXpost = if_waste*post
gen if_wasteXtreatedXpost = if_waste*treatedXpost

gen if_pollute = use_of_proceeds_general=="Pollution Control"
gen if_polluteXtreated = if_pollute*treated
gen if_polluteXpost = if_pollute*post
gen if_polluteXtreatedXpost = if_pollute*treatedXpost

gen if_cu = use_of_proceeds_general=="Combined Utilities"
gen if_cuXtreated = if_cu*treated
gen if_cuXpost = if_cu*post
gen if_cuXtreatedXpost = if_cu*treatedXpost

gen if_seaport = use_of_proceeds_general=="Seaports/Marine Terminals"
gen if_seaportXtreated = if_seaport*treated
gen if_seaportXpost = if_seaport*post
gen if_seaportXtreatedXpost = if_seaport*treatedXpost

gen if_sl = use_of_proceeds_general=="Student Loans"
gen if_slXtreated = if_sl*treated
gen if_slXpost = if_sl*post
gen if_slXtreatedXpost = if_sl*treatedXpost

reghdfe gross_spread_inbp ///
i.(treated post)##( ///
if_gp ///
if_edu ///
if_util ///
if_mfh ///
if_tsp ///
if_health ///
if_ed ///
if_id ///
if_sfh ///
if_nh ///
if_elec ///
if_air ///
if_waste ///
if_pollute ///
if_cu ///
if_seaport ///
if_sl) ///
if_gpXtreatedXpost ///
if_eduXtreatedXpost ///
if_utilXtreatedXpost ///
if_mfhXtreatedXpost ///
if_tspXtreatedXpost ///
if_healthXtreatedXpost ///
if_edXtreatedXpost ///
if_idXtreatedXpost ///
if_sfhXtreatedXpost ///
if_nhXtreatedXpost ///
if_elecXtreatedXpost ///
if_airXtreatedXpost ///
if_wasteXtreatedXpost ///
if_polluteXtreatedXpost ///
if_cuXtreatedXpost ///
if_seaportXtreatedXpost ///
if_slXtreatedXpost ///
, ///
absorb(i.issuer_code##i.issuer_type i.calendar_year) cluster(i.issuer_code##i.issuer_type)

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
, ///
absorb(i.issuer_code##i.issuer_type i.calendar_year) cluster(i.issuer_code##i.issuer_type)

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
xtitle("") ytitle("Effects on underwriting spread (in bps.)") yline(0, lpattern(dash)) legend(label(1 "Coef") label(2 "95% CI") position(11) col(1) ring(0)) ///
xlabel(1 "General Purpose" 2 "Education" 3 "Utilities" 4 "Housing" 5 "Economic Development" 6 "Health Care" 7 "Transportation" 8 "Pollution Control",angle(45)) ///
xscale(range(0,8.5))
graph export "../Slides/figs/EffectByUse.eps", replace



/* Figure: Plot frequency of each use of proceeds */

import delimited "../CleanData/MAEvent/GPF.csv", clear 

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
xtitle("") ytitle("N of issues (in thousands)") ///
xlabel(1 "General Purpose" 2 "Education" 3 "Utilities" 4 "Housing" 5 "Economic Development" 6 "Health Care" 7 "Transportation" 8 "Pollution Control",angle(45)) ///
xscale(range(0,8.5)) 
graph export "../Slides/figs/FrequencyByUse.eps", replace


