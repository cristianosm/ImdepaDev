#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#Include 'Totvs.ch'

#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

#Define _NIPCO_	18		//| Numero de intens que cabem na Pagina completa
#Define _NIPFI_	14		//| Numero de intens que cabem na Pagina Final

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


// Define do Array aPedidos 
#Define APDIMPEM 	1 	// C6_IMPEMB  	|-> Pedido Impresso ?
#Define APFILIAL	2 	// C5_FILIAL	|-> Filial
#Define APNUMERO  	3 	// C5_NUM		|-> Numero do Pedido
#Define APEMISSA  	4 	// C5_EMISSAO	|-> Emissao do Pedido
#Define APCLIENT  	5 	// C5_CLIENTE	|-> Codigo do Cliente
#Define APLOJACL  	6 	// C5_LOJACLI	|-> Loja do Cliente
#Define APNOMECL	7	// A1_NOME		|-> Nome do Cliente
#Define APEDGUIA 	8	// C5_PEDGUIA	|-> 


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  º IMDR150w º Autor º Edivaldo Gonçalves  º Data º  02/10/06 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao  º Impressao do Pedido de Venda Separação WMS,auxilio na     º±±
±±º           º separacao dos materiais(Com impressao de Endereco e Lote) º±±
±±º           º Está preparado para imprimir produtos que não estão       º±±
±±º           º habilitado a Rastreabilidade no WMS                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PEDIDO DE SEPARAÇÃO IMDEPA    						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  29/11/2006  Edivaldo Gonçalves  Cordeiro                             ³±±
±±³  Ajustado programa para fazer leitura de produtos que possuem         ³±±
±±ºRastreabilidade(Considerando o serviço ='001' e Tarefa='002' do WMS    ³±±
±±º-----------------------------------------------------------------------³±±
±±º 15/12/2006   Edivaldo Gonçalves Cordeiro                              ³±±
±±º              Corrigido problema na impressão de duplicidade de        ³±±
±±º              Produto X Endereço                                       ³±±
±±³                                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*****************************************************************************
User Function IMDR050w()
*****************************************************************************
	Private cPerg := 'IMDR05'
	Private aPedidos    := Array(0)
	Private _cVersao_ := GetVersao(.F.)

	VerPerg() // Verifica as Perguntas

	Do While Pergunte( cPerg, .T. )

		Private cString   := 'SC5'
		Private cVersao   := 'V.20160130'
		Private cTitulo   := ALLTRIM(GetEnvServer())+'/Ped. de Venda - Separacao WMS '
		Private cDesc1    := OemToAnsi( cVersao+'-Este programa vai emitir o relatório de Pedidos de Venda' )
		Private cDesc2    := OemToAnsi( 'separados pelo WMS, conforme os parâmetros informados pelo' )
		Private cDesc3    := OemToAnsi( 'usuário.Também está compátivel para imprimir produtos que não estã habilitados a Rastreabilidade' )
		Private cCabec1   := ''
		Private cCabec2   := ''
		Private aReturn   := { 'Zebrado', 1,'Administracao', 2, 2, 1, '',1 }
		Private cNomeProg := 'IMDR050b'
		Private cTamanho  := 'P'
		Private nLastKey  := 0
		Private cNomeRel  := Time()
		cNomeRel  := ( DtoS( Date() ) + SubStr( cNomeRel, 1, 2 ) + SubStr( cNomeRel, 4, 2 ) + SubStr( cNomeRel, 7, 2 ) )
		Private wnrel     //:= SetPrint( cString, cNomeRel, cPerg, cTitulo, cDesc1, cDesc2, cDesc3, .F., '', .T., cTamanho,, .F. )

		MsAguarde({||SF4->(RunProc()) },"Pedido Separação...","Estruturando lista de Pedidos ...")

	END DO

	Return

*******************************************************************************
Static Function VerPerg() // Verifica as Perguntas
*******************************************************************************

	IF CVERSAO <> "MP8.11"
		cPerg := PADR(cPerg,10)
	ENDIF

	SX1->( dbSetOrder( 1 ) )

	If !SX1->( dbSeek( cPerg ) )

		SX1->( RecLock( 'SX1', .T. ) )
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

		SX1->( RecLock( 'SX1', .T. ) )
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

		SX1->( RecLock( 'SX1', .T. ) )
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
	
Return

*****************************************************************************
Static Function RunProc() // Executa a Rotina
*****************************************************************************

	Local 	oDlg, oBut1, oBut2, oList
	Local 	aItensFull  := Array(0)
	Local 	aItensTemp 	:={}
	Local 	lRetSemBloqWms

	Local 	oEnable  	:= Loadbitmap( GetResources(), 'ENABLE' )
	Local 	oCinza 		:= Loadbitmap( GetResources(), 'BR_CINZA' )
	Local 	oAzul  		:= Loadbitmap( GetResources(),'FWOCN_RDO_HVR.PNG')

	Private cQuery    	:= ""
	Private cPedidos  	:= ""
	Private lImpresso 	:= .F.
	
	Public 	dDataCom   	:= CToD("  /  /  ")
	Public 	cHRLCom    	:= ""
	Public 	cUSRCom    	:= ""
	Public 	dDataCre   	:= CToD("  /  /  ")
	Public 	cUSRCre    	:= ""
	Public 	cHRLCre    	:= ""

	SUA->(DbSetOrder(8))

	*--------------------------------------------------------*
	//Seleciona os pedidos aptos a impressão para Separação  //
	*--------------------------------------------------------*
	// query para analisar os pedidos que podem ser impressos...
	cQuery := "select C5_FILIAL, C5_NUM, C5_TIPFAT, C5_NUMSUA, sum( C6_QTDVEN ) C6_QTDVEN, sum( C9_QTDLIB ) C9_QTDLIB"
	cQuery += " from ("
	// seleciono a quantidade total dos pedidos de venda que possuem algum item apto a ser faturado...
	cQuery += " select C5_FILIAL, C5_NUM, C5_TIPFAT, C5_NUMSUA, sum( C6_QTDVEN ) C6_QTDVEN, 0 C9_QTDLIB"
	cQuery += "  from " + RetSqlName( 'SC5' ) + " SC5, " + RetSqlName( 'SC6' ) + " SC6"
	cQuery += "  where C5_FILIAL = '" + xFilial( 'SC5' ) + "'"
	cQuery += "  and C5_EMISSAO >= '" + DtoS( mv_par03 ) + "'"
	cQuery += "  and SC5.D_E_L_E_T_ = ' '"
	cQuery += If( !Empty( mv_par02 ), " and C5_NUM = '" + mv_par02 + "'", "" )

	cQuery+=" AND C6_IMPEMB = " + If( mv_par01 = 1, "'S'", "' '" )

	// verifica se o pedido possui algum item apto a ser faturado...
	cQuery += "  and exists ("
	cQuery += "  select C9_PEDIDO"
	cQuery += "  from " + RetSqlName( 'SC9' ) + " SC9B"
	cQuery += "  where SC9B.C9_FILIAL = SC5.C5_FILIAL"
	cQuery += "  and SC9B.C9_PEDIDO = SC5.C5_NUM"

	/////////////JULIO JACOVENKO, em 30/09/2016
	cQuery += "  and SC9B.C9_SERIENF = ' '"
	cQuery += "  and SC9B.C9_NFISCAL = ' '"
	cQuery += "  and SC9B.C9_BLCRED = ' '"
	cQuery += "  and SC9B.C9_BLEST = ' '"
	cQuery += "  and SC9B.C9_STSERV ='3'"
	cQuery += "  and SC9B.D_E_L_E_T_ = ' ' )"
	cQuery += "  and C6_FILIAL = C5_FILIAL"
	cQuery += "  and C6_NUM = C5_NUM"
	cQuery += "  and SC6.D_E_L_E_T_ = ' '"
	cQuery += "  group by C5_FILIAL, C5_NUM, C5_TIPFAT, C5_NUMSUA"
	cQuery += " union all"

	// seleciono a quantidade total dos itens aptos a serem faturados...
	cQuery += " select C5_FILIAL,C5_NUM, C5_TIPFAT, C5_NUMSUA, 0 C6_QTDVEN, sum( C9_QTDLIB ) C9_QTDLIB"
	cQuery += "  from " + RetSqlName( 'SC5' ) + " SC5, " + RetSqlName( 'SC9' ) + " SC9"
	cQuery += "  where C5_FILIAL = '" + xFilial( 'SC5' ) + "'"
	cQuery += "  and C5_EMISSAO >= '" + DtoS( mv_par03 ) + "'"
	cQuery += "  and SC5.D_E_L_E_T_ = ' '"
	cQuery += If( !Empty( mv_par02 ), " and C5_NUM = '" + mv_par02 + "'", "" )

	cQuery += "  and C9_FILIAL = C5_FILIAL"
	cQuery += "  and C9_PEDIDO = C5_NUM"

	/////////////JULIO JACOVENKO, em 30/09/2016
	cQuery += "  and C9_SERIENF = ' '"
	cQuery += "  and C9_NFISCAL = ' '"
	cQuery += "  and C9_BLCRED = ' '"
	cQuery += "  and C9_BLEST = ' '"
	cQuery += "  and C9_STSERV ='3'"

	cQuery += "  and SC9.D_E_L_E_T_ = ' '"
	cQuery += "  group by C5_FILIAL, C5_NUM, C5_TIPFAT, C5_NUMSUA )"
	cQuery += "  group by C5_FILIAL, C5_NUM, C5_TIPFAT, C5_NUMSUA "

	IF SELECT( "SC5TMP1" ) <> 0
		dbSelectArea("SC5TMP1")
		SC5TMP1->(DbCLoseArea())
	Endif

	U_ExecMySql( cSql :=  cQuery, cCursor := 'SC5TMP1', cModo := 'Q', lMostra := .F., lChange := .F. )

	TCSetField( 'SC5TMP1', 'C6_QTDVEN' , 'N', 14, 4 )
	TCSetField( 'SC5TMP1', 'C9_QTDLIB' , 'N', 14, 4 )

	// analisa os pedidos que podem ser impressos...
	SC5TMP1->( DbGotop() )
	While SC5TMP1->( !Eof() )

		/////////////JULIO JACOVENKO, em 30/09/2016
		If  SC5TMP1->C6_QTDVEN == SC5TMP1->C9_QTDLIB
			cPedidos += "'" + SC5TMP1->C5_NUM + "',"
		Else

		EndIf

		dbSkip()
	Enddo

	dbSelectArea('SC5TMP1');dbCloseArea()

	If Empty( cPedidos )

		MsgStop( '*Nao existem pedidos de separacao a serem impressos', cTitulo )
		
		Return
	Else

		cQuery:=" SELECT C5_FILIAL,C5_NUM,C5_CLIENTE,C5_LOJACLI,C5_EMISSAO,C6_IMPEMB,C5_PEDGUIA"
		cQuery+=" FROM "
		cQuery+=RetSqlName( 'SC6' ) + " SC6, "+RetSqlName( 'SC5' ) + " SC5 "
		cQuery+=" WHERE "
		cQuery+=" C5_FILIAL='"+ xFilial( 'SC5' )+ "'"
		cQuery+=" AND C6_FILIAL=C5_FILIAL"
		cQuery+=" AND C5_NUM in (" + Left( cPedidos, Len( cPedidos ) - 1 ) + ")"
		cQuery+=" AND C6_NUM = C5_NUM"
		cQuery+=" AND  SC5.D_E_L_E_T_ = ' '"
		cQuery+=" AND  SC6.D_E_L_E_T_ = ' '"
		cQuery+=" GROUP BY C5_FILIAL,C5_NUM,C5_CLIENTE,C5_LOJACLI,C5_EMISSAO,C6_IMPEMB,C5_PEDGUIA "
		cQuery+=" ORDER BY C5_PEDGUIA DESC ,C5_NUM  "

		IF Select('SC5TMP') <> 0
			SC5TMP->( DbCLoseArea() )
		Endif

		dbUseArea( .T., 'TOPCONN', TCGenQry( ,, cQuery ), 'SC5TMP', .T., .T. )
		TCSetField( 'SC5TMP', 'C5_EMISSAO', 'D', 08, 0 )

		dbselectarea('SC5TMP')
		aPedidos := Array(0)

		While SC5TMP->( !Eof() )

			lRetSemBloqWms := SF4->(checkServico(SC5TMP->C5_FILIAL,SC5TMP->C5_NUM))

			If lRetSemBloqWms
				SA1->( dbSeek(xFilial('SA1')+SC5TMP->C5_CLIENTE+SC5TMP->C5_LOJACLI) )

				Aadd(aPedidos,{ Iif(SC5TMP->C6_IMPEMB=='S',.T.,.F.) ,;
				SC5TMP->C5_FILIAL,;
				SC5TMP->C5_NUM,;
				SC5TMP->C5_EMISSAO,;
				SC5TMP->C5_CLIENTE,;
				SC5TMP->C5_LOJACLI,;
				SA1->A1_NOME,;
				SC5TMP->C5_PEDGUIA})

			Endif

			dbSkip()
		EndDo

	Endif

	If !Empty(aPedidos)

		DEFINE MSDIALOG oDlg TITLE 'Impressão de Pedidos de Separação WMS' FROM 0,0 TO 18,100 OF oMainWnd

		@ 109,003 bitmap size 8,8 file 'FWOCN_RDO_HVR.PNG' of oDlg  NOBORDER WHEN .F. PIXEL
		@ 109,012  Say "Pedido c/ Guia Aguardando Impressão "  of oDlg PIXEL

		@ 109,115 bitmap size 8,8 file 'ENABLE' of oDlg  NOBORDER WHEN .F. PIXEL
		@ 109,124  Say "Pedido Aguardando Impressão "  of oDlg PIXEL

		@ 109,206 bitmap size 8,8 file 'BR_CINZA' of oDlg NOBORDER WHEN .F. PIXEL
		@ 109,217  Say "Pedido Impresso "  of oDlg PIXEL

		TBtnBmp2():New(216,745,035,018,'IMPRESSAO_OCEAN.PNG',,,,{|| RodaRel(aPedidos) },oDlg,"Imprimir",{||},,.T. )

		If _cVersao_ == "11"
			TBtnBmp2():New(240,745,035,018,'IC_20_CANCELAR.GIF',,,,{|| Iif(MarcaPV(aPedidos), (aPedidos := Array(0), oDlg:End()),.F.)  },oDlg,"Sair",{||},,.T. )
		Else
			TBtnBmp2():New(240,745,035,018,'NG_ICO_CANCELAR.PNG',,,,{|| Iif(MarcaPV(aPedidos), (aPedidos := Array(0), oDlg:End()),.F.)  },oDlg,"Sair",{||},,.T. )
		EndIf

		@ 05,02  LISTBOX oList FIELDS HEADER  ' ','Filial','Pedido','Emissao','Cliente','Loja','Nome','Guia GNE ' SIZE 100,100 PIXEL OF oDlg

		oList:Align := 3
		oList:SetArray(aPedidos)
		oList:bLine:={|| {IIf(aPedidos[oList:nAt][APEDGUIA] == '1' , IIf(aPedidos[ oList:nAt][APDIMPEM] == .F. , oAzul ,oCinza) , IIf(aPedidos[ oList:nAt][APDIMPEM] == .F. , oEnable ,oCinza)),;
		aPedidos[oList:nAt][APFILIAL],;
		aPedidos[oList:nAt][APNUMERO],;
		aPedidos[oList:nAt][APEMISSA],;
		aPedidos[oList:nAt][APCLIENT],;
		aPedidos[oList:nAt][APLOJACL],;
		aPedidos[oList:nAt][APNOMECL],;
		aPedidos[oList:nAt][APEDGUIA]}}
		oList:Refresh()

		ACTIVATE MSDIALOG oDlg CENTER

	Endif

	dbSelectArea('SC5TMP')
	dbCloseArea()

	dbSelectArea('SC5')

	Return
*****************************************************************************
Static Function RodaRel(aPedidos, aItensPV) // Inicia a impressão do Relatório
*****************************************************************************

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

	RptDetail(aPedidos, @oPrn)

	oPrn:Preview()

	Return
*****************************************************************************
Static Function RptDetail(aPedidos, oPrn) // Impressao dos relatorio... 
*****************************************************************************

	Local nValTot, cKey
	Local nStart, nItem
	Local cQuery
	Local aItensPV		:= {}
	
	Private lRetabAuto  := .F.
	Private cPictPeso 	:= "@E 999.99"
	Private nPesTot 	:= 0
	Private nLin 		:= 0
	Private nPagina 	:= 0	// Numero da Pagina Atual do Pedido
	Private nTotPag 	:= 0    // Numero Total de Paginas do Pedido
	Private bFinalP 	:= {|| if(nPagina == nTotPag,.T.,.F.)} // Verifica se eh pagina final

	Private cLibCom 	:= ""
	Private cLibFin 	:= ""

	Private cNomeVend1, cNomeVend2
	Private nTipo := If( aReturn[4] == 1, 15, 18 )

	SA1->( DbSetOrder( 1 ) )
	SA2->( DbSetOrder( 1 ) )
	SA3->( DbSetOrder( 1 ) )
	SA4->( DbSetOrder( 1 ) )
	SC5->( DbSetOrder( 1 ) )
	SC6->( DbSetOrder( 1 ) )
	SC9->( DbSetOrder( 1 ) )
	SE4->( DbSetOrder( 1 ) )
	SU7->( DbSetOrder( 1 ) )
	SUA->( DbSetOrder( 8 ) )
	ZZV->( DbSetOrder( 1 ) )

	SC9->( DbSetOrder(1))

	For nStart := 1 To Len(aPedidos) // Percorre os Pedidos

		// ajusta variaveis de controle
		cFilPed   := aPedidos[nStart][APFILIAL]
		cNumPed   := aPedidos[nStart][APNUMERO]

		SC5->( dbSeek( cFilPed + cNumPed, .F. ) )
		SA3->( dbSeek( xFilial( 'SA3' ) + SC5->C5_VEND1		, .F. ) )
		SA3->( dbSeek( xFilial( 'SA3' ) + SC5->C5_VEND2		, .F. ) )	; cNomeVend2 := AllTrim( SA3->A3_NOME )
		SA4->( dbSeek( xFilial( 'SA4' ) + SC5->C5_TRANSP	, .F. ) )
		SE4->( dbSeek( xFilial( 'SE4' ) + SC5->C5_CONDPAG	, .F. ) )
		SU7->( dbSeek( xFilial( 'SU7' ) + SC5->C5_OPERADO	, .F. ) )  ; cNomeVend1 := AllTrim( SU7->U7_NOME )
		SUA->( dbSeek( xFilial( 'SUA' ) + SC5->C5_NUM		, .F. ) )
		SC9->( dbSeek( cFilPed + cNumPed, .F. ) )

		nValTot := 0
		nPesTot := 0
		cKey    := cFilPed + cNumPed

		aItensPV := BuscaItensDBC9(cFilPed,cNumPed)

		nPos := Ascan(aItensPV, {|x| x[1]+x[2] = cKey})

		nTotPag := CalcTotPag(Len(aItensPV))
		
		If nPos > 0 // Se Encontrou o Pedido

			cLibCom := DtoC(SC9->C9_DTLCOM) + ' - ' + SC9->C9_HRLCOM + ' - ' +  SC9->C9_USRLCOM
			cLibFin := DtoC(SC9->C9_DTLCRE) + ' - ' + SC9->C9_HRLCRE + ' - ' +  SC9->C9_USRLCRE
			nLin 	:= 1			

			ImpCabec(@oPrn)
			For nItem := nPos To Len(aItensPV) // Percorre os Itens do pedido


				If nLin > _NIPCO_ //| Verifica se a Pagina completa atingio o Limite de Itens

					//DLibPed(@oPrn) // Imprime Dados Liberação e Rodape

					ImpCabec(@oPrn)//;Alert('ImpCabec : 581')
			
				EndIf

				cFilPed     := aItensPV[nItem,1]   // SC6TMP->C6_FILIAL
				cUM			:= aItensPV[nItem,9]   // SC6TMP->B1_UM
				cNumPed     := aItensPV[nItem,2]   // SC6TMP->C6_NUM
				cProduto    := aItensPV[nItem,3]   // SC6TMP->C6_NUM
				nC9_QTDLIB  := aItensPV[nItem,4]   // SC6TMP->C9_QTDLIB
				cB1_REFER   := aItensPV[nItem,7]   // SC6TMP->B1_REFER
				cB1_MARCA   := aItensPV[nItem,6]   // SC6TMP->B1_MARCA
				cB1_ORIGEM  := aItensPV[nItem,10]  // SC6TMP->B1_ORIGEM
				nB1_PESO    := aItensPV[nItem,8]   // SC6TMP->B1_PESO
				cEnd        := aItensPV[nItem,5]   // Endereço do Produto
				cLote       := aItensPV[nItem,11]
				cReabast    := aItensPV[nItem,12]

				nC6_PRCVEN  := 0

				SC6->( dbSeek( cFilPed + cNumPed, .F. ) )


				lRetabAuto := SF4->(chekReabastAuto(SC5->C5_NUM,cProduto))

				If lRetabAuto
					cRAA := ' R'
				Else
					cRAA := '  '
				Endif

				cProdN := Alltrim(cProduto)
				If Len(Alltrim(cProduto)) == 8
					cProdN := cProduto
				ElseIf Len(Alltrim(cProduto)) == 9
					cProdN := Substr(Alltrim(cProduto),2,8)
				Else
					cProdN := Substr(Alltrim(cProduto),6,8)
				EndIf

				nPesTot += nB1_PESO * nC9_QTDLIB

				// Impressão dos Itens
				Itens(@oPrn, nLin,;
				cEnd		:= LEFT(cEnd,8) + cRAA,;
				cQtd		:= Transform( nC9_QTDLIB, "@E 99,999.99"  ),;
				cProduto 	:= Alltrim(cProdN),;
				cRefer 		:= SubStr(cB1_REFER,1,20),;
				cMarca 		:= SubStr( cB1_MARCA, 1, 05 ),;
				cOrigem		:= cB1_ORIGEM,;
				cUM			:= cUM,;
				cPESO		:= Transform( nB1_PESO,cPictPeso)  )

				nLin += 1
			Next

			If nPagina < nTotPag // Em Caso de Haver uma pagina pendente por nao ter itens a imprimir ... Gera o Cabecalho
				ImpCabec(@oPrn)//;Alert('ImpCabec : 623')
			EndIf

			DLibPed(@oPrn) // Imprime Dados Liberação e Rodape

			//ImpCabec(@oPrn);Alert('ImpCabec : 579')

			//| Fim Itens

		Endif

	Next

	Return	
*****************************************************************************
Static Function checkServico(cCodFil,cPedido)	//Pesquisa status do serviço WMS EXECUTADO/NAO EXECUTADO //
*****************************************************************************

	Local lRet
	Local cQuery

	cQuery :="SELECT DCF_STSERV "
	cQuery +=" FROM "
	cQuery +=RetSqlName("DCF")+" DCF "
	cQuery +=" WHERE   DCF_FILIAL = '"+cCodFil+"'"
	cQuery +=" AND DCF_DOCTO = '"+cPedido+"'"
	cQuery +=" AND DCF_SERVIC = '001'"
	cQuery +=" AND DCF.D_E_L_E_T_ = ' ' "

	IF Select('TRB') <> 0
		TRB->( DbCLoseArea() )
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)

	DbselectARea("TRB")
	DbGoTop()

	If TRB->( Eof() )
		//Pedido não possui itens Gerenciado pelo WMS,Libera impressão do pedido de separação
		lRet:=.T.
	Else
		If TRB->DCF_STSERV='1' .OR. TRB->DCF_STSERV='2' //Serviço está pendente a Execução,bloqueia a impressão
			lRet := .F.
		Else
			lRet := .T.
		Endif
	Endif

	Return lRet
