
use "C:/Users/$pid/Box/esop-tax-credit-did/data/clean_data/esop_state_panel", clear
* Set panel
xtset state_fips year

* Create outcome variable
gen esop_rate = esop_firm_share

* Check data availability
tab year if !missing(esop_rate)
list state_fips year esop_rate if state_fips == 8

********************************************************************************
* RUN SYNTHETIC CONTROL
********************************************************************************

* Main specification
synth esop_rate ///
    esop_rate(2010) esop_rate(2013) esop_rate(2016) ///
    , ///
    trunit(8) trperiod(2017) ///
    mspeperiod(2010(1)2016) ///
    resultsperiod(2010(1)2024) ///
    keep(synth_results.dta, replace) ///
    fig

********************************************************************************
* PLOT RESULTS
********************************************************************************

use synth_results.dta, clear

* Main plot
twoway ///
    (line _Y_treated _time, lcolor(black)) ///
    (line _Y_synthetic _time, lcolor(red) lpattern(dash)), ///
    xline(2017, lpattern(dash)) ///
    legend(label(1 "Colorado") label(2 "Synthetic Colorado")) ///
    title("Synthetic Control") ///
    xtitle("Year") ytitle("ESOP Rate")
	
	
	
//Dr Wilson Synth Code
//Need to install the programs to run synthetic control
ssc install synth
findit synth_runner


//need to tell stata this is a panel and what the identifier is
tsset state year 

//Estimate synthetic control. Tell it what to match on (trunit 3 is california takes value of 3 in state variable)
synth cigsale cigsale(1988) cigsale(1987) cigsale(1986) cigsale(1985) cigsale(1984) ///
	cigsale(1983) cigsale(1982) cigsale(1981) cigsale(1980) cigsale(1979) cigsale(1978) ///
	cigsale(1977) cigsale(1976) cigsale(1975) cigsale(1974) cigsale(1973) cigsale(1972) ///
	cigsale(1971) cigsale(1970), trunit(3) trperiod(1989) fig


/// What if we match on something slightly different...

synth cigsale cigsale(1988) cigsale(1987) cigsale(1986) cigsale(1985) cigsale(1984) ///
	cigsale(1983) cigsale(1982) cigsale(1981) cigsale(1980) cigsale(1979) cigsale(1978) ///
	cigsale(1977) , trunit(3) trperiod(1989) fig
	

/// What if we change the donor pool? Exclude Utah?

preserve 
drop if state == 34 
synth cigsale cigsale(1988) cigsale(1987) cigsale(1986) cigsale(1985) cigsale(1984) ///
	cigsale(1983) cigsale(1982) cigsale(1981) cigsale(1980) cigsale(1979) cigsale(1978) ///
	cigsale(1977) cigsale(1976) cigsale(1975) cigsale(1974) cigsale(1973) cigsale(1972) ///
	cigsale(1971) cigsale(1970) , trunit(3) trperiod(1989) fig
	
restore
	
	
	
///We can create the placebo tests ourselves with synth_runner
/// 
synth_runner cigsale cigsale(1988) cigsale(1987) cigsale(1986) cigsale(1985) cigsale(1984) ///
	cigsale(1983) cigsale(1982) cigsale(1981) cigsale(1980) cigsale(1979) cigsale(1978) ///
	cigsale(1977) cigsale(1976) cigsale(1975) cigsale(1974) cigsale(1973) cigsale(1972) ///
	cigsale(1971) cigsale(1970), trunit(3) trperiod(1989) gen_vars
	
//create the same sort of plots as above
effect_graphs, trlinediff(-1)

//creates the placebo plots to get at standard error/p value
single_treatment_graphs, trlinediff(-1) do_color(gray*.4)

//plot the p values in each post period
pval_graphs 



*********************************************
// DR WILSON WORKING CODE

* keep only the usable years
keep if inrange(year, 2011, 2025)
findit synth_runner
* set panel structure
tsset state_fips year

