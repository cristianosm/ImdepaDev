#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APVT100.CH"
/*
Jean Rehermann - Solutio IT - 09/01/2018
Programa que efetua a contagem dos endereços de acordo com o mestre de contagem selecionado
*/
User Function VTCONTAG()

	Local bkey09 := VTSetKey(09)          
	Local bkey22 := VTSetKey(22)
	Local bkey24 := VTSetKey(24)
	Local cKey09 := VtDescKey(09)
	Local cKey22 := VtDescKey(22)
	Local cKey24 := VtDescKey(24)
	
	Local aTela     := {}
	Local lContinua := .T.
	Local cEndereco := ""
	Local cConfirma := ""
	Local cProduto  := ""
	Local cDescPrd  := ""
	Local cPrdAtua  := ""
	Local nQtde     := 0
	
	Private cMestre := Space(6)
	Private aContag := {}
	Private nCont   := 0
	Private cCont   := ""

	aTela := VtSave()
	VtClearBuffer()
			
	While .T.
		
		lContinua := .T.
		
		VTClear()
		DLVTCabec("Contagem", .F., .F., .T.)
			@ 02, 00 VTSay PadR("Mestre de Contagem", VTMaxCol())
			@ 03, 00 VTGet cMestre Valid ValMstr( cMestre )
		VTRead
	
		If VTLastKey() == 27
			Exit
		EndIf
	
		While lContinua
	
			For _nX := 1 To Len( aContag )
				
				cEndereco := aContag[ _nX, 1 ]
				cConfirma := Space( Len( cEndereco ) )
				
				VTClear()
				DLVTCabec('Va para o Endereco',.F.,.F.,.T.)
				@ 02, 00 VTSay PadR('Endereco', VTMaxCol())
				@ 03, 00 VTSay PadR(cEndereco, VTMaxCol())
				@ 05, 00 VTSay PadR('Confirme !', VTMaxCol())
				@ 06, 00 VTGet cConfirma Picture '@!' Valid VldEnd( @cConfirma, cEndereco )
				VTRead
			          
				If VTLastKey() == 27
					If DLVTAviso('CONTAGEM','Deseja interromper?', {'Sim','Não'}) == 1
						lContinua := .F.
						aContag := {}
						VTKeyBoard(Chr(20))
						Exit
					Else
						_nX--
						Loop
					EndIf
				EndIf
				
				If nCont == 1

					If lContinua
						
						While .T.
	
							cProduto := Space( Len( SB1->B1_CODBAR ) )
							nQtde    := 0
							
							DLVTCabec('Produto Contagem',.F.,.F.,.T.)
							@ 02, 00 VTSay PadR('Produto', VTMaxCol())
							@ 03, 00 VTGet cProduto Picture '@!' Valid VldPro(@cProduto,cPrdAtua)
							@ 04, 00 VTSay PadR('Quantidade', VTMaxCol())
							@ 05, 00 VTGet nQtde Picture "@E 999,999.99"
							VTRead
	
							If VTLastKey() == 27
								 
								 nOpc := DLVTAviso('CONTAGEM ENDEREÇO','Selecione uma opção', {'Continuar','Interromper','Finalizar'})
								 
								 If nopc == 2
								 	_nX--
								 	Exit
								 ElseIf nOpc == 3
								 	FinalEnd( cEndereco )
								 	Exit
								 EndIf
							Else
								AvalCont( cEndereco, cProduto, nQtde ) // faz a avaliação da contagem para o endereço/produto
							EndIf
							
						EndDo
						
					EndIf
	
					If _nX == Len( aContag )
						aContag := {}
						lContinua := .F.
					Endif
			
				Else // Contagem maior que 1
				
					While lContinua .And. cEndereco == aContag[ _nX, 1 ]

						cPrdAtua := aContag[ _nX, 2 ]
						cDescPrd := Posicione("SB1", 1, xFilial("SB1") + cPrdAtua, "B1_DESC" )

						DLVTCabec('Produto Contagem',.F.,.F.,.T.)
						@ 01, 00 VTSay PadR('Leia o Produto', VTMaxCol())
						@ 02, 00 VTSay aContag[ _nX, 2 ]
						@ 03, 00 VTSay Left( cDescPrd, VTMaxCol() )                   // Descrição de 01 a 20
						@ 04, 00 VTSay SubStr( cDescPrd, VTMaxCol() + 1, VTMaxCol() ) // Descrição de 21 a 40
						DLVTRodaPe()
						VtClear()

						cProduto := Space( Len( SB1->B1_CODBAR ) )
						nQtde    := 0
						
						DLVTCabec('Produto Contagem',.F.,.F.,.T.)
						@ 02, 00 VTSay PadR('Produto', VTMaxCol())
						@ 03, 00 VTGet cProduto Picture '@!' Valid VldPro(@cProduto,cPrdAtua)
						@ 04, 00 VTSay PadR('Quantidade', VTMaxCol())
						@ 05, 00 VTGet nQtde Picture "@E 999,999.99"
						VTRead

						If VTLastKey() == 27
							 
							 nOpc := DLVTAviso('CONTAGEM ENDEREÇO','Selecione uma opção', {'Continuar','Interromper'})
							 
							 If nopc == 2
							 	_nX--
							 	Exit
							 EndIf
						Else
							
							AvalCont( cEndereco, cProduto, nQtde ) // faz a avaliação da contagem para o endereço/produto
							
							_nX++ // Avanço uma posição no array
							
							If _nX > Len( aContag )
								aContag := {}
								lContinua := .F.
							Endif

							If lContinua .And. cEndereco != aContag[ _nX, 1 ]
								_nX--
							EndIf
							
						EndIf
						
					EndDo
				
				EndIf
			
			Next
			
			VTKeyBoard(Chr(20))

		EndDo
	
	EndDo

