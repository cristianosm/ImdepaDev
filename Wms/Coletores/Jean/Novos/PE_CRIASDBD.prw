#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PE_CRIASDBD�Autor  �Microsiga           � Data �  18/07/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION CRIASDBD()

Local _cQuery := ""
Local cDscUM  := ""

Local _cFilADB   := SuperGetMV('IMD_ADBFIL', .F., '05') // Filiais onde dever� ser considerado o tratamento de armaz�ns 
Local _cLocADB   := SuperGetMV('IMD_ADBLOC', .F., '01') // Armaz�m que ser� o padr�o para confer�ncia de recebimento
Local _aAreaSDB  := GetArea()
Local cGrvPri    := ''
Local cPrior     := SuperGetMV('MV_WMSPRIO', .F., '' )
Local cIdAnt     := '' // Jean Rehermann - Solutio IT - 13/12/2017 - Verificar se est� sendo executado novamente (estornado)
Local _nTpEstr   := ''
Local cCodCfgEnd := ''
Local cWmsTpEn   := ''
Local cCodNorma  := ''
Local cEstFis2   := ''
Local cArmz2     := ''
Local _cMesaTmp  := ''
Local _aArSDB1   := {}
Local aNivEndOri := {}

IF SDB->DB_FILIAL == '05'
	//PODEREMOS TRATAR AS FILIAIS DE FORMA DIFERENCIADA SE FOR PRECISO
	IF SDB->DB_SERVIC ='001' .And. SDB->DB_ORIGEM == 'SC9' .And. SDB->DB_ATUEST = 'N'  // Expedicao - 29/11 Jean - Antes apenas verificava o servi�o
		
		//Localiza ultima mesa que recebeu um pedido no dia de hoje
		_cQuery := " SELECT NVL(TAB.DB_ENDDES,'') ULTMESA FROM ( "
		_cQuery += " SELECT DB_ENDDES , R_E_C_N_O_ "
		_cQuery += " FROM "+RetSqlName("SDB")+" SDB "
		_cQuery += " WHERE DB_FILIAL = '"+ SDB->DB_FILIAL +"' "
		_cQuery += " AND DB_SERVIC   = '001' "
		_cQuery += " AND DB_DATA = '"+ DtoS( dDataBase ) +"' "
		_cQuery += " AND D_E_L_E_T_  = ' ' "
		_cQuery += " AND DB_ESTORNO  = ' ' "
		_cQuery += " ORDER BY R_E_C_N_O_ DESC ) TAB   "
		_cQuery += " WHERE TAB.DB_ENDDES LIKE 'MESA%' "
		_cQuery += " AND ROWNUM < 100 "
		_cQuery += " ORDER BY TAB.R_E_C_N_O_ DESC     "
		
		//cQuery := ChangeQuery(_cQuery)
		_cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,_cQuery),_cAliasQry,.F.,.T.)
		
		_cUltMesa := (_cAliasQry)->ULTMESA
		
		(_cAliasQry)->(DbCloseArea())
		
		IF !EMPTY(_cUltMesa)

			// Jean Rehermann - SOlutio IT - 18/10/2018 - Ao inv�s de retornar se existe ou n�o, retorna a pr�pria mesa se existir
			_cMesaTmp := QtdItmPd()

			If !Empty( _cMesaTmp ) // Jean Rehermann - Solutio IT - 16/10/2017 - Avalia se � o mesmo pedido, para jogar na mesma mesa, sen�o joga na pr�xima
				_cProxMesa := _cMesaTmp // Se j� tiver itens para o mesmo pedido, usa a mesma mesa
			Else
				_cProxMesa := SOMA1( ALLTRIM( _cUltMesa ) )
			Endif
		ELSE
			_cProxMesa := 'MESA01'
		ENDIF
		
		_cQuery := " SELECT COUNT(*) NMESA FROM "+RetSqlName("SBE")+" SBE"
		_cQuery += " WHERE SBE.BE_FILIAL = '"+SDB->DB_FILIAL+"' "
		_cQuery += " AND SBE.BE_LOCALIZ = '"+_cProxMesa+"' "
		_cQuery += " AND SBE.D_E_L_E_T_ = ' ' "
		
		//cQuery := ChangeQuery(_cQuery)
		_cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,_cQuery),_cAliasQry,.F.,.T.)
		
		_lOkMesa := (_cAliasQry)->NMESA > 0
		
		(_cAliasQry)->(DbCloseArea())
		
		IF !_lOkMesa
			_cProxMesa := "MESA01"
		ENDIF
		
		IF SDB->DB_TAREFA = '002'  // Apanhe
			
			IF SDB->DB_ATIVID = '015'  //Separar Produto
				SDB->( Reclock("SDB",.F.) )

					SDB->DB_ENDDES  := _cProxMesa

					// Jean Rehermann - Solutio IT - 11/12/2017 - Devido a estorno para altera��es do pedido foi necess�rio tratar em outro local o RH
					// Verifica se existe IDDCF anterior para o mesmo produto/documento/cliente
					_aArSDB1 := SDB->( GetArea() )
					cIdAnt := U_GetIdAnt( { SDB->DB_DOC, SDB->DB_CLIFOR, SDB->DB_LOJA, SDB->DB_PRODUTO, Nil, SDB->DB_IDDCF } ) 
					RestArea( _aArSDB1 )
					
					If !Empty( cIdAnt ) .And. AllTrim( cIdAnt ) != 'VAZIO' // Quando � estorno trato o RH em outro ponto de entrada
						SDB->DB_RECHUM := Replicate("0",6)
					EndIf

				SDB->( MSUNLOCK() )
			ENDIF
			
			// Jean Rehermann - Solutio IT - 27/10/2017 - Associar o mesmo recurso humano para todo o documento
			// Jean Rehermann - Solutio IT - 11/12/2017 - Devido a estorno para altera��es do pedido foi necess�rio tratar em outro local o RH
			If Empty( cIdAnt ) .Or. AllTrim( cIdAnt ) == 'VAZIO' // Quando n�o � estorno j� defino o RH sen�o trato em outro ponto de entrada CRIASDBD
				U_DBRecHum()
			EndIf
	
		ELSEIF SDB->DB_TAREFA = '003' //Conferencia
			
			IF SDB->DB_ATIVID = '022'  // Conferir Mercadoria
				SDB->( Reclock("SDB",.f.) )
					SDB->DB_LOCALIZ := _cProxMesa
					SDB->DB_ENDDES  := "DOCA"
					SDB->DB_RHFUNC  := "00" // Para n�o ser convocado no coletor
				SDB->( MSUNLOCK() )
			ENDIF
			
		ENDIF
		
	ELSEIF SDB->DB_SERVIC = '003' .And. SDB->DB_ORIGEM == 'SD1' .And. SDB->DB_ATUEST = 'N' // Recebimento
		
		IF SDB->DB_TAREFA = '009'  // Conferencia e endere�amento
			
			IF SDB->DB_ATIVID = '042'  //Conferir Produtos paletizados

				// Jean Rehermann - SOLUTIO IT - 26/12/2017 - Tratamento para endere�os do tipo pulm�o compartilhados
				_nTpEstr := DLTipoEnd(SDB->DB_ESTDES)

				If _nTpEstr == 1 .And. !IsInCallStack("EndParcial") // 1 = Pulm�o - 2 = Picking - Somente reavalia se n�o for cria��o de SDB via endere�amento parcial

					// Defino o armaz�m espelho (se tiver saldo no pulm�o em outro armaz�m posso usar esse mesmo endere�o)
					cArmz2 := Iif( SDB->DB_LOCAL == '02', '01', '02' )
					
					// Aqui eu busco a sequencia de abastecimento para os armazens 01 e 02 no pulm�o
					DC3->( DbSetOrder(2) ) // DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_TPESTR
					DC3->( DbSeek( xFilial('DC3') + SDB->DB_PRODUTO + cArmz2 ) )
					
					While !DC3->( Eof() ) .And. xFilial('DC3') + SDB->DB_PRODUTO + cArmz2 == DC3->DC3_FILIAL + DC3->DC3_CODPRO + DC3->DC3_LOCAL
						If DLTipoEnd( DC3->DC3_TPESTR ) == 1 // Quero apenas a estrutura de pulm�o do local espelho
							cEstFis2 := DC3->DC3_TPESTR
							Exit
						EndIf
						DC3->( dbSkip() )
					End
					
					DC3->( DbSetOrder(2) ) // DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_TPESTR
					DC3->( DbSeek( xFilial('DC3') + SDB->DB_PRODUTO + SDB->DB_LOCAL + SDB->DB_ESTDES ) )
					cCodNorma := DC3->DC3_CODNOR
					cWmsTpEn  := DC3->DC3_TIPEND
				
					_cEndDes := ImdEndEstr(SDB->DB_PRODUTO,SDB->DB_LOCAL,SDB->DB_ESTDES,SDB->DB_QUANT,cWmsTpEn,.F.,.F.,.T.,"000001",cCodNorma,.T.,'1',aNivEndOri,cCodCfgEnd,.T.,cEstFis2,cArmz2)
					
					If !Empty( _cEndDes ) .And. SDB->DB_ENDDES <> _cEndDes
						Reclock("SDB",.f.)
							SDB->DB_ENDDES  := _cEndDes
						MSUNLOCK()
					EndIf
				
				EndIf
