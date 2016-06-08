#Include "Totvs.ch"

#DEFINE COD_FIL     		1 //Codigo Filial
#DEFINE NOM_FIL     		2 //Nome Filial
#DEFINE EST_ATUAL      	3 //B2_QATU
#DEFINE EST_DISPO      	4 //B2_QATU - Pedido - Jausado = SALDO DISPONIVEL
#DEFINE EST_TRANS      	5 //B2_QTRANS - JaUsado
#DEFINE EST_QACLA      	6 //B2_QACLASS - A CLASSIFICAR
#DEFINE EST_SLAUX      	7 // 0 - SALDO AUXILIAR

#DEFINE POS_PLAN_DESTINO	2
#DEFINE POS_PLAN_NUMPLAN	3
#DEFINE POS_PLAN_ITEM		4
#DEFINE POS_PLAN_QTDPLA	   5
#DEFINE POS_PLAN_QTDDISP	6
#DEFINE POS_PLAN_DTENTRE	7
#DEFINE POS_PLAN_HAWB		8
#DEFINE POS_PLAN_CODPE		9
#DEFINE POS_PLAN_EXCED		10
#DEFINE POS_PLAN_CLIENTE	11

#DEFINE X_TLIST        	385
#DEFINE Y_TLIST        	130 + 15

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMDF051   บAutor  ณCRISTIANO MACHADO   บ Data ณ  04/02/2009 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao do SUB->UB_QUANT e Tela de Estoques / Planilhas  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8 IMDEPA ROLAMENTOS                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
User Function IMDF051()
*********************************************************************

	Private nQtdDig		:= 0  //|Quantidade Digitada

	Private nEstLoc1		:= 0  // Estoque Disponivel Local 01
	Private nEstLoc2		:= 0  // Estoque Disponivel Local 02
	Private nEstoque		:= 0  // Soma dos Estoque Utilizados. Hoje: 01 + 02

	Private cProduto 	:= gdFieldGet("UB_PRODUTO",n)
	Private cImdepa 		:= GetMV('MV_IMDEPA')
	Private cSemEst 		:= GetMV('MV_FILSEST')

	Private aEstFil 		:= {} //|Estoque das Filiais
	Private aEstPlan		:= {}

	Private lAtende    := "nQtdDig <= nEstoque"

	Private nOriginal	:= n

	//| Testa ah Recursividade..
	If GdDeleted(n) .Or. Type('lRecursivo') != 'U'
		Return (.T.)
	Else
		If Type('lRecursivo') == 'U'
			Private lRecursivo := .T.
		Endif
	Endif
	//| Fim Recursividade...

	//| Roda Funcoes Padroes e Inicializa Variaveis Necessarias (nQtdDig)
	FRodaFun()

	//| Verifica Estoque 01 da Filial
	nEstLoc1 := FEstoque("01")

	//| Verifica Estoque 02 em algumas filiais
	nEstLoc2 := FEstoque("02")

	// Soma os Estoque e Forma o Estoque Total
	nEstoque := nEstLoc1 + nEstLoc2

	// Estoque Atende Quantidade Digitada ? Sim ...
	IF &lAtende.

		Atende()

	Else // Nao...

		NaoAtende()

	EndIf

	__ReadVar 		:= "M->UB_QUANT" //| Evita Erros Malucos caso o __ReadVar esteja com outro conteudo...

Return( .T. )
*********************************************************************
Static Function Atende() //| Saldos em estoques atende Quantidade Digitada...
*********************************************************************
	Local nQtdDigAux 	:= 0
	Local lCriaLinha 	:= .F.
	Local lPegarE02		:= .T. // Determina se deve pegar Produto no Estoque 02...


	If nEstLoc1 > 0 // Estoque 01 Pode Atender Algo....

		If ( nQtdDig <= nEstLoc1 ) //| Estoque 01 Atende 100%

			FCarQtd(n, nQtdDig) //|Lanca no Estoque 01 Quantidade Digitada....

			lPegarE02 := .F.

		ElseiF nEstLoc1 > 0 .And. nQtdDig > nEstLoc1  //| Estoque 01 Atende Parcialmente

			nQtdDigAux := nEstLoc1

			nQtdDig := ( nQtdDig - nQtdDigAux )

			lCriaLinha := .T.

		EndIF
	EndIf


	If nEstLoc2 > 0 .And. lPegarE02 // Estoque 02 Pode Atender Algo....

		If ( nQtdDig <= nEstLoc2 ) //| Estoque 02 Atende 100%

			FCarQtd(n, nQtdDig, "02" ,lCriaLinha) //| Joga nQtdDig no SUB

		ElseiF nQtdDig > nEstLoc2  //| Estoque 02 Atende Parcialmente

			FCarQtd(n, nQtdDig, "02" ,lCriaLinha) //| Quantidade Estoque 02

			If ( n - nOriginal > 1 ) .And. Procname(1) <> "FSELECT" // Corrigi Bug do Objeto... Come linha quando a linha eh mais distante que 1 da original..
				FAddLinha()
			EndIf

		EndIf
	EndIf

	//| Retorna a Linha Original e Atualiza o Browse...
	n	:= nOriginal
	oGetTlv:oBrowse:nAt := n
	oGetTlv:oBrowse:Refresh()

	If lCriaLinha //| Lanca a Linha Original....Caso tenha sido criada outras linhas...
		lCriaLinha := .F.
		FCarQtd(n, nQtdDigAux, "01" ) //| Quantidade Estoque 01
	EndIf


Return(.T.)
*********************************************************************
Static Function NaoAtende()//| Saldos em estoques NAO atende Quantidade Digitada...
*********************************************************************

	Private nQtdCon		:= nQtdDig  	//|Quantidadfe Consultada
	Private nQtdOfer		:= 0  			//|Quantidadfe Ofertada
	Private nQtdRest   	:= nQtdDig  	//|Quantidade Restante
	Private lPlanilha 	:= .F.			//|Planilhas Estao Desativadas por enquanto... 29/11/13 - Cristiano Machado ... falei com o EDI.
	Private lFirst	  	:= .T.			//|Variavel que Controla a Obrigatoriedade de Selecao da Filial Local...

/*
If FVerPlan() > 0
	lPlanilha := .T. //|Verifica se Possui saldo em Planilha
	If !MsgYesNo( "Existe(m) Planilha(s) para o Produto informado."+Chr(13)+"Deseja vizualizar a(s) Planilha(s) ?","Planilhas" )
		lPlanilha := .F. //|Verifica se Possui saldo em Planilha
	EndIf
EndIf
*/

	FBuscFil()	//  Busca Filiais e Seus Estoques

	FAbreTela()	 // Abri tela com Estoques e Filiais

