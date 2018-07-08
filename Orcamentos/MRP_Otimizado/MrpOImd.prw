#include 'protheus.ch'
#include 'parmtype.ch'

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

	
	Private lMostra := .F.
	Private lStatusP:= .F.
	Private lMedias := .F.
	Private lCoefVar:= .F.
	
	Private lAbort 	
	Private bAbort	:= { || IIf ( lAbort == .T., Alert("Não vá neste momento"), "" ) }
	
	
	If Iw_MsgBox("Deseja Executar Manualmente a Otimização MRP Imdepa","Atenção","YESNO")
	
		lStatusP := Iw_MsgBox("Deseja Atualizar o Status dos Produtos ?","Atenção","YESNO")
		lMedias  := Iw_MsgBox("Deseja Calcular as Médias dos Produtos?","Atenção","YESNO")
		lCoefVar := Iw_MsgBox("Deseja Calcular o Coeficiente de Variabilidade ?","Atenção","YESNO")
	
		// Execucoes Diarias
		ExecDiario()
	
		// Execucoes Mensais
		ExecMensal()
	
	EndIf

Return()
*******************************************************************************
Static Function  ExecDiario()// Execucoes Diarias
*******************************************************************************
	
	Local cMsg   	:= "Aguarde o Inicio" 

	Local bAction 	:= {}
	Local cTitulo   := ""


	If lStatusP
	
		// 1.1 ZA7_PPCOMP => Produtos com Pedidos Abertos 
		bAction 	:= {|| za7ppcomp() }
		cTitulo   	:= "Atualizando (ZA7_PPCOMP) - Produtos com Pedidos"
		Processa( bAction, @cTitulo, @cMsg, @lAbort )
	
	
		// 1.2 ZA7_PGRAMA => SIM - Produto com Programa (Contrato) 
		bAction 	:= {|| ZA7PGRAMA() }
		cTitulo   := "Atualizando (ZA7_PGRAMA) - Produtos com Programa"
		Processa( bAction, @cTitulo, @cMsg, @lAbort )

	EndIf
	

