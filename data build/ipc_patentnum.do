cd "C:\study\DATA!!!!\Patent Data\spillover"
unicode encoding set gb18030
unicode analyze *
unicode translate *,invalid(ignore)

cd "C:\study\DATA!!!!\Patent Data\spillover"

foreach  i of numlist 1998/2008{
use reshape`i',clear
drop j corp_num
split chr_classification, p(";") g(ipc)

drop chr_classification 
bys chr_applicationnumber: gen n=_n
keep if n==1
drop n
reshape long ipc, i( chr_applicationnumber) j(j)
drop if ipc==""

drop if regexm(ipc,"//")==1
drop if regexm(ipc,":")==1
drop if regexm(ipc,"∶")==1

*gen a = strpos(ipc,"/")
*gen b = length(ipc)
*gen ipc_code = substr(ipc,1,strpos(ipc,"/")-1) if a != 0
*replace ipc_code = ipc if a == 0

gen ipc_code= ipc

bys ipc_code:gen total_num = _N
bys chr_patenttype ipc_code:gen number = _N
gen design_num = number if chr_patenttype=="外观(3)"
gen invention_num = number if chr_patenttype=="发明(1)"
gen utility_num = number if chr_patenttype=="新型(2)"
gen foreign_num = number if chr_patenttype=="发明(8)" ||  chr_patenttype=="新型(9)"

sort ipc_code invention_num
bys ipc_code:replace invention_num=invention_num[_n-1] if invention_num==.
sort ipc_code utility_num
bys ipc_code:replace utility_num=utility_num[_n-1] if utility_num==.
sort ipc_code foreign_num
bys ipc_code:replace foreign_num=foreign_num[_n-1] if foreign_num==.
sort ipc_code design_num
bys ipc_code:replace design_num=design_num[_n-1] if design_num==.


keep ipc_code total_num invention_num utility_num foreign_num design_num
mvencode _all, mv(0)
duplicates drop
drop if invention_num + utility_num + foreign_num + design_num  != total_num
duplicates list ipc_code
gen year=`i'
save ipcnum_`i'.dta,replace
}


foreach  i of numlist 1998/2008{
use ipcnum_`i',clear
export delimited using "C:\Users\shiki\Desktop\ipcnum`i'.csv", replace
}
/*
preserve 
keep if chr_patenttype=="外观(3)"
gen n = 1
collapse(sum) n , by(ipc_code)
rename n desgin_num
save 3.dta,replace
restore

preserve
keep if chr_patenttype=="发明(1)"
gen n = 1
collapse(sum) n , by(ipc_code)
rename n invention_num
save 1.dta,replace
restore

preserve
keep if chr_patenttype=="新型(2)"
gen n = 1
collapse(sum) n , by(ipc_code)
rename n utility_num
save 2.dta,replace
merge 1:1 ipc_code using 1.dta
drop _merge 
save 4.dta,replace
restore

preserve
keep if chr_patenttype=="发明(8)" ||  chr_patenttype=="新型(9)"
gen n = 1
collapse(sum) n , by(ipc_code)
rename n foreign_num
merge 1:1 ipc_code using 4.dta
drop _merge 
save 5.dta,replace
restore

preserve 
drop if chr_patenttype=="外观(3)"
gen n = 1
collapse(sum) n , by(ipc_code)
rename n invention_num
restore



clear
use

gen  invention_num = number if chr_patenttype=="发明(1)"
gen utility_num = number if chr_patenttype=="新型(2)"
