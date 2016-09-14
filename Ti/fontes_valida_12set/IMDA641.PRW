#INCLUDE "PROTHEUS.CH"
#DEFINE  ENTER CHR(13)+CHR(10)

/*/
Jean Rehermann - Solutio IT - 29/09/2015
Rotina para cadastro e execucao de plano de corte de correias
Gerencia os cortes e efetua a atualizacao dos estoques via RE7/DE7
/*/

User Function IMDA641()

	Local aCores 	  := {}

	Private cCadastro := "Planos de Corte"
	Private aRotina   := MenuDef()
	Private cDelFunc  := "{ || AllwaysTrue() }"
	Private cString   := "ZXA"
	Private cLocPad   := ""           // Local padrão para as peças cortadas
	Private cLocSob   := ""           // Local padrão para as sobras de corte
	Private cEndPad   := ""           // Endereço padrão para as peças cortadas
	Private cEndSob   := ""           // Endereço padrão para as sobras de corte
	Private cParEnd   := "MV_LPADCRT" // Parâmetro de Local + Endereço padrão para as peças cortadas
	Private cParSob   := "MV_LPADSOB" // Parâmetro de Local + Endereço padrão para as sobras de corte
	
	Public cFamilia  := "" // Deverá conter a família do produto selecionado/ Será utilizado no filtro da consulta padrão

	If cFilAnt != "09"
		MsgAlert("Rotina só pode ser executada pela filial 09 - São Paulo")
		Return
	EndIf
	
	If !DefAdrCr( cParEnd ) // Verifica se existe parâmetro do local + endereço padrão para peças cortadas, se o mesmo está preenchido e se é válido
		MsgAlert("Rotina não pode continuar sem local e endereço padrão!")
		Return
	EndIf
	
	If !DefAdrCr( cParSob ) // Verifica se existe parâmetro do local + endereço padrão para sobras, se o mesmo está preenchido e se é válido
		MsgAlert("Rotina não pode continuar sem local e endereço padrão!")
		Return
	EndIf

	SetKey( VK_F5, {|| U_IMD641Ef() })
					
	aCores := { {"ZXA_STATUS=='A'",'ENABLE' }, {"ZXA_STATUS=='E'",'DISABLE'}, {"ZXA_STATUS=='I'",'BR_PRETO' }, {"ZXA_STATUS=='C'",'BR_AZUL'} }

	dbSelectArea( cString )
	dbSetOrder(1)

	mBrowse( 6, 1, 22, 75, cString,,,,,,aCores,,,,,,.T.,,)
    
	SetKey( VK_F5, Nil )
	
Return

/*
Função que cria a interface de inclusão
*/
User Function IMD641In(cAlias,nReg,nOpcx)

	Local cCodPrd1 := "ZZZZZ"
	Local _nOpc    := 0
	Local oDlg
	Local oCBox1
	Local oBtn1
	Local oGrp1
	
	Private _cFam := "01"
	
	DEFINE MSDIALOG oDlg TITLE "Família" FROM 000, 000 TO 075, 200 COLORS 0, 16777215 PIXEL STYLE 128
	
		@ 004, 002 GROUP oGrp1 TO 034, 097 PROMPT "Selecione a Família" OF oDlg COLOR 0, 16777215 PIXEL
		@ 014, 006 MSCOMBOBOX oCBox1 VAR _cFam ITEMS {"01=Correias Fechadas","02=Correias Abertas"} SIZE 066, 010 OF oDlg COLORS 0, 16777215 PIXEL
		@ 012, 074 BUTTON oBtn1 PROMPT "OK" ACTION ( _nOpc := 1, oDlg:End() ) SIZE 018, 012 OF oDlg PIXEL
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If _nOpc == 1 // Selecionado o tipo de correia e pressionado o botão OK
	
		__ReadVar := "cCodPrd1"
		
		While .T. // Mantenho no loop
			
			cCodPrd1 := A093MontaCod( PadR( _cFam, 10 ), .F. )
			
			If !Empty( cCodPrd1 ) .And. !SB1->( dbSeek( xFilial("SB1") + cCodPrd1 ) )
				MsgAlert("Produto selecionado ainda não cadastrado!")
			Else
				Exit // Se ESC ou FECHAR, sai do loop
			EndIf
		End
		
		If !Empty( cCodPrd1 )	
			PlanInc(cAlias,nReg,nOpcx,cCodPrd1)
		EndIf
    
	EndIf
	
Return

Static Function PlanInc(cAlias,nReg,nOpcx,cProd1)

	Local aArea     := GetArea()
	Local aSize     := {}
	Local aPosObj   := {}
	Local aInfo     := {}
	Local aObjects  := {}
	Local nOpca	    := 0
	Local aVarSBS   := {}
	Local cRef      := ""
	Local cLrg      := ""
	Local cFam      := ""
	Local cBase     := PadR( _cFam, 10 )
	Local oDlg

	Private oGet

	ExecBlock('ChkPosBase',.F.,.F., {'IMDA641', ""})	
	cBase := U_A093Base( PadR( cProd1, TamSX3("B1_COD")[ 1 ] ) )
	ExecBlock('ChkPosBase',.F.,.F., {'IMDA641', cBase})	
	
	aVarSBS  := A093SBSVars( cProd1 ) 

	cRef := aVarSBS[ aScan( aVarSBS, {|o|  AllTrim( o[ 1 ] ) == 'REF' } ) ][03]
	cLrg := aVarSBS[ aScan( aVarSBS, {|o|  AllTrim( o[ 1 ] ) == 'LRG' } ) ][03]
	cFam := aVarSBS[ aScan( aVarSBS, {|o|  AllTrim( o[ 1 ] ) == 'FAM' } ) ][02]
	cFDe := aVarSBS[ aScan( aVarSBS, {|o|  AllTrim( o[ 1 ] ) == 'FAM' } ) ][03]

    dbSelectArea("ZXB")

	FillGetDados(nOPcx,"ZXB",1,/*cSeek*/,/*{|| &cWhile }*/,{||.T.},{"ZXB_NUMCRT"},/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,.T.)

	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 050, .t., .t. } )
	AAdd( aObjects, { 100, 050, .t., .t. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	RegToMemory("ZXA",.T.,.T.,.T.)

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		EnChoice( cAlias, nReg, nOpcx, , , , , aPosObj[1],,3,,,)
		oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"U_I641LinOk","U_I641TudOk","+ZXB_ITEM",.T.,,,,,,,,"U_I641DelOk")
		oDlg:lMaximized := .T.
		aCols[1][ aScan( aHeader, {|o| AllTrim( Upper( o[ 2 ] ) ) == "ZXB_ITEM"   } ) ] := "001"
		aCols[1][ aScan( aHeader, {|o| AllTrim( Upper( o[ 2 ] ) ) == "ZXB_PRODUT" } ) ] := cProd1
		SX3->( dbSetOrder(2) )
		SX3->( dbSeek("ZXB_PRODUT") )
		IF ExistTrigger("ZXB_PRODUT")
			M->ZXB_PRODUT := cProd1
			RunTrigger(2,1)
		EndIf
		M->ZXA_NUMCRT := GetSx8Num("ZXA","ZXA_NUMCRT")
		M->ZXA_REF    := cRef
		M->ZXA_CODBAS := cBase
		M->ZXA_LRG    := Iif( AllTrim( cBase ) == "02", cLrg, "" )
		M->ZXA_NOMFAM := cFDe
		cFamilia      := cFam
		oGet:oBrowse:Refresh()
		oGet:Refresh()
	ACTIVATE MSDIALOG oDlg On INIT I641Bar( oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()},nOpcx)

	If nOpcA == 1
		Begin Transaction

			dbSelectArea("ZXA")
			RecLock("ZXA",.T.)
				ZXA->ZXA_FILIAL := cFilAnt
				ZXA->ZXA_NUMCRT := M->ZXA_NUMCRT
				ZXA->ZXA_USER   := M->ZXA_USER
				ZXA->ZXA_DATA   := M->ZXA_DATA
				ZXA->ZXA_HORA   := M->ZXA_HORA
				ZXA->ZXA_TIPO   := M->ZXA_TIPO
				ZXA->ZXA_STATUS := M->ZXA_STATUS
				ZXA->ZXA_REF    := M->ZXA_REF
				ZXA->ZXA_CODBAS := M->ZXA_CODBAS
				ZXA->ZXA_LRG    := M->ZXA_LRG
			ZXA->( MsUnLock() )

			dbSelectArea("ZXB")
			For _nX := 1 To Len( aCols )
				If !aCols[ _nX, Len( aHeader ) + 1 ]
					RecLock("ZXB",.T.)
						ZXB->ZXB_FILIAL := cFilAnt
						ZXB->ZXB_NUMCRT := M->ZXA_NUMCRT
						ZXB->ZXB_ITEM   := aCols[ _nX, aScan( aHeader, {|o| AllTrim( Upper( o[ 2 ] ) ) == "ZXB_ITEM"   } ) ]
						ZXB->ZXB_PRODUT := aCols[ _nX, aScan( aHeader, {|o| AllTrim( Upper( o[ 2 ] ) ) == "ZXB_PRODUT" } ) ]
						ZXB->ZXB_UN     := aCols[ _nX, aScan( aHeader, {|o| AllTrim( Upper( o[ 2 ] ) ) == "ZXB_UN"     } ) ]
						ZXB->ZXB_QTD    := aCols[ _nX, aScan( aHeader, {|o| AllTrim( Upper( o[ 2 ] ) ) == "ZXB_QTD"    } ) ]
						ZXB->ZXB_FILORI := aCols[ _nX, aScan( aHeader, {|o| AllTrim( Upper( o[ 2 ] ) ) == "ZXB_FILORI" } ) ]
						ZXB->ZXB_PEDIDO := aCols[ _nX, aScan( aHeader, {|o| AllTrim( Upper( o[ 2 ] ) ) == "ZXB_PEDIDO" } ) ]
						ZXB->ZXB_ITEMPV := aCols[ _nX, aScan( aHeader, {|o| AllTrim( Upper( o[ 2 ] ) ) == "ZXB_ITEMPV" } ) ]
					ZXB->( MsUnLock() )
				EndIf
			Next
		
		End Transaction

		If ( __lSx8 )
			ConfirmSx8()
		EndIf
	Else
		If ( __lSx8 )
			RollBackSx8()
		EndIf
	EndIf

	RestArea(aArea)

Return(nOpca)

/*
Função que cria a interface de alteração
*/
User Function IMD641Al(cAlias,nReg,nOpcx)

	Local aArea     := GetArea()
	Local aSize     := {}
	Local aPosObj   := {}
	Local aInfo     := {}
	Local aObjects  := {}
	Local nOpca	    := 0
	Local oDlg

	Private oGet

	If ZXA->ZXA_STATUS $ "IE"
		MsgAlert("Plano de corte já efetivado ou interrompido!")
		SetKey( VK_F5, {|| U_IMD641Ef() })
		Return( .F. )
	EndIf
	
	FillGetDados(nOpcx,"ZXB",1,,,{||.T.},{"ZXB_NUMCRT"},,,,{|| MontaCols()},.F.)

	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 050, .t., .t. } )
	AAdd( aObjects, { 100, 050, .t., .t. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	RegToMemory("ZXA",.F.,.F.)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ POSICIONA TABELAS NA XX_BASE CORRETA E VERIFICA SE ALIAS() ESTA VAZIA	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ExecBlock('ChkPosBase',.F.,.F., {'IMDA641', Left(ZXB->ZXB_PRODUT,02) })
	
	aVarSBS  :=	A093SBSVars(ZXB->ZXB_PRODUT) 
	cFDe := aVarSBS[ aScan( aVarSBS, {|o|  AllTrim( o[ 1 ] ) == 'FAM' } ) ][03]
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		EnChoice( cAlias, nReg, nOpcx, , , , , aPosObj[1],,3,,,)
		M->ZXA_NOMFAM := cFDe

		oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"U_I641LinOk","U_I641TudOk","+ZXB_ITEM",.T.,,,,,,,,"U_I641DelOk")
		oDlg:lMaximized := .T.
		oGet:oBrowse:nAt := 1
		oGet:ForceRefresh()
	ACTIVATE MSDIALOG oDlg On INIT I641Bar( oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()},nOpcx)

	If nOpcA == 1
		Begin Transaction

			dbSelectArea("ZXB")
			dbSetOrder(1)

			For _nX := 1 To Len( aCols )

				lDele := aCols[ _nX, Len( aHeader ) + 1 ]
				lSeek := dbSeek( xFilial("ZXB") + ZXA->ZXA_NUMCRT + aCols[ _nX, aScan( aHeader, {|o| AllTrim( Upper( o[ 2 ] ) ) == "ZXB_ITEM" } ) ] )

				If lDele
					If lSeek
						RecLock("ZXB",.F.)
							ZXB->( dbDelete() )
						ZXB->( MsUnLock() )
					EndIf

				Else
					RecLock("ZXB",!lSeek)
						ZXB->ZXB_FILIAL := cFilAnt
						ZXB->ZXB_NUMCRT := ZXA->ZXA_NUMCRT
						ZXB->ZXB_ITEM   := aCols[ _nX, aScan( aHeader, {|o| AllTrim( Upper( o[ 2 ] ) ) == "ZXB_ITEM"   } ) ]
						ZXB->ZXB_PRODUT := aCols[ _nX, aScan( aHeader, {|o| AllTrim( Upper( o[ 2 ] ) ) == "ZXB_PRODUT" } ) ]
						ZXB->ZXB_UN     := aCols[ _nX, aScan( aHeader, {|o| AllTrim( Upper( o[ 2 ] ) ) == "ZXB_UN"     } ) ]
						ZXB->ZXB_QTD    := aCols[ _nX, aScan( aHeader, {|o| AllTrim( Upper( o[ 2 ] ) ) == "ZXB_QTD"    } ) ]
					ZXB->( MsUnLock() )
				EndIf
			Next

		End Transaction
	EndIf

	RestArea(aArea)

Return(nOpca)

