#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "IMDEPA.CH"

#define X_PARCELA		"123456789ABCDEFGHIJKLMNOPQ"
#define CRLF 				( chr(13)+chr(10) )
#define X_PRODUTO		aScan(aHeader, {|x| AllTrim(x[2])=='UB_PRODUTO'})
#define X_QTD				aScan(aHeader, {|x| AllTrim(x[2])=='UB_QUANT'})
#DEFINE X_ZE_NUMPLAN	12
#DEFINE X_ZE_ITEM		13
#DEFINE X_ZE_PVITEM		14

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³U_Tmkvfim() ³ Autor ³Microsiga/MQB        ³ Data ³ 22/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gravacao do arquivos de pedido de vendas                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ESPECIFICO PARA O CLIENTE IMDEPA						 	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³15/10/2005³  MQB   ³     Fonte Compatibilizado Hand                    ³±±
±±³21/10/2005³  MQB   ³     Adicionado caso que PEDIDO é liberado direto  ³±±
±±³19/10/2005³  MQB   ³     Liberação de PV automatico para Imdepauto     ³±±
±±³21/11/2005³  MQB   ³     Retirado alçada de Margem                     ³±±
±±³29/11/2005³  MQB   ³     Revisado toda a alcada de margem              ³±±
±±³18/12/2006³  MQB   ³     Posicionado TES logo apos Posicionadp Pedido  ³±±
±±³25/04/2007³  MQB   ³     Passagem dos Acresc e Desc Real no u_Defcomis ³±±
±±³12/06/2007³  MQB   ³     SelectArea("SE1"), p/ compatib. grv. prospect ³±±
±±³20/05/2008³  MQB   ³     Desonera MC qdo Sit.Trib,considera icm retido ³±±
±±³          ³        ³                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
*********************************************************************
User Function Tmkvfim()
*********************************************************************

	Local aArea := Getarea(),;
		aAreaSUA := SUA->(Getarea()),;
		aAreaSUB := SUB->(Getarea()),;
		aAreaSA1 := SA1->(Getarea()),;
		aAreaSB1 := SB1->(Getarea()),;
		aAreaSF4 := SF4->(Getarea()),;
		aAreaSA3 := SA3->(Getarea()),;
		aAreaSL4 := SL4->(Getarea()),;
		aAreaSUW := SUW->(Getarea()),;
		aAreaSC6 := SC6->(Getarea()),;
		aAreaSC5 := SC5->(Getarea()),;
		aAreaSB2 := SB2->(Getarea()),;
		aIt   	 := Array(0),;
		aItem 	 := Array(0),;
		aCab  	 := Array(0),;
		nX,nJ,;
		nDecSUB := TamSx3("UB_VRUNIT")[2],;
		nDecDesc := TamSx3("UB_DESC")[2],;
		nDecVLRITEM := TamSx3("UB_VLRITEM")[2],;
		nDecBASEICM := TamSx3("UB_BASEICM")[2],;
		cDescComis := GetMV("MV_COMIDES"),;
		cAcreComis := GetMV("MV_COMIACR"),;
		aSZE       := Array(0),;
		__aCols    := Array(0),;
		__aHead    := Array(0),;
		__cFil,;
		lGeraSZE   := .F.,;
		nPerComisCLI,aComisCamp,;
		nLucro, nMargem, nCusto, cTpCust,;
		nAcreFin, nAcreReal, nDescLucro,;
		nDescReal := 100, nPrcTabBase,;
		aVendedores,aOperador,aAvalCom:={},;
		nPosQtdLib,nPos,;
		lOk:= .T., lOkItem,lLibDireto:= .F.,lLibTES:= .F., nPrRecSUB,;
		nVlrItem,;
		cHora := Strtran(Left(Time(),5),":","")

	Local lGeralog := .F.
	Local cProduto, cLocal
	Local  nValDifICM
	Local nPercFrete, nFreteItem
	Local aPlanilha := {}
	Local cPlanilha
	Local cFiltran
	Local nIMC 		:= 0, nIMCg  		:= 0, nIMCR  	:= 0, nIMCUC 	:= 0, nIMCgTot		:= 0, nIMCRTot			:= 0, nQtdItem := 0
	Local nMCTot	:= 0, nMCgTot		:= 0, nMCRTot	:= 0, nMCUCTot	:= 0, nIMCTot		:= 0, nIMCUCTot			:= 0
	Local nQtdTotal	:= 0, nIdadeTotal 	:= 0, nQtdItem_X_nIdadeTOTAL 	:= 0, nQtdItemTotal	:= 0, nTOTTotItemSemIPI	:= 0

	Local lCancAnt
	Local lEnvMail := (Upper(GetMv('MV_ENVMAIL')) = 'SIM') //Informa se envia e-mail para os operadores para informar que a nota de transferencia foi entrada
	Local nPrBaseDesc,nDifIcmUnit,nPrcMin
	Local nFatores

//Inserido por Edivaldo Gonçalves Codeiro em 31/08/06 Declarado variáveis locais para percentual de comissão //
//Pois está sendo rodado o MSAGUARDE e com isso se faz necessário iniciar ás varíaveis                       //
//12/09/06 Edivaldo/Márcio - Inserido o (SF4->)para garantir que o MsAguarde e o RetCodUsr() não desposicione//
//o alias Corrente                                                                                           //

	Local n_COMIS1 := 0
	Local n_COMIS2 := 0
	Local n_COMIS3 := 0
	Local n_COMIS4 := 0
	Local n_COMIS5 := 0

//Cristiano Machado
	Local nAlicIcm	:= 0
	Local nValDesp  := 0
	Local nAcreCon  := 0
	Local nValFret  := 0
	Local nCalcIcm  := 0
	Local nAlicIpi  := 0
	Local nMVA		:= 0
	Local nValIcmSt := 0
	Local nIcmRetido := 0

	Local nCustoMCR  :=0
	Local nCustoMCUC :=0
	Local lRetWMS
	Local lRedesp    := .F.

// Jorge Oliveira - 28/02/2011 - Indica se a Filial atual, trabalha com as Liberacao Comercial utilizando Carta de Negocio
	Local lCartLib   := IIF( Upper( SuperGetMV( "MV_CARTLIB",, "N" ) ) == "S", .T., .F. )
	Local aCarta     := {}
	Local aProdCarta := {}
	Local aAreaAtu   := {}

	Private lMsHelpAuto := .T. // se .T. direciona as mensagens de help para o arq. de log
	Private lMsErroAuto := .F. //necessario a criacao, pois sera atualizado quando houver alguma incosistencia nos parametros
	Private __cNumOrig
	Private aStrucSC5   := RetStruct('SC5')
	Private aStrucSC6   := RetStruct('SC6')

	Private cCustoNF  := GetMV("MV_CUSTONF",," ")
	Private lEstOner  := dDatabase >= GetMV("MV_ESTONER",,dDatabase+1)

	Private aLogComiss:={}
	Private nDescIcmPad := 0
	Private nDescComExp := 0
	Private nAcrComExp  := 0

	Private cVend_1

////////////////////////////////////////////////CRIADO PELO JULIO JACOVENKO em 14/10/2011
////////////////////////////////////////////////PARA GRAVAR O CODIGO DO CLIENTE CORRETO QUANDO
////////////////////////////////////////////////TRANSFORMA PROSPECT PARA CLIENTES
///////////////////////////////////////////////////////////////////////////
	Private cCodCli:=''
	Private cLojCli:=''

	Private cNumSC5:=''
	Private cNunFil:=''

///////////////////////////////////////////////////////////////





	DbSelectArea("SU7")
	DbSetOrder(4) //U7_FILIAL+U7_CODUSU
	DbSeek(xFilial("SU7")+SU7->(RetCodUsr()))

	cVend_1   :=SU7->U7_CODVEN
	cOperAtivo:=SU7->U7_COD


	__cMensagem := ""
	cDescComis := IIF(EMPTY(cDescComis),"N",cDescComis)
	cAcreComis := IIF(EMPTY(cAcreComis),"N",cAcreComis)

	If M->UA_OPER <> "1"	// nao eh faturamento
	//Inserido por Edivaldo Gonçalves Cordeiro  Tela de Processo e Tratamento para o Palm em 01/09/06
		If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
			MsAguarde({||SF4->(Testetmkok()) },"Verificando atendimento","Verificando se atendimento é cópia ...")
		Else
			SF4->(Testetmkok())   //<- testa e Cancela o atendimento anterior automaticamente
		Endif

		Return NIL

	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionando o atendimento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectarea("SUA")
	DbSetorder(1)
	If !DbSeek(xFilial("SUA")+M->UA_NUM)
	// Cancela toda a transacao
		If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
			u_Mensagem("Não foi possível encontrar o atendimento "+M->UA_NUM+". Favor acionar Depto de Tecnologia Imdepa.")
		Else
			ConOut("Não foi possível encontrar o atendimento "+M->UA_NUM+". Favor acionar Depto de Tecnologia Imdepa.")
		EndIf
		Final("Erro ao localizar atendimento.")
	Endif

	cTabPreco	:= SUA->UA_TABELA
	cMoeda		:= SUA->UA_MOEDA
	cCondPag 	:= SUA->UA_CONDPG

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona a ordem dos arquivos                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SZP->(dbSetOrder(1))	//Filial + Numero do Atendimento	(Nao precisa salvar ambiente desta  tabela,  eh especificas)
	SZQ->(dbSetOrder(1))	//Filial + Numero do Atendimento + Item  	(Nao precisa salvar ambiente desta  tabela,  eh especificas)
	ZZA->(dbSetOrder(1))
	DbSelectarea("SF7");DbSetOrder(1)
	dbSelectArea("SA1");dbSetOrder(1)     //CLIETNES
	dbSelectArea("SB1");dbSetOrder(1)     //PRODUTOS
	dbSelectArea("SB2");dbSetOrder(1)     //SALDO FISICO E FIN
	dbSelectArea("SC6");dbSetOrder(1)     //Itens Pedido de venca  --> ordem: C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	dbSelectArea("SE1")
	dbSelectArea("SE4");dbSetOrder(1);dbseek(xFilial("SE4")+cCondPag)  // cONDICAO DE pAGAMENTO
	dbSelectArea("SF4");dbSetOrder(1)      //TES
	dbSelectArea("SA3");dbSetOrder(1)       // CADASTRO DE VENDEDORES
	dbSelectArea("SL4");dbSetOrder(1)	      //CAD CONDICAO NEGOCIADA
	dbSelectArea("SUB");dbSetOrder(1)      //ITENS DO ORCAMENTO TELEVENDAS
	dbSelectArea("SUW");dbOrderNickName('UW_PRODUTO')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionando Clientes					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA1->(DbSeek(xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA))

	If SA1->A1_GERVEN='000685' //----------------- Projeto Comissões por Operador(Pedido do Call Center)
		aVendedores := { {cVend_1},{SA1->A1_VEND},{SA1->A1_VENDCOO},{SA1->A1_CHEFVEN},{SA1->A1_GERVEN} }
	Else
		aVendedores := { {SA1->A1_VENDEXT},{SA1->A1_VEND},{SA1->A1_VENDCOO},{SA1->A1_CHEFVEN},{SA1->A1_GERVEN} }
	Endif

////////////////////////////////////////////////CRIADO PELO JULIO JACOVENKO em 14/10/2011
////////////////////////////////////////////////PARA GRAVAR O CODIGO DO CLIENTE CORRETO QUANDO
////////////////////////////////////////////////TRANSFORMA PROSPECT PARA CLIENTES
///////////////////////////////////////////////////////////////////////////
	cCodCli:=SA1->A1_COD
	cLojCli:=SA1->A1_LOJA
///////////////////////////////////////////////////////////////////////

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao do percentual de comissao           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Inicialmente, vale o maior percentual entre Campanhas e Clientes
//nPerComisCLI := IIF(SA1->A1_COMIS != 0 .and. SA1->A1_COMIS > nComisCamp,SA1->A1_COMIS,nComisCamp)
// mudanca de conceito: o percentual de comissao da campanha sera adicionado ao percentual da regra normal

//comentado por Edivaldo
//cPAGCOM1 	:= 	SA1->A1_PAGCOM1
//cPAGCOM2	:= 	SA1->A1_PAGCOM2
//cPAGCOM3	:=	SA1->A1_PAGCOM3
//cPAGCOM4	:=	SA1->A1_PAGCOM4
//cPAGCOM5	:=	SA1->A1_PAGCOM5

	dbSelectArea("SA3")
	For nX := 1 to Len(aVendedores)
		DbSeek(xFilial("SA3")+aVendedores[nX,1])
		aAdd(aVendedores[nX],SA3->A3_COMIS)
	Next

//³Define o desconto de ICMS padrao                     ³
	SF4->(U_DesICMPad(SA1->A1_EST))

//³Cancela o atendimento anterior automaticamente             ³
// PROJETO F11,
// não cancela mais o atendimento original, nem no orçamento nem no faturamento
//Procura nos pedidos de venda
	dbSelectArea("SC5")
	dbSetOrder(1)
	If !DbSeek(xFilial("SC5")+SUA->UA_NUMSC5)
		If Type("l410Auto") != "U" .And. !l410Auto
			ALERT("PROBLEMA, Pedido de venda n:"+ SUA->UA_NUMSC5 + " não encontrado , entre em contato com o Depto. de Tecnologia Imdepa!")
		Else
			ConOut("PROBLEMA, Pedido de venda n:"+ SUA->UA_NUMSC5 + " não encontrado , entre em contato com o Depto. de Tecnologia Imdepa!")
		Endif
	Endif

////////////////////////////////////////////INCLUIDO PELO JULIO EM 17/10/2011
////////////////////////////////////////////PARA AJUSTAR O CODIGO DO CLIENTE QUANDO
////////////////////////////////////////////DE PROSPECT PARA CLIENTE
	cNumSC5:=SC5->C5_NUM
	cNumFIL:=SC5->C5_FILIAL

//////////////////////////////////////////////////////////////////////////////////////
	Reclock("SUA",.F.)

	If  SUA->UA_OPERAD2 <> cOperAtivo  .AND. SUA->UA_OPERADO <> cOperAtivo  //Mudou o operador
		SUA->UA_OPERAD2 := cOperAtivo
	Endif

	If SA1->A1_GERVEN='000685' //----------------- Projeto Comissões por Operador(Pedido do Call Center)
		SUA->UA_VEND := cVend_1
	Endif

	SUA->(MsUnlock())


//³Altera o cabecalho do pedido de venda                 ³

	Reclock("SC5",.F.)
	SC5->C5_VEND1   := aVendedores[1,1] //INTERNO
	SC5->C5_VEND2   := aVendedores[2,1] //EXTERNO
	SC5->C5_VEND3   := aVendedores[3,1] //COORDE.
	SC5->C5_VEND4   := aVendedores[4,1] //CHEFE VENDAS
	SC5->C5_VEND5   := aVendedores[5,1] //GER.VENDAS
	SC5->C5_COMIS1  := 0
	SC5->C5_COMIS2  := 0
	SC5->C5_COMIS3  := 0
	SC5->C5_COMIS4  := 0
	SC5->C5_COMIS5  := 0
	SC5->C5_TIPLIB  := "2"
	SC5->C5_CODROTA := SUA->UA_CODROTA
	SC5->C5_OCCLI   := SUA->UA_OCCLI
	SC5->C5_TIPFAT  := SUA->UA_TIPFAT
	SC5->C5_MENNOTA := SUA->UA_MENNOTA
	SC5->C5_OPERADO := SUA->UA_OPERADO
	SC5->C5_NUMSUA  := SUA->UA_NUM
	SC5->C5_CLIENTR := SUA->UA_CLIENTR
	SC5->C5_LOJENTR := SUA->UA_LOJENTR
	SC5->C5_GERAWMS :='1'
	MsUnlock()

