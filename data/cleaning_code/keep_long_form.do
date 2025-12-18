/*
Loop through the Long forms and save needed variables

11/11/2025

Soren Pack

sohen33

*/

* Set local var list to loop through
cd "C:\Users\sohen33\Box\esop-tax-credit-did\data\raw\long_form_unrestricted"
global data "C:\Users\sohen33\Box\esop-tax-credit-did\data\raw\long_form_unrestricted\"
set varabbrev off
local files : dir "$data" files "*.csv"

* Loop through long forms
foreach file of local files {
	import delimited $data\`file', clear
	display "`file'"
	local date = substr("`file'",-15,4)
	
	keep ack_id spons_dfe_ein spons_dfe_pn plan_name form_plan_year_begin_date form_tax_prd sponsor_dfe_name business_code tot_partcp_boy_cnt tot_act_partcp_boy_cnt tot_active_partcp_cnt partcp_account_bal_cnt type_pension_bnft_code type_welfare_bnft_code spons_dfe_mail_us_city spons_dfe_mail_us_state spons_dfe_mail_us_zip plan_eff_date
	
// 	keep if strpos(type_pension_bnft_code, "2P") > 0 | strpos(type_pension_bnft_code, "2Q") > 0 | strpos(type_pension_bnft_code, "2O") > 0
	
// 	keep if strpos(type_pension_bnft_code, "2O") > 0 | strpos(type_pension_bnft_code, "2P") > 0 | strpos(type_pension_bnft_code, "2Q") > 0 | strpos(type_welfare_bnft_code, "2O") > 0 | strpos(type_welfare_bnft_code, "2P") > 0 | strpos(type_welfare_bnft_code, "2Q") > 0

	save "$data\long_form_unrestricted_`date'", replace
}