/*
Função que cria a interface de visualização
*/
User Function IMD641Vi(cAlias,nReg,nOpcx)

	Local oDlg
	Private	aHeader := {}
	Private aCols   := {}
	
	FillGetDados(nOpcx,"ZXB",1,,,,{"ZXB_NUMCRT"},,,,{|| MontaCols() },.F.,,,,,,)

	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 050, .t., .t. } )
	AAdd( aObjects, { 100, 050, .t., .t. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	dbSelectArea("ZXB")
	dbSetOrder(1)
	dbSeek( xFilial("ZXA") + ZXA->ZXA_NUMCRT ) // Posicionar no primeiro item para identificar a familia
	dbSelectArea("ZXA")

	//Iif( Select('SBP') == 0, ( ChkFile('SBP'), DbSelectArea("SBP") ), )
	//aVarSBS  := A093SBSVars( ZXB->ZXB_PRODUT ) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ POSICIONA TABELAS NA XX_BASE CORRETA E VERIFICA SE ALIAS() ESTA VAZIA	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ExecBlock('ChkPosBase',.F.,.F., {'IMDA614', Left(ZXB->ZXB_PRODUT,02) })
	
	aVarSBS  :=	A093SBSVars( ZXB->ZXB_PRODUT ) 
	cFDe := aVarSBS[ aScan( aVarSBS, {|o|  AllTrim( o[ 1 ] ) == 'FAM' } ) ][03]
	cRef := aVarSBS[ aScan( aVarSBS, {|o|  AllTrim( o[ 1 ] ) == 'REF' } ) ][03]

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		EnChoice( cAlias, nReg, nOpcx, , , , , aPosObj[1],,3,,,)
		M->ZXA_NOMFAM := cFDe
		M->ZXA_REF    := cRef
		MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,,,"",,,,,,,,,,,)
		oDlg:lMaximized := .T.
	ACTIVATE MSDIALOG oDlg On INIT I641Bar( oDlg,{||oDlg:End()},{||oDlg:End()},nOpcx)

Return( nOpcx )

/*
Função que cria a interface de exclusão
*/
User Function IMD641Ex(cAlias,nReg,nOpcx)

	Local oDlg
	Local nOpca	    := 0
    Local _nNum     := ZXA->ZXA_NUMCRT
	Private	aHeader := {}
	Private aCols   := {}

	If ZXA->ZXA_STATUS $ "IE"
		MsgAlert("Plano de corte já efetivado ou interrompido!")
		Return( .F. )
	EndIf

	FillGetDados(nOpcx,"ZXB",1,,,,{"ZXB_NUMCRT"},,,,{|| MontaCols() },.F.,,,,,,)

	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 050, .t., .t. } )
	AAdd( aObjects, { 100, 050, .t., .t. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ POSICIONA TABELAS NA XX_BASE CORRETA E VERIFICA SE ALIAS() ESTA VAZIA	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ExecBlock('ChkPosBase',.F.,.F., {'IMDA614', Left(ZXB->ZXB_PRODUT,02) })
	
	aVarSBS  :=	A093SBSVars( ZXB->ZXB_PRODUT ) 
	cFDe 	 :=	aVarSBS[ aScan( aVarSBS, {|o|  AllTrim( o[ 1 ] ) == 'FAM' } ) ][03]

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		EnChoice( cAlias, nReg, nOpcx, , , , , aPosObj[1],,3,,,)
		M->ZXA_NOMFAM := cFDe
		MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,,,"",,,,,,,,,,,)	
		oDlg:lMaximized := .T.
	ACTIVATE MSDIALOG oDlg On INIT I641Bar( oDlg,{||nOpca:=1,oDlg:End()},{||oDlg:End()},nOpcx)

	If nOpca == 1
		Begin Transaction

			dbSelectArea("ZXA")
			RecLock("ZXA",.F.)
				ZXA->( dbDelete() )
			ZXA->( MsUnLock() )

			dbSelectArea("ZXB")
			dbSetOrder(1)
			dbSeek( xFilial("ZXB") + _nNum )
			While !ZXB->( Eof() ) .And. xFilial("ZXB") + _nNum == ZXB->ZXB_FILIAL + ZXB->ZXB_NUMCRT
				
				If !Empty( ZXB->ZXB_FILORI + ZXB->ZXB_PEDIDO + ZXB->ZXB_ITEMPV )	
					dbSelectArea("SC6")
					dbSetOrder(1)
					If dbSeek( ZXB->ZXB_FILORI + ZXB->ZXB_PEDIDO + AllTrim( ZXB->ZXB_ITEMPV ) + ZXB->ZXB_PRODUT )
						RecLock("SC6",.F.)
							SC6->C6_CORTE   := " " // G = Gerado / C = Cortado / " " = Sem plano de corte
							SC6->C6_NUMCRT  := " "
							SC6->C6_ITEMCRT := " "
						SC6->( MsUnLock() )
					EndIf
				EndIf
				
				RecLock("ZXB",.F.)
					ZXB->( dbDelete() )
				ZXB->( MsUnLock() )

				ZXB->( dbSkip() )
			End

		End Transaction
	EndIf
	
Return( nOpcx )

/* Função que cria a interface de cancelamento */
User Function IMD641Ca(cAlias,nReg,nOpcx)

	Local oDlg
	Local nOpca	  := 0
    Local _nNum   := ZXA->ZXA_NUMCRT
	Local cDocSD3 := ""
	Local dEmisD3 := CtoD("//")
	Local cSeqEst := ""
	Local aAutoCab := {}
	Local aAutoItens := {}
	Local aAutoItem := {}
	Local _lTemErr := .F.
	Local _lTemOk := .F.

	Private	aHeader := {}
	Private aCols   := {}
	Private lMsErroAuto := .F.

	If ZXA->ZXA_STATUS $ "AC"
		MsgAlert("Plano de corte em aberto ou já cancelado!")
		Return( .F. )
	EndIf

	FillGetDados(nOpcx,"ZXB",1,,,,{"ZXB_NUMCRT"},,,,{|| MontaCols() },.F.,,,,,,)

	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 050, .t., .t. } )
	AAdd( aObjects, { 100, 050, .t., .t. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	RegToMemory("ZXA",.F.,.F.)

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		EnChoice( cAlias, nReg, nOpcx, , , , , aPosObj[1],,3,,,)
		MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,,,"",,,,,,,,,,,)	
		oDlg:lMaximized := .T.
	ACTIVATE MSDIALOG oDlg On INIT I641Bar( oDlg,{||nOpca:=1,oDlg:End()},{||oDlg:End()},nOpcx)

	If nOpca == 1
		Begin Transaction

			dbSelectArea("ZXC")
			dbSetOrder(1)
			dbSeek( xFilial("ZXC") + _nNum )
			While !ZXC->( Eof() ) .And. xFilial("ZXC") + _nNum == ZXC->ZXC_FILIAL + ZXC->ZXC_NUMCRT
				
				dbSelectArea("SD3")
				dbSetOrder(2)
				If dbSeek( xFilial("SD3") + ZXC->ZXC_DOCSD3 )

					cDocSD3 :=SD3->D3_DOC
					dEmisD3 :=SD3->D3_EMISSAO
					cSeqEst :=SD3->D3_NUMSEQ

					While !SD3->( Eof() ) .And. SD3->D3_NUMSEQ == cSeqEst .And. SD3->D3_DOC == cDocSD3
						
						If SD3->D3_CF == "RE7" .And. SD3->D3_EMISSAO == dEmisD3 // Cabeçalho da desmontagem

							aAutoCab := {	{"cProduto"   , SD3->D3_COD	   , Nil},;
											{"cLocOrig"   , SD3->D3_LOCAL  , Nil}, ;
											{"nQtdOrig"   , SD3->D3_QUANT  , Nil}, ;
											{"nQtdOrigSe" , SD3->D3_QTSEGUM, Nil}, ;
											{"cDocumento" , SD3->D3_DOC    , Nil}, ;
											{"cNumLote"   , SD3->D3_NUMLOTE, Nil}, ;
											{"cLoteDigi"  , SD3->D3_LOTECTL, Nil}, ;
											{"dDtValid"   , SD3->D3_DTVALID, Nil}, ;
											{"nPotencia"  , SD3->D3_POTENCI, Nil}, ;
											{"cLocaliza"  , SD3->D3_LOCALIZ, Nil}, ;
											{"cNumSerie"  , SD3->D3_NUMSERI, Nil}}

						ElseIf SD3->D3_CF == "DE7" .And. SD3->D3_EMISSAO == dEmisD3

							aAutoItem := {;
								{"D3_COD"    , SD3->D3_COD    , Nil},;
								{"D3_LOCAL"  , SD3->D3_LOCAL  , Nil},;
								{"D3_QUANT"  , SD3->D3_QUANT  , Nil},;
								{"D3_LOCALIZ", SD3->D3_LOCALIZ, Nil},;
								{"D3_RATEIO" , SD3->D3_RATEIO , Nil} }
								
							aAdd( aAutoItens, aAutoItem )

						EndIf
						
						SD3->( dbSkip() )
					End
					// Reposiciono no registro do movimento antes de efetuar o estorno da desmontagem
					dbSeek( xFilial("SD3") + ZXC->ZXC_DOCSD3 )
					// Estorno de desmontagem, com movimentação de estoque
					MSExecAuto( {|v,x,y,z| Mata242( v, x, y, z ) }, aAutoCab, aAutoItens, 5, .T. )

					If lMsErroAuto
						Mostraerro()
						_lTemErr := .T.
					Else
						dbSelectArea("ZXC")
						RecLock("ZXC",.F.)
							ZXC->( dbDelete() )
						ZXC->( MsUnLock() )
						_lTemOk := .T.
					EndIf
				
				EndIf
                
				aAutoItens := {}
				aAutoItem := {}
				aAutoCab := {}

				ZXC->( dbSkip() )
			End
            
			_cSts := Iif( _lTemOk, Iif( _lTemErr, "I", "A" ), "E" )
			
			// Alterar o status do corte para tornar apto a efetivação novamente
			dbSelectArea("ZXA")
			RecLock("ZXA",.F.)
				ZXA->ZXA_STATUS := _cSts
				If _cSts == "A"
					ZXA->ZXA_USERE  := " "
					ZXA->ZXA_DATAE  := CtoD("//")
					ZXA->ZXA_HORAE  := " "
				EndIf
			ZXA->( MsUnLock() )

		End Transaction
	EndIf
	
Return( nOpcx )

/*
Prepara e exibe a legenda do status do plano de corte
*/
User Function Imd641Le()

	Local aLegenda	:= {}

	Aadd( aLegenda, {"DISABLE" ,"Efetivado"})
	Aadd( aLegenda, {"ENABLE"  ,"Aberto"})
	Aadd( aLegenda, {"BR_PRETO","Interrompido"})
	Aadd( aLegenda, {"BR_AZUL" ,"Cancelado"})

	BrwLegenda("Legenda","Status",aLegenda)  //"Legenda"

Return(.T.)

/*
Efetiva o corte e realiza as movimentações de estoque
*/
User Function IMD641Ef()

	Local oSay3
	Local oSay4
	Local oSay5
	Local nOpcD    := 0
	Local aItem    := {}
	Local aPedLib  := {}
	Local _aFilPed := {}
	Local _aNumPed := {}
	Local _aItePed := {}
	Local _cStatus := ZXA->ZXA_STATUS
	Local _lD3Err  := .F.
	Local _lD3Ok   := .F.

	Private oDlg
	Private _aCabDes 	:= 	{} 	// Cabeçalho da desmontagem
	Private _aIteDes 	:= 	{} 	// Item da desmontagem
	Private oBrwB
	Private oBrwA
	Private aAutoItens 	:= 	{}
	Private _lMM    	:= 	.F.
	Private _lRibs    	:= 	.F.
	Private cDoc    	:= 	""
	Private _aD3Doc 	:= 	{}
	Private _aSobra 	:= 	{}

	Private _lBase01 := ( "01" $ ZXA->ZXA_CODBAS )
	Private _lBase02 := ( "02" $ ZXA->ZXA_CODBAS )

	SetKey( VK_F5, Nil )
	
	If _lBase02
		Setkey( VK_F4, { || U_Sobra02( _aSobra, oBrwB:aCols[ oBrwB:nAt ], .T. ) } )
		Setkey( VK_F5, { || U_VerSob02( .F. ) } )
	EndIf
	
	If ZXA->ZXA_STATUS == "E"
		MsgAlert("Plano de corte já efetivado!")
		Return( .F. )
	ElseIf ZXA->ZXA_STATUS == "I"
		MsgAlert("Plano de corte interrompido, precisa ser cancelado antes de ser efetivado novamente!")
		Return( .F. )
	EndIf

	dbSelectArea("ZXB")
	dbSetOrder(1)
	dbSeek( xFilial("ZXA") + ZXA->ZXA_NUMCRT ) // Posicionar no primeiro item para identificar a familia

	Iif( Select('SBP') == 0, ( ChkFile('SBP'), DbSelectArea("SBP") ), )
	SBP->( dbGoTop() )
	dbSelectArea("ZXA")

	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 288, 045, .t., .t. } )
	AAdd( aObjects, { 288, 045, .t., .t. } )
	AAdd( aObjects, { 288, 010, .t., .t. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .t. )

	DEFINE MSDIALOG oDlg TITLE "Efetivar Corte" From aSize[7], 0 to aSize[6],aSize[5] COLORS 0, 16777215 of oMainWnd PIXEL

		RegToMemory("ZXA", .F., .F.)
		fGrid1( aPosObj[ 1 ] )
		fGrid2( aPosObj[ 2 ] )

	ACTIVATE MSDIALOG oDlg On INIT I641Bar( oDlg,{|| Iif( VldTela(), ( Iif( VldSobra(), ( nOpcD := 1, oDlg:End() ), ) ), ) }, {|| oDlg:End() }, 9 )

	If nOpcD == 1

		For _nK := 1 To Len( _aCabDes )

			For _nL := 1 To Len( _aIteDes )

				If _aIteDes[ _nL, 1 ] == _aCabDes[ _nK, 1 ]

					dbSelectArea("SB2")
					dbSetOrder(1)
					If !SB2->( dbSeek( xFilial("SB2") + _aIteDes[ _nL, 3 ] + Iif( _aIteDes[ _nL, 2 ] == "000", cLocSob, cLocPad ) ) )
						CriaSB2( _aIteDes[ _nL, 3 ], Iif( _aIteDes[ _nL, 2 ] == "000", cLocSob, cLocPad ) )
					EndIf

					aAdd( aItem, { "D3_COD"    , _aIteDes[ _nL, 3 ], Nil } )
					aAdd( aItem, { "D3_QUANT"  , _aIteDes[ _nL, 4 ], Nil } )
					aAdd( aItem, { "D3_LOCAL"  , Iif( _aIteDes[ _nL, 2 ] == "000", cLocSob, cLocPad ), Nil } )
					aAdd( aItem, { "D3_RATEIO" , _aIteDes[ _nL, 8 ], Nil } )
					aAdd( aItem, { "D3_LOCALIZ", _aIteDes[ _nL, 9 ], Nil } )

					If Len( _aIteDes[ _nL, 5 ] ) > 0 // Verifico se tem algum pedido de venda amarrado a este item de desmontagem
						
						// Arrays com os pedidos aglutinados no item da desmontagem
						_aFilPed := _aIteDes[ _nL, 5 ]
						_aNumPed := _aIteDes[ _nL, 6 ]
						_aItePed := _aIteDes[ _nL, 7 ]
						
						For _nT := 1 To Len( _aFilPed )
							aAdd( aPedLib, { _aFilPed[ _nT ],;   // Filial
							                 _aNumPed[ _nT ],;   // Pedido
							                 _aItePed[ _nT ] } ) // Item
						Next
					
					EndIf

					aAdd( aAutoItens, aItem )
					aItem := {}

				EndIf

			Next

			Processa( {|| cDoc := Imd641Des( _aCabDes[ _nK, 2 ], _aCabDes[ _nK, 4 ], _aCabDes[ _nK, 3 ], 1, aAutoItens, aPedLib, _aCabDes[ _nK, 5 ], _aIteDes ) } )
			
			aAdd( _aD3Doc, cDoc )
			
			aPedLib := {}
			aAutoItens := {}

		Next
		
		For _nXX := 1 To Len( _aD3Doc )
			
			If Empty( _aD3Doc[ _nXX ] )
				_lD3Err := .T. // Possui pelo menos uma desmontagem com problema
			Else
				_lD3Ok := .T. // Possui pelo menos uma desmontagem com sucesso
				
				// Gravar no log de desmontagens (movimento no SD3)
				aArea := GetArea()
				
				dbSelectArea("ZXC")
				RecLock("ZXC",.T.)
					ZXC->ZXC_FILIAL := xFilial("ZXC")
					ZXC->ZXC_NUMCRT := ZXA->ZXA_NUMCRT
					ZXC->ZXC_DOCSD3 := _aD3Doc[ _nXX ]
				MsUnLock()
				
				RestArea( aArea )
			EndIf
		
		Next

		_cStatus := Iif( _lD3Ok, Iif( _lD3Err, "I", "E" ), _cStatus ) // Se fez parcial, total ou nenhuma desmontagem
		
		If _cStatus $ "ICE" // I=Interrompido C=Cancelado E=Efetivado

			RecLock("ZXA",.F.)
				ZXA->ZXA_USERE  := cUserName
				ZXA->ZXA_DATAE  := dDataBase
				ZXA->ZXA_HORAE  := SubStr( Time(), 1, 5 )
				ZXA->ZXA_STATUS := "E"
			ZXA->( MsUnLock() )
        
        EndIf
	
	EndIf

	SetKey( VK_F5, {|| U_IMD641Ef() })

Return

/* Valida se todos os cortes solicitados foram processados */
Static Function VldTela()

	Local _lOk := .T.
	Local _nPosQtd := aScan( oBrwA:aHeader,{ |X| AllTrim( x[ 2 ] ) == "QUANT"} )
	Local _nPosAte := aScan( oBrwA:aHeader,{ |X| AllTrim( x[ 2 ] ) == "ATEND"} )

	For _nX := 1 To Len( oBrwA:aCols )
		If oBrwA:aCols[ _nX, _nPosQtd ] <> oBrwA:aCols[ _nX, _nPosAte ]
			MsgAlert("Há itens não selecionados para corte, verificar!")
			_lOk := .F.
			Exit
		EndIf
	Next

Return( _lOk )

/* Verifica as sobras e solicita encaminhamento */
Static Function VldSobra()

	Local _nSobra := aScan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "SOBRAU"} )
	Local _nLarg  := aScan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "LARGUR"} )
	Local _nSeq   := aScan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "SEQUEN"} )
	Local _nProd  := aScan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "CODIGO"} )
	Local nOpcSob := 0
	Local oButton1, oSay6, oSay7, oDlgS
	Local _lRet := .T.
	Private oBrwX
	Private aHeaderX := {}
	Private aColsX   := {}

	If _lBase01
		
		For _nK := 1 To Len( oBrwB:aCols )

			_nSld := oBrwB:aCols[ _nK, _nSobra ]
	
			If _nSld > 0 .And. _nSld < oBrwB:aCols[ _nK, _nLarg ]
				
				aAdd( aColsX, { oBrwB:aCols[ _nK, _nSeq ],;
								oBrwB:aCols[ _nK, _nProd ],;
								_nSld,;
								Space( TamSx3("B1_COD")[1] ),;
								1,;
								.F. } )

			EndIf
	
		Next
		
	ElseIf _lBase02

		aColTmp := U_VerSob02(.T.) // SEQUENCIA / PROD.PAI / QTD / LARG / COMP / AREA
		
		If Len( aColTmp ) > 0
			
			For _nK := 1 To Len( aColTmp )

				_nLrgSob := aColTmp[ _nK, 4 ]
				_nCmpSob := aColTmp[ _nK, 6 ]
				
				_nPosSob := aScan( aColsX, {|o| o[ 4 ] == _nLrgSob .And. o[ 5 ] == _nCmpSob } )

				If _nPosSob > 0
					aColsX[ _nPosSob, 6 ] += aColTmp[ _nK, 7 ]
					aColsX[ _nPosSob, 7 ] += aColTmp[ _nK, 3 ]
				Else
					aAdd( aColsX, { aColTmp[ _nK, 1 ],; // SEQ
									aColTmp[ _nK, 2 ],; // PROD. PAI
									Space( TamSx3("B1_COD")[1] ),; // PROD. SOBRA
									_nLrgSob,; // LARG
									_nCmpSob,; // COMP
									aColTmp[ _nK, 7 ],; // AREA
									aColTmp[ _nK, 3 ],; // QUANT
									.F. } )
				EndIf

			Next

		EndIf

	EndIf
	


	If Len( aColsX ) > 0
		
		aAdd( aHeaderX, { "Seq.         ", "SEQUEN", "@!", 3, 0, "", "", "C", ""} )
		aAdd( aHeaderX, { "Prod. Pai    ", "PRDPAI", "@!", TamSx3('UB_PRODUTO')[01], 0, "", "", "C", ""})
		
		If _lBase01
			aAdd( aHeaderX, { "Sobra/Perda  ", "SOBRAT", "@E 999.99", 7, 2, "" , "" , "N" , ""})
			aAdd( aHeaderX, { "Prod. Sobra  ", "PRDPER", "@!", TamSx3('UB_PRODUTO')[01], 0, "", "", "C", "SB1PCI"})
			aAdd( aHeaderX, { "Qtd p/Estoque", "SOBRAQ", "@E 999.99", 7, 2, "" , "" , "N" , ""})
		ElseIf _lBase02
			aAdd( aHeaderX, { "Prod. Sobra  ", "PRDPER", "@!", TamSx3('UB_PRODUTO')[01], 0, "", "", "C", "SB1PCI"})
			aAdd( aHeaderX, { "Largura      ", "LARGUS", "@E 999,999.99", 10, 2, "" , "" , "N" , ""})
			aAdd( aHeaderX, { "Comprimento  ", "COMPRS", "@E 999,999.99", 10, 2, "" , "" , "N" , ""})
			aAdd( aHeaderX, { "Área M2      ", "AREAM2", "@E 999,999.9999", 12, 4, "" , "" , "N" , ""})
			aAdd( aHeaderX, { "Qtd p/Estoque", "SOBRAQ", "@E     999.99", 07, 2, "" , "" , "N" , ""})
		EndIf
		
		SetKey( VK_F6, {|| WizCriaP() } )
		
		DEFINE MSDIALOG oDlgS TITLE "Tratamento de Sobra/Perda" FROM 000, 000  TO 300, 750 COLORS 0, 16777215 PIXEL Style 128
			@005,003 SAY oSay6 PROMPT "Selecione para qual produto será atribuído o saldo que sobrou." SIZE 293, 011 OF oDlgS COLORS 0, 16777215 PIXEL
			@134,003 SAY oSay7 PROMPT "<F6> - Selecionar Produtos Para Sobras" SIZE 150, 010 OF oDlgS COLORS 255, 16777215 PIXEL
			oBrwX := MsNewGetDados():New( 023, 003, 127, 370, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "",{"PRDPER"},, Len(aColsX), "AllwaysTrue", "", "AllwaysTrue", oDlgS, aHeaderX, aColsX)
			@132,290 BUTTON oButton1 PROMPT "C&onfirmar" Action( Iif( VlBrwSob(), ( nOpcSob:=1,oDlgS:End() ), ) ) SIZE 037, 012 OF oDlgS PIXEL
			@132,330 BUTTON oButton2 PROMPT "&Cancelar " Action( _lRet:=.F.,oDlgS:End() ) SIZE 037, 012 OF oDlgS PIXEL
		ACTIVATE MSDIALOG oDlgS CENTERED

		SetKey( VK_F6, Nil )

		If nOpcSob == 1 .And. _lRet

			nPPr := aScan( oBrwX:aHeader, { |b| AllTrim( b[ 2 ] ) == "PRDPER" } )
			nPSq := aScan( oBrwX:aHeader, { |b| AllTrim( b[ 2 ] ) == "SEQUEN" } )
			nPLr := aScan( oBrwX:aHeader, { |b| AllTrim( b[ 2 ] ) == "SOBRAT" } )
			nPAr := aScan( oBrwX:aHeader, { |b| AllTrim( b[ 2 ] ) == "AREAM2" } )
			nPQt := aScan( oBrwX:aHeader, { |b| AllTrim( b[ 2 ] ) == "SOBRAQ" } )
			
			For _nX := 1 To Len( oBrwX:aCols )
				If !Empty( oBrwX:aCols[ _nX, nPPr ] )
					// Verificar se já existe código deste produto nesta desmontagem (rotina padrão não permite repetir código nos itens)
					nPExist := aScan( _aIteDes, { |o| AllTrim( o[ 1 ] ) == oBrwX:aCols[ _nX, nPSq ] .And. AllTrim( o[ 3 ] ) == AllTrim( oBrwX:aCols[ _nX, nPPr ] ) } )
					// Caso não exista apenas incluo o item no array dos itens da desmontagem, senão, somo a quantidade e a dimensão (LRG ou M2)
					If nPExist == 0
						aAdd( _aIteDes, { oBrwX:aCols[ _nX, nPSq ],;                                 // [ 01 ] Sequencia de desmontagem
						                  "000",;                                                    // [ 02 ] Item de desmontagem
						                  PadR( oBrwX:aCols[ _nX, nPPr ],TamSx3('UB_PRODUTO')[1] ),; // [ 03 ] Produto Sobra
						                  oBrwX:aCols[ _nX, nPQt ],;                                 // [ 04 ] Quantidade
						                  {},;                                                       // [ 05 ] Filial
						                  {},;                                                       // [ 06 ] Pedido
						                  {},;                                                       // [ 07 ] Item
						                  oBrwX:aCols[ _nX, Iif( _lBase01, nPLr, nPAr ) ],;          // [ 08 ] Largura ou área da Sobra
						                  cEndSob,;                                                  // [ 09 ] Endereço
						                  {} } )                                                     // [ 10 ] Quantidade
					Else
						_aIteDes[ nPExist, 4 ] += oBrwX:aCols[ _nX, nPQt ] // Somo a quantidade
						_aIteDes[ nPExist, 8 ] += oBrwX:aCols[ _nX, Iif( _lBase01, nPLr, nPAr ) ] // Somo a largura ou área da sobra, para o % rateio custo
					EndIf
				EndIf
			Next

		EndIf

	EndIf

Return _lRet

