#include "protheus.ch"
#include "fwstyle.ch"

USER FUNCTION V3ExtA01()
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Browse do cadastro de consultas
<Data> : 28/09/2016
<Parametros> : Nenhum
<Retorno> : Nenhum
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : M
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local cVldAlt	:= "U_V3ExtA04() .AND. U_VExtA01M()"
Local cVldExc	:= "U_VExtA01E()" 
Local aBotoes	:= {}
Local aRotAdc	:= {}
Private cString := U_VExtM01I("CONS")

Aadd(aRotAdc, {"ServiÁo", "U_VExtA01S", 0, 6})

DbSelectArea(cString)
DbSetOrder(1)

Aadd(aBotoes, {"recorrente", {|| U_VExtA01R()}, "Agendamento", "Agendamento"})

AxCadastro(cString, "Cadastro de Consultas", cVldExc, cVldAlt, aRotAdc,,,,,,, aBotoes)

Return	

USER FUNCTION VExtA01S()
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Browse do cadastro de consultas
<Data> : 28/09/2016
<Parametros> : Nenhum
<Retorno> : Nenhum
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : M
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local lAtivo	:= .t.
Local cArquivo	:= U_VExtJ01N()[1] + U_VExtJ01N()[2]
Local aAliases	:= {}

IF !File(cArquivo) .OR. FErase(cArquivo) == 0
	lAtivo	:= .f.
ENDIF

IF lAtivo
	IF Aviso("ServiÁo ativo", "O serviÁo de execuÁ„o das consultas est· ATIVO." + CRLF + "Deseja interromper o serviÁo?", {"Sim", "N„o"}) == 1
		MemoWrit(StrTran(cArquivo, ".lck", ".sto"), StrTran(cArquivo, ".lck", ".sto"))
		Sleep(1000)
	ENDIF
ELSE
	IF Aviso("ServiÁo inativo", "O serviÁo de execuÁ„o das consultas est· INATIVO." + CRLF + "Deseja iniciar o serviÁo?", {"Sim", "N„o"}) == 1
		Aadd(aAliases, {"CONS", GetPvProfString("ALIAS_EXPORT_TOOL", "CONS", "*", U_VExtM01R())})
		Aadd(aAliases, {"PERM", GetPvProfString("ALIAS_EXPORT_TOOL", "PERM", "*", U_VExtM01R())})
		Aadd(aAliases, {"SXB1", GetPvProfString("ALIAS_EXPORT_TOOL", "SXB1", "*", U_VExtM01R())})
		Aadd(aAliases, {"SXB2", GetPvProfString("ALIAS_EXPORT_TOOL", "SXB2", "*", U_VExtM01R())})
		Aadd(aAliases, {"SXB3", GetPvProfString("ALIAS_EXPORT_TOOL", "SXB3", "*", U_VExtM01R())})
		Aadd(aAliases, {"SXB4", GetPvProfString("ALIAS_EXPORT_TOOL", "SXB4", "*", U_VExtM01R())})
		
		StartJob("U_V3ExtJ01", GetEnvServer(), .F., {cEmpAnt, cFilAnt, AClone(aAliases)})
		Sleep(1000)
	ENDIF
ENDIF
RETURN

USER FUNCTION VExtA01R()
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Interface de configuraÁ„o dos agendamentos e recorrÍncia de execuÁ„o autom·tica das consultas
<Data> : 28/09/2016
<Parametros> : Nenhum
<Retorno> : Nenhum
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local oDlg, oFWLayer, oPFreq, oPExec, oPeriod, oDEach, oDEvery, oDDay, oMDay, oYDay, oYMonth, oRExe, oRInter, oBtnTable, oLbx, oEndNo, oEnd, oEndDay
Local oSubmit, oCancel, oDtIni, oHrIni
Local cCons		:= U_VExtM01I("CONS")
Local cPreC		:= Iif(Left(cCons, 1) == "S", Substr(cCons, 2), cCons)
Local nPeriod	:= 1
Local aPanels	:= {}
Local lDEach	:= .t.
Local lDEvery	:= .f.
Local nDDay		:= 1
Local aWeek		:= {.F., .F., .F., .F., .F., .F., .F.}
Local nMDay		:= 1
Local nYDay		:= 1
Local cRExe		:= "01"
Local cTime		:= ""
Local cRInter	:= "00:00"
Local cLbx		:= ""
Local aHoras	:= {}
Local lEnd		:= .t.
Local lEndNo	:= .f.
Local dEndDay	:= Date()
Local lSubmit	:= .f.
Local cYMonth	:= ""
Local lShowLbx	:= .T.
Local dDtIni	:= Date()
Local cHrIni	:= "00:00"

