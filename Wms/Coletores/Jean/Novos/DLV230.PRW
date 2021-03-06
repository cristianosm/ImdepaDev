#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APVT100.CH"
/*
Jean Rehermann - Solutio IT - 23/10/2017
Programa para manuten��o de pallet de volumes de embarque
*/
User Function DLV230()

	Local bkey09 := VTSetKey(09,{|| D230Hist()},"Informacoes") // CTRL+I
	Local bKey24 := VTSetKey(24,{|| Estorna()},"Estorno") // CTRL+X
	Local _nOpt := 0
	Local aTela  := {}

	aTela := VtSave()
	VtClearBuffer()
	VTClear()
	
	_nOpt := DLVTAviso("Pallet de Volumes","Escolha uma op��o", {"Monta Novo Pallet","Inclui Volume","Estorna Volume"})

	If _nOpt == 1
		D230New()
    ElseIf _nOpt == 2
        D230Inc()
    ElseIf _nOpt == 3
    	D230Est()
    EndIf
	
	Vtsetkey( 09, bkey09 )
	Vtsetkey( 24,bkey24 )
	VtRestore(,,,,aTela)

Return

// Efetua a inclus�o de um novo pallet
Static Function D230New()

	Private aHisEti:= {}
	Private cEti   := Space( TamSX3("D00_CODVOL")[1] + 1 )
	
	While .T.
	 
		cEti   := Space( TamSX3("D00_CODVOL")[1] + 1 )
	   
		VTClear()
		@ 0,0 VTSay "Monta Palet Embarque"
		@ 2,0 VTSay "Volume  :"  VTGet cEti pict '@!' Valid VldEti(cEti) .And. !Empty(aHisEti)
		VTRead                               
		
		// Valida quando digitar [ESC]
		If VTLastKey() == 27 .and. Empty(aHisEti)
			Exit
		ElseIf VTLastKey() == 27 .and. !Empty(aHisEti)
	    	If VTYesNo("Aborta a operacao ?","Pergunta",.T.)
				Exit
			Else
				Loop
			EndIf
		EndIf
		
		If VTYesNo("Confirma geracao do Pallet ?","Pergunta",.T.)
			GeraPallet()
		Else
			Loop
		EndIf

		aHisEti := {}

	Enddo

Return

// Valida o volume lido
Static Function VldEti( cEti )

	Local nPos
	Local aVol := {}
	Local cEti := AllTrim( cEti )
	
	If Empty( cEti )
		Return .T.
	Endif
	
	If Len( cEti ) != 10
	   VTBeep(2)
	   VTAlert("Etiqueta de volume inv�lida","Aviso",.t.,2000)
	   VtClearGet("cEti")
	   Return .F.
	Endif

	// Valida se o volume j� foi inserido em um pallet ou embarcado
	aVol := ChkPallet( cEti )
	
	If Empty( aVol )
		VTBeep(2)
		VTAlert("Volume n�o encontrado","Aviso",.T.,2000)
		VtClearGet("cEti")
		Return .F.
	ElseIf Len( aVol ) > 1
		VTBeep(2)
		VTAlert("Mais de um volume com mesmo c�digo","Aviso",.T.,2000)
		VtClearGet("cEti")
		Return .F.
	ElseIf !Empty( aVol[ 1, 3 ] ) // Data de Embarque
		VTBeep(2)
		VTAlert("Volume j� foi embarcado em "+ CtoD( StoD( aVol[ 1, 3 ] ) ),"Aviso",.T.,2000)
		VtClearGet("cEti")
		Return .F.
	ElseIf !Empty( aVol[ 1, 2 ] ) // Pallet
		VTBeep(2)
		VTAlert("Volume j� pertence ao pallet "+ aVol[ 1, 2 ],"Aviso",.T.,2000)
		VtClearGet("cEti")
		Return .F.
	EndIf
	
	nPos := Ascan( aHisEti, { |x| x == cEti } )
	
	If nPos > 0	
		VTBeep(2)
		VTAlert("Volume ja informado","Aviso",.T.,2000)
		VtClearGet("cEti")
		Return .F.
	Endif
	
	aAdd( aHisEti, cEti ) // Passou pelas valida��es, portanto entra no array das etiquetas lidas
	
	VtClearGet("cEti")

