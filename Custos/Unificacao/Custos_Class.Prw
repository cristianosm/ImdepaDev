#Include "Protheus.ch"

#Define NOR 		1 	//| NORMAL
#Define GER 		2 	//| GERENTE
#Define REP 		3 	//| REPRESENTANTE
#Define UNI 		4 	//| UNIDADE

// Custo Margem de Contribuicao Media das Ultimas Compras
#Define MCN 		1 	//| Margem Normal
#Define MCR 		2 	//| Margem Reposicao
#Define MUC 		3 	//| Margem Ultimas Compras
#Define MCG 		4 	//| Margem Ultimas Compras

#Define COEFC 	1 	//| Coeficiente Cambial    (COEFC)
#Define COEFF 	2 	//| Coeficiente Financeiro (COEFF)
#Define COEFI 	3 	//| Coeficiente Idade      (COEFI)
#Define VALOR 	1	//| Coluna VALOR do Coef
#Define FATOR 	2 	//| Coluna FATOR do Coef

#Define TAM 		4

#Define CRLF		chr(13)+chr(10)

// SC5 - SF2 - SA1
*******************************************************************************
// Classe oPedido
*******************************************************************************
Class oPedido

	Data aGetAreas						// Armazena as Areas....
	Data _cFilial
	Data cTabPreco
	Data cCondPag
	Data cPedido

	Data aItens
	Data aMargemTotal
	Data nIdadeTotal
	Data nQtdTotal

	Data nItens				//| Quantidade de Itens

	Data cGeraLog
	
	Data oCliente
	
	

	Method  New( cNumPv ) Constructor //| Cria o Objeto
	Method  Add_Produto()							//| Adiciona cada Produto que compoe o PV ou NF
	Method  Calc_Custos(nItem)				//| Calcula o Custo dos Produtos contidos no PV ou NF...

	Method  Grava_Item()							//| Grava os Dados na Tabela... SC6 ou SD2...
	Method  Grava_Total()							//| Grava os Dados na Tabela... SC5 ou SF2...

	//| Methodos Auxiliares...
	Method SalvaAreas( cNumPv )  			//| Salva Areas em Aberto....
	Method SalvaLog()								//| Salva Log com Todo os Valores envolvidos nos Calculos....
	Method RestAreas()								//| Restaura o posicionamento das areas Salvas...


EndClass
***************************************
Method New( cNumPv ) Class oPedido
***************************************

	::SalvaAreas( cNumPv )

	::_cFilial			:= xFilial("SB1")
	::cTabPreco 		:= SC5->C5_TABELA
	::cCondPag 		:= SC5->C5_CONDPAG
	::cPedido			:= SC5->C5_NUM

	::aItens				:= {}
	::aMargemTotal	:= { 0 , 0 , 0 , 0 }
	::nIdadeTotal	:= 0
	::nQtdTotal		:= 0
	::nItens				:= 0
	::cGeraLog			:= ""
	::oCliente			:= oCliente():New()
	

Return Self
***************************************
Method Add_Produto() Class oPedido
***************************************

	Local oProduto

	::nItens += 1

	oProduto := oProduto():New( CamposUni("PRODUTO") , CamposUni("NITEM") )

	Aadd( ::aItens , oProduto )

Return
***************************************
Method Calc_Custos(nItem) Class oPedido
***************************************

	oPedido:aItens[nItem]:oCustos := oCustos():New()

	oPedido:aItens[nItem]:oCustos:Calcula()  // := oCustos():New()

