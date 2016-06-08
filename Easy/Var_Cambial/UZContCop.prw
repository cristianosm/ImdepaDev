#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE PICVAL  "@E 999,999,999.99"
#DEFINE PICTX   "@E 99.999999"

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: UZContCop()
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 24 de Novembro de 2009, 08:41
//|Uso.......: Contabilidade
//|Versao....: Protheus - 10
//|Descricao.: Função principal para a chamada da rotina de contabilização por Competencia
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
User Function UZContCop()
*-----------------------------------------*

	Local cTipoCad  := "Taxas"
	Local cCadastr  := "Variação Cambial por Competencia"
	Local oDlg      := Nil
	Local oCamb     := Nil
	Local cCamb     := ""
	Local aCamb     := {}
	Local lRet      := .F.
	Local nLin      := 05
	Local nCol1     := 05
	Local nCol2     := 30

	Private aTits := {}
	Private aDesc := {}
	Private oLbx1 := Nil
	Private bLine := Nil
	Private oOk   := LoadBitmap( GetResources(), "LBOK" )
	Private oNo   := LoadBitmap( GetResources(), "LBNO" )

	Private nTx21 := nTx31 := nTx41 := nTx51 := 0
	Private nTx22 := nTx32 := nTx42 := nTx52 := 0
	Private cLote
	Private cxFUso:= ""

	Private aFolds1 := {"Pgto. Antecipados","INV´s SEM D.I.","Frete SEM D.I.","Seguro SEM D.I.","INV´s COM D.I.","Frete COM D.I.","Seguro COM D.I.","INV´s em Estoque","Frete em Estoque","Seguro em Estoque","Entreposto"}
	Private aDesc   := {"","Tipo","Numero","Prefixo","Parcela","Fornecedor","Loja","Emissão","Vencimento","Moeda","Valor na Moeda","Taxa","Valor Anterior","Valor Atual","Variação","Histórico"}

	For tr := 1 To Len(aFolds1)
		cFol := "oFol"+Alltrim(Str(tr))
		cbLx := "oLbx"+Alltrim(Str(tr))
		cLin := "bLin"+Alltrim(Str(tr))
		cVet := "aVet"+Alltrim(Str(tr))
		cQtt := "nQtt"+Alltrim(Str(tr))
		coQt := "oQtt"+Alltrim(Str(tr))
		cTot := "nTot"+Alltrim(Str(tr))
		cOTo := "oTot"+Alltrim(Str(tr))
		cFUs := "cFUs"+Alltrim(Str(tr))

		Private &cFol := Nil
		Private &cbLx := Nil
		Private &cLin := Nil
		Private &coQt := Nil
		Private &cOTo := Nil
		Private &cQtt := 0
		Private &cTot := 0
		Private &cVet := {}
		Private &cFUs := Alltrim(Str(tr))
	Next

	While .T.

		nLin  := 05
		nCol1 := 05
		nCol2 := 30

		DEFINE MSDIALOG oDlg TITLE cCadastr FROM 0,0 TO 165,315 OF oMainWnd PIXEL STYLE DS_MODALFRAME

		oGrp1 := TGroup():New( nLin,nCol1,68,80,"Taxas a Prazo",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )

		@ nLin+=10,nCol1+=5 SAY Alltrim(GetMV("MV_SIMB2")) SIZE 30,7 OF oDlg PIXEL
		@ nLin,nCol2 MSGET nTx21 PICTURE "@E 99.99999" SIZE 30,7 OF oDlg PIXEL

		@ nLin+=12,nCol1 SAY Alltrim(GetMV("MV_SIMB3")) SIZE 30,7 OF oDlg PIXEL
		@ nLin,nCol2 MSGET nTx31 PICTURE "@E 99.99999" SIZE 30,7 OF oDlg PIXEL

		@ nLin+=12,nCol1 SAY Alltrim(GetMV("MV_SIMB4")) SIZE 30,7 OF oDlg PIXEL
		@ nLin,nCol2 MSGET nTx41 PICTURE "@E 99.99999" SIZE 30,7 OF oDlg PIXEL

		@ nLin+=12,nCol1 SAY Alltrim(GetMV("MV_SIMB5")) SIZE 30,7 OF oDlg PIXEL
		@ nLin,nCol2 MSGET nTx51 PICTURE "@E 99.99999" SIZE 30,7 OF oDlg PIXEL

		nLin  := 05
		nCol1 := 80
		nCol2 := 105

		oGrp2 := TGroup():New( nLin,nCol1+=5,68,nCol1+70,"Taxas Antecipadas",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )

		@ nLin+=10,nCol1+=5 SAY Alltrim(GetMV("MV_SIMB2")) SIZE 30,7 OF oDlg PIXEL
		@ nLin,nCol2 MSGET nTx22 PICTURE "@E 99.99999" SIZE 30,7 OF oDlg PIXEL

		@ nLin+=12,nCol1 SAY Alltrim(GetMV("MV_SIMB3")) SIZE 30,7 OF oDlg PIXEL
		@ nLin,nCol2 MSGET nTx32 PICTURE "@E 99.99999" SIZE 30,7 OF oDlg PIXEL

		@ nLin+=12,nCol1 SAY Alltrim(GetMV("MV_SIMB4")) SIZE 30,7 OF oDlg PIXEL
		@ nLin,nCol2 MSGET nTx42 PICTURE "@E 99.99999" SIZE 30,7 OF oDlg PIXEL

		@ nLin+=12,nCol1 SAY Alltrim(GetMV("MV_SIMB5")) SIZE 30,7 OF oDlg PIXEL
		@ nLin,nCol2 MSGET nTx52 PICTURE "@E 99.99999" SIZE 30,7 OF oDlg PIXEL


		DEFINE SBUTTON FROM nLin+=20,05 TYPE 19 OF oDlg ACTION (lRet:=.T.,oDlg:End()) ENABLE
		DEFINE SBUTTON FROM nLin    ,35 TYPE 2  OF oDlg ACTION (lRet:=.F.,oDlg:End()) ENABLE

		ACTIVATE MSDIALOG oDlg CENTER

		If lRet .AND. (Empty(nTx21) .AND. Empty(nTx31) .AND. Empty(nTx41) .AND. Empty(nTx51)) .AND. (Empty(nTx22) .AND. Empty(nTx32) .AND. Empty(nTx42) .AND. Empty(nTx52))
			MsgInfo("Nenhuma taxa informada. Para geração da variação, deve-se ter pelo menos uma taxa informada para 'A Prazo' e 'Antecipado'")
			Loop
		ElseIf !lRet
			Exit
		Else
			Processa({ || U_UZContProc() })
			Exit
		EndIf

	EndDo

Return

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: UZContCop()
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 24 de Novembro de 2009, 20:41
//|Uso.......: Contabilidade
//|Versao....: Protheus - 10        `
//|Descricao.: Função para gerar a Variação Cambial por competencia
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
User Function UZContProc()
*-----------------------------------------*


	Local nUso := 0

	Public _nValVari := 0

	LoteCont("FIN")

	ProcRegua(0)

	UzCriaArray()
