*! version 0.1 20241017 Rodrigo Taborda

#delimit ;

program bj;
    version 18;

    syntax varlist(max=1 numeric ts) [if] [in];
        marksample touse;
        quietly count if `touse';
            if `r(N)' == 0 {;
                error 2000;
                };

    tsline `varlist'
        ,
        nodraw
        name(tsline_`varlist', replace)
        ;
        
    ac `varlist'
        ,
        title(AC)
        nodraw
        name(ac_`varlist', replace)
        ;

    pac `varlist'
        ,
        nodraw
        name(pac_`varlist', replace)
        ;

    graph combine ac_`varlist' pac_`varlist'
        ,
        rows(1)
        nodraw
        name(ac_pac_`varlist', replace)
        ;

    graph combine tsline_`varlist' ac_pac_`varlist'
        ,
        cols(1)
        name(tsline_ac_pac_`varlist', replace)
        ;

    graph drop tsline_`varlist' ac_`varlist' pac_`varlist';

end;