Return()

//------------------------------------------------------------
// Valida o mestre de contagem informado na tela inicial
//------------------------------------------------------------
Static Function ValMstr( cMstr )

	Local _lRet := .T.
	Local _cUsr := RetCodUsr()
	
	dbSelectArea("ZAP")
	dbSetOrder(1)
	If !dbSeek( xFilial("ZAP") + cMstr )
		VTAlert("Mestre de contagem não existe!","Erro",.T.,2000 )
		VTKeyBoard(Chr(20))
		_lRet := .F.
	ElseIf dDataBase > ZAP->ZAP_DTFIM .Or. dDataBase < ZAP->ZAP_DTINI
		VTAlert("Contagem fora do período!","Erro",.T.,2000 )
		VTKeyBoard(Chr(20))
		_lRet := .F.
	EndIf

	If _lRet
		
		cCont := ZAP->ZAP_CONTAG
		nCont := Val( ZAP->ZAP_CONTAG )
		
		GetCont( _cUsr, cCont ) // Verifica as contagens disponíveis para este usuário neste mestre de contagem
		
		If Len( aContag ) == 0
			VTAlert("Não existe contagem para este usuário neste mestre de contagem!","Erro",.T.,2000 )
			VTKeyBoard(Chr(20))
			_lRet := .F.
		EndIf
	
	EndIf
	
Return( _lRet )

//------------------------------------------------------------
// Verifica se existem registros para o usuário nesta contagem
//------------------------------------------------------------
Static Function GetCont( cUserId, cCnt )

	Local _cQuery := ""
	Local _cAlias := ""
	Local _aArea  := GetArea()
	
	aContag := {}
	
	If nCont == 1

		_cQuery := "SELECT DISTINCT(ZAQ_ENDER) ZAQ_ENDER "
		_cQuery += " FROM "+ RetSqlName("ZAQ")
		_cQuery += " WHERE ZAQ_FILIAL  = '"+ xFilial("ZAQ") +"' "
		_cQuery += "   AND ZAQ_MESTRE  = '"+ cMestre +"' "
		_cQuery += "   AND ZAQ_CONTAG  = '"+ cCnt    +"' "
		_cQuery += "   AND ZAQ_USER    = '"+ cUserId +"' "
		_cQuery += "   AND ZAQ_STATUS  = 'X' "
		_cQuery += "   AND D_E_L_E_T_  = ' ' "
		_cQuery += "   ORDER BY ZAQ_ENDER "
	
	Else

		_cQuery := "SELECT ZAQ_ENDER, ZAQ_PRODUT "
		_cQuery += " FROM "+ RetSqlName("ZAQ")
		_cQuery += " WHERE ZAQ_FILIAL  = '"+ xFilial("ZAQ") +"' "
		_cQuery += "   AND ZAQ_MESTRE  = '"+ cMestre +"' "
		_cQuery += "   AND ZAQ_CONTAG  = '"+ cCnt    +"' "
		_cQuery += "   AND ZAQ_USER    = '"+ cUserId +"' "
		_cQuery += "   AND ZAQ_STATUS  = 'X' "
		_cQuery += "   AND D_E_L_E_T_  = ' ' "
		_cQuery += "   ORDER BY ZAQ_ENDER, ZAQ_PRODUT "
	
	EndIf
	
	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	
	While !(_cAlias)->( Eof() )
		
		aAdd( aContag, { (_cAlias)->ZAQ_ENDER, Iif( nCont == 1, "", (_cAlias)->ZAQ_PRODUT ) } )
		
		(_cAlias)->( dbSkip() )
	End
	
	(_cAlias)->( dbCloseArea() )

	RestArea( _aArea )
	
