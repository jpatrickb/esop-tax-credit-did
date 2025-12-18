********************************************************************************
// Project: ESOP Data Preparation - Merge and Clean 5500 Forms
// Authors: Soren Pack | Mitchel Balif | Patrick Beal | Will Cheney
// Date: 2025-11-11
// Purpose: Merge Schedule H and I data onto long form and clean 5500 data
********************************************************************************

// Setup
clear all
set more off
set varabbrev off

// global pid "sohen33"
global pid "mwballif"
global data "D:\esop_data"


********************************************************************************
// PROCESS LONG FORM DATA (F_5500)
********************************************************************************

local files : dir "$data/5500_long_csv" files "f_*.csv"

// Loop through long forms
foreach file of local files {
    import delimited "$data/5500_long_csv/`file'", clear
    display "`file'"
    local year = substr("`file'", 8, 4)
    rename *, lower
    
    // Standardize variable names across years
    capture confirm variable ack_id 
    if _rc != 0 rename filing_id ack_id
    
    capture confirm variable spons_dfe_mail_us_city
    if _rc != 0 rename spons_dfe_city spons_dfe_mail_us_city 
    
    capture confirm variable spons_dfe_mail_us_state
    if _rc != 0 rename spons_dfe_state spons_dfe_mail_us_state 
    
    capture confirm variable spons_dfe_mail_us_zip 
    if _rc != 0 rename spons_dfe_zip_code spons_dfe_mail_us_zip 
    
    // Convert to string format
    tostring ack_id, replace format(%20.0g) force
    recast str30 ack_id, force
    tostring spons_dfe_ein, replace force
    recast str30 spons_dfe_ein, force
    tostring spons_dfe_pn, replace force
    recast str30 spons_dfe_pn, force
    
    // Convert to numeric format
    destring spons_dfe_mail_us_zip, replace force
    destring business_code, replace force
    
    // Clean form_tax_prd variable
    capture confirm string variable form_tax_prd
    if _rc == 0 {
        replace form_tax_prd = subinstr(form_tax_prd, "-", "", .)
        destring form_tax_prd, replace force
    }
    
    // Keep relevant variables
    keep ack_id spons_dfe_ein spons_dfe_pn plan_name form_tax_prd ///
        sponsor_dfe_name business_code tot_partcp_boy_cnt ///
        tot_active_partcp_cnt partcp_account_bal_cnt ///
        type_pension_bnft_code type_welfare_bnft_code ///
        spons_dfe_mail_us_city spons_dfe_mail_us_state ///
        spons_dfe_mail_us_zip plan_eff_date
    
    duplicates drop ack_id, force
    save "$data/5500_long_dta/5500_long_`year'", replace
}


********************************************************************************
// PROCESS SCHEDULE I DATA
********************************************************************************

local files : dir "$data/5500_sch_i_csv" files "f_*.csv"

// Loop through Schedule I forms
foreach file of local files {
    import delimited $data/5500_sch_i_csv/`file', clear
    display "`file'"
    local year = substr("`file'", 9, 4)
    
    // Standardize variable names
    capture confirm variable ack_id
    if _rc != 0 rename filing_id ack_id
    
    // Convert to string format
    tostring ack_id, replace format(%20.0g) force
    recast str30 ack_id, force
    tostring sch_i_ein, replace format(%20.0g) force
    recast str30 sch_i_ein, force
    tostring sch_i_plan_num, replace format(%20.0g) force
    recast str30 sch_i_plan_num, force
    
    // Clean form_tax_prd variable
    capture confirm string variable form_tax_prd
    if _rc == 0 {
        replace form_tax_prd = subinstr(form_tax_prd, "-", "", .)
        destring form_tax_prd, replace force
    }
    
    // Keep relevant variables
    keep ack_id sch_i_ein sch_i_plan_num sch_i_tax_prd ///
        small_tot_assets_boy_amt small_tot_assets_eoy_amt ///
        small_net_assets_eoy_amt small_net_assets_boy_amt
    
    duplicates drop ack_id, force
    save "$data/5500_sch_i_dta/5500_sch_i_`year'", replace
}


********************************************************************************
// PROCESS SCHEDULE H DATA
********************************************************************************

local files : dir "$data/5500_sch_h_csv" files "f_*.csv"

