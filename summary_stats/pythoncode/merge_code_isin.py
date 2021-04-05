import pandas as pd
import os

path = '/media/guolewen/regular_files/guolewen/Market_invariance/JAPAN/Code_ISIN'
files = os.listdir(path)
df = pd.concat((pd.read_csv(os.path.join(path, f)) for f in files), ignore_index=True)
df['Code'] = df['Code'].apply(lambda x: int(str(x)[0:4]))
df.to_csv('/media/guolewen/regular_files/guolewen/Market_invariance/JAPAN/code_isin_industry_table.csv', index=False)