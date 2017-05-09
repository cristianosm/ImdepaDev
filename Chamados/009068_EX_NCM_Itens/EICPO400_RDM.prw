#INCLUDE "RWMAKE.ch"
#INCLUDE "TOPCONN.CH"
#include 'protheus.ch'
#include 'parmtype.ch'

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: EICPO400 ()
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 25 de Agosto de 2010, 15:37
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 10
//|Descricao.: Ponto de entrada Pedido
//|Observa**o:
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

		AddButons()

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

		RetButons()
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
	//|Observa**o:
	//------------------------------------------------------------------------------------//
	*----------------------------------------------*
User Function EICPO02E()
	*----------------------------------------------*

	VeriTabPre()

	Return .T.

	//+-----------------------------------------------------------------------------------//
	//|Empresa...: Imdepa
	//|Funcao....: VeriTabPre()
	//|Descricao.: Verifica a Existencia da Tabela de pr*-calculo
	//|Observa**o:
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
	//|Descricao.: Deleta Previs*es caso a tabela de Pr*-calculo esteja vazia.
	//|Observa**o:
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

	*******************************************************************************
Static Function AddButons()
	*******************************************************************************

	Set key VK_F8 to
	SetKey( VK_F8, { || U_AlterEXNCM()  } )

	// AAdd( ABUTTONS , { "RESPONSA", {|| U_AlterEXNCM(), IF(!LNEWTELASI, OMARK:OBROWSE:REFRESH() , OBROWSE:REFRESH() )}, "Alterar EX" } )
	//AAdd( ABOTOESINC , { "RESPONSA", {|| U_AlterEXNCM(), IF(!LNEWTELASI, OMARK:OBROWSE:REFRESH() , OBROWSE:REFRESH() )}, "Alterar EX" } )

	Return
	*******************************************************************************
Static Function RetButons()
	*******************************************************************************

	Set key VK_F8 to

	Return
	*******************************************************************************
User Function AlterEXNCM()
	*******************************************************************************

	Local nP 		:= 0
	Local cNCM 		:= ""
	Local lContinua := .T.
	
	If Type("aSelItem") == "U" /// Soh deve executar caso exista a variavel aselitem... este e o ponto correto...
		Return()
	EndIf

	cNCM := TelaSelNCM(@lContinua)

	If lContinua
	
		DbSelectArea("WORK"); DbGotop()
		While !EOF()

			If WORK->WKFLAG

				WORK->WK_EX_NCM := cNCM
				nP += 1

			EndIf

			DbSelectArea("WORK")
			DbSkip()

		EndDo
		DbSelectArea("WORK"); DbGotop()

		If nP == 0
			Iw_MsgBox( " Nenhum item foi alterado ... " , "Atencao", "INFO")
		ElseIf nP == 1
			Iw_MsgBox( cValToChar(nP) + " item foi alterado para EX NCM '"+cNCM+"' ... " , "Atencao", "INFO")
		Else
			Iw_MsgBox( cValToChar(nP) + " itens foram alterados para EX NCM '"+cNCM+"' ... "  , "Atencao", "INFO")
		EndIf
	EndIF

	Return()
	*******************************************************************************
Static Function TelaSelNCM(lContinua)//| Tela para Selecionar a NCM a ser utilizada...
	*******************************************************************************

	Local cCombo 	:= ""
	Local oCombo 	:= Nil
	Local oTButton 	:= Nil 
	Local oGroup    := Nil
	Local aItems 	:= {}

	aItems := SqlSelOpc()

	DEFINE DIALOG oDlg TITLE "Qual EX_NCM ? " FROM 000,000 TO 100,200 PIXEL

	oGroup:= TGroup():New(02,02,049,102,'',oDlg,,,.T.)
	
	cCombo:= aItems[1]
	oCombo := TComboBox():New(012,030,{|u|if(PCount()>0,cCombo:=u,cCombo)},aItems,50,20,oDlg,,,,,,.T.,,,,,,,,,'cCombo')
	
	oTButton := TButton():New( 035, 005, "Cancela"  ,oDlg,{|| lContinua:=.F., oDlg:end() }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
	oTButton := TButton():New( 035, 060, "Confirma" ,oDlg,{|| oDlg:end()                 }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   

	ACTIVATE DIALOG oDlg CENTERED

	Return(cCombo)
	*******************************************************************************
Static Function SqlSelOpc()//| Obtem todos as ExNCM existentes...TABELA SYD010
	*******************************************************************************

	Local cSql := ""
	Local aAux := {}

	cSql := "SELECT YD_EX_NCM FROM SYD010 GROUP BY YD_EX_NCM ORDER BY YD_EX_NCM"

	U_ExecMySql(cSql, "AUX", "Q", .F.)

	DbSelectArea("AUX");DbGotop()
	While !EOF()

		AADD(aAux , AUX->YD_EX_NCM )

		DbSkip()
	EndDo

	DbCloseArea()

Return aAux