*****************************************************************************
Static Function BuscaItensDBC9(cCodFil,cPedido)
*****************************************************************************
	Local aItensPed 	:= {}
	Local cController	:= .F.
	Local lController

	//Busca Itens de Produto com seus respectivos Endereços e Lotes separados pelo WMS //
	/////////////JULIO JACOVENKO, em 29/09/2016
	CQUERY:=" SELECT DB_FILIAL,DB_DOC,DB_PRODUTO,DB_ESTFIS,DB_LOCALIZ,BE_CODZON,BE_ESTFIS, ""
	CQUERY+=" DB_QUANT,DB_LOTECTL,B1_MARCA,B1_DESC,B1_PESO,B1_ORIGEM,B1_UM "
	CQUERY+=" FROM "+RETSQLNAME("SDB")+" SDB, "+RETSQLNAME("SC90")+" SC9, "+RETSQLNAME("SB1")+" SB1, "+RETSQLNAME("SBE")+" SBE "
	CQUERY+=" WHERE DB_DOC  = '"+cPedido+"' "
	CQUERY+=" AND DB_FILIAL = '"+cCodFil +"' "
	CQUERY+=" AND C9_FILIAL = DB_FILIAL "
	CQUERY+=" AND B1_FILIAL = DB_FILIAL  "
	CQUERY+=" AND C9_PEDIDO  = DB_DOC  "
	CQUERY+=" AND C9_ITEM    = DB_SERIE "
	CQUERY+=" AND C9_PRODUTO = DB_PRODUTO "
	CQUERY+=" AND C9_IDDCF   = DB_IDDCF "
	CQUERY+=" AND B1_COD     = DB_PRODUTO "
	CQUERY+=" AND B1_LOCALIZ = 'S' "
	CQUERY+=" AND BE_FILIAL  = DB_FILIAL "
	CQUERY+=" AND BE_LOCALIZ = DB_LOCALIZ "
	CQUERY+=" AND BE_LOCAL   = DB_LOCAL "
	CQUERY+=" AND BE_ESTFIS  = DB_ESTFIS "
	CQUERY+=" AND DB_ESTORNO <> 'S' "
	CQUERY+=" AND DB_TM > '500' "
	CQUERY+=" AND DB_ATUEST = 'N' "
	CQUERY+=" AND DB_SERVIC = '001' "
	CQUERY+=" AND DB_TAREFA = '002' "
	CQUERY+=" AND DB_ATIVID = '015' "
	// Jorge Oliveira - 28/07/2010 - Inclusao da Atividade 015 - Separar Produtos
	If cVersao <> "MP8.11"
		cQuery +=" AND DB_ATIVID = '015' "
	EndIf

	CQUERY+=" AND SDB.D_E_L_E_T_ = ' ' "
	CQUERY+=" AND SC9.D_E_L_E_T_ = ' ' "
	CQUERY+=" AND SB1.D_E_L_E_T_ = ' ' "
	CQUERY+=" AND SBE.D_E_L_E_T_ = ' ' "
	CQUERY+=" ORDER BY DB_ESTFIS,BE_ESTFIS,DB_LOCALIZ, BE_CODZON ASC ""

	IF Select('TRB') <> 0
		TRB->( DbCLoseArea() )
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)

	DbselectARea("TRB")

	ProcRegua(TRB->(Reccount()))

	While TRB->(!Eof())
		//MsAguarde({||lController:=SF4->(chekReabastAuto(TRB->DB_DOC,TRB->DB_PRODUTO)) },"Reabastecimento Automático",'Checando  Reabastecimento para o item '+TRB->DB_PRODUTO+'...')
		lController:=SF4->(chekReabastAuto(TRB->DB_DOC,TRB->DB_PRODUTO))

		////////JULIO JACOVENKO, em 29/09/2016
		aAdd(aItensPed,{ TRB->DB_FILIAL,;
		TRB->DB_DOC,;
		TRB->DB_PRODUTO,;
		TRB->DB_QUANT,;
		Alltrim(TRB->DB_LOCALIZ),;
		TRB->B1_MARCA,;
		TRB->B1_DESC,;
		TRB->B1_PESO,;
		TRB->B1_UM,;
		TRB->B1_ORIGEM,;
		TRB->DB_LOTECTL,;
		Iif(lController,'Não Possui','S')} )

		DbSkip()

	Enddo
	
	DbselectARea("TRB")
	DbCloseArea()

	aSort(aItensPed,,,{|X,Y| X[5] < Y[5]})
	
	Return(aItensPed)