/*				
				//Localizar Picking Fixo
				DbSelectArea("SBE")
				DbSetOrder(10) //BE_FILIAL+BE_CODPRO+BE_LOCAL+BE_LOCALIZ
				DbSeek(xFilial("SBE")+SDB->DB_PRODUTO+SDB->DB_LOCAL)
				
				_cEndDes := ""
				_cEstDes := ""
				
				Do While !eof() .AND. xFilial("SBE")+SDB->DB_PRODUTO+SDB->DB_LOCAL == SBE->(BE_FILIAL+BE_CODPRO+BE_LOCAL)
					
					_nTpEstr   := DLTipoEnd(SBE->BE_ESTFIS)
					IF _nTpEstr == 2 // Picking
						_nQtdNorma := DLQtdNorma(SDB->DB_PRODUTO,SDB->DB_LOCAL,SBE->BE_ESTFIS,@cDscUM,.F.)
						_nSaldoSBF := WmsSaldoSBF(SDB->DB_LOCAL,SBE->BE_LOCALIZ,SDB->DB_PRODUTO,,,,.T.,.T.,.T.,.F.,'2',.T.)
						_nSldSBFAt := WmsSaldoSBF(SDB->DB_LOCAL,SBE->BE_LOCALIZ,SDB->DB_PRODUTO,,,,.T.,.F.,.T.,.F.,'2',.T.)
						_nDispo    := _nQtdNorma - _nSaldoSBF
						
						IF _nDispo > 0 .Or. ( _nDispo == 0 .And. ( _nSldSBFAt + SDB->DB_QUANT ) == _nSaldoSBF )
							_cEndDes := SBE->BE_LOCALIZ
							_cEstDes := SBE->BE_ESTFIS
							Exit
					    Else
					    
						ENDIF
					ENDIF
					DbSelectArea("SBE")
					DbSkip()
				Enddo
				IF empty(_cEndDes)
					//Nao achou endere�o de picking procura outra estrutura com endere�o fixo
					DbSelectArea("SBE")
					DbSetOrder(10) //BE_FILIAL+BE_CODPRO+BE_LOCAL+BE_LOCALIZ
					DbSeek(xFilial("SBE")+SDB->DB_PRODUTO+SDB->DB_LOCAL)
					_cEndDes := ""
					_cEstDes := ""
					
					Do While !eof() .AND. xFilial("SBE")+SDB->DB_PRODUTO+SDB->DB_LOCAL == SBE->(BE_FILIAL+BE_CODPRO+BE_LOCAL)
						
						_nTpEstr   := DLTipoEnd(SBE->BE_ESTFIS)
						IF _nTpEstr <> 2 // Diferente de Picking
							_nQtdNorma := DLQtdNorma(SDB->DB_PRODUTO,SDB->DB_LOCAL,SBE->BE_ESTFIS,@cDscUM,.F.)
							_nSaldoSBF := WmsSaldoSBF(SDB->DB_LOCAL,SBE->BE_LOCALIZ,SDB->DB_PRODUTO,,,,.T.,.T.,.T.,.F.,'2',.T.)
							_nSldSBFAt := WmsSaldoSBF(SDB->DB_LOCAL,SBE->BE_LOCALIZ,SDB->DB_PRODUTO,,,,.T.,.F.,.T.,.F.,'2',.T.)
							_nDispo    := _nQtdNorma - _nSaldoSBF
							
							IF _nDispo > 0 .Or. ( _nDispo == 0 .And. ( _nSldSBFAt + SDB->DB_QUANT ) == _nSaldoSBF )
								_cEndDes := SBE->BE_LOCALIZ
								_cEstDes := SBE->BE_ESTFIS
								Exit
							ENDIF
						ENDIF
						DbSelectArea("SBE")
						DbSkip()
					Enddo
					
				ENDIF
				
				IF empty(_cEndDes)
					//Nao achou endere�o endere�o fixo... procura algum endere�o no estoque com este produto
					DbSelectArea("SBF")
					DbSetOrder(5)   //BF_FILIAL+BF_PRODUTO+BF_ESTFIS+BF_LOCALIZ
					DbSeek( xFilial("SBF")+SDB->DB_PRODUTO)
					_cEndDes := ""
					_cEstDes := ""
					
					Do While  !EOF() .AND.  xFilial("SBF")+SDB->DB_PRODUTO == SBF->(BF_FILIAL+BF_PRODUTO)
						
						//+BF_ESTFIS+BF_LOCALIZ
						IF SBF->BF_LOCAL == SDB->DB_LOCAL
							//_nTpEstr   := DLTipoEnd(SBF->BF_ESTFIS)
							// IF _nTpEstr <> 2 // Diferente de Picking
							_nQtdNorma := DLQtdNorma(SBF->BF_PRODUTO,SBF->BF_LOCAL,SBF->BF_ESTFIS,@cDscUM,.F.)
							_nSaldoSBF := WmsSaldoSBF(SBF->BF_LOCAL,SBF->BF_LOCALIZ,SBF->BF_PRODUTO,,,,.T.,.T.,.T.,.F.,'2',.T.)
							_nSldSBFAt := WmsSaldoSBF(SDB->DB_LOCAL,SBE->BE_LOCALIZ,SDB->DB_PRODUTO,,,,.T.,.F.,.T.,.F.,'2',.T.)
							_nDispo    := _nQtdNorma - _nSaldoSBF
							
							IF _nDispo > 0 .Or. ( _nDispo == 0 .And. ( _nSldSBFAt + SDB->DB_QUANT ) == _nSaldoSBF )
								_cEndDes := SBF->BF_LOCALIZ
								_cEstDes := SBF->BF_ESTFIS
								EXIT
							ENDIF
						ENDIF
						DbSelectArea("SBF")
						DbSkip()
					Enddo
					
				ENDIF
				// Procura um endere�o de Pulm�o liberado.
				IF empty(_cEndDes)
				
					DbSelectArea("SBE")
					DbSetOrder(1) //BE_FILIAL+BE_LOCAL+BE_LOCALIZ
					DbSeek(xFilial("SBE")+SDB->DB_LOCAL)
					_cEndDes := ""
					_cEstDes := ""

					Do While !eof() .AND. xFilial("SBE")+SDB->DB_LOCAL == SBE->(BE_FILIAL+BE_LOCAL)
						
						_nTpEstr   := DLTipoEnd(SBE->BE_ESTFIS)
						IF _nTpEstr <> 2 // Diferente de Picking
							_nQtdNorma := DLQtdNorma(SDB->DB_PRODUTO,SDB->DB_LOCAL,SBE->BE_ESTFIS,@cDscUM,.F.)
							_nSaldoSBF := WmsSaldoSBF(SDB->DB_LOCAL,SBE->BE_LOCALIZ,SDB->DB_PRODUTO,,,,.T.,.T.,.T.,.F.,'2',.T.)
							_nSldSBFAt := WmsSaldoSBF(SDB->DB_LOCAL,SBE->BE_LOCALIZ,SDB->DB_PRODUTO,,,,.T.,.F.,.T.,.F.,'2',.T.)
							_nDispo    := _nQtdNorma - _nSaldoSBF
							
							IF _nDispo > 0 .Or. ( _nDispo == 0 .And. ( _nSldSBFAt + SDB->DB_QUANT ) == _nSaldoSBF )
								_cEndDes := SBE->BE_LOCALIZ
								_cEstDes := SBE->BE_ESTFIS
								Exit
							ENDIF
						ENDIF
						DbSelectArea("SBE")
						DbSkip()
					Enddo
					
				ENDIF
				
				IF !empty(_cEndDes)
					//Se n�o achou pela regra deixa o endere�o existente
					Reclock("SDB",.f.)
						SDB->DB_ENDDES  := _cEndDes
						SDB->DB_ESTDES  := _cEstDes
					MSUNLOCK()
				ENDIF
*/			
				// Tratamento para enderecamento parcial (quando cria novo SDB com saldo a endere�ar)
				If IsInCallStack("EndParcial") .And. SDB->( FieldPos("DB_LOCEND") ) > 0 .And. Empty( SDB->DB_LOCEND )
					Reclock("SDB",.f.)
						SDB->DB_LOCEND := SDBLocal() // Local original no SD1
						SDB->DB_LOCAL  := _cLocADB   // Local padr�o definido por par�metro
					MSUNLOCK()
			    EndIf
			
			ENDIF
			
		ENDIF
		
	ELSEIF  SDB->DB_SERVIC ='005'  // Armazengem

		// Jean Rehermann - Solutio IT - 29/09/2017 - Altera a prioridade para que atividade seja considerada a mais priorit�ria
		IF SDB->DB_TAREFA = '001'  // Reabastecimento
			IF SDB->DB_ATIVID = '009'  // Reabastecimento de picking
				Reclock( "SDB", .F. )
					SDB->DB_PRIORI := "AA"+ SDB->DB_DOC
					SDB->DB_RECHUM := GetRecHum() // Seleciona o recurso humano pela disponibilidade
				SDB->( MsUnLock() )
			ENDIF
		ENDIF
		
	ENDIF
	
