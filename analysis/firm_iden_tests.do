********************************************************************************
// Project: Firm-Level Identification Assumption Tests
// Author: Mitchell
// Date: 2025-11-18
// Purpose: Firm-level event study analysis for Colorado ESOP treatment
********************************************************************************

// Setup
clear all
set more off

global downloads "D:\01 - Projects\esop_data"
global clean_data "C:\Users\mwballif\Box\esop-tax-credit-did\data\clean_data"
global tabfig "C:\Users\mwballif\Box\esop-tax-credit-did\tabfig"

// Define output folder
local output "$tabfig\identification tests"

// Define outcomes to test
local outcomes "esop_partcp_rate esop_firm esop_tot_active_partcp_cnt esop_tot_assets_boy_amt esop_tot_partcp_boy_cnt tot_assets_boy_amt"

// Define outcome labels for graphs
local l_esop_partcp_rate "ESOP Participation Rate"
local l_esop_firm "Has ESOP Plan"
local l_esop_tot_active_partcp_cnt "Total Active ESOP Participants"
local l_esop_tot_assets_boy_amt "Total ESOP Assets (BOY)"
local l_esop_tot_partcp_boy_cnt "Total ESOP Participants (BOY)"
local l_tot_assets_boy_amt "Total Assets (BOY)"

// Define clustering options
local cluster_opts "state_fips spons_dfe_ein"

// Define cluster labels
local l_state_fips "State-Clustered"
local l_spons_dfe_ein "Firm-Clustered"


********************************************************************************
// FINAL DRAFT EVENT STUDIES AND PLOTS (UTAH VS COLORADO)
********************************************************************************
use "$downloads/esop_firm_panel", clear
        
// Keep only Colorado and Utah
keep if inlist(state_fips, 8, 49)

// Treatment start date
gen credit_start = 2017
gen tdate = year - credit_start

// Define dummies
forval i = 1/15 {
    gen t_n`i' = tdate == -`i'
    gen t_p`i' = tdate == `i'
    
    gen co_t_n`i' = CO * t_n`i'
    gen co_t_p`i' = CO * t_p`i'
}

gen t_0 = tdate == 0
gen co_t0 = CO * t_0 

gen esop_assets_millions = esop_tot_assets_eoy_amt / 1000000
****
// Assets (Colorado vs Utah only)
reghdfe esop_assets_millions co_t_n5 co_t_n4 co_t_n3 co_t_n2 ///
    o.co_t_n1 co_t0 co_t_p1 co_t_p2 co_t_p3 co_t_p4 co_t_p5 ///
    if tdate >= -5 & tdate <= 5, absorb(state_fips year) vce(cluster spons_dfe_ein)

// Plot coefficients
coefplot, keep(co_t_*) vertical omitted ///
    yline(0, lcolor(red) lpattern(dash)) ///
    xline(6, lpattern(dash) lcolor(gray)) ///
    xtitle("Years Relative to 2016") ///
    ytitle("Effect on Assets (millions USD)") ///
    graphregion(color(white)) ///
    ciopts(recast(rcap)) ///
    xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "1" 8 "2" 9 "3" 10 "4" 11 "5+", angle(0))
    
graph export "$tabfig\final_draft_figs\firm_event_assets_state_FE.png", replace

// Total Participants (Colorado vs Utah only)
reghdfe esop_tot_partcp_boy_cnt co_t_n5 co_t_n4 co_t_n3 co_t_n2 ///
    o.co_t_n1 co_t0 co_t_p1 co_t_p2 co_t_p3 co_t_p4 co_t_p5 ///
    if tdate >= -5 & tdate <= 5, absorb(state_fips year) vce(cluster spons_dfe_ein)

// Plot coefficients
coefplot, keep(co_t_*) vertical omitted ///
    yline(0, lcolor(red) lpattern(dash)) ///
    xline(6, lpattern(dash) lcolor(gray)) ///
    xtitle("Years Relative to 2016") ///
    ytitle("Effect on Total ESOP Plan Participants") ///
    graphregion(color(white)) ///
    ciopts(recast(rcap)) ///
    xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "1" 8 "2" 9 "3" 10 "4" 11 "5+", angle(0))
    
