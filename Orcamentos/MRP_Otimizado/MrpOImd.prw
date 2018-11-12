#include 'Protheus.ch'
#include 'Parmtype.ch'
#include 'Totvs.ch'

#Define ENTER Chr(13)+Chr(10)


/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : IMDC040     | AUTOR : Cristiano Machado  | DATA : 29/06/2018   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Efetua Ajustes MRP conforme Regras no Cadastro de Produtos     ** 
**          : sua e Extensao                                                 **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente IMDEPA                               **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function MrpOImd()
*******************************************************************************

	Private lMostra  := .F.
	Private lStatusP := .F.
	Private lMedias  := .F.
	Private lCoefVar := .F.
	Private lRankVen := .F.
	Private lCurvABC := .F.
	Private lCurvPQR := .F.
	Private lCurABCM := .F.
	Private lCuABCOV := .F.
	
	// Variaveis Utilizadas no oProcess:SetRegua1
	Private lAbort 	:= .F.
	Private cMsg   	:= "Aguarde o Inicio" 
	Private bAction := {}
	Private cTitulo := ""
	Private oProcess := Nil
	
	//Private bAbort	:= { || IIf ( lAbort == .T., Alert("Não vá neste momento"), "" ) }
	
	Private cLog := ""
	
	If Iw_MsgBox("Deseja Executar Manualmente a Otimização MRP Imdepa","Atenção","YESNO")
	
		lStatusP := Iw_MsgBox("Deseja Atualizar o Status dos Produtos ?","Atenção","YESNO")
		lMedias  := Iw_MsgBox("Deseja Calcular as Médias dos Produtos?","Atenção","YESNO")
		lCoefVar := Iw_MsgBox("Deseja Calcular o Coeficiente de Variabilidade ?","Atenção","YESNO")
		lRankVen := Iw_MsgBox("Deseja Calcular o Ranking de Vendas ?","Atenção","YESNO")
		lCurvABC := Iw_MsgBox("Deseja calcular a Curva ABC ?","Atenção","YESNO")
		lCurvPQR := Iw_MsgBox("Deseja calcular a Curva PQR ?","Atenção","YESNO")
		lCurABCM := Iw_MsgBox("Deseja calcular a Curva ABC Margem ?","Atenção","YESNO")
		lCuABCOV := Iw_MsgBox("Deseja calcular a Curva ABC Ofertado e Vendido ?","Atenção","YESNO")
		
		If lCurvABC
			lRankVen := lCurvABC
		EndIf
		
		// Execucoes Diarias
		ExecDiario()
	
		// Execucoes Mensais
		ExecMensal()
	
		// Apresenta o LOG de Execucao
		ShowLog()
		
	EndIf

Return()
*******************************************************************************
Static Function  ExecDiario()// Execucoes Diarias
*******************************************************************************


	If lStatusP
	
		// 1.1 ZA7_PPCOMP => Produtos com Pedidos Abertos 
		bAction 	:= {|| za7ppcomp() }
		cTitulo   	:= "Atualizando (ZA7_PPCOMP) - Produtos com Pedidos"
		//Processa( bAction, @cTitulo, @cMsg, @lAbort )
		oProcess := MsNewProcess():New( bAction ,cTitulo,"Lendo...",.T.)
		oProcess:Activate()
	
		// 1.2 ZA7_PGRAMA => SIM - Produto com Programa (Contrato) 
		bAction 	:= {|| ZA7PGRAMA() }
		cTitulo   := "Atualizando (ZA7_PGRAMA) - Produtos com Programa"
		//Processa( bAction, @cTitulo, @cMsg, @lAbort )
		oProcess := MsNewProcess():New( bAction ,cTitulo,"Lendo...",.T.)
		oProcess:Activate()
		
	EndIf
	

