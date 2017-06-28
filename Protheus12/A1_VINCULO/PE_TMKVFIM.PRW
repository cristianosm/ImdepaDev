#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "IMDEPA.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE X_PARCELA		"123456789ABCDEFGHIJKLMNOPQ"
#DEFINE CRLF 			( chr(13)+chr(10) )
#DEFINE X_PRODUTO		aScan(aHeader, {|x| AllTrim(x[2])=='UB_PRODUTO'})
#DEFINE X_QTD			aScan(aHeader, {|x| AllTrim(x[2])=='UB_QUANT'})
#DEFINE X_ZE_NUMPLAN	12
#DEFINE X_ZE_ITEM		13
#DEFINE X_ZE_PVITEM		14

#DEFINE  ENTER CHR(13)+CHR(10)

//ajustado 04/09/2014
//testes com mauricio
//

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³U_Tmkvfim() ³ Autor ³Microsiga/MQB        ³ Data ³ 22/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gravacao do arquivos de pedido de vendas                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ESPECIFICO PARA O CLIENTE IMDEPA						      ³±±
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
Local _aArea := GetArea()
Local aAreaSA1 := SA1->(GetArea())
Local nRecSA1  := SA1->(Recno())
Local cOld_F10 := SetKey(VK_F10)

cTpOperAT := IIF(SUA->UA_OPER == '1', 'Faturamento', IIF(SUA->UA_OPER == '2','Orcamento','Atendimento'))


oProcess := MsNewProcess():New({|lEnd| ExecGravaAT(@oProcess, @lEnd) },"Gravando "+cTpOperAT,"Processando... Aguarde",.F.)
oProcess:Activate()