IF &("M->" + cPreC + "_MODOEX") == "1"
	Aviso("ConfiguraÁ„o do agendamento", "A consulta 'Manual' n„o permite a configuraÁ„o de agendamento.", {"Fechar"})
ELSE
	nPeriod		:= Val(&("M->" + cPreC + "_PADRAO"))
	lDEvery		:= &("M->" + cPreC + "_QTSDIA") == -1
	lDEach		:= &("M->" + cPreC + "_QTSDIA") # -1
	nDDay		:= Iif(&("M->" + cPreC + "_QTSDIA") == -1, 0, &("M->" + cPreC + "_QTSDIA"))
	aWeek[1]	:= &("M->" + cPreC + "_DOMING")
	aWeek[2]	:= &("M->" + cPreC + "_SEGUND")
	aWeek[3]	:= &("M->" + cPreC + "_TERCA")
	aWeek[4]	:= &("M->" + cPreC + "_QUARTA")
	aWeek[5]	:= &("M->" + cPreC + "_QUINTA")
	aWeek[6]	:= &("M->" + cPreC + "_SEXTA")
	aWeek[7]	:= &("M->" + cPreC + "_SABADO")
	nMDay		:= Iif(nPeriod == 3, &("M->" + cPreC + "_DIAMES"), nMDay)
	nYDay		:= Iif(nPeriod == 4, &("M->" + cPreC + "_DIAMES"), nYDay)
	cYMonth		:= &("M->" + cPreC + "_MES")
	cRExe		:= StrZero(&("M->" + cPreC + "_EXEDIA"), 2)
	cRInter		:= &("M->" + cPreC + "_INTERV")
	lEndNo		:= Empty(&("M->" + cPreC + "_DTTERM"))
	lEnd		:= !Empty(&("M->" + cPreC + "_DTTERM"))
	dEndDay		:= &("M->" + cPreC + "_DTTERM")
	dDtIni		:= Iif(Empty(&("M->" + cPreC + "_DTINI")), dDtIni, &("M->" + cPreC + "_DTINI"))
	cHrIni		:= Iif(Empty(Alltrim(&("M->" + cPreC + "_HRINI"))), cHrIni, &("M->" + cPreC + "_HRINI"))

	DEFINE MSDIALOG oDlg TITLE "Agendamento da consulta" FROM 000, 000 TO 318, 550 PIXEL
	
	oFWLayer := FWLayer():New()
	oFWLayer:init( oDlg )
	
	// Adiciona coluna no layer de serviÁos
	oFWLayer:AddCollumn("Sched", 100, .F.)
	
	// Cria janelas dos serviÁos
	oFWLayer:AddWindow("Sched", "Freq", "Padr„o"	, 45, .F., .T., {||} )
	oFWLayer:AddWindow("Sched", "Exec", "Intervalo"	, 45, .F., .T., {||} )
	
	oPFreq := oFWLayer:GetWinPanel("Sched", "Freq")
	oPFreq:ReadClientCoors()
	
	oPExec := oFWLayer:GetWinPanel("Sched", "Exec")
	oPExec:readClientCoors()
	
	@ 005, 010 RADIO oPeriod VAR nPeriod ITEMS "Di·rio", "Semanal", "Mensal", "Anual" SIZE 045, 000 OF oPFreq PIXEL 
	oPeriod:bChange	:= {|| UpdatePanels(nPeriod, aPanels)}
	oPeriod:bWhen	:= {|| Inclui .OR. Altera}
	oPeriod:setCSS(FW_P10_RADIO)
	
	// Diario
	Aadd(aPanels, TPanel():New(002, 055,, oPFreq,,,,,, 210, 042,,))
	
	@ 005, 005 CHECKBOX oDEach VAR lDEach PROMPT "A cada" SIZE 029, 010 OF aPanels[1] PIXEL
	oDEach:bLClicked	:= {|| Iif(lDEach, lDEvery := .F., lDEvery := .T.), oDEvery:Refresh()}
	oDEach:bWhen		:= {|| Inclui .OR. Altera}
	
	@ 004, 035 GET oDDay VAR nDDay PICTURE "@E 99" OF aPanels[1] SIZE 020, 009 PIXEL
	oDDay:bWhen := {|| Inclui .OR. Altera}
	
	@ 006, 055 SAY " dia(s)" SIZE 020, 010 OF aPanels[1] PIXEL
	
	@ 020, 005 CHECKBOX oDEvery VAR lDEvery PROMPT "Todos os dias da semana" SIZE 080, 010 OF aPanels[1] PIXEL
	oDEvery:bLClicked	:= {|| Iif(lDEvery, lDEach := .F., lDEach := .T.), oDEach:Refresh()}
	oDEvery:bWhen		:= {|| Inclui .OR. Altera}
	
	// Semanal
	Aadd(aPanels, TPanel():New(002, 055,, oPFreq,,,,,, 210, 042,,))
	
	@ 005, 005 SAY "Todo(a)" SIZE 050, 010 OF aPanels[2] PIXEL
	@ 015, 007 CHECKBOX aWeek[1] PROMPT "domingo"	SIZE 050, 010 OF aPanels[2] WHEN {|| Inclui .OR. Altera} PIXEL
	@ 015, 060 CHECKBOX aWeek[2] PROMPT "segunda"	SIZE 050, 010 OF aPanels[2] WHEN {|| Inclui .OR. Altera} PIXEL
	@ 015, 113 CHECKBOX aWeek[3] PROMPT "terÁa"		SIZE 050, 010 OF aPanels[2] WHEN {|| Inclui .OR. Altera} PIXEL
	@ 015, 160 CHECKBOX aWeek[4] PROMPT "quarta"	SIZE 050, 010 OF aPanels[2] WHEN {|| Inclui .OR. Altera} PIXEL
	@ 030, 007 CHECKBOX aWeek[5] PROMPT "quinta"	SIZE 050, 010 OF aPanels[2] WHEN {|| Inclui .OR. Altera} PIXEL
	@ 030, 060 CHECKBOX aWeek[6] PROMPT "sexta"		SIZE 050, 010 OF aPanels[2] WHEN {|| Inclui .OR. Altera} PIXEL
	@ 030, 113 CHECKBOX aWeek[7] PROMPT "s·bado"	SIZE 050, 010 OF aPanels[2] WHEN {|| Inclui .OR. Altera} PIXEL
	
	// Mensal
	Aadd(aPanels, TPanel():New(002, 055,, oPFreq,,,,,, 210, 042,,))
	
	@ 006, 005 SAY "Dia" SIZE 025, 010 OF aPanels[3] PIXEL
	@ 004, 020 GET oMDay VAR nMDay PICTURE "@E 99" SIZE 020, 009 OF aPanels[3] PIXEL
	oMDay:bWhen := {|| Inclui .OR. Altera}
	
	@ 006, 042 SAY "de cada mÍs" SIZE 050, 010 OF aPanels[3] PIXEL
	
	// Anual
	Aadd(aPanels, TPanel():New(002, 055,, oPFreq,,,,,, 210, 042,,))
	
	@ 006, 005 SAY "A cada dia" SIZE 030, 010 OF aPanels[4] PIXEL
	
	@ 004, 033 GET oYDay VAR nYDay PICTURE "@E 99" SIZE 020, 009 OF aPanels[4] PIXEL
	oYDay:bWhen := {|| Inclui .OR. Altera}
	
	@ 006, 055 SAY "de" SIZE 010, 010 OF aPanels[4] PIXEL
	
	@ 004, 065 COMBOBOX oYMonth VAR cYMonth ITEMS {"1=janeiro", "2=fevereiro", "3=marÁo", "4=abril", "5=maio", "6=junho", "7=julho", "8=agosto", ;
		"9=setembro", "A=outubro", "B=novembro", "C=dezembro"} SIZE 050, 012 OF aPanels[4] PIXEL
	oYMonth:bWhen := {|| Inclui .OR. Altera}
	
	// Atualiza todos os paineis
	UpdatePanels(nPeriod, aPanels)
	
	@ 005, 010 SAY "Data de inÌcio" PIXEL OF oPExec
	@ 003, 050 MSGET oDtIni VAR dDtIni SIZE 050, 009 PIXEL OF oPExec HASBUT VALID VlDtIni(dDtIni)
	oDtIni:bWhen	:= {|| Inclui .OR. Altera}
	
	@ 005, 110 SAY "Hr. ExecuÁ„o" PIXEL OF oPExec
	@ 003, 149 GET oHrIni VAR cHrIni SIZE 020, 009 PICTURE "99:99" PIXEL OF oPExec ;
		VALID (VlHrIni(cHrIni) .AND. TabExec(.F., cHrIni, cRInter, cRExe, @aHoras, @oLbx))
	oHrIni:bWhen	:= {|| Inclui .OR. Altera}
	
	@ 017, 010 SAY "N∫ ExecuÁıes no mesmo dia" SIZE 070, 010 OF oPExec PIXEL
	@ 015, 082 GET oRExe VAR cRExe SIZE 010, 009 PICTURE "@E 99" OF oPExec PIXEL
	oRExe:bValid	:= {|| ValidVz(cRExe, @cTime, @cRInter, @oRInter), ;
							TabExec(.F., cHrIni, cRInter, cRExe, @aHoras, @oLbx), Iif(Val(cRExe) > 0, oRInter:SetFocus(), .T.)}
	oRExe:bWhen		:= {|| Inclui .OR. Altera}
	
	@ 017, 126 SAY "Intervalo" SIZE 020, 010 OF oPExec PIXEL
	
	@ 015, 149 GET oRInter VAR cRInter SIZE 020, 009 PICTURE "99:99" OF oPExec PIXEL
	oRInter:bValid	:= {|| SchVldInt(cRInter, cRExe, cTime)}
	oRInter:bChange	:= {|| TabExec(.F., cHrIni, cRInter, cRExe, @aHoras, @oLbx)}
	oRInter:bWhen	:= {|| Inclui .OR. Altera}
	
	@ 003, 195 LISTBOX oLbx VAR cLbx ITEMS aHoras SIZE 070, 037 OF oPExec PIXEL
	//oLbx:Hide()
	
	@ 032, 010 CHECKBOX oEndNo VAR lEndNo PROMPT "Sem data de tÈrmino" SIZE 060, 010 OF oPExec PIXEL
	oEndNo:bLClicked	:= {|| Iif(lEndNo, lEnd := .F., lEnd := .T.), oEnd:Refresh()}
	oEndNo:bWhen		:= {|| Inclui .OR. Altera}
	
	@ 032, 082 CHECKBOX oEnd VAR lEnd PROMPT "Termina em:" SIZE 080, 010 OF oPExec PIXEL
	oEnd:bLClicked	:= {|| Iif(lEnd, lEndNo := .F., lEndNo := .T.), oEndNo:Refresh()}
	oEnd:bWhen		:= {|| Inclui .OR. Altera}
	
	@ 032, 130 MSGET oEndDay VAR dEndDay SIZE 060, 009 OF oPExec PIXEL HASBUT
	oEndDay:bValid	:= {|| Iif(dEndDay < Date(), (MsgAlert("A data de tÈrmino deve ser maior que a data inicial " + Dtoc(Date()), "AtenÁ„o"), .F.), .T.)}
	oEndDay:bWhen	:= {|| Inclui .OR. Altera}
	
	@ 146, 150 BUTTON oSubmit PROMPT "Confirmar" OF oDlg SIZE 050, 012 ACTION (lSubmit := .T., oDlg:End()) PIXEL
	oSubmit:bWhen	:= {|| Inclui .OR. Altera}
	
	@ 146, 210 BUTTON oCancel PROMPT "Cancelar" OF oDlg SIZE 050, 012 ACTION (lSubmit := .F., oDlg:End()) PIXEL
	
	ACTIVATE DIALOG oDlg CENTERED ON INIT Eval(oRInter:bChange)
	
	IF lSubmit
		&("M->" + cPreC + "_PADRAO")	:= Alltrim(Str(nPeriod))
		&("M->" + cPreC + "_QTSDIA")	:= Iif(lDEvery, -1, nDDay)
		&("M->" + cPreC + "_DOMING")	:= aWeek[1]
		&("M->" + cPreC + "_SEGUND")	:= aWeek[2]
		&("M->" + cPreC + "_TERCA")		:= aWeek[3]
		&("M->" + cPreC + "_QUARTA")	:= aWeek[4]
		&("M->" + cPreC + "_QUINTA")	:= aWeek[5]
		&("M->" + cPreC + "_SEXTA")		:= aWeek[6]
		&("M->" + cPreC + "_SABADO")	:= aWeek[7]
		&("M->" + cPreC + "_DIAMES")	:= Iif(nPeriod == 3, nMDay, nYDay)
		&("M->" + cPreC + "_MES")		:= cYMonth
		&("M->" + cPreC + "_EXEDIA")	:= Val(cRExe)
		&("M->" + cPreC + "_INTERV")	:= cRInter
		&("M->" + cPreC + "_DTTERM")	:= Iif(lEndNo, Ctod(""), dEndDay)
		&("M->" + cPreC + "_DTINI")		:= dDtIni
		&("M->" + cPreC + "_HRINI")		:= cHrIni
	ENDIF
