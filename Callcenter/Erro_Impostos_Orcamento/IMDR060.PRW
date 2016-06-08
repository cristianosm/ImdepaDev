#Include "RWMAKE.CH"
#Include "TMKR03.CH"
#Include "TOPCONN.CH"
#Include "TOTVS.CH"
#Include "PROTHEUS.CH"

#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF


//JULIO JACOVENKO, em 14/02/2014
//COMPATIBILIZADO COM O DA PRODUCAO (VERSAO AGOSTINHO) 
//ENVIADO ESTE POR EMAIL
//   

///JULIO JACOVENKO, em 24/04/2014
///ajustado valor st por item e total
///nTOTICMSRET trocado pelo MAFISRET(,"NF_VALSOL")


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUNCAO    ³TMKR03    ºAutor  ³Luis Marcelo Kotaki º Data ³  15/01/98   º±±
±±ºAlterado  ³IMDR060   ºAutor  ³Marllon Figueiredo  º Data ³ 23/05/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime Pedido ou Orcamento                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGATMK  - Rotina de televendas                             º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Fabio Rogerio ³12/09/00³      ³Revisao para a versao 5.08              ³±±
±±³Márcio QBorges³12/12/05³      ³Adicionado Linha de Equivalente/Similar ³±±
±±³              ³  /  /  ³      ³e reformulado Lay-Out                   ³±±
±±³Márcio QBorges³09/01/05³      ³Campo descrição mostrado completo       ³±±
±±³Márcio QBorges³13/06/06³      ³Alterado Tot.C/IPI para UA_VLRIPI       ³±±
±±³Márcio QBorges³08/12/06³      ³'Indisponivel' mudou para 'Sob Consulta'³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³Julio Jacovenko³28/01/14*      ³Ajustes ST x SUFRAMA  
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*********************************************************************
User Function IMDR060(cNumAte, cTipo, NSUF, NST)
*********************************************************************

//³ Define Variaveis ³
	Local nHeight10    := 10
	Local nHeight12    := 12

	Local nHeight16    := 16

	Local nHeight15    := 15
	Local lBold	      	:= .T.
	Local lUnderLine   := .T.

// Jorge Oliveira - 21/01/2011 - Chamado: AAZTHT - Ajuste do espacamento entre as linhas impressas e as informacoes do rodape
	Private nTamCab    := 250      // espaco para o cabecalho ( relaltorio modelo grafico )
	Private nTamPag    := 2000 //2850     // altura total da pagina ( relaltorio modelo grafico )
	Private nEspRoda   := 350      // espaco reservado para o rodape ( relaltorio modelo grafico )
	Private nMargInf   := 10 //50       // margem inferior ( relaltorio modelo grafico )
	Private Li         := 0
	Private nCol       := 0
//Private oFont	    := TFont():New( "Arial",,nHeight12,,lBold,,,,,!lUnderLine )  
//Julio Jacovenko, em 24/04/2012 - alterado para fonte ficar menor,
//dando mais espaço quando paisagem
	Private oFont     := TFont():New( "Arial",,nHeight10,,lBold,,,,,!lUnderLine )

	Private oFont8    := TFont():New( "Arial",,nHeight10-2,,lBold,,,,,!lUnderLine )

	Private oFontb	   := TFont():New( "Arial",,nHeight16,,lBold,,,,,!lUnderLine )

	Private oFont2     := TFont():New( "Tahoma",,nheight12,,lBold,,,,,!lUnderLine )
	Private oFont9     := TFont():New( "Tahoma",,nheight16,,lBold,,,,,!lUnderLine )
	Private oBrush1    := TBrush():New( , CLR_BLACK )
    

	Private oFont3     := TFont():New( "Mono AS",,nHeight10,,!lBold,,,,,!lUnderLine )
	Private oFont4     := TFont():New( "Times New Roman",,nheight15   ,,!lBold,,,,,lUnderLine )
	Private oFont5     := TFont():New( "Arial",,nHeight10,,!lBold,,,,,!lUnderLine )
	Private oFont6     := TFont():New( "Arial",,nheight15,,lBold,,,,,!lUnderLine )
	Private oFont7     := TFont():New( "Times New Roman",,nheight10-2 ,,!lBold,,,,,lUnderLine )
	Private wnrel      := "IMDR060"
	Private nOrdem     := 0
	Private tamanho    := "G"
	Private nColunas   := 90
	Private limite     := 132//90
	Private titulo     := Iif(cTipo=='1', 'Orcamento', 'Pedido de Venda')
	Private cDesc1     := 'Este programa ira emitir o '+Iif(cTipo=='1', 'Orcamento.', 'Pedido de Venda.')
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
	Private cEmailResp := ""
	Private nPagina    := 0
	
	
	//Permite imprimir o Orcamento/Pedido pelo botao imprimir , apenas pedidos com nota fiscal emitida
	//Para Orçamentos/Pedidos em aberto , a impressao é feita somente apos a gravacao	
	If _lAltOrc .AND.  Empty(SUA->UA_DOC) .AND. PROCNAME(2) == "ACTIVATE"  //PROCNAME(1)<> "U_TMKR03" //PROCNAME(1) <> "U_TMKR3A"
		IW_MsgBox("Este Orçamento/Pedido foi alterado após a ultima gravação , faça a confirmação para realizar a impressão","Impressão de Orçamento/Pedido")
	  	//IW_MsgBox("Esta opção somente é permitida para pedidos com NF. Emitida"+Chr(10)+Chr(13)+"Para impressão do Orçamento/Pedido ou envio por e-mail , favor clicar no botão <CONFIRMAR> !","Impressão de Orçamento/Pedido")
		Return
	Endif
	
// define o destino da impressao
	nDestPrint := xPergunta(cTipo)

	If nDestPrint = 0
		Return
	EndIf
	//ALERT(NSUF)
	//ALERT(NST)
//nDestPrint:=2
	 
// coloca no centro do relatorio
	cTitEmp  := Space(Int((nColunas-Len(cTitemp))/2))+cTitEmp
	Cabec1   := Space(Int((nColunas-Len(Cabec1))/2))+Cabec1
	Cabec2   := Space(Int((nColunas-Len(Cabec2))/2))+Cabec2

	If nDestPrint = 1    // NORMAL
		li := 80
	Else
		Li := 80  //50
	EndIf              // Ajuste de margem esquerda

	nCol    := 50

	If nDestPrint = 1     // relatorio normal
	
		wnrel := SetPrint(cString,wnrel,,titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,.F.)
	
		If ( nLastKey == 27 .Or. LastKey() == 27 )
			Set Filter to
			Return
		Endif
	
		SetDefault(aReturn, cString)
	
		If ( nLastKey == 27 .Or. LastKey() == 27 )
			Set Filter to
			Return
		Endif
	
		RptStatus({|lEnd| C003Imp(@lEnd,wnRel,cString,cNumAte,cTipo,NSUF,NST)},Titulo)
	
	ElseIf nDestPrint = 2     // relatorio grafico
	
		oPrn := TMSPrinter():New()
		oPrn:Setup()
		oPrn:SetLandsCape() //SetPortrait()   //SetLandsCape()
	
		RptStatus( {|lEnd| C003Imp(@lEnd,wnRel,cString,cNumAte,cTipo,NSUF,NST) },Titulo )
	
	EndIf

Return( .T. )


*********************************************************************
Static Function C003Imp(lEnd,WnRel,cString,cNumAte,cTipo,NSUF,NST)
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
//Cristiano
	Local nTotIcmsRet := 0
	Local nTotSuframa := 0
// Jorge Oliveira - 21/01/2011 - Chamado: AAZTHT - Ajuste do espacamento entre as linhas impressas e as informacoes do rodape
	Local nMaxLin   := 65 // Quantidade maxima de linhas para impressao ( relatorio normal )
	Local nLinRodape:= 15 // Quantidade de linhas necessarias para imprimir o rodape ( relatorio normal )
	Local aImposto  :={}
	Local nTotFinal :=0
	Local lGFabrica := .F.

	Private cImdepa := GetMV('MV_IMDEPA')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape  .³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	m_pag    := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve comprimir ou nao                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nTipo := IIf(aReturn[4]==1,15,18)

	titulo := cTitEmp

	SetRegua(RecCount())		// Total de Elementos da regua

