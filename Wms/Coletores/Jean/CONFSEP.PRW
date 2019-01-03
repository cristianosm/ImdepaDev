#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"

#DEFINE TXTIDLOG "ID LOG."
#DEFINE TXTEAN13 "EAN 13"
#DEFINE TXTEAN14 "EAN 14"

#DEFINE BRW2LEG 1
#DEFINE BRW2PED 2
#DEFINE BRW2ATE 3
#DEFINE BRW2CLI 4
#DEFINE BRW2TRA 5
#DEFINE BRW2MUN 6

#DEFINE BRW3ITM 1
#DEFINE BRW3COD 2
#DEFINE BRW3DES 3
#DEFINE BRW3QTD 4
#DEFINE BRW3LID 5
#DEFINE BRW3RES 6
#DEFINE BRW3REC 7
#DEFINE BRW3EMB 8
#DEFINE BRW3DCF 9
#DEFINE BRW3QVA 10

#DEFINE BRW4PRO 1
#DEFINE BRW4VAI 2
#DEFINE BRW4FOI 3
#DEFINE BRW4FAL 4
#DEFINE BRW4BQP 5
#DEFINE BRW4AQP 6
#DEFINE BRW4CNF 7
#DEFINE BRW4ZAR 8

#DEFINE BRW5VOL 1
#DEFINE BRW5PRO 2
#DEFINE BRW5QTO 3
#DEFINE BRW5RET 4
#DEFINE BRW5QTA 5
#DEFINE BRW5STS 6
#DEFINE BRW5ZCU 7
#DEFINE BRW5ZCV 8
/*
Jean Rehermann - SOLUTIO IT - 29/05/2017
Programa de conferência de separação no WMS
*/

User Function CONFSEP()

	Local _cEstrMesa := GetMv("IMD_ESTMES") // Estrutura física das mesas

	Private _lSaiu    := .F.
	Private _cEndMesa := SelecMesa( _cEstrMesa ) // Endereço da mesa
	Private cStatExec := SuperGetMV('MV_RFSTEXE', .F., '1') //-- DB_STATUS indincando Atividade Executada
	Private cStatProb := SuperGetMV('MV_RFSTPRO', .F., '2') //-- DB_STATUS indincando Atividade com Problemas
	Private cStatInte := SuperGetMV('MV_RFSTINT', .F., '3') //-- DB_STATUS indincando Atividade Interrompida (Em Execução)
	Private cStatAExe := SuperGetMV('MV_RFSTAEX', .F., '4') //-- DB_STATUS indincando Atividade A Executar
	Private cStatAuto := SuperGetMV('MV_RFSTAUT', .F., 'A') //-- DB_STATUS indincando Atividade Automatica
	Private cStatManu := SuperGetMV('MV_RFSTMAN', .F., 'M') //-- DB_STATUS indincando Atividade Manual
	Private _cCodServ := SuperGetMV('IMD_SVCONF', .F., '001') // Código do serviço de conferência de separação
	Private _cCodTare := SuperGetMV('IMD_TRCONF', .F., '003') // Código da tarefa de conferência de separação
	Private _cCodAtiv := SuperGetMV('IMD_ATCONF', .F., '022') // Código da atividade de conferência de separação

    zPutSX1("CONFSEP","01","Imp. Etiq. Volume   ?","MV_PAR01","MV_CH0","N",1,0,"C","","","","Sim","Não",""        ,"","","")
    zPutSX1("CONFSEP","02","Finaliza Automatico ?","MV_PAR02","MV_CH1","N",1,0,"C","","","","Sim","Não","Pergunta","","","")

	Pergunte("CONFSEP",.F.)
	
	If Empty( _cEndMesa )
		If !_lSaiu
			MsgAlert("Mesa não selecionada!")
		EndIf
		Return
	EndIf
    
	If !_lSaiu
		MsAguarde( {|| PedConf() }, "Verificando atividades..." ) // Escolher o pedido para conferir
    EndIf
    
Return


// Tela para seleção do endereço da mesa de separação
Static Function SelecMesa( cEstrMesa )

	Local _cQuery   := ""
	Local _cAlias   := ""
	Local _aEditCpo := {}
	Local oSBtn1, oSBtn2
	Local _oFont1   := TFont():New( "Arial",0,-16,,.T.,0,,700,.F.,.F.,,,,,, )

	Private oSay1, oBrwEnd
	Private _cEndMesa := ""
	Private _aHeader  := {}
	Private _aCols    := {}

	aAdd( _aHeader, { "..."      , "MARCA", "@!", 001, 0 , "" , "" , "C" , ""})
	aAdd( _aHeader, { "Endereço ", "ENDER", "@!", TamSx3('BE_LOCALIZ')[01], 0 , "" , "" , "C" , ""})
	aAdd( _aHeader, { "Descrição", "DESCR", "@!", TamSx3('BE_DESCRIC')[01], 0 , "" , "" , "C" , ""})

	aAdd( _aEditCpo, "MARCA" )

	_cQuery := "SELECT DISTINCT(BE_LOCALIZ), BE_DESCRIC"
	_cQuery += " FROM "+ RetSqlName("SBE")
	_cQuery += " WHERE BE_ESTFIS = '"+ cEstrMesa +"'" // Estrutura física das mesas - Parâmetro IMD_ESTMES
	_cQuery += " AND BE_FILIAL = '"+ xFilial("SBE") +"'"
	_cQuery += " AND D_E_L_E_T_ = ' '"
	_cQuery += " ORDER BY BE_LOCALIZ ASC "
	
	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )

	While !(_cAlias)->( Eof() )

		aAdd( _aCols, { Space(5), (_cAlias)->BE_LOCALIZ, (_cAlias)->BE_DESCRIC, .F. } )

		(_cAlias)->( dbSkip() )
	End

	(_cAlias)->( dbCloseArea() )
	
	If Len( _aCols ) == 0
		aAdd( _aCols, { Space(5), " ", " ", .F. } )
	EndIf

	DEFINE MSDIALOG oDlg TITLE "Selecionar Mesa de Conferência" From 190,318 To 378,826 COLORS 0, 16777215 of oMainWnd PIXEL STYLE 128

		oBrwEnd := MsNewGetDados():New(004,004,060,244,GD_UPDATE,'AllwaysTrue()','AllwaysTrue()','',_aEditCpo,1,999,,'','', oDlg, _aHeader, _aCols )
		oBrwEnd:oBrowse:bLDblClick := {|| DbClick(oSBtn1), oBrwEnd:oBrowse:Refresh() }
		oSay1  := TSay():New( 070,004,{||""},oDlg,,_oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,108,016)
		oSBtn1 := SButton():New( 072,180,1,{|| Iif( !Empty( _cEndMesa ), oDlg:End(), MsgAlert("Mesa de conferência não selecionada!") ) },oDlg,,"", )
		oSBtn2 := SButton():New( 072,212,2,{|| _cEndMesa:="",_lSaiu:=.T., oDlg:End() },oDlg,,"", )
	
	ACTIVATE MSDIALOG oDlg CENTERED

Return _cEndMesa


// Atualiza a marca no browse dos endereços
Static Function DbClick(o)
	
	Local nPMarca := Ascan(oBrwEnd:aHeader,{|X| AllTrim(x[2]) == "MARCA"})
	Local nPEnder := Ascan(oBrwEnd:aHeader,{|X| AllTrim(x[2]) == "ENDER"})
	Local nPDescr := Ascan(oBrwEnd:aHeader,{|X| AllTrim(x[2]) == "DESCR"})
	Local nJaMarc := Ascan(oBrwEnd:aCols,  {|X| X[nPMarca]    == "  X  "}) 
	
	If nJaMarc > 0
		oBrwEnd:aCols[nJaMarc][nPMarca] := ''
	EndIf
	
	oBrwEnd:aCols[oBrwEnd:nAT][nPMarca] := Iif( Empty( oBrwEnd:aCols[oBrwEnd:nAT][nPMarca] ), "  X  ", "     " )
	oSay1:SetText(oBrwEnd:aCols[oBrwEnd:nAT][nPDescr])
	oSay1:Refresh()
	
	_cEndMesa := oBrwEnd:aCols[oBrwEnd:nAT][nPEnder]
	o:SetFocus()
	
Return()


// Função para selecionar o pedido que será conferido
Static Function PedConf()

	Local _cAliasSDB := RodaSDB(1) // Verifica todos os pedidos com atividade de conferencia de separação

	Private oBrwPed
	Private _nLidos := 0
	Private _cIdDCF := "" // IdDCF mestre utilizado para gravar o CB0_IDMVTO para controlar as etiquetas já lidas
	Private _aCols  := {}
	Private aEtiq   := {} // Array com as etiquetas lidas
	Private aLeitur := {} // Array com a informação da leitura que foi realizada
	Private aQtDist := {} // Array com a distribuição das quantidades nos itens
	
	SetKey( VK_F5 , {|| MsAguarde( {|| Atualista() }, "Atualizando..." ) } )
	SetKey( VK_F12, {|| Pergunte("CONFSEP",.T.) } )
	
	AvaliaPV(_cAliasSDB) // Avalia os pedidos que estão aptos a serem conferidos

	oDlg  := MSDialog():New( 169,247,480,1054,"Pedidos a Conferir - "+ _cEndMesa,,,.F.,,,,,,.T.,,,.T. )
	oBtn1 := TButton():New( 140,356,"&Sair",oDlg,{||oDlg:End()},037,012,,,,.T.,,"",,,,.F. )
	oBtn2 := TButton():New( 140,268,"&Atualiza [F5]",oDlg,{|| MsAguarde( {|| Atualista() }, "Atualizando..." )},037,012,,,,.T.,,"",,,,.F. )
	oBtn3 := TButton():New( 140,312,"&Conferir",oDlg,{|| ChkPedCnf() },037,012,,,,.T.,,"",,,,.F. )

	aColuna := {" ","Pedido","N.Atend.","Cliente","Transportadora","Município"}
	oBrwPed := TCBrowse():New(004,004,392,128,,aColuna,,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	If Empty( _aCols )
		aAdd( _aCols, {"","","","","","",.T.} )
	EndIf
	AtuBrw(.T.)
	oBrwPed:bLDblClick := {|| ChkPedCnf() }

	oDlg:Activate(,,,.T.,,,{|| oBrwPed:SetFocus() })

	SetKey( VK_F5 , Nil )
	SetKey( VK_F12, Nil )

Return()

// Função que executa a query no SDB
Static Function RodaSDB( nTipo, cPedido )

	Local _cQuery    := ""
	Local _cAliasSDB := GetNextAlias()
	Local _cPedido   := Iif( cPedido == Nil .Or. Empty( cPedido ), "", cPedido )
	Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])

		
	If nTipo == 1
		_cQuery := "SELECT DISTINCT( DB_DOC ), DB_RECHUM, DB_PRIORI, R_E_C_N_O_"
	ElseIf nTipo == 2
		_cQuery := "SELECT DB_DOC, DB_SERIE, DB_PRODUTO, DB_QUANT, DB_QTDLID, R_E_C_N_O_, DB_IDDCF"
	EndIf
	_cQuery += " FROM "+ RetSqlName('SDB') +" SDB"
	_cQuery += " WHERE DB_FILIAL  = '"+ xFilial("SDB") +"'"
	_cQuery += " AND DB_ESTORNO = ' '"
	_cQuery += " AND DB_SERVIC  = '"+ _cCodServ +"'"
	_cQuery += " AND DB_TAREFA  = '"+ _cCodTare +"'"
	_cQuery += " AND DB_ATIVID  = '"+ _cCodAtiv +"'"
	_cQuery += " AND DB_ORIGEM = 'SC9' "
	If !Empty( _cPedido )
		_cQuery += " AND DB_DOC = '"+ _cPedido +"' "
	EndIf
	If nTipo == 1
		_cQuery += " AND (DB_RECHUM = '"+ __cUserID +"' OR DB_RECHUM = '"+ cRecHVazio +"')"
		_cQuery += " AND DB_STATUS IN ('"+ cStatAExe +"','"+ cStatInte +"','"+ cStatProb +"')"
		_cQuery += " AND ( SELECT COUNT (*) "
		_cQuery += "        FROM "+ RetSqlName("SDB") +" SDBD "
		_cQuery += "        WHERE SDBD.DB_FILIAL  = SDB.DB_FILIAL "
		_cQuery += "          AND SDBD.DB_DOC     = SDB.DB_DOC "
		_cQuery += "          AND ((SDBD.DB_STATUS = '"+ cStatProb +"' OR SDBD.DB_STATUS = '"+ cStatInte +"' OR SDBD.DB_STATUS = '"+ cStatAExe +"' ) AND SDBD.DB_ATIVID  = '015' ) "
		_cQuery += "          AND D_E_L_E_T_      = ' ' AND SDBD.DB_ESTORNO = ' ') = 0 "
	EndIf
	_cQuery += " AND DB_LOCALIZ = '"+ _cEndMesa +"'"
	_cQuery += " AND D_E_L_E_T_ = ' '"
	If nTipo == 1
		_cQuery += " ORDER BY DB_RECHUM DESC, DB_PRIORI ASC " // Respeita a prioridade
	EndIf
	
	_cQuery := ChangeQuery(_cQuery)
	
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,_cQuery),_cAliasSDB,.F.,.T.)

	If nTipo == 2
		TCSetField(_cAliasSDB,'DB_QUANT' ,'N',TamSx3('DB_QUANT')[1] , TamSx3('DB_QUANT')[2] )
		TCSetField(_cAliasSDB,'DB_QTDLID','N',TamSx3('DB_QTDLID')[1], TamSx3('DB_QTDLID')[2])
	EndIf
	
Return( _cAliasSDB )

// Função que faz a atualização do bLine do browse
Static Function AtuBrw(lRefresh)

	Local oCn := LoadBitMap( GetResources(), "LBOK" )
	Local oRt := LoadBitMap( GetResources(), "BR_CANCEL" )

	oBrwPed:SetArray( _aCols ) 

	oBrwPed:bLine := { ||{	Iif( _aCols[ oBrwPed:nAt, BRW2LEG ]=="P", oCn, Iif( _aCols[ oBrwPed:nAt, BRW2LEG ]=="R", oRt, " " ) ),;
							_aCols[ oBrwPed:nAt, BRW2PED ],;
							_aCols[ oBrwPed:nAt, BRW2ATE ],;
							_aCols[ oBrwPed:nAt, BRW2CLI ],;
							_aCols[ oBrwPed:nAt, BRW2TRA ],;
							_aCols[ oBrwPed:nAt, BRW2MUN ] } }
	
	If lRefresh
		oBrwPed:Refresh()
	EndIf	

Return


// Avalia os pedidos de venda quanto à disponibilidade para conferência
Static Function AvaliaPV(_cAliasSDB)

	Local _cQuery    := ""
	Local _cAliasZAR := GetNextAlias()

	// Isto é para carregar a área em memória (são 33 milhões de registros)
	dbSelectArea("SDB")
	SDB->( DbGoTop() )

	If Len( _aCols ) == 1 .And. Empty( _aCols[ 1, BRW2PED ] )
		_aCols := {}
	EndIf
	
	While (_cAliasSDB)->( !Eof() )

		If aScan( _aCols, {|o| AllTrim( o[BRW2PED] ) == AllTrim( (_cAliasSDB)->DB_DOC ) } ) == 0
			
			SDB->( dbGoTo( (_cAliasSDB)->R_E_C_N_O_ ) )
			
			If HasPrdSep( SDB->DB_SERVIC, SDB->DB_ORDTARE, SDB->DB_DOC )
                
				SC5->( dbSetOrder(1) )
				SC5->( MsSeek( xFilial("SC5") + (_cAliasSDB)->DB_DOC ) )
				
				SA1->( dbSetOrder(1) )
				SA1->( MsSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ) )

				aAdd( _aCols, { "P", SC5->C5_NUM,;
								SC5->C5_NUMSUA,;
								AllTrim( SA1->A1_NREDUZ ),;
								AllTrim( Posicione("SA4", 1, xFilial("SA4") + SC5->C5_TRANSP, "A4_NREDUZ") ),;
								AllTrim( SA1->A1_MUN ) +"/"+ SA1->A1_EST } )

			EndIf
			
		EndIf
		
		(_cAliasSDB)->( DbSkip() )
	EndDo

	(_cAliasSDB)->( DbCloseArea() )

	_cQuery := "SELECT DISTINCT( ZAR_PEDIDO ) "
	_cQuery += " FROM "+ RetSqlName('ZAR') +" ZAR "
	_cQuery += " WHERE ZAR_FILIAL  = '"+ xFilial("ZAR") +"' "
	_cQuery += " AND ZAR_LOCALI = '"+ _cEndMesa +"' "
	_cQuery += " AND ZAR_QTDRET > 0 "
	_cQuery += " AND D_E_L_E_T_ = ' ' "
	_cQuery += " ORDER BY ZAR_PEDIDO "
	
	_cQuery := ChangeQuery(_cQuery)

	dbUseArea(.T.,'TOPCONN',TcGenQry(,,_cQuery),_cAliasZAR,.F.,.T.)

	TCSetField(_cAliasZAR,'ZAR_QTDANT' ,'N',10,2 )
	TCSetField(_cAliasZAR,'ZAR_QTDATU' ,'N',10,2 )
	TCSetField(_cAliasZAR,'ZAR_CNFANT' ,'N',10,2 )
	TCSetField(_cAliasZAR,'ZAR_QTDRET' ,'N',10,2 )
	
	While !(_cAliasZAR)->( Eof() )
	
		// Avaliar se pedido não possui pendências de apanhe antes de aparecer na tela de retio
		If IsPvOkRet( (_cAliasZAR)->ZAR_PEDIDO )
		
			SC5->( dbSetOrder(1) )
			SC5->( MsSeek( xFilial("SC5") + (_cAliasZAR)->ZAR_PEDIDO ) )
			
			SA1->( dbSetOrder(1) )
			SA1->( MsSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ) )
	
			aAdd( _aCols, { "R", SC5->C5_NUM,;
							SC5->C5_NUMSUA,;
							AllTrim( SA1->A1_NREDUZ ),;
							AllTrim( Posicione("SA4", 1, xFilial("SA4") + SC5->C5_TRANSP, "A4_NREDUZ") ),;
							AllTrim( SA1->A1_MUN ) +"/"+ SA1->A1_EST } )

        EndIf

		(_cAliasZAR)->( DbSkip() )
	EndDo

	(_cAliasZAR)->( DbCloseArea() )

	aSort( _aCols,,, { |x, y| x[ 1 ] + x[ 2 ] < y[ 1 ] + y[ 2 ] } )

