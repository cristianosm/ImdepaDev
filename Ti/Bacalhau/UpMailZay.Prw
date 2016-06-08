#include 'Totvs.ch'

Static lRunning 	:= .F.
Static lStop			:= .F.


*******************************************************************************
User Function UpMailZay()
*******************************************************************************
	Private nTotal 		:= 0
	Private lShowSql		:= .F.
	Private EmailFind 	:= ""
	Private nUpdate		:= 0
	
	//Obtem Dados
	Consulta()
	
	// Monta Tela de Processamento
	Tela()

Return()
*******************************************************************************	
Static Function Consulta()
*******************************************************************************	

	cSql := ""
	cSql += "Select count(1) Total From sa3010 where a3_email > ' ' " 

	U_ExecMySql(cSql , "REG" , "Q" , lShowSql )
	
	DbSelectArea("REG");DbGotop()
	nTotal := REG->TOTAL

	DbSelectArea("REG");	DbCloseArea()

	cSql := ""
	cSql += "Select trim(a3_email) sa3_email From sa3010 where a3_email > ' ' "

	U_ExecMySql(cSql , "AUX" , "Q" , lShowSql )


Return()
*******************************************************************************	
Static Function Tela()
*******************************************************************************	
	Private oDlg, nMeter := 0, oBtn1, oBtn2
	
	Private oMeter
	Private cTGet := Space(100)
	Private cTGetN := ""
	Private cUGetN
	Private oTGet, oTGetN ,oUGetNÊ

	DEFINE DIALOG oDlg TITLE "| Retirando Emails Indevidos da NFE | Total: "+cValToChar(nTotal) FROM 150,150 TO 330,500 PIXEL
	
	oFont := TFont():New('Courier new',,-12,.T.)
	
	oSay:= TSay():New(05,010,{||'Procucando email...'},oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20) 
	oSay:= TSay():New(05,150,{||'Total'},oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20) 
	
	oTGet		:= TGet():New( 15,010,{||cTGet	},oDlg,130,015,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet ,,,,)
	oTGetN 	:= TGet():New( 15,150,{||cTGetN	},oDlg,020,015,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGetN,,,,)

	oSay:= TSay():New(35,010,{||'Processo Geral...'},oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20) 
	oSay:= TSay():New(35,145,{||'Retirados'},oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20) 

	oMeter		:= TMeter():New(45,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},130,oDlg,100,16,,.T.)
	oMeter:SetTotal (nTotal)
	oUGetN 	 	:= TGet():New( 45,150,{||cUGetN},oDlg,020,015,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cUGetN,,,,)

	@ 070,10  BUTTON oBtn1 PROMPT 'Executar'	SIZE 40,15 OF oDlg PIXEL ACTION ( RunMeter(oMeter) )
	@ 070,70  BUTTON oBtn1 PROMPT 'Parar' 		SIZE 40,15 OF oDlg PIXEL ACTION ( lStop := .T. )
	@ 070,130 BUTTON oBtn1 PROMPT 'Sair' 		SIZE 40,15 OF oDlg PIXEL ACTION ( oDlg:end() )


	ACTIVATE DIALOG oDlg CENTERED

Return()
*******************************************************************************
Static Function RunMeter(oMeter)
*******************************************************************************
 
	Local nCurrent := 1

// Inicia a rŽgua
	oMeter:Set(0)
	oMeter:SetTotal(nTotal)

	DbSelectArea("AUX");DbGotop()
	While !lStop .And. !Eof()

	//	nCurrent 	:= Eval(oMeter:bSetGet)
	
		EmailFind := Alltrim(AUX->SA3_EMAIL)
	
	// Processa o Registro...
		cTGet := ( EmailFind ) 

		cTGetN := cValToChar(nCurrent)
 		
 		cUGetN := cValToChar(nUpdate)

		oTGet:CtrlRefresh()
		oTGetN:CtrlRefresh()
		oUGetN:CtrlRefresh()
	
		oMeter:Refresh()
		
		ProcRegistro()
	
		nCurrent		+= 1
		oMeter:Set(nCurrent)

		If ( nCurrent == oMeter:nTotal ) 

			Iw_MsgBox("Fim do processamento","Atencao","INFO")
			
			oMeter:Set(0)
			
			lStop := .T.
			 
		EndIf

		DbSelectArea("AUX")
		DbSkip()

	Enddo

	lRunning	:= .F.

	lStop		:= .F.

	nCurrent := 0 

Return()

*******************************************************************************
Static Function ProcRegistro()
*******************************************************************************
Local 	cAtualMail	:= ""
Local 	cNovoMail := ""


	cSql:=""
	cSql+= " Select trim(nvl(upper(Zay_email),' ' ))  Zay_email, r_e_c_n_o_ recno "
	cSql+= " From zay010 "
	cSql+= " where d_e_l_e_t_ = ' ' and zay_email like '%"+upper(EmailFind)+"%' or zay_email like '%"+lower(EmailFind)+"%'"

	U_ExecMySql(cSql, "MAIL", "Q", lShowSql)

	DbSelectArea("MAIL");DbGotop()
	While !Eof()

		cAtualMail := Alltrim(MAIL->ZAY_EMAIL)

		cNovoMail 	:= StrTran(Strtran(cAtualMail,EmailFind,''),';;',';')
	
		If Empty(cNovoMail)
			cNovoMail := Space(1)
		EndIf
		
		nUpdate += 1
		
		cSql := "update zay010 set Zay_email = '"+cNovoMail+"' where r_e_c_n_o_ = "+cValToChar(MAIL->RECNO)+" "
		U_ExecMySql(cSql, "", "E",lShowSql)
 
		DbSelectArea("MAIL")
		DbSkip()
	EndDo
	
	DbSelectArea("MAIL")
	DbCloseArea()

Return()