ENDIF

// Se existir o campo da personaliza��o e estiver logado na filial que trata a regra e estiver executando o servi�o
If SDB->( FieldPos("DB_LOCEND") ) > 0 .And. cFilAnt $ _cFilADB .And. IsInCallStack("DLGA150")

	// Servi�o de Recebimento, Tarefa de confer�ncia e endere�amento e atividade de confer�ncia e endere�amento
	If SDB->DB_SERVIC ='003' .And. ( ( SDB->DB_TAREFA == '009' .And. SDB->DB_ATIVID == '042' ) .Or. ( SDB->DB_TAREFA == '003' .And. SDB->DB_ATIVID == '022' ) )
	
		Reclock( "SDB", .F. )
			SDB->DB_LOCEND := SDB->DB_LOCAL
			SDB->DB_LOCAL  := _cLocADB
		
			If Empty( SDB->DB_SEQPRI )
				SDB->DB_SEQPRI := WMSBuscaSeqPri( SDB->( Recno() ) )
			EndIf

			If Empty( SDB->DB_PRIORI ) .Or. AllTrim( SDB->DB_PRIORI ) == 'ZZ'
				cGrvPri := "ZZ" + IIf( Empty( cPrior ), '', &cPrior ) + StrZero( Val( SDB->DB_ITEM ), 2 )
				SDB->DB_PRIORI := cGrvPri
			EndIf
		
		SDB->( MsUnLock() )
		
	EndIf
	
EndIf

RestArea( _aAreaSDB )

RETURN(.T.)

// Fun��o busca o local padr�o no SD1 e grava no campo DB_LOCEND
Static Function SDBLocal()

	Local _cLocal := ""
	Local _cQuery := ""
	Local _cAlias := ""
	Local _aArea  := GetArea()
	
	_cQuery := "SELECT D1_LOCAL "
	_cQuery += " FROM "+ RetSqlName("SD1")
	_cQuery += " WHERE D1_FILIAL  = '"+ DB_FILIAL  +"'"
	_cQuery += "   AND D1_ITEM    = '"+ DB_ITEM    +"' "
	_cQuery += "   AND D1_COD     = '"+ DB_PRODUTO +"' "
	_cQuery += "   AND D1_DOC     = '"+ DB_DOC     +"' "
	_cQuery += "   AND D1_SERIE   = '"+ DB_SERIE   +"' "
	_cQuery += "   AND D1_FORNECE = '"+ DB_CLIFOR  +"' "
	_cQuery += "   AND D1_LOJA    = '"+ DB_LOJA    +"' "
	_cQuery += "   AND D_E_L_E_T_ = ' '"
	
	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	
	If !(_cAlias)->( Eof() )
		_cLocal := (_cAlias)->D1_LOCAL
	EndIf
	
	(_cAlias)->( dbCloseArea() )
	
	RestArea( _aArea )
	
