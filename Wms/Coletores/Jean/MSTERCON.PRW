#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"

/*
Jean Rehermann - Solutio IT - 09/01/2018
Apresenta o browse do arquivo mestre de contagens e as opções disponíveis para análise
das contagens realizadas.
*/

User Function MSTERCON()

	Local aCores  := {}
	Local aCorAux := {}

	Private aLegenda  := {}
	Private cCadastro := "Mestre de Contagens"
	Private cString   := "ZAP"

	aCorAux := {{ "ZAP->ZAP_STATUS=='I'", "ENABLE"    , "Não iniciada" },;
				{ "ZAP->ZAP_STATUS=='X'", "BR_AMARELO", "Em Contagem " },;
				{ "ZAP->ZAP_STATUS=='*'", "DISABLE"   , "Encerrada   " } }

	For _nCor := 1 To Len( aCorAux )
		aAdd( aCores  , { aCorAux[ _nCor, 1 ], aCorAux[ _nCor, 2 ] } )
		aAdd( aLegenda, { aCorAux[ _nCor, 2 ], aCorAux[ _nCor, 3 ] } )
	Next ni

	Private aRotina := {{ "Pesquisar"    , "AxPesqui"  , 0, 1, 0, Nil },;
						{ "Visualizar"   , "AxVisual"  , 0, 2, 0, Nil },;
						{ "Incluir"      , "AxInclui"  , 0, 3, 0, Nil },;
						{ "Alterar"      , "U_AltCon"  , 0, 4, 0, Nil },;
						{ "Exportar"     , "U_ExpCon"  , 0, 2, 0, Nil },;
						{ "Nova Contagem", "U_NewCon"  , 0, 4, 0, Nil },;
						{ "Gerenciar"    , "U_GerCon"  , 0, 4, 0, Nil },;
						{ "Legenda"      , "U_LegCon"  , 0, 2, 0, Nil },;
						{ "Excluir"      , "U_DelCon"  , 0, 5, 0, .F. } }

	dbSelectArea(cString)
	dbSetOrder(1)
	mBrowse( 6, 1, 22, 75, cString,,,,,, aCores,,,,,.T. )

Return

//------------------------------
// Função de exibição da legenda
//------------------------------
User Function LegCon()

	BrwLegenda( cCadastro, "Legenda", aLegenda )

Return(.T.)

//------------------------------
// Função de exibição da legenda
//------------------------------
User Function LegGer()

	BrwLegenda( cCadastro, "Legenda", aLegGer )

Return(.T.)

//--------------------------------
// Função de alteraçao da contagem
//--------------------------------
User Function AltCon(cAlias,nReg,nOpcx)

	dbselectarea("ZAQ")
	dbselectarea("ZAP")
	If ZAP->ZAP_STATUS = "X"
		MsgAlert("Já existe inventário em andamento!")
	ElseIf ZAP->ZAP_STATUS = "*"
		MsgAlert("Este inventário já foi encerrado!")
	Else
		AxAltera(cAlias,nReg,nOpcx)
	EndIf

Return(.T.)

//------------------------------------------
// Função de exclusão do mestre de contagens
//------------------------------------------
User Function DelCon(cAlias,nReg,nOpcx)

	If ZAP->ZAP_STATUS = "X"
		MsgAlert("Já existe inventário em andamento!")
	ElseIf ZAP->ZAP_STATUS = "*"
		MsgAlert("Este inventário já foi encerrado!")
	Else
		AxDeleta(cAlias,nReg,nOpcx)
	EndIf

Return(.T.)

