#INCLUDE "PROTHEUS.CH"
/*
Jean Rehermann - Solutio IT - 28/03/2018 - Ponto de entrada para confirmar execução da rotina de Refaz Saldos
Estou utilizando este ponto para recarregar as variaveis mv_par do pergunte do grupo MTA300
*/
User Function MA300OK()

	Local _lRet := .T.
	
	// Se estiver executando do programa de habilitar estorno de execucao de servico wms
	If IsInCallStack("U_HABESTOR")
		
		// Grupo de perguntas "espelho" utilizado
		_sGrupo := PadR( "HABESTOR", Len( SX1->X1_GRUPO ) )
		
		// Percorre as 8 perguntas do grupo
		For _nK := 1 To 8
		
			// Posiciona no SX1 pois la as perguntas ja foram atualizadas pelo programa HABESTOR
			If SX1->( dbSeek( _sGrupo + StrZero( _nK, 2 ), .F. ) )
			    
				// Atualiza o conteudo das privates mv_par de perguntas conforme conteudo do SX1
				&("mv_par" + StrZero( _nK, 2 ) ) := Iif( SX1->X1_TIPO == "N", Val( SX1->X1_CNT01 ), SubStr( SX1->X1_CNT01, 1, SX1->X1_TAMANHO ) )
				
			EndIf

		Next
		
	EndIf

Return( _lRet )