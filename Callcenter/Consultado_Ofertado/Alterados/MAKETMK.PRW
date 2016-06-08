#INCLUDE 'protheus.ch'
#INCLUDE 'tbiconn.ch'
#INCLUDE "TOPCONN.CH"


#IFNDEF CRLF
	#DEFINE CRLF ( chr(13)+chr(10) )
#ENDIF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MAKETMK   ºAutor  ³Edivaldo Gonçalves  º Data ³  13/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importa Orçamentos/Pedidos B2B                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ WORKFLOW                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function makeTmka(aCab_Ped_par, aIt_Ped_par, _lApaga, _aCons)

Local cItemNovo      := "00"
Local NumPedInternet := "" 	// Número do Pedido da Internet
Local _cFilSUA           	// Filial do orçamento gerado
Local _cNumSUA           	// Número do orçamento gerado
Local cCliente           	// Código do cliente
Local cLoja              	// Loja do cliente
Local iCondPag           	// Código da condição de pagamento
Local iContato           	// Código do contato do cliente
Local iTransp            	// Código da transportadora

Local iTpFrete              // Tipo de Frete C=Cif F=Fob
Local cOper                 // Código do Operador de Tele Vendas
Local cOperNome             // Nome do Operador de Tele Vendas
Local nTotalPed     := 0
Local aLinha        := {}
Local _lApaga       := _lApaga

Local cPathLogs     := "\hhtrg\"
Local cTextoAlert   :=' '
Local cTes

Local cFreteDestac :=0
Local cFilCliente  :=''

Local   iVrConc     := 0
Local   cSeq_ID     :=' '
Local   cMailLog    := GetMV("MV_LOGB2B" ) //Emails para recepcao de ErrorLog
//Private oError      := ErrorBlock({|e| U_EnvMyMail('protheus@imdepa.com.br','edivaldo@imdepa.com.br','','B2B - ErrorLog na Importação do Orçamento/Pedido',e:Description,'')})

Private N:=1
Private	cEmp
Private cFil

PRIVATE  iOperacao          // Código da operação 1=Faturamento 2=Orçamento
PRIVATE  cTipo

PRIVATE lMsErroAuto   := .F.
PRIVATE lMsHelpAuto   := .T.  // Direciona as mensagens de help

Private aCab_Ped      := aCab_Ped_par
Private aIt_Ped       := aIt_Ped_par
Private lProspect     :=.F.

Private lViaWorkFlow


conout("makeTmka - execucao abortada linha 74 - "+dtos())
Return()/// ABORTA A EXECUCAO


If Len(aCab_Ped)>0
	cCliente        := aCab_Ped [ 3 ]
	cLoja           := aCab_Ped [ 4 ]
	cFilCliente     :=SA1->(Posicione("SA1",1,xFilial("SA1") + cCliente + cLoja,"A1_ESTQFIL"))
Endif


If Empty(cFilCliente)
	Conout('B2B - Estoque do cliente inválido,abortando operação...')
	Return
Endif

cEmp := '01'
cFil := Alltrim(cFilCliente)

PswOrder(2)
PswSeek("VENDASMAIL",.T.)
__cUserId := PswRet()[1][1]
ConOut('ID do usuario vendas mail: ' + __cUserId)


lViaWorkFlow := .T.          //Forcado a execucao via Work-Flow - Edivaldo
nModulo      := 13           //Seta a variavel nModulo para 13 (Call Center) para utilizar os campos do modulo
cFilant      := cFilCliente  //Define a filial que vai entrar o Orcamento/Pedido pelo estoque do cliente B2(BA1_ESTQFIL)

SM0->(DbSeek("01" + cFilCliente))


// Posiciona Vendedor (Usuário para os pedidos da Internet)
SA3->(dbSetOrder(1))
SA3->(dbSeek(xFilial("SA3")+'000698'))

