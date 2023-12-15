def FUN_GetQ_byUsageMain(year,GPF):

    import pandas as pd
    import numpy as np
    
    StateXCounty = []
    for idx, row in GPF[['State','County']].drop_duplicates().reset_index().iterrows():
        StateXCounty = StateXCounty+[[row['State'],row['County']]]
    
    UsageMain = list(GPF['use_of_proceeds_main'].unique())
    StateXCountyXUsageMain = [A+[B] for A in StateXCounty for B in UsageMain]
    StateXCountyXUsageMain = pd.DataFrame(StateXCountyXUsageMain,columns=['State','County','use_of_proceeds_main'])
    StateXCountyXUsageMain['amount'] = 0
    StateXCountyXUsageMain['sale_year'] = year
    
    GPF_oneyear = GPF[GPF['sale_year']==year]
    for idx,row in GPF_oneyear.iterrows():
    
        amount_idx = np.argmax(\
            (StateXCountyXUsageMain['State']==row['State'])& \
            (StateXCountyXUsageMain['County']==row['County'])& \
            (StateXCountyXUsageMain['use_of_proceeds_main']==row['use_of_proceeds_main'])& \
            (StateXCountyXUsageMain['sale_year']==row['sale_year'])
            )
        StateXCountyXUsageMain.at[amount_idx,'amount'] = StateXCountyXUsageMain.at[amount_idx,'amount']+row['amount']
    
    return StateXCountyXUsageMain
