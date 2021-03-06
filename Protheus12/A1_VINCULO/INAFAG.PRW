#INCLUDE "ap5mail.ch"
#INCLUDE "protheus.ch"
#INCLUDE "tbiconn.ch"

/*/
Programa : INAFAG.PRW
Autor    : JEAN REHERMANN
Data     : 30/01/11
Descri��o: Arquivo com os tickets v�lidos da campanha da INA-FAG - 2011
/*/

User Function INAFAG

	Local   _aSays	   := {}
	Local   _aButtons  := {}
	Local   _cCadastro := OemtoAnsi("Exporta��o de Dados - Campanha INA-FAG")
	Private lViaWorkFlow := Type("dDatabase") == "U"// Se rodar via workflow, dDatabase s� estara disponivel apos o Prepare Environment

	If lViaWorkFlow
		PREPARE ENVIRONMENT EMPRESA '01' FILIAL '09' FUNNAME 'INAFAG' TABLES 'SA1','SD2','SD1', 'SX6','SM0'
		Executar()
	Else
		AADD( _aSays,OemToAnsi("Esta rotina tem por finalidade efetuar a exporta��o de dados para arquivo de") )
		AADD( _aSays,OemToAnsi("texto, obedecendo layout espec�fico para a Campanha INA-FAG.                ") )
		   
		AADD( _aButtons, { 1, .T., { |o| Processa( { || Executar() }, "Exportar", "Preparando dados..." ) } } )
		AADD( _aButtons, { 2, .T., { |o| FechaBatch() } } )
	
		// Tela de apresenta��o do programa.
		FormBatch( _cCadastro, _aSays, _aButtons )
	Endif
		
Return Nil


//*************************************************************************************
// Jean Rehermann - 30/01/2011 - Fun��o principal do programa
//*************************************************************************************

Static Function Executar()

	Local _nSeq  := 1 
	Local _cArq  := _cQuery := _cEOL := _cLinha := ""
	Local _cTipo := _cData := _cNomeCli := _cProd := _cNfVen := _cNfDev := ""
	Local _cItem := _cQuant := _cCodCli := _cLojaCli := _cVlrUnit := _cVlrTot := ""
	Local _nRegs := 0
	Private _nHdl := -1
	
	_cEOL := "CHR(13)+CHR(10)"
    _cEOL := Trim( _cEOL )
    _cEOL := &_cEOL

	// Cria o arquivo especificado.
	_cArq := "\workflow\cupons.txt"
	_nHdl := MsFCreate( Alltrim( _cArq ), 0 )

	// Query para selecionar os registros.
	_cQuery := "SELECT "
	_cQuery += "A1_COD     AS CODCLI, "
	_cQuery += "A1_NOME    AS NOMECLI, "
	_cQuery += "A1_TEL     AS FONECLI, "
	_cQuery += "A1_EMAIL   AS MAILCLI, "
	_cQuery += "A1_GERVEN  AS GERCLI, "
	_cQuery += "A1_VEND    AS VENCLI, "
	_cQuery += "A1_CGC     AS CGCCLI, "
	_cQuery += "SUM(D2_QUANT*D2_PRCVEN) AS TOTAL "

	_cQuery += "FROM "+ RetSqlName("SD2") +" D2, "+ RetSqlName("SA1") +" A1, "+ RetSqlName("SB1") +" B1, "+ RetSqlName("SF4") +" F4 "

	_cQuery += "WHERE D2.D2_FILIAL IN ('02','04','05','06','07','09','12','13') "
	_cQuery += "AND D2.D2_EMISSAO   = TO_CHAR(SYSDATE-1,'yyyymmdd') "