Return( aContag )

//---------------------------------------------------
// Valida o endereço lido, só pode aceitar o sugerido
//---------------------------------------------------
Static Function VldEnd( cConfirma, cEndereco )

	Local lRet := .T.
	
	If Empty( cConfirma )
		lRet := .F.
	Else
		lRet := ( AllTrim(cConfirma) == Alltrim(cEndereco) )
		If !lRet
			DLVTAviso('ENDEREÇO',"Endereco Incorreto")
			VTKeyBoard(Chr(20))
		EndIf
	EndIf

Return lRet

//----------------------
// Valida o produto lido
//----------------------
Static Function VldPro( cProduto, cPrdLer )

	Local lRet     := .T.
	Local aProduto := {}
	Local nOpc     := 0
	Local aTela    := VtSave()
	
	If Empty( cProduto )
		lRet := .F.
	Else

		aProduto := CBRetEtiEAN( cProduto )
		
		If Len(aProduto) > 0
			If Len(aProduto) > 1
				VTClear()
				// VER AQUI pra verificar produto com saldo no endereço
				DLVTCabec('Seleciona Produto',.F.,.F.,.T.)
				nOpc := VTaChoice(2,0,VtMaxRow(),VTMaxCol(),aProduto)
				VtRestore(,,,,aTela)
				If nOpc == 0
					cProduto := ""
				Else
					cProduto := aProduto[nOpc]
				EndIf
			Else
				cProduto := aProduto[1]
			EndIf
		Else
			aProduto := CBRetEti(cProduto, '01')
			If Len(aProduto) > 0
				cProduto := aProduto[1]
			Else
				cProduto := ""
			EndIf
		EndIf

		If Empty( cProduto )
			lRet := .F.
			DLVTAviso('PRODUTO',"Produto Inválido")
		EndIf

		If nCont > 1 .And. !Empty( cPrdLer ) .And. AllTrim( cPrdLer ) != AllTrim( cProduto )
			lRet := .F.
			DLVTAviso('PRODUTO',"Produto lido: "+ AllTrim( cProduto ) +" / Produto esperado: "+ AllTrim( cPrdLer ) )
		EndIf
		
	EndIf

	If !lRet
		cProduto := Space( Len( SB1->B1_CODBAR ) )
		VTKeyBoard(Chr(20))
	EndIf

Return lRet

//------------------------------------------------------------------
// Faz a avaliação dos dados lidos, verificando contagens anteriores
//------------------------------------------------------------------
Static Function AvalCont( cEndereco, cProduto, nQtde )

	Local aArea   := GetArea()
	Local nSaldo  := GetSaldo( cProduto, cEndereco, .T., .T. )
	Local nCntAn  := 0
	Local _nH     := 0
	Local _lFound := .F.
	
	If nCont == 1 // Primeira contagem
		
		dbSelectArea("ZAQ")
		dbSetorder(1)
	
		_lFound := dbSeek( xFilial("ZAQ") + cMestre + cEndereco + cProduto + cCont )
	
		RecLock( "ZAQ",!_lFound )

			If !_lFound
				ZAQ->ZAQ_FILIAL := xFilial("ZAQ")
				ZAQ->ZAQ_MESTRE := cMestre
				ZAQ->ZAQ_CONTAG := cCont
				ZAQ->ZAQ_PRODUT := cProduto
				ZAQ->ZAQ_ENDER  := cEndereco
				ZAQ->ZAQ_SALDO  := nSaldo
				ZAQ->ZAQ_DTANAL := CtoD("//")
				ZAQ->ZAQ_HRANAL := ""
				ZAQ->ZAQ_USER   := RetCodUsr()
			EndIf
	
			ZAQ->ZAQ_QUANT  := nQtde
			ZAQ->ZAQ_DTCONT := dDataBase
			ZAQ->ZAQ_HRCONT := Left( Time(), 5 )
			ZAQ->ZAQ_STATUS := Iif( nSaldo != nQtde, "D", "*" )
	
		MsUnLock()
		
	ElseIf nCont > 1 // Contagens seguintes
	
		dbSelectArea("ZAQ")
		dbSetorder(1)

		If dbSeek( xFilial("ZAQ") + cMestre + cEndereco + cProduto + cCont ) // Contagem atual
		
			RecLock( "ZAQ", .F. )
	
				ZAQ->ZAQ_QUANT  := nQtde
				ZAQ->ZAQ_DTCONT := dDataBase
				ZAQ->ZAQ_HRCONT := Left( Time(), 5 )
				// Contagem = Saldo : OK | Contagem <> Saldo = Contagem anterior : NOK | Contagem <> Saldo <> Contagem anterior : DIVERG
				ZAQ->ZAQ_STATUS := Iif( nSaldo != nQtde, Iif( nCntAn == nQtde, "N", "D" ), "*" )
	
			MsUnLock()
		
		EndIf
		
	EndIf

	RestArea( aArea )

