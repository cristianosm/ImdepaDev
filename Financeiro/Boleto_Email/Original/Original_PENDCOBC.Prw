#INCLUDE 'rwmake.ch'
#INCLUDE 'tbiconn.ch'
#INCLUDE 'topconn.ch'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FILEIO.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPENDCOBC  บAutor  ณ   AGOSTINHO LIMA   บ Data ณ  18/01/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGERA RELATORIO DE PENDENCIAS DE COBRANCA PARA OS CLIENTES   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8 IMDEPA ROLAMENTOS - FINANCEIRO                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*********************************************************************
User Function PENDCOBC(nFreq)
*********************************************************************

	LOCAL aDIAPEND   := {}
	LOCAL aDIAPEND1  := {}
	LOCAL cDIAPEND
	LOCAL aLink      := {}
	LOCAL aLink01    := {}

	PRIVATE cHtml     := ""
	PRIVATE cHtmlc    := ""
	PRIVATE cHtmld    := ""
	PRIVATE cHtmlr    := ""

	PRIVATE cEMailfin := ""
	PRIVATE cEMailcli := ""
	PRIVATE cDescRel  := ""
	PRIVATE cLink     := ""
	PRIVATE cBanco    := ""

	Prepare Environment Empresa '01' Filial '09' FunName 'PENDCOBF' Tables 'SE1','SA1'

	cDIAPEND  := ALLTRIM(GETMV("MV_DIAPFIN"))

	aDIAPEND1 := &cDIAPEND

	aDIAPEND  := aDIAPEND1[nFreq[1,1]]

	cEMailfin  := aDIAPEND[5]
	cDescRel:= "Pendencias Financeiras"

	cQuery := "SELECT E1_CLIENTE,E1_LOJA,E1_NOMCLI,A1_PESSOA,A1_CGC,A1_DDD,A1_TEL,A1_EMAIL,A1_MAILFIN,A1_MAILNFE,E1_PORTADO,E1_AGEDEP,E1_CONTA,E1_NUMBCO,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_EMISSAO,E1_VENCTO,"
	cQuery += "E1_SALDO,E1_FILORIG,TRUNC(SYSDATE) - TO_DATE(E1_VENCTO,'YYYYMMDD') ATRASO, "

	cQuery += " (SELECT SUM(E1_SALDO) FROM " + RetSqlName("SE1") + " E1 "
	cQuery += " WHERE E1.D_E_L_E_T_ = ' ' "
	cQuery += " AND E1.E1_CLIENTE = SE1.E1_CLIENTE  AND E1.E1_LOJA = SE1.E1_LOJA "
	cQuery += " AND E1.E1_FILIAL = ' ' AND E1.E1_EMISSAO <> E1.E1_VENCTO "

	IF VAL(aDIAPEND[2]) > 0
		cQuery += " AND E1.E1_VENCTO < '"+DTOS(DDATABASE)+"'
	ELSE
		cQuery += " AND E1.E1_VENCTO > '"+DTOS(DDATABASE)+"'
	ENDIF

	cQuery += " AND E1.E1_SALDO > 0 AND E1.E1_TIPO IN  "+GETMV("MV_TIPOATR")
	cQuery += " AND TRUNC(SYSDATE) - TO_DATE(E1.E1_VENCTO,'YYYYMMDD')  "+aDIAPEND[1]+aDIAPEND[2]+"   "
	cQuery += " AND TRUNC(SYSDATE) - TO_DATE(E1.E1_VENCTO,'YYYYMMDD')  "+aDIAPEND[3]+aDIAPEND[4]+"   "
	cQuery += " ) TOTSALCLI "

	cQuery += " FROM " + RetSqlName("SE1") + " SE1, " + RetSqlName( "SA1" ) + " SA1 "
	cQuery += " WHERE  SE1.D_E_L_E_T_  = ' ' AND SA1.D_E_L_E_T_  = ' ' "
	cQuery += " AND E1_FILIAL = ' ' AND A1_FILIAL = ' ' "