Return()
*********************************************************************
Static Function FRodaFun()//| Roda Funcoes Padroes e Inicializa Variaveis Necessarias
*********************************************************************
//	oGetTlv:bBeforeEdit := {|| U_VldProdSUB(X,Y)}
//| Inicializacoes Necessarias
	//If INCLUI .OR.  __COPIATT //.OR. //| Bloqueia o Atendimento. Nao sai sem concluir.
		__Podesair := "N"
	//EndIf

	SB1-> ( DbSeek(xFilial( "SB1" ) + gdFieldGet("UB_PRODUTO",n),.F.))

	nControle 	:= N
	nQtdDig 	:= &(Readvar())//|Quantidade Digitada    o q

	Aadd(aEstFil,{SM0->M0_CODFIL,'** '+SM0->M0_FILIAL,0,0,0,0,0})

	//| Dispara Consultado e Ofertado
	//| Processa( {|| nSeqId := SUB->(U_Write_OrcOfert(n,cFilAnt,M->UA_NUM,gdFieldGet("UB_PRODUTO",n),nQtdDig,gdFieldGet("UB_VRCACRE",n),gdFieldGet("UB_SEQID",n),GdFieldGet("UB_DTNECLI",n),GdFieldGet("UB_HRNECLI",n))) }, 'Aguarde ', 'Gerando Consultado X Ofertado' )

Return()
*********************************************************************
Static Function FEstoque(cLocal)//| Levanta o Estoque da Filial Atual
*********************************************************************
	Local cQuery			:= ""
	Local aArea	:= GetArea()
	Local nEstoque 		:= 0
	Local lFilocal		:= cFilAnt == SM0->M0_CODFIL

	Default cLocal := '01'

	If !OperaLocal02(cLocal)
		Return 0
	ElseIf !lFilocal .And. Type('lJaViuEst02') == 'U'// Opera com estoque 02 e nao eh filial local ...pegar o estoque 02 para as transferencias...
		Private lJaViuEst02 := .T.
		FEstoque("02")
	EndIF

	If lFilocal
		cQuery += " SELECT SUM(TA.SALDO + TB.SALDO) ATUAL, SUM(TA.DISPO + TB.DISPO + TC.DISPO) DISPO, SUM(TA.QTRANS + TB.QTRANS) TRANS, SUM(TA.QACLASS + TB.QACLASS) QACLA  "
	Else

		cQuery := " SELECT SUM(TA.SALDO + TB.SALDO) ATUAL, SUM(TA.DISPO + TB.DISPO) DISPO, SUM(TA.QTRANS + TB.QTRANS) TRANS, SUM(TA.QACLASS + TB.QACLASS) QACLA  "
	EndIf

	cQuery += " FROM "
	cQuery += " ( SELECT 0 SALDO, NVL( SUM(C6_QTDVEN - C6_QTDENT ), 0 ) DISPO, 0 QTRANS, 0 QACLASS "
	cQuery += "	  FROM " + RetSQLName("SC6") + " SC6, " + RetSQLName("SC7") + " SC7 "
	cQuery += "	  WHERE C6_FILIAL = '" 	+ SM0->M0_CODFIL 	+ "' "
	cQuery += "	  AND C6_PRODUTO = '" 	+ cProduto + "' "
	cQuery += "	  AND C6_CLI <> '" 		+ cImdepa 			+ "' AND ( C6_PLANILH <> ' ' OR C6_FILTRAN <> ' ' ) "
	cQuery += "	  AND C6_NOTA = ' ' "
	cQuery += "	  AND C6_LOCAL = '"+cLocal+"' "
	cQuery += "	  AND SC6.D_E_L_E_T_ = ' ' "
	cQuery += "	  AND C7_FILIAL = C6_FILIAL "
	cQuery += "	  AND C7_PLANILH = C6_PLANILH "
	cQuery += "	  AND C7_PLITEM = C6_PLITEM "
	cQuery += "	  AND ( C7_QUANT - C7_QUJE ) > 0 "
	cQuery += "	  AND C7_LOCAL = '"+cLocal+"' "
	cQuery += "	  AND SC7.D_E_L_E_T_ = ' ') TA, "

	cQuery += "( SELECT SUM(B2_QATU) SALDO, SUM(B2_QATU - B2_RESERVA - B2_QPEDVEN - B2_QACLASS) DISPO, SUM(B2_QTRANS) QTRANS, SUM(B2_QACLASS) QACLASS "
	cQuery += "	  FROM " + RetSQLName("SB2") + " "
	cQuery += "	  WHERE B2_FILIAL = '" + SM0->M0_CODFIL + "'  "
	cQuery += "	  AND B2_COD = '" + cProduto + "' "
	cQuery += "	  AND B2_LOCAL = '"+cLocal+"' "

	cQuery += "	  AND D_E_L_E_T_ = ' ') TB  "

	If lFilocal

		cQuery += ", ( SELECT NVL (SUM(UB_QUANT) , 0) DISPO "
		cQuery += "   FROM " + RetSQLName("SUA") + " UA, " + RetSQLName("SUB") + " UB "
		cQuery += "   WHERE UA.UA_FILIAL  = '" + SM0->M0_CODFIL + "' "
		cQuery += "   AND   UA.UA_NUM     = '"+M->UA_NUM+"'  "
		cQuery += "   AND   UA.UA_OPER    = '1'   "
		cQuery += "   AND   UA.UA_CANC    = ' ' "
		cQuery += "   AND   UA.UA_FILIAL  = UB.UB_FILIAL  "
		cQuery += "   AND   UA.UA_NUM     = UB.UB_NUM "
		cQuery += "   AND   UB.UB_PRODUTO = '"+cProduto+"'  "
		cQuery += "   AND   UB.UB_LOCAL   = '"+cLocal+"'  "
		cQuery += "   AND   UA.D_E_L_E_T_ = ' ' "
		cQuery += "   AND   UB.D_E_L_E_T_ = ' ' "
		cQuery += "  ) TC "

	EndIf

	U_ExecMySql(cQuery,"ESTOQUE","Q",.F.) //| VALIDADA CUSTO 17

	DbselectArea('ESTOQUE')

	nEstoque := GravaEstArray(cLocal)

	DbCloseArea()
	RestArea(aArea)

