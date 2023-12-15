def FUN_GetQ_byUsageGeneral(year,GPF):

    import pandas as pd
    import numpy as np
    
    StateXCounty = []
    for idx, row in GPF[['State','County']].drop_duplicates().reset_index().iterrows():
        StateXCounty = StateXCounty+[[row['State'],row['County']]]
    
    UsageGeneral = list(GPF['use_of_proceeds_general'].unique())
    StateXCountyXUsageGeneral = [A+[B] for A in StateXCounty for B in UsageGeneral]
    StateXCountyXUsageGeneral = pd.DataFrame(StateXCountyXUsageGeneral,columns=['State','County','use_of_proceeds_general'])
    StateXCountyXUsageGeneral['amount'] = 0
    StateXCountyXUsageGeneral['sale_year'] = year
    
    GPF_oneyear = GPF[GPF['sale_year']==year]
    for idx,row in GPF_oneyear.iterrows():
    
        amount_idx = np.argmax(\
            (StateXCountyXUsageGeneral['State']==row['State'])& \
            (StateXCountyXUsageGeneral['County']==row['County'])& \
            (StateXCountyXUsageGeneral['use_of_proceeds_general']==row['use_of_proceeds_general'])& \
            (StateXCountyXUsageGeneral['sale_year']==row['sale_year'])
            )
        StateXCountyXUsageGeneral.at[amount_idx,'amount'] = StateXCountyXUsageGeneral.at[amount_idx,'amount']+row['amount']
    
    return StateXCountyXUsageGeneral