//	cQuery += " AND E1_CLIENTE IN('026068','029020') "

	cQuery += " AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA "
	cQuery += " AND E1_EMISSAO <> E1_VENCTO "

	IF VAL(aDIAPEND[2]) > 0
		cQuery += " AND E1_VENCTO <  '"+DTOS(DDATABASE)+"'
	ELSE
		cQuery += " AND E1_VENCTO > '"+DTOS(DDATABASE)+"'
	ENDIF

	cQuery += " AND E1_SALDO > 0 "
	cQuery += " AND E1_TIPO IN  "+GETMV("MV_TIPOATR")

	cQuery += " AND TRUNC(SYSDATE) - TO_DATE(E1_VENCTO,'YYYYMMDD')  "+aDIAPEND[1]+aDIAPEND[2]+"   "
	cQuery += " AND TRUNC(SYSDATE) - TO_DATE(E1_VENCTO,'YYYYMMDD')  "+aDIAPEND[3]+aDIAPEND[4]+"   "

	cQuery += " GROUP BY E1_CLIENTE , E1_LOJA , E1_NOMCLI, A1_PESSOA ,A1_CGC , A1_DDD, A1_TEL, A1_MAILFIN, A1_MAILNFE, A1_EMAIL, E1_PORTADO, E1_AGEDEP, E1_CONTA, E1_NUMBCO, E1_PREFIXO , E1_NUM , "
	cQuery += " E1_PARCELA , E1_EMISSAO, E1_VENCTO, E1_SALDO, E1_FILORIG "

	cQuery += " ORDER BY TOTSALCLI DESC, ATRASO DESC "

	TCQUERY cQuery NEW ALIAS ("PEND1")


	IF ! (PEND1->( bof() ) .AND. PEND1->( eof() ))
	
		cHtmlc:='<html><body>'
		cHtmlr:='</html></body>'
	
		cHtml += cHtmlc
	
		WHILE !EOF()
		
			cHtmld:='<table border="0" width="600">'  // Formato para envio para o cliente
		
			cHtmld+='<tr valign = "middle" bgcolor="#FF7575">'
		
			cHtmld+='<td colspan = "3" align="center"><font size = "2" face="Verdana"><b>'+ALLTRIM(Transform(PEND1->A1_CGC,LEFT(PicPes(PEND1->A1_PESSOA),LEN(PicPes(PEND1->A1_PESSOA))-2)))+'</b></font></td>'
			cHtmld+='<td colspan = "6" align="center"><font size = "2" face="Verdana"><b>'+ALLTRIM(PEND1->E1_NOMCLI)+'</b></font></td>'
			cHtmld+='<td colspan = "2" align="center"><font size = "2" face="Verdana"><b>'+ALLTRIM("("+RIGHT(ALLTRIM(PEND1->A1_DDD),2)+") "+PEND1->A1_TEL)+'</b></font></td>'
		
			cHtmld+='</tr>'
		
			cHtmld+='<tr bgcolor="#E2E2E2">'
		
			cHtmld+='<th align="center"><font size = "2" face="Arial"><b>Filial</b></font></td>'
			cHtmld+='<th align="center"><font size = "2" face="Arial"><b>Qt Dias Atraso</b></font></td>'

			cHtmld+='<th align="center"><font size = "2" face="Arial"><b>Banco</b></font></td>'
			cHtmld+='<th align="center"><font size = "2" face="Arial"><b>Agencia</b></font></td>'
			cHtmld+='<th align="center"><font size = "2" face="Arial"><b>Conta</b></font></td>'
			
			cHtmld+='<th align="center"><font size = "2" face="Arial"><b>Nosso Numero</b></font></td>'
			cHtmld+='<th align="center"><font size = "2" face="Arial"><b>Nota Fiscal</b></font></td>'
			cHtmld+='<th align="center"><font size = "2" face="Arial"><b>Numero Titulo</b></font></td>'
			cHtmld+='<th align="center"><font size = "2" face="Arial"><b>Emissao</b></font></td>'
			cHtmld+='<th align="center"><font size = "2" face="Arial"><b>Vcto</b></font></td>'
			cHtmld+='<th align="center"><font size = "2" face="Arial"><b>Valor em Atraso</b></font></td>'
		
			cHtmld+='</tr>'
		
			nTOTCLI  := 0
			cCLIE    := PEND1->E1_CLIENTE+PEND1->E1_LOJA
			cCORLIN  := "2"
			cEMailcli:= IF(!EMPTY(PEND1->A1_MAILFIN),ALLTRIM(PEND1->A1_MAILFIN),IF(!EMPTY(PEND1->A1_MAILNFE),ALLTRIM(PEND1->A1_MAILNFE),ALLTRIM(PEND1->A1_EMAIL)))
			WHILE cCLIE = PEND1->E1_CLIENTE+PEND1->E1_LOJA
			
				aLink01  := ALLTRIM(SUPERGETMV("MV_LINK"+PEND1->E1_PORTADO,.F.," "))
				IF !EMPTY(aLink01)
					aLink  := &aLink01
					cLink  := aLink[1]
					cBanco := aLink[2]
				ELSE
					cLink  := " "
					cBanco := ALLTRIM(POSICIONE("SA6",1,XFILIAL("SA6")+PEND1->E1_PORTADO,"A6_NOME"))
				ENDIF
			
				cCORLIN := IF(cCORLIN = "1","2","1")
			
				cHtmld+='<tr nowrap align="center" bgcolor='+IF(cCORLIN = "1","white","#E2E2E2")+'>'
			
				cHtmld+='<td><font size="2" face="Arial">'+PEND1->E1_FILORIG+"-"+POSICIONE("SM0",1,cEmpAnt+PEND1->E1_FILORIG,"M0_FILIAL")+'</font></td>'
				cHtmld+='<td><font size="2" face="Arial">'+STR(PEND1->ATRASO)+'</font></td>'
			
				IF !EMPTY(cLink)
					cHtmld+='<td><font size="2" face="Arial"><a href="'+ cLink +'">'+ cBanco +'</a></font></td>'
				ELSE
					cHtmld+='<td><font size="2" face="Arial">'+ cBanco +'</font></td>'
				ENDIF

				cHtmld+='<td><font size="2" face="Arial">'+PEND1->E1_AGEDEP+'</font></td>'
				cHtmld+='<td><font size="2" face="Arial">'+PEND1->E1_CONTA+'</font></td>'
			
				cHtmld+='<td><font size="2" face="Arial">'+IF(PEND1->E1_PORTADO <> "237",PEND1->E1_NUMBCO,SUBSTR(PEND1->E1_NUMBCO,1,LEN(ALLTRIM(PEND1->E1_NUMBCO))-1))+'</font></td>'
				cHtmld+='<td><font size="2" face="Arial">'+PEND1->E1_NUM+'</font></td>'
				cHtmld+='<td><font size="2" face="Arial">'+PEND1->E1_PREFIXO+PEND1->E1_NUM+PEND1->E1_PARCELA+'</font></td>'
				cHtmld+='<td><font size="2" face="Arial">'+RIGHT(PEND1->E1_EMISSAO,2)+"/"+SUBSTR(PEND1->E1_EMISSAO,5,2)+"/"+LEFT(PEND1->E1_EMISSAO,4)+'</font></td>'
				cHtmld+='<td><font size="2" face="Arial">'+RIGHT(PEND1->E1_VENCTO,2)+"/"+SUBSTR(PEND1->E1_VENCTO,5,2)+"/"+LEFT(PEND1->E1_VENCTO,4)+'</font></td>'
				cHtmld+='<td><font size="2" face="Arial">'+TRANSFORM(PEND1->E1_SALDO,'@E 999,999,999.99')+'</font></td>'
			
				cHtmld+='</tr>'
			
				nTOTCLI := nTOTCLI + PEND1->E1_SALDO
			
				IF !EMPTY(cEMailcli) .AND. GETMV("MV_ENVPCLI")
				
					DBSELECTAREA("SE1")
					DBSETORDER(2)
					IF DBSEEK(XFILIAL("SE1")+cCLIE+PEND1->E1_PREFIXO+PEND1->E1_NUM+PEND1->E1_PARCELA)
						RecLock("SE1",.F.)
						SE1->E1_DEMACOB := DDATABASE
						MsUnlock()
					ENDIF
					DbSelectArea("PEND1")
				
				ENDIF
			
				DBSKIP()
			ENDDO
		
			cHtmld+='<tr nowrap align="center" >'
		
			cHtmld+='<td colspan = "10" nowrap align="center">'+" "+'</td>'
		
			cHtmld+='<td  bgcolor="#FF7575"><font size="2" face="Arial"><b>'+Transform(nTOTCLI,'@E 999,999,999.99')+'</b></font></td>'
		
			DbSelectArea("PEND1")
		
			cHtmld+='</tr>'
		
			cHtmld+='</table>'
		
			cHtmld+='<br>'
		
			IF !EMPTY(cEMailcli) .AND. GETMV("MV_ENVPCLI")
			
				cHtmlCli := cHtmlc + '<pre width="800"><IMG SRC="http://www.gbrparts.com.br/Ass/logo.gif" align="middle">'
				cHtmlCli += '<font face="Arial"><b>&nbsp;&nbsp;&nbsp;&nbsp;Imdepa Rolamentos Importa&ccedil;&atilde;o e Com&eacute;rcio LTDA</b></font></pre><br>'
				cHtmlCli += '<pre><font face="Arial">Porto Alegre, ' + RIGHT(DTOS(DDATABASE),2) + ' de ' + MES(DDATABASE) + ' de ' + LEFT(DTOS(DDATABASE),4)+'.<font></pre>'
				cHtmlCli += '<pre width="800"><font face="Arial">Prezados Senhores:<br>'
				cHtmlCli += 'Constam em aberto em nossos controles as duplicatas abaixo relacionadas:</font></pre><br>'
				cHtmlCli +=  cHtmld
				cHtmlCli += '<pre width="800"><font face= "Arial" ><b>Dados Cedente: 88.613.922/0012-78 Imdepa Rolamentos.</b></font></pre>'
				cHtmlCli += '<pre width="800"><font face= "verdana" color="red"><b>SE O PAGAMENTO J&Aacute; FOI EFETUADO, FAVOR DESCONSIDERAR ESTE E-MAIL.</b></font></pre>'
				cHtmlCli += '<pre width="800"><p><font face="Arial">Em caso de necessidade de segunda via de boleto favor</font><font face= "verdana" color="blue">&nbsp;CLICAR NO NOME DO BANCO</font><font face="Arial">, para emiss&atilde;o da duplicata <br>'
				cHtmlCli += 'ou efetuar a solicita&ccedil;&atilde;o  para boletos@imdepa.com.br,<br>'
				cHtmlCli += 'ou entre em contato conosco pelo telefone (51) 21210025</font>.</pre>'
				cHtmlCli += '<pre width="800"><font face="Arial">Atenciosamente,</pre>'
				cHtmlCli += '<pre width="800">Imdepa Rolamentos<br>'
				cHtmlCli += 'Departamento Financeiro</font></p></pre>'
			
				cHtmlCli += cHtmlr
			
				MAILPEND(cHtmlCli,cEMailcli)
			
			
			ENDIF
		
		ENDDO
	
	
	ENDIF

	dbCloseArea("PEND1")

	Conout("FIM DO PENDCOBC!")

