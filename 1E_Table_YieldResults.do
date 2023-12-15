
/*-----------------------------------------*/
/* Table: Main results of yield around M&A */
/*-----------------------------------------*/

/* Panel 1: Using yield */

local outfile =  "../Slides/tabs/DID_MA_Yield_main.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

if "$MainThreshold" == "HHI" {
	import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear
}
else if "$MainThreshold" == "MarketShare" {
	import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear
}

gen avg_yield_inbp = avg_yield*10000

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

drop if if_yield_from_nic=="True"

/* Column 1 */

// Column 1: Using implied HHI increase > 0.01
reghdfe avg_yield_inbp treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

/* Column 2 */

/* Alternative specification: "hhi_dif" */

if "$MainThreshold" == "HHI" {
	gen if_hhi_dif_200_300 = hhi_dif>=0.02&hhi_dif<0.03
	gen treatedXpostXhhi_dif_200_300 = treatedXpost*(hhi_dif>=0.02&hhi_dif<0.03)
	label var treatedXpostXhhi_dif_200_300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ in [200,300)"

	gen if_hhi_dif_gt300 = hhi_dif>0.03&hhi_dif!=.
	gen treatedXpostXhhi_dif_gt300 = treatedXpost*(hhi_dif>0.03&hhi_dif!=.)
	label var treatedXpostXhhi_dif_gt300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ $\ge$ 300"

	// Column 2: By increased in HHI induced by merger
	reghdfe avg_yield_inbp treated post if_hhi_dif_200_300 if_hhi_dif_gt300 ///
	treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300, /// 
	absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300) `outputoptions' ctitle("Offering","Yield (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")
}

/* Alternative specification: "max_sum_share" */

if "$MainThreshold" == "MarketShare" {
	gen if_max_sum_share_10_25 = max_sum_share>=0.10&max_sum_share<0.25&max_sum_share!=.
	gen TXPXmax_sum_share_10_25 = treatedXpost*if_max_sum_share_10_25
	label var TXPXmax_sum_share_10_25 "Treated $\times$ Post $\times$ Market Share in [0.10,0.25)"

	gen if_max_sum_share_gt_25 = max_sum_share>=0.25&max_sum_share!=.
	gen TXPXmax_sum_share_gt_25 = treatedXpost*if_max_sum_share_gt_25
	label var TXPXmax_sum_share_gt_25 "Treated $\times$ Post $\times$ Market Share $\ge$ 0.25"

	reghdfe avg_yield_inbp i.post (i.treated)##(i.if_max_sum_share_gt_25) ///
	treatedXpost TXPXmax_sum_share_gt_25, /// 
	absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)

	// Column 2: By market share of merging entities
	reghdfe avg_yield_inbp i.post (i.treated)##(i.if_max_sum_share_10_25 i.if_max_sum_share_gt_25) ///
	treatedXpost TXPXmax_sum_share_10_25 TXPXmax_sum_share_gt_25, /// 
	absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(treatedXpost treatedXpostXmax_sum_share_10_25 treatedXpostXmax_sum_share_gt_25) `outputoptions' ctitle("Offering","Yield (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")
}

/* Column 3 */

bysort county: egen avghhi_by_n = mean(hhi_by_n)

gen if_avghhi_lt1000 = (avghhi_by_n<0.10)
gen treatedXpostXavghhi_lt1000 = treatedXpost*(avghhi_by_n<0.1)
label var treatedXpostXavghhi_lt1000 "Treated $\times$ Post $\times$ HHI $<$ 1000"

gen if_avghhi_gt1000 = (avghhi_by_n>=0.10)
gen treatedXpostXavghhi_gt1000 = treatedXpost*(avghhi_by_n>=0.1)
label var treatedXpostXavghhi_gt1000 "Treated $\times$ Post $\times$ HHI $\ge$ 1000"

gen if_avghhi_1000_2500 = (avghhi_by_n>=0.1&avghhi_by_n<0.25)
gen treatedXpostXavghhi_1000_2500 = treatedXpost*(avghhi_by_n>=0.1&avghhi_by_n<0.25)
label var treatedXpostXavghhi_1000_2500 "Treated $\times$ Post $\times$ HHI in [1000,2500)"

gen if_avghhi_gt2500 = (avghhi_by_n>=0.25)
gen treatedXpostXavghhi_gt2500 = treatedXpost*(avghhi_by_n>=0.25)
label var treatedXpostXavghhi_gt2500 "Treated $\times$ Post $\times$ HHI $\ge$ 2500"

// Column 3: By initial HHI
reghdfe avg_yield_inbp (i.treated i.post)##(i.if_avghhi_lt1000 i.if_avghhi_gt1000) ///
treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000 if if_yield_from_nic=="False", /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

/* Effects on the probability of being callable */

local yield_effects_avghhi_lt1000 = _b[treatedXpostXavghhi_lt1000]
local yield_effects_avghhi_lt1000 : display %-9.1f `yield_effects_avghhi_lt1000'
file open myfile using "../Slides/nums/yield_effects_avghhi_lt1000.tex", write replace
file write myfile "`yield_effects_avghhi_lt1000'"
file close myfile

local abs_yield_effects_avghhi_lt1000 = -_b[treatedXpostXavghhi_lt1000]
local abs_yield_effects_avghhi_lt1000 : display %-9.1f `abs_yield_effects_avghhi_lt1000'
file open myfile using "../Slides/nums/abs_yield_effects_avghhi_lt1000.tex", write replace
file write myfile "`abs_yield_effects_avghhi_lt1000'"
file close myfile

local yield_effects_avghhi_gt1000 = _b[treatedXpostXavghhi_gt1000]
local yield_effects_avghhi_gt1000 : display %-9.1f `yield_effects_avghhi_gt1000'
file open myfile using "../Slides/nums/yield_effects_avghhi_gt1000.tex", write replace
file write myfile "`yield_effects_avghhi_gt1000'"
file close myfile


