
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³U_MSD2460 ³ Autor ³ Expedito Mendonca Jr. ³ Data ³ 12/12/2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o arquivo SA7 com o ultimo preco de venda com       ³±±
±±³          ³ acrescimo financeiro praticado por produtoXcliente.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ESPECIFICO PARA O CLIENTE IMDEPA						        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

************************************************************************
User Function MSD2460()
************************************************************************
Local cSuf, nI
Local aArea,aAreaSC5
Local lLock := .F.

Local  cEstOri		:= GETMV("MV_ESTADO")
Private cImdepa  	:= GetMV('MV_IMDEPA') // Cliente Tranferência

//| Cristiano Machado - 12/03/2008 - Chamado: AAZNRB [Adriana - Fiscal]
//³ Grava no Item da nota o Custo Medio no Momento da Geracao da NF de Saida

//| Cristiano Machado - 12/03/2008 - Chamado: AAZNRB [Adriana - Fiscal]
// VERIFICA SE A FILIAL TRATA SUBSTITUICAO TRIBBUTARIA

//| Márcio Q.Borges   - 29/04/2008 - Chamado: AAZO28 [Adriana - Fiscal]
// VERIFICA SE A FILIAL TRATA SUBSTITUICAO TRIBBUTARIA
IF U_F_Sim_SUBTRIB('IMP',cEstOri,substr(SA1->A1_GRPSEG,3,1)) .OR. SD2->D2_CLIENTE $ Getmv("MV_CLIMENF") .OR. SD2->D2_CLIENTE = cImdepa//CHAMADO:AAZP17 DATA:26/09/08 ANALISTA:CRISTIANO
//	IF u_FSubTrib(cFilAnt,"S",SC5->C5_TIPO,SA1->A1_TIPO,SA1->A1_EST,SB1->B1_POSIPI,substr(SA1->A1_GRPSEG,3,1),3) // VERIFICA SE E PRODUTO COM SUBSTITUICAO TRIBUTARIA
		//		IF AllTrim(SD2->D2_CF)  $ "5405/5106" /// TES ESPECIFICA //		IF AllTrim(SD2->D2_CF)  == "5405" /// TES ESPECIFICA
		SD2->( RecLock('SD2',.F.))
		SD2->D2_CUSIND := U_FCusTrib(.F.) //SB2->B2_CM1   //
		SD2->D2_CM1    := SB2->B2_CM1
		SD2->( MsUnlock() )
		//		ENDIF
//	ENDIF
ENDIF

// incluido por Luciano Correa em 07/06/04...
// grava dt/hr preparacao docto, jah estah posicionado no pedido...
If SC9->C9_FILIAL+SC9->C9_NFISCAL+SC9->C9_SERIENF+SC9->C9_PEDIDO+SC9->C9_ITEM = ;
	SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_PEDIDO+SD2->D2_ITEMPV
	SC9->( RecLock( 'SC9', .f. ) )
	SC9->C9_DTDOCS  := Date()
	SC9->C9_HRDOCS  := Time()
	SC9->C9_USRDOCS := SubStr( cUsuario, 7, 15 )
	SC9->( MsUnlock() )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizacao da classe de valor (brindes em campanhas de vendas)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM == xFilial('SC6')+SD2->D2_PEDIDO+SD2->D2_ITEMPV .and. SD2->(!Eof())
	SD2->D2_CLVL    := SC6->C6_CLVL
Else
	Alert("Arquivo de itens de pedidos de venda nao estava posicionado, não será registrada a saída deste brinde para esta campanha, entre em contato com o Depto. de Tecnologia Imdepa!")
Endif

aArea := GetArea()
aAreaSC5 := SC5->(Getarea())

Pergunte("MT460A",.F.) // Alterado Para o P12 ...

lAtuaSa7 := .F.
If mv_par15 == 1  .OR. mv_par15 ==2 // X1_GRUPO: "MT460A"    
	dbSelectArea("SA7")
	If !(dbSeek(xFilial("SA7")+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_COD))
		lAtuaSa7 := .T.
		Reclock("SA7",.T.)
		Replace A7_FILIAL With xFilial("SA7")
		Replace A7_PRODUTO With SD2->D2_COD
		Replace A7_CLIENTE With SD2->D2_CLIENTE
		Replace A7_LOJA    With SD2->D2_LOJA
		Replace A7_PRECO01 With SD2->D2_PRUNIT
		Replace A7_PRACR01 With SD2->D2_PRCVEN
		Replace A7_DTREF01 With SD2->D2_EMISSAO
		Replace A7_CPAG01  With Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_CONDPAG")
		MsUnlock()
	Else
		
		Reclock("SA7")
		FOR jk:=12 TO  2 step -1
			nProx:=jk-1
			cSuf := StrZero(jk,2)
			cProx:= StrZero(nProx,2)
			Replace A7_PRECO&cSuf With A7_PRECO&cProx
			Replace A7_DTREF&cSuf With A7_DTREF&cProx
			Replace A7_PRACR&cSuf With A7_PRACR&cProx//  SD2->D2_PRCVEN
			Replace A7_CPAG&cSuf  With A7_CPAG&cProx   //Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_CONDPAG")
		Next jk
		
		Replace A7_PRECO01  With SD2->D2_PRUNIT
		Replace A7_DTREF01  With SD2->D2_EMISSAO
		Replace A7_PRACR01  With SD2->D2_PRCVEN
		Replace A7_CPAG01   With Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_CONDPAG")
		MsUnlock()
	Endif
	
	RestArea(aAreaSC5)
	RestArea(aArea)
	
Endif

Return NIL
