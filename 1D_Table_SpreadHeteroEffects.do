
// If HHI cross-section not working: Consider redo HHI calculation by doing it with several years data. Even though HHI do not work with DeltaHHI, it is close, so could be just noise

/*----------------------------------------------------------------------*/
/* Table: Cross-sectional heterogeneity of effects of spread around M&A */
/*----------------------------------------------------------------------*/

// Note that for some cross-sectional variables, it does not make sense to have a variable X post term. For example,
// for "Delta HHI", the variable only applies to the treated and not to the control, so it does not make sense to interact
// it with "Post". Similary, it is so for the dummy of whether bank is involved in the M&A.


/* Panel 1: By economics of where market power could have bigger effects */

local outfile =  "../Slides/tabs/DID_MA_GrossSpread_hetero_1.tex"
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

/* Column 1 */

/* Alternative specification: "hhi_dif" */

if "$MainThreshold" == "HHI" {
	gen if_hhi_dif_200_300 = hhi_dif>=0.02&hhi_dif<0.03
	gen treatedXpostXhhi_dif_200_300 = treatedXpost*(hhi_dif>=0.02&hhi_dif<0.03)
	label var treatedXpostXhhi_dif_200_300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ in [200,300)"

	gen if_hhi_dif_gt300 = hhi_dif>0.03&hhi_dif!=.
	gen treatedXpostXhhi_dif_gt300 = treatedXpost*(hhi_dif>0.03&hhi_dif!=.)
	label var treatedXpostXhhi_dif_gt300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ $\ge$ 300"

	// Column 1: By increased in HHI induced by merger
	reghdfe gross_spread_inbp treated post if_hhi_dif_200_300 if_hhi_dif_gt300 ///
	treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300, /// 
	absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
	outreg2 using  "`outfile'", tex(fragment) replace label ///
	keep(treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

	/* Effects when Delta HHI above 2500 */

	local spread_effects_if_hhi_dif_gt300 = _b[treatedXpost]+_b[treatedXpostXhhi_dif_gt300]
	local spread_effects_if_hhi_dif_gt300 : display %-9.1f `spread_effects_if_hhi_dif_gt300'
	file open myfile using "../Slides/nums/spread_effects_if_hhi_dif_gt300.tex", write replace
	file write myfile "`spread_effects_if_hhi_dif_gt300'"
	file close myfile
	
}

// Note that other cross-sectional variables can be used, e.g., "max_sum_share", "max_min_share", "mean_sum_share", "hhi_dif", "acquiror_market_share_avg", and "target_market_share_avg"
// Also, other values of cutoffs can be used.

/* Alternative specification: "max_sum_share" */

if "$MainThreshold" == "MarketShare" {
	gen if_max_sum_share_10_25 = max_sum_share>=0.10&max_sum_share<0.25&max_sum_share!=.
	gen TXPXmax_sum_share_10_25 = treatedXpost*if_max_sum_share_10_25
	label var TXPXmax_sum_share_10_25 "Treated $\times$ Post $\times$ Market Share in [0.10,0.25)"

	gen if_max_sum_share_gt_25 = max_sum_share>=0.25&max_sum_share!=.
	gen TXPXmax_sum_share_gt_25 = treatedXpost*if_max_sum_share_gt_25
	label var TXPXmax_sum_share_gt_25 "Treated $\times$ Post $\times$ Market Share $\ge$ 0.25"

	reghdfe gross_spread_inbp i.post (i.treated)##(i.if_max_sum_share_gt_25) ///
	treatedXpost TXPXmax_sum_share_gt_25, /// 
	absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)

	// Column 1: By market share of merging entities
	reghdfe gross_spread_inbp i.post (i.treated)##(i.if_max_sum_share_10_25 i.if_max_sum_share_gt_25) ///
	treatedXpost TXPXmax_sum_share_10_25 TXPXmax_sum_share_gt_25, /// 
	absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
	outreg2 using  "`outfile'", tex(fragment) replace label ///
	keep(treatedXpost treatedXpostXmax_sum_share_10_25 treatedXpostXmax_sum_share_gt_25) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")
}
	
/* Alternative specification: "mean_sum_share" */

