#include 'protheus.ch'
#include 'parmtype.ch'

#Define _SIM_ "1"
#Define _NAO_ "2"

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : M410STTS     | AUTOR : Cristiano Machado | DATA : 29/01/2019   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Controle se eh necessario Gerar Guia de Pagamento ST para o    **
**          : Pedido de Vendas , só executa em Pedidos incluidos apenas no   **
**          : FATURAMENTO, pedidos que nascem apartir de um atendimento      **
**          : tem este controle efetuado pelo PE TMKVFIM                     **
**---------------------------------------------------------------------------**
** USO : Especifico para Imdepa Rolamentos                                   **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                         **
**---------------------------------------------------------------------------**
** PROGRAMADOR | DATA | MOTIVO DA ALTERACAO                                  **
**---------------------------------------------------------------------------**
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function M410STTS()
*******************************************************************************	

	aAtu	:= GetArea()  //| Area Atual
	aSA4	:= SA4->( GetArea()	) //| Area SA4
	aSA1	:= SA1->( GetArea()	) //| Area SA1
	aSUA	:= SUA->( GetArea()	) //| Area SUA

	
	// Verifica se tem necessidade de Gerar Guia de Pagamento ST para o Pedido de Venda
	VNecGuia()
	
	
	RestArea(aSUA)
	RestArea(aSA4)
	RestArea(aSA1)
	RestArea(aAtu)
	
Return Nil
*******************************************************************************
Static Function VNecGuia()
*******************************************************************************

	ObtemVar() // Obtem valores para variaveis necessarias no calculo
	
	DbSelectarea("SUA");DbSetOrder(8)
	If !(DbSeek(xFilial("SUA")+SC5->C5_NUM)) // Só executa se for pedido incluido através do FATURAMENTO ou seja não possui atendimento
		
		CalcCapa() // Inicializa o Calculo da Capa

		CalcIten() //  Inclui os itens no Calculo
	
		VerGuia() // Verifica se deve ter guia
		
	EndIf
	
Return Nil 
*******************************************************************************
Static Function ObtemVar() // Obtem valores para variaveis necessarias no calculo
*******************************************************************************
	
	_SetOwnerPrvt( 'aTransp', {"",""} 				) //| Dados Transportadora

	_SetOwnerPrvt( 'nItens' , 0						) //| Quantidade de Itens

	SA4->(dbSetOrder(1))
	If SA4->( DbSeek(xFilial("SA4") + SC5->C5_TRANSP, .F. )) 
		aTransp[1] := SA4->A4_EST
		aTransp[2] := SA4->A4_TPTRANS
	Endif

	MaFisClear()

Return Nil
*******************************************************************************
Static Function CalcCapa() // Inicializa o Calculo da Capa
*******************************************************************************
	
	MaFisSave()
	MaFisEnd()
	MaFisIni(	SC5->C5_CLIENT 		,;	// 1-Codigo Cliente/Fornecedor
				SC5->C5_LOJAENT		,;	// 2-Loja do Cliente/Fornecedor
				"C"					,;	// 3-C:Cliente , F:Fornecedor
				SC5->C5_TIPO		,;	// 4-Tipo da NF
				SC5->C5_TIPOCLI		,;	// 5-Tipo do Cliente/Fornecedor
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				"MATA461",;
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				aTransp,,,;
				SC5->C5_NUM,;
				SC5->C5_CLIENTE,;
				SC5->C5_LOJACLI,;
				0,,;
				SC5->C5_TPFRETE )


Return Nil
*******************************************************************************
Static Function CalcIten() //  Inclui os itens no Calculo
*******************************************************************************

	cAux := "AUXC6"
	
	GetItens(cAux) // Obtem os Itens do Pedido em Questão
	
	DbSelectArea(cAux);DbGotop()
	While !EOF()
		
		MaFisAdd( 	(cAux)->C6_PRODUTO	,; // 1-Codigo do Produto ( Obrigatorio )
					(cAux)->C6_TES		,; // 2-Codigo do TES ( Opcional )
					(cAux)->C6_QTDVEN	,; // 3-Quantidade ( Obrigatorio )
					(cAux)->C6_PRUNIT	,; // 4-Preco Unitario ( Obrigatorio )
					0					,; // 5-Valor do Desconto ( Opcional )
					""					,; // 6-Numero da NF Original ( Devolucao/Benef )
					""					,; // 7-Serie da NF Original ( Devolucao/Benef )
					0					,; // 8-RecNo da NF Original no arq SD1/SD2
					0					,; // 9-Valor do Frete do Item ( Opcional )
					0					,; // 10-Valor da Despesa do item ( Opcional )
					0					,; // 11-Valor do Seguro do item ( Opcional )
					0					,; // 12-Valor do Frete Autonomo ( Opcional )
					Round((cAux)->C6_QTDVEN * (cAux)->C6_PRUNIT,4) ,; // 13-Valor da Mercadoria ( Obrigatorio )
					0					,; // 14-Valor da Embalagem ( Opiconal )	
					Nil					,; // 15
					Nil					,; // 16
					(cAux)->C6_ITEM		,; // 17 
					Nil					,; // 18-Despesa s nao tributadas - Portugal
					Nil					,; // 19-Tara - Portugal
					(cAux)->C6_CF		,; // 20-CFO 
					Nil					,; // 21-Array para o calculo do IVA Ajustado (opcional)	
					""					,; // 22-Codigo Retencao - Equador
					Nil					,; // 23-Valor Abatimento ISS
					(cAux)->C6_LOTECTL	,; // 24-Lote Produto
					(cAux)->C6_NUMLOTE  ,; // 25-Sub-Lote Produto
					Nil					,; // 26
					Nil					,; // 27
					(cAux)->C6_CLASFIS   ) // 28-Classificação fiscal  

					 
	   nItens += 1
	   
       DbSelectArea(cAux)
       DbSkip()
       
	EndDo
	
	DbSelectArea(cAux)
    DbCloseArea()

Return Nil
*******************************************************************************
Static Function GetItens(cAux) // Obtem os Itens do Pedido em Questão
*******************************************************************************
	
	cSql := "Select * From SC6010 Where C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+SC5->C5_NUM+"' AND D_E_L_E_T_ = ' '"
	
	U_ExecMySql( cSql , cCursor := cAux , cModo := "Q", lMostra := .F., lChange := .F. )
	
Return Nil
*******************************************************************************
Static Function VerGuia() // Verifica se deve ter guia
*******************************************************************************

	Local cTemGuia  := ""
	Local cConteudo := ""
	Local nTotValSol:= 0 
	Local cEstCli	:= Posicione("SA1", 1, xFilial("SA1")+ SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_EST" )
	Local nPosInPar := 0
	
	// Obtem Total de ST apartir dos Itens
	For nI := 1 To nItens
		nTotValSol +=  MaFisRet(nI,"IT_VALSOL")  
	Next

	// Chamado: 23902 Cristiano Machado - Ajuste para Identificar se eh Necessario Imprimir Guia ST no FATURAMENTO
	cConteudo := SuperGetMv("MV_SUBTRIB" , .F. , "" , xFilial("SC5"))
	nPosInPar := AT(cEstCli, cConteudo )
	
	If nTotValSol > 0 .And. nPosInPar <= 0 .And. Alltrim( GetMv("MV_ESTADO") ) <> cEstCli
	   cTemGuia := "1" // Sim
	Else
   	   cTemGuia := "2" // Nao
    Endif
        
    RecLock("SC5",.F.)
    	SC5->C5_PEDGUIA := cTemGuia
	MsUnlock()
	
Return Nil	