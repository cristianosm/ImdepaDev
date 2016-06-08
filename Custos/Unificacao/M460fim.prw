#include "topconn.ch"
#include "rwmake.ch"
#define  X_DOLAR  "2"
#Define  CRLF  (chr(13) + chr(10))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460FIM   ºAutor  ³Raul                º Data ³  April/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada apos a gravacao de Nota fiscal             º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico para o cliente Imdepa                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cristiano M ³Out/2013³ Reestruturacao Total e Utilizacao de Classe no  ³±±
±±³            ³        ³ calculo da Margem e custos em geral             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
*******************************************************************************
User Function M460FIM()
*******************************************************************************

	Local area 				:= GetArea()
	Private lGeralog 		:= .F.

	Private nDescIcmPad		:= 0, nValDifICM		:= 0, nDescComExp		:= 0
	Private nAcrComExp  	:= 0

	Private cImdepa 			:= GetMv('MV_IMDEPA') //CODIGO DA IMDEPA NO CADASTRO DE CLIENTES (SA1) E DE FORNECEDORES (SA2), PARA FINS DE TRANSFERENCIA ENTRE FILIAIS.
	//Private cCustoNF  		:= GetMV("MV_CUSTONF",," ")

	Private _cEndosso 		:= '', _cCredicm 		:= '', _cReemb   		:= ''

	Public cUFOri 			:= " "

	OrdenaTabeIndex() // Ordena Todas as Tabelas Utilizadas no Fonte

	//Retorna uma string com o nome do ambiente (environment) em execução no Application Server.
	GetEnvServer()

	// Somente se for devolucao, gerou nota de credito ao cliente e estah posicionado nela
	// Obs.: devera jah estar posicionado no sf2, sd2 e se2
	Grava_Natureza()

	// Grava Dados da Nota no CallCenter
	Grava_DadosSUA()

	// Edivaldo Gonlcalves Cordeiro  |Envio dos Boletins de Entrada
	fItensBoletim()

	// Segue Somente quando atualiza financeiro e quando for nota de venda
	If SF4->F4_DUPLIC == 'S' .Or. !SF2->F2_TIPO $ 'BD'
		Processa_Nota()
	Endif

	RestArea( area )

Return()
*******************************************************************************
Static Function Processa_Nota()
*******************************************************************************

	Private lucro				:= 0, nTOTTotItemSemIPI		:= 0
	Private nFreteItem		:= 0, nIMCTot						:= 0, nIMCgTot			:= 0

	Private nMCTot				:= 0, nMCgTot						:= 0, nMCRTot			:= 0
	Private nIMCRTot			:= 0, nIMCUCTot					:= 0, nQtdItem 		:= 0
	Private _nFreteCf 		:= 0, nItens							:= 0

	Private nMCUCTot			:= 0, nQtdItemTotal 	:= 0

	Private cChaveSD2 		:= "SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE"
	Private cChaveSF2 		:= "SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE"

	Private oPedido	//Classe que Calcula Custos... Custos_Class.Prw


	// Define o desconto de ICMS padrao                     
	DbSelectArea("SA1")
	DbSeek(xFilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA, .F.)
	If Empty( SA1->A1_EST )
		Alert("O estado do cliente ["+SF2->F2_CLIENTE+"] loja ["+SF2->F2_LOJA+"] nao foi informado, acione o suporte Microsiga.")
	EndIf

	DbSelectArea("SD2")
	DbSeek( xFilial('SD2')+SF2->F2_DOC+SF2->F2_SERIE, .F. )

	aItemSD2 := ITEMSD2( xFilial('SD2') , SF2->F2_DOC , SF2->F2_SERIE )

	oPedido := oPedido():New( SC5->C5_NUM )

	DbSelectArea("SD2")
	While ( !Eof() .AND. &cChaveSD2. == &cChaveSF2. )

		nItens += 1
		Processa_Item()

		DbSelectArea("SD2")
		DbSkip()

	End While

	oPedido():Grava_Total()

	oPedido():SalvaLog()
	
	
	ContasaReceber()

	//oPedido := oPedido():RestAreas()

Return()
*******************************************************************************
Static Function Processa_Item()
*******************************************************************************