/* Column 4 */

gen isC = bid=="C"
gen isN = bid=="N"

gen treatedXpostXavghhi_lt1000XisC = treatedXpost*(avghhi_by_n<0.1)*(bid=="C")
label var treatedXpostXavghhi_lt1000XisC "Treated $\times$ Post $\times$ HHI $<$ 1000 $\times$ Competitive Bidding"

gen treatedXpostXavghhi_gt1000XisC = treatedXpost*(avghhi_by_n>=0.1)*(bid=="C")
label var treatedXpostXavghhi_gt1000XisC "Treated $\times$ Post $\times$ HHI $\ge$ 1000 $\times$ Competitive Bidding"

gen treatedXpostXavghhi_lt1000XisN = treatedXpost*(avghhi_by_n<0.1)*(bid=="N")
label var treatedXpostXavghhi_lt1000XisN "Treated $\times$ Post $\times$ HHI $<$ 1000 $\times$ Negotiated Sales"

gen treatedXpostXavghhi_gt1000XisN = treatedXpost*(avghhi_by_n>=0.1)*(bid=="N")
label var treatedXpostXavghhi_gt1000XisN "Treated $\times$ Post $\times$ HHI $\ge$ 1000 $\times$ Negotiated Sales"

// Column 4: By initial HHI and method of sales
reghdfe avg_yield_inbp (i.treated i.post)##(i.if_avghhi_lt1000 i.if_avghhi_gt1000)##(isC isN) ///
treatedXpostXavghhi_lt1000XisC treatedXpostXavghhi_gt1000XisC treatedXpostXavghhi_lt1000XisN treatedXpostXavghhi_gt1000XisN if if_yield_from_nic=="False", /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXavghhi_lt1000XisC treatedXpostXavghhi_gt1000XisC treatedXpostXavghhi_lt1000XisN treatedXpostXavghhi_gt1000XisN) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

/*

/* Column 5 */

gen if_advisor_coded = if_advisor=="Yes"

gen treatedXpostXhas_advisor = treatedXpost*(if_advisor=="Yes")
label var treatedXpostXhas_advisor "Treated $\times$ Post $\times$ Has Advisor"

gen treatedXpostXno_advisor = treatedXpost*(if_advisor=="No")
label var treatedXpostXno_advisor "Treated $\times$ Post $\times$ No Advisor"

// Column 5: By whether employing an advisor
reghdfe avg_yield_inbp (i.treated i.post)##(i.if_advisor_coded) treatedXpostXhas_advisor treatedXpostXno_advisor, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)

if "$MainThreshold" == "HHI" {
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(treatedXpostXhas_advisor treatedXpostXno_advisor) `outputoptions' ctitle("Offering","Yield (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer") ///
	sortvar(treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300 ///
	treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000)
}
if "$MainThreshold" == "MarketShare" {
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(treatedXpostXhas_advisor treatedXpostXno_advisor) `outputoptions' ctitle("Offering","Yield (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer") ///
	sortvar(treatedXpost TXPXmax_sum_share_10_25 TXPXmax_sum_share_gt_25 ///
	treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000 ///
	treatedXpostXavghhi_lt1000XisC treatedXpostXavghhi_gt1000XisC treatedXpostXavghhi_lt1000XisN treatedXpostXavghhi_gt1000XisN)
}

*/



/* Column 6 */

gen is_callable = if_callable=="Yes"

// Column 6: Whether bond is callable
reghdfe is_callable treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("If","Callable") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE","Yes","Credit Rating X Year FE", "No","Clustering","Issuer")

/* Effects on the probability of being callable */

local callable_effects = _b[treatedXpost]*100
local callable_effects : display %-9.1f `callable_effects'
file open myfile using "../Slides/nums/callable_effects.tex", write replace
file write myfile "`callable_effects'"
file close myfile

/*

/* Column 6 */

if "$MainThreshold" == "HHI" {
	import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN_bondlevel.csv", clear
}
else if "$MainThreshold" == "MarketShare" {
	import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN_bondlevel.csv", clear
}

replace yield_one_bond = yield_one_bond*10000

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Winsorize bond-level yield and spread
winsor2 yield_one_bond, replace cuts(1 99)

gen treatedXpostXhhi_dif_200_300 = .
gen treatedXpostXhhi_dif_gt300 = .
gen TXPXmax_sum_share_10_25 = .
gen TXPXmax_sum_share_gt_25 = .
gen treatedXpostXavghhi_lt1000 = .
gen treatedXpostXavghhi_gt1000 = .
gen treatedXpostXavghhi_1000_2500 = .
gen treatedXpostXavghhi_gt2500 = .
gen treatedXpostXhas_advisor = .
gen treatedXpostXno_advisor = .

label var treatedXpostXhhi_dif_200_300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ in [200,300)"
label var treatedXpostXhhi_dif_gt300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ $\ge$ 300"
label var TXPXmax_sum_share_10_25 "Treated $\times$ Post $\times$ Market Share in [0.15,0.25)"
label var TXPXmax_sum_share_gt_25 "Treated $\times$ Post $\times$ Market Share $\ge$ 0.25"
label var treatedXpostXavghhi_lt1000 "Treated $\times$ Post $\times$ HHI $<$ 1000"
label var treatedXpostXavghhi_gt1000 "Treated $\times$ Post $\times$ HHI $\ge$ 1000"
label var treatedXpostXavghhi_1000_2500 "Treated $\times$ Post $\times$ HHI in [1000,2500)"
label var treatedXpostXavghhi_gt2500 "Treated $\times$ Post $\times$ HHI $\ge$ 2500"
label var treatedXpostXhas_advisor "Treated $\times$ Post $\times$ Has Advisor"
label var treatedXpostXno_advisor "Treated $\times$ Post $\times$ No Advisor"

