#INCLUDE 'PROTHEUS.CH'

//-------------------------------------------------------------------
/*{Protheus.doc} RUP_WMS
Função de compatibilização do release incremental.
Ser„o chamadas todas as funcoes compiladas referentes aos mÛdulos cadastrados do Protheus
Ser· sempre considerado prefixo "RUP_" acrescido do nome padr„o do mÛdulo sem o prefixo SIGA.
Ex: para o mÛdulo SIGACTB criar a função RUP_CTB

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (paÌs). Ex: BRA

@Author  Guilherme A. Metzger
@since   19/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static __cEmpWms := ""
Function RUP_WMS( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
Local aArea  := GetArea()

	// Os conouts est„o colocados com objetivo de facilitar a identificação de quais comandos foram executados.
	// Se no futuro n„o existir mais necessidade de determinados comandos, os mesmos podem ser eliminados.
	// Importante! N„o colocar acentuação.

	// Criamos um padr„o para facilitar a localização das funcoes, onde:
	// WMSU       (Prefixo WMS)
	//     M1     (Modo de Execução)
	//       0001 (Número Sequencial da Função)

	conout('[RUP_WMS] Verificando necessidade de atualizacao...')
	conout('[RUP_WMS] Versao: ' + cVersion + ' / Modo: ' + cMode + ' / Release Inicial: ' + cRelStart + ' Release Final:  ' + cRelFinish)

	// Necessidade de alteração única por grupo de empresas
	If cMode == "1"
		conout("[RUP WMS] - cMode: "+cMode+" - Empresa: "+AllTrim(cEmpAnt)+" - Filial: "+AllTrim(cFilAnt))
		If cRelStart >= '006'
			WMSUM10001()
			WMSUM10002()
			WMSUM10003()
			WMSUM10004()
		EndIf
		
		If cRelStart >= '016'
			WMSUM10005()
			WMSUM10006()
		EndIf

	ElseIf cMode == "2"
		conout("[RUP WMS] - cMode: "+cMode+" - Empresa: "+AllTrim(cEmpAnt)+" - Filial: "+AllTrim(cFilAnt))

		If cRelStart >= '006'
			WMSUM20001()
		EndIf

		If cRelStart >= '016'
			WMSUM20002()
			WMSUM20003()
			WMSUM20004()
			WMSUM20005()
			WMSUM20006()
			WMSUM20007()
			WMSUM20008()
		EndIf
		// Salva a empresa anterior para validar as filiais das tabelas
		__cEmpWms := cEmpAnt
	EndIf

RestArea( aArea )
Return

Static Function WMSUM10001()

	SX1->(DbSetOrder(1)) // X1_GRUPO+X1_ORDEM
	If SX1->(DbSeek(PadR('OMS200',Len(SX1->X1_GRUPO))+'19')) .And. 'ARMAZEM' $ Upper(SX1->X1_PERGUNT)
		conout("[RUP_WMS] Excluindo o campo 'Armazem ate ?' do pergunte OMS200.")
		RecLock('SX1',.F.)
		SX1->(DbDelete())
		SX1->(MsUnlock())
		SX1->(dbCommit())
	EndIf

Return

Static Function WMSUM10002()
Local aDados := {}

	conout("[RUP_WMS] Alterando a propriedade browse do campo D02_DTVALI para nao.")
	aAdd(aDados,{ {"D02_DTVALI"},{{"X3_BROWSE","N"}} })

	conout("[RUP_WMS] Alterando a propriedade browse do campo D04_DTVALI para nao.")
	aAdd(aDados,{ {"D04_DTVALI"},{{"X3_BROWSE","N"}} })

	conout("[RUP_WMS] Alterando o campo D04_IDDCF para nao usado e a propriedade browse para nao.")
	aAdd(aDados,{ {"D04_IDDCF"},{{"X3_BROWSE","N"}} })
	aAdd(aDados,{ {"D04_IDDCF"},{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"}} })

	conout("[RUP_WMS] Alterando o campo D02_IDDCF para nao usado e a propriedade browse para nao.")
	aAdd(aDados,{ {"D02_IDDCF"},{{"X3_BROWSE","N"}} })
	aAdd(aDados,{ {"D02_IDDCF"},{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"}} })

Return WmsEngSx3(aDados)

Static Function WMSUM10003()
Local aDados := {}

	conout("[RUP_WMS] Alterando o inicializador padrao do campo DCY_DPROD.")
	aAdd(aDados,{ {"DCY_DPROD"},{{"X3_RELACAO","RetField('SB1',1,xFilial('SB1')+DCY->DCY_PROD,'B1_DESC')"}} })
	    
Return WmsEngSx3(aDados)

Static Function WMSUM10004()
Local aDados := {}

	conout("[RUP_WMS] Atualizando o inicializador padrao do campo DC3_DESEST.")
	aAdd(aDados,{ {"DC3_DESEST"},{{"X3_RELACAO"," "}} })
	
	conout("[RUP_WMS] Atualizando o inicializador padrao do campo DC3_DESNOR.")
	aAdd(aDados,{ {"DC3_DESNOR"},{{"X3_RELACAO"," "}} })
	
	conout("[RUP_WMS] Atualizando o inicializador padrao do campo DC3_TPESTR.")
	aAdd(aDados,{ {"DC3_TPESTR"},{{"X3_WHEN"," "}} })
	
	conout("[RUP_WMS] Atualizando o inicializador padrao do campo DC3_TIPREP.")
	aAdd(aDados,{ {"DC3_TIPREP"},{{"X3_WHEN"," "}} })
	
	conout("[RUP_WMS] Atualizando o inicializador padrao do campo DC3_PERREP.")
	aAdd(aDados,{ {"DC3_PERREP"},{{"X3_WHEN"," "}} })
	
	conout("[RUP_WMS] Atualizando o inicializador padrao do campo DC3_PERAPM.")
	aAdd(aDados,{ {"DC3_PERAPM"},{{"X3_WHEN"," "}} })
	
Return WmsEngSx3(aDados)

Static Function WMSUM10005()
Local aDados := {}

	conout("[RUP_WMS] Desabilitando o campo DCS_DOCTO.")
	aAdd(aDados,{ {"DCS_DOCTO"},{{"X3_ORDEM","ZZ"}} })
	aAdd(aDados,{ {"DCS_DOCTO"},{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"}} })
	aAdd(aDados,{ {"DCS_DOCTO"},{{"X3_RESERV","ÇA"}} })
	aAdd(aDados,{ {"DCS_DOCTO"},{{"X3_BROWSE","N"}} })
	
	conout("[RUP_WMS] Desabilitando o campo DCS_ORIGEM.")
	aAdd(aDados,{ {"DCS_ORIGEM"},{{"X3_ORDEM","ZZ"}} })
	aAdd(aDados,{ {"DCS_ORIGEM"},{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"}} })
	aAdd(aDados,{ {"DCS_ORIGEM"},{{"X3_RESERV","ÇA"}} })
	aAdd(aDados,{ {"DCS_ORIGEM"},{{"X3_BROWSE","N"}} })
	
	conout("[RUP_WMS] Desabilitando o campo DCT_DOCTO.")
	aAdd(aDados,{ {"DCT_DOCTO"},{{"X3_ORDEM","ZZ"}} })
	aAdd(aDados,{ {"DCT_DOCTO"},{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"}} })
	aAdd(aDados,{ {"DCT_DOCTO"},{{"X3_RESERV","ÇA"}} })
	aAdd(aDados,{ {"DCT_DOCTO"},{{"X3_BROWSE","N"}} })

	conout("[RUP_WMS] Desabilitando o campo DCT_ORIGEM.")
	aAdd(aDados,{ {"DCT_ORIGEM"},{{"X3_ORDEM","ZZ"}} })
	aAdd(aDados,{ {"DCT_ORIGEM"},{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"}} })
	aAdd(aDados,{ {"DCT_ORIGEM"},{{"X3_RESERV","ÇA"}} })
	aAdd(aDados,{ {"DCT_ORIGEM"},{{"X3_BROWSE","N"}} })

	conout("[RUP_WMS] Desabilitando o campo DCT_IDDCF.")
	aAdd(aDados,{ {"DCT_IDDCF"},{{"X3_ORDEM","ZZ"}} })
	aAdd(aDados,{ {"DCT_IDDCF"},{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"}} })
	aAdd(aDados,{ {"DCT_IDDCF"},{{"X3_RESERV","ÇA"}} })
	aAdd(aDados,{ {"DCT_IDDCF"},{{"X3_BROWSE","N"}} })

	conout("[RUP_WMS] Desabilitando o campo DCT_QTLIBE.")
	aAdd(aDados,{ {"DCT_QTLIBE"},{{"X3_ORDEM","ZZ"}} })
	aAdd(aDados,{ {"DCT_QTLIBE"},{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"}} })
	aAdd(aDados,{ {"DCT_QTLIBE"},{{"X3_RESERV","ÇA"}} })
	aAdd(aDados,{ {"DCT_QTLIBE"},{{"X3_BROWSE","N"}} })

	conout("[RUP_WMS] Alterando a visualizando de browse do campo DCT_STATUS.")
	aAdd(aDados,{ {"DCT_STATUS"},{{"X3_BROWSE","N"}} })
	
Return WmsEngSx3(aDados)

Static Function WMSUM10006()
Local aDados := {}
	
	conout("[RUP_WMS] Removendo obrigatoriedade do campo D08_DATENT.")
	aAdd(aDados,{ {"D08_DATENT"},{{"X3_RESERV","  "}} })
	
	conout("[RUP_WMS] Alterando conteúdo X3_CBOX do campo D12_STATUS.")
	conout("[RUP_WMS] Ajustando contexto do campo D12_NOMREC de real para virtual.")
	aAdd(aDados,{ {"D12_STATUS"},{{"X3_CBOX","0=Estornada;1=Executada;2=Interrompida;3=Em Execução;4=A Executar"}} })
	aAdd(aDados,{ {"D12_NOMREC"},{{"X3_CONTEXT","V"}} })
	
	conout("[RUP_WMS] Ajustando para o campo DC6_SOLEND aparecer no mÛdulo WMS.")
	aAdd(aDados,{ {"DC6_SOLEND"},{{"X3_USANDO","ÄÄÄÄÄâÄÄÄÄÄÄÄÄÄ"}} })
	aAdd(aDados,{ {"DC6_SOLEND"},{{"X3_RESERV","ÜA"}} })
	
	conout("[RUP_WMS] Ajustando tamanho dos campos hora da tabela D00 de 5 para 8 posições.")
	aAdd(aDados,{ {"D00_HOREND"},{{"X3_TAMANHO",8}} })
	aAdd(aDados,{ {"D00_HRENDF"},{{"X3_TAMANHO",8}} })
	aAdd(aDados,{ {"D00_HORDOC"},{{"X3_TAMANHO",8}} })
	aAdd(aDados,{ {"D00_HRDOCF"},{{"X3_TAMANHO",8}} })
	aAdd(aDados,{ {"D00_HOREMB"},{{"X3_TAMANHO",8}} })
	aAdd(aDados,{ {"D00_HREMBF"},{{"X3_TAMANHO",8}} })
	
	conout("[RUP_WMS] Ajustando campos da DCF para usado.")
	aAdd(aDados,{ {"DCF_SEQUEN"},{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ†"}} })
	aAdd(aDados,{ {"DCF_IDORI" },{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ†"}} })
	aAdd(aDados,{ {"DCF_LOCDES"},{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ†"}} })
	aAdd(aDados,{ {"DCF_ENDDES"},{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ†"}} })
	aAdd(aDados,{ {"DCF_PRDORI"},{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ†"}} })
	aAdd(aDados,{ {"DCF_CODREC"},{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ†"}} })
	aAdd(aDados,{ {"DCF_CODPLN"},{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ†"}} })
	aAdd(aDados,{ {"DCF_DOCPEN"},{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ†"}} })
	aAdd(aDados,{ {"DCF_SDOCOR"},{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ†"}} })
	aAdd(aDados,{ {"DCF_SDOC"  },{{"X3_USADO","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ†"}} })
	
	conout("[RUP_WMS] Ajustando obrigatoriedade dos campos D0A_ENDER e D0A_QTDMOV.")
	aAdd(aDados,{ {"D0A_ENDER" },{{"X3_RESERV","óÄ"}} })
	aAdd(aDados,{ {"D0A_QTDMOV"},{{"X3_RESERV","óÄ"}} })

Return WmsEngSx3(aDados)

Static __cModSBE := ""
Static Function WMSUM20001()
Local cFilSBE    := ""
Local cFilDC7    := ""
Local cQuery     := ""
Local cAliasSBE  := ""
Local cCodCfgVz  := Space(TamSx3("BE_CODCFG")[1])
Local cCodZonVz  := Space(TamSx3("BE_CODZON")[1])
Local cEstFisVz  := Space(TamSx3("BE_ESTFIS")[1])
Local aValNiv    := {}

	DbSelectArea('SBE') // ForÁa atualização da tabela

	If Empty(__cModSBE)
		__cModSBE := FWModeAccess("SBE",3)
	EndIf
	// Se for a mesma empresa anterior e a tabela for compartilhada, n„o roda novamente
	If __cEmpWms == cEmpAnt .And. __cModSBE == "C"
		Return
	EndIf

	__cModSBE := FWModeAccess("SBE",3)
	cFilSBE  := FWxFilial("SBE",/*cEmpUDFil*/,FWModeAccess("SBE",1),FWModeAccess("SBE",2),__cModSBE)
	cFilDC7  := FWxFilial("DC7",/*cEmpUDFil*/,FWModeAccess("DC7",1),FWModeAccess("DC7",2),FWModeAccess("DC7",3))

	conout("[RUP_WMS] Ajustando os campos niveis da tabela SBE.")

	conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

	cQuery := "SELECT SBE.BE_CODCFG,"
	cQuery +=       " SBE.BE_LOCALIZ,"
	cQuery +=       " SBE.R_E_C_N_O_ RECNOSBE"
	cQuery +=  " FROM "+RetSqlName('SBE')+" SBE"
	cQuery += " WHERE SBE.BE_FILIAL  = '"+cFilSBE+"'"
	cQuery +=   " AND SBE.BE_CODCFG  <> '"+cCodCfgVz+"'"
	cQuery +=   " AND SBE.BE_CODZON  <> '"+cCodZonVz+"'"
	cQuery +=   " AND SBE.BE_ESTFIS  <> '"+cEstFisVz+"'"
	cQuery +=   " AND SBE.BE_VALNV1  = 0"
	cQuery +=   " AND EXISTS (SELECT 1 "
	cQuery +=                 " FROM "+RetSqlName('DC7')+" DC7"
	cQuery +=                " WHERE DC7.DC7_FILIAL  = '"+cFilDC7+"'"
	cQuery +=                  " AND DC7.DC7_CODCFG = SBE.BE_CODCFG"
	cQuery +=                  " AND DC7.D_E_L_E_T_ = ' ')"
	cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasSBE := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSBE,.F.,.T. )
	While !(cAliasSBE)->(Eof())
		aValNiv := WmsCfgEnd((cAliasSBE)->BE_CODCFG, (cAliasSBE)->BE_LOCALIZ)
		If Len(aValNiv) > 0
			SBE->(DbGoTo((cAliasSBE)->RECNOSBE))
			RecLock("SBE",.F.)
			SBE->BE_VALNV1 := Iif(Len(aValNiv)>0,Val(Str(aValNiv[1,1])),0)
			SBE->BE_VALNV2 := Iif(Len(aValNiv)>1,Val(Str(aValNiv[2,1])),0)
			SBE->BE_VALNV3 := Iif(Len(aValNiv)>2,Val(Str(aValNiv[3,1])),0)
			SBE->BE_VALNV4 := Iif(Len(aValNiv)>3,Val(Str(aValNiv[4,1])),0)
			SBE->BE_VALNV5 := Iif(Len(aValNiv)>4,Val(Str(aValNiv[5,1])),0)
			SBE->BE_VALNV6 := Iif(Len(aValNiv)>5,Val(Str(aValNiv[6,1])),0)
			SBE->(MsUnlock())
			SBE->(dbCommit())
		EndIf
		(cAliasSBE)->(DbSkip())
	EndDo
	(cAliasSBE)->(DbCloseArea())

	conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

