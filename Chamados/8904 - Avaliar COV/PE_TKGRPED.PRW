#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'RWMAKE.CH'
#DEFINE  ENTER CHR(13)+CHR(10)
///
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | U_TKGRPED       ³Autor  ³Microsiga        |Data  |26/04/03  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a validacao dos dados digitados na tela de atendimento   ³±?
±±|          ³de televendas do modulo Call Center, apos o usuario clicar   ³±?
±±|          ³no botao <Ok>.                                               ³±?
±±|          |                                                             ³±?
±±|          ³P.E. ANTES da grava‡ao do atendimento com espera de retorno  ³±?
±±|          |                                                             ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       |CALL CENTER						                       	   ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
*********************************************************************
User Function TKGRPED(	_nLiquido, _aParcelas, M_UA_OPER, M_UA_NUM,;
						M_UA_CODLIG, _cCodPagto, _cOpFat, _cCodTransp)
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
	nPos       	:= 0,;
	aSldPlan   	:= Array(0)
Local xy		:=0
Local i 		:= 1
Local nStart 	:= 1
Local cMens 	:= " "
Local nQtdispo 	:= 0
Local aProdXQtd_no_SUB := {}
Local cNumSC5  	:= SPACE(6)
Local cOperaWms	:= GetMv("MV_WMSTPAP",,"F")
Local cNome 	:= ""
Local lOper 	:= .T.
//Local lFaturado	:= IIF(M->UA_NUM == SUA->UA_NUM .And. SUA->UA_STATUS == "NF." .And. !Empty(SUA->UA_NUMSC5), .T., .F.)
Local lFaturado	:= .F.


//|NOME: CRISTIANO MACHADO //|DATA: 30/04/2006
//|MOTIVO: CRIACAO DE PARAMETRO PARA CAMPOS QUE SAO OBRIGATORIOS NO CADASTRO DE CLIENTES
//|		  MAS N? PRECISAM SER PREENCHIDO ENQUANTO CLIENTE FOR UM PROSPECT.
//|CHAMADO: AAZO2V
Private cSa1nSus := Getmv("MV_SA1NSUS")


//----------------------Posiciona no arquivo de estoques , chamado AAZQLF
SB2->(DbSetOrder(1))


// Posiciona no SUA para buscar o numero do pedido
DbSelectarea("SUA");DbSetorder(1)
If DbSeek(xFilial("SUA")+M->UA_NUM)
	cNumSC5   := SUA->UA_NUMSC5
	lFaturado := IIF(!Empty(SUA->UA_NUMSC5), .T., .F.) // SUA->UA_STATUS == "NF."
EndIf


If ( PedFinMin() == .F. ) // Verifica o pedido Minimo .. Regra Financeira Chamado: ??????
	Return(.F.)
EndIf




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//? AJUSTE PARA NAO APRESENTAR MENSAGEM "ERRO SOMA DAS PARCELAS" ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
**********************************
	ChkTk010ValOk(_aParcelas)
**********************************



*=================================================================================*
//N? Permite Alterar Pedido que j?foi impresso em filiais que n? possuem o WMS *
//Nas que possuem o WMS j?tratado pela OS. - Edivaldo Gon?lves Cordeiro 06/09/07*
*=================================================================================*

IF cOperaWms =='F' .AND. PedidoImp(xFilial("SC9"),cNumSC5)
	__Podesair := "S" //Permite sair/limpar pois n? permitir?gravar
	If Type("lTk271Auto") == "U" .Or. !lTk271Auto
		IW_MSGBOX("Atendimento n?ero "+M->UA_NUM+" n? pode ser alterado pois o pedido j?foi impresso. Para iniciar um novo atendimento, clique em 'Limpa o Atendimento' ou tecle <F5>.",'Aten?o','ALERT')
	EndIf
	Return .F.
ENDIF

//  testa o numero do atendimento original (esta validacao eh temporaria, para tentar descobrir um possivel erro)
If M->UA_NUM == M->UA_NUMORIG
	If Type("lTk271Auto") == "U" .Or. !lTk271Auto
		IW_MSGBOX("N?ero do atendimento = N?ero do atendimento original. Favor entrar em contato com o Depto. de Tecnologia Imdepa! e informe o numero de atendimento "+M->UA_NUM+".",'Aten?o','ALERT')
	Else
		ConOut("N?ero do atendimento = N?ero do atendimento original. Favor entrar em contato com o Depto. de Tecnologia Imdepa e informe o numero de atendimento "+M->UA_NUM+".")
	EndIf
Endif

// Jeferson.
// Validacao para nao ocorrer a confirmacao de um atendimento
// sem que o passe pelo campo quantidade quando o item for novo.


If Empty(M->UA_PEDWEB)

	If !lFaturado
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//| VERIFICA SE USUARIO CONFIRMOU AS QUANTIDADES	|
		//|  E VALORES DOS PRECOS							|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		lRet := ExecBlock('ChkQtdxVlr', .F., .F., {SUA->UA_NUMSC5})
    EndIf

EndIf



