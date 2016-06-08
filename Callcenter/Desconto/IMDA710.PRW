#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "IMDEPA.CH"

#DEFINE CRLF ( chr( 13 ) + chr( 10 ) )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IMDA710     ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao no Cadastro de Carta de Negocios                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_IMDA710()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±³          ³         Vizualizar, Incluir, Alterar, Excluir ou Copiar    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±³ Incluido o campo ZAO_FOBPRG, tanto na tela como no arquivo de importa- ³±±
±±³ ção.                                                                   ³±±
±±³                                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR       ³ DATA        ³ DESCRICAO                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Julio Jacovenko   ³ 31/10/2011  ³                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function IMDA710()

	Local cFilNoEst := GetMV("MV_FILSEST")
	Local nRecSM0   := 0
	Local aCores    := {	{ '! (ZAN_INIVAL <= dDataBase .and. dDataBase <= ZAN_FIMVAL)'                        , 'BR_AZUL' },;
		{ 'ZAN_CARAPR == "S" .and. ( ZAN_INIVAL <= dDataBase .and. dDataBase <= ZAN_FIMVAL )', 'ENABLE'  },;
		{ 'ZAN_CARAPR == "N"'                                                                , 'DISABLE' }}

	Private cCadastro	:= OemToAnsi("Carta de Negócios")

	Private aRotina	:= {	{ OemToAnsi("Pesquisar"	),	"AxPesqui"   ,0,1},;
		{ OemToAnsi("Visualizar"),	"U_IMD710Mnt",0,2},;
		{ OemToAnsi("Incluir"	),	"U_IMD710Mnt",0,3},;
		{ OemToAnsi("Alterar"	),	"U_IMD710Mnt",0,4},;
		{ OemToAnsi("Excluir"	),	"U_IMD710Mnt",0,5},;
		{ OemToAnsi("Aprova&r"	),	"U_IMD710Apr",0,6},;
		{ OemToAnsi("Copiar"		),	"U_IMD710Mnt",0,6},;
		{ OemToAnsi("Força Aprovação"	),	"U_IMD710Tst",0,6},;
		{ OemToAnsi("Legenda"	),	"U_IMD710Lgd",0,7} }

// Rotina consulta todos os Cadastrados como Aprovadores e grava na Carta,
// fazendo com que essa carta esteja valida automaticamente !!
//									{ OemToAnsi("Força Aprovação"	),	"U_IMD710Tst",0,6},;

	Private aUsuAprov := U_A710RETAPR()
	Private aFiliais  := {}

	// Busca as filiais da Empresa
	DbSelectArea("SM0")
	nRecSM0 := Recno()
	DbSeek( cEmpAnt, .F. )
	While SM0->M0_CODIGO == cEmpAnt

		// Somente carrega as Filiais que utilizam Estoque
		If ! SM0->M0_CODFIL $ cFilNoEst
			AADD( aFiliais, { .F., SM0->M0_CODFIL, SM0->M0_FILIAL, IIF( SM0->M0_CODFIL==cFilAnt, " FILIAL ATUAL", " " ) } )
		EndIf

		DbSkip()
	Enddo
	DbGoto( nRecSM0 )

	DbSelectArea( "ZAN" )
	ZAN->( DbSetOrder( 1 ) )

	mBrowse( 6, 1, 22, 75, "ZAN",,,,,, aCores )

	RetIndex("ZAN")

Return NIL


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IMD710Mnt   ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao no Cadastro de Carta de Negocios                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_IMD710Mnt()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±³          ³         Vizualizar, Incluir, Alterar, Excluir ou Copiar    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function IMD710Mnt( cAlias, nReg, nOpcx )

	//-- Genericas
	Local aAreaAnt	:= GetArea()
	Local nCntFor	:= 0
	Local nPosApr  := 0
	Local nCampo   := 0
	Local bCampo   := { |nCPO| Field(nCPO) }
	Local cCposNot := ""
	Local cCpo     := ""
	Local cCpo1    := ""
	//-- EnchoiceBar
	Local aVisual	:= {}
	Local aAltera	:= {}
	Local aButtons	:= {}
	Local nOpca		:= 0
	Local oEnch
	//-- Dialog
	Local oDlgEsp
	//-- GetDados
	Local aNoFields	:= {}
	Local aYesFields:= {}
	//-- Controle de dimensoes de objetos
	Local aObjects	:= {}
	Local aInfo		:= {}

	Local nUsado    := 0

	Local nPProduto
	Local nPDescri
	Local nPQuant
	Local nPVrCAcre
	Local nPOperado
	Local nJ
	Local lInclui
	Local cTexto
	Local cSeqID

	//-- EnchoiceBar
	Private aTela[0][0]
	Private aGets[0]
	//-- GetDados
	Private aHeader	:= {}
	Private aCols	:= {}
	Private oGetD

	Private aPosObj:= {}
	Private nPIni
	Private aPreco := {}
	Private INCLUI := ( nOpcx == 3 )
	Private ALTERA := ( nOpcx == 4 )
	Private EXCLUI := ( nOpcx == 5 )

	// Somente na inclusao mostra o botao para importar uma Carta de um arquivo .CSV
	If nOpcx == 3
		aAdd( aButtons, { "S4WB001N", &("{|| U_IMD710Imp() }"), "Importa Carta" } )
	EndIf

	DbSelectArea( "ZAN" )

	// Na Alteracao, trava o registro para que outro nao possa Alterar ou Aprovar
	If nOpcX == 4
		If !RecLock( "ZAN", .F. )
			MsgStop( "Não foi possível travar o registro para atualização. Pode ter outro usuário acessando essa Carta", "Carta de Negócios" )
			Return
		EndIf
	EndIf

	//-- Campos que nao aparecerao na GetDados
	Aadd( aNoFields, "ZAO_CODCAR" )

	//-- Configura variaveis da Enchoice
	RegToMemory( cAlias, ( nOpcx==3 .Or. nOpcx==7 ) )

	//-- Configura variaveis da GetDados
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("ZAO")
	Do While ( !Eof() .And. SX3->X3_ARQUIVO == "ZAO" )
		If X3USO(SX3->X3_USADO)
			If aScan(aNoFields, AllTrim(SX3->X3_CAMPO)) = 0
				nUsado++
				aAdd(aHeader,{ TRIM(X3Titulo()),;
					TRIM(SX3->X3_CAMPO),;
					SX3->X3_PICTURE,;
					SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,;
					SX3->X3_VALID,;
					SX3->X3_USADO,;
					SX3->X3_TIPO,;
					SX3->X3_ARQUIVO,;
					SX3->X3_CONTEXT } )
			EndIf
		EndIf
		dbSelectArea("SX3")
		dbSkip()
	EndDo

	// carrega os dados para o aCols
	n := 0

	// Na inclusao nao precisa consultar os Produtos
	If nOpcx <> 3
		dbSelectArea("ZAO")
		dbSetOrder(1)
		dbSeek(xFilial("ZAO")+ZAN->ZAN_CODCAR,.F.)
		Do While ZAO->ZAO_FILIAL+ZAO->ZAO_CODCAR == xFilial("ZAO")+ZAN->ZAN_CODCAR .and. !Eof()
			n++
			aAdd(aCols,Array(nUsado+1))
			For nCntFor := 1 To nUsado
				If ( aHeader[nCntFor][10] != "V" )
					aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
				Else
					aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
				EndIf
			Next nCntFor
			aCols[Len(aCols)][Len(aHeader)+1] := .F.
			dbSkip()
		EndDo
	EndIf
	n := 1

	//-- Inicializa o item da getdados se a linha estiver em branco.
	If Len( aCols ) == 1 .And. Empty( GDFieldGet( "ZAO_ITEM", 1 ) )
		GDFieldPut( "ZAO_ITEM", StrZero( 1, Len( ZAO->ZAO_ITEM ) ), 1 )
		nPIni := 1
	Else
		nPIni := Len( aCols )+1
	EndIf

	// Na copia deixa alguns campos com o valor default
	If	nOpcx == 7

      // Variavel que armazena os campos que NAO serao copiados
		cCposNot := "ZAN_CODCAR|ZAN_INIVAL|ZAN_FIMVAL"

		// Nos campos dos Aprovadores, deixa o valor default
		For nPosApr := 1 To 5

			cCpo  := "|ZAN_CODAP" + cValToChar( nPosApr )
			cCpo1 := "|ZAN_DTAPR" + cValToChar( nPosApr )

			cCposNot += cCpo + cCpo1
		Next

		DbSelectArea( "ZAN" )
		For nCampo := 1 To FCount()

			// Campos que estiverem na variavel abaixo, nao terao o valor copiado, mas serah inicializado com o valor default
			If !FieldName( nCampo ) $ cCposNot
				M->&( EVAL( bCampo, nCampo ) ) := FieldGet( nCampo )
			Else
				M->&( EVAL( bCampo, nCampo ) ) := CriaVar( FieldName( nCampo ) )
			EndIf

		Next nCampo

	EndIf

	// Dimensoes padroes
	aSize := MsAdvSize()
	AAdd( aObjects, { 100, 065, .T., .T. } ) // getdados
	AAdd( aObjects, { 100, 050, .T., .T. } ) // enchoice

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
		// Monta a enchoice
	oEnch := MsMGet():New( cAlias, nReg, nOpcx,,,, aVisual, aPosObj[1],, 3,,,,,,.T. )

		//        MsGetDados(                  nT ,               nL,             nB,               nR,                         nOpc,   cLinhaOk,    cTudoOk,   cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oGetD := MSGetDados():New(aPosObj[ 2, 1 ], aPosObj[ 2, 2 ],aPosObj[ 2, 3 ], aPosObj[ 2, 4 ], IIF( nOpcx == 7, 3, nOpcx ),"U_IMD710L(.F.)","U_IMD710T","+ZAO_ITEM",.T.   ,      ,1      ,      ,100 ,       ,         ,       ,     ,    )

	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||nOpca:=1, If( oGetD:TudoOk(),oDlgEsp:End(),nOpca := 0)},{||oDlgEsp:End()},, aButtons )

	// Nao eh Vizualizacao e Confirmou a tela !!
	If nOpcx != 2 .And. nOpcA == 1

		IMD710Grv( nOpcx )

	EndIf

	// Na Alteracao, destrava o registro
	If nOpcX == 4
		DbSelectArea( "ZAN" )
		MsUnLock()
	EndIf

	DeleteObject( oDlgEsp )
	DeleteObject( oEnch )
	DeleteObject( oGetD )

	RestArea( aAreaAnt )

Return( nOpcA )


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IMD710L     ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes da linha da GetDados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_IMD710L()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function IMD710L( lConfirma )

	Local aArea     := GetArea()
	Local cQuery    := ""
	Local lRet      := .T.
	Local nPos      := 0
	Local nP_Item   := Ascan( aHeader, {|x| AllTrim( x[2] ) == "ZAO_ITEM"   } )
	Local nP_CodPro := Ascan( aHeader, {|x| AllTrim( x[2] ) == "ZAO_CODPRO" } )
	Local nP_Descri := Ascan( aHeader, {|x| AllTrim( x[2] ) == "ZAO_DESCRI" } )
	Local nP_CodIte := Ascan( aHeader, {|x| AllTrim( x[2] ) == "ZAO_CODITE" } )
	Local nP_Quant  := Ascan( aHeader, {|x| AllTrim( x[2] ) == "ZAO_QUANT"  } )
	Local nP_Marca  := Ascan( aHeader, {|x| AllTrim( x[2] ) == "ZAO_MARCA"  } )
	Local nP_Grupo  := Ascan( aHeader, {|x| AllTrim( x[2] ) == "ZAO_GRUPO"  } )
	Local nP_GrpMa1 := Ascan( aHeader, {|x| AllTrim( x[2] ) == "ZAO_GRPMA1" } )
	Local nP_GrpMa2 := Ascan( aHeader, {|x| AllTrim( x[2] ) == "ZAO_GRPMA2" } )
	Local nP_GrpMa3 := Ascan( aHeader, {|x| AllTrim( x[2] ) == "ZAO_GRPMA3" } )
	Local nP_SGRB1  := Ascan( aHeader, {|x| AllTrim( x[2] ) == "ZAO_SGRB1"  } )
	Local nP_SGRB2  := Ascan( aHeader, {|x| AllTrim( x[2] ) == "ZAO_SGRB2"  } )
	Local nP_SGRB3  := Ascan( aHeader, {|x| AllTrim( x[2] ) == "ZAO_SGRB3"  } )
	Local nP_PercDe := Ascan( aHeader, {|x| AllTrim( x[2] ) == "ZAO_PERCDE" } )
	Local nP_Preco  := Ascan( aHeader, {|x| AllTrim( x[2] ) == "ZAO_PRECO"  } )
	Local nP_Margem := Ascan( aHeader, {|x| AllTrim( x[2] ) == "ZAO_MARGEM" } )

	Default lConfirma := .F.

   // Se a linha estiver deletada, retorna TRUE
	If GDDeleted( N )
		Return( lRet )
	EndIf

	If (	Empty( aCols[ N, nP_CodPro ] ) .And. Empty( aCols[ N, nP_Descri ] ) .And. Empty( aCols[ N, nP_CodIte ] ) .And.;
			Empty( aCols[ N, nP_Marca  ] ) .And. Empty( aCols[ N, nP_Grupo  ] ) .And. Empty( aCols[ N, nP_GrpMa1 ] ) .And.;
			Empty( aCols[ N, nP_GrpMa2 ] ) .And. Empty( aCols[ N, nP_GrpMa3 ] ) .And. aCols[ N, nP_Quant ] <= 0      .And.;
			Empty( aCols[ N, nP_SGRB1  ] ) .And. Empty( aCols[ N, nP_SGRB2  ] ) .And. Empty( aCols[ N, nP_SGRB3  ] ) )

		MsgStop( "Favor informar: Codigo ou Descrição ou Item ou Quantidade ou Marca ou qualquer um dos Grupos ou qualquer um dos Sub Grupos !", "Carta de Negócios" )

		lRet := .F.
		Return( lRet )
	EndIf

	If (	aCols[ N, nP_PercDe ] <= 0 .And. aCols[ N, nP_Preco ] <= 0 .And. aCols[ N, nP_Margem ] <= 0 )

		MsgStop( "Favor informar valor para: Percentual Desconto ou Preço ou Margem !", "Carta de Negócios" )

		lRet := .F.
		Return( lRet )
	EndIf

	// Validar o item informado
	If !Empty( aCols[ N, nP_CodIte ] )

		cQuery := "SELECT B1_FILIAL, B1_COD "
		cQuery += "	 FROM " + RetSqlName( "SB1" ) + " "
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += "   AND EXISTS ( SELECT B1_FILIAL, B1_COD "
		cQuery += "	 					  FROM " + RetSqlName( "SB1" ) + " "
		cQuery += " 					 WHERE D_E_L_E_T_ = ' ' "
		cQuery += "   						AND B1_FILIAL  = '" + xFilial( "SB1" ) + "' "
		cQuery += "   						AND B1_MSBLQL  <> '1' "
		cQuery += "   						AND B1_CODITE  LIKE UPPER( '%" + AllTrim( aCols[ N, nP_CodIte ] ) + "%' ) "
		cQuery += "   						AND ROWNUM = 1 ) "

		If Select( "QRY_SB1" ) <> 0
			DbSelectArea( "QRY_SB1" )
			DbCloseArea()
		EndIf

		MemoWrit( "IMDA710_VALID_LINHA.sql", cQuery )

		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY_SB1",.F.,.T.)

		If QRY_SB1->( EOF() )

			MsgStop( "Não foi localizado nenhum Produto para Item informado nessa Filial", "Carta de Negócios" )

			DbCloseArea()
			RestArea( aArea )

			lRet := .F.
			Return( lRet )

		EndIf
		DbCloseArea()

	EndIf

	// Quando o usuario clicar no botao "OK" da tela, deverah validar todas as linhas
	If lConfirma
		// Analisa se ha itens duplicados na GetDados
		For nPos := 1 To Len( aCols )

			// Nao avalia linhas deletadas
			// Avalia linhas diferente da posicao atual
			If !GDDeleted( nPos ) .And. N <> nPos

				// Nao pode ter todas essas informacoes iguais, ou seja, alguma coisa tem que ser diferente
				If (	aCols[ nPos, nP_CodPro ] == aCols[ N, nP_CodPro ] .And. aCols[ nPos, nP_CodIte ] == aCols[ N, nP_CodIte ] .And.;
						aCols[ nPos, nP_Marca  ] == aCols[ N, nP_Marca  ] .And. aCols[ nPos, nP_Grupo  ] == aCols[ N, nP_Grupo  ] .And.;
						aCols[ nPos, nP_GrpMa1 ] == aCols[ N, nP_GrpMa1 ] .And. aCols[ nPos, nP_GrpMa2 ] == aCols[ N, nP_GrpMa2 ] .And.;
						aCols[ nPos, nP_GrpMa3 ] == aCols[ N, nP_GrpMa3 ] .And. aCols[ nPos, nP_SGRB1  ] == aCols[ N, nP_SGRB1  ] .And.;
						aCols[ nPos, nP_SGRB2  ] == aCols[ N, nP_SGRB2  ] .And. aCols[ nPos, nP_SGRB3  ] == aCols[ N, nP_SGRB3  ] .And.;
						aCols[ nPos, nP_Descri ] == aCols[ N, nP_Descri ] .And. aCols[ nPos, nP_Quant  ] == aCols[ N, nP_Quant  ] )

					MsgStop( "As informações de: Codigo, Descrição, Item, Quantidade, Marca, Grupos e Sub Grupos, " +;
						"são iguais nos itens " + aCols[ nPos, nP_Item ] + " e " + aCols[ N, nP_Item ] + "." + Chr(13) +;
						"Favor alterar uma dessas informações.", "Carta de Negócios" )
					lRet := .F.
					Exit
				EndIf

			EndIf

		Next
	EndIf