Return(nEstoque)
*********************************************************************
Static Function FBuscFil()//Carrega as Filiais
*********************************************************************
	Local cDescFil:=' '

	DbSelectArea("SM0")  //| Buscar todas as filiais da empresa em questao
	nRecSM0	:=	Recno()
	cCodEmp	:=	SM0->M0_CODIGO
	CfilAtu	:=	SM0->M0_CODFIL

	DbGoTop()
	While !Eof()

		If SM0->M0_CODIGO == cCodEmp .and. !(SM0->M0_CODFIL $ cSemEst) .And. SM0->M0_CODFIL != cFilAnt

			Aadd(aEstFil,{SM0->M0_CODFIL,SM0->M0_FILIAL,0,0,0,0,0})
			FEstoque() //FEstFilial() //| Busca o Estoque

		EndIf

		DbSelectArea("SM0")
		DbSkip()
	EndDo

	DbGoto(nRecSM0)

Return()
*********************************************************************
Static Function FJaUsado(cProd,cFil,lPlanilha,cLocal) //| Obtem Produtos ja Utilizados no Orcamento / Pedido em questao
*********************************************************************
	Local nQtd := 0

	Default lPlanilha := .F.
	Default cLocal 		:= "01"


	If !OperaLocal02(cLocal)
		Return nQtd
	EndIF


// Abate os itens jแ selecionados no acols da quantidade disponํvel
	For i := 1 To Len(aCols)

		If lPlanilha
			If !GDDeleted(i) .and. n != i .And. Empty(GDFieldGet('UB_FILTRAN',i)) .And. cFilAnt == cFil .And. !Empty(GDFieldGet('UB_PLANILH',i)) .And. SZE->ZE_NUMPLAN == GDFieldGet('UB_PLANILH',i) .And. cProd = GDFieldGet('UB_PRODUTO',i) .And. cLocal == GDFieldGet('UB_LOCAL',i)

				nQtd += GDFieldGet('UB_QUANT',i)

			Endif
		ElseIf !GDDeleted(i) .and. n != i .and. cFil == GDFieldGet('UB_FILTRAN',i) .and. Cfilant != cFil .and.  Empty(GDFieldGet('UB_PLANILH',i)) .and. cProd = GDFieldGet('UB_PRODUTO',i) .and. cLocal == GDFieldGet('UB_LOCAL',i)

			nQtd += GDFieldGet('UB_QUANT',i)

		ElseIf !GDDeleted(i) .and. n != i .and. Empty(GDFieldGet('UB_FILTRAN',i)) .and. Cfilant == cFil .and. Empty(GDFieldGet('UB_PLANILH',i)) .and. cProd = GDFieldGet('UB_PRODUTO',i) .And. cLocal == GDFieldGet('UB_LOCAL',i) // .and. GDFieldGet('UB_LOCAL',n) == GDFieldGet('UB_LOCAL',i)

			nQtd += GDFieldGet('UB_QUANT',i)

		Endif

	Next

Return(nQtd)
*********************************************************************
Static Function FVerPlan() //|Consulta e carrega as Planilhas
*********************************************************************
	Local aExced     	:= Array(0)
	Local nQtdDisp	  	:= 0
	Local nQtdPed	  	:= 0
	Local nQtdInf    	:= 0
	Local nAux		  	:= 0
	Local cQuery     	:= ""
	Local lContinua  	:= .F.
	Local dDataCorte	:= SuperGetMV( "MV_FILPLAN",, "20100801" )
	Local nSomaDisp		:= 0
	aListPlan 			:= {} //|Reinicializa

	If ValType( dDataCorte ) == "C"
		dDataCorte := StoD( dDataCorte )
	EndIf

	DbSelectArea("SB2");DbSetOrder(1) // B2_FILIAL + B2_PRODUTO
	DbSelectArea('SZE');DbSetOrder(4) // ZE_FILIAL + ZE_PRODUTO + ZE_DESTINO

	If SZE->( DbSeek( xFilial('SZE') + cProduto ) ) // Procura o Produto - Achou ? Sim...

		While SZE->( !Eof() ) .and. SZE->ZE_PRODUTO == cProduto .and. xFilial('SZE') == SZE->ZE_FILIAL

			nQtdPed  := 0
			nQtdDisp := 0

		//| Somente irao aparecer as Planilhas cadastradas apartir de 01 Agosto 2010 OU Planilhas que ainda nao venceram
			If SZE->ZE_DATA < dDataCorte .Or. SZE->ZE_VENCD < dDataBase
				SZE->( dbSkip() )
				Loop
			EndIf

		//| Somente Planilhas de Transferencia serao mostradas , que ainda nao foram processadas e estao Destravadas
			If SZE->ZE_TPPLAN <> "T" .Or. SZE->ZE_FLAGPT  == "S" .OR. SZE->ZE_STATUS=='2'
				SZE->( dbSkip() )
				Loop
			EndIf

		//| Filial de destino do Produto eh diferente da Filial atual, nao mostra
			If ( SZE->ZE_DESTINO <> cFilAnt .And. SZE->ZE_EXCED <= 0 )
				SZE->( dbSkip() )
				Loop
			EndIf

			nQtdInf := FJaUsado( cProduto, xFilial("SUB"), .T. )

		//| Se tem uma quantidade informada a ser transferido, pode ser para um Cliente ( Reserva ) ou pode ser que o item da Planilha seja uma transferencia para uma determinada Filial
			If SZE->ZE_QTDTRAN > 0

				nQtdPed  := U_PEDPLAN( SZE->ZE_NUMPLAN, SZE->ZE_ITEM, cProduto, SZE->ZE_CODCLI, "", "", IIF( Empty( SZE->ZE_CODCLI ), "", cFilAnt ) )
				nQtdDisp := ( SZE->ZE_QTDTRAN - SZE->ZE_QTDRES - nQtdInf - nQtdPed )

			//| Busca os Pedidos colocado pelo Excedente
			ElseIf SZE->ZE_EXCED > 0

				nQtdPed  := U_PEDPLAN( SZE->ZE_NUMPLAN, SZE->ZE_ITEM, cProduto )
				nQtdDisp := ( SZE->ZE_EXCED - SZE->ZE_QTDRES - nQtdInf - nQtdPed )

			EndIf

		//| Carrega as informacoes se tem quantidade disponivel
			nAux := Val(Posicione("SX5",1,xFilial("SX5")+"I5"+SZE->ZE_MSFIL + xFilial( "SUB" ),"X5_DESCRI"))
			nSomaDisp += nQtdDisp

		//| Carrega o Array
			Aadd(aListPlan,{'',SZE->ZE_DESTINO, SZE->ZE_NUMPLAN, SZE->ZE_ITEM, SZE->ZE_QTDTRAN, nQtdDisp, SZE->ZE_DTENTRE+nAux, Iif(!Empty(SZE->ZE_HAWB), 'Importada', 'Nacional'), SZE->ZE_CODPE, SZE->ZE_EXCED, SZE->ZE_CODCLI+'/'+SZE->ZE_LOJA})


			SZE->( DbSkip() )

		EndDo

	EndIf

	DbSelectArea('SZE');DbSetOrder(1) // ZE_FILIAL + ZE_NUMPLAN + ZE_PRODUTO + ZE_DESTINO

	If Len( aListPlan ) <= 0
		Aadd(aListPlan,{'','','','',0,0,Ctod(''),'','',0, ''})
	EndIf

