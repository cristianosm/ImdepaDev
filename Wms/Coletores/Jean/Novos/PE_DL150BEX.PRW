#INCLUDE "PROTHEUS.CH"

/*
Jean Rehermann - Solutio IT - 23/08/2017
Ponto de Entrada DL150BEX (Antes da Execucao/Estorno do Servico)
Verificar se todos os produtos de todos os servi�os marcados possuem sequencia de abastecimento
Caso algum n�o tenha, nenhum servi�o marcado � executado
*/
//-- Parametros Passados:
//-- PARAMIXB[1] = nOpcx

User Function DL150BEX()

	Local _lRet := .T.
	Local _aSav := GetArea()
	Local _nOpc := PARAMIXB[1]
	Local aSeqAbast := {}
	Local cErros    := ""
	Local cQuery    := ""
	Local cAliasNew := ""
	Local cSrvVazio := Space(Len(DCF->DCF_SERVIC))

	If _nOpc == 1 // Apenas quando for execu��o

		// Jean Rehermann - Solutio IT - 09/10/2017 - Vari�vel p�blica para utiliza��o no PE DL150AEX (tratamento prioridade de convoca��o)
		If Type("__cDocDCF") == "U"
			Public __cDocDCF := ""
		Else
			__cDocDCF := ""
		EndIf

		// Jean Rehermann - Solutio IT - 31/10/2017 - Vari�vel p�blica para utiliza��o no PE DL150AEX (tratamento estorno de pedido)
		If Type("__aIDDCF") == "U"
			Public __aIDDCF := {}
		Else
			__aIDDCF := {}
		EndIf

		Pergunte('DLA150', .F.)
		cAliasNew := GetNextAlias()
		
		cQuery := "SELECT DCF_ID IDDCF, R_E_C_N_O_ RECNODCF,"+ SqlOrder( DCF->( IndexKey( IndexOrd() ) ) )
		cQuery += "  FROM "+ RetSqlName('DCF')
		cQuery += " WHERE DCF_FILIAL = '"+ xFilial("DCF") +"'"
		If mv_par01 == mv_par02
			cQuery += " AND DCF_SERVIC = '"+ mv_par01 +"'"
		Else
			cQuery += " AND DCF_SERVIC BETWEEN '"+ mv_par01 +"' AND '"+ mv_par02 +"'"
		EndIf
		If Empty( mv_par01 ) .Or. Empty( mv_par02 )
			cQuery += " AND DCF_SERVIC <> '"+ cSrvVazio +"'"
		EndIf
		If mv_par03 == 1         //-- Somente Servicos ainda Nao Executados
			cQuery += " AND DCF_STSERV IN (' ','1')"
		ElseIf mv_par03 == 2     //-- Somente Servicos Interrompidos
			cQuery += " AND DCF_STSERV = '2'"
		ElseIf mv_par03 == 4     //-- Somente Servicos Aptos a Execucao (Nao Executados e Iterrompidos)
			cQuery += " AND DCF_STSERV IN ('1','2')"
		EndIf
		cQuery += " AND DCF_OK = '"+ oBrowse:cMark +"'"
		cQuery += " AND D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY "
		cQuery += SqlOrder( DCF->( IndexKey( IndexOrd() ) ) )
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	
		While !(cAliasNew)->( Eof() )
		
		    // Posiciono no registro do servi�o
			DCF->( dbGoTo( (cAliasNew)->RECNODCF ) )
			
			// Verificar se produto possui sequencia de abastecimento
			aSeqAbast := WmsSeqAbast( DCF->DCF_LOCAL, DCF->DCF_CODPRO, 1 )
			
			// Se n�o possui sequencia de abastecimento e for servi�o de recebimento,n�o executa o servi�o
			If Empty( aSeqAbast ) .And. DCF->DCF_SERVIC $ "003"
				If Empty( cErros )
					cErros += "Os produtos abaixo n�o possuem sequ�ncia de abastecimento e os servi�os marcados n�o ser�o executados neste momento: "+ CHR(13) + CHR(10) + CHR(13) + CHR(10)
				EndIf
				cErros += "Produto: "+ DCF->DCF_CODPRO +" Local: "+ DCF->DCF_LOCAL + CHR(13) + CHR(10)
			EndIf
			
			// Vari�vel p�blica para utiliza��o no PE DL150AEX (tratamento prioridade de convoca��o)
			If !DCF->DCF_DOCTO $ __cDocDCF .And. DCF->DCF_ORIGEM == "SC9" .And. DCF->DCF_SERVIC == "001"
				__cDocDCF += DCF->DCF_DOCTO +"','"
			EndIf
			
			// Vari�vel p�blica para utiliza��o no PE DL150AEX (tratamento estorno de pedido)
			If DCF->DCF_ORIGEM == "SC9" .And. DCF->DCF_SERVIC == "001"
				aAdd( __aIDDCF, { DCF->DCF_DOCTO, DCF->DCF_CLIFOR, DCF->DCF_LOJA, DCF->DCF_CODPRO, DCF->DCF_QUANT, (cAliasNew)->IDDCF, DCF->DCF_SERIE } )
			EndIf
			
			(cAliasNew)->( dbSkip() )
		End
	
		(cAliasNew)->( dbCloseArea() )
		
		If !Empty( cErros )
			WmsMessage(cErros,"SEQUENCIA DE ABASTECIMENTO",1,.T.,{"OK"},"")
			__cDocDCF := "" // Limpa a vari�vel p�blica criada para outros tratamentos
			_lRet := .F. // N�o executar� nenhum servi�o marcado
		EndIf

	EndIf
	
		RestArea( _aSav )

Return( _lRet )