#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APVT100.CH"

/*
Jean Rehermann - Solutio IT - 27/06/2017
Ponto de entrada na conferencia de entrada na leitura do código de barras
Tratamento para buscar o código de produto correto por conta do EAN13 repetido
Parametrização para permitir digitação de acordo com cada rotina chamadora
*/

User Function CBRETEAN()

	Local uAux
	Local aRet         := {}
	Local aEan128      := {}
	Local cCodBar      := ''
	Local cDL          := ''
	Local cProduto     := ''
	Local cUnDespacho  := ''
	Local cLote        := ''
	Local nQE          := 0
	Local nPos         := 0
	Local nOrdemSB1    := 0
	Local nQtdeDespacho:= 0
	Local lEAN13OU8    := .F.
	Local lEAN14       := .F.
	Local lEAN128      := .F.
	Local lEAN12813OU8 := .F.
	Local lEAN12814    := .F.
	Local lEAN12814VAR := .F.
	Local cID          := PARAMIXB[1]
	Local dValid       := CtoD('')
	Local cNumSerie    := Space(20)

	Local _cProdB1     := ""
	Local _cB1         := ""
	Local _cAlias      := ""
	Local _cAliasSDB   := ""
	Local _cQuery      := ""
	Local _nRecSDB     := 0
	Local _aSDB        := {}
	Local _lConfEnt    := IsInCallStack("WMSV073") .And. IsInCallStack("VALIDPRDLOT") // Conferencia de entrada
	Local _lEntE13     := SuperGetMV('IMD_ENTE13', .F., .T.) .And. _lConfEnt // Aceita digitar quantidade no EAN13 (apenas conferência de entrada)
	Local _lEndEnt     := IsInCallStack("DLGV080") .And. IsInCallStack("DLV30VLPRO") // Endereçamento na entrada
	Local _lEndE13     := SuperGetMV('IMD_ENDE13', .F., .T.) .And. _lEndEnt // Aceita digitar quantidade no EAN13 (apenas endereçamento entrada)
	Local _lApnSep     := IsInCallStack("DLGV030") .And. IsInCallStack("DLV030UM") // Apanhe de separação
	Local _lApnE13     := SuperGetMV('IMD_APNE13', .F., .T.) .And. _lApnSep // Aceita digitar quantidade no EAN13 (apenas apanhe separação)
	
	// Primeiro de tudo, verifica se operador solicitou consulta aos divergentes na conferência de entrada
	If _lConfEnt .And. Len( Alltrim( cID ) ) == 1 .And. Upper( Alltrim( cID ) ) == "D"
		VerDiver()
		Return( {} )		
	EndIf
	
	// Verifica se o usuário bipou o código do produto
	If Len( Alltrim( cID ) ) <= TamSX3("B1_COD")[1]

		SB1->(DbSetOrder(1))
		If SB1->( MsSeek( xFilial('SB1') + cID ) ) // Código de produto válido digitado

			If _lEndEnt .Or. _lApnSep

				// Quando for endereçamento ou apanhe não pode aceitar produto diferente do posicionado no SDB
				If !( SDB->DB_PRODUTO $ cID )
					Return aRet
				Else
					nQE := Iif( _lEndE13 .Or. _lApnE13, 0, 1 )
				EndIf
			
			ElseIf _lConfEnt // Conferencia de entrada
				nQE := Iif( _lEntE13, 0, 1 )
			ElseIf IsInCallStack("ALTPRDEND") // Selecionar o produto para endereçar, tratamento diferenciado
				Return("'"+ cId +"'")
			ElseIf IsInCallStack("VLDPRO") // Validação na contagem (inventário)
				Return( {cID} )
			ElseIf IsInCallStack("VLPRDRET") // Validação do produto na retirada de volumes
				Return( {cID} )
			Else
				nQE := 1
			EndIf
			
			Return {SB1->B1_COD,nQE,Padr(cLote,TamSX3("CB8_LOTECT")[1]),dValid,Padr(cNumSerie,20)}
		EndIf
	EndIf

	If Len(Alltrim(cID)) == 8  .or. Len(Alltrim(cID)) == 13 .or. Len(Alltrim(cID)) == 12
		cCodBar := AllTrim(cID)
		lEAN13OU8 :=.T.
	
	ElseIf Len(Alltrim(cID)) == 14
		cCodBar := Subs(Alltrim(cID),2,12)
		cUnDespacho := Left(cID,1) //-- checar o digito
		If Left(cCodBar,5) =="00000"
			cCodBar := Subs(cCodBar,6)
		EndIf
		lEAN14 := .T.
		
	ElseIf Len(Alltrim(cID)) > TamSX3("B1_COD")[1] .and. ! UsaCB0('01')
		aEan128 := CBAnalisa128(cID)
		If ! Empty(aEan128)
			lEAN128 := .T.
			nPos := Ascan(aEan128,{|x| x[1] == "01"})
			If nPos > 0
				cCodBar:= Subst(aEan128[nPos,2],2,12)
				cDL := Left(aEan128[nPos,2],1)
			EndIf
			nPos := Ascan(aEan128,{|x| x[1] == "02"})
			If nPos > 0
				cCodBar:= Subst(aEan128[nPos,2],2,12)
				cDL := Left(aEan128[nPos,2],1)
			EndIf
			nPos := Ascan(aEan128,{|x| x[1] == "8006"})
			If nPos > 0
				cCodBar:= Subst(aEan128[nPos,2],2,12)
				cDL := Left(aEan128[nPos,2],1)
			EndIf
			If cDL $ "12345678"
				cUnDespacho := cDL
				lEAN12814 := .T.
			ElseIf cDL =="0"
				lEAN12813OU8 := .T.
			ElseIf cDL =="9"
				lEAN12814VAR := .T.
			EndIf
			If Left(cCodBar,5) =="00000"
				cCodBar := Subs(cCodBar,6)
			EndIf
		EndIf
	Else
		If UsaCB0('01') .And. Len( AllTrim( cID ) ) == Len( AllTrim( GetMv("MV_CODCB0") ) )
			Return( {} )
		Else
			cCodBar := Alltrim(cID)
			lEAN13ou8 := .T.
		EndIf
	EndIf

	If ! lEAN13ou8 .And. ! lEAN14 .and. !lEAN128 .or. Empty(cCodBar)
		Return( {} )
	EndIf

	nOrdemSB1:= SB1->( IndexOrd() )
	SB1->(DbSetOrder(5))

	If ( ( _lConfEnt .Or. _lApnSep .Or. _lEndEnt ) .Or. IsInCallStack("ALTPRDEND") .Or. IsInCallStack("VLDPRO") .Or. IsInCallStack("VLPRDRET") ) .And. ( lEAN13ou8 .Or. lEAN14 .Or. lEAN128 )
	
		If SB1->( dbSeek( xFilial("SB1") + cCodBar ) ) // Posiciono pelo código de barras

			aArea51 := GetArea()
			_cB1    := "'"
			_cAlias := ""
			
			_cQuery := "SELECT B1_COD "
			_cQuery += " FROM "+ RetSqlName("SB1")
			_cQuery += " WHERE B1_FILIAL = '"+ xFilial("SB1") +"'"
			If lEAN14
				_cQuery += " AND SUBSTR(B1_CODBAR,1,12) = '"+ cCodBar +"'"
			Else
				If Len( cCodBar ) == 11 // Jean Rehermann - 10/11/2017 - Ocorreu leitura de CB da Timken com 11 caract.
					_cQuery += " AND B1_CODBAR LIKE '"+ cCodBar +"%'"
				Else
					_cQuery += " AND B1_CODBAR = '"+ cCodBar +"'"
				EndIf
			EndIf
			_cQuery += " AND D_E_L_E_T_ = ' '"
			_cQuery += " AND B1_MSBLQL <> '1'"
			_cQuery += " ORDER BY B1_COD ASC "
			
			TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	
			// Lista com todos os B1_COD com mesmo EAN (formatado para utilizar no IN do SQL)
			While !(_cAlias)->( Eof() )
				_cB1 += (_cAlias)->B1_COD +"','"
				(_cAlias)->( dbSkip() )
			End
			(_cAlias)->( dbCloseArea() )
			
			// Quando for endereçamento ou apanhe não pode aceitar produto diferente do posicionado no SDB
			If _lEndEnt .Or. _lApnSep

				If !( _cB1 == "'" ) // Se encontrar algo
					If SDB->DB_PRODUTO $ _cB1
						_cProdB1 := SDB->DB_PRODUTO
					EndIf
				EndIf

			ElseIf IsInCallStack("ALTPRDEND") // Quando estou buscando o produto para endereçar
			
				If !( _cB1 == "'" ) // Se encontrar algo
					Return( Left( _cB1, Len( _cB1 ) - 2 ) )
				Else
					Return("")
				EndIf
			
			Elseif IsInCallStack("VLDPRO") // Quando estou validando o produto na tela de contagem de endereços
			
				If !( _cB1 == "'" ) // Se encontrar algo
					Return( StrTokArr( StrTran( Left( _cB1, Len( _cB1 ) - 2 ), "'", "" ), "," ) )
				Else
					Return( {} )
				EndIf

			Elseif IsInCallStack("VLPRDRET") // Quando estou validando o produto na tela de retirada de volumes
			
				If !( _cB1 == "'" ) // Se encontrar algo
					Return( StrTokArr( StrTran( Left( _cB1, Len( _cB1 ) - 2 ), "'", "" ), "," ) )
				Else
					Return( {} )
				EndIf

			// Quando for conferência de entrada busco pelo SDB do produto lido
			ElseIf _lConfEnt

				If !( _cB1 == "'" )
	
					_cAliasSDB := GetNextAlias()
					
					_cQuery := "SELECT DB_PRODUTO, DB_QUANT, DB_QTDLID, R_E_C_N_O_"
					_cQuery += " FROM "+ RetSqlName('SDB') +" SDB"
					_cQuery += " WHERE DB_FILIAL  = '"+ xFilial("SDB") +"'"
					_cQuery += " AND DB_ESTORNO   = ' '"
					_cQuery += " AND DB_SERVIC    = '003'"
					_cQuery += " AND DB_TAREFA    = '003'"
					_cQuery += " AND DB_ATIVID    = '022'"
					_cQuery += " AND DB_ORIGEM    = 'SD1' "
					_cQuery += " AND DB_DOC       = '"+ SDB->DB_DOC    +"' "
					_cQuery += " AND DB_SERIE     = '"+ SDB->DB_SERIE  +"' "
					_cQuery += " AND DB_CLIFOR    = '"+ SDB->DB_CLIFOR +"' "
					_cQuery += " AND DB_LOJA      = '"+ SDB->DB_LOJA   +"' "
					_cQuery += " AND DB_STATUS  IN ('3','4')"
					_cQuery += " AND DB_PRODUTO IN ("+ SubStr( _cB1, 1, Len( _cB1 ) - 2 ) +")"
					_cQuery += " AND D_E_L_E_T_ = ' '"
					
					_cQuery := ChangeQuery(_cQuery)
					
					dbUseArea(.T.,'TOPCONN',TcGenQry(,,_cQuery),_cAliasSDB,.F.,.T.)
				
					TCSetField(_cAliasSDB,'DB_QUANT ','N',TamSx3('DB_QUANT')[1] , TamSx3('DB_QUANT')[2] )
					TCSetField(_cAliasSDB,'DB_QTDLID','N',TamSx3('DB_QTDLID')[1], TamSx3('DB_QTDLID')[2])
			
					_aSDB := {}
				
					(_cAliasSDB)->( dbGoTop() )
					While !(_cAliasSDB)->( Eof() )
						
						aAdd( _aSDB, { (_cAliasSDB)->DB_PRODUTO, (_cAliasSDB)->DB_QUANT, (_cAliasSDB)->DB_QTDLID, (_cAliasSDB)->R_E_C_N_O_ } )
						
						(_cAliasSDB)->( dbSkip() )
					End
					(_cAliasSDB)->( DbCloseArea() )
					RestArea( aArea51 )
			
					If Len( _aSDB ) > 0
			
						aSort( _aSDB,,, { |x, y| x[3] > y[3] } )
						
						For _nX := 1 To Len( _aSDB )
							If _aSDB[ _nX, 3 ] < _aSDB[ _nX, 2 ]
								_cProdB1 := _aSDB[ _nX, 1 ]
								_nRecSDB := _aSDB[ _nX, 4 ]
								Exit
							EndIf
						Next
				
						If Empty( _cProdB1 ) .And. _nRecSDB == 0
							_cProdB1 := _aSDB[ Len( _aSDB ), 1 ]
							_nRecSDB := _aSDB[ Len( _aSDB ), 4 ]
						EndIf
						
						SDB->( dbGoTo( _nRecSDB ) )
					EndIf
				EndIf

			EndIf
			
		EndIf
	EndIf

	// Se for conferencia, endereçamento ou apanhe e for EAN e Encontrou SB1 ( _cProdB1 não vazio)
	If ( _lConfEnt .Or. _lApnSep .Or. _lEndEnt ) .And. ( lEAN13ou8 .Or. lEAN14 .Or. lEAN128 ) .And. !Empty( _cProdB1 )

		SB1->(DbSetOrder(1))
		SB1->(DBSeek(xFilial("SB1")+_cProdB1))

	// Caso contrário, se não encontrou o B1 para posicionar, ordeno pelo índice do código de barras e pesquiso
	Else
		SB1->(DbSetOrder(5))
		SB1->(DBSeek(xFilial("SB1")+cCodBar))
	EndIf
	
	SB1->(DbSetOrder(nOrdemSB1))
	If SB1->(Eof())
		dbSelectArea("SLK")
		SLK->( dbSetOrder(1) )
		If SB1->( DBSeek(xFilial("SLK")+cCodBar) )
			aRet := {LK_CODIGO, LK_QUANT,Padr(cLote,TamSX3("CB8_LOTECT")[1]),dValid,Padr(cNumSerie,20)}
			Return aRet
		Else
			Return aRet
		EndIf
	EndIf
	
	SB5->(DbSetOrder(1))
	SB5->(DBSeek(xFilial("SB5")+SB1->B1_COD))

	If lEAN13ou8
		// Se estiver na rotina determinada com parâmetro permitindo ler quantidade, retorno 0, senão retorno 1
		nQE := Iif( _lEntE13 .Or. _lEndE13 .Or. _lApnE13, 0, 1 )
	
	ElseIf lEAN14
		nQtdeDespacho := SB5->(FieldGet(FieldPos("B5_EAN14"+cUnDespacho)))
		If nQtdeDespacho == 0
			VTAlert("EAN14 sem quantidade definida no campo B5_EAN14"+ cUnDespacho )
		EndIf
		nQE := nQtdeDespacho
	
	ElseIf lEAN128
		nPos := Ascan(aEan128,{|x| x[1] == "30"})  // Qtde variavel
		If nPos > 0
			nQtdeDespacho:= Val(aEan128[nPos,2])
		EndIf
		nPos := Ascan(aEan128,{|x| x[1] == "37"}) // Qtde de itens comerciais
		If nPos > 0
			nQE:= Val(aEan128[nPos,2])
			If lEAN12814
				nQE:= nQE * SB5->(FieldGet(FieldPos("B5_EAN14"+cUnDespacho)))
			ElseIf lEAN12814VAR
				If ! Empty(nQtdeDespacho)
					nQE:= nQE * nQtdeDespacho
				EndIf
			EndIf
		Else
			nQE := nQtdeDespacho
		EndIf
		nPos := Ascan(aEan128,{|x| x[1] == "10"})  // lote
		If nPos > 0
			cLote := aEan128[nPos,2]
		EndIf
		nPos := Ascan(aEan128,{|x| x[1] == "15"})  // data de durabilidade
		If nPos > 0
			uAux:= right(aEan128[nPos,2],2)+'/'+Subs(aEan128[nPos,2],3,2)+'/'+right(aEan128[nPos,2],2)
			If Left(uAux,2) =="00"
				uAux := "01"+Subs(uAux,3)
				dValid := ctod(StrZero(LastDay(ctod(uAux)),2)+Subs(uAux,3))
			Else
				dValid := ctod(uAux)
			EndIf
		EndIf
		nPos := Ascan(aEan128,{|x| x[1] == "17"})  // data de validade
		If nPos > 0
			uAux:= right(aEan128[nPos,2],2)+'/'+Subs(aEan128[nPos,2],3,2)+'/'+right(aEan128[nPos,2],2)
			If Left(uAux,2) =="00"
				uAux := "01"+Subs(uAux,3)
				dValid := ctod(StrZero(LastDay(ctod(uAux)),2)+Subs(uAux,3))
			Else
				dValid := ctod(uAux)
			EndIf
		EndIf
		nPos := Ascan(aEan128,{|x| x[1] == "21"})  // numero de serie
		If nPos > 0
			cNumSerie := aEan128[nPos,2]
		EndIf
	EndIf 

	aRet := {SB1->B1_COD,nQE,Padr(cLote,TamSX3("CB8_LOTECT")[1]),dValid,Padr(cNumSerie,20)}
	