*****************************************************************************
Static Function ImpCabec(oPrn)	//  Impressão do Cabeçalho do Relatório Pedido de Separação //
*****************************************************************************
	Local cCliImdepa  := GetMV('MV_IMDEPA')
	Local cDescSeg    := ' '
	Local cSegmento	  := SPACE(TamSX3('A1_GRPSEG')[1])
	Local lTemGuia    := .F.  //Define se o pedido possui Guia GNE

	lImpresso 	:= .T.

	oPrn:StartPage()
	
	nPagina 	+= 1
	nLin 		:= 1
	
	If !SC5->C5_TIPO $ 'DB'

		SA1->( dbSeek( xFilial( 'SA1' ) + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .F. ) )

		cCliente := SA1->A1_COD + '/' + SA1->A1_LOJA + ' ' + SA1->A1_NOME
		cEndFatu := AllTrim( U_ALTEND(SA1->A1_END) ) + ', ' + AllTrim( Str( SA1->A1_NUMEND, 6 ) )
		cCidFatu := AllTrim( SA1->A1_MUN ) + ' - ' + SA1->A1_EST
		cEndEntr := AllTrim( SA1->A1_ENDENT) + ', ' + AllTrim( Str( SA1->A1_NUMENTR, 6 ) )
		cCidEntr := AllTrim( SA1->A1_MUN ) + ' - ' + SA1->A1_EST
		cSegmento:= SA1->A1_GRPSEG
	Else

		SA2->( dbSeek( xFilial( 'SA2' ) + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .F. ) )

		If SA2->A2_ESTRATG = 'S'

			SZZ->( dbSetOrder( 1 ) )
			SZZ->( dbSeek( xFilial( 'SZZ' ) + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .F. ) )
		EndIf

		cCliente := SA2->A2_COD + '/' + SA2->A2_LOJA + ' ' + If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_NOME, SA2->A2_NOME )
		cEndFatu := AllTrim( If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_END, SA2->A2_END ) )
		cCidFatu := AllTrim( If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_MUN, SA2->A2_MUN ) ) + ' - ' + SA2->A2_EST
		cEndEntr := AllTrim( If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_END, SA2->A2_END ) )
		cCidEntr := AllTrim( If( SA2->A2_ESTRATG = 'S', SZZ->ZZ_MUN, SA2->A2_MUN ) ) + ' - ' + SA2->A2_EST

	EndIf

	cDescSeg := SF4->(cRetset(cSegmento))
	SE4->( dbSeek( xFilial( 'SE4' ) + SC5->C5_CONDPAG, .F. ) ) ; cDescCondpg := Alltrim( SE4->E4_DESCRI)

	If SC5->C5_PEDGUIA=='1'
		lTemGuia := .T.
	Endif

	//////|||||| Impressão Cabecalho  ************************************************************************************************

	oPrn:Box( 100 , 50 , 250 , 2930 , '02' )

	//Linhas Laterais externas aos itens
	If eVal(bFinalP) // eh pagina final ? Caso nao imprime os itens
		oPrn:Line( 270 , 50   , 2200 , 50 , 0 , '01'  )
		oPrn:Line( 270 , 2930 , 2200 , 2930 , 0 , '01'  )
	Else
		oPrn:Line( 270 , 50   , 2430 , 50 , 0 , '01'  )
		oPrn:Line( 270 , 2930 , 2430 , 2930 , 0 , '01'  )
	EndIf

	oFont :=  TFont():New( 'Courier new' , , -12)
	oPrn:Say( 140 , 60 , Alltrim(SM0->M0_CODFIL)+' : '+Alltrim(SM0->M0_NOME)+' - '+ Alltrim(SM0->M0_FILIAL) , oFont ,   , 0 , ) //oPrn:Say( 130 , 60 , 'IMDEPA - CD PORTO ALEGRE ' , oFont ,   , 0 , )

	oFont :=  TFont():New( 'Courier new' , , -18) ; oFont:Bold 	:= .T.
	oPrn:Say( 160 , 1000 , 'Pedido de Venda - Separação WMS ' , oFont ,   , 0 , )

	oFont :=  TFont():New( 'Courier new' , , -12)
	oPrn:Say( 140 , 2530 , 'Emissão: '+ dToc(dDataBase) + ' - ' + Substr(Time(),1,5) , oFont ,   , 0 , ) //oPrn:Say( 130 , 2530 , 'Emissão: 11/12/17 - 09:33 ' , oFont ,   , 0 , )

	oFont :=  TFont():New( 'Courier new' , , -12)
	oPrn:Say( 230 , 60 , 'Visto Expedição em : ____/____/____  ' , oFont ,   , 0 , )

	oFont :=  TFont():New( 'Courier new' , , -12)
	oPrn:Say( 230 , 650 , 'Visto : ______________ ' , oFont ,   , 0 , )

	oFont :=  TFont():New( 'Courier new' , , -12)
	oPrn:Say( 230 , 1050 , 'NF : ______________ ' , oFont ,   , 0 , )

	oFont :=  TFont():New( 'Courier new' , , -12)
	oPrn:Say( 230 , 2715 , 'Página: '+Strzero(nPagina,2)+'-'+Strzero(nTotPag,2) , oFont ,   , 0 , )

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
	oPrn:Say( 700 , 70 , 'Condição de Pagto.:  ' , oFont ,   , 0 , )

	oFont :=  TFont():New( 'Courier new' , , -12);oFont:Bold 	:= .T.
	oPrn:Say( 750 , 70 , 'Origem Produto....:  ' , oFont ,   , 0 , )

	***********************
	// Variaveis Comerciais
	***********************
	oFont :=  TFont():New( 'Courier new' , , -12)

	oPrn:Say( 400 , 400 , SC5->C5_NUM , oFont ,   , 0 , )

	If MV_PAR01 = 1 // Reabastecimento
		oPrn:Say( 400 , 510 , '* R', oFont ,   , 0 , )
	EndIf

	If !Empty(SC5->C5_NUMSUA) .AND. cCliImdepa == SC5->C5_CLIENTE
		oPrn:Say( 400 , 580 , '** PEDIDO ALOCADO ', oFont ,   , 0 , )
	EndIf

	If lTemGuia 
		oPrn:Say( 400 , 860 , '*** Pedido com GUIA ST ', oFont ,   , 0 , )
	EndIf
	
	oPrn:Say( 450 , 400 , SC5->C5_OCCLI , oFont ,   , 0 , )

	oPrn:Say( 500 , 400 , cCliente      , oFont ,   , 0 , )

	oPrn:Say( 550 , 400 , cSegmento + ' / ' + cDescSeg   , oFont ,   , 0 , )

	oPrn:Say( 600 , 400 , cNomeVend2 , oFont ,   , 0 , )

	oPrn:Say( 650 , 400 , cNomeVend1 , oFont ,   , 0 , )

	oPrn:Say( 700 , 400 ,  Alltrim( SE4->E4_DESCRI ) , oFont ,   , 0 , )

	oPrn:Say( 750 , 400 , '0 -> Nacional, 1 -> Importado, 2 -> Nacionalizado' , oFont ,   , 0 , )

	oPrn:Line( 300 , 1415 , 750 , 1415 , 0 , '01'  )

	oFont :=  TFont():New( 'Courier new' , , -14);oFont:Bold 	:= .T.
	oPrn:Say( 320 , 2000 , 'DADOS ENTREGA ' , oFont ,   , 0 , )

	oFont :=  TFont():New( 'Courier new' , , -12);oFont:Bold 	:= .T.
	oPrn:Say( 400 , 1435 , 'Endereço Fatura...:  ' , oFont ,   , 0 , )

	oPrn:Say( 450 , 1435 , 'Cidade Fatura.....:  ' , oFont ,   , 0 , )

	oPrn:Say( 500 , 1435 , 'Endereço Entrega..:  ' , oFont ,   , 0 , )

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

	oPrn:Say( 700 , 1765 , +Alltrim(Transform(SUA->UA_FRETE,"@E 999,999.99")) , oFont ,   , 0 , )

	// Linha Fim Cabecalho
	oPrn:Line( 770 , 50 , 770 , 2930 , 0 , '-6'  )

	oFont :=  TFont():New( 'Courier new' , , -14);oFont:Bold 	:= .T.
	oPrn:Say( 820 , 70 , 'Observação:  ' , oFont ,   , 0 , )

	oFont :=  TFont():New( 'Courier new' , , -14)
	oPrn:Say( 820 , 300 ,  SUA->UA_OBSEXP , oFont ,   , 0 , )

	// Linha Fim Observacao
	oPrn:Line( 850 , 50 , 850 , 2930 , 0 , '01'  )

	CabItens(@oPrn)

	Return
