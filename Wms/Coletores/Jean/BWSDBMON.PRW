#INCLUDE "PROTHEUS.CH"

/*
Jean Rehermann - Solutio IT - 11/09/2017
Função utilizada para preenchimento de campos virtuais no browse do monitor de serviços
*/

User Function BWSDBMON( cField )

	Local aArea := GetArea()
	Local cRet  := ""

	Do Case

		Case cField == "DB_TRANSPO"
			If SDB->DB_ORIGEM == "SC9"
				cRet := Posicione("SC5",1,SDB->DB_FILIAL + SDB->DB_DOC,"C5_TRANSP")
				cRet := Posicione("SA4",1,xFilial("SA4") + cRet,"A4_NREDUZ")
            EndIf
		Case cField == "DB_NCLIFOR"
			If SDB->DB_ORIGEM == "SC9"
				cRet := Posicione("SA1",1,xFilial("SA1") + SDB->DB_CLIFOR + SDB->DB_LOJA,"A1_NREDUZ")
			ElseIf SDB->DB_ORIGEM == "SD1"
				cRet := Posicione("SA2",1,xFilial("SA2") + SDB->DB_CLIFOR + SDB->DB_LOJA,"A2_NREDUZ")
			EndIf

		Case cField == "DB_PVOBS"
			If SDB->DB_ORIGEM == "SC9"
				cRet := Posicione("SC5",1,SDB->DB_FILIAL + SDB->DB_DOC,"C5_NUMSUA")
				cRet := Posicione("SUA",1,xFilial("SUA") + cRet,"UA_OBSEXP")
			EndIf
		OtherWise
			cRet := ""

	EndCase

Return( cRet )