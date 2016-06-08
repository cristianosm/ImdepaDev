#Include "Totvs.ch"
#Include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ U_TKGRPED       ³Autor  ³Microsiga        ³ Data ³ 26/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a validacao dos dados digitados na tela de atendimento  ³±±
±±³          ³ de televendas do modulo Call Center, apos o usuario clicar  ³±±
±±³          ³ no botao <Ok>.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER						                       	     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

*********************************************************************
User Function TKGRPED()
*********************************************************************

	Local aArea   := GetArea(),;
		aAreaSZE      := SZE->( GetArea() ),;
		aAreaSB2      := SB2->( GetArea() ),;
		lRet          := .T.,;
		cCodTrf       := GetMV('MV_IMDEPA'),;
		nQtd,;
		nQtdAux,;
		cProd,;
		cPlItem,;
		cFilTran,;
		nPos       := 0,;
		aSldPlan   := Array(0)
	Local xy:=0
	Local i := 1
	Local nStart := 1
	Local cMens := " "
	Local nQtdispo := 0
	Local aProdXQtd_no_SUB := {}
	Local cNumSC5    := SPACE(6)
	Local cOperaWms  := GetMv("MV_WMSTPAP",,"F")
	Local cNome := ""
	Local lOper := .T.

//|NOME: CRISTIANO MACHADO //|DATA: 30/04/2006
//|MOTIVO: CRIACAO DE PARAMETRO PARA CAMPOS QUE SAO OBRIGATORIOS NO CADASTRO DE CLIENTES
//|		  MAS NÃO PRECISAM SER PREENCHIDO ENQUANTO CLIENTE FOR UM PROSPECT.
//|CHAMADO: AAZO2V
	Private cSa1nSus := Getmv("MV_SA1NSUS")

	Private cImdepa 	:= GetMV('MV_IMDEPA')
	Private CPRODUTO

//----------------------Posiciona no arquivo de estoques , chamado AAZQLF
	SB2->(dbSetOrder(1))


// Posiciona no SUA para buscar o numero do pedido
	DbSelectarea("SUA")
	DbSetorder(1)
	IF DbSeek(xFilial("SUA")+M->UA_NUM)
		cNumSC5 := SUA->UA_NUMSC5
	ENDIF


*=================================================================================*
//Não Permite Alterar Pedido que já foi impresso em filiais que não possuem o WMS *
//Nas que possuem o WMS já tratado pela OS. - Edivaldo Gonçalves Cordeiro 06/09/07*
*=================================================================================*

	IF cOperaWms =='F' .AND. PedidoImp(xFilial("SC9"),cNumSC5)
		__Podesair := "S" //Permite sair/limpar pois não permitirá gravar
		If Type("lTk271Auto") == "U" .Or. !lTk271Auto
			IW_MSGBOX("Atendimento número "+M->UA_NUM+" não pode ser alterado pois o pedido já foi impresso. Para iniciar um novo atendimento, clique em 'Limpa o Atendimento' ou tecle <F5>.",'Atenção','ALERT')
		EndIf
	Return .F.
	ENDIF

//  testa o numero do atendimento original (esta validacao eh temporaria, para tentar descobrir um possivel erro)
	If M->UA_NUM == M->UA_NUMORIG
		If Type("lTk271Auto") == "U" .Or. !lTk271Auto
			IW_MSGBOX("Número do atendimento = Número do atendimento original. Favor entrar em contato com o Depto. de Tecnologia Imdepa! e informe o numero de atendimento "+M->UA_NUM+".",'Atenção','ALERT')
		Else
			ConOut("Número do atendimento = Número do atendimento original. Favor entrar em contato com o Depto. de Tecnologia Imdepa e informe o numero de atendimento "+M->UA_NUM+".")
		EndIf
	Endif