//+-----------------------------------------------------------------------------------//
//|ANTECIPADOS
//+-----------------------------------------------------------------------------------//
	cSql := ""
	cSql := "SELECT E2.E2_TIPO,E2.E2_NUM,E2.E2_PREFIXO,E2.E2_PARCELA,E2.E2_FORNECE,E2.E2_LOJA,E2.E2_EMISSAO,E2.E2_VENCTO,E2.E2_MOEDA,"
	cSql += "E2.E2_HIST,E2.E2_TXMOEDA,E2.E2_TXMDCOR,E2.E2_DTVARIA,E2.E2_SALDO,E2.E2_VALOR,E2.E2_VLCRUZ,E2.R_E_C_N_O_ "
	cSql += " FROM "+RetSqlName("SE2")+" E2 "
	cSql += " WHERE E2.D_E_L_E_T_ <> '*' AND E2.E2_FILIAL = '"+xFilial("SE2")+"' "
	cSql += "	AND E2.E2_PREFIXO = 'EIC' "
	cSql += "	AND E2.E2_TIPO = 'PA' AND E2.E2_MOEDA <> '1' AND E2.E2_SALDO > 0 "
	cSql += "	AND E2.E2_EMISSAO <= '"+DtoS(dDataBase)+"' "

	//cSql += " AND E2.E2_FILIAL = '99' " /// NAO RODAR QUERY - CRISTIANO

	cSql += "ORDER BY E2.E2_TIPO,E2.E2_NUM,E2.E2_PARCELA,E2.E2_FORNECE,E2.E2_LOJA "
	nUso++
	UZQuery(cSql,Alltrim(Str(nUso)))

//+-----------------------------------------------------------------------------------//
//|EM TRANSITO SEM D.I.
//+-----------------------------------------------------------------------------------//
	For whj := 1 To 3
		cSql := ""
		cSql := "SELECT E2.E2_TIPO,E2.E2_NUM,E2.E2_PREFIXO,E2.E2_PARCELA,E2.E2_FORNECE,E2.E2_LOJA,E2.E2_EMISSAO,E2.E2_VENCTO,E2.E2_MOEDA,"
		cSql += "E2.E2_HIST,E2.E2_TXMOEDA,E2.E2_TXMDCOR,E2.E2_DTVARIA,E2.E2_SALDO,E2.E2_VALOR,E2.E2_VLCRUZ,E2.R_E_C_N_O_ "
		cSql += " FROM "+RetSqlName("SE2")+" E2 "
		cSql += " JOIN "+RetSqlName("SW6")+" W6 ON E2.E2_NUM = W6.W6_HAWB AND W6.W6_DI_NUM = ' ' AND W6.W6_DT_EMB <> ' ' "
		cSql += " 	AND W6.D_E_L_E_T_ <> '*' AND W6.W6_FILIAL = '"+xFilial("SW6")+"' "
		cSql += Iif(whj == 1," AND W6.W6_HAWB NOT IN (SELECT W2.W2_HAWB_DA FROM "+RetSqlName("SW2")+" W2 WHERE W2.D_E_L_E_T_ <> '*' AND W2.W2_HAWB_DA <> ' ') ","")
		cSql += " WHERE E2.D_E_L_E_T_ <> '*' AND E2.E2_FILIAL = '"+xFilial("SE2")+"' "
		cSql += "	AND E2.E2_PREFIXO = 'EIC' "
		cSql += "	AND E2.E2_TIPO = "+Iif(whj==1,"'INV'","'NF'")+" AND E2.E2_MOEDA <> '1' "
		cSql += "	AND E2.E2_EMIS1 <= '"+DtoS(dDataBase)+"' "

		//cSql += " AND E2.E2_NUM = '005001' " /// ISOLADA - CRISTIANO

		If whj == 2
			cSql += "	AND E2_HIST LIKE '%FRETE%' "
		ElseIf whj == 3
			cSql += "	AND E2_HIST LIKE '%SEGURO%'  "
		EndIf
		cSql += "ORDER BY E2.E2_TIPO,E2.E2_NUM,E2.E2_PARCELA,E2.E2_FORNECE,E2.E2_LOJA "
		nUso++
		UZQuery(cSql,Alltrim(Str(nUso)))
	Next

//+-----------------------------------------------------------------------------------//
//|EM TRANSITO COM D.I.
//+-----------------------------------------------------------------------------------//
	For whj := 1 To 3
		cSql := ""
		cSql := "SELECT E2.E2_TIPO,E2.E2_NUM,E2.E2_PREFIXO,E2.E2_PARCELA,E2.E2_FORNECE,E2.E2_LOJA,E2.E2_EMISSAO,E2.E2_VENCTO,E2.E2_MOEDA,"
		cSql += "E2.E2_HIST,E2.E2_TXMOEDA,E2.E2_TXMDCOR,E2.E2_DTVARIA,E2.E2_SALDO,E2.E2_VALOR,E2.E2_VLCRUZ,E2.R_E_C_N_O_ "
		cSql += " FROM "+RetSqlName("SE2")+" E2 "
		cSql += " JOIN "+RetSqlName("SW6")+" W6 ON E2.E2_NUM = W6.W6_HAWB AND W6.W6_DI_NUM <> ' ' AND W6.W6_DT_NF = ' '  "
		cSql += " 	AND W6.D_E_L_E_T_ <> '*' AND W6.W6_FILIAL = '"+xFilial("SW6")+"' "
		cSql += Iif(whj == 1," AND W6.W6_HAWB NOT IN (SELECT W2.W2_HAWB_DA FROM "+RetSqlName("SW2")+" W2 WHERE W2.D_E_L_E_T_ <> '*' AND W2.W2_HAWB_DA <> ' ') ","")
		cSql += " WHERE E2.D_E_L_E_T_ <> '*' AND E2.E2_FILIAL = '"+xFilial("SE2")+"' "
		cSql += "	AND E2.E2_PREFIXO = 'EIC' AND E2.E2_SALDO > 0 "
		cSql += "	AND E2.E2_TIPO = "+Iif(whj==1,"'INV'","'NF'")+" AND E2.E2_MOEDA <> '1' "
		cSql += "	AND E2.E2_EMISSAO <= '"+DtoS(dDataBase)+"' "

		//cSql += " AND E2.E2_FILIAL = '99' " /// NAO RODAR QUERY - CRISTIANO

		If whj == 2
			cSql += "	AND E2_HIST LIKE '%FRETE%'	"
		ElseIf whj == 3
			cSql += "	AND E2_HIST LIKE '%SEGURO%' "
		EndIf
		cSql += "ORDER BY E2.E2_TIPO,E2.E2_NUM,E2.E2_PARCELA,E2.E2_FORNECE,E2.E2_LOJA "
		nUso++
		UZQuery(cSql,Alltrim(Str(nUso)))
	Next

