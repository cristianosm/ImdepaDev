#Include "RwMake.ch"
#Include "TopConn.ch"
#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FWPrintSetup.ch"

// ï¿½
#Define _DESCONTO 2
#Define _FRETE    4
#Define _DESPESA  5

#Define  NAOFATURANDO .F.

#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF


// #########################################################################################
// Projeto: Oramento de Vendas Tela da Verdade
// Modulo : Call Center
// Fonte  : IMDR060
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 23/05/03 | Marllon Figueiredo| Imprime Orcamento de Vendas
// ---------+-------------------+-----------------------------------------------------------

*********************************************************************
User Function IMDR060(_lPerg ) //nSuf, nST)
*********************************************************************

	Local aSaveOpe    			:= GetArea()
	Local aSaveSA1				:= SA1->(GetArea())
	Local aSaveSUS				:= SUS->(GetArea())
	Local aSaveSF4				:= SF4->(GetArea())
	Local aSaveSB1				:= SB1->(GetArea())

	Local nHeight10    		:= 10
	Local nHeight12    		:= 12
	Local nHeight16    		:= 16
	Local nHeight15    		:= 15
	Local lBold       		:= .T.
	Local lUnderLine   		:= .T.
	Local cAnexo					:= ""
	Local cCopia					:= ""
	Local cPara					:= ""
	Local lCopMailVendInt       := IIf(SU7->U7_RCOPORC == '1' ,.T. ,.F. ) //Define se o Vendedor Interno Recebe ou Nao uma copia do Orçamento de Venda

	Default _lPerg				:= .T.

	Private IMP_PDF 			:= 6 // Parametro para Funcao de geracao do PDF totvs
	Private _SAIR_ 			:= .F.
	Private lPerg				:= _lPerg

	Private lJaSave			:= .F.
	Private cNumAte			:= ""
	Private cTipOper			:= Iif( M->UA_OPER == "1" , "2" , "1" )

	//| Posicao dos campos detalhe no __aCCols da tela da Verdade...
	Private  A_CODIGO 			:= RetPosArr(aHeader, "UB_PRODUTO" 	, 1) //RetPosArr("UB_PRODUTO"	) // Codigo do Produto...
	Private  A_DESCRI 			:= RetPosArr(aHeader, "UB_DESCRI"		, 1) // Referencia e Marca do Produto...
	Private  A_UNIDADEM 		:= RetPosArr(aHeader, "UB_UM"				, 1) // Unidade Medida...
	Private  A_QUANT 			:= RetPosArr(aHeader, "UB_QUANT"		, 1) // Quantidade...
	Private  A_VLACRE 			:= RetPosArr(aHeader, "UB_VRCACRE"	, 1) // Valor com Acrescimo ...
	Private  A_VLUNIT 			:= RetPosArr(aHeader, "UB_VRUNIT"		, 1) // Valor Unitario...
	Private  A_DTENTG   		:= RetPosArr(aHeader, "UB_DTENTRE"	, 1) // Data de Entrega...
	Private  A_TES				:= RetPosArr(aHeader, "UB_TES"			, 1) // Codigo da TES...
	Private  A_EQSIMORI			:= RetPosArr(aHeader, "UB_EQSIORI" 	, 1) // Produto Original em relacao ou equivalente/similar
	Private  A_VLRST			:= RetPosArr(aHeader, "UB_ST", 		1) 	// Valor Unitario ST
	Private  A_VLRIPI			:= RetPosArr(aHeader, "UB_VALIPI", 1) 	// Valor Unitario IPI
	Private  A_DELETE			:= Len(aHeader) + 1 								// Marcado como deletado...

	//| Define Mascara para Valores unitario, Valores Totais e Valores Gerais...
	Private  _MASC_VL_U_ 	:= "@E 99,999.9999"
	Private  _MASC_VL_T_	:= "@E 999,999.99"
	Private  _MASC_VL_G_ 	:= "@E 999,999.99"

	//| Jorge Oliveira - 21/01/2011 - Chamado: AAZTHT - Ajuste do espacamento entre as linhas impressas e as informacoes do rodape
	Private nTamCab   			:= 250    	// espaco para o cabecalho ( relaltorio modelo grafico )
	Private nTamPag    			:= 2000 		//2850     // altura total da pagina ( relaltorio modelo grafico )
	Private nEspRoda   			:= 350     // espaco reservado para o rodape ( relaltorio modelo grafico )
	Private nMargInf   			:= 10 			//50       // margem inferior ( relaltorio modelo grafico )
	Private Li         			:= 0
	Private nCol       			:= 0

	Private oFont     			:= TFont():New( "Arial",,nHeight10,,lBold,,,,,!lUnderLine )
	Private oFont8    			:= TFont():New( "Arial",,nHeight10-2,,lBold,,,,,!lUnderLine )
	Private oFontb   			:= TFont():New( "Arial",,nHeight16,,lBold,,,,,!lUnderLine )
	Private oFont2     			:= TFont():New( "Tahoma",,nheight12,,lBold,,,,,!lUnderLine )
	Private oFont9     			:= TFont():New( "Tahoma",,nheight16,,lBold,,,,,!lUnderLine )
	Private oBrush1    			:= TBrush():New( , CLR_BLACK )
	Private oFont3     			:= TFont():New( "Mono AS",,nHeight10,,!lBold,,,,,!lUnderLine )
	Private oFont4     			:= TFont():New( "Times New Roman",,nheight15   ,,!lBold,,,,,lUnderLine )
	Private oFont5     			:= TFont():New( "Arial",,nHeight10,,!lBold,,,,,!lUnderLine )
	Private oFont6    			:= TFont():New( "Arial",,nheight15,,lBold,,,,,!lUnderLine )
	Private oFont7     			:= TFont():New( "Times New Roman",,nheight10-2 ,,!lBold,,,,,lUnderLine )

	Private wnrel      	:= "IMDR060"
	Private nOrdem     := 0
	Private tamanho    := "G"
	Private nColunas   := 90
	Private limite    	:= 132//90
	Private titulo    	:= Iif(cTipOper=='1', 'Orcamento', 'Pedido de Venda')
	Private cDesOper		:= Iif(cTipOper=='1', 'Orcamento de Venda Imdepa', 'Pedido de Venda Imdepa')
	Private cDesc1     	:= 'Este programa ira emitir o '+Iif(cTipOper=='1', 'Orcamento.', 'Pedido de Venda.')
	Private cDesc2     := ""
	Private cDesc3     := ""
	Private cString    := "SUA"
	Private nReg       := 0
	Private aReturn    := { "Especial", 1,"Administracao", 2, 2, 1, "",1 }
	Private nLastKey   := 0
	Private cWww       := Iif(SM0->M0_CODIGO='01','www.imdepa.com.br','www.sulauto.com.br')
	Private cTitEmp    := Iif(SM0->M0_CODIGO$'01/51','IMDEPA ROLAMENTOS','SULAUTO ROLAMENTOS')
	Private Cabec1     := 'Distribuidor: '
	Private Cabec2     := Iif(SM0->M0_CODIGO$'01/51', 'INA FAG LUK SABO TIMKEN GOODYEAR MDS GBR FCM BG FRM', Iif(SM0->M0_CODIGO$'02/52', 'FAG  SABO  TIMKEN' ,' '))
	Private nomeprog   := "IMDR060"
	Private nDestPrint := 1

	Private cVendResp  := ""
	Private cEmailResp   := ""
	Private cRepresen 	 := ""
	Private cMailRepr 	 := ""

	Private cMailChefVen := ""  //E-mail do Chef de Vendas
	Private cMailCoodVen := "" //E-mail do Coordenador de Vendas


	Private cMailCont	:= ""
	Private cMailCli		:= ""
	Private nPagina    := 0

	//| Parametros para Geracao em PDF
	Private cFilePrintert		:= CriaTrab( ,.F.) + ".pdf"
	Private nDevice				:= IMP_PDF
	Private lAdjustToLegacy	:= .T.
	Private cPathInServer		:= "\system\pdf\"
	Private cLocalPath			:= "C:\mp11\"
	Private lDisabeSetup		:= .T.
	Private lTReport				:= .F.
	Private cPrinter				:=  ""
	Private lServer				:= .F.
	Private lPDFAsPNG			:= .T.
	Private lRaw						:= .F.
	Private lViewPDF				:= .T.
	Private nQtdCopy				:= NIL
	Private oPrn

	Private cImdepa 			:= GetMV('MV_IMDEPA') // Codigo da Imdepa no Cadastro de Cliente
	Private lEnvEmailR 		:= Iif ( At(cFilant, Alltrim( SuperGetMv( "IM_FEOPREP", .F., "",  ) ) ) > 0 , .T. , .F. )
 	Private lFaturado 		:= If(Alltrim(SUA->UA_STATUS) == "NF.",.T.,.F.)

	Private nAcrFin	 :=  Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_ACRSFIN") // Juros ou Acrescimo Finnanceiro

	If ( ValidacoesGerias(lPerg) == _SAIR_ )
		Return(.T.)
	EndIf

	nDestPrint :=  2 // Grafico // xPergunta(cTipo) // Destino Impressao // CrisAlt

	If nDestPrint = 0
		Return(.T.)
	EndIf

	Cabec1   := Space( Int( ( nColunas - Len(Cabec1)) / 2)) + Cabec1
	Cabec2   := Space( Int( ( nColunas - Len(Cabec2)) / 2)) + Cabec2

	If nDestPrint = 1    // NORMAL
	Else
		Li := 50  //80
	EndIf              // Ajuste de margem esquerda

	nCol    := 50

	If nDestPrint = 1     // relatorio normal
	ElseIf nDestPrint = 2     // relatorio grafico

		oPrn := FWMSPrinter():New(cFilePrintert, nDevice, lAdjustToLegacy ,cPathInServer, lDisabeSetup, lTReport, @oPrn, cPrinter, lServer, lPDFAsPNG, lRaw, lViewPDF )

		oPrn:SetResolution(78)
		oPrn:SetLandscape()
		oPrn:SetPaperSize(9)
		oPrn:SetMargin(0,0,0,0)
		oPrn:cPathPDF:= cLocalPath
		oPrn:SetViewPDF(.F.)

		If lFaturado //| Somente Substitui o __ACOLS caso seja Orcamento já Faturado... |
			__aCCols := ACOLS
		EndIf

		Processa( { || C003Imp() } , Titulo, "Aguarde o processamento..." )

		If lEnvEmailR .And. !Empty(cMailRepr)
			//If Iw_MsgBox("Deseja enviar uma cópia do Orçamento ao Representante ?", "Atenção", "YESNO" )
			cCopia 	+= ALLTRIM(cMailRepr)

			//If !Empty(cCopia)
			 //	cCopia += ";"
			//EndIf


		EndIF

		PswOrder(2);PswSeek(CUSERNAME,.T.)
		cDe			:= Alltrim( SA3->(PswRet()[1][14]) 	) + Space(100)
		cPara		:= Alltrim( cMailCli			) + Space(50) //| |+";"+Alltrim(cMailCont)

		//Envia Cópia do e-mail para o Vendedor Interno
		If lCopMailVendInt
		    If !Empty(cCopia)
				cCopia += ";"
			EndIf
		  cCopia	+= Alltrim( cEmailResp) //+ Space(50)
		Endif

			//Envia Cópia do e-mail para o Chefe de Vendas
		If !Empty(cMailChefVen)
		    If !Empty(cCopia)
				cCopia += ";"
			EndIf
		  cCopia	+= Alltrim( cMailChefVen) //+ Space(50)
		Endif


		//Envia Cópia do e-mail para o Coordenador de Vendas
		If !Empty(cMailCoodVen)
		    If !Empty(cCopia)
				cCopia += ";"
			EndIf
		  cCopia	+= Alltrim( cMailCoodVen) //+ Space(50)
		Endif



		cAnexo 	:= Alltrim( oPrn:cPathpdf	) + Substr(Alltrim(oPrn:cFileName),1,Len(Alltrim(oPrn:cFileName))-3)+"pdf"

		//|         _cFrom,_cTo  ,_cBcc  ,_cSubject,_cBody,_cAttach,lTela
		U_EnvMyMail( cDe , Lower(cPara) , lower(cCopia) , cDesOper , 'Segue anexo '+ cDesOper , cAnexo , .T.)

	EndIf

	RestArea(aSaveSB1)
	RestArea(aSaveSF4)
	RestArea(aSaveSUS)
	RestArea(aSaveSA1)
	RestArea(aSaveOpe)

    dbselectarea("SB2")
	MsRUnlock(0)
	dbclosearea()
    dbselectarea("SC9")
    MsRUnlock(0)
   	dbclosearea()