// Jorge Oliveira - 28/02/2011 - Filial atual trabalha com as Liberacao Comercial utilizando Carta de Negocio
	If lCartLib

		AADD( aCarta, xFilial( "SUA" )	) //  1 - POS_FILIAL
		AADD( aCarta, SUA->UA_CLIENTE		) //  2 - POS_CLIENTE
		AADD( aCarta, SUA->UA_LOJA			) //  3 - POS_LOJA
		AADD( aCarta, SUA->UA_CONDPG		) //  4 - POS_CONDPG
		AADD( aCarta, 0						) //  5 - POS_PRECO_CARTA
		AADD( aCarta, 0						) //  6 - POS_PER_DES_FILIAL
		AADD( aCarta, SUA->UA_TPFRETE		) //  7 - POS_FRETE
		AADD( aCarta, 0						) //  8 - POS_COM_CLIENTE
		AADD( aCarta, 0						) //  9 - POS_MARGEM_CARTA
		AADD( aCarta, SA1->A1_EST			) // 10 - POS_UF_CLIENTE
		AADD( aCarta, SA1->A1_COD_MUN		) // 11 - POS_MUN_CLIENTE
		AADD( aCarta, SA1->A1_REGIAO		) // 12 - POS_REGIAO_CLIENTE
		AADD( aCarta, SA1->A1_MESORG		) // 13 - POS_MESOREGIAO_CLIENTE
		AADD( aCarta, SA1->A1_MICRORE		) // 14 - POS_MICROREGIAO_CLIENTE
		AADD( aCarta, SA1->A1_CNAE			) // 15 - POS_CNAE_CLIENTE
		AADD( aCarta, SA1->A1_ATIVIDA    ) // 16 - POS_ATIVIDADE_CLIENTE
		AADD( aCarta, SA1->A1_GRPSEG     ) // 17 - POS_GRPSEGMENTO_CLIENTE
		AADD( aCarta, SA1->A1_SATIV1     ) // 18 - POS_SEGMENTO_CLIENTE
		AADD( aCarta, 0                  ) // 19 - POS_PERC_DESCONTO_CLIENTE
		AADD( aCarta, SA1->A1_VINCULO    ) // 20 - POS_VINCULO_CLIENTE
		AADD( aCarta, aVendedores[1,1]   ) // 21 - POS_VEND_B2B
		AADD( aCarta, 0                  ) // 22 - POS_PERC_DENCONTO_B2B
		AADD( aCarta, aVendedores[1,1]   ) // 23 - POS_VEND_VI
		AADD( aCarta, 0                  ) // 24 - POS_DESCONTO_VI
		AADD( aCarta, 0                  ) // 25 - POS_COMISSAO_VI
		AADD( aCarta, aVendedores[2,1]   ) // 26 - POS_VEND_VE
		AADD( aCarta, 0                  ) // 27 - POS_DESCONTO_VE
		AADD( aCarta, 0                  ) // 28 - POS_COMISSAO_VE
		AADD( aCarta, aVendedores[3,1]   ) // 29 - POS_VEND_GC
		AADD( aCarta, 0                  ) // 30 - POS_DESCONTO_GC
		AADD( aCarta, 0                  ) // 31 - POS_COMISSAO_GC
		AADD( aCarta, aVendedores[4,1]   ) // 32 - POS_VEND_GE
		AADD( aCarta, 0                  ) // 33 - POS_DESCONTO_GE
		AADD( aCarta, 0                  ) // 34 - POS_COMISSAO_GE
		AADD( aCarta, aVendedores[4,1]   ) // 35 - POS_VEND_DIR
		AADD( aCarta, 0                  ) // 36 - POS_DESCONTO_DIR
		AADD( aCarta, 0                  ) // 37 - POS_COMISSAO_DIR
		AADD( aCarta, SA3->A3_CARGO      ) // 38 - POS_CARGO  -- Depois serah atualizado corretamente

	EndIf

