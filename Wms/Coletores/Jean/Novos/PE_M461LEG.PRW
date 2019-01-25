#INCLUDE "PROTHEUS.CH"
/*
Jean Rehermann - Solutio IT - 26/01/2018
Ponto de entrada para alterar as cores da legenda da tela de faturamento (Documento de saída - Mata460/Mata461)
*/
User Function M461LEG()

	Local _aCores := PARAMIXB
	
	aAdd( _aCores, {"BR_AMARELO","Pedido Aguardando Pallet"} )
	
Return( _aCores )