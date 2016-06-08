#INCLUDE "TOTVS.CH"

//| Validacao de Usuario  no Momento de Digitar a Parcela....SE2->E2_PARCELA
//| Criado em Razao de no P11 a Funcão padrao ã

*******************************************************************************
User Function ValParcela()
*******************************************************************************

	Local aArea	:= GetArea()
	Local aSe2Area	:= {}
	Local lReturn	:= .T.

	aSe2Area := SE2->(GetArea())

	DbSelectArea("SE2")
	DbSetOrder(1) //	E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

	If DbSeek(xFilial("SE2")+M->E2_PREFIXO+M->E2_NUM+M->E2_PARCELA+M->E2_TIPO,.F.)

		lReturn := .F.

	EndIf

	If !lReturn
		Iw_MsgBox("Este Título já Existe no Contas a Pagar.. "+( CHR(10)+CHR(13) )+M->E2_PREFIXO+"-"+M->E2_NUM+"-"+M->E2_TIPO+"."+M->E2_PARCELA+"...","Atenção","ALERT")

	EndIf


	RestArea(aSe2Area)
	RestArea(aArea)

Return(lReturn)