//---------------------------------
// Função de exportação da contagem
//---------------------------------
User Function ExpCon()

    Local _cDir := ""
    Local _cAba := "Planilha Geral"
    Local _cTab := "CONTAGEM GERAL "+ ZAP->ZAP_MESTRE
    Local _cArq := "Contagem_"+ ZAP->ZAP_MESTRE
	Local _nCont := Val( ZAP->ZAP_CONTAG )
	Local _aTabs := GetItExp( ZAP->ZAP_MESTRE )
	
	If Len( _aTabs ) == 0
		MsgAlert("Não foram encontradas contagens para este inventário!")
		Return
	EndIf
	
	_cDir := cGetFile( 'Pastas|*.*' , 'Salvar em...', 1, "C:\TEMP\", .T., GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY )
    
	If File( _cDir + _cArq + ".xml" )
		_cArq += "_"+ StrTran( Time(), ":", "" )
	EndIf
	
	oFWMsExcel := FWMSExcel():New()
	oFWMsExcel:AddworkSheet( _cAba )
	oFWMsExcel:AddTable( _cAba, _cTab )

	oFWMsExcel:AddColumn( _cAba, _cTab,"Código"       ,1,1,.F.) 
	oFWMsExcel:AddColumn( _cAba, _cTab,"Descrição"    ,1,1,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"Grupo"        ,2,1,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"UM"           ,2,1,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"Rua"          ,2,1,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"Nível"        ,2,1,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"Arm.01"       ,3,2,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"Arm.02"       ,3,2,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"Endereço"     ,1,1,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"Saldo Total"  ,2,2,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"Cst.Uni.01"   ,2,3,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"Cst.Uni.02"   ,2,3,.F.)
	
	For _n := 1 To _nCont
		oFWMsExcel:AddColumn( _cAba, _cTab,"Qtd. "+ cValToChar( _n ) +"a Cont.",2,2,.F.)
		oFWMsExcel:AddColumn( _cAba, _cTab,"Análise"                           ,2,1,.F.)
    Next
    
	oFWMsExcel:AddColumn( _cAba, _cTab,"Divergência"  ,3,2,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"Custo"        ,3,3,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"Diverg. 01"   ,3,2,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"Diverg. 02"   ,3,2,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"Troca Ender." ,3,2,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"INV 01"       ,3,2,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"INV 02"       ,3,2,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"DR"           ,3,2,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"Saldo Final"  ,3,2,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"Valor Final"  ,3,3,.F.)
	oFWMsExcel:AddColumn( _cAba, _cTab,"Quant."       ,2,1,.F.)

	For _n := 1 To Len( _aTabs )
		oFWMsExcel:AddRow( _cAba, _cTab, _aTabs[ _n ] )
	Next

	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile( _cDir + _cArq + ".xml" )
	
	If MsgYesNo("Deseja abrir o arquivo agora?")
	
		If ! ApOleClient( 'MsExcel' )
			MsgAlert( 'MsExcel nao instalado')
		Else
			oExcel := MsExcel():New()
			oExcel:WorkBooks:Open( _cDir + _cArq + ".xml" )
			oExcel:SetVisible(.T.)
			oExcel:Destroy()
		EndIf

	EndIf

Return

//-----------------------------------
// Função de criação de nova contagem
//-----------------------------------
User Function NewCon()

	Local aColuna   := {"  ","Código","Nome"}
	Local aRecHum   := {}
	Local nOpc      := 0
	Local nQtdRecH  := 0
	Local nQtdEnd   := 0
	Local nTotEnd   := 0
	Local cAliasIt  := ""
	Local lTodos    := .T.
	Local oDlg1, oSay1, oSay2, oBtn1, oBtn2, oMenu
	
	Private oBrw1, oGet1, oGet2
	Private cFunDes := Space( Len( SRJ->RJ_DESC ) )
	Private cFuncao := Space( Len( SRJ->RJ_FUNCAO ) )
	Private aRecurso := {{.F.,"",""}}
	
	If ZAP->ZAP_STATUS == "X" .And. GetQtSts("X") > 0
		MsgAlert("Inventário "+ PadL( ZAP->ZAP_CONTAG, 3, "0" ) +" em andamento!")
		Return
	ElseIf ZAP->ZAP_STATUS == "*"
		MsgAlert("Inventário já finalizado! Crie um novo mestre de inventário!")
		Return
	ElseIf dDataBase < ZAP->ZAP_DTINI .Or. dDataBase > ZAP->ZAP_DTFIM
		MsgAlert("Inventário fora do período!")
		Return
	EndIf
	
	Menu oMenu PopUp
		MenuItem "Marca Todos     "	Action Eval( { || lTodos := .T. , aEval( aRecurso, {|e| e[1] := lTodos } ), oBrw1:Refresh() } )
		MenuItem "Desmarca Todos  "	Action Eval( { || lTodos := .F. , aEval( aRecurso, {|e| e[1] := lTodos } ), oBrw1:Refresh() } )
		MenuItem "Inverter Seleção"	Action Eval( { || lTodos := Nil , aEval( aRecurso, {|e| e[1] := !e[1] } ), oBrw1:Refresh() } )
	EndMenu

	oDlg1 := MSDialog():New( 139,430,448,761,"Recursos Humanos",,,.F.,,,,,,.T.,,,.T. )
	oSay1 := TSay():New( 004,004,{||"Selecione a função do recurso humano "},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,148,008)
	oSay2 := TSay():New( 032,004,{||"Selecione os recursos humanos para a contagem"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,148,008)
	oGet1 := TGet():New( 016,004,{|u| If(Pcount()>0,cFuncao:=u,cFuncao)},oDlg1,030,008,'9999',{|| MsAguarde( {|| GetRecH() }, "Consultando cadastro..." ) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SRJ","cFuncao")
	oGet2 := TGet():New( 016,044,{|u| If(Pcount()>0,cFunDes:=u,cFunDes)},oDlg1,108,008,'@!'  ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cFunDes")
	oBtn1 := SButton():New( 140,130,1,{|| If( VldRecH(), ( nOpc:=1, oDlg1:End() ), nOpc:=0 ) },oDlg1,,"", )
	oBtn2 := SButton():New( 140,098,2,{|| nOpc:=0, oDlg1:End()},oDlg1,,"", )
	oBrw1 := TCBrowse():New(042,004,150,070,,aColuna,,oDlg1,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	AtuBrw(.F.)
	oBrw1:bLDblClick   := {|| aRecurso[ oBrw1:nAt, 1 ] := !aRecurso[ oBrw1:nAt, 1 ] }
	oBrw1:bHeaderClick := { |o,x,y| Iif( x == 1 , oMenu:Activate(x,y,oBrw1) , Nil ) }	
	oGet2:lCanGotFocus := .F.

	oDlg1:Activate(,,,.T.)

	If nOpc == 1
		// Executa a query 
		MsAguarde( {|| cAliasIt := RunQry() }, "Executando query..." )
		
		// Verifica a quantidade de recursos humanos selecionados para a contagem
		aEval( aRecurso, {|X| Iif( X[1], aAdd( aRecHum, X[2] ), Nil ) } )
		nQtdRecH := Len( aRecHum )
		
		// Quantidade de endereços por recurso humano selecionado
		MsAguarde( {|| nTotEnd := AddrCount( cAliasIt ) }, "Contando Endereços..." )

		(cAliasIt)->( dbGoTop() )
		nQtdEnd := Int( nTotEnd / nQtdRecH )
		
		// Distribuir os endereços para os recursos humanos
		MsAguarde( {|| AlocarRh( cAliasIt, nQtdEnd, aRecHum ) }, "Alocando recursos..." )

		(cAliasIt)->( dbCloseArea() )
	
		_nQtdX := GetQtSts("X")
		
		RecLock("ZAP", .F. )
			If _nQtdX > 0
				ZAP->ZAP_STATUS := "X"
				ZAP->ZAP_CONTAG := Soma1(ZAP->ZAP_CONTAG)
			Else
				ZAP->ZAP_STATUS := "*"
			EndIf
		ZAP->( MsUnLock() )

	EndIf

Return

//--------------------------------------
// Função de gerenciamento das contagens
//--------------------------------------
User Function GerCon()

	Local aCores  := {}
	Local aCorAux := {}
	Local aIndex  := {}
	Local cFiltro := "ZAQ_MESTRE == '"+ ZAP->ZAP_MESTRE +"'"

	Private aLegGer := {}
	Private bFiltraBrw := { || FilBrowse( "ZAQ" , @aIndex , @cFiltro ) } //Determina a Expressao do Filtro

	aCorAux := {{ "ZAQ->ZAQ_STATUS=='X'", "ENABLE"    , "Em Contagem " },;
				{ "ZAQ->ZAQ_STATUS=='N'", "BR_AZUL"   , "Não OK      " },;
				{ "ZAQ->ZAQ_STATUS=='D'", "BR_AMARELO", "Divergente  " },;
				{ "ZAQ->ZAQ_STATUS=='*'", "DISABLE"   , "OK          " } }

	For _nCor := 1 To Len( aCorAux )
		aAdd( aCores , { aCorAux[ _nCor, 1 ], aCorAux[ _nCor, 2 ] } )
		aAdd( aLegGer, { aCorAux[ _nCor, 2 ], aCorAux[ _nCor, 3 ] } )
	Next ni

	Private aRotina := {{ "Pesquisar"    , "AxPesqui"  , 0, 1, 0, Nil },;
						{ "Visualizar"   , "AxVisual"  , 0, 2, 0, Nil },;
						{ "Analisar"     , "U_AnaCon"  , 0, 4, 0, Nil },;
						{ "Legenda"      , "U_LegGer"  , 0, 2, 0, Nil } }

	dbSelectArea("ZAQ")
	dbSetOrder(1)
	
	Eval( bFiltraBrw )
	mBrowse( 6, 1, 22, 75, "ZAQ",,,,,, aCores )
	EndFilBrw( "ZAQ" , @aIndex ) //Finaliza o Filtro

Return

//---------------------------------------------------------
// Retorna a lista de recursos humanos da função solicitada
//---------------------------------------------------------
Static Function GetRecH()

	Local cQuery    := ""
	Local cNewAlias := ""

	If ExistCpo("SRJ",cFuncao,1)
	
		cQuery := "SELECT DCD_CODFUN, DCD_NOMFUN "
		cQuery += " FROM "+ RetSqlName("DCI") +" DCI, "+ RetSqlName("DCD") +" DCD "
		cQuery += " WHERE DCI_FILIAL = '"+ xFilial("DCI") +"' "
		cQuery += "   AND DCI_FUNCAO = '"+ cFuncao +"' "
		cQuery += "   AND DCI_FILIAL = DCD_FILIAL "
		cQuery += "   AND DCI_CODFUN = DCD_CODFUN "
		cQuery += "   AND DCD_STATUS <> '3' "
		cQuery += "   AND DCD.D_E_L_E_T_ = ' ' "
		cQuery += "   AND DCI.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY DCD_CODFUN"
		
		TCQuery cQuery New Alias ( cNewAlias := GetNextAlias() )
		
		aRecurso := {}
		
		While !(cNewAlias)->( Eof() )
			aAdd( aRecurso, { .F., (cNewAlias)->DCD_CODFUN, (cNewAlias)->DCD_NOMFUN } )
			(cNewAlias)->( dbSkip() )
		End
		(cNewAlias)->( dbCloseArea() )
		
		cFunDes := Posicione("SRJ",1,xFilial("SRJ")+cFuncao,"RJ_DESC")
	
		If Len( aRecurso ) == 0
			MsgAlert("Nenhum recurso humano com a função selecionada!")
			aRecurso := {{.F.,"",""}}
		Endif

		oGet2:Refresh()
		AtuBrw(.T.)
	Else
		aRecurso := {{.F.,"",""}}
		AtuBrw(.T.)
		cFunDes := Space( Len( SRJ->RJ_DESC ) )
		oGet2:Refresh()
		oGet1:SelectAll()
	EndIf

Return()

//------------------------------------------------
// Função que faz a atualização do bLine do browse
//------------------------------------------------
Static Function AtuBrw(lAtu)

	Local oOk := LoadBitMap( GetResources(), "LBOK" )
	Local oNo := LoadBitMap( GetResources(), "LBNO" )
	
	oBrw1:SetArray( aRecurso ) 

	oBrw1:bLine := { ||{ Iif( aRecurso[ oBrw1:nAt, 1 ], oOk, oNo ),;
							  aRecurso[ oBrw1:nAt, 2 ],;
							  aRecurso[ oBrw1:nAt, 3 ] } }
	If lAtu
		oBrw1:Refresh()
    EndIf
    
Return

//------------------------------------------------------------
// Função que verifica se algum recurso humano foi selecionado
//------------------------------------------------------------
Static Function VldRecH()

	Local _lRet := .F.
	Local _nX   := 1
	
	For _nX := 1 To Len( aRecurso )
		If aRecurso[ _nX, 1 ] .And. !Empty( aRecurso[ _nX, 2 ] )
			_lRet := .T.
			Exit
		EndIf
	Next
	
	If !_lRet
		MsgAlert("Nenhum recurso humano selecionado")
	Else
		_lRet := MsgYesNo("Deseja prosseguir com o(s) recurso(s) humano(s) selecionado(s)?")
	EndIf

Return( _lRet )

//-----------------------------------------------------------------
// Realiza a análise de contagens de determinado produto x endereço
//-----------------------------------------------------------------
User Function AnaCon()

	Local oDlg1
	Local aCpoEnch   := {}
	Local aPos       := {001,001,080,345}  //Vetor com coordenadas para criacao da enchoice no formato <top>, <left>, <bottom>, <right>
	Local cAliasE    := "ZAP"
	Local nCntFor    := 0
	Local nOpcE      := 2
	Local nRegE      := Nil
	Local aButtons   := {}

	Private bCampo   := {|nCPO| Field(nCPO)}
	Private VISUAL   := .T.
	Private oBrowse1
	Private aConta   := {}

	If ZAP->ZAP_STATUS <> "*"
		aAdd( aButtons, { "S4WB004N", { || ForcaFim() }, "&Encerra", "Encerrar" } )
		aAdd( aButtons, { "S4WB004N", { || ForcaDiv() }, "&Reabre" , "Reabre" } )
	EndIf
	
	oDlg1 := MSDialog():New( 128,357,628,1052,"Análise das Contagens",,,.F.,,,,,,.T.,,,.T. )
	oDlg1:bInit := {|| EnchoiceBar(oDlg1,{||oDlg1:End()},{||oDlg1:End()},,aButtons) }
	RegToMemory(cAliasE, .F., .F.)

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAliasE)
	
	While !Eof().And.( X3_ARQUIVO == cAliasE )
		If X3USO( X3_USADO ).And.cNivel >= X3_NIVEL
			aAdd( aCpoEnch, X3_CAMPO )
		Endif
		&("M->"+Alltrim( X3_CAMPO ) ) := CriaVar(X3_CAMPO)
		dbSkip()
	End

	For nCntFor := 1 TO FCount()
		M->&( EVAL( bCampo, nCntFor ) ) := FieldGet( nCntFor )
	Next

	EnChoice( cAliasE,  Nil,nOpcE,,,,aCpoEnch,aPos,,3,,,)
	aColuna := {"  ","Contagem","Endereço","Produto","Saldo","Contado","Descrição","Usuário","Data","Hora"}
	oBrowse1 := TCBrowse():New(082,002,341,150,,aColuna,,oDlg1,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	AtuBrwIt(.F.)

	oDlg1:Activate(,,,.T.)
	
Return

//-----------------------------------------------------------
// Força a contagem atual a finalizar, alterando o seu status
//-----------------------------------------------------------
Static Function ForcaFim()

	ZAQ->( dbGoTo( aTail( aConta )[ 10 ] ) )
	
	If ZAQ->ZAQ_STATUS == "*"
		MsgAlert("Esta contagem já está encerrada!")
		Return
	EndIf
	
	If MsgYesNo("Tem certeza que deseja finalizar a contagem para este produto/endereço?")
		ZAQ->( RecLock("ZAQ", .F.) )
			ZAQ->ZAQ_STATUS := "*"
			ZAQ->ZAQ_DTANAL := dDataBase
			ZAQ->ZAQ_HRANAL := Left( Time(), 5 )
		ZAQ->( MsUnLock() )
		AtuBrwIt(.T.)
	EndIf
	
Return

//---------------------------------------------------------
// Força a geração de nova contagem, alterando o seu status
//---------------------------------------------------------
Static Function ForcaDiv()

	ZAQ->( dbGoTo( aTail( aConta )[ 10 ] ) )

	If ZAQ->ZAQ_CONTAG < ZAP->ZAP_CONTAG
		MsgAlert("A contagem deste item é anterior à contagem mestre!")
		Return
	ElseIf ZAQ->ZAQ_STATUS == "D"
		MsgAlert("Esta contagem já está divergente aguardando a geração da próxima contagem!")
		Return
	Elseif ZAQ->ZAQ_STATUS == "X"
		MsgAlert("Esta contagem está em andamento!")
		Return
	EndIf

	If MsgYesNo("Esta ação deixará esta contagem com status divergente e apta a nova contagem. Continuar?")
		ZAQ->( RecLock("ZAQ", .F.) )
			ZAQ->ZAQ_STATUS := "D"
			ZAQ->ZAQ_DTANAL := dDataBase
			ZAQ->ZAQ_HRANAL := Left( Time(), 5 )
		ZAQ->( MsUnLock() )
		AtuBrwIt(.T.)
	EndIf
	
Return

//-------------------------------------------------------------
// Seleciona os registros para o browse dos itens das contagens
//-------------------------------------------------------------
Static Function AtuBrwIt(lAtu)

	Local oVL := LoadBitMap(GetResources(), "BR_VERMELHO")
	Local oAZ := LoadBitMap(GetResources(), "BR_AZUL")
	Local oAM := LoadBitMap(GetResources(), "BR_AMARELO")
	Local oVD := LoadBitMap(GetResources(), "BR_VERDE")
	Local cQuery    := ""
	Local cNewAlias := ""
	Local aArea     := GetArea()

	cQuery := "SELECT * "
	cQuery += " FROM "+ RetSqlName("ZAQ") 
	cQuery += " WHERE ZAQ_FILIAL = '"+ xFilial("ZAQ")  +"' "
	cQuery += "   AND ZAQ_MESTRE = '"+ ZAP->ZAP_MESTRE +"' "
	cQuery += "   AND ZAQ_ENDER  = '"+ ZAQ->ZAQ_ENDER  +"' "
	cQuery += "   AND ZAQ_PRODUT = '"+ ZAQ->ZAQ_PRODUT +"' "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	
	TCQuery cQuery New Alias ( cNewAlias := GetNextAlias() )
	TCSetField(cNewAlias,'ZAQ_QUANT','N',TamSx3('ZAQ_QUANT')[1],TamSx3('ZAQ_QUANT')[2])
	TCSetField(cNewAlias,'ZAQ_SALDO','N',TamSx3('ZAQ_SALDO')[1],TamSx3('ZAQ_SALDO')[2])
	
	aConta := {}
	
	While !(cNewAlias)->( Eof() )

		aAdd( aConta, {  (cNewAlias)->ZAQ_STATUS,;
						 PadL( (cNewAlias)->ZAQ_CONTAG, 3, "0" ),;
						 (cNewAlias)->ZAQ_ENDER ,;
						 (cNewAlias)->ZAQ_PRODUT,;
						 (cNewAlias)->ZAQ_SALDO ,;
						 (cNewAlias)->ZAQ_QUANT ,;
						 Posicione("SB1",1,xFilial("SB1")+(cNewAlias)->ZAQ_PRODUT,"B1_DESC"),;
						 UsrRetName( (cNewAlias)->ZAQ_USER ),;
						 (cNewAlias)->ZAQ_DTCONT,;
						 (cNewAlias)->ZAQ_HRCONT,;
						 (cNewAlias)->R_E_C_N_O_ } )
						 
		(cNewAlias)->( dbSkip() )
	End
	(cNewAlias)->( dbCloseArea() )
	
	oBrowse1:SetArray( aConta ) 
	oBrowse1:bLine := { ||{ Iif( aConta[ oBrowse1:nAt, 01 ] == "X", oVD, Iif( aConta[ oBrowse1:nAt, 1 ] == "N", oAZ, Iif( aConta[ oBrowse1:nAt, 1 ] == "D", oAM, oVL ) ) ),;
								 aConta[ oBrowse1:nAt, 02 ],;
								 aConta[ oBrowse1:nAt, 03 ],;
								 aConta[ oBrowse1:nAt, 04 ],;
								 aConta[ oBrowse1:nAt, 05 ],;
								 aConta[ oBrowse1:nAt, 06 ],;
								 aConta[ oBrowse1:nAt, 07 ],;
								 aConta[ oBrowse1:nAt, 08 ],;
								 aConta[ oBrowse1:nAt, 09 ],;
								 aConta[ oBrowse1:nAt, 10 ] } }

	RestArea( aArea )

	If lAtu
		oBrowse1:Refresh()
    EndIf
	
Return

//---------------------------------------
// Executa a query para primeira contagem
//---------------------------------------
Static Function RunQry()

	Local _cQuery   := ""
	Local cNewAlias := ""
	
	If ZAP->ZAP_STATUS == "I"
	
		_cQuery := " SELECT DISTINCT( BE_LOCALIZ ) ENDERECO, "
		_cQuery += "        CASE WHEN BF_PRODUTO IS NOT NULL THEN BF_PRODUTO ELSE ' ' END PRODUTO, "
		_cQuery += "        CASE WHEN SALDO IS NOT NULL THEN SALDO ELSE 0 END SALDO "
		_cQuery += " FROM   "+ RetSqlName("SBE")
		_cQuery += " LEFT JOIN (SELECT SUM(BF_QUANT) SALDO, BF_LOCALIZ, BF_PRODUTO "
		_cQuery += "            FROM   "+ RetSqlName("SBF")
		_cQuery += "            WHERE  BF_FILIAL = '"+ xFilial("SBF") +"' "
		_cQuery += "                   AND D_E_L_E_T_ = ' ' "
		_cQuery += "                   AND BF_LOCAL BETWEEN '"+ ZAP->ZAP_LOCINI +"' AND '"+ ZAP->ZAP_LOCFIM +"' "

		_cQuery += "                   AND BF_PRODUTO IN ("

		If Empty( ZAP->ZAP_MOVINI ) .And. Empty( ZAP->ZAP_MOVFIM ) // Não considera o movimento
		
			_cQuery += "                          SELECT DISTINCT( B1_COD ) "
			_cQuery += "                          FROM  "+ RetSqlName("SB1") +" SB1 "
			_cQuery += "                          WHERE SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+ xFilial("SB1") +"' AND B1_MSBLQL <> '1' "
			_cQuery += "                                AND B1_COD   BETWEEN '"+ ZAP->ZAP_PRDINI +"' AND '"+ ZAP->ZAP_PRDFIM +"' "
			If Empty( ZAP->ZAP_GRUPOS )
				_cQuery += "                            AND B1_GRUPO BETWEEN '"+ ZAP->ZAP_GRPINI +"' AND '"+ ZAP->ZAP_GRPFIM +"' "
			Else
				_cQuery += "                            AND B1_GRUPO IN ('"+ StrTran( ZAP->ZAP_GRUPOS, ",", "','" ) +"') "
			EndIf
			_cQuery += "                                 )"

		Else // Considera movimentação no período (entrada/saída/internos)
		
			_cQuery += "                     SELECT DISTINCT( PRODUTO ) FROM ( "
			_cQuery += "                       SELECT D1_COD PRODUTO "
			_cQuery += "                       FROM   "+ RetSqlName("SD1")
			_cQuery += "                       WHERE  D1_FILIAL = '"+ xFilial("SD1") +"' "
			_cQuery += "                          AND D1_DTDIGIT BETWEEN '"+ DtoS( ZAP->ZAP_MOVINI ) +"' AND '"+ DtoS( ZAP->ZAP_MOVFIM ) +"' "
			_cQuery += "                          AND D_E_L_E_T_ = ' ' "
			_cQuery += "                          AND D1_COD IN (SELECT DISTINCT( B1_COD ) B1_COD "
			_cQuery += "                                         FROM  "+ RetSqlName("SB1") +" SB1 "
			_cQuery += "                                         WHERE SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+ xFilial("SB1") +"' AND B1_MSBLQL <> '1' "
			_cQuery += "                                           AND B1_COD   BETWEEN '"+ ZAP->ZAP_PRDINI +"' AND '"+ ZAP->ZAP_PRDFIM +"' "
			If Empty( ZAP->ZAP_GRUPOS )
				_cQuery += "                                       AND B1_GRUPO BETWEEN '"+ ZAP->ZAP_GRPINI +"' AND '"+ ZAP->ZAP_GRPFIM +"' "
			Else
				_cQuery += "                                       AND B1_GRUPO IN ('"+ StrTran( ZAP->ZAP_GRUPOS, ",", "','" ) +"') "
			EndIf
			_cQuery += "                                        ) "
			_cQuery += "                       UNION "
			_cQuery += "                       SELECT D2_COD PRODUTO "
			_cQuery += "                       FROM   "+ RetSqlName("SD2")
			_cQuery += "                       WHERE  D2_FILIAL = '"+ xFilial("SD2") +"' "
			_cQuery += "                          AND D2_DTDIGIT BETWEEN '"+ DtoS( ZAP->ZAP_MOVINI ) +"' AND '"+ DtoS( ZAP->ZAP_MOVFIM ) +"' "
			_cQuery += "                          AND D_E_L_E_T_ = ' ' "
			_cQuery += "                          AND D2_COD IN (SELECT DISTINCT( B1_COD ) B1_COD "
			_cQuery += "                                         FROM  "+ RetSqlName("SB1") +" SB1 "
			_cQuery += "                                         WHERE SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+ xFilial("SB1") +"' AND B1_MSBLQL <> '1' "
			_cQuery += "                                           AND B1_COD   BETWEEN '"+ ZAP->ZAP_PRDINI +"' AND '"+ ZAP->ZAP_PRDFIM +"' "
			If Empty( ZAP->ZAP_GRUPOS )
				_cQuery += "                                       AND B1_GRUPO BETWEEN '"+ ZAP->ZAP_GRPINI +"' AND '"+ ZAP->ZAP_GRPFIM +"' "
			Else
				_cQuery += "                                       AND B1_GRUPO IN ('"+ StrTran( ZAP->ZAP_GRUPOS, ",", "','" ) +"') "
			EndIf
			_cQuery += "                                        ) "
			_cQuery += "                       UNION "
			_cQuery += "                       SELECT D3_COD PRODUTO "
			_cQuery += "                       FROM   "+ RetSqlName("SD3")
			_cQuery += "                       WHERE  D3_FILIAL = '"+ xFilial("SD3") +"' "
			_cQuery += "                          AND D3_EMISSAO BETWEEN '"+ DtoS( ZAP->ZAP_MOVINI ) +"' AND '"+ DtoS( ZAP->ZAP_MOVFIM ) +"' "
			_cQuery += "                          AND D_E_L_E_T_ = ' ' "
			_cQuery += "                          AND D3_ESTORNO = ' ' "
			_cQuery += "                          AND D3_COD IN (SELECT DISTINCT( B1_COD ) B1_COD "
			_cQuery += "                                         FROM  "+ RetSqlName("SB1") +" SB1 "
			_cQuery += "                                         WHERE SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+ xFilial("SB1") +"' AND B1_MSBLQL <> '1' "
			_cQuery += "                                           AND B1_COD   BETWEEN '"+ ZAP->ZAP_PRDINI +"' AND '"+ ZAP->ZAP_PRDFIM +"' "
			If Empty( ZAP->ZAP_GRUPOS )
				_cQuery += "                                       AND B1_GRUPO BETWEEN '"+ ZAP->ZAP_GRPINI +"' AND '"+ ZAP->ZAP_GRPFIM +"' "
			Else
				_cQuery += "                                       AND B1_GRUPO IN ('"+ StrTran( ZAP->ZAP_GRUPOS, ",", "','" ) +"') "
			EndIf
			_cQuery += "  )  ) MOV ) "

		EndIf
		
		_cQuery += "                  GROUP  BY BF_LOCALIZ, BF_PRODUTO "
		_cQuery += "		   ) SLD "
		_cQuery += " ON BE_LOCALIZ = BF_LOCALIZ "
		_cQuery += " WHERE  BE_FILIAL = '"+ xFilial("SBE") +"' "
		_cQuery += "   AND SBE010.D_E_L_E_T_ = ' ' "
		If Empty( ZAP->ZAP_ENDFIM ) .And. !Empty( ZAP->ZAP_PRDFIM )
			_cQuery += "   AND SALDO > 0 "
		Else
			_cQuery += "   AND BE_LOCALIZ BETWEEN '"+ ZAP->ZAP_ENDINI +"' AND '"+ ZAP->ZAP_ENDFIM +"' "
			
			If ZAP->ZAP_SALDO == "S"
				_cQuery += " AND SALDO > 0 "
			EndIf
		EndIf
		_cQuery += "   AND BE_LOCAL   BETWEEN '"+ ZAP->ZAP_LOCINI +"' AND '"+ ZAP->ZAP_LOCFIM +"' "
		_cQuery += "   AND BE_STATUS <> '3' " // Apenas endereços não bloqueados
		_cQuery += " ORDER BY ENDERECO"
	Else
		_cQuery := " SELECT ZAQ_ENDER ENDERECO, ZAQ_QUANT SALDO, ZAQ_PRODUT PRODUTO "
		_cQuery += " FROM "+ RetSqlName("ZAQ")
		_cQuery += " WHERE D_E_L_E_T_ = ' ' AND ZAQ_FILIAL = '"+ xFilial("ZAQ") +"' ""
		_cQuery += "   AND ZAQ_MESTRE = '"+ ZAP->ZAP_MESTRE +"' "
		_cQuery += "   AND ZAQ_CONTAG = '"+ ZAP->ZAP_CONTAG +"' "
		_cQuery += "   AND ZAQ_STATUS = 'D' "
		_cQuery += " ORDER BY ENDERECO"
	EndIf

	_cQuery := ChangeQuery( _cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQuery), ( cNewAlias := GetNextAlias() ), .F., .T.)

Return( cNewAlias )

//--------------------------------------------------------------------
// Verifica quantos registros de contagem existe em determinado status
//--------------------------------------------------------------------
Static Function GetQtSts( cSts )

	Local _nQtd     := 0
	Local cQuery    := ""
	Local cNewAlias := ""
	Local aArea     := GetArea()

	cQuery := "SELECT COUNT(*) TOTAL "
	cQuery += " FROM "+ RetSqlName("ZAQ") 
	cQuery += " WHERE ZAQ_FILIAL = '"+ xFilial("ZAQ")  +"' "
	cQuery += "   AND ZAQ_MESTRE = '"+ ZAP->ZAP_MESTRE +"' "
	cQuery += "   AND ZAQ_STATUS = '"+ cSts            +"' "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	
	TCQuery cQuery New Alias ( cNewAlias := GetNextAlias() )
	
	_nQtd := (cNewAlias)->TOTAL
	(cNewAlias)->( dbCloseArea() )
	
	RestArea( aArea )
		
Return( _nQtd )

//-----------------------------------------------------------------
// Seleciona os itens para exportação em excel, preparando os dados
//-----------------------------------------------------------------
Static Function GetItExp( cMestre )

	Local _aRet     := {}
	Local _aTmp     := {}
	Local _aLastCnt := {}
	Local _n        := 0
	Local _nTmp     := 0
	Local _nQtCont  := 0
	Local _nArrElm  := 0
	Local _cTmp     := ""
	Local cQuery    := ""
	Local cNewAlias := ""
	Local aArea     := GetArea()

	If ZAP->ZAP_MESTRE <> cMestre
		ZAP->( dbSeek( xFilial("ZAP") + cMestre ) )
	EndIf
	
	_nQtCont := Val( ZAP->ZAP_CONTAG )
	_nArrElm := 23 + ( 2 * _nQtCont ) // 23 campos fixos mais dois campos para cada contagem
	
	cQuery := " SELECT * FROM "+ RetSqlName("ZAQ")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += "    AND ZAQ_FILIAL = '"+ xFilial("ZAQ") +"'"
	cQuery += "    AND ZAQ_MESTRE = '"+ cMestre +"'"
	cQuery += " ORDER BY ZAQ_ENDER, ZAQ_PRODUT, ZAQ_CONTAG"
	
	TCQuery cQuery New Alias ( cNewAlias := GetNextAlias() )
	
	While !(cNewAlias)->( Eof() )

		_aTmp := Array( _nArrElm )
		
		_aTmp[ 01 ] := CHR(160) + (cNewAlias)->ZAQ_PRODUT

		dbSelectArea("SB1")
		dbSetOrder(1)
		
		If !Empty( (cNewAlias)->ZAQ_PRODUT ) .And. dbSeek( xFilial("SB1") + (cNewAlias)->ZAQ_PRODUT )
			_aTmp[ 02 ] := CHR(160) + AllTrim( SB1->B1_DESC )
			_aTmp[ 03 ] := CHR(160) + SB1->B1_GRUPO
			_aTmp[ 04 ] := CHR(160) + SB1->B1_UM
		Else
			_aTmp[ 02 ] := CHR(160) + Space(1)
			_aTmp[ 03 ] := CHR(160) + Space(1)
			_aTmp[ 04 ] := CHR(160) + Space(1)
		EndIf
		
		_aTmp[ 05 ] := CHR(160) + Left( AllTrim( (cNewAlias)->ZAQ_ENDER ), 2 )
		_aTmp[ 06 ] := CHR(160) + Right( AllTrim( (cNewAlias)->ZAQ_ENDER ), 2 )

		dbSelectArea("SBF")
		dbSetOrder(1)
		
		_aTmp[ 07 ] := Iif( dbSeek( xFilial("SBF") + "01" + (cNewAlias)->ZAQ_ENDER + (cNewAlias)->ZAQ_PRODUT ), SBF->BF_QUANT, 0 )
		_aTmp[ 08 ] := Iif( dbSeek( xFilial("SBF") + "02" + (cNewAlias)->ZAQ_ENDER + (cNewAlias)->ZAQ_PRODUT ), SBF->BF_QUANT, 0 )

		_aTmp[ 09 ] := CHR(160) + (cNewAlias)->ZAQ_ENDER
		_aTmp[ 10 ] := _aTmp[ 07 ] + _aTmp[ 08 ]
		
		dbSelectArea("SB2")
		dbSetOrder(1)
		
		_aTmp[ 11 ] := Iif( dbSeek( xFilial("SB2") + (cNewAlias)->ZAQ_PRODUT + "01" ), Round( SB2->B2_CM1, 2 ), 0 )
		_aTmp[ 12 ] := Iif( dbSeek( xFilial("SB2") + (cNewAlias)->ZAQ_PRODUT + "02" ), Round( SB2->B2_CM1, 2 ), 0 )

		_nTmp := 13
		_cTmp := (cNewAlias)->ZAQ_ENDER + (cNewAlias)->ZAQ_PRODUT

		For _n := 1 To _nQtCont

			If (cNewAlias)->ZAQ_ENDER + (cNewAlias)->ZAQ_PRODUT == _cTmp

				_aTmp[ _nTmp++ ] := (cNewAlias)->ZAQ_QUANT
				_aTmp[ _nTmp++ ] := Iif( (cNewAlias)->ZAQ_STATUS == "D", "RECONTAR", Iif( (cNewAlias)->ZAQ_STATUS == "N", "NOK", Iif( (cNewAlias)->ZAQ_STATUS == "*", "OK", "NAO CONTADO" ) ) )
                
                _aLastCnt := { (cNewAlias)->ZAQ_QUANT, _aTmp[ _nTmp - 1 ] }
                
				(cNewAlias)->( dbSkip() )
			Else
				_aTmp[ _nTmp++ ] := _aLastCnt[ 1 ]
				_aTmp[ _nTmp++ ] := _aLastCnt[ 2 ]
				_cTmp := (cNewAlias)->ZAQ_ENDER + (cNewAlias)->ZAQ_PRODUT
			EndIf
			
		Next

		_aTmp[ _nTmp++ ] := _aLastCnt[ 1 ] - _aTmp[ 10 ] // Divergência = última contagem menos o saldo total
		_aTmp[ _nTmp++ ] := Round( ( _aLastCnt[ 1 ] - _aTmp[ 10 ] ) * _aTmp[ 11 ], 2 ) // Custo = divergência vezes o B2_CM1 no 01
		_aTmp[ _nTmp++ ] := Iif( ( ( _aLastCnt[ 1 ] - _aTmp[ 10 ] ) * (-1) ) > _aTmp[ 07 ], ( _aTmp[ 07 ] * (-1) ), _aLastCnt[ 1 ] - _aTmp[ 10 ] )
		_aTmp[ _nTmp++ ] := ( _aLastCnt[ 1 ] - _aTmp[ 10 ] ) - _aTmp[ _nTmp - 1 ]
		_aTmp[ _nTmp++ ] := 0
		_aTmp[ _nTmp++ ] := 0
		_aTmp[ _nTmp++ ] := 0
		_aTmp[ _nTmp++ ] := 0
		_aTmp[ _nTmp++ ] := ( _aLastCnt[ 1 ] - _aTmp[ 10 ] ) - _aTmp[ _nTmp - 1 ] - _aTmp[ _nTmp - 2 ] - _aTmp[ _nTmp - 3 ] - _aTmp[ _nTmp - 4 ]
		_aTmp[ _nTmp++ ] := _aTmp[ _nTmp - 1 ] * _aTmp[ 11 ]
		_aTmp[ _nTmp++ ] := 0

		aAdd( _aRet, _aTmp )
		
	End
	(cNewAlias)->( dbCloseArea() )
	
	RestArea( aArea )

Return( _aRet )

// Conta a quantidade de endereços distintos
Static Function AddrCount( cAlias )

	Local nCntEnd := 0
	Local cUltEnd := ""
	
	(cAlias)->( dbGoTop() )
	
	While !(cAlias)->( Eof() )
		
		If (cAlias)->ENDERECO != cUltEnd
			nCntEnd++
		EndIf
		
		cUltEnd := (cAlias)->ENDERECO
		
		(cAlias)->( dbSkip() )
	End
	
Return( nCntEnd )

// Distribui os endereços afetados pela query entre os recursos humanos selecionados
Static Function AlocarRh( cAliasIt, nQtdEnd, aRecHum )

	Local nSaldo    := 0
	Local nEndQAtu  := 0
	Local cLastEnd  := ""
	Local nRecHAtu  := 1

	While !(cAliasIt)->( Eof() )
		
		nSaldo := 0
		
		If nEndQAtu == nQtdEnd
			
			If cLastEnd != (cAliasIt)->ENDERECO

				nEndQAtu := 1
				cLastEnd := (cAliasIt)->ENDERECO
				
				If nRecHAtu < Len( aRecHum ) // Se houver diferença na divisão (quebra) ficará para o último
					nRecHAtu++
				EndIf
				
			EndIf
		Else
			If cLastEnd != (cAliasIt)->ENDERECO
				cLastEnd := (cAliasIt)->ENDERECO
				nEndQAtu++
			EndIf
		EndIf
		
		If !Empty( (cAliasIt)->PRODUTO )

			dbSelectArea("SBF")
			dbSetOrder(1)

			If dbSeek( xFilial("SBF") + "01" + (cAliasIt)->ENDERECO + (cAliasIt)->PRODUTO )
				nSaldo += SBF->BF_QUANT
			EndIf
			
			If dbSeek( xFilial("SBF") + "02" + (cAliasIt)->ENDERECO + (cAliasIt)->PRODUTO )
				nSaldo += SBF->BF_QUANT
			EndIf
		
		EndIf
		
		ZAQ->( RecLock("ZAQ", .T. ) )
			ZAQ->ZAQ_FILIAL := xFilial("ZAQ")
			ZAQ->ZAQ_MESTRE := ZAP->ZAP_MESTRE
			ZAQ->ZAQ_CONTAG := Soma1(ZAP->ZAP_CONTAG)
			ZAQ->ZAQ_PRODUT := (cAliasIt)->PRODUTO
			ZAQ->ZAQ_ENDER  := (cAliasIt)->ENDERECO
			ZAQ->ZAQ_QUANT  := 0
			ZAQ->ZAQ_SALDO  := nSaldo
			ZAQ->ZAQ_DTCONT := CtoD("//")
			ZAQ->ZAQ_HRCONT := ""
			ZAQ->ZAQ_DTANAL := CtoD("//")
			ZAQ->ZAQ_HRANAL := ""
			ZAQ->ZAQ_STATUS := "X"
			ZAQ->ZAQ_USER   := aRecHum[ nRecHAtu ]
		ZAQ->( MsUnLock() )
		
		(cAliasIt)->( dbSkip() )
	End

Return