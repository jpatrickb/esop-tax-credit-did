
// Author: Mitchell Ballif
// Date: 2025-11-18
// Purpose: Event studies and synthetic control placebo tests for state level outcomes
********************************************************************************

// Setup
clear all
set more off

global clean_data "C:\Users\mwballif\Box\esop-tax-credit-did\data\clean_data"
global tabfig "C:\Users\mwballif\Box\esop-tax-credit-did\tabfig"
global int_data "C:\Users\mwballif\Box\esop-tax-credit-did\data\int_data"

// Define output folder
local output "$tabfig\identification tests"

// Define outcomes to test
local outcomes "esop_firm_share num_esop_firms state_esop_partcp_rate num_transitions esop_tot_active_partcp_cnt esop_tot_assets_boy_amt esop_tot_partcp_boy_cnt"

// Define outcome labels for graphs
local l_esop_firm_share "ESOP Firm Share"
local l_num_esop_firms "Number of ESOP Firms"
local l_state_esop_partcp_rate "State ESOP Participation Rate"
local l_num_transitions "Number of ESOP Transitions"
local l_esop_tot_active_partcp_cnt "Total Active ESOP Participants"
local l_esop_tot_assets_boy_amt "Total ESOP Assets (BOY)"
local l_esop_tot_partcp_boy_cnt "Total ESOP Participants (BOY)"

********************************************************************************
// FINAL DRAFT FIGS: COLORADO VS UTAH 2017 EVENT STUDY
********************************************************************************

use "$clean_data/esop_state_panel", clear
    
// Keep only Colorado and Utah
keep if inlist(state_fips, 8, 49)

// Create treatment timing variables
gen credit_start = 2017
gen tdate = year - credit_start

// Define dummies for distance from treatment start
forval i = 1/15 {
    gen t_n`i' = tdate == -`i'
    gen t_p`i' = tdate == `i'
    
    gen co_t_n`i' = CO * t_n`i'
    gen co_t_p`i' = CO * t_p`i'
}
gen t_0 = tdate == 0
gen co_t0 = CO * t_0

format esop_tot_assets_eoy_amt %20.2f
gen esop_assets_millions = esop_tot_assets_eoy_amt / 1000000
// Run event study on sample 5 years before and 5 after
reghdfe esop_assets_millions co_t_n5 co_t_n4 co_t_n3 co_t_n2 ///
    o.co_t_n1 co_t0 co_t_p1 co_t_p2 co_t_p3 co_t_p4 co_t_p5 ///
    if tdate >= -5 & tdate <= 5, absorb(year) 
    
// Plot coefficients directly
coefplot, keep(co_t_*) vertical omitted ///
    yline(0, lcolor(red) lpattern(dash)) ///
    xline(6, lpattern(dash) lcolor(gray)) ///
    xtitle("Years Relative to 2016") ///
    ytitle("Effect on Assets (Millions USD)") ///
    graphregion(color(white)) ///
    ciopts(recast(rcap)) ///
    xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "1" 8 "2" 9 "3" 10 "4" 11 "5+", angle(0))
    
graph export "$tabfig/final_draft_figs/state_event_study_esop_assets.png", replace

// Run event study on sample 5 years before and 5 after
reghdfe num_esop_firms co_t_n5 co_t_n4 co_t_n3 co_t_n2 ///
    o.co_t_n1 co_t0 co_t_p1 co_t_p2 co_t_p3 co_t_p4 co_t_p5 ///
    if tdate >= -5 & tdate <= 5, absorb(year) 
    
// Plot coefficients directly
coefplot, keep(co_t_*) vertical omitted ///
    yline(0, lcolor(red) lpattern(dash)) ///
    xline(6, lpattern(dash) lcolor(gray)) ///
    xtitle("Years Relative to 2016") ///
    ytitle("Effect on ESOP firms") ///
    graphregion(color(white)) ///
    ciopts(recast(rcap)) ///
    xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "1" 8 "2" 9 "3" 10 "4" 11 "5+", angle(0))
    
graph export "$tabfig/final_draft_figs/state_event_study_esop_firms.png", replace

// Run event study on sample 5 years before and 5 after
reghdfe esop_tot_active_partcp_cnt co_t_n5 co_t_n4 co_t_n3 co_t_n2 ///
    o.co_t_n1 co_t0 co_t_p1 co_t_p2 co_t_p3 co_t_p4 co_t_p5 ///
    if tdate >= -5 & tdate <= 5, absorb(year) 
    
