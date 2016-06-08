#Include "Protheus.ch"
#Include "Rwmake.ch"


#DEFINE COD_FIL     		1 //B2_QATU
#DEFINE NOM_FIL     		2 //SALDO DISPONIVEL
#DEFINE EST_ATUAL      		3 //B2_QATU
#DEFINE EST_DISPO      		4 //SALDO DISPONIVEL
#DEFINE EST_TRANS      		5 //TRANSFERENCIA
#DEFINE EST_QACLA      		6 //A CLASSIFICAR
#DEFINE EST_SLAUX      		7 //SALDO AUXILIAR

#DEFINE POS_PLAN_DESTINO	2
#DEFINE POS_PLAN_NUMPLAN	3
#DEFINE POS_PLAN_ITEM		4
#DEFINE POS_PLAN_QTDPLA	    5
#DEFINE POS_PLAN_QTDDISP	6
#DEFINE POS_PLAN_DTENTRE	7
#DEFINE POS_PLAN_HAWB		8
#DEFINE POS_PLAN_CODPE		9
#DEFINE POS_PLAN_EXCED		10
#DEFINE POS_PLAN_CLIENTE	11

#DEFINE X_TLIST        		385
#DEFINE Y_TLIST        		130+15

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

//| Declaracao de Variaveis
Private nQuant		:= 0  //|Quantidade Principal
Private nQtdCon		:= 0  //|Quantidadfe Consultada
Private nQtdOfer		:= 0  //|Quantidadfe Ofertada
Private nOfePlan		:= 0  //|Quantidadfe Ofertada
Private nQtdRest   	:= 0  //|Quantidade Restante
Private nQtdEst 		:= 0  //|Disponival em Estoque Local
Private nSldPlan		:= 0  //|Quantidade Total Somando as Planilhas
Private nQtdAcols	:= 0  //|Quantidade ja utilizado no orcamento
Private nExced		:= 0  //|Quantidade Excedente em Planilhas
Private aEstFil 		:= {} //|Estoque das Filiais
Private aEstPlan		:= {}
Private cProduto 	:= gdFieldGet("UB_PRODUTO",n)
Private cImdepa 		:= GetMV('MV_IMDEPA')
Private cSemEst 		:= GetMV('MV_FILSEST')
Private nControle	:= 0
Private lFirst	  	:= .T.
Private lPlanilha	:= .F.
Private lnB2b		:= (FUNNAME() <> "IMDB2BPV" .OR. FUNNAME() <> "GERB2B")

//| Testa ah Recursividade
If GdDeleted(n) .Or. Type('lRecursivo') != 'U'
	Return (.T.)
Else
	If Type('lRecursivo') == 'U'
		Private lRecursivo := .T.
	Endif
Endif


FRodaFun()	//| Rodda Funcoes Padroes e Inicializa Campos Necessarios

nQtdCon := nQuant //|

//If lnB2b
//	FPromo()	//|Regras Relativas a Promocoes
//Endif

FEstoque()	//|Verifica Estoque Filial

nQtdAcols := FJaUsado(cProduto,xFilial("SUB"))  //|Verifica Quantidade ja utilizada no atual orcamento

If FVerPlan() > 0
	lPlanilha := .T. //|Verifica se Possui saldo em Planilha
	If !MsgYesNo( "Existe(m) Planilha(s) para o Produto informado."+Chr(13)+"Deseja vizualizar a(s) Planilha(s) ?","Planilhas" )
		lPlanilha := .F. //|Verifica se Possui saldo em Planilha
	EndIf
EndIf

If nQuant <= (nQtdEst -  nQtdAcols) .And. !lPlanilha   //|Quantidade em Estoque Supri ah Necessidade ?

	If !lPlanilha
		FCarQtd(N, nQuant) //| Joga nQuant no SUB

		// Jorge Oliveira - 04/01/2011 - Chamado AAZTEJ - Colocar na tela o Produto similar da Marca FAG
		If lnB2b

			//		DbSelectArea( "SB1" );DbSetOrder( 1 ) // B1_FILIAL + B1_COD
			//		SB1->( DbSeek( xFilial( "SB1" ) + cProduto ) )

			//		If AllTrim( SB1->B1_MARCA ) == "INA" .And. !Empty( AllTrim( SB1->B1_SGRB1 ) )
			//
			//		MsAguarde( {|| U_F190EQUI( SB1->B1_COD, SB1->B1_SGRB1 ) }, "Aguarde...", "Consultando Produto equivalente..." )
			//
			//		EndIf

		EndIf

		Return(.T.)

	EndIf

