#INCLUDE "PROTHEUS.CH"
/*
Ponto de entrada MTA103MNU
Serve para adicionar um item no menu de A��es Relacionadas na rotina de Documento de Entrada (MATA103)
*/
User Function MTA103MNU
	aAdd( aRotina, { "Etiquetas Receb.", "U_ETIQUETAS", 0 , 2, 0, .F.} )
Return