Return

Static __cModDCS  := ""
Static __lUIdxDCT := .F.
Static Function WMSUM20002()
Local cFilDCS    := ""
Local cFilDCT    := ""
Local cFilDCU    := ""
Local cFilDCV    := ""
Local cFilD0I    := ""
Local cQuery     := ""
Local cAliasDCS  := ""
Local cAliasDCT  := ""
Local cAliasDCV  := ""
Local lErro      := .F.
Local cCodMnt    := ""
Local cCodMntVz  := Space(TamSx3("DCS_CODMNT" )[1])
Local cPrdLtAnt  := ""
Local aIdDCF     := {}
Local nI         := 1

	DbSelectArea('DCS') // ForÁa atualização da tabela
	DbSelectArea('DCT') // ForÁa atualização da tabela
	DbSelectArea('DCU') // ForÁa atualização da tabela
	DbSelectArea('DCV') // ForÁa atualização da tabela
	DbSelectArea('D0I') // ForÁa atualização da tabela
	
	If Empty(__cModDCS)
		__cModDCS := FWModeAccess("DCS",3)
	EndIf
	// Se for a mesma empresa anterior e a tabela for compartilhada, n„o roda novamente
	If __cEmpWms == cEmpAnt .And. __cModDCS == "C"
		Return
	EndIf

	__cModDCS := FWModeAccess("DCS",3)
	cFilDCS  := FWxFilial("DCS",/*cEmpUDFil*/,FWModeAccess("DCS",1),FWModeAccess("DCS",2),__cModDCS)
	cFilDCT  := FWxFilial("DCT",/*cEmpUDFil*/,FWModeAccess("DCT",1),FWModeAccess("DCT",2),FWModeAccess("DCT",3))
	cFilDCU  := FWxFilial("DCU",/*cEmpUDFil*/,FWModeAccess("DCU",1),FWModeAccess("DCU",2),FWModeAccess("DCU",3))
	cFilDCV  := FWxFilial("DCV",/*cEmpUDFil*/,FWModeAccess("DCV",1),FWModeAccess("DCV",2),FWModeAccess("DCV",3))
	cFilD0I  := FWxFilial("D0I",/*cEmpUDFil*/,FWModeAccess("D0I",1),FWModeAccess("D0I",2),FWModeAccess("D0I",3))

	conout("[RUP_WMS] Atualizacao do processo de montagem de volumes.")
	
	conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

	//InÌcio da transação
	Begin Transaction

	conout("[RUP_WMS] Criando a tabela auxiliar DCS")
	conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

	// Busca os documentos das montagens dentro de um determinado range
	cQuery := "SELECT R_E_C_N_O_ RECNODCS"
	cQuery +=  " FROM " + RetSqlName('DCS')
	cQuery += " WHERE DCS_FILIAL = '"+cFilDCS+"'"
	cQuery +=   " AND DCS_CODMNT = '"+cCodMntVz+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cAliasDCS := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCS,.F.,.T.)

	While !(cAliasDCS)->(Eof()) .And. !lErro

		// Posiciona no documento da montagem
		DCS->(DbGoTo((cAliasDCS)->RECNODCS))

		// Busca um novo cÛdigo de montagem
		cCodMnt := GetSX8Num('DCS','DCS_CODMNT')
		Iif(__lSX8,ConfirmSX8(),.T.)

		RecLock('DCS',.F.)
		DCS->DCS_CODMNT := cCodMnt
		DCS->DCS_QTORIG := DCS->DCS_QTSEPA
		DCS->DCS_LIBPED := "6"
		DCS->DCS_MNTEXC := "2"
		DCS->DCS_LIBEST := "2"
		DCS->(MsUnlock())
		DCS->(dbCommit())

		//----------------------------------------------------------------------------
		// Devido a alteração de Ìndice único das tabelas DCT e DCV, ser· necess·rio
		// aglutinar os registros de mesmo produto/lote/sublote para que n„o ocorram
		// erros de chave duplicada.
		//----------------------------------------------------------------------------

		conout("[RUP_WMS] Criando a tabela auxiliar DCT")
		conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

		// Busca os itens do documento na montagem de volumes
		cQuery := "SELECT DCT_CODPRO,"
		cQuery +=       " DCT_LOTE,"
		cQuery +=       " DCT_SUBLOT,"
		cQuery +=       " DCT_QTSEPA,"
		cQuery +=       " DCT_QTEMBA,"
		cQuery +=       " DCT_IDDCF,"
		cQuery +=       " R_E_C_N_O_ RECNODCT"
		cQuery +=  " FROM " + RetSqlName('DCT')
		cQuery += " WHERE DCT_FILIAL = '"+cFilDCT+"'"
		cQuery +=   " AND DCT_CODMNT = '"+cCodMntVz+"'"
		cQuery +=   " AND DCT_CARGA  = '"+DCS->DCS_CARGA+"'"
		cQuery +=   " AND DCT_PEDIDO = '"+DCS->DCS_PEDIDO+"'"
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY DCT_CODPRO,DCT_LOTE,DCT_SUBLOT"
		cAliasDCT := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCT,.F.,.T.)

		While !(cAliasDCT)->(Eof()) .And. !lErro
			// No primeiro loop ou caso seja um produto/lote diferente do anterior, atualiza
			// o cÛdigo de montagem e guarda as informações para as interações seguintes
			If cPrdLtAnt != (cAliasDCT)->DCT_CODPRO+(cAliasDCT)->DCT_LOTE+(cAliasDCT)->DCT_SUBLOT
				cPrdLtAnt := (cAliasDCT)->DCT_CODPRO+(cAliasDCT)->DCT_LOTE+(cAliasDCT)->DCT_SUBLOT
				cRecnoAnt := (cAliasDCT)->RECNODCT
				// Guarda o ID da DCF para gravar na D0I
				// Mesmo sendo lotes diferentes, podem ter origem na mesma DCF
				If AScan(aIdDCF,(cAliasDCT)->DCT_IDDCF) <= 0
					aAdd(aIdDCF,(cAliasDCT)->DCT_IDDCF)
				EndIf
				// Posiciona no registro correspondente
				DCT->(DbGoTo(cRecnoAnt))
				// Atualiza o cÛdigo de montagem e demais informações
				RecLock("DCT",.F.)
				DCT->DCT_CODMNT := cCodMnt
				DCT->DCT_PRDORI := (cAliasDCT)->DCT_CODPRO
				DCT->DCT_QTORIG := (cAliasDCT)->DCT_QTSEPA
				DCT->(MsUnlock())
				DCT->(dbCommit())
			Else
				// Guarda o ID da DCF para gravar na D0I
				// Mesmo sendo lotes iguais, podem ter origem em DCFs diferentes
				If AScan(aIdDCF,(cAliasDCT)->DCT_IDDCF) <= 0
					aAdd(aIdDCF,(cAliasDCT)->DCT_IDDCF)
				EndIf
				// Deleta o registro duplicado da DCT
				If TcSQLExec("DELETE FROM "+RetSqlName('DCT')+" WHERE R_E_C_N_O_ = " + Str((cAliasDCT)->RECNODCT)) < 0
					MsgStop("Erro encontrado ao tentar excluir um registro duplicado da tabela DCT:" + CRLF + TcSQLError())
					lErro := .T.
					Exit
				EndIf
				// Posiciona no registro anterior
				DCT->(DbGoTo(cRecnoAnt))
				// Atualiza apenas as quantidades
				RecLock("DCT",.F.)
				DCT->DCT_QTSEPA += (cAliasDCT)->DCT_QTSEPA
				DCT->DCT_QTORIG += (cAliasDCT)->DCT_QTSEPA
				DCT->DCT_QTEMBA += (cAliasDCT)->DCT_QTEMBA
				DCT->(MsUnlock())
				DCT->(dbCommit())
			EndIf
			(cAliasDCT)->(DbSkip())
		EndDo
		(cAliasDCT)->(DbCloseArea())
		cPrdLtAnt := ""

		If lErro
			Exit
		EndIf

		conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

		conout("[RUP_WMS] Atualizando tabela DCU")
		conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

		// Atualiza a montagem de volumes
		cQuery := "UPDATE " + RetSqlName('DCU')
		cQuery +=   " SET DCU_CODMNT = '"+cCodMnt+"'"
		cQuery += " WHERE DCU_FILIAL = '"+cFilDCU+"'"
		cQuery +=   " AND DCU_CODMNT = '"+cCodMntVz+"'"
		cQuery +=   " AND DCU_CARGA  = '"+DCS->DCS_CARGA+"'"
		cQuery +=   " AND DCU_PEDIDO = '"+DCS->DCS_PEDIDO+"'"
		cQuery +=   " AND D_E_L_E_T_ = ' '"

		If TcSQLExec(cQuery) < 0
			MsgStop("Erro ao tentar atualizar a tabela DCU:" + CRLF + TcSQLError())
			lErro := .T.
			Exit
		EndIf

		conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

		conout("[RUP_WMS] Criando a tabela auxiliar DCV")
		conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

		// Atualiza itens da montagem de volumes
		cQuery := "SELECT DCV.R_E_C_N_O_ RECNODCV"
		cQuery +=  " FROM "+RetSqlName('DCV')+" DCV,"
		cQuery +=           RetSqlName('DCU')+" DCU"
		cQuery += " WHERE DCV.DCV_FILIAL = '"+cFilDCV+"'"
		cQuery +=   " AND DCV.DCV_CODMNT = '"+cCodMntVz+"'"
		cQuery +=   " AND DCV.DCV_CODVOL = DCU.DCU_CODVOL"
		cQuery +=   " AND DCV.D_E_L_E_T_ = ' '"
		cQuery +=   " AND DCU.DCU_FILIAL = '"+cFilDCU+"'"
		cQuery +=   " AND DCU.DCU_CARGA  = '"+DCS->DCS_CARGA+"'"
		cQuery +=   " AND DCU.DCU_PEDIDO = '"+DCS->DCS_PEDIDO+"'"
		cQuery +=   " AND DCU.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasDCV := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCV,.F.,.T.)

		While !(cAliasDCV)->(Eof())
			// Posiciona no registro correspondente
			DCV->(DbGoTo((cAliasDCV)->RECNODCV))
			// Atualiza com o cÛdigo de montagem e demais informações
			RecLock("DCV",.F.)
			DCV->DCV_CODMNT := cCodMnt
			DCV->DCV_CARGA  := DCS->DCS_CARGA
			DCV->DCV_PEDIDO := DCS->DCS_PEDIDO
			DCV->DCV_PRDORI := DCV->DCV_CODPRO
			DCV->DCV_ITEM   := WmsGetItem(DCS->DCS_CARGA,DCS->DCS_PEDIDO,DCV->DCV_CODPRO,DCV->DCV_LOTE,DCV->DCV_SUBLOT,DCV->DCV_SEQUEN,DCV->DCV_IDDCF)
			DCV->(MsUnlock())
			DCV->(dbCommit())
			(cAliasDCV)->(DbSkip())
		EndDo
		(cAliasDCV)->(DbCloseArea())

		conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

		// Atualiza a tabela de Montagem de Volumes x OS
		For nI := 1 To Len(aIdDCF)
			RecLock("D0I",.T.)
			D0I->D0I_FILIAL := cFilD0I
			D0I->D0I_CODMNT := cCodMnt
			D0I->D0I_IDDCF  := aIdDCF[nI]
			D0I->(MsUnlock())
			D0I->(dbCommit())
		Next

		// Limpa as vari·veis de controle
		cPrdLtAnt := ""
		cRecnoAnt := 0
		aIdDCF    := {}

		(cAliasDCS)->(DbSkip())
	EndDo
	(cAliasDCS)->(DbCloseArea())

	conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

	// Se ocorreu algum erro desfaz a transação
	If lErro
		DisarmTransaction()
	EndIf

	//Fim da transação
	End Transaction

	If !__lUIdxDCT
		// Atualiza o Ìndice único da DCT manualmente apenas depois de aglutinar os seus 
		// registros e que n„o haja registro com DCT_CODMNT em branco, 
		// para que n„o ocorra erro de chave duplicada
		cQuery := "SELECT DCT_FILIAL FROM "+RetSqlName("DCT")
		cQuery += " WHERE DCT_CODMNT = '"+cCodMntVz+"'"
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		cAliasMax := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasMax,.F.,.T.)
		If (cAliasMax)->(Eof())
			UnqIdxDCT()
			__lUIdxDCT := .T.
		EndIf
		(cAliasMax)->(dbCloseArea())
	EndIf
	
	conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

