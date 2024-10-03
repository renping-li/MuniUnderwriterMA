
import delimited "../CleanData/MAEvent/GovFin_State_from_CBSA.csv", clear 


gen post = year_to_merger>=0
gen treatedXpost = treated*post
label var treatedXpost "Treated $\times$ Post"

encode state, gen(state_code)



/* Panel: Using variables scaled by total expenditure */

local outfile =  "../Draft/tabs/DID_GovFin_StateLevel_Scaled.tex"
local outputoptions = "nor2 dec(2) stats(coef tstat) nocons tdec(2) nonotes adec(3)"

/* Column 1 */

// Column 1: Total transfer to local government

keep if igexptolocalgovts!=.
gen igexptolocalgovts_toexp = igexptolocalgovts/totalexpenditure*100
winsor2 igexptolocalgovts_toexp, replace cuts(1 99)
reghdfe igexptolocalgovts_toexp treated post treatedXpost, absorb(state_code calendar_year) cluster(state_code)
outreg2 using  "`outfile'", tex(fragment) replace label keep(treatedXpost) `outputoptions' ctitle("Total Trans. to","Local/Exp. (%)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","State FE", "Yes","Clustering","State")

/* Column 2 */

// Column 2: Total construction

gen totalconstruction_toexp = totalconstruction/totalexpenditure*100
winsor2 totalconstruction_toexp, replace cuts(1 99)
reghdfe totalconstruction_toexp treated post treatedXpost, absorb(state_code calendar_year) cluster(state_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Total Construction","/Exp. (%)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","State FE", "Yes","Clustering","State")

/* Column 3 */

// Column 3: Total capital outlay

gen totalcapitaloutlay_toexp = totalcapitaloutlay/totalexpenditure*100
winsor2 totalcapitaloutlay_toexp, replace cuts(1 99)
reghdfe totalcapitaloutlay_toexp treated post treatedXpost, absorb(state_code calendar_year) cluster(state_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Total Capital","Outlay/Exp. (%)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","State FE", "Yes","Clustering","State")

/* Column 4 */

// Column 4: Total current operation

gen totalcurrentoperation_toexp = totalcurrentoperation/totalexpenditure*100
winsor2 totalcurrentoperation_toexp, replace cuts(1 99)
reghdfe totalcurrentoperation_toexp treated post treatedXpost, absorb(state_code calendar_year) cluster(state_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Total Current","Operation/Exp. (%)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","State FE", "Yes","Clustering","State")

/* Column 5 */

// Column 5: Total interest on debt, using the observation for this state year
gen totalltdissued_toexp = totalltdissued/totalexpenditure*100
winsor2 totalltdissued_toexp, replace cuts(1 99)
reghdfe totalltdissued_toexp treated post treatedXpost, absorb(state_code calendar_year) cluster(state_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("Interest Paid","/Exp. (%)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","State FE", "Yes","Clustering","State")

/* Column 6 */

// Column 6: Debt issuance, using the observation for this state year
gen totalinterestondebt_toexp = totalinterestondebt/totalexpenditure*100
winsor2 totalinterestondebt_toexp, replace cuts(1 99)
reghdfe totalinterestondebt_toexp treated post treatedXpost, absorb(state_code calendar_year) cluster(state_code)
outreg2 using  "`outfile'", tex(fragment) append label keep(treatedXpost) `outputoptions' ctitle("New Issuance","/Exp. (%)") ///
addstat("Adjusted R-squared", e(r2_a)) addtext("Year FE", "Yes","State FE", "Yes","Clustering","State")