//|	Deve posicionar [ SC6 ],[SB1],[SB2] caso ja nao esteja posicionado...

	If ( SB1->B1_FILIAL + SB1->B1_COD <> SD2->D2_FILIAL + SD2->D2_COD )
		DbSelectArea("SB1");	DbSeek(xFilial("SB1")+SD2->D2_COD, .F. )
	EndIf
	If ( SB2->B2_FILIAL + SB2->B2_COD <> SD2->D2_FILIAL + SD2->D2_COD )
		DbSelectArea("SB2");	DbSeek(xFilial("SB2")+SD2->D2_COD+SD2->D2_LOCAL, .F. )
	EndIf
	If ( SC6->C6_FILIAL + SC6->C6_PRODUTO <> SD2->D2_FILIAL + SD2->D2_COD )
		DbSelectArea("SC6");	DbSeek(xFilial("SC6")+SD2->D2_PEDIDO + SD2->D2_ITEM + SD2->D2_COD, .F. )
	EndIf
	DbSelectArea("SD2")

	oPedido:Add_Produto()

	oPedido:Calc_Custos(nItens)

	oPedido:Grava_Item()

Return
*******************************************************************************
Static Function ContasaReceber()
*******************************************************************************

Local TotalVenda		:= 0
Local TotLucro1	 	:= 0

	/*//| Calcula o total a receber da nota
	DbSelectArea("SE1")
	DbSeek( xFilial('SE1')+SF2->F2_SERIE + SF2->F2_DOC )
	While !Eof() .AND. SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial('SE1')+SF2->F2_SERIE+SF2->F2_DOC
		If !('-' $ SE1->E1_TIPO )    // desconsidera descontos antecipados
			TotalVenda += SE1->E1_VALOR
		EndIF

		DbSelectArea("SE1")
		DbSkip()
	End While
	*/

	cSql := "select sum(E1_VALOR) TOTAL from se1010 "
	cSql += "Where e1_filial = '  ' and e1_prefixo = '"+SF2->F2_SERIE+"' "
	cSql += "and e1_num = '"+SF2->F2_DOC+"' and e1_filorig = '"+SF2->F2_FILIAL+"' "
	cSql += "and e1_tipo = 'NF' and d_e_l_e_t_ = ' ' " //

	U_ExecMySql( cSql , "AUXE1" , "Q" , .F. )

	TotalVenda := AUXE1->TOTAL

	//| Atualiza as parcelas do contas a receber  com o valor ponderado do lucro
	DbSelectArea("SE1");DbGotop()
	DbSeek( xFilial('SE1')+SF2->F2_SERIE + SF2->F2_DOC )
	Do While !Eof() .AND. SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial('SE1')+SF2->F2_SERIE+SF2->F2_DOC

		RecLock('SE1',.F.)
		SE1->E1_LUCRO1 := ( TotLucro1 *  SE1->E1_VALOR ) / TotalVenda
		SE1->E1_LUCRO2 := ConvMoeda( SF2->F2_EMISSAO, , SE1->E1_LUCRO1 , X_DOLAR )

	//|By Jeferson (Pega os campos do arquivo SUA para posterior gravacao no SE1)
		SE1->E1_ENDOSSO := _cEndosso

		If Empty(SE1->E1_PARCELA) .Or. SE1->E1_PARCELA = 'A'  .Or. SE1->E1_PARCELA = '1'
			SE1->E1_CREDICM := _cCredicm
		Endif
		SE1->E1_REEMB   := _cReemb

	//|Grava flag indicando se o titulo se trata de um Vendor do Contas a Receber
		If SE4->E4_VENDORR == "1"
			SE1->E1_VENDORR := "S"
			SE1->E1_HIST := "VENDOR"
		Endif

		MsUnlock()

		DbSelectArea("SE1")
		DbSkip()

	End Do

Return()
*********************************************************************
Static Function ItemSd2(_Filial,_DOC,_SERIE)
*********************************************************************

	aItemSD2 := {}

	cQuery :=   " "
	cQuery +=	" SELECT  D2_ITEM C_D2_ITEM FROM " + RetSqlName("SD2") + " D2 "
	cQuery +=	"    WHERE D2_DOC = '" + _DOC + "' AND "
	cQuery +=	"		     D2_FILIAL ='"+ _Filial + "' AND "
	cQuery +=	"		     D2_SERIE ='" + _SERIE +  "' AND "
	cQuery +=	"		     D2.D_E_L_E_T_ != '*' "
	cQuery +=	"    ORDER BY D2_DOC, D2_ITEM

	IF SELECT( '__ITEMS' ) <> 0
		dbSelectArea('__ITEMS')
		Use
	Endif

	TCQuery cQuery NEW ALIAS ('__ITEMS')


	DO WHILE   !__ITEMS->(EOF())
		AADD(aItemSD2,C_D2_ITEM)
		__ITEMS->(DBSKIP())
	ENDDO

	DBCloseArea('__ITEMS')

