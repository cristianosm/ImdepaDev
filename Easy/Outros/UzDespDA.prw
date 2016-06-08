#INCLUDE "Rwmake.ch"
#INCLUDE "Average.ch"
#INCLUDE "TOPCONN.CH"

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa Rolamentos
//|Funcao....: UzDespDA
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 01 de Novembro de 2011 - 08:00
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 10
//|Descricao.: Realiza rateio correto das despesas para a DA
//|Observação:
//+------------------------------------------------------------------------------------//
*----------------------------------------------*
User Function UzDespDA(xProc,xTp)
*----------------------------------------------* 

Local cSql   := ""
Local cDespN := "101,102,103,201,202,203,901,902,903"
Local nValDA := 0
Local nValDI := 0
Local nValUsa:= 0
Local nValDes:= 0
Local nDesUso:= 0
Local nQtdPrc:= 0
Local nValAnt:= 0
Local cNull  := "NVL"
Local cSubSt := "SUBSTR" 
Local cProOri:= "0"+SubStr(Alltrim(xProc),2,6)
Local cProcDI:= xProc
Local nPesoDA:= Posicione("SW6",1,xFilial("SW6")+cProOri,"W6_PESOL")
Local nPesoDI:= Posicione("SW6",1,xFilial("SW6")+cProcDI,"W6_PESOL")
Local aRetCon:= {}

ProcRegua(0)
IncProc("Analisando Despesas...")

