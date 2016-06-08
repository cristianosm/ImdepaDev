#include 'Protheus.ch'
#include "Topconn.ch"

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : IMDC040     | AUTOR : Cristiano Machado  | DATA : 07/05/2015   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Apresenta Saldos em Estoque conforme Parametros                **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente IMDEPA                               **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function ImdC041()
*******************************************************************************

// Visualiza ultimo preco de compra...
	Private lUPrcCom := .t.

	U_ImdC040()

Return()
********************************************************************************
User Function ImdC042() //| ROTINA CUSTOMIZADA PARA A AREA DE VENDAS SEM O PREÇO DE COMPRA
********************************************************************************


//| Nao visualiza ultimo preco de compra...
	Private lUPrcCom := .f.

	U_ImdC040()

Return()
********************************************************************************
User Function ImdC040( cRotina )
********************************************************************************

	Local xRet      := .t.
	Private	cPerg	:= 'IMDC04'
	Private aDados  := {}

	Private cCadastro := OemToAnsi( 'Consulta Saldo de Produtos' )

	Private aRotina  := { { 'Pesquisar' , 'AxPesqui'  , 0, 1 }, ;
		{	'Produto'   , 'U_IC040Con' , 0, 2 }, ;
		{	'Referencia', 'U_IC040Con' , 0, 3 }, ;
		{ 'Parametros', 'Pergunte( cPerg, .t. )',0 ,4 }}