// Jeferson.
// Validacao para nao ocorrer a confirmacao de um atendimento
// sem que o passe pelo campo quantidade quando o item for novo.
	If Empty(M->UA_PEDWEB)
		For xy:=__nLibDel+1 To Len(aCols)
			If !aCols[xy,Len(aHeader)+1] .And.  Ascan(__aItDigQtd,xy)=0
				If Type("lTk271Auto") == "U" .Or. !lTk271Auto
					IW_MSGBOX("Favor confirmar a quantidade do item "+aCols[xy,GdFieldPos('UB_ITEM')],'Atenção','ALERT')
				Else
					ConOut("Favor confirmar a quantidade do item "+Str(xy,2))
				EndIf
				lRet:=.F.
				Exit
			Endif
		Next
	EndIf

	If lRet

	// INICIO - MARLLON
	// processa todos os itens do aCols
		If M->UA_OPER == '1'
		// busca as quantidades originais do atendimento para abater da reserva


		//| Cristiano Machado - Melhorias B2B - 18/10/2011
			If M->UA_STPB2B == 'S'
				M->UA_STPB2B := 'A' //| Controla as Alteracoes nos Pedidos...
			EndIf
		//| Fim B2B

			For nStart := 1 To Len(aCols)



				//| Correcao palhativa as validacoes do tmkgrped - Cristiano Machado - 11/08/2013 - solicitato por Edivaldo
				lPlanilha := .F.
				cProduto  := GDFieldGet('UB_PRODUTO',nStart)
				nQuant 	:= GDFieldGet('UB_QUANT',nStart)

				nQtdispo 	:= FEstoque(nQtdispo)	//|Verifica Estoque Filial

				nQtdAcols := FJaUsado(cProduto,xFilial("SUB"))  //|Verifica Quantidade ja utilizada no atual orcamento

				nQtdPlan	:= FVerPlan()

				If FVerPlan() > 0
					lPlanilha := .T. //|Verifica se Possui saldo em Planilha
				EndIf

				If nQuant > (nQtdispo -  nQtdAcols) .And. !lPlanilha   //|Quantidade em Estoque Supri ah Necessidade ?
					lRet := .F.
					ConOut('Por Favor, Revalidar a Quantidade Digitada no Item '+GDFieldGet('UB_ITEM',nStart)+' Codigo '+GDFieldGet('UB_PRODUTO',nStart)+'... Digite a Quantidade Novamente !')
				Else

					lRet := .T.
				EndIf

			/*
			// processa as reservas em planilha de transferencia
				If cCodTrf <> SC5->C5_CLIENTE
				// se a linha nao estiver deletada entao vou tratar
					If !aCols[nStart,Len(aHeader)+1]//! GDDeleted(nStart)
						nQtd     := GDFieldGet('UB_QUANT',nStart)
						cPlan    := GDFieldGet('UB_PLANILH',nStart)
						cPlItem  := GDFieldGet('UB_PLITEM',nStart)
						cFilTran := GDFieldGet('UB_FILTRAN',nStart)

						If ! Empty(cPlan)
						// testa se reservou em planilha
							dbSelectArea('SZE')
							dbSetOrder(3)
							dbSeek(xFilial('SZE')+cPlan+cPlItem)

						// Tenho que fazer isto pois a venda nao pode ser efetivada para uma planilha
						// que estiver em processo de manutencao
						// A funcao reclock() dispara uma mensagem para o usuario informando que o registro
						// esta bloqueado
							RecLock('SZE',.F.)
							msUnLock()
						// fim do teste de bloqueio de manutencao

						// Calcula o saldo disponivel do item da planilha
							nSldPlan := ( SZE->ZE_QTDTRAN + SZE->ZE_EXCED ) - SZE->ZE_QTDRES

							nPos := Ascan(aSldPlan, {|x| x[1]+x[2] == cPlan+cPlItem})
							If nPos > 0
								aSldPlan[nPos,3] := aSldPlan[nPos,3] + nQtd
							Else
								Aadd(aSldPlan, {cPlan, cPlItem, nQtd, nSldPlan, GDFieldGet('UB_PRODUTO',nStart)})
							EndIf

						ElseIf Empty(cPlan) .and. !Empty(cFilTran)
						// calcular a quantidade ja reservada em transferencia desta venda
						// com excecao do item atual
							nQtdFilt := 0
							nQtdAux  := 0
							For i := 1 To Len(aCols)
							// transferencia
								If nStart <> i .and. GDFieldGet('UB_FILTRAN',nStart) = GDFieldGet('UB_FILTRAN',i) .and. GDFieldGet('UB_PRODUTO',nStart) = GDFieldGet('UB_PRODUTO',i) .and. GDFieldGet('UB_LOCAL',nStart) = GDFieldGet('UB_LOCAL',i)
									nQtdFilt += GDFieldGet('UB_QUANT',i)
								EndIf
							// venda local
								If nStart <> i .and. Empty(GDFieldGet('UB_FILTRAN',i)) .and. Empty(GDFieldGet('UB_PLANILH',i)) .and. GDFieldGet('UB_PRODUTO',nStart) = GDFieldGet('UB_PRODUTO',i) .and. GDFieldGet('UB_LOCAL',nStart) = GDFieldGet('UB_LOCAL',i)
									nQtdAux += GDFieldGet('UB_QUANT',i)
								EndIf
							Next
						// calcula o saldo disponivel local
							SB2->( dbSeek(xFilial('SB2')+GDFieldGet('UB_PRODUTO',nStart)+GDFieldGet('UB_LOCAL',nStart)) )


							CPRODUTO  := GDFieldGet('UB_PRODUTO',nStart)

							nQtdispo 	:= FEstoque(nQtdispo)
							nQtdAcols := FJaUsado(CPRODUTO,xFilial("SUB"))

							nQtdispo := nQtdispo - nQtdAcols


							//nQtdispo := (SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QPEDVEN - SB2->B2_QACLASS ;
							//	+ u_QtdPedTra(SB2->B2_COD,SB2->B2_FILIAL) ;
							//	- nQtdAux ;
							//	+ u_QtdaCancelar( M->UA_NUM,GDFieldGet('UB_PRODUTO',nStart),GDFieldGet('UB_LOCAL',nStart) ) )

						// a quantidade ja reservada em transferencia + o item atual nao pode ser maior que o
						// saldo disponivel para transferencia
						// nao pode existir saldo disponivel local
							SB2->( dbSeek(cFilTran+GDFieldGet('UB_PRODUTO',nStart)+GDFieldGet('UB_LOCAL',nStart)) )
							If SB2->B2_QTRANS < (nQtdFilt + nQtd) .or. nQtdispo > 0
								lRet := .F.

								If SB2->B2_QTRANS < (nQtdFilt + nQtd)
									If (Type("lTk271Auto") = "U" .Or. !lTk271Auto)
										IW_MSGBOX('Quantidade solicitada do produto '+GDFieldGet('UB_PRODUTO',nStart)+' náo disponível para transferencia da filial '+cFilTran+'.','Atenção','ALERT')
									Else
										lRet := .T.
										ConOut('Quantidade solicitada do produto '+GDFieldGet('UB_PRODUTO',nStart)+' náo disponível para transferencia da filial '+cFilTran+'. Validacao ignorada, importacao via Palm.')
									EndIf
								EndIf
								If nQtdispo > 0
									If Type("lTk271Auto") == "U" .Or. !lTk271Auto
										IW_MSGBOX('Existe saldo disponivel do produto '+GDFieldGet('UB_PRODUTO',nStart)+', náo pode ser utilizado reserva em Planilha e nem Transferencia. Tecle ENTER na Quantidade.','Atenção','ALERT')
									Else
										lRet := .T.
										ConOut('Existe saldo disponivel do produto '+GDFieldGet('UB_PRODUTO',nStart)+', náo pode ser utilizado reserva em Planilha e nem Transferencia. Validacao ignorada, importacao via Palm.')
									EndIf
								EndIf
							EndIf

						ElseIf Empty(cPlan) .and. Empty(cFilTran)
						// testa saldo disponivel local
						// atualiza com os itens ja selecionados no aCols
							nQtdAux:=0
							For i := 1 To Len(aCols)
								If ! GDDeleted(i) .and. nStart <> i .and. Empty(GDFieldGet('UB_FILTRAN',i)) .and. Empty(GDFieldGet('UB_PLANILH',i)) .and. GDFieldGet('UB_PRODUTO',nStart) = GDFieldGet('UB_PRODUTO',i) .and. GDFieldGet('UB_LOCAL',nStart) = GDFieldGet('UB_LOCAL',i)
									nQtdAux += GDFieldGet('UB_QUANT',i)
								EndIf
							Next

							// CRISTIANO - GAMBIARRA PARA RESOLVER ERRO QUANDO UTILIZA PLANILHA... SOLICITADO POR EDIVALDO 08/11/2013
							// FEITO COM URGENCIA

							SB2->( dbSeek(xFilial('SB2')+GDFieldGet('UB_PRODUTO',nStart)+GDFieldGet('UB_LOCAL',nStart)) )

							CPRODUTO  := GDFieldGet('UB_PRODUTO',nStart)

							nQtdispo 	:= FEstoque(nQtdispo)
							nQtdAcols := FJaUsado(CPRODUTO,xFilial("SUB"))

							nQtdispo := nQtdispo - nQtdAcols

							//nQtdispo := (SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QPEDVEN - SB2->B2_QACLASS ;
								//+ u_QtdPedTra(SB2->B2_COD,SB2->B2_FILIAL) ;
								//- nQtdAux ;
								//+ u_QtdaCancelar( M->UA_NUM,GDFieldGet('UB_PRODUTO',nStart),GDFieldGet('UB_LOCAL',nStart) ) )


							If nQtd > nQtdispo
								lRet := .F.

								If (Type("lTk271Auto") = "U" .Or. !lTk271Auto)
									IW_MSGBOX('Quantidade solicitada do produto '+GDFieldGet('UB_PRODUTO',nStart)+', Item: '+GDFieldGet('UB_ITEM',nStart)+' , não disponível no estoque local.','Atenção','ALERT')
								Else
									lRet := .T.
									ConOut('Quantidade solicitada do produto '+GDFieldGet('UB_PRODUTO',nStart)+', Item: '+GDFieldGet('UB_ITEM',nStart)+' , não disponível no estoque local. Validacao ignorada, importacao via Palm.')
								EndIf

							EndIf
						EndIf
					ELSE // caso esteja deletada a linha na alteracao do atendimento
						IF !EMPTY(GDFieldGet('UB_PLANILH',nStart)) .And. ALTERA
						// não permite gravar o pedido quando alteração e tiver linha deletada com planilha já processada
							lRet := .F.
							If Type("lTk271Auto") == "U" .Or. !lTk271Auto
								IW_MSGBOX("Não é permitido deletar o item "+ GDFieldGet('UB_ITEM',nStart)+ " pois o mesmo já gerou planilha de transferência",'ALERT')
							Else
								lRet := .T.
								ConOut("Não é permitido deletar o item "+ GDFieldGet('UB_ITEM',nStart)+ " pois o mesmo já gerou planilha de transferência")
							EndIf
						ENDIF
					EndIf
				EndIf
*/
			Next
