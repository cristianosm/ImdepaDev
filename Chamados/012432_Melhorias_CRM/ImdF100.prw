#Include 'tbiconn.ch'
#IFNDEF CRLF
#DEFINE CRLF ( chr(13)+chr(10) )
#ENDIF

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : IMDF100     | AUTOR : Luciano Correa     | DATA : 30/04/2003   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Workflow para envio da agenda do vendedor                      **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente Imdepa Rolamentos                    **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
** Marcio Q. Borges|05/09/2007|Considerar todas as filiais cadastradas no    **
**                 |          |sistema sem necessidade de config. parametros **
**---------------------------------------------------------------------------**
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function ImdF100()
*******************************************************************************

	Local nI

	Private cServer 	:= " "
	Private cAccount 	:= " "
	Private cPassword	:= " "
	Private lAuth 		:= " "
	Private cAssunto 	:= " "
	Private cEmailTo 	:= " "
	Private cEmailBcc	:= " "
	Private cAnexo   	:= " "
	Private lResult  	:= .F.
	Private cError   	:= " "
	Private cBody		:= " "
	Private cHtml    	:= " "

	Private nArq, nRecNo

	Private aEmpImd := {}

	cEmp := '01'
	cFil := '09'
	// processa empresa por empresa
	//For nParam := 1 to Len( aParam[ 1 ] )

	//	Prepare Environment Empresa aParam[ 1, nParam ] Filial aParam[ 2, nParam ] FunName 'IMDRMV'  Tables 'SM0','SF4','SD2'
	Conout( 'IMDF100 -  VIA WORKFLOW - Preparando Environment Principal')
	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil FUNNAME 'IMDF100'  TABLES 'SM0','SA3', 'AD7', 'AD8'

	Conout(  'IMDF100 - Carregando Filiais' )
	aEmpImd := Empresas()

	Reset Environment

	CONOUT('IMDF100 - ' + str(LEN(aEmpImd)))

	FOR nI := 1 TO LEN(aEmpImd)

		cEmp := SUBSTR(aEmpImd[nI],1,2)
		cFil := SUBSTR(aEmpImd[nI],3,2)

		PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil FUNNAME 'IMDF100'  TABLES 'SM0','SA3', 'AD7', 'AD8'
		Conout( 'IMDF100 ' + cEmpAnt + '/' +cFilAnt + ' - Preparando Environment ...' )

		cServer 	:= GetMV("MV_RELSERV" )
		cAccount 	:= Alltrim(GETMV("MV_RELACNT"))
		cPassword 	:= Alltrim(GETMV("MV_RELPSW"))
		lAuth 		:= Getmv("MV_RELAUTH")

		/*
		// processa empresa por empresa
		For nI := 1 to Len( aParam[ 1 ] )

		Prepare Environment Empresa aParam[ 1, nI ] Filial aParam[ 2, nI ] FunName 'IMDF100' Tables 'SA3', 'AD7', 'AD8'

		Conout( 'IMDF100 ' + aParam[ 1, nI ] + '/' + aParam[ 2, nI ] + ' - Verificando Agenda ( CRM )...' )

		SM0->( dbSetOrder( 1 ) )
		SM0->( dbSeek( aParam[ 1, nI ] + aParam[ 2, nI ], .f. ) )
		*/

		Conout( 'IMDF100 ' + cEmpAnt + '/' +cFilAnt + ' - Verificando Agenda ( CRM )...' )

		SA3->( dbSetOrder( 1 ) )

		AD7->( dbOrderNickName( 'WFSTATUS' ) )
		AD7->( dbSeek( xFilial( 'AD7' ) + ' ', .t. ) )

		While AD7->( !eof() )  .and. AD7->AD7_FILIAL == xFilial( 'AD7' ) .And. AD7->AD7_WFST == ' '

			SA3->( dbSeek( xFilial( 'SA3' ) + AD7->AD7_VEND, .f. ) )

			cHtml := '<html>'	+ CRLF
			cHtml += '<head>'	+ CRLF
			//cHtml += '<p><img src="../images/cabecweb.jpeg" width="1060" height="100"></p>' + CRLF
			cHtml += '<title>Agenda do Vendedor</title>' + CRLF
			cHtml += '</head>' + CRLF

			//cHtml += '<body bgcolor=white text=black background="../images/marcadagua.jpg" align=center >' + CRLF
			cHtml += '<body bgcolor=white text=black  >' + CRLF
			cHtml += '<h3 align=center>Agenda do Vendedor ' + AllTrim( SA3->A3_NOME ) + '</h3>' + CRLF
			cHtml += '<br><hr>'

			cHtml += '<br> Filial :   '
			cHtml += '<b>' + SM0->M0_CODFIL + ' - ' + SM0->M0_FILIAL + '</b>' + CRLF

			cHtml += IncCampos( 'AD7' )

			cHtml += '<br><hr>'
			cHtml += '<br>' + SM0->M0_NOMECOM

			cHtml += '<br></a>' + CRLF
			cHtml += '<br> Microsiga Software S/A  -  Verificado em ' + DtoC( dDataBase ) + ' às ' + Time() + ' h </a>' + CRLF

			cHtml += '</body></html>' + CRLF

			If File( '\Workflow\ImdF100a.html')
				fErase( '\Workflow\ImdF100a.html' )
			EndIf

			nArq := fCreate( '\Workflow\ImdF100a.html' )
			fWrite( nArq, cHtml )
			fClose( nArq )

			/*
			oProcess          := TWFProcess():New( 'IMDF100', 'Agenda do Vendedor' )
			oProcess:NewTask( 'IMDF100', '\Workflow\ImdF100a.html' )
			oProcess:cSubject := 'Agenda Imdepa - ' + DtoC( dDataBase ) + ' ' + Time()
			oProcess:cTo      := UsrRetMail( SA3->A3_CODUSR )
			oProcess:cCC      := ''
			oProcess:cBCC     := ''
			//oProcess:cBody    := cMensagem
			oProcess:Start()
			*/

			cEmailTo 	:= UsrRetMail( SA3->A3_CODUSR )
			cEmailBcc := " "
			cAssunto	:= 'Agenda Imdepa - ' + DtoC( dDataBase ) + ' ' + Time()
			cBody		:= cHtml
			cAnexo	:= "" //'\Workflow\ImdF100a.html'

			EnviaEmail()

			AD7->( dbSkip() )
			nRecNo := AD7->( RecNo() )
			AD7->( dbSkip( -1 ) )

			AD7->( RecLock( 'AD7', .f. ) )
			AD7->AD7_WFST := 'S'
			AD7->( MsUnlock() )

			AD7->( dbGoTo( nRecNo ) )
		End

		//	Conout( 'IMDF100 ' + aParam[ 1, nI ] + '/' + aParam[ 2, nI ] + ' - Verificando Tarefas ( CRM )...' )

		Conout( 'IMDF100 ' + cEmpAnt + '/' +cFilAnt + ' - Verificando Tarefas ( CRM )...' )

		SA3->( dbSetOrder( 7 ) )

		AD8->( dbOrderNickName( 'WFSTATUS' ) )
		AD8->( dbSeek( xFilial( 'AD8' ) + ' ', .T. ) )

		While AD8->( !eof() )  .and. AD8->AD8_FILIAL == xFilial( 'AD8' ) .And. AD8->AD8_WFST == ' '

			SA3->( dbSeek( xFilial( 'SA3' ) + AD8->AD8_CODUSR, .f. ) )

			cHtml := '<html>'	+ CRLF
			cHtml += '<head>'	+ CRLF
			//cHtml += '<p><img src="../images/cabecweb.jpeg" width="1060" height="100"></p>' + CRLF
			cHtml += '<title>Tarefas do Vendedor</title>' + CRLF
			cHtml += '</head>' + CRLF

			//cHtml += '<body bgcolor=white text=black background="../images/marcadagua.jpg" align=center >' + CRLF
			cHtml += '<body bgcolor=white text=black  >' + CRLF
			cHtml += '<h3 align=center>Tarefas do Vendedor ' + AllTrim( SA3->A3_NOME ) + '</h3>' + CRLF
			cHtml += '<br><hr>'

			cHtml += '<br> Filial :   '
			cHtml += '<b>' + SM0->M0_CODFIL + ' - ' + SM0->M0_FILIAL + '</b>' + CRLF

			cHtml += IncCampos( 'AD8' )

			cHtml += '<br><hr>'
			cHtml += '<br>' + SM0->M0_NOMECOM

			cHtml += '<br></a>' + CRLF
			cHtml += '<br> Microsiga Software S/A  -  Verificado em ' + DtoC( dDataBase ) + ' às ' + Time() + ' h </a>' + CRLF

			cHtml += '</body></html>' + CRLF

			If File( '\Workflow\ImdF100b.html')
				fErase( '\Workflow\ImdF100b.html' )
			EndIf

			nArq := fCreate( '\Workflow\ImdF100b.html' )
			fWrite( nArq, cHtml )
			fClose( nArq )

			/*
			oProcess          := TWFProcess():New( 'IMDF100', 'Tarefas do Vendedor' )
			oProcess:NewTask( 'IMDF100', '\Workflow\ImdF100b.html' )
			oProcess:cSubject := 'Tarefas Imdepa - ' + DtoC( dDataBase ) + ' ' + Time()
			oProcess:cTo      := UsrRetMail( SA3->A3_CODUSR )
			oProcess:cCC      := ''
			oProcess:cBCC     := ''
			//oProcess:cBody    := cMensagem
			oProcess:Start()
			*/

			cEmailTo 	:= UsrRetMail( SA3->A3_CODUSR )
			cEmailBcc := " "
			cAssunto	:= 'Tarefas Imdepa - ' + DtoC( dDataBase ) + ' ' + Time()
			cBody		:= cHtml
			cAnexo	:= "" //'\Workflow\ImdF100b.html'

			EnviaEmail()

			AD8->( dbSkip() )
			nRecNo := AD8->( RecNo() )
			AD8->( dbSkip( -1 ) )

			AD8->( RecLock( 'AD8', .f. ) )
			AD8->AD8_WFST := 'S'
			AD8->( MsUnlock() )

			AD8->( dbGoTo( nRecNo ) )
		End

		//	Conout( 'IMDF100 ' + aParam[ 1, nI ] + '/' + aParam[ 2, nI ] + ' - Job executado com sucesso...' )
		Conout( 'IMDF100 ' + cEmpAnt + '/' +cFilAnt + '  - Job executado com sucesso...' )

		Reset Environment
	NEXT

	Return

