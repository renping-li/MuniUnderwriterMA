def FUN_0D_Add_Amount_Category_WithinCSA(GPF):

    import pandas as pd

    # Amount, when sorted within CSA
    CSAs = list(GPF['CSA Code'].unique())
    CSAs = [item for item in CSAs if item!=None]
    CSAs = [item for item in CSAs if str(item)!='None']
    CSAs = [item for item in CSAs if str(item)!='nan']
    years = list(GPF['sale_year'].unique())
    for CSA in CSAs:
        for year in years:
            mask_onecsayear = (GPF['sale_year']==year)&(GPF['CSA Code']==CSA)
            GPF.loc[mask_onecsayear,'csa_amount_is_mega'] = \
                GPF[mask_onecsayear]['amount']>GPF[mask_onecsayear]['amount'].quantile(0.95)
            GPF.loc[mask_onecsayear,'csa_amount_is_large'] = \
                (GPF[mask_onecsayear]['amount']<=GPF[mask_onecsayear]['amount'].quantile(0.95))&\
                (GPF[mask_onecsayear]['amount']>GPF[mask_onecsayear]['amount'].quantile(0.75))
            GPF.loc[mask_onecsayear,'csa_amount_is_med'] = \
                (GPF[mask_onecsayear]['amount']<=GPF[mask_onecsayear]['amount'].quantile(0.75))&\
                (GPF[mask_onecsayear]['amount']>GPF[mask_onecsayear]['amount'].quantile(0.5))
            GPF.loc[mask_onecsayear,'csa_amount_is_small'] = \
                GPF[mask_onecsayear]['amount']<=GPF[mask_onecsayear]['amount'].quantile(0.5)
    GPF['csa_amount_bracket'] = ""
    GPF.loc[pd.isnull(GPF['csa_amount_is_mega']),'csa_amount_is_mega'] = False
    GPF.loc[pd.isnull(GPF['csa_amount_is_large']),'csa_amount_is_large'] = False
    GPF.loc[pd.isnull(GPF['csa_amount_is_med']),'csa_amount_is_med'] = False
    GPF.loc[pd.isnull(GPF['csa_amount_is_small']),'csa_amount_is_small'] = False
    GPF.loc[GPF['csa_amount_is_mega'],'csa_amount_bracket'] = 'mega'
    GPF.loc[GPF['csa_amount_is_large'],'csa_amount_bracket'] = 'large'
    GPF.loc[GPF['csa_amount_is_med'],'csa_amount_bracket'] = 'med'
    GPF.loc[GPF['csa_amount_is_small'],'csa_amount_bracket'] = 'small'
    GPF = GPF.drop(columns=['csa_amount_is_mega','csa_amount_is_large','csa_amount_is_med','csa_amount_is_small'])

    return GPF