Return

Static __cModDC5 := ""
Static Function WMSUM20003()
Local cFilDC5    := ""
Local cFilSX5    := ""
Local cQuery     := ""
Local cAliasQry  := ""

	DbSelectArea('DC5') // ForÁa atualização da tabela
	
	If Empty(__cModDC5)
		__cModDC5 := FWModeAccess("DC5",3)
	EndIf
	// Se for a mesma empresa anterior e a tabela for compartilhada, n„o roda novamente
	If __cEmpWms == cEmpAnt .And. __cModDC5 == "C"
		Return
	EndIf
	
	__cModDC5 := FWModeAccess("DC5",3)
	cFilDC5 := FWxFilial("DC5",/*cEmpUDFil*/,FWModeAccess("DC5",1),FWModeAccess("DC5",2),__cModDC5)
	cFilSX5 := FWxFilial("SX5",/*cEmpUDFil*/,FWModeAccess("SX5",1),FWModeAccess("SX5",2),FWModeAccess("SX5",3))

	conout("[RUP_WMS] Ajustando tabela DC5 (DC5_OPERAC)")

	conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

	cQuery := " SELECT DC5.R_E_C_N_O_ RECNODC5,SX5.X5_DESCRI"
	cQuery +=   " FROM "+RetSqlName('DC5')+" DC5"
	cQuery +=  " INNER JOIN "+RetSqlName('SX5')+" SX5"
	cQuery +=     " ON SX5.X5_FILIAL = '"+cFilSX5+"'"
	cQuery +=    " AND SX5.X5_CHAVE  = DC5.DC5_FUNEXE"
	cQuery +=    " AND SX5.X5_TABELA = 'L6'"
	cQuery +=  " WHERE DC5.DC5_FILIAL = '"+cFilDC5+"'"
	cQuery +=    " AND DC5.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	While (cAliasQry)->(!Eof())
		cFuncao := Alltrim(Upper((cAliasQry)->X5_DESCRI))
		DC5->(dbGoTo((cAliasQry)->RECNODC5))
		RecLock('DC5',.F.)
		Do Case
			Case cFuncao == "DLENDERECA()"
				DC5->DC5_OPERAC := "1" //EndereÁamento
			Case cFuncao == "DLCROSSDOC()"
				DC5->DC5_OPERAC := "2" //EndereÁamento Crossdocking
			Case cFuncao == "DLAPANHE()" .Or. cFuncao == "DLAPANHEVL()"
				DC5->DC5_OPERAC := "3" //Separação
			Case cFuncao == "DLAPANHEC1()" .Or. cFuncao == "DLAPANHEC2()"
				DC5->DC5_OPERAC := "4"  //Separação Crossdocking
			Case cFuncao == "DLGXABAST()"
				DC5->DC5_OPERAC := "5" //Reabastecimento
			Case cFuncao == "DLCONFENT()"
				DC5->DC5_OPERAC := "6" //ConferÍncia Entrada
			Case cFuncao == "DLCONFSAI()"
				DC5->DC5_OPERAC := "7" //ConferÍncia SaÌda
			Case cFuncao == "DLDESFRAG()" .Or. cFuncao == "DLTRANSFER()"
				DC5->DC5_OPERAC := "8" //TransferÍncia
			Otherwise
				DC5->DC5_OPERAC := ""
		EndCase
		DC5->(MsUnLock())
		DC5->(dbCommit())
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
Return