Return( lRet )


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IMD710T     ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao Geral						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_IMD710T()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function IMD710T()

	Local lRet, nX, lAtuConc := .F.
	//-- Analisa se os campos obrigatorios da Enchoice foram informados.
	lRet := Obrigatorio( aGets, aTela )

	//-- Analisa se os campos obrigatorios da GetDados foram informados.
	If	lRet
		lRet := oGetD:ChkObrigat( n )
	EndIf

	//-- Analisa o linha ok.
	If lRet
		lRet := U_IMD710L( .T. )
	EndIf

	//-- Analisa se todos os itens da GetDados estao deletados.
	If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
		Help( ' ', 1, 'OBRIGAT2')
		lRet := .F.
	EndIf

Return( lRet )


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IMD710Grv   ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravar dados 							                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ IMD710Grv()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function IMD710Grv( nOpcx )

	Local aAreaAnt	  := GetArea()
	Local cBkpFil    := cFilAnt
	Local nCntFor	  := 0
	Local nCntFol	  := 0
	Local nFil		  := 0
	Local cCodCar    := ""
	Local aProd      := {}
	Local aFil       := {}
	Local cPicPercDE := PesqPict( "ZAO", "ZAO_PERCDE" )
	Local cPicPreco  := PesqPict( "ZAO", "ZAO_PRECO"  )
	Local cPicMargem := PesqPict( "ZAO", "ZAO_MARGEM" )
	Local cPicQuant  := PesqPict( "ZAO", "ZAO_QUANT"  )

	If	nOpcx == 5				//-- Excluir

		Begin Transaction

			dbSelectArea("ZAO")
			DbSetOrder( 1 )
			dbSeek(xFilial("ZAO")+M->ZAN_CODCAR,.F.)
			Do While ZAO->ZAO_FILIAL + ZAO->ZAO_CODCAR == xFilial("ZAO") + M->ZAN_CODCAR .and. !Eof()

				AADD( aProd,{	{ "Codigo"				, AllTrim( ZAO->ZAO_CODPRO ), "" },;
					{ "Descrição"			, AllTrim( ZAO->ZAO_DESCRI ), "" },;
					{ "Codigo Item"		, AllTrim( ZAO->ZAO_CODITE ), "" },;
					{ "Quantidade"			, ZAO->ZAO_QUANT , cPicQuant },;
					{ "Marca"				, AllTrim( ZAO->ZAO_MARCA ), "" },;
					{ "Grupo"				, ZAO->ZAO_GRUPO , ""  },;
					{ "Grp. Marca 1"		, ZAO->ZAO_GRPMA1, "" },;
					{ "Grp. Marca 2"		, ZAO->ZAO_GRPMA2, "" },;
					{ "Grp. Marca 3"		, ZAO->ZAO_GRPMA3, "" },;
					{ "Sub Grupo 1"		, ZAO->ZAO_SGRB1 , "" },;
					{ "Sub Grupo 2"		, ZAO->ZAO_SGRB2 , "" },;
					{ "Sub Grupo 3"		, ZAO->ZAO_SGRB3 , "" },;
					{ "% Desconto"			, ZAO->ZAO_PERCDE, cPicPercDE },;
					{ "Preço"				, ZAO->ZAO_PRECO , cPicPreco },;
					{ "Moeda"				, IIF( ZAO->ZAO_MOEDA=="1","Real","Dolar"), "" },;
					{ "Margem"				, ZAO->ZAO_MARGEM, cPicMargem };
					} )

				RecLock("ZAO",.F.,.T.)
				ZAO->( DbDelete() )
				MsUnLock()
				dbSkip()
			EndDo

			dbSelectArea("ZAN")
			RecLock("ZAN",.F.,.T.)
			ZAN->(DbDelete())
			MsUnLock()

		End Transaction

		// ###############################################
		// Envia e-mail informando a Exclusao
		// ###############################################
		Set Deleted Off // Mostra os registros deletados
		Processa( {|| ZAN->( U_A710SndMail( "E", aProd ) ) }, "Aguarde", "Enviando comunicado da Carta..." )
		Set Deleted On // NAO mostra os registros deletados

	ElseIf ( nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx == 7 ) // Incluir, Alterar ou Copiar

		// Para a COPIA, seleciona as Filiais da nova Carta
		If nOpcx == 7
			aFil := SelFil( aFiliais )
		Else
			//cFilCart := cFilAnt
			AADD( aFil, cFilAnt )
		EndIf

		If nOpcx == 7 .And. Empty( aFil )
			MsgInfo( "Nenhuma Filial selecionada para a cópia!" )
			cFilAnt := cBkpFil
			RestArea( aAreaAnt )
			Return( NIL )
		EndIf

		Begin Transaction

			For nFil := 1 To Len( aFil )

				cFilAnt := aFil[ nFil ]
				aProd   := {}

		      // Pega o proximo numero disponivel, na Inclusao ou Copia
				If ( nOpcx == 3 .Or. nOpcx == 7 )
					cCodCar := GetSXENum( "ZAN", "ZAN_CODCAR" )

			      // Se a carta jah existir nessa Filial, confirma e pega o proximo codigo, revalidando o sequencial
					While SAN->( DbSeek( xFilial( "ZAN" ) + cCodCar ) )
						ConfirmSX8()
						cCodCar := GetSXENum( "ZAN", "ZAN_CODCAR" )
					EndDo

				Else
					cCodCar := ZAN->ZAN_CODCAR
				EndIf

				// Grava o Cabecalho
				dbSelectArea("ZAN")
				// Cria um novo registro na Inclusao ou Copia
				Reclock( "ZAN", ( nOpcx == 3 .Or. nOpcx == 7 ) )

				For nCntFor := 1 To fCount()
					Fieldput( nCntFor, M->&( Fieldname( nCntFor ) ) )
				Next

				ZAN->ZAN_FILIAL := cFilAnt
				ZAN->ZAN_CODCAR := cCodCar

					// QUALQUER alteracao limpa TODAS as aprovacoes
					// Incluir, Alterar ou Copiar
				ZAN->ZAN_CARAPR := "N"

				ZAN->ZAN_CODAP1 := Space( Len( ZAN->ZAN_CODAP1 ) )
				ZAN->ZAN_DTAPR1 := Space( Len( ZAN->ZAN_DTAPR1 ) )

				ZAN->ZAN_CODAP2 := Space( Len( ZAN->ZAN_CODAP2 ) )
				ZAN->ZAN_DTAPR2 := Space( Len( ZAN->ZAN_DTAPR2 ) )

				ZAN->ZAN_CODAP3 := Space( Len( ZAN->ZAN_CODAP3 ) )
				ZAN->ZAN_DTAPR3 := Space( Len( ZAN->ZAN_DTAPR3 ) )

				ZAN->ZAN_CODAP4 := Space( Len( ZAN->ZAN_CODAP4 ) )
				ZAN->ZAN_DTAPR4 := Space( Len( ZAN->ZAN_DTAPR4 ) )

				ZAN->ZAN_CODAP5 := Space( Len( ZAN->ZAN_CODAP5 ) )
				ZAN->ZAN_DTAPR5 := Space( Len( ZAN->ZAN_DTAPR5 ) )

				MsUnlock()

				// Grava os Itens
				dbSelectArea("ZAO")
				DbSetOrder( 1 )
				For nCntFor := 1 To Len( aCols )

					If	!GDDeleted( nCntFor )

						If DbSeek( xFilial( "ZAO" ) + ZAN->ZAN_CODCAR + GDFieldGet( "ZAO_ITEM", nCntFor ) )
							RecLock("ZAO",.F.)
						Else
							RecLock("ZAO",.T.)
							ZAO->ZAO_FILIAL	:= xFilial("ZAO")
							ZAO->ZAO_CODCAR 	:= ZAN->ZAN_CODCAR
						EndIf

						For nCntFol := 1 To Len(aHeader)
							If	aHeader[ nCntFol, 10 ] != "V"
								FieldPut( FieldPos( aHeader[ nCntFol, 2 ] ), aCols[ nCntFor, nCntFol ] )
							EndIf
						Next
						MsUnLock()

						AADD( aProd,{	{ "Codigo"				, AllTrim( ZAO->ZAO_CODPRO ), "" },;
							{ "Descrição"			, AllTrim( ZAO->ZAO_DESCRI ), "" },;
							{ "Codigo Item"		, AllTrim( ZAO->ZAO_CODITE ), "" },;
							{ "Quantidade"			, ZAO->ZAO_QUANT , cPicQuant },;
							{ "Marca"				, AllTrim( ZAO->ZAO_MARCA ), "" },;
							{ "Grupo"				, ZAO->ZAO_GRUPO , ""  },;
							{ "Grp. Marca 1"		, ZAO->ZAO_GRPMA1, "" },;
							{ "Grp. Marca 2"		, ZAO->ZAO_GRPMA2, "" },;
							{ "Grp. Marca 3"		, ZAO->ZAO_GRPMA3, "" },;
							{ "Sub Grupo 1"		, ZAO->ZAO_SGRB1 , "" },;
							{ "Sub Grupo 2"		, ZAO->ZAO_SGRB2 , "" },;
							{ "Sub Grupo 3"		, ZAO->ZAO_SGRB3 , "" },;
							{ "% Desconto"			, ZAO->ZAO_PERCDE, cPicPercDE },;
							{ "Preço"				, ZAO->ZAO_PRECO ,  cPicPreco },;
							{ "Moeda"				, IIF( ZAO->ZAO_MOEDA=="1","Real","Dolar"), "" },;
							{ "Margem"				, ZAO->ZAO_MARGEM, cPicMargem };
							} )
					Else
						If DbSeek( xFilial( "ZAO" ) + ZAN->ZAN_CODCAR + GDFieldGet( "ZAO_ITEM", nCntFor ) )
							RecLock("ZAO",.F.,.T.)
							ZAO->( DbDelete() )
							MsUnLock()
						EndIf
					EndIf

				Next

				If Len( aCols ) > 0
					EvalTrigger()
				EndIf

				// Confirma o codigo da Carta
				If ( nOpcx == 3 .Or. nOpcx == 7 )
					ConfirmSX8()
				EndIf

				// ##################################################################
				// Envia e-mail informando a Inclusao ( copia ou nao ) ou Alteracao
				// ##################################################################
				If ( nOpcx == 3 .Or. nOpcx == 7 )
					Processa( {|| ZAN->( U_A710SndMail( "I", aProd ) ) }, "Aguarde", "Enviando comunicado da Carta..." )
				ElseIf nOpcx == 4
					Processa( {|| ZAN->( U_A710SndMail( "A", aProd ) ) }, "Aguarde", "Enviando comunicado da Carta..." )
				EndIf

			Next

		End Transaction

	EndIf

	cFilAnt := cBkpFil

	RestArea( aAreaAnt )

