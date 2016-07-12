#INCLUDE "ap5mail.ch"
#INCLUDE "protheus.ch"
#INCLUDE "tbiconn.ch"

/*/
Programa : PRGINAFAG.PRW
Autor    : JEAN REHERMANN
Data     : 06/05/11
Descri??o: Programa??o de compras INA-FAG.
/*/

User Function PRGINAFAG

	Local   _aSays	     := {}
	Local   _aButtons    := {}
	Local   _cCadastro   := OemtoAnsi("Exporta??o de Dados - Promo??o Goodyear")
    Private lViaWorkFlow := Type("dDatabase") == "U"// Se rodar via workflow, dDatabase s? estara disponivel apos o Prepare Environment

	If lViaWorkFlow
		PREPARE ENVIRONMENT EMPRESA '01' FILIAL '09' FUNNAME 'PRGINAFAG' TABLES 'ZA0','SD2', 'SX6','SM0'
		Executar()
	Else
		AADD( _aSays,OemToAnsi("Esta rotina tem por finalidade efetuar a exporta??o de dados para arquivo de") )
		AADD( _aSays,OemToAnsi("texto, obedecendo layout espec?fico.                                        ") )
		   
		AADD( _aButtons, { 1, .T., { |o| Processa( { || Executar() }, "Exportar", "Preparando dados..." ) } } )
		AADD( _aButtons, { 2, .T., { |o| FechaBatch() } } )
	
		// Tela de apresenta??o do programa.
		FormBatch( _cCadastro, _aSays, _aButtons )
	Endif
		
Return Nil


//*************************************************************************************
// Jean Rehermann - 07/05/2011 - Fun??o principal do programa
//*************************************************************************************

Static Function Executar()

	Local _cArq  := _cQuery := _cEOL := _cLinha := ""
	Local _nRegs := 0
	Private _nHdl := -1
	
	_cEOL := "CHR(13)+CHR(10)"
    _cEOL := Trim( _cEOL )
    _cEOL := &_cEOL

	// Cria o arquivo especificado.
	_cArq := "\workflow\PRGINAFAG.txt"
	_nHdl := MsFCreate( Alltrim( _cArq ), 0 )

	// Query para selecionar os registros.