synth esop_tot_active_partcp_cnt ///
    esop_tot_active_partcp_cnt(2016) ///
    esop_tot_active_partcp_cnt(2015) ///
    esop_tot_active_partcp_cnt(2014) ///
    esop_tot_active_partcp_cnt(2013) ///
    esop_tot_active_partcp_cnt(2012) ///
	esop_tot_partcp_boy_cnt(2016) ///
    esop_tot_partcp_boy_cnt(2015) ///
    esop_tot_partcp_boy_cnt(2014) ///
    esop_tot_partcp_boy_cnt(2013) ///
    esop_tot_partcp_boy_cnt(2012) ///
	esop_tot_assets_boy_amt(2016) ///
    esop_tot_assets_boy_amt(2015) ///
    esop_tot_assets_boy_amt(2014) ///
    esop_tot_assets_boy_amt(2013) ///
    esop_tot_assets_boy_amt(2012)  ///
	esop_partcp_rate(2016) ///
    esop_partcp_rate(2015) ///
    esop_partcp_rate(2014) ///
    esop_partcp_rate(2013) ///
    esop_partcp_rate(2012) ///
	num_esop_firms(2016) ///
    num_esop_firms(2015) ///
    num_esop_firms(2014) ///
    num_esop_firms(2013) ///
    num_esop_firms(2012), ///
    trunit(8) trperiod(2017) ///
    mspeperiod(2012(1)2016) ///
    resultperiod(2011(1)2025) ///
    fig
	graph export "C:\Users\wkcbacon\Box\esop-tax-credit-did\tabfig\rough_draft_figs\esop_tot_active_partcp_cnt_synth.png", replace
	
	* 1. esop_tot_partcp_boy_cnt
synth esop_tot_partcp_boy_cnt ///
    esop_tot_partcp_boy_cnt(2016) ///
    esop_tot_partcp_boy_cnt(2015) ///
    esop_tot_partcp_boy_cnt(2014) ///
    esop_tot_partcp_boy_cnt(2013) ///
    esop_tot_partcp_boy_cnt(2012), ///
    trunit(8) trperiod(2017) ///
    mspeperiod(2012(1)2016) ///
    resultsperiod(2011(1)2025) ///
    fig
	graph export "C:\Users\wkcbacon\Box\esop-tax-credit-did\tabfig\rough_draft_figs\esop_tot_partcp_boy_cnt_synth.png", replace
* 2. esop_tot_assets_boy_amt
synth esop_tot_assets_boy_amt ///
    esop_tot_assets_boy_amt(2016) ///
    esop_tot_assets_boy_amt(2015) ///
    esop_tot_assets_boy_amt(2014) ///
    esop_tot_assets_boy_amt(2013) ///
    esop_tot_assets_boy_amt(2012), ///
    trunit(8) trperiod(2017) ///
    mspeperiod(2012(1)2016) ///
    resultsperiod(2011(1)2025) ///
    fig
	graph export "C:\Users\wkcbacon\Box\esop-tax-credit-did\tabfig\rough_draft_figs\esop_tot_assets_boy_amt_synth.png", replace
* 3. esop_partcp_rate
synth esop_partcp_rate ///
    esop_partcp_rate(2016) ///
    esop_partcp_rate(2015) ///
    esop_partcp_rate(2014) ///
    esop_partcp_rate(2013) ///
    esop_partcp_rate(2012), ///
    trunit(8) trperiod(2017) ///
    mspeperiod(2012(1)2016) ///
    resultsperiod(2011(1)2025) ///
    fig
	graph export "C:\Users\wkcbacon\Box\esop-tax-credit-did\tabfig\rough_draft_figs\esop_partcp_rate_synth.png", replace
* 4. num_esop_firms
synth num_esop_firms ///
    num_esop_firms(2016) ///
    num_esop_firms(2015) ///
    num_esop_firms(2014) ///
    num_esop_firms(2013) ///
    num_esop_firms(2012), ///
    trunit(8) trperiod(2017) ///
    mspeperiod(2012(1)2016) ///
    resultsperiod(2011(1)2025) ///
    fig
	graph export "C:\Users\wkcbacon\Box\esop-tax-credit-did\tabfig\rough_draft_figs\num_esop_firms_synth.png", replace
	
	
	
	
	
	
	
	
