def FUN_1B_Get_Delta_CB_HHI(CSAs_part):

    import pandas as pd
    import numpy as np

    # CBs in SOD
    SOD = pd.read_csv('../CleanData/FDIC/0I_SOD.csv')
    SOD['DEPSUMBR'] = SOD['DEPSUMBR'].str.replace(',','')
    SOD['DEPSUMBR'] = SOD['DEPSUMBR'].astype(int)
    
    # M&As among CBs in SOD
    SNL_in_SOD = pd.read_csv('../CleanData/FDIC/0I_SNL_in_SOD.csv')
    SNL_in_SOD['year'] = SNL_in_SOD['Completion Date'].str[:4].astype(int)
    SNL_in_SOD = SNL_in_SOD[SNL_in_SOD['Target']!=SNL_in_SOD['Buyer']]
    SNL_in_SOD = SNL_in_SOD[['Target','Buyer','year']]

    Delta_CB_HHI = []

    for CSA in CSAs_part:

        for year in range(1995,2023):
            
            # HHI in the year prior to M&A
            SOD_prior = SOD[(SOD['CSA Code']==CSA)&(SOD['year']==year-1)].copy()
            SOD_prior = SOD_prior.groupby('name').agg({'DEPSUMBR':sum})
            
            SOD_prior = SOD_prior.reset_index()
            hhi_prior = np.sum((SOD_prior['DEPSUMBR']/np.sum(SOD_prior['DEPSUMBR']))**2)
            
            # Get SNL deals of interest in the current year
            Banks_in_SOD = SOD[(SOD['CSA Code']==CSA)&(SOD['year']==year-1)].copy()
            Banks_in_SOD = list(Banks_in_SOD['name'].unique())
            SNL_in_SOD_relevant = SNL_in_SOD[
                (SNL_in_SOD['Target'].isin(Banks_in_SOD))
                &(SNL_in_SOD['Buyer'].isin(Banks_in_SOD))
                &(SNL_in_SOD['year']==year)]
    
            if len(SNL_in_SOD_relevant)>0:
                for idx,row in SNL_in_SOD_relevant.iterrows():
                    SOD_prior.loc[SOD_prior['name']==row['Target'],'name'] = row['Buyer']
                SOD_prior = SOD_prior.groupby('name').agg({'DEPSUMBR':sum})
                hhi_post = np.sum((SOD_prior['DEPSUMBR']/np.sum(SOD_prior['DEPSUMBR']))**2)
                Delta_CB_HHI = Delta_CB_HHI+[{'CSA Code':CSA,'year':year,'CB_hhi_dif':hhi_post-hhi_prior}]
            else:
                Delta_CB_HHI = Delta_CB_HHI+[{'CSA Code':CSA,'year':year,'CB_hhi_dif':0}]

    Delta_CB_HHI = pd.DataFrame(Delta_CB_HHI)

    return Delta_CB_HHI