// Loop through Schedule H forms
foreach file of local files {
    import delimited $data/5500_sch_h_csv/`file', clear
    display "`file'"
    local year = substr("`file'", 9, 4)
    
    // Standardize variable names
    capture confirm variable ack_id
    if _rc != 0 rename filing_id ack_id
    
    // Convert to string format
    tostring ack_id, replace format(%20.0g) force
    recast str30 ack_id, force
    tostring sch_h_ein, replace format(%20.0g) force
    recast str30 sch_h_ein, force
    tostring sch_h_pn, replace format(%20.0g) force
    recast str30 sch_h_pn, force
    
    // Clean form_tax_prd variable
    capture confirm string variable form_tax_prd
    if _rc == 0 {
        replace form_tax_prd = subinstr(form_tax_prd, "-", "", .)
        destring form_tax_prd, replace force
    }
    
    // Keep relevant variables
    keep ack_id sch_h_ein sch_h_pn sch_h_tax_prd ///
        tot_assets_boy_amt tot_assets_eoy_amt ///
        net_assets_eoy_amt net_assets_boy_amt
    
    duplicates drop ack_id, force
    save "$data/5500_sch_h_dta/5500_sch_h_`year'", replace
}


********************************************************************************
// MERGE SCHEDULE H AND I DATA - 2024
********************************************************************************

local files : dir "$data/5500_long_dta" files "*.dta"

// Merge schedule H and I data to 2024 long form
use "$data/5500_long_dta/5500_long_2024.dta", clear
drop plan_eff_date

merge 1:1 ack_id using "$data/5500_sch_h_dta/5500_sch_h_2024.dta"
drop if _merge == 2 
drop _merge

merge 1:1 ack_id using "$data/5500_sch_i_dta/5500_sch_i_2024.dta"
drop if _merge == 2 
drop _merge

// Combine Schedule H and I variables
replace sch_h_tax_prd = sch_i_tax_prd if missing(sch_h_tax_prd)
replace sch_h_pn = sch_i_plan_num if missing(sch_h_pn)
replace sch_h_ein = sch_i_ein if missing(sch_h_ein)

replace tot_assets_boy_amt = small_tot_assets_boy_amt if missing(tot_assets_boy_amt)
replace net_assets_boy_amt = small_net_assets_boy_amt if missing(net_assets_boy_amt)
replace tot_assets_eoy_amt = small_tot_assets_eoy_amt if missing(tot_assets_eoy_amt)
replace net_assets_eoy_amt = small_net_assets_eoy_amt if missing(net_assets_eoy_amt)

drop sch_i_tax_prd sch_i_plan_num sch_i_ein ///
    small_tot_assets_boy_amt small_net_assets_boy_amt ///
    small_tot_assets_eoy_amt small_net_assets_eoy_amt

// Save 2024 dataset
save "$data/5500_merged/5500_merged_2024.dta", replace


********************************************************************************
// MERGE SCHEDULE H AND I DATA - ALL YEARS 2014-2023
********************************************************************************

// Loop through all years and merge Schedule H and I data
foreach file of local files {
    use $data/5500_long_dta/`file', clear
    display "`file'"
    drop plan_eff_date
    local year = substr("`file'", 11, 4)
    display "`year'"
    
    // Merge Schedule H
    merge 1:1 ack_id using "$data/5500_sch_h_dta/5500_sch_h_`year'.dta"
    drop if _merge == 2 
    drop _merge
    
    // Merge Schedule I
    merge 1:1 ack_id using "$data/5500_sch_i_dta/5500_sch_i_`year'.dta"
    drop if _merge == 2 
    drop _merge

    // Drop all companies with welfare plan not pension plan
    drop if strpos(type_welfare_bnft_code, "4") > 0
    drop type_welfare_bnft_code
    
    // Ensure all variables are numeric
    foreach var in sch_h_tax_prd sch_i_tax_prd ///
                   sch_h_pn sch_i_plan_num ///
                   sch_h_ein sch_i_ein ///
                   tot_assets_boy_amt small_tot_assets_boy_amt ///
                   net_assets_boy_amt small_net_assets_boy_amt ///
                   tot_assets_eoy_amt small_tot_assets_eoy_amt ///
                   net_assets_eoy_amt small_net_assets_eoy_amt {
        capture confirm numeric variable `var'
        if _rc != 0 {
            destring `var', replace force
        }
    }
    
    // Combine Schedule H and I variables
    replace sch_h_tax_prd = sch_i_tax_prd if missing(sch_h_tax_prd)
    replace sch_h_pn = sch_i_plan_num if missing(sch_h_pn)
    replace sch_h_ein = sch_i_ein if missing(sch_h_ein)

    replace tot_assets_boy_amt = small_tot_assets_boy_amt if missing(tot_assets_boy_amt)
    replace net_assets_boy_amt = small_net_assets_boy_amt if missing(net_assets_boy_amt)
    replace tot_assets_eoy_amt = small_tot_assets_eoy_amt if missing(tot_assets_eoy_amt)
    replace net_assets_eoy_amt = small_net_assets_eoy_amt if missing(net_assets_eoy_amt)

    drop sch_i_tax_prd sch_i_plan_num sch_i_ein ///
        small_tot_assets_boy_amt small_net_assets_boy_amt ///
        small_tot_assets_eoy_amt small_net_assets_eoy_amt
 
    save "$data/5500_merged/5500_merged_`year'", replace
}


