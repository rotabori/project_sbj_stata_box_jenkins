*! bj_test.do  26oct2026  tests for bj.ado v0.2
*  Usage: place bj.ado and bj.sthlp in your PERSONAL ado directory (see: sysdir)
*         and run:  do bj_test.do

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
* 1. Data
* ---------------------------------------------------------------------------
use "https://rodrigotaborda.com/ad/data/trafico_carreteras/trafico_carreteras_2003-2024_nacional.dta", clear
tsset                           // confirm the time variable

* ---------------------------------------------------------------------------
* 2. Test cases
*    capture noisily: if a case fails, the error is shown and the do-file
*    continues with the next case
* ---------------------------------------------------------------------------
graph drop _all

display as text _newline"== 2.1 Basic use"
capture noisily bj trafico_peaje
display as text "rc = " _rc

display as text _newline"== 2.2 Time-series operator + options"
capture noisily bj D.trafico_peaje, lags(24) level(90)
display as text "rc = " _rc

display as text _newline"== 2.3 Is the in qualifier honored?"
capture noisily bj trafico_peaje in 1/100
display as text "rc = " _rc

display as text _newline"== 2.4 Sub-options"
capture noisily bj trafico_peaje, acopts(title("ACF")) note("x")
display as text "rc = " _rc

display as text _newline"== 2.5 Graphs in memory (only bj_* should remain)"
graph dir

* ---------------------------------------------------------------------------
* 3. Expected errors
* ---------------------------------------------------------------------------
display as text _newline"== 3.1 Data not tsset: should return error 111"
tsset, clear
capture noisily bj trafico_peaje
display as text "rc = " _rc "  (expected: 111)"

* ---------------------------------------------------------------------------
* 4. Help file
* ---------------------------------------------------------------------------
help bj

log close
