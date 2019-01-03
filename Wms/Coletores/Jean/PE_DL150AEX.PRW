#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*
Jean Rehermann - Solutio IT - 03/10/2017
Ponto de Entrada DL150AEX (Depois da Execucao/Estorno do Servico)
Na execução do serviço de apanhe, reordenar a prioridade pelo endereço de forma crescente
No estorno, reconfigurar as atividade de acordo com as alterações do pedido
*/
//-- Parametros Passados:
//-- PARAMIXB[1] = nOpcx

User Function DL150AEX()

	Local _nOpc     := PARAMIXB[1]
	Local _lRadioF  := ( SuperGetMV('MV_RADIOF', .F., 'N') == 'S' ) // Jean Rehermann - Solutio IT - 26/12/2018 - Não executar quando RF OFF

	If _lRadioF
		MsAguarde( {|| AvPriEst(_nOpc) }, "Avaliando prioridade e estorno..." )
    EndIf
    
Return

Static Function AvPriEst(nOpt)

	Local _aSav     := GetArea()
	Local _aDocs    := {}
	Local cQuery    := ""
	Local cAliasNew := ""
	Local _cDoc     := ""
	Local _cOrd     := ""
	Local _cItm     := "00"
	Local _lPriori  := .T.
	Local _l015     := .F.
	Local _l022     := .F.
	Local _lPrdRec  := .F.
	Local _aSDBAnt  := {}
	Local _aSDBAtu  := {}
	Local _nX       := 0
	Local _nY       := 0
	Local _nQtdAnt  := 0
	Local _nQtdAtu  := 0
	Local _nQtdSld  := 0
	Local _nDif     := 0

	Private _aDocVer  := {}
	Private cStatExec := SuperGetMV('MV_RFSTEXE', .F., '1') //-- DB_STATUS indincando Atividade Executada
	Private cStatProb := SuperGetMV('MV_RFSTPRO', .F., '2') //-- DB_STATUS indincando Atividade com Problemas
	Private cStatInte := SuperGetMV('MV_RFSTINT', .F., '3') //-- DB_STATUS indincando Atividade Interrompida (Em Execução)
	Private cStatAExe := SuperGetMV('MV_RFSTAEX', .F., '4') //-- DB_STATUS indincando Atividade A Executar
	Private cStatAuto := SuperGetMV('MV_RFSTAUT', .F., 'A') //-- DB_STATUS indincando Atividade Automatica
	Private cStatManu := SuperGetMV('MV_RFSTMAN', .F., 'M') //-- DB_STATUS indincando Atividade Manual
	
	// Caso a variável não tenha sido criada no ponto anterior, não tem como continuar (tratamento da priorização)
	If Type("__cDocDCF") == "U"
		_lPriori := .F.
	Else
		If !Empty( __cDocDCF ) .And. Right( __cDocDCF, 2 ) == ",'"
			__cDocDCF += "#'"
		Else
			__cDocCDF := ""
			_lPriori  := .F.
		EndIf
	EndIf

	If nOpt == 1 // Apenas quando for execução
	
        // Faz os ajustes de prioridade
		If _lPriori

			// Primeiro altera as atividades de separação
			cAliasNew := GetNextAlias()
			
			cQuery := " SELECT DB_PRIORI, DB_DOC, R_E_C_N_O_ RECNOSDB "
			cQuery += " FROM "+ RetSqlName("SDB")
			cQuery += " WHERE DB_DOC IN ('"+ __cDocDCF +") AND DB_ORIGEM = 'SC9' " // __cDocDCF é uma varável pública criada no PE DL150BEX
			cQuery += "    AND D_E_L_E_T_ = ' ' AND DB_ESTORNO = ' ' "
			cQuery += "    AND DB_SERVIC = '001' AND DB_FILIAL = '"+ xFilial("SDB") +"' "
			cQuery += "    AND DB_TAREFA = '002' AND DB_ATIVID = '015' "
			cQuery += "    AND ( DB_STATUS = '"+ cStatAExe +"' OR DB_STATUS = '"+ cStatInte +"' OR DB_STATUS = '"+ cStatProb +"' ) "
			cQuery += " ORDER BY DB_DOC, DB_LOCALIZ ASC "
	
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
		
			While !(cAliasNew)->( Eof() )
			
				_cDoc := (cAliasNew)->DB_DOC
				_nPosDoc := aScan( _aDocs, {|o| o[ 1 ] == _cDoc } )
			    
				If _nPosDoc == 0
					_cItm := "00"
					_cOrd := AllTrim( (cAliasNew)->DB_PRIORI )
					_cOrd := SubStr( _cOrd, 1, Len( _cOrd ) - 2 )
					aAdd( _aDocs, { _cDoc, _cItm, _cOrd } )
					_nPosDoc := aScan( _aDocs, {|o| o[ 1 ] == _cDoc } )
				Else
					_cItm := _aDocs[ _nPosDoc, 2 ]
					_cOrd := _aDocs[ _nPosDoc, 3 ]
				EndIf
				
				SDB->( dbGoTo( (cAliasNew)->RECNOSDB ) )
				
				SDB->( RecLock( "SDB", .F. ) )
					_cItm := Soma1( _cItm )
					_aDocs[ _nPosDoc, 2 ] := _cItm // Atualizo a última sequência do documento
					SDB->DB_PRIORI := _cOrd + _cItm
				SDB->( MsUnLock() )
				
				(cAliasNew)->( dbSkip() )
			End
		
			(cAliasNew)->( dbCloseArea() )
			
			// Depois altera as atividades de conferência, para manter a integridade do campo de prioridade (sequenciamento dentro do documento)
			_cDoc     := ""
			cAliasNew := GetNextAlias()
			
			cQuery := " SELECT DB_PRIORI, DB_DOC, R_E_C_N_O_ RECNOSDB "
			cQuery += " FROM "+ RetSqlName("SDB")
			cQuery += " WHERE DB_DOC IN ('"+ __cDocDCF +") AND DB_ORIGEM = 'SC9' " // __cDocDCF é uma varável pública criada no PE DL150BEX
			cQuery += "    AND D_E_L_E_T_ = ' ' AND DB_ESTORNO = ' ' "
			cQuery += "    AND DB_SERVIC = '001' AND DB_FILIAL = '"+ xFilial("SDB") +"' "
			cQuery += "    AND DB_TAREFA = '003' AND DB_ATIVID = '022' "
			cQuery += "    AND ( DB_STATUS = '4' OR DB_STATUS = '3' OR DB_STATUS = '2' ) "
			cQuery += " ORDER BY R_E_C_N_O_ ASC "
	
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
		
			While !(cAliasNew)->( Eof() )
			
				_cDoc := (cAliasNew)->DB_DOC
				_nPosDoc := aScan( _aDocs, {|o| o[ 1 ] == _cDoc } )
			    
				If _nPosDoc == 0
					_cItm := "00"
					_cOrd := AllTrim( (cAliasNew)->DB_PRIORI )
					_cOrd := SubStr( _cOrd, 1, Len( _cOrd ) - 2 )
					aAdd( _aDocs, { _cDoc, _cItm, _cOrd } )
					_nPosDoc := aScan( _aDocs, {|o| o[ 1 ] == _cDoc } )
				Else
					_cItm := _aDocs[ _nPosDoc, 2 ]
					_cOrd := _aDocs[ _nPosDoc, 3 ]
				EndIf
				
				SDB->( dbGoTo( (cAliasNew)->RECNOSDB ) )
				
				SDB->( RecLock( "SDB", .F. ) )
					_cItm := Soma1( _cItm )
					_aDocs[ _nPosDoc, 2 ] := _cItm // Atualizo a última sequência do documento
					SDB->DB_PRIORI := _cOrd + _cItm
				SDB->( MsUnLock() )
				
				(cAliasNew)->( dbSkip() )
			End
		
			(cAliasNew)->( dbCloseArea() )
		
		EndIf

		///////////////////   AJUSTES DO ESTORNO  //////////////////////

		// Verificar se os itens executados tem estorno anterior e realiza o ajuste das quantidades separadas
		If Type("__aIDDCF") == "A" .And. Len( __aIDDCF ) > 0

			If _lPriori // Variável existe
				_aDocVer := VerTodos() // Recebe todos os produtos de todos os DOCUMENTOS marcados, com serviço 001 e origem SC9
			EndIf
			
			For _nX := 1 To Len( __aIDDCF )
			
				// Pode ser que algum item marcado tenha dado problema na execução, se não existir aqui é porque não foi executado.
				If ExistMark( __aIDDCF[ _nX ] ) // Marca no array de produtos dos DOCUMENTOS executados aquele que está sendo processado
				
					_cIDAnt := U_GetIdAnt( __aIDDCF[ _nX ] ) // Pesquisa se existe IDDCF anterior para o mesmo Documento + Produto
				
					// Jean Rehermann - Solutio IT - 04/12/2018 - Verificar se item foi deletado em estorno anterior ao último
					_lPrdRec := VltExcl( _cIDAnt )

					// Jean Rehermann - Solutio IT - 05/12/2018 - Neste caso, vou tratar como se fosse um item novo
					If _lPrdRec
						_cIDAnt := 'VAZIO'
					EndIf
					
					If !Empty( _cIDAnt ) .And. AllTrim( _cIDAnt ) != 'VAZIO'
					
						// Limpo as variáveis de controle
						_l015    := .F.
						_l022    := .F.

						// Gravação da observação de pedido estornado no atendimento para aparecer na tela de separação
						cSUA := Posicione("SC5",1,xFilial("SC5") + __aIDDCF[ _nX, 1 ],"C5_NUMSUA")
						If !Empty( cSUA )
							cObs := AllTrim( Posicione("SUA",1,xFilial("SUA") + cSUA,"UA_OBSEXP") )
							If !"PEDIDO ESTORNADO"$cObs
								cObs := Left( cObs + Iif( !Empty( cObs ), " - ", "" ) +"PEDIDO ESTORNADO", TamSX3("UA_OBSEXP")[1] )
								SUA->(dbSetOrder(1))
								SUA->(dbSeek(xFilial("SUA")+cSUA))
								If Found()
									SUA->( RecLock("SUA",.F.) )
										SUA->UA_OBSEXP := cObs
									SUA->( MsUnLock() )
								EndIf
							EndIf
						EndIf
	
						_aSDBAnt := GetSDBAnt( _cIDAnt, __aIDDCF[ _nX ] ) // Busca os últimos registros do SDB com este IDDCF anterior
						
						LimpaRegs( _cIDAnt, _aSDBAnt ) // Como existe IDDCF anterior, eliminos os registro de DCF, DCR correspondentes
						
						For _nY := 1 To Len( _aSDBAnt )
							
							If _aSDBAnt[ _nY, 5 ] == "022" // Atividade de Conferência
								
								_aSDBAtu := GetSDBAtu( __aIDDCF[ _nX ], "022" ) // Busca os registros do SDB com o IDDCF atual de conferência

								If Len( _aSDBAtu ) > 0 // Encontrou o registro atual e trouxe as informações

									SDB->( dbGoTo( _aSDBAtu[ 1, 3 ] ) ) // Posiciono no SDB atual da atividade de conferência
									SDB->( RecLock("SDB",.F.) )
										
										// Ajusto apenas a quantidade conferida de acordo com o registro anterior
										SDB->DB_QTDLID := Iif( _aSDBAnt[ _nY, 8 ] < SDB->DB_QUANT, _aSDBAnt[ _nY, 8 ], SDB->DB_QUANT )

										// Se a quantidade lida for maior ou igual à quantidade, então a atividade já deve constar como concluída
										If SDB->DB_QTDLID >= SDB->DB_QUANT
											SDB->DB_STATUS  := '1'
											SDB->DB_DATAFIM := dDataBase
											SDB->DB_HRFIM   := Left( Time(), 5 )
											SDB->DB_ESTFLAG := "NGL" // Isto indica que este registro de conferência não precisa ser liberado de estoque
										EndIf

										If Empty( SDB->DB_RECHUM ) .Or. SDB->DB_RECHUM == "000000"
											SDB->DB_RECHUM := Iif( SDB->DB_QTDLID < SDB->DB_QUANT, Space( Len( SDB->DB_RECHUM ) ), _aSDBAnt[ _nY, 9 ] ) // Se vou ter que conferir algo, deixo em branco mesmo
										EndIf
									
										SDB->DB_LOCALIZ := _aSDBAnt[ _nY, 13 ] // Deve manter na mesma mesa
									
									SDB->( MsUnLock() )

									If _aSDBAtu[ 1, 1 ] <= _aSDBAnt[ _nY, 3 ] // Quando a quantidade atual é menor ou igual que o SDB anterior

										// SE a quantidade conferida anteriormente for maior que a QUANTIDADE atual, grava na ZAR para retirada de volume
										If ( _aSDBAnt[ _nY, 8 ] - SDB->DB_QUANT ) > 0
											ZAR->( RecLock("ZAR",.T.) )
												ZAR->ZAR_FILIAL := xFilial("ZAR")
												ZAR->ZAR_PEDIDO := SDB->DB_DOC
												ZAR->ZAR_PRODUT := SDB->DB_PRODUTO
												ZAR->ZAR_QTDANT := _aSDBAnt[ _nY, 3 ]  // Quantidade anterior
												ZAR->ZAR_QTDATU := SDB->DB_QUANT       // Quantidade atual
												ZAR->ZAR_CNFANT := _aSDBAnt[ _nY, 8 ]  // Conferido anterior
												ZAR->ZAR_QTDRET := _aSDBAnt[ _nY, 8 ] - SDB->DB_QUANT // Quantidade a retirar
												ZAR->ZAR_RECHUM := SDB->DB_RECHUM      // Recurso Humano
												ZAR->ZAR_LOCALI := SDB->DB_LOCALIZ     // Mesa de conferência
											ZAR->( MsUnLock() )
										EndIf
										// Isto indica que este registro de conferência não precisa ser liberado de estoque
										SDB->( RecLock("SDB",.F.) )
											SDB->DB_ESTFLAG := "NGL"
										SDB->( MsUnLock() )
                                    EndIf
                                    
								Else
									// Jean Rehermann-Solutio IT- 28/02/2018 - Ajuste realizado quando produto não é executado (preciso reativar o SDB deletado)
									// SDBRecall( _cIDAnt, _aSDBAnt, "022" )
								EndIf	

								_l022 := .T.
							EndIf
							
							If _aSDBAnt[ _nY, 5 ] == "015" // Atividade de Separação
								
								_aSDBAtu := GetSDBAtu( __aIDDCF[ _nX ], "015" ) // Busca os registros do SDB com o IDDCF atual de separação
								
								If Len( _aSDBAtu ) > 0
									
									// Zerar os totalizadores de controle
									_nQtdAnt := 0
									_nQtdAtu := 0
									_nQtdSld := 0
									
									// Totalizar as quantidades (anterior e atual)
									aEval( _aSDBAnt, { |o| _nQtdAnt += Iif( o[ 5 ] == "015", o[ 3 ], 0 ) } )
									aEval( _aSDBAtu, { |o| _nQtdAtu += o[ 1 ] } )
									
									_nQtdSld := _nQtdAnt // Controlar o saldo a ser verificado para o apanhe
											
									// Quando a quantidade atual for maior do que o SDB anterior
									If _nQtdAtu > _nQtdAnt
	                                                      
										// Verifico todos os registros SDB gerados (Atuais - _aSDBAtu)
										For _nU := 1 To Len( _aSDBAtu )
										
											SDB->( dbGoTo( _aSDBAtu[ _nU, 3 ] ) ) // Posiciono no SDB atual da atividade de separação
											
											// Significa que neste SDB não tem quantidade a ser apanhada, portanto não cairá nos coletores
											If _nQtdSld >= SDB->DB_QUANT
												
												_nQtdSld -= SDB->DB_QUANT // Diminuir a quantidade do saldo anterior

												SDB->( RecLock("SDB",.F.) )
													SDB->DB_STATUS  := '1'
													SDB->DB_DATAFIM := dDataBase
													SDB->DB_HRFIM   := Left( Time(), 5 )
													SDB->DB_QTDLID  := SDB->DB_QUANT

													// Verifico o recurso humano
													If Empty( SDB->DB_RECHUM ) .Or. SDB->DB_RECHUM == "000000"
														SDB->DB_RECHUM := Iif( Empty( _aSDBAnt[ _nY, 9 ] ) .Or. _aSDBAnt[ _nY, 9 ] == "000000", U_DBRecHum(.F.), _aSDBAnt[ _nY, 9 ] )
													EndIf

													SDB->DB_ENDDES := _aSDBAnt[ _nY, 14 ] // Deve manter na mesma mesa

												SDB->( MsUnLock() )

												// Preciso levar o saldo do endereço para a DOCA ou MESA novamente
												ConWmsEst( _aSDBAtu[ _nU ], _cIDAnt, _aSDBAnt[ _nY, 14 ] ) // [1] SDB atual [2] IDDCF Anterior [3] Endereço
												SDB->( dbGoTo( _aSDBAtu[ _nU, 3 ] ) ) // Reposiciono o SDB após tratamento de estoques

												Loop // Vai para o próximo registro SDB gerado (atual)

											// Significa que neste SDB tem que ser apanhada alguma quantidade e será feito o ajuste
											ElseIf _nQtdSld < SDB->DB_QUANT

												_nDif    := SDB->DB_QUANT - _nQtdSld
												_nQtdSld := 0

												SDB->( RecLock("SDB",.F.) )

													SDB->DB_QUANT := _nDif // Quantidade que deve ser apanhada fisicamente no endereço

													// Verifico o recurso humano
													If Empty( SDB->DB_RECHUM ) .Or. SDB->DB_RECHUM == "000000"
														SDB->DB_RECHUM := Iif( Empty( _aSDBAnt[ _nY, 9 ] ) .Or. _aSDBAnt[ _nY, 9 ] == "000000", U_DBRecHum(.F.), _aSDBAnt[ _nY, 9 ] )
													EndIf

													SDB->DB_ENDDES := _aSDBAnt[ _nY, 14 ] // Deve manter na mesma mesa

												SDB->( MsUnLock() )

												// Faço ajuste no ZCS e ZCT com a quantidade atual para poder embalar o volume depois
												ZCS->( dbSetOrder(1) ) //ZCS_FILIAL+ZCS_CARGA+ZCS_PEDIDO
												If ZCS->( MsSeek( xFilial("ZCS") + Space( Len( ZCS->ZCS_CARGA ) ) + __aIDDCF[ _nX, 1 ] ) )

													// Quando o ZCS já existe, preciso incluir este novo item no ZCT e atualizar o ZCS
													ZCS->( RecLock("ZCS",.F.) )
														ZCS->ZCS_QTSEPA += _nDif // Quantidade é a diferença
														If ZCS->ZCS_STATUS == "3"
															ZCS->ZCS_STATUS := "2"
														EndIf
													ZCS->( MsUnLock() )

													ZCT->( dbSetOrder(1) ) //ZCT_FILIAL+ZCT_CARGA+ZCT_PEDIDO+ZCT_CODPRO
													If !ZCT->( MsSeek( xFilial("ZCT") + Space( Len( ZCS->ZCS_CARGA ) ) + AllTrim( __aIDDCF[ _nX, 1 ] ) + __aIDDCF[ _nX, 4 ] ) )
														ZCT->( Reclock('ZCT',.T.) )
															ZCT->ZCT_Filial := xFilial("ZCT")
															ZCT->ZCT_IDDCF  := __aIDDCF[ _nX, 6 ]
															ZCT->ZCT_PEDIDO := __aIDDCF[ _nX, 1 ]
															ZCT->ZCT_STATUS := "1"
															ZCT->ZCT_CODPRO := __aIDDCF[ _nX, 4 ]
															ZCT->ZCT_QTSEPA := _nQtdAtu // Quantidade atual se não existe ZCT (improvável)
															ZCT->ZCT_QTEMBA := 0
															If ZCT->(FieldPos("ZCT_DATA")) > 0
																ZCT->ZCT_DATA := ZCS->ZCS_DATA
																ZCT->ZCT_HORA := ZCS->ZCS_HORA
															EndIf
														ZCT->( MsUnLock() )
													Else
														ZCT->( Reclock('ZCT',.F.) )
															ZCT->ZCT_QTSEPA += _nDif // Quantidade é a diferença
															ZCT->ZCT_IDDCF  := __aIDDCF[ _nX, 6 ] // Atualizo o IDDCF do ZCT
															AtuDcfZcv( _aSDBAnt[ _nY, 7 ], __aIDDCF[ _nX, 6 ] ) // Atualiza o ZCV com o novo IDDCF
															If ZCT->ZCT_STATUS == "3"
																ZCT->ZCT_STATUS := "2"
															EndIf
														ZCT->( MsUnLock() )
													EndIf

												EndIf

											EndIf

                                        Next // For _aSDBAtu ( todos os registros atuais de SDB para este IDDCF )

									// Quando a quantidade total atual é menor ou igual que a quantidade total anterior
									ElseIf _nQtdAtu <= _nQtdAnt

										// Verifico todos os registros SDB gerados (Atuais - _aSDBAtu)
										For _nU := 1 To Len( _aSDBAtu )

											SDB->( dbGoTo( _aSDBAtu[ _nU, 3 ] ) ) // Posiciono no SDB atual da atividade de separação

											SDB->( RecLock("SDB",.F.) )
												SDB->DB_QTDLID  := SDB->DB_QUANT
												SDB->DB_STATUS  := '1'
												SDB->DB_DATAFIM := dDataBase
												SDB->DB_HRFIM   := Left( Time(), 5 )

												// Verifico o recurso humano
												If Empty( SDB->DB_RECHUM ) .Or. SDB->DB_RECHUM == "000000"
													SDB->DB_RECHUM := Iif( Empty( _aSDBAnt[ _nY, 9 ] ) .Or. _aSDBAnt[ _nY, 9 ] == "000000", U_DBRecHum(.F.), _aSDBAnt[ _nY, 9 ] )
												EndIf

												SDB->DB_ENDDES := _aSDBAnt[ _nY, 14 ] // Deve manter na mesma mesa

											SDB->( MsUnLock() )

											// Preciso levar o saldo do endereço para a DOCA ou MESA novamente
											// [1] SDB atual [2] IDDCF Anterior [3] Endereço da MESA
											ConWmsEst( _aSDBAtu[ _nU ], _cIDAnt, _aSDBAnt[ _nY, 14 ] )
											SDB->( dbGoTo( _aSDBAtu[ _nU, 3 ] ) ) // Reposiciono o SDB após tratamento de estoques

										Next

										// Faço ajuste no ZCS e ZCT com a quantidade atual quando for menor
										If _nQtdAtu < _nQtdAnt

											ZCS->( dbSetOrder(1) ) //ZCS_FILIAL+ZCS_CARGA+ZCS_PEDIDO
											If ZCS->( MsSeek( xFilial("ZCS") + Space( Len( ZCS->ZCS_CARGA ) ) + __aIDDCF[ _nX, 1 ] ) )

												ZCS->( RecLock("ZCS",.F.) )
													ZCS->ZCS_QTSEPA -= ( _nQtdAnt - _nQtdAtu ) // Quantidade é a diferença
													ZCS->ZCS_QTEMBA -= ( _nQtdAnt - _nQtdAtu ) // Quantidade é a diferença
												ZCS->( MsUnLock() )

												ZCT->( dbSetOrder(1) ) //ZCT_FILIAL+ZCT_CARGA+ZCT_PEDIDO+ZCT_CODPRO
												If ZCT->( MsSeek( xFilial("ZCT") + Space( Len( ZCS->ZCS_CARGA ) ) + AllTrim( __aIDDCF[ _nX, 1 ] ) + __aIDDCF[ _nX, 4 ] ) )
													ZCT->( Reclock('ZCT',.F.) )
														ZCT->ZCT_QTSEPA -= ( _nQtdAnt - _nQtdAtu ) // Quantidade é a diferença
														ZCT->ZCT_QTEMBA -= ( _nQtdAnt - _nQtdAtu ) // Quantidade é a diferença
														ZCT->ZCT_QTLIBE -= ( _nQtdAnt - _nQtdAtu ) // Quantidade é a diferença
													ZCT->( MsUnLock() )
												EndIf

											EndIf

                                        EndIf

								    EndIf

								Else
									// Jean Rehermann-Solutio IT- 28/02/2018 - Ajuste realizado quando produto não é executado (preciso reativar o SDB deletado)
									//SDBRecall( _cIDAnt, _aSDBAnt, "015" )
								EndIf

								_l015 := .T.
							EndIf

							If _l015 .And. _l022
								Exit
							EndIf

						Next

					Else
						// Quando não possui IDDCF anterior, pode ser que eu esteja incluindo item no PV, para saber verifico se existe ZCS
						// Quando o ZCS não existe significa que é um pedido novo e o ZCS e o ZCT serão criados na tela de conferência
						ZCS->( dbSetOrder(1) ) //ZCS_FILIAL+ZCS_CARGA+ZCS_PEDIDO
						If ZCS->( MsSeek( xFilial("ZCS") + Space( Len( ZCS->ZCS_CARGA ) ) + __aIDDCF[ _nX, 1 ] ) )

							// Quando o ZCS já existe, preciso incluir este novo item no ZCT e atualizar o ZCS
							ZCS->( RecLock("ZCS",.F.) )
								ZCS->ZCS_QTSEPA += __aIDDCF[ _nX, 5 ]
								If ZCS->ZCS_STATUS == "3"
									ZCS->ZCS_STATUS := "2"
								EndIf
							ZCS->( MsUnLock() )

							ZCT->( dbSetOrder(1) ) //ZCT_FILIAL+ZCT_CARGA+ZCT_PEDIDO+ZCT_CODPRO
							If !ZCT->( MsSeek( xFilial("ZCT") + Space( Len( ZCS->ZCS_CARGA ) ) + AllTrim( __aIDDCF[ _nX, 1 ] ) + __aIDDCF[ _nX, 4 ] ) )
								ZCT->( Reclock('ZCT',.T.) )
									ZCT->ZCT_FILIAL := xFilial("ZCT")
									ZCT->ZCT_IDDCF  := __aIDDCF[ _nX, 6 ]
									ZCT->ZCT_PEDIDO := AllTrim( __aIDDCF[ _nX, 1 ] )
									ZCT->ZCT_STATUS := "1"
									ZCT->ZCT_CODPRO := __aIDDCF[ _nX, 4 ]
									ZCT->ZCT_QTSEPA := __aIDDCF[ _nX, 5 ]
									ZCT->ZCT_QTEMBA := 0
									If ZCT->(FieldPos("ZCT_DATA")) > 0
										ZCT->ZCT_DATA := ZCS->ZCS_DATA
										ZCT->ZCT_HORA := ZCS->ZCS_HORA
									EndIf
								ZCT->( MsUnLock() )
							EndIf

						EndIf

					EndIf // Se possui IDDCF anterior

				EndIf

				// Jean Rehermann - Solutio IT - 11/12/2017 - Faço aqui a verificação do RH que era no PE CRIASDBD
				aAreaSDB := SDB->( GetArea() )

				dbSelectArea("SDB")
				dbSetOrder(7)
				If dbSeek( xFilial("SDB") + __aIDDCF[ _nX, 4 ] + __aIDDCF[ _nX, 1 ] + __aIDDCF[ _nX, 7 ] + __aIDDCF[ _nX, 2 ] + __aIDDCF[ _nX, 3 ] + "001002015" )
					If SDB->DB_IDDCF == __aIDDCF[ _nX, 6 ] .And. ( Empty( SDB->DB_RECHUM ) .Or. SDB->DB_RECHUM == "000000" )
						U_DBRecHum() // Função está no fonte do ponto de entrada CRIASDBD
					EndIf
				EndIf

				RestArea( aAreaSDB )

			Next

			VerDelet() // Se restou algum produto não marcado no processamento, ele pode ter sido excluído, preciso verificar

		EndIf

	EndIf

	RestArea( _aSav )

