
drop if typecode==0
drop if population==.&enrollment==.
drop if typecode==4 // The population in special districts (hospital, utility, etc.) is not comparable to types

// Within each type, drop if population is in the bottom 5%
sum population if typecode==1, d
drop if population<r(p5)&typecode==1
sum population if typecode==2, d
drop if population<r(p5)&typecode==2
sum population if typecode==3, d
drop if population<r(p5)&typecode==3
sum population if typecode==4, d
drop if population<r(p5)&typecode==4
sum population if typecode==5, d
drop if population<r(p5)&typecode==5

drop if totalrevenue==.
drop if totalrevenue==0
drop if totalinterestondebt==.
drop if totalexpenditure==.
drop if totalexpenditure==0
drop if totaltaxes==.
drop if propertytax==.
drop if totalltdissued==.
drop if population==.&typecode!=5
drop if population==0&typecode!=5
drop if enrollment==.&typecode==5
drop if enrollment==0&typecode==5

// Verify that "Population" is available for only non-school district, and "Enrollment" is available for only school district

count if population!=.&typecode==5
assert r(N)==0
count if enrollment!=.&typecode!=5
assert r(N)==0

egen county_code = group(county state)

// Total expenditure for a county, which will be used to generate dollar amounts that help gauge economic magnitudes
bysort county calendar_year: egen county_totalexpenditure = sum(totalexpenditure)

// Create vars for regression

// Note that, when scaling variables, the scaler for non-school district is population, and for school district is enrollment. 
// "Population" is missing for school district, and "Enrollment" is missing for population

// Three versions of variable:
// (1) Per capita or per student
// (2) Logged of (1)
// (3) Total amount scaled by revenue

/*--- Interest ---*/

winsor2 totalinterestondebt, replace cuts(1 99) by(typecode calendar_year)

gen log_totalinterestondebt = log(totalinterestondebt+1)
winsor2 log_totalinterestondebt, replace cuts(1 99)

gen totalinterestondebt_pc = totalinterestondebt/population*1000
replace totalinterestondebt_pc = totalinterestondebt_pc*scaler
winsor2 totalinterestondebt_pc, replace cuts(1 99)

gen totalinterestondebt_pe = totalinterestondebt/enrollment*1000
replace totalinterestondebt_pe = totalinterestondebt_pe*scaler
winsor2 totalinterestondebt_pe, replace cuts(1 99)

gen log_totalinterestondebt_pc = log(totalinterestondebt_pc+1)
winsor2 log_totalinterestondebt_pc, replace cuts(1 99)

gen log_totalinterestondebt_pe = log(totalinterestondebt_pe+1)
winsor2 log_totalinterestondebt_pe, replace cuts(1 99)

gen totalinterestondebt_toexp = totalinterestondebt/totalexpenditure*100
winsor2 totalinterestondebt_toexp, replace cuts(1 99)

gen interest_ratio = totalinterestondebt/totaldebtoutstanding
winsor2 interest_ratio, replace cuts(1 99) by(typecode calendar_year)

/*--- Expenditure ---*/

// Total expenses

winsor2 totalexpenditure , replace cuts(1 99) by(typecode calendar_year)

gen log_totalexpenditure = log(totalexpenditure+1)
winsor2 log_totalexpenditure, replace cuts(1 99)

gen totalexpenditure_pc = totalexpenditure/population*1000
replace totalexpenditure_pc = totalexpenditure_pc*scaler
winsor2 totalexpenditure_pc, replace cuts(1 99)

gen totalexpenditure_pe = totalexpenditure/enrollment*1000
replace totalexpenditure_pe = totalexpenditure_pe*scaler
winsor2 totalexpenditure_pe, replace cuts(1 99)

gen log_totalexpenditure_pc = log(totalexpenditure_pc+1)
winsor2 log_totalexpenditure_pc, replace cuts(1 99)

gen log_totalexpenditure_pe = log(totalexpenditure_pe+1)
winsor2 log_totalexpenditure_pe, replace cuts(1 99)

// IG expenses, federal

winsor2 igexptofederalgovt, replace cuts(1 99) by(typecode calendar_year)