// Column 6: Using bond-level data
reghdfe yield_one_bond treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

*/






/* Panel 2: Controlling for credit ratings */

local outfile =  "../Slides/tabs/DID_MA_Yield_conctrolCR.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

if "$MainThreshold" == "HHI" {
	import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear
}
else if "$MainThreshold" == "MarketShare" {
	import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear
}

gen avg_yield_inbp = avg_yield*10000

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

drop if if_yield_from_nic=="True"

gen has_rating = (has_fitch=="True")|(has_moodys=="True")
gen best_rating = rating_fitch==0|rating_moodys==0
gen med_rating = ((rating_fitch!=.)&(rating_fitch>0&rating_fitch<=4))|((rating_moodys!=.)&(rating_moodys>0&rating_moodys<=3))
gen bad_rating = ((rating_fitch!=.)&(rating_fitch>4))|((rating_moodys!=.)&(rating_moodys>3))

/* Column 1 */

// Column 1: Control for credit rating
reghdfe avg_yield_inbp treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type (best_rating med_rating bad_rating)##calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "No","Issuer FE","Yes","Credit Rating X Year FE", "Yes","Clustering","Issuer")

/* Column 2 */

/* Alternative specification: "hhi_dif" */

if "$MainThreshold" == "HHI" {
	gen if_hhi_dif_200_300 = hhi_dif>=0.02&hhi_dif<0.03
	gen treatedXpostXhhi_dif_200_300 = treatedXpost*(hhi_dif>=0.02&hhi_dif<0.03)
	label var treatedXpostXhhi_dif_200_300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ in [200,300)"

	gen if_hhi_dif_gt300 = hhi_dif>0.03&hhi_dif!=.
	gen treatedXpostXhhi_dif_gt300 = treatedXpost*(hhi_dif>0.03&hhi_dif!=.)
	label var treatedXpostXhhi_dif_gt300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ $\ge$ 300"

	// Column 2: By increased in HHI induced by merger
	reghdfe avg_yield_inbp treated post if_hhi_dif_200_300 if_hhi_dif_gt300 ///
	treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300, /// 
	absorb(i.issuer_code##i.issuer_type (best_rating med_rating bad_rating)##calendar_year) cluster(i.issuer_code##i.issuer_type)
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300) `outputoptions' ctitle("Offering","Yield (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")
}

/* Alternative specification: "max_sum_share" */

if "$MainThreshold" == "MarketShare" {
	gen if_max_sum_share_10_25 = max_sum_share>=0.10&max_sum_share<0.25&max_sum_share!=.
	gen TXPXmax_sum_share_10_25 = treatedXpost*if_max_sum_share_10_25
	label var TXPXmax_sum_share_10_25 "Treated $\times$ Post $\times$ Market Share in [0.10,0.25)"

	gen if_max_sum_share_gt_25 = max_sum_share>=0.25&max_sum_share!=.
	gen TXPXmax_sum_share_gt_25 = treatedXpost*if_max_sum_share_gt_25
	label var TXPXmax_sum_share_gt_25 "Treated $\times$ Post $\times$ Market Share $\ge$ 0.25"

	reghdfe avg_yield_inbp i.post (i.treated)##(i.if_max_sum_share_gt_25) ///
	treatedXpost TXPXmax_sum_share_gt_25, /// 
	absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)

	// Column 2: By market share of merging entities
	reghdfe avg_yield_inbp i.post (i.treated)##(i.if_max_sum_share_10_25 i.if_max_sum_share_gt_25) ///
	treatedXpost TXPXmax_sum_share_10_25 TXPXmax_sum_share_gt_25, /// 
	absorb(i.issuer_code##i.issuer_type (best_rating med_rating bad_rating)##calendar_year) cluster(i.issuer_code##i.issuer_type)
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(treatedXpost treatedXpostXmax_sum_share_10_25 treatedXpostXmax_sum_share_gt_25) `outputoptions' ctitle("Offering","Yield (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")
}

/* Column 3 */

bysort county: egen avghhi_by_n = mean(hhi_by_n)

gen if_avghhi_lt1000 = (avghhi_by_n<0.10)
gen treatedXpostXavghhi_lt1000 = treatedXpost*(avghhi_by_n<0.1)
label var treatedXpostXavghhi_lt1000 "Treated $\times$ Post $\times$ HHI $<$ 1000"

gen if_avghhi_gt1000 = (avghhi_by_n>=0.10)
gen treatedXpostXavghhi_gt1000 = treatedXpost*(avghhi_by_n>=0.1)
label var treatedXpostXavghhi_gt1000 "Treated $\times$ Post $\times$ HHI $\ge$ 1000"

gen if_avghhi_1000_2500 = (avghhi_by_n>=0.1&avghhi_by_n<0.25)
gen treatedXpostXavghhi_1000_2500 = treatedXpost*(avghhi_by_n>=0.1&avghhi_by_n<0.25)
label var treatedXpostXavghhi_1000_2500 "Treated $\times$ Post $\times$ HHI in [1000,2500)"

gen if_avghhi_gt2500 = (avghhi_by_n>=0.25)
gen treatedXpostXavghhi_gt2500 = treatedXpost*(avghhi_by_n>=0.25)
label var treatedXpostXavghhi_gt2500 "Treated $\times$ Post $\times$ HHI $\ge$ 2500"

