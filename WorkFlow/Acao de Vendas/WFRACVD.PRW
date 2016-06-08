#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE 'TBICONN.CH'

#IFNDEF CRLF
	#DEFINE CRLF ( CHR(13)+CHR(10) )
#ENDIF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³WFRACVD   ºAUTOR  ³CRISTIANO MACHADO   º DATA ³  01/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ENVIO AUTOMáTICO DO RELATóRIO ACAO DE VENDAS (RSIGV01)      º±±
±±º          ³ALTERADO PARA ENVIO DO RELACVD()                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ AP8 IMDEPA ROLAMENTOS                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*********************************************************************
USER FUNCTION WFRACVD()
*********************************************************************

//VERSAO OK PREPARE ENVIRONMENT EMPRESA "01" FILIAL "12" MODULO "FIN" USER "WORK" PASSWORD "WORK" TABLES "SUA","SUB","SA1","SB1","SF2","SD2","SF1","SD2","SF4","SA3","SD1"
// PREPARE ENVIRONMENT EMPRESA '01' FILIAL '12' FUNNAME 'WFRACVD' TABLES "SUA","SUB","SA1","SB1","SF2","SD2","SF1","SD2","SF4","SA3","SD1"

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "05" MODULO "FAT" USER "WORK" PASSWORD "WORK" TABLES "SUA"


	Men("Inicio de Execucao")