/*

gen if_mean_sum_share_10_25 = mean_sum_share>=0.10&mean_sum_share<0.25&mean_sum_share!=.
gen TXPXmean_sum_share_10_25 = treatedXpost*if_mean_sum_share_10_25
label var TXPXmean_sum_share_10_25 "Treated $\times$ Post $\times$ Market Share in [0.10,0.25)"

gen if_mean_sum_share_gt_25 = mean_sum_share>=0.25&mean_sum_share!=.
gen TXPXmean_sum_share_gt_25 = treatedXpost*if_mean_sum_share_gt_25
label var TXPXmean_sum_share_gt_25 "Treated $\times$ Post $\times$ Market Share $\ge$ 0.25"

// Column 1: By market share of merging entities
reghdfe gross_spread_inbp i.post (i.treated)##(i.if_mean_sum_share_10_25 i.if_mean_sum_share_gt_25) ///
treatedXpost TXPXmean_sum_share_10_25 TXPXmean_sum_share_gt_25, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label ///
keep(treatedXpost treatedXpostXmean_sum_share_10_25 treatedXpostXmean_sum_share_gt_25) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

*/

/* Column 2 */

bysort county: egen avghhi_by_n = mean(hhi_by_n)

gen if_avghhi_1000_2500 = (avghhi_by_n>=0.1&avghhi_by_n<0.25)
gen treatedXpostXavghhi_1000_2500 = treatedXpost*(avghhi_by_n>=0.1&avghhi_by_n<0.25)
label var treatedXpostXavghhi_1000_2500 "Treated $\times$ Post $\times$ HHI in [1000,2500)"

gen if_avghhi_gt2500 = (avghhi_by_n>=0.25)
gen treatedXpostXavghhi_gt2500 = treatedXpost*(avghhi_by_n>=0.25)
label var treatedXpostXavghhi_gt2500 "Treated $\times$ Post $\times$ HHI $\ge$ 2500"

// Column 2: By initial HHI
reghdfe gross_spread_inbp (i.treated i.post)##(i.if_avghhi_1000_2500 i.if_avghhi_gt2500) ///
treatedXpost treatedXpostXavghhi_1000_2500 treatedXpostXavghhi_gt2500, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost treatedXpostXavghhi_1000_2500 treatedXpostXavghhi_gt2500) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Effects when HHI above 2500 */

local spread_effects_if_avghhi_gt2500 = _b[treatedXpost]+_b[treatedXpostXavghhi_gt2500]
local spread_effects_if_avghhi_gt2500 : display %-9.1f `spread_effects_if_avghhi_gt2500'
file open myfile using "../Slides/nums/spread_effects_if_avghhi_gt2500.tex", write replace
file write myfile "`spread_effects_if_avghhi_gt2500'"
file close myfile

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

if "$MainThreshold" == "HHI" {
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(if_advisor_coded treatedXpostXhas_advisor treatedXpostXno_advisor) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer") ///
	sortvar(treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300 ///
	treatedXpostXavghhi_1000_2500 treatedXpostXavghhi_gt2500 ///
	if_advisor_coded treatedXpostXhas_advisor treatedXpostXno_advisor)
}

if "$MainThreshold" == "MarketShare" {
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(if_advisor_coded treatedXpostXhas_advisor treatedXpostXno_advisor) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer") ///
	sortvar(treatedXpost treatedXpostXmean_sum_share_10_25 treatedXpostXmean_sum_share_gt_25 ///
	treatedXpostXavghhi_1000_2500 treatedXpostXavghhi_gt2500 ///
	if_advisor_coded treatedXpostXhas_advisor treatedXpostXno_advisor)
}




/* Panel 2: By feature of interest of the muni market */

local outfile =  "../Slides/tabs/DID_MA_GrossSpread_hetero_2.tex"
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

/* Column 1 */

encode bid, gen(bid_coded)

gen treatedXpostXbidC = treatedXpost*(bid=="C")
label var treatedXpostXbidC "Treated $\times$ Post $\times$ Competitive Bidding"

gen treatedXpostXbidN = treatedXpost*(bid=="N")
label var treatedXpostXbidN "Treated $\times$ Post $\times$ Negotiated Sales"

// Column 1: Either competitive bidding or negotiated sales
reghdfe gross_spread_inbp (i.treated i.post)##(i.bid_coded) treatedXpostXbidC treatedXpostXbidN, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append replace ///
keep(treatedXpostXbidC treatedXpostXbidN) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 2 */

encode taxable_code, gen(taxable_code_coded)

gen treatedXpostXtaxableE = treatedXpost*(taxable_code=="E")
label var treatedXpostXtaxableE "Treated $\times$ Post $\times$ Tax-Exempt"

gen treatedXpostXtaxableT = treatedXpost*(taxable_code=="T")
label var treatedXpostXtaxableT "Treated $\times$ Post $\times$ Taxable"

