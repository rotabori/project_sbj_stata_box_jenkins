*! bj_test.do  17nov2026  tests for bj.ado v0.3.0
*  Usage: place bj.ado and bj.sthlp in your PERSONAL ado directory (see: sysdir)
*         and run:  do bj_test.do
*  Data: example datasets shipped with Stata, loaded with sysuse (no internet)
*    stationary series     : tsline2, calories (daily, 2002, 365 days)
*    non-stationary series : gnp96, gnp96 (quarterly real GNP)

version 18
clear all
set more off
capture log close
log using bj_test.log, replace text

* ---------------------------------------------------------------------------
* 0. Load the current version of bj (clears old versions from memory)
* ---------------------------------------------------------------------------
discard
which bj

* ---------------------------------------------------------------------------
* 1. Data: stationary series (sections 2.1 to 2.18)
* ---------------------------------------------------------------------------
sysuse tsline2, clear
tsset day                       // daily, 01jan2002 to 31dec2002

* show the original variable label and format (used by bj)
describe calories
local original_label : variable label calories
display as text "Original label: [" as result `"`original_label'"' as text "]"

* ---------------------------------------------------------------------------
* 2. Test cases
*    capture noisily: if a case fails, the error is shown and the do-file
*    continues with the next case
* ---------------------------------------------------------------------------
graph drop _all

display as text _newline "== 2.1 Basic use"
capture noisily bj calories
display as text "rc = " _rc

display as text _newline "== 2.1b id option and default output name bj_id"
capture noisily bj calories, id
display as text "rc = " _rc
capture graph describe bj_id
display as text "graph bj_id exists: " as result cond(_rc == 0, "yes", "NO")
capture noisily bj calories, id export(bj_id, replace)
display as text "rc = " _rc
capture confirm file bj_id.pdf
display as text "bj_id.pdf exists: " as result cond(_rc == 0, "yes", "NO")

display as text _newline "== 2.1c Stage 2: bj_est with the model selected by BIC"
capture noisily bj calories
display as text "rc = " _rc
capture graph describe bj_est
display as text "graph bj_est exists: " as result cond(_rc == 0, "yes", "NO")
display as text "observations in memory (unchanged by tsappend): " as result _N

display as text _newline "== 2.1c2 Residual diagnostics: expected values (daily: 14 lags)"
quietly arima calories, arima(1,0,1)
predict double res_check, residuals
wntestq res_check, lags(14)                            // Ljung-Box
display as text "5% critical value: " as result invchi2tail(r(df), 0.05)
generate double res_check2 = res_check^2
wntestq res_check2, lags(14)                           // McLeod-Li
display as text "5% critical value: " as result invchi2tail(r(df), 0.05)
summarize res_check, detail                            // mean, sd, skewness, kurtosis
local jb = r(N) / 6 * (r(skewness)^2 + (r(kurtosis) - 3)^2 / 4)
display as text "Jarque-Bera: " as result `jb' as text "  p = " as result chi2tail(2, `jb') ///
	as text "  5% cv = " as result invchi2tail(2, 0.05)
drop res_check res_check2
capture noisily bj calories, order(1 1)
display as text "rc = " _rc "  (compare the table in bj_est with the values above)"

display as text _newline "== 2.1d Stage 2 with order(1 1) on D."
capture noisily bj D.calories, order(1 1)
display as text "rc = " _rc "  (subtitle: Estimation, diagnosis and forecast / label (D.calories); note: ARMA(1,1), user)"
arima D.calories, arima(1,0,1)                    // expected fit

display as text _newline "== 2.1d2 horizon(): forecast periods set by the user"
capture noisily bj calories, horizon(30)
display as text "rc = " _rc "  (note: Forecast: 30 periods (user); default would be 19 (5% of obs.))"
capture noisily bj calories, horizon(0)
display as text "rc = " _rc "  (expected: 125, horizon must be > 0)"

display as text _newline "== 2.1e Export of both figures: bj_test2.pdf and bj_test2_est.pdf"
capture noisily bj calories, export(bj_test2, replace)
display as text "rc = " _rc
capture confirm file bj_test2.pdf
display as text "bj_test2.pdf exists: " as result cond(_rc == 0, "yes", "NO")
capture confirm file bj_test2_est.pdf
display as text "bj_test2_est.pdf exists: " as result cond(_rc == 0, "yes", "NO")

display as text _newline "== 2.1f id option: no bj_est"
capture graph drop bj_est
capture noisily bj calories, id
capture graph describe bj_est
display as text "graph bj_est exists: " as result cond(_rc == 0, "YES (error)", "no (correct)")