Return
***************************************
Method Grava_Item() Class oPedido
***************************************

	Local nQtd				:= oPedido:aItens[nItens]:nQtd
	Local aMargens 	:= oPedido:aItens[nItens]:oCustos:aMargem
	Local aIndices 	:= oPedido:aItens[nItens]:oCustos:aIndice
	Local aCustos 		:= oPedido:aItens[nItens]:oCustos:aCusto
	Local aCoefs 		:= oPedido:aItens[nItens]:oCustos:aCoef:aCoef
	Local nIdade			:= oPedido:aItens[nItens]:nIdade

	DbSelectArea("SD2")
	RecLock("SD2",.F.)

	//| Grava Margens
	SD2->D2_MC 		:= aMargens[MCN]:nval_margem
	SD2->D2_MCR		:= aMargens[MCR]:nval_margem
	SD2->D2_MCG		:= aMargens[MCG]:nval_margem
	SD2->D2_MCUC		:= aMargens[MUC]:nval_margem

	//| Grava Indices das Margens
	SD2->D2_IMC		:= aIndices[MCN]:nIndice
	SD2->D2_IMCR		:= aIndices[MCR]:nIndice
	SD2->D2_IMCG		:= aIndices[MCG]:nIndice
	SD2->D2_IMCUC	:= aIndices[MUC]:nIndice

	//| Grava os Custos
	SD2->D2_CUSMC	:= aCustos[MCN]:nCusto
	SD2->D2_CUSMCR	:= aCustos[MCR]:nCusto
	SD2->D2_CUSMCG	:= aCustos[MCG]:nCusto
	SD2->D2_CUSMCUC:= aCustos[MUC]:nCusto

	//| Grava Coeficientes
	SD2->D2_COEFC	:= aCoefs[COEFC][2]
	SD2->D2_COEFF	:= aCoefs[COEFF][2]
	SD2->D2_COEFI	:= aCoefs[COEFI][2]

	//| Grava Idade
	SD2->D2_IDADE	:= U_IdadeAtu( nQtd , SB2->B2_IDADE , SB2->B2_DTIDADE )

	MsUnlock()

Return
***************************************
Method Grava_Total() Class oPedido
***************************************

	DbSelectArea("SF2")
	RecLock("SF2",.F.)

	SF2->F2_FILCLI 	:= oPedido:oCliente:cFilCli
	SF2->F2_IMC			:= oPedido:aMargemTotal[MCN]
	SF2->F2_IMCG			:= oPedido:aMargemTotal[MCG]
	SF2->F2_IMCR 		:= oPedido:aMargemTotal[MCR]
	SF2->F2_IMCUC		:= oPedido:aMargemTotal[MUC]
	SF2->F2_IDADE		:= oPedido:nIdadeTotal / oPedido:nQtdTotal

	MsUnlock()

Return
***************************************
Method  SalvaAreas( cNumPv ) Class oPedido
***************************************

	::aGetAreas := {}

	Aadd( ::aGetAreas , SC5->(GETAREA()) )
	DbSelectarea("SC5");DbSetOrder(1)
	DbSeek(xFilial("SC5")+cNumPv, .F. )

	Aadd( ::aGetAreas , SA1->(GETAREA()) )
	DbSelectarea("SA1");DbSetOrder(1)
	DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, .F. )

	Aadd( ::aGetAreas , SE4->(GETAREA()) )
	DbSelectarea("SE4");DbSetOrder(1)
	DbSeek(xFilial("SE4")+SC5->C5_CONDPAG, .F.)  // Condicao de Pagamento

	DbSelectArea('SZW');DbSetOrder(1)
	DbSeek(xFilial('SZW') + SM0->M0_ESTENT + SA1->A1_EST, .F.)

Return
***************************************
Method SalvaLog() Class oPedido						//| Salva Log com Todo os Valores envolvidos nos Calculos....
***************************************
	Local cTeste := ""
	
	//Alert("oPedido:cGeraLog: "+cValToChar(oPedido:cGeraLog))
//	Alert("::cGeraLog: "+cValToChar(::cGeraLog))
	
	U_CaixaTexto(oPedido:cGeraLog)
	
Return

/*
	cGeraLog := ""
	cGeraLog +=	" Filial             -> "+ (SC6->C6_FILIAL) 					+ CRLF
	cGeraLog +=	" Pedido             -> "+ (SC6->C6_NUM) 						+ CRLF
	cGeraLog +=	" Nota               -> "+ (SC6->C6_NOTA) 						+ CRLF
	cGeraLog +=	" Cliente            -> "+ (SC6->C6_CLI) 						+ CRLF
	cGeraLog +=	" Produto            -> "+ (SB1->B1_COD) 						+ CRLF
	cGeraLog +=	" Ncm                -> "+ (SB1->B1_POSIPI) 					+ CRLF
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
*/
Return
*******************************************************************************
// Classe oCliente
*******************************************************************************
Class oCliente

	Data cCodigo
	Data cLoja
	Data cUF
	Data cFilCli
	Data lFilImd

	

	Method New() Constructor