gen treatedXpostXtaxableA = treatedXpost*(taxable_code=="A")
label var treatedXpostXtaxableA "Treated $\times$ Post $\times$ Alternative Minimum Tax"

// Column 2: Taxable or exempt
reghdfe gross_spread_inbp (i.treated i.post)##(i.taxable_code_coded) treatedXpostXtaxableE treatedXpostXtaxableT treatedXpostXtaxableA, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXtaxableE treatedXpostXtaxableT treatedXpostXtaxableA) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 3 */

encode security_type, gen(security_type_coded)

gen treatedXpostXsectypeREV = treatedXpost*(security_type=="RV")
label var treatedXpostXsectypeREV "Treated $\times$ Post $\times$ REV"

gen treatedXpostXsectypeGO = treatedXpost*(security_type=="GO")
label var treatedXpostXsectypeGO "Treated $\times$ Post $\times$ GO"

// Column 3: Revenue or Go
reghdfe gross_spread_inbp (i.treated i.post)##(i.security_type_coded) treatedXpostXsectypeREV treatedXpostXsectypeGO, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXsectypeREV treatedXpostXsectypeGO) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer") 

/* Column 4 */

gen if_bank_is_acquiror = bank_is_acquiror=="True"
gen treatedXpostXbank_is_acquiror = treatedXpost*(bank_is_acquiror=="True")
label var treatedXpostXbank_is_acquiror "Treated $\times$ Post $\times$ Bank is Acquiror in M\&A"

gen if_bank_is_target = bank_is_target=="True"
gen treatedXpostXbank_is_target = treatedXpost*(bank_is_target=="True")
label var treatedXpostXbank_is_target "Treated $\times$ Post $\times$ Bank is Target in M\&A"

// Column 4: Whether bank is a target bank
reghdfe gross_spread_inbp (i.treated i.post)##(i.if_bank_is_acquiror if_bank_is_target) ///
treatedXpost if_bank_is_acquiror if_bank_is_target treatedXpostXbank_is_acquiror treatedXpostXbank_is_target, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost treatedXpostXbank_is_acquiror treatedXpostXbank_is_target) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer") ///
sortvar(treatedXpost treatedXpostXbidC treatedXpostXbidN ///
treatedXpostXtaxableE treatedXpostXtaxableT treatedXpostXtaxableA ///
treatedXpostXsectypeREV treatedXpostXsectypeGO ///
treatedXpostXbank_is_acquiror treatedXpostXbank_is_target)







/* Panel 3: Miscellaneous heterogeneity */

local outfile =  "../Slides/tabs/DID_MA_GrossSpread_hetero_3.tex"
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

/* Column 1 */

gen if_before2000 = (calendar_year-year_to_merger<=2000)

gen treatedXpostXbefore2000 = treatedXpost*(calendar_year-year_to_merger<=2000)
label var treatedXpostXbefore2000 "Treated $\times$ Post $\times$ Pre-2000"

gen treatedXpostXafter2000 = treatedXpost*(calendar_year-year_to_merger>2000)
label var treatedXpostXafter2000 "Treated $\times$ Post $\times$ Post-2000"

// Column 1: By whether before or after 2000
reghdfe gross_spread_inbp (i.treated i.post)##(i.if_before2000) treatedXpostXbefore2000 treatedXpostXafter2000, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label ///
keep(treatedXpostXbefore2000 treatedXpostXafter2000) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 2 */

gen decade = floor(calendar_year/10)*10
bysort decade csacode: egen median_amount = median(amount)

gen if_small = (amount<=median_amount)
gen treatedXpostXsmall= treatedXpost*(amount<=median_amount)
label var treatedXpostXsmall "Treated $\times$ Post $\times$ Small Deals"

// Column 2: By size of deal
reghdfe gross_spread_inbp (i.treated i.post)##(i.if_small) treatedXpost treatedXpostXsmall, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost treatedXpostXsmall) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 3 */

bysort decade csacode: egen median_avg_maturity = median(avg_maturity)

gen if_long = (avg_maturity>=median_avg_maturity)
gen treatedXpostXlong= treatedXpost*(avg_maturity>=median_avg_maturity)
label var treatedXpostXlong "Treated $\times$ Post $\times$ Long Maturity"

// Column 3: By maturity of deal
reghdfe gross_spread_inbp (i.treated i.post)##(i.if_long) treatedXpost treatedXpostXlong, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost treatedXpostXlong) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 4 */

bysort decade: egen black_ratio_p75 = pctile(black_ratio), p(75)

