#INCLUDE 'PROTHEUS.CH'
User Function DLENDAP( )
//-- Ponto de entrada após selecionar um endereço.
//-- Ponto de Entrada: DLENDAP
//-- Para confirmar a escolha de um endereço de apanhe
//-- Parametros:
//-- PARAMIXB[1] = Armazem Origem
//-- PARAMIXB[2] = Endereco Origem
//-- PARAMIXB[3] = Estrutura Fisica Origem
//-- PARAMIXB[4] = Codigo do Produto
//-- PARAMIXB[5] = Lote
//-- PARAMIXB[6] = Sub-Lote
//-- PARAMIXB[7] = Qtd Apanhe

//-- Retorno (Logico):
//-- .F. - Para Descartar o endereco de Apanhe
//-- .T. - Para Confirmar o endereco de Apanhe

//Opção 02 (Array):
//xRetPE[1] - Lógico
//Indicador se deve utilizar este endereço para efetuar a separação.
//Caso o retorno seja falso, o endereço é descartado.
//xRetPE[2] - Numérico
//Quantidade a ser utilizada para a separação.

Local aRet      := {}
Local aAreaSBF  := GetArea("SBF")
Local _nQtdEmb  := 1
Local _cCampo   := 'B5_EAN14'
Local _n        := 0
Local _nQtdRet  := 0
Local _nSldEmb  := 0
Local _lLoc01   := .F.
Local _lTemPick := .F.
Local _lTemPulm := .F.
Local _lRadioF  := ( SuperGetMV('MV_RADIOF', .F., 'N') == 'S' ) // Jean Rehermann - Solutio IT - 26/12/2018 - Não executar quando RF OFF
Local _nQtdRetPul := 0

If !_lRadioF
	Return( .T. )
EndIf

