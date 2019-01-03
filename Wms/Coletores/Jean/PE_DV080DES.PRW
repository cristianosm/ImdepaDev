#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*
Jean Rehermann - Solutio IT - 07/08/2017
Ponto de entrada na função FinalAtiv, que finaliza a atividade de endereçamento no DLGV080
Estou utilizando para atualizar o endereço das etiquetas de ID de logística lidas através do campo customizado CB0_IDMVTO
*/

User Function DV080DES()

	Local lRet := PARAMIXB[1]
	Local cSql := ""

	If lRet
		cSql := "UPDATE "+ RetSqlName("CB0")
		cSql += " SET CB0_LOCALI = '"+ SDB->DB_ENDDES +"', CB0_IDMVTO = ' '"
		cSql += " WHERE D_E_L_E_T_ = ' ' AND CB0_FILIAL = '"+ xFilial("CB0") +"'"
		cSql += " AND CB0_IDMVTO = '"+ SDB->DB_IDMOVTO +"' AND CB0_TIPO = '01'"
		cSql += " AND CB0_CODPRO = '"+ SDB->DB_PRODUTO +"' AND CB0_NFENT = '"+ SDB->DB_DOC +"' AND CB0_SERIEE = '"+ SDB->DB_SERIE +"' "
	
		TCSQLExec( cSql )
		TCSQLExec('COMMIT')
	EndIf

Return lRet