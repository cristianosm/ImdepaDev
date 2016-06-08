#include "TOTVS.CH"




User Function Teste_Classes()

/*
	DbSelectarea("SA1");DbSetOrder(1)
	DbSelectarea("SB1");DbSetOrder(1)
	DbSelectarea("SC5");DbSetOrder(1)
	DbSelectarea("SC6");DbSetOrder(1)
	DbSelectarea("SF2");DbSetOrder(3)//(1) - F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO+
	DbSelectarea("SD2");DbSetOrder(3)//(3) - D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	SC5->( DbSeek(xFilial("SC5")+"328795", .F. ) )
	SC6->( DbSeek(xFilial("SC6")+"328795", .F. ) )

	SA1->( DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, .F. ) )
	SB1->( DbSeek(xFilial("SB1")+SC6->C6_PRODUTO, .F. ) )


	SF2->( DbSeek(xFilial("SF2")+SC5->C5_NOTA+SC5->C5_SERIE+SC5->C5_CLIENTE+SC5->C5_LOJACLI, .F. ) )
	SD2->( DbSeek(xFilial("SD2")+SC5->C5_NOTA+SC5->C5_SERIE+SC5->C5_CLIENTE+SC5->C5_LOJACLI+SC6->C6_PRODUTO, .F. ) )

*/
	oPedido := oPedido():New( SC5->C5_NUM )

	oPedido:Add_Produto()

	For n := 1 To 1
		oPedido:Calc_Custos(n)
	Next

	Alert("FIM")


Return()