If lRet
  If M->UA_OPER == '2'
	For nStart := 1 To Len(aCols)

		If (!aCols[nStart,Len(aHeader)+1] .AND. GDFieldGet('UB_CONFITA',nStart)=='1' )

		//   	IW_MSGBOX("O Sistema adicionou uma oferta Automática neste Pedido !"+Chr(10)+Chr(13)+"Item :"+aCols[xy,GdFieldPos('UB_ITEM')]+' - '+aCols[xy,GdFieldPos('UB_DESCRI')]+Chr(10)+Chr(13)+"Favor confirmar ou Deletar a oferta !",'Oferta Automatica','INFO')
    	IW_MSGBOX("O Sistema adicionou uma oferta Automática neste Orçamento !"+Chr(10)+Chr(13)+"Item :"+aCols[nStart,GdFieldPos('UB_ITEM')]+' - '+aCols[nStart,GdFieldPos('UB_DESCRI')],'Oferta Automatica','INFO')

		Endif
	Next nStart
  Endif

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

			If (!aCols[nStart,Len(aHeader)+1] .AND. GDFieldGet('UB_CONFITA',nStart)=='1' )

				//   	IW_MSGBOX("O Sistema adicionou uma oferta Automática neste Pedido !"+Chr(10)+Chr(13)+"Item :"+aCols[xy,GdFieldPos('UB_ITEM')]+' - '+aCols[xy,GdFieldPos('UB_DESCRI')]+Chr(10)+Chr(13)+"Favor confirmar ou Deletar a oferta !",'Oferta Automatica','INFO')
				IW_MSGBOX("O Sistema adicionou uma oferta Automática neste Pedido !"+Chr(10)+Chr(13)+"Item :"+aCols[nStart,GdFieldPos('UB_ITEM')]+' - '+aCols[nStart,GdFieldPos('UB_DESCRI')],'Oferta Automatica','INFO')

			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//|  VERIFICA DESCONTO \ ACRESCIMO E ZERO VALORES PARA NAO INFLUENCIAR NA NOTA FISCAL	|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			******************************
				ChkDescAcre(nStart)
			******************************

			IIF(Select('SBP')==0, (ChkFile('SBP'),DbSelectArea("SBP")),)
			lCorreia := !Empty(A093VldBase(GdFieldGet("UB_PRODUTO",nStart)))


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
						nQtdispo := (SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QPEDVEN - SB2->B2_QACLASS ;
						+ u_QtdPedTra(SB2->B2_COD,SB2->B2_FILIAL) ;
						- nQtdAux ;
						+ u_QtdaCancelar( M->UA_NUM,GDFieldGet('UB_PRODUTO',nStart),GDFieldGet('UB_LOCAL',nStart) ) )

						// a quantidade ja reservada em transferencia + o item atual nao pode ser maior que o
						// saldo disponivel para transferencia
						// nao pode existir saldo disponivel local
						SB2->( dbSeek(cFilTran+GDFieldGet('UB_PRODUTO',nStart)+GDFieldGet('UB_LOCAL',nStart)) )
						If SB2->B2_QTRANS < (nQtdFilt + nQtd) .or. nQtdispo > 0

							lRet := IIF(lCorreia, .T., .F.)

							If SB2->B2_QTRANS < (nQtdFilt + nQtd)
								If (Type("lTk271Auto") = "U" .Or. !lTk271Auto)
									If !lCorreia	// FABIANO PEREIRA - SOLUTIO
										IW_MSGBOX('Quantidade solicitada do produto '+GDFieldGet('UB_PRODUTO',nStart)+' n? dispon?el para transferencia da filial '+cFilTran+'.','Aten?o','ALERT')
                                    EndIf
								Else
									lRet := .T.
									ConOut('Quantidade solicitada do produto '+GDFieldGet('UB_PRODUTO',nStart)+' n? dispon?el para transferencia da filial '+cFilTran+'. Validacao ignorada, importacao via Palm.')
								EndIf
							EndIf

							If nQtdispo > 0
								If Type("lTk271Auto") == "U" .Or. !lTk271Auto
									IW_MSGBOX('Existe saldo disponivel do produto '+GDFieldGet('UB_PRODUTO',nStart)+', n? pode ser utilizado reserva em Planilha e nem Transferencia. Tecle ENTER na Quantidade.','Aten?o','ALERT')
								Else
									lRet := .T.
									ConOut('Existe saldo disponivel do produto '+GDFieldGet('UB_PRODUTO',nStart)+', n? pode ser utilizado reserva em Planilha e nem Transferencia. Validacao ignorada, importacao via Palm.')
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



						SB2->( dbSeek(xFilial('SB2')+GDFieldGet('UB_PRODUTO',nStart)+GDFieldGet('UB_LOCAL',nStart)) )
						nQtdispo := (SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QPEDVEN - SB2->B2_QACLASS ;
						+ u_QtdPedTra(SB2->B2_COD,SB2->B2_FILIAL) ;
						- nQtdAux ;
						+ u_QtdaCancelar( M->UA_NUM,GDFieldGet('UB_PRODUTO',nStart),GDFieldGet('UB_LOCAL',nStart) ) )

						If nQtd > nQtdispo

							lRet := IIF(lCorreia, .T., .F.)

							If (Type("lTk271Auto") = "U" .Or. !lTk271Auto)
								If !lCorreia	// FABIANO PEREIRA - SOLUTIO
									IW_MSGBOX('Quantidade solicitada do produto '+GDFieldGet('UB_PRODUTO',nStart)+', Item: '+GDFieldGet('UB_ITEM',nStart)+' , n? dispon?el no estoque local.','Aten?o','ALERT')
								EndIf
							Else
								lRet := .T.
								ConOut('Quantidade solicitada do produto '+GDFieldGet('UB_PRODUTO',nStart)+', Item: '+GDFieldGet('UB_ITEM',nStart)+' , n? dispon?el no estoque local. Validacao ignorada, importacao via Palm.')
							EndIf

						EndIf

					EndIf

				ELSE // caso esteja deletada a linha na alteracao do atendimento
					IF !EMPTY(GDFieldGet('UB_PLANILH',nStart)) .And. ALTERA
						// n? permite gravar o pedido quando altera?o e tiver linha deletada com planilha j?processada
						lRet := .F.
						If Type("lTk271Auto") == "U" .Or. !lTk271Auto
							IW_MSGBOX("N? ?permitido deletar o item "+ GDFieldGet('UB_ITEM',nStart)+ " pois o mesmo j?gerou planilha de transfer?cia",'ALERT')
						Else
							lRet := .T.
							ConOut("N? ?permitido deletar o item "+ GDFieldGet('UB_ITEM',nStart)+ " pois o mesmo j?gerou planilha de transfer?cia")
						EndIf
					ENDIF
				EndIf

			EndIf

		Next

		// Valido os saldos
		For nStart := 1 To Len(aSldPlan)
			If aSldPlan[nStart,3] < aSldPlan[nStart,4]
				lRet := .F.

				// libera a digitacao do campo quantidade novamente
				// Expedito
				U_LibDigQtd(aSldPlan[nStart,1],aSldPlan[nStart,2],aSldPlan[nStart,5])	// planilha,item,produto
				// Fim Expedito

				Help(" ", 1, "Aten?o",,'Inconsist?cia na Quantidade do Produto '+;
										  AllTrim( aSldPlan[nStart,5] )+' da Planilha '+aSldPlan[nStart,1]+' !',1,1)

			EndIf

		Next

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
		Help(" ",1,"OBRIGAT",,'Contato do Cliente est?em branco',4)
	  //Edivaldo Goncalves Cordeiro - Valida?o do CNAE do cliente
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
		For nStart := 1 To Len(aCols)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//|  VERIFICA DESCONTO \ ACRESCIMO E ZERO VALORES PARA NAO INFLUENCIAR NA NOTA FISCAL	|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			***************************
				ChkDescAcre(nStart)
			***************************

			// Projeto F11 - Pode deletar item
			If aCols[nStart,Len(aHeader)+1]	// a linha esta deletada
				exit
			Else	// a linha nao esta deletada

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
						IW_MSGBOX(Oemtoansi("Por favor, atualize a Data/Hora da Necessidade do Cliente nos Itens do Orçamento para uma Data/Hora maior que a atual !"),Oemtoansi('Atenção'),'ALERT')
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
				IW_MSGBOX(Oemtoansi("Antes de confirmar o atendimento, clique no bot? 'Condi?es de Pagamento' ou tecle <F6>"),Oemtoansi('Aten?o'),'ALERT')
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


// FABIANO PEREIRA SOLUTIO
If !lRet

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//| CASO OCORRA ERRO NA VALIDACAO DO ATENDIMENTO     	|
	//| ZERA ARRAY PARA MOSTRAR NOVAMENTE A TELA COM OS  	|
	//| ITENS BLOQUEADOS POR REGRA DE NEGOCIO            	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		aImdCodR := {}

EndIf


RestArea(aAreaSB2)
RestArea(aAreaSZE)
RestArea(aArea)

Return( lRet )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |U_QTDACANCELAR   ³Autor  ³Microsiga        |Data  |26/09/03  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o |Retorna a quantidade do produto no atendimento original,     ³±?
±±|          |nos casos de copia de atendimento com operacao "faturamento" ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Uso       |CALL CENTER						                           ³±?
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
±±³Fun‡…o    | ValObrSA1       ³Autor  ³Microsiga        |Data  |30/06/04  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o |Verifica se os campos obrigatorios do cadastro de clientes   ³±?
±±|          |estao preenchidos no cadastro de prospects.                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Uso       |CALL CENTER						                           ³±?
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
				IW_MSGBOX("O campo "+aCampObrig[nI]+" n? existe no cadastro de prospect, Depto de Tecnologia Imdepa.",'Aten?o','ALERT')
			Endif
		Endif
	next
	If !lRet
		IW_MSGBOX("Campos obrigat?ios n? preenchidos. Para efetivar esta venda, Tecle em <Altera?o da Entidade> e preencha os campos com asterisco (*)",'Aten?o','ALERT')
	Else
		If Empty(SUS->US_INSCR) .AND. !MsgYesNo( 'Tem certeza que este cliente n? possui inscri?o estadual?', 'Cadastro de clientes' )
			IW_MSGBOX("Tecle em <Altera?o da Entidade> e preencha o campo 'Inscri?o Estadual'",'Aten?o','INFO')
			lRet := .F.
		Endif
	Endif
Else
	If Type("lTk271Auto") == "U" .Or. !lTk271Auto
		Alert("Prospect n? cadastrado")
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


