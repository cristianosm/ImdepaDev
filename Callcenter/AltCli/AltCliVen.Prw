#Include "Totvs.ch"


#Define HORIZONTAL 1
#Define VERTICAL 	2

/// Alteração do Cadastro de Cliente pelo Vendedor através do CallCenter....
*******************************************************************************
User Function AltCliVen()
*******************************************************************************

	Local oDlgCli
	Local oEnchCli

	//| Parametros MsmGet |
	Local lMemoria 	:= .F.		//| Enchoice utilizará variáveis de memória ou os campos da tabela na edição. Valor default é .F.
	Local lF3				:= .F.		//| Enchoice esta sendo criada em uma consulta F3 para utilizar variáveis de memória. Valor default é .F.
	Local nModelo		:=  1		//| Se for diferente de 1 desabilita execução de gatilhos estrangeiros.|
	Local aAlterCpo	:= {} 		//| Habilita estes campos para edição...
	Local lCreate		:= .T.		//| Cria as pastas especificadas no parâmetro aFolder. Valor default é .F. |
	Local aField			:= {}		//| Vetor com os campos que serão mostrados na Enchoice caso o SX3 não seja utilizado.|

	//Parametros RegtoMemory
	Local lInc				:= .F. 	//| Inicialização será baseada numa operações de inclusão ( .T. ) ou manutenção ( .F. ). A diferença entre elas é que na operação de inclusão os valores são inicializados vazios e na manutenção com os dados do registro posicionado.|
	Local lDic				:= .F. 	//| Inicialização das variaveis será baseada no dicionário de dados ou apenas nos dados da WorkArea aberta. A diferença entre elas são os campos virtuais que somente são inicializadados com a opção .T. - Dicionário de dados.
	Local lInitPad		:= .F. 	//| Inicializador padrão do dicionário de dados será executado. Este parametro somente será acionado se o parametro lDic for configurado como .T. - Dicionário de Dados.

	//| Parametros Enchoice |
	Local bOk				:= {|| SaveDados(aAlterCpo),  oDlgCli:End() } //| Bloco de código a ser executado no botão Ok.|
	Local bCancel		:= {|| oDlgCli:End() } //| Bloco de código a ser executado no botão Cancelar. |
	Local lMashups		:= .F.		//|Indica se o botão "Mashups" deve ser exibido.|
	Local lWalkThru	:= .F.		//|Indica se o botão "Walkthru" deve ser exibido.|

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
		Iw_MsgBox("Nenhum Cliente foi selecionado !!!","Atenção","ALERT")
		Return()
	ElseIf lProspect
		Iw_MsgBox("Essa Rotina não Altera Prospects!!!","Atenção","ALERT")
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

	RegToMemory(cAlias, lInc, lDic, lInitPad ) //Esta função inicializa as variaveis de memoria utilizadas pela interfaces modelo 3 ou que contenha o objeto Enchoice/MsSelect.

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