synth num_esop_firms ///
    esop_tot_active_partcp_cnt(2016) ///
    esop_tot_active_partcp_cnt(2015) ///
    esop_tot_active_partcp_cnt(2014) ///
    esop_tot_active_partcp_cnt(2013) ///
    esop_tot_active_partcp_cnt(2012) ///
	esop_tot_partcp_boy_cnt(2016) ///
    esop_tot_partcp_boy_cnt(2015) ///
    esop_tot_partcp_boy_cnt(2014) ///
    esop_tot_partcp_boy_cnt(2013) ///
    esop_tot_partcp_boy_cnt(2012) ///
	esop_tot_assets_boy_amt(2016) ///
    esop_tot_assets_boy_amt(2015) ///
    esop_tot_assets_boy_amt(2014) ///
    esop_tot_assets_boy_amt(2013) ///
    esop_tot_assets_boy_amt(2012)  ///
	esop_partcp_rate(2016) ///
    esop_partcp_rate(2015) ///
    esop_partcp_rate(2014) ///
    esop_partcp_rate(2013) ///
    esop_partcp_rate(2012) ///
	num_esop_firms(2016) ///
    num_esop_firms(2015) ///
    num_esop_firms(2014) ///
    num_esop_firms(2013) ///
    num_esop_firms(2012), ///
    trunit(8) trperiod(2017) ///
    mspeperiod(2012(1)2016) ///
    resultperiod(2011(1)2025) ///
    fig
	
	
// Single Weight Attempt

use "C:/Users/$pid/Box/esop-tax-credit-did/data/clean_data/esop_state_panel", clear
* Set panel
xtset state_fips year

keep if inrange(year, 2011, 2025)
* Ensure numeric state_fips
destring state_fips, replace
drop if state_fips == 19 | state_fips == 29


* Standardize each outcome (z-scores)
egen z_active = std(esop_tot_active_partcp_cnt)
egen z_boy    = std(esop_tot_partcp_boy_cnt)
egen z_assets = std(esop_tot_assets_boy_amt)
egen z_rate   = std(esop_partcp_rate)
egen z_firms  = std(num_esop_firms)


* Equal weights example
gen composite_y = (z_active + z_boy + z_assets + z_rate + z_firms)/5

synth composite_y ///
    esop_tot_active_partcp_cnt(2012) esop_tot_active_partcp_cnt(2013) esop_tot_active_partcp_cnt(2014) ///
    esop_tot_active_partcp_cnt(2015) esop_tot_active_partcp_cnt(2016) ///
    esop_tot_partcp_boy_cnt(2012) esop_tot_partcp_boy_cnt(2013) esop_tot_partcp_boy_cnt(2014) ///
    esop_tot_partcp_boy_cnt(2015) esop_tot_partcp_boy_cnt(2016) ///
    esop_tot_assets_boy_amt(2012) esop_tot_assets_boy_amt(2013) esop_tot_assets_boy_amt(2014) ///
    esop_tot_assets_boy_amt(2015) esop_tot_assets_boy_amt(2016) ///
    esop_partcp_rate(2012) esop_partcp_rate(2013) esop_partcp_rate(2014) ///
    esop_partcp_rate(2015) esop_partcp_rate(2016) ///
    num_esop_firms(2012) num_esop_firms(2013) num_esop_firms(2014) ///
    num_esop_firms(2015) num_esop_firms(2016), ///
    trunit(8) trperiod(2017) mspeperiod(2012(1)2016) resultperiod(2011(1)2025) fig
	
********************************************************************************
* STEP 4 — CREATE DONOR WEIGHTS DATASET
********************************************************************************

* Extract donor IDs and weights from e(W_weights)
matrix Wmat = e(W_weights)
local nrows = rowsof(Wmat)

clear
set obs `nrows'

* Donor IDs
gen donor_id = .
forvalues i = 1/`nrows' {
    replace donor_id = Wmat[`i',1] in `i'
}

