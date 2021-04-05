clear
global pathdata "/media/guolewen/regular_files/guolewen/Market_invariance/JAPAN/times_series_reg_coefficients"
cd $pathdata

import delimited "/media/guolewen/intraday_data/needs/day_stock_computed_data/full_data.csv", stringcols(2) clear  // import data
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
gen benchmarkw1 = 810000 * 0.018 // benchmark trading volatility
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

* -----------------Time-series-OLS-coefficients--------------------------------
* for number of prints
levelsof date, local(levels)
tempname res_num_print
postfile `res_num_print' str8 date obs intercept w se cil ciu pval using res_num_print.dta, replace
foreach x of local levels {
	regress lognprints logw1dbw1 if date=="`x'", robust
	local pval = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
	post `res_num_print' ("`x'") (e(N)) (_b[_cons]) (_b[logw1dbw1]) (_se[logw1dbw1]) (_b[logw1dbw1]-invttail(e(df_r),0.025)*_se[logw1dbw1]) (_b[logw1dbw1]+invttail(e(df_r),0.025)*_se[logw1dbw1]) (`pval')
}
postclose `res_num_print'

* for printsize
* trade-weighted
levelsof date, local(levels)
tempname res_printsize_tw
postfile `res_printsize_tw' str8 date obs intercept w se cil ciu pval using res_printsize_tw.dta, replace
foreach x of local levels {
	regress logtwsize logw1dbw1 if date=="`x'", robust
	local pval = ttail(e(df_r), (abs(_b[logw1dbw1] + 2/3) /_se[logw1dbw1])) * 2
	post `res_printsize_tw' ("`x'") (e(N)) (_b[_cons]) (_b[logw1dbw1]) (_se[logw1dbw1]) (_b[logw1dbw1]-invttail(e(df_r),0.025)*_se[logw1dbw1]) (_b[logw1dbw1]+invttail(e(df_r),0.025)*_se[logw1dbw1]) (`pval')
}
postclose `res_printsize_tw'
* volume-weighted
levelsof date, local(levels)
tempname res_printsize_vw
postfile `res_printsize_vw' str8 date obs intercept w se cil ciu pval using res_printsize_vw.dta, replace
foreach x of local levels {
	regress logvwsize logw1dbw1 if date=="`x'", robust
	local pval = ttail(e(df_r), (abs(_b[logw1dbw1] + 2/3) /_se[logw1dbw1])) * 2
	post `res_printsize_vw' ("`x'") (e(N)) (_b[_cons]) (_b[logw1dbw1]) (_se[logw1dbw1]) (_b[logw1dbw1]-invttail(e(df_r),0.025)*_se[logw1dbw1]) (_b[logw1dbw1]+invttail(e(df_r),0.025)*_se[logw1dbw1]) (`pval')
}
postclose `res_printsize_vw'

