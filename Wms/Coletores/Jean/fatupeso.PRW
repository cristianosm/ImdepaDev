#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FatuPeso  ³ Autor ³ Cristiano Machado     ³ Data ³03/06/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*********************************************************************
User Function FatuPeso(cPar1,cPar2,cPar3)
*********************************************************************

	Private cEspecie	:= Space(25)
	Private nVolume	 	:= 0
	Private nPesob	 	:= 0
	Private nPesol	 	:= 0
	Private VISUAL 		:= .F.
	Private INCLUI 		:= .F.
	Private ALTERA 		:= .F.
	Private DELETA 		:= .F.
	Private cNota 		:= cPar1
	Private cSerie		:= cPar2
	Private cPar		:= cPar3
	Private cPlaca  	:= Space(25)
	Private cPlaca2  	:= Space(25)
	Private cTransp  	:= Space(06)

	Private oTransp
	Private ocEspecie
	Private ocVolume
	Private onPesob
	Private onPesol
	Private _oDlg
	Private ocPlaca
	Private ocPlaca2
	Private cNumPed
	Private cImdepa 	:= GetMV('MV_IMDEPA')       // Cliente Tranferência
	Private lLibTransp  :=.F.
	Private cDescTransp

	lConDad := nil
/*
cNota := "000001"
cSerie := "I02"
*/
	nOrd_SF2 := SF2->( IndexOrd() )
	nRec_SF2 := SF2->( RecNo() )

	nOrd_SD2 := SD2->( IndexOrd() )
	nRec_SD2 := SD2->( RecNo() )

	nOrd_SB1 := SB1->( IndexOrd() )
	nRec_SB1 := SB1->( RecNo() )

	nOrd_SC5 := SC5->( IndexOrd() )
	nRec_SC5 := SC5->( RecNo() )


	DbSelectArea("SB1");Dbsetorder(1)
	DbSelectArea("SF2");DbSetOrder(1)

	If !Dbseek(xFilial("SF2")+cNota+CSerie,.F.)
		Return()
	Endif

	DbSelectArea("SD2");DbSetOrder(3)
	Dbseek(xFilial("SD2")+cNota+CSerie,.F.)
	cNumPed:=SD2->D2_PEDIDO
	lLibTransp:=IIf(cImdepa==SD2->D2_CLIENTE,.T.,.F.)

	While cFilAnt+cNota+CSerie == xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE
	
		SB1->(Dbseek(xFilial("SB1")+SD2->D2_COD,.F.))
	
		nPesoB += SB1->B1_PESBRU	*	SD2->D2_QUANT
		nPesoL += SB1->B1_PESO 		* 	SD2->D2_QUANT
	
		DbSelectArea("SD2")
		Dbskip()
	
	Enddo

	DbSelectArea("SC5");Dbsetorder(1)
	DbSeek(xFilial("SC5")+cNumPed)
	cTransp     :=SC5->C5_TRANSP
	cDescTransp:=Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME")

//If SF2->F2_PLIQUI == 0 .or. SF2->F2_PBRUTO == 0 .or. SF2->F2_VOLUME1 == 0 .or. Empty(SF2->F2_ESPECI1)
	
	// Jean Rehermann - Solutio IT - 09/02/2018 - Verificar os volumes e pallets nas tabelas ZCU, ZCV e D00
	nVolumeZCU := GetVolD00( SF2->F2_DOC )

	nVolume := Iif( nVolumeZCU == 0, SF2->F2_VOLUME1, nVolumeZCU )
	//nVolume := SF2->F2_VOLUME1
	cEspeci := SF2->F2_ESPECI1
	If Empty( cEspecie )
		cEspecie := "VOL"
	EndIf

	If SF2->F2_PLIQUI == 0
		nPesoL := SF2->F2_PLIQUI
	EndIF
	If SF2->F2_PBRUTO == 0
		nPesoB := SF2->F2_PBRUTO
	EndIF
	If nPesoB == 0
		// Jean Rehermann - Solutio IT - 09/02/2018 - Faz o correto arredondamento do peso bruto
		nPesoB := Int( nPesoL ) + 1
	EndIf
	If lConDad == nil
		Tela()
	Elseif lConDad
		Tela()
	Endif
	