/* Faz a criação do produto para a nova dimensão da sobra */
Static Function CriaPrd( cPrd, nItSob )

	Local cDescB1 := ""
	Local cCodSBS := ""
	Local cCodBas := ""
	Local cDescR  := ""
	Local cDescPr := ""
	Local cSql    := ""
	Local cNewAli := ""
	Local cIntSob := ""
	Local cModSob := ""
	Local cCod    := Space( TamSX3("B1_COD")[1] )
	Local nPosLgs := aScan( oBrwX:aHeader, { |b| AllTrim( b[ 2 ] ) == "LARGUS" } ) // Base 02
	Local nPosCps := aScan( oBrwX:aHeader, { |b| AllTrim( b[ 2 ] ) == "COMPRS" } ) // Base 02
	Local nPosArs := aScan( oBrwX:aHeader, { |b| AllTrim( b[ 2 ] ) == "AREAM2" } ) // Base 02
	Local nPosSob := aScan( oBrwX:aHeader, { |b| AllTrim( b[ 2 ] ) == "SOBRAT" } ) // Apenas Base 01
	Local nPosPer := aScan( oBrwX:aHeader, { |b| AllTrim( b[ 2 ] ) == "PRDPER" } ) // Base 01 e 02
	Local nPosPai := aScan( oBrwX:aHeader, { |b| AllTrim( b[ 2 ] ) == "PRDPAI" } ) // Base 01 e 02
	Local _lTem   := .F.
	Local _lG     := .T.
	Local _lAtSBS := .F.
	Local nSobra  := 0
	Local nPosFim := 2
	Local nTamLrg := 0
	Local nTamCmp := 0
	Local aArea   := GetArea()
	Local aCodSBS := {}
	Local _cPrPer := ""
	Local _aIdSBQ := {}
	Local nConsPol := 25.4
	Local _aVldSBS := {}
	Private lMsHelpAuto

	ExecBlock('ChkPosBase',.F.,.F., {'IMDA641', ""})	
	cCodBas := U_A093Base( cPrd )
	ExecBlock('ChkPosBase',.F.,.F., {'IMDA641', cCodBas})	

	_aIdSBQ	 := A093ORetSBQ( cCodBas )
	
	For nFor := 1 To Len( _aIdSBQ )
		If AllTrim( _aIdSBQ[nFor][ 1 ] ) == "LRG"
			nTamLrg := _aIdSBQ[ nFor ][ 2 ]
		EndIf
		If AllTrim( _aIdSBQ[nFor][ 1 ] ) == "COM"
			nTamCmp := _aIdSBQ[ nFor ][ 2 ]
		EndIf
		If !( AllTrim( _aIdSBQ[nFor][ 1 ] ) $ "COM/LRG" )
			nPosFim += _aIdSBQ[ nFor ][ 2 ]
		EndIf
	Next

	_cPrPer := Left( cPrd, nPosFim )

	If Empty( oBrwX:aCols[ nItSob, nPosPer ] )

		// Verificar se largura do produto é medido em MM ou POL
		aUmPrPai := U_GetUmSBS( oBrwX:aCols[ nItSob, nPosPai ], "LRG", .F. )
		_lMM 	:= 	"MM" 	$ 	aUmPrPai[01]
		_lRibs	:=	"RIBS" 	$ 	aUmPrPai[01]

		// Montar a sobra
		nSobra := oBrwX:aCols[ nItSob, Iif( _lBase01, nPosSob, nPosLgs ) ]
		
		cNewAli := GetNextAlias()

		cSql := " SELECT BS_CODIGO, BS_DESCR, BS_DESCPRD FROM "+ RetSqlName("SBS")
		cSql += " WHERE BS_ID = 'LRG' AND D_E_L_E_T_ = ' ' AND BS_BASE = '"+ cCodBas +"' "
		//cSql += " AND BS_DESCR"+ Iif( _lMM, "  ", " NOT " ) +"LIKE '%MM%' "

		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),cNewAli,.F.,.T.)
		
		While !(cNewAli)->( Eof() )

			_lTem := Val( (cNewAli)->BS_DESCPRD ) == nSobra
			
			If _lTem 
			 	If _lRibs
					_lTem := AT("RIBS", (cNewAli)->BS_DESCR ) > 0
				ElseIf _lMM
					_lTem := AT("MM",   (cNewAli)->BS_DESCR ) > 0
				EndIf
			EndIf
						
			If _lTem
				_cPrPer := AllTrim( _cPrPer ) + AllTrim( (cNewAli)->BS_CODIGO )
				cCodSBS := (cNewAli)->BS_CODIGO
				Exit
			EndIf

			If Ascan(aCodSBS,  AllTrim( (cNewAli)->BS_CODIGO )) == 0
				aAdd( aCodSBS, AllTrim( (cNewAli)->BS_CODIGO ) )
			EndIf
			
			(cNewAli)->( dbSkip() )
		End

		If _lBase01
		
			If !_lTem
	
				ExecBlock('ChkPosBase',.F.,.F., {'IMDA641', cCodBas})
	
				cCodSBS := GetSBSNum( aCodSBS, nTamLrg )   // Determino o código SBS baseado nas lacunas da sequência
				cIntSob := cValToChar( Int( nSobra ) ) // Gero a parte inteira da medida da sobra, já como caractere para a descrição
				cModSob := StrZero( ( nSobra % Int( nSobra ) ) * 100, 2 ) // Gero a parte decimal da medida da sobra, já como caractere para a descrição
	
				cDescR  := IIF(_lMM, cIntSob + "MM", StrTran(cValToChar(nSobra), ".", ",") +IIF(_lRibs, "RIBS", "POL") )
				cDescPr := IIF(_lMM, cIntSob, cValToChar(nSobra))

				If !Empty(cCodSBS)

					DbSelectArea("SBS")
					RecLock("SBS",.T.)
						SBS->BS_FILIAL  := xFilial("SBS")
						SBS->BS_BASE    := cCodBas
						SBS->BS_ID      := 'LRG'
						SBS->BS_CODIGO  := cCodSBS
						SBS->BS_DESCR   := cDescR
						SBS->BS_DESCPRD := cDescPr
						SBS->BS_ATIVO   := '1'
					SBS->( MsUnLock() )
	
					Iif( Select('SBP') == 0, ( ChkFile('SBP'), DbSelectArea("SBP") ), )
					SBP->( dbGoTop() )
					A093VldBase( _cPrPer )         
					
					__ReadVar := "M->PRDPER"
					M->PRDPER := _cPrPer + cCodSBS
	
					lMsHelpAuto := .T. // Crio esta variável pois ela é consultada e quando existe não aparece o MontaCod do configurador de produtos
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³  UTILIZADO BEGIN TRANSACTION ANTES DO UPDATE QUE ALTERAR O BT_BASE PARA QUE O PRODUTO SOBRA   	³
					//³  A SER CRIADO NAO ENTRE NAS REGRAS DE VALIDACOES DO CONFIG.PRODUTO (TABELA SBT) 			  	³
					//|																								  	|
					//|  APOS CRIAR PRODUTO, VIA A093Prod(), Eh DESFEITO O UPDATE 			  	|
					//|  DESSA FORMA Eh CRIADO O PRODUTO, E EM OUTRAS TABELAS, E REPLICADO PARA AS OUTRAS FILIAIS  		|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Begin Transaction

						_cSBTQry := "UPDATE "+ RetSqlName("SBT") + " "
						_cSBTQry += "SET 	BT_BASE = '"+ AllTrim(cCodBas) +"_XX' "
						_cSBTQry += "WHERE 	BT_BASE = '"+ AllTrim(cCodBas) +"' "
						_cSBTQry += "AND 	D_E_L_E_T_ = ' '"
						_nRetQry := TCSQLExec( _cSBTQry )
		
						ExecBlock('ChkPosBase',.F.,.F., {'IMDA641', cCodBas} )
					
						_cFilBkp := cFilAnt  // Jean Rehermann - backup da filial atual antes de alterar o cfilant para 05 (criar produto apenas no 05)
						cFilAnt  := "05"

						Processa( {|| _lG := A093Prod(.T.,"M->PRDPER",_cPrPer+IIF(Len(_cPrPer+cCodSBS) != nTamCod, cCodSBS,'')) }, "Corte de Correias", "Criando o novo produto..." ) // Cria o produto pelo padrão
						
						cFilAnt := _cFilBkp

					End Transaction
	
					_cSBTQry := "UPDATE "+ RetSqlName("SBT") + " "
					_cSBTQry += "SET 	BT_BASE = '"+ AllTrim(cCodBas) +"' "
					_cSBTQry += "WHERE 	BT_BASE = '"+ AllTrim(cCodBas) +"_XX' "
					_cSBTQry += "AND 	D_E_L_E_T_ = ' '"
					_nRetQry := TCSQLExec( _cSBTQry )
	
					If _lG
						
						oBrwX:aCols[ nItSob, nPosPer ] := &( Readvar() )
						
						dbSelectArea("SBS")
						dbSetOrder(1)
						If dbSeek( xFilial("SBS") + cCodBas + PadR( 'LRG', TamSX3("BS_ID")[ 1 ] ) + cCodSBS )
							RecLock( "SBS", .F. )
								SBS->BS_ATIVO := "0"
							MsUnLock()
						EndIf
						
						oBrwX:oBrowse:Refresh()
					EndIf
	
				Else
					MsgAlert("Não foi possível determinar um código para a largura especificada!(SBS)")
				EndIf
	
			Else // Já existe o código no SBS para a largura, preciso verificar se existe o produto cadastrado com esta largura
	
				SB1->( dbSetOrder(1) )
				If !SB1->( dbSeek( xFilial("SB1") + _cPrPer ) )
					dbSelectArea("SBS")
					dbSetOrder(1)
					If dbSeek( xFilial("SBS") + cCodBas + PadR( 'LRG', TamSX3("BS_ID")[ 1 ] ) + cCodSBS )
						If SBS->BS_ATIVO == "0"
							RecLock("SBS",.F.)
								SBS->BS_ATIVO := "1"
								_lAtSBS := .T.
							SBS->( MsUnLock() )
						EndIf
					EndIf
					Iif( Select('SBP') == 0, ( ChkFile('SBP'), DbSelectArea("SBP") ), )
					SBP->( dbGoTop() )
					A093VldBase( _cPrPer )
					__ReadVar := "M->PRDPER"
					M->PRDPER := _cPrPer
	
					lMsHelpAuto := .T. // Crio esta variável pois ela é consultada e quando existe não aparece o MontaCod do configurador de produtos
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³  UTILIZADO BEGIN TRANSACTION ANTES DO UPDATE QUE ALTERAR O BT_BASE PARA QUE O PRODUTO SOBRA   	³
					//³  A SER CRIADO NAO ENTRE NAS REGRAS DE VALIDACOES DO CONFIG.PRODUTO (TABELA SBT) 			  	³
					//|																								  	|
					//|  APOS CRIAR PRODUTO, VIA A093Prod(), Eh DESFEITO O UPDATE 			  	|
					//|  DESSA FORMA Eh CRIADO O PRODUTO, E EM OUTRAS TABELAS, E REPLICADO PARA AS OUTRAS FILIAIS  		|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Begin Transaction

						_cSBTQry := "UPDATE "+ RetSqlName("SBT") + " "
						_cSBTQry += "SET 	BT_BASE = '"+ AllTrim(cCodBas) +"_XX' "
						_cSBTQry += "WHERE 	BT_BASE = '"+ AllTrim(cCodBas) +"' "
						_cSBTQry += "AND 	D_E_L_E_T_ = ' '"
						_nRetQry := TCSQLExec( _cSBTQry )
		
						ExecBlock('ChkPosBase',.F.,.F., {'IMDA641', cCodBas} )
					
						_cFilBkp := cFilAnt  // Jean Rehermann - backup da filial atual antes de alterar o cfilant para 05 (criar produto apenas no 05)
						cFilAnt  := "05"

						Processa( {|| _lG := A093Prod(.T.,"M->PRDPER",_cPrPer ) }, "Corte de Correias", "Criando o novo produto..." ) // Cria o produto pelo padrão

						cFilAnt := _cFilBkp
												
					End Transaction
	
					_cSBTQry := "UPDATE "+ RetSqlName("SBT") + " "
					_cSBTQry += "SET 	BT_BASE = '"+ AllTrim(cCodBas) +"' "
					_cSBTQry += "WHERE 	BT_BASE = '"+ AllTrim(cCodBas) +"_XX' "
					_cSBTQry += "AND 	D_E_L_E_T_ = ' '"
					_nRetQry := TCSQLExec( _cSBTQry )
	
					If _lAtSBS
						If dbSeek( xFilial("SBS") + cCodBas + PadR( 'LRG', TamSX3("BS_ID")[ 1 ] ) + cCodSBS )
							If SBS->BS_ATIVO == "1"
								RecLock("SBS",.F.)
									SBS->BS_ATIVO := "0"
									_lAtSBS := .F.
								SBS->( MsUnLock() )
							EndIf
						EndIf
					EndIf
					
					If _lG
						oBrwX:aCols[ nItSob, nPosPer ] := &( Readvar() )
					EndIf
				Else
					If ChkProdOk(_cPrPer, 'ATUAL')
						oBrwX:aCols[nItSob][nPosPer] := _cPrPer
					EndIf
				EndIf
	
				oBrwX:oBrowse:Refresh()
	
			EndIf

			(cNewAli)->( dbCloseArea() )

		ElseIf _lBase02 // Quando for correia aberta - Base 02
		    
			If _lTem
				dbSelectArea("SBS")
				dbSetOrder(1)
				If dbSeek( xFilial("SBS") + cCodBas + PadR( 'LRG', TamSX3("BS_ID")[ 1 ] ) + cCodSBS )
					If SBS->BS_ATIVO == "0"
						RecLock("SBS",.F.)
							SBS->BS_ATIVO := "1"
						SBS->( MsUnLock() )
						aAdd( _aVldSBS, { 'LRG', cCodSBS } ) // Adiciono neste array para controlar quais características inativas eu ativei
					EndIf
				EndIf
			Else
				cCodSBS := GetSBSNum( aCodSBS, nTamLrg )   // Determino o código SBS baseado nas lacunas da sequência
				cIntSob := cValToChar( Int( nSobra ) ) // Gero a parte inteira da medida da sobra, já como caractere para a descrição
	
				cDescR  := IIF( _lMM, cIntSob + "MM", StrTran( cValToChar( nSobra ), ".", "," ) + IIF(_lRibs, "RIBS", "POL") )
				cDescPr := IIF( _lMM, cIntSob, cValToChar( nSobra ) )
	
				If !Empty( cCodSBS )
					DbSelectArea("SBS");DbSetOrder(1)
					If !DbSeek(xFilial('SBS')+cCodBas+PadR('LRG',TamSx3('BS_ID')[01],'')+cCodSBS, .F.)
						RecLock("SBS",.T.)
							SBS->BS_FILIAL  := xFilial("SBS")
							SBS->BS_BASE    := cCodBas
							SBS->BS_ID      := 'LRG'
							SBS->BS_CODIGO  := cCodSBS
							SBS->BS_DESCR   := cDescR
							SBS->BS_DESCPRD := cDescPr
							SBS->BS_ATIVO   := '1'
						SBS->( MsUnLock() )
						aAdd( _aVldSBS, { 'LRG', cCodSBS } ) // Adiciono neste array para controlar quais características inativas eu ativei ou criei
					EndIf
					
					_cPrPer := AllTrim( _cPrPer ) + AllTrim( cCodSBS )
				EndIf
			EndIf
			
			// Comprimento da Sobra
			nSobra := oBrwX:aCols[ nItSob, nPosCps ]
			
			cNewAli := GetNextAlias()
	
			cSql := " SELECT BS_CODIGO, BS_DESCR, BS_DESCPRD FROM "+ RetSqlName("SBS")
			cSql += " WHERE BS_ID = 'COM' AND D_E_L_E_T_ = ' ' AND BS_BASE = '"+ cCodBas +"' "
	
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),cNewAli,.F.,.T.)
			
			While !(cNewAli)->( Eof() )
	
				_lTem := Val( (cNewAli)->BS_DESCR ) == nSobra
	
				If _lTem
					_cPrPer := AllTrim( _cPrPer ) + AllTrim( (cNewAli)->BS_CODIGO )
					cCodSBS := (cNewAli)->BS_CODIGO
					Exit
				EndIf
			
				If Ascan(aCodSBS,  AllTrim( (cNewAli)->BS_CODIGO )) == 0
					Aadd( aCodSBS, AllTrim( (cNewAli)->BS_CODIGO ) )
	        	EndIf
				(cNewAli)->( dbSkip() )
			End
			
			If _lTem
				dbSelectArea("SBS")
				dbSetOrder(1)
				If dbSeek( xFilial("SBS") + cCodBas + PadR( 'COM', TamSX3("BS_ID")[ 1 ] ) + cCodSBS )
					If SBS->BS_ATIVO == "0"
						RecLock("SBS",.F.)
							SBS->BS_ATIVO := "1"
						SBS->( MsUnLock() )
						aAdd( _aVldSBS, { 'COM', cCodSBS } ) // Adiciono neste array para controlar quais características inativas eu ativei
					EndIf
				EndIf
			Else
				cCodSBS := GetSBSNum( aCodSBS, nTamCmp )// Determino o código SBS baseado nas lacunas da sequência
				cDescR  := cValToChar( nSobra ) + "MM" // Como a sobra do comprimento é sempre em milimetros apenas converto para caracter
				cDescPr := cValToChar( nSobra / 1000 ) // A descriçao é em metros sem U.M.
	
				If !Empty( cCodSBS )    
					// BS_FILIAL+BS_BASE+BS_ID+BS_CODIGO
					DbSelectArea("SBS");DbSetOrder(1)
					If !DbSeek(xFilial('SBS')+cCodBas+PadR('COM',TamSx3('BS_ID')[01],'')+cCodSBS, .F.)
						RecLock("SBS",.T.)
							SBS->BS_FILIAL  := xFilial("SBS")
							SBS->BS_BASE    := cCodBas
							SBS->BS_ID      := 'COM'
							SBS->BS_CODIGO  := cCodSBS
							SBS->BS_DESCR   := cDescR
							SBS->BS_DESCPRD := cDescPr
							SBS->BS_ATIVO   := '1'
						SBS->( MsUnLock() )
						aAdd( _aVldSBS, { 'COM', cCodSBS } ) // Adiciono neste array para controlar quais características inativas eu ativei
					EndIf
					
					_cPrPer := AllTrim( _cPrPer ) + AllTrim( cCodSBS )
				EndIf
			EndIf

			SB1->( dbSetOrder(1) )
			If !SB1->( dbSeek( xFilial("SB1") + _cPrPer ) )

				Iif( Select('SBP') == 0, ( ChkFile('SBP'), DbSelectArea("SBP") ), )
				SBP->( dbGoTop() )
				A093VldBase( _cPrPer )
				__ReadVar := "M->PRDPER"
				M->PRDPER := _cPrPer

				lMsHelpAuto := .T. // Crio esta variável pois ela é consultada e quando existe não aparece o MontaCod do configurador de produtos
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³  UTILIZADO BEGIN TRANSACTION ANTES DO UPDATE QUE ALTERAR O BT_BASE PARA QUE O PRODUTO SOBRA   	³
				//³  A SER CRIADO NAO ENTRE NAS REGRAS DE VALIDACOES DO CONFIG.PRODUTO (TABELA SBT) 			  	³
				//|																								  	|
				//|  APOS CRIAR PRODUTO, VIA A093Prod(), Eh DESFEITO O UPDATE 			  	|
				//|  DESSA FORMA Eh CRIADO O PRODUTO, E EM OUTRAS TABELAS, E REPLICADO PARA AS OUTRAS FILIAIS  		|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Begin Transaction

					_cSBTQry := "UPDATE "+ RetSqlName("SBT") + " "
					_cSBTQry += "SET 	BT_BASE = '"+ AllTrim(cCodBas) +"_XX' "
					_cSBTQry += "WHERE 	BT_BASE = '"+ AllTrim(cCodBas) +"' "
					_cSBTQry += "AND 	D_E_L_E_T_ = ' '"
					_nRetQry := TCSQLExec( _cSBTQry )
	
					ExecBlock('ChkPosBase',.F.,.F., {'IMDA641', cCodBas} )
				
					_cFilBkp := cFilAnt  // Jean Rehermann - backup da filial atual antes de alterar o cfilant para 05 (criar produto apenas no 05)
					cFilAnt  := "05"
					
					Processa( {|| _lG := A093Prod(.T.,"M->PRDPER",_cPrPer ) }, "Corte de Correias", "Criando o novo produto..." ) // Cria o produto pelo padrão
					
					cFilAnt := _cFilBkp
				End Transaction

				_cSBTQry := "UPDATE "+ RetSqlName("SBT") + " "
				_cSBTQry += "SET 	BT_BASE = '"+ AllTrim(cCodBas) +"' "
				_cSBTQry += "WHERE 	BT_BASE = '"+ AllTrim(cCodBas) +"_XX' "
				_cSBTQry += "AND 	D_E_L_E_T_ = ' '"
				_nRetQry := TCSQLExec( _cSBTQry )

				For _nFor := 1 To Len( _aVldSBS )
					If dbSeek( xFilial("SBS") + cCodBas + PadR( _aVldSBS[ _nFor, 1 ], TamSX3("BS_ID")[ 1 ] ) + _aVldSBS[ _nFor, 2 ] )
						If SBS->BS_ATIVO == "1"
							RecLock("SBS",.F.)
								SBS->BS_ATIVO := "0"
							SBS->( MsUnLock() )
						EndIf
					EndIf
				Next
				
				If _lG
					oBrwX:aCols[ nItSob, nPosPer ] := &( Readvar() )
				EndIf

			Else
				oBrwX:aCols[ nItSob, nPosPer ] := _cPrPer
			EndIf

			oBrwX:oBrowse:Refresh()

		EndIf
		
	EndIf

	RestArea( aArea )

Return()

/* Seleciono uma numeração válida para o código da SBS que vou criar */
Static Function GetSBSNum( aNumSBS, nTam )

	Local _cCod := Space( nTam )
	Local _cTmp := ""
	
	// Ordeno de menor para maior
	aSort( aNumSBS,,, { |x,y| x < y } )
	_cTmp := StrZero( 0, nTam )
	
	For _nC := 1 To Len( aNumSBS )

		_cTmp := Soma1( _cTmp )
		
		If aNumSBS[ _nC ] != _cTmp
			_cCod := _cTmp
			Exit
		EndIf
		
	Next

	_cCod := Iif( Empty( _cCod ), Soma1( _cTmp ), _cCod )

