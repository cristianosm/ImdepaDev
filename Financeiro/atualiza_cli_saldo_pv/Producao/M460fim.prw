#include "topconn.ch"
#include "rwmake.ch"
#define  X_DOLAR  "2"
#Define  CRLF    (chr(13)+chr(10))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460FIM   ºAutor  ³Raul                º Data ³  April/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada apos a gravacao de Nota fiscal             º±±
±±º          ³                                                            º±±
±±ºAlteracao ³Gravacao dos campos E1_ENDOSSO,E1_CREDICM E E1_REEM,        º±±
±±º          ³campos estes para filtro na geracao do bordero. (O rela-    º±±
±±º          ³cionamento destes campos sao com o arquivo SUA.             º±±
±±º          ³Gravacao do lucro e margem nos arquivos SD2 e SE1           º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico para o cliente Imdepa                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Expedito    ³06/04/06³ Verificacao de inconsistencia nas tabelas e     ³±±
±±³            ³        ³ geracao de log.                                 ³±±
±±³MarcioQ.Borg³19/09/07³ Ajuste na amarração do itemSD2 com o acols      ³±±
±±³MarcioQ.Borg³20/05/08³ Desonera MC qdo Sit.Trib,considera icm retido   ³±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
*********************************************************************
User Function M460FIM()
*********************************************************************

Local nAcreFin
Local nAcreReal
Local nDescLucro
Local custoTotal       // custo total do produto vindo da planilha
Local totLucro1 	:= 0     // Lucro total em reais
Local lucro
Local totalVenda 	:=0    // Valor total da venda
Local cTpCust
Local area 			:= GetArea()
Local lGeralog := .F. // GetMv('IM_LOGCUST')  //AJUSTADO 27/12/2012 - CRISTIANO
Local nPercFrete
Local nFreteItem
Local nDecVLRITEM := TamSx3("D2_PRCVEN")[2]  // TamSx3("UB_VLRITEM")[2]
Local nDecBASEICM := TamSx3("D2_BASEICM")[2]
Local nIMC := 0, nIMCg  := 0, nIMCR  := 0, nIMCUC := 0
Local nMCTot:= 0,nMCgTot:= 0,nMCRTot:= 0,nMCUCTot:= 0,nIMCTot:= 0,nIMCgTot:= 0,;
nIMCRTot:= 0,nIMCUCTot:= 0,nTOTTotItemSemIPI:= 0, nQtdItem := 0
Local nQtdTotal		:= 0 , nIdadeTotal 	:= 0 , nQtdItem_X_nIdadeTOTAL := 0 , nQtdItemTotal := 0
Local _nFreteCf := 0
Local nValDesc :=0
Local lRedesp :=.F.

// By Jeferson (Pega os campos do arquivo SUA para posterior gravacao no SE1)
Local _cEndosso := ''
Local _cCredicm := ''
Local _cReemb   := ''
Local nSimD2Total, nSimDescLucro, nSimValDifICM, nSimPercFrete, nSimFreteItem, nSimLucro
Local nFatores

Private cImdepa := GetMv('MV_IMDEPA') //CODIGO DA IMDEPA NO CADASTRO DE CLIENTES (SA1) E DE FORNECEDORES (SA2), PARA FINS DE TRANSFERENCIA ENTRE FILIAIS.

Private  aItensTransf   :={}
Private  nDescIcmPad	:= 0
Private  nValDifICM	 	:= 0
Private  nDescComExp	:= 0
Private  nAcrComExp  := 0

Public cUFOri := " "

// incluido por Luciano Correa em 19/03/04 para gravar natureza em ndfs...
Private Ind_SE2, Rec_SE2, cNaturez

Private cCustoNF  := GetMV("MV_CUSTONF",," ")

GetEnvServer()


//Inserido por Edivaldo Goncalves Cordeiro - Grava Comissoes por Operador
cComisPorOperador(SC5->C5_VEND1,SE3->E3_NUM)





// Verifica se ha alguma inconsistencia e caso haja, gera log
VerIncons()

IF SF2->F2_FILIAL = '13'
   U__CORCOMIS() // Corrigi as comissões de Curitiba com TES com percentual de icms diferido - Agostinho 23/03/2010
ENDIF



// somente se for devolucao, gerou nota de credito ao cliente e estah posicionado nela
// Obs.: devera jah estar posicionado no sf2, sd2 e se2

If SF2->F2_TIPO == 'D' .and. SE2->E2_TIPO == 'NDF' .and. ;
	( SF2->F2_SERIE + SF2->F2_DOC + SF2->F2_CLIENTE + SF2->F2_LOJA ) == ;
	( SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_FORNECE + SE2->E2_LOJA )

	// busca natureza do titulo de origem
	Ind_SE2 := SE2->( IndexOrd() )
	Rec_SE2 := SE2->( Recno() )

//	SE2->( dbSetOrder( 1 ) )
	SE2->( dbSetOrder( 6 ) )

	// na Imdepa estah configurado para o titulo nao ser gerado com o prefixo igual a serie ( considero errado )...
	SE2->( dbSeek( xFilial( 'SE2' ) + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_SERIORI + SD2->D2_NFORI, .f. ) )
//	SE2->( dbSeek( xFilial( 'SE2' ) + &( GetMv( "MV_2DUPREF" ) ) + SD2->D2_NFORI, .f. ) )
	IF !FOUND()  //  Compatiblizar para encontrar os titulos  gerados com os prefixos das filias, antes da alteração do parametro MV_2DUPREF para SF1->F1_SERIE em 14/02/2013
	    SE2->( dbSeek( xFilial( 'SE2' ) + SD2->D2_CLIENTE + SD2->D2_LOJA + ALLTRIM(POSICIONE("SX5",1, XFILIAL("SX5")+"Z3"+SD2->D2_FILIAL , "X5_DESCRI")) + SD2->D2_NFORI, .f. ) )
	ENDIF
	cNaturez := SE2->E2_NATUREZ

	SE2->( dbSetOrder( Ind_SE2 ) )
	SE2->( dbGoTo( Rec_SE2 ) )

	// grava natureza
	SE2->( RecLock( 'SE2', .f. ) )
	SE2->E2_NATUREZ := cNaturez
	SE2->( MsUnlock() )
EndIf
// fim alteracao por Luciano Correa...


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³atualizar dados da NF no atendimento do Call Center    	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

_cNumLig := SC5->C5_NUM

DbSelectarea("SUA");DbSetOrder(8)

If DbSeek(xFilial("SUA")+_cNumLig)

	// By Jeferson (Pega os campos do arquivo SUA para posterior gravacao no SE1)
	_cEndosso := SUA->UA_ENDOSSO
	_cCredicm := SUA->UA_CREDICM
	_cReemb   := SUA->UA_REEMB
	_nFreteCf := SUA->UA_FRETCAL

	Reclock("SUA",.F.)
	SUA->UA_DOC   := SF2->F2_DOC 		// SC9->C9_NFISCAL
	SUA->UA_SERIE := SF2->F2_SERIE 		// SC9->C9_SERIENF
	SUA->UA_EMISNF:= SF2->F2_EMISSAO   // SC9->C9_DATALIB
	SUA->UA_STATUS:= "NF."
    SUA->UA_STPB2B:= "A" //Atualizar enviar novamente ao B2B
	MsUnlock()
Endif

 // Edivaldo Gonlcalves Cordeiro  |Envio dos Boletins de Entrada
  If SF2->F2_CLIENTE==cImdepa .AND. SF4->F4_ESTOQUE = 'S' .AND. SF2->F2_TIPO $ 'ND'  //Nota de Transferência , avisa vendedores da entrada dos produtos na filial

      SF2->(fItensBoletim())

	     If Len(aItensTransf)>0
           SF1->(U_SendNfTrf(SF2->F2_FILIAL,SF2->F2_CLIENTE,SF2->F2_LOJA,aItensTransf,'SF2'))
         EndIf

  Endif


// Somente quando atualiza financeiro e quando for nota de venda
If SF4->F4_DUPLIC <> 'S' .or. SF2->F2_TIPO $ 'BD'
	RestArea( area )
	Return
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define o desconto de ICMS padrao                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SA1')
dbSetOrder(1) // filial+codigo+loja
MsSeek(xFilial('SA1')+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)
If Empty( SA1->A1_EST )
	Alert("O estado do cliente ["+SF2->F2_CLIENTE+"] loja ["+SF2->F2_LOJA+"] nao foi informado, acione o suporte Microsiga.")
EndIf

/* Desativo por Edivaldo
///| Chamado: AAZVO2  Analista: Cristiano Machado
///| Atualiza as Informacoes no campos A1_SALPED "Saldo em Pedido" , A1_SALPEDL "Saldo em Pedido Liberado"
oPvSldFin := PvSldFin():Novo( SA1->A1_COD , SA1->A1_LOJA )
oPvSldFin:AtuCliente()
*/

///| Fim AAZVO2


///JULIO JACOVENKO, 27/12/2012
//| Verifica Desconto ICMS e Comercial Exportadora
//DesICMPad(SA1->A1_EST)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o campo especifico F2_FILCLI                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reclock("SF2",.F.)
SF2->F2_FILCLI := SA1->A1_FILCLI
MsUnlock()

dbSelectArea('SC5');dbSetOrder(1) // filial+pedido

dbSelectArea('SC6');dbSetOrder(1) // filial+pedido+item

dbSelectArea("SB1");dbSetOrder(1) // Produtos

dbSelectArea('SB2');dbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

dbSelectArea('SD2');dbSetOrder(3) // filial+doc+serie

dbSeek( xFilial('SD2')+SF2->F2_DOC+SF2->F2_SERIE )

cTabPreco 	:= SC5->C5_TABELA
cMoeda		:= SC5->C5_MOEDA
cCondPag 	:= SF2->F2_COND

aItemSD2 := ITEMSD2( xFilial('SD2'),SF2->F2_DOC,SF2->F2_SERIE)


dbSelectArea("SE4");dbSetOrder(1);dbseek(xFilial("SE4")+cCondPag)  // cONDICAO DE pAGAMENTO

nItemSD2	:= 0





Do While  SD2->(!Eof()) .AND. SD2->D2_FILIAL == xFilial('SD2') .AND. SD2->D2_DOC == SF2->F2_DOC  .AND. SD2->D2_SERIE == SF2->F2_SERIE
	//	nItemSD2 := ITEMSD2(SD2->D2_ITEM)

	nItemSD2 := aScan(aItemSD2, SD2->D2_ITEM)

	//------> Posiciona nas Tableas

	// localiza a tabela de precos utilizada
	SC5->( MsSeek( xFilial('SC5')+SD2->D2_PEDIDO,.F. ))

	// localiza o custo da embalagem
	SC6->( MsSeek( xFilial('SC6')+SD2->D2_PEDIDO+SD2->D2_ITEMPV,.F. ))

	//³Posicionando de TES	         			     ³
	SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
	//-----> Carrega variaveis

	cProduto 	:= SD2->D2_COD
	cLocal	 	:= SD2->D2_LOCAL
	nVlrItem 	:= SD2->D2_PRCVEN  //TOTAL DA LINHA COM ACRESCIMO
	nBASEICM 	:= SD2->D2_BASEICM
	nQtdItem 	:= SD2->D2_QUANT
	nDescIcm 	:= SC6->C6_DESCICM
	nFreteCal 	:= SF2->F2_FRETE
	nValmerc 	:= SF2->F2_VALMERC //VALOR TOTAL DAS MERCADORIAS COM ACRESCIMMO DA CONDIÇÃO DE PAGAMENTO
	nDespesa	:= SF2->F2_DESPESA


	///IDADE FILIAL
	nIdade 		:= 0
    nFreteFob   := SUA->UA_FRETFOB  // Redespacho
	NIDADESC6   := 0

	///JULIO JACOVENKO, em 25/01/2012
	///Projeto Idade Imdepa
	///
	nIdade2     := 0   //VARIAVEL PADRÃO PARA IDADE2




	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionando Produtos         			     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SB1->(DbSeek(xFilial("SB1")+cProduto+cLocal))




	///////////////JULIO JACOVENKO
	///////////////27/12/2012
	//| Verifica Desconto ICMS e Comercial Exportadora
	////TEM QUE ESTAR AQUI POIS AGORA LE ITEM A ITEM
     SB1->(DesICMPad(SA1->A1_EST))


	//////////////////////////



	// Posiciona no Esoque


	SB2->( MsSeek( xFilial('SB2')+cProduto+cLocal,.F. ))  //busco o armazem da nota (local)



	//------------- MARCIO --------------------------

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ITEM SUB X ITEM ACOLS  	  							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Identifica item do SUB correspondente no alcols

	nItemacols 	:= 0
	nItem 		:= 	nItemSD2

	//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	//º                        CUSTOS        (OBS: qualquer alteração aqui, faça também no TMKVFIM        º
	//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼


	//marcio
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³     CAMPANHAS DE VENDAS								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//  nao precisa de campanha pois pego a meta direto do SC6

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³CALCULO DAS COMISSOES  	  							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	n_COMIS1 := SC6->C6_COMIS1
	n_COMIS2 := SC6->C6_COMIS2
	n_COMIS3 := SC6->C6_COMIS3
	n_COMIS4 := SC6->C6_COMIS4
	n_COMIS5 := SC6->C6_COMIS5

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MARGEM                	  							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// Define variaveis para calculo de custo total e lucro

	// busca acrescimo financeiro
	nAcreFin  := SE4->E4_ACRSFIN/100     //Posicione("SE4",1,xFilial("SE4")+cCondPag,"E4_ACRSFIN") / 100)
	nAcreReal := 1 + (SE4->E4_ACRREAL / 100)

	//Descricao: Calcula a Desoneracao do Custo sobre a SubsTituicao Tributaria | Nome:Cristiano Machado | Data:10/07/08 | Chamado:AAZOEX
	nCustoMC  	:= U_FCusTrib(.F.)

	//Custo Margem de Contribuição Reposicao
	nCustoMCR  :=  U_PrcBase( cProduto,cTabPreco,@cTpCust,.F.,"R") // U_PrcBase( SUB->UB_PRODUTO,SUA->UA_TABELA,@cTpCust,.F.,"R")

	//Custo Margem de Contribuição Média das Ultimas Compras
	nCustoMCUC :=  U_PrcBase( cProduto,cTabPreco,@cTpCust,.F.,"U") // U_PrcBase( SUB->UB_PRODUTO,SUA->UA_TABELA,@cTpCust,.F.,"U")

	// converte o valor total do item para moeda 1
	nVlrItem := IIF(cMoeda==1,nVlrItem,xMoeda(nVlrItem,cMoeda,1,dDataBase,nDecVLRITEM))

	// Valor  TOTAL DO ITEM com acréscimo e sem IPI =  BASE DE ICM  (UB_VRCACRE * UB_QUANT
	nBASEICM := IIF(cMoeda==1,nBASEICM,xMoeda(nBASEICM,cMoeda,1,dDataBase,nDecBASEICM))

	// ***********     Preco de Venda Deflacionado    *********
	// Define o desconto a ser aplicado no lucro devido ao acrescimo financeiro
	// ou seja, é a diferença das despesas financeiras que pago para o banco das que o cliente me paga

	nDescLucro :=  (nBASEICM * nAcreFin) // (NOVO)

	// Calcula o valor da diferenca de ICMS
	nValDifICM := nVlrItem * ( (nDescIcmPad - nDescICM) / 100 )
IF SUA->UA_TPFRETE == "F" .AND. nFretefob !=0
       IF POSICIONE("SZO",1,XFILIAL("SZO")+SUA->UA_CODROTA,"ZO_REDESPA") = "S" //Verifica frete redespacho
          lRedesp := .T.
       END
ENDIF

/*// ALTERACAO POR MOTIVO DA BUILD 20A POR CRISTIANO MACHADO EM 29/11/2012
	If SUA->UA_TPFRETE == "C" .AND. SUA->UA_FRETE != 0
//	If SUA->UA_TPFRETE == "C"
//		nFreteItem	:= nFreteCal / nValmerc	* nVlrItem
        nFreteItem	:= (nFreteCal / nValmerc	* (nVlrItem * nQtdItem))
        nFreteItem	:= nFreteItem - (nFreteItem * 0.2) //MENOS 20%
    Elseif SUA->UA_TPFRETE == "C" .AND. SUA->UA_FRETE = 0
        nFreteItem := (_nFreteCf / nValmerc	* (nVlrItem * nQtdItem))
Elseif lRedesp
        nFreteItem := (nFretefob / nValmerc	* (nVlrItem * nQtdItem)) //Valor Frete de Redespacho
Else
		nFreteItem := 0
Endif
*/

	nDespDOC := nDespesa
	lVerST	 := .F.
	nAlicIcm := nValDesp := nAcreCon := nValFret := nCalcIcm := nAlicIpi := nMVA := nValIcmSt := nIcmRetido := 0


	// RATEIOS
	// Faz o Rateio do frete quando for CIF

	// ALTERACAO POR MOTIVO DA BUILD 20A POR CRISTIANO MACHADO EM 29/11/2012
	nValFret := NoRound(SC6->C6_VALOR / SUA->UA_VALMERC * SUA->UA_FRETE,2) //Valor Frete

	If SUA->UA_TPFRETE == "C" .AND. SUA->UA_FRETE != 0
		nFreteItem		:= nValFret
		nFreteItem		:= nValFret - (nValFret * 0.2) // MENOS 20%
	Elseif SUA->UA_TPFRETE == "C" .AND. SUA->UA_FRETE = 0
		//nFreteItem 		:= NoRound(SC6->C6_VALOR / SUA->UA_VALMERC * nFreteCal,2) //Valor Frete
	 	  nFreteItem 		:= NoRound(SC6->C6_VALOR / SUA->UA_VALMERC * SUA->UA_FRETCAL,2) //Valor Frete Incluso
	Elseif lRedesp
		nFreteItem 		:= NoRound(SC6->C6_VALOR / SUA->UA_VALMERC * nFreteFob,2) //Valor Frete de Redespacho
	Else
		nFreteItem 		:= 0
	Endif


	// Rateio das Despesas por item
	nRatDesp := nDespesa / nValmerc 	* nVlrItem

	// ********** Despesa do DOC - Despesas diversas cobradas do cliente**********
	nDespDOC := nDespesa



	//nITEM :=ascan(acols, {|x| x[X_PRODUTO]+x[X_QTD]==SUB->UB_PRODUTO+SUB->UB_QUANT}) //Ascan(aTotal, {|x| x[1]+Dtos(x[2]) == aList[nStart,4]+Dtos(aList[nStart,9])})

	if nItem > 0
		//      Valor de ICM                          Valor de PIS                 Valor COFINS
		//		IF (cUFOri $ 'MT') // Se for estado de GO ou MT  o icm é zerado
		//			nValICM := 0
		//		ELSE

		// ALTERACAO POR MOTIVO DA BUILD 20A POR CRISTIANO MACHADO EM 29/11/2012
		//nValICM :=	mafisret(nItem,"IT_VALICM")
		// Valor ICMS

		nValDesp := NoRound(SC6->C6_VALOR / SUA->UA_VALMERC * SUA->UA_DESPESA,2) // Despesa DOC

		nAcreCon := NoRound(((SC6->C6_VALOR + (SC6->C6_VALOR / SUA->UA_VALMERC) * SUA->UA_DESPESA) * SE4->E4_ACRSFIN)/100,2) //Acrescimo Condicao

		nValFret := NoRound(SC6->C6_VALOR / SUA->UA_VALMERC * SUA->UA_FRETE,2) //Valor Frete

		nCalcIcm := NoRound((SC6->C6_VALOR  + nValDesp + nAcreCon + nValFret),2)   // Base do Icms

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

			EndIf
		EndIf

		If cFilant == '04' .AND. ( SF4->F4_CODIGO $ '540/721/723' ) // Chamado AAZUTY
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
		Endif


		nAlicIpi := SB1->B1_IPI

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
			nCalcPis	:= NoRound( ( ( nAliqPis - ( ( nAliqPis / 100 ) * nRedPis) ) / 100 ) * (nCalcIcm) , 2 )
			nCalcCof    := 0
		ElseIf SF4->F4_PISCOF == '2'
				nCalcPis	:= 0
		nCalcCof	:= NoRound( ( ( nAliqCof - ( ( nAliqCof / 100 ) * nRedCof) ) / 100 ) * (nCalcIcm) , 2 )
		ElseIf SF4->F4_PISCOF == '3'
			nCalcPis	:= NoRound( ( ( nAliqPis - ( ( nAliqPis / 100 ) * nRedPis) ) / 100 ) * (nCalcIcm) , 2 )
			nCalcCof	:= NoRound( ( ( nAliqCof - ( ( nAliqCof / 100 ) * nRedCof) ) / 100 ) * (nCalcIcm) , 2 )
		Else
			nCalcCof    := 0
			nCalcPis	:= 0
		Endif


		//		ENDIF
		// ALTERACAO POR MOTIVO DA BUILD 20A POR CRISTIANO MACHADO EM 29/11/2012
		// Busca ICMS Retido
	   	//nICMRetido := mafisret(nItem,"IT_VALSOL")  //Idem a isto :	mafisret(nItem,"IT_BASESOL") * mafisret(nItem,"IT_ALIQSOL")/100  - mafisret(nItem,"IT_VALICM")
		If nValIcmSt != 0
			nIcmRetido := NoRound(( nValIcmSt - ( nCalcIcm * ( nAlicIcm / 100) )),2)
		Else
			nIcmRetido := 0
		Endif


		// ALTERACAO POR MOTIVO DA BUILD 20A POR CRISTIANO MACHADO EM 29/11/2012
		//nImpostosnoVlrItem := nValICM + mafisret(nItem,"IT_VALPS2") + mafisret(nITEM,"IT_VALCF2") + nICMRetido // Ver Funcoes Padroes
		nImpostosnoVlrItem 	:= nValICM + nCalcPis + nCalcCof + nICMRetido// ver funções padrões do siga

	Else

		nImpostosnoVlrItem := 0

	Endif


	// ********** COMISSOES ***********************************
	// acrescer 63% ao valor do vendedor interno (comis1) em função de incidência de encargos trabalhistas
	// descimo  terçeiro, férias , etc ----> marcio
	// usado no Interno/Externo/Chefe de Venda
	nVDescComis := nQtdItem * nVlrItem * ( (n_COMIS1 * 1.63)  + n_COMIS2 + (n_COMIS3 * 1.63)  + (n_COMIS4 * 1.63) + (n_COMIS5 * 1.63) )/100
   //	nVDescComis := nQtdItem * nVlrItem * ( (n_COMIS1 * 1.63)  + n_COMIS2 + (n_COMIS3 * 1.63)  + (n_COMIS4 * 1.63) + n_COMIS5)/100

	// *********** Fatores (F´s)
	// nFat1 =  Coeficiente Cambial    (COEFC)
	// nFat2 =  Coeficiente Financeiro (COEFF)
	// nFat3 =  Coeficiente Idade      (COEFI)

	////Idade Filial
	////Ajustado pelo Julio Jacovenko, em 23/05/2012
	////
	NIDADESC6:=u_IdadeAtu(nQtdItem,SB2->B2_IDADE,SB2->B2_DTIDADE) //PARA GRAVAR A IDADE ATUAL NO
	                                                              //SC6

	//SE IDADE2 = 0, USA A IDADE1 (PARA COMPATIBILIZAR)
	//POIS HE PARA USAR A IDADE2 NO PEDIDO
	IF SB2->B2_IDIMDE=0
	  nIdade := u_IdadeAtu(nQtdItem,SB2->B2_IDADE,SB2->B2_DTIDADE)
	ELSE
	  nIdade := u_IdadeAtu(nQtdItem,SB2->B2_IDIMDE,SB2->B2_DTCALC)
	ENDIF



	///JULIO JACOVENKO, em 25/01/2012
	///Projeto Idade Imdepa
	   NIDADEX:=1
	   NIDADEY:=DATE()
	IF SB2->B2_IDIMDE=0
	   NIDADEX:=SB2->B2_IDADE
	   NIDADEY:=SB2->B2_DTIDADE
	ELSEIF SB2->B2_IDIMDE<>0
	   NIDADEX:=SB2->B2_IDIMDE
	   NIDADEY:=SB2->B2_DTCALC
	ENDIF
    nIdade2 := NIDADEX //u_IdadeAtu(nQtdItem,NIDADEX,NIDADEY)  //SB2->B2_DTCALC)
	//////////////////////////////////////////////////////////////


	nTJLPdia  := (1 + (GetMV("MV_TJLP",,0) /100)/12)^(1/30) -1


	nCOEFC:= SB2->B2_COEFC
	nCOEFF:= SB2->B2_COEFF
	nCOEFI:= ((1+ nTJLPdia)^nIdade)- 1

	///JULIO E MARCIA, ACRESCIDO A DIVISAO POR 100
	///
	nFat1 := (SB2->B2_COEFC/100) 	* nCustoMC
	nFat2 := (SB2->B2_COEFF/100) 	* nCustoMC
	nFat3 := nCOEFI			* (nCustoMC+ nfat1 + nfat2)


	nFatores := nFat1 + nFat2 + nFat3

	// ALTERACAO POR MOTIVO DA BUILD 20A POR CRISTIANO MACHADO EM 29/11/2012
	//nTotItemSemIPI  :=  MaFisRet(nItem,"IT_TOTAL") - MaFisRet(nItem,"IT_VALIPI")
	nTotItemSemIPI  	:= NoRound(SD2->D2_PRCVEN * SD2->D2_QUANT + (SC6->C6_VALOR / SUA->UA_VALMERC * SUA->UA_DESPESA ),2) + nICMRetido + nValFret


	//************************
	//Custo médio kardex Gerencial
	nCustoMCg 			:=  nFatores + nCustoMC
	nTxFin  			:=  GETMV("MV_TXFIN",,0)/100  // Similar a Taxa CDI , mas ao mês
	nValCPMF	    	:=  GETMV("MV_CPMF" ,,0)/100  * MaFisRet(nItem,"IT_TOTAL") //GETMV("MV_CPMF" ,,0)/100  * (SUB->UB_VRACRE * (1 + SUB->UB_VALIPI/100))
	nPrazoMedioCobr 	:= 	SE4->E4_PRZMED //criar campo
	nTaxaDiaria 		:=  ((1 + nTxFin )^(1/30))-1
	nValorDeflacionado 	:=  (nTotItemSemIPI / ((1 + nTaxaDiaria) ^ nPrazoMedioCobr ))

	// Margem de Contribuicao não Gerencial (sem os fatores -> F1, F2, F3 ...)


	//nMC   := nValorDeflacionado - (nValCPMF + nCustoMC   * nQtdItem + nImpostosnoVlrItem + nVDescComis + nFreteItem)
	nMC     := nValorDeflacionado - (nValCPMF + nCustoMC  * nQtdItem + nImpostosnoVlrItem + nVDescComis + nFreteItem)

	//|Analista: Cristiano MAchado  |Chamado: AAZPZ2  |Assunto: Calculo Margem Custo Reposicao
	//|Solicitante: Marcia Silveira |Data: 11/05/09
	cSegmento  	:= substr(SA1->A1_GRPSEG,3,1)
	cTpCliFor	:= SA1->A1_TIPO

	lVerST 		:= U_Fsubtrib(xFilial("SUA"),"S","N",cTpCliFor,SA1->A1_EST,SB1->B1_POSIPI,cSegmento,3,'S')//| Verifica se eh ST


	// CHAMADO TECNICO : AAZVST    SOLICITANTE: Marcia Silveira   DATA: 22/08/2013
	// Favor contemplar no cálculo do IMCR nas vendas para fora do Estado, de produtos Importados, a alíquota de 4%, hoje o sistema efetua o cálculo do campo CUSMCR da seguinte forma:
	// Custo standart = 100,00 ( - ) % PIS ( - ) % Cofins ( - ) % ICMS do Estado de origem da venda (ESTE PERCENTUAL NESTA SITUAÇÃO, deve ser substituído pela alíquota de 4%
    // ( = ) Custo Reposição


    If  ( nAlicIcm == GetMv("IM_ICMIMP") ) // Produto Importado e Venda InterEstadual....
		nAuxPis := nAliqPis - ( nAliqPis * nRedPis  /  100 )
		nAuxCof := nAliqCof - ( nAliqCof * nRedCof  /  100 )
		nAuxIcm := nAlicIcm

		nCustoMCR := xMoeda(SB1->B1_CUSTD,Val(SB1->B1_MCUSTD),1,dDataBase) * (( 100 - ( nAuxPis + nAuxCof + nAuxIcm ) ) / 100 )

	EndIf
	// FIM CHAMADO AAZVST

	// CHAMADO TECNICO : AAZVO6    SOLICITANTE: Marcia Silveira
    // Incluir o percentual de 8,25% no custo reposição nas vendas que se enquadram na substituição tributária para as filiais: RS , MT, PR, MG.
	// Ajuste de Mergem Reposicao para ST

	If lverSt

		cFilAjuMar := GetMV("MV_UFAJMGR") // UF's que devem receber o ajuste no custo reposicao...
		cUfFilOrig := SM0->M0_ESTENT /// UF filial origem...

		if ( cUfFilOrig $ cFilAjuMar )

			nCustoMCR  := nCustoMCR * 1.0825 // Acrescimo de 8.25 %

		EndIf
	EndIf

	// AAZV06 - FIM


	nMCR  := nValorDeflacionado - (nValCPMF + nCustoMCR  * nQtdItem + nImpostosnoVlrItem + nVDescComis + nFreteItem)


	//|Analista: Cristiano MAchado  |Chamado: AAZPZ2  |Assunto: Calculo Margem Custo Reposicao
	//|Solicitante: Marcia Silveira |Data: 11/05/09
	If nValICM == 0 .and. (SM0->M0_ESTENT == SA1->A1_EST) .and. (lVerST .OR. ( SM0->M0_ESTENT == "MT" .AND. SA1->A1_EST <> SM0->M0_ESTENT ))
		//nMCR  := nMCR - (((SD2->D2_TOTAL + SD2->D2_DESPESA) * GetMv('MV_ICMPAD'))/100)
		nMCR  := nMCR - ((nCalcIcm * GetMv('MV_ICMPAD')) / 100)
	Endif
	//|FIM Chamado: AAZPZ2

	nMCUC := nValorDeflacionado - (nValCPMF + nCustoMCUC * nQtdItem + nImpostosnoVlrItem + nVDescComis + nFreteItem)

	// Margem de Contribuicao Gerencial (com os fatores -> F1, F2, F3 ...) em Valores
	nMCg   	:= nValorDeflacionado - (nValCPMF + nCustoMCg  * nQtdItem + nImpostosnoVlrItem + nVDescComis + nFreteItem)




	//|Chamado: 	AAZQ5R 			|Assunto: DESONER CUSTO COML EXPORTADORA |Analista: Cristiano MAchado
	//|Solicitante: Marcia Silveira |Data: 28/05/09
	If SC6->C6_TES == '508'

		nAcrComExp := ((nDescComExp * 	(SD2->D2_TOTAL + SD2->D2_DESPESA)) / 100 )

		nMC    := nMC    + nAcrComExp
		nMCR   := nMCR   + nAcrComExp
		nMCUC  := nMCUC  + nAcrComExp
		nMCg   := nMCg   + nAcrComExp

    EndIf
    //FIM AAZQ5R

	// Jorge Oliveira - 07/12/10 - Acrescentar as margens, o Desconto do ICMS ( Filial do Parana e TES 720 e ter Perc. Desc. ICMS )
	If ( cFilAnt == "13" .And. SC6->C6_TES == "720" .And. SC6->C6_DESCICM > 0 )

		nValDesc := Posicione( "SUB", 3, xFilial( "SUB" ) + SC6->C6_NUM + SC6->C6_ITEM, "UB_VDESICM" )

		nMC   += nValDesc
		nMCR  += nValDesc
		nMCUC += nValDesc
		nMCg  += nValDesc

	EndIf
	// Calcula a margem em percentual
	//Indices da Margem de Contribuição (DIVIDIR PELO VALOR TOTAL DA NOTA sem IPI, ou seja é igual a base de ICM )
	// Não Gerencial

// ALTERACAO POR MOTIVO DA BUILD 20A POR CRISTIANO MACHADO EM 29/11/2012
//	nIMC   := U_ValMarg(nMC  / (nTotItemSemIPI - SD2->D2_ICMSRET) * 100) //Valida a margem para manter entre -999.99 e 999.99
//	// Gerencial
//	nIMCg  := U_ValMarg(nMCg  / (nTotItemSemIPI - SD2->D2_ICMSRET) * 100) //Valida a margem para manter entre -999.99 e 999.99
//	nIMCR  := U_ValMarg(nMCR  / (nTotItemSemIPI - SD2->D2_ICMSRET) * 100)
//	nIMCUC := U_ValMarg(nMCUC / (nTotItemSemIPI - SD2->D2_ICMSRET) * 100)

	// ALTERACAO POR MOTIVO DA BUILD 20A POR CRISTIANO MACHADO EM 29/11/2012
	nIMC   := U_ValMarg(nMC  / (nTotItemSemIPI - nIcmRetido)  * 100) //Valida a margem para manter entre -999.99 e 999.99
	// Gerencial
	nIMCg  := U_ValMarg(nMCg  / (nTotItemSemIPI - nIcmRetido) * 100) //Valida a margem para manter entre -999.99 e 999.99
	nIMCR  := U_ValMarg(nMCR  / (nTotItemSemIPI - nIcmRetido) * 100)
	nIMCUC := U_ValMarg(nMCUC / (nTotItemSemIPI - nIcmRetido) * 100)


	//Acumuladores
	nMCTot					+= nMC
	nMCgTot					+= nMCg
	nMCRTot					+= nMCR
	nMCUCTot				+= nMCUC

	nQtdItem_X_nIdadeTOTAL	+= nQtdItem * nIdade

	nQtdItemTotal 			+= nQtdItem
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

		cArquivo := "C:\LOG_CUSTO - "+SC6->C6_FILIAL+"_"+SC6->C6_NUM+"_"+SC6->C6_PRODUTO+"_NFS.txt"

		Memowrit(cArquivo , cGeraLog )

	EndIf


	RecLock('SD2',.F.)

	// Faz a gravacao do lucro, da margem de lucro e do custo total
	//	Replace UB_LUCRO1 with nLucro,UB_MARGEM with nMargem, UB_CUSTIMD with nCusto, UB_TPCUST with cTpCust

	//Grava Margens
	Replace SD2->D2_MC    with nMC		,SD2->D2_MCG    with nMCg	 , SD2->D2_MCR    with nMCR	 	    , SD2->D2_MCUC    with nMCUC

	//Grava Indices das Margens
	Replace SD2->D2_IMC   with nIMC		,SD2->D2_IMCG   with nIMCg	 , SD2->D2_IMCR   with nIMCR	 	, SD2->D2_IMCUC   with nIMCUC

	//Grava Custos das Margens
	Replace SD2->D2_CUSMC with nCustoMC	,SD2->D2_CUSMCG with nCustoMCg, SD2->D2_CUSMCR with nCustoMCR	, SD2->D2_CUSMCUC with nCustoMCUC

	//Grava Coeficientes
	Replace SD2->D2_COEFC with nCOEFC	,SD2->D2_COEFF  with nCOEFF   , SD2->D2_COEFI   with nCOEFI

	//Grava Idade Filial
	Replace SD2->D2_IDADE with nIdadeSC6

	///JULIO JACOVENKO, em 03/04/2012
	///Projeto Idade Imdepa
	///aqui tem que buscar no pedido de venda (SC6)
	///o campo C6_IDIMDE
	//SELECT C6_IDIMDE FROM SC6010
    //WHERE C6_NUM=D2_PEDIDO
    //AND C6_ITEM=D2_ITEMPV

    /*
    ///SO PARA TESTES, DEPOIS TROCAR POR DBSEEK
	cQuery:=""
	cQuery:="SELECT C6_IDADE2 FROM "+RETSQLNAME('SC6')+" "
	cQuery+="WHERE C6_NUM='"+SD2->D2_PEDIDO+"' "
	cQuery+="AND C6_ITEM='"+SD2->D2_ITEMPV+"' "
	cQuery+="AND D_E_L_E_T_ <>'*' "
	cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "TSC6"
	Idade2:=0
	Do While TSC6->(!EOF())
	 nIdade2:=TSC6->C6_IDADE2
	 TSC6->(dBSkip())
	EndDo
	TSC6->(DBCloseArea())
    */



	///busca no SC6 o conteudo do C6_IDADE2
	nIdade2:=0
	if SC6->( MsSeek( xFilial('SC6')+SD2->D2_PEDIDO+SD2->D2_ITEMPV,.F. ))
       nIdade2:=SC6->C6_IDADE2
    endif

	Replace SD2->D2_IDIMDE with nIdade2
	//////////////////////////////////////////////////////

	MsUnlock()

	SD2->(dbSkip())
	//	nItemSD2++
Enddo


nIMCTot 	:= U_ValMarg(nMCTot   / nTOTTotItemSemIPI * 100)
nIMCgTot	:= U_ValMarg(nMCgTot  / nTOTTotItemSemIPI * 100)
nIMCRTot	:= U_ValMarg(nMCRTot  / nTOTTotItemSemIPI * 100)
nIMCUCTot	:= U_ValMarg(nMCUCTot / nTOTTotItemSemIPI * 100)

SF2->(Reclock("SF2",.F.))
SF2->F2_IMC		:= nIMCTot
SF2->F2_IMCG	:= nIMCgTot
SF2->F2_IMCR   	:= nIMCRTot
SF2->F2_IMCUC  	:= nIMCUCTot
SF2->F2_IDADE	:= nQtdItem_X_nIdadeTOTAL / nQtdItemTotal
SF2->(MsUnlock())



dbSelectArea('SE1')
dbSetOrder(1)

// Calcula o total a receber da nota
dbSeek( xFilial('SE1')+SF2->F2_SERIE + SF2->F2_DOC )
Do While !Eof() .AND. SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial('SE1')+SF2->F2_SERIE+SF2->F2_DOC
	IF !('-' $ SE1->E1_TIPO )    // desconsidera descontos antecipados
		totalVenda += SE1->E1_VALOR
	ENDIF
	dbSkip()
Enddo

******************* CONTAS A RECEBER (SE1) *****************************************************************

// Atualiza as parcelas do contas a receber  com o valor ponderado do lucro
dbSeek( xFilial('SE1')+SF2->F2_SERIE + SF2->F2_DOC )
Do While !Eof() .AND. SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial('SE1')+SF2->F2_SERIE+SF2->F2_DOC
	RecLock('SE1',.F.)
	SE1->E1_LUCRO1 := ( totLucro1 *  SE1->E1_VALOR ) / totalVenda
	SE1->E1_LUCRO2 := ConvMoeda( SF2->F2_EMISSAO, , SE1->E1_LUCRO1 , X_DOLAR )

	// By Jeferson (Pega os campos do arquivo SUA para posterior gravacao no SE1)
	SE1->E1_ENDOSSO := _cEndosso
	If Empty(SE1->E1_PARCELA) .Or. SE1->E1_PARCELA='A'  .Or. SE1->E1_PARCELA='1'
		SE1->E1_CREDICM := _cCredicm
	Endif
	SE1->E1_REEMB   := _cReemb


	// grava flag indicando se o titulo se trata de um Vendor do Contas a Receber
	If SE4->E4_VENDORR == "1"
		SE1->E1_VENDORR := "S"
		SE1->E1_HIST := "VENDOR"
	Endif
	MsUnlock()
	dbSkip()
Enddo

/*

If SF4->F4_DUPLIC='S'//Edivaldo Gonçalves Cordeiro
	//Envia a Nota Fiscal por Email para o Cliente e Representante
	MsAguarde({||SF4->(U_EmailNfHtml(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SC5->C5_NUM))},"E-mail Nota Fiscal","Enviando para cliente,representante e coordenador...")
Endif
*/

RestArea( area )

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VERINCONS ³ Autor ³ Expedito Mendonca Jr  ³ Data ³06/06/2006³±±

±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a verificacao de inconsistencias entre as tabelas      ³±±
±±³          ³ SD2 e SC9 e, se houver, gera log. O objetivo desta funcao  ³±±
±±³          ³ eh identificar a origem de problemas na quantidade         ³±±
±±³          ³ reservada dos produtos (B2_RESERVA).                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VERINCONS()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
*********************************************************************
Static Function VERINCONS()
*********************************************************************

Local cQuery, cArea, aAreaSC9, nHdlLog, lOk, lTemSC9

If GETMV("ES_LOGINC")

	// Salva a area atual
	cArea := alias()
	aAreaSC9 := SC9->(Getarea())

	SC9->(dbSetOrder(1))	// C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

	IF SELECT( 'TRB' ) <> 0
		dbSelectArea('TRB')
		Use
	Endif


	// Verifica se houve inconsistencias entre as tabelas SD2 e SC9
	// Monta a query para selecionar registros inconsistentes
	cQuery := "SELECT D2_FILIAL, D2_SERIE, D2_DOC, D2_CLIENTE, D2_LOJA, D2_ITEM, D2_COD, D2_LOCAL, D2_QUANT, D2_PEDIDO, D2_ITEMPV, D2_SEQUEN "
	cQuery += " FROM "+RetSqlName('SD2')+" SD2"
	// Filtra os itens desta nota fiscal
	cQuery += " WHERE D2_FILIAL = '"+SF2->F2_FILIAL+"'"
	cQuery += " AND D2_DOC = '"+SF2->F2_DOC+"'"
	cQuery += " AND D2_SERIE = '"+SF2->F2_SERIE+"'"
	cQuery += " AND D2_CLIENTE = '"+SF2->F2_CLIENTE+"'"
	cQuery += " AND D2_LOJA = '"+SF2->F2_LOJA+"'"
	cQuery += " AND SD2.D_E_L_E_T_ = ' '"
	// Verifica se existe o registro correspondente e correto na tabela SC9
	cQuery += " AND NOT EXISTS ("
	cQuery += 	" SELECT C9_PEDIDO"
	cQuery += 	" FROM "+RetSqlName('SC9')+" SC9"
	cQuery +=	" WHERE C9_FILIAL = SD2.D2_FILIAL"
	cQuery += 	" AND C9_PEDIDO = SD2.D2_PEDIDO"
	cQuery += 	" AND C9_ITEM = SD2.D2_ITEMPV"
	cQuery +=	" AND C9_PRODUTO = SD2.D2_COD"
	cQuery +=	" AND C9_NFISCAL = SD2.D2_DOC"
	cQuery +=	" AND C9_SERIENF = SD2.D2_SERIE"
	cQuery += 	" AND C9_BLEST = '10'"
	cQuery +=	" AND C9_BLCRED = '10'"
	cQuery +=	" AND SC9.D_E_L_E_T_ = ' ' )"
	// Executa a query
	//	MEMOWRIT( "\m460fim.sql", cQuery )
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery ),'TRB',.T.,.T.)
	TCSetField('TRB','D2_QUANT','N',14,4)

	dbSelectArea("TRB")
	If !Eof()

		// Inconsistencias encontradas. Em cada inconsistencia, podem haver 2 possibilidades: Nao haver registro no SC9 ou haver registro no SC9 errado
		// Faz a gravacao do log de inconsistencia na geracao da NF
		If File("\incgernf.log")
			nHdlLog := fOpen("\incgernf.log",2)
			fSeek(nHdlLog,0,2)
		Else
			nHdlLog:=fCreate("\incgernf.log",0)
			fWrite(nHdlLog,"DATA     HORA     FILIAL SERIE DOCUMENTO CLIENTE LOJA ITEM PRODUTO         LOCAL QUANTIDADE PEDIDO ITEMPV SEQUENCIA C9_NFISCAL C9_SERIENF C9_BLEST C9_BLCRED"+CRLF)
			fWrite(nHdlLog,"------------------------------------------------------------------------------------------------------------------------------------------------------------"+CRLF)
		Endif

		// Grava log de cada inconsistencia encontrada
		Do While !Eof()

			// Verifica se ha ou nao registro no SC9
			lTemSC9 := .F.
			dbSelectArea("SC9")
			dbSeek(TRB->D2_FILIAL+TRB->D2_PEDIDO+TRB->D2_ITEMPV,.F.)
			Do While C9_FILIAL+C9_PEDIDO+C9_ITEM == TRB->D2_FILIAL+TRB->D2_PEDIDO+TRB->D2_ITEMPV .and. !Eof()
				If SC9->C9_PRODUTO == TRB->D2_COD
					lTemSC9 := .T.
					exit
				Endif
				dbSkip()
			Enddo
			If !lTemSC9
				dbGoBottom()
				dbSkip()
			Endif

			fWrite(nHdlLog,dtoc(date())+" "+time()+" "+PadR(TRB->D2_FILIAL,6)+" "+PadR(TRB->D2_SERIE,5)+" "+PadR(TRB->D2_DOC,9)+" "+;
			PadR(TRB->D2_CLIENTE,7)+" "+PadR(TRB->D2_LOJA,4)+" "+PadR(TRB->D2_ITEM,4)+" "+TRB->D2_COD+" "+PadR(TRB->D2_LOCAL,5)+" "+;
			Transform(TRB->D2_QUANT,"@E 999,999.99")+" "+TRB->D2_PEDIDO+" "+PadR(TRB->D2_ITEMPV,6)+" "+PadR(TRB->D2_SEQUEN,9)+" "+;
			PadR(SC9->C9_NFISCAL,10)+" "+PadR(SC9->C9_SERIENF,10)+" "+PadR(SC9->C9_BLEST,8)+" "+PadR(SC9->C9_BLCRED,9)+CRLF)

			dbSelectArea("TRB")
			dbSkip()

		Enddo

		// Fecha o arquivo de log e o cursor
		fClose(nHdlLog)

	Endif

	TRB->(dbCloseArea())
	// Restaura a area
	Restarea(aAreaSC9)
	dbSelectArea(cArea)