Return( NIL )



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SelFil      ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Selecionar uma Filial que ira receber a Nova Carta copiada ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SelFil()		                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function SelFil( aFiliais )

	Local nFil		:= 0
	Local aRet		:= {}
	Local oOk      := Loadbitmap( GetResources(), 'LBOK' )
	Local oNo      := Loadbitmap( GetResources(), 'LBNO' )
	Local lOk      := .T.

	Static oDlg, oBut, oList

	DEFINE MSDIALOG oDlg TITLE OemToAnsi( "Filiais de Carta de Negócios" ) FROM 0,0 TO 18,90
	@ 115,020 BUTTON "Inverte a marca" SIZE 40,13 ACTION {|| SDTroca( @aFiliais, .F. ) } PIXEL OF oDlg
	@ 115,090 BUTTON "Marca/Desmarca" SIZE 40,13 ACTION {|| SDTroca( @aFiliais, .T.  ) } PIXEL OF oDlg
	@ 115,160 BUTTON "Confirma" SIZE 40,13 ACTION {|| lOk := .T., oDlg:End() } PIXEL OF oDlg
	@ 115,230 BUTTON "Cancela" SIZE 40,13 ACTION {|| lOk := .F., oDlg:End() } PIXEL OF oDlg

	@ 02,02  LISTBOX oList ;
		FIELDS HEADER  '  ','Codigo','Descricao','Tipo' ;
		SIZE 300,105 ;
		PIXEL OF oDlg ;
		ON dblClick(aFiliais[oList:nAt,1] := !aFiliais[oList:nAt,1],oList:Refresh())
	oList:Align := 3

	oList:SetArray(aFiliais)
	oList:bLine:={|| {If(aFiliais[oList:nAt,01],oOk,oNo),;
		aFiliais[oList:nAt,02],;
		aFiliais[oList:nAt,03],;
		aFiliais[oList:nAt,04]}}

	oList:Refresh()

	ACTIVATE MSDIALOG oDlg CENTERED

	If lOk

		// Para cada filial marcada carrega no array
		For nFil := 1 To Len( aFiliais )

			If aFiliais[ nFil, 1 ]
				AADD( aRet, aFiliais[ nFil, 2 ] )
			EndIf

		Next

	EndIf

Return( aRet )




/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SDTroca     ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marcar ou Desmarcar as Filiais que sao mostradas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SDTroca()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function SDTroca( aVetor, lTodos )

	Local nPos    := 0
	Local lStatus := aVetor[ 1, 1 ]

	For nPos := 1 To Len( aVetor )

		If lTodos
			// Marca ou Desmarca todos
			aVetor[ nPos, 1 ] := !lStatus
		Else
			// Inverte o Status dos registros
			aVetor[ nPos, 1 ] := !aVetor[ nPos, 1 ]
		EndIf

	Next

Return



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IMD710Apr   ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aprovar uma Carta de Negocios                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_IMD710Apr()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function IMD710Apr()

	Local cCodUsu_   := AllTrim( RetCodUsr() )
	Local cPerfApr   := ""
	Local cCpo       := ""
	Local nPosApr    := 0
	Local nAprov     := 0
	Local lOk        := .T.
	Local aProd      := {}
	Local cPicPercDE := PesqPict( "ZAO", "ZAO_PERCDE" )
	Local cPicPreco  := PesqPict( "ZAO", "ZAO_PRECO"  )
	Local cPicMargem := PesqPict( "ZAO", "ZAO_MARGEM" )
	Local cPicQuant  := PesqPict( "ZAO", "ZAO_QUANT"  )

	For nAprov := 1 To Len( aUsuAprov )

		// Verifica se o usuario atual pode aprovar carta
		If cCodUsu_ == AllTrim( aUsuAprov[ nAprov, POS_COD_APR ] )

			// Carrega o Perfil do usuario que pode aprovar
			cPerfApr := AllTrim( aUsuAprov[ nAprov, POS_PERFIL_APR ] )

			Exit
		EndIf

	Next

	If Empty( cPerfApr )
		MsgStop( "Usuário não tem permissão para Aprovar Carta de Negócio", "Carta de Negócios" )
		Return
	EndIf

	// Se o usuario jah liberou essa carta, avisa e cancela
	For nPosApr := 1 To 5

		cCpo := "ZAN->ZAN_CODAP" + cValToChar( nPosApr )

		If cCodUsu_ == &cCpo

			MsgStop( AllTrim( UsrFullName( cCodUsu_ ) ) + ", voce já aprovou essa Carta em " + &("ZAN->ZAN_DTAPR" + cValToChar( nPosApr ) ), "Carta de Negócios" )
			lOk := .F.
			Exit

		EndIf

	Next

	If !lOk
		Return
	EndIf

	DbSelectArea( "ZAN" )

	// Dependendo do Perfil do usuario, o sistema irah verificar se precisa da aprovacao
	If cPerfApr == PERFIL_DIRETOR

		If !Empty( ZAN->ZAN_CODAP1 ) .And. !Empty( ZAN->ZAN_CODAP2 )

			MsgStop( "Já existem as aprovações dos Diretores." + Chr( 10 ) +;
				"Aprovação cancelada !!!", "Carta de Negócios" )
			Return
		EndIf

	ElseIf cPerfApr == PERFIL_USUARIO

		If !Empty( ZAN->ZAN_CODAP3 ) .And. !Empty( ZAN->ZAN_CODAP4 ) .And. !Empty( ZAN->ZAN_CODAP5 )

			MsgStop( "Já foram realizadas todas as aprovações para o Perfil Usuário." + Chr( 10 ) +;
				"Aprovação cancelada !!!", "Carta de Negócios" )
			Return
		EndIf

	Else
		MsgStop( "Perfil do usuário inválido !!!" + Chr( 10 ) +;
			"Informe ao Setor de TI - POA", "Carta de Negócios" )
		Return
	EndIf

	If !RecLock( "ZAN", .F. )
		MsgStop( "Existe um usuário realizando alterações nessa Carta, favor aguardar o término da alteração.", "Carta de Negócios" )
		Return
	EndIf

	// Chama a rotina para vizualizar e se o usuario confirmou aprova a carta
	If U_IMD710Mnt( "ZAN", ZAN->( Recno() ), 2 ) == 1

		// Grava as aprovacoes de acordo com o Perfil do usuario
		If cPerfApr == PERFIL_DIRETOR

			If Empty( ZAN->ZAN_CODAP1 )

				ZAN->ZAN_CODAP1 := cCodUsu_
				ZAN->ZAN_DTAPR1 := DtoC( dDataBase ) + " " + Time()

			ElseIf Empty( ZAN->ZAN_CODAP2 )

				ZAN->ZAN_CODAP2 := cCodUsu_
				ZAN->ZAN_DTAPR2 := DtoC( dDataBase ) + " " + Time()

			EndIf

		ElseIf cPerfApr == PERFIL_USUARIO

			If Empty( ZAN->ZAN_CODAP3 )

				ZAN->ZAN_CODAP3 := cCodUsu_
				ZAN->ZAN_DTAPR3 := DtoC( dDataBase ) + " " + Time()

			ElseIf Empty( ZAN->ZAN_CODAP4 )

				ZAN->ZAN_CODAP4 := cCodUsu_
				ZAN->ZAN_DTAPR4 := DtoC( dDataBase ) + " " + Time()

			ElseIf Empty( ZAN->ZAN_CODAP5 )

				ZAN->ZAN_CODAP5 := cCodUsu_
				ZAN->ZAN_DTAPR5 := DtoC( dDataBase ) + " " + Time()

			EndIf

		EndIf

		// Se existem as 2 aprovacoes dos DIRETORES, desbloqueia a carta !!
		If !Empty( ZAN->ZAN_CODAP1 ) .And. !Empty( ZAN->ZAN_CODAP2 )

			ZAN->ZAN_CARAPR := "S"

		EndIf

	EndIf

	// Aprova o registro que jah estava travado
	MsUnLock()

	// ###############################################
	// Envia e-mail informando a Aprovacao
	// ###############################################
	If ZAN->ZAN_CARAPR == "S"

		// Faz a leitura de todos os itens para envio do e-mail
		DbSelectArea( "ZAO" )
		DbSetOrder( 1 )
		ZAO->( DbSeek( xFilial("ZAO") + ZAN->ZAN_CODCAR, .F. ) )
		While ZAO->ZAO_FILIAL + ZAO->ZAO_CODCAR == xFilial("ZAO") + ZAN->ZAN_CODCAR .And. ZAO->( !Eof()	 )

			AADD( aProd,{	{ "Codigo"				, AllTrim( ZAO->ZAO_CODPRO ), "" },;
				{ "Descrição"			, AllTrim( ZAO->ZAO_DESCRI ), "" },;
				{ "Codigo Item"		, AllTrim( ZAO->ZAO_CODITE ), "" },;
				{ "Quantidade"			, ZAO->ZAO_QUANT , cPicQuant },;
				{ "Marca"				, AllTrim( ZAO->ZAO_MARCA ), "" },;
				{ "Grupo"				, ZAO->ZAO_GRUPO , ""  },;
				{ "Grp. Marca 1"		, ZAO->ZAO_GRPMA1, "" },;
				{ "Grp. Marca 2"		, ZAO->ZAO_GRPMA2, "" },;
				{ "Grp. Marca 3"		, ZAO->ZAO_GRPMA3, "" },;
				{ "Sub Grupo 1"		, ZAO->ZAO_SGRB1 , "" },;
				{ "Sub Grupo 2"		, ZAO->ZAO_SGRB2 , "" },;
				{ "Sub Grupo 3"		, ZAO->ZAO_SGRB3 , "" },;
				{ "% Desconto"			, ZAO->ZAO_PERCDE, cPicPercDE },;
				{ "Preço"				, ZAO->ZAO_PRECO, cPicPreco },;
				{ "Moeda"				, IIF( ZAO->ZAO_MOEDA=="1","Real","Dolar"), "" },;
				{ "Margem"				, ZAO->ZAO_MARGEM, cPicMargem };
				} )

			ZAO->( DbSkip() )
		EndDo

		Processa( {|| ZAN->( U_A710SndMail( "L", aProd ) ) }, "Aguarde", "Enviando comunicado da Carta..." )

	EndIf