Return(.T.)
*********************************************************************
Static Function C003Imp()
*********************************************************************

	Local lCalcIpi  := .F.
	Local cCaracter := ''
	Local cMens1    := ''
	Local cMens2    := ''
	Local cQuery    := ''
	Local nValTmp   := 0
	Local nVRatFre  := 0 // Valor do Rateio do Frete
	Local nVRatDes  := 0 // Valor do Rateio da Despesa
	Local cCliente  := ""
	Local cRg       := ""
	Local cEntidade := ""
	Local dDtEnt    := Ctod('')
	Local nPesol    := 0
	Local nPesob    := 0

	Local nTotSuframa := 0

// Jorge Oliveira - 21/01/2011 - Chamado: AAZTHT - Ajuste do espacamento entre as linhas impressas e as informacoes do rodape
	Local nMaxLin   	:= 65 // Quantidade maxima de linhas para impressao ( relatorio normal )
	Local nLinRodape	:= 15 // Quantidade de linhas necessarias para imprimir o rodape ( relatorio normal )
	//Local aImposto  	:= {}
	Local nTotFinal 	:= 0
	Local lGFabrica 	:= .F.
	Local cPesq 			:= " "
	Local cText 			:= " "
	Local nPos
	Local nValorFrt	:= 0

	m_pag    := 1

	nTipo := IIf(aReturn[4]==1,15,18)

	titulo := cTitEmp

	//| Inserido por Edivaldo Gonsalves Cordeiro em 11/09/2007 - Garante o posicionamento no Orcamento ativo em Tela

	//| Armazena os dados da Empresa.
	If ! M->UA_PROSPEC
		cEntidade := "SA1"
		dbSelectArea("SA1");dbSetOrder(1)
		If dbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA)
			cCliente:= SA1->A1_COD + " - " + SA1->A1_NOME
			cCGC    := SA1->A1_CGC
			cRg     := IIf(!Empty(SA1->A1_INSCR),SA1->A1_INSCR,SA1->A1_RG)
		Else
			cCliente := "Not Found"
			cCgc     := "Not Found"
		EndIf
	Else
		cEntidade := "SUS"
		dbSelectArea("SUS");dbSetOrder(1)
		If dbSeek(xFilial("SUS")+M->UA_CLIENTE+M->UA_LOJA)
			cCliente:= SUS->US_COD + " - " + SUS->US_NOME
			cCGC    := SUS->US_CGC
		Else
			cCliente := "Not Found"
			cCgc     := "Not Found"
		EndIf
	EndIf

		//| Gera o arquivo de configuracao do lFax
	If nDestPrint = 2 // fax somente para relatorio grafico
		GeraLFax(cTipOper)
	EndIf

	//| Impresssao de cabecalho
	If nDestPrint = 1     // Normal

	Else
		oPrn:StartPage()// INICIO DE PAGINA
		ICabec(titulo, cabec1,cabec2,nomeprog,tamanho,nTipo,cTipOper,.T.)
	EndIf

	nDespTot := nTotAcrI := nTotUniI := nQtdTotI := nTotAcrG := nTotFinal:= nTotMerc := nTotItem := nTotQtd := nTotLiq := nVlIpi := nTotIpi := nVlUnit := nVlAcre := nLiq1 := nLiq := nValMerc := nVlST := nvTotST := 0

	nItem := 0

	//|  Monta Totais apartir do __aCCols....
	For nT:= 1 To Len(__aCCols)
		If !__aCCols[nT][A_DELETE]
			nTotQtd 		+= __aCCols[nT][A_QUANT]
			nTotAcrG 	+= __aCCols[nT][A_VLACRE] * __aCCols[nT][A_QUANT] // 836.807 + 1.75
		EndIf
	Next

	//| Percorre o __aCCols
	For nI := 1 To Len(__aCCols)

		If __aCCols[nI][A_DELETE] // Verifica se a linha esta deletada ... para seguir...
			Loop
		EndIf

		DbSelectArea('SF4');DbSeek(xFilial('SF4')+__aCCols[nI][A_TES])
		If SF4->F4_IPI == 'S'
			lCalcIpi := .T.
		Else
			lCalcIpi := .F.
		EndIf

		dbSelectArea("SB1");dbSetOrder(1)
		dbSeek(xFilial("SB1")+__aCCols[nI][A_CODIGO])

		cPesq := "MC3"
		cText := SB1->B1_REFER
		nPos := AT( cPesq, cText )

				//| Tratamento para Substituicao Tributaria -> Edivaldo Gonsalves Cordeiro 13/08/2008
		cIndustr := SB1->B1_INDUSTR

		If ! lGFabrica
			lGFabrica := If(((SB1->B1_SGRB1 = "220000" .and. SB1->B1_GRMAR3 = "000510" .and. SB1->B1_MERCADO = "N").OR.(If(! SUA->UA_PROSPEC,SA1->A1_GRPSEG = "AG3",SUS->US_GRPSEG = "AG3"))),.T.,.F.)
		Endif

		If Substr(SA1->A1_GRPSEG,3,1) == "3"
			If U_FVerNcm()// Verifica se Produto eh ST
				If !U_FCnaeAuto()// Verifica Cnae Do Cliente
					If cINDUSTR == "S"
						If (! SF2->F2_FILIAL $ALLTRIM(GETMV("MV_MENFIL"))) .AND. (! SF2->F2_FILIAL + SF2->F2_EST $ALLTRIM(GETMV("MV_MENFIL1"))) .AND. SA1->A1_CONAGRI <> "1"  //Agostinho - 24/03/2009 - Chamado AAZOSN retirada da mensagem para as filias 02-CUI, 04-GOI e 05-CDP quando venda para o RS

							cCaracter:='+'
							cMens1  := " + Mercadorias P/ Uso e Aplicacao Exclusivamente Industrial Nao Sujeita a ST"
							cMens2  := " Cfe Protocolo 49/08"

						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		If nDestPrint = 1   // NORMAL

		Else

			oPrn:Say( Li, nCol+0000, PADR( ALLTRIM( SB1->B1_COD ), 15, " " ) + cCaracter , oFont, 100 )
			oPrn:Say( Li, nCol+0180, PADR( ALLTRIM( SB1->B1_DESC ), 30, " " ) + cCaracter , oFont, 100 )

			If nPos > 0
				Li += 50
				oPrn:Say( Li, nCol+0180, PADR(  'Separador de Bronze' , 30, " " ) , oFont, 100 )
			Endif

			oPrn:Say( Li, nCol+0750, SB1->B1_UM, oFont, 100 )//700
			oPrn:Say( Li, nCol+870, Transform(__aCCols[nI][A_QUANT], "@E 99,999.99"), oFont, 100 )//crisalt
			oPrn:Say( Li, nCol+1095, Transform(__aCCols[nI][A_VLACRE], _MASC_VL_U_), oFont, 100 )//crisalt

			If nPos>0
				//Msginfo('Imprimir mensagem')
			Endif

		EndIf

		cCliente		:= SUA->UA_CLIENTE
		cLojCli 		:= SUA->UA_LOJA
		cTipCli 		:= SA1->A1_TIPO  //'R'
		nDespTot		:= aValores[_DESPESA] //SUA->UA_DESPESA
		nValorFrt 	:= aValores[_FRETE]   ///M->UA_FRETCAL

		nQtdTotI  	:= __aCCols[nI][A_QUANT] //QRY_SUB->QTD_PECAS
		nTotAcrI 	+= __aCCols[nI][A_VLACRE] * nQtdTotI //QRY_SUB->VAL_MERC
		nTotUniI		+= __aCCols[nI][A_VLUNIT] * nQtdTotI
		cProduto		:= __aCCols[nI][A_CODIGO] //SB1->B1_COD crisalt
		cTes    		:= __aCCols[nI][A_TES] //SUB->UB_TES

		nQtdTotI 	:= __aCCols[nI][A_QUANT]//SUB->UB_QUANT
		nPrcVen 		:= __aCCols[nI][A_VLUNIT] //NoRound(SUB->UB_VLRITEM/__aCCols[nI][A_QUANT] ,4) //SUB->UB_VRCACRE
		nValor  		:= __aCCols[nI][A_QUANT] * __aCCols[nI][A_VLACRE]   //SUB->UB_BASEICM //SUB->UB_VLRITEM   //SUB->UB_QUANT * SUB->UB_VRCACRE

		nVlAcre   	:= __aCCols[nI][A_VLACRE]
		nVlUnit   	:= __aCCols[nI][A_VLUNIT] //CRISALT //NoRound( SUB->UB_VRCACRE * SUB->UB_QUANT, 4 )

		nFatorItem	:= 	nVlAcre * nQtdTotI / nTotAcrG  // Fator do item frente ao total acrescimo

		nVRDespT 	:=  nDespTot * nFatorItem   					// Valor Rateio Despesa no Total do Item
		nVRDespI		:=  nVRDespT  / nQtdTotI 							// Valor Rateio Despesa no Item

				//|  Jorge Oliveira - 31/01/2011 - Ajustes para mostrar o valor Unitario c/IPI
		If nValorFrt > 0
			nVRFretT 		:= ( nValorFrt  *  nFatorItem )
			nVRFretI 		:= ( nVRFretT   /  nQtdTotI   )

			//Alert(Cvaltochar(nVRFretT) )
		Else
			nVRFretT := 0
			nVRFretI  := 0
		EndIf

		nItem 			+= 1
		//xImposto(cCliente,cLojCli,cTipCli,cProduto,cTes,nQtdTotI,nPrcVen,nValor,nVRDespT+nVRFretT,nI)

		If ( MaFisRet(nI,"IT_BASESOL" ) > 0 ) //| Só Calcula a ST quando houver base... |
			// nVlST := (MaFisRet(nI,"IT_VALSOL")/__aCCols[nI][A_QUANT])  	//:= (( MaFisRet(nI,"IT_BASESOL" ) * MaFisRet(nI,"IT_ALIQSOL") / 100 ) - MaFisRet(nI,"IT_VALICM") ) / __aCCols[nI][A_QUANT] // CRISALT //NoRound(aImposto[1],4)  //MAFISRET(NITEM,"LF_ICMSRET")//NoRound(aImposto[1],4)

			nVlST 	:= __aCCols[nI][A_VLRST]		//	FABIANO PEREIRA
			nvTotST	+=	MaFisRet(nI,"IT_VALSOL")	// TOTAL ST COM DESPESAS NA BASE
		Else
			nVlST := 0
		EndIf

		//nvTotST		+= nVlST  * __aCCols[nI][A_QUANT]


		nTotSuframa := 0 // nSuf //MAFISRET(,"NF_DESCZF") //nSUF  //VINDO DIRETO
		If lCalcIpi
			nAliqIpiI := ( SB1->B1_IPI / 100 )
		Else
			nAliqIpiI := 0
		EndIf

		nVlIpi := 0
		If lCalcIpi

		//| JULIO JACOVENKO - 20/02/2012
		//| Ajustado para calcular o imp sobre o frete e outras
		//| despesas NO TOTAL, estava usando somente o nVlUnit (Vlr sem despesas)

			// nVlIpi 	:= ( ( nVlAcre ) * nAliqIpiI ) // crisalt //Round(  (nVRatDes+nVRatFre+nLiq)  * ( SB1->B1_IPI/100 ), 2 )
			nVlIpi 	:=__aCCols[nI][A_VLRIPI]		//	FABIANO PEREIRA

			//nTotIpi   += ((nVlIpi * __aCCols[nI][A_QUANT] ) + ( nVRDespT * nAliqIpiI ) + ( nVRFretT * nAliqIpiI )) ///crisalt
			nTotIpi   += ( nVlIpi + ( nVRDespT * nAliqIpiI ) + ( nVRFretT * nAliqIpiI )) ///crisalt

		EndIf

		// FABIANO PEREIRA
		// nValMerc  := nVlAcre  + nVlIpi  + nVlST //| + nVRDespI  //U_FValIcmsRet()
		nValMerc  := nVlAcre  + nVlIpi

		nTotLiq   += ( ( nVlUnit + nVlIpi + nVlST ) * nQtdTotI ) +  nVRDespT + nVRFretT + ( nVRFretT * nAliqIpiI ) + ( nVRDespT * nAliqIpiI )

		//| Aliquota de IPI
		If lCalcIpi
			If nDestPrint = 1   // NORMAL
			Else

				oPrn:Say( Li, nCol+1330, Transform(nAliqIpiI * 100, "@E 99"), oFont, 100 ) // CRISALT
				oPrn:Say( Li, nCol+1430, Transform(nVlIpi, _MASC_VL_U_), oFont, 100 ) // CRISALT

			EndIf
		Else
			If nDestPrint = 1   // NORMAL
			Else
				oPrn:Say( Li, nCol+1410, Transform(0, _MASC_VL_U_), oFont, 100 ) // CRISALT
			EndIf
		EndIf

		If nDestPrint = 1   // NORMAL
		Else

			oPrn:Say( Li, nCol+1630, Transform(nVlST			, _MASC_VL_U_), oFont, 100 )//crisalt
			oPrn:Say( Li, nCol+1930, Transform(nValMerc + nVlST	, _MASC_VL_U_), oFont, 100 ) //crisalt
			oPrn:Say( Li, nCol+2230, Transform((nValMerc + nVlST) * __aCCols[nI][A_QUANT] , _MASC_VL_T_), oFont, 100 )// crisalt

			cNcm	 :=	AllTrim(SB1->B1_POSIPI)

			oPrn:Say( Li, nCol+2470, PADR( ALLTRIM( SB1->B1_POSIPI ), 10, " " ) + cCaracter, oFont, 100 )//crisalt

			If ! Empty(__aCCols[nI][A_DTENTG])
				oPrn:Say( Li, nCol+2700, Dtoc(__aCCols[nI][A_DTENTG])+ SPACE(4), oFont, 100 )
			Else
				oPrn:Say( Li, nCol+2680, 'Sob Consulta'  , oFont, 100 )
				lindisp :=.t.
			EndIf

					//| Chamado: AAZR8U | Solicitante: Gabriel   | Analista: Cristiano Machado   | Data: 09/11/09   ||
			If SB1->B1_SGRB1 == "000257"
				Li += 50
				oPrn:Say( Li, nCol+0000, "*** Elevadores - Contem chapa de encosto em todas as borrachas." , oFont, 100 )  //oPrn:Say( Li, nCol+0000, SB1->B1_DESC, oFont, 100 )
			Endif

					//| marcio  se o produto for originado de um Equivalente ou Similar, mostra de qual.
			If !Empty(__aCCols[nI][A_EQSIMORI])
				Li+=50
				oPrn:Say( Li, 00300,  replicate('-',3) + "> Item Oriundo do Equivalente/Similar : " + Posicione("SB1",1,xFilial("SB1")+__aCCols[nI][A_EQSIMORI],"B1_DESC"), oFont, 100 ) //CHR(196)
			EndIf

			Li+=50
			oPrn:Say( Li, nCol+0000, Repl("-",350), oFont, 100 )
			Li+=50

		EndIf

		If dDtEnt < __aCCols[nI][A_DTENTG]
			dDtEnt := __aCCols[nI][A_DTENTG]
		EndIf

		nPesol := nPesol + (SB1->B1_PESO 		* __aCCols[nI][A_QUANT])
		nPesob := nPesob + (SB1->B1_PESBRU 	* __aCCols[nI][A_QUANT])

		//dbSelectArea("SUB");dbSkip()
		cCaracter = ""

		If nDestPrint = 1   // NORMAL
		Else

			//Alert("Item: " + cValToChar(nI) + " Linha: " + cValToChar(Li) + " TamPag: " + cValToChar(nTamPag) + " Margem: " +cValToChar(nMargInf)  )
			If Li > (nTamPag-nMargInf) .And. Len(__aCCols) > nI // !Eof() .and. (xFilial("SUB")+SUA->UA_NUM == SUB->UB_FILIAL+SUB->UB_NUM)
				//Alert("Entrou ICabec1")
				Li+=50
				oPrn:Say( Li, nCol+0900, 'CONTINUA...', oFont, 100 )

				LI+=200
				oPrn:Say( Li, nCol+2500, 'PAGINA N.: '+STRZERO(++NPAGINA,05,00), oFont, 100 )

				oPrn:EndPage()    // finaliza a pagina
				oPrn:StartPage()// inicio de pagina

				ICabec1()

			EndIf
		EndIf

	Next

	If SA1->A1_EST=='GO' .AND. SA1->A1_GRPSEG $ "AG3/AU3/IN3" .AND. cFilant = '04'

		If nDestPrint == 1   // Normal
		Else
			oPrn:Say( Li+120, 1200, 'ATENCAO',oFontb, 100 )
			oPrn:Say( Li+150, nCol, 'Ao comparar nossos precos com os de outros fornecedores locais, nao esqueca de verificar se a Substituicao Tributaria esta destacada (TARE).', oFontb, 100 )
			//oPrn:Say( Li+150, nCol, 'esqueca de verificar se a Substituicao Tributaria esta destacada (TARE).', oFontb, 100 )

		Endif
	Endif

 		//| Regra para  MT
	If SA1->A1_GRPSEG $ "AG3/AU3/IN3" .AND. SA1->A1_EST == SM0->M0_ESTENT   //| Clientes do segmento AG3/AU3/IN3 e venda realizada dentro do estado

		If nDestPrint = 1   // Normal
		Else
			If Li > ( nTamPag - nMargInf - nEspRoda )
				Li+=50
				oPrn:Say( Li, nCol+0900, 'CONTINUA...', oFont, 100 )

				LI+=200
				oPrn:Say( Li, nCol+2500, 'PAGINA N.: '+STRZERO(++NPAGINA,05,00), oFont, 100 )

				oPrn:EndPage()    // finaliza a pagina
				oPrn:StartPage()// INICIO DE PAGINA

				ICabec1()

			EndIf
		EndIf

		If nDestPrint = 1   // Normal
		Else

			oPrn:Say( Li, 1250, 'PREZADOS CLIENTES', oFont2, 100 ) //oFontb, 100 )

			If lGFabrica

				oPrn:Box( Li+30,400-20   ,Li+100, 400+1850)
				oPrn:Say( Li+80, 400, 'Correias Agricolas GOODYEAR : As unicas com 100% de garantia do fabricante !', oFont9 )

			Endif

			oPrn:Say( Li+190, nCol, 'Para compras fora do estado e fundamental levar em consideracao as mesmas bases de ICMS e Substituicao Tributaria.', oFont2, 100 )  //oFontb, 100 )
			oPrn:Say( Li+250, nCol, '*** O FATURAMENTO MINIMO E DE ' + ALLTRIM(Transform(GETMV("IM_PEDMINF"),'@E 999,999.99')) + ' REAIS ***', oFont2, 100 )  //oFontb, 100 )

		Endif

	Else

		oPrn:Say( Li+160, nCol, '*** O FATURAMENTO MINIMO DE ' + ALLTRIM(Transform(GETMV("IM_PEDMINF"),'@E 999,999.99')) + ' REAIS ***', oFont2, 100 )  //oFontb, 100 )

	Endif

	If nDestPrint = 1   // Normal
	Else
		If Li > (nTamPag-nMargInf-nEspRoda)
			Li+=50
			oPrn:Say( Li, nCol+0900, 'CONTINUA...', oFont, 100 )

			LI+=200
			oPrn:Say( Li, nCol+2500, 'PAGINA N.: '+STRZERO(++NPAGINA,05,00), oFont, 100 )

			oPrn:EndPage()    // finaliza a pagina
			oPrn:StartPage()// INICIO DE PAGINA

			ICabec1()

		EndIf
	EndIf

	If nDestPrint = 1   // NORMAL

	Else

			//| Jorge Oliveira - 21/01/2011 - Chamado: AAZTHT - Ajuste do espacamento entre as linhas impressas e as informacoes do rodape
		Li := ( nTamPag-nMargInf-nEspRoda )
		Li+=50+50+50+50
		oPrn:Say( Li, nCol+2500, 'PAGINA N.: '+STRZERO(++NPAGINA,05,00), oFont, 100 )
		Li+=50
		oPrn:Say( Li, nCol+0000, Repl("-",350), oFont, 100 )
		Li+=50
		oPrn:Say( Li, nCol+0000, 'Despesa: ', oFont, 100 )
		oPrn:Say( Li, nCol+0250, Transform(nDespTot,'@E 999,999.99') , oFont, 100 )


		oPrn:Say( Li, nCol+0450, "Valor IPI:", oFont, 100 )
		oPrn:Say( Li, nCol+0650, Transform(nTotIpi,'@E 999,999.99') , oFont, 100 )

		oPrn:Say( Li, nCol+0850, "Total Merc.:", oFont, 100 ) //oPrn:Say( Li, nCol+0850, "Total Liq:", oFont, 100 )
			//nTotLiq + nvTotST + nTotIpi + SUA->UA_FRETE + SUA->UA_DESPESA
		oPrn:Say( Li, nCol+1050, Transform(nTotAcrG,'@E 9,999,999.99') , oFont, 100 ) //oPrn:Say( Li, nCol+1050, Transform(nTotLiq,'@E 9,999,999.99') , oFont, 100 )

		oPrn:Say( Li, nCol+1250, "Valor ST:", oFont, 100 )

		oPrn:Say( Li, nCol+1450, Transform(nvTotST ,'@E 999,999.99'), oFont, 100 )
		oPrn:Say( Li, nCol+1650, 'Frete:', oFont, 100 )
		oPrn:Say( Li, nCol+1850, Transform(nValorFrt,'@E 999,999.99') , oFont, 100 )

		nTotFinal := ( nTotUniI * nAcrFin / 100 ) + nTotLiq //+ nValorFrt
		oPrn:Say( Li, nCol+2050, 'Valor Total:', oFont, 100 )
		oPrn:Say( Li, nCol+2250, Transform(nTotFinal ,'@E 9,999,999.99') , oFont, 100 ) //Transform(nTotGeral-nTotIcmsRet,'@E 9,999,999.99') , oFont, 100 )

		//| Julio Jacovenko em 26/04/2012
		//| temos de tirar o ST do total (nTotGeral), pois quando ele
		//| soma este ja esta incluso no SUB->UB_VRCACRE.

		Li+=50
		oPrn:Say( Li, nCol+0000, Repl("-",350), oFont, 100 )

		Li+=50
		oPrn:Say( Li, nCol+0000, "Total Pecas:", oFont, 100 )
		oPrn:Say( Li, nCol+0250, Transform(nTotQtd,'@E 99,999.99') , oFont, 100 )
		oPrn:Say( Li, nCol+0450, "P.Liq:", oFont, 100 )
		oPrn:Say( Li, nCol+0650, Transform(nPesol,'@E 99999.99') , oFont, 100 )
		oPrn:Say( Li, nCol+0850, 'P.Brut:', oFont, 100 )
		oPrn:Say( Li, nCol+1050, Transform(nPesob,'@E 99999.99') , oFont, 100 )

		oPrn:Say( Li, nCol+1250, 'Cond. Pagto:', oFont, 100 )
		oPrn:Say( Li, nCol+1500, M->UA_CONDPG + " - " + Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_DESCRI"), oFont, 100 )

		If !Empty( cMens1 )
			Li+=50
			oPrn:Say( Li, nCol+0000, Alltrim(cMens1), oFont, 100 )
		EndIf

		If !Empty( cMens2 )
			Li+=50
			oPrn:Say( Li, nCol+0000, Alltrim(cMens2), oFont, 100 )
		EndIf

		Li+=50
		oPrn:Say( Li, nCol+0000, Repl("-",350), oFont, 100 )
		Li+=50
		oPrn:Say( Li, nCol+0000, 'Transportadora: '+ M->UA_TRANSP + " - " + AllTrim(Posicione("SA4",1,xFilial("SA4")+M->UA_TRANSP,"A4_NOME")), oFont, 100 )
		oPrn:Say( Li, nCol+1800, 'Frete: ', oFont, 100 )
		oPrn:Say( Li, nCol+1950, Iif(M->UA_TPFRETE=='C','CIF','FOB') , oFont, 100 )

		Li+=50
		oPrn:Say( Li, nCol+0000, Repl("-",350), oFont, 100 )
		Li+=50
		oPrn:Say( Li, nCol+0000, 'Validade da Proposta: '+'02 (dois) dias.', oFont8, 100 )
		oPrn:Say( Li, nCol+0700, 'Sera acrescida despesa bancaria por duplicata.', oFont8, 100 )
		oPrn:Say( Li, nCol+1400, 'Itens importados sujeito a Variacao Cambial.', oFont8, 100 )
		oPrn:Say( Li, nCol+2100, 'Gerado em: '+Dtoc(M->UA_EMISSAO)+' - '+SubStr(M->UA_INICIO,1,5), oFont8, 100 )

		Li+=50
		oPrn:Say( Li, nCol+0000, Repl("-",350), oFont, 100 )
	EndIf

	IRoda()

	If nDestPrint = 2 // Grafico
		oPrn:EndPage() // Fechamento da pagina
	EndIf


	If nDestPrint == 1     // Relatorio normal
	Else                  // Relatorio grafico
		oPrn:Preview()

	EndIf

Return()
*********************************************************************
Static Function ICabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,cTipOper,lImp,nPagina)
*********************************************************************
	Local aArea    := GetArea()
	Local aAreaSA1 := SA1->( GetArea() )
	Local cBitMap  := 'LGRL'+cEmpAnt+'.BMP'      // carrega o logo da empresa


	If lImp=NIL
		lImp:=.T.
	Endif
	If nPagina=NIL
		nPagina=0
	EndIf

	dbSelectArea("SA1")
	dbSeek(xfilial('SA1')+cImdepa+SM0->M0_CODFIL)
	cTitEmp   := AllTrim(SA1->A1_NOME)
	cWww      := AllTrim(SA1->A1_HPAGE)

	titulo  := cTitEmp

	If nDestPrint = 1    // NORMAL
	Else

		Li := 50

		oPrn:SayBitmap( Li, nCol+000, cBitMap, 340, 90 )
		Li+=100
		If cEmpAnt = '01'
			oPrn:Say( Li, nCol+0550, cTitEmp, oFont6, 800 )
			Li+=50
			oPrn:Say( Li, nCol+0450, AllTrim(Cabec1), oFont6, 100 )
			oPrn:Say( Li, nCol+0850, AllTrim(Cabec2), oFont6, 100 )
			Li+=50
			oPrn:Say( Li, nCol+0000, Repl("-",350), oFont, 100 )
		Else
			oPrn:Say( Li, nCol+0900, cTitEmp, oFont6, 800 )
			Li+=50
			oPrn:Say( Li, nCol+0800, AllTrim(Cabec1), oFont6, 100 )
			oPrn:Say( Li, nCol+1200, AllTrim(Cabec2), oFont6, 100 )
			Li+=50
			oPrn:Say( Li, nCol+0000, Repl("-",350), oFont, 100 )
		EndIf

	EndIf

	_aArea := GetArea()
	//| Recupera os dados do Cliente
	dbSelectArea("SA1")
	dbSeek(xfilial('SA1')+M->UA_CLIENTE+M->UA_LOJA)

	If cTipOper = "1"
		cVendResp := SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDEXT,"A3_NOME"))
		cEmailResp:= SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDEXT,"A3_EMAIL"))

		cRepresen    := SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND,"A3_NOME"))
		cMailRepr    := SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND,"A3_EMAIL"))
		cMailChefVen := SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_CHEFVEN,"A3_EMAIL"))
		cMailCoodVen := SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDCOO,"A3_EMAIL"))



		cMailCli 	:= SA1->A1_EMAIL

		If Empty(cVendResp)//Pedido do Call Center nao possui vendedor ligado ao cliente |Inserido por Edivaldo Goncalves em 25/06/2010
			cVendResp := SA1->(Posicione("SU7",1,xFilial("SU7")+M->UA_OPERADO,"U7_NOME"))
		Endif


	Else
		cVendResp := SA1->(Posicione("SU7",1,xFilial("SU7")+M->UA_OPERADO,"U7_NOME"))
		cEmailResp:= SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDEXT,"A3_EMAIL"))

		cRepresen := SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND,"A3_NOME"))
		cMailRepr := SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND,"A3_EMAIL"))

		cMailChefVen := SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_CHEFVEN,"A3_EMAIL"))
		cMailCoodVen := SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDCOO,"A3_EMAIL"))

		cMailCli 	:= SA1->A1_EMAIL

	EndIf

	RestArea(_aArea)

	If lImp
		If nDestPrint = 1   // NORMAL
		Else
			Li+=50
			oPrn:Say( Li, nCol+0000, 'De:', oFont, 100 )

			oPrn:Say( Li, nCol+0060, SA1->A1_NOME, oFont, 300 )
			oPrn:Say( Li, nCol+1210, 'Filial: '+AllTrim(SM0->M0_FILIAL), oFont, 100 )
			Li+=50
			oPrn:Say( Li, nCol+0000, 'Fone: ('+SA1->A1_DDD+') '+SA1->A1_TEL, oFont, 100 )
                  //1000
			oPrn:Say( Li, nCol+0500, 'Fax: ('+SA1->A1_DDD+') '+SA1->A1_FAX, oFont, 100 )

			oPrn:Say( Li, nCol+0900, 'e-mail: '+SA1->A1_EMAIL, oFont, 100 )
		EndIf
	EndIf

	//| posiciona nos dados do contato
	SU5->( dbseek(xFilial('SU5')+M->UA_CODCONT) )
	SUM->( dbseek(xFilial('SUM')+SU5->U5_FUNCAO) )

	If ! M->UA_PROSPEC

	//| Recupera os dados do Cliente
		dbSelectArea("SA1")
		dbSeek(xfilial('SA1')+M->UA_CLIENTE+M->UA_LOJA)

		If cTipOper = "1"
			cVendResp := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDEXT,"A3_NOME")

			cRepresen := SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND,"A3_NOME"))
			cMailRepr := SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND,"A3_EMAIL"))

			cMailChefVen := SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_CHEFVEN,"A3_EMAIL"))
		    cMailCoodVen := SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDCOO,"A3_EMAIL"))

			If Empty(cVendResp)//Pedido do Call Center nao possui vendedor ligado ao cliente |Inserido por Edivaldo Goncalves em 25/06/2010
                       //Pega o usuario que gravou o Orcamento
				cVendResp := Posicione("SU7",1,xFilial("SU7")+M->UA_OPERADO,"U7_NOME")
			Endif
		Else
			cVendResp := Posicione("SU7",1,xFilial("SU7")+M->UA_OPERADO,"U7_NOME")
		EndIf

		If lImp
			If nDestPrint = 1   // NORMAL
			Else

				cVend:=cVendResp
				cVend+=' Email: '+cEmailResp
				oPrn:Say( Li, nCol+1480, 'Vendedor : '+cVend, oFont, 100 )

				Li+=50
				oPrn:Say( Li, nCol+0000, 'Cliente: '+SA1->A1_COD+'-'+SA1->A1_NOME, oFont, 100 )

				oPrn:Say( Li, nCol+1200, 'Endereco: '+AllTrim(SA1->A1_TLOGEND)+" "+AllTrim(U_ALTEND(SA1->A1_END))+" "+AllTrim(Str(SA1->A1_NUMEND,6))+" "+AllTrim(SA1->A1_COMPEND), oFont, 100 )

				oPrn:Say( Li, nCol+2250, AllTrim(SA1->A1_MUN)+' - '+SA1->A1_EST+' - CEP: '+SA1->A1_CEP, oFont, 100 )
				Li+=50
				oPrn:Say( Li, nCol+0000, 'Fone: ('+SA1->A1_DDD+') '+SA1->A1_TEL, oFont, 100 )
				oPrn:Say( Li, nCol+1000, 'Fax:  ('+SA1->A1_DDD+') '+SA1->A1_FAX, oFont, 100 )
				oPrn:Say( Li, nCol+1450, 'e-mail: '+SA1->A1_EMAIL, oFont, 100 )

				Li+=50
				oPrn:Say( Li, nCol+0000, 'CNPJ/CPF: '+SA1->A1_CGC, oFont, 100 )
				oPrn:Say( Li, nCol+1000, 'Insc. Estadual: '+SA1->A1_INSCR, oFont, 100 )

			EndIf
		EndIf
	Else
		If lImp
			If nDestPrint = 1   // NORMAL

			Else
				Li+=50
				oPrn:Say( Li, nCol+0000, 'Prospect: '+SUS->US_COD+'-'+SUS->US_NOME, oFont, 100 )

				oPrn:Say( Li, nCol+1200, 'Endereco: '+AllTrim(SUS->US_TLOGEND)+" "+AllTrim(SUS->US_END)+" "+AllTrim(Str(SUS->US_NUMEND,6))+" "+AllTrim(SUS->US_COMPEND), oFont, 100 )

				oPrn:Say( Li, nCol+2250, AllTrim(SUS->US_MUN)+' - '+SUS->US_EST+' - CEP: '+SUS->US_CEP, oFont, 100 )
				Li+=50
				oPrn:Say( Li, nCol+0000, 'Fone: ('+SUS->US_DDD+') '+SUS->US_TEL, oFont, 100 )
				oPrn:Say( Li, nCol+1000, 'Fax:  ('+SUS->US_DDD+') '+SUS->US_FAX, oFont, 100 )
				oPrn:Say( Li, nCol+1450, 'e-mail: '+SA1->A1_EMAIL, oFont, 100 )
				Li+=50
				oPrn:Say( Li, nCol+0000, 'CNPJ/CPF: '+SUS->US_CGC, oFont, 100 )
				oPrn:Say( Li, nCol+1000, 'Insc. Estadual: '+SUS->US_INSCR, oFont, 100 )
			EndIf
		Endif
	EndIf

	If nDestPrint == 1   // NORMAL
	Else
		If LIMP
			Li+=50
			oPrn:Say( Li, nCol+0000, 'Contato: '+SubStr(SU5->U5_CONTAT,1,25), oFont, 100 )
			oPrn:Say( Li, nCol+1000, 'Cargo: '  +SubStr(SUM->UM_DESC,1,25), oFont, 100 )
			oPrn:Say( Li, nCol+1560, 'e-mail: ' +SU5->U5_EMAIL, oFont, 100 )

			cMailCont := SU5->U5_EMAIL

		EndIf

		If cTipOper == '1' // Orcamento
			cTipOper 	:= 'Orcamento N.: '
			cNumAte		:= M->UA_NUM				//| Existe este campo em Memoria por isso pode pegar na Memoria
		Else
			cTipOper 	:= 'Pedido N.: '
			cNumAte		:= SUA->UA_NUMSC5	//| Nao Existe este campo em Memoria por isso tem que pegar da Tabela
		EndIf

		Li+=50
		oPrn:Say( Li, nCol+0000, 'Assunto: '+cTipOper+cNumAte, oFont, 100 )

		oPrn:Say( Li, nCol+1000, 'Pagina: '+StrZero(nPagina,05,00), oFont, 100 )

		oPrn:Say( Li, nCol+1500, 'Ordem de Compra: ', oFont, 100 )

		//If cTipOper == '1'
			Li+=50
			oPrn:Say( Li, nCol+0000, 'Obs.: '+M->UA_OBSORC, oFont, 100 )
		//EndIf

		IF LIMP
			Li+=050
			oPrn:Say( Li, nCol+0000, 'Atendendo a sua solicitacao, apresentamos nossas disponibilidades:', oFont, 100 )
		ENDIF

		Li+=050

		oPrn:Say( Li, nCol+0000, Repl("-",350), oFont, 100 )    // PROVISORIO

		Li+=50

		oPrn:Say( Li, nCol+0000, 'Codigo', oFont, 100 )
		oPrn:Say( Li, nCol+0180, 'Referencia e Marca', oFont, 100 )
		oPrn:Say( Li, nCol+0750, 'Un', oFont, 100 )
		oPrn:Say( Li, nCol+0860, 'Quantidade', oFont, 100 )
		oPrn:Say( Li, nCol+1100, 'Valor Unit', oFont, 100 )
		oPrn:Say( Li, nCol+1300, 'IPI Aliq', oFont, 100 )
		oPrn:Say( Li, nCol+1460, 'IPI Unit', oFont, 100 )
		oPrn:Say( Li, nCol+1650, 'ST Unit', oFont, 100 )
		oPrn:Say( Li, nCol+1850, 'Valor + IPI + ST Unit', oFont, 100 )
		oPrn:Say( Li, nCol+2150, 'Valor + IPI + ST Total', oFont, 100 )
		oPrn:Say( Li, nCol+2500, 'NCM', oFont, 100 )
		oPrn:Say( Li, nCol+2670, 'Prev Entrega', oFont, 100 )

		Li+=50
		oPrn:Say( Li, nCol+0000, Repl("-",350), oFont, 100 )    // PROVISORIO
		Li+=50
	EndIf

	RestArea(aAreaSA1)
	RestArea(aArea)

