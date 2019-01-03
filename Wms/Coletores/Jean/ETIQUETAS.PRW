#INCLUDE "PROTHEUS.CH"

#DEFINE NPOSCHK 1
#DEFINE NPOSCAX 2
#DEFINE NPOSETI 3
#DEFINE NPOSQTD 4
#DEFINE NPOSDSC 5
#DEFINE NPOSPRD 6
#DEFINE NPOSLOC 7
#DEFINE NPOSEND 8

User Function Etiquetas()

    Local aCmpItem := {"D1_ITEM","DESCRICAO","D1_QUANT","D1_UM","D1_COD","D1_PEDIDO","D1_ITEMPC","D1_LOCAL"}
	Local oFont1 := TFont():New( "Arial",0,-19,,.T.,0,,700,.F.,.F.,,,,,, )
	Local oFont2 := TFont():New( "Arial",0,-11,,.T.,0,,700,.F.,.F.,,,,,, )
	Local oNf
	Local oSer
	Local oEmis
	Local oForn
	Local oLoja
	Local oNome
	Local oDlg
	Local oGrp1
	Local oGrp2
	Local oGrp3
	Local oMenu   
	Local lTodos
	Local _nX   := 0
	Local nOpcI := 0
	Local cEndEnt := ""
	Local cNota := SF1->F1_DOC
	Local cSeri := SF1->F1_SERIE
	Local dEmis := SF1->F1_EMISSAO
	Local cForn := SF1->F1_FORNECE
	Local cLoja := SF1->F1_LOJA
	Local cNome := Posicione("SA2",1,xFilial("SA2")+cForn+cLoja,"A2_NOME")
    
	Private aHeader	   := {}
	Private aCols	   := {}
	Private aEtiq      := {}
	Private aQtdEtqBkp := {}
	Private _lEdit     := SuperGetMv("IMD_EDETRE",.F.,.F.)
	Private oBrowse1
    
	dbSelectArea("SX3")
	dbSetOrder(2)
	
	For _nX := 1 To Len( aCmpItem )
	    
		If dbSeek( aCmpItem[ _nX ] ) .And. X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL

			aAdd( aHeader,{ AllTrim( X3Titulo() ),;
							AllTrim( SX3->X3_CAMPO ),;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,;
							SX3->X3_CONTEXT } )
		Else
			// Descrição do Produto
			If aCmpItem[ _nX ] = "DESCRICAO"
				aAdd( aHeader,{ "Descrição do Produto","DESCRICAO","@!",40,0,"","","C","","V" } )
			EndIf
		EndIf

	Next

	// Carrega os dados para o aCols
	RegToMemory('SD1',.F.)
    
	DbSelectArea('SD1')
	DbSetOrder(1)
	cChavSD1 := xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA
	DbSeek( cChavSD1 )
    
	Do While !SD1->( Eof() ) .And. SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == cChavSD1
 
		aAdd( aCols, Array( Len( aHeader ) + 1 ) )
		
		_nQtdTmp := SD1->D1_QUANT
 
		For nX := 1 To Len( aHeader )
			If ( aHeader[nX][10] != "V" )	// -- Pego campo somente que e REAL
				aCols[ Len( aCols ) ][ nX ] := FieldGet( FieldPos( aHeader[ nX ][ 2 ] ) )
			Else								// -- Se for campo virtual inicializa com conteudo do campo
				aCols[ Len( aCols ) ][ nX ] := AllTrim( Posicione("SB1",1,xFilial("SB1")+D1_COD,"B1_DESC") )
			EndIf
		Next
 
		aCols[ Len( aCols ) ][ Len( aHeader ) + 1 ] := .F. // -- Marco a linha como NAO deletada
		
		// Atualiza o array de etiquetas
		nPosEti := aScan( aEtiq, {|o| o[NPOSPRD] == SD1->D1_COD .And. o[NPOSLOC] == SD1->D1_LOCAL } )

		cChaveCB0 := xFilial("CB0") + SF1->F1_FORNECE + SF1->F1_LOJA + SD1->D1_COD + SF1->F1_DOC + SF1->F1_SERIE
		CB0->( dbSetOrder(9) )
		If CB0->( dbSeek( cChaveCB0 ) )
			While CB0->CB0_FILIAL + CB0->CB0_FORNEC + CB0->CB0_LOJAFO + CB0->CB0_CODPRO + CB0->CB0_NFENT + CB0->CB0_SERIEE == cChaveCB0
			
				If nPosEti == 0
					aAdd( aEtiq, { .F., StrZero( Len( aEtiq ) + 1, 3 ), CB0->CB0_CODETI, CB0->CB0_QTDE, AllTrim( Posicione("SB1",1,xFilial("SB1")+CB0->CB0_CODPRO,"B1_DESC") ), CB0->CB0_CODPRO, CB0->CB0_LOCAL, CB0->CB0_LOCALI } )
				Else
					aEtiq[ nPosEti, NPOSQTD ] += CB0->CB0_QTDE
				EndIf

				_nQtdTmp -= CB0->CB0_QTDE
				CB0->( dbSkip() )
			End
			// Após trazer as etiquetas ainda tem quantidade deste item + local sem etiquetas
			If _nQtdTmp > 0
				If nPosEti == 0
					aAdd( aEtiq, { .F., StrZero( Len( aEtiq ) + 1, 3 ), Space( TamSX3("CB0_CODETI")[1] ), _nQtdTmp, AllTrim( Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC") ), SD1->D1_COD, SD1->D1_LOCAL, SD1->D1_ENDER } )
				Else
					aEtiq[ nPosEti, NPOSQTD ] += _nQtdTmp
				EndIf
			EndIf
		Else
			If nPosEti == 0
				aAdd( aEtiq, { .F., StrZero( Len( aEtiq ) + 1, 3 ), Space( TamSX3("CB0_CODETI")[1] ), SD1->D1_QUANT, AllTrim( Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC") ), SD1->D1_COD, SD1->D1_LOCAL, SD1->D1_ENDER } )
			Else
				aEtiq[ nPosEti, NPOSQTD ] += SD1->D1_QUANT
			EndIf
		EndIf
		
		SD1->( DbSkip() )
	EndDo
	
	aQtdEtqBkp := aClone( aEtiq )
	nItem := aScan( aHeader, {|n| AllTrim( n[2] ) == "D1_ITEM" } )
	aSort( aCols,,,{|o,u| o[nItem] < u[nItem] } )

	DEFINE MSDIALOG oDlg TITLE "Impressão de Etiquetas" FROM 093,224 TO 633,1296 OF oMainWnd PIXEL
	
		oGrp1 := TGroup():New( 002,004,056,524,""                    ,oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )
		oGrp2 := TGroup():New( 060,004,258,210,"Itens da Nota Fiscal",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )
		oGrp3 := TGroup():New( 060,214,236,524,"Etiquetas / Caixas  ",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )
	
		@ 012,012 SAY "Nota Fiscal" SIZE 037,010 OF oDlg PIXEL
		@ 012,053 SAY "Série"   	SIZE 037,010 OF oDlg PIXEL
		@ 012,096 SAY "Emissão"   	SIZE 037,010 OF oDlg PIXEL
		@ 012,145 SAY "Fornecedor"  SIZE 037,010 OF oDlg PIXEL
		@ 012,190 SAY "Loja"   		SIZE 037,010 OF oDlg PIXEL
		@ 012,220 SAY "Nome"   		SIZE 037,010 OF oDlg PIXEL
	
		@ 028,012 MSGET	oNf   VAR cNota SIZE 040,010 OF oDlg PIXEL WHEN .F.
		@ 028,053 MSGET	oSer  VAR cSeri SIZE 020,010 OF oDlg PIXEL WHEN .F.
		@ 028,096 MSGET	oEmis VAR dEmis SIZE 040,010 OF oDlg PIXEL WHEN .F.
		@ 028,145 MSGET	oForn VAR cForn SIZE 040,010 OF oDlg PIXEL WHEN .F.
		@ 028,190 MSGET	oLoja VAR cLoja SIZE 020,010 OF oDlg PIXEL WHEN .F.
		@ 028,220 MSGET	oNome VAR cNome SIZE 150,010 OF oDlg PIXEL WHEN .F.
	   
		oBtn1  := TButton():New( 240,220,"&Dividir" ,oDlg,{||Dividir(oBrowse1:nAt)},037,012,,,,.T.,,"",,,,.F. )
		oBtn2  := TButton():New( 240,264,"&Reunir"  ,oDlg,{||Reunir(oBrowse1:nAt) },037,012,,,,.T.,,"",,,,.F. )
		oBtn3  := TButton():New( 240,308,"&Limpa"   ,oDlg,{||Limpar()             },037,012,,,,.T.,,"",,,,.F. )
		oBtn7  := TButton():New( 240,352,"&Excluir" ,oDlg,{||ExcluiEti()          },037,012,,,,.T.,,"",,,,.F. )
		oBtn4  := TButton():New( 240,430,"&Sair"    ,oDlg,{||nOpcI := 0,oDlg:End()},037,012,,,,.T.,,"",,,,.F. )
		oBtn6  := TButton():New( 240,474,"&Imprime",oDlg,{|| Iif( Confere(),(nOpcI:=1,oDlg:End()),Nil ) },037,012,,,,.T.,,"",,,,.F. )
	 	
		oMulti := MSGetDados():New( 070,006,256,208,2,"AllwaysTrue","AllwaysTrue","+D1_ITEM",.F.,,,,,,"",, )
		oMulti:Refresh()
	
		Menu oMenu PopUp
			MenuItem "Marca Todos     "	Action Eval( { || lTodos := .T. , aEval( aEtiq, {|e| e[NPOSCHK] := lTodos } ), oBrowse1:Refresh() } )
			MenuItem "Desmarca Todos  "	Action Eval( { || lTodos := .F. , aEval( aEtiq, {|e| e[NPOSCHK] := lTodos } ), oBrowse1:Refresh() } )
			MenuItem "Inverter Seleção"	Action Eval( { || lTodos := Nil , aEval( aEtiq, {|e| e[NPOSCHK] := !e[NPOSCHK] } ), oBrowse1:Refresh() } )
		EndMenu
		
		aColuna := {"  ","Caixa","Etiqueta","Quantidade","Descrição","Produto","Local","Endereço"}
		oBrowse1 := TCBrowse():New(070,217,285,155,,aColuna,,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
		AtuBrw(.f.)
		oBrowse1:bLDblClick   := {|| If( oBrowse1:nColPos == NPOSQTD, If( Empty( aEtiq[ oBrowse1:nAt, NPOSETI ] ) .Or. ( !Empty( aEtiq[ oBrowse1:nAt, NPOSETI ] ) .And. _lEdit .And. AllTrim( aEtiq[ oBrowse1:nAt, NPOSEND ] ) == "DOCA" ), EditQtd(), aEtiq[ oBrowse1:nAt, NPOSCHK ] := !aEtiq[ oBrowse1:nAt, NPOSCHK ] ), aEtiq[ oBrowse1:nAt, NPOSCHK ] := !aEtiq[ oBrowse1:nAt, NPOSCHK ] ) }
		oBrowse1:bHeaderClick := { |o,x,y| Iif( x == 1 , oMenu:Activate(x,y,oBrowse1) , Nil ) }	
	
	ACTIVATE MSDIALOG oDlg CENTERED

    If nOpcI == 1

		If !CB5SetImp( GetMv("MV_IACD02"),IsTelNet() )
			CBAlert('Codigo do tipo de impressao invalido')
			Return
		EndIF

		// Reordena o array de etiquetas pelo código de produto, para impressão
		aSort( aEtiq, , , {|x,y| x[ NPOSPRD ] < y[ NPOSPRD ] } )
		
		For _nX := 1 To Len( aEtiq )

			If aEtiq[ _nX, NPOSCHK ]
			
				SB1->( dbSetOrder(1) )
				SB1->( dbSeek( xFilial("SB1") + aEtiq[ _nX, NPOSPRD ] ) )
	
				SB5->( dbSetOrder(1) )
				SB5->( dbSeek( xFilial("SB5") + aEtiq[ _nX, NPOSPRD ] ) )
				cEndEnt := Iif( !Empty( SB5->B5_ENDENT ), SB5->B5_ENDENT, aEtiq[_nX,NPOSEND] )
	
				If !Empty( aEtiq[ _nX, NPOSETI ] )
					If _lEdit // Apenas quando permitir edição das quantidades das etiquetas já geradas
						CBGrvEti( '01', { Nil, aEtiq[_nX,NPOSQTD] }, aEtiq[ _nX, NPOSETI ] ) // Atualiza a quantidade
					EndIf
					ExecBlock('IMG01',,,{ Nil, Nil, aEtiq[ _nX, NPOSETI ] } )
				Else
					ExecBlock('IMG01',,,{aEtiq[_nX,NPOSQTD],RetCodUsr(),Nil,1,SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,aEtiq[_nX,NPOSLOC],,,,,,,,,,,cEndEnt})
				EndIf
			EndIf
		Next

		MSCBCLOSEPRINTER()

    EndIf

Return

// Função que divide a quantidade total do produto em caixas
Static Function Dividir(nLin)

	Local lChk    := aEtiq[ nLin, NPOSCHK ]
	Local cProd   := aEtiq[ nLin, NPOSPRD ]
	Local cDesc   := aEtiq[ nLin, NPOSDSC ]
	Local cLoca   := aEtiq[ nLin, NPOSLOC ]
	Local cEnde   := aEtiq[ nLin, NPOSEND ]
	Local cEtiq   := aEtiq[ nLin, NPOSETI ]
	Local oFont1  := TFont():New( "Arial",0,-21,,.T.,0,,700,.F.,.F.,,,,,, )
	Local nMod    := 0
	Local nQtdInCx:= 0
	Local nOpc    := 0
	
	Private nQtdO   := aEtiq[ nLin, NPOSQTD ]
	Private nQtdC   := 1
	Private nQtdS   := 0
	Private nQtdP   := 0
	Private cOptCb  := "1"

	If !Empty( cEtiq )
		MsgAlert("Etiqueta já gerada, não pode ser dividida!")
		Return
	EndIf
	
	If nQtdO < 2
		MsgAlert("Quantidade não pode ser dividida!")
		Return
	EndIf
	
	cPrdT := "Produto: "+ AllTrim( cProd ) +" - "+ AllTrim( Posicione("SB1",1,xFilial("SB1") + cProd,"B1_DESC") )
	
	oDlg1 := MSDialog():New( 186,415,380,820,"Sequência - "+ aEtiq[ nLin, NPOSCAX ],,,.F.,,,,,,.T.,,,.T. )
	oSay1 := TSay():New( 004,004,{|| cPrdT },oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)
	oGrp1 := TGroup():New( 016,004,090,190,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay4 := TSay():New( 024,069,{||"Dividir em"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay5 := TSay():New( 024,115,{||"Qtd.p/Etiq."},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGet1 := TGet():New( 024,008,{|u| If(Pcount()>0,nQtdO:=u,nQtdO)},oGrp1,048,014,'999999',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nQtdO"   ,,,,.F.,.F.,,"Qtd.Sem Etiqueta"  ,1)
	oGet2 := TGet():New( 050,008,{|u| If(Pcount()>0,nQtdS:=u,nQtdS)},oGrp1,048,014,'999999',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nQtdS"   ,,,,.F.,.F.,,"Saldo"             ,1)

	oSpinBox := tSpinBox():new(033,069,oGrp1,{|x| DivEtiq(x,1) },040,014)
	oSpinBox:setRange(1,nQtdO)
	oSpinBox:setStep(1)
	oSpinBox:setValue(nQtdC)
	oSpinBox:oFont := oFont1
	
	oSpinBox2 := tSpinBox():new(033,115,oGrp1,{|x| DivEtiq(x,2) },040,014)
	oSpinBox2:setRange(1,nQtdO)
	oSpinBox2:setStep(1)
	oSpinBox2:setValue(nQtdO)
	oSpinBox2:oFont := oFont1

	oCBox1 := TComboBox():New( 055,069,{|u| If(Pcount()>0,cOptCb:=u,cOptCb)},{"1=Cria Nova Etiqueta","2=Distribui em todas","3=Soma na Última"},072,010,oGrp1,,,,CLR_BLACK,CLR_WHITE,.T.,,,,,,,,,"cOptCb","Tratamento Saldo",1 )
	
	oSBtn1 := SButton():New( 053,160,1,{|| nOpc := 1, oDlg1:End() },oGrp1,,"", )
	oSBtn2 := SButton():New( 068,160,2,{|| oDlg1:End() },oGrp1,,"", )
	
	oDlg1:Activate(,,,.T.)
    
	If nOpc == 1
		
		aEtiq[ nLin, NPOSQTD ] := nQtdP
		
		For _nX := 1 To nQtdC - 1
			aAdd( aEtiq, { lChk, StrZero( Len( aEtiq ) + 1, 3 ), Space( TamSX3("CB0_CODETI")[1] ), nQtdP, cDesc, cProd, cLoca, cEnde } )
		Next
		
		If nQtdS > 0
			Do Case
				Case cOptCb == "1" // Gera nova etiqueta com o saldo
					aAdd( aEtiq, { lChk, StrZero( Len( aEtiq ) + 1, 3 ), Space( TamSX3("CB0_CODETI")[1] ), nQtdS, cDesc, cProd, cLoca, cEnde } )
				
				Case cOptCb == "2" // Distribui o saldo nas caixas
					
					While nQtdS > 0
						For _nX := 1 To Len( aEtiq )
							If aEtiq[ _nX, NPOSPRD ] == cProd .And. Empty( aEtiq[ _nX, NPOSETI ] )
								aEtiq[ _nX, NPOSQTD ]++
								nQtdS--
								If nQtdS == 0
								    Exit
								EndIf
							EndIf
						Next
				    End
				    
				Case cOptCb == "3" // Soma o saldo em uma etiqueta
					aEtiq[ Len( aEtiq ), NPOSQTD ] += nQtdS

			EndCase
		EndIf
		
		AtuBrw(.T.)
		
	EndIf

Return

// Função que reune a quantidade total do produto em uma única caixa
Static Function Reunir(nLin)

	Local cProd := aEtiq[ nLin, NPOSPRD ]
	Local cDesc := aEtiq[ nLin, NPOSDSC ]
	Local cLoca := aEtiq[ nLin, NPOSLOC ]
	Local cEtiq := aEtiq[ nLin, NPOSETI ]
	Local cEnde := aEtiq[ nLin, NPOSEND ]
	Local aTemp := {}
	Local nTemp := 0
	
	If !Empty( cEtiq )
		MsgAlert("Etiqueta já gerada, não pode ser aglutinada!")
		Return
	EndIf

	For _nX := 1 To Len( aEtiq )
		If aEtiq[ _nX, NPOSPRD ] != cProd
			aAdd( aTemp, { aEtiq[ _nX, NPOSCHK ], StrZero( Len( aTemp ) + 1, 3 ), aEtiq[ _nX, NPOSETI ], aEtiq[ _nX, NPOSQTD ], aEtiq[ _nX, NPOSDSC ], aEtiq[ _nX, NPOSPRD ], aEtiq[ _nX, NPOSLOC ], aEtiq[ _nX, NPOSEND ] } )
		Else
			If Empty( aEtiq[ _nX, NPOSETI ] ) .And. aEtiq[ _nX, NPOSLOC ] == cLoca
				nTemp += aEtiq[ _nX, NPOSQTD ]
			Else
				aAdd( aTemp, { aEtiq[ _nX, NPOSCHK ], StrZero( Len( aTemp ) + 1, 3 ), aEtiq[ _nX, NPOSETI ], aEtiq[ _nX, NPOSQTD ], aEtiq[ _nX, NPOSDSC ], aEtiq[ _nX, NPOSPRD ], aEtiq[ _nX, NPOSLOC ], aEtiq[ _nX, NPOSEND ] } )
			EndIf
		EndIf
	Next
 
	aAdd( aTemp, { .F., StrZero( Len( aTemp ) + 1, 3 ), Space( TamSX3("CB0_CODETI")[1] ), nTemp, cDesc, cProd, cLoca, cEnde } )
	aEtiq := aTemp
	
	AtuBrw(.T.)
	
Return

// Função que reune a quantidade total do produto em uma única caixa, para todos os itens sem etiqueta
Static Function Limpar(nLin)

	aEtiq := aQtdEtqBkp
	AtuBrw(.T.)

Return

// Função que verifica as quantidades separadas
Static Function Confere()

	Local _nX     := 0
	Local _nTotal := 0
	Local _nSoma  := 0
	Local _nSum1  := 0 // Total com Etiquetas
	Local _nSum2  := 0 // Total sem Etiquetas
	Local _cProd  := ""
	Local _cMsg   := ""
	Local _lRet   := .T.

	For _nX := 1 To Len( aQtdEtqBkp ) // Este é o array com as quantidades originais
		
		_cProd  := aQtdEtqBkp[_nX,NPOSPRD]    // Produto a ser pesquisado
		_cArmz  := aQtdEtqBkp[_nX,NPOSLOC]    // Local a ser pesquisado

		// Só preciso contar as quantidades do que não possui etiqueta quando a edição de etiquetas já geradas estiver desabilitada
		If !_lEdit .And. Empty( aQtdEtqBkp[ _nX, NPOSETI ] ) 

			_nSoma  := 0  // Contagem
			_nTotal := aQtdEtqBkp[ _nX, NPOSQTD ] // Quantidade original

			aEval( aEtiq,{ |X| _nSoma += Iif( X[NPOSPRD] == _cProd .And. X[NPOSLOC] == _cArmz .And. Empty( X[NPOSETI] ), X[NPOSQTD], 0 ) } )

			If _nSoma != _nTotal // Contagem diferente do total original
				_cMsg := "Verificar a soma das quantidades para o produto/local "+ AllTrim( _cProd ) +"/"+ AllTrim( _cArmz ) + CHR(13) + CHR(10)
				_cMsg += "Quantidade sem etiqueta: "+ cValToChar( _nTotal ) + CHR(13) + CHR(10)
				_cMsg += "Quantidade somada: "+ cValToChar( _nSoma )
				MsgAlert(_cMsg)
				_lRet  := .F.
				Exit
			EndIf
	
		ElseIf _lEdit

			aEval( aEtiq ,{ |X| _nSum1 += Iif( X[NPOSPRD] == _cProd .And. X[NPOSLOC] == _cArmz .And. !Empty( X[NPOSETI] ), X[NPOSQTD], 0 ) } ) // Soma o que está em etiquetas deste produto
			aEval( aEtiq ,{ |X| _nSum2 += Iif( X[NPOSPRD] == _cProd .And. X[NPOSLOC] == _cArmz .And. Empty( X[NPOSETI] ) , X[NPOSQTD], 0 ) } ) // Soma o que está sem etiquetas deste produto
			aEval( aQtdEtqBkp,{ |X| _nTotal += Iif( X[NPOSLOC] == _cArmz .And. X[NPOSPRD] == _cProd, X[NPOSQTD], 0 ) } ) // Soma o total original para o produto
			
			If ( _nSum1 + _nSum2 ) != _nTotal // Contagem diferente do total original
				_cMsg := "Verificar a soma das quantidades para o produto/local "+ AllTrim( _cProd ) +"/"+ AllTrim( _cArmz ) + CHR(13) + CHR(10)
				_cMsg += "Quantidade sem etiqueta: "+ cValToChar( _nSum2 ) + CHR(13) + CHR(10)
				_cMsg += "Quantidade com etiqueta: "+ cValToChar( _nSum1 ) + CHR(13) + CHR(10)
				_cMsg += "Total distribuído: "+ cValToChar( _nSum1 + _nSum2 ) + CHR(13) + CHR(10)
				_cMsg += "Quantidade original: "+ cValToChar( _nTotal ) + CHR(13) + CHR(10)
				_cMsg += "Diferença: "+ cValToChar( Abs( _nTotal - ( _nSum1 + _nSum2 ) ) )
				MsgAlert(_cMsg)
				_lRet  := .F.
				Exit
			EndIf

		EndIf
	Next

	If _lRet
		_lRet := MsgYesNo("Conferência OK, deseja imprimir agora?","Confirmar a impressão")
	EndIf

Return _lRet

// Função que faz a atualização do bLine do browse
Static Function AtuBrw(lRefresh)

	Local oOk := LoadBitMap(GetResources(), "LBOK")
	Local oNo := LoadBitMap(GetResources(), "LBNO")
	
	oBrowse1:SetArray( aEtiq ) 

	oBrowse1:bLine := { ||{ Iif( aEtiq[ oBrowse1:nAt, NPOSCHK ], oOk, oNo ),;
								 aEtiq[ oBrowse1:nAt, NPOSCAX ],;
								 aEtiq[ oBrowse1:nAt, NPOSETI ],;
								 aEtiq[ oBrowse1:nAt, NPOSQTD ],;
								 aEtiq[ oBrowse1:nAt, NPOSDSC ],;
								 aEtiq[ oBrowse1:nAt, NPOSPRD ],;
								 aEtiq[ oBrowse1:nAt, NPOSLOC ],;
								 aEtiq[ oBrowse1:nAt, NPOSEND ] } }
	If lRefresh
		oBrowse1:Refresh()
	EndIf	

Return


// Função que imprime a etiqueta na impressora térmica, e gera o ID para a etiqueta no CB0
User Function IMG01 //Identificacao de produto

	Local cCodigo, sConteudo, cTipoBar, nX
	
	Local nQtde    := Iif( Len( PARAMIXB ) >=01, PARAMIXB[01], NIL )
	Local cCodSep  := Iif( Len( PARAMIXB ) >=02, PARAMIXB[02], NIL )
	Local cCodID   := Iif( Len( PARAMIXB ) >=03, PARAMIXB[03], NIL )
	Local nCopias  := Iif( Len( PARAMIXB ) >=04, PARAMIXB[04], 1   )
	Local cNFEnt   := Iif( Len( PARAMIXB ) >=05, PARAMIXB[05], ""  )
	Local cSeriee  := Iif( Len( PARAMIXB ) >=06, PARAMIXB[06], ""  )
	Local cFornec  := Iif( Len( PARAMIXB ) >=07, PARAMIXB[07], ""  )
	Local cLojafo  := Iif( Len( PARAMIXB ) >=08, PARAMIXB[08], ""  )
	Local cArmazem := Iif( Len( PARAMIXB ) >=09, PARAMIXB[09], ""  )
	Local cOP      := Iif( Len( PARAMIXB ) >=10, PARAMIXB[10], ""  )
	Local cNumSeq  := Iif( Len( PARAMIXB ) >=11, PARAMIXB[11], ""  )
	Local cLote    := Iif( Len( PARAMIXB ) >=12, PARAMIXB[12], ""  )
	Local cSLote   := Iif( Len( PARAMIXB ) >=13, PARAMIXB[13], ""  )
	Local dValid   := Iif( Len( PARAMIXB ) >=14, PARAMIXB[14], NIL )
	Local cCC      := Iif( Len( PARAMIXB ) >=15, PARAMIXB[15], NIL )
	Local cLocOri  := Iif( Len( PARAMIXB ) >=16, PARAMIXB[16], NIL )
	Local cOPREQ   := Iif( Len( PARAMIXB ) >=17, PARAMIXB[17], NIL )
	Local cNumSerie:= Iif( Len( PARAMIXB ) >=18, PARAMIXB[18], NIL )
	Local cOrigem  := Iif( Len( PARAMIXB ) >=19, PARAMIXB[19], NIL )
	Local cEndereco:= Iif( Len( PARAMIXB ) >=20, PARAMIXB[20], NIL )
	Local cPedido  := Iif( Len( PARAMIXB ) >=21, PARAMIXB[21], NIL )
	Local nResto   := Iif( Len( PARAMIXB ) >=22, PARAMIXB[22], 0   )
	Local cItNFE   := Iif( Len( PARAMIXB ) >=23, PARAMIXB[23], NIL )
	
	cLocOri := If( cLocOri==cArmazem, ' ', cLocOri )
	nQtde   := If( nQtde == NIL, SB1->B1_QE, nQtde )
	cCodSep := If( cCodSep == NIL, '', cCodSep )
	
	For nX := 1 to nCopias
		
		If cCodID != NIL

			CBRetEti(cCodID)
			
			nQtde 	 := CB0->CB0_QTDE
			cCodSep  := CB0->CB0_USUARIO
			cNFEnt   := CB0->CB0_NFENT
			cSeriee  := CB0->CB0_SERIEE
			cFornec  := CB0->CB0_FORNEC
			cLojafo  := CB0->CB0_LOJAFO
			cArmazem := CB0->CB0_LOCAL
			cOP      := CB0->CB0_OP
			cNumSeq  := CB0->CB0_NUMSEQ
			cLote    := CB0->CB0_LOTE
			cSLote   := CB0->CB0_SLOTE
			cCC      := CB0->CB0_CC
			cLocOri  := CB0->CB0_LOCORI
			cOPReq   := CB0->CB0_OPREQ
			cNumserie:= CB0->CB0_NUMSER		
			cOrigem  := CB0->CB0_ORIGEM
			cEndereco:= CB0->CB0_LOCALI
			cPedido  := CB0->CB0_PEDCOM
			cItNFE   := CB0->CB0_ITNFE
		
		EndIf

		If UsaCB0("01")
			cCodigo := If(cCodID==NIL,CBGrvEti('01',{SB1->B1_COD,nQtde,cCodSep,cNFEnt,cSeriee,cFornec,cLojafo,cPedido,cEndereco,cArmazem,cOp,cNumSeq,NIL,NIL,NIL,cLote,cSLote,dValid,cCC,cLocOri,NIL,cOPReq,cNumserie,cOrigem,cItNFE}),cCodID)
		Else
			cCodigo := SB1->B1_CODBAR
		EndIf
		
		cCodigo := Alltrim(cCodigo)

		//MSCBLOADGRF("lgrl01.bmp")
		MSCBBEGIN(1,6)                            
			MSCBBOX(07,24,96,65,1)    
			MSCBLineH(35,60,96,1) 
			MSCBLineH(07,53,96,1) 
			MSCBLineH(07,45,96,1) 
			MSCBLineH(07,39,96,1) 
			MSCBLineV(35,53,64,1)
			//MSCBGRAFIC(7,56,"lgrl01")
			MSCBSAY(13,55,'IMDEPA',"N","5","01,01")
			MSCBSAY(38,61,'PRODUTO',"N","2","01,01")
			MSCBSAY(38,58,'CODIGO',"N","1","01,01")
			MSCBSAY(38,54,SB1->B1_COD, "N", "3", "01,01")
			MSCBSAY(09,50,'DESCRICAO',"N","1","01,01")
			MSCBSAY(09,46,Left(SB1->B1_DESC, 50),"N", "2", "01,01")
			MSCBSAY(09,40,'QUANTIDADE: '+ PADL( cValToChar( nQtde ), 10 ),"N","2","01,01")
			MSCBSAYBAR(33,27,cCodigo,"N","E",8.36,.F.,.T.,.F.,,3,2,.F.,.F.,"1",.T.)
		MSCBEND()

	Next

Return

// Faz a correção das quantidades distribuídas nas etiquetas
Static Function Corrige( nLin )

	Local _lRet   := .T.
	Local _nX     := 0
	Local _nPos   := 0
	Local _nSumEt := 0
	Local _nSumVz := 0
	Local _nTotal := 0
	Local cProd   := aEtiq[ nLin, NPOSPRD ]
	Local cEtiq   := aEtiq[ nLin, NPOSETI ]
	Local cDesc   := aEtiq[ nLin, NPOSDSC ]
	Local cLoca   := aEtiq[ nLin, NPOSLOC ]
	Local cEnde   := aEtiq[ nLin, NPOSEND ]

	If !IsInCallStack("EDITQTD")
		If Empty( cEtiq )
			MsgAlert("Item sem etiqueta!")
			Return
		EndIf
		
		If AllTrim( cEnde ) != "DOCA"
			MsgAlert("Endereço diferente de DOCA!")
			Return
		EndIf
    EndIf
    
	aEval( aEtiq     ,{ |X| _nSumEt += Iif( X[NPOSPRD] == cProd .And. !Empty( X[NPOSETI] ), X[NPOSQTD], 0 ) } ) // Soma o que está em etiquetas deste produto
	aEval( aEtiq     ,{ |X| _nSumVz += Iif( X[NPOSPRD] == cProd .And. Empty( X[NPOSETI] ) , X[NPOSQTD], 0 ) } ) // Soma o que está sem etiquetas deste produto
	aEval( aQtdEtqBkp,{ |X| _nTotal += Iif( X[NPOSPRD] == cProd, X[NPOSQTD], 0 ) } ) // Soma o total para o produto da etiqueta
	
	If ( _nSumEt + _nSumVz ) < _nTotal // Soma dos itens com etiqueta e sem etiqueta é menor que o original
		
		If _nSumVz == 0 // Se a soma dos itens sem etiqueta for zero, crio um novo item
			aAdd( aEtiq, { .F., StrZero( Len( aEtiq ) + 1, 3 ), "", _nTotal - ( _nSumEt + _nSumVz ), cDesc, cProd, cLoca, cEnde } )
		Else // Senão somo no item existente
			_nPos := aScan( aEtiq, {|X| X[NPOSPRD] == cProd .And. Empty( X[NPOSETI] ) } ) // Primeira posição do produto sem etiqueta
			aEtiq[ _nPos, NPOSQTD ] += ( _nTotal - ( _nSumEt + _nSumVz ) )
		EndIf
		AtuBrw(.T.)
	
	ElseIf ( _nSumEt + _nSumVz ) > _nTotal // Soma dos itens com etiqueta e sem etiqueta é maior que o original
		
		If ( ( _nSumEt + _nSumVz ) - _nTotal ) <= _nSumVz .And. _nSumVz > 0 // Tem item com quantidade sem etiqueta

			_nPos := aScan( aEtiq, {|X| X[NPOSPRD] == cProd .And. Empty( X[NPOSETI] ) } ) // Primeira posição do produto sem etiqueta
			Reunir( _nPos ) // Aglutino todas as quantidades sem etiquetas para evitar deixar negativo
			_nPos := aScan( aEtiq, {|X| X[NPOSPRD] == cProd .And. Empty( X[NPOSETI] ) } ) // Verifico a nova posição do produto sem etiqueta (será o último)
			
			aEtiq[ _nPos, NPOSQTD ] -= ( ( _nSumEt + _nSumVz ) - _nTotal )
			
			If aEtiq[ _nPos, NPOSQTD ] == 0
				aDel( aEtiq, _nPos ) // Apaga do array o registro que ja foi movimentado, que sempre será o último
				aSize( aEtiq, Len( aEtiq ) - 1 ) // Exclui fisicamente o registro do array
			EndIf
			
			AtuBrw(.T.)

		Else
			MsgAlert("A quantidade distribuida nas etiquetas supera o total do item. Verifique!")
			_lRet := .F.
		EndIf
	
	EndIf

Return( _lRet )

// Valida o conteúdo digitado no campo da quantidade
Static Function EditQtd()

	Local _nQtdOri := aEtiq[ oBrowse1:nAt, NPOSQTD ]
	
	lEditCell( aEtiq, oBrowse1, "999999", NPOSQTD )	
	
	While .T.
		If aEtiq[ oBrowse1:nAt, NPOSQTD ] <= 0 // Valida a quantidade
			MsgAlert("Quantidade inválida!")
			aEtiq[ oBrowse1:nAt, NPOSQTD ] := _nQtdOri
			lEditCell( aEtiq, oBrowse1, "999999", NPOSQTD )

		Else // Quantidade positiva
			If !Empty( aEtiq[ oBrowse1:nAt, NPOSETI ] ) .And. _lEdit .And. AllTrim( aEtiq[ oBrowse1:nAt, NPOSEND ] ) == "DOCA"
				If Corrige( oBrowse1:nAt ) // Caso a quantidade digitada não exceda o total do produto na nota
					Exit
				Else
					aEtiq[ oBrowse1:nAt, NPOSQTD ] := _nQtdOri
					lEditCell( aEtiq, oBrowse1, "999999", NPOSQTD )
				EndIf
			Else // Apenas sai do campo
				Exit
			EndIf
		EndIf
	End

Return


// Função para excluir etiquetas que já foram geradas
Static Function ExcluiEti()

	Local _nSemEtiq := 0
	Local _nTotSemE := 0
	Local _nEtiqEnd := 0
	Local _nX       := 0
	Local _nPos1    := 0
	Local _nPos2    := 0
	Local _lUmaMarc := .F.
	Local _lConf    := .F. 
	Local _aEtiqExc := {}
	Local _cMens    := ""
	
	For _nX := 1 To Len( aEtiq )

		If aEtiq[ _nX, NPOSCHK ]
	
			_lUmaMarc := .T.
			
			If Empty( aEtiq[ _nX, NPOSETI ] )
				_nSemEtiq++
				_nTotSemE++
			ElseIf AllTrim( aEtiq[ _nX, NPOSEND ] ) != "DOCA"
				_nEtiqEnd++
			Else
				aAdd( _aEtiqExc, aEtiq[ _nX, NPOSETI ] )
			EndIf
		
		Else
			If Empty( aEtiq[ _nX, NPOSETI ] )
				_nTotSemE++
			EndIf
		EndIf
	
	Next
	
	If _nTotSemE == Len( aEtiq )
		_cMens := "Sem etiquetas geradas para esta nota fiscal!"+Chr(13)+Chr(10)
	ElseIf !_lUmaMarc
		_cMens := "Nenhuma etiqueta marcada para exclusão!"+Chr(13)+Chr(10)
	ElseIf Len( _aEtiqExc ) == 0
		_cMens := "Nenhuma etiqueta elegível para exclusão!"+Chr(13)+Chr(10)
	Else
		_cMens := "Confirma a exclusão das etiquetas?"+Chr(13)+Chr(10)
		_cMens += cValToChar( Len( _aEtiqExc ) ) +" etiqueta(s) será(ão) excluída(s)."+Chr(13)+Chr(10)
	EndIf

	If _nEtiqEnd > 0
		_cMens += cValToChar( _nEtiqEnd ) +" etiqueta(s) marcada(s) já está(ão) endereçada(s)."+Chr(13)+Chr(10)
	EndIf

	If _nSemEtiq > 0
		_cMens += cValToChar( _nSemEtiq ) +" item(ns) marcado(s) não tem etiqueta."
	EndIf
	
	If "Confirma a exclusão das etiquetas?" $ _cMens
		_lConf := MsgYesNo( _cMens )
	Else
		MsgAlert( _cMens )
	EndIf

	If _lConf
	
		For _nX := 1 To Len( _aEtiqExc )
			
			_nPos1 := aScan( aEtiq     , {|X| X[NPOSETI] == _aEtiqExc[ _nX ] } ) // Posição da etiqueta no array
			_nPos2 := aScan( aQtdEtqBkp, {|X| X[NPOSETI] == _aEtiqExc[ _nX ] } ) // Posição da etiqueta no array
			
			If _nPos1 > 0
			
				CB0->( dbSetOrder(1) )
				If CB0->( dbSeek( xFilial("CB0") + _aEtiqExc[ _nX ] ) )
					RecLock("CB0",.F.)
						dbDelete()
					CB0->( MsUnLock() )
				
					aEtiq[ _nPos1, NPOSETI ] := Space(10)
					Reunir(_nPos1)
					
					If _nPos2 > 0
						AjustaBkp( _nPos2 ) // Altera o backup da posição inicial pois não existe mais a etiqueta
					EndIf

				EndIf
			
			EndIf
			
		Next
	
    EndIf

Return


// Altera o backup da posição inicial logo após excluir a etiqueta
Static Function AjustaBkp( nPosEti )

	Local _cProd   := ""
	Local _cLocal  := ""
	Local _cLocali := ""
	Local _aTemp   := {}
	Local _nX      := 0
	Local _nPos    := 0
	Local _nPosP   := 0
	Local _nQtdE   := 0
	Local _nLast   := 0
	
	If nPosEti > 0
		
		_cProd   := aQtdEtqBkp[ nPosEti, NPOSPRD ]
		_nQtdE   := aQtdEtqBkp[ nPosEti, NPOSQTD ]
		_cLocal  := aQtdEtqBkp[ nPosEti, NPOSLOC ]
		_cLocali := aQtdEtqBkp[ nPosEti, NPOSEND ]
	
		For _nX := 1 To Len( aQtdEtqBkp )
		
			If _nX != nPosEti
				
				aAdd( _aTemp, aQtdEtqBkp[ _nX ] ) // Adiciono o item quando não for o item marcado
				_nLast := Len( _aTemp )
				_aTemp[ _nLast, NPOSCAX ] := StrZero( Len( _aTemp ), 3 ) // Ajusto a sequencia

				If _nPosP == 0 .And. Empty( _aTemp[ _nLast, NPOSETI ] ) .And. _aTemp[ _nLast, NPOSPRD ] == _cProd // Tem saldo do produto sem etiqueta
					_aTemp[ _nLast, NPOSQTD ] += _nQtdE // Somo neste item a quantidade que estava na etiqueta
					_nPosP := _nX
				EndIf
			
			EndIf
		
		Next

		// Quando não existe um item de mesmo produto sem etiqueta, para somar a quantidade da etiqueta excluída, crio um ao final.
		If _nPosP == 0
			aAdd( _aTemp, { .F., StrZero( _nLast + 1, 3 ), Space(10), _nQtdE, AllTrim( Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_DESC") ), _cProd, _cLocal, _cLocali } )
		EndIf
		
		aQtdEtqBkp := _aTemp
		
	EndIf

Return

// Atualiza a tela de divisão de etiqueta com as quantidades de acordo com a seleção do usuário
Static Function DivEtiq( z, s )
	
	If s == 1

		nQtdC := z // Quantas caixas foi informado
	
		nQtdP := Int( nQtdO / nQtdC ) // Quantidade que vai em cada caixa
		nQtdS := nQtdO % nQtdC // resto da divisão da quantidade pelas caixas
		oSpinBox2:setValue(nQtdP) // Atualiza o SpinBox da quantidade por caixa
		oSpinBox2:Refresh()
    
	Else

		nQtdP := z // Quantidade por caixa que foi informado
		
		nQtdC := Int( nQtdO / nQtdP ) // Quantas caixas (nQtdC) para a quantidade por caixa estipulada (z)
		nQtdS := nQtdO - ( nQtdP * nQtdC ) // Saldo da divisão da quantidade pelas caixas
		oSpinBox:setValue(nQtdC) // Atualiza o SpinBox da quantidade de caixas
		oSpinBox:Refresh()
	
	EndIf

	oGet2:Refresh() // Atualiza o campo do saldo
	
Return