*******************************************************************************
Static Function IncCampos( cAlias )
*******************************************************************************

	Local cCampo, cKey, cCBox, nCont
	Local cReturn := ''

	SYP->( dbSetOrder( 1 ) )
	SX3->( dbSetOrder( 1 ) )
	SX3->( dbSeek( cAlias, .f. ) )

	While SX3->( !eof() ) .and. SX3->X3_ARQUIVO == cAlias

		// verifica se o campo eh utilizado e o nivel...
		If !X3Uso( SX3->X3_USADO ) .or. cNivel < SX3->X3_NIVEL

			SX3->( dbSkip() )
			Loop
		EndIf

		If SX3->X3_TIPO == 'M'

			//cCampo := MSMM( &( SX3->X3_CAMPO ),,,, 3 )
			cCampo := ''
			cKey   := &( SX3->X3_ARQUIVO + '->' + Left( SX3->X3_CAMPO, 4 ) + 'CODMEM' )

			SYP->( dbSeek( xFilial( 'SYP' ) + cKey, .f. ) )

			While SYP->( !eof() )  .and. SYP->YP_FILIAL == xFilial( 'SYP' ) ;
			.and. SYP->YP_CHAVE  == cKey

				cCampo += SYP->YP_TEXTO

				SYP->( dbSkip() )
			End

		ElseIf SX3->X3_CONTEXT == 'V'

			cCampo := &( SX3->X3_INIBRW )
		Else
			cCampo := &( SX3->X3_ARQUIVO + '->' + SX3->X3_CAMPO )
		EndIf

		If !Empty( SX3->X3_CBOX )

			cCBox := AllTrim( SX3->X3_CBOX )
			While !Empty( cCBox )

				nCont := AT( ';', cCBox )

				If Left( cCBox, SX3->X3_TAMANHO ) == cCampo

					cCBox := AllTrim( SubStr( cCBox, 1, nCont-1 ) )
					Exit
				EndIf

				cCBox := AllTrim( SubStr( cCBox, nCont + 1 ) )
			End
			cCampo := cCBox
		EndIf

		// verifica se o campo esta preenchido...
		If Empty( cCampo )

			SX3->( dbSkip() )
			Loop
		EndIf

		cReturn += '<br>' + SX3->X3_TITULO + ':   '

		If SX3->X3_TIPO == 'N'

			cReturn += '<b>' + Transform( cCampo, SX3->X3_PICTURE ) + '</b>' + CRLF

		ElseIf SX3->X3_TIPO == 'D'

			cReturn += '<b>' + DtoC( cCampo ) + '</b>' + CRLF
		Else

			nCount := 1
			cCampo := StrTran( cCampo , '\13\10' , " " )
			nLENMemoLine	:= MLCOUNT(cCampo,100)
			FOR nCount := 1 to nLENMemoLine
				cSay := MEMOLINE(cCampo,100,nCount)

				cReturn += '<b>' + cSay + '</b>' + CRLF
			NEXT

			//cCampo := StrTran( cCampo , CRLF , " " )
			//cReturn += '<b>' + cCampo + '</b>' + CRLF
		EndIf

		SX3->( dbSkip() )
	End