/*
		// Valido os saldos
			For nStart := 1 To Len(aSldPlan)
				If aSldPlan[nStart,3] < aSldPlan[nStart,4]
					lRet := .F.

				// libera a digitacao do campo quantidade novamente
				// Expedito
					U_LibDigQtd(aSldPlan[nStart,1],aSldPlan[nStart,2],aSldPlan[nStart,5])	// planilha,item,produto
				// Fim Expedito

					Help(" ", 1, "Atenção",,'Inconsistência na Quantidade do Produto '+;
						AllTrim( aSldPlan[nStart,5] )+' da Planilha '+aSldPlan[nStart,1]+' !',1,1)

				EndIf

			Next
*/
		// Inicio Expedito - Tratamento de campos obrigatorios do cadastro de clientes quando eh primeira venda a um prospect
			If lRet .and. lProspect
				lRet := ValObrSA1()
			Endif
		// Fim Expedito

		EndIf
	Endif
// FIM - MARLLON
// Fim do tratamento da validacao em planilha

// INICIO - EXPEDITO
	IF lRet
		If Empty(M->UA_CONDPG)
			lRet := .F.
			Help(" ",1,"OBRIGAT",, RetTitle("UA_CONDPG"),4)
		Elseif Empty(M->UA_CODCONT)
			lRet := .F.
			Help(" ",1,"OBRIGAT",,'Contato do Cliente está em branco',4)
	  //Edivaldo Goncalves Cordeiro - Validação do CNAE do cliente
		ElseIf  !lProspect .AND. Empty(SA1->A1_CNAE) .AND. SA1->A1_PESSOA <> "F"
			Help(" ",1,"OBRIGAT",,RetTitle("A1_CNAE"),4)
			lRet := .F.
		ElseIf  lProspect .AND. Empty(SUS->US_CNAE) .AND. SUS->US_PESSOA <> "F"
			Help(" ",1,"OBRIGAT",,RetTitle("US_CNAE"),4)
			lRet := .F.
		Elseif !u_ValRota()


			lRet := .F.
		ELSE
		// valida preenchimento do campo quantidade e a data/hora da necessidade do cliente
			for nStart := 1 to Len(aCols)

			// Projeto F11 - Pode deletar item
				If aCols[nStart,Len(aHeader)+1]	// a linha esta deletada
					exit
				Else	// a linha nao esta deletada


				//()





					If gdFieldGet("UB_QUANT",nStart) == 0 .or. gdFieldGet("UB_VRUNIT",nStart) == 0
						lRet := .F.
						If Type("lTk271Auto") == "U" .Or. !lTk271Auto
							Help(" " , 1, "A010VAZ" )
						EndIf
						exit

					******
					//
						If	DTOS(gdFieldGet("UB_DTNECLI",nStart))+gdFieldGet("UB_HRNECLI",nStart) < DTOS(Date())+Strtran(Left(Time(),5),":","") .and. M->UA_OPER != "1"	// orcamento
							MsgInfo("Problema com as Datas da Necessidade do Cliente")
						Endif
					******

					Elseif DTOS(gdFieldGet("UB_DTNECLI",nStart))+gdFieldGet("UB_HRNECLI",nStart) < DTOS(Date())+Strtran(Left(Time(),5),":","") .and. M->UA_OPER != "1"	// orcamento

						lRet := .F.
						If Type("lTk271Auto") == "U" .Or. !lTk271Auto
							IW_MSGBOX(Oemtoansi("A data/hora da necessidade de faturamento do cliente deve ser maior que a data/hora atual !"),Oemtoansi('Atenção'),'ALERT')
						Else
							ConOut("A data/hora da necessidade de faturamento do cliente deve ser maior que a data/hora atual !")
						EndIf
						exit
					Endif
				Endif

			next


		// valida se o usuario ja clicou no botao de condicao de pagamento no orcamento
			If Type("lTk271Auto") == "U" .Or. !lTk271Auto
				If lRet .and. !__lJaBotCPag
					lRet := .F.
					IW_MSGBOX(Oemtoansi("Antes de confirmar o atendimento, clique no botão 'Condições de Pagamento' ou tecle <F6>"),Oemtoansi('Atenção'),'ALERT')
				Endif
			Endif
		Endif
	Endif