Static __cModD0K := ""
Static Function WMSUM20004()
Local cFilD0K    := ""
Local cFilDCX    := ""
Local cFilSD1    := ""
Local cQuery     := ""
Local cAliasQry  := ""

	DbSelectArea('D0K') // ForÁa atualização da tabela
	DbSelectArea('SD1') // ForÁa atualização da tabela
	
	If Empty(__cModD0K)
		__cModD0K := FWModeAccess("D0K",3)
	EndIf
	// Se for a mesma empresa anterior e a tabela for compartilhada, n„o roda novamente
	If __cEmpWms == cEmpAnt .And. __cModD0K == "C"
		Return
	EndIf

	__cModD0K := FWModeAccess("D0K",3)
	cFilD0K  := FWxFilial("D0K",/*cEmpUDFil*/,FWModeAccess("D0K",1),FWModeAccess("D0K",2),__cModD0K)
	cFilDCX  := FWxFilial("DCX",/*cEmpUDFil*/,FWModeAccess("DCX",1),FWModeAccess("DCX",2),FWModeAccess("DCX",3))
	cFilSD1  := FWxFilial("SD1",/*cEmpUDFil*/,FWModeAccess("SD1",1),FWModeAccess("SD1",2),FWModeAccess("SD1",3))

	conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

	//InÌcio da transação
	Begin Transaction

	// Busca todos os itens de todos os documentos de entrada que passaram pela
	// ConferÍncia de Recebimento e ainda n„o tenham sido repassados para a nova
	// tabela (para os casos em que um cliente executar o update mais de uma vez)
	cQuery := "SELECT DCX_EMBARQ, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM,"
	cQuery +=       " D1_LOCAL, D1_COD, D1_LOTECTL, D1_NUMLOTE, D1_QUANT"
	cQuery +=  " FROM "+RetSqlName('DCX')+" DCX"
	cQuery += " INNER JOIN "+RetSqlName('SD1')+" SD1"
	cQuery +=    " ON SD1.D1_FILIAL  = '"+cFilSD1+"'"
	cQuery +=   " AND SD1.D1_DOC     = DCX.DCX_DOC"
	cQuery +=   " AND SD1.D1_SERIE   = DCX.DCX_SERIE"
	cQuery +=   " AND SD1.D1_FORNECE = DCX.DCX_FORNEC"
	cQuery +=   " AND SD1.D1_LOJA    = DCX.DCX_LOJA"
	cQuery +=   " AND SD1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE DCX.DCX_FILIAL = '"+cFilDCX+"'"
	cQuery +=   " AND DCX.D_E_L_E_T_ = ' '"
	cQuery +=   " AND NOT EXISTS (SELECT 1 "
	cQuery +=                     " FROM "+RetSqlName('D0K')+" D0K"
	cQuery +=                    " WHERE D0K.D0K_FILIAL = '"+cFilD0K+"'"
	cQuery +=                      " AND D0K.D0K_EMBARQ = DCX.DCX_EMBARQ"
	cQuery +=                      " AND D0K.D0K_DOC    = SD1.D1_DOC"
	cQuery +=                      " AND D0K.D0K_SERIE  = SD1.D1_SERIE"
	cQuery +=                      " AND D0K.D0K_FORNEC = SD1.D1_FORNECE"
	cQuery +=                      " AND D0K.D0K_LOJA   = SD1.D1_LOJA"
	cQuery +=                      " AND D0K.D0K_PROD   = SD1.D1_COD"
	cQuery +=                      " AND D0K.D0K_ITEM   = SD1.D1_ITEM"
	cQuery +=                      " AND D0K.D_E_L_E_T_ = ' ')"
	cQuery += " ORDER BY DCX_EMBARQ, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

	While (cAliasQry)->(!Eof())
		RecLock('D0K',.T.)
		D0K->D0K_FILIAL := cFilD0K
		D0K->D0K_EMBARQ := (cAliasQry)->DCX_EMBARQ
		D0K->D0K_DOC    := (cAliasQry)->D1_DOC
		D0K->D0K_SERIE  := (cAliasQry)->D1_SERIE
		D0K->D0K_FORNEC := (cAliasQry)->D1_FORNECE
		D0K->D0K_LOJA   := (cAliasQry)->D1_LOJA
		D0K->D0K_ITEM   := (cAliasQry)->D1_ITEM
		D0K->D0K_LOCAL  := (cAliasQry)->D1_LOCAL
		D0K->D0K_PROD   := (cAliasQry)->D1_COD
		D0K->D0K_LOTE   := (cAliasQry)->D1_LOTECTL
		D0K->D0K_SUBLOT := (cAliasQry)->D1_NUMLOTE
		D0K->D0K_QUANT  := (cAliasQry)->D1_QUANT
		D0K->(MsUnlock())
		D0K->(dbCommit())
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	//Fim da transação
	End Transaction

	conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