gen igexptofederalgovt_pc = igexptofederalgovt/population*1000
replace igexptofederalgovt_pc = igexptofederalgovt_pc*scaler
winsor2 igexptofederalgovt_pc, replace cuts(1 99)

gen igexptofederalgovt_pe = igexptofederalgovt/enrollment*1000
replace igexptofederalgovt_pe = igexptofederalgovt_pe*scaler
winsor2 igexptofederalgovt_pe, replace cuts(1 99)

gen log_igexptofederalgovt_pc = log(igexptofederalgovt_pc+1)
winsor2 log_igexptofederalgovt_pc, replace cuts(1 99)

gen log_igexptofederalgovt_pe = log(igexptofederalgovt_pe+1)
winsor2 log_igexptofederalgovt_pe, replace cuts(1 99)

// IG expenses, state

winsor2 igexptostategovt, replace cuts(1 99) by(typecode calendar_year)

gen igexptostategovt_pc = igexptostategovt/population*1000
replace igexptostategovt_pc = igexptostategovt_pc*scaler
winsor2 igexptostategovt_pc, replace cuts(1 99)

gen igexptostategovt_pe = igexptostategovt/enrollment*1000
replace igexptostategovt_pe = igexptostategovt_pe*scaler
winsor2 igexptostategovt_pe, replace cuts(1 99)

gen log_igexptostategovt_pc = log(igexptostategovt_pc+1)
winsor2 log_igexptostategovt_pc, replace cuts(1 99)

gen log_igexptostategovt_pe = log(igexptostategovt_pe+1)
winsor2 log_igexptostategovt_pe, replace cuts(1 99)

// IG expenses, local

winsor2 igexptolocalgovts, replace cuts(1 99) by(typecode calendar_year)

gen igexptolocalgovts_pc = igexptolocalgovts/population*1000
replace igexptolocalgovts_pc = igexptolocalgovts_pc*scaler
winsor2 igexptolocalgovts_pc, replace cuts(1 99)

gen igexptolocalgovts_pe = igexptolocalgovts/enrollment*1000
replace igexptolocalgovts_pe = igexptolocalgovts_pe*scaler
winsor2 igexptolocalgovts_pe, replace cuts(1 99)

gen log_igexptolocalgovts_pc = log(igexptolocalgovts_pc+1)
winsor2 log_igexptolocalgovts_pc, replace cuts(1 99)

gen log_igexptolocalgovts_pe = log(igexptolocalgovts_pe+1)
winsor2 log_igexptolocalgovts_pe, replace cuts(1 99)

/*--- Revenue ---*/

// Total revenue

winsor2 totalrevenue, replace cuts(1 99) by(typecode calendar_year)

gen log_totalrevenue = log(totalrevenue+1)
winsor2 log_totalrevenue, replace cuts(1 99)

gen totalrevenue_pc = totalrevenue/population*1000
replace totalrevenue_pc = totalrevenue_pc*scaler
winsor2 totalrevenue_pc, replace cuts(1 99)

gen totalrevenue_pe = totalrevenue/enrollment*1000
replace totalrevenue_pe = totalrevenue_pe*scaler
winsor2 totalrevenue_pe, replace cuts(1 99)

gen log_totalrevenue_pc = log(totalrevenue_pc+1)
winsor2 log_totalrevenue_pc, replace cuts(1 99)

gen log_totalrevenue_pe = log(totalrevenue_pe+1)
winsor2 log_totalrevenue_pe, replace cuts(1 99)

// IG revenue

winsor2 totaligrevenue, replace cuts(1 99) by(typecode calendar_year)

gen log_totaligrevenue = log(totaligrevenue+1)
winsor2 log_totaligrevenue, replace cuts(1 99)

gen totaligrevenue_pc = totaligrevenue/population*1000
replace totaligrevenue_pc = totaligrevenue_pc*scaler
winsor2 totaligrevenue_pc, replace cuts(1 99)

gen totaligrevenue_pe = totaligrevenue/enrollment*1000
replace totaligrevenue_pe = totaligrevenue_pe*scaler
winsor2 totaligrevenue_pe, replace cuts(1 99)

