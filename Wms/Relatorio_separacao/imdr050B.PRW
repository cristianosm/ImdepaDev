#Include 'rwmake.ch'
#Include 'Totvs.ch'

#Define CLR_ORANGE      RGB( 255, 229, 204 )
#Define CLR_GRAYH       RGB( 224, 224, 224 )
#Define CLR_GRAY        RGB( 128, 128, 128 )
#Define CLR_HBLUE       RGB(   0,   0, 255 )
#Define CLR_HGREEN      RGB(   0, 255,   0 )
#Define CLR_HCYAN       RGB(   0, 255, 255 )
#Define CLR_HRED        RGB( 255,   0,   0 )
#Define CLR_HMAGENTA    RGB( 255,   0, 255 )
#Define CLR_YELLOW      RGB( 255, 255,   0 )
#Define CLR_WHITE       RGB( 255, 255, 255 )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออหออออออออออหอออออออหออออออออออออออออออออหออออออหออออออออออออปฑฑ
ฑฑบ Programa  บ IMDR150b บ Autor บ Luciano Correa     บ Data บ  26/13/04  บฑฑ
ฑฑฬอออออออออออสออออออออออสอออออออสออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Original  บ IMDR050a บ Autor บ Jeferson Luis      บ Data บ  23/05/03  บฑฑ
ฑฑฬอออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDescricao  บ Impressao do Pedido de Venda especifico IMDEPA para auxi- บฑฑ
ฑฑบ           บ lio na separacao dos materias (Sem impressao de Endereco) บฑฑ
ฑฑฬอออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                        Ultimas Alteracoes                             บฑฑ
ฑฑฬออออออออออหออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ  Autor   บ   Data   บ  Descricao                                      บฑฑ
ฑฑบ  MARCIO  บ 18/10/05 บ  Acrescentado campo UM ao relat๓rio e ajustado  บฑฑ
ฑฑบ          บ          บ  campo QTD                                      บฑฑ
ฑฑบ          บ          บ                                                 บฑฑ
ฑฑศออออออออออสออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*****************************************************************************
User Function ImdR050B()
*****************************************************************************

	Private cPerg := 'IMDR05'

	IF CVERSAO <> "MP8.11"
		cPerg := PADR(cPerg,10)
	ENDIF

	SX1->( dbSetOrder( 1 ) )

	If !SX1->( dbSeek( cPerg ) )

		SX1->( RecLock( 'SX1', .t. ) )
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := '01'
		SX1->X1_PERGUNT := 'Imprime marcados?'
		SX1->X1_VARIAVL := 'mv_ch01'
		SX1->X1_TIPO    := 'N'
		SX1->X1_TAMANHO := 1
		SX1->X1_GSC     := 'C'
		SX1->X1_VAR01   := 'mv_par01'
		SX1->X1_DEF01   := 'Sim'
		SX1->X1_DEF02   := 'Nao'
		SX1->( MsUnlock() )

		SX1->( RecLock( 'SX1', .t. ) )
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := '02'
		SX1->X1_PERGUNT := 'Pedido:'
		SX1->X1_VARIAVL := 'mv_ch02'
		SX1->X1_TIPO    := 'C'
		SX1->X1_TAMANHO := 6
		SX1->X1_GSC     := 'G'
		SX1->X1_VALID   := 'Vazio() .or. ExistCpo("SC5")'
		SX1->X1_VAR01   := 'mv_par02'
		SX1->( MsUnlock() )
	EndIf

	If !SX1->( dbSeek( cPerg + '03' ) )

		SX1->( RecLock( 'SX1', .t. ) )
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := '03'
		SX1->X1_PERGUNT := 'Emissao a partir de:'
		SX1->X1_VARIAVL := 'mv_ch03'
		SX1->X1_TIPO    := 'D'
		SX1->X1_TAMANHO := 8
		SX1->X1_GSC     := 'G'
		SX1->X1_VALID   := 'mv_par03>CtoD("01/11/03").and.mv_par03<=dDataBase'
		SX1->X1_VAR01   := 'mv_par03'
		SX1->( MsUnlock() )
	EndIf

	DO WHILE Pergunte( cPerg, .t. )

		Private cString   := 'SC5'
		Private cTitulo   := 'Pedidos de Venda - Separacao'
		Private cDesc1    := OemToAnsi( 'Este programa vai emitir o relat๓rio de Pedidos de Venda' )
		Private cDesc2    := OemToAnsi( 'para separacao conforme os parโmetros informados pelo' )
		Private cDesc3    := OemToAnsi( 'usuแrio.' )
		Private cCabec1   := ''
		Private cCabec2   := ''
		Private aReturn   := { 'Zebrado', 1,'Administracao', 2, 2, 1, '',1 }
		Private cNomeProg := 'IMDR050b'
		Private cTamanho  := 'P'
		Private nLastKey  := 0
		Private m_pag     := 1
		Private cNomeRel  := Time()
		cNomeRel  := ( DtoS( Date() ) + SubStr( cNomeRel, 1, 2 ) + SubStr( cNomeRel, 4, 2 ) + SubStr( cNomeRel, 7, 2 ) )
		Private wnrel     //:= SetPrint( cString, cNomeRel, cPerg, cTitulo, cDesc1, cDesc2, cDesc3, .f., '', .t., cTamanho,, .f. )

		/*
		If nLastKey == 27
		Set Filter to
		Return
		EndIf

		SetDefault( aReturn, cString )

		If nLastKey == 27
		Set Filter to
		Return
		EndIf
		*/

		Processa( { || RunProc() }, cTitulo, 'Verificando Pedidos de Venda...' )

	END DO
	Return