Return( Nil )

// Verifica se produto foi excluído de pedido em estorno anterior ao atual
Static Function VltExcl( cIDCFAnt )

	Local lRetorno  := .F.
	Local cQuery    := ""
	Local cAliasNew := ""
	
	cAliasNew := GetNextAlias()

	cQuery := " SELECT COUNT(*) TOTAL "
	cQuery += " FROM "+ RetSqlName("SDB")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += "   AND DB_FILIAL  = '"+ xFilial("SDB") +"' "
	cQuery += "   AND DB_SERVIC  = 'XXX' "
	cQuery += "   AND DB_TIPO    = 'X' "
	cQuery += "   AND DB_ESTORNO = 'S' "
	cQuery += "   AND DB_ORIGEM  = 'DEL' "
	cQuery += "   AND DB_IDDCF   = '"+ cIDCFAnt +"' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)

	lRetorno := (cAliasNew)->TOTAL > 0
		
	(cAliasNew)->( dbCloseArea() )

Return( lRetorno )

// Verifica se existe IDDCF anterior para o mesmo produto/documento/cliente
User Function GetIdAnt( aDCF, lMens )

	Local _cId      := ""
	Local cQuery    := ""
	Local cAliasNew := ""
	
	Default lMens := .F.

	cAliasNew := GetNextAlias()

	If lMens
	
		cQuery := " SELECT CASE SUM(TOTAL) WHEN 0 THEN 'VAZIO' ELSE 'ESTORNADO' END RESULT "
		cQuery += " FROM  (SELECT (SELECT COUNT(*) TOT "
		cQuery += "               FROM   "+ RetSqlName("SDB") +" SDB2 "
		cQuery += "               WHERE  DB_FILIAL      = SDB1.DB_FILIAL "
		cQuery += "                      AND DB_DOC     = SDB1.DB_DOC "
		cQuery += "                      AND DB_ATIVID  = SDB1.DB_ATIVID "
		cQuery += "                      AND DB_ORIGEM  = SDB1.DB_ORIGEM "
		cQuery += "                      AND DB_PRODUTO = SDB1.DB_PRODUTO "
		cQuery += "                      AND DB_LOCAL   = SDB1.DB_LOCAL "
		cQuery += "                      AND DB_LOCALIZ = SDB1.DB_LOCALIZ "
		cQuery += "                      AND D_E_L_E_T_ = ' ' "
		cQuery += "                      AND DB_ESTORNO = 'S') TOTAL, "
		cQuery += "                   DB_ESTORNO, "
		cQuery += "		              DB_LOCAL, "
		cQuery += "		              DB_PRODUTO, "
		cQuery += "		              DB_LOCALIZ "
		cQuery += "		       FROM   "+ RetSqlName("SDB") +" SDB1 "
		cQuery += "		       WHERE  DB_FILIAL      = '"+ xFilial("SDB") +"' "
		cQuery += "		              AND DB_DOC     = '"+ aDCF[ 1 ] +"' "
		cQuery += "		              AND DB_ATIVID  = '015' "
		cQuery += "		              AND DB_ORIGEM  = 'SC9' "
		cQuery += "		              AND D_E_L_E_T_ = ' ' "
		cQuery += "		              AND DB_ESTORNO = ' ') "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	
		_cId := (cAliasNew)->RESULT
		
	Else
	
		cQuery := " SELECT NVL( MAX(DCF_ID), 'VAZIO') MAXIDDCF "
		cQuery += " FROM "+ RetSqlName("DCF")
		cQuery += " WHERE D_E_L_E_T_ <> ' ' "
		cQuery += "   AND DCF_SERVIC = '001' "
		cQuery += "   AND DCF_FILIAL = '"+ xFilial("DCF") +"' "
		cQuery += "   AND DCF_DOCTO  = '"+ aDCF[ 1 ] +"' "
		cQuery += "   AND DCF_CLIFOR = '"+ aDCF[ 2 ] +"' "
		cQuery += "   AND DCF_LOJA   = '"+ aDCF[ 3 ] +"' "
		cQuery += "   AND DCF_CODPRO = '"+ aDCF[ 4 ] +"' "
		cQuery += "   AND DCF_ID    <> '"+ aDCF[ 6 ] +"' "
	
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	
		_cId := (cAliasNew)->MAXIDDCF
    
	EndIf
	
	(cAliasNew)->( dbCloseArea() )