graph export "$tabfig\final_draft_figs\firm_event_partcp_state_FE.png", replace

// Active Participants (Colorado vs Utah only)
reghdfe esop_tot_active_partcp_cnt co_t_n5 co_t_n4 co_t_n3 co_t_n2 ///
    o.co_t_n1 co_t0 co_t_p1 co_t_p2 co_t_p3 co_t_p4 co_t_p5 ///
    if tdate >= -5 & tdate <= 5, absorb(state_fips year) vce(cluster spons_dfe_ein)

// Plot coefficients
coefplot, keep(co_t_*) vertical omitted ///
    yline(0, lcolor(red) lpattern(dash)) ///
    xline(6, lpattern(dash) lcolor(gray)) ///
    xtitle("Years Relative to 2016") ///
    ytitle("Effect on Total Active ESOP Participants") ///
    graphregion(color(white)) ///
    ciopts(recast(rcap)) ///
    xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "1" 8 "2" 9 "3" 10 "4" 11 "5+", angle(0))
    
graph export "$tabfig\final_draft_figs\firm_event_act_partcp_state_FE.png", replace

// Participation Share (Colorado vs Utah only)
reghdfe esop_partcp_rate co_t_n5 co_t_n4 co_t_n3 co_t_n2 ///
    o.co_t_n1 co_t0 co_t_p1 co_t_p2 co_t_p3 co_t_p4 co_t_p5 ///
    if tdate >= -5 & tdate <= 5, absorb(state_fips year) vce(cluster spons_dfe_ein)

// Plot coefficients
coefplot, keep(co_t_*) vertical omitted ///
    yline(0, lcolor(red) lpattern(dash)) ///
    xline(6, lpattern(dash) lcolor(gray)) ///
    xtitle("Years Relative to 2016") ///
    ytitle("Effect on Participation Rate") ///
    graphregion(color(white)) ///
    ciopts(recast(rcap)) ///
    xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "1" 8 "2" 9 "3" 10 "4" 11 "5+", angle(0))
    
graph export "$tabfig\final_draft_figs\firm_event_shr_partcp_state_FE.png", replace

// ESOP Firm (Colorado vs Utah only)
reghdfe esop_firm co_t_n5 co_t_n4 co_t_n3 co_t_n2 ///
    o.co_t_n1 co_t0 co_t_p1 co_t_p2 co_t_p3 co_t_p4 co_t_p5 ///
    if tdate >= -5 & tdate <= 5, absorb(state_fips year) vce(cluster spons_dfe_ein)

// Plot coefficients
coefplot, keep(co_t_*) vertical omitted ///
    yline(0, lcolor(red) lpattern(dash)) ///
    xline(6, lpattern(dash) lcolor(gray)) ///
    xtitle("Years Relative to 2016") ///
    ytitle("Effect on Probability Firm Has ESOP") ///
    graphregion(color(white)) ///
    ciopts(recast(rcap)) ///
    xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "1" 8 "2" 9 "3" 10 "4" 11 "5+", angle(0))
    
graph export "$tabfig\final_draft_figs\firm_event_esop_firm_state_FE.png", replace