Return aItemSD2
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fItensBoletim ºAutor  ³                º Data ³  April/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega os itens de transferência para envio do Boletim     º±±
±±º          ³de Entrada                                                  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Envia o e-mail dos Boletins de Entrada                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
*******************************************************************************
Static Function fItensBoletim()
*******************************************************************************
	Local cSql:=' '
	Local aItensTransf := {}


	If SF2->F2_CLIENTE == cImdepa .AND. SF4->F4_ESTOQUE = 'S' .AND. SF2->F2_TIPO $ 'ND'  //Nota de Transferência , avisa vendedores da entrada dos produtos na filial

		cSql:=" SELECT D2_COD,D2_QUANT  "
		cSql+=" FROM "+RetSqlName("SD2")+" SD2"
		cSql+=" WHERE "
		cSql+=" D2_FILIAL      ='"+xFilial("SD2")+ "'"
		cSql+=" AND D2_DOC     ='"+SF2->F2_DOC+ "'"
		cSql+=" AND D2_SERIE   ='"+SF2->F2_SERIE+"'"
		cSql+=" AND D2_CLIENTE ='"+SF2->F2_CLIENTE+"'"
		cSql+=" AND D2_LOJA    ='"+SF2->F2_LOJA+"'"
		cSql+=" AND D_E_L_E_T_  <>'*'"

		If( Select("QRY_D2") <> 0 ) // Se a area a ser utilizada estiver em uso, fecho a mesma
			QRY_D2->( dbCloseArea() )
		EndIf

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"QRY_D2",.F.,.T.)

		While !QRY_D2->(EOF())

			aAdd(aItensTransf,{QRY_D2->D2_COD,QRY_D2->D2_QUANT})
			QRY_D2->( dbSkip() )
		EndDo

		QRY_D2->( dbCloseArea() )


		If Len(aItensTransf)>0
			SF1->(U_SendNfTrf(SF2->F2_FILIAL,SF2->F2_CLIENTE,SF2->F2_LOJA,aItensTransf,'SF2'))
		EndIf

	EndIf

Return
*******************************************************************************
Static Function Grava_Natureza()
*******************************************************************************

	Local Ind_SE2			:= 0, Rec_SE2			:= 0 //POSICIONAR NO SE1

	DbSeek( xFilial('SE1')+SF2->F2_SERIE + SF2->F2_DOC )
	If SF2->F2_TIPO == 'D' .And. SE2->E2_TIPO == 'NDF' .And. ( SF2->F2_SERIE + SF2->F2_DOC + SF2->F2_CLIENTE + SF2->F2_LOJA ) == ( SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_FORNECE + SE2->E2_LOJA )

		// busca natureza do titulo de origem
		Ind_SE2 := SE2->( IndexOrd() )
		Rec_SE2 := SE2->( Recno() )

		SE2->( dbSetOrder( 6 ) )

		// Na Imdepa estah configurado para o titulo nao ser gerado com o prefixo igual a serie ( considero errado )...
		SE2->( dbSeek( xFilial( 'SE2' ) + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_SERIORI + SD2->D2_NFORI, .f. ) )
		If !Found()
			SE2->( dbSeek( xFilial( 'SE2' ) + SD2->D2_CLIENTE + SD2->D2_LOJA + ALLTRIM(POSICIONE("SX5",1, XFILIAL("SX5")+"Z3"+SD2->D2_FILIAL , "X5_DESCRI")) + SD2->D2_NFORI, .f. ) )
		EndIf

		cNaturez := SE2->E2_NATUREZ

		SE2->( dbSetOrder( Ind_SE2 ) )
		SE2->( dbGoTo( Rec_SE2 ) )

			// Grava natureza
		SE2->( RecLock( 'SE2', .f. ) )
		SE2->E2_NATUREZ := cNaturez
		SE2->( MsUnlock() )

	EndIf
		// Fim alteracao por Luciano Correa...