ENDIF

RETURN

STATIC FUNCTION VlDtIni(dDtIni)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : ValidaÁ„o da data inicial de processamento
<Data> : 28/09/2016
<Parametros> : dDtIni - Data inicial digitada pelo usu·rio
<Retorno> : LÛgico
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : V
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local lRet	:= .t.

IF dDtIni < Date()
	Aviso("Data inv·lida", "A data inicial deve ser maior ou igual a data atual.", {"Fechar"})
	lRet	:= .f.
ENDIF
Return(lRet)

STATIC FUNCTION VlHrIni(cHrIni)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : ValidaÁ„o da hora de execuÁ„o
<Data> : 28/09/2016
<Parametros> : cHrIni - caractere representando o hor·rio digitado pelo usu·rio
<Retorno> : LÛgico
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local lRet	:= .t.

IF Val(Left(cHrIni, 2)) > 23
	lRet	:= .f.
	Aviso("Hora inv·lida", "Informe a hora no intervalo entre 00 e 23.", {"Fechar"})
ELSEIF !Substr(cHrIni, 4) $ "00|15|30|45"
	lRet	:= .f.
	Aviso("Minuto inv·lido", "Digite os minutos em quartos de hora dentro do intervalo entre 00 e 45.", {"Fechar"})
ENDIF

