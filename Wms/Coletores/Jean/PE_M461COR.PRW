#INCLUDE "PROTHEUS.CH"
/*
Jean Rehermann - Solutio IT - 26/01/2018
Ponto de entrada para alterar as cores da legenda da tela de faturamento (Documento de saída - Mata460/Mata461)
*/
User Function M461COR()

	Local _aCores := PARAMIXB
	Local _aRet   := {}
	
	aAdd( _aRet, {'SC9->C9_AGREG=="PALL"','BR_AMARELO'} )
	
	For _nX := 1 To Len( _aCores )
		aAdd( _aRet, _aCores[ _nX ] )
	Next
	
Return( _aRet )