//Inserido por Edivaldo Gonçalves Cordeiro em 11/09/2007 - Garante o posicionamento no orçamento ativo em Tela
	cNumAte	:= M->UA_NUM

	dbSelectArea("SUA");dbSetOrder(1)
	If dbSeek(xFilial("SUA") + cNumAte) //Pedido
		 
	
		IncRegua()
	
	// Armazena os dados da Empresa.
		If ! SUA->UA_PROSPEC
			cEntidade := "SA1"
			dbSelectArea("SA1");dbSetOrder(1)
			If dbSeek(xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA)
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
			If dbSeek(xFilial("SUS")+SUA->UA_CLIENTE+SUA->UA_LOJA)
				cCliente:= SUS->US_COD + " - " + SUS->US_NOME
				cCGC    := SUS->US_CGC
			Else
				cCliente := "Not Found"
				cCgc     := "Not Found"
			EndIf
		EndIf
	
	// Gera o arquivo de configuracao do lFax
		If nDestPrint = 2 // fax somente para relatorio grafico
			GeraLFax(cTipo)
		EndIf
	
	// Impresssao de cabecalho
		If nDestPrint = 1     // Normal
			ICabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,cTipo,.T.)
		Else
			oPrn:StartPage()	// INICIO DE PAGINA
		// cabecalho
			ICabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,cTipo,.T.)
		EndIf
	
	// Imprime os produtos/servicos pedidos.
		nTotFinal:= nTotMerc := nTotQtd := nTotGeral := nTotLiq := nValIpi := nTotIpi := nLiq := nLiq1 := nValMerc := 0
	
		Iif(nDestPrint == 1,Li,Li)
	
	// Jorge Oliveira - 16/12/10 - Soma a quantidade total de itens para utilizar nos Rateios do Frete e do Acrescimo
		cQuery := "SELECT TRUNC( SUM( UB_VRCACRE * UB_QUANT ), 2 ) AS VAL_MERC "
		cQuery += "     , SUM( UB_QUANT ) AS QTD_PECAS, COUNT(*) AS NLINHA  "
		cQuery += "  FROM " + RetSqlName("SUB") + " "
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += "   AND UB_FILIAL  = '" + xFilial("SUB") + "' "
		cQuery += "   AND UB_NUM     = '" + SUA->UA_NUM + "' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY_SUB",.F.,.T.)
		DbSelectArea("QRY_SUB")
		DbGoTop()

		nTotQtd := 0
		If QRY_SUB->( !EOF() )
			nTotQtd  := QRY_SUB->QTD_PECAS
			nTotMerc := QRY_SUB->VAL_MERC
			NTOTITEM := QRY_SUB->NLINHA
		EndIf
		QRY_SUB->( DbCloseArea() )

		dbSelectArea("SUB")
		dbSetOrder(1)
	    
		NITEM:=0
		If dbSeek(xFilial("SUB")+SUA->UA_NUM)
		     
		        ///JULIO JACOVENKO, 17/01/2013 - GUARDAR A AREA FISCAL
			MAFISSAVE()
			MAFISEND()

		
			While (!Eof()) .And. (xFilial("SUB")+SUA->UA_NUM == SUB->UB_FILIAL+SUB->UB_NUM)

				dbSelectArea('SF4');dbSeek(xFilial('SF4')+SUB->UB_TES)
				If SF4->F4_IPI == 'S'
					lCalcIpi := .T.
				Else
					lCalcIpi := .F.
				EndIf

				dbSelectArea("SB1");dbSetOrder(1)
				dbSeek(xFilial("SB1")+SUB->UB_PRODUTO)
			
			//Tratamento para Substituição Tributaria
			//Edivaldo Gonçalves Cordeiro 13/08/2008
				cINDUSTR:=SB1->B1_INDUSTR
			
				If ! lGFabrica
					lGFabrica := If(((SB1->B1_SGRB1 = "220000" .and. SB1->B1_GRMAR3 = "000510" .and. SB1->B1_MERCADO = "N").OR.(If(! SUA->UA_PROSPEC,SA1->A1_GRPSEG = "AG3",SUS->US_GRPSEG = "AG3"))),.T.,.F.)
				Endif
				
				If Substr(SA1->A1_GRPSEG,3,1) == "3"
					If U_FVerNcm()// Verifica se Produto eh ST
						If !U_FCnaeAuto()// Verifica Cnae Do Cliente
							If cINDUSTR == "S"
							
								If (! SF2->F2_FILIAL $ALLTRIM(GETMV("MV_MENFIL"))) .AND. (! SF2->F2_FILIAL + SF2->F2_EST $ALLTRIM(GETMV("MV_MENFIL1"))) .AND. SA1->A1_CONAGRI <> "1"  //Agostinho - 24/03/2009 - Chamado AAZOSN retirada da mensagem para as filias 02-CUI, 04-GOI e 05-CDP quando venda para o RS
								
									cCaracter:='+'
									cMens1  := " + Mercadorias P/ Uso e Aplicação Exclusivamente Industrial Não Sujeita a ST"
									cMens2  := " Cfe Protocolo 49/08"
								
								EndIf
							
							EndIf
						EndIf
					EndIf
				EndIf
			
			//          Codigo          Descricao                       Un    Qtdade    Vlr. Unit.  IPI(%) Vlr.c/IPI  Prev.Entrega    Tot.Liq Total c/IPI
			//          123456789012345 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  AA  99999.99   999999.9999  99   999999.9999   99/99/9999  9999999.99  9999999.99
			//          123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
			
				If nDestPrint = 1   // NORMAL
				
				// Jorge Oliveira - 08/12/2010 - Utiliza a Descricao do Produto
				//@ Li,000		PSAY PADR(ALLTRIM(SB1->B1_REFER)+" "+ALLTRIM(SB1->B1_MARCA),50," ") + cCaracter  PICTURE "@!"
				//oPrn:Say( Li, nCol+0000, PADR( ALLTRIM( SB1->B1_COD ), 15, " " ) + cCaracter , oFont, 100 )
					@ Li,000      PSAY PADR( ALLTRIM( SB1->B1_COD ), 08, " " ) + cCaracter
					@ Li,Pcol()+2 PSAY PADR( ALLTRIM( SB1->B1_DESC ), 30, " " ) + cCaracter  PICTURE "@!"
					@ Li,Pcol()+2 PSAY SB1->B1_UM			   PICTURE PESQPICT("SB1","B1_UM") //032
					@ Li,Pcol()+2 PSAY SUB->UB_QUANT           PICTURE '@E 99999.99'  //036
					@ Li,Pcol()+2 PSAY SUB->UB_VRCACRE         PICTURE "@E 999999.9999" //046

				Else
				
				// Jorge Oliveira - 08/12/2010 - Utiliza a Descricao do Produto
				//oPrn:Say( Li, nCol+0000, PADR(ALLTRIM(SB1->B1_REFER)+" "+ALLTRIM(SB1->B1_MARCA),50," ") + cCaracter , oFont, 100 )  //oPrn:Say( Li, nCol+0000, SB1->B1_DESC, oFont, 100 )
				//Julio Jacovenko - 24/04/2012
					oPrn:Say( Li, nCol+0000, PADR( ALLTRIM( SB1->B1_COD ), 15, " " ) + cCaracter , oFont, 100 )
					oPrn:Say( Li, nCol+0180, PADR( ALLTRIM( SB1->B1_DESC ), 30, " " ) + cCaracter , oFont, 100 )
                //Li := Li+=50
					oPrn:Say( Li, nCol+0750, SB1->B1_UM, oFont, 100 )//700
					oPrn:Say( Li, nCol+0900, Transform(SUB->UB_QUANT, '@E 99999.99'), oFont, 100 )
					oPrn:Say( Li, nCol+1200, Transform(SUB->UB_VRCACRE, '@E 999999.9999'), oFont, 100 )
			
				EndIf
			// Cristiano
			//nTotIcmsRet += U_FValIcmsRet()
				cCLIENTE:=SUA->UA_CLIENTE
				cLOJCLI :=SUA->UA_LOJA
				cTIPCLI :=SA1->A1_TIPO  //'R'
				cPRODUTO:=SB1->B1_COD
				cTES    :=SUB->UB_TES
				nQTDVEN :=SUB->UB_QUANT
				
				nPRCVEN :=NoRound(SUB->UB_VLRITEM/SUB->UB_QUANT,4) //SUB->UB_VRCACRE
				
				nVALOR  :=SUB->UB_QUANT * NOROUND(SUB->UB_VRCACRE,4)   //SUB->UB_BASEICM //SUB->UB_VLRITEM   //SUB->UB_QUANT * SUB->UB_VRCACRE
				//nDespesa:=(SUA->UA_DESPESA+SUA->UA_FRETE)/NTOTITEM
            //JULIO JACOVENKO, 02/07/2013
			//reaplicado em 28/01/2014
			//aplicando rateio sobre despesas....
			///                                                                              
				nLiq     := NoRound( SUB->UB_VRCACRE * SUB->UB_QUANT, 4 )
				nVRatDes := NoRound(( SUA->UA_DESPESA / nTotMerc ) * nLiq , 6)
			
				NDESPESA:= NVRATDES
			
			
		    ///para pegar valor ST
				NITEM+=1
				aImposto    := xfImpostos(cCliente,cLojCli,cTipCli,cPRODUTO,cTES,nQTDVEN,nPRCVEN,nVALOR,NDESPESA,NITEM)
				nvST        := NoRound(aImposto[1],4)  	//MAFISRET(NITEM,"LF_ICMSRET")//NoRound(aImposto[1],4)
                
                
                
                ///para pegar o valor da suframa por item (se houver)
				nVlrSu      := NoRound(aImposto[2],4)
				nTOTICMSRET += nvST
				
				nTOTSUFRAMA := nSUF //MAFISRET(,"NF_DESCZF") //nSUF  //VINDO DIRETO
			    //ALERT(NVST)
			
		
			
			// Jorge Oliveira - 31/01/2011 - Ajustes para mostrar o valor Unitario c/IPI
			//nLiq := SUB->UB_VRCACRE * SUB->UB_QUANT


				nLiq := NoRound( SUB->UB_VRCACRE * SUB->UB_QUANT, 4 ) // Campo SUB->UB_VRCACRE tem 4 casas decimais
				///Julio Jacovenko, 24/04/2012
				nLIQ1:=SUB->UB_VRCACRE
			
			// Jorge Oliveira - 31/01/2011 - Ajustes para mostrar o valor Unitario c/IPI
				If SUA->UA_DESPESA > 0
					nVRatDes := ( SUA->UA_DESPESA / nTotMerc ) * nLiq
					VRatDes1 := ( SUA->UA_DESPESA / nTotMerc ) * nLiq1
				Else
					nVRatDes := 0
					VRatDes1 := 0
				EndIf
			
			// Jorge Oliveira - 31/01/2011 - Ajustes para mostrar o valor Unitario c/IPI
				If SUA->UA_FRETE > 0
					nVRatFre := ( SUA->UA_FRETE   / nTotMerc ) * nLiq
					VRatFre := ( SUA->UA_FRETE   / nTotMerc ) * nLiq1

				Else
					nVRatFre := 0
					VRatFre  := 0
				EndIf

				nValIpi := 0
				nValIpi1:= 0
				If lCalcIpi
				// Jorge Oliveira - 31/01/2011 - Ajustes para mostrar o valor Unitario c/IPI
				//nValIpi := Round( ( nLiq + nVRatDes + nVRatFre ) * ( SB1->B1_IPI/100 ), 2 )
				//Inserido por Edivaldo Goncalves Cordeiro em 16/06/11 Valor com IPI eh o Liquido + % IPI
				//nValIpi := Round(  nLiq  * ( SB1->B1_IPI/100 ), 2 )  
				
				///JULIO JACOVENKO - 20/02/2012
				///Ajustado para calcular o imp sobre o frete e outras 
				///despesas NO TOTAL, estava usando somente o NLIQ (Vlr sem despesas)
					nValIpi := Round(  (nVRatDes+nVRatFre+nLiq)  * ( SB1->B1_IPI/100 ), 2 )
					nValIpi1:= Round(  (VRatDes1+VRatFre+nLiq1)  * ( SB1->B1_IPI/100 ), 2 )
				
				EndIf
         
         // Jorge Oliveira - 31/01/2011 - Ajustes para mostrar o valor Unitario c/IPI
         
            ///Julio Jacovenko, em 24/04/2012 - colocar o ST no preco
			
				nValMerc  := nLiq  + nValIpi  + nvST   //U_FValIcmsRet()
			
			//ValMerc1  := nLiq1 + nValIpi1 + NOROUND((U_FValIcmsRet()/SUB->UB_QUANT))
				ValMerc1  := nLiq1 + nValIpi1 + NOROUND(nvST/SUB->UB_QUANT,4)
				nTotLiq   += nLiq
				nTotIpi   += nValIpi
				nTotGeral += nValMerc
			
			
			// Aliquota de IPI
				If lCalcIpi
					If nDestPrint = 1   // NORMAL
						@ Li,Pcol()+2 PSAY SB1->B1_IPI PICTURE "99"   //060
					Else
						oPrn:Say( Li, nCol+1450, Transform(SB1->B1_IPI, '99'), oFont, 100 )
					EndIf
				Else
					If nDestPrint = 1   // NORMAL
						@ Li,Pcol()+2 PSAY 0           PICTURE "99" //60
					Else
						oPrn:Say( Li, nCol+1450, Transform(0, '99'), oFont, 100 )
					EndIf
				EndIf
			
			
			
			
				If nDestPrint = 1   // NORMAL
			
			
			    ///Julio Jacovenko, 24/04/2012
			    ///Nova ordem
			    ///VALOR DO ST, PRCUNIT+IPI+ST
			    ///TOTAL COM IPI+ST
			    ///NCM
			    ///PRAZO DE ENTREGA

                //ST 
                //nvST   
                //nVlrST:=NOROUND(U_FValIcmsRet()/SUB->UB_QUANT)
					
					nVlrST:=NOROUND(nvST/SUB->UB_QUANT,4)
					
                        
                /*
                mafisret(nI,"IT_VALICM") ICM
                MaFisRet(nI,"IT_VALIPI") IPI
                aFisRet(nI,"IT_TOTAL")  TOTAL
                */
                
                
					@ Li,Pcol()+2 PSAY nVlrST                  PICTURE "@E 9999999.9999"

                //PRC UNIT         //NVALMERC
					@ Li,Pcol()+3 PSAY NValMerc/SUB->UB_QUANT   PICTURE "@E 9999999.9999"
                
                
                //PRC TOTAL        //NVALMERC
					@ Li,Pcol()+5 PSAY NValMerc                  PICTURE "@E 9999999.99"
                
                //NCM                                       
					cNCM:=ALLTRIM(SB1->B1_POSIPI)
					@ Li,Pcol()+12 PSAY PADR( ALLTRIM( SB1->B1_POSIPI ), 10, " " ) + cCaracter
			
			
					If !Empty(SUB->UB_DTENTRE)
						@ Li,Pcol()+2 PSAY DTOC(SUB->UB_DTENTRE) + SPACE(4)
					Else
						@ Li,Pcol()+2 PSAY 'Sob Consulta'
					EndIf

				//@ Li,Pcol()+2 PSAY nValMerc                  PICTURE "@E 9999999.99"
				
				//edi
				//@ Li+5,001 PSAY 'TESTE...TESTE...'
				//edi
				
								

				//| Chamado: AAZR8U   | Solicitante: Gabriel   | Analista: Cristiano Machado   | Data: 09/11/09   ||
					If SB1->B1_SGRB1 == "000257"
						Li += 1
						@ Li, 000 Psay "*** Elevadores - Contém chapa de encosto em todas as borrachas."  PICTURE "@!"
					Endif

				//marcio  se o produto for originado de um Equivalente ou Similar, mostra de qual.
					If !Empty(SUB->UB_EQSIORI)
						Li++
						@ Li, 005 PSay Replicate('-',3) + "> Item Oriundo do Equivalente/Similar : " + Posicione("SB1",1,xFilial("SB1")+SUB->UB_EQSIORI,"B1_DESC") //CHR(196)
					EndIf

					Li++
					@ Li, 0000 PSay __PrtThinLine()
					Li++

				Else
			
			    ///Julio Jacovenko, 24/04/2012
			    ///Nova ordem
			    ///VALOR DO ST, PRCUNIT+IPI+ST
			    ///TOTAL COM IPI+ST
			    ///NCM
			    ///PRAZO DE ENTREGA

                //ST
                //nvST    
                //nVlrST:=NOROUND(U_FValIcmsRet()/SUB->UB_QUANT)
					nVlrST:=NOROUND(nvST/SUB->UB_QUANT,4)

					oPrn:Say( Li, nCol+1550, Transform(nVlrST, "@E 9999999.9999"), oFont, 100 )

                //PRC UNIT                        //NVALMERC
					oPrn:Say( Li, nCol+1750, Transform(NValMerc/SUB->UB_QUANT, "@E 9999999.9999"), oFont, 100 )
                
                
                //PRC TOTAL                        //NVALMERC
					oPrn:Say( Li, nCol+2050, Transform(NValMerc, "@E 9999999.99"), oFont, 100 )
                
                //NCM                                       
					cNCM:=ALLTRIM(SB1->B1_POSIPI)
					oPrn:Say( Li, nCol+2280, PADR( ALLTRIM( SB1->B1_POSIPI ), 10, " " ) + cCaracter, oFont, 100 )
                
                
					If ! Empty(SUB->UB_DTENTRE)
						oPrn:Say( Li, nCol+2500, Dtoc(SUB->UB_DTENTRE)+ SPACE(4), oFont, 100 )
					Else
						oPrn:Say( Li, nCol+2500, 'Sob Consulta'  , oFont, 100 )
						lindisp :=.t.
					EndIf
                

				//oPrn:Say( Li, nCol+1880, Transform(nValMerc, "@E 9999999.99"), oFont, 100 )
				
				
				//| Chamado: AAZR8U | Solicitante: Gabriel   | Analista: Cristiano Machado   | Data: 09/11/09   ||
					If SB1->B1_SGRB1 == "000257"
						Li += 50
						oPrn:Say( Li, nCol+0000, "*** Elevadores - Contém chapa de encosto em todas as borrachas." , oFont, 100 )  //oPrn:Say( Li, nCol+0000, SB1->B1_DESC, oFont, 100 )
					Endif

				//marcio  se o produto for originado de um Equivalente ou Similar, mostra de qual.
					If !Empty(SUB->UB_EQSIORI)
						Li+=50
						oPrn:Say( Li, 00300,  replicate('-',3) + "> Item Oriundo do Equivalente/Similar : " + Posicione("SB1",1,xFilial("SB1")+SUB->UB_EQSIORI,"B1_DESC"), oFont, 100 ) //CHR(196)
					EndIf
								
				
				
					Li+=50
					oPrn:Say( Li, nCol+0000, Repl("-",300), oFont, 100 )
					Li+=50
				
				EndIf

				If dDtEnt < SUB->UB_DTENTRE
					dDtEnt := SUB->UB_DTENTRE
				EndIf
			
			// calcula peso
				nPesol := nPesol + (SB1->B1_PESO * SUB->UB_QUANT)
				nPesob := nPesob + (SB1->B1_PESBRU * SUB->UB_QUANT)

				dbSelectArea("SUB");dbSkip()
				cCaracter=''
			
				If nDestPrint = 1   // NORMAL
				// Jorge Oliveira - 21/01/2011 - Chamado: AAZTHT - Ajuste do espacamento entre as linhas impressas e as informacoes do rodape
