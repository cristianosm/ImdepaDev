#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "APVT100.CH"
/*
Jean Rehermann - Solutio IT - 17/10/2017
Programa para embarque com conferência de volumes
*/
User Function DLV103()

	Local bkey09 := VTSetKey(09)          
	Local bkey22 := VTSetKey(22)
	Local bkey24 := VTSetKey(24)
	Local cKey09 := VtDescKey(09)
	Local cKey22 := VtDescKey(22)
	Local cKey24 := VtDescKey(24)
	
	Local aTela   := {}
	Local nAviso  := 0
	Local cDanfe  := Space(45)
	Local cVolume := Space( Len( ZCU->ZCU_CODVOL ) + 1 )

	Private aEmbarque := {}
	Private aPallets  := {}
	Private aNotas    := {}
	Private nLidos    := 0
	Private nLer      := 0
	Private cCodOpe   := __cUserID

	aTela := VtSave()
	VtClearBuffer()
			
	While .T.
		
		VTClear()
		
		aEmbarque := {}
		aPallets  := {}
		aNotas    := {}
		nAviso    := 0
		nLidos    := 0
		nLer      := 0
		cCodOpe   := __cUserID
		
		While .T.
			
			cDanfe  := Space(45)
			
			VTClear()
			DLVTCabec("Embarque", .F., .F., .T.)
				@ 02, 00 VTSay PadR("Ler Danfe", VTMaxCol())
				@ 03, 00 VTGet cDanfe Valid RetNfVol( cDanfe ) // Valida se a nota existe, e baseado nos pedidos, alimenta array com os volumes
			VTRead
		
			If VTLastKey() == 27
				Exit
			EndIf        
		
		EndDo
		
		If Len( aEmbarque ) > 0

			nLer := Len( aEmbarque )
			
			While .T.
				
				cVolume := Space( Len( ZCU->ZCU_CODVOL ) + 1 )
				
				VTClear()
				DLVTCabec("Embarque "+ cValToChar(nLidos) +" de "+ cValToChar(nLer), .F., .F., .T.)
					@ 02, 00 VTSay PadR("Ler Volume/Pallet", VTMaxCol())
					@ 04, 00 VTGet cVolume Picture "@!" Valid ValVolum( cVolume )
				VTRead
				
				// Ao teclar [ESC] avisa que faltam volumes a embarcar, porém permite zerar, retomar ou finalizar o embarque
				If VTLastKey() == 27 .And. nLidos != nLer
					nAviso := DLVTAviso("Aviso","Embarque não finalizado!", {"Continuar","Abandonar","Embarcar"})
					If nAviso != 1
						Exit
					Else
						nAviso := 0
					EndIf
				EndIf
				
				// Finaliza sozinho ao ler o último volume
				If nLidos == nLer
					Exit
				EndIf
				
			EndDo	

		Else
			Exit
		EndIf
				
		VTClear()
		DLVTCabec("Embarque", .F., .F., .T.)

		If nAviso == 3 .Or. ( nAviso == 0 .And. VTLastKey() != 27 )
		
			FinalEmb() // Finaliza o embarque
			
			@ 01, 00 VTSay PadC("Finalizado", VTMaxCol())
			@ 02, 00 VTSay " ------------------ "
			@ 03, 00 VTSay PadR("Embarque Finalizado", VTMaxCol())
			@ 04, 00 VTSay " ------------------ "
			@ 05, 00 VTSay PadR("ENTER=Cont./ESC=Sair", VTMaxCol())

		ElseIf nAviso == 2 .Or. ( nAviso == 0 .And. VTLastKey() == 27 )

			aEmbarque := {} // Quando o embarque é cancelado todas as leituras são desconsideradas e o embarque não é realizado
			
			@ 01, 00 VTSay PadC("Cancelado", VTMaxCol())
			@ 02, 00 VTSay " ------------------ "
			@ 03, 00 VTSay PadR("Embarque Cancelado", VTMaxCol())
			@ 04, 00 VTSay " ------------------ "
			@ 05, 00 VTSay PadR("ENTER=Cont./ESC=Sair", VTMaxCol())
			
		EndIf
		
		DLVTRodaPe()	    

		If VTLastKey() == 27 
			Exit
		EndIf

	   VTKeyBoard(Chr(20))

	EndDo
			
	//Restaura teclas
	VTSetKey(09,bkey09,cKey09)
	VTSetKey(22,bkey22,cKey22)
	VTSetKey(24,bkey24,cKey24)   
	VtRestore(,,,,aTela)

Return

