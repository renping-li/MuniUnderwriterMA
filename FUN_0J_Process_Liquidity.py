def FUN_0J_Process_Liquidity(year):

    import pandas as pd
    import numpy as np
    import scipy as sp
    import os
    import dask
    import dask.dataframe as dd
    import itertools
    from itertools import chain
    from math import sqrt, floor, ceil, isnan
    import multiprocess
    import multiprocessing
    import importlib
    from importlib import reload
    from collections import Counter
    from fuzzywuzzy import process, fuzz
    import time
    import seaborn as sns
    import geopandas as gpd
    import matplotlib.pyplot as plt
    import matplotlib.colors as colors
    import warnings
    import pyreadstat
    import bisect
    warnings.filterwarnings("error")

    # For unknown reasons, cannot download data as "dta" with correct dates in Feb 2024
    if year not in [2016,2022,2023]:
        TradeData,TradeDataMeta = pyreadstat.read_dta('../RawData/MSRB/MSRB_'+str(year)+'.dta')
    else:
        TradeData = pd.read_csv('../RawData/MSRB/MSRB_'+str(year)+'.csv',low_memory=False)
        TradeData['trade_date'] = pd.to_datetime(TradeData['trade_date'], format='%d/%m/%Y',errors='coerce')
        TradeData['dated_date'] = pd.to_datetime(TradeData['dated_date'], format='%d/%m/%Y',errors='coerce')
        TradeData['maturity_date'] = pd.to_datetime(TradeData['maturity_date'], format='%d/%m/%Y',errors='coerce')
        TradeData['settlement_date'] = pd.to_datetime(TradeData['settlement_date'], format='%d/%m/%Y',errors='coerce')
        TradeData['rtrs_publish_date'] = pd.to_datetime(TradeData['rtrs_publish_date'], format='%d/%m/%Y',errors='coerce')

    TradeData_gb = TradeData.groupby('cusip')
    
    liquidity_oneyear = []
    
    for CUSIP in list(TradeData_gb.groups.keys()):
    
        TradeData_oneCUSIP = TradeData_gb.get_group(CUSIP).copy()

        TradeData_oneCUSIP = TradeData_oneCUSIP[TradeData_oneCUSIP['par_traded']!='1MM+']
        if len(TradeData_oneCUSIP)==0:
            continue
        TradeData_oneCUSIP['par_traded'] = TradeData_oneCUSIP['par_traded'].astype(float)
        
        # Reset data
        n_trades = None
        dollar_trades = None
        percent_markup_withinmonth = None
        percent_markup_withinweek = None
        
        # N trades
        n_trades = len(TradeData_oneCUSIP)
        
        # Par traded in dollar
        dollar_trades = np.sum(TradeData_oneCUSIP['par_traded'])
        
        # Markup, comparing trades within same month
        TradeData_oneCUSIP['trade_month'] = TradeData_oneCUSIP['trade_date'].dt.month
        months_available = list(TradeData_oneCUSIP['trade_month'].unique())
        percent_markup_withinmonth_allmonths = []
        for month in months_available:
            TradeData_oneCUSIP_onemonth = TradeData_oneCUSIP[TradeData_oneCUSIP['trade_month']==month].copy()
            # "S" means "a sale to a customer by a dealer"
            if (np.sum(TradeData_oneCUSIP_onemonth['trade_type_indicator']=='S')>0) and \
                (np.sum(TradeData_oneCUSIP_onemonth['trade_type_indicator']=='D')>0):
                TradeData_oneCUSIP_onemonth_S = \
                    TradeData_oneCUSIP_onemonth[TradeData_oneCUSIP_onemonth['trade_type_indicator']=='S'].copy()
                TradeData_oneCUSIP_onemonth_D = \
                    TradeData_oneCUSIP_onemonth[TradeData_oneCUSIP_onemonth['trade_type_indicator']=='D'].copy()
                if np.sum(TradeData_oneCUSIP_onemonth_S['par_traded'])>0 and np.sum(TradeData_oneCUSIP_onemonth_D['par_traded'])>0:
                    weighted_price_S = \
                        np.dot(TradeData_oneCUSIP_onemonth_S['dollar_price'],TradeData_oneCUSIP_onemonth_S['par_traded'])/ \
                        np.sum(TradeData_oneCUSIP_onemonth_S['par_traded'])
                    weighted_price_D = \
                        np.dot(TradeData_oneCUSIP_onemonth_D['dollar_price'],TradeData_oneCUSIP_onemonth_D['par_traded'])/ \
                        np.sum(TradeData_oneCUSIP_onemonth_D['par_traded'])
                    if weighted_price_D>0:
                        percent_markup_withinmonth = weighted_price_S/weighted_price_D-1
                        percent_markup_withinmonth_allmonths = percent_markup_withinmonth_allmonths+[percent_markup_withinmonth]
        if len(percent_markup_withinmonth_allmonths)>0:
            percent_markup_withinmonth = np.mean(percent_markup_withinmonth_allmonths)
        
        # Markup, comparing trades within same week
        TradeData_oneCUSIP['trade_week'] = TradeData_oneCUSIP['trade_date'].dt.isocalendar().week
        weeks_available = list(TradeData_oneCUSIP['trade_week'].unique())
        percent_markup_withinweek_allweeks = []
        for week in weeks_available:
            TradeData_oneCUSIP_oneweek = TradeData_oneCUSIP[TradeData_oneCUSIP['trade_week']==week].copy()
            # "S" means "a sale to a customer by a dealer"
            if (np.sum(TradeData_oneCUSIP_oneweek['trade_type_indicator']=='S')>0) and \
                (np.sum(TradeData_oneCUSIP_oneweek['trade_type_indicator']=='D')>0):
                TradeData_oneCUSIP_oneweek_S = \
                    TradeData_oneCUSIP_oneweek[TradeData_oneCUSIP_oneweek['trade_type_indicator']=='S'].copy()
                TradeData_oneCUSIP_oneweek_D = \
                    TradeData_oneCUSIP_oneweek[TradeData_oneCUSIP_oneweek['trade_type_indicator']=='D'].copy()
                if np.sum(TradeData_oneCUSIP_oneweek_S['par_traded'])>0 and np.sum(TradeData_oneCUSIP_oneweek_D['par_traded'])>0:
                    weighted_price_S = \
                        np.dot(TradeData_oneCUSIP_oneweek_S['dollar_price'],TradeData_oneCUSIP_oneweek_S['par_traded'])/ \
                        np.sum(TradeData_oneCUSIP_oneweek_S['par_traded'])
                    weighted_price_D = \
                        np.dot(TradeData_oneCUSIP_oneweek_D['dollar_price'],TradeData_oneCUSIP_oneweek_D['par_traded'])/ \
                        np.sum(TradeData_oneCUSIP_oneweek_D['par_traded'])
                    if weighted_price_D>0:
                        percent_markup_withinweek = weighted_price_S/weighted_price_D-1
                        percent_markup_withinweek_allweeks = percent_markup_withinweek_allweeks+[percent_markup_withinweek]
        if len(percent_markup_withinweek_allweeks)>0:
            percent_markup_withinweek = np.mean(percent_markup_withinweek_allweeks)
    
        liquidity_oneyear = liquidity_oneyear+[{
            'CUSIP':CUSIP,
            'year':year,
            'n_trades':n_trades,
            'dollar_trades':dollar_trades,
            'percent_markup_withinmonth':percent_markup_withinmonth,
            'percent_markup_withinweek':percent_markup_withinweek,
            }]

    liquidity_oneyear = pd.DataFrame(liquidity_oneyear)
    print('Processed year '+str(year)+' liquidity measures.')

    return liquidity_oneyear