Return(lRet)

STATIC FUNCTION SchVldInt(cHoraIt, cVz, cHoraIn)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : ValidaÁ„o do intervalo de execuÁ„o
<Data> : 28/09/2016
<Parametros> : cHoraIt, cVz, cHoraIn
	cHoraIt	: Intevalo de execuÁ„o no formato hh:mm
	cVz		: Quantidade de execuÁıes no mesmo dia no formato caractere
<Retorno> : LÛgico
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : V
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local lRet		:= .t.
Local nMinutos	:= 0
Local nH		:= 0
Local nM		:= 0
Local nHorasDia	:= 0
Local nHoras	:= 0
Local nHint		:= 0

IF " " $ cHoraIt
	Aviso("AtenÁ„o", "Intervalo invalido", {"Fechar"})
	lRet	:= .F.
ELSE
	nH	:= Val(SubStr(cHoraIt, 1, 2))
	nM	:= Val(SubStr(cHoraIt, 4, 2))
	
	IF !((nH >= 0 .AND. nM == 0) .OR. nM == 15 .OR. nM == 30 .OR. nM == 45 )
		Aviso("AtenÁ„o", "Intervalo inv·lido. Informe em quartos de hora", {"Fechar"})
		lRet	:= .F.
	ENDIF
ENDIF