//| Parametro Para Rodar Retroativo
	If !Empty(Alltrim(GetMv("MV_DTWORKF")))
		dDatabase := Stod(GetMv("MV_DTWORKF"))
		Men("Execucao em Modo Retroativo")
	Endif


	PRIVATE  LRESULT  := .F.

	DBSELECTAREA("SX5")
	IF DBSEEK(xFILIAL("SX5")+"ZI",.F.)

		WHILE !EOF() .AND. SX5->X5_TABELA == "ZI"

			CCHAVE := SX5->X5_CHAVE
			NRECNO := RECNO("SX5")


			IF FILE( "\WORKFLOW\" + CCHAVE+".TXT" )
				FERASE( "\WORKFLOW\" + CCHAVE+".TXT" )
				Men("Apagando Arquivo \WORKFLOW\" + CCHAVE+".TXT" )
			ENDIF

		//AJUSTA OS PARAMETROS ....
			IF !AJUSTAPAR(CCHAVE)
				DBSELECTAREA("SX5")
				DBSKIP()
				LOOP
			ENDIF

		//COMPLETA ENDERECOS DE E-MAIL COM @IMDEPA.COM.BR
			CEMAILS := COMPLEMAIL(ALLTRIM(MV_PAR30))

		//GERA O RELATORIO ACAO DE VENDAS CONFORME PARAMETROS PRE CADASTRADOS
		//U_RSIGV01("W")

			Men("Disparando Execucao  U_RELACVD('W')")

			U_RELACVD("W")

			Men("Fim Execucao  U_RELACVD('W')")

			Men("Buscando Arquivo contido no Diretorio '\RELATO\WORKFLOW\ ")
		 //Cristiano - Inico
			cChave := Substr(dtos(dDatabase) + StrTran(Time(),':',''),1,12)
			aFiles := Directory('\RELATO\WORKFLOW\' + '*.spl')

			For n :=1 To Len(aFiles)

				If Substr(dTos(aFiles[n][3]) + StrTran(aFiles[n][4],':',''),1,12) == cChave
					aFile := 	aFiles[n][1]
					exit
				EndIF
			Next

			Men("Renomeando Arquivo '\RELATO\WORKFLOW\"+aFile+" para \RELATO\WORKFLOW\RELACVD.##R' ")
			fRename( '\RELATO\WORKFLOW\' + aFile , '\RELATO\WORKFLOW\RELACVD.##R' )


		 // Cristiano - Fim
			DBSELECTAREA("SX5")
			DBGOTO(NRECNO)
//		FRENAME("\RELATO\ROSE\RSIGVG.##R","\WORKFLOW\"+CCHAVE+".TXT")
//		FRENAME("\RELATO\ROSE\RELACVD.##R","\WORKFLOW\"+CCHAVE+".TXT")

//		FRENAME("\RELATO\MARCIO\RELACVD.##R","\WORKFLOW\"+CCHAVE+".TXT")
			Men("Renomeando Arquivo \RELATO\WORKFLOW\RELACVD.##R' para \WORKFLOW\"+CCHAVE+".TXT" )
			FRENAME("\RELATO\WORKFLOW\RELACVD.##R","\WORKFLOW\"+CCHAVE+".TXT")

		//ENVIA RELATORIO PARA USUARIOS CADASTRADOS NO PARAMETRO
			Men("Enviando relatório para "+CCHAVE)
			WFSEND2(CCHAVE)
			Men("Apagando arquivo \WORKFLOW\"+CCHAVE+".TXT")
			FERASE("\WORKFLOW\"+CCHAVE+".TXT")

			DBSELECTAREA("SX5")
			DBSKIP()

		ENDDO

	ENDIF

//RESET ENVIRONMENT

RETURN()
*********************************************************************
STATIC FUNCTION AJUSTAPAR(CGRUPO)
*********************************************************************
	CGRUPO := CGRUPO + SPACE(4)
	PERGUNTE(CGRUPO,.F.)

//SX1->(DBSEEK(SX5->X5_CHAVE+"31",.F.))
	SX1->(DBSEEK(CGRUPO+"01",.F.))
	FOR i := 1 TO 31

		IF i == 1 .OR. i == 2
			&("MV_PAR"+STRZERO(i,2)) := VAL(ALLTRIM(SX1->X1_CNT01))
		ELSEIF i == 31
			&("MV_PAR"+STRZERO(i,2)) := VAL(ALLTRIM(SX1->X1_CNT01))
			LOOP
		ELSE
			&("MV_PAR"+STRZERO(i,2)) := ALLTRIM(SX1->X1_CNT01)
		ENDIF

		SX1->(DBSKIP())
	NEXT

	DO CASE

	CASE MV_PAR31 == 1 // EXECUTA SOMENTE O DIA ANTERIOR

		IF UPPER(CDOW(DDATABASE)) == "MONDAY"
			MV_PAR11 := MV_PAR12 := (DDATABASE - 2)
		ELSE
			MV_PAR11 := MV_PAR12 := (DDATABASE - 1)
		ENDIF

	CASE MV_PAR31 == 2 // EXECUTA DO DIA 1 ATE O DIA ANTERIOR DO MES CORRENTE

		IF SUBSTR(DTOS(DDATABASE),7,2) = "01"

			MV_PAR11 := CTOD("01"+SUBSTR(DTOC(DDATABASE - 1),3) )
			MV_PAR12 := (DDATABASE - 1)

		ELSE

			MV_PAR11 := CTOD("01/"+SUBSTR(DTOS(DDATABASE),5,2)+"/"+SUBSTR(DTOS(DDATABASE),1,4))

			IF UPPER(CDOW(DDATABASE)) == "MONDAY"

				IF VAL(SUBSTR(DTOS(DDATABASE),7,2)) > 2

					MV_PAR12 := (DDATABASE - 2)

				ELSE

					MV_PAR12 := DDATABASE

				ENDIF

			ELSE
				MV_PAR12 := (DDATABASE - 1)
			ENDIF

		ENDIF

	CASE MV_PAR31 == 3 // EXECUTA A SEMANA ANTERIOR SOMENTE NAS SEGUNDAS FEIRAS...DEVE ENVIAR

		IF UPPER(CDOW(DDATABASE)) == "MONDAY"
			MV_PAR11 := (DDATABASE - 7)
			MV_PAR12 := (DDATABASE - 2)
		ELSE
			RETURN(.F.)
		ENDIF

	CASE MV_PAR31 == 4 // EXECUTA DO DIA 1 DE JANEIRO ATE MES ANTERIOR ...DEVE ENVIAR SO DIA 1 DE CADA MES

		IF SUBSTR(DTOS(DDATABASE),7,2) == "01"

			IF SUBSTR(DTOS(DDATABASE),5,4) == "0101"
				MV_PAR11 := CTOD("01/01/"+SUBSTR(DTOS(DDATABASE-1),1,4))
			ELSE
				MV_PAR11 := CTOD("01/01/"+SUBSTR(DTOS(DDATABASE),1,4))
			ENDIF

			MV_PAR12 := (DDATABASE - 1)
		ELSE

			RETURN(.F.)

		ENDIF

	ENDCASE

RETURN(.T.)

*********************************************************************
STATIC FUNCTION WFSEND2(CANEXO)
*********************************************************************
	LOCAL CSERVER  := GETMV('MV_RELSERV')	// Nome do Servidor de E-mail
	LOCAL CUSER    := GETMV('MV_RELACNT')	// Conta a ser usada no envio do E-mail. protheus@imdepa.com.br
	LOCAL CPASS    := GETMV('MV_RELPSW')   // Senha de Autentificacao do E-mail
	LOCAL LAUTH    := GETMV("MV_RELAUTH")	// Se servidor de e-mail necessita de autentificacao
	LOCAL CHTML

	PRIVATE CERROR    := ""
	PRIVATE CPASS     := SPACE(25)

	cHtml := '<html>'
	cHtml += '<head>'
	cHtml += '<title>AÇÃO DE VENDAS</title>'	+ CRLF
	cHtml += '<h3 align=Left>AÇÃO DE VENDAS</h3>'+ CRLF
	cHtml += '</head>'
	cHtml += '<body bgcolor=white text=black  >'
	cHtml += '<hr width=100% noshade>' + CRLF

	cHtml += '<font size="3" face="Courier">Processamento :</font>'+'<b><font size="3" face="Courier">Automático</font></b>'+ CRLF
	cHtml += '<font size="3" face="Courier">Processado em :</font>'+'<b><font size="3" face="Courier">'+Dtoc(DDATABASE)+' às '+Time()+'</font></b>'+ CRLF+CRLF

	cHtml += '<font size="4" color="#23238E"><b>Prezados srs. !  </b></font>'+ CRLF+ CRLF
	cHtml += '<font size="3" color="#23238E"><b>Vamos analisar o relatorio em Anexo </b></font>'+ CRLF
	cHtml += '<font size="3" color="#23238E"><b>Atenciosamente</b></font>'+ CRLF
	cHtml += '<font size="3" color="#23238E"><b>Diretor Comercial</b></font>'+ CRLF

	cHtml += '</body>'
	cHtml += '</html>'
	cHtml += CRLF

	CENVIA 		:= "ROSE@IMDEPA.COM.BR"
	CMENSAGEM 	:= "RELATóRIO DE ACAO DE VENDAS"
	CSUBJECT 	:= "ACAO DE VENDAS"
	NI        	:= 1
	N 			:= 1
	CPATHARQ := "\WORKFLOW\"+CANEXO+".TXT"

	ALISTA := {}
//teste
//CEMAILS:='edivaldo@imdepa.com.br'
//teste

	AADD( ALISTA, CEMAILS )

	CSERVER	:= GETMV("MV_RELSERV")
	CCONTA 	:= GETMV("MV_RELACNT")
	CPASS  	:= GETMV("MV_RELPSW")

	CONNECT SMTP SERVER CSERVER ACCOUNT CUSER PASSWORD CPASS RESULT LRESULT
	IF LRESULT .AND. LAUTH
		LRESULT := MAILAUTH(CUSER,CPASS)
		IF !LRESULT
		//LRESULT := QADGETMAIL() // FUNCAO QUE ABRE UMA JANELA PERGUNTANDO O USUARIO E SENHA PARA FAZER AUTENTICACAO
			LRESULT := MAILAUTH(CUSER,CPASS)
		ENDIF
		IF !LRESULT
		//ERRO NA CONEXAO COM O SMTP SERVER
			GET MAIL ERROR CERROR
			Men("ERRO DE AUTENTICACAO DE E-MAIL "+CERROR)
			RETURN NIL
		ENDIF
	ELSE
		IF !LRESULT
		//ERRO NA CONEXAO COM O SMTP SERVER
			GET MAIL ERROR CERROR
			Men("ERRO DE CONEXAO NO ENVIO DE E-MAIL: "+CERROR)
			RETURN NIL
		ENDIF
	ENDIF

	SEND MAIL FROM CCONTA TO ALISTA[1]  ;
		BCC     	"";
		SUBJECT 'ACAO DE VENDAS'                    ;
		BODY CHTML ;
		ATTACHMENT  '\WORKFLOW\'+CANEXO+'.TXT'
	DISCONNECT SMTP SERVER

  Men("ENVIANDO E-MAIL PARA "+ALISTA[1])

RETURN()
*********************************************************************
STATIC FUNCTION COMPLEMAIL(CDESTINO)
*********************************************************************
	cUserEmail:= cNome	:= ""
	cEviarPara 	:= CDESTINO

	WHILE LEN(cEviarPara) > 0
		IIF(AT(",",cEviarPara)>0,cNome := SUBSTR(cEviarPara,1,AT(",",cEviarPara)-1),cNome := cEviarPara)
		cUserEmail +=   cNome+IIF(AT("@",cNome) == 0,"@IMDEPA.COM.BR,", ",")
		IIF(AT(",",cEviarPara)>0, cEviarPara := SUBSTR(cEviarPara,AT(",",cEviarPara)+1,LEN(cEviarPara)), cEviarPara := ""  )
		cNome 	   := ""
	ENDDO

	cUserEmail := SUBSTR(cUserEmail,1,LEN(cUserEmail)-1)
	cUserEmail += ","+ALLTRIM(GETMV("MV_ECONTTI")) // E-mail de controle da TI

RETURN(cUserEmail)

*******************************************************************************
Static Function Men(cTexto)
*******************************************************************************
Local cData := dToC(dDataBase)
Local cTime := Time()
Local cMenP := "WFRACVD - Acao de Vendas : " + cTexto + Replicate(".",100-Len(cTexto)) + " " + cData + " " + cTime

Conout ( cMenP )

Return()


/*
CEMAILS := ""
FOR I := 1 TO LEN(CDESTINO)
	IF SUBSTR(CDESTINO,I,1) <> ','
		CEMAILS += SUBSTR(CDESTINO,I,1)
	ELSEIF SUBSTR(CDESTINO,I,1) == ','
		CEMAILS += "@IMDEPA.COM.BR,"
	ENDIF
NEXT

IF SUBSTR(CEMAILS,LEN(CEMAILS),1) == ","
	CEMAILS := SUBSTR(CEMAILS,1,LEN(CEMAILS)-1)
ENDIF
*/
//CEMAILS += ",EDIVALDO@IMDEPA.COM.BR,LUIZ.FRANCESCHINI@IMDEPA.COM.BR,MENNA@IMDEPA.COM.BR"
//CONOUT('PROCESSANDO E-MAIL PARA '+CEMAILS)
//CEMAILS := "CRISTIANOSM@GMAIL.COM"
//CEMAILS += ",EDIVALDO@IMDEPA.COM.BR,MENNA@IMDEPA.COM.BR"

//RETURN(CEMAILS)