Return( _cId )

// Busca os últimos registros do SDB com o IDDCF anterior existente
Static Function GetSDBAnt( cIdDCF, aDCF )

	Local _aSDBRet  := {}
	Local cQuery    := ""
	Local cAliasNew := ""
	Local _nPos     := 0
	Local _nF       := 0
	Local _cAtivid  := ""
	Local _nQtdAnt  := 0
	Local _nLidAnt  := 0
	
	cAliasNew := GetNextAlias()

	cQuery := " SELECT DB_ESTORNO, DB_PRODUTO, DB_QUANT, DB_TAREFA, DB_ATIVID, DB_STATUS, DB_IDDCF, DB_QTDLID, DB_RECHUM, DB_LOCALIZ, DB_ENDDES, R_E_C_N_O_ "
	cQuery += " FROM "+ RetSqlName("SDB")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += "   AND DB_FILIAL  = '"+ xFilial("SDB") +"' "
	cQuery += "   AND DB_SERVIC  = '001' "
	cQuery += "   AND DB_ORIGEM  = 'SC9' "
	cQuery += "   AND DB_DOC     = '"+ aDCF[ 1 ] +"' "
	cQuery += "   AND DB_CLIFOR  = '"+ aDCF[ 2 ] +"' "
	cQuery += "   AND DB_LOJA    = '"+ aDCF[ 3 ] +"' "
	cQuery += "   AND DB_PRODUTO = '"+ aDCF[ 4 ] +"' "
	cQuery += "   AND DB_IDDCF   = '"+ cIdDCF    +"' "
	cQuery += " ORDER BY R_E_C_N_O_ DESC "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	
	While !(cAliasNew)->( Eof() )
		
		_nPos    := aScan( _aSDBRet, {|o| o[13] == (cAliasNew)->DB_LOCALIZ } )
		_cAtivid := (cAliasNew)->DB_ATIVID
		
		If _nPos == 0
		
			aAdd( _aSDBRet, {(cAliasNew)->DB_ESTORNO,;                             // 01 - ESTORNADO
							 (cAliasNew)->DB_PRODUTO,;                             // 02 - CODIGO DO PRODUTO
							 Iif( _cAtivid == "015", 0, (cAliasNew)->DB_QUANT ),;  // 03 - QUANTIDADE SOLICITADA
							 (cAliasNew)->DB_TAREFA ,;                             // 04 - TAREFA
							 _cAtivid               ,;                             // 05 - ATIVIDADE
							 (cAliasNew)->DB_STATUS ,;                             // 06 - STATUS
							 cIdDCF                 ,;                             // 07 - IDDCF
							 Iif( _cAtivid == "015", 0, (cAliasNew)->DB_QTDLID ),; // 08 - QUANTIDADE LIDA
							 (cAliasNew)->DB_RECHUM ,;                             // 09 - RECURSO HUMANO
							 aDCF[ 1 ],;                                           // 10 - DOCUMENTO
							 aDCF[ 2 ],;                                           // 11 - CLIENTE
							 aDCF[ 3 ],;                                           // 12 - LOJA
							 (cAliasNew)->DB_LOCALIZ,;                             // 13 - ENDEREÇO ORIGEM
							 (cAliasNew)->DB_ENDDES })                             // 14 - ENDEREÇO DESTINO
	    
		Endif
		
		(cAliasNew)->( dbSkip() )
	End
	(cAliasNew)->( dbCloseArea() )

	// Atualizar a quantidade e a quantidade lida do produto + endereço do que já foi apanhado
	For _nF := 1 To Len( _aSDBRet )

		If _aSDBRet[ _nF, 5 ] == "015" // Apenas atividade de apanhe
		
			cAliasNew := GetNextAlias()
		
			cQuery := " SELECT NVL(SUM(DB_QUANT),0) QUANT, NVL(SUM(DB_QTDLID),0) LIDO "
			cQuery += " FROM "+ RetSqlName("SDB")
			cQuery += " WHERE D_E_L_E_T_ = ' ' "
			cQuery += "   AND DB_FILIAL  = '"+ xFilial("SDB") +"' "
			cQuery += "   AND DB_SERVIC  = '001' "
			cQuery += "   AND DB_ATIVID  = '015' "
			cQuery += "   AND DB_ORIGEM  = 'SC9' "
			cQuery += "   AND DB_STATUS  = '"+ cStatExec +"' "
			cQuery += "   AND DB_DOC     = '"+ aDCF[ 1 ] +"' "
			cQuery += "   AND DB_CLIFOR  = '"+ aDCF[ 2 ] +"' "
			cQuery += "   AND DB_LOJA    = '"+ aDCF[ 3 ] +"' "
			cQuery += "   AND DB_PRODUTO = '"+ aDCF[ 4 ] +"' "
			cQuery += "   AND DB_LOCALIZ = '"+ _aSDBRet[ _nF, 13 ] +"' "
			cQuery += "   AND DB_ESTFLAG = ' ' "
			cQuery += "   AND DB_IDDCF = '"+ cIdDCF +"' "
		
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
			
			If !(cAliasNew)->( Eof() )
				_nQtdAnt := (cAliasNew)->QUANT
				_nLidAnt := (cAliasNew)->LIDO
			EndIf
			(cAliasNew)->( dbCloseArea() )

			// Jean Rehermann - Solutio IT - 06/12/2018 - Este teste condicional foi criado para o caso em que os apanhes anteriores somados
			// são iguais ou maiores que a quantidade que está sendo solicitada, porém, antes do último estorno a quantidade era menor, ou seja,
			// para esta execução deve gerar apanhe para a diferença entre o atual e o anterior, mas como a soma dos apanhes anteriores é maior
			// não estava gerando este apanhe e encerrando a atividade como executada. >> aDCF[ 5 ] == Quantidade atual no DCF | cIdDCF == IDDCF anterior
			If _nQtdAnt > 0 .And. _nQtdAnt < aDCF[ 5 ]
				
				_aSDBRet[ _nF, 03 ] := _nQtdAnt
				_aSDBRet[ _nF, 08 ] := _nLidAnt
			
			Else

				cAliasNew := GetNextAlias()
			
				cQuery := " SELECT NVL(SUM(DB_QUANT),0) QUANT, NVL(SUM(DB_QTDLID),0) LIDO "
				cQuery += " FROM "+ RetSqlName("SDB")
				cQuery += " WHERE D_E_L_E_T_ = ' ' "
				cQuery += "   AND DB_FILIAL  = '"+ xFilial("SDB") +"' "
				cQuery += "   AND DB_SERVIC  = '001' "
				cQuery += "   AND DB_ATIVID  = '015' "
				cQuery += "   AND DB_ORIGEM  = 'SC9' "
				cQuery += "   AND DB_STATUS  = '"+ cStatExec +"' "
				cQuery += "   AND DB_DOC     = '"+ aDCF[ 1 ] +"' "
				cQuery += "   AND DB_CLIFOR  = '"+ aDCF[ 2 ] +"' "
				cQuery += "   AND DB_LOJA    = '"+ aDCF[ 3 ] +"' "
				cQuery += "   AND DB_PRODUTO = '"+ aDCF[ 4 ] +"' "
				cQuery += "   AND DB_LOCALIZ = '"+ _aSDBRet[ _nF, 13 ] +"' "
				cQuery += "   AND DB_ESTFLAG = 'GAP' " // Novo campo para controlar quantidade física no estorno (GAP = Gerou apanhe - ou seja - está na mesa/doca)
			
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
				
				If !(cAliasNew)->( Eof() )
					_aSDBRet[ _nF, 03 ] := (cAliasNew)->QUANT
					_aSDBRet[ _nF, 08 ] := (cAliasNew)->LIDO
				EndIf
				(cAliasNew)->( dbCloseArea() )

			EndIf

		EndIf

	Next