EndIf

FBuscFil()	//  Busca Filiais e Seus Estoques

If lnB2b
	FAbreTela()	 // Abri tela com Estoques e Filiais
Endif


Return(.T.)
*********************************************************************
Static Function FRodaFun()//| Roda Funcoes Padroes e Inicializa Campos Necessarios
*********************************************************************

//| Inicializacoes Necessarias
If inclui .OR.  __COPIATT //| Bloqueia o Atendimento. Nao sai sem concluir.
	__Podesair := "N"
EndIf

nControle 	:= N
nQtdAux 	:= nQuant := &(Readvar())//|Quantidade Digitada    o q
nQtdRest 	:= nQuant

If lnB2b	//| Dispara Consultado e Ofertado
	Processa( {|| nSeqId := SUB->(U_Write_OrcOfert(n,cFilAnt,M->UA_NUM,gdFieldGet("UB_PRODUTO",n),nQuant,gdFieldGet("UB_VRCACRE",n),gdFieldGet("UB_SEQID",n),GdFieldGet("UB_DTNECLI",n),GdFieldGet("UB_HRNECLI",n))) }, 'Aguarde ', 'Gerando Consultado X Ofertado' )
Else
	nSeqId := SUB->(U_Write_OrcOfert(n,cFilAnt,M->UA_NUM,gdFieldGet("UB_PRODUTO",n),nQuant,gdFieldGet("UB_VRCACRE",n),gdFieldGet("UB_SEQID",n),GdFieldGet("UB_DTNECLI",n),GdFieldGet("UB_HRNECLI",n)))
Endif


Return()
*********************************************************************
Static Function FPromo()//| Informa Produto Promocao
*********************************************************************

cPromocao := SB1->(Posicione( "SB1", 1, xFilial( "SB1" ) + gdFieldGet("UB_PRODUTO",n),"B1_CLASSVE"))
_cDescPro := Alltrim(gdFieldGet("UB_PRODUTO",n))+'/'+ Alltrim(Posicione( "SB1", 1, xFilial( "SB1" ) + gdFieldGet("UB_PRODUTO",n),"B1_DESC"))

//Inserido por Edivaldo Goncalves Cordeiro em 16/01/09 avisa o operador quando o produto esta na Promocao
If cPromocao == "2"
	cMens := OemToAnsi("P R O M O C A O")+chr(13)+chr(13)
	cMens := cMens + OemToAnsi("O Produto " + _cDescPro + " esta na Promo็ใo ") + chr(13) + chr(13)
	Msginfo( cMens,  OemToAnsi("Aten็ใo"),"INFO")
Endif

Return()
*********************************************************************
Static Function FEstoque()//| Levanta o Estoque da Filial Atual
*********************************************************************
Local cQuery
Local aArea	:= GetArea()

cQuery := " SELECT SUM(TA.QTD + TB.QTD + TC.QTD) QTD "
cQuery += " FROM "
cQuery += " ( SELECT NVL( SUM( C6_QTDVEN - C6_QTDENT ), 0 ) QTD "
cQuery += "	  FROM " + RetSQLName("SC6") + " SC6, " + RetSQLName("SC7") + " SC7 "
cQuery += "	  WHERE C6_FILIAL = '" 	+ xFilial("SC6") 	+ "' "
cQuery += "	  AND C6_PRODUTO = '" 	+ cProduto + "' "
cQuery += "	  AND C6_CLI <> '" 		+ cImdepa 			+ "' AND ( C6_PLANILH <> ' ' OR C6_FILTRAN <> ' ' ) "
cQuery += "	  AND C6_NOTA = ' ' "
cQuery += "	  AND SC6.D_E_L_E_T_ = ' ' "
cQuery += "	  AND C7_FILIAL = C6_FILIAL "
cQuery += "	  AND C7_PLANILH = C6_PLANILH "
cQuery += "	  AND C7_PLITEM = C6_PLITEM "
cQuery += "	  AND ( C7_QUANT - C7_QUJE ) > 0 "
cQuery += "	  AND SC7.D_E_L_E_T_ = ' ') TA, "

