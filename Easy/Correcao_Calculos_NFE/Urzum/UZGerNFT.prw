#INCLUDE "Rwmake.ch"
#include "Average.ch"
#INCLUDE "TopConn.ch"

#DEFINE  NFE_UNICA     3
#define  NF_TRANS      6

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa Rolamentos
//|Funcao....: UZGerNFT
//|Data......: 03 de Fevereiro de 2010 - 08:00
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 10
//|Descricao.: Gera NF de Transferencia
//|Observação:
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
User Function UZGerNFT()
*----------------------------------------------*

Local nRadio  := 1
Local lRet    := .F.
Local cMsgInf := ""

Private oLbxIT  := Nil
Private bLineIT := Nil
Private aVetIT  := {}
Private aDescIT := {}
Private aAlt    := Array(7)
Private cNovaNF := Space(9)
Private cNovaSe := Space(3)
Private dNovaDt := CtoD(Space(8))
Private nBasIPI := 0
Private nTotIpi := 0
Private nBasPCO := 0
Private nTotPis := 0
Private nTotCOF := 0
Private nBasICM := 0
Private nTotICMS:= 0
Private nTotSimp:= 0
Private nTotCimp:= 0
Private nTotDesp:= 0
Private nDifIpi := 0
Private nxIpi_Eic := 0
Private lImpDentro := .F.

cMsgInf := "Para Geração de NF de Transferencia é necessário que o processo seja do Tipo 'Conta e Ordem' ou 'Encomenda'. "
cMsgInf += "É necessário também que seja gerada Nf Unica"

If !SW6->W6_TIPOEMB $ "23"
	MsgInfo(cMsgInf,"NF Transferencia")
	Return .F.
ElseIf Empty(SW6->W6_NF_ENT)
	MsgStop("Processo Não Possue Nota de Entrada","Sem NF")
	Return .F.
EndIf

Begin Sequence

lRet := UZTelaGet(@nRadio)

If !lRet
	Break
Endif

End Sequence

If !lRet
	Return .T.
Endif

If nRadio == 1  //Inclusao
	If Empty(SW6->W6_NF_ENT)
		MsgStop("Processo Não Possue Nota de Entrada","Sem NF")
		Return .F.
	Endif
	
	If !Empty(SW6->W6_NFTRAN)
		MsgStop("Nota Fiscal de Transferencia já gerada","NF Tranferencia")
		Return .F.
	Endif
	
	If SW6->W6_TIPOEMB $ "23"
		Processa({|| UZGrvNFT(nRadio) },"Processando Itens...")
	Endif
	
ElseIf nRadio == 3  //Visualização
	
	If SW6->W6_TIPOEMB $ "23"
		Processa({|| UZGrvNFT(nRadio) },"Processando Itens...")
	Endif
	
ElseIf nRadio == 2 // Estorno
	
	If Empty(SW6->W6_NFTRAN)
		MsgStop("Processo nao possui Nota Fiscal de Transferencia Gerada")
		Return .F.
	Else
		Processa({|| UZGrvNFT(nRadio) },"Processando Itens...")
	Endif
	
Endif

Return .T.

//+-----------------------------------------------------------------------------------//
//|Funcao....: UZTelaGet
//|Uso.......: SIGAEIC
//|Descricao.: Mostra Tela com Opções de NF de Transferencia
//|Observação:
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function UZTelaGet(nRadio)
*----------------------------------------------*

Local lRet := .F.
Local oDlg := Nil

DEFINE MSDIALOG oDlg TITLE "Nota Fiscal Transferência" FROM 1,1 TO 90,350 OF oMAINWND PIXEL

@15,30 RADIO oRADIO VAR nRADIO ITEMS "Inclusão","Estorno","Visualização" SIZE 70,10 OF oDlg PIXEL

ACTIVATE MSDIALOG oDLG CENTERED ON INIT ENCHOICEBAR(oDlg,{||lRet := .T.,oDlg:END()},{||oDlg:END()})

Return(lRET)
    
//+-----------------------------------------------------------------------------------//
//|Funcao....: UZGrvNFT
//|Descricao.: Grava NF de Transferencia
//|Observação:
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function UZGrvNFT(nEscolha)
*----------------------------------------------*

Local nValMerc := 0
Local nValTot  := 0
Local nValNF   := 0
Local cPosicao := ""
Local cTipoNFs := ""
Local _wnIpi_Eic := 0
Local _wnIpi_SD1 := 0

SC7->(dbSetOrder(1))
SF1->(dbSetOrder(1))

If Empty(SW6->W6_FORNEX)
	MsgInfo("Não há Fornecedor para Transferencia","Sem Fornecedor")
	Return .T.
EndIf

SWN->(dbSetOrder(3))
If SWN->(dbSeek(xFilial("SWN")+SW6->W6_HAWB+"3"))
	cTipoNFs := Iif(SWN->WN_TIPO_NF == "2","3",SWN->WN_TIPO_NF)
EndIf

If cTipoNFs == "3"
	If SWN->(dbSeek(xFilial("SWN")+SW6->W6_HAWB+cTipoNFs))
		
		If nEscolha == 3
			Processa({|| UZVisNFT() },"Processando Visualização...")
			Return .T.
		ElseIf nEscolha == 2
			Processa({|| UZEstNFT() },"Processando Estorno...")
			Return .T.
		Else
			If UzValIncNFT()
				UZIncNFT()
				TelaNFT()
				Return .T.
			Else
				Return .T.
			EndIf
		EndIf
	EndIf
EndIf	
				
Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: UzValIncNFT()
//|Descricao.: Valida a Inclusão da NF de Transferencia
//|Observação:
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function UzValIncNFT()
*----------------------------------------------*

Local lRetur := .F.

