#INCLUDE "PROTHEUS.CH"
/*
Jean Rehermann - Solutio IT - 17/10/2017
Ponto de Entrada DL150OEX (Ordem dos registros no browse de execução de serviços DLGA150)
*/
User Function DL150OEX()

	Local _cOrdem := "DCF_DOCTO, DCF_SERIE"
	
Return( _cOrdem )