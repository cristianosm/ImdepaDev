#INCLUDE "TOTVS.CH"

//| Validacao de Usuario  no Momento de Digitar a Parcela....SE2->E2_PARCELA
//| Criado em Razao de no P11 a Func�o padrao �


User Function ValParcela()

Local aArea	:= GetArea()
Local aSe2Area	:= {}
Local lReturn	:= .T.

DbSelectArea("SE2")

aSe2Area := SE2->(GetArea())

//If ExistChav("SE2", xFilial("SE2")+M->E2_PREFIXO+M->E2_NUM+M->E2_PARCELA,1,)
If DbSeek(xFilial("SE2")+M->E2_PREFIXO+M->E2_NUM+M->E2_PARCELA,.F.)

	lReturn := .F.

EndIf



If !lReturn
	Iw_MsgBox("Este T�tulo j� Existe no Contas a Pagar.. "+( CHR(10)+CHR(13) )+M->E2_PREFIXO+"-"+M->E2_NUM+"."+M->E2_PARCELA+" ","Aten��o","ALERT")

EndIf


RestArea(aSe2Area)
RestArea(aArea)

Return(lReturn)