*****************************************************************************
Static Function RunProc()
*****************************************************************************

	Local oDlg, oBut1, oBut2, oList
	Local aPedidos    := Array(0)
	Local aItensPV    := Array(0)
	Local nItProc     := 0
	Local nItValid    := 0
	Private cQuery    := ""
	Private cPedidos  := ""
	Private lImpresso := .F.
	Public dDataCom   := CToD("  /  /  ")
	Public cHRLCom    := ""
	Public cUSRCom    := ""
	Public dDataCre   := CToD("  /  /  ")
	Public cUSRCre    := ""
	Public cHRLCre    := ""

	//SUA->( dbOrderNickName( 'UA_NUMSC5' ) )
	SUA->(DbSetOrder(8))

	// query para analisar os pedidos que podem ser impressos...
	cQuery := "select C5_FILIAL, C5_NUM, C5_TIPFAT, C5_NUMSUA, sum( C6_QTDVEN ) C6_QTDVEN, sum( C9_QTDLIB ) C9_QTDLIB"
	cQuery += " from ("
	// seleciono a quantidade total dos pedidos de venda que possuem algum item apto a ser faturado...
	cQuery += " select C5_FILIAL, C5_NUM, C5_TIPFAT, C5_NUMSUA, sum( C6_QTDVEN ) C6_QTDVEN, 0 C9_QTDLIB"
	cQuery += "  from " + RetSqlName( 'SC5' ) + " SC5, " + RetSqlName( 'SC6' ) + " SC6"
	cQuery += "  where C5_FILIAL = '" + xFilial( 'SC5' ) + "'"
	//cQuery += "  and C5_EMISSAO >= '20031101'"
	cQuery += "  and C5_EMISSAO >= '" + DtoS( mv_par03 ) + "'"
	cQuery += "  and SC5.D_E_L_E_T_ = ' '"
	cQuery += If( !Empty( mv_par02 ), " and C5_NUM = '" + mv_par02 + "'", "" )
	// verifica se o pedido possui algum item apto a ser faturado...
	cQuery += "  and exists ("
	cQuery += "   select C9_PEDIDO"
	cQuery += "    from " + RetSqlName( 'SC9' ) + " SC9B"
	cQuery += "    where SC9B.C9_FILIAL = SC5.C5_FILIAL"
	cQuery += "    and SC9B.C9_PEDIDO = SC5.C5_NUM"
	cQuery += "    and SC9B.C9_SERIENF = ' '"
	cQuery += "    and SC9B.C9_NFISCAL = ' '"
	cQuery += "    and SC9B.C9_BLCRED = ' '"
	cQuery += "    and SC9B.C9_BLEST = ' '"
	cQuery += "    and SC9B.D_E_L_E_T_ = ' ' )"
	cQuery += "  and C6_FILIAL = C5_FILIAL"
	cQuery += "  and C6_NUM = C5_NUM"
	cQuery += "  and SC6.D_E_L_E_T_ = ' '"
	cQuery += "  group by C5_FILIAL, C5_NUM, C5_TIPFAT, C5_NUMSUA"
	cQuery += " union all"
	// seleciono a quantidade total dos itens aptos a serem faturados...
	cQuery += " select C5_FILIAL,C5_NUM, C5_TIPFAT, C5_NUMSUA, 0 C6_QTDVEN, sum( C9_QTDLIB ) C9_QTDLIB"
	cQuery += "  from " + RetSqlName( 'SC5' ) + " SC5, " + RetSqlName( 'SC9' ) + " SC9"
	cQuery += "  where C5_FILIAL = '" + xFilial( 'SC5' ) + "'"
	//cQuery += "  and C5_EMISSAO >= '20031101'"
	cQuery += "  and C5_EMISSAO >= '" + DtoS( mv_par03 ) + "'"
	cQuery += "  and SC5.D_E_L_E_T_ = ' '"
	cQuery += If( !Empty( mv_par02 ), " and C5_NUM = '" + mv_par02 + "'", "" )
	cQuery += "  and C9_FILIAL = C5_FILIAL"
	cQuery += "  and C9_PEDIDO = C5_NUM"
	cQuery += "  and C9_SERIENF = ' '"
	cQuery += "  and C9_NFISCAL = ' '"
	cQuery += "  and C9_BLCRED = ' '"
	cQuery += "  and C9_BLEST = ' '"
	cQuery += "  and SC9.D_E_L_E_T_ = ' '"
	cQuery += "  group by C5_FILIAL, C5_NUM, C5_TIPFAT, C5_NUMSUA )"
	cQuery += "group by C5_FILIAL, C5_NUM, C5_TIPFAT, C5_NUMSUA"

	MEMOWRIT("C:\SQLSIGA\IMDR050B_SC5TMP.TXT", cQuery)
	dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC5TMP', .t., .t. )

	TCSetField( 'SC5TMP', 'C6_QTDVEN' , 'N', 14, 4 )
	TCSetField( 'SC5TMP', 'C9_QTDLIB' , 'N', 14, 4 )

	// analisa os pedidos que podem ser impressos...
	//dbGotop()
	While !Eof()

		nItProc++

		IncProc( 'Analisando Pedido ' + SC5TMP->C5_NUM )

		// verifica se foi gravado pela tela da verdade...
		**//	If !Empty( SC5TMP->C5_NUMSUA ) .AND. SC5TMP->CLIENTE <>'N00000'

		// verifica se ja terminou gravacao...
		**//		If SUA->( !dbSeek( xFilial( 'SUA' ) + SC5->C5_NUM, .f. ) )

		**//			dbSkip()
		**//			Loop
		**//		EndIf
		**//	EndIf

		// se for faturamento parcial ou a quantidade total do pedido eh igual a quantidade liberada...
		If SC5TMP->C5_TIPFAT == '1' .or. SC5TMP->C6_QTDVEN == SC5TMP->C9_QTDLIB

			cPedidos += "'" + SC5TMP->C5_NUM + "',"
		EndIf

		dbSkip()
	End

	//SC5TMP->( dbCloseArea() )
	dbSelectArea('SC5TMP')
	dbCloseArea()

	dbSelectArea('SC5')

	If Empty( cPedidos )

		MsgStop( 'Nao existem pedidos de separacao a serem impressos', cTitulo )
	Else
		// query somente com os pedidos que podem ser impressos...
		cQuery := "select C6_FILIAL, C6_NUM, C6_ITEM, C9_SEQUEN, C6_PRODUTO, C9_QTDLIB, C9_PRCVEN,"
		cQuery += "B1_UM, B1_REFER, B1_PESO, B1_MARCA, B1_ORIGEM, C6_CLI, C6_LOJA, C5_EMISSAO "

		cQuery += " from " + RetSQLName( 'SC6' ) + " SC6, " + RetSQLName( 'SC9' ) + " SC9, " + RetSQLName( 'SB1' ) + " SB1, " + RetSQLName( 'SC5' ) + " SC5"

		cQuery += " where C6_FILIAL = '" + xFilial( 'SC6' ) + "'"
		cQuery += " and C6_NUM in (" + Left( cPedidos, Len( cPedidos ) - 1 ) + ")"
		cQuery += " and C6_IMPEMB = " + If( mv_par01 = 1, "'S'", "' '" )
		cQuery += " and SC6.D_E_L_E_T_ = ' '"

		cQuery += " and C9_FILIAL = '" + xFilial( 'SC9' ) + "'"
		cQuery += " and C9_PEDIDO = C6_NUM"
		cQuery += " and C9_ITEM = C6_ITEM"
		cQuery += " and C9_SERIENF = ' '"
		cQuery += " and C9_NFISCAL = ' '"
		cQuery += " and C9_BLEST = ' '"
		cQuery += " and C9_BLCRED = ' '"
		cQuery += " and SC9.D_E_L_E_T_ = ' '"

		cQuery += " and C5_FILIAL = C6_FILIAL"
		cQuery += " and C5_NUM = C6_NUM"
		cQuery += " and SC5.D_E_L_E_T_ = ' '"

		cQuery += " and B1_FILIAL = '" + xFilial( 'SB1' ) + "'"
		cQuery += " and B1_COD = C9_PRODUTO"
		cQuery += " and SB1.D_E_L_E_T_ = ' '"

		cQuery += " order by C6_FILIAL, C6_NUM, B1_REFER, C6_PRODUTO"

		dbUseArea( .t., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC6TMP', .t., .t. )

		TCSetField( 'SC6TMP', 'C9_QTDLIB' , 'N', 14, 4 )
		TCSetField( 'SC6TMP', 'C9_PRCVEN' , 'N', 14, 4 )
		TCSetField( 'SC6TMP', 'B1_PESO'   , 'N', 11, 4 )
		TCSetField( 'SC6TMP', 'C5_EMISSAO', 'D', 08, 0 )

		dbselectarea('SC6TMP')
		SC6TMP->( DBGOTOP())
		If SC6TMP->( Eof() )

			MsgStop( 'Nao existem pedidos de separacao a serem impressos.', cTitulo )
		Else
			MEMOWRIT("C:\SQLSIGA\IMDR050B_SC6TMP.TXT", cQuery)
			Do While SC6TMP->( !Eof() )

				nItValid++

				If aScan(aPedidos, {|x| x[1]+x[2] = SC6TMP->C6_FILIAL+SC6TMP->C6_NUM}) = 0

					SA1->( dbSeek(xFilial('SA1')+SC6TMP->C6_CLI+SC6TMP->C6_LOJA) )

					Aadd(aPedidos,{SC6TMP->C6_FILIAL,;
					SC6TMP->C6_NUM,;
					SC6TMP->C5_EMISSAO,;
					SC6TMP->C6_CLI,;
					SC6TMP->C6_LOJA,;
					SA1->A1_NOME})

				EndIf

				Aadd(aItensPV, {SC6TMP->C6_FILIAL,;
				SC6TMP->C6_NUM,;
				SC6TMP->C6_ITEM,;
				SC6TMP->C6_PRODUTO,;
				SC6TMP->C9_QTDLIB,;
				SC6TMP->C9_PRCVEN,;
				SC6TMP->B1_REFER,;
				SC6TMP->B1_PESO,;
				SC6TMP->B1_MARCA,;
				SC6TMP->B1_ORIGEM,;
				SC6TMP->C9_SEQUEN,;
				SC6TMP->B1_UM})
				dbSkip()
			EndDo

			// dialogo com o usuario
			DEFINE MSDIALOG oDlg TITLE 'Pedidos a Separar - Itens Processados: ( ' + AllTrim(Str(nItProc)) + ' )  Validos: ( '+ AllTrim(Str(nItValid)) + ' )' FROM 0,0 TO 18,80 OF oMainWnd
			DEFINE SBUTTON oBut1 FROM 115,130 TYPE 01 ENABLE OF oDlg PIXEL ACTION(RodaRel(aPedidos, aItensPV))
			DEFINE SBUTTON oBut2 FROM 115,200 TYPE 02 ENABLE OF oDlg PIXEL ACTION( Iif(MarcaPV(aItensPV), (aPedidos:=Array(0), oDlg:End()),.F.) )

			@ 02,02  LISTBOX oList FIELDS HEADER  'Filial','Pedido','Emissao','Cliente','Loja','Nome' SIZE 300,105 PIXEL OF oDlg

			oList:Align := 3
			oList:SetArray(aPedidos)
			oList:bLine:={|| {   aPedidos[oList:nAt,01],;
			aPedidos[oList:nAt,02],;
			aPedidos[oList:nAt,03],;
			aPedidos[oList:nAt,04],;
			aPedidos[oList:nAt,05],;
			aPedidos[oList:nAt,06]}}
			oList:Refresh()

			ACTIVATE MSDIALOG oDlg CENTER

		EndIf

		//SC6TMP->( dbCloseArea() )
		dbSelectArea('SC6TMP')
		dbCloseArea()

		dbSelectArea('SC5')
	EndIf

	Return

*****************************************************************************
Static Function RodaRel(aPedidos, aItensPV)
*****************************************************************************
/*
	nLastKey := 0

	wnrel := SetPrint( cString, cNomeRel, cPerg, cTitulo, cDesc1, cDesc2, cDesc3, .f., '', .t., cTamanho,, .f. )

	If nLastKey == 27
		Set Filter to
		Return
	EndIf

	SetDefault( aReturn, cString )

	If nLastKey == 27
		Set Filter to
		Return
	EndIf

	Processa( { || RptDetail(aPedidos, aItensPV) } )
*/

Local cFilePrint := CriaTrab( ,.F. ) + '.pdf' 
Local lAdjustToLegacy := .T.
Local cPathInServer := '\system\pdf\'
Local lDisableSetup := .T.
Local lTReport := .F.
Local cPrinter :=  ''
Local lServer := .F.
Local lPDFAsPNG := .F.
Local lRaw := .F.
Local lViewPDF := .T.
Local nQtdCopy := NIL
Local lSetView := .T.

Local oBruVE := TBrush():New2(,CLR_HRED	)
Local oBruCI := TBrush():New2(,CLR_GRAYH	)
Local oBruAM := TBrush():New2(,CLR_YELLOW	)
Local oBruAZ := TBrush():New2(,CLR_BLUE 	)
Local oBruVD := TBrush():New2(,CLR_ORANGE	)
Local oBruBR := TBrush():New2(,CLR_WHITE	)

Local oTFont 
Local oPrn 

Local nDevice := 6 
Local cLocalPath := 'SERVIDOR\spool\' 
Local nPaperSize := 9 

oPrn := FWMSPrinter():New(cFilePrint, nDevice, lAdjustToLegacy ,cPathInServer, lDisableSetup, lTReport, @oPrn, cPrinter, lServer, lPDFAsPNG, lRaw, lViewPDF )
oPrn:SetLandscape() 
oPrn:SetPaperSize(nPaperSize)
oPrn:SetMargin(10,10,10,10)
oPrn:SetViewPDF(lSetView) 


oPrn:StartPage()

RptDetail(aPedidos, aItensPV, @oPrn)

//Cabecalho(oPrn)

CabItens(oPrn)

Itens(oPrn)

DLibPed(oPrn)

Roddape(oPrn)

oPrn:EndPage()

oPrn:Preview()

Return
*******************************************************************************
Static Function Cabecalho(oPrn)
*******************************************************************************

	//Prepara Dados
	Local cCliImdepa  := GetMV('MV_IMDEPA')

	Cabec( cTitulo, cCabec1, cCabec2, cNomeProg, cTamanho, nTipo )

	If !SC5->C5_TIPO $ 'DB'

		SA1->( dbSeek( xFilial( 'SA1' ) + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .f. ) )

		cCliente := SA1->A1_COD + '/' + SA1->A1_LOJA + ' ' + SA1->A1_NOME
		cEndFatu := AllTrim( U_ALTEND(SA1->A1_END) ) + ', ' + AllTrim( Str( SA1->A1_NUMEND, 6 ) )
		cCidFatu := AllTrim( SA1->A1_MUN ) + ' - ' + SA1->A1_EST
		//By Edivaldo Gon็alves Cordeiro
		//Setei o Endere็o de Entrega para A1_ENDENT, onde antes era o de Cobra็a A1_ENDCOB
		cEndEntr := AllTrim( SA1->A1_ENDENT) + ', ' + AllTrim( Str( SA1->A1_NUMENTR, 6 ) )
		cCidEntr := AllTrim( SA1->A1_MUN ) + ' - ' + SA1->A1_EST
	Else
		SA2->( dbSeek( xFilial( 'SA2' ) + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .f. ) )

		If SA2->A2_ESTRATG = 'S'

			SZZ->( dbSetOrder( 1 ) )
			SZZ->( dbSeek( xFilial( 'SZZ' ) + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .f. ) )
		EndIf

		cCliente := SA2->A2_COD + '/' + SA2->A2_LOJA + ' ' + If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_NOME, SA2->A2_NOME )
		cEndFatu := AllTrim( If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_END, SA2->A2_END ) )
		cCidFatu := AllTrim( If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_NUM, SA2->A2_MUN ) ) + ' - ' + SA2->A2_EST
		cEndEntr := AllTrim( If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_END, SA2->A2_END ) )
		cCidEntr := AllTrim( If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_NUM, SA2->A2_MUN ) ) + ' - ' + SA2->A2_EST
	EndIf