//					If Li > ( nMaxLin - nLinRodape ) .and. !Eof() .and. (xFilial("SUB")+SUA->UA_NUM == SUB->UB_FILIAL+SUB->UB_NUM)
					If Li >  nMaxLin  .and. !Eof() .and. (xFilial("SUB")+SUA->UA_NUM == SUB->UB_FILIAL+SUB->UB_NUM)
						@ ++Li,040 PSAY 'CONTINUA...'
//					ICabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,cTipo,.F.)
						ICabec1()

					EndIf
				Else
//					If Li > (nTamPag-nMargInf-nEspRoda) .and. !Eof() .and. (xFilial("SUB")+SUA->UA_NUM == SUB->UB_FILIAL+SUB->UB_NUM)
					If Li > (nTamPag-nMargInf) .and. !Eof() .and. (xFilial("SUB")+SUA->UA_NUM == SUB->UB_FILIAL+SUB->UB_NUM)

						Li+=50
						oPrn:Say( Li, nCol+0900, 'CONTINUA...', oFont, 100 )
					
						LI+=200
						oPrn:Say( Li, nCol+2500, 'PAGINA N.: '+STRZERO(++NPAGINA,05,00), oFont, 100 )
					
						oPrn:EndPage()	    // finaliza a pagina
						oPrn:StartPage()	// inicio de pagina
					
//					ICabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,cTipo,.F.)
						ICabec1()
					
					EndIf
				EndIf
	
		
			EndDo
		
		//JULIO JACOVENKO, 16/01/2013
		//ST SOMENTE SOBRE DESPESAS, PARA AGREGAR NA TOTALIZACAO
		//xfImpostos 
		
		/*
		nDespesa:=SUA->UA_DESPESA+SUA->UA_FRETE
         
        nqtdvem :=0
        nprecven:=0
        nvalor  :=0 
                                                                                                              
        NITEM+=1
		aImposto    := xfImpostos(cCliente,cLojCli,cTipCli,cPRODUTO,cTES,nQTDVEN,nPRCVEN,nVALOR,NDESPESA,nitem)
        nvST        :=  aImposto[1]
		nTOTICMSRET += nvST      
	    */
	    
	    //ALERT('TOTAIS')
	    //ALERT(NVST)
		

		//////JULIO JACOVENKO, 17/01/2013 - RESTAURA A AREA FISCAL
			MAFISEND()
			MAFISRESTORE()
		
		/*
		 If SA1->A1_EST=='GO' .AND. SA1->A1_GRPSEG $ "AG3/AU3/IN3" .AND. cFilant = '04'
		  				
		     If nDestPrint = 1   // Normal
		       @ Li,32  PSAY 'ATENÇÃO'	
		       @ Li+2,000 PSAY 'Ao comparar nossos preços com os de outros fornecedores locais , não esqueça de'
	           @ Li+3,000 PSAY 'verificar se a Substituição Tributária esta destacada(TARE). '
	           //@ Li+4,000 PSAY 'Neste caso , acrescente a estes preços ofertados 6.80%'
		       //@ Li+4,000 PSAY 'Ao Comparar nossos Preços com os de outros fornecedores , não esqueça de verificar se a Substituição Tributária esta destacada(TARE). '
		       
		       Else
		      oPrn:Say( Li, 1000, 'ATENÇÃO',oFontb, 100 )		  
		      oPrn:Say( Li+60, nCol, 'Ao comparar nossos preços com os de outros fornecedores locais , não  ', oFontb, 100 )
		      oPrn:Say( Li+109, nCol, 'esqueça de verificar se a Substituição Tributária esta destacada(TARE).', oFontb, 100 )
            //oPrn:Say( Li+148, nCol,'Neste caso , acrescente a estes preços ofertados 6.80%', oFontb, 100 )
		     Endif
		 Endif
		 */
 
		 
		 //Regra para  MT
		 
		 //If cFilant <> '04' .AND.  SA1->A1_GRPSEG $ "AG3/AU3/IN3" .AND. SA1->A1_EST==SM0->M0_ESTENT   //| Clientes do segmento AG3/AU3/IN3 e venda realizada dentro do estado
			If SA1->A1_GRPSEG $ "AG3/AU3/IN3" .AND. SA1->A1_EST==SM0->M0_ESTENT   //| Clientes do segmento AG3/AU3/IN3 e venda realizada dentro do estado

				If nDestPrint = 1   // Normal
					If Li >= ( nMaxLin - nLinRodape )
						@ ++Li,040 PSAY 'CONTINUA...'
						ICabec1()
					EndIf
				Else
					If Li > (nTamPag-nMargInf-nEspRoda)
						Li+=50
						oPrn:Say( Li, nCol+0900, 'CONTINUA...', oFont, 100 )

						LI+=200
						oPrn:Say( Li, nCol+2500, 'PAGINA N.: '+STRZERO(++NPAGINA,05,00), oFont, 100 )
			
						oPrn:EndPage()	    // finaliza a pagina
						oPrn:StartPage()	// INICIO DE PAGINA
			
						ICabec1()

					EndIf
				EndIf
				
				If nDestPrint = 1   // Normal

					@ Li,001 PSAY 'PREZADOS CLIENTES'

					If lGFabrica
                  	@ Li+01,060 PSAY '|'+ Replicate("-",72)+'|'
						@ Li+02,060 PSAY '|CORREIAS AGRÍCOLAS GOODYEAR:AS ÚNICAS COM 100% DE GARANTIA DO FABRICANTE|'
                  	@ Li+03,060 PSAY '|'+ Replicate("-",72) + '|'
					Endif

					@ Li+4,001 PSAY 'Para compras fora do estado é fundamental levar em consideração as mesmas'
					@ Li+5,001 PSAY 'bases de ICM´s e Substituição Tributária.'

					@ Li+7,001 PSAY '*** O FATURAMENTO MÍNIMO É DE ' + ALLTRIM(Transform(GETMV("IM_PEDMINF"),'@E 999,999.99')) +' REAIS ***'


				Else

					oPrn:Say( Li, 1250, 'PREZADOS CLIENTES', oFont2, 100 ) //oFontb, 100 )

					If lGFabrica

						oPrn:Say( Li+80, 400, 'CORREIAS AGRÍCOLAS GOODYEAR:AS ÚNICAS COM 100% DE GARANTIA DO FABRICANTE', oFont9 )

						oPrn:FillRect( {Li+60, 400-20, Li+70, 400+2670}, oBrush1 ) 
						oPrn:FillRect( {Li+160, 400-20, Li+170, 400+2670}, oBrush1 )
						oPrn:FillRect( {Li+60, 400-30, Li+170, 400-20}, oBrush1 )
						oPrn:FillRect( {Li+60, 400+2670, Li+170, 400+2680}, oBrush1 )
						oBrush1:End()

					Endif

					oPrn:Say( Li+190, nCol, 'Para compras fora do estado é fundamental levar em consideração as mesmas '+'bases de ICM´s e Substituição Tributária.', oFont2, 100 )  //oFontb, 100 )
					oPrn:Say( Li+250, nCol, '*** O FATURAMENTO MÍNIMO É DE ' + ALLTRIM(Transform(GETMV("IM_PEDMINF"),'@E 999,999.99')) + ' REAIS ***', oFont2, 100 )  //oFontb, 100 )


              //oPrn:Say( Li+109, nCol, 'bases de ICM´s e Substituição Tributária.', oFont2, 100 )  //oFontb, 100 )		      
				Endif

			Else
          
				If nDestPrint = 1   // Normal

					@ Li,001 PSAY 'PREZADOS CLIENTES'

					If lGFabrica
                  	@ Li+01,060 PSAY '|'+ Replicate("-",72)+'|'
						@ Li+02,060 PSAY '|CORREIAS AGRÍCOLAS GOODYEAR:AS ÚNICAS COM 100% DE GARANTIA DO FABRICANTE|'
                  	@ Li+03,060 PSAY '|'+ Replicate("-",72) + '|'
					Endif

					@ Li+04,000 PSAY '*** O FATURAMENTO MÍNIMO É DE ' + ALLTRIM(Transform(GETMV("IM_PEDMINF"),'@E 999,999.99')) +' REAIS ***'

				Else

					oPrn:Say( Li, 1250, 'PREZADOS CLIENTES', oFont2, 100 ) //oFontb, 100 )

					If lGFabrica

						oPrn:Say( Li+80, 400, 'CORREIAS AGRÍCOLAS GOODYEAR:AS ÚNICAS COM 100% DE GARANTIA DO FABRICANTE', oFont9 )

						oPrn:FillRect( {Li+60, 400-20, Li+70, 400+2670}, oBrush1 ) 
						oPrn:FillRect( {Li+160, 400-20, Li+170, 400+2670}, oBrush1 )
						oPrn:FillRect( {Li+60, 400-30, Li+170, 400-20}, oBrush1 )
						oPrn:FillRect( {Li+60, 400+2670, Li+170, 400+2680}, oBrush1 )
						oBrush1:End()

					Endif

					oPrn:Say( Li+160, nCol, '*** O FATURAMENTO MÍNIMO É DE ' + ALLTRIM(Transform(GETMV("IM_PEDMINF"),'@E 999,999.99')) + ' REAIS ***', oFont2, 100 )  //oFontb, 100 )

				Endif

			Endif
		 
		EndIf
	
	// para fechar a cotacao/pedido
		If nDestPrint = 1   // Normal
			If Li >= ( nMaxLin - nLinRodape )
				@ ++Li,040 PSAY 'CONTINUA...'