Return



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ A710SndMail ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Envia email informando sobre movimentacoes da Carta        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_A710SndMail()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function A710SndMail( cTipoLib, aDados )

	Local cServer    := GetMV('MV_RELSERV')
	Local cUser      := GetMV('MV_RELACNT')
	Local cPass      := GetMV('MV_RELPSW')
	Local lAuth      := Getmv("MV_RELAUTH")
	Local nVencCar   := SuperGetMV( "MV_VENCCAR",, 30 )
	Local cPicPDEFIL := PesqPict( "ZAN", "ZAN_PDEFIL" )
	Local cPicPreco  := PesqPict( "ZAN", "ZAN_PRECO" )
	Local cPicComis  := PesqPict( "ZAN", "ZAN_COMISS" )
	Local cPicMarge  := PesqPict( "ZAN", "ZAN_MARGEM" )
	Local cPicPrazo  := PesqPict( "ZAN", "ZAN_PRAZOM" )
	Local cPicDeCli  := PesqPict( "ZAN", "ZAN_PDECLI" )
	Local cPicPDVI   := PesqPict( "ZAN", "ZAN_PDVI" )
	Local cPicPCVI   := PesqPict( "ZAN", "ZAN_PCVI" )
	Local cPicPDVE   := PesqPict( "ZAN", "ZAN_PDVE" )
	Local cPicPCVE   := PesqPict( "ZAN", "ZAN_PCVE" )
	Local cPicDesGC  := PesqPict( "ZAN", "ZAN_DESGC" )
	Local cPicComGC  := PesqPict( "ZAN", "ZAN_COMGC" )
	Local cPicDesGE  := PesqPict( "ZAN", "ZAN_DESGER" )
	Local cPicComGE  := PesqPict( "ZAN", "ZAN_COMGER" )
	Local cPicDesDI  := PesqPict( "ZAN", "ZAN_DESDIR" )
	Local cPicComDI  := PesqPict( "ZAN", "ZAN_COMDIR" )
	Local cPicPDB2B  := PesqPict( "ZAN", "ZAN_PDB2B"  )
	Local cPicCampo  := ""
	Local lResult    := .F.
	Local cHtml      := ""
	Local cDest      := ""
	Local cCpo       := ""
	Local cCpo1      := ""
	Local nPos       := 0
	Local nReg       := 0
	Local nPerfil    := 0
	Local nPosApr    := 0
	Local cError

	// A rotina do workflow que avisa sobre cartas que irao vencer, nao esta declarada essa variavel
	If Upper( cTipoLib ) == "V"
		aUsuAprov := U_A710RETAPR()
	EndIf

	// Busca o e-mail do usuario logado no sistema
	//cDest += Lower( AllTrim( UsrRetMail( RetCodUsr() ) ) ) + ";"

	For nPosApr := 1 To Len( aUsuAprov )

		cCpo := Lower( AllTrim( aUsuAprov[ nPosApr, POS_EMAIL_APR ] ) )

		// Nao duplica o destinatario
		If ! cCpo $ cDest
			cDest += cCpo + ";"
		EndIf

	Next

	// Retira o ";" do final
	cDest := SubStr( cDest, 1, Len( cDest )-1 )

	cHtml += '<html>'
	cHtml += '<head>'

	cHtml += '<title>Carta de Negócios Nr ' + ZAN->ZAN_CODCAR + '</title>'
	cHtml += '<style type="text/css" > '
	cHtml += 'TAM18N{ font-size:18PX; font-weight: bold; } '
	cHtml += '</style>'
	cHtml += '</head>'

	cHtml += '<body bgcolor="white" text="black" >'
	cHtml += 'A Carta de Negócios Nr ' + ZAN->ZAN_CODCAR + ', '

	If Upper( cTipoLib ) == "I"

		cHtml += 'foi <TAM18N> INCLUIDA </TAM18N> '

	ElseIf Upper( cTipoLib ) == "A"

		cHtml += 'foi <TAM18N> ALTERADA </TAM18N> '

	ElseIf Upper( cTipoLib ) == "E"

		cHtml += 'foi <TAM18N> EXCLUIDA </TAM18N> '

	ElseIf Upper( cTipoLib ) == "L"

		cHtml += 'foi <TAM18N> APROVADA </TAM18N> '

	ElseIf Upper( cTipoLib ) == "V"

		cHtml += 'irá vencer até o dia ' + DtoC( dDataBase + nVencCar ) + ''

	EndIf

	cHtml += ' conforme detalhes abaixo:'

	// ###############################################
	// Comeca a montar os dados do cabecalho
	// ###############################################
	cHtml += '<table width="100%" border=0 >'
	cHtml += '<tr bgcolor="#8DB6CD" >'
	cHtml += '<td colspan="16" align=center><b> DEFINIÇÕES DA CARTA </b></td>'
	cHtml += '</tr>'

	cHtml += '<tr>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Codigo </td>'
	cHtml += '<td colspan="3" > ' + ZAN->ZAN_CODCAR + ' </td>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Descrição </td>'
	cHtml += '<td colspan="9" > ' + ZAN->ZAN_DESCRI + ' </td>'
	cHtml += '</tr>'

	cHtml += '<tr>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Filial </td>'
	cHtml += '<td colspan="3" > ' + ZAN->ZAN_FILIAL + '-' + Posicione( "SM0", 1, cEmpAnt + xFilial( "ZAL" ), "M0_FILIAL" ) + ' </td>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Perc. Desc. </td>'
	cHtml += '<td colspan="3" > ' + Transform( ZAN->ZAN_PDEFIL, cPicPDEFIL ) + ' </td>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Frete </td>'
	If Empty( ZAN->ZAN_TPFRET )
		cHtml += '<td colspan="4" > CIF ou FOB </td>'
	ElseIf ZAN->ZAN_TPFRET == "C"
		cHtml += '<td colspan="4" > CIF </td>'
	ElseIf ZAN->ZAN_TPFRET == "F"
		cHtml += '<td colspan="4" > FOB </td>'
	EndIf
	cHtml += '</tr>'

	cHtml += '<tr>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Validade Inicial </td>'
	cHtml += '<td colspan="3" > ' + DtoC( ZAN->ZAN_INIVAL ) + ' </td>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Validade Final </td>'
	cHtml += '<td colspan="3" > ' + DtoC( ZAN->ZAN_FIMVAL ) + ' </td>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Carta Aprovada </td>'
	cHtml += '<td colspan="4" > ' + IIF( ZAN->ZAN_CARAPR == 'S', 'Sim', 'Não' ) + ' </td>'
	cHtml += '</tr>'

	cHtml += '<tr>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Preço </td>'
	cHtml += '<td colspan="3" > ' + Transform( ZAN->ZAN_PRECO, cPicPreco ) + ' </td>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Comissão </td>'
	cHtml += '<td colspan="3" > ' + Transform( ZAN->ZAN_COMISS, cPicComis ) + ' </td>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Margem ( IMC ) </td>'
	cHtml += '<td colspan="4" > ' + Transform( ZAN->ZAN_MARGEM, cPicMarge ) + ' </td>'
	cHtml += '</tr>'

	If !Empty( ZAN->ZAN_CONDPG )
		cHtml += '<tr>'
		cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Cond. Pagto </td>'
		cHtml += '<td> ' + ZAN->ZAN_CONDPG + ' - ' + Posicione( "SE4", 1, xFilial( "SE4" ) + ZAN->ZAN_CONDPG, "E4_DESCRI" ) + '</td>'
		cHtml += '</tr>'
	Else
		cHtml += '<tr>'
		cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Prazo Médio </td>'
		cHtml += '<td> ' + Transform( ZAN->ZAN_PRAZOM, cPicPrazo ) + '</td>'
		cHtml += '</tr>'
	EndIf

	// Linha em branco
	cHtml += '<tr bgcolor="#FFFFFF" >'
	cHtml += '<td colspan="16" text="white" > <br> </td>'
	cHtml += '</tr>'

	cHtml += '<br><br>'
	cHtml += '<tr bgcolor="#8DB6CD" >'
	cHtml += '<td colspan="16" align=center><b> DEFINIÇÕES DO CLIENTE </b></td>'
	cHtml += '</tr>'

	cHtml += '<tr>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Codigo / Loja - Nome </td>'
	cHtml += '<td colspan="8" > ' + ZAN->ZAN_CODCLI + ' / ' + ZAN->ZAN_LOJCLI + ' - ' + Posicione( "SA1", 1, xFilial( "SA1" ) + ZAN->ZAN_CODCLI + ZAN->ZAN_LOJCLI, "A1_NREDUZ" ) + ' </td>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> UF / Cidade </td>'
	cHtml += '<td colspan="4" > ' + ZAN->ZAN_UFCLI + ' / ' + AllTrim( Posicione( "CC2", 1, xFilial( "CC2" ) + ZAN->ZAN_UFCLI + ZAN->ZAN_MUNCLI, "CC2_MUN" ) ) + ' - ' + ZAN->ZAN_MUNCLI + ' </td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Região </td>'
	cHtml += '<td colspan="3" > ' + ZAN->ZAN_REGIAO + ' - ' + Posicione( "SZ1", 1, xFilial( "SZ1" ) + ZAN->ZAN_REGIAO, "Z1_DESCRI" ) + ' </td>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Mesoregião </td>'
	cHtml += '<td colspan="3" > ' + ZAN->ZAN_MESREG + ' - ' + Posicione( "SZ3", 1, xFilial( "SZ3" ) + ZAN->ZAN_MESREG, "Z3_DESCRI" ) + ' </td>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Microregião </td>'
	cHtml += '<td colspan="4" > ' + ZAN->ZAN_MICREG + ' - ' + Posicione( "SZ2", 1, xFilial( "SZ2" ) + ZAN->ZAN_MICREG, "Z2_DESCRI" ) + ' </td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> CNAE </td>'
	cHtml += '<td colspan="3" > ' + ZAN->ZAN_CNAE + ' - ' + Posicione( "CC3", 1, xFilial( "CC3" ) + ZAN->ZAN_CNAE, "CC3_DESC" ) + ' </td>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Ativ. / Neg. </td>'
	cHtml += '<td colspan="3" > ' + ZAN->ZAN_ATIVID + ' - ' + Posicione( "SX5", 1, xFilial( "SX5" ) + "T8" + ZAN->ZAN_ATIVID, "X5_DESCRI" ) + ' </td>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Grupo Segmento </td>'
	cHtml += '<td colspan="4" > ' + ZAN->ZAN_GRPSEG + ' - ' + Posicione( "ZZV", 1, xFilial( "ZZV" ) + ZAN->ZAN_GRPSEG, "ZZV_DESC" ) + ' </td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Segmento </td>'
	cHtml += '<td colspan="3" > ' + ZAN->ZAN_GRPSEG + ' - ' + Posicione( "SX5", 1, xFilial( "SX5" ) + "T3" + ZAN->ZAN_GRPSEG, "X5_DESCRI" ) + ' </td>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Perc. Desc </td>'
	cHtml += '<td colspan="3" > ' + Transform( ZAN->ZAN_PDECLI, cPicDeCli ) + ' </td>'
	cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Vinculo </td>'
	cHtml += '<td colspan="4" > ' + ZAN->ZAN_TPVINC + ' - ' + Posicione( "CC1", 1, xFilial( "CC1" ) + ZAN->ZAN_TPVINC, "CC1_DESCRI" ) + ' </td>'
	cHtml += '</tr>'


	//cHtml += '</table>'

	If ( !Empty( ZAN->ZAN_CODAP1 ) .Or. !Empty( ZAN->ZAN_CODAP2 ) .Or. !Empty( ZAN->ZAN_CODAP3 ) .Or. !Empty( ZAN->ZAN_CODAP4 ) .Or. !Empty( ZAN->ZAN_CODAP5 ) )

		// Linha em branco
		cHtml += '<tr bgcolor="#FFFFFF" >'
		cHtml += '<td colspan="16" text="white" > <br> </td>'
		cHtml += '</tr>'

		cHtml += '<tr bgcolor="#8DB6CD" >'
		cHtml += '<td colspan="16" align=center><b> APROVADORES </b></td>'
		cHtml += '</tr>'

		// Faz o LOOP nos 5 campos dos Aprovadores
		For nPosApr := 1 To 5

			cCpo  := "ZAN->ZAN_CODAP" + cValToChar( nPosApr )
			cCpo1 := "ZAN->ZAN_DTAPR" + cValToChar( nPosApr )

			If !Empty( &cCpo )

				cHtml += '<tr>'
				cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Usuário </td>'
				cHtml += '<td colspan="6" > ' + &cCpo + ' - ' + AllTrim( UsrFullName( &cCpo ) ) + ' </td>'
				cHtml += '<td bgcolor="#F3F3F3"> Data </td>'
				cHtml += '<td colspan="3" > ' + &cCpo1 + ' </td>'
				cHtml += '<td bgcolor="#F3F3F3"> Perfil </td>'

				nPerfil := aScan( aUsuAprov, { |x| x[ POS_COD_APR ] ==  &cCpo } )
				If nPerfil > 0
					cHtml += '<td colspan="3" > ' + AllTrim( aUsuAprov[ nPerfil, POS_PERFIL_APR ] ) + ' </td>'
				Else
					cHtml += '<td colspan="3" > ' + ' ' + '</td>'
				EndIf

				cHtml += '</tr>'

			EndIf

		Next

		//cHtml += '</table>'
	EndIf

	// Informacoes dos Vendedores
	If ( !Empty( ZAN->ZAN_CARGO ) .Or. !Empty( ZAN->ZAN_CODVI  ) .Or. !Empty( ZAN->ZAN_CODVE  ) .Or.;
			!Empty( ZAN->ZAN_CODGC ) .Or. !Empty( ZAN->ZAN_CODGER ) .Or. !Empty( ZAN->ZAN_CODDIR ) )

		// Linha em branco
		cHtml += '<tr bgcolor="#FFFFFF" >'
		cHtml += '<td colspan="16" text="white" > <br> </td>'
		cHtml += '</tr>'

		cHtml += '<tr bgcolor="#8DB6CD" >'
		cHtml += '<td colspan="16" align=center><b> DEFINIÇÕES DA ESTRUTURA DE VENDAS </b></td>'
		cHtml += '</tr>'

		If !Empty( ZAN->ZAN_CARGO )
			cHtml += '<tr>'
			cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Cargo Vendas </td>'
			cHtml += '<td colspan="14"> ' + ZAN->ZAN_CARGO + ' - ' + ZAN->ZAN_DESCAR + ' </td>'
			cHtml += '</tr>'
		EndIf

		If !Empty( ZAN->ZAN_CODVI )
			cHtml += '<tr>'
			cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Vend. Interno </td>'
			cHtml += '<td colspan="6" > ' + ZAN->ZAN_CODVI + ' - ' + ZAN->ZAN_NOMVI + ' </td>'
			cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Desconto </td>'
			cHtml += '<td colspan="2" > ' + Transform( ZAN->ZAN_PDVI, cPicPDVI ) + ' </td>'
			cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Comissão </td>'
			cHtml += '<td colspan="2" > ' + Transform( ZAN->ZAN_PCVI, cPicPCVI ) + ' </td>'
			cHtml += '</tr>'
		EndIf

		If !Empty( ZAN->ZAN_CODVE )
			cHtml += '<tr>'
			cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Vend. Externo </td>'
			cHtml += '<td colspan="6" > ' + ZAN->ZAN_CODVE + ' - ' + ZAN->ZAN_NOMVE + ' </td>'
			cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Desconto </td>'
			cHtml += '<td colspan="2" > ' + Transform( ZAN->ZAN_PDVE, cPicPDVE ) + ' </td>'
			cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Comissão </td>'
			cHtml += '<td colspan="2" > ' + Transform( ZAN->ZAN_PCVE, cPicPCVE ) + ' </td>'
			cHtml += '</tr>'
		EndIf

		If !Empty( ZAN->ZAN_CODGC )
			cHtml += '<tr>'
			cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Gestor Conta </td>'
			cHtml += '<td colspan="6" > ' + ZAN->ZAN_CODGC + ' - ' + ZAN->ZAN_NOMGC + ' </td>'
			cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Desconto </td>'
			cHtml += '<td colspan="2" > ' + Transform( ZAN->ZAN_DESGC, cPicDesGC ) + ' </td>'
			cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Comissão </td>'
			cHtml += '<td colspan="2" > ' + Transform( ZAN->ZAN_COMGC, cPicComGC ) + ' </td>'
			cHtml += '</tr>'
		EndIf

		If !Empty( ZAN->ZAN_CODGER )
			cHtml += '<tr>'
			cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Gerente </td>'
			cHtml += '<td colspan="6" > ' + ZAN->ZAN_CODGER + ' - ' + ZAN->ZAN_NOMGER + ' </td>'
			cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Desconto </td>'
			cHtml += '<td colspan="2" > ' + Transform( ZAN->ZAN_DESGER, cPicDesGE ) + ' </td>'
			cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Comissão </td>'
			cHtml += '<td colspan="2" > ' + Transform( ZAN->ZAN_COMGER, cPicComGE ) + ' </td>'
			cHtml += '</tr>'
		EndIf

		If !Empty( ZAN->ZAN_CODDIR )
			cHtml += '<tr>'
			cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Diretor </td>'
			cHtml += '<td colspan="6" > ' + ZAN->ZAN_CODDIR + ' - ' + ZAN->ZAN_NOMDIR + ' </td>'
			cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Desconto </td>'
			cHtml += '<td colspan="2" > ' + Transform( ZAN->ZAN_DESDIR, cPicDesDI ) + ' </td>'
			cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Comissão </td>'
			cHtml += '<td colspan="2" > ' + Transform( ZAN->ZAN_COMDIR, cPicComDI ) + ' </td>'
			cHtml += '</tr>'
		EndIf

		//cHtml += '</table>'
	EndIf

	If !Empty( ZAN->ZAN_CODB2B )

		// Linha em branco
		cHtml += '<tr bgcolor="#FFFFFF" >'
		cHtml += '<td colspan="16" text="white" > <br> </td>'
		cHtml += '</tr>'

		cHtml += '<tr bgcolor="#8DB6CD" >'
		cHtml += '<td colspan="16" align=center><b> DEFINIÇÕES DO B2B </b></td>'
		cHtml += '</tr>'

		cHtml += '<br><br>'
		cHtml += '<tr>'
		cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Operador B2B </td>'
		cHtml += '<td colspan="5" > ' + ZAN->ZAN_CODB2B + ' - ' + Posicione( "SA3", 1, xFilial( "SA3" ) + ZAN->ZAN_CODB2B, "A3_NREDUZ" ) + ' </td>'
		cHtml += '<td colspan="2" bgcolor="#F3F3F3"> Perc. Desconto </td>'
		cHtml += '<td> ' + Transform( ZAN->ZAN_PDB2B, cPicPDB2B ) + ' </td>'
		cHtml += '</tr>'
		//cHtml += '</table>'

	EndIf


	// ###############################################
	// Comeca a montar as linhas dos Produtos
	// ###############################################
	If ValType( aDados ) == "A" .And. Len( aDados ) > 0

		// Linha em branco
		cHtml += '<tr bgcolor="#FFFFFF">'
		cHtml += '<td colspan="16" text="white" > <br> </td>'
		cHtml += '</tr>'

		cHtml += '<tr bgcolor="#8DB6CD">'

		// Imprime os titulos das colunas
		For nPos := 1 To Len( aDados[1] )
			cHtml += '<td align=center><b>' + aDados[ 1, nPos, 1 ] + '</b></td>'
		Next
		cHtml += '</tr>'

		// Imprime os dados
		For nPos := 1 To Len( aDados )

			// Numeros pares coloca cor no fundo
			If Mod( nPos, 2 ) <> 0
				cHtml += '<tr >'
			Else
				cHtml += '<tr bgcolor="#F3F3F3" >'
			EndIf

			For nReg := 1 To Len( aDados[ nPos ] )

				If ValType( aDados[ nPos, nReg, 2 ] ) == "C"
					cHtml += '<td align=center > ' + aDados[ nPos, nReg, 2 ] + '</td>'
				Else
					cHtml += '<td align=center > ' + Transform( aDados[ nPos, nReg, 2 ], aDados[ nPos, nReg, 3 ] ) + '</td>'
				EndIf

			Next
			cHtml += '</tr>'

		Next

	EndIf

	cHtml += '</table>'
	cHtml += '</body>' + CRLF
	cHtml += '</html>' + CRLF

	cHtml += '<br><br><br>'
