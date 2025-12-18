

// Setup
clear all
set more off

global downloads "C:\Users\mwballif\Downloads"
global clean_data "C:\Users\mwballif\Box\esop-tax-credit-did\data\clean_data"
global tabfig "C:\Users\mwballif\Box\esop-tax-credit-did\tabfig"

use "$clean_data/esop_state_panel", clear
* keep only the usable years
keep if inrange(year, 2011, 2025)

gen missing_y = missing(esop_tot_active_partcp_cnt)
list state_fips year if missing_y==1


findit synth_runner
* set panel structure
tsset state_fips year

synth esop_tot_active_partcp_cnt ///
    esop_tot_active_partcp_cnt(2016) ///
    esop_tot_active_partcp_cnt(2015) ///
    esop_tot_active_partcp_cnt(2014) ///
    esop_tot_active_partcp_cnt(2013) ///
    esop_tot_active_partcp_cnt(2012), ///
    trunit(8) trperiod(2017) ///
    mspeperiod(2012(1)2016) ///
    resultperiod(2011(1)2025) ///
    fig

*******************************************************
* Synthetic Control with Placebo Tests (Fixed)
*******************************************************
*******************************************************
* Synthetic Control with Placebo Tests (Fixed)
*******************************************************
clear all
set more off

global clean_data "C:\Users\mwballif\Box\esop-tax-credit-did\data\clean_data"
cd "$clean_data"

use "esop_state_panel.dta", clear
keep if inrange(year, 2011, 2025)
tsset state_fips year

local treated = 8
local trperiod = 2017
local outcomes esop_partcp_rate esop_firm esop_tot_active_partcp_cnt ///
               esop_tot_assets_boy_amt esop_tot_partcp_boy_cnt tot_assets_boy_amt

foreach yvar of local outcomes {

    * Treated
    synth `yvar' `yvar'(2016) `yvar'(2015) `yvar'(2014) `yvar'(2013) `yvar'(2012), ///
        trunit(`treated') trperiod(`trperiod') mspeperiod(2012(1)2016) resultperiod(2011(1)2025) keep(synth)
    use "synthout_`yvar'.dta", clear
    rename synth synth_`yvar'_`treated'
    merge 1:1 state_fips year using "esop_state_panel.dta", nogenerate
    gen gap_`yvar'_`treated' = `yvar' - synth_`yvar'_`treated'

    * Placebos
    levelsof state_fips, local(states)
    foreach s of local states {
        if `s' == `treated' continue
        synth `yvar' `yvar'(2016) `yvar'(2015) `yvar'(2014) `yvar'(2013) `yvar'(2012), ///
            trunit(`s') trperiod(`trperiod') mspeperiod(2012(1)2016) resultperiod(2011(1)2025) keep(synth)
        use "synthout_`yvar'.dta", clear
        rename synth synth_`yvar'_`s'
        merge 1:1 state_fips year using "esop_state_panel.dta", nogenerate
        gen gap_`yvar'_`s' = `yvar' - synth_`yvar'_`s'
    }

    * Plot
    local placebo_lines
    foreach s of local states {
        if `s' == `treated' continue
        local placebo_lines `placebo_lines' (line gap_`yvar'_`s' year, lcolor(gs10) lwidth(thin))
    }

    twoway (line gap_`yvar'_`treated' year, lcolor(blue) lwidth(medthick)) `placebo_lines', ///
        title("Placebo Test - `yvar'") yline(0, lpattern(dash)) xtitle("Year") ytitle("Gap")
    graph display
}
