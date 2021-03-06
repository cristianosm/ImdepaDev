#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "RWMAKE.CH"
#DEFINE  ENTER CHR(13)+CHR(10)

#DEFINE X_DESCNEG		30  // Dias para vencimento dos acrescimos/descontos negociados
#DEFINE ACRESCIMO		3	// Valor do acrescimo financeiro da condicao de pagamento

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TLVENT    �Autor  �Edivaldo Gon�alves  � Data �  09/13/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de Entrada ap�s sele��o do Hist�rico das ligacoes     ���
���          �atendidas pelo Televendas                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Call Center                                                ���
�������������������������������������������������������������������������͹��
���Alteracao � M�rcio Q. Borges �Rodar Valid de campo VRUNIT somente      ���
��� 27/10/07 �                  �quando alterar o preco de tabela e PV    ���
���          �                  �estiver aberto.                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
**********************************************************************
User Function TLVENT()
**********************************************************************
Local cDisplay:=''



//�����������������������������������������Ŀ
//�  FABIANO PEREIRA - SOLUTIO            	�
//�  ZERA VARIAVEIS PUBLICAS - TMKACTIVE()	�
//�������������������������������������������
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
		cDisplay='Or�amento'
	Endif
Endif

//Inserido por Edivaldo Gon�alves Cordeiro em 01/09/2009 - Atualiza vari�veis de Mem�ria no cabe�alho no Or�amento
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
			//���������������������������������������������������������������������������������Ŀ
			//� NECESSARIO RODAR aColsReCalc QUE CHAMA ROTINA PARA CALCULAR VALOR				�
			//| UNITARIO (PrcReCalc) POREM NAO ALTERA VALORES 									|
			//| -->> APENAS CARREGA ARRAY aProdxImp												|
			//�����������������������������������������������������������������������������������
			lOnlyArray := .T.
			ExecBlock('aColsReCalc',.F.,.F.,{'TODOS', lOnlyArray})
			
		EndIf
		
	Else
		
		Processa({|| SF4->(LoadOrc())  },'Hist�rico','Estruturando '+cDisplay+' ...')
		
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
Local nAcreMva    := 0  //Acr�scimo do MVA
Local cEstATU     := GETMV("MV_ESTADO")
Local nDiasHist   := GetMv('IM_DIAHIST')
Local lRecalAtend  := DateDiffDay(Date(), M->UA_EMISSAO) > nDiasHist


