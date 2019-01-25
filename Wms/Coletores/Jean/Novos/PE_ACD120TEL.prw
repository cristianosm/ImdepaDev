#INCLUDE "protheus.ch"
#INCLUDE "apvt100.ch"
/*
Jean Rehermann - Solutio IT - 28/03/2017
ACD120TEL - Ponto de entrada na rotina de conferência do coletor
Utilizada neste contexto para trazer a quantidade da caixa (volume) conforme etiqueta gerada.
*/
User Function ACD120TEL

	Local   cVolume   := Space(TamSx3("CB0_VOLUME")[1])
	Local   lUsa01    := UsaCB0("01")
	Private cEtiqProd := Space(48)
	Private cNota     := Space(TamSx3("F1_DOC")[1])
	Private cSerie    := Space(TamSx3("F1_SERIE")[1])
	Private cFornec   := Space(TamSx3("F1_FORNECE")[1])
	Private cLoja     := Space(TamSx3("F1_LOJA")[1])
	Private nQtdEtiq  := 0
	Private lLocktmp  := .F.
	Private lForcaQtd :=GetMV("MV_CBFCQTD",,"2") =="1"

	If lUsa01
		@ 0,0 VTSAY 'Volume ' VTGET cVolume pict '@!' Valid (!Empty(cVolume) .and. AV120VldVol(cVolume)) When ((Empty(cVolume) .or. VtLastkey()==5) .and. ! lLocktmp)
	EndIf

	@ 1,00 VTSAY 'Nota ' VTGet cNota   pict '@!' Valid VldNota(cNota) F3 'CBW'								When !lUsa01 .and.(Empty(cNota).or. VtLastkey()==5)  .and. ! lLocktmp
	@ 1,14 VTSAY '-'     VTGet cSerie  pict '@!' Valid Empty(cSerie) .or. VldNota(cNota+cSerie)				When !lUsa01 .and.((Empty(cSerie) .and. lBranco) .or. VtLastkey()==5)  .and. ! lLocktmp
	@ 2,00 VTSAY 'Forn ' VTGet cFornec pict '@!' Valid VldNota(cNota+cSerie+cFornec) F3 'FOR'				When !lUsa01 .and.(Empty(cFornec) .or. VtLastkey()==5)  .and. ! lLocktmp
	@ 2,14 VTSAY '-'     VTGet cLoja   pict '@!' Valid (lBranco := .f.,VldNota(cNota+cSerie+cFornec+cLoja))	When !lUsa01 .and.(Empty(cLoja) .or. VtLastkey()==5 )  .and. ! lLocktmp
	@ 3,00 VTSAY "Quantidade"
	@ 4,00 VTGet nQtdEtiq pict CBPictQtde() Valid nQtdEtiq > 0 when (lForcaQtd .or. VTLastkey() == 5)
	@ 5,00 VTSAY "Produto"
	@ 6,00 vtGet cEtiqProd pict '@!' Valid (VTLastkey() == 5 .or. AV120VldPrd(cEtiqProd))  F3 "CBZ"
	VTRead

Return

// Valida o volume e obtém as informações da etiqueta
Static Function AV120VldVol( cVolume )

	Local aVolume := {}
	
	aVolume := CBRetEti( cVolume, "01" ) //Volume
	
	If Empty( aVolume )
		VTBeep(2)
		VTAlert("Etiqueta invalida.","Aviso",.T.,2000)
		VTKeyBoard(chr(20)) //Limpa o get
		Return .F.
	EndIf

	cNota     := aVolume[2]
	cSerie    := aVolume[3]
	cFornec   := aVolume[4]
	cLoja     := aVolume[5]
	cEtiqProd := aVolume[6]
	nQtdEtiq  := aVolume[7]

	dbSelectArea("SF1")
	SF1->(dbSetOrder(1))
	
	If !SF1->( dbSeek( xFilial("SF1") + cNota + cSerie + cFornec + cLoja ) )
		VTBeep(2)
		VTAlert("Nota fiscal nao cadastrada","Aviso",.T.,2000)
		VTKeyBoard(chr(20))
		Return .F.
	EndIf
	
	If SF1->F1_STATCON == "1" //Conferida
		VTBeep(2)
		VTAlert("Esta nota ja foi conferida.","Aviso",.T.,2000)
		VTKeyBoard(chr(20))
		Return .F.
	EndIf

	TravaTMP()
	
	VTGetRefresh("cNota")
	VTGetRefresh("cSerie")
	VTGetRefresh("cFornec")
	VTGetRefresh("cLoja")
	VTGetRefresh("cEtiqProd")
	VTGetRefresh("nQtdEtiq")