oPrn:Box( 100 , 50 , 250 , 2930 , '02' )
oPrn:Line( 270 , 50 , 2200 , 50 , 0 , '01'  )
oPrn:Line( 270 , 2930 , 2200 , 2930 , 0 , '01'  )


oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 130 , 60 , Alltrim(SM0->M0_NOME)  , oFont ,   , 0 , ) //oPrn:Say( 130 , 60 , 'IMDEPA - CD PORTO ALEGRE ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -18) ; oFont:Bold 	:= .T. 
oPrn:Say( 160 , 1000 , 'Pedido de Venda - Separa็ใo WMS ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -12)
oPrn:Say( 130 , 2530 , 'Emissใo: '+ dToc(dDataBase) + ' - ' + Substr(Time(),1,5) , oFont ,   , 0 , ) //oPrn:Say( 130 , 2530 , 'Emissใo: 11/12/17 - 09:33 ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 230 , 60 , 'Visto Expedi็ใo em : ____/____/____  ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 230 , 650 , 'Visto : ______________ ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 230 , 1050 , 'NF : ______________ ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 230 , 2760 , 'Pแgina: 01' , oFont ,   , 0 , ) 


oPrn:Line( 270 , 50 , 270 , 2930 , 0 , '01'  )


oFont :=  TFont():New( 'Courier new' , , -14);oFont:Bold 	:= .T. 
oPrn:Say( 320 , 560 , 'DADOS COMERCIAIS ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -12);oFont:Bold 	:= .T. 
oPrn:Say( 400 , 70 , 'Pedido............:  ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -12);oFont:Bold 	:= .T. 
oPrn:Say( 450 , 70 , 'Ordem de Compra...:  ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -12);oFont:Bold 	:= .T. 
oPrn:Say( 500 , 70 , 'Cliente...........:  ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -12);oFont:Bold 	:= .T. 
oPrn:Say( 550 , 70 , 'Segmento..........:  ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -12);oFont:Bold 	:= .T. 
oPrn:Say( 600 , 70 , 'Representante.....:  ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -12);oFont:Bold 	:= .T. 
oPrn:Say( 650 , 70 , 'Vendedor..........:  ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -12);oFont:Bold 	:= .T. 
oPrn:Say( 700 , 70 , 'Condi็ใo de Pagto.:  ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -12);oFont:Bold 	:= .T. 
oPrn:Say( 750 , 70 , 'Origem Produto....:  ' , oFont ,   , 0 , ) 

***********************
// Variaveis Comerciais
*********************** 
oFont :=  TFont():New( 'Courier new' , , -12) 

	If !Empty(SC5->C5_NUMSUA) .AND. cCliImdepa == SC5->C5_CLIENTE
		oPrn:Say( 400 , 400 , SC5->C5_NUM '  **PEDIDO ALOCADO**', oFont ,   , 0 , ) 
	Else
		oPrn:Say( 400 , 400 , SC5->C5_NUM , oFont ,   , 0 , )
	EndIf

oPrn:Say( 450 , 400 , 'VOrdem de Compra  ' , oFont ,   , 0 , ) 

oPrn:Say( 500 , 400 , cCliente      , oFont ,   , 0 , ) 

oPrn:Say( 550 , 400 , 'VSegmento  ' , oFont ,   , 0 , ) 

oPrn:Say( 600 , 400 , cNomeVend2 , oFont ,   , 0 , ) 

oPrn:Say( 650 , 400 , cNomeVend1 , oFont ,   , 0 , ) 

oPrn:Say( 700 , 400 ,  Alltrim( SE4->E4_DESCRI ) , oFont ,   , 0 , ) 

oPrn:Say( 750 , 400 , '0 -> Nacional, 1 -> Importado, 2 -> Nacionalizado' , oFont ,   , 0 , ) 

oPrn:Line( 300 , 1415 , 750 , 1415 , 0 , '01'  )

oFont :=  TFont():New( 'Courier new' , , -14);oFont:Bold 	:= .T. 
oPrn:Say( 320 , 2000 , 'DADOS ENTREGA ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -12);oFont:Bold 	:= .T. 
oPrn:Say( 400 , 1435 , 'Endere็o Fatura...:  ' , oFont ,   , 0 , ) 

oPrn:Say( 450 , 1435 , 'Cidade Fatura.....:  ' , oFont ,   , 0 , ) 

oPrn:Say( 500 , 1435 , 'Endere็o Entrega..:  ' , oFont ,   , 0 , ) 

oPrn:Say( 550 , 1435 , 'Cidade Entrega....:  ' , oFont ,   , 0 , ) 

oPrn:Say( 600 , 1435 , 'Transportadora....:  ' , oFont ,   , 0 , ) 

oPrn:Say( 650 , 1435 , 'Tipo de Frete.....:  ' , oFont ,   , 0 , ) 

oPrn:Say( 700 , 1435 , 'Valor do Frete....:  ' , oFont ,   , 0 , ) 

***********************
// Variaveis Entrega
***********************
oFont :=  TFont():New( 'Courier new' , , -12)
oPrn:Say( 400 , 1765 , cEndFatu			 , oFont ,   , 0 , ) 

 
oPrn:Say( 450 , 1765 , cCidFatu          , oFont ,   , 0 , ) 

oPrn:Say( 500 , 1765 , cEndEntr           , oFont ,   , 0 , ) 

oPrn:Say( 550 , 1765 , cCidEntr           , oFont ,   , 0 , ) 

oPrn:Say( 600 , 1765 , Alltrim( SA4->A4_NOME ) , oFont ,   , 0 , ) 

oPrn:Say( 650 , 1765 , IIF(SC5->C5_TPFRETE='2','1','2') , oFont ,   , 0 , ) 

oPrn:Say( 700 , 1765 , +Transform(SUA->UA_FRETE,"@E 999,999.99") , oFont ,   , 0 , ) 

// Linha Fim Cabecalho
oPrn:Line( 770 , 50 , 770 , 2930 , 0 , '-6'  )


oFont :=  TFont():New( 'Courier new' , , -14);oFont:Bold 	:= .T. 
oPrn:Say( 820 , 70 , 'Observa็ใo:  ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -14) 
oPrn:Say( 820 , 300 ,  SUA->UA_OBSEXP , oFont ,   , 0 , ) 


// Linha Fim Observacao 
oPrn:Line( 850 , 50 , 850 , 2930 , 0 , '01'  )

Return
*******************************************************************************
Static Function CabItens(oPrn)
*******************************************************************************

// Cabecalho dos itens
oPrn:Box( 870 , 65 , 2090 , 2915 , '01' )

oFont :=  TFont():New( 'Courier new' , , -16);oFont:Bold 	:= .T. 
oPrn:Say( 907 , 130 , 'Endere็o ' , oFont ,   , 0 , ) 

oPrn:Say( 907 , 400 , 'Qtd ' , oFont ,   , 0 , ) 

oPrn:Say( 907 , 650 , 'Codigo ' , oFont ,   , 0 , ) 

oPrn:Say( 907 , 1000 , 'Descri็ใo ' , oFont ,   , 0 , ) 
 
oPrn:Say( 907 , 2000 , 'Marca ' , oFont ,   , 0 , ) 
 
oPrn:Say( 907 , 2300 , 'Origem ' , oFont ,   , 0 , ) 
 
oPrn:Say( 907 , 2500 , 'UM ' , oFont ,   , 0 , ) 
 
oPrn:Say( 907 , 2700 , 'Peso Un ' , oFont ,   , 0 , ) 


// Linha fim Cabecalho Itens
oPrn:Line( 920 , 90 , 920 , 2890 , 0 , '01'  )


Return
*******************************************************************************
Static Function Itens(oPrn)
*******************************************************************************

// Item 01

oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 970 , 130 , 'CF08250 ' , oFont ,   , 0 , ) 

oPrn:Say( 970 , 400 , '100.000' , oFont ,   , 0 , ) 

oPrn:Say( 970 , 650 , '000000092851A' , oFont ,   , 0 , ) 

oPrn:Say( 970 , 1000 , 'R2AT-1.1/4" 1813PSI - 2SN-20 125BAR *20M' , oFont ,   , 0 , ) 

oPrn:Say( 970 , 2000 , 'GBR/GTOP ' , oFont ,   , 0 , ) 

oPrn:Say( 970 , 2300 , '2 ' , oFont ,   , 0 , ) 

oPrn:Say( 970 , 2500 , 'PC ' , oFont ,   , 0 , ) 

oPrn:Say( 970 , 2700 , '30 ' , oFont ,   , 0 , ) 

// Item 02
oPrn:Line( 1000 , 90 , 1000 , 2890 , 0 , '-2'  )

oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 1050 , 130 , 'CF08250 ' , oFont ,   , 0 , ) 
 
oPrn:Say( 1050 , 400 , '100.000' , oFont ,   , 0 , ) 
 
oPrn:Say( 1050 , 650 , '000000092851A' , oFont ,   , 0 , ) 
 
oPrn:Say( 1050 , 1000 , 'R2AT-1.1/4" 1813PSI - 2SN-20 125BAR *20M' , oFont ,   , 0 , ) 
 
oPrn:Say( 1050 , 2000 , 'GBR/GTOP ' , oFont ,   , 0 , ) 
 
oPrn:Say( 1050 , 2300 , '2 ' , oFont ,   , 0 , ) 
 
oPrn:Say( 1050 , 2500 , 'PC ' , oFont ,   , 0 , ) 
 
oPrn:Say( 1050 , 2700 , '30 ' , oFont ,   , 0 , ) 
// Item 03
oPrn:Line( 1080 , 90 , 1080 , 2890 , 0 , '-2'  )
// Item 04
oPrn:Line( 1160 , 90 , 1160 , 2890 , 0 , '-2'  )
// Item 04
oPrn:Line( 1240 , 90 , 1240 , 2890 , 0 , '-2'  )
// Item 04
oPrn:Line( 1320 , 90 , 1320 , 2890 , 0 , '-2'  )
// Item 04
oPrn:Line( 1400 , 90 , 1400 , 2890 , 0 , '-2'  )
// Item 04
oPrn:Line( 1480 , 90 , 1480 , 2890 , 0 , '-2'  )
// Item 04
oPrn:Line( 1560 , 90 , 1560 , 2890 , 0 , '-2'  )
// Item 04
oPrn:Line( 1640 , 90 , 1640 , 2890 , 0 , '-2'  )
// Item 04
oPrn:Line( 1720 , 90 , 1720 , 2890 , 0 , '-2'  )
// Item 04
oPrn:Line( 1800 , 90 , 1800 , 2890 , 0 , '-2'  )
// Item 04
oPrn:Line( 1880 , 90 , 1880 , 2890 , 0 , '-2'  )
// Item 04
oPrn:Line( 1960 , 90 , 1960 , 2890 , 0 , '-2'  )
// Item 04
oPrn:Line( 2040 , 90 , 2040 , 2890 , 0 , '-2'  )

Return
*******************************************************************************
Static Function DLibPed(oPrn)
*******************************************************************************

// Dados Liberacao do Pedido
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 2080 , 90 , 'Dados Libera็ใo do Pedido ' , oFont ,   , 0 , ) 
 
oPrn:Say( 2080 , 600 , 'COMERCIAL: ' , oFont ,   , 0 , ) 
 
oPrn:Say( 2080 , 750 , '11/12/17 - 08:30:29 - Paula Lidiele F   ' , oFont ,   , 0 , ) 
 
oPrn:Say( 2080 , 1650 , 'CREDITO: ' , oFont ,   , 0 , ) 
 
oPrn:Say( 2080 , 1800 , '11/12/17 - 08:31:29 - Paula Lidiele F' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -12) ;oFont:Bold 	:= .T. 
oPrn:Say( 2080 , 2500 , 'Peso Total: ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -12) ;oFont:Bold 	:= .F.
oPrn:Say( 2080 , 2700 , '     300.00 ' , oFont ,   , 0 , ) 

Return
*******************************************************************************
Static Function Roddape(oPrn)
*******************************************************************************

// Rodape do Relatorio
oPrn:Box( 2100 , 50 , 2400 , 2930 , '01' )

oFont :=  TFont():New( 'Courier new' , , -14);oFont:Bold 	:= .T. 
oPrn:Say( 2130 , 1285 , 'FICHA DE SEPARAวรO ' , oFont ,   , 0 , ) 

oPrn:Line( 2135 , 200 , 2135 , 2910 , 0 , '-2'  )

oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T. 
oPrn:Say( 2185 , 200 , 'SEPARADOR.....:_____________________________________________ ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T. 
oPrn:Say( 2235 , 200 , 'EMBALADOR.....:_____________________________________________ ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T. 
oPrn:Say( 2285 , 200 , 'CONFERENTE....:_____________________________________________ ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T. 
oPrn:Say( 2335 , 200 , 'QTD DE ERROS..:_____________________________________________ ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T. 
oPrn:Say( 2385 , 200 , 'PESO BRUTO....:_____________________________________________ ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T. 
oPrn:Say( 2185 , 1565 , 'INICIO........:_____________________________________________ ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T. 
oPrn:Say( 2235 , 1565 , 'TERMINO.......:_____________________________________________ ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T. 
oPrn:Say( 2285 , 1565 , 'FATURAMENTO...:_____________________________________________ ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T. 
oPrn:Say( 2335 , 1565 , 'TIPOS DE ERROS:_____________________________________________ ' , oFont ,   , 0 , ) 

oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T. 
oPrn:Say( 2385 , 1565 , 'QTD VOLUMES...:_____________________________________________ ' , oFont ,   , 0 , ) 

Return() 

*****************************************************************************
Static Function RptDetail(aPedidos, aItensPV, oPrn )
*****************************************************************************

	Local nValTot, nPesTot, cKey
	Local nStart, nItem
	Local cQuery
	Private cNomeVend1, cNomeVend2
	Private nTipo := If( aReturn[4] == 1, 15, 18 )

	ProcRegua( Len(aPedidos) )

	SA1->( dbSetOrder( 1 ) )
	SA2->( dbSetOrder( 1 ) )
	SA3->( dbSetOrder( 1 ) )
	SA4->( dbSetOrder( 1 ) )
	SC5->( dbSetOrder( 1 ) )
	SC6->( dbSetOrder( 1 ) )
	SE4->( dbSetOrder( 1 ) )
	SU7->( dbSetOrder( 1 ) )
	SUA->(DbSetOrder(8))

	For nStart := 1 To Len(aPedidos)

		// ajusta variaveis de controle
		cFilPed   := aPedidos[nStart,1]
		cNumPed   := aPedidos[nStart,2]

		IncProc( 'Imprimindo pedido ' + cNumPed )

		SC5->( dbSeek( cFilPed + cNumPed, .f. ) )
		SA3->( dbSeek( xFilial( 'SA3' ) + SC5->C5_VEND1, .f. ) )
		SA3->( dbSeek( xFilial( 'SA3' ) + SC5->C5_VEND2, .f. ) )	; cNomeVend2 := AllTrim( SA3->A3_NOME )
		SA4->( dbSeek( xFilial( 'SA4' ) + SC5->C5_TRANSP, .f. ) )
		SE4->( dbSeek( xFilial( 'SE4' ) + SC5->C5_CONDPAG, .f. ) )
		SU7->( dbSeek( xFilial( 'SU7' ) + SC5->C5_OPERADO, .f. ) )  ; cNomeVend1 := AllTrim( SU7->U7_NOME )
		SUA->( dbSeek( xFilial( 'SUA' ) + SC5->C5_NUM, .f. ) )

		nValTot := 0
		nPesTot := 0
		cKey    := cFilPed + cNumPed

		nPos := Ascan(aItensPV, {|x| x[1]+x[2] = cKey})
		For nItem := nPos To Len(aItensPV)

			cFilPed     := aItensPV[nItem,1]   // SC6TMP->C6_FILIAL
			cUM			:= aItensPV[nItem,12]  // SC6TMP->B1_UM
			cNumPed     := aItensPV[nItem,2]   // SC6TMP->C6_NUM
			cNumItem    := aItensPV[nItem,3]   // SC6TMP->C6_ITEM
			nC9_QTDLIB  := aItensPV[nItem,5]   // SC6TMP->C9_QTDLIB
			cB1_REFER   := aItensPV[nItem,7]   // SC6TMP->B1_REFER
			cB1_MARCA   := aItensPV[nItem,9]   // SC6TMP->B1_MARCA
			cB1_ORIGEM  := aItensPV[nItem,10]  // SC6TMP->B1_ORIGEM
			nB1_PESO    := aItensPV[nItem,8]   // SC6TMP->B1_PESO
			nC6_PRCVEN  := aItensPV[nItem,6]   // SC6TMP->C9_PRCVEN

			If cFilPed + cNumPed <> cKey
				Exit
			EndIf

			SC6->( dbSeek( cFilPed + cNumPed + cNumItem, .f. ) )

			If nItem > 14 .or. m_pag == 1
				Cabecalho(oPrn)
			EndIf
			/*If pRow() > 14 .or. m_pag == 1	// salto de pagina, neste caso o formulario tem 55 linhas...
				ImpCabec()
				lImpresso := .T.
			EndIf

			
			@ pRow()+2, 000 pSay nC9_QTDLIB   Picture "999999.99" //+3
			@ pRow()  , 010 pSay cUM
			@ pRow()  , 013 pSay cB1_REFER
			@ pRow()  , 034 pSay SubStr( cB1_MARCA, 1, 15 )
			@ pRow()  , 050 pSay cB1_ORIGEM
			@ pRow()  , 052 pSay nB1_PESO Picture "@E 999.9999"
			@ pRow()  , 061 pSay DtoC( SC6->C6_ENTREG )
			*/
			nValTot += nC6_PRCVEN * nC9_QTDLIB
			nPesTot += nB1_PESO * nC9_QTDLIB

			// provisorio, gravacao de tabela de log de impressao...
			// testa a existencia da tabela...
			If !TCCanOpen( 'tImdR050c' )

				// 1o. executar este comando sql para criar a tabela
				cQuery := "create table tImdR050c as"
			Else
				// 1o. executar este comando sql para preencher a tabela
				cQuery := "insert into tImdR050c"
			EndIf

			cQuery += " select C6_FILIAL FILIAL, C6_NUM NUM, C6_ITEM ITEM, C6_PRODUTO PRODUTO, "
			cQuery += " C6_QTDVEN QTDVEN, '" + DtoS( Date() ) + "' DTIMPR, '" + Time() + "' HRIMPR, "
			cQuery += " '" + Str( aReturn[5], 1 ) + "' MIDIA, '" + wnrel + "' ARQUIVO"
			cQuery += " from " + RetSqlName( "SC6" ) + " SC6"
			cQuery += " where C6_FILIAL = '" + SC6->C6_FILIAL + "'"
			cQuery += " and C6_NUM = '" + SC6->C6_NUM + "'"
			cQuery += " and C6_ITEM = '" + SC6->C6_ITEM + "'"
			cQuery += " and C6_PRODUTO = '" + SC6->C6_PRODUTO + "'"
			cQuery += " and SC6.D_E_L_E_T_ = ' '"

			TCSQLExec( cQuery )
			// fim gravacao provisoria...

			//SC6TMP->( dbSkip() )
			//End
		Next

		dbSelectArea("SC9")
		dbSetOrder(1)

		dbSeek( SC6->C6_FILIAL + SC6->C6_NUM ,.f. )

		If pRow() > 50
			ImpCabec()
		EndIf
/*
		@ pRow()+2, 000 pSay 'Valor Total:'
		@ pRow()  , 013 pSay nValTot Picture '@E 9,999,999.99'
		@ pRow()  , 056 psay 'Peso Total:'
		@ pRow()  , 068 pSay nPesTot Picture '@E 999,999.9999'
		@ pRow()+1, 000 pSay __PrtThinLine()  //@ pRow()+1, 000 pSay Replicate( '-', 80 )
		@ pRow()+1, 000 pSay 'Visto Expedicao em ___/___/___     Visto:_________________    NF:_______________'
		@ pRow()+1, 000 pSay __PrtThinLine() //@ pRow()+1, 000 pSay Replicate( '-', 80 )

		@ pRow()+2, 000 pSay "Lib. Pedidos : Comercial "+DtoC(SC9->C9_DTLCOM)+" - "+SC9->C9_HRLCOM+" - "+SC9->C9_USRLCOM
		@ pRow()+1, 000 pSay "Lib. Pedidos : Credito   "+DtoC(SC9->C9_DTLCRE)+" - "+SC9->C9_HRLCRE+" - "+SC9->C9_USRLCRE
*/
		m_pag := 1
	Next
/*
	If aReturn[5] == 1
		Set Printer to
		Commit
		OurSpool( wnrel )
	EndIf
	Ms_Flush()
*/
	Return

*****************************************************************************
Static Function ImpCabec()
*****************************************************************************

	Local cCliImdepa  := GetMV('MV_IMDEPA')

	Cabec( cTitulo, cCabec1, cCabec2, cNomeProg, cTamanho, nTipo )

	If !SC5->C5_TIPO $ 'DB'

		SA1->( dbSeek( xFilial( 'SA1' ) + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .f. ) )

		cCliente := SA1->A1_COD + '/' + SA1->A1_LOJA + ' ' + SA1->A1_NOME
		cEndFatu := AllTrim( U_ALTEND(SA1->A1_END) ) + ', ' + AllTrim( Str( SA1->A1_NUMEND, 6 ) )
		cCidFatu := AllTrim( SA1->A1_MUN ) + ' - ' + SA1->A1_EST
		//By Edivaldo Gon็alves Cordeiro
		//Setei o Endere็o de Entrega para A1_ENDENT, onde antes era o de Cobra็a A1_ENDCOB
		cEndEntr := AllTrim( SA1->A1_ENDENT) + ', ' + AllTrim( Str( SA1->A1_NUMENTR, 6 ) )
		cCidEntr := AllTrim( SA1->A1_MUN ) + ' - ' + SA1->A1_EST
	Else
		SA2->( dbSeek( xFilial( 'SA2' ) + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .f. ) )

		If SA2->A2_ESTRATG = 'S'

			SZZ->( dbSetOrder( 1 ) )
			SZZ->( dbSeek( xFilial( 'SZZ' ) + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .f. ) )
		EndIf

		cCliente := SA2->A2_COD + '/' + SA2->A2_LOJA + ' ' + If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_NOME, SA2->A2_NOME )
		cEndFatu := AllTrim( If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_END, SA2->A2_END ) )
		cCidFatu := AllTrim( If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_NUM, SA2->A2_MUN ) ) + ' - ' + SA2->A2_EST
		cEndEntr := AllTrim( If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_END, SA2->A2_END ) )
		cCidEntr := AllTrim( If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_NUM, SA2->A2_MUN ) ) + ' - ' + SA2->A2_EST
	EndIf

	//Inserido por Edivaldo Gon็alves Cordeiro  em 10/01/2006
	//Imprime a mensagem '**Pedido Gerado Automaticamente**' Quando o Pedido for originado de uma Transfer๊ncia e o cliente
	//for igual แ IMDEPA (N00000)

	/*
	If !Empty(SC5->C5_NUMSUA) .AND. cCliImdepa == SC5->C5_CLIENTE
		@ pRow()+1,000 pSay '**PEDIDO ALOCADO**'
		@ pRow()+2,000 pSay 'Pedido No.........: ' + SC5->C5_NUM
	Else
		@ pRow()+1,000 pSay 'Pedido No.........: ' + SC5->C5_NUM
	Endif

	@ pRow()  ,050 pSay 'Emissao: ' + DtoC( SC5->C5_EMISSAO )
	@ pRow()  ,078 pSay AllTrim(SC5->C5_TIPFAT)
	If MV_PAR01 = 1
		@ pRow(),079 pSay 'R'
	EndIf
	@ pRow()+1,000 pSay 'Ordem de Compra...: '
	@ pRow()+1,000 pSay 'Cliente...........: ' + cCliente
	@ pRow()+1,000 pSay 'Endereco Fatura...: ' + cEndFatu
	@ pRow()+1,000 pSay 'Cidade   Fatura...: ' + cCidFatu
	@ pRow()+1,000 pSay 'Endereco Entrega..: ' + cEndEntr
	@ pRow()+1,000 pSay 'Cidade   Entrega..: ' + cCidEntr
	@ pRow()  ,053 pSay 'Origem.: 0 - Nacional'
	@ pRow()+1,000 pSay 'Condicoes Pgto....: ' + Alltrim( SE4->E4_DESCRI )
	@ pRow()  ,062 pSay '1 - Importado'
	@ pRow()+1,000 pSay 'Representante.....: ' + cNomeVend2
	@ pRow()  ,062 pSay '2 - Nacionalizado'
	@ pRow()+1,000 pSay 'Vendedor Interno..: ' + cNomeVend1
	@ pRow()  ,053 pSay 'Tipo Frete .: '+IIF(SC5->C5_TPFRETE='2','1','2')
	@ pRow()+1,000 pSay 'Transportadora....: ' + Alltrim( SA4->A4_NOME )
	@ pRow()  ,053 pSay 'R$ Frete .: '+Transform(SUA->UA_FRETE,"@E 999,999.99")
	@ pRow()+1,000 pSay 'Observacao........: ' + Substr( SUA->UA_OBSEXP, 01, 45 )
	@ pRow()+1,000 pSay '                    ' + Substr( SUA->UA_OBSEXP, 46, 45 )
	@ pRow()+1, 000 pSay __PrtFatLine()
	@ pRow()+1,000 pSay 'Qtd       UM Referencia           Marca          Ori Peso_Un Data/Hora Prev'
	//@ pRow()+1,000 pSay '------    -- -------------------- --------------- - -------- --------  -----'
	@ pRow()+1, 000 pSay __PrtThinLine()
	*/
	
	
	
Return
*****************************************************************************
Static Function MarcaPV(aItensPV)
*****************************************************************************

	Local lSair      := .T.
	Local nStart
	Local cFilPed
	Local cNumPed
	Local cNumItem
	Local cSequen
	Local cProduto

	SC9->( dbSetOrder( 1 ) )

	If lImpresso
		If MsgYesNo('Marca os Pedidos como ja Impressos?')
			// marca os itens como ja impressos
			Begin Transaction
				For nStart := 1 To Len(aItensPV)
					cFilPed     := aItensPV[nStart,1]   // SC6TMP->C6_FILIAL
					cNumPed     := aItensPV[nStart,2]   // SC6TMP->C6_NUM
					cNumItem    := aItensPV[nStart,3]   // SC6TMP->C6_ITEM
					cSequen     := aItensPV[nStart,11]  // SC6TMP->C9_SEQUEN
					cProduto    := aItensPV[nStart,4]   // SC6TMP->C6_PRODUTO

					If SC6->( dbSeek( cFilPed + cNumPed + cNumItem, .f. ) )

						// grava status de ja impresso...
						SC6->( RecLock( 'SC6', .f. ) )
						SC6->C6_IMPEMB := 'S'
						SC6->( MsUnlock() )

					EndIf

					// incluido por Luciano Correa em 08/06/04 para gravar dt/hr impressao...
					If SC9->( dbSeek( cFilPed + cNumPed + cNumItem + cSequen + cProduto, .f. ) )

						SC9->( RecLock( 'SC9', .f. ) )
						SC9->C9_DTPSEP  := Date()
						SC9->C9_HRPSEP  := Time()
						SC9->C9_USRPSEP := SubStr( cUsuario, 7, 15 )
						SC9->( MsUnlock() )
					Else
						MEMOWRIT("ps"+alltrim(str(seconds()))+".bak", cFilPed + cNumPed + cNumItem + cSequen + cProduto)
					Endif

				Next
			End Transaction
		EndIf
		lSair := .T.
	Else
		If MsgYesNo('Os Pedidos nao foram Impressos! Sair assim mesmo?')
			lSair := .T.
		Else
			lSair := .F.
		EndIf
	EndIf

Return(lSair)