Return _cCod

/* Valida para que seja informado o produto para sobra ou perda */
Static Function VlBrwSob()

	Local _lOk 	:= .T.
	Local nPPr 	:=	aScan( oBrwX:aHeader, { |b| AllTrim( b[ 2 ] ) == "PRDPER" } )
	Local nPrdP := 	aScan( oBrwX:aHeader, { |b| AllTrim( b[ 2 ] ) == "PRDPAI" } )


	For _nX := 1 To Len( oBrwX:aCols )
		If Empty(oBrwX:aCols[_nX][nPPr])
			_lOk := .F.
			MsgYesNo("Existe item sem produto informado. Informar todos os produtos para sobra ou perda.")
			Exit
		Else
			cBrwPPai := oBrwX:aCols[_nX][nPrdP]
			_lOk 	 := ChkProdOk(cBrwPPai)
		EndIf
	Next

Return(_lOk)

/* Monta o grid com os produtos para serem cortados | aPTm = Array com as coordenadas de tela */
Static Function fGrid1( aPTm )

	Local nX
	Local aHeaderB := {}
	Local aColsB   := {}
	Local aEditCpo := {}
	Local aVarsSBS := {}
	Local aIdSBQ   := {}
	Local lCLocal  := .F.
	Local cFam     := ""
	Local cBase    := ZXA->ZXA_CODBAS
	Local _nSeq    := 1
	Local nPosMat, nPosFam, nPosRef, nPosLgr, nTamCorr // Variáveis para definir tamanho do código do produto
	Local cAlias2  := GetNextAlias()
	Local aAreaAtu2
	
	// 
	aAdd( aHeaderB, { "..."        , "MARCA" , "@!", 001, 0 , "" , "" , "C" , ""})
	aAdd( aHeaderB, { "Seq.       ", "SEQUEN", "@!", 003, 0 , "" , "" , "C" , ""})
	aAdd( aHeaderB, { "Código     ", "CODIGO", "@!", TamSx3('UB_PRODUTO')[01], 0 , "" , "" , "C" , "SB1"})
	aAdd( aHeaderB, { "Quantidade ", "SALDO" , "@E 9,999.99", TamSx3('UB_QUANT')[01]  , TamSx3('UB_QUANT')[02] , "" , "" , "N" , ""})
	aAdd( aHeaderB, { "Largura    ", "LARGUR", "@E 9,999.99", 7, 2, "" , "" , "N" , ""})
	aAdd( aHeaderB, { "Unid.Medida", "UMLARG", "@!", 003, 0 , "" , "" , "C" , ""})
	aAdd( aHeaderB, { "Comprimento", "COMPRI", "@E 999,999.99", 10, 2, "" , "" , "N" , ""})
	aAdd( aHeaderB, { "Área em M² ", "AREATT", "@E 999,999.9999", 12, 4, "" , "" , "N" , ""})
	If _lBase01
		aAdd( aHeaderB, { "Saldo/Sobra", "SOBRAU", "@E 9,999.99", 8, 2, "" , "" , "N" , ""})
	Else
		aAdd( aHeaderB, { "Saldo/Sobra", "SOBRAU", "@E 999,999.9999", 12, 4, "" , "" , "N" , ""})
	EndIf
	aAdd( aHeaderB, { "Endereço   ", "ENDERE", "@!", TamSx3('BF_LOCALIZ')[01], 0, "" , "" , "C" , ""})
	aAdd( aHeaderB, { "Local      ", "LOCALP", "@!", TamSx3('B2_LOCAL')[01], 0, "" , "" , "C" , ""})
	aAdd( aHeaderB, { "Descrição  ", "DESCRI", "@!", TamSx3('B1_DESC')[01], 0, "", "", "C", "" })

	aAdd( aEditCpo, "MARCA" )

	ExecBlock('ChkPosBase',.F.,.F., {'IMDA641', ""})
	cBase := U_A093Base( PadR( ZXB->ZXB_PRODUT, TamSX3("B1_COD")[ 1 ] ) )
	SBP->( dbSeek( xFilial("SBP") + cBase ) )

	aVarSBS := A093SBSVars( ZXB->ZXB_PRODUT )
	cFam    := aVarSBS[ aScan( aVarSBS, {|o| AllTrim( o[ 1 ] ) == 'FAM' } ) ][02]
	aUmLrgF := U_GetUmSBS( ZXB->ZXB_PRODUT, "LRG", .T. ) // Largura do filho, convertida em MM se for em POL

	// Preparo a busca pelos PAs
	aIdSBQ	 := A093ORetSBQ( cBase )

	nPosMat	 := Ascan( aIdSBQ, { |X| AllTrim( X[ 01 ] ) == 'MAT' } )
	nPosFam	 := Ascan( aIdSBQ, { |X| AllTrim( X[ 01 ] ) == 'FAM' } )
	nPosRef	 := Ascan( aIdSBQ, { |X| AllTrim( X[ 01 ] ) == 'REF' } )
			
	nTamCorr := Len( AllTrim( cBase ) ) + aIdSBQ[ nPosMat ][ 02 ] + aIdSBQ[ nPosFam ][ 02 ] + aIdSBQ[ nPosRef ][ 02 ]
			
	//If AllTrim( cBase ) == "02"
	//	nPosLgr	 := Ascan( aIdSBQ, { |X| AllTrim( X[ 01 ] ) == 'LRG' } )
	//	nTamCorr += aIdSBQ[ nPosLgr ][ 02 ]
	//EndIf
			
	cQuery := "SELECT B1_FILIAL, B1_COD, B1_DESC, B2_LOCAL, B2_QATU "
	cQuery += " FROM "+ RetSqlName("SB1") +" SB1, "+ RetSqlName("SB2") +" SB2 "
	cQuery += " WHERE B1_COD LIKE '"+ SubStr( ZXB->ZXB_PRODUT, 1, nTamCorr ) +"%' "
	cQuery += " AND B1_FILIAL = '"+ xFilial("SB1") +"' "
	cQuery += " AND B1_COD = B2_COD AND SB1.D_E_L_E_T_ = ' ' AND SB2.D_E_L_E_T_ = ' ' "
	cQuery += " AND SB2.B2_QATU > 0 AND B2_FILIAL = '"+ xFilial("SB2") +"' AND B1_MSBLQL <> '1' "

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias2,.F.,.T.)

	While !(cAlias2)->( Eof() )

		ExecBlock('ChkPosBase',.F.,.F., {'IMDA641', cBase})
		SBP->( dbSeek( xFilial("SBP") + cBase ) )
		aVarSBS  := A093SBSVars( (cAlias2)->B1_COD ) 
		nPos     := Ascan( aVarSBS, {|o|  AllTrim( o[01] ) == 'LRG' } )
		nLargAtu := Iif( nPos > 0, Val( aVarSBS[nPos][03] ), 0 )
		nPos     := Ascan( aVarSBS, {|o|  AllTrim( o[01] ) == 'COM' } )
		nCompAtu := Iif( nPos > 0, Val( aVarSBS[nPos][03] ) * 1000, 0 )
		aUmLarg  := U_GetUmSBS( (cAlias2)->B1_COD, "LRG", .T. )
		nAreaAtu := Round( Iif( nCompAtu > 0, ( nCompAtu / 1000 ) * ( aUmLarg[ 3 ] / 1000 ), 0 ), 4 )
		
		If aUmLarg[ 3 ] < aUmLrgF[ 3 ] // Se LARGURA do PAI for MENOR que a LARGURA do FILHO, dispensa o mesmo.
			(cAlias2)->( dbSkip() )
			Loop
		EndIf
		
		aUmLrgO  := U_GetUmSBS( (cAlias2)->B1_COD, "LRG", .F. )
		
		lCLocal  := Localiza( (cAlias2)->B1_COD )

		If lCLocal
		
			aAreaAtu2 := GetArea()

			dbSelectArea("SBF")
			dbSetOrder(2)
			If dbSeek( (cAlias2)->B1_FILIAL + (cAlias2)->B1_COD + (cAlias2)->B2_LOCAL )
				While !SBF->( EOF() ) .And. (cAlias2)->B1_FILIAL + (cAlias2)->B1_COD + (cAlias2)->B2_LOCAL == SBF->BF_FILIAL + SBF->BF_PRODUTO + SBF->BF_LOCAL

					_nQtdSBF := SBF->BF_QUANT // - SBF->BF_EMPENHO

					For _nG := 1 To _nQtdSBF
						aAdd( aColsB, { Space(5), StrZero(_nSeq++,3), (cAlias2)->B1_COD, 1, nLargAtu, aUmLrgO[1],nCompAtu, nAreaAtu, Iif( _lBase01, nLargAtu, nAreaAtu ), SBF->BF_LOCALIZ, SBF->BF_LOCAL,(cAlias2)->B1_DESC, .F. } )
					Next

					SBF->( dbSkip() )
				End
			EndIf
		Else
			For _nG := 1 To (cAlias2)->B2_QATU
				aAdd( aColsB, { Space(5), StrZero(_nSeq++,3), (cAlias2)->B1_COD, 1, nLargAtu, aUmLarg[1], nCompAtu, nAreaAtu, Iif( _lBase01, nLargAtu, nAreaAtu ), "", (cAlias2)->B2_LOCAL,(cAlias2)->B1_DESC, .F. } )
			Next
        EndIf

		(cAlias2)->( dbSkip() )
	End
	(cAlias2)->( dbCloseArea() )

	If Len( aColsB ) > 0
		_nPosX := aScan( aHeaderB, { |o| AllTrim( o[2] ) == Iif( AllTrim( cBase ) == "01", "LARGUR", "COMPRI" ) } )
		If _lBase01
			aSort( aColsB, , , { |x,y| x[_nPosX] > y[_nPosX] } )
		ElseIf _lBase02
			aSort( aColsB, , , { |x,y| x[_nPosX] < y[_nPosX] } ) // Se for correia aberta as primeiras serão as mais estreitas
		EndIf
		aColsB[ 1, 1 ] := "  X  "
    EndIf
    
	oBrwB := MsNewGetDados():New(aPTm[1],aPTm[2],aPTm[3],aPTm[4],GD_UPDATE,'AllwaysTrue()','AllwaysTrue()','',aEditCpo,1,999,,'','', oDlg, aHeaderB, aColsB )
	oBrwB:oBrowse:bLDblClick := {|| DbClickG(), oBrwB:oBrowse:Refresh() }

Return()

/* Monta o grid com os itens do plano de corte | aPTm = Array com as coordenadas de tela */
Static Function fGrid2( aPTm )

	Local nX
	Local aHeaderA := {}
	Local aColsA   := {}
	Local aVarSBS := {}

	Aadd(aHeaderA, {"It.Corte   ", "ITEMC" , "@!"              , 2, 0, "" , "" , "C" , ""})
	Aadd(aHeaderA, {"Código     ", "CODIGO", "@!"              , TamSx3('UB_PRODUTO')[01], 0 , "" , "" , "C" , ""})
	Aadd(aHeaderA, {"Quantid.   ", "QUANT" , "@E 999,999.99"   , TamSx3('UB_QUANT')[01]  , TamSx3('UB_QUANT')[02] , "" , "" , "N" , ""})
	Aadd(aHeaderA, {"Atendido   ", "ATEND" , "@E 999,999.99"   , TamSx3('UB_QUANT')[01]  , TamSx3('UB_QUANT')[02] , "" , "" , "N" , ""})
	Aadd(aHeaderA, {"Largura    ", "LARGU" , "@E 999,999.99"   ,10, 2, "" , "" , "N" , ""})
	Aadd(aHeaderA, {"Un.Medida  ", "UMLRG" , "@!"              , 3, 0, "" , "" , "C" , ""})
	Aadd(aHeaderA, {"Comprimento", "COMPR" , "@E 999,999.99"   ,10, 2, "" , "" , "N" , ""})
	Aadd(aHeaderA, {"Área M² Uni", "AREAU" , "@E 999,999.9999" ,12, 4, "" , "" , "N" , ""})
	Aadd(aHeaderA, {"Área M² Tot", "AREAT" , "@E 999,999.9999" ,12, 4, "" , "" , "N" , ""})
	Aadd(aHeaderA, {"Fil.Ori.   ", "FILOR" , "@!"              , 2, 0, "" , "" , "C" , ""})
	Aadd(aHeaderA, {"P.Venda    ", "NUMPV" , "@!"              , 6, 0, "" , "" , "C" , ""})
	Aadd(aHeaderA, {"Item PV    ", "ITMPV" , "@!"              , 7, 2, "" , "" , "C" , ""})
	Aadd(aHeaderA, {"Observações", "OBSERV", "@!"              ,90, 0, "" , "" , "C" , ""})
	
	dbSelectArea("ZXB")
	dbSetOrder(1)
	dbSeek( ZXA->ZXA_FILIAL + ZXA->ZXA_NUMCRT )
	
	While !ZXB->( Eof() ) .And. ZXA->ZXA_FILIAL + ZXA->ZXA_NUMCRT == ZXB->ZXB_FILIAL + ZXB->ZXB_NUMCRT
	
		Iif( Select('SBP') == 0, ( ChkFile('SBP'), DbSelectArea("SBP") ), )
		SBP->( dbSeek( xFilial("SBP") + ZXA->ZXA_CODBAS ) )
		aVarSBS  := A093SBSVars(ZXB->ZXB_PRODUT) 
		nPos     := Ascan( aVarSBS, {|o|  AllTrim( o[01] ) == 'LRG' } )
		nLargAtu := Iif( nPos > 0, Val( aVarSBS[nPos][03] ), 0 )
		nPos     := Ascan( aVarSBS, {|o|  AllTrim( o[01] ) == 'COM' } )
		nCompAtu := Iif( nPos > 0, Val( aVarSBS[nPos][03] ) * 1000, 0 )
		aUmLarg  := U_GetUmSBS( ZXB->ZXB_PRODUT, "LRG", .T. )
		nAreaAtu := Round( Iif( nCompAtu > 0, ( nCompAtu / 1000 ) * ( aUmLarg[ 3 ] / 1000 ), 0 ), 4 )
		nAreaAtt := nAreaAtu * ZXB->ZXB_QTD
		aUmLrgO  := U_GetUmSBS( ZXB->ZXB_PRODUT, "LRG", .F. )
		
		aAdd( aColsA, { ZXB->ZXB_ITEM, ZXB->ZXB_PRODUT, ZXB->ZXB_QTD, 0, nLargAtu, aUmLrgO[1], nCompAtu, nAreaAtu, nAreaAtu * ZXB->ZXB_QTD, ZXB->ZXB_FILORI, ZXB->ZXB_PEDIDO, ZXB->ZXB_ITEMPV, ZXB->ZXB_OBS, .F. } )
		
		ZXB->( dbSkip() )
	End
	
	If Len( aColsA ) > 0
		_nPosX := aScan( aHeaderA, { |o| AllTrim( o[2] ) == Iif( AllTrim( ZXA->ZXA_CODBAS ) == "01", "LARGU", "COMPR" ) } )
		aSort( aColsA, , , { |x,y| x[_nPosX] > y[_nPosX] } )
	EndIf
	
	oBrwA := MsNewGetDados():New(aPTm[1],aPTm[2],aPTm[3],aPTm[4],GD_UPDATE,'AllwaysTrue()','AllwaysTrue()','',{},0,999,,'','AllwaysTrue()', oDlg, aHeaderA, aColsA )
	oBrwA:oBrowse:bLDblClick := {|| DbClkCrt() }
	oBrwA:oBrowse:SetFocus()

Return()

