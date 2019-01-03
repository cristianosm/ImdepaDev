#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"
/*
Jean Rehermann - Solutio IT - 03/07/2017
DLGV001G - Ponto de entrada na convocação antes de selecionar a rotina
Utilizado para criar arquivo temporário de controle de leitura de etiquetas na conferência de entrada (WMSV073)
*/
User Function DLGV001G()

	Local _nHd1     := 0
	Local _cNomeArq := ""
	Local cFunExe   := Iif( Type("PARAMIXB")=="A" .And. Len(PARAMIXB) > 0, PARAMIXB[1], "" )
	Local cRechum   := SDB->DB_RECHUM
	
	If 'DLCONFENT' $ Upper(cFunExe)
		_cNomeArq := "cb0w073"+ AllTrim( SubStr( cUsuario, 7, 15 ) ) +".txt"
		VTSetKey( 12, {|| U_CleanID()}, "Limpa IDs")
	ElseIf 'DLENDERECA' $ Upper(cFunExe)
		_cNomeArq := "cb0w080"+ AllTrim( SubStr( cUsuario, 7, 15 ) ) +".txt"
	ElseIf 'DLAPANHE'  $ Upper(cFunExe)
		_cNomeArq := "cb0w030"+ AllTrim( SubStr( cUsuario, 7, 15 ) ) +".txt"
	EndIf
    
	If !Empty( _cNomeArq )

		_nHd1 := fCreate( _cNomeArq )

		If fError() != 0
			VTAlert("P.E.DLGV001G - Erro ao criar o arquivo de conferencia","Aviso",.T.,2000 )
			Return .F.
		EndIf       
	
		FClose( _nHd1 )

	EndIf

Return .T.

// Efetua a limpeza dos ids lidos na conferência de entrada, apagando o arquivo de conferência
User Function CleanID()

	Local _cNomeArq := ""
	Local _nHd1     := 0

	// Caso esteja na rotina de conferência de entrada, ativa a tecla para limpeza dos IDs
	If IsInCallStack("WMSV073")

		_cNomeArq := "cb0w073"+ AllTrim( SubStr( cUsuario, 7, 15 ) ) +".txt"
		
		If !Empty( _cNomeArq )
			If File( _cNomeArq )
				If FErase( _cNomeArq ) == -1
					VTAlert("Não foi possível eliminar o arquivo de controle!","Erro",.T.,2000 )
				Else
					_nHd1 := fCreate( _cNomeArq )
					FClose( _nHd1 )
					VTAlert("Limpeza de IDs OK!","Sucesso",.T.,2000 )
				EndIf
			Else
				VTAlert("Arquivo de controle não localizado!","Erro",.T.,2000 )
			EndIf
		EndIf
	Else
		VTAlert("Apenas disponível na rotina de conferência!","Erro",.T.,2000 )
	EndIf

Return