// Jorge Oliveira - 17/09/2010 - Chamado AAZRL3 - Gravar o codigo do Operador atual no atendimento
	If lRet

		PswOrder(1)
		If PswSeek(__cUserId)
			cNome := PswRet()[1][4]
		EndIf

	//Pesquisa o usuario no cadastro de operadores
		DbSelectarea("SU7")
		DbSetorder(3)
		If !DbSeek(xFilial("SU7")+cNome) // Nome completo
		// Caso nao encontre, tenta com todas as letras maiusculas (legado)
			If !DbSeek(xFilial("SU7")+UPPER(cNome)) // Nome completo
				lOper := .F.
			EndIf
		Endif

	// Posiciona no SUA novamente
		DbSelectarea( "SUA" )
		DbSetorder( 1 )
		If DbSeek( xFilial( "SUA" ) + M->UA_NUM )

		// Achou e eh outro operador, entao atualiza
			If lOper .And. M->UA_OPERADO <> SU7->U7_COD
				If RecLock( "SUA", .F. )

				// Novo operador
					If ( Empty( SUA->UA_OPERAD2 ) .And. SUA->UA_OPERAD2 <> SU7->U7_COD  .AND. SUA->UA_OPERADO <> SU7->U7_COD )
						SUA->UA_OPERAD2 := SUA->UA_OPERADO
						M->UA_OPERAD2   := SUA->UA_OPERADO

				// O primeiro operador, voltou a alterar o atendimento
					ElseIf !Empty( SUA->UA_OPERAD2 ) .And. SUA->UA_OPERAD2 == SU7->U7_COD
						SUA->UA_OPERAD2 := SUA->UA_OPERADO
						M->UA_OPERAD2   := SUA->UA_OPERADO
					Endif

				// Sempre vai atualizar o Operador atual com o codigo correto
					SUA->UA_OPERADO := SU7->U7_COD
					M->UA_OPERADO   := SU7->U7_COD

					MsUnLock()
				EndIf
			EndIf
		EndIf

	EndIf

	RestArea(aAreaSB2)
	RestArea(aAreaSZE)
	RestArea(aArea)