********************************************************************************
// ROUGH DRAFT EVENT STUDIES AND PLOTS (UTAH VS COLORADO)
********************************************************************************
use "$downloads/esop_firm_panel", clear
        
        // Keep only Colorado and Utah
        keep if inlist(state_fips, 8, 49)
        
        // Treatment start date
        gen credit_start = 2017
        gen tdate = year - credit_start
        
        // Define dummies
        forval i = 1/15 {
            gen t_neg`i' = tdate == -`i'
            gen t_pos`i' = tdate == `i'
            
            gen co_t_neg`i' = CO * t_neg`i'
            gen co_t_pos`i' = CO * t_pos`i'
        }
        
        gen t_0 = tdate == 0
        gen co_t0 = CO * t_0 
        
		gen esop_assets= esop_tot_assets_boy_amt/ 1000
        // Assets (Colorado vs Utah only)
        reghdfe esop_assets co_t_neg5 co_t_neg4 co_t_neg3 co_t_neg2 ///
            o.co_t_neg1 co_t0 co_t_pos1 co_t_pos2 co_t_pos3 co_t_pos4 co_t_pos5 ///
            if tdate >= -5 & tdate <= 5, absorb(spons_dfe_ein year) vce(cluster spons_dfe_ein)
        
        // Plot coefficients
        coefplot, keep(co_t_*) vertical ///
            yline(0, lcolor(red)) ///
            xline(4.5, lpattern(dash) lcolor(gray)) ///
            title("Firm-Level Event Study: Total ESOP Assets") ///
            subtitle("Colorado vs Utah") ///
            xtitle("Years Relative to 2016") ///
            ytitle("Effect on Total ESOP Assets (thousands)") ///
            graphregion(color(white)) ///
            ciopts(recast(rcap)) ///
			xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "1" 6 "2" 7 "3" 8 "5" 9 "", angle(0))
            
        graph export "$tabfig\rough_draft_figs\firm_event_assets.png", replace
		
		// Total Participants (Colorado vs Utah only)
        reghdfe esop_tot_partcp_boy_cnt co_t_neg5 co_t_neg4 co_t_neg3 co_t_neg2 ///
            o.co_t_neg1 co_t0 co_t_pos1 co_t_pos2 co_t_pos3 co_t_pos4 co_t_pos5 ///
            if tdate >= -5 & tdate <= 5, absorb(spons_dfe_ein year) vce(cluster spons_dfe_ein)
        
        // Plot coefficients
        coefplot, keep(co_t_*) vertical ///
            yline(0, lcolor(red)) ///
            xline(4.5, lpattern(dash) lcolor(gray)) ///
            title("Firm-Level Event Study: Total ESOP Plan Participants") ///
            subtitle("Colorado vs Utah") ///
            xtitle("Years Relative to 2016") ///
            ytitle("Effect on Total ESOP Plan Participants") ///
            graphregion(color(white)) ///
            ciopts(recast(rcap)) ///
			xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "1" 6 "2" 7 "3" 8 "5" 9 "", angle(0))
            
        graph export "$tabfig\rough_draft_figs\firm_event_partcp.png", replace
		
		// Active Participants (Colorado vs Utah only)
        reghdfe esop_tot_active_partcp_cnt co_t_neg5 co_t_neg4 co_t_neg3 co_t_neg2 ///
            o.co_t_neg1 co_t0 co_t_pos1 co_t_pos2 co_t_pos3 co_t_pos4 co_t_pos5 ///
            if tdate >= -5 & tdate <= 5, absorb(spons_dfe_ein year) vce(cluster spons_dfe_ein)
        
        // Plot coefficients
        coefplot, keep(co_t_*) vertical ///
            yline(0, lcolor(red)) ///
            xline(4.5, lpattern(dash) lcolor(gray)) ///
            title("Firm-Level Event Study: Total Active ESOP Particpants") ///
            subtitle("Colorado vs Utah") ///
            xtitle("Years Relative to 2016") ///
            ytitle("Effect on Total Active ESOP Participants") ///
            graphregion(color(white)) ///
            ciopts(recast(rcap)) ///
			xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "1" 6 "2" 7 "3" 8 "5" 9 "", angle(0))
            
        graph export "$tabfig\rough_draft_figs\firm_event_act_partcp.png", replace
		
		// Participation Share (Colorado vs Utah only)
        reghdfe esop_partcp_rate co_t_neg5 co_t_neg4 co_t_neg3 co_t_neg2 ///
            o.co_t_neg1 co_t0 co_t_pos1 co_t_pos2 co_t_pos3 co_t_pos4 co_t_pos5 ///
            if tdate >= -5 & tdate <= 5, absorb(spons_dfe_ein year) vce(cluster spons_dfe_ein)
        
        // Plot coefficients
        coefplot, keep(co_t_*) vertical ///
            yline(0, lcolor(red)) ///
            xline(4.5, lpattern(dash) lcolor(gray)) ///
            title("Firm-Level Event Study: ESOP Particpation Share") ///
            subtitle("Colorado vs Utah") ///
            xtitle("Years Relative to 2016") ///
            ytitle("Effect on Participation Rate") ///
            graphregion(color(white)) ///
            ciopts(recast(rcap)) ///
			xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "1" 6 "2" 7 "3" 8 "5" 9 "", angle(0))
            
        graph export "$tabfig\rough_draft_figs\firm_event_shr_partcp.png", replace
		
		// ESOP Firm (Colorado vs Utah only)
        reghdfe esop_firm co_t_neg5 co_t_neg4 co_t_neg3 co_t_neg2 ///
            o.co_t_neg1 co_t0 co_t_pos1 co_t_pos2 co_t_pos3 co_t_pos4 co_t_pos5 ///
            if tdate >= -5 & tdate <= 5, absorb(spons_dfe_ein year) vce(cluster spons_dfe_ein)
        
        // Plot coefficients
        coefplot, keep(co_t_*) vertical ///
            yline(0, lcolor(red)) ///
            xline(4.5, lpattern(dash) lcolor(gray)) ///
            title("Firm-Level Event Study: Probability Firm Has ESOP") ///
            subtitle("Colorado vs Utah") ///
            xtitle("Years Relative to 2016") ///
            ytitle("Probability Firm Has ESOP") ///
            graphregion(color(white)) ///
            ciopts(recast(rcap)) ///
			xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "1" 6 "2" 7 "3" 8 "5" 9 "", angle(0))
            
        graph export "$tabfig\rough_draft_figs\firm_event_esop_firm.png", replace
		
		
		
		
		
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************