//	cHtml += 'Processado pelo usuário: ' + AllTrim( UsrRetName( RetCodUsr() ) ) + '.'
//	cHtml += '<br> '
//	cHtml += '<br> '
	cHtml += 'Não é necessário responder este e-mail.'
	cHtml += '<br> '
	cHtml += 'Processado em ' + DtoC( dDataBase ) + ' às ' + Time() + ' hr '
	cHtml += '<br> '

	Memowrit( "A710SndMail.html", cHtml )

	// conectando-se com o servidor de e-mail
	CONNECT SMTP SERVER cServer ACCOUNT cUser PASSWORD cPass RESULT lResult

	// fazendo autenticacao
	If lResult .And. lAuth
		lResult := MailAuth(cUser,cPass)
		If !lResult .And. Upper( cTipoLib ) <> "V"
			lResult := QADGetMail() // Funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
		EndIf
		If !lResult
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			conout( "A710SndMail - Erro no envio de e-mail da Carta de Negocios. Erro: " + cError )
			Return Nil
		Endif
	Else
		If !lResult
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			conout( "A710SndMail - Erro no envio de e-mail da Carta de Negocios. Erro: " + cError )
			Return Nil
		Endif
	EndIf

	SEND MAIL FROM cUser ;
		TO cDest;
		SUBJECT 'Carta de Negócios Nr ' + ZAN->ZAN_CODCAR + '';
		BODY cHtml;
		RESULT lResult

	If ! lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		conout( "A710SndMail - Erro no envio de e-mail da Reserva de Carta de Negocio. Erro: " + cError )
	EndIf

	DISCONNECT SMTP SERVER