Return( lRet )


	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ U_QTDACANCELAR  ³Autor  ³Microsiga        ³ Data ³ 26/09/03 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Retorna a quantidade do produto no atendimento original,    ³±±
	±±³          ³ nos casos de copia de atendimento com operacao "faturamento"³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ CALL CENTER						                           ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
User Function QtdaCancelar(cNumOrig,cProduto,cLocal)
	Local aArea, aAreaSUA, aAreaSC6, aAreaSF4
	Local nQtd := 0

	If !Empty(cNumOrig)

	// salva o ambiente
		aArea := getarea()
		aAreaSUA := SUA->(getarea())
		aAreaSC6 := SC6->(getarea())
		aAreaSF4 := SF4->(getarea())

	// localiza o atendimento original
		dbSelectArea("SUA")
		dbSetOrder(1)
		dbSeek(xFilial("SUA")+cNumOrig)

		If SUA->UA_OPER == "1" 	// Faturamento

			dbSelectArea("SF4")
			dbSetOrder(1)

			dbSelectArea("SC6")
			dbSetOrder(2)	// filial + produto + numero + item
			dbSeek(xFilial("SC6")+cProduto+SUA->UA_NUMSC5)
			Do While SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_NUM == xFilial("SC6")+cProduto+SUA->UA_NUMSC5 .and. !Eof()

			// Verifica se eh o mesmo armazem
				If SC6->C6_LOCAL == cLocal

				// avalia a TES
					dbSelectArea("SF4")
					SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES))
					If SF4->F4_ESTOQUE == "S" .and. Empty(SC6->C6_PLANILH) .and. Empty(SC6->C6_FILTRAN)
						nQtd += SC6->C6_QTDVEN
					Endif
				Endif

				dbSelectArea("SC6")
				dbSkip()
			Enddo

		Endif

	// Restaura ambiente
		Restarea(aAreaSF4)
		Restarea(aAreaSC6)
		Restarea(aAreaSUA)
		Restarea(aArea)

	Endif

