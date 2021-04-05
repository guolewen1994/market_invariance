from linearmodels.panel import PanelOLS, PooledOLS
import statsmodels.api as sm
import pandas as pd
import numpy as np


df = pd.read_csv('/media/guolewen/intraday_data/needs/day_stock_computed_data/full_data_with_volg.csv')
Date = pd.Categorical(df.Date)
Ticker = pd.Categorical(df.Ticker)
df = df.set_index(["Ticker", "Date"])
df["Date1"] = Date
df["Ticker1"] = Ticker
# Variable Constructions
df['lognprints'] = np.log(df['NPRINTs'])
w = (df['YENVOL'] / 100) * (df['volatility'])
df['logwdbw'] = np.log(w / (601000 * 0.016))
# drop -inf when volatility equals to 0
df = df[~df.isin([np.nan, np.inf, -np.inf]).any(1)]
# Pooled OLS
exog = sm.add_constant(df['logwdbw'])
mod = PooledOLS(df.lognprints, exog)
pooled_res = mod.fit()
print(pooled_res)

"""
# fixed effects with time dummy
exog = sm.add_constant(df[['logwdbw','Date1']])
mod = PanelOLS(df.lognprints, exog, entity_effects=True)
fe_res1 = mod.fit()
print(fe_res1)
"""
# fixed effects with ticker dummy
exog = sm.add_constant(df[['logwdbw', "Ticker1"]])
mod = PanelOLS(df.lognprints, exog, time_effects=True)
fe_res3 = mod.fit()
print(fe_res3)

# two-way fixed effects
"""
exog = sm.add_constant(df['logwdbw'])
mod = PanelOLS(df.lognprints, exog, entity_effects=True, time_effects=True)
fe_res2 = mod.fit()
print(fe_res2)
"""