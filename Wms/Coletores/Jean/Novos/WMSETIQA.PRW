#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*
Jean Rehermann - Solutio IT
Programa para impressão de etiquetas avulsas e de identificação
*/

User Function WMSETIQA()

	Local nOpc     := 0
	Local aProdTiq := {}

	Private cProd  := Space(15)
	Private nQuant := 1
	Private nTipo  := "1"
	Private nTamEt := "1"
	Private aPrdIdLt := {}

	oDlg1  := MSDialog():New( 243,511,442,781,"Impressão de Etiquetas",,,.F.,,,,,,.T.,,,.T. )
	oCBox1 := TComboBox():New( 015,004,{|u| If(PCount()>0,nTipo:=u,nTipo)},{"1=Avulsa","2=Identificação","3=Pallet Vol."},056,010,oDlg1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,"nTipo" )
	oCBox2 := TComboBox():New( 015,064,{|u| If(PCount()>0,nTamEt:=u,nTamEt)},{"1=Pequena","2=Grande"},056,010,oDlg1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,"nTamEt" )
	oSay1  := TSay():New( 004,004,{||"Tipo de Etiqueta"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008)
	oSay2  := TSay():New( 004,064,{||"Tamanho"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGet1  := TGet():New( 037,004,{|u| If(PCount()>0,cProd:=u,cProd)},oDlg1,056,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SB1","cProd",,,,.F.,.F.,,"Produto",1)
	oGet2  := TGet():New( 037,076,{|u| If(PCount()>0,nQuant:=u,nQuant)},oDlg1,044,008,'@E 9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nQuant",,,,.F.,.F.,,"Quantidade",1)
	oBtn1  := TButton():New( 076,004,"Mais Produtos",oDlg1,{|| MaisProd() },052,012,,,,.T.,,"",,,,.F. )
	oSBtn1 := SButton():New( 076,067,1,{|| Iif(TudoOk(),(nOpc:=1,oDlg1:End()),nOpc:=0)},oDlg1,,"", )
	oSBtn2 := SButton():New( 076,099,2,{||oDlg1:End()},oDlg1,,"", )
	oBtn1:bWhen := {|| nTipo == "2" }
	oDlg1:Activate(,,,.T.)

	If nOpc == 1
		
		If !CB5SetImp( GetMv("MV_IACD02"),IsTelNet() )
			CBAlert('Codigo do tipo de impressao invalido')
			Return
		EndIF

		If nTipo == "1"
			
			DbSelectArea('CB0')

			For _nX := 1 To nQuant
				
				While .T.
				
					cID := Padr( CBProxCod('MV_CODCB0'), 10 )
					
					If ! CB0->( DbSeek( xFilial("CB0") + cID ) )
						Exit
					EndIf
				
				EndDo
				
				If nTamEt == "2"
					Avulsa2( cId, .F. )
				Else
					aAdd( aProdTiq, cId )
				Endif
				
			Next
			
			If nTamEt == "1"
				Avulsa1( aProdTiq, 1 ) // Id Avulsa
			EndIf
			
		ElseIf nTipo == "2"
			
			If Empty( aPrdIdLt )
				For nX := 1 To nQuant
					aAdd( aProdTiq, cProd )
				Next
			Else // Para imprimir a identificação de mais de um produto
				For _nY := 1 To Len( aPrdIdLt )
					For nX := 1 To aPrdIdLt[ _nY, 2 ]
						aAdd( aProdTiq, aPrdIdLt[ _nY, 1 ] )
					Next
				Next
				
				aPrdIdLt := {}
			
			EndIf
		    
			Avulsa1( aProdTiq, 2 ) // Identificação Produto
		
		ElseIf nTipo == "3"
			
			For _nX := 1 To nQuant
				
				While .T.
				
					cID := Padr( CBProxCod('IMD_VPALET'), TamSX3("D00_PALLET")[1] )
					
					If VerPltNovo( cID ) == 0
						Exit
					EndIf
				
				EndDo
				
				Avulsa2( cId, .T. )
				
			Next

		EndIf
		
		MSCBCLOSEPRINTER()
		
	EndIf
	
Return

// Valida os campos da tela
Static Function TudoOk()

	Local _lOk := .T.

	If nQuant < 1
		MsgAlert("Quantidade precisa ser maior que ZERO!")
		_lOk := .F.
	Endif
	
	If _lOk .And. nTipo == "2"
		nTamEt := 1
		If Empty( cProd ) .And. Len( aPrdIdLt ) == 0
			MsgAlert("Produto precisa ser informado!")
			_lOk := .F.
		EndIf
	EndIf
	
Return( _lOk )


// Imprime etiqueta avulsa (nTipo=1) de tamanho pequeno e etiquetas de identificação de produto (nTipo=2)
Static Function Avulsa1( aImp, nTipo )

	Local nMax := Len( aImp )
	Local nCol01_1 := ""
	Local nCol02_1 := ""
	Local nCol03_1 := ""
	Local nCol04_1 := ""
	Local nCol01_2 := ""
	Local nCol02_2 := ""
	Local nCol03_2 := ""
	Local nCol04_2 := ""
	Local nCol01_3 := ""
	Local nCol02_3 := ""
	Local nCol03_3 := ""
	Local nCol04_3 := ""

	If nTipo == 2
		dbSelectArea("SB1")
		dbSetOrder(1)
	EndIf

	For nX := 1 To nMax

		If nTipo == 2
			SB1->( MsSeek( xFilial("SB1") + aImp[ nX ] ) )
			nCol01_1 := "Cod. "+ AllTrim( SB1->B1_COD )
			nCol02_1 := "Desc. "+ Left( AllTrim( SB1->B1_DESC ), 20 )
			nCol03_1 := Left( AllTrim( SB1->B1_DESC ), 21 )
			nCol04_1 := AllTrim( SB1->B1_CODBAR )
		Else
			nCol04_1 := AllTrim( aImp[ nX ] )
		EndIf
		nX++
		If nX <= nMax
			If nTipo == 2
				SB1->( MsSeek( xFilial("SB1") + aImp[ nX ] ) )
				nCol01_2 := "Cod. "+ AllTrim( SB1->B1_COD )
				nCol02_2 := "Desc. "+ Left( AllTrim( SB1->B1_DESC ), 20 )
				nCol03_2 := Left( AllTrim( SB1->B1_DESC ), 21 )
			    nCol04_2 := AllTrim( SB1->B1_CODBAR )
			Else
				nCol04_2 := AllTrim( aImp[ nX ] )
			EndIf
	    	nX++
	    EndIf
		If nX <= nMax
			If nTipo == 2
				SB1->( MsSeek( xFilial("SB1") + aImp[ nX ] ) )
				nCol01_3 := "Cod. "+ AllTrim( SB1->B1_COD )
				nCol02_3 := "Desc. "+ Left( AllTrim( SB1->B1_DESC ), 20 )
				nCol03_3 := Left( AllTrim( SB1->B1_DESC ), 21 )
			    nCol04_3 := AllTrim( SB1->B1_CODBAR )
			Else
				nCol04_3 := AllTrim( aImp[ nX ] )
			EndIf
	    EndIf
	
		MSCBBEGIN( 1, 6 )
	
		If ! Empty(nCol01_1)
			MSCBSAY(08,16,nCol01_1,"N","1","1,1")
		EndIf
	
		If ! Empty(nCol01_2)
			MSCBSAY(42,16,nCol01_2,"N","1","1,1")
		EndIf
	
		If ! Empty(nCol01_3)
			MSCBSAY(76,16,nCol01_3,"N","1","1,1")
		EndIf
	
		MSCBSAY(08,14,nCol02_1,"N","1","1,1")
	
		If ! Empty(nCol02_2)
		   MSCBSAY(42,14,nCol02_2,"N","1","1,1")
		EndIf
	
		If ! Empty(nCol02_3)
			MSCBSAY(76,14,nCol02_3,"N","1","1,1")
		EndIf
	
		If ! Empty(nCol03_1)
			MSCBSAY(08,12,nCol03_1,"N","1","1,1")
		EndIf
	
		If ! Empty(nCol03_2)
			MSCBSAY(42,12,nCol03_2,"N","1","1,1")
		EndIf
	
		If ! Empty(nCol03_3)
			MSCBSAY(76,12,nCol03_3,"N","1","1,1")
		EndIf
	
		MSCBSAYBAR(09+Iif(nTipo==2,0,3),01,nCol04_1,"N","E",5,.F.,.t.,.f.,,3,2,.T.)
		
		If ! Empty(nCol04_2)
			MSCBSAYBAR(42+Iif(nTipo==2,0,3),01,nCol04_2,"N","E",5,.F.,.t.,.f.,,3,2,.T.)
		Endif
	
		If ! Empty(nCol04_3)
			MSCBSAYBAR(75+Iif(nTipo==2,0,3),01,nCol04_3,"N","E",5,.F.,.t.,.f.,,3,2,.T.)
		Endif
	
		MSCBEND()

		nCol01_1 := ""
		nCol02_1 := ""
		nCol03_1 := ""
		nCol04_1 := ""
		nCol01_2 := ""
		nCol02_2 := ""
		nCol03_2 := ""
		nCol04_2 := ""
		nCol01_3 := ""
		nCol02_3 := ""
		nCol03_3 := ""
		nCol04_3 := ""

	Next

Return

// Imprime etiqueta avulsa ou de pallet de volume de tamanho grande
Static Function Avulsa2( cId, lPallet )

		MSCBBEGIN(1,6)                            
			MSCBBOX(07,24,96,65,1)    
			MSCBLineH(35,60,96,1) 
			MSCBLineH(07,53,96,1) 
			MSCBLineH(07,45,96,1) 
			MSCBLineH(07,39,96,1) 
			MSCBLineV(35,53,64,1)
			MSCBSAY(13,55,'IMDEPA',"N","5","01,01")
			If !lPallet
				MSCBSAY(38,61,'ETIQUETA AVULSA',"N","2","01,01")
				MSCBSAY(38,58,'CODIGO',"N","1","01,01")
				MSCBSAY(38,54,"", "N", "3", "01,01")
				MSCBSAY(09,50,'DESCRICAO',"N","1","01,01")
				MSCBSAY(09,46,"","N", "2", "01,01")
				MSCBSAY(09,40,'QUANTIDADE: ',"N","2","01,01")
			Else
				MSCBSAY(38,61,'ETIQUETA DE PALLET DE VOLUMES',"N","2","01,01")
				MSCBSAY(38,58,'PALLET',"N","1","01,01")
			Endif
			MSCBSAYBAR(33,27,cID,"N","E",8.36,.F.,.T.,.F.,,3,2,.F.,.F.,"1",.T.)
		MSCBEND()

Return

// Função que exibe tela para seleção de produtos para impressão em lote de etiquetas de identificação
Static Function MaisProd()

	Local aHoBrw1 := {{"Código","PRODUTO","@!",15,0,"ExistCpo('SB1')","","C","SB1","","",""},{"Quantidade","QUANT","@E 999",5,0,"","","N","","","","1"}}
	Local aCoBrw1 := {{Space(15),1,.F.}}
	Local nOpc    := GD_INSERT+GD_DELETE+GD_UPDATE
	Local oDlg1   := MSDialog():New( 092,232,286,567,"Inserir produtos",,,.F.,,,,,,.T.,,,.T. )
	Local oSBtn1  := SButton():New( 072,128,1,{||oDlg1:End()},oDlg1,,"", )
	
	oBrw1 := MsNewGetDados():New(004,004,060,152,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,999,'AllwaysTrue()','','AllwaysTrue()',oDlg1,aHoBrw1,aCoBrw1 )
	oDlg1:Activate(,,,.T.)

	aPrdIdLt := {}
	
	For _nX := 1 To Len( oBrw1:aCols )
		If !oBrw1:aCols[ _nX, 3 ]
			aAdd( aPrdIdLt, { oBrw1:aCols[ _nX, 1 ], oBrw1:aCols[ _nX, 2 ] } )
		EndIf
	Next
	
Return

// Verifica se o código de Pallet já existe
Static Function VerPltNovo( cPallet )

	Local _nQtReg := 0
	Local _cQuery := ""
	Local _cAlias := ""
	Local _aArea  := GetArea()

	_cQuery := "SELECT COUNT(*) QTDREG "
	_cQuery += " FROM "+ RetSqlName("D00")
	_cQuery += " WHERE D00_FILIAL = '"+ xFilial("D00") +"'"
	_cQuery += "   AND D00_PALLET = '"+ cPallet +"' "
	_cQuery += "   AND D_E_L_E_T_ = ' '"

	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	_nQtReg := (_cAlias)->QTDREG
	(_cAlias)->( dbCloseArea() )

	RestArea( _aArea )

Return( _nQtReg )
