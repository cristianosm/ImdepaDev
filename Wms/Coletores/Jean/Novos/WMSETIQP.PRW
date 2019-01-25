#INCLUDE "PROTHEUS.CH"

/*
Jean Rehermann - Solutio IT
Programa para impressão de etiquetas de Pallet
*/

User Function WMSETIQP()

	Local nOpc    := 0
	Local nCopias := 1
	Local nLinha  := 1
	Local cPesq   := Space( Len( CB0->CB0_CODETI ) )
	Local _cQuery := ""
	Local cPallet := ""
	Local _cAlias := GetNextAlias()
	
	Private aEtiq    := {}
	Private aEtiqTmp := {}
	Private aPallet  := {}
	Private oDlg1,oSay1,oSay2,oSay3,oSay4,oBrw1,oBrw2,oGet1,oSBtn1,oGet2,oBtn1,oSBtn2

	_cQuery := "SELECT CB0_CODETI, CB0_CODPRO, CB0_QTDE, CB0_PALLET"
	_cQuery += " FROM "+ RetSqlName('CB0') +" CB0"
	_cQuery += " WHERE  CB0_FILIAL = '"+ xFilial("CB0") +"'"
	_cQuery += "    AND CB0_PALLET <> ' '"
	_cQuery += "    AND CB0_TIPO   = '01'"
	_cQuery += "    AND D_E_L_E_T_ = ' ' "
	_cQuery += " ORDER BY CB0_PALLET DESC"
	
	_cQuery := ChangeQuery(_cQuery)
	
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,_cQuery),_cAlias,.F.,.T.)

	While !(_cAlias)->( Eof() )
	
		If cPallet != (_cAlias)->CB0_PALLET
			aAdd( aPallet, { (_cAlias)->CB0_PALLET } )
			cPallet := (_cAlias)->CB0_PALLET
		EndIf
		
		aAdd( aEtiqTmp, { (_cAlias)->CB0_CODETI, (_cAlias)->CB0_QTDE, Posicione("SB1",1,xFilial("SB1")+(_cAlias)->CB0_CODPRO,"B1_DESC"), (_cAlias)->CB0_PALLET } )
		
		(_cAlias)->( dbSkip() )
	End
	
	(_cAlias)->( dbCloseArea() )
	
	If Len( aPallet ) > 0
		For _nX := 1 To Len( aEtiqTmp )
			If aEtiqTmp[ _nX, 4 ] == aPallet[ 1, 1 ]
				aAdd( aEtiq, aEtiqTmp[ _nX ] )
			EndIf
		Next
	EndIf
	
	oDlg1 := MSDialog():New( 099,324,459,776,"Impressão de Etiqueta Pallet",,,.F.,,,,,,.T.,,,.T. )
	oSay1 := TSay():New( 004,004,{||"Pallets"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay2 := TSay():New( 004,085,{||"Produtos no Pallet"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,064,008)
	oBrw1 := TcBrowse():New(016,004,075,150,,,,oDlg1,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)
	oBrw2 := TcBrowse():New(016,085,135,080,,,,oDlg1,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)
	oGet2 := TGet():New( 122,085,{|u| If(PCount()>0,cPesq:=u,cPesq)}    ,oDlg1,040,008,'@!'    ,{|| PsqPallet(cPesq) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cPesq"  ,,,,.F.,.F.,,"Pesquisar Pallet: ",2)
	oGet1 := TGet():New( 154,085,{|u| If(PCount()>0,nCopias:=u,nCopias)},oDlg1,028,008,'@E 999',{||nCopias>0},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nCopias",,,,.F.,.F.,,"Cópias: ",02)
	oSBtn1:= SButton():New( 152,188,1,{|| nOpc := 1, nLinha := oBrw1:nAt, oDlg1:End() },oDlg1,,"", )
	oSBtn2:= SButton():New( 152,156,2,{|| oDlg1:End() },oDlg1,,"", )
	
	oBrw1:AddColumn( TcColumn():New( "Etiqueta Pallet",{ || aPallet[oBrw1:nAt,1]}, "@!",,,"CENTER",020,.f.,.f.) )
	
	oBrw2:AddColumn( TcColumn():New( "Etiqueta"  ,{ || aEtiq[oBrw2:nAt,1]}, "@!"        ,,,"LEFT"  ,040,.f.,.f.) )
	oBrw2:AddColumn( TcColumn():New( "Quantidade",{ || aEtiq[oBrw2:nAt,2]}, "@e 999,999",,,"RIGHT" ,040,.f.,.f.) )
	oBrw2:AddColumn( TcColumn():New( "Produto"   ,{ || aEtiq[oBrw2:nAt,3]}, "@!"        ,,,"LEFT"  ,100,.f.,.f.) )

	oBrw1:SetArray( aPallet )
	oBrw2:SetArray( aEtiq )
    
	oBrw1:bChange := {|| AtuEtiq() }
	oGet2:SetFocus()
	
	oDlg1:Activate(,,,.T.)

	If nOpc == 1
		
		If !CB5SetImp( GetMv("MV_IACD02"),IsTelNet() )
			MsgAlert('Codigo do tipo de impressao invalido')
			Return
		EndIF
		    
		For _nX := 1 To nCopias
			U_IMG10( aPallet[nLinha,1], Len( aEtiq ) )
		Next
		
		MSCBCLOSEPRINTER()
		
	EndIf
	
Return

// Imprime etiqueta de Pallet de tamanho grande
User Function IMG10( cId, nQtdVol )

	Local cIdEti := Iif( cId == Nil, PARAMIXB[1], cId )
	
	MSCBBEGIN(1,6)                            
		MSCBBOX(07,24,96,65,1)    
		MSCBLineH(35,60,96,1) 
		MSCBLineH(07,53,96,1) 
		MSCBLineH(07,45,96,1) 
		MSCBLineH(07,39,96,1) 
		MSCBLineV(35,53,64,1)
		MSCBSAY(13,55,'IMDEPA',"N","5","01,01")
		MSCBSAY(38,61,'ETIQUETA DE PALLET',"N","2","01,01")
		MSCBSAY(38,58,'PALLET: ',"N","1","01,01")
		MSCBSAY(38,54, cIdEti, "N", "3", "01,01")
		If nQtdVol != Nil
			MSCBSAY(09,40,'VOLUMES NO PALLET: '+ PADL( cValToChar( nQtdVol ), 10 ),"N","2","01,01")
		EndIf
		MSCBSAYBAR(33,27,cIdEti,"N","E",8.36,.F.,.T.,.F.,,3,2,.F.,.F.,"1",.T.)
	MSCBEND()

Return

// Função que atualiza o browse de etiquetas que compõe o pallet
Static Function AtuEtiq()

	aEtiq:={}
	
	For _nX := 1 To Len( aEtiqTmp )
		If aEtiqTmp[_nX,4] == aPallet[oBrw1:nAt,1]
			aAdd( aEtiq, aEtiqTmp[_nX] )
		EndIf
	Next
	
	oBrw2:SetArray( aEtiq )
	oBrw2:Refresh()

Return

// Função que faz a pesquisa por um número de etiqueta de pallet
Static Function PsqPallet( cPesquisa )

	Local nPos := aScan( aPallet, {|o| o[1] == cPesquisa } )
	
	If nPos > 0
	
		oBrw1:nAt := nPos
		oBrw1:Refresh()
		AtuEtiq()
	
    EndIf
    
Return ( nPos > 0 .Or. Empty( cPesquisa ) )