Return nQtd


	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ ValObrSA1       ³Autor  ³Microsiga        ³ Data ³ 30/06/04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Verifica se os campos obrigatorios do cadastro de clientes  ³±±
	±±³          ³ estao preenchidos no cadastro de prospects.                 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ CALL CENTER						                           ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Static Function ValObrSA1()
	Local aArea   := GetArea()
	Local aAreaSUS := SUS->(getarea())
	Local aAReaSA1 := SA1->(getarea())

	Local lRet := .T., aCampObrig:={},nI
	Local nPos

// Verifica os campos obrigatorios do SA1
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SA1")
	Do While ( !Eof() .And. SX3->X3_ARQUIVO == "SA1" )
		If X3Obrigat(Alltrim(SX3->X3_CAMPO))
			aAdd(aCampObrig,Alltrim(SX3->X3_CAMPO))
		EndIf
		dbSelectArea("SX3")
		dbSkip()
	EndDo

	dbSelectArea("SUS");dbSetOrder(1)
	If DbSeek(xFilial("SUS")+M->UA_CLIENTE+M->UA_LOJA,.F.)
		for nI := 1 to Len(aCampObrig)
			nPos := FieldPos("US_"+SubStr(aCampObrig[nI],4))
			If nPos > 0
				If aCampObrig[nI] $ cSa1nSus

				ElseIf Empty(FieldGet(nPos))
					lRet := .F.
				Endif
			Else	// Excecoes
				If aCampObrig[nI] $ cSa1nSus

				Elseif aCampObrig[nI] == "A1_SATIV1"	// De US_SATIV para A1_SATIV1
					If Empty(SUS->US_SATIV)
						lRet := .F.
					Endif
				Else
					IW_MSGBOX("O campo "+aCampObrig[nI]+" não existe no cadastro de prospect, Depto de Tecnologia Imdepa.",'Atenção','ALERT')
				Endif
			Endif
		next
		If !lRet
			IW_MSGBOX("Campos obrigatórios não preenchidos. Para efetivar esta venda, Tecle em <Alteração da Entidade> e preencha os campos com asterisco (*)",'Atenção','ALERT')
		Else
			If Empty(SUS->US_INSCR) .AND. !MsgYesNo( 'Tem certeza que este cliente não possui inscrição estadual?', 'Cadastro de clientes' )
				IW_MSGBOX("Tecle em <Alteração da Entidade> e preencha o campo 'Inscrição Estadual'",'Atenção','INFO')
				lRet := .F.
			Endif
		Endif
	Else
		If Type("lTk271Auto") == "U" .Or. !lTk271Auto
			Alert("Prospect não cadastrado")
		EndIf
		lRet := .F.
	Endif

	Restarea(aAreaSUS)
	Restarea(aAReaSA1)
	Restarea(aArea)
Return lRet
***********************************
//Projeto F11
***********************************


Static Function  PedidoImp(cFil,cNumPedido)

	Local lRet := .F.
	Local cQuery

	cQuery := "SELECT MAX (C9_DTPSEP) DTSEP"
	cQuery += "  FROM " + RetSQLName("SC9")
	cQuery += " WHERE C9_FILIAL = '" + cFil + "' AND C9_PEDIDO = '" +cNumPedido + "' AND"
	cQuery += " 	  D_E_L_E_T_ <> '*'"

	IF SELECT( 'SEP' ) <> 0
		dbSelectArea('SEP')
		Use
	Endif

	TCQUERY cQuery NEW ALIAS ('SEP')


	IF  !EMPTY(SEP->DTSEP)
		lRet := .T.
	ENDIF

	SEP->(DbCloseArea())

return lRet

