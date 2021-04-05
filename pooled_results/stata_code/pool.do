clear
global pathdata "/media/guolewen/regular_files/guolewen/Market_invariance/JAPAN/pooled_results"
cd $pathdata
import delimited "/media/guolewen/intraday_data/needs/day_stock_computed_data/full_data_with_volg.csv", stringcols(2)
gen date1 = date(date, "YMD")
xtset ticker date1
sum // summary statistics


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
egen newgroup=group(industry date1) // se clustered by both industry and date

*-------------------------------Fig.1----------------------------------
/*
#d  ;
twoway
	scatter logscaled1prints logw1,
	title('Microstructure Invariance');
graph save fig1.gph, 
replace;
twoway
	scatter logscaledbfprints logw1,
	title('Invariant Bet Frequency');
graph save fig2.gph,
replace;
twoway
	scatter logscaledbsprints logw1,
	title('Invariant Bet Size');
graph save fig3.gph,
replace;
#d cr

graph combine fig1.gph fig2.gph fig3.gph
graph save combine_fig1.jpg, replace
*/

*------------------------Pooled Regressions for number of prints----------
* Ln (Nit) = mu + alpha (Ln(Wit/W*)) + error              (1)
* Both OLS and Poisson regressions are estimated
* OLS Pooled Results

