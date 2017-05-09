#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "RWMAKE.CH"
#DEFINE  ENTER CHR(13)+CHR(10)

#DEFINE X_DESCNEG		30  // Dias para vencimento dos acrescimos/descontos negociados
#DEFINE ACRESCIMO		3	// Valor do acrescimo financeiro da condicao de pagamento

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TLVENT    ºAutor  ³Edivaldo Gonçalves  º Data ³  09/13/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de Entrada após seleção do Hist¢rico das ligacoes     º±±
±±º          ³atendidas pelo Televendas                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Call Center                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteracao ³ Márcio Q. Borges ³Rodar Valid de campo VRUNIT somente      º±±
±±º 27/10/07 ³                  ³quando alterar o preco de tabela e PV    º±±
±±º          ³                  ³estiver aberto.                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
**********************************************************************
User Function TLVENT()
	**********************************************************************
	Local 	cDisplay	 :=	''
	Local 	nDiasHist  	 :=	0
	Private lRecalAtend := 0
	Private cFilEstC 	 := GetMv('MV_FILESTC')

	IIF(!ExisteSX6('IM_DIAHIST'), CriarSX6('IM_DIAHIST','N','Numero de Dias para permanecer os valores do Historico', '2'), )
	nDiasHist  := GetMv('IM_DIAHIST')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  FABIANO PEREIRA - SOLUTIO            	³
	//³  ZERA VARIAVEIS PUBLICAS - TMKACTIVE()	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aProdxImp  	:= {}
	aContDesc 	:= {}
	aHistTV		:= {}
	aRegDesc	:= {}
	aImdCodR 	:= {}
	aATxRN		:= {}

	If M->UA_OPER = '1'
		cDisplay='Pedido'
	Else
		If M->UA_OPER='2'
			cDisplay='Orçamento'
		Endif
	Endif

	//Inserido por Edivaldo Gonçalves Cordeiro em 01/09/2009 - Atualiza variáveis de Memória no cabeçalho no Orçamento
	M->UA_VENDINT 	:= SUA->(U_PesqVend(M->UA_CLIENTE,M->UA_LOJA))
	M->UA_DESATIV	:= SUA->(U_PesqAtiv(M->UA_CLIENTE,M->UA_LOJA))
	//M->UA_OPERADO   := SUA->(TKOPERADOR())
	M->UA_DESCOPE   := SUA->(Posicione("SU7",1,xFilial("SU7") + M->UA_OPERADO, "U7_NOME"))
	M->UA_CODROTA	 := ""

	If AllTrim(SUA->UA_STATUS) != 'CAN'

		//Caso Emitiu NF, nao roda atualizacoes do Historico
		If  !Empty(SUA->UA_EMISNF)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ NECESSARIO RODAR aColsReCalc QUE CHAMA ROTINA PARA CALCULAR VALOR				³
			//| UNITARIO (PrcReCalc) POREM NAO ALTERA VALORES 									|
			//| -->> APENAS CARREGA ARRAY aProdxImp												|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lOnlyArray := .T.
			ExecBlock('aColsReCalc',.F.,.F.,{'TODOS', lOnlyArray})

		Else

			lRecalAtend	:= ExecBlock('ChkRecalAT',.F.,.F.)
			Processa({|| SF4->(LoadOrc())  },'Histórico '+IIF(lRecalAtend,' > '+cValToChar(nDiasHist)+' Dias',''),'Estruturando '+cDisplay+' ...')

		EndIf

	EndIf

	//|ANALISTA: CRISTIANO MACHADO DESC.: PERCENTUAL DO FRETE   DATA: 31/07/13
	U_CAMPRODAPE()
	//FIM
	
	Return(.T.)
	**********************************************************************