Return

Static __cModD0I := ""
Static Function WMSUM20005()
Local cFilD0I    := ""
Local cFilDCS    := ""
Local cFilDCF    := ""
Local cQuery     := ""
Local cAliasQry  := ""

	DbSelectArea('DCS') // ForÁa atualização da tabela
	DbSelectArea('D0I') // ForÁa atualização da tabela

	If Empty(__cModD0I)
		__cModD0I := FWModeAccess("D0I",3)
	Endif
	// Se for a mesma empresa anterior e a tabela for compartilhada, n„o roda novamente
	If __cEmpWms == cEmpAnt .And. __cModD0I == "C"
		Return
	EndIf

	__cModD0I := FWModeAccess("D0I",3)
	cFilD0I  := FWxFilial("D0I",/*cEmpUDFil*/,FWModeAccess("D0I",1),FWModeAccess("D0I",2),__cModD0I)
	cFilDCS  := FWxFilial("DCS",/*cEmpUDFil*/,FWModeAccess("DCS",1),FWModeAccess("DCS",2),FWModeAccess("DCS",3))
	cFilDCF  := FWxFilial("DCF",/*cEmpUDFil*/,FWModeAccess("DCF",1),FWModeAccess("DCF",2),FWModeAccess("DCF",3))

	conout("[RUP_WMS] Ajustando gravacao da tabela D0I")

	conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

	//Busca todas as DCFs que possuam montagem de volumes
	//e que n„o possuam registro na tabela auxiliar D0I.
	cQuery := " SELECT DCF.DCF_ID, DCS.DCS_CODMNT"
	cQuery +=   " FROM "+RetSqlName('DCF')+" DCF"
	cQuery +=  " INNER JOIN "+RetSqlName('DCS')+" DCS"
	cQuery +=     " ON DCS_FILIAL = '"+cFilDCS+"'"
	cQuery +=    " AND DCS_CARGA  = DCF_CARGA"
	cQuery +=    " AND DCS_PEDIDO = DCF_DOCTO"
	cQuery +=    " AND DCS.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCF_FILIAL = '"+cFilDCF+"'"
	cQuery +=    " AND DCF_ORIGEM = 'SC9'"
	cQuery +=    " AND DCF_STSERV = '3'"
	cQuery +=    " AND DCF.D_E_L_E_T_ = ' '"
	cQuery +=    " AND NOT EXISTS (SELECT D0I_IDDCF"
	cQuery +=                      " FROM "+RetSqlName('D0I')+" D0I"
	cQuery +=                     " WHERE D0I_FILIAL = '"+cFilD0I+"'"
	cQuery +=                       " AND D0I_CODMNT = DCS_CODMNT"
	cQuery +=                       " AND D0I_IDDCF  = DCF_ID"
	cQuery +=                       " AND D0I.D_E_L_E_T_ =  ' ')"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!EoF())
		Reclock("D0I",.T.)
		D0I->D0I_FILIAL := cFilD0I
		D0I->D0I_CODMNT := (cAliasQry)->DCS_CODMNT
		D0I->D0I_IDDCF  := (cAliasQry)->DCF_ID
		D0I->(MsUnlock())
		D0I->(dbCommit())
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