******************************************************************
Static Function PedFinMin() // Limita o Pedido Minimo para Faturameto..
********************************************************************
Local aValPedMi 	:= GetMV("IM_PEDMINF")// Pedido Minimo Faturamento...
Local aValorTotal	:= aValores[8]
Local cMen			:= ""
Local cLibPedMin	:= IF(!lProspect,Posicione( "SA1" , 1 , xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA , "A1_CLFAMIN" ),Posicione( "SUS" , 1 , xFilial("SUS")+M->UA_CLIENTE+M->UA_LOJA , "US_CLFAMIN" ))

Local aParc := Condicao( aValores[8] , M->UA_CONDPG , , dDataBase )

Local i := 1
Local j := 1

cMen += "O Valor Total do Pedido R$ "+CvalToChar(aValorTotal)+" ?inferior ao mimo permitido para Faturamento. " + CHR(13)+CHR(10) + CHR(13)+CHR(10)
cMen += "Opções?:" + CHR(13)+CHR(10) + CHR(13)+CHR(10)
cMen += " 1 - Alterar para Orçamento. " + CHR(13)+CHR(10)
cMen += " 2 - Atingir o Valor Minimo. " + CHR(13)+CHR(10) + CHR(13)+CHR(10)
cMen += "Valor Minimo Permitido para Faturamento ?R$ " + CvalToChar(aValPedMi)

//aParcelas


If ( M->UA_OPER == "1" ) // Faturamento

	If ( cLibPedMin == "N" ) // Libera Pedido abaixo do Minimo ? S->SIM , N->NAO

		If ( aValorTotal <= aValPedMi )
			Iw_MsgBox(cMen,"Atenção","ALERT")

			For i := 1 To Len(aValores)
				aValores[i] := 0
			Next

			Return ( .F. )
		EndIf

	EndIf

	If  Len(aParc) > 1
		For j := 1 To Len(aParc) //| Boqueia o Pv se a Parcela estiver abaixo do valor do parametro. - Agostinho Lima - 05/10/2015

			If (aParc[j][2] < GETMV("MV_VRPEDMI") )

				Iw_MsgBox("Se mais de uma parcela, os valores das parcelas devem ser maior ou igual a " + Alltrim(str(GETMV("MV_VRPEDMI")))+ " !" ,"Atenção?","ALERT")

				Return ( .F. )
			EndIf

		Next
	Endif

EndIF


Return(.T.)
**********************************************************************
Static Function ChkDescAcre(nLinha)
**********************************************************************
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//|  NECESSARIO ZERAR VALOR DO DESCONTO \ ACRESCIMO PARA NAO INFLUENCIAR NA NOTA FISCAL		|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

If GdFieldGet('UB_DESC',nLinha) > 0 .Or. GdFieldGet('UB_VALDESC',nLinha) > 0
	GdFieldPut('UB_DESC',    0,	nLinha)
	GdFieldPut('UB_VALDESC', 0, nLinha)
EndIf

If GdFieldGet('UB_ACRE',nLinha) > 0 .Or. GdFieldGet('UB_VALACRE', nLinha) > 0
	GdFieldPut('UB_ACRE',    0, nLinha)
	GdFieldPut('UB_VALACRE', 0, nLinha)
EndIf

Return()
**********************************************************************
User Function ChkQtdxVlr()
**********************************************************************
Local aAreaAnt 	:= 	GetArea()
Local lRetorno 	:= 	.T.
Local cMsgQtd	:= 	''
Local aDivPrc 	:= 	{}
Local aDivCor 	:= 	{}
Local nE4Acresc := 	Posicione('SE4',1,xFilial('SE4')+M->UA_CONDPG,'E4_ACRSFIN')
Local lCorreia	:=	.F.
Local cFilEstC 	:= 	GetMv('MV_FILESTC')
Local cNotTes	:=	''
Local oDlgDiv
Local oSay1
Local cNumPV	:=	IIF(Type('ParamIxb')== 'A', ParamIxb[01], '')

IIF(!ExisteSX6('IM_NOTTES'), CriarSX6('IM_NOTTES', 'C','Nao verificar TES na Confirmacao AT - TKGRPED', '508' ),)
cNotTes	:= GetMv('IM_NOTTES')

IIF(!ExisteSX6('IM_NOTATEN'), CriarSX6('IM_NOTATEN', 'C','Nao verificar AT na Confirmacao AT', '' ),)
cNotAT	:= GetMv('IM_NOTATEN')

IIF(!ExisteSX6('IM_TOLEPRC'), CriarSX6('IM_TOLEPRC', 'N','Tolerancia entre (PrcUnit+%Acres)x(Prc.C/Acres)', '0.00' ),)
nToler	:= GetMv('IM_TOLEPRC')

IIF(!ExisteSX6('IM_TESXIMP'), CriarSX6('IM_TESXIMP', 'C','Tes PODE gerar ou nao impostos. TKGRPED', '719' ),)
cTesXImp	:= GetMv('IM_TESXIMP')

IIF(!ExisteSX6('IM_TOLEIPI'), CriarSX6('IM_TOLEIPI', 'N','Tolerancia entre valore de IPI', '0.05'),)
nIPIToler	:= GetMv('IM_TOLEIPI')