cQuery += "	( SELECT (B2_QATU - B2_RESERVA - B2_QPEDVEN - B2_QACLASS) QTD "
cQuery += "	  FROM " + RetSQLName("SB2") + " "
cQuery += "	  WHERE B2_FILIAL = '" + xFilial("SB2") + "'  "
cQuery += "	  AND B2_COD = '" + cProduto + "' "
cQuery += "	  AND B2_LOCAL = '01' "
cQuery += "	  AND D_E_L_E_T_ = ' ') TB, "

cQuery += " ( SELECT NVL (SUM(UB_QUANT) , 0) QTD "
cQuery += "   FROM " + RetSQLName("SUA") + " UA, " + RetSQLName("SUB") + " UB "
cQuery += "   WHERE UA.UA_FILIAL  = '" + xFilial( "SUA" ) + "' "
cQuery += "   AND   UA.UA_NUM     = '"+M->UA_NUM+"'  "
cQuery += "   AND   UA.UA_OPER    = '1'   "
cQuery += "   AND   UA.UA_CANC    = ' ' "
cQuery += "   AND   UA.UA_FILIAL  = UB.UB_FILIAL  "
cQuery += "   AND   UA.UA_NUM     = UB.UB_NUM "
cQuery += "   AND   UB.UB_PRODUTO = '"+cProduto+"'  "
cQuery += "   AND   UA.D_E_L_E_T_ = ' ' "
cQuery += "   AND   UB.D_E_L_E_T_ = ' ' "
cQuery += "  ) TC "

U_ExecMySql(cQuery,"cQuery","Q") //| VALIDADA CUSTO 17

DbselectArea('cQuery')

nQtdEst	:=	cQuery->QTD

DbCloseArea()
RestArea(aArea)

Return()
*********************************************************************
Static Function FJaUsado(cProd,cFil,lPlanilha) //| Obtem Produtos ja Utilizados no Orcamento / Pedido em questao
*********************************************************************
Local nQtd := 0

Default lPlanilha := .F.

// Abate os itens jแ selecionados no acols da quantidade disponํvel
For i := 1 To Len(aCols)


	If lPlanilha
		If !GDDeleted(i) .and. n != i .And. Empty(GDFieldGet('UB_FILTRAN',i)) .And. cFilAnt == cFil .And. !Empty(GDFieldGet('UB_PLANILH',i)) .And. SZE->ZE_NUMPLAN == GDFieldGet('UB_PLANILH',i) .And. cProd = GDFieldGet('UB_PRODUTO',i) .And. GDFieldGet('UB_LOCAL',n) = GDFieldGet('UB_LOCAL',i)

			nQtd += GDFieldGet('UB_QUANT',i)

		Endif
	ElseIf !GDDeleted(i) .and. n != i .and. cFil == GDFieldGet('UB_FILTRAN',i) .and. Cfilant != cFil .and.  Empty(GDFieldGet('UB_PLANILH',i)) .and. cProd = GDFieldGet('UB_PRODUTO',i) .and. GDFieldGet('UB_LOCAL',n) = GDFieldGet('UB_LOCAL',i)

		nQtd += GDFieldGet('UB_QUANT',i)

	ElseIf !GDDeleted(i) .and. n != i .and. Empty(GDFieldGet('UB_FILTRAN',i)) .and. Cfilant == cFil .and. Empty(GDFieldGet('UB_PLANILH',i)) .and. cProd = GDFieldGet('UB_PRODUTO',i) .and. GDFieldGet('UB_LOCAL',n) = GDFieldGet('UB_LOCAL',i)

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

If SZE->( DbSeek( xFilial('SZE') + cProduto ) )

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
	//OKAadd(aListPlan,{'','','',0,0,Ctod(''),'','',0, ''})
	Aadd(aListPlan,{'','','','',0,0,Ctod(''),'','',0, ''})
EndIf

Return(nSomaDisp)
*********************************************************************
Static Function FCarQtd(nLinha, nQtd)//| Joga o nQuant para SUB
*********************************************************************