Return .F. // Quando passa pelas valida��es e inclui o volume no array, permanece no campo para nova leitura, por isso sempre retorna .F. ao final

// Verifica se o volume lido j� pertence a um pallet ou se j� foi embarcado
Static Function ChkPallet( cId )

	Local aItens := {}
	Local _cQuery := ""
	Local _cAlias := ""
	Local _aArea  := GetArea()
	Local cId     := AllTrim( cId )
	
	_cQuery := "SELECT D00_CODVOL, D00_PALLET, D00_DATEMB "
	_cQuery += " FROM "+ RetSqlName("D00")
	_cQuery += " WHERE D00_FILIAL  = '"+ xFilial("D00") +"' "
	_cQuery += "   AND D00_CODVOL  = '"+ cId +"' "
	_cQuery += "   AND D_E_L_E_T_  = ' ' "
	
	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	
	While !(_cAlias)->( Eof() )
		
		aAdd( aItens, { (_cAlias)->D00_CODVOL, (_cAlias)->D00_PALLET, (_cAlias)->D00_DATEMB } )
		
		(_cAlias)->( dbSkip() )
	End
	
	(_cAlias)->( dbCloseArea() )

Return( aItens )

// Efetua a amarra��o dos volumes em pallet para embarque
Static Function GeraPallet()

	Local cPallet := ""
	Local lSaiu   := .F.
	
	While .T.
		
		cPallet := Space( Len( D00->D00_PALLET ) + 1 )
		
		VTClear()
		DLVTCabec("Gerar Pallet", .F., .F., .T.)
			@ 02, 00 VTSay PadR("Ler Etiqueta Pallet", VTMaxCol())
			@ 04, 00 VTGet cPallet Picture "@!" Valid ValPallet( cPallet )
		VTRead
		
		If VTLastKey() == 27
			If DLVTAviso( "Aviso", "Deseja cancelar a opera��o?", {"Sim","N�o"} ) == 1
				lSaiu := .T.
				Exit
			EndIf
		EndIf

		If !Empty( cPallet )
			cPallet := AllTrim( cPallet )
			Exit
		EndIf
		
	EndDo
	
	If !lSaiu
		For _nX := 1 To Len( aHisEti )
			// Grava o pallet no registro de volume D00
			GrvPallet( AllTrim( cPallet ), aHisEti[ _nX ], .T. )
		Next
		If DLVTAviso( "Aviso", "Libera o(s) pedido(s) ?", {"Sim","N�o"} ) == 1
			LibPvPlt()
		EndIf
	Else
		VTClear()
		DLVTCabec("Gerar Pallet", .F., .F., .T.)
			@ 02, 00 VTSay PadC("Cancelado", VTMaxCol())
			@ 03, 00 VTSay " ------------------ "
		DLVTRodaPe()	    
	EndIf
	
Return

// Valida o codigo da etiqueta de pallet lida
Static Function ValPallet( cCodPalet )

	Local _lRet := .T.
	Local _nProxCod := Val( Getmv("IMD_VPALET") )
	
	If Len( AllTrim( cCodPalet ) ) != 8
		VTBeep(2)
		VTAlert("Numera��o de pallet inv�lida - 8 caracteres","Aviso",.T.,2000)
		VtClearGet("cPallet")
		_lRet := .F.
	EndIf

	If Val( cCodPalet ) > _nProxCod
		VTBeep(2)
		VTAlert("Numera��o de pallet ainda n�o gerada etiqueta","Aviso",.T.,2000)
		VtClearGet("cPallet")
		_lRet := .F.
	EndIf
	
	If Val( cCodPalet ) == 0
		VTBeep(2)
		VTAlert("Numera��o inv�lida de etiqueta","Aviso",.T.,2000)
		VtClearGet("cPallet")
		_lRet := .F.
	EndIf

	If _lRet .And. VerPltNovo( AllTrim( cCodPalet ), .F. ) > 0
		VTBeep(2)
		VTAlert("Numera��o de pallet j� existente","Aviso",.T.,2000)
		VtClearGet("cPallet")
		_lRet := .F.
	EndIf