*****************************************************************************
Static Function MarcaPV(aPedidos)
*****************************************************************************

	Local lSair      := .T.
	Local nStart

	//³Atualiza informações de impressão do pedido de separação³
	//³Edivaldo Gonçalves Cordeiro em 29/10/06                   ³

	If lImpresso
		If MsgYesNo('Marca os Pedidos como ja Impressos?')
			Begin Transaction
				For nStart := 1 To Len(aPedidos)

					cSql := " UPDATE "+RetSqlName('SC6') //grava status de ja impresso
					cSql += " SET C6_IMPEMB = 'S' WHERE C6_FILIAL= '" + xFilial( 'SC6' ) + "'"
					cSql += " AND C6_NUM = '"+aPedidos[nStart][APNUMERO]+"'"
					cSql += " AND D_E_L_E_T_ = ' '"
					TCSQLExec( cSql )
					TCSQLExec('COMMIT')

					cSql := " UPDATE "+RetSqlName('SC9') //grava status de ja impresso
					cSql += " SET C9_DTPSEP ='"+Dtos(Date())+"'"
					cSql += ",C9_HRPSEP='"+Strtran(Left(Time(),5),":","")+"'"
					cSql += ",C9_USRPSEP='"+SubStr( cUsuario, 7, 15 )+"'"
					cSql += " WHERE C9_FILIAL= '" + xFilial( 'SC9' ) + "'"
					cSql += " AND C9_PEDIDO = '"+aPedidos[nStart][APNUMERO]+"'"
					cSql += " AND D_E_L_E_T_ = ' '"
					TCSQLExec( cSql )
					TCSQLExec('COMMIT')

				Next i
			End Transaction
		Endif

	Else
		If MsgYesNo('Os Pedidos nao foram Impressos! Sair assim mesmo?')
			lSair := .T.
		Else
			lSair := .F.
		Endif

	Endif

	Return(lSair)
