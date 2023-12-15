###############
# Import CBSA #
###############

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


##############
# Import GPF #
##############

# Import GPF
GPF = pd.read_csv("../RawData/SDC/GPF.csv",low_memory=False)
if 'Unnamed: 0' in GPF.columns:
    GPF = GPF.drop(columns=['Unnamed: 0'])

# Generate cleaned names
raw_name_GPF_colnames = [column for column in GPF.columns if 'raw_name_GPF_' in column]
idx = 0
for column in raw_name_GPF_colnames:
    GPF['name_GPF_'+str(idx)] = GPF[column].apply(FUN_proc_name)
    idx = idx+1
name_GPF_colnames = ['name_GPF_'+str(idx) for idx in range(0,len(raw_name_GPF_colnames))]


# Hand corrections
# Change "CHEMICAL BANK" to "CHEMICAL BANK MICHIGAN" for deals in MI
GPF.loc[(GPF['lead_manager'].str.contains('Chemical Bank'))&(GPF['State']=='MI'),'lead_manager'] = 'CHEMICAL BANK MICHIGAN'
for column in raw_name_GPF_colnames:
    GPF.loc[(GPF['raw_name_GPF_0'].str.contains('Chemical Bank'))&(GPF['State']=='MI'),column] = 'CHEMICAL BANK MICHIGAN'

# Sometimes name of an entity that arise due to merger appear prior to merger
GPF.loc[(GPF['lead_manager']=='Dean Witter Reynolds Inc.')&(GPF['sale_year']<1978),'lead_manager'] = 'Dean Witter'
for column in raw_name_GPF_colnames:
    GPF.loc[(GPF['raw_name_GPF_0']=='Dean Witter Reynolds Inc.')&(GPF['sale_year']<1978),column] = 'Dean Witter'

GPF.loc[(GPF['lead_manager']=='Prescott, Ball & Turben, Inc.')&(GPF['sale_year']<1973),'lead_manager'] = 'Prescott, Merrill, Turben'
for column in raw_name_GPF_colnames:
    GPF.loc[(GPF['raw_name_GPF_0']=='Prescott, Ball & Turben, Inc.')&(GPF['sale_year']<1973),column] = 'Prescott, Merrill, Turben'

# Whether dual advisor/underwriter
GPF['raw_advisor_long'] = GPF['advisor_long']
GPF['raw_advisor_short'] = GPF['advisor_short']
GPF['advisor_long'] = GPF['advisor_long'].apply(FUN_proc_name)
GPF['advisor_short'] = GPF['advisor_short'].apply(FUN_proc_name)
GPF['if_dual_advisor'] = False
for col in name_GPF_colnames:
    GPF['if_dual_advisor'] = (GPF['if_dual_advisor'])|(GPF['advisor_long']==GPF[col])

# Winsorize data. Handle missing values cases carefully

upper_limit = np.percentile(GPF['gross_spread'][np.logical_not(np.isnan(GPF['gross_spread']))],99)
lower_limit = np.percentile(GPF['gross_spread'][np.logical_not(np.isnan(GPF['gross_spread']))],1)
GPF.loc[(GPF['gross_spread']>upper_limit)&(np.logical_not(np.isnan(GPF['gross_spread']))),'gross_spread'] = \
    upper_limit
GPF.loc[(GPF['gross_spread']<lower_limit)&(np.logical_not(np.isnan(GPF['gross_spread']))),'gross_spread'] = \
    lower_limit

upper_limit = np.percentile(GPF['avg_yield'][np.logical_not(np.isnan(GPF['avg_yield']))],99)
lower_limit = np.percentile(GPF['avg_yield'][np.logical_not(np.isnan(GPF['avg_yield']))],1)
GPF.loc[(GPF['avg_yield']>upper_limit)&(np.logical_not(np.isnan(GPF['avg_yield']))),'avg_yield'] = \
    upper_limit
GPF.loc[(GPF['avg_yield']<lower_limit)&(np.logical_not(np.isnan(GPF['avg_yield']))),'avg_yield'] = \
    lower_limit

