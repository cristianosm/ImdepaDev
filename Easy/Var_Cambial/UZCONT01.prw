#Include "totvs.ch"

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: U_UZCONT01()
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 30 de Junho de 2009 - 08:00
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 8.11
//|Descricao.: Valida Informações para contabilização em Transito
//|Observação:
//+-----------------------------------------------------------------------------------//
*--------------------------------------------------------------------------------------*
User Function UZCONT01(xDtDIOld,xDTDIMe,xDtEmbOld,xDtEmbMe,axVet,xProc,axTxOld,xValInvOld,xValInvNew)
*--------------------------------------------------------------------------------------*

	Private aTxOl 	:= axTxOld
	Private lHead	:= .F.
	Private lFim		:= .F.

	Private cArquivo	:= ""
	Private cLote		:= "008850" // MV_PAR05
	Private nTotal		:= 0
	Private nHdlPrv		:= 0
	Private nLenX1    := Len(SX1->X1_GRUPO)-6
	Private lMostra   := Iif(Posicione("SX1",1,"EICFI4"+Space(nLenX1)+"02","X1_PRESEL") == 1,.T.,.F.)
	Private lAglut	:= .F.
	Private nTxMoed   := 0

	Private aCtbDesp  := {}


	Private iTot			:= Len(axVet)/2

	Public xdDt1    := CtoD("")
	Public xdDt2    := CtoD("")
	Public _nTotFob := 0
	Public xDeEntrP := ""
	Public xDeVarRe := ""
	Public xToProUse:= xProc
	Public xDebVari := ""
	Public xDebCred := ""
	Public xcCVDed  := ""
	Public xcCVCred := ""
	Public xcCCDed  := ""
	Public xcCCCred := ""
	Public _UzHistEntrep := ""


	Default xValInvOld := 0
	Default xValInvNew := 0
//------------------------------------------------------------------------------------//
//|Como as datas de contabilização são efetuadas no Desembaraço e se o usuário
//|estiver do Embarque o programa irá retornar sem processamento contabil
//------------------------------------------------------------------------------------//
	If Alltrim(FunName()) == "EICDI501"
		Return Nil
	Endif

//+------------------------------------------------------------------------------------//
//|A contabilização só será possivel se o processo possuir Invoice
//+------------------------------------------------------------------------------------//
	SW8->(dbSetOrder(1))
	SW9->(dbSetOrder(3))

	If !SW8->(dbSeek(xFilial("SW8")+SW6->W6_HAWB)) .OR.	!SW9->(dbSeek(xFilial("SW9")+SW6->W6_HAWB))
		Return Nil
	EndIf