/* Faz a atualização dos saldos em tela pela seleção dos itens para o corte */
Static Function DbClkCrt()

	Local nSobraP := nLargF := nLargP := nAtend := nQtdUni := nQtModu := 0
	Local nQtTira := nPos := _nS := _nAreaF := _nAreaP := 0

	Local nPosQtd := Ascan( oBrwA:aHeader,{ |X| AllTrim( x[ 2 ] ) == "QUANT" } )
	Local nPosAte := Ascan( oBrwA:aHeader,{ |X| AllTrim( x[ 2 ] ) == "ATEND" } )
	Local nPosLrg := Ascan( oBrwA:aHeader,{ |X| AllTrim( x[ 2 ] ) == "LARGU" } )
	Local nPosIte := Ascan( oBrwA:aHeader,{ |X| AllTrim( x[ 2 ] ) == "ITEMC" } )
	Local nPosCod := Ascan( oBrwA:aHeader,{ |X| AllTrim( x[ 2 ] ) == "CODIGO"} )
	Local nPosPvF := Ascan( oBrwA:aHeader,{ |X| AllTrim( x[ 2 ] ) == "FILOR" } )
	Local nPosPvN := Ascan( oBrwA:aHeader,{ |X| AllTrim( x[ 2 ] ) == "NUMPV" } )
	Local nPosPvI := Ascan( oBrwA:aHeader,{ |X| AllTrim( x[ 2 ] ) == "ITMPV" } )
	Local nPosCpf := Ascan( oBrwA:aHeader,{ |X| AllTrim( x[ 2 ] ) == "COMPR" } )
	Local nPosArf := Ascan( oBrwA:aHeader,{ |X| AllTrim( x[ 2 ] ) == "AREAU" } )
	
	Local nPMarca := Ascan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "MARCA" } )
	Local nPosSob := Ascan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "SOBRAU"} )
	Local nPosLrp := Ascan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "LARGUR"} )
    Local nPosCpp := Ascan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "COMPRI"} )
    Local nPosArp := Ascan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "AREATT"} )
	Local nPosSeq := Ascan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "SEQUEN"} )
	Local nPosPro := Ascan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "CODIGO"} )
	Local nPosEnd := Ascan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "ENDERE"} )
	Local nPosLoc := Ascan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "LOCALP"} )
	Local nPosUml := Ascan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "UMLARG"} )
	Local nLinPai := Ascan( oBrwB:aCols,{ |X| AllTrim( x[ nPMarca ] ) == "X" } )
	
	// Já foram selecionadas as peças que atendem este item do corte
	If oBrwA:aCols[ oBrwA:nAt, nPosAte ] == oBrwA:aCols[ oBrwA:nAt, nPosQtd ]
		MsgAlert("Item já atendido!")
		Return
	EndIf
	
	// Se o saldo a cortar é menor do que a largura da peça que eu quero cortar
	If _lBase01 .And. oBrwB:aCols[ nLinPai, nPosSob ] < oBrwA:aCols[ oBrwA:nAt, nPosLrg ]
		MsgAlert("Largura insuficiente para atender este item!")
		Return
	EndIf

	// Se a largura do pai é igual à largura do filho
	If _lBase01 .And. oBrwB:aCols[ nLinPai, nPosLrp ] == oBrwA:aCols[ oBrwA:nAt, nPosLrg ]
		MsgAlert("Largura do pai não pode ser igual à do filho!")
		Return
	// Se largura e comprimento são iguais o produto pai é igual ao produto filho
	ElseIf _lBase02 .And. oBrwB:aCols[ nLinPai, nPosCpp ] == oBrwA:aCols[ oBrwA:nAt, nPosCpf ] .And.;
	       oBrwB:aCols[ nLinPai, nPosLrp ] == oBrwA:aCols[ oBrwA:nAt, nPosLrg ]
		MsgAlert("Este produto (PAI) atende tanto à largura quanto ao comprimento, não precisa ser cortado!")
		Return
	// Comprimento do pai menor que o do filho
	ElseIf _lBase02 .And. oBrwB:aCols[ nLinPai, nPosCpp ] < oBrwA:aCols[ oBrwA:nAt, nPosCpf ] .And.;
	       oBrwB:aCols[ nLinPai, nPosLrp ] >= oBrwA:aCols[ oBrwA:nAt, nPosLrg ]
		MsgAlert("Comprimento insuficiente para atender este item!")
		Return
	EndIf

	If _lBase01
	
		nSobraP := oBrwB:aCols[ nLinPai, nPosSob ]    // Sobra do pai
		nLargF  := oBrwA:aCols[ oBrwA:nAt, nPosLrg ]  // Largura do filho
	
		nAtend := oBrwA:aCols[ oBrwA:nAt, nPosAte ] // Quantidade já atendida
		
		// Enquanto a sobra do pai for maior do que a largura do filho
		While nSobraP >= nLargF
			
			// Para cada peça "cortada", diminuo da sobra do pai a largura da peça do filho
			nAtend++
			nSobraP -= nLargF
			
			// Verifico quantas peças serão geradas unicamente para este item, para a desmontagem
			nQtdUni++
			
			// If a quantidade cortada já atendeu a necessidade, saio do while
			If nAtend == oBrwA:aCols[ oBrwA:nAt, nPosQtd ]
				Exit
			EndIf
			
		End
		
		oBrwA:aCols[ oBrwA:nAt, nPosAte ] := nAtend
		oBrwB:aCols[ nLinPai, nPosSob ]   := nSobraP
    
	ElseIf _lBase02
		
		nLinFil := oBrwA:nAt
		nLargF  := oBrwA:aCols[ nLinFil, nPosLrg ] // Largura do filho
		nLargP  := oBrwB:aCols[ nLinPai, nPosLrp ] // Largura do pai
		cUmLrg  := oBrwB:aCols[ nLinPai, nPosUml ] // Unidade de medida da Largura
		nCompF  := oBrwA:aCols[ nLinFil, nPosCpf ] // Comprimento do filho
		nCompP  := oBrwB:aCols[ nLinPai, nPosCpp ] // Comprimento do pai
		nAreaF  := oBrwA:aCols[ nLinFil, nPosArf ] // Área unitária dos filhos cortados
		nAreaP  := oBrwB:aCols[ nLinPai, nPosArp ] // Área total do pai
		nAtend  := oBrwA:aCols[ nLinFil, nPosAte ] // Quantidade já atendida
		
		// Verificar se este produto pai já está no array (se já foi utilizado alguma vez para atender algum filho)
		nPos := aScan( _aSobra, { |X| AllTrim( x[ 1 ] ) == oBrwB:aCols[ nLinPai, nPosSeq ] } )

		// Se não foi utilizado, incluo o número sequencial que identifica o item pai no array das sobras
		// _aSobra[ Seq.Pai, { array das tiras* }, Módulo da largura**, Saldo em M2 ]
		If nPos == 0
			aAdd( _aSobra, { oBrwB:aCols[ nLinPai, nPosSeq ], { }, 0, nAreaP } )
			nPos := Len( _aSobra )
			
			nQtTira := Int( nLargP / nLargF ) // *lrg. pai dividido pela lrg. filho (quantas tiras de mesma lrgura do filho consigo cortar com este PAI)

			// Incluo a dimensão de comprimento do pai para cada tira, pois cada tira pode gerar uma sobra
			For _nS := 1 To nQtTira
				aAdd( _aSobra[ nPos, 2 ], nCompP )
			Next

			nQtModu := nLargP - ( nLargF * nQtTira ) // **retorna a diferença das tiras
			_aSobra[ nPos, 3 ] :=  nQtModu   // armazeno a informação para ser utilizada no tratamento das sobras
			
		EndIf
		
		// Após posicionar no array correspondente, pego o array de tiras e ordeno de menor para maior (tudo o que for menor que a largura do pai é sobra)
		_aTiras := _aSobra[ nPos, 2 ]
		aSort( _aTiras,,, { |x,y| x < y } )
		
		For _nS := 1 To Len( _aTiras )
			
			// A sobra da tira no sentido do comprimento
			nSobraP := _aTiras[ _nS ]
			
			// Enquanto couber um comprimento do filho dentro da sobra do pai
			While nSobraP >= nCompF
				
				// Para cada peça "cortada", diminuo da sobra do pai o comprimento da peça do filho
				nAtend++
				nSobraP -= nCompF
				
				// Diminuo da area total do pai a área do filho recém cortado
				_aSobra[ nPos, 4 ] -= nAreaF
				
				// Verifico quantas peças serão geradas unicamente para este item, para a desmontagem (posso usar várias desmontagens)
				nQtdUni++
				
				_aTiras[ _nS ] := nSobraP // Atualizo a sobra da tira no item do array de tiras correspondente
				
				// Se a quantidade cortada já atendeu a necessidade, saio do while
				If nAtend == oBrwA:aCols[ nLinFil, nPosQtd ]
					Exit
				EndIf
				
			End
			
			_aSobra[ nPos, 2 ] := _aTiras
				        
			// Se a quantidade cortada já atendeu a necessidade, saio do for das tiras
			If nAtend == oBrwA:aCols[ nLinFil, nPosQtd ]
				Exit
			EndIf

		Next
        
		oBrwA:aCols[ oBrwA:nAt, nPosAte ] := nAtend
		oBrwB:aCols[ nLinPai, nPosSob ] := _aSobra[ nPos, 4 ]

	EndIf

	oBrwA:oBrowse:Refresh()
	oBrwB:oBrowse:Refresh()

	// Verificando se este produto pai já está no array do cabeçalho da desmontagem, verifico pelo número da sequencia
	_nPos := aScan( _aCabDes, { |n| n[ 1 ] == oBrwB:aCols[ nLinPai, nPosSeq ] } )
		
	If _nPos == 0
		// [01] Sequencia / [02] Produto / [03] Endereco / [04] Local / [05] Largura do Pai
		aAdd( _aCabDes, { oBrwB:aCols[ nLinPai, nPosSeq ], oBrwB:aCols[ nLinPai, nPosPro ], oBrwB:aCols[ nLinPai, nPosEnd ], oBrwB:aCols[ nLinPai, nPosLoc ], oBrwB:aCols[ nLinPai, nPosLrp ] } )
	EndIf

	// Quando o produto já existir ns itens, apenas somo a quantidade e a dimensão total (a dimensão calcula o custo proporcional na desmontagem)
	nPExist := aScan( _aIteDes, { |o| AllTrim( o[ 1 ] ) == oBrwB:aCols[ nLinPai, nPosSeq ] .And. AllTrim( o[ 3 ] ) == AllTrim( oBrwA:aCols[ oBrwA:nAt, nPosCod ] ) } )
	
	// Verifico se existe pedido de venda para armazenar no array dentro do elemento de _aIteDes
	_lTemPv := !Empty( AllTrim( oBrwA:aCols[ oBrwA:nAt, nPosPvF ] ) )
			
	// Se base 01 traz a largura na unidade atual, se base 02 traz a largura convertida para milimetro se estiver em polegadas
	nLargF := U_GetUmSBS( oBrwA:aCols[ oBrwA:nAt, nPosCod ], "LRG", _lBase02 )[ 3 ]
	
	If nPExist == 0 // Item da desmontagem não existente no array para este produto PAI
			
		_aFlTmp := Iif( _lTemPv, { oBrwA:aCols[ oBrwA:nAt, nPosPvF ] }, {} ) // Filial
		_aPvTmp := Iif( _lTemPv, { oBrwA:aCols[ oBrwA:nAt, nPosPvN ] }, {} ) // Pedido
		_aItTmp := Iif( _lTemPv, { oBrwA:aCols[ oBrwA:nAt, nPosPvI ] }, {} ) // Item
	
		aAdd( _aIteDes,	{ oBrwB:aCols[ nLinPai, nPosSeq ],;       // [01] SEQ. DO PAI (para controle dos itens)
                          oBrwA:aCols[ oBrwA:nAt, nPosIte ],;     // [02] ITEM DO PLANO DE CORTE
                          oBrwA:aCols[ oBrwA:nAt, nPosCod ],;     // [03] PRODUTO
                          nQtdUni,;                               // [04] QUANTIDADE
                          _aFlTmp,;                               // [05] FILIAL DE ORIGEM
                          _aPvTmp,;                               // [06] PEDIDO  - FILIAL DE ORIGEM
                          _aItTmp,;                               // [07] ITEM PV - FILIAL DE ORIGEM
                          ( Iif( _lBase01, nLargF, Iif( _lBase02, nAreaF, 1 ) ) * nQtdUni ),; // [08] ( LARG ou M2 ) * QTD
                          cEndPad,;                               // [09] ENDEREÇO PADRAO CORTE
                          { nQtdUni };                            // [10] QUANTIDADE (preservo a quantidade original de cada filial+pedido+item para tratar reserva)
                        } )
	Else // Já existe este item para este produto PAI no array
		
		// Somo a quantidade do filho [ 04 ] utilizada na desmontagem
		_aIteDes[ nPExist, 4 ] += nQtdUni              
		// Somo a largura ou M2 do filho [ 08 ] utilizado no cálculo do custo
		_aIteDes[ nPExist, 8 ] += ( Iif( _lBase01, nLargF, Iif( _lBase02, ( nCompF / 1000 ) * ( nLargF / 1000 ), 1 ) ) * nQtdUni ) 
			
		// Apenas armazeno a informação quando houver pedido amarrado ao item do corte
		If _lTemPv
		
			aAdd( _aIteDes[ nPExist, 05 ], oBrwA:aCols[ oBrwA:nAt, nPosPvF ] ) // Filial
			aAdd( _aIteDes[ nPExist, 06 ], oBrwA:aCols[ oBrwA:nAt, nPosPvN ] ) // Pedido
			aAdd( _aIteDes[ nPExist, 07 ], oBrwA:aCols[ oBrwA:nAt, nPosPvI ] ) // Item
			aAdd( _aIteDes[ nPExist, 10 ], nQtdUni )                           // Quantidade no item (para tratar a exclusão da reserva e liberação do pedido)
		
		EndIf
		
	EndIf
		
Return

/* Atualiza a marca no browse dos produtos */
Static Function DbClickG()
	
	Local nPMarca := Ascan(oBrwB:aHeader,{|X| AllTrim(x[2]) == "MARCA"})
	Local nJaMarc := Ascan(oBrwB:aCols,  {|X| X[nPMarca]    == "  X  "}) 
	
	If nJaMarc > 0
		oBrwB:aCols[nJaMarc][nPMarca] := ''
	EndIf
	
	oBrwB:aCols[oBrwB:nAT][nPMarca] := Iif( Empty( oBrwB:aCols[oBrwB:nAT][nPMarca] ), "  X  ", "     " )
	oBrwA:oBrowse:SetFocus()
	
Return()

/* Impressão do plano de corte */
User Function IMD641Re()

	Local cDesc1        := "Este programa tem como objetivo imprimir o espelho "
	Local cDesc2        := "do plano de corte de acordo com os parâmetros.     "
	Local cDesc3        := "Impressão da Ordem de Corte"
	Local cPict         := ""
	Local titulo        := "Impressão da Ordem de Corte"
	Local nLin          := 80
	Local Cabec1        := " IMDEPA                           ORDEM DE CORTE DE CORREIAS No. "+ ZXA->ZXA_NUMCRT +"                       Inclusão: "+ DtoC(ZXA->ZXA_DATA)
	Local Cabec2        := ""
	Local imprime       := .T.
	Local cPerg         := "IMD641REL"
	Local aOrd          := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "IMD641RE" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "IMD641RE" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString     := "ZXA"
	
	CriaSX1Rel( cPerg )
	Pergunte( cPerg, .F. )
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	   Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	
	RptStatus( {|| SelPlcRel( Cabec1, Cabec2, Titulo, nLin ) }, Titulo )

Return

/* Seleciona os planos de corte de acordo com os parâmetros selecionados */
Static Function SelPlcRel( Cabec1, Cabec2, Titulo, nLin )

	If mv_par01 == 1

		dbSelectArea("ZXA")
		dbSetOrder(1)
		dbSeek( xFilial("ZXA") + mv_par04, .T. )
		
		While !ZXA->( Eof() ) .And. ZXA->ZXA_FILIAL == xFilial("ZXA") .And. ZXA->ZXA_NUMCRT <= mv_par05
			
			If ZXA->ZXA_REF > mv_par03 .Or. ZXA->ZXA_REF < mv_par02
				ZXA->( dbSkip() )
				Loop
			EndIf
			
			If ( mv_par06 == 1 .And. !(ZXA->ZXA_STATUS $ "ACI") ) .Or. ( mv_par06 == 2 .And. ZXA->ZXA_STATUS != "E" )
				ZXA->( dbSkip() )
				Loop
			EndIf
			Cabec1 := " IMDEPA                           ORDEM DE CORTE DE CORREIAS No. "+ ZXA->ZXA_NUMCRT +"                       Inclusão: "+ DtoC(ZXA->ZXA_DATA)
			RunReport( Cabec1, Cabec2, Titulo, nLin )
			
			ZXA->( dbSkip() )
		End
		
	Else
		RunReport( Cabec1, Cabec2, Titulo, nLin )
	EndIf

	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()
	
Return

/* Tem os dados pra a impressão da ordem de corte */
Static Function RunReport( Cabec1, Cabec2, Titulo, nLin )

	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
	Endif

	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
		nLin := 8
	Endif
	/*             1         2         3         4         5         6         7         8         9        10        11        12        13   */
	/*    123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012 */
	Do Case
		Case ZXA->ZXA_STATUS == "A"
			_cStsDes := "Aberto"
		Case ZXA->ZXA_STATUS == "E"
			_cStsDes := "Encerrado"
		Case ZXA->ZXA_STATUS == "I"
			_cStsDes := "Interrompido"
	EndCase	

	@nLin, 001 PSAY "Geração: "+ Iif( ZXA->ZXA_TIPO == "A", "Automática", "Manual" )
	@nLin, 030 PSAY "Status : "+ _cStsDes
	@nLin, 055 PSAY "Referência: "+ ZXA->ZXA_REF
	@nLin, 095 PSAY "Correias "+ Iif( AllTrim(ZXA->ZXA_CODBAS) == "01", "Fechadas", "Abertas de Largura "+ AllTrim( ZXA->ZXA_LRG ) )
	
	nLin++
	@nLin, 00 PSAY Replicate("-",132)
	nLin++
	@nLin, 01 PSAY PadC("Produtos a serem gerados",132)
	nLin++
	@nLin, 00 PSAY Replicate("-",132)
	nLin++
	
	dbSelectArea("ZXB")
	dbSetOrder(1)
	dbSeek( xFilial("ZXB") + ZXA->ZXA_NUMCRT )

	@nLin, 01 PSAY "Código            Descrição                                                        Quantidade   Fil   P.V.   Item"
	nLin++
	@nLin, 00 PSAY Replicate("-",132)
	nLin++

	nMinLrg := 0
	nMinCmp := 0
	
	While !ZXB->( Eof() ) .And. xFilial("ZXB") + ZXA->ZXA_NUMCRT == ZXB->ZXB_FILIAL + ZXB->ZXB_NUMCRT
		
		aUmLargF := U_GetUmSBS( ZXB->ZXB_PRODUT, "LRG", .T. )
		nMinLrg  := Iif( aUmLargF[ 3 ] < nMinLrg, aUmLargF[ 3 ], nMinLrg )
		
		If AllTrim( ZXA->ZXA_CODBAS ) == "02"
			aUmCompF := U_GetUmSBS( ZXB->ZXB_PRODUT, "COM", .F. )
			nMinCmp  := Iif( aUmCompF[ 3 ] < nMinCmp, aUmCompF[ 3 ], nMinCmp )		
		EndIf

		@nLin, 001 PSAY ZXB->ZXB_PRODUT
		cB1Desc   := AllTrim(Posicione("SB1", 1, xFilial("SB1") + ZXB->ZXB_PRODUT, "B1_DESC"))
		cB1Espec  := AllTrim(Posicione("SB1", 1, xFilial("SB1") + ZXB->ZXB_PRODUT, "B1_ESPECIF"))
		cDescProd := Iif( !Empty( cB1Espec ), cB1Espec, cB1Desc )
		@nLin, 019 PSAY AllTrim( cDescProd )
			
		@nLin, 084 PSAY Transform( ZXB->ZXB_QTD, "@E 999,999.99" )
		@nLin, 098 PSAY ZXB->ZXB_FILORI
		@nLin, 103 PSAY ZXB->ZXB_PEDIDO
		@nLin, 111 PSAY ZXB->ZXB_ITEMPV
		
		nLin++

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif
		
		ZXB->( dbSkip() )
	End


	If ZXA->ZXA_STATUS == "A" // Só vou imprimir os endereços quando o plano de corte ainda estiver em aberto

		nLin++
		
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		@nLin, 00 PSAY Replicate("-",132)
		nLin++
		@nLin, 01 PSAY PadC("Endereços das peças para corte",132)
		nLin++
		@nLin, 00 PSAY Replicate("-",132)
		nLin++

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		@nLin, 01 PSAY "Código           Descrição                                                          Quantidade   Endereço    Largura   Comprimento"
		nLin++
		@nLin, 00 PSAY Replicate("-",132)
		nLin++

		dbSelectArea("ZXB")
		dbSetOrder(1)
		dbSeek( xFilial("ZXB") + ZXA->ZXA_NUMCRT )

		// Preparo a busca pelos PAs
		ExecBlock('ChkPosBase',.F.,.F., {'IMDA641', ""})	
		cBase := U_A093Base( PadR( ZXB->ZXB_PRODUT, TamSX3("B1_COD")[ 1 ] ) )
		ExecBlock('ChkPosBase',.F.,.F., {'IMDA641', cBase})	
		aIdSBQ	 := A093ORetSBQ( cBase )
	
		nPosMat	 := Ascan( aIdSBQ, { |X| AllTrim( X[ 01 ] ) == 'MAT' } )
		nPosFam	 := Ascan( aIdSBQ, { |X| AllTrim( X[ 01 ] ) == 'FAM' } )
		nPosRef	 := Ascan( aIdSBQ, { |X| AllTrim( X[ 01 ] ) == 'REF' } )
				
		nTamCorr := Len( AllTrim( cBase ) ) + aIdSBQ[ nPosMat ][ 02 ] + aIdSBQ[ nPosFam ][ 02 ] + aIdSBQ[ nPosRef ][ 02 ]
				
		cQuery := "SELECT B1_FILIAL, B1_COD, B1_DESC, B1_ESPECIF, B2_LOCAL, B2_QATU, B1_SGRB2 "
		cQuery += " FROM "+ RetSqlName("SB1") +" SB1, "+ RetSqlName("SB2") +" SB2 "
		cQuery += " WHERE B1_COD LIKE '"+ SubStr( ZXB->ZXB_PRODUT, 1, nTamCorr ) +"%' "
		cQuery += " AND B1_FILIAL = '"+ xFilial("SB1") +"' "
		cQuery += " AND B1_COD = B2_COD AND SB1.D_E_L_E_T_ = ' ' AND SB2.D_E_L_E_T_ = ' ' "
		cQuery += " AND SB2.B2_QATU > 0 AND B2_FILIAL = '"+ xFilial("SB2") +"' AND B1_MSBLQL <> '1' "
	
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasR := GetNextAlias(),.F.,.T.)
	
		While !(cAliasR)->( Eof() )
	
			aUmLargP := U_GetUmSBS( (cAliasR)->B1_COD, "LRG", .T. )
			If aUmLargP[ 3 ] < nMinLrg // Se LARGURA do PAI for MENOR que a LARGURA do FILHO, dispensa o mesmo.
				(cAliasR)->( dbSkip() )
				Loop
			EndIf

			If AllTrim( ZXA->ZXA_CODBAS ) == "02"
				aUmCompP := U_GetUmSBS( (cAliasR)->B1_COD, "COM", .F. )
				If aUmCompP[ 3 ] < nMinCmp // Se COMPRIMENTO do PAI for MENOR que COMPRIMENTO do FILHO, dispensa o mesmo.
					(cAliasR)->( dbSkip() )
					Loop
				EndIf
			EndIf
			aUmLargP := U_GetUmSBS( (cAliasR)->B1_COD, "LRG", .F. )
			
			lCLocal  := Localiza( (cAliasR)->B1_COD )

			If lCLocal

				aAreaAtu2 := GetArea()
	
				dbSelectArea("SBF")
				dbSetOrder(2)
				If dbSeek( (cAliasR)->B1_FILIAL + (cAliasR)->B1_COD + (cAliasR)->B2_LOCAL )
					While !SBF->( EOF() ) .And. (cAliasR)->B1_FILIAL + (cAliasR)->B1_COD + (cAliasR)->B2_LOCAL == SBF->BF_FILIAL + SBF->BF_PRODUTO + SBF->BF_LOCAL
	
						@nLin, 001 PSAY (cAliasR)->B1_COD
						
						cDescProd := AllTrim( Iif( !Empty( (cAliasR)->B1_ESPECIF ), (cAliasR)->B1_ESPECIF, (cAliasR)->B1_DESC ) )

						@nLin, 018 PSAY cDescProd
						@nLin, 085 PSAY Transform( SBF->BF_QUANT, "@E 99,999.99" )
						@nLin, 098 PSAY SBF->BF_LOCALIZ
						@nLin, 108 PSAY Transform( aUmLargP[ 3 ], "@E 9,999.99" ) + aUmLargP[ 1 ]
						If AllTrim( ZXA->ZXA_CODBAS ) == "02"
							@nLin, 122 PSAY Transform( aUmCompP[ 3 ], "@E 99,999.99" ) + aUmCompP[ 1 ]
						EndIf
						
						nLin++

						If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif
	
						SBF->( dbSkip() )
					End
				EndIf
			
			EndIf
	
			(cAliasR)->( dbSkip() )
		End
		(cAliasR)->( dbCloseArea() )

	EndIf
	
Return