Static Function LoadOrc()
	**********************************************************************
	Local nAnt, nPrcTabAtu
	Local lDesNegVencido,lOrcVencido := .F.
	Local cOperAtivo  	:=	""
	Local aArea       	:= 	Getarea()
	Local lAtuPrcTab2 	:= 	.F.
	Local nDesAcreFil 	:=	0
	Local uBcf        	:=	' '
	Local nAcreMva    	:= 	0
	Local cEstATU     	:= 	GETMV("MV_ESTADO")
	Local _MERCADORIA	:=	1	// [1] VALOR TOTAL DO MERCADORIA
	Local _DESCONTO		:=	2	// [2] VALOR TOTAL DO DESCONTO
	Local _ACRESCIMO	:=	3	// [3] VALOR DO ACRESCIMO FINANCEIRO DA CONDICAO DE PAGAMENTO
	Local _FRETE		:=	4	// [4] VALOR TOTAL DO FRETE
	Local _DESPESA		:=	5	// [5] VALOR TOTAL DA DESPESA
	Local _TOTAL		:=	6	// [6] TOTAL DO PEDIDO
	Local _SUFRAMA		:=	7	// [7] VALOR TOTAL DA SUFRAMA
	Local _BASEDUP		:=	8	// [8] BASE DA DUPLICATA (VALOR LíQUIDO DA CONDIçãO DE PAGAMENTO)
	Local lNF_SUFRAMA	:=	MaFisRet(,"NF_DESCZF") > 0
	Local cTransf		:=	''

	// Campos virtuais Customizados pela IMDEPA
	M->UA_OBSCLI  := IIF(SUA->UA_PROSPEC,"",SA1->(POSICIONE("SA1",1,XFILIAL("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA,"A1_OBSVEND")))

	aHeader  := {}
	aCols    := {}
	aHeader  := aClone(aSvFolder[2][1])
	aCols    := aClone(aSvFolder[2][2])
	__aCCols := aClone(aSvFolder[2][2])
	n		 := aSvFolder[2][3]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  	TELEVENDAS 		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nP_Data	:= 	Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_DTNECLI"	})
	nP_Hora	:= 	Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_HRNECLI"	})
	nPProd	:= 	Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_PRODUTO" 	})
	nPQuant	:= 	Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_QUANT" 	})

	//VERIFICA SE O ORCAMENTO COPIADO ESTA VENCIDO (vencimento dos preços acertados).
	lOrcVencido 	:= (DDATABASE >  M->UA_DTLIM )   // 3 dias após a database
	lDesNegVencido	:= DDATABASE > (SUA->UA_EMISSAO + X_DESCNEG)  //ENTRE(SUA->UA_EMISSAO,(SUA->UA_EMISSAO + X_DESCNEG), DDATABASE)  // Descontos Negociados vencem em 30 dias

	// Array com a amarracao produtoxcampanha para posterior gravacao da tabela ZZI
	__aProdCamp := {}	//	FABIANO PEREIRA - SOLUTIO
	__aItDigPrd := {}

	nAnt := n

	If lProspect
		cTabela	:=	''
	Else

		If AllTrim(SA1->A1_COD+SA1->A1_LOJA) == AllTrim(M->UA_CLIENTE+M->UA_LOJA)
			cCliente	:= 	M->UA_CLIENTE
			cLoja		:= 	M->UA_LOJA
		Else
			DbselectArea("SA1");DbSetOrder(1);DbGoTop()
			If DbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA, .F.)
				cCliente	:= 	SA1->A1_COD
				cLoja		:= 	SA1->A1_LOJA
			EndIf
		EndIf

		M->UA_TEL 		:= IIF(!Empty(SA1->A1_DDD), '('+AllTrim(SA1->A1_DDD)+') ', '')+AllTrim(SA1->A1_TEL)
		M->UA_VINCULO	:=	SA1->A1_VINCULO
		M->UA_DESCSEG	:=	Posicione("ZZV",1,xFilial("ZZV")+SA1->A1_GRPSEG,"ZZV_COD")

		cGrpSeg	:= 	SA1->A1_GRPSEG
		cTabela	:=	SA1->A1_TABELA

	EndIf

	aValidDA0 := ExecBlock('ChkValidDA0',.F.,.F.,{cTabela})
	If aValidDA0[01]
		M->UA_TABELA := aValidDA0[02]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ * NA CARGA DO HISTORICO                                        		|
	//|                                                 					|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// lNF_SUFRAMA
	If (aValores[_MERCADORIA] == 0 .Or.	aValores[_TOTAL] == 0 .Or. 	aValores[_BASEDUP] == 0)
		Tk273RecCpg()
		Tk273Refresh(.T.)
		Tk273AtuNFs()
		Tk273Refresh(.T.)

		MaColsToFis(aHeader,aCols,NIL,"TK271",.T., Nil,Nil,Nil)
		Tk273Refresh(.T.)

		If SUA->UA_VALMERC != MaFisRet(, "NF_VALMERC")
			MaColsToFis(aHeader,aCols,NIL,"TK271",.T., Nil,Nil,Nil)
			Tk273Refresh(.T.)
		EndIf

	EndIf
	//MaFisAlt("NF_DESPESA",aValores[_ACRESCIMO]+aValores[_DESPESA])

	ProcRegua(Len(aCols))
	For nI := 1 To Len(aCols)

		n := nI

		If !lRecalAtend
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| AT <= 2 DIAS									|
			//³	NAO RECALCULAR PARA MANTER OS MESMOS VALORES	³
			//|	APENAS GRAVA VALORES NO ARRAY aProdXImp	  		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			IncProc('Processando...  '+AllTrim(Str(nI))+' de '+AllTrim(Str(Len(aCols)))+' Itens' )

			lOnlyArray	:=	.T.
			Aadd(aHistTV, {	GdFieldGet('UB_ITEM', nI), 		GdFieldGet('UB_PRODUTO', nI),;									//	[01], [02],
			M->UA_DESC1, M->UA_DESC4, M->UA_DESCG,;														//	[03], [04], [05]
			GdFieldGet('UB_TOTDESC', nI), 	GdFieldGet('UB_DESCVEN', nI), 	GdFieldGet('UB_DESCRD', nI),;	//	[06], [07], [08]
			GdFieldGet('UB_ACRE2',   nI),	GdFieldGet('UB_VRUNIT',  nI), 	GdFieldGet('UB_PRCTAB', nI) })	//	[09], [10], [11]

		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|   AT > 2 DIAS	|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			cTabela   	:= IIF(!Empty(GdFieldGet('UB_TABPRC', nI)),GdFieldGet('UB_TABPRC', nI), M->UA_TABELA)														//	Tipo (1=Preço/2 = Fator de acréscimo ou desconto)
			nPrecoTab 	:= ExecBlock("OM010PRC",.F.,.F.,{cTabela,GdFieldGet('UB_PRODUTO', nI),GdFieldGet('UB_QUANT', nI),M->UA_CLIENTE,M->UA_LOJA,M->UA_MOEDA,dDataBase,1})

			If GdFieldGet('UB_PRCTAB', nI) == nPrecoTab
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³	SE NAO MUDOU O PRECO DE TABELA ENTAO NAO PRECISA RECALCULAR E MANTEM O MESMO PRECO	³
				//|	APENAS GRAVA VALORES NO ARRAY aProdXImp	  											³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lOnlyArray	:=	.T.
				IncProc('ReCalculando...  '+AllTrim(Str(nI))+' de '+AllTrim(Str(Len(aCols)))+' Itens.' )
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³	   RECALCULAR VALORES      	³
				//|	ATAULIZA ARRAY aProdXImp	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lOnlyArray	:= .F.
				GdFieldPut('UB_PRCTAB', nPrecoTab, nI )
				IncProc('ReCalculando...  '+AllTrim(Str(nI))+' de '+AllTrim(Str(Len(aCols)))+' Itens..' )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  RECALCULA LINHA DO aCOLS						|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//lOnlyArray := IIF(lRecalAtend, .F., .T.)
			If !lOnlyArray .And. MaFisRet(nI, "IT_DESCZF") == 0

				//Tk273Recalc(nI,.T.,.T.)	// 	ExpN1: Linha do aCols a Ser atualizada
				//	ExpL2: .T. - Indica que so a linha selecionada deve ser atualizada
				//	ExpL3: .F. - Indica se a chamada vem do valid do campo UA_TABELA.
			EndIf

			// Pega o desconto que será aplicado de acordo com o cabeçalho da regra de desconto.
			//M->UA_DESC4 := TkRegraDesc(2,NIL,@M->UA_DESC4,NIL,M->UA_CONDPG,nI)

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  ALIMENTA APENAS O ARRAY aProdXImp PARA MOSTRAR DADOS... NAO EXECUTA O RECALCULO   	|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nLinha 	 	:= 	 nI
		lForcExec 	:= 	.F.
		lCheckDel	:= 	.F.
		//lOnlyArray	:=	IIF(lRecalAtend, .F., .T.)
		ExecBlock('PrcReCalc',.F.,.F.,{nLinha, lForcExec, lCheckDel, lOnlyArray})

		//	FABIANO PEREIRA - SOLUTIO - PREENCHE CAMPO OBSERVACAO - APOS PRCRECALC PARA OBTER VALOR CORRETO DO IPI
		cObsProd := U_IMDA760(.F., GdFieldGet('UB_PRODUTO',nI) )
		GdFieldPut('UB_OBS', cObsProd, nI )
		GdFieldPut('UB_ALIQIPI', MaFisRet(nI, "IT_ALIQIPI"), nI)	//	% IPI

		//////////////////////////////////////////////
		// JULIO JACOVENKO, em 16/08/2016
		// usado para para preencher campo UB_INDSTR
		//////////////////////////////////////////////
		//////////////////////////////////////////////
		cProduto 	:= GDFIELDGET('UB_PRODUTO', nI)  //pega produto da linha
		cFilialB1	:= XFILIAL('SUB')                //pega filial da SUB
		cIndustr    := POSICIONE("SB1",1,cFilialB1+cProduto,"B1_INDUSTR")  //pego B1_INDUSTR
		GDFIELDPUT("UB_INDUSTR",CINDUSTR,nI) //REPLICA B1_INDUSTR na linha
		//////////////////////////////////////////////
		//////////////////////////////////////////////
		///Liberado p/ Validacao em 16/08/2016 as 15:30
		//////////////////////////////////////////////

		***********************************************************************************************************
		//Projeto F11 - Usado para armazenar o estado anterior dos produtos para saber quando houver uma alteração//
		***********************************************************************************************************

		Aadd(__aItDigPrd, {nI, GdFieldGet("UB_PRODUTO",nI), GdFieldGet("UB_LOCAL",nI)} ) //Carrega o Vetor __aItDigPrd{} com os produtos do Acols
		Aadd(__aItDigQtd,nI)

		//// Chamado: 8904 - Cristiano Machado // Nao deve ser atualizado ... atrapalha o controle do COV
		// FABIANO PEREIRA - SOLUTIO
	    //	aCols[nI,nP_DATA]   := dDataBase  // Data da Necessidade do Cliente
	    aCols[nI,nP_HORA]   := StrZero(Val(SubStr(Time(),1,2))+2,2)+SubStr(Time(),4,2)//Hora da Necessidade do Cliente

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  VERIFICA RESERVA X PROD.CORREIAS	|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lCorreia :=	!Empty(A093VldBase(GdFieldGet("UB_PRODUTO",nI))	)
		IIF(lCorreia, U_ChkReserva(nI, SUA->UA_NUMSC5),)

		If !Empty(GdFieldGet('UB_FILTRAN', nI)) .And. Empty(GdFieldGet('UB_PLANILH', nI))
			cTransf += AllTrim(GdFieldGet('UB_ITEM', nI))+' - '+AllTrim(GdFieldGet('UB_PRODUTO',nI))+'  '+AllTrim(GdFieldGet('UB_DESCRI',nI))+ENTER
		EndIf

	Next

	If !Empty(cTransf)
		cEstFilSP  := AllTrim( Posicione('SM0', 1, cEmpAnt + cFilEstC,  'M0_ESTENT' ))
		cEstFilAtu := AllTrim( Posicione('SM0', 1, cEmpAnt + cFilAnt,   'M0_ESTENT' ))
		MsgAlert('O(s) seguinte(s) item(s) irão gerar PEDIDO DE TRANSFÊRENCIA de '+cEstFilSP+' para '+cEstFilAtu+ENTER+ENTER+;
		cTransf+ENTER+ENTER+IIF(M->UA_OPER=='02','Após esse orçamento gerar Pedido de Venda','Portanto')+' não poderá ser excluido até que a transferência seja concluida.', 'Pedido de Transferência.')

	EndIf

	n := nAnt // oGetTlv:oBrowse:nAT	// FABIANO PEREIRA - SOLUTIO

	// Indica que neste atendimento, ao se passar pelo campo UA_TABELA, a validacao nao atualizar os precos dos itens do atendimento
	__cTabAtu	:= M->UA_TABELA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| VALIDACAO PARA QUE ITEM DE TRANSFERENCIA NAO ALTERE QUANTIDADE.     	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPQuant > 0 .And. nFolder == 2
		If !('ChkTransf()' $ aHeader[nPQuant][06])
			aHeader[nPQuant][06] := 'U_ChkTransf() .And. '+aHeader[nPQuant][06]
		EndIf
	EndIf

	oGetTlv:oBrowse:Refresh()
	Restarea(aArea)
	Return()
	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ChkRecAT   ³ Autor ³ Fabiano Pereira      ³ Data ³ 27/07/15 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Verifica se Recalcular valores do Atendimento.              ³±±
	±±³          |                                                            ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       | IMDEPA 													  ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	**********************************************************************
User Function ChkRecalAT()
	**********************************************************************
	Local lReCalcAT  :=	.F.
	Local nDiasHist  :=	0
	Local nCountDias :=	0

	IIF(!ExisteSX6('IM_DIAHIST'), CriarSX6('IM_DIAHIST','N','Numero de Dias para permanecer os valores do Historico', '2'), )
	nDiasHist  := GetMv('IM_DIAHIST')

	If DateDiffDay(Date(), M->UA_EMISSAO) > nDiasHist
		// 	 24/07/2015			27/07/2015
		// 	M->UA_EMISSAO

		dDtAtend := DataValida(M->UA_EMISSAO+1)
		Do While Date() >= dDtAtend

			If DataValida(dDtAtend) == dDtAtend
				nCountDias++
			EndIf

			If nCountDias > nDiasHist
				lReCalcAT:= .T.
				_lAltOrc := .T.
				Exit
			EndIf

			dDtAtend := DataValida(dDtAtend+1)
		EndDo

	EndIf

	Return(lReCalcAT)
	**********************************************************************
User Function ChkReserva(nLinha, cNumPV)
	**********************************************************************
	Local _aArea    := 	Getarea()
	Local cReserva  := ''

	If Type('aProdXImp') == 'A'

		nPosProd := Ascan(aProdXImp, {|X| AllTrim(X[1]) == AllTrim(GdFieldGet('UB_ITEM',nLinha)) })
		If nPosProd > 0

			If Empty(cNumPV)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³  ATENDIMENTO \ ORCAMENTO						³
				//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
				//|	JA GRAVA aProdXImp[nPosProd][09] := cReserva	|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cRotina  := 'TLVENT'
				aOpcao	 :=	{'BROWSER_CORREIAS','HIDE','QTD_EST_DISP'}
				cCodProd := GdFieldGet("UB_PRODUTO",nLinha)
				aParam	 := {}
				xRetorno :=	'QTD_EST_DISP'
				aRetorno := ExecBlock('ChkCorreias', .F., .F., {cRotina, aOpcao, cCodProd, aParam, nLinha, xRetorno})
				If ValType(aRetorno) == 'A'
					If Len(aRetorno) >= 3
						If Len(aRetorno[03]) > 0
							aReserva := aRetorno[03][01]
							If AllTrim(aReserva[05]) == AllTrim(cFilAnt) .And. !Empty(GdFieldGet('UB_FILTRAN', nLinha))
								GdFieldPut('UB_FILTRAN', Space(TamSx3('UB_FILTRAN')[01]), nLinha )
							EndIf
						EndIf
					EndIf
				EndIf

			Else

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³  ATENDIMENTO \ FATURAMENTO  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cNumRes := 	AllTrim(SUA->UA_NUMSC5)+AllTrim(GdFieldGet('UB_ITEM',nLinha))
				If cFilAnt != cFilEstC
					cFiltro	:=	" IN " + FormatIn(xFilial('SC0')+'|'+cFilEstC,"|")
				Else
					cFiltro	:=	" = '"+xFilial('SC0')+"'"
				EndIf

				IIF(Select('TMPRES')!=0, TMPRES->(DbCloseArea()), )
				cSql := " SELECT * 									"+ENTER
				cSql += " FROM 	"+RetSqlName("SC0")+" SC0 			"+ENTER
				cSql += " WHERE SC0.C0_FILIAL  		" +cFiltro		 +ENTER		//cSql += " WHERE SC0.C0_FILIAL  IN   ("+cFilRes+")	"+ENTER
				cSql += " AND 	SC0.C0_DOCRES   =	'"+cNumRes+"' 	"+ENTER
				cSql += " AND 	SC0.D_E_L_E_T_ != 	'*'  			"+ENTER

				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),'TMPRES',.T.,.T.)
				DbSelectArea('TMPRES');DbGoTop()
				Do While !Eof()
					//	cReserva += '{'+cProd+','+cLarg+','+cQuant+','+cLocal+','+cFilRes+'}'

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ POSICIONA TABELAS NA XX_BASE CORRETA E VERIFICA SE ALIAS() ESTA VAZIA	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ExecBlock('ChkPosBase',.F.,.F., {'TLVENT\ChkReserva', TMPRES->C0_PRODUTO})
					cBase  		:= 	A093VldBase(TMPRES->C0_PRODUTO)
					lCorrOpen	:=	IIF(AllTrim(cBase)=='02', .T., .F.)		// 01-FECHADAS, 02-ABERTAS
					ExecBlock('ChkPosBase',.F.,.F., {'ChkCorreias', cBase})

					aVarSBS := 	A093SBSVars(TMPRES->C0_PRODUTO)
					nPos 	:= 	Ascan(aVarSBS, {|X|  AllTrim(X[01]) == 'LRG'} )
					cLarg	:= 	IIF(nPos > 0, AllTrim(aVarSBS[nPos][03]), '')
					nPos 	:= 	Ascan(aVarSBS, {|X|  AllTrim(X[01]) == 'COM'} )
					cComp	:= 	IIF(nPos > 0, AllTrim(aVarSBS[nPos][03]), '')

					nVlrMax	  := Max(TMPRES->C0_QUANT, TMPRES->C0_QTDELIM)
					nVlrMin	  := Min(TMPRES->C0_QUANT, TMPRES->C0_QTDELIM)
					nSaldoSBF := (nVlrMax - nVlrMin)
					cReserva += '{'+AllTrim(TMPRES->C0_PRODUTO)+','+cLarg+','+AllTrim(Str(nSaldoSBF))+','+TMPRES->C0_LOCAL+','+TMPRES->C0_FILIAL+','+cComp+'}'

					DbSelectArea('TMPRES')
					DbSkip()
				EndDo

				aProdXImp[nPosProd][09] := cReserva

			EndIf

		EndIf

	EndIf

	IIF(Select('TMPRES')!=0, TMPRES->(DbCloseArea()), )
	RestArea(_aArea)
Return()