upper_limit = np.percentile(GPF['avg_spread'][np.logical_not(np.isnan(GPF['avg_spread']))],99)
lower_limit = np.percentile(GPF['avg_spread'][np.logical_not(np.isnan(GPF['avg_spread']))],1)
GPF.loc[(GPF['avg_spread']>upper_limit)&(np.logical_not(np.isnan(GPF['avg_spread']))),'avg_spread'] = \
    upper_limit
GPF.loc[(GPF['avg_spread']<lower_limit)&(np.logical_not(np.isnan(GPF['avg_spread']))),'avg_spread'] = \
    lower_limit



#######################
# Merge GPF with CBSA #
#######################

# First try to merge with first item before '/'
GPF = GPF.reset_index(drop=True)
GPF = GPF[~pd.isnull(GPF['County'])]
for idx,row in GPF.iterrows():
    if '/' in row['County']:
        GPF.at[idx,'County'] = row['County'].split('/')[0]
GPF = GPF.merge(CBSAData[['CBSA Code','CSA Code','CBSA Title','CSA Title','County','State']],
    on=['County','State'],how='outer',indicator=True)

GPF = GPF[GPF['State']!='nan']
GPF = GPF[GPF['State']!='AS']
GPF = GPF[GPF['State']!='DC']
GPF = GPF[GPF['State']!='FF']
GPF = GPF[GPF['State']!='GU']
GPF = GPF[GPF['State']!='MR']
GPF = GPF[GPF['State']!='PR']
GPF = GPF[GPF['State']!='TT']
GPF = GPF[GPF['State']!='VI']

# Notes:
# Most cases it is because a county does not belong to any CBSA: Out of 3,000 counties in US, only 2,000 in CBSAData.
# Sometimes other "/" items lead to the right match in CBSAData.
# Some "County" fields are occupied by cities or school districts.
# Many cases issuer is "STATE AUTHORITY" or "COLLEGE OR UNIVERSITY".

# Handle cases where other "/" items might lead to the right match in CBSA
for idx,row in GPF.iterrows():
    if type(row['County_raw'])==str:
        if (row['_merge']=='left_only')&('/' in row['County_raw']):
            for item in row['County_raw'].split('/'):
                item = item.upper()
                CBSA_frag = CBSAData[(CBSAData['County']==item)&(CBSAData['State']==row['State'])].reset_index()
                if len(CBSA_frag)>0:
                    GPF.at[idx,'CBSA Code'] = CBSA_frag['CBSA Code'][0]
                    GPF.at[idx,'CSA Code'] = CBSA_frag['CSA Code'][0]
                    GPF.at[idx,'CBSA Title'] = CBSA_frag['CBSA Title'][0]
                    GPF.at[idx,'CSA Title'] = CBSA_frag['CSA Title'][0]
                    GPF.at[idx,'_merge'] = 'both'
                    # No need to continue once a match is found
                    break

#----------------#
# Credit ratings #
#----------------#

# Whether has rating
GPF['has_Moodys'] = \
    (GPF['Moodys_ILTR'].str.contains('A'))|(GPF['Moodys_ISTR'].str.contains('A'))|\
    (GPF['Moodys_ILTR'].str.contains('B'))|(GPF['Moodys_ISTR'].str.contains('B'))|\
    (GPF['Moodys_ILTR'].str.contains('C'))|(GPF['Moodys_ISTR'].str.contains('C'))
GPF['has_Fitch'] = \
    (GPF['Fitch_ILTR'].str.contains('A'))|(GPF['Fitch_ISTR'].str.contains('A'))|\
    (GPF['Fitch_ILTR'].str.contains('B'))|(GPF['Fitch_ISTR'].str.contains('B'))|\
    (GPF['Fitch_ILTR'].str.contains('C'))|(GPF['Fitch_ISTR'].str.contains('C'))|\
    (GPF['Fitch_ILTR'].str.contains('D'))|(GPF['Fitch_ISTR'].str.contains('D'))