Return( _cLocal )

// Fun��o para verificar se j� existe algum item referente ao mesmo documento, para controle da MESA de separa��o
Static Function QtdItmPd()

	Local _nQtReg := 0
	Local _cQuery := ""
	Local _cAlias := ""
	Local _cMesaX := ""
	Local _aArea  := GetArea()

	_cQuery := "SELECT COUNT(*) QTDREG "
	_cQuery += " FROM "+ RetSqlName("SDB")
	_cQuery += " WHERE DB_FILIAL  = '"+ SDB->DB_FILIAL  +"'"
	_cQuery += "   AND DB_ORIGEM  = '"+ SDB->DB_ORIGEM  +"' "
	_cQuery += "   AND DB_SERVIC  = '"+ SDB->DB_SERVIC  +"'"
	_cQuery += "   AND DB_DOC     = '"+ SDB->DB_DOC     +"' "
	_cQuery += "   AND DB_CLIFOR  = '"+ SDB->DB_CLIFOR  +"' "
	_cQuery += "   AND DB_LOJA    = '"+ SDB->DB_LOJA    +"' "
	_cQuery += "   AND R_E_C_N_O_ <> '"+ cValToChar( SDB->( Recno() ) ) +"' "
	_cQuery += "   AND DB_ENDDES LIKE 'MESA%' "
	_cQuery += "   AND D_E_L_E_T_ = ' '"

	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	_nQtReg := (_cAlias)->QTDREG
	(_cAlias)->( dbCloseArea() )

	If _nQtReg > 0
	
		_cQuery := "SELECT DISTINCT(DB_ENDDES) MESA "
		_cQuery += " FROM "+ RetSqlName("SDB")
		_cQuery += " WHERE DB_FILIAL  = '"+ SDB->DB_FILIAL  +"'"
		_cQuery += "   AND DB_ORIGEM  = '"+ SDB->DB_ORIGEM  +"' "
		_cQuery += "   AND DB_SERVIC  = '"+ SDB->DB_SERVIC  +"'"
		_cQuery += "   AND DB_DOC     = '"+ SDB->DB_DOC     +"' "
		_cQuery += "   AND DB_CLIFOR  = '"+ SDB->DB_CLIFOR  +"' "
		_cQuery += "   AND DB_LOJA    = '"+ SDB->DB_LOJA    +"' "
		_cQuery += "   AND R_E_C_N_O_ <> '"+ cValToChar( SDB->( Recno() ) ) +"' "
		_cQuery += "   AND DB_ENDDES LIKE 'MESA%' "
		_cQuery += "   AND D_E_L_E_T_ = ' '"
	
		TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
		(_cAlias)->( dbGoTop() )
		If !(_cAlias)->( Eof() )
			_cMesaX := (_cAlias)->MESA
		EndIf
		(_cAlias)->( dbCloseArea() )

	EndIf

	RestArea( _aArea )

Return( _cMesaX )

// Jean Rehermann - Solutio IT - 27/10/2017 - Associar o mesmo recurso humano para todo o documento no apanhe
User Function DBRecHum(_lLock,_lForca)

	Local cRecHum := ""
	Local _cQuery := ""
	Local _cAlias := ""
	Local _aArea  := GetArea()

	Default _lLock  := .T.
	Default _lForca := .F.
	
	If Empty( SDB->DB_RECHUM ) .Or. SDB->DB_RECHUM == "000000" .Or. _lForca
		
		_cQuery := "SELECT DB_RECHUM "
		_cQuery += " FROM "+ RetSqlName("SDB")
		_cQuery += " WHERE DB_FILIAL  = '"+ xFilial("SDB") +"'"
		_cQuery += "   AND DB_DOC     = '"+ SDB->DB_DOC     +"'"
		_cQuery += "   AND DB_CLIFOR  = '"+ SDB->DB_CLIFOR  +"'"
		_cQuery += "   AND DB_LOJA    = '"+ SDB->DB_LOJA    +"'"
		_cQuery += "   AND DB_SERVIC  = '"+ SDB->DB_SERVIC  +"'"
		_cQuery += "   AND DB_ATIVID  = '"+ SDB->DB_ATIVID  +"'"
		_cQuery += "   AND DB_ORIGEM  = 'SC9'"
		_cQuery += "   AND DB_ESTORNO = ' '"
		_cQuery += "   AND D_E_L_E_T_ = ' '"
		_cQuery += "   AND DB_RECHUM <> '000000'"
		_cQuery += "   AND DB_RECHUM <> '      '"

		TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
		
		If !(_cAlias)->( Eof() )
			cRecHum := (_cAlias)->DB_RECHUM
		EndIf
		(_cAlias)->( dbCloseArea() )
	
		If Empty( cRecHum ) .Or. cRecHum == "000000"
			cRecHum := GetRecHum() // Busca o recurso humano para a atividade
		EndIf

		If _lLock
			Reclock( "SDB", .F. )
		EndIf
			SDB->DB_RECHUM := cRecHum
		If _lLock
			SDB->( MsUnLock() )
		EndIf
		
		RestArea( _aArea )

	EndIf
	
Return

