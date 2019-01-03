#INCLUDE "PROTHEUS.CH"

/*
Jean Rehermann - Solutio IT - 11/09/2017
Ponto de entrada na gravação do SDB para definir a prioridade das atividades (DB_PRIORI)
*/

User Function WMSREGRA()

	Local cPrior := SuperGetMV('MV_WMSPRIO', .F., '' ) //-- Prioridade de convocacao no WMS.
	Local cSufix := Iif( Empty( SDB->DB_PRIORI ), SDB->DB_SERIE, Right( AllTrim( SDB->DB_PRIORI ), 2 ) )
	Local cRegra := PARAMIXB[ 1 ] + Iif( Empty( cPrior ), '', &cPrior ) + cSufix
	
    If SDB->DB_ORIGEM == "SC9" .And. SDB->DB_CLIFOR == SuperGetMv("MV_IMDEPA",.F.,"N00000")
    	cRegra := Stuff( cRegra, 3, 1, "1" )
    EndIf

Return( cRegra )