Endif

Return NIL
*********************************************************************
Static Function ITEMSD2(_Filial,_DOC,_SERIE)
*********************************************************************

aItemSD2:={}

cQuery :=   " "
//cQuery +=	" SELECT D2.*,ROWNUM N_NUMITEM FROM "
//cQuery +=	" ("
cQuery +=	" SELECT  D2_ITEM C_D2_ITEM FROM " + RetSqlName("SD2") + " D2 "
cQuery +=	"    WHERE D2_DOC = '" + _DOC + "' AND "
cQuery +=	"		     D2_FILIAL ='"+ _Filial + "' AND "
cQuery +=	"		     D2_SERIE ='" + _SERIE +  "' AND "
cQuery +=	"		     D2.D_E_L_E_T_ != '*' "
cQuery +=	"    ORDER BY D2_DOC, D2_ITEM
//cQuery +=	" ) D2"


IF SELECT( '__ITEMS' ) <> 0
	dbSelectArea('__ITEMS')
	Use
Endif

TCQuery cQuery NEW ALIAS ('__ITEMS')


DO WHILE   !__ITEMS->(EOF())
	AADD(aItemSD2,C_D2_ITEM) //	AADD(aItemSD2,{C_D2_ITEM,N_NUMITEM})
	__ITEMS->(DBSKIP())
