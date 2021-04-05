clear
global pathdata "/media/guolewen/regular_files/guolewen/Market_invariance/JAPAN/subsample_ticksizegroup"
cd $pathdata

import delimited "/media/guolewen/intraday_data/needs/day_stock_computed_data/subsample_withticksizeind.csv", stringcols(3)

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

xtreg lognprints logw1dbw1 1.ticksizegroupind 1.ticksizegroupind#c.logw1dbw1, fe r
