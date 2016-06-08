#INCLUDE 'PROTHEUS.CH'
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ IMDA090  บAUTOR  ณMARLLON FIGUEIREDO  บ DATA ณ 17/03/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ MANUTENCAO DA PLANILHA DE TRANSFERENCIA ENTRE FILIAIS      บฑฑ
ฑฑบ          ณ PROCESSA A PLANILHA GERANDO OS PVS E PCS NAS FILIAIS       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ                                                            บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบULTIMAS ALTERACOES                                                     บฑฑ
ฑฑฬออออออออออัออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAUTOR     ณ DATA     ณ  DESCRICAO                                      บฑฑ
ฑฑบMARLLON   ณ31/03/2003ณ TESTADO OK                                      บฑฑ
ฑฑบMARCIO    ณ19/11/2005ณ LIBERA AUTOMATICO PEDIDO DE TRANSFERENCIA       บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
USER FUNCTION IMDA090()
*********************************************************************

	LOCAL CFILTRO   := SPACE(0)
	LOCAL AFIXE     := {{ OEMTOANSI("PLANILHA    "), "ZE_NUMPLAN" },;  //"PLANILHA    "
	{ OEMTOANSI("ITEM        "), "ZE_ITEM   " },;  //"ITEM        "
	{ OEMTOANSI("NUM. PC/PO  "), "ZE_HAWB   " }}   //"PROCESSO    "

	LOCAL ACORES    := {{ 'ZE_FLAGPT <> "S" .AND. ZE_VENCD < DDATABASE', 'BR_AZUL' },;
		{ 'ZE_FLAGPT <> "S"', 'ENABLE'  },;
		{ 'ZE_FLAGPT == "S"', 'DISABLE' }}


	PRIVATE BFILTRABRW := {|| NIL}
	PRIVATE NFUNCAO    := 1
	PRIVATE NTIPOPED   := 1
	PRIVATE CCADASTRO  := OEMTOANSI("Planilha de Transfer๊ncia")
	PRIVATE L120AUTO   := .F.
	PRIVATE AAUTOCAB   := {}
	PRIVATE AAUTOITENS := {}
	PRIVATE LPEDIDO    := .T.

//+--------------------------------------------------------------+
//ฆ DEFINE ARRAY CONTENDO AS ROTINAS A EXECUTAR DO PROGRAMA      ฆ
//ฆ ----------- ELEMENTOS CONTIDOS POR DIMENSAO ------------     ฆ
//ฆ 1. NOME A APARECER NO CABECALHO                              ฆ
//ฆ 2. NOME DA ROTINA ASSOCIADA                                  ฆ
//ฆ 3. USADO PELA ROTINA                                         ฆ
//ฆ 4. TIPO DE TRANSA็ไO A SER EFETUADA                          ฆ
//ฆ    1 - PESQUISA E POSICIONA EM UM BANCO DE DADOS             ฆ
//ฆ    2 - SIMPLESMENTE MOSTRA OS CAMPOS                         ฆ
//ฆ    3 - INCLUI REGISTROS NO BANCOS DE DADOS                   ฆ
//ฆ    4 - ALTERA O REGISTRO CORRENTE                            ฆ
//ฆ    5 - REMOVE O REGISTRO CORRENTE DO BANCO DE DADOS          ฆ
//+--------------------------------------------------------------+
	PRIVATE AROTINA := {{OEMTOANSI('PESQUISAR'),	'AXPESQUI',		0, 1}  ,;  // 'PESQUISAR'
	{OEMTOANSI('VISUALIZAR'),	'U_IMD090MAN',	0, 2}  ,;  // 'VISUALIZAR'
	{OEMTOANSI('M&ANUTEN็ใO'),	'U_IMD090MAN',	0, 4}  ,;  // 'MANUTEN็ใO'
	{OEMTOANSI('VA&LIDADE'),	'U_IMD090VAL',	0, 4}  ,;  // 'VALIDADE'
	{OemtoAnsi('V&ENDAS'),		'U_IMD080Ven',	0, 2}  ,;  // 'VENDAS'
	{OEMTOANSI('LE&GENDA'),		'U_IMD090LEG',	0, 5}  ,;  // 'LEGENDA'
	{OEMTOANSI('P&ROCESSAR'),	'U_IMDA640'  ,	0, 5}}     // 'PROCESSAR'
	PRIVATE CPERG   := 'IMD090'

/*
// Jorge Oliveira - 10/11/10 - O processamento da planilha serah realizado por outra rotina
// {OEMTOANSI('PROCESSAR'),  'U_IMD090GER',  0 , 4}  ,;  // 'PROCESSAR'
A funcao IMD090GER() serah utilizada para gerar os PV automaticamente, quando for realizada uma venda de mercadoria de outra Filial.
*/

	DBSELECTAREA('SZE')
	DBSETORDER(3)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ INICIALIZA A FUNCAO FILBROWSE                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CFILTRO := "ZE_FILIAL == '"+XFILIAL('SZE')

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ ENDERECA A FUNCAO DE BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MBROWSE( 6, 1, 22, 75, 'SZE', AFIXE,,,,, ACORES )

	DBSELECTAREA('SZE')
	DBSETORDER(3)

RETURN(.T.)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณIMD090MAN บAUTOR  ณMICROSIGA           บ DATA ณ  04/08/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ MANUTENCAO DA PLANILHA DE TRANSFERENCIA                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
USER FUNCTION IMD090MAN(CALIAS, NREG, NOPC)
*********************************************************************

	LOCAL AAREA        := GETAREA()
	LOCAL NOPCA        := 0
	LOCAL COLDALIAS    := ALIAS()
	LOCAL CNUMPLAN     := SZE->ZE_NUMPLAN
	Local cCodiUsu     := RetCodUsr()
//+--------------------------------------------------------------+
//ฆ MONTA A ENTRADA DE DADOS DO ARQUIVO                          ฆ
//+--------------------------------------------------------------+
	PRIVATE ATELA[0][0],AGETS[0]

	NOPCA := 0

// POSICIONA NO PRIMEIRO REGISTRO DA PLANILHA
	DBSELECTAREA('SZE')
	DBSETORDER(1)
	DBSEEK(XFILIAL('SZE')+CNUMPLAN)

// NAO PODE FAZER MANUTENCAO SE JA ESTIVER PROCESSADA
	IF (SZE->ZE_FLAGPT == 'S' .OR. SZE->ZE_VENCD < DDATABASE) .AND. NOPC = 3
		IF SZE->ZE_VENCD < DDATABASE
			HELP(' ', 1, 'ATEN็ใO',,'Planilha com prazo de validade esgotado!',1,1)
		ELSE
			HELP(' ', 1, 'ATEN็ใO',,'Planilha ap๓s ser processada nใo pode sofrer manuten็ใo!',1,1)
		ENDIF
	ELSE
		IF NOPC = 3 .AND. SZE->ZE_MSFIL <> CFILANT
			HELP(' ', 1, 'ATEN็ใO',,'Esta planilha s๓ pode sofrer manuten็ใo dentro da filial distribuidora!',1,1)
		ELSE
			NOPCA := IMD090TELA( CALIAS, NREG, NOPC )
		ENDIF
	ENDIF

// Jorge Oliveira - 26/10/10 - Confirmou a Manutencao da Planilha, por isso grava o codigo do usuario
	If ( nOpc == 3 .And. nOpca == 3 .And. !Empty( cCodiUsu ) )

	// Preenche o codigo do usuario atual, em todos os registros da Planilha
		DBSEEK( XFILIAL( 'SZE' ) + CNUMPLAN )
		While SZE->( !EOF() ) .And. SZE->ZE_NUMPLAN == cNumPlan

			RECLOCK("SZE",.F.)
			SZE->ZE_CODUSU := cCodiUsu
			MSUNLOCK()

			SZE->( DbSkip() )
		EndDo

	EndIf

// RETORNA AREA ORIGINAL
	RESTAREA(AAREA)

