/*
Loop through the Short forms and save needed variables

11/11/2025

Soren Pack

sohen33

*/

* Set local var list to loop through
cd "C:\Users\sohen33\Box\esop-tax-credit-did\data\raw\short_form"
global data "C:\Users\sohen33\Downloads\"
set varabbrev off
local files : dir "$data\short_form" files "*.csv"

* Loop through long forms
foreach file of local files {
	import delimited $data/short_form/`file', clear
	display "`file'"
	local date = substr("`file'",-15,4)
keep ack_id sf_spons_ein sf_sponsor_dfe_dba_name sf_plan_num sf_plan_name sf_plan_year_begin_date sf_tax_prd sf_sponsor_name sf_business_code sf_tot_partcp_boy_cnt sf_tot_act_partcp_boy_cnt sf_tot_act_partcp_eoy_cnt sf_tot_act_rtd_sep_benef_cnt sf_partcp_account_bal_cnt sf_type_pension_bnft_code sf_type_welfare_bnft_code sf_spons_us_city sf_spons_us_state sf_spons_us_zip
	keep if sf_type_pension_bnft_code == "2O" | sf_type_pension_bnft_code == "2P"|sf_type_welfare_bnft_code == "2O" | sf_type_pension_bnft_code == "2P"
	save "C:\Users\sohen33\Box\esop-tax-credit-did\data\raw\short_form\short_form_`date'", replace
}