Return(nSomaDisp)
*********************************************************************
Static Function FValPla()// Quando duplo click na Tela Planilhas
*********************************************************************
	Local nPos 	:= 0
	Local aRet	:= {}

	//| Consiste para nao Aceitar Zero
	aRet := U_Men("Planilhas","Aten็ใo","Informe a Quantidade:",{"OK"},nQtdDig,.T.)

	While aRet[2] == 0
		Alert("Informe Uma Quantidade ! ")
		aRet := U_Men("Planilhas","Aten็ใo","Informe a Quantidade:",{"OK"},nQtdDig,.T.)
	EndDo

	nQtdDig := aRet[2] //| Quantidade Selecionada no Get da Funcao Men

	If nQtdDig > nQtdCon //|Se Quantidade Aumentar no Momento da Selecao da Planilha Tem que Atualizar o Consultado
	//|	Processa( {|| nSeqId := SUB->(U_Write_OrcOfert(N,cFilAnt,M->UA_NUM,gdFieldGet("UB_PRODUTO",n),nQtdDig,gdFieldGet("UB_VRCACRE",n),gdFieldGet("UB_SEQID",n),GdFieldGet("UB_DTNECLI",n),GdFieldGet("UB_HRNECLI",n))) }, 'Aguarde ', 'Gerando Consultado X Ofertado' )
		nQtdCon := nQtdDig
	EndIf

	If nSldPlan > 0

		If aListPlan[nAt][POS_PLAN_QTDDISP] > 0

			If nQtdDig <= aListPlan[nAt][POS_PLAN_QTDDISP]

				nQtdOfer							+= nQtdDig					//|Quantidadfe Ofertada
				nQtdRest    						:= nQtdCon - nQtdOfer
				aListPlan[nAt][POS_PLAN_QTDDISP] 	-= nQtdDig				//|Disponival em Estoque Local
				nSldPlan							-= nQtdDig

				FSelect("P")//| Seleciona Casa Local ou Transferencia

				nQtdDig	   							:=  nQtdRest				//|Quantidade Principal

			ElseIf nQtdDig > aListPlan[nAt][POS_PLAN_QTDDISP]

				nQtdDig 								:= aListPlan[nAt][POS_PLAN_QTDDISP]
				nQtdOfer								+= aListPlan[nAt][POS_PLAN_QTDDISP]
				nQtdRest    							:= nQtdCon - nQtdOfer
				aListPlan[nAt][POS_PLAN_QTDDISP] 	-= aListPlan[nAt][POS_PLAN_QTDDISP]
				nSldPlan								-= aListPlan[nAt][POS_PLAN_QTDDISP]

				FSelect("P")//| Seleciona Casa Local ou Transferencia

				nQtdDig	   							:=  nQtdRest				//|Quantidade Principal

			EndIf

		Else
			MsgInfo(OemToAnsi('Este Planilha nใo tem saldo Disponivel. Selecione Outra Planilha !'))
		Endif

	Else
		MsgInfo(OemToAnsi('Este item nao possui um saldo disponivel em planilha!'))
	Endif

	Atu_Tela()

Return()
*********************************************************************
Static Function FCarQtd(nLinha, nQtd, cLocal, lCriaLn)//| Joga o nQtdDig para SUB
*********************************************************************

	Default cLocal 	:= "01" /// Local que deve ser utilizado
	Default lCriaLn 	:= .F.	// Se deve criar Linha

	If lCriaLn
		FCriaLinha(cProduto, lCriaLn)//| Cria Linha e Joga Produto no SUB
	EndIF
//	Alert("N = "+cValToChar(n))

	//RunTrigger(2,n,"",,PADR('UB_PRODUTO',10))

//Alimenta a Linha com a Quantidade
	__ReadVar 	:= "M->UB_QUANT"
	M->UB_QUANT	:= nQtd
	lOk 		:= CheckSX3("UB_QUANT",M->UB_QUANT)

	//GDFieldPut( "UB_QUANT", nQtd, N )
	//aCols[ N, GDFieldPos( "UB_QUANT" ) ] := nQtd
	//M->UB_QUANT	:= nQtd
	//lOk 		:= CheckSX3("UB_QUANT",M->UB_QUANT)

	//| Local
	GDFieldPut( "UB_LOCAL", cLocal, N )
	aCols[ N, GDFieldPos( "UB_LOCAL" ) ] := cLocal
	M->UB_LOCAL := cLocal
	__aItDigPrd[N,3]:= cLocal

	//| RunTrigger(2,nLinha,"",,PADR('UB_QUANT',10))
	U_RunLTriguer( n , "UB_QUANT", "UB_TES"		)
	U_RunLTriguer( n , "UB_QUANT", "UB_DESCICM"	)

	//| Jorge Oliveira - 11/02/2011 - Chamado AAZTKF - Quando a venda da mercadoria eh da propria Filial, atualiza a data de entrega.
	If Empty( gdFieldGet( "UB_FILTRAN", N ) ) .And. Empty( gdFieldGet( "UB_PLANILH", N ) )
		GDFieldPut( "UB_DTENTRE", dDataBase, N )
		aCols[ N, GDFieldPos( "UB_DTENTRE" ) ] := dDataBase
		M->UB_DTENTRE := dDataBase
	EndIf

	FCriaLinha(cProduto, .F.)//| Cria Linha e Joga Produto no SUB

Return()
*********************************************************************
Static Function FAbreTela() //| Monta a Tela  Estoques / Planilhas
*********************************************************************

