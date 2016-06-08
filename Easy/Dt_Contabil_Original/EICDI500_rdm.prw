#INCLUDE "Rwmake.ch"
#INCLUDE "Average.ch"
#INCLUDE "TOPCONN.CH"


//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa Rolamentos
//|Funcao....: U_EICDI500()
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 30 de Junho de 2009 - 08:00
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 8.11
//|Descricao.: Contem todos pontos de entradas do EICDI500 e funcoes para
//|            tratamento de contabilização em Transito
//|Observação:
//+------------------------------------------------------------------------------------//

*********************************************************************
User Function EICDI500()
*********************************************************************

	Local aDespUso    	:= {}


	Static dDtEmbOld  	:= CtoD("")
	Static dDtDIOld   	:= CtoD("")
	Static dxDtEmbMe  	:= CtoD("")
	Static dxDTDIMe   	:= CtoD("")
	Static dxDtCorFre 	:= CtoD("")
	Static dxDtCorSeg 	:= CtoD("")

	Static nValInvOld	:= 0
	Static nValInvNew	:= 0

	Static nxTxCorFre 	:= 0
	Static nxTxCorSeg 	:= 0
	Static nxValFreBD	:= 0
	Static nxValSegBD 	:= 0
	Static nxValFreMe 	:= 0
	Static nxValSegMe 	:= 0
	Static nxTXFre    	:= 0
	Static nxTXSeg    	:= 0
	Static nxValIv14  	:= 0
	Static nxValIv02  	:= 0
	Static nTxEntrep  	:= 0
	Static axInvs     	:= {}
	Static axTxOld    	:= {}

	Static cxTpProc   := ""

	Do Case

	//|Parametro..: "TELA_DESP"
	//|Descricao..: Realiza Compensação automatica

	Case ParamIxb == "TELA_DESP"
		//Alert( "Entrou Avisar TI TELA_DESP")

		If Ascan(aBotoesDesp,{|x|x[1]=="PENDENTE"}) == 0
			If cNivel >= 6
				Aadd( aBotoesDesp,{ "PENDENTE", {|| U_UzCompAuto("I")}, "Compensação Automatica","Comp.Automatica" } )
			EndIf
		Endif

	//|Parametro..: "VALID_PEDIDO_PLI"
	//|Descricao..: Valida o Tipo de Pedido no processo

	Case ParamIXB == "VALID_PEDIDO_PLI"

		If M->W6_TIPOEMB <> "1"
			lValidPOPLI := U_UzmForn("TIPO")
		Endif


	//|Parametro..: "RAVA_ANTES_SW6"
	//|Descricao..: Arruma despesas vindas da DA

	Case ParamIXB == "GRAVA_ANTES_SW6"

		If MOpcao == "3" .AND. Alltrim(M->W6_TIPODES) == "14"
			If Len(adespda) > 0
				aDespUso  := adespda
				adespda   := {}
				For kui := 1 To Len(aDespUso)
					If SubStr(aDespUso[kui,1],1,1) <> "9"
						aAdd(adespda,aDespUso[kui])
					EndIf
				Next
			EndIf
			M->W6_CONDP_F 	:= ""
			M->W6_FORNECF 	:= ""
			M->W6_LOJAF   	:= ""
			M->W6_DIASP_F 	:= 0
			M->W6_VENCFRE 	:= CtoD("")
			M->W6_CONDP_S 	:= ""
			M->W6_FORNECS 	:= ""
			M->W6_LOJAS   	:= ""
			M->W6_DIASP_S 	:= 0
			M->W6_VENCSEG 	:= CtoD("")
			M->W6_CORRETO 	:= ""
		EndIf


	//| Parametro..: "ANT_GRAVA_CAPA" E "ANT_GRAVA_TUDO"
	//| Descricao..: Utilizada antes da gração da capa e de todo o Embarque/Desembaraço
	//| para contabilização de transito de Invoice, Seguro e Frete

	Case ParamIxb == "ANT_GRAVA_CAPA"  .Or. ParamIxb == "ANT_GRAVA_TUDO"
		nxValIv14	:= 0
		nxValIv02 	:= 0
		nTxEntrep 	:= 0
		//axInvs    := {}
		axTxOld   	:= {}

	  // Alert("Entrou 1 Adcontabil")
		AdContabi(ParamIxb) // ENTROU 1 CRISTIANO


	//|Parametro..: "POS_GRAVA_TUDO" E "POS_GRAVA_CAPA"
	//|Descricao..: Utilizada depois da gração da capa e de todo o Embarque/Desembaraço
	//|             para contabilização e amarração das despesas do pedido

	Case ParamIxb == "POS_GRAVA_TUDO" .OR. ParamIxb == "POS_GRAVA_CAPA"

		nValInvNew  := SW6->W6_FOB_TOT

		If Alltrim(SW6->W6_TIPODES) == "14" // Entreposto
			Processa({ || U_UzDespDA(SW6->W6_HAWB) })
		EndIf

		U_UZPREEIC()
		//Alert("Entrou 2 Adcontabil")
		AdContabi(ParamIxb)

		//| Localiza Titulo de invoice e grava os valores da ultima var Cambial...Esta Informacao nao pode ser perdida...pela exclusao e criacao do titulo...
		SlvTxCamb()

		//nValInvNew  := 0

	Case ParamIxb == "EXEC_ESTORNO_B"

		//Alert("Entrou 3 Adcontabil")
		AdContabi(ParamIxb)


	//|Parametro..: "FINAL_OPCAO"
	//|Descricao..: Confirma numeração dos titulos

	Case ParamIxb == "FINAL_OPCAO"
		If nOPC_mBrw <> 2 .AND. nOpca <> 0

			U_UZPREEIC()

			If nOPC_mBrw <> 5 .AND. cxTpProc <> "14"
				U_UZCONT02(dDtDIOld,dxDTDIMe,nxValFreBD,nxValFreMe,nxValSegBD,nxValSegMe,dxDtEmbMe,dDtEmbOld,nxTXSeg,nxTXFre)
			EndIf
		EndIf


	//|Parametro..: "CTRL_DI"
	//|Descricao..: Utilizada para numeração automatica do Processo

	Case ParamIxb == "CTRL_DI"

        	//|Inserido por Edivaldo/Márcio,novo formato de atribuição do número do processo de
        	//|importação
        	//|Utilizado para sugerir a numeracao automatica somente com as ultimas 6 posicoes e nao as 17

		If nOPC_mBrw == 3

	        //|Para processos de entreposto

			If Alltrim(M->W6_TIPODES) == "14"
				cQuery := " SELECT W2_HAWB_DA FROM "+RetSqlName("SW2")+" WHERE  W2_FILIAL = '"+xFilial("SW2")+"' AND "
				cQuery += " W2_PO_NUM = '"+WORK->WKPO_NUM+"' "
				Iif(Select("PROUSE") # 0,PROUSE->(dbCloseArea()),.T.)
				TCQuery cQuery NEW ALIAS "PROUSE"
				dbSelectArea("PROUSE")
				cProUse := Alltrim(SubStr(PROUSE->W2_HAWB_DA,2,Len(PROUSE->W2_HAWB_DA)))
				PROUSE->(dbCloseArea())

				cQuery := " SELECT MAX(W6_HAWB) AS NOVOPROC FROM "+RetSqlName("SW6")+" WHERE  W6_FILIAL = '"+xFilial("SW6")+"' "
				cQuery += " AND W6_HAWB LIKE "+"('%"+cProUse+"%') "
				Iif(Select("XZZX") # 0,XZZX->(dbCloseArea()),.T.)
				TcQuery cQuery New Alias "XZZX"
				XZZX->(dbSelectArea("XZZX"))

				If SubStr(XZZX->NOVOPROC,1,1) == "0"
					cProUse := "A"+cProUse
				Else
					cProUse := Soma1(SubStr(XZZX->NOVOPROC,1,1))+cProUse
				EndIf
				XZZX->(dbCloseArea())

				M->W6_HAWB := cProUse

			Else

		      //| Para processos normais
				cQuery := " SELECT MAX(SUBSTR(W6_HAWB,2,6)) AS MAXID FROM "+RetSqlName("SW6")+"  "
				Iif(Select("MAX_W6") # 0,MAX_W6->(dbCloseArea()),.T.)
				TCQuery cQuery NEW ALIAS "MAX_W6"
				dbSelectArea("MAX_W6")

				M->W6_HAWB := "0"+Soma1(Alltrim(MAX_W6->MaxID))
				MAX_W6->(dbCloseArea())
			EndIf

		EndIf

	EndCase

Return .T.


//|Empresa...: Imdepa Rolamentos
//|Funcao....: AdContabi()
//|Autor.....: Armando M. Urzum - armando@afill.com.br
//|Data......: 17 de agosto de 2011 - 18:00
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 10
//|Descricao.: Analise de contabilização de Transito de importação
//|Observação:

*********************************************************************
Static Function AdContabi(xPar)
*********************************************************************

	Local aAreUs := GetArea()


	If xPar == "ANT_GRAVA_CAPA"  .OR. xPar == "ANT_GRAVA_TUDO" .OR. xPar == "EXEC_ESTORNO_B"

		cxTpProc   	:= Alltrim(M->W6_TIPODES) // ENTROU 1 CRISTIANO
		dDtEmbOld  	:= Iif(nOPC_mBrw <> 3,SW6->W6_DT_EMB,CtoD(""))
		dDtDIOld   	:= Iif(nOPC_mBrw <> 3,SW6->W6_DTREG_D,CtoD(""))
		nxValFreBD 	:= Iif(nOPC_mBrw <> 3,(SW6->W6_VLFRECC+SW6->W6_VLFREPP)*SW6->W6_TX_FRET,0)
		nxValSegBD 	:= Iif(nOPC_mBrw <> 3,SW6->W6_VLSEGMN,0)
		dxDTDIMe   	:= M->W6_DTREG_D
		nxValFreMe 	:= (M->W6_VLFRECC+M->W6_VLFREPP)*M->W6_TX_FRET
		nxValSegMe	 	:= M->W6_VLSEGMN
		dxDtEmbMe  	:= M->W6_DT_EMB

		nValInvOld  := Iif(nOPC_mBrw <> 3,SW6->W6_FOB_TOT,0)

		nxTXFre    	:= 0
		nxTXSeg    	:= 0
		nxTxCorFre 	:= 0
		nxTxCorSeg 	:= 0
		dxDtCorFre 	:= CtoD("")
		dxDtCorSeg 	:= CtoD("")

		SE2->(dbSetOrder(1)) // ???? CAMPOS VAZIUS
		If SE2->(dbSeek(xFilial("SE2")+M->W6_PREFIXF+M->W6_NUMDUPF+M->W6_PARCELF+M->W6_TIPOF+M->W6_FORNECF+M->W6_LOJAF))
			nxTXFre  	:= SE2->E2_TXMDCOR
			dxDtCorFre	:= SE2->E2_DTVARIA
			nxTxCorFre	:= SE2->E2_TXMDCOR
		EndIf

		//SE2->(dbSetOrder(1))
		If SE2->(dbSeek(xFilial("SE2")+M->W6_PREFIXS+M->W6_NUMDUPS+M->W6_PARCELS+M->W6_TIPOS+M->W6_FORNECS+M->W6_LOJAS))
			nxTXSeg   	:= SE2->E2_TXMDCOR
			dxDtCorSeg	:= SE2->E2_DTVARIA
			nxTxCorSeg	:= SE2->E2_TXMDCOR
		EndIf
	//	axInvs := {}
	EndIf

	If nOPC_mBrw == 5
		dxDTDIMe  		:= CtoD("")
		dxDtEmbMe 		:= CtoD("")
		nValInvNew 	:= 0
	EndIf

	If nOPC_mBrw <> 5
		//axInvs := {}
	EndIf
	nRecWork9 := SW9->(RecNo())
	SE2->(dbSetOrder(1))
	SW9->(dbSetOrder(3))
	SWB->(dbSetOrder(1))
	SW9->(dbGoTop())
	If nOPC_mBrw <> 3
		WORK_SW9->(dbGoTo(1))
	EndIf

	If nOPC_mBrw == 3  .AND. (xPar == "ANT_GRAVA_CAPA" .OR. xPar == "ANT_GRAVA_TUDO") .AND. cxTpProc <> "14"

		nRecWork9 := SW9->(RecNo())
		WORK_SW9->(dbGoTo(1))
		SW9->(dbSetOrder(3))
		SWB->(dbSetOrder(1))
		SW9->(dbGoTop())
		M->W6_HAWB := M->W6_HAWB+Space(11)
		If SW9->(dbSeek(xFilial("SW9")+M->W6_HAWB))
			While SW9->(!EOF()) .AND. SW9->(W9_FILIAL+W9_HAWB) == (xFilial("SW9")+M->W6_HAWB)
				cSeekW9 := xFilial("SWB")+M->W6_HAWB+"D"+SW9->W9_INVOICE+SW9->W9_FORN+SW9->W9_FORLOJ
				If SWB->(dbSeek(cSeekW9))
					While SWB->(!EOF()) .AND. SWB->(WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA) == cSeekW9
						If !SE2->(dbSeek(xFilial("SE2")+"EIC"+SWB->WB_NUMDUP+SWB->WB_PARCELA+"INV"+SWB->WB_FORN+SWB->WB_LOJA))
							SWB->(dbSkip())
							Loop
						Else
							aAdd(axTxOld,SW9->W9_TX_FOB)
						EndIf
						SWB->(dbskip())
					EndDo
				EndIf
				SW9->(dbSkip())
			EndDo
		EndIf

	ElseIf nOPC_mBrw <> 3  .AND. (xPar == "ANT_GRAVA_CAPA" .OR. xPar == "ANT_GRAVA_TUDO")

		nRecWork9 := SW9->(RecNo())
		nRecWork6 := SW6->(RecNo())
		WORK_SW9->(dbGoTo(1))
		SW9->(dbSetOrder(3))
		SWB->(dbSetOrder(1))
		SW9->(dbGoTop())
		If SW9->(dbSeek(xFilial("SW9")+M->W6_HAWB))
			While SW9->(!EOF()) .AND. SW9->(W9_FILIAL+W9_HAWB) == (xFilial("SW9")+M->W6_HAWB)
				If cxTpProc <> "14"
					cSeekW9 := xFilial("SWB")+M->W6_HAWB+"D"+SW9->W9_INVOICE+SW9->W9_FORN+SW9->W9_FORLOJ
					If SWB->(dbSeek(cSeekW9))
						While SWB->(!EOF()) .AND. SWB->(WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA) == cSeekW9
							If SE2->(dbSeek(xFilial("SE2")+"EIC"+SWB->WB_NUMDUP+SWB->WB_PARCELA+"INV"+SWB->WB_FORN+SWB->WB_LOJA))
								If SWB->WB_TIPOREG <> 'P'
									aAdd(axInvs,{SW9->W9_TX_FOB,Iif(SW6->W6_TX_VCAM<>0,SW6->W6_TX_VCAM,SE2->E2_TXMOEDA),W6_DT_VCAM,;
										xFilial("SE2")+"EIC"+SWB->WB_NUMDUP+SWB->WB_PARCELA+"INV"+SWB->WB_FORN+SWB->WB_LOJA,SWB->WB_FOBMOE+SWB->WB_PGTANT})// SE2->E2_VALOR})
									aAdd(axTxOld,SW9->W9_TX_FOB)
								EndIf
							EndIf
							SWB->(dbskip())
						EndDo
					EndIf
				Else
					nxValIv14 += WORK_SW9->W9_FOB_TOT
					nTxEntrep := WORK_SW9->W9_TX_FOB
					aAdd(axTxOld,SW9->W9_TX_FOB)
				EndIf
				SW9->(dbSkip())
			EndDo
		EndIf

		If cxTpProc == "14"	.AND. !Empty(nxValIv14)
			nQtdUse := 0
			cxProcUse := "0"+Alltrim(SubStr(M->W6_HAWB,2,5))+Space(11)
			If SW9->(dbSeek(xFilial("SW9")+cxProcUse))
				While SW9->(!EOF()) .AND. SW9->(W9_FILIAL+W9_HAWB) == (xFilial("SW9")+cxProcUse)
					cSeekW9 := xFilial("SWB")+cxProcUse+"D"+SW9->W9_INVOICE+SW9->W9_FORN+SW9->W9_FORLOJ
					If SWB->(dbSeek(cSeekW9))
						While SWB->(!EOF()) .AND. SWB->(WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA) == cSeekW9
							If SE2->(dbSeek(xFilial("SE2")+"EIC"+SWB->WB_NUMDUP+SWB->WB_PARCELA+"INV"+SWB->WB_FORN+SWB->WB_LOJA))
								If SWB->WB_TIPOREG <> 'P'
									aAdd(axInvs,{SW9->W9_TX_FOB,Iif(SW6->W6_TX_VCAM<>0,SW6->W6_TX_VCAM,SE2->E2_TXMOEDA),SW6->W6_DT_VCAM,;
										xFilial("SE2")+"EIC"+SWB->WB_NUMDUP+SWB->WB_PARCELA+"INV"+SWB->WB_FORN+SWB->WB_LOJA,SWB->WB_FOBMOE+SWB->WB_PGTANT})//SE2->E2_VALOR})
									nQtdUse++
								EndIf
							EndIf
							SWB->(dbskip())
						EndDo
					EndIf
					SW9->(dbSkip())
				EndDo
			EndIf
/*
			If Len(axInvs) > 0
				For hj := 1 To Len(axInvs)
					nxValIv02 += axInvs[hj,5]
				Next
				For hj := 1 To Len(axInvs)
					axInvs[hj,5] := (nxValIv14/nxValIv02)*axInvs[hj,5]
				Next
			EndIf

			If nQtdUse > Len(axTxOld)
				For kl := Len(axTxOld) To nQtdUse
					aAdd(axTxOld,axTxOld[1])
				Next
			EndIf
*/
		EndIf

		SW9->(dbGoTo(nRecWork9))
		SW6->(dbGoTo(nRecWork6))

	ElseIf nOPC_mBrw == 3 .OR. nOPC_mBrw == 4 .OR. nOPC_mBrw == 5

		nRecWork6 := SW6->(RecNo())
		nRecWork9 := SW9->(RecNo())

		If SW9->(dbSeek(xFilial("SW9")+SW6->W6_HAWB))
			If cxTpProc == "14" .AND. (nOPC_mBrw == 3 .OR. nOPC_mBrw == 5)
				nTxEntrep := SW9->W9_TX_FOB
			EndIf
			While SW9->(!EOF()) .AND. SW9->(W9_FILIAL+W9_HAWB) == (xFilial("SW9")+SW6->W6_HAWB)
				If cxTpProc <> "14"
					cSeekW9 := xFilial("SWB")+SW6->W6_HAWB+"D"+SW9->W9_INVOICE+SW9->W9_FORN+SW9->W9_FORLOJ
					If SWB->(dbSeek(cSeekW9))
						While SWB->(!EOF()) .AND. SWB->(WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA) == cSeekW9
							If SE2->(dbSeek(xFilial("SE2")+"EIC"+SWB->WB_NUMDUP+SWB->WB_PARCELA+"INV"+SWB->WB_FORN+SWB->WB_LOJA))
								If SWB->WB_TIPOREG <> 'P'
									aAdd(axInvs,{ SW9->W9_TX_FOB , Iif(SW6->W6_TX_VCAM<>0,SW6->W6_TX_VCAM,SE2->E2_TXMOEDA),W6_DT_VCAM,;
										xFilial("SE2")+"EIC"+SWB->WB_NUMDUP+SWB->WB_PARCELA+"INV"+SWB->WB_FORN+SWB->WB_LOJA , SWB->WB_FOBMOE+SWB->WB_PGTANT})//SE2->E2_VALOR})
								EndIf
							EndIf
							SWB->(dbskip())
						EndDo
					EndIf
				ElseIf (nOPC_mBrw == 3 .OR. nOPC_mBrw == 5) .AND. cxTpProc == "14"
					nxValIv14 += SW9->W9_FOB_TOT
				EndIf
				SW9->(dbSkip())
			EndDo
		EndIf

		If cxTpProc == "14"	.AND. !Empty(nxValIv14)
			cxProcUse := "0"+Alltrim(SubStr(M->W6_HAWB,2,5))+Space(11)
			nQtdUse := 0
			If SW9->(dbSeek(xFilial("SW9")+cxProcUse))
				While SW9->(!EOF()) .AND. Alltrim(SW9->(W9_FILIAL+W9_HAWB)) == Alltrim(xFilial("SW9")+cxProcUse)
					cSeekW9 := xFilial("SWB")+cxProcUse+"D"+SW9->W9_INVOICE+SW9->W9_FORN+SW9->W9_FORLOJ
					If SWB->(dbSeek(cSeekW9))
						While SWB->(!EOF()) .AND. SWB->(WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA) == cSeekW9
							If SE2->(dbSeek(xFilial("SE2")+"EIC"+SWB->WB_NUMDUP+SWB->WB_PARCELA+"INV"+SWB->WB_FORN+SWB->WB_LOJA))
								If SWB->WB_TIPOREG <> 'P'
									aAdd(axInvs,{ nTxEntrep , Iif(SW6->W6_TX_VCAM<>0,SW6->W6_TX_VCAM,SE2->E2_TXMOEDA),W6_DT_VCAM,;
										xFilial("SE2")+"EIC"+SWB->WB_NUMDUP+SWB->WB_PARCELA+"INV"+SWB->WB_FORN+SWB->WB_LOJA,SWB->WB_FOBMOE+SWB->WB_PGTANT})//SE2->E2_VALOR})
									nQtdUse++
								EndIf
							EndIf
							SWB->(dbskip())
						EndDo
					EndIf
					SW9->(dbSkip())
				EndDo
			EndIf
/*
			If Len(axInvs) > 0
				nxValIv02 := 0
				For hj := 1 To Len(axInvs)
					nxValIv02 += axInvs[hj,5]
				Next
				For hj := 1 To Len(axInvs)
					axInvs[hj,5] := (nxValIv14/nxValIv02)*axInvs[hj,5]
				Next
			EndIf
*/
		EndIf

		SW9->(dbGoTo(nRecWork9))
		SW6->(dbGoTo(nRecWork6))

	EndIf



	//If nOPC_mBrw <> 5 .And. ( xPar == "ANT_GRAVA_CAPA" .OR. xPar == "ANT_GRAVA_TUDO")
//		Iif(Len(axInvs) > 0,U_UZCONT01(dDtDIOld,dxDTDIMe,dDtEmbOld,dxDtEmbMe,axInvs,cxTpProc,axTxOld,nValInvOld,nValInvNew),.T.)

	If nOPC_mBrw <> 5 .AND. xPar == "POS_GRAVA_TUDO" .OR. xPar == "POS_GRAVA_CAPA"
		Iif(Len(axInvs) > 0,U_UZCONT01(dDtDIOld,dxDTDIMe,dDtEmbOld,dxDtEmbMe,axInvs,cxTpProc,axTxOld,nValInvOld,nValInvNew),.T.)
		axInvs := {}
	ElseIf nOPC_mBrw == 5  .AND. xPar == "EXEC_ESTORNO_B"
		Iif(Len(axInvs) > 0,U_UZCONT01(dDtDIOld,dxDTDIMe,dDtEmbOld,dxDtEmbMe,axInvs,cxTpProc,axTxOld,nValInvOld,nValInvNew),.T.)
		Iif(cxTpProc <> "14",U_UZCONT02(dDtDIOld,dxDTDIMe,nxValFreBD,nxValFreMe,nxValSegBD,nxValSegMe,dxDtEmbMe,dDtEmbOld,nxTXSeg,nxTXFre),.T.)
		axInvs := {}
	EndIf


	RestArea(aAreUs)

Return
*******************************************************************************
Static function SlvTxCamb() //| Restaura informa›es no Titulo... Taxa Cambio, Data Contabiliza‹o e etc...
*******************************************************************************

	//| Cristiano Machado  -  2014/04/08
	//| Correcao Variacao Cambial
	//| Localiza Titulo de invoice e grava os valores da ultima var Cambial...
	//| Esta Informacao nao pode ser perdida...pela exclusao e criacao do titulo...
   
	cUpdt := " Update SE2010 Set " 
	cUpdt += " E2_TXMDCOR 		= "	 + cValToChar(SW6->W6_TX_VCAM)	+ ", "
	cUpdt += " E2_DTVARIA 		= '"	 + Dtos(SW6->W6_DT_VCAM)				+ "', "
	cUpdt += " E2_EMIS1 			= '"	 + Dtos(SW6->W6_DTCTEMB)				+ "' "
	
	//Alert("nValInvOld: " + cValtoChar(nValInvOld)+ " nValInvNew:" + cValtoChar(nValInvNew) )
	
	If ( nValInvOld <> nValInvNew .And. nValInvOld <> 0 .And. nValInvNew <> 0 )
		cUpdt += ", E2_HIST 			= 'P: " + Alltrim(SW9->W9_HAWB) + " " + Alltrim(SW9->W9_INVOICE) + " " + SW9->W9_FORN + SW9->W9_FORLOJ + " *** VLR. ALTERADO'"   //TRIM(E2_HIST)  || ' VALOR ALTERADO' "
	EndIf
	
	cUpdt += " Where E2_FILIAL 	= ' ' "
	cUpdt += " And E2_PREFIXO  	= 'EIC' "
	cUpdt += " And E2_NUM      	= '"+SW6->W6_HAWB+"' "
	cUpdt += " And E2_TIPO     	= 'INV' "
	cUpdt += " And D_E_L_E_T_  	= ' ' "

	U_ExecMySql(cUpdt , "" , "E" , .F.)

Return()


