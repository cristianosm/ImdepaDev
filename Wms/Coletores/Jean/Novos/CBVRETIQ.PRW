#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#DEFINE CRLF ( CHR(13) + CHR(10) )

/*
Jean Rehermann - Solutio IT - 04/04/2017
CBVRETIQ - Valida se a etiqueta já foi lida dentro desta transação de conferência.
*/

User Function CBVRETIQ()

	Local _cNomeArq := ""
	Local _lExiste  := .F.
	Local _cLinha   := ""
	Local _nHandle  := 0
	
	If IsInCallStack("WMSV073")
		_cNomeArq := "cb0w073"+ AllTrim( SubStr( cUsuario, 7, 15 ) ) +".txt"
	ElseIf ( IsInCallStack("DLGV080") .Or. IsInCallStack("WMSV080") ) .And. !IsInCallStack("U_DV080INI")
		_cNomeArq := "cb0w080"+ AllTrim( SubStr( cUsuario, 7, 15 ) ) +".txt"
	ElseIf IsInCallStack("DLGV030") .Or. IsInCallStack("WMSV030")
		_cNomeArq := "cb0w030"+ AllTrim( SubStr( cUsuario, 7, 15 ) ) +".txt"
	EndIf

	If !Empty( _cNomeArq )
	
		If File( _cNomeArq )
		
			_nHandle := FT_FUSE( _cNomeArq ) // Abro o arquivo para leitura
			FT_FGOTOP() // Posiciono no início da primeira linha do arquivo
			
			Do While !FT_FEOF()
				
				_cLinha := Ft_FReadLn()
				_lExiste := _cID $ _cLinha
				
				If _lExiste
					Exit
				EndIf
				
				FT_FSKIP()
			EndDo
			
			FT_FUse()
			
			If _lExiste
				VTAlert("P.E.CBVRETIQ - Etiqueta ja foi lida.","Aviso",.T.,2000 )
			Else
				_nHandle := FOPEN( _cNomeArq, FO_READWRITE + FO_EXCLUSIVE )
				FSEEK( _nHandle, 0, FS_END)
				FWRITE( _nHandle, _cID + CRLF )
				FCLOSE( _nHandle )
				
				// Jean Rehermann - Solutio IT - 08/08/2017 - Verifica se leitura foi feita no endereçamento e armazena o ID do movimento do SDB
				If IsInCallStack("DLGV080") .And. !IsInCallStack("U_DV080INI") .And. CB0->CB0_CODPRO == SDB->DB_PRODUTO .And. AllTrim( CB0->CB0_LOCALI ) == "DOCA"
					RecLock("CB0",.F.)
						CB0->CB0_IDMVTO := SDB->DB_IDMOVTO
					CB0->( MsUnLock() )
				EndIf
			EndIf
		
		Else
			VTAlert("P.E.CBVRETIQ - Erro ao acessar o arquivo","Aviso",.T.,2000 )
		EndIf
		
	Endif

Return( !_lExiste )