// Column 3: By initial HHI
reghdfe avg_yield_inbp (i.treated i.post)##(i.if_avghhi_lt1000 i.if_avghhi_gt1000) ///
treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000 if if_yield_from_nic=="False", /// 
absorb(i.issuer_code##i.issuer_type (best_rating med_rating bad_rating)##calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

/* Column 4 */

gen isC = bid=="C"
gen isN = bid=="N"

gen treatedXpostXavghhi_lt1000XisC = treatedXpost*(avghhi_by_n<0.1)*(bid=="C")
label var treatedXpostXavghhi_lt1000XisC "Treated $\times$ Post $\times$ HHI $<$ 1000 $\times$ Competitive Bidding"

gen treatedXpostXavghhi_gt1000XisC = treatedXpost*(avghhi_by_n>=0.1)*(bid=="C")
label var treatedXpostXavghhi_gt1000XisC "Treated $\times$ Post $\times$ HHI $\ge$ 1000 $\times$ Competitive Bidding"

gen treatedXpostXavghhi_lt1000XisN = treatedXpost*(avghhi_by_n<0.1)*(bid=="N")
label var treatedXpostXavghhi_lt1000XisN "Treated $\times$ Post $\times$ HHI $<$ 1000 $\times$ Negotiated Sales"

gen treatedXpostXavghhi_gt1000XisN = treatedXpost*(avghhi_by_n>=0.1)*(bid=="N")
label var treatedXpostXavghhi_gt1000XisN "Treated $\times$ Post $\times$ HHI $\ge$ 1000 $\times$ Negotiated Sales"

// Column 4: By initial HHI and method of sales
reghdfe avg_yield_inbp (i.treated i.post)##(i.if_avghhi_lt1000 i.if_avghhi_gt1000)##(isC isN) ///
treatedXpostXavghhi_lt1000XisC treatedXpostXavghhi_gt1000XisC treatedXpostXavghhi_lt1000XisN treatedXpostXavghhi_gt1000XisN if if_yield_from_nic=="False", /// 
absorb(i.issuer_code##i.issuer_type (best_rating med_rating bad_rating)##calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXavghhi_lt1000XisC treatedXpostXavghhi_gt1000XisC treatedXpostXavghhi_lt1000XisN treatedXpostXavghhi_gt1000XisN) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

/* Column 5 */

gen is_callable = if_callable=="Yes"

// Column 5: Whether bond is callable
reghdfe is_callable treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type (best_rating med_rating bad_rating)##calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("If","Callable") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE","Yes","Credit Rating X Year FE", "No","Clustering","Issuer")





/* Panel 2: Using spread */

local outfile =  "../Slides/tabs/DID_MA_Spread_main.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

if "$MainThreshold" == "HHI" {
	import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear
}
else if "$MainThreshold" == "MarketShare" {
	import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear
}

gen avg_spread_inbp = avg_spread*10000

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

drop if if_yield_from_nic=="True"

/* Column 1 */

// Column 1: Using implied HHI increase > 0.01
reghdfe avg_spread_inbp treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Yield","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

/* Column 2 */

/* Alternative specification: "hhi_dif" */

if "$MainThreshold" == "HHI" {
	gen if_hhi_dif_200_300 = hhi_dif>=0.02&hhi_dif<0.03
	gen treatedXpostXhhi_dif_200_300 = treatedXpost*(hhi_dif>=0.02&hhi_dif<0.03)
	label var treatedXpostXhhi_dif_200_300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ in [200,300)"

	gen if_hhi_dif_gt300 = hhi_dif>0.03&hhi_dif!=.
	gen treatedXpostXhhi_dif_gt300 = treatedXpost*(hhi_dif>0.03&hhi_dif!=.)
	label var treatedXpostXhhi_dif_gt300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ $\ge$ 300"

	// Column 2: By increased in HHI induced by merger
	reghdfe avg_spread_inbp treated post if_hhi_dif_200_300 if_hhi_dif_gt300 ///
	treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300, /// 
	absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300) `outputoptions' ctitle("Yield","Spread (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")
}

/* Alternative specification: "max_sum_share" */

if "$MainThreshold" == "MarketShare" {
	gen if_max_sum_share_10_25 = max_sum_share>=0.10&max_sum_share<0.25&max_sum_share!=.
	gen TXPXmax_sum_share_10_25 = treatedXpost*if_max_sum_share_10_25
	label var TXPXmax_sum_share_10_25 "Treated $\times$ Post $\times$ Market Share in [0.10,0.25)"

	gen if_max_sum_share_gt_25 = max_sum_share>=0.25&max_sum_share!=.
	gen TXPXmax_sum_share_gt_25 = treatedXpost*if_max_sum_share_gt_25
	label var TXPXmax_sum_share_gt_25 "Treated $\times$ Post $\times$ Market Share $\ge$ 0.25"

	reghdfe avg_spread_inbp i.post (i.treated)##(i.if_max_sum_share_gt_25) ///
	treatedXpost TXPXmax_sum_share_gt_25, /// 
	absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)

	// Column 2: By market share of merging entities
	reghdfe avg_spread_inbp i.post (i.treated)##(i.if_max_sum_share_10_25 i.if_max_sum_share_gt_25) ///
	treatedXpost TXPXmax_sum_share_10_25 TXPXmax_sum_share_gt_25, /// 
	absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(treatedXpost treatedXpostXmax_sum_share_10_25 treatedXpostXmax_sum_share_gt_25) `outputoptions' ctitle("Yield","Spread (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")
}

/* Column 3 */

bysort county: egen avghhi_by_n = mean(hhi_by_n)

gen if_avghhi_lt1000 = (avghhi_by_n<0.10)
gen treatedXpostXavghhi_lt1000 = treatedXpost*(avghhi_by_n<0.1)
label var treatedXpostXavghhi_lt1000 "Treated $\times$ Post $\times$ HHI $<$ 1000"

gen if_avghhi_gt1000 = (avghhi_by_n>=0.10)
gen treatedXpostXavghhi_gt1000 = treatedXpost*(avghhi_by_n>=0.1)
label var treatedXpostXavghhi_gt1000 "Treated $\times$ Post $\times$ HHI $\ge$ 1000"

gen if_avghhi_1000_2500 = (avghhi_by_n>=0.1&avghhi_by_n<0.25)
gen treatedXpostXavghhi_1000_2500 = treatedXpost*(avghhi_by_n>=0.1&avghhi_by_n<0.25)
label var treatedXpostXavghhi_1000_2500 "Treated $\times$ Post $\times$ HHI in [1000,2500)"

gen if_avghhi_gt2500 = (avghhi_by_n>=0.25)
gen treatedXpostXavghhi_gt2500 = treatedXpost*(avghhi_by_n>=0.25)
label var treatedXpostXavghhi_gt2500 "Treated $\times$ Post $\times$ HHI $\ge$ 2500"

// Column 3: By initial HHI
reghdfe avg_spread_inbp (i.treated i.post)##(i.if_avghhi_lt1000 i.if_avghhi_gt1000) ///
treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000) `outputoptions' ctitle("Yield","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

/* Column 4 */

gen if_advisor_coded = if_advisor=="Yes"

gen treatedXpostXhas_advisor = treatedXpost*(if_advisor=="Yes")
label var treatedXpostXhas_advisor "Treated $\times$ Post $\times$ Has Advisor"

gen treatedXpostXno_advisor = treatedXpost*(if_advisor=="No")
label var treatedXpostXno_advisor "Treated $\times$ Post $\times$ No Advisor"

// Column 4: By whether employing an advisor
reghdfe avg_spread_inbp (i.treated i.post)##(i.if_advisor_coded) treatedXpostXhas_advisor treatedXpostXno_advisor, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)

if "$MainThreshold" == "HHI" {
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(treatedXpostXhas_advisor treatedXpostXno_advisor) `outputoptions' ctitle("Yield","Spread (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer") ///
	sortvar(treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300 ///
	treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000 ///
	treatedXpostXhas_advisor treatedXpostXno_advisor)
}
if "$MainThreshold" == "MarketShare" {
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(treatedXpostXhas_advisor treatedXpostXno_advisor) `outputoptions' ctitle("Yield","Spread (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer") ///
	sortvar(treatedXpost TXPXmax_sum_share_10_25 TXPXmax_sum_share_gt_25 ///
	treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000 ///
	treatedXpostXhas_advisor treatedXpostXno_advisor)
}
	
/* Column 5 */

gen has_rating = (has_fitch=="True")|(has_moodys=="True")
gen best_rating = rating_fitch==0|rating_moodys==0
gen med_rating = ((rating_fitch!=.)&(rating_fitch>0&rating_fitch<=4))|((rating_moodys!=.)&(rating_moodys>0&rating_moodys<=3))
gen bad_rating = ((rating_fitch!=.)&(rating_fitch>4))|((rating_moodys!=.)&(rating_moodys>3))

// Column 5: Control for credit rating
reghdfe avg_spread_inbp treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type (best_rating med_rating bad_rating)##calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Yield","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "No","Issuer FE","Yes","Credit Rating X Year FE", "Yes","Clustering","Issuer")

/* Column 6 */

gen is_callable = if_callable=="Yes"

// Column 6: Whether bond is callable
reghdfe is_callable treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("If","Callable") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE","Yes","Credit Rating X Year No", "Yes","Clustering","Issuer")

/*

/* Column 6 */

if "$MainThreshold" == "HHI" {
	import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN_bondlevel.csv", clear
}
else if "$MainThreshold" == "MarketShare" {
	import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN_bondlevel.csv", clear
}

replace spread_one_bond = spread_one_bond*10000

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Winsorize bond-level spread and spread
winsor2 spread_one_bond, replace cuts(1 99)


gen treatedXpostXhhi_dif_200_300 = .
gen treatedXpostXhhi_dif_gt300 = .
gen TXPXmax_sum_share_10_25 = .
gen TXPXmax_sum_share_gt_25 = .
gen treatedXpostXavghhi_lt1000 = .
gen treatedXpostXavghhi_gt1000 = .
gen treatedXpostXavghhi_1000_2500 = .
gen treatedXpostXavghhi_gt2500 = .
gen treatedXpostXhas_advisor = .
gen treatedXpostXno_advisor = .

label var treatedXpostXhhi_dif_200_300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ in [200,300)"
label var treatedXpostXhhi_dif_gt300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ $\ge$ 300"
label var TXPXmax_sum_share_10_25 "Treated $\times$ Post $\times$ Market Share in [0.15,0.25)"
label var TXPXmax_sum_share_gt_25 "Treated $\times$ Post $\times$ Market Share $\ge$ 0.25"
label var treatedXpostXavghhi_lt1000 "Treated $\times$ Post $\times$ HHI $<$ 1000"
label var treatedXpostXavghhi_gt1000 "Treated $\times$ Post $\times$ HHI $\ge$ 1000"
label var treatedXpostXavghhi_1000_2500 "Treated $\times$ Post $\times$ HHI in [1000,2500)"
label var treatedXpostXavghhi_gt2500 "Treated $\times$ Post $\times$ HHI $\ge$ 2500"
label var treatedXpostXhas_advisor "Treated $\times$ Post $\times$ Has Advisor"
label var treatedXpostXno_advisor "Treated $\times$ Post $\times$ No Advisor"

// Column 6: Using bond-level data
reghdfe spread_one_bond treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Yield","Spread (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

*/




/* Panel 3: Using yield, two matches */

local outfile =  "../Slides/tabs/DID_MA_Yield_main_TwoMatch.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

if "$MainThreshold" == "HHI" {
	import delimited "../CleanData/MAEvent/CSA_TwoMatch_episodes_impliedHHIByN.csv", clear
}
else if "$MainThreshold" == "MarketShare" {
	import delimited "../CleanData/MAEvent/CSA_TwoMatch_episodes_marketshareHHIByN.csv", clear
}

gen avg_yield_inbp = avg_yield*10000

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

drop if if_yield_from_nic=="True"

/* Column 1 */

// Column 1: Using implied HHI increase > 0.01
reghdfe avg_yield_inbp treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

/* Column 2 */

/* Alternative specification: "hhi_dif" */

if "$MainThreshold" == "HHI" {
	gen if_hhi_dif_200_300 = hhi_dif>=0.02&hhi_dif<0.03
	gen treatedXpostXhhi_dif_200_300 = treatedXpost*(hhi_dif>=0.02&hhi_dif<0.03)
	label var treatedXpostXhhi_dif_200_300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ in [200,300)"

	gen if_hhi_dif_gt300 = hhi_dif>0.03&hhi_dif!=.
	gen treatedXpostXhhi_dif_gt300 = treatedXpost*(hhi_dif>0.03&hhi_dif!=.)
	label var treatedXpostXhhi_dif_gt300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ $\ge$ 300"

	// Column 2: By increased in HHI induced by merger
	reghdfe avg_yield_inbp treated post if_hhi_dif_200_300 if_hhi_dif_gt300 ///
	treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300, /// 
	absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300) `outputoptions' ctitle("Offering","Yield (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")
}

