#INCLUDE "FWMBrowse.ch"

/*
Jean Rehermann - Solutio IT - 02/01/2018
Ponto de entrada executado no acesso � rotina Monitor de Servi�os (WMSA331) e tem como objetivo 
permitir manipula��o das op��es do menu A��es Relacionadas. Permite tanto a inclus�o como a exclus�o de op��es.
*/

User Function WM331MNU()

	// Permite remover a condi��o de anomalia de um movimento com diverg�ncia de recebimento
	ADD OPTION aRotina TITLE "Lib. Anomalia" ACTION "U_RetAnoma()" OPERATION 2 ACCESS 0

Return Nil