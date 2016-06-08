#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Write_OrcOfert  ³ Autor ³ Edivaldo/ Márcio³ Data ³ 06/08/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Registro de quantidade ofertada e venda perdida              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data Atu. ³ Descricao                                                    ³±±
±±³          ³                                                              ³±±
±±³11/12/06  ³ Adicionado parametro nLinha pois durante a Atualização da    ³±±
±±³          ³ data e hora considerava a linha n e não a linha que estava   ³±±
±±³          ³ sendo alterada                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ESPECIFICO PARA O CLIENTE IMDEPA						        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
**********************************************************************
User Function Write_OrcOfert(nLinha,cCodFil,cNumOrc,cProd,nQtdConsult,nPrcAcre,nSeqId,dDtNeCl,cHrNeCl)
**********************************************************************

Local cSql  		:= ''
Local nSeqId
Local nSomatorio	:= nQtdConsult

Private nPosSeqID 	:= GdFieldPos('UB_SEQID')
Private nPosQtd   	:= GdFieldPos('UB_QUANT')
Private nPosProd    := GdFieldPos('UB_PRODUTO')

// Adaptacao para colocar novo modelo em PRODUCAO...
If ( ValType(nLinha) == "C" )
	Return(.T.)
ElseIf ( ValType(nLinha) == "U" )
	Return(aCols[N][nPosSeqID])
EndIf

nSeqId := GeraSeqID(cCodFil,cNumOrc,cProd,nQtdConsult,nPrcAcre,nSeqId,dDtNeCl,cHrNeCl)

_lAltOrc:=.T. //Libera o orçamento para reimpressao

Return(nSeqId)
**********************************************************************
Static Function GeraSeqID(cCodFil,cNumOrc,cProd,nQtdConsult,nPrcAcre,nSeqId,dDtNeCl,cHrNeCl)
**********************************************************************
Local aTamSX3:= TamSX3("ZA0_SEQID")

If Select( "TRB_MAX" ) <> 0
	dbSelectArea("TRB_MAX")
	TRB_MAX->(DbCLoseArea())
Endif

cSql :=" SELECT MAX(ZA0_SEQID)MaxID FROM  "
cSql += RetSqlName( "ZA0" )+ " ZA0 "
cSql +=" WHERE "
cSql +=" ZA0_FILIAL='"+cCodFil+"'"
cSql +=" AND ZA0_NUMORC = '"+ cNumOrc + "'"
cSql +=" AND ZA0.D_E_L_E_T_ <> '*'"

U_ExecMySql( cSql , "TRB_MAX" , "Q" )//| Parametros:(cSql:Texto Sql, cAlias:Alias a ser usado no caso de Query, lModo: "E"-Execucao ou "Q"-Query)   Obs.: Execucao(Drop, Update, Delete, etc..   Retorno: No modo Execucao retorna o Status caracter, em modo Query não tem retorno.

nSeqId := TRB_MAX->MaxID + 1

DbCloseArea()

ProcRegua(1)

While  !MayIUseCode("ZA0"+cCodFil+cNumOrc+STRZERO(nSeqId,aTamSX3[1]))
	nSeqId++
EndDo

DbSelectArea("ZA0");DbSetOrder(3)//| Filial + NumOrc + Produto
nSomatorio := 0

If DbSeek(xFilial("ZA0")+cNumOrc+cProd,.F.)

	For i := 1 To Len(aCols)
		If !GDDeleted(i) .and. acols[i,nPosProd] == cProd
			nSomatorio += acols[i,nPosQtd]
		EndIf
	Next

	Atu_Consultado(cCodFil,cNumOrc,cProd,nSomatorio,nSeqId,dDtNeCl,cHrNeCl)

Else

	Begin Transaction

	RecLock("ZA0",.T.)
	ZA0->ZA0_FILIAL := cCodFil
	ZA0->ZA0_NUMORC := cNumOrc
	ZA0->ZA0_PRODUT := cProd
	ZA0->ZA0_SEQID  := nSeqId
	ZA0->ZA0_QUANTD := nQtdConsult
	ZA0->ZA0_DTNECL := dDtNeCl
	ZA0->ZA0_HRNECL := cHrNeCl
	ZA0->ZA0_PRECO  := nPrcAcre
	// Jorge Oliveira - 11/02/2011 - Grava o Cliente e Loja
	ZA0->ZA0_CLIENT := M->UA_CLIENTE
	ZA0->ZA0_LOJACL := M->UA_LOJA
	ZA0->(MsUnlock())

	End Transaction

Endif

IncProc()

Return(nSeqId)
**********************************************************************
Static Function Atu_Consultado(cCodFil,cNumOrc,cProd,nSomatorio,nSeqId,dDtNeCl,cHrNeCl)
**********************************************************************
Local aTamSX3:= TamSX3("ZA0_SEQID")

DbSelectArea("ZA0")

Begin Transaction

RecLock("ZA0",.F.)
If nSomatorio > ZA0->ZA0_QUANTD
	ZA0->ZA0_QUANTD := nSomatorio
EndIf

ZA0->ZA0_DTNECL	:= dDtNeCl
ZA0->ZA0_HRNECL	:= cHrNeCl

//| Limpa dados para poder ser reprocessado pelo workflow
ZA0->ZA0_VOFERT	:=  0
ZA0->ZA0_QOFERT	:=  0
ZA0->ZA0_FLAGOF	:= " "
ZA0->ZA0_DTOFER	:= CTOD(" ")
ZA0->ZA0_HROFER	:= SPACE(LEN(ZA0->ZA0_HROFER))
// Jorge Oliveira - 11/02/2011 - Grava o Cliente e Loja
ZA0->ZA0_CLIENT   := M->UA_CLIENTE
ZA0->ZA0_LOJACL   := M->UA_LOJA
ZA0->(MsUnlock())

End Transaction

Return()