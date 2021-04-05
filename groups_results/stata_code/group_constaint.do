clear
global pathdata "/media/guolewen/regular_files/guolewen/Market_invariance/JAPAN/groups_results"
cd $pathdata
import delimited "/media/guolewen/intraday_data/needs/day_stock_computed_data/full_data_with_volg.csv", stringcols(2) // import data

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


* ----------------constainted OLS w1: Coef=2/3 Ticksize-------------------------
constraint 1 logw1 = 2/3
qui reg lognprints logw1 if ticksize==1, cluster(industry)
local sst = e(mss)
cnsreg lognprints logw1 if ticksize==1, constraints(1) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
local rsq = 1 - `ssr' / `sst'
outreg2 using table3c.tex, replace ctitle("Ticksize 1") title("Table IIIc Restricted OLS Estimates of Number of Prints for Ticksize Groups: Order Split Calibration") drop(logw1) adds("mu", `mu', "rmse", e(rmse), "R-squared", `rsq') adec(3) afmt(fc) label dec(3)

qui reg lognprints logw1 if ticksize==5, cluster(industry)
local sst = e(mss)
cnsreg lognprints logw1 if ticksize==5, constraints(1) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
local rsq = 1 - `ssr' / `sst'
outreg2 using table3c.tex, append ctitle("Ticksize 5") adds("mu", `mu', "rmse", e(rmse), "R-squared", `rsq') drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg lognprints logw1 if ticksize==10, cluster(industry)
local sst = e(mss)
cnsreg lognprints logw1 if ticksize==10, constraints(1) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
local rsq = 1 - `ssr' / `sst'
outreg2 using table3c.tex, append ctitle("Ticksize 10") adds("mu", `mu', "rmse", e(rmse), "R-squared", `rsq') drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg lognprints logw1 if ticksize==50, cluster(industry)
local sst = e(mss)
cnsreg lognprints logw1 if ticksize==50, constraints(1) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
local rsq = 1 - `ssr' / `sst'
outreg2 using table3c.tex, append ctitle("Ticksize 50") adds("mu", `mu', "rmse", e(rmse), "R-squared", `rsq') drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg lognprints logw1 if ticksize==100, cluster(industry)
local sst = e(mss)
cnsreg lognprints logw1 if ticksize==100, constraints(1) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
local rsq = 1 - `ssr' / `sst'
outreg2 using table3c.tex, append ctitle("Ticksize 100") adds("mu", `mu', "rmse", e(rmse), "R-squared", `rsq') drop(logw1) adec(3) afmt(fc) label dec(3)

* ----------------constainted OLS w1: Coef=2/3 Volume-------------------------
qui reg lognprints logw1 if volkylegroup==1, cluster(industry)
local sst = e(mss)
di `sst'
cnsreg lognprints logw1 if volkylegroup==1, constraints(1) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
di `ssr'
local rsq = 1 - `ssr' / `sst'
outreg2 using table3d.tex, replace ctitle("Volume 1") title("Table IIIc Restricted OLS Estimates of Number of Prints for Volume Groups: Order Split Calibration") drop(logw1) adds("mu", `mu', "rmse", e(rmse)) adec(3) afmt(fc) label dec(3)

qui reg lognprints logw1 if volkylegroup==2, cluster(industry)
local sst = e(mss)
di `sst'
cnsreg lognprints logw1 if volkylegroup==2, constraints(1) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
di `ssr'
local rsq = 1 - `ssr' / `sst'
outreg2 using table3d.tex, append ctitle("Volume 2") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg lognprints logw1 if volkylegroup==3, cluster(industry)
local sst = e(mss)
di `sst'
cnsreg lognprints logw1 if volkylegroup==3, constraints(1) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
di `ssr'
local rsq = 1 - `ssr' / `sst'
outreg2 using table3d.tex, append ctitle("Volume 3") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg lognprints logw1 if volkylegroup==4, cluster(industry)
local sst = e(mss)
di `sst'
cnsreg lognprints logw1 if volkylegroup==4, constraints(1) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
di `ssr'
local rsq = 1 - `ssr' / `sst'
outreg2 using table3d.tex, append ctitle("Volume 4") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg lognprints logw1 if volkylegroup==5, cluster(industry)
local sst = e(mss)
di `sst'
cnsreg lognprints logw1 if volkylegroup==5, constraints(1) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
di `ssr'
local rsq = 1 - `ssr' / `sst'
outreg2 using table3d.tex, append ctitle("Volume 5") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg lognprints logw1 if volkylegroup==6, cluster(industry)
local sst = e(mss)
di `sst'
cnsreg lognprints logw1 if volkylegroup==6, constraints(1) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
di `ssr'
local rsq = 1 - `ssr' / `sst'
outreg2 using table3d.tex, append ctitle("Volume 6") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg lognprints logw1 if volkylegroup==7, cluster(industry)
local sst = e(mss)
di `sst'
cnsreg lognprints logw1 if volkylegroup==7, constraints(1) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
di `ssr'
local rsq = 1 - `ssr' / `sst'
outreg2 using table3d.tex, append ctitle("Volume 7") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg lognprints logw1 if volkylegroup==8, cluster(industry)
local sst = e(mss)
di `sst'
cnsreg lognprints logw1 if volkylegroup==8, constraints(1) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
di `ssr'
local rsq = 1 - `ssr' / `sst'
outreg2 using table3d.tex, append ctitle("Volume 8") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg lognprints logw1 if volkylegroup==9, cluster(industry)
local sst = e(mss)
di `sst'
cnsreg lognprints logw1 if volkylegroup==9, constraints(1) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
di `ssr'
local rsq = 1 - `ssr' / `sst'
outreg2 using table3d.tex, append ctitle("Volume 9") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg lognprints logw1 if volkylegroup==10, cluster(industry)
local sst = e(mss)
di `sst'
cnsreg lognprints logw1 if volkylegroup==10, constraints(1) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
di `ssr'
local rsq = 1 - `ssr' / `sst'
outreg2 using table3d.tex, append ctitle("Volume 10") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

* ----------------constraint OLS w1: Coef=-2/3---------------------------------
constraint 2 logw1 = -2/3

qui reg logvwsize logw1 if ticksize==1, cluster(industry)
local sst = e(mss)
cnsreg logvwsize logw1 if ticksize==1, constraints(2) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
local rsq = 1 - `ssr' / `sst'
outreg2 using table5a.tex, replace ctitle("Ticksize 1") title("Table Va Restricted OLS Estimates of Print Size for Ticksize Groups: Order Split Calibration") drop(logw1) adds("mu", `mu', "rmse", e(rmse)) adec(3) afmt(fc) label dec(3)

qui reg logvwsize logw1 if ticksize==5, cluster(industry)
local sst = e(mss)
cnsreg logvwsize logw1 if ticksize==5, constraints(2) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
local rsq = 1 - `ssr' / `sst'
outreg2 using table5a.tex, append ctitle("Ticksize 5") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg logvwsize logw1 if ticksize==10, cluster(industry)
local sst = e(mss)
cnsreg logvwsize logw1 if ticksize==10, constraints(2) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
local rsq = 1 - `ssr' / `sst'
outreg2 using table5a.tex, append ctitle("Ticksize 10") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg logvwsize logw1 if ticksize==50, cluster(industry)
local sst = e(mss)
cnsreg logvwsize logw1 if ticksize==50, constraints(2) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
local rsq = 1 - `ssr' / `sst'
outreg2 using table5a.tex, append ctitle("Ticksize 50") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg logvwsize logw1 if ticksize==100, cluster(industry)
local sst = e(mss)
cnsreg logvwsize logw1 if ticksize==100, constraints(2) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
local rsq = 1 - `ssr' / `sst'
outreg2 using table5a.tex, append ctitle("Ticksize 100") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

* trade-weighted
qui reg logtwsize logw1 if ticksize==1, cluster(industry)
local sst = e(mss)
cnsreg logtwsize logw1 if ticksize==1, constraints(2) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
local rsq = 1 - `ssr' / `sst'
outreg2 using table5b.tex, replace ctitle("Ticksize 1") title("Table Va Restricted OLS Estimates of Print Size for Ticksize Groups: Order Split Calibration") drop(logw1) adds("mu", `mu', "rmse", e(rmse)) adec(3) afmt(fc) label dec(3)

qui reg logtwsize logw1 if ticksize==5, cluster(industry)
local sst = e(mss)
cnsreg logtwsize logw1 if ticksize==5, constraints(2) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
local rsq = 1 - `ssr' / `sst'
outreg2 using table5b.tex, append ctitle("Ticksize 5") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg logtwsize logw1 if ticksize==10, cluster(industry)
local sst = e(mss)
cnsreg logtwsize logw1 if ticksize==10, constraints(2) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
local rsq = 1 - `ssr' / `sst'
outreg2 using table5b.tex, append ctitle("Ticksize 10") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg logtwsize logw1 if ticksize==50, cluster(industry)
local sst = e(mss)
cnsreg logtwsize logw1 if ticksize==50, constraints(2) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
local rsq = 1 - `ssr' / `sst'
outreg2 using table5b.tex, append ctitle("Ticksize 50") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

qui reg logtwsize logw1 if ticksize==100, cluster(industry)
local sst = e(mss)
cnsreg logtwsize logw1 if ticksize==100, constraints(2) cluster(industry)
local mu = exp(_b[_cons])
local ssr = e(rmse)^2 * e(df_r)
local rsq = 1 - `ssr' / `sst'
outreg2 using table5b.tex, append ctitle("Ticksize 100") adds("mu", `mu', "rmse", e(rmse)) drop(logw1) adec(3) afmt(fc) label dec(3)