*****************************************************************************
Static Function chekReabastAuto(cNumPed,cItemProd)
*****************************************************************************
	Local lRet:=.F.

	cQuery := " SELECT DCF_DOCORI "
	cQuery += " FROM "+ RetSqlName( 'DCF' ) + " DCF "
	cQuery += " WHERE DCF_FILIAL = '" + xFilial( 'DCF' ) + "'"
	cQuery += " AND DCF_DOCORI='"+cNumPed+ "'"
	cQuery += " AND DCF_CODPRO='"+cItemProd+"'"
	cQuery += " AND DCF_SERVIC='005'
	cQuery += " AND D_E_L_E_T_ = ' '"

	If Select('DCFTMP') <> 0
		DCFTMP->( DbCLoseArea() )
	Endif

	dbUseArea( .T., 'TOPCONN', TCGenQry(,,cQuery), 'DCFTMP', .F., .T. )

	DCFTMP->( DBGOTOP())

	If DCFTMP->( !Eof() )
		//Item de Pedido gerou reabastecimento
		lRet:=.T.
	Endif

	Return lRet
*****************************************************************************
Static Function cRetset(cSeg)
*****************************************************************************
	Local cRetseg:=' '

	cQuery := " SELECT ZZV_DESC "
	cQuery += " FROM "+ RetSqlName( 'ZZV' ) + " ZZV "
	cQuery += " WHERE ZZV_FILIAL = '" + xFilial( 'ZZV' ) + "'"
	cQuery += " AND ZZV_COD = '"+cSeg+ "'"
	cQuery += " AND D_E_L_E_T_ = ' '"

	If Select('ZZVTMP') <> 0
		ZZVTMP->( DbCLoseArea() )
	Endif

	dbUseArea( .T., 'TOPCONN', TCGenQry(,,cQuery), 'ZZVTMP', .F., .T. )

	ZZVTMP->( DBGOTOP())

	If DCFTMP->( !Eof() )

		cRetseg=Alltrim(ZZVTMP->ZZV_DESC)
	Endif

	Return(cRetseg)