********************************************************************************
// FIRM-LEVEL EVENT STUDY: COLORADO VS US - ALL OUTCOMES & CLUSTERS
********************************************************************************

foreach cluster_var of local cluster_opts {
    foreach outcome of local outcomes {
        
        use "$clean_data/esop_firm_panel", clear
        
        // Create outcome variable if needed
        if "`outcome'" == "esop_partcp_rate" {
            gen esop_partcp_rate = esop_tot_active_partcp_cnt / tot_active_partcp_cnt
        }
        
        // Treatment start date
        gen credit_start = 2017
        gen tdate = year - credit_start
        
        // Define dummies
        forval i = 1/15 {
            gen t_neg`i' = tdate == -`i'
            gen t_pos`i' = tdate == `i'
            
            gen co_t_neg`i' = CO * t_neg`i'
            gen co_t_pos`i' = CO * t_pos`i'
        }
        
        gen t_0 = tdate == 0
        gen co_t0 = CO * t_0 
        
        // Run event study for firm-level outcome
        reghdfe `outcome' co_t_neg5 co_t_neg4 co_t_neg3 co_t_neg2 ///
            o.co_t_neg1 co_t0 co_t_pos1 co_t_pos2 co_t_pos3 co_t_pos4 co_t_pos5 ///
            if tdate >= -5 & tdate <= 5, absorb(year spons_dfe_ein) vce(cluster `cluster_var')
        
        // Plot coefficients
        coefplot, keep(co_t_*) vertical ///
            yline(0, lcolor(red)) ///
            xline(4.5, lpattern(dash) lcolor(gray)) ///
            title("Firm-Level Event Study: Colorado ESOP 2017" "Outcome: `l_`outcome''") ///
            subtitle("Colorado vs U.S. - `l_`cluster_var'' SE") ///
            xtitle("Years Relative to Treatment (t=-1 is reference)") ///
            ytitle("Effect on `l_`outcome''") ///
            graphregion(color(white)) ///
            ciopts(recast(rcap))
            
        graph export "`output'/firm_event_study_CO_vs_US_`outcome'_`cluster_var'.png", replace
    }
}


********************************************************************************
// FIRM-LEVEL EVENT STUDY: COLORADO VS UTAH - ALL OUTCOMES & CLUSTERS
********************************************************************************

