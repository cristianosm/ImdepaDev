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
Local cDisplay:=''



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

IIF(!ExisteSX6('IM_DIAHIST'), CriarSX6('IM_DIAHIST','N','Numero de Dias para permanecer os valores do Historico', '2'), )




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
	If  !EMPTY(SUA->UA_EMISNF)
		
		// FABIANO PEREIRA - SOLUTIO
		If ExistBlock('aColsReCalc')
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ NECESSARIO RODAR aColsReCalc QUE CHAMA ROTINA PARA CALCULAR VALOR				³
			//| UNITARIO (PrcReCalc) POREM NAO ALTERA VALORES 									|
			//| -->> APENAS CARREGA ARRAY aProdxImp												|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lOnlyArray := .T.
			ExecBlock('aColsReCalc',.F.,.F.,{'TODOS', lOnlyArray})
			
		EndIf
		
	Else
		
		Processa({|| SF4->(LoadOrc())  },'Histórico','Estruturando '+cDisplay+' ...')
		
	EndIf
	
EndIf


Tk273FRefresh()
Return(.T.)
**********************************************************************
Static Function LoadOrc()
**********************************************************************
Local nAnt, nPrcTabAtu
Local lDesNegVencido,lOrcVencido := .F.
Local cOperAtivo  :=""
Local aArea       := Getarea()
Local lAtuPrcTab2 := .F.
Local nDesAcreFil :=0
Local uBcf        :=' '
Local nAcreMva    := 0  //Acréscimo do MVA
Local cEstATU     := GETMV("MV_ESTADO")
Local nDiasHist   := GetMv('IM_DIAHIST')
Local lRecalAtend  := DateDiffDay(Date(), M->UA_EMISSAO) > nDiasHist