Return cReturn
*******************************************************************************
Static Function EMPRESAS()
*******************************************************************************
	Local aEmpImd := {}

	/* Carga das filiais */
	
	dbSelectArea('SM0')
	dbSeek(cEmpAnt,.T.)
	recSM0      := SM0->( Recno() )

	While SM0->M0_CODIGO == cEmpAnt .and. !EOF()
		AADD(aEmpImd, SM0->M0_CODIGO+ SM0->M0_CODFIL)
		dbSkip()
	Enddo

	dbGoto( recSM0 )
Return aEmpImd
*******************************************************************************
Static Function EnviaEmail()
*******************************************************************************
	Conout('IMDF100 '  + " - Conectando com o Servidor de Email")
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

	If lResult .And. lAuth
		lResult := MailAuth(cAccount,cPassword)
		If !lResult
			lResult := QADGetMail() // Funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
		EndIf
		If !lResult
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			Conout('IMDF100 '  + " -  Erro de Autenticacao")
			//			MsgInfo(cError,OemToAnsi("Erro de Autenticacao"))
			Return Nil
		Endif
	Else
		If !lResult
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			Conout('IMDF100 '  + " - Erro de Conexao")
			//			MsgInfo(cError,OemToAnsi("Erro de Conexao"))
			Return Nil
		Endif
	EndIf

	// enviando e-mail
	If lResult
		Conout('IMDF100 '  + " - Enviando Email para " + cEmailTo + cEmailBcc )
		SEND MAIL FROM cAccount ;
		TO			cEmailTo ; //		BCC     	cEmailBcc ;
		CC     		cEmailBcc;
		SUBJECT 	cAssunto ;
		BODY    	cBody ;
		ATTACHMENT  cAnexo ;
		RESULT lResult

		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			Conout('IMDF100 '  + " - Nao Enviou Email - " + cError)
		EndIf
		//		DISCONNECT SMTP SERVER
	Endif
	DISCONNECT SMTP SERVER

Return