foreach cluster_var of local cluster_opts {
    foreach outcome of local outcomes {
        
        use "$clean_data/esop_firm_panel", clear
        
        // Keep only Colorado and Utah
        keep if inlist(state_fips, 8, 49)
        
        // Create outcome variable if needed
        if "`outcome'" == "esop_partcp_rate" {
            gen esop_partcp_rate = esop_tot_active_partcp_cnt / tot_active_partcp_cnt
        }
        
        // Treatment start date
        gen credit_start = 2017
        gen tdate = year - credit_start
        
        // Define dummies
        forval i = 1/15 {
            gen t_neg`i' = tdate == -`i'
            gen t_pos`i' = tdate == `i'
            
            gen co_t_neg`i' = CO * t_neg`i'
            gen co_t_pos`i' = CO * t_pos`i'
        }
        
        gen t_0 = tdate == 0
        gen co_t0 = CO * t_0 
        
        // Run event study (Colorado vs Utah only)
        reghdfe `outcome' co_t_neg5 co_t_neg4 co_t_neg3 co_t_neg2 ///
            o.co_t_neg1 co_t0 co_t_pos1 co_t_pos2 co_t_pos3 co_t_pos4 co_t_pos5 ///
            if tdate >= -5 & tdate <= 5, absorb(spons_dfe_ein year) vce(cluster `cluster_var')
        
        // Plot coefficients
        coefplot, keep(co_t_*) vertical ///
            yline(0, lcolor(red)) ///
            xline(4.5, lpattern(dash) lcolor(gray)) ///
            title("Firm-Level Event Study: Colorado ESOP 2017" "Outcome: `l_`outcome''") ///
            subtitle("Colorado vs Utah - `l_`cluster_var'' SE") ///
            xtitle("Years Relative to Treatment (t=-1 is reference)") ///
            ytitle("Effect on `l_`outcome''") ///
            graphregion(color(white)) ///
            ciopts(recast(rcap))
            
        graph export "`output'/firm_event_study_CO_vs_UT_`outcome'_`cluster_var'.png", replace
    }
}


********************************************************************************
// FIRM-LEVEL EVENT STUDY: COLORADO VS ARIZONA - ALL OUTCOMES & CLUSTERS
********************************************************************************

foreach cluster_var of local cluster_opts {
    foreach outcome of local outcomes {
        
        use "$clean_data/esop_firm_panel", clear
        
        // Keep only Colorado and Arizona
        keep if inlist(state_fips, 8, 4)
        
        // Create outcome variable if needed
        if "`outcome'" == "esop_partcp_rate" {
            gen esop_partcp_rate = esop_tot_active_partcp_cnt / tot_active_partcp_cnt
        }
        
        // Treatment start date
        gen credit_start = 2017
        gen tdate = year - credit_start
        
        // Define dummies
        forval i = 1/15 {
            gen t_neg`i' = tdate == -`i'
            gen t_pos`i' = tdate == `i'
            
            gen co_t_neg`i' = CO * t_neg`i'
            gen co_t_pos`i' = CO * t_pos`i'
        }
        
        gen t_0 = tdate == 0
        gen co_t0 = CO * t_0 
        
        // Run event study (Colorado vs Arizona only)
        reghdfe `outcome' co_t_neg5 co_t_neg4 co_t_neg3 co_t_neg2 ///
            o.co_t_neg1 co_t0 co_t_pos1 co_t_pos2 co_t_pos3 co_t_pos4 co_t_pos5 ///
            if tdate >= -5 & tdate <= 5, absorb(spons_dfe_ein year) vce(cluster `cluster_var')
        
        // Plot coefficients
        coefplot, keep(co_t_*) vertical ///
            yline(0, lcolor(red)) ///
            xline(4.5, lpattern(dash) lcolor(gray)) ///
            title("Firm-Level Event Study: Colorado ESOP 2017" "Outcome: `l_`outcome''") ///
            subtitle("Colorado vs Arizona - `l_`cluster_var'' SE") ///
            xtitle("Years Relative to Treatment (t=-1 is reference)") ///
            ytitle("Effect on `l_`outcome''") ///
            graphregion(color(white)) ///
            ciopts(recast(rcap))
            
        graph export "`output'/firm_event_study_CO_vs_AZ_`outcome'_`cluster_var'.png", replace
    }
}

display "All firm-level tests completed. Graphs saved to: `output'"