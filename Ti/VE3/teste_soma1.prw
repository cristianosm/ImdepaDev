#include 'protheus.ch'
#include 'parmtype.ch'




user function teste_soma1()
	
local cSequen := '000'


  alert(cSequen)
  
  for n:=1 to 3
   
  cSequen := soma1(cSequen)

   alert(cSequen)
   
   next
   

return