display as text _newline "== 2.2 Time-series operator + options"
capture noisily bj D.calories, lags(24) level(90)
display as text "rc = " _rc

display as text _newline "== 2.3 Is the in qualifier honored?"
capture noisily bj calories in 1/100
display as text "rc = " _rc

display as text _newline "== 2.4 Sub-options"
capture noisily bj calories, acopts(title("ACF")) note("x")
display as text "rc = " _rc

display as text _newline "== 2.5 Subtitle from the variable label"
label variable calories "Calories"
capture noisily bj calories, name(t_label, replace)
display as text "rc = " _rc "  (title: Box - Jenkins modelling strategy; subtitle: Identification / Calories)"

display as text _newline "== 2.6 Label + time-series operator"
capture noisily bj D.calories, name(t_label_op, replace)
display as text "rc = " _rc "  (subtitle: Identification / Calories (D.calories))"

display as text _newline "== 2.7 nolabel option"
capture noisily bj D.calories, nolabel name(t_nolabel, replace)
display as text "rc = " _rc "  (subtitle: Identification / D.calories)"

display as text _newline "== 2.8 Variable without label"
generate calories_copy = calories
capture noisily bj calories_copy, name(t_nolab_var, replace)
display as text "rc = " _rc "  (subtitle: Identification / calories_copy)"
drop calories_copy

display as text _newline "== 2.9 User title and subtitle override the defaults"
capture noisily bj calories, title("My title") subtitle("My subtitle") name(t_user, replace)
display as text "rc = " _rc "  (title: My title; subtitle: My subtitle)"

display as text _newline "== 2.10 Information panel: dates, frequency and statistics"
quietly tsset
display as text "Expected: Start: " as result "`r(tmins)'" ///
	as text "  End: " as result "`r(tmaxs)'" as text "  Frequency: " as result "`r(unit)'"
summarize calories                                  // expected statistics
capture noisily bj calories, name(t_info, replace)
display as text "rc = " _rc

display as text _newline "== 2.11 Information panel with D. (start moves one period)"
capture noisily bj D.calories, name(t_info_d, replace)
display as text "rc = " _rc "  (start: one period later; statistics of D.calories)"
summarize D.calories                                // expected statistics

display as text _newline "== 2.12 Information panel with in 1/100 (end moves)"
capture noisily bj calories in 1/100, name(t_info_in, replace)
display as text "rc = " _rc "  (end: date of observation 100)"

display as text _newline "== 2.13 noinfo option"
timer clear 2
timer on 2
capture noisily bj calories, noinfo name(t_noinfo, replace)
timer off 2
display as text "rc = " _rc "  (no panels below the graphs; no dfuller, no arimasoc)"
timer list 2                                           // should be fast

display as text _newline "== 2.13b notests option"
timer clear 3
timer on 3
capture noisily bj calories, notests name(t_notests, replace)
timer off 3
display as text "rc = " _rc "  (Data description only; empty cell below the PACF)"
timer list 3                                           // should be fast
capture noisily bj calories, notest name(t_notest, replace)
display as text "rc = " _rc "  (abbreviation notest works)"

display as text _newline "== 2.14 infotext(): additional description of the data"
capture noisily bj calories, name(t_infotext, replace) ///
	infotext("Unit: calories per day" "Source: Stata example data (tsline2)")
display as text "rc = " _rc "  (two lines below the Data description box)"

display as text _newline "== 2.14b Statistics with thousands separators"
format calories %12.0fc
capture noisily bj calories, name(t_format, replace)
display as text "rc = " _rc "  (statistics with commas)"

display as text _newline "== 2.14c Label with double quotes and accents"
label variable calories `"Calorías "diarias" consumidas"'
capture noisily bj calories, name(t_quotes, replace)
display as text "rc = " _rc "  (subtitle: Identification / Calorías 'diarias' consumidas)"
label variable calories `"`original_label'"'        // restore

display as text _newline "== 2.14d Text size: series, ACF and PACF should look alike"
capture noisily bj calories, name(t_iscale, replace)
display as text "rc = " _rc "  (check axis labels visually)"
capture noisily bj calories, combopts(iscale(0.8)) name(t_iscale08, replace)
display as text "rc = " _rc "  (all text larger than the default iscale(0.5))"

display as text _newline "== 2.14g Default titles AC / PAC, no y-axis title; user override"
capture noisily bj calories, name(t_acpac_titles, replace)
display as text "rc = " _rc "  (titles AC and PAC, no y-axis titles)"
capture noisily bj calories, acopts(title("Autocorrelation") ytitle("r(k)")) name(t_acpac_user, replace)
display as text "rc = " _rc "  (ACF: user title and y-axis title)"

