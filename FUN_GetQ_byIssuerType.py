def FUN_GetQ_byIssuerType(year,GPF):

    import pandas as pd
    import numpy as np
    
    StateXCounty = []
    for idx, row in GPF[['State','County']].drop_duplicates().reset_index().iterrows():
        StateXCounty = StateXCounty+[[row['State'],row['County']]]
    
    IssuerType = list(GPF['issuer_type_full'].unique())
    StateXCountyXIssuerType = [A+[B] for A in StateXCounty for B in IssuerType]
    StateXCountyXIssuerType = pd.DataFrame(StateXCountyXIssuerType,columns=['State','County','issuer_type_full'])
    StateXCountyXIssuerType['amount'] = 0
    StateXCountyXIssuerType['sale_year'] = year
    
    GPF_oneyear = GPF[GPF['sale_year']==year]
    for idx,row in GPF_oneyear.iterrows():
    
        amount_idx = np.argmax(\
            (StateXCountyXIssuerType['State']==row['State'])& \
            (StateXCountyXIssuerType['County']==row['County'])& \
            (StateXCountyXIssuerType['issuer_type_full']==row['issuer_type_full'])& \
            (StateXCountyXIssuerType['sale_year']==row['sale_year'])
            )
        StateXCountyXIssuerType.at[amount_idx,'amount'] = StateXCountyXIssuerType.at[amount_idx,'amount']+row['amount']
    
    return StateXCountyXIssuerType