RETURN()


Static Function MAILPEND(cHtmlenv,cEMailenv)

	Local cServer     := GetMV('MV_RELSERV')
	Local cUser       := cEMailfin
	Local cPass       := GetMV('MV_RELPSW')
	Local lAuth       := Getmv("MV_RELAUTH")
	Local cTO         := cEMailenv
//	Local cTO         := "agostinho.lima@imdepa.com.br"
	Local cCopia      := ALLTRIM(GETMV("MV_ECONTTI"))
	Local lResult     := .F.
	Local cError

	CONNECT SMTP SERVER cServer ACCOUNT cUser PASSWORD cPass RESULT lResult

// fazendo autenticacao
	If lResult .And. lAuth
		lResult := MailAuth(cUser,cPass)
		If !lResult
			lResult := QADGetMail() // Funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
		EndIf
		If !lResult
		//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			MsgInfo("Erro de Autenticacao no Envio de e-mail: "+cError)
			Return Nil
		Endif
	
	EndIf


	SEND MAIL FROM cUser ;
		TO cTo ;
		BCC cCopia ;
		SUBJECT cDescRel;
		BODY cHtmlenv;
		RESULT lResult

	If ! lResult
	//Erro no envio do email
		GET MAIL ERROR cError
		Msginfo("Erro no envio de e-mail: "+cError)
	EndIf


	DISCONNECT SMTP SERVER

Return()