//1 - Busca a quantidade por embalagem
DbSelectArea("SB5")
DbSetOrder(1)
DbSeek( xFilial("SB5") + PARAMIXB[4] )
//1.a Testa se é Granel
IF !CBProdUnit(PARAMIXB[4])
	// se é granel (etiqueta interna de quantidade)
	
	_nQtdEmb := 1
	
	IF DCF->DCF_SERVIC == "001"  // AQUI ESTA POSICIONADO O DCF...
		
		// seguinte...
		// Caso oproduto só possua endereço de pulmao... vai separar a quantidade total aqui..
		// Caso o produto possua PULMAO +PICKING ...precisao varrer o endereço e ver se temos etiquetas com caixas fechadas e pegar os multiplos dessas caixas ....
		//                                          e deixar o fracionado para o Picking
		
		_nTpEstr   := DLTipoEnd(PARAMIXB[3])
		// Este endereço tem Saldo ?
		_nSaldoSBF := WmsSaldoSBF(PARAMIXB[1],PARAMIXB[2],PARAMIXB[4],/*cNumSerie*/,/*cLoteCtl*/,/*cNumLote*/,.T.,.T.,.T.,.F.,'2',.T.)
		
		//procuro Caixas fechas quando não é picking
		IF _nTpEstr <> 2  // Nao seja Picking
			
			//Busco se tem algum endereço de Picking
			cAliasNew := GetNextAlias()
			cQuery := " SELECT BF_FILIAL,BF_LOCAL,BF_LOCALIZ,BF_ESTFIS,BF_PRODUTO,SUM(BF_QUANT) BF_QUANT,SUM(BF_QTSEGUM) BF_QTSEGUM"
			cQuery += " FROM "+RetSqlName('SBF')+" SBF, "
			cQuery += " "+RetSqlName('SBE')+" SBE, "
			cQuery += " "+RetSqlName('DC8')+" DC8 "
			cQuery += " WHERE "
			cQuery += " BF_FILIAL          = '"+xFilial("SBF")+"'"
			cQuery += " AND BF_LOCAL       = '"+PARAMIXB[1]+"'"
			cQuery += " AND BF_PRODUTO     = '"+PARAMIXB[4]+"'"
			cQuery += " AND SBF.D_E_L_E_T_ = ' '"
			cQuery += " AND BE_FILIAL      = '"+xFilial("SBE")+"'"
			cQuery += " AND BE_LOCAL       = '"+PARAMIXB[1]+"'"
			cQuery += " AND BE_LOCALIZ     = BF_LOCALIZ"
			cQuery += " AND BE_ESTFIS      = BF_ESTFIS"
			cQuery += " AND SBE.D_E_L_E_T_ = ' '"
			cQuery += " AND DC8_FILIAL     = '"+xFilial("DC8")+"'"
			cQuery += " AND DC8_CODEST     = BF_ESTFIS"
			cQuery += " AND DC8.D_E_L_E_T_ = ' '"
			// Nao bloqueado... Tipo Estrutura = Picking
			cQuery += " AND (BE_STATUS <> '3' AND DC8_TPESTR = '2' )
			cQuery += " GROUP BY BF_FILIAL,BF_LOCAL,BF_LOCALIZ,BF_ESTFIS,BF_PRODUTO"
			
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
			
			_nTot := 0
			
			DbSelectArea(cAliasNew)
			Do While (cAliasNew)->(!Eof())
				
				_nTot += (cAliasNew)->BF_QUANT
				
				DbSelectArea(cAliasNew)
				DbSkip()
				
			Enddo
			
			_lTemPick := ( _nTot > 0 )
			
			IF _lTemPick
				
				// Se temSaldo no endereço vamos ver quantas caixas temos neste endereço... pois vamos pegar somente caixas fechadas..
				// deixando o fracionado para o picking
				IF _nSaldoSBF > 0
					/* // Jean Rehermann = Solutio IT - 29/12/2017 - Não deve mais procurar pelas caixas
					DbSelectArea("CB0")
					DbSetorder(4) //CB0_FILIAL+CB0_TIPO+CB0_LOCAL+CB0_CODPRO
					
					DbSeek(xFilial("CB0")+"01"+PARAMIXB[1]+PARAMIXB[4])
					
					_nQtdRet := 0
					
					If Found()
					
						Do While xFilial("CB0")+"01"+PARAMIXB[1]+PARAMIXB[4] == CB0->(CB0_FILIAL+CB0_TIPO+CB0_LOCAL+CB0_CODPRO)
							
							//procuro Caixas fechadas quando não é picking
							// Caixa fechada e com endereço igual ao que estamos validando e sem o flag de apanhe (o flag CB0_IDMVTO será limpo na finalização)
							IF CB0->CB0_QTDE > 0 .and. PARAMIXB[2] == CB0->CB0_LOCALI .And. Empty( CB0->CB0_IDMVTO ) 
								
								IF ( _nQtdRet + CB0->CB0_QTDE ) >  PARAMIXB[7] // caso o acumulado com esta etiqueta supere a quantidade de endereçamento
									Exit
								ELSE
									_lLoc01 := .t.
									_nQtdRet += CB0->CB0_QTDE
								ENDIF
							Endif
							
							DbSelectArea("CB0")
							DbSkip()
							
						Enddo
					
					Else
					*/
					// Se não tem caixa fechada, é picking e tem saldo, pega a quantidade do pedido
						_lLoc01 := .t.
						_nQtdRet += IIF(_nSaldoSBF >= PARAMIXB[7],PARAMIXB[7],_nSaldoSBF)
					
					/*EndIf*/
				Endif // saldo SBF
			Else // lTemPick
				
				// é pulmão e nao tem endereço de picking ... pega tudo aqui
				_lLoc01 := .t.
				_nQtdRet += IIF(_nSaldoSBF >= PARAMIXB[7],PARAMIXB[7],_nSaldoSBF)
				
			Endif 
		
		Elseif _nTpEstr == 2 //picking
            
			//Busco se tem algum endereço de Pulmao
			cAliasNew := GetNextAlias()
			cQuery := " SELECT BF_FILIAL,BF_LOCAL,BF_LOCALIZ,BF_ESTFIS,BF_PRODUTO,SUM(BF_QUANT) BF_QUANT,SUM(BF_QTSEGUM) BF_QTSEGUM"
			cQuery += " FROM "+RetSqlName('SBF')+" SBF, "
			cQuery += " "+RetSqlName('SBE')+" SBE, "
			cQuery += " "+RetSqlName('DC8')+" DC8 "
			cQuery += " WHERE "
			cQuery += " BF_FILIAL          = '"+xFilial("SBF")+"'"
			cQuery += " AND BF_LOCAL       = '"+PARAMIXB[1]+"'"
			cQuery += " AND BF_PRODUTO     = '"+PARAMIXB[4]+"'"
			cQuery += " AND SBF.D_E_L_E_T_ = ' '"
			cQuery += " AND BE_FILIAL      = '"+xFilial("SBE")+"'"
			cQuery += " AND BE_LOCAL       = '"+PARAMIXB[1]+"'"
			cQuery += " AND BE_LOCALIZ     = BF_LOCALIZ"
			cQuery += " AND BE_ESTFIS      = BF_ESTFIS"
			cQuery += " AND SBE.D_E_L_E_T_ = ' '"
			cQuery += " AND DC8_FILIAL     = '"+xFilial("DC8")+"'"
			cQuery += " AND DC8_CODEST     = BF_ESTFIS"
			cQuery += " AND DC8.D_E_L_E_T_ = ' '"
			// Nao bloqueado... Tipo Estrutura = Picking
			cQuery += " AND (BE_STATUS <> '3' AND DC8_TPESTR = '1' )
			cQuery += " GROUP BY BF_FILIAL,BF_LOCAL,BF_LOCALIZ,BF_ESTFIS,BF_PRODUTO"
			
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
			
			_nTot := 0
			
			DbSelectArea(cAliasNew)
			Do While (cAliasNew)->(!Eof())
				
				_nTot += (cAliasNew)->BF_QUANT
				
				DbSelectArea(cAliasNew)
				DbSkip()
				
			Enddo
			
			_lTemPulm := ( _nTot > 0 )
			
			IF _lTemPulm
				/* // Não deve mais separar pelas caixas
				// Se temSaldo no endereço vamos ver quantas caixas temos neste endereço... pois vamos pegar somente caixas fechadas..
				// deixando o fracionado para o picking
				IF _nSaldoSBF > 0

					DbSelectArea("CB0")
					DbSetorder(4) //CB0_FILIAL+CB0_TIPO+CB0_LOCAL+CB0_CODPRO
					
					DbSeek(xFilial("CB0")+"01"+PARAMIXB[1]+PARAMIXB[4])  
					
					_nQtdRetPul := 0
					
					Do While xFilial("CB0")+"01"+PARAMIXB[1]+PARAMIXB[4] == CB0->(CB0_FILIAL+CB0_TIPO+CB0_LOCAL+CB0_CODPRO)
						
						// Caixa fechada e com endereço igual ao que estamos validando e sem o flag de apanhe (o flag CB0_IDMVTO será limpo na finalização)
						IF CB0->CB0_QTDE > 0 .and. PARAMIXB[2] == CB0->CB0_LOCALI .And. Empty( CB0->CB0_IDMVTO ) 
							
							IF ( _nQtdRetPul + CB0->CB0_QTDE ) >  PARAMIXB[7] // caso o acumulado com esta etiqueta supere a quantidade de endereçamento
								Exit
							ELSE
								_lLoc01 := .t.
								_nQtdRetPul += CB0->CB0_QTDE
							ENDIF
						Endif
						
						DbSelectArea("CB0")
						DbSkip()
						
					Enddo
					
				Endif // saldo SBF
                */
                //Calculo o Fracionado a pegar no Pickinkg 
                _lLoc01 := .t.
                _nQtdRet :=  PARAMIXB[7] - _nQtdRetPul
            
            Else // lTemPulm
                //Não tem pulmao só picking
			    _lLoc01 := .t.
			    _nQtdRet += IIF(_nSaldoSBF >= PARAMIXB[7],PARAMIXB[7],_nSaldoSBF)
            Endif
		
		Endif
	ELSE
		//OUTROS SERVICOS
		_lLoc01  := .T.
	ENDIF
	
