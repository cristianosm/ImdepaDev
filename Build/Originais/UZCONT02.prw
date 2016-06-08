#INCLUDE "Rwmake.ch"
#INCLUDE "TOPCONN.CH"

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: U_UZCONT02()
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 22 de Maio de 2010 - 18:00
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 10
//|Descricao.: Valida Informações para contabilização em Transito de Frete e Seguro
//|Observação:
//+-----------------------------------------------------------------------------------//
*-------------------------------------------------------------------------------------------*
User Function UZCONT02(xDatDB,xDatME,xFreteDB,xFreteME,xSeguroDB,xSeguroME,xDtMemo,xDtBase,;
						xTXSeg,xTXFre,xTxCorFre,xTxCorSeg,xDtCorFre,xDtCorSeg)
*-------------------------------------------------------------------------------------------*
Local cSeekFre  := xFilial("SE2")+SW6->W6_PREFIXF+SW6->W6_NUMDUPF+SW6->W6_PARCELF+SW6->W6_TIPOF+SW6->W6_FORNECF+SW6->W6_LOJAF
Local cSeekSeg  := xFilial("SE2")+SW6->W6_PREFIXS+SW6->W6_NUMDUPS+SW6->W6_PARCELS+SW6->W6_TIPOS+SW6->W6_FORNECS+SW6->W6_LOJAS
Public _nTotSF  := 0
Public xdDt1    := CtoD("")
Public xdDt2    := CtoD("")

//------------------------------------------------------------------------------------//
//|Como as datas de contabilização são efetuadas no Desembaraço e se o usuário  
//|estiver do Embarque o programa irá retornar sem processamento contabil       
//------------------------------------------------------------------------------------//
If Alltrim(FunName()) == "EICDI501"
	Return Nil
Endif

//+------------------------------------------------------------------------------------//
//|Contabilização de Importação em Transito Frete e Seguro sem D.I.
//+------------------------------------------------------------------------------------//
If Empty(xDatME) .AND. Empty(xDatDB)

	If !Empty(xDtMemo) .AND. Empty(xDtBase)
		xdDt1 := xDtMemo
		xdDt2 := xDtMemo
		If !Empty(xFreteME) 
			UZValInf2("UZ5",cSeekFre,xFreteME,0) //INCLUSÃO DE FRETE SEM DI
		EndIf
		If !Empty(xSeguroME)
			UZValInf2("UZ9",cSeekSeg,xSeguroME,0) //INCLUSÃO DE SEGURO SEM DI		
		EndIf
		
	ElseIf Empty(xDtMemo) .AND. !Empty(xDtBase)
		xdDt1 := xDtBase
		xdDt2 := xDtBase
		If !Empty(xFreteDB)
			UZValInf2("UZ6",cSeekFre,xFreteDB,xTXFre) //EXCLUSÃO DE FRETE SEM DI
		EndIf
		If !Empty(xSeguroDB)
			UZValInf2("UZA",cSeekSeg,xSeguroDB,xTXSeg) //EXCLUSÃO DE SEGURO SEM DI
		EndIf
		
	ElseIf xDtMemo <> xDtBase 
		xdDt1 := xDtMemo
		xdDt2 := xDtBase

		If Empty(xFreteDB) .AND. !Empty(xFreteME)
			UZValInf2("UZ5",cSeekFre,xFreteME,0) //INCLUSÃO DE FRETE SEM DI
		ElseIf !Empty(xFreteDB) .AND. Empty(xFreteME)
			UZValInf2("UZ6",cSeekFre,xFreteDB,xTXFre) //EXCLUSÃO DE FRETE SEM DI
		ElseIf !Empty(xFreteDB) .AND. !Empty(xFreteME)
			UZValInf2("UZ6",cSeekFre,xFreteDB,xTXFre) //EXCLSÃO DE FRETE SEM DI
			UZValInf2("UZ5",cSeekFre,xFreteME,0) //INCLUSÃO DE FRETE SEM DI
		EndIf

		If Empty(xSeguroDB) .AND. !Empty(xSeguroME)
			UZValInf2("UZ9",cSeekSeg,xSeguroME,0) //INCLUSÃO DE SEGURO SEM DI
		ElseIf !Empty(xSeguroDB) .AND. Empty(xSeguroME)
			UZValInf2("UZA",cSeekSeg,xSeguroDB,xTXSeg) //EXCLUSÃO DE SEGURO SEM DI
		ElseIf !Empty(xSeguroDB) .AND. !Empty(xSeguroME)
			UZValInf2("UZA",cSeekSeg,xSeguroDB,xTXSeg) //EXCLUSÃO DE SEGURO SEM DI
			UZValInf2("UZ9",cSeekSeg,xSeguroME,0) //INCLUSÃO DE SEGURO SEM DI
		EndIf
	
	ElseIf (!Empty(xDtMemo) .AND. !Empty(xDtBase)) .AND. (xDtMemo == xDtBase)

		xdDt1 := xDtMemo
		xdDt2 := xDtMemo

		If !Empty(xFreteME) .AND. xFreteDB <> xFreteME
			UZValInf2("UZ6",cSeekFre,xFreteDB,xTXFre) //EXCLUSÃO DE FRETE SEM DI
			UZValInf2("UZ5",cSeekFre,xFreteME,0) //INCLUSÃO DE FRETE SEM DI
		ElseIf !Empty(xFreteDB) .AND. Empty(xFreteME)
			UZValInf2("UZ6",cSeekFre,xFreteDB,xTXFre) //EXCLUSÃO DE FRETE SEM DI			
		EndIf

		If !Empty(xSeguroME) .AND. xSeguroDB <> xSeguroME
			UZValInf2("UZA",cSeekSeg,xSeguroDB,xTXSeg) //EXCLUSÃO DE SEGURO SEM DI
			UZValInf2("UZ9",cSeekSeg,xSeguroME,0) //INCLUSÃO DE SEGURO SEM DI
		ElseIf !Empty(xSeguroDB) .AND. Empty(xSeguroME)
			UZValInf2("UZA",cSeekSeg,xSeguroDB,xTXSeg) //EXCLUSÃO DE SEGURO SEM DI
		EndIf

	EndIf