Return



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IMD710Imp   ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Importar uma Carta de Negocios  									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_IMD710Imp()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function IMD710Imp()

	Local cArq := ""
	Local nHdl := 0

	cArq := cGetFile( "Arquivo CSV | *.csv", "Selecione um arquivo", 2, "C:\", .T.,,, .T. )

	If Empty( cArq )
		Return()
	EndIf

	nHdl := fopen( cArq )

	If nHdl == NIL .Or. nHdl <= 0
		MsgStop( "Não foi possível abrir o arquivo " + cArq + ". O arquivo pode estar sendo utilizado por outro usuário.", "Carta de Negócios" )
	Else
		Processa( {|| ZAN->( A710LeArq( @cArq, @nHdl ) ) }, "Aguarde", "Lendo arquivo " + cArq )
	EndIf

	fClose( nHdl )

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ A710LeArq   ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a importacao do arquivo de Carta de Negocios       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A710LeArq()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function A710LeArq( cArq, nHdl )

	Local nLinha       := 0
	Local nTamFile     := 0
	Local nPosBufCRLF  := 0
	Local nPosCRLF     := 0
	Local nQtdeItem    := 0
	Local nPercDesc    := 0
	/////INCLUIDO POR JULIO EM 31/10/2011
	////SOLICITACAO DA ROSI
	Local nFobPrg      := 0
	///////////////////////////
	Local nPreco       := 0
	Local nMargem      := 0
	Local nP_Item      := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_ITEM"   } )
	Local nP_CodPro    := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_CODPRO" } )
	Local nP_DescPro   := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_DESCRI" } )
	Local nP_CodIte    := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_CODITE" } )
	Local nP_Quant     := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_QUANT"  } )
	Local nP_Marca     := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_MARCA"  } )
	Local nP_Grupo     := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_GRUPO"  } )
	Local nP_Grupo1    := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_GRPMA1" } )
	Local nP_Grupo2    := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_GRPMA2" } )
	Local nP_Grupo3    := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_GRPMA3" } )
	Local nP_SGrupo1   := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_SGRB1"  } )
	Local nP_SGrupo2   := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_SGRB2"  } )
	Local nP_SGrupo3   := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_SGRB3"  } )
	Local nP_PercDes   := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_PERCDE" } )
	///Incluido por Julio Jacovenko em 31/10/2011
	///por solicitação da Rosi
	Local nP_FOBPRG     := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_FOBPRG"  } )

	Local nP_Preco     := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_PRECO"  } )
	Local nP_Moeda     := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_MOEDA"  } )
	Local nP_Margem    := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_MARGEM" } )
	Local nP_ObsTpEst  := Ascan( aHeader, {|x| AllTrim( x[ 2 ] ) == "ZAO_OBSTPE" } )
	Local cCabecalho   := ""
	Local cInf         := ""
	Local cLinha       := ""
	Local cBuffer      := ""
	Local cDelimitador := ""
	Local cCabecalho   := Upper( "CODIGO DO PRODUTO|CÓDIGO DO PRODUTO" )
	Local cCodProd     := ""
	Local cDescProd    := ""
	Local cCodItem     := ""
	Local cMarca       := ""
	Local cGrupo       := ""
	Local cGrupo1      := ""
	Local cGrupo2      := ""
	Local cGrupo3      := ""
	Local cSubGrupo1   := ""
	Local cSubGrupo2   := ""
	Local cSubGrupo3   := ""
	Local cMoeda       := ""
	Local cObsTPEst    := ""
	Local cDescErro    := ""
	Local lAchouCabec  := .F.
	Local lPosiSB1     := .F.

	// Busca o tamanho do arquivo
	nTamFile := fSeek( nHdl, 0, 2 )

	// Posiciona no inicio da linha
	fSeek( nHdl, 0, 0 )

	// Coloca todo o arquivo na memoria
	cBuffer := Space( nTamFile )
	fRead( nHdl, @cBuffer, nTamFile )

	// Procura por delimitador
	cDelimitador := ""
	If At( ";", cBuffer ) > 0
		cDelimitador := ";"
	EndIf

	// Retira as aspas
	cBuffer := AllTrim( Replace( cBuffer, '"', "" ) )

	// Substitui a quebra de linha pelo delimitador. Para separar as informacoes
	//cBuffer := AllTrim( Replace( cBuffer, CRLF, cDelimitador ) )

	If Empty( cDelimitador )

		MsgInfo( 'Problemas na estrutura do arquivo: " ' + cArq  + ' "' + Chr( 13 ) +;
			'Não foi encontrado o delimitador " ; " ' + Chr( 13 ) + "" + Chr( 13 ) +;
			'Processamento cancelado.' )
		cBuffer := ""
	EndIf

	DBSelectArea( "SB1" )
	DbSetOrder( 1 )

	// Tamanho do arquivo
	ProcRegua( nTamFile )

	lAchouCabec := .F.
	// Fica em loop lendo o arquivo enquanto existir alguma informacao
	While !Empty( cBuffer )

		nLinha++

		// Busca o final de linha
		nPosBufCRLF := At( CRLF, cBuffer )
		nPosCRLF    := nPosBufCRLF

		// Pega o que estiver do inicio ateh o final da linha
		cLinha := SubStr( cBuffer, 1, nPosCRLF - 1 )

		//MsgInfo( cLinha + Chr(13) + "Len( cBuffer ) " + cValToChar( Len( cBuffer ) ) )

		// Busca a informacao
		cInf := SubStr( cBuffer, 1, At( cDelimitador, cBuffer ) -1 )

		// Se achou o Cabecalho, entao deve comecar a ler as linhas, pois apartir de agora tem conteudo
		If !lAchouCabec .And. Upper( cInf ) $ cCabecalho
			lAchouCabec := .T.
		EndIf

		// Depois de ter descoberto o cabecalho, soh comeca a ler as linhas que interessa
		//If ( lAchouCabec .And. !Empty( cInf ) .And. ( !Upper( cInf ) $ cCabecalho ) )
		If ( lAchouCabec .And. ( !Upper( cInf ) $ cCabecalho ) )

			// Busca o final de linha
			nPosCRLF := At( CRLF, cBuffer )

			// Leio novamente toda a linha de DADOS
			cLinha := SubStr( cBuffer, 1, nPosCRLF - 1 )


			// ######################
			// CODIGO DO PRODUTO
			// ######################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			cCodProd  := AllTrim( SubStr( cLinha, 1, nPosDelimi-1 ) )
        	// Tenta localizar o Produto
			If !Empty( cCodProd )
				cCodProd  := PadL( AllTrim( SubStr( cLinha, 1, nPosDelimi-1 ) ), 8, "0" )

				If SB1->( DbSeek( xFilial( "SB1" ) + cCodProd ) )
					lPosiSB1 := .T.
				Else
					lPosiSB1 := .F.
					cDescErro += "Código do Produto informado não é válido." + Chr(13 ) + ""
				EndIf
			EndIf

        	// Retiro o que jah foi lido
			cLinha    := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


			// #########################
			// DESCRICAO
			// #########################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			cDescProd  := UPPER( AllTrim( SubStr( cLinha, 1, nPosDelimi-1 ) ) )

        	// Retiro o que jah foi lido
			cLinha    := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


			// ########################################
			// COD. ITEM
			// ########################################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			cCodItem   := UPPER( AllTrim( SubStr( cLinha, 1, nPosDelimi-1 ) ) )

        	// Retiro o que jah foi lido
			cLinha     := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


			// ########################################
			// QUANTIDADE
			// ########################################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			nQtdeItem  := Val( SubStr( cLinha, 1, nPosDelimi-1 ) )

			If nQtdeItem < 0
				cDescErro += "Quantidade informada não é válida." + Chr(13 ) + ""
			EndIf

        	// Retiro o que jah foi lido
			cLinha     := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


			// ########################################
			// MARCA
			// ########################################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			cMarca     := UPPER( AllTrim( SubStr( cLinha, 1, nPosDelimi-1 ) ) )

			If !Empty( cMarca ) .And. Empty( Posicione( "ZZW", 1, xFilial( "ZZW" ) + cMarca, "ZZW_DESCRI" ) )
				cDescErro += "Marca informada não é válida." + Chr(13 ) + ""
			EndIf

        	// Retiro o que jah foi lido
			cLinha     := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


			// ########################################
			// GRUPO
			// ########################################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			cGrupo     := AllTrim( SubStr( cLinha, 1, nPosDelimi-1 ) )

			If !Empty( cGrupo )

				cGrupo := PadL( cGrupo, 4, "0" )
				DbSelectArea( "SBM" )
				DbSetOrder( 1 )
				If !DbSeek( xFilial( "SBM" ) + cGrupo )
					cDescErro += "Grupo informado não é válido." + Chr(13 ) + ""
				EndIf
			EndIf

        	// Retiro o que jah foi lido
			cLinha     := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


			// ########################################
			// GRUPO 1
			// ########################################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			cGrupo1    := AllTrim( SubStr( cLinha, 1, nPosDelimi-1 ) )

			If !Empty( cGrupo1 )
				cGrupo1 := PadL( cGrupo1, 6, "0" )
				If Empty( Posicione( "SX5", 1, xFilial( "SX5" ) + "Z6" + cGrupo1, "X5_DESCRI" ) )
					cDescErro += "Grupo 1 informado não é válido." + Chr(13 ) + ""
				EndIf
			EndIf

        	// Retiro o que jah foi lido
			cLinha     := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


 			// ########################################
			// GRUPO 2
			// ########################################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			cGrupo2    := AllTrim( SubStr( cLinha, 1, nPosDelimi-1 ) )

			If !Empty( cGrupo2 )
				cGrupo2 := PadL( cGrupo2, 6, "0" )
				If Empty( Posicione( "SX5", 1, xFilial( "SX5" ) + "Z7" + cGrupo2, "X5_DESCRI" ) )
					cDescErro += "Grupo 2 informado não é válido." + Chr(13 ) + ""
				EndIf
			EndIf

        	// Retiro o que jah foi lido
			cLinha     := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


			// ########################################
			// GRUPO 3
			// ########################################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			cGrupo3    := AllTrim( SubStr( cLinha, 1, nPosDelimi-1 ) )

			If !Empty( cGrupo3 )
				cGrupo3 := PadL( cGrupo3, 6, "0" )
				If Empty( Posicione( "SX5", 1, xFilial( "SX5" ) + "Z8" + cGrupo3, "X5_DESCRI" ) )
					cDescErro += "Grupo 3 informado não é válido." + Chr(13 ) + ""
				EndIf
			EndIf

        	// Retiro o que jah foi lido
			cLinha     := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


			// ########################################
			// SUB GRUPO 1
			// ########################################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			cSubGrupo1 := AllTrim( SubStr( cLinha, 1, nPosDelimi-1 ) )

			If !Empty( cSubGrupo1 )
				cSubGrupo1 := PadL( cSubGrupo1, 6, "0" )
				If Empty( Posicione( "SZA", 1, xFilial( "SZA" ) + cSubGrupo1, "ZA_DESC" ) )
					cDescErro += "Sub Grupo 1 informado não é válido." + Chr(13 ) + ""
				EndIf
			EndIf

        	// Retiro o que jah foi lido
			cLinha     := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


			// ########################################
			// SUB GRUPO 2
			// ########################################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			cSubGrupo2 := AllTrim( SubStr( cLinha, 1, nPosDelimi-1 ) )

			If !Empty( cSubGrupo2 )
				cSubGrupo2 := PadL( cSubGrupo2, 6, "0" )
				If Empty( Posicione( "SZB", 1, xFilial( "SZB" ) + cSubGrupo2, "ZB_DESC" ) )
					cDescErro += "Sub Grupo 2 informado não é válido." + Chr(13 ) + ""
				EndIf
			EndIf

        	// Retiro o que jah foi lido
			cLinha     := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


			// ########################################
			// SUB GRUPO 3
			// ########################################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			cSubGrupo3 := AllTrim( SubStr( cLinha, 1, nPosDelimi-1 ) )

			If !Empty( cSubGrupo3 )
				cSubGrupo3 := PadL( cSubGrupo3, 6, "0" )
				If Empty( Posicione( "SZC", 1, xFilial( "SZC" ) + cSubGrupo3, "ZC_DESC" ) )
					cDescErro += "Sub Grupo 3 informado não é válido." + Chr(13 ) + ""
				EndIf
			EndIf

        	// Retiro o que jah foi lido
			cLinha     := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


			// ########################################
			// PERC DESC
			// ########################################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			nPercDesc  := Val( StrZero( Val( Replace( Replace( SubStr( cLinha, 1, nPosDelimi-1 ), ".", "" ), ",", "." ) ), 9, 2 ) )

			If nPercDesc < 0
				cDescErro += "Percentual de Desconto informado não é válido." + Chr(13 ) + ""
			EndIf

        	// Retiro o que jah foi lido
			cLinha     := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


       		//////////////////////////////////////////////
       		////Incluido pelo Julio Jacovenko, 31/10/2011
       		////solicitacao da Rosi                 /////
			// ##########################################
			// FOB PRG	                               //
			// ##########################################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )
			nFobPrg    := Val( StrZero( Val( Replace( Replace( SubStr( cLinha, 1, nPosDelimi-1 ), ".", "" ), ",", "." ) ), 9, 4 ) )
        	// Retiro o que jah foi lido
			cLinha     := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )
       		/////////////////////////////////////////////


			// ########################################
			// PRECO
			// ########################################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			nPreco     := Val( StrZero( Val( Replace( Replace( SubStr( cLinha, 1, nPosDelimi-1 ), ".", "" ), ",", "." ) ), 9, 4 ) )

			If nPreco < 0
				cDescErro += "Preço de Desconto informado não é válido." + Chr(13 ) + ""
			EndIf

        	// Retiro o que jah foi lido
			cLinha     := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


			// ########################################
			// MOEDA
			// ########################################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			cMoeda     := SubStr( cLinha, 1, nPosDelimi-1 )

			If Empty( cMoeda )
				cMoeda := "1"
			Else
	        	// Pode ser Real ou Dolar, mas o default eh o Real
				cMoeda := AllTrim( Upper( cMoeda ) )

				If ( ! cMoeda $ "1_2_R_D_REAL_DOLAR" )
					cDescErro += "Moeda informada não é válida." + Chr(13 ) + ""
				Else
					cMoeda := Replace( Replace( Replace( Replace( cMoeda, "R", "1" ), "D", "2" ), "REAL", "1" ), "DOLAR", "2" )
				EndIf
			EndIf

        	// Retiro o que jah foi lido
			cLinha     := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


			// ########################################
			// MARGEM
			// ########################################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			nMargem    := Val( StrZero( Val( Replace( Replace( SubStr( cLinha, 1, nPosDelimi-1 ), ".", "" ), ",", "." ) ), 9, 4 ) )

			If nMargem < 0
				cDescErro += "Margem informado não é válido." + Chr(13 ) + ""
			EndIf

        	// Retiro o que jah foi lido
			cLinha     := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


			// ########################################
			// OBS TIPO EST
			// ########################################
			// Apartir do conteudo da linha, vou buscando os delimitadores de informacoes
			nPosDelimi := At( cDelimitador, cLinha )
			If nPosDelimi <= 0
				nPosDelimi := Len( AllTrim( cLinha ) )
			EndIf

        	// Vou lendo tudo o que tem na linha para pegar cada informacao
			cObsTPEst  := UPPER( AllTrim( SubStr( cLinha, 1, nPosDelimi-1 ) ) )

        	// Retiro o que jah foi lido
			cLinha     := AllTrim( SubStr( cLinha, nPosDelimi11+1 ) )


			// ####################################################
			// CARREGA AS INFORMACOES NA TELA
			// ####################################################

			// Se alguma dessas posicoes estiverem com algum conteudo, cria outra posicao no array
			If (	!Empty( aCols[ N, nP_CodPro ] ) .Or. !Empty( aCols[ N, nP_DescPro ] ) .Or. !Empty( aCols[ N, nP_CodIte ] ) .Or.;
					aCols[ N, nP_Quant ] > 0        .Or. !Empty( aCols[ N, nP_Marca   ] ) .Or. !Empty( aCols[ N, nP_Grupo  ] ) .Or.;
					!Empty( aCols[ N, nP_Grupo1 ] ) .Or. !Empty( aCols[ N, nP_Grupo2  ] ) .Or. !Empty( aCols[ N, nP_Grupo3 ] ) .Or.;
					!Empty( aCols[ N, nP_SGrupo1] ) .Or. !Empty( aCols[ N, nP_SGrupo2 ] ) .Or. !Empty( aCols[ N, nP_SGrupo3] ) )

				AADD( aCols, Array( Len( aHeader )+1 ) )
				N := Len( aCols )

				aCols[ N, Len( aHeader )+1 ] := .F.
				nPIni := N+1
				oGetD:oBrowse:nAt := N

				M->ZAO_ITEM := StrZero( N, Len( ZAO->ZAO_ITEM ) )
				aCols[ N, nP_Item ] := M->ZAO_ITEM
				GDFieldPut( "ZAO_ITEM", M->ZAO_ITEM, N )
			EndIf

			M->ZAO_CODPRO := PadR( cCodProd, Len( ZAO->ZAO_CODPRO ), " " )
			aCols[ N, nP_CodPro ]	:= M->ZAO_CODPRO
			GDFieldPut( "ZAO_CODPRO", M->ZAO_CODPRO, N )

			M->ZAO_DESCRI := PadR( cDescProd, Len( ZAO->ZAO_DESCRI ), " " )
			aCols[ N, nP_DescPro ]	:= M->ZAO_DESCRI
			GDFieldPut( "ZAO_DESCRI", M->ZAO_DESCRI, N )

			M->ZAO_CODITE := PadR( cCodItem, Len( ZAO->ZAO_CODITE ), " " )
			aCols[ N, nP_CodIte ]	:= M->ZAO_CODITE
			GDFieldPut( "ZAO_CODITE", M->ZAO_CODITE, N )

			M->ZAO_QUANT := nQtdeItem
			aCols[ N, nP_Quant ]	:= M->ZAO_QUANT
			GDFieldPut( "ZAO_QUANT", M->ZAO_QUANT, N )

			M->ZAO_MARCA := PadR( cMarca, Len( ZAO->ZAO_MARCA ), " " )
			aCols[ N, nP_Marca ]	:= M->ZAO_MARCA
			GDFieldPut( "ZAO_MARCA", M->ZAO_MARCA, N )

			M->ZAO_GRUPO := PadR( cGrupo, Len( ZAO->ZAO_GRUPO ), " " )
			aCols[ N, nP_Grupo ]	:= M->ZAO_GRUPO
			GDFieldPut( "ZAO_GRUPO", M->ZAO_GRUPO, N )

			M->ZAO_GRPMA1 := PadR( cGrupo1, Len( ZAO->ZAO_GRPMA1 ), " " )
			aCols[ N, nP_Grupo1 ]	:= M->ZAO_GRPMA1
			GDFieldPut( "ZAO_GRPMA1", M->ZAO_GRPMA1, N )

			M->ZAO_GRPMA2 := PadR( cGrupo2, Len( ZAO->ZAO_GRPMA2 ), " " )
			aCols[ N, nP_Grupo2 ]	:= M->ZAO_GRPMA2
			GDFieldPut( "ZAO_GRPMA2", M->ZAO_GRPMA2, N )

			M->ZAO_GRPMA3 := PadR( cGrupo3, Len( ZAO->ZAO_GRPMA3 ), " " )
			aCols[ N, nP_Grupo3 ]	:= M->ZAO_GRPMA3
			GDFieldPut( "ZAO_GRPMA3", M->ZAO_GRPMA3, N )

			M->ZAO_SGRB1 := PadR( cSubGrupo1, Len( ZAO->ZAO_SGRB1 ), " " )
			aCols[ N, nP_SGrupo1 ]	:= M->ZAO_SGRB1
			GDFieldPut( "ZAO_SGRB1", M->ZAO_SGRB1, N )

			M->ZAO_SGRB2 := PadR( cSubGrupo2, Len( ZAO->ZAO_SGRB2 ), " " )
			aCols[ N, nP_SGrupo2 ]	:= M->ZAO_SGRB2
			GDFieldPut( "ZAO_SGRB2", M->ZAO_SGRB2, N )

			M->ZAO_SGRB3 := PadR( cSubGrupo3, Len( ZAO->ZAO_SGRB3 ), " " )
			aCols[ N, nP_SGrupo3 ]	:= M->ZAO_SGRB3
			GDFieldPut( "ZAO_SGRB3", M->ZAO_SGRB3, N )

			M->ZAO_PERCDE := nPercDesc
			aCols[ N, nP_PercDes ]	:= M->ZAO_PERCDE
			GDFieldPut( "ZAO_PERCDE", M->ZAO_PERCDE, N )

            ////Incluido por Julio Jacovenko em 31/10/2011
            ////por solicitacao da Rosi
			M->ZAO_FOBPRG := nFobPrg
			aCols[ N, nP_FobPrg ]	:= M->ZAO_FOBPRG
			GDFieldPut( "ZAO_FOBPRG", M->ZAO_FOBPRG, N )



			M->ZAO_PRECO := nPreco
			aCols[ N, nP_Preco ]	:= M->ZAO_PRECO
			GDFieldPut( "ZAO_PRECO", M->ZAO_PRECO, N )

			M->ZAO_MOEDA := cMoeda
			aCols[ N, nP_Moeda ]	:= M->ZAO_MOEDA
			GDFieldPut( "ZAO_MOEDA", M->ZAO_MOEDA, N )

			M->ZAO_MARGEM := nMargem
			aCols[ N, nP_Margem ]	:= M->ZAO_MARGEM
			GDFieldPut( "ZAO_MARGEM", M->ZAO_MARGEM, N )

			M->ZAO_OBSTPE := PadR( cObsTPEst, Len( ZAO->ZAO_OBSTPE ), " " )
			aCols[ N, nP_ObsTpEst ]	:= M->ZAO_OBSTPE
			GDFieldPut( "ZAO_OBSTPE", M->ZAO_OBSTPE, N )


			// ############################################################################################
			// CASO TEVE ALGUM PROBLEMA, INFORMA O ERRO E CARREGA A INFORMACAO DEIXANDO A LINHA DELETADA
			// ############################################################################################
			If !Empty( cDescErro )
				MsgInfo( "Inconsistências no item " + StrZero( N, Len( ZAO->ZAO_ITEM ) ) + ": " + Chr(13) +;
					AllTrim( cDescErro ), "Carta de Negócios" )
				cDescErro := ""
				aCols[ N, Len( aHeader )+1 ] := .T.
			EndIf

		EndIf

		// O que jah foi lido desconsidera
		cBuffer := AllTrim( SubStr( cBuffer, nPosBufCRLF+2 ) )
	EndDo

	// Se tiver mais do que um registro, fica posicionado no primeiro
	If Len( aCols ) > 1
		N := 1
		oGetD:oBrowse:nAt := N
	EndIf