//Alimenta a Linha com a Quantidade
__ReadVar 	:= "M->UB_QUANT"
M->UB_QUANT	:= nQtd
lOk 		:= CheckSX3("UB_QUANT",M->UB_QUANT)
RunTrigger(2,nLinha,"",,PADR('UB_QUANT',10))

// Jorge Oliveira - 11/02/2011 - Chamado AAZTKF - Quando a venda da mercadoria eh da propria Filial, atualiza a data de entrega.
If Empty( gdFieldGet( "UB_FILTRAN", N ) ) .And. Empty( gdFieldGet( "UB_PLANILH", N ) )
	GDFieldPut( "UB_DTENTRE", dDataBase, N )
	aCols[ N, GDFieldPos( "UB_DTENTRE" ) ] := dDataBase
	M->UB_DTENTRE := dDataBase
EndIf

//__ReadVar 			:= "M->UB_PRODUTO"
//M->UB_PRODUTO       := cProduto
//lOk := CheckSX3('UB_PRODUTO',M->UB_PRODUTO)
RunTrigger(2,n,"",,PADR('UB_PRODUTO',10))

Return()
*********************************************************************
Static Function FBuscFil()//Carrega as Filiais
*********************************************************************
Local cDescFil:=' '
//| Buscar todas as filiais da empresa em questao
DbSelectArea("SM0")
nRecSM0	:=	Recno()
cCodEmp	:=	SM0->M0_CODIGO
CfilAtu	:=	SM0->M0_CODFIL

DbGoTop()
While !Eof()
cDescFil:=M0_FILIAL
 If CfilAtu == SM0->M0_CODFIL
  cDescFil:='** '+M0_FILIAL
 Endif

	If SM0->M0_CODIGO == cCodEmp .and. !(SM0->M0_CODFIL $ cSemEst) //.and. SM0->M0_CODFIL != CfilAtu
		//Aadd(aEstFil,{M0_CODFIL,M0_FILIAL,0,0,0,0,0})
		Aadd(aEstFil,{M0_CODFIL,cDescFil,0,0,0,0,0})

		FEstImd()//Busca o Estoque
	EndIf
	DbSkip()
EndDo

DbGoto(nRecSM0)

Return()
*********************************************************************
Static Function FEstImd()// Busca Estoque de Todas as Filiais apartir da FBuscFil
*********************************************************************
Local cQuery
Local aArea	 := GetArea()

cQuery := " SELECT SUM(TA.SALDO + TB.SALDO) ATUAL, SUM(TA.QTD + TB.QTD) DISPO, SUM(TA.QTRANS + TB.QTRANS) TRANS, SUM(TA.QACLASS + TB.QACLASS) QACLA  "
cQuery += " FROM( "
cQuery += " 	 SELECT 0 SALDO, NVL( SUM(C6_QTDVEN - C6_QTDENT ), 0 ) QTD, 0 QTRANS, 0 QACLASS "
cQuery += " 	 FROM SC6010 SC6, SC7010 SC7 	   "
cQuery += " 	 WHERE C6_FILIAL = '"+SM0->M0_CODFIL+"' 	   "
cQuery += " 	 AND C6_PRODUTO = '"+cProduto+"' 	   "
cQuery += " 	 AND C6_CLI <> '"+cImdepa+"'  "
cQuery += " 	 AND ( C6_PLANILH <> ' ' OR C6_FILTRAN <> ' ' ) 	   "
cQuery += " 	 AND C6_NOTA = ' ' 	   "
cQuery += " 	 AND SC6.D_E_L_E_T_ = ' ' 	   "
cQuery += " 	 AND C7_FILIAL = C6_FILIAL 	   "
cQuery += " 	 AND C7_PLANILH = C6_PLANILH 	   "
cQuery += " 	 AND C7_PLITEM = C6_PLITEM 	   "
cQuery += " 	 AND ( C7_QUANT - C7_QUJE ) > 0 	   "
cQuery += " 	 AND SC7.D_E_L_E_T_ = ' '  "
cQuery += " 	) TA, 	 "