Return( _aSDBRet )

// Busca os registros do SDB com o IDDCF atual para saber a quantidade
Static Function GetSDBAtu( aDCF,cAtiv )

	Local _aSDBRet  := {}
	Local cQuery    := ""
	Local cAliasNew := ""
	Local _nPos     := 0
	
	cAliasNew := GetNextAlias()

	cQuery := " SELECT DB_QUANT, DB_QTDLID, R_E_C_N_O_, DB_LOCALIZ "
	cQuery += " FROM "+ RetSqlName("SDB")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += "   AND DB_FILIAL  = '"+ xFilial("SDB") +"' "
	cQuery += "   AND DB_SERVIC  = '001' "
	cQuery += "   AND DB_ESTORNO = ' ' "
	cQuery += "   AND DB_ORIGEM  = 'SC9' "
	cQuery += "   AND DB_ATIVID  = '"+ cAtiv     +"' "
	cQuery += "   AND DB_DOC     = '"+ aDCF[ 1 ] +"' "
	cQuery += "   AND DB_CLIFOR  = '"+ aDCF[ 2 ] +"' "
	cQuery += "   AND DB_LOJA    = '"+ aDCF[ 3 ] +"' "
	cQuery += "   AND DB_PRODUTO = '"+ aDCF[ 4 ] +"' "
	cQuery += "   AND DB_IDDCF   = '"+ aDCF[ 6 ] +"' "
	cQuery += " ORDER BY DB_LOCALIZ ASC, DB_QUANT DESC "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	
	While !(cAliasNew)->( Eof() )
		
		If cAtiv == "022" // Se for atividade de conferência, apenas adiciono no array, pois sempre é apenas um registro
			aAdd( _aSDBRet, { (cAliasNew)->DB_QUANT, (cAliasNew)->DB_QTDLID, (cAliasNew)->R_E_C_N_O_, (cAliasNew)->DB_LOCALIZ } )
		Else

			_nPos := aScan( _aSDBRet, {|o| o[4] == (cAliasNew)->DB_LOCALIZ } )
			
			If _nPos == 0
				aAdd( _aSDBRet, { (cAliasNew)->DB_QUANT, (cAliasNew)->DB_QTDLID, (cAliasNew)->R_E_C_N_O_, (cAliasNew)->DB_LOCALIZ } )
			Else
				// Soma no item já adicionado e exclui o SDB criado, aglutinando a quantidade pelo endereço
				_aSDBRet[ _nPos, 1 ] += (cAliasNew)->DB_QUANT
				_aSDBRet[ _nPos, 2 ] += (cAliasNew)->DB_QTDLID

				SDB->( dbGoTo( (cAliasNew)->R_E_C_N_O_ ) )

				SDB->( RecLock("SDB", .F.) )
					SDB->( dbDelete() )
				SDB->( MsUnLock() )
			EndIf
		
		EndIf
		(cAliasNew)->( dbSkip() )	
	End

	(cAliasNew)->( dbCloseArea() )
	
