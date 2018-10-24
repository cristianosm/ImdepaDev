#Include 'Totvs.ch'
#Include "Tbiconn.ch"

#Define DINI	1
#Define DFIM	2

#Define DATAREF cTod("04/11/2018") // Domingo

*******************************************************************************
User function teste_dia()
*******************************************************************************
	
	Local aDia 		
	Local dIni	 	
	Local dAux	 	
	Local lAvalia	
	
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "05" FUNNAME 'MetasMargem'  TABLES 'SM0'
	
	aDia 		:= { DATAREF , DATAREF }
	dIni	 	:= DATAREF
	dAux	 	:= dIni
	lAvalia		:= .T.
	
	
	While lAvalia 
	
		dAux := DataValida(dIni,.F.)
		if dAux == dIni
			lAvalia := .F.
			aDia[DINI] := dAux
		Else
			dIni := dAux
		EndIf
	
	EndDo
	
	Conout( "Dia Incial : " + DtOC( aDia[DINI] ) + " -> " + CDOW( aDia[DINI] ) + "  Dia Final: " + DtOC( aDia[DFIM] ) + " -> " + CDOW( aDia[DFIM] ) + " ")

	RESET ENVIRONMENT
	
Return Nil