//	_cQuery += "AND D2.D2_EMISSAO   BETWEEN TO_CHAR(SYSDATE-10,'yyyymmdd') and TO_CHAR(SYSDATE-1,'yyyymmdd') "
	_cQuery += "AND D2.D2_TIPO      = 'N' "
	_cQuery += "AND A1.A1_MSBLQL    <> '1' "
	_cQuery += "AND A1.A1_VINCIMD   IN ('R2','R9') "
	_cQuery += "AND B1.B1_GRMAR2    IN ('000001','000002') "
	_cQuery += "AND F4.F4_ESTOQUE   = 'S' "
	_cQuery += "AND F4.F4_DUPLIC    = 'S' "
	_cQuery += "AND A1.A1_COD       = D2.D2_CLIENTE "
	_cQuery += "AND A1.A1_LOJA      = D2.D2_LOJA "
	_cQuery += "AND B1.B1_FILIAL    = D2.D2_FILIAL "
	_cQuery += "AND B1.B1_COD       = D2.D2_COD "
	_cQuery += "AND F4.F4_FILIAL    = D2.D2_FILIAL "
	_cQuery += "AND F4.F4_CODIGO    = D2.D2_TES "
	_cQuery += "AND A1.D_E_L_E_T_   = ' ' "
	_cQuery += "AND B1.D_E_L_E_T_   = ' ' "
	_cQuery += "AND D2.D_E_L_E_T_   = ' ' "
	_cQuery += "AND F4.D_E_L_E_T_   = ' ' "

	_cQuery += "GROUP BY A1_COD, A1_NOME, A1_TEL, A1_EMAIL, A1_GERVEN, A1_VEND, A1_CGC "

	_cQuery := ChangeQuery( _cQuery )
	Iif( Select("TMPFAT") <> 0, TMPFAT->( dbCloseArea() ), ) // Verifico se a area n�o est� em uso.
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),"TMPFAT",.F.,.T.) // Crio a area.
	CONOUT("INAFAG - QUERY EXECUTADA" )

	If !lViaWorkFlow
		TMPFAT->( dbGoTop() )
		Count To _nRegs // Total de registros da query.
		TMPFAT->( dbGoTop() )
		ProcRegua( _nRegs )
	EndIf
	
	// Preparo a linha de cabe�alho para gravar
	_cLinha := "codigo_cliente;nome_cliente;telefone_cliente;mail_cliente;gerente_cliente;vendedor_cliente;faturamento_cliente;cnpj_cliente" + _cEOL
	// Gravo a linha de cabe�alho no arquivo
	FWrite( _nHdl, _cLinha )

	While !TMPFAT->( Eof() )

		_cLinha := ""
		
		_cCodCli := ALLTRIM( TMPFAT->CODCLI )
		_cVlrTot := STRZERO( ROUND( TMPFAT->TOTAL, 2 ) * 100, 15 )
		_cNome   := TMPFAT->NOMECLI
		_cFone   := TMPFAT->FONECLI
		_cMail   := TMPFAT->MAILCLI
		_cGeren  := TMPFAT->GERCLI
		_cVend   := TMPFAT->VENCLI
		_cCnpj   := TMPFAT->CGCCLI

		// Preparo a linha para gravar
		_cLinha := _cCodCli +";"+ _cNome +";"+ _cFone +";"+ _cMail +";"+ _cGeren +";"+ _cVend +";"+ _cVlrTot +";"+ _cCnpj + _cEOL
		// Gravo a linha no arquivo
		FWrite( _nHdl, _cLinha )
	
		If !lViaWorkFlow
			IncProc("Gerando Arquivo....( "+ StrZero( _nRegs, 6 ) +" registros )")
		EndIf
		TMPFAT->( dbSkip() )
	End

	TMPFAT->( dbCloseArea() ) // Fecho a area
	FClose( _nHdl ) // Fecho o arquivo
	CONOUT("INAFAG - ARQUIVO PROCESSADO E GERADO" )

	_cServer := GETMV("MV_RELSERV")
	_cConta  := GETMV("MV_RELACNT")
	_cPass   := GETMV("MV_RELPSW")
	_cUser   := GETMV('MV_RELACNT')
	_lAuth   := GETMV("MV_RELAUTH")

	CONNECT SMTP SERVER _cServer ACCOUNT _cUser PASSWORD _cPass RESULT _lResult

	IF _lResult .AND. _lAuth
		_lResult := MAILAUTH( _cUser, _cPass )
		IF !_lResult
			_lResult := MAILAUTH( _cUser, _cPass )
		ENDIF
		IF !_lResult
			GET MAIL ERROR _cErro
			CONOUT("INAFAG - ERRO DE AUTENTICACAO DE E-MAIL: "+ _cErro )
		ENDIF
	ELSE
		IF !_lResult
			GET MAIL ERROR _cErro
			CONOUT("INAFAG - ERRO DE CONEXAO NO ENVIO DE E-MAIL: "+ _cErro )
		ENDIF
	ENDIF
	CONOUT("INAFAG - CONECTADO AO SERVIDOR DE EMAILS" )
	
	
	// Enviar o arquivo para o ftp do portal. Em caso de erro o arquivo ser� enviado por e-mail.
	If FTPConnect( GETMV("MV_FTPWEB1"), GETMV("MV_FTPWEB2"), GETMV("MV_FTPWEB3"), GETMV("MV_FTPWEB4") ) // Conectar no FTP
		CONOUT("INAFAG - CONECTADO NO FTP DO PORTAL" )

		If FTPDirChange('web/import') // Selecionar o diret�rio no FTP
			CONOUT("INAFAG - DIRETORIO REMOTO SELECIONADO")
			
			If FTPUpload( '\workflow\cupons.txt', 'cupons.txt' ) // Fazer upload no arquivo no diret�rio selecionado no FTP
				CONOUT("INAFAG - ARQUIVO ENVIADO COM SUCESSO PARA O PORTAL")
				SEND MAIL FROM _cConta;
				TO GETMV("MV_FTPWEB5");
				SUBJECT 'Portal Imdepa - Arquivo enviado com sucesso';
				BODY 'O arquivo foi gerado e enviado com sucesso para o portal.'
				DISCONNECT SMTP SERVER
				
				// Grava no parametro a data processada
				PutMV( "MV_PROCTIK", dDataBase )

			Else
				CONOUT("INAFAG - FALHA NO ENVIO DO ARQUIVO PARA O PORTAL, SEGUE POR EMAIL")
				SEND MAIL FROM _cConta;
				TO GETMV("MV_FTPWEB5");
				SUBJECT 'Portal Imdepa - Falha no upload';
				BODY 'Houve falha no upload do arquivo. O arquivo segue em anexo.';
				ATTACHMENT  '\workflow\cupons.txt'
				DISCONNECT SMTP SERVER

			EndIf

		Else
			CONOUT("INAFAG - FALHA AO SELECIONAR DIRETORIO REMOTO, SEGUE POR EMAIL")
			SEND MAIL FROM _cConta;
			TO GETMV("MV_FTPWEB5");
			SUBJECT 'Portal Imdepa - Falha no diret�rio';
			BODY 'N�o foi poss�vel selecionar o diret�rio via FTP. O arquivo segue em anexo.';
			ATTACHMENT  '\workflow\cupons.txt'
			DISCONNECT SMTP SERVER

		EndIf

		FTPDisconnect() // Desconex�o do FTP

	Else
		CONOUT("INAFAG - FALHA NA CONEXAO COM O SERVIDOR DE FTP, SEGUE POR EMAIL")
		SEND MAIL FROM _cConta;
		TO GETMV("MV_FTPWEB5");
		SUBJECT 'Portal Imdepa - Falha na conex�o FTP';
		BODY 'Houve falha na conex�o como FTP do portal. O arquivo segue em anexo.';
		ATTACHMENT  '\workflow\cupons.txt'
		DISCONNECT SMTP SERVER

	EndIf

	If !lViaWorkFlow
		FechaBatch() // Fecha a tela com os bot�es.
	EndIf
	CONOUT("INAFAG - FIM DO PROCESSAMENTO" )
	
Return Nil