cSql := " SELECT COUNT(*) AS QTDE FROM "+RetSqlName("SF1") 
cSql += " WHERE D_E_L_E_T_ <> '*' AND F1_FILIAL = '"+xFilial("SF1")+"' AND "
cSql += " 	F1_HAWB = '"+SW6->W6_HAWB+"' AND F1_TIPO = 'N' AND F1_STATUS <> ' ' "
Iif(Select("XXXX") # 0,XXXX->(dbCloseArea()),.T.)
TcQuery cSql New Alias "XXXX"
XXXX->(dbSelectArea("XXXX"))
XXXX->(dbGoTop())

Iif(XXXX->QTDE > 0,MsgInfo("NF já classifica não pode ser convertida para Transferencia","NF Classificada"),lRetur := .T.)

XXXX->(dbCloseArea())

Return(lRetur)

//+-----------------------------------------------------------------------------------//
//|Funcao....: UZIncNFT()
//|Descricao.: Gera dados para mostrar na Tela
//|Observação:
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function UZIncNFT()
*----------------------------------------------*

Local cSql := ""

lImpDentro := MsgYesNo("Calcula IPI e ICMS por dentro?")

//PRODUTOS
If lImpDentro
	cSql := " SELECT (WN.WN_CIF+WN.WN_IIVAL+WN.WN_VLRPIS+WN.WN_VLRCOF+WN.WN_VALICM) AS VALMERC, " 
Else
	cSql := " SELECT (((WN.WN_VALIPI+WN.WN_VLRPIS+WN.WN_VLRCOF+WN.WN_DESPICM)/WN.WN_QUANT)+WN.WN_PRUNI) AS VALMERC, "
EndIf
cSql += " 		WN.WN_DESCR, WN.WN_TEC, WN.WN_EX_NCM, WN.WN_ICMS_A, WN.WN_QUANT, WN.WN_VALIPI, WN.WN_FOB_R, WN.R_E_C_N_O_ AS RECWN, "
cSql += " 		WN.WN_FRETE, WN.WN_SEGURO, WN.WN_CIF, WN.WN_IIVAL, WN.WN_IPIVAL, WN.WN_BASPIS, WN.WN_VLRPIS, WN.WN_VLRCOF, "
cSql += " 		WN.WN_DESPADU, WN.WN_DESPICM, WN.WN_DESPESA, "
cSql += " 		D1.D1_COD, D1.D1_ITEM, D1.D1_DOC, D1.D1_SERIE, D1.D1_FORNECE, D1.D1_LOJA, D1.D1_PEDIDO, D1.D1_ITEMPC, "
cSql += " 		D1.R_E_C_N_O_ AS RECD1,  "
cSql += " 		C7.R_E_C_N_O_ AS RECC7  "
cSql += " FROM "+RetSqlName("SD1")+" D1 "
cSql += " JOIN "+RetSqlName("SF1")+" F1 ON F1.F1_HAWB = '"+SW6->W6_HAWB+"' AND F1.F1_TIPO = 'N' "
cSql += " 		AND F1.F1_DOC = D1.D1_DOC AND F1.F1_SERIE = D1.D1_SERIE "
cSql += "	    AND F1.D_E_L_E_T_ <> '*' AND F1.F1_FILIAL = '"+xFilial("SF1")+"' "
cSql += " JOIN "+RetSqlName("SWN")+" WN ON WN.WN_HAWB = '"+SW6->W6_HAWB+"' AND WN.WN_TIPO_NF = '3' "
cSql += "	    AND WN.WN_DOC = D1.D1_DOC AND WN.WN_SERIE = D1.D1_SERIE AND WN.WN_FORNECE = D1.D1_FORNECE "
cSql += "	    AND WN.WN_LOJA = D1.D1_LOJA AND WN.WN_PO_NUM = D1.D1_PEDIDO "//AND WN.WN_ITEM = D1.D1_ITEMPC "
cSql += "	    AND WN.WN_QUANT = D1.D1_QUANT 
//cSql += "	    AND SUBSTRING(CAST(WN.WN_LINHA+10000 AS VARCHAR(5)),2,4) = D1.D1_ITEM "
cSql += "	    AND LPAD(WN.WN_LINHA,4,'0') = D1.D1_ITEM " 
cSql += "	    AND WN.D_E_L_E_T_ <> '*' AND WN.WN_FILIAL = '"+xFilial("SWN")+"' "
//cSql += " JOIN "+RetSqlName("SWN")+" WN ON WN.WN_HAWB = '"+SW6->W6_HAWB+"' AND WN.WN_TIPO_NF = '3' "
//cSql += "	    AND WN.WN_DOC = D1.D1_DOC AND WN.WN_SERIE = D1.D1_SERIE AND WN.WN_FORNECE = D1.D1_FORNECE "
//cSql += "	    AND WN.WN_LOJA = D1.D1_LOJA AND WN.WN_PO_NUM = D1.D1_PEDIDO AND WN.WN_ITEM = D1.D1_ITEMPC "
//cSql += "	    AND WN.D_E_L_E_T_ <> '*' AND WN.WN_FILIAL = '"+xFilial("SWN")+"' "
cSql += " JOIN "+RetSqlName("SC7")+" C7 ON C7.C7_NUM = D1.D1_PEDIDO AND C7.C7_ITEM = D1.D1_ITEMPC AND C7.C7_PRODUTO = D1.D1_COD "
cSql += "	    AND C7.D_E_L_E_T_ <> '*' AND C7.C7_FILIAL = '"+xFilial("SC7")+"' "
cSql += " WHERE D1.D_E_L_E_T_ <> '*' AND D1.D1_FILIAL = '"+xFilial("SD1")+"' " 
cSql += " ORDER BY D1.D1_DOC, D1.D1_SERIE, D1.D1_ITEM "
Iif(Select("XXXX") # 0,XXXX->(dbCloseArea()),.T.)
TcQuery cSql New Alias "XXXX"
XXXX->(dbSelectArea("XXXX"))
XXXX->(dbGoTop())

//VALOR TOTAL EM REAIS PARA RATEIO DAS DESPESAS
cSql := " SELECT SUM(WN_FOB_R) AS FOBTOT FROM "+RetSqlName("SWN")
cSql += " WHERE D_E_L_E_T_ <> '*' AND WN_FILIAL = '"+xFilial("SWN")+"' " 
cSql += " 		AND WN_HAWB = '"+SW6->W6_HAWB+"' AND WN_TIPO_NF = '3' "
Iif(Select("XXWN") # 0,XXWN->(dbCloseArea()),.T.)
TcQuery cSql New Alias "XXWN"
XXWN->(dbSelectArea("XXWN"))
XXWN->(dbGoTop())

//TOTAL DE DESPESAS
cSql := " SELECT SUM(WD.WD_VALOR_R) AS DESTOT FROM "+RetSqlName("SWD")+" WD, "+RetSqlName("SYB")+" YB" 
cSql += " WHERE WD.D_E_L_E_T_ <> '*' AND WD.WD_FILIAL = '"+xFilial("SWD")+"' " 
cSql += " 		AND YB.D_E_L_E_T_ <> '*' AND YB.YB_FILIAL = '"+xFilial("SYB")+"' "
cSql += " 		AND WD.WD_HAWB = '"+SW6->W6_HAWB+"' "
cSql += " 		AND WD.WD_DESPESA = YB.YB_DESP AND YB.YB_XDPNFT = 'S' "
Iif(Select("XXDE") # 0,XXDE->(dbCloseArea()),.T.)
TcQuery cSql New Alias "XXDE"
XXDE->(dbSelectArea("XXDE"))
XXDE->(dbGoTop())

nxIpi_Eic := 0
nItss     := 1
nTotDesp  := XXDE->DESTOT

If XXXX->(EOF()) .AND. XXXX->(BOF())
	MsgInfo("Não há itens para geração da NF de transferencia","Sem Itens")
	XXXX->(dbCloseArea())
	XXWN->(dbCloseArea())
	XXDE->(dbCloseArea())
	Return
Endif

XXXX->(dbGoTop())
While XXXX->(!EOF())

	cDescr   := Alltrim(XXXX->WN_DESCR)
	nPerIPI  := Posicione("SYD",1,xFilial("SYD")+XXXX->WN_TEC+XXXX->WN_EX_NCM,"YD_PER_IPI")
	nPerICM  := Posicione("SYD",1,xFilial("SYD")+XXXX->WN_TEC+XXXX->WN_EX_NCM,"YD_ICMS_RE")

	If lImpDentro
		nxIpi_Eic += XXXX->WN_VALIPI
		nValDesp := Round((XXDE->DESTOT/XXWN->FOBTOT)*XXXX->WN_FOB_R,2)
		nValTot  := Round(((XXXX->VALMERC+nValDesp)/(1-(XXXX->WN_ICMS_A/100))),4)
		//nPerIPI  := Posicione("SYD",1,xFilial("SYD")+XXXX->WN_TEC+XXXX->WN_EX_NCM,"YD_PER_IPI")
		nValIPI  := Round((nValTot*nPerIPI)/100,2)
		nValICM  := Round((nValTot*XXXX->WN_ICMS_A)/100,2)
	Else		
		nValDesp := Round((XXDE->DESTOT/XXWN->FOBTOT)*XXXX->WN_FOB_R,2)
		nValTot  := Round((XXXX->VALMERC*XXXX->WN_QUANT)+nValDesp,4)
		nValIPI  := Round((nValTot*nPerIPI)/100,2)
		nValICM  := Round((nValTot*nPerICM)/100,2)
	EndIf
	aAdd(aVetIT,{XXXX->D1_COD,; //1
				cDescr,;        //2
				XXXX->WN_QUANT,;//3
				Round(nValTot/XXXX->WN_QUANT,6),;//4
				nValTot,;//5
				nPerIPI,;//6
				nValTot,;//7
				nValIPI,;//8
				XXXX->WN_BASPIS,;//9
				XXXX->WN_VLRPIS,;//10
				XXXX->WN_VLRCOF,;//11
				nPerICM,;//12
				nValTot,;//13
				nValICM,;//14
				XXXX->WN_FOB_R,;//15
				XXXX->WN_FRETE,;//16
				XXXX->WN_SEGURO,;//17
				XXXX->WN_CIF,;//18
				XXXX->WN_IIVAL,;//19
				XXXX->WN_IPIVAL,;//20
				XXXX->WN_BASPIS,;//21
				XXXX->WN_VLRPIS,;//22
				XXXX->WN_VLRCOF,;//23
				XXXX->WN_DESPADU,;//24
				XXXX->WN_DESPICM,;//25
				XXXX->WN_DESPESA,;//26
				nValDesp,;//27
				StrZero(nItss,4),;//28
				XXXX->RECD1,;//29
				XXXX->RECWN,;//30
				XXXX->RECC7})//31
				
	nItss++

	nBasIPI += nValTot
	nTotIpi += nValIPI
	nBasPCO += XXXX->WN_BASPIS
	nTotPis += XXXX->WN_VLRPIS
	nTotCOF += XXXX->WN_VLRCOF
	nBasICM += nValTot
	nTotICMS+= nValICM
	nTotSimp+= nValTot
	
	XXXX->(dbSkip())
EndDo

nTotCimp := nTotIpi+nTotSimp
nDifIpi  := nTotIpi-nxIpi_Eic

aDescIT := {"Produto","Descrição","Quantidade","Vlr Unit","Vlr Total","% IPI","Bc IPI","Vlr IPI",;
			"Bc PIS/COFINS","Vlr PIS","Vlr COFINS","% ICMS","Bc ICMS","Vlr ICMS",;
			"Fob Import","Frete Import","Seguro Import","CIF Import","I.I. Import","IPI Import","Base PIS/COFINS Import",;
			"PIS Import","COFINS Import","Desp Adua Import","Desp ICMS Import","Despesa NF Transferencia"}

cLineIT := "{aVetIT[oLbxIT:nAt,1],aVetIT[oLbxIT:nAt,2],aVetIT[oLbxIT:nAt,3],aVetIT[oLbxIT:nAt,4],aVetIT[oLbxIT:nAt,5],"
cLineIT += "aVetIT[oLbxIT:nAt,6],aVetIT[oLbxIT:nAt,7],aVetIT[oLbxIT:nAt,8],aVetIT[oLbxIT:nAt,9],aVetIT[oLbxIT:nAt,10],"
cLineIT += "aVetIT[oLbxIT:nAt,11],aVetIT[oLbxIT:nAt,12],aVetIT[oLbxIT:nAt,13],aVetIT[oLbxIT:nAt,14],aVetIT[oLbxIT:nAt,15],"
cLineIT += "aVetIT[oLbxIT:nAt,16],aVetIT[oLbxIT:nAt,17],aVetIT[oLbxIT:nAt,18],aVetIT[oLbxIT:nAt,19],aVetIT[oLbxIT:nAt,20],"
cLineIT += "aVetIT[oLbxIT:nAt,21],aVetIT[oLbxIT:nAt,22],aVetIT[oLbxIT:nAt,23],aVetIT[oLbxIT:nAt,24],aVetIT[oLbxIT:nAt,25],"
cLineIT += "aVetIT[oLbxIT:nAt,26],aVetIT[oLbxIT:nAt,27]}"
bLineIT := &("{ || "+cLineIT+" }")

XXXX->(dbCloseArea())
XXWN->(dbCloseArea())
XXDE->(dbCloseArea())

Return	   

//+-----------------------------------------------------------------------------------//
//|Funcao....: TelaNFT()
//|Descricao.: Mostra Tela com Itens antes da geração
//|Observação:
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function TelaNFT()
*----------------------------------------------*

Local cTitulo  := ".:: Nota de Transferência ::. Itens do Processo: "+Alltrim(SW6->W6_HAWB)
Local oDlgParc := Nil
Local oLBox1   := Nil
Local oLBox2   := Nil                       
Local bOk      := {||nOpcao:=1 , Processa({ || lRet := Grava() }), Iif(lRet,oDlgParc:End(),.T.) }
Local bCancel  := {||nOpcao:=0 , Iif(MsgYesNo("Deseja realmente Sair?","Sair"),oDlgParc:End(),.T.) }
Local bButtons := {}
Local aPosTel  := {}
Local nLin1    := 15
Local nLin2    := 400
Local nCol1    := 05
Local nCol2    := 110
Local lRet     := .F.

aAdd(bButtons,{"EDIT"    ,{|| UZAltIt(oLbxIT:nAt) }, "Altera Item"})

Define MsDialog oDlgParc Title cTitulo FROM 1,1 To 305,900 STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd Pixel
 
aPosTel := PosDlg(oDlgParc)

nLin1 := 15
nCol1 := 5
nLin2 := aPosTel[3]-3
nCol2 := aPosTel[4]-220

oLBox1:= TGroup():New( nLin1,nCol1,nLin2,nCol2,"Itens para Transferencia",oDlgParc,CLR_BLACK,CLR_WHITE,.T.,.F. )

oLbxIT:= TWBrowse():New( nLin1+=8,nCol1+=5,(nCol2-nCol1)-5,(nLin2-nLin1)-5,,aDescIT,,oDlgParc,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbxIT:SetArray(aVetIT)
oLbxIT:bLDblClick := { || UZAltIt(oLbxIT:nAt) }
oLbxIT:bLine := bLineIT

nLin1 := 15
nCol1 := nCol2+5
nCol2 += 108

oLBox2:= TGroup():New( nLin1,nCol1,nLin2,nCol2,"Dados NF",oDlgParc,CLR_BLACK,CLR_WHITE,.T.,.F. )

@ nLin1+=9 ,nCol1+=5 SAY "No. NF"  SIZE 40,7 PIXEL OF oDlgParc
@ nLin1    ,nCol1+30 MSGET cNovaNF  PICTURE "@!" SIZE 60,7 PIXEL OF oDlgParc
@ nLin1+=12,nCol1    SAY "Serie"  SIZE 40,7 PIXEL OF oDlgParc
@ nLin1    ,nCol1+30 MSGET cNovaSe  PICTURE "@!" SIZE 60,7 PIXEL OF oDlgParc
@ nLin1+=12,nCol1    SAY "Data"  SIZE 40,7 PIXEL OF oDlgParc
@ nLin1    ,nCol1+30 MSGET dNovadt  PICTURE "@D" SIZE 60,7 PIXEL OF oDlgParc
@ nLin1+=12,nCol1    SAY "Total Merc."  SIZE 40,7 PIXEL OF oDlgParc
@ nLin1    ,nCol1+30 MSGET oTotSImp VAR nTotSImp  PICTURE "@E 999,999,999.99" WHEN .F. SIZE 60,7 PIXEL OF oDlgParc
@ nLin1+=12,nCol1    SAY "Total NF"  SIZE 40,7 PIXEL OF oDlgParc
@ nLin1    ,nCol1+30 MSGET oTotCImp VAR nTotCImp  PICTURE "@E 999,999,999.99" WHEN .F. SIZE 60,7 PIXEL OF oDlgParc

nLin1 := 15
nCol1 := nCol2+5
nCol2 := aPosTel[4]-3

oLBox3:= TGroup():New( nLin1,nCol1,nLin2,nCol2,"Impostos",oDlgParc,CLR_BLACK,CLR_WHITE,.T.,.F. )

@ nLin1+=9 ,nCol1+=5 SAY "Base IPI"  SIZE 40,7 PIXEL OF oDlgParc
@ nLin1    ,nCol1+30 MSGET oBasIPI VAR nBasIPI  PICTURE "@E 999,999,999.99" WHEN .F. SIZE 60,7 PIXEL OF oDlgParc
@ nLin1+=12,nCol1    SAY "Total IPI"  SIZE 40,7 PIXEL OF oDlgParc
@ nLin1    ,nCol1+30 MSGET oTotIpi VAR nTotIpi  PICTURE "@E 999,999,999.99" WHEN .F. SIZE 60,7 PIXEL OF oDlgParc
@ nLin1+=12,nCol1    SAY "Base P/Cof"  SIZE 40,7 PIXEL OF oDlgParc
@ nLin1    ,nCol1+30 MSGET oBasPCO VAR nBasPCO  PICTURE "@E 999,999,999.99" WHEN .F. SIZE 60,7 PIXEL OF oDlgParc
@ nLin1+=12,nCol1    SAY "Total PIS"  SIZE 40,7 PIXEL OF oDlgParc
@ nLin1    ,nCol1+30 MSGET oTotPis VAR nTotPis  PICTURE "@E 999,999,999.99" WHEN .F. SIZE 60,7 PIXEL OF oDlgParc
@ nLin1+=12,nCol1    SAY "Total COF"  SIZE 40,7 PIXEL OF oDlgParc
@ nLin1    ,nCol1+30 MSGET oTotCOF VAR nTotCOF  PICTURE "@E 999,999,999.99" WHEN .F. SIZE 60,7 PIXEL OF oDlgParc
@ nLin1+=12,nCol1    SAY "Base ICMS"  SIZE 40,7 PIXEL OF oDlgParc
@ nLin1    ,nCol1+30 MSGET oBasICM VAR nBasICM  PICTURE "@E 999,999,999.99" WHEN .F. SIZE 60,7 PIXEL OF oDlgParc
@ nLin1+=12,nCol1    SAY "Total ICMS"  SIZE 40,7 PIXEL OF oDlgParc
@ nLin1    ,nCol1+30 MSGET oTotICMS VAR nTotICMS  PICTURE "@E 999,999,999.99" WHEN .F. SIZE 60,7 PIXEL OF oDlgParc
@ nLin1+=12,nCol1    SAY "Total Desp"  SIZE 40,7 PIXEL OF oDlgParc
@ nLin1    ,nCol1+30 MSGET nTotDesp  PICTURE "@E 999,999,999.99" WHEN .F. SIZE 60,7 PIXEL OF oDlgParc
If lImpDentro
	@ nLin1+=12,nCol1    SAY "Dif IPI"  SIZE 40,7 PIXEL OF oDlgParc
	@ nLin1    ,nCol1+30 MSGET oDifIpi VAR nDifIpi  PICTURE "@E 999,999,999.99" SIZE 60,7 PIXEL OF oDlgParc
EndIf

Activate MsDialog oDlgParc ON INIT EnchoiceBar(oDlgParc,bOk,bCancel,,bButtons) Centered 

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: UZAltIt()
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Descricao.: Faz Alteração nos Itens
//|Observação: 
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function UZAltIt(xPos)
*----------------------------------------------*

Local oDlg    := Nil
Local oGrp    := Nil
Local nLi1    := 15
Local nCo1    := 5
Local nCo2    := 40
Local nOpcao  := 0
Local cTit    := "Alteração de Produto: "+Alltrim(aVetIT[xPos,1])

aAlt := Array(10)

aAlt[1] := aVetIT[xPos,3]
aAlt[2] := aVetIT[xPos,4]
aAlt[3] := aVetIT[xPos,5]
aAlt[4] := aVetIT[xPos,7]
aAlt[5] := aVetIT[xPos,8]
aAlt[6] := aVetIT[xPos,9]
aAlt[7] := aVetIT[xPos,10]
aAlt[8] := aVetIT[xPos,11]
aAlt[9] := aVetIT[xPos,13]
aAlt[10] := aVetIT[xPos,14]

While .T.
	
	nLi1   := 5
	nCo1   := 5
	nCo2   := 40
	
	DEFINE MSDIALOG oDlg TITLE cTit From 1,1 to 280,290 of oMainWnd PIXEL
	
	oGrp  := TGroup():New( nLi1,nCo1,138,110,"Dados",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )
	
	@ nLi1+=9 ,nCo1+=5 SAY "Quantidade"  SIZE 35,7 PIXEL OF oDlg
	@ nLi1    ,nCo1+35 MSGET aAlt[1] PICTURE "@E 99,999,999.9999" WHEN .F. SIZE 58,8 PIXEL OF oDlg
	@ nLi1+=12,nCo1 SAY "Vlr Unit" SIZE 35,7 PIXEL OF oDlg
	@ nLi1    ,nCo1+35 MSGET aAlt[2] VALID UzAltVal("UNI") PICTURE "@E 99,999,999.999999" SIZE 58,8 PIXEL OF oDlg
	@ nLi1+=12,nCo1 SAY "Vlr Tot" SIZE 35,7 PIXEL OF oDlg
	@ nLi1    ,nCo1+35 MSGET aAlt[3] VALID UzAltVal("TOT") PICTURE "@E 99,999,999.9999" SIZE 58,8 PIXEL OF oDlg
	@ nLi1+=12,nCo1 SAY "Bc IPI" SIZE 35,7 PIXEL OF oDlg
	@ nLi1    ,nCo1+35 MSGET aAlt[4] PICTURE "@E 99,999,999.99" SIZE 58,8 PIXEL OF oDlg
	@ nLi1+=12,nCo1 SAY "Vlr IPI" SIZE 35,7 PIXEL OF oDlg
	@ nLi1    ,nCo1+35 MSGET aAlt[5] PICTURE "@E 99,999,999.99" SIZE 58,8 PIXEL OF oDlg
	@ nLi1+=12,nCo1 SAY "Bc PIS/COF" SIZE 35,7 PIXEL OF oDlg
	@ nLi1    ,nCo1+35 MSGET aAlt[6] PICTURE "@E 99,999,999.99" SIZE 58,8 PIXEL OF oDlg
	@ nLi1+=12,nCo1 SAY "Vlr PIS" SIZE 35,7 PIXEL OF oDlg
	@ nLi1    ,nCo1+35 MSGET aAlt[7] PICTURE "@E 99,999,999.99" SIZE 58,8 PIXEL OF oDlg
	@ nLi1+=12,nCo1 SAY "Vlr COFINS" SIZE 35,7 PIXEL OF oDlg
	@ nLi1    ,nCo1+35 MSGET aAlt[8] PICTURE "@E 99,999,999.99" SIZE 58,8 PIXEL OF oDlg	
	@ nLi1+=12,nCo1 SAY "Bc ICMS" SIZE 35,7 PIXEL OF oDlg
	@ nLi1    ,nCo1+35 MSGET aAlt[9] PICTURE "@E 99,999,999.99" SIZE 58,8 PIXEL OF oDlg
	@ nLi1+=12,nCo1 SAY "Vlr ICMS" SIZE 35,7 PIXEL OF oDlg
	@ nLi1    ,nCo1+35 MSGET aAlt[10] PICTURE "@E 99,999,999.99" SIZE 58,8 PIXEL OF oDlg

	DEFINE SBUTTON FROM 13,115 TYPE 19 OF oDlg ACTION (nOpcao:=1, oDlg:End()) ENABLE
	DEFINE SBUTTON FROM 31,115 TYPE 2  OF oDlg ACTION (nOpcao:=0, oDlg:End()) ENABLE

	ACTIVATE MSDIALOG oDlg CENTER
	
	If nOpcao == 1
		If aAlt[1] == 0 .OR. aAlt[2] == 0
			MsgInfo("Vlr Unit e Vlr Tot não podem ser 'zero'","Sem Valor")
			Loop
		ElseIf MsgYesNo("Confirma a Alteração?",cTit)


			aVetIT[xPos,4] := aAlt[2]
			aVetIT[xPos,5] := aAlt[3]
			aVetIT[xPos,7] := aAlt[4]
			aVetIT[xPos,8] := aAlt[5]
			aVetIT[xPos,9] := aAlt[6]
			aVetIT[xPos,10] := aAlt[7]
			aVetIT[xPos,11] := aAlt[8]
			aVetIT[xPos,13] := aAlt[9]
			aVetIT[xPos,14] := aAlt[10]

			nBasIPI := 0
			nTotIpi := 0
			nBasPCO := 0
			nTotPis := 0
			nTotCOF := 0
			nBasICM := 0
			nTotICMS:= 0
			nTotSimp:= 0
			nTotCimp:= 0
			nDifIpi := 0
			
			For gh := 1 To Len(aVetIT)
				nBasIPI += aVetIT[gh,7]
				nTotIpi += aVetIT[gh,8]
				nBasPCO += aVetIT[gh,9]
				nTotPis += aVetIT[gh,10]
				nTotCOF += aVetIT[gh,11]
				nBasICM += aVetIT[gh,13]
				nTotICMS+= aVetIT[gh,14]
				nTotSimp+= aVetIT[gh,5]
			Next			

			nTotCimp := nTotIpi+nTotSimp
			nDifIpi  := nTotIpi-nxIpi_Eic
			
			Exit
		Else        
			Loop
		EndIf
	Else
		Exit
	EndIf
	
EndDo

oBasIPI:Refresh()
oTotIpi:Refresh()
oBasPCO:Refresh()
oTotPis:Refresh()
oTotCOF:Refresh()
oBasICM:Refresh()
oTotICMS:Refresh()
oTotSimp:Refresh()
oTotCimp:Refresh()

If lImpDentro
	oDifIpi:Refresh()
EndIf

oLbxIT:SetArray(aVetIT)
oLbxIT:bLine := bLineIT
oLbxIT:Refresh()

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: UZAltIt()
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Descricao.: Faz Alteração nos Itens
//|Observação: 
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function UzAltVal(xTip) 
*----------------------------------------------*

If xTip == "UNI"
	aAlt[3] := Round(aAlt[2]*aAlt[1],6)
	aAlt[4] := aAlt[3]
	aAlt[9] := aAlt[3]
	
Else
	aAlt[2] := Round(aAlt[3]/aAlt[1],6)
	aAlt[4] := aAlt[3]
	aAlt[9] := aAlt[3]
EndIf

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: Grava()
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Descricao.: Faz a Gravação da NF
//|Observação: 
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function Grava()
*----------------------------------------------*

Local lRetu  := .F.
Local nValNF := 0
Local aRet   := {}
Local cICMCont := Alltrim(GetMV("MV_XICMCO",.F.))
Local cIPICont := Alltrim(GetMV("MV_XIPICO",.F.))

SF1->(dbSetOrder(1))
If Empty(Alltrim(cNovaNF)) .OR. Empty(dNovadt)
	MsgStop("Nota, Serie e Data devem ser preenchidas","Sem Preenchimento")
	Return(lRetu)
ElseIf SF1->(dbSeek(xFilial("SF1")+cNovaNF+cNovaSe+SW6->W6_FORNEX+SW6->W6_LJFOEXT+"N"))
	MsgStop("Nota já existe para Fornecedor","Nota Já existe")
	Return(lRetu)
ElseIf MsgYesNo("Confirma a geração da Nota de Transferencia?","Confirmação")
	lRetu  := .T.

	ProcRegua(Len(aVetIT))
	
	aRet := MaFisRelImp("MT100",{ "SD1" })
	If !Empty( nPosi := aScan(aRet,{|x| x[1]=="SD1" .And. x[3]=="IT_BASEPS2"} ) )
		cxBasePis:= aRet[nPosi,2]
	EndIf
	If !Empty( nPosi := aScan(aRet,{|x| x[1]=="SD1" .And. x[3]=="IT_VALPS2"} ) )
		cxValorPis:= aRet[nPosi,2]
	EndIf
	If !Empty( nPosi := aScan(aRet,{|x| x[1]=="SD1" .And. x[3]=="IT_BASECF2"} ) )
		cxBaseCof:= aRet[nPosi,2]
	EndIf
	If !Empty( nPosi := aScan(aRet,{|x| x[1]=="SD1" .And. x[3]=="IT_VALCF2"} ) )
		cxValorCof:= aRet[nPosi,2]
	EndIf	
	
	Begin Transaction

	For tg := 1 To Len(aVetIT)
		IncProc("Gravando NF de Transferencia...")
		SD1->(dbGoTo(aVetIT[tg,29]))
		SD1->(RecLock("SD1",.F.))
		SD1->D1_VUNIT   := aVetIT[tg,4]
		SD1->D1_TOTAL   := aVetIT[tg,5]
		SD1->D1_II      := 0
		SD1->D1_IPI     := aVetIT[tg,6]
		SD1->D1_BASEIPI := aVetIT[tg,7]
		SD1->D1_VALIPI  := aVetIT[tg,8]				
		SD1->D1_PICM    := aVetIT[tg,12]
		SD1->D1_BASEICM := aVetIT[tg,13]		
		SD1->D1_VALICM  := aVetIT[tg,14]
		SD1->D1_FORNECE := SW6->W6_FORNEX
		SD1->D1_LOJA    := SW6->W6_LJFOEXT
		SD1->D1_TOTAL   := aVetIT[tg,5]
		SD1->D1_DOC     := cNovaNF
		SD1->D1_SERIE   := cNovaSE
		SD1->D1_ITEM    := aVetIT[tg,28]
		SD1->D1_DESPESA := 0
		SD1->D1_FORMUL  := "N"
		SD1->D1_PEDIDO  := ""		
		SD1->D1_ITEMPC  := ""
		SD1->D1_NUMDI   :=SW6->W6_DI_NUM
		SD1->(&(cxBasePis))  := aVetIT[tg,9]
		SD1->(&(cxValorPis)) := aVetIT[tg,10]
		SD1->(&(cxBaseCof))  := aVetIT[tg,9]
		SD1->(&(cxValorCof)) := aVetIT[tg,11]						
		SD1->(MsUnLock())		
      
      	SC7->(dbGoTo(aVetIT[tg,31]))
		SC7->(RecLock("SC7",.F.))
		SC7->C7_QUJE    := SC7->C7_QUJE+SD1->D1_QUANT
		SC7->(MsUnLock())		
		/*
		If Alltrim(SW6->W6_TIPODES) <> "14"
			SC7->C7_FO_ORIG := SC7->C7_FORNECE
			SC7->C7_LJ_ORIG := SC7->C7_LOJA
			SC7->C7_FORNECE := SW6->W6_FORNEX
			SC7->C7_LOJA    := SW6->W6_LJFOEXT
		Else
			SC7->C7_QUJE    := SC7->C7_QUJE+SD1->D1_QUANT
		EndIf
		SC7->(MsUnLock())		
		*/
		SWN->(dbGoTo(aVetIT[tg,30]))
		SWN->(RecLock("SWN",.F.))
		SWN->WN_NFTRAN  := cNovaNF
		SWN->WN_SERTRAN := cNovaSE
		SWN->(MsUnlock())
        
		nValNF += aVetIT[tg,5]
	Next

	cSql := " SELECT R_E_C_N_O_ AS REC FROM "+RetSqlName("SF1")
	cSql += " WHERE F1_HAWB = '"+SW6->W6_HAWB+"' AND F1_TIPO = 'N' "
	cSql += "	    AND D_E_L_E_T_ <> '*' AND F1_FILIAL = '"+xFilial("SF1")+"' "	
	Iif(Select("XXXX") # 0,XXXX->(dbCloseArea()),.T.)
	TcQuery cSql New Alias "XXXX"
	XXXX->(dbSelectArea("XXXX"))
	XXXX->(dbGoTop())
	
	nUsa := 1
	
	While XXXX->(!EOF())
		SF1->(dbGoTo(XXXX->REC))
		SF1->(RecLock("SF1",.F.))
		If nUsa == 1
			SF1->F1_DOC     := cNovaNF
			SF1->F1_SERIE   := cNovaSE
			SF1->F1_EMISSAO := dNovadt
			SF1->F1_FORNECE := SW6->W6_FORNEX
			SF1->F1_LOJA    := SW6->W6_LJFOEXT
			SF1->F1_FOB_R   := nValNF
			SF1->F1_FRETE   := 0
			SF1->F1_SEGURO  := 0
			SF1->F1_CIF     := nValNF
			SF1->F1_II      := 0
			SF1->F1_IPI     := nTotIpi
			SF1->F1_ICMS    := nTotIcms
			SF1->F1_DESPESA := 0
			SF1->F1_EST     := Posicione("SA2",1,xFilial("SA2")+SW6->W6_FORNEX+SW6->W6_LJFOEXT,"A2_EST")
			SF1->F1_FORMUL  := "N"
        Else
			SF1->(dbDelete())
		EndIf
		SF1->(MsUnLock())
		nUsa++
		XXXX->(dbSkip())
	EndDo
	XXXX->(dbCloseArea())	

    If !Empty(cICMCont)
		Processa({ || U_GerDespCO("I",cICMCont,nTotICMS,"TX","2080101",cNovaNF,dNovadt,.T.) })
		Processa({ || U_UzDelDesp("E","I.C.M.") })
	Else
		MsgInfo("Codigo da despesa de ICMS não informada no paramentro 'MV_XICMCO'.","Sem Despesa")
	EndIf
	
	If !Empty(cIPICont) .AND. lImpDentro .AND. nDifIpi > 0
		Processa({ || U_GerDespCO("I",cIPICont,nDifIpi,"NF","2080101",cNovaNF,dNovadt,.F.) })
		//Processa({ || U_UzDelDesp("E","I.P.I.") })
	Else
		MsgInfo("Codigo da despesa de Complemento de IPI não informada no paramentro 'MV_XIPICO'.","Sem Despesa")
	EndIf	

	SW6->(RecLock("SW6",.F.))
	SW6->W6_NFTRAN := "S"
	SW6->(MsUnlock())
	
	End Transaction
	
EndIf                 

Return(lRetu)

//+-----------------------------------------------------------------------------------//
//|Funcao....: UZVisNFT
//|Descricao.: Visualiza NF de Transferencia
//|Observação:
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function UZVisNFT()
*----------------------------------------------*

SF1->(dbSelectArea("SF1"))
SF1->(dbSetOrder(1))

If SF1->(dbSeek(xFilial("SF1")+SWN->WN_NFTRAN+SWN->WN_SERTRAN+SW6->W6_FORNEX+SW6->W6_LJFOEXT+"N"))
	
	SF1->(dbSetFilter( {|| SF1->F1_FILIAL = xFilial("SF1") .AND. SF1->F1_HAWB = SW6->W6_HAWB .AND. SF1->F1_TIPO = "N"  },;
	"SF1->F1_FILIAL = xFilial('SF1') .AND. SF1->F1_HAWB = SW6->W6_HAWB .AND. SF1->F1_TIPO = 'N' "))
	MATA140()
	
	SF1->(dbClearFilter())
	
EndIf

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: UZEstNFT()
//|Descricao.: Gera Estorno na NF de Transferencia e NF Normal
//|Observação:
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function UZEstNFT()
*----------------------------------------------*

Local cFilSF1     := xFilial("SF1")
Local lMACanDelF1 := .T.
Local cICMCont    := Alltrim(GetMV("MV_XICMCO",.F.))
Local cIPICont    := Alltrim(GetMV("MV_XIPICO",.F.))
Local aPcUse      := {}

Private lMSErroAuto := .F.

ProcRegua(3)
IncProc("Estornando Nota Fiscal")

SD1->(dbSetOrder(1))
SF1->(dbSetOrder(5))

Begin Transaction

aItens := {}
If MsgYesNo("Deseja Realmente Excluir a NF?","Exclusão")
	If SF1->(dbSeek(cFilSF1+SW6->W6_HAWB+"3"))
		
		While SF1->(!EOF()) .AND. SF1->(F1_FILIAL+F1_HAWB+"3") == (cFilSF1+SW6->W6_HAWB+"3")
			
			If Empty(SF1->F1_STATUS)
				lNFClassificada := .F.
			Else
				lNFClassificada := .T.
			EndIf
			
			If SD1->(dbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))) 
				While SD1->(!EOF()) .AND. SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == (xFilial("SD1")+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA))
					
					If SD1->D1_TIPO # "N" .OR. SD1->D1_CONHEC # SW6->W6_HAWB
						SD1->(dbSkip())
						Loop
					EndIf
					
					aItem := {}
					aAdd(aItem,{"D1_DOC"    ,SD1->D1_DOC    ,NIL})
					aAdd(aItem,{"D1_SERIE"  ,SD1->D1_SERIE  ,NIL})
					aAdd(aItem,{"D1_FORNECE",SD1->D1_FORNECE,NIL})
					aAdd(aItem,{"D1_LOJA"   ,SD1->D1_LOJA   ,NIL})
					aAdd(aItens,ACLONE(aItem))
					SD1->(dbSkip())
				EndDo
			EndIf
			
			aCab := {}
			aAdd(aCab,{"F1_DOC"    ,SF1->F1_DOC    ,NIL})   // NUMERO DA NOTA
			aAdd(aCab,{"F1_SERIE"  ,SF1->F1_SERIE  ,NIL})   // SERIE DA NOTA
			aAdd(aCab,{"F1_FORNECE",SF1->F1_FORNECE,NIL})   // FORNECEDOR
			aAdd(aCab,{"F1_LOJA"   ,SF1->F1_LOJA   ,NIL})   // LOJA DO FORNECEDOR
			aAdd(aCab,{"F1_TIPO"   ,SF1->F1_TIPO   ,NIL})   // TIPO DA NF
			If lNFClassificada
				MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItens,20)
			Else
				MSExecAuto({|x,y,z| MATA140(x,y,z)},aCab,aItens,5)
			EndIf
			If lMSErroAuto
				MostraErro()
				Exit
			EndIf
			SF1->(DbSkip())
			
		EndDo
		// Limpa a Nota Fiscal de Transferencia
		If !lMSErroAuto
			SWN->(dbsetorder(3))
			SWN->(dbseek(xFilial("SWN")+SW6->W6_HAWB))
			While !SWN->(eof()) .and. SWN->WN_FILIAL == xFilial("SWN") .and. SWN->WN_HAWB == SW6->W6_HAWB
				IF SC7->(dbSeek(xFilial("SC7")+Alltrim(SWN->WN_PO_NUM)+SWN->WN_ITEM))
					SC7->(RecLock("SC7",.F.))
					SC7->C7_QUJE    := SC7->C7_QUJE-SWN->WN_QUANT
					SC7->C7_QTDACLA := SC7->C7_QTDACLA-SWN->WN_QUANT
					SC7->(MsUnlock())
					/*
					If Alltrim(SW6->W6_TIPODES) <> "14"
						If !Empty(SC7->C7_FO_ORIG)
							SC7->(RecLock("SC7",.F.))
							SC7->C7_FORNECE := SC7->C7_FO_ORIG
							SC7->C7_LOJA    := SC7->C7_LJ_ORIG
							SC7->C7_FO_ORIG := ""
							SC7->C7_LJ_ORIG := ""
							SC7->(MsUnlock())
						EndIf
					Else
						SC7->(RecLock("SC7",.F.))
						SC7->C7_QUJE    := SC7->C7_QUJE-SWN->WN_QUANT
						SC7->C7_QTDACLA := SC7->C7_QTDACLA-SWN->WN_QUANT
						SC7->(MsUnlock())
					EndIf
					*/
				Endif
				SWN->(RecLock("SWN",.F.))
				SWN->(dbDelete())
				SWN->(MsUnlock())
				SWN->(dbSkip())
			EndDo
			
			SW6->(RecLock("SW6",.F.))
			SW6->W6_NF_ENT := ""
			SW6->W6_SE_NF  := ""
			SW6->W6_DT_NF  := CtoD("")
			SW6->W6_NF_COMP:= ""
			SW6->W6_SE_NFC := ""
			SW6->W6_VL_NF  := 0
			SW6->W6_NFTRAN := ""
			SW6->(MsUnLock())

			nVal := 0			
			SWD->(dbSetOrder(1))
			If SWD->(dbSeek(xFilial("SW6")+SW6->W6_HAWB))
				While SWD->(!EOF()) .AND. (xFilial("SWD")+SWD->WD_HAWB) == SW6->(W6_FILIAL+W6_HAWB)			
					SWD->(RecLock("SWD",.F.))
					SWD->WD_NF_COMP := ""
					SWD->WD_SE_NFC  := ""
					SWD->WD_VL_NFC  := 0
					SWD->WD_DT_NFC  := CtoD("")
					SWD->(MsUnLock())
					SWD->(dbSkip())
				EndDo
			EndIf

			If !Empty(cICMCont)
				Processa({ || U_GerDespCO("E",cICMCont) })
				Processa({ || U_UzDelDesp("I","I.C.M.") })
			Else
				MsgInfo("Codigo da despesa de ICMS não informada no paramentro 'MV_XICMCO'.","Sem Despesa")
			EndIf

			If !Empty(cIPICont)
				Processa({ || U_GerDespCO("E",cIPICont) })
				Processa({ || U_UzDelDesp("I","I.P.I.") })
			Else
				MsgInfo("Codigo da despesa de Complemento de IPI não informada no paramentro 'MV_XIPICO'.","Sem Despesa")
			EndIf
			
		Else
			MsgStop("Ocorrerão Problemas com a Exclusão da NF de Transferencia. Favor vericar","Exclusão")
		EndIf
	EndIf
Else
	lMSErroAuto := .T.
EndIf

End Transaction

If !lMSErroAuto
	cSql := " SELECT R_E_C_N_O_ AS REC FROM "+RetSqlName("SWN")+" WHERE D_E_L_E_T_ <> '*' "
	cSql += " AND WN_HAWB = '"+SW6->W6_HAWB+"' "
	Iif(Select("XXZZ") # 0,XXZZ->(dbCloseArea()),.T.)
	TcQuery cSql New Alias "XXZZ"
	XXZZ->(dbSelectArea("XXZZ"))
	XXZZ->(dbGoTop())

	If XXZZ->(EOF()) .AND. XXZZ->(BOF())
		XXZZ->(dbCloseArea())
	Else
		XXZZ->(dbGoTop())
		While XXZZ->(!EOF())
			SWN->(dbGoTo(XXZZ->REC))
			SWN->(RecLock("SWN",.F.))
			SWN->(dbDelete())
			SWN->(MsUnlock())						
			XXZZ->(dbSkip())		
		EndDo
		XXZZ->(dbCloseArea())
	EndIf 
	
	cSql := " SELECT R_E_C_N_O_ AS REC FROM "+RetSqlName("SWD")+" WHERE D_E_L_E_T_ <> '*' "
	cSql += " AND WD_HAWB = '"+SW6->W6_HAWB+"' "
	Iif(Select("XXZX") # 0,XXZX->(dbCloseArea()),.T.)
	TcQuery cSql New Alias "XXZX"
	XXZX->(dbSelectArea("XXZX"))
	XXZX->(dbGoTop())

	If XXZX->(EOF()) .AND. XXZX->(BOF())
		XXZX->(dbCloseArea())
	Else
		XXZX->(dbGoTop())
		While XXZX->(!EOF())
			SWD->(dbGoTo(XXZX->REC))
			SWD->(RecLock("SWD",.F.))
			SWD->WD_NF_COMP := ""
			SWD->WD_SE_NFC  := ""
			SWD->WD_VL_NFC  := 0
			SWD->WD_DT_NFC  := CtoD("")
			SWD->(MsUnLock())				
			XXZX->(dbSkip())		
		EndDo
		XXZX->(dbCloseArea())
	EndIf 

	MsgInfo("NF excluida com sucesso!","Exclusão")
EndIf

Return

//+------------------------------------------------------------------------------------//
//|Fim do programa UZGerNFT.PRW
//+------------------------------------------------------------------------------------//

