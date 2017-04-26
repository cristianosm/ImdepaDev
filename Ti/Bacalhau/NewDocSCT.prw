#include 'protheus.ch'
#include 'parmtype.ch'

user function NewDocSCT()
	
Local cDoc := ""	
Local cSql := "SELECT MAX(CT_DOC) FROM SCT010 WHERE CT_FILIAL = '09' AND CT_DOC <= '999999999' AND D_E_L_E_T_ = ' '"


U_ExecMySql( cSql , "NDOC" , "Q", .F., .F. )
	
DbSelectArea(NDOC)
	
	
return