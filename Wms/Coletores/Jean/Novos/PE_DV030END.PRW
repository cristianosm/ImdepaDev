#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*
Jean Rehermann - Solutio IT - 19/04/2018
Vou utilizar para avisar o operador que um apanhe petence a um pedido estornado.
Este ponto é exatamente antes de o programa alimentar o array aColetor com os itens a serem endereçados fisicamente (estoque)
*/

User Function DV030END()

    Local cIdAnt   := ""
	Local _cQuery  := ""
	Local _cAlias  := ""
	Local _cMesaX  := ""
    Local _aArSDB1 := {}

	If SDB->DB_SERVIC == '001' .And. SDB->DB_TAREFA == '002' .And. SDB->DB_ATIVID == '015' .And. 'MESA' $ SDB->DB_ENDDES .And. SDB->DB_ORIGEM = 'SC9'

		_aArSDB1 := SDB->( GetArea() )
		cIdAnt := U_GetIdAnt( { SDB->DB_DOC, SDB->DB_CLIFOR, SDB->DB_LOJA, SDB->DB_PRODUTO, Nil, SDB->DB_IDDCF }, .T. ) 
		RestArea( _aArSDB1 )
			
		// Jean Rehermann - Solutio IT - Mensagem no apanhe direto (sem reabastecimento)
		If 'ESTORNADO' $ cIdAnt
			DLVTAviso('PEDIDO COM ESTORNO',"Na mesa "+ AllTrim( SDB->DB_ENDDES ) +" procure pelo pedido "+ AllTrim( SDB->DB_DOC ) )
		
		Else

			aAreaSDB := SDB->( GetArea() )
	
			_cQuery := "SELECT DISTINCT(DB_ENDDES) MESA "
			_cQuery += " FROM "+ RetSqlName("SDB")
			_cQuery += " WHERE DB_FILIAL  = '"+ SDB->DB_FILIAL  +"'"
			_cQuery += "   AND DB_ORIGEM  = 'SC9' " // Originado de pedido de venda
			_cQuery += "   AND DB_SERVIC  = '001'"
			_cQuery += "   AND DB_TAREFA  = '002'"
			_cQuery += "   AND DB_ATIVID  = '015'"
			_cQuery += "   AND DB_STATUS  = '1' " // Apenas itens finalizados (na mesa)
			_cQuery += "   AND R_E_C_N_O_ <> '"+ cValToChar( SDB->( Recno() ) ) +"' " // Somente itens diferentes do que estou separando
			_cQuery += "   AND DB_DOC     = '"+ SDB->DB_DOC    +"' "
			_cQuery += "   AND DB_CLIFOR  = '"+ SDB->DB_CLIFOR +"' "
			_cQuery += "   AND DB_LOJA    = '"+ SDB->DB_LOJA   +"' "
			_cQuery += "   AND DB_ENDDES LIKE 'MESA%' " // Endereço destino precisa ser uma mesa
			_cQuery += "   AND D_E_L_E_T_ = ' '"
		
			TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
			(_cAlias)->( dbGoTop() )
			If !(_cAlias)->( Eof() )
				_cMesaX := (_cAlias)->MESA
			EndIf
			(_cAlias)->( dbCloseArea() )

			If !Empty( _cMesaX )
				DLVTAviso('PEDIDO JA INICIADO',"Na mesa "+ AllTrim( _cMesaX ) +" procure pelo pedido "+ AllTrim( SDB->DB_DOC ) )
			EndIf

			RestArea( aAreaSDB )

		EndIf
		
	EndIf

Return( Nil )