Return .T.

//-- Ponto de Entrada : Na leitura do codigo da etiqueta
User Function CBRETETI()

	Local _cID 	  := Iif( Len( PARAMIXB ) >=1, PARAMIXB[1], "" )
	Local _cTipId := Iif( Len( PARAMIXB ) >=2, PARAMIXB[2], "" )
	Local _myRet  := {}
	
	IF _cTipId == "01"
		// Por enquanto somente para os tipo 01
		_myRet := { CB0->CB0_VOLUME,;    // 1-Etiqueta (volume)
					CB0->CB0_NFENT,;     // 2-nota fiscal de entrada
					CB0->CB0_SERIEE,;    // 3-serie da NF de entrada
					CB0->CB0_FORNEC,;    // 4-codigo do fornecedor
					CB0->CB0_LOJAFO,;    // 5-Loja do fornecedor
				    CB0->CB0_CODPRO,;    // 6-codigo do produto
				    CB0->CB0_QTDE;       // 7-quantidade
					}
	Endif

Return( _myRet )

// Conteúdo para o campo SF1->F1_QTDCONF
Static Function RetQtdConf()

	Local cChave   := SF1->( xFilial("SF1") + cNota + cSerie + cFornec + cLoja )
	Local nQtdConf := 0
	
	TMP->( DbSeek( cChave ) )
	
	While ! TMP->(Eof()) .and. TMP->CHAVE == cChave
		If ! Tmp->( RLock() )
			nQtdConf++
		Else
			Tmp->( DbDelete() )
			Tmp->( DbUnlock() )
		EndIf
		Tmp->(DbSkip())
	End

Return nQtdConf

Static function TravaTmp(lTrava)

	Local cChave   := SF1->( xFilial("SF1") + cNota + cSerie + cFornec + cLoja )
	DEFAULT lTrava := .T.

	If lTrava

		RecLock("SF1",.F.)
			SF1->F1_STATCON := "3" //-- Em conferencia
			SF1->F1_QTDCONF := RetQtdConf() + 1
		MsUnlock()

		RecLock( "TMP", .T. )
			TMP->NUMRF := VTNUMRF()
			TMP->CHAVE := cChave
		TMP->( MsUnlock() )

		RecLock("TMP",.F.)

		lLocktmp := .T.
	Else

		If lLocktmp
			
			TMP->( DbDelete() )
			TMP->( MsUnlock() )
	
			lLocktmp := .F.
	
			RecLock("SF1",.F.)
				SF1->F1_QTDCONF := RetQtdConf()
			MsUnlock()
		EndIf
	EndIf

Return

