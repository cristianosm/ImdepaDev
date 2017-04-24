#Include 'Totvs.ch'
#Include "Tbiconn.ch"

#Define AJUSTA  .F.  	// Bem deve ser Ajustado
#Define NAJUSTA .T.  	// Bem Nao precisa de Ajuste
#Define CTADES  '3'   	// CONTA DE DESPESA
#Define CTADEP  '4'		// CONTA DE DEPREC ACUMULADA
#Define TXMOE5   0.8287	// Moeda 5 UFIR
#Define DECIMAL  2      // Casas Decimais Geral
#Define ME       0.75    // Margem de Erro, Sempre sera o Dobro do Valor aqui informado
#Define ENTER CHR(13)+CHR(10)

/*
N4_OCORR == "01"    // Baixa
N4_OCORR == "03"    // Transferencia DE
N4_OCORR == "04"    // Transferencia DE
N4_OCORR == "05"    // Aquisicao
N4_OCORR == "06"    // Depreciacao
N4_OCORR == "07"    // Correcao do bem
N4_OCORR == "08"    // Correcao
N4_OCORR == "09"    // Ampliacao

N4_TIPOCNT == "1"	//CONTA DO BEM
N4_TIPOCNT == "2"  	//CONTA DE CORRECAO DO BEM
N4_TIPOCNT == "3"  	//CONTA DE DESPESA
N4_TIPOCNT == "4"  	//CONTA DE DEPREC ACUMULADA
N4_TIPOCNT == "5"  	//CONTA DE CORRECAO DA DEP ACUMULADA
*/
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : SM_ADA    | AUTOR : Cristiano Machado | DATA : 20/04/2017      **
**---------------------------------------------------------------------------**
** DESCRIÇÃO:  Corrige Saldos e Movimentos dos Ativos ( SN3 | SN4 )          **
**---------------------------------------------------------------------------**
** USO : Especifico para Imdepa Rolamentos                                   **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                         **
**---------------------------------------------------------------------------**
** PROGRAMADOR | DATA | MOTIVO DA ALTERACAO                                  **
**---------------------------------------------------------------------------**
**   |  | **
**   |  | **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User function SM_ADA() // Ajusta Depreciacao Ativo;
*******************************************************************************

	Private cLogTxt  := ""
	Private lShowSql := .F.
	Private oProcess := Nil
	Private cFile	 := "C:\mp11\Log_"+Dtos(dDataBase)+"_"+STRTRAN(Time(), ":",".")+".txt"
	Private nHFile	 := 0

	CriaFLog( @nHFile )//| Cria Arquivo de Log

	oProcess := MsNewProcess():New({|lEnd| Rotina(lEnd,oProcess)},"Inicando Ajustes Ativo....","Aguarde...",.T.)
	oProcess:Activate()

	SlvLog( ENTER + "FIM PROCESSO -->  "+CV(dDataBase)+" "+Time() + ENTER )

	FClose(nHFile)

	If Iw_MsgBox("Deseja Abrir o LOG ? ","Responda...","YESNO")			 // Se deve Mostrar os SQL em Tela
		shellExecute("Open", cFile, "", "C:\mp11\", 1 )
	Else
		Iw_MsgBox("Log Salvo em "+cFile,"LOG","INFO")
	EndIf

	Return Nil
*******************************************************************************
Static Function Rotina(lEnd) // Montagem de Reguas
*******************************************************************************

	Local cCBase  := ""		 // Codigo do Bem
	Local cItem   := ""		 // Item do Bem
	Local CConta  := ""		 // Conta do Bem
	Local dDtUlD  := CToD("  /  /    ") // Data Ultima Depreciacao
	Local cCursor := "BASE"

	oProcess:SetRegua1(0)
	oProcess:SetRegua2(0)

	MontaBase(@cCursor)// Monta Bens a Avaliar apartir dos Parametros

	DbSelectArea(cCursor)
	While !Eof()

		cCBase := BASE->CODBASE	 // Codigo do Bem
		cItem  := BASE->CITEM	 // Item do Bem
		CConta := BASE->CCONTA	 // Conta do Bem
		dDtUlD := MV_PAR01 		 // Data Ultima Depreciacao

		oProcess:IncRegua1("Bem: "+AllTrim(cCBase)+" Item: "+AllTrim(cItem)+" Conta: "+Alltrim(CConta))

		Principal(cCBase, cItem, cConta, dDtUlD,  )

		DbSelectArea(cCursor)
		DbSkip()

	EndDo

	Return Nil
*******************************************************************************
Static Function Principal(CBase, Item, Conta, DtUlD ) //Funcao Principal
*******************************************************************************

	Private cCBase := CBase	 // Codigo do Bem
	Private cItem  := Item	 // Item do Bem
	Private cConta := Conta	 // Conta do Bem
	Private dDtUlD := DtUlD  // Data Ultima Depreciacao

	Private TCA	   := "DAT" // Tabela Cadastro Ativo
	Private TMA    := "MAT" // Tabela Movimento Ativo

	// Obtem Dados do ATIVO
	DadosAtivo(@TCA)

	// Obtem Movimento Ativo Atual
	MovAtivo(@TMA)

	// Verifica se eh necessário Ajuste na Depreciacao ?
	If VerSeAjusta() == AJUSTA

		// Ajusta Depreciacao caso Necessario
		AjuDepre()

	EndIf

	DbSelectArea(TCA);DbCloseArea()
	DbSelectArea(TCA);DbCloseArea()

	Return Nil
*******************************************************************************
Static function DadosAtivo(cCursor)// Obtem Dados do ATIVO
*******************************************************************************
	Local cSql 		:= ""

	cSql += "SELECT N3_FILIAL SN3_FILIAL, N3_CBASE SN3_CBASE, N3_ITEM SN3_ITEM, "
	cSql += "	N3_CCONTAB SN3_CCONTAB, " //-- CONTA BEM
	cSql += "	N3_SUBCCON SN3_SUBCCON, " //-- ITEM CONTA BEM
	cSql += "	N3_CDEPREC SN3_CDEPREC, " //-- CONTA DEBITO DEPRECIACAO
	cSql += "	N3_CCDEPR  SN3_CCDEPR,  " //-- CONTA CREDITO DEPRECIACAO
	cSql += "	N3_CCCDEP  SN3_CCCDEP,  " //-- CENTRO DE CUSTO DEPRECIACAO
	cSql += "	N3_TXDEPR1 SN3_TXDEPR1, " //-- TAXA DEPRECIACAO
	cSql += "	N3_DINDEPR SN3_DINDEPR, " //-- INICIO DEPRECIACAO
	cSql += "	N3_FIMDEPR SN3_FIMDEPR, " //-- FIM DEPRECIACAO
	cSql += "	N3_VORIG1  SN3_VORIG1,  " //-- VALOR BEM
	cSql += "	N3_VRDBAL1 SN3_VRDBAL1, " //-- VALOR DEPRECIACAO ULT. BALANCO .
	cSql += "	N3_VRDMES1 SN3_VRDMES1, " //-- VALOR MES ULTIMA DEPRECIACAO
	cSql += "	N3_VRDACM1 SN3_VRDACM1, " //-- VALOR ACUMULADO DEPRECIACAO
	cSql += "	R_E_C_N_O_ SN3_RECNO  " //-- RECNO SN3
	cSql += "FROM SN3010 "
	cSql += "WHERE D_E_L_E_T_ = ' ' "
	cSql += "AND   N3_CCONTAB = '"+CConta+"' "
	cSql += "AND   N3_CBASE   = '"+cCBase+"' "
	cSql += "AND   N3_ITEM    = '"+cItem+"' "
	cSql += "AND   N3_DTBAIXA = ' ' " // Só bens Ativos
	cSql += "AND   N3_CDEPREC > ' ' " // Deve ter conta debito  de depreciacao
	cSql += "AND   N3_CCDEPR  > ' ' " // Deve ter conta credito de depreciacao

	cSql += "ORDER BY N3_CBASE, N3_ITEM "

	U_ExecMySql( cSql , cCursor , "Q", lShowSql, .F. )

	Return Nil
*******************************************************************************
Static function MovAtivo(cCursor)// Obtem Movimento Ativo Atual
*******************************************************************************
	Local cSql := ""

	cSql += "SELECT N4_FILIAL SN4_FILIAL, N4_CBASE SN4_CBASE, N4_ITEM SN4_ITEM, N4_TIPO SN4_TIPO, N4_OCORR SN4_OCORR, N4_TIPOCNT SN4_TIPOCNT, "
	cSql += "       N4_CONTA SN4_CONTA, N4_DATA SN4_DATA, N4_VLROC1 SN4_VLROC1, N4_TXMEDIA SN4_TXMEDIA, N4_TXDEPR SN4_TXDEPR, N4_CCUSTO SN4_CCUSTO, "
	cSql += "       N4_SEQ SN4_SEQ, N4_SUBCTA SN4_SUBCTA, R_E_C_N_O_ SN4_RECNO "
	cSql += "FROM SN4010 "
	cSql += "WHERE D_E_L_E_T_ = ' ' "
	cSql += "AND   N4_CBASE  = '"+cCBase+"' "
	cSql += "AND   N4_ITEM = '"+cItem+"' "
	cSql += "AND   N4_OCORR = '06' " // Movimento de Depreciacao
	cSql += "ORDER BY N4_CBASE, N4_ITEM, N4_DATA, N4_TIPOCNT "

	U_ExecMySql( cSql , cCursor , "Q", lShowSql, .F. )

	Return Nil
*******************************************************************************
Static Function VerSeAjusta(lLog)// Verifica se eh necessário Ajuste na Depreciacao ?
*******************************************************************************
	Local cSql := ""
	Local cCursor := "VAT" // Verifica Ativo
	Local lOk := NAJUSTA

	Default lLog := .F.

	cSql += " SELECT N3.CODBASE, N3.ITEM, CONTAA, CONTAD, TXDEP, INICIODEP, FIMDEP, VALORORI, "
	cSql += " 	CASE "
	cSql += " 		WHEN (MESDEP * VLDEPMES) + (DIADEP * VLDEPDIA) > VALORORI THEN VALORORI "
	cSql += " 		ELSE ROUND((MESDEP * VLDEPMES) + (DIADEP * VLDEPDIA),2) "
	cSql += " 		END DEP_CAL, "
	cSql += " 	N3.DEPACUM DEP_ACU, "
	cSql += " 	NVL(N4.DEPACUM,0) DEP_MOV "
	cSql += " FROM (	SELECT 	N3_CBASE CODBASE, N3_ITEM ITEM, N3_CCONTAB CONTAA, N3_CCDEPR CONTAD, N3_DINDEPR INICIODEP, "
	cSql += " 				N3_FIMDEPR FIMDEP,N3_VORIG1 VALORORI, N3_TXDEPR1 TXDEP, N3_VRDACM1 DEPACUM, "

	cSql += " 				N3_VORIG1 * ROUND( N3_TXDEPR1 / 100 / 360 , 8 ) VLDEPDIA, "
	cSql += " 				N3_VORIG1 * ROUND( N3_TXDEPR1 / 100 / 12  , 8 ) VLDEPMES, "

	//cSql += " 				ROUND(N3_VORIG1 * (N3_TXDEPR1 / 100 / 360  ),4) VLDEPDIA, "
	//cSql += " 				ROUND(N3_VORIG1 * (N3_TXDEPR1 / 100 / 12   ),2) VLDEPMES, "
	
	cSql += " 				ROUND( (MONTHS_BETWEEN( TO_DATE('20170331','YYYYMMDD') , LAST_DAY(TO_DATE(N3_DINDEPR, 'YYYYMMDD'))+1 )), 0) MESDEP, "
	cSql += " 				LAST_DAY(TO_DATE(N3_DINDEPR, 'YYYYMMDD')) - TO_DATE(N3_DINDEPR,'YYYYMMDD') + 1 DIADEP "
	cSql += " 	FROM SN3010 "
	cSql += " 	WHERE D_E_L_E_T_ = ' ' "
	cSql += " 	AND  N3_CCONTAB = '"+CConta+"' "
	cSql += "     AND  N3_DTBAIXA =  ' ' "
	cSql += " 	AND  N3_CBASE = '"+cCBase+"' "
	cSql += " 	AND  N3_ITEM = '"+cItem+"' "
	cSql += " 	) N3 FULL JOIN "
	cSql += " 	(	SELECT N4_CBASE CODBASE, N4_ITEM ITEM, (SUM(N4_VLROC1)/2) DEPACUM "
	cSql += " 		FROM  SN4010 "
	cSql += " 		WHERE	D_E_L_E_T_ = ' ' "
	cSql += " 		AND     N4_CBASE||N4_ITEM IN (  SELECT N3_CBASE||N3_ITEM FROM SN3010 WHERE D_E_L_E_T_ = ' ' "
	cSql += " 										AND	N3_CCONTAB = '"+CConta+"' "
	cSql += " 										AND N3_CBASE = '"+cCBase+"' "
	cSql += " 										AND N3_ITEM = '"+cItem+"' "
	cSql += " 										AND D_E_L_E_T_ = ' ' "
	cSql += " 										AND N3_DTBAIXA =  ' ' ) "
	cSql += " 		AND 	N4_OCORR = '06' "
	cSql += " 		AND		N4_TIPOCNT IN ('3','4') "
	cSql += " 		GROUP BY N4_CBASE, N4_ITEM "
	cSql += " 	) N4 "
	cSql += " ON N3.CODBASE = N4.CODBASE "
	cSql += " AND   N3.ITEM = N4.ITEM "

	U_ExecMySql( cSql , cCursor , "Q", lShowSql, .F. )

	DbSelectArea(cCursor)
	DbGotop()

	If !lLog // Se nao for LOG

		If  (( (VAT->DEP_ACU+ME) < VAT->DEP_CAL .Or. (VAT->DEP_ACU-ME) > VAT->DEP_CAL  ) .Or. ( (VAT->DEP_MOV+ME) < VAT->DEP_CAL .Or. (VAT->DEP_MOV-ME) > VAT->DEP_CAL  ) .Or. VAT->DEP_MOV <> VAT->DEP_ACU )  // Depreciacao InCorreta Deve Ajustar
			lOk := AJUSTA
		EndIf

		If ( ( VALORORI ==  VAT->DEP_ACU ) .And. Empty(VAT->FIMDEP) ) // Item Depreciado por Completo sem data de final de Depreciacao deve colocar
			lOk := AJUSTA
		EndIf

		If lOk == NAJUSTA // Caso nao precise de ajuste apenas grava os dados principais do bem no log
			GrvLog("C","")
		EndIF

		DbSelectArea(cCursor)
		DbCloseArea()

	EndIf

	Return lOk 
*******************************************************************************
Static function AjuDepre()// Ajusta Depreciacao caso Necessario
*******************************************************************************
	Local lACorrigir 	:= .T.

	Private nDia	   		:= 0 //Numero de Dias a Depreciar para o Bem no inicio da Depreciacao
	Private nMes	   		:= 0 //Numero de Meses a Depreciar o Bem ate a Completa Depreciacao

	Private dFimDepr 		:= cToD("01/01/01") // Data Final para Completar a Depreciacao
	Private dFimDepG 		:= cToD("  /  /  ") // Data Final Depreciacao que sera Gravada no SN3
	Private dPriDepr 		:= cToD("01/01/01") // Data Primeira Depreciacao
	Private dCorDepr 		:= cToD("01/01/01") // Data Depreciacao Corrente

	Private nVlDepDia  	:= 0 // Valor Depreciacao Dia
	Private nVlDepMes  	:= 0 // Valor Depreciacao Mes

	Private nVlDepAc 	:= 0 // Guarda o Valor Acumulado da Depreciacao
	Private nDepAcum 	:= 0 // Acumula o Valor Depreciado
	Private nValorOri 	:= 0 // Valor Original do bem
	Private nVlrDepUM 	:= 0 // Valor Depreciacao Ultimo Mes

	DbSelectArea(TCA);DbGotop()// Tabela Cadastro Ativo

	// Calcula os Valores de Depreciacao Dia e Mes
	CalDepAtivo(@nVlDepDia, @nVlDepMes, @nValorOri)

	// Verifica Quantos Dias e Meses serao necessário para depreciar totalmente o ativo
	VerPerDep( @nDia, @nMes, nVlDepDia, nVlDepMes, @dFimDepr, @dPriDepr )

	LimpMov() // Limpa o Movimento Anterior e Posterior aos Limites de Data

	dCorDepr := dPriDepr // Inicialisa a Data de Depreciacao Corrente

	GrvLog("I","")  // Grava Inico do LOG para o Item

	DbSelectArea(TMA);DbGotop()// Tabela Movimento Ativo
	While lACorrigir

		oProcess:IncRegua2("Movimento -> Data : "+StrZero(Month(dCorDepr),2)+"/"+CV(YEAR(dCorDepr))+" Acumulo : "+CV(nDepAcum))

		If dCorDepr == SToD(&(TMA+"->SN4_DATA")) // Verifica Se Data do Movimento esta Correta

			If  dCorDepr == SToD(&(TMA+"->SN4_DATA")) .And. &(TMA+"->SN4_TIPOCNT") == CTADES // Verifica se esta OK ContaDes
				AtuSN4(CTADES) // Atualiza Valores no SN4
				DbSelectArea(TMA);DbSkip()
			Else
				LancSN4(CTADES) // Lança Movimento no SN4
			EndIF

			If  dCorDepr == SToD(&(TMA+"->SN4_DATA")) .And. &(TMA+"->SN4_TIPOCNT") == CTADEP
				AtuSN4(CTADEP) // Atualiza Valores no SN4
				DbSelectArea(TMA);DbSkip()
			Else
				LancSN4(CTADEP) // Lança Movimento no SN4
			EndIF

			// Caso Exista Registro Duplicados no meio dos periodos ja os Elimina...
			While dCorDepr >=  SToD(&(TMA+"->SN4_DATA")) .And. !EOF()
				DbSelectArea(TMA)
				DbGoto( &(TMA+"->SN4_RECNO") )

				cExec := "DELETE SN4010 WHERE R_E_C_N_O_ = "+CV(&(TMA+"->SN4_RECNO"))+" "
				U_ExecMySql( cExec , "" , "E", .F., .F. )

				// Grava LOF de Exclusão
				GrvLog("M","Excluido => Data: "+CV(SToD(&(TMA+"->SN4_DATA")))+" Valor: "+CV(&(TMA+"->SN4_VLROC1"))+" Registro: "+ CV( &(TMA+"->SN4_RECNO") ) )

				DbSelectArea(TMA)
				DbSkip()
			EndDo

		Else
			LancDSN4() // Lança Movimento no SN4 para as Duas Contas
		EndIf

		//Verifica se ja atingiou Fim da Depreciacao ou ultima Depreciacao
		If dCorDepr == dDtUlD // Atingiu a ultima depreciaca pode encerrar...
			lACorrigir := .F.
		Endif
		If nDepAcum == nValorOri // Se Depreciacao Acumulada atingir o Valor Original
			dFimDepG := dCorDepr
			lACorrigir := .F.
		EndIf

		//Ajusta Data para Próximo Mes
		If lACorrigir
			dCorDepr := LastDay(dCorDepr + 10)
		EndIf

	EndDo

	// Atualiza Saldos do Item SN3
	AtuSld()

	GrvLog("F","") // Grava Log Final do Item

	Return Nil
*******************************************************************************
Static Function AtuSN4(TpConta)// Atualiza Valores no SN4
*******************************************************************************

	Local nValor := 0

	DbSelectArea("SN4");DbGoto(&(TMA+"->SN4_RECNO"))
	If !EOF()
		nValor := MontaValor(DToS(SN4->N4_DATA))

		RecLock("SN4",.F.)
		SN4->N4_FILIAL	:= xFilial("SN4")
		SN4->N4_CONTA   := If(TpConta==CTADES,&(TCA+"->SN3_CDEPREC"),&(TCA+"->SN3_CCDEPR"))
		SN4->N4_VLROC1 	:= nValor
		SN4->N4_VLROC2	:= 0
		SN4->N4_VLROC3	:= 0
		SN4->N4_VLROC4	:= 0
		SN4->N4_VLROC5	:= Round(nValor * TXMOE5,DECIMAL)
		SN4->N4_TXMEDIA	:= TXMOE5 //Taxa Moeda 5
		SN4->N4_TXDEPR	:= &(TCA+"->SN3_TXDEPR1")
		SN4->N4_CCUSTO  := &(TCA+"->SN3_CCCDEP")
		SN4->N4_SEQ		:= ""
		SN4->N4_SUBCTA  := &(TCA+"->SN3_SUBCCON")
		MsUnlock()

		If TpConta == CTADEP // So Acumula no Tipo 4 -> CONTA DEBITO para não duplicar os valores
			nDepAcum += nValor
			GrvLog("M","Atualizado => Data: "+CV(SN4->N4_DATA)+" Valor: "+CV(nValor)+" Acumulado: "+  CV(nDepAcum) )
		EndIf
	Else
		LancSN4(TpConta)
	EndIf
	
	Return Nil
*******************************************************************************
Static Function LancSN4(TpConta) // Lanca Novos Valores SN4
*******************************************************************************
	Local nValor := 0

	nValor := MontaValor(DToS(dCorDepr))

	DbSelectArea("SN4")
	RecLock("SN4",.T.)
	SN4->N4_FILIAL	:= xFilial("SN4")
	SN4->N4_CBASE	:= &(TCA+"->SN3_CBASE")
	SN4->N4_ITEM	:= &(TCA+"->SN3_ITEM")
	SN4->N4_TIPO	:= "01"
	SN4->N4_OCORR	:= "06"
	SN4->N4_TIPOCNT	:= TpConta
	SN4->N4_CONTA	:= If(TpConta==CTADES,&(TCA+"->SN3_CDEPREC"),&(TCA+"->SN3_CCDEPR"))
	SN4->N4_DATA	:= dCorDepr
	SN4->N4_VLROC1	:= nValor
	SN4->N4_VLROC2	:= 0
	SN4->N4_VLROC3	:= 0
	SN4->N4_VLROC4	:= 0
	SN4->N4_VLROC5	:= Round(nValor * TXMOE5,DECIMAL)
	SN4->N4_TXMEDIA	:= TXMOE5 //Taxa Moeda 5
	SN4->N4_TXDEPR	:= &(TCA+"->SN3_TXDEPR1")
	SN4->N4_CCUSTO	:= &(TCA+"->SN3_CCCDEP")
	SN4->N4_SEQ		:= ""
	SN4->N4_SUBCTA	:= &(TCA+"->SN3_SUBCCON")
	MsUnlock()

	If TpConta == CTADEP // So Acumula no Tipo 4 -> CONTA DEBITO para não duplicar os valores
		nDepAcum += nValor
		GrvLog("M","Incluido  =>  Data: "+ CV(dCorDepr ) +" Valor: "+CV(nValor)+" Acumulado: "+ CV(nDepAcum) )
	EndIf

	Return Nil
*******************************************************************************
Static Function LancDSN4 // Lanca nas Duas Contas SN4
*******************************************************************************

	LancSN4(CTADES)
	LancSN4(CTADEP)

	Return Nil
*******************************************************************************
Static function AtuSld()// Atualiza Saldo caso tenho havido ajuste o movimento
*******************************************************************************
	Local nVal := 0

	If Empty( DToS(dFimDepG))
		nVal := nVlrDepUM
	Else
		nVal := 0
	EndIf

	DbSelectArea("SN3");DbGoto(&(TCA+"->SN3_RECNO"))
	RecLock("SN3",.F.)

	SN3->N3_FIMDEPR := dFimDepG

	SN3->N3_VORIG1	:= nValorOri
	SN3->N3_VORIG2	:= 0
	SN3->N3_VORIG3	:= 0
	SN3->N3_VORIG4	:= 0
	SN3->N3_VORIG5	:= Round(nValorOri * TXMOE5,DECIMAL)

	SN3->N3_VRDBAL1 := nDepAcum
	SN3->N3_VRDBAL2 := 0
	SN3->N3_VRDBAL3 := 0
	SN3->N3_VRDBAL4 := 0
	SN3->N3_VRDBAL5 := Round(nDepAcum * TXMOE5,DECIMAL)

	SN3->N3_VRDMES1 := nVal
	SN3->N3_VRDMES2 := 0
	SN3->N3_VRDMES3 := 0
	SN3->N3_VRDMES4 := 0
	SN3->N3_VRDMES5 := Round(nVal * TXMOE5,DECIMAL)

	SN3->N3_VRDACM1 := nDepAcum
	SN3->N3_VRDACM2 := 0
	SN3->N3_VRDACM3 := 0
	SN3->N3_VRDACM4 := 0
	SN3->N3_VRDACM5 := Round(nDepAcum * TXMOE5,DECIMAL)

	Msunlock()

	Return Nil
*******************************************************************************
Static Function CalDepAtivo(nVlDepDia, nVlDepMes, nValorOri) // Calcula os Valores de Depreciacao Dia e Mes
*******************************************************************************

	nVlDepDia := Round( &(TCA+"->SN3_TXDEPR1") / 100 / 360 , 10 ) * &(TCA+"->SN3_VORIG1")
	nVlDepMes := Round( &(TCA+"->SN3_TXDEPR1") / 100 / 12  , 10 ) * &(TCA+"->SN3_VORIG1")
	nVlDepAno := Round( &(TCA+"->SN3_TXDEPR1") / 100 / 1   , 10 ) * &(TCA+"->SN3_VORIG1")
	nValorOri := &(TCA+"->SN3_VORIG1")

	Return Nil
*******************************************************************************
Static Function VerPerDep( nDia, nMes, nVlDepDia, nVlDepMes, dFimDepr, dPriDepr )	// Verifica Quantos Dias e Meses serao necessário depreciar
*******************************************************************************
	Local dDataI := STod(&(TCA+"->SN3_DINDEPR")) 	// Data Inicio Depreciacao
	Local dUDiaM := LastDay(dDataI) 	// Data Ultimo dia Mes Inicio Depreciacao
	Local nADDia := 0					// Valor Acumulo Depreciacao Dias a Depreciar
	Local nAuxMes:= 1
	Local dDtDIM := dUDiaM + 1 		// Data Depreciacao Inicial de Meses
	Local dDataF := dDataI         //

	// Dias a Depreciar
	nDia    := dUDiaM - dDataI + 1 // Dias a Depreciar

	// Meses a Depreciar
	nAuxMes := (nValorOri - (nVlDepDia * nDia)) // Monta o Valor a Depreciar jah descontatos os dias depreciados do primeiro mes
	If Mod(nAuxMes , nVlDepMes ) <> 0
		nMes := NoRound(nAuxMes/nVlDepMes,0) + 1
	Else
		nMes := NoRound(nAuxMes/nVlDepMes,0)
	EndIf

	// Monta Data Final Depreciacao
	nAnos := NoRound(nMes / 12)
	nMDif := nMes - (nAnos * 12)
	nAuxMes := dDtDIM - 15 + (nMDif * 30) // Adiciona os Meses a Data inicial Depreciacao Mes cheio
	dFimDepr := LastDay(cToD("01/"+StrZero(Month(nAuxMes))+"/"+StrZero(Year(nAuxMes)+nAnos,4)))

	// Monta Data Primeira Depreciacao
	dPriDepr := dUDiaM

	Return Nil
*******************************************************************************
Static Function MontaValor(cDTSN4) // Monta Valor do Lancamento
*******************************************************************************
	Local nValor := 0

	If SToD(cDTSN4) == dPriDepr // Veirifca se eh o primeiro mes de depreciacao
		nValor := ( nDia * nVlDepDia )
	Else
		nValor := ( nVlDepMes )
	EndIf

	If (nDepAcum + nValor) >= nValorOri // Caso tenha Sido Atingido a Valor do Bem deve Grava apenas a Diferença e Encerrar a Depreciacao
		nValor := (nValorOri - nDepAcum)
	EndIf

	nValor :=  Round(nValor,DECIMAL) // Ajusta Valor

	nVlrDepUM := nValor

	Return nValor
*******************************************************************************
Static Function MontaBase(cCursor)// Monta Bens a Avaliar apartir dos Parametros
*******************************************************************************
	Local cSql 		:= ""
	Local cModo		:= "Q"
	Local lMostra   := .F.
	Local lChange   := .F.
	Local cPerg		:= "AJUAVO"

	Pergunte(cPerg, .T.)

	MV_PAR01 := GetMv("MV_ULTDEPR") // Obtem Data da Ultima Depreciacao

	
	cSql += "SELECT N3_CBASE CODBASE, N3_ITEM CITEM, N3_CCONTAB CCONTA "
	cSql += "FROM SN3010 "
	cSql += "WHERE D_E_L_E_T_ 	= ' ' "
	cSql += "AND   N3_DTBAIXA   = ' ' "
	cSql += "AND   N3_CDEPREC 	> ' ' "
	cSql += "AND   N3_CCDEPR 	> ' ' "
	cSql += "AND   N3_VORIG1 	> 1   "
	cSql += "AND   N3_TXDEPR1   > 0   "
	cSql += "AND   N3_CBASE 	BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' "
	cSql += "AND   N3_ITEM  	BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"' "
	cSql += "AND   N3_CCONTAB 	BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"' "
	cSql += "ORDER BY N3_CBASE, N3_ITEM "

	U_ExecMySql( cSql , cCursor , cModo, lMostra, lChange )

	Return Nil
*******************************************************************************
Static Function LimpMov() // Limpa o Movimento Anterior e Posterior aos Limites de Data	de Depreciacao
*******************************************************************************
	Local cSql := ""
	Local dDataFim := If(dFimDepr>dDtUlD,dDtUlD,dFimDepr) // Pega a Ultima data que vai ser Depreciado Efetivamente

	cSql += "DELETE SN4010 "
	cSql += "WHERE D_E_L_E_T_ 	= ' ' "
	cSql += "AND   N4_CBASE 	    = '"+cCBase+"' "
	cSql += "AND   N4_ITEM  		= '"+cItem+"' "
	cSql += "AND   N4_OCORR 		= '06' "
	cSql += "AND   ( N4_DATA       < '"+DToS(dPriDepr)+"' OR N4_DATA  > '"+DToS(dDataFim)+"' ) "

	U_ExecMySql( cSql , "" , "E", .F., .F. )

	//GrvLog("M","Excluindo Movimento Anterior a " + CV(dPriDepr) + " e Posterior a " + CV(dDataFim) )

	Return Nil
*******************************************************************************
Static Function GrvLog(nP,cMen) // Controle de Gravacao do LOG
*******************************************************************************
	Local cLogAux := ""

	If NP == "I" // Inicio BEM

		cLogAux +=    "**************************************************" + ENTER
		cLogAux +=    "CBase: " + &(TCA+"->SN3_CBASE")  + ENTER
		cLogAux +=    "Item : " + &(TCA+"->SN3_ITEM")  + ENTER
		cLogAux +=    "Conta: " + &(TCA+"->SN3_CCONTAB")  + ENTER
		cLogAux +=    "Valor Bem: " + CV(nValorOri)  + ENTER
		cLogAux +=    ENTER
		cLogAux +=    "Inicio Dep: " +  CV(dPriDepr)  + ENTER
		cLogAux +=    "Ultima Dep: " +  CV(dFimDepr)  + ENTER
		cLogAux +=    ENTER
		cLogAux +=    "Valor Dep Dia: " + CV(nVlDepDia)  + ENTER
		cLogAux +=    "Valor Dep Mes: " + CV(nVlDepMes)  + ENTER
		cLogAux +=    ENTER

	EndIf

	If NP == "M" // Movimento BEM
		cLogAux +=    cMen + ENTER
	EndIf

	If NP == "F" // Final BEM

		VerSeAjusta(.T.)

		cLogAux += ENTER
		cLogAux += "Dep Calculada: " + CV(nDepAcum) + " "+ ENTER
		cLogAux += "Dep Saldo    : " + CV(VAT->DEP_ACU)+ " "+ ENTER
		cLogAux += "Dep Movimento: " + CV(VAT->DEP_MOV)+ " "+ ENTER
		cLogAux += "Ultima Dep.  : " + CV(dCorDepr)+ " " + ENTER
		cLogAux += "**************************************************" + ENTER

		DbSelectArea("VAT")
		DbCloseArea()

	EndIf

	If NP == "C" // BEM Correto

		//VerSeAjusta(.T.)

		cLogAux += "**************************************************" + ENTER
		cLogAux += "CBase: " +VAT->CODBASE  + ENTER
		cLogAux += "Item : " +VAT->ITEM  + ENTER
		cLogAux += "Conta: " +VAT->CONTAA  + ENTER
		cLogAux += "Valor Bem: " + CV(VAT->VALORORI) + " "+ ENTER
		cLogAux += ENTER
		cLogAux += "Dep Calculada: " + CV(VAT->DEP_CAL) + " * Margem aceita + ou - "+CV(ME)+ ENTER
		cLogAux += "Dep Saldo    : " + CV(VAT->DEP_ACU) + " "+ ENTER
		cLogAux += "Dep Movimento: " + CV(VAT->DEP_MOV) + " "+ ENTER + ENTER
		cLogAux += "VALORES CORRETOS! BEM NAO PRECISA DE AJUSTE !!! " + ENTER
		cLogAux += "**************************************************" + ENTER

	EndIf

	ConOut(cLogAux)

	SlvLog(cLogAux)

	Return Nil
*******************************************************************************
Static Function CV( xVar )	//Converte Variavel para Texto
*******************************************************************************

	Return(cValToChar(xVar))
*******************************************************************************
Static Function SlvLog( cTexto )	//Salva Log Arquivo
*******************************************************************************

	FWrite(nHFile, cTexto, Len(cTexto))

	Return Nil
*******************************************************************************
Static Function CriaFLog( nHFile )//| Cria Arquivo de LOG
*******************************************************************************

	Local nModo			:= 2 //| 0-> READ | 1-> WRITE | 2-> READ_WRITE |
	Local cBuffer		:= ""
	Local lChangeCase	:= .T. //| Case sensitive .T. , .F. |
	Local aLine			:= {}

//	nHandle		:= 0 //FCREATE(cArq, nModo)

	nHFile	:= FCreate(cFile, nModo)

	cTexto := "INICIO PROCESSO --> "+CV(dDataBase)+" "+Time()+ ENTER

	SlvLog( cTexto )

Return Nil