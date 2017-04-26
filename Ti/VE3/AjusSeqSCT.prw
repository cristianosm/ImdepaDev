#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "Tbiconn.ch"

#Define CRLF ( chr(13)+chr(10) )
/*
Esta Rotina Ajusta o Sequencial do License para a Tabela SCt Metas em Todas as Filiais que possuem registros...  
*/
*******************************************************************************
User Function AjusSeqSCT()
*******************************************************************************

	Local cMaxID  := ''
	Local cAtuID  := ''
	Local aFilAtv := { }
	Local lSet	  := .F.
	
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME 'AjusSeqSCT'  TABLES 'SM0','SCT'

	VerFilAtivas(@aFilAtv);ConOut('')
	
	For nF := 1 To Len(aFilAtv)

		lSet := RpcSetEnv("01",aFilAtv[nF],Nil,Nil,"FAT","AjusSeqSCT", {"SX6","SCT"} )

		If lSet
			cFilAnt := aFilAtv[nF]

			VerMaxID(@cMaxID)//;ConOut(' Maior ID encontrado: ' + cMaxID )

			VerAtuID(@cAtuID)//;ConOut(' DOC Autal encontrado: ' + cAtuID )

			If cAtuID <= cMaxID
				
				ConOut(' Iniciando Ajuste Filial... ['+aFilAtv[nF]+']' )

				AjustaXENum(cMaxID)

				ConOut(' Filial Ajustada... ['+aFilAtv[nF]+']'  )

			Endif
		Else
			ConOut(" Não conseguiu Setar a Filial "+ aFilAtv[nF] )
		EndIf
	Next

	ConOut('');ConOut('Fim da Rotina...')
	
	RESET ENVIRONMENT

	Return()
*******************************************************************************
Static Function AjustaXENum(cMaxID)
*******************************************************************************

	Local __SpecialKey 	:= Upper(GetSrvProfString("SpecialKey", ""))
	Local cAliasSx8  	:=   PADR( xFilial("SCT")+Upper(x2path("SCT")), 50 )
	Local cChaveSx 		:= __SpecialKey+cAliasSX8+"SCT"
	Local cNum			:= ""
	Local nRet			:= 0

	ConOut(" Maior DOC encontrado na Filial [" + xFilial("SCT") +"] => "+ cMaxID )
	
	cNum := LS_GetNum(cChaveSx) 				; ConOut( " DOC Atual : "+cValToChar( cNum ) )
	nRet := LS_ConfirmNum(cChaveSx, cMaxID ) 	; ConOut( " Confirmando DOC : " + If(cValToChar(nRet)=="0","Ok","Erro"))

	LS_ChangeFreeNum(cChaveSx, cMaxID )	;ConOut( " Alterando DOC para " + cMaxID )

	cNum := LS_GetNum(cChaveSx)				; ConOut(" Proximo DOC : "+ cValToChar( cNum ) )
	nRet := LS_ConfirmNum(cChaveSx, cNum ) 	; ConOut(" Confirmando DOC : " + If(cValToChar(nRet)=="0","Ok","Erro"))
	
	ConOut('')
	
	Return
*******************************************************************************
Static Function CheckDoc(cNexID)
*******************************************************************************

	Local cQuery
	Local cDoc:=' '
	Local lOk:=.F.
	cQuery :=" SELECT CT_DOC  FROM SCT010 SCT "
	cQuery +=" WHERE CT_FILIAL  = '" + xFilial("SCT")	+ "' "
	cQuery +=" AND CT_DOC  = '" + cNexID	+ "' "
	cQuery +=" AND SCT.D_E_L_E_T_ = ' '"

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.T.,.T.)

	DbSelectArea("TRB")
	cDoc:=TRB->CT_DOC
	TRB->( dbCloseArea())

	If Empty(cDoc)
		lOk:=.T.
	Endif

	Return(lOk)
*******************************************************************************
Static Function	VerMaxID(cMaxID)
*******************************************************************************

	cSql := " SELECT MAX(CT_DOC) MAXID FROM SCT010 "
	cSql += " WHERE CT_FILIAL = '"+xFilial("SCT")+"' "
	cSql += " And   CT_RELAUTO = ' ' "
	cSql += " And   CT_DOC < '999999999' "
	cSql += " And   D_E_L_E_T_ = ' ' "

	//dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.T.,.T.)
	U_ExecMySql( cSql, 'TRB', 'Q', .F., .F.  )

	DbSelectArea("TRB")
	cMaxID := cValToChar(TRB->MaxID)
	DbCloseArea()

	Return()
*******************************************************************************
Static Function	VerAtuID(cMaxID)
*******************************************************************************

	cAtuID := GETSXENum("SCT","CT_DOC") //Obtenho a Sequencia do Documeto atual disponivel pelo License

	RollBackSX8()//Devolvo o Controle sem Confirmar

	Return()
*******************************************************************************
Static Function	VerFilAtivas(aFilAtv)
*******************************************************************************
	Local cSql := ""

	cSql := "SELECT DISTINCT CT_FILIAL FILIAL FROM SCT010 GROUP BY CT_FILIAL ORDER BY CT_FILIAL"

	U_ExecMySql( cSql, 'FIA', 'Q', .F., .F.  )

	DbSelectArea("FIA");DbGotop()
	While !Eof()

		Aadd( aFilAtv ,  FIA->FILIAL )

		DbSelectArea("FIA")
		DbSkip()
	EndDo
	DbSelectArea("FIA");DbClose()
Return()