Static Function AV120VldPrd()

	Local aProd
	Local cProduto   := Space(TamSx3("B1_COD")[1])
	Local cProdPai	 := Space(TamSx3("B1_COD")[1])
	Local nQE        := 0 //quantidade por embalagem
	Local nSaldo     := 0
	Local lCodInt    := .T.
	Local nCopias    := 0
	Local nSaldoDist := 0
	Local cTipId     := ""
	Local cLote      := Space(TamSx3("D1_LOTECTL")[1])
	Local dValid     := cTod('')
	Local aTela
	Local lPesqSA5   := SuperGetMv("MV_CBSA5",.F.,.F.)

	//--- Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
	Local nToler1UM  := QtdComp(SuperGetMV("MV_NTOL1UM",.F.,0))
	Local lForcaImp  := .F.
	Local nOpcao     := 0
	Local cEtiqRet   := ""
	Local lAC120VLD  := .T.
	Local lWmsNew	 := SuperGetMv("MV_WMSNEW",.F.,.F.)
	
	Private nQtdEtiq2 := nQtdEtiq
	
	If Empty(cEtiqProd)
		Return .f.
	EndIf
	
	If ! CBLoad128(@cEtiqProd)
		VTkeyBoard(chr(20))
		Return .f.
	EndIf
	
	If ExistBlock("AC120VLD") 
		lAC120VLD := ExecBlock("AC120VLD",.F.,.F.,{cEtiqProd})  
		lAC120VLD := If(ValType(lAC120VLD)=="L",lAC120VLD,.T.)
	EndIf
	
	// Ponto de entrada para criar produto no CB0
	If UsaCB0("01") .and. ExistBlock("AV120CB0")
		cEtiqRet  := ExecBlock("AV120CB0",.F.,.F.,{cEtiqProd})
		cEtiqProd := If(ValType(cEtiqRet)=="C",cEtiqRet,cEtiqProd)
	EndIf
	
	If lAC120VLD
		Begin sequence
			dbSelectArea("SA5")
			SA5->(dbSetorder(8)) //A5_CODBAR
			If lPesqSA5 .and. SA5->(MsSeek(xFilial("SA5")+cFornec+cLoja+Padr(AllTrim(cEtiqProd),Tamsx3("B1_COD")[1])))
				cProduto := SA5->A5_PRODUTO
				nQE      := CBQtdEmb(cProduto)
				If Empty(nQE)
					Break
				EndIf
				nQtdEtiq2 := nQtdEtiq2*nQE
				lCodInt := .F.
			Else
				cTipId := CBRetTipo(cEtiqProd)
				If UsaCB0("01") .And. cTipId=="01"
					aProd := CBRetEti(cEtiqProd,"01") //Produto
					If Len(aProd) == 0
						VTBeep(2)
						VTAlert("Etiqueta invalida.","Aviso",.T.,2000)
						Break
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se etiqueta ja tem dados da nota  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cProduto := aProd[1]
					If PesqCBE(CB0->CB0_CODETI)
						VTBeep(2)
						VTAlert("Etiqueta ja lida","Aviso",.T.,2000)
						Break
					EndIf
					If ! CBProdUnit(cProduto)
						nQE := CBQtdEmb(cProduto)
						If Empty(nQE)
							Break
						EndIf
						If nQE # aProd[2]
							VTBeep(2)
							VTAlert("Quantidade nao confere!","Aviso",.T.,2000)
							Break
						EndIf
					EndIf
					// Valida se a etiqueta lida pertence a NF conferida.
					If !(cNota == CB0->CB0_NFENT .And. cSerie == CB0->CB0_SERIEE .And. cFornec == CB0->CB0_FORNEC .And. cLoja == CB0->CB0_LOJAFO)
						VTBeep(2)
						VTAlert("Etiqueta não pertence a nota.","Aviso",.T.,2000)
						Break
					EndIf
					nQtdEtiq2 := aProd[2]
					cLote     := aProd[16]
					dValid    := aProd[18]
					lCodInt   := .t.
				ElseIf cTipId $ "EAN8OU13-EAN14-EAN128"  //-- nao tem codigo interno e tera'que ser impresso a etiqueta de identificacao
					aProd := CBRetEtiEan(cEtiqProd)
					If Empty(aProd) .or. Empty(aProd[2])
						VTBeep(2)
						VTAlert("Etiqueta invalida.","Aviso",.T.,2000)
						Break
					EndIf
					cProduto := aProd[1]
					nQE := aProd[2]
					If ! CBProdUnit(cProduto)
						nQE := CBQtdEmb(cProduto)
						If Empty(nQE)
							Break
						EndIf
					EndIf
					nQtdEtiq2 := nQtdEtiq2 * nQE
					lCodInt   := .F.
					cLote     := aProd[3]
					dValid    := aProd[4]
				Else
					VTBeep(2)
					VTAlert("Etiqueta invalida","Aviso",.T.,2000)
					Break
				EndIf
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o produto pertence a nota³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lWmsNew
				cProdPai := MtWMSGtPai(cProduto)
				
				dbSelectArea("SD1")
				SD1->(dbSetOrder(1))
				If ! SD1->(dbSeek(xFilial("SD1")+cNota+cSerie+cFornec+cLoja+cProdPai))
					If  ! ExistBlock("AV120QTD") //verificar somente a existencia
						VTBeep(2)
						VTAlert("Produto nao pertence a nota.","Aviso",.T.,2000)
						Break
					EndIf
				EndIf
			Else
				SD1->( dbSetOrder(1) )
				If ! SD1->( dbSeek( xFilial("SD1") + cNota + cSerie + cFornec + cLoja + cProduto ) )
					If  ! ExistBlock("AV120QTD") //verificar somente a existencia
						VTBeep(2)
						VTAlert("Produto nao pertence a nota.","Aviso",.T.,2000)
						Break
					EndIf
				EndIf
			Endif
			
			SB1->( DbSetOrder(1) )
			SB1->( MsSeek( xFilial('SB1') + cProduto ) )
			If Empty(cLote) .or. Empty( dValid )
				dValid := dDatabase + SB1->B1_PRVALID
				If !CBRastro(cProduto,@cLote,,@dValid,.t.)
					VTKeyboard(chr(20))
					Break
				EndIf
			EndIf
		  
			// Ponto de Entrada para validar a etiqueta lida.
			If ExistBlock("A120PROD")
				lProd := Execblock("A120PROD",.F.,.F.,{cEtiqProd})  
				If ValType(lProd) == "L" .And. !lProd
					Break
				EndIf
			EndIf
		
			// Retorna o saldo que pode ser conferido
			nSaldo := QtdAConf(cProduto)
			
			If nSaldo == 0
				If !ExistBlock("AV120QTD")  //-- verificar somente a existencia
					VTBeep(2)
					VTAlert("Produto excede a nota.","Aviso",.T.,2000)
					Break
				EndIf
			EndIf

			// Distribui a quantidade no SD1
			If lCodInt //-- Codigo interno
				If nQtdEtiq2 > nSaldo
					If	ExistBlock("AV120QTD")
						ExecBlock("AV120QTD",.F.,.F.,{cProduto,nQtdEtiq2,1,cEtiqProd})
					Else
						VTBeep(2)
						VTAlert("Produto excede a nota.","Aviso",.T.,2000)
						Break
					EndIf
				Else
					GravaCBE(CB0->CB0_CODETI,cProduto,nQtdEtiq2,cLote,dValid)
					DistQtdConf(cProduto,nQtdEtiq2)
				EndIf
			Else //-- Cod fornecedor
				dbSelectArea("SB1")
				SB1->( dbSetOrder(1) )
				SB1->( MsSeek( xFilial("SB1") + cProduto ) )
		
				If nQtdEtiq2 <= nSaldo .OR. ABS( QtdComp( nQtdEtiq2 - nSaldo ) ) <= nToler1UM
					nSaldoDist := nQtdEtiq2
					nCopias    := 0 // Int( nQtdEtiq2 / nQE )
				ElseIf nQtdEtiq2 > nSaldo
					nSaldoDist := nSaldo
					nCopias    := 0 // Int(nSaldo/nQE)
					If	ExistBlock("AV120QTD")
						ExecBlock("AV120QTD",.F.,.F.,{cProduto,nQE,nQtdEtiq2-nCopias,nil})
					Else
						VTBeep(2)
						VTAlert("Produto excede a nota.","Aviso",.T.,2000)
						Break
					EndIf
				EndIf
				
				If	ExistBlock("CBVLDIRE")
					lForcaImp := ExecBlock("CBVLDIRE",.F.,.F.,{cEtiqProd,cNota,cSerie,cFornec,cLoja,cLote,dvalid,nOpcao,nQtdEtiq2})
					lForcaImp := If(ValType(lForcaImp)=="L",lForcaImp,.F.)
				EndIf
				
				If Usacb0("01") .or. lForcaImp  //-- origem do codigo eh pelo fornecedor
					If nCopias > 0 .and. ExistBlock('IMG01')
						aTela:= VtSave()
						VtClear()
						CB5SetImp(CBRLocImp("MV_IACD03"),.T.)
						VtAlert("Imprimindo "+Str(nCopias,3)+" etiqueta(s) no local :"+CB5->CB5_CODIGO,"Impressao",.t.,3000,3)
		
						ExecBlock("IMG01",,,{nQE,cCodOpe,,nCopias,cNota,cSerie,cFornec,cLoja,,,,cLote,'',dValid})
		
						MSCBClosePrinter()
						VTRestore(,,,,aTela)
					EndIf
				Else
					GravaCBE( Space(10), cProduto, nQtdEtiq2, cLote, dValid )
				EndIf
				
				DistQtdConf(cProduto,nSaldoDist) //-- distribui quant dentro da nota
			
			EndIf
			
			If	ExistBlock("AV120VLD")
				Execblock("AV120VLD",.F.,.F.,{cEtiqProd,lForcaImp})
			EndIf
		    
			If lForcaQtd
				VtSay( 6, 0, Space(19) )
				cEtiqProd := Space(48)
				nQtdEtiq  := 1
				VtGetSetFocus('nQtdEtiq')
				Return .F.
			EndIf 
			
		End Sequence
	EndIf
		
	nQtdEtiq  := 0
	cEtiqProd := Space(48)
	cNota     := Space( TamSx3("F1_DOC")[1]     )
	cSerie    := Space( TamSx3("F1_SERIE")[1]   )
	cFornec   := Space( TamSx3("F1_FORNECE")[1] )
	cLoja     := Space( TamSx3("F1_LOJA")[1]    )
	cVolume   := Space( TamSx3("CB0_VOLUME")[1] )
	
	VTGetRefresh("cNota")
	VTGetRefresh("cSerie")
	VTGetRefresh("cFornec")
	VTGetRefresh("cLoja")
	VTGetRefresh("cVolume")
	VTGetRefresh("cEtiqProd")
	VTGetRefresh("nQtdEtiq")

	VtGetSetFocus('cVolume')
	VTKeyBoard( CHR(20) )