cQuery += " 	(  "
cQuery += " 	 SELECT B2_QATU SALDO, (B2_QATU - B2_RESERVA - B2_QPEDVEN - B2_QACLASS) QTD, B2_QTRANS QTRANS, B2_QACLASS QACLASS    "
cQuery += " 	 FROM  SB2010 	   "
cQuery += " 	 WHERE B2_FILIAL = '"+SM0->M0_CODFIL+"'  	   "
cQuery += " 	 AND B2_COD = '"+cProduto+"' 	   "
cQuery += " 	 AND B2_LOCAL = '01' 	   "
cQuery += " 	 AND D_E_L_E_T_ = ' ' "
cQuery += " 	) TB "

U_ExecMySql(cQuery, "cQuery", "Q")//| VALIDADO CUSTO TOTAL 10

DbSelectArea('cQuery')

nPos := aScan(aEstFil,{|x| x[1] == SM0->M0_CODFIL})

aEstFil[nPos][EST_ATUAL] := cQuery->ATUAL

If Cfilant == SM0->M0_CODFIL
	aEstFil[nPos][EST_DISPO] := cQuery->DISPO - nQtdAcols
	aEstFil[nPos][EST_TRANS] := 0
Else
	aEstFil[nPos][EST_DISPO] := cQuery->DISPO
	aEstFil[nPos][EST_TRANS] := cQuery->TRANS - FJaUsado(cProduto,SM0->M0_CODFIL)
Endif

aEstFil[nPos][EST_QACLA] := cQuery->QACLA
aEstFil[nPos][EST_SLAUX] := 0

DbCloseArea()
RestArea(aArea)

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
//ATUAL Private oEstLocNoYes:= Loadbitmap( GetResources(), 'NOCHECKED_CHILD_15')
Private oEstLocNoYes:= Loadbitmap( GetResources(), 'NOCHECKED')



//EDI Private oEstYes  := Loadbitmap( GetResources(), 'CHECKED')
//EDI Private oEstNo   := Loadbitmap( GetResources(), 'NOCHECKED_CHILD_25')

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

@ 015,363 Button 'Sair' Size 30,10 of oDlg01 PIXEL Action(lFecha := .T., FverRest(), oDlg01:End()) //Action(lFecha:= .T.,aVetorTrf(lFecha,oListBox:nAt,@aListBox,@nQuant), oDlg01:End())

@ 140+13,318 Say "Qtd Consultada"  			of oFolder:aDialogs[1] PIXEL
@ 150+13,318 Say "Qtd Ofertada"   				of oFolder:aDialogs[1] PIXEL
@ 160+13,318 Say "Saldo Restante"  			of oFolder:aDialogs[1] PIXEL

@ 138+13,361 MsGet oBQtdCon	VAR	AllTrim(Str(nQtdCon))		WHEN .F. FONT oBold					Size 025,005 of oFolder:aDialogs[1] PIXEL READONLY
@ 148+13,361 MSGet oBQtdOfer	VAR	AllTrim(Str(nQtdOfer))		WHEN .F. FONT oBold					Size 025,005 of oFolder:aDialogs[1] PIXEL READONLY
@ 158+13,361 MSGet oBQtdRest	VAR	Alltrim(Str(nQtdRest))  	WHEN .F. FONT oBold	Color CLR_BLUE  Size 025,005 of oFolder:aDialogs[1] PIXEL READONLY


//@ 138,005 bitmap size 7,7 file 'CHECKED_CHILD_15' NOBORDER 	of oFolder:aDialogs[1] PIXEL
@ 138+20,005 bitmap size 15,12 file 'CHECKED' NOBORDER 	of oFolder:aDialogs[1] PIXEL
@ 138+20,020 Say "Filiais c/ Estoque"  		of oFolder:aDialogs[1] PIXEL

//@ 138,075 bitmap size 7,7 file 'NOCHECKED_CHILD_15' NOBORDER	of oFolder:aDialogs[1] PIXEL
@ 138+20,075 bitmap size 15,12 file 'NOCHECKED_CHILD_25' NOBORDER	of oFolder:aDialogs[1] PIXEL
@ 138+20,092 Say "Filiais s/ Estoque"  	of oFolder:aDialogs[1] PIXEL