RETURN()
/*ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUN…O    ณIMD090LEG ณ AUTOR ณ MARLLON FIGUEIREDO    ณ DATA ณ14/03/2003ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRI…O ณ CRIA UMA JANELA CONTENDO A LEGENDA DA MBROWSE              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
USER FUNCTION IMD090LEG()
*********************************************************************

	BRWLEGENDA( CCADASTRO,"LEGENDA",{	{"BR_AZUL", "Prazo de validade esgotado"},;
		{"ENABLE",  "Aguardando manuten็ใo da planilha"},;
		{"DISABLE", "Planilha processada"}} )

RETURN( .T. )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณIMD090TELAบAUTOR  ณMARLLON FIGUEIREDO  บ DATA ณ 20/03/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
STATIC FUNCTION IMD090TELA(CALIAS, NREG, NOPC)
*********************************************************************

	LOCAL BWHILE
	LOCAL ODLG
	LOCAL OGETDAD
	LOCAL OENCH
	LOCAL NOPCA      := 0
	LOCAL NPOSLF     := 0
	LOCAL NUSADO     := 0
	LOCAL NCNTFOR    := 0
	LOCAL cRecno     := ""
	LOCAL cNumPlan   := ""
	LOCAL cMailDir   := ""
	LOCAL cProd      := ""
	LOCAL cVendedor  := ""
	LOCAL cCodPE     := ""
	LOCAL cMailDir   := U_MailDire("P") //SuperGetMV( "MV_DIRPLA",, "" )
	LOCAL ALISTFILES := {}
	LOCAL ANOFIELDS  := {}
	LOCAL AYESFIELDS := {}
	LOCAL ASIZE      := {}
	LOCAL AOBJECTS   := {}
	LOCAL AINFO      := {}
	LOCAL AIMDPOSOBJ := {}
	LOCAL AVISUAL    := {}
	LOCAL aAltera    := {}
	LOCAL aAlterEnch := {}

	PRIVATE ACOLS    := {}
	PRIVATE AHEADER  := {}

// VARIAVEIS UTILIZADAS NA FUNCAO IA080PO()...
	PRIVATE CNEWSC	 := ''
	PRIVATE CNEWSI	 := ''
	PRIVATE NNEWIT	 := 0

// Manutencao da Planilha so pode ser feita por um usuario sendo um Comprador
	If NOPC == 3

	// Chama rotina para verificar se o usuario pode alterar ou excluir a planilha
		If !U_A090PERALT()

			MsgInfo( "Usuแrio nใo tem permissใo para acessar a op็ใo selecionada, " + Chr(13) +;
				"pois nใo estแ cadastrado como um Comprador." )
		// Irah retornar zero, como se estivesse cancelado
			Return( NOPCA )

		EndIf

	EndIf

// Jorge Oliveira - 16/08/2010 - Deixa o separador de endereco
	cMailDir := IIF( Right( AllTrim( cMailDir ), 1 ) <> ";", cMailDir + "; ", cMailDir )

// RECUPERA CAMPOS PARA AS VARIAVEIS DE MEMORIA
	REGTOMEMORY(CALIAS, .F.)

// CAMPOS A SEREM APRESENTADOS NA ENCHOICE
	AADD(AVISUAL,"ZE_NUMPLAN")
	AADD(AVISUAL,"ZE_HAWB")
	AADD(AVISUAL,"ZE_DATA")
	AADD(AVISUAL,"ZE_VENCD")
	AADD(AVISUAL,"ZE_VENCH")
	AADD(AVISUAL,"ZE_MSFIL")
	AADD(AVISUAL,"ZE_CODUSU")
//AADD(AVISUAL,"ZE_NOMEUSU")

// CAMPOS QUE PODEM SER ALTERADOS
//AADD(AALTERA,"ZE_VENCD")
//AADD(AALTERA,"ZE_VENCH")

//+----------------------------------------------------------------+
//|   MONTAGEM DO AHEADER E DO ACOLS                               |
//+----------------------------------------------------------------+
	DBSELECTAREA("SX3")
	DBSETORDER(1)
	DBSEEK("SZE")
	DO WHILE ( !EOF() .AND. SX3->X3_ARQUIVO == "SZE" )
		IF ( X3USO(SX3->X3_USADO) .AND. CNIVEL >= SX3->X3_NIVEL )

		// Esses campos nao serao mostrados no ACOLS da consulta ou manutencao, somente no HEADER
			IF ! TRIM(SX3->X3_CAMPO) $ "ZE_TPPLAN|ZE_CODPE"

			// Carrega no Header se nao for visual
				IF ASCAN(AVISUAL, ALLTRIM(SX3->X3_CAMPO)) = 0 .And. SX3->X3_CONTEXT <> "V"

					NUSADO++
					AADD( AHEADER,{	TRIM(X3TITULO()),;
						TRIM(SX3->X3_CAMPO),;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_ARQUIVO,;
						SX3->X3_CONTEXT } )
				ENDIF
			ENDIF
		ENDIF
		DBSELECTAREA("SX3")
		DBSKIP()
	ENDDO

// CARREGA OS DADOS PARA O ACOLS
	DBSELECTAREA('SZE')
	DBSETORDER(1) // ZE_FILIAL + ZE_NUMPLAN + ZE_PRODUTO + ZE_DESTINO

	BWHILE := {|| XFILIAL("SZE") == SZE->ZE_FILIAL .AND. SZE->ZE_NUMPLAN == M->ZE_NUMPLAN }
	DO WHILE ( !EOF() .AND. EVAL(BWHILE) )

		cNumPlan := SZE->ZE_NUMPLAN

		AADD(ACOLS,ARRAY(NUSADO+1))
		FOR NCNTFOR := 1 TO NUSADO
			IF ( AHEADER[NCNTFOR][10] != "V" )
				ACOLS[LEN(ACOLS)][NCNTFOR] := FIELDGET(FIELDPOS(AHEADER[NCNTFOR][2]))
			ELSE
				ACOLS[LEN(ACOLS)][NCNTFOR] := CRIAVAR(AHEADER[NCNTFOR][2])
				ACOLS[LEN(ACOLS)][NCNTFOR] := POSICIONE("SB1",1,XFILIAL("SB1")+SZE->ZE_PRODUTO,"B1_DESC")
			ENDIF
		NEXT NCNTFOR
		ACOLS[LEN(ACOLS)][LEN(AHEADER)+1] := .F.

	// TRAVO TODOS OS REGISTROS PARA IMPEDIR O USO POR OUTRAS ROTINAS QUE
	// UTILIZAM A PLANILHA DE TRANSFERENCIA EM MANUTENCAO
		IF NOPC = 3
			RECLOCK('SZE',.F.)
		ENDIF

		DBSELECTAREA('SZE')
		DBSKIP()
	ENDDO

	ASIZE := MSADVSIZE()
	AADD( AOBJECTS, { 100, 25, .T., .T. } )
	AADD( AOBJECTS, { 100, 75, .T., .T. } )
	AINFO      := { ASIZE[ 1 ], ASIZE[ 2 ], ASIZE[ 3 ], ASIZE[ 4 ], 5, 5 }
	AIMDPOSOBJ := MSOBJSIZE( AINFO, AOBJECTS,.T.)

	DBSELECTAREA(CALIAS)
//SOFTLOCK(CALIAS)

	NOPCA := 0
	DEFINE MSDIALOG ODLG TITLE CCADASTRO FROM ASIZE[7],00 TO ASIZE[6],ASIZE[5] PIXEL

//-- MONTA A ENCHOICE.
	OENCH := MSMGET():NEW( CALIAS, NREG, NOPC,,,, AVISUAL, AIMDPOSOBJ[1], , 3, , , , , ,.T. )

//-- DEFINE AS POSICOES DA GETDADOS A PARTIR DO FOLDER.
	NGD1 := AIMDPOSOBJ[2,1]
	NGD2 := AIMDPOSOBJ[2,2]
	NGD3 := AIMDPOSOBJ[2,3]
	NGD4 := AIMDPOSOBJ[2,4]
	OGETDAD :=MSGETDADOS():NEW(NGD1, NGD2,NGD3,NGD4,NOPC,'U_VALLINGD','U_VALGDADOS',         ,.F.    ,      ,       ,      ,LEN(ACOLS),        ,         ,       ,      ,ODLG)

	ABUTTONS := ARRAY(0)
	IF NOPC == 3
		AADD(ABUTTONS, {"EDIT",{|| U_INCFIL(N)},OEMTOANSI('Incluir Filial para Transferencia')})
	ENDIF
	AADD(ABUTTONS, {"SOLICITA",{|| U_IMD090PED(N)},OEMTOANSI('Pedidos de Venda Vinculados')})

	ACTIVATE MSDIALOG ODLG ON INIT ENCHOICEBAR(ODLG,{|| NOPCA := 2,IIF(U_VALGDADOS(),ODLG:END(),NOPCA := 0)},{|| NOPCA := 1,ODLG:END()},,ABUTTONS)

// MANUTENCAO DA PLANILHA
	IF NOPC == 3

	// VALORES DO ACOLS
		NDEST    := ASCAN(AHEADER, {|X| ALLTRIM(X[2]) == 'ZE_DESTINO'})
		NDTENT   := ASCAN(AHEADER, {|X| ALLTRIM(X[2]) == 'ZE_DTENTRE'})
		NITEM    := ASCAN(AHEADER, {|X| ALLTRIM(X[2]) == 'ZE_ITEM'   })

		NQTDSOL  := ASCAN(AHEADER, {|X| ALLTRIM(X[2]) == 'ZE_QTDORIG'})
		NQTDPC   := ASCAN(AHEADER, {|X| ALLTRIM(X[2]) == 'ZE_QTDPC'  })
		NQTDRES  := ASCAN(AHEADER, {|X| ALLTRIM(X[2]) == 'ZE_QTDRES' })
		NQTDTRAN := ASCAN(AHEADER, {|X| ALLTRIM(X[2]) == 'ZE_QTDTRAN'})
		NEXCED   := ASCAN(AHEADER, {|X| ALLTRIM(X[2]) == 'ZE_EXCED'  })

		NVENCD   := ASCAN(AHEADER, {|X| ALLTRIM(X[2]) == 'ZE_VENCD'  })
		NPRODUTO := ASCAN(AHEADER, {|X| ALLTRIM(X[2]) == 'ZE_PRODUTO'})
		NCODCLI  := ASCAN(AHEADER, {|X| ALLTRIM(X[2]) == 'ZE_CODCLI' })
		NLOJA    := ASCAN(AHEADER, {|X| ALLTRIM(X[2]) == 'ZE_LOJA'   })

	// Consulta o codigo da PE do primeiro item da Planilha
		cCodPE := Posicione( "SZE", 3, xFilial( "SZE" ) + M->ZE_NUMPLAN + "01", "ZE_CODPE" )

	// Confirmou atualizacao
		IF NOPCA == 2

			BEGIN TRANSACTION

				DBSELECTAREA('SZE')
		/*
		INDICES:
		1 => ZE_FILIAL + ZE_NUMPLAN + ZE_PRODUTO + ZE_DESTINO
		2 => ZE_FILIAL + ZE_NUMPLAN + ZE_DESTINO + ZE_PRODUTO + DTOS( ZE_DTENTRE )
		3 => ZE_FILIAL + ZE_NUMPLAN + ZE_ITEM
		4 => ZE_FILIAL + ZE_PRODUTO + ZE_DESTINO + DTOS( ZE_DTENTRE )
		5 => ZE_FILIAL + ZE_NUMPLAN + ZE_PLSEQID + ZE_ITEM
		*/
				DBSETORDER(3)

				FOR NXA := 1 TO LEN(ACOLS)

					cRecno   := ""

					IF SZE->( DBSEEK( XFILIAL('SZE') + M->ZE_NUMPLAN + ACOLS[ NXA, NITEM ] ) )

				// Se todos os valores estao zerados, deve deleta a linha
						If ( ACOLS[ NXA, NQTDSOL  ] <= 0 .And. ACOLS[ NXA, NQTDPC ] <= 0 .And. ACOLS[ NXA, NQTDRES ] <= 0 .And. ;
								ACOLS[ NXA, NQTDTRAN ] <= 0 .And. ACOLS[ NXA, NEXCED ] <= 0 )

							RECLOCK("SZE",.F.)
							SZE->ZE_CODUSU := RetCodUsr()
							MSUNLOCK()
					//Jorge Oliveira - 23/08/2010 - Chama a rotina para gravar os Logs
							U_LOGPLANI( "E" )

							RECLOCK("SZE",.F.)
							DbDelete()
							MSUNLOCK()

						Else
							RECLOCK("SZE",.F.)

							FOR NXB := 1 TO LEN(ACOLS[NXA])-1
								CPARC := AHEADER[NXB,2]
								IF CPARC <> 'ZE_QTDRES'
									FIELDPUT(FIELDPOS(CPARC), ACOLS[NXA,NXB])
								ENDIF
							NEXT NXB
							SZE->ZE_CODUSU := RetCodUsr()

							MSUNLOCK()

					//Jorge Oliveira - 23/08/2010 - Chama a rotina para gravar os Logs
							U_LOGPLANI( "A" )

						EndIf

						cRecno := SZE->( Recno() )

					ELSE
				// Se foi informado algo a ser transferido, pode cadastrar a planilha
						IF ACOLS[ NXA, NQTDTRAN ] > 0

							RECLOCK("SZE",.T.)
							SZE->ZE_NUMPLAN := M->ZE_NUMPLAN
							SZE->ZE_DATA    := M->ZE_DATA
							SZE->ZE_HAWB    := M->ZE_HAWB
							SZE->ZE_VENCD   := M->ZE_VENCD
							SZE->ZE_VENCH   := M->ZE_VENCH
							SZE->ZE_CODUSU  := RetCodUsr()
							SZE->ZE_CODPE   := cCodPE

							FOR NXB := 1 TO LEN(ACOLS[NXA])-1
								CPARC := AHEADER[NXB,2]
								FIELDPUT(FIELDPOS(CPARC), ACOLS[NXA,NXB])
							NEXT NXB
							MSUNLOCK()

					//Jorge Oliveira - 23/08/2010 - Chama a rotina para gravar os Logs
							U_LOGPLANI( "I" )
							cRecno := SZE->( Recno() )

						ENDIF // IF ACOLS[ NXA, NQTDTRAN ] > 0 .Or. ACOLS[ NXA, NEXCED ]

					ENDIF

			// Jorge Oliveira - 11/10/10 - Deve estara posicionado no registro
					If !Empty( cRecno )

						If cRecno <> SZE->( Recno() )
							SZE->( DbGoTo( cRecno ) )
						EndIf

				// Marca que essa Planilha eh de Transferencia, para que possa realizar as vendas na tela da verdade
						If SZE->ZE_TPPLAN <> "T"
							RECLOCK("SZE",.F.)
							SZE->ZE_TPPLAN := "T"
							MSUNLOCK()
						EndIf

				//Jorge Oliveira - 23/08/2010 - Chama a rotina para buscar o e-mail da Estrutura de Vendas
						If !Empty( SZE->ZE_CODCLI )
							cMailDir += U_EstruVen( SZE->ZE_CODCLI, SZE->ZE_LOJA )
						EndIf

						cProd := AllTrim( SZE->ZE_PRODUTO ) + ' - ' + Posicione( "SB1", 1, xFilial("SB1")+SZE->ZE_PRODUTO, "B1_DESC" )

				// Jorge Oliveira - 23/08/2010 - Monta as informacoes para envio do e-mail
						AADD( aAltera, { { "Nr da Planilha"				, SZE->ZE_NUMPLAN						},;
							{ "Item da Planilha"			, SZE->ZE_ITEM 			 			},;
							{ "Filial de Origem"			, SZE->ZE_MSFIL 			 			},;
							{ "Filial de Destino"		, SZE->ZE_DESTINO			 			},;
							{ "Produto"			  			, cProd						 			},;
							{ "Quantidade Solicitada"	, cValToChar( SZE->ZE_QTDPC )		},;
							{ "Quantidade Transferida"	, cValToChar( SZE->ZE_QTDTRAN )	},;
							{ "Cliente"			  			, SZE->ZE_CODCLI						},;
							{ "Loja"				 			, SZE->ZE_LOJA							},;
							{ "Nr do Contrato "			, SZE->ZE_CODCONT						},;
							{ "Quantidade Excedente"	, cValToChar( SZE->ZE_EXCED )		},;
							{ "Data Entrada"		 		, DtoC( SZE->ZE_DTENTRE )			},;
							{ "Data Vencimento"			, DtoC( SZE->ZE_VENCD )	 			};
							} )
					EndIf


				NEXT NXA
				DBSETORDER(1)

		// INCLUIDO POR LUCIANO CORREA EM 01/08/05...
				SC7->( DBORDERNICKNAME( 'C7_PLAN' ) )
				SC7->( DBSEEK( SZE->ZE_DESTINO + SZE->ZE_NUMPLAN, .F. ) )

				WHILE SC7->( !EOF() ) .AND. SC7->C7_FILIAL  == SZE->ZE_DESTINO ;
						.AND. SC7->C7_PLANILH == SZE->ZE_NUMPLAN

					IF !EMPTY( SC7->C7_NUMIMP )

						U_IA080PO()
					ENDIF

					SC7->( DBSKIP() )
				END

			END TRANSACTION

		ENDIF // Confirmou atualizacao
	ENDIF

// DESTRAVA TODOS OS REGISTROS BLOQUEADOS
	MSUNLOCKALL()

//Jorge Oliveira - 25/08/2010 - Confirmou a manutencao, entao envia o e-mail
	If NOPC == 3 .And. nOpca == 2

		If Len( aAltera ) > 0

		// Ordena por Planilha e Item
		//aSort( aAltera[1],,, { |x,y| x[1]+x[2] < y[1]+y[2] } )

		// TIPOS: I=>Inclusao M=>Manutencao P=>Processamento E=>Exclusao V=>Vencimento do Prazo
			u_I080SndMail( cNumPlan, {}, cMailDir, "M", aAltera )

		EndIf

	EndIf

RETURN(NOPCA)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณIMD090VAL บAUTOR  ณMARLLON FIGUEIREDO  บ DATA ณ 08/07/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณPERMITE ALTERAR A DATA DE VALIDADE DA PLANILHA DE TRANSFERENบฑฑ
ฑฑบ          ณCIA                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
USER FUNCTION IMD090VAL()

	LOCAL ODLG1, OBUT0, OBUT1
	LOCAL DVALID     := SZE->ZE_VENCD
	LOCAL CHORA      := SZE->ZE_VENCH
	LOCAL DVALIDOLD  := SZE->ZE_VENCD
	LOCAL CHORAOLD   := SZE->ZE_VENCH
	LOCAL LOK        := .F.
	LOCAL LSAIR      := .F.
	LOCAL AAREA      := GETAREA()
	LOCAL CNUMPLAN   := SZE->ZE_NUMPLAN
	LOCAL CGERENTE   := StrTran( Upper( SUPERGETMV( "MV_ALTVPLA",, "" ) ), ";", "_" )
	Local cMailDir   := U_MailDire("P") //SuperGetMV( "MV_DIRPLA",, "" )
	Local cProd      := ""
	Local aAltera    := {}

// Jorge Oliveira - 18/08/2010 - Incluida a validacao abaixo
// Se tem algum conteudo no parametro, deve validar com o nome do usuario
	IF ( !EMPTY( CGERENTE ) .AND. ! ( Upper( SubStr( CUSUARIO, 7, 15 ) ) $ CGERENTE ) )
		HELP('TESTE', 1, 'ATEN็ใO',,'NAO TEM PERMISSรO PARA ALTERAR A VALIDADE DA PLANILHA!', 1, 1 )
		RETURN( NIL )
	ENDIF

