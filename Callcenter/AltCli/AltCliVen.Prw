#Include "Totvs.ch"


#Define HORIZONTAL 1
#Define VERTICAL 	2

/// Altera��o do Cadastro de Cliente pelo Vendedor atrav�s do CallCenter....
*******************************************************************************
User Function AltCliVen()
*******************************************************************************

	Local oDlgCli
	Local oEnchCli

	//| Parametros MsmGet |
	Local lMemoria 	:= .F.		//| Enchoice utilizar� vari�veis de mem�ria ou os campos da tabela na edi��o. Valor default � .F.
	Local lF3				:= .F.		//| Enchoice esta sendo criada em uma consulta F3 para utilizar vari�veis de mem�ria. Valor default � .F.
	Local nModelo		:=  1		//| Se for diferente de 1 desabilita execu��o de gatilhos estrangeiros.|
	Local aAlterCpo	:= {} 		//| Habilita estes campos para edi��o...
	Local lCreate		:= .T.		//| Cria as pastas especificadas no par�metro aFolder. Valor default � .F. |
	Local aField			:= {}		//| Vetor com os campos que ser�o mostrados na Enchoice caso o SX3 n�o seja utilizado.|

	//Parametros RegtoMemory
	Local lInc				:= .F. 	//| Inicializa��o ser� baseada numa opera��es de inclus�o ( .T. ) ou manuten��o ( .F. ). A diferen�a entre elas � que na opera��o de inclus�o os valores s�o inicializados vazios e na manuten��o com os dados do registro posicionado.|
	Local lDic				:= .F. 	//| Inicializa��o das variaveis ser� baseada no dicion�rio de dados ou apenas nos dados da WorkArea aberta. A diferen�a entre elas s�o os campos virtuais que somente s�o inicializadados com a op��o .T. - Dicion�rio de dados.
	Local lInitPad		:= .F. 	//| Inicializador padr�o do dicion�rio de dados ser� executado. Este parametro somente ser� acionado se o parametro lDic for configurado como .T. - Dicion�rio de Dados.

	//| Parametros Enchoice |
	Local bOk				:= {|| SaveDados(aAlterCpo),  oDlgCli:End() } //| Bloco de c�digo a ser executado no bot�o Ok.|
	Local bCancel		:= {|| oDlgCli:End() } //| Bloco de c�digo a ser executado no bot�o Cancelar. |
	Local lMashups		:= .F.		//|Indica se o bot�o "Mashups" deve ser exibido.|
	Local lWalkThru	:= .F.		//|Indica se o bot�o "Walkthru" deve ser exibido.|

	//| Tela e Area |
	Local aAreaAtu		:= GetArea()				//| Salva Area Atual |
	Local aScreen 		:= GetScreenRes()	//| Obtem Array com Resolucao do Monitor... |

	// Diversos
	Local cCampAlt 	:= U_GetSx6("IM_CMPALTC",Nil,'A1_DDD;A1_EMAIL;A1_TEL')//

	//| Valores Padroes ... |
	Private cAlias 	:= "SA1"
	Private nRecno		:= SA1->(Recno())
	Private nOpc			:= 2 		//| 4-Alterar |

	Private aRotina := {	{"Pesquisar" , "axPesqui" 		, 0, 1},;
			    							{"Alterar" 	, "U_AltCliVen" 	, 0, 4}}


	If Empty(M->UA_CLIENTE)
		Iw_MsgBox("Nenhum Cliente foi selecionado !!!","Aten��o","ALERT")
		Return()
	ElseIf lProspect
		Iw_MsgBox("Essa Rotina n�o Altera Prospects!!!","Aten��o","ALERT")
		Return()
	EndIf

	aAlterCpo				:= StrTokArr(cCampAlt,";")

	// Reduz em 15% a o numero de Pixel do monitor para ser utilizada Nos Dialogos...
	aScreen[VERTICAL] 		:= aScreen[VERTICAL] 		* 0.85
	aScreen[HORIZONTAL] 	:= aScreen[HORIZONTAL] 	* 0.85

	DbSelectArea("SA1")
	DbGoto(nRecno)

	//| Abri o Dialogo com Todos os Campos... |
	DEFINE MSDIALOG oDlgCli TITLE "Cliente" FROM 0,0 TO aScreen[VERTICAL],aScreen[HORIZONTAL] PIXEL

	oDlgCli:lMaximized := .T.

	RegToMemory(cAlias, lInc, lDic, lInitPad ) //Esta fun��o inicializa as variaveis de memoria utilizadas pela interfaces modelo 3 ou que contenha o objeto Enchoice/MsSelect.

	oEnchCli	:= MsmGet():New(cAlias,nRecno,nOpc,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aVisulCpo*/,/*aPos*/,aAlterCpo,nModelo,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oDlgCli,lF3,lMemoria,/*lColumn*/,/*caTela*/,/*lNoFolder*/,/*lProperty*/,/*aField*/, /*aFolder*/,/*lCreate*/,/*lNoMDIStretch*/,/*cTela*/)

	oEnchCli:oBox:align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgCli CENTER ON INIT EnchoiceBar( oDlgCli, bOk, bCancel, /*lMsgDel*/, /*aButtons*/, nRecno, cAlias, lMashups, /*lImpCad*/, /*lPadrao*/, /*lHasOk*/, lWalkThru, /*cProfileID*/)

	RestArea(aAreaAtu) //| Restaura as Areas ..

Return()
*******************************************************************************
Static Function SaveDados(aAlterCpo)//| Salva as Alteracoes efetuadas pelo Vendedor... |
*******************************************************************************
Local cCampoR	:= ""
Local cCampoM	:= ""


RecLock(cAlias,.F.)
For nC := 1 To Len(aAlterCpo)

	cCampoR := cAlias+"->"+aAlterCpo[nC]
	cCampoM := "M->"+aAlterCpo[nC]

	&cCampoR. := &cCampoM.

Next
MsUnlock()


Return()

