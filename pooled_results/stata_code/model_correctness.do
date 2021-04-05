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

*------------------------test for poolability-------------------------------
* chow
* test poolability across firms/ slope only
xtset ticker date1
levelsof ticker, local(levels)
scalar define urss = 0
qui xtreg lognprints logw1dbw1, fe
scalar define N = e(N_g)
scalar define T = e(Tbar)
scalar define k = e(rank) - 1
scalar define rrss = e(rss)
foreach x of local levels{
	qui reg lognprints logw1dbw1 if ticker==`x'
	scalar define urss = urss + e(rss)
}
scalar define F = ((rrss - urss) / ((N-1)*k)) / ((urss)/ (N*(T-k-1)))
di "F Statistics is " F
di "df1 " (N-1)*k " df2 " N*(T-k-1) 
di "F Critical Value is " invFtail((N-1)*k, N*(T-k-1), 0.05)
di "p-value is "  Ftail((N-1)*k, N*(T-k-1), F)

*test poolability across time/ slope only
xtset date1 ticker
levelsof date1, local(levels)
scalar define urss = 0
qui xtreg lognprints logw1dbw1, fe
scalar define N = e(N_g)
scalar define T = e(Tbar)
scalar define k = e(rank) - 1
scalar define rrss = e(rss)
foreach x of local levels{
	qui reg lognprints logw1dbw1 if date1==`x'
	scalar define urss = urss + e(rss)
}
di ((rrss - urss) / ((N-1)*k)) / ((urss)/ (N*(T-k-1)))
*-------------------FE versus RE
* Hausman Test
xtreg lognprints logw2dbw1, fe
estimates store FE
xtreg lognprints logw2dbw1, re
estimates store RE 
hausman FE RE, constant sigmamore
xtreg lognprints logw2dbw1, re r
xtoverid 

xtreg lognprints logw2dbw1 i.date1, fe
estimates store FE1
xtreg lognprints logw2dbw1 i.date1, re
estimates store RE1 
hausman FE1 RE1, constant sigmamore

                    
*-------------------tests for fixed effects-------------------------------
xtreg lognprints logw1dbw1 i.date1, fe

/*
-----This block could be run only by stata SE or higher
xtset date1 ticker
xtreg lognprints logw1dbw1 i.ticker, fe
*/
