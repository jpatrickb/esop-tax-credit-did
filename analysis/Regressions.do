
********************************************************************************
// Project: Regressions	
********************************************************************************

*use esop_firm_panel, but do to file size and box limitations can't link it directly here because changes locations


//Install Packages
ssc install reghdfe, replace
ssc install ftools
ssc install estout
eststo clear

//prep DiD
gen post = year >= 2017
gen treat = state_fips == 8
gen did = post * treat

********************************************************************************
* RUN Regressions
********************************************************************************

//Cluster on firm level for CO and UT with state and year fixed effects

eststo clear

reghdfe esop_firm did if state_fips == 8 | state_fips == 49, absorb(state_fips year) vce(cluster spons_dfe_ein) 
eststo

reghdfe esop_tot_partcp_boy_cnt did if state_fips == 8 | state_fips == 49, absorb(state_fips year) vce(cluster spons_dfe_ein) 
eststo

reghdfe esop_tot_assets_boy_amt did if state_fips == 8 | state_fips == 49, absorb(state_fips year) vce(cluster spons_dfe_ein) 
eststo

reghdfe esop_tot_active_partcp_cnt did if state_fips == 8 | state_fips == 49, absorb(state_fips year) vce(cluster spons_dfe_ein) 
eststo

reghdfe esop_partcp_rate did if state_fips == 8 | state_fips == 49, absorb(state_fips year) vce(cluster spons_dfe_ein) 
eststo


esttab, se star(* 0.10 ** 0.05 *** 0.01) ///
	keep(did _cons) ///
	stats(N, fmt (0 3) labels("Observations"))
	
//Cluster on firm level for CO and UT with year fixed effects

eststo clear

reghdfe esop_firm did treat if state_fips == 8 | state_fips == 49, absorb(year) vce(cluster spons_dfe_ein) 
eststo

reghdfe esop_tot_partcp_boy_cnt did treat if state_fips == 8 | state_fips == 49, absorb(year) vce(cluster spons_dfe_ein) 
eststo

reghdfe esop_tot_assets_boy_amt did treat if state_fips == 8 | state_fips == 49, absorb(year) vce(cluster spons_dfe_ein) 
eststo

reghdfe esop_tot_active_partcp_cnt treat did if state_fips == 8 | state_fips == 49, absorb(year) vce(cluster spons_dfe_ein) 
eststo

reghdfe esop_partcp_rate treat did if state_fips == 8 | state_fips == 49, absorb(year) vce(cluster spons_dfe_ein) 
eststo

esttab, se star(* 0.10 ** 0.05 *** 0.01) ///
	keep(did treat _cons) ///
	stats(N, fmt (0 3) labels("Observations"))

	
//Cluster on firm level for CO and UT with state fixed effects

eststo clear

reghdfe esop_firm did post if state_fips == 8 | state_fips == 49, absorb(state_fips) vce(cluster spons_dfe_ein) 
eststo

reghdfe esop_tot_partcp_boy_cnt did post if state_fips == 8 | state_fips == 49, absorb(state_fips) vce(cluster spons_dfe_ein) 
eststo

reghdfe esop_tot_assets_boy_amt did post if state_fips == 8 | state_fips == 49, absorb(state_fips) vce(cluster spons_dfe_ein) 
eststo

reghdfe esop_tot_active_partcp_cnt did post if state_fips == 8 | state_fips == 49, absorb(state_fips) vce(cluster spons_dfe_ein) 
eststo

reghdfe esop_partcp_rate did post if state_fips == 8 | state_fips == 49, absorb(state_fips) vce(cluster spons_dfe_ein) 
eststo

esttab, se star(* 0.10 ** 0.05 *** 0.01) ///
	keep(did post _cons) ///
	stats(N, fmt (0 3) labels("Observations"))
	
********************************************************************************
// Project: Firm-Level Identification Assumption Tests	
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
// Project: Synthetic Control	
********************************************************************************

// ------------------------------------------------------------
// STEP 1 — LOAD DATA AND PREPARE LOG OUTCOMES
// ------------------------------------------------------------

use "C:/Users/$pid/Box/esop-tax-credit-did/data/clean_data/esop_state_panel", clear
xtset state_fips year

keep if inrange(year, 2011, 2025)
destring state_fips, replace
drop if state_fips == 19 | state_fips == 29

// Log-transform outcomes
gen ln_active = ln(esop_tot_active_partcp_cnt + 1)
gen ln_boy    = ln(esop_tot_partcp_boy_cnt + 1)
gen ln_assets = ln(esop_tot_assets_boy_amt + 1)
gen ln_rate   = ln(esop_partcp_rate + 1)
gen ln_firms  = ln(num_esop_firms + 1)

// Standardize logs
egen z_active = std(ln_active)
egen z_boy    = std(ln_boy)
egen z_assets = std(ln_assets)
egen z_rate   = std(ln_rate)
egen z_firms  = std(ln_firms)

// Composite index (equal weights)
gen composite_y = (z_active + z_boy + z_assets + z_rate + z_firms)/5


// ------------------------------------------------------------
// STEP 2 — SYNTHETIC CONTROL USING LOG PREDICTORS
// ------------------------------------------------------------

