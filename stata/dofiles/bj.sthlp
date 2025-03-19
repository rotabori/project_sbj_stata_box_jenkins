{smcl}
{* *! version 0.1 20241017}{...}
{cmd:help bj}
{hline}

{title:Title}

{p2colset 8 18 20 2}{...}
{p2col :{hi:bj} {hline 2}} Graphs Box - Jenkins diagnostics and arima estimation{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:bj} {varlist} {ifin}

{p 4 6 2}
{it:varlist} may contain time-series operators; see {help tsvarlist}.{p_end}


{title:Description}

{pstd}{cmd:bj} gathers graphical information related to the time series identification methodology Box-Jenkins. Graphs the time series, 
auto-correlation function and partial auto-correlation function. A table with model selection models is also shown (optional), based on 
information criteria, using the output of command XXX. This is a publication graph ready time series analysis mainly for teaching and consulting purposes.


{title:Options}

{phang}{opt dif} estimates model in first difference.


{title:Examples}

{phang}{stata "use https://rodrigotaborda.com/ad/data/trafico_carreteras/trafico_carreteras_2003-2024_nacional.dta, clear" : . Load colombia's road traffic}{p_end}
{phang}{stata "bj trafico_peaje" : . bj trafico_peaje}


{title:Author}

{phang}Rodrigo Taborda, Universidad de los Andes{break}
r.taborda@uniandes.edu.co{p_end}


{title:Also see}

{psee}
Online: {manhelp summarize R}, {manhelp pctile D}
{p_end}