//| Objetos
	Private oDlg01
	Private oListbox
	Private oListPlan
	Private oBar
	Private oGet
	Private oFolder
	Private oBQtdCon
	Private oBQtdOfer
	Private oBQtdRest
	Private oPQtdCon
	Private oPQtdOfer
	Private oPQtdRest

	Private oLaranja  := Loadbitmap( GetResources(), 'BR_LARANJA'  	)
	Private oVerde 	  := Loadbitmap( GetResources(), 'BR_VERDE'  	)
	Private oMarrom   := Loadbitmap( GetResources(), 'BR_MARRON'   	)
	Private oCinza    := Loadbitmap( GetResources(), 'BR_CINZA'    	)
	Private oAzul	  := Loadbitmap( GetResources(), 'BR_AZUL' 		)

	Private oEstLocYes  := Loadbitmap( GetResources(), 'CHECKED')
	Private oEstLocNoYes:= Loadbitmap( GetResources(), 'NOCHECKED')

	Private oEstYes  := Loadbitmap( GetResources(), 'CHECKED_15')
	Private oEstNo   := Loadbitmap( GetResources(), 'NOCHECKED_CHILD_15')

	Private oEsTransp:= Loadbitmap( GetResources(), 'CARGA_OCEAN')
	Private oEstArmaz:= Loadbitmap( GetResources(), 'ARMAZEM_MDI')

//| Caracteres
	Private cTitle	  := OemToAnsi("Estoques Filiais / Planilhas ")
	Private cAlias	  := GetArea()

//| Boleanas
	Private lFecha 	  := .F.

//| Arrays
	Private aListBox  := aClone(aEstFil)
	Private aListPlan := {} //aClone(aEstPlan)
	Private aBtn	  := Array(2)
	Private aNqtd	  := {}

//| Numericas
	Private nAux	  := 0
	Private nAt		  := 0
	Private nSldPlan		//| Saldo Total em Planilhas


	nSldPlan := FVerPlan()//| Alimenta as Quantidades em Planilhas

//Janela Principal
	Define FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	Define MSDIALOG oDlg01 TITLE cTitle FROM 001,001 TO 433,800 STYLE nOr( DS_MODALFRAME, WS_DLGFRAME )  PIXEL OF oMainWnd
	Define BUTTONBAR oBar 3D TOP OF oDlg01

//Cria as Pastas
	oFolder := TFolder():New(15,03,{"Estoques","Planilhas"},,oDlg01,,,,.T.,,395,190+5)

//Pasta Estoques
	@ 005,004 LISTBOX oListBox 	FIELDS HEADER " ","CodFil","Filial","Estoque Atual","Estoque Disponivel","Estoque Transferencia","ภ Endere็ar" SIZE X_TLIST ,Y_TLIST PIXEL Of oFolder:aDialogs[1];
		ON DBLCLICK ( nAt := oListBox:nAt, FValEst(),If(nQtdRest==0,(lFecha:=.T.,oDlg01:End()),)) NOSCROLL

	@ 015,363 Button 'Sair' Size 30,10 of oDlg01 PIXEL Action(lFecha := .T., FverRest(), oDlg01:End()) //Action(lFecha:= .T.,aVetorTrf(lFecha,oListBox:nAt,@aListBox,@nQtdDig), oDlg01:End())

	@ 140+13,318 Say "Qtd Consultada"  			of oFolder:aDialogs[1] PIXEL
	@ 150+13,318 Say "Qtd Ofertada"   				of oFolder:aDialogs[1] PIXEL
	@ 160+13,318 Say "Saldo Restante"  			of oFolder:aDialogs[1] PIXEL

	@ 138+13,361 MsGet oBQtdCon		VAR	AllTrim(Str(nQtdCon))	WHEN .F. FONT oBold						Size 025,005 of oFolder:aDialogs[1] PIXEL READONLY
	@ 148+13,361 MSGet oBQtdOfer	VAR	AllTrim(Str(nQtdOfer))	WHEN .F. FONT oBold						Size 025,005 of oFolder:aDialogs[1] PIXEL READONLY
	@ 158+13,361 MSGet oBQtdRest	VAR	Alltrim(Str(nQtdRest))  	WHEN .F. FONT oBold	Color CLR_BLUE  	Size 025,005 of oFolder:aDialogs[1] PIXEL READONLY


	@ 138+20,005 bitmap size 15,12 file 'CHECKED' NOBORDER 	of oFolder:aDialogs[1] PIXEL
	@ 138+20,020 Say "Filiais c/ Estoque"  		of oFolder:aDialogs[1] PIXEL

	@ 138+20,075 bitmap size 15,12 file 'NOCHECKED_CHILD_25' NOBORDER	of oFolder:aDialogs[1] PIXEL
	@ 138+20,092 Say "Filiais s/ Estoque"  	of oFolder:aDialogs[1] PIXEL


//Pasta Planilha
	@ 05,04  LISTBOX oListPlan FIELDS HEADER ' ','Filial','Planilha','Item','Qtd Transferida','Qtd Excedente','Qtd Disponivel','Disponivel Vitoria','Compra', 'Cod. PE','Cliente/Loja' SIZE X_TLIST,Y_TLIST PIXEL OF oFolder:aDialogs[2];
		ON DBLCLICK( nAt := oListPlan:nAt, FValPla(),If(nQtdRest==0,(lFecha:=.T.,oDlg01:End()),'')) NOSCROLL

	@ 140+13,318 Say "Qtd Consultada" 	of oFolder:aDialogs[2] PIXEL
	@ 150+13,318 Say "Qtd Ofertada"   	of oFolder:aDialogs[2] PIXEL
	@ 160+13,318 Say "Saldo Restante" 	of oFolder:aDialogs[2] PIXEL

	@ 138+13,361 MsGet oPQtdCon		VAR	cValToChar(nQtdCon)	WHEN .F. FONT oBold						Size 025,005 of oFolder:aDialogs[2] PIXEL READONLY
	@ 148+13,361 MSGet oPQtdOfer	VAR	cValToChar(nQtdOfer)	WHEN .F. FONT oBold						Size 025,005 of oFolder:aDialogs[2] PIXEL READONLY
	@ 158+13,361 MSGet oPQtdRest	VAR	cValToChar(nQtdRest)	WHEN .F. FONT oBold	Color CLR_BLUE  	Size 025,005 of oFolder:aDialogs[2] PIXEL READONLY


	@ 138+20,005 bitmap size 15,12 file 'CARGA_OCEAN' NOBORDER 	of oFolder:aDialogs[2] PIXEL
	@ 138+20,019 Say "Planilha em Transito"  		of oFolder:aDialogs[2] PIXEL

	@ 138+20,75 bitmap size 15,30 file 'ARMAZEM_MDI' NOBORDER 	of oFolder:aDialogs[2] PIXEL
	@ 138+20,92 Say "Planilha no Armazem"  		of oFolder:aDialogs[2] PIXEL

	Atu_Tela()

	If lPlanilha
		oFolder:nOption := 2
	EndIf

	Activate MsDialog oDlg01 Centered Valid lFecha