synth composite_y ///
    ln_active(2012) ln_active(2013) ln_active(2014) ln_active(2015) ln_active(2016) ///
    ln_boy(2012)    ln_boy(2013)    ln_boy(2014)    ln_boy(2015)    ln_boy(2016) ///
    ln_assets(2012) ln_assets(2013) ln_assets(2014) ln_assets(2015) ln_assets(2016) ///
    ln_rate(2012)   ln_rate(2013)   ln_rate(2014)   ln_rate(2015)   ln_rate(2016) ///
    ln_firms(2012)  ln_firms(2013)  ln_firms(2014)  ln_firms(2015)  ln_firms(2016), ///
    trunit(8) trperiod(2017) mspeperiod(2012(1)2016) resultperiod(2011(1)2025) fig


// ------------------------------------------------------------
// STEP 3 — EXTRACT DONOR WEIGHTS
// ------------------------------------------------------------

matrix Wmat = e(W_weights)
local n = rowsof(Wmat)

clear
set obs `n'

gen donor_id = .
gen weight   = .

forvalues i = 1/`n' {
    replace donor_id = Wmat[`i',1] in `i'
    replace weight   = Wmat[`i',2] in `i'
}

keep if weight != 0
save donor_weights.dta, replace

use donor_weights.dta, clear
list donor_id weight


// ------------------------------------------------------------
// STEP 4 — RECONSTRUCT SYNTHETIC OUTCOMES (LOG SCALE)
// ------------------------------------------------------------
use "C:/Users/$pid/Box/esop-tax-credit-did/data/clean_data/esop_state_panel", clear
xtset state_fips year
keep if inrange(year, 2011, 2025)
destring state_fips, replace

* ✅ Recreate log variables here (this was missing)
gen ln_active = ln(esop_tot_active_partcp_cnt + 1)
gen ln_boy    = ln(esop_tot_partcp_boy_cnt + 1)
gen ln_assets = ln(esop_tot_assets_boy_amt + 1)
gen ln_rate   = ln(esop_partcp_rate + 1)
gen ln_firms  = ln(num_esop_firms + 1)

preserve
keep if state_fips != 8
drop if state_fips == 19 | state_fips == 29
rename state_fips donor_id

merge m:1 donor_id using donor_weights.dta, keep(match) nogen

foreach v in ln_active ln_boy ln_assets ln_rate ln_firms {
    gen `v'_w = `v' * weight
}

collapse (sum) synth_ln_active=ln_active_w ///
                 synth_ln_boy=ln_boy_w ///
                 synth_ln_assets=ln_assets_w ///
                 synth_ln_rate=ln_rate_w ///
                 synth_ln_firms=ln_firms_w, by(year)

save synth_outcomes.dta, replace
restore


// ------------------------------------------------------------
// STEP 5 — MERGE SYNTHETIC LOG OUTCOMES WITH TREATED UNIT
// ------------------------------------------------------------

keep if state_fips == 8
merge m:1 year using synth_outcomes.dta, nogen

// Convert synthetic logs back to levels
gen synth_active = exp(synth_ln_active) - 1
gen synth_boy    = exp(synth_ln_boy)    - 1
gen synth_assets = exp(synth_ln_assets) - 1
gen synth_rate   = exp(synth_ln_rate)   - 1
gen synth_firms  = exp(synth_ln_firms)  - 1

list year esop_tot_active_partcp_cnt synth_active in 1/10


// ------------------------------------------------------------
// STEP 6 — PLOT RAW OUTCOMES VS SYNTHETIC (LEVELS)
// ------------------------------------------------------------

twoway ///
    (line esop_tot_active_partcp_cnt year, lcolor(blue)) ///
    (line synth_active year, lcolor(red) lpattern(dash)), ///
    xline(2017, lpattern(dash) lcolor(black)) ///
    legend(order(1 "Actual" 2 "Synthetic"))
	graph export "C:\Users\$pid\Box\esop-tax-credit-did\tabfig\rough_draft_figs\esop_tot_active_partcp_cnt_synth.png", replace

twoway ///
    (line esop_tot_partcp_boy_cnt year, lcolor(blue)) ///
    (line synth_boy year, lcolor(red) lpattern(dash)), ///
    xline(2017, lpattern(dash) lcolor(black)) ///
    legend(order(1 "Actual" 2 "Synthetic"))
	graph export "C:\Users\$pid\Box\esop-tax-credit-did\tabfig\rough_draft_figs\esop_tot_partcp_boy_cnt_synth.png", replace

twoway ///
    (line esop_tot_assets_boy_amt year, lcolor(blue)) ///
    (line synth_assets year, lcolor(red) lpattern(dash)), ///
    xline(2017, lpattern(dash) lcolor(black)) ///
    legend(order(1 "Actual" 2 "Synthetic"))
	graph export "C:\Users\$pid\Box\esop-tax-credit-did\tabfig\rough_draft_figs\esop_tot_assets_boy_amt_synth.png", replace

twoway ///
    (line esop_partcp_rate year, lcolor(blue)) ///
    (line synth_rate year, lcolor(red) lpattern(dash)), ///
    xline(2017, lpattern(dash) lcolor(black)) ///
    legend(order(1 "Actual" 2 "Synthetic"))
	graph export "C:\Users\$pid\Box\esop-tax-credit-did\tabfig\rough_draft_figs\esop_partcp_rate_synth.png", replace

twoway ///
    (line num_esop_firms year, lcolor(blue)) ///
    (line synth_firms year, lcolor(red) lpattern(dash)), ///
    xline(2017, lpattern(dash) lcolor(black)) ///
    legend(order(1 "Actual" 2 "Synthetic"))
	graph export "C:\Users\$pid\Box\esop-tax-credit-did\tabfig\rough_draft_figs\num_esop_firms_synth.png", replace
	
********************************************************************************
// Project: Data visualization
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