Return( aRet )

// Consulta aos itens com divergência
Static Function VerDiver()

	Local aAreaAnt   := GetArea()
	Local aProduto   := {}
	Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
	Local cQuery     := ""
	Local cAliasQry  := GetNextAlias()
	Local aHeaders   := {}
	Local aSizes     := {}
	Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])

	cQuery := "SELECT DB_PRODUTO, DB_QUANT, DB_QTDLID"
	cQuery +=  " FROM "+ RetSqlName('SDB') +" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+ xFilial("SDB") +"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_DOC     = '"+ SDB->DB_DOC     +"'"
	cQuery +=   " AND DB_SERIE   = '"+ SDB->DB_SERIE   +"'"
	cQuery +=   " AND DB_SERVIC  = '"+ SuperGetMV('IMD_SVCNFS', .F., '003') +"'"
	cQuery +=   " AND DB_TAREFA  = '"+ SuperGetMV('IMD_TRCNFS', .F., '003') +"'"
	cQuery +=   " AND DB_ATIVID  = '"+ SuperGetMV('IMD_ATCNFS', .F., '022') +"'"
	cQuery +=   " AND DB_ORIGEM  = 'SD1' "
	cQuery +=   " AND DB_STATUS IN ('"+ cStatInte +"','"+ cStatAExe +"','"+ cStatProb +"')"
	cQuery +=   " AND (DB_RECHUM = '"+ __cUserID +"'"
	cQuery +=     " OR DB_RECHUM = '"+ cRecHVazio +"')"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery +=   " AND (DB_QTDLID = 0 OR (DB_QTDLID > 0 AND DB_QTDLID <> DB_QUANT))"
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

	TCSetField(cAliasQry,'DB_QUANT' ,'N',TamSx3('DB_QUANT')[1], TamSx3('DB_QUANT')[2])
	TCSetField(cAliasQry,'DB_QTDLID','N',TamSx3('DB_QTDLID')[1],TamSx3('DB_QTDLID')[2])

	While (cAliasQry)->(!Eof())
		If (cAliasQry)->DB_QUANT <> (cAliasQry)->DB_QTDLID
			aAdd(aProduto,{(cAliasQry)->DB_QTDLID,Posicione('SB1',1,xFilial('SB1')+(cAliasQry)->DB_PRODUTO,'SB1->B1_DESC'),(cAliasQry)->DB_PRODUTO})
		EndIf
		(cAliasQry)->( DbSkip() )
	EndDo

	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)

   aHeaders := {"Qtde Conferida",RetTitle("B1_DESC"),RetTitle("DB_PRODUTO")} //Produto|Descrição|Qtde Conferida
   aSizes   := {TamSx3("DB_PRODUTO")[1],30,11}
   VtClearBuffer()
   DLVTCabec("Divergencias",.F.,.F.,.T.)
   VTaBrowse(1,,,,aHeaders,aProduto,aSizes)
   VTKeyBoard(chr(20))
   VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	
RestArea(aAreaAnt)

Return

// Calcula o DV de um EAN13 ou EAN14
Static Function GeraDV( cCB )

	Local _CBDV := AllTrim( cCB )
	Local _nX   := 1
	Local _nSum := 0
	Local _nDV  := 0
	
	For _nX := 1 To Len( _CBDV )
		_nSum += ( Val( SubStr( _CBDV, _nX, 1 ) ) * 3 ) / Iif( Mod( _nX, 2 ) == 0, 1, 3 )
	Next

	While Mod( _nSum + _nDV, 10 ) != 0
		_nDV++
	End

	_CBDV += cValToChar( _nDV )
	
Return( _CBDV )