//+------------------------------------------------------------------------------------//
//|Contabilização de Importação em Transito Frete e Seguro com D.I.
//+------------------------------------------------------------------------------------//
ElseIf !Empty(xDatME) .AND. Empty(xDatDB)

	xdDt1 := xDatME
	xdDt2 := Iif(Empty(xDtBase),xDtMemo,xDtBase)

	If Empty(xFreteDB) .AND. !Empty(xFreteME) .AND. Empty(xDtBase)
		UZValInf2("UZ7",cSeekFre,xFreteME,0) //INCLUSÃO DE FRETE COM DI
	ElseIf !Empty(xFreteDB) .AND. Empty(xFreteME) .AND. !Empty(xDtBase)
		UZValInf2("UZ6",cSeekFre,xFreteDB,xTXFre) //EXCLUSÃO DE FRETE SEM DI
	ElseIf !Empty(xFreteDB) .AND. !Empty(xFreteME) .AND. !Empty(xDtMemo)
		UZValInf2("UZ6",cSeekFre,xFreteDB,xTXFre) //EXCLUSÃO DE FRETE SEM DI
		UZValInf2("UZ7",cSeekFre,xFreteME,0) //INCLUSÃO DE FRETE COM DI
	EndIf

	If Empty(xSeguroDB) .AND. !Empty(xSeguroME) .AND. Empty(xDtBase)
		UZValInf2("UZB",cSeekSeg,xSeguroME,0) //INCLUSÃO DE SEGURO COM DI
	ElseIf !Empty(xSeguroDB) .AND. Empty(xSeguroME) .AND. !Empty(xDtBase)
		UZValInf2("UZA",cSeekSeg,xSeguroDB,xTXSeg) //EXCLUSÃO DE SEGURO SEM DI
	ElseIf !Empty(xSeguroDB) .AND. !Empty(xSeguroME) .AND. !Empty(xDtMemo)
		UZValInf2("UZA",cSeekSeg,xSeguroDB,xTXSeg) //EXCLUSÃO DE SEGURO SEM DI
		UZValInf2("UZB",cSeekSeg,xSeguroME,0) //INCLUSÃO DE SEGURO COM DI
	EndIf
	