// Plot coefficients directly
coefplot, keep(co_t_*) vertical omitted ///
    yline(0, lcolor(red) lpattern(dash)) ///
    xline(6, lpattern(dash) lcolor(gray)) ///
    xtitle("Years Relative to 2016") ///
    ytitle("Effect on Participants") ///
    graphregion(color(white)) ///
    ciopts(recast(rcap)) ///
    xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "1" 8 "2" 9 "3" 10 "4" 11 "5+", angle(0))
    
graph export "$tabfig/final_draft_figs/state_event_study_esop_participants.png", replace
********************************************************************************
// EVENT STUDY: COLORADO 2017 - ALL OUTCOMES
********************************************************************************

foreach outcome of local outcomes {
    
    use "$clean_data/esop_state_panel", clear
    
    // Create treatment timing variables
    gen credit_start = 2017
    gen tdate = year - credit_start
    
    // Define dummies for distance from treatment start
    forval i = 1/15 {
        gen t_neg`i' = tdate == -`i'
        gen t_pos`i' = tdate == `i'
        
        gen co_t_neg`i' = CO * t_neg`i'
        gen co_t_pos`i' = CO * t_pos`i'
    }
    
    gen t_0 = tdate == 0
    gen co_t0 = CO * t_0 
    
    // Run event study on sample 5 years before and 5 after
    reghdfe `outcome' co_t_neg5 co_t_neg4 co_t_neg3 co_t_neg2 ///
        o.co_t_neg1 co_t0 co_t_pos1 co_t_pos2 co_t_pos3 co_t_pos4 co_t_pos5 ///
        if tdate >= -5 & tdate <= 5, absorb(year state_fips) vce(cluster state_fips)
    
    // Plot coefficients directly
    coefplot, keep(co_t_*) vertical ///
        yline(0, lcolor(red)) ///
        xline(4.5, lpattern(dash) lcolor(gray)) ///
        title("Event Study: Colorado ESOP Treatment 2017" "Outcome: `l_`outcome''") ///
        subtitle("CO VS U.S.") ///
		xtitle("Years Relative to Treatment (t=-1 is reference)") ///
        ytitle("Effect on `l_`outcome''") ///
        graphregion(color(white)) ///
        ciopts(recast(rcap))
        
    graph export "`output'/event_study_`outcome'.png", replace
}


********************************************************************************
// SYNTHETIC CONTROL: COLORADO - ALL OUTCOMES
********************************************************************************

foreach outcome of local outcomes {
    
    use "$clean_data/esop_state_panel", clear
    xtset state_fips year
    
    // Run synthetic control with multiple pre-treatment predictors
    quietly capture synth `outcome' ///
        `outcome'(2013) `outcome'(2014) `outcome'(2015) `outcome'(2016), ///
        trunit(8) trperiod(2017) ///
        mspeperiod(2013(1)2016) resultsperiod(2013(1)2024) ///
        keep("$int_data/synth_`outcome'.dta", replace)
    
    if _rc == 0 {
        display "Synthetic control successful for `outcome'"
    }
    else {
        display "Synthetic control failed for `outcome'"
    }
}

********************************************************************************
// EVENT STUDY: COLORADO VS UTAH 2017 - ALL OUTCOMES
********************************************************************************

foreach outcome of local outcomes {
    
    use "$clean_data/esop_state_panel", clear
    
    // Keep only Colorado and Utah
    keep if inlist(state_fips, 8, 49)
    
    // Create treatment timing variables
    gen credit_start = 2017
    gen tdate = year - credit_start
    
    // Define dummies for distance from treatment start
    forval i = 1/15 {
        gen t_neg`i' = tdate == -`i'
        gen t_pos`i' = tdate == `i'
        
        gen co_t_neg`i' = CO * t_neg`i'
        gen co_t_pos`i' = CO * t_pos`i'
    }
    
    gen t_0 = tdate == 0
    gen co_t0 = CO * t_0 
    
    // Run event study on sample 5 years before and 5 after
    reghdfe `outcome' co_t_neg5 co_t_neg4 co_t_neg3 co_t_neg2 ///
        o.co_t_neg1 co_t0 co_t_pos1 co_t_pos2 co_t_pos3 co_t_pos4 co_t_pos5 ///
        if tdate >= -5 & tdate <= 5, absorb(year ) 
    
    // Plot coefficients directly
    coefplot, keep(co_t_*) vertical ///
        yline(0, lcolor(red)) ///
        xline(4.5, lpattern(dash) lcolor(gray)) ///
        title("Event Study: Colorado ESOP Treatment 2017" "Outcome: `l_`outcome''") ///
        subtitle("Colorado vs Utah") ///
        xtitle("Years Relative to Treatment (t=-1 is reference)") ///
        ytitle("Effect on `label_`outcome''") ///
        graphregion(color(white)) ///
        ciopts(recast(rcap))
        
    graph export "`output'/event_study_CO_vs_UT_`outcome'.png", replace
}

