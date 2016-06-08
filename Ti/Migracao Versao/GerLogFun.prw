#INCLUDE "TOPCONN.CH"
#INCLUDE 'protheus.ch'
#INCLUDE 'tbiconn.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO3     บAutor  ณMicrosiga           บ Data ณ  07/27/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

*********************************************************************
User Function GerLogFun()
*********************************************************************
Local cEmp := '01'
Local cFil := '09'

Private cRet := "Executado Com Sucesso"
Private cMen := ""
Private lViaWorkFlow := .F.

If Type("dDatabase") == "U" // Se rodado via workflow a variแvel dDatabase estara disponivel somente apos o Prepare Environment
	lViaWorkFlow := .T.
Endif

If lViaWorkFlow

	Prepare Environment Empresa "01" Filial "05" FunName 'GerLogFun' Tables 'SM0'

Endif
	
cRet := U_ExecMySql( "SELECT * FROM MONFUN" , "" , "E" )

If cRet <> "Executado Com Sucesso"
	Gera_Tabela()
Else
	If lViaWorkFlow
		Controle()
	Else
		Processa( {||Controle()},"Aguarde...",cMen)
	Endif
Endif

If lViaWorkFlow

	Reset Environment

Endif

Return()
*********************************************************************
Static Function Gera_Tabela()
*********************************************************************

cSql := ""
cSql += "CREATE TABLE MONFUN AS "
cSql += "(SELECT  SYSDATE DTFUNCAO, "
cSql += "        SUBSTR(ACTION,1,(INSTR(ACTION,':')-1)) USUARIO, "
cSql += "        SUBSTR(ACTION,(INSTR(ACTION,'(')),INSTR(ACTION,'-') - INSTR(ACTION,'(')-1) FUNCAO "
cSql += " FROM V$SESSION b "
cSql += " WHERE ACTION IS NOT NULL "
cSql += " AND OSUSER = 'root' "
cSql += " AND SUBSTR(ACTION,(INSTR(ACTION,'(')),INSTR(ACTION,'-') - INSTR(ACTION,'(')-1) <> '()Main Window') "

U_ExecMySql( cSql , "" , "E" ) 

Return()
*********************************************************************
Static Function Controle()
*********************************************************************
Local cTime := GerTime()
ProcRegua(0)

While Time() < "20:00:00"

	If cTime == Time() 
		cMen := "Ultima Execucao as "+Time() 
		IncProc(cMen)
		cTime := GerTime()
		Atualiza(cMen)
	Endif

	IncProc(cMen)
	
EndDo

Return()          
*********************************************************************
Static Function GerTime()
*********************************************************************
nIntervalo := 1 //| Intervalo em Minutos

cHora 	:= Substr(Time(),1,2)

If (Val(Substr(Time(),4,2)) + nIntervalo) >= 60
	cMin := StrZero( Val( Substr( Time(),4,2 ) ) + nIntervalo - 60,2)
Else
	cMin := StrZero( Val( Substr( Time(),4,2 ) ) + nIntervalo     ,2)
Endif

cSeg	:=	Substr(time(),7,2)

cTime := cHora +":"+ cMin +":"+ cSeg

Return(cTime)
*********************************************************************
Static Function Atualiza()
*********************************************************************
cSql := ""
cSql += "INSERT INTO MONFUN (DTFUNCAO, USUARIO , FUNCAO) "
cSql += "(SELECT  SYSDATE DTFUNCAO, "
cSql += "        SUBSTR(ACTION,1,(INSTR(ACTION,':')-1)) USUARIO, "
cSql += "        SUBSTR(ACTION,(INSTR(ACTION,'(')),INSTR(ACTION,'-') - INSTR(ACTION,'(')-1) FUNCAO "
cSql += " FROM V$SESSION b "
cSql += " WHERE ACTION IS NOT NULL "
cSql += " AND OSUSER = 'root' "
cSql += " AND SUBSTR(ACTION,(INSTR(ACTION,'(')),INSTR(ACTION,'-') - INSTR(ACTION,'(')-1) <> '()Main Window' "
cSql += " AND NOT EXISTS(SELECT * FROM MONFUN A  "
cSql += "               WHERE A.FUNCAO = SUBSTR(ACTION,(INSTR(ACTION,'(')),INSTR(ACTION,'-') - INSTR(ACTION,'(')-1)) ) "

U_ExecMySql( cSql , "" , "E" )

Return()