Return(Li)


*********************************************************************
Static Function IRoda()
*********************************************************************
	Local cRoda1 := AllTrim(cWww)+Space(20)+AllTrim(cTitEmp)+Space(20)+AllTrim(cWww)
	Local cRoda2 := Iif(SM0->M0_CODIGO$'01/51', 'Distribuidor: INA  FAG  LUK  SABO  TIMKEN  GOODYEAR', Iif(SM0->M0_CODIGO$'02/52', 'Distribuidor: FAG  SABO  TIMKEN' ,' '))

	cRoda1  := Space(Int((nColunas-Len(cRoda1))/2))+cRoda1
	cRoda2  := Space(Int((nColunas-Len(cRoda2))/2))+cRoda2

Return
*********************************************************************
Static Function GeraLFax(cTipOper)//Rotina para gerar o arquivo de configuracao do LFAX
*********************************************************************
	Local cLFaxPath   := GetMV('MV_LFAX')
	Local hFile       := FCreate(cLFaxPath+'\lfaxinfo.txt')
	Local cAssunto    := Iif(cTipOper=='1', 'Orcamento ', 'Pedido de Venda')
	Local cFax
	Local cNome       := Space(0)

	If ! UA_PROSPEC
		cFax  := AllTrim( SA1->A1_DDD ) + AllTrim( SA1->A1_FAX )
		cNome := SA1->A1_NOME
	Else
		cFax  := AllTrim( SUS->US_DDD ) + AllTrim( SUS->US_FAX )
		cNome := SUS->US_NOME
	EndIf

	fWrite(hFile, cFax+';;;;'+cNome+';;;'+cAssunto+';;;;NAO;')

	fClose(hFile)