Return

//--------------------------------------------------
// Retorna o saldo do produto no endereço, por local
//--------------------------------------------------
Static Function GetSaldo( cProd, cEnd, lL01, lL02 )

	Local aArea   := GetArea()
	Local _nSaldo := 0
	
	dbSelectArea("SBF")
	dbSetOrder(1)

	If lL01 .And. dbSeek( xFilial("SBF") + "01" + cEnd + cProd )
		_nSaldo += SBF->BF_QUANT
	EndIf
	
	If lL02 .And. dbSeek( xFilial("SBF") + "02" + cEnd + cProd )
		_nSaldo += SBF->BF_QUANT
	EndIf
	
	RestArea( aArea )

Return( _nSaldo )

//--------------------------------------------------------------------
// Retorna a quantidade da contagem anterior para o produto / endereço
//--------------------------------------------------------------------
Static Function GetCntAnt( cEnder, cProd )

	Local _nCntAnt := 0
	Local _aArea   := ZAQ->( GetArea() )
	
	dbSelectArea("ZAQ")
	dbSetOrder(1)
	If dbSeek( xFilial("ZAQ") + cMestre + cEnder + cProd + cValToChar( nCont - 1 ) )
		_nCntAnt := ZAQ->ZAQ_QUANT
	EndIf
	RestArea( _aArea )

Return( _nCntAnt )

//-----------------------------------------------------------------------------------------------
// Faz a finalização do endereço, verificando se ficaram itens não lidos na contagem para o mesmo
//-----------------------------------------------------------------------------------------------
Static Function FinalEnd( cEnder )
	
	Local _cQuery := ""
	Local _cAlias := ""
	Local _aArea  := GetArea()
	
	_cQuery := "SELECT * "
	_cQuery += " FROM "+ RetSqlName("ZAQ")
	_cQuery += " WHERE ZAQ_FILIAL  = '"+ xFilial("ZAQ") +"' "
	_cQuery += "   AND ZAQ_MESTRE  = '"+ cMestre +"' "
	_cQuery += "   AND ZAQ_CONTAG  = '"+ cCont   +"' "
	_cQuery += "   AND ZAQ_ENDER   = '"+ cEnder  +"' "
	_cQuery += "   AND ZAQ_STATUS  = 'X' "
	_cQuery += "   AND D_E_L_E_T_  = ' ' "
	
	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	
	While !(_cAlias)->( Eof() )
		
		ZAQ->( dbGoTo( (_cAlias)->R_E_C_N_O_ ) )
		ZAQ->( RecLock("ZAQ",.F.) )
			ZAQ->ZAQ_STATUS := Iif( Empty( (_cAlias)->ZAQ_PRODUT ), "*", Iif( (_cAlias)->ZAQ_QUANT == (_cAlias)->ZAQ_SALDO, "N", "D" ) )
			ZAQ->ZAQ_DTCONT := dDataBase
			ZAQ->ZAQ_HRCONT := Left( Time(), 5 )
		ZAQ->( MsUnLock() )
		
		(_cAlias)->( dbSkip() )
	End
	
	(_cAlias)->( dbCloseArea() )

	RestArea( _aArea )
	
Return