/* Alternative specification: "max_sum_share" */

if "$MainThreshold" == "MarketShare" {
	gen if_max_sum_share_10_25 = max_sum_share>=0.10&max_sum_share<0.25&max_sum_share!=.
	gen TXPXmax_sum_share_10_25 = treatedXpost*if_max_sum_share_10_25
	label var TXPXmax_sum_share_10_25 "Treated $\times$ Post $\times$ Market Share in [0.10,0.25)"

	gen if_max_sum_share_gt_25 = max_sum_share>=0.25&max_sum_share!=.
	gen TXPXmax_sum_share_gt_25 = treatedXpost*if_max_sum_share_gt_25
	label var TXPXmax_sum_share_gt_25 "Treated $\times$ Post $\times$ Market Share $\ge$ 0.25"

	reghdfe avg_yield_inbp i.post (i.treated)##(i.if_max_sum_share_gt_25) ///
	treatedXpost TXPXmax_sum_share_gt_25, /// 
	absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)

	// Column 2: By market share of merging entities
	reghdfe avg_yield_inbp i.post (i.treated)##(i.if_max_sum_share_10_25 i.if_max_sum_share_gt_25) ///
	treatedXpost TXPXmax_sum_share_10_25 TXPXmax_sum_share_gt_25, /// 
	absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(treatedXpost treatedXpostXmax_sum_share_10_25 treatedXpostXmax_sum_share_gt_25) `outputoptions' ctitle("Offering","Yield (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")
}

/* Column 3 */

bysort county: egen avghhi_by_n = mean(hhi_by_n)

gen if_avghhi_lt1000 = (avghhi_by_n<0.10)
gen treatedXpostXavghhi_lt1000 = treatedXpost*(avghhi_by_n<0.1)
label var treatedXpostXavghhi_lt1000 "Treated $\times$ Post $\times$ HHI $<$ 1000"

gen if_avghhi_gt1000 = (avghhi_by_n>=0.10)
gen treatedXpostXavghhi_gt1000 = treatedXpost*(avghhi_by_n>=0.1)
label var treatedXpostXavghhi_gt1000 "Treated $\times$ Post $\times$ HHI $\ge$ 1000"

gen if_avghhi_1000_2500 = (avghhi_by_n>=0.1&avghhi_by_n<0.25)
gen treatedXpostXavghhi_1000_2500 = treatedXpost*(avghhi_by_n>=0.1&avghhi_by_n<0.25)
label var treatedXpostXavghhi_1000_2500 "Treated $\times$ Post $\times$ HHI in [1000,2500)"

gen if_avghhi_gt2500 = (avghhi_by_n>=0.25)
gen treatedXpostXavghhi_gt2500 = treatedXpost*(avghhi_by_n>=0.25)
label var treatedXpostXavghhi_gt2500 "Treated $\times$ Post $\times$ HHI $\ge$ 2500"

// Column 3: By initial HHI
reghdfe avg_yield_inbp (i.treated i.post)##(i.if_avghhi_lt1000 i.if_avghhi_gt1000) ///
treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

/* Column 4 */

gen if_advisor_coded = if_advisor=="Yes"

gen treatedXpostXhas_advisor = treatedXpost*(if_advisor=="Yes")
label var treatedXpostXhas_advisor "Treated $\times$ Post $\times$ Has Advisor"

gen treatedXpostXno_advisor = treatedXpost*(if_advisor=="No")
label var treatedXpostXno_advisor "Treated $\times$ Post $\times$ No Advisor"

// Column 4: By whether employing an advisor
reghdfe avg_yield_inbp (i.treated i.post)##(i.if_advisor_coded) treatedXpostXhas_advisor treatedXpostXno_advisor, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)

if "$MainThreshold" == "HHI" {
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(treatedXpostXhas_advisor treatedXpostXno_advisor) `outputoptions' ctitle("Offering","Yield (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer") ///
	sortvar(treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300 ///
	treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000 ///
	treatedXpostXhas_advisor treatedXpostXno_advisor)
}
if "$MainThreshold" == "MarketShare" {
	outreg2 using  "`outfile'", tex(fragment) append label ///
	keep(treatedXpostXhas_advisor treatedXpostXno_advisor) `outputoptions' ctitle("Offering","Yield (bps.)") ///
	addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer") ///
	sortvar(treatedXpost TXPXmax_sum_share_10_25 TXPXmax_sum_share_gt_25 ///
	treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000 ///
	treatedXpostXhas_advisor treatedXpostXno_advisor)
}

/* Column 5 */

gen has_rating = (has_fitch=="True")|(has_moodys=="True")
gen best_rating = rating_fitch==0|rating_moodys==0
gen med_rating = ((rating_fitch!=.)&(rating_fitch>0&rating_fitch<=4))|((rating_moodys!=.)&(rating_moodys>0&rating_moodys<=3))
gen bad_rating = ((rating_fitch!=.)&(rating_fitch>4))|((rating_moodys!=.)&(rating_moodys>3))

// Column 5: Control for credit rating
reghdfe avg_yield_inbp treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type (best_rating med_rating bad_rating)##calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "No","Issuer FE","Yes","Credit Rating X Year FE", "Yes","Clustering","Issuer")

/*

/* Column 6 */

if "$MainThreshold" == "HHI" {
	import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN_bondlevel.csv", clear
}
else if "$MainThreshold" == "MarketShare" {
	import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN_bondlevel.csv", clear
}

replace yield_one_bond = yield_one_bond*10000

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

// Winsorize bond-level yield and spread
winsor2 yield_one_bond, replace cuts(1 99)

gen treatedXpostXhhi_dif_200_300 = .
gen treatedXpostXhhi_dif_gt300 = .
gen TXPXmax_sum_share_10_25 = .
gen TXPXmax_sum_share_gt_25 = .
gen treatedXpostXavghhi_lt1000 = .
gen treatedXpostXavghhi_gt1000 = .
gen treatedXpostXavghhi_1000_2500 = .
gen treatedXpostXavghhi_gt2500 = .
gen treatedXpostXhas_advisor = .
gen treatedXpostXno_advisor = .

label var treatedXpostXhhi_dif_200_300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ in [200,300)"
label var treatedXpostXhhi_dif_gt300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ $\ge$ 300"
label var TXPXmax_sum_share_10_25 "Treated $\times$ Post $\times$ Market Share in [0.15,0.25)"
label var TXPXmax_sum_share_gt_25 "Treated $\times$ Post $\times$ Market Share $\ge$ 0.25"
label var treatedXpostXavghhi_lt1000 "Treated $\times$ Post $\times$ HHI $<$ 1000"
label var treatedXpostXavghhi_gt1000 "Treated $\times$ Post $\times$ HHI $\ge$ 1000"
label var treatedXpostXavghhi_1000_2500 "Treated $\times$ Post $\times$ HHI in [1000,2500)"
label var treatedXpostXavghhi_gt2500 "Treated $\times$ Post $\times$ HHI $\ge$ 2500"
label var treatedXpostXhas_advisor "Treated $\times$ Post $\times$ Has Advisor"
label var treatedXpostXno_advisor "Treated $\times$ Post $\times$ No Advisor"

// Column 6: Using bond-level data
reghdfe yield_one_bond treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

*/



/* Panel 4: Using alternative cutoffs as robustness test */

local outfile =  "../Slides/tabs/Slides_DID_MA_Yield_othercutoff.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear

gen avg_yield_inbp = avg_yield*10000

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

drop if if_yield_from_nic=="True"

/* Column 1 */

// Column 1: Using market share of both sides > 5%
reghdfe avg_yield_inbp treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

/* Column 2 */

bysort county: egen avghhi_by_n = mean(hhi_by_n)

gen if_avghhi_lt1000 = (avghhi_by_n<0.10)
gen treatedXpostXavghhi_lt1000 = treatedXpost*(avghhi_by_n<0.1)
label var treatedXpostXavghhi_lt1000 "Treated $\times$ Post $\times$ HHI $<$ 1000"

gen if_avghhi_gt1000 = (avghhi_by_n>=0.10)
gen treatedXpostXavghhi_gt1000 = treatedXpost*(avghhi_by_n>=0.1)
label var treatedXpostXavghhi_gt1000 "Treated $\times$ Post $\times$ HHI $\ge$ 1000"

gen if_avghhi_1000_2500 = (avghhi_by_n>=0.1&avghhi_by_n<0.25)
gen treatedXpostXavghhi_1000_2500 = treatedXpost*(avghhi_by_n>=0.1&avghhi_by_n<0.25)
label var treatedXpostXavghhi_1000_2500 "Treated $\times$ Post $\times$ HHI in [1000,2500)"

gen if_avghhi_gt2500 = (avghhi_by_n>=0.25)
gen treatedXpostXavghhi_gt2500 = treatedXpost*(avghhi_by_n>=0.25)
label var treatedXpostXavghhi_gt2500 "Treated $\times$ Post $\times$ HHI $\ge$ 2500"

// Column 2: By initial HHI
reghdfe avg_yield_inbp (i.treated i.post)##(i.if_avghhi_lt1000 i.if_avghhi_gt1000) ///
treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

/* Column 3 */

gen isC = bid=="C"
gen isN = bid=="N"

gen treatedXpostXavghhi_lt1000XisC = treatedXpost*(avghhi_by_n<0.1)*(bid=="C")
label var treatedXpostXavghhi_lt1000XisC "Treated $\times$ Post $\times$ HHI $<$ 1000 $\times$ Competitive Bidding"

gen treatedXpostXavghhi_gt1000XisC = treatedXpost*(avghhi_by_n>=0.1)*(bid=="C")
label var treatedXpostXavghhi_gt1000XisC "Treated $\times$ Post $\times$ HHI $\ge$ 1000 $\times$ Competitive Bidding"

gen treatedXpostXavghhi_lt1000XisN = treatedXpost*(avghhi_by_n<0.1)*(bid=="N")
label var treatedXpostXavghhi_lt1000XisN "Treated $\times$ Post $\times$ HHI $<$ 1000 $\times$ Negotiated Sales"

gen treatedXpostXavghhi_gt1000XisN = treatedXpost*(avghhi_by_n>=0.1)*(bid=="N")
label var treatedXpostXavghhi_gt1000XisN "Treated $\times$ Post $\times$ HHI $\ge$ 1000 $\times$ Negotiated Sales"

// Column 3: By initial HHI and method of sales
reghdfe avg_yield_inbp (i.treated i.post)##(i.if_avghhi_lt1000 i.if_avghhi_gt1000)##(isC isN) ///
treatedXpostXavghhi_lt1000XisC treatedXpostXavghhi_gt1000XisC treatedXpostXavghhi_lt1000XisN treatedXpostXavghhi_gt1000XisN, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXavghhi_lt1000XisC treatedXpostXavghhi_gt1000XisC treatedXpostXavghhi_lt1000XisN treatedXpostXavghhi_gt1000XisN) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

import delimited "../CleanData/MAEvent/CSA_episodes_top5sharebyN.csv", clear

gen avg_yield_inbp = avg_yield*10000

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

drop if if_yield_from_nic=="True"

/* Column 4 */

// Column 4: Using implied increase in top 5 share > 5%
reghdfe avg_yield_inbp treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

/* Column 5 */

bysort county: egen avghhi_by_n = mean(hhi_by_n)

gen if_avghhi_lt1000 = (avghhi_by_n<0.10)
gen treatedXpostXavghhi_lt1000 = treatedXpost*(avghhi_by_n<0.1)
label var treatedXpostXavghhi_lt1000 "Treated $\times$ Post $\times$ HHI $<$ 1000"

gen if_avghhi_gt1000 = (avghhi_by_n>=0.10)
gen treatedXpostXavghhi_gt1000 = treatedXpost*(avghhi_by_n>=0.1)
label var treatedXpostXavghhi_gt1000 "Treated $\times$ Post $\times$ HHI $\ge$ 1000"

gen if_avghhi_1000_2500 = (avghhi_by_n>=0.1&avghhi_by_n<0.25)
gen treatedXpostXavghhi_1000_2500 = treatedXpost*(avghhi_by_n>=0.1&avghhi_by_n<0.25)
label var treatedXpostXavghhi_1000_2500 "Treated $\times$ Post $\times$ HHI in [1000,2500)"

gen if_avghhi_gt2500 = (avghhi_by_n>=0.25)
gen treatedXpostXavghhi_gt2500 = treatedXpost*(avghhi_by_n>=0.25)
label var treatedXpostXavghhi_gt2500 "Treated $\times$ Post $\times$ HHI $\ge$ 2500"

// Column 5: By initial HHI
reghdfe avg_yield_inbp (i.treated i.post)##(i.if_avghhi_lt1000 i.if_avghhi_gt1000) ///
treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")

/* Column 6 */

gen isC = bid=="C"
gen isN = bid=="N"

gen treatedXpostXavghhi_lt1000XisC = treatedXpost*(avghhi_by_n<0.1)*(bid=="C")
label var treatedXpostXavghhi_lt1000XisC "Treated $\times$ Post $\times$ HHI $<$ 1000 $\times$ Competitive Bidding"

gen treatedXpostXavghhi_gt1000XisC = treatedXpost*(avghhi_by_n>=0.1)*(bid=="C")
label var treatedXpostXavghhi_gt1000XisC "Treated $\times$ Post $\times$ HHI $\ge$ 1000 $\times$ Competitive Bidding"

gen treatedXpostXavghhi_lt1000XisN = treatedXpost*(avghhi_by_n<0.1)*(bid=="N")
label var treatedXpostXavghhi_lt1000XisN "Treated $\times$ Post $\times$ HHI $<$ 1000 $\times$ Negotiated Sales"

gen treatedXpostXavghhi_gt1000XisN = treatedXpost*(avghhi_by_n>=0.1)*(bid=="N")
label var treatedXpostXavghhi_gt1000XisN "Treated $\times$ Post $\times$ HHI $\ge$ 1000 $\times$ Negotiated Sales"

// Column 6: By initial HHI and method of sales
reghdfe avg_yield_inbp (i.treated i.post)##(i.if_avghhi_lt1000 i.if_avghhi_gt1000)##(isC isN) ///
treatedXpostXavghhi_lt1000XisC treatedXpostXavghhi_gt1000XisC treatedXpostXavghhi_lt1000XisN treatedXpostXavghhi_gt1000XisN, /// 
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpostXavghhi_lt1000XisC treatedXpostXavghhi_gt1000XisC treatedXpostXavghhi_lt1000XisN treatedXpostXavghhi_gt1000XisN) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer") ///
sortvar(treatedXpost treatedXpostXavghhi_lt1000 treatedXpostXavghhi_gt1000 ///
treatedXpostXavghhi_lt1000XisC treatedXpostXavghhi_gt1000XisC treatedXpostXavghhi_lt1000XisN treatedXpostXavghhi_gt1000XisN)




/* Table used in the slides */

local outfile =  "../Slides/tabs/Slides_DID_MA_Yield_main.tex"
local outputoptions = "nor2 dec(3) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

if "$MainThreshold" == "HHI" {
	import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIbyN.csv", clear
}
else if "$MainThreshold" == "MarketShare" {
	import delimited "../CleanData/MAEvent/CSA_episodes_marketsharebyN.csv", clear
}

gen avg_yield_inbp = avg_yield*10000

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode issuer, gen(issuer_code)

drop if if_yield_from_nic=="True"

/* Column 1 */

// Column 1: Using implied HHI increase > 0.01
reghdfe avg_yield_inbp treated post treatedXpost, ///
absorb(i.issuer_code##i.issuer_type calendar_year) cluster(i.issuer_code##i.issuer_type)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Offering","Yield (bps.)") ///
addstat("Within R-squared", e(r2_within)) addtext("Year FE", "Yes","Issuer FE", "Yes","Credit Rating X Year FE","No","Clustering","Issuer")


