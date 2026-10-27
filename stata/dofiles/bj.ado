*! version 0.2.0  26oct2026  Rodrigo Taborda
*  0.1.0  17oct2024  first version: tsline + ac + pac combined
*  0.2.0  26oct2026  if/in honored; ts operators in graph names; sub-option
*                    design (tsopts/acopts/pacopts/combopts); lags/level;
*                    temporary graph names with guaranteed cleanup

program define bj
	version 18

	syntax varname(numeric ts) [if] [in] [,       ///
		LAGs(numlist integer max=1 >0)            /// lags for ac and pac
		LEVel(cilevel)                            /// confidence level
		TItle(string asis)                        /// combined graph
		SUBtitle(string asis)                     ///
		NOTE(string asis)                         ///
		CAPtion(string asis)                      ///
		TSOPTs(string asis)                       /// options for tsline
		ACOPTs(string asis)                       /// options for ac
		PACOPTs(string asis)                      /// options for pac
		COMBOPTs(string asis)                     /// options for graph combine
		NAME(string asis)                         ///
		SAVing(string asis)                       ///
		]

	* ---- sample and time-series checks ------------------------------------
	quietly tsset                     // error 111 if data are not tsset
	marksample touse
	quietly count if `touse'
	if r(N) == 0 error 2000

	* ---- build option strings ---------------------------------------------
	if "`lags'" != "" local lagsopt lags(`lags')

	if `"`title'"' == "" local title `""Box-Jenkins: `varlist'""'
	if `"`subtitle'"' != "" local subopt  subtitle(`subtitle')
	if `"`note'"'     != "" local noteopt note(`note')
	if `"`caption'"'  != "" local capopt  caption(`caption')

	if `"`name'"' == "" {
		local gname = strtoname("bj_`varlist'")   // D.y -> bj_D_y
		local name `gname', replace
	}
	local nameopt name(`name')
	if `"`saving'"' != "" local savopt saving(`saving')

	* ---- individual graphs, then combine ----------------------------------
	tempname g_ts g_ac g_pac g_acpac

	capture noisily {
		tsline `varlist' if `touse', nodraw                   ///
			xtitle("") `tsopts' name(`g_ts')

		ac `varlist' if `touse', nodraw                       ///
			`lagsopt' level(`level') `acopts' name(`g_ac')

		pac `varlist' if `touse', nodraw                      ///
			`lagsopt' level(`level') `pacopts' name(`g_pac')

		graph combine `g_ac' `g_pac', rows(1) nodraw name(`g_acpac')

		graph combine `g_ts' `g_acpac', cols(1)               ///
			title(`title') `subopt' `noteopt' `capopt'        ///
			`combopts' `nameopt' `savopt'
	}
	local rc = _rc

	* ---- always remove the intermediate graphs ----------------------------
	foreach g in `g_ts' `g_ac' `g_pac' `g_acpac' {
		capture graph drop `g'
	}
	exit `rc'
end