# Ratings in numerical score. Take the best rating
GPF['rating_Moodys'] = None
for idx,row in GPF.iterrows():
    if str(row['Moodys_ILTR'])=='None' or str(row['Moodys_ISTR'])=='nan':
        continue
    if 'Aaa' in row['Moodys_ILTR'] or 'Aa1' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 0
    elif 'Aa1' in row['Moodys_ILTR'] or 'Aa1' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 1
    elif 'Aa2' in row['Moodys_ILTR'] or 'Aa2' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 2
    elif 'Aa3' in row['Moodys_ILTR'] or 'Aa3' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 3
    elif 'A1' in row['Moodys_ILTR'] or 'A1' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 4
    elif 'A2' in row['Moodys_ILTR'] or 'A2' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 5
    elif 'A3' in row['Moodys_ILTR'] or 'A3' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 6
    elif 'Baa1' in row['Moodys_ILTR'] or 'Baa1' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 7
    elif 'Baa2' in row['Moodys_ILTR'] or 'Baa2' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 8
    elif 'Baa3' in row['Moodys_ILTR'] or 'Baa3' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 9
    elif 'Ba1' in row['Moodys_ILTR'] or 'Ba1' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 10
    elif 'Ba2' in row['Moodys_ILTR'] or 'Ba2' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 11
    elif 'Ba3' in row['Moodys_ILTR'] or 'Ba3' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 12
    elif 'B1' in row['Moodys_ILTR'] or 'B1' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 13
    elif 'B2' in row['Moodys_ILTR'] or 'B2' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 14
    elif 'B3' in row['Moodys_ILTR'] or 'B3' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 15
    elif 'Caa1' in row['Moodys_ILTR'] or 'Caa1' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 16
    elif 'Caa2' in row['Moodys_ILTR'] or 'Caa2' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 17
    elif 'Caa3' in row['Moodys_ILTR'] or 'Caa3' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 18
    elif 'Ca' in row['Moodys_ILTR'] or 'Ca' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 19
    elif 'C' in row['Moodys_ILTR'] or 'C' in row['Moodys_ISTR']:
        GPF.at[idx,'rating_Moodys'] = 20

GPF['rating_Fitch'] = None
for idx,row in GPF.iterrows():
    if str(row['Fitch_ILTR'])=='None' or str(row['Fitch_ISTR'])=='nan':
        continue
    if 'AAA' in row['Fitch_ILTR'] or 'AAA' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 0
    elif 'AA+' in row['Fitch_ILTR'] or 'AA+' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 1
    elif 'AA' in row['Fitch_ILTR'] or 'AA' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 2
    elif 'AA-' in row['Fitch_ILTR'] or 'AA-' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 3
    elif 'A+' in row['Fitch_ILTR'] or 'A+' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 4
    elif 'A' in row['Fitch_ILTR'] or 'A' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 5
    elif 'A-' in row['Fitch_ILTR'] or 'A-' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 6
    elif 'BBB+' in row['Fitch_ILTR'] or 'BBB+' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 7
    elif 'BBB' in row['Fitch_ILTR'] or 'BBB' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 8
    elif 'BBB-' in row['Fitch_ILTR'] or 'BBB-' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 9
    elif 'BB+' in row['Fitch_ILTR'] or 'BB+' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 10
    elif 'BB' in row['Fitch_ILTR'] or 'BB' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 11
    elif 'BB-' in row['Fitch_ILTR'] or 'BB-' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 12
    elif 'B+' in row['Fitch_ILTR'] or 'B+' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 13
    elif 'B' in row['Fitch_ILTR'] or 'B' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 14
    elif 'B-' in row['Fitch_ILTR'] or 'B-' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 15
    elif 'CCC+' in row['Fitch_ILTR'] or 'CCC+' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 16
    elif 'CCC' in row['Fitch_ILTR'] or 'CCC' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 17
    elif 'CCC-' in row['Fitch_ILTR'] or 'CCC-' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 18
    elif 'CC+' in row['Fitch_ILTR'] or 'CC+' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 19
    elif 'CC' in row['Fitch_ILTR'] or 'CC' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 20
    elif 'CC-' in row['Fitch_ILTR'] or 'CC-' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 21
    elif 'C+' in row['Fitch_ILTR'] or 'C+' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 22
    elif 'C' in row['Fitch_ILTR'] or 'C' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 22
    elif 'C-' in row['Fitch_ILTR'] or 'C-' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 23
    elif 'D+' in row['Fitch_ILTR'] or 'D+' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 24
    elif 'D' in row['Fitch_ILTR'] or 'D' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 25
    elif 'D-' in row['Fitch_ILTR'] or 'D-' in row['Fitch_ISTR']:
        GPF.at[idx,'rating_Fitch'] = 16
