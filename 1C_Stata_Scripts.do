
cd "/Users/renpingli/Dropbox/MunicipalBond/Codes_MuniMarketPower"

global MainThreshold = "HHI" // Alternatively, "MarketShare"

do 1C_Table_SummStats.do

do 1D_Table_SpreadMainResults.do
do 1D_Table_SpreadHeteroEffects.do
do 1D_Figure_SpreadMainResults.do
do 1D_Figure_EffectByUse.do

do 1E_Table_YieldResults.do
do 1E_Figure_YieldResults.do

do 1F_Table_ExamineEfficiency.do
do 1F_Figure_ExamineEfficiency.do
do 1F_Table_PredictOtherFees.do
do 1F_Table_NetCost.do

do 1G_Table_SpreadRobustness.do
do 1G_Table_SpreadIV.do
do 1G_Table_SpreadPlacebo.do

do 1H_Table_Quantity.do