Return

Static __cModD0H := ""
Static Function WMSUM20006()
Local cFilD0H    := ""
Local cFilD01    := ""
Local cFilDCF    := ""
Local cQuery     := ""
Local cAliasQry  := ""

	DbSelectArea('D01') // ForÁa atualização da tabela
	DbSelectArea('D0H') // ForÁa atualização da tabela

	If Empty(__cModD0H)
		__cModD0H := FWModeAccess("D0H",3)
	EndIf
	// Se for a mesma empresa anterior e a tabela for compartilhada, n„o roda novamente
	If __cEmpWms == cEmpAnt .And. __cModD0H == "C"
		Return
	EndIf

	__cModD0H := FWModeAccess("D0H",3)
	cFilD0H  := FWxFilial("D0H",/*cEmpUDFil*/,FWModeAccess("D0H",1),FWModeAccess("D0H",2),__cModD0H)
	cFilD01  := FWxFilial("D01",/*cEmpUDFil*/,FWModeAccess("D01",1),FWModeAccess("D01",2),FWModeAccess("D01",3))
	cFilDCF  := FWxFilial("DCF",/*cEmpUDFil*/,FWModeAccess("DCF",1),FWModeAccess("DCF",2),FWModeAccess("DCF",3))

	conout("[RUP_WMS] Ajustando gravacao da tabela D0H")

	conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

	//Busca todas as DCFs que possuam conferÍncia de expedição
	//e que n„o possuam registro na tabela auxiliar D0H.
	cQuery := " SELECT DCF.DCF_ID, D01.D01_CODEXP"
	cQuery +=   " FROM "+RetSqlName('DCF')+" DCF"
	cQuery +=  " INNER JOIN "+RetSqlName('D01')+" D01"
	cQuery +=     " ON D01_FILIAL = '"+cFilD01+"'"
	cQuery +=    " AND D01_CARGA  = DCF_CARGA"
	cQuery +=    " AND D01_PEDIDO = DCF_DOCTO"
	cQuery +=    " AND D01.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCF_FILIAL = '"+cFilDCF+"'"
	cQuery +=    " AND DCF_ORIGEM = 'SC9'"
	cQuery +=    " AND DCF_STSERV = '3'"
	cQuery +=    " AND DCF.D_E_L_E_T_ = ' '"
	cQuery +=    " AND NOT EXISTS (SELECT D0H_IDDCF"
	cQuery +=                      " FROM "+RetSqlName('D0H')+" D0H"
	cQuery +=                     " WHERE D0H_FILIAL = '"+cFilD0H+"'"
	cQuery +=                       " AND D0H_CODEXP = D01_CODEXP"
	cQuery +=                       " AND D0H_IDDCF  = DCF_ID"
	cQuery +=                       " AND D0H.D_E_L_E_T_ =  ' ')"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!EoF())
		Reclock("D0H",.T.)
		D0H->D0H_FILIAL := cFilD0H
		D0H->D0H_CODEXP := (cAliasQry)->D01_CODEXP
		D0H->D0H_IDDCF  := (cAliasQry)->DCF_ID
		D0H->(MsUnlock())
		D0H->(dbCommit())
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