// Posiciona Operador (Usuário para os pedidos da Internet)
SU7->(dbSetOrder(4))
SU7->(dbSeek(xFilial("SU7")+SA3->A3_CODUSR))
cOper 		:= SU7->U7_COD
cOperNome 	:= SU7->U7_NOME

SUA->(U_TmkActive())


aCabec := {}
aItens := {}

If Len(aCab_Ped) > 0

	/*------------------------------Cabeçaho do Pedido de Internet(colunas fixas)
	Registro Tipo 0				Ultima Atualizacao 19/07/2011
	Campo		Tamanho		Formato			Decimais	Descrição
	TIPO REG	1			9				0			Fixo "0"
	NUMERO		6			999999			0			Numero do PV no site
	UA_CLIENTE	6			AAAAAA			0			Codigo do Cliente
	UA_LOJA		2			AA				0			Loja do Cliente
	UA_CODCONT	6			AAAAAA			0			Codigo do contato
	UA_OPERADO	6			AAAAAA			0			Codigo do operador
	UA_TRANSP	6			AAAAAA			0			Codigo da transportadora
	UA_TPFRETE	1			A				0			Tipo de Frete
	UA_CODROTA	6			A				0			Codigo da Rota
	UA_FRETEXP	1			A				0			Frete Expresso
	UA_OPER		1			A				0			Tipo de Operacao
	UA_CONDPG	3			999				0			Condicao de Pagamento
	UA_FRETCAL	10			9999999999		2			Valor do frete *
	A1_CIFDEST	1			9				0			Destaca CIF
	UA_OBSEXP	90			AAAAAAAAAA...	0			Obs.: Pedido
	UA_MENNOTA	60			AAAAAAAAAA...	0			Obs.: Nota Fiscal
	UA_OCCLI	10			AAAAAAAAAA		0			Ordem de Compra Cliente

	---------------------------------------------------------------------------
	*/

	/*-----------------------------Itens do Pedido
	1)REGISTRO     - Tipo de registro no arquivo (uso interno)
	2)UB_PRODUTO
	3)UB_QUANT
	4)UB_VRUNIT
	5)PREÇO CONCORRENTE
	---------------------------------------------
	*/

	NumPedInternet  := aCab_Ped [ 2 ]      //HC5->HC5_COTAC
	cCliente        := aCab_Ped [ 3 ]      // Pega os 6 primeiros bytes pq a loja esta concatenada
	cLoja           := aCab_Ped [ 4 ]      // Pega os dois ultimos caracteres
	iCondPag        := aCab_Ped [ 12]
	iContato        := aCab_Ped [ 5 ]
	iTransp         := aCab_Ped [ 7 ]
	iOperacao       := aCab_Ped [ 11]      //1=Faturamento 2=Orçamento
	//Tipo de Frete , se vir vazio considera padrao tipo FOB
	iTpFrete        := Iif(Empty(aCab_Ped [ 8 ]),'F', aCab_Ped [ 8 ])  //aCab_Ped [ 8 ]      //Tipo de Frete C=Cif F=Fob
	iValFrete       := aCab_Ped [ 13]      //Valor do Frete
	cFreteCif       := aCab_Ped [ 14]      //Destaca Frete Cif 1=SIM 2= NÃO

	//| cristiano
	cObsexp			:= aCab_Ped [ 15]
	cMenNota		:= aCab_Ped [ 16]
	cOcCli			:= aCab_Ped [ 17]

	If cFreteCif == '1'
		cFreteDestac   := iValFrete / (1 + GETMV("MV_PERACFT")/100)
	Endif

	/*
	Se Destaca frete
	*/

	dbSelectArea("SA1");dbSetOrder(1)     //Posiciona Clientes
	SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja))

	If Empty( NumPedInternet )
		cTextoAlert:='-> Número do Pedido Internet vazio'
	ElseIf Empty( cCliente )
		cTextoAlert+=Chr(13)+Chr(10)+'-> Código do cliente  vazio'
	ElseIf Empty( cLoja )
		cTextoAlert+=Chr(13)+Chr(10)+'-> Loja do cliente  vazio'
	ElseIf Empty( iCondPag )
		cTextoAlert+=Chr(13)+Chr(10)+'-> Condição de pagamento  vazio'
	ElseIf Empty( iContato )
		cTextoAlert+=Chr(13)+Chr(10)+'-> Contato do cliente  vazio'
	ElseIf Empty( iTransp )
		cTextoAlert+=Chr(13)+Chr(10)+'-> Código da transportadora  vazio'
	ElseIf Empty( ioperacao )
		cTextoAlert+=Chr(13)+Chr(10)+'-> Operação(Orçamento - Pedido)  vazio'
	//ElseIf Empty( iTpFrete )
	 //	cTextoAlert+=Chr(13)+Chr(10)+'-> Tipo de Frete  vazio'
	Endif

	If!Empty(cTextoAlert) //Houve inconsistências
		SF4->( U__Alerta(1,'Orçamento'+' Web Nº'+NumPedInternet +'- Filial '+SM0->M0_CODFIL+' não importado para o cliente '+cCliente+'/'+cLoja +CHR(13)+CHR(10)+CHR(13)+CHR(10)+'INCONSISTÊNCIAS'+ CHR(13)+CHR(10)+CHR(13)+CHR(10)+cTextoAlert,'Orçamento',NumPedInternet ))
		_lApaga    := .F. // Não apaga o arquivo
		cTextoAlert:=' '
		Return //Abandona a rotina por inconsistência nos Dados
	Endif

	AADD(aCabec,{"UA_PEDWEB"		,NumPedInternet ,Nil})
   	AADD(aCabec,{"UA_STPWEB"		,"S"   			,Nil})//| controle de atualizacao
	AADD(aCabec,{"UA_CLIENTE"		,cCliente 	    ,Nil})
	AADD(aCabec,{"UA_LOJA"			,cLoja      	,Nil})
	AADD(aCabec,{"UA_CODCONT"  		,iContato      	,Nil})
	AADD(aCabec,{"UA_TRANSP"		,iTransp		,Nil})	//Transportadora
	AADD(aCabec,{"UA_CONDPG"		,iCondPag   	,Nil})	//Condicao de Pagamento
	AADD(aCabec,{"UA_TABELA"		,'001'   	    ,Nil})	//Condicao de Pagamento
	AADD(aCabec,{"UA_OPERADO"		,'055615'  	    ,Nil})	//cOper Codigo do Operador
	AADD(aCabec,{"UA_OPER"			,iOperacao		,Nil})	//1-Faturamento 2-Orcamento 3-Atendimento
	AADD(aCabec,{"UA_TMK"			,"1"			,Nil})	//1-Ativo 2-Receptivo
	AADD(aCabec,{"UA_TPFRETE"   	,iTpFrete       ,Nil})	//Tipo de Frete C=Cif F=Fob
	AADD(aCabec,{"UA_REEMB"     	,'N'            ,Nil})
	AADD(aCabec,{"UA_CREDICM"   	,'N'            ,Nil})
	AADD(aCabec,{"UA_ENDOSSO"   	,'N'            ,Nil})

	//| Cristiano
	AADD(aCabec,{"UA_OBSEXP"   		,cObsexp        ,Nil})
	AADD(aCabec,{"UA_MENNOTA"   	,cMenNota       ,Nil})
	AADD(aCabec,{"UA_OCCLI"   		,cOcCli         ,Nil})
	AADD(aCabec,{"UA_FRETCAL"       ,cFreteDestac   ,Nil})

	If cFreteCif='1'
	AADD(aCabec,{"UA_FRETE"         ,iValFrete      ,Nil})

	Endif

	SE4->( dbSeek( xFilial("SE4") + iCondPag ) )  // Posiciona Condicao
	nAcreCond := 1 + ( SE4->E4_ACRSFIN / 100 )    // Calcula o percentual de acréscimo na condição de pagamento

	For nX := 1 To Len(aIt_Ped)

		aLinha := {}

		iProduto := aIt_Ped[ nX, 2 ]  // Código do produto (arquivo)
		iQtd     := aIt_Ped[ nX, 3 ]  // Quantidade (arquivo)
		iVrunit  := aIt_Ped[ nX, 4 ]  // Valor unitário da mercadoria (arquivo - já é com acréscimo)
		iVrConc  := aIt_Ped[ nX, 5 ]  // Valor do concorrente

		  SB1->(DbSeek(xFilial("SB1")+iProduto))

    	  cTes:=SB1->(U_FPARTES("S","N"))

		   If Empty(cTes)
		     cTes :=GetMv("MV_TESPADR",,"501")
		   Endif


		If Empty(iProduto)
			cTextoAlert:='-> Código do Produto vazio'
		ElseIf iQtd=0
			cTextoAlert+=Chr(13)+Chr(10)+'-> Quantidade do Produto zerada'
		ElseIf iVrunit=0
			cTextoAlert+=Chr(13)+Chr(10)+'-> Valor unitário do Produto zerado'
		Endif

		If!Empty(cTextoAlert) //Houve inconsistências
			SF4->( U__Alerta(1,'Orçamento'+' Web Nº'+NumPedInternet +'- Filial '+SM0->M0_CODFIL+' não importado para o cliente '+cCliente+'/'+cLoja +CHR(13)+CHR(10)+CHR(13)+CHR(10)+'INCONSISTÊNCIAS'+ CHR(13)+CHR(10)+CHR(13)+CHR(10)+cTextoAlert,'Orçamento',NumPedInternet ))
			_lApaga    := .F. // Não apaga o arquivo
			cTextoAlert:=' '
			Return //Abandona a rotina por inconsistência nos Dados
		Endif


		cItemNovo   := Soma1( cItemNovo, 2 ) // Incrementa o item em + 1

		nVlrUnit    :=  Round(iVrunit / nAcreCond,4) // Valor unitário sem acréscimo (o valor que vem no arquivo já é com acréscimo)

		nVlrTotItem := A410Arred( iQtd * iVrunit, "UB_VLRITEM" ) // Valor total do item (já com o acréscimo)

		nTotalPed   += nVlrTotItem  // Incrementa o valor total do pedido

		dDatEntreg  := DDATABASE    // Data de entrega
		cHourNecCl  := StrZero( Val( SubStr( Time(), 1, 2 ) ) + 1 , 2 ) + SubStr( Time(), 4, 2 ) // Hora

		aAdd( aLinha, { "UB_PRODUTO" , iProduto                       ,Nil } )
		aAdd( aLinha, { "UB_ITEM"    , cItemNovo                      ,Nil } )
		aAdd( aLinha, { "UB_QUANT"   , iQtd                        	  ,Nil } )
		aAdd( aLinha, { "UB_VRUNIT"  , nVlrUnit                       ,Nil } )
		aAdd( aLinha, { "UB_VLRITEM" , nVlrTotItem            	      ,Nil } )
		aAdd( aLinha, { "UB_DTENTRE" , dDatEntreg                     ,Nil } )
		aAdd( aLinha, { "UB_DTNECLI" , dDatEntreg                     ,Nil } )
		aAdd( aLinha, { "UB_HRNECLI" , cHourNecCl                     ,Nil } )
		aAdd( aLinha, { "UB_VRCACRE" , iVrunit                        ,Nil } )
		aadd(aLinha , { "UB_TES"     , cTes                           ,Nil } )
		aAdd( aLinha, { "UB_LOCAL"   , '01'                           ,Nil } )

		aAdd( aItens, aLinha ) // Inclui o item no array dos itens para o ExecAuto

		// Jean Rehermann - 14/05/2010 - Alteração para gravar o preço do concorrente (SU2) - Chamado Call Tracking AAZS72
		If iVrConc > 0

			cSeq_ID:=_GetISeqU2()

			Conout ('SEQID = ' +cSeq_ID)

			SU2->( RecLock( "SU2", .T. ) )

			SU2->U2_COD     := iProduto
			SU2->U2_MARCACO := Posicione( "SB1", 1, xFilial("SB1") + iProduto, "B1_MARCA" )
			SU2->U2_CODCON  := '000372'
			SU2->U2_CONCOR  := 'NAO INFORMADO                           '
			SU2->U2_PRECO   := iVrConc
			SU2->U2_PRCCIPI := '2'
			SU2->U2_QUANT   := iQtd
			SU2->U2_PRAZO   := Posicione( "SE4", 1, xFilial("SE4") + iCondPag, "E4_COND" )
			SU2->U2_TPFRETE := iTpFrete
			SU2->U2_DTATUAL := dDataBase
			SU2->U2_HRATUAL := StrTran( Left( Time(), 5 ), ":" , "" )
			SU2->U2_OPERADO := cOper
			SU2->U2_FILATEN := cFilCliente
			SU2->U2_SEQID   := cSeq_ID

			SU2->( MsUnlock() )
		EndIf

	Next nX


	Conout('Empresa - ANTES DO RPCSETENV : '+SM0->M0_CODIGO+" Filial : "+SM0->M0_CODFIL+"-"+SM0->M0_NOME+CHR(13)+CHR(10))



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Executa a chamada da rotina de atendimento CALL CENTER       |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 //   Begin Sequence
 	  SUB->(TMKA271(aCabec,aItens,3,"2")) //-- Cabecalho / Itens / Opcao / Opcao do Folder (1 - Telemarketing, 2 - Televendas, etc)

    //End Sequence


	If  lMsErroAuto
		MostraErro( cPathLogs + "/logs/" )
		SF4->( U__Alerta(2,Iif(iOperacao=='1','Pedido de Venda','Orçamento')+' Web Nº'+NumPedInternet +'- Filial '+SM0->M0_CODFIL+' não importado para o cliente '+cCliente+'/'+cLoja +' em '+DTOC(DDATABASE)+' ás '+Time() +', ver log em "' + cPathLogs + '/logs/sc____.log',Iif(iOperacao=='1','Pedido de Venda','Orçamento'),NumPedInternet ))
		_lApaga := .F. // Não apaga o arquivo
		Return //Abandona a rotina por inconsistência nos Dados
	Else

		_cQuery := "SELECT UA_FILIAL, UA_NUM FROM "+ RetSqlName("SUA") +" WHERE UA_PEDWEB = '"+ NumPedInternet +"' AND D_E_L_E_T_ <> '*'"
		Iif( Select("UAPWEB") <> 0, UAPWEB->( dbCloseArea() ), ) // Verifico se a area não está em uso.
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),"UAPWEB",.F.,.T.) // Crio a area.
		While !UAPWEB->( Eof() )
			_cFilSUA := UAPWEB->UA_FILIAL
			_cNumSUA := UAPWEB->UA_NUM
			UAPWEB->( dbSkip() )
		EndDo
		UAPWEB->( dbCloseArea() )

		SF4->(U__Alerta(0,Iif(iOperacao=='1','Pedido de Venda','Orçamento')+' Web Nº'+NumPedInternet+" Orçamento Imdepa "+ _cNumSUA+'- Filial '+SM0->M0_CODFIL+' Importado com Sucesso para o cliente '+cCliente+'/'+cLoja +' em '+DTOC(DDATABASE)+' ás '+Time(),Iif(iOperacao=='1','Pedido de Venda','Orçamento'),NumPedInternet ))



		// Jean Rehermann - 17/05/2010 - Se tiver itens consultados sem estoque, grava na ZA0 - Chamado Call Tracking AAZS74
		If Len( _aCons ) > 0
			For nX := 1 To Len( _aCons )
				ZA0->( RecLock( "ZA0", .T. ) )

				ZA0->ZA0_FILIAL := cFilCliente
				ZA0->ZA0_NUMORC := _cNumSUA
				ZA0->ZA0_PRODUT := _aCons[ nX, 2 ]
				ZA0->ZA0_QUANTD := _aCons[ nX, 3 ]
				ZA0->ZA0_QOFERT := _aCons[ nX, 3 ]
				ZA0->ZA0_VOFERT := _aCons[ nX, 3 ] * _aCons[ nX, 4 ]
				ZA0->ZA0_DTOFER := dDataBase
				ZA0->ZA0_HROFER := StrTran( Left( Time(), 5 ), ":" , "" )
				ZA0->ZA0_DTNECL := dDataBase
				ZA0->ZA0_HRNECL := StrTran( Left( Time(), 5 ), ":" , "" )
				ZA0->ZA0_SEQID  := nX
				ZA0->ZA0_PRECO  := _aCons[ nX, 4 ]

				ZA0->( MsUnlock() )
			Next
		End If

	Endif

