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
*-----------------coefficients by volume group all----------------------------
qui xtreg lognprints logw1dbw1 if volkylegroup==1, fe r
scalar coef1 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p1 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p1)
di (e(N))

qui xtreg lognprints logw1dbw1 if volkylegroup==2, fe r
scalar coef2 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p2 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p2)
di (e(N))

qui xtreg lognprints logw1dbw1 if volkylegroup==3, fe r
scalar coef3 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p3 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p3)
di (e(N))

qui xtreg lognprints logw1dbw1 if volkylegroup==4, fe r
scalar coef4 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p4 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p4)
di (e(N))

qui xtreg lognprints logw1dbw1 if volkylegroup==5, fe r
scalar coef5 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p5 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p5)
di (e(N))

qui xtreg lognprints logw1dbw1 if volkylegroup==6, fe r
scalar coef6 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p6 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p6)
di (e(N))

qui xtreg lognprints logw1dbw1 if volkylegroup==7, fe r
scalar coef7 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p7 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p7)
di (e(N))

qui xtreg lognprints logw1dbw1 if volkylegroup==8, fe r
scalar coef8 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p8 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p8)
di (e(N))

qui xtreg lognprints logw1dbw1 if volkylegroup==9, fe r
scalar coef9 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p9 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p9)
di (e(N))

qui xtreg lognprints logw1dbw1 if volkylegroup==10, fe r
scalar coef10 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p10 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p10)
di (e(N))

scalar avg = (coef1 + coef2 + coef3 + coef4 + coef5 + coef6 + coef7 + coef8 + coef9 + coef10) / 10

di ("Avg Coefficient for Volume Group ") avg



*------------------coefficients by volume group and by tick size--------------
qui xtreg lognprints logw1dbw1 if ticksize==1 & volkylegroup==1, fe r
scalar coef11 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p11 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p11)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==1 & volkylegroup==2, fe r
scalar coef12 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p12 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p12)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==1 & volkylegroup==3, fe r
scalar coef13 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p13 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p13)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==1 & volkylegroup==4, fe r
scalar coef14 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p14 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p14)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==1 & volkylegroup==5, fe r
scalar coef15 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p15 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p15)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==1 & volkylegroup==6, fe r
scalar coef16 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p16 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p16)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==1 & volkylegroup==7, fe r
scalar coef17 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p17 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p17)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==1 & volkylegroup==8, fe r
scalar coef18 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p18 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p18)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==1 & volkylegroup==9, fe r
scalar coef19 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p19 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p19)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==1 & volkylegroup==10, fe r
scalar coef110 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p110 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p110)
di (e(N))

scalar avg1 = (coef11 + coef12 + coef13 + coef14 + coef15 + coef16 + coef17 + coef18 + coef19 + coef110) / 10

di ("Avg Coefficient for ticksize 1 ") avg1

*-------tick size 5-----------------------------------------------------------

qui xtreg lognprints logw1dbw1 if ticksize==5 & volkylegroup==1, fe r
scalar coef51 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p51 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p51)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==5 & volkylegroup==2, fe r
scalar coef52 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p52 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p52)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==5 & volkylegroup==3, fe r
scalar coef53 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p53 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p53)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==5 & volkylegroup==4, fe r
scalar coef54 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p54 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p54)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==5 & volkylegroup==5, fe r
scalar coef55 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p55 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p55)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==5 & volkylegroup==6, fe r
scalar coef56 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p56 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p56)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==5 & volkylegroup==7, fe r
scalar coef57 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p57 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p57)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==5 & volkylegroup==8, fe r
scalar coef58 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p58 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p58)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==5 & volkylegroup==9, fe r
scalar coef59 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p59 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p59)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==5 & volkylegroup==10, fe r
scalar coef510 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p510 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p510)
di (e(N))

scalar avg5 = (coef51 + coef52 + coef53 + coef54 + coef55 + coef56 + coef57 + coef58 + coef59 + coef510) / 10

di ("Avg Coefficient for ticksize 5 ") avg5

*-------tick size 10-----------------------------------------------------------

qui xtreg lognprints logw1dbw1 if ticksize==10 & volkylegroup==1, fe r
scalar coef101 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p101 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p101)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==10 & volkylegroup==2, fe r
scalar coef102 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p102 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p102)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==10 & volkylegroup==3, fe r
scalar coef103 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p103 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p103)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==10 & volkylegroup==4, fe r
scalar coef104 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p104 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p104)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==10 & volkylegroup==5, fe r
scalar coef105 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p105 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p105)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==10 & volkylegroup==6, fe r
scalar coef106 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p106 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p106)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==10 & volkylegroup==7, fe r
scalar coef107 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p107 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p107)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==10 & volkylegroup==8, fe r
scalar coef108 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p108 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p108)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==10 & volkylegroup==9, fe r
scalar coef109 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p109 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p109)
di (e(N))

qui xtreg lognprints logw1dbw1 if ticksize==10 & volkylegroup==10, fe r
scalar coef1010 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p1010 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p1010)
di (e(N))

scalar avg10 = (coef101 + coef102 + coef103 + coef104 + coef105 + coef106 + coef107 + coef108 + coef109 + coef1010) / 10

di ("Avg Coefficient for ticksize 10 ") avg10


qui xtreg lognprints logw1dbw1 if ticksize==50 & volkylegroup==10, fe r
scalar coef5010 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p5010 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p5010)
di (e(N))


qui xtreg lognprints logw1dbw1 if ticksize==100 & volkylegroup==10, fe r
scalar coef10010 = _b[logw1dbw1]
di (_b[logw1dbw1])
scalar p10010 = ttail(e(df_r), (abs(_b[logw1dbw1] - 2/3) /_se[logw1dbw1])) * 2
di (p10010)
di (e(N))
