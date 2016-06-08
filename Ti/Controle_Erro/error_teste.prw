#INCLUDE "TOTVS.CH"
 
User Function Error_Block()
Local cError      := ""
Local oLastError := ErrorBlock({|e| cError := e:Description + e:ErrorStack})
Local uTemp        := Nil
      
uTemp := "A" + 1
      
ErrorBlock(oLastError)
      
// Anota o erro no console.
Alert(cError)
 
Return