For xY:= 1 To Len(aCols)

	If !GdDeleted(xY)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//|  	  PROJETO CORREIAS			  |
		//|	VERIFICA SALDO PRODUTO CORREIA	  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		If M->UA_OPER == '1' //.And. IsInCallStack("U_TKGRPED")
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
									//| QUANDO DISPARADO DO BTN. COND.PGTO	|
									//|	NAO EXECUTAR, AO CONFIRMAR O ATEND.	|
									//| E ITEM CORREIA NAO TIVER SALDO NAO  |
									//| IRA GRAVAR PV.						|
									//| TB CHAMDO NO PE TMKCND PARA OUTRAS 	|
									//| VALIDACOES							|
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

			lCorreia := !Empty(A093VldBase(GdFieldGet("UB_PRODUTO",xY)))
			If lCorreia


				If !ChkSC9Lib(cNumPV, GdFieldGet("UB_ITEM",xY), GdFieldGet("UB_PRODUTO",xY))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					//|          PROJETO CORREIAS            		|
					//| VERIFICA SALDOs DOS ITENS DO ATENDIEMTNTO	|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					cRotina  	:= 	'TKGRPED'
					aOpcao	 	:=	{'VALID_SALDO'}
					cProduto 	:= 	GdFieldGet("UB_PRODUTO",xY)
					aParam	 	:= 	{}
					nLinha	 	:= 	xY
					xRetorno 	:=	'ARRAY_DIVERG'
					aRetorno 	:= 	ExecBlock('ChkCorreias', .F., .F., {cRotina, aOpcao, cProduto, aParam, nLinha, xRetorno})
					aProblem 	:=	aRetorno
					If Len(aProblem) > 0
						//aDivCor := aProblem
						Aadd(aDivCor, aProblem[01])
					EndIf
				EndIf


			EndIf

		EndIf





		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//|   VERIFICA SE USUARIO INFORMOU QUANTIDADE		|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		If Ascan(__aItDigQtd,xy) == 0
			cMsgQtd += 'ITEM:  '+ AllTrim(GdFieldGet("UB_ITEM",xY)) +'   PRODUTO: '+ AllTrim(GdFieldGet("UB_PRODUTO",xY)) +' - '+ AllTrim(GdFieldGet("UB_DESCRI",xY))+ENTER
		EndIf



		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//|   VERIFICA PRECO\VALORES - TELA DIVERGENCIA PRECO	|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		If !(cFilAnt+M->UA_NUM $ cNotAT)

			cDiverg 	:= 	''
	       nToler		:=	nToler // 0.01

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//|  (PRC.UNIT + %ACRESC.FIN) != PRC.ACRESC			|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			nVlrUAcre 	 := NoRound(GdFieldGet("UB_VRUNIT",xY) *(1+(nE4Acresc/100)),2)
			nVlrAcre 	 := NoRound(GdFieldGet("UB_VRCACRE",xY),2)
			lUnitDifAcre := nVlrUAcre != nVlrAcre
		   	lUnitDifAcre := IIF(lUnitDifAcre .And. ((nVlrAcre - nVlrUAcre) > nToler), .T., .F.)
			cDiverg		 += IIF(lUnitDifAcre, '[ (PRC.UNIT+ACRESC) <> PRC.C\ACRESC ]', '')


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//|  PRC.UNIT > PRC.ACRESC		|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		   	lUnitMaAcre	:=	NoRound(GdFieldGet("UB_VRUNIT",xY),2) >  NoRound(GdFieldGet("UB_VRCACRE",xY),2)
			cDiverg	+= IIF(lUnitMaAcre, '[ (PRC.UNIT) MAIOR PRC.C\ACRESC ]', '')



			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//|  PRC.UNIT < PRC.TABELA e DESCONTO == ZERO    |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			/*
			lUnitMeTab	:=	NoRound(GdFieldGet("UB_VRUNIT",xY),2) <  NoRound(GdFieldGet("UB_PRCTAB",xY), 2) .And.;
							GdFieldGet("UB_DESCVEN",xY) == 0

			cDiverg	+= IIF(lUnitMeTab, '[ (PRC.UNIT) MENOR PRC.TABELA e ZERO%DESC ]', '')
			*/

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//|  PRC.UNIT < PRC.TABELA e DESCONTO > ZERO (PODE SER RESERVA)		|
			//|	  CHECA SE (PRC.UNIT + %ACRESC.FIN) == PRC.C\ACRESC				|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//If !lUnitMeTab
				If NoRound(GdFieldGet("UB_VRUNIT",xY),2) <  NoRound(GdFieldGet("UB_PRCTAB",xY), 2) .And.;
						   	 GdFieldGet("UB_DESCVEN",xY) > 0


					nVlrUAcre 	 := NoRound(GdFieldGet("UB_VRUNIT",xY) *(1+(nE4Acresc/100)),2)
					nVlrAcre 	 := NoRound(GdFieldGet("UB_VRCACRE",xY),2)
					If nVlrUAcre != nVlrAcre
						If (nVlrAcre - nVlrUAcre) > nToler
							// lUnitMeTab 	:= .F.
							cDiverg		+= '[ (PRC.UNIT) MENOR PRC.TABELA e %DESC > ZERO e (PRC.UNIT+ACRESC) <> PRC.C\ACRESC ]'
						EndIf
					EndIf

				EndIf
			//EndIf



			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?ÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|  PRC.UNIT == PRC.TABELA e TES <> PARAMETRO	|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?ÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If NoRound(GdFieldGet("UB_VRUNIT",xY),2) == NoRound(GdFieldGet("UB_PRCTAB",xY), 2) .And.;
			   AT(GdFieldGet("UB_TES",xY), cNotTes) == 0 //!(cNotTes $ GdFieldGet("UB_TES",xY))

				If GdFieldGet("UB_DESCVEN",xY) == 0

					If cTesXImp == GdFieldGet("UB_TES",xY)

						nRedPis := Posicione('SB1',1,xFilial('SB1')+GdFieldGet("UB_PRODUTO",xY),'B1_REDPIS')
						nRedCof := Posicione('SB1',1,xFilial('SB1')+GdFieldGet("UB_PRODUTO",xY),'B1_REDCOF')

						If nRedPis != 100 .And. nRedCof != 100
							cDiverg	+= '[ PRC.UNIT IGUAL PRC.TABELA e TES <> PARAM e %DESC == ZERO e REDUZ.PIS\COF <> 100 ]'
					    EndIf

					Else
						cDiverg	+= '[ PRC.UNIT IGUAL PRC.TABELA e TES <> PARAM e %DESC == ZERO ]'
      				EndIf

				EndIf
			EndIf



			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?ÄÄ?ÄÄÄÄ?Ä¿
			//|  VERIFICA SE VALOR DO IPI ESTA CORRETO	|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?ÄÄ?ÄÄ?ÄÄ??
			nVlrCalcIPI 	:= 	Round( (GdFieldGet("UB_VRCACRE",xY) * GdFieldGet("UB_ALIQIPI",xY) / 100), TamSx3('UB_ACREIPI')[02])
			nVlrSisIPI		:=	GdFieldGet("UB_VALIPI",xY)

			If nVlrCalcIPI != nVlrSisIPI
				nMaxIPI	 	:= 	Max(nVlrCalcIPI, nVlrSisIPI)
				nMinIPI		:=	Min(nVlrCalcIPI, nVlrSisIPI)
				If (nMaxIPI - nMinIPI) > nIPIToler
					cDiverg	+= '[ DIVERG.IPI -> PRC.ACRES x ALIQ.IPI <> VALOR IPI.   PRC.ACRES.: '+cValToChar(GdFieldGet("UB_VRCACRE",xY))+' x  ALIQ.IPI: '+cValToChar(GdFieldGet("UB_ALIQIPI",xY))+'  <>  '+cValToChar(GdFieldGet("UB_VALIPI",xY))+'  (CORRETO: '+cValToChar(nVlrCalcIPI)+') ]'
				EndIf
			EndIf


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?Ä¿
			//|  GRAVA ARRAY COM DIVERGENCIAS	|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?ÄÙ
	        If !Empty(cDiverg)
				cDiverg += ' AT. '+M->UA_NUM
				Aadd(aDivPrc, {AllTrim(GdFieldGet("UB_ITEM",xY)), AllTrim(GdFieldGet("UB_PRODUTO",xY)), AllTrim(GdFieldGet("UB_DESCRI",xY)), GdFieldGet("UB_VRUNIT",xY), GdFieldGet("UB_VRCACRE",xY), GdFieldGet("UB_PRCTAB",xY), nE4Acresc, GdFieldGet("UB_DESCVEN",xY), cDiverg })
			EndIf


		EndIf

	EndIf

Next




If !Empty(cMsgQtd)
	IW_MSGBOX("FAVOR CONFIRMAR A QUANTIDADE DO(S) SEGUINTE(S) ITEM(S):"+ENTER+ENTER+cMsgQtd+ENTER,'Aten?o','ALERT')
	lRetorno := .F.

