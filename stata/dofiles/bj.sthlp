{smcl}
{* *! version 0.2.0  26oct2026}{...}
{vieweralsosee "[TS] corrgram" "help corrgram"}{...}
{vieweralsosee "[TS] tsline" "help tsline"}{...}
{vieweralsosee "[G-2] graph combine" "help graph combine"}{...}
{vieweralsosee "[TS] arima" "help arima"}{...}
{viewerjumpto "Syntax" "bj##syntax"}{...}
{viewerjumpto "Description" "bj##description"}{...}
{viewerjumpto "Options" "bj##options"}{...}
{viewerjumpto "Remarks" "bj##remarks"}{...}
{viewerjumpto "Examples" "bj##examples"}{...}
{viewerjumpto "Author" "bj##author"}{...}
{title:Title}

{p2colset 5 11 13 2}{...}
{p2col:{cmd:bj} {hline 2}}Box{c -}Jenkins identification graph: time series,
ACF and PACF in one figure{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:bj} {varname} {ifin} [{cmd:,} {it:options}]

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt lag:s(#)}}number of lags in the ACF and PACF; default as in
{helpb corrgram}{p_end}
{synopt:{opt lev:el(#)}}confidence level for the bands; default is
{cmd:level(95)}{p_end}

{syntab:Combined graph}
{synopt:{opt ti:tle(tinfo)}}overall title; default is
{cmd:"Box-Jenkins:} {it:varname}{cmd:"}{p_end}
{synopt:{opt sub:title(tinfo)}}overall subtitle{p_end}
{synopt:{opt note(tinfo)}}overall note{p_end}
{synopt:{opt cap:tion(tinfo)}}overall caption{p_end}
{synopt:{opt name(name[, replace])}}name of the combined graph; default is
{cmd:bj_}{it:varname}{cmd:, replace}{p_end}
{synopt:{opt sav:ing(filename[, replace])}}save the combined graph to disk{p_end}
{synopt:{opt combopt:s(options)}}other options passed to
{helpb graph combine}{p_end}

{syntab:Individual graphs}
{synopt:{opt tsopt:s(options)}}options passed to {helpb tsline}{p_end}
{synopt:{opt acopt:s(options)}}options passed to {helpb ac}{p_end}
{synopt:{opt pacopt:s(options)}}options passed to {helpb pac}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
You must {helpb tsset} your data before using {cmd:bj}.{p_end}
{p 4 6 2}
{it:varname} may contain time-series operators; see {help tsvarlist}.
For example, {cmd:bj D.y} analyzes the first difference of {cmd:y}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:bj} gathers in a single, publication-ready figure the graphical
information used in the identification stage of the Box{c -}Jenkins
methodology: the time plot of the series (top) and its autocorrelation and
partial autocorrelation functions (bottom), with confidence bands. It is
intended mainly for teaching and consulting.

{pstd}
{cmd:bj} is a wrapper: it calls {helpb tsline}, {helpb ac} and {helpb pac},
and joins their output with {helpb graph combine}.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt lags(#)} specifies the number of lags shown in both the ACF and the
PACF.

{phang}
{opt level(#)}; see {helpb level:[R] level}. Applies to both the ACF and the
PACF bands.

{dlgtab:Combined graph}

{phang}
{opt title()}, {opt subtitle()}, {opt note()} and {opt caption()} apply to the
combined figure; see {manhelpi title_options G-3}.

{phang}
{opt name()} and {opt saving()}; see {manhelpi name_option G-3} and
{manhelpi saving_option G-3}.

{phang}
{opt combopts(options)} passes any other option to the final
{cmd:graph combine}, for example {cmd:combopts(ysize(6) xsize(5))}.

{dlgtab:Individual graphs}

{phang}
{opt tsopts(options)}, {opt acopts(options)} and {opt pacopts(options)} pass
options to each of the three graphs. Any option accepted by the corresponding
command is allowed, such as {cmd:title()}, {cmd:ytitle()}, {cmd:xlabel()} or
{cmd:note()}. Do not specify {cmd:lags()} or {cmd:level()} here; use the main
options instead.


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:ac} and {cmd:pac} require a sample without gaps. If {cmd:if} or
{cmd:in} produce gaps in the time variable, {cmd:bj} stops with the error
message of {cmd:ac}.

{pstd}
Stata computes the PACF from a sequence of regressions; therefore the first
partial autocorrelation need not equal the first autocorrelation. See
{it:Methods and formulas} in {manlink TS corrgram}.


{marker examples}{...}
{title:Examples}

{pstd}Setup: Colombia's road traffic{p_end}
{phang2}{stata "use https://rodrigotaborda.com/ad/data/trafico_carreteras/trafico_carreteras_2003-2024_nacional.dta, clear":. use .../trafico_carreteras_2003-2024_nacional.dta, clear}{p_end}

{pstd}Basic use{p_end}
{phang2}{stata "bj trafico_peaje":. bj trafico_peaje}{p_end}

{pstd}First difference, 24 lags, 90% bands{p_end}
{phang2}{stata "bj D.trafico_peaje, lags(24) level(90)":. bj D.trafico_peaje, lags(24) level(90)}{p_end}

{pstd}Customizing the individual graphs{p_end}
{phang2}{cmd:. bj trafico_peaje, tsopts(title("Series")) acopts(title("ACF")) pacopts(title("PACF")) note("Source: own calculations")}{p_end}


{marker author}{...}
{title:Author}

{pstd}
Rodrigo Taborda, Universidad de los Andes{break}
{browse "mailto:r.taborda@uniandes.edu.co":r.taborda@uniandes.edu.co}


{title:Also see}

{psee}
Online: {manhelp corrgram TS}, {manhelp tsline TS}, {manhelp graph_combine G-2:graph combine},
{manhelp arima TS}
{p_end}