//³Altera os itens do pedido de vendas							 ³
	nItemSUB	:= 1

	SUB->(dbSeek(xFilial("SUB")+M->UA_NUM))
	Do While SUB->UB_FILIAL+SUB->UB_NUM == xFilial("SUB")+M->UA_NUM .and. SUB->(!Eof())

	//³Posicionando Pedidos         			     ³
	//	SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM+SUB->UB_ITEM+SUB->UB_PRODUTO,.F.))
		SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM+SUB->UB_ITEM+SUB->UB_PRODUTO,.F.))

	//³Posicionando de TES	         			     ³
		SF4->(dbSeek(xFilial("SF4")+SUB->UB_TES))

	//Inserido por Edivaldo Gonçalves Cordeiro em 21/10/06                                    //
	//Verifica se o produto em movimentação está habilitado o apanhe/separação pelo WMS       //

		IF  ( TYPE("lTk271Auto") = "U" .OR. !lTk271Auto )
			MsAguarde({||lRetWMS:=SF4->(U_checkWMS(SUB->UB_PRODUTO)) },"WMS","Verificando se o item possui controle de localização...")
		ELSE
			lRetWMS:=SF4->(U_checkWMS(SUB->UB_PRODUTO))
		Endif

	//lLock := SC6->(Reclock("SC6",.F.))
		DBSELECTAREA("SC6")
		Reclock("SC6",.F.)


	//³Verifica se eh preco fiscal bruto                    ³

	// Preço com Acrescimo)
		SC6->C6_PRCACRE := SUB->UB_VRCACRE

		IF lRetWMS

			SC6->C6_ENDPAD:=SF4->(Posicione("SBE",6,xFilial("SBE") +'000007'+'01',"BE_LOCALIZ"))
			SC6->C6_TPESTR:=SF4->(Posicione("DC8",3,xFilial("DC8") +'5',"DC8_CODEST"))
			SC6->C6_SERVIC:=SF4->(Posicione("DC5",2,xFilial("DC5") +'002',"DC5_SERVIC"))
		Endif

		MsUnlock()


	/*
	IF lLock
	SC6->(MsUnlock())
	ENDIF

	*/


	//-----> Carrega variaveis

		cProduto 	:= SUB->UB_PRODUTO
		cLocal	 	:= SUB->UB_LOCAL
		nVlrItem 	:= SUB->UB_VRCACRE  //SD2->D2_PRCVEN
		nBASEICM 	:= SUB->UB_BASEICM
		nQtdItem 	:= SUB->UB_QUANT
		nDescIcm 	:= SUB->UB_DESCICM
		nFreteCal	:= SUA->UA_FRETE //SUA->UA_FRETCAL
		nValmerc 	:= SUA->UA_VALMERC + SUA->UA_ACRECND // VALOR COM ACRESCIMO (PS. NO UA_VALMERC NÃO ESTÁ CONTIDO O ACRESCIMO)
		nDespesa	:= SUA->UA_DESPESA
		nIdade 		:= 0
		NIDADESC6   := 0

		nFreteFob   := SUA->UA_FRETFOB  // Redespacho

	//³Posicionando Estoque, se for transrfeência, busca do estoque da filial de transferência   ³
	// Utilizar a pesquisa de estoque na filial de transferencia somente
	// no atendimento (tmk271), no faturamento verificar o estoque atual
		IF FUNNAME() == 'TMKA271' .AND. !Empty(SUB->UB_FILTRAN)
			cFilialB2	:= SUB->UB_FILTRAN
			cLocalB2 	:= Posicione("SB1",1,cFilialB2+cProduto,"B1_LOCPAD")
		ELSE
			cFilialB2	:= xFilial('SB2')
			cLocalB2 	:= cLocal
		ENDIF

		SB2->(DbSeek(cFilialB2+cProduto+cLocalB2))

	//³Posicionando Produtos         			     ³

		SB1->(DbSeek(xFilial("SB1")+cProduto))

	//³Inicia processo de gravacao de campos especificos    ³
	//³na tabela SUB										³

	//³ ITEM SUB X ITEM ACOLS  	  							³

	//Identifica item do SUB correspondente no alcols






		nItem		:= 0
		nItemacols 	:= 1
		For i:=1 To Len( acols )
			If  !gdDeleted(i)   //  se não estiver deletado (DELETADO = .T.)
				If nItemSUB = nItemacols
					nItem := i
					Exit
				EndIf
				nItemacols++
			Endif
		Next i

	//|CUSTOS        (OBS: qualquer alteração aqui, faça também no M460FIM        º
	//³CAMPANHAS DE VENDAS								³

		nPrcMin := 0
		aComisCamp := {0,0,0,0,0}
		for nJ := 1 to Len(__aProdCamp)
			If __aProdCamp[nJ] != NIL .and. __aProdCamp[nJ,1] == SUB->UB_PRODUTO
				If nPrcMin == 0 .or. (__aProdCamp[nJ,4] < nPrcMin .and. __aProdCamp[nJ,4] != 0)
					nPrcMin := __aProdCamp[nJ,4]
				Endif
			// Verifica o menor percentual de comissao das campanhas de vendas ativas para cada vendedor
				for nK := 1 to Len(aComisCamp)

					If __aProdCamp[nJ,6] != "2" .or. ZZA->(dbSeek(xFilial("ZZA")+__aProdCamp[nJ,2]+aVendedores[nK,1]+str(nK,1),.F.))
						If aComisCamp[nK] == 0 .or. (__aProdCamp[nJ,5] < aComisCamp[nK] .and. __aProdCamp[nJ,5] != 0)
							aComisCamp[nK] := __aProdCamp[nJ,5]
						Endif
					Endif
				next
			Endif
		next

    // Verifica se o produto possui Desconto/Acréscimo por filial
		nDesAcreFil :=SB1->(U_IMDG240E(.F.,SUB->UB_PRODUTO,.T.))

	//³ Faz a avaliacao comercial conforme alcada do operador     ³
		nPrcTabBase := MaTabPrVen(GetMV("MV_TABPAD"),SUB->UB_PRODUTO,SUB->UB_QUANT,SUA->UA_CLIENTE,SUA->UA_LOJA,SUA->UA_MOEDA)

	//Aplica o Desconto/Acréscimo Especial
		If nDesAcreFil <>0
			nPrcTabBase :=A410Arred(nPrcTabBase +((nPrcTabBase*nDesAcreFil)/100))
		Endif


	//|Chamado: 	AAZQ5R 			|Assunto: DESONER CUSTO COML EXPORTADORA |Analista: Cristiano MAchado
	//|Solicitante: Marcia Silveira |Data: 24/06/09

	//////////////////////////////////JULIO JACOVENKO
	//////////////////////////////////AQUI TRATA 4%
	//////////////////////////////////TEM QUE ESTAR NESTA POSICAO, POIS TRATA ITEM A ITEM...
	//³Define o desconto de ICMS padrao                     ³
		SUB->(U_DesICMPad(SA1->A1_EST))
	/////////////////////////////////////////////////




		If SUB->UB_TES == '508'

			If 	SUB->UB_DESC2 == 0 .And.  ( SUB->UB_DESCICM == 0 .and. nDescIcmPad != 0 ) .And. SUB->UB_ACRE2 == 0//| Desconto igual a Zero não necessita calcular.

				nDescReal := (nDescIcmPad + nDescComExp) * (-1)

			ElseIf SUB->UB_DESC2 == 0 .And. nDescIcmPad == 0 .And. nDescIcmPad == 0 .And. SUB->UB_ACRE2 == 0

				nDescReal := nDescComExp * (-1)

			ElseIf SUB->UB_DESC2 <> 0 .Or. nDescIcmPad <> 0 .Or. SUB->UB_ACRE2 <> 0

			//Desconto ICMS
				nDescConcedido := nPrcTabBase - ((nPrcTabBase * SUB->UB_DESCICM) / 100)
			//Desconto Comercial + Comercio Exportadora
				nDescConcedido := nDescConcedido - ((nDescConcedido * SUB->UB_DESC2) / 100)
			//Acrescimo
				nDescConcedido := nDescConcedido + ((nDescConcedido * SUB->UB_ACRE2) / 100)

			//Desconto ICMS
				nDescPossivel := nPrcTabBase - ((nPrcTabBase * nDescIcmPad) / 100)
			//Desconto Comercial + Comercio Exportadora
				nDescPossivel := nDescPossivel - ((nDescPossivel * nDescComExp) / 100)
			//Acrescimo
				nDescPossivel := nDescPossivel + ((nDescPossivel * 0) / 100)

			//|Desconto Real
			//nDescReal := NoRound( ( ( (nDescPossivel / nDescConcedido )- 1 ) * 100) ,nDecDesc)
			//Formula Criada Por Marcia Silveira
				nDescConcedido	:= Iif(nDescConcedido > 0 ,nDescConcedido * (-1), nDescConcedido )

				nDescReal	:= ( ( nDescConcedido / nDescPossivel ) + 1 ) * 100

			Endif
		Else

			If nPrcTabBase > 0
				nPrBaseDesc 	:= SUB->UB_VRUNIT / (1 - ((SUB->UB_DESCICM) /100))
				nDifIcmUnit 	:= nPrBaseDesc * ((nDescIcmPad - SUB->UB_DESCICM) / 100 )
				nDescReal 		:= NoRound( ( 1 -((nPrBaseDesc + nDifIcmUnit) / nPrcTabBase)) * 100 , nDecDesc      )

			Endif
		Endif

   /* ORIGINAL
	If nPrcTabBase > 0
		nPrBaseDesc := SUB->UB_VRUNIT / (1 - ((SUB->UB_DESCICM) /100))
    	nDifIcmUnit := nPrBaseDesc * ((nDescIcmPad - SUB->UB_DESCICM) / 100 )
		nDescReal := NoRound( ( 1 -((nPrBaseDesc + nDifIcmUnit) / nPrcTabBase)) * 100 , nDecDesc      )
	Endif
	*/
	//FIM AAZQ5R

	//³CALCULO DAS COMISSOES  	  							³
	//Alterado por Edivaldo Gonçalves Cordeiro em 06/04/09


		If SA1->A1_GERVEN='000685' //----------------- Projeto Comissões por Operador(Pedido do Call Center
			Processa( {|| n_COMIS1  := SF4->(u_DefComis(SU7->U7_CODVEN,.F.,SA1->A1_PAGCOM1,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[1]  }, 'Comissoes ', 'Processando vendedor 1...' )
		Else
			Processa( {|| n_COMIS1  := SF4->(u_DefComis(SA1->A1_VENDEXT,.F.,SA1->A1_PAGCOM1,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[1]  }, 'Comissoes ', 'Processando vendedor 1...' )
		Endif

		Processa( {|| n_COMIS2  := SF4->(u_DefComis(SA1->A1_VEND   ,.T.,SA1->A1_PAGCOM2,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[2]  }, 'Comissoes ', 'Processando vendedor 2...' )
		Processa( {|| n_COMIS3  := SF4->(u_DefComis(SA1->A1_VENDCOO,.F.,SA1->A1_PAGCOM3,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[3]  }, 'Comissoes ', 'Processando vendedor 3...' )
		Processa( {|| n_COMIS4  := SF4->(u_DefComis(SA1->A1_CHEFVEN,.F.,SA1->A1_PAGCOM4,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[4]  }, 'Comissoes ', 'Processando vendedor 4...' )
		Processa( {|| n_COMIS5  := SF4->(u_DefComis(SA1->A1_GERVEN ,.F.,SA1->A1_PAGCOM5,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[5]  }, 'Comissoes ', 'Processando vendedor 5...' )


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MARGEM (OBS: qualquer alteração aqui, faça também no M460FIM    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// Define variaveis para calculo de custo total e lucro
		nAcreFin  := SE4->E4_ACRSFIN /100 //(Posicione("SE4",1,xFilial("SE4")+cCondPag,"E4_ACRSFIN") / 100) //(NOVO)
		nAcreReal := 1 + (SE4->E4_ACRREAL / 100)

	// Define o custo do item (na moeda 1)
	//Custo Margem de Contribuição

	// Inicializa variável de controle
		nCustoMC :=  U_FCusTrib(.F.)


		If  ( Type("lTk271Auto") == "U" .OR. !lTk271Auto )
			MsAguarde({||nCustoMCR  := SF4->(U_PrcBase( cProduto,cTabPreco,@cTpCust,.F.,"R")) },"MARGEM","Definindo Custo Contribuição Reposicao...")
		Else
			nCustoMCR  :=  U_PrcBase( cProduto,cTabPreco,@cTpCust,.F.,"R")
		Endif

	//Custo Margem de Contribuição Média das Ultimas Compras
		If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
			MsAguarde({||nCustoMCUC :=SF4->(U_PrcBase( cProduto,cTabPreco,@cTpCust,.F.,"U")) },"MARGEM","Definindo Custo Contribuição Média das Ultimas Compras...")
		Else
			nCustoMCUC :=  U_PrcBase( cProduto,cTabPreco,@cTpCust,.F.,"U")
		Endif

	// converte o valor total do item para moeda 1
		nVlrItem := IIF(cMoeda==1,nVlrItem,xMoeda(nVlrItem,cMoeda,1,dDataBase,nDecVLRITEM))

	// Valor  TOTAL DO ITEM com acréscimo e sem IPI =  BASE DE ICM  (UB_VRCACRE * UB_QUANT
		nBASEICM := IIF(cMoeda==1,nBASEICM,xMoeda(nBASEICM,cMoeda,1,dDataBase,nDecBASEICM))

	// ***********     Preco de Venda Deflacionado    *********
	// Define o desconto a ser aplicado no lucro devido ao acrescimo financeiro
	// ou seja, é a diferença das despesas financeiras que pago para o banco das que o cliente me paga

		nDescLucro :=  (nBASEICM * nAcreFin) // (NOVO)

	// Calcula o valor da diferenca de ICMS
		nValDifICM := nVlrItem * ( (nDescIcmPad - nDescIcm) / 100 )
	// RATEIOS
	// Faz o Rateio do frete quando for CIF
	// Rateio das Despesas por item
		nRatDesp := nDespesa / nValmerc 	* nVlrItem

	// ********** Despesa do DOC - Despesas diversas cobradas do cliente**********
		nDespDOC := nDespesa
		lVerST	 := .F.
		nAlicIcm := nValDesp := nAcreCon := nValFret := nCalcIcm := nAlicIpi := nMVA := nValIcmSt := nIcmRetido := 0

		If nItem > 0  .AND. nItem <= Len(aCols)
		//      Valor de ICM                          Valor de PIS                 Valor COFINS

			/**************************************************************************************************************/
		//nValICM :=	mafisret(nItem,"IT_VALICM")
		//If mafisret(nItem,"IT_VALICM") == 0

		//CRISTIANO 31/10/08 Ajuste de Margens ...
			nValDesp := NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_DESPESA,2) // Despesa DOC

			nAcreCon := NoRound(((SUB->UB_VLRITEM + (SUB->UB_VLRITEM / SUA->UA_VALMERC) * SUA->UA_DESPESA) * SE4->E4_ACRSFIN)/100,2) //Acrescimo Condicao

			nValFret := NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_FRETE,2) //Valor Frete

			If SUA->UA_TPFRETE == "F" .AND. nFretefob !=0
				If POSICIONE("SZO",1,XFILIAL("SZO")+SUA->UA_CODROTA,"ZO_REDESPA") = "S" //Verifica frete redespacho
					lRedesp := .T.
				EndIf
			EndIf

			If SUA->UA_TPFRETE == "C" .AND. SUA->UA_FRETE != 0
				nFreteItem	:= nValFret//| CIF - Destacado      ///nFreteCal / nValmerc * nVlrItem
				nFreteItem	:= nValFret - (nValFret * 0.2) // MENOS 20%
			Elseif SUA->UA_TPFRETE == "C" .AND. SUA->UA_FRETE = 0
      	//nFreteItem := NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC * nFreteCal,2) //Valor Frete
				nFreteItem := NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_FRETCAL,2) //Valor Frete Incluso
			Elseif lRedesp
				nFreteItem := NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC * nFreteFob,2) //Valor Frete de Redespacho
			Else
				nFreteItem := 0
			Endif

			nCalcIcm := NoRound((SUB->UB_VLRITEM  + nValDesp + nAcreCon + nValFret),2)   // Base do Icms

			nAlicIpi := SB1->B1_IPI

			cTpCliFor  := SA1->A1_TIPO

			cSegmento  := substr(SA1->A1_GRPSEG,3,1)

			lVerST := U_Fsubtrib(xFilial("SUA"),"S","N",cTpCliFor,SA1->A1_EST,SB1->B1_POSIPI,cSegmento,3,"S")//| Verifica se eh ST

			If lVerST .AND. SF4->F4_CREDST == '3'

				DbSelectarea("SF7")
				If DbSeek(xFilial("SF7")+SB1->B1_GRTRIB,.F.)
					While !eof() .AND. SB1->B1_GRTRIB == SF7->F7_GRTRIB .AND. SF7->F7_GRPCLI == SPACE(03)
						If SA1->A1_EST == SF7->F7_EST
							nMVA := SF7->F7_MARGEM
							Exit
						Endif
						DbSkip()

					EndDo

					nBaseRet 	:= ( nCalcIcm * (1 + nAlicIpi / 100)) * ( 1 +  (nMVA/100) )
					cEstxIcm 	:= GetMv("MV_ESTICM")
					nPosUf		:= At(SA1->A1_EST,cEstxIcm) + 2
					nValIcmSt 	:= (nBaseRet * ((Val(Substr(cEstxIcm,nPosUf,2))/100)))


				Endif

			Endif

			lInterna := (SM0->M0_ESTENT == SA1->A1_EST)

			If SF4->F4_ICM == 'S'
				If lInterna
					nAlicIcm := GetMv('MV_ICMPAD')
				Else

					If SA1->A1_EST $ GetMv('MV_NORTE') .AND. !(SM0->M0_ESTENT $ GetMv('MV_NORTE'))
						nAlicIcm := 7
					Else
						nAlicIcm := 12
					EndIf

				//| Cristiano Machado - 27/12/2012 - 4% Importados ICMS
					If SB1->B1_ORIGEM $ "1/2"
						nAlicIcm := GETMV('IM_ICMIMP') // 4
					EndIf

				Endif
			EndIf

			If nValIcmSt != 0
				nIcmRetido := NoRound(( nValIcmSt - ( nCalcIcm * ( nAlicIcm / 100) )),2)
			Else
				nIcmRetido := 0
			Endif
			DbSelectArea("SYD");DbSeek(xFilial("SYD")+SB1->B1_POSIPI,.F.)

		//Inserido por Edivaldo Gonçalves Cordeiro em 30/11/2009
			If cFilant == '04' .AND. ( SF4->F4_CODIGO $ '540/721/723' ) // Chamado AAZUTY
			//Tratamento para Goiania
				nValICM		:= (nCalcICM * SF4->F4_BASEICM/100) * nAlicIcm / 100

			Else

				IF SF4->F4_PICMDIF == 0 //CRISTIANO DATA 28/11/08 // Reducao da Base do ICMS
					nValICM 	:= NoRound(( nAlicIcm      /100)	* ( nCalcIcm ),2)
				ELSE
					nValICM 	:= NoRound(( nAlicIcm      /100)	* ( nCalcIcm ),2)
					nValICM		:= nValICM - (nValICM * (SF4->F4_PICMDIF / 100 ))
				ENDIF

			//Edivaldo
				If  SF4->F4_BASEICM<>0 .AND. SF4->F4_PICMDIF == 0
					nValICM 	:= NoRound(( nAlicIcm      /100)	* ( nCalcIcm ),2)
					nValICM		:= nValICM - (nValICM * (SF4->F4_BASEICM / 100 ))
				Endif
			//Edivaldo

			Endif

			If SA1->A1_TIPO == 'F' //Cliente Final
				nValICM := NoRound(( 1 + (nAlicIpi /100) ) * ( nValICM ),2)
			Endif

		//Aloquotas PIS e COFINS
			nAliqPis := Iif(SB1->B1_PPIS==0,GetMv("MV_TXPIS"),SB1->B1_PPIS)
			nAliqCof := Iif(SB1->B1_PCOFINS==0,GetMv("MV_TXCOFIN"),SB1->B1_PCOFINS)

		// Percentual de Reducao PIS e COFINS
			nRedPis := SB1->B1_REDPIS
			nRedCof := SB1->B1_REDCOF

		// Calculo do PIS e COFINS
			If SF4->F4_PISCOF == '1'
			//nCalcPis	:= NoRound( ( Iif(SB1->B1_PPIS==0,GetMv("MV_TXPIS"),SB1->B1_PPIS)/100) * (nCalcIcm) , 2 )
				nCalcPis	:= NoRound( ( ( nAliqPis - ( ( nAliqPis / 100 ) * nRedPis) ) / 100 ) * (nCalcIcm) , 2 )
				nCalcCof    := 0
			ElseIf SF4->F4_PISCOF == '2'
				nCalcPis	:= 0
				nCalcCof	:= NoRound( ( ( nAliqCof - ( ( nAliqCof / 100 ) * nRedCof) ) / 100 ) * (nCalcIcm) , 2 )
			//nCalcCof	:= NoRound((Iif(SB1->B1_PCOFINS==0,GetMv("MV_TXCOFIN"),SB1->B1_PCOFINS)/100 )*(nCalcIcm),2)
			ElseIf SF4->F4_PISCOF == '3'
				nCalcPis	:= NoRound( ( ( nAliqPis - ( ( nAliqPis / 100 ) * nRedPis) ) / 100 ) * (nCalcIcm) , 2 )
				nCalcCof	:= NoRound( ( ( nAliqCof - ( ( nAliqCof / 100 ) * nRedCof) ) / 100 ) * (nCalcIcm) , 2 )
			Else
				nCalcCof    := 0
				nCalcPis	:= 0
			Endif

			DbSelectArea("SC6")

		// CHAMADO TECNICO : AAZVST    SOLICITANTE: Marcia Silveira   DATA: 22/08/2013
		// Favor contemplar no cálculo do IMCR nas vendas para fora do Estado, de produtos Importados, a alíquota de 4%, hoje o sistema efetua o cálculo do campo CUSMCR da seguinte forma:
		// Custo standart = 100,00 ( - ) % PIS ( - ) % Cofins ( - ) % ICMS do Estado de origem da venda (ESTE PERCENTUAL NESTA SITUAÇÃO, deve ser substituído pela alíquota de 4%
        // ( = ) Custo Reposição


			If  ( nAlicIcm == GetMv("IM_ICMIMP") ) // Produto Importado e Venda InterEstadual....

				nAuxPis := nAliqPis - ( nAliqPis * nRedPis  /  100 )
				nAuxCof := nAliqCof - ( nAliqCof * nRedCof  /  100 )
				nAuxIcm := nAlicIcm

				nCustoMCR :=  xMoeda(SB1->B1_CUSTD,Val(SB1->B1_MCUSTD),1,dDataBase) * (( 100 - ( nAuxPis + nAuxCof + nAuxIcm ) ) / 100 )

			EndIf
		// AAZVST FIM

		// CHAMADO TECNICO : AAZVO6    SOLICITANTE: Marcia Silveira
    	// Incluir o percentual de 8,25% no custo reposição nas vendas que se enquadram na substituição tributária para as filiais: RS , MT, PR, MG.
		// Ajuste de Mergem Reposicao para ST

			If ( lverSt )

				cFilAjuMar := GetMV("MV_UFAJMGR") // UF's que devem receber o ajuste no custo reposicao...
				cUfFilOrig := SM0->M0_ESTENT /// UF filial origem...

				If ( cUfFilOrig $ cFilAjuMar )

					nCustoMCR  := nCustoMCR * 1.0825 // Acrescimo de 8.25 %

				EndIf
			EndIf

		// AAZV06 - FIM


			/***************************************************************************************************************/

		// Busca ICMS Retido
		//nICMRetido := mafisret(nItem,"IT_VALSOL")  //Idem a isto :	mafisret(nItem,"IT_BASESOL") * mafisret(nItem,"IT_ALIQSOL")/100  - mafisret(nItem,"IT_VALICM")
		//nImpostosnoVlrItem := nValICM + mafisret(nItem,"IT_VALPS2") + mafisret(nITEM,"IT_VALCF2")// + nICMRetido // ver funções padrões do siga
			nImpostosnoVlrItem := nValICM + nCalcPis + nCalcCof + nICMRetido// ver funções padrões do siga

		Else
			nImpostosnoVlrItem := 0
		Endif

	// ********** COMISSOES ***********************************
	// acrescer 63% ao valor do vendedor interno (comis1, comis3 e comis4) em função de incidência de encargos trabalhistas
	// descimo  terçeiro, férias , etc ----> marcio
	// usado no Interno/Externo/Chefe de Venda

		nVDescComis := nQtdItem * nVlrItem * ( (n_COMIS1 * 1.63)  + n_COMIS2 + (n_COMIS3 * 1.63)  + (n_COMIS4 * 1.63) + (n_COMIS5 * 1.63) )/100

	// *********** Fatores (F´s)
	// nFat1 =  Coeficiente Cambial    (COEFC)
	// nFat2 =  Coeficiente Financeiro (COEFF)
	// nFat3 =  Coeficiente Idade      (COEFI)
		If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
        ///JULIO JACOVENKO, em 23/05/2012
        ///AJUSTADO PARA PEGAR A IDADE2
			nIdadeSC6 := u_IdadeAtu(nQtdItem,SB2->B2_IDADE,SB2->B2_DTIDADE) //PEGA A IDADE1 PARA GRAVAR NO SC6
			IF SB2->B2_IDIMDE=0
				MsAguarde({||nIdade :=SF4->(u_IdadeAtu(nQtdItem,SB2->B2_IDADE,SB2->B2_DTIDADE))},"IDADE","Definindo Idade do Produto ...")
			ELSE
				MsAguarde({||nIdade :=SF4->(u_IdadeAtu(nQtdItem,SB2->B2_IDIMDE,SB2->B2_DTCALC))},"IDADE","Definindo Idade do Produto ...")
			ENDIF
		Else
        ///JULIO JACOVENKO, em 23/05/2012
        ///AJUSTADO PARA PEGAR A IDADE2
			IF SB2->B2_IDIMDE=0
				nIdade := u_IdadeAtu(nQtdItem,SB2->B2_IDADE,SB2->B2_DTIDADE)
			ELSE
				nIdade := u_IdadeAtu(nQtdItem,SB2->B2_IDIMDE,SB2->B2_DTCALC)
			ENDIF
			nIdadeSC6 := u_IdadeAtu(nQtdItem,SB2->B2_IDADE,SB2->B2_DTIDADE)

		Endif



		nTJLPdia  := (1+ (GetMV("MV_TJLP",,0) /100)/12)^(1/30) -1 //(1+ (GetMV("MV_TJLP",,0) /100))^(1/365) -1




		nCOEFC:= SB2->B2_COEFC


		nCOEFF:= SB2->B2_COEFF
		nCOEFI:= ((1+ nTJLPdia)^nIdade)- 1


    //julio jacovenko junto com a Marcia, colocado a divisao por 100
    //em 23/05/2012
		nFat1 := (SB2->B2_COEFC/100)	*	nCustoMC
		nFat2 := (SB2->B2_COEFF/100)	*	nCustoMC
		nFat3 := nCOEFI			*	(nCustoMC+ nfat1 + nfat2)


		nFatores := nFat1 + nFat2 + nFat3

	//nTotItemSemIPI  := MaFisRet(nItem,"IT_TOTAL") - MaFisRet(nItem,"IT_VALIPI")

	//CRISTIANO 31/10/08 Ajuste Margens
	//1  - nTotItemSemIPI  := SUB->UB_VLRITEM + nValDesp + nAcreCon + nValFret
		nTotItemSemIPI  := NoRound(SUB->UB_VRCACRE * SUB->UB_QUANT + (SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_DESPESA ),2) + nICMRetido + nValFret

	//Custo médio kardex Gerencial
		nCustoMCg 			:=  nFatores + nCustoMC


		nTxFin  			:=  GETMV("MV_TXFIN",,0)/100  // Similar a Taxa CDI , mas ao mês
		nValCPMF	    	:=  GETMV("MV_CPMF" ,,0)/100  * MaFisRet(nItem,"IT_TOTAL")
		nPrazoMedioCobr 	:= 	SE4->E4_PRZMED //criar campo
		nTaxaDiaria 		:=  ((1 + nTxFin )^(1/30))-1
		nValorDeflacionado 	:=  (nTotItemSemIPI / ((1 + nTaxaDiaria) ^ nPrazoMedioCobr ))

	// Margem de Contribuicao não Gerencial (sem os fatores -> F1, F2, F3 ...)
	//AVALIAR CRISTIANO
		nMC   := nValorDeflacionado - (nValCPMF + nCustoMC  * nQtdItem + nImpostosnoVlrItem + nVDescComis + nFreteItem)
		/********************/
		nMCR  := nValorDeflacionado - (nValCPMF + nCustoMCR  * nQtdItem + nImpostosnoVlrItem + nVDescComis + nFreteItem)

	//|Chamado: 	AAZPZ2 			|Assunto: Calculo Margem Custo Reposicao |Analista: Cristiano MAchado
	//|Solicitante: Marcia Silveira |Data: 11/05/09
		If nValICM == 0 .and. lInterna .and. (lVerST .OR. ( SM0->M0_ESTENT == "MT" .AND. SA1->A1_EST <> SM0->M0_ESTENT )  )
			nMCR  := nMCR - ((nCalcIcm * GetMv('MV_ICMPAD')) / 100)
		Endif

		nMCUC := nValorDeflacionado - (nValCPMF + nCustoMCUC * nQtdItem + nImpostosnoVlrItem + nVDescComis + nFreteItem)
	// Margem de Contribuicao Gerencial (com os fatores -> F1, F2, F3 ...) em Valores
		nMCg   	:= nValorDeflacionado - (nValCPMF + nCustoMCg  * nQtdItem + nImpostosnoVlrItem + nVDescComis + nFreteItem)
	//Indices da Margem de Contribuição (DIVIDIR PELO VALOR TOTAL DA NOTA sem IPI, ou seja é igual a base de ICM )
	// Não Gerencial

	//|Chamado: 	AAZQ5R 			|Assunto: DESONER CUSTO COML EXPORTADORA |Analista: Cristiano MAchado
	//|Solicitante: Marcia Silveira |Data: 24/06/09
		If SUB->UB_TES == '508'

			nAcrComExp := ((nDescComExp * ((SUB->UB_VRCACRE * SUB->UB_QUANT) + nValDesp) / 100 ))

			nMC    := nMC    + nAcrComExp
			nMCR   := nMCR   + nAcrComExp
			nMCUC  := nMCUC  + nAcrComExp
			nMCg   := nMCg   + nAcrComExp

		EndIf
   //FIM AAZQ5R

	// Jorge Oliveira - 07/12/10 - Acrescentar as margens, o Desconto do ICMS ( Filial do Parana e TES 720 e ter Perc. Desc. ICMS )
		If ( cFilAnt == "13" .And. SUB->UB_TES == "720" .And. SUB->UB_DESCICM > 0 )

			nMC   += SUB->UB_VDESICM
			nMCR  += SUB->UB_VDESICM
			nMCUC += SUB->UB_VDESICM
			nMCg  += SUB->UB_VDESICM

		EndIf

		nIMC   := U_ValMarg(nMC  / (nTotItemSemIPI - nIcmRetido)  * 100) //Valida a margem para manter entre -999.99 e 999.99
	// Gerencial
		nIMCg  := U_ValMarg(nMCg  / (nTotItemSemIPI - nIcmRetido) * 100) //Valida a margem para manter entre -999.99 e 999.99
		nIMCR  := U_ValMarg(nMCR  / (nTotItemSemIPI - nIcmRetido) * 100)
		nIMCUC := U_ValMarg(nMCUC / (nTotItemSemIPI - nIcmRetido) * 100)

		nMCTot						+= nMC
		nMCgTot		  				+= nMCg
		nMCRTot						+= nMCR
		nMCUCTot			 			+= nMCUC
		nQtdItem_X_nIdadeTOTAL	+= nQtdItem * nIdade
		nQtdItemTotal 	  			+= nQtdItem
		nTOTTotItemSemIPI 		+= nTotItemSemIPI  //acumulador da base de icm dos itens do pedido



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ@¿
	//³Log de variáveis para localizar diferença nos custos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ@Ù

		If lGeralog

			cGeraLog := ""
			cGeraLog +=	" Filial             -> "+ (SC6->C6_FILIAL) 				+ CRLF
			cGeraLog +=	" Pedido             -> "+ (SC6->C6_NUM) 					+ CRLF
			cGeraLog +=	" Nota               -> "+ (SC6->C6_NOTA) 					+ CRLF
			cGeraLog +=	" Cliente            -> "+ (SC6->C6_CLI) 					+ CRLF
			cGeraLog +=	" Produto            -> "+ (SB1->B1_COD) 					+ CRLF
			cGeraLog +=	" Ncm                -> "+ (SB1->B1_POSIPI) 				+ CRLF
			cGeraLog +=	" nVlrItem           -> "+ cValToChar(nVlrItem) 			+ CRLF
			cGeraLog +=	" n_COMIS1           -> "+ cValToChar(n_COMIS1) 			+ CRLF
			cGeraLog +=	" n_COMIS2           -> "+ cValToChar(n_COMIS2) 			+ CRLF
			cGeraLog +=	" n_COMIS3           -> "+ cValToChar(n_COMIS3) 			+ CRLF
			cGeraLog +=	" n_COMIS4           -> "+ cValToChar(n_COMIS4) 			+ CRLF
			cGeraLog +=	" n_COMIS5           -> "+ cValToChar(n_COMIS5) 			+ CRLF
			cGeraLog +=	" nValIcmSt          -> "+ cValToChar(nValIcmSt) 			+ CRLF
			cGeraLog +=	" nIcmRetido         -> "+ cValToChar(nIcmRetido) 			+ CRLF
			cGeraLog +=	" nValDesp           -> "+ cValToChar(nValDesp) 			+ CRLF
			cGeraLog +=	" nAcreCon           -> "+ cValToChar(nAcreCon) 			+ CRLF
			cGeraLog +=	" nRedPis            -> "+ cValToChar(nRedPis) 				+ CRLF
			cGeraLog +=	" nRedCof            -> "+ cValToChar(nRedCof) 				+ CRLF
			cGeraLog +=	" nAliqCof           -> "+ cValToChar(nAliqCof) 			+ CRLF
			cGeraLog +=	" nAliqPis           -> "+ cValToChar(nAliqPis) 			+ CRLF
			cGeraLog +=	" nCalcCof           -> "+ cValToChar(nCalcCof) 			+ CRLF
			cGeraLog +=	" nCalcPis           -> "+ cValToChar(nCalcPis) 			+ CRLF
			cGeraLog +=	" nAlicIcm           -> "+ cValToChar(nAlicIcm) 			+ CRLF
			cGeraLog +=	" nCalcIcm           -> "+ cValToChar(nCalcIcm) 			+ CRLF
			cGeraLog +=	" nValICM            -> "+ cValToChar(nValICM) 				+ CRLF
			cGeraLog +=	" nTaxaDiaria        -> "+ cValToChar(nTaxaDiaria) 			+ CRLF
			cGeraLog +=	" nPrazoMedioCobr    -> "+ cValToChar(nPrazoMedioCobr) 		+ CRLF
			cGeraLog +=	" nTotItemSemIPI     -> "+ cValToChar(nTotItemSemIPI) 		+ CRLF
			cGeraLog +=	" nFreteCal          -> "+ cValToChar(nFreteCal) 			+ CRLF
			cGeraLog +=	" nValFret           -> "+ cValToChar(nValFret) 			+ CRLF
			cGeraLog +=	" nFreteItem         -> "+ cValToChar(nFreteItem) 			+ CRLF
			cGeraLog +=	" nVDescComis        -> "+ cValToChar(nVDescComis)			+ CRLF
			cGeraLog +=	" nImpostosnoVlrItem -> "+ cValToChar(nImpostosnoVlrItem)	+ CRLF
			cGeraLog +=	" nQtdItem           -> "+ cValToChar(nQtdItem)			 	+ CRLF
			cGeraLog +=	" nCustoMC           -> "+ cValToChar(nCustoMC) 			+ CRLF
			cGeraLog +=	" nCustoMCR          -> "+ cValToChar(nCustoMCR)			+ CRLF
			cGeraLog +=	" nAcrComExp         -> "+ cValToChar(nAcrComExp)			+ CRLF
			cGeraLog +=	" nMCR               -> "+ cValToChar(nMCR)				+ CRLF
			cGeraLog +=	" nValCPMF           -> "+ cValToChar(nValCPMF) 			+ CRLF
			cGeraLog +=	" nValorDeflacionado -> "+ cValToChar(nValorDeflacionado) 	+ CRLF
			cGeraLog +=	" nMC                -> "+ cValToChar(nMC) 					+ CRLF
			cGeraLog +=	" nIMC               -> "+ cValToChar(nIMC)					+ CRLF

			cArquivo := "C:\LOG_CUSTO - "+SC6->C6_FILIAL+"_"+SC6->C6_NUM+"_"+SC6->C6_PRODUTO+"_PED.txt"

			Memowrit(cArquivo , cGeraLog )

		EndIf


		Reclock("SUB",.F.)
	// Faz a gravacao do lucro, da margem de lucro e do custo total
	//Grava Margens
		Replace UB_MC    with nMC		,UB_MCG    with nMCg	 , UB_MCR    with nMCR	 	, UB_MCUC    with nMCUC
	//Grava Indices das Margens
		Replace UB_IMC   with nIMC		,UB_IMCG   with nIMCg	 , UB_IMCR   with nIMCR	 	, UB_IMCUC   with nIMCUC
	//Grava Custos das Margens
		Replace UB_CUSMC with nCustoMC	,UB_CUSMCG with nCustoMCg, UB_CUSMCR with nCustoMCR	, UB_CUSMCUC with nCustoMCUC
	//Grava Coeficientes
		Replace UB_COEFC with nCOEFC	,UB_COEFF  with nCOEFF   , UB_COEFI   with nCOEFI

	//Grava Idade
		Replace UB_IDADE with NIDADESC6 //nIdade

	// Verifica se houve venda perdida
		If SUB->UB_QCONSUL > SUB->UB_QOFERT
		// Registra a venda perdida (Atencao, SUA e SUB devem estar posicionados)
			If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
				MsAguarde({||SF4->(U_GravaVP()) },"Venda Perdida","Registrando Venda Perdida ...")
			Else
				U_GravaVP()
			Endif

		Endif
		MsUnlock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define alcada do operador (vendedor)                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DBSELECTAREA("SA3")
		DBSETORDER(7)
		DBSEEK(xFilial("SA3")+SF4->(RetCodUsr()))
		If SB1->B1_ALCDESC == '1'
			nalcada := SA3->A3_ALCDESC
		Else
			nalcada := SA3->A3_ALCDES2
		EndIf

	// Jorge Oliveira - 28/02/2011 - Projeto Carta Negocio - Criada a posicao 6 no array de operadores
	//			      |--[1]---|   |--[2]----|   |----[3]------| |-[4]-|  |----[5]-----|   |----[6]----|
		aOperador := { SA3->A3_COD, SA3->A3_NOME, SA3->A3_ALCADA, nalcada, SA3->A3_SUPER, SA3->A3_CARGO }

	// Jorge Oliveira - 28/02/2011 - Filial atual NAO trabalha com as Liberacao Comercial utilizando Carta de Negocio
		If !lCartLib

			lOkItem := ( nPrcMin != 0 .And. ( SUB->UB_VRUNIT + SUB->UB_VDESICM ) >= nPrcMin )
		// Faz o tratamento da alcada por margem e desconto real

			If !lOkItem
				lOkItem := nDescReal <= aOperador[4]
			Endif

		//******************* CASOS QUE O PEDIDO PASSA PELA LIBERAÇÃO COMERCIAL DIRETO**************************
		//Caso seja cliente "N00000" (Transferência entre filiais) -> isto foi contemplando no progrmaa imda09.prw função IncPV
		//Caso o cliente seja imdepauto (009974)
			IF !lLibDireto
				If SUA->UA_CLIENTE == "009974"
					lLibDireto := .T.
				Endif
			Endif

		//Caso as  TES de todos os itens não gera duplicata
			If !lLibTES
				If SF4->F4_DUPLIC == 'N'
					lLibTES := .T.
				EndIf
			EndIf

			lOk := IIF(!lOk,.F.,lOkItem) //liberaçao por magem e desconto
			lOk := lOk .OR. lLibDireto .OR. lLibTES
		Else
			lOkItem := .F.
		EndIf

	// Carrega array para posterior envio de e-mail
		aAdd( aAvalCom, { SUB->UB_ITEM , SUB->UB_PRODUTO , SUB->UB_VLRITEM , SUB->UB_MARGEM, lOkItem, nDescReal, SB1->B1_DESC } )

	//************ GRAVA DADOS NO SC6***********
		SC6->( Reclock("SC6",.F.) )
	//--------- Campos de Custos
		SC6->C6_IDADE   := SUB->UB_IDADE


	///////JULIO JACOVENKO, 03/04/2012
	///////para o projeto Idade2
	//////////////////////////////////

		_jarea:=GetArea()
		nIdade2:=0
		DbSelectArea('SB2')
		DbSetOrder(1)
		If DbSeek(xfilial()+SC6->C6_PRODUTO+'01')
        ///JULIO JACOVENKO, em 23/05/2012
        ///AJUSTADO PARA PEGAR A IDADE2
			IF SB2->B2_IDIMDE=0
				nIdade2 := u_IdadeAtu(nQtdItem,SB2->B2_IDADE,SB2->B2_DTIDADE)
				RECLOCK('SB2',.F.)
				SB2->B2_IDIMDE=nIdade2
				SB2->B2_DTCALC:=SB2->B2_DTIDADE
				MSUNLOCK()
			ELSE
				nIdade2 := u_IdadeAtu(nQtdItem,SB2->B2_IDIMDE,SB2->B2_DTCALC)
			ENDIF

    /*
	   IF SB2->B2_IDIMDE=0
	      RECLOCK('SB2',.F.)
	         SB2->B2_IDIMDE=SB2->B2_IDADE
	         SB2->B2_DTCALC:=SB2->B2_DTIDADE
	      MSUNLOCK()
	   ENDIF
	   nIdade2:=SB2->B2_IDIMDE  //POSICIONE("SB2",1,XFILIAL('SB2')+SC6->C6_PRODUTO,"B2_IDIMDE")  //idade2 do produto (atual)
	*/
		EndIf



		RestArea(_jarea)

		SC6->C6_IDADE2 :=nIdade2
	////////////////////////////////////////////////////////
		SC6->C6_MC		:= SUB->UB_MC
		SC6->C6_IMC		:= SUB->UB_IMC
		SC6->C6_CUSMC	:= SUB->UB_CUSMC
		SC6->C6_MCG		:= SUB->UB_MCG
		SC6->C6_IMCG	:= SUB->UB_IMCG
		SC6->C6_CUSMCG	:= SUB->UB_CUSMCG
		SC6->C6_MCR		:= SUB->UB_MCR
		SC6->C6_IMCR	:= SUB->UB_IMCR
		SC6->C6_CUSMCR	:= SUB->UB_CUSMCR
		SC6->C6_MCUC	:= SUB->UB_MCUC
		SC6->C6_IMCUC	:= SUB->UB_IMCUC
		SC6->C6_CUSMCUC	:= SUB->UB_CUSMCUC
		SC6->C6_COEFC	:= SUB->UB_COEFC
		SC6->C6_COEFF	:= SUB->UB_COEFF
		SC6->C6_COEFI	:= SUB->UB_COEFI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inserido por Edivaldo Goncalves Cordeiro                        ³
	//³Trecho em Teste(Regravando comissão Nao Retirar                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If SA1->A1_GERVEN='000685' //----------------- Projeto Comissões por Operador(Pedido do Call Center
			SC6->C6_COMIS1  := SC6->(u_DefComis(SU7->U7_CODVEN,.F.,SA1->A1_PAGCOM1,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[1] //n_COMIS1
		Else
			SC6->C6_COMIS1  := SC6->(u_DefComis(SA1->A1_VENDEXT,.F.,SA1->A1_PAGCOM1,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[1] //n_COMIS1
		Endif

		SC6->C6_COMIS2  := SC6->(u_DefComis(SA1->A1_VEND   ,.T.,SA1->A1_PAGCOM2,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[2] //n_COMIS2
		SC6->C6_COMIS3  := SC6->(u_DefComis(SA1->A1_VENDCOO,.F.,SA1->A1_PAGCOM3,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[3] //n_COMIS3
		SC6->C6_COMIS4  := SC6->(u_DefComis(SA1->A1_CHEFVEN,.F.,SA1->A1_PAGCOM4,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[4] //n_COMIS4
		SC6->C6_COMIS5  := SC6->(u_DefComis(SA1->A1_GERVEN ,.F.,SA1->A1_PAGCOM5,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[5] //n_COMIS5

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Grava as informacoes de comissao na tabela xcomis para posterior uso pela Trigger TRI_XCOMIS ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		SC6->(U_GrvXComis(SC6->C6_FILIAL , SC6->C6_NUM , SC6->C6_ITEM , SC6->C6_COMIS1, SC6->C6_COMIS2 , SC6->C6_COMIS3 , SC6->C6_COMIS4 , SC6->C6_COMIS5))

		SC6->C6_CUSTEMB := SUB->UB_CUSTEMB
		SC6->C6_PLANILH := SUB->UB_PLANILH
		SC6->C6_PLITEM  := SUB->UB_PLITEM
		SC6->C6_FILTRAN := SUB->UB_FILTRAN
		SC6->C6_DESCICM := SUB->UB_DESCICM
		SC6->C6_DESCREA := IIF(nDescReal<0,0,nDescReal)
		SC6->C6_ACREREA := IIF(nDescReal<0,nDescReal*-1,0)
		SC6->C6_PRCTPAD := nPrcTabBase
		SC6->C6_DTINC   := Date()
		SC6->C6_HRINC   := Time()
		SC6->C6_USRINC  := SubStr( cUsuario, 7, 15 )
		SC6->(MsUnlock())

	// Jorge Oliveira - 28/02/2011 - Atualiza as comissoes e descontos para as Filiais que trabalham com as
	// Liberacao Comercial utilizando Carta de Negocio. Essa atualizacao serah feita somente uma vez por Pedido !
		If lCartLib

			aCarta[ POS_CARGO							] := aOperador[6]

			aCarta[ POS_PRECO_CARTA					] += SUB->UB_VLRITEM
			aCarta[ POS_PER_DES_FILIAL				] += SUB->UB_DESC2
			aCarta[ POS_MARGEM_CARTA				] += SC6->C6_IMC

		// Campos da Estrutura de Vendas
			aCarta[ POS_COM_CLIENTE					] += SC6->C6_COMIS1
			aCarta[ POS_PERC_DESCONTO_CLIENTE	] += SUB->UB_DESC2
			aCarta[ POS_DESCONTO_VI					] += SUB->UB_DESC2
			aCarta[ POS_COMISSAO_VI					] += SC6->C6_COMIS1
			aCarta[ POS_DESCONTO_VE					] += SUB->UB_DESC2
			aCarta[ POS_COMISSAO_VE					] += SC6->C6_COMIS2
			aCarta[ POS_DESCONTO_GC					] += SUB->UB_DESC2
			aCarta[ POS_COMISSAO_GC					] += SC6->C6_COMIS3
			aCarta[ POS_DESCONTO_GE					] += SUB->UB_DESC2
			aCarta[ POS_COMISSAO_GE					] += SC6->C6_COMIS4
			aCarta[ POS_DESCONTO_DIR				] += SUB->UB_DESC2
			aCarta[ POS_COMISSAO_DIR				] += SC6->C6_COMIS5

		// Campos do B2B
			aCarta[ POS_VEND_B2B						] := IIf( SUA->UA_OPERADO == "055615", Posicione( "SU7", 1, xFilial( "SU7" ) + SUA->UA_OPERADO, "U7_CODVEN" ), SUA->UA_OPERADO )
			aCarta[ POS_PERC_DENCONTO_B2B 		] += 0

		// Carrega os produtos, para depois comparar com os Produtos da Carta de Negocio
			AADD( aProdCarta, {	SUB->UB_PRODUTO,;		// 01 - POS_PRODUTO
			SB1->B1_DESC,;			// 02 - POS_DESC
			SB1->B1_CODITE,;		// 03 - POS_CODITE
			SUB->UB_QUANT,;		// 04 - POS_QUANT
			SB1->B1_MARCA,;		// 05 - POS_MARCA
			SB1->B1_GRUPO,;		// 06 - POS_GRUPO
			SB1->B1_GRMAR1,;		// 07 - POS_GRPMA1
			SB1->B1_GRMAR2,;		// 08 - POS_GRPMA2
			SB1->B1_GRMAR3,;		// 09 - POS_GRPMA3
			SB1->B1_SGRB1,;		// 10 - POS_SRGB1
			SB1->B1_SGRB2,;		// 11 - POS_SRGB2
			SB1->B1_SGRB3,;		// 12 - POS_SRGB3
			SUB->UB_DESC2,;		// 13 - POS_PERCENT_DESC
			nVlrItem,;				// 14 - POS_PRECO
			SUB->UB_IMC,;			// 15 - POS_MARGEM
			SB1->B1_OBSTPES,;		// 16 - POS_OBS_TIPO_ESTOQUE
			.F.  } )					// 17 - POS_ITEM_OK
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza flag no array de gravacao de campanhas de vendas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nJ := 1 To Len(__aProdCamp)
			If __aProdCamp[nJ] != NIL .and. __aProdCamp[nJ,1] == SUB->UB_PRODUTO
				__aProdCamp[nJ,3] := .T.
			Endif
		Next

	// **********************
	//  Gravacao da Planilha
	// Inicio - 06/05/2003
		If !Empty(SUB->UB_FILTRAN) .AND. EMPTY(SUB->UB_PLANILH)
			lGeraSZE := .T.

			nPos := aScan(aSZE, {|x| x[1] = SUB->UB_FILTRAN})

			If Empty(aSZE) .or. nPos <= 0

				Aadd(aSZE, {SUB->UB_FILTRAN,{{.T.,;									//01 //X_lMKBR_SC7
				' ',;										//02 //
				' ',;                           	//03
				SUB->UB_PRODUTO,;  					//04 //X_ZE_PRODUTO
				SUB->UB_QUANT,;              		//05 //X_ZE_QTDPC
				cFilAnt,;         					//06 //X_ZE_DESTINO filial em uso no momento
				SUB->UB_QUANT,;						//07 //X_ZE_QTDORIG
				' ',;										//08 //X_ZE_HAWB
				SUB->UB_DTNECLI,;						//09 //X_ZE_DTENTRE
				0,;                             	//10 //X_ZE_EXCED
				' ',;									   //11 //X_ZE_LOCAL
				' ',;										//12 //X_ZE_NUMPLAN
				' ',;										//13 //X_ZE_ITEM
				SUB->UB_ITEM,;							//14 //X_ZE_PVITEM
				SUB->UB_QUANT,;						//15 - Backup da quantidade
				'',;										//16 - Descricao
				dDataBase + 5,;						//17 - Previsao de chegada mercadoria
				'';										//18 - Codigo da PE
				}}})
			Else

			// Jorge Oliveira - 20/12/2010 - Incluido campos para a Planilha de Transferencia( posicao 15, 16 e 17 )
				Aadd(aSZE[nPos,2], {.T.,;  						//01 //X_lMKBR_SC7
				' ',;							//02 //
				' ',;                  	//03
				SUB->UB_PRODUTO,;			//04 //X_ZE_PRODUTO
				SUB->UB_QUANT,;			//05 //X_ZE_QTDPC
				cFilAnt,;					//06 //X_ZE_DESTINO
				SUB->UB_QUANT,;			//07 //X_ZE_QTDORIG
				' ',;							//08 //X_ZE_HAWB
				SUB->UB_DTNECLI,;			//09 //X_ZE_DTENTRE
				0,;							//10 //X_ZE_EXCED
				' ',; 						//11 //X_ZE_LOCAL
				' ',;							//12 //X_ZE_NUMPLAN
				' ',;							//13 //X_ZE_ITEM
				SUB->UB_ITEM,;				//14 //X_ZE_PVITEM
				SUB->UB_QUANT,;			//15 - Backup da quantidade
				'',;							//16 - Descricao
				dDataBase + 5,;			//17 - Previsao de chegada mercadoria
				'';							//18 - Codigo da PE
				})
			EndIf
		EndIf
		SUB->(dbskip())
		nItemSUB++
	Enddo

// Jorge Oliveira - 28/02/2011 - Filial trabalha com Liberacao Comercial utilizando Carta de Negocio
	If lCartLib

		aCarta[ POS_MARGEM_CARTA ] := U_ValMarg( nMCTot / nTOTTotItemSemIPI * 100 )

	// Chama a rotina que irah informar se tem alguma Carta de Negocio que poderah liberar o Pedido
		Processa( {|| lOkItem := SUB->( U_A710Carta( aCarta, aProdCarta, @aAvalCom, ( SUA->UA_OPERADO == "055615" ) ) ) }, "Carta de Negócios", "Consultando Cartas de Negócios..." )
		lOk := lOkItem

	EndIf

	IF SC5->C5_LIBREPR = "S" // Libera quando o pedido estiver macado para reprocesso  - Marca Pedido
		lOk := .T.
	ENDIF

//| ANALISTA:CRISTIANO MACHADO CHAMADO:AAZS0B     SOLICITANTE: JULIANO       DESCRICAO: INFLUENCIAVA NA LIBERACAO DE CREDITO    DATA: 02/06/2010
//| O pedido passou pela liberacao comercial, devo gerar o SC9
	If lOk
		dbSelectArea("SC5")
		dbSetOrder(1)
		DbSeek(xFilial("SC5")+SUA->UA_NUMSC5)
//| Adicionado Flag para liberar o pedido qdo ele passa pela liberação comercial  // MQB 06/10/2005
// ANALISTA:CRISTIANO MACHADO CHAMADO:AAZS0B     SOLICITANTE: JULIANO       DESCRICAO: INFLUENCIAVA NA LIBERACAO DE CREDITO    DATA: 02/06/2010
		If Found()
			Reclock("SC5",.F.)
			SC5->C5_LIBEROK := "S"
			SC5->C5_LIBERAD := SF4->(RetCodUsr())
			MsUnlock()
		Endif
	//---fim da flag
		SC6->(dbSetOrder(1))		// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM,.F.))
		SA1->( dbSeek(xFilial('SA1')+SC6->C6_CLI+SC6->C6_LOJA) )

		dbSelectArea('SC6')
		Do While !Eof() .and. xFilial('SC6') == SC6->C6_FILIAL .and. SC5->C5_NUM == SC6->C6_NUM
		/* funcao Microsiga para liberacao do item posicionado do pedido SC6
		Parametros ExpN1: Registro do SC6
		ExpN2: Quantidade a Liberar
		ExpL3: Bloqueio de Credito
		ExpL4: Bloqueio de Estoque
		ExpL5: Avaliacao de Credito
		ExpL6: Avaliacao de Estoque
		ExpL7: Permite Liberacao Parcial
		ExpL8: Tranfere Locais automaticamente
		ExpA9: Empenhos ( Caso seja informado nao efetua a gravacao
		apenas avalia ).
		ExpbA: CodBlock a ser avaliado na gravacao do SC9
		ExpAB: Array com Empenhos previamente escolhidos(impede selecao dos empenhos pelas rotinas)
		ExpLC: Indica se apenas esta trocando lotes do SC9
		ExpND: Valor a ser adicionado ao limite de credito
		ExpNE: Quantidade a Liberar - segunda UM
		*/
		//| processa a liberacao do item

			Begin Transaction
//|		MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,.T.,.T.,.T.,.T.,.F.,.F.,,) -  ORIGINAL
		//|                                        BLC, BLE, ADC, ADE,
				MaLibDoFat(SC6->(RecNo()), SC6->C6_QTDVEN, .F., .F., .T., .T., .F., .F.)
			End Transaction
			DbSkip()
		EndDo
	Else  // nao deve liberar o pedido
	// Localiza o pedido de venda relacionado ao atendimento
		DbSelectarea("SC5")
		DbSetOrder(1)
		If DbSeek(xFilial("SC5")+SUA->UA_NUMSC5)
		// Verifica se o pedido esta liberado
			DbSelectarea("SC9")
			DbSetorder(1)
			If DbSeek(xFilial("SC9")+SUA->UA_NUMSC5)
			// estorno as liberacoes
				xaCab := {{'C5_NUM'      ,SUA->UA_NUMSC5      , },;
					{'C5_TIPO'     ,SC5->C5_TIPO        , },;
					{'C5_CLIENTE'  ,SC5->C5_CLIENTE     , },;
					{'C5_LOJACLI'  ,SC5->C5_LOJACLI     , },;
					{'C5_TIPOCLI'  ,SC5->C5_TIPOCLI     , },;
					{'C5_CONDPAG'  ,SC5->C5_CONDPAG     , },;
					{'C5_EMISSAO'  ,SC5->C5_EMISSAO     , },;
					{'C5_MOEDA'    ,SC5->C5_MOEDA       , },;
					{'C5_TIPLIB'   ,SC5->C5_TIPLIB      , } }

			// incluo os campos especificos
				For nField := 1 To Len(aStrucSC5)
					cCampo := aStrucSC5[nField,1]
					Aadd( xaCab, {cCampo, SC5->&(cCampo), } )
				Next

				xaIt := {}
				dbselectarea("SC6")
				dbSetOrder(1)	//FILIAL+NUMERO+ITEM
				dbSeek(xFilial("SC6")+SUA->UA_NUMSC5)
				while C6_FILIAL+C6_NUM == xFilial("SC6")+SUA->UA_NUMSC5 .and. !Eof()
					xaItem := {}

					aAdd(xaItem,{'C6_ITEM'     ,SC6->C6_ITEM    , } )
					aAdd(xaItem,{'C6_PRODUTO'  ,SC6->C6_PRODUTO , } )
					aAdd(xaItem,{'C6_QTDVEN'   ,SC6->C6_QTDVEN  , } )
					aAdd(xaItem,{'C6_PRCVEN'   ,SC6->C6_PRCVEN  , } )
					aAdd(xaItem,{'C6_VALOR'    ,SC6->C6_VALOR   , } )
					aAdd(xaItem,{'C6_TES'      ,SC6->C6_TES     , } )
					aAdd(xaItem,{'C6_QTDLIB'   ,0               , } )
					aAdd(xaItem,{'C6_LOCAL'    ,SC6->C6_LOCAL   , } )
					aAdd(xaItem,{'C6_PRUNIT'   ,SC6->C6_PRUNIT  , } )
					aAdd(xaItem,{'C6_CLASFIS'  ,SC6->C6_CLASFIS , } )
				// incluo os campos expecificos
					For nField := 1 To Len(aStrucSC6)
						cCampo := aStrucSC6[nField,1]
						Aadd( xaItem, {cCampo, SC6->&(cCampo), } )
					Next

					AADD(xaIt,aClone(xaItem))
					dbskip()
				end
				MSExecAuto({|w,x,y| Mata410(w,x,y)},xaCab,xaIt,4)
				If lMsErroAuto
					Mostraerro()
				Endif
			Endif
		EndIf
	EndIf

	dbSelectArea('SC5')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia a transacao de inclusao do pedido de vendas  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Begin Transaction

// Inicio - 07/05/2003
	If lGeraSZE
	// inicio a geracao da planilha de transferecia
	// quem vai distribuir eh a filial que vai enviar a mercadoria
	// backup
		__aCols := aClone(aCols)
		__aHead := aClone(aHeader)
		__cFil  := cFilAnt
	// qunatidade de planilhas a serem geradas depende das filiais (FILTRAN) utilizadas
	// para gerar a transferencia. Serah gerada uma planilha para cada filial utilizada
		For nSZE := 1 To Len(aSZE)
			aCols   := Array(0)
			aHeader := Array(0)
			cFilAnt := aSZE[nSZE,1]

		// gera planilhas de transferencia sempre na filial distribuidora
			If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
				MsAguarde({||SF4->(u_IMD080Plan( .F., ' ', aSZE[nSZE,2] ))},"Item de Transferência","Gerando Planilha ...")
			Else
				u_IMD080Plan( .F., ' ', aSZE[nSZE,2] )
			Endif

			cFilAnt := __cFil


		// Recupera o numero/item da planilha de transferencia
			For ncItem := 1 To Len(aSZE[nSZE,2])
			// item do pedido de venda
				__cItem := aSZE[nSZE,2,ncItem,X_ZE_PVITEM]

			// recupero a linha do item que vai ser gravado no PV

				SC6->(dbSetOrder(1))		// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				SC6->(dbSeek(xFilial("SC6")+SUA->UA_NUMSC5+__cItem,.F.))
				SC6->(Reclock("SC6",.F.))
			// salvo o numero/item da planilha no item do pedido
				SC6->C6_PLANILH := aSZE[nSZE,2,ncItem,X_ZE_NUMPLAN]    // SZE->ZE_NUMPLAN
				SC6->C6_PLITEM := aSZE[nSZE,2,ncItem,X_ZE_ITEM]    // SZE->ZE_ITEM
				SC6->( MsUnlock() )

			// SUB --> PROJ F11
			// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				SUB->(dbSeek(xFilial("SUB")+SUA->UA_NUM+__cItem,.F.))
				SUB->(Reclock("SUB",.F.))
			// salvo o numero/item da planilha no item do pedido
				SUB->UB_PLANILH := aSZE[nSZE,2,ncItem,X_ZE_NUMPLAN]
				SUB->UB_PLITEM 	:= aSZE[nSZE,2,ncItem,X_ZE_ITEM]
				SUB->( MsUnlock() )

			// reserva na planilha
				SZE->(dbSetOrder(3))
				SZE->( dbSeek(xFilial("SZE")+SC6->C6_PLANILH+SC6->C6_PLITEM) )

				SZE->(Reclock("SZE",.F.))
				SZE->ZE_QTDRES := SC6->C6_QTDVEN
				SZE->( MsUnlock() )

				SZE->(dbSetOrder(1))
			Next

		// processa a planilha gerada  e  gera o pedido de compra e pedido de venda correspondente a planilha
		//If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
			cFilAnt := aSZE[nSZE,1]
		**********************************************************
		//Alterado por Edivaldo Gonçalves Cordeiro em 31/07/06  //
		//Inserido a passagem de parâmetro(M->UA_NUM)           //
		**********************************************************
			If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
				MsAguarde({||SF4->(u_IMD090Proc(.F.,,M->UA_NUM))},"Item de Transferência","Processando Planilha ...")
			Else
				u_IMD090Proc(.F.,,M->UA_NUM)
			Endif

			cFilAnt := __cFil

		Next

		aHeader := __aHead
		aCols   := __aCols
	EndIf

	nIMCTot 	:= U_ValMarg(nMCTot   / nTOTTotItemSemIPI * 100)
	nIMCgTot	:= U_ValMarg(nMCgTot  / nTOTTotItemSemIPI * 100)
	nIMCRTot	:= U_ValMarg(nMCRTot  / nTOTTotItemSemIPI * 100)
	nIMCUCTot	:= U_ValMarg(nMCUCTot / nTOTTotItemSemIPI * 100)

	dbSelectArea("SC5")
	dbSetOrder(1)
	If DbSeek(xFilial("SC5")+SUA->UA_NUMSC5)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Totalizadores do Pedido (SC5)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SC5->( Reclock("SC5",.F.) )
		SC5->C5_IMC		:= nIMCTot
		SC5->C5_IMCG	:= nIMCgTot
		SC5->C5_IMCR  	:= nIMCRTot
		SC5->C5_IMCUC 	:= nIMCUCTot
		SC5->C5_IDADE	:= nQtdItem_X_nIdadeTOTAL / nQtdItemTotal

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Libera o Pedido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lOk
			SC5->C5_LIBEROK := "S"
			SC5->C5_LIBERAD := SF4->(RetCodUsr())
		Else
		// Jorge Oliveira - 28/02/2011 - Projeto Carta Negocios
			SC5->C5_LIBEROK := " "
			SC5->C5_LIBERAD := Space( 6 )
		Endif

		SC5->( MsUnlock() )

	//--------------------

		dbSelectArea("SUA")
		RecLock("SUA",.F.)
		If SC5->C5_LIBEROK == "S"
			SUA->UA_STATUS := "LIB"
		Endif
		MsUnlock()
		If  ( Type("lTk271Auto") <> "U" .AND. lTk271Auto )
			cResp := "PALMJOB: " + Space(4) + "Pedido " + SC5->C5_NUM + " importado com sucesso."
			ConOut(cResp)
		EndIf
	Else
	// Cancela toda a transacao
		If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
			u_Mensagem("Nao foi possivel encontrar o pedido "+SC6->C6_NUM+". Favor acionar o Depto de Tecnologia Imdepa.")
		Else
			ConOut("Nao foi possivel encontrar o pedido "+SC6->C6_NUM+". Favor acionar o Depto de Tecnologia Imdepa.")
		EndIf
		Final("Erro ao localizar pedido de venda.")
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualizo flag para ser considerada a consulta anterior     ³
//³quando o usuario deleta algum item.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	for nX := 1 to Len(aCols)
		If gdDeleted(nX)
			If SUB->(dbSeek(xFilial("SUB")+SUA->UA_NUMORIG+strzero(nX,2)+aCols[nX,X_PRODUTO]))
				SUB->(Reclock("SUB",.F.))
				SUB->UB_FLAGCON := "S"
				SUB->(MsUnlock())
			Endif
		Endif
	next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro os itens de campanhas de vendas relacionadas a este pedido.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("ZZI")
	for nX := 1 to Len(__aProdCamp)
		If __aProdCamp[nX] != NIL .and. __aProdCamp[nX,3]
			Reclock("ZZI",.T.)
			Replace ZZI_FILIAL with xFilial("ZZI"),;
				ZZI_NUM    with SUA->UA_NUMSC5,;
				ZZI_PRODUT with __aProdCamp[nX,1],;
				ZZI_CODCAM with __aProdCamp[nX,2]
			MsUnlock()
		Endif
	next
	__aProdCamp := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se eh primeira compra do cliente            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If __PrimComp == "S"  // primeira compra
		If lEnvMail
		//Envia e-mail para o departamento de credito avisando sobre novo cliente
			EnvMailCred(SUA->UA_NUMSC5)
		Endif
		__PrimComp := "N"	// Primeira compra do cliente
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso um dos itens possua uma margem de lucro menor  ³
//³ que a definida no cadastro de vendedores, gera um   ³
//³ E-mail para o superior imediato do vendedor         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lOk
	//	u_Mensagem('Pedido reprovado pela avaliação comercial automática!','INFO')
		If lEnvMail
			GeraMens(aOperador[1],aAvalCom,aOperador[5],aOperador[2],aOperador[3],aOperador[4])
		Endif
	Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura o ambiente                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Restarea(aAreaSUA)
	Restarea(aAreaSUB)
	Restarea(aAreaSA1)
	Restarea(aAreaSB1)
	Restarea(aAreaSF4)
	Restarea(aAreaSA3)
	Restarea(aAreaSL4)
	Restarea(aAreaSUW)
	Restarea(aAreaSC5)
	Restarea(aAreaSC6)
	Restarea(aAreaSB2)
	Restarea(aArea)

//Verifico se houve algum erro na composicao das comissoes,havendo erro envia log por e-mail
	If Len(aLogComiss)>0
		MailMaxComissao()
	Endif


	If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
		MsAguarde({||SF4->(Testetmkok())},"Aguarde...","Verificando se é cópia e processando...")
	Else
		Testetmkok()
	Endif


////////////////////////////////////////////////CRIADO PELO JULIO JACOVENKO em 14/10/2011
////////////////////////////////////////////////PARA GRAVAR O CODIGO DO CLIENTE CORRETO QUANDO
////////////////////////////////////////////////TRANSFORMA PROSPECT PARA CLIENTES
///////////////////////////////////////////////////////////////////////////

	IF SA1->A1_STATUS=='X'
		fVeCodCli(cCodcli,cLojCli,cNumSC5,cNumFil)
	ENDIF


///////////////////////////////////////////////////////////////////////////
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³DEFCOMIS    ³ Autor ³Márcio Borges        ³ Data ³ 28/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Define o percentual de comissao dos vendedores              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³obs       ³Deve se estar posicionado no SB1                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ESPECIFICO PARA O CLIENTE IMDEPA 						           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß                                              '
/*/
*********************************************************************
User Function DefComis(_cVendedor,lRep,cPagCom,_nDesNeg,_nAcreNeg)
*********************************************************************

	Local aSaveArea	    := GetArea()
	Local nComCli       := SA1->A1_COMIS    	  // Comissão CLiente
	Local nProdComiss	:= SB1->B1_COMIS          //Comissao do Produto
	Local cProdMerc		:= SB1->B1_MERCADO
	Local cDescComis    := GetMV("MV_COMIDES")
	Local cAcreComis    := GetMV("MV_COMIACR")
	Local nLimDescComis := GetMV("MV_LIMDESC",,0) //Limite máximo p/ Desconto na Comissao do Vendedor
	Local _ComisVend    := SA3->(Posicione("SA3",1,xFilial("SA3")+ _cVendedor,"A3_COMIS"))
	Local nPerComisREP  := SA1->A1_COMISRE
	Local nComisPaga    := 0
	Local lTemLimDesc   :=.F.

//Tratamento para o Desconto na Comissao do Vendedor interno
	If !lRep
		If nLimDescComis > 0 .AND. _nDesNeg > nLimDescComis
			lTemLimDesc:=.T.
		Endif
	Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso nao tenha sido passado o vendedor ou para este cliente 		 ³
//³nao se paga comissao para este vendedor, retorna 0          		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(_cVendedor) .or. cPagCom <> "1"
		Return 0
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso as comissoes nao estejam cadastradas no SA1 nem nas campanhas   ³
//³vale a menor entre o Cadastro de Produtos e o Cadastro de Vendedores.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//Alterado esta lógica para: se A1_COMIS == 0 vale a formula acima, caso contrário, é a fórmula acima X A1_COMIS/100 */
//vide abaixo  (cONSIDERA SEMRE A MENOR COMISSAO ENTRE A COMISSAO DO PRODUTO E A DO VENDEDOR)

//Solicitado por Beto 25/06/09
//If _ComisVend == 0 .OR. nProdComiss == 0
//	nformula_comissao := iif(_ComisVend > nProdComiss,_ComisVend,nProdComiss)  //Max(_ComisVend,nProdComiss)
//Else
	nformula_comissao := iif(_ComisVend < nProdComiss,_ComisVend,nProdComiss)  //Min(_ComisVend,nProdComiss)
//EndIf

//|Chamado: 	AAZQ9Y 			|Assunto: Comissao Repasse Produto Mercado |Analista: Cristiano MAchado
//|Solicitante: Marcia Silveira |Data: 24/06/09
//|Obs.: SATIV1 = Montadoras

	If nComCli == 0 .or. (cProdMerc == 'S' .AND. SA1->A1_SATIV1 = '000002')

//If cProdMerc == 'S' .AND. SA1->A1_SATIV1 = '000002'
		nComCli := nformula_comissao
	Elseif cProdMerc == 'N'
		nComCli := nformula_comissao * nComCli/100
	Elseif cProdMerc == 'S' .AND.  SA1->A1_SATIV1 <> '000002'
		nComCli := nformula_comissao * nComCli/100

	Endif
//FIM AAZQ5R

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Aplica desconto nos percentuais de comissao (conforme CUS10)      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Tratamento para o Desconto na Comissao do Vendedor
	If cDescComis == "S"
		If lTemLimDesc
			nComCli := nComCli * (1-(nLimDescComis/ 100))
		Else
			nComCli := nComCli * (1-(_nDesNeg / 100))
		Endif
	Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Aplica acrescimo nos percentuais de comissao (conforme CUS10)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cAcreComis == "S"
		nComCli := nComCli * (1+(_nAcreNeg / 100))
	Endif

// Caso For Vendedor Representante  e Tiver comissão específica no SA1->A1_COMISRE
	IF nPerComisREP  <> 0 .AND. lRep
		nComCli := nPerComisREP
	ENDIF


	RestArea(aSaveArea)

Return nComCli



Static Function MailMaxComissao()

	Local cServer   := GetMV("MV_RELSERV" )
	Local cAccount  := Alltrim(GETMV("MV_RELACNT"))
	Local cPassword := Alltrim(GETMV("MV_RELPSW"))
	Local lAuth     := Getmv("MV_RELAUTH")
	Local lResult   := .F.
	Local cError    := ""
	Local cHtml     := ""
	Local cPara     := Alltrim(Getmv("MV_LOGCOMI"))

	cHtml := '<html>'	+ CRLF
	cHtml += '<head>'	+ CRLF
	cHtml += '<title>Log de Comissoes</title>' //+ CRLF
	cHtml += '</head>'
	cHtml += '<body bgcolor=white text=black  >'

	cHtml+='<center><h1>Comissões - Relatório para Análise</h1></center>'
	cHtml+='<hr width=100% noshade>' + CRLF
	cHtml+='<PRE>
	cHtml+='<td>Data de Emissão :'+ dToc(dDataBase) + '</td>'  + CRLF
	cHtml+='</PRE>


	cHtml +='<table border="1" width="100%">'
	cHtml +='<tr bgcolor="#99CCFF" ><td> FILIAL </td>'
	cHtml +='<td>ORCAMENTO        </td>'
	cHtml +='<td>PRODUTO          </td>'
	cHtml +='<td>VENDEDOR         </td>'
	cHtml +='<td>COMISSAO VENDEDOR</td>'
	cHtml +='<td>COMISSAO PRODUTO </td>'
	cHtml +='<td>COMISSAO PAGA    </td>'


	For i=1 to len(aLogComiss)
		__cFilial  := aLogComiss[i,1]
		_cNumOrc   := aLogComiss[i,2]
		_cProduto  := aLogComiss[i,3]
		cVendedor  := aLogComiss[i,4]
		nComisVend := aLogComiss[i,5]
		nComisProd := aLogComiss[i,6]
		nComisPaga := aLogComiss[i,7]

		cHtml += '<tr>'
		cHtml += '<td  align=middle >'+ __cFilial +     '</td>'
		cHtml += '<td  align=middle >'+ _cNumOrc+       '</td>'
		cHtml += '<td  align=middle >'+_cProduto+       '</td>'
		cHtml += '<td width="49%" align=middle >'+ SubStr(cVendedor,1,25) +     '</td>'
		cHtml += '<td  align=middle >'+Str(nComisVend)+ '</td>'
		cHtml += '<td  align=middle >'+Str(nComisProd)+ '</td>
		cHtml += '<td  align=middle >'+Str(nComisPaga)+ '</td>'
	Next I

	cHtml += '</table>'
	cHtml += '</body>' + CRLF
	cHtml += '</html>' + CRLF
	cHtml += CRLF


	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

	If lResult .And. lAuth
		lResult := MailAuth(cAccount,cPassword)
		If !lResult
			lResult := QADGetMail() // Funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
		EndIf
		If !lResult
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			MsgInfo(cError,OemToAnsi("Erro de Autenticacao"))
			Return Nil
		Endif
	Else
		If !lResult
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			MsgInfo(cError,OemToAnsi("Erro de Conexao"))
			Return Nil
		Endif
	EndIf

	cAssunto := "COMISSOES - ERRO NA GERAÇÃO -  DATA DE GERAÇÃO : " + DTOC(DDATABASE)

	If lResult
		SEND MAIL FROM cAccount ;
			TO		cPara ;
			CC   	' ';
			SUBJECT cAssunto;
			BODY    cHtml ;
			RESULT lResult

		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			Msginfo(" - Nao Enviou Email - " + cError)
		EndIf
	Endif

	DISCONNECT SMTP SERVER

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³EnvMailCreº Autor ³Microsiga           º Data ³  11/04/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Envia e-mail para o departamento de credito avisando que   º±±
±±º          ³ foi inserido um novo cliente.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico para o cliente IMDEPA                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*********************************************************************
Static Function EnvMailCred(cNum)
*********************************************************************

	Local cServer := GetMV("MV_RELSERV" ),;
		cAccount := Alltrim(GETMV("MV_RELACNT")),;
		cPassword := Alltrim(GETMV("MV_RELPSW")),;
		lAuth := Getmv("MV_RELAUTH"),;
		cAssunto := "Cliente novo",;
		cMensagem,cEmailTo := "",cEmailBcc:="",;
		lResult  := .F.,;
		cError := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense³
//³que somente ela recebeu aquele email, tornando o email mais personalizado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cEmailTo := GetMV("MV_EMAILCR")

// Posiciona arquivo de pedidos de venda (SC5)
	dbSelectArea("SC5")
	dbSetOrder(1)
	DbSeek(xFilial("SC5")+cNum)

// corpo do e-mail
	cMensagem := "Ao responsável pelo departamento de crédito"
	cMensagem += CRLF
	cMensagem += CRLF
	cMensagem += "O sistema Advanced Protheus comunica a inserção do primeiro pedido de venda para o cliente. " + CRLF
	cMensagem += "Favor proceder a avalidação de crédito do pedido de venda e a classificação do cliente em relação ao crédito." + CRLF
	cMensagem += "Seguem abaixo os dados do pedido:" + CRLF+CRLF
	cMensagem += "Número: "+SC5->C5_NUM + CRLF
	cMensagem += "Emissão: "+dtoc(SC5->C5_EMISSAO) + CRLF
	cMensagem += "Código/Loja do Cliente....: "+SA1->A1_COD+"/"+SA1->A1_LOJA + CRLF
	cMensagem += "Nome do Cliente..............: "+SA1->A1_NOME + CRLF
	cMensagem += "Valor do Pedido de Venda: "+Transform(aValores[6],"@E 99,999,999.99") + CRLF

// conectando-se com o servidor de e-mail
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

// fazendo autenticacao
	If lResult .And. lAuth
		lResult := MailAuth(cAccount,cPassword)
		If !lResult
			If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
				lResult := QADGetMail() // Funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
			Else
				ConOut("Não foi possivel autenticar o usuário ou senha, será desconectado...")
			Endif
		EndIf
		If !lResult
		//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
				u_Mensagem("Erro de Autenticacao no envio de e-mail: "+cError)
			Else
				ConOut("Erro de Autenticacao no envio de e-mail: "+cError)
			Endif
			Return Nil
		Endif
	Else
		If !lResult
		//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
				u_Mensagem("Erro de Conexao no envio de e-mail: "+cError)
			Else
				ConOut("Erro de Conexao no envio de e-mail: "+cError)
			Endif
			Return Nil
		Endif
	EndIf

// enviando e-mail
	If lResult
		SEND MAIL FROM cAccount ;
			TO			 cEmailTo;
			BCC     	cEmailBcc;
			SUBJECT 	cAssunto;
			BODY    	cMensagem;
			RESULT lResult
		If !lResult
		//Erro no envio do email
			GET MAIL ERROR cError

			If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
				u_Mensagem("Erro no envio de e-mail: "+cError)
			Else
				ConOut("Erro no envio de e-mail: "+cError)
			Endif
		EndIf
		DISCONNECT SMTP SERVER
	EndIf

Return(lResult)
/**
*   Rotina: IMDF060
*   Funcao: Controle de alcada de vendedores
*   Autor : Microsiga
*   Data  : Abril de 2003
*
*/
*********************************************************************
Static Function geraMens(cVend,aResult,cSuperior,cNome,nAlcada,nAlcDesc)
*********************************************************************

//< cCodPagto > - Vindo da tela do telemarketing
//< cVend   >
//< UA_CLIENTE >   - Vindo da tela do tmk
//< UA_NUM     >   - numero do pedito tmk
// ddatabase  ou datap

	Local cArq
	Local aArea     := GetArea()
	Local aAreaSA3  := SA3->( GetArea() )
	Local cTexto := ''
	Local ix
	Local cServer := GetMV("MV_RELSERV" ),;
		cAccount := Alltrim(GETMV("MV_RELACNT")),;
		cPassword := Alltrim(GETMV("MV_RELPSW")),;
		lAuth := Getmv("MV_RELAUTH"),;
		lResult  := .F.,;
		cError := ""
	Local nTotMerc

	If Empty( cSuperior )
		If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
			u_Mensagem('Não foi possível enviar e-mail ao superior para avaliação, motivo: superior não cadastrado no cadastro do vendedor.')
		Else
			ConOut('Não foi possível enviar e-mail ao superior para avaliação, motivo: superior não cadastrado no cadastro do vendedor.')
		Endif
		Return
	Endif

	cTexto := Space(5)+CRLF
	cTexto += 'OCORRENCIA DE VENDA BLOQUEADA PELA AVALIAÇÃO COMERCIAL AUTOMÁTICA'+CRLF
	cTexto += '------------------------------------------------------------------------------------------------------------------'+CRLF
	cTexto += 'Pedido: '+ SUA->UA_NUMSC5+'                       Data: '+Dtoc( ddatabase )+ ' Hora: '+Time()+CRLF
	cTexto += Space(5)+CRLF
	cTexto += 'Vendedor     : '+cVend+'-'+cNome+CRLF
	cTexto += 'Margem Minima: '+Transform(nAlcada ,'@E 99.99' )+" %"+CRLF
	cTexto += 'Desc. Maximo : '+Transform(nAlcDesc,'@E 99.99' )+" %"                    +CRLF
	cTexto += Space(5)                                                                         +CRLF
	cTexto += 'Cliente  : '+M->UA_CLIENTE+'/'+M->UA_LOJA+' - '+SA1->A1_NOME                      +CRLF
	cTexto += 'Cidade   : '+SA1->A1_MUN +'  UF: '+SA1->A1_EST                           +CRLF
	cTexto += Space(5)                                                                         +CRLF
	cTexto += 'Cond. Pag.: ' + SE4->E4_DESCRI                                                    +CRLF
	cTexto += Space(5)                                                                         +CRLF
	cTexto += 'Item Produto         Descrição                                              Valor    Margem  Desc.Real  Situacao '+CRLF
	cTexto += '------------------------------------------------------------------------------------------------------------------'+CRLF
//cTexto += 'xxxx xxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 999,999,999.99 9,999.99%  9,999.99%  Reprovado!

	nTotMerc := 0
	For ix := 1 To Len ( aResult )

		cTexto += aResult[ ix, 01]+Space(3)+aResult[ix,02]+" "+aResult[ix,7]+Space(1)+;
			Transform( aResult[ix,03],'@E 999,999,999.99')+;
			Space(1)+Transform( aResult[ix,04],'@E 9,999.99')+"%"+;
			Space(2)+Transform( aResult[ix,06],'@E 9,999.99')+"%"+;
			Space(2)+If(aResult[ix,05],'Ok','Bloqueado!')+CRLF
		nTotMerc += aResult[ix,03]

	Next ix
	cTexto += '------------------------------------------------------------------------------------------------------------------'+CRLF
	cTexto += 'Total das Mercadorias                                              '+Transform(nTotMerc,'@E 999,999,999.99')+CRLF

// pega o nome do arquivo para ir como anexo
	cArq := "\"+SUA->UA_NUMSC5
	ix := 1
	While File(cArq)
		cArq := "\"+SUA->UA_NUMSC5+"_"+Soma1(Str(ix,1))
		ix++
	End
	cArq+=".txt"

// grava  o arquivo para anexa-lo e envia o e-mail
	IF MEMOWRIT(cArq,cTexto)

	// Posiciona cadastro de vendedores no vendedor superior
		SA3->( dbSetOrder(1) )
		SA3->( dbSeek( xFilial('SA3')+cSuperior ) )

	// Redefine variavel cTexto para corpo do e-mail
		cTexto := "Sr(a) "+SA3->A3_NOME
		cTexto += CRLF
		cTexto += CRLF
		cTexto += "O sistema Advanced Protheus comunica a inserção de um pedido de venda reprovado pela avaliação comercial automática. "
		cTexto += "Favor proceder a avaliação comercial manual deste pedido de venda."+CRLF
		cTexto += "Segue arquivo anexo contendo os dados do pedido." + CRLF

	//Conexao com o servidor SMTP
		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult
	// fazendo autenticacao
		If lResult .And. lAuth
			lResult := MailAuth(cAccount,cPassword)
			If !lResult
				lResult := QADGetMail() // Funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
			EndIf
			If !lResult
			//Erro na conexao com o SMTP Server
				GET MAIL ERROR cError
				If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
					u_Mensagem("Erro de Autenticacao no envio de e-mail de avaliação comercial: "+cError)
				Else
					ConOut("Erro de Autenticacao no envio de e-mail de avaliação comercial: "+cError)
				Endif
			// apaga o arquivo anexado
				FERASE(cArq)
				RestArea(aAreaSA3)
				RestArea(aArea)
				Return Nil
			Endif
		Else
			If !lResult
			//Erro na conexao com o SMTP Server
				GET MAIL ERROR cError
				If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
					u_Mensagem("Erro de Conexao no envio de e-mail de avaliação comercial: "+cError)
				Else
					ConOut("Erro de Conexao no envio de e-mail de avaliação comercial: "+cError)
				Endif
			// apaga o arquivo anexado
				FERASE(cArq)
				RestArea(aAreaSA3)
				RestArea(aArea)
				Return Nil
			Endif
		EndIf

	//Envio do Email
		SEND MAIL FROM cAccount to alltrim(SA3->A3_EMAIL)  SUBJECT Oemtoansi("Venda bloqueada pela avaliação comercial automática") BODY cTexto ATTACHMENT cArq RESULT lResult
		If !lResult
		//Erro no envio do email
			GET MAIL ERROR cError
			If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
				u_Mensagem("Erro no envio do e-mail de avaliação comercial: "+cError)
			Else
				ConOut("Erro no envio do e-mail de avaliação comercial: "+cError)
			Endif
		EndIf
		DISCONNECT SMTP SERVER

	// apaga o arquivo anexado
		FERASE(cArq)

	Else
		If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
			u_Mensagem('Erro ao gravar arquivo '+cArq+' para envio de e-mail sobre avaliação comercial.')
		Else
			ConOut('Erro ao gravar arquivo '+cArq+' para envio de e-mail sobre avaliação comercial.')
		Endif
	Endif

	RestArea(aAreaSA3)
	RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³U_DESICMPAD º Autor ³Expedito Mendonca Jrº Data ³  21/10/03 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o desconto de ICM padrao da venda                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*********************************************************************
User Function DesIcmPad(cDestino )
*********************************************************************
	Local aArea     := GetArea()
	Local aAreaSA1  := SA1->( GetArea() )
	Local nRecnoSA1 := SA1->( RECNO())
	Local cImdepa   := GetMv('MV_IMDEPA') //CODIGO DA IMDEPA NO CADASTRO DE CLIENTES (SA1) E DE FORNECEDORES (SA2), PARA FINS DE TRANSFERENCIA ENTRE FILIAIS.
	Local cOrigem

	Public cUFOri := " "

//cFilAnt -> variavel publica do sistema,	Número da Filial que está em uso no momento.

// recupero a UF de origem
	dbSelectArea('SA1');dbSetOrder(1)
	dbSeek(xFilial('SA1')+cImdepa+cFilAnt)
	cOrigem := SA1->A1_EST

// determino o percentual de desconto de ICMS padrao na tabela DESCONTO DE ICMS
	dbSelectArea('SZW');dbSetOrder(1)
	If dbSeek(xFilial('SZW') + cOrigem + cDestino)


///JULIO JACOVENKO....
///21/12/2012 - PARA AJUSTAR DESCONTO ICM
		LIMP:=.F.
		CPRODUTO:=SB1->B1_COD
		cIMPNAC:=SA1->(POSICIONE('SB1',1,XFILIAL('SB1')+CPRODUTO,'B1_ORIGEM'))
		LIMP:=(CIMPNAC='1' .OR. CIMPNAC='2')

		if !LIMP //e nacional
			nDescIcmPad	:= SZW->ZW_DESCONT
		else     //e importado
			nDescIcmPad	:= SZW->ZW_DESCIMP
		endif


		nDescComExp := SZW->ZW_DESCEXP
	Else
		If Type("l410Auto") != "U" .And. !l410Auto
			u_Mensagem("O desconto de ICMS padrão para vendas com origem em "+cOrigem+" e destino "+cDestino+" não está cadastrado.")
			Final("Erro ao gravar pedido de venda.")

			ConOut("O desconto de ICMS padrão para vendas com origem em "+cOrigem+" e destino "+cDestino+" não está cadastrado.")
			ConOut("Erro ao gravar pedido de venda.")
		EndIf
		nDescIcmPad	:= 0
		nDescComExp := 0
	EndIf

//³ Armazena o estado de origem para calc da margem³
	cUFOri := cOrigem

	RestArea(aAreaSA1)
	DBGOTO(nRecnoSA1)
	RestArea(aArea)

//Return()

/*---------------------------------------------------------------------------------------------------------------------------
| A funcao retorna o Desconto de ICMS Padrao p/ uso em outras rotinas - Inserido por Edivaldo Goncalves Cordeiro em 30/11/11 |
 ----------------------------------------------------------------------------------------------------------------------------
*/

Return(nDescIcmPad)

*********************************************************************
Static Function Testetmkok()
*********************************************************************
// projeto f11,
// não cancela mais pelo botão COPIA --> NÃO CANCELA ORÇAMENTO ORIGINAL QUANDO FOR ORÇAMENTO, COMENTADO ESTA ROTINA

// Libera a saida da tela
	__Podesair  := "S"

// Flag para identificar que o proximo atendimento ainda nao tera clicado no botao
// de condicao de pagamento
	__lJaBotCPag := .F.

// Zera o array com flag indicando itens em que o usuario ja digitou a quantidade,
// liberando a digitacao para o proximo atendimento
	__aItDigQtd  := {}

// Ate qual linha do aCols o sistema deve permitir a delecao de itens do aCols
	__nLibDel := 0

// Indica que no proximo atendimento, ao se passar pelo campo UA_TABELA, a validacao
// deve atualizar os precos dos itens do atendimento
	__cTabAtu	:= ""

// Exibe mensagens
	If !Empty(__cMensagem)
		If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
			IW_MsgBox(__cMensagem, 'Atenção', 'STOP')
		Else
			ConOut(__cMensagem)
		Endif
	Endif
	__cMensagem := NIL


//Projeto Abaulados
	If Len(aAbaulSimi)>0
		U_IMDA702(aAbaulSimi)
		aAbaulSimi:={}
	Endif


// Faz chamada ao programa de envio de e-mail
	If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
	//MsAguarde({||SF4->(U_EmailHtml(M->UA_NUM,M->UA_CLIENTE,M->UA_LOJA,xFilial("SUA"),SUA->UA_NUMSC5,M->UA_OPER,ALLTRIM(M->UA_OCCLI),M->UA_TPFRETE,ALLTRIM(M->UA_DESCNT),M->UA_CODCONT,lTk271Auto))},"E-mail Vendas","Publicando e-mail...")
		MsAguarde({||SF4->(U_IMDA800(M->UA_NUM,M->UA_CLIENTE,M->UA_LOJA,xFilial("SUA"),SUA->UA_NUMSC5,M->UA_OPER,ALLTRIM(M->UA_OCCLI),M->UA_TPFRETE,ALLTRIM(M->UA_DESCNT),M->UA_CODCONT,lTk271Auto))},"E-mail Vendas","Enviando...")
	Else
		ConOut("Iniciando chamada do EmailHtml PARA VENDAS MAIL")
		SF4->(U_EmailHtml(M->UA_NUM,M->UA_CLIENTE,M->UA_LOJA,xFilial("SUA"),SUA->UA_NUMSC5,M->UA_OPER,ALLTRIM(M->UA_OCCLI),M->UA_TPFRETE,ALLTRIM(M->UA_DESCNT),M->UA_CODCONT,lTk271Auto))

	//Inicio teste Edi
		If SUA->UA_OPERADO='0445'//Pedido Vendas Mail
			SF4->(U_EmailVmail(M->UA_NUM,M->UA_CLIENTE,M->UA_LOJA,xFilial("SUA"),SUA->UA_NUMSC5,M->UA_OPER,ALLTRIM(M->UA_OCCLI),M->UA_TPFRETE,ALLTRIM(M->UA_DESCNT),M->UA_CODCONT,lTk271Auto))
		Endif

	//Fim teste Edi
	Endif
// mostra o system tracker do pedido no caso de faturamento
	If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
		If M->UA_OPER == "1" .and. MsgYesNo('Visualiza System Tracker do Pedido!')
			U_IMDF080()
		EndIf
	Endif

Return
*********************************************************************
Static Function RetStruct( _Alias_ )
*********************************************************************

	Local aArea   := GetArea()
	Local aStruc  := Array(0)

	dbselectArea('SX3')
	dbSetOrder(1)
	dbSeek( _Alias_ )
	Do While !Eof() .and. X3_ARQUIVO = _Alias_
		If X3Uso(X3_USADO) .and. cNivel >= X3_NIVEL .and. X3_PROPRI = 'U' .and. X3_CONTEXT != "V"
			Aadd(aStruc, {X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL})
		EndIf
		dbselectArea('SX3')
		dbSkip()
	EndDo

	RestArea(aArea)

Return(aStruc)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fVeCodCliºAutor  ³Julio Jacovenko      º Data ³  10/14/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao auxiliar para ajustar codigo de cliente             º±±
±±º          ³ quando prospect para cliente                               º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//fVeCodCli(cCodcli,cLojCli,cNumSC5,cNumFil)

Static Function fVeCodCli(cCodcli,cLojCli,cNumSC5,cNumFil)
	_aArea:=GetArea()

	DbSelectArea("SA1")
	If DbSeek(XFILIAL("SA1")+cCodCli+cLojCli)
		If SA1->A1_STATUS=='X'     ///PROSPECT PARA CLIENTE, TENHO QUE FAZER AS VERIFICACOES
			cCgcCli:=SA1->A1_CGC
			fGravaPro(cCgcCli, cCodCli, cLojCli, cNumSC5, cNumFil)
		EndIf
	Endif


	RestArea(_aArea)
Return NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGravaProºAutor  ³Julio Jacovenko      º Data ³  10/14/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Codigo principal para ajustar o codigo do cliente           º±±
±±º          ³para quando for Prospect para Cliente, para pegar o mesmo   º±±
±±º          ³codigo do cliente quado existir os 11 primeiros digitos     º±±
±±º          ³do CGC                                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

      //fGravaPro(cCgcCli, cCodCli, cLojCli, cNumSC5, cNumFil)


Static Function fGravaPro(cCgcCli, cCodCli, cLojCli, cNumSC5, cNumFil)
///cCodcli e cLojCli é codigo e loja que o sistema gerou no
///inicio

///cNumSC5 e cNumFil, são o numero do Pedido Gerado....
	Local _cArea:=GetArea()



	cCGC:=cCgcCli
	cCGCF:=SUBSTR(cCGC,1,08)  //SUBSTR(cCGC,1,11)
	lAchouC:=.F.
	lAchouF:=.F.
	lGrava :=.F.
	cCODANT:=''
	cCGCANT:=''



	cQUERY:=""
	cQUERY+="SELECT * FROM "+RetSqlName('SA1')+" "
//cQUERY+="WHERE SUBSTR(A1_CGC,1,11)='"+cCGCF+"' "
	cQUERY+="WHERE SUBSTR(A1_CGC,1,08)='"+cCGCF+"' "
	cQUERY+="ORDER BY A1_CGC "

	cQUERY := ChangeQuery( cQUERY )

	If( Select("QRY_DB") <> 0 ) // Se a area a ser utilizada estiver em uso, fecho a mesma
		QRY_DB->( dbCloseArea() )
	EndIf

	MEMOWRIT( "C:\SQLSIGA\JKTESTE1.SQL", cQUERY )

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQUERY),"QRY_DB",.F.,.T.)

	DBSELECTAREA("QRY_DB")
	QRY_DB->(DBGOTOP())

	lOK    :=.F.
	cCODANT:=QRY_DB->A1_COD
	cLOJANT:=QRY_DB->A1_LOJA
	cCODATU:=QRY_DB->A1_COD
	cLOJATU:=QRY_DB->A1_LOJA
	nREC   :=QRY_DB->R_E_C_N_O_

	WHILE !EOF() .AND. cCGCF==SUBSTR(QRY_DB->A1_CGC,1,08)   //SUBSTR(QRY_DB->A1_CGC,1,11)
		IF cCGC<>QRY_DB->A1_CGC
			cCODANT:=QRY_DB->A1_COD
			nREC   :=QRY_DB->R_E_C_N_O_
			LGRAVA :=.T.
			exit
		ENDIF
		QRY_DB->(DBSKIP())
	ENDDO

	DBCLOSEAREA("QRY_DB")

///////////////////////////////////////////////////////////////////
// SE lGrava=.T. ajusta o SA1
///////////////////////////////////////////////////////////////////
	IF lGrava


		BEGIN TRANSACTION   //QUALQUER ERRO, NAO FAZ NADA, DEIXANDO
                    //OR REGISTRO DEFAULT DO SISTEMA

			DBSELECTAREA("SA1")
			DBSETORDER(3) //CGC
			IF DBSEEK(XFILIAL("SA1")+cCGCCLI)
				IF RECLOCK("SA1",.F.)
					SA1->A1_COD   :=cCODANT
					SA1->A1_LOJA  :=SA1->(POSICIONE("SUS",4,XFILIAL("SUS")+cCGCCLI, "US_LOJA"))  ///BUSCAR PELO CGC
					SA1->A1_STATUS:=''
					MSUNLOCK()
				ENDIF
			ENDIF

			///////////////Agora Ajusta o SUS o campo US_CLIENTE
			//DBSelectArea("SUS")
			//busca pro CGC
			DBSELECTAREA("SUS")
			DBSETORDER(4)
			IF DBSEEK(XFILIAL("SUS")+cCGCCLI)
				IF RECLOCK("SUS",.F.)
					SUS->US_CODCLI :=cCODANT
					SUS->US_LOJACLI:=SUS->US_LOJA
					MSUNLOCK()
				ENDIF
			ENDIF

////////AGORA QUE AJUSTOU CLIENTE E PROSPECT, TEMOS DE AJUSTAR
////////SC5,SC6,SC9 e SUA
////////FAZER TESTE COM EDIVALDO PARA VERIFICAR SE
////////SAO SOMENTE ESTES ARQUIVOS

			IF ALLTRIM(cNumSC5)<>'' ///SOMENTE SE HOUVER SC5
   /////Vou buscar o pedido, pegando o RECNO e Numero do SUA
   /////
				cQUERY:=''
				cQUERY+="SELECT SC5.R_E_C_N_O_ AS nRec, SC5.C5_NUMSUA AS cNSUA FROM "+RetSqlName('SC5')+" SC5 "
				cQUERY+="WHERE SC5.C5_NUM='"+cNumSC5+"' AND SC5.C5_FILIAL='"+cNumFIL+"' "

				cQUERY := ChangeQuery( cQUERY )

				If( Select("QRY_001") <> 0 ) // Se a area a ser utilizada estiver em uso, fecho a mesma
					QRY_001->( dbCloseArea() )
				EndIf

				MEMOWRIT( "C:\SQLSIGA\QRY001.SQL", cQUERY )

				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQUERY),"QRY_001",.F.,.T.)
				_nREC:=QRY_001->nREC
				_cNSUA:=QRY_001->cNSUA

				dBCloseArea("QRY_001")
   /////AGORA COMECA OS UPDATES NAS TABELAS
   /////COMECA PELO SC5

   //ALERT("VAI ALTERAR O SC5 N. "+cNumSC5+" Cli: "+cCODANT)
				cSql :=" UPDATE "+RetSqlName('SC5')
				cSql +=" SET "
				cSql +=" C5_CLIENTE = '"+cCODANT+"', "
				cSql +=" C5_LOJACLI = '"+SUS->US_LOJA+"', "
				cSql +=" C5_CLIENT  = '"+cCODANT+"'
				cSql +=" WHERE "
				cSql +=" R_E_C_N_O_= "+STR(_nRec)

				NRET:=	TCSQLExec( cSql )


				If nRet == 0
		    //MsgAlert("Inseriu","Alerta")
				Else
					cRet = TCSQLERROR()
					MsgAlert(cRet,"Alerta")
				EndIf

				TCSQLExec('COMMIT')

  //////AGORA VAI PARA O SC6

  //ALERT("VAI ALTERA O SC6 N."+cNUMSC5+" CLI: "+cCODANT)
				cSql1 :=" UPDATE "+RetSqlName('SC6')
				cSql1 +=" SET "
				cSql1 +=" C6_CLI       = '"+cCODANT+"', "
				cSql1 +=" C6_LOJA       = '"+SUS->US_LOJA+"' "
				cSql1 +=" WHERE "
				cSql1 +=" C6_NUM        = '"+cNumSC5+"'
				cSql1 +=" AND C6_FILIAL = '"+cNumFIL+"' "

				NRET:=TCSQLExec( cSql1 )


				If nRet == 0
		    //TCRefresh("ZAA990")
		    //MsgAlert("Inseriu","Alerta")
				Else
					cRet = TCSQLERROR()
					MsgAlert(cRet,"Alerta")
				EndIf
				TCSQLExec('COMMIT')


  //////TROCA NO SC9 SE HOUVER

  //ALERT("VAI ALTERAR O SC9..SE HOUVER..")
				cSql2 :=" UPDATE "+RetSqlName('SC9')
				cSql2 +=" SET "
				cSql2 +=" C9_CLIENTE   = '"+cCODANT+"', "
				cSql2 +=" C9_LOJA      = '"+SUS->US_LOJA+"' "
				cSql2 +=" WHERE "
				cSql2 +=" C9_PEDIDO    = '"+cNumSC5+"'
				cSql2 +=" AND C9_FILIAL= '"+cNumFIL+"' "

				NRET:=TCSQLExec( cSql2 )

				If nRet == 0
			    //MsgAlert("Inseriu","Alerta")
				Else
					cRet = TCSQLERROR()
					MsgAlert(cRet,"Alerta")
				EndIf


				TCSQLExec('COMMIT')


 //////E POR ULTIMO SUA
 //ALERT("VAI ALTERAR O SUA...")
				cSql3 :=" UPDATE "+RetSqlName('SUA')
				cSql3 +=" SET "
				cSql3 +=" UA_CLIENTE   = '"+cCODANT+"', "
				cSql3 +=" UA_LOJA      = '"+SUS->US_LOJA+"' "
				cSql3 +=" WHERE "
				cSql3 +=" UA_NUMSC5    = '"+cNumSC5+"'
				cSql3 +=" AND UA_FILIAL= '"+cNumFIL+"' "

				NRET:=TCSQLExec( cSql3 )

				If nRet == 0
		    //MsgAlert("Inseriu","Alerta")
				Else
					cRet = TCSQLERROR()
					MsgAlert(cRet,"Alerta")
		    /*
		    Do While !Empty(cRet)
		      MsgAlert(cRet,"Alerta")
		      cRet = TCSQLERROR()
		    EndDo
		    */
				EndIf

				TCSQLExec('COMMIT')


			ENDIF


		END TRANSACTION


	ELSE		 ////SE FOR NOVO, AJUSTA SOMENTE O A1_STATUS PARA BRANCO
		DBSELECTAREA("SA1")
		DBSETORDER(3) //CGC
		IF DBSEEK(XFILIAL("SA1")+cCGCCLI)
			IF RECLOCK("SA1",.F.)
				SA1->A1_STATUS:=''
				MSUNLOCK()
			ENDIF
		ENDIF
	ENDIF


/////////////////////////////////////////////////////////////////////////////
	RestArea(_aArea)

RETURN NIL