Return .F.

// Retorna o saldo que pode ser conferido do produto
Static Function QtdAConf(cProd)

	Local nSaldo    := 0
	Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)
	Local lCTRWMS   := SB5->( FieldPos("B5_CTRWMS") ) > 0
	Local lWmsGtPai := FindFunction("MtWMSGtPai")
	Local lFilho    := .F. 
	
	If lWmsGtPai
		lFilho	:= ( MtWMSGtPai( cProd ) <> cProd )
	Endif
	
	If lWmsNew .And. lCTRWMS .And. SB5->( MsSeek( xFilial("SB5") + cProd ) ) .And. SB5->B5_CTRWMS == '1' .And. lWmsGtPai .And. lFilho
		 
		DbSelectArea("CBN")
		CBN->( DbSeek( xFilial("CBN") + cNota + cSerie + cFornec + cLoja + Prod ) )
		While CBN->( !Eof() .And.  CBN_FILIAL + CBN_DOC + CBN_SERIE + CBN_FORNECE + CBN_LOJA + CBN_PRODU ==;
					xFilial("CBN") + cNota + cSerie + cFornec + cLoja + cProd )
			If CBN->CBN_QTDCON < CBN->CBN_QUANT
				nSaldo += ( CBN->CBN_QUANT - CBN->CBN_QTDCON )
			EndIf
			CBN->( dbSkip() )
		End
		
	Else	
		dbSelectArea("SF1")
		SF1->( dbSetOrder(1) )
		SF1->( dbSeek( xFilial("SF1") + cNota + cSerie + cFornec + cLoja ) )
		dbSelectArea("SD1")
		SD1->( dbSetOrder(1) )
		SD1->( dbSeek( xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + cProd ) )
		While !SD1->( Eof() ) .And. ;
			xFilial("SD1")  == D1_FILIAL .And.;
			SD1->D1_DOC     == SF1->F1_DOC .And. SD1->D1_SERIE == SF1->F1_SERIE .And.;
			SD1->D1_FORNECE == SF1->F1_FORNECE .And.;
			SD1->D1_LOJA    == SF1->F1_LOJA .And. SD1->D1_COD == cProd
			If SD1->D1_QTDCONF < SD1->D1_QUANT
				nSaldo += ( SD1->D1_QUANT - SD1->D1_QTDCONF )
			EndIf
			SD1->( dbSkip() )
		EndDo
	Endif