*********************************************************************
Static Function FEstoque(nQtdEst)//| Levanta o Estoque da Filial Atual
*********************************************************************
	Local cQuery
	Local aArea	:= GetArea()

	cQuery := " SELECT SUM(TA.QTD + TB.QTD + TC.QTD) QTD "
	cQuery += " FROM "
	cQuery += " ( SELECT NVL( SUM( C6_QTDVEN - C6_QTDENT ), 0 ) QTD "
	cQuery += "	  FROM " + RetSQLName("SC6") + " SC6, " + RetSQLName("SC7") + " SC7 "
	cQuery += "	  WHERE C6_FILIAL = '" 	+ xFilial("SC6") 	+ "' "
	cQuery += "	  AND C6_PRODUTO = '" 	+ cProduto + "' "
	cQuery += "	  AND C6_CLI <> '" 		+ cImdepa 			+ "' AND ( C6_PLANILH <> ' ' OR C6_FILTRAN <> ' ' ) "
	cQuery += "	  AND C6_NOTA = ' ' "
	cQuery += "	  AND SC6.D_E_L_E_T_ = ' ' "
	cQuery += "	  AND C7_FILIAL = C6_FILIAL "
	cQuery += "	  AND C7_PLANILH = C6_PLANILH "
	cQuery += "	  AND C7_PLITEM = C6_PLITEM "
	cQuery += "	  AND ( C7_QUANT - C7_QUJE ) > 0 "
	cQuery += "	  AND SC7.D_E_L_E_T_ = ' ') TA, "

	cQuery += "	( SELECT (B2_QATU - B2_RESERVA - B2_QPEDVEN - B2_QACLASS) QTD "
	cQuery += "	  FROM " + RetSQLName("SB2") + " "
	cQuery += "	  WHERE B2_FILIAL = '" + xFilial("SB2") + "'  "
	cQuery += "	  AND B2_COD = '" + cProduto + "' "
	cQuery += "	  AND B2_LOCAL = '01' "
	cQuery += "	  AND D_E_L_E_T_ = ' ') TB, "

	cQuery += " ( SELECT NVL (SUM(UB_QUANT) , 0) QTD "
	cQuery += "   FROM " + RetSQLName("SUA") + " UA, " + RetSQLName("SUB") + " UB "
	cQuery += "   WHERE UA.UA_FILIAL  = '" + xFilial( "SUA" ) + "' "
	cQuery += "   AND   UA.UA_NUM     = '"+M->UA_NUM+"'  "
	cQuery += "   AND   UA.UA_OPER    = '1'   "
	cQuery += "   AND   UA.UA_CANC    = ' ' "
	cQuery += "   AND   UA.UA_FILIAL  = UB.UB_FILIAL  "
	cQuery += "   AND   UA.UA_NUM     = UB.UB_NUM "
	cQuery += "   AND   UB.UB_PRODUTO = '"+cProduto+"'  "
	cQuery += "   AND   UA.D_E_L_E_T_ = ' ' "
	cQuery += "   AND   UB.D_E_L_E_T_ = ' ' "
	cQuery += "  ) TC "

	U_ExecMySql(cQuery,"cQuery","Q") //| VALIDADA CUSTO 17

	DbselectArea('cQuery')

	nQtdEst	:=	cQuery->QTD

	DbCloseArea()
	RestArea(aArea)

Return(nQtdEst)
*********************************************************************
Static Function FJaUsado(cProd,cFil,lPlanilha) //| Obtem Produtos ja Utilizados no Orcamento / Pedido em questao
*********************************************************************
	Local nQtd := 0

	Default lPlanilha := .F.

// Abate os itens já selecionados no acols da quantidade disponível
	For i := 1 To Len(aCols)


		If lPlanilha
			If !GDDeleted(i) .and. n != i .And. Empty(GDFieldGet('UB_FILTRAN',i)) .And. cFilAnt == cFil .And. !Empty(GDFieldGet('UB_PLANILH',i)) .And. SZE->ZE_NUMPLAN == GDFieldGet('UB_PLANILH',i) .And. cProd = GDFieldGet('UB_PRODUTO',i) .And. GDFieldGet('UB_LOCAL',n) = GDFieldGet('UB_LOCAL',i)

				nQtd += GDFieldGet('UB_QUANT',i)

			Endif
		ElseIf !GDDeleted(i) .and. n != i .and. cFil == GDFieldGet('UB_FILTRAN',i) .and. Cfilant != cFil .and.  Empty(GDFieldGet('UB_PLANILH',i)) .and. cProd = GDFieldGet('UB_PRODUTO',i) .and. GDFieldGet('UB_LOCAL',n) = GDFieldGet('UB_LOCAL',i)

			nQtd += GDFieldGet('UB_QUANT',i)

		ElseIf !GDDeleted(i) .and. n != i .and. Empty(GDFieldGet('UB_FILTRAN',i)) .and. Cfilant == cFil .and. Empty(GDFieldGet('UB_PLANILH',i)) .and. cProd = GDFieldGet('UB_PRODUTO',i) .and. GDFieldGet('UB_LOCAL',n) = GDFieldGet('UB_LOCAL',i)

			nQtd += GDFieldGet('UB_QUANT',i)

		Endif

	Next