ENDDO

DBCloseArea('__ITEMS')

Return aItemSD2
*********************************************************************
Static Function DesIcmPad(cDestino)
*********************************************************************
Local aArea     := GetArea()
Local aAreaSA1  := SA1->( GetArea() )
Local nRecnoSA1 := SA1->( RECNO())
//Local cImdepa   := GetMv('MV_IMDEPA') //CODIGO DA IMDEPA NO CADASTRO DE CLIENTES (SA1) E DE FORNECEDORES (SA2), PARA FINS DE TRANSFERENCIA ENTRE FILIAIS.
Local cOrigem
LOCAL nOld


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
      CPRODUTO:=SB1->B1_COD    //gdFieldGet( "UB_PRODUTO", N ) //SB1->B1_COD
      cIMPNAC:=SA1->(POSICIONE('SB1',1,XFILIAL('SB1')+CPRODUTO,'B1_ORIGEM'))
	  LIMP:=(CIMPNAC='1' .OR. CIMPNAC='2')


   if !LIMP //e nacional
	nDescIcmPad	:= SZW->ZW_DESCONT
   else     //e importado
	nDescIcmPad	:= SZW->ZW_DESCIMP
   endif

	//nDescIcmPad	:= SZW->ZW_DESCONT
	nDescComExp := SZW->ZW_DESCEXP