Return( _aSDBRet )

// Como existe IDDCF anterior, eliminos os registro de DCF, DCR e SDB correspondentes
Static Function LimpaRegs( _cIDAnt, aSDB )
	
	Local cQuery    := ""

	// Elimina registros anteriores na DCF
	cQuery := "UPDATE "+ RetSqlName("DCF")
	cQuery += " SET D_E_L_E_T_ = '*' "
	cQuery += " WHERE DCF_FILIAL = '"+ xFilial("DCF") +"'"
	cQuery += "   AND DCF_ID = '"+ _cIDAnt +"' "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	
	TcSqlExec( cQuery )
	TcSqlExec( 'COMMIT' )
	
	// Elimina registros anteriores na DCR
	cQuery := "UPDATE "+ RetSqlName("DCR")
	cQuery += " SET D_E_L_E_T_ = '*' "
	cQuery += " WHERE DCR_FILIAL = '"+ xFilial("DCR") +"'"
	cQuery += "   AND DCR_IDDCF = '"+ _cIDAnt +"' "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	
	TcSqlExec( cQuery )
	TcSqlExec( 'COMMIT' )
	
	// Elimina registros anteriores na SDB
	/* 22/03/2018 - Jean Rehermann - Não será mais necessário exclui, implementado controle por flag (campo)
	If ValType( aSDB ) == "A" .And. Len( aSDB ) > 0

		cQuery := "UPDATE "+ RetSqlName("SDB")
		cQuery += " SET D_E_L_E_T_ = '*' "
		cQuery += " WHERE DB_FILIAL  = '"+ xFilial("SDB") +"'"
		cQuery += "   AND DB_DOC     = '"+ aSDB[ 1, 10 ] +"' "
		cQuery += "   AND DB_CLIFOR  = '"+ aSDB[ 1, 11 ] +"' "
		cQuery += "   AND DB_LOJA    = '"+ aSDB[ 1, 12 ] +"' "
		cQuery += "   AND DB_IDDCF   = '"+ _cIDAnt +"'"
		cQuery += "   AND DB_ORIGEM  = 'SC9' "
		cQuery += "   AND D_E_L_E_T_ = ' ' "

		TcSqlExec( cQuery )
		TcSqlExec( 'COMMIT' )
	
	EndIf
	*/