/* Parâmetros para geração automática dos planos de corte */
User Function IMD641Au()

	Local cPerg := PadR( "IMDA641", Len( SX1->X1_GRUPO ) )

	AjustaSX1( cPerg )
	
	If Pergunte( cPerg, .T. )

		If MsgYesNo("Esta rotina irá gerar planos de corte baseados nos pedidos em aberto. Confirma?")
			Processa( {|| GerAutPL() }, "Gerar Plano de Corte", "Executando query..." )
		EndIf

	EndIf
			
Return

/* Efetua a busca pela demanda de corte nos pedidos e cria os planos de corte automaticamente */
Static Function GerAutPL()
	
	Local _cQuery  := ""
	Local _cAlias1 := GetNextAlias()
	Local _aProds  := {}
	Local _aTemp   := {}
	Local _aIdSBQ  := {}
	Local aVarSBS  := {}
	Local _cRefs   := ""
	Local _cLarg   := ""
	Local _cBase   := ""
	Local _nPRef   := 0
	Local _nFor    := 0
	Local nPosFim  := 2
	Local _cNumCrt := ""
	Local _cPsqRef := ""
	Local _cSqlC01 := "(SELECT SUM(C0_QUANT) C0_QUANT FROM "+ RetSqlName("SC0") +" SC0 WHERE SC0.C0_DOCRES = SC6.C6_NUM||SC6.C6_ITEM AND SC0.C0_FILIAL = SC6.C6_FILIAL AND SC6.C6_PRODUTO = SC0.C0_PRODUTO AND C0_QTDELIM = 0 AND SC0.D_E_L_E_T_ = ' ')"
	Local _cSqlC02 := "(SELECT SUM(C0_QUANT) C0_QUANT FROM "+ RetSqlName("SC0") +" SC0 WHERE SC0.C0_DOCRES = SC6.C6_NUM||SC6.C6_ITEM AND SC0.C0_FILIAL = '09' AND SC6.C6_PRODUTO = SC0.C0_PRODUTO AND C0_QTDELIM = 0 AND SC0.D_E_L_E_T_ = ' ')"
	Local nTamProd := GetMv('IM_TAMPROD')
	
	// A quantidade considerada para o corte é C6_QTDVEN menos o saldo disponivel na filial solicitante ou na filial do corte (não será cortado) vide mv_par07
	_cQuery := "SELECT C6_QTDVEN, NVL( "+ _cSqlC01 +", 0 ) RESERVA1, NVL( "+ _cSqlC02 +", 0 ) RESERVA2, SC6.C6_PRODUTO,  SC6.C6_NUM,  SC6.C6_ITEM,  SB1.B1_SGRB3,  SB1.B1_SGRB2,  SC6.C6_FILIAL,  SC6.C6_UM,  SC6.C6_PLANILH,  SC6.C6_PLITEM,  SC9.C9_BLCRED,  SC9.C9_BLEST "
	_cQuery += "FROM "+ RetSqlName("SC6") +" SC6, "+ RetSqlName("SC5") +" SC5, "+ RetSqlName("SB1") +" SB1, "+ RetSqlName("SC9") +" SC9 "
	_cQuery += " WHERE SC6.C6_FILIAL   = SC5.C5_FILIAL  AND "
	_cQuery += "       SC6.C6_NUM      = SC5.C5_NUM     AND "
	_cQuery += "       SC6.C6_PRODUTO  = SB1.B1_COD     AND "
	_cQuery += "       SC6.C6_FILIAL   = SC9.C9_FILIAL  AND "
	_cQuery += "       SC6.C6_NUM      = SC9.C9_PEDIDO  AND "
	_cQuery += "       SC6.C6_ITEM     = SC9.C9_ITEM    AND "
	_cQuery += "       SC6.C6_PRODUTO  = SC9.C9_PRODUTO AND "
	_cQuery += "       SC6.C6_LOCAL    = SC9.C9_LOCAL   AND "
	_cQuery += "       SC6.D_E_L_E_T_  = ' '            AND "
	_cQuery += "       SC5.D_E_L_E_T_  = ' '            AND "
	_cQuery += "       SB1.D_E_L_E_T_  = ' '            AND "
	_cQuery += "       SC9.D_E_L_E_T_  = ' '            AND "
	_cQuery += "       SC5.C5_EMISSAO  BETWEEN '"+ DtoS( MV_PAR05 ) +"' AND '"+ DtoS( MV_PAR06 ) +"' AND "
	_cQuery += "       SC6.C6_NUM      BETWEEN '"+ MV_PAR03         +"' AND '"+ MV_PAR04         +"' AND "
	_cQuery += "       SB1.B1_SGRB3    BETWEEN '"+ MV_PAR01         +"' AND '"+ MV_PAR02         +"' AND "
	_cQuery += "       SC6.C6_CORTE    = ' ' AND "
	_cQuery += "       SC5.C5_BLQ      = ' ' AND "                         // Apenas pedidos liberados
	_cQuery += "       SC5.C5_TIPO     = 'N' AND "                         // Apenas pedidos de VENDA
	_cQuery += "       SC5.C5_CLIENTE  <> '"+ GetMv("MV_IMDEPA") +"' AND " // Não considera pedidos de transferências
	_cQuery += "       SB1.B1_GRUPO    = '0022' AND "                      // Apenas grupo de correias
	_cQuery += "       SC9.C9_BLCRED   = '  '   AND "                      // Apenas itens liberados no crédito
	_cQuery += "       SB1.B1_FILIAL   = '"+ xFilial("SB1") +"' AND "
	_cQuery += "       LENGTH(RTRIM(SB1.B1_COD)) > "+cValToChar(nTamProd)+"  "

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cAlias1,.F.,.T.)
	
	While !(_cAlias1)->( Eof() )
		
		// Validação para verificar se produto é de correias
		_aAreaA := GetArea()
		ExecBlock('ChkPosBase',.F.,.F., {'IMDA641', ""})	
		cCodBas := U_A093Base( (_cAlias1)->C6_PRODUTO )
		ExecBlock('ChkPosBase',.F.,.F., {'IMDA641', cCodBas})	
		RestArea( _aAreaA )
        // Se a base estiver vazia, não é correia, vai para o próximo registro
		If Empty( cCodBas )
			(_cAlias1)->( dbSkip() )
			Loop
		EndIf
		
		_aIdSBQ	 := A093ORetSBQ( cCodBas )
		
		For _nFor := 1 To Len( _aIdSBQ )
			If AllTrim( _aIdSBQ[_nFor][ 1 ] ) == "LRG"
				If AllTrim( cCodBas ) == "02"
					nPosFim += _aIdSBQ[ _nFor ][ 2 ]
				EndIf
				Exit
			EndIf                  
			nPosFim += _aIdSBQ[ _nFor ][ 2 ]
		Next
	
		_cPsqRef := Left( (_cAlias1)->C6_PRODUTO, nPosFim )
		_nPRef   := aScan( _aProds, { |o| o[ 1 ] == _cPsqRef } )
		// Se considera as reservas, subtraio do corte
		_nQtd    := Iif( mv_par07 == 1, (_cAlias1)->C6_QTDVEN - (_cAlias1)->RESERVA1 - Iif( (_cAlias1)->C6_FILIAL == "09", 0, (_cAlias1)->RESERVA2 ), (_cAlias1)->C6_QTDVEN ) 
		
		If _nQtd > 0 // Pode ser que a quantidade solicitada já esteja totalmente reservada

			If _nPRef == 0

				aVarSBS  := A093SBSVars( (_cAlias1)->C6_PRODUTO ) 
				_cRefs := aVarSBS[ aScan( aVarSBS, {|o|  AllTrim( o[ 1 ] ) == 'REF' } ) ][03]
				_cLarg := aVarSBS[ aScan( aVarSBS, {|o|  AllTrim( o[ 1 ] ) == 'LRG' } ) ][03]
				
				_aTemp := {}
				aAdd( _aTemp, { (_cAlias1)->C6_PRODUTO, _nQtd, (_cAlias1)->C6_UM, (_cAlias1)->C6_FILIAL, (_cAlias1)->C6_NUM, (_cAlias1)->C6_ITEM } )
				aAdd( _aProds, { _cPsqRef, _aTemp, cCodBas, _cRefs, _cLarg } )
			Else
				_aTemp := _aProds[ _nPRef, 2 ]
				aAdd( _aTemp, { (_cAlias1)->C6_PRODUTO, _nQtd, (_cAlias1)->C6_UM, (_cAlias1)->C6_FILIAL, (_cAlias1)->C6_NUM, (_cAlias1)->C6_ITEM } )
				_aProds[ _nPRef, 2 ] := _aTemp
			EndIf
		
		EndIf
		
		(_cAlias1)->( dbSkip() )
	End
	
	(_cAlias1)->( dbCloseArea() )

	ProcRegua( Len( _aProds ) )

    For _nF := 1 To Len( _aProds )
		
		_aTemp   := _aProds[ _nF, 2 ] // Array com os produtos e pedidos
		_cBase   := _aProds[ _nF, 3 ] // Codigo base do produto
		_cRefs   := _aProds[ _nF, 4 ] // Referencia (BS_DESCPRD)
		_cLarg   := _aProds[ _nF, 5 ] // Largura quando base for 02 (BS_DESCPRD)
		_cNumCrt := GetSx8Num("ZXA","ZXA_NUMCRT")
		
		IncProc("Efetuando inclusão dos planos: "+ cValToChar( _nF ) +" de "+ cValToChar( Len( _aProds ) ) )
		
		Begin Transaction
			
			dbSelectArea("ZXA")
			RecLock("ZXA",.T.)
				ZXA->ZXA_FILIAL := cFilAnt
				ZXA->ZXA_NUMCRT := _cNumCrt
				ZXA->ZXA_USER   := CUSERNAME
				ZXA->ZXA_DATA   := DDATABASE
				ZXA->ZXA_HORA   := SUBSTR(TIME(),1,5)
				ZXA->ZXA_TIPO   := "A"
				ZXA->ZXA_STATUS := "A"
				ZXA->ZXA_REF    := _cRefs
				ZXA->ZXA_CODBAS := _cBase
				ZXA->ZXA_LRG    := Iif( AllTrim( _cBase ) == "02", _cLarg, "" )

			ZXA->( MsUnLock() )
			
			For _nX := 1 To Len( _aTemp )
				
				dbSelectArea("ZXB")
				RecLock("ZXB",.T.)
					ZXB->ZXB_FILIAL := cFilAnt
					ZXB->ZXB_NUMCRT := _cNumCrt
					ZXB->ZXB_ITEM   := StrZero( _nX, 3 )
					ZXB->ZXB_PRODUT := _aTemp[ _nX, 1 ]
					ZXB->ZXB_QTD    := _aTemp[ _nX, 2 ]
					ZXB->ZXB_UN     := _aTemp[ _nX, 3 ]
					ZXB->ZXB_FILORI := _aTemp[ _nX, 4 ]
					ZXB->ZXB_PEDIDO := _aTemp[ _nX, 5 ]
					ZXB->ZXB_ITEMPV := _aTemp[ _nX, 6 ]
				ZXB->( MsUnLock() )
				
				dbSelectArea("SC6")
				dbSetOrder(1)
				If dbSeek( ZXB->ZXB_FILORI + ZXB->ZXB_PEDIDO + AllTrim( ZXB->ZXB_ITEMPV ) + ZXB->ZXB_PRODUT )
					RecLock("SC6",.F.)
						SC6->C6_CORTE   := "G"               // G = Gerado / C = Cortado / " " = Sem plano de corte
						SC6->C6_NUMCRT  := _cNumCrt          // Número do plano no ZXA / ZXB
						SC6->C6_ITEMCRT := StrZero( _nX, 3 ) // Item do plano no ZXB
					SC6->( MsUnLock() )
				EndIf
				
			Next

		End Transaction
		
		If ( __lSx8 )
			ConfirmSx8()
		EndIf

	Next
	
Return

/*
Valida cada linha do acols
*/
User Function I641LinOk()
	
	Local _cRef     := ""
	Local _aAreaAtu := GetArea()
	Local _aAreaSB1 := SB1->( GetArea() )
	Local _lRet     := .T.
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek( xFilial("SB1") + aCols[ oGet:oBrowse:nAt, aScan( aHeader,{|o| AllTrim( o[2] ) == "ZXB_PRODUT" } ) ] )
	
	If SB1->B1_MSBLQL == "1"
		MsgAlert("Produto selecionado está bloqueado para uso!")
		_lRet := .F.
	EndIf
	
	If _lRet .And. AllTrim( SB1->B1_GRUPO ) <> "0022"
		MsgAlert("Produto selecionado não faz parte do grupo de correias!")
		_lRet := .F.
	EndIf
	
	If _lRet .And. AllTrim( SB1->B1_TIPO ) <> "PP"
		MsgAlert("Produto selecionado não é um PP!")
		_lRet := .F.
	EndIf

	If _lRet .And. !aCols[ oGet:oBrowse:nAt, Len( aHeader ) + 1 ] .And. AllTrim( M->ZXA_REF ) != AllTrim( SB1->B1_SGRB3 )
		MsgAlert("Só podem ser utilizados produtos com a referência: "+ AllTrim( M->ZXA_REF ) )
		_lRet := .F.
	EndIf

	RestArea( _aAreaAtu )
	RestArea( _aAreaSB1 )

Return _lRet

/*
Valida toda a tela (se for necessário)
*/
User Function I641TudOk


Return .T.

/*
Valida a exclusão da linha, se necessário
*/
User Function I641DelOk()
	
	
Return .T.
  
/*
Cria o menu para o aRotina
*/
Static Function MenuDef()

	Local aRots := {}
	
	aAdd( aRots, { "Pesquisar"   ,"AxPesqui"  , 0, 1 } )
	aAdd( aRots, { "Visualizar"  ,"U_IMD641Vi", 0, 2 } )
	aAdd( aRots, { "Incluir"     ,"U_IMD641In", 0, 3 } )
	aAdd( aRots, { "Automatico"  ,"U_IMD641Au", 0, 2 } )
	aAdd( aRots, { "Efetivar"    ,"U_IMD641Ef", 0, 4 } )
	aAdd( aRots, { "Alterar"     ,"U_IMD641Al", 0, 4 } )
	aAdd( aRots, { "Excluir"     ,"U_IMD641Ex", 0, 5 } )
	aAdd( aRots, { "Cancelar"    ,"U_IMD641Ca", 0, 4 } )
	aAdd( aRots, { "Desmontagens","U_IMD641De", 0, 4 } )
	aAdd( aRots, { "Impressão"   ,"U_IMD641Re", 0, 2 } )
	aAdd( aRots, { "Legenda"     ,"U_IMD641Le", 0, 2 } )

Return aRots

/*
Monta o array aCols com os itens na visualização, exclusão e alteração
*/
Static Function MontaCols()

	Local _nI    := 0
	Local nUsado := Len( aHeader )
	
	aCols := {}

	dbSelectArea("ZXB")
	dbSetOrder(1)
	dbSeek( xFilial("ZXB") + ZXA->ZXA_NUMCRT )

	While !ZXB->( Eof() ) .And. ZXB->ZXB_FILIAL + ZXB->ZXB_NUMCRT == xFilial("ZXB") + ZXA->ZXA_NUMCRT
	
		aAdd( aCols, Array( nUsado + 1 ) )
		
		For _ni := 1 to nUsado - 3
			aCols[ Len( aCols ), _ni ] := FieldGet( FieldPos( aHeader[ _ni, 2 ] ) )
			If AllTrim( aHeader[ _ni, 2 ] ) == "ZXB_DESC"
				aCols[ Len( aCols ), _ni ] := Posicione("SB1",1,xFilial("SB1")+aCols[Len( aCols ),aScan(aHeader,{|o| AllTrim(o[2])=="ZXB_PRODUT"})],"B1_DESC")
			EndIf
		Next
		aCols[ Len( aCols ) ][ nUsado - 1 ] := "ZXB"
		aCols[ Len( aCols ) ][ nUsado     ] := ZXB->( Recno() )
		aCols[ Len( aCols ) ][ nUsado + 1 ] := .F.
  	  
  	  	ZXB->( dbSkip() )
	End

Return 

/* Faz a manutenção das perguntas para geração automática de planos de corte */
Static Function AjustaSX1( cPerg )

	PutSx1(cPerg, "01",'Da Referência   ?',"","","mv_ch1","C",10,0,0,"G","","SBSPLC",""," ","mv_par01",     ,,,,     ,,,"","","","","","","","","",,,,"")
	PutSx1(cPerg, "02",'Até Referência  ?',"","","mv_ch2","C",10,0,0,"G","","SBSPLC",""," ","mv_par02",     ,,,,     ,,,"","","","","","","","","",,,,"") 
	PutSx1(cPerg, "03",'Do Pedido       ?',"","","mv_ch3","C",06,0,0,"G","","      ",""," ","mv_par03",     ,,,,     ,,,"","","","","","","","","",,,,"")
	PutSx1(cPerg, "04",'Ate Pedido      ?',"","","mv_ch4","C",06,0,0,"G","","      ",""," ","mv_par04",     ,,,,     ,,,"","","","","","","","","",,,,"")
	PutSx1(cPerg, "05",'Da Emissão      ?',"","","mv_ch5","D",08,0,0,"G","","      ",""," ","mv_par05",     ,,,,     ,,,"","","","","","","","","",,,,"")
	PutSx1(cPerg, "06",'Até Emissão     ?',"","","mv_ch6","D",08,0,0,"G","","      ",""," ","mv_par06",     ,,,,     ,,,"","","","","","","","","",,,,"") 
	PutSx1(cPerg ,"07",'Cons.Saldo Local?',"","","mv_ch7","N",01,0,0,"C","","      ","","S","mv_par07","Sim",,,,"Nao",,,"","","","","","","","","",,,,"") 

Return

/* Faz a manutenção das perguntas para para o relatório de planos de corte */
Static Function CriaSx1Rel( cPerg )

	PutSx1(cPerg ,"01",'Cons.Par.Abaixo ?',"","","mv_ch1","N",01,0,0,"C","","      ","","S","mv_par01","Sim",,,,"Nao",,,"","","","","","","","","",,,,"") 
	PutSx1(cPerg, "02",'Da Referência   ?',"","","mv_ch2","C",10,0,0,"G","","SBSPLC",""," ","mv_par02",     ,,,,     ,,,"","","","","","","","","",,,,"")
	PutSx1(cPerg, "03",'Até Referência  ?',"","","mv_ch3","C",10,0,0,"G","","SBSPLC",""," ","mv_par03",     ,,,,     ,,,"","","","","","","","","",,,,"") 
	PutSx1(cPerg, "04",'Do Plano        ?',"","","mv_ch4","C",06,0,0,"G","","      ",""," ","mv_par04",     ,,,,     ,,,"","","","","","","","","",,,,"")
	PutSx1(cPerg, "05",'Ate Plano       ?',"","","mv_ch5","C",06,0,0,"G","","      ",""," ","mv_par05",     ,,,,     ,,,"","","","","","","","","",,,,"")
	PutSx1(cPerg ,"06",'De qual Status  ?',"","","mv_ch6","N",01,0,0,"C","","      ","","A","mv_par06","Aberto",,,,"Encerrado",,,"Todos","","","","","","","","",,,,"") 

Return