// Valida o chave e retorna array com todos os volumes da nota fiscal de acordo com seu(s) pedido(s) de venda
Static Function RetNfVol( cDanfe )

	Local cNumDanfe := AllTrim( cDanfe )
	Local cSerie    := "I"+ cFilAnt
	Local lRet      := .T.
	Local aRetVol   := {}
	Local aVolumes  := {}
	Local aPedidos  := {}
	Local cNota     := ""
	Local _nI := _nX := _nY := 0
	
	If Len( cNumDanfe ) == 44
		
		cNota := SubStr( cNumDanfe, 26, 09 )
		
		If aScan( aNotas, { |o| o == cNota + cSerie } ) == 0
		
			If SF2->( dbSeek( xFilial("SF2") + cNota + cSerie ) )
	
				aPedidos := RetPedido( cNota + cSerie )
	
				For _nX := 1 To Len( aPedidos )
					
					aRetVol := RetVolume( aPedidos[ _nX ] )
					
					For _nI := 1 To Len( aRetVol )
						aAdd( aVolumes, aRetVol[ _nI ] )
					Next
					
				Next
				
				For _nY := 1 To Len( aVolumes )
				
					aAdd( aEmbarque, {  .F.,;                  // Lido no Embarque .F./.T.
										aVolumes[ _nY, 4 ],;   // Número do pedido
										aVolumes[ _nY, 1 ],;   // Número do volume
										aVolumes[ _nY, 2 ],;   // Recno do volume na D00
										aVolumes[ _nY, 3 ],;   // Pallet do Volume
										cNota + cSerie   } )   // Nota + Série
				Next
				
				nLer := Len( aVolumes )
	
				If nLer == 0
					VTAlert("Não foram encontrados volumes para esta nota!","Erro",.T.,2000 )
					VTKeyBoard(Chr(20))
					lRet := .F.
				Else
					aAdd( aNotas, cNota + cSerie )
				EndIf
	
			Else
				VTAlert("Nota fiscal "+ cNota +"/"+ cSerie +" não encontrada!","Erro",.T.,2000 )
				VTKeyBoard(Chr(20))
				lRet := .F.
			EndIf
		Else
			VTAlert("Nota fiscal "+ cNota +"/"+ cSerie +" já lida neste embarque!","Erro",.T.,2000 )
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
	Else
		VTAlert("Chave de acesso deve ter 44 caracteres!","Erro",.T.,2000 )
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	
Return lRet

// Retorna os números de PV referente à nota fiscal informada
Static Function RetPedido( cNumNf )

	Local aPed := {}
	Local _cQuery := ""
	Local _cAlias := ""
	Local _aArea  := GetArea()
	
	_cQuery := "SELECT DISTINCT(D2_PEDIDO) D2_PEDIDO "
	_cQuery += " FROM "+ RetSqlName("SD2")
	_cQuery += " WHERE D2_FILIAL  = '"+ xFilial("SD2")     +"' "
	_cQuery += "   AND D2_DOC     = '"+ Left( cNumNf, 9 )  +"' "
	_cQuery += "   AND D2_SERIE   = '"+ Right( cNumNf, 3 ) +"' "
	_cQuery += "   AND D_E_L_E_T_ = ' ' "
	
	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	
	While !(_cAlias)->( Eof() )
		
		aAdd( aPed, (_cAlias)->D2_PEDIDO )
		
		(_cAlias)->( dbSkip() )
	End
	
	(_cAlias)->( dbCloseArea() )
	
	RestArea( _aArea )

Return( aPed )

// Retorna os volumes referente ao pedido informado
Static Function RetVolume( cNumPv )

	Local aVol := {}
	Local _cQuery := ""
	Local _cAlias := ""
	Local _aArea  := GetArea()
	
	_cQuery := "SELECT DISTINCT(D00_CODVOL) D00_CODVOL, R_E_C_N_O_, D00_PALLET "
	_cQuery += " FROM "+ RetSqlName("D00")
	_cQuery += " WHERE D00_FILIAL  = '"+ xFilial("D00") +"' "
	_cQuery += "   AND D00_PEDIDO  = '"+ cNumPv +"' "
	_cQuery += "   AND D00_DATEMB  = ' ' "
	_cQuery += "   AND D_E_L_E_T_  = ' ' "
	
	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	
	While !(_cAlias)->( Eof() )
		
		aAdd( aVol, { (_cAlias)->D00_CODVOL, (_cAlias)->R_E_C_N_O_, (_cAlias)->D00_PALLET, cNumPv } )
		
		(_cAlias)->( dbSkip() )
	End
	
	(_cAlias)->( dbCloseArea() )
	
	RestArea( _aArea )