Return

// Verifica todos os produtos existentes para os documentos marcados para execução
Static Function VerTodos()
	
	Local cQuery    := ""
	Local cAliasNew := ""
	Local aAllProd  := {}
	
	cAliasNew := GetNextAlias()

	cQuery := " SELECT DB_DOC, DB_CLIFOR, DB_LOJA, DB_PRODUTO, DB_IDDCF "
	cQuery += " FROM "+ RetSqlName("SDB")
	cQuery += " WHERE DB_DOC IN ('"+ __cDocDCF +") AND DB_ORIGEM = 'SC9' " // __cDocDCF é uma varável pública criada no PE DL150BEX
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	cQuery += "    AND DB_SERVIC = '001' "
	cQuery += "    AND DB_FILIAL = '"+ xFilial("SDB") +"' "
	cQuery += "    AND DB_TAREFA = '002' 
	cQuery += "    AND DB_ATIVID = '015' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	
	While !(cAliasNew)->( Eof() )
		
		aAdd( aAllProd, {	(cAliasNew)->DB_DOC,;
							(cAliasNew)->DB_CLIFOR,;
							(cAliasNew)->DB_LOJA,;
							(cAliasNew)->DB_PRODUTO,;
							(cAliasNew)->DB_IDDCF,;
							.F. } )
		
		(cAliasNew)->( dbSkip() )
	End
	
	(cAliasNew)->( dbCloseArea() )
	
Return( aAllProd )

// Marca no array de produtos dos documentos executados aquele que está sendo processado
Static Function ExistMark( aIDDCF )

	Local _nX := 0
	Local _lRet := .F.
	
	For _nX := 1 To Len( _aDocVer )
		If _aDocVer[_nX,1] == aIDDCF[1] .And. _aDocVer[_nX,2] == aIDDCF[2] .And. _aDocVer[_nX,3] == aIDDCF[3] .And. _aDocVer[_nX,4] == aIDDCF[4]
			_aDocVer[ _nX, 6 ] := .T.
			_lRet := .T.
		EndIf
	Next

Return( _lRet )

// Se restou algum produto não marcado no processamento, pode ter sido excluído, então verifico
Static Function VerDelet()

	Local _nX := 0
	
	For _nX := 1 To Len( _aDocVer )
		
		// Se não marcado, verifico se não foi deletado (vejo no pedido)
		If !_aDocVer[ _nX, 6 ]
			
			If !TemPVOk( _aDocVer[ _nX ] ) // preciso verificar se tem PV, pois pode estar executando item que deu problema e ficou pra trás (status 2)
			
				GravaZAR( _aDocVer[ _nX ] ) // Grava ZAR para retirada dos produtos conferidos dos volumes

				LimpaRegs( _aDocVer[ _nX, 5 ] ) // Elimina os registros

				// Gravação da observação de pedido estornado no atendimento para aparecer na tela de separação
				cSUA := Posicione("SC5",1,xFilial("SC5") + AllTrim( _aDocVer[ _nX, 1 ] ),"C5_NUMSUA")
				If !Empty( cSUA )
					cObs := Posicione("SUA",1,xFilial("SUA") + cSUA,"UA_OBSEXP")
					If !"PEDIDO ESTORNADO"$cObs
						cObs := Left( cObs + Iif( !Empty( cObs ), " - ", "" ) +"PEDIDO ESTORNADO", TamSX3("UA_OBSEXP")[1] )
						SUA->(dbSetOrder(1))
						SUA->(dbSeek(xFilial("SUA")+cSUA))
						If Found()
							SUA->( RecLock("SUA",.F.) )
								SUA->UA_OBSEXP := cObs
							SUA->( MsUnLock() )
						EndIf
					EndIf
				EndIf
			
			EndIf

		EndIf
	
	Next
	
	_aDocVer := {}
	
Return

// Se não marcado, verifico se não foi deletado (vejo no pedido)
Static Function TemPVOk( aItDCF )

	Local _lRet     := .T.
	Local cQuery    := ""
	Local cAliasNew := ""
	
	cAliasNew := GetNextAlias()

	cQuery := " SELECT C9_STSERV "
	cQuery += " FROM "+ RetSqlName("SC9")
	cQuery += " WHERE D_E_L_E_T_  = ' ' "
	cQuery += "    AND C9_FILIAL  = '"+ xFilial("SC9") +"' "
	cQuery += "    AND C9_PEDIDO  = '"+ aItDCF[ 1 ] +"' "
	cQuery += "    AND C9_CLIENTE = '"+ aItDCF[ 2 ] +"' "
	cQuery += "    AND C9_LOJA    = '"+ aItDCF[ 3 ] +"' "
	cQuery += "    AND C9_PRODUTO = '"+ aItDCF[ 4 ] +"' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	
	_lRet := !(cAliasNew)->( Eof() )
	
	(cAliasNew)->( dbCloseArea() )