//Pasta Planilha
@ 05,04  LISTBOX oListPlan FIELDS HEADER ' ','Filial','Planilha','Item','Qtd Transferida','Qtd Excedente','Qtd Disponivel','Disponivel Vitoria','Compra', 'Cod. PE','Cliente/Loja' SIZE X_TLIST,Y_TLIST PIXEL OF oFolder:aDialogs[2];
ON DBLCLICK( nAt := oListPlan:nAt, FValPla(),If(nQtdRest==0,(lFecha:=.T.,oDlg01:End()),'')) NOSCROLL

@ 140+13,318 Say "Qtd Consultada" 	of oFolder:aDialogs[2] PIXEL
@ 150+13,318 Say "Qtd Ofertada"   	of oFolder:aDialogs[2] PIXEL
@ 160+13,318 Say "Saldo Restante" 	of oFolder:aDialogs[2] PIXEL

@ 138+13,361 MsGet oPQtdCon	VAR	AllTrim(Str(nQtdCon))		WHEN .F. FONT oBold					Size 025,005 of oFolder:aDialogs[2] PIXEL READONLY
@ 148+13,361 MSGet oPQtdOfer	VAR	AllTrim(Str(nQtdOfer))		WHEN .F. FONT oBold					Size 025,005 of oFolder:aDialogs[2] PIXEL READONLY
@ 158+13,361 MSGet oPQtdRest	VAR	Alltrim(Str(nQtdRest))  	WHEN .F. FONT oBold	Color CLR_BLUE  Size 025,005 of oFolder:aDialogs[2] PIXEL READONLY


@ 138+20,005 bitmap size 15,12 file 'CARGA_OCEAN' NOBORDER 	of oFolder:aDialogs[2] PIXEL
@ 138+20,019 Say "Planilha em Transito"  		of oFolder:aDialogs[2] PIXEL

@ 138+20,75 bitmap size 15,30 file 'ARMAZEM_MDI' NOBORDER 	of oFolder:aDialogs[2] PIXEL
@ 138+20,92 Say "Planilha no Armazem"  		of oFolder:aDialogs[2] PIXEL


If lnB2b
	Atu_Tela()
Endif

If lPlanilha
	oFolder:nOption := 2
EndIf

Activate MsDialog oDlg01 Centered Valid lFecha

Return()
*********************************************************************
Static Function FValEst()// Quando duplo click na Tela Estoque
*********************************************************************
Local nPos := 0
//Local aRet := U_Men("Estoques","Aten็ใo","Deseja selecionar esta casa ? ",{"Sim","Nใo"})
Local aRet := U_Men("Estoques","Aten็ใo","Deseja selecionar esta casa ? ",{"Nao","Sim"})

If aRet[1] == 1

	If aListBox[nAt][COD_FIL] == cFilAnt	//| Casa Local
		If aListBox[nAt][EST_DISPO] > 0		//| Estoque Filial
			If nQuant <= aListBox[nAt][EST_DISPO]

				nQtdOfer					+=  nQuant				//|Quantidadfe Ofertada
				nQtdRest    				:= 	nQtdCon - nQtdOfer	//|
				aListBox[nAt][EST_TRANS]	-=  nQuant				//|Disponival em Estoque Local

				FSelect("L")//| Seleciona Casa Local ou Transferencia

			ElseIf nQuant > aListBox[nAt][EST_DISPO]

				nQuant 						:= aListBox[nAt][EST_DISPO]
				nQtdOfer					+= aListBox[nAt][EST_DISPO]
				nQtdRest    				:= nQtdCon - nQtdOfer
				aListBox[nAt][EST_DISPO] 	-= aListBox[nAt][EST_DISPO]

				FSelect("L")//| Seleciona Casa Local ou Transferencia

				nQuant	   					:=  nQtdRest				//|Quantidade Principal

			EndIf
		Else
			MsgInfo(OemToAnsi('Este item nao possui um saldo disponivel na Casa [Local]!'))
		Endif

	Else // Outras Filial

		nPos := aScan(aEstFil,{|x| x[1] == cFilAnt})

		If aListBox[nPos][EST_DISPO] == 0 //| Veririfica se o saldo local ja foi Utilizado

			If aListBox[nAt][EST_TRANS] > 0 //| Verifica se Tem Saldo a Transferir em Outra Filial Selecionada

				If nQuant <= aListBox[nAt][EST_TRANS]

					nQtdOfer					+=  nQuant				//|Quantidadfe Ofertada
					nQtdRest    				:= 	nQtdCon - nQtdOfer	//|
					aListBox[nAt][EST_TRANS]	-=  nQuant				//|Disponival em Estoque Local

					FSelect("T")//| Seleciona Casa Local ou Transferencia

				ElseIf nQuant > aListBox[nAt][EST_TRANS]

					nQuant 						:= aListBox[nAt][EST_TRANS]
					nQtdOfer   					+= aListBox[nAt][EST_TRANS]
					nQtdRest    				:= nQtdCon - nQtdOfer
					aListBox[nAt][EST_TRANS] 	-= aListBox[nAt][EST_TRANS]

					FSelect("T")//| Seleciona Casa Local ou Transferencia

					nQuant						:=  nQtdRest				//|Quantidade Principal

				EndIf
			Else
				MsgInfo(OemToAnsi("Esta Casa nao possui estoque de transferencia!"))
			EndIf

		Else

			MsgInfo(OemToAnsi('Este item possui um saldo disponivel na Casa [Local] que deve ser utilizado antes!'))

		Endif

	Endif

