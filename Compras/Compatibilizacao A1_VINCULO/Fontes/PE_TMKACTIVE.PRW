#INCLUDE 'VKEY.CH'
#INCLUDE 'PROTHEUS.CH'
//#INCLUDE 'INKEY.CH'

//ajustado 04/09/2014
//testes com mauricio


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄż±±
±±łPrograma  ł TmkActive   ł Autor łExpedito Mendonca Jrł Data ł 30/04/03 ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±łDescri‡„o ł Inicializa variaveis na entrada da tela de atendimento do  ł±±
±±ł          ł Call Center                                                ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łSintaxe   ł U_TmkActive()                                              ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łParametrosł NIL                                                        ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łRetorno   ł NIL                                                        ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łUso       ł Call Center                                                ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ł ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ł PROGRAMADOR  ł DATA   ł DESCRICAO                                     ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ł              ł        ł                                               ł±±
±±ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function TmkActive()

	Public __PrimComp   := "N"	// Primeira compra do cliente
	Public __Podesair   := "S"	// Libera a saida da tela
	Public __lJaBotCPag := .F.  // Ja clicou no botao de condicao de pagamento neste atendimento?
	Public __lTranspPossuiRota 	:= .F.  // Transportadora possui rota
	Public __RodouRotas			:= .F.
	Public __ClienteAtual		:= SPACE(TamSx3("UA_CLIENTE")[1] + TamSx3("UA_LOJA")[1])
	Public __aItDigQtd  := {}   // Array com flag indicando itens em que o usuario ja digitou a quantidade
	Public __aItDigPrd  := {}   // Array contendo a linha e o produto digitado, para avaliar se houve modificaçăo no produto digitado
	Public __COPIATT	:= .F.  // Flag que indica que o atendimento atual da tela é uma cópia
	Public __nLibDel	:= 0	// Ate qual linha o sistema permite a delecao de itens do aCols
	Public __cTabAtu	:= ""	// Tabela de precos atual, utilizada para definir se ao passar pela validacao do campo UA_TABELA,
	                            // deve-se ou nao atualizar os precos dos itens do atendimento
	Public __aProdCamp  := {}	// Array com a amarracao produtoxcampanha para posterior gravacao da tabela ZZI
	Public __cMensagem
	Public aPrecosCamp :={}    // Array com preços de campanha
	Public lFocusTlv := .F.
	Public __ClienteAtual		:= SPACE(TamSx3("UA_CLIENTE")[1] + TamSx3("UA_LOJA")[1])
	Public bSigaGotFocus
	Public bDel
	Public aAbaulSimi           :={} //Array com produtos Abaulados/Similares para posterior envio do e-mail ao cliente
	Public nFreteTabFix         := 0     
	Public _lAltOrc             :=.F.
	Public _ljaCPaCP						:= .F. //| Solicita o Click na Condi?o de Pagamento antes de emitir o Orcamento...
	
	Public _ljaCPIMC            := .F.   //Solicita o Click na Condicao de Pagamento quando F4
	
	//Public __CopaHeader					:= {} //:=  @aHeader     // Array com flag indicando itens em que o usuario ja digitou a quantidade
	Public __aCCols  		   		:= {} // Array contendo a linha e o produto digitado, para avaliar se houve modifica?o no produto digitado
	    
    ////JULIO JACOVENKO, em 11/08/2014 
    ////Variaveis globais para tratamento do frete
    ////
    Public _NFRETE              := 0
    Public _NVALFRT             := 0
    Public _NVLMETA             := 0
    Public _NVALSUG             := 0
    Public _LPEGATRAN           := .F.    ///ainda nao passou pelo transporte
    
    Public _LPEGATIMC           := .F.    ///ainda nao passou pelo transporte quando F4
    Public _NACOL               := 1
    ///////////////////////////////////         
    Public __lJaBotPag2        := .F. //CLICOU NA CONDICAO DE PAGAMENTO 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
	//ł  SOLUTIO - FABIANO PEREIRA  - 23/09/2014                          ł
	//ł  ARRAY CRIADO PARA GUARDAR OS VALORES DOS IMPOSTOS - POR ITEM     ł
	//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
		Public aProdxImp  	:= {}	//	PRODUTO X IMPOSTOS
		Public aContDesc 	:= {}	//	ARRAY UTILIZADO NA REGRA DE DESCONTO
		Public aHistTV		:= {}	//	HISTORICO DE ATENDIMENTO
		Public aRegDesc		:= {}	//	REGRA DE DESCONTO
		Public aImdCodR 	:= {}	//	CODIGO DA REGRA DE NEGOCIO   
		Public aATxRN	 	:= {}	//	ATENDIMENTO X REGRA DE NEGOCIO
		Public _nCopyAt 	:= 0	//	CONTROLE COPIA DE ATENDIMENTO - RAFAEL L. SCHEIBLER
     
        Public nDestaca     
        Public LCLISPFRT :=.F.
        Public NCARRO    :=0
        Public LCLIENTESP:=.F.
		

		SetKey(K_ALT_F2,  {|| ExecBlock('TelaImpostos', .F., .F.) })
		// SetKey(K_CTRL_F2, {|| ExecBlock('TelaImpostos', .F., .F., {'RD'}) })
		// SetKey(K_SH_F2,    {||ExecBlock('TelaImpostos', .F., .F.) })
		//SetKey(K_SH_F2,    {||ExecBlock('TelaImpostos', .F., .F.) })



	    
	
If TkGetTipoAte() != "3" //Se nao for TELECOBRANCA

	If Type("lTk271Auto") == "U" .Or. !lTk271Auto
		bSigaGotFocus 				:= oGetTlv:oBrowse:bGotFocus
		bDel						:= oGetTlv:oBrowse:bDelete
		oGetTlv:oBrowse:bGotFocus  	:=  { || Eval(bSigaGotFocus),lFocusTlv := .T.}
		oGetTlv:oBrowse:bLostFocus	:=  { || lFocusTlv := .F. }
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

	    /////JULIO JACOVENKO, em 30/10/2015
	    /////para testar IMC
	    ///// 
	//Set key K_SH_F1 to
	//SetKey(K_SH_F1, {|| U_FDEFMC()})
	
	Set key VK_F4 to
	SetKey(VK_F4, {|| U_FDEFMC()})


EndIf


Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄż±±
±±łPrograma  ł IMDM100     ł Autor łJorge Oliveira      ł Data ł 05/10/10 ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±łDescri‡„o ł Coloca na tela o Codigo e Loja do ultimo Cliente utilizado ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łSintaxe   ł U_IMDM100()                                                ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łParametrosł NIL                                                        ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łRetorno   ł NIL                                                        ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łUso       ł Call Center                                                ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ł ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ł PROGRAMADOR  ł DATA   ł DESCRICAO                                     ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ł              ł        ł                                               ł±±
±±ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ±±
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
    //IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCIMD<>'PP' .AND. SA1->A1_VINCIMD<>'CM')
    IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCIMD<>'PP' .AND. SA1->A1_VINCIMD<>'CM') .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'
    //IF (XFILIAL('SUA')=='05') .AND. (SA1->A1_VINCIMD<>'PP' .OR. SA1->A1_VINCIMD<>'CM')
       lRet := .T.
    ENDIF

RETURN lRet

//////////------------------------------------------