Return(nQtd)
*********************************************************************
Static Function FVerPlan() //|Consulta e carrega as Planilhas
*********************************************************************
	Local aExced     	:= Array(0)
	Local nQtdDisp	  	:= 0
	Local nQtdPed	  	:= 0
	Local nQtdInf    	:= 0
	Local nAux		  	:= 0
	Local cQuery     	:= ""
	Local lContinua  	:= .F.
	Local dDataCorte	:= SuperGetMV( "MV_FILPLAN",, "20100801" )
	Local nSomaDisp		:= 0
	aListPlan 			:= {} //|Reinicializa

	If ValType( dDataCorte ) == "C"
		dDataCorte := StoD( dDataCorte )
	EndIf

	DbSelectArea("SB2");DbSetOrder(1) // B2_FILIAL + B2_PRODUTO
	DbSelectArea('SZE');DbSetOrder(4) // ZE_FILIAL + ZE_PRODUTO + ZE_DESTINO

	If SZE->( DbSeek( xFilial('SZE') + cProduto ) )

		While SZE->( !Eof() ) .and. SZE->ZE_PRODUTO == cProduto .and. xFilial('SZE') == SZE->ZE_FILIAL

			nQtdPed  := 0
			nQtdDisp := 0

		//| Somente irao aparecer as Planilhas cadastradas apartir de 01 Agosto 2010 OU Planilhas que ainda nao venceram
			If SZE->ZE_DATA < dDataCorte .Or. SZE->ZE_VENCD < dDataBase
				SZE->( dbSkip() )
				Loop
			EndIf

		//| Somente Planilhas de Transferencia serao mostradas , que ainda nao foram processadas e estao Destravadas
			If SZE->ZE_TPPLAN <> "T" .Or. SZE->ZE_FLAGPT  == "S" .OR. SZE->ZE_STATUS=='2'
				SZE->( dbSkip() )
				Loop
			EndIf

		//| Filial de destino do Produto eh diferente da Filial atual, nao mostra
			If ( SZE->ZE_DESTINO <> cFilAnt .And. SZE->ZE_EXCED <= 0 )
				SZE->( dbSkip() )
				Loop
			EndIf

			nQtdInf := FJaUsado( cProduto, xFilial("SUB"), .T. )

		//| Se tem uma quantidade informada a ser transferido, pode ser para um Cliente ( Reserva ) ou pode ser que o item da Planilha seja uma transferencia para uma determinada Filial
			If SZE->ZE_QTDTRAN > 0

				nQtdPed  := U_PEDPLAN( SZE->ZE_NUMPLAN, SZE->ZE_ITEM, cProduto, SZE->ZE_CODCLI, "", "", IIF( Empty( SZE->ZE_CODCLI ), "", cFilAnt ) )
				nQtdDisp := ( SZE->ZE_QTDTRAN - SZE->ZE_QTDRES - nQtdInf - nQtdPed )

			//| Busca os Pedidos colocado pelo Excedente
			ElseIf SZE->ZE_EXCED > 0

				nQtdPed  := U_PEDPLAN( SZE->ZE_NUMPLAN, SZE->ZE_ITEM, cProduto )
				nQtdDisp := ( SZE->ZE_EXCED - SZE->ZE_QTDRES - nQtdInf - nQtdPed )

			EndIf

		//| Carrega as informacoes se tem quantidade disponivel
			nAux := Val(Posicione("SX5",1,xFilial("SX5")+"I5"+SZE->ZE_MSFIL + xFilial( "SUB" ),"X5_DESCRI"))
			nSomaDisp += nQtdDisp

		//| Carrega o Array
			Aadd(aListPlan,{'',SZE->ZE_DESTINO, SZE->ZE_NUMPLAN, SZE->ZE_ITEM, SZE->ZE_QTDTRAN, nQtdDisp, SZE->ZE_DTENTRE+nAux, Iif(!Empty(SZE->ZE_HAWB), 'Importada', 'Nacional'), SZE->ZE_CODPE, SZE->ZE_EXCED, SZE->ZE_CODCLI+'/'+SZE->ZE_LOJA})


			SZE->( DbSkip() )

		EndDo

	EndIf

	DbSelectArea('SZE');DbSetOrder(1) // ZE_FILIAL + ZE_NUMPLAN + ZE_PRODUTO + ZE_DESTINO

	If Len( aListPlan ) <= 0
	//OKAadd(aListPlan,{'','','',0,0,Ctod(''),'','',0, ''})
		Aadd(aListPlan,{'','','','',0,0,Ctod(''),'','',0, ''})
	EndIf

Return(nSomaDisp)

