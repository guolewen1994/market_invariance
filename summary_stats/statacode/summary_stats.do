clear
global pathdata "/media/guolewen/regular_files/guolewen/Market_invariance/JAPAN/summary_stats"
cd $pathdata
import delimited "/media/guolewen/intraday_data/needs/day_stock_computed_data/full_data_with_volg.csv", stringcols(2) // import data

gen hundred_prc = hundredlotprints / nprints
gen thousand_prc = thousandlotprints / nprints
gen even_prc = evenlotprints / nprints
gen dollarvol_in_1000 = yenvol / 100000 // yen-dollar volume adjustment

outreg2 using table1pa, sideway replace tex sum(detail) eqkeep(N mean sd p1 p50 p99) title("Table I: Panel A Descriptive Statstics for All Stocks") keep(avg_printsize d_med_tw_size d_med_vw_size nprints avg_price dollarvol_in_1000 volatility hundred_prc thousand_prc even_prc) dec(3)

bysort ticksize: outreg2 using table1pb, replace tex sum(log) eqkeep(mean N) title("Table I: Panel B Descriptive Statstics for Ticksize Groups") keep(avg_printsize d_med_tw_size d_med_vw_size nprints avg_price dollarvol_in_1000 volatility hundred_prc thousand_prc even_prc) dec(3)


bysort volkylegroup: outreg2 using table1pc, replace tex sum(log) eqkeep(mean N) title("Table I: Panel C Descriptive Statstics for Volume Groups") keep(avg_printsize d_med_tw_size d_med_vw_size nprints avg_price dollarvol_in_1000 volatility hundred_prc thousand_prc even_prc) dec(3)

bysort volnormalgroup: outreg2 using table1pd, replace tex sum(log) eqkeep(mean N) title("Table I: Panel D Descriptive Statstics for Volume Groups") keep(avg_printsize d_med_tw_size d_med_vw_size nprints avg_price dollarvol_in_1000 volatility hundred_prc thousand_prc even_prc) dec(3)