*******************************************************************************
Static Function CabItens(oPrn)
*******************************************************************************

	// Cabecalho dos itens
	If eVal(bFinalP) // eh pagina final ? Caso nao imprime os itens
		oPrn:Box( 870 , 65 , 2090 , 2915 , '01' )
	Else
		oPrn:Box( 870 , 65 , 2410 , 2915 , '01' )
	Endif

	oFont :=  TFont():New( 'Courier new' , , -16);oFont:Bold 	:= .T.
	oPrn:Say( 907 , 130 , 'Endereço ' , oFont ,   , 0 , )

	oPrn:Say( 907 , 370 , 'Qtd ' , oFont ,   , 0 , )

	oPrn:Say( 907 , 550 , 'Codigo ' , oFont ,   , 0 , )

	oPrn:Say( 907 , 0950 , 'Descrição ' , oFont ,   , 0 , )

	oPrn:Say( 907 , 2050 , 'Marca ' , oFont ,   , 0 , )

	oPrn:Say( 907 , 2300 , 'Origem ' , oFont ,   , 0 , )

	oPrn:Say( 907 , 2500 , 'UM ' , oFont ,   , 0 , )

	oPrn:Say( 907 , 2650 , 'Peso Un ' , oFont ,   , 0 , )

	// Linha fim Cabecalho Itens
	oPrn:Line( 920 , 90 , 920 , 2890 , 0 , '01'  )

	// Linhas Itens
	// Item 01
	oPrn:Line( 1000 , 90 , 1000 , 2890 , 0 , '-2'  )
	// Item 02
	oPrn:Line( 1080 , 90 , 1080 , 2890 , 0 , '-2'  )
	// Item 03
	oPrn:Line( 1160 , 90 , 1160 , 2890 , 0 , '-2'  )
	// Item 04
	oPrn:Line( 1240 , 90 , 1240 , 2890 , 0 , '-2'  )
	// Item 05
	oPrn:Line( 1320 , 90 , 1320 , 2890 , 0 , '-2'  )
	// Item 06
	oPrn:Line( 1400 , 90 , 1400 , 2890 , 0 , '-2'  )
	// Item 07
	oPrn:Line( 1480 , 90 , 1480 , 2890 , 0 , '-2'  )
	// Item 08
	oPrn:Line( 1560 , 90 , 1560 , 2890 , 0 , '-2'  )
	// Item 09
	oPrn:Line( 1640 , 90 , 1640 , 2890 , 0 , '-2'  )
	// Item 10
	oPrn:Line( 1720 , 90 , 1720 , 2890 , 0 , '-2'  )
	// Item 11
	oPrn:Line( 1800 , 90 , 1800 , 2890 , 0 , '-2'  )
	// Item 12
	oPrn:Line( 1880 , 90 , 1880 , 2890 , 0 , '-2'  )
	// Item 13
	oPrn:Line( 1960 , 90 , 1960 , 2890 , 0 , '-2'  )
	// Item 14
	oPrn:Line( 2040 , 90 , 2040 , 2890 , 0 , '-2'  )

	If !eVal(bFinalP) // eh pagina final ? Caso nao imprime os itens

		// Item 15
		oPrn:Line( 2120 , 90 , 2120 , 2890 , 0 , '-2'  )
		// Item 16
		oPrn:Line( 2200 , 90 , 2200 , 2890 , 0 , '-2'  )
		// Item 17
		oPrn:Line( 2280 , 90 , 2280 , 2890 , 0 , '-2'  )
		// Item 18
		oPrn:Line( 2360 , 90 , 2360 , 2890 , 0 , '-2'  )
		// Item 18
		//oPrn:Line( 2440 , 90 , 2440 , 2890 , 0 , '-2'  )

		oPrn:Line( 2430 , 50 , 2430 , 2930 , 0 , '01'  )

	EndIf

	Return