IF lRet
	nMinutos	:= (nH * 60) + nM
	
	IF !CalcHora(@nHorasDia, @nHoras, @nHint, ,cHoraIn, cHoraIt, cVz)
		lRet	:= .F.
	ENDIF
ENDIF
Return(lRet)

STATIC FUNCTION UpdatePanels(nPeriod, aPanels)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : FunÁ„o para atualizaÁ„o dos paineis na mudanÁa de tipo de periodicidade
<Data> : 28/09/2016
<Parametros> : nPeriod, aPanels
	nPeriod	: n˙mero do perÌodo selecionado pelo usu·rio (di·rio, semanal, mensal e anual)
	aPanels	: array com os objetos correspondentes aos painÈis criados para as configuraÁıes por tipo de perÌodo
<Retorno> : Nenhum
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local nX	:= 0

FOR nX := 1 TO Len(aPanels)
	IF nX == nPeriod
		aPanels[nX]:Show()
	ELSE
		aPanels[nX]:Hide()
	ENDIF
NEXT
RETURN

STATIC FUNCTION TabExec(lShow, cHoraIn, cHoraIt, cVz, aHora, oList)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Retorna lista com os hor·rios para execuÁ„o
<Data> : 28/09/2016
<Parametros> : lShow, cHoraIn, cHoraIt, cVz, aHora, oList
	lShow	: Se .t., forÁa a exibiÁ„o do objeto com a lista de hor·rios
	cHoraIn	: Hor·rio inicial
	cHoraIt	: Intervalo em hh:mm
	cVz		: Quantidade de execuÁıes
	aHora	: Array com a lista de hor·rios de execuÁ„o
	oList	: Objeto de exibiÁ„o da lista de hor·rios