Return()
*******************************************************************************
Static Function Grava_DadosSUA()
*******************************************************************************
//³atualizar dados da NF no atendimento do Call Center    	     ³
	If SUA->( DbSeek(xFilial("SUA")+SC5->C5_NUM, .F.))

		// By Jeferson (Pega os campos do arquivo SUA para posterior gravacao no SE1)
		_cEndosso	:= SUA->UA_ENDOSSO
		_cCredicm	:= SUA->UA_CREDICM
		_cReemb  	:= SUA->UA_REEMB
		_nFreteCf	:= SUA->UA_FRETCAL

		Reclock("SUA",.F.)
		SUA->UA_DOC   	:= SF2->F2_DOC 		//| SC9->C9_NFISCAL
		SUA->UA_SERIE 	:= SF2->F2_SERIE 		//| SC9->C9_SERIENF
		SUA->UA_EMISNF	:= SF2->F2_EMISSAO  	//| SC9->C9_DATALIB
		SUA->UA_STATUS	:= "NF."
		SUA->UA_STPB2B	:= "A" //Atualizar enviar novamente ao B2B
		MsUnlock()

	Endif


Return()
*******************************************************************************
Static Function OrdenaTabeIndex() // Ordena Todas Tabelas Utilizadas no Fonte
*******************************************************************************

	DbSelectarea("SUA");DbSetOrder(8)
	DbSelectarea("SA1");DbSetOrder(1)
	DbSelectarea("SC5");DbSetOrder(1)
	DbSelectarea("SC6");DbSetOrder(1)
	DbSelectarea("SB1");DbSetOrder(1)
	DbSelectarea("SB2");DbSetOrder(1)
	DbSelectarea("SD2");DbSetOrder(3)
	DbSelectarea("SE4");DbSetOrder(1)
	DbSelectarea("SE1");DbSetOrder(1)
	DbSelectarea("SC9");DbSetOrder(1)
	DbSelectarea("SZW");DbSetOrder(1)
	DbSelectarea("SE3");DbSetOrder(1)
	DbSelectarea("SE2");DbSetOrder(6)

Return()
*******************************************************************************
Static Function GravaLog()
*******************************************************************************

	cGeraLog := ""
	cGeraLog +=	" Filial             -> "+ (SC6->C6_FILIAL) 				+ CRLF
	cGeraLog +=	" Pedido             -> "+ (SC6->C6_NUM) 					+ CRLF
	cGeraLog +=	" Nota               -> "+ (SC6->C6_NOTA) 				+ CRLF
	cGeraLog +=	" Cliente            -> "+ (SC6->C6_CLI) 					+ CRLF
	cGeraLog +=	" Produto            -> "+ (SB1->B1_COD) 					+ CRLF
	cGeraLog +=	" Ncm                -> "+ (SB1->B1_POSIPI) 				+ CRLF
	cGeraLog +=	" nVlrItem           -> "+ cValToChar(nVlrItem) 			+ CRLF
	cGeraLog +=	" n_COMIS1           -> "+ cValToChar(n_COMIS1) 			+ CRLF
	cGeraLog +=	" n_COMIS2           -> "+ cValToChar(n_COMIS2) 			+ CRLF
	cGeraLog +=	" n_COMIS3           -> "+ cValToChar(n_COMIS3) 			+ CRLF
	cGeraLog +=	" n_COMIS4           -> "+ cValToChar(n_COMIS4) 			+ CRLF
	cGeraLog +=	" n_COMIS5           -> "+ cValToChar(n_COMIS5) 			+ CRLF
	cGeraLog +=	" nValIcmSt          -> "+ cValToChar(nValIcmSt) 		+ CRLF
	cGeraLog +=	" nIcmRetido         -> "+ cValToChar(nIcmRetido) 		+ CRLF
	cGeraLog +=	" nValDesp           -> "+ cValToChar(nValDesp) 			+ CRLF
	cGeraLog +=	" nAcreCon           -> "+ cValToChar(nAcreCon) 			+ CRLF
	cGeraLog +=	" nRedPis            -> "+ cValToChar(nRedPis) 			+ CRLF
	cGeraLog +=	" nRedCof            -> "+ cValToChar(nRedCof) 			+ CRLF
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

	cArquivo := "C:\LOG_CUSTO - "+SC6->C6_FILIAL+"_"+SC6->C6_NUM+"_"+SC6->C6_PRODUTO+"_NFS.txt"

	Memowrit(cArquivo , cGeraLog )

Return
