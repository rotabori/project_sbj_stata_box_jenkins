*! version 0.1 20241017 Rodrigo Taborda

program bj

version 18

syntax varlist(max=1 numeric ts) [if] [in], ///
        [TItle(string asis)]                     /// Title for the combined graph
        [SUBtitle(passthru)]                  /// Subtitle for the combined graph
        [XTitle(passthru)]                    /// X-axis title
        [YTitle(passthru)]                    /// Y-axis title
        [XLabel(passthru)]                    /// X-axis labels
        [YLabel(passthru)]                    /// Y-axis labels
        [NOTE(passthru)]                      /// Add a note to the combined graph
        [CAPtion(passthru)]                   /// Add a caption to the combined graph
        [REName(passthru)]                    /// Rename individual graphs
        [TSLTitle(string)]                    /// Title for the tsline graph
        [TSLSubtitle(string)]                 /// Subtitle for the tsline graph
        [TSLNote(string)]                     /// Note for the tsline graph
        [TSLCaption(string)]                  /// Caption for the tsline graph
        [ACTitle(string)]                     /// Title for the ac graph
        [ACSubtitle(string)]                  /// Subtitle for the ac graph
        [ACNote(string)]                      /// Note for the ac graph
        [ACCaption(string)]                   /// Caption for the ac graph
        [PACTitle(string)]                    /// Title for the pac graph
        [PACSubtitle(string)]                 /// Subtitle for the pac graph
        [PACNote(string)]                     /// Note for the pac graph
        [PACCaption(string)]                  /// Caption for the pac graph
        [*]                                   /// Other graph options

marksample touse

quietly count if `touse'
    if `r(N)' == 0 {
        error 2000
        }

    tsline `varlist', nodraw ///
        title("`tsltitle'") subtitle("`tslsubtitle'") ///
        note("`tslnote'") caption("`tslcaption'") ///
        xtitle("") ///
        `xtitle' `ytitle' `xlabel' `ylabel' `rename' `options' ///
        name(tsline_`varlist', replace)

    ac `varlist', nodraw ///
        title("`actitle'") subtitle("`acsubtitle'") ///
        note("`acnote'") caption("`accaption'") ///
        `xtitle' `ytitle' `xlabel' `ylabel' `rename' `options' ///
        name(ac_`varlist', replace)
        
    pac `varlist', nodraw ///
        title("`pactitle'") subtitle("`pacsubtitle'") ///
        note("`pacnote'") caption("`paccaption'") ///
        `xtitle' `ytitle' `xlabel' `ylabel' `rename' `options' ///
        name(pac_`varlist', replace)

    graph combine ac_`varlist' pac_`varlist', nodraw ///
        rows(1) ///
        name(ac_pac_`varlist', replace) ///

    local bj_title = cond("`title'" != "", "`title'", "Box-Jenkins for `varlist'") ///
    
    graph combine tsline_`varlist' ac_pac_`varlist', ///
        cols(1) ///
        title("`bj_title'") ///
        name(tsline_ac_pac_`varlist', replace) ///

    graph drop tsline_`varlist' ac_`varlist' pac_`varlist' ///

end



