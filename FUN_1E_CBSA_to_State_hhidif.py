def FUN_1E_CBSA_to_State_hhidif(State,GPF,MA,raw_name_GPF_colnames,pop_by_CBSA):

    all_state_hhi_dif = []

    import pandas as pd
    import numpy as np
    import itertools
    from itertools import chain

    
    #-------------#
    # Import CBSA #
    #-------------#
    
    us_state_to_abbrev = {
        "Alabama": "AL",
        "Alaska": "AK",
        "Arizona": "AZ",
        "Arkansas": "AR",
        "California": "CA",
        "Colorado": "CO",
        "Connecticut": "CT",
        "Delaware": "DE",
        "Florida": "FL",
        "Georgia": "GA",
        "Hawaii": "HI",
        "Idaho": "ID",
        "Illinois": "IL",
        "Indiana": "IN",
        "Iowa": "IA",
        "Kansas": "KS",
        "Kentucky": "KY",
        "Louisiana": "LA",
        "Maine": "ME",
        "Maryland": "MD",
        "Massachusetts": "MA",
        "Michigan": "MI",
        "Minnesota": "MN",
        "Mississippi": "MS",
        "Missouri": "MO",
        "Montana": "MT",
        "Nebraska": "NE",
        "Nevada": "NV",
        "New Hampshire": "NH",
        "New Jersey": "NJ",
        "New Mexico": "NM",
        "New York": "NY",
        "North Carolina": "NC",
        "North Dakota": "ND",
        "Ohio": "OH",
        "Oklahoma": "OK",
        "Oregon": "OR",
        "Pennsylvania": "PA",
        "Rhode Island": "RI",
        "South Carolina": "SC",
        "South Dakota": "SD",
        "Tennessee": "TN",
        "Texas": "TX",
        "Utah": "UT",
        "Vermont": "VT",
        "Virginia": "VA",
        "Washington": "WA",
        "West Virginia": "WV",
        "Wisconsin": "WI",
        "Wyoming": "WY",
        "District of Columbia": "DC",
        "American Samoa": "AS",
        "Guam": "GU",
        "Northern Mariana Islands": "MP",
        "Puerto Rico": "PR",
        "United States Minor Outlying Islands": "UM",
        "U.S. Virgin Islands": "VI",
    }
    
    # "CSA" is for metropolitan and "CBSA" includes also those micropolitan
    CBSAData = pd.read_excel("../RawData/MSA/CBSA.xlsx",skiprows=[0,1])
    CBSAData = CBSAData[~pd.isnull(CBSAData['County/County Equivalent'])]
    
    # Add state abbreviations
    us_state_to_abbrev = pd.DataFrame.from_dict(us_state_to_abbrev,orient='index').reset_index()
    us_state_to_abbrev.columns = ['State Name','State']
    CBSAData = CBSAData.rename(columns={'County/County Equivalent':'County'})
    CBSAData = CBSAData.merge(us_state_to_abbrev,on='State Name',how='outer',indicator=True)
    CBSAData = CBSAData[CBSAData['_merge']=='both'].drop(columns=['_merge'])
    # Merge is perfect
    CBSAData['County'] = CBSAData['County'].str.upper()
    CBSAData['County'] = CBSAData['County'].str.replace(' COUNTY','')
    CBSAData['County'] = CBSAData['County'].str.replace(' AND ',' & ')
    CBSAData['County'] = CBSAData['County'].str.replace('.','',regex=False)
    CBSAData['CSA Code'] = CBSAData['CSA Code'].astype(float)
    CBSAData['CBSA Code'] = CBSAData['CBSA Code'].astype(float)
    
    CBSAsinState = list(CBSAData[CBSAData['State']==State]['CBSA Code'].unique())
    
    for year in range(1970,2023):
    
        # Within a state X year, the implied HHI difference for every CBSA
        CBSA_hhi_dif = []
        
        for CBSA in CBSAsinState:
    
            GPF_oneCBSA_priorMA = GPF[(GPF['sale_year']>=year-3)&(GPF['sale_year']<=year)&(GPF['CBSA Code']==CBSA)]
            if len(GPF_oneCBSA_priorMA)==0:
                CBSA_hhi_dif = CBSA_hhi_dif+[{'CBSA Code':CBSA,'hhi_dif':None}]
                continue
    
            # Calculate (1) HHI (by parent firm) in the three years prior (2) Predicted HHI after the mergers complete
            
            # Underwriters in the market
            parent_name_colnames = ['parent_name_'+str(i) for i in range(0,len(raw_name_GPF_colnames))]
            name_GPFs = list(chain.from_iterable(list(np.array(GPF_oneCBSA_priorMA[parent_name_colnames]))))
            name_GPFs = [item for item in name_GPFs if item!=None]
            name_GPFs = [item for item in name_GPFs if str(item)!='nan']
            name_GPFs = list(set(name_GPFs))
            if len(name_GPFs)==0:
                CBSA_hhi_dif = CBSA_hhi_dif+[{'CBSA Code':CBSA,'hhi_dif':None}]
                continue
            n_deals = {}
            for item in name_GPFs:
                n_deals[item] = 0
            
            # Record market shares before merger episode
            parent_name_colnames = ['parent_name_'+str(i) for i in range(0,len(raw_name_GPF_colnames))]
            for idx,row in GPF_oneCBSA_priorMA.iterrows():
                underwriters_onedeal = [row[item] for item in parent_name_colnames if row[item]!=None and str(row[item])!='nan']
                n_underwriters = len(underwriters_onedeal)
                for item in underwriters_onedeal:
                    n_deals[item] = n_deals[item]+1/n_underwriters
            n_deals = pd.DataFrame.from_dict(n_deals,orient='index').reset_index()
            n_deals = n_deals.rename(columns={'index':'underwriter',0:'n_deals'})
            n_deals_prior = n_deals
            
            # HHI prior to merger
            hhi_piror = np.sum((n_deals['n_deals']/np.sum(n_deals['n_deals']))**2)
    
            # Implied HHI post merger
            # Extract MAs that are relevant
            MA_relevant = MA[(MA['target'].isin(name_GPFs))&(MA['acquiror'].isin(name_GPFs))]
            MA_relevant = MA_relevant[(MA_relevant['sale_year']<=year-1)&(MA_relevant['sale_year']>=year-3)]
            MA_relevant = MA_relevant.reset_index(drop=True)
            for idx,row in MA_relevant.iterrows():
                n_deals.loc[n_deals['underwriter']==row['target'],'underwriter'] = row['acquiror_parent']
            n_deals = n_deals.groupby('underwriter').agg({'n_deals':sum}).reset_index()
            hhi_predicted = np.sum((n_deals['n_deals']/np.sum(n_deals['n_deals']))**2)
            n_deals_post = n_deals
    
            hhi_dif = hhi_predicted-hhi_piror
    
            CBSA_hhi_dif = CBSA_hhi_dif+[{'CBSA Code':CBSA,'hhi_dif':hhi_dif}]
    
        CBSA_hhi_dif  = pd.DataFrame(CBSA_hhi_dif)
        # Stipulate HHI dif to be 0 if it is unavailable, i.e., there is no deals in three years prior which prevents calculation
        CBSA_hhi_dif = CBSA_hhi_dif[~pd.isnull(CBSA_hhi_dif['hhi_dif'])]
        CBSA_hhi_dif['sale_year'] = year

        # Calculate state wide Delta HHI
        CBSA_hhi_dif = CBSA_hhi_dif.merge(pop_by_CBSA,on=['CBSA Code','sale_year'])
        CBSA_hhi_dif = CBSA_hhi_dif[~pd.isnull(CBSA_hhi_dif['pop'])]
        # If population data not avaiable, skip 
        if np.sum(CBSA_hhi_dif['pop'])==0|len(CBSA_hhi_dif)==0:
            all_state_hhi_dif = all_state_hhi_dif+[{'State':State,'year':year,'state_hhi_dif':None}]
            continue
        state_hhi_dif = np.sum(np.dot(CBSA_hhi_dif['pop'],CBSA_hhi_dif['hhi_dif']))/np.sum(CBSA_hhi_dif['pop'])
        all_state_hhi_dif = all_state_hhi_dif+[{'State':State,'year':year,'state_hhi_dif':state_hhi_dif}]

    return pd.DataFrame(all_state_hhi_dif)