Return( _lRet )

// Verifica se o c�digo de Pallet informado j� foi utilizado
Static Function VerPltNovo( cPallet, lEmb )

	Local _nQtReg := 0
	Local _cQuery := ""
	Local _cAlias := ""
	Local _aArea  := GetArea()

	_cQuery := "SELECT COUNT(*) QTDREG "
	_cQuery += " FROM "+ RetSqlName("D00")
	_cQuery += " WHERE D00_FILIAL = '"+ xFilial("D00") +"'"
	_cQuery += "   AND D00_PALLET = '"+ AllTrim( cPallet ) +"' "
	_cQuery += "   AND D_E_L_E_T_ = ' '"

	If lEmb
		_cQuery += "   AND D00_DATEMB = ' ' "		
	EndIf

	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	_nQtReg := (_cAlias)->QTDREG
	(_cAlias)->( dbCloseArea() )

	RestArea( _aArea )

Return( _nQtReg )

// Grava o pallet no registro de volume D00
Static Function GrvPallet( cPallet, cVolume, lInclui )

	Local cSql := ""

	cSql := "UPDATE "+ RetSqlName("D00")
	cSql += " SET D00_PALLET = '"+ Iif( lInclui, AllTrim( cPallet ), " " ) +"' "
	cSql += " WHERE D_E_L_E_T_ = ' ' "
	cSql += " AND D00_FILIAL = '"+ xFilial("D00") +"'"
	cSql += " AND D00_CODVOL = '"+ AllTrim( cVolume ) +"'"
	
	TCSQLExec( cSql )
	TCSQLExec('COMMIT')

Return

// Estorna o volume que foi adicionado na lista de volumes a ser tratado (montagem ou manuten��o de pallet)
Static Function Estorna()

	Local aTela := VTSave()
	Local cEtiq := Space( TamSX3("D00_CODVOL")[1] + 1 )
	
	VTClear()
	
	@ 00,00 VtSay "Estorno de Volume"
	@ 02,00 VtGet cEtiq Pict "@!" Valid VldEstorno(cEtiq)
	VtRead
	
	VtRestore(,,,,aTela)

Return

// Valida o estorno de um volume do pallet que est� sendo montado
Static Function VldEstorno(cEti)

	Local nPos
	
	If Empty(cEti)
		Return .f.
	EndIF
	
	nPos:= Ascan(aHisEti,{|x| AllTrim(x) == AllTrim(cEti)})
	
	If nPos == 0
	   VTBeep(2)
	   VTALERT("Volume nao encontrado","Aviso",.T.,2000)
	   VtKeyboard(Chr(20))
	   Return .f.
	Endif
	
	If ! VTYesNo("Confirma o estorno do volume ?","Atencao",.t.)
		VtKeyboard(Chr(20))
		Return .F.
	EndIf
	
	While .t.
	  
		nPos:= Ascan(aHisEti,{|x| AllTrim(x) == AllTrim(cEti)})
		
		If nPos == 0
			Exit
		Endif
		
		aDel(aHisEti,nPos)
		aSize(aHisEti,Len(aHisEti)-1)
		
		VtKeyboard(Chr(20))
	Enddo

Return .F.

// Exibe todos os volumes lidos para este pallet at� o momento
Static Function D230Hist()

	Local aSave := VTSAVE()
	Local aCab  := {"Volume"}
	Local aSize := {30}
	Local aItem := {}
	Local nX
	
	For nX:= 1 to Len(aHisEti)
      aAdd(aItem,{aHisEti[nX]})   
	Next
	   
	VtClear()
	@ 0,0 VTSay "Etiqueta(s) Lida(s):"
	VTaBrowse(2,0,7,19,aCab,aItem,aSize)	
	If VtLastKey() == 27
	   VtRestore(,,,,aSave)
	Endif
	VtRestore(,,,,aSave)

