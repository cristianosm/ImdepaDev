#INCLUDE "FWMBrowse.ch"

/*
Jean Rehermann - Solutio IT - 02/01/2018
Ponto de entrada executado no acesso à rotina Monitor de Serviços (WMSA331) e tem como objetivo 
permitir manipulação das opções do menu Ações Relacionadas. Permite tanto a inclusão como a exclusão de opções.
*/

User Function WM331MNU()

	// Permite remover a condição de anomalia de um movimento com divergência de recebimento
	ADD OPTION aRotina TITLE "Lib. Anomalia" ACTION "U_RetAnoma()" OPERATION 2 ACCESS 0

Return Nil