Return Nil
*******************************************************************************
Static function za7ppcomp()	// 1.1 ZA7_PPCOMP => Produtos com Pedidos Abertos 
*******************************************************************************

	Local cSql 		:= ""
	Local cSData 	:= dToS(DataRef(nMeses := 6)) // Retorna 6 meses
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo IncProc
	
	ProcRegua(0)
	IncProc()
	
	// Consulta Pedidos de Compras e Solicitacoes de Compras  
	cSql += "SELECT PRODUTO FROM ( " 
	cSql += "SELECT C7_PRODUTO PRODUTO FROM SC7010 "
	cSql += "WHERE C7_QUJE < C7_QUANT "
	cSql += "AND   C7_EMISSAO >= '"+cSData+"' "
	cSql += "AND   C7_ENCER = ' ' " 
	cSql += "AND   D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY C7_PRODUTO "
	cSql += "UNION " 
	cSql += "SELECT C1_PRODUTO PRODUTO  FROM SC1010 " 
	cSql += "WHERE C1_QUJE < C1_QUANT "
	cSql += "AND   C1_EMISSAO >= '"+cSData+"' "
	cSql += "AND   C1_RESIDUO = ' ' "
	cSql += "AND   D_E_L_E_T_ = ' ' " 
	cSql += "GROUP BY C1_PRODUTO "
	cSql += ") ORDER BY PRODUTO "
	
	
	IncProc("Consultando Pedidos de Compras apartir de "+SToC(cSData))
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	
	// Atualiza Todos os Produtos para NAO
	cSql := "UPDATE ZA7010 SET ZA7_PPCOMP = 'N' WHERE ZA7_PPCOMP <> 'N' "
	IncProc("Definido Todos os Produtos como N-Nao") 
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	// Inicia a Atualizacao 
	DbSelectArea("TAUX");DbGotop()
	While !EOF()
		
		// Atualiza os Produtos para SIM
		cSql := "Update ZA7010 Set ZA7_PPCOMP = 'S' WHERE ZA7_CODPRO = '" + Alltrim(TAUX->PRODUTO) + "' " 
		
		If nIntPro == 100
			IncProc("Atualizando o Produto " +  Alltrim(TAUX->PRODUTO) + " para SIM " )
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
	
	MsgInfo ("Foram Atualizados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " Produtos em cada Filial ","Campo ZA7_PPCOMP")
	
	
	
Return Nil
*******************************************************************************
Static function ZA7PGRAMA()	// 1.2 ZA7_PGRAMA => SIM - Produto com Programa (Contrato)
*******************************************************************************

	Local cSql 		:= ""
	Local cSData 	:= dToS(DataRef(nMeses := 0)) // Retorna 6 meses
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo IncProc

	ProcRegua(0)
	IncProc()

	// Consulta Contratos
	cSql += "SELECT ADB.ADB_CODPRO PRODUTO "
	cSql += "FROM ADA010 ADA INNER JOIN ADB010 ADB "
	cSql += "ON	ADA.ADA_FILIAL = ADB.ADB_FILIAL "
	cSql += "AND ADA.ADA_NUMCTR = ADB.ADB_NUMCTR "
	cSql += "WHERE 	ADA.D_E_L_E_T_ = ' ' "  
	cSql += "AND     ADB.D_E_L_E_T_ = ' ' "
	cSql += "AND 	ADA.ADA_EMISSA >= '" + cSData + "' " 
	cSql += "GROUP BY ADB.ADB_CODPRO " 


	IncProc("Consultando Contratos de Compras apartir de " + SToC(cSData) )
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	
	// Atualiza Todos os Produtos para NAO
	cSql := "UPDATE ZA7010 SET ZA7_PGRAMA = 'N' WHERE ZA7_PGRAMA <> 'N' "
	IncProc("Definido Todos os Produtos como N-Nao") 
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	// Inicia a Atualizacao 
	DbSelectArea("TAUX");DbGotop()
	While !EOF()
		
		// Atualiza os Produtos para SIM
		cSql := "Update ZA7010 Set ZA7_PGRAMA = 'S' WHERE ZA7_CODPRO = '" + Alltrim(TAUX->PRODUTO) + "' " 
		
		If nIntPro == 100
			IncProc("Atualizando o Produto " +  Alltrim(TAUX->PRODUTO) + " para SIM" )
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
	
	MsgInfo ("Foram Atualizados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " Produtos em cada Filial ","Campo ZA7_CODPRO")
	

Return Nil
*******************************************************************************
Static Function  ExecMensal()// Execucoes Mensais
*******************************************************************************
	Local lAbort 	:= .F.
	Local cMsg   	:= "Aguarde o Inicio" 

	// Executa Consultas como Pré-Requisito Mensal
	//PreRecMes()

	If lStatusP
		// 1.3 B1_PRONOVO => Produto NOVO
		bAction 	:= {|| B1PRONOVO() }
		cTitulo   	:= "Atualizando B1_PRONOVO"
		Processa( bAction, @cTitulo, @cMsg, @lAbort )


		//1.4 B1_PROATIV => SIM - Produtos Ativos 
		bAction 	:= {|| B1PROATIV() }
		cTitulo   	:= "Atualizando B1_PROATIV"
		Processa( bAction, @cTitulo, @cMsg, @lAbort )
	
	
		//1.5 B1_MSBLOQ => SIM - Produtos Bloqueados 
		bAction 	:= {|| B1MSBLOQ() }
		cTitulo   	:= "Atualizando B1_MSBLOQ"
		Processa( bAction, @cTitulo, @cMsg, @lAbort )

	Endif

	If lMedias 
		//2.1.1  Calcular Média do COV
		bAction 	:= {|| MediaCOV() }
		cTitulo   	:= "Calculando Media COV"
		Processa( bAction, @cTitulo, @cMsg, @lAbort )

		//2.1.2  Calcular Média do COV
		bAction 	:= {|| SomaMCOV() }
		cTitulo   	:= "Calculando Soma Media COV"
		Processa( bAction, @cTitulo, @cMsg, @lAbort )
	EndIf
	
	If lCoefVar 

		//2.2  Calculo do Coeficiente de Variabilidade 
		bAction 	:= {|| CoefVar() }
		cTitulo   	:= "Calculando o Coeficiente de Variabilidade"
		Processa( bAction, @cTitulo, @cMsg, @lAbort )
	
	Endif 
	
	
	
Return Nil
******************************************************************************
Static Function PreRecMes()
******************************************************************************


Return Nil
******************************************************************************
Static Function B1PRONOVO() // 1.3 B1_PRONOVO => Produto NOVO
******************************************************************************
	Local cSql 		:= ""
	Local cSData 	:= dToS(DataRef(nMeses := 6)) // Retorna 6 meses
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo IncProc

	ProcRegua(0)
	IncProc()

	// Consulta Produtos Novos
	cSql += "SELECT B1_COD PRODUTO "
	cSql += "FROM SB1010 "
	cSql += "WHERE B1_FILIAL = '05' " 
	cSql += "AND   B1_DATREF >= '" + cSData + "' " 
	cSql += "AND   D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY B1_COD "

	IncProc("Consultando Produtos Novos apartir de " + SToC(cSData) )
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	
	// Atualiza Todos os Produtos para NAO
	cSql := "UPDATE SB1010 SET B1_PRONOVO = 'N' WHERE B1_PRONOVO <> 'N' "
	IncProc("Definido Todos os Produtos como Novo N-Nao") 
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	// Inicia a Atualizacao 
	DbSelectArea("TAUX");DbGotop()
	While !EOF()
		
		// Atualiza os Produtos para SIM
		cSql := "UPDATE SB1010 SET B1_PRONOVO = 'S' WHERE B1_COD = '" + Alltrim(TAUX->PRODUTO) + "' " 
		
		If nIntPro == 100
			IncProc("Atualizando o Produto " +  Alltrim(TAUX->PRODUTO) + " para SIM" )
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
	
	MsgInfo ("Foram Atualizados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " Produtos em cada Filial ","Campo B1_PRONOVO")

Return Nil
******************************************************************************
Static Function B1PROATIV()//1.4 B1_PROATIV => SIM - Produtos Ativos 
******************************************************************************
	Local cSql 		:= ""
	Local cSData 	:= dToS(DataRef(nMeses := 6)) // Retorna 6 meses
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo IncProc
	Local oHTCov	:= HMNew()	// Tabela Hash COV
	Local oHTEst	:= HMNew()	// Tabela Hash Estoque
	Local oHTPor	:= HMNew()	// Tabela Hash PO 
	Local oHTPar	:= HMNew()	// Tabela Hash Parametros Produto 
	Local aValHT	:= Nil		// Auxiliar para Obter Valor nas Hash Tables 
	
	ProcRegua(0)
	IncProc()

	//*************************************************************************
	// Consulta Produtos Ativos COV
	//*************************************************************************
	cSql := "SELECT ZA0_PRODUT PRODUTO FROM ZA0010 "
	cSql += "WHERE ZA0_DTNECL >= '" + cSData + "' "
	cSql += "AND   D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY ZA0_PRODUT "

	IncProc("Consultando COV apartir de  " + SToC(cSData) )
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
	cSql := "SELECT B2_COD PRODUTO FROM SB2010 "
	cSql += "WHERE B2_QATU > 0  "
	cSql += "AND   B2_LOCAL IN ('01','02') "
	cSql += "AND   D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY B2_COD "
	
	IncProc("Consultando Estoque dos Produtos ")
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )

	DbSelectArea("TAUX");DbGoTop()
	While !EOF()
		HMAdd(oHTEst,{ TAUX->PRODUTO } )
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()


	//*************************************************************************
	// Consulta Produtos com PO em Aberto
	//*************************************************************************
	cSData 	:= dToS(DataRef(nMeses := 12))
	cSql := "SELECT SW3.W3_COD_I PRODUTO "
	cSql += "FROM SW2010 SW2 INNER JOIN SW3010 SW3 "
	cSql += "ON 	SW2.W2_FILIAL = SW3.W3_FILIAL "
	cSql += "AND  SW2.W2_PO_NUM = SW3.W3_PO_NUM "
	cSql += "				INNER JOIN SW5010 SW5 "
	cSql += "ON  SW3.W3_FILIAL = SW5.W5_FILIAL "
	cSql += "AND SW3.W3_PO_NUM = SW5.W5_PO_NUM "
	cSql += "AND SW3.W3_POSICAO = SW5.W5_POSICAO "
	cSql += "AND SW3.W3_COD_I = SW5.W5_COD_I "
	cSql += "WHERE SW2.D_E_L_E_T_ = ' ' "
	cSql += "AND   SW2.W2_PO_DT >= '" + cSData + "' "
	cSql += "AND   SW3.W3_SEQ = 0 "
	cSql += "AND   SW3.D_E_L_E_T_ = ' ' "
	cSql += "AND   SW5.D_E_L_E_T_ = ' ' "
	cSql += "AND   SW5.W5_SALDO_Q > 0 "
	cSql += "GROUP BY SW3.W3_COD_I "

	IncProc("Consulta Produtos com PO em Aberto")
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )

	DbSelectArea("TAUX");DbGoTop()
	While !EOF()
		HMAdd(oHTPor,{ TAUX->PRODUTO } )
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()



	//*************************************************************************
	// Consulta Status dos Produtos 
	//*************************************************************************

	cSql := "SELECT B1_COD PRODUTO, B1_PRONOVO PRONOVO, ZA7_ITEMNO ITEMNOVO, ZA7_PGRAMA PROGRAMA, ZA7_PPCOMP PEDIDO "
	cSql += "FROM SB1010 SB1 INNER JOIN ZA7010 ZA7 "
	cSql += "ON SB1.B1_FILIAL = ZA7.ZA7_FILIAL "
	cSql += "AND SB1.B1_COD = ZA7.ZA7_CODPRO "
	cSql += "WHERE B1_FILIAL = '05' "
	cSql += "AND   B1_GRMAR1 IN ('000001','000002') "
	cSql += "AND   SB1.D_E_L_E_T_ = ' ' "
	cSql += "AND   ZA7.D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY B1_COD, B1_PRONOVO, ZA7_ITEMNO, ZA7_PGRAMA, ZA7_PPCOMP "

	IncProc("Consulta Parametros dos Produtos ")
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )


	//*************************************************************************
	// Atualiza Todos os Produtos para NAO
	//*************************************************************************
	
	cSql := "UPDATE SB1010 SET B1_PROATIV = 'N' WHERE B1_PROATIV <> 'N' "
	IncProc("Definido Todos os Produtos como Ativo N-Nao") 
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	// Inicia a Atualizacao 
	DbSelectArea("TAUX");DbGotop()
	While !EOF()
		
		lUpd := .F. // Deve Atualizar o Produto ?
		
		// Produto Possui COV ou Estoque ou PO Easy em Aberto
		If HMGet(oHTCov , TAUX->PRODUTO , @aValHT) .Or. HMGet(oHTEst , TAUX->PRODUTO , @aValHT) .Or. HMGet(oHTPor , TAUX->PRODUTO , @aValHT)
			lUpd := .T.
			
		ElseIf TAUX->PRONOVO == "S" .Or.  TAUX->ITEMNOVO  == "S" .Or.  TAUX->PROGRAMA  == "S" .Or.  TAUX->PEDIDO == "S"
			lUpd := .T.
		EndIf
		
		
		
		If lUpd
		
			// Atualiza os Produtos para SIM
			cSql := "UPDATE SB1010 SET B1_PROATIV = 'S' WHERE B1_COD = '" + Alltrim(TAUX->PRODUTO) + "' "
		
			If nIntPro == 100
				IncProc("Atualizando o Produto " +  Alltrim(TAUX->PRODUTO) + " para SIM" )
				nIntPro := 0
			Else
				nIntPro += 1
			EndIf 
		
			U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
			
			nPAtu += 1
			
		EndIf
		
		
		DbSelectArea("TAUX")
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	MsgInfo ("Foram Atualizados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " Produtos em cada Filial ","Campo B1_PROATIV")

Return Nil
******************************************************************************
Static Function B1MSBLOQ()//1.5 B1_MSBLOQ => SIM - Produtos Bloqueados 
******************************************************************************
	Local cSql 		:= ""
	Local cSData 	:= dToS(DataRef(nMeses := 24)) 
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo IncProc
	Local oHTCov	:= HMNew()	// Tabela Hash COV
	Local aValHT	:= Nil		// Auxiliar para Obter Valor nas Hash Tables 
	
	ProcRegua(0)
	IncProc()
	//*************************************************************************
	// Consulta Produtos com Movimento COV
	//*************************************************************************
	cSql := "SELECT ZA0_PRODUT PRODUTO FROM ZA0010 "
	cSql += "WHERE ZA0_DTNECL >= '" + cSData + "' "
	cSql += "AND   D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY ZA0_PRODUT "

	IncProc("Consultando COV apartir de  " + SToC(cSData) )
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
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
	cSql += "FROM SB1010 "
	cSql += "WHERE B1_FILIAL = '05' "
	cSql += "AND   B1_DATREF < '" + cSData + "' "
	cSql += "AND   B1_PROATIV = 'N' "
	cSql += "AND   B1_MSBLQL IN (' ','2') "
	cSql += "AND	  D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY B1_COD"
	
	IncProc("Verificando Produtos ATIVOS e com Data REF apartir de  " + SToC(cSData) )
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
		DbSelectArea("TAUX");DbGoTop()
	While !EOF()
		
		// Verifica se o Produto esta no COV nos Ultimos 24 meses 
		If! HMGet(oHTCov , TAUX->PRODUTO , @aValHT)
		
			// Atualiza os Produtos para SIM
			cSql := "UPDATE SB1010 SET B1_MSBLQL = '1' WHERE B1_COD = '" + Alltrim(TAUX->PRODUTO) + "' "
	
			If nIntPro == 100
				IncProc("Atualizando o Produto " +  Alltrim(TAUX->PRODUTO) + " para BLOQUEADO" )
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
	
	MsgInfo ("Foram Bloqueados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " Produtos em cada Filial ","Campo B1_MSBLQL")

Return Nil 
******************************************************************************
Static Function MediaCOV()//1.5 B1_MSBLOQ => SIM - Produtos Bloqueados 
******************************************************************************
	Local cSql 		:= ""
	Local cSDataI 	:= dToS(DataRef(nMeses := 12))
	Local cSDataF 	:= dToS(DataRef(nMeses := 0 ))  
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo IncProc
	Local oHTCov	:= HMNew()	// Tabela Hash COV
	Local aValHT	:= Nil		// Auxiliar para Obter Valor nas Hash Tables 


	ProcRegua(0)
	IncProc()
	//*************************************************************************
	// Montando Media do COV  
	//*************************************************************************

	cSql := "SELECT FILIAL, PRODUTO, SUM(MCONS) MCONS, SUM(MOFER) MOFER, SUM(MVREV) MVREV, SUM(MFATU) MFATU "
	cSql += "FROM ( "
	cSql += "SELECT ZA0.ZA0_FILIAL FILIAL, ZA0.ZA0_PRODUT PRODUTO, " 
	cSql += "Round( Sum(ZA0.ZA0_QUANTD) / COUNT(ZA0.ZA0_QUANTD),2) MCONS, " 
	cSql += "Round( Sum(ZA0.ZA0_QOFERT) / COUNT(ZA0.ZA0_QUANTD),2) MOFER, " 
	cSql += "Round( Sum(ZA0.ZA0_VENDRE) / COUNT(ZA0.ZA0_QUANTD),2) MVREV, "
	cSql += "Round( Sum(0) ,2) MFATU " 
	cSql += "FROM ZA0010 ZA0 "
	cSql += "WHERE ZA0.ZA0_DTNECL BETWEEN '" + cSDataI + "' AND '" + cSDataF + "' "
	cSql += "GROUP BY ZA0.ZA0_FILIAL, ZA0.ZA0_PRODUT "
	cSql += "UNION "   
	cSql += "SELECT  SD2.D2_FILIAL FILIAL, SD2.D2_COD PRODUTO, "
	cSql += "Round( Sum(0) ,2) MCONS, " 
	cSql += "Round( Sum(0) ,2) MOFER, " 
	cSql += "Round( Sum(0) ,2) MVREV, "
	cSql += "Round( Sum(SD2.D2_QUANT) / COUNT(SD2.D2_QUANT),2) MFATU "
	cSql += "FROM SD2010 SD2 INNER JOIN SF2010 SF2 "
	cSql += "ON   SD2.D2_FILIAL = SF2.F2_FILIAL "
	cSql += "AND  SD2.D2_DOC    = SF2.F2_DOC "
	cSql += "AND  SD2.D2_SERIE  = SF2.F2_SERIE "
	cSql += "AND  SD2.D2_CLIENTE= SF2.F2_CLIENT "
	cSql += "AND  SD2.D2_LOJA   = SF2.F2_LOJA "
	cSql += "INNER JOIN SF4010 SF4 "
	cSql += "ON  SD2.D2_FILIAL = SF4.F4_FILIAL "
	cSql += "AND SD2.D2_TES    = SF4.F4_CODIGO "
	cSql += "WHERE SF2.F2_EMISSAO BETWEEN '" + cSDataI + "' AND '" + cSDataF + "' "
	cSql += "AND   SF4.F4_ESTOQUE = 'S' "
	cSql += "AND   SF4.F4_DUPLIC = 'S' "
	cSql += "AND   SF2.F2_CLIENT <> 'N00000' "
	cSql += "AND   SD2.D_E_L_E_T_ = ' ' "
	cSql += "AND   SF2.D_E_L_E_T_ = ' ' "
	cSql += "AND   SF4.D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY SD2.D2_FILIAL, SD2.D2_COD "
	cSql += ") " 
	cSql += "GROUP BY FILIAL, PRODUTO "
	cSql += "ORDER BY PRODUTO, FILIAL "

	IncProc("Montando Media do COV Periodo: ["+SToC(cSDataI)+" ate "+SToC(cSDataF)+"] " )
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )

	
	//*************************************************************************
	// Zerando Todos as Medias do COV
	//*************************************************************************
	
	cSql := "UPDATE ZA7010 SET ZA7_M12CP = 0, ZA7_M12OP  = 0, ZA7_M12VP  = 0, ZA7_M12VRP  = 0 "
	IncProc("Zerando Todas as Médias [ZA7_M12CP,ZA7_M12OP,ZA7_M12VP,ZA7_M12VRP]") 
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )


	DbSelectArea("TAUX");DbGoTop()
	While !EOF()
		
			// Atualiza os Produtos para SIM
			cSql := "UPDATE ZA7010 SET "
			cSql += "ZA7_M12CP 	= "+cValToChar(TAUX->MCONS)+", " // Média 12 Meses Consultado.
			cSql += "ZA7_M12OP  = "+cValToChar(TAUX->MOFER)+", " // Média 12 Meses Ofertado.
			cSql += "ZA7_M12VP  = "+cValToChar(TAUX->MFATU)+", " // Média 12 Meses Vendido.
			cSql += "ZA7_M12VRP = "+cValToChar(TAUX->MVREV)+"  " // Média 12 Meses Venda Revisada.
			cSql += "WHERE ZA7_FILIAL = "+Alltrim(TAUX->FILIAL)+" AND ZA7_CODPRO = '" + Alltrim(TAUX->PRODUTO) + "' "
	
			If nIntPro == 100
				IncProc("Atualizando as Medias da [Filial-Produto] " + Alltrim(TAUX->FILIAL) +"-"+Alltrim(TAUX->PRODUTO) + "" )
				nIntPro := 0
			Else
				nIntPro += 1
			EndIf 
		
			U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		
			nPAtu += 1
			
			eVal(bAbort)
			
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	MsgInfo ("Foram Atualizados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " Produtos ","Campos [ZA7_M12CP,ZA7_M12OP,ZA7_M12VP,ZA7_M12VRP]")

Return Nil
******************************************************************************
Static Function SomaMCOV()//1.5 B1_MSBLOQ => SIM - Produtos Bloqueados 
******************************************************************************
	Local cSql 		:= ""
	Local cSDataI 	:= dToS(DataRef(nMeses := 12))
	Local cSDataF 	:= dToS(DataRef(nMeses := 0 ))  
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo IncProc
	Local oHTCov	:= HMNew()	// Tabela Hash COV
	Local aValHT	:= Nil		// Auxiliar para Obter Valor nas Hash Tables 


	ProcRegua(0)
	IncProc()
	//*************************************************************************
	// Montando Media do COV  
	//*************************************************************************

	cSql := "SELECT SB1.B1_CODITE CODITE,  SUM(MCONS) SMCONS, SUM(MOFER) SMOFER, SUM(MVREV) SMVREV, SUM(MFATU) SMFATU "
	cSql += "FROM (	 "
	cSql += "SELECT FILIAL, PRODUTO, SUM(MCONS) MCONS, SUM(MOFER) MOFER, SUM(MVREV) MVREV, SUM(MFATU) MFATU "
	cSql += "FROM ( "
	cSql += "SELECT ZA0.ZA0_FILIAL FILIAL, ZA0.ZA0_PRODUT PRODUTO, " 
	cSql += "Round( Sum(ZA0.ZA0_QUANTD) / COUNT(ZA0.ZA0_QUANTD),2) MCONS, " 
	cSql += "Round( Sum(ZA0.ZA0_QOFERT) / COUNT(ZA0.ZA0_QUANTD),2) MOFER, "
	cSql += "Round( Sum(ZA0.ZA0_VENDRE) / COUNT(ZA0.ZA0_QUANTD),2) MVREV, "
	cSql += "Round( Sum(0) ,2) MFATU  "
	cSql += "FROM ZA0010 ZA0 INNER JOIN SB1010 SB1 "
	cSql += "ON ZA0.ZA0_FILIAL = SB1.B1_FILIAL "
	cSql += "AND ZA0.ZA0_PRODUT = SB1.B1_COD  "
	cSql += "WHERE ZA0.ZA0_DTNECL BETWEEN '" + cSDataI + "' AND '" + cSDataF + "' "
	cSql += "AND   SB1.B1_PROATIV = 'S' "
	cSql += "AND   ZA0.D_E_L_E_T_ = ' ' "
	cSql += "AND   SB1.D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY ZA0.ZA0_FILIAL, ZA0.ZA0_PRODUT "
	cSql += "UNION    "
	cSql += "SELECT  SD2.D2_FILIAL FILIAL, SD2.D2_COD PRODUTO, "
	cSql += "Round( Sum(0) ,2) MCONS,  "
	cSql += "Round( Sum(0) ,2) MOFER,  "
	cSql += "Round( Sum(0) ,2) MVREV, "
	cSql += "Round( Sum(SD2.D2_QUANT) / COUNT(SD2.D2_QUANT),2) MFATU "
	cSql += "FROM SD2010 SD2 INNER JOIN SF2010 SF2 "
	cSql += "ON   SD2.D2_FILIAL = SF2.F2_FILIAL "
	cSql += "AND  SD2.D2_DOC    = SF2.F2_DOC "
	cSql += "AND  SD2.D2_SERIE  = SF2.F2_SERIE "
	cSql += "AND  SD2.D2_CLIENTE= SF2.F2_CLIENT "
	cSql += "AND  SD2.D2_LOJA   = SF2.F2_LOJA "
	cSql += "		INNER JOIN SF4010 SF4 "
	cSql += "ON  SD2.D2_FILIAL = SF4.F4_FILIAL "
	cSql += "		INNER JOIN SB1010 SB1 "
	cSql += "ON   SD2.D2_FILIAL = SB1.B1_FILIAL "
	cSql += "AND  SD2.D2_COD    = SB1.B1_COD "
	cSql += "AND SD2.D2_TES    = SF4.F4_CODIGO "
	cSql += "WHERE SF2.F2_EMISSAO BETWEEN '" + cSDataI + "' AND '" + cSDataF + "' "
	cSql += "AND   SF4.F4_ESTOQUE = 'S' "
	cSql += "AND   SF4.F4_DUPLIC = 'S' "
	cSql += "AND   SB1.B1_PROATIV = 'S' "
	cSql += "AND   SF2.F2_CLIENT <> 'N00000' " 
	cSql += "AND   SD2.D_E_L_E_T_ = ' ' "
	cSql += "AND   SF2.D_E_L_E_T_ = ' ' "
	cSql += "AND   SF4.D_E_L_E_T_ = ' ' "
	cSql += "AND   SB1.D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY SD2.D2_FILIAL, SD2.D2_COD "
	cSql += ")  "
	cSql += "GROUP BY FILIAL, PRODUTO "
	cSql += "ORDER BY PRODUTO, FILIAL "
	cSql += ") MED, "
	cSql += "SB1010 SB1 "
	cSql += "WHERE SB1.B1_FILIAL = '05' "
	cSql += "AND   SB1.B1_COD = MED.PRODUTO "
	cSql += "GROUP BY SB1.B1_CODITE "

	IncProc("Montando Soma Media do COV por CODITE Periodo: ["+SToC(cSDataI)+" ate "+SToC(cSDataF)+"] " )
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )

	
	//*************************************************************************
	// Zerando Todos as Medias do COV
	//*************************************************************************
	
	cSql := "UPDATE ZA7010 SET ZA7_M12CPI = 0, ZA7_M12OPI  = 0, ZA7_M12VPI  = 0, ZA7_M12VRI  = 0 "
	IncProc("Zerando Todas as Somas de Médias [ZA7_M12CPI,ZA7_M12OPI,ZA7_M12VPI,ZA7_M12VRI]") 
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )


	DbSelectArea("TAUX");DbGoTop()
	While !EOF()
		
			// Atualiza os CODITE 
			cSql := "UPDATE ZA7010 SET "
			cSql += "ZA7_M12CPI  = " + cValToChar(TAUX->SMCONS) + ", " // Soma da Média do Consultado.
			cSql += "ZA7_M12OPI  = " + cValToChar(TAUX->SMOFER) + ", " // Soma da Média do Ofertado.
			cSql += "ZA7_M12VPI  = " + cValToChar(TAUX->SMFATU) + ", " // Soma da Média do Vendido.
			cSql += "ZA7_M12VRI  = " + cValToChar(TAUX->SMVREV) + ", " // Soma da Média do Venda Revisada.
			cSql += "WHERE ZA7_CODITE = '" + Alltrim(TAUX->SMFATU) + "' "
			
			If nIntPro == 100
				IncProc("Atualizando as Somas Media do CodItem " + Alltrim(TAUX->SMFATU) + "" )
				nIntPro := 0
			Else
				nIntPro += 1
			EndIf 
		
			U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		
			nPAtu += 1
			
			eVal(bAbort)

		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	MsgInfo ("Foram Atualizados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " CodItens em Cada Filial  ","Campos [ZA7_M12CPI,ZA7_M12OPI,ZA7_M12VPI,ZA7_M12VRI]")

Return Nil
*******************************************************************************
Static Function CoefVar()
*******************************************************************************

	Local cSql := ""
	Local cSDataI 	:= dToS(DataRef(nMeses := 36))
	Local cSDataF 	:= dToS(DataRef(nMeses := 0 ))  
	
	Local cCoefMin 	:= Alltrim(cValToChar(0.25))
	Local cCoefMax 	:= Alltrim(cValToChar(1.50))
	
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo IncProc
	
	
	ProcRegua(0)
	IncProc()

	// Dropar Tabela Tamporaria COEFVAR
	IncProc("Apagando Tabela Temporária" )
	U_ExecMySql( cSql := "Drop Table COEFVAR" , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	
	//***************************************************************	
	// Criando Tabela Atualizada Base para o Calculo do Coeficiente ja com SOMA VR 
	IncProc("Criando Tabela Base Coeficiente Variavel [COEFVAR]" )
	
	cSql := "CREATE TABLE COEFVAR AS "
	cSql += "SELECT SB1.B1_CODITE 				ITEM, " 
	cSql += "		SUBSTR(ZA0.ZA0_DTNECL,1,6) 	MESANO, "
	cSql += "ROUND( SUM(ZA0.ZA0_VENDRE) )		SOMAVR, "
	cSql += "ROUND( SUM(0) )					MEDIAVR, "
	cSql += "ROUND( SUM(0) ) 					VLABS, "
	cSql += "ROUND( SUM(0) ) 					MEDIAABS, "
	cSql += "ROUND( SUM(0) ) 					DESVPAD, "
	cSql += "ROUND( SUM(0) ) 					COEFICIENTE "
	cSql += "FROM ZA0010 ZA0 INNER JOIN SB1010 SB1 "
	cSql += "ON   ZA0.ZA0_PRODUT = SB1.B1_COD "
	cSql += "WHERE ZA0.ZA0_DTNECL BETWEEN '" + cSDataI + "' AND '" + cSDataF + "' "
	cSql += "AND   ZA0.D_E_L_E_T_ = ' ' "
	cSql += "AND   SB1.B1_FILIAL = '05' "
	cSql += "AND   SB1.D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY SB1.B1_CODITE, SUBSTR(ZA0.ZA0_DTNECL,1,6) "

	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	//***************************************************************
	// Indexando Tabela  [COEFVAR] pelo Item para melhor performance  
	IncProc("Indexando Tabela [COEFVAR] por Item " )
	cSql := "CREATE INDEX SIGA.IDX_COEFVAR ON SIGA.COEFVAR(ITEM) TABLESPACE SIGA_INDEX"
	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra , lChange := .F. )
	
	
	//***************************************************************
	// Calculando Média VR por Item   
	IncProc("Calculando Média VR por Item " )
	
	DropTAux() // Dropa a Tabela Temporaria Auxiliar do MRP
	 
	cSql := "CREATE TABLE TAUX_MRP AS "  
	cSql += "SELECT 	SB1.B1_CODITE 				ITEM, " 
	cSql += "ROUND( SUM(ZA0.ZA0_VENDRE) / COUNT(ZA0.ZA0_VENDRE) ,4 ) MEDIAVR "
	cSql += "FROM ZA0010 ZA0 INNER JOIN SB1010 SB1 "
	cSql += "ON   ZA0.ZA0_PRODUT = SB1.B1_COD "
	cSql += "WHERE ZA0.ZA0_DTNECL BETWEEN  '" + cSDataI + "' AND '" + cSDataF + "' "
	cSql += "AND   ZA0.D_E_L_E_T_ = ' ' "
	cSql += "AND   SB1.B1_FILIAL = '05' "
	cSql += "AND   SB1.D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY SB1.B1_CODITE "
	
	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	//***************************************************************
	// Atualizando Média VR por Item   
	IncProc("Atualizando Média VR na Tabela [COEFVAR]" )
	
	cSql := "UPDATE COEFVAR CV SET CV.MEDIAVR = ( SELECT AUX.MEDIAVR FROM TAUX_MRP AUX WHERE AUX.ITEM = CV.ITEM )"
	cSql += "WHERE CV.ITEM IN ( SELECT AUX.ITEM FROM TAUX_MRP AUX WHERE AUX.ITEM = CV.ITEM )"
	
	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	//***************************************************************
	// Calculando Valor Absoluto   
	IncProc("Calculando Valor Absoluto e Aplicando na Tabela [COEFVAR]" )
	cSql := "UPDATE COEFVAR CV SET CV.VLABS =  ROUND ( ABS(SOMAVR - MEDIAVR) , 2 )"
	
	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	//***************************************************************
	// Calculando Média do Valor  Absoluto   
	IncProc("Calculando Média do Valor  Absoluto" )
	
	DropTAux() // Dropa a Tabela Temporaria Auxiliar do MRP
	
	cSql := "CREATE TABLE TAUX_MRP AS "  
	cSql += "SELECT CV.ITEM,  ROUND( SUM(CV.VLABS),4) SOMA, ROUND( COUNT(CV.VLABS),4) QTD, ROUND( SUM(CV.VLABS) / COUNT(CV.VLABS) ,4 ) MEDIAABS " 
	cSql += "FROM COEFVAR CV GROUP BY CV.ITEM "
	
	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	

	//***************************************************************
	// Atualizando Média do Valor Absoluto
	IncProc("Atualizando Média do Valor Absoluto na Tabela [COEFVAR]" )
	
	cSql := "UPDATE COEFVAR CV SET CV.MEDIAABS = ( SELECT AUX.MEDIAABS FROM TAUX_MRP AUX WHERE AUX.ITEM = CV.ITEM )"
	cSql += "WHERE CV.ITEM IN ( SELECT AUX.ITEM FROM TAUX_MRP AUX WHERE AUX.ITEM = CV.ITEM )"
	
	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	

	//***************************************************************
	// Calculando Desvio Padrao 
	IncProc("Calculando Desvio Padrao e Aplicando na Tabela [COEFVAR]" )
	cSql := "UPDATE COEFVAR SET COEFVAR.DESVPAD = ROUND( ( COEFVAR.MEDIAABS / 36 ) ,4 )"
	
	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	

	//***************************************************************
	// Calculando Coeficiente e Atualizando na Tabela 
	IncProc( "Calculando Coeficiente e Atualizando na Tabela [COEFVAR]" )
	cSql := "UPDATE COEFVAR SET COEFICIENTE = CASE " 
	cSql += "WHEN ROUND( DESVPAD / DECODE(MEDIAVR,0,1,MEDIAVR) ,4) < "+cCoefMin+" THEN "+cCoefMin+" " 
	cSql += "WHEN ROUND( DESVPAD / DECODE(MEDIAVR,0,1,MEDIAVR) ,4) > "+cCoefMax+" THEN "+cCoefMax+" "
	cSql += "ELSE ROUND( DESVPAD / DECODE(MEDIAVR,0,1,MEDIAVR) ,4) "
	cSql += "END "

	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	//***************************************************************
	// Preparando para Atualizar ZA7_CVVRIT
	IncProc( "incianco atualizacao do Campo ZA7_CVVRIT " )
	
	cSql := "SELECT ITEM, MAX(COEFICIENTE) COEFICIENTE FROM COEFVAR GROUP BY ITEM"
	U_ExecMySql( cSql, cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	

	DbSelectArea("TAUX");DbGoTop()
	While !EOF()
		
			// Atualizando ZA7_CVVRIT
			cSql := "UPDATE ZA7010 SET "
			cSql += "ZA7_CVVRIT  = " + cValToChar(TAUX->COEFICIENTE) + " " // Soma da Média do Consultado.
			cSql += "WHERE ZA7_CODITE = '" + Alltrim(TAUX->ITEM) + "' "
			
			If nIntPro == 100
				IncProc("Atualizando Coeficiente [ZA7_CVVRIT] do ITEM " + Alltrim(TAUX->ITEM) + "" )
				nIntPro := 0
			Else
				nIntPro += 1
			EndIf 
		
			U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
		
			nPAtu += 1
			
			eVal(bAbort)
			
		DbSkip()
	EndDo
	DbSelectArea("TAUX");DbCloseArea()
	
	MsgInfo ("Foram Atualizados " + Alltrim( Transform(nPAtu,"@E 99,999,999")) + " CODITE em Cada Filial  ","Campo [ZA7_CVVRIT]")	
	
Return Nil 
*******************************************************************************
Static Function DataRef(nMeses)//| Retorna a data dia 1 de nMeses atraz
*******************************************************************************

 	Local dDataAux := dDatabase
 	
 	Default nMeses := 1
 
 	For nI:=1 To nMeses
 
 		dDataAux := LastDay(dDataAux,1) - 5
 
 	Next 

 	dDataAux := CToD( '01/' + Substr( dToC(dDataAux) , 4, 7 ))
 	
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
 	U_ExecMySql( cSql, cCursor := "", cModo := "E", lMostra := .F., lChange := .F. )

Return Nil