Return()
*********************************************************************
Static Function FValEst()// Quando duplo click na Tela Estoque
*********************************************************************
	Local nPos := 0
	Local aRet := U_Men("Estoques","Aten็ใo","Deseja selecionar esta casa ? ",{"Nao","Sim"})

	If aRet[1] == 1

		If aListBox[nAt][COD_FIL] == cFilAnt	//| Casa Local
			If aListBox[nAt][EST_DISPO] > 0		//| Estoque Filial
				If nQtdDig <= aListBox[nAt][EST_DISPO]

					nQtdOfer					+= 	nQtdDig				//|Quantidadfe Ofertada
					nQtdRest    				:= 	nQtdCon - nQtdOfer	//|
					aListBox[nAt][EST_TRANS]	-=	nQtdDig				//|Disponival para Transferir em Estoque Local

					FSelect("L")//| Seleciona Casa Local ou Transferencia

				ElseIf nQtdDig > aListBox[nAt][EST_DISPO]

					nQtdDig 					:= aListBox[nAt][EST_DISPO]
					nQtdOfer					+= aListBox[nAt][EST_DISPO]
					nQtdRest    				:= nQtdCon - nQtdOfer
					aListBox[nAt][EST_DISPO] 	-= aListBox[nAt][EST_DISPO]

					FSelect("L")//| Seleciona Casa Local ou Transferencia

					nQtdDig	   				:=  nQtdRest				//|Quantidade Principal

				EndIf
			Else
				MsgInfo(OemToAnsi('Este item nao possui um saldo disponivel na Casa [Local]!'))
			Endif

		Else // Outras Filial

			nPos := aScan(aEstFil,{|x| x[1] == cFilAnt})

			If aListBox[nPos][EST_DISPO] == 0 //| Veririfica se o saldo local ja foi Utilizado

				If aListBox[nAt][EST_TRANS] > 0 //| Verifica se Tem Saldo a Transferir em Outra Filial Selecionada

					If nQtdDig <= aListBox[nAt][EST_TRANS]

						nQtdOfer					+=  nQtdDig				//|Quantidadfe Ofertada
						nQtdRest    				:= 	nQtdCon - nQtdOfer	//|
						aListBox[nAt][EST_TRANS]	-=  nQtdDig				//|Disponival em Estoque Local

						FSelect("T")//| Seleciona Casa Local ou Transferencia

					ElseIf nQtdDig > aListBox[nAt][EST_TRANS]

						nQtdDig 						:= aListBox[nAt][EST_TRANS]
						nQtdOfer   					+= aListBox[nAt][EST_TRANS]
						nQtdRest    				:= nQtdCon - nQtdOfer
						aListBox[nAt][EST_TRANS] 	-= aListBox[nAt][EST_TRANS]

						FSelect("T")//| Seleciona Casa Local ou Transferencia

						nQtdDig						:=  nQtdRest				//|Quantidade Principal

					EndIf
				Else
					MsgInfo(OemToAnsi("Esta Casa nao possui estoque de transferencia!"))
				EndIf

			Else

				MsgInfo(OemToAnsi('Este item possui um saldo disponivel na Casa [Local] que deve ser utilizado antes!'))

			Endif

		Endif

	Endif

	Atu_Tela()

Return()
*********************************************************************
Static Function FverRest() //| Lanca a quantidade restante no SUB com ha linha deletada quando sair da Tela de Estoques / Planilhas....
*********************************************************************
	Local cLocal 		:= GDFieldGet('UB_LOCAL',n)
	Local dDataVazia := cToD("  / /  ")

//| Caso nao tenha sido selecionado nenhuma casa
	If nQtdRest > 0 .and. lFirst

		FCarQtd(n, nQtdDig)		//| Joga nQtdDig no SUB

	//Roda gatilhos mesmo com a linha deletada -  Edivaldo Goncalves Cordeiro em 04/08/2010
		FCarQtd(n, nQtdDig)	//| Joga nQtdDig no SUB

	// Jorge Oliveira - 11/02/2011 - Chamado AAZTKF - So tem data de previsao de entrega se tiver saldo
		GDFieldPut( "UB_DTENTRE", dDataVazia, N )
		aCols[ N, GDFieldPos( "UB_DTENTRE" ) ] := dDataVazia
		M->UB_DTENTRE := dDataVazia

		Eval(bDel)    			//| Deleta a Linha

	ElseIf nQtdRest > 0



		FCarQtd(n, nQtdRest, cLocal,.T.)

		//FCriaLinha(cProduto,.T.)	//| Cria Linha e Joga Produto no SUB

		//FCarQtd(N, nQtdRest)	//| Joga nQtdDig no SUB

		//FCarQtd(N, nQtdRest)	//| Joga nQtdDig no SUB

	// so tem data de previsao de entrega se tiver saldo
		GDFieldPut( "UB_DTENTRE", dDataVazia, N )
		aCols[ N, GDFieldPos( "UB_DTENTRE" ) ] := dDataVazia
		M->UB_DTENTRE := dDataVazia

		Eval(bDel)    			//| Deleta a Linha

	Endif