********************************************************************************
// APPEND ALL YEARS INTO MASTER DATASET
********************************************************************************

local files : dir "$data/5500_merged" files "*.dta"

use "$data/5500_merged/5500_merged_2024.dta", clear

foreach file of local files {
    local year = substr("`file'", 13, 4)
    if "`year'" == "2024" continue
    
    append using "$data/5500_merged/5500_merged_`year'.dta"
}

save "$data/5500_master.dta", replace










********************************************************************************
// Project: ESOP Firm and State Panel Creation
// Authors: Soren Pack | Mitchel Balif | Patrick Beal | Will Cheney
// Date: 2025-11-11
// Purpose: Convert 5500 data into firm-year and state-year panel datasets
********************************************************************************

// Setup
clear all
set more off
set varabbrev off

// global pid "sohen33"
global pid "mwballif"
global data "Downloads"


********************************************************************************
// LOAD AND PREPARE FIRM-LEVEL DATA
********************************************************************************

use "$data/5500_master.dta", clear

// Create indicator for if plan is ESOP plan
gen esop_plan = 0
gen total_plans = 1

replace esop_plan = 1 if strpos(type_pension_bnft_code, "2P") > 0 | ///
    strpos(type_pension_bnft_code, "2Q") > 0 | ///
    strpos(type_pension_bnft_code, "2O") > 0

// Create ESOP-specific outcome variables
local outcomes tot_partcp_boy_cnt tot_active_partcp_cnt partcp_account_bal_cnt ///
    tot_assets_boy_amt net_assets_boy_amt tot_assets_eoy_amt net_assets_eoy_amt

foreach var of local outcomes {
    gen esop_`var' = `var' if esop_plan == 1
} 

// Create state indicators
gen CO = spons_dfe_mail_us_state == "CO"
gen IA = spons_dfe_mail_us_state == "IA"
gen MO = spons_dfe_mail_us_state == "MO"
gen UT = spons_dfe_mail_us_state == "UT"

// Create year variable from tax period
gen year_numeric = floor(form_tax_prd / 10000)
gen month = floor((form_tax_prd - year_numeric * 10000) / 100)
gen year = year_numeric if month < 7
replace year = year_numeric + 1 if month >= 7

// Add state FIPS codes
statastates, abbreviation(spons_dfe_mail_us_state)

sort spons_dfe_ein year

********************************************************************************
// CREATE FIRM-YEAR PANEL
********************************************************************************

// Collapse multiple filings per firm to one observation per firm-year
collapse ///
    (sum) esop_* `outcomes' ///
    (max) CO IA MO ///
    (max) state_fips ///
    , by(spons_dfe_ein year)
	
gen esop_partcp_rate = esop_tot_active_partcp_cnt / tot_active_partcp_cnt
gen esop_firm = 1 if esop_plan >=1
compress
save "$data/esop_firm_panel", replace


********************************************************************************
// CREATE STATE-YEAR PANEL
********************************************************************************

sort spons_dfe_ein year

// Create transition indicator
by spons_dfe_ein: gen esop_transition = (esop_firm == 1 & esop_firm[_n-1] == 0)

gen firm = 1

// Collapse to state-year level
collapse ///
    (sum) num_esop_firms = esop_firm ///
    (sum) num_transitions = esop_transition ///
    (sum) total_firms = firm ///
    (sum) esop_* `outcomes' ///
    (mean) CO IA MO ///
    , by(state_fips year)

// Create rates
gen esop_firm_share = num_esop_firms / total_firms
gen transition_rate = num_transitions / total_firms
gen state_esop_partcp_rate = esop_tot_active_partcp_cnt / tot_active_partcp_cnt

save "C:/Users/$pid/Box/esop-tax-credit-did/data/clean_data/esop_state_panel", replace