// Busca o recurso humano para a atividade
Static Function GetRecHum()

	Local _cCodRH := ""
	Local _cQuery := ""
	Local _cAlias := ""
	Local _aFuncs := {}
	Local _aArea  := GetArea()

	_cQuery := "SELECT DCI_CODFUN "
	_cQuery += " FROM "+ RetSqlName("DCI") +" DCI, "+ RetSqlName("DCD") +" DCD "
	_cQuery += " WHERE DCI_FILIAL = '"+ xFilial("DCI") +"' "
	_cQuery += "   AND DCI_FUNCAO = '"+ SDB->DB_RHFUNC +"' "
	_cQuery += "   AND DCI_FILIAL = DCD_FILIAL "
	_cQuery += "   AND DCI_CODFUN = DCD_CODFUN "
	_cQuery += "   AND DCD_STATUS <> '3' "
	_cQuery += "   AND DCD.D_E_L_E_T_ = ' ' "
	_cQuery += "   AND DCI.D_E_L_E_T_ = ' ' "
	_cQuery += " ORDER BY DCI_CODFUN DESC"
	
	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	
	While !(_cAlias)->( Eof() )
		aAdd( _aFuncs,  { (_cAlias)->DCI_CODFUN, 0 } )
		(_cAlias)->( dbSkip() )
	End
	(_cAlias)->( dbCloseArea() )
	
	If !Empty( _aFuncs )
	
		For _nX := 1 To Len( _aFuncs )
		
			_cQuery := "SELECT COUNT(*) TOTAL "
			_cQuery += " FROM "+ RetSqlName("SDB")
			_cQuery += " WHERE DB_FILIAL  = '"+ xFilial("SDB") +"' "
			_cQuery += "  AND DB_RECHUM  = '"+ _aFuncs[ _nX, 1 ] +"'"
			_cQuery += "  AND DB_ESTORNO = ' ' "
			_cQuery += "  AND D_E_L_E_T_ = ' ' "
			_cQuery += "  AND ( ( DB_ORIGEM  = 'SC9' "
			_cQuery += "  AND DB_SERVIC  = '001' "
			_cQuery += "  AND DB_TAREFA  = '002' "
			_cQuery += "  AND DB_ATIVID  = '015' ) "
			_cQuery += "  OR ( DB_ORIGEM  = 'DCF' "
			_cQuery += "  AND DB_SERVIC  = '005' "
			_cQuery += "  AND DB_TAREFA  = '001' "
			_cQuery += "  AND DB_ATIVID  = '009' ) ) "
			_cQuery += "  AND DB_STATUS  IN ('4','3','-') "
	
			TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	
			_aFuncs[ _nX, 2 ] := (_cAlias)->TOTAL
			(_cAlias)->( dbCloseArea() )
		
		Next

		aSort( _aFuncs,,, { |x, y| x[ 2 ] < y[ 2 ] } )
		_cCodRH := _aFuncs[ 1, 1 ]
		
	EndIf
	
	RestArea( _aArea )
	
Return( _cCodRH )

// Jean Rehermann - Solutio IT - 26/12/2016 - Utilizo a fun��o padr�o para buscar endere�o ideal, sem validar as regras de compartilhamento de
// endere�o para as estruturas de pulm�o
Static Function ImdEndEstr(cProduto,cLocDest,cEstDest,nQuant,cWmsTpEn,lOnlyPkg,lPriorSA,lZonaPrd,cZonaPrd,cCodNorma,lRadioF,cStatRF,aNivEndOri,cCodCfgEnd,lExibeMsg,cEstFis2,cArmz2)

	Local aParam150 := {Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,'003','009',Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,'DOCA','000039'}
	Local aAreaAnt   := GetArea()
	Local lRet       := .T.
	Local cAliasSBE  := "SBE"
	Local aEnderecos := {}
	Local nTipoPerc  := 0
	Local nCapEstru  := 0
	Local nNormaEst  := 0
	Local nCapEnder  := 0
	Local nSaldoSBF  := 0
	Local nSaldoRF   := 0
	Local nSaldoEnd  := 0
	Local nSaldoQry  := 0
	Local cEndDest   := ""
	Local cOrdSeq    := "00"
	Local cOrdPrd    := "00"
	Local cOrdSld    := "00"
	Local cOrdMov    := "00"
	Local nX         := 0
	Local nTipoEst   := DLTipoEnd(cEstDest)        // 1 = Pulmao
	Local cTipoServ  := WmsTipServ(aParam150[09])  //-- Servico
	Local cTarefa    := aParam150[10]              //-- Tarefa
	Local cEndOrig   := aParam150[20]              //-- Endere�o de origem (DOCA)
	Local cEstOrig   := aParam150[21]              //-- Estrutura de origem (000039) - DOCA
	Local aExcecoesO := {} //-- Excecoes referentes ao Endereco ORIGEM
	Local aExcecoesD := {} //-- Excecoes referentes ao Endereco DESTINO

	//-- Carregas as exce��es das atividades, somente da origem
	DLExcecoes(cTipoServ,cLocDest,cEstOrig,cEndOrig,cLocDest,cEstDest,cEndDest,aExcecoesO,Nil)

	//Calcula a norma somente uma vez para a estrtura fisica, pois todos os endere�os 
	//devem posuir a mesma norma, exceto quando possui percentual de ocupa��o
	nCapEstru := DLQtdNorma(cProduto, cLocDest, cEstDest)
	nNormaEst := DLQtdNorma(cProduto, cLocDest, cEstDest, /*cDesUni*/, .F.) //Considerar somente a norma
	
	cAliasSBE = QryEndEst(cProduto,cLocDest,cEstDest,'','',cWmsTpEn,lPriorSA,lZonaPrd,cZonaPrd,lRadioF,cEstFis2,cArmz2)

	Do While (cAliasSBE)->(!Eof())
		// Desconsidera endere�os que possuem percentual de ocupa��o para um produto
		// diferente do que est� sendo endere�ado
		If (cAliasSBE)->DCP_PEROCP == 3
			(cAliasSBE)->(DbSkip())
			Loop
		EndIf
		
		//Adiciona o endere�o ao array de endere�os possiveis de serem ocupados
		AAdd(aEnderecos,{;
			PadR((cAliasSBE)->ZON_ORDEM,TamSX3("DCH_ORDEM")[1],'0'),; //Ordem Zona
			StrZero((cAliasSBE)->PRD_ORDEM,2,0),; //Ordem Produto
			StrZero((cAliasSBE)->SLD_ORDEM,2,0),; //Ordem Saldo -- Endere�o Ocupado
			StrZero((cAliasSBE)->MOV_ORDEM,2,0),; //Ordem Movimenta��o -- Endere�o Ocupado
			0,;  //Ordem Distancia Total
			(cAliasSBE)->RECNOSBE,;   //Recno SBE
			(cAliasSBE)->BE_LOCALIZ,; //C�digo do Endere�o
			(cAliasSBE)->SLD_SALDO,;  //Saldo no Endere�o
			(cAliasSBE)->MOV_SALDO,;  //Saldo RF do Endere�o
			(cAliasSBE)->DCP_PEROCP;  //Indicador de percentual de ocupa��o -> 0-N�o compartilha;1-Produto;2-Geral;
		})
		
		(cAliasSBE)->(DbSkip())
	EndDo
	(cAliasSBE)->(DbCloseArea())
	
	//Aqui deve processar os endere�os encontrados
	If Len(aEnderecos) > 0

		//Ordena por - Ordem Zona + Ordem Produto + Endere�o Ocupado + Distancia Total + C�digo Endere�o
		ASort(aEnderecos,,, {|x,y| x[1]+x[2]+x[3]+StrZero(x[5],6)+x[7] < y[1]+y[2]+y[3]+StrZero(y[5],6)+y[7]})

		//Deve validar o endere�o e gerar os processos de movimenta��o para o endere�amento
		nX := 1
		While nX <= Len(aEnderecos) .And. nQuant > 0
	
			cOrdSeq    := aEnderecos[nX,01]
			cOrdPrd    := aEnderecos[nX,02]
			cOrdSld    := aEnderecos[nX,03]
			cOrdMov    := aEnderecos[nX,04]
			cEndDest   := aEnderecos[nX,07]
			nTipoPerc  := aEnderecos[nX,10]
			nSaldoSBF  := aEnderecos[nX,08]
			nSaldoRF   := aEnderecos[nX,09]
			nSaldoEnd  := 0
			nSaldoQry  := nSaldoSBF + nSaldoRF
			
			// Caso n�o encontre nenhum pulm�o com saldo (nem mesmo compartilhado), for�o retornar em branco pois assim n�o regrava o endere�o
			// destino e o endere�o escolhido pelo sistema � o primeiro vazio, j� est� correto.
			If nSaldoQry == 0
				cEndDest := ''
				nQuant := 0
				Loop
			EndIf
			
			//Se n�o utiliza percentual de ocupa��o utiliza a capacidade da estrutura, sen�o calcula a do endere�o
			nCapEnder  := Iif(nTipoPerc==0,nCapEstru,DLQtdNorma(cProduto, cLocDest, cEstDest,, .T., cEndDest)) //Considerar a qtd pelo nr de unitizadores
			
			If QtdComp(nCapEnder) <= 0
				nX++
				Loop
			EndIf
	
			//Se procura s� endere�os vazios, n�o precisa consultar o saldo, pois j� foi descartado no SELECT
			If cWmsTpEn != "1"
				//Se o saldo da consulta j� for maior que a capacidade do endere�o, nem refaz a consulta de saldo do endere�o
				If QtdComp(nSaldoQry) >= QtdComp(nCapEnder)
					nX++
					Loop
				EndIf
				//Se possui percentual de ocupa��o deve consultar o saldo somente do produto
				//Caso contr�rio deve consultar o saldo do endere�o por completo
				nSaldoSBF := WmsSaldoSBF(cLocDest,cEndDest,Iif(nTipoPerc!=0,cProduto,Nil),,,,.F.,.F.,.F.,.F.,'2',.F.)
				nSaldoRF  := WmsSaldoSBF(cLocDest,cEndDest,Iif(nTipoPerc!=0,cProduto,Nil),,,,.T.,.T.,.T.,.F.,'3',.T.)
				nSaldoEnd := nSaldoSBF + nSaldoRF

				//Se a quantidade de saldo do endere�o, for diferente da quantidade retornada
				//da query indica que o endere�o possui saldo relativo a algum outro produto (endere�o compartilhado)
				If QtdComp(nSaldoEnd) != QtdComp(nSaldoQry)
					// Verifico apenas o saldo do produto para saber se tem capacidade
					// IMD_VCEPCS - Se valida a capacidade do endere�o pulm�o compartilhado (saldo do produto apenas)
					If QtdComp(nQuant) + QtdComp(nSaldoQry) > QtdComp(nCapEnder) .And. SuperGetMV('IMD_VCEPCS', .F., .F.)
						nX++
						Loop
					EndIf
                Else
					// Verifica se o endere�o possui capacidade, para comportar o produto
					// IMD_VCEPNC - Valida capacidade do endere�o pulm�o n�o compartilhado (saldo de todo o endere�o)
					If QtdComp(nSaldoEnd) >= QtdComp(nCapEnder) .And. SuperGetMV('IMD_VCEPNC', .F., .F.)
						nX++
						Loop
					EndIf
                EndIf
				
				nQuant := 0

			EndIf

			nX++
		EndDo

	EndIf

	RestArea(aAreaAnt)
	
