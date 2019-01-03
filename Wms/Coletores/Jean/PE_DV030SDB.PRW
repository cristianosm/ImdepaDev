#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*
Jean Rehermann - Solutio IT - 22/03/2018
Este Ponto de Entrada permite gravar campos específicos na tabela de atividades RF (SDB) no final da execução da atividade de separação.
Usado para gravar o flag de apanhe no campo customizado DB_ESTFLAG utilizado no estorno para calcular a quantidade física movimentada
Usado para atualizar o SDB de apanhe com aguarde de reabastecimento, após abastecer libera para convocação
*/
User Function DV030SDB()

	If SDB->DB_QTDLID > 0 .And. SDB->DB_STATUS == '1' .And. SDB->DB_ORIGEM == "SC9" .And. SDB->DB_SERVIC == "001" .And. SDB->DB_ATIVID == "015"
		RecLock("SDB", .F.)
			SDB->DB_ESTFLAG := "GAP"
		MsUnLock()
	EndIf

	If SDB->DB_QTDLID > 0 .And. SDB->DB_STATUS == '1' .And. SDB->DB_ORIGEM == "DCF" .And. SDB->DB_SERVIC == "005" .And. SDB->DB_ATIVID == "009"

		aAreaDCF := DCF->( GetArea() )
		aAreaSDB := SDB->( GetArea() )
		
		DCF->( dbSetOrder(2) )
		If DCF->( dbSeek( SDB->DB_FILIAL+SDB->DB_SERVIC+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA+SDB->DB_PRODUTO ) )
			
			cQuery := "UPDATE "+ RetSqlName("SDB")
			cQuery += " SET DB_STATUS = '4', DB_ANOMAL = ' '  "
			cQuery += " WHERE DB_FILIAL  = '"+ xFilial("SDB")  +"'"
			cQuery += "   AND DB_PRODUTO = '"+ DCF->DCF_CODPRO +"' "
			cQuery += "   AND DB_LOCAL   = '"+ DCF->DCF_LOCAL  +"' "
			cQuery += "   AND DB_DOC     = '"+ DCF->DCF_DOCORI +"' "
			cQuery += "   AND DB_SERIE   = '"+ DCF->DCF_SERORI +"' "
			cQuery += "   AND DB_ORIGEM  = 'SC9' "
			cQuery += "   AND DB_STATUS  = '2' "
			cQuery += "   AND DB_ESTORNO = ' ' "
			cQuery += "   AND D_E_L_E_T_ = ' ' "
			
			TcSqlExec( cQuery )
			TcSqlExec( 'COMMIT' )
			
		EndIf
		
		RestArea( aAreaSDB )
		RestArea( aAreaDCF )
	EndIf
Return