RestArea( _aArea )
RestArea( aAreaSA1 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificacao se Registro do SA1 do ultimo pedido ficou³
//³ TRAVADO por alguma rotina por este usuario.          ³
//³ DESTRAVA sempre                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SA1")
dbGoTo( nRecSA1 )
If !SA1->(SimpleLock())
	SA1->(MsRUnlock(nRecSA1))
	/*
	Aviso(	"Registro Travado",;
	"Cliente " + SA1->A1_COD + "-" + SA1->A1_LOJA + " - " + AllTrim(SA1->A1_NOME) + Chr(13) + Chr(10) + "",;
	{"OK"})
	*/
Else
	SA1->(MsRUnlock(nRecSA1))
	/*
	Aviso(	"Registro DesTravado",;
	"Cliente " + SA1->A1_COD + "-" + SA1->A1_LOJA + " - " + AllTrim(SA1->A1_NOME) + Chr(13) + Chr(10) + "",;
	{"OK"})
	*/
EndIf

SetKey(VK_F10, cOld_F10)
Return(.T.)
*************************************************************************
Static Function ExecGravaAT(oProcess, lEnd, cTpOperAT)
*************************************************************************
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
//alterado em 10/02/2015 em função de que as regras de acrescimo e desconto forma descontinuadas - Rodrigo Carvalho - Solutio
//Local nPrBaseDesc,nDifIcmUnit,nPrcMin
Local nDifIcmUnit,nPrcMin
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
Local cTpEstFis
Local lRedesp    := .F.

//removido em 10/02/2015 em função de que o processo carta negocio foi descontinuado - Rodrigo Carvalho - Solutio
/*
// Jorge Oliveira - 28/02/2011 - Indica se a Filial atual, trabalha com as Liberacao Comercial utilizando Carta de Negocio
Local lCartLib   := IIF( Upper( SuperGetMV( "MV_CARTLIB",, "N" ) ) == "S", .T., .F. )
Local aCarta     := {}
Local aProdCarta := {}
Local aAreaAtu   := {}
Local nAcreMva   := 0 //Acréscimo MVA
Local cEstATU    :=  GETMV("MV_ESTADO")
*/

Private lMsHelpAuto := .T. // se .T. direciona as mensagens de help para o arq. de log
Private lMsErroAuto := .F. //necessario a criacao, pois sera atualizado quando houver alguma incosistencia nos parametros
Private __cNumOrig
Private aStrucSC5   := RetStruct('SC5')
Private aStrucSC6   := RetStruct('SC6')

Private cCustoNF  := GetMV("MV_CUSTONF",," ")
Private lEstOner  := dDatabase >= GetMV("MV_ESTONER",,dDatabase+1)

Private aLogComiss:={}
//	Private nDescIcmPad := 0		//	RODRIGO SOLUTIO
//	Private nDescComExp := 0		//	RODRIGO SOLUTIO
//	Private nAcrComExp  := 0		//	RODRIGO SOLUTIO

Private cVend_1
Private NIcm_PIS

////////////////////////////////////////////////CRIADO PELO JULIO JACOVENKO em 14/10/2011
////////////////////////////////////////////////PARA GRAVAR O CODIGO DO CLIENTE CORRETO QUANDO
////////////////////////////////////////////////TRANSFORMA PROSPECT PARA CLIENTES
///////////////////////////////////////////////////////////////////////////
Private cCodCli:=''
Private cLojCli:=''


///////////////////////////////////////////////////////////////
////JULIO JACOVENKO, em 13/08/2014
////projeto frete 1.3
Private nValFrtA:=0

// FABIANO PEREIRA - SOLUTIO
Private lOperFat 	:= (SUA->UA_OPER == '1')	// 1=Faturamento;2=Orcamento;3=Atendimento
//Private aRetZRD	:=	{}
Private aRetZRN	 	:=	{}
Private aComplRD 	:=	{}
Private nE4Acresc	:=	Posicione('SE4',1,xFilial('SE4')+SUA->UA_CONDPG,'E4_ACRSFIN')
Private aPTransf	:=	{}  
Private lTemGuia    :=.F.


// Jean Rehermann - Solutio IT - 19/11/2015 - Variáveis transformadas em private para uso em outros programas (referência ao acols e aheader)
Private __aCols := 	Array(0)
Private __aHead := 	Array(0)
Private cNumSC5	:=	Space(TamSx3('C5_NUM')[01])
Private cNumFIL	:=	Space(TamSx3('C5_FILIAL')[01])

IIF( !ExisteSX6('MV_FILFRT'),	CriarSX6('MV_FILFRT', 'C','Parametro utilizado no fonte PE_TMKVFIM,PRW' ,'') , )

oProcess:SetRegua1(Len(aCols))

DbSelectArea("SU7")
DbSetOrder(4) //U7_FILIAL+U7_CODUSU
DbSeek(xFilial("SU7")+SU7->(RetCodUsr()))

cVend_1    := SU7->U7_CODVEN
cOperAtivo := SU7->U7_COD

__cMensagem := ""
cDescComis  := IIF(EMPTY(cDescComis),"N",cDescComis)
cAcreComis  := IIF(EMPTY(cAcreComis),"N",cAcreComis)

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



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Autor: Cristiano Machado    Data: 02/07/2014                    	³
//³  Atualiza Cliente no Consultado (ZA0) Caso Tenha Sido alterado...  	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*****************************************************
oProcess:IncRegua1('Verificando Cliente...')
CLI_Atualiza()
*****************************************************


//Robson Salvieri - 14/10/2014
//Atualiza o controle de reservas
//U_IMDA104B()
__aCCols 	:= aClone(Acols) /// Atualiza o __CopaCols Publico para utilizado na emissão do orcamento...


// FABIANO PEREIRA - SOLUTIO
// COMENTADO TRECHO... NO FINAL DO FONTE Testetmkok Eh CHAMADO
/*
If M->UA_OPER <> "1"	// nao eh faturamento
//Inserido por Edivaldo Gonçalves Cordeiro  Tela de Processo e Tratamento para o Palm em 01/09/06
If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
MsAguarde({||SF4->(Testetmkok()) },"Verificando atendimento","Verificando se atendimento é cópia ...")
Else
SF4->(Testetmkok())   //<- testa e Cancela o atendimento anterior automaticamente
Endif

Return NIL

Endif
*/

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
dbSelectArea("DC8");dbSetOrder(4)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionando Clientes					     ³

//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->(DbSeek(xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA))

//removido o processo de comissões por operador em 09/02/2015 conforme solicitação do edvaldo - Rodrigo Carvalho - Solutio
//If SA1->A1_GERVEN='000685' //----------------- Projeto Comissões por Operador(Pedido do Call Center)
//	aVendedores := { {cVend_1},{SA1->A1_VEND},{SA1->A1_VENDCOO},{SA1->A1_CHEFVEN},{SA1->A1_GERVEN} }
//Else
aVendedores := { {SA1->A1_VENDEXT},{SA1->A1_VEND},{SA1->A1_VENDCOO},{SA1->A1_CHEFVEN},{SA1->A1_GERVEN} }
//Endif


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

//Removido em 10/02/2015 em função de que as regras de desconto e acrescimo foram descontinuadas
//³Define o desconto de ICMS padrao                     ³
//SF4->(U_DesICMPad(SA1->A1_EST))


//³Cancela o atendimento anterior automaticamente             ³
// PROJETO F11,
// não cancela mais o atendimento original, nem no orçamento nem no faturamento
//Procura nos pedidos de venda

//	FABIANO PEREIRA - SOLUTIO
If lOperFat
	
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
	
EndIf


RecLock("SUA",.F.)

	//	FABIANO PEREIRA - SOLUTIO
	//	GRAVA DESCONTO GERAL QUE USUARIO CONCEDEU.
	//  UTILIZADO NO CASOS ONDE O USUARIO QUER SABER QUANTO DE DESCONTO GERAL FOI DADO. EX.: VIA HISTORICO
	If SUA->(FieldPos('UA_DESC_CC')) > 0
		SUA->UA_DESC_CC := SUA->UA_DESCG
	EndIf
	
	If  SUA->UA_OPERAD2 <> cOperAtivo  .AND. SUA->UA_OPERADO <> cOperAtivo  //Mudou o operador
		SUA->UA_OPERAD2 := cOperAtivo
	Endif
	
	//removido o processo de comissões por operador em 09/02/2015 conforme solicitação do edvaldo - Rodrigo Carvalho - Solutio
	/*
	If SA1->A1_GERVEN='000685' //----------------- Projeto Comissões por Operador(Pedido do Call Center)
	SUA->UA_VEND := cVend_1
	EndIf
	*/
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  AJUSTA UA_JUROS == E4_ACRSFIN            ³
	//³  OCORRENCIA ONDE UA_JUROS GRAVOU ERRADO   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If SUA->UA_JUROS != nE4Acresc
		SUA->UA_JUROS := nE4Acresc
	EndIf
SUA->(MsUnlock())


//	FABIANO PEREIRA - SOLUTIO
If lOperFat
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
	
	//	FABIANO PEREIRA - SOLUTIO
	SC5->C5_DESC1	:=	SUA->UA_DESC1		//	DESCONTO CAD.CLIENTE
	// SC5->C5_DESCG:=	SUA->UA_DESCG		//	DESCONTO GERAL (USUARIO ALTERA NA MAO)
	SC5->C5_DESC4	:=	SUA->UA_DESC4		//	DESCONTO DA REGRA DE DESCONTO
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  AJUSTA E4_ACRSFIN == E4_ACRSFIN          ³
	//³  OCORRENCIA ONDE E4_ACRSFIN GRAVOU ERRADO ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SC5->C5_ACRSFIN != nE4Acresc
		SC5->C5_ACRSFIN := nE4Acresc
	EndIf
	
/*
	If	SC5->C5_BLQ = '1' .And. Empty(SC5->C5_LIBRNV1)		
		SC5->C5_LIBRNV1 :=	'B'
		SC5->C5_LIBRNV2 :=	'B'
		SC5->C5_LIBRNV3 :=	'L'
	EndIf
*/	
	MsUnlock()
	
EndIf

// Jorge Oliveira - 28/02/2011 - Filial atual trabalha com as Liberacao Comercial utilizando Carta de Negocio
//removido em 10/02/2015 em função de que o processo carta negocio foi descontinuado - Rodrigo Carvalho - Solutio
/*
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
AADD( aCarta, SA1->A1_VINCIMD    ) // 20 - POS_VINCULO_CLIENTE
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
*/


//³Altera os itens do pedido de vendas							 ³
nItemSUB	:= 1

SUB->(dbSeek(xFilial("SUB")+M->UA_NUM))
Do While SUB->UB_FILIAL+SUB->UB_NUM == xFilial("SUB")+M->UA_NUM .and. SUB->(!Eof())
	
	oProcess:IncRegua1("Processando Item "+AllTrim(Str(nItemSUB))+" de "+AllTrim(Str(Len(aCols))) )
	oProcess:SetRegua2(17)
	
	//	FABIANO PEREIRA - SOLUTIO
	If lOperFat
		//³Posicionando Pedidos    ³
		//	SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM+SUB->UB_ITEM+SUB->UB_PRODUTO,.F.))
		SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM+SUB->UB_ITEM+SUB->UB_PRODUTO,.F.))
	EndIf
	
	
	//³Posicionando de TES	         			     ³
	SF4->(dbSeek(xFilial("SF4")+SUB->UB_TES))
	 If SF4->F4_CODIGO $ "750/753/754/762"   
        lTemGuia:=.T.
      Endif  
	
	
	//Inserido por Edivaldo Gonçalves Cordeiro em 21/10/06                                    //
	//Verifica se o produto em movimentação está habilitado o apanhe/separação pelo WMS       //
	
	IF  ( TYPE("lTk271Auto") = "U" .OR. !lTk271Auto )
		// MsAguarde({|| lRetWMS:=SF4->(U_checkWMS(SUB->UB_PRODUTO)) },"WMS","Verificando se o item possui controle de localização...")
		oProcess:IncRegua2("WMS - Verificando se o item possui controle de localização...")
		lRetWMS := SF4->(U_checkWMS(SUB->UB_PRODUTO))
	ELSE
		lRetWMS:=SF4->(U_checkWMS(SUB->UB_PRODUTO))
	Endif
	
	//FABIANO PEREIRA - SOLUTIO - 13/02/2015 - participação Rodrigo Carvalho Solutio
	Reclock('SUB', .F.)
	
	SUB->UB_PRCTAB2	:=	SUB->UB_PRCTAB			//	Prc.Tab.Dia At
	SUB->UB_PREC_CC	:=	SUB->UB_VRUNIT			//	Preco Atend
	SUB->UB_DESC_CC	:=	Round(SUB->UB_DESCVEN,TamSx3('UB_DESCVEN')[02])			//	% Desconto Concedido
	SUB->UB_ACRE_CC	:=	Round(SUB->UB_ACRE2   ,TamSx3('UB_ACRE2')[02]) 			//	% Acrescimo Concedido
	
	MsUnlock()
	
	//	FABIANO PEREIRA - SOLUTIO
	If lOperFat
		
		//lLock := SC6->(Reclock("SC6",.F.))
		DBSELECTAREA("SC6")
		Reclock("SC6",.F.)
		
		//³Verifica se eh preco fiscal bruto                    ³
		
		// Preço com Acrescimo)
		//removido em 09/02/2015 em função de que as regras de desconto e acrescimo foram descontinuadas - Rodrigo carvalho - Solutio
		//SC6->C6_PRCACRE := SUB->UB_VRCACRE
		//ativado novamente em 06/07/2015 para alimentar o campo no SC6
		SC6->C6_PRCACRE := SUB->UB_VRCACRE
		
		If lRetWMS
			//SC6->C6_ENDPAD:=SF4->(Posicione("SBE",6,xFilial("SBE") +'000007'+'01',"BE_LOCALIZ"))
			//SC6->C6_TPESTR:=SF4->(Posicione("DC8",3,xFilial("DC8") +'5',"DC8_CODEST"))
			//SC6->C6_SERVIC:=SF4->(Posicione("DC5",2,xFilial("DC5") +'002',"DC5_SERVIC"))
			If DC8->(dbSeek(xFilial('DC8')+'5'+SC6->C6_LOCAL, .F.))
				cTpEstFis      := DC8->DC8_CODEST
				SC6->C6_ENDPAD := SBE->(Posicione("SBE",1,xFilial("SBE") +SC6->C6_LOCAL+'DOCA',"BE_LOCALIZ"))
				SC6->C6_SERVIC := DC5->(Posicione("DC5",2,xFilial("DC5") +'002',"DC5_SERVIC"))
				//				SC6->C6_TPESTR := cTpEstFis
			EndIf
		EndIf
		
		MsUnlock()
		
	EndIf
	
	/*
	IF lLock
	SC6->(MsUnlock())
	ENDIF
	*/
	
	
	//-----> Carrega variaveis
	
	cProduto 	:= SUB->UB_PRODUTO
	cLocal	 	:= SUB->UB_LOCAL
	nVlrItem 	:= SUB->UB_VRCACRE  //SD2->D2_PRCVEN
	//	nBASEICM 	:= SUB->UB_BASEICM alterado por rodrigo solutio em 29/05/2015 para
	nBASEICM 	:=	NoRound((SUB->UB_VLRITEM   + nValDesp + nAcreCon + nValFrtA),2)
	nQtdItem 	:= SUB->UB_QUANT
	//removido em 10/02/2015 em função de que as regras de desconto e acrescimo foram descontinuadas
	//nDescIcm 	:= SUB->UB_DESCICM
	nFreteCal	:= SUA->UA_FRETE //SUA->UA_FRETCAL
	// Alterado em 	09/02/2015 em função de que as regras de desconto e acrescimo foram descontinuadas - Rodrigo Carvalho - Solutio
	//nValmerc 	:= SUA->UA_VALMERC + SUA->UA_ACRECND // VALOR COM ACRESCIMO (PS. NO UA_VALMERC NÃO ESTÁ CONTIDO O ACRESCIMO)
	nValmerc 	:= 	SUA->UA_VALMERC  // VALOR COM ACRESCIMO (PS. NO UA_VALMERC NÃO ESTÁ CONTIDO O ACRESCIMO)
	nDespesa	:= 	SUA->UA_DESPESA
	nIdade 		:= 	0
	NIDADESC6   := 	0
	
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
	
	//comentado para ser removido por solicitação do Edvaldo - Rodrigo Carvalho - Solutio 09/02/2015
	/*
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
	*/
	
	//	FABIANO PEREIRA - SOLUTIO. SE TIVER ALGUM ACRES\DESCONTO O PRW IMDG240E ALIMENTA OS CAMPOS PADROES DE ACRESC\DESC.
	// VERIFICAR NECESSIDADE... POIS A CADA ITEM JA Eh VERIFICAR E ALIMENTADO OS CAMPOS PADROES.
	// Verifica se o produto possui Desconto/Acréscimo por filial
	
	//removido em 09/02/2015 por que as regras de desconto e acrescimo por filial estão sendo descontinuadas - Rodrigo carvalho - Solutio
	// nDesAcreFil := SB1->(U_IMDG240E(.F.,SUB->UB_PRODUTO,.T.))
	
	
	//	FABIANO PEREIRA - SOLUTIO
	// ALTERADO PARA UB_PRCBASE
	//³ Faz a avaliacao comercial conforme alcada do operador     ³
	// nPrcTabBase := MaTabPrVen(GetMV("MV_TABPAD"),SUB->UB_PRODUTO,SUB->UB_QUANT,SUA->UA_CLIENTE,SUA->UA_LOJA,SUA->UA_MOEDA)
	
	//Aplica o Desconto/Acréscimo Especial
	//removido em 09/02/2015 por que as regras de desconto e acrescimo por filial estão sendo descontinuadas - Rodrigo carvalho - Solutio
	/*
	If nDesAcreFil <>0
	nPrcTabBase :=A410Arred(nPrcTabBase +((nPrcTabBase*nDesAcreFil)/100))
	Endif
	*/
	//removido em 10/02/2015 por que as regras de desconto e acrescimo por filial estão sendo descontinuadas - Rodrigo carvalho - Solutio
	// Acrescimo MVA	p/ SP ou Desc/Acrescimo especifico para a filial em questao
	/*
	If ((SA1->A1_EST==cEstATU .AND. cEstATU=='SP' .AND. Alltrim(SF4->F4_CF) == "5405") .OR.;
	(SA1->A1_EST==cEstATU .AND. cEstATU=='PR' .AND. SF4->F4_CODIGO=='724') .OR. ;
	(SA1->A1_EST==cEstATU .AND. cEstATU=='RS' .AND. SF4->F4_CODIGO=='721' .AND. (Alltrim(SB1->B1_ORIGER) <> "F/NCZADO" .AND. Alltrim(SB1->B1_ORIGER) <> "IMPORTADO"  )))
	
	If SX5->(DbSeek(xFilial("SX5") + "77" +cFilant,.F.))
	nAcreMva:=Val(StrTran(SX5->X5_DESCRI,",","."))
	
	nPrcTabBase := A410Arred(nPrcTabBase*nAcreMva,"UB_VRUNIT")
	Endif
	Endif
	*/
	
	
	//|Chamado: 	AAZQ5R 			|Assunto: DESONER CUSTO COML EXPORTADORA |Analista: Cristiano MAchado
	//|Solicitante: Marcia Silveira |Data: 24/06/09
	
	//////////////////////////////////JULIO JACOVENKO
	//////////////////////////////////AQUI TRATA 4%
	//////////////////////////////////TEM QUE ESTAR NESTA POSICAO, POIS TRATA ITEM A ITEM...
	//Removido em 10/02/2015 em função de que as regras de desconto foram descontinuadas - Rodrigo Carvalho - Solutio
	//³Define o desconto de ICMS padrao                     ³
	//SUB->(U_DesICMPad(SA1->A1_EST))
	/////////////////////////////////////////////////
	
	
	//Removido em 10/02/2015 em função de que as regras de desconto foram descontinuadas - Rodrigo Carvalho - Solutio
	/*
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
	nPrBaseDesc := SUB->UB_VRUNIT / (1 - ((SUB->UB_DESCICM) /100))
	nDifIcmUnit := nPrBaseDesc * ((nDescIcmPad - SUB->UB_DESCICM) / 100 )
	
	nDescReal := NoRound( ( 1 -((nPrBaseDesc + nDifIcmUnit) / nPrcTabBase)) * 100 , nDecDesc      )
	Endif
	Endif
	*/
	
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
	
	//removido os calculos de desconto e acrescimo das comissões conforme solicitado em reunião com a Diretoria - Rodrigo SOlutio 30/01/2015
	/*
	If SA1->A1_GERVEN='000685' //----------------- Projeto Comissões por Operador(Pedido do Call Center
	Processa( {|| n_COMIS1  := SF4->(u_DefComis(SU7->U7_CODVEN,.F.,SA1->A1_PAGCOM1,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[1]  }, 'Comissoes ', 'Processando vendedor 1...' )
	Else
	Processa( {|| n_COMIS1  := SF4->(u_DefComis(SA1->A1_VENDEXT,.F.,SA1->A1_PAGCOM1,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[1]  }, 'Comissoes ', 'Processando vendedor 1...' )
	Endif
	
	Processa( {|| n_COMIS2  := SF4->(u_DefComis(SA1->A1_VEND   ,.T.,SA1->A1_PAGCOM2,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[2]  }, 'Comissoes ', 'Processando vendedor 2...' )
	Processa( {|| n_COMIS3  := SF4->(u_DefComis(SA1->A1_VENDCOO,.F.,SA1->A1_PAGCOM3,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[3]  }, 'Comissoes ', 'Processando vendedor 3...' )
	Processa( {|| n_COMIS4  := SF4->(u_DefComis(SA1->A1_CHEFVEN,.F.,SA1->A1_PAGCOM4,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[4]  }, 'Comissoes ', 'Processando vendedor 4...' )
	Processa( {|| n_COMIS5  := SF4->(u_DefComis(SA1->A1_GERVEN ,.F.,SA1->A1_PAGCOM5,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[5]  }, 'Comissoes ', 'Processando vendedor 5...' )
	*/
	
	oProcess:IncRegua2('Verificando Comissoes vendedor 1...')
	n_COMIS1  := SF4->(u_DefComis(SA1->A1_VENDEXT,.F.,SA1->A1_PAGCOM1,0,0 ))
	oProcess:IncRegua2('Verificando Comissoes vendedor 2...')
	n_COMIS2  := SF4->(u_DefComis(SA1->A1_VEND   ,.T.,SA1->A1_PAGCOM2,0,0 ))
	oProcess:IncRegua2('Verificando Comissoes vendedor 3...')
	n_COMIS3  := SF4->(u_DefComis(SA1->A1_VENDCOO,.F.,SA1->A1_PAGCOM3,0,0 ))
	oProcess:IncRegua2('Verificando Comissoes vendedor 4...')
	n_COMIS4  := SF4->(u_DefComis(SA1->A1_CHEFVEN,.F.,SA1->A1_PAGCOM4,0,0 ))
	oProcess:IncRegua2('Verificando Comissoes vendedor 5...')
	n_COMIS5  := SF4->(u_DefComis(SA1->A1_GERVEN ,.F.,SA1->A1_PAGCOM5,0,0 ))
	
	
	//	RODRIGO SOLUTIO
	/*
	Processa( {|| n_COMIS1  := SF4->(u_DefComis(SA1->A1_VENDEXT,.F.,SA1->A1_PAGCOM1,0,0 )) }, 'Verificando Comissoes ', 'Processando vendedor 1...' )
	Processa( {|| n_COMIS2  := SF4->(u_DefComis(SA1->A1_VEND   ,.T.,SA1->A1_PAGCOM2,0,0 )) }, 'Verificando Comissoes ', 'Processando vendedor 2...' )
	Processa( {|| n_COMIS3  := SF4->(u_DefComis(SA1->A1_VENDCOO,.F.,SA1->A1_PAGCOM3,0,0 )) }, 'Verificando Comissoes ', 'Processando vendedor 3...' )
	Processa( {|| n_COMIS4  := SF4->(u_DefComis(SA1->A1_CHEFVEN,.F.,SA1->A1_PAGCOM4,0,0 )) }, 'Verificando Comissoes ', 'Processando vendedor 4...' )
	Processa( {|| n_COMIS5  := SF4->(u_DefComis(SA1->A1_GERVEN ,.F.,SA1->A1_PAGCOM5,0,0 )) }, 'Verificando Comissoes ', 'Processando vendedor 5...' )
	*/
	
	RecLock("SUB",.F.)
	SUB->UB_COMIS1 := n_COMIS1
	SUB->UB_COMIS2 := n_COMIS2
	SUB->UB_COMIS3 := n_COMIS3
	SUB->UB_COMIS4 := n_COMIS4
	SUB->UB_COMIS5 := n_COMIS5
	MsUnlock()
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MARGEM (OBS: qualquer alteração aqui, faça também no M460FIM    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	// Define variaveis para calculo de custo total e lucro
	//	nAcreFin  := SE4->E4_ACRSFIN /100 //(Posicione("SE4",1,xFilial("SE4")+cCondPag,"E4_ACRSFIN") / 100) //(NOVO)	//	SOLUTIO
	//	nAcreReal := 1 + (SE4->E4_ACRREAL / 100)                                                                        //	SOLUTIO
	
	// Define o custo do item (na moeda 1)
	//Custo Margem de Contribuição
	
	// Inicializa variável de controle
	***********************************
	nCustoMC :=  U_FCusTrib(.F.)
	***********************************
	
	If  ( Type("lTk271Auto") == "U" .OR. !lTk271Auto )
		// MsAguarde({|| nCustoMCR  := SF4->(U_PrcBase( cProduto,cTabPreco,@cTpCust,.F.,"R")) },"MARGEM","Definindo Custo Contribuição Reposicao...")
		
		oProcess:IncRegua2("Margem - Definindo Custo Contribuição Reposicao...")
		nCustoMCR  := SF4->(U_PrcBase(cProduto,cTabPreco,@cTpCust,.F.,"R"))
		
	Else
		nCustoMCR  :=  U_PrcBase( cProduto,cTabPreco,@cTpCust,.F.,"R")
	Endif
	
	//Custo Margem de Contribuição Média das Ultimas Compras
	If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
		// MsAguarde({|| nCustoMCUC :=SF4->(U_PrcBase( cProduto,cTabPreco,@cTpCust,.F.,"U")) },"MARGEM","Definindo Custo Contribuição Média das Ultimas Compras...")
		oProcess:IncRegua2("Margem - Definindo Custo Contribuição Média das Ultimas Compras...")
		nCustoMCUC :=SF4->(U_PrcBase( cProduto,cTabPreco,@cTpCust,.F.,"U"))
		
	Else
		nCustoMCUC :=  U_PrcBase( cProduto,cTabPreco,@cTpCust,.F.,"U")
	Endif
	
	// converte o valor total do item para moeda 1
	nVlrItem := IIF(cMoeda==1,nVlrItem,xMoeda(nVlrItem,cMoeda,1,dDataBase,nDecVLRITEM))
	
	// ***********     Preco de Venda Deflacionado    *********
	// Define o desconto a ser aplicado no lucro devido ao acrescimo financeiro
	// ou seja, é a diferença das despesas financeiras que pago para o banco das que o cliente me paga
	
	//	nDescLucro :=  (nBASEICM * nAcreFin) // (NOVO)	// SOLUTIO
	
	// Calcula o valor da diferenca de ICMS
	//removido em 10/02/2015 em função de que as regras de desconto e acrescimo foram descontinuadas
	// nValDifICM := nVlrItem * ( (nDescIcmPad - nDescIcm) / 100 )
	
	// RATEIOS
	// Faz o Rateio do frete quando for CIF
	// Rateio das Despesas por item
	nRatDesp := SUB->UB_VLRITEM / SUA->UA_VALBRUT * nDespesa
	
	// ********** Despesa do DOC - Despesas diversas cobradas do cliente**********
	nDespDOC := nDespesa
	lVerST	 := .F.
	nAlicIcm := nValDesp := nAcreCon := nValFret := nCalcIcm := nAlicIpi := nMVA := nValIcmSt := nIcmRetido := nValFrtA := 0
	
	If nItem > 0  .And. nItem <= Len(aCols)
		//      Valor de ICM                          Valor de PIS                 Valor COFINS
		
		/**************************************************************************************************************/
		//nValICM :=	mafisret(nItem,"IT_VALICM")
		//If mafisret(nItem,"IT_VALICM") == 0
		
		//CRISTIANO 31/10/08 Ajuste de Margens ...
		nValDesp := NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_DESPESA,2) // Despesa DOC
		
		nAcreCon := NoRound(((SUB->UB_VLRITEM + (SUB->UB_VLRITEM / SUA->UA_VALMERC) * SUA->UA_DESPESA) * SE4->E4_ACRSFIN)/100,2) //Acrescimo Condicao
		
		//original
		//nValFret := NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_FRETE,2) //Valor Frete
		
		If SUA->UA_TPFRETE == "F" .AND. nFretefob !=0
			If POSICIONE("SZO",1,XFILIAL("SZO")+SUA->UA_CODROTA,"ZO_REDESPA") = "S" //Verifica frete redespacho
				lRedesp := .T.
			EndIf
		EndIf
		
		nBASEICM 	:=	NoRound((SUB->UB_VLRITEM   + nValDesp + nAcreCon + nValFrtA),2)
		// Valor  TOTAL DO ITEM com acréscimo e sem IPI =  BASE DE ICM  (UB_VRCACRE * UB_QUANT
		nBASEICM  := IIF(cMoeda==1,nBASEICM,xMoeda(nBASEICM,cMoeda,1,dDataBase,nDecBASEICM))
		
		
		/////JULIO JACOVENKO, em 04/07/2014 PROJETO NOVO FRETE
		/////CRIADO CAMPO UA_TPCIF para saber o tipo de frete escolhido (e nao mais pelos campos UA_FRETE ou UA_FRETCAL)
		/////a escolha ate entao era se o camp UA_FRETE tivesse valor este era identificado como CIFD, caso
		/////contrario seria CIFI.
		/////Como agora usamos o campo UA_FRETE sempre (ou seja o vendedor pode alter o valor do frete I ou D)
		/////este sempre contera valor.
		
		
		
		////JULIO JACOVENKO, em 31/07/2014
		////tratar excecoes
		
		
		////USANDO FILIAL 05
		///QUANDO TODOS TROCAR
		///IF (XFILIAL('SUA')<>'07' .OR. XFILIAL('SUA')<>'11') .AND. (SA1->A1_VINCIMD<>'PP' .OR. SA1->A1_VINCIMD<>'CM') .AND. (SA1->A1_CLFAMIN<>'S')
		
		//MV_FILFRT='05/11'
		//IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCIMD<>'PP' .AND. SA1->A1_VINCIMD<>'CM')
		LVINCULO:=ALLTRIM(SA1->A1_VINCIMD)$  ("#CM*CM*#PP*PP")
		IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (!LVINCULO) .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'
			
			//IF (XFILIAL('SUA')=='05') .AND. (SA1->A1_VINCIMD<>'PP' .OR. SA1->A1_VINCIMD<>'CM')
			/////tratar aqui
			nValFret := NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC *  SUA->UA_FRETRAN,2) // - SUA->UA_FRETE,2) //Valor Frete
			nValFrtA:= NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC *  SUA->UA_FRETE,2)
		ELSE
			nValFret := NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_FRETE,2) //Valor Frete
			nValFrtA:= 0
		ENDIF
		
		
		
		
		///ORIGINAL
		//If SUA->UA_TPFRETE == "C" .AND. SUA->UA_FRETE != 0
		If SUA->UA_TPFRETE == "C" .AND. SUA->UA_FRETE !=0    //SUA->UA_TPCIF='CIFD'   //SUA->UA_FRETE != 0
			
			///JULIO JACOVENKO, em 04/08/2014
			///condiçao de especiais
			
			
			///USANDO FILIAL 05
			///QUANDO TODAS TROCAR
			///IF (XFILIAL('SUA')<>'07' .OR. XFILIAL('SUA')<>'11') .AND. (SA1->A1_VINCIMD<>'PP' .OR. SA1->A1_VINCIMD<>'CM') .AND. (SA1->A1_CLFAMIN<>'S')
			
			//MV_FILFRT='05/11'
			//IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCIMD<>'PP' .AND. SA1->A1_VINCIMD<>'CM')
			LVINCULO:=ALLTRIM(SA1->A1_VINCIMD)$  ("#CM*CM*#PP*PP")
			IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (!LVINCULO) .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'
				//IF (XFILIAL('SUA')=='05') .AND. (SA1->A1_VINCIMD<>'PP' .OR. SA1->A1_VINCIMD<>'CM')
				
				//ALERT('UA_FRETE<>')
				nFreteItem	:= nValFret //| CIF - Destacado      ///nFreteCal / nValmerc * nVlrItem
				
				////JULIO JACOVENKO, em 04/07/2014 - ref projeto novo frete
				////
				////pelo projeto nao teremos mais os 20%
			ELSE
				
				//ORIGINAL
				nFreteItem	:= nValFret //- (nValFret * 0.2) // MENOS 20%
				
			ENDIF
			
			
		Elseif SUA->UA_TPFRETE == "C" .AND. SUA->UA_FRETE = 0 //SUA->UA_TPCIF='CIFI' //SUA->UA_FRETE = 0
			//nFreteItem := NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC * nFreteCal,2) //Valor Frete
			
			
			////JULIO JACOVENKO, em 31/07/2014
			////tratar excecoes
			/////tratar aqui
			
			
			//ALERT('UA_FRETE=0')
			
			
			///USANDO FILIAL 05
			///QUANDO TODOS TROCAR
			///IF (XFILIAL('SUA')<>'07' .OR. XFILIAL('SUA')<>'11') .AND. (SA1->A1_VINCIMD<>'PP' .OR. SA1->A1_VINCIMD<>'CM') .AND. (SA1->A1_CLFAMIN<>'S')
			
			//MV_FILFRT='05/11'
			//IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCIMD<>'PP' .AND. SA1->A1_VINCIMD<>'CM')
			LVINCULO:=ALLTRIM(SA1->A1_VINCIMD)$  ("#CM*CM*#PP*PP")
			IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (!LVINCULO) .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'
				//IF (XFILIAL('SUA')=='05') .AND. (SA1->A1_VINCIMD<>'PP' .OR. SA1->A1_VINCIMD<>'CM')
				///AJUSTADO PARA NOVO FRETE
				nFreteItem := NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_FRETRAN ,2) //(SUA->UA_FRETRAN - SUA->UA_FRETCAL),2) //Valor Frete Incluso
			ELSE
				///ORIGINAL
				nFreteItem := NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_FRETCAL,2) //Valor Frete Incluso
			ENDIF
			
			
			
			
		Elseif lRedesp
			nFreteItem := NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC * nFreteFob,2) //Valor Frete de Redespacho
		Else
			nFreteItem := 0
		Endif
		
		/////JULIO JACOVENKO, 13/08/2014
		/////PROJETO FRETE 1.3
		////Reajuste em 26/08/2014 - ref. nIMC e nValFrtA, corrigido diferença entre pedido e nf.
		////
		
		///USANDO FILIAL 05
		///QUANDO TODAS TROCAR
		///IF (XFILIAL('SUA')<>'07' .OR. XFILIAL('SUA')<>'11') .AND. (SA1->A1_VINCIMD<>'PP' .OR. SA1->A1_VINCIMD<>'CM') .AND. (SA1->A1_CLFAMIN<>'S')
		
		//MV_FILFRT='05/11'
		//IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCIMD<>'PP' .AND. SA1->A1_VINCIMD<>'CM')
		LVINCULO:=ALLTRIM(SA1->A1_VINCIMD)$  ("#CM*CM*#PP*PP")
		IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (!LVINCULO) .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'
			//IF (XFILIAL('SUA')=='05') .AND. (SA1->A1_VINCIMD<>'PP' .OR. SA1->A1_VINCIMD<>'CM')
			nCalcIcm := NoRound((SUB->UB_VLRITEM   + nValDesp + nAcreCon + nValFrtA),2)   // Base do Icms
			//IF SUA->UA_FRETE==0 .AND. SUA->UA_FRETCAL==0
			//nCalcIcm := NoRound((SUB->UB_VLRITEM  + nValDesp + nAcreCon ),2)   // Base do Icms
			//ENDIF
			//Novo Cálculo para PIS desprezando o frete
			// NIcm_PIS := NoRound((SUB->UB_VLRITEM   nValDesp + nAcreCon ),2)   // Base do Icms
			
			NIcm_PIS := NoRound((SUB->UB_VLRITEM  + nAcreCon ),2)   // Base do Icms // alterado por rodrigo em 29/05 em função de que não deve somar as despesas nos calculo de PIS
			
		ELSE
			nCalcIcm    := NoRound((SUB->UB_VLRITEM   + nValDesp + nAcreCon + nValFret),2)   // Base do Icms
			
			//Novo Cálculo para PIS desprezando o frete
			NIcm_PIS:= NoRound((SUB->UB_VLRITEM   + nAcreCon),2)   // Base do Icms // alterado por rodrigo em 29/05 em função de que não deve somar as despesas nos calculo de PIS
		ENDIF
		
		//IF SUA->UA_FRETE==0 .AND. SUA->UA_FRETCAL==0
		//nCalcIcm := NoRound((SUB->UB_VLRITEM  + nValDesp + nAcreCon ),2)   // Base do Icms
		//ELSE
		//nCalcIcm := NoRound((SUB->UB_VLRITEM  + nValDesp + nAcreCon + NVALFRET ),2)
		//ENDIF
		
		//ALERT('TMKVFIM calcicm: '+STR(NCALCICM))
		
		
		
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
				If SB1->B1_ORIGEM $ "1/2/3/8"
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
		If cFilant == '04' .AND. ( SF4->F4_CODIGO $ '540/721/724/723' ) // Chamado AAZUTY
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
		
		IF SF4->F4_CREDICM <> 'S'
			
			nValICM := 0
			
		endif
		
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
			//nCalcPis	:= NoRound( ( ( nAliqPis - ( ( nAliqPis / 100 ) * nRedPis) ) / 100 ) * (nCalcIcm) , 2 )
			//Novo cálculo desprezando frete
			nCalcPis	:= NoRound( ( ( nAliqPis - ( ( nAliqPis / 100 ) * nRedPis) ) / 100 ) * (NIcm_PIS) , 2 )
			
			nCalcCof    := 0
		ElseIf SF4->F4_PISCOF == '2'
			nCalcPis	:= 0
			//nCalcCof	:= NoRound( ( ( nAliqCof - ( ( nAliqCof / 100 ) * nRedCof) ) / 100 ) * (nCalcIcm) , 2 )
			//Novo cálculo desprezando frete
			nCalcCof	:= NoRound( ( ( nAliqCof - ( ( nAliqCof / 100 ) * nRedCof) ) / 100 ) * (NIcm_PIS) , 2 )
			
		ElseIf SF4->F4_PISCOF == '3'
			//nCalcPis	:= NoRound( ( ( nAliqPis - ( ( nAliqPis / 100 ) * nRedPis) ) / 100 ) * (nCalcIcm) , 2 )
			//Novo cálculo desprezando frete
			nCalcPis	:= NoRound( ( ( nAliqPis - ( ( nAliqPis / 100 ) * nRedPis) ) / 100 ) * (NIcm_PIS) , 2 )
			
			//nCalcCof	:= NoRound( ( ( nAliqCof - ( ( nAliqCof / 100 ) * nRedCof) ) / 100 ) * (nCalcIcm) , 2 )
			//Novo cálculo desprezando frete
			nCalcCof	:= NoRound( ( ( nAliqCof - ( ( nAliqCof / 100 ) * nRedCof) ) / 100 ) * (NIcm_PIS) , 2 )
			
		Else
			nCalcCof    := 0
			nCalcPis	:= 0
		Endif
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  ZERAR PIS \ COFINS QUANDO Credita PIS/COFINS <> DEBITA		³
		//|  FABIANO PEREIRA - SOLUTIO 05/10/2015 						|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SF4->F4_PISCRED != '2' // <> DEBITA
			nCalcCof    := 0
			nCalcPis	:= 0
		EndIf


		
		DbSelectArea("SC6")
		
		// CHAMADO TECNICO : AAZVST    SOLICITANTE: Marcia Silveira   DATA: 22/08/2013
		// Favor contemplar no cálculo do IMCR nas vendas para fora do Estado, de produtos Importados, a alíquota de 4%, hoje o sistema efetua o cálculo do campo CUSMCR da seguinte forma:
		// Custo standart = 100,00 ( - ) % PIS ( - ) % Cofins ( - ) % ICMS do Estado de origem da venda (ESTE PERCENTUAL NESTA SITUAÇÃO, deve ser substituído pela alíquota de 4%
		// ( = ) Custo Reposição
		
		/* //Desabilitado conforme analise custo/suprimentos em 23/12/2014
		If  ( nAlicIcm == GetMv("IM_ICMIMP") ) // Produto Importado e Venda InterEstadual....
		
		nAuxPis := nAliqPis - ( nAliqPis * nRedPis  /  100 )
		nAuxCof := nAliqCof - ( nAliqCof * nRedCof  /  100 )
		nAuxIcm := nAlicIcm
		
		nCustoMCR :=  xMoeda(SB1->B1_CUSTD,Val(SB1->B1_MCUSTD),1,dDataBase) * (( 100 - ( nAuxPis + nAuxCof + nAuxIcm ) ) / 100 )
		
		EndIf
		*/
		
		// AAZVST FIM
		
		// CHAMADO TECNICO : AAZVO6    SOLICITANTE: Marcia Silveira
		// Incluir o percentual de 8,25% no custo reposição nas vendas que se enquadram na substituição tributária para as filiais: RS , MT, PR, MG.
		// Ajuste de Mergem Reposicao para ST
		
		cUfFilOrig := SM0->M0_ESTENT /// UF filial origem...
		If ( lverSt )
	       //ALERT('ENTROU NO LVERST')		

			cFilAjuMar := GetMV("MV_UFAJMGR") // UF's que devem receber o ajuste no custo reposicao...
			//cUfFilOrig := SM0->M0_ESTENT /// UF filial origem...
			
			If ( cUfFilOrig $ cFilAjuMar ) .AND. SF4->F4_CODIGO == '720'
			   //FILIAIS:= 02,05,09,13,14
			   //nFATOR:=FCalcIMC(cFil,cArmazem,cB1origer,nAliqIPI)
				
				
				If  cFilAnt =='02' .AND. cUfFilOrig =='MT'
					//nCustoMCR  := nCustoMCR * 1.24    // Acrescimo Especifico para MT
	               nFATOR:=U_FCalcIMC(cFilAnt,cLocalB2,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
				   nCustoMCR  := nCustoMCR * NFATOR    // Acrescimo Especifico para MT
	


				elseIf cFilAnt =='14' .AND. cUfFilOrig =='MG'
					//nCustoMCR  := nCustoMCR * 1.44    // Acrescimo Especifico para MT
         	       nFATOR:=U_FCalcIMC(cFilAnt,cLocalB2,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
				   nCustoMCR  := nCustoMCR * NFATOR    // Acrescimo Especifico para MT
				elseIf cFilAnt =='09' .AND. cUfFilOrig =='SP'
					//nCustoMCR  := nCustoMCR * 1.40  // 
					////
					////     
					//msgalert("vai chamar funcao para PRODUTO: "+SUB->UB_PRODUTO)
			        nFATOR:=U_FCalcIMC(cFilAnt,cLocalB2,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
			        //msgalert("retornou c/fator: "+str(NFATOR))
					nCustoMCR  := nCustoMCR * nFATOR  
					////
					////
				    //msgalert("nCustoMcr: "+str(nCustoMCR))
				elseIf cFilAnt =='05' .AND. cUfFilOrig =='RS'
				    //nCustoMCR  := nCustoMCR * 1.40
				    //ALERT(SUB->UB_PRODUTO+' '+cFilAnt+' '+cLocalB2+' '+SB1->B1_ORIGER+' '+SB1->B1_ORIGEM+' '+ALLTRIM(STR(SB1->B1_IPI)))
		           nFATOR:=U_FCalcIMC(cFilAnt,cLocalB2,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
				   //ALERT('NCUSTOMCRa: '+STR(nCUSTOMCR))
				   nCustoMCR  := nCustoMCR * NFATOR    // Acrescimo Especifico para MT
				   //ALERT('NFATORa: '+STR(NFATOR))
				   
				elseIf cFilAnt =='13' .AND. cUfFilOrig =='PR'
				    //nCustoMCR  := nCustoMCR * 1.40
				   nFATOR:=U_FCalcIMC(cFilAnt,cLocalB2,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
				   nCustoMCR  := nCustoMCR * NFATOR    // Acrescimo Especifico para MT
				else
					//nCustoMCR  := nCustoMCR * 1.20 // Acrescimo de 8.25 %
				endif
			/*
			Elseif ( cUfFilOrig $ cFilAjuMar ) .AND. SF4->F4_CODIGO == '501'
		
		         If  cFilAnt =='02' .AND. cUfFilOrig =='MT'
					//nCustoMCR  := nCustoMCR * 1.24    // Acrescimo Especifico para MT
	               nFATOR:=U_FCalcIMC(cFilAnt,cLocal,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
				    nCustoMCR  := nCustoMCR * NFATOR    // Acrescimo Especifico para MT
	            EndIF	
	       */     
			Endif
		
		
		ELSE
		//ALERT(CFILANT)
		//ALERT(cUfFilOrig)
		//ALERT(NCUSTOMCR)
		
			
			
			///SA1->A1_EST estado destino

			
			If (cFilAnt =='02' .AND. cUfFilOrig =='MT'  .AND. SA1->A1_EST='MT' .AND. !(SB1->B1_GRUPO $ "0008") ) //.AND. SB1->B1_INDUSTR='N' //QUANDO INDUSTRIAL FOR NAO

				//nCustoMCR  := nCustoMCR * 1.24 // Acrescimo Especifico para MT
				//LEIO A TABELA BASEADO NO IPI
	           nFATOR:=U_FCalcIMC(cFilAnt,cLocalB2,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
			   nCustoMCR  := nCustoMCR * NFATOR    // Acrescimo Especifico para MT
			endif
			
          //SB1->B1_GRUPO NOT $ "001*0014*0015"
			
			If cFilAnt =='14' .AND. cUfFilOrig =='MG' .AND. !(SB1->B1_GRUPO $ "0011*0014*0015*0008") .AND. SA1->A1_EST='MG' //.AND. SB1->B1_INDUSTR='N' ///QUAN INSDUSTRIAL FOR NAO

				//nCustoMCR  := nCustoMCR * 1.44 // Acrescimo Especifico para MT
			   //LEIO A TABELA BASEADO NO IPI                                   
		       nFATOR:=U_FCalcIMC(cFilAnt,cLocalB2,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
			   nCustoMCR  := nCustoMCR * NFATOR    // Acrescimo Especifico para MT
			endif			
			
			//ALERT(NFATOR)
		   
			/*

			If cFilAnt =='09' .AND. cUfFilOrig =='SP' .AND. SF4->F4_CODIGO == '720'
				nCustoMCR  := nCustoMCR * 1.40 // Acrescimo Especifico para MT
									//nCustoMCR  := nCustoMCR * 1.40  // 
									
			endif
			*/
			
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
	
	// RODRIGO SOLUTIO
	// nVDescComis := nQtdItem * nVlrItem * ( (n_COMIS1 * 1.63)  + n_COMIS2 + (n_COMIS3 * 1.63)  + (n_COMIS4 * 1.63) + (n_COMIS5 * 1.63) )/100
	
	// *********** Fatores (F´s)
	// nFat1 =  Coeficiente Cambial    (COEFC)
	// nFat2 =  Coeficiente Financeiro (COEFF)
	// nFat3 =  Coeficiente Idade      (COEFI)
	If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
		///JULIO JACOVENKO, em 23/05/2012
		///AJUSTADO PARA PEGAR A IDADE2
		nIdadeSC6 := u_IdadeAtu(nQtdItem,SB2->B2_IDADE,SB2->B2_DTIDADE) //PEGA A IDADE1 PARA GRAVAR NO SC6
		IF SB2->B2_IDIMDE=0
			// MsAguarde({|| nIdade :=SF4->(u_IdadeAtu(nQtdItem,SB2->B2_IDADE,SB2->B2_DTIDADE))},"IDADE","Definindo Idade do Produto ...")
			oProcess:IncRegua2("Idade - Definindo Idade do Produto ...")
			nIdade := SF4->(u_IdadeAtu(nQtdItem,SB2->B2_IDADE,SB2->B2_DTIDADE))
			
		ELSE
			//MsAguarde({|| nIdade :=SF4->(u_IdadeAtu(nQtdItem,SB2->B2_IDIMDE,SB2->B2_DTCALC))},"IDADE","Definindo Idade do Produto ...")
			oProcess:IncRegua2("Idade - Definindo Idade do Produto ...")
			nIdade :=SF4->(u_IdadeAtu(nQtdItem,SB2->B2_IDIMDE,SB2->B2_DTCALC))
			
		ENDIF
	Else
		///JULIO JACOVENKO, em 23/05/2012
		///AJUSTADO PARA PEGAR A IDADE2
		IF SB2->B2_IDIMDE=0
			oProcess:IncRegua2("Verificando IdadeAtu...")
			nIdade := u_IdadeAtu(nQtdItem,SB2->B2_IDADE,SB2->B2_DTIDADE)
		ELSE
			oProcess:IncRegua2("Verificando IdadeAtu...")
			nIdade := u_IdadeAtu(nQtdItem,SB2->B2_IDIMDE,SB2->B2_DTCALC)
		ENDIF
		oProcess:IncRegua2("Verificando IdadeAtu...")
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
	
	
	////JULIO JACOVENKO, em 13/08/2014
	////projeto frete 1.3
	
	///USANDO FILIAL 05
	///QUANDO TODAS TROCAR
	///IF (XFILIAL('SUA')<>'07' .OR. XFILIAL('SUA')<>'11') .AND. (SA1->A1_VINCIMD<>'PP' .OR. SA1->A1_VINCIMD<>'CM') .AND. (SA1->A1_CLFAMIN<>'S')
	
	//MV_FILFRT='05/11'
	//IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCIMD<>'PP' .AND. SA1->A1_VINCIMD<>'CM')
	LVINCULO:=ALLTRIM(SA1->A1_VINCIMD)$  ("#CM*CM*#PP*PP")
	IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (!LVINCULO) .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'
		//IF (XFILIAL('SUA')=='05') .AND. (SA1->A1_VINCIMD<>'PP' .OR. SA1->A1_VINCIMD<>'CM')
		//Msginfo('Nova versão de fretes ')
		
		//comentado por Rodrigo SOlutio em 09/02/2015 para que a variável nTotItemSemIPI receba o valor de SUB->UB_TOTACRE
		//nTotItemSemIPI  := NoRound(SUB->UB_VRCACRE * SUB->UB_QUANT + (SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_DESPESA ),2) + nICMRetido + nValFrtA
		//nTotItemSemIPI  := NoRound(SUB->UB_VRCACRE * SUB->UB_QUANT + (SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_DESPESA ),2) + nICMRetido + nValFret
		
		//IF SUA->UA_FRETE==0 .AND. SUA->UA_FRETCAL==0
		//nTotItemSemIPI  := NoRound(SUB->UB_VRCACRE * SUB->UB_QUANT + (SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_DESPESA ),2) + nICMRetido
		//ENDIF
		
		
		// RODRIGO SOLUTIO
		nTotItemSemIPI  := SUB->UB_VLRITEM + nRatDesp + nAcreCon + nValFrtA
		
		
	ELSE
		//comentado por Rodrigo SOlutio em 09/02/2015 para que a variável nTotItemSemIPI receba o valor de SUB->UB_TOTACRE
		//nTotItemSemIPI  := NoRound(SUB->UB_VRCACRE * SUB->UB_QUANT + (SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_DESPESA ),2) + nICMRetido + nValFret
		
		
		// RODRIGO SOLUTIO
		nTotItemSemIPI  := SUB->UB_VLRITEM + nRatDesp + nAcreCon + nValFret
		
	ENDIF
	
	
	
	//Custo médio kardex Gerencial
	nCustoMCg 			:=  nFatores + nCustoMC
	
	
	nTxFin  			:=  GETMV("MV_TXFIN",,0)/100  // Similar a Taxa CDI , mas ao mês
	nValCPMF	    	:=  GETMV("MV_CPMF" ,,0)/100  * MaFisRet(nItem,"IT_TOTAL")
	nPrazoMedioCobr 	:= 	SE4->E4_PRZMED //criar campo
	nTaxaDiaria 		:=  ((1 + nTxFin )^(1/30))-1
	nValorDeflacionado 	:=  (nTotItemSemIPI / ((1 + round(nTaxaDiaria,6)) ^ nPrazoMedioCobr ))
	
	
	// Margem de Contribuicao não Gerencial (sem os fatores -> F1, F2, F3 ...)
	//AVALISOLUTIOAR CRISTIANO
	
	////JULIO JACOVENKO, em 13/08/2014
	////nFreteItem tem de ser o FRETE TRANSP
	
	//ALERT('TMKVFIM  : '+STR(NFRETEITEM) )
	
	//// Alteração Rodrigo Solutio em 04/02/2015
	// regra antiga
	//	nMC   := nValorDeflacionado - (nValCPMF + nCustoMC  * nQtdItem + nImpostosnoVlrItem + nVDescComis + nFreteItem)
	
	//Nova Rega
	//*** MC = Valor da mercadoria - Custo(CUSMC) - Impostos(PIS,COFINS,ICMS) - Frete CIF - Comissão
	//nRedComis := nQtdItem * nVlrItem * ( n_COMIS1  + n_COMIS2 + n_COMIS3  + n_COMIS4 + n_COMIS5 )/100 //  Alterado em 25/05/2015 para retornar a incidência de 63% sobre o calculo de comissões.
	//    nRedComis := nQtdItem * nVlrItem * ( (n_COMIS1 * 1.63)  + n_COMIS2 + (n_COMIS3 * 1.63)  + (n_COMIS4 * 1.63) + (n_COMIS5 * 1.63) )/100
	//nRedComis := ((n_COMIS1 + n_COMIS3  + n_COMIS4 + n_COMIS5) * 1,63 *  nVlrItem +  ((n_COMIS2)*(nVlrItem)))
	nRedComis := (((n_COMIS1+n_COMIS3+n_COMIS4+n_COMIS5) *1.63 * (SUB->UB_VLRITEM  + nAcreCon))+((n_COMIS2)*(SUB->UB_VLRITEM  + nAcreCon))) / 100
	/********************/
	// nMCR  := nValorDeflacionado - (nValCPMF + nCustoMCR  * nQtdItem + nImpostosnoVlrItem + nVDescComis + nFreteItem)
	
	// FABIANO PEREIRA - SOLUTIO
	nMC   := NOROUND(nValorDeflacionado - (nCustoMC  * nQtdItem + nImpostosnoVlrItem + nRedComis + nFreteItem))
	// RODRIGO SOLUTIO
	nMCR  := nValorDeflacionado - ( nCustoMCR  * nQtdItem + nImpostosnoVlrItem + nRedComis + nFreteItem )
	
	
	//|Chamado: 	AAZPZ2 			|Assunto: Calculo Margem Custo Reposicao |Analista: Cristiano MAchado
	//|Solicitante: Marcia Silveira |Data: 11/05/09
	/*
	Desabilitado por Edivaldo Goncalves - Este trecho foi substituido pelo fator 1.024 em (Cuiaba) e  1.0825 demais filiais
	If nValICM == 0 .and. lInterna .and. (lVerST .OR. ( SM0->M0_ESTENT == "MT" .AND. SA1->A1_EST <> SM0->M0_ESTENT )  )
	nMCR  := nMCR - ((nCalcIcm * GetMv('MV_ICMPAD')) / 100)
	Endif
	*/
	
	/*
	// RODRIGO SOLUTIO
	nMCUC := nValorDeflacionado - (nValCPMF + nCustoMCUC * nQtdItem + nImpostosnoVlrItem + nVDescComis + nFreteItem)
	// Margem de Contribuicao Gerencial (com os fatores -> F1, F2, F3 ...) em Valores
	nMCg   	:= nValorDeflacionado - (nValCPMF + nCustoMCg  * nQtdItem + nImpostosnoVlrItem + nVDescComis + nFreteItem)
	//Indices da Margem de Contribuição (DIVIDIR PELO VALOR TOTAL DA NOTA sem IPI, ou seja é igual a base de ICM )
	// Não Gerencial
	*/
	
	//removido em 10/02/2015 em função de que as regras de desconto e acrescimo foram descontinuadas
	/* SOLUTIO
	
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
	*/
	
	oProcess:IncRegua2("Analisando Margem....")
	nIMC   := U_ValMarg(nMC  / (nTotItemSemIPI - nIcmRetido)  * 100) //Valida a margem para manter entre -999.99 e 999.99
	// Gerencial
	// RODRIGO SOLUTIO
	//nIMCg  := U_ValMarg(nMCg  / (nTotItemSemIPI - nIcmRetido) * 100) //Valida a margem para manter entre -999.99 e 999.99
	oProcess:IncRegua2("Analisando Margem....")
	nIMCR  := U_ValMarg(nMCR  / (nTotItemSemIPI - nIcmRetido) * 100)
	// RODRIGO SOLUTIO
	// nIMCUC := U_ValMarg(nMCUC / (nTotItemSemIPI - nIcmRetido) * 100)
	
	nMCTot						+= nMC
	// nMCgTot		  				+= nMCg  // RODRIGO SOLUTIO
	nMCRTot						+= nMCR
	// nMCUCTot			 			+= nMCUC  // RODRIGO SOLUTIO
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
		//removido em 10/02/2015 em função de que as regras de desconto e acrescimo foram descontinuadas
		//		cGeraLog +=	" nAcreCon           -> "+ cValToChar(nAcreCon) 			+ CRLF
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
		//removido em 10/02/2015 em função de que as regras de desconto e acrescimo foram descontinuadas
		//cGeraLog +=	" nVDescComis        -> "+ cValToChar(nVDescComis)			+ CRLF
		cGeraLog +=	" nImpostosnoVlrItem -> "+ cValToChar(nImpostosnoVlrItem)	+ CRLF
		cGeraLog +=	" nQtdItem           -> "+ cValToChar(nQtdItem)			 	+ CRLF
		cGeraLog +=	" nCustoMC           -> "+ cValToChar(nCustoMC) 			+ CRLF
		cGeraLog +=	" nCustoMCR          -> "+ cValToChar(nCustoMCR)			+ CRLF
		//removido em 10/02/2015 em função de que as regras de desconto e acrescimo foram descontinuadas
		//  		cGeraLog +=	" nAcrComExp         -> "+ cValToChar(nAcrComExp)			+ CRLF
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
	// Replace UB_MC    with nMC		,UB_MCG    with nMCg	 , UB_MCR    with nMCR	 	, UB_MCUC    with nMCUC // SOLUTIO
	Replace UB_MC    with nMC, UB_MCR    with nMCR
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
			// MsAguarde({|| SF4->(U_GravaVP()) },"Venda Perdida","Registrando Venda Perdida ...")
			oProcess:IncRegua2("Registrando Venda Perdida ...")
			SF4->(U_GravaVP())
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
	//removido em 10/02/2015 em função de que o processo carta negocio foi descontinuado - Rodrigo Carvalho - Solutio
	//	aOperador := { SA3->A3_COD, SA3->A3_NOME, SA3->A3_ALCADA, nalcada, SA3->A3_SUPER, SA3->A3_CARGO }
	
	// Jorge Oliveira - 28/02/2011 - Filial atual NAO trabalha com as Liberacao Comercial utilizando Carta de Negocio
	/*
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
	*/
	
	
	// Carrega array para posterior envio de e-mail
	// Removido em função de que o envio de mensagens foi descontinuado 10/02/2015 - Rodrigo Carvalho - Solutio
	// aAdd( aAvalCom, { SUB->UB_ITEM , SUB->UB_PRODUTO , SUB->UB_VLRITEM , SUB->UB_MARGEM, lOkItem, nDescReal, SB1->B1_DESC } )
	
	
	//	FABIANO PEREIRA - SOLUTIO
	If lOperFat
		
		oProcess:IncRegua2("Atualizando Pedido de Venda...")
		
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
		///JULIO JACOVENKO, em 11/07/2014
		///CORRIGIDO PARA PEGAR O LOCAL DO PEDIDO
		///FILIAL DO SC6
		C6FILIAL:=SC6->C6_FILIAL
		
		//XFILIAL()
		If DbSeek(C6FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL) //'01')
			///JULIO JACOVENKO, em 23/05/2012
			///AJUSTADO PARA PEGAR A IDADE2
			IF SB2->B2_IDIMDE=0
				nIdade2 := u_IdadeAtu(nQtdItem,SB2->B2_IDADE,SB2->B2_DTIDADE)
				RECLOCK('SB2',.F.)
					SB2->B2_IDIMDE	:= nIdade2
					SB2->B2_DTCALC	:= SB2->B2_DTIDADE
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
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Projeto comissões por operador descontinuado por solicitação do edvaldo, comentado em 09/02/2015 por Rodrigo Carvalho - Solutio IT
		/*
		If SA1->A1_GERVEN='000685' //----------------- Projeto Comissões por Operador(Pedido do Call Center
		SC6->C6_COMIS1  := SC6->(u_DefComis(SU7->U7_CODVEN,.F.,SA1->A1_PAGCOM1,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[1] //n_COMIS1
		Else
		SC6->C6_COMIS1  := SC6->(u_DefComis(SA1->A1_VENDEXT,.F.,SA1->A1_PAGCOM1,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[1] //n_COMIS1
		Endif
		
		SC6->C6_COMIS2  := SC6->(u_DefComis(SA1->A1_VEND   ,.T.,SA1->A1_PAGCOM2,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[2] //n_COMIS2
		SC6->C6_COMIS3  := SC6->(u_DefComis(SA1->A1_VENDCOO,.F.,SA1->A1_PAGCOM3,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[3] //n_COMIS3
		SC6->C6_COMIS4  := SC6->(u_DefComis(SA1->A1_CHEFVEN,.F.,SA1->A1_PAGCOM4,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[4] //n_COMIS4
		SC6->C6_COMIS5  := SC6->(u_DefComis(SA1->A1_GERVEN ,.F.,SA1->A1_PAGCOM5,IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0) )) + aComisCamp[5] //n_COMIS5
		*/
		
		// RODRIGO SOLUTIO
		SC6->C6_COMIS1  := SC6->(u_DefComis(SA1->A1_VENDEXT,.F.,SA1->A1_PAGCOM1,0,0 ))  //n_COMIS1
		SC6->C6_COMIS2  := SC6->(u_DefComis(SA1->A1_VEND   ,.T.,SA1->A1_PAGCOM2,0,0 ))  //n_COMIS2
		SC6->C6_COMIS3  := SC6->(u_DefComis(SA1->A1_VENDCOO,.F.,SA1->A1_PAGCOM3,0,0))  //n_COMIS3
		SC6->C6_COMIS4  := SC6->(u_DefComis(SA1->A1_CHEFVEN,.F.,SA1->A1_PAGCOM4,0,0 ))  //n_COMIS4
		SC6->C6_COMIS5  := SC6->(u_DefComis(SA1->A1_GERVEN ,.F.,SA1->A1_PAGCOM5,0,0 ))  //n_COMIS5
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava as informacoes de comissao na tabela xcomis para posterior uso pela Trigger TRI_XCOMIS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SC6->(U_GrvXComis(SC6->C6_FILIAL , SC6->C6_NUM , SC6->C6_ITEM , SC6->C6_COMIS1, SC6->C6_COMIS2 , SC6->C6_COMIS3 , SC6->C6_COMIS4 , SC6->C6_COMIS5))
		
		// Jean Rehermann - Solutio IT - 18/01/2017 - Recalcula o total de descontos e regrava no item do atendimento e do pedido, para garantir
		nTtDscIt := SUA->UA_DESC1 + SUA->UA_DESC2 + SUA->UA_DESC4 + SUA->UA_DESCG + SUB->UB_DESCVEN + SUB->UB_DESCRD
		SUB->( RecLock("SUB",.F.) )
		SUB->UB_TOTDESC := nTtDscIt
		SUB->( MsUnLock() )
		// Fim Jean Rehermann - 18/01/2017
		
		SC6->C6_CUSTEMB := SUB->UB_CUSTEMB
		SC6->C6_PLANILH := SUB->UB_PLANILH
		SC6->C6_PLITEM  := SUB->UB_PLITEM
		SC6->C6_FILTRAN := SUB->UB_FILTRAN
		SC6->C6_ACREREA := SUB->UB_ACRE2		//	FABIANO PEREIRA - SOLUTIO
		SC6->C6_DESCREA := SUB->UB_TOTDESC		//	FABIANO PEREIRA - SOLUTIO
		
		/*
		//Removido em 10/02/2015 em função de que as regras de desconto foram descontinuadas - Rodrigo carvalho - Solutio
		SC6->C6_DESCICM := SUB->UB_DESCICM
		SC6->C6_DESCREA := IIF(nDescReal<0,0,nDescReal)
		SC6->C6_ACREREA := IIF(nDescReal<0,nDescReal*-1,0)
		*/
		
		// SC6->C6_PRCTPAD := nPrcTabBase // FABIANO PEREIRA - SOLUTIO
		SC6->C6_PRCTPAD := SUB->UB_PRCBASE
		SC6->C6_DTINC   := Date()
		SC6->C6_HRINC   := Time()
		SC6->C6_USRINC  := SubStr( cUsuario, 7, 15 )
		SC6->(MsUnlock())
	EndIf
	
	// Jorge Oliveira - 28/02/2011 - Atualiza as comissoes e descontos para as Filiais que trabalham com as
	// Liberacao Comercial utilizando Carta de Negocio. Essa atualizacao serah feita somente uma vez por Pedido !
	/*
	//	RODRIGO SOLUTIO
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
	*/
	
	
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
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  FABIANO PEREIRA - SOLUTIO                               	³
	//³  ATUALIZA ARRAY aATxRN COM NUMERO\ITEM DO PEDIDO DE VENDA	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//				   1           2            3            4             5                         6                            7            8		9    10	 	11
	//			    NUM.ATEND   COD.REGRA   (NEG\COM\DESC) CAMPO BLQ    ITEM ATEND             DESCONTO VENDEDOR               PRODUTO     DESC.RNEG   PV ITEMPV  FLAG
	//Aadd(aATxRN, {M->UA_NUM, aBlq[nX][1], cDescAba,   aBlq[nX][4], aBlq[nX][5], GdFieldGet('UB_DESCVEN', Val(aBlq[nX][5])), aBlq[nX][6], aBlq[nX][7], '','',     ''})
	Do While .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  1 ITEM DO ATENDIMENTO PODE TER MAIS DE UM BLOQUEIO DA REGRA DE NEGOCIO		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos := Ascan(aATxRN, {|X| AllTrim(X[11]) == '' .And. AllTrim(X[1]) == AllTrim(SUB->UB_NUM) .And. AllTrim(X[5]) == AllTrim(SUB->UB_ITEM) })
		If nPos > 0
			aATxRN[nPos][09] := SUB->UB_NUMPV
			aATxRN[nPos][10] := IIF(!Empty(SUB->UB_NUMPV), SUB->UB_ITEMPV, '')
			aATxRN[nPos][11] := 'X'
		Else
			Exit
		EndIf
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  GRAVA NO ARRAY aRetZRN ITEMS DO ATENDIMENTO QUE NAO ENTRARAM NO BLOQ. DA REGRA DE NEGOCIO	|
	//|  CASO ITEM EXISTA NA TABELA DE LOG ZRN ENTAO DELETA REGISTRO								|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Ascan(aATxRN, {|X|  AllTrim(X[1]) == AllTrim(SUB->UB_NUM) .And. AllTrim(X[5]) == AllTrim(SUB->UB_ITEM) }) == 0
		Aadd(aRetZRN, {AllTrim(SUB->UB_NUM), AllTrim(SUB->UB_ITEM) })
	EndIf
	
	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  FABIANO PEREIRA - SOLUTIO                               		³
	//³  ARRAY AUXILIAR aComplRD PARA GRAVAR LOG AT X REGRA DESCONTO	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*
	Aadd(aRegDesc, {'Desc.Cliente', '', '', M->UA_DESC1 })
	Aadd(aRegDesc, {'Desc.RD - Cabec', '', cCodRegra, M->UA_DESC4 })
	Aadd(aRegDesc, {'Desc.Geral', '', '', M->UA_DESCG })
	Aadd(aRegDesc, {'ITEM RD',  n, cCodRegra, nDesconto })
	Aadd(aRegDesc, {'Fiscal', GdFieldGet('UB_ITEM', n), '', nDesconto })
	Aadd(aRegDesc, {'Fiscal', GdFieldGet('UB_ITEM', n), 'Comp.ST', nDesconto })
	Aadd(aRegDesc, {'Fiscal', GdFieldGet('UB_ITEM', n), 'ICMS', nPerDesc })
	*/
	nPosR := Ascan(aRegDesc, {|X| AllTrim(X[02]) == AllTrim(SUB->UB_ITEM) })
	If nPosR > 0
		Aadd(aComplRD, {AllTrim(SUB->UB_ITEM), AllTrim(SUB->UB_PRODUTO), SUB->UB_DESCVEN, SUB->UB_NUMPV, IIF(!Empty(SUB->UB_NUMPV), SUB->UB_ITEMPV, ''), SUB->UB_DESCRD, '' })
	EndIf
	
	SUB->(DbSkip())
	nItemSUB++
EndDo

// Jorge Oliveira - 28/02/2011 - Filial trabalha com Liberacao Comercial utilizando Carta de Negocio
/*
// SOLUTIO
If lCartLib

aCarta[ POS_MARGEM_CARTA ] := U_ValMarg( nMCTot / nTOTTotItemSemIPI * 100 )

// Chama a rotina que irah informar se tem alguma Carta de Negocio que poderah liberar o Pedido
Processa( {|| lOkItem := SUB->( U_A710Carta( aCarta, aProdCarta, @aAvalCom, ( SUA->UA_OPERADO == "055615" ) ) ) }, "Carta de Negócios", "Consultando Cartas de Negócios..." )
lOk := lOkItem

EndIf
*/

//	FABIANO PEREIRA - SOLUTIO
If lOperFat
	
	lPVBloqReg 	:= 	.F.
	lSC6AllLib	:=	.F.
	aAreaAtu 	:=	GetArea()
	DbSelectArea("SC5");DbSetOrder(1);DbGoTop()
	If DbSeek(xFilial("SC5") + SUA->UA_NUMSC5, .F.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  FABIANO PEREIRA - SOLUTIO                               	³
		//³  CASO EXISTIR ALGUM ITEM COM BLOQ.REGRA NAO FORCA LIB.PV 	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lPVBloqReg 	:= 	AllTrim(SC5->C5_BLQ) == '1' 		
		If lPVBloqReg


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ OBSERVACAO: FABIANO PEREIRA - SOLUTIO                  				³
			//³ PV BLOQUEADO APENAS NO C5_BLQ E C6_BLOQUEI COM TODOS OS ITENS DO PV	|
			//| ESTAO LIBERAMOS O C5_BLQ PARA PODER GERAR SC9.						|
			//|																		|
			//| VERIFICAR SE TEM ALGUM ITEM BLOQ NO SC6 (SE NAO TIVER EH PQ O PV 	|
			//|	ESTAVA BLOQ.POR REGRA E AGORA ESTA SAINDO DO BLOQ.DE REGRA			|
		 	//| (EX. USER ADD NOVO ITEM E SAIU DO BLOQ.REGRA)						|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ChkSC6Lib(SC5->C5_FILIAL, SC5->C5_NUM)

				lSC6AllLib 	:= 	.T.
				lPVBloqReg	:=	.F.

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ VERIFICA SE ALGUM ITEM ESTA COM DESCONTO ACIMA DA REGRA.				|
				//|	CASO ITEM EXISTE NA ZRN E C6_BLOQUEI = ' ' FORCA BLOQUEIO NO SC6		|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| QDO BLOQ DE REGRA NO PADRAO TODO OS ITENS VEM COM C6_BLOQUEI = '01'		|
				//| DE QQ MANEIRA VERIFICO ZRN x SC6  (SE C5_BLQ=1 C6_BLOQUEI TEM Q SER =01)|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IIF(Select('TMPC')!=0, TMPC->(DbCloseArea()), )
				cQuery := "	SELECT 	ZRN.ZRN_FILIAL, ZRN.ZRN_NUMAT, ZRN.ZRN_ITEMAT, ZRN.ZRN_PEDIDO, ZRN.ZRN_ITEMPV, ZRN.ZRN_PRODUT, 	"+ENTER
				cQuery += "			ZRN.ZRN_TPBLQ, ZRN.ZRN_VENDA,  ZRN.ZRN_REGRA,  ZRN.ZRN_CODRN,  ZRN.ZRN_TPBLQ,  ZRN.ZRN_CPOBLQ,	"+ENTER
				cQuery += "			SC6.C6_BLOQUEI, SC6.R_E_C_N_O_ AS SC6RECNO														"+ENTER+ENTER
			
				cQuery += " FROM 	"+RetSqlName("ZRN")+" ZRN   											   	"+ENTER
				cQuery += "										INNER JOIN "+RetSqlName("SC6")+" SC6 			"+ENTER
				cQuery += "										ON 	SC6.C6_FILIAL 	 = 	ZRN.ZRN_FILIAL			"+ENTER
				cQuery += "										AND SC6.C6_NUM 		 =  ZRN.ZRN_PEDIDO			"+ENTER
				cQuery += "										AND SC6.C6_ITEM 	 = 	ZRN.ZRN_ITEMPV			"+ENTER
				cQuery += "										AND SC6.C6_PRODUTO 	 = 	ZRN.ZRN_PRODUT			"+ENTER
				cQuery += "										AND SC6.C6_BLOQUEI	 =  '  '					"+ENTER
				cQuery += "										AND SC6.D_E_L_E_T_ 	!= 	'*' 					"+ENTER+ENTER

				cQuery += " WHERE 	ZRN.ZRN_FILIAL 	=  '"+SUA->UA_FILIAL+"' 	"+ENTER
				cQuery += " AND 	ZRN.ZRN_PEDIDO 	=  '"+SUA->UA_NUMSC5+"'		"+ENTER
				cQuery += " AND 	ZRN.D_E_L_E_T_ !=  '*' 						"+ENTER+ENTER
			
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPC', .F., .T.)
				DbSelectArea('TMPC');DbGoTop()
				Do While !Eof()   
				
                	lSC6AllLib 	:= 	.F.
					lPVBloqReg	:=	.T.
				                    
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³  	BLOQUEIA SC6 	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SC6Bloqueia(TMPC->ZRN_PEDIDO, TMPC->ZRN_ITEMPV)
	
					DbSelectArea('TMPC')
					DbSkip()
				EndDo

			EndIf

		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ VERIFICA SE C5_BLQ = ' ' e C6_BLOQUEI = '  '				³
			//| CASO ALGUM ITEM BLOQUEADO NO SC6 VERIFICA SE EXISTE SC9		|
			//| SENAO TEM SC9 BLOQUEIA P C5_BLQ								|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
		EndIf

	EndIf
	RestArea(aAreaAtu)
	
	
	IF SC5->C5_LIBREPR = "S" // Libera quando o pedido estiver macado para reprocesso  - Marca Pedido
		lOk := .T.
	ENDIF
	
	//| ANALISTA:CRISTIANO MACHADO CHAMADO:AAZS0B     SOLICITANTE: JULIANO       DESCRICAO: INFLUENCIAVA NA LIBERACAO DE CREDITO    DATA: 02/06/2010
	//| O pedido passou pela liberacao comercial, devo gerar o SC9
	
	If lOk .And. !lPVBloqReg		//	FABIANO PEREIRA - SOLUTIO [ VERIFICA SE PV TEM BLOQ. REGRA ]
		dbSelectArea("SC5")
		dbSetOrder(1)
		DbSeek(xFilial("SC5")+SUA->UA_NUMSC5)
		//| Adicionado Flag para liberar o pedido qdo ele passa pela liberação comercial  // MQB 06/10/2005
		// ANALISTA:CRISTIANO MACHADO CHAMADO:AAZS0B     SOLICITANTE: JULIANO       DESCRICAO: INFLUENCIAVA NA LIBERACAO DE CREDITO    DATA: 02/06/2010
		If Found()
			Reclock("SC5",.F.)
				SC5->C5_LIBEROK := "S"
				SC5->C5_LIBERAD := SF4->(RetCodUsr())
				If lSC6AllLib
					SC5DesBlq(SC5->C5_NUM, .T.)
				EndIf
			MsUnlock()
		Endif
		//---fim da flag
		SC6->(dbSetOrder(1))		// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM,.F.))
		SA1->( dbSeek(xFilial('SA1')+SC6->C6_CLI+SC6->C6_LOJA) )
		
		DbSelectArea('SC6')
		Do While !Eof() .And. xFilial('SC6') == SC6->C6_FILIAL .And. SC5->C5_NUM == SC6->C6_NUM

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Parametros³ExpN1: Registro do SC6                                      ³
			³          ³ExpN2: Quantidade a Liberar                                 ³
			³          ³ExpL3: Bloqueio de Credito                                  ³
			³          ³ExpL4: Bloqueio de Estoque                                  ³
			³          ³ExpL5: Avaliacao de Credito                                 ³
			³          ³ExpL6: Avaliacao de Estoque                                 ³
			³          ³ExpL7: Permite Liberacao Parcial                            ³
			³          ³ExpL8: Transfere Locais automaticamente                     ³
			³          ³ExpA9: Empenhos ( Caso seja informado nao efetua a gravacao ³
			³          ³       apenas avalia ).                                     ³
			³          ³ExpbA: CodBlock a ser avaliado na gravacao do SC9           ³
			³          ³ExpAB: Array com Empenhos previamente escolhidos            ³
			³          ³       (impede selecao dos empenhos pelas rotinas)          ³
			³          ³ExpLC: Indica se apenas esta trocando lotes do SC9          ³
			³          ³ExpND: Valor a ser adicionado ao limite de credito          ³
			³          ³ExpNE: Quantidade a Liberar - segunda UM                    ³
			ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			*/

			Begin Transaction

				lCredito	:=	.F.
				lEstoque	:=	.F.
				lAvalCre 	:= 	.T.
				lAvalEst 	:= 	.T.
				lLibParc	:=	.F.
				lTrfLocal	:=	.F.
				cDocRes		:=	PadR(AllTrim(SC6->C6_NUM+SC6->C6_ITEM), TamSx3('C0_DOCRES')[01])

				If ExecBlock('ChkResxSld', .F., .F., {cFilAnt, cDocRes, SC6->C6_PRODUTO})
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|	NAO VERIFICAR ESTOQUE QUANDO CORREIA TEM RESERVA				|
					//| OCORRENCIA DE BLOQUEIO DE ESTOQUE QDO ATENDIMENTO TEM RESERVA	|
					//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
					//| EX.:															|
					//| AO GRAVAR AT COM PRODUTO CORREIA, COM SALDO, Eh GRAVADO RESERVAS|
					//| Eh RESERVADO PARA QUE OUTRO VENDEDOR NAO "ROUBE" O SALDO		|
					//| AO BUSCAR AT VIA F10 E CONFIRMA O SISTEMA IRA BLOQUEAR O ITEM	|
					//| CORREIA PQ O SISTEMA IDENTIFICA INDEVIDAMENTE QUE NAO TEM SALDO	|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lEstoque	:=	.T.
					lAvalEst 	:= 	.F.
				EndIf
			
				//				[01]			[02]		[03]      [04]    [05]     [06]    [07]    [08][09][10][11][12][13][14]

				MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,lCredito,lEstoque,lAvalCre,lAvalEst,lLibParc,lTrfLocal,Nil,Nil,Nil,Nil,Nil,0)
				//MaLibDoFat(nRegSC6  ,nQtdaLib,lCredito,lEstoque,lAvCred,lAvEst,lLibPar,lTrfLocal,aEmpenho,bBlock,aEmpPronto,lTrocaLot,lGeraDCF,nVlrCred,nQtdalib2)

				//				[01]			[02]		  [03] [04][05] [06] [07]  [08][09][10][11][12][13][14]
				//MaLibDoFat(SC6->(RecNo()), SC6->C6_QTDVEN, .F., .F., .T., .T., .F., .F.)

			End Transaction
			
			DbSelectArea('SC6')
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
				xaCab := {	{'C5_NUM'      ,SUA->UA_NUMSC5      , },;
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
					Dbskip()
				End
				MSExecAuto({|w,x,y| Mata410(w,x,y)},xaCab,xaIt,4)
				If lMsErroAuto
					Mostraerro()
				Endif
			Endif
		EndIf
	EndIf
	
	dbSelectArea('SC5')
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia a transacao de inclusao do pedido de vendas  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Begin Transaction


If lOperFat
	// Inicio - 07/05/2003
	If lGeraSZE
		// inicio a geracao da planilha de transferecia
		// quem vai distribuir eh a filial que vai enviar a mercadoria
		// backup
		__aCols := aClone(aCols)
		__aHead := aClone(aHeader)
		__cFil  := cFilAnt
		// Jean Rehermann - Solutio IT - 19/11/2015 - Salvo a área fiscal antes de gerar planilha e pedido de transferência
		MaFisSave()
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
				SC6->C6_PLITEM 	:= aSZE[nSZE,2,ncItem,X_ZE_ITEM]   	 	// SZE->ZE_ITEM
                If !Empty(SC6->C6_PLANILH)
					Aadd(aPTransf, {SC6->C6_NUM, SC6->C6_ITEM, SC6->C6_PRODUTO, SC6->C6_PLANILH, SC6->C6_PLITEM})
				EndIf
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
		
		// Fabiano Pereira\Gean -Solutio IT - 19/11/2015 - Restauro a área fiscal após gerar planilha e pedido de transferência
		MaFisRestore()
		aHeader := __aHead
		aCols   := __aCols
	EndIf
EndIf

nIMCTot 	:= U_ValMarg(nMCTot   / nTOTTotItemSemIPI * 100)
//nIMCgTot	:= U_ValMarg(nMCgTot  / nTOTTotItemSemIPI * 100)    //	RODRIGO SOLUTIO
nIMCRTot	:= U_ValMarg(nMCRTot  / nTOTTotItemSemIPI * 100)
//nIMCUCTot	:= U_ValMarg(nMCUCTot / nTOTTotItemSemIPI * 100)	//	RODRIGO SOLUTIO

//	FABIANO PEREIRA - SOLUTIO
If lOperFat
	
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
		If lTemGuia
		   SC5->C5_PEDGUIA:='1'
		Endif   
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Libera o Pedido³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lOk
			SC5->C5_LIBEROK := "S"
			SC5->C5_LIBERAD := SF4->(RetCodUsr())
			/*
			Else
			// removido em 10/02/2015 em função de que o processo carta de negocio foi descontinuado - Rodrigo Carvalho - Solutio
			// Jorge Oliveira - 28/02/2011 - Projeto Carta Negocios
			SC5->C5_LIBEROK := " "
			SC5->C5_LIBERAD := Space( 6 )
			*/
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
	
EndIf




// Rodrigo - Solutio - 18/06/2015 - grava totais de IMC e IMCR na tabela SUA, cabeçalho do atendimento
DbSelectArea("SUA")
RecLock("SUA",.F.)
	SUA->UA_IMC		:= nIMCTot
	SUA->UA_IMCR  	:= nIMCRTot
MsUnlock()



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  FABIANO PEREIRA - SOLUTIO            			³
//³  ATUALIZA LOG ATENDIMENTO X REGRA DE NEGOCIO	³
//|  1o GRAVA LOG(ZRN) 								|
//|  2o GRAVA BLOQUEIOS								|
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//|*** OBS.: BLOQUEIOS VERIFICA ZRN	                |
//|			 EXECUTAR ANTESLogRegNeg				|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*********************
	LogRegNeg()
*********************
aRegDesc	:= {}	//	REGRA DE DESCONTO
aATxRN	 	:= {}	//	ATENDIMENTO X REGRA DE NEGOCIO


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|						B L O Q U E I O   D E   R E G R A S 							|
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³  18/06/2015  - RODRIGO SOLUTIO                                                      |
//|  VERIFICACAO DE IMC NO ITEM DO ATENDIMENTO E COMPARACAO COM A CURVA 				³
//³  DO PRODUTO PARA ALTERAR O TIPO DE BLOQUEIO DO PEDIDO      							³
//³  CASO A MARGEM FIQUE NEGATIVA OU INFERIOS à MíNIMA CADASTRADA NA TABELA DE CURVAS.	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOperFat
	
	cTabPrc	 	:= 	' '
	cTabCli 	:= 	' '
	cTabPV		:=	' '
	aPVBlq   	:= 	{}

	
	IIF(!ExisteSX6('IMD_TMIMC'),	CriarSX6('IMD_TMIMC', 'L','Bloq.Trava Master por IMC - FT210OPC.PRW', 	'.T.' ),)
	lMvIMC_TM := GetMv('IMD_TMIMC')
	IIF(!ExisteSX6('IMD_TMIMCR'),	CriarSX6('IMD_TMIMCR', 'L','Bloq.Trava Master por IMCR - FT210OPC.PRW', '.F.' ),)
	lMvIMCR_TM := GetMv('IMD_TMIMCR')
	IIF(!ExisteSX6('IMD_IMCOUR'),	CriarSX6('IMD_IMCOUR', 'L','Bloq.Trava Master por IMC OU IMCR - FT210OPC.PRW', '.F.' ),)
	lIMCouIMCR := GetMv('IMD_IMCOUR')

	IIF(!ExisteSX6('IMD_MINIMC'),	CriarSX6('IMD_MINIMC', 'N','Valor minimo IMC  - PE_TMKVFIM.PRW', '-10'),)
    nMvImcMin 	:=	GetMv('IMD_MINIMC')				// 0 \-10
	IIF(!ExisteSX6('IMD_MIIMCR'),	CriarSX6('IMD_MIIMCR', 'N','Valor minimo IMCR - PE_TMKVFIM.PRW', '-10'),)
    nMvImcRMin	:=	GetMv('IMD_MIIMCR')				// 0 \-10
	
	
 	If SUA->UA_NUMSC5 != SC5->C5_NUM
    	DbSelectArea('SC5');DbSetOrder(1)		// C5_FILIAL+C5_NUM
 		DbSeek(xFilial('SC5') + SUA->UA_NUMSC5, .F.)
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|	TABELA DE PRECO - PEDIDO	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTabPV	:=	SC5->C5_TABELA
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|	VERIFICA SE CLIENTE TEM TABELA DE PRECO EXCLUSIVA	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If SA1->A1_COD+SA1->A1_LOJA != SC5->C5_CLIENTE+SC5->C5_LOJACLI
		DbselectArea("SA1");DbSetOrder(1);DbGoTop()
		If DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, .F.)
			cTabCli := SA1->A1_TABELA
        EndIf
    Else
		cTabCli := SA1->A1_TABELA    
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|	lChkLogZRN = VARIAVEL PARA CONTROLE SE ATUALIZA LOG (ZRN)	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lChkLogZRN := IIF(SC5->C5_BLQ == '1' .And. Empty(SC5->C5_LIBRNV1), .F., .T.)	


	aTabelas 	:= 	&(GetMv('MV_SEGXTAB'))		//	{{"1","OEM"},{"2","MNT"},{"3","REV"}}
	nPosTab 	:= 	Ascan(aTabelas, {|X| X[2] == SC5->C5_TABELA })
	If nPosTab > 0
		cTabPrc := 	SC5->C5_TABELA
    Else

		DbselectArea("SA1");DbSetOrder(1);DbGoTop()
		If DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, .F.)
			cSegmento  	:= 	SubStr(SA1->A1_GRPSEG,3,1)
			nPosTab 	:= 	Ascan(aTabelas, {|X| X[1] == cSegmento })
			cTabPrc 	:= 	IIF(nPosTab > 0, aTabelas[nPosTab][02], '')
		EndIf

	EndIf

	
	IIF(Select('TMPV')!=0, TMPV->(DbCloseArea()), )
	cQuery := "	SELECT 	SUB.UB_PRODUTO, SB1.B1_DESC,	SB1.B1_OBSTPES, 						"+ENTER
	cQuery += "			SUB.UB_NUM, 	SUB.UB_ITEM, 	SUB.UB_ITEMPV,  SUB.UB_PRODUTO,			"+ENTER
	cQuery += "			SUB.UB_IMC, 					SUB.UB_IMCR,	SUB.UB_IMCG,			"+ENTER
	cQuery += "			ZGV.ZGV_IMCMIN RGV_IMCMIN, 		ZGV.ZGV_IMCRMI  RGV_IMCRMIN, 			"+ENTER
	cQuery += "			ZGV.ZGV_VLRMIN RGV_VLRMIN, 												"+ENTER
	cQuery += "			(IM1.IM1_IMCMIN * 100) MKP_IMCMIN,										"+ENTER
	cQuery += "			(IM1.IM1_TRAVAM * 100) TRAVAM,											"+ENTER
	cQuery += "			SUB.UB_TABPRC, SUB.UB_PRCTAB, 											"+ENTER
	cQuery += "			SUB.UB_VRCACRE, SUB.UB_VRUNIT, SUB.UB_PRCBASE							"+ENTER+ENTER

	cQuery += "	FROM "+RetSqlName("SUB")+"  SUB  												"+ENTER+ENTER

	cQuery += "									INNER JOIN "+RetSqlName("ZGV")+" ZGV 			"+ENTER
	cQuery += "									ON 	ZGV.ZGV_FILIAL 	 = '"+xFilial("ZGV")+" '	"+ENTER
	cQuery += "									AND ZGV.ZGV_GV 		 =  SUB.UB_FILIAL	 		"+ENTER
	cQuery += "									AND ZGV.ZGV_TABELA 	 = 	'"+cTabPrc+"' 			"+ENTER
	cQuery += "									AND ZGV.D_E_L_E_T_ 	!= 	'*' 					"+ENTER+ENTER
	
	cQuery += " 								INNER JOIN "+RetSqlName("SB1")+" SB1 			"+ENTER
	cQuery += " 								ON  SB1.B1_FILIAL 	=  SUB.UB_FILIAL		 	"+ENTER
	cQuery += " 								AND SB1.B1_COD 		=  SUB.UB_PRODUTO 			"+ENTER
	cQuery += " 								AND SB1.D_E_L_E_T_ !=  '*' 						"+ENTER+ENTER
	
	cQuery += " 								INNER JOIN "+RetSqlName("IM1")+" IM1 			"+ENTER
	cQuery += " 								ON  IM1.IM1_FILIAL 	=  SUB.UB_FILIAL		 	"+ENTER
	cQuery += " 								AND IM1.IM1_COD 	=  SB1.B1_CURVA 			"+ENTER
	cQuery += " 								AND IM1.IM1_SEGMEN 	=  '"+cTabPrc+"' 			"+ENTER
	cQuery += " 								AND IM1.D_E_L_E_T_ !=  '*' 						"+ENTER+ENTER

	cQuery += "	WHERE SUB.UB_FILIAL  = '"+SUA->UA_FILIAL+"' 	"+ENTER
	cQuery += "	AND SUB.UB_NUM 		 = '"+SUA->UA_NUM+"' 		"+ENTER
	cQuery += "	AND SUB.D_E_L_E_T_ 	!= '*'  					"+ENTER
	
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPV', .F., .T.)
		
	
	DbSelectArea("TMPV");DbGoTop()
	Do While !Eof()

		lChkIMC := 	.T.
		lDelZRN	:= 	.T.
		lTravaM	:=	.F.
		lPromo	:=	Left(TMPV->B1_OBSTPES,1) == 'P'


	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³***  BUSCA VALOR DA TRAVA MASTER NA TABELA IM1	*** ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		nMvImcMin := TMPV->TRAVAM
		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  VERIFICA SE EXISTE DESCONTO ACIMA DO PERMITIDO                     |
		//|	(SE ZRN_TPBLQ = DESCONTO EH PQ DESCONTO ESTA ACIMA DO PERMITIDO)	³
		//³  UTILIZADO QUERY PQ PODE HAVER + REGISTROS NA TABELA ZRN            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IIF(Select('TMPD')!=0, TMPD->(DbCloseArea()), )
		cQuery := "	SELECT 	ZRN.ZRN_FILIAL, ZRN.ZRN_NUMAT, ZRN.ZRN_ITEMAT, ZRN.ZRN_PEDIDO, ZRN.ZRN_ITEMPV, ZRN.ZRN_PRODUT, 	"+ENTER
		cQuery += "			ZRN.ZRN_TPBLQ, ZRN.ZRN_VENDA,  ZRN.ZRN_REGRA,  ZRN.ZRN_CODRN, ZRN.ZRN_TPBLQ, ZRN.ZRN_CPOBLQ		"+ENTER+ENTER
	
		cQuery += " FROM 	"+RetSqlName("ZRN")+" ZRN   			   	"+ENTER
		cQuery += " WHERE 	ZRN.ZRN_FILIAL 	=  '"+SUA->UA_FILIAL+"' 	"+ENTER
		cQuery += " AND 	ZRN.ZRN_NUMAT 	=  '"+TMPV->UB_NUM+"'		"+ENTER
		cQuery += " AND 	ZRN.ZRN_ITEMAT 	=  '"+TMPV->UB_ITEM+"'		"+ENTER
		cQuery += " AND 	ZRN.ZRN_PRODUT 	=  '"+TMPV->UB_PRODUTO+"' 	"+ENTER
		cQuery += " AND 	UPPER(RTRIM(ZRN.ZRN_TPBLQ)) =  'DESCONTOS'	"+ENTER
		cQuery += " AND 	ZRN.ZRN_VENDA 	>  ZRN.ZRN_REGRA 			"+ENTER
		cQuery += " AND 	ZRN.D_E_L_E_T_ !=  '*' 						"+ENTER+ENTER
	
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPD', .F., .T.)
		nCount := 0
		TMPD->(DbGoTop())
		TMPD->(dbEval({||nCount++},,,1 ))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|  VERIFICA SE DESCONTO DENTRO DA ALCADA	  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        lDescOK 	:=	IIF(nCount==0, .T., .F.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|	 [ VERSAO ANTIGA ] 																|
		//|  SE PRODUTO ESTA EM PROMO E DESCONTO DENTRO DA ALCADA [ NAO ] VERIFICA IMC\IMCR	|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lChkIMC  :=	IIF(lPromo, IIF(nCount==0, .F., .T.), .T.)
			



		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|																			|
		//| PARA CLIENTES COM TABELA DE PRECO EXCLUSIVA NAO VERIFICAR VALIDACOES	|
		//| PROCESSA VALIDACOES QDO PRC.VENDA > PRC.TAB								|
		//|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
		//| VERIFICA TAB.PRECO DO AT. PQ A TAB. CADASTRADA NO CLIENTE PODE ESTAR 	|
		//| FORA DE VIGENCIA ou USUARIO ALTEROU A TAB.PRECO NO ATENDIMENTO			|
		//|																			|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosTab 	:= 	Ascan(aTabelas, {|X| AllTrim(X[2]) == AllTrim(cTabPV) }) //	{{"1","OEM","INDUSTRIA"},{"2","MNT","MANUTENCAO"},{"3","REV","REVENDA"}}
		lCliTab 	:= 	IIF(nPosTab > 0, .F., 	IIF(cTabPV == TMPV->UB_TABPRC, .T., .F.))
		nItPreco	:=	TMPV->UB_VRCACRE
		nPrcTab		:=	TMPV->UB_PRCTAB
        
		If !lCliTab
	    	lChkRegra := .T.
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|  ATUALIZA PRECO TABELA + IMPOSTOS   | 
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPosProd	:=	Ascan(aProdxImp, {|X| AllTrim(X[01]) == AllTrim(TMPV->UB_ITEM) .And. AllTrim(X[02]) == AllTrim(TMPV->UB_PRODUTO) })
			nVlrImp 	:=	IIF(nPosProd > 0, aProdxImp[nPosProd][21], 0)		//	[21] SOMA ALIQUOTAS IMPOSTOS
			nPrcTab		:=	NoRound(nPrcTab/ ((100 - nVlrImp) / 100), 02)
			lChkRegra 	:=	IIF(nItPreco > nPrcTab,  .F., .T.)
		EndIf
            			


		If lDescOK .And. lChkRegra

			If !lPromo 

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| 		-->   R E G R A   B L O Q U E I O   <--  				|
				//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
				//| GetMv('IMD_TMIMC') 	- VERIFICA TRAVA MASTER POR IMC            	|
				//| GetMv('IMD_TMIMCR')	- VERIFICA TRAVA MASTER POR IMCR			|
				//|	GetMv('IMD_IMCOUR')	- VERIFICA IMC OU IMCR						|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³    X5_TABELA = 'GV'    					³
				//³	BLMRG1 - IMC Negativo 					³
				//³	BLMRG2 - IMC Item     					³
				//³	BLMRG3 - IMC Pedido   					³
				//³	BLMRG4 - IMCR Negativo					³
				//³	BLMRG5 - IMCR Item    					³
				//³	BLMRG6 - IMCR Pedido  					³
				//³	BLMRG7 - IMC e  IMCR Negativo  			³
				//³	BLMRG8 - IMC ou IMCR Negativo  			³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If lIMCouIMCR
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| TRAVA MASTER VERIFICA IMC -> OU <- IMCR		|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If TMPV->UB_IMC < nMvImcMin .Or. TMPV->UB_IMCR < nMvImcRMin
						cCodRegra 	:= 	'BLMRG8'
						cBlqImc		:=	'!lPromo e  IMC PROD.   [ '+cValToChar(TMPV->UB_IMC)+' ]   MENOR QUE TRAVA MASTER  [ '+cValToChar(nMvImcMin)+'  ]  -  '+cCodRegra
						cBlqImcR	:=	'!lPromo e  IMCR PROD.  [ '+cValToChar(TMPV->UB_IMCR)+' ]  MENOR QUE TRAVA MASTER  [ '+cValToChar(nMvImcRMin)+' ]  -  '+cCodRegra
													
						lDelZRN := .F.
						Aadd(aPVBlq,  {SUA->UA_NUM, TMPV->UB_ITEM, SUA->UA_NUMSC5, TMPV->UB_ITEMPV, TMPV->UB_PRODUTO, cCodRegra, 'Item PV', nMvImcMin,  TMPV->UB_IMC,  AllTrim(TMPV->B1_DESC), cBlqImc  })
						Aadd(aPVBlq,  {SUA->UA_NUM, TMPV->UB_ITEM, SUA->UA_NUMSC5, TMPV->UB_ITEMPV, TMPV->UB_PRODUTO, cCodRegra, 'Item PV', nMvImcRMin, TMPV->UB_IMCR, AllTrim(TMPV->B1_DESC), cBlqImcR })
					EndIf
				                             
				
				Else
		
					If lMvIMC_TM .And. lMvIMCR_TM
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| TRAVA MASTER - IMC -> E <- IMCR	Negativo	|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If	TMPV->UB_IMC < nMvImcMin .And. TMPV->UB_IMCR < nMvImcRMin
							cCodRegra 	:= 	'BLMRG7'
							cBlqImc		:=	'!lPromo e  IMC PROD.   [ '+cValToChar(TMPV->UB_IMC)+' ]   MENOR QUE TRAVA MASTER  [ '+cValToChar(nMvImcMin)+'  ]  -  '+cCodRegra
							cBlqImcR	:=	'!lPromo e  IMCR PROD.  [ '+cValToChar(TMPV->UB_IMCR)+' ]  MENOR QUE TRAVA MASTER  [ '+cValToChar(nMvImcRMin)+' ]  -  '+cCodRegra
														
							lDelZRN := .F.
							Aadd(aPVBlq,  {SUA->UA_NUM, TMPV->UB_ITEM, SUA->UA_NUMSC5, TMPV->UB_ITEMPV, TMPV->UB_PRODUTO, cCodRegra, 'Item PV', nMvImcMin,  TMPV->UB_IMC,  AllTrim(TMPV->B1_DESC), cBlqImc  })
							Aadd(aPVBlq,  {SUA->UA_NUM, TMPV->UB_ITEM, SUA->UA_NUMSC5, TMPV->UB_ITEMPV, TMPV->UB_PRODUTO, cCodRegra, 'Item PV', nMvImcRMin, TMPV->UB_IMCR, AllTrim(TMPV->B1_DESC), cBlqImcR })
						EndIf

					ElseIf lMvIMC_TM
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| TRAVA MASTER - IMC Negativo		|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If TMPV->UB_IMC < nMvImcMin
							cCodRegra 	:= 	'BLMRG1'
							nVenda		:=	TMPV->UB_IMC
							nRegra		:=	nMvImcMin
							cCondBlq	:=	'!lPromo e  IMC PROD.  [ '+cValToChar(TMPV->UB_IMC)+' ]  MENOR QUE TRAVA MASTER  [ '+cValToChar(nMvImcMin)+'  -  '+cCodRegra
							lDelZRN 	:= 	.F.
							Aadd(aPVBlq, {SUA->UA_NUM, TMPV->UB_ITEM, SUA->UA_NUMSC5, TMPV->UB_ITEMPV, TMPV->UB_PRODUTO, cCodRegra, 'Item PV', nRegra, nVenda, AllTrim(TMPV->B1_DESC), cCondBlq})
						EndIf

					ElseIf lMvIMCR_TM
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| TRAVA MASTER - IMCR	Negativo	|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If TMPV->UB_IMCR < nMvImcRMin
							cCodRegra 	:=	'BLMRG4'
							nVenda		:=	TMPV->UB_IMCR
							nRegra		:=	nMvImcRMin
							cCondBlq	:=	'!lPromo e  IMCR PROD.  [ '+cValToChar(TMPV->UB_IMCR)+' ]  MENOR QUE TRAVA MASTER  [ '+cValToChar(nMvImcRMin)+'  -  '+cCodRegra
							lDelZRN 	:= 	.F.
							Aadd(aPVBlq, {SUA->UA_NUM, TMPV->UB_ITEM, SUA->UA_NUMSC5, TMPV->UB_ITEMPV, TMPV->UB_PRODUTO, cCodRegra, 'Item PV', nRegra, nVenda, AllTrim(TMPV->B1_DESC), cCondBlq})
						EndIf

		            Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| TODOS OS PARAMETROS COMO FALSO - NAO VERIFICA TRAVA MASTER	|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					EndIf
		
				EndIf

			EndIf

		EndIf
        
        

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  VERIFICA SE REGISTRO COM BLOQUEIO 'BLMRG' EXISTE NA ZRN E DELETA	³
		//|  QDO lChkLogZRN == .F. Eh A PRIMEIRA INCLUSAO 						|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lDelZRN .And. lChkLogZRN
			DelZRNLog(SUA->UA_NUM, TMPV->UB_ITEM, SUA->UA_NUMSC5, TMPV->UB_ITEMPV)
		EndIf


		IIF(Select('TMPD')!=0, TMPD->(DbCloseArea()), )
		DbSelectArea("TMPV")
		DbSkip()
	
	EndDo


	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  VERIFICA BLOQUEIOS SC9\SC5\SC6\ZRN		|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aPVBlq) > 0

		Begin Transaction 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  ESTORNA SC9 \ BLOQUEIA SC5    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SC9Estorna(SUA->UA_NUMSC5)
		SC5Bloqueia(SUA->UA_NUMSC5)

		aMsgBlq := {}
		cMsg 	:= ''
		For nY:=1 To Len(aPVBlq)
			cTexto 	:= 	''

			/*					[01]			[02]        	  [03]			[04]		 	  [05]
			Aadd(aPVBlq,  {	SUA->UA_NUM,   TMPV->UB_ITEM,   SUA->UA_NUMSC5, TMPV->UB_ITEMPV, TMPV->UB_PRODUTO,	
							cCodRegra, 	  (Pedido\Item PV),		nRegra, 		nVenda,		 TMPV->B1_DESC,		cCondBlq })			
	  							[06]			[07]			  [08]			[09]			  [10]			  [11]
			*/
			
			cNumAT		:=	aPVBlq[nY][01]
			cItemAT		:=	aPVBlq[nY][02]
			cNumPV		:=	aPVBlq[nY][03]
			cItemPV		:=	aPVBlq[nY][04]
			cProduto	:=	aPVBlq[nY][05]
			cCodRegra	:=	aPVBlq[nY][06]
			cTpBloq		:=	aPVBlq[nY][07]
			nRegra		:=	aPVBlq[nY][08]
			nVenda		:=	aPVBlq[nY][09]
			cDescri		:=	aPVBlq[nY][10]
			cCondBlq	:=	aPVBlq[nY][11]
						
			If cCodRegra $ 'BLMRG1\BLMRG4'
				cTexto := 'MARGEM ABAIXO DA TRAVA MASTER '+IIF(cCodRegra=='BLMRG1','[ IMC ]',' [ IMCR ]') 
			ElseIf cCodRegra $ 'BLMRG2\BLMRG5'
				cTexto := 'PRODUTO COM MARGEM ABAIXO DO MÍNIMO PERMITIDO '+IIF(cCodRegra=='BLMRG2','[ IMC ]',' [ IMCR ]') 
			ElseIf cCodRegra $ 'BLMRG3\BLMRG6'
				cTexto := 'PEDIDO COM MARGEM ABAIXO DO MÍNIMO PERMITIDO '+IIF(cCodRegra=='BLMRG3','[ IMC ]',' [ IMCR ]') 
			EndIf

			cMsg += cTexto +ENTER
			Aadd(aMsgBlq,{cNumAT, cItemAT, cNumPV, cItemPV, cProduto, cDescri, cCodRegra, cTpBloq, nRegra, nVenda, cTexto, cCondBlq })

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  BLOQUEIA SC6  \ GRAVA LOG     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SC6Bloqueia(cNumPV, cItemPV)
        	ZRNGravaLog(cNumAT, cItemAT, cCodRegra, cTpBloq, nRegra, nVenda, cProduto, cNumPV, cItemPV)

		Next

		End Transaction


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  TELA COM BLOQUEIO IMC \ IMCR  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//IIF(!Empty(cMsg), MsgAlert(cMsg,'TMKVFIM'),)
		IIF(Len(aMsgBlq)>0, TelaBloq(aMsgBlq),)


	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ OBS.: BLOQUEIO DE REGRA DE NEGOCIO (DESC\COM\NEG)                	|
		//|		  POR PADRAO JA ESTA COM FLAGs (C5_BLQ e C6_BLOQUEI)			³
		//|		  (JA GRAVADOS NA TAB. ZRN VIA ROTINA LogRegNeg())				|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ NENHUM ITEM ESTA NA REGRA DE NEGOCIO -> LIBERA DO BLOQUEIO SC5\SC6	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea('ZRN');DbSetOrder(1)	//	ZRN_FILIAL + ZRN_NUMAT + ZRN_ITEMAT  + ZRN_CODRN
		If !DbSeek(xFilial('ZRN')+ SUA->UA_NUM, .F.)
			Begin Transaction 
			 SC5DesBlq(SUA->UA_NUMSC5)
			 SC6DesBlq(SUA->UA_NUMSC5)
			End Transaction
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ EXISTE ALGUM ITEM BLOQUEADO(ZRN) PELA REGRA DE NEGOCIO E CAMPOS DE BLOQUEIO EM BRANCO						|
			//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
			//³ OCORRENCIA: C5_BLQ == '1'.And.Empty(C5_LIBRNV1) QDO PV COM APENAS BLOQUEIO DE REGRA DE NEGOCIO NO PADRAO	³
			//| SOLUCAO:	FORCA BLOQUEIO NOS CAMPOS CUSTOMIZADOS C5_LIBRNV1,2,3											|
			//|				C6_BLOQUEI E LOG->ZRN JA ESTAO GRAVADOS															|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea('SC5');DbSetOrder(1)		// C5_FILIAL+C5_NUM
			If DbSeek(xFilial('SC5') + SUA->UA_NUMSC5, .F.)
				If SC5->C5_BLQ == '1' .And. Empty(SC5->C5_LIBRNV1)
					
					Begin Transaction 
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³  ESTORNA SC9 \ BLOQUEIA SC5    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SC9Estorna(SUA->UA_NUMSC5)
						SC5Bloqueia(SUA->UA_NUMSC5)
			
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ NAO Eh NECESSARIO ATUALIZA SC6											|
						//| QDO BLOQ DE REGRA NO PADRAO TODO OS ITENS VEM COM C6_BLOQUEI = '01'		|
						//|																			|
						//| DE QQ MANEIRA VERIFICO ZRN x SC6  (SE C5_BLQ=1 C6_BLOQUEI TEM Q SER =01)|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						IIF(Select('TMPC')!=0, TMPC->(DbCloseArea()), )
						cQuery := "	SELECT 	ZRN.ZRN_FILIAL, ZRN.ZRN_NUMAT, ZRN.ZRN_ITEMAT, ZRN.ZRN_PEDIDO, ZRN.ZRN_ITEMPV, ZRN.ZRN_PRODUT, 	"+ENTER
						cQuery += "			ZRN.ZRN_TPBLQ, ZRN.ZRN_VENDA,  ZRN.ZRN_REGRA,  ZRN.ZRN_CODRN,  ZRN.ZRN_TPBLQ,  ZRN.ZRN_CPOBLQ,	"+ENTER
						cQuery += "			SC6.C6_BLOQUEI, SC6.R_E_C_N_O_ AS SC6RECNO														"+ENTER+ENTER
					
						cQuery += " FROM 	"+RetSqlName("ZRN")+" ZRN   											   	"+ENTER
						cQuery += "										INNER JOIN "+RetSqlName("SC6")+" SC6 			"+ENTER
						cQuery += "										ON 	SC6.C6_FILIAL 	 = 	ZRN.ZRN_FILIAL			"+ENTER
						cQuery += "										AND SC6.C6_NUM 		 =  ZRN.ZRN_PEDIDO			"+ENTER
						cQuery += "										AND SC6.C6_ITEM 	 = 	ZRN.ZRN_ITEMPV			"+ENTER
						cQuery += "										AND SC6.C6_PRODUTO 	 = 	ZRN.ZRN_PRODUT			"+ENTER
						cQuery += "										AND SC6.C6_BLOQUEI	 =  '  '					"+ENTER
						cQuery += "										AND SC6.D_E_L_E_T_ 	!= 	'*' 					"+ENTER+ENTER

						cQuery += " WHERE 	ZRN.ZRN_FILIAL 	=  '"+SUA->UA_FILIAL+"' 	"+ENTER
						cQuery += " AND 	ZRN.ZRN_PEDIDO 	=  '"+SUA->UA_NUMSC5+"'		"+ENTER
						cQuery += " AND 	ZRN.D_E_L_E_T_ !=  '*' 						"+ENTER+ENTER
					
						DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPC', .F., .T.)
						DbSelectArea('TMPC');DbGoTop()
						Do While !Eof()
                                    
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³  BLOQUEIA SC6  \ GRAVA LOG     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							SC6Bloqueia(TMPC->ZRN_PEDIDO, TMPC->ZRN_ITEMPV)
			
							DbSelectArea('TMPC')
							DbSkip()
						EndDo
						
						IIF(Select('TMPC')!=0, TMPC->(DbCloseArea()), )			
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³  NAO Eh NECESSARIO ATUALIZA ZRN POIS JA FOI ATUALIZADA PELA FUNCAO LogRegNeg()	|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			        	//ZRNGravaLog(cNumAT, cItemAT, cCodRegra, cTpBloq, nRegra, nVenda, cProduto, cNumPV, cItemPV)
		
					End Transaction
					
				EndIf
			EndIf


		EndIf

	EndIf
	
	
	
	IIF(Select('TMPD')!=0, TMPD->(DbCloseArea()), )
	IIF(Select('TMPV')!=0, TMPV->(DbCloseArea()), )
EndIf



If lOperFat .And. (SC5->C5_BLQ == '1' .And. SC5->C5_LIBRNV1 == 'L' .And. SC5->C5_LIBRNV2 == 'L' .And. SC5->C5_LIBRNV3 == 'L')

	MsgAlert('ALERTA-2  - INFORMAR A TI',"Alerta - 2")	
	
	DbSelectArea("SC5");DbSetOrder(1)
	If DbSeek(xFilial("SC5")+SUA->UA_NUMSC5, .F.)
		RecLock("SC5",.F.)
			SC5->C5_LIBRNV1 := 'B'
		MsUnLock()
	Endif
EndIf



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualizo flag para ser considerada a consulta anterior     ³
//³quando o usuario deleta algum item.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea('SUB');DbSetOrder(1)
nPosItem := Ascan(aHeader, {|x| AllTrim(x[2])=='UB_ITEM'})
cNumAT	 := SUA->UA_NUM
For nX := 1 To Len(aCols)
	If GdDeleted(nX)
		//nItemAT := aCols[nX][nPosItem]
		//cProduto:= aCols[nX][X_PRODUTO]
		
		If DbSeek(xFilial("SUB")+SUA->UA_NUMORIG+StrZero(nX,2)+aCols[nX,X_PRODUTO])
			//If DbSeek(xFilial("SUB")+cNumAT+nItemAT+aCols[nX,X_PRODUTO])
			Reclock("SUB", .F.)
				SUB->UB_FLAGCON := "S"
			MsUnlock()
		EndIf
		/*
		cSql :=" UPDATE "+RetSqlName('SUB')
		cSql +=" 	SET UB_FLAGCON = 'S' "
		cSql +=" WHERE UB_FILIAL   = '"+xFilial('SUB')+"' "
		cSql +=" AND   UB_NUM      = '"+cNumAT+"' "
		cSql +=" AND   UB_ITEM     = '"+nItemAT+"' "
		cSql +=" AND   UB_PRODUTO  = '"+cProduto+"' "
		cSql +=" AND   D_E_L_E_T_  = '*' "
		
		nErro := TcSqlExec(cSql)
		IIF(nErro==0, TcSqlExec('COMMIT'), TcSqlExec('ROLLBACK'))
		*/
		
	EndIf
	
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro os itens de campanhas de vendas relacionadas a este pedido.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//removido em função da descontinuação da campanha de vendas - Rodrigo carvalho - Solutio 09/02/2015
/*

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
*/

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
//Removido em 09/02/2015 em função de que o envio de mensagens foi descontinuado - Rodrigo Carvalho - Solutio
/*
If !lOk
//	u_Mensagem('Pedido reprovado pela avaliação comercial automática!','INFO')
If lEnvMail
GeraMens(aOperador[1],aAvalCom,aOperador[5],aOperador[2],aOperador[3],aOperador[4])
Endif
Endif
*/

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
//removido em 09/02/2015 em função de que o envio de e-mails foi descontinuado - Rodrigo Carvalho - Solutio
/*
If Len(aLogComiss)>0
MailMaxComissao()
Endif
*/


If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
	MsAguarde({||SF4->(Testetmkok())},"Aguarde...","Verificando se é cópia e processando...")
Else
	Testetmkok()
Endif


////////////////////////////////////////////////CRIADO PELO JULIO JACOVENKO em 14/10/2011
////////////////////////////////////////////////PARA GRAVAR O CODIGO DO CLIENTE CORRETO QUANDO
////////////////////////////////////////////////TRANSFORMA PROSPECT PARA CLIENTES
///////////////////////////////////////////////////////////////////////////

If lRunProspect //SA1->A1_STATUS=='X'
	fVeCodCli(cCodcli,cLojCli,cNumSC5,cNumFil)
Endif


***********************************************************************************************************
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  FABIANO PEREIRA - SOLUTIO            	³
	//³  ZERA VARIAVEIS PUBLICAS - TMKACTIVE()	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// VldGrvRes VALIDA\GRAVA RESERVA - SC0 [PROJETO CORREIAS]                                  
	lGravaRes := .T.
	IIF(lOperFat, (oProcess:IncRegua2("Verificando Reservas"), ExecBlock('VldGrvRes',.F.,.F.,{lGravaRes, aPTransf})), )



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  FABIANO PEREIRA - SOLUTIO            	³
	//³  ZERA VARIAVEIS PUBLICAS - TMKACTIVE()	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aProdxImp  	:= {}	//	PRODUTO X IMPOSTOS
	aContDesc 	:= {}	//	ARRAY UTILIZADO NA REGRA DE DESCONTO
	aHistTV		:= {}	//	HISTORICO DE ATENDIMENTO
	aImdCodR 	:= {}	//	CODIGO DA REGRA DE NEGOCIO
	
	If Type('aIPvImda090') <> 'U'
		aIPvImda090 := Nil
	EndIf
***********************************************************************************************************


Return(.T.)
*********************************************************************
Static Function SC9Estorna(cNumPV)
*********************************************************************
DbSelectArea('SC9');Dbsetorder(1)	// C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
DbSeek(xFilial('SC9')+cNumPV)

Do While !Eof('SC9') .AND. SC9->C9_FILIAL == xFilial('SC9') .AND. SC9->C9_PEDIDO == cNumPV
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  A460Estorna eh uma funcao padrao do siga que estorna a SC9 que esta         ³
	//³  posicionada, desta forma ele jah arruma os saldos da SB2 e libera a SC5/SC6 ³
	//³  para exclusao, alem de outras coisas internas do siga.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SC9->(A460Estorna())
	DbSelectArea('SC9')
	DbSkip()
EndDo

Return()
*********************************************************************
Static Function SC5Bloqueia(cNumPV)
*********************************************************************
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| REALIZA BLOQUEIO - SC5	|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea('SC5');DbSetOrder(1)		// C5_FILIAL+C5_NUM
If DbSeek(xFilial('SC5') + cNumPV, .F.)
	RecLock('SC5',.F.)
		SC5->C5_BLQ  	:= 	'1'
		SC5->C5_LIBRNV1	:= 	'B'
		SC5->C5_LIBRNV2	:= 	'B'
		SC5->C5_LIBRNV3	:=	'B' //-- FABIANO SOLUTIO
	MsUnLock()
EndIf

Return()
*********************************************************************
Static Function SC6Bloqueia(cNumPV, cItemPV)
*********************************************************************
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| REALIZA BLOQUEIO - SC6	|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Dbselectarea('SC6');DbSetOrder(1)		// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
If DbSeek(xFilial('SC6')+ cNumPV + cItemPV, .F.)
	RecLock('SC6', .F.)
		SC6->C6_BLOQUEI := '01'
	MsUnLock()
EndIf

Return()
*************************************************************************
Static Function ZRNGravaLog(cNumAT, cItemAT, cCodRegra, cTpBloq, nRegra, nVenda,;
							cProduto, cNumPV, cItemPV)
*************************************************************************
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| 						   				GRAVA LOG - ZRN									 					|
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//| ZRNGravaLog(SUA->UA_NUM, TMPV->UB_ITEM, 'BLMRG1', 'Item PV', nMvImcMin, TMPV->UB_IMC)						|
//| ZRNGravaLog(SUA->UA_NUM, TMPV->UB_ITEM, 'BLMRG2', 'Item PV', ((TMPV->MKP_IMCMIN -1 ) * 100), TMPV->UB_IMC)	|
//| ZRNGravaLog(SUA->UA_NUM, TMPV->UB_ITEM, 'BLMRG3', 'Pedido', TMPV->RGV_IMCMIN, SUA->UA_IMC)					|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// cCodRegra[ BLMRG1 - MARGEM NEGATIVA 	- IMC	]
//			[ BLMRG2 - MARGEM ITEM 		- IMC 	]
//			[ BLMRG3 - MARGEM PEDIDO 			]
//			[ BLMRG4 - MARGEM NEGATIVA 	- IMCR 	]
//			[ BLMRG5 - MARGEM ITEM 		- IMCR 	]
//
// cTpBloq 	[ Item PV - Pedido		 ]
//
// nRegra  	[ nMvImcMin == GetMv('IMD_MINIMC')	] 
//			[ ((TMPV->MKP_IMCMIN -1 ) * 100)	]
//
// nVenda	[ TMPV->UB_IMC			 ]
//			[ SUA->UA_IMC 			 ] 
//			[ TMPV->RGV_IMCMIN		 ]
//


DbSelectArea('ZRN');DbSetOrder(1)	//	ZRN_FILIAL + ZRN_NUMAT + ZRN_ITEMAT + ZRN_CODRN
lGrava := !DbSeek(xFilial('ZRN') + cNumAT + cItemAT + PadR(cCodRegra, TamSx3('ZRN_CODRN')[01]), .F.)

DbSelectArea('ZRN')
Reclock('ZRN',lGrava)
	ZRN->ZRN_FILIAL	:=	xFilial('ZRN')
	ZRN->ZRN_NUMAT	:=	cNumAT
	ZRN->ZRN_ITEMAT	:= 	cItemAT
	ZRN->ZRN_PRODUT	:=	cProduto
	ZRN->ZRN_VENDA	:=	Round(nVenda, TamSx3('ZRN_VENDA')[02])
	ZRN->ZRN_CODRN	:=	cCodRegra
	ZRN->ZRN_REGRA	:=	Round(nRegra, TamSx3('ZRN_REGRA')[02])
	ZRN->ZRN_TPBLQ 	:=	Posicione("SX5",1,xFilial("SX5")+"GV"+cCodRegra,"X5_DESCRI" )
	ZRN->ZRN_CPOBLQ	:=	cTpBloq
	ZRN->ZRN_PEDIDO	:=	cNumPV
	ZRN->ZRN_ITEMPV	:=	cItemPV
MsUnlock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| VERIFICA\APAGA ALGUM LOG QUE POSSA TER OCORRIDO E NAO EXISTE MAIS A DIVERGENCIA		|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea('ZRN');Dbsetorder(1)
If Dbseek(xFilial('ZRN') + cNumAT + cItemAT + 'BLM')
	Do While !Eof().And. Substr(ZRN->ZRN_CODRN,1,3) == 'BLM' .And.  ZRN->ZRN_PEDIDO == cNumPV .And. ZRN->ZRN_ITEMPV == cItemPV
        If AllTrim(ZRN->ZRN_CODRN) != AllTrim(cCodRegra)
			RecLock('ZRN',.F.)
				DbDelete()
			MsUnlock()
		EndIf
		DbSkip()
	EndDo
EndIf

Return()
*************************************************************************
Static Function DelZRNLog(cNumAT, cItemAT, cNumPV, cItemPV)
*************************************************************************

DbSelectArea('ZRN');Dbsetorder(1)
If Dbseek(xFilial('ZRN') + cNumAT + cItemAT + 'BLM')
	Do While !Eof().And. Substr(ZRN->ZRN_CODRN,1,3) == 'BLM' .And.  ZRN->ZRN_PEDIDO == cNumPV .And. ZRN->ZRN_ITEMPV == cItemPV
		RecLock('ZRN',.F.)
			DbDelete()
		MsUnlock()
		DbSkip()
	EndDo
EndIf

Return()
*************************************************************************
Static Function SC5DesBlq(cNumPV, lForca)
*************************************************************************
Default lForca := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| REALIZA BLOQUEIO - SC5	|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea('SC5');DbSetOrder(1)		// C5_FILIAL+C5_NUM
If DbSeek(xFilial('SC5') + cNumPV, .F.)
	If !Empty(SC5->C5_BLQ) .Or. !Empty(SC5->C5_LIBRNV1) .Or. !Empty(SC5->C5_LIBRNV2) .Or. !Empty(SC5->C5_LIBRNV3) .Or. lForca
		RecLock('SC5',.F.)
			SC5->C5_BLQ  	:= 	' '
			SC5->C5_LIBRNV1	:= 	' '
			SC5->C5_LIBRNV2	:= 	' '
			SC5->C5_LIBRNV3	:=	' '
		MsUnLock()
	EndIf
EndIf

Return()			
*************************************************************************
Static Function SC6DesBlq(cNumPV)
*************************************************************************
DbSelectArea('SC6');DbSetOrder(1)		// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
If DbSeek(xFilial('SC6') + cNumPV, .F.)
    Do While !Eof() .And. SC6->C6_NUM == cNumPV
		If !Empty(SC6->C6_BLOQUEI)
			RecLock('SC6', .F.)
				SC6->C6_BLOQUEI := '  '
			MsUnLock()
		EndIf
	DbSkip()
	EndDo
EndIf

Return()			
**********************************************************************
Static Function TelaBloq(aMsgBlq)
**********************************************************************

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|   	TELA BLOQUEIO PV - IMC \ IMCR		|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//				   [01]		[02]    [03]	 [04]	  [05]      [06]      [07]	    [08]	[09]    [10]    [11]	 [12]
	//  Aadd(aMsgBlq,{cNumAT, cItemAT, cNumPV, cItemPV, cProduto, cDescri, cCodRegra, cTpBloq, nRegra, nVenda, cTexto, cCondBlq })

	Define Dialog oDlgBlq Title "Bloqueio PV - IMC \ IMCR" From 120,120 To 350,950 Pixel 
	
	    oBrowse := TcBrowse():New(001, 001, 415, 095,,{'Item At.','Produto','Descrição','Bloqueio'},{50,50,50},oDlgBlq,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	    oBrowse:SetArray(aMsgBlq)
	
	    oBrowse:AddColumn( TcColumn():New('Item At.'	,{|| aMsgBlq[oBrowse:nAt][02] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	    oBrowse:AddColumn( TcColumn():New('Produto'		,{|| aMsgBlq[oBrowse:nAt][05] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	    oBrowse:AddColumn( TcColumn():New('Descrição'	,{|| aMsgBlq[oBrowse:nAt][06] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	    oBrowse:AddColumn( TcColumn():New('Bloqueio'	,{|| aMsgBlq[oBrowse:nAt][11] },,,,"LEFT",,.F.,.T.,,,,.F.,) )

		If UsrRetName(__cUserId) == 'SOLUTIO'
		    oBrowse:AddColumn( TcColumn():New('Detalhe'		,{|| aMsgBlq[oBrowse:nAt][12] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
		    /*
		    oBrowse:AddColumn( TcColumn():New('cCodRegra'		,{|| aMsgBlq[oBrowse:nAt][07] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
		    oBrowse:AddColumn( TcColumn():New('cTpBloq'			,{|| aMsgBlq[oBrowse:nAt][08] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
		    oBrowse:AddColumn( TcColumn():New('nRegra'			,{|| aMsgBlq[oBrowse:nAt][09] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
		    oBrowse:AddColumn( TcColumn():New('nVenda'	   		,{|| aMsgBlq[oBrowse:nAt][10] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
			*/
		EndIf


	    TButton():New( 100, 365, '&Sair', oDlgBlq,{|| oDlgBlq:End() },30,010,,,.F.,.T.,.F.,,.F.,,,.F. )
		@ 100, 003  Say oSay1 PROMPT "Nesta tela são exibidas todas as regras de MARGEM que bloqueiam o Pedido de Venda." Size 225, 020 Of oDlgBlq COLORS CLR_HRED,CLR_WHITE/*0, 16777215*/ Pixel
	
	Activate Dialog oDlgBlq Centered

Return()
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
±±³ Uso      ³ESPECIFICO PARA O CLIENTE IMDEPA 						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
*********************************************************************
User Function DefComis(_cVendedor,lRep,cPagCom,_nDesNeg,_nAcreNeg)
*********************************************************************

Local aSaveArea	    := GetArea()
Local nComCli       := SA1->A1_COMIS    	  // Comissão CLiente
Local nProdComiss	:= SB1->B1_COMIS          //Comissao do Produto
Local cProdMerc		:= SB1->B1_MERCADO
//Local cDescComis    := GetMV("MV_COMIDES")	//	RODRIGO SOLUTIO
//Local cAcreComis    := GetMV("MV_COMIACR")	//	RODRIGO SOLUTIO
//Local nLimDescComis := 0//GetMV("MV_LIMDESC",,0) //Limite máximo p/ Desconto na Comissao do Vendedor		//	RODRIGO SOLUTIO
Local _ComisVend    := 0//SA3->(Posicione("SA3",1,xFilial("SA3")+ _cVendedor,"A3_COMIS"))Local nComisPaga    := 0
Local nPerComisREP  := SA1->A1_COMISRE
Local nComisPaga    := 0
Local lTemLimDesc   :=.F.
Local cFilVend      := Space(2)


DbSelectARea('SA3')
DbSetOrder(1)

If SA3->( DbSeek( xFilial( "SA3" ) + _cVendedor ) )
	_ComisVend    :=SA3->A3_COMIS
	cFilVend      :=SA3->A3_CODFIL
	//removido em 10/02/2015 em função de que as regras de desconto foram descontinuadas
	// nLimDescComis :=SuperGetMv("MV_LIMDESC" , .T. , 0 ,cFilVend)
Endif

//removido em 10/02/2015 em função de que as regras de desconto e acrescimos foram descontinuadas - Rodrigo Carvalho - Solutio
//Tratamento para o Desconto na Comissao do Vendedor interno
//Em Cuiaba o limite de desconto na comissao é baseado apenas no A3_COMIS, o desconto na venda é desconsiderado no cálculo
/*
If !lRep
If (nLimDescComis > 0 .OR. cFilVend $ "02/04") .AND. ( _nDesNeg > nLimDescComis)
lTemLimDesc:=.T.
Endif
Endif
*/

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
/* retirado em 30/01/2015 conforme definição em reunião com a Diretoria Rodrigo Carvalho Solutio
If cDescComis == "S"
If lTemLimDesc
nComCli := nComCli * (1-(nLimDescComis/ 100))
Else
nComCli := nComCli * (1-(_nDesNeg / 100))
Endif
Endif
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Aplica acrescimo nos percentuais de comissao (conforme CUS10)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/* retirado em 30/01/2015 conforme definição em reunião com a Diretoria Rodrigo Carvalho Solutio
If cAcreComis == "S"
nComCli := nComCli * (1+(_nAcreNeg / 100))
Endif
*/

// Caso For Vendedor Representante  e Tiver comissão específica no SA1->A1_COMISRE
IF nPerComisREP  <> 0 .AND. lRep
	nComCli := nPerComisREP
ENDIF


RestArea(aSaveArea)

Return nComCli


//Deve ser removido do fonte em função de que o envio de e-mails foi descontinuado - Rodrigo Carvalho - Solutio 09/02/2015
/*

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
*/

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

//deve ser removido do fonte em função de que o envio de mensagens por e-mail foi descontinuado - Rodrigo Carvalho - Solutio - 09/02/2015

/*
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
*/

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
//Removido em 10/02/2015 em função de que as regras de desconto e acrescimo foram descontinuadas
/*
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

//---------------------------------------------------------------------------------------------------------------------------
//| A funcao retorna o Desconto de ICMS Padrao p/ uso em outras rotinas - Inserido por Edivaldo Goncalves Cordeiro em 30/11/11 |
// ----------------------------------------------------------------------------------------------------------------------------

Return(nDescIcmPad)
*/

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
__lJaBotPag2 := .F.
//| Controla se houve alteração no Orçamento ... Já vem setada como alterado...
_lAltOrc  := .T.

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
	//	MsAguarde({||SF4->(U_EmailHtml(M->UA_NUM,M->UA_CLIENTE,M->UA_LOJA,xFilial("SUA"),SUA->UA_NUMSC5,M->UA_OPER,ALLTRIM(M->UA_OCCLI),M->UA_TPFRETE,ALLTRIM(M->UA_DESCNT),M->UA_CODCONT,lTk271Auto))},"E-mail Vendas","Publicando e-mail...")
	//	MsAguarde({||SF4->(U_IMDA800(M->UA_NUM,M->UA_CLIENTE,M->UA_LOJA,xFilial("SUA"),SUA->UA_NUMSC5,M->UA_OPER,ALLTRIM(M->UA_OCCLI),M->UA_TPFRETE,ALLTRIM(M->UA_DESCNT),M->UA_CODCONT,lTk271Auto))},"E-mail Vendas","Enviando...")
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


***********************************************************
Static Function fVeCodCli(cCodcli,cLojCli,cNumSC5,cNumFil) 
***********************************************************
_aArea:=GetArea()

DbSelectArea("SA1")
If DbSeek(XFILIAL("SA1")+cCodCli+cLojCli)
 cCgcCli:=SA1->A1_CGC
 fGravaPro(cCgcCli, cCodCli, cLojCli, cNumSC5, cNumFil)
Endif

lRunProspect:=.F.
RestArea(_aArea)

Return



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
Local cCodPreCli :=' '
Local cLojPreCli :=' '



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

//cQUERY := ChangeQuery( cQUERY )

If( Select("QRY_DB") <> 0 ) // Se a area a ser utilizada estiver em uso, fecho a mesma
	QRY_DB->( dbCloseArea() )
EndIf

//MEMOWRIT( "C:\SQLSIGA\JKTESTE1.SQL", cQUERY )

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
		
	///////////////Agora Ajusta o SUS o campo US_CLIENTE
	//DBSelectArea("SUS")
	//busca pro CGC
	DBSELECTAREA("SUS")
	DBSETORDER(4)
	IF DBSEEK(XFILIAL("SUS")+cCGCCLI)
	  cCodPreCli:=SUS->US_COD
      cLojPreCli :=SUS->US_LOJA

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
		
		//cQUERY := ChangeQuery( cQUERY )
		
		If( Select("QRY_001") <> 0 ) // Se a area a ser utilizada estiver em uso, fecho a mesma
			QRY_001->( dbCloseArea() )
		EndIf
		
		//MEMOWRIT( "C:\SQLSIGA\QRY001.SQL", cQUERY )
		
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
		
		cSql3 :=" UPDATE "+RetSqlName('SUA')
		cSql3 +=" SET "
		cSql3 +=" UA_CLIENTE   = '"+cCODANT+"', "
		cSql3 +=" UA_LOJA      = '"+SUS->US_LOJA+"' "
		cSql3 +=" WHERE "
		//cSql3 +=" UA_NUMSC5    = '"+cNumSC5+"'
		cSql3 +=" WHERE UA_FILIAL= '"+cNumFIL+"' "
   	    cSql3 +=" AND   UA_CLIENTE= '"+cCodPreCli+"' "
        cSql3 +=" AND   UA_LOJA   = '"+cLojPreCli+"' "
		
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
	
	Else
	//Atualiza o Histórico dos Orçamentos SUA
	fUpdateHistSua(cCODANT,cLOJANT)
EndIf


/////////////////////////////////////////////////////////////////////////////
RestArea(_aArea)

Return

************************************************//--------------------------------------------------------------------------------------
Static Function fUpdateHistSua(cNewCli,cNewLoja) // Atualiza o Histórico dos Orçamentos do Prospect para o Cliente ao qual foi Convertido
************************************************//--------------------------------------------------------------------------------------
Local cQuery

 DbSelectArea("SUS")
 DbSetOrder(4)
 
 If DbSeek(XFILIAL("SUS")+cCGCCLI)
	  cCodPreCli :=SUS->US_COD  //Código de Prospect
      cLojPreCli :=SUS->US_LOJA	//Loja de Prospect
      		
		cQuery :=" UPDATE "+RetSqlName('SUA')
		cQuery +=" SET "
		cQuery +=" UA_CLIENTE   = '"+cNewCli+"', "
		cQuery +=" UA_LOJA      = '"+SUS->US_LOJA+"' "
		cQuery +=" WHERE "
		cQuery +=" UA_FILIAL= '"+cNumFIL+"' "
   	    cQuery +=" AND UA_CLIENTE= '"+cCodPreCli+"' "
        cQuery +=" AND UA_LOJA   = '"+cLojPreCli+"' "
		
		nRet:=TCSQLExec( cQuery )
		
		If nRet <> 0		
			cRet = TCSQLERROR()
			MsgAlert(cRet,"Alerta")
		EndIf
		
		TCSQLExec('COMMIT')		

 EndIf
 
Return

**********************************************************************
Static Function CLI_Atualiza()//³ Atualiza Cliente no Consultado (ZA0) Caso Tenha Sido alterado...
**********************************************************************
Local cSql 			:= ""
Local cUA_CLIENTE	:= SUA->UA_CLIENTE
Local cUA_LOJA		:= SUA->UA_LOJA
Local cUA_NUM			:= SUA->UA_NUM
Local cUA_FILIAL		:= xFilial("SUA")


cSql  	+=	"Update ZA0010 "							;
+	"Set "											;
+	"ZA0_CLIENT = '"+cUA_CLIENTE		+"', "	;
+	"ZA0_LOJACL = '"+cUA_LOJA			+"', "	;
+	"ZA0_FLAGOF = ' ' "							;
+ 	"Where ZA0_FILIAL = '"+cUA_FILIAL	+"' "	;
+	"AND   ZA0_NUMORC = '"+cUA_NUM		+"' "

U_ExecMySql(cSql, "", "E", .F.)

Return()
**********************************************************************
Static Function LogRegNeg()
**********************************************************************
Local _aArea  	 := GetArea()
Local aNotDelZRD := {}
Local nPItem 	 := Ascan(aHeader, {|x| AllTrim(x[2])=='UB_ITEM'})
//				   1           2            3            4           5                          6                           7            8		   9  10
//			    NUM.ATEND   COD.REGRA   (NEG\COM\DESC) CAMPO BLQ    ITEM ATEND             DESCONTO VENDEDOR              PRODUTO     DESC.RNEG   PV ITEMPV
//Aadd(aATxRN, {M->UA_NUM, aBlq[nX][1], cDescAba,   aBlq[nX][4], aBlq[nX][5], GdFieldGet('UB_DESCVEN', Val(aBlq[nX][5])), aBlq[nX][6], aBlq[nX][7], '',''})

/*
Aadd(aRegDesc, {'Desc.Cliente', '', '', M->UA_DESC1 })
Aadd(aRegDesc, {'Desc.RD - Cabec', '', cCodRegra, M->UA_DESC4 })
Aadd(aRegDesc, {'Desc.Geral', '', '', M->UA_DESCG })
Aadd(aRegDesc, {'ITEM RD',  n, cCodRegra, nDesconto })
Aadd(aRegDesc, {'Fiscal', GdFieldGet('UB_ITEM', n), '', nDesconto })
Aadd(aRegDesc, {'Fiscal', GdFieldGet('UB_ITEM', n), 'Comp.ST', nDesconto })
Aadd(aRegDesc, {'Fiscal', GdFieldGet('UB_ITEM', n), 'ICMS', nPerDesc })
'Fator'
*/


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  			ATENDIMENTO   X   REGRA DE NEGOCIO  		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aATxRN) > 0
	
	For nX:=1 To Len(aATxRN)
		
		DbSelectArea('ZRN');DbSetOrder(1)	//	ZRN_FILIAL + ZRN_NUMAT + ZRN_ITEMAT  + ZRN_CODRN
		lGrava := !DbSeek(xFilial('ZRN')+ SUA->UA_NUM + aATxRN[nX][05] + aATxRN[nX][02], .F.)
		
		DbSelectArea('ZRN')
		Reclock('ZRN',lGrava)
			ZRN->ZRN_FILIAL	:=	xFilial('ZRN')
			ZRN->ZRN_NUMAT	:=	SUA->UA_NUM
			ZRN->ZRN_ITEMAT	:=	aATxRN[nX][05]
			ZRN->ZRN_PRODUT	:=	aATxRN[nX][07]
			ZRN->ZRN_VENDA	:=	Round(aATxRN[nX][06], TamSx3('ZRN_VENDA')[02])
			ZRN->ZRN_CODRN	:=	aATxRN[nX][02]
			ZRN->ZRN_REGRA	:=	Round(aATxRN[nX][08], TamSx3('ZRN_REGRA')[02])
			ZRN->ZRN_TPBLQ 	:=	aATxRN[nX][03]
			ZRN->ZRN_CPOBLQ	:=	aATxRN[nX][04]
			ZRN->ZRN_PEDIDO	:=	aATxRN[nX][09]
			ZRN->ZRN_ITEMPV	:=	aATxRN[nX][10]
		MsUnlock()
		
	
	Next
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  EXCLUI ITENS QUE NAO ESTAO BLOQUEADOS PELA REGRA DE NEGOCIO  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aRetZRN) > 0
	
	For nX:=1 To Len(aRetZRN)
		
		// Aadd(aRetZRN, {AllTrim(SUB->UB_NUM), AllTrim(SUB->UB_ITEM) })
		cNumAt  := 	aRetZRN[nX][01]
		cItemAt := 	aRetZRN[nX][02]
		
		//	CASO NUM.ATENDIMENTO NAO EXISTA NA TABELA NAO HA NECESSIDADE DE VERIFICAR OS ITENS
		DbSelectArea('ZRN');DbSetOrder(1)	//	ZRN_FILIAL + ZRN_NUMAT + ZRN_ITEMAT  + ZRN_CODRN
		If !DbSeek(xFilial('ZRN')+ cNumAt, .F.)
			Exit
		EndIf
		
		DbSelectArea('ZRN');DbSetOrder(1)
		If DbSeek(xFilial('ZRN')+ cNumAt + cItemAt, .F.)
			Do While !Eof() .And. ZRN->ZRN_NUMAT == cNumAt .And. ZRN->ZRN_ITEMAT == cItemAt
				
				If SubStr(ZRN->ZRN_CODRN,1,3) <> 'BLM'
					Reclock('ZRN',.F.)
						DbDelete()
					MsUnlock()
				EndIf
			
				DbSkip()
			EndDo
		EndIf
		
	Next
	
EndIf





//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  			ATENDIMENTO   X   REGRA DE DESCONTO			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aRegDesc) > 0
	
	
	/*
	Aadd(aRegDesc, {'Desc.Cliente'		, '', '', M->UA_DESC1	, '' 			,	})
	Aadd(aRegDesc, {'Desc.RD - Cabec'	, ''	, cCodRegra		, M->UA_DESC4	, ''})
	Aadd(aRegDesc, {'Desc.Geral', ''	, ''	, M->UA_DESCG	, ''			, 	})
	'Fator'
	Aadd(aRegDesc, {'ITEM RD',GdFieldGet('UB_ITEM', n),  cCodRegra, nDesconto,  cItemRD })
	Aadd(aRegDesc, {'Fiscal', GdFieldGet('UB_ITEM', n), 'Comp.ST, 	nDesconto, '' })
	Aadd(aRegDesc, {'Fiscal', GdFieldGet('UB_ITEM', n), 'ICMS', 	nPerDesc,  ''	})
	*/
	
	aSort(aRegDesc,,,{|X,Y| X[2] < Y[2]})
	For nX:=1 To Len(aRegDesc)

		// VERIFICAR SE LINHA DO ACOLS FOI DELETADA E RETIRAR DA ZRD
		// VERIFICAR ZRD X aCOLS DELETADOS
		
		// VERIFICAR SE DESCONTO FOI DADO, AT GRAVADO + F10 E RETIRADO DESCONTO
		// VERIFICAR ZRD X aRegDesc



		// VERIFICA SE LINHA DO ACOLS ESTA DELETADA... SE DELETADA NA GRAVAR NO ZRD
		cItemAT		:=	PadL(aRegDesc[nX][02], TamSx3('UB_ITEM')[1], '0')

		nLinAT		:=	Ascan(aCols, {|X| X[nPItem] == cItemAT  })
		lLinhaDel 	:=	IIF(nLinAT > 0, IIF(GdDeleted(nLinAT), .T., .F.), .T.)
	    
		// NAO GRAVO DESCONTO GERAL PQ JA INCLUSO ESSE DESCONTO NO ITEM.
		If Upper(aRegDesc[nX][01]) $ 'DESC.GERAL' .Or. lLinhaDel
			Loop
		EndIf

		/*
		aRegDesc[01] -	DESCR.REGRA         (DESC.VEN, FISCAL, FATOR, REGRA DESCONTO, ITEM RD)
		aRegDesc[02] -	ITEM ATENDIMENTO
		aRegDesc[03] -	DESCR.REGRA DETALHE (COMP.ST, ICMS)
		aRegDesc[04] -	VALOR DESCONTO
		aRegDesc[05] -	ITEM DA REGRA DE DESCONTO
		*/
		
		cCodRD	:=	IIF(Empty(aRegDesc[nX][03]), Space(TamSx3('ZRD_CODRD')[1]),  PadR(aRegDesc[nX][03], TamSx3('ZRD_CODRD')[1] , ''))
		cCodRD	:=	IIF(cCodRD=='Comp.ST','CompST', cCodRD)
		cItemRD	:=	IIF(Empty(aRegDesc[nX][05]), Space(TamSx3('ZRD_ITEMRD')[1]), PadR(aRegDesc[nX][05], TamSx3('ZRD_ITEMRD')[1], ''))
		cTpBloq	:=	PadR(aRegDesc[nX][01], TamSx3('ZRD_TPBLQ')[1] , '')
		

		IIF(Select('TMPZRD')!=0, TMPZRD->(DbCloseArea()), )
		cSql := " SELECT ZRD.R_E_C_N_O_ ZRD_RECNO, ZRD.* 		   			"+ENTER
		cSql += " FROM 	"+RetSqlName("ZRD")+" ZRD 				   			"+ENTER
		cSql += " WHERE ZRD.ZRD_FILIAL 		 =  '"+xFilial('ZRD')+"'	   	"+ENTER
		cSql += " AND	ZRD.ZRD_NUMAT		 =  '"+AllTrim(SUA->UA_NUM)+"'	"+ENTER
		cSql += " AND 	ZRD.ZRD_ITEMAT		 =  '"+AllTrim(cItemAT)+"'		"+ENTER
		cSql += " AND 	UPPER(ZRD.ZRD_TPBLQ) =  '"+Upper(cTpBloq)+"'		"+ENTER
		cSql += " AND 	ZRD.ZRD_CODRD		 = 	'"+Upper(cCodRD)+"'			"+ENTER
		cSql += " AND 	ZRD.ZRD_ITEMRD   	 =  '"+cItemRD+"'				"+ENTER
		cSql += " AND 	ZRD.D_E_L_E_T_ != '*'								"+ENTER
		
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),'TMPZRD',.T.,.T.)
		DbSelectArea('TMPZRD');DbGoTop()
		lGrava 		:= 	IIF(Empty(TMPZRD->ZRD_TPBLQ), .T., .F.) 
		nZRDRecno 	:=	TMPZRD->ZRD_RECNO
		IIF(Select('TMPZRD')!=0, TMPZRD->(DbCloseArea()), )



        IIF(!lGrava, ZRD->(DbGoTo(nZRDRecno)), )
        
		DbSelectArea('ZRD')
		RecLock('ZRD',lGrava)
			ZRD->ZRD_FILIAL	:=	xFilial('ZRD')
			ZRD->ZRD_NUMAT	:=	SUA->UA_NUM
			ZRD->ZRD_ITEMAT	:=	cItemAT
			ZRD->ZRD_CODRD	:=	StrTran(aRegDesc[nX][03], '.','')
			ZRD->ZRD_TPBLQ 	:=	AllTrim(aRegDesc[nX][01])
			ZRD->ZRD_DESCRD	:=	IIF(AllTrim(Upper(cTpBloq))=='DESC.VEND', 0, aRegDesc[nX][04])
			ZRD->ZRD_ITEMRD :=	cItemRD

			//							1						2						3				4				5             6         7=FLAG
			//	Aadd(aComplRD, {AllTrim(SUB->UB_ITEM), AllTrim(SUB->UB_PRODUTO), SUB->UB_DESCVEN, SUB->UB_NUMPV, SUB->UB_ITEMPV, SUB->UB_DESCRD, ''  })
			nPos := Ascan(aComplRD, {|X| AllTrim(X[01]) == AllTrim(cItemAT) .And. Empty(X[07]) })
			If nPos > 0
				ZRD->ZRD_PRODUT	:=	aComplRD[nPos][02]
				ZRD->ZRD_DESCVE	:=	IIF(AllTrim(Upper(cTpBloq))=='DESC.VEND', aComplRD[nPos][03], 0)

				ZRD->ZRD_PEDIDO	:=	aComplRD[nPos][04]
				ZRD->ZRD_ITEMPV	:=	aComplRD[nPos][05]
			EndIf

		MsUnLock()


		// aNotDelZRD UTILIZADO PARA DELETAR DO ZRD OS ITENS Q ESTAO ESTAO MAIS NO aRegDesc
		// VERIFICA SE O REGISTRO ZRD ESTA NO aNotDelZRD E NAO DELETA O ITEM.
		Aadd(aNotDelZRD, ZRD->(Recno()) )

	Next
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  EXCLUI DESCONTO(s) QUE ESTAO NA ZRD E FORAM RETIRADOS 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea('ZRD');DbSetOrder(1)					//	[ 1-ITEM  ]	ZRD_FILIAL + ZRD_NUMAT + ZRD_ITEMAT  + ZRD_CODRD + ZRD_ITEMRD
If DbSeek(xFilial('ZRD') + SUA->UA_NUM, .T.)		//	[ 2-CABEC ]	ZRD_FILIAL + ZRD_NUMAT + ZRD_ITEMAT  + ZRD_TPBLQ + ZRD_CODRD
	Do While ZRD->ZRD_NUMAT == SUA->UA_NUM

		lDeleta := IIF(Len(aNotDelZRD)==0, .T., IIF(Ascan(aNotDelZRD, ZRD->(Recno())) > 0, .F., .T.) )
		
		If lDeleta
			Reclock('ZRD',.F.)
				DbDelete()
			MsUnlock()
		EndIf

		DbSelectArea('ZRD')
		DbSkip()
	EndDo
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  EXCLUI DESCONTO(s) QUE FORAM DELETADOS DO aCOLS  [ZRN\ZRD] ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nIniDel := Ascan(aCols, {|X| X[Len(aHeader)+1]})
If nIniDel > 0
	For nX:=nIniDel To Len(aCols)
		If GdDeleted(nX)
			
			DbSelectArea('ZRD');DbSetOrder(1)					//	[ 1-ITEM  ]	ZRD_FILIAL + ZRD_NUMAT + ZRD_ITEMAT  + ZRD_CODRD + ZRD_ITEMRD
			If DbSeek(xFilial('ZRD') + SUA->UA_NUM + GdFieldGet('UB_ITEM', nX), .T.)		//	[ 2-CABEC ]	ZRD_FILIAL + ZRD_NUMAT + ZRD_ITEMAT  + ZRD_TPBLQ + ZRD_CODRD
				Do While ZRD->ZRD_NUMAT == SUA->UA_NUM .And. ZRD->ZRD_ITEMAT == GdFieldGet('UB_ITEM', nX)
	
						Reclock('ZRD',.F.)
							DbDelete()
						MsUnlock()
		
					DbSelectArea('ZRD')
					DbSkip()
				EndDo
			EndIf
		
			DbSelectArea('ZRN');DbSetOrder(1)	//	ZRN_FILIAL + ZRN_NUMAT + ZRD_ITEMAT + ZRN_CODRN
			If DbSeek(xFilial('ZRN') + SUA->UA_NUM + GdFieldGet('UB_ITEM', nX), .T.)
				Do While ZRN->ZRN_NUMAT == SUA->UA_NUM .And. ZRN->ZRN_ITEMAT == GdFieldGet('UB_ITEM', nX)
	
						Reclock('ZRN',.F.)
							DbDelete()
						MsUnlock()
		
					DbSelectArea('ZRN')
					DbSkip()
				EndDo
			EndIf
					
		EndIf
	Next
EndIf
                
	
RestArea(_aArea)
Return()
/*
Aadd(aRegDesc, {'Desc.Cliente'		, '', ''		, M->UA_DESC1 })
Aadd(aRegDesc, {'Desc.RD - Cabec'	, '', cCodRegra	, M->UA_DESC4 })
Aadd(aRegDesc, {'Desc.Geral'		, '', ''		, M->UA_DESCG })

Aadd(aRegDesc, {'Item RD'			, GdFieldGet('UB_ITEM', n)	, ''   			    	, nVlrDesRD, 	'000000'			})
Aadd(aRegDesc, {'ITEM RD'			, GdFieldGet('UB_ITEM', n)  , cCodRegra	, nDesconto 						})
Aadd(aRegDesc, {'Desc.Vend'			, GdFieldGet('UB_ITEM', n)	, ''       	, nDescVend, 	'' 					})
Aadd(aRegDesc, {'Acrec.Vend'		, GdFieldGet('UB_ITEM', n)	, ''       	, GdFieldGet('UB_ACRE',nLinha), '' 	})

Aadd(aRegDesc, {'Fiscal'			, GdFieldGet('UB_ITEM', n)	, 'Comp.ST'	, nDesconto, 	'' })
Aadd(aRegDesc, {'Fiscal'			, GdFieldGet('UB_ITEM', n)	, 'ICMS'	, nPerDesc, 	'' })

Aadd(aRegDesc, {'Fator'				, GdFieldGet('UB_ITEM', n)	, ''		, nFatorTV, 	'' })
*/
*******************************************************************************
Static Function ChkSC6Lib(cFilPV, cNumPV) 
*******************************************************************************
Local lRetorno := .F.

IIF(Select('TMPPV')!=0, TMPM->(DbCloseArea()), )
cQuery := "	SELECT 	C6_BLOQUEI, C6_NUM, C6_ITEM				   					"+ENTER
cQuery += " FROM 	"+RetSqlName("SC6")+" SC6   			   					"+ENTER
cQuery += " WHERE 	SC6.C6_FILIAL 	 =  '"+cFilPV+"' 							"+ENTER
cQuery += " AND 	SC6.C6_NUM	 	 =  '"+cNumPV+"'							"+ENTER
cQuery += " AND 	SC6.C6_BLOQUEI	!=  '"+Space(TamSx3('C6_BLOQUEI')[01])+"'	"+ENTER
cQuery += " AND 	SC6.D_E_L_E_T_ 	!=  '*' 									"+ENTER

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPPV', .F., .T.)

DbSelectArea('TMPPV');DbGoTop()
lRetorno :=	IIF(Empty(TMPPV->C6_BLOQUEI), .T., .F.)

IIF(Select('TMPPV')!=0, TMPPV->(DbCloseArea()), )
Return(lRetorno)
**********************************************************************
Static Function ChkBlqLibSC9(cNumPV)
**********************************************************************
Local aAreaAnt := 	GetArea()
Local lRetorno	:=	.F.

IIF(Select('TMPSC9')!=0, TMPMSC9->(DbCloseArea()), )
cQuery := " SELECT	C9_FILIAL, C9_PEDIDO, C9_PRODUTO, C9_LOCAL, C9_BLEST, C9_BLCRED, C9_BLWMS, C9_RESERVA, C9_QTDRESE, C9_SEQUEN "+ENTER
cQuery += " FROM 	"+RetSqlName("SC9")+" SC9   			   	"+ENTER
cQuery += " WHERE 	SC9.C9_FILIAL 	=  '"+xFilial('SC9')+"' 	"+ENTER
cQuery += " AND 	SC9.C9_PEDIDO 	=  '"+cNumPV+"'				"+ENTER
cQuery += " AND 	SC9.C9_ITEM 	=  '"+cItemPV+"'			"+ENTER
cQuery += " AND 	SC9.C9_PRODUTO 	=  '"+cProdPV+"'			"+ENTER
cQuery += " AND 	SC9.D_E_L_E_T_ 	!=  '*' 					"+ENTER

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPSC9', .F., .T.)

DbSelectArea('TMPSC9');DbGoTop()
lRetorno :=	IIF(Empty(TMPSC9->C9_BLEST).And.Empty(TMPSC9->C9_BLCRED), .T., .F.)

IIF(Select('TMPSC9')!=0, TMPSC9->(DbCloseArea()), )
RestArea(aAreaAnt)
Return(lRetorno)