reg lognprints logw1dbw1, cluster(industry) // Coefficient: .6840641
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table2.tex, replace ctitle("OLS") title("Table II Pooled Least Square Estimates of Number of Prints") label adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) adds("Coef Equal 2/3 p-val", `pval') adec(3) afmt(fc)
 
/* Fama MacBeth Results
asreg lognprints logw1dbw1, fmb newey(3)
outreg2 using table2.tex, append ctitle("Fama-MacBeth") label addtext(Stock FE, NO, Day FE, NO) dec(3)
*/
* Poisson Pooled Results
qui poisson lognprints logw1dbw1, cluster(newgroup)
margins, dydx(*) // dydx: .7058628 
qui poisson lognprints logw1dbw1, cluster(industry)
margins, dydx(*) 

*------------------------Pooled Regressions for print size-----------------
* f{Ln (|X|/V)} = mu + alpha (Ln(Wit/W*)) + error          (2)
* OLS Pooled Results
* Volume-weighted dependent variable

reg logvwsize logw1dbw1, cluster(industry) // Coefficient: -.6172054
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] + 2/3) /_se[logw1dbw1])) * 2
outreg2 using table5.tex, replace ctitle("Volume-Weighted") title("Table V Pooled Least Square Estimates of Quantile Print Sizes") adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) adds("Coef Equal -2/3 p-val", `pval') adec(3) afmt(fc)
* Trade-weighted dependent variable (median, 80p, 20p)

reg logtwsize logw1dbw1, cluster(industry) // Coefficient: -.7495869
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] + 2/3) /_se[logw1dbw1])) * 2
outreg2 using table5.tex, append ctitle("Trade-Weighted") title("Table V Pooled Least Square Estimates of Quantile Print Sizes") adjr2 addtext(Stock FE, NO, Day FE, NO) dec(3) adds("Coef Equal -2/3 p-val", `pval') adec(3) afmt(fc)

reg logtw80size logw1dbw1, cluster(industry) // Coefficient: -.651438 

reg logtw20size logw1dbw1, cluster(industry) // Coefficient: -.7941355 

*--------------------Fixed Effects (LSDV) for number of prints---------- 
* LSDV estimator, standard errors are clustered by both date and industry
areg lognprints logw1dbw1, absorb(ticker) cluster(industry) // Stock FE .63147
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table2.tex, append adjr2 ctitle("LSDV") label addtext(Stock FE, YES, Day FE, NO) dec(3) adds("Coef Equal 2/3 p-val", `pval') adec(3) afmt(fc)

areg lognprints logw1dbw1, absorb(date) cluster(industry)  // Day FE .6839493
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table2.tex, append adjr2 ctitle("LSDV") label addtext(Stock FE, NO, Day FE, YES) dec(3) adds("Coef Equal 2/3 p-val", `pval') adec(3) afmt(fc)

areg lognprints logw1dbw1 i.date1, absorb(ticker) cluster(industry) // two-way FE .626967
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
outreg2 using table2.tex, append adjr2 ctitle("LSDV") keep(logw1dbw1) label addtext(Stock FE, YES, Day FE, YES) dec(3) adds("Coef Equal 2/3 p-val", `pval') adec(3) afmt(fc)

*Prais-Winsten regression, heteroskedastic panels corrected standard errors
* However, this could only be examined when using stata SE or higher
*xtpcse lognprints logw1dbw1 i.ticker, corr(ar1)


*--------------------Fixed Effects (LSDV) for number of prints----------
* LSDV estimator, standard errors are clustered by both date and industry
* Volume-weighted dependent variable

areg logvwsize logw1dbw1, absorb(ticker) cluster(industry) // Stock FE -.4899378
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] + 2/3) /_se[logw1dbw1])) * 2
outreg2 using table5.tex, append ctitle("Volume-Weighted") label title("Table V Pooled Least Square Estimates of Quantile Print Sizes") adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3) adds("Coef Equal -2/3 p-val", `pval') adec(3) afmt(fc)

areg logvwsize logw1dbw1, absorb(date) cluster(industry) // Day FE -.6182569
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] + 2/3) /_se[logw1dbw1])) * 2
outreg2 using table5.tex, append ctitle("Volume-Weighted") label title("Table V Pooled Least Square Estimates of Quantile Print Sizes") adjr2 addtext(Stock FE, NO, Day FE, YES) dec(3) adds("Coef Equal -2/3 p-val", `pval') adec(3) afmt(fc)

areg logvwsize logw1dbw1 i.date1, absorb(ticker) cluster(industry) // two-way -.493899
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] + 2/3) /_se[logw1dbw1])) * 2
outreg2 using table5.tex, append ctitle("Volume-Weighted") title("Table V Pooled Least Square Estimates of Quantile Print Sizes") keep(logw1dbw1) label adjr2 addtext(Stock FE, YES, Day FE, YES) dec(3) adds("Coef Equal -2/3 p-val", `pval') adec(3) afmt(fc)
* Trade-weighted dependent variable

areg logtwsize logw1dbw1, absorb(ticker) cluster(industry) // Stock FE -.7224438
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] + 2/3) /_se[logw1dbw1])) * 2
outreg2 using table5.tex, append ctitle("Trade-Weighted") label title("Table V Pooled Least Square Estimates of Quantile Print Sizes") adjr2 addtext(Stock FE, YES, Day FE, NO) dec(3) adds("Coef Equal -2/3 p-val", `pval') adec(3) afmt(fc)

areg logtwsize logw1dbw1, absorb(date) cluster(industry) // Day FE -.7491275
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] + 2/3) /_se[logw1dbw1])) * 2
outreg2 using table5.tex, append ctitle("Trade-Weighted") label title("Table V Pooled Least Square Estimates of Quantile Print Sizes") adjr2 addtext(Stock FE, NO, Day FE, YES) dec(3) adds("Coef Equal -2/3 p-val", `pval') adec(3) afmt(fc)

areg logtwsize logw1dbw1 i.date1, absorb(ticker) cluster(industry) // two-way -.7156124
local pval = ttail(e(df_r), (abs(_b[logw1dbw1] + 2/3) /_se[logw1dbw1])) * 2
outreg2 using table5.tex, append ctitle("Trade-Weighted") label title("Table V Pooled Least Square Estimates of Quantile Print Sizes") adjr2 keep(logw1dbw1) addtext(Stock FE, YES, Day FE, YES) dec(3) adds("Coef Equal -2/3 p-val", `pval') adec(3) afmt(fc)


areg logtw80size logw1dbw1, absorb(ticker) cluster(industry) // -.617646 
areg logtw80size logw1dbw1, absorb(date) cluster(industry) // -.6510443
areg logtw80size logw1dbw1 i.date1, absorb(ticker) cluster(industry) // -.6111797

areg logtw20size logw1dbw1, absorb(ticker) cluster(industry) // -.7720191
areg logtw20size logw1dbw1, absorb(date) cluster(industry) // -.7936087
areg logtw20size logw1dbw1 i.date1, absorb(ticker) cluster(industry) // -.7648057

exit