// SO PERMITO ALTERAR SE A PLANILHA NAO FOI PROCESSADA
	IF SZE->ZE_FLAGPT <> 'S'
		DEFINE MSDIALOG ODLG1 TITLE 'Altera็ใo da Planilha' FROM 0,0 TO 250,350 OF OMAINWND PIXEL
		DEFINE SBUTTON OBUT0 FROM 100,140 TYPE 01 ENABLE OF ODLG1 PIXEL ACTION(LOK:=LSAIR:=.T., ODLG1:END())
		DEFINE SBUTTON OBUT1 FROM 100,110 TYPE 02 ENABLE OF ODLG1 PIXEL ACTION(LSAIR:=.T., ODLG1:END())

		@ 012,008 SAY 'Validade:' OF ODLG1 PIXEL
		@ 012,055 MSGET DVALID OF ODLG1 PIXEL SIZE 40,10

		@ 027,008 SAY 'Hora:' OF ODLG1 PIXEL
		@ 027,055 MSGET CHORA PICTURE '99:99:99'  OF ODLG1 PIXEL SIZE 30,10

		ACTIVATE MSDIALOG ODLG1 CENTER VALID LSAIR

		IF LOK

		// Jorge Oliveira - 16/08/2010 - Deixa o separador de endereco
			cMailDir := IIF( Right( AllTrim( cMailDir ), 1 ) <> ";", cMailDir + "; ", cMailDir )

			DbSelectArea('SZE')
			DbSetOrder( 3 )
			SZE->( DbSeek( xFilial('SZE') + CNUMPLAN ) )
			While !EOF() .AND. CNUMPLAN = SZE->ZE_NUMPLAN

				cProd := AllTrim( SZE->ZE_PRODUTO ) + ' - ' + Posicione( "SB1", 1, xFilial("SB1")+SZE->ZE_PRODUTO, "B1_DESC" )

				RECLOCK('SZE',.F.)
				SZE->ZE_VENCD := DVALID
				SZE->ZE_VENCH := CHORA
				MSUNLOCK()

			//Jorge Oliveira - 23/08/2010 - Chama a rotina para gravar os Logs
				U_LOGPLANI( "A" )

				AADD( aAltera,{	{ "Nr da Planilha"			, SZE->ZE_NUMPLAN					},;
					{ "Item da Planilha"			, SZE->ZE_ITEM		 				},;
					{ "Filial de Origem"			, SZE->ZE_MSFIL	 				},;
					{ "Filial de Destino"		, SZE->ZE_DESTINO					},;
					{ "Produto"			  			, cProd						 		},;
					{ "Quantidade Solicitada"	, cValToChar( SZE->ZE_QTDPC )	},;
					{ "Quantidade Transferida"	, cValToChar( SZE->ZE_QTDTRAN	)},;
					{ "Cliente"			 			, SZE->ZE_CODCLI					},;
					{ "Loja"				  			, SZE->ZE_LOJA						},;
					{ "Nr do Contrato "			, SZE->ZE_CODCONT					},;
					{ "Quantidade Excedente"	, cValToChar( SZE->ZE_EXCED )	},;
					{ "Data Entrada"		  		, DtoC( SZE->ZE_DTENTRE)		},;
					{ "Vencimento anterior"		, DtoC( DVALIDOLD )				},;
					{ "Hora Venc. anterior"		, CHORAOLD							},;
					{ "Vencimento atual"			, DtoC( SZE->ZE_VENCD)			},;
					{ "Hora Venc. atual"			, SZE->ZE_VENCH					};
					} )


			//Jorge Oliveira - 23/08/2010 - Chama a rotina para buscar o e-mail da Estrutura de Vendas
				If !Empty( SZE->ZE_CODCLI )
					cMailDir += U_EstruVen( SZE->ZE_CODCLI, SZE->ZE_LOJA )
				EndIf

				SZE->( DbSkip() )
			EndDo

			If Len( aAltera ) > 0

			// Ordena por Planilha e Item
			//aSort( aAltera[1],,, { |x,y| x[1]+x[2] < y[1]+y[2] } )

			//Jorge Oliveira - 23/08/2010 - Envio de E-mail
			// TIPOS: I=>Inclusao M=>Manutencao P=>Processamento E=>Exclusao V=>Vencimento do Prazo
				U_I080SndMail( cNumPlan, {}, cMailDir, "M", aAltera )
			EndIf

		ENDIF
	ELSE
		HELP(' ', 1, 'ATEN็ใO',,'NAO PODE ALTERAR A VALIDADE DE PLANILHA JA PROCESSADA!',1,1)
	ENDIF

	RESTAREA(AAREA)

RETURN( NIL )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณINCFIL    บAUTOR  ณMARLLON FIGUEIREDO  บ DATA ณ 16/06/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณPERMITE UTILIZAR O SALDO EXCEDENTE PARA INCLUIR UMA FILIAL  บฑฑ
ฑฑบ          ณPARA TRANSFERENCIA DE MATERIAL                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
USER FUNCTION INCFIL( NLIN )
*********************************************************************

	LOCAL AAREA      := GETAREA()
	LOCAL ODLG1, OCBX
	LOCAL LSAIR      := .F.
	LOCAL __CFILDEST := SPACE(2)
	LOCAL __QTDPC    := GDFIELDGET('ZE_QTDPC', NLIN)
	LOCAL __NQUANT   := GDFIELDGET('ZE_EXCED', NLIN)
	LOCAL __CCOD     := GDFIELDGET('ZE_PRODUTO', NLIN)
	LOCAL __DDATA    := GDFIELDGET('ZE_DTENTRE', NLIN)
	LOCAL __CDESTINO := GDFIELDGET('ZE_DESTINO', NLIN)
	LOCAL NSTART     := 0
	LOCAL LOK        := .F.
	LOCAL AITENS     := ARRAY(0)
	LOCAL _CFILS     := GDFIELDGET('ZE_DESTINO', NLIN)

	IF __NQUANT <= 0
		MSGINFO('NใO EXISTE SALDO EXCEDENTE DISPONIVEL PARA ESTE ITEM')
	ELSE
	//Jorge Oliveira - 03/09/10 - Todas as filiais poderao receber Pedidos
	/*
	// RECUPERO AS FILIAIS QUE NAO PODEM RECEBER TRANSFERENCIA
	FOR NSTART := 1 TO LEN(ACOLS)
	IF ACOLS[NSTART, GDFIELDPOS('ZE_PRODUTO')] = __CCOD
	IF ACOLS[NSTART, GDFIELDPOS('ZE_DTENTRE')] = __DDATA
	_CFILS := _CFILS + '/' + GDFIELDGET('ZE_DESTINO', NSTART)
	ENDIF
	ENDIF
	NEXT

	// RETORNA AS FILIAIS PARA TRANSFERENCIA
	AITENS := U_RETFILIAL( _CFILS )
	*/

	// RETORNA TODAS AS FILIAIS PARA TRANSFERENCIA, MENOS AS QUE NAO USAM ESTOQUE
		AITENS := U_RETFILIAL( GetMV("MV_FILSEST") )

		IF LEN(AITENS) > 0
			DEFINE MSDIALOG ODLG1 TITLE 'INCLUIR TRANSFERENCIA' FROM 0,0 TO 250,350 OF OMAINWND PIXEL
			DEFINE SBUTTON OBUT0 FROM 100,140 TYPE 01 ENABLE OF ODLG1 PIXEL ACTION(LOK:=LSAIR:=.T., ODLG1:END())
			DEFINE SBUTTON OBUT1 FROM 100,110 TYPE 02 ENABLE OF ODLG1 PIXEL ACTION(LSAIR:=.T., ODLG1:END())

			@ 011,008 SAY  AllTrim( __CCOD )+" - "+Posicione( "SB1", 1, xFilial("SB1") + AllTrim( __CCOD ), "B1_DESC" ) OF ODLG1 PIXEL

			@ 027,008 SAY 'FILIAL' OF ODLG1 PIXEL
			@ 025,055 COMBOBOX OCBX VAR  __CFILDEST ITEMS AITENS  OF ODLG1 PIXEL SIZE 80,100

			@ 042,008 SAY 'QUANTIDADE' OF ODLG1 PIXEL
			@ 040,055 MSGET __NQUANT PICTURE '@E 999999.99'  OF ODLG1 PIXEL SIZE 30,10 VALID (__NQUANT <= GDFIELDGET('ZE_EXCED') .AND. __NQUANT >= 0)

			ACTIVATE MSDIALOG ODLG1 CENTER VALID LSAIR

			IF LOK
			// CALCULA O PROXIMO ITEM
				_CNUMITEM := '00'
				FOR NSTART := 1 TO LEN(ACOLS)
					IF GDFIELDGET('ZE_ITEM', NSTART) > _CNUMITEM
						_CNUMITEM := GDFIELDGET('ZE_ITEM', NSTART)
					ENDIF
				NEXT
				_CNUMITEM := SOMA1(_CNUMITEM)

			// Jorge Oliveira - 28/12/10 - O excedente sempre serah zerado
			// Calculo o excedente do registro atual
			//GDFieldPut('ZE_EXCED'   , ( __QTDPC - __NQUANT ) )

			// ADCIONA A FILIAL NO ACOLS, REGISTRO NOVO
				AADD(ACOLS, ACLONE(ACOLS[NLIN]))

				GDFIELDPUT('ZE_DESTINO'	, SUBSTR(__CFILDEST,1,2), LEN(ACOLS))
				GDFIELDPUT('ZE_QTDTRAN'	, __NQUANT, LEN(ACOLS))
				GDFIELDPUT('ZE_QTDORIG'	, 0, LEN(ACOLS))
				GDFIELDPUT('ZE_QTDPC'	, 0, LEN(ACOLS))
				GDFIELDPUT('ZE_QTDRES'	, 0, LEN(ACOLS))
				GDFIELDPUT('ZE_ITEM'		, _CNUMITEM, LEN(ACOLS))
				GDFieldPut('ZE_EXCED'   , 0, LEN(ACOLS))
			// Jorge Oliveira - 10/11/2010 - Na criacao de um novo registro, deixa os campos vazios
				GDFIELDPUT('ZE_CODCLI'	, Space( 6 ), LEN(ACOLS))
				GDFIELDPUT('ZE_LOJA'		, Space( 2 ), LEN(ACOLS))

				N := LEN(ACOLS)
				U_IMDG002()
				N := NLIN

			ENDIF
		ELSE
			MSGINFO('NใO EXISTE FILIAL PARA RECEBER ESTA TRANSFERENCIA!')
		ENDIF
	ENDIF

	RESTAREA(AAREA)

RETURN()
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณIMD090PED บAUTOR  ณMARLLON FIGUEIREDO  บ DATA ณ 14/04/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณMOSTRA OS PEDIDOS DE VENDA VINCULADOS AO ITEM POSICIONADO DAบฑฑ
ฑฑบ          ณPLANILHA DE TRANSFERENCIA                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
USER FUNCTION IMD090PED( NLIN )
*********************************************************************

	LOCAL ALIST    := ARRAY(0)
	LOCAL OLIST, OBUT, ODLG
	LOCAL CPROD    := SPACE(0)
	LOCAL CFIL     := SPACE(0)
	LOCAL CITEM
	LOCAL AFIL     := ARRAY(0)
	LOCAL NFIL     := 0
	LOCAL CNOMFIL
	LOCAL NPOS
	LOCAL nSoma    := 0
	LOCAL CIMDEPA  := GETMV('MV_IMDEPA')


	IF ! GDDELETED(NLIN)
		CPROD := GDFIELDGET('ZE_PRODUTO', NLIN)
		CITEM := GDFIELDGET('ZE_ITEM', NLIN)

	// CARREGA AS FILIAIS DO SIGAMAT
		AAREASM0 := SM0->( GETAREA() )
		DBSELECTAREA('SM0')
		DBSEEK(CEMPANT)
		DO WHILE !EOF() .AND. SM0->M0_CODIGO == CEMPANT
			AADD( AFIL, {SM0->M0_CODFIL, SM0->M0_FILIAL} )
			DBSKIP()
		ENDDO
		RESTAREA(AAREASM0)

	// RECUPERO PEDIDOS DE TODAS AS FILIAIS
		ALIST := ARRAY(0)
		DBSELECTAREA('SC6')
		DBORDERNICKNAME('C6_PLAN')
		FOR NFIL := 1 TO LEN(AFIL)
			CFIL := AFIL[NFIL,1]
			IF DBSEEK(CFIL+M->ZE_NUMPLAN+CITEM+CPROD)
				DO WHILE !EOF() .AND. M->ZE_NUMPLAN == SC6->C6_PLANILH
					IF CPROD <> SC6->C6_PRODUTO
						DBSKIP()
						LOOP
					ENDIF
					IF CITEM <> SC6->C6_PLITEM
						DBSKIP()
						LOOP
					ENDIF

				// NAO MOSTRA OS PEDIDOS DA PROPRIA IMDEPA (TRANSFERENCIAS)
				//IF SC6->C6_CLI <> CIMDEPA
					// POSICIONA NO CLIENTE
					SA1->( DBSEEK(XFILIAL('SA1')+SC6->C6_CLI+SC6->C6_LOJA) )
					SA3->( DBSEEK(XFILIAL('SA3')+SA1->A1_VEND) )
					SC5->( DBSEEK(CFIL+SC6->C6_NUM) )

					NPOS := ASCAN(AFIL, {|X| X[1] == SC6->C6_FILIAL})
					IF NPOS > 0
						__CNOMFIL := AFIL[NPOS,2]
					ENDIF

					// CARREGA AS POSICOES PARA O VETOR LISTBOX
					// ATUALIZA O VETOR DO LISTBOX
					AADD(ALIST,{SC6->C6_NUM,;
						SC6->C6_ITEM,;
						__CNOMFIL,;
						SC5->C5_EMISSAO,;
						SC6->C6_PRODUTO,;
						SC6->C6_DESCRI,;
						SC6->C6_QTDVEN,;
						SC6->C6_ENTREG,;
						SA1->A1_NREDUZ,;
						SC6->C6_CLI,;
						SC6->C6_LOJA,;
						SA3->A3_NOME})

					If SC6->C6_CLI <> CIMDEPA
						nSoma += SC6->C6_QTDVEN
					EndIf
				//ENDIF

					DBSKIP()
				ENDDO

			ENDIF
		NEXT

	// TESTA SE ENCONTROU ALGUM REGISTRO, POIS O ARRAY NAO PODE
	// SER PASSADO VAZIO PARA A LISTBOX
		IF EMPTY(ALIST)
			ALIST := {{'','','','','','','','','','','',''}}
		ENDIF

	// MONTA UMA DIALOG COM UM BROWSE DO SC7 PARA SELECAO
		DEFINE MSDIALOG ODLG TITLE 'Pedidos de Venda Vinculados' FROM 0,0 TO 18,80 OF OMAINWND
		DEFINE SBUTTON OBUT FROM 122,270 TYPE 01 ENABLE OF ODLG PIXEL ACTION ODLG:END()

	// Jorge Oliveira - 12/11/10 - Colocada a soma dos pedidos de venda, sem os de Transferencia
		@ 124,008 SAY 'Total: ' OF ODLG PIXEL
		@ 122,025 GET oGet VAR nSoma PICTURE '@E 999,999,999.99' OF ODLG PIXEL READONLY

		@ 02,02  LISTBOX OLIST ;
			FIELDS HEADER  'PEDIDO','ITEM','FILIAL','EMISSAO','PRODUTO','DESCRI็ใO','QUANTIDADE','NECESSIDADE','CLIENTE','CODIGO','LOJA','VENDEDOR INTERNO' ;
			SIZE 300,120 ;
			PIXEL OF ODLG
		OLIST:ALIGN := 3

		OLIST:SETARRAY(ALIST)
		OLIST:BLINE:={|| {	ALIST[OLIST:NAT,01],;
			ALIST[OLIST:NAT,02],;
			ALIST[OLIST:NAT,03],;
			ALIST[OLIST:NAT,04],;
			ALIST[OLIST:NAT,05],;
			ALIST[OLIST:NAT,06],;
			ALIST[OLIST:NAT,07],;
			ALIST[OLIST:NAT,08],;
			ALIST[OLIST:NAT,09],;
			ALIST[OLIST:NAT,10],;
			ALIST[OLIST:NAT,11],;
			ALIST[OLIST:NAT,12]}}
		OLIST:REFRESH()

		ACTIVATE MSDIALOG ODLG CENTERED

		DBSELECTAREA('SC6')
		DBSETORDER(1)
	ENDIF

