#INCLUDE "PROTHEUS.CH"
/*
Jean Rehermann - Solutio IT - 04/04/2017
CBRETETI - Ponto de entrada na leitura da etiqueta via RF
Armazena o ID da etiqueta em uma variável pública para utilização no ponto de entrada CBVRETIQ, que valida se a etiqueta
já foi lida dentro desta transação de conferência.
*/
User Function CBRETETI()

	Local _aRet     := {}
	If Type("_cID") == "U"
		Public _cID	:= AllTrim( PARAMIXB[1] )
	Else
		_cID := Iif( Len( AllTrim( PARAMIXB[1] ) ) == 10, AllTrim( PARAMIXB[1] ), Space(10) )
	EndIf
	
Return(_aRet)