//			ICabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,cTipo,.F.)
//			Li += 10
				ICabec1()

			EndIf
		Else
			If Li > (nTamPag-nMargInf-nEspRoda)
				Li+=50
				oPrn:Say( Li, nCol+0900, 'CONTINUA...', oFont, 100 )

				LI+=200
				oPrn:Say( Li, nCol+2500, 'PAGINA N.: '+STRZERO(++NPAGINA,05,00), oFont, 100 )

			
				oPrn:EndPage()	    // finaliza a pagina
				oPrn:StartPage()	// INICIO DE PAGINA
			
//			ICabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,cTipo,.F.)
				ICabec1()

			EndIf
		EndIf

	// Jorge Oliveira - 31/01/2011 - Ajustes para mostrar o valor Unitario c/IPI
	//nTotGeral := NoRound( nTotGeral + nTotIcmsRet + nTotIpi + SUA->UA_FRETE + SUA->UA_DESPESA, 2 )
	
	///JULIO CORRIGIU EM  20/05/2012
	//  nTotGeral := NoRound( nTotGeral + nTotIcmsRet + SUA->UA_FRETE + SUA->UA_DESPESA, 2 ) 
    //  JULIO JACOVENKO, EM 16/01/2013
	//  NVST HE O ST SOBRE O FRETE CALCULADO NO FINAL DO WHILE
	///
		nTotFinal:= NoRound( nTotGeral +  SUA->UA_FRETE + SUA->UA_DESPESA , 4 )
		If nDestPrint = 1   // NORMAL
		// Jorge Oliveira - 21/01/2011 - Chamado: AAZTHT - Ajuste do espacamento entre as linhas impressas e as informacoes do rodape
			Li := ( nMaxLin - nLinRodape )
			@ Li,00 PSAY __PrtThinLine()
      //         1         2         3         4         5         6         7         8         9         10
		// 1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		// Despesa: 9,999,999.99   Valor IPI:9,999,999.99       Total Liq:  9,999,999.99
		// Valor ST:9,999,999.99   Frete:    9,999,999.99       Valor Total:9,999,999.99
		// Total Peças:99,999.99   P.Liq:        99999.99       P.Brut:         99999.99

			Li++
			@ Li,00        PSAY "Despesa      :"
			@ Li,Pcol()+05 PSAY SUA->UA_DESPESA PICTURE '@E 999,999.99'
			@ Li,Pcol()+05 PSAY "Valor IPI    :"
			@ Li,Pcol()+05 PSAY nTotIpi         PICTURE '@E 999,999.99'
			@ Li,Pcol()+05 PSAY "Total Liq    :"
			@ Li,Pcol()+05 PSAY nTotLiq         PICTURE "@E 9,999,999.99"

			@ Li,Pcol()+05 PSAY "Valor ST:"
		
		//NTOTICMSRET:=yfImpostos(cCliente,cLojCli,cTipCli,cPRODUTO,cTES,nQTDVEN,nPRCVEN,nVALOR,NDESPESA)
		
		                                                                        
		    ///JULIO JACOVENKO, em 29/01/2014
		    ///revisado em 24/04/2014
		    ///NTOTICMSRET                            
		    //PSAY MAFISRET(,"NF_VALSOL")
			@ Li,Pcol()+05 PSAY MAFISRET(,"NF_VALSOL")   PICTURE '@E 9,999,999.99'
			@ Li,Pcol()+05 PSAY "Frete        :"
			@ Li,Pcol()+05 PSAY SUA->UA_FRETE PICTURE '@E 9,999,999.99'
			
			//@ Li,Pcol()+05 PSAY "Suframa(-):"                  
			//@ Li,Pcol()+05 PSAY nTOTSUFRAMA PICTURE '@E 99,999.99'
			@ Li,Pcol()+05 PSAY "Valor Total  :"
		
		//Julio Jacovenko em 26/04/2012
		//temos de tirar o ST do total (nTotGeral), pois quando ele
		//soma este ja esta incluso no SUB->UB_VRCACRE.
		//@ Li,Pcol()+05 PSAY (SUA->UA_VLRLIQ)  PICTURE "@E 9,999,999.99" //NTOTGERAL- nTotIcmsRet)  PICTURE "@E 9,999,999.99"
		                                   
		//ALERT(MAFISRET(,"NF_VALMERC"))
		
		
		
		//NTOTFINAL:=SUA->UA_DESPESA+nTotIpi+nTotLiq+MAFISRET(,"NF_VALSOL")+SUA->UA_FRETE
			nTOTFINAL:=MAFISRET(,"NF_TOTAL")
		//-nTOTSUFRAMA
			@ Li,Pcol()+05 PSAY (nTotFinal)  PICTURE "@E 999,999.99" //NTOTGERAL- nTotIcmsRet)  PICTURE "@E 9,999,999.99"
			//@ Li,Pcol()+05 PSAY (nTotFinal-nTotIcmsRet)  PICTURE "@E 999,999.99" //NTOTGERAL- nTotIcmsRet)  PICTURE "@E 9,999,999.99"
		
			Li++
			@ Li,00 PSAY __PrtThinLine()

			Li++
			@ Li,00        PSAY "Total Peças  :"
			@ Li,Pcol()+05 PSAY nTotQtd   PICTURE '@E 9,999,999.99'
			@ Li,Pcol()+05 PSAY "P.Liq        :"
			@ Li,Pcol()+05 PSAY nPesol    PICTURE '@E 9,999,999.99'
			@ Li,Pcol()+05 PSAY "P.Brut       :"
			@ Li,Pcol()+05 PSAY nPesob    PICTURE '@E 9,999,999.99'
			@ Li,Pcol()+05 PSAY 'Cond.Pgto    :' + SUA->UA_CONDPG + ": " + Posicione("SE4",1,xFilial("SE4")+SUA->UA_CONDPG,"E4_DESCRI")
			@ Li,PCol()+05 PSAY 'Prev.Entrega :'+Dtoc(dDtEnt)
		
			If !Empty( cMens1 )
				Li++
				@ Li,000 PSAY Alltrim( cMens1 )
			EndIf
		
			If !Empty( cMens2 )
				Li++
				@ Li,000 PSAY Alltrim( cMens2 )
			EndIf
		
			Li++
			@ Li,00 PSAY __PrtFatLine()
		
			Li++
			@ Li,000 PSAY 'Transportadora: '+ SUA->UA_TRANSP + " - " + AllTrim(Posicione("SA4",1,xFilial("SA4")+SUA->UA_TRANSP,"A4_NOME"))
			@ Li,PCol()+01  PSAY 'Frete: ' + Iif(SUA->UA_TPFRETE='C','CIF','FOB')

			Li++
			@ Li,000 PSAY __PrtThinLine()
			Li++
			@ Li,000       PSAY 'Validade da Proposta: '+'02 (dois) dias'
		//Li++
			@ Li,Pcol()+05       PSAY 'Será acrescida despesa bancária por duplicata.'
		//Li++
			@ Li,Pcol()+05       PSAY 'Itens importados sujeito a variação cambial.'
			@ Li,PCol()+08 PSAY 'Gerado em: '+Dtoc(SUA->UA_EMISSAO)+' - '+SubStr(SUA->UA_INICIO,1,5)
			Li++
			@ Li,000 PSAY __PrtThinLine()

		Else

		// Jorge Oliveira - 21/01/2011 - Chamado: AAZTHT - Ajuste do espacamento entre as linhas impressas e as informacoes do rodape
			Li := ( nTamPag-nMargInf-nEspRoda )
			Li+=50+50+50+50
			oPrn:Say( Li, nCol+2500, 'PAGINA N.: '+STRZERO(++NPAGINA,05,00), oFont, 100 )
			Li+=50
			oPrn:Say( Li, nCol+0000, Repl("-",300), oFont, 100 )
			Li+=50
			oPrn:Say( Li, nCol+0000, 'Despesa: ', oFont, 100 )
			oPrn:Say( Li, nCol+0250, Transform(SUA->UA_DESPESA,'@E 999,999.99') , oFont, 100 )
		
			oPrn:Say( Li, nCol+0450, "Valor IPI:", oFont, 100 )
			oPrn:Say( Li, nCol+0650, Transform(nTotIpi,'@E 999,999.99') , oFont, 100 )
        
			oPrn:Say( Li, nCol+0850, "Total Liq:", oFont, 100 )
			oPrn:Say( Li, nCol+1050, Transform(nTotLiq,'@E 9,999,999.99') , oFont, 100 )
        
			oPrn:Say( Li, nCol+1250, "Valor ST:", oFont, 100 )
        
   		   //NTOTICMSRET:=yfImpostos(cCliente,cLojCli,cTipCli,cPRODUTO,cTES,nQTDVEN,nPRCVEN,nVALOR,NDESPESA)
            //NTOTICMSRET
            //Revisado em 24/04/2014                
			oPrn:Say( Li, nCol+1450, Transform(MAFISRET(,"NF_VALSOL"),'@E 999,999.99'), oFont, 100 )
		
			oPrn:Say( Li, nCol+1650, 'Frete:', oFont, 100 )
			oPrn:Say( Li, nCol+1850, Transform(SUA->UA_FRETE,'@E 999,999.99') , oFont, 100 )
		                                                                           
		
		    ///JACOVENKO em 16/10/2014
 		    //NTOTFINAL:=SUA->UA_DESPESA+nTotIpi+nTotLiq+MAFISRET(,"NF_VALSOL")+SUA->UA_FRETE
			nTOTFINAL:=MAFISRET(,"NF_TOTAL")
		
			oPrn:Say( Li, nCol+2050, 'Valor Total:', oFont, 100 )
			oPrn:Say( Li, nCol+2250, Transform(nTotFinal ,'@E 9,999,999.99') , oFont, 100 ) //Transform(nTotGeral-nTotIcmsRet,'@E 9,999,999.99') , oFont, 100 )

		//oPrn:Say( Li, nCol+0550, Transform(SUA->UA_DESPESA,'@E 999,999.99') , oFont, 100 )
		//oPrn:Say( Li, nCol+0800, "Valor IPI:", oFont, 100 )
		//oPrn:Say( Li, nCol+1000, Transform(nTotIpi,'@E 999,999.99') , oFont, 100 )
		//oPrn:Say( Li, nCol+1520, "Total Liq:", oFont, 100 )
		//oPrn:Say( Li, nCol+1780, Transform(nTotLiq,'@E 9,999,999.99') , oFont, 100 )

		//Li+=50
		//oPrn:Say( Li, nCol+0000, "Valor ST:", oFont, 100 )
		//oPrn:Say( Li, nCol+0550, Transform(nTotIcmsRet,'@E 999,999.99'), oFont, 100 )
		//oPrn:Say( Li, nCol+0800, 'Frete:', oFont, 100 )
		//oPrn:Say( Li, nCol+1000, Transform(SUA->UA_FRETE,'@E 999,999.99') , oFont, 100 )
		//oPrn:Say( Li, nCol+1520, 'Valor Total:', oFont, 100 )

		//Julio Jacovenko em 26/04/2012
		//temos de tirar o ST do total (nTotGeral), pois quando ele
		//soma este ja esta incluso no SUB->UB_VRCACRE.
		//oPrn:Say( Li, nCol+1780, Transform(nTotGeral,'@E 9,999,999.99') , oFont, 100 )
        //oPrn:Say( Li, nCol+1780, Transform(nTotGeral-nTotIcmsRet,'@E 9,999,999.99') , oFont, 100 )		
			Li+=50
			oPrn:Say( Li, nCol+0000, Repl("-",300), oFont, 100 )

			Li+=50
			oPrn:Say( Li, nCol+0000, "Total Peças:", oFont, 100 )
			oPrn:Say( Li, nCol+0250, Transform(nTotQtd,'@E 99,999.99') , oFont, 100 )
			oPrn:Say( Li, nCol+0450, "P.Liq:", oFont, 100 )
			oPrn:Say( Li, nCol+0650, Transform(nPesol,'@E 99999.99') , oFont, 100 )
			oPrn:Say( Li, nCol+0850, 'P.Brut:', oFont, 100 )
			oPrn:Say( Li, nCol+1050, Transform(nPesob,'@E 99999.99') , oFont, 100 )

			oPrn:Say( Li, nCol+1250, 'Cond. Pagto:', oFont, 100 )
			oPrn:Say( Li, nCol+1500, SUA->UA_CONDPG + " - " + Posicione("SE4",1,xFilial("SE4")+SUA->UA_CONDPG,"E4_DESCRI"), oFont, 100 )

		//oPrn:Say( Li, nCol+0550, Transform(nTotQtd,'@E 99,999.99') , oFont, 100 )
		//oPrn:Say( Li, nCol+0800, "P.Liq:", oFont, 100 )
		//oPrn:Say( Li, nCol+1000, Transform(nPesol,'@E 99999.99') , oFont, 100 )
		//oPrn:Say( Li, nCol+1520, 'P.Brut:', oFont, 100 )
		//oPrn:Say( Li, nCol+1780, Transform(nPesob,'@E 99999.99') , oFont, 100 )
        
			If !Empty( cMens1 )
				Li+=50
				oPrn:Say( Li, nCol+0000, Alltrim(cMens1), oFont, 100 )
			EndIf
		
			If !Empty( cMens2 )
				Li+=50
				oPrn:Say( Li, nCol+0000, Alltrim(cMens2), oFont, 100 )
			EndIf
		
		/*
		Li+=50
		oPrn:Say( Li, nCol+0000, Repl("-",250), oFont, 100 )
        
		Li+=50
		oPrn:Say( Li, nCol+0000, 'Cond. Pagto: ', oFont, 100 )
		oPrn:Say( Li, nCol+0800, SUA->UA_CONDPG + " - " + Posicione("SE4",1,xFilial("SE4")+SUA->UA_CONDPG,"E4_DESCRI"), oFont, 100 )
		oPrn:Say( Li, nCol+1650, 'Frete: ', oFont, 100 )
		oPrn:Say( Li, nCol+1880, Iif(SUA->UA_TPFRETE='C','CIF','FOB') , oFont, 100 )
        */
        
			Li+=50
			oPrn:Say( Li, nCol+0000, Repl("-",300), oFont, 100 )
			Li+=50
			oPrn:Say( Li, nCol+0000, 'Transportadora: '+ SUA->UA_TRANSP + " - " + AllTrim(Posicione("SA4",1,xFilial("SA4")+SUA->UA_TRANSP,"A4_NOME")), oFont, 100 )
			oPrn:Say( Li, nCol+1800, 'Frete: ', oFont, 100 )
			oPrn:Say( Li, nCol+1950, Iif(SUA->UA_TPFRETE='C','CIF','FOB') , oFont, 100 )
		
			Li+=50
			oPrn:Say( Li, nCol+0000, Repl("-",300), oFont, 100 )
			Li+=50
			oPrn:Say( Li, nCol+0000, 'Validade da Proposta: '+'02 (dois) dias.', oFont8, 100 )
			oPrn:Say( Li, nCol+0700, 'Será acrescida despesa bancária por duplicata.', oFont8, 100 )
			oPrn:Say( Li, nCol+1400, 'Itens importados sujeito a variação cambial.', oFont8, 100 )
			oPrn:Say( Li, nCol+2100, 'Gerado em: '+Dtoc(SUA->UA_EMISSAO)+' - '+SubStr(SUA->UA_INICIO,1,5), oFont8, 100 )

		//Li+=50
		//oPrn:Say( Li, nCol+0000, 'Será acrescida despesa bancária por duplicata.', oFont, 100 )
		//Li+=50
		//oPrn:Say( Li, nCol+0000, 'Itens importados sujeito a variação cambial.', oFont, 100 )
		//oPrn:Say( Li, nCol+1700, 'Gerado em: '+Dtoc(SUA->UA_EMISSAO)+' - '+SubStr(SUA->UA_INICIO,1,5), oFont, 100 )
			Li+=50
			oPrn:Say( Li, nCol+0000, Repl("-",300), oFont, 100 )
		EndIf
	
		IRoda()
	
		If nDestPrint = 2 // Grafico
			oPrn:EndPage() // Fechamento da pagina
		EndIf
	
	EndIf

	dbSelectArea("SUA")
	RetIndex("SUA")
	Set Filter To
	dbSetOrder(1)

	nTotIcmsRet := 0

	If nDestPrint == 1     // Relatorio normal
		Set Device To Screen
	
		If aReturn[5] == 1
			Set Printer TO
			dbcommitAll()
			ourspool(wnrel)
		EndIf
	
		MS_FLUSH()
	Else                  // Relatorio grafico
		oPrn:Preview()
		oPrn:End()
	EndIf

