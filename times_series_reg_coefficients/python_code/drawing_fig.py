import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os


def plotting(file, title, type='plus'):
    if type =='plus':
        pvallb=r'$\it{p}-\mathrm{value} (\/ \mathrm{Ln(\frac{W}{W^{*}}) = \frac{2}{3}})$'
        hline = 2/3
    elif type =='negative':
        pvallb = r'$\it{p}-\mathrm{value} (\/ \mathrm{Ln(\frac{W}{W^{*}}) = -\frac{2}{3}})$'
        hline = -2/3
    plt.style.use('bmh')
    df = pd.read_stata(file)
    df.date = pd.to_datetime(df.date, format='%Y%m%d')
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 5), gridspec_kw={'height_ratios': [3, 1]})
    #lims = [df.date.to_list()[0], df.date.to_list()[-1]]
    ax1.plot(df.date, df.w, marker='d', linestyle='solid', label=r'$\mathrm{Ln(\frac{W}{W^{*}}) Coefficient}$', markersize=5.3)
    ax1.plot(df.date, df.ciu, linestyle='dashed', color='dimgray', label='95% CI Upper')
    ax1.plot(df.date, df.cil, linestyle='dotted', color='dimgray', label='95% CI Lower')
    ax1.axhline(y=hline, linestyle='dashdot', color='salmon')
    # ax1.set_xlim(left=df.date.to_list()[0], right=df.date.to_list()[-1])
    ax1.set_ylabel('Coefficients')
    ax1.set_title(title)
    ax1.legend()
    ax1.set_yticks(np.sort(np.append(ax1.get_yticks(), hline)))
    ax1.axes.xaxis.set_ticklabels([])

    ax2.bar(df.date, df.pval, 0.8, color='black', label=pvallb)
    for label in ax2.get_xticklabels():
        label.set_rotation(40)
        label.set_horizontalalignment('right')
    ax2.set_ylabel(pvallb, fontsize=8)
    ax2.set_ylim(bottom=0, top=1)
    ax2.axhline(y=0.05, linestyle='dotted', color='black', label='5% Threshold')
    ax2.set_xlabel('Date')
    ax2.set_yticks(np.sort(np.append(ax2.get_yticks(), 0.05)))
    ax2.tick_params(axis='y', labelsize=4.8)
    ax2.legend()

    plt.savefig(file.split('.')[0] + '.jpg', dpi=800)
    return

if __name__ == '__main__':
    os.chdir('/media/guolewen/regular_files/guolewen/Market_invariance/JAPAN/times_series_reg_coefficients/')
    plotting('res_num_print.dta', "Coefficients for Number of Trades" ,type='plus')
    plotting('res_printsize_tw.dta',"Coefficients for Median Trade-Weighted Print Sizes" ,type='negative')
    plotting('res_printsize_vw.dta', "Coefficients for Median Volume-Weighted Print Sizes",type='negative')