ElseIf Len(aDivPrc) > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//|   		TELA DIVERGENCIA PRECO   		|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	/*
	 Aadd(aDivPrc, {	AllTrim(GdFieldGet("UB_ITEM",xY)),;		[01]
						AllTrim(GdFieldGet("UB_PRODUTO",xY)),;	[02]
						AllTrim(GdFieldGet("UB_DESCRI",xY)),;	[03]
						GdFieldGet("UB_VRUNIT",xY),; 			[04]
						GdFieldGet("UB_VRCACRE",xY),; 			[05]
						GdFieldGet("UB_PRCTAB",xY),;			[06]
						nE4Acresc,;								[07]
						GdFieldGet("UB_DESCVEN",xY),;			[08]
	 					cDiverg )}								[09]
    */

	Define Dialog oDlgDiv Title "Divergência Preços" From 120,120 To 360,780 Pixel STYLE DS_MODALFRAME

		oDlgDiv:lEscClose := .F.

		oFont1	:= TFont():New( "Arial",0,16,,.T.,0,,700,.F.,.F.,,,,,, )
	    oBrowse := TcBrowse():New(020, 001, 330, 085,,{'Item','Produto','Descrição','Prc.Unit','Prc.c\Acre','Prc.Tabela','%Acresc','Divergência'},{/*50,50,50*/},oDlgDiv,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	    oBrowse:SetArray(aDivPrc)

		oSay1  := TSay():New( 007,080,{|| "D I V E R G ?N C I A   D E   P R E ÇO"+Space(25)+IIF(cFilAnt!='05','',"Ligar para TI - POA") },,,oFont1,.F.,.F.,.F.,.T.,CLR_HRED,CLR_WHITE,225,020 )

	    oBrowse:AddColumn( TcColumn():New('Item At.'		,{|| aDivPrc[oBrowse:nAt][01] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	    oBrowse:AddColumn( TcColumn():New('Produto'			,{|| aDivPrc[oBrowse:nAt][02] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	    oBrowse:AddColumn( TcColumn():New('Descrição'		,{|| aDivPrc[oBrowse:nAt][03] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	    oBrowse:AddColumn( TcColumn():New('Prc.c\Acre'		,{|| aDivPrc[oBrowse:nAt][05] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	    oBrowse:AddColumn( TcColumn():New('Prc.Unit'		,{|| aDivPrc[oBrowse:nAt][04] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	    oBrowse:AddColumn( TcColumn():New('Prc.Tabela'		,{|| aDivPrc[oBrowse:nAt][06] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	    oBrowse:AddColumn( TcColumn():New('% Acresc'		,{|| aDivPrc[oBrowse:nAt][07] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	    oBrowse:AddColumn( TcColumn():New('Desc.Vend'		,{|| aDivPrc[oBrowse:nAt][08] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	    oBrowse:AddColumn( TcColumn():New('Divergência'		,{|| aDivPrc[oBrowse:nAt][09] },,,,"LEFT",,.F.,.T.,,,,.F.,) )


	    TButton():New( 107, 290, '&Retornar',  oDlgDiv,{|| lRetorno:= .F., GravaLog(aDivPrc), oDlgDiv:End() },30,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	    //TButton():New( 107, 285, '&Continuar', oDlgDiv,{|| lRetorno:= .T., oDlgDiv:End() },30,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	Activate Dialog oDlgDiv Centered

EndIf



If Len(aDivCor) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//|   		TELA PROJETO CORREIAS   		|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	/*	Aadd(aDivCor, {	AllTrim(GdFieldGet("UB_ITEM",xY)), 		[01]
						AllTrim(GdFieldGet("UB_PRODUTO",xY)),	[02]
						AllTrim(GdFieldGet("UB_DESCRI",xY)), 	[03]
						GdFieldGet("UB_QUANT",xY),	 			[04]
						nSaldoC })								[05]
	*/

	Define Dialog oDlgDiv Title "Produto(s) Correia Sem Saldo" From 120,120 To 360,780 Pixel

		oFont1	:= TFont():New( "Arial",0,16,,.T.,0,,700,.F.,.F.,,,,,, )
	    oBrowse := TcBrowse():New(020, 001, 330, 085,,{'Item','Produto','Descrição','Quant.','Saldo'},{/*50,50,50*/},oDlgDiv,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	    oBrowse:SetArray(aDivCor)

		oSay1  := TSay():New( 007,040,{|| " PRODUTO \ CORREIA SEM SALDO  -  OS SEGUINTES ITENS NÃO SERÃO GRAVADOS"+Space(25) },,,oFont1,.F.,.F.,.F.,.T.,CLR_HRED,CLR_WHITE,300,020 )

	    oBrowse:AddColumn( TcColumn():New('Item At.'		,{|| aDivCor[oBrowse:nAt][01] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	    oBrowse:AddColumn( TcColumn():New('Produto'			,{|| aDivCor[oBrowse:nAt][02] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	    oBrowse:AddColumn( TcColumn():New('Descrição'		,{|| aDivCor[oBrowse:nAt][03] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	    oBrowse:AddColumn( TcColumn():New('Quant.'			,{|| aDivCor[oBrowse:nAt][04] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	    oBrowse:AddColumn( TcColumn():New('Saldo'			,{|| aDivCor[oBrowse:nAt][05] },,,,"LEFT",,.F.,.T.,,,,.F.,) )

	    TButton():New( 107, 290, '&Retornar',  oDlgDiv,{|| lRetorno:= .F., oDlgDiv:End() },30,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	Activate Dialog oDlgDiv Centered

EndIf



RestArea(aAreaAnt)
Return(lRetorno)
**********************************************************************
Static Function ChkSC9Lib(cNumPV, cItemPV, cProdPV)
**********************************************************************
Local aAreaAnt := 	GetArea()
Local lRetorno	:=	.F.
If !Empty(cNumPV)
	IIF(Select('TMPSC9')!=0, TMPMSC9->(DbCloseArea()), )
	cQuery := " SELECT	C9_FILIAL, C9_PEDIDO, C9_PRODUTO, C9_LOCAL, C9_BLEST, C9_BLCRED, C9_BLWMS, C9_RESERVA, C9_QTDRESE, C9_SEQUEN "+ENTER
	cQuery += " FROM 	"+RetSqlName("SC9")+" SC9   			   	"+ENTER
	cQuery += " WHERE 	SC9.C9_FILIAL 	=  '"+xFilial('SC9')+"' 	"+ENTER
	cQuery += " AND 	SC9.C9_PEDIDO 	=  '"+cNumPV+"'				"+ENTER
	cQuery += " AND 	SC9.C9_ITEM 	=  '"+cItemPV+"'			"+ENTER
	cQuery += " AND 	SC9.C9_PRODUTO 	=  '"+cProdPV+"'			"+ENTER
	cQuery += " AND 	SC9.D_E_L_E_T_ 	!=  '*' 					"+ENTER

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPSC9', .F., .T.)
	nQtdReg := 0
	TMPSC9->(DbGoTop())
	TMPSC9->(dbEval({||nQtdReg++},,,1))

	DbSelectArea('TMPSC9');DbGoTop()
	lRetorno := IIF(nQtdReg==0, .F., .T.)
	lRetorno := IIF(lRetorno, IIF(Empty(TMPSC9->C9_BLEST).And.Empty(TMPSC9->C9_BLCRED), .T., .F.), .F.)
EndIf
IIF(Select('TMPSC9')!=0, TMPSC9->(DbCloseArea()), )
RestArea(aAreaAnt)
Return(lRetorno)
**********************************************************************
Static Function GravaLog(aDivPrc)
**********************************************************************
/*
    oBrowse:AddColumn( TcColumn():New('Item At.'		,{|| aDivPrc[oBrowse:nAt][01] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
    oBrowse:AddColumn( TcColumn():New('Produto'			,{|| aDivPrc[oBrowse:nAt][02] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
    oBrowse:AddColumn( TcColumn():New('Descrição'		,{|| aDivPrc[oBrowse:nAt][03] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
    oBrowse:AddColumn( TcColumn():New('Prc.c\Acre'		,{|| aDivPrc[oBrowse:nAt][05] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
    oBrowse:AddColumn( TcColumn():New('Prc.Unit'		,{|| aDivPrc[oBrowse:nAt][04] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
    oBrowse:AddColumn( TcColumn():New('Prc.Tabela'		,{|| aDivPrc[oBrowse:nAt][06] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
    oBrowse:AddColumn( TcColumn():New('% Acresc'		,{|| aDivPrc[oBrowse:nAt][07] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
    oBrowse:AddColumn( TcColumn():New('Desc.Vend'		,{|| aDivPrc[oBrowse:nAt][08] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
    oBrowse:AddColumn( TcColumn():New('Divergência'		,{|| aDivPrc[oBrowse:nAt][09] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
*/


If !TcCanOpen('LOGDIVERG')
	cQuery := "CREATE TABLE LOGDIVERG ( 	FILIAL		VARCHAR(02),	"
	cQuery += "							NUMAT 		VARCHAR(06),	"
	cQuery += "							ITEMAT 		VARCHAR(03),	"
	cQuery += "							DATALOG		VARCHAR(08),	"
	cQuery += "							DATASYS		VARCHAR(08),	"
	cQuery += "							PRODUTO		VARCHAR(15),	"
	cQuery += "							DESCRICAO	VARCHAR(60),	"
	cQuery += "							PRCACRE		NUMBER(12,4),	"
	cQuery += "							PRCUNIT		NUMBER(12,4),	"
	cQuery += "							PRCTAB		NUMBER(14,4),	"
	cQuery += "							PERACRE		NUMBER(6,4),	"
	cQuery += "							DESCVEN		NUMBER(8,4),	"
	cQuery += "							IMPOSTOS	VARCHAR(1000), 	"
	cQuery += "							DIVERG		VARCHAR(250) 	"
	cQuery += "						  ) "

	TcSqlExec(cQuery)
EndIf



For nX:=1 To Len(aDivPrc)

	cItemAT		:=	aDivPrc[nX][01]
	cProduto	:=	aDivPrc[nX][02]
	cDescricao	:=	aDivPrc[nX][03]
	cPrcAcre	:=	cValToChar(aDivPrc[nX][04])
	cPrcUnit	:=	cValToChar(aDivPrc[nX][05])
	cPrcTab		:=	cValToChar(aDivPrc[nX][06])
	cPerAcrec	:=	cValToChar(aDivPrc[nX][07])
	cDescVend	:=	cValToChar(aDivPrc[nX][08])
	cDiverg		:=	aDivPrc[nX][09]

	IIF(Select('TMPLOG')!=0, TMPLOG->(DbCloseArea()), )
	cQuery := "SELECT COUNT(1) AS NREG FROM LOGDIVERG WHERE FILIAL = '"+cFilAnt+"' AND NUMAT = '"+M->UA_NUM+"' AND ITEMAT = '"+cItemAT+"' "
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPLOG', .F., .T.)
	DbSelectArea('TMPLOG');DbGoTop()

	cImpostos := ChkImposto(cItemAT)

	If TMPLOG->NREG == 0
		cQuery := "INSERT INTO LOGDIVERG VALUES ( '"+cFilAnt+"', '"+M->UA_NUM+"', '"+cItemAT+"', '"+DtoS(dDataBase)+"', '"+DtoS(Date())+"', '"+cProduto+"', '"+cDescricao+"', '"+cPrcAcre+"', '"+cPrcUnit+"', '"+cPrcTab+"', '"+cPerAcrec+"', '"+cDescVend+"', '"+cImpostos+"', '"+cDiverg+"')"
	Else
		cQuery := "UPDATE LOGDIVERG SET 	PRODUTO 	= '"+cProduto+"', 			"+ENTER
		cQuery += "						DESCRICAO	= '"+cDescricao+"', 		"+ENTER
		cQuery += "						DATALOG		= '"+DtoS(dDataBase)+"', 	"+ENTER
		cQuery += "						DATASYS		= '"+DtoS(Date())+"',  	"+ENTER
		cQuery += "						PRCACRE		= '"+cPrcAcre+"', 			"+ENTER
		cQuery += "						PRCUNIT		= '"+cPrcUnit+"', 			"+ENTER
		cQuery += "						PRCTAB		= '"+cPrcTab+"', 			"+ENTER
		cQuery += "						PERACRE		= '"+cPerAcrec+"', 		"+ENTER
		cQuery += "						DESCVEN		= '"+cDescVend+"', 		"+ENTER
		cQuery += "						IMPOSTOS	= '"+cImpostos+"', 		"+ENTER
		cQuery += "						DIVERG		= '"+cDiverg+"' 			"+ENTER

		cQuery += " WHERE FILIAL = '"+cFilAnt+"' AND NUMAT = '"+M->UA_NUM+"' AND ITEMAT = '"+cItemAT+"'
	EndIf

	TcSqlExec(cQuery)

Next


IIF(Select('TMPLOG')!=0, TMPLOG->(DbCloseArea()), )
Return()
**********************************************************************
Static Function ChkImposto(cItemAT)
**********************************************************************
Local cRetorno 		:=	''
Local aParametro	:=	{}
Local nPItem		:= 	Ascan(aHeader, {|x| AllTrim(x[2]) == "UB_ITEM" })

nLinha := Ascan(aCols, {|X| AllTrim(X[nPItem]) == AllTrim(cItemAT) })


If nLinha > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//| CARREGA TODOS OS IMPOSTOS			  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	aNF_IMPOSTOS := MaFisRet(, "NF_IMPOSTOS")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//| VERIFICA SE IMPOSTO EXISTE EM aNF_IMPOSTOS		|
	//|	 CheckImpXProd() ALIMENTA\ATUALIZA aProdXImp	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If Ascan(aNF_IMPOSTOS, {|X| 'ICM' $ X[2]} ) > 0

	    // Imposto sobre operações relativas a circulação de mercadorias e sobre prestações de serviços
		// aIT_ICMS	:= MaFisRet(nLinha, "IT_ICMS") 			//	Array contendo os valores de ICMS
		nIT_BASEICM	:= MaFisRet(nLinha, "IT_BASEICM") 		//	Valor da Base de ICMS
		nIT_ALIQICM	:= MaFisRet(nLinha, "IT_ALIQICM") 		//	Aliquota de ICMS
		nIT_VALICM		:= MaFisRet(nLinha, "IT_VALICM") 		//	Valor do ICMS Normal
		IIF(nIT_VALICM > 0, Aadd(aParametro, {'ICM', nIT_BASEICM, nIT_ALIQICM, nIT_VALICM, "IT_VALICM"}),)


		nIT_BASESOL	:= MaFisRet(nLinha, "IT_BASESOL") 		//	Base do ICMS Solidario
		nIT_ALIQSOL	:= MaFisRet(nLinha, "IT_ALIQSOL") 		//	Aliquota do ICMS Solidario
		nIT_VALSOL		:= MaFisRet(nLinha, "IT_VALSOL") 		//	Valor do ICMS Solidario
		IIF(nIT_VALSOL > 0, Aadd(aParametro, {'ICR', nIT_BASESOL, nIT_ALIQSOL, nIT_VALSOL, "IT_VALSOL" }),)


		nIT_BASEICM	:= MaFisRet(nLinha, "IT_BASEICM") 		//	Valor da Base de ICMS
		nIT_ALIQCMP	:= MaFisRet(nLinha, "IT_ALIQCMP")	 	//	Aliquota para calculo do ICMS Complementar
		nIT_VALCMP		:= MaFisRet(nLinha, "IT_VALCMP") 		//	Valor do ICMS Complementar do item
		IIF(nIT_VALCMP > 0, Aadd(aParametro, {'ICC', 0, nIT_ALIQCMP,  nIT_VALCMP, "IT_VALCMP" }),)


		nIT_BASEICA	:= MaFisRet(nLinha, "IT_BASEICA") 		//	Base do ICMS sobre o frete autonomo
		nIT_VALICA		:= MaFisRet(nLinha, "IT_VALICA") 		//	Valor do ICMS sobre o frete autonomo
		nIT_VALICA		:= MaFisRet(nLinha, "IT_VALICA") 		//	Valor do Frete Autonomo
		IIF(nIT_VALICA > 0, Aadd(aParametro,  {'ICA', nIT_BASEICA, nIT_VALICA, nIT_VALICA, "IT_VALICA" }),)


		nIT_BASETST	:= MaFisRet(nLinha, "IT_BASETST")  		//	Base do ICMS sobre o frete autonomo
		nIT_ALIQTST	:= MaFisRet(nLinha, "IT_ALIQTST")  		//	Valor do ICMS sobre o frete autonomo
		nIT_VALTST		:= MaFisRet(nLinha, "IT_VALTST")  		//	Valor do Frete Autonomo
		IIF(nIT_VALTST > 0, Aadd(aParametro, {'TST', nIT_BASETST, nIT_ALIQTST, nIT_VALTST, "IT_VALTST" }),)


	EndIf


	If Ascan(aNF_IMPOSTOS, {|X| 'IPI' $ X[2]} )  > 0
	    // O Imposto sobre Produtos Industrializados
		// aIT_IPI 	:= MaFisRet(nLinha, "IT_IPI")			//	Array contendo os valores de IPI

		nIT_BASEIPI	:= MaFisRet(nLinha, "IT_BASEIPI") 		//	Valor da Base do IPI
		nIT_ALIQIPI	:= MaFisRet(nLinha, "IT_ALIQIPI") 		//	Aliquota de IPI
		nIT_VALIPI 	:= MaFisRet(nLinha, "IT_VALIPI") 		//	Valor do IPI
		IIF(nIT_VALIPI > 0, Aadd(aParametro, {'IPI', nIT_BASEIPI, nIT_ALIQIPI, nIT_VALIPI, "IT_VALIPI" }) ,)


	EndIf


	If Ascan(aNF_IMPOSTOS, {|X| 'ISS' $ X[2]} ) > 0
		//	Instituto Nacional do Seguro Social
		// aIT_ISS 	:= MaFisRet(nLinha, "IT_ISS") 			//	Array contendo os valores de ISS
		nIT_BASEISS 	:= MaFisRet(nLinha, "IT_BASEISS")		//	Base de Calculo do ISS
		nIT_ALIQISS	:= MaFisRet(nLinha, "IT_ALIQISS")  		//	Aliquota de ISS do item
		nIT_VALISS 	:= MaFisRet(nLinha, "IT_VALISS")			//	Valor do ISS do item
		IIF(nIT_VALISS > 0, Aadd(aParametro, {'ISS', nIT_BASEISS, nIT_ALIQISS, nIT_VALISS, "IT_VALISS" }	),)

	EndIf

	If Ascan(aNF_IMPOSTOS, {|X| 'IRR' $ X[2]} ) > 0
		// aIT_IR 		:= MaFisRet(nLinha, "IT_IR")			//	Array contendo os valores do Imposto de renda
		nIT_BASEIRR 	:= MaFisRet(nLinha, "IT_BASEIRR")		//	Base do Imposto de Renda do item
		nIT_ALIQIRR	:= MaFisRet(nLinha, "IT_ALIQIRR") 		//	Aliquota de Calculo do IR do Item
		nIT_VALIRR 	:= MaFisRet(nLinha, "IT_VALIRR")			//	Valor do IR do Item
		IIF(nIT_VALIRR > 0, Aadd(aParametro, {'IRR', nIT_BASEIRR, nIT_ALIQIRR, nIT_VALIRR, "IT_VALIRR" }),)

	EndIf

	If Ascan(aNF_IMPOSTOS, {|X| 'INSS' $ X[2]} ) > 0
		//	(Instituto Nacional do Seguro Social
		// aIT_INSS 	:= MaFisRet(nLinha, "IT_INSS")		//	Array contendo os valores de INSS
		nIT_BASEINS	:= MaFisRet(nLinha, "IT_BASEINS") 		//	Base de calculo do INSS
		nIT_ALIQINS	:= MaFisRet(nLinha, "IT_ALIQINS") 		//	Aliquota de Calculo do INSS
		nIT_VALINS 	:= MaFisRet(nLinha, "IT_VALINS")			//	Valor do INSS
		IIF(nIT_VALINS > 0, Aadd(aParametro, {'INS', nIT_BASEINS, nIT_ALIQINS, nIT_VALINS, "IT_VALINS" }),)


		nIT_BASEINA	:= MaFisRet(nLinha, "IT_BASEINA") 		//	Base de calculo do INSS Condições Especiais
		IT_ALIQINA  	:= MaFisRet(nLinha, "IT_ALIQINA")		//	Aliquota de calculo do INSS Condições Especiais
		nIT_VALINA		:= MaFisRet(nLinha, "IT_VALINA") 		//	Valor do INSS Condições Especiais
		IIF(nIT_VALINA > 0, Aadd(aParametro, {'INA', nIT_BASEINA, nIT_ALIQINA, nIT_VALINA, "IT_VALINA" }),)

	EndIf



	If Ascan(aNF_IMPOSTOS, {|X| 'PIS' $ X[2]} ) > 0
		// Programa de Integração Social

		nIT_BASEPIS	:= MaFisRet(nLinha, "IT_BASEPIS") 		//	Base de calculo do PIS
		nIT_ALIQPIS 	:= MaFisRet(nLinha, "IT_ALIQPIS")		//	Aliquota de calculo do PIS
		nIT_VALPIS 	:= MaFisRet(nLinha, "IT_VALPIS")			//	Valor do PIS
		IIF(nIT_VALPIS > 0, Aadd(aParametro, {'PIS', nIT_BASEPIS, nIT_ALIQPIS, nIT_VALPIS, "IT_VALPIS" }),)



		nIT_BASEPIS	:= MaFisRet(nLinha, "IT_BASEPS2") 		//	Base de calculo do PIS
		nIT_ALIQPIS 	:= MaFisRet(nLinha, "IT_ALIQPS2")		//	Aliquota de calculo do PIS
		nIT_VALPIS 	:= MaFisRet(nLinha, "IT_VALPS2")		//	Valor do PIS
		IIF(nIT_VALPIS > 0, Aadd(aParametro, {'PS2', nIT_BASEPIS, nIT_ALIQPIS, nIT_VALPIS, "IT_VALPS2" }),)



		nIT_BASEPIS	:= MaFisRet(nLinha, "IT_BASEPS3") 		//	Base de calculo do PIS
		nIT_ALIQPIS 	:= MaFisRet(nLinha, "IT_ALIQPS3")		//	Aliquota de calculo do PIS
		nIT_VALPIS 	:= MaFisRet(nLinha, "IT_VALPS3")			//	Valor do PIS
		IIF(nIT_VALPIS > 0, Aadd(aParametro, {'PS3', nIT_BASEPIS, nIT_ALIQPIS, nIT_VALPIS, "IT_VALPS3" }),)



	EndIf



	If Ascan(aNF_IMPOSTOS, {|X| 'COF' $ X[2]} )  > 0
		// Contribuição para o Financiamento da Seguridade Social
		nIT_BASECOF 	:= MaFisRet(nLinha, "IT_BASECOF")		//	Base de calculo do COFINS
		nIT_ALIQCOF 	:= MaFisRet(nLinha, "IT_ALIQCOF")		//	Aliquota de calculo do COFINS
		nIT_VALCOF		:= MaFisRet(nLinha, "IT_VALCOF") 		//	Valor do COFINS
		IIF(nIT_VALCOF > 0, Aadd(aParametro, {'COF', nIT_BASECOF, nIT_ALIQCOF, nIT_VALCOF, "IT_VALCOF" }),)



		nIT_BASECOF := MaFisRet(nLinha, "IT_BASECF2") 		//	Base de calculo do COFINS
		nIT_ALIQCOF := MaFisRet(nLinha, "IT_ALIQCF2") 		//	Aliquota de calculo do COFINS
		nIT_VALCOF	  := MaFisRet(nLinha, "IT_VALCF2")  		//	Valor do COFINS
		IIF(nIT_VALCOF > 0, Aadd(aParametro, {'CF2', nIT_BASECOF, nIT_ALIQCOF, nIT_VALCOF, "IT_VALCF2" }),)



		nIT_BASECOF 	:= MaFisRet(nLinha, "IT_BASECF3") 		//	Base de calculo do COFINS
		nIT_ALIQCOF 	:= MaFisRet(nLinha, "IT_ALIQCF3") 		//	Aliquota de calculo do COFINS
		nIT_VALCOF		:= MaFisRet(nLinha, "IT_VALCF3")  		//	Valor do COFINS
		IIF(nIT_VALCOF > 0, Aadd(aParametro, {'CF3', nIT_BASECOF, nIT_ALIQCOF, nIT_VALCOF, "IT_VALCF3" }),)

	EndIf



	If Ascan(aNF_IMPOSTOS, {|X| 'CSL' $ X[2]} ) > 0
		// Contribuição Social sobre o Lucro Líquido
		nIT_BASECSL	:= MaFisRet(nLinha, "IT_BASECSL") 		//	Base de calculo do CSLL
		nIT_ALIQCSL 	:= MaFisRet(nLinha, "IT_ALIQCSL")		//	Aliquota de calculo do CSLL
		nIT_VALCSL		:= MaFisRet(nLinha, "IT_VALCSL") 		//	Valor do CSLL
		IIF(nIT_VALCSL > 0, Aadd(aParametro,  {'CSL', nIT_BASECSL, nIT_ALIQCSL, nIT_VALCSL, "IT_VALCSL" }),)

	EndIf

	If Ascan(aNF_IMPOSTOS, {|X| 'FUN' $ X[2]} ) > 0
		//	Fundo de Assistência ao Trabalhador Rural
		nIT_BASEFUN	:= MaFisRet(nLinha, "IT_BASEFUN") 		//	Base de calculo do FunRural
		nIT_PERFUN  	:= MaFisRet(nLinha, "IT_PERFUN")			//	Aliquota de calculo do FunRural
		nIT_FUNRURAL	:= MaFisRet(nLinha, "IT_FUNRURAL") 		//	Valor do FunRural
		IIF(nIT_FUNRURAL > 0, Aadd(aParametro, {'FRU', nIT_BASEFUN, nIT_PERFUN, nIT_FUNRURAL, "IT_FUNRURAL" }),)

	EndIf

	If Ascan(aNF_IMPOSTOS, {|X| 'SES' $ X[2]} ) > 0
		nIT_BASESES	:= MaFisRet(nLinha, "IT_BASESES") 		//	Base de calculo do SEST/SENAT
		nIT_ALIQSES 	:= MaFisRet(nLinha, "IT_ALIQSES")			//	Aliquota de calculo do SEST/SENAT
		nIT_VALSES		:= MaFisRet(nLinha, "IT_VALSES") 		//	Valor do SEST/SENAT
		IIF(nIT_VALSES > 0, Aadd(aParametro,  {'SES', nIT_BASESES, nIT_ALIQSES, nIT_VALSES, "IT_VALSES" }),)

	EndIf

	If Ascan(aNF_IMPOSTOS, {|X| 'FET' $ X[2]} ) > 0
		// Fundo Estadual de Transporte e Habitação (FETHAB) - MT
		nIT_BASEFET := MaFisRet(nLinha, "IT_BASEFET")  		//	Base de calculo do FETHAB
		nIT_ALIQFET := MaFisRet(nLinha, "IT_ALIQFET") 		//	Aliquota de calculo do FETHAB
		nIT_VALFET	 := MaFisRet(nLinha, "IT_VALFET")  		//	Valor do FETHAB
		IIF(nIT_VALFET >0, Aadd(aParametro,  {'FET', nIT_BASEFET, nIT_ALIQFET, nIT_VALFET, "IT_VALFET" }),)

	EndIf

	If Ascan(aNF_IMPOSTOS, {|X| 'FAV' $ X[2]} ) > 0
		// Fundo de Apoio a Bovinocultura de Corte
		nIT_BASEFAB	:= MaFisRet(nLinha, "IT_BASEFAB") 		//	Base de calculo do FABOV
		nIT_ALIQFAB 	:= MaFisRet(nLinha, "IT_ALIQFAB") 		//	Aliquota de calculo do FABOV
		nIT_VALFAB		:= MaFisRet(nLinha, "IT_VALFAB")  		//	Valor do FABOV
		IIF(nIT_VALFAB > 0, Aadd(aParametro, {'FAB', nIT_BASEFAB, nIT_ALIQFAB, nIT_VALFAB, "IT_VALFAB" }	),)

	EndIf

	If Ascan(aNF_IMPOSTOS, {|X| 'FAC' $ X[2]} ) > 0
		// Fundo de Apoio a Cultura da Soja (FACS) - MT
		nIT_BASEFAC	:= MaFisRet(nLinha, "IT_BASEFAC") 		//	Base de calculo do FACS
		nIT_ALIQFAC 	:= MaFisRet(nLinha, "IT_ALIQFAC") 		//	Aliquota de calculo do FACS
		nIT_VALFAC		:= MaFisRet(nLinha, "IT_VALFAC")  		//	Valor do FACS
		IIF(nIT_VALFAC > 0, Aadd(aParametro, {'FAC', nIT_BASEFAC, nIT_ALIQFAC, nIT_VALFAC, "IT_VALFAC" }),)

	EndIf

	If Ascan(aNF_IMPOSTOS, {|X| 'FUM' $ X[2]} ) > 0
		// 	Fundo Maranhense de Combate a Pobreza - FUMACOP
		nIT_BASEFUM	:= MaFisRet(nLinha, "IT_BASEFUM") 		//	Base de calculo do FUMACOP
		nIT_ALIQFUM 	:= MaFisRet(nLinha, "IT_ALIQFUM") 		//	Aliquota de calculo do FUMACOP
		nIT_VALFUM		:= MaFisRet(nLinha, "IT_VALFUM")  		//	Valor do FUMACOP
		IIF(nIT_VALFUM > 0, Aadd(aParametro, {'FUM', nIT_BASEFUM, nIT_ALIQFUM, nIT_VALFUM, "IT_VALFUM" }	),)

	EndIf

	If Ascan(aNF_IMPOSTOS, {|X| 'SEN' $ X[2]} ) > 0
		// 	Serviço Nacional de Aprendizagem Rural
		nIT_BSSENAR	:= MaFisRet(nLinha, "IT_BSSENAR") 		//	Base de calculo do SENAR
		nIT_ALSENAR 	:= MaFisRet(nLinha, "IT_ALSENAR") 		//	Aliquota de calculo do SENAR
		nIT_VLSENAR	:= MaFisRet(nLinha, "IT_VLSENAR")  		//	Valor do SENAR
		IIF(nIT_VLSENAR > 0, Aadd(aParametro,  {'SENAR', nIT_BSSENAR, nIT_ALSENAR, nIT_VLSENAR, "IT_VLSENAR" }),)

	EndIf

EndIf


For nI:=1 To len(aParametro)
	cRetorno += aParametro[nI][01]+';'
	cRetorno += cValToChar(aParametro[nI][02])+';'
	cRetorno += cValToChar(aParametro[nI][03])+';'
	cRetorno += cValToChar(aParametro[nI][04])+';'
	cRetorno += aParametro[nI][05]+';'
	cRetorno += '|'
Next

Return(cRetorno)
**********************************************************************
Static Function ChkTk010ValOk(_aParcelas)
**********************************************************************
Local nTotal		:=	0
Local _MERCADORIA	:=	1	// Valor total do mercadoria
Local _DESCONTO	:=	2	// Valor total do desconto
Local _ACRESCIMO	:=	3	// Valor do acrescimo financeiro da condicao de pagamento
Local _FRETE		:=	4	// Valor total do frete
Local _DESPESA		:=	5	// Valor total da despesa
Local _TOTAL		:=	6	// Total do pedido
Local _SUFRAMA		:=	7	// Valor total da suframa
Local _BASEDUP		:=	8	// Base da duplicata (Valor l?uido da condi?o de pagamento)

If Len(_aParcelas) > 0 .And. !Empty(_aParcelas[1][1])
	For nI := 1 To Len(_aParcelas)
		nTotal += Round(NoRound(_aParcelas[nI][2],4),2)
	Next

	If NoRound(nTotal,2) <> NoRound(aValores[_BASEDUP],2)

		ALERT('OCORREU ALGUM PROBLEMA NOS VALORES APRESENTADO.'+ENTER+'PARA CONTINUAR, CLIQUE NOVAMENTE NA CONDIÇÃO DE PAGAMENTO (F6).')

		Tk273AtuNFs()
		aValores[_MERCADORIA]	:= MaFisRet(, "NF_VALMERC")
		aValores[_SUFRAMA]	:= MaFisRet(, "NF_DESCZF")
		aValores[_TOTAL]		:= MaFisRet(, "NF_TOTAL")
		aValores[_BASEDUP]	:= MaFisRet(, "NF_BASEDUP")
		aValores[_FRETE]		:= MaFisRet(, "NF_FRETE")
		// Tk273Refresh(.T.) FAZ A MESMA COISA
	EndIf
EndIf

Return()