Endif

If lnB2b
	Atu_Tela()
Endif

Return()
*********************************************************************
Static Function FValPla()// Quando duplo click na Tela Planilhas
*********************************************************************
Local nPos 	:= 0
Local aRet	:= {}

//If Aviso("Aten็ใo","Deseja selecionar esta Planilha ? ",{"Sim","Nใo"}) == 1

	//| Consiste para nao Aceitar Zero
	aRet := U_Men("Planilhas","Aten็ใo","Informe a Quantidade:",{"OK"},nQuant,.T.)

	While aRet[2] == 0
		Alert("Informe Uma Quantidade ! ")
		aRet := U_Men("Planilhas","Aten็ใo","Informe a Quantidade:",{"OK"},nQuant,.T.)
	EndDo

	nQuant := aRet[2] //| Quantidade Selecionada no Get da Funcao Men

	If nQuant > nQtdCon //|Se Quantidade Aumentar no Momento da Selecao da Planilha Tem que Atualizar o Consultado
		Processa( {|| nSeqId := SUB->(U_Write_OrcOfert(N,cFilAnt,M->UA_NUM,gdFieldGet("UB_PRODUTO",n),nQuant,gdFieldGet("UB_VRCACRE",n),gdFieldGet("UB_SEQID",n),GdFieldGet("UB_DTNECLI",n),GdFieldGet("UB_HRNECLI",n))) }, 'Aguarde ', 'Gerando Consultado X Ofertado' )
		nQtdCon := nQuant
	EndIf

	If nSldPlan > 0

		If aListPlan[nAt][POS_PLAN_QTDDISP] > 0

			If nQuant <= aListPlan[nAt][POS_PLAN_QTDDISP]

				nQtdOfer							+= nQuant					//|Quantidadfe Ofertada
				nQtdRest    						:= nQtdCon - nQtdOfer
				aListPlan[nAt][POS_PLAN_QTDDISP] 	-= nQuant				//|Disponival em Estoque Local
				nSldPlan							-= nQuant

				FSelect("P")//| Seleciona Casa Local ou Transferencia

				nQuant	   							:=  nQtdRest				//|Quantidade Principal

			ElseIf nQuant > aListPlan[nAt][POS_PLAN_QTDDISP]

				nQuant 								:= aListPlan[nAt][POS_PLAN_QTDDISP]
				nQtdOfer							+= aListPlan[nAt][POS_PLAN_QTDDISP]
				nQtdRest    						:= nQtdCon - nQtdOfer
				aListPlan[nAt][POS_PLAN_QTDDISP] 	-= aListPlan[nAt][POS_PLAN_QTDDISP]
				nSldPlan							-= aListPlan[nAt][POS_PLAN_QTDDISP]

				FSelect("P")//| Seleciona Casa Local ou Transferencia

				nQuant	   							:=  nQtdRest				//|Quantidade Principal

			EndIf

		Else
			MsgInfo(OemToAnsi('Este Planilha nใo tem saldo Disponivel. Selecione Outra Planilha !'))
		Endif

	Else
		MsgInfo(OemToAnsi('Este item nao possui um saldo disponivel em planilha!'))
	Endif