Return

// Fun��o para incluir volumes em pallets j� montados
Static Function D230Inc()
	D230Manut(.T.)
Return()

// Fun��o para estornar volumes de pallets j� montados
Static Function D230Est()
	D230Manut(.F.)
Return

// Fun��o �nica para tratar inclus�o e estorno
Static Function D230Manut( lInclusao )

	Local   cTexto := " "
	Local   aTela  := {}
	Local   nLin   :=0
	
	Private aHisEti:= {}
	Private cEti   := Space(TamSX3("D00_CODVOL")[1]+1)
	Private cPallet:= Space(TamSX3("D00_PALLET")[1]+1)
	
	VTClear()            
	
	While .T.   

		nLin := 0	

		@ nLin,0 VTSay "Manutencao de Pallet"
		@ ++nLin,0 VTSay If( lInclusao,"Inclusao:","Exclusao")
		@ ++nLin,0 VTSay "Pallet"
		@ ++nLin,0 VTGet cPallet Pict '@!' Valid VldPallet( AllTrim( cPallet ) ) When Empty(cPallet) 
		@ ++nLin,0 VTSay "Volume"
		@ ++nLin,0 VTGet cEti Pict '@!' Valid VldManEti( AllTrim( cEti ),lInclusao) .And. !Empty(aHisEti) 
		VTRead                               
		
		If VTLastKey() == 27 .and. Empty(aHisEti)
			Exit
		EndIf
		
		If lInclusao
			cTexto:= "Confirma a inclus�o do(s) volume(s) ?"
		Else
			cTexto:= "Confirma o estorno do(s) volume(s) ?"
		Endif
		
		If VTYesNo(cTexto,"Pergunta",.t.)
			Manutencao( lInclusao )
		Else
			If VTYesNo('Abortar a opera��o ?','Pergunta',.T.)
				Exit   
			EndIf
			Loop   
		EndIf
		
		cPallet:= Space(TamSX3("D00_PALLET")[1]+1)
		aHisEti:= {}
	
	Enddo
	
Return

// Valida se existe Pallet lido na manuten��o (inclus�o e estorno de volumes)
Static Function VldPallet( cPallet )

	Local _nQtd := VerPltNovo( AllTrim( cPallet ), .T. )

	If _nQtd == 0
		VTBeep(2)
		VTAlert("Pallet informado n�o existe ou j� embarcado!", "Aviso",.T.,2000)
		VtClearGet("cPallet")
		Return .f.
	EndIf

Return( .T. )

