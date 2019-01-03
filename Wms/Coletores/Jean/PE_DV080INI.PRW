#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"

/*
Jean Rehermann - Solutio IT - 30/08/2017
Ponto de entrada antes de efetuar as leituras de confirmação de endereço
Utilizado para reposicionar o SDB de acordo com o produto lido
*/

User Function DV080INI

	Local cProduto := ""
    Local lSelPrd  := SuperGetMV('IMD_SELPEN', .F., .F.) // Seleciona produto no endereçamento?
    
	If lSelPrd .And. SDB->DB_SERVIC == "003" .And. SDB->DB_TAREFA == "009" .And. SDB->DB_ATIVID == "042"

		While .T.
	
			cProduto := Space( Len( SDB->DB_PRODUTO ) )
	
			DLVTCabec("__Seleciona Produto_",.F.,.F.,.T.)
			@ 02,00  VTSay "Informe o Produto"
			@ 03,00  VtGet cProduto Picture "@!" Valid AltPrdEnd( cProduto )
			VtRead()
	
			If VTLastKey() == 27 .Or. !Empty( cProduto ) .Or. ( Empty( cProduto ) .And. VTLastKey() == 13 )
				Exit
			EndIf
	
		EndDo

	EndIf

Return


// Verifica se o produto digitado no endereçamento existe no documento, quando for diferente do SDB posicionado
Static Function AltPrdEnd( cCodPrd )

	Local _lRet      := .T.
	Local nQE        := 0
	Local cQuery     := ""
	Local cAliasQry  := ""
	Local cRecHVazio := Space(TamSX3("DB_RECHUM")[1])
	Local cProdSB1   := ""
	Local aProduto   := {}

	If Empty( cCodPrd )
		Return _lRet
	EndIf

	cProdSB1 := CBRetEtiEAN( cCodPrd )
	
	If Empty( cProdSB1 )
		
		aProduto := CBRetEti( cCodPrd, "01" )
		
		If Len( aProduto ) > 0
			cCodPrd := "'"+ aProduto[ 1 ] +"'"
		Else
			DLVTAviso("___Produto___","Produto lido não localizado!")
			VTKeyBoard( Chr(20) )
			_lRet := .F.
		EndIf
	Else
		cCodPrd := cProdSB1
	EndIf
	
	If _lRet

		cQuery := "SELECT R_E_C_N_O_"
		cQuery += "  FROM "+ RetSqlName('SDB') +" SDB"
		cQuery += " WHERE DB_FILIAL  = '"+ xFilial("SDB") +"'"
		cQuery +=   " AND DB_ESTORNO = ' '"
		cQuery +=   " AND DB_ATUEST  = 'N'"
		cQuery +=   " AND DB_DOC     = '"+ SDB->DB_DOC    +"'"
		cQuery +=   " AND DB_SERIE   = '"+ SDB->DB_SERIE  +"'"
		cQuery +=   " AND DB_SERVIC  = '"+ SDB->DB_SERVIC +"'"
		cQuery +=   " AND DB_TAREFA  = '"+ SDB->DB_TAREFA +"'"
		cQuery +=   " AND DB_ATIVID  = '"+ SDB->DB_ATIVID +"'"
		cQuery +=   " AND DB_PRODUTO IN ("+ cCodPrd +")"
		cQuery +=   " AND DB_ORIGEM  = 'SD1' "
		cQuery +=   " AND DB_STATUS IN ('"+ cStatInte +"','"+ cStatAExe +"')"
		cQuery +=   " AND (DB_RECHUM = '"+ __cUserID +"' OR DB_RECHUM = '"+ cRecHVazio +"')"
		cQuery +=   " AND ("
		cQuery +=   "   SELECT DB_ANOMAL FROM "+ RetSqlName('SDB')
		cQuery +=   "   WHERE DB_FILIAL  = '"+ xFilial("SDB") +"'"
		cQuery +=   "   AND DB_ESTORNO = ' '"
		cQuery +=   "   AND DB_ATUEST  = 'N'"
		cQuery +=   "   AND DB_DOC     = '"+ SDB->DB_DOC    +"'"
		cQuery +=   "   AND DB_SERIE   = '"+ SDB->DB_SERIE  +"'"
		cQuery +=   "   AND DB_SERVIC  = '"+ SDB->DB_SERVIC +"'"
		cQuery +=   "   AND DB_TAREFA  = '003'"
		cQuery +=   "   AND DB_ATIVID  = '022'"
		cQuery +=   "   AND DB_PRODUTO IN ("+ cCodPrd +")"
		cQuery +=   "   AND DB_ORIGEM  = 'SD1'"
		cQuery +=   "   AND ROWNUM     = 1 "
		cQuery +=   " ) <> 'S'"
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		cQuery +=   " AND ROWNUM = 1 "
		cQuery +=   " ORDER BY DB_ESTDES DESC"
		cQuery := ChangeQuery(cQuery)
	
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),(cAliasQry:=GetNextAlias()),.F.,.T.)
	
		If !(cAliasQry)->( Eof() )
			
			// Se o produto lido corresponde ao SDB posicionado, não preciso alterar nada
			If (cAliasQry)->R_E_C_N_O_ == SDB->( Recno() )
				(cAliasQry)->( dbCloseArea() )
				Return _lRet
			EndIf
			
			// Alterações no SDB corrente
			RecLock("SDB",.F.)
				SDB->DB_RECHUM := cRecHVazio // Libero o recurso humano do SDB corrente
				SDB->DB_STATUS := SuperGetMV('MV_RFSTAEX', .F., '4') // Altero o status para "A Executar"
			SDB->( MsUnLock() )
			
			SDB->( dbGoTo( (cAliasQry)->R_E_C_N_O_ ) ) // Reposiciono o SDB
			
			// Alterações no SDB reposicionado
			RecLock("SDB",.F.)
				SDB->DB_RECHUM := __cUserID
				SDB->DB_STATUS := SuperGetMV('MV_RFSTINT', .F., '3') // Altero o status para "Em Execução"
			SDB->( MsUnLock() )
		Else
			_lRet := .F.
			DLVTAviso("_Produto_","Produto lido não consta no documento ou tem divergência!")
			VTKeyBoard( Chr(20) )
		EndIf
		(cAliasQry)->( dbCloseArea() )
	
	EndIf

Return _lRet