//+------------------------------------------------------------------------------------//
//|Contabilização de Importação em Transito sem D.I.
//+------------------------------------------------------------------------------------//
	If xToProUse == "14"

		dbSelectArea("CT5")
		dbSelectArea("SA2")
		dbSelectArea("SE2")
		dbSelectArea("SE5")
		dbSelectArea("SWB")

		If !Empty(xDTDIMe) .AND. Empty(xDtDIOld)

			xdDt1 := dDataBase
			xdDt2 := dDataBase
			For i := 1 To Len(axvet)
				Processa({|| UZContab("UZG",axVet[I],"I","V")},"Contabilizando")
			next
		//| Processa({|| UZContab("XX2",axVet,"I","V")},"Contabilizando")
			lFim := .t.
			RdProvaFim()

		ElseIf Empty(xDTDIMe) .AND. !Empty(xDtDIOld)
			If Empty(xDtEmbMe) .AND. !Empty(xDtEmbOld)

				xdDt1 := dDataBase
				xdDt2 := xDtEmbOld
				For i := 1 To Len(axvet)
					Processa({|| UZContab("UZG",axVet[I],"E","V")},"Contabilizando")
				next
				lFim := .t.
				RdProvaFim()

			EndIf
		EndIf

	Else
		If Empty(xDTDIMe) .AND. Empty(xDtDIOld)


			//Alert("Entrou.... Old $ "+CvalToChar(xValInvOld)+"  New $"+cValToChar(xValInvNew))
			If !Empty(xDtEmbMe) .AND. Empty(xDtEmbOld)

				xdDt1 := xDtEmbMe
				xdDt2 := xDtEmbMe

				For i := 1 To Len(axvet)
					UZValInf1("UZ1",axVet[I],"I") //INCLUSÃO DE MERCADORIA SEM DI
				next
				lFim := .t.
				RdProvaFim()


			ElseIf Empty(xDtEmbMe) .AND. !Empty(xDtEmbOld)


				xdDt1 := xDtEmbOld
				xdDt2 := xDtEmbOld

				For i := 1 To Len(axvet)
					UZValInf1("UZ2",axVet[I],"E") //EXCLUSÃO DE MERCADORIA SEM DI
				next

				RdProvaFim()


			Elseif ( xValInvOld <> xValInvNew .And.( xValInvOld > 0 .And. xValInvNew > 0 ))
				xdDt1 := xDtEmbMe
				xdDt2 := xDtEmbOld

				For i := 1 To iTot
					UZValInf1("UZ2",axVet[i],"E","V") //EXCLUSÃO DE MERCADORIA SEM DI
				Next

				For i := 1 To iTot
					UZValInf1("UZ1",axVet[i+iTot],"I") //INCLUSÃO DE MERCADORIA SEM DI
				Next

				lFim := .t.
				RdProvaFim()

			EndIf

		//+------------------------------------------------------------------------------------//
		//|Contabilização de Importação em Transito com D.I. ENTROU AQUI
		//+------------------------------------------------------------------------------------//
		ElseIf !Empty(xDTDIMe) .AND. Empty(xDtDIOld)

			xdDt1 := xDTDIMe
			xdDt2 := Iif(Empty(xDtEmbOld),xDtEmbMe,xDtEmbOld)

			For i := 1 To iTot
				UZValInf1("UZ2",axVet[I],"E","V") //EXCLUSÃO DE MERCADORIA SEM DI
			Next


			For i := 1 To iTot
				UZValInf1("UZD",axVet[i+iTot],"I")     //INCLUSÃO DE MERCADORIA COM DI
			Next

			lFim := .T.
			RdProvaFim()

		//+------------------------------------------------------------------------------------//
		//|Contabilização de Importação em Transito - Exclusão
		//+------------------------------------------------------------------------------------//
		ElseIf Empty(xDTDIMe) .AND. !Empty(xDtDIOld)

			xdDt1 := xDtEmbMe
			xdDt2 := xDtEmbOld

			If Empty(xDtEmbMe) .AND. !Empty(xDtEmbOld)
				For i := 1 To Len(axvet)

					UZValInf1("UZE",axVet[i],"E") //EXCLUSÃO DE MERCADORIA COM DI
				Next

				lFim := .T.
				RdProvaFim()


			ElseIf !Empty(xDtEmbMe) .AND. !Empty(xDtEmbOld)

				For i := 1 To iTot

					UZValInf1("UZE",axVet[i],"E","V") //EXCLUSÃO DE MERCADORIA COM DI
				Next

				For i := 1 To iTot

					UZValInf1("UZI",axVet[iTot+i],"I") //INCLUSÃO DE MERCADORIA SEM DI
				Next
				lFim := .t.
				RdProvaFim()

			EndIf

		EndIf

		Processa({ || UzTxCorr(axVet) })

	EndIf