Return( NIL )


*********************************************************************
Static Function ICabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,cTipo,lImp,nPagina)
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no cadastro da IMDEPA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA1")
	dbSeek(xfilial('SA1')+cImdepa+SM0->M0_CODFIL)
	cTitEmp   := AllTrim(SA1->A1_NOME)
	cWww      := AllTrim(SA1->A1_HPAGE)

// trata o cabecalho
	titulo  := cTitEmp

	If nDestPrint = 1    // NORMAL
	
		Li := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
	
	Else
	// aqui mostra o logotipo
		Li := 50
	
		oPrn:SayBitmap( Li, nCol+000, cBitMap, 340, 90 )
		Li+=100
		If cEmpAnt = '01'
			oPrn:Say( Li, nCol+0550, cTitEmp, oFont6, 800 )
			Li+=50
			oPrn:Say( Li, nCol+0450, AllTrim(Cabec1), oFont6, 100 )
			oPrn:Say( Li, nCol+0850, AllTrim(Cabec2), oFont6, 100 )
			Li+=50
			oPrn:Say( Li, nCol+0000, Repl("-",300), oFont, 100 )
		Else
			oPrn:Say( Li, nCol+0900, cTitEmp, oFont6, 800 )
			Li+=50
			oPrn:Say( Li, nCol+0800, AllTrim(Cabec1), oFont6, 100 )
			oPrn:Say( Li, nCol+1200, AllTrim(Cabec2), oFont6, 100 )
			Li+=50
			oPrn:Say( Li, nCol+0000, Repl("-",300), oFont, 100 )
		EndIf
	
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime os dados do pedido.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	_aArea:=GetArea()
	// Recupera os dados do Cliente
	dbSelectArea("SA1")
	dbSeek(xfilial('SA1')+SUA->UA_CLIENTE+SUA->UA_LOJA)

	If cTipo = "1"
		cVendResp := SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDEXT,"A3_NOME"))
		cEmailResp:= SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDEXT,"A3_EMAIL"))
		          
		If Empty(cVendResp)//Pedido do Call Center nao possui vendedor ligado ao cliente |Inserido por Edivaldo Goncalves em 25/06/2010
	                       //Pega o usuario que gravou o Orcamento
			cVendResp := SA1->(Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_NOME"))
		Endif
	Else
		cVendResp := SA1->(Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_NOME"))
		cEmailResp:= SA1->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDEXT,"A3_EMAIL"))
	EndIf
	RestArea(_aArea)




	If lImp
		If nDestPrint = 1   // NORMAL
			Li++
			@ Li,000 PSAY 'De:'
			@ Li,Pcol()+2  PSAY SA1->A1_NOME
			@ Li,Pcol()+05 PSAY 'Filial: '+AllTrim(SM0->M0_FILIAL)
			Li++
			@ Li,000       PSAY 'Fone: ('+SA1->A1_DDD+') '+SA1->A1_TEL
			@ Li,Pcol()+05 PSAY 'Fax: ('+SA1->A1_DDD+') '+SA1->A1_FAX
			@ Li,Pcol()+05 PSAY 'e-mail: '+ALLTRIM(SA1->A1_EMAIL)