Else
	//1.b ... ver se tem EAN14
	For _n := 1 to 8
		_cCampo  += STR(_n,1,0)
		_nQtdEAN := SB5->(&_cCampo)
		IF _nQtdEAN > 0
			_nQtdEmb := _nQtdEAN
			Exit  // para sair
		ELSE
			_cCampo  := 'B5_EAN14'
		ENDIF
	Next _n
	
	// Calcula quantas embalagens fechadas vou precisar
	_nSldEmb := INT(PARAMIXB[7]/_nQtdEmb)
	//2 - Localiza Tipo Estrutura
	DbSelectArea("DC8")
	DbSetOrder(1)
	DbSeek(xFilial("DC8")+PARAMIXB[3])
	_cTipoStr := DC8->DC8_TPESTR
	//1=Pulmao ; 2=Picking ; 3=Cross-Docking ; 4=Blocado ; 5=Box/Doca ; 6 = Blocado/Fracionado
	
	//3 - Localizar Endereço
	DbSelectArea("SBF")
	DbSetOrder(5)   //BF_FILIAL+BF_PRODUTO+BF_ESTFIS+BF_LOCALIZ
	DbSeek( xFilial("SBF")+PARAMIXB[4]+PARAMIXB[3]+PARAMIXB[2] )
	_lLoc01 := .f.
	
	/// preciso ordenar se a quantidae de embalagens fechadas for igual a zero... ou seja precisa ir direto para o picking...
	// é menor que uma caixa fechada?
	//   -->SIM é menor : o endereço é de picking?
	//			  --> SIM :o produto tem saldo no Picking?
	//                     --> SIM : Só aceita endereço de Picking
	//                     --> NAO : Aceita endereço de Pulmão
	//            --> NAO : Então nao aceita retorna .f.
	//   -->NAO é igual ou maior: o endereço é de pulmão?
	//			  --> SIM : o produto tem saldo?
	//                     --> SIM :
	//
	// enquanto for o mesmo produto, na mesma estrutura fisica e mesma localização
	Do While  !EOF() .AND.  xFilial("SBF")+PARAMIXB[4]+PARAMIXB[3]+PARAMIXB[2] == SBF->(BF_FILIAL+BF_PRODUTO+BF_ESTFIS+BF_LOCALIZ)
		_nSaldoSBF := SBF->BF_QUANT - SBF->BF_EMPENHO
		// Sempre trato primeiro o local 01, para demandar primeiros estes saldos....
		IF SBF->BF_LOCAL == '01'
			//Se o produto possuir embalagens fechadas,
			//existir saldo para atender pelo menos uma embalagem fechada e
			//a quantidade a ser separada precisa ser maior ou igual a uma embalagem fechada
			IF _nQtdEmb > 1 .and. _nSaldoSBF >= INT(PARAMIXB[7]/_nQtdEmb) .and. PARAMIXB[7] >= _nQtdEmb
				//Calculo multiplos da embalagem
				_nQtdRet := INT(PARAMIXB[7]/_nQtdEmb) * _nQtdEmb
				_lLoc01 := .t.
			Else
				//Caso o saldo em estoque não tenha nem a quantidade de uma caixa fechada
				IF _nSaldoSBF < PARAMIXB[7]
					_lLoc01 := .t.
					_nQtdRet := _nSaldoSBF
				ELSE
					_lLoc01 := .t.
					_nQtdRet := PARAMIXB[7]
				ENDIF
			Endif
		ENDIF
		SBF->( DbSkip() )
	Enddo
	
	IF !(_lLoc01) //BUSCA NO 02 SOMENTE SE NÃO ACHAR NO 01
		DbSeek( xFilial("SBF")+PARAMIXB[4]+PARAMIXB[3]+PARAMIXB[2] )
		_lLoc01 := .f.
		Do While !EOF() .AND. xFilial("SBF")+PARAMIXB[4]+PARAMIXB[3]+PARAMIXB[2] == SBF->(BF_FILIAL+BF_PRODUTO+BF_ESTFIS+BF_LOCALIZ)
			IF SBF->BF_LOCAL == '02'
				//Se o produto possuir embalagens fechadas,
				//existir saldo para atender pelo menos uma embalagem fechada e
				//a quantidade a ser separada precisa ser maior ou igual a uma embalagem fechada
				IF _nQtdEmb > 1 .and. _nSaldoSBF >= INT(PARAMIXB[7]/_nQtdEmb) .and. PARAMIXB[7] >= _nQtdEmb
					//Calculo multiplos da embalagem
					_nQtdRet := INT(_nsaldoSBF/_nQtdEmb) * _nQtdEmb
					_lLoc01 := .t.
				Else
					//Caso o saldo em estoque não tenha nem a quantidade de uma caixa fechada
					IF _nSaldoSBF < PARAMIXB[7]
						_lLoc01 := .t.
						_nQtdRet := _nSaldoSBF
					ELSE
						_lLoc01 := .t.
						_nQtdRet := PARAMIXB[7]
					ENDIF
				Endif
			ENDIF
			SBF->( DbSkip() )
		Enddo
	ENDIF
	
Endif //Fim do controle do EAN14

//Segurança
IF _nQtdRet == 0 // Caso a quantidade sejamenor que a embalagem
	_nQtdRet := PARAMIXB[7]
ENDIF

aadd(aRet,_lLoc01)
aadd(aRet,_nQtdRet)

RestArea(aAreaSBF)
Return aRet