Else
	If Type("l410Auto") != "U" .And. !l410Auto
		//u_Mensagem("O desconto de ICMS padrão para vendas com origem em "+cOrigem+" e destino "+cDestino+" não está cadastrado.")
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

Return()


//+-----------------------------------------------------------------------------------//
//|Programa..: cComisPorOperador()
//|Autor.....: Edivaldo Gonçalves Cordeiro
//|Data......: 13/05/2010
//|Descricao.: Atualiza comissão por Operador na gravação da Nota Fiscal
//|Observação:
//+-----------------------------------------------------------------------------------//
*--------------------------------------------------*
Static Function cComisPorOperador(cVendInt,cNumSE3)
*--------------------------------------------------*

Local cNewVend     :=' '
Local cSql         :=' '
Local nDifComis    :=0
Local nPerComVenda :=0


DbSelectarea("SUA")
DbSetOrder(1)

If DbSeek(xFilial("SUA")+SC5->C5_NUMSUA)
   If Empty(SUA->UA_OPERAD2) .OR. SUA->UA_OPERAD2=SUA->UA_OPERADO .OR. SA1->A1_GERVEN <> '000685'   //-------Não há dois operadores,portando não precisa gerar a segunda comissão.
	      Return
   Else
            cNewOperador:= SUA->UA_OPERAD2
            cNewVend    := POSICIONE("SU7",1,XFILIAL("SU7") + SUA->UA_OPERAD2, "U7_CODVEN")

			If cNewVend=cVendInt
                      cNewVend    := POSICIONE("SU7",1,XFILIAL("SU7") + SUA->UA_OPERADO, "U7_CODVEN")
            Endif

            SE3->( dbSetorder( 1 ) )

            IF SE3->( dbSeek( xFilial("SE3") + SE3->E3_PREFIXO + SE3->E3_NUM + SE3->E3_PARCELA + SE3->E3_SEQ +  cVendInt , .T. ) )

               cNumSE3    :=SE3->E3_NUM
               cEmissSE3  :=SE3->E3_EMISSAO
               cSerie     :=SE3->E3_SERIE
               cCodCli    :=SE3->E3_CODCLI
               cLojaCli   :=SE3->E3_LOJA
               nBaseSe3   :=SE3->E3_BASE
               nE3PORC    :=SE3->E3_PORC
               nValComis  :=SE3->E3_COMIS
               dDataSE3   :=SE3->E3_DATA
               cPrefixoSE3:= SE3->E3_PREFIXO
               cParcelaSE3:= SE3->E3_PARCELA
               cTipoSE3   := SE3->E3_TIPO
               cPedidoSE3 := SE3->E3_PEDIDO
               cVencSE3   := SE3->E3_VENCTO
               cOrigSE3   := SE3->E3_ORIGEM
               cE3_BAIEMI := SE3->E3_BAIEMI


                SE3->( RecLock( 'SE3', .T. ) )
					SE3->E3_FILIAL   := Xfilial("SE3")
					SE3->E3_VEND 	 := cNewVend
					SE3->E3_NUM      := cNumSE3
					SE3->E3_EMISSAO  := cEmissSE3
					SE3->E3_SERIE    := cSerie
					SE3->E3_CODCLI   := cCodCli
					SE3->E3_LOJA     := cLojaCli
					SE3->E3_BASE     := nBaseSe3
					SE3->E3_PORC     := nE3PORC
					SE3->E3_COMIS    := nValComis
					SE3->E3_DATA     := dDataSE3
					SE3->E3_PREFIXO  := cPrefixoSE3
					SE3->E3_PARCELA  := cParcelaSE3
					SE3->E3_TIPO     := cTipoSE3
					SE3->E3_PEDIDO   := cPedidoSE3
					SE3->E3_VENCTO   := cVencSE3
					SE3->E3_ORIGEM	 := cOrigSE3
					SE3->E3_BAIEMI   := cE3_BAIEMI

					SE3->( MsUnlock() )


                    //Identifico os percentuais de comissão dos vendedores
                    nComVend1 := POSICIONE("SA3",1,XFILIAL("SA3") + cVendInt, "A3_COMIS") //Vendedor 1
                    nComVend2 := POSICIONE("SA3",1,XFILIAL("SA3") + cNewVend, "A3_COMIS") //Vendedor 2

                    //Calcula Diferença da Comissão entre o Cadastro(SA3) e Comissão no Título SE3
                    nDifComis       := nE3PORC / nComVend1
                    nPerComVenda    := nComVend2 *nDifComis



               cSql :=" UPDATE "+RetSqlName("SE3")//--------------Atualiza a Base e o valor da Comissão para os vendedores
	           cSql +=" SET "
	           cSql +=" E3_BASE = " + STR(SE3->E3_BASE  /2 )   + " ,  "
	           cSql +=" E3_COMIS =" + Str(ROUND(SE3->E3_BASE  /2    * SE3->E3_PORC /100 ,2))
	           cSql +=" WHERE "
	           cSql +=" E3_FILIAL='"+xFilial("SE3")+"'"
	           cSql +=" AND E3_SERIE='"+SE3->E3_SERIE+"'"
	           cSql +=" AND E3_NUM='"+SE3->E3_NUM+"'"
	           cSql +=" AND E3_CODCLI='"+SE3->E3_CODCLI+"'"
	           cSql +=" AND D_E_L_E_T_ = ' ' "

	           TCSQLExec( cSql )
	           TCSQLExec('COMMIT')

               cSql :=" UPDATE "+RetSqlName("SE3")//--------Atualiza o Percentual e valor da comissão para o vendedor2
	           cSql +=" SET "
	           cSql +=" E3_BASE = " + STR(SE3->E3_BASE  /2 )   + " ,  "
	           cSql +=" E3_PORC = " + STR(ROUND( nPerComVenda,4 ))   + " ,  "
	           cSql +=" E3_COMIS =" + Str(ROUND(SE3->E3_BASE  /2    * nPerComVenda /100 ,2))
	           cSql +=" WHERE "
	           cSql +=" E3_FILIAL='"+xFilial("SE3")+"'"
	           cSql +=" AND E3_VEND='"+cNewVend+"'"
	           cSql +=" AND E3_SERIE='"+SE3->E3_SERIE+"'"
	           cSql +=" AND E3_NUM='"+SE3->E3_NUM+"'"
	           cSql +=" AND E3_CODCLI='"+SE3->E3_CODCLI+"'"
	           cSql +=" AND D_E_L_E_T_ = ' ' "

	           TCSQLExec( cSql )
	           TCSQLExec('COMMIT')

            Endif

      Endif