gen if_black = (black_ratio>black_ratio_p75)&(black_ratio!=.)
gen treatedXpostXblack = treatedXpost*((black_ratio>black_ratio_p75)&(black_ratio!=.))
label var treatedXpostXblack "Treated $\times$ Post $\times$ Black"

// Column 4: By ratio composition
reghdfe gross_spread_inbp (i.treated i.post)##(i.if_black) treatedXpost treatedXpostXblack, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost treatedXpostXblack) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer") ///
sortvar(treatedXpost treatedXpostXbefore2000 treatedXpostXafter2000 ///
treatedXpostXsmall treatedXpostXlong treatedXpostXblack)








/* Table in the Appendix: Can employing an advisor undo market power? */

// Note that variable label is too long and has to be updated by hand in the latex table

local outfile =  "../Slides/tabs/DID_MA_GrossSpread_advisor_undo.tex"
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

/* Column 1 */

gen if_advisor_coded = if_advisor=="Yes"

if "$MainThreshold" == "MarketShare" {

	gen treatedXpostXhas_advisor = treatedXpost*(if_advisor=="Yes")
	label var treatedXpostXhas_advisor "Treated $\times$ Post $\times$ Has Advisor "

	gen if_max_sum_share_10_25 = max_sum_share>=0.15&max_sum_share<0.25&max_sum_share!=.
	gen HAXif_max_sum_share_10_25 = (if_advisor=="Yes")*if_max_sum_share_10_25
	gen TXPXHAXmax_sum_share_10_25 = treatedXpost*(if_advisor=="Yes")*if_max_sum_share_10_25
	label var TXPXHAXmax_sum_share_10_25 "TP $\times$ HA $\times$ Market Share in [0.15,0.25)"

	gen if_max_sum_share_gt_25 = max_sum_share>=0.25&max_sum_share!=.
	gen HAXif_max_sum_share_gt_25 = (if_advisor=="Yes")*if_max_sum_share_gt_25
	gen TXPXHAXmax_sum_share_gt_25 = treatedXpost*(if_advisor=="Yes")*if_max_sum_share_gt_25
	label var TXPXHAXmax_sum_share_gt_25 "TP $\times$ HA $\times$ Market Share $\ge$ 0.25"

	gen treatedXpostXno_advisor = treatedXpost*(if_advisor=="No")
	label var treatedXpostXno_advisor "Treated $\times$ Post $\times$ No Advisor"

	// Note that "HAXif_max_sum_share_10_25" and "HAXif_max_sum_share_gt_25" is not to be interacted with "post"

	// Column 1: By whether employing an advisor, for levels of increased in HHI induced by merger 
	reghdfe gross_spread_inbp (i.treated i.post)##(i.if_advisor_coded) i.treated##(i.HAXif_max_sum_share_10_25 i.HAXif_max_sum_share_gt_25) ///
	treatedXpostXhas_advisor TXPXHAXmax_sum_share_10_25 TXPXHAXmax_sum_share_gt_25 treatedXpostXno_advisor, /// 
	absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
	outreg2 using  "`outfile'", tex(fragment) replace label ///
	keep(treatedXpostXhas_advisor TXPXHAXmax_sum_share_10_25 TXPXHAXmax_sum_share_gt_25 treatedXpostXno_advisor) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")
}

if "$MainThreshold" == "HHI" {

	gen treatedXpostXhas_advisor = treatedXpost*(if_advisor=="Yes")
	label var treatedXpostXhas_advisor "Treated $\times$ Post $\times$ Has Advisor "

	gen if_hhi_dif_200_300 = (if_advisor=="Yes")*(hhi_dif>=0.02&hhi_dif<0.03)
	gen TXPXhas_advisor_hhi_dif_200_300 = treatedXpost*(if_advisor=="Yes")*(hhi_dif>=0.02&hhi_dif<0.03)
	label var TXPXhas_advisor_hhi_dif_200_300 "TP $\times$ HA $\times$ \emph{predicted} $\Delta_{HHI}$ in [0.02,0.03)"

	gen if_hhi_dif_gt_300 = (if_advisor=="Yes")*(hhi_dif>0.03)
	gen TXPXhas_advisor_hhi_dif_gt_300 = treatedXpost*(if_advisor=="Yes")*(hhi_dif>0.03)
	label var TXPXhas_advisor_hhi_dif_gt_300 "TXP $\times$ HA $\times$ \emph{predicted} $\Delta_{HHI}$ $\ge$ 0.03"

	gen treatedXpostXno_advisor = treatedXpost*(if_advisor=="No")
	label var treatedXpostXno_advisor "Treated $\times$ Post $\times$ No Advisor"

	// Column 1: By whether employing an advisor, for levels of increased in HHI induced by merger 
	reghdfe gross_spread_inbp (i.treated i.post)##(i.if_advisor_coded) i.treated##(i.if_hhi_dif_200_300 i.if_hhi_dif_gt_300) ///
	treatedXpostXhas_advisor TXPXhas_advisor_hhi_dif_200_300 TXPXhas_advisor_hhi_dif_gt_300 treatedXpostXno_advisor, /// 
	absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
	outreg2 using  "`outfile'", tex(fragment) replace label ///
	keep(treatedXpostXhas_advisor TXPXhas_advisor_hhi_dif_200_300 TXPXhas_advisor_hhi_dif_gt_300 treatedXpostXno_advisor) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")
}