gen log_totaligrevenue_pc = log(totaligrevenue_pc+1)
winsor2 log_totaligrevenue_pc, replace cuts(1 99)

gen log_totaligrevenue_pe = log(totaligrevenue_pe+1)
winsor2 log_totaligrevenue_pe, replace cuts(1 99)

gen totaligrevenue_toexp = totaligrevenue/totalexpenditure*100
winsor2 totaligrevenue_toexp, replace cuts(1 99)

// IG revenue, federal

winsor2 totalfedigrevenue, replace cuts(1 99) by(typecode calendar_year)

gen totalfedigrevenue_pc = totalfedigrevenue/population*1000
replace totalfedigrevenue_pc = totalfedigrevenue_pc*scaler
winsor2 totalfedigrevenue_pc, replace cuts(1 99)

gen totalfedigrevenue_pe = totalfedigrevenue/enrollment*1000
replace totalfedigrevenue_pe = totalfedigrevenue_pe*scaler
winsor2 totalfedigrevenue_pe, replace cuts(1 99)

gen log_totalfedigrevenue_pc = log(totalfedigrevenue_pc+1)
winsor2 log_totalfedigrevenue_pc, replace cuts(1 99)

gen log_totalfedigrevenue_pe = log(totalfedigrevenue_pe+1)
winsor2 log_totalfedigrevenue_pe, replace cuts(1 99)

gen totalfedigrevenue_toexp = totalfedigrevenue/totalexpenditure*100
winsor2 totalfedigrevenue_toexp, replace cuts(1 99)

// IG revenue, state

winsor2 totalstateigrevenue, replace cuts(1 99) by(typecode calendar_year)

gen totalstateigrevenue_pc = totalstateigrevenue/population*1000
replace totalstateigrevenue_pc = totalstateigrevenue_pc*scaler
winsor2 totalstateigrevenue_pc, replace cuts(1 99)

gen totalstateigrevenue_pe = totalstateigrevenue/enrollment*1000
replace totalstateigrevenue_pe = totalstateigrevenue_pe*scaler
winsor2 totalstateigrevenue_pe, replace cuts(1 99)

gen log_totalstateigrevenue_pc = log(totalstateigrevenue_pc+1)
winsor2 log_totalstateigrevenue_pc, replace cuts(1 99)

gen log_totalstateigrevenue_pe = log(totalstateigrevenue_pe+1)
winsor2 log_totalstateigrevenue_pe, replace cuts(1 99)

gen totalstateigrevenue_toexp = totalstateigrevenue/totalexpenditure*100
winsor2 totalstateigrevenue_toexp, replace cuts(1 99)

// IG revenue, local

winsor2 totlocaligrev, replace cuts(1 99) by(typecode calendar_year)

gen totlocaligrev_pc = totlocaligrev/population*1000
replace totlocaligrev_pc = totlocaligrev_pc*scaler
winsor2 totlocaligrev_pc, replace cuts(1 99)

gen totlocaligrev_pe = totlocaligrev/enrollment*1000
replace totlocaligrev_pe = totlocaligrev_pe*scaler
winsor2 totlocaligrev_pe, replace cuts(1 99)

gen log_totlocaligrev_pc = log(totlocaligrev_pc+1)
winsor2 log_totlocaligrev_pc, replace cuts(1 99)

gen log_totlocaligrev_pe = log(totlocaligrev_pe+1)
winsor2 log_totlocaligrev_pe, replace cuts(1 99)

gen totlocaligrev_toexp = totlocaligrev/totalexpenditure*100
winsor2 totlocaligrev_toexp, replace cuts(1 99)

/*--- Taxes ---*/

// Total taxes

winsor2 totaltaxes, replace cuts(1 99) by(typecode calendar_year)

gen log_totaltaxes = log(totaltaxes+1)
winsor2 log_totaltaxes, replace cuts(1 99)

gen totaltaxes_pc = totaltaxes/population*1000
replace totaltaxes_pc = totaltaxes_pc*scaler
winsor2 totaltaxes_pc, replace cuts(1 99)