Endif

Return



*****************************************************************************************
USER FUNCTION _CORCOMIS() // Faz a correcao da base e do valor das comissoes da filial de
                          // Curitiba com TES com percentual de icms diferido informado.
                          // Esse erro está ocorrendo no P8. No P10 não ocorre.
                          // Essa função deverá ser desativado no P10.
*****************************************************************************************

Local cSql  := ""

IF SF4->F4_FILIAL = "13"

   IF SF4->F4_PICMDIF > 0

	  cSql :=" UPDATE "+RetSqlName("SE3")
	  cSql +=" SET "
	  cSql +=" E3_BASE = " + STR(SF2->F2_VALMERC, Tamsx3("E3_BASE")[1],Tamsx3("E3_BASE")[2])   + " ,  "
	  cSql +=" E3_COMIS = ROUND( " + STR(SF2->F2_VALMERC, Tamsx3("E3_BASE")[1],Tamsx3("E3_BASE")[2]) + " * E3_PORC /100, " + STR(Tamsx3("E3_COMIS")[2],3) + " ) "
	  cSql +=" WHERE "
	  cSql +=" E3_FILIAL='"+xFilial("SE3")+"'"
	  cSql +=" AND E3_SERIE='"+SF2->F2_SERIE+"'"
	  cSql +=" AND E3_NUM='"+SF2->F2_DOC+"'"
	  cSql +=" AND E3_CODCLI='"+SF2->F2_CLIENTE+"'"
	  cSql +=" AND E3_EMISSAO='"+DTOS(SF2->F2_EMISSAO)+"'"
	  cSql +=" AND D_E_L_E_T_ = ' ' "

	  TCSQLExec( cSql )
	  TCSQLExec('COMMIT')

   ENDIF

