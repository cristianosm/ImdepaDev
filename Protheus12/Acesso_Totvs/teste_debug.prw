#Include 'protheus.ch'
#Include 'parmtype.ch'


*******************************************************************************
User Function Teste_Debug()
*******************************************************************************
	
	Local cVersion 		:= "12"
	Local cMode 		:= "2"
	Local cRelStart 	:= "016"
	Local cRelFinish 	:= "017"
	Local cLocaliz 		:= "BRA"

	
	conout("Entrou -> RUP_WMS")
	
	RUP_WMS( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
	
	
	conout("Saiu ->  RUP_WMS")
	
Return