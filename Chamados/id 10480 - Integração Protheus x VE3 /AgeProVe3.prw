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
	//oDialog:Center := .T. 
    
    // Cria o Calendario 
	oMsCalend := MsCalend():New(070,50,oDialog,.T.)   
	
	// Mensagem
	cTxtMM +=  _ENTER_ + SPACE(10) + 'Este programa tem a funcao de efetuar o agendamento da execucao ' 	+ _ENTER_
	cTxtMM +=  _ENTER_ + SPACE(10) + 'das Procedures que geram os arquivos utilizados na Integracao VE3.' 	+ _ENTER_

    // Cria o MultGet (Memo)
	oMultget := tMultiget():New( 10, 20, {| u | if( pCount() > 0, cTxtMM := u, cTxtMM ) }, oDialog, 210, 50, , , , , , .T. )
	oMultget:lReadOnly := .T.
	
	// Define o dia a ser exibido no calendario   
	oMsCalend:dDiaAtu := VerAgenda()    
		
	// Code-Block para mudanca de Dia   
	oMsCalend:bChange := { || CtrDateCal(oMsCalend:dDiaAtu) }       

	// Code-Block para mudanca de mes   
	//oMsCalend:bChangeMes := { || alert('Mes alterado') }                  
	
	oDialog:Activate()
	

Return Nil	
*******************************************************************************
Static Function VerAgenda()
*******************************************************************************

Return(ctod( "01/01/2008" ))
*******************************************************************************
Static Function CtrDateCal(dDiaAtu)
*******************************************************************************
	
	Alert(cValToChar(dDiaAtu))
	
Return Nil 