//+------------------------------------------------------------------------------------//
//|Contabilização de Importação em Transito Frete e Seguro com D.I. - Exclusão
//+------------------------------------------------------------------------------------//
ElseIf Empty(xDatME) .AND. !Empty(xDatDB)

	xdDt1 := xDtMemo
	xdDt2 := xDtBase

	If Empty(xFreteDB) .AND. !Empty(xFreteME) .AND. !Empty(xDtMemo)
		UZValInf2("UZ5",cSeekFre,xFreteME,0) //INCLUSÃO DE FRETE SEM DI
	ElseIf !Empty(xFreteDB) .AND. Empty(xFreteME) .AND. !Empty(xDtBase)
		UZValInf2("UZ8",cSeekFre,xFreteDB,xTXFre) //EXCLUSÃO DE FRETE COM DI
	ElseIf !Empty(xFreteDB) .AND. !Empty(xFreteME) .AND. !Empty(xDtMemo) .AND. !Empty(xDtBase)
		UZValInf2("UZ8",cSeekFre,xFreteDB,xTXFre) //EXCLUSÃO DE FRETE COM DI
	ElseIf !Empty(xFreteDB) .AND. !Empty(xFreteME) .AND. !Empty(xDtMemo)
		UZValInf2("UZ8",cSeekFre,xFreteDB,xTXFre) //EXCLUSÃO DE FRETE COM DI
		UZValInf2("UZ5",cSeekFre,xFreteME,0) //INCLUSÃO DE FRETE SEM DI
	EndIf

	If Empty(xSeguroDB) .AND. !Empty(xSeguroME) .AND. !Empty(xDtMemo)
		UZValInf2("UZ9",cSeekSeg,xSeguroME,0) //INCLUSÃO DE SEGURO SEM DI
	ElseIf !Empty(xSeguroDB) .AND. Empty(xSeguroME) .AND. !Empty(xDtBase)
		UZValInf2("UZC",cSeekSeg,xSeguroDB,xTXSeg) //EXCLUSÃO DE SEGURO COM DI
	ElseIf !Empty(xSeguroDB) .AND. !Empty(xSeguroME) .AND. Empty(xDtMemo) .AND. !Empty(xDtBase)
		UZValInf2("UZC",cSeekSeg,xSeguroDB,xTXSeg) //EXCLUSÃO DE SEGURO COM DI
	ElseIf !Empty(xSeguroDB) .AND. !Empty(xSeguroME) .AND. !Empty(xDtMemo)
		UZValInf2("UZC",cSeekSeg,xSeguroDB,xTXSeg) //EXCLUSÃO DE SEGURO SEM DI
		UZValInf2("UZ9",cSeekSeg,xSeguroME,0) //INCLUSÃO DE SEGURO COM DI
	EndIf

EndIf

Begin Transaction

	SE2->(dbSetOrder(1))
	If !Empty(xTxCorFre)
		If SE2->(dbSeek(cSeekFre))
			SE2->(RecLock("SE2",.F.))
			SE2->E2_DTVARIA := xDtCorFre
			SE2->E2_TXMDCOR := xTxCorFre
			SE2->(MsUnLock())
		EndIf
	EndIf

	If !Empty(xTxCorSeg)
		If SE2->(dbSeek(cSeekSeg))
			SE2->(RecLock("SE2",.F.))
			SE2->E2_DTVARIA := xDtCorSeg
			SE2->E2_TXMDCOR := xTxCorSeg
			SE2->(MsUnLock())
		EndIf
	EndIf

End Transaction

Return
//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: UZValInf2
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 22 de Maio de 2010 - 18:00
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 10
//|Descricao.: Contabilização em transito SIGAEIC Frete e Seguro
//|Observação:
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function UZValInf2(xLP,xSeek,xVal,xTx)
*----------------------------------------------*

dbSelectArea("CT5")
dbSelectArea("SA2")
dbSelectArea("SE2")
dbSelectArea("SE5")

If VerPadrao(xLP)
	Processa({|| UZContab(xLP,xSeek,xVal,xTx)},"Contabilizando")
Else
	MsgInfo("Lancamento padronizado "+Alltrim(xLP)+" nao existe. Favor verificar os Lançamentos cadastrados","Lançamento Padrão")
EndIf

Return

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: UZContab
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 22 de Maio de 2010 - 18:00
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 10
//|Descricao.: Inicia Processamento Principal
//|Observação:
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function UZContab(cxLanc,xSeek,xVal,xTx)
*----------------------------------------------*

Local nLenX1    := Len(SX1->X1_GRUPO)-6
Local cArquivo	:= ""
Local cLote		:= "008850" // MV_PAR05
Local nTotal	:= 0
Local nHdlPrv	:= 0
Local lMostra	:= Iif(Posicione("SX1",1,"EICFI4"+Space(nLenX1)+"02","X1_PRESEL") == 1,.T.,.F.)
Local lAglut	:= .F.
Local lHead		:= .T.

Private aRotina := {}

ProcRegua(1)

Begin Transaction
	
	SA2->(dbSetOrder(1))
	SE2->(dbSetOrder(1))
	If SE2->(dbSeek(xSeek))
		
		SA2->(dbSeek(xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA)))

				
		_nTotSF := Iif(!Empty(xTx),SE2->E2_VALOR*xTx,xVal)
		lHead   := .T.
		
		If lHead
			lHead   := .F.
			nHdlPrv := HeadProva(cLote,"CONTGD02",Subs(cUsuario,7,6),@cArquivo)
			If nHdlPrv <= 0
				Help(" ",1,"A100NOPRV")
				Return Nil
			EndIf
		EndIf
		
		nTotal := DetProva(nHdlPrv,cxLanc,"CONTGD02",cLote)
		
		If nHdlPrv > 0
			RodaProva(nHdlPrv,nTotal)
			lLctoOk	:= cA100Incl(cArquivo,nHdlPrv,3,cLote,lMostra,lAglut)
		EndIf
		
	EndIf
	
End Transaction

Return

//+------------------------------------------------------------------------------------//
//|Fim do programa UZCONT02.PRW
//+------------------------------------------------------------------------------------//

