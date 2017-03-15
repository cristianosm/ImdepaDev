#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "Totvs.ch"

#Define _ENTER_  CHR(13) + CHR(10)

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
	Private oMsCalend := Nil //| Objeto Calendario
	Private oMultget  := Nil //| Cria o Objeto Memo
	Private oSay      := Nil //| Cria o Objeto Memo
	Private oGroup    := Nil //|
	Private oTBut_Ok  := Nil //|
	Private oTBut_Ca  := Nil //|
	Private lOkDate	  := .F.
	Private cCodAge	  := SuperGetMv('IM_CODVEWF', .F., '000168') // Codigo do Agendamento responsavel por ececutar a Integracao VE3
	Private dDiaOld	  := Nil 	// Armazena a Data da Agenda anterior...
	Private lOnlyDel  := .F.
	Private lOnlyIns  := .F.
	Private dDiaAtu	  := Nil
	Private lJa		  := .F.

	// Cria o Dialogo
	oDialog:= TDialog():New(180,180,540,680,'Agendamento VE3 - COPLAN',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	oDialog:lCentered := .T.

	// Cria o Group
	oGroup := TGroup():Create(oDialog,005,005,173,246,,,,.T.)

	// Cria o Calendario
	oMsCalend := MsCalend():New(070,050,oDialog,.T.)
	oMsCalend:CanMultSel := .F.

	// Mensagem
	cTxtMM +=  _ENTER_ + SPACE(10) + 'Este programa tem a função de efetuar o agendamento da execucao das ' 	+ _ENTER_
	cTxtMM +=  _ENTER_ + SPACE(10) + 'Procedures que geram os arquivos utilizados na Integracao VE3 - COPLAN.' 	+ _ENTER_

	// Cria o MultGet (Memo)
	oMultget := tMultiget():New( 15, 20, {| u | if( pCount() > 0, cTxtMM := u, cTxtMM ) }, oDialog, 210, 40, , , , , , .T. )
	oMultget:lReadOnly := .T.

	oSay	:= TSay():New(060,075,{||'Por Favor, Selecione uma data abaixo:'},oDialog,,Nil,,,,.T.,CLR_RED,CLR_WHITE,200,20)

	VerAgenda(@oMsCalend)//| Verifica Agendamentos Anteriores que estão Ativos ... 

	oMsCalend:bChange :=  { || IncAgenda(@oMsCalend:dDiaAtu) }//| Inclui no Calendario o Agendamento

	oMsCalend:BlDBlClick := { || DelAgenda(@oMsCalend:dDiaAtu) }//| Desmarca o Agendamento no Calendario


	oSay	:= TSay():New(140,065,{||'* Click = Marca           ** Duplo Click = Desmarca'},oDialog,,Nil,,,,.T.,CLR_RED,CLR_WHITE,200,20)

	// Botoes
	oTBut_Ca := TButton():New( 150, 030, "Sair"		,oDialog,{|| oDialog:end()				 }, 50,15,,,.F.,.T.,.F.,,.F.,,,.F. )   
	oTBut_Ok := TButton():New( 150, 160, "Confirma"	,oDialog,{|| AgendaWf() }, 50,15,,,.F.,.T.,.F.,,.F.,,,.F. )   //|Trata qual o Tipo de alteracao sera efetuado... (Inclusao, Alteracao ou Exclusao)

	oDialog:Activate()

	Return Nil
*******************************************************************************
Static Function VerAgenda(oMsCalend)//| Verifica Agendamentos Anteriores que estão Ativos ... 
*******************************************************************************

	Local cSql := ''

	cSql += " SELECT Min(TSK_DIA) AGENDA FROM SCHDTSK "
	cSql += " WHERE D_E_L_E_T_ = ' ' "
	cSql += " AND   TSK_TENTAT = 0 "
	cSql += " AND   TSK_DIA >= '"+dToS(dDatabase-30)+"'  "
	cSql += " AND TSK_CODIGO = '"+cCodAge+"' " //-- > Informar o Codigo do Processo....

	U_ExecMySql( cSql , 'AGE' , 'Q', .F., .F. )

	DbSelectArea('AGE')
	If !Eof()

		If !Empty(AGE->AGENDA)

			oMsCalend:dDiaAtu  := dDiaOld := StoD(AGE->AGENDA)
			oMsCalend:AddRestri( Val(Substr(AGE->AGENDA,7,2)), CLR_GREEN, CLR_HRED)

		EndIf
	Else
		dDiaOld	  := Nil
	EndIf
	

	Return()
*******************************************************************************
Static Function DelAgenda(dDiaAtu)//| Desmarca o Agendamento no Calendario
*******************************************************************************

	AtuCalend(@oMsCalend,.F.)//| Atualiza o Objeto oMsCalend

	If ValType(dDiaOld) <> "U"
		oMsCalend:AddRestri( Val( Substr( DToS( dDiaOld ) ,7,2)), CLR_GREEN, CLR_HRED)
		lOnlyDel  	:= .T.
	Else
		lOnlyDel  	:= .F.

	EndIf
	lJa := .T.
	lOnlyIns  	:= .F.
	oMsCalend:CtrlRefresh()

	Return()
*******************************************************************************
Static Function IncAgenda(dDiaAtu)//| Inclui no Calendario o Agendamento
*******************************************************************************

	If !lJa

		If ( dDiaAtu < dDatabase )

			Iw_MsgBox( "Por Favor, Selecione uma data futura !!!", "Data Selecionada Inválida!", "ALERT" )
			dDiaAtu  := dDataBase
			lOnlyIns := lOnlyDel := .F.

		Elseif ValType(dDiaOld) <> "U" //| Caso as datas tenham sido mantidas, não precisa alterar o agendamento...

			If dDiaAtu == dDiaOld
				lOnlyIns := lOnlyDel := .F.
			Else
				lOnlyIns := lOnlyDel := .T.
			EndIf
		Else

			If  ValType(dDiaOld) <> "U"
				lOnlyDel := .T.
			EndIf

			lOnlyIns := .T.

		EndIf
	Else
		lJa := .F.
	EndIf
	
	Return Nil
*******************************************************************************
Static Function AgendaWf()//|Trata qual o Tipo de alteracao sera efetuado... (Inclusao, Alteracao ou Exclusao)
*******************************************************************************

	Local cRet	:= ""
	Private dDtAM := dDiaAtu :=  oMsCalend:dDiaAtu	//| Data Atual para Utilizar no Email
	Private dDtOM := dDiaOld 	//| Data Antiga para Utilizar no Email
	Private lOnlyAlt := Iif (lOnlyDel .And. lOnlyIns, .T., .F. )
	
	//dDiaAtu := oMsCalend:dDiaAtu
	
	If ( lOnlyAlt ) .Or. ( lOnlyIns  .And. ValType(dDiaOld) <> "U" .And. dDiaOld <> dDiaAtu )
		If Iw_MsgBox("Confirma à alteração do Agendamento do Exporte de "+DToC(dDiaOld)+" para "+DToC(dDiaAtu)+"... "," Alteração","YESNO")
			
			
			DelWfAge()//| Efetiva a Exclucao do Agendamento....
			InsWfAge(dDiaAtu)//| Efetiva a Inclusao do Agendamento....
			lOnlyDel :=  lOnlyIns := .F.
			
		EndIf
	Else

		If lOnlyDel
			If Iw_MsgBox("Confirma o Cancelamento do Agendamento do Exporte no dia "+DToC(dDiaOld)+" ... "," Exclusão","YESNO")
				
				dDtOM := dDiaOld
				DelWfAge()//| Efetiva a Exclucao do Agendamento....
				lOnlyDel := .F.
				
			EndIf
		EndIf

		If lOnlyIns

			If Iw_MsgBox("Confirma o Agendamento do Exporte para "+DToC(dDiaAtu)+" ... "," Inclusão","YESNO")				
				InsWfAge(dDiaAtu) //| Efetiva a Inclusao do Agendamento....
				lOnlyIns := .F.
			EndIf
		EndIf
	EndIf

	AtuCalend(@oMsCalend)//| Atualiza o Objeto oMsCalend
		
	Return()
*******************************************************************************
Static Function DelWfAge()//| Efetiva a Exclucao do Agendamento....
*******************************************************************************
	Local cSqlD := ""

	//| Deleta o Agendamento Anterior....
	If ValType(dDiaOld) <> "U" //| So faz o Delete caso exista um agendamento....

		cSqlD += "DELETE SIGA.SCHDTSK WHERE TSK_CODIGO = '"+cCodAge+"' AND TSK_DIA = '"+DToS(dDiaOld)+"' AND TSK_TENTAT = 0 "

		cRet := U_ExecMySql( cSqlD , "" , "E", .F. , .F. )
		
		dDiaOld := Nil
	
	EndIf
	
	If At("Sucesso",cRet) > 0 
	 	If !lOnlyAlt
	 		Iw_MsgBox("Cancelado com Sucesso!!!","Cancelado...","INFO")
	 		SendMail("E") // Exclusao
	 	EndIf
	Else
		Iw_MsgBox(cRet,"Erro ao Cancelar Agenda !!!","ALERT")
	EndIf

	Return
*******************************************************************************
Static Function InsWfAge(dDiaAtu)//| Efetiva a Inclusao do Agendamento....
*******************************************************************************
	Local cSqlI	:= ""

	//| Insere o novo Agendamento....
	cSqlI += "INSERT INTO "
	cSqlI += "	SIGA.SCHDTSK(TSK_CODIGO,TSK_ITEM,TSK_ENV,TSK_EMP,TSK_FILIAL,TSK_USERID,TSK_HORA,TSK_ROTINA,TSK_MODULO,TSK_STATUS,TSK_EXEC,TSK_TENTAT,TSK_PARM,D_E_L_E_T_,R_E_C_N_O_,R_E_C_D_E_L_,TSK_DIA) "
	cSqlI += "	VALUES('"+cCodAge+"',(SELECT NVL(TRIM(TO_CHAR(MAX(TSK_ITEM)+1,'000000')),'000001') ITEM FROM SCHDTSK WHERE TSK_CODIGO = '"+cCodAge+"'),'WORKFLOW','01','05','000615','22:00','U_WsExecVe3()',	2,'0','               ',0,NULL,' ',(SELECT	MAX( R_E_C_N_O_ )+ 1 FROM SCHDTSK),	0,'"+DToS(dDiaAtu)+"') "

	cRet := U_ExecMySql( cSqlI , "" , "E", .F. , .F. )

	If At("Sucesso",cRet) > 0
		Iw_MsgBox("Agendado com Sucesso!!!","Agendado...","INFO")
		If !lOnlyAlt
			SendMail("I") // Inclusao 
		Else
			SendMail("A") // Alteracao
		EndIf
	Else
		Iw_MsgBox(cRet,"Erro ao confirmar agenda !!!","ALERT")
	EndIf

	Return
*******************************************************************************
Static Function AtuCalend(oMsCalend, lVerAge)//| Atualiza o Objeto oMsCalend
*******************************************************************************

	Default lVerAge := .T.
	
	oMsCalend := MsCalend():New(070,050,oDialog,.T.)
	oMsCalend:CanMultSel := .F.
	oMsCalend:bChange 	 := { || IncAgenda(@oMsCalend:dDiaAtu) }//| Inclui no Calendario o Agendamento
	oMsCalend:bldBlClick := { || DelAgenda(@oMsCalend:dDiaAtu) }//| Desmarca o Agendamento no Calendario
	
	If lVerAge
		VerAgenda(@oMsCalend) //| Verifica Agendamentos Anteriores que estão Ativos ... 
	EndIf
		
Return	
*******************************************************************************
Static Function SendMail(xTp) 
*******************************************************************************

Local cTo 		:= UsrRetMail( RetCodUsr() )
Local cBcc		:= "grupo_ti@imdepa.com.br"
Local cSubject 	:= " Agendamento VE3 - COPLAN"
Local cBody 	:= _ENTER_

 
If xTp == "I"

	cBody += " Atenção, " + _ENTER_ + _ENTER_
	cBody += " Foi efetuado o Agendamento da Execução da PROCEDURE VE3 - COPLAN " + _ENTER_
	cBody += "  " + _ENTER_
	cBody += " Para  " + dToC(dDtAM) + " às 22:00 Horas ..."
	
	
ElseIf xTp == "A"

	cBody += " Atenção, " + _ENTER_ + _ENTER_
	cBody += " Foi alterado o Agendamento da Execução da PROCEDURE VE3 - COPLAN " + _ENTER_
	cBody += "  " + _ENTER_
	cBody += " De  "+dToC(dDtOM)+"  para  " + dToC(dDtAM) + " às 22:00 Horas... "

ElseIf xTp == "E"

	cBody += " Atenção, " + _ENTER_ + _ENTER_
	cBody += " Foi cancelado o Agendamento da Execução da PROCEDURE VE3 - COPLAN " + _ENTER_
	cBody += "  " + _ENTER_
	cBody += " Para  " + dToC(dDtOM) + " às 22:00 Horas ..."

EndIf


cBody +=  _ENTER_ +  _ENTER_ + " Envio Automático - TI Imdepa Rolamentos" 


U_EnvMyMail(Nil, cTo, cBcc, cSubject, cBody, Nil, .F.)

PutMV('IM_EAGEVE3',Alltrim(cTo)) 

Return()