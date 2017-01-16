#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "Tbiconn.ch"

#Define CRLF ( chr(13)+chr(10) )

*******************************************************************************
User Function AjusSeqSCT()
*******************************************************************************

	Local cMaxID := ''
	Local cAtuID := ''

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "05" FUNNAME 'AjusSeqSCT'  TABLES 'SM0','SCT'

		VerMaxID(@cMaxID);conout(' Maior ID encontrado: ' + cMaxID )

		VerAtuID(@cAtuID);conout(' DOC Autal encontrado: ' + cAtuID )

		If cAtuID <= cMaxID

			conout(' Iniciando Ajuste...'  )

			AjustaXENum(cAtuID , cMaxID)

		Endif

	RESET ENVIRONMENT

Return()
*******************************************************************************
Static Function AjustaXENum(cAtuID,cMaxID)
*******************************************************************************
	Local cHoraInicio   	:= Time()
	Local lJaOk := .F.
	Local nPorx := 10000
	Local nShow := nPorx + Val(cAtuID)


	For i := Val(cAtuID) To Val(cMaxID)
        cNexID := GetLSNum("SCT","CT_DOC") //,cAliasSX8,nOrdem)
		//cNexID := GetSxeNum("SCT","CT_DOC")
		ConfirmSX8()

		if I == nShow
			conout('Processando item '+Str(i) +' de  '+cMaxID+'  ' + Time())
			nShow += nPorx
		EndIf

		//Verifica se já existe o documento
		//lJaOk	:=	CheckDoc(cNexID)
		If lJaOk
			cHoraFim := Time()
			conout('Processo Finalizado com Sucesso !'+Chr(10)+Chr(13)+'Tempo de Processamento :'+ ELAPTIME(cHoraInicio, cHoraFim))
			Exit
		Endif
	Next i

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