Return



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ A710Carta   ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a validacao dos dador da Carta com o Atendimento   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_A710Carta()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ TRUE se a Carta esta Aprovada ou FALSE                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function A710Carta( aCarta, aProdCarta, aAvalCom, lB2B )

	Local cQuery    := ""
	Local cCodCarta := ""
	Local cAlcVend  := ""
	Local aArea     := GetArea()
	Local lOk       := .F.
	Local lOkItem   := .F.
	Local nOkItens  := 0
	Local nProd     := 0
	Local nPos      := 0
	Local nTotReg   := 0
	Local nReg      := 1
	Local nCotDolar := 0
	Local nPreco    := 0

	cQuery := "SELECT * "
	cQuery += "	 FROM " + RetSqlName( "ZAN" ) + " "
	cQuery += "	WHERE D_E_L_E_T_ = ' ' "
	cQuery += "	  AND ZAN_FILIAL = '" + aCarta[ POS_FILIAL ] + "' "
	cQuery += "	  AND ZAN_CARAPR = 'S' "
	cQuery += "	  AND ( " + DtoS( dDataBase ) + " >= ZAN_INIVAL AND " + DtoS( dDataBase ) + " <= ZAN_FIMVAL ) "

	cQuery += "	  AND ( TRIM( ZAN_CONDPG ) IS NULL OR ZAN_CONDPG  = '" + aCarta[ POS_CONDPG ] + "') "
	cQuery += "	  AND ( ZAN_PRAZOM = 0             OR ZAN_PRAZOM  = " + cValToChar( Posicione( "SE4", 1, xFilial( "SE4" ) + aCarta[ POS_CONDPG ], "E4_PRZMED" ) ) + " ) "

	If aCarta[ POS_PRECO_CARTA ] > 0
		cQuery += "	AND ( ZAN_PRECO = 0             OR ZAN_PRECO  <= " + cValToChar( aCarta[ POS_PRECO_CARTA ] ) + " ) "
	EndIf

	If aCarta[ POS_PER_DES_FILIAL ] > 0
		cQuery += "	AND ( ZAN_PDEFIL = 0            OR ZAN_PDEFIL >= " + cValToChar( aCarta[ POS_PER_DES_FILIAL ] ) + " ) "
	EndIf

	cQuery += "	AND ( TRIM( ZAN_TPFRET ) IS NULL   OR ZAN_TPFRET  = '" + aCarta[ POS_FRETE ] + "'  ) "

	If aCarta[ POS_COM_CLIENTE ] > 0
		cQuery += " AND ( ZAN_COMISS = 0            OR ZAN_COMISS >= " + cValToChar( aCarta[ POS_COM_CLIENTE ] ) + " ) "
	EndIf

	If aCarta[ POS_MARGEM_CARTA ] > 0
		cQuery += " AND ( ZAN_MARGEM = 0            OR ZAN_MARGEM <= " + cValToChar( aCarta[ POS_MARGEM_CARTA ] ) + " ) "
	EndIf

	If !Empty( aCarta[ POS_SEGMENTO_CLIENTE ] )
		cQuery += " AND ( TRIM( ZAN_SEGMEN ) IS NULL OR ZAN_SEGMEN  = '" + aCarta[ POS_SEGMENTO_CLIENTE ] + "' ) "
	EndIf

	If !Empty( aCarta[ POS_GRPSEGMENTO_CLIENTE ] )
		cQuery += " AND ( TRIM( ZAN_GRPSEG ) IS NULL OR ZAN_GRPSEG  = '" + aCarta[ POS_GRPSEGMENTO_CLIENTE ] + "' ) "
	EndIf

	If !Empty( aCarta[ POS_ATIVIDADE_CLIENTE ] )
		cQuery += " AND ( TRIM( ZAN_ATIVID ) IS NULL OR ZAN_ATIVID  = '" + aCarta[ POS_ATIVIDADE_CLIENTE ] + "' ) "
	EndIf

	If !Empty( aCarta[ POS_CNAE_CLIENTE ] )
		cQuery += " AND ( TRIM( ZAN_CNAE   ) IS NULL OR ZAN_CNAE    = '" + aCarta[ POS_CNAE_CLIENTE ] + "' ) "
	EndIf

	If !Empty( aCarta[ POS_MICROREGIAO_CLIENTE ] )
		cQuery += " AND ( TRIM( ZAN_MICREG ) IS NULL OR ZAN_MICREG  = '" + aCarta[ POS_MICROREGIAO_CLIENTE ] + "' ) "
	EndIf

	If !Empty( aCarta[ POS_MESOREGIAO_CLIENTE ] )
		cQuery += " AND ( TRIM( ZAN_MESREG ) IS NULL OR ZAN_MESREG  = '" + aCarta[ POS_MESOREGIAO_CLIENTE ] + "' ) "
	EndIf

	If !Empty( aCarta[ POS_REGIAO_CLIENTE ] )
		cQuery += " AND ( TRIM( ZAN_REGIAO ) IS NULL OR ZAN_REGIAO  = '" + aCarta[ POS_REGIAO_CLIENTE ] + "' ) "
	EndIf

	If !Empty( aCarta[ POS_MUN_CLIENTE ] )
		cQuery += " AND ( TRIM( ZAN_MUNCLI ) IS NULL OR TRIM( ZAN_MUNCLI ) = '" + AllTrim( aCarta[ POS_MUN_CLIENTE ] ) + "' ) "
	EndIf

	If !Empty( aCarta[ POS_UF_CLIENTE ] )
		cQuery += " AND ( TRIM( ZAN_UFCLI  ) IS NULL OR ZAN_UFCLI   = '" + aCarta[ POS_UF_CLIENTE ] + "' ) "
	EndIf

	If !Empty( aCarta[ POS_CLIENTE ] )
		cQuery += " AND ( TRIM( ZAN_CODCLI ) IS NULL OR ZAN_CODCLI  = '" + aCarta[ POS_CLIENTE ] + "' ) "
	EndIf

	If !Empty( aCarta[ POS_LOJA ] )
		cQuery += " AND ( TRIM( ZAN_LOJCLI ) IS NULL OR ZAN_LOJCLI  = '" + aCarta[ POS_LOJA ] + "' ) "
	EndIf

	If aCarta[ POS_PERC_DESCONTO_CLIENTE ] > 0
		cQuery += " AND ( ZAN_PDECLI = 0             OR ZAN_PDECLI >= " + cValToChar( aCarta[ POS_PERC_DESCONTO_CLIENTE ] ) + " ) "
	EndIf

	cQuery += " AND ( TRIM( ZAN_CARGO ) IS NULL OR ZAN_CARGO  = '" + aCarta[ POS_CARGO ] + "' ) "

	cQuery += " AND ( TRIM( ZAN_TPVINC ) IS NULL OR ZAN_TPVINC  = '" + aCarta[ POS_VINCULO_CLIENTE ] + "' ) "

	/* #########################################
		Estrutura de Vendas - Vendedor Interno
	############################################  */
	cQuery += " AND ( TRIM( ZAN_CODVI ) IS NULL    OR ZAN_CODVI   = '" + aCarta[ POS_VEND_VI     ] + "' ) "
	cQuery += " AND ( ZAN_PDVI = 0                 OR ZAN_PDVI   >=  " + cValToChar( aCarta[ POS_DESCONTO_VI ] ) + "  ) "
	cQuery += " AND ( ZAN_PCVI = 0                 OR ZAN_PCVI   >=  " + cValToChar( aCarta[ POS_COMISSAO_VI ] ) + "  ) "

	/* #########################################
		Estrutura de Vendas - Vendedor Externo
	############################################  */
	cQuery += " AND ( TRIM( ZAN_CODVE ) IS NULL    OR ZAN_CODVE   = '" + aCarta[ POS_VEND_VE     ] + "' ) "
	cQuery += " AND ( ZAN_PDVE = 0                 OR ZAN_PDVE   >=  " + cValToChar( aCarta[ POS_DESCONTO_VE ] ) + "  ) "
	cQuery += " AND ( ZAN_PCVE = 0                 OR ZAN_PCVE   >=  " + cValToChar( aCarta[ POS_COMISSAO_VE ] ) + "  ) "

	/* #########################################
		Estrutura de Vendas - Gestor de Contas
	############################################  */
	cQuery += " AND ( TRIM( ZAN_CODGC ) IS NULL    OR ZAN_CODGC   = '" + aCarta[ POS_VEND_GC     ] + "' ) "
	cQuery += " AND ( ZAN_DESGC = 0                OR ZAN_DESGC  >=  " + cValToChar( aCarta[ POS_DESCONTO_GC ] ) + "  ) "
	cQuery += " AND ( ZAN_COMGC = 0                OR ZAN_COMGC  >=  " + cValToChar( aCarta[ POS_COMISSAO_GC ] ) + "  ) "

	/* #########################################
		Estrutura de Vendas - Gerente
	############################################  */
	cQuery += " AND ( TRIM( ZAN_CODGER ) IS NULL   OR ZAN_CODGER  = '" + aCarta[ POS_VEND_GE     ] + "' ) "
	cQuery += " AND ( ZAN_DESGER = 0               OR ZAN_DESGER >=  " + cValToChar( aCarta[ POS_DESCONTO_GE ] ) + "  ) "
	cQuery += " AND ( ZAN_COMGER = 0               OR ZAN_COMGER >=  " + cValToChar( aCarta[ POS_COMISSAO_GE ] ) + "  ) "

	/* #########################################
		Estrutura de Vendas - Diretor
	############################################  */
	cQuery += " AND ( TRIM( ZAN_CODDIR ) IS NULL   OR ZAN_CODDIR  = '" + aCarta[ POS_VEND_DIR    ] + "' ) "
	cQuery += " AND ( ZAN_DESDIR = 0               OR ZAN_DESDIR >=  " + cValToChar( aCarta[ POS_DESCONTO_DIR] ) + "  ) "
	cQuery += " AND ( ZAN_COMDIR = 0               OR ZAN_COMDIR >=  " + cValToChar( aCarta[ POS_COMISSAO_DIR] ) + "  ) "


 // 	If lB2B
  //		cQuery += " AND ZAN_CODB2B  = '" + aCarta[ POS_VEND_B2B                      ] + "' "
//		cQuery += " AND ZAN_PDEB2B >=  " + cValToChar( aCarta[ POS_PERC_DENCONTO_B2B ] ) + " "
 //	EndIf

	cQuery += " ORDER BY TRIM( ZAN_CARGO ), ZAN_CODCAR "

	// Grava o usuario( Vendedor ) na consulta do Cabecalho da Carta de Negocio
	MemoWrit( "IMDA710_CABEC_" + AllTrim( SubStr( cUsuario, 7, 15 ) ) + ".sql", cQuery )
	//MemoWrit( "c:\sqlsiga\IMDA710_CABEC.sql", cQuery )

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY_ZAN",.F.,.T.)
	DbSelectArea( "QRY_ZAN" )
	cCodCarta := ""

	// Carrega em uma String todas as cartas que tem o CABECALHO valido, para depois ver os itens dessas cartas
	While QRY_ZAN->( !EOF() )

		cCodCarta += "'" + QRY_ZAN->ZAN_CODCAR + "',"

		// Caso a Carta seja para um Cargo, entao guarda o codigo da carta para ordenar pelos itens das cartas
		If QRY_ZAN->ZAN_CARGO = aCarta[ POS_CARGO ]
			cAlcVend := QRY_ZAN->ZAN_CODCAR
		EndIf

		QRY_ZAN->( DbSkip() )
	EndDo
	DbCloseArea()

	// Se nao localizou nenhuma carta, retorna False, para que o pedido fique bloqueado no comercial
	If Empty( cCodCarta )
		lOkItem := .F.
		RestArea( aArea )
		Return( lOkItem )
	EndIf

	// Retira a ultima virgula
	cCodCarta := SubStr( cCodCarta, 1, Len( cCodCarta )-1 )

	// Monta a consulta dos itens de todas as cartas com CABECALHO valido
	cQuery := "SELECT DECODE( ZAO.ZAO_CODCAR, '" + cAlcVend + "', 1, 0 ) AS ALCADA, ZAO.* "
	cQuery += "	 FROM " + RetSqlName( "ZAO" ) + " ZAO "
	cQuery += "	WHERE ZAO.D_E_L_E_T_ = ' ' "
	cQuery += "	  AND ZAO.ZAO_FILIAL = '" + aCarta[ POS_FILIAL ] + "' "
	cQuery += "	  AND ZAO.ZAO_CODCAR IN ( " + cCodCarta + " ) "
	// A ordenacao com a carta que tem alcada primeiro e depois com as outras cartas
	cQuery += " ORDER BY ALCADA DESC, ZAO.ZAO_CODCAR, ZAO.ZAO_ITEM "

	// Grava o usuario( Vendedor ) na consulta dos Itens da Carta de Negocio
	MemoWrit( "IMDA710_ITENS_" + AllTrim( SubStr( cUsuario, 7, 15 ) ) + ".sql", cQuery )
	//MemoWrit( "c:\sqlsiga\IMDA710_ITENS.sql", cQuery )

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY_ZAO",.F.,.T.)
	DbSelectArea( "QRY_ZAO" )

	Count To nTotReg
	ProcRegua( nTotReg )

	DbSelectArea( "QRY_ZAO" )
	QRY_ZAO->( DbGoTop() )

	// Irah comparar todos os Produtos de cada carta, com todos os produtos do atendimento
	While QRY_ZAO->( !EOF() )
		lOkItem  := .F.
		nOkItens := 0

		For nProd := 1 To Len( aProdCarta )
			lOkItem  := .F.

    		// Se o item esta marcado como True, entao jah foi liberado por outro item de uma carta
			If aProdCarta[ nProd, POS_ITEM_OK ]
				nOkItens++
				Loop
			EndIf

			Begin Sequence
				If !Empty( QRY_ZAO->ZAO_CODPRO )
					If AllTrim( QRY_ZAO->ZAO_CODPRO ) == AllTrim( aProdCarta[ nProd, POS_PRODUTO ] )
						lOkItem := .T.
					Else
						lOkItem := .F.
						Break
					EndIf
				EndIf

				If !Empty( QRY_ZAO->ZAO_DESCRI )
					If AllTrim( QRY_ZAO->ZAO_DESCRI ) == AllTrim( aProdCarta[ nProd, POS_DESC ] )
						lOkItem := .T.
					Else
						lOkItem := .F.
						Break
					EndIf
				EndIf

				If !Empty( QRY_ZAO->ZAO_CODITE )
					If AllTrim( QRY_ZAO->ZAO_CODITE ) == AllTrim( aProdCarta[ nProd, POS_CODITE ] )
						lOkItem := .T.
					Else
						lOkItem := .F.
						Break
					EndIf
				EndIf

				If QRY_ZAO->ZAO_QUANT > 0
					// Quantidade minima do produto foi atingida, pode ser que irah aprovadar
					If QRY_ZAO->ZAO_QUANT <= aProdCarta[ nProd, POS_QUANT ]
						lOkItem := .T.
					Else
						lOkItem := .F.
						Break
					EndIf
				EndIf

				If !Empty( QRY_ZAO->ZAO_MARCA )
					If AllTrim( QRY_ZAO->ZAO_MARCA ) == AllTrim( aProdCarta[ nProd, POS_MARCA ] )
						lOkItem := .T.
					Else
						lOkItem := .F.
						Break
					EndIf
				EndIf

				If !Empty( QRY_ZAO->ZAO_GRUPO )
					If AllTrim( QRY_ZAO->ZAO_GRUPO ) == AllTrim( aProdCarta[ nProd, POS_GRUPO ] )
						lOkItem := .T.
					Else
						lOkItem := .F.
						Break
					EndIf
				EndIf

				If !Empty( QRY_ZAO->ZAO_GRPMA1 )
					If AllTrim( QRY_ZAO->ZAO_GRPMA1 ) == AllTrim( aProdCarta[ nProd, POS_GRPMA1 ] )
						lOkItem := .T.
					Else
						lOkItem := .F.
						Break
					EndIf
				EndIf

				If !Empty( QRY_ZAO->ZAO_GRPMA2 )
					If AllTrim( QRY_ZAO->ZAO_GRPMA2 ) == AllTrim( aProdCarta[ nProd, POS_GRPMA2 ] )
						lOkItem := .T.
					Else
						lOkItem := .F.
						Break
					EndIf
				EndIf

				If !Empty( QRY_ZAO->ZAO_GRPMA3 )
					If AllTrim( QRY_ZAO->ZAO_GRPMA3 ) == AllTrim( aProdCarta[ nProd, POS_GRPMA3 ] )
						lOkItem := .T.
					Else
						lOkItem := .F.
						Break
					EndIf
				EndIf

				If !Empty( QRY_ZAO->ZAO_SGRB1 )
					If AllTrim( QRY_ZAO->ZAO_SGRB1 ) == AllTrim( aProdCarta[ nProd, POS_SRGB1 ] )
						lOkItem := .T.
					Else
						lOkItem := .F.
						Break
					EndIf
				EndIf

				If !Empty( QRY_ZAO->ZAO_SGRB2 )
					If AllTrim( QRY_ZAO->ZAO_SGRB2 ) == AllTrim( aProdCarta[ nProd, POS_SRGB2 ] )
						lOkItem := .T.
					Else
						lOkItem := .F.
						Break
					EndIf
				EndIf

				If !Empty( QRY_ZAO->ZAO_SGRB3 )
					If AllTrim( QRY_ZAO->ZAO_SGRB3 ) == AllTrim( aProdCarta[ nProd, POS_SRGB3 ] )
						lOkItem := .T.
					Else
						lOkItem := .F.
						Break
					EndIf
				EndIf

				If !Empty( QRY_ZAO->ZAO_OBSTPE )
					If AllTrim( QRY_ZAO->ZAO_OBSTPE ) == AllTrim( aProdCarta[ nProd, POS_OBS_TIPO_ESTOQUE ] )
						lOkItem := .T.
					Else
						lOkItem := .F.
						Break
					EndIf
				EndIf

				/* ######################################################
					Agora comeca a verificar os Valores do Item da Carta
				   ###################################################### */

				If QRY_ZAO->ZAO_PERCDE > 0// .And. aProdCarta[ nProd, POS_PERCENT_DESC ] > 0
					If QRY_ZAO->ZAO_PERCDE >= aProdCarta[ nProd, POS_PERCENT_DESC ]
						lOkItem := .T.
					Else
						lOkItem := .F.
						Break
					EndIf
				EndIf

				If QRY_ZAO->ZAO_MARGEM > 0 .And. aProdCarta[ nProd, POS_MARGEM ] > 0
					If QRY_ZAO->ZAO_MARGEM <= aProdCarta[ nProd, POS_MARGEM ]
						lOkItem := .T.
					Else
						lOkItem := .F.
						Break
					EndIf
				EndIf

				If QRY_ZAO->ZAO_PRECO > 0

					// Se na Carta a moeda estah cadastrada como Dolar, entao deverah ser convertido
					If QRY_ZAO->ZAO_MOEDA == "2"

						// Retorna a cotacao do Dolar do dia
						nCotDolar := RECMOEDA( dDataBase, 2 )
						// Se nao tiver a cotacao do Dolar, coloca um valor muito alto para que nao aprove o item
						nCotDolar := IIF( nCotDolar <= 0, 999999999, nCotDolar )

						nPreco := Trunc( nCotDolar * QRY_ZAO->ZAO_PRECO, 2 )
					Else
						nPreco := QRY_ZAO->ZAO_PRECO
					EndIf

					// Preco minimo informado na Carta ( Real ou Convertido ) para a liberacao comercial
					If nPreco <= aProdCarta[ nProd, POS_PRECO ]
						lOkItem := .T.
					Else
						lOkItem := .F.
						Break
					EndIf

				EndIf

			End Sequence

			If aAvalCom <> NIL .And. Len( aAvalCom ) > 0
				// Atualiza se o Produto estah ou nao aprovado, serah enviado e-mail para o vendedor informado que o Pedido nao for aprovado
				//aAdd( aAvalCom, { SUB->UB_ITEM , SUB->UB_PRODUTO , SUB->UB_VLRITEM , SUB->UB_MARGEM, lOkItem, nDescReal, SB1->B1_DESC } )
				If ( nPos := aScan( aAvalCom, { |x| x[2] == aProdCarta[ nProd, POS_PRODUTO ] } ) ) > 0
					aAvalCom[ nPos, 5 ] := lOkItem
				EndIf
			EndIf

			// Se o Item estah correto, marca o item como OK e soma a quantidade de itens
			If lOkItem
				aProdCarta[ nProd, POS_ITEM_OK ] := lOkItem
				nOkItens++
			EndIf

		Next

		IncProc( "Consultando Carta " + cValToChar( nReg ) + " de " + cValToChar( nTotReg ) )
		nReg++

		// Caso todos os itens do Pedido estao liberados por alguma carta, entao
		// nao precisa ficar olhando outras cartas... ESPERTO HEIN !?!?!?!
		If Len( aProdCarta ) == nOkItens
			Exit
		EndIf

		QRY_ZAO->( DbSkip() )
	EndDo

	If Select( "QRY_ZAO" ) <> 0
		DbSelectArea( "QRY_ZAO" )
		DbCloseArea()
	EndIf

	//lOkItem := .T.

	// Se todos os itens do Atendimento foram aprovados por alguma Carta ,
	// entao o pedido terah a liberacao comercial realizada automaticamente.
	aEval( aProdCarta, { |x| lOkItem := IIF( x[ POS_ITEM_OK ], lOkItem, .F. ) } )

	RestArea( aArea )

