clear
global pathdata "/media/guolewen/regular_files/guolewen/Market_invariance/JAPAN/groups_results"
cd $pathdata
import delimited "/media/guolewen/intraday_data/needs/day_stock_computed_data/full_data_with_volg.csv", stringcols(2) // import data
gen date1 = date(date, "YMD")
xtset ticker date1

gen dollarvol = yenvol / 100 // yen-dollar volume adjustment
gen w1 = dollarvol * volatility // trading activity based on standard volatility
gen w2 = dollarvol * parkinsonvol // trading activity based on parkinson vol
gen scaled1prints = nprints * ((w1)^(-2/3)) // scaled prints
gen scaledbsprints = nprints * (w1^(-1)) // invariant bet size
gen scaledbfprints = nprints // invariant bet frequency
gen logw1 = log(w1)
gen logscaled1prints = log(scaled1prints)
gen logscaledbsprints = log(scaledbsprints)
gen logscaledbfprints = log(scaledbfprints)
gen benchmarkw1 = 601000 * 0.016 // benchmark trading volatility
gen logw1dbw1 = log(w1 / benchmarkw1) // right-hand side variable in reg(1) and reg(2)
gen logw2dbw1 = log(w2 / benchmarkw1)
label variable logw1dbw1 "Log Adj-Trading Activity"
/* Number of Print Variable    */
gen lognprints = log(nprints) // left-hand side variable in reg (1)
label variable lognprints "Log Number of Prints"
/* Print Size Variable    */
gen logvwsize = log(d_med_vw_size / vol) // Volume-weighted median print size
gen logtwsize = log(d_med_tw_size / vol) // Trade-weighted median print size
gen logtw80size = log(d_80p_tw_size / vol) // TW 80% print size 
gen logtw20size = log(d_20p_tw_size / vol) // TW 20% print size 
egen newgroup=group(industry date) // se clustered by both industry and date

* -----------------------ticksize group regressions----------------------------
reg lognprints logw1dbw1 if ticksize==1, cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table3.tex, replace ctitle("Ticksize 1") title("Table III OLS Estimates of Number of Prints for Ticksize Groups") adds("Coef Equal 2/3 p-val", `pval') adec(3) afmt(fc) label adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3)

reg lognprints logw1dbw1 if ticksize==5, cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table3.tex, append ctitle("Ticksize 5") adds("Coef Equal 2/3 p-val", `pval') adec(3) afmt(fc) label adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) 

reg lognprints logw1dbw1 if ticksize==10, cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table3.tex, append ctitle("Ticksize 10") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) adec(3) afmt(fc)

reg lognprints logw1dbw1 if ticksize==50, cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table3.tex, append ctitle("Ticksize 50") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) adec(3) afmt(fc)

reg lognprints logw1dbw1 if ticksize==100, cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table3.tex, append ctitle("Ticksize 100") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) adec(3) afmt(fc)


* -----------------------ticksize stock fixed effects-------------------------
areg lognprints logw1dbw1 if ticksize==1, absorb(ticker) cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table3b.tex, replace ctitle("Ticksize 1") title("Table IIIb OLS Estimates of Number of Prints for Ticksize Groups") adds("Coef Equal 2/3 p-val", `pval') adec(3) afmt(fc) label adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3)

areg lognprints logw1dbw1 if ticksize==5, absorb(ticker) cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table3b.tex, append ctitle("Ticksize 5") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3) adec(3) afmt(fc)

areg lognprints logw1dbw1 if ticksize==10, absorb(ticker) cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table3b.tex, append ctitle("Ticksize 10") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3) adec(3) afmt(fc)

areg lognprints logw1dbw1 if ticksize==50, absorb(ticker) cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table3b.tex, append ctitle("Ticksize 50") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3) adec(3) afmt(fc)

areg lognprints logw1dbw1 if ticksize==100, absorb(ticker) cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table3b.tex, append ctitle("Ticksize 100") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3) adec(3) afmt(fc)

* ----------------------trade volume group regressions-------------------------
reg lognprints logw1dbw1 if volkylegroup==1, cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4.tex, replace ctitle("Volume 1") title("Table IV OLS Estimates of Number of Prints for Volume Groups") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) adec(3) afmt(fc)

reg lognprints logw1dbw1 if volkylegroup==2, cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4.tex, append ctitle("Volume 2") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) adec(3) afmt(fc)

reg lognprints logw1dbw1 if volkylegroup==3, cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4.tex, append ctitle("Volume 3") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) adec(3) afmt(fc)

reg lognprints logw1dbw1 if volkylegroup==4, cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4.tex, append ctitle("Volume 4") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) adec(3) afmt(fc)

reg lognprints logw1dbw1 if volkylegroup==5, cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4.tex, append ctitle("Volume 5") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) adec(3) afmt(fc)

reg lognprints logw1dbw1 if volkylegroup==6, cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4.tex, append ctitle("Volume 6") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) adec(3) afmt(fc)

reg lognprints logw1dbw1 if volkylegroup==7, cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4.tex, append ctitle("Volume 7") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) adec(3) afmt(fc)

reg lognprints logw1dbw1 if volkylegroup==8, cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4.tex, append ctitle("Volume 8") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) adec(3) afmt(fc)

reg lognprints logw1dbw1 if volkylegroup==9, cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4.tex, append ctitle("Volume 9") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) adec(3) afmt(fc)

reg lognprints logw1dbw1 if volkylegroup==10, cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4.tex, append ctitle("Volume 10") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) adec(3) afmt(fc)

* ------------------------trade volume group stock fixed effect----------------

areg lognprints logw1dbw1 if volkylegroup==1, absorb(ticker) cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4b.tex, replace ctitle("Volume 1") title("Table IVb OLS Estimates of Number of Prints for Volume Groups") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3) adec(3) afmt(fc)

areg lognprints logw1dbw1 if volkylegroup==2, absorb(ticker) cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4b.tex, append ctitle("Volume 2") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3) adec(3) afmt(fc)

areg lognprints logw1dbw1 if volkylegroup==3, absorb(ticker) cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4b.tex, append ctitle("Volume 3") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3) adec(3) afmt(fc)

areg lognprints logw1dbw1 if volkylegroup==4, absorb(ticker) cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4b.tex, append ctitle("Volume 4") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3) adec(3) afmt(fc)

areg lognprints logw1dbw1 if volkylegroup==5, absorb(ticker) cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4b.tex, append ctitle("Volume 5") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3) adec(3) afmt(fc)

areg lognprints logw1dbw1 if volkylegroup==6, absorb(ticker) cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4b.tex, append ctitle("Volume 6") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3) adec(3) afmt(fc)

areg lognprints logw1dbw1 if volkylegroup==7, absorb(ticker) cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4b.tex, append ctitle("Volume 7") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3) adec(3) afmt(fc)

areg lognprints logw1dbw1 if volkylegroup==8, absorb(ticker) cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4b.tex, append ctitle("Volume 8") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3) adec(3) afmt(fc)

areg lognprints logw1dbw1 if volkylegroup==9, absorb(ticker) cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4b.tex, append ctitle("Volume 9") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3) adec(3) afmt(fc)

areg lognprints logw1dbw1 if volkylegroup==10, absorb(ticker) cluster(industry)
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table4b.tex, append ctitle("Volume 10") adds("Coef Equal 2/3 p-val", `pval') label adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3) adec(3) afmt(fc)