// Valida os volumes lidos na manuten��o do pallet (inclus�o e estorno de volumes)
Static Function VldManEti( cEti, lInclusao )

	Local nPos
	Local aVol
	Local cEti := AllTrim( cEti )
	
	If Empty( cEti )
		Return .T.
	Endif
	
	If Len( cEti ) != 10
	   VTBeep(2)
	   VTAlert("Etiqueta de volume inv�lida","Aviso",.t.,2000)
	   VtClearGet("cEti")
	   Return .F.
	Endif
	
	nPos:= Ascan( aHisEti, { |x| x == cEti } )

	If nPos > 0
		VTBeep(2)
		VTAlert("Etiqueta ja informada","Aviso",.t.,2000)
		VtClearGet("cEti")
		Return .f.
	Endif
	
	// Valida se o volume j� foi inserido em um pallet ou embarcado e se ele existe
	aVol := ChkPallet( cEti ) // [1] Volume - [2] Pallet - [3] Data Embarque
	
	If Empty( aVol )
		VTBeep(2)
		VTAlert("Volume n�o encontrado","Aviso",.T.,2000)
		VtClearGet("cEti")
		Return .F.
	ElseIf Len( aVol ) > 1
		VTBeep(2)
		VTAlert("Mais de um volume com mesmo c�digo","Aviso",.T.,2000)
		VtClearGet("cEti")
		Return .F.
	ElseIf !Empty( aVol[ 1, 3 ] ) // Data de Embarque
		VTBeep(2)
		VTAlert("Volume j� foi embarcado em "+ DtoC( StoD( aVol[ 1, 3 ] ) ) + Iif( !Empty( aVol[ 1, 2 ] ), " no pallet "+ aVol[ 1, 2 ], "" ),"Aviso",.T.,2000)
		VtClearGet("cEti")
		Return .F.
	ElseIf !Empty( aVol[ 1, 2 ] ) .And. lInclusao // Est� em Pallet
		VTBeep(2)
		VTAlert("Volume j� pertence ao pallet "+ aVol[ 1, 2 ],"Aviso",.T.,2000)
		VtClearGet("cEti")
		Return .F.
	ElseIf Empty( aVol[ 1, 2 ] ) .And. !lInclusao // N�o est� em Pallet
		VTBeep(2)
		VTAlert("Volume n�o est� paletizado","Aviso",.T.,2000)
		VtClearGet("cEti")
		Return .F.
	ElseIf !Empty( aVol[ 1, 2 ] ) .And. !lInclusao .And. aVol[ 1, 2 ] != AllTrim( cPallet ) // Est� em Pallet diferente
		VTBeep(2)
		VTAlert("Volume lido pertence a outro pallet","Aviso",.T.,2000)
		VtClearGet("cEti")
		Return .F.
	ElseIf Empty( aVol[ 1, 2 ] ) .And. lInclusao .And. aVol[ 1, 2 ] == AllTrim( cPallet ) // Volume j� est� no pallet
		VTBeep(2)
		VTAlert("Volume lido j� pertence a este pallet","Aviso",.T.,2000)
		VtClearGet("cEti")
		Return .F.
	EndIf

	aAdd( aHisEti, cEti ) // Passou pelas valida��es, portanto entra no array das etiquetas lidas

	VtClearGet("cEti")

Return( .F. )

// Efetua a atualiza��o dos pallets nos volumes
Static Function Manutencao( lInclusao )

	For _nX := 1 To Len( aHisEti )
		// Grava ou apaga o pallet no registro de volume D00
		GrvPallet( cPallet, aHisEti[ _nX ], lInclusao )
	Next

Return

// Efetua a libera�ao do pedido (legenda de pallet)
Static Function LibPvPlt()

	Local _aAreaATU := GetArea()
	Local _aAreaSC9 := SC9->( GetArea() )
	Local _aPedPal  := {}
	
	For _nQ := 1 To Len( aHisEti )
	
		dbSelectArea("ZCU")
		dbSetOrder(1)
		If dbSeek( xFilial("ZCU") + aHisEti[ _nQ ] )
			If aScan( _aPedPal, {|o| o == ZCU->ZCU_PEDIDO } ) == 0
				aAdd( _aPedPal, ZCU->ZCU_PEDIDO )
			EndIf
		EndIf
	Next
	
	For _nQ := 1 To Len( _aPedPal )

		dbSelectArea("SC9")
		dbSetOrder(1)
		If dbSeek( xFilial("SC9") + _aPedPal[ _nQ ] )
			While !SC9->( Eof() ) .And. SC9->C9_FILIAL + SC9->C9_PEDIDO = xFilial("SC9") + _aPedPal[ _nQ ]
				RecLock("SC9",.F.)
					SC9->C9_AGREG := "    "
				SC9->( MsUnlock() )
				
				SC9->( dbSkip() )
			End
			If !U_MailPvWms( _aPedPal[ _nQ ] ) // Envia o e-mail informando que o pedido est� liberado para faturamento
				MsgAlert("Erro ao enviar o e-mail. Favor avisar o faturista para faturar o pedido "+ _aPedPal[ _nQ ] )
			EndIf
		EndIf
    Next
    
	RestArea( _aAreaATU )
	RestArea( _aAreaSC9 )

Return