RETURN NIL
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณIMD090GER บAUTOR  ณMARLLON FIGUEIREDO  บ DATA ณ 20/03/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณDISPARA O PROCESSAMENTO DA PLANILHA  COM GERACAO DE PEDIDOS บฑฑ
ฑฑบ          ณDE COMPRA NAS FILIAIS DESTINO, GERACAO DE PEDIDOS DE VENDA  บฑฑ
ฑฑบ          ณPARA TRANSFERENCIA NA FILIAL ORIGEM.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณESTA FUNCAO DEVE SER UTILIZADA SE FOR ACESSAR O PROCESSA-   บฑฑ
ฑฑบ          ณMENTO DA PLANILHA VIA MENU (AROTINA)                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
USER FUNCTION IMD090GER()
*********************************************************************

// TESTO SE A PLANILHA NAO ESTA SENDO USADA
	IF RECLOCK('SZE',.F.)
		MSUNLOCK()
		U_IMD090PROC()
	ENDIF

RETURN()
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณIMD090PROCบAUTOR  ณMARLLON FIGUEIREDO  บ DATA ณ 20/03/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณEXECUTA PROCESSAMENTO DA PLANILHA - TEM QUE ENTRAR NA FUNCAOบฑฑ
ฑฑบ          ณJA POSICIONADO NA PLANILHA QUE SERA PROCESSADA              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบPARAMETROSณLFLAG = .T. MOSTRA OS DIALOGOS PARA O USUARIO               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
USER FUNCTION IMD090PROC(LFLAG,LSETFILIAL,CNUMORC)
*********************************************************************

	LOCAL CNUMPLAN      := SZE->ZE_NUMPLAN
//LOCAL AITEMS        := ARRAY(0)
	LOCAL NOPCA         := 0
	LOCAL CCADASTRO     := OEMTOANSI("Processa a Planilha de Transfer๊ncia" )
	LOCAL ASAYS	        := {}
	LOCAL ABUTTONS      := {}
	LOCAL NCUSTO        := 0
	LOCAL NAUXICM       := 0
	LOCAL NCALCCUSI     := 0
	LOCAL CCODTRF       := GETMV('MV_IMDEPA')
	LOCAL CESTORI		:= GETMV('MV_ESTADO')
	LOCAL LSUBSTRIBUTARIA := .F.
	LOCAL CMENS
	Local cDescProd		:= ""
	Local cVendedor		:= ""
	Local lProcessou    := .T.

	Public aIPvImda090	:= ARRAY(0)

	DEFAULT LFLAG       := .T.
	DEFAULT LSETFILIAL  := .F.

//Edivaldo Gon็alves Cordeiro - Posiciona o cliente quando o processo for uma Transferencia via IMDA070
	If FunName() =='IMDA070'
		dbSelectArea("SA1")
		dbSeek(xfilial('SA1')+CCODTRF+cFilAnt)
	Endif


// TESTA SE A PLANILHA EH DA FILIAL ATIVA
	IF SZE->ZE_FLAGPT == 'S'
		IF LFLAG
			HELP(' ', 1, 'ATEN็ใO',,'ITEM DA PLANILHA Jแ FOI PROCESSADA E NใO PODE SOFRER NOVO PROCESSAMENTO!',1,1)
		ENDIF
		RETURN NIL
	ENDIF

// TESTA SE A PLANILHA EH DA FILIAL ATIVA
	IF SZE->ZE_MSFIL <> CFILANT .AND. LFLAG
		HELP(' ', 1, 'ATEN็ใO',,'ESTA PLANILHA SOMENTE PODERแ SER PROCESSADA NA FILIAL QUE A GEROU! - (FILIAL - '+SZE->ZE_MSFIL+')',1,1)
		RETURN NIL
	ENDIF

// POSICIONA NA PLANILHA
	DBSELECTAREA('SZE')
// Jorge Oliveira - 18/09/2010 - Alterado o posicionamento, antes era o 3 e agora eh 2
	DBSETORDER(2) // 2 => ZE_FILIAL + ZE_NUMPLAN + ZE_DESTINO + ZE_PRODUTO + DTOS( ZE_DTENTRE )
	DBSEEK(XFILIAL('SZE') + CNUMPLAN )
	DO WHILE !EOF() .AND. CNUMPLAN == SZE->ZE_NUMPLAN

		IF SZE->ZE_FLAGPT == 'S'
			DBSKIP()
			LOOP
		ENDIF

		IF FUNNAME() == 'IMDA070'
			NAUXICM   := SZE->(U_RETICMS(CFILORI, IIF(!Empty(SZE->ZE_DESTINO),SZE->ZE_DESTINO,cFilDest)))
		ELSE
			NAUXICM   := SZE->(U_RETICMS(CFILANT, SZE->ZE_DESTINO))
		ENDIF


//	NCALCCUSI     := (100-NAUXICM)/100


	// POSICIONA NO SB2 PARA PEGAR O CUSTO DO MATERIAL NA ORIGEM
		SB2->( DBSETORDER(1) )
		SB2->( DBSEEK(CFILANT+SZE->ZE_PRODUTO+SZE->ZE_LOCAL) )

	// POSICIONA NO PRODUTO
		SB1->( DBSEEK(CFILANT+SZE->ZE_PRODUTO) )

	//////////////////////////////////////////////// Data: 27/12/2012
	//////////////////////////////////////////////// Cristiano Machado
	//////////////////////////////////////////////// Aqui trata 4%
		If ( SB1->B1_ORIGEM $ "1/2") //|Tratamento importados
			NCALCCUSI     := (100-4)/100
		Else
			NCALCCUSI     := (100-NAUXICM)/100
		EndIF


/*
	// POSICIONA NO PEDIDO DE COMPRAS
	DBSELECTAREA('SC7')
	DBORDERNICKNAME('C7_PLAN')
	DBSEEK(SZE->ZE_MSFIL+SZE->ZE_NUMPLAN)
	// LOCALIZA O PRODUTO NO PEDIDO DE COMPRAS
	DO WHILE !EOF() .AND. SZE->ZE_NUMPLAN = SC7->C7_PLANILH
		IF SZE->ZE_PRODUTO = SC7->C7_PRODUTO
			EXIT
		ENDIF
		DBSKIP()
	ENDDO
	*/

	// CRISTIANO MACHADO 12/11/08 DESCOMENTADO LINHA ABAIXO
		NCUSTO := ROUND(SZE->(U_FCUSTRIB(.F.)),4)
		

	/*
	//IF SB2->B2_CM1 > 0//IF SB2->B2_CM1 > 0
	If NCUSTO<>0pl

		NCUSTO := SB2->B2_CM1

	ELSE
		IF EMPTY(SZE->ZE_HAWB)
			// PEDIDO DE COMPRAS NACIONAL
			NCUSTO := FORMULA('901')
		ELSE
			// PEDIDO DE COMPRAS IMPORTADO
			NCUSTO := FORMULA('902')
		ENDIF
	ENDIF
	*/
	/*
	ALERT("ICMS..........: " + ALLTRIM( CVALTOCHAR( NAUXICM   ) ) + CHR(13) +;
	"CUSTO UNITARIO: " + ALLTRIM( CVALTOCHAR( NCALCCUSI ) ) + CHR(13) +;
	"CUSTO.........: " + ALLTRIM( CVALTOCHAR( NCUSTO    ) ) )
	*/    
		If SB1->B1_GRUPO <> '0008'
			NCUSTO := ROUND(NCUSTO/NCALCCUSI,4)
		Endif

	// RETORNA PARA A PLANILHA
		DBSELECTAREA('SZE')

		IF SZE->ZE_DESTINO <> 'EX'

			IF SZE->ZE_QTDTRAN > 0
			// MONTAGEM DO ARRAY PARA GERACAO DOS PEDIDOS DE VENDA E COMPRA
				AADD(aIPvImda090, {  CFILANT,;
					SZE->ZE_PRODUTO,;
					SZE->ZE_QTDTRAN,;
					SZE->ZE_DESTINO,;
					SZE->ZE_NUMPLAN,;
					NCUSTO,;
					SZE->ZE_DTENTRE,;
					SZE->ZE_ITEM,;
					" ",;
					" ",;
					SZE->ZE_LOCAL,;
					SZE->( RECNO() ) })

			ENDIF
		ENDIF

		DBSELECTAREA("SZE")
		DBSKIP()
	ENDDO

// Jorge Oliveira - 16/08/2010 - Validacao para custo zerado !
//SC7->( DBSETORDER(1) )
	NOPCA := 0
	FOR NITEM := 1 TO LEN( aIPvImda090 )

		IF aIPvImda090[ NITEM, 6 ] <= 0

			CMENS := "CUSTO UNITARIO ZERADO DO PRODUTO '" + ALLTRIM( aIPvImda090[ NITEM, 2 ] ) + "' DA PLANILHA '" + ALLTRIM( aIPvImda090[ NITEM, 5 ] ) + "'." + CHR(13)+;
				"PLANILHA NAO SERAH PROCESSADA"

			IF LFLAG
				MsgInfo( CMENS )
			ENDIF

			CONOUT( "IMDA090 => " + CMENS )
			NOPCA := 1
			EXIT
		ENDIF

	NEXT

// SE ALGUM CUSTO DE PRODUTO ESTAH ZERADO, NAO PROCESSA A PLANILHA
	IF NOPCA == 1
		RETURN
	ENDIF

	If LFLAG
	// MONTA O FORM BATCH
		AADD(ASAYS,OEMTOANSI("Esta rotina tem como finalidade processar a planilha de transferencia "	))
		AADD(ASAYS,OEMTOANSI("e gerar os Pedidos de Venda e os Pedidos de Compras nas Filiais para "	))
		AADD(ASAYS,OEMTOANSI("distribui็ใo dos produtos."												))

		AADD(ABUTTONS, { 1,.T.,{|O| NOPCA := 1,FECHABATCH()}})
		AADD(ABUTTONS, { 2,.T.,{|O| FECHABATCH()}})
		FORMBATCH(CCADASTRO,ASAYS,ABUTTONS )
	Else
		NOPCA := 1
	EndIf

	IF NOPCA == 1
		IF  ( TYPE("LTK271AUTO") = "U" .OR. !LTK271AUTO )
			PROCESSA({|| lProcessou := PROCPLAN(aIPvImda090,CNUMPLAN,LSETFILIAL,CNUMORC )})//ALTERADO POR EDIVALDO GON็ALVES CORDEIRO EM 24/07/06
		ELSE                            			                         			       //INCLUIDO A PASSAGEM DE PARโMETROS CNUMORC
			lProcessou := PROCPLAN(aIPvImda090,CNUMPLAN, LSETFILIAL,'' )
		ENDIF
	ENDIF

RETURN

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณPROCPLAN  บAUTOR  ณMARLLON FIGUEIREDO  บ DATA ณ 31/03/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ PROCESSA A PLANILHA DE TRANSFERENCIA PARA GERACAO DOS PVS  บฑฑ
ฑฑบ          ณ E PCS NAS FILIAIS                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
STATIC FUNCTION PROCPLAN(AITEMS,CNUMPLAN,LSETFILIAL,CNUMORC)
*********************************************************************

	LOCAL AITEMPC       := ARRAY(0)
	LOCAL AITEMPV       := ARRAY(0)
	LOCAL NSTART
	LOCAL __XFIL
	LOCAL __CFILANT     := CFILANT
	LOCAL __LGERPC      := .T.
	LOCAL __LGERPV      := .T.
	LOCAL NPLANI        := 0

// Jorge Oliveira - 26/10/10 - Incluida variavel

	IF FUNNAME() == 'IMDA070'
		CFILANT := CFILORI
	Endif
// TAMANHO DA REGUA
	PROCREGUA(LEN(AITEMS))

// INICIA TRANSACAO
	BEGIN TRANSACTION

// CARREGA O VETOR DE ITENS DO PEDIDO DE COMPRAS
		__XFIL := 'XX'
		FOR NSTART := 1 TO LEN(AITEMS)
	// ATUALIZA A REGUA
			INCPROC()

			IF __XFIL <> AITEMS[NSTART,4]
		// FILIAL DESTINO PARA O PEDIDO DE COMPRAS
				__XFIL  := AITEMS[NSTART,4]
			ENDIF

	// SETA O ITEM PARA O PEDIDO DE VENDAS
	// VOU VENDER DA FILIAL ATIVA PARA A FILIAL DESTINO
			AADD(AITEMPV, { .F.,;                    // FILIAL
			AITEMS[NSTART,2],;       // PRODUTO
			AITEMS[NSTART,3],;       // QUANTIDADE
			AITEMS[NSTART,4],;       // LOJA DO CLIENTE NO PV
			AITEMS[NSTART,5],;       // NUMERO DA PLANILHA DE TRANSFERENCIA
			AITEMS[NSTART,6],;       // VALOR
			AITEMS[NSTART,7],;       // DATA DE ENTREGA
			AITEMS[NSTART,8],;       // ITEM DA PLANILHA DE TRANSFERENCIA
			AITEMS[NSTART,11]})       //ARMAZ้M  LOCAL DO PRODUTO

	// SETA O ITEM PARA O PEDIDO DE COMPRAS
	// VOU COMPRAR DA FILIAL QUE ESTAH ATIVA NO SISTEMA


			IF FUNNAME() == 'IMDA070'
				AADD(AITEMPC, { CFILDEST,;               // FILIAL QUE ESTA COMPRANDO
				AITEMS[NSTART,2],;       // PRODUTO
				AITEMS[NSTART,3],;       // QUANTIDADE
				'',;                     // NUMERO DA SOLICITACAO
				'',;                     // ITEM DA SOLICITACAO
				AITEMS[NSTART,6],;       // VALOR
				AITEMS[NSTART,7],;       // DATA DE ENTREGA
				AITEMS[NSTART,5],;       // NUMERO DA PLANILHA DE TRANSFERENCIA
				AITEMS[NSTART,8],;       // ITEM DA PLANILHA DE TRANSFERENCIA
				AITEMS[NSTART,4]})       // NUMERO DA FILIAL DESTINO

			ELSE
				AADD(AITEMPC, { __XFIL,;                 // FILIAL QUE ESTA COMPRANDO
				AITEMS[NSTART,2],;       // PRODUTO
				AITEMS[NSTART,3],;       // QUANTIDADE
				'',;                     // NUMERO DA SOLICITACAO
				'',;                     // ITEM DA SOLICITACAO
				AITEMS[NSTART,6],;       // VALOR
				AITEMS[NSTART,7],;       // DATA DE ENTREGA
				AITEMS[NSTART,5],;       // NUMERO DA PLANILHA DE TRANSFERENCIA
				AITEMS[NSTART,8],;       // ITEM DA PLANILHA DE TRANSFERENCIA
				AITEMS[NSTART,4]})       // NUMERO DA FILIAL DESTINO

			ENDIF

	// TESTA SE TEM OUTRO ITEM E SE ELE EH DA MESMA FILIAL,
	// SE NAO TIVER OU FOR DE OUTRA FILIAL ENTAO GERO O PEDIDO DE COMPRAS
			IF NSTART+1 > LEN(AITEMS) .OR. AITEMS[NSTART,4] <> AITEMS[NSTART+1,4]
		// SOMENTE GERO OS PEDIDOS DE COMPRA E VENDA SE FOR PARA UMA FILIAL DIFERENTE
		// DA ATIVA
				IF __XFIL <> CFILANT
			// GRAVA O PEDIDO DE COMPRAS NA FILIAL DESTINO (__XFIL)
					DBSELECTAREA('SC7')
			// TROCO PARA A FILIAL DESTINO
					IF LSETFILIAL
						TROCAFIL(__XFIL)
					ENDIF

					DbSelectArea( "SC7" )

					__LGERPC := U_INCPC(__XFIL, AITEMPC, .F. )

			// VOLTO PARA A FILIAL ORIGEM
					IF LSETFILIAL
						TROCAFIL(__CFILANT)
					ENDIF

					IF __LGERPC

				// GERA PV NA FILIAL QUE TEM O SALDO DISPONIVEL (PLANILHA)
						DBSELECTAREA('SC5')
				//ALTERADO POR EDIVALDO GON็ALVES CORDEIRO, INSERIDO A PASSAGEM DE PARโMETRO CNUMORC
				// Jorge Oliveira - 16/08/2010 - Incluido o parametro cNumPed, para retornar o Nr do PV
						__LGERPV := U_INCPV(CFILANT, AITEMPV, .T.,CNUMORC )

				// Jorge Oliveira - 16/08/2010 - Grava o Nr do PV no registro da filial correta
						IF __LGERPV

					// VOLTO PARA A FILIAL ORIGEM
							IF LSETFILIAL
								TROCAFIL(__CFILANT)
							ENDIF

						ENDIF
					ENDIF
				ENDIF

		// INICIALIZA PARA O PROXIMO PEDIDO
				AITEMPV  := ARRAY(0)
				AITEMPC  := ARRAY(0)
			ENDIF
		NEXT