********************************************************************************
// EVENT STUDY: COLORADO VS ARIZONA 2017 - ALL OUTCOMES
********************************************************************************

foreach outcome of local outcomes {
    
    use "$clean_data/esop_state_panel", clear
    
    // Keep only Colorado and Arizona
    keep if inlist(state_fips, 8, 4)
    
    // Create treatment timing variables
    gen credit_start = 2017
    gen tdate = year - credit_start
    
    // Define dummies for distance from treatment start
    forval i = 1/15 {
        gen t_neg`i' = tdate == -`i'
        gen t_pos`i' = tdate == `i'
        
        gen co_t_neg`i' = CO * t_neg`i'
        gen co_t_pos`i' = CO * t_pos`i'
    }
    
    gen t_0 = tdate == 0
    gen co_t0 = CO * t_0 
    
    // Run event study on sample 5 years before and 5 after
    reghdfe `outcome' co_t_neg5 co_t_neg4 co_t_neg3 co_t_neg2 ///
        o.co_t_neg1 co_t0 co_t_pos1 co_t_pos2 co_t_pos3 co_t_pos4 co_t_pos5 ///
        if tdate >= -5 & tdate <= 5, absorb(year ) vce(cluster state_fips)
    
    // Plot coefficients directly
    coefplot, keep(co_t_*) vertical ///
        yline(0, lcolor(red)) ///
        xline(4.5, lpattern(dash) lcolor(gray)) ///
        title("Event Study: Colorado ESOP Treatment 2017" "Outcome: `l_`outcome''") ///
        subtitle("Colorado vs Arizona") ///
        xtitle("Years Relative to Treatment (t=-1 is reference)") ///
        ytitle("Effect on `label_`outcome''") ///
        graphregion(color(white)) ///
        ciopts(recast(rcap))
        
    graph export "`output'/event_study_CO_vs_AZ_`outcome'.png", replace
}
********************************************************************************
// PLACEBO TEST: RUN SYNTH FOR ALL STATES - ALL OUTCOMES
********************************************************************************

foreach outcome of local outcomes {
    
    display "Running placebo test for `outcome'..."
    
    use "$clean_data/esop_state_panel", clear
    xtset state_fips year
    
    // Get list of states (exclude Colorado = 8)
    levelsof state_fips if state_fips != 8, local(states)
    
    // Initialize dataset to store all gaps
    clear
    gen state_fips = .
    gen year = .
    gen gap = .
    save "$int_data/all_gaps_`outcome'.dta", replace
    
    // Run synth for each state and save gaps
    foreach state of local states {
        use "$clean_data/esop_state_panel", clear
        xtset state_fips year
        
        quietly capture synth `outcome' ///
            `outcome'(2013) `outcome'(2014) `outcome'(2015) `outcome'(2016), ///
            trunit(`state') trperiod(2017) ///
            mspeperiod(2013(1)2016) resultsperiod(2013(1)2024) ///
            keep("$int_data/temp_`state'_`outcome'.dta", replace)
        
        if _rc == 0 {
            use "$int_data/temp_`state'_`outcome'.dta", clear
            gen gap = _Y_treated - _Y_synthetic
            gen state_fips = `state'
            rename _time year
            keep state_fips year gap
            
            append using "$int_data/all_gaps_`outcome'.dta"
            save "$int_data/all_gaps_`outcome'.dta", replace
            erase "$int_data/temp_`state'_`outcome'.dta"
        }
    }
    
    // Add Colorado results
    capture confirm file "$int_data/synth_`outcome'.dta"
    if _rc == 0 {
        use "$int_data/synth_`outcome'.dta", clear
        gen gap = _Y_treated - _Y_synthetic
        rename _time year
        gen state_fips = 8
        keep state_fips year gap
        
        append using "$int_data/all_gaps_`outcome'.dta"
        save "$int_data/all_gaps_`outcome'.dta", replace
    }
    
    // Plot placebo test
    use "$int_data/all_gaps_`outcome'.dta", clear
    
    twoway ///
        (line gap year if state_fips != 8, lcolor(gs14) lwidth(vthin)) ///
        (line gap year if state_fips == 8, lcolor(red) lwidth(thick)), ///
        xline(2017, lpattern(dash)) yline(0) ///
        legend(order(2 "Colorado" 1 "Other States")) ///
        title("Placebo Test: `l_`outcome''") ///
        graphregion(color(white)) ///
        xtitle("Year") ytitle("Gap in `l_`outcome''")
        
    graph export "`output'/placebo_test_`outcome'.png", replace
}

display "All tests completed. Graphs saved to: `output'"