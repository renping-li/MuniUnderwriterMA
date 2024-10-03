
/*---------------------------------------------------------------------------------*/
/* Table: Investigate whether M&A has any effects on the quantity of bond issuance */
/*---------------------------------------------------------------------------------*/

/* Panel 1: Linear probability model */

local outfile =  "../Draft/tabs/DID_MAQuant.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

import delimited "../CleanData/MAEvent/CSA_episodes_impliedHHIByN_Quant.csv", clear

gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

egen county_code = group(state county)

winsor2 amount, replace cuts(1 99)

gen log_amount = log(amount)

/* Column 1 */

// Column 1: Amount
reghdfe log_amount treated post treatedXpost, absorb(i.county_code calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("log(Amount)","\;") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","County FE", "Yes","Clustering","County")

/* Column 2 */

gen if_hhi_dif_200_300 = hhi_dif>=0.02&hhi_dif<0.03
gen treatedXpostXhhi_dif_200_300 = treatedXpost*(hhi_dif>=0.02&hhi_dif<0.03)
label var treatedXpostXhhi_dif_200_300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ in [200,300)"

gen if_hhi_dif_gt300 = hhi_dif>0.03&hhi_dif!=.
gen treatedXpostXhhi_dif_gt300 = treatedXpost*(hhi_dif>0.03&hhi_dif!=.)
label var treatedXpostXhhi_dif_gt300 "Treated $\times$ Post $\times$ \emph{predicted} $\Delta_{HHI}$ $\ge$ 300"

// Column 2: By increased in HHI induced by merger
reghdfe log_amount treated post if_hhi_dif_200_300 if_hhi_dif_gt300 ///
treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300, /// 
absorb(i.county_code calendar_year) cluster(i.county_code)

/* Column 3 */

bysort county: egen avghhi_by_n = mean(hhi_by_n)

gen if_avghhi_1000_2000 = (avghhi_by_n>=0.1&avghhi_by_n<0.2)
gen treatedXpostXavghhi_1000_2000 = treatedXpost*(avghhi_by_n>=0.1&avghhi_by_n<0.2)
label var treatedXpostXavghhi_1000_2000 "Treated $\times$ Post $\times$ HHI in [1000,2000)"

gen if_avghhi_2000_3000 = (avghhi_by_n>=0.2&avghhi_by_n<0.3)
gen treatedXpostXavghhi_2000_3000 = treatedXpost*(avghhi_by_n>=0.2&avghhi_by_n<0.3)
label var treatedXpostXavghhi_2000_3000 "Treated $\times$ Post $\times$ HHI in [2000,3000)"

gen if_avghhi_gt3000 = (avghhi_by_n>=0.3)
gen treatedXpostXavghhi_gt3000 = treatedXpost*(avghhi_by_n>=0.3)
label var treatedXpostXavghhi_gt3000 "Treated $\times$ Post $\times$ HHI $\ge$ 3000"

// Column 3: Amount by HHI
reghdfe log_amount (i.treated i.post)##(i.if_avghhi_1000_2000 i.if_avghhi_2000_3000 i.if_avghhi_gt3000) ///
treatedXpost treatedXpostXavghhi_1000_2000 treatedXpostXavghhi_2000_3000 treatedXpostXavghhi_gt3000, ///
absorb(i.county_code calendar_year) cluster(i.county_code)

/* Column 4 */

gen amount_per_pop = amount/pop
gen log_amount_per_pop = log(amount_per_pop)

// Column 4: Amount per capita
reghdfe log_amount_per_pop treated post treatedXpost, ///
absorb(i.county_code calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) replace label ///
keep(treatedXpost) `outputoptions' ctitle("log Amount","per Capita") addstat("Adjusted R-squared", e(r2_a)) ///
addtext("Year FE", "Yes","County FE", "Yes","Clustering","County")

/* Column 5 */

// Column 5: By increased in HHI induced by merger
reghdfe log_amount_per_pop treated post if_hhi_dif_200_300 if_hhi_dif_gt300 ///
treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300, /// 
absorb(i.county_code calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost treatedXpostXhhi_dif_200_300 treatedXpostXhhi_dif_gt300) `outputoptions' ctitle("log Amount","per Capita") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","County FE", "Yes","Clustering","County")

/* Column 6 */

// Column 6: Amount per capita by HHI
reghdfe log_amount_per_pop (i.treated i.post)##(i.if_avghhi_1000_2000 i.if_avghhi_2000_3000 i.if_avghhi_gt3000) ///
treatedXpost treatedXpostXavghhi_1000_2000 treatedXpostXavghhi_2000_3000 treatedXpostXavghhi_gt3000, ///
absorb(i.county_code calendar_year) cluster(i.county_code)
outreg2 using  "`outfile'", tex(fragment) append label ///
keep(treatedXpost treatedXpostXavghhi_1000_2000 treatedXpostXavghhi_2000_3000 treatedXpostXavghhi_gt3000) `outputoptions' ctitle("log Amount","per Capita") addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","County FE", "Yes","Clustering","County")






