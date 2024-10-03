def FUN_0A_Match_TBB_GPF(GPF,BBIssueDataAll,state_abbreviations):

    import pandas as pd
    import numpy as np
    import re
    
    for idx,row in BBIssueDataAll.iterrows():
    
        # Find the match for each TBB issue in GPF
        GPF_candidate = GPF[GPF['sale_date']>=row['sale_date']-pd.Timedelta(days=5)]
        GPF_candidate = GPF_candidate[GPF_candidate['sale_date']<=row['sale_date']+pd.Timedelta(days=5)]
        GPF_candidate = GPF_candidate[GPF_candidate['dated_date']>=row['dated_date']-pd.Timedelta(days=5)]
        GPF_candidate = GPF_candidate[GPF_candidate['dated_date']<=row['dated_date']+pd.Timedelta(days=5)]
        GPF_candidate = GPF_candidate[GPF_candidate['State']==state_abbreviations[row['state']]]
        # Skip if amount is missing in TBB
        if row['amount']==None:
            continue
        if len(row['amount'])==0:
            continue
        if re.search(r'\D',row['amount'])!=None:
            continue
        GPF_candidate = GPF_candidate[np.absolute(GPF_candidate['amount']-int(row['amount'])/1000000)<0.05]
        GPF_candidate = GPF_candidate.copy()
        GPF_candidate['issuer_similarity'] = None
        if len(GPF_candidate)>1:
            for sub_idx,sub_row in GPF_candidate.iterrows():
                isser_GPF = sub_row['Issuer']
                isser_GPF = re.sub(r'[^A-Za-z0-9]',' ',isser_GPF)
                isser_GPF = re.sub(r'\s{2,}',' ',isser_GPF)
                isser_GPF = isser_GPF.strip()
                isser_GPF = isser_GPF.split(' ')
                TBB_GPF = row['issuer']
                TBB_GPF = re.sub(r'[^A-Za-z0-9]',' ',TBB_GPF)
                TBB_GPF = re.sub(r'\s{2,}',' ',TBB_GPF)
                TBB_GPF = TBB_GPF.strip()
                TBB_GPF = TBB_GPF.split(' ')
                common = set(isser_GPF).intersection(set(TBB_GPF))
                GPF_candidate.at[sub_idx,'issuer_similarity'] = len(common)
            GPF_candidate = GPF_candidate.sort_values('issuer_similarity',ascending=False)
            GPF_candidate = GPF_candidate[GPF_candidate['issuer_similarity']==np.max(GPF_candidate['issuer_similarity'])]
    
        # Put data from TBB to GPF
        if len(GPF_candidate)==0:
            BBIssueDataAll.at[idx,'GPF_no_match'] = True
        elif len(GPF_candidate)>1:
            BBIssueDataAll.at[idx,'GPF_multiple_match'] = True
        elif len(GPF_candidate)==1:
            index_in_GPF = GPF_candidate.index[0]
    
            GPF.at[index_in_GPF,'CaseEffRate_amounts'] = row['CaseEffRate_amounts']
            GPF.at[index_in_GPF,'CaseEffRate_purchasers'] = row['CaseEffRate_purchasers']
            GPF.at[index_in_GPF,'CaseEffRate_coupon_rates'] = row['CaseEffRate_coupon_rates']
            GPF.at[index_in_GPF,'CaseEffRate_purchase_price_minus_pars'] = row['CaseEffRate_purchase_price_minus_pars']
            GPF.at[index_in_GPF,'CaseEffRate_effective_rates'] = row['CaseEffRate_effective_rates']
            GPF.at[index_in_GPF,'CaseEffRate_lines_other_bidders'] = row['CaseEffRate_lines_other_bidders']
    
            GPF.at[index_in_GPF,'CaseTIC_purchaser'] = row['CaseTIC_purchaser']
            GPF.at[index_in_GPF,'CaseTIC_purchase_price'] = row['CaseTIC_purchase_price']
            GPF.at[index_in_GPF,'CaseTIC_TIC'] = row['CaseTIC_TIC']
            GPF.at[index_in_GPF,'CaseTIC_lines_other_bidders'] = row['CaseTIC_lines_other_bidders']
    
            GPF.at[index_in_GPF,'CaseNIC_purchaser'] = row['CaseNIC_purchaser']
            GPF.at[index_in_GPF,'CaseNIC_purchase_price'] = row['CaseNIC_purchase_price']
            GPF.at[index_in_GPF,'CaseNIC_NIC'] = row['CaseNIC_NIC']
            GPF.at[index_in_GPF,'CaseNIC_lines_other_bidders'] = row['CaseNIC_lines_other_bidders']

    return (GPF,BBIssueDataAll)