<Retorno> : Nenhum
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local nHour		:= (Val(SubStr(cHoraIn, 1, 2)) * 60) + Val(SubStr(cHoraIn, 4, 2))
Local nInterv	:= (Val(SubStr(cHoraIt, 1, 2)) * 60) + Val(SubStr(cHoraIt, 4, 2))
Local nVz		:= Val(cVz)
Local i			:= 0
Local nHoras	:= 0
Default lShow	:= .t.

IF CalcHora(,,,.F., cHoraIn, cHoraIt, cVz)
	aHora	:= {}
	
	Aadd(aHora, " 1  " + StrZero(Int(nHour / 60), 2) + ":" + StrZero(Mod(nHour, 60), 2))
	FOR i := 1 TO (nVz - 1)
		nHoras	:= nHour + (i * nInterv)
		Aadd(aHora, Str(i + 1, 2) + "  " + StrZero(Int(nHoras / 60), 2) + ":" + StrZero(Mod(nHoras, 60), 2))
	NEXT
	
	oList:SetItems(aHora)
	oList:Refresh()
	IF lShow
		oList:Show()
	ENDIF
ENDIF

RETURN

STATIC FUNCTION ValidVz(cVz, cHoraIn, cHoraIt, oHoraIt)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Valida a quantidade de execuÁıes por dia
<Data> : 28/09/2016
<Parametros> : cVz, cHoraIn, cHoraIt, oHoraIt
	cVz		: Quantidade de execuÁıes por dia
	cHoraIn	: Hora incial
	cHoraIt	: Intervalo entre execuÁıes no formato hh:mm
	oHoraIt	: Objeto com o GET do intervalo de execuÁıes
<Retorno> : LÛgico
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : V
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local lRet		:= .t.
Local nVz		:= 0
Local nHorasDia	:= 0
Local nHoras	:= 0
Local nHint		:= 0

IF !(cVz $ "  ")
	nVz	:= Val(cVz)
	
	IF (nVz < 0)
		Aviso("N˙mero de execuÁıes", "O n˙mero de execuÁıes deve ser maior que 0!", {"Fechar"})
		lRet	:= .F.
	ELSEIF nVz == 0
		cHoraIt	:= "00:00"
		oHoraIt:Refresh()
	ELSE
		oHoraIt:SetFocus()
	ENDIF
ELSE
	Aviso("N˙mero de execuÁıes", "O n˙mero de execuÁıes deve ser maior que 0!", {"Fechar"})
	lRet	:= .F.
ENDIF

IF lRet .AND. !CalcHora(@nHorasDia, @nHoras, @nHint,, cHoraIn, cHoraIt, cVz)
	lRet	:= .F.
ENDIF

Return(lRet)

STATIC FUNCTION CalcHora(nHorasDia, nHoras, nHint, lMsg, cHoraIn, cHoraIt, cVz)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Valida a quantidade de horas por dia
<Data> : 28/09/2016
<Parametros> : nHorasDia, nHoras, nHint, lMsg, cHoraIn, cHoraIt, cVz
	nHorasDia	: Quantidade de horas no dia
	nHoras		: Quantidade de horas
	nHint		: Horas de intervalo
	lMsg		: Se .t., exibe mensagem quando a quantidade de horas calculada for inv·lida
	cHoraIn		: Hor·rio inicial
	cHoraIt		: Intervalo no formato hh:mm
	cVz			: Quantidade de execuÁıes no dia
<Retorno> : LÛgico
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : V
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local lRet		:= .t.
Local nHin		:= 0
Local nMin		:= 0
Local nInterv	:= 0
Local nHFi		:= 0
Local nMFi		:= 0
Default lMsg	:= .T.

nHorasDia	:= 1440