EndClass
***************************************
Method New() Class oCliente
***************************************
	::cCodigo 	:= SA1->A1_COD
	::cLoja		:= SA1->A1_LOJA
	::cUf			:= SA1->A1_EST //Posicione("SA1",1,xFilial("SA1")+cCodigo+cLoja,"A1_EST")
	::cFilCli	:= SA1->A1_FILCLI
	::lFilImd	:= Iif(SA1->A1_COD=="N00000",.T.,.F.) // Filial Imdepa? True or False

Return Self
*******************************************************************************
// Classe oProduto
*******************************************************************************
Class oProduto

	Data cCodigo		// Codigo do Produto
	Data cItem			// Posicao do Produto no PV ou NF
	Data cNCM			// Codigo NCM do Produto
	Data nQtd			// Quantidade
	Data cLoEst  	// Local do Estoque
	Data lImport 	// Produto Importado ? .T. - SIM ou .F. -> NAO
	Data oCustos		//
	Data nIdade		// Idade do Produto
	Data nIdade2		// Idade do Produto 2

	Method New( cCodigo , cItem ) Constructor

EndClass
***************************************
Method New( cCodigo , cItem ) Class oProduto
***************************************
	Default cItem := '01'

	::cCodigo	:= cCodigo
	::cItem		:= cItem
	::cNCM			:= SB1->B1_POSIPI //Posicione("SB1",1, xFilial("SB1") + ::cCodigo , "B1_POSIPI" )
	::nQtd			:= CamposUni("NQTD")
	::cLoEst		:= SB2->B2_LOCAL
	::lImport	:= Iif(SB1->B1_ORIGEM $ "1/2/6/7", .T. , .F. ) // 1,2,6,7 - > Extrangeira outros sao Nacionais
	
	If !(oPedido:oCliente:lFilImd)// Venda
		::nIdade		:= U_IdadeAtu( ::nQtd , SB2->B2_IDADE , SB2->B2_DTIDADE )
		::nIdade2	:= U_IdadeAtu( ::nQtd , SB2->B2_IDADE , SB2->B2_DTIDADE )
	Else // Transferencia
		::nIdade		:= Posicione("SC6",1,xFilial('SC6')+SD2->D2_PEDIDO+SD2->D2_ITEMPV,"C6_IDADE2")
		::nIdade2	:= U_IdadeAtu( ::nQtd , SB2->B2_IDADE , SB2->B2_DTIDADE )
	EndIf

	// Soma aos Totais
	oPedido:nQtdTotal		+= ::nQtd
	oPedido:nIdadeTotal 	+= ::nIdade * ::nQtd

Return Self
*******************************************************************************
//| Classe oCustos
*******************************************************************************
Class oCustos

	Data aMargem
	Data aIndice
	Data aCusto
	Data aCoef

	Method New() Constructor
	Method Calcula() // Calcula os Custos....

EndClass
***************************************
Method New() Class oCustos
***************************************

	::aCusto		:= {}
	::aMargem	:= {}
	::aIndice	:= {}
	::aCoef		:= {}

Return Self
***************************************
Method Calcula() Class oCustos
***************************************

	::aCoef		:= oCoef():New()

	For nI := 1 To TAM

		Aadd( ::aCusto 	, oCusto():New( nI )	)
		Aadd( ::aMargem 	, oMargem():New(nI )	)
		Aadd( ::aIndice	, oIndice():New(nI )	)

	Next

Return
*******************************************************************************
//| Classe oCusto
*******************************************************************************
Class oCusto

	Data nCusto

	Method New( nQual ) Constructor
	Method Regras( nQual )