//Endif   

	Dbselectarea("SB1")
	Dbsetorder(nOrd_SB1)
	Dbgoto(nRec_SB1)

	Dbselectarea("SD2")
	DbSetOrder(nOrd_SD2)
	Dbgoto(nRec_SD2)

	Dbselectarea("SF2")
	DbSetOrder(nOrd_SF2)
	Dbgoto(nRec_SF2)


	Dbselectarea("SC5")
	DbSetOrder(nOrd_SC5)
	Dbgoto(nRec_SC5)

Return()
*********************************************************************
Static function Tela()
*********************************************************************

//DEFINE MSDIALOG _oDlg TITLE "Dados Adicionais NF" FROM C(300+15),C(300+15) TO C(550),C(660) PIXEL
	DEFINE MSDIALOG _oDlg TITLE "Dados Adicionais NF" FROM C(300+15),C(300+15) TO C(550+30),C(660+30) PIXEL

	@ C(030),C(010) TO C(115),C(170) LABEL "Preencher Dados da Nf:"+cNota PIXEL OF _oDlg

	@ C(005),C(015) Say 	"Esta rotina tem o objetivo de preencher dados adicionais para a Nota Fiscal." 	Size C(195),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(015),C(015) Say 	"Estes dados irão ser armazenados no Cabeçalho da Nota Fiscal." 		   		Size C(196),C(008) COLOR CLR_BLACK PIXEL OF _oDlg

	@ C(040),C(015) Say 	"Peso Liquido:" 										Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg
	@ C(040),C(045) MsGet 	onPesol 	Var nPesol 	Picture("@E 999,999,999.99") 	Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg

	@ C(040),C(095) Say 	"Peso Bruto:" 											Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg
	@ C(040),C(125) MsGet 	onPesob 	Var nPesob 	Picture("@E 999,999,999.99")  	Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg

	@ C(060),C(015) Say 	"Especie:" 												Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg
	@ C(060),C(045) MsGet 	ocEspecie 	Var cEspecie 								Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg

	@ C(060),C(095) Say 	"Volume:" 												Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg
	@ C(060),C(125) MsGet 	ocVolume 	Var nVolume Picture("@E 99999")  			Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg

	@ C(080),C(015) Say 	"Placa 01:" 												Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg
	@ C(080),C(045) MsGet 	ocPlaca 	Var cPlaca Picture("@!")           			Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg

	@ C(080),C(095) Say 	"Placa 02:" 												Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg
	@ C(080),C(125) MsGet 	ocPlaca2 	Var cPlaca2 Picture("@!")           			Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg


/*
@ C(100),C(015) Say 	"Transp:" 												Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg
@ C(100),C(045) MsGet 	oTransp 	Var cTransp Picture("@!")           		Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg
*/

	@ C(100),C(015) Say 	"Transp:"      					 		   	Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg

	If lLibTransp
		@ C(100),C(045) MsGet 	oTransp  	Var cTransp WHEN .T.  Picture("@!") F3 "SA4" valid ImpTransp(cTransp)  		Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg
	Else
		@ C(100),C(045) MsGet 	oTransp  	Var cTransp WHEN .F.  Picture("@!") F3 "SA4" valid ImpTransp(cTransp)  		Size C(040),C(010) COLOR CLR_BLACK 	PIXEL OF _oDlg
	Endif

	@ C(103),C(090) Say   SubStr(cDescTransp,1,27) 	PIXEL OF _oDlg

/*
If lLibTransp 
 oTransp:Enable()
Else
 oTransp:Disable()
Endif
*/


//@ C(100),C(080) Say 	SA4->A4_NOME



	@ C(120),C(020) Button "Confirma"  												Size C(037),C(012) 					PIXEL OF _oDlg action(AtuNota())
	@ C(120),C(070) Button "Ignora" 												Size C(037),C(012) 					PIXEL OF _oDlg action(CanNota())
	@ C(120),C(120) Button "Ignora Todas" 											Size C(037),C(012) 					PIXEL OF _oDlg action(TodNota())

	ACTIVATE MSDIALOG _oDlg CENTERED