/* Desmontagem do produto */
Static Function Imd641Des( cCod, cLoc, cEnd, nQtd, aAutoItens, aPedLib, nLrgPai, _aIteDes )

	Local aAutoCab := {}
	Local cDoc     := NextNumero( "SD3", 2, "D3_DOC", .T. )
	Local nTot     := 0
	Local cFilBck  := ""
	Local cNumPV   := ""
	Local cItemPV  := ""
	Local cProduto := ""
	Local cFilPed  := ""
	Local cFilDest := ""
	
		
	Private lMsErroAuto := .F.
	
	If Type("aAutoItens") != "A" .Or. Len( aAutoItens ) == 0
		cDoc := ""
		Return cDoc
	EndIf
	
	aAdd( aAutoCab, {"cProduto"  , Pad( cCod, Len(SD3->D3_COD))	 , Nil} )
	aAdd( aAutoCab, {"cLocOrig"  , cLoc						     , Nil} )
	aAdd( aAutoCab, {"nQtdOrig"  , nQtd 						 , Nil} )
	aAdd( aAutoCab, {"cDocumento", Pad( cDoc, Len(SD3->D3_DOC) ) , Nil} )
	aAdd( aAutoCab, {"nQtdOrigSe", CriaVar("D3_QTSEGUM")		 , Nil} )
	aAdd( aAutoCab, {"cNumLote"  , CriaVar("D3_NUMLOTE")		 , Nil} )
	aAdd( aAutoCab, {"cLoteDigi" , CriaVar("D3_LOTECTL")		 , Nil} )
	aAdd( aAutoCab, {"dDtValid"  , CriaVar("D3_DTVALID")		 , Nil} )
	aAdd( aAutoCab, {"nPotencia" , CriaVar("D3_POTENCI")		 , Nil} )
	aAdd( aAutoCab, {"cLocaliza" , cEnd		                     , Nil} )
	aAdd( aAutoCab, {"cNumSerie" , CriaVar("D3_NUMSERI")		 , Nil} )
	
	nPrat := aScan( aAutoItens[ 1 ], {|o| AllTrim( o[ 1 ] ) == "D3_RATEIO"} ) // Posição do campo D3_RATEIO no item
	
	aEval( aAutoItens, {|o| nTot += o[ nPrat, 2 ] } )  // Total das larguras ou M2 cortadas nos itens

	For _nW := 1 To Len( aAutoItens )
		// Proporcionalizar o custo pelos itens da desmonstagem
		aAutoItens[ _nW, nPrat, 2 ] := Round( ( aAutoItens[ _nW, nPrat, 2 ] / nTot ) * 100, 2 )
	Next
	
	nTot := 0
	aEval( aAutoItens, {|o| nTot += o[ nPrat, 2 ] } ) // Total do percentual
	
	If nTot != 100
		aAutoItens[ Len( aAutoItens ), nPrat, 2 ] += ( 100 - nTot )
	EndIf

	For _nA := 1 To Len( aPedLib )
		
		cAliSC0 := GetNextAlias()
		
		cFilDest:= aPedLib[ _nA, 1 ]
		
		cSql := "SELECT * "
		cSql += " FROM "+ RetSqlName("SC0")
		cSql += " WHERE C0_FILRES = '"+ aPedLib[ _nA, 1 ] +"' AND "
		cSql += "       C0_FILIAL = '09' AND "
		cSql += "       C0_DOCRES = '"+ aPedLib[ _nA, 2 ] + aPedLib[ _nA, 3 ] +"' AND "
		cSql += "       C0_TIPO   = 'PD' AND "
		cSql += "       C0_QTDELIM < C0_QUANT AND "
		cSql += "       D_E_L_E_T_ = ' '"
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),cAliSC0,.F.,.T.)
		
		While !(cAliSC0)->( Eof() )
		
			// Armazeno a filial atual e altero a filial corrente para a filial da reserva, para poder processar a eliminação
			cFilBck	:= cFilAnt
			cFilAnt := (cAliSC0)->C0_FILIAL
			//cFilDest:= (cAliSC0)->C0_FILIAL

			DbSelectArea('SB2');DbSetOrder(1)
			DbSeek( xFilial('SB2') + (cAliSC0)->C0_PRODUTO + (cAliSC0)->C0_LOCAL, .F.)

			dbSelectArea("SC0")
			dbSetOrder(1)
			dbSeek( (cAliSC0)->C0_FILIAL + (cAliSC0)->C0_NUM + (cAliSC0)->C0_PRODUTO + (cAliSC0)->C0_LOCAL )
			
			// Executa o estorno da reserva para o pedido + item
			If !a430Reserva({2,	(cAliSC0)->C0_TIPO,(cAliSC0)->C0_DOCRES,(cAliSC0)->C0_SOLICIT,(cAliSC0)->C0_FILRES, (cAliSC0)->C0_OBS },;
								(cAliSC0)->C0_NUM,;
								(cAliSC0)->C0_PRODUTO,;
								(cAliSC0)->C0_LOCAL,;
								0,;
								{(cAliSC0)->C0_NUMLOTE,(cAliSC0)->C0_LOTECTL,(cAliSC0)->C0_LOCALIZ,(cAliSC0)->C0_NUMSERI},,,;
								(cAliSC0)->C0_QUANT)

			
				MsgAlert('ERRO ao gravar estorno da reserva. Favor acionar o Depto. de Tecnologia Imdepa!','IMDA641')
			EndIf

			SC0->( MsUnLock() ) // Necessário pois na saída da função acima o registro permanece em Lock
			
			cFilAnt := cFilBck
			
			(cAliSC0)->(DbSkip())
		End

		(cAliSC0)->( dbCloseArea() )

	Next

	Iif( Select('SD3') == 0 .Or. Empty( Alias() ), ( ChkFile('SD3'), DbSelectArea('SD3') ), DbSelectArea('SD3') ) // Garantir a seleção do alias SD3
	MSExecAuto( { |v,x,y,z| Mata242(v,x,y,z) }, aAutoCab, aAutoItens, 3, .T. )

	If lMsErroAuto
		cDoc := ""
		If MsgYesNo("Houve um problema e não foi feita desmontagem. Pedidos não liberados, mas reservas já canceladas. Deseja ver o erro?")
			Mostraerro()
		EndIf
	Else
		_aAreaTmp := GetArea()

		For nX := 1 To Len( _aIteDes )
		
		   //Inserido por Edivaldo Goncalves
		   //Cria a Sequência de Abastecimento na Filial de Destino
				
				If ( !Empty(cFilDest) .AND. cFilDest <> cFilAnt )
					CriaDC3( cFilDest, PadR( _aIteDes[ nX ][ 03 ], TamSx3('B2_COD')[ 01 ], '' ) )
				Endif
				

			If _aIteDes[ nX ][ 02 ] == '000' .Or. Len( _aIteDes[ nX ][ 05 ] ) == 0 // <- PRODUTO "SOBRA" OU SEM PEDIDO DE VENDAS
					  	

				If Len( _aIteDes[ nX ][ 05 ] ) == 0 // Se não tem pedido de vendas
					CriaDC3( cFilAnt, PadR( _aIteDes[ nX ][ 03 ], TamSx3('B2_COD')[ 01 ], '' ) )
				EndIf
								
				Loop
			EndIf
                          

			For _nU := 1 To Len( _aIteDes[ nX ][ 05 ] )

				_lResOk   := .F.
				cProduto  := PadR( _aIteDes[ nX ][ 03 ], TamSx3('B2_COD')[ 01 ], '' )
				cFilPed	  := _aIteDes[ nX ][ 05 ][ _nU ]

				If cFilPed == cFilAnt // Filial do pedido é a mesma da filial de corte, não há transferência
					cNumPV  := PadR( _aIteDes[ nX ][ 06 ][ _nU ], TAMSX3("C6_NUM")[1] ) // Pedido de venda
					cItemPV := PadR( _aIteDes[ nX ][ 07 ][ _nU ], TAMSX3("C6_ITEM")[1] ) // Item do pedido
					LibRolPV(cNumPV)  // Verifico se no pedido da filial de corte existe rolamento e faço a liberação do mesmo
				Else                  // Procuro pelo pedido de transferencia quando for filial diferente
					aPedTran := PVTranRs( cFilPed, cProduto, _aIteDes[ nX ][ 06 ][ _nU ], _aIteDes[ nX ][ 07 ][ _nU ] )
					If Len( aPedTran ) > 0
						cNumPV  := aPedTran[ 1 ] // Pedido de transferência
						cItemPV := aPedTran[ 2 ] // Item do pedido
					EndIf
				Endif

				// Executa a liberação do item no pedido
				dbSelectArea("SC5")
				dbSetOrder(1)
				If DbSeek( cFilAnt + cNumPV )
	
					SA1->( dbSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ) )
		
					dbSelectArea("SC9")
					dbSetOrder(1)
					If dbSeek( cFilAnt + cNumPV + cItemPV )
						While !SC9->( Eof() ).And. cFilAnt + cNumPV + cItemPV == SC9->C9_FILIAL + SC9->C9_PEDIDO + SC9->C9_ITEM
							SC9->( A460Estorna() )
							SC9->( dbSkip() )
						End
					EndIf
						
					dbSelectArea("SC6")
					dbSetOrder(1)
					dbSeek( cFilAnt + cNumPV + cItemPV )
		
					Begin Transaction
						MaLibDoFat( SC6->( RecNo() ), SC6->C6_QTDVEN, .T., .F., .F., .T., .F., .F. )
					End Transaction

					CriaDC3( SC6->C6_FILIAL, SC6->C6_PRODUTO )

					// Altero o flag do SC6 para cortado
					dbSelectArea("SC6")
					dbSetOrder(1)
					If dbSeek( cFilPed + _aIteDes[ nX ][ 06 ][ _nU ] + _aIteDes[ nX ][ 07 ][ _nU ] )
						RecLock("SC6", .F.)
							SC6->C6_CORTE := "C"
						SC6->( MsUnLock() )
					EndIf
				
					MaLiberOk({SC6->C6_NUM},.F.) // Atualizacao do Campo C5_LiberOk - Padrão TOTVS
					
				Else
					MsgAlert("Não foi possível efetuar a liberação do pedido!")
				EndIf
			Next
																		
		Next

		RestArea( _aAreaTmp )
	EndIf
	
Return cDoc

/*
Verifica se referência selecionada é válida
*/
Static Function IsSbsRef( cRef )

	Local _lOk  := .F.
	Local aBase := {}
	Local aArea := GetArea()
	Local _nX   := 0
	
	dbSelectArea("SBP")
	dbGoTop()
	While !SBP->( Eof() )
		If SBP->BP_DISPUSO == "1"
			aAdd( aBase, SBP->BP_BASE )
		EndIf
		SBP->( dbSkip() )
	End
	
	dbSelectArea("SBS")
	dbSetOrder(1)
	
	For _nX := 1 To Len( aBase )

		If dbSeek( xFilial("SBS") + aBase[ _nX ] + "REF       ")
			
			While !_lOk .And. !SBS->( Eof() ) .And. SBS->BS_ID == "REF       " .And. SBS->BS_BASE = aBase[ _nX ]
				
				_lOk := SBS->BS_ATIVO == "1" .And. SBS->BS_DESCR == cRef
				
				SBS->( dbSkip() )
			End
			
			If _lOk
				Exit
			EndIf
		
		EndIf
		
	Next

	RestArea( aArea )

Return _lOk

/*
Limpa todos os cortes, saldos e sobras e reinicia a operação
*/
Static Function ZeraTudo()

	Local nPosAte := Ascan( oBrwA:aHeader,{ |X| AllTrim( x[ 2 ] ) == "ATEND"} )
	Local nPosSob := Ascan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "SOBRAU"} )
	Local nPosLrg := Ascan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "LARGUR"} )
    Local nPosArp := Ascan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "AREATT"} )
	
	For _nS := 1 To Len( oBrwA:aCols )
		oBrwA:aCols[ _nS, nPosAte ] := 0
	Next
	
	For _nS := 1 To Len( oBrwB:aCols )
		oBrwB:aCols[ _nS, nPosSob ] := Iif( _lBase01, oBrwB:aCols[ _nS, nPosLrg ], oBrwB:aCols[ _nS, nPosArp ] )
	Next

	_aCabDes := {}
	_aIteDes := {}
	_aSobra  := {}	
	
	oBrwA:oBrowse:Refresh()
	oBrwB:oBrowse:Refresh()
	
Return

/*
Cria opções no menu Ações Relacionadas
*/
Static Function I641Bar(oDlg,bOk,bCancel,nOpc)

	Local aButtons   := {}

	If nOpc == 9 // Efetivação
		AAdd( aButtons, { "S4WB004N", { || ZeraTudo() }, "&Zerar", "ZERAR TELA" } )
		If "02" $ ZXA->ZXA_CODBAS
			AAdd( aButtons, { "S4WB004N", { || U_VerSob02(.F.) }, "&Sobras", "VER SOBRAS" } )
		EndIf
	EndIf

Return (EnchoiceBar(oDlg,bOK,bcancel,,aButtons))

/* Verifica a base de um código */
User Function A093Base(cCodigo)

	Local aSavAre := SaveArea1( {"SBP"} )
	Local cBase   := Space( Len( SBP->BP_BASE ) )
	Local x       := Len( Alltrim( SBP->BP_BASE ) )
	
	If !SBP->( LastRec() ) == 0 .Or.  SBP->( dbSeek( xFilial("SBP") ) )
		dbSelectArea("SBP")
		If dbSeek( xFilial("SBP") + Pad( SubStr( cCodigo, 1, x ), Len( SBP->BP_BASE ) ) )
			cBase := SBP->BP_BASE
		Else
			For x := 1 to Len( cCodigo )
				If dbSeek( xFilial("SBP") + Pad( SubStr( cCodigo, 1, x ), Len( SBP->BP_BASE ) ) )
					cBase := SBP->BP_BASE
					Exit
				Endif
			Next
		EndIf
	EndIf
	RestArea1( aSavAre )

Return( cBase )

/* Uso este ponto de entrada apenas para alterar a variável lMsHelpAuto */
User Function A093Gera()
	lMsHelpAuto := .F.
Return( .T. )

/* Verifica parâmetro que define o local + endereço padrão */
Static Function DefAdrCr( _cParam )

	Local _lOk     := .F.
	Local _lPar    := GetMV( _cParam, .T. )
	Local _cCont   := Iif( _lPar, AllTrim( GetMV( _cParam ) ), Space( TamSX3("BE_LOCAL")[ 1 ] + TamSX3("BE_LOCALIZ")[ 1 ] ) )
	Local _lSobra  := "SOB" $ Upper( _cParam )
	Local _cMsgCmp := Iif( _lSobra, "da sobra", "das peças cortadas" )

	If !_lPar .Or. ( _lPar .And. Empty( _cCont ) )
		If MsgYesNo("Parâmetro "+ _cParam +" de local e endereço "+ _cMsgCmp +" não definido! Definir agora?")
			
			// Criar o parâmetro
			_lOk := DefLocAd( _lPar, _cCont, _cParam, _lSobra )
			
		EndIf
	Else
		dbSelectArea("SBE")
		dbSetOrder(1)
		If dbSeek( xFilial("SBE") + _cCont )
			If _lSobra
				cLocSob := Left( _cCont, 2 )
				cEndSob := PadR( SubStr( _cCont, 3 ), TamSX3("D3_LOCALIZ")[1] )
			Else
				cLocPad := Left( _cCont, 2 )
				cEndPad := PadR( SubStr( _cCont, 3 ), TamSX3("D3_LOCALIZ")[1] )
			EndIf

			_lOk := .T.
		Else
			If MsgYesNo("Local + Endereço do parâmetro "+ _cParam +" são inválidos.! Definir agora?")

				// Atualizar o parâmetro
				_lOk := DefLocAd( _lPar, _cCont, _cParam, _lSobra )

			EndIf
		EndIf
	EndIf

Return _lOk

/* Exibe prompt para seleção do local + endereço padrão */
Static Function DefLocAd( _lPar, _cCont, _cParam, _lSobra )

	Local _lOk   := .F.
	Local _nOpcA := 0
	Local oDlg
	Local oButton1
	Local oSay1
	Local oSay2
	Local oSay3
	Local _cMsgCmp := Iif( _lSobra, "sobras de corte", "correias cortadas" )
	Private oGet1
	Private oGet2
	Private cGet1 := PadR(SubStr(_cCont,03),TamSx3('BE_LOCALIZ')[01])	//SubStr( _cCont, 3 )
	Private cGet2 := PadR(Left(_cCont,02),TamSx3('BE_LOCAL')[01])		//Left( _cCont, 2 )

	DEFINE MSDIALOG oDlg TITLE "Endereço Padrão" FROM 000, 000  TO 080, 250 COLORS 0, 16777215 PIXEL
		@ 003, 005 SAY oSay1 PROMPT "Selecione o endereço padrão para as "+ _cMsgCmp SIZE 111, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 015, 005 SAY oSay2 PROMPT "Endereço"                                       SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 015, 053 SAY oSay3 PROMPT "Local"                                          SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 024, 004 MSGET oGet1 VAR cGet1 F3 "SBE" /*VALID ( ValLEnd( 1 ) )*/ SIZE 044, 010 OF oDlg COLORS 0, 16777215 PIXEL
		@ 024, 052 MSGET oGet2 VAR cGet2 /*VALID ( ValLEnd( 2 ) )*/ SIZE 027, 010 OF oDlg COLORS 0, 16777215 PIXEL
		@ 020, 097 BUTTON oButton1 PROMPT "OK" ACTION ( Iif( !Empty( cGet1 + cGet2 ).And.ValLEnd(), ( _nOpcA:=1, oDlg:End() ), _nOpcA:=0 ) ) SIZE 024, 015 OF oDlg PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If _nOpcA == 1
		
		If !_lPar
			dbSelectArea("SX6")
			RecLock("SX6", .T.)
				SX6->X6_VAR     := _cParam
				SX6->X6_TIPO    := "C"
				SX6->X6_DESCRIC := SX6->X6_DSCSPA  := SX6->X6_DSCENG  := "Local+Ender. padrão para "+ _cMsgCmp
				SX6->X6_CONTEUD := SX6->X6_CONTSPA := SX6->X6_CONTENG := ""
				SX6->X6_PROPRI  := 'U'
			SX6->( MsUnlock() )
		EndIf
		
		PutMv( _cParam, cGet2 + cGet1 )

		// Alimentar as variáveis para uso no programa (local + endereço)
		If _lSobra
			cLocSob := AllTrim( cGet2 )
			cEndSob := PadR( AllTrim( cGet1 ), TamSX3("D3_LOCALIZ")[1] )
		Else
			cLocPad := AllTrim( cGet2 )
			cEndPad := PadR( AllTrim( cGet1 ), TamSX3("D3_LOCALIZ")[1] )
		EndIf		

		_lOk := .T.
	EndIf

Return _lOk

/* Valida os campos GET para a seleção do local + endereço padrão do corte */
Static Function ValLEnd( nCmp )

	Local _lOk := .F.

	_lOk :=  SBE->( dbSeek( xFilial("SBE") + cGet2 + cGet1 ))
		
	If !_lOk
		MsgAlert('Endereço ['+AllTrim(cGet1)+'] e\ou  Local ['+cGet2+'] inválido!!!   Verifique.') 
	EndIf
    
Return _lOk

/* Recebe a Filial, Produto, Pedido e item (venda) e retorna a planilha e o pedido de transferência */
Static Function PVTranRs( cFil, cProd, cNumPV, cItPV )
	
	Local _aRet   := {}
	Local _cSql   := ""
	Local cNewAli := GetNextAlias()
	
	_cSql := "SELECT C6_FILIAL, C6_ITEM, C6_NUM, C6_PLITEM, C6_PLANILH "
	_cSql += "FROM "+ RetSqlName("SC6") + " "
	_cSql += "WHERE C6_PLANILH = (SELECT C6_PLANILH "
	_cSql += "                    FROM SC6010 "
	_cSql += "                    WHERE C6_NUM     = '"+ cNumPV +"' "
	_cSql += "                    AND   C6_ITEM    = '"+ cItPV  +"' "
	_cSql += "                    AND   C6_FILIAL  = '"+ cFil   +"' "
	_cSql += "                    AND   D_E_L_E_T_ = ' ') "
	_cSql += "AND   C6_NUM    <> '"+ cNumPV +"' "
	_cSql += "AND   C6_FILIAL <> '"+ cFil   +"' "
	_cSql += "AND   C6_PRODUTO = '"+ cProd  +"' "
	_cSql += "AND   D_E_L_E_T_ = ' '"

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cSql),cNewAli,.F.,.T.)
	
	If !(cNewAli)->( Eof() )
		
		aAdd( _aRet, (cNewAli)->C6_NUM     ) // Pedido de transferência
		aAdd( _aRet, (cNewAli)->C6_ITEM    ) // Item do pedido
		aAdd( _aRet, (cNewAli)->C6_PLANILH ) // Planilha
		aAdd( _aRet, (cNewAli)->C6_PLITEM  ) // Item da Planilha
	
	EndIf
	
	(cNewAli)->( dbCloseArea() )

Return _aRet

// Jean Rehermann - SOLUTIO IT - 07/01/2016 - Função que avalia a necessidade de criação de sequência de abastecimento
Static Function CriaDC3( xFilial, cProduto )
	
	Local _lContinua := .T.
	Local _lSeekDC3  := .F.
	Local _cLocal    := ""
	Local _cEstFis   := "000037"
	Local _cOrdem    := "01"
	Local _cNorma    := "235599"
	Local _cReabas   := "005"
	Local _nUnitiz   := 1
	Local _cTipSep   := "3"
	Local _cTipEnd   := "1"
	Local _cTipSeq   := "1"
	Local _cPriEnd   := "2"
	Local _aArea     := GetArea()
	
	// Verifica se está posicionado no produto selecionado
	If !( SB1->B1_COD == cProduto .And. SB1->B1_FILIAL == xFilial )
		dbSelectArea("SB1")
		dbSetOrder(1)
		_lContinua := dbSeek( xFilial + cProduto )
	EndIf
	
	If _lContinua

		_cLocal := SB1->B1_LOCPAD
		
		// Verificar se sequencia já existe
		dbSelectArea("DC3")
		dbSetOrder(1)
		_lSeekDC3 := dbSeek( xFilial + cProduto + _cLocal + _cOrdem )
		
		// Verifico a ordem da sequencia do abastecimento pelo tipo de estrutura
		While _lSeekDC3 // Existe a sequencia
			
			If DC3->DC3_TPESTR == PadR( _cEstFis, TamSX3("DC3_TPESTR")[ 1 ] ) // Se o tipo de estrutura já estiver cadastrado
				_lContinua := .F.                                             // Não preciso cadastrar
				Exit
			Else
				_cOrdem := Soma1( _cOrdem )                                 // Senão, somo 1 na ordem e testo novamente
				_lSeekDC3 := dbSeek( xFilial + cProduto + _cLocal + _cOrdem )
			EndIf
		
		End
		
		If _lContinua

			/*
			IIF(!ExisteSX6('IMD_NORMA'), CriarSX6('IMD_NORMA', 'C','Codigo Norma - IMDA641.PRW', "{'09','235599'},{'04',''},{'05',''},{'06',''}" ),)
			aNorma 	:= 	&(GetMv('IMD_NORMA'))
			nPos 	:=	Ascan(aNorma, {|X| X[01] == xFilial })
			_cNorma	:= IIF(nPos > 0, aNorma[nPos][02], _cNorma)	
            */
            
			_cNorma    := "235599"

			RecLock( "DC3", .T. )
				DC3->DC3_FILIAL := xFilial
				DC3->DC3_CODPRO := cProduto
				DC3->DC3_LOCAL  := _cLocal
				DC3->DC3_ORDEM  := _cOrdem
				DC3->DC3_TPESTR := _cEstFis
				DC3->DC3_CODNOR := _cNorma
				DC3->DC3_REABAS := _cReabas
				DC3->DC3_NUNITI := _nUnitiz
				DC3->DC3_TIPSEP := _cTipSep
				DC3->DC3_TIPEND := _cTipEnd
				DC3->DC3_EMBDES := _cTipSeq
				DC3->DC3_PRIEND := _cPriEnd
			DC3->( MsunLock() )
			
		EndIf
	
	EndIf

	RestArea( _aArea )
	