Return

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: ValInform()
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 30 de Junho de 2009 - 08:00
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 8.11
//|Descricao.: Contabilização em transito SIGAEIC
//|Observação:
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function UZValInf1(cxLanc,xVet,xTip,xVari)
*----------------------------------------------*

	dbSelectArea("CT5")
	dbSelectArea("SA2")
	dbSelectArea("SE2")
	dbSelectArea("SE5")
	dbSelectArea("SWB")

	If VerPadrao(cxLanc)
		Processa({|| UZContab(cxLanc,xVet,xTip,xVari)},"Contabilizando")
	Else
		MsgInfo("Lancamento padronizado "+Alltrim(cxLanc)+" nao existe. Favor verificar os Lançamentos cadastrados","Lançamento Padrão")
	EndIf

Return

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: UZContab
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 13 de Junho de 2009 - 18:21
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 8.11
//|Descricao.: Inicia Processamento Principal
//|Observação:
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function UZContab(cxLanc,xVet,xTip,xVari)
*----------------------------------------------*

	Local cLancOld  := cxLanc
	Local nTotReg		:= Len(xVet)

	ProcRegua(nTotReg)

	Begin Transaction

		SA2->(dbSetOrder(1))
		SE2->(dbSetOrder(1))



		cxLanc := cLancOld
		IncProc("Contabilizando Invoices...")

		If SE2->(dbSeek(xVet[4]))
			SA2->(dbSeek(xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA)))
			If !cxLanc $ "XX1,XX2,XX3,UZG"
				_nTotFob := xVet[5] * Iif(xTip=="E".AND.!Empty(xVet[2]),xVet[2],Iif(!Empty(xVet[2]),xVet[2],xVet[1]))

				If cxLanc == "UZE" .and. xTip == "E"
					_nTotFob := xVet[5] * xVet[1]
				Endif

				If cxLanc == "UZD" // REGISTRO DI PEGA TAXA DA INVOICE....W9_TX_FOB
					_nTotFob := xVet[5] * xVet[1]
				Endif

				If !lHead
					lHead   := .T.
					nHdlPrv := HeadProva(cLote,"CONTGD01",Subs(cUsuario,7,6),@cArquivo)
				EndIf
				nTotal += DetProva(nHdlPrv,cxLanc,"CONTGD01",cLote)
			ElseIf cxLanc == "UZG"
				_nTotFob := xVet[5]*xVet[2]
				If xTip == "E"
					_UzHistEntrep := "TRANSF. ENTREP. PE: "+Alltrim(SW6->W6_HAWB)+" P/  DA: 0"+SubStr(Alltrim(SW6->W6_HAWB),2,5)
					xcCVDed  := U_UZCCusto("ENT")
					xcCVCred := U_UZCCusto("ENT","UZG")
				Else
					_UzHistEntrep := "TRANSF. ENTREP. DA: 0"+SubStr(Alltrim(SW6->W6_HAWB),2,5)+" P/ PE: "+Alltrim(SW6->W6_HAWB)
					xcCVDed  := U_UZCCusto("ENT","UZG")
					xcCVCred := U_UZCCusto("ENT")
				EndIf
				If !lHead
					lHead   := .T.
					nHdlPrv := HeadProva(cLote,"CONTGD01",Subs(cUsuario,7,6),@cArquivo)
				EndIf
				nTotal += DetProva(nHdlPrv,cxLanc,"CONTGD01",cLote)
			EndIf

			If xVari == "V"
				If VerPadrao("UZF")

					_nTotFob := xVet[5]*Iif(!Empty(xVet[2]),ABS(xVet[2]-SW9->W9_TX_FOB),xVet[1]-SW9->W9_TX_FOB)
					If cxLanc == "UZ2"
						_nTotFob := _nTotFob * (-1) // INVERTE AS CONTAS...
					EndIF
					//nVal2    := xVet[5]*xVet[1]
					//_nTotFob := nVal2-nVal1

					If Alltrim(xToProUse) == "2"
						If Empty(SE2->E2_SALDO)
							xcCVDed  := Iif(_nTotFob > 0,"",U_UZCCusto("ENT"))
							xcCVCred := Iif(_nTotFob > 0,U_UZCCusto("ENT"),"")
							xcCCDed  := Iif(_nTotFob > 0,U_UZCCusto("FEX"),"151101")
							xcCCCred := Iif(_nTotFob > 0,"151101",U_UZCCusto("FEX"))
							xDebVari := Iif(_nTotFob > 0,"21201020","34301090")
							xDebCred := Iif(_nTotFob > 0,"31201020","21201020")
						Else
							_nTotFob := 0
						EndIf
						SE2->(RecLock("SE2",.F.))
						SE2->E2_TXMDCOR := Iif(!Empty(xVet[2]),xVet[2],xVet[1])
						SE2->E2_DTVARIA := xdDt1
						SE2->(MsUnLock())

					ElseIf Alltrim(xToProUse) == "14"
						xcCVDed  := Iif(_nTotFob > 0,U_UZCCusto("ENT"),"")
						xcCVCred := Iif(_nTotFob > 0,"",U_UZCCusto("ENT"))
						xcCCDed  := Iif(_nTotFob > 0,"","151101")
						xcCCCred := Iif(_nTotFob > 0,"151101","")
						xDebVari := Iif(_nTotFob > 0,"11501032","34301090")
						xDebCred := Iif(_nTotFob > 0,"31201020","11501032")

						If cxLanc == "UZG"
							cxLanc := Iif(xTip == "E","XX3","XX2")
						EndIf
					Else
						If Empty(SE2->E2_SALDO)
							xcCVDed  := Iif(_nTotFob > 0,U_UZCCusto("MTE"),"")
							xcCVCred := Iif(_nTotFob > 0,"",U_UZCCusto("MTE"))
							xcCCDed  := Iif(_nTotFob > 0,U_UZCCusto("FEX"),"151101")
							xcCCCred := Iif(_nTotFob > 0,"151101",U_UZCCusto("FEX"))
							xDebVari := Iif(_nTotFob > 0,"21201020","34301090")
							xDebCred := Iif(_nTotFob > 0,"31201020","21201020")
						Else
							_nTotFob := 0
						EndIf
					EndIf

					If cxLanc == "XX1"
						xDeVarRe := "VAR INC ADM: "+Alltrim(SW6->W6_HAWB)+" - "+DtoC(dDataBase)+IIF(M->_nTotFob>0," - PAS"," - AT")
					ElseIf cxLanc == "XX2"
						xDeVarRe := "VAR RDI DESEN ENT: "+Alltrim(SW6->W6_HAWB)+" - "+DtoC(dDataBase)+IIF(M->_nTotFob>0," - PAS"," - (ATIVA)")
					ElseIf cxLanc == "XX3"
						xDeVarRe := "VAR RET DA: "+Alltrim(SW6->W6_HAWB)+" - "+DtoC(dDataBase)+IIF(M->_nTotFob>0," - AT"," - PAS")
					ElseIf cxLanc == "UZ2" .AND. xToProUse == "2"
						xDeVarRe := "VAR RDA: "+Alltrim(SW6->W6_HAWB)+" - "+DtoC(dDataBase)+IIF(M->_nTotFob>0," - AT"," - PAS")
					Else
						xDeVarRe := "VAR RDI PROC.: "+Alltrim(SW6->W6_HAWB)+"- TRANS: "+DtoC(xdDt2)+IIF(M->_nTotFob<0," - PAS"," - AT")
					EndIf

					If !lHead
						lHead   := .T.
						nHdlPrv := HeadProva(cLote,"CONTGD01",Subs(cUsuario,7,6),@cArquivo)
					EndIf
					nTotal += DetProva(nHdlPrv,"UZF","CONTGD01",cLote)
				EndIf
				If !Empty(_nTotFob)
					xVet[3] := dDataBase
					xVet[2] := xVet[1]

					dbSelectArea("SE5")
					SE5->(RecLock("SE5",.T.))
					SE5->E5_FILIAL  	:= xFilial("SE5")
					SE5->E5_PREFIXO 	:= SE2->E2_PREFIXO
					SE5->E5_NUMERO  	:= SE2->E2_NUM
					SE5->E5_PARCELA 	:= SE2->E2_PARCELA
					SE5->E5_TIPO    	:= SE2->E2_TIPO
					SE5->E5_CLIFOR  	:= SE2->E2_FORNECE
					SE5->E5_LOJA    	:= SE2->E2_LOJA
					SE5->E5_VALOR   	:= _nTotFob
					SE5->E5_VLMOED2 	:= Round(_nTotFob/xVet[1],2)
					SE5->E5_DATA    	:= dDataBase
					SE5->E5_NATUREZ 	:= SE2->E2_NATUREZ
					SE5->E5_RECPAG  	:= "P"
					SE5->E5_TIPODOC 	:= "VM"
					SE5->E5_LA      	:= "S"
					SE5->E5_DTDIGIT 	:= dDataBase
					SE5->E5_DTDISPO 	:= dDataBase
					SE5->E5_HISTOR  	:= "CORREC MONET "+Iif(cxLanc $ "XX1,XX2,XX3","ENTREPOSTO","REG D.I.")
					SE5->(MsUnlock())
				EndIf

			EndIf

		EndIf


		If cLancOld == "UZG"
			Processa({ || aCtbDesp := U_UzDespDA(SW6->W6_HAWB,"CTB") })

			For gt := 1 To Len(aCtbDesp)
				IncProc("Contabilizando Despesa de DA...")
				SE2->(dbGoTo(aCtbDesp[gt,1]))
				SA2->(dbSeek(xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA)))
				_nTotFob := aCtbDesp[gt,2]
				If xTip == "E"
					_UzHistEntrep := "TRANSF. DESPESA PE: "+Alltrim(SW6->W6_HAWB)+" P/  DA: 0"+SubStr(Alltrim(SW6->W6_HAWB),2,5)+": "+aCtbDesp[gt,3]
					xcCVDed  := U_UZCCusto("ENT")
					xcCVCred := U_UZCCusto("ENT","UZG")
				Else
					_UzHistEntrep := "TRANSF. DESPESA DA: "+SubStr(Alltrim(SW6->W6_HAWB),2,5)+" P/ PE: 0"+Alltrim(SW6->W6_HAWB)+": "+aCtbDesp[gt,3]
					xcCVDed  := U_UZCCusto("ENT","UZG")
					xcCVCred := U_UZCCusto("ENT")
				EndIf
				If !lHead
					lHead   := .T.
					nHdlPrv := HeadProva(cLote,"CONTGD01",Subs(cUsuario,7,6),@cArquivo)
				EndIf
				nTotal += DetProva(nHdlPrv,"UZH","CONTGD01",cLote)
			Next
		EndIf

	End Transaction

Return
*******************************************************************************
Static Function RdProvaFim()
*******************************************************************************

	IF lHead .And. lFim
		RodaProva(nHdlPrv,nTotal)
		cA100Incl(cArquivo,nHdlPrv,3,cLote,lMostra,lAglut)
	Endif


Return()
//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: UzTxCorr
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 02 de Março de 2011 - 10:30
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 10.11
//|Descricao.: Grava a Taxa de Correção caso tenha sido apagada
//|Observação:
//+-----------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function UzTxCorr(xVet)
*----------------------------------------------*

	Begin Transaction

		SE2->(dbSetOrder(1))
		For gt := 1 To Len(xVet)
			IncProc("Analisando Variações...")
			If SE2->(dbSeek(xVet[gt,4]))
				SE2->(RecLock("SE2",.F.))
				SE2->E2_DTVARIA := xVet[gt,3]
				SE2->E2_TXMDCOR := xVet[gt,2]
				SE2->(MsUnLock())
			EndIf
		Next

	End Transaction

Return

//+------------------------------------------------------------------------------------//
//|Fim do programa UZCONT01.PRW
//+------------------------------------------------------------------------------------//