EndClass
***************************************
Method New( nQual ) class oCusto
***************************************

	Local cTpCust 	:= ''
	Local nFatores 	:= oPedido:aItens[nItens]:oCustos:aCoef:nCoef
	Local cTabPreco	:= oPedido:cTabPreco
	Local cCodigo		:= oPedido:aItens[nItens]:cCodigo
	Local nValTst		:= 0

	// Descricao: Calcula a Desoneracao do Custo sobre a SubsTituicao Tributaria | Nome:Cristiano Machado | Data:10/07/08 | Chamado:AAZOEX
	Do Case
	Case nQual == MCN // 1
		::nCusto	:= 	U_FCusTrib(.F.) // nCustoMC
	Case nQual == MCR // 2
		::nCusto	:= U_PrcBase( cCodigo, cTabPreco 	,@cTpCust,.F.	,"R") // nCustoMCR
	Case nQual == MUC // 3
		::nCusto	:= U_PrcBase( cCodigo, cTabPreco	,@cTpCust,.F.	,"U")
	Case nQual == MCG // 4
		::nCusto	:= nFatores + oPedido:aItens[nItens]:oCustos:aCusto[MCN]:ncusto
	End Case

	nValTst := ::nCusto

	::Regras( nQual )

Return Self
***************************************
Method Regras( nQual ) Class oCusto
***************************************

	Local nItem_PoN	:= Val(oPedido:aItens[nItens]:cItem)

	Do Case
	Case nQual == MCN

	Case nQual == MCR

		//| CHAMADO TECNICO : AAZVST    SOLICITANTE: Marcia Silveira   DATA: 22/08/2013
		//| Favor contemplar no cálculo do IMCR nas vendas para fora do Estado, de produtos Importados, a alíquota de 4%, hoje o sistema efetua o cálculo do campo CUSMCR da seguinte forma:
		//| Custo standart = 100,00 ( - ) % PIS ( - ) % Cofins ( - ) % ICMS do Estado de origem da venda (ESTE PERCENTUAL NESTA SITUAÇÃO, deve ser substituído pela alíquota de 4%
    	//| ( = ) Custo Reposição

		nAlicIcm 		:= MaFisRet(nItem_PoN,"IT_ALIQICM")

		If  ( nAlicIcm == GetMv("IM_ICMIMP") ) // Produto Importado e Venda InterEstadual....

			nAliPis 			:= MaFisRet(nItem_PoN,"IT_ALIQIV5")
			nAliCofins 	:= MaFisRet(nItem_PoN,"IT_ALIQIV6")
			nValCusPad		:= xMoeda(SB1->B1_CUSTD , Val(SB1->B1_MCUSTD) , 1 , dDataBase)

			nCustoMCR := nValCusPad * ( ( 100 - ( nAliPis + nAliCofins + nAlicIcm ) ) / 100 )

		EndIf
		//| FIM CHAMADO AAZVST


	Case nQual == MUC
	Case nQual == MCG
	End Case
Return
*******************************************************************************
//| Classe oMargem
*******************************************************************************
Class oMargem

	Data nVal_Margem
	Data nVal_SemIPI
	Data nVal_IcmSol
	Data nVal_Impostos

	Method New(nQual) Constructor
	Method Excecoes(nQual)