Endif

lMsErroAuto   :=.F.  // Volta a variável lMsErroAuto para o seu estado inicial
_lApaga       :=.T.  // Libera o arquivo para Delecao
__RpcCalled   := Nil // Reseta o RPCSETENV

Return


Static Function _GetISeqU2()

Local cSeqId  :=' '

cQuery :="SELECT MAX(U2_SEQID)MaxID FROM "
cQuery += RetSqlName( "SU2" )
cQuery +=" WHERE "
cQuery +=" D_E_L_E_T_ <> '*'"

TCQUERY cQuery NEW ALIAS "MAX_U2"

dbSelectArea("MAX_U2")

cSeqId := Soma1(Alltrim(MAX_U2->MaxID))

MAX_U2->( DbCloseArea() )


Return(cSeqId)


User Function _Alerta(nCriticidade,cMsg,cTipo,cPedInternet )

Local _cAccount   := "protheus@imdepa.com.br"
Local cTo         := GetMV("MV_LOGB2B" )
Local cHtml       := ' '
Local cIcone      := ' '
Local cAssunto    := ' '
Local cTitulo     := ' '



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄiD¿
//           CÓDIGO DE CRITICIDADE VÁLIDO                  ³
//======================================================== ³
//³0 - Job Executado Normalmente                           ³
//³1 - Criticidade média (somente  um alerta para analise) ³
//³2 - Criticidade Alta (Erro, o Job não executou )        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄiDÙ


