#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APVT100.CH"

/*
Jean Rehermann - SOLUTIO IT - 06/09/2017
Ponto de entrada DLVENDER na validação da seleção do endereço
Na confirmação do endereço de destino (MESA DE CONFERÊNCIA) permite alterar o endereço.
*/
User Function DLVENDER()

	Local _cEndCon := PARAMIXB[ 1 ] // Confirmação do endereço
	Local _cEndDes := PARAMIXB[ 2 ] // Endereço sugerido
	Local _nOpc    := 0
	Local _lRet    := AllTrim( _cEndCon ) == Alltrim( _cEndDes )
	Local _lDest   := IsInCallStack("DLV030End") // Apenas quando a leitura do endereço for para o destino
	Local _cQuery  := ""
	Local _cAlias  := ""
	Local aAreaAtu := GetArea()
	Local aAreaSDB := SDB->( GetArea() )
	
	If _lDest .And. !_lRet

		_nOpc := DLVTAviso('ALTERA DESTINO','Deseja alterar o endereço destino?', {"Sim","Nao"})

		If _nOpc == 1
			
			_lRet := DesVlEnd( _cEndCon )
			
			If _lRet

				_cQuery := "SELECT R_E_C_N_O_ "
				_cQuery += " FROM "+ RetSqlName("SDB")
				_cQuery += " WHERE DB_FILIAL  = '"+ xFilial("SDB") +"'"
				_cQuery += "   AND DB_DOC     = '"+ SDB->DB_DOC     +"' "
				_cQuery += "   AND DB_CLIFOR  = '"+ SDB->DB_CLIFOR  +"' "
				_cQuery += "   AND DB_LOJA    = '"+ SDB->DB_LOJA    +"' "
				_cQuery += "   AND DB_SERVIC  = '"+ SDB->DB_SERVIC  +"' "
				_cQuery += "   AND DB_TAREFA  = '002' "
				_cQuery += "   AND DB_ATIVID  = '015' "
				_cQuery += "   AND DB_ORIGEM  = 'SC9'"
				_cQuery += "   AND DB_ESTORNO = ' '"
				_cQuery += "   AND D_E_L_E_T_ = ' '"
				
				TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
				
				While !(_cAlias)->( Eof() )
			
					SDB->( dbGoTo( (_cAlias)->R_E_C_N_O_ ) )
					SDB->( RecLock("SDB",.F.) )
					SDB->( SDB->DB_ENDDES := _cEndCon )
					SDB->( MsUnLock() )
					AtuDBCnf( _cEndCon, _cEndDes ) // Atualiza o registro de conferência
			
					(_cAlias)->( dbSkip() )
				End
				
				(_cAlias)->( dbCloseArea() )
			
				RestArea( aAreaSDB )
				RestArea( aAreaAtu )

			EndIf
			
		EndIf
    
    EndIf

Return _lRet

// Valida o endereço informado
Static Function DesVlEnd( cEndereco )

	Local aAreaAnt     := GetArea()
	Local lRet         := .T.
	Default cEndereco  := ''
	
	lRet := ExistCpo( 'SBE', SDB->DB_LOCAL + cEndereco )
	
	RestArea(aAreaAnt)

Return lRet

// Atualiza o registro de conferência referente ao apanhe
Static Function AtuDBCnf( cNewEnd, cOldEnd )

	Local _cQuery  := ""
	Local _cAlias  := ""
	Local aAreaAtu := GetArea()
	Local aAreaSDB := SDB->( GetArea() )
	
	_cQuery := "SELECT R_E_C_N_O_ "
	_cQuery += " FROM "+ RetSqlName("SDB")
	_cQuery += " WHERE DB_FILIAL  = '"+ xFilial("SDB") +"'"
	_cQuery += "   AND DB_ITEM    = '"+ SDB->DB_ITEM    +"' "
	_cQuery += "   AND DB_PRODUTO = '"+ SDB->DB_PRODUTO +"' "
	_cQuery += "   AND DB_LOCAL   = '"+ SDB->DB_LOCAL   +"' "
	_cQuery += "   AND DB_DOC     = '"+ SDB->DB_DOC     +"' "
	_cQuery += "   AND DB_SERIE   = '"+ SDB->DB_SERIE   +"' "
	_cQuery += "   AND DB_SERVIC  = '"+ SDB->DB_SERVIC  +"' "
	_cQuery += "   AND DB_IDDCF   = '"+ SDB->DB_IDDCF   +"' "
	_cQuery += "   AND DB_LOCALIZ = '"+ cOldEnd    +"' "
	_cQuery += "   AND DB_TAREFA  = '003' "
	_cQuery += "   AND DB_ATIVID  = '022' "
	_cQuery += "   AND DB_ORIGEM  = 'SC9'"
	_cQuery += "   AND DB_ESTORNO = ' '"
	_cQuery += "   AND D_E_L_E_T_ = ' '"
	
	TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )
	
	While !(_cAlias)->( Eof() )

		SDB->( dbGoTo( (_cAlias)->R_E_C_N_O_ ) )
		SDB->( RecLock("SDB",.F.) )
		SDB->( SDB->DB_LOCALIZ := cNewEnd )
		SDB->( MsUnLock() )

		(_cAlias)->( dbSkip() )
	End
	
	(_cAlias)->( dbCloseArea() )

	RestArea( aAreaSDB )
	RestArea( aAreaAtu )
	
Return