/*
Loop through the H-forms and save needed variables

11/11/2025

Soren Pack

sohen33

*/

* Set local var list to loop through
cd "C:\Users\sohen33\Box\esop-tax-credit-did\data\raw\i_form"
global data "C:\Users\sohen33\Downloads\"
set varabbrev off
local files : dir "$data\i_form" files "*.csv"

* Loop through long forms
foreach file of local files {
	import delimited $data/i_form/`file', clear
	display "`file'"
	local date = substr("`file'",-15,4)
	
 keep ack_id sch_i_ein sch_i_plan_num sch_i_plan_year_begin_date sch_i_tax_prd small_tot_assets_boy_amt small_tot_assets_eoy_amt small_net_assets_eoy_amt small_net_assets_boy_amt
 
	save "C:\Users\sohen33\Box\esop-tax-credit-did\data\raw\i_form\i_form_`date'", replace
}
