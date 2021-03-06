#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"

/*
Jean Rehermann - Solutio IT - 10/07/2017
Ponto de entrada na valida��o do endere�o, na rotina DLGV080 (endere�amento) da convoca��o (DLGV001)
Est� sendo usado para permitir a altera��o do endere�o sugerido pelo sistema no endere�amento
PARAMIXB[1] = End.Digitado | PARAMIXB[2] = End.Sugerido | PARAMIXB[3] = 1) End.Origem 2) End.Destino 3) Unitizador
*/
User Function DLV080VL()

	Local _cDigi := PARAMIXB[1]
	Local _cSist := PARAMIXB[2]
	Local _nTipo := PARAMIXB[3]
	Local _lRet  := ( _cDigi == _cSist )
	
	Local nCapEnder := 0 // Capacidade do endere�o
	Local nSaldoSBF := 0
	Local nSaldoRF  := 0
	Local nSaldoEnd := 0
	Local cEstDest  := ""
	
	If _nTipo == 2 // S� valida o endere�o de destino
		If !_lRet .And. IsInCallStack("U_DLV080OPC")// Apenas continua quando o endere�o for diferente e vier do CTRL+J
			// Valida o endere�o
			_lRet := WMSVldDest(SDB->DB_PRODUTO, SDB->DB_LOCAL,_cDigi,Nil,Nil,'',0)			

			If _lRet
				RecLock("SDB",.F.)
					SDB->DB_ENDDES := _cDigi // Endere�o destino alterado
				SDB->( MsUnLock() )
			EndIf
		EndIf
	Else
		If !_lRet
			If _nTipo == 1
				DLVTAviso("DLGV08017","Endereco Origem "+ AllTrim( _cDigi ) +" incorreto.")
			ElseIf _nTipo == 3
				DLVTAviso("DLGV08017","Unitizador "+ AllTrim( _cDigi ) +" incorreto.")
			EndIf
			VTKeyBoard( CHR(20) )
		EndIf
	EndIf

Return _lRet