Return Nil
*******************************************************************************
Static function za7ppcomp()	// 1.1 ZA7_PPCOMP => Produtos com Pedidos Abertos 
*******************************************************************************

	Local cSql 		:= ""
	Local cSDataPC 	:= dToS(DataRef(nMeses := 6)) // Retorna 6 meses
	Local cSDataSC 	:= dToS(DataRef(nMeses := 0)) // Retorna 0 meses
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo oProcess:IncRegua1
	
	oProcess:SetRegua1(0);oProcess:SetRegua2(0)
	oProcess:IncRegua1();oProcess:IncRegua2()
	
	// Consulta Pedidos de Compras e Solicitacoes de Compras  
	cSql := "SELECT PRODUTO FROM ( " 
	cSql += "SELECT C7_PRODUTO PRODUTO FROM SC7010 "
	cSql += "WHERE D_E_L_E_T_ = ' ' "
	cSql += "AND   C7_EMISSAO >= '"+cSDataPC+"' "
	cSql += "AND   C7_RESIDUO = ' ' " 
	cSql += "GROUP BY C7_PRODUTO "
	cSql += "UNION " 
	cSql += "SELECT C1_PRODUTO PRODUTO  FROM SC1010 " 
	cSql += "WHERE D_E_L_E_T_ = ' ' "
	cSql += "AND   C1_DATPRF >= '"+cSDataSC+"' "
	cSql += "AND   C1_RESIDUO = ' ' "
	cSql += "GROUP BY C1_PRODUTO "
	cSql += ") ORDER BY PRODUTO "
	
	
	oProcess:IncRegua1("Consultando Pedidos de Compras apartir de "+SToC(cSDataPC)) ; oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	
	// Atualiza Todos os Produtos para NAO
	cSql := "UPDATE ZA7010 SET ZA7_PPCOMP = 'N' WHERE ZA7_PPCOMP <> 'N' "
	oProcess:IncRegua1("Definido Todos os Produtos como N-Nao") ; oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	// Inicia a Atualizacao 
	DbSelectArea("TAUX");DbGotop()
	While !EOF()
		
		// Atualiza os Produtos para SIM
		cSql := "Update ZA7010 Set ZA7_PPCOMP = 'S' WHERE ZA7_CODPRO = '" + CV(TAUX->PRODUTO) + "' " 
		
		If nIntPro == 100
 
			oProcess:IncRegua1("Atualizando o Produto " +  Alltrim(TAUX->PRODUTO) + " para SIM " ); oProcess:IncRegua2()
			nIntPro := 0
		Else
			nIntPro += 1
		EndIf 
		U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		
		nPAtu += 1
		
		DbSelectArea("TAUX")
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	MntLog ("1.1 ZA7_PPCOMP => Produtos com Pedidos Abertos " + ENTER +;
	"Foram Atualizados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " Produtos em cada Filial ","Campo ZA7_PPCOMP")
	
	
	
Return Nil
*******************************************************************************
Static function ZA7PGRAMA()	// 1.2 ZA7_PGRAMA => SIM - Produto com Programa (Contrato)
*******************************************************************************

	Local cSql 		:= ""
	Local cSData 	:= dToS(DataRef(nMeses := 1,.T.)) // Retorna 6 meses
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo oProcess:IncRegua1

	//oProcess:SetRegua1(0);oProcess:SetRegua2(0)
	//oProcess:IncRegua1();oProcess:IncRegua2()

	oProcess:SetRegua1(0);oProcess:SetRegua2(0)
	oProcess:IncRegua1();oProcess:IncRegua2()
	
	// Consulta Contratos
	cSql := "SELECT ADB.ADB_CODPRO PRODUTO "
	cSql += "FROM ADA010 ADA INNER JOIN ADB010 ADB "
	cSql += "ON	ADA.ADA_FILIAL = ADB.ADB_FILIAL "
	cSql += "AND ADA.ADA_NUMCTR = ADB.ADB_NUMCTR "
	cSql += "WHERE 	ADA.D_E_L_E_T_ = ' ' "  
	cSql += "AND     ADB.D_E_L_E_T_ = ' ' "
	cSql += "AND 	ADA.ADA_EMISSA >= '" + cSData + "' " 
	cSql += "GROUP BY ADB.ADB_CODPRO " 


	oProcess:IncRegua1("Consultando Contratos de Compras apartir de " + SToC(cSData) ) ; oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	
	// Atualiza Todos os Produtos para NAO
	cSql := "UPDATE ZA7010 SET ZA7_PGRAMA = 'N' WHERE ZA7_PGRAMA <> 'N' "
	oProcess:IncRegua1("Definido Todos os Produtos como N-Nao") ; oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	// Inicia a Atualizacao 
	DbSelectArea("TAUX");DbGotop()
	While !EOF()
		
		// Atualiza os Produtos para SIM
		cSql := "Update ZA7010 Set ZA7_PGRAMA = 'S' WHERE ZA7_CODPRO = '" + CV(TAUX->PRODUTO) + "' " 
		
		If nIntPro == 100
			oProcess:IncRegua1("Atualizando o Produto " +  Alltrim(TAUX->PRODUTO) + " para SIM" ) ; oProcess:IncRegua2()

			nIntPro := 0
		Else
			nIntPro += 1
		EndIf 
		
		U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		
		nPAtu += 1
		
		DbSelectArea("TAUX")
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	MntLog ("1.2 ZA7_PGRAMA => SIM - Produto com Programa (Contrato) " + ENTER +;
	"Foram Atualizados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " Produtos em cada Filial ","Campo ZA7_CODPRO")
	

Return Nil
*******************************************************************************
Static Function  ExecMensal()// Execucoes Mensais
*******************************************************************************

	// Executa Consultas como Pré-Requisito Mensal
	//PreRecMes()

	If lStatusP
		// 1.3 B1_PRONOVO => Produto NOVO
		bAction 	:= {|| B1PRONOVO() }
		cTitulo   	:= "Atualizando B1_PRONOVO"
		//Processa( bAction, @cTitulo, @cMsg, @lAbort )
		oProcess := MsNewProcess():New( bAction ,cTitulo,"Lendo...",.T.)
		oProcess:Activate()


		//1.4 B1_PROATIV => SIM - Produtos Ativos 
		bAction 	:= {|| B1PROATIV() }
		cTitulo   	:= "Atualizando B1_PROATIV"
		//Processa( bAction, @cTitulo, @cMsg, @lAbort )
		oProcess := MsNewProcess():New( bAction ,cTitulo,"Lendo...",.T.)
		oProcess:Activate()
	
	
		//1.5 B1_MSBLOQ => SIM - Produtos Bloqueados 
		bAction 	:= {|| B1MSBLOQ() }
		cTitulo   	:= "Atualizando B1_MSBLOQ"
		//Processa( bAction, @cTitulo, @cMsg, @lAbort )
		oProcess := MsNewProcess():New( bAction ,cTitulo,"Lendo...",.T.)
		oProcess:Activate()

	Endif

	If lMedias 
		//2.1.1  Calcular Média do COV
		bAction 	:= {|| MediaCOV() }
		cTitulo   	:= "Calculando Media COV"
		//Processa( bAction, @cTitulo, @cMsg, @lAbort )
		oProcess := MsNewProcess():New( bAction ,cTitulo,"Lendo...",.T.)
		oProcess:Activate()

		//2.1.2  Calcular Média do COV
		bAction 	:= {|| SomaMCOV() }
		cTitulo   	:= "Calculando Soma Media COV"
		//Processa( bAction, @cTitulo, @cMsg, @lAbort )
		oProcess := MsNewProcess():New( bAction ,cTitulo,"Lendo...",.T.)
		oProcess:Activate()
	EndIf
	
	If lCoefVar 

		//2.2  Calculo do Coeficiente de Variabilidade 
		bAction 	:= {|| CoefVar() }
		cTitulo   	:= "Calculando o Coeficiente de Variabilidade"
		//Processa( bAction, @cTitulo, @cMsg, @lAbort )
		oProcess := MsNewProcess():New( bAction ,cTitulo,"Lendo...",.T.)
		oProcess:Activate()
	
	Endif 
	
	If lRankVen 

		//2.3  Calculo do Ranking de Vendas  
		bAction 	:= {|| RankVen() }
		cTitulo   	:= "Calculando o Ranking de Vendas "
		//Processa( bAction, @cTitulo, @cMsg, @lAbort )
		oProcess := MsNewProcess():New( bAction ,cTitulo,"Lendo...",.T.)
		oProcess:Activate()
	
	Endif 
	
	If lCurvABC

		//3  Calculo das Curvas ABC  
		bAction 	:= {|| CurvasABC() }
		cTitulo   	:= "Calculando Curvas ABC "
		//Processa( bAction, @cTitulo, @cMsg, @lAbort )
		oProcess := MsNewProcess():New( bAction ,cTitulo,"Lendo...",.T.)
		oProcess:Activate()
	
	Endif 

	If lCurvPQR
		//3.2 Calculo das Curvas PQR Consultado e Cliente  
		bAction 	:= {|| CurvasPQR() }
		cTitulo   	:= "Calculando Curva PQR "
		//Processa( bAction, @cTitulo, @cMsg, @lAbort )
		oProcess := MsNewProcess():New( bAction ,cTitulo,"Lendo...",.T.)
		oProcess:Activate()
	
	Endif 
	
	If lCurABCM

		//3.3  Calculo das Curvas ABC Margem 
		bAction 	:= {|| CurvABCM() }
		cTitulo   	:= "Calculando Curvas ABC Margem"
		//Processa( bAction, @cTitulo, @cMsg, @lAbort )
		oProcess := MsNewProcess():New( bAction ,cTitulo,"Lendo...",.T.)
		oProcess:Activate()
	
	Endif 
	
	If lCuABCOV

		//3.4  Calculo das Curvas ABC Ofertado e Vendido 
		bAction 	:= {|| CurABCOV() }
		cTitulo   	:= "Calculando Curvas ABC Ofertado e Vendido "
		//Processa( bAction, @cTitulo, @cMsg, @lAbort )
		oProcess := MsNewProcess():New( bAction ,cTitulo,"Lendo...",.T.)
		oProcess:Activate()
	
	Endif 
	
Return Nil
******************************************************************************
Static Function B1PRONOVO() // 1.3 B1_PRONOVO => Produto NOVO
******************************************************************************
	Local cSql 		:= ""
	Local cSData 	:= dToS(DataRef(nMeses := 6)) // Retorna 6 meses
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo oProcess:IncRegua1

	oProcess:SetRegua1(0);oProcess:SetRegua2(0)
	oProcess:IncRegua1();oProcess:IncRegua2()

	// Consulta Produtos Novos
	cSql := "SELECT B1_COD PRODUTO "
	cSql += "FROM SB1010 "
	cSql += "WHERE B1_FILIAL = '05' " 
	cSql += "AND   B1_DATREF >= '" + cSData + "' " 
	cSql += "AND   D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY B1_COD "

	oProcess:IncRegua1("Consultando Produtos Novos apartir de " + SToC(cSData) ) ; oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	
	// Atualiza Todos os Produtos para NAO
	cSql := "UPDATE SB1010 SET B1_PRONOVO = 'N' WHERE B1_PRONOVO <> 'N' "
	oProcess:IncRegua1("Definido Todos os Produtos como Novo N-Nao") ; oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	// Inicia a Atualizacao 
	DbSelectArea("TAUX");DbGotop()
	While !EOF()
		
		// Atualiza os Produtos para SIM
		cSql := "UPDATE SB1010 SET B1_PRONOVO = 'S' WHERE B1_COD = '" + CV(TAUX->PRODUTO) + "' " 
		
		If nIntPro == 100
			oProcess:IncRegua1("Atualizando o Produto " +  Alltrim(TAUX->PRODUTO) + " para SIM" ) ; oProcess:IncRegua2()
			nIntPro := 0
		Else
			nIntPro += 1
		EndIf 
		
		U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		
		nPAtu += 1
		
		DbSelectArea("TAUX")
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	MntLog (" 1.3 B1_PRONOVO => SIM - Produto NOVO " + ENTER +;
	"Foram Atualizados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " Produtos em cada Filial ","Campo B1_PRONOVO")

Return Nil
******************************************************************************
Static Function B1PROATIV()//1.4 B1_PROATIV => SIM - Produtos Ativos 
******************************************************************************
	Local cSql 		:= ""
	Local cSDataI 	:= dToS(DataRef(nMeses := 12))
	Local cSDataF 	:= dToS(DataRef(nMeses := 1 ,.T.))  
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo oProcess:IncRegua1
	Local oHTCov	:= HMNew()	// Tabela Hash COV
	Local oHTEst	:= HMNew()	// Tabela Hash Estoque
	//Local oHTPor	:= HMNew()	// Tabela Hash PO 
	Local oHTPar	:= HMNew()	// Tabela Hash Parametros Produto 
	Local aValHT	:= Nil		// Auxiliar para Obter Valor nas Hash Tables 
	
	Local nRaizF1	:= 10 // Numero de digitos que formam a RAIZ da formacao do codigo na familia 1
	Local nRaizF2	:= 7  // Numero de digitos que formam a RAIZ da formacao do codigo na familia 2
	
	Local lUF1		:= .F. // Deve Atualizar a Nivel Guarda Chuva - Familia de Correias 01
	Local lUF2		:= .F. // Deve Atualizar a Nivel Guarda Chuva - Familia de Correias 02
	
	oProcess:SetRegua1(0);oProcess:SetRegua2(0)
	oProcess:IncRegua1();oProcess:IncRegua2()

	//*************************************************************************
	// Consulta Produtos Ativos COV
	//*************************************************************************
	
	
	cSql := "SELECT ZA0_PRODUT PRODUTO "
	cSql += "FROM ZA0010 ZA0 INNER JOIN SB1010 SB1 "
	cSql += "ON SB1.B1_COD = ZA0.ZA0_PRODUT "
	
	cSql += " 				 INNER JOIN SUA010 SUA "
	cSql += "ON  ZA0.ZA0_FILIAL    =     SUA.UA_FILIAL "
	cSql += "AND ZA0.ZA0_NUMORC    =     SUA.UA_NUM "
	cSql += "AND ZA0.ZA0_CLIENT    =	 SUA.UA_CLIENTE "
	cSql += "AND ZA0.ZA0_LOJACL    =	 SUA.UA_LOJA "
	
	cSql += "WHERE ZA0_DTNECL BETWEEN '" + cSDataI + "' AND '" + cSDataF + "' "
	cSql += "AND   ZA0.D_E_L_E_T_ = ' ' "
	cSql += "AND   SB1.B1_FILIAL = '05' "
	cSql += "AND   SB1.B1_GRMAR1 IN ('000001','000002') AND SB1.B1_TIPO IN ('PA','PP','MP')"
	cSql += "AND   SB1.B1_DESC NOT LIKE '%(N USAR)%' "
	cSql += "AND   SB1.D_E_L_E_T_ = ' ' "
	
	cSql += "AND SUA.D_E_L_E_T_ = ' ' "
	cSql += "AND SUA.UA_STATUS  !=  'CAN' "
	cSql += "AND SUA.UA_CANC    !=  'S' "
	
	cSql += "GROUP BY ZA0_PRODUT "

	oProcess:IncRegua1("Consultando COV entre " + SToC(cSDataI) + " e "+ SToC(cSDataF) ) ; oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	DbSelectArea("TAUX");DbGoTop()
	While !EOF()
		HMAdd(oHTCov,{ TAUX->PRODUTO } )
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	
	//*************************************************************************
	// Consulta Produtos com Estoque Imdepa
	//*************************************************************************
	
	//-- PRODUTOS SEM FAMILIA 00
	cSql := "SELECT B2_COD PRODUTO "
	cSql += "FROM SB2010 SB2 INNER JOIN SB1010 SB1 "
	cSql += "ON SB1.B1_COD = SB2.B2_COD "
	cSql += "WHERE B2_QATU > 0  "
	cSql += "AND   SB2.D_E_L_E_T_ = ' ' "
	cSql += "AND   SB1.B1_FILIAL = '05' "
	cSql += "AND   SB1.B1_GRMAR1 IN ('000001','000002') AND SB1.B1_TIPO IN ('PA','PP','MP') "
	//cSql += "AND   SB1.B1_DESC NOT LIKE '%(N USAR)%' "
	cSql += "AND   SB1.D_E_L_E_T_ = ' ' "
	//cSql += "AND   SUBSTR(SB1.B1_COD,1,2) = '00' " // CODIGO INICIO COM "00"
	cSql += "GROUP BY B2_COD "
	/*
	cSql += "UNION "
	
	//-- PRODUTOS FAMILIA 01
	cSql += "SELECT SB1.B1_COD PRODUTO "
	cSql += "FROM  "
	cSql += "	( 	SELECT SUBSTR(B2_COD,1,"+CV(nRaizF1)+") GC_CODIGO FROM SB2010  "
	cSql += "		WHERE D_E_L_E_T_ = ' ' "
	cSql += "		AND   B2_QATU > 0  "
	//cSql += "AND   SUBSTR(B2_COD,1,"+CV(nRaizF1)+") = '0110303570' "
	cSql += "		GROUP BY SUBSTR(B2_COD,1,"+CV(nRaizF1)+") ) SB2 INNER JOIN SB1010 SB1 "
	cSql += "ON SUBSTR(B1_COD,1,"+CV(nRaizF1)+") = SB2.GC_CODIGO "
	cSql += "WHERE SB1.B1_FILIAL = '05' "
	cSql += "AND   SB1.B1_GRMAR1 IN ('000001','000002') AND SB1.B1_TIPO IN ('PA','PP','MP') "
	//cSql += "AND   SB1.B1_DESC NOT LIKE '%(N USAR)%' "
	cSql += "AND   SB1.D_E_L_E_T_ = ' ' "
	cSql += "AND   SUBSTR(SB1.B1_COD,1,2) = '01' " // CODIGO INICIO COM "01"
	cSql += "GROUP BY SB1.B1_COD "

	cSql += "UNION "

	//-- PRODUTOS FAMILIA 02
	cSql += "SELECT SB1.B1_COD PRODUTO "
	cSql += "FROM  "
	cSql += "	( 	SELECT SUBSTR(B2_COD,1,"+CV(nRaizF2)+") GC_CODIGO FROM SB2010  "
	cSql += "		WHERE D_E_L_E_T_ = ' ' "
	cSql += "		AND   B2_QATU > 0  "
	//cSql += " AND   SUBSTR(B2_COD,1,"+CV(nRaizF2)+") = '0221023' "
	cSql += "		GROUP BY SUBSTR(B2_COD,1,"+CV(nRaizF2)+") ) SB2 INNER JOIN SB1010 SB1 "
	cSql += "ON SUBSTR(B1_COD,1,"+CV(nRaizF2)+") = SB2.GC_CODIGO "
	cSql += "WHERE SB1.B1_FILIAL = '05' "
	cSql += "AND   SB1.B1_GRMAR1 IN ('000001','000002') AND SB1.B1_TIPO IN ('PA','PP','MP') "
	//cSql += "AND   SB1.B1_DESC NOT LIKE '%(N USAR)%' "
	cSql += "AND   SB1.D_E_L_E_T_ = ' ' "
	cSql += "AND   SUBSTR(SB1.B1_COD,1,2) = '02' " // CODIGO INICIO COM "02"
	cSql += "GROUP BY SB1.B1_COD "
	*/
	
	oProcess:IncRegua1("Consultando Estoque dos Produtos ") ; oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )

	DbSelectArea("TAUX");DbGoTop()
	While !EOF()
		HMAdd(oHTEst,{ TAUX->PRODUTO } )
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()


	//*************************************************************************
	// Consulta Status dos Produtos 
	//*************************************************************************

	//cSql := "SELECT B1_COD PRODUTO, B1_PRONOVO PRONOVO, ZA7_ITEMNO ITEMNOVO, ZA7_PGRAMA PROGRAMA, ZA7_PPCOMP PEDIDO, B1_ESTFOR ESTFOR, B1_ESTSEG ESTSEG, "
	cSql := "SELECT B1_COD PRODUTO, B1_PRONOVO PRONOVO, ZA7_ITEMNO ITEMNOVO, ZA7_PGRAMA PROGRAMA, ZA7_PPCOMP PEDIDO, B1_ESTSEG ESTSEG, "
	cSql += "CASE WHEN SB1.B1_DESC LIKE '%(N USAR)%' THEN 'NAO' "
	cSql += "ELSE 'SIM' END USAR "	
	cSql += "FROM ( SELECT '05' B1_FILIAL, B1_COD,B1_DESC,  MIN(B1_PRONOVO) B1_PRONOVO, SUM(B1_ESTSEG) B1_ESTSEG "
	cSql += "		FROM SB1010 "
	cSql += "		WHERE D_E_L_E_T_ = ' ' "
	//cSql += "		AND   B1_COD IN('000000007172H','000000028755Z') " 
	cSql += "		AND   B1_GRMAR1 IN ('000001','000002') "
	cSql += "		AND   B1_TIPO IN ('PA','PP','MP') "
	//cSql += "		AND   B1_DESC NOT LIKE '%(N USAR)%' " 
	cSql += "		GROUP BY B1_COD, B1_DESC ) SB1 INNER JOIN ZA7010 ZA7 "
	cSql += "ON SB1.B1_FILIAL = ZA7.ZA7_FILIAL "
	cSql += "AND SB1.B1_COD = ZA7.ZA7_CODPRO "
	
	//cSql += "WHERE SB1.B1_FILIAL = '05' "
	//cSql += "AND   SB1.B1_GRMAR1 IN ('000001','000002') AND SB1.B1_TIPO IN ('PA','PP','MP') "
	//cSql += "AND   SB1.B1_DESC NOT LIKE '%(N USAR)%' "
	//cSql += "AND   SB1.D_E_L_E_T_ = ' ' "
	
	cSql += "WHERE   ZA7.D_E_L_E_T_ = ' ' "
	//cSql += "GROUP BY B1_COD, B1_DESC, B1_PRONOVO, ZA7_ITEMNO, ZA7_PGRAMA, ZA7_PPCOMP, B1_ESTFOR, B1_ESTSEG "
	cSql += "GROUP BY B1_COD, B1_DESC, B1_PRONOVO, ZA7_ITEMNO, ZA7_PGRAMA, ZA7_PPCOMP, B1_ESTSEG "
	
	oProcess:IncRegua1("Consulta Parametros dos Produtos ") ; oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )


	//*************************************************************************
	// Atualiza Todos os Produtos para NAO
	//*************************************************************************
	
	// TEMP
	cSql := "UPDATE SB1010 SET B1_PROATIV = 'N' WHERE B1_PROATIV <> 'N' AND B1_GRMAR1 IN ('000001','000002') AND B1_TIPO IN ('PA','PP','MP') " 
	oProcess:IncRegua1("Definido Todos os Produtos como Ativo N-Nao"); oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	// Inicia a Atualizacao 
	DbSelectArea("TAUX");DbGotop()
	While !EOF()
		
		lUpd := lUF1 := lUF2 := .F. // Deve Atualizar o Produto e/ou Familias ?
		
		// Produto Possui COV ou Estoque 
		If HMGet(oHTCov , TAUX->PRODUTO , @aValHT) .Or. HMGet(oHTEst , TAUX->PRODUTO , @aValHT) //.Or. HMGet(oHTPor , TAUX->PRODUTO , @aValHT)
			
			lUpd := .T.
			
			// Avalia se eh Correias, Neste Caso deve Atualizar o Guarda-Chuva...Nao importa qual é o Filho, O Pai "PA" e Todos os "PP"'s devem ser ATIVADOS.
			If Substr(CV(TAUX->PRODUTO),1,2) > "00"  
				
				If Substr(CV(TAUX->PRODUTO),1,2) == "01" // Correias, Familia 01 
					lUF1 := .T.
				EndIf
				If Substr(CV(TAUX->PRODUTO),1,2) == "02" // Correias, Familia 02
					lUF2 := .T.
				EndIf
			Else
				lUF1 := lUF2 := .F.
			Endif
				
		ElseIf TAUX->USAR == "SIM" .AND. ( TAUX->PRONOVO == "S" .Or.  TAUX->ITEMNOVO  == "S" .Or.  TAUX->PROGRAMA  == "S" .Or.  TAUX->PEDIDO == "S" .Or. (  TAUX->ESTSEG >= 1 ))
	
			lUpd := .T.
	
		EndIf
		
		
		If lUpd
		
			// Atualiza os Produtos para SIM

			If lUF1 // Correias Familia 01
				cSql := "UPDATE SB1010 SET B1_PROATIV = 'S' WHERE D_E_L_E_T_ = ' ' AND SUBSTR(B1_COD,1,"+CV(nRaizF1)+") = '" + SUBSTR(CV(TAUX->PRODUTO),1,nRaizF1) + "' "
			ElseIf lUF2 // Correias Familia 02
				cSql := "UPDATE SB1010 SET B1_PROATIV = 'S' WHERE D_E_L_E_T_ = ' ' AND SUBSTR(B1_COD,1,"+CV(nRaizF2)+") = '" + SUBSTR(CV(TAUX->PRODUTO),1,nRaizF2) + "' "
			Else // Nao eh correias
				cSql := "UPDATE SB1010 SET B1_PROATIV = 'S' WHERE D_E_L_E_T_ = ' ' AND B1_COD = '" + CV(TAUX->PRODUTO) + "' "
			EndIf
			
			If nIntPro == 100
				oProcess:IncRegua1("Atualizando o Produto " +  Alltrim(TAUX->PRODUTO) + " para SIM" ); oProcess:IncRegua2()
				nIntPro := 0
			Else
				nIntPro += 1
			EndIf 
		
			U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
			//ConOut("MRP | Atualizando o Produto " +  Alltrim(TAUX->PRODUTO) + " para SIM -> " + Alltrim(cSql))
			nPAtu += 1
			
		EndIf
		
		DbSelectArea("TAUX")
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	//MsgInfo ("Foram Atualizados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " Produtos em cada Filial ","Campo B1_PROATIV")
	MntLog("1.4 B1_PROATIV => SIM - Produtos Ativos " + ENTER +;
	"Foram Atualizados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " Produtos em cada Filial ","Campo B1_PROATIV")
	
Return Nil
******************************************************************************
Static Function B1MSBLOQ()//1.5 B1_MSBLOQ => SIM - Produtos Bloqueados 
******************************************************************************
	Local cSql 		:= ""
	Local cSData 	:= dToS(DataRef(nMeses := 24)) 
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo oProcess:IncRegua1
	Local oHTCov	:= HMNew()	// Tabela Hash COV
	Local aValHT	:= Nil		// Auxiliar para Obter Valor nas Hash Tables 
	
	oProcess:SetRegua1(0);oProcess:SetRegua2(0)
	oProcess:IncRegua1();oProcess:IncRegua2()

	//*************************************************************************
	// Consulta Produtos com Movimento COV
	//*************************************************************************
	cSql := "SELECT ZA0_PRODUT PRODUTO FROM ZA0010 ZA0 INNER JOIN SB1010 SB1 "
	cSql += "ON ZA0.ZA0_PRODUT = SB1.B1_COD "
	
	cSql += " 				 INNER JOIN SUA010 SUA "
	cSql += "ON  ZA0.ZA0_FILIAL    =     SUA.UA_FILIAL "
	cSql += "AND ZA0.ZA0_NUMORC    =     SUA.UA_NUM "
	cSql += "AND ZA0.ZA0_CLIENT    =	 SUA.UA_CLIENTE "
	cSql += "AND ZA0.ZA0_LOJACL    =	 SUA.UA_LOJA "

	cSql += "WHERE ZA0_DTNECL >= '" + cSData + "' "
	cSql += "AND   ZA0.D_E_L_E_T_ = ' ' "
	cSql += "AND   SB1.B1_FILIAL = '05' " 
	cSql += "AND   SB1.B1_GRMAR1 IN ('000001','000002') AND SB1.B1_TIPO IN ('PA','PP','MP') "
	cSql += "AND   SB1.D_E_L_E_T_ = ' ' "
	
	cSql += "AND SUA.D_E_L_E_T_ = ' ' "
	cSql += "AND SUA.UA_STATUS  !=  'CAN' "
	cSql += "AND SUA.UA_CANC    !=  'S' "

	cSql += "GROUP BY ZA0_PRODUT "

	oProcess:IncRegua1("Consultando COV apartir de  " + SToC(cSData) ); oProcess:IncRegua2() 
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra := .F., lChange := .F. )
	
	DbSelectArea("TAUX")
	While !EOF()
		HMAdd(oHTCov,{ TAUX->PRODUTO } )
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()

	//*************************************************************************
	// Verificando Data de Referencia de Produtos  
	//*************************************************************************
	cSql := "SELECT B1_COD PRODUTO " 
	cSql += "FROM SB1010 SB1 "
	cSql += "WHERE SB1.B1_FILIAL = '05' "
	cSql += "AND   SB1.B1_DATREF < '" + cSData + "' "
	cSql += "AND   SB1.B1_PROATIV = 'N' "
	//cSql += "AND   SB1.B1_MSBLQL IN (' ','2') "
	cSql += "AND   SB1.B1_GRMAR1 IN ('000001','000002') AND SB1.B1_TIPO IN ('PA','PP','MP') "
	cSql += "AND   SB1.D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY B1_COD"
	
	oProcess:IncRegua1("Verificando Produtos ATIVOS e com Data REF apartir de  " + SToC(cSData) ); oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	
	cSql := "UPDATE SB1010 SET B1_MSBLQL = '2' WHERE B1_MSBLQL <> '2' AND B1_GRMAR1 IN ('000001','000002') AND B1_TIPO IN ('PA','PP','MP') " 
	oProcess:IncRegua1("Definido Todos os Produtos como Desbloqueados N-Nao"); oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	
	DbSelectArea("TAUX");DbGoTop()
	While !EOF()
		
		// Verifica se o Produto NAO esta no COV nos Ultimos 24 meses 
		If !HMGet(oHTCov , TAUX->PRODUTO , @aValHT)
		
			// Atualiza os Produtos para SIM
			cSql := "UPDATE SB1010 SET B1_MSBLQL = '1' WHERE B1_COD = '" + CV(TAUX->PRODUTO) + "' "
	
			If nIntPro == 100
				oProcess:IncRegua1("Atualizando o Produto " +  Alltrim(TAUX->PRODUTO) + " para BLOQUEADO" ); oProcess:IncRegua2()
				nIntPro := 0
			Else
				nIntPro += 1
			EndIf 
		
			U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		
			nPAtu += 1
			
		EndIf
		
		
		
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	MntLog ("1.5 B1_MSBLOQ => SIM - Produtos Bloqueados " + ENTER +;
	"Foram Bloqueados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " Produtos em cada Filial ","Campo B1_MSBLQL")

Return Nil 
******************************************************************************
Static Function MediaCOV()// 2.1.1 Calculo Média do COV
******************************************************************************
	Local cSql 		:= ""
	Local nPeriodo  := 12 // Divisor para media Mes 
	Local cSDataI 	:= dToS(DataRef(nMeses := nPeriodo))
	Local cSDataF 	:= dToS(DataRef(nMeses := 1 ,.T.))  
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo oProcess:IncRegua1
	Local oHTCov	:= HMNew()	// Tabela Hash COV
	Local aValHT	:= Nil		// Auxiliar para Obter Valor nas Hash Tables 


	oProcess:SetRegua1(0);oProcess:SetRegua2(0)
	oProcess:IncRegua1();oProcess:IncRegua2()
	
	oProcess:IncRegua1("Apagando Tabela Temporária" ); oProcess:IncRegua2() 
	U_ExecMySql( cSql := "Drop Table MEDCOV" , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	
	//*************************************************************************
	// Montando Media do COV  
	//*************************************************************************
	cSql := "CREATE TABLE MEDCOV AS "
	cSql += "SELECT FILIAL, PRODUTO, SUM(MCONS) MCONS, SUM(MOFER) MOFER, SUM(MVREV) MVREV, SUM(MFATU) MFATU "
	cSql += "FROM ( "

	cSql += "SELECT SA1.A1_ESTQFIL FILIAL, ZA0.ZA0_PRODUT PRODUTO, " 
	cSql += "Round( Sum(ZA0.ZA0_QUANTD) / "+cValToChar(nPeriodo)+",2) MCONS, " 
	cSql += "Round( Sum(ZA0.ZA0_QOATEN) / "+cValToChar(nPeriodo)+",2) MOFER, " 
	cSql += "Round( Sum(ZA0.ZA0_VENDRE) / "+cValToChar(nPeriodo)+",2) MVREV, "
	cSql += "Round( Sum(0) ,2) MFATU " 
	cSql += "FROM ZA0010 ZA0 INNER JOIN SB1010 SB1 "
	cSql += "ON ZA0.ZA0_PRODUT = SB1.B1_COD "
	
	cSql += " 				 INNER JOIN SUA010 SUA "
	cSql += "ON  ZA0.ZA0_FILIAL    =     SUA.UA_FILIAL "
	cSql += "AND ZA0.ZA0_NUMORC    =     SUA.UA_NUM "
	cSql += "AND ZA0.ZA0_CLIENT    =	 SUA.UA_CLIENTE "
	cSql += "AND ZA0.ZA0_LOJACL    =	 SUA.UA_LOJA "

	cSql += " 				 INNER JOIN SA1010 SA1 "
	cSql += "ON  ZA0.ZA0_CLIENT    =     SA1.A1_COD "
	cSql += "AND ZA0.ZA0_LOJACL    =     SA1.A1_LOJA "

	cSql += "WHERE ZA0.ZA0_DTNECL BETWEEN '" + cSDataI + "' AND '" + cSDataF + "' "
	cSql += "AND ZA0.D_E_L_E_T_ = ' ' "
	cSql += "AND SA1.D_E_L_E_T_ = ' ' "
	cSql += "AND SB1.B1_FILIAL = '05' "
	cSql += "AND SB1.B1_GRMAR1 IN ('000001','000002') AND SB1.B1_TIPO IN ('PA','PP','MP') "
	cSql += "AND SB1.D_E_L_E_T_ = ' ' "
	
	cSql += "AND SUA.D_E_L_E_T_ = ' ' "
	cSql += "AND SUA.UA_STATUS  !=  'CAN' "
	cSql += "AND SUA.UA_CANC    !=  'S' "

	cSql += "GROUP BY SA1.A1_ESTQFIL, ZA0.ZA0_PRODUT "
	
	cSql += "UNION "   
	
	cSql += "SELECT  SA1.A1_ESTQFIL FILIAL, SD2.D2_COD PRODUTO, "
	cSql += "Round( Sum(0) ,2) MCONS, " 
	cSql += "Round( Sum(0) ,2) MOFER, " 
	cSql += "Round( Sum(0) ,2) MVREV, "
	cSql += "Round( Sum(SD2.D2_QUANT) / "+cValToChar(nPeriodo)+",2) MFATU "

	cSql += "FROM SD2010 SD2 INNER JOIN SF2010 SF2 "
	cSql += "ON   SD2.D2_FILIAL  = SF2.F2_FILIAL "
	cSql += "AND  SD2.D2_DOC     = SF2.F2_DOC "
	cSql += "AND  SD2.D2_SERIE   = SF2.F2_SERIE "
	cSql += "AND  SD2.D2_CLIENTE = SF2.F2_CLIENTE "
	cSql += "AND  SD2.D2_LOJA    = SF2.F2_LOJA "

	cSql += "INNER JOIN SF4010 SF4 "
	cSql += "ON  SD2.D2_FILIAL = SF4.F4_FILIAL "
	cSql += "AND SD2.D2_TES    = SF4.F4_CODIGO "

	cSql += "INNER JOIN SB1010 SB1 "
	cSql += "ON SD2.D2_COD = SB1.B1_COD "

	cSql += "INNER JOIN SA1010 SA1 "
	cSql += "ON  SD2.D2_CLIENTE = SA1.A1_COD "
	cSql += "AND SD2.D2_LOJA   	= SA1.A1_LOJA "
	
	cSql += "WHERE SF2.F2_EMISSAO BETWEEN '" + cSDataI + "' AND '" + cSDataF + "' "
	cSql += "AND SF4.F4_ESTOQUE = 'S' "
	cSql += "AND SF4.F4_DUPLIC = 'S' "
	cSql += "AND SF2.F2_CLIENTE <> 'N00000' "
	cSql += "AND SD2.D_E_L_E_T_ = ' ' "
	cSql += "AND SA1.D_E_L_E_T_ = ' ' "
	cSql += "AND SF2.D_E_L_E_T_ = ' ' "
	cSql += "AND SF4.D_E_L_E_T_ = ' ' "
	cSql += "AND SB1.B1_FILIAL = '05' "
	cSql += "AND SB1.B1_GRMAR1 IN ('000001','000002') AND SB1.B1_TIPO IN ('PA','PP','MP') "
	cSql += "AND SB1.D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY SA1.A1_ESTQFIL, SD2.D2_COD "
	cSql += ") " 
	cSql += "GROUP BY FILIAL, PRODUTO "
	cSql += "ORDER BY PRODUTO, FILIAL "

	oProcess:IncRegua1("Criando Tabela Auxiliar Media do COV Periodo: ["+SToC(cSDataI)+" ate "+SToC(cSDataF)+"] " ); oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "", cModo := "E",  lMostra, lChange := .F. )
	lMostra:= .F.
	
	cSql := "SELECT * FROM MEDCOV"
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	//*************************************************************************
	// Zerando Todos as Medias do COV
	//*************************************************************************
	
	cSql := "UPDATE ZA7010 SET ZA7_M12CP = 0, ZA7_M12OP  = 0, ZA7_M12VP  = 0, ZA7_M12VRP  = 0 "
	oProcess:IncRegua1("Zerando as Médias [ZA7_M12CP,ZA7_M12OP,ZA7_M12VP,ZA7_M12VRP]") ; oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )


	DbSelectArea("TAUX");DbGoTop()
	While !EOF()
		
			// Atualiza os Produtos para SIM
			cSql := "UPDATE ZA7010 SET "
			cSql += "ZA7_M12CP 	= "+CV(TAUX->MCONS)+", " // Média 12 Meses Consultado.
			cSql += "ZA7_M12OP  = "+CV(TAUX->MOFER)+", " // Média 12 Meses Ofertado.
			cSql += "ZA7_M12VP  = "+CV(TAUX->MFATU)+", " // Média 12 Meses Vendido.
			cSql += "ZA7_M12VRP = "+CV(TAUX->MVREV)+"  " // Média 12 Meses Venda Revisada.
			cSql += "WHERE ZA7_FILIAL = "+CV(TAUX->FILIAL)+" AND ZA7_CODPRO = '" + CV(TAUX->PRODUTO) + "' "
	
			If nIntPro == 100
				oProcess:IncRegua1("Atualizando as Medias da [Filial-Produto] " + Alltrim(TAUX->FILIAL) +"-"+Alltrim(TAUX->PRODUTO) + "" ); oProcess:IncRegua2() 
				nIntPro := 0
			Else
				nIntPro += 1
			EndIf 
		
			U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		
			nPAtu += 1
			
			//eVal(bAbort)
			
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	MntLog (" 2.1.1 Calculo Média do COV " + ENTER +;
	"Foram Atualizados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " Produtos ","Campos [ZA7_M12CP,ZA7_M12OP,ZA7_M12VP,ZA7_M12VRP]")

Return Nil
******************************************************************************
Static Function SomaMCOV()// 2.1.2 - Soma Media do COV  
******************************************************************************
	Local cSql 		:= ""
	
	Local cSDataI 	:= dToS(DataRef(nMeses := 12))
	Local cSDataF 	:= dToS(DataRef(nMeses := 1,.T. ))  
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo oProcess:IncRegua1
	Local oHTCov	:= HMNew()	// Tabela Hash COV
	Local aValHT	:= Nil		// Auxiliar para Obter Valor nas Hash Tables 

	
	oProcess:SetRegua1(0);oProcess:SetRegua2(0)
	oProcess:IncRegua1();oProcess:IncRegua2()
	//*************************************************************************
	// Montando Media do COV  
	//*************************************************************************

	cSql := "SELECT SB1.B1_CODITE CODITE,  SUM(MCONS) SMCONS, SUM(MOFER) SMOFER, SUM(MVREV) SMVREV, SUM(MFATU) SMFATU "
	cSql += "FROM MEDCOV MED, "
	cSql += "SB1010 SB1 "
	cSql += "WHERE SB1.B1_FILIAL = '05' "
	cSql += "AND   SB1.B1_COD = MED.PRODUTO "
	cSql += "GROUP BY SB1.B1_CODITE "

	oProcess:IncRegua1("Montando Soma Media do COV por CODITE Periodo: ["+SToC(cSDataI)+" ate "+SToC(cSDataF)+"] " ); oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )

	
	//*************************************************************************
	// Zerando Todos as Medias do COV
	//*************************************************************************
	
	cSql := "UPDATE ZA7010 SET ZA7_M12CPI = 0, ZA7_M12OPI  = 0, ZA7_M12VPI  = 0, ZA7_M12VRI  = 0 "
	oProcess:IncRegua1("Zerando Todas as Somas de Médias [ZA7_M12CPI,ZA7_M12OPI,ZA7_M12VPI,ZA7_M12VRI]"); oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )


	DbSelectArea("TAUX");DbGoTop()
	While !EOF()
		
			// Atualiza os CODITE 
			cSql := "UPDATE ZA7010 SET "
			cSql += "ZA7_M12CPI = " + CV(TAUX->SMCONS) + ", " // Soma da Média do Consultado.
			cSql += "ZA7_M12OPI = " + CV(TAUX->SMOFER) + ", " // Soma da Média do Ofertado.
			cSql += "ZA7_M12VPI = " + CV(TAUX->SMFATU) + ", " // Soma da Média do Vendido.
			cSql += "ZA7_M12VRI = " + CV(TAUX->SMVREV) + "  "  // Soma da Média do Venda Revisada.
			cSql += "WHERE ZA7_CODITE = '" + CV(TAUX->CODITE) + "' "
			
			If nIntPro == 100
				oProcess:IncRegua1("Atualizando as Somas Media do CodItem " + Alltrim(TAUX->CODITE) + "" ); oProcess:IncRegua2()
				nIntPro := 0
			Else
				nIntPro += 1
			EndIf 
			
			U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		
			nPAtu += 1
			
			//eVal(bAbort)
		
		DbSelectArea("TAUX")
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	MntLog ("2.1.2 - Soma Media do COV " + ENTER +;
	"Foram Atualizados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " CodItens em Cada Filial  ","Campos [ZA7_M12CPI,ZA7_M12OPI,ZA7_M12VPI,ZA7_M12VRI]")

Return Nil
*******************************************************************************
Static Function CoefVar()// 2.2  Calculo do Coeficiente de Variabilidade
*******************************************************************************

	Local cSql := ""
	Local nPeriodo  := 36 // numero de meses para divisor 
	Local cSDataI 	:= dToS(DataRef(nMeses := nPeriodo))
	Local cSDataF 	:= dToS(DataRef(nMeses := 1,.T. ))  
	
	Local cCoefMin 	:= Alltrim(cValToChar(0.25))
	Local cCoefMax 	:= Alltrim(cValToChar(1.25))
	
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo oProcess:IncRegua1
	
	
	oProcess:SetRegua1(0);oProcess:SetRegua2(0)
	oProcess:IncRegua1();oProcess:IncRegua2()

	// Dropar Tabela Tamporaria COEFVAR
	oProcess:IncRegua1("Apagando Tabela Temporária" ); oProcess:IncRegua2()
	U_ExecMySql( cSql := "Drop Table COEFVAR" , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	
	//***************************************************************	
	// Criando Tabela Atualizada Base para o Calculo do Coeficiente ja com SOMA VR 
	oProcess:IncRegua1("Criando Tabela Base Coeficiente Variavel [COEFVAR]" ); oProcess:IncRegua2()
	
	cSql := "CREATE TABLE COEFVAR AS "
	cSql += "SELECT SB1.B1_CODITE 				ITEM, " 
	cSql += "		SUBSTR(ZA0.ZA0_DTNECL,1,6) 	MESANO, "
	cSql += "ROUND( SUM(ZA0.ZA0_VENDRE),2 )		SOMAVR, "
	cSql += "ROUND( SUM(0) )					MEDIAVR, "
	cSql += "ROUND( SUM(0) ) 					VLABS, "
	cSql += "ROUND( SUM(0) ) 					MEDIAABS, "
	cSql += "ROUND( SUM(0) ) 					DESVPAD, "
	cSql += "ROUND( SUM(0) ) 					COEFICIENTE "
	cSql += "FROM ZA0010 ZA0 INNER JOIN SB1010 SB1 "
	cSql += "ON   ZA0.ZA0_PRODUT = SB1.B1_COD "
	
	cSql += " 				 INNER JOIN SUA010 SUA "
	cSql += "ON  ZA0.ZA0_FILIAL    =     SUA.UA_FILIAL "
	cSql += "AND ZA0.ZA0_NUMORC    =     SUA.UA_NUM "
	cSql += "AND ZA0.ZA0_CLIENT    =	 SUA.UA_CLIENTE "
	cSql += "AND ZA0.ZA0_LOJACL    =	 SUA.UA_LOJA "
	
	cSql += "WHERE ZA0.ZA0_DTNECL BETWEEN '" + cSDataI + "' AND '" + cSDataF + "' "
	cSql += "AND   ZA0.D_E_L_E_T_ = ' ' "
	cSql += "AND   SB1.B1_FILIAL = '05' "
	cSql += "AND   SB1.B1_GRMAR1 IN ('000001','000002') AND SB1.B1_TIPO IN ('PA','PP','MP') "
	cSql += "AND   SB1.D_E_L_E_T_ = ' ' "
	
	cSql += "AND SUA.D_E_L_E_T_ = ' ' "
	cSql += "AND SUA.UA_STATUS  !=  'CAN' "
	cSql += "AND SUA.UA_CANC    !=  'S' "
	
	cSql += "GROUP BY SB1.B1_CODITE, SUBSTR(ZA0.ZA0_DTNECL,1,6) "

	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	//***************************************************************
	// Indexando Tabela  [COEFVAR] pelo Item para melhor performance  
	oProcess:IncRegua1("Indexando Tabela [COEFVAR] por Item " ); oProcess:IncRegua2()
	cSql := "CREATE INDEX SIGA.IDX_COEFVAR ON SIGA.COEFVAR(ITEM) TABLESPACE SIGA_INDEX"
	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra , lChange := .F. )
	
	
	//***************************************************************
	// Calculando Média VR por Item   
	oProcess:IncRegua1("Calculando Média VR por Item " ); oProcess:IncRegua2()
	
	DropTAux() // Dropa a Tabela Temporaria Auxiliar do MRP
	 
	cSql := "CREATE TABLE TAUX_MRP AS "  
	cSql += "SELECT 	SB1.B1_CODITE 				ITEM, " 
	cSql += "ROUND( SUM(ZA0.ZA0_VENDRE) / "+CV(nPeriodo)+" ,4 ) MEDIAVR "
	cSql += "FROM ZA0010 ZA0 INNER JOIN SB1010 SB1 "
	cSql += "ON   ZA0.ZA0_PRODUT = SB1.B1_COD "
	
	cSql += " 				 INNER JOIN SUA010 SUA "
	cSql += "ON  ZA0.ZA0_FILIAL    =     SUA.UA_FILIAL "
	cSql += "AND ZA0.ZA0_NUMORC    =     SUA.UA_NUM "
	cSql += "AND ZA0.ZA0_CLIENT    =	 SUA.UA_CLIENTE "
	cSql += "AND ZA0.ZA0_LOJACL    =	 SUA.UA_LOJA "
	
	cSql += "WHERE ZA0.ZA0_DTNECL BETWEEN  '" + cSDataI + "' AND '" + cSDataF + "' "
	cSql += "AND   ZA0.D_E_L_E_T_ = ' ' "
	cSql += "AND   SB1.B1_FILIAL = '05' "
	cSql += "AND   SB1.B1_GRMAR1 IN ('000001','000002') AND SB1.B1_TIPO IN ('PA','PP','MP') "
	cSql += "AND   SB1.D_E_L_E_T_ = ' ' "
	
	cSql += "AND SUA.D_E_L_E_T_ = ' ' "
	cSql += "AND SUA.UA_STATUS  !=  'CAN' "
	cSql += "AND SUA.UA_CANC    !=  'S' "

	cSql += "GROUP BY SB1.B1_CODITE "
	
	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	//***************************************************************
	// Atualizando Média VR por Item   
	oProcess:IncRegua1("Atualizando Média VR na Tabela [COEFVAR]" ); oProcess:IncRegua2()
	
	cSql := "UPDATE COEFVAR CV SET CV.MEDIAVR = ( SELECT AUX.MEDIAVR FROM TAUX_MRP AUX WHERE AUX.ITEM = CV.ITEM )"
	cSql += "WHERE CV.ITEM IN ( SELECT AUX.ITEM FROM TAUX_MRP AUX WHERE AUX.ITEM = CV.ITEM )"
	
	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	//***************************************************************
	// Calculando Valor Absoluto   
	oProcess:IncRegua1("Calculando Valor Absoluto e Aplicando na Tabela [COEFVAR]" ); oProcess:IncRegua2()
	cSql := "UPDATE COEFVAR CV SET CV.VLABS =  ROUND ( ABS(SOMAVR - MEDIAVR) , 2 )"
	
	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	//***************************************************************
	// Calculando Média do Valor  Absoluto   
	oProcess:IncRegua1("Calculando Desvio Padrao" ); oProcess:IncRegua2()
	
	DropTAux() // Dropa a Tabela Temporaria Auxiliar do MRP
	
	cSql := "CREATE TABLE TAUX_MRP AS "  
	cSql += "SELECT CV.ITEM,  ROUND( SUM(CV.VLABS),4) SOMA, ROUND( "+CV(nPeriodo)+",4) QTD, ROUND( SUM(CV.VLABS) / "+CV(nPeriodo)+" ,4 ) DESVPAD " 
	cSql += "FROM COEFVAR CV GROUP BY CV.ITEM "
	
	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	

	//***************************************************************
	// Atualizando Desvio Padrao
	oProcess:IncRegua1("Calculando Desvio Padrao e Aplicando na Tabela [COEFVAR]" ); oProcess:IncRegua2()
	
	cSql := "UPDATE COEFVAR CV SET CV.DESVPAD = ( SELECT AUX.DESVPAD FROM TAUX_MRP AUX WHERE AUX.ITEM = CV.ITEM )"
	cSql += "WHERE CV.ITEM IN ( SELECT AUX.ITEM FROM TAUX_MRP AUX WHERE AUX.ITEM = CV.ITEM )"
	
	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	/*
	//***************************************************************
	// Calculando Desvio Padrao 
	oProcess:IncRegua1("Calculando Desvio Padrao e Aplicando na Tabela [COEFVAR]" ); oProcess:IncRegua2()
	cSql := "UPDATE COEFVAR SET COEFVAR.DESVPAD = ROUND( ( COEFVAR.MEDIAABS / "+CV(nPeriodo)+" ) ,4 )"
	
	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	*/

	//***************************************************************
	// Calculando Coeficiente e Atualizando na Tabela 
	oProcess:IncRegua1( "Calculando Coeficiente e Atualizando na Tabela [COEFVAR]" ); oProcess:IncRegua2()
	cSql := "UPDATE COEFVAR SET COEFICIENTE = CASE " 
	cSql += "WHEN ROUND( DESVPAD / DECODE(MEDIAVR,0,1,MEDIAVR) ,4) < "+CV(cCoefMin)+" THEN "+CV(cCoefMin)+" " 
	cSql += "WHEN ROUND( DESVPAD / DECODE(MEDIAVR,0,1,MEDIAVR) ,4) > "+CV(cCoefMax)+" THEN "+CV(cCoefMax)+" "
	cSql += "ELSE ROUND( DESVPAD / DECODE(MEDIAVR,0,1,MEDIAVR) ,4) "
	cSql += "END "

	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	//***************************************************************
	// Preparando para Atualizar ZA7_CVVRIT
	oProcess:IncRegua1( "incianco atualizacao do Campo ZA7_CVVRIT " ); oProcess:IncRegua2()
	
	cSql := "SELECT ITEM, MAX(COEFICIENTE) COEFICIENTE FROM COEFVAR GROUP BY ITEM"
	U_ExecMySql( cSql, cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	

	DbSelectArea("TAUX");DbGoTop()
	While !EOF()
		
			// Atualizando ZA7_CVVRIT
			cSql := "UPDATE ZA7010 SET "
			cSql += "ZA7_CVVRIT  = " + CV(TAUX->COEFICIENTE) + " " // Soma da Média do Consultado.
			cSql += "WHERE ZA7_CODITE = '" + CV(TAUX->ITEM) + "' "
			
			If nIntPro == 100
				oProcess:IncRegua1("Atualizando Coeficiente [ZA7_CVVRIT] do ITEM " + Alltrim(TAUX->ITEM) + "" ); oProcess:IncRegua2()
				nIntPro := 0
			Else
				nIntPro += 1
			EndIf 
		
			U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		
			nPAtu += 1
			
			//eVal(bAbort)
			
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	MntLog ("2.2  Calculo do Coeficiente de Variabilidade " + ENTER +; 
	"Foram Atualizados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " CODITE em Cada Filial  ","Campo [ZA7_CVVRIT]")	
	
Return Nil 
*******************************************************************************
Static Function RankVen()//2.3  Calculo do Ranking de Vendas  
*******************************************************************************
	Local cSql := ""
	Local cSDataI 	:= dToS(DataRef(nMeses := 12))
	Local cSDataF 	:= dToS(DataRef(nMeses := 1,.T. ))  
	
	Local nPAtuPV 	:= 0 // Total de Produtos Pecas vendas 
	Local nPAtuVV 	:= 0 // Total de Produtos Valor Vendas 
	Local nPAtuPR 	:= 0 // Total de Produtos Pecas Revisadas
	Local nPAtuVR 	:= 0 // Total de Produtos Valor revisadas 
	
	Local nIntPro 	:= 0 // Intervalo oProcess:IncRegua1
	
	oProcess:SetRegua1(0);oProcess:SetRegua2(0)
	oProcess:IncRegua1();oProcess:IncRegua2()
	
	//***************************************************************
	// Dropar Tabela Tamporaria RANKVEN
	oProcess:IncRegua1("Apagando Tabela Auxiliar [RANKVEN]" ); oProcess:IncRegua2()
	U_ExecMySql( cSql := "Drop Table RANKVEN" , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	
	//***************************************************************	
	// Criando Tabela Atualizada Base para avaliar Rank de Vendas
	oProcess:IncRegua1("Criando e alimentando Tabela Auxiliar [RANKVEN]" ); oProcess:IncRegua2()
	
	cSql := "CREATE TABLE RANKVEN AS " 
	// Ranking Venda por Peças - VEP 
	cSql += "SELECT " 
	cSql += "	'VEP' TIPO, "
	cSql += "	SB1.B1_CODITE CODITE, "
	cSql += "	ROUND( SUM( D2_QUANT ), 2 ) SOMA, "
	cSql += "	RANK() OVER (ORDER BY ROUND( SUM( D2_QUANT ), 2 ) DESC  ) POSICAO "
	cSql += "FROM "
	cSql += "	SD2010 SD2 "
	cSql += "INNER JOIN SF2010 SF2 ON "
	cSql += "	SD2.D2_FILIAL = SF2.F2_FILIAL "
	cSql += "	AND SD2.D2_DOC = SF2.F2_DOC "
	cSql += "	AND SD2.D2_SERIE = SF2.F2_SERIE "
	cSql += "	AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
	cSql += "	AND SD2.D2_LOJA = SF2.F2_LOJA "
	cSql += "INNER JOIN SF4010 SF4 ON "
	cSql += "	SD2.D2_FILIAL = SF4.F4_FILIAL "
	cSql += "	AND SD2.D2_TES = SF4.F4_CODIGO "
	cSql += "INNER JOIN SB1010 SB1 ON "
	cSql += "	SD2.D2_COD = SB1.B1_COD "
	cSql += "WHERE "
	cSql += "	SF2.F2_EMISSAO BETWEEN '" + cSDataI + "' AND '" + cSDataF + "' "
	cSql += "	AND SF4.F4_ESTOQUE = 'S' "
	cSql += "	AND SF4.F4_DUPLIC = 'S' "
	cSql += "	AND SD2.D_E_L_E_T_ = ' ' "
	cSql += "	AND SF2.D_E_L_E_T_ = ' ' "
	cSql += "	AND SF4.D_E_L_E_T_ = ' ' "
	cSql += "	AND SB1.B1_FILIAL = '05' "
	cSql += "	AND SB1.B1_GRMAR1 IN ( '000001', '000002' ) "
	cSql += "	AND SB1.B1_TIPO IN ( 'PA', 'PP', 'MP' ) "
	cSql += "	AND SB1.D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY "
	cSql += "	SB1.B1_CODITE "

	cSql += "UNION ALL "

	// Ranking Venda por Valor - VEV
	cSql += "SELECT " 
	cSql += "	'VEV' TIPO, "
	cSql += "	SB1.B1_CODITE CODITE, "
	cSql += "	ROUND( SUM( D2_TOTAL ), 2 ) SOMA, "
	cSql += "	RANK() OVER (ORDER BY ROUND( SUM( D2_TOTAL ), 2 ) DESC  ) POSICAO "
	cSql += "FROM "
	cSql += "	SD2010 SD2 "
	cSql += "INNER JOIN SF2010 SF2 ON "
	cSql += "	SD2.D2_FILIAL = SF2.F2_FILIAL "
	cSql += "	AND SD2.D2_DOC = SF2.F2_DOC "
	cSql += "	AND SD2.D2_SERIE = SF2.F2_SERIE "
	cSql += "	AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
	cSql += "	AND SD2.D2_LOJA = SF2.F2_LOJA "
	cSql += "INNER JOIN SF4010 SF4 ON "
	cSql += "	SD2.D2_FILIAL = SF4.F4_FILIAL "
	cSql += "	AND SD2.D2_TES = SF4.F4_CODIGO "
	cSql += "INNER JOIN SB1010 SB1 ON "
	cSql += "	SD2.D2_COD = SB1.B1_COD "
	cSql += "WHERE "
	cSql += "	SF2.F2_EMISSAO BETWEEN '" + cSDataI + "' AND '" + cSDataF + "' "
	cSql += "	AND SF4.F4_ESTOQUE = 'S' "
	cSql += "	AND SF4.F4_DUPLIC = 'S' "
	cSql += "	AND SD2.D_E_L_E_T_ = ' ' "
	cSql += "	AND SF2.D_E_L_E_T_ = ' ' "
	cSql += "	AND SF4.D_E_L_E_T_ = ' ' "
	cSql += "	AND SB1.B1_FILIAL = '05' "
	cSql += "	AND SB1.B1_GRMAR1 IN ( '000001', '000002' ) "
	cSql += "	AND SB1.B1_TIPO IN ( 'PA', 'PP', 'MP' ) "
	cSql += "	AND SB1.D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY "
	cSql += "	SB1.B1_CODITE "
	
	cSql += "UNION ALL " 	
	
	// Rankin Venda Revisada por Peças - VRP
	cSql += "SELECT " 
	cSql += "	'VRP' 												TIPO, "
	cSql += "	SB1.B1_CODITE 										CODITE, "
	cSql += "	ROUND( SUM( ZA0.ZA0_VENDRE ), 2 ) 					SOMA, "
	cSql += "RANK() OVER (ORDER BY ROUND( SUM( ZA0.ZA0_VENDRE ), 2 ) DESC  ) POSICAO "
	cSql += "FROM "
	cSql += "	ZA0010 ZA0 "
	cSql += "INNER JOIN SB1010 SB1 ON "
	cSql += "	ZA0.ZA0_PRODUT = SB1.B1_COD "
	
	cSql += " 				 INNER JOIN SUA010 SUA "
	cSql += "ON  ZA0.ZA0_FILIAL    =     SUA.UA_FILIAL "
	cSql += "AND ZA0.ZA0_NUMORC    =     SUA.UA_NUM "
	cSql += "AND ZA0.ZA0_CLIENT    =	 SUA.UA_CLIENTE "
	cSql += "AND ZA0.ZA0_LOJACL    =	 SUA.UA_LOJA "
	
	cSql += "WHERE "
	cSql += "	ZA0.ZA0_DTNECL BETWEEN '" + cSDataI + "' AND '" + cSDataF + "' "
	cSql += "	AND ZA0.D_E_L_E_T_ = ' ' "
	cSql += "	AND SB1.B1_FILIAL = '05' "
	cSql += "	AND SB1.B1_GRMAR1 IN ( '000001', '000002' ) "
	cSql += "	AND SB1.B1_TIPO IN ( 'PA', 'PP', 'MP' ) "
	cSql += "	AND SB1.D_E_L_E_T_ = ' ' "
	
	cSql += "	AND SUA.D_E_L_E_T_ = ' ' "
	cSql += "	AND SUA.UA_STATUS  !=  'CAN' "
	cSql += "	AND SUA.UA_CANC    !=  'S' "

	cSql += "	GROUP BY SB1.B1_CODITE " 				

	cSql += "UNION ALL " 
	
	// Rankin Venda Revisada por Valor - VRP
	cSql += "SELECT " 
	cSql += "	'VRV' 												TIPO, "
	cSql += "	SB1.B1_CODITE 										CODITE, "
	cSql += "	ROUND( SUM( ZA0.ZA0_VENDRE * ZA0.ZA0_PRECO ), 4 ) 	SOMA, "
	cSql += "RANK() OVER (ORDER BY ROUND( SUM( ZA0.ZA0_VENDRE * ZA0.ZA0_PRECO ), 4 ) DESC  ) POSICAO "
	cSql += "FROM "
	cSql += "	ZA0010 ZA0 "
	cSql += "INNER JOIN SB1010 SB1 ON "
	cSql += "	ZA0.ZA0_PRODUT = SB1.B1_COD "
	
	cSql += " 				 INNER JOIN SUA010 SUA "
	cSql += "ON  ZA0.ZA0_FILIAL    =     SUA.UA_FILIAL "
	cSql += "AND ZA0.ZA0_NUMORC    =     SUA.UA_NUM "
	cSql += "AND ZA0.ZA0_CLIENT    =	 SUA.UA_CLIENTE "
	cSql += "AND ZA0.ZA0_LOJACL    =	 SUA.UA_LOJA "
	
	cSql += "WHERE "
	cSql += "	ZA0.ZA0_DTNECL BETWEEN '" + cSDataI + "' AND '" + cSDataF + "' "
	cSql += "	AND ZA0.D_E_L_E_T_ = ' ' "
	cSql += "	AND SB1.B1_FILIAL = '05' "
	cSql += "	AND SB1.B1_GRMAR1 IN ( '000001', '000002' ) "
	cSql += "	AND SB1.B1_TIPO IN ( 'PA', 'PP', 'MP' ) "
	cSql += "	AND SB1.D_E_L_E_T_ = ' ' "
	
	cSql += "	AND SUA.D_E_L_E_T_ = ' ' "
	cSql += "	AND SUA.UA_STATUS  !=  'CAN' "
	cSql += "	AND SUA.UA_CANC    !=  'S' "

	cSql += "	GROUP BY SB1.B1_CODITE "
	
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra := .F., lChange := .F. )
	
	lMostra := .F.
	
	//***************************************************************	
	// Zerando Ranking de Vendas Peças, Valor e Venda Revisada Peças e Valor 
	cSql := "UPDATE ZA7010 SET "
	cSql += "ZA7_RKVDIP  = 0 ," 
	cSql += "ZA7_RKVDIV  = 0 ,"
	cSql += "ZA7_RKVRIP  = 0 ," 
	cSql += "ZA7_RKVRIV  = 0 "
	
	oProcess:IncRegua1("Zerando campos de Ranking [ZA7_RKVDIP][ZA7_RKVDIV][ZA7_RKVRIP][ZA7_RKVRIV]" ); oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )


	// Verificando Ranking de Vendas  
	oProcess:IncRegua1("Consultando Tabela Auxiliar [RANKVEN]" ); oProcess:IncRegua2()
	cSql := "SELECT TIPO, CODITE, SOMA, POSICAO FROM RANKVEN ORDER BY TIPO,CODITE"  
	U_ExecMySql( cSql, cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	DbSelectArea("TAUX");DbGoTop();nIntPro:=0
	While !EOF()
		
			cSql := "UPDATE SIGA.ZA7010 SET "
			If 		Alltrim(TAUX->TIPO) == "VEP"	// Atualizando ZA7_RKVDIP - Venda em Peças.
				cSql += "ZA7_RKVDIP = " + CV(TAUX->POSICAO) + " " 
				nPAtuPV += 1
			
			ElseIf Alltrim(TAUX->TIPO) == "VEV"		// Atualizando ZA7_RKVDIV - Venda em Valor.
				cSql += "ZA7_RKVDIV = " + CV(TAUX->POSICAO) + " " 
				nPAtuVV += 1
			
			ElseIf Alltrim(TAUX->TIPO) == "VRP"		// Atualizando ZA7_RKVRIP - Venda Revisada em Peças. 
				cSql += "ZA7_RKVRIP = " + CV(TAUX->POSICAO) + " " 
				nPAtuPR += 1
			
			ElseIf Alltrim(TAUX->TIPO) == "VRV"		// Atualizando ZA7_RKVRIV - Venda Revisada em Valor
				cSql += "ZA7_RKVRIV = " + CV(TAUX->POSICAO) + " " 
				nPAtuVR += 1
			
			EndIf
			cSql += "WHERE ZA7_CODITE = '" + CV(TAUX->CODITE) + "' "
			
			If nIntPro == 100
				If 		Alltrim(TAUX->TIPO) == "VEP"
					oProcess:IncRegua1("Atualizando Ranking Venda Peças [ZA7_RKVDIP] ITEM " + Alltrim(TAUX->CODITE) + "" ); oProcess:IncRegua2()
				ElseIf Alltrim(TAUX->TIPO) == "VEV"		
					oProcess:IncRegua1("Atualizando Ranking Venda Valor [ZA7_RKVDIV] ITEM " + Alltrim(TAUX->CODITE) + "" ); oProcess:IncRegua2()
				ElseIf Alltrim(TAUX->TIPO) == "VRP"	
					oProcess:IncRegua1("Atualizando Ranking Venda Revisada Peças [ZA7_RKVRIP] ITEM " + Alltrim(TAUX->CODITE) + "" ); oProcess:IncRegua2()
				ElseIf Alltrim(TAUX->TIPO) == "VRV"
					oProcess:IncRegua1("Atualizando Ranking Venda Revisada Valor [ZA7_RKVRIV] ITEM " + Alltrim(TAUX->CODITE) + "" ); oProcess:IncRegua2()
				EndIf
				nIntPro := 0
			Else
				nIntPro += 1
			EndIf 
			
				U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
			
			//eVal(bAbort)
		
		DbSelectArea("TAUX")
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	MntLog ("2.3  Calculo do Ranking de Vendas " + ENTER + ; 
			"Foram Atualizados: " + ENTER + ;
			 "Ranking Venda Peças "	+ Alltrim( Transform(nPAtuPV,"@E 99,999,999"))  + ENTER + ;
			 "Ranking Venda Valor "	+ Alltrim( Transform(nPAtuVV,"@E 99,999,999"))  + ENTER + ;
			 "Ranking Venda Revisada Peças " + Alltrim( Transform(nPAtuPR,"@E 99,999,999")) + ENTER + ;
			 "Ranking Venda Revisada Valor " + Alltrim( Transform(nPAtuVR,"@E 99,999,999")) + ENTER + ENTER + ;
			 " Em cada Filial por CODITE. ","Campos [ZA7_RKVDIP][ZA7_RKVDIV][ZA7_RKVRIP][ZA7_RKVRIV]")
			 	
Return Nil
*******************************************************************************
Static Function CurvasABC() // 3  Curvas ABC  
*******************************************************************************

	Local cSql := ""
	Local cFaixa    := "" // Armazena a Faixa na Qual se enquadrou o ITEM
	
	// Salva os Totais de Vendas
	Local nSTotVEP 	:= 0 // Soma Total de Venda Pecas 
	Local nSTotVEV 	:= 0 // Soma Total de Venda Valor
	Local nSTotVRP 	:= 0 // Soma Total de Venda Revisada Pecas
	Local nSTotVRV 	:= 0 // Soma Total de Venda Revisada Valor

	Local nPercent  := 0 // Guarda o Resultado do Calculo de Percentual de Representação do Item
	
	Local nIntPro 	:= 0 // Intervalo oProcess:IncRegua1

	// Salva os Acumulos  de Vendas
	Local nSAcuVEP 	:= 0 // Acumulo de Venda Pecas 
	Local nSAcuVEV 	:= 0 // Acumulo Total de Venda Valor
	Local nSAcuVRP 	:= 0 // Acumulo Total de Venda Revisada Pecas
	Local nSAcuVRV 	:= 0 // Acumulo Total de Venda Revisada Valor
	
	Local nSAcPVEP 	:= 0 // Acumulo de Venda Pecas 
	Local nSAcPVEV 	:= 0 // Acumulo Total de Venda Valor
	Local nSAcPVRP 	:= 0 // Acumulo Total de Venda Revisada Pecas
	Local nSAcPVRV 	:= 0 // Acumulo Total de Venda Revisada Valor

	Local nSVanVEP 	:= 0 // Valor Anteior de Venda Pecas 
	Local nSVanVEV 	:= 0 // Valor Anteior de Venda Valor
	Local nSVanVRP 	:= 0 // Valor Anteior de Venda Revisada Pecas
	Local nSVanVRV 	:= 0 // Valor Anteior de Venda Revisada Valor

	Local nPAtuPV 	:= 0 // Total de Produtos Pecas vendas 
	Local nPAtuVV 	:= 0 // Total de Produtos Valor Vendas 
	Local nPAtuPR 	:= 0 // Total de Produtos Pecas Revisadas
	Local nPAtuVR 	:= 0 // Total de Produtos Valor revisadas 

	
	oProcess:SetRegua1(0);oProcess:SetRegua2(0)
	oProcess:IncRegua1();oProcess:IncRegua2()


	//***********************************************************
	// Consultando Soma Total de Venda Pecas  
	oProcess:IncRegua1("Consultando Soma Total de Venda Pecas "); oProcess:IncRegua2()
	
	cSql := "SELECT ROUND( SUM(SOMA),2) TOTAL FROM RANKVEN WHERE TIPO = 'VEP'"
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	DbSelectArea("TAUX");DbGoTop()
	nSTotVEP := TAUX->TOTAL
	ConOut("nSTotVEP : " + cValToChar(nSTotVEP) )
	DbSelectArea("TAUX");DbCloseArea()
	
	//***********************************************************
	// Consultando Soma Total de Venda Valor
	oProcess:IncRegua1("Consultando Soma Total de Venda Valor "); oProcess:IncRegua2()
	
	cSql := "SELECT ROUND( SUM(SOMA),2) TOTAL FROM RANKVEN WHERE TIPO = 'VEV'"
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	DbSelectArea("TAUX");DbGoTop()
	nSTotVEV := TAUX->TOTAL
	ConOut("nSTotVEV : " + cValToChar(nSTotVEV) )
	DbSelectArea("TAUX");DbCloseArea()

	//***********************************************************
	// Soma Total de Venda Revisada Pecas
	oProcess:IncRegua1("Consultando Soma Total de Venda Revisada Pecas"); oProcess:IncRegua2()
	
	cSql := "SELECT ROUND( SUM(SOMA),2) TOTAL FROM RANKVEN WHERE TIPO = 'VRP'"
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	DbSelectArea("TAUX");DbGoTop()
	nSTotVRP := TAUX->TOTAL
	ConOut("nSTotVRP : " + cValToChar(nSTotVRP) )
	DbSelectArea("TAUX");DbCloseArea()

	//***********************************************************
	// Soma Total de Venda Revisada Valor
	oProcess:IncRegua1("Consultando Soma Total de Venda Revisada Valor"); oProcess:IncRegua2()
	
	cSql := "SELECT ROUND( SUM(SOMA),2) TOTAL FROM RANKVEN WHERE TIPO = 'VRV'"
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	DbSelectArea("TAUX");DbGoTop()
	nSTotVRV := TAUX->TOTAL
	ConOut("nSTotVRV : " + cValToChar(nSTotVRV) )
	DbSelectArea("TAUX");DbCloseArea()


	//********************************************************************
	// Resetando Curvas Vendas Pecas e Valor  
	oProcess:IncRegua1("Resetando Curva ABC de Venda Pecas e Valor  " ); oProcess:IncRegua2()
	cSql := "UPDATE SB1010 SET B1_CURVAIT = 'ZZ' "  
	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	

	//********************************************************************
	// Resetando Curvas Vendas Revisadas Pecas e Valor  
	oProcess:IncRegua1("Resetando Curva ABC de Venda Pecas e Valor  " ); oProcess:IncRegua2()
	cSql := "UPDATE ZA7010 SET ZA7_ABCVRI = 'ZZ' "  
	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	
	//********************************************************************
	// Verificando Somas de Vendas  
	oProcess:IncRegua1("Consultando Tabela Auxiliar [RANKVEN]" ); oProcess:IncRegua2()
	cSql := "SELECT TIPO, CODITE, SOMA, POSICAO FROM RANKVEN ORDER BY POSICAO"  
	U_ExecMySql( cSql, cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	DbSelectArea("TAUX");DbGotop()
	While !EOF()
		
		If		Alltrim(TAUX->TIPO) == "VEP"	// Curva ABC - Venda em Peças.
			
			// Avalia Faixa Curva ABC
			cFaixa := AvalABC(@nPAtuPV, @nSAcuVEP, @nSVanVEP, @nSAcPVEP, @nSTotVEP, "VEP" )
			
			cTexto	:= "Atualizando Curva ABC Venda Peca ITEM " + Alltrim(TAUX->CODITE)
			cSql	:= "UPDATE SB1010 SET B1_CURVAIT = SUBSTR(B1_CURVAIT,1,1)||'"+cFaixa+"' WHERE B1_CODITE = '" + CV(TAUX->CODITE) + "' "
			
		ElseIf 	Alltrim(TAUX->TIPO) == "VEV"		//  Curva ABC - Venda em Valor.
			
			// Avalia Faixa Curva ABC
			cFaixa := AvalABC(@nPAtuVV, @nSAcuVEV, @nSVanVEV, @nSAcPVEV, @nSTotVEV, "VEV" )
			
			cTexto	:= "Atualizando Curva ABC Venda Valor ITEM " + Alltrim(TAUX->CODITE)
			cSql	:= "UPDATE SB1010 SET B1_CURVAIT = '"+cFaixa+"'||SUBSTR(B1_CURVAIT,2,1) WHERE B1_CODITE = '" + CV(TAUX->CODITE) + "' "
			
		ElseIf 	Alltrim(TAUX->TIPO) == "VRP"		//  Curva ABC - Venda Revisada em Peças. 
			
			// Avalia Faixa Curva ABC 
			cFaixa := AvalABC(@nPAtuPR, @nSAcuVRP, @nSVanVRP, @nSAcPVRP, @nSTotVRP, "VRP" )
			
			cTexto 	:= "Atualizando Curva ABC Venda Revisada Peca ITEM " + Alltrim(TAUX->CODITE)
			cSql 	:= "UPDATE ZA7010 SET ZA7_ABCVRI = SUBSTR(ZA7_ABCVRI,1,1)||'"+CV(cFaixa)+"' WHERE ZA7_CODITE = '" + CV(TAUX->CODITE) + "' "
			
		ElseIf 	Alltrim(TAUX->TIPO) == "VRV"		//  Curva ABC - Venda Revisada em Valor
			
			// Avalia Faixa Curva ABC
			cFaixa := AvalABC(@nPAtuVR, @nSAcuVRV, @nSVanVRV, @nSAcPVRV, @nSTotVRV, "VRV" )
			
			cTexto 	:= "Atualizando Curva ABC Venda Revisada Valor ITEM " + Alltrim(TAUX->CODITE)
			cSql 	:= "UPDATE ZA7010 SET ZA7_ABCVRI = '"+CV(cFaixa)+"'||SUBSTR(ZA7_ABCVRI,2,1) WHERE ZA7_CODITE = '" + CV(TAUX->CODITE) + "' "
			
		EndIf
		
		If nIntPro == 100
			ConOut("nPercent : " + cValToChar(nPercent) + " ITEM: " + Alltrim(TAUX->CODITE) )
			If 		Alltrim(TAUX->TIPO) == "VEP"
				oProcess:IncRegua1("Atualizando Curva ABC Venda Peças [B1_CURVAIT] ITEM " + Alltrim(TAUX->CODITE) + "" ); oProcess:IncRegua2()
			ElseIf 	Alltrim(TAUX->TIPO) == "VEV"		
				oProcess:IncRegua1("Atualizando Curva ABC Venda Valor [B1_CURVAIT] ITEM " + Alltrim(TAUX->CODITE) + "" ); oProcess:IncRegua2()
			ElseIf 	Alltrim(TAUX->TIPO) == "VRP"	
				oProcess:IncRegua1("Atualizando Curva ABC Venda Revisada Peças [ZA7_ABCVRI] ITEM " + Alltrim(TAUX->CODITE) + "" ); oProcess:IncRegua2()
			ElseIf 	Alltrim(TAUX->TIPO) == "VRV"
				oProcess:IncRegua1("Atualizando Curva ABC Venda Revisada Valor [ZA7_ABCVRI] ITEM " + Alltrim(TAUX->CODITE) + "" ); oProcess:IncRegua2()
			EndIf
			nIntPro := 0
		Else
			nIntPro += 1
		EndIf 
		
		U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
		DbSelectArea("TAUX")
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	/// Ajustando Curva E
	cTexto 	:= "Ajustando Curva E - B1_CURVAIT - Curva ABC Item Vlr-Pcs "
	cSql := "SELECT ZA7_CODITE CODITE, SUBSTR(B1_CURVAIT,1,1) VEP, SUBSTR(B1_CURVAIT,2,1) VEV, SUBSTR(ZA7_ABCVRI,1,1) VRP,SUBSTR(ZA7_ABCVRI,2,1) VRV "   
	cSql += "FROM ZA7010 ZA7  INNER JOIN SB1010 SB1 ON ZA7.ZA7_FILIAL = SB1.B1_FILIAL AND ZA7.ZA7_CODPRO = SB1.B1_COD "
	cSql += "WHERE 	( SUBSTR(ZA7_ABCVRI,1,1) != 'Z' OR SUBSTR(ZA7_ABCVRI,2,1) != 'Z') " 
	cSql += "AND   	( SUBSTR(B1_CURVAIT,1,1)  = 'Z' OR SUBSTR(B1_CURVAIT,2,1)  = 'Z') "
	cSql += "AND 	ZA7.D_E_L_E_T_ = ' ' "
	cSql += "AND 	SB1.D_E_L_E_T_  = ' ' "
	cSql += "GROUP BY ZA7_CODITE, ZA7_ABCVRI, B1_CURVAIT "
	
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	DbSelectArea("TAUX");dbGotop();nIntPro := 0; cFaixa := "E"
	While !EOF()
		
		// Ajustando Faixa Pecas 
		If TAUX->VRP <> "Z" .And.  TAUX->VEP == "Z" 
			cSql := "UPDATE SB1010 SET B1_CURVAIT = '"+cFaixa+"'||SUBSTR(B1_CURVAIT,2,1) WHERE B1_CODITE = '" + CV(TAUX->CODITE) + "' "
			U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		Endif 	
		
		// Ajustando Faixa Valor 
		If TAUX->VRV <> "Z" .And.  TAUX->VEV == "Z" 
			cSql := "UPDATE SB1010 SET B1_CURVAIT = SUBSTR(B1_CURVAIT,1,1) || '"+cFaixa+"' WHERE B1_CODITE = '" + CV(TAUX->CODITE) + "' "
			U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		Endif 	
		
		If nIntPro == 100
			oProcess:IncRegua1("Ajustando Curva E [B1_CURVAIT] Item " + CV(TAUX->CODITE) ); oProcess:IncRegua2()
			nIntPro := 0
		Else
			nIntPro += 1
		EndIf 
	
		DbSelectArea("TAUX")
		DbSkip()
	EndDO
	DbSelectArea("TAUX");DbCloseArea()
	
	
	/// Sincronizando 
	cTexto 	:= "Sincronizando [ZA7_ABCMC - Curva ABC Margem] com [B1_CURVAIT - Curva ABC Item Valor] "
	cSql :=	"SELECT 'UPDATE ZA7010 SET ZA7_ABCMC = SUBSTR(ZA7_ABCMC,1,1)|| ''' || SUBSTR(B1_CURVAIT,1,1) ||  ''' WHERE ZA7_CODITE = ''' || TRIM(SB1.B1_CODITE) || ''' ' AS UPD "
	cSql +=	"FROM SB1010 SB1 WHERE B1_FILIAL = '05' AND   B1_CODITE > ' ' AND   SUBSTR(B1_CURVAIT,2,1) IN ('Z','E') AND D_E_L_E_T_ = ' ' "
	
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	DbSelectArea("TAUX");dbGotop();nIntPro := 0
	While !EOF()
		
		U_ExecMySql( TAUX->UPD , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		
		If nIntPro == 100
			oProcess:IncRegua1(cTexto ); oProcess:IncRegua2()
			nIntPro := 0
		Else
			nIntPro += 1
		EndIf 
	
		DbSelectArea("TAUX")
		DbSkip()
	EndDO
	DbSelectArea("TAUX");DbCloseArea()
	
	MntLog ("3  Montagem Curva ABC Venda e Venda Revisada " + ENTER + ; 
			"Foram Atualizados: " + ENTER + ;
			 "Curva ABC Venda Peças "	+ Alltrim( Transform(nPAtuPV,"@E 99,999,999"))  + ENTER + ;
			 "Curva ABC  Venda Valor "	+ Alltrim( Transform(nPAtuVV,"@E 99,999,999"))  + ENTER + ;
			 "Curva ABC  Venda Revisada Peças " + Alltrim( Transform(nPAtuPR,"@E 99,999,999")) + ENTER + ;
			 "Curva ABC  Venda Revisada Valor " + Alltrim( Transform(nPAtuVR,"@E 99,999,999")) + ENTER + ENTER + ;
			 " Em cada Filial por CODITE. ","Campos [ZA7_RKVDIP][ZA7_RKVDIV][ZA7_RKVRIP][ZA7_RKVRIV]")


Return Nil 
*******************************************************************************
Static Function VerFABC(nPercent, cItem, cTipo ) // Verifica a Faixa ABC do Item 
*******************************************************************************

	// Faixa de Curvas ... 
	Local nCurvaA	:= 50
	Local nCurvaB	:= nCurvaA + 35
	Local nCurvaC	:= nCurvaB + 13
	Local nCurvaD	:= nCurvaC + 2 
	
	Local cSql 		:= ""
	
	Local cFaixa	:= ""
	
	Do Case 
		Case nPercent <= nCurvaA
			cFaixa := "A"
		Case nPercent <= nCurvaB
			cFaixa := "B"
		Case nPercent <= nCurvaC
			cFaixa := "C"
		Case nPercent <= nCurvaD
			cFaixa := "D"	
	OtherWise
			cFaixa := " "
	End Case 


Return cFaixa
*******************************************************************************
Static Function AvalABC(nPAtu, nSAcu, nSVan, nSAcP, nSTot ,cQuem )
*******************************************************************************
	Local cFaixa
			
	nPAtu	 += 1
	nSAcu += TAUX->SOMA
			
	If  TAUX->SOMA == nSVan // Quando os Valores são Iguais, segue enviando o aCumulo Paralelo para nao mudar a Faixa
				
		nPercent := NoRound( ( nSAcP / nSTot * 100 ), 0 )  
			
	Else// Quando os Valores são diferentes, envia o aCumulado Normal, ja pode ser alterado a Faixa
		nPercent := NoRound( ( nSAcu / nSTot * 100 ), 0 )  
				
		nSAcP := nSAcu
				
	EndIf
			
	cFaixa	:= VerFABC(nPercent, TAUX->CODITE , cQuem ) // Verifica a Faixa ABC
			
	nSVan := TAUX->SOMA

Return cFaixa 
*******************************************************************************
Static Function CurvasPQR() // 3.2.	Curvas PQR
*******************************************************************************

	Local cSql := ""
	Local cSDataI 	:= dToS(DataRef(nMeses := 12))
	Local cSDataF 	:= dToS(DataRef(nMeses := 1,.T. ))  
	Local cFaixa    := "" // Armazena a Faixa na Qual se enquadrou o ITEM

	Local nPercent  := 0 // Guarda o Resultado do Calculo de Percentual de Representação do Item
	
	Local nIntPro 	:= 0 // Intervalo oProcess:IncRegua1

	Local nSToCITE 	:= 0 // Soma Total de Consultas Item
	Local nPAcuITE 	:= 0 // Percentual Acumulado de Consultas Item
	Local nPAPaITE 	:= 0 // Percentual Acumulado Paralelo de Consultas Item
	Local nPercITE 	:= 0 // Percentual do CodITe Sobre Total de Consultas Itens 
	
	Local nSToCCLI 	:= 0 // Soma Total de Consultas Cliente
	Local nPAcuCLI 	:= 0 // Percentual Acumulado de Consultas Cliente
	Local nPAPaCLI 	:= 0 // Percentual Acumulado Paralelo de Consultas Cliente
	Local nPercCLI 	:= 0 // Percentual do CodITe Sobre Total de Consultas Clientes 

	Local nTotIUpd 	:= 0 // Total de Itens Consulta Itens Atualizados  
	Local nTotCUpd 	:= 0 // Total de Itens Consulta Clientes Atualizados 
	
	oProcess:SetRegua1(0);oProcess:SetRegua2(0)
	oProcess:IncRegua1();oProcess:IncRegua2()
	
	oProcess:IncRegua1("Resetando Consulta PQR..." ); oProcess:IncRegua2()
	U_ExecMySql( "UPDATE ZA7010 SET ZA7_PQR = 'ZZ' ", cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	oProcess:IncRegua1("Excluindo Tabela Auxiliar [RANKPQR]" ); oProcess:IncRegua2()
	U_ExecMySql( "Drop Table RANKPQR" , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	
	// Consultando Curva PQR
	cSql :="CREATE TABLE RANKPQR AS "
	cSql +="SELECT TABA.CODITE, CONITE, POSITE, CONCLI, POSCLI "
	cSql +="FROM  "
	cSql +="	(   SELECT  SB1.B1_CODITE   	CODITE, "
	cSql +="			SUM(ZA0_QUANTD) 		CONITE, " 
	cSql +="			RANK() OVER (ORDER BY ROUND( SUM(ZA0_QUANTD) , 2 ) DESC  ) POSITE " 
	cSql +="		FROM ZA0010 ZA0 INNER JOIN SB1010 SB1 " 
	cSql +="		ON 	ZA0.ZA0_FILIAL = SB1.B1_FILIAL " 
	cSql +="		AND ZA0.ZA0_PRODUT = SB1.B1_COD " 
 	
 	cSql += " 				 INNER JOIN SUA010 SUA "
 	cSql += "		ON  ZA0.ZA0_FILIAL    =  SUA.UA_FILIAL "
 	cSql += "		AND ZA0.ZA0_NUMORC    =  SUA.UA_NUM "
 	cSql += "		AND ZA0.ZA0_CLIENT    =	 SUA.UA_CLIENTE "
 	cSql += "		AND ZA0.ZA0_LOJACL    =	 SUA.UA_LOJA "
 	
 	cSql +="		WHERE ZA0_DTNECL BETWEEN  '" + cSDataI + "' AND '" + cSDataF + "' "
 	cSql +="		AND   ZA0.D_E_L_E_T_ = ' ' " 
 	cSql +="		AND   SB1.B1_GRMAR1 IN ( '000001', '000002' ) " 
 	cSql +="		AND   SB1.B1_TIPO IN ( 'PA', 'PP', 'MP' ) " 
 	cSql +="		AND   SB1.D_E_L_E_T_ = ' ' " 
 	
 	cSql += "		AND SUA.D_E_L_E_T_ = ' ' "
 	cSql += "		AND SUA.UA_STATUS  !=  'CAN' "
 	cSql += "		AND SUA.UA_CANC    !=  'S' "
 	
 	cSql +="		GROUP BY SB1.B1_CODITE " 
 	cSql +="	 ) TABA, "  
	
 	cSql +="	 ( 	SELECT 	CODITE, "
	cSql +="			COUNT(CLIENTE) CONCLI, "
	cSql +="			RANK() OVER (ORDER BY ROUND( COUNT(CLIENTE) , 2 ) DESC  ) POSCLI "
	cSql +="		FROM ( "	
	cSql +="				SELECT 	DISTINCT " 
	cSql +="				SB1.B1_CODITE 	CODITE, "
	cSql +="				ZA0.ZA0_CLIENT  CLIENTE "
	cSql +="				FROM ZA0010 ZA0 INNER JOIN SB1010 SB1 " 
	cSql +="				ON 	ZA0.ZA0_FILIAL = SB1.B1_FILIAL " 
	cSql +="				AND ZA0.ZA0_PRODUT = SB1.B1_COD " 
	
	cSql += " 				INNER JOIN SUA010 SUA "
	cSql += "				ON  ZA0.ZA0_FILIAL    =  SUA.UA_FILIAL "
	cSql += "				AND ZA0.ZA0_NUMORC    =  SUA.UA_NUM "
	cSql += "				AND ZA0.ZA0_CLIENT    =	 SUA.UA_CLIENTE "
	cSql += "				AND ZA0.ZA0_LOJACL    =	 SUA.UA_LOJA "

 	cSql +="				WHERE ZA0_DTNECL BETWEEN  '" + cSDataI + "' AND '" + cSDataF + "' "
 	cSql +="				AND   ZA0.D_E_L_E_T_ = ' ' " 
 	cSql +="				AND   SB1.B1_GRMAR1 IN ( '000001', '000002' ) " 
 	cSql +="				AND   SB1.B1_TIPO IN ( 'PA', 'PP', 'MP' ) " 
 	cSql +="				AND   SB1.D_E_L_E_T_ = ' ' " 
 	
 	cSql += "				AND SUA.D_E_L_E_T_ = ' ' "
 	cSql += "				AND SUA.UA_STATUS  !=  'CAN' "
 	cSql += "				AND SUA.UA_CANC    !=  'S' "
 	
 	cSql +="		) GROUP BY CODITE " 
 	cSql +="	  ) TABB "
 	
 	cSql +="	WHERE TABA.CODITE = TABB.CODITE "
 	cSql +="	ORDER BY TABA.CODITE "
	
	oProcess:IncRegua1("Criando Tabela Auxiliar [RANKPQR]" ); oProcess:IncRegua2()
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	oProcess:IncRegua1("Consultando Tabela Auxiliar [RANKPQR] Total Consultas" ); oProcess:IncRegua2()
	U_ExecMySql( "SELECT SUM(CONITE) TCONITE FROM RANKPQR"  , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	DbSelectArea("TAUX");DbGoTop()
	nSToCITE := TAUX->TCONITE
	DbSelectArea("TAUX");DbCloseArea()
	

	oProcess:IncRegua1("Consultando Tabela Auxiliar [RANKPQR] Consultas por Item" ); oProcess:IncRegua2()
	U_ExecMySql( "SELECT CODITE, CONITE, POSITE  FROM RANKPQR ORDER BY POSITE"  , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	DbSelectArea("TAUX");dbGotop();nIntPro := 0
	While !EOF()
	
		cFaixa := AvalFPQR(@nPercITE, @nPAcuITE, @nPAPaITE, nSToCITE, "TAUX->CONITE" )  
		
		If nIntPro == 100
			oProcess:IncRegua1("Atualizando Curva PQR Consulta Item " + CV(TAUX->CODITE)) ; oProcess:IncRegua2()
			nIntPro := 0
		Else
			nIntPro += 1
		EndIf 

		nTotIUpd += 1  
	 	
		cSql := "UPDATE ZA7010 SET ZA7_PQR = '"+cFaixa+"' || SUBSTR(ZA7_PQR,2,1) WHERE ZA7_CODITE = '" + CV(TAUX->CODITE) + "' "
		U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		
		DbSelectArea("TAUX")
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	oProcess:IncRegua1("Consultando Tabela Auxiliar [RANKPQR] Total Clientes" ); oProcess:IncRegua2()
	U_ExecMySql( "SELECT SUM(CONCLI) TCONCLI FROM RANKPQR"  , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )

	DbSelectArea("TAUX");DbGoTop()
	nSToCCLI := TAUX->TCONCLI
	DbSelectArea("TAUX");DbCloseArea()
	

	oProcess:IncRegua1("Consultando Tabela Auxiliar [RANKPQR] Consultas por Cliente" ); oProcess:IncRegua2()
	U_ExecMySql( "SELECT CODITE, CONCLI, POSCLI FROM RANKPQR ORDER BY POSCLI"  , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )

	DbSelectArea("TAUX");dbGotop();nIntPro := 0
	While !EOF()
	
		cFaixa := AvalFPQR(@nPercCLI, @nPAcuCLI, @nPAPaCLI, nSToCCLI, "TAUX->CONCLI" )  
		
		If nIntPro == 100
			oProcess:IncRegua1("Atualizando Curva PQR Consulta Cliente "  + CV(TAUX->CODITE)) ; oProcess:IncRegua2()
			nIntPro := 0
		Else
			nIntPro += 1
		EndIf 

		nTotCUpd+= 1
			
		cSql := "UPDATE ZA7010 SET ZA7_PQR =  SUBSTR(ZA7_PQR,1,1) || '"+cFaixa+"'  WHERE ZA7_CODITE = '" + CV(TAUX->CODITE) + "' "
		U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		
		DbSelectArea("TAUX")
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	MntLog ("3.2  Montagem Curva PQR Consulta Item e Cliente " + ENTER + ; 
			"Foram Atualizados: " + ENTER + ;
			 "Curva PQR Consultas "	+ Alltrim( Transform(nTotIUpd,"@E 99,999,999"))  + ENTER + ;
			 "Curva PQR Clientes "	+ Alltrim( Transform(nTotCUpd,"@E 99,999,999"))  + ENTER + ;
			 " Em cada Filial por CODITE. ","Campo [ZA7_PQR]")


Return Nil
*******************************************************************************	
Static Function AvalFPQR(nPerc, nPAcu, nPAPa, nSToC, CpoCon ) // Avalia Faixa do Item na Curva PQR [Consultas e Clientes ]
*******************************************************************************		
	// Faixas Consultas ITem
	Local nFxPQRIP := 50 // Faixa PQR Consulta Itens P
	Local nFxPQRIQ := nFxPQRIP + 35 // Faixa PQR Consulta Itens Q
	Local nFxPQRIR := 100 - Round( 24 / nSToC * 100 , 20) // Faixa PQR Consulta Itens R [Nao e Percentual e sim 254 consultas ]
	Local nFxPQRIS := 100 // Faixa PQR Consulta Itens S [ Menos de 24 Consultas]
	
	// Faixas Consultas Cliente	
	Local nFxPQRCP := 50 // Faixa PQR Consulta Itens P
	Local nFxPQRCQ := nFxPQRIP + 35 // Faixa PQR Consulta Cliente Q
	Local nFxPQRCR := nFxPQRCQ + 13 // Faixa PQR Consulta Cliente R 
	Local nFxPQRCS := nFxPQRCR + 02 // Faixa PQR Consulta Cliente S
		
	If nPerc <>  ( &CpoCon / nSToC * 100 , 20) 
		nPAcu := nPAPa
		nPAcu += nPerc := Round( &CpoCon / nSToC * 100 , 20)
		nPAPa := nPAcu
	Else
		nPAPa += nPerc := Round( &CpoCon / nSToC *100 , 20)
	EndIf
		
	If AT("ITE",CpoCon) > 0
		If nPAcu <= nFxPQRIP
			cFaixa := "P"
		ElseIf nPAcu <= nFxPQRIQ
			cFaixa := "Q"
		ElseIf nPAcu <= nFxPQRIR
			cFaixa := "R"
		ElseIf nPAcu <= nFxPQRIS
			cFaixa := "S"
		EndIf
	
	Elseif AT("CLI",CpoCon) > 0
		If nPAcu <= nFxPQRCP
			cFaixa := "P"
		ElseIf nPAcu <= nFxPQRCQ
			cFaixa := "Q"
		ElseIf nPAcu <= nFxPQRCR
			cFaixa := "R"
		ElseIf nPAcu <= nFxPQRCS
			cFaixa := "S"
		EndIf
	EndIf 
	
Return cFaixa

*******************************************************************************
Static Function CurvABCM() // //3.3  Calculo das Curvas ABC Margem 
*******************************************************************************


	Local cSql := ""
	Local cSDataI 	:= dToS(DataRef(nMeses := 12))
	Local cSDataF 	:= dToS(DataRef(nMeses := 1,.T. ))  
	
	Local nIntPro 	:= 0 // Intervalo oProcess:IncRegua1
	
	Local nSToMarg 	:= 0 // Soma Total das Margens
	Local nPAcuSMA 	:= 0 // Percentual Acumulado de Soma Margem
	Local nPAPaCIM 	:= 0 // Percentual Acumulado Paralelo de Soma Margem
	Local nPercCIM 	:= 0 // Percentual do CodITe Sobre Total da Margem

	Local nTotIUpd 	:= 0 // Total de ABC MArgem por Itens Atualizados  
	
	oProcess:SetRegua1(0);oProcess:SetRegua2(0)
	oProcess:IncRegua1();oProcess:IncRegua2()
	
	//**************************************************************	
	// Dropar Tabela Tamporaria RANKMAR
	oProcess:IncRegua1("Apagando Tabela Auxiliar [RANKMAR]" ); oProcess:IncRegua2()
	U_ExecMySql( cSql := "Drop Table RANKMAR" , cCursor := "", cModo := "E", lMostra, lChange := .F. )


	//***************************************************************	
	// Criando Tabela Atualizada Base para avaliar Ranking Margem
	oProcess:IncRegua1("Criando e alimentando Tabela Auxiliar [RANKMAR]" ); oProcess:IncRegua2()

	cSql := "CREATE TABLE RANKMAR AS " 
	cSql += "SELECT " 
	cSql += "	SB1.B1_CODITE CODITE, "
	cSql += "	ROUND( SUM( D2_MARGEM ), 2 ) SOMA, "
	cSql += "	RANK() OVER (ORDER BY ROUND( SUM( D2_MARGEM ), 2 ) DESC  ) POSICAO "
	cSql += "FROM "
	cSql += "	SD2010 SD2 "
	cSql += "INNER JOIN SF2010 SF2 ON "
	cSql += "	SD2.D2_FILIAL = SF2.F2_FILIAL "
	cSql += "	AND SD2.D2_DOC = SF2.F2_DOC "
	cSql += "	AND SD2.D2_SERIE = SF2.F2_SERIE "
	cSql += "	AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
	cSql += "	AND SD2.D2_LOJA = SF2.F2_LOJA "
	cSql += "INNER JOIN SF4010 SF4 ON "
	cSql += "	SD2.D2_FILIAL = SF4.F4_FILIAL "
	cSql += "	AND SD2.D2_TES = SF4.F4_CODIGO "
	cSql += "INNER JOIN SB1010 SB1 ON "
	cSql += "	SD2.D2_COD = SB1.B1_COD "
	cSql += "WHERE "
	cSql += "	SF2.F2_EMISSAO BETWEEN '" + cSDataI + "' AND '" + cSDataF + "' "
	cSql += "	AND SF4.F4_ESTOQUE = 'S' "
	cSql += "	AND SF4.F4_DUPLIC = 'S' "
	cSql += "	AND SD2.D_E_L_E_T_ = ' ' "
	cSql += "	AND SF2.D_E_L_E_T_ = ' ' "
	cSql += "	AND SF4.D_E_L_E_T_ = ' ' "
	cSql += "	AND SB1.B1_FILIAL = '05' "
	cSql += "	AND SB1.B1_GRMAR1 IN ( '000001', '000002' ) "
	cSql += "	AND SB1.B1_TIPO IN ( 'PA', 'PP', 'MP' ) "
	cSql += "	AND SB1.D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY "
	cSql += "	SB1.B1_CODITE "

	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra := .F., lChange := .F. )
	
	oProcess:IncRegua1("Consultando Tabela Auxiliar [RANKMAR] Rankin Margem" ); oProcess:IncRegua2()
	U_ExecMySql( "SELECT SUM(SOMA) TRM FROM RANKMAR "  , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	DbSelectArea("TAUX");DbGoTop()
	nSToMargem := TAUX->TRM
	DbSelectArea("TAUX");DbCloseArea()
	

	oProcess:IncRegua1("Consultando Tabela Auxiliar [RANKMAR] Ranking Margens por Item" ); oProcess:IncRegua2()
	U_ExecMySql( "SELECT CODITE, SOMA, POSICAO FROM RANKMAR ORDER BY POSICAO"  , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )

	DbSelectArea("TAUX");dbGotop();nIntPro := 0
	While !EOF()
		
		cFaixa := AvaCABCM(@nPercCIM, @nPAcuSMA, @nPAPaCIM, nSToMarg, "TAUX->SOMA" )  
		
		If nIntPro == 100
			oProcess:IncRegua1("Atualizando Curva ABC Margem Item " + CV(TAUX->CODITE)); oProcess:IncRegua2()
			nIntPro := 0
		Else
			nIntPro += 1
		EndIf 

		nTotIUpd += 1 
	 	
		cSql := "UPDATE ZA7010 SET ZA7_ABCMC = SUBSTR(ZA7_ABCMC,1,1)||'"+cFaixa+"'  WHERE CODITE = '"+CV(TAUX->CODITE)+"' "
		U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		
		DbSelectArea("TAUX")
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()


	MntLog ("3.3  Montagem Curva ABC Margens " + ENTER + ; 
			"Foram Atualizados: " + Alltrim( Transform(nTotIUpd,"@E 99,999,999"))  + ENTER + ;
			 " Em cada Filial por CODITE. ","Campo [ZA7_ABCMC]" )
Return
*******************************************************************************
Static Function AvaCABCM(nPerc, nPAcu, nPAPa, nSToM, CpoCon) // Avalia Posicao Ranking Margem 
*******************************************************************************

	// Faixas Cusva ABC Margem 
	Local nFxABCMA := 50 			// Faixa Margem ABC - A 
	Local nFxABCMB := nFxABCMA + 35 // Faixa Margem ABC - B
	Local nFxABCMC := nFxABCMB + 13 // Faixa Margem ABC - C 
	Local nFxABCMD := nFxABCMC + 2  // Faixa Margem ABC - D 
		
	If nPerc <> ( &CpoCon / nSToM * 100 , 20) 
		nPAcu := nPAPa
		nPAcu += nPerc := Round( &CpoCon / nSToM * 100 , 20)
		nPAPa := nPAcu
	Else
		nPAPa += nPerc := Round( &CpoCon / nSToM *100 , 20)
	EndIf
		
	If nPAcu <= nFxABCMA
		cFaixa := "A"
	ElseIf nPAcu <= nFxABCMB
		cFaixa := "B"
	ElseIf nPAcu <= nFxABCMC
		cFaixa := "C"
	ElseIf nPAcu <= nFxABCMD
		cFaixa := "D"
	EndIf
	
	
Return cFaixa
*******************************************************************************
Static Function CurABCOV()//3.4  Calculo das Curvas ABC Ofertado e Vendido
*******************************************************************************
	
	Local cSql 		:= ""
	Local nIntPro 	:= 0
	Local nTotIUpd 	:= 0 // Total de Registros Atualizados... 
	
	oProcess:SetRegua1(0);oProcess:SetRegua2(0)
	oProcess:IncRegua1();oProcess:IncRegua2()

	//**************************************************************	
	// Dropar Tabela Tamporaria CABCCV
	oProcess:IncRegua1("Apagando Tabela Auxiliar [CABCCV]" ); oProcess:IncRegua2()
	U_ExecMySql( cSql := "Drop Table CABCCV" , cCursor := "", cModo := "E", lMostra, lChange := .F. )

	//***************************************************************	
	// Criando Tabela Atualizada Base para avaliar Curva ABC Ofertado e Vendido
	oProcess:IncRegua1("Criando e alimentando Tabela Auxiliar [CABCCV] Curva ABC Ofertado e Vendido" ); oProcess:IncRegua2()

	cSql := "CREATE TABLE CABCCV AS "
	cSql += "SELECT DISTINCT ZA7_CODITE CODITE,  "
	cSql += "ZA7_M12OPI, ZA7_M12CPI, "
	cSql += "CASE  "
	cSql += "WHEN ROUND( ZA7_M12OPI / DECODE(ZA7_M12CPI,0,1,ZA7_M12CPI)  , 4 )  >= 0.90 THEN '1' "
	cSql += "WHEN ROUND( ZA7_M12OPI / DECODE(ZA7_M12CPI,0,1,ZA7_M12CPI)  , 4 )  >= 0.80 THEN '2' "
	cSql += "WHEN ROUND( ZA7_M12OPI / DECODE(ZA7_M12CPI,0,1,ZA7_M12CPI)  , 4 )  >= 0.70 THEN '3' "
	cSql += "WHEN ROUND( ZA7_M12OPI / DECODE(ZA7_M12CPI,0,1,ZA7_M12CPI)  , 4 )  >= 0.63 THEN '4' "
	cSql += "WHEN ROUND( ZA7_M12OPI / DECODE(ZA7_M12CPI,0,1,ZA7_M12CPI)  , 4 )  >= 0.50 THEN '5' "
	cSql += "WHEN ROUND( ZA7_M12OPI / DECODE(ZA7_M12CPI,0,1,ZA7_M12CPI)  , 4 )  <  0.50 THEN '6' "
	cSql += "WHEN ROUND( ZA7_M12OPI , 2 ) 			    = 0.00 THEN '7'  "
	cSql += "WHEN ROUND( ZA7_M12CPI , 2 )                = 0.00 THEN '9' "
	cSql += "END	OVE,  "
	cSql += "ZA7_ABCOC, "
	cSql += "ZA7_M12VPI , "
	cSql += "CASE  "
	cSql += "WHEN ROUND( ZA7_M12VPI / DECODE(ZA7_M12OPI,0,1,ZA7_M12OPI)  , 4 )  >= 0.65 THEN '1' "
	cSql += "WHEN ROUND( ZA7_M12VPI / DECODE(ZA7_M12OPI,0,1,ZA7_M12OPI)  , 4 )  >= 0.55 THEN '2' "
	cSql += "WHEN ROUND( ZA7_M12VPI / DECODE(ZA7_M12OPI,0,1,ZA7_M12OPI)  , 4 )  >= 0.50 THEN '3' "
	cSql += "WHEN ROUND( ZA7_M12VPI / DECODE(ZA7_M12OPI,0,1,ZA7_M12OPI)  , 4 )  >= 0.45 THEN '4' "
	cSql += "WHEN ROUND( ZA7_M12VPI / DECODE(ZA7_M12OPI,0,1,ZA7_M12OPI)  , 4 )  >= 0.35 THEN '5' "
	cSql += "WHEN ROUND( ZA7_M12VPI / DECODE(ZA7_M12OPI,0,1,ZA7_M12OPI)  , 4 )  <  0.35 THEN '6' "
	cSql += "WHEN ROUND( ZA7_M12VPI , 2 )			   =  0.00 THEN '7' "
	cSql += "WHEN ROUND( ZA7_M12OPI , 2 )			   =  0.00 THEN '9' "
	cSql += "END VEO, "
	cSql += "ZA7_ABCVO "
	cSql += "FROM ZA7010 ZA7, SB1010 SB1 "
	cSql += "WHERE ZA7.D_E_L_E_T_ = ' ' "
	cSql += "AND   ZA7.ZA7_CODITE > ' ' "
	cSql += "AND   ZA7.ZA7_FILIAL = SB1.B1_FILIAL "
	cSql += "AND   ZA7.ZA7_CODPRO  = SB1.B1_COD "
	cSql += "AND   SB1.B1_FILIAL = '05' "
	cSql += "AND   SB1.B1_GRMAR1 IN ('000001','000002') AND SB1.B1_TIPO IN ('PA','PP','MP') "
	cSql += "AND   SB1.B1_DESC NOT LIKE '%(N USAR)%'  "
	cSql += "AND   SB1.D_E_L_E_T_ = ' '  "
	cSql += "ORDER BY ZA7_CODITE DESC "

	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )

	oProcess:IncRegua1("Consultando Tabela Auxiliar [CABCCV] Curva ABC Ofertado e Vendido" ); oProcess:IncRegua2()
	U_ExecMySql( cSql := "SELECT * FROM CABCCV" , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	DbSelectArea("TAUX");dbGotop();nIntPro := 0
	While !EOF()
		
		If nIntPro == 100
			oProcess:IncRegua1("Atualizando Curva ABC Ofertado e Vendido Item " + CV(TAUX->CODITE)) ; oProcess:IncRegua2()
			nIntPro := 0
		Else
			nIntPro += 1
		EndIf 

		nTotIUpd += 1 
	 	
		cSql := "UPDATE ZA7010 SET ZA7_ABCOC = '"+TAUX->OVE+"', ZA7_ABCVO = '"+TAUX->VEO+"' WHERE ZA7_CODITE = '"+CV(TAUX->CODITE)+"' "
		U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		
		DbSelectArea("TAUX")
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()

	MntLog ("3.5  Montagem Curva ABC Ofertado e Vendido " + ENTER + ; 
			"Foram Atualizados: " + Alltrim( Transform(nTotIUpd,"@E 99,999,999"))  + ENTER + ;
			"em cada Filial por CODITE. ","Campo [ZA7_ABCOC] E [ZA7_ABCVO]" )


Return
*******************************************************************************
Static Function DataRef(nMeses,lUlt)//| Retorna a data dia 1 de nMeses atraz
*******************************************************************************

 	Local dDataAux := dDatabase
 	
 	Default nMeses := 1
 	Default lUlt := .F.
 	
 	For nI := 1 To nMeses
 
 		dDataAux := LastDay(dDataAux,1) - 5
 
 	Next 

 	dDataAux := CToD( '01/' + Substr( dToC(dDataAux) , 4, 7 ))
 	
 	If lUlt
 		dDataAux := LastDay(dDataAux , 0)
 	EndIf 
 	
Return dDataAux
*******************************************************************************
Static Function SToC(sData) //| Converte Data Sistema para Data Caracter 
*******************************************************************************

	Local cData := DToC(StoD(sData))

Return cData

*******************************************************************************
Static Function DropTAux() // Dropa a Tabela Temporaria Auxiliar do MRP
*******************************************************************************

 	cSql := "Drop Table TAUX_MRP"
 	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )


Return Nil
*******************************************************************************
Static Function MntLog(cTexto)// Monta LOG 
*******************************************************************************
	
	cLog += ENTER
	cLog += Replicate("-",50) + ENTER + ENTER
	cLog += cTexto 
	cLog += ENTER + ENTER

Return Nil
*******************************************************************************
Static Function ShowLog()// Mostra o LOG
*******************************************************************************
	
	U_CaixaTexto(cLog)

Return Nil
*******************************************************************************
Static Function CV(xValor)// Converte  Variaveis para Caracter sem espacos
*******************************************************************************
	cValor := ""

	cValor := Alltrim(cValToChar(xValor))

Return cValor