#INCLUDE "PROTHEUS.CH"
#INCLUDE 'APVT100.CH'

/*
Jean Rehermann - Solutio It - 10/07/2017
Ponto de entrada na rotina de endereçamento do coletor
Serve para informar a descrição do produto
*/
User Function DV080SCR()

	Local nMax     := VTMaxCol()
	Local cDescPro := Space( nMax )
	Local cDescPr1 := Space( nMax )
	Local cDescPr2 := Space( nMax )
	Local cDescPr3 := Space( nMax )
	Local lWmsLote := SuperGetMV('MV_WMSLOTE',.F.,.F.)

	// Caso tenha lote, este espaço da tela será ocupado e não posso exibir a descrição	
	If !( lWmsLote .And. Rastro(SDB->DB_PRODUTO) )
		
		cDescPro := Posicione("SB1",1,xFilial("SB1")+SDB->DB_PRODUTO,"B1_DESC")
		cDescPr1 := SubStr( cDescPro,            1, nMax )
		cDescPr2 := SubStr( cDescPro,     nMax + 1, nMax )
		cDescPr3 := SubStr( cDescPro, 2 * nMax + 1, nMax )
	
		@ 03,00 VTGet cDescPr1 When .F.
		@ 04,00 VTGet cDescPr2 When .F.
		@ 05,00 VTGet cDescPr3 When .F.

	Endif
	
Return