Return()
*********************************************************************
Static Function Atu_Tela()//| Atualiza Tela de Estoques / Planilhas
*********************************************************************

	oListBox:SetArray(aListBox)
	oListBox:bLine := { ||{		IIf(aListBox[oListBox:nAt,COD_FIL] == cFilAnt , IIf(aListBox[oListBox:nAt,EST_DISPO] == 0 , oEstNo ,oEstYes) , IIf(aListBox[oListBox:nAt,EST_TRANS] == 0 , oEstNo ,oEstYes)),;
		aListBox[oListBox:nAt,COD_FIL] 		,;
		aListBox[oListBox:nAt,NOM_FIL] 		,;
		aListBox[oListBox:nAt,EST_ATUAL] 	,;
		aListBox[oListBox:nAt,EST_DISPO] 	,;
		aListBox[oListBox:nAt,EST_TRANS] 	,;
		aListBox[oListBox:nAt,EST_QACLA] } }

	oGetTlv:Refresh()
	oListBox:Refresh()

	oBQtdCon:Refresh()
	oBQtdOfer:Refresh()
	oBQtdRest:Refresh()

	oListPlan:SetArray(aListPlan)
	oListPlan:bLine:={|| {IIf(aListPlan[oListPlan:nAt,POS_PLAN_NUMPLAN]='1'  , oCinza  ,oEsTransp ),;
		aListPlan[ oListPlan:nAt, POS_PLAN_DESTINO ],;
		aListPlan[ oListPlan:nAt, POS_PLAN_NUMPLAN ],;
		aListPlan[ oListPlan:nAt, POS_PLAN_ITEM    ],;
		aListPlan[ oListPlan:nAt, POS_PLAN_QTDPLA  ],;
		aListPlan[ oListPlan:nAt, POS_PLAN_EXCED   ],;
		aListPlan[ oListPlan:nAt, POS_PLAN_QTDDISP ],;
		aListPlan[ oListPlan:nAt, POS_PLAN_DTENTRE ],;
		aListPlan[ oListPlan:nAt, POS_PLAN_HAWB    ],;
		aListPlan[ oListPlan:nAt, POS_PLAN_CODPE   ],;
		aListPlan[ oListPlan:nAt, POS_PLAN_CLIENTE ]}}
	oListPlan:Refresh()

	oGetTlv:Refresh()
	oListPlan:Refresh()

	oPQtdCon:Refresh()
	oPQtdOfer:Refresh()
	oPQtdRest:Refresh()


Return()
*********************************************************************
Static Function FSelect(cPar) //| Seleciona Estoque / Planilha a ser utilizada
*********************************************************************
//| cPar == "T" - Transferencia Entre Filiais
//| cPar == "P" - Transferencia por Planilhas
//| cPar == "L" - Selecionada Filial Local

	If lFirst //| Primeira Selecao

		lFirst := .F.

		Do Case
		Case cPar == "T"
			GrvFilTran()	//|Grava Dados Da Filial de transferencia
		Case cPar == "P"
			GrvPlan()		//|Grava Dados da planilha
		Case cPar == "L"
			FCriaLinha(cProduto)
		EndCase

		//FCarQtd(N, nQtdDig) //| Joga nQtdDig no SUB

		Atende()

	Else //| Demais Selecoes

		FCriaLinha(cProduto)//| Cria Linha e Joga Produto no SUB

		Do Case
		Case cPar == "T"
			GrvFilTran()	//|Grava Dados Da Filial de transferencia
		Case cPar == "P"
			GrvPlan()		//|Grava dados da planilha Tratamento Planilha
		Case cPar == "L"
		EndCase

		FCarQtd(n,nQtdDig) //| Joga nQtdDig no SUB

	Endif

Return()
*********************************************************************
Static Function GrvFilTran() //| Grava dados da Filial Selecinona no SUB
*********************************************************************
	Local cFilTrans 	:= aListBox[nAt][COD_FIL]
	Local cAux 			:= Tabela("I5",cFilTrans+cFilAnt)
	Local nAux 			:= Val(cAux)
	Local dDtEntrega 	:= dDataBase + nAux

	GDFieldPut('UB_FILTRAN'	, cFilTrans		, N)
	GDFieldPut('UB_DTENTRE'	, dDtEntrega 	, N)
	GDFieldPut('UB_PLANILH'	, ''			, N)
	GDFieldPut('UB_PLITEM'	, ''			, N)

Return()
*********************************************************************
Static Function GrvPlan()//| Grava dados da Planilha selecionada no SUB
*********************************************************************

	GDFieldPut( 'UB_DTNECLI', aListPlan[ nAt, POS_PLAN_DTENTRE	], N )
	GDFieldPut( 'UB_DTENTRE', aListPlan[ nAt, POS_PLAN_DTENTRE ], N )
	GDFieldPut( 'UB_PLANILH', aListPlan[ nAt, POS_PLAN_NUMPLAN	], N )
	GDFieldPut( 'UB_PLITEM'	, aListPlan[ nAt, POS_PLAN_ITEM	], N )
	GDFieldPut( 'UB_EMISSAO', dDataBase, N )

Return()
*********************************************************************
Static Function FCriaLinha(cProd, lCria)//| Cria Linha e Joga Produto no SUB
*********************************************************************

	Default lCria := .F.

	If lCria

		If FAddLinha()

			__ReadVar 			:= "M->UB_PRODUTO"

			GDFieldPut( "UB_PRODUTO", cProd, N )
			aCols[ N, GDFieldPos( "UB_PRODUTO" ) ] := cProd
			M->UB_PRODUTO       := cProd

			lOk := CheckSX3('UB_PRODUTO',M->UB_PRODUTO)
			RunTrigger(2,n,"",,PADR('UB_PRODUTO',10))
			//Alert(cValToChar(n) + " " +  cValToChar(lCria))

		EndIf

	Else
		__ReadVar 			:= "M->UB_PRODUTO"

		GDFieldPut( "UB_PRODUTO", cProd, N )
		aCols[ N, GDFieldPos( "UB_PRODUTO" ) ] := cProd
		M->UB_PRODUTO       := cProd

		lOk := CheckSX3('UB_PRODUTO',M->UB_PRODUTO)
		RunTrigger(2,n,"",,PADR('UB_PRODUTO',10))
		//	Alert(cValToChar(n) + " " +  cValToChar(lCria))
	EndIf



Return()
*********************************************************************
Static Function FPromo()//| Informa Produto Promocao
*********************************************************************

	SB1-> ( DbSeek(xFilial( "SB1" ) + gdFieldGet("UB_PRODUTO",n),.F.))
	cPromocao := SB1->B1_CLASSVE //SB1->(Posicione( "SB1", 1, xFilial( "SB1" ) + gdFieldGet("UB_PRODUTO",n),"B1_CLASSVE"))
	_cDescPro := Alltrim(gdFieldGet("UB_PRODUTO",n))+'/'+ Alltrim(Posicione( "SB1", 1, xFilial( "SB1" ) + gdFieldGet("UB_PRODUTO",n),"B1_DESC"))