// Marca a Planilha como processada
		DBSELECTAREA('SZE')
		DBSETORDER(1)
		DBSEEK(XFILIAL('SZE')+CNUMPLAN)
		DO WHILE !EOF() .AND. CNUMPLAN == SZE->ZE_NUMPLAN
			RECLOCK("SZE",.F.)
			SZE->ZE_FLAGPT := 'S'
			MSUNLOCK()
			DBSKIP()
		ENDDO

// FINALIZA A TRANSACAO
	END TRANSACTION

RETURN( __LGERPC )



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ ROTINA PARA CRIAR OS PEDIDOS DE VENDA DE TRANSFERENCIA PARA AS FILIAIS (PLANILHA)บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAUTOR     ณ DATA        DESCRICAO                                      บฑฑ
ฑฑบMARLLON   ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบPARAMETROSณ __CFIL      FILIAL ONDE DEVE SER GERADO O PEDIDO DE VENDAS บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ AITENS      ARRAY COM OS ITENS PARA GERACAO DO PEDIDO DE   บฑฑ
ฑฑบ          ณ             VENDAS:                                        บฑฑ
ฑฑบ          ณ             [01] = FLAG DE GRAVACAO                        บฑฑ
ฑฑบ          ณ             [02] = PRODUTO                                 บฑฑ
ฑฑบ          ณ             [03] = QUANTIDADE                              บฑฑ
ฑฑบ          ณ             [04] = LOJA DESTINO DA MERCADORIA (IMDEPA-XX)  บฑฑ
ฑฑบ          ณ             [05] = NUMERO DA PLANILHA DE TRANSFERENCIA     บฑฑ
ฑฑบ          ณ             [06] = VALOR UNITARIO                          บฑฑ
ฑฑบ          ณ             [07] = DATA DE ENTREGA                         บฑฑ
ฑฑบ          ณ             [08] = ITEM DA PLANILHA DE TRANSFERENCIA       บฑฑ
ฑฑบ          ณ             [11] = ARMAZEM DO PRODUTO                      บฑฑ
ฑฑบ          ณ LQTRANS     SE .T. USA SALDO DE TRANSFERENCIA B2_QTRANS    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบALTERACAO ณ                                                            บฑฑ
ฑฑบ002696    ณ MแRCIO B.   CHAMADO 002696 SOLICITA็ใO PARA MUDAR PARA CIF บฑฑ
ฑฑบ          ณ             OS PEDIDOS DE TRANSFER๊NCIA ATUTOMแTICOS       บฑฑ
ฑฑบAAZNSS    ณ MแRCIO B.   TES DE TRANSFERENCIA BUSCA PRIMEIRO DA ZA4,    บฑฑ
ฑฑบ          ณ             APOS BUSCA DO B1 E APOS BUSCA DO PARAMETRO     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบAAZNRN    ณ MแRCIO B.   C๓DIGO DA TRANPORTADORA VEM DO CADASTRO GEN.   บฑฑ
ฑฑบ          ณ             DA SX5 I6  PARA O SC5                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ23/06/06	 ณCRIADO CAMPO B1_TSPLAN PARA CONTROLAR A TES DE SAํDA QUANTO บฑฑ
ฑฑบ			 ณTRANSFERENCIA POR  PLANILHA. MANTIDO O PARโMETRO MV_TESTRF  บฑฑ
ฑฑบ			 ณNO CASO DE NใO HAVER SIDO GRAVADO O DADO NO SB1             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
USER FUNCTION INCPV(__CFIL, AITENS,LQTRANS,CNUMORC )
*********************************************************************

	LOCAL NITEM         := 0
	LOCAL CCODTRF       := GETMV('MV_IMDEPA')
	LOCAL AIT           := ARRAY(0)
	LOCAL AITEM         := ARRAY(0)
	LOCAL ACAB          := ARRAY(0)
	LOCAL __CFILANT     := CFILANT
	LOCAL LOKLIBAUT		:= .T.
	LOCAL CFILLOGIN     := SM0->M0_CODFIL
	LOCAL LRETWMS

	LOCAL CTESSITTRIB 	:= " "
	LOCAL CESTORI		  	:= " "
	LOCAL cNumPed        := ""

	PRIVATE LMSHELPAUTO := .T. // SE .T. DIRECIONA AS MENSAGENS DE HELP PARA O ARQ. DE LOG
	PRIVATE LMSERROAUTO := .F. //NECESSARIO A CRIACAO, POIS SERA ATUALIZADO QUANDO HOUVER ALGUMA INCOSISTENCIA NOS PARAMETROS