Return( lOkItem )




/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ A710RETAPR  ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna os Aprovadores de Carta de Negocios                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_A710RETAPR()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function A710RETAPR()

	Local aAprov  := {}
	Local aArea   := GetArea()
	Local cTabSX5 := "1Z"

	DbSelectArea( "SX5" )
	DbSeek( xFilial( "SX5" ) + cTabSX5 )
	While SX5->( !EOF() ) .And. SX5->X5_TABELA == cTabSX5

		AADD( aAprov, {	SX5->X5_CHAVE,;										// POS_COD_APR
		AllTrim( SX5->X5_DESCRI ),;						// POS_NOME_APR
		AllTrim( SX5->X5_DESCSPA ),;						// POS_PERFIL_APR
		Lower( AllTrim( SX5->X5_DESCENG ) ) } )		// POS_EMAIL_APR

		SX5->( DbSkip() )
	EndDo

	RestArea( aArea )

Return( aAprov )



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IMD710Lgd   ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Legenda do Cadastro da Carta de Negocios                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_IMD710Lgd()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±³          ³         Vizualizar, Incluir, Alterar, Excluir ou Copiar    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function ValPrMed()

	Local lRet   := .F.
	Local cQuery := ""
	Local aArea  := GetArea()

	If M->ZAN_PRAZOM <= 0
		Return( lRet )
	EndIf

	cQuery := "SELECT E4_CODIGO "
	cQuery += "	 FROM " + RetSqlName( "SE4" ) + " "
	cQuery += "	WHERE D_E_L_E_T_ = ' ' "
	cQuery += "	  AND E4_PRZMED = " + cValToChar( M->ZAN_PRAZOM ) + " "
	cQuery += "	  AND E4_MSBLQL <> '1' "

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY_SE4",.F.,.T.)
	DbSelectArea( "QRY_SE4" )

	If QRY_SE4->( !EOF() )
		lRet := .T.
	EndIf

	DbCloseArea()

	RestArea( aArea )

Return( lRet )



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IMD710Lgd   ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Legenda do Cadastro da Carta de Negocios                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_IMD710Lgd()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±³          ³         Vizualizar, Incluir, Alterar, Excluir ou Copiar    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function IMD710Lgd()

	BRWLEGENDA( CCADASTRO,"LEGENDA",{	{"BR_AZUL", "Carta fora da Validade"},;
		{"ENABLE",  "Carta Aprovada"},;
		{"DISABLE", "Carta Bloqueada"} } )

	/*
	Local aCores  := {	{ '! (ZAN_INIVAL <= dDataBase .and. dDataBase <= ZAN_FIMVAL)'                        , 'BR_AZUL' },;
					  			{ 'ZAN_CARAPR == "S" .and. ( ZAN_INIVAL <= dDataBase .and. dDataBase <= ZAN_FIMVAL )', 'ENABLE'  },;
					  			{ 'ZAN_CARAPR == "N"'                                                                , 'DISABLE' }}
	*/
Return



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IMD710Tst   ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Forca a aprovacao da Carta e envia e-mail                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_IMD710Tst()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function IMD710Tst()

	Local cCodUsu_   := AllTrim( RetCodUsr() )
	Local nAprov     := 0
	Local nPosApr    := 0
	Local lOk        := .T.
	Local aProd      := {}
	Local cPicPercDE := PesqPict( "ZAO", "ZAO_PERCDE" )
	Local cPicPreco  := PesqPict( "ZAO", "ZAO_PRECO"  )
	Local cPicMargem := PesqPict( "ZAO", "ZAO_MARGEM" )
	Local cPicQuant  := PesqPict( "ZAO", "ZAO_QUANT"  )

	For nAprov := 1 To Len( aUsuAprov )
      /*
		lOk := .T.

		// Verifica se o usuario atual jah aprovou essa carta
		For nPosApr := 1 To 5
			cCpo := "ZAN->ZAN_CODAP" + cValToChar( nPosApr )

			If cCodUsu_ == &cCpo
				lOk := .F.
				Exit
			EndIf

		Next

		// Usuario atual logado no sistema, jah aprovou a carta
		If !lOk
			Loop
		EndIf
		*/
		If RecLock( "ZAN", .F. )

			// Perfil do Aprovador eh um Diretor
			If PERFIL_DIRETOR == AllTrim( aUsuAprov[ nAprov, POS_PERFIL_APR ] )

				If Empty( ZAN->ZAN_CODAP1 )

					ZAN->ZAN_CODAP1 := aUsuAprov[ nAprov, POS_COD_APR ]
					ZAN->ZAN_DTAPR1 := DtoC( dDataBase ) + " " + Time()

				ElseIf Empty( ZAN->ZAN_CODAP2 )

					ZAN->ZAN_CODAP2 := aUsuAprov[ nAprov, POS_COD_APR ]
					ZAN->ZAN_DTAPR2 := DtoC( dDataBase ) + " " + Time()

				EndIf

			// Perfil do Aprovador eh um Usuario
			ElseIf PERFIL_USUARIO == AllTrim( aUsuAprov[ nAprov, POS_PERFIL_APR ] )

				If Empty( ZAN->ZAN_CODAP3 )

					ZAN->ZAN_CODAP3 := aUsuAprov[ nAprov, POS_COD_APR ]
					ZAN->ZAN_DTAPR3 := DtoC( dDataBase ) + " " + Time()

				ElseIf Empty( ZAN->ZAN_CODAP4 )

					ZAN->ZAN_CODAP4 := aUsuAprov[ nAprov, POS_COD_APR ]
					ZAN->ZAN_DTAPR4 := DtoC( dDataBase ) + " " + Time()

				ElseIf Empty( ZAN->ZAN_CODAP5 )

					ZAN->ZAN_CODAP5 := aUsuAprov[ nAprov, POS_COD_APR ]
					ZAN->ZAN_DTAPR5 := DtoC( dDataBase ) + " " + Time()

				EndIf

			EndIf

		Else
			MsgStop( "Existe um usuário realizando alterações nessa Carta, favor aguardar o término da alteração.", "Carta de Negócios" )
			Exit
		EndIf

		MsUnLock()

	Next

	If !Empty( ZAN->ZAN_CODAP1 ) .And. !Empty( ZAN->ZAN_CODAP2 )

		If RecLock( "ZAN", .F. )
			ZAN->ZAN_CARAPR := "S"
			MsUnLock()

			MsgInfo( "Carta Aprovada !" )

			// Faz a leitura de todos os itens para envio do e-mail
			DbSelectArea( "ZAO" )
			DbSetOrder( 1 )
			ZAO->( DbSeek( xFilial("ZAO") + ZAN->ZAN_CODCAR, .F. ) )
			While ZAO->ZAO_FILIAL + ZAO->ZAO_CODCAR == xFilial("ZAO") + ZAN->ZAN_CODCAR .And. ZAO->( !Eof()	 )

				AADD( aProd,{	{ "Codigo"				, AllTrim( ZAO->ZAO_CODPRO ), "" },;
					{ "Descrição"			, AllTrim( ZAO->ZAO_DESCRI ), "" },;
					{ "Codigo Item"		, AllTrim( ZAO->ZAO_CODITE ), "" },;
					{ "Quantidade"			, ZAO->ZAO_QUANT , cPicQuant },;
					{ "Marca"				, AllTrim( ZAO->ZAO_MARCA ), "" },;
					{ "Grupo"				, ZAO->ZAO_GRUPO , ""  },;
					{ "Grp. Marca 1"		, ZAO->ZAO_GRPMA1, "" },;
					{ "Grp. Marca 2"		, ZAO->ZAO_GRPMA2, "" },;
					{ "Grp. Marca 3"		, ZAO->ZAO_GRPMA3, "" },;
					{ "Sub Grupo 1"		, ZAO->ZAO_SGRB1 , "" },;
					{ "Sub Grupo 2"		, ZAO->ZAO_SGRB2 , "" },;
					{ "Sub Grupo 3"		, ZAO->ZAO_SGRB3 , "" },;
					{ "% Desconto"			, ZAO->ZAO_PERCDE, cPicPercDE },;
					{ "Preço"				, ZAO->ZAO_PRECO, cPicPreco },;
					{ "Moeda"				, IIF( ZAO->ZAO_MOEDA=="1","Real","Dolar"), "" },;
					{ "Margem"				, ZAO->ZAO_MARGEM, cPicMargem };
					} )

				ZAO->( DbSkip() )
			EndDo

			Processa( {|| ZAN->( U_A710SndMail( "L", aProd ) ) }, "Aguarde", "Enviando comunicado da Carta..." )

		EndIf
	EndIf

Return()



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ A710RepDes  ³ Autor ³ Jorge Oliveira     ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche o Desconto para os demais itens da Carta          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_A710RepDes()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function A710RepDes()

	Local nX          := 0
	Local cVar        := SubStr( Readvar(), 4 )
	Local lPreenchido := .F.

	// Validacao somente para a primeira linha E para ALTERACAO
	If ( N <> 1 .Or. INCLUI .Or. EXCLUI )
		Return( .T. )
	EndIf

	// Verifica se tem algum item preenchido
	for nX := (n+1) To Len( aCols )

		If GDFieldGet( cVar, nX ) > 0
			lPreenchido := .T.
			Exit
		EndIf

	Next

	// Preenche os campos
	If lPreenchido .And. MsgYesNo( "Deseja replicar o desconto para os demais itens?", "Carta de Negócios" )

		For nX := (n+1) To Len( aCols )
			GDFieldPut( cVar, &( Readvar() ), nX )
		Next

	Endif

Return( .T. )