Return
*********************************************************************
Static Function xPergunta( cTipOper )//Define o destino da impressao do orcamento ou pedido
*********************************************************************

Return( nDestPrint )

// #########################################################################################
// Projeto: Calculo do Imposto na Tela da Verdade...
// Modulo : Call Center
// Fonte  : IMDR060
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 23/05/03 | Julio Jacovenko   | Imprime Orcamento de Vendas
//          |                   | Parametros:
//          |                   |			cCliente 	-> Codigo do cliente
//          |                   |			cLoja 			-> Loja do cliente
//          |                   |			Tipo 			-> Tipo de cliente
//          |                   |			cProduto 	-> Codigo do produto
//          |                   |			cTes 			-> Tes usado na venda
//          |                   |			nQtd 			-> Quantidade da venda (linha)
//          |                   |     nPrc 			-> Preco unitario
//          |                   |     nValor 		-> Valor da mercadoria (unitario, Junto com descontos,etc..)
// ---------+-------------------+-----------------------------------------------------------
*******************************************************************************
Static Function XImposto(cCliente,cLoja,cTipOper,cProduto,cTes,nQtd,nPrc,nValor,nDespesa,nItem)
*******************************************************************************
/*
	Local aImp 			:= {0,0,0}
	Local lJaCalcI		:= .F.

	//|Fim Cristiano
	If !lJaSave //  Se nao Salvou os impostos ..  entra...

		lJaCalcI := MaFisFound()


		//|Analista: Cristiano Machado   Data: 18/09/2010   Obs: Correcao Mensagem "SEMDADOS"
		If !lJaCalcI
			lJaSave := .T. // MaFisClear()
		Endif

	EndIf
	//|Analista: Cristiano Machado   Data: 18/09/2010   Obs: Correcao Mensagem "SEMDADOS"
	If lJaSave // !MaFisFound()
		Alert("Entrou Tk273Recalc")
		MaFisAlt("IT_QUANT"		,nQtd			,nItem)
		MaFisAlt("IT_PRCUNI"	,nPrcVen		,nItem)
		MaFisAlt("IT_VALMERC"	,nValor		,nItem)

		MaColsToFis(aHeader,aCols,nItem,"TK271",.T.,NIL,NIL,NIL)

		Tk273Recalc(nItem)

	EndIf
*/
Return()
*******************************************************************************
Static Function ICabec1()
*******************************************************************************
	Local cabec1_1 := 'Cod       Refer./Marca                    Un    Qtdade    Vlr. Unit  IPI       ST     Pr.Un.c/IPI e ST   Total c/IPI e ST    NCM       Prev.entrega'
	Local cBitMap  := 'LGRL'+cEmpAnt+'.BMP'      // carrega o logo da empresa

	If nDestPrint = 1    // NORMAL

	Else

		Li := 50

		oPrn:SayBitmap( Li, nCol+000, cBitMap, 340, 90 )
		Li+=100
		If cEmpAnt = '01'
			oPrn:Say( Li, nCol+0550, cTitEmp, oFont6, 800 )
		Else
			oPrn:Say( Li, nCol+0900, cTitEmp, oFont6, 800 )
		EndIf

		Li+=050
		oPrn:Say( Li, nCol+0000, Repl("-",350), oFont, 100 )    // PROVISORIO
		Li+=50

		oPrn:Say( Li, nCol+0000, 'Codigo', oFont, 100 )
		oPrn:Say( Li, nCol+0180, 'Referencia e Marca', oFont, 100 )
		oPrn:Say( Li, nCol+0750, 'Un', oFont, 100 )
		oPrn:Say( Li, nCol+0860, 'Quantidade', oFont, 100 )
		oPrn:Say( Li, nCol+1100, 'Valor Unit', oFont, 100 )
		oPrn:Say( Li, nCol+1300, 'IPI Aliq', oFont, 100 )
		oPrn:Say( Li, nCol+1460, 'IPI Unit', oFont, 100 )
		oPrn:Say( Li, nCol+1650, 'ST Unit', oFont, 100 )
		oPrn:Say( Li, nCol+1850, 'Valor + IPI + ST Unit', oFont, 100 )
		oPrn:Say( Li, nCol+2150, 'Valor + IPI + ST Total', oFont, 100 )
		oPrn:Say( Li, nCol+2500, 'NCM', oFont, 100 )
		oPrn:Say( Li, nCol+2670, 'Prev Entrega', oFont, 100 )

		Li+=50
		oPrn:Say( Li, nCol+0000, Repl("-",350), oFont, 100 )    // PROVISORIO
		Li+=50

	EndIf

