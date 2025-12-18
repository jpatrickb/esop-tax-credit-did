/*
Loop through the H-forms and save needed variables

11/11/2025

Soren Pack

sohen33

*/

* Set local var list to loop through
cd "C:\Users\sohen33\Box\esop-tax-credit-did\data\raw\h_form"
global data "C:\Users\sohen33\Downloads\"
set varabbrev off
local files : dir "$data\h_form" files "*.csv"

* Loop through long forms
foreach file of local files {
	import delimited $data/h_form/`file', clear
	display "`file'"
	local date = substr("`file'",-15,4)
	
 keep ack_id sch_h_ein sch_h_pn sch_h_plan_year_begin_date sch_h_tax_prd tot_assets_boy_amt tot_assets_eoy_amt tot_assets_eoy_amt net_assets_eoy_amt net_assets_boy_amt
 
	save "C:\Users\sohen33\Box\esop-tax-credit-did\data\raw\h_form\h_form_`date'", replace
}
