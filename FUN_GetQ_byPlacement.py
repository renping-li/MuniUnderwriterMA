def FUN_GetQ_byPlacement(year,GPF):

    import pandas as pd
    import numpy as np
    
    StateXCounty = []
    for idx, row in GPF[['State','County']].drop_duplicates().reset_index().iterrows():
        StateXCounty = StateXCounty+[[row['State'],row['County']]]
    
    Bid = list(GPF['Bid'].unique())
    StateXCountyXBid = [A+[B] for A in StateXCounty for B in Bid]
    StateXCountyXBid = pd.DataFrame(StateXCountyXBid,columns=['State','County','Bid'])
    StateXCountyXBid['amount'] = 0
    StateXCountyXBid['sale_year'] = year
    
    GPF_oneyear = GPF[GPF['sale_year']==year]
    for idx,row in GPF_oneyear.iterrows():
    
        amount_idx = np.argmax(\
            (StateXCountyXBid['State']==row['State'])& \
            (StateXCountyXBid['County']==row['County'])& \
            (StateXCountyXBid['Bid']==row['Bid'])& \
            (StateXCountyXBid['sale_year']==row['sale_year'])
            )
        StateXCountyXBid.at[amount_idx,'amount'] = StateXCountyXBid.at[amount_idx,'amount']+row['amount']
    
    return StateXCountyXBid
