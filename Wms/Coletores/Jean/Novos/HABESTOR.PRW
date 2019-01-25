#INCLUDE 'PROTHEUS.CH'

/*
Jean Rehermann - Solutio IT - 30/11/2017
Programa para liberar a confirmação de alteração de algum pedido na tela da verdade que já tenha
serviços executados no wms, apenas casos com tarefas concluídas, sem que seja necessário fazer o 
estorno da execução do serviço, deixando a cargo dos pontos de entrada PE_DL150BEX e PE_DL150AEX
o controle das quantidades e dos itens do pedido.
Foi criado apenas para as situações em que a atividade de apanhe já foi executada e o material já
tenha sido descarregado na mesa de conferência.
*/

User Function HabEstor()

	Local oDlg1,oSay1,oSay2,oSay3,oSay4,oGrp1,oSBtn1,oSBtn2
	Local cEscolha := "0"
	Local lRetOk   := .T.
	
	Private oGet1,oGet2,oGet3,oGet4
	Private cPedido  := Space( Len( SC5->C5_NUM ) )
	Private cEmissao := CtoD("")
	Private cCliente := Space( Len( SA1->A1_NREDUZ ) )
	Private cTransp  := Space( Len( SA4->A4_NREDUZ ) )

	oDlg1  := MSDialog():New( 142,389,378,741,"Libera Alteração de Pedido de Vendas",,,.F.,,,,,,.T.,,,.T. )
	oSay1  := TSay():New( 008,008,{||"Pedido"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
	oGet1  := TGet():New( 007,032,{|u| If(PCount()>0,cPedido:=u,cPedido)},oDlg1,044,008,"@!",{|| ValidPed(cPedido)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SC5","cPedido",,)
	oGrp1  := TGroup():New( 024,004,088,168,"  Informações  ",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay2  := TSay():New( 040,012,{||"Cliente"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oSay3  := TSay():New( 056,012,{||"Emissão"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oSay4  := TSay():New( 072,012,{||"Transportadora"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
	oGet2  := TGet():New( 036,040,{|u| If(PCount()>0,cCliente:=u,cCliente)},oGrp1,120,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cCliente",,)
	oGet3  := TGet():New( 052,040,{|u| If(PCount()>0,cEmissao:=u,cEmissao)},oGrp1,040,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cEmissao",,)
	oGet4  := TGet():New( 068,056,{|u| If(PCount()>0,cTransp:=u,cTransp)},oGrp1,104,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cTransp",,)
	oSBtn1 := SButton():New( 094,136,1,{|| cEscolha:="1",oDlg1:End() },oDlg1,,"", )
	oSBtn2 := SButton():New( 094,104,2,{|| cEscolha:="0",oDlg1:End() },oDlg1,,"", )
	oGet2:Disable()
	oGet3:Disable()
	oGet4:Disable()
	oDlg1:Activate(,,,.T.)
    
	If cEscolha == "1" .And. MsgYesNo("Tem certeza que deseja abrir o pedido "+ cPedido +" para alterações?")
		
		dbSelectArea("SC9")
		dbSetOrder(1)
		dbSeek( xFilial("SC9") + cPedido )
		
		While !SC9->( Eof() ) .And. xFilial("SC9") + cPedido == SC9->C9_FILIAL + SC9->C9_PEDIDO
			
			If SC9->C9_STSERV == "3" .And. Empty( SC9->C9_NFISCAL )
				
				// Analisa os registros referentes à execução do serviço, estornando se for o caso
				lRetOk := VerItLib()
				
				// Atualiza o C9 para permitir a confirmação da tela do televendas com as novas alterações
				If lRetOk
					RecLock("SC9",.F.)
						SC9->C9_STSERV := "1"
						SC9->C9_BLWMS  := "01"
					SC9->( MsUnLock() )
					
					// Executa o saldo atual para o produto para devolver o saldo ao endereço
					MsAguarde( {|| WmsSdAtu(SC9->C9_PRODUTO) }, "Atualizando Saldos..." )
				EndIf
				
			EndIf
			
			SC9->( dbSkip() )
		End
		
	EndIf

Return

// Efetua a validação do pedido selecionado
Static Function ValidPed( cPed )

	Local _lRet := .T.
	
	_lRet := ExistCpo("SC5",cPed)
	
	If _lRet
	
		dbSelectArea("SC9")
		dbSetOrder(1)
		_lRet := dbSeek( xFilial("SC9") + cPed )
		
		If _lRet
			
			While !SC9->( Eof() ) .And. xFilial("SC9") + cPed == SC9->C9_FILIAL + SC9->C9_PEDIDO
				
				_lRet := .F. // Caso exista algum item já executado ele volta a ser .T.
				
				If !Empty( SC9->C9_NFISCAL )
					Exit
				EndIf
				
				If SC9->C9_STSERV == "3" .And. Empty( SC9->C9_NFISCAL )
					_lRet := .T.
					Exit
				EndIf
				
				SC9->( dbSkip() )
			End
			SC9->( dbSkip(-1) )
			If !_lRet 
				If Empty( SC9->C9_NFISCAL )
					MsgAlert("Pedido não possui itens com serviço WMS executado.")
				Else
					MsgAlert("Pedido já possui nota fiscal.")
				EndIf
			EndIf
			
		Else
			MsgAlert("Pedido não possui liberações.")
		EndIf
	
	EndIf
	
	// Atualizando os campos com os detalhes do pedido
	If _lRet
		dbSelectArea("SC5")
		dbSetOrder(1)
		dbSeek( xFilial("SC5") + cPed )
		
		cEmissao := SC5->C5_EMISSAO
		oGet3:Refresh()
		
		cCliente := Posicione( "SA1", 1, xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_NREDUZ" )
		oGet2:Refresh()
		
		cTransp := Posicione( "SA4", 1, xFilial("SA4") + SC5->C5_TRANSP, "A4_NREDUZ" )
		oGet4:Refresh()
	EndIf

Return( _lRet )

// Analisa os registros referentes à execução do serviço, estornando se for o caso
Static Function VerItLib()

	Local _lOk      := .T.
	Local _aArea    := GetArea() // SC9 selecionado
	Local _cIdDCF   := SC9->C9_IDDCF
	Local cQuery    := ""
	
	If !Empty( _cIdDCF )

		cQuery := "UPDATE "+ RetSqlName("SDB")
		cQuery += " SET DB_ESTORNO  = 'S' "
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += "   AND DB_FILIAL  = '"+ xFilial("SDB") +"' "
		cQuery += "   AND DB_SERVIC  = '001' "
		cQuery += "   AND DB_IDDCF   = '"+ _cIdDCF         +"' "
		cQuery += "   AND DB_DOC     = '"+ SC9->C9_PEDIDO  +"' "
		cQuery += "   AND DB_SERIE   = '"+ SC9->C9_ITEM    +"' "
		cQuery += "   AND DB_PRODUTO = '"+ SC9->C9_PRODUTO +"' "
		cQuery += "   AND DB_LOCAL   = '"+ SC9->C9_LOCAL   +"' "
		cQuery += "   AND ( (   DB_ORIGEM  = 'SC9' "
		cQuery += "         AND DB_TIPO    = 'E' "
		cQuery += "         AND DB_CLIFOR  = '"+ SC9->C9_CLIENTE +"' "
		cQuery += "         AND DB_LOJA    = '"+ SC9->C9_LOJA    +"' )"
		cQuery += "      OR (   DB_ORIGEM  = 'SD3' ) ) "

		TcSqlExec( cQuery )
		TcSqlExec( 'COMMIT' )
	
	Else
		_lOk := .F.
	EndIf

Return _lOk

// Executa o saldo aual para o produto, retornando assim o saldo da DOCA para o endereço
Static Function WmsSdAtu( cProdSld )

	Local _nV   := 0
	Local _lOk  := .T.
	Local aArea := GetArea()
	Local aPerg := {"01", "02", cProdSld, cProdSld, "2", "2", "2", "2"}

	// Atualiza as perguntas no SX1
	For _nV := 1 To Len( aPerg )
		GravaSX1( "MTA300", "HABESTOR", StrZero( _nV, Len( SX1->X1_ORDEM ) ), aPerg[ _nV ] )
	Next
	
	MATA300( .T., Nil, {"05"} )
	
	RestArea( aArea )

Return( _lOk )

// Atualiza respostas das perguntas no SX1
Static function GravaSX1( cGrupo, cPergs, cOrdem, xValor )

	Local _aAreaAnt := GetArea()
	Local _sGrupo   := PadR( cGrupo, Len( SX1->X1_GRUPO ) )
	Local _sPergs   := PadR( cPergs, Len( SX1->X1_GRUPO ) )

	If SX1->( dbSeek( _sGrupo + cOrdem, .F. ) )

		RecLock("SX1", .F.)
			SX1->X1_CNT01  := xValor
		SX1->( MsUnLock() )
		
		aSX1 := {_sPergs,SX1->X1_ORDEM,SX1->X1_PERGUNT,SX1->X1_PERSPA,SX1->X1_PERENG,SX1->X1_VARIAVL,SX1->X1_TIPO,SX1->X1_TAMANHO,SX1->X1_DECIMAL,SX1->X1_PRESEL,SX1->X1_GSC,SX1->X1_VAR01,SX1->X1_DEF01,SX1->X1_DEFSPA1,SX1->X1_DEFENG1,SX1->X1_DEF02,SX1->X1_DEFSPA2,SX1->X1_DEFENG2,SX1->X1_DEF03,SX1->X1_DEFSPA3,SX1->X1_DEFENG3,SX1->X1_F3,SX1->X1_PYME,SX1->X1_GRPSXG}

	EndIf
	
	If SX1->( dbSeek( _sPergs + cOrdem, .F. ) )

		RecLock("SX1", .F. )
		SX1->X1_CNT01  := xValor

	Else
		RecLock("SX1", .T. )

		SX1->X1_GRUPO   := aSX1[01]
		SX1->X1_ORDEM   := aSX1[02]
		SX1->X1_PERGUNT := aSX1[03]
		SX1->X1_PERSPA  := aSX1[04]
		SX1->X1_PERENG  := aSX1[05]
		SX1->X1_VARIAVL := aSX1[06]
		SX1->X1_TIPO    := aSX1[07]
		SX1->X1_TAMANHO := aSX1[08]
		SX1->X1_DECIMAL := aSX1[09]
		SX1->X1_PRESEL  := aSX1[10]
		SX1->X1_GSC     := aSX1[11]
		SX1->X1_VAR01   := aSX1[12]
		SX1->X1_DEF01   := aSX1[13]
		SX1->X1_DEFSPA1 := aSX1[14]
		SX1->X1_DEFENG1 := aSX1[15]
		SX1->X1_DEF02   := aSX1[16]
		SX1->X1_DEFSPA2 := aSX1[17]
		SX1->X1_DEFENG2 := aSX1[18]
		SX1->X1_DEF03   := aSX1[19]
		SX1->X1_DEFSPA3 := aSX1[20]
		SX1->X1_DEFENG3 := aSX1[21]
		SX1->X1_F3      := aSX1[22]
		SX1->X1_PYME    := aSX1[23]
		SX1->X1_GRPSXG  := aSX1[24]
		SX1->X1_CNT01   := xValor

	EndIf

	SX1->( MsUnLock() )

	RestArea( _aAreaAnt )

Return