Return()
*********************************************************************
Static Function AtuNota()
*********************************************************************
	_oDlg:End()

	lConDad := .T.

	Reclock("SF2",.F.)

	SF2->F2_PLIQUI 	:= nPesol
	SF2->F2_PBRUTO 	:= nPesob
	SF2->F2_VOLUME1	:= nVolume
	SF2->F2_ESPECI1	:= cEspecie
	SF2->F2_VEICUL1   := cPlaca
	SF2->F2_VEICUL2   := cPlaca2

	SF2->F2_TRANSP  := cTransp
	SF2->(MsUnlock())

//Atualiza a Tranportadora no pedido de Transferência  
	Reclock("SC5",.F.)
	SC5->C5_TRANSP := cTransp
	SC5->(MsUnlock())


Return()
*********************************************************************
Static Function CanNota()
*********************************************************************

	_oDlg:End()

	lConDad := .T.

Return()
*********************************************************************
Static Function TodNota()
*********************************************************************

	_oDlg:End()

	lConDad := .F.

Return()
*********************************************************************
Static Function C(nTam)
*********************************************************************

	Local nHRes	:=	oMainWnd:nClientWidth

	If nHRes == 640
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)
		nTam *= 1
	Else
		nTam *= 1.28
	EndIf

	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf

Return Int(nTam)

Static Function ImpTransp()
	cDescTransp:=Posicione("SA4",1,xFilial("SA4")+cTransp,"A4_NOME")
	@ C(103),C(090) Say   SubStr(cDescTransp,1,27) 	PIXEL OF _oDlg
Return

// Jean Rehermann - Solutio IT - 09/02/2018 - Verificar os volumes nas tabelas ZCU, ZCV e D00
Static Function GetVolD00( cNF )

	Local _nVol := 0
	Local cNota     := cNF
	Local cSerie    := "I"+ cFilAnt
	Local aRetVol   := {}
	Local aVolumes  := {}
	Local aPedidos  := {}
	Local aPallets  := {}
	Local _nI := _nX := _nY := 0
	
	aPedidos := RetPedido( cNota + cSerie )
	
	For _nX := 1 To Len( aPedidos )
		
		aRetVol := RetVolume( aPedidos[ _nX ] )
		
		For _nI := 1 To Len( aRetVol )
			aAdd( aVolumes, { aRetVol[ _nI, 1 ], aRetVol[ _nI, 2 ] } )
		Next
		
	Next

	For _nY := 1 To Len( aVolumes )

		If Empty( aVolumes[ _nY, 2 ] )
			_nVol++
		Else
			If aScan( aPallets, { |o| o == aVolumes[ _nY, 2 ] } ) == 0
				aAdd( aPallets, aVolumes[ _nY, 2 ] )
			EndIf
		EndIf

	Next

	_nVol += Len( aPallets )

Return( _nVol )

// Jean Rehermann - Solutio IT - 09/02/2018 - Retorna os números de PV referente à nota fiscal informada
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

// Jean Rehermann - Solutio IT - 09/02/2018 - Retorna os volumes referente ao pedido informado
Static Function RetVolume( cNumPv )

	Local aVol := {}
	Local _cQuery := ""
	Local _cAlias := ""
	Local _aArea  := GetArea()
	
	_cQuery := "SELECT DISTINCT(D00_CODVOL) D00_CODVOL, D00_PALLET "
	_cQuery += " FROM "+ RetSqlName("D00")
	_cQuery += " WHERE D00_FILIAL  = '"+ xFilial("D00") +"' "
	_cQuery += "   AND D00_PEDIDO  = '"+ cNumPv +"' "
	_cQuery += "   AND D00_DATEMB  = ' ' "
	_cQuery += "   AND D_E_L_E_T_  = ' ' "
	
	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	
	While !(_cAlias)->( Eof() )
		
		aAdd( aVol, { (_cAlias)->D00_CODVOL, (_cAlias)->D00_PALLET } )
		
		(_cAlias)->( dbSkip() )
	End
	
	(_cAlias)->( dbCloseArea() )
	
	RestArea( _aArea )

Return( aVol )
