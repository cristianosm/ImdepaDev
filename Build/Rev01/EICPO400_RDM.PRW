#INCLUDE "RWMAKE.ch"
#INCLUDE "TOPCONN.CH"

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: EICPO400 ()
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 25 de Agosto de 2010, 15:37
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 10
//|Descricao.: Ponto de entrada Utilizado durante a rotina de manutenção do Purchase Order.
//|Observação:
//------------------------------------------------------------------------------------//
*----------------------------------------------*
User Function EICPO400()
*----------------------------------------------*

Local cSql := ""
Static cxTabPre
Static lxPassou

Do Case

	Case ParamIxb == "INCLUIR" .OR. ParamIxb == "ANTES_ALTERA_TELA_PO" .OR. ParamIxb == "BROWSE_VISUALIZAR" .OR. ParamIxb == "BROWSE_ESTORNO"
		lxPassou := .F.

	Case ParamIxb == "ANTES_GRAVA_PO"
		cxTabPre := M->W2_TAB_PC
		lxPassou := .T.

	Case ParamIxb == "APOS_GET_SI"
		VeriTabPre()
		DelPRPedido()

	Case ParamIxb == "DEPOIS_GRAVA_ALT_PO"
		VeriTabPre()
		DelPRPedido()

	Case ParamIxb == "DEPOIS_GRAVA_INC_PO" .OR. ParamIxb == "DEPOIS_GRAVA_ALT_PO"
		DelPRPedido()

EndCase

 /*
 ----------------------------------------------------------------------------------------
 |Permite desmarcar o Item do Purchase Order - Edivaldo Goncalves Cordeiro - 21/03/2011  |
 ----------------------------------------------------------------------------------------
 */

If ParamIxb == "INICIA_TE_3"
 lPermiteDesm:= .T.
EndIf


Return

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: EICPO02E()
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 25 de Agosto de 2010, 15:37
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 10
//|Descricao.: Ponto de entrada Pedido
//|Observação:
//------------------------------------------------------------------------------------//
*----------------------------------------------*
User Function EICPO02E()
*----------------------------------------------*

VeriTabPre()

Return .T.

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: VeriTabPre()
//|Descricao.: Verifica a Existencia da Tabela de pré-calculo
//|Observação:
//------------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function VeriTabPre()
*----------------------------------------------*

lxPassou := .T.

If Empty(M->W2_TAB_PC)
	SW2->(RecLock("SW2",.F.))
	SW2->W2_TAB_PC := ""
	SW2->(MsUnLock())
	cxTabPre := ""
Else
	cxTabPre := M->W2_TAB_PC
EndIf

Return .T.

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: DelPRPedido()
//|Descricao.: Deleta Previsões caso a tabela de Pré-calculo esteja vazia.
//|Observação:
//------------------------------------------------------------------------------------//
*----------------------------------------------*
Static Function DelPRPedido()
*----------------------------------------------*

//Alert("Static Function DelPRPedido")

If Empty(Alltrim(cxTabPre)) .AND. lxPassou
	cSql := " SELECT R_E_C_N_O_ AS REC FROM "+RetSqlName("SE2")
	cSql += " WHERE D_E_L_E_T_ <> '*' AND E2_FILIAL = '"+xFilial("SE2")+"' "
	cSql += " 	AND E2_PREFIXO = 'EIC' AND E2_TIPO = 'PR' AND E2_NUM = '"+Alltrim(SW2->W2_PO_NUM)+"' "
	IIf(Select("XXXZ") # 0,XXXZ->(dbCloseArea()),.T.)
	TcQuery cSql New Alias "XXXZ"
	XXXZ->(dbSelectArea("XXXZ"))
	XXXZ->(dbGoTop())

	If XXXZ->(EOF()) .AND. XXXZ->(BOF())
		XXXZ->(dbCloseArea())
	Else
		XXXZ->(dbGoTop())
		While XXXZ->(!EOF())
			SE2->(dbGoTo(XXXZ->REC))
			SE2->(RecLock("SE2",.F.))
			SE2->(dbDelete())
			SE2->(MsUnLock())
			XXXZ->(dbSkip())
		EndDo
		XXXZ->(dbCloseArea())
	EndIf

	SW2->(RecLock("SW2",.F.))
	SW2->W2_TAB_PC := ""
	SW2->(MsUnLock())
EndIf


cSql := " DELETE "+RetSqlName('SE2')
cSql += " WHERE E2_FILIAL= '" + xFilial( 'SE2' ) + "'"
//cSql += " AND E2_NUM = '"+Alltrim(SW2->W2_PO_NUM)+"'"
cSql += " AND E2_NUM = '"+SE2->E2_NUM+"'"
cSql += " AND E2_PREFIXO = 'EIC'"
cSql += " AND E2_TIPO IN('PRE','INV','NF','PR')
cSql += " AND D_E_L_E_T_='*'"


Return