//	_cQuery := "SELECT CNPJCLI, PRODUTO, SUM(COMPRADO) COMPRADO, SUM(CONSULTADO) CONSULTADO, SUBSTR( ZA0_DTNECL ,1,6) AS PERIODO FROM ( "
_cQuery :=" SELECT * FROM "
_cQuery +=" (SELECT CNPJCLI, PRODUTO, SUM(COMPRADO) COMPRADO, SUM(CONSULTADO) CONSULTADO, SUBSTR( ZA0_DTNECL ,1,6) AS PERIODO FROM ( "
	
	_cQuery += "SELECT "
	_cQuery += "	 ZA0_PRODUT PRODUTO, "
	_cQuery += "	 SUM(ZA0_QUANTD) CONSULTADO, "
	_cQuery += "	 0          COMPRADO, "
	_cQuery += "	 ZA0_DTNECL  , "
	_cQuery += "	 A1_CGC     CNPJCLI "
	
	_cQuery += "FROM SA1010 SA1, ZA0010 ZA0, SB1010 SB1 "
	
	_cQuery +=" WHERE   SA1.A1_FILIAL='"+xFilial("SA1")+"'"
	_cQuery += " AND    SA1.A1_COD NOT IN ('N00000', 'N00001','000000') "
	_cQuery += " AND    SA1.A1_MSBLQL   <> '1' "
	_cQuery += " AND    SA1.A1_VINCULO   IN ('R2','R9') "
	_cQuery += " AND    SA1.D_E_L_E_T_  =  ' ' "
	
	_cQuery += " AND    ZA0.ZA0_CLIENT  = SA1.A1_COD "
	_cQuery += " AND    ZA0.ZA0_LOJACL  = SA1.A1_LOJA "
	_cQuery += " AND    ZA0.D_E_L_E_T_  = SA1.D_E_L_E_T_ "
	_cQuery += " AND    ZA0.ZA0_DTOFER BETWEEN TO_CHAR( ADD_MONTHS( SYSDATE, -12 ), 'yyyymmdd' ) AND TO_CHAR( SYSDATE, 'yyyymmdd') "
	_cQuery += " AND    ZA0.D_E_L_E_T_  = ' ' "
	
	_cQuery += " AND    ZA0.ZA0_FILIAL  = SB1.B1_FILIAL "
	_cQuery += " AND    ZA0.ZA0_PRODUT  = SB1.B1_COD "
	_cQuery += " AND    ZA0.D_E_L_E_T_  = SB1.D_E_L_E_T_ "
	_cQuery += " AND    SB1.B1_MSBLQL   <> '1' "
	_cQuery += " AND    SB1.B1_GRMAR2   IN ('000001','000002') "
	_cQuery += " AND    SB1.D_E_L_E_T_  =  ' ' "
	
	_cQuery += "GROUP BY ZA0_PRODUT, ZA0_DTNECL, A1_CGC "
	
	_cQuery += " UNION "
		
	_cQuery += "SELECT "
	_cQuery += "	 D2_COD        PRODUTO, "
	_cQuery += "	 0             CONSULTADO, "
	_cQuery += "	 SUM(D2_QUANT) COMPRADO, "
	_cQuery += "	 D2_EMISSAO    DATA, "
	_cQuery += "	 A1_CGC     CNPJCLI "

	_cQuery += "FROM SD2010 D2, SA1010 A1, SB1010 B1, SF4010 F4 "
	
	_cQuery += " WHERE   A1.A1_FILIAL='"+xFilial("SA1")+"'"
	_cQuery += " AND  D2.D2_FILIAL IN ('02','04','05','06','07','09','12','13') "
	_cQuery += " AND D2.D2_EMISSAO BETWEEN TO_CHAR( ADD_MONTHS( SYSDATE, -12 ), 'yyyymmdd' ) AND TO_CHAR( SYSDATE, 'yyyymmdd') "
	_cQuery += " AND D2.D2_TIPO      = 'N' "
	_cQuery += " AND A1.A1_MSBLQL    <> '1' "
	_cQuery += " AND A1.A1_VINCULO   IN ('R2','R9') "
	_cQuery += " AND B1.B1_GRMAR2    IN ('000001','000002') "
	_cQuery += " AND F4.F4_ESTOQUE   = 'S' "
	_cQuery += " AND F4.F4_DUPLIC    = 'S' "
	_cQuery += " AND A1.A1_COD       = D2.D2_CLIENTE "
	_cQuery += " AND A1.A1_LOJA      = D2.D2_LOJA "
	_cQuery += " AND B1.B1_FILIAL    = D2.D2_FILIAL "
	_cQuery += " AND B1.B1_COD       = D2.D2_COD "
	_cQuery += " AND F4.F4_FILIAL    = D2.D2_FILIAL "
	_cQuery += " AND F4.F4_CODIGO    = D2.D2_TES "
	_cQuery += " AND A1.D_E_L_E_T_   = ' ' "
	_cQuery += " AND B1.D_E_L_E_T_   = ' ' "
	_cQuery += " AND D2.D_E_L_E_T_   = ' ' "
	_cQuery += " AND F4.D_E_L_E_T_   = ' ' "

	_cQuery += " GROUP BY D2_COD, D2_EMISSAO, A1_CGC "
	_cQuery += ") GROUP BY CNPJCLI, PRODUTO, ZA0_DTNECL "
	
	_cQuery += " ORDER BY CNPJCLI, ZA0_DTNECL, PRODUTO"
    _cQuery += ")"
    
	MemoWrite("INAFAGPROG.SQL", _cQuery)
	
	_cQuery := ChangeQuery( _cQuery )
	Iif( Select("PRGQ") <> 0, PRGQ->( dbCloseArea() ), ) // Verifico se a area n?o est? em uso.
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),"PRGQ",.F.,.T.) // Crio a area.
	CONOUT("PRGINAFAG - QUERY EXECUTADA" )

	// Formatar os campos para uso
	aStru := PRGQ->( dbStruct() )
	aEval( aStru, { |e| If( e[ 2 ] != "C" .And. PRGQ->( FieldPos( Alltrim( e[ 1 ] ) ) ) > 0, TCSetField( "PRGQ", e[ 1 ], e[ 2 ],e [ 3 ], e[ 4 ] ), Nil ) } )

	If !lViaWorkFlow
		PRGQ->( dbGoTop() )
		Count To _nRegs // Total de registros da query.
		PRGQ->( dbGoTop() )
		ProcRegua( _nRegs )
	EndIf
	
	While !PRGQ->( Eof() )
      
		// Preparo a linha para gravar
		_cLinha := PRGQ->CNPJCLI + ";" + PRGQ->PRODUTO + ";" + PRGQ->PERIODO + ";" + StrZero(PRGQ->COMPRADO * 100,15) + ";" + StrZero(PRGQ->CONSULTADO * 100,15) + _cEOL
		// Gravo a linha no arquivo
		FWrite( _nHdl, _cLinha )
	
		If !lViaWorkFlow
			IncProc("Gerando Arquivo....( "+ StrZero( _nRegs, 6 ) +" registros )")
		EndIf
		PRGQ->( dbSkip() )
	End

	PRGQ->( dbCloseArea() ) // Fecho a area
	FClose( _nHdl ) // Fecho o arquivo
	CONOUT("PRGINAFAG - ARQUIVO PROCESSADO E GERADO" )

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
			CONOUT("PRGINAFAG - ERRO DE AUTENTICACAO DE E-MAIL: "+ _cErro )
		ENDIF
	ELSE
		IF !_lResult
			GET MAIL ERROR _cErro
			CONOUT("PRGINAFAG - ERRO DE CONEXAO NO ENVIO DE E-MAIL: "+ _cErro )
		ENDIF
	ENDIF
	CONOUT("PRGINAFAG - CONECTADO AO SERVIDOR DE EMAILS" )
	
	// Enviar o arquivo para o ftp do portal. Em caso de erro o arquivo ser? enviado por e-mail.
	If FTPConnect( GETMV("MV_FTPWEB1"), GETMV("MV_FTPWEB2"), GETMV("MV_FTPWEB3"), GETMV("MV_FTPWEB4") ) // Conectar no FTP
		CONOUT("PRGINAFAG - CONECTADO NO FTP DO PORTAL" )

		If FTPDirChange('web/import') // Selecionar o diret?rio no FTP
			CONOUT("PRGINAFAG - DIRETORIO REMOTO SELECIONADO")
			
			If FTPUpload( '\workflow\PRGINAFAG.txt', 'PRGINAFAG.txt' ) // Fazer upload no arquivo no diret?rio selecionado no FTP
				CONOUT("PRGINAFAG - ARQUIVO DE PROGRAMA??O ENVIADO COM SUCESSO PARA O PORTAL")
				SEND MAIL FROM _cConta;
				TO GETMV("MV_FTPWEB5");
				SUBJECT 'Portal Imdepa - Arquivo de programa??o enviado com sucesso';
				BODY 'O arquivo foi gerado e enviado com sucesso para o portal.'
				DISCONNECT SMTP SERVER
				
				// Grava no parametro a data processada
				PutMV( "MV_PROCTIK", dDataBase )

			Else
				CONOUT("PRGINAFAG - FALHA NO ENVIO DO ARQUIVO DE PROGRAMA??O PARA O PORTAL, SEGUE POR EMAIL")
				SEND MAIL FROM _cConta;
				TO GETMV("MV_FTPWEB5");
				SUBJECT 'Portal Imdepa - Falha no upload do arquivo de programa??o';
				BODY 'Houve falha no upload do arquivo. O arquivo segue em anexo.';
				ATTACHMENT  '\workflow\PRGINAFAG.txt'
				DISCONNECT SMTP SERVER

			EndIf

		Else
			CONOUT("PRGINAFAG - FALHA AO SELECIONAR DIRETORIO REMOTO, SEGUE POR EMAIL")
			SEND MAIL FROM _cConta;
			TO GETMV("MV_FTPWEB5");
			SUBJECT 'Portal Imdepa - Falha no diret?rio';
			BODY 'N?o foi poss?vel selecionar o diret?rio via FTP. O arquivo de programa??o segue em anexo.';
			ATTACHMENT  '\workflow\PRGINAFAG.txt'
			DISCONNECT SMTP SERVER

		EndIf

		FTPDisconnect() // Desconex?o do FTP

	Else
		CONOUT("PRGINAFAG - FALHA NA CONEXAO COM O SERVIDOR DE FTP, SEGUE POR EMAIL")
		SEND MAIL FROM _cConta;
		TO GETMV("MV_FTPWEB5");
		SUBJECT 'Portal Imdepa - Falha na conex?o FTP';
		BODY 'Houve falha na conex?o como FTP do portal. O arquivo de programa??o segue em anexo.';
		ATTACHMENT  '\workflow\PRGINAFAG.txt'
		DISCONNECT SMTP SERVER

	EndIf

	If !lViaWorkFlow
		FechaBatch() // Fecha a tela com os bot?es.
	EndIf
	CONOUT("PRGINAFAG - FIM DO PROCESSAMENTO" )
	
Return Nil