Return( _lRet )

// Se item foi eliminado, preciso verificar se tem quantidade conferida para ser retirada dos volumes
Static Function GravaZAR( _aRemove )

	Local _aSDBAnt := {}
	Local _nY      := 0

	// Busca os últimos registros do SDB com este IDDCF anterior
	_aSDBAnt := GetSDBAnt( _aRemove[5], { _aRemove[1], _aRemove[2], _aRemove[3], _aRemove[4], DCF->DCF_QUANT } ) 

	For _nY := 1 To Len( _aSDBAnt )
		
		// Jean Rehermann - Solutio IT - 04/12/2018 - Grava registro no SDB referente exclusão de item do PV após estorno
		If _aSDBAnt[ _nY, 5 ] == "015" // Atividade de Separação
			SDB->( RecLock("SDB",.T.) )
				SDB->DB_FILIAL  := xFilial("SDB")
				SDB->DB_PRODUTO := _aSDBAnt[ _nY, 02 ]
				SDB->DB_QUANT   := _aSDBAnt[ _nY, 03 ]
				SDB->DB_TAREFA  := _aSDBAnt[ _nY, 04 ]
				SDB->DB_ATIVID  := _aSDBAnt[ _nY, 05 ]
				SDB->DB_IDDCF   := _aSDBAnt[ _nY, 07 ]
				SDB->DB_QTDLID  := _aSDBAnt[ _nY, 08 ]
				SDB->DB_DOC     := _aSDBAnt[ _nY, 10 ]
				SDB->DB_CLIFOR  := _aSDBAnt[ _nY, 11 ]
				SDB->DB_LOJA    := _aSDBAnt[ _nY, 12 ]
				SDB->DB_ORIGEM  := "DEL"
				SDB->DB_DATA    := dDataBase
				SDB->DB_TIPO    := "X"
				SDB->DB_SERVIC  := "XXX"
				SDB->DB_ATUEST  := "N"
				SDB->DB_STATUS  := "1"
				SDB->DB_ESTORNO := "S" // Como estornado para evitar qualquer problema com reprocessamentos
			SDB->( MsUnLock() )
		EndIf
		
		If _aSDBAnt[ _nY, 5 ] == "022" // Atividade de Conferência
		
			SDB->( RecLock("SDB",.T.) )
				SDB->DB_FILIAL  := xFilial("SDB")
				SDB->DB_PRODUTO := _aSDBAnt[ _nY, 02 ]
				SDB->DB_QUANT   := _aSDBAnt[ _nY, 03 ]
				SDB->DB_TAREFA  := _aSDBAnt[ _nY, 04 ]
				SDB->DB_ATIVID  := _aSDBAnt[ _nY, 05 ]
				SDB->DB_IDDCF   := _aSDBAnt[ _nY, 07 ]
				SDB->DB_QTDLID  := _aSDBAnt[ _nY, 08 ]
				SDB->DB_DOC     := _aSDBAnt[ _nY, 10 ]
				SDB->DB_CLIFOR  := _aSDBAnt[ _nY, 11 ]
				SDB->DB_LOJA    := _aSDBAnt[ _nY, 12 ]
				SDB->DB_ORIGEM  := "DEL"
				SDB->DB_DATA    := dDataBase
				SDB->DB_TIPO    := "X"
				SDB->DB_SERVIC  := "XXX"
				SDB->DB_ATUEST  := "N"
				SDB->DB_STATUS  := "1"
				SDB->DB_ESTORNO := "S" // Como estornado para evitar qualquer problema com reprocessamentos
			SDB->( MsUnLock() )

			If !ZAR->( dbSeek( xFilial("ZAR") + _aRemove[1] + _aRemove[4] ) )
				ZAR->( RecLock("ZAR",.T.) )
					ZAR->ZAR_FILIAL := xFilial("ZAR")
					ZAR->ZAR_PEDIDO := _aRemove[1]
					ZAR->ZAR_PRODUT := _aRemove[4]
					ZAR->ZAR_QTDANT := _aSDBAnt[ _nY, 03 ]  // Quantidade anterior
					ZAR->ZAR_QTDATU := 0                    // Quantidade atual
					ZAR->ZAR_CNFANT := _aSDBAnt[ _nY, 08 ]  // Conferido anterior
					ZAR->ZAR_QTDRET := _aSDBAnt[ _nY, 08 ]  // Quantidade a retirar
					ZAR->ZAR_RECHUM := _aSDBAnt[ _nY, 09 ]  // Recurso Humano
					ZAR->ZAR_LOCALI := _aSDBAnt[ _nY, 13 ]  // Mesa de conferência
				ZAR->( MsUnLock() )

				// Faço ajuste no ZCS e ZCT
				ZCS->( dbSetOrder(1) ) //ZCS_FILIAL+ZCS_CARGA+ZCS_PEDIDO
				If ZCS->( MsSeek( xFilial("ZCS") + Space( Len( ZCS->ZCS_CARGA ) ) + AllTrim( _aRemove[1] ) ) )
					
					ZCS->( RecLock("ZCS",.F.) )
						ZCS->ZCS_QTSEPA -= _aSDBAnt[ _nY, 03 ]
						ZCS->ZCS_QTEMBA -= _aSDBAnt[ _nY, 03 ]
					ZCS->( MsUnLock() )
					
					ZCT->( dbSetOrder(1) ) //ZCT_FILIAL+ZCT_CARGA+ZCT_PEDIDO+ZCT_CODPRO
					If ZCT->( MsSeek( xFilial("ZCT") + Space( Len( ZCS->ZCS_CARGA ) ) + AllTrim( _aRemove[1] ) + _aRemove[4] ) )
						ZCT->( Reclock('ZCT',.F.) )
							ZCT->( dbDelete() )
						ZCT->( MsUnLock() )
					EndIf
					
				EndIf

			EndIf
			
		EndIf
	Next
	
Return

// Função que atualiza o IDDCF dos registros no ZCV quando aumento a quantidade de um item no estorno
Static Function AtuDcfZcv( cIdAnt, cIdAtu )
	
	Local cQuery := ""
	
	cQuery := "UPDATE "+ RetSqlName("ZCV")
	cQuery += " SET ZCV_IDDCF = '"+ cIdAtu +"' "
	cQuery += " WHERE ZCV_FILIAL = '"+ xFilial("ZCV") +"'"
	cQuery += "   AND ZCV_IDDCF = '"+ cIdAnt +"' "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	
	TcSqlExec( cQuery )
	TcSqlExec( 'COMMIT' )
	
Return

// Função criada para reativar SDB estornado que foi deletado (continua estornado, porém não pode ficar deletado)
// Isso porque quando ocorre um problema na execução (sem saldo, por exemplo) eu vou precisar destes registros (SDB anterior) para fazer os cálculos
/* 22/03/2018 - Desabilitado por não estar mais deletando SDB, implementado melhoria que controla por flag (campo)
Static Function SDBRecall( cIDAnt, aSDB, cAtiv )
	
	Local cQuery    := ""
	
	// Elimina registros anteriores na SDB
	If ValType( aSDB ) == "A" .And. Len( aSDB ) > 0

		cQuery := "UPDATE "+ RetSqlName("SDB")
		cQuery += " SET D_E_L_E_T_ = ' ' "
		cQuery += " WHERE DB_FILIAL  = '"+ xFilial("SDB") +"'"
		cQuery += "   AND DB_DOC     = '"+ aSDB[ 1, 10 ] +"' "
		cQuery += "   AND DB_CLIFOR  = '"+ aSDB[ 1, 11 ] +"' "
		cQuery += "   AND DB_LOJA    = '"+ aSDB[ 1, 12 ] +"' "
		cQuery += "   AND DB_IDDCF   = '"+ cIDAnt +"'"
		cQuery += "   AND DB_ATIVID  = '"+ cAtiv  +"'"
		cQuery += "   AND DB_ORIGEM  = 'SC9' "
		cQuery += "   AND D_E_L_E_T_ = '*' "

		TcSqlExec( cQuery )
		TcSqlExec( 'COMMIT' )
	
	EndIf

Return
*/