*****************************************************************************
Static Function Itens(oPrn, nitem, cEnd,cQtd,cProduto,cRefer,cMarca,cOrigem,cUM,cPESO)
*****************************************************************************
	nSalto := (( nitem * 80) + 890 )
	// Item 01

	oFont :=  TFont():New( 'Courier new' , , -15)
	oPrn:Say( nSalto , 130 , cEnd , oFont ,   , 0 , )

	oPrn:Say( nSalto , 300 , cQtd , oFont ,   , 0 , )

	oPrn:Say( nSalto , 550 , cProduto , oFont ,   , 0 , )

	oPrn:Say( nSalto , 0950 , cRefer , oFont ,   , 0 , )

	oPrn:Say( nSalto , 2050 , cMarca , oFont ,   , 0 , )

	oPrn:Say( nSalto , 2300 , cOrigem , oFont ,   , 0 , )

	oPrn:Say( nSalto , 2500 , cUM , oFont ,   , 0 , )

	oPrn:Say( nSalto , 2650 , cPESO , oFont ,   , 0 , )

	Return
*****************************************************************************
Static Function DLibPed(oPrn)
*****************************************************************************

	If eVal(bFinalP) // eh pagina final ? Se for, imprime ...

		// Dados Liberacao do Pedido
		oFont :=  TFont():New( 'Courier new' , , -12)
		oPrn:Say( 2075 , 90 , 'Liberação do Pedido ' , oFont ,   , 0 , )

		oPrn:Say( 2075 , 500 , 'COMERCIAL: ' , oFont ,   , 0 , )

		oPrn:Say( 2075 , 660 , cLibCom , oFont ,   , 0 , )

		oPrn:Say( 2075 , 1650 , 'CREDITO: ' , oFont ,   , 0 , )

		oPrn:Say( 2075 , 1780 , cLibFin  , oFont ,   , 0 , )

		oFont :=  TFont():New( 'Courier new' , , -12) ;oFont:Bold 	:= .T.
		oPrn:Say( 2075 , 2500 , 'Peso Total: ' , oFont ,   , 0 , )

		oFont :=  TFont():New( 'Courier new' , , -12) ;oFont:Bold 	:= .F.
		oPrn:Say( 2075 , 2700 , Transform( nPesTot,cPictPeso)  , oFont ,   , 0 , )

		Roddape(@oPrn)

	EndIf
	
	nPagina := 0
	
	Return