Return

//-----------------------------------------------------------------------------
//Verifica quantidade do produto que está empenhada (já separada)
//Somente permite iniciar a conferência, caso alguma atividade de separação 
//tenha sido executada, disponiblizando assim itens para conferência
//-----------------------------------------------------------------------------
Static Function HasPrdSep( cServico, cOrdTar, cPedido )

	Local aAreaAnt   := GetArea()
	Local aAreaDC5   := DC5->( GetArea() )
	Local lRet       := .F.
	Local cQuery     := ""
	Local cAliasQry  := GetNextAlias()
	Local cOrdSep    := "01"

	DC5->( DbSetOrder(1) )
	If DC5->( MsSeek( xFilial("DC5") + cServico + cOrdTar ) )
		DC5->( DbSkip(-1) )
		If DC5->DC5_SERVIC == cServico
			cOrdSep := DC5->DC5_ORDEM
		EndIf 
	EndIf

	cQuery := "SELECT DISTINCT 1"
	cQuery +=  " FROM "+ RetSqlName('SDB') +" SDB"
	cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND SDB.DB_ESTORNO = ' '"
	cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
	cQuery +=   " AND SDB.DB_SERVIC  = '"+ cServico +"'"
	cQuery +=   " AND SDB.DB_ORDTARE = '"+ cOrdSep  +"'"
	cQuery +=   " AND SDB.DB_DOC     = '"+ cPedido  +"'"
	cQuery +=   " AND SDB.DB_STATUS IN ('1','M')"
	cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SDB.DB_ORDATIV = (SELECT MAX(DB_ORDATIV)"+;
                                     " FROM "+ RetSqlName("SDB") +" SDBM"+;
                                     " WHERE SDBM.DB_FILIAL  = SDB.DB_FILIAL"+;
                                      " AND SDBM.DB_PRODUTO = SDB.DB_PRODUTO"+;
                                      " AND SDBM.DB_DOC     = SDB.DB_DOC"+;
                                      " AND SDBM.DB_SERIE   = SDB.DB_SERIE"+;
                                      " AND SDBM.DB_CLIFOR  = SDB.DB_CLIFOR"+;
                                      " AND SDBM.DB_LOJA    = SDB.DB_LOJA"+;
                                      " AND SDBM.DB_SERVIC  = SDB.DB_SERVIC"+;
                                      " AND SDBM.DB_TAREFA  = SDB.DB_TAREFA"+;
                                      " AND SDBM.DB_IDMOVTO = SDB.DB_IDMOVTO"+;
                                      " AND SDBM.DB_ESTORNO = ' '"+;
                                      " AND SDBM.DB_ATUEST  = 'N'"+;
                                      " AND SDBM.D_E_L_E_T_ = ' ' )"

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
	
	RestArea(aAreaDC5)
	RestArea(aAreaAnt)

Return lRet


// Atualiza a lista de pedidos com as conferências
Static Function Atualista()
	
	Local cAliSDB := ""

	_aCols := {}
	
	cAliSDB := RodaSDB(1) // Seleciona os registros de atividade de conferência
	
	AvaliaPV(cAliSDB) // Avalia os pedidos que estão aptos a serem conferidos
	
	If Empty( _aCols )
		aAdd( _aCols, {"","","","","","",.T.} )
	EndIf
	
	AtuBrw(.T.)
	
Return

// Faz a conferência do pedido selecionado
Static Function LerConf( nLin )

	Local aCoors   := FWGetDialogSize( oMainWnd )
	Local oFont1   := TFont():New( "Arial",,-14,,.T.,,,,,.F.,.F. )
	Local oFont2   := TFont():New( "Arial",,-10,,.T.,,,,,.F.,.F. )
	Local oFontB   := TFont():New( "Arial",,-13,,.T.,,,,,.F.,.F. )
	Local bIniDlg  := {|| oGet4:SetFocus(), oItens:nAt := 1, oItens:Refresh() }
	Local _cPedido := ""
	Local _cTransp := ""
	Local _cMunici := ""
	Local _cObs    := ""
	
	Private _cCodVol := ""
	Private aItens   := {}
	Private cLeitura := Space(14)
	Private cCarga   := Space( TamSX3("ZCT_CARGA")[1] ) // Carga sempre será branco
	Private lAltQtd  := SuperGetMV("IMD_ALTQCO", .F., .F.) // Permite alterar a quantidade na leitura do EAN13
	Private lPalet   := .F.
	Private oDlgCon
	Private oSayP
	Private oSayQ
	
	If Empty( _aCols )
		Return
	EndIf
	
	aLeitur := {} // Apago as leituras realizadas anteriormente
	aQtDist := {} // Apago as leituras realizadas anteriormente

	_cPedido := _aCols[ nLin, BRW2PED ]
	_cTransp := _aCols[ nLin, BRW2TRA ]
	_cMunici := _aCols[ nLin, BRW2MUN ]
	_cObs    := Posicione("SUA",1,xFilial("SUA")+_aCols[ nLin, BRW2ATE ],"UA_OBSEXP")
	VePallet( _cPedido ) // Atualiza variável se pedido já foi marcado para gerar pallet
	
	aItens := GetItens( _cPedido )
	
	If Len( aItens ) == 0 .Or. ( Len( aItens ) == 1 .And. Empty( aItens[ 1, BRW3ITM ] ) )
		MsgAlert("Nenhum item encontrado!")
		Return
	EndIf
	
	// Posiciono em cada registro do SDB e atualizo as tabelas ZCS e ZCT de volumes
	ZCS->( dbSetOrder(1) ) //ZCS_FILIAL+ZCS_CARGA+ZCS_PEDIDO
	If !ZCS->( MsSeek( xFilial("ZCS") + cCarga + _cPedido ) )
		For _nX := 1 To Len( aItens )
			If !Empty( aItens[ _nX, BRW3ITM ] )
				SDB->( dbGoTo( aItens[ _nX, BRW3REC ] ) )
				// Função identica ao wmsvolemb padrão da versão 11
				ImdVolEmb( SDB->DB_CARGA, SDB->DB_DOC, SDB->DB_PRODUTO, SDB->DB_LOTECTL, SDB->DB_NUMLOTE, SDB->DB_IDDCF, SDB->DB_QUANT )
			EndIf
		Next
	EndIf
    
	_cCodVol := VerifVol( _cPedido, .F. )
	
	oDlgCon  := MSDialog():New( 2, 2, aCoors[3], aCoors[4],"",,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,.F.)
	oDlgCon:lEscClose := .T.
	SetKey( VK_F5, Nil )
		
	oSay1 := TSay():New( 004,004,{||"Pedido de Venda"}    ,oDlgCon,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,041,008)
	oSay2 := TSay():New( 020,004,{||"Transportadora"}     ,oDlgCon,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,041,008)
	oSay3 := TSay():New( 036,004,{||"Município"}          ,oDlgCon,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,041,008)
	oSay4 := TSay():New( 062,220,{||"Pallet: "}           ,oDlgCon,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,041,008)
	oSay5 := TSay():New( 062,300,{||"Digita Quantidade: "},oDlgCon,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,080,008)

	oSayP := TSay():New( 062,240,{||Iif( lPalet , "Sim", "Não" )},oDlgCon,,oFontb,.F.,.F.,.F.,.T.,Iif( lPalet , CLR_GREEN, CLR_RED ),CLR_WHITE,041,008)
	oSayQ := TSay():New( 062,350,{||Iif( lAltQtd, "Sim", "Não" )},oDlgCon,,oFontb,.F.,.F.,.F.,.T.,Iif( lAltQtd, CLR_GREEN, CLR_RED ),CLR_WHITE,041,008)
	
	oGet1 := TGet():New( 004,051,{||_cPedido},oDlgCon,060,008,'',,CLR_WHITE,CLR_GRAY ,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","_cPedido",,)
	oGet1:SetContentAlign(0)
	oGet1:lCanGotFocus := .F.
	oGet2 := TGet():New( 020,051,{||_cTransp},oDlgCon,060,008,'',,CLR_WHITE,CLR_GRAY ,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","_cTransp",,)
	oGet2:SetContentAlign(0)
	oGet2:lCanGotFocus := .F.
	oGet3 := TGet():New( 036,051,{||_cMunici},oDlgCon,060,008,'',,CLR_WHITE,CLR_GRAY ,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","_cMunici",,)
	oGet3:SetContentAlign(0)
	oGet3:lCanGotFocus := .F.
	
	oMGet := TMultiGet():New( 008,120,{||_cObs},oDlgCon,256,035,oFont2,,,CLR_WHITE,,.T.,,,{||},,,.T.,{||},,,.F.,.T.,"Observações",1,,CLR_BLUE)
	
	oGetV := TGet():New( 052,120,{|u| Iif(PCount()>0,_cCodVol:=u,_cCodVol)},oDlgCon,060,008,'@!',{||.T.},CLR_WHITE,CLR_GRAY,/*oFont*/,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","_cCodVol",,,,.F.,.F.,,"Volume em montagem",1,,CLR_BLUE)
	oGetV:SetContentAlign(0)
	oGetV:lCanGotFocus := .F.
	
	oTMsgBar := TMsgBar():New(oDlgCon, " [F3] Paletizar | [F4] Digita Quantidade | [F7] Ver Volumes | [F8] Fecha Volume | [F9] Desfazer | [F12] Parâmetros ",,,,,CLR_GRAY,,oFont2)
	
	oItens := TcBrowse():New(076,004,aCoors[4]/2.1,aCoors[3]/3,,,,oDlgCon,,,,,,,oFontB,,,,,.f.,,.t.,,.f.,,,,)

	oItens:AddColumn( TcColumn():New( "Item          ",{ || aItens[oItens:nAt,BRW3ITM]}, "@!"        ,,,"CENTER",020,.f.,.f.) )
	oItens:AddColumn( TcColumn():New( "Código Produto",{ || aItens[oItens:nAt,BRW3COD]}, "@!"        ,,,"LEFT"  ,070,.f.,.f.) )
	oItens:AddColumn( TcColumn():New( "Descrição     ",{ || aItens[oItens:nAt,BRW3DES]}, "@!"        ,,,"LEFT"  ,160,.f.,.f.) )
	oItens:AddColumn( TcColumn():New( "Qtd.Total Item",{ || aItens[oItens:nAt,BRW3QTD]}, "@e 999,999",,,"RIGHT" ,050,.f.,.f.) )
	oItens:AddColumn( TcColumn():New( "Qtd.Conferida ",{ || aItens[oItens:nAt,BRW3LID]}, "@e 999,999",,,"RIGHT" ,050,.f.,.f.) )
	oItens:AddColumn( TcColumn():New( "Qtd.Restante  ",{ || aItens[oItens:nAt,BRW3RES]}, "@e 999,999",,,"RIGHT" ,050,.f.,.f.) )
	oItens:AddColumn( TcColumn():New( "Qtd.Embalada  ",{ || aItens[oItens:nAt,BRW3EMB]}, "@e 999,999",,,"RIGHT" ,050,.f.,.f.) )
	oItens:AddColumn( TcColumn():New( "Qtd.Vol.Atual ",{ || aItens[oItens:nAt,BRW3QVA]}, "@e 999,999",,,"RIGHT" ,050,.f.,.f.) )
	oItens:AddColumn( TcColumn():New( ""              ,{ ||                           }, "@!"        ,,,"CENTER",001,.f.,.f.) )

	oItens:lUseDefaultColors := .F.
	oItens:lCanGotFocus := .F.
	oItens:lReadOnly := .T.
	oItens:SetBlkBackColor( {|| GetFundoLinha( oItens:nAT ) } )
	oItens:SetBlkColor( {|| GetCorLetra( oItens:nAT ) } )
	oItens:SetArray( aItens )
	
	oGet4 := TGet():New( 051,008,{|u| Iif(PCount()>0,cLeitura:=u,cLeitura)},oDlgCon,100,012,'@!',{|| Iif( !Empty(cLeitura), VldCB(_cPedido), .T.) },CLR_WHITE,CLR_BLACK,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cLeitura",,,,.F.,.F.,,"Código de Barras:",1,,CLR_BLUE)
	oGet4:SetContentAlign(0)
	
	SetaFk( _cPedido ) // Atribui funções às teclas de atalho
	
	oDlgCon:Activate(,,,.T.,{|| PausaConf() },,bIniDlg)

	SetKey( VK_F5, {|| MsAguarde( {|| Atualista() }, "Atualizando..." ) } )

Return


// Apenas sai da tela, toda a conferência já está gravada
Static Function PausaConf( lFecha )

	Local _lRet := .T.

	ClearfK()
	
Return( _lRet )


// Define a cor da linha do browse
Static Function GetFundoLinha( nLinha )

	Local nRet := 0
	
	If aItens[nLinha,BRW3LID] == 0
		nRet := CLR_BLUE
	ElseIf aItens[nLinha,BRW3LID] == aItens[nLinha,BRW3QTD]
		nRet := CLR_GREEN
	Else
		nRet := CLR_YELLOW
	Endif

	oItens:nClrBackFocus := nRet

Return( nRet )


// Define a cor da letra na linha do browse
Static Function GetCorLetra( nLinha )

	Local nRet := 0
	
	If aItens[nLinha,BRW3LID] == 0
		nRet := CLR_YELLOW
	ElseIf aItens[nLinha,BRW3LID] == aItens[nLinha,BRW3QTD]
		nRet := CLR_YELLOW
	Else
		nRet := CLR_BLACK
	Endif
		
Return( nRet )


// Busca os itens do pedido para o browse de leitura
Static Function GetItens( cPedido )

	Local _aRet      := {}
	Local _nQtdEmb   := 0
	Local _cAliasSDB := RodaSDB( 2, cPedido ) // Executa a query e retorna o Alias
	
	While (_cAliasSDB)->( !Eof() )
		
		_nQtdEmb := QtdEmbVol( cPedido, (_cAliasSDB)->DB_PRODUTO, (_cAliasSDB)->DB_IDDCF ) // Quantidade já embalada (volumes fechados)
		
		aAdd( _aRet, { (_cAliasSDB)->DB_SERIE,;
						(_cAliasSDB)->DB_PRODUTO,;
						AllTrim( Posicione("SB1",1,xFilial("SB1")+(_cAliasSDB)->DB_PRODUTO,"B1_DESC") ),;
						(_cAliasSDB)->DB_QUANT,;
						(_cAliasSDB)->DB_QTDLID,;
						(_cAliasSDB)->DB_QUANT - (_cAliasSDB)->DB_QTDLID,;
						(_cAliasSDB)->R_E_C_N_O_,;
						_nQtdEmb,;
						(_cAliasSDB)->DB_IDDCF,;
						0 } )
//						(_cAliasSDB)->DB_QTDLID - _nQtdEmb } ) // O que está lido e não está em volume fechado, está no volume atualmente aberto
		
		(_cAliasSDB)->( DbSkip() )
	EndDo
	(_cAliasSDB)->( DbCloseArea() )

	_cIdDCF := _aRet[ Len( _aRet ), BRW3DCF ] // IdDCF Mestre para controle das etiquetas lidas (CB0_IDMVTO)
	
	_aRet := Organiza( _aRet )

Return( _aRet )


// Organiza as linhas do array de acordo com o saldo a ser lido
Static Function Organiza( aRet )

	Local _nX    := 0
	Local _aRet  := {}
	Local _aTmp1 := aRet
	Local _aTmp2 := {} // Conterá registros que não começaram a ser conferidos
	Local _aTmp3 := {} // Conterá registros que já foram conferidos totalmente
	
	aAdd( _aRet, {"","","",0,0,0,0,0,"",0} ) // Item vazio para ficar com o background de perda de foco

	For _nX := 1 To Len( _aTmp1 )
		If !Empty( _aTmp1[ _nX, BRW3ITM ] ) // Desconsidero o Item vazio pois irei incluir um novo no retorno
			If _aTmp1[ _nX, BRW3LID ] == 0 // Não iniciou conferência deste item (prioridade 2)
				aAdd( _aTmp2, _aTmp1[ _nX ] )
			ElseIf _aTmp1[ _nX, BRW3LID ] == _aTmp1[ _nX, BRW3QTD ] // Já finalizou conferência deste item (prioridade 3)
				aAdd( _aTmp3, _aTmp1[ _nX ] )
			Else // Já iniciou conferência do item e não está concluída (prioridade 1)
				aAdd( _aRet, _aTmp1[ _nX ] )
			EndIf
		EndIf
	Next
	
	If Len( _aTmp2 ) > 0
	     For _nX := 1 To Len( _aTmp2 )
	     	aAdd( _aRet, _aTmp2[ _nX ] )
	     Next
	EndIf
		
	If Len( _aTmp3 ) > 0
	     For _nX := 1 To Len( _aTmp3 )
	     	aAdd( _aRet, _aTmp3[ _nX ] )
	     Next
	EndIf

Return( _aRet )

// Faz a validação da leitura do CB
Static Function VldCB(cPedido)
	
	Local _lRet := .F.
	Local _cEan := AllTrim( oGet4:cText )
	Local _cP14 := Iif( Len( _cEan ) == 14, Left( _cEan, 1 ), "" )
	Local _nFim := 0
	
	Private _cTipo := ""
	
	oItens:lReadOnly := .F.
	
	If Len( _cEan ) <= TamSX3("B1_COD")[1]
		
		// Primeiro procuro pelo código do produto no SB1
		SB1->( DbSetOrder(1) )
		If SB1->( MsSeek( xFilial('SB1') + _cEan ) )
			// Verifico se código de produto consta no Browse, senão pode ser que seja ID de Logística
			If ( _nPos := aScan( aItens, {|o| AllTrim( o[ BRW3COD ] ) == _cEan } ) ) > 0
				// Recupero o código de barras para fazer o mesmo tratamento paraEAN13 repetidos
				_cEan := AllTrim( SB1->B1_CODBAR )
				_lRet := BuscaB1( _cEan, _cP14, 0 )
			Else
				// Id de Logística
				If Len( _cEan ) == 10
					_lRet := BuscaCB0( _cEan )
				Else
					Tone()
					MsgAlert("Produto digitado não pertence a este pedido!")
				EndIf
			Endif
		Else
			// Caso não seja código de produto verifico o EAN
			If Len( _cEan ) == 13 .Or. Len( _cEan ) == 12 .Or. Len( _cEan ) == 14
		
				_cEan := Iif( Len( _cEan ) == 14, SubStr( _cEan, 2, 12 ), _cEan )
				_lRet := BuscaB1( _cEan, _cP14, 0 )
			
			ElseIf Len( _cEan ) == 10
				_lRet := BuscaCB0( _cEan )
			Else
				Tone()
				MsgAlert("Leitura de código de barras inválida!")
			EndIf

		EndIf

	Else
		Tone()
		MsgAlert("Leitura de código de barras inválida!")
	EndIf

	If _lRet
		// Reorganiza os itens na tela de acordo com o status da conferência
		aItens := Organiza( aItens )
		oItens:nAt := 1
		oItens:Refresh()
		// Atualiza a quantidade conferida no SDB
		AtuSDB(.F.)
	EndIf
	
	// Soma o restante para verificar se encerrou a conferência
	aEval( aItens,{ |X| _nFim += X[BRW3RES] } )

	If _nFim > 0
		oGet4:cText := Space(14)
		oGet4:SetContentAlign(0)
		oGet4:CtrlRefresh()
		oGet4:SetFocus()
	ElseIf _lRet
		If mv_par02 == 1 .Or. ( mv_par02 == 3 .And. MsgYesNo("Finaliza conferência? (Gerará volume e etiqueta com o último item lido)") )
			MsAguarde( {|| ConfVol( cPedido, .T. ) }, "Gravando Volume e finalizando conferência..." )
		Else
			oGet4:cText := Space(14)
			oGet4:SetContentAlign(0)
			oGet4:CtrlRefresh()
			oGet4:SetFocus()
		EndIf
	EndIf

	oItens:lReadOnly := .T.
	
Return( .T. )


// Utiliza o código lido para buscar a quantidade na etiqueta CB0
Static Function BuscaCB0( cEan )

	Local _aArea := GetArea()
	Local _nQtEt := 0
	Local _nPos  := 0
	Local _cCodB := ""
	Local _lRet  := .F.
	
	Private _cCB0 := AllTrim( cEan )
	
	dbSelectArea("CB0")
	dbSetOrder(1)
	
	If !dbSeek( xFilial("CB0") + _cCB0 )
		Tone()
		MsgAlert("Etiqueta não localizada!")
	Else

		_nPos := aScan( aItens, {|o| AllTrim( o[ BRW3COD ] ) == AllTrim( CB0->CB0_CODPRO ) } )
		
		If _nPos == 0
			Tone()
			MsgAlert("O produto lido nesta etiqueta, não está neste pedido! "+ CB0->CB0_CODPRO )
		Else
			
			_nPos := aScan( aEtiq, {|o| AllTrim( o ) == _cCB0 } )
			
			If _nPos > 0
				Tone()
				MsgAlert("Etiqueta já foi lida nesta conferência!")
			Else
				_nQtEt := CB0->CB0_QTDE
				_cCodB := AllTrim( Posicione("SB1", 1, xFilial("SB1") + CB0->CB0_CODPRO, "B1_CODBAR") )
	
				If !Empty( _cCodB )
					_lRet  := BuscaB1( _cCodB, "", 0, _nQtEt )
					aAdd( aEtiq, _cCB0 )
					CB0->( dbSetOrder(1) )
					CB0->( dbSeek( xFilial("CB0") + _cCB0 ) )
					CB0->( RecLock("CB0",.F.) )
						CB0->CB0_IDMVTO := _cIdDCF
					CB0->( MsUnLock() )
				Else
					Tone()
					MsgAlert("Não é possível determinar o código EAN13 deste produto! Verificar cadastro!")
				EndIf
			EndIf
		EndIf
		
	EndIf
		
	RestArea( _aArea )

Return( _lRet )


// Utiliza o código lido para buscar a quantidade a conferir
Static Function BuscaB1( cCodEan, cP14, nLin, nQtdID )

	Local _aB1     := {}
	Local _aPosEAN := {}
	Local _lRet    := .F.
	Local _nPosItm := 0
	Local _nQtdOri := 0
	Local _nQtdLid := 0
	Local _nSaldo  := 0
	Local _nItem   := 0
	Local _nPE13   := 0
	Local _nQtdSum := 1
	Local _nQtdID  := Iif( nQtdID != Nil, nQtdID, 0 )
	Local _cQuery  := ""
	Local _cAlias  := ""
	Local _nLinha  := nLin
	Local _cCodEAN := cCodEan

	_cQuery := "SELECT B1_COD "
	_cQuery += " FROM "+ RetSqlName("SB1")
	_cQuery += " WHERE B1_FILIAL = '"+ xFilial("SB1") +"'"
	If !Empty( cP14 ) // EAN14
		_cQuery += " AND SUBSTR(B1_CODBAR,1,12) = '"+ _cCodEan +"'"
	Else
		_cQuery += " AND B1_CODBAR = '"+ _cCodEan +"'"
	EndIf
	_cQuery += " AND D_E_L_E_T_ = ' '"
	_cQuery += " AND B1_MSBLQL <> '1'"
	_cQuery += " ORDER BY B1_COD ASC "
	
	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	While !(_cAlias)->( Eof() )

		aAdd( _aB1, (_cAlias)->B1_COD ) // Produtos com mesmo EAN13

		(_cAlias)->( dbSkip() )
	End
	
	(_cAlias)->( dbCloseArea() )

	If Len( _aB1 ) == 0
		Tone()
		MsgAlert("EAN13 não localizado no cadastro de produtos!")
	Else
		
		For _nX := 1 To Len( _aB1 )
			
			While ( _nPosItm := aScan( aItens, {|o| AllTrim( o[ BRW3COD ] ) == AllTrim( _aB1[ _nX ] ) }, _nPosItm + 1 ) ) > 0

				aAdd( _aPosEAN, { AllTrim( _aB1[ _nX ] ), aItens[ _nPosItm, BRW3REC ] } ) // Produto encontrado, armazeno o código e o RECNO da linha
			
			End
			
		Next

		If Len( _aPosEAN ) == 0
			Tone()
			MsgAlert("O produto lido não está neste pedido!")
		Else

			// GetCB14 retorna a quantidade EAN14 no SB5
			// GetCB13 permite digitar a quantidade para EAN13 na leitura e também verifica se é leitura de ID de logística
			If Empty( cP14 ) // Não é EAN14

				If _nQtdID > 0 // Leitura de ID de logística
					_cTipo   := TXTIDLOG
					_cCodEan := _cCB0
					_nQtdSum := _nQtdID
				Else	
					If lAltQtd 
						_nQtdSum := GetCB13(_aPosEAN,_cCodEan,_nLinha, .F.)
					Else
						_nQtdSum := 1
					Endif
					_cTipo := TXTEAN13
				EndIf
			Else // É EAN14
				_cTipo := TXTEAN14
				_nQtdSum := GetCB14( _aB1[ 1 ], cP14 ) 
			Endif			

			If _nQtdSum == 0 // So sera 0 quando for EAN14 e nao encontrar a quantidade
				Tone()
				MsgAlert("Não foi possível encontrar a configuração EAN14 para o produto!")
				Return
			EndIf

			For _nX := 1 To Len( _aPosEAN )
			
				_nPosRec := aScan( aItens, {|o| o[BRW3REC] == _aPosEAN[ _nX, 2 ] } )
				_nQtdOri := aItens[ _nPosRec, BRW3QTD ]
				_nQtdLid := aItens[ _nPosRec, BRW3LID ]
				
				// A partir daqui faco a distribuicao da quantidade pelos itens encontrados no browse
				// Posso ter varios produtos com mesmo EAN13 no mesmo pedido, porem a quantidade tem que ser considerada a total para o EAN13
				// Entao para que nao gere divergencia preciso, a cada leitura, avaliar as quantidades de todos os itens deste mesmo EAN13

				If Len( _aPosEAN ) == 1 // Produto nao tem EAN13 repetido neste pedido, entao a quantidade vai toda para este item
					If ( _nQtdLid + _nQtdSum ) <= _nQtdOri
						aItens[ _nPosRec, BRW3LID ] += _nQtdSum
						aItens[ _nPosRec, BRW3QVA ] += _nQtdSum
						aItens[ _nPosRec, BRW3RES ] -= _nQtdSum
						_lRet := .T.
						_nLidos++
						aAdd( aLeitur, { _nLidos, cP14 + _cCodEan, _cTipo, _nQtdSum } ) // Sequencia, CB Lido, , Tipo de CB, Qtd. Lida
						aAdd( aQtDist, { _nLidos, _aPosEAN[ _nX, 2 ], _nQtdSum } ) // Sequencia, RECNO, Qtd. Lida
					Else
						Tone()
						MsgAlert("Quantidade lida supera a quantidade total do item!")
					EndIf

					Exit

				Else // Produto tem EAN13 repetidos, preciso tratar os itens
                    
					// Jean Rehermann - Solutio IT - 24/04/2016 - Validar a quantidade digitada pelos totais dos produtos de mesmo EAN antes de distribuir
					_nPosLi1 := 0
					_nQtFal1 := 0
					
					For _nOK := 1 To Len( _aPosEAN )
						_nPosLi1 := aScan( aItens, {|o| o[BRW3REC] == _aPosEAN[ _nOK, 2 ] } )
						If _nPosLi1 > 0
							_nQtFal1 += aItens[ _nPosLi1, BRW3RES ]
						EndIf
					Next
					
					If _nQtdSum > _nQtFal1
						Tone()
						MsgAlert("Quantidade lida supera a quantidade total após a distribuição nos itens!")
						Exit
					EndIf
					// Fim validacao Jean 24/04/2018

					If Len( _aPosEAN ) == _nX // Estou na última ocorrência dos produtos com mesmo EAN13, portanto somo a quantidade total neste item

						If ( _nQtdLid + _nQtdSum ) <= _nQtdOri
							aItens[ _nPosRec, BRW3LID ] += _nQtdSum
							aItens[ _nPosRec, BRW3QVA ] += _nQtdSum
							aItens[ _nPosRec, BRW3RES ] -= _nQtdSum
							_lRet := .T.
							_nLidos++
							aAdd( aLeitur, { _nLidos, cP14 + _cCodEan, _cTipo, _nQtdSum } ) // Sequencia, CB Lido, , Tipo de CB, Qtd. Lida
							aAdd( aQtDist, { _nLidos, _aPosEAN[ _nX, 2 ], _nQtdSum } ) // Sequencia, RECNO, Qtd. Lida
						Else
							Tone()
							MsgAlert("Quantidade lida supera a quantidade total do item!")
						EndIf

						Exit
						
					Else // Não estou na última ocorrência dos produtos com mesmo EAN13, sei que tenho o PRÓXIMO item no array
					
						If _nQtdLid == _nQtdOri // Item ja conferido na sua totalidade, vou pulando para o proximo
							Loop // Vou para o próximo
						Else
							If ( _nQtdLid + _nQtdSum ) > _nQtdOri // Se a qtd ja conferida somada à qtd da leitura atual for maior que qtd do item
								
								_nSaldo := _nQtdSum // Quantidade da ultima leitura
								_nItem  := _nX      // Item atual do array de produtos com EAN13 repetidos (_aPosEAN)
								_nPosRec := aScan( aItens, {|o| o[BRW3REC] == _aPosEAN[ _nItem, 2 ] } )
								_nLidos++
								aAdd( aLeitur, { _nLidos, cP14 + _cCodEan, _cTipo, _nQtdSum } ) // Sequencia, CB Lido, , Tipo de CB, Qtd. Lida

								// Faço um backup da posição atual dos arrays, pois se no decorrer dos cálculos for verificado que a quantidade
								// lida supera a quantidade original de algum item, eu volto a esta posição
								_aBkpItens := aItens
								_aBkpQtDis := aQtDist
								_aBkpLeitu := aLeitur
								
								While _nSaldo > 0 // Trabalho com o saldo item a item

									_nQtdTmp := _nQtdOri - _nQtdLid // O quanto eu consigo colocar neste item
									aItens[ _nPosRec, BRW3LID ] += _nQtdTmp // Somo a quantidade obtida acima, neste item atual
									aItens[ _nPosRec, BRW3QVA ] += _nQtdTmp // Somo a quantidade obtida acima, neste item atual
									aItens[ _nPosRec, BRW3RES ] -= _nQtdTmp
									_nSaldo -= _nQtdTmp // Diminuo do saldo a quantidade somada acima
									aAdd( aQtDist, { _nLidos, _aPosEAN[ _nX, 2 ], _nQtdTmp } ) // Sequencia, RECNO, Qtd. Lida

									If _nSaldo > 0 // Caso ainda sobre algum saldo para o próximo item

										_nItem++ // Acumulo a variável temporária do item
                                        _nPosRec := aScan( aItens, {|o| o[BRW3REC] == _aPosEAN[ _nItem, 2 ] } )
                                        
										If _nItem == Len( _aPosEAN ) // Caso já tenha chego no último item 
											aItens[ _nPosRec, BRW3LID ] += _nSaldo // Armazeno o saldo restante independente sem validar
											aItens[ _nPosRec, BRW3QVA ] += _nSaldo // Quantidade no volume atual
											aItens[ _nPosRec, BRW3RES ] -= _nSaldo
											aAdd( aQtDist, { _nLidos, _aPosEAN[ _nX, 2 ], _nSaldo } ) // Sequencia, RECNO, Qtd. Lida
											_nSaldo := 0 // Fará sair do while pois terminei de distribuir o saldo da quantidade lida
											_lRet := .T.

										Else // Ainda não cheguei ao final e tenho saldo, atualizo a qtd original e a qtd lida do item atual
											_nQtdOri := aItens[ _nPosRec, BRW3QTD ]
											_nQtdLid := aItens[ _nPosRec, BRW3LID ]
										EndIf
									Else
										_lRet := .T.
									EndIf
									
								End // While _nSaldo > 0
								
								Exit

							Else // Caso contrario, posso somar toda a quantidade da ultima leitura
								If _nQtdLid < _nQtdOri
									aItens[ _nPosRec, BRW3LID ] += _nQtdSum
									aItens[ _nPosRec, BRW3QVA ] += _nQtdSum
									aItens[ _nPosRec, BRW3RES ] -= _nQtdSum
									_nLidos++
									aAdd( aLeitur, { _nLidos, cP14 + _cCodEan, _cTipo, _nQtdSum } ) // Sequencia, CB Lido, , Tipo de CB, Qtd. Lida
									aAdd( aQtDist, { _nLidos, _aPosEAN[ _nX, 2 ], _nQtdSum } ) // Sequencia, RECNO, Qtd. Lida
									_lRet := .T.
								Else
									Tone()
									MsgAlert("Quantidade lida supera a quantidade total do item!")
								EndIf

								Exit
							EndIf
							
						EndIf
					EndIf
				Endif
			Next
		EndIf
	EndIf

Return( _lRet )


// Função que busca a quantidade corresponde ao código EAN14
Static Function GetCB14( cCodB1, cP14 )

	Local _nQtd := 0
	
	dbSelectArea("SB5")
	dbSetOrder(1)
	If dbSeek( xFilial("SB5") + cCodB1 )
		If FieldPos("B5_EAN14"+cP14) > 0
			_nQtd := &("B5_EAN14"+cP14)
		EndIf
	EndIf
	
Return _nQtd


// Função que permite digitar a quantidade para EAN13
Static Function GetCB13(aEan,cEan,nLinha,lRetira)

	Local _aEan  := aEan
	Local _cEan  := cEan
	Local _nQtd  := Iif( nLinha == 0 .Or. lRetira, 1, 0 )
	Local _nCon  := 0
	Local _cTit  := Iif( lRetira, "Quantidade a retirar do volume", Iif( nLinha == 0, "Quantidade a Somar ao conferido", "Alterar quantidade do item") )
	Local oFont1 := TFont():New( "Arial",0,-14,,.T.,0,,700,.F.,.F.,,,,,, )
	Local oDlg1  := MSDialog():New( 225,463,361,749,_cTit,,,.F.,,,,,,.T.,,,.T. )
	Local oGet3  := TGet():New( 040,004,{|u| Iif(PCount()>0,_nQtd:=u,_nQtd)},oDlg1,060,014,'@E 999,999',{||_nQtd>0},CLR_BLUE,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","_nQtd"   ,,,,.F.,.F.,,"Quantidade:  ",2)
	Local oSBtn1 := SButton():New( 042,104,1,{|| Iif( _nQtd > 0, oDlg1:End(), MsgAlert("Quantidade deve ser maior que ZERO") ) },oDlg1,,"", )
	Local oSay1, oSay2,oGet1,oGet2

	If !(lRetira)

		oSay1  := TSay():New( 004,004,{||"EAN13"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
		oSay2  := TSay():New( 020,004,{||"Conferido"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
		oGet1  := TGet():New( 003,038,{||_cEan},oDlg1,068,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)
		oGet2  := TGet():New( 017,038,{||_nCon},oDlg1,048,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)
    
		For _nX := 1 To Len( _aEan )
			_nCon += aItens[ aScan( aItens, {|o| o[BRW3REC] == _aEan[ _nX, 2 ] } ), BRW3LID ]
		Next
	
	Else
		oDlg1:lEscClose := .F.
	EndIf
	
	oDlg1:Activate(,,,.T.)

Return(_nQtd)


// Atualiza a quantidade conferida no SDB
Static Function AtuSDB(_lDel)

	Local _nX   := 0
	Local _nRec := 0
	Local _nQtL := 0
	
	dbSelectArea("SDB")
	
	For _nX := 1 To Len( aItens )
		
		If !Empty( aItens[ _nX, BRW3ITM ] )
		
			_nRec := aItens[ _nX, BRW3REC ] // RECNO
			_nQtL := aItens[ _nX, BRW3LID ] // Quantidade Lida
			
			SDB->( DbGoTop() )
			SDB->( dbGoTo( _nRec ) )
			
			If !SDB->( Eof() )
				
				If SDB->DB_QTDLID != _nQtL
					RecLock("SDB",.F.)
						SDB->DB_QTDLID := _nQtL
						If !_lDel .And. _nQtL == SDB->DB_QUANT .And. SDB->DB_STATUS != cStatExec // Quantidade já conferida e status em execução
	
							SDB->DB_STATUS  := cStatExec // Executado
							SDB->DB_DATAFIM := dDataBase
							SDB->DB_HRFIM   := Left( Time(), 5 )
	
						ElseIf !_lDel .And. _nQtL > 0 .And. _nQtL < SDB->DB_QUANT .And. ( SDB->DB_STATUS == cStatAExe .Or. SDB->DB_STATUS == cStatProb ) // Em conferência e status a Executar
	
							SDB->DB_STATUS := cStatInte // Em execução ou Interrompido
							SDB->DB_HRINI  := Left( Time(), 5 )
							SDB->DB_RECHUM := __cUserID // Usuário atual
	
						ElseIf _lDel .And. SDB->DB_STATUS == cStatExec .And. _nQtL != SDB->DB_QUANT .And. _nQtL > 0 // Deletando leitura e reabrindo status
	
							SDB->DB_STATUS  := cStatInte // Em execução ou Interrompido
							SDB->DB_DATAFIM := CtoD("")
							SDB->DB_HRFIM   := Space(5)
	
						ElseIf _lDel .And. _nQtL == 0
	
							SDB->DB_STATUS  := cStatAExe // A executar
							SDB->DB_DATAFIM := CtoD("")
							SDB->DB_HRFIM   := Space(5)
	
						EndIf
					SDB->( MsUnLock() )
				EndIf
				
			EndIf
		EndIf
	Next

Return


// Carrega em um array os produtos, quantidades e a descrição dos produtos contidos em um volume
Static Function GetPrdVol( cVol )

	Local aLbx2 := {}
	
	ZCV->( DbSetOrder(1) )
	ZCV->( DbSeek( xFilial('ZCV') + cVol ) )
	
	While ZCV->( !Eof() ) .And. ( ZCV->( ZCV_FILIAL + ZCV_CODVOL ) == xFilial('ZCV') + cVol )
		SB1->( DbSeek( xFilial('SB1') + ZCV->ZCV_CODPRO ) )
		ZCV->( aAdd( aLbx2, { ZCV_CODPRO, ZCV_QUANT, SB1->B1_DESC } ) )
		ZCV->( DbSkip() )
	EndDo
	
Return ( aLbx2 )


// Retorna o código do volume que está sendo gerado
Static Function VerifVol( cPedido, lCria )

	Local cVolume := ""
	Local lVolNew := lCria
	
	// Quando verdadeiro força a criação de novo volume sem precisar avaliar o atual
	If !lCria
		// Verifico na tabela de volumes se existe algum volume em aberto
		ZCU->( DbSetOrder(2) )
		If ZCU->( !DbSeek( xFilial('ZCU') + cCarga + cPedido ) )
			lVolNew := .T.
		Else
			While !ZCU->( Eof() ) .And. xFilial('ZCU') + cCarga + cPedido == ZCU->ZCU_FILIAL + ZCU->ZCU_CARGA + ZCU->ZCU_PEDIDO
				If ZCU->ZCU_STATUS == "1"
					cVolume := ZCU->ZCU_CODVOL
					lVolNew := .F.
					Exit
				Else
					lVolNew := .T.
				EndIf
				ZCU->( dbSkip() )
			End
			
		EndIf
	EndIf
	
	// Crio o volume no sistema
	If lVolNew

		cVolume := PadL( CBProxCod('MV_WMSNVOL'), 10, '0' )
		
		RecLock('ZCU',.T.)
			ZCU->ZCU_FILIAL := xFilial('ZCU')
			ZCU->ZCU_PEDIDO := cPedido
			ZCU->ZCU_CODVOL := cVolume
			ZCU->ZCU_OPERAD := __CUSERID
			ZCU->ZCU_IMPETI := '0'
			ZCU->ZCU_STATUS := '1' // Em Montagem - Campo Customizado
			If ZCU->( FieldPos("ZCU_DATA") ) > 0
				ZCU->ZCU_DATA := dDataBase
				ZCU->ZCU_HORA := SubStr( Time(), 1, 5 )
			EndIf
		ZCU->( MsUnLock() )

	EndIf
	
Return( cVolume )


// Função que libera todas as teclas de função com codeblock atribuído
Static Function ClearFk()

	SetKey( VK_F3, Nil )
	SetKey( VK_F4, Nil )
	SetKey( VK_F7, Nil )
	SetKey( VK_F8, Nil )
	SetKey( VK_F9, Nil )

Return


// Função que atribui funções às teclas de atalho
Static Function SetaFk( cPedido )

	SetKey( VK_F3, {|| Pallet( cPedido ) } )
	SetKey( VK_F4, {|| DgtQuant() } )
	SetKey( VK_F7, {|| MsAguarde( {|| VolView( cPedido ) }, "Selecionando Volumes..." ) } )
	SetKey( VK_F8, {|| MsAguarde( {|| ConfVol( cPedido, .F. ) }, "Gravando Volume..." ) } )
	SetKey( VK_F9, {|| CtrlZ(cPedido) } )

Return
    

// Função que exibe os volumes já embalados nesta conferência
Static Function VolView( cPedido )

	ClearFk()

	MsgAlert("Solicitar implementação de melhoria!")
	
	SetaFk( cPedido )
	
Return


// Função que prepara os dados para envio da função que atualiza todos os dados do volume e imprime a etiqueta
Static Function ConfVol( cPedido, lFinal )

	Local _aProds := {}
	Local _lRet   := .F.
	Local _lCria  := .F.
	Local _nFim   := 0
	Local _aArea  := GetArea()

	ClearFk() // Libera as funções das teclas de atalho

	For _nX := 1 To Len( aItens )

		If !Empty( aItens[ _nX, BRW3ITM ] )
			
			If aItens[ _nX, BRW3QVA ] > 0 // Caso alguma quantidade deste item já tenha sido conferida/embalada
				
				aAdd( _aProds, { aItens[ _nX, BRW3COD ], , , , aItens[ _nX, BRW3QVA ] } )
				
				If aItens[ _nX, BRW3RES ] > 0 // Se neste item ainda tiver saldo a conferir, vai pra outro volume
					_lCria := .T.
				EndIf
	
			Else // Se neste item nada ainda foi lido, quando for lido irá para outro item
				_lCria := .T.
			EndIf
		EndIf
    Next

	// Grava o Volume, os Itens do Volume, atualiza Quantidades e Status na ZCS e libera as quantidades no SC9
	_lRet := WMAVolGrv( 1, cCarga, cPedido, _cCodVol, _aProds, .F., '' )
	
	// Se conseguiu finalizar o volume atualiza o status
	If _lRet
		dbSelectArea("ZCU")
		dbSetOrder(1)
		dbSeek( xFilial("ZCU") + _cCodVol )
		RecLock("ZCU",.F.)
			ZCU->ZCU_STATUS := "2" // Volume finalizado
		ZCU->( MsUnLock() )
	EndIf

	// Se conseguiu finalizar o volume, verifica se faz a impressão das etiquetas
	If _lRet .And. mv_par01 == 1
		U_WMSR410A( _cCodVol )
	EndIf
		
	// Se conseguiu finalizar o volume e ainda tem saldo para novo volume, cria o novo volume
	If _lRet .And. _lCria .And. !lFinal
		_cCodVol := VerifVol( cPedido, .T. )
	EndIf
	
	// Se conseguiu finalizar o volume, atualiza a quantidade de produtos embalados no array dos itens a conferir
	If _lRet
		For _nX := 1 To Len( aItens )
			aItens[ _nX, BRW3EMB ] += aItens[ _nX, BRW3QVA ]
			aItens[ _nX, BRW3QVA ] := 0
	    Next
	EndIf

	// Se conseguiu finalizar o volume, verifica se é o volume que encerra a conferencia automaticamente
	If _lRet
		If lFinal

			ConWmsEst()           // Atualiza o estoque e registra movimentação automática no SDB
			WmsC9Lib(cPedido,.T.) // Faz a liberação de WMS dos itens caso tenham sido estornados (bloqueados pela função habilita estorno)
			oDlgCon:End()         // Fecha a tela de conferência

		Else // Parametro não encerra automatico, verifico se este volume manual [F8] deixa saldo a conferir zerado

			// Soma o restante para verificar se encerrou a conferência
			aEval( aItens,{ |X| _nFim += X[BRW3RES] } )

			If _nFim > 0
				SetaFk( cPedido ) // Reatribui os valores às teclas de atalho, pois continua a conferência
			Else
				ConWmsEst()     // Atualiza o estoque e registra movimentação automática no SDB
				oDlgCon:End()   // Fecha a tela de conferência
			EndiF

		EndIf
	Else
		SetaFk( cPedido ) // Reatribui os valores às teclas de atalho, pois continua a conferência
	EndIf

	RestArea( _aArea )

Return

// Prepara a impressão da etiqueta de volume
User Function WMSR410A( cCodVol, lFlag, oObj )

	Local aZCUArea := ZCU->(GetArea())
	Local cVolume  := Iif( cCodVol == Nil, "", cCodVol )
	Local cLocImp  := SuperGetMV('MV_WMSLOCI',.F.,'      ')
	Local lLocImp  := .T.
	Local lFirst   := .T.
	Local cPedido  := ""
	Local nQtdZCV  := 0
	Local nView    := 0
	Local nPosView := 0
	Local nLoop    := 1
	Local nLinha   := 55
	Local aIteVol  := {}
	Local oGetLI, oDlgLI, oView 
	
	If Empty( cVolume ) .And. oObj != Nil
		
		// Quando estou no monitor de volumes, preciso buscar o número do volume posicionado no objeto da tela
		If ValType( oObj:AVIEWS ) == "A"
			nView := aScan( oObj:AVIEWS, {|o| AllTrim( o[ 1 ] ) == "VIEW_ZCU" } )
		EndIf

		If nView == 0
			Tone()
			MsgAlert("Não foi possível encontrar o volume!")
			Return
		EndIf
		
		// Recebe o Objeto que contemo Browse para a View selecionada
		oView := oObj:AVIEWS[ nView, 3 ]
		
		If ValType(oView) == Nil
			Tone()
			MsgAlert("Não foi possível encontrar o volume!")
			Return
		EndIf
		
		aView := oView:OBROWSE:ODATA:ASHOW
		nPosView := oView:OBROWSE:nAt
		
		If Type("aView") != "A" .Or. nPosView == 0
			Tone()
			MsgAlert("Não foi possível encontrar o volume!")
			Return
		EndIf
		
		nView := aScan( oView:OBROWSE:ACOLUMNS, {|o| AllTrim( o:CID ) == "ZCU_CODVOL" } )
		
		If nView == 0 .Or. Empty( aView[ nPosView, nView ] )
			Tone()
			MsgAlert("Não foi possível encontrar o volume!")
			Return
		Else
			cVolume := aView[ nPosView, nView ]
		EndIf
		
	EndIf
	
	If Empty( cLocImp )
		DEFINE MSDIALOG oDlgLI TITLE "Informe local da impressão" From 50,50 to 120,280 PIXEL
			@ 06,05 SAY "Local de Impressão:" SIZE 50,8 OF oDlgLI PIXEL
			@ 05,60 MSGET oGetLI VAR cLocImp F3 'CB5' SIZE 50,06 WHEN .T. PICTURE '@!' OF oDlgLI PIXEL
			DEFINE SBUTTON FROM 21,083 TYPE 1 ACTION ( oDlgLI:End() ) ENABLE Of oDlgLI
		ACTIVATE DIALOG oDlgLI CENTERED
	EndIf

	If !CB5SetImp( cLocImp, IsTelNet() )
		Tone()
		Alert("Local de impressao invalido!","Aviso",.t.,3000,2)
		lLocImp := .F.
	EndIf

	dbSelectArea("ZCU")	
	ZCU->( dbSetOrder(1) ) //ZCU_FILIAL+ZCU_CODVOL
	If ZCU->( dbSeek( xFilial("ZCU") + cVolume ) ) .And. lLocImp
		
		cPedido := ZCU->ZCU_PEDIDO
		
		dbSelectArea("SC5")
		dbSetOrder(1)
		dbSeek( xFilial("SC5") + cPedido )
		
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI )
		
		cPedido += " - "+ AllTrim( SA1->A1_NOME )
		
		dbSelectArea("ZCV")
		ZCV->( dbSetOrder(1) )
		dbSeek( xFilial("ZCV") + ZCU->ZCU_CODVOL )
		While !ZCV->( Eof() ) .And. ZCV->ZCV_FILIAL == xFilial("ZCV") .And. ZCV->ZCV_CODVOL == ZCU->ZCU_CODVOL

			nQtdZCV += ZCV->ZCV_QUANT
			aAdd( aIteVol, { Left( Posicione("SB1",1,xFilial("SB1")+ZCV->ZCV_CODPRO,"B1_DESC"), 40 ), "."+ PadL( cValToChar( ZCV->ZCV_QUANT ), 14 ) } )

			ZCV->( dbSkip() )
		EndDo
		
		// Atualiza campo ZCU_IMPETI (Flag de Impressao)
		dbSelectArea("ZCU")	
		RecLock("ZCU",.F.)
			ZCU->ZCU_IMPETI := '1'
		ZCU->( MsUnlock() )
		
		// Jean Rehermann - Solutio IT - 24/10/2017 - De acordo com solicitação do Jonas não deve mais imprimir a etiqueta de volume
		/*
		MSCBBEGIN(1,6)                            
			MSCBBOX(07,24,96,65,1)    
			MSCBLineH(35,60,96,1) 
			MSCBLineH(07,53,96,1) 
			MSCBLineH(07,45,96,1) 
			MSCBLineH(07,39,96,1) 
			MSCBLineV(35,53,64,1)
			MSCBSAY(13,55,'IMDEPA',"N","5","01,01")
			MSCBSAY(38,61,'ETIQUETA DE VOLUME',"N","2","01,01")
			MSCBSAY(38,58,'VOLUME: ',"N","1","01,01")
			MSCBSAY(38,54, cVolume, "N", "3", "01,01")
			MSCBSAY(09,50,'PEDIDO: ',"N","1","01,01")
			MSCBSAY(09,46, cPedido,"N", "2", "01,01")
			MSCBSAY(09,40,'PECAS NO VOLUME: '+ PADL( cValToChar( nQtdZCV ), 10 ),"N","2","01,01")
			MSCBSAYBAR(33,27,cVolume,"N","E",8.36,.F.,.T.,.F.,,3,2,.F.,.F.,"1",.T.)
		MSCBEND()
		*/		

		For _nX := 1 To Len( aIteVol )

			MSCBBEGIN(1,6)                            

			MSCBSAY(09,nLinha - ( 5 * nLoop ) - 4, aIteVol[ _nX, 1 ],"N", "2", "01,01")
			MSCBSAY(73,nLinha - ( 5 * nLoop ) - 4, aIteVol[ _nX, 2 ],"N", "2", "01,01")
	
			// Imprime o layout da etiqueta: 1- Imprimiu o último item; 2- For a 1a etiqueta e sexto item; 3- Não for 1a etiqueta e nono item
			If _nX == Len( aIteVol ) .Or. ( nLoop == 6 .And. lFirst ) .Or. ( nLoop == 9 )
				lFirst := ImpCabEt( lFirst, cVolume, ZCU->ZCU_PEDIDO, nLinha )
				nLoop := 0
			EndIf

		    nLoop++

		Next

		MSCBCLOSEPRINTER()

	EndIf
	
	RestArea( aZCUArea )

Return ( Nil )


// Função que faz a impressão do layout principal da etiqueta
Static Function ImpCabEt( lPrim, cVol, cPed, nLinha )

	Local _nO := 0
	
	MSCBBOX(07,05,100,65,1) // Caixa que circunda a etiqueta (box)
	MSCBLineH(35,60,100,1)  // Linha no cabeçalho que começa ao lado do logotipo (horizontal)
	MSCBLineH(07,53,100,1)  // Linha que fecha o cabeçalho (horizontal)
	MSCBLineV(35,53,65,1)   // Linha que separa o logotipo da identificação da etiqueta (vertical)
	
	If lPrim
		MSCBLineH(07,20,100,1) // Linha que separa a área dos itens da área do código de barras (horizontal)
		MSCBLineV(70,20,60,1)  // Linha que separa nos itens os campos da descrição e da quantidade (vertical)
		MSCBSAYBAR(33,06,cVol,"N","E",8.36,.F.,.T.,.F.,,3,2,.F.,.F.,"1",.T.)
		// Imprime todas as linhas de itens da etiqueta, neste caso 6
		For _nO := 1 To 6
			MSCBLineH(07,nLinha - ( 5 * _nO ),100,1)
		Next
	Else
		MSCBLineV(70,05,60,1) // Linha que separa nos itens os campos da descrição e da quantidade (vertical)
		// Imprime todas as linhas de itens da etiqueta, neste caso 9
		For _nO := 1 To 9
			MSCBLineH(07,nLinha - ( 5 * _nO ),100,1)
		Next
	EndIf
	
	MSCBSAY(13,55,'IMDEPA',"N","5","01,01")
	MSCBSAY(38,61,'ETIQUETA DE PICK LIST DE VOLUME',"N","2","01,01")
	MSCBSAY(38,58,'VOLUME: ',"N","1","01,01")
	MSCBSAY(38,54, cVol, "N", "3", "01,01")
	MSCBSAY(73,58,'PEDIDO: ',"N","1","01,01")
	MSCBSAY(73,54, cPed, "N", "3", "01,01")
	MSCBSAY(09,51,'PRODUTO: ',"N","1","01,01")
	MSCBSAY(73,51,'QUANTIDADE: ',"N","1","01,01")

	MSCBEND()
	
Return( .F. ) // Sempre retorno falso para alimentar a variável de primeira impressão


// Função que verifica a quantidade que já está embalada em volumes para mostrar nos itens da conferência
Static Function QtdEmbVol( cPedido, cProduto, cIDDCF )

	Local _nQtdVol  := 0
	Local cQuery    := ""
	Local cAliasSC9 := ""
	Local cAliasZCV := ""
	
	cQuery := "SELECT C9_SEQUEN, SUM(C9_QTDLIB) AS SOMASC9"
	cQuery += " FROM "+ RetSqlName('SC9') +" SC9"
	cQuery += " WHERE C9_FILIAL   = '"+ xFilial('SC9') +"'"
	cQuery +=      " AND C9_PEDIDO  = '"+ cPedido +"'"
	cQuery +=      " AND C9_PRODUTO = '"+ cProduto +"'"
	cQuery +=      " AND C9_BLWMS   = '01'"
	cQuery +=      " AND C9_IDDCF   = '"+ cIDDCF +"'"
	cQuery +=      " AND D_E_L_E_T_ = ' '"
	cQuery +=      " GROUP BY C9_SEQUEN"
	cQuery +=      " ORDER BY C9_SEQUEN"
	cQuery := ChangeQuery(cQuery)
	cAliasSC9 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSC9,.F.,.T.)

	While (cAliasSC9)->( !Eof() )
	
		// Quantidade embalada em volumes anteriores
		cQuery := "SELECT SUM(ZCV_QUANT) AS SOMAZCV"
		cQuery += " FROM "+ RetSqlName('ZCV') +" ZCV"
		cQuery += " WHERE ZCV_FILIAL = '"+ xFilial('ZCV')          +"'"
		cQuery +=   " AND ZCV_CODPRO = '"+ cProduto                +"'"
		cQuery +=   " AND ZCV_IDDCF  = '"+ cIDDCF                  +"'"
		cQuery +=   " AND ZCV_SEQUEN = '"+ (cAliasSC9)->C9_SEQUEN  +"'"
		cQuery +=   " AND ZCV_STATUS <> '1'"
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasZCV := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasZCV,.F.,.T.)

		_nQtdVol += (cAliasZCV)->SOMAZCV

		(cAliasSC9)->( dbSkip() )
		(cAliasZCV)->( dbCloseArea() )
	
	EndDo

	(cAliasSC9)->( dbCloseArea() )

Return _nQtdVol


// Grava o Volume, os Itens do Volume, atualiza Quantidades e Status na ZCS e libera as quantidades no SC9
Static Function WMAVolGrv( nAcao, cCarga, cPedido, cVolume, aProdutos, lSepara, cDtHr )

	Local nX          := 0
	Local nY          := 0
	Local lRet        := .F.
	Local nQtdEmb     := 0 // Quantidade que será embalada no ZCV corrente
	Local nQtdRes     := 0 // Quantidade que resta a ser embalada
	Local nQtdSol     := 0
	Local nSaldo      := 0
	Local nQtdVol     := 0
	Local cLocImp     := Space(Len(CB5->CB5_CODIGO))
	Local lLocImp     := .T.
	Local nTotLote    := 0
	Local nTotItem    := 0
	Local nQtdTotEmb  := 0
	Local lRasLot     := ( AllTrim( SuperGetMV('MV_RASTRO',.F.,'N') ) == 'S') .And. SuperGetMV('MV_WMSLOTE',.F.,.F.)
	Local cQuery      := ''
	Local cAliasZCT   := ''
	Local cAliasSC9   := ''
	Local cAliasZCU   := ''
	Local cAliasZCV   := ''
	Local aAreaAnt   := GetArea()
	
	Default cCarga    := ''
	Default cPedido   := ''
	Default cVolume   := ''
	Default aProdutos := {}
	Default nAcao     := 1
	Default lSepara   := .F.
	Default cDtHr     := ''
	
	ZCS->(DbSetOrder(1)) //ZCS_FILIAL+ZCS_CARGA+ZCS_PEDIDO+DTOS(ZCS_DATA)+ZCS_HORA
	ZCT->(DbSetOrder(1)) //ZCT_FILIAL+ZCT_CARGA+ZCT_PEDIDO+ZCT_CODPRO+ZCT_LOTE+ZCT_SUBLOT+ZCT_IDDCF
	ZCV->(DbSetOrder(2)) //ZCV_FILIAL+ZCV_CODPRO+ZCV_LOTE+ZCV_SUBLOT+ZCV_IDDCF+ZCV_SEQUEN
	
	While !LockByName(Iif(nAcao==1,'WMST390','WMSV080'),.F.,.F. )
		Sleep(50)
		nX++
		If nX > 200
			Return ( .F. )
		EndIf
	EndDo
	
	Begin Transaction
	
		ZCU->(DbSetOrder(2)) //ZCU_FILIAL+ZCU_CARGA+ZCU_PEDIDO+ZCU_CODVOL
		If ZCU->(!DbSeek(xFilial('ZCU')+cCarga+cPedido+cVolume))

			RecLock('ZCU',.T.)
				ZCU->ZCU_FILIAL := xFilial('ZCU')
				ZCU->ZCU_CARGA  := cCarga
				ZCU->ZCU_PEDIDO := cPedido
				ZCU->ZCU_CODVOL := cVolume
				ZCU->ZCU_OPERAD := __CUSERID
				ZCU->ZCU_IMPETI := '0'
				ZCU->ZCU_STATUS := '1'
				If ZCU->(FieldPos("ZCU_DATA")) > 0
					ZCU->ZCU_DATA := StoD(SubStr(cDtHr,1,8))
					ZCU->ZCU_HORA := SubStr(cDtHr,9,5)
				EndIf
			ZCU->(MsUnLock())

		EndIf

		D00->(DbSetOrder(4)) // D00_FILIAL+D00_CARGA+D00_PEDIDO+D00_CODEND+D00_CODVOL
		// Jean Rehermann - Solutio IT - 19/09/2017 - Alteração para contemplar o embarque e a conferência dos volumes (gravação da tabela D00)
		RecLock("D00",D00->( !DbSeek( xFilial('D00') + cCarga + cPedido + Padr("DOCA",TamSX3("D00_CODEND")[1]) + cVolume ) ) )
			D00->D00_FILIAL	:= xFilial("D00")
			D00->D00_CARGA	:= cCarga
			D00->D00_PEDIDO	:= cPedido
			D00->D00_CODEND	:= "DOCA"
			D00->D00_OPEEND	:= __CUSERID
			D00->D00_DATEND	:= dDataBase
			D00->D00_HOREND	:= Time()
			D00->D00_CODDOC	:= "DOCA"
			D00->D00_OPEDOC := __CUSERID
			D00->D00_DATDOC	:= dDataBase
			D00->D00_HORDOC	:= Time()
			If D00->(FieldPos("D00_CODVOL")) > 0
				D00->D00_CODVOL	:= cVolume
			EndIf	
			If D00->(FieldPos("D00_TIPEMB")) > 0
				D00->D00_TIPEMB	:= '0'
			EndIf
		D00->(MsUnLock())
		
		For nY := 1  To Len(aProdutos)
	
			// Validar quando status na ZCT já for 3 (QTD SEP. = QTD.EMB.)
			If CheckZCT( aProdutos[nY,1], cCarga, cPedido )
				Loop
			EndIf
			
			nQtdRes  := aProdutos[ nY, 5 ]
	
			cQuery := "SELECT ZCT_CARGA, ZCT_PEDIDO, ZCT_LOTE, ZCT_SUBLOT, ZCT_QTSEPA, ZCT_QTEMBA, ZCT_IDDCF, ZCT.R_E_C_N_O_ RECNOZCT"
			cQuery += " FROM "+RetSqlName('ZCT')+" ZCT"
			cQuery += " WHERE ZCT_FILIAL  = '"+xFilial('ZCT')+"'"
			cQuery +=      " AND ZCT_CARGA  = '"+cCarga+"'"
			cQuery +=      " AND ZCT_PEDIDO = '"+cPedido+"'"
			cQuery +=      " AND ZCT_CODPRO = '"+aProdutos[nY,1]+"'"
			If lRasLot
				cQuery +=   " AND ZCT_LOTE   = '"+aProdutos[nY,3]+"'"
				cQuery +=   " AND ZCT_SUBLOT = '"+aProdutos[nY,4]+"'"
			EndIf
			If ZCT->(FieldPos("ZCT_DATA")) > 0
				cQuery +=   " AND ZCT_DATA = '"+SubStr(cDtHr,1,8)+"'"
				cQuery +=   " AND ZCT_HORA = '"+SubStr(cDtHr,9,5)+"'"
			EndIf			
			cQuery +=      " AND ZCT_STATUS <> '3'"
			cQuery +=      " AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasZCT := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasZCT,.F.,.T.)
	
			nTotItem := 0
			nQtdSol  := nQtdRes
			While (cAliasZCT)->(!Eof()) .AND. QtdComp(nQtdRes) > 0
	
				nTotLote := 0
				nSaldo   := (cAliasZCT)->ZCT_QTSEPA - (cAliasZCT)->ZCT_QTEMBA
				If QtdComp(nQtdRes) > QtdComp(nSaldo)
					nQtdEmb := nSaldo
				Else
					nQtdEmb := nQtdRes
				EndIf
				nQtdRes -= nQtdEmb
	
				//verifica se o produto é um filho
				If SuperGetMV("MV_WMSNEW",.F.,.F.)
					dbSelectArea("D11")
					D11->(dbSetOrder(2))
					If dbSeek(xFilial("D11")+aProdutos[nY,1])
						cProdSC9 := D11->D11_PRODUT
						nQTMULT  := D11->D11_QTMULT
					Else
						cProdSC9 := aProdutos[nY,1]
						nQTMULT  := 1
					EndIf
				Else
					cProdSC9 := aProdutos[nY,1]
					nQTMULT  := 1
				EndIf
				cQuery := "SELECT C9_SEQUEN, SUM(C9_QTDLIB) AS SOMASC9" //O SUM para quando se está trabalhando com carga
				cQuery += " FROM "+RetSqlName('SC9')+" SC9"
				cQuery += " WHERE C9_FILIAL   = '"+xFilial('SC9')+"'"
				If !(Empty(cCarga))
					cQuery +=   " AND C9_CARGA  = '"+(cAliasZCT)->ZCT_CARGA+"'"
				EndIf
				cQuery +=      " AND C9_PEDIDO   = '"+(cAliasZCT)->ZCT_PEDIDO+"'"
				cQuery +=      " AND C9_PRODUTO = '"+cProdSC9+"'"
				cQuery +=      " AND C9_LOTECTL = '"+(cAliasZCT)->ZCT_LOTE+"'"
				cQuery +=      " AND C9_NUMLOTE = '"+(cAliasZCT)->ZCT_SUBLOT+"'"
				//cQuery +=      " AND C9_BLWMS   = '01'"
				cQuery +=      " AND C9_IDDCF   = '"+(cAliasZCT)->ZCT_IDDCF+"'"
				cQuery +=      " AND D_E_L_E_T_ = ' '"
				cQuery +=      " GROUP BY C9_SEQUEN"
				cQuery +=      " ORDER BY C9_SEQUEN"
				cQuery := ChangeQuery(cQuery)
				cAliasSC9 := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSC9,.F.,.T.)
	
				While (cAliasSC9)->(!Eof()) .AND. QtdComp(nQtdEmb) > 0
					//É preciso descontar a quantidade embalada em volumes anteriores
					cQuery := "SELECT SUM(ZCV_QUANT) AS SOMAZCV"
					cQuery += " FROM "+RetSqlName('ZCV')+" ZCV"
					cQuery += " WHERE ZCV_FILIAL = '"+xFilial('ZCV')+"'"
					cQuery +=   " AND ZCV_CODPRO = '"+aProdutos[nY,1]+"'"
					cQuery +=   " AND ZCV_LOTE   = '"+(cAliasZCT)->ZCT_LOTE+"'"
					cQuery +=   " AND ZCV_SUBLOT = '"+(cAliasZCT)->ZCT_SUBLOT+"'"
					cQuery +=   " AND ZCV_IDDCF  = '"+(cAliasZCT)->ZCT_IDDCF+"'"
					cQuery +=   " AND ZCV_SEQUEN = '"+(cAliasSC9)->C9_SEQUEN+"'"
					cQuery +=   " AND ZCV_STATUS <> '1'"
					cQuery +=   " AND D_E_L_E_T_ = ' '"
					cQuery := ChangeQuery(cQuery)
					cAliasZCV := GetNextAlias()
					DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasZCV,.F.,.T.)
	
					//Se a Quantidade a embalar for maior que o item liberado varre as outras sequencias do pedido
					If QtdComp(nQtdEmb) >  QtdComp(((cAliasSC9)->SOMASC9 * nQTMULT) - (cAliasZCV)->SOMAZCV)
						nQtdVol := ((cAliasSC9)->SOMASC9 * nQTMULT) - (cAliasZCV)->SOMAZCV
					Else
						nQtdVol := nQtdEmb
					EndIf
	
					If QtdComp(nQtdVol) == 0
						(cAliasSC9)->(DbSkip())
						Loop
					EndIf
	
					ZCV->(DbSetOrder(1))
					If ZCV->(!DbSeek(xFilial('ZCV')+cVolume+aProdutos[nY,1]+(cAliasZCT)->ZCT_LOTE+(cAliasZCT)->ZCT_SUBLOT+(cAliasZCT)->ZCT_IDDCF+(cAliasSC9)->C9_SEQUEN))
						RecLock('ZCV',.T.)
						ZCV->ZCV_FILIAL := xFilial('ZCV')
						ZCV->ZCV_CODVOL := cVolume
						ZCV->ZCV_CODPRO := aProdutos[nY,1]
						ZCV->ZCV_LOTE   := (cAliasZCT)->ZCT_LOTE
						ZCV->ZCV_SUBLOT := (cAliasZCT)->ZCT_SUBLOT
						ZCV->ZCV_SEQUEN := (cAliasSC9)->C9_SEQUEN
						ZCV->ZCV_QUANT  := nQtdVol
						ZCV->ZCV_IDDCF  := (cAliasZCT)->ZCT_IDDCF
						ZCV->ZCV_STATUS := '0' //Não Liberado
						If ZCV->(FieldPos("ZCV_CARGA")) > 0
							ZCV->ZCV_CARGA  := (cAliasZCT)->ZCT_CARGA
							ZCV->ZCV_PEDIDO := (cAliasZCT)->ZCT_PEDIDO
							ZCV->ZCV_DATA   := StoD(SubStr(cDtHr,1,8))
							ZCV->ZCV_HORA   := SubStr(cDtHr,9,5)
						EndIf						
						ZCV->(MsUnlock())
					Else
						RecLock('ZCV',.F.)
						ZCV->ZCV_QUANT  += nQtdVol
						ZCV->(MsUnlock())
					EndIf
					nQtdEmb    -= nQtdVol
					nTotLote   += nQtdVol
					nTotItem   += nQtdVol
					nQtdTotEmb += nQtdVol
					(cAliasSC9)->(DbSkip())
					(cAliasZCV)->(DbCloseArea())
				EndDo
	
				ZCT->(DbGoTo((cAliasZCT)->RECNOZCT))
				RecLock('ZCT',.F.)
				ZCT->ZCT_QTEMBA += nTotLote
				If ZCT->ZCT_QTEMBA == ZCT->ZCT_QTSEPA
					ZCT->ZCT_STATUS := '3' //Finalizado
				Else
					ZCT->ZCT_STATUS := '2' //Em Andamento
				EndIf
				lRet := .T.
				ZCT->(MsUnlock())
				(cAliasZCT)->(DbSkip())
				(cAliasSC9)->(DbCloseArea())
			EndDo
	
			If QtdComp(nQtdSol) != QtdComp(nTotItem)
				If nAcao == 1
					Aviso("Atenção", "Quantidade solicitada para embalagem do produto "+ AllTrim(aProdutos[nY,1]) +" não possui saldo de pedido a ser liberado", {'OK'})
				Else
					DLVTAviso("Aviso", "Quantidade solicitada para embalagem do produto não possui saldo de pedido a ser liberado")
					VtKeyboard(Chr(20))
				EndIf
				lRet := .F.
				Exit
			EndIf
	
			(cAliasZCT)->(DbCloseArea())
		Next
	
		If lRet
			If ZCS->(DbSeek(xFilial('ZCS')+cCarga+cPedido+cDtHr))
				RecLock('ZCS',.F.)
					ZCS->ZCS_QTEMBA += nQtdTotEmb
					If ZCS->ZCS_QTEMBA == ZCS->ZCS_QTSEPA
						ZCS->ZCS_STATUS := '3' //Finalizado
					Else
						ZCS->ZCS_STATUS := '2' //Em Andamento
					EndIf
				ZCS->(MsUnlock())
			EndIf
	
			If ZCU->(FieldPos("ZCU_DATA")) > 0
				cSeek := cCarga+cPedido+cDtHr
				nIndZCU := 3
			Else
				cSeek := cCarga+cPedido
				nIndZCU := 2
			EndIf
			//Atualização do Status da ZCV para Liberado
			If ZCS->ZCS_STATUS == '3'
				ZCU->(DbSetOrder(nIndZCU))
				If ZCU->(DbSeek(xFilial('ZCU')+cSeek))
					While ZCU->(!Eof()) .And. (ZCU->(ZCU_FILIAL+ZCU_CARGA+ZCU_PEDIDO+If(nIndZCU == 3,DTOS(ZCU_DATA)+ZCU_HORA,'')) == xFilial("ZCU")+cSeek)
						ZCV->(DbSetOrder(1))
						If ZCV->(DbSeek(xFilial('ZCV')+ZCU->ZCU_CODVOL))
							While ZCV->(!Eof()) .And. (ZCV->(ZCV_FILIAL+ZCV->ZCV_CODVOL)  == xFilial("ZCV")+ZCU->ZCU_CODVOL)
								RecLock('ZCV',.F.)
									ZCV->ZCV_STATUS := '1' //Liberado
								ZCV->(MsUnlock())
								ZCV->(DbSkip())
							EndDo
						EndIf
						ZCU->(DbSkip())
					EndDo
					If ZCT->(FieldPos("ZCT_DATA")) > 0
						nInd  := 3
						cSeek := cCarga+cPedido+cDtHr
					Else
						nInd  := 1
						cSeek := cCarga+cPedido
					EndIf
					SC9->(DbSetOrder(9))
					ZCT->(DbSetOrder(nInd))
					If ZCT->(DbSeek(xFilial('ZCT')+cSeek))
						While ZCT->(!Eof()) .And. (ZCT->(ZCT_FILIAL+ZCT_CARGA+ZCT_PEDIDO+If(nInd == 3,DTOS(ZCT_DATA)+ZCT_HORA,'')) == xFilial('ZCT')+cSeek)
							RecLock('ZCT',.F.)
								ZCT->ZCT_QTLIBE := ZCT->ZCT_QTEMBA
							ZCT->(MsUnlock())
							If SC9->(MsSeek(xFilial('SC9')+ZCT->ZCT_IDDCF)) .And. !(lSepara .And. (AllTrim(SuperGetMV('MV_WMSCEXP',.F.,'0'))  $ '14') )
								While SC9->(!Eof()) .And. (SC9->(C9_FILIAL+C9_IDDCF) == xFilial('SC9')+ZCT->ZCT_IDDCF)
									RecLock('SC9',.F.)
									SC9->C9_BLWMS := '05'
									SC9->(MsUnlock())
									SC9->(DbSkip())
								EndDo
							EndIf
							ZCT->(DbSkip())
						EndDo
					EndIf
				EndIf
			EndIf
		EndIf
		If !lRet
			DisarmTransaction()
		EndIf
	End Transaction
	
	If nAcao == 1
		UnLockByName('WMSA390',.F.,.F.)
	ElseIf nAcao == 2
		UnLockByName('WMSV080',.F.,.F.)
	EndIf
	
	RestArea(aAreaAnt)
Return lRet


// Esta função desfaz a última leitura, caso o item lido não caiba no volume
Static Function CtrlZ(cPedido)

	Local aLer := {}
	Local aDis := {}
	Local nSeq := 0
	Local nPos := 0
	Local _lOK := .T.
	Local _lErase := .T.
	
	If Len( aLeitur ) == 0
		Tone()
		MsgAlert("Não há nenhum registro de leitura de conferência!")
		Return
	EndIf
	
	ClearfK()
	aLer := aTail( aLeitur ) // Sequencia, CB Lido, , Tipo de CB, Qtd. Lida
	
	If !MsgYesNo("Desfazer a última leitura? ["+ AllTrim( aLer[ 2 ] ) +" | "+ AllTrim( aLer[ 3 ] )  +"] - Quantidade ["+ cValToChar( aLer[ 4 ] ) +"]")
		Return
	EndIf
	
	nSeq := aLer[ 1 ]
	
	While _lOK
	
		If Len( aQtDist ) > 0
			If !aQtDist[ Len( aQtDist ), 1 ] == nSeq
				_lOK := .F.
				Loop
			EndIf
		Else
			_lOK := .F.
			Loop
		EndIf
		
		aDis := aQtDist[ Len( aQtDist ) ] // Sequencia, RECNO, Qtd. Lida
		nPos := aScan( aItens, {|o| o[BRW3REC] == aDis[ 2 ] } ) // Linha dos itens que corresponde ao RECNO do SDB da quantidade a ser subtraída
		
		If aDis[ 3 ] <= aItens[ nPos, BRW3QVA ] // Verifico se a quantidade a excluir pertence ao volume aberto

			aDel( aQtDist, Len( aQtDist ) ) // Apaga o último item do array
			aSize( aQtDist, Len( aQtDist ) - 1 ) // Exclui fisicamente o registro do array
			
			aItens[ nPos, BRW3LID ] -= aDis[ 3 ]
			aItens[ nPos, BRW3QVA ] -= aDis[ 3 ]
			aItens[ nPos, BRW3RES ] += aDis[ 3 ]
		    
			_lErase := .T.
		Else
			Tone()
			MsgAlert("Quantidade pertence a volume já fechado!")
			_lOK := .F.
		EndIf
		
	End

	If _lErase // Apagou pelo menos uma linha do array das quantidades distribuidas

		// Quando for a leitura de uma etiqueta que eu estou desfazendo, retiro ela do array de controle de leitura de etiquetas
		If aLer[ 3 ] == TXTIDLOG
		
			nPos := aScan( aEtiq, {|o| AllTrim( o ) == AllTrim( aLer[ 2 ] ) } )
			
			If nPos > 0
				aDel( aEtiq, nPos ) // Apaga o último item do array
				aSize( aEtiq, nPos - 1 ) // Exclui fisicamente o registro do array
				CB0->( dbSetOrder(1) )
				CB0->( dbSeek( xFilial("CB0") + AllTrim( aLer[ 2 ] ) ) )
				CB0->( RecLock("CB0",.F.) )
					If CB0->CB0_IDMVTO == _cIdDCF
						CB0->CB0_IDMVTO := Space( Len( CB0->CB0_IDMVTO ) )
					EndIf
				CB0->( MsUnLock() )
			EndIf
		
		EndIf
		
		aDel( aLeitur, Len( aLeitur ) ) // Apaga o último item do array
		aSize( aLeitur, Len( aLeitur ) - 1 ) // Exclui fisicamente o registro do array
		aItens := Organiza( aItens ) // Reordena os itens de acordo com as leituras
		oItens:nAt := 1  // Mantenho o foco no item vazio
		oItens:Refresh() // Atualiza o Browse na tela
		AtuSDB(.T.) // Atualiza os registros no SDB

	EndIf
	
	SetaFk( cPedido )
	
Return

// Função que grava no SDB o registro de movimentação de estoque e realiza a movimentação de endereços (da MESA para a DOCA)
Static Function ConWmsEst()

	Local _nX       := 0
	Local _nRecSDB  := 0
	Local cQuery    := ""
	Local cAliasQry := ""
	
	Private aParam150  := Array(34)
	Private _nQtdEmpBF := 0
	
	dbSelectArea("SDB")

	For _nX := 1 To Len( aItens )
		
		If !Empty( aItens[ _nX, BRW3ITM ] )
		
			_nRecSDB := aItens[ _nX, BRW3REC ]
			
			SDB->( DbGoTop() )
			SDB->( dbGoTo( _nRecSDB ) )
			
			If !SDB->( Eof() ) .And. Empty( SDB->DB_ESTFLAG ) // Flag de registro de estorno que não precisa de nova liberação
			
				cQuery := "SELECT DCF.R_E_C_N_O_ DCFRECNO "
				cQuery += "  FROM "+ RetSqlName('DCF') +" DCF "
				cQuery += " WHERE DCF.DCF_FILIAL = '"+ xFilial("DCF") +"'"
				cQuery += "   AND DCF.DCF_NUMSEQ = '"+ SDB->DB_NUMSEQ +"'"
				cQuery += "   AND DCF.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery( cQuery )
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),(cAliasQry := GetNextAlias()),.F.,.T.)
				If (cAliasQry)->( !Eof() )
					DCF->( dbGoTo( (cAliasQry)->DCFRECNO ) )//Posicionar no DCF selecionado
				EndIf
				(cAliasQry)->( dbCloseArea() )
	
				aParam150[01]  := SDB->DB_PRODUTO //-- Produto
				aParam150[02]  := SDB->DB_LOCAL   //-- Almoxarifado
				aParam150[03]  := SDB->DB_DOC     //-- Documento
				aParam150[04]  := SDB->DB_SERIE   //-- Serie
				aParam150[05]  := DCF->DCF_NUMSEQ
				aParam150[06]  := SDB->DB_QUANT   //-- Saldo do produto em estoque
				aParam150[07]  := SDB->DB_DATA    //-- Data da Movimentacao
				aParam150[08]  := Time()          //-- Hora da Movimentacao
				aParam150[09]  := SDB->DB_SERVIC  //-- Servico
				aParam150[10]  := SDB->DB_TAREFA  //-- Tarefa
				aParam150[11]  := SDB->DB_ATIVID  //-- Atividade
				aParam150[12]  := SDB->DB_CLIFOR  //-- Cliente/Fornecedor
				aParam150[13]  := SDB->DB_LOJA    //-- Loja
				aParam150[14]  := ''              //-- Tipo da Nota Fiscal
				aParam150[15]  := '01'            //-- Item da Nota Fiscal
				aParam150[16]  := ''              //-- Tipo de Movimentacao
				aParam150[17]  := SDB->DB_ORIGEM  //-- Origem de Movimentacao
				aParam150[18]  := SDB->DB_LOTECTL //-- Lote
				aParam150[19]  := SDB->DB_NUMLOTE //-- Sub-Lote
				aParam150[20]  := SDB->DB_LOCALIZ //-- Endereco
				aParam150[21]  := SDB->DB_ESTFIS  //-- Estrutura Fisica
				aParam150[22]  := 0                   //-- Regra de Apanhe (1=LOTE/2=NUMERO DE SERIE/3=DATA.SEQ.ABAST/4=DATA)
				aParam150[23]  := SDB->DB_CARGA   //-- Carga
				aParam150[24]  := SDB->DB_UNITIZ  //-- Nr. do Pallet
				aParam150[25]  := SDB->DB_LOCAL   //-- Centro de Distribuicao Destino
				aParam150[26]  := SDB->DB_ENDDES  //-- Endereco Destino
				aParam150[27]  := SDB->DB_ESTDES  //-- Estrutura Fisica Destino
				aParam150[28]  := SDB->DB_ORDTARE //-- Ordem da Tarefa
				aParam150[29]  := SDB->DB_ORDATIV //-- Ordem da Atividade
				aParam150[30]  := SDB->DB_RHFUNC  //-- Funcao do Recurso Humano
				aParam150[31]  := SDB->DB_RECFIS  //-- Recurso Fisico
				aParam150[32]  := SDB->DB_IDDCF   //-- Identificador do DCF DCF_ID
				aParam150[34]  := SDB->DB_IDMOVTO //-- Identificador exclusivo do Movimento no SDB
	
				Begin Transaction
				
					_nQtdEmpBF := 0 // Variável que receberá o empenho do SDB para gravar depois no SBF endereço DOCA
					
					WmsRemSBF() // Remove o empenho do SBF para poder fazer a liberação
					
					_lRet := WmsMovEst( aParam150 ) // Realiza a movimentação do saldo para o endereço DOCA
					
					WmsSBFEmp( _nQtdEmpBF ) // Grava o empenho do SDB na DOCA para faturamento
					
					If _lRet
						DLVStAuto( aParam150[09], aParam150[28], aParam150[10] ) // Realiza a atualização do status no SDB com a movimentação de estoque automática
					EndIf
			    
				If !_lRet
					DisarmTransaction()
				EndIf
				
				End Transaction
			    
			EndIf
		EndIf
	Next

Return( _lRet )

// Remover o empenho do SBF para ter saldo de movimentação na liberação
Static Function WmsRemSBF()

	Local _aArea := GetArea()

	dbSelectArea("SBF")
	dbSetOrder(1)
	
	If dbSeek( xFilial("SBF") + SDB->DB_LOCAL + SDB->DB_LOCALIZ + SDB->DB_PRODUTO )
		If SBF->BF_EMPENHO > 0
			_nQtdEmpBF := SDB->DB_QUANT
			RecLock("SBF",.F.)
				SBF->BF_EMPENHO := SBF->BF_EMPENHO - SDB->DB_QUANT
			MsUnLock()
		EndIf
	EndIf
	
	RestArea( _aArea )
	
Return

// Atualiza no SC9 o Campo AGREG para pallet (legenda amarela na tela de faturamento)
Static Function Pallet( cPedPal )
	
	Local _aAreaATU := GetArea()
	Local _aAreaSC9 := SC9->( GetArea() )
	
	lPalet := !lPalet
	
	dbSelectArea("SC9")
	dbSetOrder(1)
	If dbSeek( xFilial("SC9") + cPedPal )
		While !SC9->( Eof() ) .And. SC9->C9_FILIAL + SC9->C9_PEDIDO = xFilial("SC9") + cPedPal
			RecLock("SC9",.F.)
				SC9->C9_AGREG := Iif( lPalet, "PALL", "    ")
			SC9->( MsUnlock() )
			
			SC9->( dbSkip() )
		End
	EndIf

	oSayP:SetText( Iif( lPalet, "Sim", "Não" ) )
	oSayP:nClrText := Iif( lPalet, CLR_GREEN, CLR_RED )
	oSayP:Refresh()
	
	RestArea( _aAreaATU )
	RestArea( _aAreaSC9 )
	
Return

// Verifica no SC9 se o Campo AGREG está marcado para pallet (legenda amarela na tela de faturamento)
Static Function VePallet( cPedPal )
	
	Local _aAreaATU := GetArea()
	Local _aAreaSC9 := SC9->( GetArea() )
	
	dbSelectArea("SC9")
	dbSetOrder(1)
	If dbSeek( xFilial("SC9") + cPedPal )
		lPalet := SC9->C9_AGREG == "PALL"
	EndIf

	RestArea( _aAreaATU )
	RestArea( _aAreaSC9 )
	
Return

// Ativar ou desativar digitação da quantidade na conferência
Static Function DgtQuant()
	lAltQtd := !lAltQtd
	oSayQ:SetText( Iif( lAltQtd, "Sim", "Não" ) )
	oSayQ:nClrText := Iif( lAltQtd, CLR_GREEN, CLR_RED )
	oSayQ:Refresh()
	If Type("oBrwItm") == "O"
		BrwItVol( .F., 1 )
	EndIf
Return

// Tela de retirada de produtos de volumes (estorno com redução de quantidade ou exclusão de item)
Static Function LerRetVol( cPedVol )
      
	Local oGet1, oSBtn1, oSBtn2, aColItm, aColVol, oSay1
	Local oFontB  := TFont():New( "Arial",,-13,,.T.,,,,,.F.,.F. )
	Local oFont1  := TFont():New( "Arial",,-14,,.T.,,,,,.F.,.F. )
	Local oFont2  := TFont():New( "Arial",,-10,,.T.,,,,,.F.,.F. )
	Local cCodPrd := Space(16)
	Local cVolume := Space(11)
	Local nOpc    := 0
	Local _lExclu := .F.
	Local _lImpEt := .F.

	Private oBrwItm, oBrwVol, oSay2, oGet2, oDlgR
	Private _cProd  := ""
	Private aRegItm := {}
	Private aRegVol := {}
	Private aRegImp := {} // Array com os volumes que deverão ser impressos
	Private lAltQtd := SuperGetMV("IMD_ALTQCO", .F., .F.) // Permite alterar a quantidade na leitura do EAN13
	
	Carga( cPedVol ) // Alimenta os arrays de produtos e volumes
	
	oDlgR := MSDialog():New( 105,351,522,1046,"Retirada de Volumes - Pedido: "+ cPedVol +" - Mesa: "+ _cEndMesa,,,.F.,,,,,,.T.,,,.T. )
	oSay1 := TSay():New( 180,176,{||"Digita Qtd.?"},oDlgR,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSayQ := TSay():New( 180,216,{||Iif( lAltQtd, "Sim", "Não" )},oDlgR,,oFontb,.F.,.F.,.F.,.T.,Iif( lAltQtd, CLR_GREEN, CLR_RED ),CLR_WHITE,041,008)

	aColVol := {"Volume","Produto","Qtd.Original","Retirado","Qtd.Atual","Status"}
	oBrwVol := TCBrowse():New(080,004,336,072,,aColVol,,oDlgR,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	BrwItVol( .F., 2 )
	
	aColItm := {" ","Produto","Retirar","Retirado","Falta","Qtd.Ant.PV","Qtd.Atu.PV","Conferido"}
	oBrwItm := TCBrowse():New(000,004,336,072,,aColItm,,oDlgR,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	BrwItVol( .F., 1 )
	
	oGet1 := TGet():New( 172,008,{|u| Iif(PCount()>0,cVolume:=u,cVolume)},oDlgR,064,014,'@!',{|| Iif( !Empty(cVolume), VlVolRet(cVolume)                , .T.) },CLR_WHITE,CLR_BLACK,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cVolume",,,,.F.,.F.,,"Volume:" ,1,,CLR_BLUE)
	oGet2 := TGet():New( 172,088,{|u| Iif(PCount()>0,cCodPrd:=u,cCodPrd)},oDlgR,080,014,'@!',{|| Iif( !Empty(cCodPrd), VlPrdRet(cCodPrd,cVolume,@_cProd), .T.) },CLR_WHITE,CLR_BLACK,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cCodPrd",,,,.F.,.F.,,"Produto:",1,,CLR_BLUE)

	oSBtn1 := SButton():New( 182,308,1,{|| nOpc := 1, oDlgR:End(), _lImpEt := MsgYesNo("Reimprime etiquetas de volume agora?") },oDlgR,,"", )
	oSBtn2 := SButton():New( 182,276,2,{|| nOpc := 0, Iif( MsgYesNo("Todos os movimentos serão perdidos! Deseja sair?"), oDlgR:End(), Nil ) },oDlgR,,"", )

	oTMsgBar := TMsgBar():New(oDlgR, " [F4] Digita Quantidade",,,,,CLR_GRAY,,oFont2)
	oGet1:SetFocus()
	oDlgR:lEscClose := .F.
	SetKey( VK_F4, {|| DgtQuant() } )

	oDlgR:Activate(,,,.T.)

	SetKey( VK_F4, Nil )
	
	If nOpc == 1
		// Atualiza a tabela de retiradas de volumes (ZAR)
		For _nG := 1 To Len( aRegItm )
			If aRegItm[ _nG, BRW4FOI ] > 0
				ZAR->( dbGoTo( aRegItm[ _nG, BRW4ZAR ] ) )
				ZAR->( RecLock("ZAR",.F.) )
					ZAR->ZAR_QTDRET -= aRegItm[ _nG, BRW4FOI ]
				ZAR->( MsUnLock() )
			EndIf
		Next
		
		// Atualiza as tabelas de volumes
		For _nG := 1 To Len( aRegVol )
			
			If aRegVol[ _nG, BRW5RET ] > 0
			
				_lExclu := .F.
				
				//Tabela ZCV
				ZCV->( dbGoTo( aRegVol[ _nG, BRW5ZCV ] ) )
				ZCV->( RecLock("ZCV",.F.) )
					If ( ZCV->ZCV_QUANT - aRegVol[ _nG, BRW5RET ] ) == 0
						// Guardo o código do volume deste item para verificações
						cVolChk := ZCV->ZCV_CODVOL
						// Elimino o item do volume
						ZCV->( dbDelete() )
						// Verifica se o item do volume era único e exclui o volume
						_lExclu := ChkDelVl( cVolChk )
					Else
						ZCV->ZCV_QUANT -= aRegVol[ _nG, BRW5RET ]
					EndIf
				ZCV->( MsUnLock() )

				// Deve imprimir os volumes, desconsiderando o volume que tenha sido excluído
				If _lImpEt .And. !_lExclu .And. aScan( aRegImp, {|o| o == ZCV->ZCV_CODVOL } ) == 0
					aAdd( aRegImp, ZCV->ZCV_CODVOL )
				EndIf
			
			EndIf

		Next

		// Faz a impressão única dos volumes
		If _lImpEt
			For _nG := 1 To Len( aRegImp )
				U_WMSR410A( aRegImp[ _nG ], Nil, Nil )
			Next
		EndIf
		
        // Faz a liberação de WMS dos itens que tiveram alteração ou dos novos itens, após estorno do pedido
		WmsC9Lib( cPedVol, .F. )
		
	EndIf

Return


// Atualiza os browsers da tela de retirada de volumes
Static Function BrwItVol( lRefresh, nBrw )

	Local oOk := LoadBitMap( GetResources(), "BR_VERDE" )
	Local oNo := LoadBitMap( GetResources(), "BR_VERMELHO" )
	Local oIn := LoadBitMap( GetResources(), "BR_AMARELO" )
	
	If nBrw == 1
		oBrwItm:SetArray( aRegItm )
	ElseIf nBrw == 2
		oBrwVol:SetArray( aRegVol )
	EndIf
	
	If nBrw == 1
	
		oBrwItm:bLine := { ||{	Iif( aRegItm[ oBrwItm:nAt, BRW4FAL ] == 0, oOk, Iif( aRegItm[ oBrwItm:nAt, BRW4FOI ] == 0, oNo, oIn ) ),;
								aRegItm[ oBrwItm:nAt, BRW4PRO ],;
								aRegItm[ oBrwItm:nAt, BRW4VAI ],;
								aRegItm[ oBrwItm:nAt, BRW4FOI ],;
								aRegItm[ oBrwItm:nAt, BRW4FAL ],;
								aRegItm[ oBrwItm:nAt, BRW4BQP ],;
								aRegItm[ oBrwItm:nAt, BRW4AQP ],;
								aRegItm[ oBrwItm:nAt, BRW4CNF ]}}
	
	ElseIf nBrw == 2
	
		oBrwVol:bLine := { ||{	aRegVol[ oBrwVol:nAt, BRW5VOL ],;
								aRegVol[ oBrwVol:nAt, BRW5PRO ],;
								aRegVol[ oBrwVol:nAt, BRW5QTO ],;
								aRegVol[ oBrwVol:nAt, BRW5RET ],;
								aRegVol[ oBrwVol:nAt, BRW5QTA ],;
								aRegVol[ oBrwVol:nAt, BRW5STS ]}}

	EndIf	

	If lRefresh
		If nBrw == 1
			oBrwItm:Refresh()
		ElseIf nBrw == 2
			oBrwVol:Refresh()
		EndIf
	EndIf	
	
Return


// Valida o volume lido
Static Function VlVolRet(cCodVol)

	Local _lRet := .T.
	Local _nPos := 0

	_nPos := aScan( aRegVol, {|o| AllTrim( o[BRW5VOL] ) == AllTrim(cCodVol) } )
	
	If _nPos == 0
		MsgAlert("Volume não tem produtos para serem retirados!")
		_lRet := .F.
	EndIf

Return( _lRet )


// Valida o volume lido e se estiver ok já atualiza as telas
Static Function VlPrdRet(cCodPrd,cCodVol,_cProd)

	Local _lRet    := .T.
	Local _nPos1   := 0
	Local _nPos2   := 0
	Local _nZ      := 0
	Local _nQtdRet := 1
	Local aProduto := {}

	aProduto := CBRetEtiEAN( cCodPrd )

	If Len(aProduto) > 0
		If Len(aProduto) > 1
			
			For _nZ := 1 To Len( aProduto )
				_nPos1 := aScan( aRegVol, {|o| AllTrim( o[BRW5PRO] ) == AllTrim( aProduto[ _nZ ] ) } )
				If _nPos1 > 0
					_cProd := aProduto[ _nZ ]
				Endif
			Next
			
		Else
			_cProd := aProduto[1]
		EndIf
	Else
		aProduto := CBRetEti(cCodPrd, '01')
		If Len(aProduto) > 0
			_cProd := aProduto[1]
		Else
			_cProd := Space(16)
		EndIf
	EndIf

	If Empty( cCodVol )
		MsgAlert("Volume não foi informado!")
		_lRet := .F.
	EndIf
	
	If _lRet .And. Empty( _cProd )
		MsgAlert("Não foi possível identificar o produto!")
		_lRet := .F.
	EndIf
	
	If _lRet
		_nPos1 := aScan( aRegVol, {|o| AllTrim( o[BRW5VOL] ) == AllTrim( cCodVol ) } )
		_nPos2 := aScan( aRegVol, {|o| AllTrim( o[BRW5VOL] ) == AllTrim( cCodVol ) .And. AllTrim( o[BRW5PRO] ) == AllTrim( _cProd  ) } )
	
		If _nPos1 == 0
			MsgAlert("Volume não tem produtos para serem retirados!")
			_lRet := .F.
		EndIf
	
		If _lRet .And. _nPos2 == 0
			MsgAlert("Produto não consta no volume selecionado!")
			_lRet := .F.
		EndIf
	EndIf
	
	If _lRet

		If lAltQtd 
			_nQtdRet := GetCB13(,,,.T.)
		Else
			_nQtdRet := 1
		Endif

		_nPos1 := aScan( aRegItm, {|o| AllTrim( o[BRW4PRO] ) == AllTrim( _cProd  ) .And. o[BRW4FAL] >= _nQtdRet } )

		If _nPos1 == 0
			MsgAlert("Produto não encontrado com quantidade a ser retirada!")
			_lRet := .F.
		EndIf

		If _lRet
			
			aRegItm[ _nPos1, BRW4FOI ] += _nQtdRet
			aRegItm[ _nPos1, BRW4FAL ] -= _nQtdRet
			
			aRegVol[ _nPos2, BRW5RET ] += _nQtdRet
			aRegVol[ _nPos2, BRW5QTA ] -= _nQtdRet
			
			BrwItVol( .T., 1 )
			BrwItVol( .T., 2 )

		EndIf
	
	EndIf

	oGet2:cText := Space( Len( _cProd ) )
	oGet2:Refresh()
	oGet2:SetFocus()
	
Return( _lRet )


// Faz a carga dos dados nos arrays de produtos e volumes para a tela de retirada de volumes
Static Function Carga( cNumPed )

	Local cQuery    := ""
	Local cAliasQry := ""
	Local cProd     := "'"
	Local aTemp     := {}

	cQuery := " SELECT ZAR_PRODUT, ZAR_QTDRET, ZAR_QTDANT, ZAR_QTDATU, ZAR_CNFANT, R_E_C_N_O_ "
	cQuery += " FROM "+ RetSqlName('ZAR')
	cQuery += " WHERE ZAR_FILIAL = '"+ xFilial("ZAR") +"'"
	cQuery += "   AND ZAR_PEDIDO = '"+ cNumPed +"'"
	cQuery += "   AND ZAR_QTDRET > 0 "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY ZAR_QTDRET DESC "

	cQuery := ChangeQuery( cQuery )

	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),(cAliasQry := GetNextAlias()),.F.,.T.)

	While (cAliasQry)->( !Eof() )
		aAdd( aTemp, { (cAliasQry)->ZAR_PRODUT, (cAliasQry)->ZAR_QTDRET, 0, (cAliasQry)->ZAR_QTDRET, (cAliasQry)->ZAR_QTDANT, (cAliasQry)->ZAR_QTDATU, (cAliasQry)->ZAR_CNFANT, (cAliasQry)->R_E_C_N_O_, .F. } )
		cProd += (cAliasQry)->ZAR_PRODUT +"','"
		(cAliasQry)->( dbSkip() )
	End
	cProd := Left( cProd, Len( cProd ) - 2 )
	(cAliasQry)->( dbCloseArea() )

	If Empty( aTemp )
		aAdd( aTemp, { " ", 0, 0, 0, 0, 0, 0, 0, .F. } )
	EndIf

	aRegItm := aTemp

	cQuery := " SELECT ZCU_CODVOL, ZCV_CODPRO, ZCU_STATUS, ZCV_QUANT, ZCV010.R_E_C_N_O_ ZCVREC, ZCU010.R_E_C_N_O_ ZCUREC "
	cQuery += " FROM "+ RetSqlName("ZCU") +", "+ RetSqlName("ZCV") 
	cQuery += " WHERE ZCU_FILIAL = '"+ xFilial("ZCU") +"' "
	cQuery += "   AND ZCU_PEDIDO = '"+ cNumPed +"'
	cQuery += "   AND ZCV_CODPRO IN ("+ cProd +")"
	cQuery += "   AND ZCU_FILIAL = ZCV_FILIAL "
	cQuery += "   AND ZCU_CODVOL = ZCV_CODVOL "
	cQuery += "   AND ZCU010.D_E_L_E_T_ = ' ' "
	cQuery += "   AND ZCV010.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )
	
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),(cAliasQry := GetNextAlias()),.F.,.T.)
	aTemp := {}

	While (cAliasQry)->( !Eof() )
		aAdd( aTemp, { (cAliasQry)->ZCU_CODVOL, (cAliasQry)->ZCV_CODPRO, (cAliasQry)->ZCV_QUANT, 0, (cAliasQry)->ZCV_QUANT, Iif( (cAliasQry)->ZCU_STATUS == "2", "Finalizado", "Em Montagem" ), (cAliasQry)->ZCUREC, (cAliasQry)->ZCVREC } )
		(cAliasQry)->( dbSkip() )
	End
	(cAliasQry)->( dbCloseArea() )
    
	If Empty( aTemp )
		aAdd( aTemp, { " ", " ", 0, 0, 0, " ", 0, 0 } )
	EndIf

	aRegVol := aTemp

Return

// Verifica se um produto possui registro na tabela ZCT para um pedido específico
Static Function CheckZCT( cProdut, cCarga, cPedido )

	Local _lRet  := .T.
	Local _aArea := GetArea()
	
	dbSelectArea("ZCT")
	dbSetOrder(1)
	dbSeek( xFilial("ZCT") + cCarga + cPedido + cProdut )
	
	While !ZCT->( Eof() ) .And. xFilial("ZCT") + cCarga + cPedido + cProdut == ZCT->ZCT_FILIAL + ZCT->ZCT_CARGA + ZCT->ZCT_PEDIDO + ZCT->ZCT_CODPRO
		
		If ZCT->ZCT_STATUS != '3' .And. ZCT->ZCT_QTSEPA != ZCT->ZCT_QTEMBA
			_lRet := .F.
			Exit
		EndIf
		
		dbSkip()
	End 
	
	RestArea( _aArea )
	
Return( _lRet )

// Verifica se após excluir item do volume ainda existem itens, caso contrário exclui o volume
Static Function ChkDelVl( cCodVol )

	Local _lRet   := .F.
	Local _nQtReg := 0
	Local _cQuery := ""
	Local _cAlias := ""
	Local _aArea  := GetArea()
	
	_cQuery := "SELECT COUNT(*) QTDREG "
	_cQuery += " FROM "+ RetSqlName("ZCV")
	_cQuery += " WHERE ZCV_FILIAL = '"+ xFilial("ZCV") +"' "
	_cQuery += "   AND ZCV_CODVOL = '"+ cCodVol        +"' "
	_cQuery += "   AND ZCV_QUANT  > 0 "
	_cQuery += "   AND D_E_L_E_T_ = ' '"

	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	_nQtReg := (_cAlias)->QTDREG
	(_cAlias)->( dbCloseArea() )
	
	If _nQtReg == 0
		
		dbSelectArea("ZCU")
		dbSetOrder(1)
		If dbSeek( xFilial("ZCU") + cCodVol )
			
			ZCU->( RecLock("ZCU", .F.) )
				ZCU->( dbDelete() )
			ZCU->( MsUnLock() )
			
			_lRet := .T.
			
			// Aqui também elimino a previsão de embarque - D00
			_cQuery := " UPDATE "+ RetSqlName("D00")
			_cQuery += " SET D_E_L_E_T_ = '*' "
			_cQuery += " WHERE D00_FILIAL = '"+ xFilial("D00") +"' "
			_cQuery += "   AND D00_CODVOL = '"+ cCodVol        +"' "
			_cQuery += "   AND D_E_L_E_T_ = ' '"
		
			TcSqlExec( _cQuery )
			TcSqlExec( 'COMMIT' )
			
		EndIf
	
	EndIf

	RestArea( _aArea )

Return( _lRet )

// Faz a liberação de WMS dos itens que tiveram alteração ou dos novos itens, após estorno do pedido
Static Function WmsC9Lib( cNumSC5, lChkRet )

	Local cQuery := ""
	Local lLib   := .F.
	
	cQuery := " UPDATE "+RetSqlName("SC9")+" SC9 "
	cQuery += " SET C9_BLWMS = '05'"
	cQuery += " WHERE C9_FILIAL  = '"+xFilial("SC9")+"'"
	cQuery += "   AND C9_PEDIDO  = '"+ cNumSC5 +"'"
	cQuery += "   AND C9_BLWMS   = '01'"
	cQuery += "   AND C9_BLEST   = '  '"
	cQuery += "   AND C9_BLCRED  = '  '"
	cQuery += "   AND D_E_L_E_T_ = ' ' "

	If lChkRet // Verificar se existe retirada de volumes
		
		ZAR->( dbSetOrder(1) )
		If ZAR->( dbSeek( xFilial("ZAR") + cNumSC5 ) )
			If ZAR->ZAR_QTDRET == 0
				lLib := .T.
			EndIf
		Else
			lLib := .T.
		EndIf
		
	Else
		lLib := .T.
	EndIf
	
	If lLib
		TcSqlExec( cQuery )
		TcSqlExec( 'COMMIT' )
	EndIf
	
Return

// Seleciona o pedido para conferência ou retirada, realizando algumas validações
Static Function ChkPedCnf()

	If !Empty(_aCols) .And. !( Len(_aCols)==1 .And. Empty(_aCols[1,BRW2PED]) )
		
		If _aCols[oBrwPed:nAt,BRW2LEG]=="P"
			LerConf( oBrwPed:nAt )
		Else
			If aScan( _aCols, { |b| b[BRW2LEG] == "P" .And. b[BRW2PED] == _aCols[ oBrwPed:nAt, BRW2PED ] } ) == 0
				LerRetVol( _aCols[oBrwPed:nAt,BRW2PED] )
			Else
				MsgAlert("Existe conferência pendente para este pedido, faça primeiro a conferência!")
			EndIf
		EndIf
		
		MsAguarde( {|| Atualista() }, "Atualizando..." )

	EndIf

Return

// Grava o empenho do SDB na DOCA para faturamento
Static Function WmsSBFEmp( nQtdEmp )

	Local _aArea := GetArea()

	dbSelectArea("SBF")
	dbSetOrder(1)
	
	If dbSeek( xFilial("SBF") + SDB->DB_LOCAL + PadR( "DOCA", Len( SDB->DB_LOCALIZ ) ) + SDB->DB_PRODUTO )
		RecLock("SBF",.F.)
			SBF->BF_EMPENHO += nQtdEmp
		MsUnLock()
	EndIf
	
	RestArea( _aArea )
	
Return

// Função que verifica se pedido tem pendências de separação para liberar ou não a retirada de volumes se for o caso
Static Function IsPvOkRet( cNumPv )

	Local _lRet     := .T.
	Local _aArea    := GetArea()
	Local cQuery    := ""
	Local cAliasNew := ""

	cAliasNew := GetNextAlias()

	cQuery := " SELECT DB_PRODUTO "
	cQuery += " FROM "+ RetSqlName("SDB")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += "   AND DB_ESTORNO = ' ' "
	cQuery += "   AND DB_SERVIC  = '001' "
	cQuery += "   AND DB_ATIVID  = '015' "
	cQuery += "   AND DB_ORIGEM  = 'SC9' "
	cQuery += "   AND DB_FILIAL  = '"+ xFilial("SDB") +"' "
	cQuery += "   AND DB_DOC     = '"+ cNumPv +"' "
	cQuery += "   AND (DB_STATUS = '"+ cStatAExe +"' OR DB_STATUS = '"+ cStatInte +"' OR DB_STATUS = '"+ cStatProb +"') "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	
	If !(cAliasNew)->( Eof() )
		_lRet := .F.
	End
	(cAliasNew)->( dbCloseArea() )
	
	RestArea( _aArea )
	
Return( _lRet )

// Preenche tabela de Volumes ZCS e ZCT
Static Function ImdVolEmb(cCarga,cPedido,cProduto,cLote,cSubLote,cIdDCF,nQtdSepa)

	Local lRet := .T.
	Local lGravaZCS := .F.
	
	Default cProduto  := ''
	Default cPedido   := Space( Len( ZCS->ZCS_PEDIDO ) )
	Default cCarga    := Space( Len( ZCS->ZCS_CARGA ) )
	Default cIdDCF    := ''
	Default nQtdSepa  := 0
	Default cLote     := ''
	Default cSubLote  := ''
	
	cCarga  := PadR( cCarga, Len( ZCS->ZCS_CARGA ) )
	cPedido := PadR( cPedido, Len( ZCS->ZCS_PEDIDO ) )
	
	ZCS->( DbSetOrder(1) ) //ZCS_FILIAL+ZCS_CARGA+ZCS_PEDIDO
	If lRet
		Begin Transaction
		If !ZCS->( MsSeek( xFilial("ZCS") + cCarga + cPedido ) )
			lGravaZCS := .T.
		Else
			Reclock('ZCS',.F.)
			ZCS->ZCS_QTSEPA += nQtdSepa
			If ZCS->ZCS_STATUS == "3"
				ZCS->ZCS_STATUS := "2"
			EndIf
			ZCS->(MsUnLock())
			lGravaZCS := .F.
		EndIf
		If lGravaZCS
			RecLock('ZCS',.T.)
			ZCS->ZCS_FILIAL   := xFilial("ZCS")
			ZCS->ZCS_CARGA    := cCarga
			ZCS->ZCS_PEDIDO   := cPedido
			ZCS->ZCS_STATUS   := "1"
			ZCS->ZCS_QTSEPA   := nQtdSepa
			ZCS->ZCS_QTEMBA   := 0
			ZCS->ZCS_DATA     := dDataBase
			ZCS->ZCS_HORA     := Time()
			ZCS->(MsUnLock())
		EndIf
	
		DbSelectArea("ZCT")
		ZCT->(DbSetOrder(1)) //ZCT_FILIAL+ZCT_CARGA+ZCT_PEDIDO+ZCT_CODPRO+ZCT_LOTE+ZCT_SUBLOT+ZCT_IDDCF
		If !ZCT->(MsSeek(xFilial("ZCT")+cCarga+cPedido+cProduto+cLote+cSubLote+cIdDCF))
			Reclock('ZCT',.T.)
			ZCT->ZCT_Filial := xFilial("ZCT")
			ZCT->ZCT_CARGA  := cCarga
			ZCT->ZCT_IDDCF  := cIdDCF
			ZCT->ZCT_PEDIDO := cPedido
			ZCT->ZCT_STATUS   := "1"
			ZCT->ZCT_CODPRO   := cProduto
			If !Empty(cLote) .And. ZCT->(FieldPos("ZCT_LOTE")) > 0
				ZCT->ZCT_LOTE     := cLote
				ZCT->ZCT_SUBLOT   := cSubLote
			EndIf
			ZCT->ZCT_QTSEPA   := nQtdSepa
			ZCT->ZCT_QTEMBA   := 0
			If ZCT->(FieldPos("ZCT_DATA")) > 0
				ZCT->ZCT_DATA := ZCS->ZCS_DATA
				ZCT->ZCT_HORA := ZCS->ZCS_HORA
			EndIf
			ZCT->(MsUnLock())
		Else
			Reclock('ZCT',.F.)
			ZCT->ZCT_QTSEPA   += nQtdSepa
			If ZCT->ZCT_STATUS == "3"
				ZCT->ZCT_STATUS := "2"
			EndIf
			ZCT->(MsUnLock())
		EndIf
		End Transaction
	EndIf

Return ( lRet )

/*/{Protheus.doc} zPutSX1
Função para criar Grupo de Perguntas
@author Atilio
@since 09/06/2017
@version 1.0
@type function
    @param cGrupo,    characters, Grupo de Perguntas       (ex.: X_TESTE)
    @param cOrdem,    characters, Ordem da Pergunta        (ex.: 01, 02, 03, ...)
    @param cTexto,    characters, Texto da Pergunta        (ex.: Produto De, Produto Até, Data De, ...)
    @param cMVPar,    characters, MV_PAR?? da Pergunta     (ex.: MV_PAR01, MV_PAR02, MV_PAR03, ...)
    @param cVariavel, characters, Variável da Pergunta     (ex.: MV_CH0, MV_CH1, MV_CH2, ...)
    @param cTipoCamp, characters, Tipo do Campo            (C = Caracter, N = Numérico, D = Data)
    @param nTamanho,  numeric,    Tamanho da Pergunta      (Máximo de 60)
    @param nDecimal,  numeric,    Tamanho de Decimais      (Máximo de 9)
    @param cTipoPar,  characters, Tipo do Parâmetro        (G = Get, C = Combo, F = Escolha de Arquivos, K = Check Box)
    @param cValid,    characters, Validação da Pergunta    (ex.: Positivo(), u_SuaFuncao(), ...)
    @param cF3,       characters, Consulta F3 da Pergunta  (ex.: SB1, SA1, ...)
    @param cPicture,  characters, Máscara do Parâmetro     (ex.: @!, @E 999.99, ...)
    @param cDef01,    characters, Primeira opção do combo
    @param cDef02,    characters, Segunda opção do combo
    @param cDef03,    characters, Terceira opção do combo
    @param cDef04,    characters, Quarta opção do combo
    @param cDef05,    characters, Quinta opção do combo
    @param cHelp,     characters, Texto de Help do parâmetro
    @obs Função foi criada, pois a partir de algumas versões do Protheus 12, a função padrão PutSX1 não funciona (por medidas de segurança)
    @example Abaixo um exemplo de como criar um grupo de perguntas
     
    cPerg    := "X_TST"
     
    cValid   := ""
    cF3      := ""
    cPicture := ""
    cDef01   := ""
    cDef02   := ""
    cDef03   := ""
    cDef04   := ""
    cDef05   := ""
     
    zPutSX1(cPerg, "01", "Produto De?",       "MV_PAR01", "MV_CH0", "C", TamSX3('B1_COD')[01], 0, "G", cValid,       "SB1", cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o produto inicial")
    zPutSX1(cPerg, "02", "Produto Até?",      "MV_PAR02", "MV_CH1", "C", TamSX3('B1_COD')[01], 0, "G", cValid,       "SB1", cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o produto final")
    zPutSX1(cPerg, "03", "A partir da Data?", "MV_PAR03", "MV_CH2", "D", 08,                   0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a data inicial a ser considerada")
    zPutSX1(cPerg, "04", "Média maior que?",  "MV_PAR04", "MV_CH3", "N", 09,                   2, "G", "Positivo()", cF3,   "@E 999,999.99", cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a média de atraso que será considerada")
    zPutSX1(cPerg, "05", "Tipo de Saldos?",   "MV_PAR05", "MV_CH4", "N", 01,                   0, "C", cValid,       cF3,   cPicture,        "Todos", "Maior que 0", "Menor que 0", "Zerados", cDef05, "Informe o tipo de saldo a ser considerado")
    zPutSX1(cPerg, "06", "Tipos de Produto?", "MV_PAR06", "MV_CH5", "C", 60,                   0, "K", cValid,       cF3,   cPicture,        "PA",    "PI",          "MP",          cDef04,    cDef05, "Informe os tipos de produto que serão considerados")
    zPutSX1(cPerg, "07", "Caminho de Log?",   "MV_PAR07", "MV_CH6", "C", 60,                   0, "F", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o caminho para geração do log")
/*/
 
Static Function zPutSX1(cGrupo, cOrdem, cTexto, cMVPar, cVariavel, cTipoCamp, nTamanho, nDecimal, cTipoPar, cValid, cF3, cPicture, cDef01, cDef02, cDef03, cDef04, cDef05, cHelp)

    Local aArea       := GetArea()
    Local cChaveHelp  := ""
    Local nPreSel     := 0
    Default cGrupo    := Space(10)
    Default cOrdem    := Space(02)
    Default cTexto    := Space(30)
    Default cMVPar    := Space(15)
    Default cVariavel := Space(6)
    Default cTipoCamp := Space(1)
    Default nTamanho  := 0
    Default nDecimal  := 0
    Default cTipoPar  := "G"
    Default cValid    := Space(60)
    Default cF3       := Space(6)
    Default cPicture  := Space(40)
    Default cDef01    := Space(15)
    Default cDef02    := Space(15)
    Default cDef03    := Space(15)
    Default cDef04    := Space(15)
    Default cDef05    := Space(15)
    Default cHelp     := ""
     
    //Se tiver Grupo, Ordem, Texto, Parâmetro, Variável, Tipo e Tamanho, continua para a criação do parâmetro
    If !Empty(cGrupo) .And. !Empty(cOrdem) .And. !Empty(cTexto) .And. !Empty(cMVPar) .And. !Empty(cVariavel) .And. !Empty(cTipoCamp) .And. nTamanho != 0
         
        //Definição de variáveis
        cGrupo     := PadR(cGrupo, Len(SX1->X1_GRUPO), " ")           //Adiciona espaços a direita para utilização no DbSeek
        cChaveHelp := "P." + AllTrim(cGrupo) + AllTrim(cOrdem) + "."  //Define o nome da pergunta
        cMVPar     := Upper(cMVPar)                                   //Deixa o MV_PAR tudo em maiúsculo
        nPreSel    := Iif(cTipoPar == "C", 1, 0)                      //Se for Combo, o pré-selecionado será o Primeiro
        cDef01     := Iif(cTipoPar == "F", "56", cDef01)              //Se for File, muda a definição para ser tanto Servidor quanto Local
        nTamanho   := Iif(nTamanho > 60, 60, nTamanho)                //Se o tamanho for maior que 60, volta para 60 - Limitação do Protheus
        nDecimal   := Iif(nDecimal > 9,  9,  nDecimal)                //Se o decimal for maior que 9, volta para 9
        nDecimal   := Iif(cTipoPar == "N", nDecimal, 0)               //Se não for parâmetro do tipo numérico, será 0 o Decimal
        cTipoCamp  := Upper(cTipoCamp)                                //Deixa o tipo do Campo em maiúsculo
        cTipoCamp  := Iif(! cTipoCamp $ 'C;D;N;', 'C', cTipoCamp)     //Se o tipo do Campo não estiver entre Caracter / Data / Numérico, será Caracter
        cTipoPar   := Upper(cTipoPar)                                 //Deixa o tipo do Parâmetro em maiúsculo
        cTipoPar   := Iif(Empty(cTipoPar), 'G', cTipoPar)             //Se o tipo do Parâmetro estiver em branco, será um Get
        nTamanho   := Iif(cTipoPar == "C", 1, nTamanho)               //Se for Combo, o tamanho será 1
     
        DbSelectArea('SX1')
        SX1->(DbSetOrder(1)) // Grupo + Ordem
     
        //Se não conseguir posicionar, a pergunta será criada
        If ! SX1->(DbSeek(cGrupo + cOrdem))
            RecLock('SX1', .T.)
                X1_GRUPO   := cGrupo
                X1_ORDEM   := cOrdem
                X1_PERGUNT := cTexto
                X1_PERSPA  := cTexto
                X1_PERENG  := cTexto
                X1_VAR01   := cMVPar
                X1_VARIAVL := cVariavel
                X1_TIPO    := cTipoCamp
                X1_TAMANHO := nTamanho
                X1_DECIMAL := nDecimal
                X1_GSC     := cTipoPar
                X1_VALID   := cValid
                X1_F3      := cF3
                X1_PICTURE := cPicture
                X1_DEF01   := cDef01
                X1_DEFSPA1 := cDef01
                X1_DEFENG1 := cDef01
                X1_DEF02   := cDef02
                X1_DEFSPA2 := cDef02
                X1_DEFENG2 := cDef02
                X1_DEF03   := cDef03
                X1_DEFSPA3 := cDef03
                X1_DEFENG3 := cDef03
                X1_DEF04   := cDef04
                X1_DEFSPA4 := cDef04
                X1_DEFENG4 := cDef04
                X1_DEF05   := cDef05
                X1_DEFSPA5 := cDef05
                X1_DEFENG5 := cDef05
                X1_PRESEL  := nPreSel
                 
                //Se tiver Help da Pergunta
                If !Empty(cHelp)
                    X1_HELP    := ""
                    fPutHelp(cChaveHelp, cHelp)
                EndIf
            SX1->(MsUnlock())
        EndIf
    EndIf
     
    RestArea(aArea)
Return
 
/*---------------------------------------------------*
 | Função: fPutHelp                                  |
 | Desc:   Função que insere o Help do Parametro     |
 *---------------------------------------------------*/
Static Function fPutHelp(cKey, cHelp, lUpdate)

    Local cFilePor  := "SIGAHLP.HLP"
    Local cFileEng  := "SIGAHLE.HLE"
    Local cFileSpa  := "SIGAHLS.HLS"
    Local nRet      := 0
    Default cKey    := ""
    Default cHelp   := ""
    Default lUpdate := .F.
     
    //Se a Chave ou o Help estiverem em branco
    If Empty(cKey) .Or. Empty(cHelp)
        Return
    EndIf
     
    //**************************** Português
    nRet := SPF_SEEK(cFilePor, cKey, 1)
     
    //Se não encontrar, será inclusão
    If nRet < 0
        SPF_INSERT(cFilePor, cKey, , , cHelp)
     
    //Senão, será atualização
    Else
        If lUpdate
            SPF_UPDATE(cFilePor, nRet, cKey, , , cHelp)
        EndIf
    EndIf

    //**************************** Inglês
    nRet := SPF_SEEK(cFileEng, cKey, 1)
     
    //Se não encontrar, será inclusão
    If nRet < 0
        SPF_INSERT(cFileEng, cKey, , , cHelp)
     
    //Senão, será atualização
    Else
        If lUpdate
            SPF_UPDATE(cFileEng, nRet, cKey, , , cHelp)
        EndIf
    EndIf

    //**************************** Espanhol
    nRet := SPF_SEEK(cFileSpa, cKey, 1)
     
    //Se não encontrar, será inclusão
    If nRet < 0
        SPF_INSERT(cFileSpa, cKey, , , cHelp)
     
    //Senão, será atualização
    Else
        If lUpdate
            SPF_UPDATE(cFileSpa, nRet, cKey, , , cHelp)
        EndIf
    EndIf

Return