Return

Static __cModD0J := ""
Static Function WMSUM20007()
Local cFilD0J    := ""
Local cFilD0D    := ""
Local cFilDCF    := ""
Local cQuery     := ""
Local cAliasQry  := ""

	DbSelectArea('D0D') // ForÁa atualização da tabela
	DbSelectArea('D0J') // ForÁa atualização da tabela

	If Empty(__cModD0J)
		__cModD0J := FWModeAccess("D0J",3)
	EndIf
	// Se for a mesma empresa anterior e a tabela for compartilhada, n„o roda novamente
	If __cEmpWms == cEmpAnt .And. __cModD0J == "C"
		Return
	EndIf

	__cModD0J := FWModeAccess("D0J",3)
	cFilD0J  := FWxFilial("D0J",/*cEmpUDFil*/,FWModeAccess("D0J",1),FWModeAccess("D0J",2),__cModD0J)
	cFilD0D  := FWxFilial("D0D",/*cEmpUDFil*/,FWModeAccess("D0D",1),FWModeAccess("D0D",2),FWModeAccess("D0D",3))
	cFilDCF  := FWxFilial("DCF",/*cEmpUDFil*/,FWModeAccess("DCF",1),FWModeAccess("DCF",2),FWModeAccess("DCF",3))

	conout("[RUP_WMS] Ajustando gravacao da tabela D0J")

	conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

	//Busca todas as DCFs que possuam distribuição da separação
	//e que n„o possuam registro na tabela auxiliar D0J.
	cQuery := " SELECT DCF.DCF_ID, D0D.D0D_CODDIS"
	cQuery +=   " FROM "+RetSqlName('DCF')+" DCF"
	cQuery +=  " INNER JOIN "+RetSqlName('D0D')+" D0D"
	cQuery +=     " ON D0D_FILIAL = '"+cFilD0D+"'"
	cQuery +=    " AND D0D_CARGA  = DCF_CARGA"
	cQuery +=    " AND D0D_PEDIDO = DCF_DOCTO"
	cQuery +=    " AND D0D.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCF_FILIAL = '"+cFilDCF+"'"
	cQuery +=    " AND DCF_ORIGEM = 'SC9'"
	cQuery +=    " AND DCF_STSERV = '3'"
	cQuery +=    " AND DCF.D_E_L_E_T_ = ' '"
	cQuery +=    " AND NOT EXISTS (SELECT D0J_IDDCF"
	cQuery +=                      " FROM "+RetSqlName('D0J')+" D0J"
	cQuery +=                     " WHERE D0J_FILIAL = '"+cFilD0J+"'"
	cQuery +=                       " AND D0J_CODDIS = D0D_CODDIS"
	cQuery +=                       " AND D0J_IDDCF  = DCF_ID"
	cQuery +=                       " AND D0J.D_E_L_E_T_ =  ' ')"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!EoF())
		Reclock("D0J",.T.)
		D0J->D0J_FILIAL := cFilD0J
		D0J->D0J_CODDIS := (cAliasQry)->D0D_CODDIS
		D0J->D0J_IDDCF  := (cAliasQry)->DCF_ID
		D0J->(MsUnlock())
		D0J->(dbCommit())
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
Return

Static __cModD0T := ""
Static Function WMSUM20008()
Local cFilD0T    := ""
Local cFilDC1    := ""
Local cQuery     := ""
Local cAliasQry  := ""
Local cAliasD0T  := ""

	DbSelectArea('DC1') // ForÁa atualização da tabela
	DbSelectArea('D0T') // ForÁa atualização da tabela

	If Empty(__cModD0T)
		__cModD0T := FWModeAccess("D0T",3)
	EndIf
	// Se for a mesma empresa anterior e a tabela for compartilhada, n„o roda novamente
	If __cEmpWms == cEmpAnt .And. __cModD0T == "C"
		Return
	EndIf

	__cModD0T := FWModeAccess("D0T",3)
	cFilD0T  := FWxFilial("D0T",/*cEmpUDFil*/,FWModeAccess("D0T",1),FWModeAccess("D0T",2),__cModD0T)
	cFilDC1  := FWxFilial("DC1",/*cEmpUDFil*/,FWModeAccess("DC1",1),FWModeAccess("DC1",2),FWModeAccess("DC1",3))
	
	conout("[RUP_WMS] Ajustando gravacao da tabela D0T")

	conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
	
	// Valida se n„o h· dados na tabela de unitizadores WMS
	cQuery := " SELECT 1"
	cQuery +=   " FROM "+RetSqlName('D0T')+" D0T"
	cQuery +=  " WHERE D0T.D_E_L_E_T_ = ' '"
	cAliasD0T := GetNextAlias()
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasD0T,.F.,.T.)
	If (cAliasD0T)->(EoF())
		//Busca todas as DCFs que possuam distribuição da separação
		//e que n„o possuam registro na tabela auxiliar D0J.
		cQuery := " SELECT DC1.DC1_CODUNI,"
		cQuery +=        " DC1.DC1_DESUNI,"
		cQuery +=        " DC1.DC1_ALTMAX,"
		cQuery +=        " DC1.DC1_LRGMAX,"
		cQuery +=        " DC1.DC1_CMPMAX,"
		cQuery +=        " DC1.DC1_CAPMAX,"
		cQuery +=        " DC1.DC1_EMPMAX,"
		cQuery +=        " DC1.DC1_TARA"
		cQuery +=   " FROM "+RetSqlName('DC1')+" DC1"
		cQuery +=  " WHERE DC1_FILIAL = '"+cFilDC1+"'"
		cQuery +=    " AND NOT EXISTS(SELECT 1"
		cQuery +=                     " FROM "+RetSqlName('D0T')+" D0T"
		cQuery +=                    " WHERE D0T.D0T_FILIAL = '"+cFilD0T+"'"
		cQuery +=                      " AND D0T.D0T_CODUNI = DC1.DC1_CODUNI"
		cQuery +=                      " AND D0T.D_E_L_E_T_ = ' ')"
		cQuery +=    " AND DC1.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		While (cAliasQry)->(!EoF())
			Reclock("D0T",.T.)
			D0T->D0T_FILIAL := cFilD0T
			D0T->D0T_CODUNI := (cAliasQry)->DC1_CODUNI
			D0T->D0T_DESUNI := (cAliasQry)->DC1_DESUNI
			D0T->D0T_ALTURA := (cAliasQry)->DC1_ALTMAX
			D0T->D0T_LARGUR := (cAliasQry)->DC1_LRGMAX
			D0T->D0T_COMPRI := (cAliasQry)->DC1_CMPMAX
			D0T->D0T_CAPMAX := (cAliasQry)->DC1_CAPMAX
			D0T->D0T_EMPMAX := (cAliasQry)->DC1_EMPMAX
			D0T->D0T_TARA   := (cAliasQry)->DC1_TARA
			D0T->D0T_CTRALT := '1'
			D0T->D0T_CTRNOR := '1'
			D0T->D0T_PADRAO := '1'
			D0T->(MsUnlock())
			D0T->(dbCommit())
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	Else
		conout("[RUP_WMS] Tabela D0T ja possui informacoes, nao sera atualizada.")
	EndIf
	(cAliasD0T)->(DbCloseArea())
	conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