Return nSaldo

// Distribui a quantidade nos itens do SD1
Static Function DistQtdConf( cProd, nQtd, lEstorna )

	Local nSaldo 	:= nQtd
	Local nSaldoItem:= 0
	Local nQtdBx 	:= 0
	Local nPos 		:= AScan(aConf,{|x|AllTrim(x[1])==AllTrim(cProd)}) 
	Local lWmsNew	:= SuperGetMv("MV_WMSNEW",.F.,.F.)
	Local lCTRWMS   := SB5->( FieldPos("B5_CTRWMS") ) > 0
	Local lWmsGtPai := FindFunction("MtWMSGtPai")
	Local lFilho	:= .F. 
	Local lAV120SD1 := ExistBlock("AV120SD1")
	
	DEFAULT lEstorna:= .f.
	
	If nPos == 0
		aAdd( aConf, { cProd, 0 } )
		nPos := Len( aConf )
	EndIf
	
	If lWmsGtPai
		lFilho	:= ( MtWMSGtPai( cProd ) <> cProd )
	Endif
	
	If lWmsNew .And. lCTRWMS .And. SB5->( MsSeek( xFilial("SB5") + cProd ) ) .And. SB5->B5_CTRWMS == '1' .And. lWmsGtPai .And. lFilho
						
		DbSelectArea("CBN")
		CBN->( dbSeek( xFilial("CBN") + cNota + cSeriev + cFornec + cLoja + cProd ) )
		While CBN->(!Eof() .And. CBN_FILIAL + CBN_DOC + CBN_SERIE + CBN_FORNECE + CBN_LOJA + CBN_PRODU ==;
					xFilial("CBN") + cNota + cSerie + cFornec + cLoja + cProd )

			If ! lEstorna
				nSaldoItem := CBN->CBN_QUANT - CBN->CBN_QTDCON
			Else
				nSaldoItem := CBN->CBN_QTDCON
			EndIf
			
			If Empty( nSaldoItem )
				CBN->( dbSkip() )
				Loop
			EndIf
			
			nQtdBx := nSaldo
			
			If	nSaldoItem < nQtdBx
				nQtdBx := nSaldoItem
			EndIf
			
			RecLock("CBN",.F.)
			
				If	!lEstorna
					CBN->CBN_QTDCON += nQtdBx
					aConf[ nPos, 2 ] += nQtdBx
				Else
					CBN->CBN_QTDCON -= nQtdBx
					aConf[ nPos, 2 ] -= nQtdBx
				EndIf
				
				nSaldo -=nQtdBx
			
			MsUnLock()
			
			If Empty( nSaldo )
				Exit
			EndIf
			
			CBN->( dbSkip() )
		EndDo
	Else
		dbSelectArea("SD1")
		SD1->( dbSetOrder(1) )
		SD1->( dbSeek( xFilial("SD1") + cNota + cSerie + cFornec + cLoja + cProd ) )
		While SD1->( !Eof() .And. D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD == xFilial("SD1") + cNota + cSerie + cFornec + cLoja + cProd )
			If !lEstorna
				nSaldoItem := SD1->D1_QUANT - SD1->D1_QTDCONF
			Else
				nSaldoItem := SD1->D1_QTDCONF
			EndIf
			
			If Empty( nSaldoItem )
				SD1->( dbSkip() )
				Loop
			EndIf

			nQtdBx := nSaldo

			If	nSaldoItem < nQtdBx
				nQtdBx := nSaldoItem
			EndIf

			RecLock("SD1",.F.)
				If	!lEstorna
					SD1->D1_QTDCONF += nQtdBx
					aConf[ nPos, 2 ] += nQtdBx
				Else
					SD1->D1_QTDCONF -= nQtdBx
					aConf[ nPos, 2 ] -= nQtdBx
				EndIf
				nSaldo -= nQtdBx
			MsUnLock()
			
			//-- Ponto de Entrada após gravação da tabela SD1 (Itens NF)
			If	lAV120SD1
				ExecBlock("AV120SD1",.F.,.F.,{lEstorna})
			EndIf
			
			If	Empty( nSaldo )
				Exit
			EndIf
			
			SD1->( dbSkip() )
		EndDo
	Endif

Return
