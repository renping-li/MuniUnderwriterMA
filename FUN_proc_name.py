# This function capitalize & remove special characters from a firm name

def FUN_proc_name(name):

    if name==None:
        return name
    if type(name)==float:
        return name
    
    import re

    name = name.upper()
    name = name.replace('É','E')
    name = name.replace('é','e')
    name = name.replace('','')
    name = name.replace('.','')
    name = name.replace('/','')
    name = name.replace(',','')
    name = name.replace('\'','')
    name = name.replace('-',' ')
    name = name.replace(';',' ')
    name = name.replace('&AMP','&')
    name = name.replace(' AND ',' & ')
    name = name.strip()
    _RE_COMBINE_WHITESPACE = re.compile(r"\s+")
    name = _RE_COMBINE_WHITESPACE.sub(" ",name).strip()

    name = name.replace(' BK ',' BANK ')
    name = name.replace(' BK',' BANK')
    name = name.replace('FST','FIRST')
    name = name.replace('COMPANY','CO')
    name = name.replace('INCORPORATED','INC')
    name = name.replace('CORPORATION','CORP')
    name = name.replace('SVCS','SERVICES')
    name = name.replace('NATIONAL ASSOCIATION','NA')
    name = name.replace('NATL','NATIONAL')
    name = name.replace('BANCORP','BANK')
    name = name.replace('BANCSHARES','BANK')
    name = name.replace('BANKSHARES','BANK')
    name = name.replace('BANK & TRUST','BANK')
    name = name.replace('BANKING','BANK')

    # Run twice
    for i in range(0,2):
        if name[-5:]==' CORP':
            name = name[:-5]
        if name[-4:]==' INC':
            name = name[:-4]
        if name[-4:]==' LLC':
            name = name[:-4]
        if name[-4:]==' LTD':
            name = name[:-4]
        if name[-4:]==' THE':
            name = name[:-4]
        if name[-4:]==' PLC':
            name = name[:-4]
        if name[-4:]==' N A':
            name = name[:-4]
        if name[-3:]==' SA':
            name = name[:-3]
        if name[-3:]==' CO':
            name = name[:-3]
        if name[-3:]==' NA':
            name = name[:-3]
        if name[-2:]==' &':
            name = name[:-2]





    if name=='EASTERN CAPITAL MARKETS':
        name = 'EASTERN BANK'
    if name=='ABN AMRO BANK':
        name = 'ABN AMRO'
    if name=='ABN AMRO CHICAGO':
        name = 'ABN AMRO'
    if name=='ABN AMRO FINANCIAL SERVICES':
        name = 'ABN AMRO'
    if name=='ABN AMRO SECURITIES GROUP':
        name = 'ABN AMRO'
    if name=='AMERICAN NTNL BANK & TR CHICAGO':
        name = 'AMERICAN NTNL BANK & TR'
    if name=='AMERICAN NTNL BANK & TR ST PAUL':
        name = 'AMERICAN NTNL BANK & TR'
    if name=='BANC OF AMERICA SECURITIES':
        name = 'BANK OF AMERICA'
    if name=='BANC ONE CAPITAL MARKETS':
        name = 'BANC ONE'
    if name=='BANC ONE LEASING':
        name = 'BANC ONE'
    if name=='BANK IV KANSAS':
        name = 'BANK IV FINANCIAL SERVICES'
    if name=='BANK OF AMERICA ILLINOIS':
        name = 'BANK OF AMERICA'
    if name=='BANK OF AMERICA INTL':
        name = 'BANK OF AMERICA'
    if name=='BANK OF AMERICA NATIONAL TRUST':
        name = 'BANK OF AMERICA'
    if name=='BANK OF AMERICA NEVADA':
        name = 'BANK OF AMERICA'
    if name=='BANK OF AMERICA NT&SA':
        name = 'BANK OF AMERICA'
    if name=='BANK OF AMERICA NATIONAL TRUST':
        name = 'BANK OF AMERICA'
    if name=='BANK OF AMERICA NW':
        name = 'BANK OF AMERICA'
    if name=='BANK OF AMERICA OREGON':
        name = 'BANK OF AMERICA'
    if name=='BANK OF AMERICA PUBLIC CAPITAL':
        name = 'BANK OF AMERICA'
    if name=='BANK OF AMERICA TEXAS':
        name = 'BANK OF AMERICA'
    if name=='BANK OF AMERICAN FORK':
        name = 'BANK OF AMERICA'
    if name=='BANK OF AMERICA NATIONAL TRUST':
        name = 'BANK OF AMERICA'
    if name=='BANK OF AMERICA LEASING CAP':
        name = 'BANK OF AMERICA'
    if name=='BANK OF AMERICA PREFERRED FUND':
        name = 'BANK OF AMERICA'
    if name=='BANK OF AMERICA CAPITAL MARKET':
        name = 'BANK OF AMERICA'
    if name=='BANK ONE AKRON':
        name = 'BANC ONE'
    if name=='BANK ONE ARIZONA':
        name = 'BANC ONE'
    if name=='BANK ONE BOULDER':
        name = 'BANC ONE'
    if name=='BANK ONE CALIFORNIA':
        name = 'BANC ONE'
    if name=='BANK ONE CAPITAL':
        name = 'BANC ONE'
    if name=='BANK ONE COLORADO':
        name = 'BANC ONE'
    if name=='BANK ONE COLUMBUS':
        name = 'BANC ONE'
    if name=='BANK ONE ILLINOIS':
        name = 'BANC ONE'
    if name=='BANK ONE INDIANA':
        name = 'BANC ONE'
    if name=='BANK ONE KANSAS':
        name = 'BANC ONE'
    if name=='BANK ONE KENTUCKY':
        name = 'BANC ONE'
    if name=='BANK ONE LOUISIANA':
        name = 'BANC ONE'
    if name=='BANK ONE MICHIGAN':
        name = 'BANC ONE'
    if name=='BANK ONE MILWAUKEE':
        name = 'BANC ONE'
    if name=='BANK ONE MISSOURI':
        name = 'BANC ONE'
    if name=='BANK ONE OHIO':
        name = 'BANC ONE'
    if name=='BANK ONE OKLAHOMA':
        name = 'BANC ONE'
    if name=='BANK ONE TEXAS':
        name = 'BANC ONE'
    if name=='BANK ONE TRUST COINDIANAPOLIS':
        name = 'BANC ONE'
    if name=='BANK ONE TRUST':
        name = 'BANC ONE'
    if name=='BANK ONE WISCONSIN TRUST':
        name = 'BANC ONE'
    if name=='BANK ONE WISCONSIN':
        name = 'BANC ONE'
    if name=='BANK ONE WISCONSIN':
        name = 'BANC ONE'
    if name=='BANK ONE':
        name = 'BANC ONE'
    if name=='BANKAMERICA':
        name = 'BANK OF AMERICA'
    if name=='BANKBANK OF AMERICA PREFERRED FUND':
        name = 'BANK OF AMERICA'
    if name=='BANKERS TRUST (DEUTSCHE BANK)':
        name = 'BANKERS TRUST'
    if name=='BANKNORTH INVESTMENT MGT GROUP':
        name = 'TD BANK'
    if name=='BANK OF BOSTON CONNECTICUT':
        name = 'BANK OF BOSTON'
    if name=='TD EQUIPMENT FINANCE':
        name = 'TD BANK'
    if name=='BAYBANK BOSTON':
        name = 'BAYBANK'
    if name=='BLAYLOCK BEAL VAN':
        name = 'BLAYLOCK VAN'
    if name=='BLAYLOCK ROBERT VAN':
        name = 'BLAYLOCK VAN'
    if name=='BLYTH EASTMAN PAINE WEBBER':
        name = 'PAINE WEBBER'
    if name=='BMO CAPITAL MARKETS GKST':
        name = 'BMO BANK'
    if name=='BMO HARRIS BANK':
        name = 'BMO BANK'
    if name=='BMO HARRIS BANK':
        name = 'BMO BANK'
    if name=='BMO HARRIS INVESTMENT':
        name = 'BMO BANK'
    if name=='HARRIS TRUST & SAVINGS BANK':
        name = 'HARRIS BANK'
    if name=='BNE CAPITAL MARKETS':
        name = 'BANK OF NEW ENGLAND'
    if name=='BOATMENS BANK & TRUST CO':
        name = 'BOATMENS BANK'
    if name=='BOATMENS BANK IOWA':
        name = 'BOATMENS BANK'
    if name=='BOATMENS BANK OF MARSHALL':
        name = 'BOATMENS BANK'
    if name=='BOATMENS BANK OF NORTH IOWA':
        name = 'BOATMENS BANK'
    if name=='SALOMON SMITH BARNEY':
        name = 'SMITH BARNEY'
    if name=='BOATMENS FIRST NATIONAL BANK (OK)':
        name = 'BOATMENS BANK'
    if name=='BOATMENS FIRST NATIONAL BANK KC':
        name = 'BOATMENS BANK'
    if name=='BOATMENS FIRST NATIONAL BANK':
        name = 'BOATMENS BANK'
    if name=='BOATMENS NATIONAL BANK DES MOINES':
        name = 'BOATMENS BANK'
    if name=='BOATMENS NATIONAL BANK OF CAPE GIRAR':
        name = 'BOATMENS BANK'
    if name=='BOATMENS NATIONAL BANK OF KANSAS':
        name = 'BOATMENS BANK'
    if name=='BOATMENS NATIONAL BANK STLOUIS':
        name = 'BOATMENS BANK'
    if name=='BOATMENS TRUST COMPANY':
        name = 'BOATMENS BANK'
    if name=='BOATMENS TRUST COST LOUIS':
        name = 'BOATMENS BANK'
    if name=='BOFA SECURITIES':
        name = 'BANK OF AMERICA'
    if name=='BOK FINANCIAL SECURITIES':
        name = 'BOK FINANCIAL'
    if name=='BOKF':
        name = 'BOK FINANCIAL'
    if name=='BOSC':
        name = 'BOK FINANCIAL'
    if name=='CALUMET NATIONAL BANK':
        name = 'BANK CALUMET'
    if name=='CAPE COD FIVE CENT SAVINGS BANK':
        name = 'CAPE COD BANK'
    if name=='CAPITAL ONE BANK':
        name = 'CAPITAL ONE FINANCIAL'
    if name=='CAPITAL ONE BANK(USA)NA':
        name = 'CAPITAL ONE FINANCIAL'
    if name=='CAPITAL ONE EQUIPMENT FIN':
        name = 'CAPITAL ONE FINANCIAL'
    if name=='CAPITAL ONE MUNICIPAL FUNDING':
        name = 'CAPITAL ONE FINANCIAL'
    if name=='CAPITAL ONE PUBLIC FUNDING':
        name = 'CAPITAL ONE FINANCIAL'
    if name=='CENTERRE TRUST CO OF ST LOUIS':
        name = 'CENTERRE BANK'
    if name=='CENTURY BANK (MA)':
        name = 'CENTURY BANK'
    if name=='CHASE BANK AG':
        name = 'CHASE BANK'
    if name=='CHASE BANK OF TEXAS':
        name = 'CHASE BANK'
    if name=='FIRST NATIONAL STATE BANK EDISON':
        name = 'FIRST NATIONAL STATE BANK OF NJ'
    if name=='CHASE EQUIPMENT LEASING':
        name = 'CHASE BANK'
    if name=='CHASE INVESTMENT BANK LIMITED':
        name = 'CHASE BANK'
    if name=='CHASE INVESTMENT SERVICES':
        name = 'CHASE BANK'
    if name=='CHASE LINCOLN FIRST BANK':
        name = 'CHASE BANK'
    if name=='CHASE MANHATTAN BANK':
        name = 'CHASE BANK'
    if name=='CHASE SECURITIES':
        name = 'CHASE BANK'
    if name=='CHEMICAL BANK CFC':
        name = 'CHEMICAL BANK MICHIGAN'
    if name=='CFC CAPITAL':
        name = 'CHEMICAL BANK MICHIGAN'
    if name=='SIGNET TRUST':
        name = 'SIGNET BANK RICHMOND'
    if name=='CHEMICAL BANK WEST':
        name = 'CHEMICAL BANK MICHIGAN'
    if name=='CHEMICAL SECURITIES':
        name = 'CHEMICAL BANK'
    if name=='CHILES HEIDER & CO INC(SBH)':
        name = 'CHILES HEIDER'
    if name=='CITI COMMUNITY CAPITAL':
        name = 'CITIGROUP'
    if name=='CITI COMMUNITY CAPITAL':
        name = 'CITIGROUP'
    if name=='CITIBANK':
        name = 'CITIGROUP'
    if name=='CITICORP':
        name = 'CITIGROUP'
    if name=='CITIGROUP LEASING':
        name = 'CITIGROUP'
    if name=='CITIGROUP SECURITIES':
        name = 'CITIGROUP'
    if name=='CITICORP SECURITIES':
        name = 'CITIGROUP'
    if name=='CITIZENS & SOUTHERN NATIONAL BANKFL':
        name = 'CITIZENS & SOUTHERN NATIONAL BANK'
    if name=='CITIZENS & SOUTHERN NATIONAL BANKGA':
        name = 'CITIZENS & SOUTHERN NATIONAL BANK'
    if name=='CITIZENS & SOUTHERN NATIONAL BANKSC':
        name = 'CITIZENS & SOUTHERN NATIONAL BANK'
    if name=='CITIZENS & SOUTHERN TRST COFL':
        name = 'CITIZENS & SOUTHERN NATIONAL BANK'
    if name=='COLLINGS LEGG MASON':
        name = 'LEGG MASON'
    if name=='COMERICA SECURITIES':
        name = 'COMERICA BANK'
    if name=='CONTINENTAL BANK (IL)':
        name = 'CONTINENTAL ILLINOIS NATIONAL BANK'
    if name=='CRONIN & MARQUETTE':
        name = 'CRONIN'
    if name=='DEUTSCHE BANC ALEX BROWN':
        name = 'DEUTSCHE BANK'
    if name=='DEUTSCHE BANK AG (NEW YORK)':
        name = 'DEUTSCHE BANK'
    if name=='DEUTSCHE BANK CAPITAL MARKETS ':
        name = 'DEUTSCHE BANK'
    if name=='DEUTSCHE BANK SECURITIES':
        name = 'DEUTSCHE BANK'
    if name=='DOUGHERTY SUMMIT SECURITIES':
        name = 'DOUGHERTY'
    if name=='EVENSEN DODGE':
        name = 'EVENSON DODGE'
    if name=='FHNC FINANCIAL CAPITAL MARKETS':
        name = 'FIRST HORIZON BANK'
    if name=='FIFTH THIRD COMMERCIAL FUNDING':
        name = 'FIFTH THIRD BANK'
    if name=='FIFTH THIRD SECURITIES':
        name = 'FIFTH THIRD BANK'
    if name=='FIFTH THIRDOHIO':
        name = 'FIFTH THIRD BANK'
    if name=='FIRST CHICAGO CAPITAL MARKETS':
        name = 'FIRST CHICAGO BANK'
    if name=='FIRST HORIZON BANKMEMPHISTN':
        name = 'FIRST HORIZON BANK'
    if name=='FTN FINANCIAL CAPITAL MARKETS':
        name = 'FIRST HORIZON BANK'
    if name=='JP MORGAN CHASE BANK':
        name = 'JP MORGAN'
    if name=='FIRST MIDWEST BANK MORRIS':
        name = 'FIRST MIDWEST BANK'
    if name=='FIRST MIDWEST BANK OF GURNEE':
        name = 'FIRST MIDWEST BANK'
    if name=='FIRST MIDWEST BANK OF JOLIET':
        name = 'FIRST MIDWEST BANK'
    if name=='FIRST MIDWEST INVESTMENT':
        name = 'FIRST MIDWEST BANK'
    if name=='FIRST MIDWEST TRUST':
        name = 'FIRST MIDWEST BANK'
    if name=='FIRST NATIONAL BANK OF CHICAGO':
        name = 'FIRST CHICAGO BANK'
    if name=='FIRST NATIONAL BANK OF OMAHA':
        name = 'FIRST NATIONAL BANK OF NEBRASKA'
    if name=='FIRST NATIONAL BANK OF ST PAUL':
        name = 'FIRST NATIONAL BANK OF MINNEAPOLIS'
    if name=='FIRST NATIONAL CAPITAL MARKETS':
        name = 'FIRST NATIONAL BANK OF NEBRASKA'
    if name=='FIRST OF AMER BANK SOUTHEAST':
        name = 'FIRST OF AMERICA BANK'
    if name=='FIRST OF AMERICA BANK CENTRAL':
        name = 'FIRST OF AMERICA BANK'
    if name=='FIRST OF AMERICA BANK INDIANA':
        name = 'FIRST OF AMERICA BANK'
    if name=='FIRST OF AMERICA BANK LANSING':
        name = 'FIRST OF AMERICA BANK'
    if name=='FIRST OF AMERICA BANK MARQUETTE':
        name = 'FIRST OF AMERICA BANK'
    if name=='FIRST OF AMERICA BANK MI':
        name = 'FIRST OF AMERICA BANK'
    if name=='FIRST OF AMERICA BANK MUSKEGO':
        name = 'FIRST OF AMERICA BANK'
    if name=='FIRST OF AMERICA BANK MUSKEGON':
        name = 'FIRST OF AMERICA BANK'
    if name=='FIRST OF AMERICA BANKKALAMAZO':
        name = 'FIRST OF AMERICA BANK'
    if name=='FIRST OF AMERICA DETROIT':
        name = 'FIRST OF AMERICA BANK'
    if name=='FIRST OF AMERICA FRANKEMUTH':
        name = 'FIRST OF AMERICA BANK'
    if name=='FIRST OF AMERICA SECURITIES':
        name = 'FIRST OF AMERICA BANK'
    if name=='FIRST OF AMERICAMONROE':
        name = 'FIRST OF AMERICA BANK'
    if name=='FIRST SECURITY BANK MONTANA':
        name = 'FIRST SECURITY'
    if name=='FIRST SECURITY BANK OF IDAHO':
        name = 'FIRST SECURITY'
    if name=='FIRST SECURITY BANK OF NM':
        name = 'FIRST SECURITY'
    if name=='FIRST SECURITY BANK OF UTAH':
        name = 'FIRST SECURITY'
    if name=='FIRST SECURITY BANK':
        name = 'FIRST SECURITY'
    if name=='FIRST SECURITY BANK':
        name = 'FIRST SECURITY'
    if name=='FIRST SECURITY CAPITAL MARKETS':
        name = 'FIRST SECURITY'
    if name=='FIRST SECURITY INVESTMENTS':
        name = 'FIRST SECURITY'
    if name=='FIRST SECURITY LEASING':
        name = 'FIRST SECURITY'
    if name=='FIRST SECURITY NATIONAL BANK & TR':
        name = 'FIRST SECURITY'
    if name=='FIRST SECURITY TR CO OF NEVADA':
        name = 'FIRST SECURITY'
    if name=='FIRST SECURITY VAN KASPER':
        name = 'FIRST SECURITY'
    if name=='FIRST NATIONAL BANK OF MEMPHIS':
        name = 'FIRST HORIZON BANK'
    if name=='FIRST TENNESSEE BANK':
        name = 'FIRST HORIZON BANK'
    if name=='FIRST UNION BANK OF SOUTH CAROLINA':
        name = 'FIRST UNION NATIONAL BANK'
    if name=='FIRST UNION BANK OF AUGUSTA':
        name = 'FIRST UNION NATIONAL BANK'
    if name=='FIRST UNION BANK OF CONNECTICUT':
        name = 'FIRST UNION NATIONAL BANK'
    if name=='FIRST UNION BROKERAGE SERVICES':
        name = 'FIRST UNION NATIONAL BANK'
    if name=='FIRST UNION CAPITAL MARKETS':
        name = 'FIRST UNION NATIONAL BANK'
    if name=='FIRST UNION NATIONAL BANK (MD)':
        name = 'FIRST UNION NATIONAL BANK'
    if name=='FIRST UNION NATIONAL BANK CT':
        name = 'FIRST UNION NATIONAL BANK'
    if name=='FIRST UNION NATIONAL BANK NY':
        name = 'FIRST UNION NATIONAL BANK'
    if name=='FIRST UNION NATIONAL BANK OF FLORIDA':
        name = 'FIRST UNION NATIONAL BANK'
    if name=='FIRST UNION NATIONAL BANK OF GEORGIA':
        name = 'FIRST UNION NATIONAL BANK'
    if name=='FIRST UNION NATIONAL BANK OF NC':
        name = 'FIRST UNION NATIONAL BANK'
    if name=='FIRST UNION NATIONAL BANK OF TN':
        name = 'FIRST UNION NATIONAL BANK'
    if name=='FIRST UNION NATIONAL BANK OF VA':
        name = 'FIRST UNION NATIONAL BANK'
    if name=='FIRST UNION NB HOUSTON':
        name = 'FIRST UNION NATIONAL BANK'
    if name=='FIRSTAR BANK OF DES MOINSES':
        name = 'FIRSTAR BANK'
    if name=='FIRSTAR CENTENNIAL BANK (MN)':
        name = 'FIRSTAR BANK'
    if name=='FIRSTAR INVESTMENT BANK':
        name = 'FIRSTAR BANK'
    if name=='FIRSTAR NATIONAL BANK':
        name = 'FIRSTAR BANK'
    if name=='FIRSTAR REALTY':
        name = 'FIRSTAR BANK'
    if name=='FIRSTAR STILLWATER BANK':
        name = 'FIRSTAR BANK'
    if name=='FIRSTAR TRUST CO (MN)':
        name = 'FIRSTAR BANK'
    if name=='FIRSTAR TRUST CO OF MILWAUKEE':
        name = 'FIRSTAR BANK'
    if name=='FLEET BANK OF MAINE':
        name = 'FLEET BANK'
    if name=='FLEET BANK OF MASSACHUSETTS':
        name = 'FLEET BANK'
    if name=='FLEET BANK OF NEW YORK':
        name = 'FLEET BANK'
    if name=='FLEET BANK OF NJ':
        name = 'FLEET BANK'
    if name=='FLEET NATIONAL BANK OF BOSTON':
        name = 'FLEET BANK'
    if name=='FLEET NATIONAL BANK OF CONNECTICUT':
        name = 'FLEET BANK'
    if name=='FLEET NATIONAL BANK PROVIDENCE':
        name = 'FLEET BANK'
    if name=='FLEET SECURITIES':
        name = 'FLEET BANK'
    if name=='FLEET SECURITIES':
        name = 'FLEET BANK'
    if name=='FLEET TRUST':
        name = 'FLEET BANK'
    if name=='FLEETBOSTON FINANCIAL':
        name = 'FLEET BANK'
    if name=='FOSTER & MARSHALLAMERICAN EXP':
        name = 'FOSTER & MARSHALL'
    if name=='GOLDMAN SACHS INTL':
        name = 'GOLDMAN SACHS'
    if name=='GREAT LAKES FINANCIAL RESOURCE':
        name = 'GREAT LAKES BANK'
    if name=='HANCOCK BANK OF LOUISIANA':
        name = 'HANCOCK BANK'
    if name=='HANCOCK WHITNEY BANK':
        name = 'HANCOCK BANK'
    if name=='PRAGER SEALY':
        name = 'MBS CAPITAL MARKET'
    if name=='BB&T CAPITAL MARKETS':
        name = 'BB&T'
    if name=='HOWARDWEILLABOUISSEFRIEDRIC':
        name = 'HOWARD WEIL LABOUISSE FRIEDRIC'
    if name=='IBERIA BANK LAFAYETTE LA':
        name = 'IBERIA BANK'
    if name=='IBERIA SAVINGS BANK':
        name = 'IBERIA BANK'
    if name=='IOWA DES MOINES NATIONAL BANK':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='J P MORGAN CHASE BANK':
        name = 'JP MORGAN'
    if name=='J P MORGAN SECURITIES':
        name = 'JP MORGAN'
    if name=='J P MORGAN TRUST':
        name = 'JP MORGAN'
    if name=='JEFFERIES & CO':
        name = 'JEFFERIES'
    if name=='JP MORGAN AG':
        name = 'JP MORGAN'
    if name=='JP MORGAN CHASE BANK':
        name = 'JP MORGAN'
    if name=='JP MORGAN SECURITIES':
        name = 'JP MORGAN'
    if name=='JPMORGAN':
        name = 'JP MORGAN'
    if name=='EVEREN SECURITIES':
        name = 'KEMPER SECURITIES'
    if name=='KEY BANC CAPITAL MARKETS':
        name = 'KEY BANK'
    if name=='KEY BANK ILLINOIS':
        name = 'KEY BANK'
    if name=='KEY BANK INDIANA':
        name = 'KEY BANK'
    if name=='KEY BANK NA ALBANY':
        name = 'KEY BANK'
    if name=='KEY BANK OF ALASKA':
        name = 'KEY BANK'
    if name=='KEY BANK OF CENTRAL NEW YORK':
        name = 'KEY BANK'
    if name=='KEY BANK OF COLORADO':
        name = 'KEY BANK'
    if name=='KEY BANK OF IDAHO':
        name = 'KEY BANK'
    if name=='KEY BANK OF LI SAYVILLE':
        name = 'KEY BANK'
    if name=='KEY BANK OF MAINE':
        name = 'KEY BANK'
    if name=='KEY BANK OF NEW YORK':
        name = 'KEY BANK'
    if name=='KEY BANK OF EASTERN NEW YORK':
        name = 'KEY BANK'
    if name=='KEY BANK OF OREGON':
        name = 'KEY BANK'
    if name=='KEY BANK OF PLATTSBURGH':
        name = 'KEY BANK'
    if name=='KEY BANK OF ROCHESTER':
        name = 'KEY BANK'
    if name=='KEY BANK OF SOUTHEASTERN NY':
        name = 'KEY BANK'
    if name=='KEY BANK OF SOUTHEASTERN NY':
        name = 'KEY BANK'
    if name=='KEY BANK OF SYRACUSE':
        name = 'KEY BANK'
    if name=='KEY BANK OF UTAH':
        name = 'KEY BANK'
    if name=='KEY BANK OF WASHINGTON':
        name = 'KEY BANK'
    if name=='KEY BANK OF WESTERN NEW YORK':
        name = 'KEY BANK'
    if name=='KEY BANK OF WYOMING':
        name = 'KEY BANK'
    if name=='KEY CAPITAL MARKETS':
        name = 'KEY BANK'
    if name=='KEY GOVERNMENT FINANCE':
        name = 'KEY BANK'
    if name=='KEY MUNICIPAL FINANCE':
        name = 'KEY BANK'
    if name=='KEY TRUST':
        name = 'KEY BANK'
    if name=='KEYBANC CAPITAL MARKETS':
        name = 'KEY BANK'
    if name=='KEYBANK NATIONAL ASSOCIATED':
        name = 'KEY BANK'
    if name=='LASALLE BANK':
        name = 'LASALLE NATIONAL BANK'
    if name=='LASALLE CAPITAL MARKETS':
        name = 'LASALLE NATIONAL BANK'
    if name=='LASALLE FINANCIAL SVC':
        name = 'LASALLE NATIONAL BANK'
    if name=='LASALLE NATIONAL BANK':
        name = 'ABN AMRO'
    if name=='LASALLE NATIONAL BANK':
        name = 'LASALLE NATIONAL BANK'
    if name=='LEGG MASON MASTEN':
        name = 'LEGG MASON'
    if name=='LEGG MASON WARREN YORK':
        name = 'LEGG MASON'
    if name=='LEGG MASON WOOD WALKER':
        name = 'LEGG MASON'
    if name=='M & I BANK MILWAUKEE':
        name = 'M & I BANK'
    if name=='M & I BANK OF ANTIGO':
        name = 'M & I BANK'
    if name=='M & I BANK OF DODGEVILLE':
        name = 'M & I BANK'
    if name=='M & I BANK OF EAGLE RIVER':
        name = 'M & I BANK'
    if name=='M & I BANK OF MAYVILLE':
        name = 'M & I BANK'
    if name=='M & I BANK OF MENOMONEE FALLS':
        name = 'M & I BANK'
    if name=='M & I BANK OF SO WISCONSIN':
        name = 'M & I BANK'
    if name=='M & I BANK OF WATERTOWN':
        name = 'M & I BANK'
    if name=='M & I BANK SOUTHWEST':
        name = 'M & I BANK'
    if name=='M & I BROKERAGE SERVICES':
        name = 'M & I BANK'
    if name=='M & I CENTRAL STATE BANK':
        name = 'M & I BANK'
    if name=='M & I CITIZENS BANK':
        name = 'M & I BANK'
    if name=='M & I FIRST NATIONAL BANK':
        name = 'M & I BANK'
    if name=='M & I HOME STATE BANK':
        name = 'M & I BANK'
    if name=='M & I MADISON BANK':
        name = 'M & I BANK'
    if name=='M & I MARSHALL & ILSLEY BANK':
        name = 'M & I BANK'
    if name=='M & I MERCHANTS BANK':
        name = 'M & I BANK'
    if name=='M & I NATIONAL BANK OF ASHLAND':
        name = 'M & I BANK'
    if name=='M & T BANK':
        name = 'M&T SECURITIES'
    if name=='M & T SECURITIES':
        name = 'M&T SECURITIES'
    if name=='MCDONALD INVESTMENTS':
        name = 'MCDONALD'
    if name=='MCDONALD FINANCIAL SECURITIES':
        name = 'MCDONALD'
    if name=='MERCANTILE BANK NA MISSOURI':
        name = 'MERCANTILE BANK OF ST LOUIS'
    if name=='MERCANTILE BANK OF ARKANSAS':
        name = 'MERCANTILE BANK OF ST LOUIS'
    if name=='MERCANTILE BANK OF EASTERN IOWA':
        name = 'MERCANTILE BANK OF ST LOUIS'
    if name=='MERCANTILE BANK OF ILLINOIS':
        name = 'MERCANTILE BANK OF ST LOUIS'
    if name=='MERCANTILE BANK OF KANSAS CITY':
        name = 'MERCANTILE BANK OF ST LOUIS'
    if name=='MERCANTILE BANK OF SPRINGFIELD':
        name = 'MERCANTILE BANK OF ST LOUIS'
    if name=='MERCANTILE BANK OF WESTERN IOWA':
        name = 'MERCANTILE BANK OF ST LOUIS'
    if name=='MERCANTILE TRUST & SAVINGSBANK':
        name = 'MERCANTILE BANK OF ST LOUIS'
    if name=='MERCANTILE TRUST':
        name = 'MERCANTILE BANK OF ST LOUIS'
    if name=='MERCHANTS NATIONAL BANK & TR':
        name = 'MERCHANTS NATIONAL BANK'
    if name=='MERCHANTS NATIONAL BANK CEDAR RAPIDS':
        name = 'MERCHANTS NATIONAL BANK'
    if name=='MERCHANTS NATIONAL BANK MANCHESTER':
        name = 'MERCHANTS NATIONAL BANK'
    if name=='MERCHANTS NATIONAL BANK MOBILE':
        name = 'MERCHANTS NATIONAL BANK'
    if name=='MERCHANTS NATIONAL BANK OF AURORA':
        name = 'MERCHANTS NATIONAL BANK'
    if name=='MERCHANTS NATIONAL BANK OF MUNCIE':
        name = 'MERCHANTS NATIONAL BANK'
    if name=='MERCHANTS NATIONAL BANK OF WINONA':
        name = 'MERCHANTS NATIONAL BANK'
    if name=='MERCHANTS NATIONAL BANK TERRE HAUT':
        name = 'MERCHANTS NATIONAL BANK'
    if name=='MERRILL LYNCH WHITE WELD CAP':
        name = 'MERRILL LYNCH'
    if name=='MICHIGAN NATIONAL BANK FARMINGTON':
        name = 'MICHIGAN NATIONAL BANK'
    if name=='MICHIGAN NATIONAL BANK LANSING':
        name = 'MICHIGAN NATIONAL BANK'
    if name=='MILLER SECURITIES':
        name = 'MILLER JOHNSON & KUEHN'
    if name=='MORGAN STANLEY DEAN WITTER':
        name = 'MORGAN STANLEY'
    if name=='MORGAN STANLEY INTERNATIONAL':
        name = 'MORGAN STANLEY'
    if name=='CIBC CAPITAL MARKETS':
        name = 'CIBC'
    if name=='NATCITY INVESTMENTS':
        name = 'NATIONAL CITY BANK'
    if name=='FIRST FIDELITY SECURITIES GRP':
        name = 'FIRST FIDELITY BANK OF NEW JERSEY'
    if name=='NATIONAL BANK OF COMMERCE PAWHUSKA':
        name = 'BLUE SKY BANK'
    if name=='HARTFORD NATIONAL BANK & TR':
        name = 'HARTFORD NATIONAL BANK'
    if name=='NATIONAL CITY BANK MIIL':
        name = 'NATIONAL CITY BANK'
    if name=='NATIONAL CITY BANK MINNEAPOLIS':
        name = 'NATIONAL CITY BANK'
    if name=='BT SECURITIES':
        name = 'BANKERS TRUST'
    if name=='NATIONAL CITY BANK OF MICHIGAN':
        name = 'NATIONAL CITY BANK'
    if name=='NATIONAL CITY CAPITAL MARKETS':
        name = 'NATIONAL CITY BANK'
    if name=='NATIONAL CITY SECURITIES':
        name = 'NATIONAL CITY BANK'
    if name=='NATIONSBANK INVESTMENT BANKG':
        name = 'NATIONSBANK'
    if name=='NATIONSBANK NA DC':
        name = 'NATIONSBANK'
    if name=='NATIONSBANK NATIONAL ASSOC':
        name = 'NATIONSBANK'
    if name=='NATIONSBANK OF FLORIDA':
        name = 'NATIONSBANK'
    if name=='NATIONSBANK OF GEORGIA':
        name = 'NATIONSBANK'
    if name=='NATIONSBANK OF MARYLAND':
        name = 'NATIONSBANK'
    if name=='NATIONSBANK OF NORTH CAROLINA':
        name = 'NATIONSBANK'
    if name=='NATIONSBANK OF SOUTH CAROLINA':
        name = 'NATIONSBANK'
    if name=='NATIONSBANK OF TENNESSEE':
        name = 'NATIONSBANK'
    if name=='NATIONSBANK OF TEXAS':
        name = 'NATIONSBANK'
    if name=='NATIONSBANK OF VIRGINIA':
        name = 'NATIONSBANK'
    if name=='NATIONSBANK TRUST':
        name = 'NATIONSBANK'
    if name=='NBD BANK':
        name = 'NATIONAL BANK OF DETROIT'
    if name=='NBD DETROIT':
        name = 'NATIONAL BANK OF DETROIT'
    if name=='NEW ENGLAND MERCHANTS NATIONAL BANK':
        name = 'MERCHANTS NATIONAL BANK'
    if name=='NORWEST BANK IOWA':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='NORWEST BANK MINNESOTA':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='NORWEST BANK OF COLORADO':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='NORWEST BANK OF DES MOINES':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='NORWEST BANK OF INDIANA':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='NORWEST BANK OF MONTANA':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='NORWEST BANK OF NEBRASKA':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='NORWEST BANK OF NEVADA':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='NORWEST BANK OF SOUTH DAKOTA':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='NORWEST BANK OF WISCONSIN':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='NORWEST BANK TEXAS':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='NORWEST SECURITIES':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='NORWEST BANK INDIANA':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='NORWEST BANK NEVADA':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='NORWEST BANK WISCONSIN':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='NORWEST BANK COLORADO':
        name = 'NORWEST INVESTMENT SERVICES'
    if name=='OLD NATIONAL BANK IN EVANSVILLE':
        name = 'OLD NATIONAL BANK'
    if name=='OLD NATIONAL BANK OF WASHINGTON':
        name = 'OLD NATIONAL BANK'
    if name=='OLD NATIONAL TRUST':
        name = 'OLD NATIONAL BANK'
    if name=='ORIX CAPITAL PARTNERS':
        name = 'ORIX BANK'
    if name=='PAINEWEBBER INC OF PUERTO RICO':
        name = 'PAINE WEBBER'
    if name=='PAINE WEBBER JACKSON CURTIS':
        name = 'PAINE WEBBER'
    if name=='PEOPLES UNITED MUNI FINANCE':
        name = 'PEOPLES UNITED BANK'
    if name=='PNC BANK INDIANA':
        name = 'PNC BANK'
    if name=='PNC BANK KENTUCKY':
        name = 'PNC BANK'
    if name=='PNC BANK OF NEW JERSEY':
        name = 'PNC BANK'
    if name=='PNC BANK OHIO':
        name = 'PNC BANK'
    if name=='PNC BROKERAGE':
        name = 'PNC BANK'
    if name=='PNC Bank NA':
        name = 'PNC FINANCIAL SERVICES GROUP'
    if name=='PNC CAPITAL MARKETS':
        name = 'PNC FINANCIAL SERVICES GROUP'
    if name=='PNC CORPORATE FINANCE':
        name = 'PNC BANK'
    if name=='PNC EQUIPMENT FINANCE':
        name = 'PNC BANK'
    if name=='PNC FINANCIAL SERVICES GROUP':
        name = 'PNC BANK'
    if name=='PNC INVESTMENT':
        name = 'PNC BANK'
    if name=='PNC MERCHANTS BANK':
        name = 'PNC BANK'
    if name=='PRUDENTIAL BACHE SEC':
        name = 'PRUDENTIAL SECURITIES'
    if name=='RAYMOND JAMES CAPITAL':
        name = 'RAYMOND JAMES'
    if name=='RAYMOND JAMES FINANCIAL':
        name = 'RAYMOND JAMES'
    if name=='RAYMOND JAMES MORGAN KEEGAN':
        name = 'RAYMOND JAMES'
    if name=='REGIONS BANK OF ALABAMA':
        name = 'REGIONS BANK'
    if name=='REGIONS BANK OF LOUISIANA':
        name = 'REGIONS BANK'
    if name=='REGIONS CAPITAL ADVANTAGE':
        name = 'REGIONS BANK'
    if name=='REGIONS CAPITAL ADVANTAGE':
        name = 'REGIONS BANK'
    if name=='REGIONS COMMERCIAL EQUIP':
        name = 'REGIONS BANK'
    if name=='REGIONS EQUIPMENT FINANCE':
        name = 'REGIONS BANK'
    if name=='REGIONS FINANCIAL':
        name = 'REGIONS BANK'
    if name=='REGIONS INVESTMENT':
        name = 'REGIONS BANK'
    if name=='FIRST ALABAMA BANK OF BIRMINGHAM':
        name = 'REGIONS BANK'
    if name=='FIRST ALABAMA SECURITIES':
        name = 'REGIONS BANK'
    if name=='FIRST ALABAMA BANK':
        name = 'REGIONS BANK'
    if name=='FIRST ALABAMA BANK OF TUSCALOOSA':
        name = 'REGIONS BANK'
    if name=='FIRST ALABAMA INVESTMENTS':
        name = 'REGIONS BANK'
    if name=='SECURITY STATE BANK IOWA':
        name = 'SECURITY STATE BANK'
    if name=='SECURITY STATE BANK OF CLAREMONT':
        name = 'SECURITY STATE BANK'
    if name=='SECURITY STATE BANK OF LEWISTON':
        name = 'SECURITY STATE BANK'
    if name=='SECURITY STATE BANK OF NEW SALEM':
        name = 'SECURITY STATE BANK'
    if name=='SECURITY STATE BANK SHELDON':
        name = 'SECURITY STATE BANK'
    if name=='SHEARSON LEHMANAMERICAN EXPRE':
        name = 'LEHMAN BROTHERS'
    if name=='LEHMAN BROTHERS KUHN LOEB':
        name = 'LEHMAN BROTHERS'
    if name=='SHEARSON LEHMAN BROTHERS':
        name = 'LEHMAN BROTHERS'
    if name=='SHEARSON LEHMAN HUTTON':
        name = 'LEHMAN BROTHERS'
    if name=='SOCIETY BANK COLUMBUS OHIO':
        name = 'SOCIETY NATIONAL BANK'
    if name=='SOCIETY BANK DAYTON':
        name = 'SOCIETY NATIONAL BANK'
    if name=='SOCIETY BANK MICHIGAN':
        name = 'SOCIETY NATIONAL BANK'
    if name=='SOCIETY BANK MICHIGAN':
        name = 'SOCIETY NATIONAL BANK'
    if name=='SOCIETY BANK OF EASTERN OHIO':
        name = 'SOCIETY NATIONAL BANK'
    if name=='SOCIETY BANK TOLEDO':
        name = 'SOCIETY NATIONAL BANK'
    if name=='SOCIETY NATIONAL BANK CLEVELAND':
        name = 'SOCIETY NATIONAL BANK'
    if name=='SOCIETY NATIONAL BANK OF OHIO':
        name = 'SOCIETY NATIONAL BANK'
    if name=='SOCIETY NATIONAL BANK INDIANA':
        name = 'SOCIETY NATIONAL BANK'
    if name=='STANDARD FEDERAL BANK':
        name = 'ABN AMRO'
    if name=='STATE STREET CAPITAL MARKETS':
        name = 'STATE STREET BANK'
    if name=='STATE STREET GLOBAL':
        name = 'STATE STREET BANK'
    if name=='STATE STREET PUBLIC LENDING':
        name = 'STATE STREET BANK'
    if name=='STATE STREET SECURITIES':
        name = 'STATE STREET BANK'
    if name=='STI INSTITUTIONAL & GOVERNMENT':
        name = 'SUNTRUST BANK'
    if name=='SUNTRUST BANK (US BANK)':
        name = 'US BANK'
    if name=='SUNTRUST BANK (US BANK)':
        name = 'US BANK'
    if name=='SUNTRUST BANK (US BANK)':
        name = 'US BANK'
    if name=='US NATIONAL BANK OF OREGON':
        name = 'US BANK'
    if name=='SUNTRUST CAPITAL MARKETS':
        name = 'SUNTRUST BANK'
    if name=='SUNTRUST EQUIPMENT FINANCE':
        name = 'SUNTRUST BANK'
    if name=='SUNTRUST EQUITABLE SECURITIES':
        name = 'SUNTRUST BANK'
    if name=='SUNTRUST PUBLIC FINANCE':
        name = 'SUNTRUST BANK'
    if name=='SUNTRUST ROBINSON HUMPHREY':
        name = 'SUNTRUST BANK'
    if name=='SUNTRUST SECURITIES':
        name = 'SUNTRUST BANK'
    if name=='TD BANKNORTH':
        name = 'TD BANK'
    if name=='TORONTO DOMINION BANK':
        name = 'TD BANK'
    if name=='TD SECURITIES (USA)':
        name = 'TD BANK'
    if name=='THE INDIANA NATIONAL BANK':
        name = 'INB NATIONAL BANK'
    if name=='THE ROBINSON HUMPHREY CO (SBH)':
        name = 'THE ROBINSON HUMPHREY'
    if name=='THORN ALVIS WELCH':
        name = 'THORN WELCH'
    if name=='TRUIST BANK':
        name = 'TRUIST FINANCIAL'
    if name=='TRUIST SECURITIES':
        name = 'TRUIST FINANCIAL'
    if name=='TRUST CO OF GEORGIA':
        name = 'TRUST CO BANK'
    if name=='UBS SECURITIES':
        name = 'UBS FINANCIAL SERVICES'
    if name=='UMB BANK COLORADO':
        name = 'UMB BANK'
    if name=='UMB BANK INDIANA':
        name = 'UMB BANK'
    if name=='UMB BANK NA KANSAS CITY':
        name = 'UMB BANK'
    if name=='UNIBANK AS ':
        name = 'UNIBANK FOR SAVINGS'
    if name=='UNIBANK FISCAL ADVISORY SERVICES':
        name = 'UNIBANK FOR SAVINGS'
    if name=='UNITED MISSOURI BANK ST LOUIS':
        name = 'UMB BANK'
    if name=='UMB OKLAHOMA BANK':
        name = 'UMB BANK'
    if name=='US BANK INVESTMENTS':
        name = 'US BANK'
    if name=='US BANK MUNI LENDING & FIN':
        name = 'US BANK'
    if name=='US BANK MUNI SECURITIES GROUP':
        name = 'US BANK'
    if name=='US BANK OF NEVADA':
        name = 'US BANK'
    if name=='US BANK OF OREGON':
        name = 'US BANK'
    if name=='US BANK OF WASHINGTON':
        name = 'US BANK'
    if name=='US BANK TRUST NATIONAL ASSOC':
        name = 'US BANK'
    if name=='WACHOVIA BANK OF GEORGIA':
        name = 'WACHOVIA BANK'
    if name=='WACHOVIA BANK OF NORTH CAROLINA':
        name = 'WACHOVIA BANK'
    if name=='WACHOVIA BANK OF SOUTH CAROLINA':
        name = 'WACHOVIA BANK'
    if name=='WACHOVIA CAPITAL MARKETS':
        name = 'WACHOVIA BANK'
    if name=='WACHOVIA SECURITIES':
        name = 'WACHOVIA BANK'
    if name=='SEIDLER FITZGERALD PUB FINANCE':
        name = 'THE SEIDLER COMPANIES'
    if name=='WELLS FARGO ADVISORS':
        name = 'WELLS FARGO'
    if name=='WELLS FARGO BANK IOWA':
        name = 'WELLS FARGO'
    if name=='WELLS FARGO BROKERAGE SEC':
        name = 'WELLS FARGO'
    if name=='WELLS FARGO INSTITUTIONAL SEC':
        name = 'WELLS FARGO'
    if name=='WELLS FARGO INVESTMENT SERVICE':
        name = 'WELLS FARGO'
    if name=='WELLS FARGO MUNI CAP STRAT':
        name = 'WELLS FARGO'
    if name=='WILEY BROS AINTREE CAPITAL':
        name = 'WILEY BROTHERS'
    if name=='ZIONS BANK COLORADO':
        name = 'ZIONS BANK'
    if name=='ZIONS BANK PUBLIC FINANCE':
        name = 'ZIONS BANK'
    if name=='ZIONS FIRST NATIONAL BANK':
        name = 'ZIONS BANK'
    if name=='ZIONS INVESTMENT SECURITIES':
        name = 'ZIONS BANK'
    if name=='ZMFU II':
        name = 'ZIONS BANK'
    if name=='NATWEST BANK FIN MKTS GROUP':
        name = 'NATWEST BANK'
    if name=='NATWEST ADVISORY GROUP':
        name = 'NATWEST BANK'
    if name=='MIDLANTIC NATIONAL BANK':
        name = 'MIDLANTIC BANK'
    if name=='MIDATLANTIC NATIONAL BANK':
        name = 'MIDLANTIC BANK'
    if name=='MIDATLANTIC NATIONAL BANK':
        name = 'MIDLANTIC BANK'
    if name=='COMMERCE CAPITAL':
        name = 'COMMERCE CAPITAL MARKETS'
    if name=='LIBERTY NATIONAL BANK OF OK':
        name = 'LIBERTY NATIONAL BANK'
    if name=='LIBERTY NATIONAL BANK OF OK':
        name = 'LIBERTY NATIONAL BANK'
    if name=='LIBERTY NTNL BANK & TR BUFFALO':
        name = 'LIBERTY NATIONAL BANK'
    if name=='LIBERTY NTNL BANK OK':
        name = 'LIBERTY NATIONAL BANK'
    if name=='LIBERTY NTNL BANK IOWA':
        name = 'LIBERTY NATIONAL BANK'
    if name=='LAWSON BANK':
        name = 'LAWSON FINANCIAL'
    if name=='HSBC BANK USA':
        name = 'HSBC'
    if name=='HSBC MARKETS LIMITED':
        name = 'HSBC'
    if name=='HSBC BROKERAGE':
        name = 'HSBC'
    if name=='HSBC (UK)':
        name = 'HSBC'
    if name=='MARINE MIDLAND CAPITAL MKTS':
        name = 'MARINE MIDLAND BANK'
    if name=='MARINE MIDLAND SECURITIES':
        name = 'MARINE MIDLAND BANK'
    if name=='NORSTAR BANK OF LONG ISLAND':
        name = 'NORSTAR BANK'
    if name=='NORSTAR BANK OF ALBANY':
        name = 'NORSTAR BANK'
    if name=='NORSTAR BANK OF THE HUDSON VLLY':
        name = 'NORSTAR BANK'
    if name=='NORSTAR BANK OF ROCHESTER':
        name = 'NORSTAR BANK'
    if name=='NORSTAR BANK OF LONG ISLAND':
        name = 'NORSTAR BANK'
    if name=='NATIONAL WESTMINSTER BANK USA':
        name = 'NATWEST BANK'
    if name=='NATIONAL WESTMINSTER BANK OF NJ':
        name = 'NATWEST BANK'
    if name=='NATIONAL WESTMINSTER INVEST SERVICES':
        name = 'NATWEST BANK'
    if name=='MANUFACTURERS HANOVER SECCORP':
        name = 'MANUFACTURERS HANOVER TRUST'
    if name=='MANUFACTURERS HANOVER TR CO CA':
        name = 'MANUFACTURERS HANOVER TRUST'
    if name=='MANUFACTURERS HANOVER LIMITED':
        name = 'MANUFACTURERS HANOVER TRUST'
    if name=='MANUFACTURERS & TRADERS TRUST':
        name = 'M&T SECURITIES'
    if name=='NATIONAL BANK OF NORTH AMERICA':
        name = 'NATWEST BANK'
    if name=='BNY CAPITAL MARKETS':
        name = 'BANK OF NEW YORK MELLON'
    if name=='COMMERCE BANK NANEW JERSEY':
        name = 'COMMERCE BANK NEW JERSEY'
    if name=='COMMERCE CAPITAL MARKETS':
        name = 'COMMERCE BANK NEW JERSEY'
    if name=='FIRST NIAGARA FINL GROUP':
        name = 'FIRST NIAGARA BANK'
    if name=='FIRST NIAGARA LEASING':
        name = 'FIRST NIAGARA BANK'
    if name=='NCNB TEXAS NATIONAL BANK':
        name = 'NCNB NATIONAL BANK OF NORTH CAROLINA'
    if name=='NCNB NATIONAL BANK OF FLORIDA':
        name = 'NCNB NATIONAL BANK OF NORTH CAROLINA'
    if name=='NCNB CAPITAL MARKETS':
        name = 'NCNB NATIONAL BANK OF NORTH CAROLINA'
    if name=='NCNB INVESTMENT BANK':
        name = 'NCNB NATIONAL BANK OF NORTH CAROLINA'
    if name=='C & SSOVRAN':
        name = 'CITIZENS & SOUTHERN NATIONAL BANK'
    if name=='C & S NATIONAL BANK':
        name = 'CITIZENS & SOUTHERN NATIONAL BANK'
    if name=='FIRST CITIZENS MUNICIPAL':
        name = 'FIRST CITIZENS BANK'
    if name=='FIRST CITIZENS BANK&TR CORALEIGH':
        name = 'FIRST CITIZENS BANK'
    if name=='FIRST CITIZENS BANK OF SMITHFIELD':
        name = 'FIRST CITIZENS BANK'
    if name=='FIRST CITIZENS BANK COLUMBIA':
        name = 'FIRST CITIZENS BANK'
    if name=='SUNTRUST ROBINSON HUMPHREY':
        name = 'THE ROBINSON HUMPHREY'
    if name=='NATIONSBANC MONTGOMERY SEC':
        name = 'NATIONSBANK'
    if name=='NATIONSBANC CAPITAL MARKETS':
        name = 'NATIONSBANK'
    if name=='FBS CAPITAL MARKETS':
        name = 'FBS FINANCIAL'
    if name=='FBS INVESTMENT SERVICES':
        name = 'FBS FINANCIAL'
    if name=='THE HUNTINGTON':
        name = 'HUNTINGTON NATIONAL BANK '
    if name=='HUNTINGTON CAPITAL MARKETS':
        name = 'HUNTINGTON NATIONAL BANK '
    if name=='HUNTINGTON CAPITAL':
        name = 'HUNTINGTON NATIONAL BANK '
    if name=='HUNTINGTON TRUST':
        name = 'HUNTINGTON NATIONAL BANK '
    if name=='HUNTINGTON BANK OF MICHIGAN':
        name = 'HUNTINGTON NATIONAL BANK '
    if name=='HUNTINGTON INVESTMENT':
        name = 'HUNTINGTON NATIONAL BANK '
    if name=='HUNTINGTON PUBLIC CAPITAL':
        name = 'HUNTINGTON NATIONAL BANK '
    if name=='HUNTINGTON SECURITIES':
        name = 'HUNTINGTON NATIONAL BANK '
    if name=='CAPMARK SECURITIES':
        name = 'NEWMAN & ASSOCIATES '
    if name=='OCONNOR & CO SECURITIES':
        name = 'OCONNOR'
    if name=='OREC SECURITIES':
        name = 'ORIX BANK'
    if name=='HUNT MORTGAGE PARTNERS':
        name = 'ORIX BANK'
    if name=='LUMENT SECURITIES':
        name = 'ORIX BANK'
    if name=='SIEBERT BRANDFORD SHANK':
        name = 'SIEBERT CISNEROS SHANK'
    if name=='SHAWMUT BANK CONNECTICUT':
        name = 'SHAWMUT BANK'
    if name=='SHAWMUT BANK OF BOSTON':
        name = 'SHAWMUT BANK'
    if name=='CONN NATIONAL BANKSHAWMUT BANK':
        name = 'SHAWMUT BANK'
    if name=='SHAWMUT NATIONAL':
        name = 'SHAWMUT BANK'
    if name=='NATIONAL SHAWMUT BANK OF BOSTON':
        name = 'SHAWMUT BANK'
    if name=='LLAMA INVESTMENTS':
        name = 'LLAMA'
    if name=='FIRST NATIONAL BANK OF OHIO':
        name = 'FIRST MERIT BANK'
    if name=='LIBERTY BANK&TR OF OKLAHOMA CITY':
        name = 'LIBERTY NATIONAL BANK'
    if name=='LIBERTY BANK & TR CO OF TULSA':
        name = 'LIBERTY NATIONAL BANK'
    if name=='1ST NATIONAL BANK & TR CO OK CITY':
        name = '1ST NATIONAL BANK'
    if name=='1ST NATIONAL BANK & TR CO TULSA':
        name = '1ST NATIONAL BANK'
    if name=='1ST NATIONAL BANK COTROY':
        name = '1ST NATIONAL BANK'
    if name=='1ST NATIONAL BANK OF CAINSVILLE':
        name = '1ST NATIONAL BANK'
    if name=='STRANDATKINSONWILLIAMS&YERL':
        name = 'UMPQUA BANK'
    if name=='FIRST EASTERN BANK':
        name = 'FIRST EASTERN'
    if name=='FIRST EASTERN CAPITAL MARKETS':
        name = 'FIRST EASTERN'
    if name=='PITTSBURGH NATIONAL BANK':
        name = 'PNC BANK'
    if name=='MERIDIAN CAPITAL MARKETS':
        name = 'MERIDIAN BANK'
    if name=='PHILADELPHIA NATIONAL BANK':
        name = 'CORESTATES BANK'
    if name=='CORESTATES CAPITAL MKTS GROUP':
        name = 'CORESTATES BANK'
    if name=='CORESTATES SECURITIES':
        name = 'CORESTATES BANK'
    if name=='W H NEWBOLDS SON':
        name = 'HOPPER SOLIDAY'
    if name=='MELLON FINANCIAL MARKETS':
        name = 'MELLON BANK'
    if name=='FIRST EASTERN BANK':
        name = 'FIRST EASTERN'
    if name=='FIRST EASTERN CAPITAL MARKETS':
        name = 'FIRST EASTERN'
    if name=='CORESTATES CAPITAL MKTS GROUP':
        name = 'CORESTATES BANK'
    if name=='CORESTATES SECURITIES':
        name = 'CORESTATES BANK'
    if name=='POTTER SHUPE & ASSOC':
        name = 'QUAESTOR MUNICIPAL GROUP'
    if name=='WEBSTER PUBLIC FINANCE CORPORA':
        name = 'WEBSTER BANK'
    if name=='MORGAN GUARANTY':
        name = 'JP MORGAN'
    if name=='MORGAN GUARANTY TRUST CO OF NY':
        name = 'JP MORGAN'
    if name=='MORGAN GUARANTY TRUST':
        name = 'JP MORGAN'
    if name=='BB&T CAPITAL PARTNERS':
        name = 'BB&T'
    if name=='BB & T LEASING':
        name = 'BB&T'
    if name=='BRANCH BANK & TRUST':
        name = 'BB&T'
    if name=='MASTERSON':
        name = 'MASTERSON MORELAND SAUER'
    if name=='PRINCIPALEPPLER GUERIN':
        name = 'PRINCIPAL FINANCIAL SEC'
    if name=='TEAM BANK OF FORT WORTH':
        name = 'TEAM BANK'
    if name=='TEXAS AMER BANKFORT WORTHNA':
        name = 'TEXAS AMER BANK'
    if name=='TEXAS AMER BANK DALLAS NORTH':
        name = 'TEXAS AMER BANK'
    if name=='FROST NATIONAL BANK':
        name = 'FROST BANK'
    if name=='TEXAS AMER BANKFORT WORTHNA':
        name = 'TEXAS AMER BANK'
    if name=='VAN KAMPEN FILKIN & MERRITT':
        name = 'VAN KAMPEN'
    if name=='VANKAMPEN WAUTERLEK & BROWN':
        name = 'VAN KAMPEN'
    if name=='PACIFIC SECURITIES BANK OF OR':
        name = 'PACIFIC SECURITIES'
    if name=='SECURITY PACIFIC BANK NEVADA':
        name = 'PACIFIC SECURITIES'
    if name=='SECURITY PACIFIC NATIONAL BANK':
        name = 'PACIFIC SECURITIES'
    if name=='SECURITY PACIFIC SEC':
        name = 'PACIFIC SECURITIES'
    if name=='PACIFIC NATIONAL BANK OF WASHINGTON':
        name = 'PACIFIC SECURITIES'
    if name=='SECURITY PACIFIC BANK OREGON':
        name = 'PACIFIC SECURITIES'
    if name=='SECURITY PACIFIC BANK WA':
        name = 'PACIFIC SECURITIES'
    if name=='MURIEL SIEBERT':
        name = 'SIEBERT CISNEROS SHANK'
    if name=='CROCKER BANK':
        name = 'CROCKER NATIONAL BANK'
    if name=='A G BECKER PARIBAS':
        name = 'AG BECKER'
    if name=='WEDBUSH MORGAN SECURITIES':
        name = 'WEDBUSH SECURITIES'
    if name=='WEDBUSH NOBLE COOKE':
        name = 'WEDBUSH SECURITIES'
    if name=='CIBC OPPENHEIMER':
        name = 'CIBC'
    if name=='CIBC WORLD MARKETS':
        name = 'CIBC'
    if name=='CIBC BANK USA':
        name = 'CIBC'
    if name=='CENTRAL FIDELITY NATIONAL BANK':
        name = 'CENTRAL FIDELITY BANK'
    if name=='BARCLAYS BANK':
        name = 'BARCLAYS'
    if name=='BARCLAYS CAPITAL GROUP':
        name = 'BARCLAYS'
    if name=='BARCLAYS CAPITAL':
        name = 'BARCLAYS'
    if name=='FIRST WISCONSIN NATIONAL BANK':
        name = 'FIRSTAR BANK'
    if name=='BANK SOUTH SECURITIES':
        name = 'BANK SOUTH'
    if name=='ENTERPRISE BANK SOUTH CAROLINA':
        name = 'BANK SOUTH'
    if name=='SOVEREIGN BANK CAPITAL MARKETS':
        name = 'SOVEREIGN SECURITIES'
    if name=='TGH SECURITIESSOVEREIGN BANK':
        name = 'SOVEREIGN SECURITIES'
    if name=='SOVEREIGN BANK NEW ENGLAND':
        name = 'SOVEREIGN SECURITIES'
    if name=='SANTANDER SECURITIES':
        name = 'SANTANDER BANK'
    if name=='RBC CAPITAL MARKETS':
        name = 'RBC BANK'
    if name=='RBC CENTURA BANK':
        name = 'RBC BANK'
    if name=='FRANKLIN BANK':
        name = 'UNITED JERSEY BANK'
    if name=='FULTON FINANCIAL ADVISORS':
        name = 'FULTON BANK'
    if name=='SUSQUEHANNA PATRIOT':
        name = 'SUSQUEHANNA BANK'
    if name=='SUSQUEHANNA TRUST & INV':
        name = 'SUSQUEHANNA BANK'
    if name=='SYNOVUS SECURITIES':
        name = 'SYNOVUS BANK'
    if name=='SYNOVUS FINANCIAL':
        name = 'SYNOVUS BANK'
    if name=='WINTRUST BANK':
        name = 'WINTRUST FINANCIAL'
    if name=='CHAPMAN SECURITIES':
        name = 'CHAPMAN'
    if name=='MB FINANCIAL BANK':
        name = 'MB FINANCIAL'
    if name=='SOVRAN INVESTMENT':
        name = 'SOVRAN BANK NA VIRGINIA'
    if name=='INTL FCSTONE':
        name = 'STONEX GROUP'
    if name=='PIPER JAFFRAY':
        name = 'PIPER SANDLER'
    if name=='INTL FCSTONE FINANCIAL':
        name = 'STONEX GROUP'
    if name=='CORBY CAPITAL MARKETS':
        name = 'CORBY NORTH BRIDGE SECURITIES'
    if name=='COMMERCE BANK NEW JERSEY MARKETS':
        name = 'COMMERCE BANK NEW JERSEY'
    if name=='BC ZIEGLER':
        name = 'ZIEGLER'
    if name=='ZIEGLER SECURITIES':
        name = 'ZIEGLER'
    if name=='BANCAMERICA SECURITIES':
        name = 'BANK OF AMERICA'
    if name=='LOVETT UNDERWOOD NEUHAUS& WEBB':
        name = 'KEMPER SECURITIES'
    if name=='SEATTLE FIRST NATIONAL BANK':
        name = 'SEAFIRST BANK'
    if name=='MASTERSON MORELAND SAUER MORELAND SAUER':
        name = 'MASTERSON MORELAND SAUER'
    if name=='GOLD CAPITAL MANAGEMENT':
        name = 'GOLD BANK'
    if name=='COMMERCE BANK NA KANSAS':
        name = 'COMMERCE BANK OF KANSAS CITY'
    if name=='CENTRAL BANK OF BIRMINGHAM':
        name = 'BBVA COMPASS'
    if name=='CENTRAL BANK OF THE SOUTH':
        name = 'BBVA COMPASS'
    if name=='COMPASS BANK':
        name = 'BBVA COMPASS'
    if name=='BC ZIEGLER':
        name = 'ZIEGLER'
    if name=='ZIEGLER SECURITIES':
        name = 'ZIEGLER'
    if name=='MAGNUS SECURITIES':
        name = 'MAGNUS'
    if name=='MAGNUS CAPITAL':
        name = 'MAGNUS'
    if name=='CAIN BROTHERS SHATTUCK':
        name = 'CAIN BROTHERS'
    if name=='POWELL & SATTERFIELD':
        name = 'AMERICAN MUNICIPAL SEC'
    if name=='DNT ASSET TRUST':
        name = 'JP MORGAN'
    if name=='NATIONAL BANK & TR CO OF NORWICH':
        name = 'NBT BANK'
    if name=='MITSUBISHI UFJ SECURITIES':
        name = 'MITSUBISHI BANK'
    if name=='BANK OF TOKYO MITSUBISHI UFJ':
        name = 'MITSUBISHI BANK'
    if name=='BANK OF TOKYO TRUST':
        name = 'BANK OF TOKYO'
    if name=='BANK OF TOKYO FINANCIAL SERVICES':
        name = 'BANK OF TOKYO'
    if name=='MUFG SECURITIES AMERICAS':
        name = 'MUFG UNION BANK'
    if name=='CITIZENS TRUST CO (RI)':
        name = 'CITIZENS BANK'
    if name=='CITIZENS BANK PROVIDENCE RI':
        name = 'CITIZENS BANK'
    if name=='SB ONE BANK':
        name = 'SUSSEX COUNTY STATE BANK'
    if name=='OREGON BANK PORTLAND':
        name = 'PACIFIC SECURITIES'
    if name=='FIRST NATIONAL CITY BANK':
        name = 'CITIGROUP'
    if name=='CITI BANK':
        name = 'CITIGROUP'
    if name=='CITI':
        name = 'CITIGROUP'
    if name=='CITIGROUP GLOBAL MARKETS':
        name = 'CITIGROUP'
    if name=='BANKNORTH':
        name = 'TD BANK'
    if name=='BECKER PARIBAS':
        name = 'AG BECKER'
    if name=='FIRST NATIONAL BANK OF CINCINNATI':
        name = 'STAR BANK'
    if name=='LCNB NATIONAL BANK':
        name = 'LEBANON CITIZENS NATIONAL BANK'
    if name=='SOUTHTRUST BANK OF ALABAMA':
        name = 'SOUTHTRUST SECURITIES'
    if name=='UNION PLANTERS BANK':
        name = 'UNION PLANTERS NATIONAL BANK'
    if name=='UNION PLANTERS INVESTMENT':
        name = 'UNION PLANTERS NATIONAL BANK'
    if name=='OLD SECOND NATIONAL BANK OF AMERICA':
        name = 'OLD SECOND BANK'
    if name=='BARCLAYS INVESTMENT':
        name = 'BARCLAYS'
    if name=='BACHE HALSEY STUART':
        name = 'BACHE HALSEY STUART SHIELDS IN'
    if name=='FIRST NATIONAL BANK OF OREGON':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK CALIFORNIA':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK DENVER':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK OREGON':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK ARIZONANA':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK NEVADANA':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK OKLAHOMA':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK WASHINGTON':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE PUB FINANCE':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE PUB FIN':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK OF ARKANSAS':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK ARIZONANA':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK NEVADANA':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK OKLAHOMA':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE PUB FINANCE':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE PUB FIN':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE SECURITIES':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK NV':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK OF TEXAS':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK WYOMING':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK WISCONSIN':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK MONTANANA':
        name = 'FIRST INTERSTATE BANK'
    if name=='FIRST INTERSTATE BANK OF BOSTON':
        name = 'FIRST INTERSTATE BANK'
    if name=='JOHN J RYAN':
        name = 'RYAN BECK'
    if name=='F S MOSELEY ESTABROOK':
        name = 'MOSELEY HALLGARTEN ESTABROOK'
    if name=='W H MORTON':
        name = 'AMERICAN EXPRESS'
    if name=='WINSTON ROWLES DIV OF COWEN':
        name = 'COWEN'
    if name=='ROWLES WINSTON':
        name = 'COWEN'
    if name=='UNITED MUNICIPAL INVEST':
        name = 'UMIC'
    if name=='A S HART':
        name = 'UNION PLANTERS NATIONAL BANK'
    if name=='MARINE BANK NA MILWAUKEE':
        name = 'MARINE NATIONAL EXCHANGE BANK'
    if name=='CBWL HAYDEN STONE':
        name = 'HAYDEN STONE'
    if name=='J MILTON NEWTON':
        name = 'MILTON NEWTON'
    if name=='WAUTERLEK & BROWN':
        name = 'CLAYTON BROWN & ASSOCIATES'
    if name=='VAN KAMPEN MERRITT':
        name = 'VAN KAMPEN'
    if name=='FIRST COMMERCE CAPITAL (MK)':
        name = 'FIRST COMMERCE CAPITAL'
    if name=='FIRST COMMERCE CAPITAL (PW)':
        name = 'FIRST COMMERCE CAPITAL'
    if name=='YOUNG SMITH & PEACOCK':
        name = 'PEACOCK HISLOP STALEY & GIVEN'
    if name=='FIRST NATIONAL BANK IN DALLAS':
        name = 'INTERFIRST BANK DALLAS'
    if name=='FIRST NATIONAL BANK OF BIRMINGHAM':
        name = 'AMSOUTH BANK'
    if name=='THE DETROIT BANK':
        name = 'COMERICA BANK'
    if name=='NATIONAL BANK OF TULSA':
        name = 'BOK FINANCIAL'
    if name=='SHEARSON LOEB RHOADES':
        name = 'SHEARSONAMERICAN EXPRESS'
    if name=='BIRMINGHAM TRUST NATIONAL BANK':
        name = 'SOUTHTRUST SECURITIES'
    if name=='SOUTHTRUST BANK OF FLORIDA':
        name = 'SOUTHTRUST SECURITIES'
    if name=='SOUTHTRUST BANK OF GEORGIA':
        name = 'SOUTHTRUST SECURITIES'
    if name=='SOUTHEASTERN MUNICIPAL BONDS':
        name = 'SOUTHEASTERN CAPITAL GROUP'
    if name=='CRESTAR SECURITIES':
        name = 'CRESTAR BANK'
    if name=='CRESTAR INVESTMENT BANK':
        name = 'CRESTAR BANK'
    if name=='CRESTAR CAPITAL MARKETS GROUP':
        name = 'CRESTAR BANK'
    if name=='NATIONAL CENTRAL BANK LANCASTER':
        name = 'HAMILTON BANK'
    if name=='FIDELITY UNION TRUST':
        name = 'FIDELITY BANK (NJ)'
    if name=='SOUTH CAROLINA NATIONAL BANK':
        name = 'NATIONAL BANK OF SO CAROLINA'
    if name=='SOUTH CAROLINA NATIONAL BANK':
        name = 'NATIONAL BANK OF SO CAROLINA'

    return name