//

/*
_aArea:=GetArea()
	// Recupera os dados do Cliente
	dbSelectArea("SA1")
	dbSeek(xfilial('SA1')+SUA->UA_CLIENTE+SUA->UA_LOJA)
	
	If cTipo = "1"
		cVendResp := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDEXT,"A3_NOME")
		cEmailResp:= Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDEXT,"A3_EMAIL")
		
		If Empty(cVendResp)//Pedido do Call Center nao possui vendedor ligado ao cliente |Inserido por Edivaldo Goncalves em 25/06/2010
	                       //Pega o usuario que gravou o Orcamento
			cVendResp := Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_NOME")
		Endif			
	Else
		cVendResp := Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_NOME")
	EndIf
RestArea(_aArea) 
*/
			@ Li,Pcol()+05 PSAY 'Vendedor : '+cVendResp //cVendResp     //A1_VENDEXT, SA3
			@ LI,PCOL()+05 PSAY "Email: "+cEmailResp  //EMAIL DO VENDEDOR
		Else
			Li+=50
			oPrn:Say( Li, nCol+0000, 'De:', oFont, 100 )
	//Li+=50
			oPrn:Say( Li, nCol+0060, SA1->A1_NOME, oFont, 300 )
			oPrn:Say( Li, nCol+1210, 'Filial: '+AllTrim(SM0->M0_FILIAL), oFont, 100 )
			Li+=50
			oPrn:Say( Li, nCol+0000, 'Fone: ('+SA1->A1_DDD+') '+SA1->A1_TEL, oFont, 100 )
	                  //1000
			oPrn:Say( Li, nCol+0500, 'Fax: ('+SA1->A1_DDD+') '+SA1->A1_FAX, oFont, 100 )
	//Li+=50          //1400
			oPrn:Say( Li, nCol+0900, 'e-mail: '+SA1->A1_EMAIL, oFont, 100 )
		EndIf
	EndIf

// posiciona nos dados do contato
	SU5->( dbseek(xFilial('SU5')+SUA->UA_CODCONT) )
	SUM->( dbseek(xFilial('SUM')+SU5->U5_FUNCAO) )

	If ! SUA->UA_PROSPEC
	
	// Recupera os dados do Cliente
		dbSelectArea("SA1")
		dbSeek(xfilial('SA1')+SUA->UA_CLIENTE+SUA->UA_LOJA)
	
		If cTipo = "1"
			cVendResp := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDEXT,"A3_NOME")
			If Empty(cVendResp)//Pedido do Call Center nao possui vendedor ligado ao cliente |Inserido por Edivaldo Goncalves em 25/06/2010
	                       //Pega o usuario que gravou o Orcamento
				cVendResp := Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_NOME")
			Endif
		Else
			cVendResp := Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_NOME")
		EndIf
	
	
	
		If lImp
			If nDestPrint = 1   // NORMAL
				Li++
				@ Li,000         PSAY 'Cliente: '+SA1->A1_COD+'-'+SA1->A1_NOME
				@ Li,Pcol()+05   PSAY 'Endereço: '+AllTrim(SA1->A1_TLOGEND)+" "+AllTrim(U_ALTEND(SA1->A1_END))+" "+AllTrim(Str(SA1->A1_NUMEND,6))+" "+AllTrim(SA1->A1_COMPEND)
				@ Li,Pcol()+05   PSAY AllTrim(SA1->A1_MUN)+' - '+SA1->A1_EST+' - CEP: '+SA1->A1_CEP
				Li++
				@ Li,000         PSAY 'Fone: ('+SA1->A1_DDD+') '+SA1->A1_TEL
				@ Li,PCol()+005  PSAY 'Fax:  ('+SA1->A1_DDD+') '+SA1->A1_FAX
				@ Li,PCol()+005  PSAY 'e-mail: '+SA1->A1_EMAIL
				Li++
				@ Li,000         PSAY 'CNPJ/CPF: '+SA1->A1_CGC
				@ Li,PCol()+005  PSAY 'Insc. Estadual: '+SA1->A1_INSCR
			Else
		//Li+=50   
		
				cVend:=cVendResp
				cVend+=' Email: '+cEmailResp
				oPrn:Say( Li, nCol+1480, 'Vendedor : '+cVend, oFont, 100 )

/*
	@ Li,Pcol()+05 PSAY 'Vendedor : '+SA1->(POSICIONE('SA3',1,XFILIAL('SA3')+SA1->A1_VENDEXT,"A3_NOME")) //cVendResp     //A1_VENDEXT, SA3
    @ LI,PCOL()+05 PSAY "Email: "+SA1->(POSICIONE('SA3',1,XFILIAL('SA3')+SA1->A1_VENDEXT,"A3_EMAIL"))  //EMAIL DO VENDEDOR        
*/  
				Li+=50
				oPrn:Say( Li, nCol+0000, 'Cliente: '+SA1->A1_COD+'-'+SA1->A1_NOME, oFont, 100 )
		//Li+=50
				oPrn:Say( Li, nCol+1200, 'Endereço: '+AllTrim(SA1->A1_TLOGEND)+" "+AllTrim(U_ALTEND(SA1->A1_END))+" "+AllTrim(Str(SA1->A1_NUMEND,6))+" "+AllTrim(SA1->A1_COMPEND), oFont, 100 )
		//Li+=50
				oPrn:Say( Li, nCol+2250, AllTrim(SA1->A1_MUN)+' - '+SA1->A1_EST+' - CEP: '+SA1->A1_CEP, oFont, 100 )
				Li+=50
				oPrn:Say( Li, nCol+0000, 'Fone: ('+SA1->A1_DDD+') '+SA1->A1_TEL, oFont, 100 )
				oPrn:Say( Li, nCol+1000, 'Fax:  ('+SA1->A1_DDD+') '+SA1->A1_FAX, oFont, 100 )
				oPrn:Say( Li, nCol+1450, 'e-mail: '+SA1->A1_EMAIL, oFont, 100 )
				Li+=50
				oPrn:Say( Li, nCol+0000, 'CNPJ/CPF: '+SA1->A1_CGC, oFont, 100 )
				oPrn:Say( Li, nCol+1000, 'Insc. Estadual: '+SA1->A1_INSCR, oFont, 100 )
		//Li+=50
		//oPrn:Say( Li, nCol+0000, 'e-mail: '+SA1->A1_EMAIL, oFont, 100 )
			EndIf
		EndIf
	Else
		If lImp
			If nDestPrint = 1   // NORMAL
		// Recupera os dados do Prospect
				Li++
				@ Li,000         PSAY 'Prospect: '+SUS->US_COD+'-'+SUS->US_NOME
				@ Li,Pcol()+05   PSAY 'Endereço: '+AllTrim(SUS->US_TLOGEND)+" "+AllTrim(SUS->US_END)+" "+AllTrim(Str(SUS->US_NUMEND,6))+" "+AllTrim(SUS->US_COMPEND)
				@ Li,Pcol()+05   PSAY AllTrim(SUS->US_MUN)+' - '+SUS->US_EST+' - CEP: '+SUS->US_CEP
				Li++
				@ Li,000         PSAY 'Fone: ('+SUS->US_DDD+') '+SUS->US_TEL
				@ Li,PCol()+05   PSAY 'Fax:  ('+SUS->US_DDD+') '+SUS->US_FAX
				@ Li,PCol()+05   PSAY 'e-mail: '+SUS->US_EMAIL
				Li++
				@ Li,000         PSAY 'CNPJ/CPF: '+SUS->US_CGC
				@ Li,PCol()+005  PSAY 'Insc. Estadual: '+SUS->US_INSCR
			Else
				Li+=50
				oPrn:Say( Li, nCol+0000, 'Prospect: '+SUS->US_COD+'-'+SUS->US_NOME, oFont, 100 )
		//Li+=50
				oPrn:Say( Li, nCol+1200, 'Endereço: '+AllTrim(SUS->US_TLOGEND)+" "+AllTrim(SUS->US_END)+" "+AllTrim(Str(SUS->US_NUMEND,6))+" "+AllTrim(SUS->US_COMPEND), oFont, 100 )
		//Li+=50
				oPrn:Say( Li, nCol+2250, AllTrim(SUS->US_MUN)+' - '+SUS->US_EST+' - CEP: '+SUS->US_CEP, oFont, 100 )
				Li+=50
				oPrn:Say( Li, nCol+0000, 'Fone: ('+SUS->US_DDD+') '+SUS->US_TEL, oFont, 100 )
				oPrn:Say( Li, nCol+1000, 'Fax:  ('+SUS->US_DDD+') '+SUS->US_FAX, oFont, 100 )
				oPrn:Say( Li, nCol+1450, 'e-mail: '+SA1->A1_EMAIL, oFont, 100 )
				Li+=50
				oPrn:Say( Li, nCol+0000, 'CNPJ/CPF: '+SUS->US_CGC, oFont, 100 )
				oPrn:Say( Li, nCol+1000, 'Insc. Estadual: '+SUS->US_INSCR, oFont, 100 )
		//Li+=50
		//oPrn:Say( Li, nCol+0000, 'e-mail: '+SUS->US_EMAIL, oFont, 100 )
			EndIf
		Endif
	EndIf
         
	If nDestPrint = 1   // NORMAL


		IF LIMP
			Li++
			@ Li,000 PSAY 'Contato: '      +SubStr(SU5->U5_CONTAT,1,25)
			@ Li,Pcol()+05 PSAY 'Cargo: '  +SubStr(SUM->UM_DESC,1,25)
			@ Li,Pcol()+05 PSAY 'e-mail: ' +SU5->U5_EMAIL
		ENDIF
		Li++
		@ Li,000 PSAY 'Assunto: '+Iif(cTipo=='1', 'Orcamento N.: ', 'Pedido N.: ')
		If cTipo = '1'
			@ Li,PCol()+02 PSAY SUA->UA_NUM
		Else
			@ Li,PCol()+02 PSAY SUA->UA_NUMSC5
		EndIf
	
		@ LI,PCOL()+05 PSAY "Pagina: "+STRZERO(NPAGINA,05,00)
	
		@ Li,PCOL()+10 PSAY 'Ordem de Compra: '
	
	
		IF LIMP
			If cTipo = '1'
				Li++
				@ Li,000 PSAY SUA->UA_OBSORC
			EndIf

	//Li++
			Li++
			@ Li,000 PSAY 'Atendendo a sua solicitacao, apresentamos nossas disponibilidades:'
		ENDIF
	//             0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	// cabecalho das colunas

		Li+= 2
		@ Li,000 PSAY 	__PrtFatLine() //@ Li,000 PSAY Repl("=",nColunas)


		Li++
		@ Li,000 PSAY 'Cod       Refer./Marca                    Un    Qtdade    Vlr. Unit  IPI       ST     Pr.Un.c/IPI e ST   Total c/IPI e ST    NCM       Prev.entrega'
	//             012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012012345678901234567890
	//             AAAAAAAAAAAAAAAAAAAA  AA  99999.99  999999.9999   99    99/99/99      9999999.99
		Li++
		@ Li,000 PSAY __PrtFatLine() //@ Li,000 PSAY Repl("-",nColunas)
		Li++
	Else
		IF LIMP
			Li+=50
			oPrn:Say( Li, nCol+0000, 'Contato: '+SubStr(SU5->U5_CONTAT,1,25), oFont, 100 )
			oPrn:Say( Li, nCol+1000, 'Cargo: '  +SubStr(SUM->UM_DESC,1,25), oFont, 100 )
	//Li+=50
			oPrn:Say( Li, nCol+1560, 'e-mail: ' +SU5->U5_EMAIL, oFont, 100 )
		ENDIF
		Li+=50
		oPrn:Say( Li, nCol+0000, 'Assunto: '+Iif(cTipo=='1', 'Orcamento N.: ', 'Pedido N.: '), oFont, 100 )
		If cTipo = '1'
			oPrn:Say( Li, nCol+500, SUA->UA_NUM, oFont, 100 )
		Else
			oPrn:Say( Li, nCol+500, SUA->UA_NUMSC5, oFont, 100 )
		EndIf

		oPrn:Say( Li, nCol+1000, 'Página: '+STRZERO(NPAGINA,05,00), oFont, 100 )


	
		oPrn:Say( Li, nCol+1500, 'Ordem de Compra: ', oFont, 100 )
		If cTipo = '1'
			Li+=50
			oPrn:Say( Li, nCol+0000, 'Obs.: '+SUA->UA_OBSORC, oFont, 100 )
		EndIf
		IF LIMP
			Li+=050
			oPrn:Say( Li, nCol+0000, 'Atendendo a sua solicitacao, apresentamos nossas disponibilidades:', oFont, 100 )
		ENDIF
	//             0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	// cabecalho das colunas
	//Julio Jacovenko em 24/04/2012
	//Li+=100
		Li+=050
	//oPrn:Say( Li, nCol+0000, Repl("-",200), oFont, 100 )    // PROVISORIO
		oPrn:Say( Li, nCol+0000, Repl("-",300), oFont, 100 )    // PROVISORIO
		Li+=50
	//oPrn:Say( Li, nCol+0000, 'Descricao', oFont, 100 )
		oPrn:Say( Li, nCol+0000, 'Cod', oFont, 100 )
		oPrn:Say( Li, nCol+0100, 'Refer. / Marca', oFont, 100 )
		oPrn:Say( Li, nCol+0700, 'Un', oFont, 100 )
		oPrn:Say( Li, nCol+0900, 'Qtde', oFont, 100 )
		oPrn:Say( Li, nCol+1200, 'Vlr. Unit', oFont, 100 )
		oPrn:Say( Li, nCol+1450, 'IPI', oFont, 100 )
		oPrn:Say( Li, nCol+1600, 'ST', oFont, 100 )
		oPrn:Say( Li, nCol+1700, 'Pr.Un.c/IPI e ST', oFont, 100 )
		oPrn:Say( Li, nCol+2000, 'Total c/IPI e ST', oFont, 100 )
		oPrn:Say( Li, nCol+2300, 'NCM', oFont, 100 )
		oPrn:Say( Li, nCol+2450, 'Prev.Entrega', oFont, 100 )
	//oPrn:Say( Li, nCol+1880, 'Total c/IPI', oFont, 100 )
	
	//             0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	//             AAAAAAAAAAAAAAAAAAAA  AA  99999.99  999999.9999   99    99/99/99      9999999.99
		Li+=50
		oPrn:Say( Li, nCol+0000, Repl("-",300), oFont, 100 )    // PROVISORIO
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
Static Function GeraLFax(cTipo)//Rotina para gerar o arquivo de configuracao do LFAX
*********************************************************************
	Local cLFaxPath   := GetMV('MV_LFAX')
	Local hFile       := FCreate(cLFaxPath+'\lfaxinfo.txt')
	Local cAssunto    := Iif(cTipo=='1', 'Orcamento ', 'Pedido de Venda')
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
Static Function xPergunta( cTipo )//Define o destino da impressao do orcamento ou pedido
*********************************************************************
	Local oDlg1
	Local cNum

	If cTipo = '1'
		cNum := SUA->UA_NUM
	Else
		cNum := SUA->UA_NUMSC5
	EndIf

	DEFINE MSDIALOG oDlg1 FROM 00,000 TO 140,360 TITLE OemToAnsi("Selecione o Destino") PIXEL