display as text _newline "== 2.14h Default navy color and small markers; user override"
capture noisily bj calories, name(t_navy, replace)
display as text "rc = " _rc "  (navy line, navy spikes, very small markers)"
capture noisily bj calories, tsopts(lcolor(maroon)) acopts(lcolor(maroon) mcolor(maroon) msize(medium)) name(t_maroon, replace)
display as text "rc = " _rc "  (maroon series and AC; PAC stays navy)"

display as text _newline "== 2.14i Panel 2: Dickey-Fuller (none, constant, trend) and arimasoc"
display as text "Expected values (compare with the panel):"
dfuller calories, noconstant
dfuller calories
dfuller calories, trend
return list                                            // check r(cv_5), r(p)
arimasoc calories, maxar(4) maxma(4)              // 25 models
return list                                            // check r(aic_sel), r(ar_max)
matrix list r(table)                                   // check column names
capture noisily bj calories, name(t_panel2, replace)
display as text "rc = " _rc

display as text _newline "== 2.14k Default ARMA search by frequency (daily data: max AR 4, MA 4)"
timer clear 1
timer on 1
capture noisily bj calories, name(t_arma_default, replace)
timer off 1
display as text "rc = " _rc "  (ARMA search: max AR 4, MA 4; DF lags 0)"
timer list 1                                           // running time

display as text _newline "== 2.14l ARMA search: user maxar()/maxma() replace the default"
capture noisily bj calories, socopts(maxar(2) maxma(2)) name(t_arma_22, replace)
display as text "rc = " _rc "  (ARMA search: max AR 2, MA 2)"
capture noisily bj calories, socopts(maxar(6) maxma(2)) name(t_arma_62, replace)
display as text "rc = " _rc "  (ARMA search: max AR 6, MA 2)"
capture noisily bj calories, socopts(maxar(8) maxma(8)) name(t_arma_88, replace)
display as text "rc = " _rc "  (ARMA search: max AR 8, MA 8; weekly default)"

display as text _newline "== 2.14j Panel 2 with dflags() and socopts(), on D."
capture noisily bj D.calories, dflags(12) socopts(maxar(3) maxma(3)) name(t_panel2_d, replace)
display as text "rc = " _rc "  (DF lags 12; ARMA search max AR 3, MA 3)"

display as text _newline "== 2.14e Figure size: default and user override"
capture noisily bj calories, name(t_size, replace)
display as text "rc = " _rc "  (letter proportion 8.5 x 11; three rows of equal height)"
capture noisily bj calories, noinfo name(t_size_noinfo, replace)
display as text "rc = " _rc "  (xsize(8.5) ysize(7.33))"
capture noisily bj calories, combopts(xsize(5) ysize(6)) name(t_size_user, replace)
display as text "rc = " _rc "  (user size wins)"

display as text _newline "== 2.14f Text panels: titles, no grid, placeholder below the PACF"
capture noisily bj calories, name(t_panels, replace)
display as text "rc = " _rc "  (Data description | Unit root and ARMA selection; white, no grid)"

display as text _newline "== 2.14m Letter-size PDF by default"
capture noisily bj calories, name(t_letter, replace) export(bj_test_letter, replace)
display as text "rc = " _rc "  (open bj_test_letter.pdf: 8.5 x 11 in)"

display as text _newline "== 2.15 export(): no extension -> pdf"
capture erase bj_test_fig.pdf
capture noisily bj calories, name(t_export, replace) export(bj_test_fig, replace)
display as text "rc = " _rc
capture confirm file bj_test_fig.pdf
display as text "bj_test_fig.pdf exists: " as result cond(_rc == 0, "yes", "NO")

display as text _newline "== 2.16 export(): user name and png"
capture noisily bj calories, name(my_figure, replace) export("bj test fig.png", replace)
display as text "rc = " _rc
capture confirm file "bj test fig.png"
display as text "bj test fig.png exists: " as result cond(_rc == 0, "yes", "NO")

display as text _newline "== 2.17 export() without replace on an existing file: error 602"
capture noisily bj calories, name(t_export2, replace) export(bj_test_fig)
display as text "rc = " _rc "  (expected: 602)"

display as text _newline "== 2.18 Graphs in memory (only bj_id, t_* and my_figure should remain)"
graph dir

* ---------------------------------------------------------------------------
* 2.19 Non-stationary series: gnp96 (quarterly real GNP)
*      levels: the ACF decays slowly and Dickey-Fuller does not reject the
*      unit root; first difference: stationary
* ---------------------------------------------------------------------------
sysuse gnp96, clear
tsset date                      // quarterly