If nCriticidade=0

	cAssunto 	:= 'B2B - Informação - '+cTipo+' Internet Nº '+cPedInternet
	cIcone     := 'info.gif'
	cHtml      := '<center><h1>B2B - '+cTipo+' Nº'+cPedInternet +' Importado com sucesso </h1></center>'
	cTitulo    := cTipo+' importado com sucesso !"

ElseIf nCriticidade=1

	cAssunto 	:= 'B2B - Alerta - '+cTipo+' Internet Nº '+cPedInternet+' não importado  '
	cIcone       := 'attention.gif'
	cHtml        := '<center><h1>B2B - '+cTipo+ ' não importado </h1></center>'
	cTitulo      := cTipo+' não importado ! '


ElseIf nCriticidade=2
	cAssunto 	:= 'B2B - Erro - '+cTipo+' Internet Nº '+cPedInternet
	cIcone      := 'Error.gif'
	cHtml       := '<center><h1>B2B - '+cTipo+ ' não importado </h1></center>'
	cTitulo     := cTipo+' não importado !'
Endif


cHtml+='<hr width=100% noshade>' + CRLF

cHtml+='<img src="http://www.imdepa.com.br/CallTracking/'+cIcone+'"><FONT size="3">'+cMsg+'</FONT>'+ CRLF   + CRLF

CONNECT SMTP SERVER GetMv("MV_RELSERV") ACCOUNT GetMv("MV_RELACNT") PASSWORD GetMv("MV_RELPSW")
SEND MAIL FROM _cAccount TO ' ' BCC cTo SUBJECT cAssunto BODY cHtml
DISCONNECT SMTP SERVER

Return
