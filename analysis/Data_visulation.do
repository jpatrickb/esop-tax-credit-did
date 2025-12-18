********************************************************************************
// Project: Data visualization
// Author: Soren
// Date: 2025-11-18
// Purpose: Data visualization for trends and summary statistics for the data section of paper
********************************************************************************

// Setup
clear all
set more off

global clean_data "C:\Users\mwballif\Box\esop-tax-credit-did\data\clean_data"
global tabfig "C:\Users\mwballif\Box\esop-tax-credit-did\tabfig"



********************************************************************************
// Summary statistics
********************************************************************************
// Summary statistics of Utah and Colorado

use "$clean_data/esop_state_panel.dta", clear

// Add variable labels
label variable num_esop_firms "Number of ESOP Firms"
label variable total_firms "Total Firms"
label variable esop_tot_partcp_boy_cnt "ESOP Participants (BOY)"
label variable esop_tot_assets_eoy_amt "ESOP Assets EOY"
gen esop_assets_thou = esop_net_assets_eoy_amt /1000000
// Keep only Colorado and Utah
preserve
keep if inlist(state_fips, 8, 49) 

// Initialize Excel file
putexcel set "$tabfig/summary_stats.xlsx", replace

// Add headers
putexcel A1 = "Variable" B1 = "State" C1 = "Mean" D1 = "SD" E1 = "Min" F1 = "Max", bold

