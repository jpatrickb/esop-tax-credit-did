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