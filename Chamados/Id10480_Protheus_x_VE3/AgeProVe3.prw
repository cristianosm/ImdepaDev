#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "Totvs.ch"


#Define _ENTER_ CHR(13) + CHR(10)


//|****************************************************************************
//| Projeto:
//| Modulo :
//| Fonte : AgeProVe3
//|
//|************|******************|*********************************************
//|    Data    |     Autor        |                   Descricao
//|************|******************|*********************************************
//| 25/01/2017 | Cristiano Machado| Funcao responsavel por agendar a Execucao da Rotina
//|            |                  | WsExecVe3 que dispara a execucao das Procedures .
//|            |                  |
//|            |                  |
//|            |                  |
//|************|***************|***********************************************
*******************************************************************************
User function AgeProVe3()
*******************************************************************************

	Local cTxtMM      := ''

	Private oDialog   := Nil //| Objeto Janela Principal
	Private oMsCalend := Nil /// Objeto Calendario
	Private oMultget  := Nil // Cria o Objeto Memo


	// Cria o Dialogo
	oDialog:= TDialog():New(180,180,550,680,'Agendamento VE3',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	oDialog:lCentered := .T.

    // Cria o Calendario
	oMsCalend := MsCalend():New(070,50,oDialog,.T.)
	oMsCalend:CanMultSel := .F.
	// Mensagem
	cTxtMM +=  _ENTER_ + SPACE(10) + 'Este programa tem a funcao de efetuar o agendamento da execucao ' 	+ _ENTER_
	cTxtMM +=  _ENTER_ + SPACE(10) + 'das Procedures que geram os arquivos utilizados na Integracao VE3.' 	+ _ENTER_

    // Cria o MultGet (Memo)
	oMultget := tMultiget():New( 10, 20, {| u | if( pCount() > 0, cTxtMM := u, cTxtMM ) }, oDialog, 210, 50, , , , , , .T. )
	oMultget:lReadOnly := .T.

	// Define o dia a ser exibido no calendario
	VerAgenda(@oMsCalend)

	// Code-Block para mudanca de Dia
	oMsCalend:bChange := { || CtrDateCal(oMsCalend:dDiaAtu) }

	// Code-Block para mudanca de mes
	//oMsCalend:bChangeMes := { || alert('Mes alterado') }

	oDialog:Activate()


Return Nil
*******************************************************************************
Static Function VerAgenda(oMsCalend)
*******************************************************************************

Local cSql := ''
//Local dAg := CtoD('  /  /  ')
// Query para Verificar se existe Agenda

cSql += " SELECT Min(TSK_DIA) AGENDA FROM SCHDTSK "
cSql += " WHERE D_E_L_E_T_ = ' ' "
cSql += " AND   TSK_TENTAT = 0 "
cSql += " AND   TSK_DIA >= '20170131'  "
cSql += " AND TSK_CODIGO = '000162' " //-- > Informar o Codigo do Processo....

U_ExecMySql( cSql , 'AGE' , 'Q', .F., .F. )

DbSelectArea('AGE')
If !Eof()

	If !Empty(AGE->AGENDA)
		Alert('Entrou')
		oMsCalend:dDiaAtu  := StoD(AGE->AGENDA)
	EndIf
EndIf

Return()
*******************************************************************************
Static Function CtrDateCal(dDiaAtu)
*******************************************************************************

	Alert(cValToChar(dDiaAtu))

Return Nil