// Calculate and export statistics for each variable and state
local row = 2
 foreach state in 8 49{
     foreach var in num_esop_firms total_firms esop_tot_partcp_boy_cnt 					esop_tot_assets_eoy_amt{
        quietly summarize `var' if state_fips == `state'
        local mean = r(mean)
        local sd = r(sd)
        local min = r(min)
        local max = r(max)
        
        putexcel A`row' = "`var'" B`row' = `state' C`row' = `mean' ///
                 D`row' = `sd' E`row' = `min' F`row' = `max'
        local row = `row' + 1
    }
}
restore


********************************************************************************
// Data Visualizations
********************************************************************************
// Graph trends


////////////////////////////////////////////////////////////////////////////////
// TRENDS COMPARISON: COLORADO VS UTAH
////////////////////////////////////////////////////////////////////////////////

preserve
keep if inlist(state_fips, 8, 49)

// Add state labels
label define states 8 "Colorado" 49 "Utah"
label values state_fips states


// Var names too long
rename esop_tot_assets_eoy_amt tot_esop_assets
rename tot_active_partcp_cnt act_pension_ptcps
rename esop_tot_active_partcp_cnt tot_act_esop

// Define variables and labels
local vars "num_esop_firms  esop_firm_share esop_tot_partcp_boy_cnt esop_assets_thou tot_act_esop act_pension_ptcps total_firms"
local label_num_esop_firms "Number of ESOP Firms"
local label_esop_assets_mill "Total ESOP Assets (USD Millions)"
local label_esop_tot_partcp_boy_cnt "ESOP Participants (BOY)"
local label_tot_act_esop "Active ESOP Participants (BOY)"
local label_act_pension_ptcps "Total Active Pension Plan Participants"
local label_tot_esop_assets "ESOP Assets EOY (USD)"
local label_total_firms "Total Firms with Pension Plan"
local label_esop_firm_share "Share of Firms with ESOP Plan"

// Create individual graphs for each variable
foreach var of local vars {
    twoway ///
        (line `var' year if state_fips == 8 & year >= 2011 & year <= 2025, lcolor(red) lwidth(medium)) ///
        (line `var' year if state_fips == 49 & year >= 2011 & year <= 2025, lcolor(blue) lwidth(medium)), ///
        xline(2017, lpattern(dash) lcolor(gray)) ///
        legend(label(1 "Colorado") label(2 "Utah") position(6) rows(1)) ///
        xtitle("Year") ytitle("`label_`var''") ///
        graphregion(color(white)) ///
        ylabel(, format(%12.0fc))
        
    graph export "$tabfig/trend_comparison_`var'.png", replace
}

restore


////////////////////////////////////////////////////////////////////////////////
// TRENDS COMPARISON: COLORADO VS UTAH+ARIZONA AVERAGE
////////////////////////////////////////////////////////////////////////////////

preserve
keep if inlist(state_fips, 8, 49, 4)

// Create control group average (Utah + Arizona)
gen control_group = inlist(state_fips, 49, 4)

// Calculate averages for control states
collapse (mean) num_esop_firms total_firms esop_tot_partcp_boy_cnt ///
         esop_tot_assets_eoy_amt, by(year control_group)

// Reshape for easier plotting
reshape wide num_esop_firms total_firms esop_tot_partcp_boy_cnt ///
             esop_tot_assets_eoy_amt, i(year) j(control_group)

// Rename for clarity (shorter names)
rename *0 *_CO
rename *1 *_ctrl

// Define variables and labels
local vars "num_esop_firms total_firms esop_tot_partcp_boy_cnt esop_tot_assets_eoy_amt"
local label_num_esop_firms "Number of ESOP Firms"
local label_total_firms "Total Firms"
local label_esop_tot_partcp_boy_cnt "ESOP Participants (BOY)"
local label_esop_tot_assets_eoy_amt "ESOP Assets EOY (USD)"

// Create individual graphs for each variable
foreach var of local vars {
    twoway ///
        (line `var'_CO year if year >= 2011 & year <= 2025, lcolor(red) lwidth(medium)) ///
        (line `var'_ctrl year if year >= 2011 & year <= 2025, lcolor(blue) lwidth(medium)), ///
        xline(2017, lpattern(dash) lcolor(gray)) ///
        legend(label(1 "Colorado") label(2 "Utah + Arizona (Avg)") position(6) rows(1)) ///
        title("Trends Comparison: `label_`var''") ///
        subtitle("Colorado vs Utah+Arizona Average (Treatment in 2017)") ///
        xtitle("Year") ytitle("`label_`var''") ///
        graphregion(color(white)) ///
        ylabel(, format(%12.0fc))
        
    graph export "$tabfig/trend_comparison_CO_vs_UT_AZ_`var'.png", replace
}

restore


////////////////////////////////////////////////////////////////////////////////
// CREATE FORMATTED SUMMARY TABLE FOR EXCEL
////////////////////////////////////////////////////////////////////////////////

preserve
keep if year >= 2011 & year <=2016


// Var names too long
replace esop_tot_assets_eoy_amt = esop_tot_assets_eoy_amt/1000000
rename esop_tot_assets_eoy_amt tot_esop_assets
rename tot_active_partcp_cnt act_pension_ptcps
rename esop_tot_active_partcp_cnt tot_act_esop

// Apply variable labels to the actual variables
label variable num_esop_firms "Number of ESOP Firms"
label variable esop_tot_partcp_boy_cnt "ESOP Participants (BOY)"
label variable tot_act_esop "Active ESOP Participants (BOY)"
label variable act_pension_ptcps "Total Active Pension Plan Participants"
label variable tot_esop_assets "ESOP Assets EOY (Millions USD)"
label variable total_firms "Total Firms with Pension Plan"
label variable esop_firm_share "Share of Firms with ESOP Plan"

// Define variables and labels
local row = 3
local vars "num_esop_firms  esop_firm_share esop_tot_partcp_boy_cnt tot_esop_assets tot_act_esop act_pension_ptcps total_firms"

// Initialize Excel file
putexcel set "$tabfig/summary_stats_formatted.xlsx", replace

// Create headers
putexcel A1 = "Variable", bold
putexcel B1:E1 = "Colorado", bold merge
putexcel F1:I1 = "Utah", bold merge
putexcel J1:M1 = "USA", bold merge

putexcel B2 = "Mean", bold
putexcel C2 = "SD", bold
putexcel D2 = "Min", bold
putexcel E2 = "Max", bold
putexcel F2 = "Mean", bold
putexcel G2 = "SD", bold
putexcel H2 = "Min", bold
putexcel I2 = "Max", bold
putexcel J2 = "Mean", bold
putexcel K2 = "SD", bold
putexcel L2 = "Min", bold
putexcel M2 = "Max", bold



foreach var of local vars {
    local varlabel : variable label `var'
    
    // Colorado stats (state_fips = 8)
    quietly summarize `var' if state_fips == 8
    local co_mean = r(mean)
    local co_sd = r(sd)
    local co_min = r(min)
    local co_max = r(max)
    
    // Utah stats (state_fips = 49)
    quietly summarize `var' if state_fips == 49
    local ut_mean = r(mean)
    local ut_sd = r(sd)
    local ut_min = r(min)
    local ut_max = r(max)
	
	// Utah stats (state_fips = 49)
    quietly summarize `var' if state_fips != 49 & state_fips != 8
    local us_mean = r(mean)
    local us_sd = r(sd)
    local us_min = r(min)
    local us_max = r(max)
    
    // Write to Excel
    putexcel A`row' = "`varlabel'"
    putexcel B`row' = `co_mean', nformat(number_sep)
    putexcel C`row' = `co_sd', nformat(number_sep)
    putexcel D`row' = `co_min', nformat(number_sep)
    putexcel E`row' = `co_max', nformat(number_sep)
    putexcel F`row' = `ut_mean', nformat(number_sep)
    putexcel G`row' = `ut_sd', nformat(number_sep)
    putexcel H`row' = `ut_min', nformat(number_sep)
    putexcel I`row' = `ut_max', nformat(number_sep)
	putexcel J`row' = `us_mean', nformat(number_sep)
    putexcel K`row' = `us_sd', nformat(number_sep)
    putexcel L`row' = `us_min', nformat(number_sep)
    putexcel M`row' = `us_max', nformat(number_sep)
    
    local row = `row' + 1
}

restore

display "Formatted summary table saved to: $tabfig/summary_stats_formatted.xlsx"