Return cEndDest

// Jean Rehermann - Solutio IT - 26/12/2017 - Query de ranqueamento de endere�os 
Static Function QryEndEst(cProduto,cLocDest,cEstDest,cLoteCtl,cNumLote,cWmsTpEn,lPriorSA,lZonaPrd,cZonaPrd,lRadioF,cEstFis2,cArmz2)

	Local cAliasSBE := "SBE"
	Local aTamSX3   := {}
	Local nTipoEst  := DLTipoEnd(cEstDest)

	cZonaPrd := PadR(cZonaPrd,TamSX3("DCH_CODZON")[1])
	cQuery := "SELECT"
	//Se considera primeiro a zona de armazenagem do produto
	If lPriorSA
		If lZonaPrd
			cQuery += " '00' ZON_ORDEM,"
		Else
			cQuery += " ZON.ZON_ORDEM,"
		EndIf
	Else
		cQuery += " ZON.ZON_ORDEM,"
	EndIf
	//Se foi informado o produto no endere�o ele tem prioridade
	cQuery += " CASE WHEN SBE.BE_CODPRO = '"+Space(TamSx3("BE_CODPRO")[1])+"' THEN 2 ELSE 1 END PRD_ORDEM,"
	//Este campos s�o para compatibilidade com outros tipos de endere�amento
	If cWmsTpEn == "1"
		cQuery += " 99 SLD_ORDEM,"
		cQuery += " 99 MOV_ORDEM,"
		cQuery += " 0 SLD_SALDO,"
		cQuery += " 0 MOV_SALDO,"
	Else
		cQuery += " CASE WHEN SLD_ORDEM IS NOT NULL THEN SLD_ORDEM ELSE 99 END SLD_ORDEM,"
		If lRadioF
			cQuery += " CASE WHEN MOV_ENDERE IS NOT NULL THEN 1 ELSE 99 END MOV_ORDEM,"
		Else
			cQuery += " 99 MOV_ORDEM,"
		EndIf
		cQuery += " CASE WHEN SLD.SLD_SALDO IS NULL THEN 0 ELSE SLD.SLD_SALDO END SLD_SALDO,"
		If lRadioF
			cQuery += " CASE WHEN MOV.MOV_SALDO IS NULL THEN 0 ELSE MOV.MOV_SALDO END MOV_SALDO,"
		Else
			cQuery += " 0 MOV_SALDO,"
		EndIf
	EndIf

	//Carregando as informa��es de endere�o compartilhado via percentual de ocupa��o
	cQuery += " CASE WHEN DCP.DCP_CODPRO IS NULL THEN 0" 
	cQuery +=      " WHEN DCP.DCP_CODPRO = '"+cProduto+"' THEN 1"
	cQuery +=      " WHEN DCP.DCP_CODPRO = '"+Space(TamSx3("DCP_CODPRO")[1])+"' THEN 2"
	cQuery +=      " ELSE 3" 
	cQuery += " END DCP_PEROCP,"

	//Pegando as informa��es do endere�o
	cQuery += " SBE.BE_LOCALIZ, SBE.BE_CODCFG, SBE.R_E_C_N_O_ RECNOSBE"
	cQuery += " FROM "+RetSqlName("SBE")+" SBE"

	//Verifica se j� considera as zonas de armazenagem na query
	If !lPriorSA .Or. (lPriorSA .And. !lZonaPrd)
		cQuery += " INNER JOIN ("

		//Se prioriza a sequencia, vai filtar direto, sen�o junta na query
		If !lPriorSA

			//N�o utiliza do cadastro por que existe um PE que pode alterar, usa a vari�vel
			cQuery += "SELECT '00' ZON_ORDEM, '"+cZonaPrd+"' ZON_CODZON"
			cQuery += "  FROM "+RetSqlName("SB5")
			cQuery += " WHERE B5_FILIAL = '"+xFilial("SB5")+"'"
			cQuery += "   AND B5_COD    = '"+cProduto+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			cQuery += " UNION ALL "

		EndIf

		cQuery += "SELECT DCH_ORDEM ZON_ORDEM, DCH_CODZON ZON_CODZON"
		cQuery += "  FROM "+RetSqlName("DCH")
		cQuery += " WHERE DCH_FILIAL = '"+xFilial("DCH")+"'"
		cQuery += "   AND DCH_CODPRO = '"+cProduto+"'"
		cQuery += "   AND DCH_CODZON <> '"+cZonaPrd+"'"
		cQuery += "   AND D_E_L_E_T_ = ' ') ZON"
		cQuery += " ON ZON.ZON_CODZON = SBE.BE_CODZON"

	EndIf

	//Carrega as informa��es se o endere�o possui percentual de ocupa��o
	cQuery += " LEFT JOIN "+RetSqlName("DCP")+" DCP"
	cQuery +=   " ON DCP.DCP_FILIAL = '"+xFilial("DCP")+"'"
	cQuery +=  " AND DCP.DCP_LOCAL  = SBE.BE_LOCAL"
	cQuery +=  " AND DCP.DCP_ENDERE = SBE.BE_LOCALIZ"
	cQuery +=  " AND DCP.DCP_ESTFIS = SBE.BE_ESTFIS"
	cQuery +=  " AND DCP.D_E_L_E_T_ = ' ' "

	//Carrega os saldos e movimenta��es pendentes para este produto para o endere�o
	If cWmsTpEn $ "2|3|4"

		//Carregando saldo do endere�o para o produto e/ou lote
		cQuery += "  LEFT JOIN ("

		//Se compartilha endere�o deve considerar o saldo do produto e de outros produtos
		If cWmsTpEn == "4"
			cQuery += "SELECT CASE SUM(SLD_ORDEM) WHEN 1 THEN 1 WHEN 4 THEN 2 ELSE 3 END SLD_ORDEM, SLD_LOCAL, SLD_ENDERE, SUM(SLD_SALDO) SLD_SALDO"
			cQuery += " FROM ("
		EndIf

		cQuery += "SELECT 1 SLD_ORDEM, BF_LOCAL SLD_LOCAL, BF_LOCALIZ SLD_ENDERE, SUM(BF_QUANT) SLD_SALDO"
		cQuery += "  FROM "+RetSqlName("SBF")
		cQuery += " WHERE BF_FILIAL  = '"+xFilial("SBF")+"'"
		cQuery += "   AND BF_PRODUTO = '"+cProduto+"'"

		// Tratamento para os dois armaz�ns e estruturas de pulm�o
		If !Empty( cArmz2 ) .And. !Empty( cEstFis2 )
			cQuery += " AND ( ( BF_LOCAL = '"+cLocDest+"' AND BF_ESTFIS = '"+cEstDest+"' ) OR ( BF_LOCAL = '"+cArmz2+"' AND BF_ESTFIS = '"+cEstFis2+"' ) )"
		Else
			cQuery += " AND BF_LOCAL = '"+cLocDest+"' AND BF_ESTFIS = '"+cEstDest+"'"
		EndIf
		
		If (cWmsTpEn == "3" .And. nTipoEst != 2)
			cQuery += " AND BF_LOTECTL = '"+cLoteCtl+"'"
			cQuery += " AND BF_NUMLOTE = '"+cNumLote+"'"
		EndIf

		cQuery += "   AND BF_QUANT > 0"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY BF_LOCAL, BF_LOCALIZ"

		//Se compartilha endere�o deve considerar o saldo de outros produtos
		If cWmsTpEn == "4"
			cQuery += " UNION ALL "
			cQuery += "SELECT 3 SLD_ORDEM, BF_LOCAL SLD_LOCAL, BF_LOCALIZ SLD_ENDERE, 0 SLD_SALDO"
			cQuery += "  FROM "+RetSqlName("SBF")+" SBF, "+RetSqlName("SBE")+" SBE"
			cQuery += " WHERE BF_FILIAL  = '"+xFilial("SBF")+"'"
			cQuery +=   " AND BF_LOCAL   = '"+cLocDest+"'"
			cQuery +=   " AND BF_PRODUTO <> '"+cProduto+"'"
			cQuery +=   " AND BF_ESTFIS  = '"+cEstDest+"'"
			cQuery +=   " AND BF_QUANT > 0"
			cQuery +=   " AND SBF.D_E_L_E_T_ = ' '"
			cQuery +=   " AND BE_FILIAL  = '"+xFilial("SBF")+"'"
			cQuery +=   " AND BF_LOCAL   = '"+cLocDest+"'"
			cQuery +=   " AND BE_ESTFIS  = '"+cEstDest+"'"
			cQuery +=   " AND BE_LOCALIZ  = BF_LOCALIZ"

			//Deve filtar os outros produtos somente da mesma zona de armazenagem do produto atual
			If lPriorSA .And. lZonaPrd
				cQuery += " AND BE_CODZON = '"+cZonaPrd+"'"
			Else
				cQuery += " AND BE_CODZON IN ("

				//Se prioriza a sequencia, vai filtar direto, sen�o junta na query
				If !lPriorSA

					//N�o utiliza do cadastro por que existe um PE que pode alterar, usa a vari�vel
					cQuery += "SELECT '"+cZonaPrd+"' ZON_CODZON"
					cQuery += "  FROM "+RetSqlName("SB5")
					cQuery += " WHERE B5_FILIAL = '"+xFilial("SB5")+"'"
					cQuery += "   AND B5_COD    = '"+cProduto+"'"
					cQuery += "   AND D_E_L_E_T_ = ' '"
					cQuery += " UNION ALL "
				EndIf

				cQuery += "SELECT DCH_CODZON ZON_CODZON"
				cQuery += "  FROM "+RetSqlName("DCH")
				cQuery += " WHERE DCH_FILIAL = '"+xFilial("DCH")+"'"
				cQuery += "   AND DCH_CODPRO = '"+cProduto+"'"
				cQuery += "   AND DCH_CODZON <> '"+cZonaPrd+"'"
				cQuery += "   AND D_E_L_E_T_ = ' ')"
			EndIf

			cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
			cQuery += " GROUP BY BF_LOCAL, BF_LOCALIZ"
			cQuery += ") COM "
			cQuery += " GROUP BY SLD_LOCAL, SLD_ENDERE"
		EndIf

		cQuery += ") SLD"
		cQuery += "    ON SLD.SLD_LOCAL  = SBE.BE_LOCAL"
		cQuery += "   AND SLD.SLD_ENDERE = SBE.BE_LOCALIZ"
		
		//Carregando movimenta��o para o endere�o para o produto e/ou lote
		If lRadioF
			cQuery += "  LEFT JOIN ("
			cQuery += "SELECT DB_LOCAL MOV_LOCAL, DB_ENDDES MOV_ENDERE, SUM(DB_QUANT) MOV_SALDO"
			cQuery += "  FROM "+RetSqlName("SDB")+" SDB"
			cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
			cQuery += "   AND SDB.DB_LOCAL   = '"+cLocDest+"'"
			cQuery += "   AND SDB.DB_PRODUTO = '"+cProduto+"'"
			If (cWmsTpEn == "3" .And. nTipoEst != 2)
				cQuery += " AND SDB.DB_LOTECTL = '"+cLoteCtl+"'"
				cQuery += " AND SDB.DB_NUMLOTE = '"+cNumLote+"'"
			EndIf
			cQuery += "   AND SDB.DB_ESTDES  = '"+cEstDest+"'"
			cQuery += "   AND SDB.DB_TM     <= '500'"
			cQuery += "   AND SDB.DB_STATUS IN ('-','2','3','4')"
			cQuery += "   AND SDB.DB_ESTORNO = ' '"
			cQuery += "   AND SDB.DB_ATUEST  = 'N'"
			cQuery += "   AND SDB.D_E_L_E_T_ = ' '"
			cQuery += "   AND SDB.DB_ORDATIV = (SELECT MIN(DB_ORDATIV)"+;
															" FROM "+RetSqlName("SDB")+" SDBM"+;
														  " WHERE SDBM.DB_FILIAL  = SDB.DB_FILIAL"+;
															 " AND SDBM.DB_PRODUTO = SDB.DB_PRODUTO"+;
															 " AND SDBM.DB_DOC     = SDB.DB_DOC"+;
															 " AND SDBM.DB_SERIE   = SDB.DB_SERIE"+;
															 " AND SDBM.DB_CLIFOR  = SDB.DB_CLIFOR"+;
															 " AND SDBM.DB_LOJA    = SDB.DB_LOJA"+;
															 " AND SDBM.DB_SERVIC  = SDB.DB_SERVIC"+;
															 " AND SDBM.DB_TAREFA  = SDB.DB_TAREFA"+;
															 " AND SDBM.DB_IDMOVTO = SDB.DB_IDMOVTO"+;
															 " AND SDBM.DB_ESTORNO = ' '"+;
															 " AND SDBM.DB_ATUEST  = 'N'"+;
															 " AND SDBM.DB_STATUS IN ('4','3','2','-')"+;
															 " AND SDBM.D_E_L_E_T_ = ' ' )"
			cQuery += " GROUP BY SDB.DB_LOCAL, SDB.DB_ENDDES) MOV"
			cQuery += "    ON MOV.MOV_LOCAL  = SBE.BE_LOCAL"
			cQuery += "   AND MOV.MOV_ENDERE = SBE.BE_LOCALIZ"
		EndIf
	EndIf
	
	//Filtros em cima da SBE - Endere�os
	cQuery += " WHERE SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=  " AND (SBE.BE_CODPRO = ' ' OR SBE.BE_CODPRO = '"+cProduto+"')"

	// Tratamento para os dois armaz�ns e estruturas de pulm�o
	If !Empty( cArmz2 ) .And. !Empty( cEstFis2 )
		cQuery +=  " AND ( ( SBE.BE_ESTFIS = '"+cEstDest+"' AND SBE.BE_LOCAL = '"+cLocDest+"' ) OR "
		cQuery +=  "( SBE.BE_ESTFIS = '"+cEstFis2+"' AND SBE.BE_LOCAL = '"+cArmz2+"' ) )"
	Else
		cQuery +=  " AND SBE.BE_ESTFIS = '"+cEstDest+"' AND SBE.BE_LOCAL = '"+cLocDest+"'"
	EndIf
	
	cQuery +=  " AND SBE.BE_STATUS <> '3'"
	cQuery +=  " AND SBE.D_E_L_E_T_ = ' '"
	
	//Se prioriza a sequencia e est� usando a zona do produto, filtra direto
	If lPriorSA .And. lZonaPrd
		cQuery +=   " AND SBE.BE_CODZON = '"+cZonaPrd+"'"
	EndIf

	//Se somente endere�a em endere�os vazios, n�o considera endere�os saldo ou movimenta��o
	If cWmsTpEn == "1"
		//Desconsiderando endere�os que possuem saldo
		cQuery += " AND NOT EXISTS ("
		cQuery += " SELECT 1 FROM "+RetSqlName('SBF')+" SBF"
		cQuery +=  " WHERE BF_FILIAL  = '"+xFilial('SBF')+"'"
		cQuery +=    " AND BF_LOCAL   = BE_LOCAL"
		cQuery +=    " AND BF_LOCALIZ = BE_LOCALIZ"
		cQuery +=    " AND BF_ESTFIS  = BE_ESTFIS"
		cQuery +=    " AND BF_QUANT   > 0"
		cQuery +=    " AND SBF.D_E_L_E_T_  = ' ')"
		
		//Desconsiderando movimenta��o para o endere�o
		If lRadioF
			cQuery += " AND NOT EXISTS ("
			cQuery += " SELECT 2 FROM "+RetSqlName('SDB')+" SDB"
			cQuery +=  " WHERE DB_FILIAL  = '"+xFilial('SDB')+"'"
			cQuery +=    " AND DB_LOCAL   = BE_LOCAL"
			cQuery +=    " AND DB_ENDDES  = BE_LOCALIZ"
			cQuery +=    " AND DB_ESTDES  = BE_ESTFIS"
			cQuery +=    " AND DB_ESTORNO = ' '"
			cQuery +=    " AND DB_ATUEST  = 'N'"
			cQuery +=    " AND DB_STATUS IN ('-','2','3','4')"
			cQuery +=    " AND DB_TM <= '500'"
			cQuery +=    " AND SDB.D_E_L_E_T_  = ' ')"
		EndIf
	EndIf
	
	//Gerando a ordena��o dos endere�os
	cQuery += " ORDER BY ZON_ORDEM, PRD_ORDEM, SLD_ORDEM, MOV_ORDEM, BE_LOCALIZ"

	cAliasSBE := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSBE,.F.,.T.)
	aTamSX3:=TamSx3('BF_QUANT');
	
	//-- Ajustando o tamanho dos campos da query
	TcSetField(cAliasSBE,'PRD_ORDEM','N',5,0)
	TcSetField(cAliasSBE,'SLD_ORDEM','N',5,0)
	TcSetField(cAliasSBE,'MOV_ORDEM','N',5,0)
	TcSetField(cAliasSBE,'DCP_PEROCP','N',5,0)
	TcSetField(cAliasSBE,'SLD_SALDO','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasSBE,'MOV_SALDO','N',aTamSX3[1],aTamSX3[2])

Return cAliasSBE