//	@ 000,000 to 140,360 Dialog oDlg1 Title "Selecione o Destino"

	@ 008,013 Say 'Numero do '+Iif(cTipo=='1', 'Orcamento:', 'Pedido:')+' '+cNum  OF oDlg1 PIXEL //Size 080,10

	@ 020,004 To 055,85 OF oDlg1 PIXEL
	@ 025,013 Say 'Para Impressao e/ou'  OF oDlg1 PIXEL//Size 080,10
	@ 035,013 Say '   envio via e-mail'  OF oDlg1 PIXEL//Size 080,10
	@ 048,030 BmpButton Type 6 Action (nDestPrint:=1, oDlg1:End())

	@ 020,090 To 055,170 OF oDlg1 PIXEL
	@ 025,105 Say 'Para Impressao e/ou'  OF oDlg1 PIXEL//Size 080,10
	@ 035,105 Say '    envio via lFax'   OF oDlg1 PIXEL//Size 080,10
	@ 048,120 BmpButton Type 10 Action (nDestPrint:=2, oDlg1:End())

	@ 060,075 BmpButton Type 2 Action (nDestPrint:=0, oDlg1:End())

//	Activate Dialog oDlg1 Centered
	ACTIVATE MSDIALOG oDlg1 CENTER

Return( nDestPrint )





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMDR060   ºAutor  ³JACOVENKO e EDIVALDO ³ Data ³  06/14/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao generica para calculo de impostos                    º±±
±±º          ³Parametros:                                                 º±±
±±º          ³cCliente - codigo do cliente                                º±±
±±º          ³cLoja - loja do cliente                                     º±±
±±º          ³cTipo - tipo de cliente                                     º±±
±±º          ³cProduto - codigo do produto                                º±±
±±º          ³cTes - tes usado na venda                                   º±±
±±º          ³nQtd - quantidade da venda (linha)                          º±±
±±º          ³nPrc - preco unitario                                       º±±
±±º          ³nValor - valor da mercadoria (unitario, já com descontos,   º±±
±±º          ³etc...)                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTERNO GENERICO IMDEPA                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//========================================== CALCULA IMPOSTOS ===========================================//
STATIC Function XfImpostos(cCliente,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor,NDespesa,NITEM)
	Local aImpostos := {}
	Local aImp := {0,0,0}

///AS LINHA ABAIXA NA PODEM SER MODIFICADAS
///isto he necessario para podermos usar as funcoes de
///calculo dos impostos
///////////////////////////////////////////////////////

///INCIALIZO A FUNCAO FISCAL

//MaFisSave()
//MaFisEnd()

	MaFisIni(cCliente,;               // 1-Codigo Cliente/Fornecedor
	cLoja,;                         // 2-Loja do Cliente/Fornecedor
	"C",;                         // 3-C:Cliente , F:Fornecedor
	"N",;                         // 4-Tipo da NF
	cTipo,;                         // 5-Tipo do Cliente/Fornecedor
	MaFisRelImp("TMK271",{"SUA","SUB"}),;   // 6-Relacao de Impostos que suportados no arquivo
	,;                               // 7-Tipo de complemento
	,;                               // 8-Permite Incluir Impostos no Rodape .T./.F.
	"SB1",;               // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
	"TMK271")            // 10-Nome da rotina que esta utilizando a funcao

	

//////////////////////////////////////////////////////////////////////////////////////////   
//MaFisIni(SA1->A1_COD, SA1->A1_LOJA, "C", "S", CTIPOCLI,,, .F., "SB1")
//////////////////////////////////////////////////////////////////////////////////////////
                                                        
   //desconto suframa
   
   

	MaFisAdd(cProduto, cTes, nQtd, nPrc, 0, "", "",, 0, NDESPESA, 0, 0, nValor , 0, 0, 0) //,SB1->(RecNo()))
//MaFisAdd(SB1->B1_COD, SF4->F4_CODIGO, nQuant,nVlUnit, 0, "", "",, 0, 0, 0, 0, nVlrTotItem, 0, SB1->(RecNo()))
//DEIXAR COMENTADO PARA O FUTURO
/*
aadd(aImpostos,"IT_VALICM")
aadd(aImpostos,"IT_ALIQICM") //               03    //Aliquota de ICMS
aadd(aImpostos,"IT_ALIQIPI") //               05    //Aliquota de IPI
aadd(aImpostos,"IT_ALIQISS") //               24,01 //Aliquota de ISS do item
aadd(aImpostos,"IT_ALIQIRR") //       25,03 //Aliquota de Calculo do IR do Item
aadd(aImpostos,"IT_ALIQINS") //       26,03 //Aliquota de Calculo do INSS
aadd(aImpostos,"IT_ALIQIV1") //       29,01 //Aliquota de Impostos Variaveis 1
aadd(aImpostos,"IT_ALIQIV2") //       29,02 //Aliquota de Impostos Variaveis 2
aadd(aImpostos,"IT_ALIQIV3") //       29,03 //Aliquota de Impostos Variaveis 3
aadd(aImpostos,"IT_ALIQIV4") //       29,04 //Aliquota de Impostos Variaveis 4
aadd(aImpostos,"IT_ALIQIV5") //       29,05 //Aliquota de Impostos Variaveis 5
aadd(aImpostos,"IT_ALIQIV6") //       29,06 //Aliquota de Impostos Variaveis 6
aadd(aImpostos,"IT_ALIQIV7") //       29,07 //Aliquota de Impostos Variaveis 7
aadd(aImpostos,"IT_ALIQIV8") //       29,08 //Aliquota de Impostos Variaveis 8
aadd(aImpostos,"IT_ALIQIV9") //       29,09 //Aliquota de Impostos Variaveis 9
aadd(aImpostos,"IT_ALIQCOF") //       41    //Aliquota de calculo do COFINS
aadd(aImpostos,"IT_ALIQCSL") //       44    //Aliquota de calculo do CSLL
aadd(aImpostos,"IT_ALIQPIS") //       47    //Aliquota de calculo do PIS
aadd(aImpostos,"IT_ALIQPS2") //       55    //Aliquota de calculo do PIS 2
aadd(aImpostos,"IT_ALIQCF2") //       58    //Aliquota de calculo do COFINS 2
aadd(aImpostos,"IT_ALIQAFRMM") //     67 //Aliquota de calculo do AFRMM ( Item )
aadd(aImpostos,"IT_ALIQSES") //       74,02 //Aliquota de calculo do SEST          
*/            


//aadd(aImpostos,"IT_VALSOL") ///VALOR DO CALCULO ST                         

//aadd(aImpostos,"NF_VALSOL")          






	_nAliqIcm       := MaFisRet(NITEM,"IT_ALIQICM")
	_nValIcm        := MaFisRet(NITEM,"IT_VALICM" )
	_nBaseIcm       := MaFisRet(NITEM,"IT_BASEICM")
	_nValIpi        := MaFisRet(NITEM,"IT_VALIPI" )
	_nBaseIpi       := MaFisRet(NITEM,"IT_BASEICM")
	_nValMerc       := MaFisRet(NITEM,"IT_VALMERC")
	_nValSol        := MaFisRet(NITEM,"IT_VALSOL" )
	_nValSuf        := MaFisRet(NITEM,"IT_DESCZF")
                                                          

	nTotSol := _nValSol
          
          //ALERT(MAFISRET(,"NF_DESCZF"))
          
