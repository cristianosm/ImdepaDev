#include 'vkey.ch'
#include 'Protheus.ch'


//ajustado 04/09/2014
//testes com mauricio


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TmkActive   ³ Autor ³Expedito Mendonca Jr³ Data ³ 30/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa variaveis na entrada da tela de atendimento do  ³±±
±±³          ³ Call Center                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_TmkActive()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Call Center                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function TmkActive()

	Public __PrimComp   				:= "N"		// Primeira compra do cliente
	Public __Podesair   				:= "S"		// Libera a saida da tela
	Public __lJaBotCPag 				:= .F.  	// Ja clicou no botao de condicao de pagamento neste atendimento?
	Public __lTranspPossuiRota 	:= .F.  	// Transportadora possui rota
	Public __RodouRotas					:= .F.
	Public __ClienteAtual				:= SPACE(TamSx3("UA_CLIENTE")[1] + TamSx3("UA_LOJA")[1])
	Public __aItDigQtd  				:= {}   	// Array com flag indicando itens em que o usuario ja digitou a quantidade
	Public __aItDigPrd  				:= {}   	// Array contendo a linha e o produto digitado, para avaliar se houve modificação no produto digitado
	Public __COPIATT						:= .F.  	// Flag que indica que o atendimento atual da tela é uma cópia
	Public __nLibDel						:= 0			// Ate qual linha o sistema permite a delecao de itens do aCols
	Public __cTabAtu						:= ""		// Tabela de precos atual, utilizada para definir se ao passar pela validacao do campo UA_TABELA,
	                            // deve-se ou nao atualizar os precos dos itens do atendimento
	Public __aProdCamp  				:= {}		// Array com a amarracao produtoxcampanha para posterior gravacao da tabela ZZI
	Public __cMensagem
	Public aPrecosCamp 					:={}    	// Array com preços de campanha
	Public lFocusTlv 					:= .F.
	Public __ClienteAtual				:= SPACE(TamSx3("UA_CLIENTE")[1] + TamSx3("UA_LOJA")[1])
	Public bSigaGotFocus
	Public bDel
	Public aAbaulSimi          	:= {} 		//Array com produtos Abaulados/Similares para posterior envio do e-mail ao cliente
	Public nFreteTabFix        	:= 0
	Public _lAltOrc            	:= .T. 	// Controla se houve alteração no Orçamento ... Já vem setada como alterado...
	Public _ljaCPaCP						:= .F. 	//| Solicita o Click na Condição de Pagamento antes de emitir o Orcamento...


	//Public __CopaHeader					:= {} //:=  @aHeader     // Array com flag indicando itens em que o usuario ja digitou a quantidade
	Public __aCCols  		   		:= {} // Array contendo a linha e o produto digitado, para avaliar se houve modificação no produto digitado


    ////JULIO JACOVENKO, em 11/08/2014
    ////Variaveis globais para tratamento do frete
    ////
    Public _NFRETE              := 0
    Public _NVALFRT             := 0
    Public _NVLMETA             := 0
    Public _NVALSUG             := 0
    Public _LPEGATRAN           := .F.    ///ainda nao passou pelo transporte
    Public _NACOL               := 1
    ///////////////////////////////////


    ////JULIO JACOVENKO, em 03/11/2014
    //////////////////////////////////


If TkGetTipoAte() != "3" //Se nao for TELECOBRANCA

	If Type("lTk271Auto") == "U" .Or. !lTk271Auto
		bSigaGotFocus 							:= oGetTlv:oBrowse:bGotFocus
		bDel												:= oGetTlv:oBrowse:bDelete
		oGetTlv:oBrowse:bGotFocus   :=  { || eval(bSigaGotFocus),lFocusTlv := .T.}
		oGetTlv:oBrowse:bLostFocus  :=  { || lFocusTlv := .F. }
	EndIf

	// Jorge Oliveira - 27/10/10 - Criada a variavel para ser recuperada sempre que foi utilizada a tecla na funcao IMDM100()
	__ClienteAtual := M->UA_CLIENTE + M->UA_LOJA

	Set key VK_F11 to
	SetKey(VK_F11, {|| U_IMDF190()})

	Set key VK_F12 to
	SetKey(VK_F12, {|| U_IMDM100()})


	//|ANALISTA: CRISTIANO MACHADO DESC.: PERCENTUAL DO FRETE   DATA: 31/07/13
	U_CAMPRODAPE()
	//FIM

EndIf

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IMDM100     ³ Autor ³Jorge Oliveira      ³ Data ³ 05/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Coloca na tela o Codigo e Loja do ultimo Cliente utilizado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_IMDM100()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Call Center                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function IMDM100()

	If !Empty( __ClienteAtual ) .And. __ClienteAtual <> M->UA_CLIENTE + M->UA_LOJA

		M->UA_CLIENTE := Left( __ClienteAtual, 6 )
		M->UA_LOJA    := Right( __ClienteAtual, 2 )

		oGetTlv:oBrowse:Refresh(.T.)

	EndIf

Return




///////////------------------------------------------
///USADO NAS ROTINAS PARA CONTROLE
///DA COBRANCA NO NOVO FRETE
///CAMPRODAPE.PRW
///MSTROT2.PRW
///PE_TK271OK.PRW
///PE_TMKVFIM.PRW
///M460FIM.PRW
///PE_TMKACTIVE.PRW (AQUI)
///VALROTA.PRW

USER FUNCTION LNFRT13()
Local lRet := .F.
//MV_FILFR13

	//XFILIAL('SUA')<>'07' .OR. XFILIAL('SUA')<>'11'	//.AND. (SA1->A1_CLFAMIN<>'S')

	//MV_FILFRT='05/11'
    //IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCULO<>'PP' .AND. SA1->A1_VINCULO<>'CM')
    IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCULO<>'PP' .AND. SA1->A1_VINCULO<>'CM') .AND. SA1->A1_CLIFRTE<>'1'
    //IF (XFILIAL('SUA')=='05') .AND. (SA1->A1_VINCULO<>'PP' .OR. SA1->A1_VINCULO<>'CM')
       lRet := .T.
    ENDIF

RETURN lRet

//////////------------------------------------------