// ALTERNA PARA A FILIAL QUE VAI INCLUIR O PEDIDO
	CFILANT := __CFIL

	CESTORI := GETMV('MV_ESTADO')

	CLOJA := 'XX'
	CITEM := '00'
	FOR NITEM := 1 TO LEN(AITENS)
		IF CLOJA <> AITENS[NITEM,4]
		// INICIALIZA VARIAVEIS DE CONTROLE
			CLOJA   := AITENS[NITEM,4]
			CITEM   := '00'
			AIT     := ARRAY(0)

			ACAB  := {	{'C5_TIPO'     ,'N'        , },;
				{'C5_CLIENTE'  ,CCODTRF    , },;
				{'C5_LOJACLI'  ,CLOJA      , },;
				{'C5_LOJAENT'  ,CLOJA      , },;
				{'C5_TIPOCLI'  ,'R'        , },;
				{'C5_CONDPAG'  ,'001'      , },;
				{'C5_EMISSAO'  ,DDATABASE  , },;
				{'C5_TPFRETE'  ,IIF(POSICIONE("SA1",1,XFILIAL("SA1")+CCODTRF+CLOJA,"A1_TPFRET")=" ","F",POSICIONE("SA1",1,XFILIAL("SA1")+CCODTRF+CLOJA,"A1_TPFRET")), },;
				{'C5_LIBEROK'  ,'S'        , },;
				{'C5_LIBERAD'  ,RETCODUSR(), } }

		// CHAMADO  AAZNRN
		//	DBSELECTAREA('SX5')
			SX5->(DBSETORDER(1))
			IF SX5->(DBSEEK(XFILIAL('SX5')+'I6'+ CFILANT + CLOJA ))
				AADD(ACAB,{'C5_TRANSP'     ,ALLTRIM(SX5->X5_DESCRI), } )
			ENDIF


		*******************************************************************************************
		//INSERIDO POR EDIVALDO GON็ALVES CORDEIRO EM 24/07/06                                              //
		//INSERE O N๚MERO DO OR็AMENTO NO PEDIDO DE TRANSFER๊NCIA DA CASA QUE VAI DISPONIBLIZAR O ITEM      //
		//QUANDO A ROTINA FOR DISPARADA PELO CALL CENTER E O ITEM FOR DE TRANSFER๊NCIA                      //
		*******************************************************************************************
			IF FUNNAME()='TMKA271'
				AADD(ACAB,{'C5_NUMSUA'     ,CNUMORC   , } )
			ENDIF

		// DEFINE OS CAMPOS DO VETOR DE ITEM PARA O PEDIDO DE VENDAS
			AITEM  :={	{'C6_ITEM'      , ,  },;
				{'C6_PRODUTO'   , ,  },;
				{'C6_UM'        , ,  },;
				{'C6_QTDVEN'    , ,  },;
				{'C6_PRCVEN'    , ,  },;
				{'C6_TES'       , ,  },;
				{'C6_CF'        , ,  },;
				{'C6_LOCAL'     , ,  },;
				{'C6_ENTREG'    , ,  },;
				{'C6_DESCRI'    , ,  },;
				{'C6_PRUNIT'    , ,  },;
				{'C6_QTDLIB'    , ,  },;
				{'C6_TPOP'      ,'F',},;
				{'C6_PLANILH'   , ,  },;
				{'C6_PLITEM'    , ,  },;
				{'C6_FILTRAN'   , IIF(LQTRANS, CFILANT, ''),  } }

		// IDADE
			AADD( AITEM,{'C6_IDADE'  ,, })
			AADD( AITEM,{'C6_IDADE2' ,, })
			AADD( AITEM,{'C6_COEFC'  ,, })
			AADD( AITEM,{'C6_COEFF'  ,, })


			MSAGUARDE({||LRETWMS:=SF4->(U_CHECKWMS(AITENS[NITEM,2])) },"WMS","CHECANDO SE O PRODUTO POSSUI CONTROLE DE LOCALIZA็ใO ...")

			IF LRETWMS

				AADD( AITEM,{'C6_ENDPAD'    ,SF4->(POSICIONE("SBE",6,XFILIAL("SBE") +'000007'+'01',"BE_LOCALIZ")), },;
					{'C6_SERVIC'    ,SF4->(POSICIONE("DC5",2,XFILIAL("DC5") +'002'         ,"DC5_SERVIC")), })
			ENDIF

		ENDIF
	// POSICIONA NO PRODUTO
		SB1->( DBSEEK(XFILIAL('SB1')+AITENS[NITEM,2]) )


	// LOCALIZO A TES
	// ********** MARCIO

	// VERIFICA SE PRODUTO DEVE USAR TES DE SUBTITUICAO TRIBUTARIA

	// INICIALIZA VARIแVEL DE CONTROLE
		CTESSITTRIB := " "

		SA1->( DBSEEK(XFILIAL('SA1') + CCODTRF + CLOJA) )
		CTESSITTRIB := U_FSUBTRIB(CFILANT,"S","N",SA1->A1_TIPO,SA1->A1_EST,SB1->B1_POSIPI,SUBSTR(SA1->A1_GRPSEG,3,1),2)// VERIFICA SE E PRODUTO COM SUBSTITUICAO TRIBUTARIA E TRAZ TES DE TRANSF

		IF !EMPTY(CTESSITTRIB) // VERIFICA SE E PRODUTO COM SUBSTITUICAO TRIBUTARIA
			CTES	:= CTESSITTRIB
		ELSEIF  !EMPTY(SB1->B1_TSPLAN)//IF  !EMPTY(SB1->B1_TSPLAN)
			CTES := SB1->B1_TSPLAN
		ELSE
			IF XFILIAL("SF4") = "07" .AND. SB1->B1_GRUPO = "0011" //Agostinho - 30/04/2010 - Chamado AAZRXH - TES de corrente.
				CTES  := SUPERGETMV("MV_TESTRFC",.F.,GETMV('MV_TESTRF'),"07")
			ELSE
				CTES  := GETMV('MV_TESTRF')
			ENDIF

		ENDIF
	//********** FIM MARCIO

		SF4->( DBSEEK(XFILIAL('SF4')+CTES) )
		CCFOP := SF4->F4_CF

	// CARREGO OS ITENS
	// PREPARA O VETOR COM OS ITENS DO PEDIDO
		CITEM := SOMA1(CITEM)
		AITEM[1,2]  := CITEM
		AITEM[2,2]  := SB1->B1_COD
		AITEM[3,2]  := SB1->B1_UM
		AITEM[4,2]  := AITENS[NITEM,3]

	//JULIO JACOVENKO, em 13/04/2010 - ajustado para o
	//chamado AAZUSJ, para Ana Clara
	//AITEM[5,2]  := AITENS[NITEM,6]
	//IF ALLTRIM(SB1->B1_GRUPO)=='0008'
		AITEM[5,2]  := AITEM[11,2] := AITENS[NITEM,6] //SB1->(POSICIONE("SB2",1,CFILANT+SB1->B1_COD+SB1->B1_LOCPAD,"B2_CM1"))  //SB2->B2_CM1
	//ELSE
	//   AITEM[5,2]  := AITENS[NITEM,6]
	//ENDIF

		AITEM[6,2]  := CTES
		AITEM[7,2]  := CCFOP
		AITEM[8,2]  := AITENS[NITEM,9] //ARMAZ้M DO PRODUTO
		AITEM[09,2] := DDATABASE + 5   // TABELA('I5',CFILANT+__CFILANT,.F.)   // BUSCA PRAZO DA TABELA

	// CALCULA A DATA DE ENTREGA NA FILIAL DE ACORDOC OM A TABELA I5

		AITEM[10,2] := SB1->B1_DESC

	//JULIO JACOVENKO, em 13/04/2010 - ajustado para o
	//chamado AAZUSJ, para Ana Clara
	//AITEM[11,2] := AITENS[NITEM,6]
		IF ALLTRIM(SB1->B1_GRUPO)=='0008'
			AITEM[11,2] := SB1->(POSICIONE("SB2",1,CFILANT+SB1->B1_COD+SB1->B1_LOCPAD,"B2_CM1"))  //SB2->B2_CM1
		ELSE
			AITEM[11,2] := AITENS[NITEM,6]
		ENDIF

		AITEM[12,2] := 0
		AITEM[14,2] := AITENS[NITEM,5]
		AITEM[15,2] := AITENS[NITEM,8]


   //IDADE 

		SB2->( DBSETORDER(1) )
		SB2->( DBSEEK(CFILANT+AITENS[NITEM,2]+AITENS[NITEM,9]) )

		AITEM[17,2] := u_IdadeAtu(AITENS[NITEM,3],SB2->B2_IDADE,SB2->B2_DTIDADE)
		AITEM[18,2] := IF(SB2->B2_IDIMDE=0,u_IdadeAtu(AITENS[NITEM,3],SB2->B2_IDADE,SB2->B2_DTIDADE),u_IdadeAtu(AITENS[NITEM,3],SB2->B2_IDIMDE,SB2->B2_DTCALC))
		AITEM[19,2] := SB2->B2_COEFC
		AITEM[20,2] := SB2->B2_COEFF


	// ADCIONA O ITEM NO VETOR AITENS
		AADD( AIT, ACLONE(AITEM) )

	// TESTA SE TEM OUTRO ITEM E SE ELE EH DA MESMA FILIAL,
	// SE NAO TIVER OU FOR DE OUTRA FILIAL ENTAO GERO O PEDIDO
		IF NITEM+1 > LEN(AITENS) .OR. AITENS[NITEM,4] <> AITENS[NITEM+1,4]

			DBSELECTAREA('SC5')
			IF CITEM <> '00'  // SOMENTE GRAVO O PEDIDO SE EXISTIREM ITENS
			// INICIA A TRANSACAO DE INCLUSAO DO PEDIDO DE VENDAS


				MSEXECAUTO({|W,X,Y| MATA410(W,X,Y)},ACAB,AIT,3)
			
				If ValType ( aIPvImda090 ) == 'A' //
					aIPvImda090 := Nil // Reseta Variavel Publica com Itens...que formam Pedido controle que foi necessario devido ao PE OM010PRC
				EndIf
			
				IF LMSERROAUTO
				/*
				SE ESTIVER EM UMA APLICAO NORMAL E OCORRER ALGUMA INCOSISTENCIA NOS
				PARAMETROS PASSADOS,MOSTRAR NA TELA O LOG INFORMANDO QUAL COLUNA
				TEVE A INCOSISTENCIA.
				*/
					IF  ( TYPE("LTK271AUTO") <> "U" .AND. LTK271AUTO )
						MOSTRAERRO("\HHTRG\LOGS\")
					ELSE
						MOSTRAERRO()
					ENDIF

				ELSE
					IF LOKLIBAUT // SE ้ PARA LIBERA AUTOMATICO OS PEDIDOS DE TRANSFERENCIA
					//LIBERA O PEDIDO
					
						IF !EMPTY(SC5->C5_LIBERAD)
							RECLOCK("SC5",.F.)
							SC5->C5_LIBEROK := "S"
							SC5->C5_IMDREP	:= "2"     //OBESRVOU-SE SER NECESSแRIO PASSAR PARA 2 EM PV DE TRANSF.
							MSUNLOCK()

						//---FIM DA FLAG
							SC6->(DBSETORDER(1))		// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
							SC6->(DBSEEK(XFILIAL("SC6")+SC5->C5_NUM,.F.))
							SA1->( DBSEEK(XFILIAL('SA1')+SC6->C6_CLI+SC6->C6_LOJA) )

							DBSELECTAREA('SC6')
							DO WHILE !EOF() .AND. XFILIAL('SC6') == SC6->C6_FILIAL .AND. SC5->C5_NUM == SC6->C6_NUM
							// FUNCAO MICROSIGA PARA LIBERACAO DO ITEM POSICIONADO DO PEDIDO SC6
							//PARAMETROS EXPN1: REGISTRO DO SC6
							//EXPN2: QUANTIDADE A LIBERAR
							//EXPL3: BLOQUEIO DE CREDITO
							//EXPL4: BLOQUEIO DE ESTOQUE
							//EXPL5: AVALIACAO DE CREDITO
							//EXPL6: AVALIACAO DE ESTOQUE
							//EXPL7: PERMITE LIBERACAO PARCIAL
							//EXPL8: TRANFERE LOCAIS AUTOMATICAMENTE
							//EXPA9: EMPENHOS ( CASO SEJA INFORMADO NAO EFETUA A GRAVACAO
							//APENAS AVALIA ).
							//EXPBA: CODBLOCK A SER AVALIADO NA GRAVACAO DO SC9
							//EXPAB: ARRAY COM EMPENHOS PREVIAMENTE ESCOLHIDOS
							//(IMPEDE SELECAO DOS EMPENHOS PELAS ROTINAS)
							//EXPLC: INDICA SE APENAS ESTA TROCANDO LOTES DO SC9
							//EXPND: VALOR A SER ADICIONADO AO LIMITE DE CREDITO
							//EXPNE: QUANTIDADE A LIBERAR - SEGUNDA UM
							// PROCESSA A LIBERACAO DO ITEM
								BEGIN TRANSACTION
									MALIBDOFAT(SC6->(RECNO()),SC6->C6_QTDVEN,.T.,.T.,.T.,.T.,.F.,.F.,,)
								END TRANSACTION
								DBSKIP()
							ENDDO
						ENDIF
					ENDIF

				ENDIF
			ENDIF

		ENDIF
	NEXT

// RETORNA PARA A FILIAL ORIGINAL
	CFILANT := __CFILANT

RETURN(! LMSERROAUTO)   // RETORNA .T. SE TEVE SUCESSO NA GERACAO DO PEDIDO

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ INCPC     ณ Autor ณ Marllon Figueiredo   ณ Data ณ 27/02/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Cria os pedidos de compra para a filial solicitante        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ U_INCPC()                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ __cFil    - Filial onde deve ser gerado o pedido de compra ณฑฑ
ฑฑณ          ณ aItens    - Array com os itens para geracao do PC          ณฑฑ
ฑฑณ          ณ           -  [01] = Loja (IMDEPA) de onde esta comprando   ณฑฑ
ฑฑณ          ณ           -  [02] = Produto                                ณฑฑ
ฑฑณ          ณ           -  [03] = Quantidade                             ณฑฑ
ฑฑณ          ณ           -  [04] = Numero da solicitacao                  ณฑฑ
ฑฑณ          ณ           -  [05] = Item da solicitacao                    ณฑฑ
ฑฑณ          ณ           -  [06] = Valor unitario                         ณฑฑ
ฑฑณ          ณ           -  [07] = Data de previsao de entrega            ณฑฑ
ฑฑณ          ณ           -  [08] = Numero da planilha de transferencia    ณฑฑ
ฑฑณ          ณ           -  [09] = Item da planilha de transferencia      ณฑฑ
ฑฑณ          ณ           -  [10] = Numero da filial destino               ณฑฑ
ฑฑณ          ณ lGeraPlan -  Se .T. gerar uma planilha de transferencia    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ .T. Se teve sucesso na geracao do pedido                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Estoque / Custos                                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ PROGRAMADOR  ณ DATA   ณ DESCRICAO                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณJorge Oliveiraณ16/08/10ณ Ajustes no P10 para que a rotina possa gerar  ณฑฑ
ฑฑณ              ณ        ณ os Pedidos, pois estava dando erros difersos. ณฑฑ
ฑฑณ              ณ        ณ Ajustes de padronizacao.                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
/*/
USER FUNCTION INCPC(__CFIL, AITENS, LGERAPLAN )

	LOCAL NITEM         := 0
	LOCAL CCODTRF       := GETMV('MV_IMDEPA')
	LOCAL CTESA         := GETMV('MV_TESTRFE')
	LOCAL AIT           := {}
	LOCAL AITEM         := ARRAY(0)
	LOCAL ACAB          := ARRAY(0)
	LOCAL __CFILANT     := CFILANT
	LOCAL AAREASA2      := SA2->( GETAREA() )
	LOCAL cNumPed       :=" "
	LOCAL cPed
	LOCAL _cAtuaFili
	Local cLocPadDest   :=" "
	PRIVATE LMSHELPAUTO := .T. // SE .T. DIRECIONA AS MENSAGENS DE HELP PARA O ARQ. DE LOG
	PRIVATE LMSERROAUTO := .F. // NECESSARIO A CRIACAO, POIS SERA ATUALIZADO QUANDO HOUVER ALGUMA INCOSISTENCIA NOS PARAMETROS


// ALTERNA PARA A FILIAL QUE VAI INCLUIR O PEDIDO
	IF FUNNAME() == 'IMDA070'
		CFILANT := CFILDEST
		CLOJA   := CFILORI
	ELSE
		CFILANT := __CFIL
		CLOJA   := __CFILANT
	ENDIF

// ORDENA O ARRAY PELA FILIAL QUE VAI RECEBER A MERCADORIA
	AITENS := ASORT( AITENS,,, {|X,Y| X[10] > Y[10] })

	CITEM := '0000'
	FOR NITEM := 1 TO LEN(AITENS)

	// POSICIONA NO FORNECEDOR
		SA2->( DBSEEK(XFILIAL('SA2')+CCODTRF+CLOJA) )

	// CABECALHO DO PEDIDO DE COMPRAS
	// Jorge Oliveira - 21/09/2010 - Alterado o conteudo do campo C7_FILENT de CLOJA para AITENS[NITEM,10]
		ACAB   := {	{'C7_FILIAL'   ,AITENS[NITEM,10]	},;
			{'C7_EMISSAO'  ,DDATABASE			},;
			{'C7_FORNECE'  ,CCODTRF            	},;
			{'C7_LOJA'     ,CLOJA              	},;
			{'C7_COND'     ,'001'              	},;
			{'C7_CONTATO'  ,''                 	},;
			{'C7_NUM'      ,''               	},;
			{'C7_FILENT'   ,AITENS[NITEM,10]	} }


	// ITENS DO PEDIDO DE COMPRAS
		AITEM  := {	{'C7_FILIAL'    , , },;
			{'C7_ITEM' 		, , },;
			{'C7_PRODUTO'   , , },;
			{'C7_UM'        , , },;
			{'C7_QUANT'     , , },;
			{'C7_PRECO'     , , },;
			{'C7_DATPRF'    , , },;
			{'C7_LOCAL'     , , },;
			{'C7_TES'       , , },;
			{'C7_PLANILH'   , , },;
			{'C7_PLITEM'    , , },;
			{'C7_PICM'      , , } }

	// Pega o Armaz้m Padrao de Destino da Mercadoria
		SB1->( DBSEEK(AITENS[NITEM,10]+AITENS[NITEM,2]) )
		cLocPadDest:=SB1->B1_LOCPAD

	// POSICIONA NO PRODUTO E NA TES
		SB1->( DBSEEK(XFILIAL('SB1')+AITENS[NITEM,2]) )
		SF4->( DBSEEK(XFILIAL('SF4')+CTESA) )

	///Adicionado por Julio Jacovenko em 05/07/2012
	///para ajustes de TES quando transferencia entre filiais
	///com base na tabela ZA4


		cTES:=U_IMDTesTr(cTESA,CCODTRF,SB1->B1_COD)



		IF ALLTRIM(CTES)==''
			CTES:=CTESA
		ENDIF
	////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////

		SF4->( DBSEEK(XFILIAL('SF4')+CTES) )

	// CARREGO OS ITENS
	// PREPARA O VETOR COM OS ITENS DO PEDIDO
		CITEM := SOMA1( CITEM, Len( SC1->C1_ITEM ) )

		AITEM[01,2] := AITENS[NITEM,10]
		AITEM[02,2] := CITEM
		AITEM[03,2] := SB1->B1_COD
		AITEM[04,2] := SB1->B1_UM
		AITEM[05,2] := AITENS[NITEM,3]
		AITEM[06,2] := AITENS[NITEM,6]
		AITEM[07,2] := AITENS[NITEM,7]
		AITEM[08,2] := cLocPadDest
		AITEM[09,2] := CTES
		AITEM[10,2] := AITENS[NITEM,8]
		AITEM[11,2] := AITENS[NITEM,9]

		IF FUNNAME() == 'IMDA070'   ///FUNCAO DAS TRANSFERENCIAS ENTRE FILIAIS
		//AITEM[12,2]   := SC7->(U_RETICMS(CFILORI, CFILDEST))
			NPERCUSI := SC7->(U_RETICMS(CFILORI, CFILDEST))
		ELSE
		//AITEM[12,2]   := SC7->(U_RETICMS(CFILANT, CLOJA))
			NPERCUSI := SC7->(U_RETICMS(CFILORI, CFILDEST))
		ENDIF

	///JULIO JACOVENKO, 03/01/2013  //////////////////////////////////////////
	////
	///PARA TRATAR (RESOLUCAO 13/2012) IMPOSTO PRODUTO IMPORTADO INTERESTADUAL
	//////////////////////////////////////////////////////////////////////////
		If ( SB1->B1_ORIGEM $ "1/2") //|Tratamento importados
			AITEM[12,2]     := 4
		Else
			AITEM[12,2]     := NPERCUSI
		EndIF
	//////////////////////////////////////////////////////////////////////////



	// ADCIONA O ITEM NO VETOR AITENS
		AADD( AIT, ACLONE(AITEM) )

	// TESTA SE TEM OUTRO ITEM E SE ELE EH DA MESMA FILIAL,
	// SE NAO TIVER OU FOR DE OUTRA FILIAL ENTAO GERO O PEDIDO
		IF NITEM+1 > LEN(AITENS) .OR. AITENS[NITEM,1] <> AITENS[NITEM+1,1]

			DBSELECTAREA('SC7')
			IF CITEM <> '0000'  // SOMENTE GRAVO O PEDIDO SE EXISTIREM ITENS
			// ESTA VARIAVEL VAI CONTROLAR A GERACAO DA PLANILHA NO PONTO DE ENTRADA
			// SE FOR .T. = GERA A PLANILHA
			// SE FOR .F. = NAO GERA A PLANILHA
				__LWFW120P := LGERAPLAN

				_cAtuaFili := cFilAnt
				cFilAnt  := AITENS[NITEM,10] //Filial destino que deve ser gravado o PC

				MSExecAuto({|v,x,y,z,a,b| MATA120(v,x,y,z,a,b)},1,ACAB,AIT,3)

				cFilAnt := _cAtuaFili

				IF LMSERROAUTO
				/*
				SE ESTIVER EM UMA APLICAO NORMAL E OCORRER ALGUMA INCOSISTENCIA NOS
				PARAMETROS PASSADOS, MOSTRAR NA TELA O LOG INFORMANDO QUAL COLUNA
				TEVE A INCOSISTENCIA.
				*/
					IF  ( TYPE("LTK271AUTO") <> "U" .AND. LTK271AUTO )
						MOSTRAERRO("\HHTRG\LOGS\")
					ELSE
						MOSTRAERRO()
					ENDIF

				ENDIF
			ENDIF
		ENDIF
	NEXT

// RETORNA PARA A FILIAL ORIGINAL
	CFILANT   := __CFILANT
	AAREASA2  := SA2->( GETAREA() )

RETURN(! LMSERROAUTO)   // RETORNA .T. SE TEVE SUCESSO NA GERACAO DO PEDIDO

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ VALLINGD บAUTOR  ณMARLLON FIGUEIREDO  บ DATA ณ 20/03/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ VALIDACAO DA LINHA DO ACOLS                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
USER FUNCTION VALLINGD()
*********************************************************************

	LOCAL LRET         := .T.
	LOCAL NPOSQTRANS   := ASCAN(AHEADER, {|X| ALLTRIM(X[2])=='ZE_QTDTRAN'})
	LOCAL NPOSQRES     := ASCAN(AHEADER, {|X| ALLTRIM(X[2])=='ZE_QTDRES' })
	LOCAL NPOSQEXCED   := ASCAN(AHEADER, {|X| ALLTRIM(X[2])=='ZE_EXCED'  })
	LOCAL NQTRANS      := ACOLS[N, NPOSQTRANS]
	LOCAL NQRES        := ACOLS[N, NPOSQRES]
	LOCAL NQEXCED      := ACOLS[N, NPOSQEXCED]

	IF NQEXCED < 0
		LRET := .F.
		HELP(' ', 1, "ATEN็ใO",,'NAO EXISTE SALDO EXCEDENTE PARA ESTA TRANSFERENCIA!',1,1)
	ENDIF

	IF LRET .AND. NQTRANS < NQRES
		LRET := .F.
		HELP(' ', 1, "ATEN็ใO",,'A QUANTIDADE A SER TRANSFERIDA NใO PODE SER MENOR QUE A RESERVA DE PEDIDOS!',1,1)
	ENDIF

RETURN(LRET)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณVALGDADOS บAUTOR  ณMARLLON FIGUEIREDO  บ DATA ณ 20/03/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ VALIDACAO DE TODO O ACOLS                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
USER FUNCTION VALGDADOS()
*********************************************************************

	Local lRet         := .T.
	Local nPos     	 := 0
	Local nPosDupli	 := 0
	Local cBkpPro		 := ""
	Local cBkpDes		 := ""
	Local cBkpCli		 := ""
	Local cBkpLoj		 := ""
	Local NPOSPROD	    := ASCAN(AHEADER, {|X| ALLTRIM(X[2])=='ZE_PRODUTO'})
	Local NPOSITEM	    := ASCAN(AHEADER, {|X| ALLTRIM(X[2])=='ZE_ITEM'   })
	Local NPOSDEST 	 := ASCAN(AHEADER, {|X| ALLTRIM(X[2])=='ZE_DESTINO'})
	Local NPOSCLIENTE	 := ASCAN(AHEADER, {|X| ALLTRIM(X[2])=='ZE_CODCLI' })
	Local NPOSLOJA		 := ASCAN(AHEADER, {|X| ALLTRIM(X[2])=='ZE_LOJA'   })
	Local NPOSQTDTRAN	 := ASCAN(AHEADER, {|X| ALLTRIM(X[2])=='ZE_QTDTRAN'})
	Local NPOSEXCED	 := ASCAN(AHEADER, {|X| ALLTRIM(X[2])=='ZE_EXCED'  })
	Local NITEM 		 := ACOLS[N, NPOSITEM]
	Local aDados		 := aClone( aCols )
	Local nPos			 := 0
	Local nQtdePed     := 0 // Quantidade total de Pedidos ( SC6 )
	Local nQtdeExc     := 0 // Quantidade excedente na linha
	Local nQtdeInf     := 0 // Quantidade informada na linha

	If ! U_VALLINGD()
		lRet := .F.
	EndIf

	DbSelectArea( "SA1" )
	DbSetOrder( 1 ) // A1_FILIAL + A1_COD + A1_LOJA

// Jorge Oliveira - 01/11/10 - Diversas validacoes para cada linha de produtos
	If lRet

	// Ordena por Produto, Destino, Cliente e Loja
		aSort( aDados,,, { |x,y| x[NPOSPROD]+x[NPOSDEST]+x[NPOSCLIENTE]+x[NPOSLOJA] < y[NPOSPROD]+y[NPOSDEST]+y[NPOSCLIENTE]+y[NPOSLOJA] } )
		For nPos := 1 To Len( aDados )

			If cBkpPro <> aDados[ nPos, NPOSPROD ]
				cBkpPro := aDados[ nPos, NPOSPROD ]
			EndIf

			If cBkpDes <> aDados[ nPos, NPOSDEST ]
				cBkpDes := aDados[ nPos, NPOSDEST ]
			EndIf

			If cBkpCli <> aDados[ nPos, NPOSCLIENTE ]
				cBkpCli := aDados[ nPos, NPOSCLIENTE ]
			EndIf

			If cBkpLoj <> aDados[ nPos, NPOSLOJA ]
				cBkpLoj := aDados[ nPos, NPOSLOJA ]
			EndIf

			If !Empty( cBkpCli ) .And. !Empty( cBkpLoj )
				If !SA1->( DbSeek( xFilial( "SA1" ) + cBkpCli + cBkpLoj ) )
					MsgInfo( "Cliente informado no item " + cValToChar( NITEM ) + " nใo foi localizado." )
					lRet := .F.
					Exit
				EndIf
			EndIf

			nPosDupli := aScan( aDados, { |x| x[NPOSPROD]+x[NPOSDEST]+x[NPOSCLIENTE]+x[NPOSLOJA] == cBkpPro+cBkpDes+cBkpCli+cBkpLoj } )

		// Se achou um Produto, Destino, Cliente e Loja em um registro diferente do atual, eh porque tem registro duplicado
			If nPosDupli > 0 .And. nPosDupli <> nPos
				MsgInfo( "Informe um Cliente / Loja diferente para o mesmo Produto e Destino." )
				lRet := .F.
				Exit
			EndIf

			If lRet
				nQtdePed := U_PEDPLAN( M->ZE_NUMPLAN, aDados[ nPos, NPOSITEM ], aDados[ nPos, NPOSPROD ] )
				nQtdeInf := aDados[ nPos, NPOSQTDTRAN ]
				nQtdeExc := aDados[ nPos, NPOSEXCED ]

			// Nao foi informado um cliente, entao consulta a quantidade para todos os clientes
				If Empty( cBkpCli )

				// Se a quantidade informada ou excedente for menor do que a quantidade jah existente de pedidos colocados
				// faz a critica e nao pode continuar.
					If ( ( nQtdeInf > 0 .And. nQtdeInf < nQtdePed ) .Or. ( nQtdeExc > 0 .And. nQtdeExc < nQtdePed ) )

						Help( "", 1, "A090VALGDADOS",,	"No item "+cValToChar( NITEM )+" a 'Qtd Transf' informada ้ menor do "+;
							"que os "+ AllTrim( Transform( nQtdePed, "@E 999,999,999.99" ) ) +;
							" necessแrios para os Pedidos jแ cadastrados.", 1, 3 )
						lRet := .F.
						Exit
					EndIf
				// Jah que foi informado um Cliente, deverah verificar se a quantidade informada eh suficiente para os
				// pedidos jah cadastrados e tambem deve verificar se o excedente eh suficiente para os pedidos jah cadastrados
				Else

				// Verifico se a quantidade informada eh suficiente para o Cliente / Loja informado
					nQtdePed := U_PEDPLAN( M->ZE_NUMPLAN, aDados[ nPos, NPOSITEM ], aDados[ nPos, NPOSPROD ], cBkpCli )
					If nQtdeInf < nQtdePed
						Help( "", 1, "A090VALGDADOS",,	"No item "+cValToChar( NITEM )+" a 'Qtd Transf' informada ้ menor do "+;
							"que os "+ AllTrim( Transform( nQtdePed, "@E 999,999,999.99" ) ) +;
							" necessแrios para os Pedidos jแ cadastrados para o Cliente.", 1, 3 )
						lRet := .F.
						Exit
					Endif

				// Verifico se o excedente eh suficiente para os outros clientes
					nQtdePed := U_PEDPLAN( M->ZE_NUMPLAN, aDados[ nPos, NPOSITEM ], aDados[ nPos, NPOSPROD ],, cBkpCli )
					If nQtdeExc < nQtdePed
						Help( "", 1, "A090VALGDADOS",,	"No item "+cValToChar( NITEM )+" a coluna 'Excedende' ้ menor do "+;
							"que os "+ AllTrim( Transform( nQtdePed, "@E 999,999,999.99" ) ) +;
							" necessแrios para os Pedidos jแ cadastrados para outros Clientes.", 1, 3 )
						lRet := .F.
						Exit
					Endif

				EndIf

			EndIf

		Next

	EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNAO    ณRETFILIAL ณ AUTOR ณ MARLLON FIGUEIREDO    ณ DATA ณ 16/06/2003 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRI…O ณ RETORNA UM ARRAY COM AS FILIAIS DISPONIVEIS PARA A EMPRESA   ณฑฑ
ฑฑณ          ณ ATUAL                                                        ณฑฑ
ฑฑณOBSERVACAOณ NAO ALTERAR O RETORNO DESTA FUNCAO.                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณPARAMETRO ณ_CFILS = SE FOR PASSADO UMA LISTA DE FILIAIS, ESTAS SERAO EX- ณฑฑ
ฑฑณ          ณ        CLUIDAS DO ARRAY DE RETORNO DESTA FUNCAO              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSINTAX    ณU_RETFILIAL() -> AFILIAIS                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
USER FUNCTION RETFILIAL( _CFILS )
*********************************************************************

	LOCAL AAREA     := GETAREA()
	LOCAL AAREASM0  := SM0->( GETAREA() )
	LOCAL __AFIL    := ARRAY(0)


	DEFAULT _CFILS := SPACE(0)

	DBSELECTAREA('SM0')
	DBSEEK(CEMPANT)
	DO WHILE !EOF() .AND. CEMPANT == SM0->M0_CODIGO
	// TRATAMENTO EXPECIFICO PARA FILIAL ATUAL DO SISTEMA
		IF SM0->M0_CODFIL $ _CFILS
			DBSKIP()
			LOOP
		ENDIF

		AADD(__AFIL, SM0->M0_CODFIL+'-'+SM0->M0_FILIAL)
		DBSKIP()
	ENDDO

	RESTAREA(AAREASM0)
	RESTAREA(AAREA)

RETURN(__AFIL)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณVALQTRANS บAUTOR  ณMARLLON FIGUEIREDO  บ DATA ณ 09/07/2004  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ VALIDA A QUANTIDADE DIGITADA                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
USER FUNCTION VALQTRANS()
*********************************************************************

	LOCAL LRET   := .T.

	IF M->ZE_QTDTRAN < M->ZE_QTDRES
		LRET := .F.
		HELP(' ', 1, "ATEN็ใO",,'A QUANTIDADE A TRANSFERIR NAO PODE SER MENOR QUE A QUANTIDADE RESERVADA EM PV!',1,1)
	ENDIF

RETURN(LRET)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณTROCAFIL  บAUTOR  ณMARLLON FIGUEIREDO  บ DATA ณ 09/07/2004  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ AJUSTA O STATUS DO SISTEMA PARA ACESSAR UMA NOVA FILIAL    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
STATIC FUNCTION TROCAFIL(__XFIL)
*********************************************************************

	CFILANT := __XFIL

RETURN



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ RETICMS  บAUTOR  ณMARLLON FIGUEIREDO  บ DATA ณ 09/08/2004  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESCRICAO ณ RETORNA O ICMS PARA O PEDIDO DE TRANSFERENCIA DE ACORDO COMบฑฑ
ฑฑบ          ณ O ESTADO ORIGEM E DESTINO DA MERCADORIA.                   บฑฑ
ฑฑบ          ณ DEVE ESTAR POSICIONADO NO SA2 (FORNECEDORES)  E NO SB1
ฑฑบ19/06/06  ณ MODIFICA TRATAMENTO DA CASA DE DESTINO E ORIGEM            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
USER FUNCTION RETICMS(CFILORI,CFILDEST)
*********************************************************************
	LOCAL AAREA      := GETAREA()
	LOCAL NVALOR     := 0
	LOCAL LINTERNA
	LOCAL LUSAEX     := .F.
	LOCAL CTES       := GETMV('MV_TESTRF')

// SE NใO INFORMADA A FILIAL DE ORIGEM CONSIDERA A ATUAL
	IF CFILORI == NIL
		CFILORI := CFILANT
	ENDIF

	IF CFILDEST == NIL
		CFILDEST := C5_LOJACLI
	ENDIF

// ARMAZENA A FILIAL QUE ESTOU
	CFILATUAL 	:= CFILANT

	CFILANT 	:= CFILORI 							//MODIFICA A FILIAL QUE ESTOU PARA A DE ORIGEM
	CESTORI		:= GETMV('MV_ESTADO')

	CFILANT 	:= CFILDEST                       	//MODIFICA A FILIAL QUE ESTOU PARA A DE DESTINO
	CESTDEST	:= GETMV('MV_ESTADO')

//RESTAURA A FILIAL
	CFILANT 	:= CFILATUAL

	LINTERNA := (CESTORI == CESTDEST)

// LOCALIZO A TES

	SF4->( DBSEEK(XFILIAL('SF4')+CTES) )

// TESTA SE TEM CALCULO DE ICMS
	IF SF4->F4_ICM = 'S'
	// VERIFICO SE TEM GRUPO DE TRIBUTACAO

	// SE NAO USOU EXCESSAO FISCAL OU O VALOR DA EXCESSAO FOR 0 (ZERO) ENTAO DEVO RECUPERAR PELOS PARAMETROS
		IF ! LUSAEX .OR. NVALOR = 0
		// SE O ESTADO DO FORNECEDOR FOR O MESMO DO DESTINO, USA ALIQUOTA INTERNA
			IF LINTERNA
				NVALOR := GETMV('MV_ICMPAD')
			ELSE
			// SE FOR OUTRO ESTADO, DEVO TESTAR SE A ALIQUOTA EH 7 OU 12
				IF (CESTDEST $ GETMV('MV_NORTE')) .and. !(CESTORI $ GETMV('MV_NORTE'))
					NVALOR := 7
				ELSE
					NVALOR := 12
				ENDIF
			ENDIF
		ENDIF
	ENDIF

	RESTAREA(AAREA)



RETURN(NVALOR)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณCADI6GEN  บAUTOR  ณMARCIO Q. BORGES    บ DATA ณ 31/03/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ CADASTRI DE TABELA GEN้RICA I6 - CADASTRO DE TRANSPORTADORAบฑฑ
ฑฑบ          ณ NAS TRANSFERENCIAS ENTRE FILIAIS                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ IMDEPA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
USER FUNCTION CADI6GEN()
*********************************************************************

	PRIVATE CCADASTRO := "CADASTRO DE TRANSPORTADORA PARA TRANFER๊NCIA "
	PRIVATE AROTINA   := { 	{ "PESQUISAR"    ,"AXPESQUI" 	, 0, 1},;
		{ "VISUALIZAR"   ,"AXVISUAL" 	, 0, 2},;
		{ "INCLUIR"      ,"AXINCLUI"	, 0, 3},;
		{ "ALTERAR"      ,"AXALTERA" 	, 0, 4},;
		{ "EXCLUIR"      ,"AXDELETA" 	, 0, 5}}

	DBSELECTAREA("SX5");DBSETORDER(1)

	SET FILTER TO SX5->X5_TABELA == "I6"

	MBROWSE( 06, 01, 22, 75, "SX5")

RETURN()
*********************************************************************
USER FUNCTION INCI6GEN()
*********************************************************************

	LOCAL LRETURN := .T.

	IF M->X5_TABELA  != 'I6'
		LRETURN := .F.
		MSGINFO("TABELA PARA CADASTRO DE TRANPORTADORA DE TRANFER๊NCIA DEVE SER I6")
	ENDIF

RETURN(LRETURN)


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ LOGPLANI  ณ Autor ณ Jorge Oliveira       ณ Data ณ 23/08/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Grava os Logs das Planilhas de Transferencias              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ U_LOGPLANI()                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cTipo   => "I", "A" ou "E"                                 ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑณ          ณ aDados  => Informacoes a serem gravadas.                   ณฑฑ
ฑฑณ          ณ            aDados[1][1] == Nome do campo                   ณฑฑ
ฑฑณ          ณ            aDados[1][2] == Valor do campo                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ .T. se Gravou ou Atualizou e .F. caso contrario            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Estoque / Custos                                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ PROGRAMADOR  ณ DATA   ณ DESCRICAO                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ        ณ                                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
/*/
User Function LOGPLANI( cTipo, aDados )

	Local   lRet    := .F.
	Local   nPos    := 0
	Local   aArea   := GetArea()
	Default cTipo   := ""
	Default aDados  := {}

// Inclusao, Alteracao, Exclusao
	If !Upper( cTipo ) $ "I_A_E"
		Return( lRet )
	EndIf

// Se nao foi passado nada, pega o conteudo do registro posicionado
	If Empty( aDados )

		If RecLock( "ZAK", .T. )

			ZAK->ZAK_TIPO    := cTipo
			ZAK->ZAK_NUMPLA  := SZE->ZE_NUMPLAN
			ZAK->ZAK_ITEM    := SZE->ZE_ITEM
			ZAK->ZAK_FILORI  := SZE->ZE_MSFIL
			ZAK->ZAK_FILDES  := SZE->ZE_DESTINO
			ZAK->ZAK_CODPRO  := SZE->ZE_PRODUTO
			ZAK->ZAK_DATA    := SZE->ZE_DATA
			ZAK->ZAK_QDTRAN  := SZE->ZE_QTDTRAN
			ZAK->ZAK_CODCLI  := SZE->ZE_CODCLI
			ZAK->ZAK_LOJA    := SZE->ZE_LOJA
			ZAK->ZAK_DTENTR  := SZE->ZE_DTENTRE
			ZAK->ZAK_VENCD   := SZE->ZE_VENCD
			ZAK->ZAK_VENCH   := SZE->ZE_VENCH
			ZAK->ZAK_JUSTIF  := ""
			ZAK->ZAK_CODCON  := SZE->ZE_CODCONT
			ZAK->ZAK_CODPE   := SZE->ZE_CODPE

			ZAK->ZAK_USUARI  := SubStr( cUsuario, 7, 15 )
			ZAK->ZAK_DTAALT  := dDataBase
			ZAK->ZAK_HRALT   := Time()
			lRet := .T.
			MsUnLock()
		EndIf

	Else

		If RecLock( "ZAK", .T. )

			ZAK->ZAK_TIPO := cTipo

			If ( nPos := aScan( aDados, {|x| x[1] == "ZE_NUMPLAN" } ) ) > 0
				ZAK->ZAK_NUMPLA := aDados[ nPos, 2 ]
			EndIf

			If ( nPos := aScan( aDados, {|x| x[1] == "ZE_ITEM" } ) ) > 0
				ZAK->ZAK_ITEM := aDados[ nPos, 2 ]
			EndIf

			If ( nPos := aScan( aDados, {|x| x[1] == "ZE_MSFIL" } ) ) > 0
				ZAK->ZAK_FILORI := aDados[ nPos, 2 ]
			EndIf

			If ( nPos := aScan( aDados, {|x| x[1] == "ZE_DESTINO" } ) ) > 0
				ZAK->ZAK_FILDES := aDados[ nPos, 2 ]
			EndIf

			If ( nPos := aScan( aDados, {|x| x[1] == "ZE_PRODUTO" } ) ) > 0
				ZAK->ZAK_CODPRO := aDados[ nPos, 2 ]
			EndIf

			If ( nPos := aScan( aDados, {|x| x[1] == "ZE_DATA" } ) ) > 0
				ZAK->ZAK_DATA   := aDados[ nPos, 2 ]
			EndIf

			If ( nPos := aScan( aDados, {|x| x[1] == "ZE_QTDTRAN" } ) ) > 0
				ZAK->ZAK_QDTRAN := aDados[ nPos, 2 ]
			EndIf

			If ( nPos := aScan( aDados, {|x| x[1] == "ZE_CODCLI" } ) ) > 0
				ZAK->ZAK_CODCLI := aDados[ nPos, 2 ]
			EndIf

			If ( nPos := aScan( aDados, {|x| x[1] == "ZE_LOJA" } ) ) > 0
				ZAK->ZAK_LOJA   := aDados[ nPos, 2 ]
			EndIf

			If ( nPos := aScan( aDados, {|x| x[1] == "ZE_DTENTRE" } ) ) > 0
				ZAK->ZAK_DTENTR := aDados[ nPos, 2 ]
			EndIf

			If ( nPos := aScan( aDados, {|x| x[1] == "ZE_VENCD" } ) ) > 0
				ZAK->ZAK_VENCD  := aDados[ nPos, 2 ]
			EndIf

			If ( nPos := aScan( aDados, {|x| x[1] == "ZE_VENCH" } ) ) > 0
				ZAK->ZAK_VENCH  := aDados[ nPos, 2 ]
			EndIf

			If ( nPos := aScan( aDados, {|x| x[1] == "ZE_JUSTIFI" } ) ) > 0
				ZAK->ZAK_JUSTIF := aDados[ nPos, 2 ]
			EndIf

			If ( nPos := aScan( aDados, {|x| x[1] == "ZE_CODCONT" } ) ) > 0
				ZAK->ZAK_CODCON := aDados[ nPos, 2 ]
			EndIf

			If ( nPos := aScan( aDados, {|x| x[1] == "ZE_CODPE" } ) ) > 0
				ZAK->ZAK_CODPE := aDados[ nPos, 2 ]
			EndIf

			ZAK->ZAK_USUARI := SubStr( cUsuario, 7, 15 )
			ZAK->ZAK_DTAALT := dDataBase
			ZAK->ZAK_HRALT  := Time()
			lRet := .T.
			MsUnLock()
		EndIf

	EndIf

	RestArea( aArea )

Return( lRet )

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ EstruVen  ณ Autor ณ Jorge Oliveira       ณ Data ณ 23/08/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Retorna os e-mail do Vendedor, Coordenador e Gerente do    ณฑฑ
ฑฑณ          ณ Cliente passado por parametro.                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ U_EstruVen()                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cCli  => Codigo do Cliente                                 ณฑฑ
ฑฑณ          ณ cLoja => Loja do Cliente                                   ณฑฑ
ฑฑณ          ณ cVend => Vendedor, Coordenador ou Gerente do Cliente       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ cMail => Lista de e-mails da Estrutura de Vendas           ณฑฑ
ฑฑณ          ณ cVend => Retorna o codigo do primeiro vendedor             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Todos Modulos                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ PROGRAMADOR  ณ DATA   ณ DESCRICAO                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ        ณ                                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
/*/
User Function EstruVen( cCli, cLoja, cVend )

	Local cMail		:= ""
	Local aArea     := GetArea()
	Local aAreaSA1	:= SA1->( GetArea() )
	Local aAreaSA3	:= SA3->( GetArea() )

	Default cVend	:= ""

// Cadastro de Clientes
	DbSelectArea( "SA1" )
	DbSetOrder( 1 ) // A1_FILIAL + A1_COD + A1_LOJA

// Cadastro de Vendedores
	DbSelectArea( "SA3" )
	DbSetOrder( 1 ) // A3_FILIAL + A3_COD

// Achou o Cliente e Loja
	If SA1->( DbSeek( xFilial("SA1") + cCli + cLoja ) )

	// Busca e-mail do Vendedor Interno
		If !Empty( SA1->A1_VEND )

			If SA3->( DbSeek( xFilial( "SA3" ) + SA1->A1_VEND ) ) .And. !Empty( SA3->A3_EMAIL )
				cMail += AllTrim( SA3->A3_EMAIL ) + "; "
			EndIf

			cVend := SA1->A1_VEND

		EndIf

	// Busca e-mail do Vendedor Externo
		If !Empty( SA1->A1_VENDEXT )

			If SA3->( DbSeek( xFilial( "SA3" ) + SA1->A1_VENDEXT ) ) .And. !Empty( SA3->A3_EMAIL )
				cMail += AllTrim( SA3->A3_EMAIL ) + "; "
			EndIf

			If Empty( cVend )
				cVend := SA1->A1_VENDEXT
			EndIf

		EndIf

	// Busca e-mail do Coordenador do Vendedor
		If !Empty( SA1->A1_VENDCOO )

			If SA3->( DbSeek( xFilial( "SA3" ) + SA1->A1_VENDCOO ) ) .And. !Empty( SA3->A3_EMAIL )
				cMail += AllTrim( SA3->A3_EMAIL ) + "; "
			EndIf

			If Empty( cVend )
				cVend := SA1->A1_VENDCOO
			EndIf

		EndIf

	// Busca e-mail o Gerente do Vendedor
		If !Empty( SA1->A1_GERVEN )

			If SA3->( DbSeek( xFilial( "SA3" ) + SA1->A1_GERVEN ) ) .And. !Empty( SA3->A3_EMAIL )
				cMail += AllTrim( SA3->A3_EMAIL ) + "; "
			EndIf

			If Empty( cVend )
				cVend := SA1->A1_GERVEN
			EndIf

		EndIf

	EndIf

	RestArea( aAreaSA3 )
	RestArea( aAreaSA1 )
	RestArea( aArea )

Return( cMail )


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ MailDire  ณ Autor ณ Jorge Oliveira       ณ Data ณ 23/08/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Retorna os e-mail dos Diretores para receber os comunicadosณฑฑ
ฑฑณ          ณ das movimentacoes das Planilhas e/ou das Reservas.         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ U_MailDire()                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cTipo => Tipo de Notificacao que irah receber              ณฑฑ
ฑฑณ          ณ          P => Notificacoes das Planilhas                   ณฑฑ
ฑฑณ          ณ          R => Notificacoes das Reservas                    ณฑฑ
ฑฑณ          ณ          C => Contrato de Parceria                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ cMail => Lista de e-mails                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Todos Modulos                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ PROGRAMADOR  ณ DATA   ณ DESCRICAO                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ        ณ                                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
/*/
User Function MailDire( cTipo )

	Local cTabX5 := "ZW"
	Local cMail  := ""
	Local cTmp   := ""

	Default cTipo := "P"

	Dbselectarea("SX5")
	DbSetOrder(1)

	If SX5->( Dbseek( xFilial( "SX5" ) + cTabX5 ) )

		While( SX5->X5_TABELA == cTabX5 )

		// Os e-mails cadastrados ateh o numero 100, irao receber notificacoes sobre as PLANILHAS
		If ( "P" $ Upper( cTipo ) .And. Val( SX5->X5_CHAVE ) <= 100 )

			// Nao repete o e-mail
			cTmp := Lower( AllTrim( SX5->X5_DESCRI ) )
			If ! cTmp $ cMail
				cMail += cTmp + "; "
			EndIf

			// Os e-mails cadastrados ENTRE os numeros 101 e 200, irao receber notificacoes sobre as RESERVAS
		ElseIf ( "R" $ Upper( cTipo ) .And. Val( SX5->X5_CHAVE ) > 100 .And. Val( SX5->X5_CHAVE ) <= 200 )

			// Nao repete o e-mail
			cTmp := Lower( AllTrim( SX5->X5_DESCRI ) )
			If ! cTmp $ cMail
				cMail += cTmp + "; "
			EndIf

			// Os e-mails cadastrados ENTRE os numeros 201 e 300, irao receber notificacoes sobre os CONTRATOS DE PARCERIA
		ElseIf ( "C" $ Upper( cTipo ) .And. Val( SX5->X5_CHAVE ) > 200 .And. Val( SX5->X5_CHAVE ) <= 300 )

			// Nao repete o e-mail
			cTmp := Lower( AllTrim( SX5->X5_DESCRI ) )
			If ! cTmp $ cMail
				cMail += cTmp + "; "
			EndIf

		EndIf

		SX5->( Dbskip() )

	EndDo
EndIf

Return( cMail )


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ A090PERALT ณ Autor ณ Jorge Oliveira      ณ Data ณ 22/10/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Verifica se o usuario tem permissao para Alterar ou Excluirณฑฑ
ฑฑณ          ณ a Planilha.                                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ U_A090PERALT()                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cUsu => Codigo do usuario, se nao informado serah o atual  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ lOk  => Tem ou nao a permissao                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Todos Modulos                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ PROGRAMADOR  ณ DATA   ณ DESCRICAO                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ        ณ                                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
/*/
User Function A090PERALT( cUsu )

	Local   aArea := GetArea()
	Local   lOk   := .T.

	Default cUsu  := RetCodUsr()

// Verifica se o usuario tem permissao para acessar a rotina
	DbSelectArea( "SY1" )
	DbSetOrder( 3 ) // Y1_FILIAL + Y1_USER
	SY1->( DbGoTop() )

// Busca todos os usuarios do Sistema que estao cadastrados como Compradores
	While SY1->( !EOF() )

		If !Empty( SY1->Y1_USER ) .And. SY1->Y1_USER == cUsu
			lOk := .T.
			Exit
		EndIf

		SY1->( DbSkip() )
	EndDo

	RestArea( aArea )

Return( lOk )
