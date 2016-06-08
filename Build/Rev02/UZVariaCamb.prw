#INCLUDE "TOTVS.CH"

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: UZValCam
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 30 de Junho de 2009 - 08:00
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 8.11
//|Descricao.: Valida o Lan�amento Padr�o e chama fun��o de contabiliza��o de
//|            varia��o cambial
//|Observa��o:
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
User Function UZValCam(axLanc)
*----------------------------------------------*

If VerPadrao(axLanc[1])
	Processa({|| UZVariaCamb(axLanc) },"Contabilizando")
Else
	//MsgInfo("Lancamento padronizado "+Alltrim(axLanc[1])+" nao existe. Favor verificar os Lan�amentos cadastrados","Lan�amento Padr�o")
EndIf

Return

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: UZVariaCamb
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 30 de Junho de 2009, 08:00
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 8.11
//|Descricao.: Chama Lan�amento padr�o para a Varia��o Cambial
//|Observa��o:
//------------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function UZVariaCamb(axPad)
*----------------------------------------------*

Local lCab   := .F.
Local nVaria := 0
Local nTotal := 0
Public _nTotFob   := 0

SE2->(dbSetOrder(1))
If SE2->(dbSeek(axPad[2]))

	dbSelectArea("SE5")
	dbSelectArea("SWB")
	dbSelectArea("SE2")
	dbSelectArea("CT5")

	cLot := "008850"
	lDig := .T.
	lAgl := .F.
	nTot := 0
	nHdl := 0
	cArq := ""

	nHdl := HeadProva(cLot,"UZVARIAC",Substr(cUsuario,7,6),@cArq)

	If Empty(SE2->E2_TXMDCOR)
		nVaria := (axPad[3]-SE2->E2_TXMOEDA)
		If nVaria == SE2->E2_TXMOEDA .OR. Empty(nVaria)
			_nTotFob := 0
		Else
			_nTotFob := SE2->E2_VALOR*nVaria
		EndIf
	Else
		nVaria := (axPad[3]-SE2->E2_TXMDCOR)
		If nVaria == SE2->E2_TXMDCOR .OR. Empty(nVaria)
			_nTotFob := 0
		Else
			_nTotFob := SE2->E2_VALOR*nVaria
		EndIf
	EndIf

	nTotal := DetProva(nHdl,axPad[1],"UZVARIAC",cLot)

	If nTotal <> 0
		RodaProva(nHdl,nTotal)
		cA100Incl(cArq,nHdl,3,cLot,lDig,lAgl)
	EndIf

EndIf

Return

//+------------------------------------------------------------------------------------//
//|Fim do programa UZVariaCamb.PRW
//+------------------------------------------------------------------------------------//