//+-----------------------------------------------------------------------------------//
//|EM ESTOQUE
//+-----------------------------------------------------------------------------------//
	For whj := 1 To 3
		cSql := ""
		cSql := "SELECT E2.E2_TIPO,E2.E2_NUM,E2.E2_PREFIXO,E2.E2_PARCELA,E2.E2_FORNECE,E2.E2_LOJA,E2.E2_EMISSAO,E2.E2_VENCTO,E2.E2_MOEDA,"
		cSql += "E2.E2_HIST,E2.E2_TXMOEDA,E2.E2_TXMDCOR,E2.E2_DTVARIA,E2.E2_SALDO,E2.E2_VALOR,E2.E2_VLCRUZ,E2.R_E_C_N_O_ "
		cSql += " FROM "+RetSqlName("SE2")+" E2 "
		cSql += " JOIN "+RetSqlName("SW6")+" W6 ON E2.E2_NUM = W6.W6_HAWB AND W6.W6_DI_NUM <> ' ' AND W6.W6_DT_NF <> ' '  "
		cSql += " 	AND W6.D_E_L_E_T_ <> '*' AND W6.W6_FILIAL = '"+xFilial("SW6")+"' "
		cSql += Iif(whj == 1," AND W6.W6_HAWB NOT IN (SELECT W2.W2_HAWB_DA FROM "+RetSqlName("SW2")+" W2 WHERE W2.D_E_L_E_T_ <> '*' AND W2.W2_HAWB_DA <> ' ') ","")
		cSql += " WHERE E2.D_E_L_E_T_ <> '*' AND E2.E2_FILIAL = '"+xFilial("SE2")+"' "
		cSql += "	AND E2.E2_PREFIXO = 'EIC' AND E2.E2_SALDO > 0 "
		cSql += "	AND E2.E2_TIPO = "+Iif(whj==1,"'INV'","'NF'")+" AND E2.E2_MOEDA <> '1' "
		cSql += "	AND E2.E2_EMISSAO <= '"+DtoS(dDataBase)+"' "

		//cSql += " AND E2.E2_FILIAL = '99' " /// NAO RODAR QUERY - CRISTIANO

		If whj == 2
			cSql += "	AND E2_HIST LIKE '%FRETE%'	"
		ElseIf whj == 3
			cSql += "	AND E2_HIST LIKE '%SEGURO%' "
		EndIf
		cSql += "ORDER BY E2.E2_TIPO,E2.E2_NUM,E2.E2_PARCELA,E2.E2_FORNECE,E2.E2_LOJA "
		nUso++
		UZQuery(cSql,Alltrim(Str(nUso)))
	Next

	cSql := ""
	cSql := "SELECT E2.E2_TIPO,E2.E2_NUM,E2.E2_PREFIXO,E2.E2_PARCELA,E2.E2_FORNECE,E2.E2_LOJA,E2.E2_EMISSAO,E2.E2_VENCTO,E2.E2_MOEDA, "
	cSql += "	E2.E2_HIST,E2.E2_TXMOEDA,E2.E2_TXMDCOR,E2.E2_DTVARIA,E2.E2_SALDO,E2.E2_VALOR,E2.E2_VLCRUZ,E2.R_E_C_N_O_,W2.W2_PO_NUM "
	cSql += " FROM "+RetSqlName("SE2")+" E2 "
	cSql += "JOIN "+RetSqlName("SW2")+" W2 ON W2.W2_HAWB_DA = E2.E2_NUM AND W2.D_E_L_E_T_ <> '*' AND W2.W2_FILIAL = '"+xFilial("SW2")+"' "
	cSql += "JOIN "+RetSqlName("SW5")+" W5 ON W5.W5_PO_NUM = W2.W2_PO_NUM AND W5.D_E_L_E_T_ <> '*' AND W5.W5_FILIAL = '"+xFilial("SW5")+"' "
	cSql += "WHERE E2.D_E_L_E_T_ <> '*' AND E2.E2_FILIAL = '"+xFilial("SE2")+"' "
	cSql += "	AND E2.E2_PREFIXO = 'EIC' "
	cSql += "	AND E2.E2_TIPO = 'INV' AND E2.E2_MOEDA <> '1' "
	cSql += "GROUP BY E2.E2_TIPO,E2.E2_NUM,E2.E2_PREFIXO,E2.E2_PARCELA,E2.E2_FORNECE,E2.E2_LOJA,E2.E2_EMISSAO,E2.E2_VENCTO,E2.E2_MOEDA, "
	cSql += "	E2.E2_HIST,E2.E2_TXMOEDA,E2.E2_TXMDCOR,E2.E2_DTVARIA,E2.E2_SALDO,E2.E2_VALOR,E2.E2_VLCRUZ,E2.R_E_C_N_O_,W2.W2_PO_NUM "
	cSql += "ORDER BY E2.E2_TIPO,E2.E2_NUM,E2.E2_PARCELA,E2.E2_FORNECE,E2.E2_LOJA "
	nUso++
	UZQuery(cSql,Alltrim(Str(nUso)))

	MostraTel()

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: UzCriaArray()
//|Descricao.: Cria Arrays para uso
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
Static Function UzCriaArray()
*-----------------------------------------*

	For tr := 1 To Len(aFolds1)
		&("aVet"+Alltrim(Str(tr))) := {}
		aAdd(&("aVet"+Alltrim(Str(tr))),Array(17))
		&("aVet"+Alltrim(Str(tr)))[1,1] := .F.
		cLine := "Iif(aVet"+Alltrim(Str(tr))+"[oLbx"+Alltrim(Str(tr))+":nAt,1],oOk,oNo),"
		For bh := 2 To 16
			cLine += "aVet"+Alltrim(Str(tr))+"[oLbx"+Alltrim(Str(tr))+":nAt,"+Alltrim(Str(bh))+"],"
		Next
		cLine := SubStr(cLine,1,Len(cLine)-1)
		&("bLin"+Alltrim(Str(tr))+"") := &( "{ || {" + cLine + "} }" )
	Next

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: UZQuery
//|Descricao.: Preenche dados para exibição
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
Static Function UZQuery(xSql,xFol)
*-----------------------------------------*

	Local nValEnt := 0
	Local nTxMoe  := 0
	Local nTotal  := 0
	Local nValor1 := 0
	Local nValorM := 0
	Local nValMoe := 0
	Local cBanc   := TCGetDB()
	Local cNull   := Iif("MSSQL" $ cBanc,"ISNULL","NVL")

	If Empty(xSql)
		Return
	EndIf

	Iif(Select("CONSUL") # 0,CONSUL->(dbCloseArea()),.T.)
	TcQuery xSql New Alias "CONSUL"
	CONSUL->(dbSelectArea("CONSUL"))
	CONSUL->(dbGoTop())

	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	&("aVet"+xFol) := {}

	While CONSUL->(!EOF())

		IncProc("Analisando Titulos...")

		If xFol <> "11"
			If !Empty(CONSUL->E2_TXMOEDA) .and. Empty(StoD(CONSUL->E2_DTVARIA)) .and. STR(CONSUL->E2_SALDO,17,2) == STR(CONSUL->E2_VALOR,17,2)
				nValor1 := Iif(xFol $ "234",CONSUL->E2_VALOR,CONSUL->E2_SALDO)*CONSUL->E2_TXMOEDA
			Else
				If(CONSUL->(FieldPos("E2_TXMDCOR")>0 ) .And. !Empty(CONSUL->E2_TXMDCOR))
//					nValor1 := xMoeda(Iif(CONSUL->E2_SALDO == 0,CONSUL->E2_VALOR,CONSUL->E2_SALDO),CONSUL->E2_MOEDA,1,;

					nValor1 := xMoeda(Iif(xFol $ "234",CONSUL->E2_VALOR,CONSUL->E2_SALDO),CONSUL->E2_MOEDA,1,;
						Iif(Empty(StoD(CONSUL->E2_DTVARIA)),StoD(CONSUL->E2_EMISSAO),StoD(CONSUL->E2_DTVARIA)),,CONSUL->E2_TXMDCOR)
				Else
//					nValor1 := xMoeda(Iif(CONSUL->E2_SALDO == 0,CONSUL->E2_VALOR,CONSUL->E2_SALDO),CONSUL->E2_MOEDA,1,;

					nValor1 := xMoeda(Iif(xFol $ "234",CONSUL->E2_VALOR,CONSUL->E2_SALDO),CONSUL->E2_MOEDA,1,;
						Iif(Empty(StoD(CONSUL->E2_DTVARIA)),StoD(CONSUL->E2_EMISSAO),StoD(CONSUL->E2_DTVARIA)),,;
						Iif(Empty(StoD(CONSUL->E2_DTVARIA)),CONSUL->E2_TXMOEDA,0))
				EndIf
			Endif

			nTxMoe    := MoedUse(CONSUL->E2_MOEDA,xFol)
//			nValorM   := xMoeda(Iif(CONSUL->E2_SALDO == 0,CONSUL->E2_VALOR,CONSUL->E2_SALDO),CONSUL->E2_MOEDA,1,dDataBase,,nTxMoe)
			nValorM   := xMoeda(Iif(xFol $ "234",CONSUL->E2_VALOR,CONSUL->E2_SALDO),CONSUL->E2_MOEDA,1,dDataBase,,nTxMoe)

			_nValVari := (nValorM - nValor1)

			cMoed     := Alltrim(GetMv("MV_SIMB"+Alltrim(Str(CONSUL->E2_MOEDA))))

			If CONSUL->E2_VALOR <> CONSUL->E2_SALDO
				If xFol == "2" .OR. xFol == "3" .OR. xFol == "4"
//				IF CONSUL->E2_SALDO == 0
					nValMoe := CONSUL->E2_VALOR
				Else
					nValMoe := CONSUL->E2_SALDO
				EndIf
			Else
				nValMoe := CONSUL->E2_VALOR
			EndIf

		Else
			cSql := " SELECT "+cNull+"(SUM(W5.W5_PRECO*W5.W5_QTDE),0) AS VALTOTAL FROM "+RetSqlName("SW5")+" W5 "
			cSql += " WHERE W5.D_E_L_E_T_ <> '*' AND W5.W5_FILIAL = '"+xFilial("SW5")+"' AND W5.W5_PO_NUM = '"+CONSUL->W2_PO_NUM+"' AND W5.W5_HAWB = ' ' "
			Iif(Select("XTOTW5") # 0,XTOTW5->(dbCloseArea()),.T.)
			TcQuery cSql New Alias "XTOTW5"
			XTOTW5->(dbSelectArea("XTOTW5"))

			cSql := " SELECT "+cNull+"(SUM(W7.W7_PRECO*W7.W7_QTDE),0) AS VALTOTAL FROM "+RetSqlName("SW7")+" W7 "
			cSql += " WHERE W7.D_E_L_E_T_ <> '*' AND W7.W7_FILIAL = '"+xFilial("SW7")+"' AND W7.W7_PO_NUM = '"+CONSUL->W2_PO_NUM+"' "
			Iif(Select("XTOTW7") # 0,XTOTW7->(dbCloseArea()),.T.)
			TcQuery cSql New Alias "XTOTW7"
			XTOTW7->(dbSelectArea("XTOTW7"))

			nValEnt := XTOTW5->VALTOTAL-XTOTW7->VALTOTAL
			nValEnt := (nValEnt/XTOTW5->VALTOTAL)*CONSUL->E2_VALOR
			nValMoe := Round(nValEnt,2)
			XTOTW5->(dbCloseArea())
			XTOTW7->(dbCloseArea())

			If Empty(CONSUL->E2_TXMOEDA) .and. Empty(StoD(CONSUL->E2_DTVARIA))
				nValor1 := nValEnt*CONSUL->E2_TXMOEDA
			Else
				If(CONSUL->(FieldPos("E2_TXMDCOR")>0 ) .And. !Empty(CONSUL->E2_TXMDCOR))
					nValor1 := xMoeda(nValEnt,CONSUL->E2_MOEDA,1,;
						Iif(Empty(StoD(CONSUL->E2_DTVARIA)),StoD(CONSUL->E2_EMISSAO),StoD(CONSUL->E2_DTVARIA)),,CONSUL->E2_TXMDCOR)
				Else
					nValor1 := xMoeda(nValEnt,CONSUL->E2_MOEDA,1,;
						Iif(Empty(StoD(CONSUL->E2_DTVARIA)),StoD(CONSUL->E2_EMISSAO),StoD(CONSUL->E2_DTVARIA)),,;
						Iif(Empty(StoD(CONSUL->E2_DTVARIA)),CONSUL->E2_TXMOEDA,0))
				EndIf
			Endif

			nTxMoe    := MoedUse(CONSUL->E2_MOEDA,xFol)
			nValorM   := xMoeda(nValEnt,CONSUL->E2_MOEDA,1,dDataBase,,nTxMoe)
			_nValVari := (nValorM - nValor1)
			cMoed     := Alltrim(GetMv("MV_SIMB"+Alltrim(Str(CONSUL->E2_MOEDA))))

		EndIf

		If _nValVari <> 0
			aAdd(&("aVet"+xFol),{.F.,CONSUL->E2_TIPO,CONSUL->E2_NUM,CONSUL->E2_PREFIXO,;
				CONSUL->E2_PARCELA,CONSUL->E2_FORNECE,;
				CONSUL->E2_LOJA,StoD(CONSUL->E2_EMISSAO),StoD(CONSUL->E2_VENCTO),cMoed,nValMoe,nTxMoe,nValor1,;
				nValorM,_nValVari,Alltrim(CONSUL->E2_HIST),CONSUL->R_E_C_N_O_,;
				Iif(Alltrim(CONSUL->E2_TIPO)<>"PA",Alltrim(CONSUL->E2_NUM),"") })
		EndIf

		_nValVari := 0
		CONSUL->(dbSkip())

	EndDo
	CONSUL->(dbCloseArea())

	If Len(&("aVet"+xFol)) = 0
		aAdd(&("aVet"+xFol),Array(17))
		&("aVet"+xFol)[1,1]	:= .F.
	EndIf

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: MostraTel()
//|Descricao.: Mostra tela com variação
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
Static Function MostraTel()
*-----------------------------------------*

	Local aPos1 := {}

	Private oDlg    := Nil
	Private bOk     := {|| nOpcao := 1 , lRet := GrvSel(), Iif(lRet,oDlg:End(),.F.) }
	Private bCancel := {|| nOpcao := 0 , Iif(MsgYesNo("Deseja Sair?","Sair"),oDlg:End(),.F.) }
	Private nOpcao  := 1
	Private aButt   := {}

	Define MsDialog oDlg Title "Titulos para Variação" From 1,1 to 500,950 of oMainWnd PIXEL  STYLE DS_MODALFRAME

	aPos1 := PosDlg(oDlg)
	oFol1 := TFolder():New(aPos1[1],aPos1[2],aFolds1,{},oDlg,,,,.T.,.F.,aPos1[4],aPos1[3])
	UZMontaTel()
	Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) Centered

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: UZMontaTel
//|Descricao.: Monta Tela
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
Static Function UZMontaTel()
*-----------------------------------------*

	aPos2 := PosDlg(oFol1:aDialogs[1])

	xoDl  := oFol1:aDialogs[1]
	nCol1 := 5
	oLbx1:= TWBrowse():New( 2,2,aPos2[4]-3,aPos2[3]-40,,aDesc,,xoDl,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx1:SetArray(aVet1)
	oLbx1:bLDblClick := { || UZMarcDes(oLbx1:nAt,"1") }
	oLbx1:bLine := bLin1
	@ aPos2[3]-21,nCol1     SAY "Qtde Títulos Selecionados:" SIZE 80,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=65 MSGET oQtt1 VAR nQtt1 WHEN .F. PICTURE "99999" SIZE 30,7 OF xoDl PIXEL
	@ aPos2[3]-21,nCol1+=40 SAY "Vlr Total Variações Selecionadas:" SIZE 100,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=82 MSGET oTot1 VAR nTot1 WHEN .F. PICTURE "@E 999,999.9999" SIZE 60,7 OF xoDl PIXEL
	@ aPos2[3]-35,aPos2[4]-110 BUTTON "Altera Variação"  SIZE 50,10 PIXEL OF xoDl ACTION UZAltVar(oLbx1:nAt,"1")
	@ aPos2[3]-35,aPos2[4]-55  BUTTON "M/Desm. Todos" SIZE 50,10 PIXEL OF xoDl ACTION UZMarcDes("","1")

	xoDl  := oFol1:aDialogs[2]
	nCol1 := 5
	oLbx2:= TWBrowse():New( 2,2,aPos2[4]-3,aPos2[3]-40,,aDesc,,xoDl,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx2:SetArray(aVet2)
	oLbx2:bLDblClick := { || UZMarcDes(oLbx2:nAt,"2") }
	oLbx2:bLine := bLin2
	@ aPos2[3]-21,nCol1     SAY "Qtde Títulos Selecionados:" SIZE 80,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=65 MSGET oQtt2 VAR nQtt2 WHEN .F. PICTURE "99999" SIZE 30,7 OF xoDl PIXEL
	@ aPos2[3]-21,nCol1+=40 SAY "Vlr Total Variações Selecionadas:" SIZE 100,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=82 MSGET oTot2 VAR nTot2 WHEN .F. PICTURE "@E 999,999.9999" SIZE 60,7 OF xoDl PIXEL
	@ aPos2[3]-35,aPos2[4]-110 BUTTON "Altera Variação"  SIZE 50,10 PIXEL OF xoDl ACTION UZAltVar(oLbx2:nAt,"2")
	@ aPos2[3]-35,aPos2[4]-55  BUTTON "M/Desm. Todos" SIZE 50,10 PIXEL OF xoDl ACTION UZMarcDes("","2")

	xoDl  := oFol1:aDialogs[3]
	nCol1 := 5
	oLbx3:= TWBrowse():New( 2,2,aPos2[4]-3,aPos2[3]-40,,aDesc,,xoDl,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx3:SetArray(aVet3)
	oLbx3:bLDblClick := { || UZMarcDes(oLbx3:nAt,"3") }
	oLbx3:bLine := bLin3
	@ aPos2[3]-21,nCol1     SAY "Qtde Títulos Selecionados:" SIZE 80,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=65 MSGET oQtt3 VAR nQtt3 WHEN .F. PICTURE "99999" SIZE 30,7 OF xoDl PIXEL
	@ aPos2[3]-21,nCol1+=40 SAY "Vlr Total Variações Selecionadas:" SIZE 100,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=82 MSGET oTot3 VAR nTot3 WHEN .F. PICTURE "@E 999,999.9999" SIZE 60,7 OF xoDl PIXEL
	@ aPos2[3]-35,aPos2[4]-110 BUTTON "Altera Variação"  SIZE 50,10 PIXEL OF xoDl ACTION UZAltVar(oLbx3:nAt,"3")
	@ aPos2[3]-35,aPos2[4]-55  BUTTON "M/Desm. Todos" SIZE 50,10 PIXEL OF xoDl ACTION UZMarcDes("","3")

	xoDl  := oFol1:aDialogs[4]
	nCol1 := 5
	oLbx4:= TWBrowse():New( 2,2,aPos2[4]-3,aPos2[3]-40,,aDesc,,xoDl,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx4:SetArray(aVet4)
	oLbx4:bLDblClick := { || UZMarcDes(oLbx4:nAt,"4") }
	oLbx4:bLine := bLin4
	@ aPos2[3]-21,nCol1     SAY "Qtde Títulos Selecionados:" SIZE 80,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=65 MSGET oQtt4 VAR nQtt4 WHEN .F. PICTURE "99999" SIZE 30,7 OF xoDl PIXEL
	@ aPos2[3]-21,nCol1+=40 SAY "Vlr Total Variações Selecionadas:" SIZE 100,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=82 MSGET oTot4 VAR nTot4 WHEN .F. PICTURE "@E 999,999.9999" SIZE 60,7 OF xoDl PIXEL
	@ aPos2[3]-35,aPos2[4]-110 BUTTON "Altera Variação"  SIZE 50,10 PIXEL OF xoDl ACTION UZAltVar(oLbx4:nAt,"4")
	@ aPos2[3]-35,aPos2[4]-55  BUTTON "M/Desm. Todos" SIZE 50,10 PIXEL OF xoDl ACTION UZMarcDes("","4")

	xoDl  := oFol1:aDialogs[5]
	nCol1 := 5
	oLbx5:= TWBrowse():New( 2,2,aPos2[4]-3,aPos2[3]-40,,aDesc,,xoDl,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx5:SetArray(aVet5)
	oLbx5:bLDblClick := { || UZMarcDes(oLbx5:nAt,"5") }
	oLbx5:bLine := bLin5
	@ aPos2[3]-21,nCol1     SAY "Qtde Títulos Selecionados:" SIZE 80,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=65 MSGET oQtt5 VAR nQtt5 WHEN .F. PICTURE "99999" SIZE 30,7 OF xoDl PIXEL
	@ aPos2[3]-21,nCol1+=40 SAY "Vlr Total Variações Selecionadas:" SIZE 100,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=82 MSGET oTot5 VAR nTot5 WHEN .F. PICTURE "@E 999,999.9999" SIZE 60,7 OF xoDl PIXEL
	@ aPos2[3]-35,aPos2[4]-110 BUTTON "Altera Variação"  SIZE 50,10 PIXEL OF xoDl ACTION UZAltVar(oLbx5:nAt,"5")
	@ aPos2[3]-35,aPos2[4]-55  BUTTON "M/Desm. Todos" SIZE 50,10 PIXEL OF xoDl ACTION UZMarcDes("","5")

	xoDl  := oFol1:aDialogs[6]
	nCol1 := 5
	oLbx6:= TWBrowse():New( 2,2,aPos2[4]-3,aPos2[3]-40,,aDesc,,xoDl,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx6:SetArray(aVet6)
	oLbx6:bLDblClick := { || UZMarcDes(oLbx6:nAt,"6") }
	oLbx6:bLine := bLin6
	@ aPos2[3]-21,nCol1     SAY "Qtde Títulos Selecionados:" SIZE 80,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=65 MSGET oQtt6 VAR nQtt6 WHEN .F. PICTURE "99999" SIZE 30,7 OF xoDl PIXEL
	@ aPos2[3]-21,nCol1+=40 SAY "Vlr Total Variações Selecionadas:" SIZE 100,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=82 MSGET oTot6 VAR nTot6 WHEN .F. PICTURE "@E 999,999.9999" SIZE 60,7 OF xoDl PIXEL
	@ aPos2[3]-35,aPos2[4]-110 BUTTON "Altera Variação"  SIZE 50,10 PIXEL OF xoDl ACTION UZAltVar(oLbx6:nAt,"6")
	@ aPos2[3]-35,aPos2[4]-55  BUTTON "M/Desm. Todos" SIZE 50,10 PIXEL OF xoDl ACTION UZMarcDes("","6")

	xoDl  := oFol1:aDialogs[7]
	nCol1 := 5
	oLbx7:= TWBrowse():New( 2,2,aPos2[4]-3,aPos2[3]-40,,aDesc,,xoDl,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx7:SetArray(aVet7)
	oLbx7:bLDblClick := { || UZMarcDes(oLbx7:nAt,"7") }
	oLbx7:bLine := bLin7
	@ aPos2[3]-21,nCol1     SAY "Qtde Títulos Selecionados:" SIZE 80,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=65 MSGET oQtt7 VAR nQtt7 WHEN .F. PICTURE "99999" SIZE 30,7 OF xoDl PIXEL
	@ aPos2[3]-21,nCol1+=40 SAY "Vlr Total Variações Selecionadas:" SIZE 100,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=82 MSGET oTot7 VAR nTot7 WHEN .F. PICTURE "@E 999,999.9999" SIZE 60,7 OF xoDl PIXEL
	@ aPos2[3]-35,aPos2[4]-110 BUTTON "Altera Variação"  SIZE 50,10 PIXEL OF xoDl ACTION UZAltVar(oLbx7:nAt,"7")
	@ aPos2[3]-35,aPos2[4]-55  BUTTON "M/Desm. Todos" SIZE 50,10 PIXEL OF xoDl ACTION UZMarcDes("","7")

	xoDl  := oFol1:aDialogs[8]
	nCol1 := 5
	oLbx8:= TWBrowse():New( 2,2,aPos2[4]-3,aPos2[3]-40,,aDesc,,xoDl,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx8:SetArray(aVet8)
	oLbx8:bLDblClick := { || UZMarcDes(oLbx8:nAt,"8") }
	oLbx8:bLine := bLin8
	@ aPos2[3]-21,nCol1     SAY "Qtde Títulos Selecionados:" SIZE 80,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=65 MSGET oQtt8 VAR nQtt8 WHEN .F. PICTURE "99999" SIZE 30,7 OF xoDl PIXEL
	@ aPos2[3]-21,nCol1+=40 SAY "Vlr Total Variações Selecionadas:" SIZE 100,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=82 MSGET oTot8 VAR nTot8 WHEN .F. PICTURE "@E 999,999.9999" SIZE 60,7 OF xoDl PIXEL
	@ aPos2[3]-35,aPos2[4]-110 BUTTON "Altera Variação"  SIZE 50,10 PIXEL OF xoDl ACTION UZAltVar(oLbx8:nAt,"8")
	@ aPos2[3]-35,aPos2[4]-55  BUTTON "M/Desm. Todos" SIZE 50,10 PIXEL OF xoDl ACTION UZMarcDes("","8")

	xoDl  := oFol1:aDialogs[9]
	nCol1 := 5
	oLbx9:= TWBrowse():New( 2,2,aPos2[4]-3,aPos2[3]-40,,aDesc,,xoDl,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx9:SetArray(aVet9)
	oLbx9:bLDblClick := { || UZMarcDes(oLbx9:nAt,"9") }
	oLbx9:bLine := bLin9
	@ aPos2[3]-21,nCol1     SAY "Qtde Títulos Selecionados:" SIZE 80,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=65 MSGET oQtt9 VAR nQtt9 WHEN .F. PICTURE "99999" SIZE 30,7 OF xoDl PIXEL
	@ aPos2[3]-21,nCol1+=40 SAY "Vlr Total Variações Selecionadas:" SIZE 100,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=82 MSGET oTot9 VAR nTot9 WHEN .F. PICTURE "@E 999,999.9999" SIZE 60,7 OF xoDl PIXEL
	@ aPos2[3]-35,aPos2[4]-110 BUTTON "Altera Variação"  SIZE 50,10 PIXEL OF xoDl ACTION UZAltVar(oLbx9:nAt,"9")
	@ aPos2[3]-35,aPos2[4]-55  BUTTON "M/Desm. Todos" SIZE 50,10 PIXEL OF xoDl ACTION UZMarcDes("","9")

	xoDl  := oFol1:aDialogs[10]
	nCol1 := 5
	oLbx10:= TWBrowse():New( 2,2,aPos2[4]-3,aPos2[3]-40,,aDesc,,xoDl,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx10:SetArray(aVet10)
	oLbx10:bLDblClick := { || UZMarcDes(oLbx10:nAt,"10") }
	oLbx10:bLine := bLin10
	@ aPos2[3]-21,nCol1     SAY "Qtde Títulos Selecionados:" SIZE 80,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=65 MSGET oQtt10 VAR nQtt10 WHEN .F. PICTURE "99999" SIZE 30,7 OF xoDl PIXEL
	@ aPos2[3]-21,nCol1+=40 SAY "Vlr Total Variações Selecionadas:" SIZE 100,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=82 MSGET oTot10 VAR nTot10 WHEN .F. PICTURE "@E 999,999.9999" SIZE 60,7 OF xoDl PIXEL
	@ aPos2[3]-35,aPos2[4]-110 BUTTON "Altera Variação"  SIZE 50,10 PIXEL OF xoDl ACTION UZAltVar(oLbx10:nAt,"10")
	@ aPos2[3]-35,aPos2[4]-55  BUTTON "M/Desm. Todos" SIZE 50,10 PIXEL OF xoDl ACTION UZMarcDes("","10")

	xoDl  := oFol1:aDialogs[11]
	nCol1 := 5
	oLbx11:= TWBrowse():New( 2,2,aPos2[4]-3,aPos2[3]-40,,aDesc,,xoDl,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx11:SetArray(aVet11)
	oLbx11:bLDblClick := { || UZMarcDes(oLbx11:nAt,"11") }
	oLbx11:bLine := bLin11
	@ aPos2[3]-21,nCol1     SAY "Qtde Títulos Selecionados:" SIZE 80,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=65 MSGET oQtt11 VAR nQtt11 WHEN .F. PICTURE "99999" SIZE 30,7 OF xoDl PIXEL
	@ aPos2[3]-21,nCol1+=40 SAY "Vlr Total Variações Selecionadas:" SIZE 100,7 OF xoDl PIXEL
	@ aPos2[3]-35,nCol1+=82 MSGET oTot11 VAR nTot11 WHEN .F. PICTURE "@E 999,999.9999" SIZE 60,7 OF xoDl PIXEL
	@ aPos2[3]-35,aPos2[4]-110 BUTTON "Altera Variação"  SIZE 50,10 PIXEL OF xoDl ACTION UZAltVar(oLbx11:nAt,"11")
	@ aPos2[3]-35,aPos2[4]-55  BUTTON "M/Desm. Todos" SIZE 50,10 PIXEL OF xoDl ACTION UZMarcDes("","11")

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: UZMarcDes()
//|Descricao.: Marca Itens
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
Static Function UZAltVar(xItem,xFol)
*-----------------------------------------*

	Local nVal    := &("aVet"+xFol)[xItem,15]
	Local oDlgVar := Nil
	Local lRet    := .F.

	While .T.

		DEFINE MSDIALOG oDlgVar TITLE "Alteração de Variação" FROM 0,0 TO 80,320 OF oMainWnd PIXEL STYLE DS_MODALFRAME

		@ 05,05 TO 40,102 LABEL "Valor" OF oDlgVar PIXEL

		@ 18,15 MSGET nVal PICTURE PICVAL SIZE 50,7 OF oDlgVar PIXEL

		DEFINE SBUTTON FROM 08,120 TYPE 19 OF oDlgVar ACTION (lRet:=.T.,oDlgVar:End()) ENABLE
		DEFINE SBUTTON FROM 26,120 TYPE 2  OF oDlgVar ACTION (lRet:=.F.,oDlgVar:End()) ENABLE

		ACTIVATE MSDIALOG oDlgVar CENTER

		If lRet
			If MsgYesNo("Confirma a Alteração?","Alteração")
				&("aVet"+xFol)[xItem,15] := nVal
				&("aVet"+xFol)[xItem,1]  := .T.
				&("oLbx"+xFol):SetArray(&("aVet"+xFol))
				&("oLbx"+xFol):bLine := &("bLin"+xFol)
				&("oLbx"+xFol):Refresh()
				UzRecalc(xFol)
				Exit
			Else
				Loop
			EndIf
		ElseIf !lRet
			Exit
		EndIf

	EndDo

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: UzRecalc
//|Descricao.: Recalcula valores
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
Static Function UzRecalc(xFol)
*-----------------------------------------*
	&("nTot"+xFol) := 0
	&("nQtt"+xFol) := 0

	For kr := 1 To Len(&("aVet"+xFol))
		If &("aVet"+xFol)[kr,1]
			&("nTot"+xFol) += &("aVet"+xFol)[kr,15]
			&("nQtt"+xFol) += 1
		EndIf
	Next

	&("oTot"+xFol):Refresh()
	&("oQtt"+xFol):Refresh()

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: UZMarcDes()
//|Descricao.: Marca Itens
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
Static Function UZMarcDes(xIt,xFol)
*-----------------------------------------*

	Local lret := .F.

	If !Empty(xIt)
		If ValType(&("aVet"+xFol)[xIt,2]) <> "U"
			lret := .T.
			&("aVet"+xFol)[xIt,1] := !&("aVet"+xFol)[xIt,1]
		Else
			MsgInfo("Não há dados no item selecionado","Sem dados")
		EndIf
	Else
		If ValType(&("aVet"+xFol)[1,2]) <> "U"
			lret := .T.
			lMar := !&("aVet"+xFol)[1,1]
			For gy := 1 To Len(&("aVet"+xFol))
				&("aVet"+xFol)[gy,1] := lMar
			Next
		Else
			MsgInfo("Não há dados para seleção","Sem dados")
		EndIf
	EndIf

	If lret
		&("oLbx"+xFol):SetArray(&("aVet"+xFol))
		&("oLbx"+xFol):bLine := &("bLin"+xFol)
		&("oLbx"+xFol):Refresh()
		UzRecalc(xFol)
	EndIf

Return(lret)

//+-----------------------------------------------------------------------------------//
//|Funcao....: UZMarcDes()
//|Descricao.: Marca Itens
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
Static Function GrvSel()
*-----------------------------------------*

	Local nSc := 0

	For vg := 1 To 11
		nSc := Ascan(&("aVet"+Alltrim(Str(vg))),{|x|x[1] == .T. } )
		If !Empty(nSc)
			Exit
		EndIf
	Next

	If Empty(nSc)
		MsgInfo("Não há titulos selecionados","Atenção")
		Return .F.
	ElseIf MsgYesNo("Confirma a geração da Variação Cambial?","Variação")
		MsgInfo("Essa rotina pode demorar alguns minutos, e só será gerada a variação para itens marcados e que tem valor de variação","Atenção")
		Processa({|| VariaGer()  })
		Return .T.
	EndIf

Return .F.

//+-----------------------------------------------------------------------------------//
//|Funcao....: UZMarcDes()
//|Descricao.: Marca Itens
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
Static Function VariaGer()
*-----------------------------------------*

	Local nTotal  := 0
	Local aRetUse := {}

	Private nHdlPrv
	Private cArquivo
	Private cPadrao    := "599"
	Private lPadrao
	Private lHeadProva := .F.
	Private lDigita    := .T.
	Private lAglutina  := .F.

	ProcRegua(0)

	Begin Transaction

		dbSelectArea("SE2")
		For nb := 1 To 11
			xFol   := Alltrim(Str(nb))
			cxFUso := xFol
			For hj := 1 To Len(&("aVet"+xFol))
				IncProc("Gerando contabilizações")
				_nValVari := 0

			//	If alltrim(&("aVet"+xFol)[hj,3]) == '004709'
			//		Teste := 0
			//	EndIf
				If &("aVet"+xFol)[hj,1] .AND. !Empty(&("aVet"+xFol)[hj,15])
					SE2->(dbGoTo(&("aVet"+xFol)[hj,17]))
					SE2->(RecLock("SE2",.F.))
					SE2->E2_DTVARIA := dDataBase
					If SE2->(FieldPos("E2_TXMDCOR")>0)
						SE2->E2_TXMDCOR := &("aVet"+xFol)[hj,12]
					EndIf
					SE2->(MsUnlock())


	//| Cristiano Machado  -  2014/04/08
	//| Correcao Variacao Cambial
	//| Localiza Processo de invoice e grava os valores da ultima var Cambial...
	//| Esta Informacao nao pode ser perdida...pela exclusao e criacao do titulo...
					If ( SW6->(DbSeek(xfilial("SW6")+&("aVet"+xFol)[hj,3],.F.)) )
	//					Alert( "Achou !!!" )
	//					Alert("Salvar Taxa Moeda no SW6 = "+ &("aVet"+xFol)[hj,3])

						RecLock("SW6",.F.)
						SW6->W6_TX_VCAM := &("aVet"+xFol)[hj,12]
						SW6->W6_DT_VCAM := dDataBase
						SW6->(MsUnlock())

					EndIf


					_nValVari := Round(&("aVet"+xFol)[hj,15],2)

					If !Empty(_nValVari)
						lPadrao := VerPadrao(cPadrao) //| Verifica se o codigo da LANPADRAO Padronizado existe. MATXFUN.PRX
						If lPadrao

							If !lHeadProva
								SA2->(dbSetOrder(1))
								SA2->(dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
								nHdlPrv := HeadProva(cLote,"UZContCop",Substr(cUsuario,7,6),@cArquivo) //| Grava o Header do arquivo  Contra Prova. HEADPROV.PRG
								lHeadProva := .T.
							EndIf
							nTotal += DetProva(nHdlPrv,cPadrao,"UZContCop",cLote) //| Grava as linhas de detalhe do arquivo de Contra Prova. DETPROVA.PRG
						EndIf

						dbSelectArea("SE5")
						SE5->(RecLock("SE5",.T.))
						SE5->E5_FILIAL  	:= xFilial("SE5")
						SE5->E5_PREFIXO 	:= SE2->E2_PREFIXO
						SE5->E5_NUMERO  	:= SE2->E2_NUM
						SE5->E5_PARCELA 	:= SE2->E2_PARCELA
						SE5->E5_TIPO    	:= SE2->E2_TIPO
						SE5->E5_CLIFOR  	:= SE2->E2_FORNECE
						SE5->E5_LOJA    	:= SE2->E2_LOJA
						SE5->E5_VALOR   	:= _nValVari
						SE5->E5_VLMOED2 	:= Round(_nValVari/&("aVet"+xFol)[hj,12],2)
						SE5->E5_DATA    	:= dDataBase
						SE5->E5_NATUREZ 	:= SE2->E2_NATUREZ
						SE5->E5_RECPAG  	:= "P"
						SE5->E5_TIPODOC 	:= "VM"
						SE5->E5_LA      	:= "S"
						SE5->E5_DTDIGIT 	:= dDataBase
						SE5->E5_DTDISPO 	:= dDataBase
						SE5->E5_HISTOR  	:= "CORREC MONET. IMPORT."
						SE5->(MsUnlock())
					EndIf
				EndIf
			Next
		Next

		IF lHeadProva
			RodaProva(nHdlPrv,nTotal) //| Grava o rodape do arquivo de Contra Prova. RODAPROV.PRG
			cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglutina) //| Programa de inclus„o de Lan‡amentos Cont beis.    CONA100A.PRX
		Endif

	End Transaction


Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: MoedUse
//|Descricao.: Verifica a moeda usada e tras a taxa correta
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
Static Function MoedUse(nxMoed,xFol)
*-----------------------------------------*

	Local nRet := 0

	If nxMoed = 2
		nRet := Iif(xFol=="1",nTx22,nTx21)
	ElseIf nxMoed = 3
		nRet := Iif(xFol=="1",nTx32,nTx31)
	ElseIf nxMoed = 4
		nRet := Iif(xFol=="1",nTx42,nTx41)
	ElseIf nxMoed = 5
		nRet := Iif(xFol=="1",nTx52,nTx51)
	EndIf

Return(nRet)


//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: UZContCTA()
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 16 de Fevereiro de 2010, 18:20
//|Uso.......: Contabilidade
//|Versao....: Protheus - 10
//|Descricao.: Função para chamada de contas contabeis corretas
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
User Function UZContCTA(xlDI,xTip)
*-----------------------------------------*

	Local lRet  := .F.
	Local lPADI := .F.

	If xTip == "PA" .AND. Alltrim(SE2->E2_TIPO) == xTip .AND. !xlDI
		lRet := .T.
	ElseIf xTip <> "PA"
		dbSelectArea("SW6")
		SW6->(dbSetOrder(1))
		If SW6->(dbSeek(xFilial("SW6")+SE2->E2_NUM))
			If Empty(SW6->W6_DI_NUM) .AND. xlDI
				Return(lRet)
			ElseIf !Empty(SW6->W6_DI_NUM) .AND. !xlDI
				Return(lRet)
			Else
				If xTip == "INV" .AND. Alltrim(SE2->E2_TIPO) == xTip
					lRet := .T.
				ElseIf xTip == "SEG" .AND. "SEGURO" $ SE2->E2_HIST .AND. Alltrim(SE2->E2_TIPO) == "NF"
					lRet := .T.
				ElseIf xTip == "FRE" .AND. "FRETE" $ SE2->E2_HIST .AND. Alltrim(SE2->E2_TIPO) == "NF"
					lRet := .T.
				Endif
			EndIf
		EndIf
	EndIf

Return(lRet)


//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: UZxUsaEnt()
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 24 de Agosto de 2010, 18:20
//|Uso.......: Contabilidade
//|Versao....: Protheus - 10
//|Descricao.: Se o Processo é de Entreposto ou não
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
User Function UZxUsaEnt(xProc)
*-----------------------------------------*

	Local lRet   := .F.
	Local nRecW6 := SW6->(RecNo())

	dbSelectArea("SW6")
	SW6->(dbSetOrder(1))
	If SW6->(dbSeek(xFilial("SW6")+xProc))
		lRet := Iif(Alltrim(SW6->W6_TIPODES) == "2" .OR. Alltrim(SW6->W6_TIPODES) == "14",.T.,.F.)
	EndIf

	SW6->(dbGoTo(nRecW6))

Return(lRet)

//+-----------------------------------------------------------------------------------//
//|Fim do Programa de Contabilização de Variação Cambial Por Competencia
//+-----------------------------------------------------------------------------------//