EndClass
***************************************
Method New (nQual) Class oMargem
***************************************

	Local nQtd_Item			:= oPedido:aItens[nItens]:nQtd				// Quantidade do Protuto
	Local nItem_PoN		`	:= Val(oPedido:aItens[nItens]:cItem)

	Local nVal_Custo			:= 0
	Local nVal_Frete			:= 0  //Calc_Frete()

	Local nVal_CPMF			:= GetMv("MV_CPMF",,0)
	Local nVal_Comissao		:= nQtd_Item * CamposUni("PRCVEN") * Total_Comissao()

	Local nVal_Deflac		:= 0
	Local nItem					:= Val( oPedido:aItens[nItens]:cItem )
	Local nTax_Financ		:= ( GetMv("MV_TXFIN",,0) / 100 )
	Local nTax_Diaria		:= ( ((1 + nTax_Financ )^(1/30)) - 1 )

	// MafisRet - Retorna os Falores dos Impostos
	Local nIT_FRETE 			:= MafisRet(nItem_PoN,"IT_FRETE") 		//| Valor do Frete
	Local nIT_TOTAL			:= MaFisRet(nItem_PoN,"IT_TOTAL")    	//| Valor Total do Item
	Local nIT_VALIPI			:= MaFisRet(nItem_PoN,"IT_VALIPI") 		//| Valor do IPI
	Local nIT_VALMERC		:= MaFisRet(nItem_PoN,"IT_VALMERC") 		//| Valor da mercadoria
	Local nIT_PRCUNI 		:= MaFisRet(nItem_PoN,"IT_PRCUNI") 		//| Preco Unitario do Item
	Local nIT_DESPESA		:= MaFisRet(nItem_PoN,"IT_DESPESA")		//| Valor das Despesas Acessorias
	Local nIT_VALICM			:= MaFisRet(nItem_PoN,"IT_VALICM")    //| Valor do ICMS Normal
	Local nIT_VALSOL			:= MaFisRet(nItem_PoN,"IT_VALSOL")		//| Valor do ICMS Solidario
	

	// Propriedades...
	::nVal_Margem		:= 0
	::nVal_SemIPI 		:= 0
	::nVal_Impostos 	:= 0
	::nVal_IcmSol		:= 0


	// Valor do Frete
	nVal_Frete			:= nIT_FRETE

	// Valor do Item sem IPI
	::nVal_SemIPI 	:= ( nIT_TOTAL - nIT_VALIPI )

	// Valor do Item com impostos
	::nVal_Impostos 	:= ( nIT_TOTAL - ( nIT_VALMERC + nIT_DESPESA ) + (nIT_VALICM  + nIT_VALSOL)) //nIT_DESPESA + nIT_VALIPI //MaFisRet(nItem_PoN,"IT_TOTAL") 	// Verificar

	// Valor do ICMS Solidario
	::nVal_IcmSol		:= nIT_VALSOL	// Icms Solidario ou ..

	// Valor Deflacionado
	nVal_Deflac 		:= ( ::nVal_SemIPI / ((1 + nTax_Diaria) ^ SE4->E4_PRZMED) ) /// Verificar

	// Valor CPMF
	nVal_CPMF			:= ( nIT_TOTAL * nVal_CPMF / 100 )

	// Custo
	nVal_Custo 		:= oPedido:aItens[nItens]:oCustos:aCusto[nQual]:ncusto //| Pegar o oCusto...

	// Margem
	::nVal_Margem 	:= nVal_Deflac - ( nVal_CPMF + nVal_Custo * nQtd_Item + ::nVal_Impostos + nVal_Comissao + nVal_Frete )

	// Acumula MArgens...
	oPedido:aMargemTotal[nQual] += ::nVal_Margem // Soma o Margem Total



	If 			nQual == 1 	//| Margem Normal
		cQuem := "MCN"
	ElseIf 	nQual == 2 	//| Margem Reposicao
		cQuem := "MCR"
	ElseIf 	nQual == 3 	//| Margem Ultimas Compras
		cQuem := "MUC"
	ElseIf 	nQual == 4 	//| Margem Ultimas Compras
		cQuem := "MCG"
	EndIf
	
	
	If	 ( nQual == 1 .Or. nQual == 2)
	If	 ( nQual == 1 )
		oPedido:cGeraLog +=	 " Filial             -> "+ (SC6->C6_FILIAL) 					+ CRLF
		oPedido:cGeraLog +=	 " Pedido             -> "+ (SC6->C6_NUM) 							+ CRLF
		oPedido:cGeraLog +=	 " Nota               -> "+ (SC6->C6_NOTA) 							+ CRLF
		oPedido:cGeraLog +=	 " Cliente            -> "+ (SC6->C6_CLI) 							+ CRLF
		oPedido:cGeraLog +=	 " Produto            -> "+ (SB1->B1_COD) 							+ CRLF
		oPedido:cGeraLog +=	 " Ncm                -> "+ (SB1->B1_POSIPI) 						+ CRLF
		oPedido:cGeraLog +=	 " nVlrItem           -> "+ cValToChar(nIT_PRCUNI) 			+ CRLF // ok
		oPedido:cGeraLog +=	 " nIcmRetido         -> "+ cValToChar(::nVal_IcmSol) 		+ CRLF // ok
		oPedido:cGeraLog +=	 " nTotItemSemIPI     -> "+ cValToChar(::nVal_SemIPI) 		+ CRLF // ok
		oPedido:cGeraLog +=	 " nFreteItem         -> "+ cValToChar(nVal_Frete) 			+ CRLF // ok
		oPedido:cGeraLog +=	 " nVDescComis        -> "+ cValToChar(nVal_Comissao)		+ CRLF // ok
		oPedido:cGeraLog +=	 " nImpostosnoVlrItem -> "+ cValToChar(::nVal_Impostos)	+ CRLF // ok
		oPedido:cGeraLog +=	 " nQtdItem           -> "+ cValToChar(nQtd_Item)			 	+ CRLF // ok
		oPedido:cGeraLog +=	 " nValCPMF           -> "+ cValToChar(nVal_CPMF) 			+ CRLF // OK
		oPedido:cGeraLog +=	 " nValorDeflacionado -> "+ cValToChar(nVal_Deflac) 		+ CRLF // OK

	EndIf
	oPedido:cGeraLog +=	 " nCusto "+cQuem+"         -> "+ cValToChar(nVal_Custo)			+ CRLF // ok
	oPedido:cGeraLog +=	 " n"+cQuem+"               -> "+ cValToChar(::nVal_Margem) 		+ CRLF
	oPedido:cGeraLog +=	 CRLF + CRLF + CRLF

//	Alert(cValToChar( oPedido:cGeraLog  ))

	EndIf
	//TEMP: CRISTIANO MACHADO


	::Excecoes(nQual)

Return Self
***************************************
Method Excecoes(nQual) Class oMargem
***************************************

	// Excessao 1
	//|Chamado: 	AAZQ5R 			|Assunto: DESONER CUSTO COML EXPORTADORA |Analista: Cristiano MAchado
	//|Solicitante: Marcia Silveira |Data: 28/05/09
	If SC6->C6_TES == '508'

		::nVal_Margem  := ::nVal_Margem + ( ( SZW->ZW_DESCEXP * ( ::nVal_SemIPI ) / 100 ) )

	EndIf
	//FIM AAZQ5R


	// Excessao 2
	// Jorge Oliveira - 07/12/10 - Acrescentar as margens, o Desconto do ICMS ( Filial do Parana e TES 720 e ter Perc. Desc. ICMS )
	If ( cFilAnt == "13" .And. SC6->C6_TES == "720" .And. SC6->C6_DESCICM > 0 )

		::nVal_Margem  += Posicione( "SUB", 3, xFilial( "SUB" ) + SC6->C6_NUM + SC6->C6_ITEM, "UB_VDESICM" )

	EndIf

Return
*******************************************************************************
//| Classe oIndice
*******************************************************************************
Class oIndice

	Data nIndice

	Method New(nQual) Constructor

EndClass
***************************************
Method New (nQual) Class oIndice
***************************************

	Local nVal_Margem	:= oPedido:aItens[nItens]:oCustos:aMargem[nQual]:nVal_Margem
	Local nVal_SemIpi	:= oPedido:aItens[nItens]:oCustos:aMargem[nQual]:nVal_SemIpi
	Local nVal_IcmSol	:= oPedido:aItens[nItens]:oCustos:aMargem[nQual]:nVal_IcmSol

	// O Calculo eh o Mesmo .... O que muda eh a Margem...
	::nIndice := U_ValMarg	(nVal_Margem / ( nVal_SemIpi - nVal_IcmSol) * 100 )
	//				U_ValMarg	(nMC  			/(nTotItemSemIPI - nIcmRetido)  * 100)
Return Self
*******************************************************************************
//| Classe oCoeficiente
*******************************************************************************
Class oCoef

	Data aCoef
	Data nCoef

	Method New() Constructor

	Method RetAll() // Retorna a Soma de Todos os Fatores...

EndClass
***************************************
Method New() Class oCoef
***************************************

	Local nTJLPdia 	:= (1 + (GetMV("MV_TJLP",,0) /100)/12)^(1/30) - 1
	Local nCusto 		:= 	U_FCusTrib(.F.) //oPedido:aItens[nItens]:oCustos:aCusto[NOR]:nCusto
	Local nQtd		:= oPedido:aItens[nItens]:nQtd
	Local aAuxCoef	:= ::aCoef		:= { {0,0},{0,0},{0,0}}

	// Coeficiente Cambial    (COEFC)
	aAuxCoef[COEFC][VALOR]	:= SB2->B2_COEFC

	// Coeficiente Financeiro (COEFF)
	aAuxCoef[COEFF][VALOR]	:= SB2->B2_COEFF

	// Coeficiente Idade      (COEFI)
	aAuxCoef[COEFI][VALOR]	:= ( (1 + nTJLPdia) ^ U_IdadeAtu( nQtd , SB2->B2_IDADE , SB2->B2_DTIDADE ) ) - 1

	// Fatores...
	aAuxCoef[COEFC][FATOR]	:= ( aAuxCoef[COEFC][VALOR] / 100) 	* nCusto
	aAuxCoef[COEFF][FATOR]	:= ( aAuxCoef[COEFF][VALOR] / 100) 	* nCusto
	aAuxCoef[COEFI][FATOR]	:= ( aAuxCoef[COEFI][VALOR] * ( nCusto + aAuxCoef[COEFC][FATOR] + aAuxCoef[COEFF][FATOR] ) )

	::nCoef := aAuxCoef[COEFC][FATOR] + aAuxCoef[COEFF][FATOR] + aAuxCoef[COEFI][FATOR]

	::aCoef := aAuxCoef

Return ::aCoef
*******************************************************************************
Static Function CamposUni(cCampo)//| Retorna Conteudo de Campos Que devem ser Unificados
*******************************************************************************
	Local lCALLCENTER	:= IF ( FUNNAME() == "MATA460A" , .F. , .T. )
	Local lFATURAMENTO	:= IF ( FUNNAME() == "MATA460A" , .T. , .F. )
	Local xConteudo

	If lCALLCENTER

	ElseIf lFATURAMENTO

		Do Case
		Case "PRODUTO" == cCampo
			xConteudo := SD2->D2_COD
		Case "PRCVEN" == cCampo
			xConteudo := SD2->D2_PRCVEN
		Case "NITEM" == cCampo
			xConteudo := SD2->D2_ITEM
		Case "NQTD" == cCampo
			xConteudo := SD2->D2_QUANT
		End Case

	EndIf

Return ( xConteudo )
*******************************************************************************
Static Function Total_Comissao()
*******************************************************************************

	Local n_COMIS1 := SC6->C6_COMIS1
	Local n_COMIS2 := SC6->C6_COMIS2
	Local n_COMIS3 := SC6->C6_COMIS3
	Local n_COMIS4 := SC6->C6_COMIS4
	Local n_COMIS5 := SC6->C6_COMIS5
	Local nTotal_Comis := ( (n_COMIS1 * 1.63) + n_COMIS2 + (n_COMIS3 * 1.63) + (n_COMIS4 * 1.63) + (n_COMIS5 * 1.63) ) / 100

Return nTotal_Comis
*******************************************************************************
Static Function Calc_Frete()
*******************************************************************************

/*
nValFret := NoRound(SC6->C6_VALOR / SUA->UA_VALMERC * SUA->UA_FRETE,2) //Valor Frete

	If SUA->UA_TPFRETE == "C" .AND. SUA->UA_FRETE != 0
		nFreteItem		:= nValFret - (nValFret * 0.2) // MENOS 20%

	Elseif SUA->UA_TPFRETE == "C" .AND. SUA->UA_FRETE = 0
		nFreteItem 		:= NoRound(SC6->C6_VALOR / SUA->UA_VALMERC * SUA->UA_FRETCAL,2) //Valor Frete Incluso

	Elseif lRedesp
		nFreteItem 		:= NoRound(SC6->C6_VALOR / SUA->UA_VALMERC * nFreteFob,2) //Valor Frete de Redespacho

	Else
		nFreteItem 		:= 0

	Endif
IT_FRETE
*/

Return nFrete
