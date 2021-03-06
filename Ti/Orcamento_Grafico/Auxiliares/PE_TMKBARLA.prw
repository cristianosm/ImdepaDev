#Include "TOTVS.CH"

#Define MARKETING 	1
#Define VENDAS 		2
#Define COBRANCA 	3

*******************************************************************************
User Function TMKBARLA(aBtnLat) //| Inclus�o de bot�es na toolbar lateral do Call Center |
*******************************************************************************

	Aadd(aBtnlat,{"S4WB010N"	,&("{ ||U_IMDR060B(.F.)	}")	, OemToAnsi("Impressao do Orcamento/Pedido")				})
	Aadd(aBtnlat,{"OBJETIVO"	,&("{ ||U_IMDF220(.F.)	}")	, OemToAnsi("Consulta Meta de Venda")							}) //| Consulta Meta de venda
	Aadd(aBtnlat,{"S4WB011N"	,&("{ ||U_IMDF080(.F.)	}")	, OemToAnsi("System Tracking do Pedido de Venda")	})
	Aadd(aBtnLat,{"BUDGETY"		,&("{ ||U_ULTPREC() 		}")	, OemToAnsi("�ltimos Pre�os do Cliente")						})
	Aadd(aBtnlat,{"NOTE"			,&("{ ||U_COPIATT()	 		}")	, OemToAnsi("Copia Atendimento")									})
	Aadd(aBtnlat,{"DBG07"			,&("{ ||U_Mstrot2() 		}")	, OemToAnsi("Rotas das Transportadoras") 					}) //| Rotas das Transportadoras
	Aadd(aBtnLat,{"SOLICITA"	,&("{ ||U_IMDF315() 		}")	, OemToAnsi("Replica linha TMK(*)")								})

Return aBtnLat
*******************************************************************************
//User Function TMK380BTN() //| Esse ponto de entrada � executado no in�cio da fun��o, antes de qualquer comando. O objetivo � adicionar novos bot�es � tela de Marketing Ativo |
*******************************************************************************


//Return
*******************************************************************************
User Function BcoConPr()//|Chamada do botao do banco de conhecimento de produtos|
*******************************************************************************
	Local aRotBack := aClone(aRotina),;
		aArea := Getarea(),;
		nAnt := n,;
		cCpoProd, lCobranca := .F.

	n := 1
	aRotina := {}
	aAdd( aRotina, { "Conhecimento", "MsDocument", 0, 4 } )

	If nFolder == 1 // Telemarketing ou Televendas
		If (cTipoAte == "1") .OR. (cTipoAte == "4") // Telemarketing"
			cCpoProd := "UD_PRODUTO"
		ElseIf cTipoAte == "2" // Televendas
			cCpoProd := "UB_PRODUTO"
		ElseIf cTipoAte == "3" // Telecobranca
			lCobranca := .T.
		Endif
	ElseIf nFolder == 2 // Televendas
		cCpoProd := "UB_PRODUTO"
	ElseIf nFolder == 3 // Telecobranca
		lCobranca := .T.
	Endif

	If lCobranca
		Aviso( Oemtoansi("Aten��o !"), Oemtoansi("Esta rotina est� dispon�vel apenas para os atendimentos de Telemarketing e Televendas !"), { Oemtoansi("Ok") }, 2 )
	Else
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1")+u_aColsGet(nAnt,cCpoProd))
		//		U_Testes( Alias(), RecNo(), 1)
			MsDocument( Alias(), RecNo(), 1)
		Else
			Aviso( Oemtoansi("Aten��o !"), Oemtoansi("Produto n�o encontrado no cadastro de produtos !"), { Oemtoansi("Ok") }, 2 )
		Endif
	Endif

	aRotina := {}
	aRotina := aClone(aRotBack)
	n := nAnt

	Restarea(aArea)
Return NIL

*******************************************************************************
User Function ElimRes()//| Chamada do botao de elimina residuos |
*******************************************************************************
	Local aArea := Getarea(), lTelevenda := .F.

	If nFolder == 1 // Telemarketing ou Televendas
		If cTipoAte == "2" // Televendas
			lTelevenda := .T.
		Endif
	ElseIf nFolder == 2 // Televendas
		lTelevenda := .T.
	Endif

	If lTelevenda
		If !Empty(SUA->UA_NUMSC5)

		// preenche os parametros Pedido de/ate com o Pedido posicionado como default
			dbSelectArea("SX1")
			dbSetOrder(1)
			If dbSeek("MTA50004")
				Reclock("SX1",.F.)
				SX1->X1_CNT01 := SUA->UA_NUMSC5
				MsUnlock()
				dbSkip()
				If SX1->X1_GRUPO+SX1->X1_ORDEM == "MTA50005"
					Reclock("SX1",.F.)
					SX1->X1_CNT01 := SUA->UA_NUMSC5
					MsUnlock()
				Endif
			Endif

		// chama a rotina de eliminacao de residuos
			MATA500()

		Else
			Aviso( Oemtoansi("Aten��o !"), Oemtoansi("Este atendimento n�o possui Pedido de Venda vinculado !"), { Oemtoansi("Ok") }, 2 )
		Endif
	Else
		IW_MsgBox(Oemtoansi("Esta rotina est� dispon�vel apenas para os atendimentos de Televendas !"),'Aten��o','ALERT')
	Endif

	RestArea(aArea)

Return()