gen totaltaxes_pe = totaltaxes/enrollment*1000
replace totaltaxes_pe = totaltaxes_pe*scaler
winsor2 totaltaxes_pe, replace cuts(1 99)

gen log_totaltaxes_pc = log(totaltaxes_pc+1)
winsor2 log_totaltaxes_pc, replace cuts(1 99)

gen log_totaltaxes_pe = log(totaltaxes_pe+1)
winsor2 log_totaltaxes_pe, replace cuts(1 99)

gen totaltaxes_toexp = totaltaxes/totalexpenditure*100
winsor2 totaltaxes_toexp, replace cuts(1 99)

// Property tax

winsor2 propertytax, replace cuts(1 99) by(typecode calendar_year)

gen log_propertytax = log(propertytax+1)
winsor2 log_propertytax, replace cuts(1 99)

gen propertytax_pc = propertytax/population*1000
replace propertytax_pc = propertytax_pc*scaler
winsor2 propertytax_pc, replace cuts(1 99)

gen propertytax_pe = propertytax/enrollment*1000
replace propertytax_pe = propertytax_pe*scaler
winsor2 propertytax_pe, replace cuts(1 99)

gen log_propertytax_pc = log(propertytax_pc+1)
winsor2 log_propertytax_pc, replace cuts(1 99)

gen log_propertytax_pe = log(propertytax_pe+1)
winsor2 log_propertytax_pe, replace cuts(1 99)

gen propertytax_toexp = propertytax/totalexpenditure*100
winsor2 propertytax_toexp, replace cuts(1 99)

/*--- Surplus ---*/

winsor2 totalexpenditure, replace cuts(1 99) by(typecode calendar_year)
winsor2 totalrevenue, replace cuts(1 99) by(typecode calendar_year)

gen surplus = totalrevenue-totalexpenditure
winsor2 surplus, replace cuts(1 99)

gen surplus_pc = surplus/population*1000
replace surplus_pc = surplus_pc*scaler
winsor2 surplus_pc, replace cuts(1 99)

gen surplus_pe = surplus/enrollment*1000
replace surplus_pe = surplus_pe*scaler
winsor2 surplus_pe, replace cuts(1 99)

gen log_surplus_pc = log(surplus_pc+1)
winsor2 log_surplus_pc, replace cuts(1 99)

gen log_surplus_pe = log(surplus_pe+1)
winsor2 log_surplus_pe, replace cuts(1 99)

gen surplus_ratio = (totalrevenue/totalexpenditure-1)*100
winsor2 surplus_ratio, replace cuts(1 99)

/*--- Issuance of long-term debt ---*/

winsor2 totalltdissued, replace cuts(1 99) by(typecode calendar_year)

gen log_totalltdissued = log(totalltdissued+1)
winsor2 log_totalltdissued, replace cuts(1 99)

gen totalltdissued_pc = totalltdissued/population*1000
replace totalltdissued_pc = totalltdissued_pc*scaler
winsor2 totalltdissued_pc, replace cuts(1 99)

gen totalltdissued_pe = totalltdissued/enrollment*1000
replace totalltdissued_pe = totalltdissued_pe*scaler
winsor2 totalltdissued_pe, replace cuts(1 99)

gen log_totalltdissued_pc = log(totalltdissued_pc+1)
winsor2 log_totalltdissued_pc, replace cuts(1 99)

gen log_totalltdissued_pe = log(totalltdissued_pe+1)
winsor2 log_totalltdissued_pe, replace cuts(1 99)

gen totalltdissued_toexp = totalltdissued/totalexpenditure*100
winsor2 totalltdissued_toexp, replace cuts(1 99)

/*--- Change in balance of short-term debt ---*/

cap gen stdebtendofyear_toexp = stdebtendofyear/totalexpenditure*100
cap winsor2 stdebtendofyear_toexp, replace cuts(1 99) by(typecode calendar_year)

cap gen stdebt_change = stdebtendofyear-stdebtbeginningofyear 

cap winsor2 stdebt_change, replace cuts(1 99) by(typecode calendar_year)

cap gen stdebt_change_toexp = stdebt_change/totalexpenditure*100
cap winsor2 stdebt_change_toexp, replace cuts(1 99)