Return

Static Function WmsGetItem(cCarga,cPedido,cProduto,cLote,cSubLote,cSequen,cIdDCF)
Local cFilSC9   := FWxFilial("SC9",/*cEmpUDFil*/,FWModeAccess("SC9",1),FWModeAccess("SC9",2),FWModeAccess("SC9",3))
Local cAliasSC9 := ""
Local cQuery    := ""
Local cItem     := ""

	cQuery := "SELECT C9_ITEM"
	cQuery +=  " FROM " + RetSqlName('SC9')
	cQuery += " WHERE C9_FILIAL  = '"+cFilSC9+"'"
	cQuery +=   " AND C9_CARGA   = '"+cCarga+"'"
	cQuery +=   " AND C9_PEDIDO  = '"+cPedido+"'"
	cQuery +=   " AND C9_PRODUTO = '"+cProduto+"'"
	cQuery +=   " AND C9_LOTECTL = '"+cLote+"'"
	cQuery +=   " AND C9_NUMLOTE = '"+cSubLote+"'"
	cQuery +=   " AND C9_SEQUEN  = '"+cSequen+"'"
	cQuery +=   " AND C9_IDDCF   = '"+cIdDCF+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cAliasSC9 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSC9,.F.,.T.)
	If !(cAliasSC9)->(Eof())
		cItem := (cAliasSC9)->C9_ITEM
	EndIf
	(cAliasSC9)->(DbCloseArea())

Return cItem

Static Function UnqIdxDCT()

	// Atualiza o campo X2_UNICO da tabela de itens dos documentos na montagem de volumes
	SX2->(DbSetOrder(1)) // X2_CHAVE
	If SX2->(DbSeek('DCT'))
		RecLock('SX2',.F.)
		SX2->X2_UNICO := "DCT_FILIAL+DCT_CODMNT+DCT_CARGA+DCT_PEDIDO+DCT_PRDORI+DCT_CODPRO+DCT_LOTE+DCT_SUBLOT"
		SX2->(MsUnlock())
		SX2->(dbCommit())
	EndIf

	// ForÁa o fechamento da ·rea de trabalho tabela de itens dos documentos na montagem de volumes
	DCT->(DbCloseArea())

	// ForÁa a abertura da ·rea de trabalho da tabela de itens dos documentos na montagem de volumes
	// com objetivo de efetivar a alteração e realizar a criação do novo Ìndice único
	DbSelectArea('DCT')

Return

Static __aCfgEnd := {}
Static __aAlpha  := {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'}
Static Function WmsCfgEnd(cCodCfg,cEndereco)
Local aAreaAnt  := GetArea()
Local aRet      := {}
Local aCfgTmp   := Array(2)
Local nCntFor   := 1
Local nPos      := 0
Local nCnt1     := 0
Local nCnt2     := 0
Local cStr1     := ''
Local cStr2     := ''
Local cLetra    := ''
Local cQuery    := ''
Local cAliasDC7 := ''
Local cFilDC7   := FWxFilial("DC7",/*cEmpUDFil*/,FWModeAccess("DC7",1),FWModeAccess("DC7",2),FWModeAccess("DC7",3))
Local nTamNiv   := TamSx3('BE_VALNV1')[1]

Default cCodCfg   := CriaVar('DC7_CODCFG', .F.)
Default cEndereco := CriaVar('BE_LOCALIZ', .F.)

	//-- Formato do Array aRet:
	//-- aRet[n,1] = Codigo do Endereco separado por Nivel
	//-- aRet[n,2] = Peso do Nivel (Deve ser DESCONSIDERADO para o ultimo Nivel)
	//-- aRet[n,3] = Peso do Lado

	If Len(__aCfgEnd) > 0 .And. (nPos:=AScan(__aCfgEnd, {|x|x[1]==cCodCfg}))>0
		aCfgTmp := __aCfgEnd[nPos]
	Else
		aCfgTmp[1] := cCodCfg
		aCfgTmp[2] := {} //Array vazio
		cAliasDC7 := GetNextAlias()
		cQuery := "SELECT DC7_POSIC,DC7_PESO1,DC7_PESO2"
		cQuery += "  FROM "+RetSqlName('DC7')+" DC7"
		cQuery += " WHERE DC7_FILIAL = '"+cFilDC7+"'"
		cQuery += "   AND DC7_CODCFG = '"+cCodCfg+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY DC7_SEQUEN,DC7_POSIC,DC7_PESO1,DC7_PESO2"
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDC7,.F.,.T.)
		Do While (cAliasDC7)->(!Eof())
			AAdd(aCfgTmp[2],{(cAliasDC7)->DC7_PESO2, (cAliasDC7)->DC7_PESO1,(cAliasDC7)->DC7_POSIC})
			(cAliasDC7)->(DbSkip())
		EndDo
		(cAliasDC7)->(DbCloseArea())
		AAdd(__aCfgEnd,aCfgTmp)
	EndIf

	For nCnt1 := 1 To Len(aCfgTmp[2])
		cStr1 := AllTrim(Upper(SubStr(cEndereco,nCntFor,aCfgTmp[2,nCnt1,3])))
		cStr2 := ''
		//Transforma a configuração em números seguindo a ordem no ARRAy
		// -> 000 -> '0' = 01 + '0' = 01 + '0' = 01 -> '010101'
		// -> R01 -> 'R' = 28 + '0' = 01 + '1' = 02 -> '280102'
		// -> ZR5 -> 'Z' = 36 + 'R' = 28 + '5' = 06 -> '362806'
		// -> ZZZ -> 'Z' = 36 + 'Z' = 36 + 'Z' = 36 -> '363636'
		For nCnt2 := 1 To Len(cStr1)
			cLetra := SubStr(cStr1, nCnt2, 1)
			nPos   := AScan(__aAlpha, {|x|x==cLetra})
			cStr2  += StrZero(nPos,2)
		Next
		AAdd(aRet, {Val(Substr(cStr2,1,nTamNiv)), aCfgTmp[2,nCnt1,1], aCfgTmp[2,nCnt1,2]})
		nCntFor += aCfgTmp[2,nCnt1,3]
	Next
	If Len(aRet)==0
		conout("[RUP_WMS] Endereco '"+AllTrim(cEndereco)+"' Codigo de Configuracao de Enderecos '"+AllTrim(cCodCfg)+"' nao cadastrado (DC7).")
	EndIf

RestArea(aAreaAnt)
Return(aRet)

//--------------------------------------------------------------------
/*/{Protheus.doc} WmsEngSx3()
Função que executa a macro de ajuste de conteúdo de campos do dicion·rio
referente ao arquivo SX3.
@author felipe.m
@since 04/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WmsEngSx3(aDados)

Local cFunEng := ""
	If Len( aDados ) > 0
		cFunEng  := "EngSX3" + SubStr( GetRpoRelease(),4,1 ) + SubStr( GetRpoRelease(),7,2 ) //monta a macro
		If FindFunction( cFunEng )
			cFunEng := cFunEng + "( aDados )" //monta a macro
			&cFunEng //Executa a macro
		Else
			conout("Função " + cFunEng + " n„o encontrada no rpo.")
		EndIf
	EndIf
Return