nHIn	:= Val(SubStr(cHoraIn, 1, 2))

nMIn	:= Val(SubStr(cHoraIn, 4, 2))

nHoras	:= (nHIn * 60) + nMin

nInterv	:= Val(cVz)

nHFi	:= Val(SubStr(cHoraIt, 1, 2))
nMFi	:= Val(SubStr(cHoraIt, 4, 2))

nHInt	:= (nHFi * 60) + nMFi

IF nHorasDia < (nHoras + (nInterv * nHInt))
	IF lMsg
		Aviso("AtenÁ„o", "Excederam as 24h di·rias, n„o ser· possÌvel executar a tarefa!", {"Fechar"})
	ENDIF
	lRet	:= .F.
ENDIF

Return(lRet)


USER FUNCTION VExtA01E()
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Valida a exclus„o da consulta
<Data> : 28/09/2016
<Parametros> : Nenhum
<Retorno> : LÛgico
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : V
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local lRet		:= .T.
Local cCons		:= U_VExtM01I("CONS")
Local cPreC		:= Iif(Left(cCons, 1) == "S", Substr(cCons, 2), cCons)
Local cPerm		:= U_VExtM01I("PERM")

(cPerm)->(DbSetOrder(1))
IF (cPerm)->(DbSeek(xFilial(cPerm) + (cCons)->(FieldGet(FieldPos(cPreC + "_CODIGO")))))
	Aviso("AtenÁ„o", "Existem permissıes cadastradas para esta consulta. Exclua antes as permissıes para depois excluir esta consulta!", {"OK"})
	lRet := .F.
ENDIF

Return lRet

USER FUNCTION VExtA01M()
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : Valida a digitaÁ„o do caminho de geraÁ„o dos arquivos da consulta
<Data> : 28/09/2016
<Parametros> : Nenhum
<Retorno> : LÛgico
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : V
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local lRet	:= .t.
Local cCons	:= U_VExtM01I("CONS")
Local cPreC	:= Iif(Left(cCons, 1) == "S", Substr(cCons, 2), cCons)

// Modo de execuÁ„o diferente de Manual e formato diferente de Banco de Dados
IF &("M->" + cPreC + "_MODOEX") # "1" .AND. &("M->" + cPreC + "_FORMAT") # "3" .AND. Empty(Alltrim(&("M->" + cPreC + "_CAMINH")))
	lRet	:= .f.
	Aviso("Path no Servidor", "Para modo de execuÁ„o 'Agendada' e formato de saÌda diferente de 'Tabela SGBD' È obrigatÛrio informar o 'Path no Servidor'" + ;
		"para gerar o arquivo de resultado.", {"Ok"})
ENDIF
Return(lRet)

USER FUNCTION VExtA01V(cCpo)
/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : ValidaÁ„o genÈricas de campos do cadastro de consutlas
<Data> : 28/09/2016
<Parametros> : Nenhum
<Retorno> : LÛgico
<Processo> : Extrator de dados
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : V
<Autor> : Marcelo Colato
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Local lRet		:= .T.
Local cCons		:= U_VExtM01I("CONS")
Local cPreC		:= Iif(Left(cCons, 1) == "S", Substr(cCons, 2), cCons)
Default cCPO	:= ""

IF cCPO = cPreC + "_PROPRI"
	IF &("M->" + cPreC + "_ACESS") == "2"
		IF !Empty(&("M->" + cPreC + "_PROPRI"))
			PswOrder(1)
			IF !PswSeek(&("M->" + cPreC + "_PROPRI"), .T.)
				Help( ,, 'Help',, "CÛdigo de usu·rio n„o localizado!", 1, 0) 
				lRet := .F.
			ELSE
				&("M->" + cPreC + "_NMPROP") := PswRet(1)[1][4]	
			ENDIF
		ELSE
			Help( ,, 'Help',, "Informe o usu·rio propriet·rio!", 1, 0) 
			lRet := .F.
		ENDIF
	ENDIF
ELSEIF cCPO = cPreC + "_ACESS"
	IF &("M->" + cPreC + "_ACESS") == "1"
		&("M->" + cPreC + "_PROPRI")	:= Space(TamSx3(cPreC + "_PROPRI")[1])				
		&("M->" + cPreC + "_NMPROP")	:= Space(TamSx3(cPreC + "_NMPROP")[1])						
	ENDIF
ENDIF

Return(lRet)