//http://ventura.pro.br/analista/?tag=mafisret


    //usando este
	//aadd(aImpostos,"LF_ICMSRET")                   
	
	
	
	aImp[1] := NoRound(MaFisRet(NITEM,"IT_VALSOL"),4) //NoRound(MaFisRet(NITEM,"LF_ICMSRET"),4) //MaFisRet(NITEM,"LF_ICMSRET") //MaFisRet(NITEM,"LF_ICMSRET")  //MaFisRet(1,"IT_VALSOL")
	aImp[2] := NoRound(MaFisRet(NITEM,"IT_DESCZF"),4)



//aImp[1] := MaFisRet(1,"LF_ICMSRET") //MaFisRet(1,"LF_ICMSRET") //MaFisRet(1,"IT_VALSOL")
//AS FUNCOES ABAIXA DEVE PODEM SER COMENTADAS

//MaFisSave()
//MaFisEnd()

Return aImp
                                         

/*
MaFisIni(cCliente,;               // 1-Codigo Cliente/Fornecedor
cLoja,;                         // 2-Loja do Cliente/Fornecedor
"C",;                         // 3-C:Cliente , F:Fornecedor
"N",;                         // 4-Tipo da NF
cTipo,;                         // 5-Tipo do Cliente/Fornecedor
MaFisRelImp("MTR700",{"SC5","SC6"}),;   // 6-Relacao de Impostos que suportados no arquivo
,;                               // 7-Tipo de complemento
,;                               // 8-Permite Incluir Impostos no Rodape .T./.F.
"SB1",;               // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
"MTR700")            // 10-Nome da rotina que esta utilizando a funcao
*/



//========================================== CALCULA IMPOSTOS ===========================================//
STATIC Function yfImpostos(cCliente,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor)
	Local aImpostos := {}
	Local aImp := {0,0,0}

///AS LINHA ABAIXA NA PODEM SER MODIFICADAS
///isto he necessario para podermos usar as funcoes de
///calculo dos impostos
///////////////////////////////////////////////////////
	MaFisIni(cCliente,;               // 1-Codigo Cliente/Fornecedor
	cLoja,;                         // 2-Loja do Cliente/Fornecedor
	"C",;                         // 3-C:Cliente , F:Fornecedor
	"N",;                         // 4-Tipo da NF
	cTipo,;                         // 5-Tipo do Cliente/Fornecedor
	MaFisRelImp("TMK271",{"SUA","SUB"}),;   // 6-Relacao de Impostos que suportados no arquivo
	,;                               // 7-Tipo de complemento
	,;                               // 8-Permite Incluir Impostos no Rodape .T./.F.
	"SB1",;               // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
	"TMK271")            // 10-Nome da rotina que esta utilizando a funcao
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

	MaFisAdd(cProduto, cTes, nQtd, nPrc, 0, "", "",, 0, 0, 0, 0, nValor, 0)


//DEIXAR COMENTADO PARA O FUTURO
/*
aadd(aImpostos,"IT_VALICM")
aadd(aImpostos,"IT_ALIQICM") //               03    //Aliquota de ICMS
aadd(aImpostos,"IT_ALIQIPI") //               05    //Aliquota de IPI
aadd(aImpostos,"IT_ALIQISS") //               24,01 //Aliquota de ISS do item
aadd(aImpostos,"IT_ALIQIRR") //       25,03 //Aliquota de Calculo do IR do Item
aadd(aImpostos,"IT_ALIQINS") //       26,03 //Aliquota de Calculo do INSS
aadd(aImpostos,"IT_ALIQIV1") //       29,01 //Aliquota de Impostos Variaveis 1
aadd(aImpostos,"IT_ALIQIV2") //       29,02 //Aliquota de Impostos Variaveis 2
aadd(aImpostos,"IT_ALIQIV3") //       29,03 //Aliquota de Impostos Variaveis 3
aadd(aImpostos,"IT_ALIQIV4") //       29,04 //Aliquota de Impostos Variaveis 4
aadd(aImpostos,"IT_ALIQIV5") //       29,05 //Aliquota de Impostos Variaveis 5
aadd(aImpostos,"IT_ALIQIV6") //       29,06 //Aliquota de Impostos Variaveis 6
aadd(aImpostos,"IT_ALIQIV7") //       29,07 //Aliquota de Impostos Variaveis 7
aadd(aImpostos,"IT_ALIQIV8") //       29,08 //Aliquota de Impostos Variaveis 8
aadd(aImpostos,"IT_ALIQIV9") //       29,09 //Aliquota de Impostos Variaveis 9
aadd(aImpostos,"IT_ALIQCOF") //       41    //Aliquota de calculo do COFINS
aadd(aImpostos,"IT_ALIQCSL") //       44    //Aliquota de calculo do CSLL
aadd(aImpostos,"IT_ALIQPIS") //       47    //Aliquota de calculo do PIS
aadd(aImpostos,"IT_ALIQPS2") //       55    //Aliquota de calculo do PIS 2
aadd(aImpostos,"IT_ALIQCF2") //       58    //Aliquota de calculo do COFINS 2
aadd(aImpostos,"IT_ALIQAFRMM") //     67 //Aliquota de calculo do AFRMM ( Item )
aadd(aImpostos,"IT_ALIQSES") //       74,02 //Aliquota de calculo do SEST          
*/            


//aadd(aImpostos,"IT_VALSOL") ///VALOR DO CALCULO ST                         

	aadd(aImpostos,"NF_VALSOL")


//aadd(aImpostos,"LF_ICMSRET")          

	aImp[1] := MaFisRet(1,"NF_VALSOL") //MaFisRet(1,"LF_ICMSRET") //MaFisRet(1,"IT_VALSOL")

//AS FUNCOES ABAIXA NAO PODEM SER COMENTADAS
	MaFisSave()
	MaFisEnd()

Return aImp


USER FUNCTION FUBTES()
	LOCAL    aImposto:={}
	LOCAL    NVST:=0


	cCLIENTE:=M->UA_CLIENTE
	cLOJCLI :=M->UA_LOJA
	cTIPCLI :=SA1->A1_TIPO  //'R'
	cPRODUTO:=ACOLS[N,01]
	cTES    :=ACOLS[N,11]
	nQTDVEN :=ACOLS[N,06]
	nPRCVEN :=ACOLS[N,07]     //ub_vrcacr
	nVALOR  :=ACOLS[N,27]     //UB_vlritem

	aImposto := U_YfImpostos(cCliente,cLojCli,cTipCli,cPRODUTO,cTES,nQTDVEN,nPRCVEN,nVALOR)
	
	nvST    := aImposto[1]

	ALERT(NVST)



RETURN NVST


Static Function ICabec1()

	Local cabec1_1 := 'Cod       Refer./Marca                    Un    Qtdade    Vlr. Unit  IPI       ST     Pr.Un.c/IPI e ST   Total c/IPI e ST    NCM       Prev.entrega'
	Local cBitMap  := 'LGRL'+cEmpAnt+'.BMP'      // carrega o logo da empresa

	If nDestPrint = 1    // NORMAL
	
		Li := Cabec(titulo,cabec1_1,"",nomeprog,tamanho)
	
	Else
	// aqui mostra o logotipo
		Li := 50
	
		oPrn:SayBitmap( Li, nCol+000, cBitMap, 340, 90 )
		Li+=100
		If cEmpAnt = '01'
			oPrn:Say( Li, nCol+0550, cTitEmp, oFont6, 800 )
		Else
			oPrn:Say( Li, nCol+0900, cTitEmp, oFont6, 800 )
		EndIf

		Li+=050
		oPrn:Say( Li, nCol+0000, Repl("-",300), oFont, 100 )    // PROVISORIO
		Li+=50
		oPrn:Say( Li, nCol+0000, 'Cod', oFont, 100 )
		oPrn:Say( Li, nCol+0100, 'Refer. / Marca', oFont, 100 )
		oPrn:Say( Li, nCol+0750, 'Un', oFont, 100 )
		oPrn:Say( Li, nCol+0950, 'Qtde', oFont, 100 )
		oPrn:Say( Li, nCol+1200, 'Vlr. Unit', oFont, 100 )
		oPrn:Say( Li, nCol+1450, 'IPI', oFont, 100 )
		oPrn:Say( Li, nCol+1600, 'ST', oFont, 100 )
		oPrn:Say( Li, nCol+1700, 'Pr.Un.c/IPI e ST', oFont, 100 )
		oPrn:Say( Li, nCol+2000, 'Total c/IPI e ST', oFont, 100 )
		oPrn:Say( Li, nCol+2300, 'NCM', oFont, 100 )
		oPrn:Say( Li, nCol+2450, 'Prev.Entrega', oFont, 100 )
		Li+=50
		oPrn:Say( Li, nCol+0000, Repl("-",300), oFont, 100 )    // PROVISORIO
		Li+=50
	
	EndIf

Return()


/*
  

Galera, resolvi isso com a dica dos camaradas AndrÃ© Esteves Machado e do Luiz Alberto Alvez, lÃ¡ no chat do www.3lsystems.com.br

Usei o cÃ³digo abaixo para resolver:

    dbSelectArea("SC6")
    dbSetOrder(01)
    dbSeek(xFilial("SC6")+SC5->C5_NUM)
        
    nLin    :=0780
    nTotSol := nTotIcm := nBasIcm := nSubTot := nTotIPI := nVlrIPI := nICMS := nTotICMS := nTotalGeral := nPesoItem := nTotalItem := nTotalNota := 0
    While !Eof() .And. C6_NUM ==SC5->C5_NUM
          // Calculo ST e Outros Impostos                      
          MaFisIni(SC5->C5_CLIENTE,SC5->C5_LOJACLI,"C","N",SC5->C5_TIPOCLI,MaFisRelImp("MTR700",{"SC5","SC6"}),,,"SB1","MTR700")
          MaFisAdd(        SC6->C6_PRODUTO,;
          SC6->C6_TES,;
          SC6->C6_QTDVEN,;
          SC6->C6_PRUNIT,;
          SC6->C6_VALDESC,;
          "",;
          "",;
          0,;
          0,;
          0,;
          0,;
          0,;
          (SC6->C6_QTDVEN*SC6->C6_PRUNIT),;
          0,;
          0,;
          0)
          _nAliqIcm        :=        MaFisRet(1,"IT_ALIQICM")
          _nValIcm                     := MaFisRet(1,"IT_VALICM" )
          _nBaseIcm       := MaFisRet(1,"IT_BASEICM")
          _nValIpi                      := MaFisRet(1,"IT_VALIPI" )
          _nBaseIpi        := MaFisRet(1,"IT_BASEICM")
          _nValMerc       := MaFisRet(1,"IT_VALMERC")
          _nValSol                      := MaFisRet(1,"IT_VALSOL" )

          nTotSol += _nValSol

          If !Empty(_nValSol)
                       _nValSol := Round(_nValSol/SC6->C6_QTDVEN,2)
          Endif
                         
          MaFisEnd()
        
        
        
          DBSKIP()
     ENDDO            



*/