// Função que fará a movimentação de estoque do endereço diretamente para a DOCA ou MESA quando item estornado não sofrer alterações
Static Function ConWmsEst( aSDBAtu, cDCFAnt, cEndDes )// [1] SDB atual [2] IDDCF Anterior [3] Endereço da MESA

	Local _nX       := 0
	Local _nRecSDB  := 0
	Local cQuery    := ""
	Local cAliasQry := ""
	Local cDCFAtu   := ""
	
	Private aParam150  := Array(34)
	
	dbSelectArea("SDB")

	_nRecSDB := aSDBAtu[ 3 ]
	
	SDB->( DbGoTop() )
	SDB->( dbGoTo( _nRecSDB ) )
	
	If !SDB->( Eof() )
		
		cDCFAtu   := SDB->DB_IDDCF
		
		cQuery := "SELECT DCF.R_E_C_N_O_ DCFRECNO "
		cQuery += "  FROM "+ RetSqlName('DCF') +" DCF "
		cQuery += " WHERE DCF.DCF_FILIAL = '"+ xFilial("DCF") +"'"
		cQuery += "   AND DCF.DCF_NUMSEQ = '"+ SDB->DB_NUMSEQ +"'"
		cQuery += "   AND DCF.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery( cQuery )
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),(cAliasQry := GetNextAlias()),.F.,.T.)
		If (cAliasQry)->( !Eof() )
			DCF->( dbGoTo( (cAliasQry)->DCFRECNO ) ) //Posicionar no DCF correspondente (obrigatório)
		EndIf
		(cAliasQry)->( dbCloseArea() )

		aParam150[01]  := SDB->DB_PRODUTO //-- Produto
		aParam150[02]  := SDB->DB_LOCAL   //-- Almoxarifado
		aParam150[03]  := SDB->DB_DOC     //-- Documento
		aParam150[04]  := SDB->DB_SERIE   //-- Serie
		aParam150[05]  := DCF->DCF_NUMSEQ
		aParam150[06]  := SDB->DB_QUANT   //-- Saldo do produto em estoque
		aParam150[07]  := SDB->DB_DATA    //-- Data da Movimentacao
		aParam150[08]  := Time()          //-- Hora da Movimentacao
		aParam150[09]  := SDB->DB_SERVIC  //-- Servico
		aParam150[10]  := SDB->DB_TAREFA  //-- Tarefa
		aParam150[11]  := SDB->DB_ATIVID  //-- Atividade
		aParam150[12]  := SDB->DB_CLIFOR  //-- Cliente/Fornecedor
		aParam150[13]  := SDB->DB_LOJA    //-- Loja
		aParam150[14]  := ''              //-- Tipo da Nota Fiscal
		aParam150[15]  := '01'            //-- Item da Nota Fiscal
		aParam150[16]  := ''              //-- Tipo de Movimentacao
		aParam150[17]  := SDB->DB_ORIGEM  //-- Origem de Movimentacao
		aParam150[18]  := SDB->DB_LOTECTL //-- Lote
		aParam150[19]  := SDB->DB_NUMLOTE //-- Sub-Lote
		aParam150[20]  := SDB->DB_LOCALIZ //-- Endereco
		aParam150[21]  := SDB->DB_ESTFIS  //-- Estrutura Fisica
		aParam150[22]  := 0               //-- Regra de Apanhe (1=LOTE/2=NUMERO DE SERIE/3=DATA.SEQ.ABAST/4=DATA)
		aParam150[23]  := SDB->DB_CARGA   //-- Carga
		aParam150[24]  := SDB->DB_UNITIZ  //-- Nr. do Pallet
		aParam150[25]  := SDB->DB_LOCAL   //-- Centro de Distribuicao Destino
		aParam150[26]  := Iif( IsQtdCnf(SDB->DB_IDDCF), DCF->DCF_ENDER, cEndDes )  //-- Endereco Destino (DOCA se já foi conferido ou MESA se não foi)
		aParam150[27]  := Posicione('SBE', 1, xFilial('SBE') + DCF->DCF_LOCAL + aParam150[26],'BE_ESTFIS') //-- Estrutura Fisica Destino
		aParam150[28]  := SDB->DB_ORDTARE //-- Ordem da Tarefa
		aParam150[29]  := SDB->DB_ORDATIV //-- Ordem da Atividade
		aParam150[30]  := SDB->DB_RHFUNC  //-- Funcao do Recurso Humano
		aParam150[31]  := SDB->DB_RECFIS  //-- Recurso Fisico
		aParam150[32]  := SDB->DB_IDDCF   //-- Identificador do DCF DCF_ID
		aParam150[34]  := SDB->DB_IDMOVTO //-- Identificador exclusivo do Movimento no SDB

		Begin Transaction
		
			_lRet := WmsMovEst( aParam150 ) // Realiza a movimentação do saldo para o endereço DOCA ou MESA
			
			If _lRet
				DLVStAuto( aParam150[09], aParam150[28], aParam150[10] ) // Realiza a atualização do status no SDB com a movimentação de estoque automática

				// Atualiza o IDDCF das movimentações para a MESA e da MESA, pois não foram estornadas
				cQuery := "UPDATE "+ RetSqlName("SDB")
				cQuery += "SET DB_IDDCF = '"+ cDCFAtu +"', DB_QUANT = "+ cValToChar( SDB->DB_QUANT )
				cQuery += " WHERE D_E_L_E_T_ = ' ' "
				cQuery += "   AND DB_FILIAL  = '"+ xFilial("SDB")  +"' "
				cQuery += "   AND DB_ESTORNO = ' ' "
				cQuery += "   AND DB_DOC     = '"+ SDB->DB_DOC     +"' "
				cQuery += "   AND DB_SERIE   = '"+ SDB->DB_SERIE   +"' "
				cQuery += "   AND DB_PRODUTO = '"+ SDB->DB_PRODUTO +"' "
				cQuery += "   AND DB_LOCAL   = '"+ SDB->DB_LOCAL   +"' "
				cQuery += "   AND DB_ORIGEM  = 'SD3' "
				cQuery += "   AND DB_IDDCF   = '"+ cDCFAnt +"' "
		
				TcSqlExec( cQuery )
				TcSqlExec( 'COMMIT' )

				// Grava o empenho do SDB na DOCA para faturamento ou na MESA para a separação
				WmsSBFEmp( SDB->DB_PRODUTO, SDB->DB_LOCAL, SDB->DB_QUANT, aParam150[26] )
			
			EndIf
	    
			If !_lRet
				DisarmTransaction()
			EndIf
		
		End Transaction

	EndIf

Return( _lRet )

// Função que verifica se item que foi estornado mas não sofreu alterações já foi conferido ou não, serve para definir para onde vai o saldo
// após o ajuste, se vai para a mesa caso não tenha sido conferido, ou se vai para doca caso já tenha sido conferido
Static Function IsQtdCnf( cDcfAt ) // IDDCF atual

	Local _lConf := .F.
	Local _cQuery := ""
	Local _cAlias := ""
	Local _aArea  := GetArea()
	
	_cQuery := "SELECT DB_STATUS, DB_QUANT, DB_QTDLID "
	_cQuery += " FROM "+ RetSqlName("SDB")
	_cQuery += " WHERE DB_FILIAL  = '"+ xFilial("SDB") +"' "
	_cQuery += "   AND DB_IDDCF   = '"+ cDcfAt +"' "
	_cQuery += "   AND DB_ATIVID  = '022' "
	_cQuery += "   AND DB_ESTORNO = ' ' "
	_cQuery += "   AND D_E_L_E_T_ = ' '"

	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	
	If !(_cAlias)->( EoF() )
		_lConf := ( (_cAlias)->DB_STATUS == '1' .Or. (_cAlias)->DB_QUANT == (_cAlias)->DB_QTDLID )
	Endif
	
	(_cAlias)->( dbCloseArea() )
	
	RestArea( _aArea )

Return( _lConf )

// Grava o empenho do SDB na DOCA para faturamento ou na MESA para a separação
Static Function WmsSBFEmp( cCodPro, cLocDes, nQtdEmp, cEndDes )

	Local _aArea := GetArea()

	dbSelectArea("SBF")
	dbSetOrder(1)
	
	If dbSeek( xFilial("SBF") + cLocDes + PadR( cEndDes, Len( SDB->DB_LOCALIZ ) ) + cCodPro )
		RecLock("SBF",.F.)
			SBF->BF_EMPENHO += nQtdEmp
		MsUnLock()
	EndIf
	
	RestArea( _aArea )
	
Return
