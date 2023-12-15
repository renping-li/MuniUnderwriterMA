def FUN_GetQ_byUsageBB(year,GPF):

    import pandas as pd
    import numpy as np
    
    StateXCounty = []
    for idx, row in GPF[['State','County']].drop_duplicates().reset_index().iterrows():
        StateXCounty = StateXCounty+[[row['State'],row['County']]]
    
    UsageBB = list(GPF['use_of_proceeds_BB'].unique())
    StateXCountyXUsageBB = [A+[B] for A in StateXCounty for B in UsageBB]
    StateXCountyXUsageBB = pd.DataFrame(StateXCountyXUsageBB,columns=['State','County','use_of_proceeds_BB'])
    StateXCountyXUsageBB['amount'] = 0
    StateXCountyXUsageBB['sale_year'] = year
    
    GPF_oneyear = GPF[GPF['sale_year']==year]
    for idx,row in GPF_oneyear.iterrows():
    
        amount_idx = np.argmax(\
            (StateXCountyXUsageBB['State']==row['State'])& \
            (StateXCountyXUsageBB['County']==row['County'])& \
            (StateXCountyXUsageBB['use_of_proceeds_BB']==row['use_of_proceeds_BB'])& \
            (StateXCountyXUsageBB['sale_year']==row['sale_year'])
            )
        StateXCountyXUsageBB.at[amount_idx,'amount'] = StateXCountyXUsageBB.at[amount_idx,'amount']+row['amount']
    
    return StateXCountyXUsageBB