// Campos virtuais Customizados pela IMDEPA
M->UA_OBSCLI  := IIF(SUA->UA_PROSPEC,"",SA1->(POSICIONE("SA1",1,XFILIAL("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA,"A1_OBSVEND")))

/*
If lRecalAtend
	// M->UA_TABELA := Posicione('SA1',1,xFilial('SA1')+ M->UA_CLIENTE+M->UA_LOJA,'A1_TABELA')
	cMsg  	:= 	ENTER
	cMsg  	+= 	'ATENDIMENTOS QUE ULTRAPASSEM  '+AllTrim(Str(nDiasHist))+' DIAS  SERÃO RECALCULADOS.'+ENTER+ENTER
	cMsg	+=	'DT. ATUAL: '+DtoC(dDataBase)+'  -   DT. ATEND.: '+DtoC(M->UA_EMISSAO)+ '  =  '+AllTrim(Str(DateDiffDay(dDataBase, M->UA_EMISSAO)))+' DIAS.'+ENTER+ENTER
	//cMsg	+=	'AO BUSCAR O HISTÓRIO DE ATENDIMENTO'+ENTER+'OS PRODUTOS QUE NÃO ESTÃO RELACIONADOS NA TAB.PREÇO  [ '+M->UA_TABELA+' ]  SERÃO DELETADOS.'+ENTER
	MsgInfo(cMsg)
EndIf
*/

aHeader  := {}
aCols    := {}
aHeader  := aClone(aSvFolder[2][1])
aCols    := aClone(aSvFolder[2][2])
n		 := aSvFolder[2][3] // FABIANO PEREIRA - SOLUTIO


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  	TELEVENDAS 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPTotal   := Ascan(aHeader, {|x| AllTrim(x[2]) == "UB_VLRITEM"	})
nPPrUnit  := Ascan(aHeader, {|x| AllTrim(x[2]) == "UB_VRUNIT"	})
nPProduto := Ascan(aHeader, {|x| AllTrim(x[2]) == "UB_PRODUTO"	})
nPQuant   := Ascan(aHeader, {|x| AllTrim(x[2]) == "UB_QUANT"	})
nPPrcTab  := Ascan(aHeader, {|x| AllTrim(x[2]) == "UB_PRCTAB"	})
nP_Data	  := Ascan(aHeader, {|x| AllTrim(x[2]) == "UB_DTNECLI"	})
nP_Hora	  := Ascan(aHeader, {|x| AllTrim(x[2]) == "UB_HRNECLI"	})



//VERIFICA SE O ORCAMENTO COPIADO ESTA VENCIDO (vencimento dos preços acertados).
lOrcVencido 	:= (DDATABASE >  M->UA_DTLIM )   // 3 dias após a database
lDesNegVencido	:= DDATABASE > (SUA->UA_EMISSAO + X_DESCNEG)  //ENTRE(SUA->UA_EMISSAO,(SUA->UA_EMISSAO + X_DESCNEG), DDATABASE)  // Descontos Negociados vencem em 30 dias

// Array com a amarracao produtoxcampanha para posterior gravacao da tabela ZZI
__aProdCamp := {}	//	FABIANO PEREIRA - SOLUTIO
__aItDigPrd := {}

nAnt := n 	// FABIANO PEREIRA - SOLUTIO



ProcRegua(Len(aCols))

// FABIANO PEREIRA - SOLUTIO - INICIO
If ExistBlock('AtuBaseICMS')
	ExecBlock('AtuBaseICMS',.F., .F., {'ZERAR'})
EndIf

// 	ATUALIZA UA_DESCORI PARA ATUALIZAR M->UA_DESC4 
//	COM O DESCONTO "ATUAL" NAO O % DESC. DO HISTORICO
//If lRecalAtend
//	M->UA_DESCORI := M->UA_DESC4
//EndIf		
		
// FABIANO PEREIRA - SOLUTIO - FIM


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

aValidDA0 := ExecBlock('ChkValidDA0',.F.,.F.,{cTabela})
If aValidDA0[01]
	M->UA_TABELA := aValidDA0[02]
EndIf


For nI := 1 To Len(aCols)
	
	n := nI // FABIANO PEREIRA - SOLUTIO
	
	
	
	IncProc('Processando...  '+AllTrim(Str(nI))+' de '+AllTrim(Str(Len(aCols)))+' Itens' )
	
	If !lRecalAtend

		/*
		Aadd(aHistTV, {M->UA_DESCG,	 GdFieldGet('UB_ITEM', nI), 	GdFieldGet('UB_PRODUTO', nI),;	//	[01], [02], [03]
								 	 GdFieldGet('UB_DESC', nI), 	GdFieldGet('UB_VALDESC', nI),;	//	[04], [05]
								 	 GdFieldGet('UB_ACRE', nI), 	GdFieldGet('UB_VALACRE', nI),;	//	[06], [07]
									 GdFieldGet('UB_DESCVEN', nI), 	GdFieldGet('UB_DESCRD',  nI),;	//	[08], [09]	
									 GdFieldGet('UB_TOTDESC', nI) })								//	[10]
        */

		Aadd(aHistTV, {	GdFieldGet('UB_ITEM', nI), 		GdFieldGet('UB_PRODUTO', nI),;									//	[01], [02],     
						M->UA_DESC1, M->UA_DESC4, M->UA_DESCG,;														//	[03], [04], [05]
						GdFieldGet('UB_TOTDESC', nI), 	GdFieldGet('UB_DESCVEN', nI), 	GdFieldGet('UB_DESCRD', nI),;	//	[06], [07], [08]
						GdFieldGet('UB_ACRE',    nI),	GdFieldGet('UB_VRUNIT',  nI), 	GdFieldGet('UB_PRCTAB', nI) })	//	[09], [10], [11]



	Else
		
		//nPrecoTab := NoRound(Posicione('DA1',1,xFilial('DA1')+ M->UA_TABELA+aCols[nI][nPProduto],'DA1_PRCVEN'), TamSx3('UB_VRUNIT')[02])                      //	Tipo (1=Preço/2 = Fator de acréscimo ou desconto)
		nPrecoTab := ExecBlock("OM010PRC",.F.,.F.,{M->UA_TABELA,GdFieldGet('UB_PRODUTO', nI),GdFieldGet('UB_QUANT', nI),M->UA_CLIENTE,M->UA_LOJA,M->UA_MOEDA,dDataBase,1})
		lPrcTabDif:= aCols[nI][nPPrcTab] != nPrecoTab
		aCols[nI][nPPrcTab]	:= 	nPrecoTab



		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  RECALCULA LINHA DO aCOLS						|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Tk273Recalc(nI,.T.,.T.)	// 	ExpN1: Linha do aCols a Ser atualizada
									//	ExpL2: .T. - Indica que so a linha selecionada deve ser atualizada
									//	ExpL3: .F. - Indica se a chamada vem do valid do campo UA_TABELA.
		
		
		// Pega o desconto que será aplicado de acordo com o cabeçalho da regra de desconto.
		M->UA_DESC4 := TkRegraDesc(2,NIL,@M->UA_DESC4,NIL,M->UA_CONDPG,nI)


	EndIf
	
	
	
	MaColsToFis(aHeader,aCols,nI,"TK271",.T.,Nil,.T.,Nil)
	
	
	
	//	FABIANO PEREIRA - SOLUTIO - PREENCHE CAMPO OBSERVACAO
	cObsProd := U_IMDA760(.F., GdFieldGet('UB_PRODUTO',nI) )
	GDFieldPut('UB_OBS', cObsProd, nI )
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  ALIMENTA APENAS O ARRAY aProdXImp PARA MOSTRAR DADOS... NAO EXECUTA O RECALCULO   	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLinha 	 	:= 	 nI
	lForcExec 	:= 	.F.
	lCheckDel	:= 	.F.
	lOnlyArray	:=	IIF(lRecalAtend, .F., .T.)
	ExecBlock('PrcReCalc',.F.,.F.,{nLinha, lForcExec, lCheckDel, lOnlyArray})


	
	***********************************************************************************************************
	//Projeto F11 - Usado para armazenar o estado anterior dos produtos para saber quando houver uma alteração//
	***********************************************************************************************************
	
	Aadd(__aItDigPrd,{nI,GdFieldGet("UB_PRODUTO",nI),GdFieldGet("UB_LOCAL",nI)}) //Carrega o Vetor __aItDigPrd{} com os produtos do Acols
	Aadd(__aItDigQtd,nI)
	
	// FABIANO PEREIRA - SOLUTIO
	aCols[nI,nP_DATA]   := dDataBase  // Data da Necessidade do Cliente
	aCols[nI,nP_HORA]   := StrZero(Val(SubStr(Time(),1,2))+1,2)+SubStr(Time(),4,2)//Hora da Necessidade do Cliente
	
	
Next

If !lRecalAtend
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  ZERA SE TIVER DESPESA(5) OU ACRESCIMO(3)   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IIF((aValores[05] + aValores[03]) > 0, ExecBlock('AtuBaseICMS',.F.,.F.,{'ZERAR',.T.,.F.}), )
	ExecBlock('AtuBaseICMS',.F.,.F.,{'RESTAURAR',.F.,.T.})
	Tk273RodImposto("NF_DESPESA",aValores[5]+aValores[3])
	MaFisAlt("NF_DESPESA",aValores[5]+aValores[3])	 // NECESSARIO PARA ATUALIZAR MaFisRet
	
	aValores[01] 	:= 	MaFisRet(, "NF_VALMERC") 
	aValores[07] 	:= 	MaFisRet(, "NF_DESCZF")
	aValores[06] 	:= 	MaFisRet(, "NF_TOTAL")
	aValores[08] 	:= 	MaFisRet(, "NF_BASEDUP")

EndIf


n := nAnt	// FABIANO PEREIRA - SOLUTIO

// Indica que neste atendimento, ao se passar pelo campo UA_TABELA, a validacao nao atualizar os precos dos itens do atendimento
__cTabAtu	:= M->UA_TABELA


oGetTlv:oBrowse:Refresh()
Restarea(aArea)
Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tk273DesCLi³ Autor ³ Vendas Clientes      ³ Data ³ 05/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Aplica o desconto informado no cabecalho e depois o desconto³±±
±±³          ³atual do item                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Linha do aCols para analise.                         ³±±
±±³          ³ExpN2: Tipo de Desconto (1 % OU 2 R$)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TELEVENDAS                                          		  ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
********************************************************************
User Function IMD_Tk273DesCLi(nLinha,nTipo)
********************************************************************
Local aArea		:= GetArea()			// Salva a area atual
Local nPQtd		:= aPosicoes[4][2]		// Quantidade
Local nPPrcUni	:= aPosicoes[5][2]		// Preco Unitario
Local nPVlrItem	:= aPosicoes[6][2]		// Valor do Item
Local nPDescon	:= aPosicoes[9][2]		// Desconto em %
Local nPVlDesc	:= aPosicoes[10][2]		// Desconto em R$
Local nPValAcre	:= aPosicoes[14][2]		// Valor de Acrescimo R$
Local nPPrcTab 	:= aPosicoes[15][2]		// Preco de Tabela
Local nVlrTabela:= 0					// Valor de Tabela

// nDesconto := TkRegraDesc(1,NIL,NIL,NIL,M->UA_CONDPG,nLinha)
// FtDescCab(nVlrTabela,{M->UA_DESC1,M->UA_DESC2,M->UA_DESC3,M->UA_DESC4})
// FtDescItem( @aCols[nLinha][nPPrcUni],;...)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Reavalia os precos dos itens                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlrTabela := aCols[nLinha][nPPrcTab]

If (aCols[nLinha][nPPrcUni] > 0)
	aCols[nLinha][nPPrcUni] := FtDescCab(nVlrTabela,{M->UA_DESC1,M->UA_DESC2,M->UA_DESC3,M->UA_DESC4})
	aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPPrcUni],"UB_VLRITEM")
	
	MaFisAlt("IT_VALMERC",aCols[nLinha][nPVlrItem],nLinha)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houver acrescimo no item - acumula no valor de tabela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[nLinha][nPValAcre] > 0
	aCols[nLinha][nPPrcUni] += aCols[nLinha][nPValAcre]
Endif

If (aCols[nLinha][nPPrcTab] > 0)
	aCols[nLinha][nPPrcTab] := nVlrTabela
	MaFisAlt("IT_PRCUNI",aCols[nLinha][nPPrcTab],nLinha)
Endif

If ( aCols[nLinha][nPDescon]  > 0 .Or.  ;
	aCols[nLinha][nPVlDesc]  > 0 .And. ;
	aCols[nLinha][nPPrcUni]  > 0 .And. ;
	aCols[nLinha][nPVlrItem] > 0 .And. ;
	aCols[nLinha][nPPrcTab]  > 0 )
	
	aCols[nLinha][nPPrcUni] := FtDescItem( @aCols[nLinha][nPPrcUni],;		//ExpN1: Preco de lista aplicado o desconto de cabecalho
	@aCols[nLinha,nPPrcTab],; 		//ExpN2: Preco de Venda
	aCols[nLinha,nPQtd],;			//ExpN3: Quantidade vendida
	@aCols[nLinha,nPVlrItem],;		//ExpN4: Valor Total (do item)
	@aCols[nLinha][nPDescon],;    	//ExpN5: Percentual de desconto
	@aCols[nLinha,nPVlDesc],;		//ExpN6: Valor do desconto
	@aCols[nLinha,nPDescon],;		//ExpN7: Valor do desconto original
	nTipo)						//ExpN8: Tipo de Desconto (1 % OU 2 R$)
	
	MaFisAlt("IT_VALMERC",aCols[nLinha][nPVlrItem],nLinha)
	
EndIf

Eval(bRefresh)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna o estado de entrada da rotina                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)
Return (.T.)