def FUN_0D_Rank_Category_US(year,GPF):

    import pandas as pd
    import numpy as np
    from itertools import chain

    all_submarket_share_oneyear = []

    cross_section_vars = ['Bid','amount_bracket','mat_bracket','use_short','has_ratings']
    for cross_section_var in cross_section_vars:
    
        categories = list(GPF.value_counts(cross_section_var).index)
        
        GPF_oneperiod = GPF[(GPF['sale_year']<=year)&(GPF['sale_year']>=year-3)].copy()
            
        for category in categories:
        
            GPF_oneperiod_onecat = GPF_oneperiod[GPF_oneperiod[cross_section_var]==category].copy()
        
            raw_name_GPF_colnames = [column for column in GPF.columns if 'raw_name_GPF_' in column]
            name_GPF_colnames = ['name_GPF_'+str(i) for i in range(0,len(raw_name_GPF_colnames))]
            
            underwriter_names = list(chain.from_iterable(list(np.array(GPF_oneperiod_onecat[name_GPF_colnames]))))
            underwriter_names = [item for item in underwriter_names if item!=None]
            underwriter_names = [item for item in underwriter_names if str(item)!='nan']
            underwriter_names = list(set(underwriter_names))
            bank_num_deals = {}
            # Initilize deal number for every bank to be 0
            for item in underwriter_names:
                bank_num_deals[item] = 0
            # Add a "None", which is to be removed
            bank_num_deals[None] = 0
            for column in name_GPF_colnames:
                GPF_oneperiod_onecat.loc[GPF_oneperiod_onecat[column].astype(str)=='nan',column] = None
            
            # Count deal number of each bank
            # Go over each deal
            for idx,row in GPF_oneperiod_onecat.iterrows():
                # First, get weight for cases where there are multiple underwriters
                n_underwriter = 0
                for column in name_GPF_colnames:
                    if row[column]!=None and str(row[column])!='nan':
                        n_underwriter = n_underwriter+1
                # Next, count number of underwriters
                for column in name_GPF_colnames:
                    bank_num_deals[row[column]] = bank_num_deals[row[column]]+1/n_underwriter
            bank_num_deals.pop(None)
            submarket_share = pd.DataFrame(list(bank_num_deals.items()),columns=['underwriter','volume'])
            
            top5 = submarket_share['volume']>submarket_share['volume'].quantile(0.95)
            top10 = submarket_share['volume']>submarket_share['volume'].quantile(0.9)
            top25 = submarket_share['volume']>submarket_share['volume'].quantile(0.75)
            top50 = submarket_share['volume']>submarket_share['volume'].quantile(0.5)
            submarket_share['BankAttribute_top5_'+cross_section_var+'_'+str(category)] = top5
            submarket_share['BankAttribute_top10_'+cross_section_var+'_'+str(category)] = top10
            submarket_share['BankAttribute_top25_'+cross_section_var+'_'+str(category)] = top25
            submarket_share['BankAttribute_top50_'+cross_section_var+'_'+str(category)] = top50

            all_submarket_share_oneyear = all_submarket_share_oneyear+[submarket_share]

    submarket_share = all_submarket_share_oneyear[0].drop(columns=['volume'])
    for dataframe in all_submarket_share_oneyear[1:]:
        submarket_share = submarket_share.merge(dataframe.drop(columns=['volume']),on='underwriter',how='outer')
    columns = [item for item in submarket_share.columns if item!='underwriter']
    for column in columns:
        submarket_share.loc[pd.isnull(submarket_share[column]),column] = False

    submarket_share['sale_year'] = year

    # Remove columns representing missing data
    if 'BankAttribute_top5_mat_bracket_' in submarket_share.columns:
        submarket_share = submarket_share.drop(columns=['BankAttribute_top5_mat_bracket_'])
    if 'BankAttribute_top10_mat_bracket_' in submarket_share.columns:
        submarket_share = submarket_share.drop(columns=['BankAttribute_top10_mat_bracket_'])
    if 'BankAttribute_top25_mat_bracket_' in submarket_share.columns:
        submarket_share = submarket_share.drop(columns=['BankAttribute_top25_mat_bracket_'])
    if 'BankAttribute_top50_mat_bracket_' in submarket_share.columns:
        submarket_share = submarket_share.drop(columns=['BankAttribute_top50_mat_bracket_'])

    return submarket_share