ENDIF

RETURN()


//+-----------------------------------------------------------------------------------//
//|Funcao....: nRetPerComisVen2()
//|Descricao.: Retorna o percentual de comissão para o 2º Operador do Call Center
//|Uso.......: U_SendNfTrf
//|Observação: Envia o e-mail dos Boletins de Entrada
//+-----------------------------------------------------------------------------------//

*************************************************
Static Function nRetPerComisVen2()
*************************************************
Local cSql    :=''
Local nPComis :=0

cSql:= " SELECT ROUND((VALCOMISSAO/TOTAL)*100,2) PER_COMIS "
cSql+= " FROM "
cSql+= "( "

cSql+=" SELECT SUM(D2_TOTAL) TOTAL, "
cSql+=" SUM((D2_TOTAL * D2_COMIS1)/100) VALCOMISSAO "
cSql+=" FROM "+RetSqlName('SD2')+" SD2"
cSql+=" WHERE D2_FILIAL='"+SF2->F2_FILIAL+"'"
cSql+=" AND   D2_DOC='"+SF2->F2_DOC+"'"
cSql+=" AND   D2_SERIE ='"+SF2->F2_SERIE+"'"
cSql+=" )"

  	If( Select("TRB_TEMP") <> 0 ) // Se a area a ser utilizada estiver em uso, fecho a mesma
		TRB_TEMP->( dbCloseArea() )
	EndIf

dbUseArea(.T.,'TOPCONN',TCGenQry(,,cSql ),'TRB_TEMP',.T.,.T.)
dbSelectArea("TRB_TEMP")

	If !Eof()
	 nPComis:= TRB_TEMP->PER_COMIS
   Endif


   TRB_TEMP->( dbCloseArea() )

   Return (nPComis)












//+-----------------------------------------------------------------------------------//
//|Funcao....: fItensBoletim()
//|Descricao.: Carrega os itens de transferência para envio do Boletim de Entrada
//|Uso.......: U_SendNfTrf
//|Observação: Envia o e-mail dos Boletins de Entrada
//+-----------------------------------------------------------------------------------//

***********************************
Static Function fItensBoletim()
***********************************
Local cSql:=' '

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

Return