Return


// Jean Rehermann - SOLUTIO IT - 07/01/2016 - Atualiza os campos do código de produto para as sobras (todas de uma vez)
Static Function WizCriaP()

	Local _nPrdP := aScan( oBrwX:aHeader, { |b| AllTrim( b[ 2 ] ) == "PRDPAI" } )
	Local _nPosR := aScan( oBrwX:aHeader, { |b| AllTrim( b[ 2 ] ) == "PRDPER" } )
	Local _It    := 0
	
	SetKey( VK_F6, Nil )


	For _It := 1 To Len( oBrwX:aCols )

		cBrwPPai 	:= 	oBrwX:aCols[_It][_nPrdP] 
		cBrwPSobra  :=	oBrwX:aCols[_It][_nPosR]
		lProcessa	:=	IIF(Empty(cBrwPSobra), ChkProdOk(cBrwPPai), .T.)

		// SE AINDA NãO FOI SELECIONADO O PRODUTO PARA A SOBRA
		If lProcessa
			Processa({|| CriaPrd(oBrwX:aCols[_It][_nPrdP], _It)}, "Corte de Correias", "Analisando características..." )
		EndIf

	Next

	SetKey( VK_F6, {|| WizCriaP() } )
	
Return

// Retorna array com as dimensões de cada sobra ou exibe tela com as sobras do produto pai posicionado
User Function Sobra02( aSobras, aItem, lTela )

	Local aHeaderS:= {}
	Local aColsS  := {}
	Local nPos    := 0
	Local _nX     := 0
	Local _nInt   := 0
	Local nLargF  := 0
	Local nModLrg := 0
	Local aTiras  := {}
	Local aComp   := {0,{}}
	Local aUmLarg := {}
	Local nPosSeq := aScan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "SEQUEN"} )
	Local nPosCpp := aScan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "COMPRI"} )
	Local nPosLrp := aScan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "LARGUR"} )
	Local nPosArp := aScan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "AREATT"} )
	Local nPosPro := aScan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "CODIGO"} )
	Local nPosDes := aScan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "DESCRI"} )
	Local nLinPai := aScan( oBrwB:aCols, { |Z| AllTrim( Z[ 2 ] ) == aItem[ nPosSeq ] } )

	If lTela
		SetKey( VK_F4, Nil )
    EndIf
    
	// Posicionar no item do produto pai
	nPos := aScan( aSobras, { |X| AllTrim( x[ 1 ] ) == aItem[ nPosSeq ] } )

	If nPos > 0

		// Após posicionar no array correspondente, pego o array de tiras e ordeno de menor para maior
		aTiras := aSobras[ nPos, 2 ]
		aSort( aTiras,,, { |x,y| x < y } )
		nComp := aItem[ nPosCpp ] // Determino o comprimento da peça "PAI"
		
		For _nX := 1 To Len( aTiras )
			
			// Qualquer comprimento de tira menor que o comprimento do "PAI", e maior que zero, é uma sobra (comprimentos das sobras)
			If aTiras[ _nX ] < nComP .And. aTiras[ _nX ] > 0
				aAdd( aComp[ 2 ], aTiras[ _nX ] )
			// Se a tira tiver comprimento igual ao total, significa que esta tira está inteira, não foi utilizada no corte
			ElseIf aTiras[ _nX ] == nComP				
				_nInt++ // Somo quantas tiras de igual largura não foram cortadas para no final fazer uma única tira (_nInt * LARG) X COMPR
			EndIf
			
		Next
		
		// As tiras inteiras terão as larguras somadas para formar uma única tira, mais larga, e gerar uma sobra
		If _nInt > 0
			aComp[ 1 ] := _nInt
		EndIf
		
		cGetS1 := oBrwB:aCols[ nLinPai, nPosSeq ]
		cGetS2 := oBrwB:aCols[ nLinPai, nPosPro ]
		cGetS3 := oBrwB:aCols[ nLinPai, nPosDes ]
		
		aAdd( aHeaderS, { "Quantidade ", "QUANTIDA" , "@E     999.99", 07, 2, "" , "" , "N" , ""})
		aAdd( aHeaderS, { "Largura    ", "LARGURAP" , "@E 999,999.99", 10, 2, "" , "" , "N" , ""})
		aAdd( aHeaderS, { "Unid.Medida", "UMLARGUP" , "@!           ", 03, 0, "" , "" , "C" , ""})
		aAdd( aHeaderS, { "Comprimento", "COMPRIMP" , "@E 999,999.99", 10, 2, "" , "" , "N" , ""})
		aAdd( aHeaderS, { "Área M2    ", "AREASOBR" , "@E 999,999.9999", 12, 4, "" , "" , "N" , ""})
		
		cProdFil := oBrwA:aCols[ 1, Ascan( oBrwA:aHeader,{ |X| AllTrim( x[ 2 ] ) == "CODIGO"} ) ]
		aUmLarg := U_GetUmSBS( cProdFil, "LRG", .T. )
		nModLrg := aSobras[ nPos, 3 ]
		aUmLrgO := U_GetUmSBS( cProdFil, "LRG", .F. )

		// Quantidade de tiras não cortadas + o módulo da largura (resto da divisão LRG PAI / LRG FILHO) que deve gerar uma peça única
		_nLrgMod := ( aComp[ 1 ] * aUmLrgO[ 3 ] ) + nModLrg

		If nModLrg > 0 // Se largura for maior que zero, gera uma sobra com comprimento total do PAI

			aAdd( aColsS, { 1,;
						    _nLrgMod,;
						    aUmLrgO[ 1 ],;
						    aItem[ nPosCpp ],;
						    Round( ( aItem[ nPosCpp ] / 1000 ) * ( _nLrgMod * Iif( AllTrim( aUmLrgO[ 1 ] ) == "POL", 25.4, 1 ) / 1000 ), 4 ),;
						    .F. } )
		EndIf
		
		For _nX := 1 To Len( aComp[ 2 ] )
			aAdd( aColsS, { 1,;
							aUmLrgO[ 3 ],;
						    aUmLrgO[ 1 ],;
							aComp[ 2, _nX ],;
							Round( ( aComp[ 2, _nX ] / 1000 ) * ( aUmLarg[ 3 ] / 1000 ), 4 ),;
							.F. } )
		Next
			
		If lTela
			
			If Len( aColsS ) > 0

				DEFINE MSDIALOG oDlgS TITLE "Resumo das Sobras" FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL
					@ 003, 003 MSGET oGetS1 VAR cGetS1 SIZE 028, 010 OF oDlgS READONLY COLORS 0, 16777215 PIXEL
					@ 003, 038 MSGET oGetS2 VAR cGetS2 SIZE 048, 010 OF oDlgS READONLY COLORS 0, 16777215 PIXEL
					@ 003, 092 MSGET oGetS3 VAR cGetS3 SIZE 148, 010 OF oDlgS READONLY COLORS 0, 16777215 PIXEL
					oBrwS := MsNewGetDados():New( 019, 003, 080, 241, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "",{},, Len(aColsS), "AllwaysTrue", "", "AllwaysTrue", oDlgS, aHeaderS, aColsS)
					DEFINE SBUTTON oButton1 FROM 084, 210 TYPE 01 ACTION( oDlgS:End() ) OF oDlgS ENABLE
				ACTIVATE MSDIALOG oDlgS CENTERED

			Else
				MsgAlert("Item cortado não gerou sobras!")
			EndIf

		EndIf

	Else
		If lTela
			MsgAlert("Produto não utilizado para corte!")
		EndIf
	EndIf
	
	If lTela
		Setkey( VK_F4, { || U_Sobra02( _aSobra, oBrwB:aCols[ oBrwB:nAt ], .T. ) } )
	EndIf
    
Return( Iif( lTela, Nil, aColsS ) )

// Função utilizada para exibir todas as sobras geradas, de todos os itens cortados até então, se lCols = .T. retorna o acols gerado sem mostrar a tela
User Function VerSob02(lCols)

	Local _nX      := 0
	Local _nY      := 0
	Local aHeaderS2:= {}
	Local aColsS2  := {}
	Local nPosSeq  := aScan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "SEQUEN"} )
	Local nPosPro  := aScan( oBrwB:aHeader,{ |X| AllTrim( x[ 2 ] ) == "CODIGO"} )
	Local lCols    := Iif( lCols == Nil, .F., lCols )
	
	SetKey( VK_F4, Nil )
	SetKey( VK_F5, Nil )

	aAdd( aHeaderS2, { "Sequencia  ", "SEQUENCI" , "@!           ", 03, 0, "" , "" , "C" , ""})
	aAdd( aHeaderS2, { "Produto Pai", "PRODUPAI" , "@!           ", 15, 0, "" , "" , "C" , ""})
	aAdd( aHeaderS2, { "Quantidade ", "QUANTIDA" , "@E     999.99", 07, 2, "" , "" , "N" , ""})
	aAdd( aHeaderS2, { "Largura    ", "LARGURAP" , "@E 999,999.99", 10, 2, "" , "" , "N" , ""})
	aAdd( aHeaderS2, { "Unid.Medida", "UMLARGUP" , "@!           ", 03, 0, "" , "" , "C" , ""})
	aAdd( aHeaderS2, { "Comprimento", "COMPRIMP" , "@E 999,999.99", 10, 2, "" , "" , "N" , ""})
	aAdd( aHeaderS2, { "Área M2    ", "AREASOBR" , "@E 999,999.9999", 12, 4, "" , "" , "N" , ""})

	For _nX := 1 To Len( oBrwB:aCols )
		aRet := U_Sobra02( _aSobra, oBrwB:aCols[ _nX ], .F. )
		If Len( aRet ) > 0
			For _nY := 1 To Len( aRet )
				aAdd( aColsS2, { oBrwB:aCols[ _nX, nPosSeq ], oBrwB:aCols[ _nX, nPosPro ], aRet[ _nY, 1 ], aRet[ _nY, 2 ], aRet[ _nY, 3 ], aRet[ _nY, 4 ], aRet[ _nY, 5 ], .F. } )
			Next
			aRet := {}
		EndIf
	Next

    If !lCols // Deve mostrar tela
		
		If Len( aColsS2 ) > 0
			DEFINE MSDIALOG oDlgS2 TITLE "Resumo das Sobras" FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL
				oBrwS2 := MsNewGetDados():New( 003, 003, 080, 241, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "",{},, Len(aColsS2), "AllwaysTrue", "", "AllwaysTrue", oDlgS2, aHeaderS2, aColsS2)
				DEFINE SBUTTON oButton1 FROM 084, 210 TYPE 01 ACTION( oDlgS2:End() ) OF oDlgS2 ENABLE
			ACTIVATE MSDIALOG oDlgS2 CENTERED
		Else
			MsgAlert("Não existem sobras para a configuração de corte atual!")
		EndIf
	EndIf

	Setkey( VK_F4, { || U_Sobra02( _aSobra, oBrwB:aCols[ oBrwB:nAt ], .T. ) } )
	Setkey( VK_F5, { || U_VerSob02( .F. ) } )

Return Iif( lCols, aColsS2, Nil )

// Função que exibe a lista de documentos no SD3 gerados por desmontagem e permite visualizar as mesmas
User Function IMD641De()

	Local oDlg
	Local oButton1
	Local oGetDoc
	Local _nX     := 0
	Local _cSql   := ""
	Local aHdrDoc := {}
	Local aColDoc := {}
	Local cNewAli := GetNextAlias()

	If !(ZXA->ZXA_STATUS $ "EI")	
		MsgAlert("Plano de corte precisa estar encerrado ou interrompido!")
		Return
	EndIf
	
	aAdd( aHdrDoc, { "Sequencia", "SEQ" , "@!", 03, 0, "" , "" , "C" , ""})
	aAdd( aHdrDoc, { "Documento", "DOC" , "@!", 10, 0, "" , "" , "C" , ""})
	
	_cSql := "SELECT ZXC_DOCSD3 "
	_cSql += "FROM "+ RetSqlName("ZXC") + " "
	_cSql += "WHERE ZXC_FILIAL = '"+ ZXA->ZXA_FILIAL +"' "
	_cSql += "AND   ZXC_NUMCRT = '"+ ZXA->ZXA_NUMCRT +"' "
	_cSql += "AND   D_E_L_E_T_ = ' '"

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cSql),cNewAli,.F.,.T.)
	
	While !(cNewAli)->( Eof() )
	
		_nX++
		aAdd( aColDoc, { StrZero( _nX, 3 ), (cNewAli)->ZXC_DOCSD3, .F. } )
	
		(cNewAli)->( dbSkip() )
	End
	
	(cNewAli)->( dbCloseArea() )
	
	If Len( aColDoc ) == 0
		MsgAlert("Nenhuma desmontagem encontrada para este plano de corte!")
		Return
	EndIf

	DEFINE MSDIALOG oDlg TITLE "Desmontagens do Plano "+ ZXA->ZXA_NUMCRT FROM 000, 000  TO 200, 300 COLORS 0, 16777215 PIXEL
		oGetDoc := MsNewGetDados():New( 004,003,081,144, GD_UPDATE,'AllwaysTrue()','AllwaysTrue()','',{},1,Len(aColDoc),,'','', oDlg, aHdrDoc, aColDoc)
		oGetDoc:oBrowse:bLDblClick := {|| VerDesm( AllTrim( oGetDoc:aCols[oGetDoc:nAt,2] ) ) }
		@ 084, 107 BUTTON oButton1 PROMPT "OK" ACTION oDlg:End() SIZE 037, 012 OF oDlg PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED
	
Return

// Função para visualização da desmontagem
Static Function VerDesm(cDoc)
	
	Local aArea51
	Private nFCICalc := SuperGetMV("MV_FCICALC",.F.,0) // Necessário para a rotina de visualização
	Private cPicQtOri,cPicQtDes // Pictures utilizadas na rotina de visualização
	
	If Empty( cDoc )
		MsgAlert("Documento em branco ou não encontrado!")
		Return
	EndIf
	
	aArea51 := GetArea()
	
	dbSelectArea("SD3")
	dbSetOrder(2)
	If dbSeek( xFilial("SD3") + cDoc )
		cPicQtOri := PesqPictQt("D3_QUANT"  , TamSX3("D3_QUANT"  )[ 1 ] )
		cPicQtDes := PesqPictQt("D3_QTSEGUM", TamSX3("D3_QTSEGUM")[ 1 ] )
		A242Visual( Alias(), Recno(), 2 ) // Visualiza o documento da desmontagem
	Else
		MsgAlert("Não encontrei o documento "+ cDoc +" nos movimentos de desmontagem!")
	EndIf
	
	RestArea( aArea51 )
Return

// Função para verificar se no pedido da filial de corte (quando não há transferência) existem rolamentos, e efetua a liberação destes itens
// Retorna um array com as informações de liberação
Static Function LibRolPV( cPvLibRol )
	
	Local _aRet     := {}
	Local _cBase    := ""
	Local _aAreaSC6 := SC6->( GetArea() )
	
	dbSelectArea("SC5")
	dbSetOrder(1)
	If dbSeek( cFilAnt + cPvLibRol )
		
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek( cFilAnt + cPvLibRol )
		
        While SC6->C6_FILIAL + SC6->C6_NUM == cFilAnt + cPvLibRol .And. !SC6->( Eof() )
        
        	_cBase := U_A093Base( SC6->C6_PRODUTO )
        	
        	If Empty( _cBase ) // Não é correia

				SA1->( dbSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ) )
	
				dbSelectArea("SC9")
				dbSetOrder(1)
				If dbSeek( SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_ITEM )
					While !SC9->( Eof() ).And. SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_ITEM == SC9->C9_FILIAL + SC9->C9_PEDIDO + SC9->C9_ITEM
						SC9->( A460Estorna() )
						SC9->( dbSkip() )
					End
				EndIf
					
				Begin Transaction
					MaLibDoFat( SC6->( RecNo() ), SC6->C6_QTDVEN, .T., .F., .F., .T., .F., .F. )
				End Transaction
				
				aAdd( _aRet, { SC6->C6_ITEM, SC6->C6_PRODUTO, SC6->C6_QTDVEN } )

        	EndIf
        	
        	SC6->( dbSkip() )
        End
        
	EndIf

	RestArea( _aAreaSC6 )
		
Return { _aRet }
**********************************************************************
Static Function ChkProdOk(cProduto, cOpcao)
**********************************************************************
Local aAreaAtu	:=	GetArea()
Local lRetorno	:= 	.T.
Default cOpcao	:=	'PA'	// PESQUISA O PA ou O CODIGO PASSADO


ExecBlock('ChkPosBase',.F.,.F., {'IMDA641\WizCriaP', cProduto})	
cBase	:= 	A093VldBase(cProduto)
aIdSBQ	:= 	A093ORetSBQ(cBase)
nPosMat	:= 	Ascan(aIdSBQ, { |X| AllTrim( X[01] ) == 'MAT' })
nPosFam	:= 	Ascan(aIdSBQ, {|X| AllTrim(X[01]) == 'FAM' })
nPosRef	:= 	Ascan(aIdSBQ, {|X| AllTrim(X[01]) == 'REF' })
nTamCorr:=	Len(AllTrim(cBase)) + aIdSBQ[nPosMat][02] + aIdSBQ[nPosFam][02] + aIdSBQ[nPosRef][02]

                                                             
IIF(Select('TMPB') != 0, TMPB->( DbCloseArea()),)
cQuery := " SELECT B1_FILIAL, B1_COD, B1_PROATIV, B1_MSBLQL, B1_CUSTD "
cQuery += " FROM "+ RetSqlName("SB1")
cQuery += " WHERE 	B1_FILIAL 	 = '09' " 
If cOpcao == 'PA'
	cQuery += " AND	 	B1_TIPO 	 = 'PA' "
	cQuery += " AND 	SUBSTR(B1_COD,1,"+AllTrim(Str(nTamCorr))+") = '"+SubStr(cProduto, 1, nTamCorr)+"' "
Else
	cQuery += " AND 	B1_COD	 = '"+cProduto+"' "
EndIf
cQuery += " AND 	D_E_L_E_T_ 	!= '*' 	"

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPB",.T.,.T.)
DbSelectArea('TMPB')

lProAtiv 	:= 	IIF(TMPB->B1_PROATIV == 'N', .T., .F.)
lMsBlql  	:= 	IIF(TMPB->B1_MSBLQL  == '1', .T., .F.)
lCusto   	:= 	IIF(cOpcao == 'PA', IIF(TMPB->B1_CUSTD   <=   0, .T., .F.), .F.)

If lProAtiv .Or. lMsBlql .Or. lCusto

	lRetorno	:= 	.F.
	cProbSB1 	:= 	IIF(lProAtiv, 	'PRODUTO ESTA INATIVO.' +ENTER,'')
	cProbSB1 	+= 	IIF(lMsBlql, 	'PRODUTO ESTA BLOQUEADO'+ENTER,'')
	cProbSB1 	+= 	IIF(lCusto, 	'PRODUTO ESTA COM O CUSTO ZERADO'+ENTER,'')
	
	Alert('PRODUTO: '+IIF(cOpcao == 'PA', TMPB->B1_COD, cProduto)+' COM PROBLEMA.'+ENTER+cProbSB1+ENTER+'ENTRE EM CONTATO COM DEPTO SUPRIMENTO.')

EndIf


IIF(Select('TMPB') != 0, TMPB->(DbCloseArea()),)
RestArea(aAreaAtu)
Return(lRetorno)