* Donor weights
gen weight = .
forvalues i = 1/`nrows' {
    replace weight = Wmat[`i',2] in `i'
}

* Keep only non-zero weight donors
drop if weight == 0

* Save donor weights
save donor_weights.dta, replace

list

********************************************************************************
* STEP 5 — COMPUTE SYNTHETIC OUTCOMES
********************************************************************************

use "C:/Users/$pid/Box/esop-tax-credit-did/data/clean_data/esop_state_panel", clear
* Set panel
xtset state_fips year

keep if inrange(year, 2011, 2025)
* Ensure numeric state_fips
destring state_fips, replace


* Ensure numeric state_fips
destring state_fips, replace

* Donor pool only
preserve
keep if state_fips != 8  
drop if state_fips == 19 | state_fips == 29    

* Rename to match donor_weights dataset
rename state_fips donor_id

* Merge in weights
merge m:1 donor_id using donor_weights.dta, keep(match) nogen

* Compute weighted outcomes
gen active_w = esop_tot_active_partcp_cnt * weight
gen boy_w    = esop_tot_partcp_boy_cnt    * weight
gen assets_w = esop_tot_assets_boy_amt    * weight
gen rate_w   = esop_partcp_rate           * weight
gen firms_w  = num_esop_firms             * weight

* Collapse to get synthetic series by year
collapse (sum) synth_active=active_w synth_boy=boy_w synth_assets=assets_w ///
         synth_rate=rate_w synth_firms=firms_w, by(year)

* Save synthetic outcomes
save synth_outcomes.dta, replace
restore

********************************************************************************
* STEP 6 — MERGE SYNTHETIC OUTCOMES WITH TREATED UNIT
********************************************************************************

* Keep only treated unit
keep if state_fips == 8

* Merge synthetic outcomes
merge m:1 year using synth_outcomes.dta, ///
    keepusing(synth_active synth_boy synth_assets synth_rate synth_firms)

* Quick check
list year esop_tot_active_partcp_cnt synth_active in 1/10

********************************************************************************
* STEP 7 — PLOT RAW OUTCOMES VS SYNTHETIC
********************************************************************************

twoway ///
        (line esop_tot_active_partcp_cnt year, lcolor(blue)) ///
        (line synth_active year, lcolor(red) lpattern(dash)), ///
		xline(2017, lpattern(dash) lcolor(black)) /// dotted vertical line at 2017
        title("Active Participants: Actual vs Synthetic") ///
        legend(order(1 "Actual" 2 "Synthetic"))
		
twoway ///
        (line esop_tot_partcp_boy_cnt year, lcolor(blue)) ///
        (line synth_boy year, lcolor(red) lpattern(dash)), ///
		xline(2017, lpattern(dash) lcolor(black)) /// dotted vertical line at 2017
        title("Total Participants: Actual vs Synthetic") ///
        legend(order(1 "Actual" 2 "Synthetic"))
		
twoway ///
        (line esop_tot_assets_boy_amt year, lcolor(blue)) ///
        (line synth_assets year, lcolor(red) lpattern(dash)), ///
		xline(2017, lpattern(dash) lcolor(black)) /// dotted vertical line at 2017
        title("Total Assets: Actual vs Synthetic") ///
        legend(order(1 "Actual" 2 "Synthetic"))
		
twoway ///
        (line esop_partcp_rate year, lcolor(blue)) ///
        (line synth_rate year, lcolor(red) lpattern(dash)), ///
		xline(2017, lpattern(dash) lcolor(black)) /// dotted vertical line at 2017
        title("Participation Rate: Actual vs Synthetic") ///
        legend(order(1 "Actual" 2 "Synthetic"))
twoway ///
        (line num_esop_firms year, lcolor(blue)) ///
        (line synth_firms year, lcolor(red) lpattern(dash)), ///
		xline(2017, lpattern(dash) lcolor(black)) /// dotted vertical line at 2017
        title("Number of ESOP Firms: Actual vs Synthetic") ///
        legend(order(1 "Actual" 2 "Synthetic"))