//+-----------------------------------------------------------------------------------//
//|Quantidade de Processos de Nacionalização
//+-----------------------------------------------------------------------------------//
cSql := " SELECT COUNT(W6_HAWB) AS QTDE FROM "+RetSqlName("SW6") 
cSql += " WHERE D_E_L_E_T_ <> '*' AND W6_HAWB LIKE '%"+SubStr(Alltrim(xProc),2,6)+"%' "
cSql += " AND "+cSubSt+"(W6_HAWB,1,1) <> '0' " 
cSql += " AND "+cSubSt+"(W6_HAWB,1,1) < '"+SubStr(Alltrim(xProc),1,1)+"'  
Iif(Select("VAL1X") # 0,VAL1X->(dbCloseArea()),.T.)
TCQuery cSql NEW ALIAS "VAL1X"
nQtdPrc := VAL1X->QTDE
VAL1X->(dbCloseArea())

//+-----------------------------------------------------------------------------------//
//|Verifica valor de processos anteriores
//+-----------------------------------------------------------------------------------//
cSql := " SELECT "+cNull+"(SUM(W9_FOB_TOT),0) AS TOTUSO FROM "+RetSqlName("SW9")
cSql += " WHERE D_E_L_E_T_ <> '*' AND W9_FILIAL = '"+xFilial("SW9")+"' "
cSql += " AND W9_HAWB LIKE '%"+SubStr(Alltrim(xProc),2,6)+"%' "
cSql += " AND "+cSubSt+"(W9_HAWB,1,1) <> '0' " 
cSql += " AND "+cSubSt+"(W9_HAWB,1,1) < '"+SubStr(Alltrim(xProc),1,1)+"'  
Iif(Select("VAL1X") # 0,VAL1X->(dbCloseArea()),.T.)
TCQuery cSql NEW ALIAS "VAL1X"
nValAnt := VAL1X->TOTUSO
VAL1X->(dbCloseArea())

//+-----------------------------------------------------------------------------------//
//|Verifica valor da DA
//+-----------------------------------------------------------------------------------//
cSql := " SELECT "+cNull+"(SUM(W9_FOB_TOT),0) AS TOTUSO FROM "+RetSqlName("SW9")
cSql += " WHERE D_E_L_E_T_ <> '*' AND W9_FILIAL = '"+xFilial("SW9")+"' "
cSql += " AND W9_HAWB = '"+cProOri+"' "
Iif(Select("VAL1X") # 0,VAL1X->(dbCloseArea()),.T.)
TCQuery cSql NEW ALIAS "VAL1X"
nValDA := VAL1X->TOTUSO
VAL1X->(dbCloseArea())

//+-----------------------------------------------------------------------------------//
//|Verifica valor da DI
//+-----------------------------------------------------------------------------------//
cSql := " SELECT "+cNull+"(SUM(W9_FOB_TOT),0) AS TOTUSO FROM "+RetSqlName("SW9")
cSql += " WHERE D_E_L_E_T_ <> '*' AND W9_FILIAL = '"+xFilial("SW9")+"' "
cSql += " AND W9_HAWB = '"+Alltrim(xProc)+"' "
Iif(Select("VAL1X") # 0,VAL1X->(dbCloseArea()),.T.)
TCQuery cSql NEW ALIAS "VAL1X"
nValDI := VAL1X->TOTUSO
VAL1X->(dbCloseArea())

SWD->(dbSetOrder(1))
If SWD->(dbSeek(xFilial("SWD")+xProc))
	While SWD->(!EOF()) .AND. SWD->(WD_FILIAL+WD_HAWB) == (xFilial("SWD")+xProc)
		
		IncProc("Analisando Despesas...")
		
		nValDes := 0
		nDesUso := 0
		nValUsa := 0
		nNovoVal:= 0 
		SWD->WD_VALOR_R
		
		If !SWD->WD_DESPESA $ cDespN .AND. Alltrim(SWD->WD_DA) == "1" .AND. Empty(Alltrim(SWD->WD_NF_COMP))
			
			//+-----------------------------------------------------------------------------------//
			//|Valor da Despesa no While
			//+-----------------------------------------------------------------------------------//
			cSql := " SELECT "+cNull+"(SUM(WD_VALOR_R),0) AS VALORI FROM "+RetSqlName("SWD")
			cSql += " WHERE D_E_L_E_T_ <> '*' AND WD_FILIAL = '"+xFilial("SWD")+"' "
			cSql += " AND WD_HAWB = '"+cProOri+"' "
			cSql += " AND WD_DESPESA = '"+SWD->WD_DESPESA+"' AND WD_DES_ADI = '"+DtoS(SWD->WD_DES_ADI)+"' "
			Iif(Select("VAL1X") # 0,VAL1X->(dbCloseArea()),.T.)
			TCQuery cSql NEW ALIAS "VAL1X"
			nValDes := VAL1X->VALORI
			VAL1X->(dbCloseArea())

			//+-----------------------------------------------------------------------------------//
			//|Acha o Recno no SE2
			//+-----------------------------------------------------------------------------------//
			cSql := " SELECT E2.R_E_C_N_O_ AS RECUSO FROM "+RetSqlName("SE2")+" E2 "
			cSql += " JOIN "+RetSqlName("SWD")+" WD ON E2.E2_NUM = WD.WD_CTRFIN1 AND E2.E2_PARCELA = WD.WD_PARCELA AND E2.E2_PREFIXO = WD.WD_PREFIXO AND "
			cSql += " 		E2.E2_TIPO = WD.WD_TIPO AND E2.E2_FORNECE = WD.WD_FORN AND E2.E2_LOJA = WD.WD_LOJA AND "
			cSql += "       WD.WD_HAWB = '"+cProOri+"' AND WD.WD_DESPESA = '"+SWD->WD_DESPESA+"' AND WD.WD_DES_ADI = '"+DtoS(SWD->WD_DES_ADI)+"' AND "
			cSql += "       WD.D_E_L_E_T_ <> '*' AND WD.WD_FILIAL = '"+xFilial("SWD")+"' "
			cSql += "       WHERE E2.D_E_L_E_T_ <> '*' "
			Iif(Select("VAL1X") # 0,VAL1X->(dbCloseArea()),.T.)
			TCQuery cSql NEW ALIAS "VAL1X"
			aAdd(aRetCon,{VAL1X->RECUSO,0,Alltrim(Posicione("SYB",1,xFilial("SYB")+SWD->WD_DESPESA,"YB_DESCR"))})
			VAL1X->(dbCloseArea())

			//+-----------------------------------------------------------------------------------//
			//|Quantidade de Processos no qual existe a despesa
			//+-----------------------------------------------------------------------------------//
			cSql := " SELECT COUNT(WD_HAWB) AS QTDE FROM "+RetSqlName("SWD")
			cSql += " WHERE D_E_L_E_T_ <> '*' AND WD_HAWB LIKE '%"+SubStr(Alltrim(xProc),2,6)+"%' "
			cSql += " AND "+cSubSt+"(WD_HAWB,1,1) <> '0' "
			cSql += " AND "+cSubSt+"(WD_HAWB,1,1) < '"+SubStr(Alltrim(xProc),1,1)+"' "
			cSql += " AND WD_DESPESA = '"+SWD->WD_DESPESA+"' AND WD_DES_ADI = '"+DtoS(SWD->WD_DES_ADI)+"' AND WD_DA = '1'
			Iif(Select("VAL1X") # 0,VAL1X->(dbCloseArea()),.T.)
			TCQuery cSql NEW ALIAS "VAL1X"
			nDesUso := VAL1X->QTDE
			VAL1X->(dbCloseArea())
			
			If nDesUso == nQtdPrc
				If Alltrim(Posicione("SYB",1,xFilial("SYB")+SWD->WD_DESPESA,"YB_RATPESO")) == "1"
					nNovoVal := (nValDes/nPesoDA)*nPesoDI
				Else
					nNovoVal := (nValDes/nValDA)*nValDI
				EndIf
			Else
				If Alltrim(Posicione("SYB",1,xFilial("SYB")+SWD->WD_DESPESA,"YB_RATPESO")) == "1"
					cSql := " SELECT A.W6_PESOL AS TOTAL, A.W6_HAWB FROM "+RetSqlName("SW6")+" A "
					cSql += " JOIN "+RetSqlName("SWD")+" B ON B.WD_HAWB = A.W6_HAWB AND B.WD_DESPESA <> '"+SWD->WD_DESPESA+"' "
					cSql += " AND B.WD_DES_ADI <> '"+DtoS(SWD->WD_DES_ADI)+"' AND B.WD_DA <> '1' AND B.D_E_L_E_T_ <> '*' AND B.WD_FILIAL = '"+xFilial("SWD")+"' "
					cSql += " WHERE A.D_E_L_E_T_ <> '*' AND A.W6_FILIAL = '"+xFilial("SW6")+"' AND "+cSubSt+"(A.W6_HAWB,1,1) NOT IN ('0','"+SubStr(Alltrim(xProc),1,1)+"') "
					cSql += " AND A.W6_HAWB LIKE '%"+SubStr(Alltrim(xProc),2,6)+"%' "
					cSql += " GROUP BY A.W6_PESOL, A.W6_HAWB "
					Iif(Select("VAL1X") # 0,VAL1X->(dbCloseArea()),.T.)
					TCQuery cSql NEW ALIAS "VAL1X"
					VAL1X->(dbGoTop())
					While VAL1X->(!EOF())
						nValUsa += VAL1X->TOTAL
						VAL1X->(dbSkip())
					EndDo
					VAL1X->(dbCloseArea())
					nNovoVal := (nValDes/(nPesoDA-nValUsa))*nPesoDI
				Else
					cSql := " SELECT A.W9_FOB_TOT AS TOTAL, A.W9_HAWB FROM "+RetSqlName("SW9")+" A "
					cSql += " JOIN "+RetSqlName("SWD")+" B ON B.WD_HAWB = A.W9_HAWB AND B.WD_DESPESA <> '"+SWD->WD_DESPESA+"' "
					cSql += " AND B.WD_DES_ADI <> '"+DtoS(SWD->WD_DES_ADI)+"' AND B.WD_DA <> '1' AND B.D_E_L_E_T_ <> '*' AND B.WD_FILIAL = '"+xFilial("SWD")+"' "
					cSql += " WHERE A.D_E_L_E_T_ <> '*' AND A.W9_FILIAL = '"+xFilial("SW9")+"' AND "+cSubSt+"(A.W9_HAWB,1,1) NOT IN ('0','"+SubStr(Alltrim(xProc),1,1)+"') "
					cSql += " AND A.W9_HAWB LIKE '%"+SubStr(Alltrim(xProc),2,6)+"%' "
					cSql += " GROUP BY A.W9_FOB_TOT, A.W9_HAWB "
					Iif(Select("VAL1X") # 0,VAL1X->(dbCloseArea()),.T.)
					TCQuery cSql NEW ALIAS "VAL1X"
					VAL1X->(dbGoTop())
					While VAL1X->(!EOF())
						nValUsa += VAL1X->TOTAL
						VAL1X->(dbSkip())
					EndDo
					VAL1X->(dbCloseArea())
					nNovoVal := (nValDes/(nValDA-nValUsa))*nValDI
				EndIf
			EndIf 
			
			aRetCon[Len(aRetCon),2] := nNovoVal
			If xTp <> "CTB"
				SWD->(RecLock("SWD",.F.))
				SWD->WD_VALOR_R := nNovoVal
				SWD->WD_GERFIN  := "2"
				SWD->WD_CTRFIN1 := ""
				SWD->WD_FORN    := ""
				SWD->WD_LOJA    := ""
				SWD->WD_DTENVF  := CtoD("")
				SWD->WD_PREFIXO := ""
				SWD->WD_TIPO    := ""
				SWD->WD_PARCELA := ""
				SWD->(MsUnLock())		
			EndIf
					
		EndIf
		SWD->(dbSkip())
	EndDo
EndIf

If xTp == "CTB"
	Return(aRetCon)
EndIf

Return