//Inserido por Edivaldo Goncalves Cordeiro em 16/01/09 avisa o operador quando o produto esta na Promocao
	If cPromocao == "2"
		cMens := OemToAnsi("P R O M O C A O")+chr(13)+chr(13)
		cMens := cMens + OemToAnsi("O Produto " + _cDescPro + " esta na Promo็ใo ") + chr(13) + chr(13)
		Msginfo( cMens,  OemToAnsi("Aten็ใo"),"INFO")
	Endif

Return()
*********************************************************************
Static Function FAddLinha()//Testa se pode ser Criado uma Linha
*********************************************************************
	Local lCriou := .F.

	IF !Empty(aCols[Len(acols),GdFieldPos("UB_PRODUTO")])
		lCriou := .T.
		eVal( oGetTlv:obrowse:badd ) //| ADICIONA UMA LINHA NA GETDADOS AUTOMATICAMENTE
		oGetTlv:oBrowse:Refresh()
		oGetTlv:oBrowse:nAt := n
		//oGetTlv:oBrowse:BldBlClick()
	Endif
Return lCriou
*********************************************************************
User Function PedPlan( cNumPlan, cItem, cProd, cCliMesmo, cCliOutros, cPedVen, cFilMov )//|Soma os Produtos da planilha, que estao em pedidos .
*********************************************************************
	Local cQuery   := ""
	Local _nRecSM0 := ""
	Local cFiliais := ""
	Local nQtdPed  := 0
	Local cCliTrf  := GetMV( "MV_IMDEPA" )

	cFiliais :=  U_cRetFils("Q")

	cQuery := "SELECT SUM( C6_QTDVEN - C6_QTDENT ) AS QTDPED "
	cQuery += "  FROM " + RetSQLName("SC6") + " "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += "   AND C6_FILIAL  IN ( " + cFiliais + " ) "
	cQuery += "   AND C6_PRODUTO = '" + cProd + "' "
	cQuery += "   AND C6_PLANILH = '" + cNumPlan + "' "
	cQuery += "   AND C6_PLITEM  = '" + cItem + "' "

// Caso tenha alterado algum Atendimento que jah tenha gerado PV, nao pode consultar esse pedido.
	If ValType( cPedVen ) == "C" .And. !Empty( cPedVen )
		cQuery += "AND C6_NUNM <> '" + cPedVen + "' "
	EndIf

// Se informado um Cliente, irah buscar a soma dos seus pedidos em qualquer filial.
	If ValType( cCliMesmo ) == "C" .And. !Empty( cCliMesmo )
		cQuery += "AND C6_CLI  = '" + cCliMesmo + "' "

	// Se informado o Codigo de Cliente, irah buscar a soma dos pedidos de outros Clientes em qualquer filial isso eh
	// utilizado na Manutencao da Planilha, para consultar se o Excedente eh suficiente para os clientes diferentes do informado
	ElseIf ValType( cCliOutros ) == "C" .And. !Empty( cCliOutros )
		cQuery += "AND C6_CLI <> '" + cCliOutros + "' "

	// O padrao eh consultar as vendas de Planilha que sao diferentes do Cliente Imdepa
	Else
		cQuery += "AND C6_CLI <> '" + cCliTrf + "' "
	EndIf

	U_ExecMySql(cQuery,"QRYPLA","Q")

	DbselectArea( "QRYPLA" )

// Soma os Produtos dessa mesma planilha, mesmo que ainda nao tenha sido faturado ou liberado o pedido
	If QRYPLA->( !EOF() )
		nQtdPed := QRYPLA->QTDPED
	Else
		nQtdPed := 0
	EndIf

	QRYPLA->( DbCLoseArea() )

Return( nQtdPed )
*********************************************************************
Static Function OperaLocal02(cLocal) /// Valida as Filiais que Operam com Local 02 ... Evitar Processamento Desnecessario
*********************************************************************
	Local lOpera 			:= .F.
	Local FilComEst02 	:= GetMv("IM_OPERE02") //"09"   /// Filiais que Operam com Estoque 02

//| Valida se filial opera com Estoque 02 ...
	If cLocal == "02" .And. (Cfilant $ FilComEst02)
		lOpera := .T.
	ElseIf cLocal == "01"
		lOpera := .T.
	EndIf

Return ( lOpera )
*********************************************************************
Static Function GravaEstArray(cLocal)// Salva o estoque obtido na query para o array pricipal que vai ser utilizado na tela ...
*********************************************************************
	Local nJaUsado := FJaUsado(cProduto,SM0->M0_CODFIL,.F.,cLocal) //FJaUsado(cProduto,SM0->M0_CODFIL)

	nPos := aScan(aEstFil,{|x| x[1] == SM0->M0_CODFIL}) //Obtem Posicao da Filial no Acols de Estoques

	aEstFil[nPos][EST_ATUAL] += ESTOQUE->ATUAL

	If Cfilant == SM0->M0_CODFIL
		aEstFil[nPos][EST_DISPO] += ESTOQUE->DISPO - nJaUsado
		aEstFil[nPos][EST_TRANS] += 0
	Else
		aEstFil[nPos][EST_DISPO] += ESTOQUE->DISPO
		aEstFil[nPos][EST_TRANS] += ESTOQUE->TRANS - nJaUsado
	EndIF

	aEstFil[nPos][EST_QACLA] += ESTOQUE->QACLA
	aEstFil[nPos][EST_SLAUX] += 0

Return(ESTOQUE->DISPO - nJaUsado)
*********************************************************************
User Function RunLTriguer( n , cCampGat, cCampDest )
*********************************************************************
	Local xRetorno

	If cCampGat == "UB_QUANT"

		If cCampDest == "UB_DESCICM"

			xRetorno := SUB->( U_IMDG008() )

			GDFieldPut(cCampDest	, xRetorno		, n)
			aCols[ N, GDFieldPos( cCampDest ) ] := xRetorno
			M->UB_DESCICM := xRetorno

		EndIF

		If cCampDest == "UB_TES"

			xRetorno := U_FPARTES("S","N")

			__AuxReadVar := __ReadVar
			__ReadVar 		:= "M->UB_TES"


			GDFieldPut(cCampDest	, xRetorno		, n)
			aCols[ N, GDFieldPos( cCampDest ) ] := xRetorno
			M->UB_TES := xRetorno

			//Alert(cValToChar(N))

			lOk 			:= CheckSX3("UB_TES",xRetorno)
			RunTrigger(2,n,"",,PADR('UB_TES',10))
			__ReadVar := __AuxReadVar
		EndIF

	EndIF

Return()