/* Column 2 */

bysort county: egen avghhi_by_n = mean(hhi_by_n)

gen if_avghhi_1000_2500 = (avghhi_by_n>=0.1&avghhi_by_n<0.25)
gen if_avghhi_gt2500 = (avghhi_by_n>=0.25)

gen TXPXhas_advisor_avghhi_1000_2500 = treatedXpost*(if_advisor=="Yes")*(avghhi_by_n>=0.1&avghhi_by_n<0.25)
label var TXPXhas_advisor_avghhi_1000_2500 "Treated $\times$ Post $\times$ Has Advisor $\times$ HHI in [1000,2500)"

gen TXPXhas_advisor_avghhi_gt2500 = treatedXpost*(if_advisor=="Yes")*(avghhi_by_n>=0.25)
label var TXPXhas_advisor_avghhi_gt2500 "Treated $\times$ Post $\times$ Has Advisor $\times$ HHI $\ge$ 2500"

// Column 2: By whether employing an advisor, for levels of initial HHI
reghdfe gross_spread_inbp (i.treated i.post)##(i.if_advisor_coded i.if_avghhi_1000_2500 i.if_avghhi_gt2500) ///
treatedXpostXhas_advisor TXPXhas_advisor_avghhi_1000_2500 TXPXhas_advisor_avghhi_gt2500 treatedXpostXno_advisor, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXhas_advisor TXPXhas_advisor_avghhi_1000_2500 TXPXhas_advisor_avghhi_gt2500 treatedXpostXno_advisor) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")

/* Column 3 */

gen treatedXpostXhas_ind_advisor = treatedXpost*((if_advisor=="Yes")&(if_dual_advisor=="False"))
label var treatedXpostXhas_ind_advisor "Treated $\times$ Post $\times$ Has Independent Advisor "

gen treatedXpostXhas_dual_advisor = treatedXpost*((if_advisor=="Yes")&(if_dual_advisor=="True"))
label var treatedXpostXhas_dual_advisor "Treated $\times$ Post $\times$ Has Dual Advisor "

// Column 3: By whether employing an advisor, considering cases of independent director
reghdfe gross_spread_inbp (i.treated i.post)##(i.if_advisor_coded) treatedXpostXhas_advisor treatedXpostXhas_dual_advisor treatedXpostXno_advisor, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)

if "$MainThreshold" == "MarketShare" {
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(treatedXpostXhas_advisor treatedXpostXhas_dual_advisor treatedXpostXno_advisor) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer") ///
	sortvar(treatedXpostXhas_advisor TXPXHAXmax_sum_share_10_25 TXPXHAXmax_sum_share_gt_25 ///
	TXPXhas_advisor_avghhi_1000_2500 TXPXhas_advisor_avghhi_gt2500 ///
	treatedXpostXhas_ind_advisor treatedXpostXhas_dual_advisor treatedXpostXno_advisor)
}

if "$MainThreshold" == "HHI" {
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(treatedXpostXhas_advisor treatedXpostXhas_dual_advisor treatedXpostXno_advisor) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer") ///
	sortvar(treatedXpostXhas_advisor TXPXhas_advisor_hhi_dif_200_300 TXPXhas_advisor_hhi_dif_gt_300 ///
	TXPXhas_advisor_avghhi_1000_2500 TXPXhas_advisor_avghhi_gt2500 ///
	treatedXpostXhas_ind_advisor treatedXpostXhas_dual_advisor treatedXpostXno_advisor)
}








/* Table in the slides */

local outfile =  "../Slides/tabs/Slides_DID_MA_GrossSpread.tex"
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

/* Column 1 */

// Column 1: Using implied HHI increase > 0.01
reghdfe gross_spread_inbp treated post treatedXpost, absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Underwriting","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Clustering","Issuer")