Return( aVol )

// Valida o volume ou pallet lido para embarque
Static Function ValVolum( cCodVol )

	Local _lRet   := .T.
	Local _nPos   := 0
	Local cCodVol := AllTrim( cCodVol )
	Local _nTam   := Len( cCodVol )
	Local _lPal   := _nTam == 8
	Local aPallet := {}
	
	If _nTam != 8 .And. _nTam != 10
		VTAlert("Código inválido para volume ou pallet!","Erro",.T.,2000 )
		VTKeyBoard(Chr(20))
		_lRet := .F.
	EndIf
	
	If _lRet .And. _nTam == 10 // Lido código de volume
		
		_nPos := aScan( aEmbarque, { |o| o[3] == cCodVol } )
		
		If _nPos > 0 .And. !Empty( aEmbarque[ _nPos, 5 ] )
			VTAlert("Volume está paletizado, não pode ser lido!","Erro",.T.,2000 )
			VTKeyBoard(Chr(20))
			_lRet := .F.
		ElseIf _nPos > 0 .And. aEmbarque[ _nPos, 1 ]
			VTAlert("Volume já foi lido para este embarque!","Erro",.T.,2000 )
			VTKeyBoard(Chr(20))
			_lRet := .F.
		ElseIf _nPos == 0
			VTAlert("Volume não pertence a nenhuma nota fiscal lida!","Erro",.T.,2000 )
			VTKeyBoard(Chr(20))
			_lRet := .F.
		EndIf                      
		
	EndIf
	
	If _lRet
		If _nTam == 8 // Pallet
			If aScan( aPallets, { |o| o == cCodVol } ) > 0
				VTAlert("Pallet já foi lido para este embarque!","Erro",.T.,2000 )
				VTKeyBoard(Chr(20))
				_lRet := .F.
			Else
				
				aAdd( aPallets, cCodVol )
				
				aPallet := GetVolPal( cCodVol ) // Busca todos os volumes contidos no pallet
				
				For _nX := 1 To Len( aPallet )
					
					_nPos := aScan( aEmbarque, { |o| o[3] == aPallet[ _nX ] } )
					
					If _nPos > 0 .And. !aEmbarque[ _nPos, 1 ]
						aEmbarque[ _nPos, 1 ] := .T.
						nLidos++
					ElseIf _nPos == 0
						VTAlert("Verificar volume "+ aPallet[ _nX ] +" no pallet "+ cCodVol +" não pertence a nenhuma nota fiscal lida!","Erro",.T.,4000 )
						VTKeyBoard(Chr(20))
					EndIf
				Next
				
			EndIf
		Else // volume
			
			_nPos := aScan( aEmbarque, { |o| o[3] == cCodVol } )
			
			If _nPos > 0 .And. !aEmbarque[ _nPos, 1 ]
				aEmbarque[ _nPos, 1 ] := .T.
				nLidos++
			EndIf
		EndIf
	EndIf
	
Return( _lRet )

// Retorna todos os volumes contidos no pallet
Static Function GetVolPal( cId )

	Local aItens := {}
	Local _cQuery := ""
	Local _cAlias := ""
	Local _aArea  := GetArea()
	
	_cQuery := "SELECT DISTINCT(D00_CODVOL) D00_CODVOL "
	_cQuery += " FROM "+ RetSqlName("D00")
	_cQuery += " WHERE D00_FILIAL  = '"+ xFilial("D00") +"' "
	_cQuery += "   AND D00_PALLET  = '"+ cId +"' "
	_cQuery += "   AND D00_DATEMB  = ' ' "
	_cQuery += "   AND D_E_L_E_T_  = ' ' "
	
	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	
	While !(_cAlias)->( Eof() )
		
		aAdd( aItens, (_cAlias)->D00_CODVOL )
		
		(_cAlias)->( dbSkip() )
	End
	
	(_cAlias)->( dbCloseArea() )
	
	RestArea( _aArea )

Return( aItens )

// Realiza a gravação do embarque, sinalizando os volumes
Static Function FinalEmb()

	Local aArea := GetArea()
	
	For _nX := 1 To Len( aEmbarque )
		If aEmbarque[ _nX, 1 ]
			D00->( dbGoTo( aEmbarque[ _nX, 4 ] ) )
			D00->( RecLock("D00",.F.) )
			D00->D00_OPEEMB := cCodOpe
			D00->D00_DATEMB := dDataBase
			D00->D00_HOREMB := Left( Time(), 5 )
			D00->( MsUnLock() )
		EndIf
	Next
	
	RestArea( aArea )

Return