*****************************************************************************
Static Function Roddape(oPrn)
*****************************************************************************

	// Rodape do Relatorio
	oPrn:Box( 2100 , 50 , 2455 , 2930 , '01' )

	oFont :=  TFont():New( 'Courier new' , , -14);oFont:Bold 	:= .T.
	oPrn:Say( 2130 , 1285 , 'FICHA DE SEPARAÇÃO ' , oFont ,   , 0 , )

	oPrn:Line( 2135 , 050 , 2135 , 2930 , 0 , '-2'  )

	// Coluna 01
	oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T.
	oPrn:Say( 2235 , 070 , 'SEPARADOR.....:_________________________________ ' , oFont ,   , 0 , )

	oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T.
	oPrn:Say( 2335 , 070 , 'EMBALADOR.....:_________________________________ ' , oFont ,   , 0 , )

	//Coluna 02
	oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T.
	oPrn:Say( 2235 , 1020 , 'INICIO........:_________________________________ ' , oFont ,   , 0 , )

	oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T.
	oPrn:Say( 2335 , 1020 , 'FATURAMENTO...:_________________________________ ' , oFont ,   , 0 , )

	// Coluna 03
	oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T.
	oPrn:Say( 2235 , 1950 , 'TERMINO.......:_________________________________ ' , oFont ,   , 0 , )

	oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T.
	oPrn:Say( 2335 , 1950 , 'CONFERENTE....:_________________________________ ' , oFont ,   , 0 , )

	// Coluna 01 linha 03
	oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T.
	oPrn:Say( 2435 , 070 , 'QTD DE ERROS..:____________________ ' , oFont ,   , 0 , )

	oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T.
	oPrn:Say( 2435 , 0785 , 'TIPOS DE ERROS:____________________ ' , oFont ,   , 0 , )

	oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T.
	oPrn:Say( 2435 , 1500 , 'PESO BRUTO....:____________________ ' , oFont ,   , 0 , )

	oFont :=  TFont():New( 'Courier new' , , -14);oFont:Italic 	:= .T.
	oPrn:Say( 2435 , 2215 , 'QTD VOLUMES...:____________________ ' , oFont ,   , 0 , )

	oPrn:EndPage()

	Return()
*******************************************************************************
Static Function CalcTotPag(nItens) //| Calcula o Numero de Paginas para atender o pedido
*******************************************************************************

//	Local nPagCo := 0  //| Paginas Completas
//	Local nPagFi := 1	//| Numero de Paginas Finais
//	Local nItPf  := 0	//| Numero de Itens que ficou para pagina final
	Local nTotPg 	:= 0	//| Total de Paginas
	Local lContinua := .T.

	While lContinua
	
		If nItens <= _NIPFI_ // Todos os itens cabem em uma Pagina
			nTotPg  	:=  1 
			lContinua 	:= .F.
		
		ElseIf nItens <= ( _NIPCO_ +  _NIPFI_ ) // Todos os Itens Cabem em duas Paginas
			nTotPg  	:=  2
			lContinua 	:= .F.
		
		ElseIf  nItens <= ( ( nTotPg * _NIPCO_ ) + _NIPFI_ ) // Alcançou um Numero de Páginas que comporta o Pedido 
			nTotPg += 1
			lContinua 	:= .F.
		Else // Ainda não alcançou o Numero necessário de paginas... 

			nTotPg += 1
		EndIf	
	
	EndDo
		
/*		


	If nItens <= _NIPFI_
		nTotPg := 1
	Else

		nPagCo := NoRound( nItens  /_NIPCO_, 0 )
		If nPagCo == 0
			nPagCo := 1 //| Minimo 1 pagina
		EndIf

		nItPf := nItens - ( nPagCo * _NIPCO_ )
		If nItPf < 0
			nItPf := 0
		EndIf

		//If nItPf <= _NIPFI_ //| Verifica se os Itens restantes cabem na Pagina Final ...
		nTotPg := nPagCo + 1
		//Else
		//	nTotPg := nPagCo + 2
		//EndIf
	Endif

	//Alert('Total de Paginas : ' + cValToChar(nTotPg))
*/
Return nTotPg