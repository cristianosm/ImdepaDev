#include 'protheus.ch'
#include 'parmtype.ch'

*******************************************************************************
User Function MrpOImd()
*******************************************************************************

	
	Private lMostra := .F.
	
	// Execucoes Diarias
	ExecDiario()
	
	// Execucoes Mensais
	ExecMensal()
	


Return()
*******************************************************************************
Static Function  ExecDiario()
*******************************************************************************
	Local lAbort 	:= .F.
	Local cMsg   	:= "Aguarde o Inicio" 

	Local bAction 	:= {}
	Local cTitulo   := ""

	
	// 1.1 ZA7_PPCOMP => Pedidos em Aberto nos ultimos 6 meses, sem cosiderar mês corrente ou Solitação Futura (Data Necessidade) em aberta .
	bAction 	:= {|| za7ppcomp() }
	cTitulo   	:= "Atualizando ZA7_PPCOMP"
	// Processa( bAction, @cTitulo, @cMsg, @lAbort )
	
	
	// 1.2 ZA7_PGRAMA => SIM - Produto com Programa (Contrato) 
	bAction 	:= {|| ZA7PGRAMA() }
	cTitulo   := "Atualizando ZA7_PGRAMA"
	// Processa( bAction, @cTitulo, @cMsg, @lAbort )



Return Nil
*******************************************************************************
Static function za7ppcomp()
*******************************************************************************

	Local cSql 		:= ""
	Local cSData 	:= dToS(DataRef(nMeses := 6)) // Retorna 6 meses
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo IncProc
	
	ProcRegua(0)
	
	// Consulta Pedidos
	cSql += "SELECT C7_PRODUTO FROM SC7010 "
	cSql += "WHERE C7_QUJE < C7_QUANT "
	cSql += "AND   C7_EMISSAO >= '"+cSData+"' "
	cSql += "AND   D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY C7_PRODUTO "
	
	IncProc("Consultando Pedidos de Compras.. ")
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	
	// Atualiza Todos os Produtos para NAO
	cSql := "UPDATE ZA7010 SET ZA7_PPCOMP = 'N' "
	IncProc("Definido Todos os Produtos como N-Nao em Todas as Filiais...") 
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	// Inicia a Atualizacao 
	DbSelectArea("TAUX");DbGotop()
	While !EOF()
		
		// Atualiza os Produtos para SIM
		cSql := "Update ZA7010 Set ZA7_PPCOMP = 'S' WHERE ZA7_CODPRO = '" + Alltrim(TAUX->C7_PRODUTO) + "' " 
		
		If nIntPro == 100
			IncProc("Atualizando o Produto " +  Alltrim(TAUX->C7_PRODUTO) + " para SIM em Todas asFiliais..." )
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
	
	Iw_MsgBox("Foram Atualizados " + cValToChar(nPAtu) + " Produtos... ","Atualizados...","INFO")
	
Return Nil
*******************************************************************************
Static function ZA7PGRAMA()
*******************************************************************************

	Local cSql 		:= ""
	Local cSData 	:= dToS(CToD( '01/' + Substr( dToC(dDataBase) , 4, 7 ) ) ) // Retorna 6 meses
	Local nPAtu 	:= 0 // Total de Produtos Atualizados 
	Local nIntPro 	:= 0 // Intervalo IncProc

	ProcRegua(0)

	// Consulta Contratos
	cSql += "SELECT C4_PRODUTO FROM SC4010 "
	cSql += "WHERE C4_DATA >= '" + cSData  + "' "
	cSql += "AND   C4_PRODUTO > ' ' "
	cSql += "AND   D_E_L_E_T_ = ' ' "
	cSql += "GROUP BY C4_PRODUTO "

	IncProc("Consultando Contratos de Compras.. ")
	U_ExecMySql( cSql , cCursor := "TAUX", cModo := "Q", lMostra, lChange := .F. )
	
	
	// Atualiza Todos os Produtos para NAO
	cSql := "UPDATE ZA7010 SET ZA7_PGRAMA = 'N' "
	IncProc("Definido Todos os Produtos como N-Nao em Todas as Filiais...") 
	U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra, lChange := .F. )
	
	// Inicia a Atualizacao 
	DbSelectArea("TAUX");DbGotop()
	While !EOF()
		
		// Atualiza os Produtos para SIM
		cSql := "Update ZA7010 Set ZA7_PGRAMA = 'S' WHERE ZA7_CODPRO = '" + Alltrim(TAUX->C4_PRODUTO) + "' " 
		
		If nIntPro == 100
			IncProc("Atualizando o Produto " +  Alltrim(TAUX->C4_PRODUTO) + " para SIM em Todas asFiliais..." )
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
	
	Iw_MsgBox("Foram Atualizados " + cValToChar(nPAtu) + " Produtos... ","Atualizados...","INFO")
	

Return Nil
*******************************************************************************
Static Function  ExecMensal()
*******************************************************************************
	Local lAbort 	:= .F.
	Local cMsg   	:= "Aguarde o Inicio" 

	// 1.3 B1_PRONOVO := 1=S_S;2=S_N;3=N_S;4=N_N => Data de referencia deve estar dentro dos 6 Últimos meses..
	bAction 	:= {|| B1PRONOVO() }
	cTitulo   	:= "Atualizando B1_PRONOVO"
	Processa( bAction, @cTitulo, @cMsg, @lAbort )


	// 1.4 B1_PROATIV => SIM - Produto com Programa (Contrato) 
	// bAction 	:= {|| B1PROATIV() }
	// cTitulo   	:= "Atualizando B1_PROATIV"
	// Processa( bAction, @cTitulo, @cMsg, @lAbort )

Return Nil
******************************************************************************
Static Function B1PRONOVO()
******************************************************************************




Return Nil
******************************************************************************
Static Function B1PROATIV()
******************************************************************************





Return Nil
*******************************************************************************
Static Function DataRef(nMeses)// Retorna a data dia 1 de nMeses atraz
*******************************************************************************

 	Local dDataAux := dDatabase
 	
 	Default nMeses := 1
 
 
 	For nI:=1 To nMeses
 
 		dDataAux := LastDay(dDataAux,1) - 5
 
 	Next 

 	dDataAux := CToD( '01/' + Substr( dToC(dDataAux) , 4, 7 ))
 	
Return dDataAux