//            Grupo  Ordem Pergunta Portugues     Pergunta Espanhol  Pergunta Ingles Variavel Tipo Tamanho Decimal Presel  GSC Valid Var01 Def01 DefSPA1 DefEng1 Cnt01  Var02 Def02    		 DefSpa2  DefEng2	Cnt02  Var03 Def03      DefSpa3    DefEng3  Cnt03  Var04  Def04     DefSpa4    DefEng4  Cnt04  Var05  Def05       DefSpa5	 DefEng5   Cnt05  XF3   GrgSxg
	aDados := {	{ "De Local Sld:","Local Saldo Atu/Disp","Local Saldo Atu/Disp","mv_ch1","C", 2,0,0,"G","NaoVazio()"		,"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""    }, ;
		{ "Até Local Sld:","Local Saldo Atu/Disp","Local Saldo Atu/Disp","mv_ch1","C", 2,0,0,"G","NaoVazio()"		,"MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""    }, ;
		{ "Tabela Preco Venda  ","Tabela Preco Venda  ","Tabela Preco Venda  ","mv_ch2","C", 3,0,0,"G","ExistCpo('DA0')","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","DA0","",""    }, ;
		{ "Taxa USD calc fator ","Taxa USD calc fator ","Taxa USD calc fator ","mv_ch3","N",11,4,0,"G","NaoVazio()"		,"MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"",""    } }

	AjustaSx1( cPerg, aDados )

	Pergunte( cPerg, .F. )

	If ValType( cRotina ) == 'C'

	//| Faz tratamento para chamada por outra rotina

		If !Empty( nScan := aScan( aRotina, { |x| x[2] == cRotina } ) )

			cRoda := cRotina + "( 'SB1', SB1->( Recno() ), " + Str(nScan,2) + ")"
			xRet  := Eval( { || &( cRoda ) } )
		EndIf
	Else

		mBrowse(06,01,22,75,"SB1",,,,,2,,,,)

	EndIf

Return( xRet )
********************************************************************************
User Function Ic040Con( cAlias, nReg, nOpcx )
********************************************************************************
	Local aArea	   := GetArea()
	Local aObjects := {}, aPosObj := {}
	Local aSize    := MsAdvSize()
	Local aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }

	Private oDlg, oFont
	Private oDisable		:= Loadbitmap( GetResources(), 'BR_BRANCO_MDI' ) //'LBNO' )
	Private oEnable		:= Loadbitmap( GetResources(), 'BR_VERDE_MDI' )
	Private oAzul			:= Loadbitmap( GetResources(), 'BR_AZUL_MDI' )
	Private oAmarelo		:= Loadbitmap( GetResources(), 'BR_AMARELO_MDI' )
	Private oVermelho	:= Loadbitmap( GetResources(), 'BR_VERMELHO_MDI' )
	Private oPreto			:= Loadbitmap( GetResources(), 'BR_PRETO_MDI' )
	Private oLista1, aLista1 := { { '', '', '', '', '', '', '', '', '', 0, 0, 0, 0, 0, 0 } }
	Private oLista2, aLista2 := { { '', '', '', '', 0, 0, 0, 0, 0, 0 } }
	Private cRefer 		:= If( nOpcx == 2, AllTrim( SB1->B1_COD ) + ' - ' + SB1->B1_DESC, Space( 20 ) )
	Private nRec_SM0, aFilial, cFilImd
	Private cImdepa 		:= GetMV( 'MV_IMDEPA' )
	Private aSimbMoeda	:= {}
	Private _aFilList	:= {}

	For ni := 1 to 5

		aAdd( aSimbMoeda, PadR( GetMv( 'MV_SIMB' + Str( ni, 1 ) ), 4 ) )
	Next

	aFilial	:= { {'  ', ' '} }
	cFilImd	:= "'  '"

	cFilImd	:= U_cRetFils("Q")

	nRec_SM0 := SM0->( RecNo() )

	SM0->( dbSeek( cEmpAnt, .f. ) )

	While SM0->( !EOF() ) .and. SM0->M0_CODIGO == cEmpAnt

		aAdd( aFilial, { SM0->M0_CODFIL, SM0->M0_FILIAL } )
		aAdd(_aFilList, SM0->M0_CODFIL )

		SM0->( dbSkip() )
	End

	SM0->( dbGoTo( nRec_SM0 ) )


	aAdd( aObjects, { 100, 020, .t., .f., .f. } )
	aAdd( aObjects, { 100, 100, .t., .t., .f. } )

	aPosObj := MsObjSize( aInfo, aObjects )

	Define Font oFont Name 'Courier New' Size 0,-11

	Define msDialog oDlg Title cCadastro Of oMainWnd Pixel From aSize[7], 0 To aSize[6], aSize[5]

	@ 001,aPosObj[1,2] To aPosObj[1,3], aPosObj[1,4] Of oDlg Pixel

	@ 013,325 Button OemToAnsi( '&Sair' )	Size 42,13 Font oDlg:oFont Action oDlg:End() Of oDlg Pixel

	@ 008,015 Say OemToAnsi( If( nOpcx == 2, 'Produto', 'Referencia' ) )		Size 030,7 Of oDlg Pixel

	@ 007,050 msGet oRefer Var cRefer When nOpcx == 3 Size 150,9 Of oDlg Pixel

	@ 001,225 Button OemToAnsi( '&Consultar' )	Size 42,13 Font oDlg:oFont When ( nOpcx <> 2 ) Action Processa( { || IC040Gera( nOpcx == 2 ) } ) Of oDlg Pixel
	@ 013,225 Button OemToAnsi( '&Pesquisar' )	Size 42,13 Font oDlg:oFont When ( nOpcx <> 2 .and. !Empty( aLista1[ 1, 4 ] ) ) Action PesqLista() Of oDlg Pixel

	@ 001,275 Button OemToAnsi( '&Importacao' )	Size 42,13 Font oDlg:oFont When ( !Empty( aLista1[ 1, 4 ] ) ) Action Processa( { || Import( aLista1[ oLista1:nAt, 04 ] ) } ) Of oDlg Pixel
	@ 013,275 Button OemToAnsi( 'P. &Terceiros' )	Size 42,13 Font oDlg:oFont When ( !Empty( aLista1[ 1, 4 ] ) ) Action Processa( { || PTerc( aLista1[ oLista1:nAt, 04 ] ) } ) Of oDlg Pixel

	@ 001,325 Button OemToAnsi( '&Legenda' )	Size 42,13 Font oDlg:oFont Action LegLista() Of oDlg Pixel


	@ aPosObj[2,1],aPosObj[2,2] ListBox oLista1 ;
		Fields Header  ' ',' ',' ','Codigo  ','Descricao'+Space( 20 ),'Grupo'+Space( 3 ),'UM','Última Compra','Incoterm','Prc Venda '+aSimbMoeda[1],'Fator',Space(5)+'Saldo Atual  ','Saldo Disponivel  ', 'Saldo Importacao  ', 'Saldo P. Terceiros' ;
		Size aPosObj[2,4]-3, (aPosObj[2,3]-6)/2 ;
		Of oDlg Pixel Font oFont;
		On Change( AtualLista( 2, aLista1[ oLista1:nAt, 04 ] ) )

	AtualLista( 1 )

	@ (aPosObj[2,1]+aPosObj[2,3]+40)/2,aPosObj[2,2] ListBox oLista2 ;
		Fields Header  ' ',' ',' ','Filial'+Space(5),Space(5)+'Saldo Atual  ','Saldo Disponivel  ','Saldo Imp (A Embarcar) ','Saldo Imp (Embarcado) ','Saldo Imp (Entreposto) ','Saldo P. Terceiros  ' ;
		Size aPosObj[2,4]-3, (aPosObj[2,3]-74)/2 ;
		Of oDlg Pixel Font oFont


	Activate msDialog oDlg On Init If( nOpcx == 2, Processa( { || IC040Gera( nOpcx == 2 ) } ), Nil )

	RestArea(aArea)

Return()
********************************************************************************
Static Function Ic040Gera( lProduto )
********************************************************************************
	Local cQuery := ''
	Local nPrcVen, nNumTab, aUPrCom, nI

	If !lProduto .and. Empty( cRefer )
		ApMsgInfo("Informe uma referencia para efetuar a consulta.", cCadastro+" - "+ProcName())
		Return
	EndIf

	IncProc("Calculando Saldos...")

	cQuery := "select B1_COD, B1_REFER, B1_MARCA,"
	cQuery += " sum( B2_QATU ) B2_QATU, sum( B2_RESERVA ) B2_RESERVA,"
	cQuery += " sum( B2_QPEDVEN ) B2_QPEDVEN, sum( QTDTRAN ) QTDTRAN,"
	cQuery += " sum( B6_SALDO ) B6_SALDO,  sum( SLDPO ) SLDPO, sum( SLDPROC ) SLDPROC"
	cQuery += " from ( "

// saldo atual, seleciona todos produtos, mesmo sem registro no sb2...
//cQuery += "select B1_COD, B1_REFER, B1_MARCA,"
	cQuery += "select /*+ USE_CONCAT */ B1_COD, B1_REFER, B1_MARCA,"
	cQuery += " sum( B2_QATU ) B2_QATU, sum( B2_RESERVA ) B2_RESERVA,"
	cQuery += " sum( B2_QPEDVEN ) B2_QPEDVEN,  0 QTDTRAN,"
	cQuery += " 0 B6_SALDO, 0 SLDPO, 0 SLDPROC"
	cQuery += " from " + RetSqlName( 'SB2' ) + " SB2, " + RetSqlName( 'SB1' ) + " SB1"
	cQuery += " where B1_FILIAL in (" + cFilImd + ")"

	If !lProduto
		cQuery += " and B1_REFER like '%" + AllTrim( cRefer ) + "%'"
	Else
		cQuery += " and B1_COD = '" + SB1->B1_COD + "'"
	EndIf

	cQuery += " and SB1.D_E_L_E_T_ = ' '"

	cQuery += " and B2_FILIAL (+) = B1_FILIAL"
	cQuery += " and B2_COD (+) = B1_COD"
	cQuery += " and B2_LOCAL (+) Between '" + MV_PAR01 + "' And '" + MV_PAR02 + "'"
	cQuery += " and SB2.D_E_L_E_T_ (+) = ' '"

	cQuery += " group by B1_COD, B1_REFER, B1_MARCA"
	cQuery += " union all "

// saldo em poder de terceiros, somente registros existentes...
	cQuery += "select B1_COD, B1_REFER, B1_MARCA,"
	cQuery += " 0 B2_QATU, 0 B2_RESERVA, 0 B2_QPEDVEN, 0 QTDTRAN,"
	cQuery += " sum( B6_SALDO ) B6_SALDO, 0 SLDPO, 0 SLDPROC"
	cQuery += " from " + RetSqlName( 'SB1' ) + " SB1, " + RetSqlName( 'SB6' ) + " SB6"
	cQuery += " where B1_FILIAL in (" + cFilImd + ")"

	If !lProduto
		cQuery += " and B1_REFER like '%" + AllTrim( cRefer ) + "%'"
	Else
		cQuery += " and B1_COD = '" + SB1->B1_COD + "'"
	EndIf

	cQuery += " and SB1.D_E_L_E_T_ = ' '"

	cQuery += " and B6_FILIAL = B1_FILIAL"
	cQuery += " and B6_PRODUTO = B1_COD"
	cQuery += " and B6_SALDO <> 0"
	cQuery += " and substr( B6_TES, 1, 1 ) >= '5'"
	cQuery += " and B6_TIPO = 'E'"
	cQuery += " and SB6.D_E_L_E_T_ = ' '"

	cQuery += " group by B1_COD, B1_REFER, B1_MARCA"
	cQuery += " union all "

// pedidos de alocados em planilhas de transferencia, somente registros existentes...
//cQuery += "select /*+rule*/ B1_COD, B1_REFER, B1_MARCA,"
	cQuery += "select B1_COD, B1_REFER, B1_MARCA,"
	cQuery += " 0 B2_QATU, 0 B2_RESERVA, 0 B2_QPEDVEN,  nvl( sum( C6_QTDVEN - C6_QTDENT ), 0 ) QTDTRAN,"
	cQuery += " 0 B6_SALDO, 0 SLDPO, 0 SLDPROC"
	cQuery += " from " + RetSqlName( 'SC6' ) + " SC6, " + RetSQLName("SC7") + " SC7, " + RetSQLName("SB1") + " SB1"
	cQuery += " where B1_FILIAL in (" + cFilImd + ")"

	If !lProduto
		cQuery += " and B1_REFER like '%" + AllTrim( cRefer ) + "%'"
	Else
		cQuery += " and B1_COD = '" + SB1->B1_COD + "'"
	EndIf

	cQuery += " and SB1.D_E_L_E_T_ = ' '"

	cQuery += " and C6_FILIAL = B1_FILIAL"
	cQuery += " and C6_PRODUTO = B1_COD"
	cQuery += " and C6_CLI <> '" + cImdepa + "'"
	cQuery += " and (C6_PLANILH <> ' ' OR C6_FILTRAN <> ' ')"
	cQuery += " and C6_NOTA = ' '"
	cQuery += " and SC6.D_E_L_E_T_ = ' '"

	cQuery += " and C7_FILIAL = C6_FILIAL"
	cQuery += " and C7_PLANILH = C6_PLANILH"
	cQuery += " and C7_PLITEM = C6_PLITEM"
	cQuery += " and ( C7_QUANT - C7_QUJE ) > 0"
	cQuery += " and SC7.D_E_L_E_T_ = ' '"

	cQuery += " group by B1_COD, B1_REFER, B1_MARCA"
	cQuery += " union all "

// saldo POs sem Processos, somente registros existentes...
	cQuery += "select B1_COD, B1_REFER, B1_MARCA, 0 B2_QATU, 0 B2_RESERVA,"
	cQuery += " 0 B2_QPEDVEN, 0 QTDTRAN, 0 B6_SALDO, sum( W5_SALDO_Q ) SLDPO, 0 SLDPROC"
	cQuery += " from " + RetSqlName( 'SB1' ) + " SB1, " + RetSqlName( 'SW2' ) + " SW2, "
	cQuery += RetSqlName( 'SW3' ) + " SW3, " + RetSqlName( 'SW5' ) + " SW5"
	cQuery += " where B1_FILIAL = '" + cFilAnt + "'"

	If !lProduto
		cQuery += " and B1_REFER like '%" + AllTrim( cRefer ) + "%'"
	Else
		cQuery += " and B1_COD = '" + SB1->B1_COD + "'"
	EndIf

	cQuery += " and SB1.D_E_L_E_T_ = ' '"
	cQuery += " and W2_FILIAL = '  '"
	cQuery += " and W2_HAWB_DA = ' '"
	cQuery += " and SW2.D_E_L_E_T_ = ' '"
	cQuery += " and W3_FILIAL = W2_FILIAL"
	cQuery += " and W3_PO_NUM = W2_PO_NUM"
	cQuery += " and W3_SEQ = 0"
	cQuery += " and W3_COD_I = B1_COD"
	cQuery += " and SW3.D_E_L_E_T_ = ' '"
	cQuery += " and W5_FILIAL = W3_FILIAL"
	cQuery += " and W5_PO_NUM = W3_PO_NUM"
	cQuery += " and W5_POSICAO = W3_POSICAO"
	cQuery += " and W5_SALDO_Q > 0"
	cQuery += " and W5_HAWB = ' '"
	cQuery += " and SW5.D_E_L_E_T_ = ' '"

	cQuery += " group by B1_COD, B1_REFER, B1_MARCA"
	cQuery += " union all "

// saldo Processos, somente registros existentes, sem distinguir embarcado, nao embarcado ou entreposto...
	cQuery += "select B1_COD, B1_REFER, B1_MARCA, 0 B2_QATU, 0 B2_RESERVA,"
	cQuery += " 0 B2_QPEDVEN, 0 QTDTRAN, 0 B6_SALDO, 0 SLDPO, sum( W7_SALDO_Q ) SLDPROC"
	cQuery += " from " + RetSqlName( 'SB1' ) + " SB1, " + RetSqlName( 'SW6' ) + " SW6, "
	cQuery += RetSqlName( 'SW7' ) + " SW7"
	cQuery += " where B1_FILIAL = '" + cFilAnt + "'"
	If !lProduto
		cQuery += " and B1_REFER like '%" + AllTrim( cRefer ) + "%'"
	Else
		cQuery += " and B1_COD = '" + SB1->B1_COD + "'"
	EndIf
	cQuery += " and SB1.D_E_L_E_T_ = ' '"
	cQuery += " and W6_FILIAL = '  '"
	cQuery += " and W6_DT_ENTR = '        '"
	cQuery += " and W6_TIPOFEC in ('DI ','DA ')"
	cQuery += " and SW6.D_E_L_E_T_ = ' '"
	cQuery += " and W7_FILIAL = W6_FILIAL"
	cQuery += " and W7_HAWB = W6_HAWB"
	cQuery += " and W7_SEQ = 0"
	cQuery += " and W7_COD_I = B1_COD"
	cQuery += " and SW7.D_E_L_E_T_ = ' '"
	cQuery += " group by B1_COD, B1_REFER, B1_MARCA"
	cQuery += " union all "

// abate saldo entreposto aduaneiro jah nacionalizado...
	cQuery += "select B1_COD, B1_REFER, B1_MARCA, 0 B2_QATU, 0 B2_RESERVA,"
	cQuery += " 0 B2_QPEDVEN, 0 QTDTRAN, 0 B6_SALDO, 0 SLDPO, sum( W7_SALDO_Q * -1 ) SLDPROC"
	cQuery += " from " + RetSqlName( 'SB1' ) + " SB1, " + RetSqlName( 'SW6' ) + " SW6, "
	cQuery += RetSqlName( 'SW7' ) + " SW7"
	cQuery += " where B1_FILIAL = '" + cFilAnt + "'"
	If !lProduto
		cQuery += " and B1_REFER like '%" + AllTrim( cRefer ) + "%'"
	Else
		cQuery += " and B1_COD = '" + SB1->B1_COD + "'"
	EndIf
	cQuery += " and SB1.D_E_L_E_T_ = ' '"
	cQuery += " and W6_FILIAL = '  '"
	cQuery += " and W6_DT_ENTR > '        '"
	cQuery += " and W6_TIPOFEC = 'DIN'"
	cQuery += " and SW6.D_E_L_E_T_ = ' '"
	cQuery += " and W7_FILIAL = W6_FILIAL"
	cQuery += " and W7_HAWB = W6_HAWB"
	cQuery += " and W7_SEQ = 0"
	cQuery += " and W7_COD_I = B1_COD"
	cQuery += " and SW7.D_E_L_E_T_ = ' '"
	cQuery += " group by B1_COD, B1_REFER, B1_MARCA"

	cQuery += " ) group by B1_COD, B1_REFER, B1_MARCA"
	cQuery += " order by B1_REFER, B1_MARCA, B1_COD"

	MEMOWRIT( 'C:\SQLSIGA\IMDC040-SB1TMP.TXT', cQuery )

	MEMOWRIT( 'C:\SQLSIGA\1Ini_SB1.TXT', "Inicio "+Time() )

	TCQuery cQuery NEW ALIAS "SB1TMP"

//dbUseArea( .t., 'TOPCONN', TCGenQry(,, cQuery ), 'SB1TMP', .t., .t. )

	TCSetField( 'SB1TMP', 'B2_QATU'   , 'N', 14, 4 )
	TCSetField( 'SB1TMP', 'B2_RESERVA', 'N', 14, 4 )
	TCSetField( 'SB1TMP', 'B2_QPEDVEN', 'N', 14, 4 )
	TCSetField( 'SB1TMP', 'QTDTRAN'   , 'N', 14, 4 )
	TCSetField( 'SB1TMP', 'B6_SALDO'  , 'N', 14, 4 )
	TCSetField( 'SB1TMP', 'SLDPO'     , 'N', 14, 4 )
	TCSetField( 'SB1TMP', 'SLDPROC'   , 'N', 14, 4 )

	MEMOWRIT( 'C:\SQLSIGA\1Fim_SB1.TXT', "Fim "+Time() )

// carrega as posicoes para o vetor listbox
	aLista1 := Array( 0 )

	IncProc("Buscando último Preço de Compra...")

//DA1->( dbSetOrder( 1 ) )
	SB1->( dbSetOrder( 1 ) )
	SBM->( dbSetOrder( 1 ) )

	DbSelectArea("SB1TMP")
	SB1TMP->( dbGoTop() )

	While SB1TMP->( !Eof() )

		SB1->( dbSeek( xFilial( 'SB1' ) + SB1TMP->B1_COD, .f. ) )
		SBM->( dbSeek( xFilial( 'SBM' ) + SB1->B1_GRUPO, .f. ) )
	//DA1->( dbSeek( xFilial( 'DA1' ) + MV_PAR03 + SB1TMP->B1_COD, .f. ) )

	// pesquisa ultimo FOB/Preco de Compra...
		aUPrCom := { CtoD( '' ), 0, 1, 0, '   ' }
	// 1 - emissao
	// 2 - preco
	// 3 - moeda
	// 4 - preco em R$
	// 5 - incoterm

	// produto nacional...
		If lUPrcCom .and. SB1->B1_ORIGEM == '0'

			For nI := 1 to Len( aFilial )

				SB1->( dbSeek( aFilial[ nI, 1 ] + SB1TMP->B1_COD, .f. ) )

				If aUPrCom[ 1 ] < SB1->B1_UCOM	// !Empty( SB1->B1_UCOM ) .and.

					aUPrCom[ 1 ] := SB1->B1_UCOM
					aUPrCom[ 2 ] := SB1->B1_UPRC
				EndIf
			Next

		// calcula preco em R$ para calculo do fator...
			aUPrCom[ 4 ] := aUPrCom[ 2 ]

		ElseIf lUPrcCom	// produto importado/nacionalizado...

			aUPrCom[ 1 ] := SB1->B1_ULTIMP
			aUPrCom[ 2 ] := SB1->B1_PRCUIMP
			aUPrCom[ 3 ] := aScan( aSimbMoeda, If( !Empty( SB1->B1_MOEUIMP ), SB1->B1_MOEUIMP, 'USD' ) )

			If SB1->B1_MOEUIMP == 'USD' .or. Empty( SB1->B1_MOEUIMP )

			//aUPrCom[ 4 ] := SB1->B1_ULTFOB * MV_PAR04
				aUPrCom[ 4 ] := SB1->B1_PRCUIMP * MV_PAR04
			Else
			//aUPrCom[ 4 ] := xMoeda( SB1->B1_ULTFOB, aScan( aSimbMoeda, SB1->B1_MOEUIMP ), 1, SB1->B1_ULTIMP )
				aUPrCom[ 4 ] := xMoeda( SB1->B1_PRCUIMP, aScan( aSimbMoeda, SB1->B1_MOEUIMP ), 1, SB1->B1_ULTIMP )
			EndIf

			aUPrCom[ 5 ] := SB1->B1_INCUIMP

		EndIf

	// pesquisa preco de venda...
		nPrcVen := 0
		nNumTab := 0

	// pesquisa tabelas de preco do produto...
		cQuery := "select DA1_PRCVEN, DA1_MOEDA"
		cQuery += " from " + RetSqlName( 'DA1' ) + " DA1, " + RetSqlName( 'DA0' ) + " DA0"
		cQuery += " where DA1_FILIAL = '  '"
		cQuery += " and DA1_CODPRO = '" + SB1TMP->B1_COD + "'"
		cQuery += " and DA1_CODTAB = '" + MV_PAR03 + "'"
		cQuery += " and DA1_ATIVO = '1'"
		cQuery += " and DA1.D_E_L_E_T_ = ' '"
		cQuery += " and DA0_FILIAL = DA1_FILIAL"
		cQuery += " and DA0_CODTAB = DA1_CODTAB"
		cQuery += " and DA0_ATIVO = '1'"
		cQuery += " and DA0_DATDE <= '" + DtoS( dDataBase ) + "'"
		cQuery += " and ( DA0_DATATE >= '" + DtoS( dDataBase ) + "' or DA0_DATATE = ' ' )"
		cQuery += " and DA0.D_E_L_E_T_ = ' '"

//	MEMOWRIT( 'C:\SQLSIGA\IMDC040-DA1TMP.TXT', cQuery )

		MEMOWRIT( 'C:\SQLSIGA\1Ini_DA1.TXT', "Inicio "+Time() )

		TCQuery cQuery NEW ALIAS "DA1TMP"

//	dbUseArea( .t., 'TOPCONN', TCGenQry(,, cQuery ), 'DA1TMP', .t., .t. )

		TCSetField( 'DA1TMP', 'DA1_PRCVEN', 'N', 11, 4 )

		MEMOWRIT( 'C:\SQLSIGA\1Fim_DA1.TXT', "Fim "+Time() )

		DbSelectArea("DA1TMP")

		DA1TMP->( dbGoTop() )

		While DA1TMP->( !Eof() )

		// se houver mais de uma tabela ativa, calcula uma media aritmetica simples...
			If DA1TMP->DA1_MOEDA <> 1
				nPrcVen += xMoeda( DA1TMP->DA1_PRCVEN, DA1TMP->DA1_MOEDA, 1, dDataBase )
			Else
				nPrcVen += DA1TMP->DA1_PRCVEN
			EndIf

			nNumTab ++

			DA1TMP->( dbSkip() )
		End

		DA1TMP->( dbCloseArea() )

		nPrcVen := ( nPrcVen / nNumTab )

		SB1->( dbSeek( xFilial( 'SB1' ) + SB1TMP->B1_COD, .f. ) )

		aAdd( aLista1, { ' ',;
			' ',;
			' ',;
			SB1TMP->B1_COD,;
			SB1->B1_DESC,;
			SBM->BM_DESC,;
			SB1->B1_UM,;
			aSimbMoeda[ aUPrCom[ 3 ] ] + Transform( aUPrCom[ 2 ], '@E 999,999.99999' ),;
			aUPrCom[ 5 ],;
			nPrcVen,;
			( nPrcVen / aUPrCom[ 4 ] ),;
			SB1TMP->B2_QATU,;
			( SB1TMP->B2_QATU - SB1TMP->B2_RESERVA - SB1TMP->B2_QPEDVEN  + SB1TMP->QTDTRAN ),;
			( SB1TMP->SLDPO + SB1TMP->SLDPROC ),;
			SB1TMP->B6_SALDO } )

		SB1TMP->( dbSkip() )
	End

	SB1TMP->( dbCloseArea() )

	AtualLista( 1 )
	AtualLista( 2, aLista1[ oLista1:nAt, 04 ] )

Return

********************************************************************************
Static Function AtualLista( nLista, cCod )//| Funcòes para Tratamento dos ListBox |
********************************************************************************
	Local cQuery := ''

	If nLista = 1

		If Empty( aLista1 )

			aLista1 := { { '', '', '', '', '', '', '', '', '', 0, 0, 0, 0, 0, 0 } }
		EndIf

		oLista1:SetArray( aLista1 )

		oLista1:bLine := { || { If( aLista1[ oLista1:nAt, 13 ] > 0, oEnable, oDisable ), ;
			If( aLista1[ oLista1:nAt, 14 ] > 0, oAzul, oDisable ), ;
			If( aLista1[ oLista1:nAt, 15 ] > 0, oAmarelo, oDisable ), ;
			aLista1[ oLista1:nAt, 04 ], ;
			aLista1[ oLista1:nAt, 05 ], ;
			aLista1[ oLista1:nAt, 06 ], ;
			aLista1[ oLista1:nAt, 07 ], ;
			aLista1[ oLista1:nAt, 08 ], ;	//Transform( aLista1[ oLista1:nAt, 06 ], PesqPict( 'DA1', 'DA1_PRCVEN' ) ), ;
			aLista1[ oLista1:nAt, 09 ], ;
			Transform( aLista1[ oLista1:nAt, 10 ], PesqPict( 'DA1', 'DA1_PRCVEN' ) ), ;
			Transform( aLista1[ oLista1:nAt, 11 ], '@E 9999.99' ), ;
			Transform( aLista1[ oLista1:nAt, 12 ], PesqPict( 'SB2', 'B2_QATU' ) ), ;
			Transform( aLista1[ oLista1:nAt, 13 ], PesqPict( 'SB2', 'B2_QATU' ) ), ;
			Transform( aLista1[ oLista1:nAt, 14 ], PesqPict( 'SB2', 'B2_QATU' ) ), ;
			Transform( aLista1[ oLista1:nAt, 15 ], PesqPict( 'SB2', 'B2_QATU' ) ) } }
		oLista1:nAt := 1
		oLista1:nFreeze := 3
		oLista1:Refresh()
		oRefer:SetFocus()

	ElseIf nLista = 2

		If !Empty( aLista1[ 1, 4 ] )

			IncProc("Verificando Saldos por Filial...")

		// carrega as posicoes para o vetor listbox
			aLista2 := Array( 0 )


			For _nCount	:= 1 to Len(_aFilList)

				_cQryAEmbarcar	:= ""
				_cQryEmbarcado	:= ""
				_cQryEntreposto	:= ""
				_cQryPodTerc	:= ""
				_cQryQtdTran	:= ""
				_nQtdAtu		:= 0
				_nSldAtu		:= 0
				_nSldAEmbarcar	:= 0
				_nSldEmbarcado	:= 0
				_nSldEntreposto	:= 0
				_nSldPodTerc	:= 0
				_nQtdTran		:= 0


			//Sld a Embarcar - Sem Processos
				_cQryAEmbarcar	:= " select W3_CC W3FILIAL, sum(W5_SALDO_Q) SLDAEMB"
				_cQryAEmbarcar	+= "   from "+RetSqlName("SW2")+" SW2, "+RetSqlName("SW3")+" SW3, "+RetSqlName("SW5")+" SW5"
				_cQryAEmbarcar	+= "  where W2_FILIAL = '  '"
				_cQryAEmbarcar	+= "    and W2_HAWB_DA = ' '"
				_cQryAEmbarcar	+= "    and SW2.D_E_L_E_T_ = ' '"
				_cQryAEmbarcar	+= "    and W3_FILIAL = W2_FILIAL"
				_cQryAEmbarcar	+= "    and W3_PO_NUM = W2_PO_NUM"
				_cQryAEmbarcar	+= "    and W3_SEQ = 0"
				_cQryAEmbarcar	+= "    and W3_COD_I = '"+cCod+"'"
				_cQryAEmbarcar	+= "    and SW3.D_E_L_E_T_ = ' '"
				_cQryAEmbarcar	+= "    and W5_FILIAL = W3_FILIAL"
				_cQryAEmbarcar	+= "    and W5_PO_NUM = W3_PO_NUM"
				_cQryAEmbarcar	+= "    and W5_POSICAO = W3_POSICAO"
				_cQryAEmbarcar	+= "    and W5_SALDO_Q > 0"
				_cQryAEmbarcar	+= "    and W5_HAWB = ' '"
				_cQryAEmbarcar	+= "    and SW5.D_E_L_E_T_ = ' '"
				_cQryAEmbarcar	+= "  group by W3_CC"

				_cAlW3 := "C040"+AllTrim(str(Aleatorio(999999,0)))

				TCQuery _cQryAEmbarcar NEW ALIAS &(_cAlW3)

				TCSetField(_cAlW3,"SLDAEMB","N",14,4)

				DbSelectArea(_cAlW3)
				&(_cAlW3)->(dbGoTop())
				Do While (&(_cAlW3)->(!Eof()))

					If AllTrim(W3FILIAL) == AllTrim(_aFilList[_nCount])
						_nSldAEmbarcar := SLDAEMB
					EndIf

					&(_cAlW3)->(DBSKIP())

				EndDo

				&(_cAlW3)->(dbCloseArea())

			//Saldos a Embarcar - Não enbarcados

				_cQryAEmbarcar	:= " select W7_CC W7FILIAL, sum(W7_SALDO_Q) SLDAEMB"
				_cQryAEmbarcar	+= "   from "+RetSqlName("SW6")+" SW6, "+RetSqlName("SW7")+" SW7"
				_cQryAEmbarcar	+= "  where W6_FILIAL = '  '"
				_cQryAEmbarcar	+= "    and W6_DT_EMB = '        '"
				_cQryAEmbarcar	+= "    and W6_TIPOFEC in ('DI ', 'DA ')"
				_cQryAEmbarcar	+= "    and SW6.D_E_L_E_T_ = ' '"
				_cQryAEmbarcar	+= "    and W7_FILIAL = W6_FILIAL"
				_cQryAEmbarcar	+= "    and W7_HAWB = W6_HAWB"
				_cQryAEmbarcar	+= "    and W7_SEQ = 0"
				_cQryAEmbarcar	+= "    and W7_COD_I = '"+cCod+"'"
				_cQryAEmbarcar	+= "    and SW7.D_E_L_E_T_ = ' '"
				_cQryAEmbarcar	+= "  group by W7_CC"


				_cAlW3 := "C040"+AllTrim(str(Aleatorio(999999,0)))

				TCQuery _cQryAEmbarcar NEW ALIAS &(_cAlW3)

				TCSetField( _cAlW3,"SLDAEMB","N",14,4)

				DbSelectArea(_cAlW3)
				&(_cAlW3)->(dbGoTop())
				Do While (&(_cAlW3)->(!Eof()))

					If AllTrim(W7FILIAL) == AllTrim(_aFilList[_nCount])
						_nSldAEmbarcar += SLDAEMB
					EndIf

					&(_cAlW3)->(DBSKIP())

				EndDo

				&(_cAlW3)->(dbCloseArea())


			//Saldo Embarcado - importacao
				_cQryEmbarcado	:= " select W7_CC W7FILIAL, sum(W7_SALDO_Q) SLDEMB"
				_cQryEmbarcado	+= "   from "+RetSqlName("SW6")+" SW6, "+RetSqlName("SW7")+" SW7"
				_cQryEmbarcado	+= "  where W6_FILIAL = '  '"
				_cQryEmbarcado	+= "    and W6_DT_EMB > '        '"
				_cQryEmbarcado	+= "    and W6_DT_ENTR = '        '"
				_cQryEmbarcado	+= "    and W6_TIPOFEC = 'DI '"
				_cQryEmbarcado	+= "    and SW6.D_E_L_E_T_ = ' '"
				_cQryEmbarcado	+= "    and W7_FILIAL = W6_FILIAL"
				_cQryEmbarcado	+= "    and W7_HAWB = W6_HAWB"
				_cQryEmbarcado	+= "    and W7_SEQ = 0"
				_cQryEmbarcado	+= "    and W7_COD_I = '"+cCod+"'"
				_cQryEmbarcado	+= "    and SW7.D_E_L_E_T_ = ' '"
				_cQryEmbarcado	+= "  group by W7_CC"

				_cAlW7 := "C040"+AllTrim(str(Aleatorio(999999,0)))

				TCQuery _cQryEmbarcado NEW ALIAS &(_cAlW7)

				TCSetField(_cAlW7,"SLDEMB","N",14,4)

				DbSelectArea(_cAlW7)
				&(_cAlW7)->(dbGoTop())
				Do While (&(_cAlW7)->(!Eof()))

					If AllTrim(W7FILIAL) == AllTrim(_aFilList[_nCount])
						_nSldEmbarcado := SLDEMB
					EndIf

					&(_cAlW7)->(DBSKIP())

				EndDo

				&(_cAlW7)->(dbCloseArea())

			//Saldo Embarcado - entreposto
				_cQryEmbarcado	:= " select W7_CC W7FILIAL, sum(W7_SALDO_Q) SLDEMB"
				_cQryEmbarcado	+= "   from "+RetSqlName("SW6")+" SW6, "+RetSqlName("SW7")+" SW7"
				_cQryEmbarcado	+= " where W6_FILIAL = '  '"
				_cQryEmbarcado	+= "   and W6_DT_EMB > '        '"
				_cQryEmbarcado	+= "   and W6_CHEG = '        '"
				_cQryEmbarcado	+= "   and W6_TIPOFEC = 'DA '"
				_cQryEmbarcado	+= "   and SW6.D_E_L_E_T_ = ' '"
				_cQryEmbarcado	+= "   and W7_FILIAL = W6_FILIAL"
				_cQryEmbarcado	+= "   and W7_HAWB = W6_HAWB"
				_cQryEmbarcado	+= "   and W7_SEQ = 0"
				_cQryEmbarcado	+= "   and W7_COD_I = '"+cCod+"'"
				_cQryEmbarcado	+= "   and SW7.D_E_L_E_T_ = ' '"
				_cQryEmbarcado	+= " group by W7_CC""

				_cAlW7 := "C040"+AllTrim(str(Aleatorio(999999,0)))

				TCQuery _cQryEmbarcado NEW ALIAS &(_cAlW7)

				TCSetField(_cAlW7,"SLDEMB","N",14,4)

				DbSelectArea(_cAlW7)
				&(_cAlW7)->(dbGoTop())
				Do While (&(_cAlW7)->(!Eof()))

					If AllTrim(W7FILIAL) == AllTrim(_aFilList[_nCount])
						_nSldEmbarcado += SLDEMB
					EndIf

					&(_cAlW7)->(DBSKIP())

				EndDo

				&(_cAlW7)->(dbCloseArea())


			// Entreposto Aduaneiro...
				_cQryEntreposto	:= " select W7_CC W7FILIAL, sum(W7_SALDO_Q) SLDENTR"
				_cQryEntreposto	+= "   from "+RetSqlName("SW6")+" SW6, "+RetSqlName("SW7")+" SW7"
				_cQryEntreposto	+= "  where W6_FILIAL = '  '"
				_cQryEntreposto	+= "    and W6_CHEG > '        '"
				_cQryEntreposto	+= "    and W6_TIPOFEC = 'DA '"
				_cQryEntreposto	+= "    and SW6.D_E_L_E_T_ = ' '"
				_cQryEntreposto	+= "    and W7_FILIAL = W6_FILIAL"
				_cQryEntreposto	+= "    and W7_HAWB = W6_HAWB"
				_cQryEntreposto	+= "    and W7_SEQ = 0"
				_cQryEntreposto	+= "    and W7_COD_I = '"+cCod+"'"
				_cQryEntreposto	+= "    and SW7.D_E_L_E_T_ = ' '"
				_cQryEntreposto	+= "  group by W7_CC"

				_cAlW7 := "C040"+AllTrim(str(Aleatorio(999999,0)))

				TCQuery _cQryEntreposto NEW ALIAS &(_cAlW7)

				TCSetField(_cAlW7,"SLDENTR","N",14,4)

				DbSelectArea(_cAlW7)
				&(_cAlW7)->(dbGoTop())
				Do While (&(_cAlW7)->(!Eof()))

					If AllTrim(W7FILIAL) == AllTrim(_aFilList[_nCount])
						_nSldEntreposto := SLDENTR
					EndIf

					&(_cAlW7)->(DBSKIP())

				EndDo

				&(_cAlW7)->(dbCloseArea())

			// abate saldo entreposto aduaneiro jah nacionalizado...
				_cQryEntreposto	:= " select W7_CC W7FILIAL, sum(W7_SALDO_Q * -1) SLDENTR"
				_cQryEntreposto	+= "   from "+RetSqlName("SW6")+" SW6, "+RetSqlName("SW7")+" SW7"
				_cQryEntreposto	+= "  where W6_FILIAL = '  '"
				_cQryEntreposto	+= "    and W6_DT_ENTR > '        '"
				_cQryEntreposto	+= "    and W6_TIPOFEC = 'DIN'"
				_cQryEntreposto	+= "    and SW6.D_E_L_E_T_ = ' '"
				_cQryEntreposto	+= "    and W7_FILIAL = W6_FILIAL"
				_cQryEntreposto	+= "    and W7_HAWB = W6_HAWB"
				_cQryEntreposto	+= "    and W7_SEQ = 0"
				_cQryEntreposto	+= "    and W7_COD_I = '"+cCod+"'"
				_cQryEntreposto	+= "    and SW7.D_E_L_E_T_ = ' '"
				_cQryEntreposto	+= "  group by W7_CC"

				_cAlW7 := "C040"+AllTrim(str(Aleatorio(999999,0)))

				TCQuery _cQryEntreposto NEW ALIAS &(_cAlW7)

				TCSetField(_cAlW7,"SLDENTR","N",14,4)

				DbSelectArea(_cAlW7)
				&(_cAlW7)->(dbGoTop())
				Do While (&(_cAlW7)->(!Eof()))

					If AllTrim(W7FILIAL) == AllTrim(_aFilList[_nCount])
						_nSldEntreposto += SLDENTR
					EndIf

					&(_cAlW7)->(DBSKIP())

				EndDo

				&(_cAlW7)->(dbCloseArea())


			// saldo em poder de terceiros...
				_cQryPodTerc := " select B6_FILIAL B6FILIAL, sum(B6_SALDO) B6SALDO"
				_cQryPodTerc += "   from "+RetSqlName("SB6")+" SB6"
				_cQryPodTerc += "  where B6_FILIAL in ("+cFilImd+")"
				_cQryPodTerc += "    and B6_PRODUTO = '"+cCod+"'"
				_cQryPodTerc += "    and B6_SALDO <> 0"
				_cQryPodTerc += "    and substr(B6_TES, 1, 1) >= '5'"
				_cQryPodTerc += "    and B6_TIPO = 'E'"
				_cQryPodTerc += "    and SB6.D_E_L_E_T_ = ' '"
				_cQryPodTerc += "  group by B6_FILIAL"

				_cAlB6 := "C040"+AllTrim(str(Aleatorio(999999,0)))

				TCQuery _cQryPodTerc NEW ALIAS &(_cAlB6)

				TCSetField(_cAlB6,"B6SALDO","N",14,4)

				DbSelectArea(_cAlB6)
				&(_cAlB6)->(dbGoTop())
				Do While (&(_cAlB6)->(!Eof()))

					If AllTrim(B6FILIAL) == AllTrim(_aFilList[_nCount])
						_nSldPodTerc	:= B6SALDO
					EndIf

					&(_cAlB6)->(DBSKIP())

				EndDo

				&(_cAlB6)->(dbCloseArea())


			// pedidos de alocados em planilhas de transferencia...
				_cQryQtdTran := " select /*+rule*/"
				_cQryQtdTran += "  C6_FILIAL C6FILIAL, nvl(sum(C6_QTDVEN - C6_QTDENT), 0) QTDTRAN"
				_cQryQtdTran += "   from "+RetSqlName("SC6")+" SC6, "+RetSqlName("SC7")+" SC7"
				_cQryQtdTran += "  where C6_FILIAL in ("+cFilImd+")"
				_cQryQtdTran += "    and C6_PRODUTO = '"+cCod+"'"
				_cQryQtdTran += "    and C6_CLI <> 'N00000'"
				_cQryQtdTran += "    and (C6_PLANILH <> ' ' OR C6_FILTRAN <> ' ')"
				_cQryQtdTran += "    and C6_NOTA = ' '"
				_cQryQtdTran += "    and SC6.D_E_L_E_T_ = ' '"
				_cQryQtdTran += "    and C7_FILIAL = C6_FILIAL"
				_cQryQtdTran += "    and C7_PLANILH = C6_PLANILH"
				_cQryQtdTran += "    and C7_PLITEM = C6_PLITEM"
				_cQryQtdTran += "    and (C7_QUANT - C7_QUJE) > 0"
				_cQryQtdTran += "    and SC7.D_E_L_E_T_ = ' '"
				_cQryQtdTran += "  group by C6_FILIAL"

				_cAlC6 := "C040"+AllTrim(str(Aleatorio(999999,0)))

				TCQuery _cQryQtdTran NEW ALIAS &(_cAlC6)

				TCSetField(_cAlC6,"QTDTRAN","N",14,4)

				DbSelectArea(_cAlC6)
				&(_cAlC6)->(dbGoTop())
				Do While (&(_cAlC6)->(!Eof()))

					If AllTrim(C6FILIAL) == AllTrim(_aFilList[_nCount])
						_nQtdTran	:= QTDTRAN
					EndIf

					&(_cAlC6)->(DBSKIP())

				EndDo

				&(_cAlC6)->(dbCloseArea())


				DbSelectArea("SB2")
				DbSetOrder(1)
				If DbSeek(_aFilList[_nCount]+cCod+MV_PAR01)
					_nQtdAtu	:= 0
					_nSldAtu	:= 0
					While !EoF() .And. ( SB2->B2_FILIAL + SB2->B2_COD == _aFilList[_nCount]+cCod ) .And. ( SB2->B2_LOCAL >= MV_PAR01 .AND. SB2->B2_LOCAL <= MV_PAR02 )
							_nQtdAtu	+= SB2->B2_QATU
						//_nSldAtu	:= SaldoSB2()
						_nSldAtu	+= SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QPEDVEN  + _nQtdTran

						DbSelectArea("SB2")
						DbSkip()
					EndDo
				Else
					_nQtdAtu	:= 0
					_nSldAtu	:= 0
				EndIf

				aAdd( aLista2, { ' ',;
					' ',;
					' ',;
					aFilial[ aScan( aFilial, { |x| x[ 1 ] == _aFilList[_nCount] } ), 2 ],;
					_nQtdAtu,;			//_nQtdAtu
				_nSldAtu,;			//_nSldAtu
				_nSldAEmbarcar,;	//_nSldAEmbarcar
				_nSldEmbarcado,;	//_SldEmbarcado
				_nSldEntreposto,;	//_SldEntreposto
				_nSldPodTerc } )	//_SldPodTerc
			Next _nCount

		Else
			aLista2 := Array( 0 )
		EndIf

		If Empty( aLista2 )

			aLista2 := { { '', '', '', '', 0, 0, 0, 0, 0, 0 } }
	//Else
	//	aLista2 := aSort( aLista2,,, { |x,y| x[3]+x[1] < y[3]+y[1] } )
		EndIf

		oLista2:SetArray( aLista2 )
		oLista2:bLine := { || { If( aLista2[ oLista2:nAt, 6 ] > 0, oEnable, oDisable ), ;
			If( aLista2[ oLista2:nAt, 7 ] > 0 .or. aLista2[ oLista2:nAt, 8 ] > 0 .or. aLista2[ oLista2:nAt, 9 ] > 0, oAzul, oDisable ), ;
			If( aLista2[ oLista2:nAt, 10 ] > 0, oAmarelo, oDisable ), ;
			aLista2[ oLista2:nAt, 04 ], ;
			Transform( aLista2[ oLista2:nAt, 05 ], PesqPict( 'SB2', 'B2_QATU' ) ), ;
			Transform( aLista2[ oLista2:nAt, 06 ], PesqPict( 'SB2', 'B2_QATU' ) ), ;
			Transform( aLista2[ oLista2:nAt, 07 ], PesqPict( 'SB6', 'B6_SALDO') ), ;
			Transform( aLista2[ oLista2:nAt, 08 ], PesqPict( 'SB2', 'B2_QATU' ) ), ;
			Transform( aLista2[ oLista2:nAt, 09 ], PesqPict( 'SB2', 'B2_QATU' ) ), ;
			Transform( aLista2[ oLista2:nAt, 10 ], PesqPict( 'SB2', 'B2_QATU' ) ) } }
		oLista2:nAt := 1
		oLista2:nFreeze := 3
		oLista2:Refresh()
		oLista1:SetFocus()
	EndIf

Return
********************************************************************************
Static Function PesqLista()
********************************************************************************
	Local oDlg1, oBut1, oBut2
	Local cDesc := Space( 30 )
	Local nPos, nOpc := 0

	Define msDialog oDlg1 Title OemToAnsi( 'Pesquisa' ) Of oDlg From 00,00 To 100,400 Pixel

	@ 012,008 Say OemToAnsi( 'Desc. Produto' ) Of oDlg1 Pixel
	@ 012,055 msGet cDesc Picture PesqPict( 'SB1', 'B1_DESC' ) Of oDlg1 Pixel Size 140,10

	Define sButton oBut1 From 030,165 Type 01 Enable Of oDlg1 Pixel Action ( nOpc := 1, oDlg1:End() )
	Define sButton oBut2 From 030,135 Type 02 Enable Of oDlg1 Pixel Action ( oDlg1:End() )

	Activate msDialog oDlg1 Center


	If nOpc == 1 .and. !Empty( cDesc )

		nPos := aScan( oLista1:aArray, { |aVal| aVal[3] >= cDesc } )

		If nPos <> 0

			oLista1:nAt := nPos

			oLista1:Refresh()

			AtualLista( 2, aLista1[ oLista1:nAt, 04 ] )
		EndIf
	EndIf

Return
********************************************************************************
Static Function LegLista()
********************************************************************************

	BrwLegenda( cCadastro, 'Legenda',{ { 'ENABLE'		, 'Saldo Disponível' }, ;
		{ 'BR_AZUL'		, 'Saldo Importação' }, ;
		{ 'BR_AMARELO'	, 'Saldo Poder de Terceiros' }, ;
		{ 'LBNO'		, 'Não possui Saldo' } } )

Return NIL
********************************************************************************
Static Function Import( cCod )
********************************************************************************
	Local oDlg1
	Local cQuery   := ''
	Local dETA     := CtoD( '' )
	Local dPrevEnt := CtoD( '' )
	Local dDtEntr  := CtoD( '' )
	Local cPedNac1, cPedNac2
	Local aEntNac
	Private oList
	Private aList  := Array( 0 )
	Private nAEmbarcar := 0
	Private nEmbarcado := 0
	Private nEntrepost := 0
	Private nTotal := 0


	IncProc("Selecionando Movimentos...")

	cQuery := "select W2_PO_NUM, '' W6_HAWB, A2_NREDUZ, W5_SALDO_Q W7_SALDO_Q, W3_PRECO W7_PRECO, W2_INCOTER W6_INCOTER,"
	cQuery += " W3_CC W7_CC, W5_DT_EMB W6_DT_ETD, '' W6_DT_EMB, '' W6_DT_ETA, '' W6_CHEG, '' W6_DTREG_D, "
	cQuery += " W5_DT_ENTR, '' W6_DT_ENTR, '' W6_PRVENTR , YR_TRANS_T, 0 Y9_LT_DES, 0 Y9_LT_TRA, '' W6_TIPOFEC, '' W6_DI_NUM"
	cQuery += " from " + RetSqlName( 'SW3' ) + " SW3, " + RetSqlName( 'SW2' ) + " SW2, "
	cQuery += RetSqlName( 'SW5' ) + " SW5, " + RetSqlName( 'SA2' ) + " SA2, " + RetSqlName( 'SYR' ) + " SYR"
	cQuery += " where W2_FILIAL = '  '"
	cQuery += " and W2_HAWB_DA = ' '"
	cQuery += " and SW2.D_E_L_E_T_ = ' '"
	cQuery += " and W3_FILIAL = W2_FILIAL"
	cQuery += " and W3_PO_NUM = W2_PO_NUM"
	cQuery += " and W3_SEQ = 0"
	cQuery += " and W3_COD_I = '" + cCod + "'"
	cQuery += " and SW3.D_E_L_E_T_ = ' '"
	cQuery += " and W5_FILIAL = W3_FILIAL"
	cQuery += " and W5_PO_NUM = W3_PO_NUM"
	cQuery += " and W5_POSICAO = W3_POSICAO"
	cQuery += " and W5_SALDO_Q > 0"
	cQuery += " and W5_HAWB = ' '"
	cQuery += " and SW5.D_E_L_E_T_ = ' '"
	cQuery += " and A2_FILIAL = W2_FILIAL"
	cQuery += " and A2_COD = W2_FORN"
	cQuery += " and SA2.D_E_L_E_T_ = ' '"
	cQuery += " and YR_FILIAL = W2_FILIAL"
	cQuery += " and YR_VIA = W2_TIPO_EM"
	cQuery += " and YR_ORIGEM = W2_ORIGEM"
	cQuery += " and YR_DESTINO = W2_DEST"
	cQuery += " and SYR.D_E_L_E_T_ = ' '"
	cQuery += " union all "
	cQuery += "select W2_PO_NUM, W6_HAWB, A2_NREDUZ, W7_SALDO_Q, W7_PRECO, W6_INCOTER, W7_CC, "
	cQuery += " W6_DT_ETD, W6_DT_EMB, W6_DT_ETA, W6_CHEG, W6_DTREG_D, "
	cQuery += " '' W5_DT_ENTR, W6_DT_ENTR,W6_PRVENTR , 0 YR_TRANS_T, Y9_LT_DES, Y9_LT_TRA, W6_TIPOFEC, W6_DI_NUM"
	cQuery += " from " + RetSqlName( 'SW7' ) + " SW7, " + RetSqlName( 'SW6' ) + " SW6 , "
	cQuery += RetSqlName( 'SW2' ) + " SW2, " + RetSqlName( 'SA2' ) + " SA2, " + RetSqlName( 'SY9' ) + " SY9"
	cQuery += " where W6_FILIAL = '  '"
//cQuery += " and W6_DT_ENTR = '        '"	// deve selecionar todos os processos, inclusives já encerrados...
	cQuery += " and SW6.D_E_L_E_T_ = ' '"
	cQuery += " and W7_FILIAL = W6_FILIAL"
	cQuery += " and W7_HAWB = W6_HAWB"
	cQuery += " and W7_SEQ = 0"
	cQuery += " and W7_COD_I = '" + cCod + "'"
	cQuery += " and SW7.D_E_L_E_T_ = ' '"
	cQuery += " and W2_FILIAL = W7_FILIAL"
	cQuery += " and W2_HAWB_DA = ' '"
	cQuery += " and W2_PO_NUM = W7_PO_NUM"
	cQuery += " and SW2.D_E_L_E_T_ = ' '"
	cQuery += " and A2_FILIAL = W2_FILIAL"
	cQuery += " and A2_COD = W2_FORN"
	cQuery += " and SA2.D_E_L_E_T_ = ' '"
	cQuery += " and Y9_FILIAL = W2_FILIAL"
	cQuery += " and Y9_SIGLA = W2_DEST"
	cQuery += " and SY9.D_E_L_E_T_ = ' '"
	cQuery += " order by W2_PO_NUM, W6_HAWB"

//MEMOWRIT( 'C:\SQLSIGA\IMDC040-SW2TMP.TXT', cQuery )

	MEMOWRIT( 'C:\SQLSIGA\1Ini_SW2.TXT', "Inicio "+Time() )

	TCQuery cQuery NEW ALIAS "SW2TMP"

//dbUseArea( .t., 'TOPCONN', TCGenQry(,, cQuery ), 'SW2TMP', .t., .t. )

	TCSetField( 'SW2TMP', 'W7_SALDO_Q', 'N', 13, 3 )
	TCSetField( 'SW2TMP', 'W7_PRECO'  , 'N', 15, 5 )
	TCSetField( 'SW2TMP', 'W6_DT_ETD' , 'D',  8, 0 )
	TCSetField( 'SW2TMP', 'W6_DT_EMB' , 'D',  8, 0 )
	TCSetField( 'SW2TMP', 'W6_DT_ETA' , 'D',  8, 0 )
	TCSetField( 'SW2TMP', 'W6_CHEG'   , 'D',  8, 0 )
	TCSetField( 'SW2TMP', 'W6_DTREG_D', 'D',  8, 0 )
	TCSetField( 'SW2TMP', 'W5_DT_ENTR', 'D',  8, 0 )
	TCSetField( 'SW2TMP', 'W6_PRVENTR', 'D',  8, 0 )
	TCSetField( 'SW2TMP', 'YR_TRANS_T', 'N',  6, 0 )
	TCSetField( 'SW2TMP', 'Y9_LT_DES' , 'N',  6, 0 )
	TCSetField( 'SW2TMP', 'Y9_LT_TRA' , 'N',  6, 0 )

	MEMOWRIT( 'C:\SQLSIGA\1Fim_SW2.TXT', "Fim "+Time() )

	SW7->( dbSetOrder( 2 ) )

	dbSelectArea("SW2TMP")
	SW2TMP->(dbGoTop())

	While !Eof()

		dETA := If( !Empty( SW2TMP->W6_DT_ETA ), SW2TMP->W6_DT_ETA, ( SW2TMP->W6_DT_ETD + SW2TMP->YR_TRANS_T ) )

		dPrevEnt := SW2TMP->W6_PRVENTR

		aEntNac := { CtoD( '' ), 0 }

	// verificar data de entrega da DIN...
		If AllTrim( SW2TMP->W6_TIPOFEC ) == 'DA'

			IncProc("Selecionando Movimentos de Importação...")

			cPedNac1 := 'DA' + Transform( SW2TMP->W6_DI_NUM, '@R XX/XXXXXXX-X' )
			cPedNac2 := 'DA' + SubStr( SW2TMP->W6_DI_NUM, 1, 10 )

			cQuery := "select max( W6_DT_ENTR ) W6_DT_ENTR, sum( W7_SALDO_Q ) W7_SALDO_Q"
			cQuery += " from " + RetSqlName( 'SW7' ) + " SW7, " + RetSqlName( 'SW6' ) + " SW6"
			cQuery += " where W6_FILIAL = '  '"
			cQuery += " and W6_DT_ENTR > '        '"
			cQuery += " and W6_TIPOFEC = 'DIN'"
			cQuery += " and SW6.D_E_L_E_T_ = ' '"
			cQuery += " and W7_FILIAL = W6_FILIAL"
			cQuery += " and W7_HAWB = W6_HAWB"
			cQuery += " and W7_SEQ = 0"
			cQuery += " and ( W7_PO_NUM = '" + cPedNac1 + "'"
			cQuery += " or substr( W7_PO_NUM, 1, 12 ) = '" + cPedNac2 + "' )"
			cQuery += " and W7_COD_I = '" + cCod + "'"
			cQuery += " and SW7.D_E_L_E_T_ = ' '"

			MEMOWRIT( 'C:\SQLSIGA\1Ini_SW7.TXT', "Inicio "+Time() )

			TCQuery cQuery NEW ALIAS "SW7TMP"

//		dbUseArea( .t., 'TOPCONN', TCGenQry(,, cQuery ), 'SW7TMP', .t., .t. )

//		MEMOWRIT( 'C:\SQLSIGA\IMDC040-SW7TMP.TXT', cQuery )
			TCSetField( 'SW7TMP', 'W6_DT_ENTR', 'D',  8, 0 )
			TCSetField( 'SW7TMP', 'W7_SALDO_Q', 'N', 13, 3 )

			MEMOWRIT( 'C:\SQLSIGA\1Fim_SW7.TXT', "Fim "+Time() )

			DbSelectArea("SW7TMP")

			aEntNac := { SW7TMP->W6_DT_ENTR, SW7TMP->W7_SALDO_Q }

			SW7TMP->(dbCloseArea())

			dbSelectArea("SW2TMP")
		EndIf

		dDtEntr := If( aEntNac[ 2 ] >= W7_SALDO_Q, aEntNac[ 1 ], W6_DT_ENTR )

		aAdd( aList, { ' ', ;
			AllTrim( W2_PO_NUM ), ;
			AllTrim( W6_HAWB ), ;
			W6_TIPOFEC, ;
			W7_CC, ;
			If( lUPrcCom, Left( A2_NREDUZ, 15 ), '' ), ;
			W7_SALDO_Q, ;
			If( lUPrcCom, W7_PRECO, 0 ), ;
			W6_INCOTER, ;
			W6_DT_ETD, ;
			W6_DT_EMB, ;
			dETA, ;
			W6_CHEG, ;
			W6_DTREG_D, ;
			dPrevEnt, ;
			dDtEntr } )

		If Empty( W6_DT_EMB )

			nAEmbarcar += W7_SALDO_Q

		ElseIf Empty( dDtEntr ) .and. W6_TIPOFEC == 'DI '

			nEmbarcado += W7_SALDO_Q

		ElseIf Empty( dDtEntr ) .and. Empty( W6_CHEG ) .and. W6_TIPOFEC == 'DA '

			nEmbarcado += W7_SALDO_Q

		ElseIf Empty( dDtEntr ) .and. !Empty( W6_CHEG ) .and. W6_TIPOFEC == 'DA '

			nEntrepost += ( W7_SALDO_Q - aEntNac[ 2 ] )
		EndIf

		dbSkip()
	End

	nTotal := nAEmbarcar + nEmbarcado + nEntrepost

	SW2TMP->( dbCloseArea() )

// testa se encontrou algum registro, pois o array nao pode
// ser passado vazio para a listbox
	If Empty( aList )
		ApMsgInfo("Não existem registros de Processos de Importações pendentes para este produto!", cCadastro+" - "+ProcName())
		Return
	EndIf

	Define msDialog oDlg1 Title OemToAnsi( cCadastro + ' - Importação' ) Of oDlg From 0,0 To 27,80

	@ 016,010 Say OemToAnsi( 'Código' ) Of oDlg1 Pixel
	@ 016,045 msGet aLista1[ oLista1:nAt, 04 ] When .f. Of oDlg1 Pixel Size 050,10

	@ 016,110 Say OemToAnsi( 'Descrição' ) Of oDlg1 Pixel
	@ 016,145 msGet aLista1[ oLista1:nAt, 05 ] When .f. Of oDlg1 Pixel Size 140,10

	@ 028,010 Say OemToAnsi( 'Grupo' ) Of oDlg1 Pixel
	@ 028,045 msGet aLista1[ oLista1:nAt, 06 ] When .f. Of oDlg1 Pixel Size 050,10

	@ 028,111 Say OemToAnsi( 'UM' ) Of oDlg1 Pixel
	@ 028,145 msGet aLista1[ oLista1:nAt, 07 ] When .f. Of oDlg1 Pixel Size 020,10

	@ 43,05  ListBox oList ;
		Fields Header  '  ','P.O.','Processo','Tipo','Filial Req','Fornecedor','Saldo Quant','Prc Unit','Incoterm','ETD','Embarque','ETA','Atracação','Registro DI','Prev Entrega', 'Dt Entrega' ;
		Size 307,113 ;
		Pixel Of oDlg1

	oList:SetArray( aList )
	oList:bLine := { || { If( Empty( aList[ oList:nAt, 11 ] ), oEnable, ;
		If( !Empty( aList[ oList:nAt, 16 ] ), oPreto, ;
		If( !Empty( aList[ oList:nAt, 13 ] ) .and. aList[ oList:nAt, 04 ] == 'DA ', oVermelho, oAmarelo ) ) ), ;
		aList[ oList:nAt, 02 ], ;
		aList[ oList:nAt, 03 ], ;
		aList[ oList:nAt, 04 ], ;
		aList[ oList:nAt, 05 ], ;
		aList[ oList:nAt, 06 ], ;
		Transform( aList[ oList:nAt, 07 ], PesqPict( 'SW7', 'W7_SALDO_Q' ) ), ;
		Transform( aList[ oList:nAt, 08 ], PesqPict( 'SW7', 'W7_PRECO' ) ), ;
		aList[ oList:nAt, 09 ], ;
		aList[ oList:nAt, 10 ], ;
		aList[ oList:nAt, 11 ], ;
		aList[ oList:nAt, 12 ], ;
		aList[ oList:nAt, 13 ], ;
		aList[ oList:nAt, 14 ], ;
		aList[ oList:nAt, 15 ], ;
		aList[ oList:nAt, 16 ] } }
	oList:nFreeze := 1
	oList:Refresh()


	@ 160,010 Say OemToAnsi( 'A Embarcar' ) Of oDlg1 Pixel
	@ 160,045 msGet nAEmbarcar Picture '@E 999,999,999.999' When .f. Of oDlg1 Pixel Size 050,10

	@ 160,105 Say OemToAnsi( 'Embarcado' ) Of oDlg1 Pixel
	@ 160,140 msGet nEmbarcado Picture '@E 999,999,999.999' When .f. Of oDlg1 Pixel Size 050,10

	@ 160,200 Say OemToAnsi( 'Saldo Entreposto' ) Of oDlg1 Pixel
	@ 160,250 msGet nEntrepost Picture '@E 999,999,999.999' When .f. Of oDlg1 Pixel Size 060,10

	@ 174,200 Say OemToAnsi( 'Saldo Importacao' ) Of oDlg1 Pixel
	@ 174,250 msGet nTotal Picture '@E 999,999,999.999' When .f. Of oDlg1 Pixel Size 060,10

	Activate msDialog oDlg1 Centered On Init EnchoiceBar( oDlg1, { || oDlg1:End() }, { || oDlg1:End() },,{{"OBJETIVO",{|| u_IC040Leg()},'Legenda'}} )

Return
********************************************************************************
User Function IC040Leg()
********************************************************************************

	BrwLegenda( cCadastro, 'Legenda',{ { 'ENABLE'		, 'Processo a Embarcar' }, ;
		{ 'BR_AMARELO'	, 'Processo Embarcado' }, ;
		{ 'BR_VERMELHO'	, 'Entreposto Aduaneiro a Nacionalizar' }, ;
		{ 'BR_PRETO'	, 'Processo Encerrado' } } )

Return Nil
********************************************************************************
Static Function PTerc( cCod )
********************************************************************************

	Local oDlg1
	Local cQuery	:= ''
	Private oList
	Private aList	:= Array( 0 )
	Private cNome


	IncProc("Selecionando Movimentos de Poder de Terceiros...")

	cQuery := "select B6_FILIAL, B6_CLIFOR, B6_LOJA, B6_TPCF, sum( B6_SALDO ) B6_SALDO"
	cQuery += " from " + RetSqlName( 'SB6' ) + " SB6"
	cQuery += " where B6_FILIAL in (" + cFilImd + ")"
	cQuery += " and B6_PRODUTO = '" + cCod + "'"
	cQuery += " and B6_SALDO <> '0'"
	cQuery += " and substr( B6_TES, 1, 1 ) >= '5'"
	cQuery += " and B6_TIPO = 'E'"
	cQuery += " and SB6.D_E_L_E_T_ = ' '"
	cQuery += " group by B6_FILIAL, B6_CLIFOR, B6_LOJA, B6_TPCF"

//MEMOWRIT( 'C:\SQLSIGA\IMDC040-SB6TMP.TXT', cQuery )

	MEMOWRIT( 'C:\SQLSIGA\1Ini_SB6.TXT', "Inicio "+Time() )

	TCQuery cQuery NEW ALIAS "SB6TMP"

//dbUseArea( .t., 'TOPCONN', TCGenQry(,, cQuery ), 'SB6TMP', .t., .t. )

	TCSetField( 'SB6TMP', 'B6_SALDO'  , 'N', 14, 4 )

	MEMOWRIT( 'C:\SQLSIGA\1Fim_SB6.TXT', "Fim "+Time() )

	SA1->( dbSetOrder( 1 ) )
	SA2->( dbSetOrder( 1 ) )

	dbSelectArea("SB6TMP")
	SB6TMP->(dbGoTop())

	While !Eof()

		If SB6TMP->B6_TPCF == 'C'

			SA1->( dbSeek( xFilial( 'SA1' ) + SB6TMP->B6_CLIFOR + SB6TMP->B6_LOJA, .f. ) )
			cNome := SA1->A1_NREDUZ
		Else
			SA2->( dbSeek( xFilial( 'SA2' ) + SB6TMP->B6_CLIFOR + SB6TMP->B6_LOJA, .f. ) )
			cNome := SA2->A2_NREDUZ
		EndIf

		aAdd( aList, { SB6TMP->B6_FILIAL, ;
			cNome, ;
			B6_SALDO } )
		dbSkip()
	End

	SB6TMP->( dbCloseArea() )

// testa se encontrou algum registro, pois o array nao pode
// ser passado vazio para a listbox
	If Empty( aList )
		ApMsgInfo("Não existem registros de Saldo em Poder de Terceiros para este produto!", cCadastro+" - "+ProcName())
		Return
	EndIf

	aList := aSort( aList,,, { |x,y| x[1]+x[2] < y[1]+y[2] } )

	Define msDialog oDlg1 Title OemToAnsi( cCadastro + ' - Em Poder de Terceiros' ) Of oDlg From 0,0 To 21,80

	@ 016,010 Say OemToAnsi( 'Codigo' ) Of oDlg1 Pixel
	@ 016,045 msGet aLista1[ oLista1:nAt, 04 ] When .f. Of oDlg1 Pixel Size 050,10

	@ 016,110 Say OemToAnsi( 'Descricao' ) Of oDlg1 Pixel
	@ 016,145 msGet aLista1[ oLista1:nAt, 05 ] When .f. Of oDlg1 Pixel Size 140,10

	@ 028,010 Say OemToAnsi( 'Grupo' ) Of oDlg1 Pixel
	@ 028,045 msGet aLista1[ oLista1:nAt, 06 ] When .f. Of oDlg1 Pixel Size 050,10

	@ 028,111 Say OemToAnsi( 'UM' ) Of oDlg1 Pixel
	@ 028,145 msGet aLista1[ oLista1:nAt, 07 ] When .f. Of oDlg1 Pixel Size 020,10


	@ 43,05  ListBox oList ;
		Fields Header  'Filial','Fornecedor','Saldo' ;
		Size 307,113 ;
		Pixel Of oDlg1

	oList:SetArray( aList )
	oList:bLine := { || { aList[ oList:nAt, 01 ], ;
		aList[ oList:nAt, 02 ], ;
		Transform( aList[ oList:nAt, 03 ], PesqPict( 'SB6', 'B6_SALDO' ) ) } }
	oList:Refresh()

	Activate msDialog oDlg1 Centered On Init EnchoiceBar( oDlg1, { || oDlg1:End() }, { || oDlg1:End() },, )

Return Nil