// Campos virtuais Customizados pela IMDEPA
M->UA_OBSCLI  := IIF(SUA->UA_PROSPEC,"",SA1->(POSICIONE("SA1",1,XFILIAL("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA,"A1_OBSVEND")))

/*
If lRecalAtend
	// M->UA_TABELA := Posicione('SA1',1,xFilial('SA1')+ M->UA_CLIENTE+M->UA_LOJA,'A1_TABELA')
	cMsg  	:= 	ENTER
	cMsg  	+= 	'ATENDIMENTOS QUE ULTRAPASSEM  '+AllTrim(Str(nDiasHist))+' DIAS  SER�O RECALCULADOS.'+ENTER+ENTER
	cMsg	+=	'DT. ATUAL: '+DtoC(dDataBase)+'  -   DT. ATEND.: '+DtoC(M->UA_EMISSAO)+ '  =  '+AllTrim(Str(DateDiffDay(dDataBase, M->UA_EMISSAO)))+' DIAS.'+ENTER+ENTER
	//cMsg	+=	'AO BUSCAR O HIST�RIO DE ATENDIMENTO'+ENTER+'OS PRODUTOS QUE N�O EST�O RELACIONADOS NA TAB.PRE�O  [ '+M->UA_TABELA+' ]  SER�O DELETADOS.'+ENTER
	MsgInfo(cMsg)
EndIf
*/

aHeader  := {}
aCols    := {}
aHeader  := aClone(aSvFolder[2][1])
aCols    := aClone(aSvFolder[2][2])
n		 := aSvFolder[2][3] // FABIANO PEREIRA - SOLUTIO


//����������������������Ŀ
//�  	TELEVENDAS 		 �
//������������������������
nPTotal   := Ascan(aHeader, {|x| AllTrim(x[2]) == "UB_VLRITEM"	})
nPPrUnit  := Ascan(aHeader, {|x| AllTrim(x[2]) == "UB_VRUNIT"	})
nPProduto := Ascan(aHeader, {|x| AllTrim(x[2]) == "UB_PRODUTO"	})
nPQuant   := Ascan(aHeader, {|x| AllTrim(x[2]) == "UB_QUANT"	})
nPPrcTab  := Ascan(aHeader, {|x| AllTrim(x[2]) == "UB_PRCTAB"	})
nP_Data	  := Ascan(aHeader, {|x| AllTrim(x[2]) == "UB_DTNECLI"	})
nP_Hora	  := Ascan(aHeader, {|x| AllTrim(x[2]) == "UB_HRNECLI"	})



//VERIFICA SE O ORCAMENTO COPIADO ESTA VENCIDO (vencimento dos pre�os acertados).
lOrcVencido 	:= (DDATABASE >  M->UA_DTLIM )   // 3 dias ap�s a database
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
		
		//nPrecoTab := NoRound(Posicione('DA1',1,xFilial('DA1')+ M->UA_TABELA+aCols[nI][nPProduto],'DA1_PRCVEN'), TamSx3('UB_VRUNIT')[02])                      //	Tipo (1=Pre�o/2 = Fator de acr�scimo ou desconto)
		nPrecoTab := ExecBlock("OM010PRC",.F.,.F.,{M->UA_TABELA,GdFieldGet('UB_PRODUTO', nI),GdFieldGet('UB_QUANT', nI),M->UA_CLIENTE,M->UA_LOJA,M->UA_MOEDA,dDataBase,1})
		lPrcTabDif:= aCols[nI][nPPrcTab] != nPrecoTab
		aCols[nI][nPPrcTab]	:= 	nPrecoTab



		//���������������������������������������������������
		//�  RECALCULA LINHA DO aCOLS						|
		//���������������������������������������������������
		Tk273Recalc(nI,.T.,.T.)	// 	ExpN1: Linha do aCols a Ser atualizada
									//	ExpL2: .T. - Indica que so a linha selecionada deve ser atualizada
									//	ExpL3: .F. - Indica se a chamada vem do valid do campo UA_TABELA.
		
		
		// Pega o desconto que ser� aplicado de acordo com o cabe�alho da regra de desconto.
		M->UA_DESC4 := TkRegraDesc(2,NIL,@M->UA_DESC4,NIL,M->UA_CONDPG,nI)


	EndIf
	
	
	
	MaColsToFis(aHeader,aCols,nI,"TK271",.T.,Nil,.T.,Nil)
	
	
	
	//	FABIANO PEREIRA - SOLUTIO - PREENCHE CAMPO OBSERVACAO
	cObsProd := U_IMDA760(.F., GdFieldGet('UB_PRODUTO',nI) )
	GDFieldPut('UB_OBS', cObsProd, nI )
		
	//�������������������������������������������������������������������������������������Ŀ
	//�  ALIMENTA APENAS O ARRAY aProdXImp PARA MOSTRAR DADOS... NAO EXECUTA O RECALCULO   	|
	//���������������������������������������������������������������������������������������
	nLinha 	 	:= 	 nI
	lForcExec 	:= 	.F.
	lCheckDel	:= 	.F.
	lOnlyArray	:=	IIF(lRecalAtend, .F., .T.)
	ExecBlock('PrcReCalc',.F.,.F.,{nLinha, lForcExec, lCheckDel, lOnlyArray})


	
	***********************************************************************************************************
	//Projeto F11 - Usado para armazenar o estado anterior dos produtos para saber quando houver uma altera��o//
	***********************************************************************************************************
	
	Aadd(__aItDigPrd,{nI,GdFieldGet("UB_PRODUTO",nI),GdFieldGet("UB_LOCAL",nI)}) //Carrega o Vetor __aItDigPrd{} com os produtos do Acols
	Aadd(__aItDigQtd,nI)
	
	// FABIANO PEREIRA - SOLUTIO
	aCols[nI,nP_DATA]   := dDataBase  // Data da Necessidade do Cliente
	aCols[nI,nP_HORA]   := StrZero(Val(SubStr(Time(),1,2))+1,2)+SubStr(Time(),4,2)//Hora da Necessidade do Cliente
	
	
Next

If !lRecalAtend
		
	//���������������������������������������������Ŀ
	//�  ZERA SE TIVER DESPESA(5) OU ACRESCIMO(3)   �
	//�����������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Tk273DesCLi� Autor � Vendas Clientes      � Data � 05/03/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Aplica o desconto informado no cabecalho e depois o desconto���
���          �atual do item                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1: Linha do aCols para analise.                         ���
���          �ExpN2: Tipo de Desconto (1 % OU 2 R$)                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       �TELEVENDAS                                          		  ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//��������������������������������������������������������Ŀ
//�Reavalia os precos dos itens                            �
//����������������������������������������������������������
nVlrTabela := aCols[nLinha][nPPrcTab]

If (aCols[nLinha][nPPrcUni] > 0)
	aCols[nLinha][nPPrcUni] := FtDescCab(nVlrTabela,{M->UA_DESC1,M->UA_DESC2,M->UA_DESC3,M->UA_DESC4})
	aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPPrcUni],"UB_VLRITEM")
	
	MaFisAlt("IT_VALMERC",aCols[nLinha][nPVlrItem],nLinha)
Endif

//��������������������������������������������������������Ŀ
//�Se houver acrescimo no item - acumula no valor de tabela�
//����������������������������������������������������������
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

//������������������������������������������������������������������������Ŀ
//�Retorna o estado de entrada da rotina                                   �
//��������������������������������������������������������������������������
RestArea(aArea)
Return (.T.)