Return()
*******************************************************************************
Static Function ValidacoesGerias(lPerg) /// Validacoes em Geral
*******************************************************************************
	Local lValidacao := .T.

	//| Solicita o Click na Condição de Pagamento antes de emitir o Orcamento...

	If !ExistDir("C:\MP11")
		If MakeDir ("C:\MP11" ) <> 0
			IW_MsgBox("Não foi possivel criar o Diretório 'C:\MP11' este é necessário, para salvar o arquivo PDF. Entrar em contato com a TI.","Impressao de Orcamento/Pedido", "ALERT")
			lValidacao := _SAIR_
		EndIf
	EndIf

	//| Solicita Gravacao de Orcamento Novo ou Alterado
	If lValidacao .And. _lAltOrc .And. !lPerg //.And. Alltrim(Procname(1)) <> "U_TMKVFIM"//.And.  Empty(M->UA_DOC) .AND. PROCNAME(2) == "ACTIVATE"  //PROCNAME(1)<> "U_TMKR03" //PROCNAME(1) <> "U_TMKR3A"
		IW_MsgBox("Como este Orcamento/Pedido foi alterado, realize a gravacao antes da Impressao","Impressao de Orcamento/Pedido", "ALERT")
		lValidacao := _SAIR_
	Endif

	IF !_ljaCPaCP .And. lValidacao
		IW_MsgBox("Por favor, clique na Condição de pagamento antes de imprimir o Orçamento","Impressao de Orcamento/Pedido", "ALERT")
		lValidacao := _SAIR_
	EndIf

	// Solicita Gravacao de Orcamento Vencido...
	If lFaturado == NAOFATURANDO //| Somente Efetua esta validacao em Orçamento não Faturados... |
		If lValidacao .And. (dDataBase >  M->UA_DTLIM .AND. M->UA_DOC<>' ') .And. !lPerg
			IW_MsgBox("Como este Orcamento esta Vencido, realize a gravacao antes da Impressao","Impressao de Orcamento/Pedido", "ALERT")
			lValidacao := _SAIR_
		EndIf
	EndIf
	//|  Pergunta se o Vendedor deseja abrir o Orcamento...
	If lPerg .And. lValidacao
	//	If !( IW_MsgBox( "Deseja olhar o Orcamento ? " , "Escolha uma Opcao ..." , "YESNO" ) )
	//		lValidacao := _SAIR_
	//	EndIf
	EndIf

Return ( lValidacao )

*******************************************************************************
Static Function RetPosArr(aHeader, cCampo)// Obtem a posicao dos Campos atravŽs do aheader
*******************************************************************************
	Local nPos := 0

	For nP := 1 To Len(aHeader)
		If Alltrim(aHeader[nP][2]) == Alltrim(cCampo)

			nPos := nP
			exit

		EndIf
	Next

Return nPos