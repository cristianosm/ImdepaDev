#INCLUDE "PROTHEUS.CH"
/*
Ponto de entrada MTA140MNU
Serve para adicionar um item no menu de A��es Relacionadas na rotina de Pr� Documento de Entrada (MATA140)
*/
User Function MTA140MNU
	aAdd( aRotina, { "Etiquetas Receb.", "U_ETIQUETAS", 0 , 2, 0, .F.} )
Return