//Endif

If lnB2b
	Atu_Tela()
Endif

Return()
*********************************************************************
Static Function FverRest() //| Lanca a quantidade restante no SUB com ha linha deletada quando sair da Tela de Estoques / Planilhas....
*********************************************************************

Local dDataVazia := cToD("  / /  ")

//| Caso nao tenha sido selecionado nenhuma casa
If nQtdRest > 0 .and. lFirst

	FCarQtd(n, nQuant)		//| Joga nQuant no SUB

	//Roda gatilhos mesmo com a linha deletada -  Edivaldo Goncalves Cordeiro em 04/08/2010
	FCarQtd(n, nQuant)	//| Joga nQuant no SUB

	// Jorge Oliveira - 11/02/2011 - Chamado AAZTKF - So tem data de previsao de entrega se tiver saldo
	GDFieldPut( "UB_DTENTRE", dDataVazia, N )
	aCols[ N, GDFieldPos( "UB_DTENTRE" ) ] := dDataVazia
	M->UB_DTENTRE := dDataVazia

	Eval(bDel)    			//| Deleta a Linha

ElseIf nQtdRest > 0

	FCriaLinha(cProduto)	//| Cria Linha e Joga Produto no SUB
	FCarQtd(n, nQtdRest)	//| Joga nQuant no SUB

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
/*
oListBox:SetArray(aListBox)
oListBox:bLine := { ||{		IIf(aListBox[oListBox:nAt,COD_FIL] == cFilAnt , oAzul , IIf(aListBox[oListBox:nAt,EST_TRANS] == 0 , oCinza  ,oVerde)),;
aListBox[oListBox:nAt,COD_FIL] 		,;
aListBox[oListBox:nAt,NOM_FIL] 		,;
aListBox[oListBox:nAt,EST_ATUAL] 	,;
aListBox[oListBox:nAt,EST_DISPO] 	,;
aListBox[oListBox:nAt,EST_TRANS] 	,;
aListBox[oListBox:nAt,EST_QACLA] } }
*/


oListBox:SetArray(aListBox)
//oListBox:bLine := { ||{		IIf(aListBox[oListBox:nAt,COD_FIL] == cFilAnt , oFilLocEstOk , IIf(aListBox[oListBox:nAt,EST_TRANS] == 0 , oEstNoYes ,oEstYes)),;
//oListBox:bLine := { ||{		IIf(aListBox[oListBox:nAt,COD_FIL] == cFilAnt , IIf(aListBox[oListBox:nAt,EST_DISPO] == 0 , oEstLocNoYes ,oEstLocYes) , IIf(aListBox[oListBox:nAt,EST_TRANS] == 0 , oEstNoYes ,oEstYes)),;
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

//EXEM oListBox:bLine := { ||{		IIf(aListBox[oListBox:nAt,COD_FIL] == cFilAnt , oAzul , IIf(aListBox[oListBox:nAt,EST_TRANS] == 0 , oCinza  ,oVerde)),;
oListPlan:SetArray(aListPlan)
//OK oListPlan:bLine:={|| {	aListPlan[ oListPlan:nAt, POS_PLAN_DESTINO ],;
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
	EndCase

	FCarQtd(N, nQuant) //| Joga nQuant no SUB

Else //| Demais Selecoes

	FCriaLinha(cProduto)//| Cria Linha e Joga Produto no SUB

	Do Case
		Case cPar == "T"
			GrvFilTran()	//|Grava Dados Da Filial de transferencia
		Case cPar == "P"
			GrvPlan()		//|Grava dados da planilha Tratamento Planilha
		Case cPar == "L"
	EndCase

	FCarQtd(n,nQuant) //| Joga nQuant no SUB

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
Static Function FCriaLinha(cProd)//| Cria Linha e Joga Produto no SUB
*********************************************************************

If FAddLinha()

	__ReadVar 			:= "M->UB_PRODUTO"
	M->UB_PRODUTO       := cProd
	lOk := CheckSX3('UB_PRODUTO',M->UB_PRODUTO)
	RunTrigger(2,n,"",,PADR('UB_PRODUTO',10))

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