display as text _newline "== 2.19a Levels: unit root expected (quarterly: max AR 2, MA 2; 8 lags)"
dfuller gnp96, trend                                   // expected: H0 not rejected
capture noisily bj gnp96, name(t_gnp_levels, replace)
display as text "rc = " _rc "  (AC decays slowly; DF trend: Z(t) > cv)"

display as text _newline "== 2.19b First difference: stationary"
dfuller D.gnp96                                        // expected: H0 rejected
capture noisily bj D.gnp96, name(t_gnp_diff, replace)
display as text "rc = " _rc "  (subtitle: ... (D.gnp96); DF constant: Z(t) < cv)"

display as text _newline "== 2.19c First difference with order(1 0): ARIMA(1,1,0)"
capture noisily bj D.gnp96, order(1 0)
display as text "rc = " _rc "  (bj_est note: ARMA(1,0), user)"
capture noisily bj D.gnp96, order(1 0) horizon(8)
display as text "rc = " _rc "  (forecast: 8 quarters (user))"

display as text _newline "== 2.19d arima(arima(1,1,0)) in levels: fit and forecast of gnp96"
capture noisily bj gnp96, arima(arima(1,1,0)) horizon(8) name(t_gnp_arima, replace)
display as text "rc = " _rc "  (note: user specification arima(1,1,0); in levels; no band)"

* ---------------------------------------------------------------------------
* 2.20 Option arima() and independent variables: tsline2
* ---------------------------------------------------------------------------
sysuse tsline2, clear
tsset day

display as text _newline "== 2.20a arima(ar(1) ma(1)): same model as order(1 1)"
capture noisily bj calories, arima(ar(1) ma(1)) name(t_arima_arma, replace)
display as text "rc = " _rc "  (note: user specification ar(1) ma(1); band drawn)"

display as text _newline "== 2.20b Seasonal term: arima(ar(1) sarima(1,0,0,7))"
capture noisily bj calories, arima(ar(1) sarima(1,0,0,7)) name(t_arima_sar, replace)
display as text "rc = " _rc "  (D = 0: forecast with band)"

display as text _newline "== 2.20c Seasonal difference: arima(ar(1) sarima(0,1,1,7))"
capture noisily bj calories, arima(ar(1) sarima(0,1,1,7)) name(t_arima_sdif, replace)
display as text "rc = " _rc "  (D = 1: forecast in levels, no band)"

display as text _newline "== 2.20d Independent variable without values after the sample: held at its last value"
capture noisily bj calories ucalories, arima(ar(1)) name(t_arimax_nofc, replace)
display as text "rc = " _rc "  (19 periods; note: covariates held at their last value)"

display as text _newline "== 2.20e Independent variable with values for 7 days after the sample"
preserve
tsappend, add(7)
replace ucalories = L7.ucalories if missing(ucalories)
capture noisily bj calories ucalories, arima(ar(1)) horizon(10) name(t_arimax_fc, replace)
display as text "rc = " _rc "  (10 periods: 7 user values, 3 held at the last value; note says held)"
restore

display as text _newline "== 2.20f order() and arima() together: error 198"
capture noisily bj calories, order(1 1) arima(ar(1)) name(t_arima_err, replace)
display as text "rc = " _rc "  (expected: 198)"

display as text _newline "== 2.20g id with indepvars: identification of calories only"
capture noisily bj calories ucalories, id name(t_arimax_id, replace)
display as text "rc = " _rc "  (bj_id of calories; no bj_est)"

display as text _newline "== 2.20h subtitle() and estsubtitle(): own subtitles in both figures"
capture noisily bj calories, subtitle("Identification" "Daily calories, 2002") ///
	estsubtitle("Estimation" "Daily calories, 2002") name(t_subtitles, replace)
display as text "rc = " _rc "  (bj_id: Identification / Daily calories, 2002; bj_est: Estimation / ...)"

display as text _newline "== 2.20i estsubtitle() only: bj_id keeps its default subtitle"
capture noisily bj calories, estsubtitle("My estimation subtitle") name(t_estsub, replace)
display as text "rc = " _rc "  (bj_id: Identification / label; bj_est: My estimation subtitle)"

sysuse gnp96, clear
tsset date

* ---------------------------------------------------------------------------
* 3. Expected errors
* ---------------------------------------------------------------------------
display as text _newline "== 3.1 Data not tsset: should return error 111"
tsset, clear
capture noisily bj gnp96
display as text "rc = " _rc "  (expected: 111)"

* ---------------------------------------------------------------------------
* 4. Help file
* ---------------------------------------------------------------------------
help bj

log close
